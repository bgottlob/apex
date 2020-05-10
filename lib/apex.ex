defmodule Apex do
  @moduledoc """
  Documentation for `Apex`.
  """

  @doc """
  Starts an Apex client
  """
  def start(_type, []) do
    {:ok, socket} = :gen_udp.open(20777, [:binary, active: false])
    listen(socket)
  end

  # For test purposes: read a single UDP packet from a file
  def start(_type, [pkt_file]) do
    {:ok, data} = File.read(pkt_file)
    parse(data)
    # Return something for mix run to succeed
    Task.start(fn -> :timer.sleep(1000) end)
  end

  def listen(socket) do
    {:ok, {_srcip, _srcport, data}} = :gen_udp.recv(socket, 0)
    parse(data)
    listen(socket)
  end

  def parse(data) do
    F1.Parser.parse(data)
  end
end


