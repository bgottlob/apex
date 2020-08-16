defmodule ApexDashWeb.PageController do
  use ApexDashWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

defmodule ApexDashWeb.RootLive do
  use Phoenix.LiveView
  use Phoenix.HTML

  def render(assigns) do
    ~L"""
    <%= f = form_for(:car_index, "#",
                     [phx_change: :select_car, phx_target: "#dashboard, #tyre-wear"]) %>
      <label>Select car:</label>
      <%= select(f, :car_index, Enum.map(0..19, &({&1, &1}))) %>
    </form>

    <%= live_render(@socket, ApexDashWeb.RacePositionLive, id: "race-position") %>
    <%= live_render(@socket, ApexDashWeb.DashboardLive, id: "dashboard") %>
    <%= live_render(@socket, ApexDashWeb.TyreWearChart, id: "tyre-wear") %>
    """
  end
end

defmodule ApexDashWeb.DashboardLive do
  use Phoenix.LiveView

  alias ApexDash.{ChartData, Series}

  def render(assigns) do
    ~L"""
    <h3>Selected car: <%= @car_index %></h3>
    <h1>Pace: <%= @pace %></h1>
    <br>
    <h1>Gear: <%= @gear %></h1>
    <br>
    <h2>Speed: <%= @speed %> km/h</h2>
    <br>
    <h2>RPM: <%= @rpm %> rpm</h2>
    <br>
    <h3><%= @rev_lights_percent %> %</h3>

    <h3>Brake/Throttle</h3>
    <div id="throttle" data-chart="<%= Jason.encode!(@throttle_data)%>">
      <svg width="600" height="300"></svg>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # Register to receive updates from ApexDash.LiveDispatcher process
    {:ok, _} = Registry.register(
      Registry.LiveDispatcher,
      __MODULE__,
      # In the future this value could correspond to the car index to focus on
      nil
    )

    throttle_data = %ChartData{
      length: 0,
      min_domain: 0,
      max_domain: 200,
      min_range: 0.0,
      max_range: 1.0,
      series: %{
        brake: %Series{color: "red", values: []},
        throttle: %Series{color: "steelblue", values: []}
      }
    }

    {:ok,
      socket
      |> assign(:pace, "Loading...")
      |> assign(:rpm, "Loading...")
      |> assign(:speed, "Loading...")
      |> assign(:gear, "Loading...")
      |> assign(:rev_lights_percent, "Loading...")
      |> assign(:throttle_data, throttle_data)
      |> assign(:car_index, nil)
    }
  end

  def handle_event("select_car", %{"car_index" => %{"car_index" => i}}, socket) do
    {:noreply, assign(socket, :car_index, String.to_integer(i))}
  end

  # Preprocessing on the first packet that comes in
  # If the car index has not been set yet, set it, then process packet normally
  def handle_info(%{header: %F1.PacketHeader{player_car_index: i}} = event,
                  %{assigns: %{car_index: nil}} = socket) do
    i = cond do
      i < 0 || i > 19 -> 0
      true -> i
    end
    handle_info(event, assign(socket, :car_index, i))
  end

  def handle_info(%F1.CarTelemetryPacket{header: header, car_telemetry_data: telemetry}, socket) do
    telemetry = elem(telemetry, socket.assigns.car_index)
    throttle_data = socket.assigns.throttle_data
                    |> ChartData.add_entry(:brake, telemetry.brake)
                    |> ChartData.add_entry(:throttle, telemetry.throttle)
                    |> ChartData.increment
    {:noreply,
      socket
      |> assign(:rpm, telemetry.engine_rpm)
      |> assign(:speed, telemetry.speed)
      |> assign(:gear, telemetry.gear)
      |> assign(:rev_lights_percent, telemetry.rev_lights_percent)
      |> assign(:throttle_data, throttle_data)
    }
  end

  def handle_info(%PaceUpdate{pace: pace, car_index: i},
                  %{assigns: %{car_index: i}} = socket) do
    {:noreply, assign(socket, :pace, pace)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  def terminate(_reason, socket) do
    msg = "Error: please refresh to keep loading data"
    {:shutdown,
      socket
      |> assign(:rpm, msg)
      |> assign(:speed, msg)
      |> assign(:gear, msg)
      |> assign(:rev_lights_percent, msg)
    }
  end
end

defmodule ApexDashWeb.TyreWearChart do
  use Phoenix.LiveView

  alias ApexDash.{ChartData, Series}

  def render(assigns) do
    ~L"""
    <h3>Tyre Wear</h3>
    <div id="tyre_wear" data-chart="<%= Jason.encode!(@tyre_wear_data)%>">
      <svg width="600" height="300"></svg>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    # Register to receive updates from ApexDash.LiveDispatcher process
    {:ok, _} = Registry.register(
      Registry.LiveDispatcher,
      __MODULE__,
      # In the future this value could correspond to the car index to focus on
      nil
    )

    tyre_wear_data = %ChartData{
      length: 0,
      min_domain: 0,
      max_domain: 200,
      min_range: 0,
      max_range: 10,
      series: %{
        rear_left: %Series{color: "red", values: []},
        rear_right: %Series{color: "red", values: []},
        front_left: %Series{color: "blue", values: []},
        front_right: %Series{color: "blue", values: []}
      }
    }

    {:ok,
      socket
      |> assign(:tyre_wear_data, tyre_wear_data)
      |> assign(:car_index, nil)
    }
  end

  # Preprocessing on the first packet that comes in
  # If the car index has not been set yet, set it, then process packet normally
  def handle_info(%{header: %F1.PacketHeader{player_car_index: i}} = event,
                  %{assigns: %{car_index: nil}} = socket) do
    i = cond do
      i < 0 || i > 19 -> 0
      true -> i
    end
    handle_info(event, assign(socket, :car_index, i))
  end

  def handle_info(%F1.CarStatusPacket{header: header, car_statuses: statuses}, socket) do
    status = elem(statuses, socket.assigns.car_index)
    {rl, rr, fl, fr} = status.tyres_wear
    tyre_wear_data = socket.assigns.tyre_wear_data
                |> ChartData.add_entry(:rear_left, rl)
                |> ChartData.add_entry(:rear_right, rr)
                |> ChartData.add_entry(:front_left, fl)
                |> ChartData.add_entry(:front_right, fr)
                |> ChartData.increment

    {:noreply, assign(socket, :tyre_wear_data, tyre_wear_data)}
  end

  def handle_event("select_car", %{"car_index" => %{"car_index" => i}}, socket) do
    {:noreply,
      socket
      |> assign(:car_index, String.to_integer(i))
      |> assign(:pace, "Waiting to complete a lap...")
    }
  end
end

# %RacePosition{
#   car_index:  11,
#   position: 2,
#   pace: 91.35,
#   current_lap_num: 4,
#   is_player_car: true
# }
defmodule ApexDashWeb.RacePosition do
  defstruct [:car_index, :car_position, :pace, :current_lap_num, :is_player_car, :pace_diff]
end

defmodule ApexDashWeb.PaceDiff do
  defstruct [:ahead, :behind]
end

defmodule ApexDashWeb.RacePositionLive do
  use Phoenix.LiveView

  alias ApexDashWeb.{PaceDiff, RacePosition}

  def render(assigns) do
    ~L"""
    <ol>
    <%= for p <- @positions do %>
      <li>
      <%= if p.is_player_car do %>
        <strong>Car #<%= p.car_index %></strong>
      <% else %>
        Car #<%= p.car_index %>
      <% end %>
      : <%= p.pace %>
      </li>
    <% end %>
    </ol>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, _} = Registry.register(
      Registry.LiveDispatcher,
      __MODULE__,
      nil
    )
    {:ok,
      socket
      |> assign(:positions, [])
      |> assign(:pace_by_car_index, List.to_tuple(for _ <- 0..19, do: 0.0))
    }
  end

  def handle_info(
    %F1.LapDataPacket{header: %{player_car_index: player_car_index},
                      lap_data: lap_data},
    socket
  ) do
    positions = Tuple.to_list(lap_data)
                # Remove cars not in the race
                |> Stream.filter(fn %F1.LapData{car_position: p} -> p > 0 end)
                |> Stream.with_index(0)
                |> Stream.map(fn {d, i} ->
                  %RacePosition{ car_index: i,
                     car_position: d.car_position,
                     pace: elem(socket.assigns.pace_by_car_index, i),
                     current_lap_num: d.current_lap_num,
                     is_player_car: player_car_index == i,
                     pace_diff: %PaceDiff{ ahead: 0.0, behind: 0.0 }
                  }
                end)
                |> Enum.sort_by(&(&1.car_position), :asc)
                |> add_pace_diffs()
    {:noreply, assign(socket, :positions, positions)}
  end

  def handle_info(%PaceUpdate{pace: pace, car_index: i}, socket) do
    {:noreply, assign(socket, :pace_by_car_index, put_elem(socket.assigns.pace_by_car_index, i, pace))}
  end

  defp add_pace_diffs(positions) do
    add_pace_diffs(positions, nil, [])
  end

  defp add_pace_diffs([], _ahead, acc), do: Enum.reverse(acc)

  defp add_pace_diffs([curr, behind | rest], nil, acc) do
    curr = Map.put(curr, :pace_diff, pace_diff(curr, nil, behind))
    add_pace_diffs([behind | rest], curr, [curr | acc])
  end

  defp add_pace_diffs([curr, behind | rest], ahead, acc) do
    curr = Map.put(curr, :pace_diff, pace_diff(curr, ahead, behind))
    add_pace_diffs([behind | rest], curr, [curr | acc])
  end

  defp add_pace_diffs([curr], ahead, acc) do
    curr = Map.put(curr, :pace_diff, pace_diff(curr, ahead, nil))
    add_pace_diffs([], curr, [curr | acc])
  end

  defp pace_diff(curr, ahead, behind) do
    diff = %PaceDiff{}
    if ahead do
      diff = %{ diff | ahead: curr.pace - ahead.pace }
    else
      diff = %{ diff | ahead: 0.0 }
    end

    if behind do
      diff = %{ diff | behind: curr.pace - behind.pace }
    else
      diff = %{ diff | behind: 0.0 }
    end

    diff
  end
end
