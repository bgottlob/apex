defmodule F1.CarMotionPacket do
  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :header,
    :car_motion_data,
    # All below data is for the player's car only
    :suspension_position,
    :suspension_velocity,
    :suspension_acceleration,
    :wheel_speed,
    :wheel_slip,
    :local_velocity_x,
    :local_velocity_y,
    :local_velocity_z,
    :angular_velocity_x,
    :angular_velocity_y,
    :angular_velocity_z,
    :angular_acceleration_x,
    :angular_acceleration_y,
    :angular_acceleration_z,
    :front_wheels_angle
  ]

  def from_binary(data, header = %F1.PacketHeader{}) do
    {data_tuple, data} = F1.Parser.parse_tuple(data, F1.CarMotion, 20)

    {%__MODULE__{header: header, car_motion_data: data_tuple}, data}
    |> float32(:suspension_position, 4)
    |> float32(:suspension_velocity, 4)
    |> float32(:suspension_acceleration, 4)
    |> float32(:wheel_speed, 4)
    |> float32(:wheel_slip, 4)
    |> float32(:local_velocity_x)
    |> float32(:local_velocity_y)
    |> float32(:local_velocity_z)
    |> float32(:angular_velocity_x)
    |> float32(:angular_velocity_y)
    |> float32(:angular_velocity_z)
    |> float32(:angular_acceleration_x)
    |> float32(:angular_acceleration_y)
    |> float32(:angular_acceleration_z)
    |> float32(:front_wheels_angle)
    |> elem(0)
  end
end

defmodule F1.CarMotion do
  import F1.DataTypes

  @derive Jason.Encoder
  defstruct [
    :world_position_x,
    :world_position_y,
    :world_position_z,
    :world_velocity_x,
    :world_velocity_y,
    :world_velocity_z,
    :world_forward_dir_x,
    :world_forward_dir_y,
    :world_forward_dir_z,
    :world_right_dir_x,
    :world_right_dir_y,
    :world_right_dir_z,
    :g_force_lateral,
    :g_force_longitudinal,
    :g_force_vertical,
    :yaw,
    :pitch,
    :roll
  ]

  def from_binary(data) do
    {%__MODULE__{}, data}
    |> float32(:world_position_x)
    |> float32(:world_position_y)
    |> float32(:world_position_z)
    |> float32(:world_velocity_x)
    |> float32(:world_velocity_y)
    |> float32(:world_velocity_z)
    |> int16(:world_forward_dir_x)
    |> int16(:world_forward_dir_y)
    |> int16(:world_forward_dir_z)
    |> int16(:world_right_dir_x)
    |> int16(:world_right_dir_y)
    |> int16(:world_right_dir_z)
    |> float32(:g_force_lateral)
    |> float32(:g_force_longitudinal)
    |> float32(:g_force_vertical)
    |> float32(:yaw)
    |> float32(:pitch)
    |> float32(:roll)
  end
end
