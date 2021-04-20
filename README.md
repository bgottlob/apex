# Apex

Apex is a suite of tools for parsing and viewing UDP telemetry data from racing
simulators.  Currently, the only supported racing simulator is
[F1 2019](https://www.codemasters.com/game/f1-2019/)

## Components

- [Apex](./apps/apex) - Elixir library for listening to UDP data, parsing it, and broadcasting it to [GenStage](https://hexdocs.pm/gen_stage/GenStage.html) consumers
- [Apex Broadcast](./apps/apex_broadcast) - Elixir application that runs a [GenStage](https://hexdocs.pm/gen_stage/GenStage.html) producer broadcasting UDP data converted to structs
- [Apex Dash](./apps/apex_dash) - Phoenix application displaying the current state of car telemetry in real time
