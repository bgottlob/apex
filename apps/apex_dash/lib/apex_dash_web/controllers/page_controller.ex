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
    {:ok, _sub} = ApexDashWeb.Subscriber.start_link(self())
    {:ok,
      socket
      |> assign(:rpm, "Loading...")
      |> assign(:speed, "Loading...")
      |> assign(:gear, "Loading...")
    }
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

defmodule ApexDashWeb.Subscriber do
  use GenStage

  # Takes a pid of the LiveView process to send events to
  def start_link(callback) do
    GenStage.start_link(__MODULE__, callback)
  end

  def init(callback) do
    {:consumer,
      callback,
      subscribe_to: [{Apex.Broadcaster, [max_demand: 5]}]}
  end

  def handle_events(events, _from, callback) do
    :ok = send_events(events, callback)
    {:noreply, [], callback}
  end

  defp send_events([], _), do: :ok
  defp send_events([event|rest], to) do
    send(to, {:update, event})
    send_events(rest, to)
  end
end
