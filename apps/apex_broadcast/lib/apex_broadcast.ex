defmodule ApexBroadcast.Application do
  def start(_type, [udp_port]) do
    Apex.Broadcaster.start_link(udp_port, name: {:global, ApexBroadcast})
  end
end
