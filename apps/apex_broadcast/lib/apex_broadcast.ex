defmodule ApexBroadcast.Application do
  @moduledoc """
  An application that receives racing simulator data via a UDP port, serializes
  it into structs and broadcasts it using a GenStage producer.
  """
  def start(_type, [udp_port]) do
    Apex.Broadcaster.start_link(udp_port, name: {:global, ApexBroadcast})
  end
end
