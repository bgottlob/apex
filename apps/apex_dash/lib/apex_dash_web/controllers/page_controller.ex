defmodule ApexDashWeb.PageController do
  use ApexDashWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

defmodule ApexDashWeb.DashboardLive do
  use Phoenix.LiveView

  alias ApexDash.{ChartData, Series}

  def render(assigns) do
    ~L"""
    <h1>Pace: <%= @pace %></h1>
    <br>
    <h1>Gear: <%= @gear %></h1>
    <br>
    <h2>Speed: <%= @speed %> km/h</h2>
    <br>
    <h2>RPM: <%= @rpm %> rpm</h2>
    <br>
    <h3><%= @rev_lights_percent %> %</h3>

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
    }
  end

  def handle_info(%F1.CarTelemetryPacket{car_telemetry_data: telemetry}, socket) do
    telemetry = elem(telemetry, 0)
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

  def handle_info(%PaceUpdate{} = pace_update, socket) do
    {:noreply, assign(socket, :pace, pace_update.value)}
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
        rear_left: %Series{color: "orange", values: []},
        rear_right: %Series{color: "red", values: []},
        front_left: %Series{color: "blue", values: []},
        front_right: %Series{color: "green", values: []}
      }
    }

    {:ok, assign(socket, :tyre_wear_data, tyre_wear_data)}
  end

  def handle_info(%F1.CarStatusPacket{car_statuses: statuses}, socket) do
    status = elem(statuses, 0)
    {rl, rr, fl, fr} = status.tyres_wear
    tyre_wear_data = socket.assigns.tyre_wear_data
                |> ChartData.add_entry(:rear_left, rl)
                |> ChartData.add_entry(:rear_right, rr)
                |> ChartData.add_entry(:front_left, fl)
                |> ChartData.add_entry(:front_right, fr)
                |> ChartData.increment

    {:noreply, assign(socket, :tyre_wear_data, tyre_wear_data)}
  end
end
