defmodule PaceUpdate do
  defstruct [:value]

  def from_redis_stream_entry({_id, map}) do
    struct(__MODULE__, Map.update!(map, :value, &(String.to_float(&1))))
  end
end
