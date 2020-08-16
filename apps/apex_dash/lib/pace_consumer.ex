defmodule ApexDash.PaceConsumer do
  @moduledoc """
  Consumes Redis Stream entries from the pace stream and sends them to
  LiveView processes
  """
  use GenStage

  def start_link([]) do
    GenStage.start_link(__MODULE__, [])
  end

  def init([]) do
    {:consumer, nil, subscribe_to: [PaceBrinkConsumer]}
  end

  def handle_events(entries, _from, nil) do
    events = Enum.map(entries, &(PaceUpdate.from_redis_stream_entry(&1)))
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
      ApexDashWeb.RacePositionLive,
      fn reg_entries ->
        for {pid, _value} <- reg_entries do
          for e <- events, do: send(pid, e)
        end
      end
    )
    {:noreply, [], nil}
  end
end
