defmodule ApexRedisStreamer do
  @moduledoc """
  A Flow that serializes Apex structs into Redis streams via a Brink stage.
  """

  use Flow

  def start_link(brink_stage) do
    Flow.from_stages([{:global, ApexBroadcast}])
    |> Flow.map(&(Apex.RedisStreamSerialize.to_redis_stream_map(&1)))
    |> Flow.into_stages([brink_stage])
  end
end
