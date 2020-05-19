defmodule ApexShiftBulb do
  @moduledoc """
  Documentation for `ApexShiftBulb`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> ApexShiftBulb.hello()
      :world

  """
  def start(_type, []) do
    pid = spawn(fn -> bulb_loop(false) end)
    Apex.Subscriber.start_link(pid)
  end

  defp bulb_loop(alert_on) do
    receive do
      {:update, telemetry} ->
        payload = case telemetry.rev_lights_percent do
          100 when alert_on != true -> %{alert: "select", on: true, bri: 50}
          x when x < 100 and alert_on == true -> %{alert: "none", on: true, bri: 50}
          _ -> %{}
        end
        unless payload == %{}, do: set_light_state(payload)
        bulb_loop(payload[:alert] == "select")

      _ ->
        bulb_loop(alert_on)
    end
  end

  defp set_light_state(payload_map) do
    username = Application.fetch_env!(:apex_shift_bulb, :username)
    light_num = Application.fetch_env!(:apex_shift_bulb, :light_number)

    {:ok, conn} = Mint.HTTP.connect(:http,
      Application.fetch_env!(:apex_shift_bulb, :bridge_address),
      80,
      mode: :passive
    )

    {:ok, conn, _} = Mint.HTTP.request(
      conn,
      "PUT",
      "/api/#{username}/lights/#{light_num}/state",
      [{"Content-Type", "application/json"}],
      Jason.encode!(payload_map)
    )

    {:ok, _, _} = Mint.HTTP.recv(conn, 0, 5000)
    Mint.HTTP.close(conn)
  end
end
