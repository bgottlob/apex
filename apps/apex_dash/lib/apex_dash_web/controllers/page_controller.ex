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
    RPM: <%= @rpm %>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(300, self(), :update)
    rpm = :rand.uniform(9000)
    {:ok, assign(socket, :rpm, rpm)}
  end

  def handle_info(:update, socket) do
    {:noreply, assign(socket, :rpm, :rand.uniform(9000))}
  end
end
