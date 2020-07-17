defmodule ApexDashWeb.PageController do
  use ApexDashWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

defmodule ApexDashWeb.DashboardLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~L"""
    <h1>Gear: <%= @gear %></h1>
    <br>
    <h2>Speed: <%= @speed %> km/h</h2>
    <br>
    <h2>RPM: <%= @rpm %> rpm</h2>
    <br>
    <h3><%= @rev_lights_percent %> %</h3>
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

    {:ok,
      socket
      |> assign(:rpm, "Loading...")
      |> assign(:speed, "Loading...")
      |> assign(:gear, "Loading...")
      |> assign(:rev_lights_percent, "Loading...")
    }
  end

  def handle_info(%F1.CarTelemetryPacket{car_telemetry_data: telemetry}, socket) do
    telemetry = elem(telemetry, 0)
    {:noreply,
      socket
      |> assign(:rpm, telemetry.engine_rpm)
      |> assign(:speed, telemetry.speed)
      |> assign(:gear, telemetry.gear)
      |> assign(:rev_lights_percent, telemetry.rev_lights_percent)
    }
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
