defmodule Apex.Broadcaster do
  use GenStage

  # Specify UDP port to listen for data on
  def start_link(port) do
    IO.puts "Starting Apex Broadcaster listening on UDP port #{port}"
    GenStage.start_link(__MODULE__, port, name: __MODULE__)
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

defmodule Apex.Subscriber do
  use GenStage

  # Takes a pid of the LiveView process to send events to
  def start_link(callback) do
    GenStage.start_link(__MODULE__, callback)
  end

  def init(callback) do
    {:consumer,
      callback,
      subscribe_to: [{Apex.Broadcaster, [max_demand: 5]}]}
  end

  def handle_events(events, _from, callback) do
    :ok = send_events(events, callback)
    {:noreply, [], callback}
  end

  defp send_events([], _), do: :ok
  defp send_events([event|rest], to) do
    send(to, {:update, event})
    send_events(rest, to)
  end
end
