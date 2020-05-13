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

  def start(_type, [capture: file]) do
    {:ok, socket} = :gen_udp.open(20777, [:binary, active: false])
    listen(socket, capture: file)
  end

  def start(_type, [read: file]) do
    {:ok, socket} = :gen_udp.open(20777, [:binary, active: false])
    Task.start(fn -> 
      Process.sleep(2000)
      Apex.TestServer.start(nil, [from: file])
    end)
    listen(socket, capture: file)
  end

  def listen(socket, opts \\ []) do
    {:ok, {_srcip, _srcport, data}} = :gen_udp.recv(socket, 0)
    if opts[:capture] do
      File.write(opts[:capture], "#{Base.encode16(data)}\n", [:append])
    end
    parse(data)
    listen(socket, opts)
  end

  def parse(data) do
    F1.Parser.parse(data)
  end
end


