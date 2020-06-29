defmodule F1.Parser do
  def parse(data) do
    {header, data} = F1.PacketHeader.from_binary(data)

    case header.packet_id do
      2 -> F1.PacketLapData.from_binary(data, header)
      6 -> F1.PacketCarTelemetryData.from_binary(data, header)
      _ -> nil
    end
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
