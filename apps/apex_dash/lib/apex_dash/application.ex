defmodule ApexDash.Application do
  @moduledoc """
  A Phoenix application that displays live telemetry data from racing
  simulators.
  """

  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the endpoint when the application starts
      supervisor(ApexDashWeb.Endpoint, []),
      # Start your own worker by calling: ApexDash.Worker.start_link(arg1, arg2, arg3)
      # worker(ApexDash.Worker, [arg1, arg2, arg3]),
      {Phoenix.PubSub, [name: ApexDash.PubSub, adapter: Phoenix.PubSub.PG2]},
      # Start a registry that LiveView processes will register with for updates
      {Registry, keys: :duplicate, name: Registry.LiveDispatcher}
      # TODO: start PaceConsumer once it is based on spigot
      #{ApexDash.PaceConsumer, []}
    ]

    stages = [{ApexDash.LiveDispatcher, []}]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ApexDash.Supervisor]
    Supervisor.start_link(List.flatten(children, stages), opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ApexDashWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
