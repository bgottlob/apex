defmodule Apex.MixProject do
  use Mix.Project

  def project do
    [
      app: :apex,
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
      mod: {Apex, [20777]},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:gen_stage, "~> 1.0.0"}
    ]
  end
end
