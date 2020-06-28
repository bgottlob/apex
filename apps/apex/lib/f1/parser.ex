defmodule F1.Parser do
  def parse(data) do
    {header, data} = F1.PacketHeader.from_binary(data)

    case header.packet_id do
      2 -> elem(parse_tuple(data, F1.LapData, 20), 0)
      6 -> elem(parse_tuple(data, F1.CarTelemetryData, 20), 0)
      _ -> nil
    end
  end

  defp parse_tuple(data, module, num) do
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
