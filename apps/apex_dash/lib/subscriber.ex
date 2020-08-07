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

  def handle_events(events, _from, nil) do
    Registry.dispatch(
      Registry.LiveDispatcher,
      ApexDashWeb.DashboardLive,
      fn reg_entries ->
        for {pid, _value} <- reg_entries do
          for e <- events, do: send(pid, e)
        end
      end
    )

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
    {:noreply, [], nil}
  end
end
