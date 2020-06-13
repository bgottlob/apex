# Apex

Apex is a parser of UDP telemetry from racing simulators (currently only
[F1 2019 by Codemasters](https://www.codemasters.com/game/f1-2019/)).

## Usage

Run `mix run --no-halt` to start an `Apex.Broadcaster` process, which listens to
UDP port 20777 for telemetry data, parses it, and broadcasts to
`Apex.Subscriber` processes. `Apex.Subscriber` processes must be started
separately.

### Capturing and Streaming Data

The `Apex.Mock.UDPCapture` module can listen on a UDP port for binary telemetry
data and capture each packet into a file to be streamed by the
`Apex.Mock.UDPServer` module.

To use either of these modules, build and install this app's `escript`:
```
mix escript.build && mix escript.install
```

To capture UDP packets into a file, use the following command:
```
./apex --dport <udp_port> --file <output_file> --capture
```
* `--dport`: UDP port the packets to be captured are sent to
* `--file`: Path to file the packet data will be saved in

To stream UDP packets from a file, use the following command:
```
./apex --sport <src_udp_port> \
       --daddr <dest_ip_address> --dport <dest_udp_port> \
       --file <file_to_stream> --stream
```
* `--sport`: UDP port to open locally to send data from
* `--daddr` and `--dport`: IP address and UDP port of host to send UDP data to
* `--file`: File containing Base16 encoded UDP packets that will be streamed

Alternatively use `apex` instead of `./apex` if you installed the escript in
a location on your `PATH`.
