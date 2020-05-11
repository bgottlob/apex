# Apex

Apex is a parser of UDP telemetry from racing simulators (currently only
[F1 2019 by Codemasters](https://www.codemasters.com/game/f1-2019/)).

Run `mix run`, which will output Elixir structs representing car telemetry
data from a single UDP packet, whose contents are stored in
`test/sample_data/car_telemetry_packet`.
