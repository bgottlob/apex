defmodule Apex.Client do
  def start(port) do
    Task.start(fn ->
      Apex.Client.UDPListener.start(port)
      Registry.start_link(keys: :unique, name: Registry.Apex)
      Registry.register(Registry.Apex, "apex_client", nil)
      Apex.Client.loop([])
    end)
  end

  def loop(subscribers) do
    receive do
      {:subscribe, pid} -> loop([pid | subscribers])
      {:udp_data, data} ->
        case F1.Parser.parse(data) do
          telemetry = %F1.CarTelemetryData{} ->
            for s <- subscribers, do: send s, {:update, telemetry}
          _ -> nil
        end
        loop(subscribers)
      _ -> loop(subscribers)
    end
  end

  def subscribe(client_pid) do
    send client_pid, {:subscribe, self()}
  end
end

defmodule Apex.Client.UDPListener do
  def start(port) do
    {:ok, socket} = :gen_udp.open(port, [:binary, active: false])
    Task.start(Apex.Client.UDPListener, :listen, [socket, self()])
  end

  def listen(socket, data_callback) do
    {:ok, {_srcip, _srcport, data}} = :gen_udp.recv(socket, 0)
    send data_callback, {:udp_data, data}
    listen(socket, data_callback)
  end
end
