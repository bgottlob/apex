defmodule Apex.Mock.UDPCapture do
  @moduledoc """
  A UDP listener that stores each packet received in a file as Base16-encoded
  text.
  """

  def start(dport, file) do
    IO.puts "Listening on UDP port #{dport} for packets to capture in file #{file}"
    {:ok, socket} = :gen_udp.open(dport, [:binary, active: true])
    File.touch!(file)
    listen(socket, file, output(0))
  end

  defp listen(socket, file, pkts) do
    receive do
      {:udp, ^socket, _ip, _inport, data} ->
        File.write!(file, "#{Base.encode16(data)}\n", [:append])
        listen(socket, file, output(pkts + 1))
      _ -> listen(socket, file, pkts)
    end
  end

  defp output(pkts) do
    IO.write "Wrote #{pkts} packets\r"
    pkts
  end
end
