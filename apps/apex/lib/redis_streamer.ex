# A GenStage subscriber that serializes data and pushes it to a Redis stream
defmodule Apex.RedisStreamer do
  use GenStage

  def start_link() do
    IO.puts "Connecting to #{Application.fetch_env!(:apex, :redis_uri)}"
    {:ok, stage} = Brink.Producer.start_link(
      redis_uri: Application.fetch_env!(:apex, :redis_uri),
      stream: "telemetry",
      maxlen: 20_000
    )
    GenStage.start_link(__MODULE__, stage)
  end

  def init(stage) do
    {:consumer, stage, subscribe_to: [{Apex.Broadcaster, [max_demand: 5]}]}
  end

  def handle_events(events, _from, stage) do
    Flow.from_enumerable(events)
    |> Flow.map(&(F1.CarTelemetryData.to_redis_stream_map(&1)))
    |> Flow.into_stages([stage])

    {:noreply, [], stage}
  end
end