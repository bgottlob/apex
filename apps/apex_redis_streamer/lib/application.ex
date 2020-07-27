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
        ApexRedisStreamer.start_link(
          System.get_env("APEX_REDIS_URI"),
          "telemetry"
        )
      _ ->
        {:error, "Unable to connect to Apex Broadcast, exiting"}
    end
  end
end
