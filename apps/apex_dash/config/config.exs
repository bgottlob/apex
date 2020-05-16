# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :phoenix, :json_library, Jason

# General application configuration
config :apex_dash,
  namespace: ApexDash

# Configures the endpoint
config :apex_dash, ApexDashWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "ZiAsbWn2nzouu36Ta3JR8jmCqz9Gycztbe8ppVYKRAFs+feb0nA/IizGPvlFBWZ5",
  render_errors: [view: ApexDashWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: ApexDash.PubSub,
  live_view: [signing_salt: "kCzxEq4RWot7tflnE6589Ty//HhJdfa4"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:user_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
