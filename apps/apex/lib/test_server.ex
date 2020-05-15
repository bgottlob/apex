defmodule Apex.TestServer do
  def start(_type, [from: file]) do
    IO.puts("Starting a test server reading from file `#{file}`")
    {:ok, socket} = :gen_udp.open(20778, [:binary, active: false])
    File.stream!(file, [:read], :line)
    |> Stream.map(fn line -> String.trim_trailing(line) end)
    |> Stream.map(fn hex_str -> Base.decode16!(hex_str) end)
    |> Enum.map(fn data -> 
      :gen_udp.send(socket, {127,0,0,1}, 20777, data)
      Process.sleep(10)
    end)
  end
end
