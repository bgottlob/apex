require Apex.Mock
{[sport: sport, daddr: daddr, dport: dport, file: file],_,_} = OptionParser.parse(
  System.argv(),
  strict: [sport: :integer, daddr: :string, dport: :integer, file: :string]
)
Apex.Mock.UDPServer.start(sport, daddr, dport, file)
