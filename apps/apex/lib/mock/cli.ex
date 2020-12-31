defmodule Apex.Mock.CLI do
  @moduledoc """
  Provides a command line interface for starting a test UDP server or UDP
  listener.
  """

  def main(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [sport: :integer, daddr: :string, dport: :integer, file: :string, capture: :boolean, stream: :boolean])
    case Enum.sort(opts, fn {x, _}, {y, _} -> x <= y end) do
      [daddr: daddr, dport: dport, file: file, sport: sport, stream: true] ->
        Apex.Mock.UDPServer.start(sport, daddr, dport, file)
      [capture: true, dport: dport, file: file] ->
        Apex.Mock.UDPCapture.start(dport, file)
    end
  end
end
