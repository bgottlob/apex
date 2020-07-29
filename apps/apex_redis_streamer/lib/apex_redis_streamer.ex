defmodule ApexRedisStreamer do
  use GenStage

  def start_link(uri, stream) do
    IO.puts "Connecting to #{uri}"
    {:ok, stage} = Brink.Producer.start_link(redis_uri: uri, stream: stream, maxlen: 5000)
    GenStage.start_link(__MODULE__, stage)
  end

  def init(stage) do
    case :global.whereis_name(ApexBroadcast) do
      :undefined ->
        {:stop, "Unable to find ApexBroadcast producer process"}
      pid ->
        {:consumer, stage, subscribe_to: [{pid, [max_demand: 5]}]}
    end
  end

  def handle_events(events, _from, stage) do
    Flow.from_enumerable(events)
    |> Flow.map(&(Apex.RedisStreamSerialize.to_redis_stream_map(&1)))
    |> Flow.into_stages([stage])

    {:noreply, [], stage}
  end
end
