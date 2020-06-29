defmodule F1.PacketHeader do
  import F1.DataTypes

  @derive Jason.Encoder
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

  def from_binary(data) do
    {%F1.PacketHeader{}, data}
    |> uint16(:packet_format)
    |> uint8(:game_major_version)
    |> uint8(:game_minor_version)
    |> uint8(:packet_version)
    |> uint8(:packet_id)
    |> uint64(:session_uid)
    |> float32(:session_time)
    |> uint32(:frame_identifier)
    |> uint8(:player_car_index)
  end
end

