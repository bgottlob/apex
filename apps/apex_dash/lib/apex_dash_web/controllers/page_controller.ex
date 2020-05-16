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
    Gear: <%= @gear %>
    <br>
    RPM: <%= @rpm %> rpm
    <br>
    Speed: <%= @speed %> km/h
    """
  end

  def mount(_params, _session, socket) do
    [{apex_client, nil}] = Registry.lookup(Registry.Apex, "apex_client")
    Apex.Client.subscribe(apex_client)
    {:ok,
      socket
      |> assign(:rpm, "Loading...")
      |> assign(:speed, "Loading...")
      |> assign(:gear, "Loading...")
    }
  end

  def handle_info(:update, socket) do
    {:noreply, assign(socket, :rpm, :rand.uniform(9000))}
  end

  def handle_info({:update, telemetry}, socket) do
    {:noreply,
      socket
      |> assign(:rpm, telemetry.engine_rpm)
      |> assign(:speed, telemetry.speed)
      |> assign(:gear, telemetry.gear)
    }
  end
end
