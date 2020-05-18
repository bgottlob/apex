defmodule Apex.Broadcaster do
  use GenStage

  # Specify UDP port to listen for data on
  def start_link(port) do
    GenStage.start_link(__MODULE__, port, name: __MODULE__)
  end

  def init(port) do
    {:ok, _socket} = :gen_udp.open(port, [:binary, active: true])
    {:producer, :ok, dispatcher: GenStage.BroadcastDispatcher}
  end

  def handle_info({:udp, _socket, _ip, _inport, data}, state) do
    case F1.Parser.parse(data) do
      telemetry = %F1.CarTelemetryData{} -> {:noreply, [telemetry], state}
      _ -> {:noreply, [], state}
    end
  end

  def handle_demand(_demand, state) do
    {:noreply, [], state}
  end
end
