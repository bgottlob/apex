defmodule F1.DataTypes do
  # Define macros for binary special forms that correspond to F1 data types
  # from https://forums.codemasters.com/topic/44592-f1-2019-udp-specification/
  defmacro uint(bit_size) do
    quote do: little-unsigned-integer-size(unquote(bit_size))
  end

  defmacro int(bit_size) do
    quote do: little-integer-size(unquote(bit_size))
  end

  # Named float32 instead of float to prevent conflict with Elixir's float
  # special form
  defmacro float32 do
    quote do: little-float-size(32)
  end

  defmacro uint8 do
    quote do: uint(8)
  end

  defmacro uint16 do
    quote do: uint(16)
  end

  defmacro uint64 do
    quote do: uint(64)
  end

  defmacro int8 do
    quote do: int(8)
  end

  defmacro int16 do
    quote do: int(16)
  end

  defmacro float32(num) do
    quote do: binary-size(unquote(4 * num))
  end

  defmacro uint8(num) do
    quote do: binary-size(unquote(num))
  end

  defmacro uint16(num) do
    quote do: binary-size(unquote(2 * num))
  end

  def float32_tuple(data, num), do: float32_tuple(data, num, [])

  # Enforces that no data can be remaining
  defp float32_tuple(<<>>, 0, acc) do
    acc
    |> Enum.reverse
    |> List.to_tuple
  end

  defp float32_tuple(data, num, acc) do
    <<x::float32, rest::binary>> = data
    float32_tuple(rest, num - 1, [x|acc])
  end

  def uint8_tuple(data, num) do
    uint8_tuple(data, num, [])
  end

  defp uint8_tuple(<<>>, 0, acc) do
    acc
    |> Enum.reverse
    |> List.to_tuple
  end

  defp uint8_tuple(data, num, acc) do
    <<x::uint8, rest::binary>> = data
    uint8_tuple(rest, num - 1, [x|acc])
  end

  def uint16_tuple(data, num) do
    uint16_tuple(data, num, [])
  end

  defp uint16_tuple(<<>>, 0, acc) do
    acc
    |> Enum.reverse
    |> List.to_tuple
  end

  defp uint16_tuple(data, num, acc) do
    <<x::uint16, rest::binary>> = data
    uint16_tuple(rest, num - 1, [x|acc])
  end
end
