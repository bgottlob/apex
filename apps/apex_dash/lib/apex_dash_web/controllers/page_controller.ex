defmodule ApexDashWeb.PageController do
  use ApexDashWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
