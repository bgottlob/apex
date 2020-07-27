use Mix.Config

import_config "../apps/*/config/config.exs"

config :apex_shift_bulb,
  bridge_address: System.get_env("APEX_HUE_BRIDGE_ADDRESS"),
  username: System.get_env("APEX_HUE_USERNAME"),
  light_number: System.get_env("APEX_HUE_LIGHT_NUMBER")
