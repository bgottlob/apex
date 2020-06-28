defmodule F1.Parser do
  def parse(data) do
    {header, data} = F1.PacketHeader.from_binary(data)
    <<_::binary-size(3), data::binary>> = data

    case header.packet_id do
      6 -> elem(F1.CarTelemetryData.from_binary(data), 0)
      _ -> nil
    end
  end
end
