defimpl Jason.Encoder, for: Tuple do
  def encode(data, options) when is_tuple(data) do
    data
    |> Tuple.to_list()
    |> Jason.Encoder.List.encode(options)
  end
end

defmodule Apex.RedisStreamSerialize do
  def to_redis_stream_map(packet) do
    %{
      type: Atom.to_string(packet.__struct__) |> String.trim_leading("Elixir."),
      data: Jason.encode!(packet)
    }
  end
end
