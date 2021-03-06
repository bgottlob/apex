defmodule ApexNeo4jAdapter.Application do
  @moduledoc """
  An application that consumes data from an Apex Broadcast process then
  serializes it and streams it to a Neo4j database.
  """

  def start(_type, _args) do
    conn = Apex.Node.connect(
      :apex_broadcast,
      System.get_env("APEX_BROADCAST_HOST")
    )

    case conn do
      true ->
        IO.puts "Connected to Apex Broadcast"
        :global.sync()
        ApexNeo4jAdapter.BoltStreamer.start_link(System.get_env("APEX_BOLT_URI"))
      _ ->
        {:error, "Unable to connect to Apex Broadcast, exiting"}
    end
  end
end
