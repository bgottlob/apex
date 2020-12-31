defmodule Apex.Mock.UDPServer do
  @moduledoc """
  A UDP server that pushes binary data to a destination host and port; intended
  for test purposes.
  """

  def start(sport, daddr, dport, file) do
    IO.puts(
      """
      Starting a test server streaming file `#{file}`:
      \tSource port: #{sport}
      \tDestination: #{daddr}:#{dport}
      """
    )

    daddr = Regex.run(~r/^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/, daddr)
            |> tl()
            |> Enum.map(&(String.to_integer(&1)))
            |> List.to_tuple()

    IO.puts "Opening UDP socket on port #{sport}"
    {:ok, socket} = :gen_udp.open(sport, [:binary, active: false])
    File.stream!(file, [:read], :line)
    |> Stream.map(fn line -> String.trim_trailing(line) end)
    |> Stream.map(fn hex_str -> Base.decode16!(hex_str) end)
    |> Enum.map(fn data -> 
      :gen_udp.send(socket, daddr, dport, data)
      Process.sleep(10)
    end)
  end
end
