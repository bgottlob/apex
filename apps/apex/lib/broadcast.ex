defmodule Apex.Broadcaster do
  use GenStage

  # Specify UDP port to listen for data on
  # options are GenServer options:
  #   https://hexdocs.pm/elixir/GenServer.html#t:options/0
  def start_link(port, options \\ []) do
    IO.puts "Starting Apex.Broadcaster GenStage producer:\n\tListening on UDP port #{port}"
    GenStage.start_link(__MODULE__, port, options)
  end

  def init(port) do
    {:ok, _socket} = :gen_udp.open(port, [:binary, active: true])
    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_info({:udp, _socket, _ip, _inport, data}, state) do
    {:noreply, [F1.Parser.parse(data)], state}
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
