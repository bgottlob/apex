defmodule F1.CarTelemetryPacket do
  @moduledoc """
  A struct representing instantaneous telemetry data for all cars on track.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :header,
    :car_telemetry_data,
    :button_status
  ]

  def from_binary(data, %F1.PacketHeader{} = header) do
    {data_tuple, data} = F1.Parser.parse_tuple(data, F1.CarTelemetry, 20)

    {%__MODULE__{header: header, car_telemetry_data: data_tuple}, data}
    |> uint32(:button_status)
    |> elem(0)
  end
end

defmodule F1.CarTelemetry do
  @moduledoc """
  A struct representing instantaneous telemetry data for a single car.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :speed,
    :throttle,
    :steer,
    :brake,
    :clutch,
    :gear,
    :engine_rpm,
    :drs,
    :rev_lights_percent,
    :brakes_temperature,
    :tyres_surface_temperature,
    :tyres_inner_temperature,
    :engine_temperature,
    :tyres_pressure,
    :surface_type
  ]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint16(:speed)
    |> float32(:throttle)
    |> float32(:steer)
    |> float32(:brake)
    |> uint8(:clutch)
    |> int8(:gear)
    |> uint16(:engine_rpm)
    |> uint8(:drs)
    |> uint8(:rev_lights_percent)
    |> uint16(:brakes_temperature, 4)
    |> uint16(:tyres_surface_temperature, 4)
    |> uint16(:tyres_inner_temperature, 4)
    |> uint16(:engine_temperature)
    |> float32(:tyres_pressure, 4)
    |> uint8(:surface_type, 4)
  end
end
