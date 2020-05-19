defmodule ApexShiftBulb.MixProject do
  use Mix.Project

  def project do
    [
      app: :apex_shift_bulb,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {ApexShiftBulb, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2.1"},
      {:mint, "~> 1.1.0"},
      {:apex, in_umbrella: true}
    ]
  end
end
