defmodule Apex.Environment do
  @moduledoc """
  Functions for interacting with Apex's distributed environment
  """

  # Perform a DNS lookup to find the IP address of the node
  # Docker uses an internal DNS mechanism
  defp look_up_ip(hostname) do
    {string, _} = System.cmd("nslookup", [hostname])
    Regex.scan(~r/Address: (\d{1,4}\.\d{1,4}\.\d{1,4}\.\d{1,4})/, string)
    |> List.flatten
    |> List.last
    |> String.trim
  end

  # Connect to node running apex_broadcast application
  def connect_to_broadcast do
    ip = case Mix.env() == :prod do
      true -> look_up_ip(Application.fetch_env!(:apex, :broadcast_host))
      _    -> Node.self |> to_string |> String.split("@") |> List.last
    end
    Node.connect(:"apex_broadcast@#{ip}")
  end
end
