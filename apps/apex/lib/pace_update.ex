defmodule PaceUpdate do
  @moduledoc """
  Struct representing a the pace measurement of a given driver during a session
  """
  defstruct [:session_uid, :car_index, :lap, :pace]
end
