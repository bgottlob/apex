defmodule F1.PacketHeader do
  import F1.DataTypes

  defstruct [
    :packet_format,
    :game_major_version,
    :game_minor_version,
    :packet_version,
    :packet_id,
    :session_uid,
    :session_time,
    :frame_identifier,
    :player_car_index
  ]

  defmacro header_binary_size do
    quote do: binary-size(20)
  end

  def from_binary(data) do
    <<packet_format::uint16,
      game_major_version::uint8,
      game_minor_version::uint8,
      packet_version::uint8,
      packet_id::uint8,
      session_uid::uint64,
      session_time::float32,
      frame_identifier::uint8,
      player_car_index::uint8
    >> = data

    %F1.PacketHeader{
      packet_format: packet_format,
      game_major_version: game_major_version,
      game_minor_version: game_minor_version,
      packet_version: packet_version,
      packet_id: packet_id,
      session_uid: session_uid,
      session_time: session_time,
      frame_identifier: frame_identifier,
      player_car_index: player_car_index
    } |> IO.inspect
  end
end

