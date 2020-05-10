defmodule F1.CarTelemetryData do
  import F1.DataTypes

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
    <<speed::uint16,
      throttle::float32,
      steer::float32,
      brake::float32,
      clutch::uint8,
      gear::int8,
      engine_rpm::uint16,
      drs::uint8,
      rev_lights_percent::uint8,
      brakes_temperature::uint16(4),
      tyres_surface_temperature::uint16(4),
      tyres_inner_temperature::uint16(4),
      engine_temperature::uint16,
      tyres_pressure::float32(4),
      surface_type::uint8(4),
      _rest::binary>> = data

    %F1.CarTelemetryData{
      speed: speed,
      throttle: throttle,
      steer: steer,
      brake: brake,
      clutch: clutch,
      gear: gear,
      engine_rpm: engine_rpm,
      drs: drs,
      rev_lights_percent: rev_lights_percent,
      brakes_temperature: uint16_tuple(brakes_temperature, 4),
      tyres_surface_temperature: uint16_tuple(tyres_surface_temperature, 4),
      tyres_inner_temperature: uint16_tuple(tyres_inner_temperature, 4),
      engine_temperature: engine_temperature,
      tyres_pressure: float32_tuple(tyres_pressure, 4),
      surface_type: uint8_tuple(surface_type, 4)
    } |> IO.inspect
  end
end
