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
    """
  end

  def mount(_params, _session, socket) do
    {:ok, _sub} = Apex.Subscriber.start_link(self())
    {:ok,
      socket
      |> assign(:rpm, "Loading...")
      |> assign(:speed, "Loading...")
      |> assign(:gear, "Loading...")
    }
  end

  def handle_info({:update, %F1.CarTelemetryPacket{car_telemetry_data: telemetry}}, socket) do
    telemetry = elem(telemetry, 0)
    {:noreply,
      socket
      |> assign(:rpm, telemetry.engine_rpm)
      |> assign(:speed, telemetry.speed)
      |> assign(:gear, telemetry.gear)
    }
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end
end
