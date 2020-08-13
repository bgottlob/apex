defmodule PaceUpdate do
  @moduledoc """
  Struct representing a the pace measurement of a given driver during a session
  """
  defstruct [:session_uid, :car_index, :lap, :pace]

  def from_redis_stream_entry({_id, map}) do
    # Perform conversions from strings to proper data types
    struct(__MODULE__, map)
    |> Map.update!(:session_uid, &(String.to_integer(&1)))
    |> Map.update!(:car_index, &(String.to_integer(&1)))
    |> Map.update!(:lap, &(String.to_integer(&1)))
    |> Map.update!(:pace, &(String.to_float(&1)))
  end
end
