defmodule ApexRedisStreamer.Application do
  @moduledoc """
  Application that consumes data from an Apex Broadcast process then serializes
  and streams the data to Redis streams.
  """

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
          maxlen: 5000,
          name: Brink.Producer.Telemetry
        )

        {:ok, brink_stage_lap} = Brink.Producer.start_link(
          redis_uri: System.get_env("APEX_REDIS_URI"),
          stream: "laps",
          maxlen: 5000,
          name: Brink.Producer.Laps
        )

        children = [
          %{id: ApexRedisStreamer,
            start: {ApexRedisStreamer, :start_link, [brink_stage]},
            restart: :permanent},
          %{id: ApexRedisStreamer.LapDataStreamer,
            start: {ApexRedisStreamer.LapDataStreamer,
                    :start_link,
                    [brink_stage_lap]}}
        ]
        Supervisor.start_link(children, strategy: :one_for_one)
      _ ->
        {:error, "Unable to connect to Apex Broadcast, exiting"}
    end
  end
end
