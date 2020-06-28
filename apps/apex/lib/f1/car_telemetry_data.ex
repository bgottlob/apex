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
    {%F1.CarTelemetryData{}, data}
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
