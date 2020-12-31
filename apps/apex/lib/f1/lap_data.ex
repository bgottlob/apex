defmodule F1.LapDataPacket do
  @moduledoc """
  A struct representing current lap data for all cars on track.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :header,
    :lap_data
  ]

  def from_binary(data, %F1.PacketHeader{} = header) do
    {data_tuple, _} = F1.Parser.parse_tuple(data, F1.LapData, 20)
    %__MODULE__{header: header, lap_data: data_tuple}
  end
end

defmodule F1.LapData do
  @moduledoc """
  A struct representing current lap data single car.
  """

  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :last_lap_time,
    :current_lap_time,
    :best_lap_time,
    :sector_1_time,
    :sector_2_time,
    :lap_distance,
    :total_distance,
    :safety_car_delta,
    :car_position,
    :current_lap_num,
    :pit_status,
    :sector,
    :current_lap_invalid,
    :penalties,
    :grid_position,
    :driver_status,
    :result_status
  ]

  def from_binary(data) do
    {%__MODULE__{}, data}
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
