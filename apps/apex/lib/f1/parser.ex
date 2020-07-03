defmodule F1.Parser do
  def parse(data) do
    {header, data} = F1.PacketHeader.from_binary(data)

    packet_type = case header.packet_id do
      0 -> F1.PacketCarMotion
      1 -> F1.PacketSession
      2 -> F1.PacketLapData
      3 -> F1.EventPacket
      4 -> F1.ParticipantPacket
      5 -> F1.CarSetupPacket
      6 -> F1.PacketCarTelemetryData
      7 -> F1.CarStatusPacket
    end

    packet_type.from_binary(data, header)
  end

  def parse_tuple(data, module, num) do
    parse_tuple(data, module, num, [])
  end

  defp parse_tuple(data, _module, 0, acc) do
    {Enum.reverse(acc) |> List.to_tuple, data}
  end

  defp parse_tuple(data, module, total, acc) do
    {struct, rest} = module.from_binary(data)
    parse_tuple(rest, module, total - 1, [struct | acc])
  end
end
