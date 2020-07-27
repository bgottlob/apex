defmodule ApexRedisStreamer.MixProject do
  use Mix.Project

  def project do
    [
      app: :apex_redis_streamer,
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

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {ApexRedisStreamer.Application, []},
      extra_applications: [:mix, :logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:apex, in_umbrella: true},
      {:brink, "0.1.3", path: "../../brink/brink"},
    ]
  end
end
