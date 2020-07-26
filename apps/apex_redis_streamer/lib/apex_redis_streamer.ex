defmodule ApexRedisStreamer do
  use GenStage

  def start_link(uri, stream) do
    IO.puts "Connecting to #{uri}"
    {:ok, stage} = Brink.Producer.start_link(redis_uri: uri, stream: stream)
    GenStage.start_link(__MODULE__, stage)
  end

  def init(stage) do
    {:consumer,
      stage,
      subscribe_to: [{:global.whereis_name(ApexBroadcast), [max_demand: 5]}]}
  end

  def handle_events(events, _from, stage) do
    Flow.from_enumerable(events)
    |> Flow.map(&(Apex.RedisStreamSerialize.to_redis_stream_map(&1)))
    |> Flow.into_stages([stage])

    {:noreply, [], stage}
  end
end
