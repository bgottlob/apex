defmodule F1.LapData do
  import F1.DataTypes

  defstruct [
    :last_lap_time,
    :current_lap_time,
    :best_lap_time,
    :sector_1_time,
    :sector_2_time,
    :lap_distance,
    :total_distance
  ]

  def from_binary(data) do
    {%F1.LapData{}, data}
    |> float32(:last_lap_time)
    |> float32(:current_lap_time)
    |> float32(:best_lap_time)
    |> float32(:sector_1_time)
    |> float32(:sector_2_time)
    |> float32(:lap_distance)
    |> float32(:total_distance)
    |> float32(:safety_car_delta)
    |> uint8(:car_position)
    |> uint8(:current_lap_num)
    |> uint8(:pit_status)
    |> uint8(:sector)
    |> uint8(:current_lap_invalid)
    |> uint8(:penalties)
    |> uint8(:grid_position)
    |> uint8(:driver_status)
    |> uint8(:result_status)
  end
end
