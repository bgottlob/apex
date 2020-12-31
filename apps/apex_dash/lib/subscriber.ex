defmodule ApexDash.LiveDispatcher do
  @moduledoc """
  A GenStage consumer that subscribes to a globally-registered Apex.Broadcaster
  GenStage producer and dispatches Apex structs to LiveView processes.
  """
  use GenStage

  def start_link([]) do
    GenStage.start_link(__MODULE__, [])
  end

  def init([]) do
    :global.sync()
    case :global.whereis_name(ApexBroadcast) do
      :undefined ->
        {:stop, "Global process ApexBroadcast not found"}
      pid ->
        IO.puts "Starting Apex.LiveDispatcher"
        {:consumer, nil, subscribe_to: [{pid, max_demand: 5}]}
    end
  end

  defp dispatch_dashboard(events) do
    Registry.dispatch(
      Registry.LiveDispatcher,
      ApexDashWeb.DashboardLive,
      fn reg_entries ->
        for {pid, _value} <- reg_entries do
        for e <- events, do: send(pid, e)
      end
      end
    )
  end

  defp dispatch_tyre_wear(events) do
    # Send TyreWearChart processes only car status packets with tyre wear
    # data
    Registry.dispatch(
      Registry.LiveDispatcher,
      ApexDashWeb.TyreWearChart,
      fn reg_entries ->
        for {pid, _value} <- reg_entries do
          for e <- events do 
            case e do
              x = %F1.CarStatusPacket{} -> send(pid, x)
              _ -> nil # noop
            end
          end
        end
      end
    )
  end

  defp dispatch_race_position(events) do
    # Send the position tracker only lap data packets, which contain the race
    # position of each car
    Registry.dispatch(
      Registry.LiveDispatcher,
      ApexDashWeb.RacePositionLive,
      fn reg_entries ->
        for {pid, _value} <- reg_entries do
          for e <- events do 
            case e do 
              x = %F1.LapDataPacket{} -> send(pid, x)
              _ -> nil # noop
            end
          end
        end
      end
    )
  end

  def handle_events(events, _from, nil) do
    dispatch_dashboard(events)
    dispatch_tyre_wear(events)
    dispatch_race_position(events)
    {:noreply, [], nil}
  end
end
