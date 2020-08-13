defmodule ApexDashWeb.Router do
  use ApexDashWeb, :router
  import Phoenix.LiveView.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ApexDashWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    live "/live", RootLive
    post "/switchCar", PageController, :switch_car
  end

  # Other scopes may use custom stacks.
  # scope "/api", ApexDashWeb do
  #   pipe_through :api
  # end
end
