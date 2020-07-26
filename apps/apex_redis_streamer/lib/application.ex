defmodule ApexRedisStreamer.Application do
  def start(_type, []) do
    uri = Application.fetch_env!(:apex_redis_streamer, :redis_uri)
    case Apex.Environment.connect_to_broadcast do
      true ->
        IO.puts "Connected to Apex Broadcast"
        :global.sync()
        ApexRedisStreamer.start_link(uri, "telemetry")
      _ ->
        {:error, "Unable to connect to Apex Broadcast, exiting"}
    end
  end
end
