defmodule ApexNeo4jAdapter.BoltStreamer do
  @moduledoc """
  A GenStage consumer of Apex structs that creates data in Neo4j.
  """

  use GenStage

  def start_link(url) do
    {:ok, _neo} = Bolt.Sips.start_link(url: url)
    IO.puts "Connected to Bolt"
    conn = Bolt.Sips.conn()
    GenStage.start_link(__MODULE__, conn)
  end

  def init(conn) do
    {:consumer,
      conn,
      subscribe_to: [{:global.whereis_name(ApexBroadcast), [max_demand: 50]}]}
  end

  def handle_events(events, _from, conn) do
    events
    |> Stream.map(fn event -> create_event_query(event) end)
    |> Stream.reject(fn x -> x == nil end)
    |> Enum.each(fn query ->
      #IO.inspect(query)
      Bolt.Sips.query!(conn, query)
    end)
    {:noreply, [], conn}
  end

  defp create_event_query(%F1.SessionPacket{} = packet) do
    """
    MERGE (s:Session { session_uid: '#{packet.header.session_uid}' })
    ON MATCH SET s += {
      track_id: #{packet.track_id},
      weather: #{packet.weather}
    }
    """
  end

  defp create_event_query(%F1.CarTelemetryPacket{} = packet) do
    telemetry = elem(packet.car_telemetry_data, 0)
    """
    CREATE (ct:CarTelemetry {
      gear: #{telemetry.gear},
      engine_rpm: #{telemetry.engine_rpm},
      rev_lights_percent: #{telemetry.rev_lights_percent},
      speed: #{telemetry.speed}
    })
    MERGE (s:Session { session_uid: '#{packet.header.session_uid}' })
    CREATE (ct)-[:MEASURED_IN {
      session_time: #{packet.header.session_time}
    }]->(s)
    RETURN ct.session_time, s.session_uid
    """
  end
  defp create_event_query(_), do: nil
end
