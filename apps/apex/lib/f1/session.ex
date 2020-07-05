defmodule F1.SessionPacket do
  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :header,
    :weather,
    :track_temperature,
    :air_temperature,
    :total_laps,
    :track_length,
    :session_type,
    :track_id,
    :formula,
    :session_time_left,
    :session_duration,
    :pit_speed_limit,
    :game_paused,
    :is_spectating,
    :spectator_car_index,
    :sli_pro_native_support,
    :num_marshal_zones,
    :marshal_zones,
    :safety_car_status,
    :network_game
  ]

  def from_binary(data, header = %F1.PacketHeader{}) do
    {struct, data} = {%__MODULE__{header: header}, data}
                     |> uint8(:weather)
                     |> int8(:track_temperature)
                     |> int8(:air_temperature)
                     |> uint8(:total_laps)
                     |> uint16(:track_length)
                     |> uint8(:session_type)
                     |> int8(:track_id)
                     |> uint8(:formula)
                     |> uint16(:session_time_left)
                     |> uint16(:session_duration)
                     |> uint8(:pit_speed_limit)
                     |> uint8(:game_paused)
                     |> uint8(:is_spectating)
                     |> uint8(:spectator_car_index)
                     |> uint8(:sli_pro_native_support)
                     |> uint8(:num_marshal_zones)
    

    {zones, data} = F1.Parser.parse_tuple(data, F1.MarshalZone, 21)

    {%{struct | marshal_zones: zones}, data}
    |> uint8(:safety_car_status)
    |> uint8(:network_game)
    |> elem(0)
  end
end

defmodule F1.MarshalZone do
  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :zone_start,
    :zone_flag
  ]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> float32(:zone_start)
    |> int8(:zone_flag)
  end
end
