defmodule Apex do
  def start(_type, [port]) do
    Apex.Broadcaster.start_link(port)
  end
end
