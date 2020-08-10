defmodule ApexRedisStreamer.LapDataStreamer do
  @moduledoc """
  Streams lap data for individual cars
  """

  def start_link(brink_stage) do
    Flow.from_stages([{:global, ApexBroadcast}])
    |> Flow.filter(fn %F1.LapDataPacket{} -> true
                      _ -> false
                   end)
    |> Flow.flat_map(&map_packet/1)
    |> Flow.into_stages([brink_stage])
  end

  # Serialize into a list of maps, one for each car in the lap data packet
  defp map_packet(packet) do
    Tuple.to_list(packet.lap_data)
    |> Stream.with_index(0)
    |> Stream.map(fn {lap_data = %F1.LapData{}, idx} ->
      %{
        session_uid: packet.header.session_uid,
        car_index: idx,
        current_lap_num: lap_data.current_lap_num,
        last_lap_time: lap_data.last_lap_time
      } |> IO.inspect
    end)
  end
end
