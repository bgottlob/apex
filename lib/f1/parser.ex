defmodule F1.Parser do
  import F1.PacketHeader, only: [header_binary_size: 0]

  def parse(data) do
    <<header::header_binary_size,
      _::binary-size(3),
      data::binary>> = data

    header = F1.PacketHeader.from_binary(header)
    if header.packet_id == 6 do
      F1.CarTelemetryData.from_binary(data)
    end
  end
end
