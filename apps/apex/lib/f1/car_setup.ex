defmodule F1.CarSetupPacket do
  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :header,
    :car_setups
  ]

  def from_binary(data, header = %F1.PacketHeader{}) do
    {data_tuple, _} = F1.Parser.parse_tuple(data, F1.CarSetup, 20)
    %__MODULE__{header: header, car_setups: data_tuple}
  end
end

defmodule F1.CarSetup do
  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :front_wing,
    :rear_wing,
    :on_throttle,
    :off_throttle,
    :front_camber,
    :rear_camber,
    :front_toe,
    :rear_toe,
    :front_suspension,
    :rear_suspension,
    :front_anti_roll_bar,
    :rear_anti_roll_bar,
    :front_suspension_height,
    :rear_suspension_height,
    :brake_pressure,
    :brake_bias,
    :front_tyre_pressure,
    :rear_tyre_pressure,
    :ballast,
    :fuel_load
  ]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:front_wing)
    |> uint8(:rear_wing)
    |> uint8(:on_throttle)
    |> uint8(:off_throttle)
    |> float32(:front_camber)
    |> float32(:rear_camber)
    |> float32(:front_toe)
    |> float32(:rear_toe)
    |> uint8(:front_suspension)
    |> uint8(:rear_suspension)
    |> uint8(:front_anti_roll_bar)
    |> uint8(:rear_anti_roll_bar)
    |> uint8(:front_suspension_height)
    |> uint8(:rear_suspension_height)
    |> uint8(:brake_pressure)
    |> uint8(:brake_bias)
    |> float32(:front_tyre_pressure)
    |> float32(:rear_tyre_pressure)
    |> uint8(:ballast)
    |> float32(:fuel_load)
  end
end
