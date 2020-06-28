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
    }
  end

  defp tuple_for_redis_stream(map, key) do
    tuple = Map.get(map, key)
    map
    |> tuple_for_redis_stream(key, tuple, tuple_size(tuple), 0)
    |> Map.delete(key)
  end

  defp tuple_for_redis_stream(map, _key, _tuple, total, total), do: map
  defp tuple_for_redis_stream(map,  key,  tuple, total, curr) do
    Map.put(map, :"#{key}_#{curr + 1}", elem(tuple, curr))
    |> tuple_for_redis_stream(key, tuple, total, curr + 1)
  end

  def to_redis_stream_map(telemetry = %F1.CarTelemetryData{}) do
    Map.from_struct(telemetry)
    |> tuple_for_redis_stream(:brakes_temperature)
    |> tuple_for_redis_stream(:tyres_surface_temperature)
    |> tuple_for_redis_stream(:tyres_inner_temperature)
    |> tuple_for_redis_stream(:tyres_pressure)
    |> tuple_for_redis_stream(:surface_type)
    |> Map.put(:type, __MODULE__)
  end
end
