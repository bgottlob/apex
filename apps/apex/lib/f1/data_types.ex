defmodule F1.DataTypes do
  @moduledoc """
  Provides functions for parsing primitive data types out of binaries.
  """

  # Define macros for binary special forms that correspond to F1 data types
  # from https://forums.codemasters.com/topic/44592-f1-2019-udp-specification/
  %{
    float32: quote(do: little-float-size(32)),
    uint8: quote(do: little-unsigned-integer-size(8)),
    uint16: quote(do: little-unsigned-integer-size(16)),
    uint32: quote(do: little-unsigned-integer-size(32)),
    uint64: quote(do: little-unsigned-integer-size(64)),
    int8: quote(do: little-signed-integer-size(8)),
    int16: quote(do: little-signed-integer-size(16))
  } |> Enum.each(fn {type, qt} ->
    def unquote(:"#{type}")({map, data}, key) do
      <<x::unquote(qt), rest::binary>> = data
      {Map.put(map, key, x), rest}
    end

    def unquote(:"#{type}")({map, data}, key, num) do
      {tuple, data} = unquote(:"#{type}_tuple")(data, num, [])
      {Map.put(map, key, tuple), data}
    end

    defp unquote(:"#{type}_tuple")(data, 0, acc) do
      {Enum.reverse(acc) |> List.to_tuple, data}
    end
    defp unquote(:"#{type}_tuple")(data, num, acc) do
      <<x::unquote(qt), rest::binary>> = data
      unquote(:"#{type}_tuple")(rest, num - 1, [x | acc])
    end
  end)
end
