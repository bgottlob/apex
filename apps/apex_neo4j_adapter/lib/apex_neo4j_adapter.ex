defmodule ApexNeo4jAdapter do
  def start(_type, [host, port]) do
    ApexNeo4jAdapter.BoltStreamer.start_link("bolt://#{host}:#{port}")
  end
end
