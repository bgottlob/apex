defmodule ApexDash.Application do
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
      {Registry, keys: :duplicate, name: Registry.LiveDispatcher},
      {Brink.Consumer, [
        redis_uri: System.get_env("APEX_REDIS_URI"),
        stream: "pace",
        name: PaceBrinkConsumer,
        initial_block_timeout: 500
      ]},
      {ApexDash.PaceConsumer, []}
    ]

    conn = Apex.Node.connect(
      :apex_broadcast,
      System.get_env("APEX_BROADCAST_HOST")
    )

    stages = case conn do
      true ->
        IO.puts "Connected to distributed Apex Broadcast node"
        :global.sync()
        [{ApexDash.LiveDispatcher, []}]
      _ ->
        IO.puts "Unable to connect to Apex Broadcast node"
        [%{id: Apex.Broadcaster, start: {Apex.Broadcaster, :start_link, [20777, [name: {:global, ApexBroadcast}]]}},
          {ApexDash.LiveDispatcher, []}]
    end

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
