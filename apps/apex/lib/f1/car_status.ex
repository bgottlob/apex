defmodule F1.CarStatusPacket do
  defstruct [
    :header,
    :car_statuses
  ]

  def from_binary(data, header = %F1.PacketHeader{}) do
    {data_tuple, _} = F1.Parser.parse_tuple(data, F1.CarStatus, 20)
    %__MODULE__{header: header, car_statuses: data_tuple}
  end
end

defmodule F1.CarStatus do
  import F1.DataTypes

  defstruct [
    :traction_control,
    :anti_lock_brakes,
    :fuel_mix,
    :front_brake_bias,
    :pit_limiter_status,
    :fuel_in_tank,
    :fuel_capacity,
    :fuel_remaining_laps,
    :max_rpm,
    :idle_rpm,
    :max_gears,
    :drs_allowed,
    :tyres_wear,
    :actual_tyre_compound,
    :tyre_visual_compound,
    :tyres_damage,
    :front_left_wing_damage,
    :front_right_wing_damage,
    :rear_wing_damage,
    :engine_damage,
    :gear_box_damage,
    :vehicle_fia_flags,
    :ers_store_energy,
    :ers_deploy_mode,
    :ers_harvested_this_lap_mguk,
    :ers_harvested_this_lap_mguh,
    :ers_deployed_this_lap
  ]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> uint8(:traction_control)
    |> uint8(:anti_lock_brakes)
    |> uint8(:fuel_mix)
    |> uint8(:front_brake_bias)
    |> uint8(:pit_limiter_status)
    |> float32(:fuel_in_tank)
    |> float32(:fuel_capacity)
    |> float32(:fuel_remaining_laps)
    |> uint16(:max_rpm)
    |> uint16(:idle_rpm)
    |> uint8(:max_gears)
    |> uint8(:drs_allowed)
    |> uint8(:tyres_wear, 4)
    |> uint8(:actual_tyre_compound)
    |> uint8(:tyre_visual_compound)
    |> uint8(:tyres_damage, 4)
    |> uint8(:front_left_wing_damage)
    |> uint8(:front_right_wing_damage)
    |> uint8(:rear_wing_damage)
    |> uint8(:engine_damage)
    |> uint8(:gear_box_damage)
    |> int8(:vehicle_fia_flags)
    |> float32(:ers_store_energy)
    |> uint8(:ers_deploy_mode)
    |> float32(:ers_harvested_this_lap_mguk)
    |> float32(:ers_harvested_this_lap_mguh)
    |> float32(:ers_deployed_this_lap)
  end
end
