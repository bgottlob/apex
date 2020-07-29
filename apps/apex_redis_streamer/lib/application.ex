defmodule ApexRedisStreamer.Application do
  def start(_type, []) do
    conn = Apex.Node.connect(
      :apex_broadcast,
      System.get_env("APEX_BROADCAST_HOST")
    )

    case conn do
      true ->
        IO.puts "Connected to Apex Broadcast"
        :global.sync()
        {:ok, brink_stage} = Brink.Producer.start_link(
          redis_uri: System.get_env("APEX_REDIS_URI"),
          stream: "telemetry",
          maxlen: 5000
        )

        children = [%{
          id: ApexRedisStreamer,
          start: {ApexRedisStreamer, :start_link, [brink_stage]},
          restart: :permanent
        }]
        Supervisor.start_link(children, strategy: :one_for_one)
      _ ->
        {:error, "Unable to connect to Apex Broadcast, exiting"}
    end
  end
end
