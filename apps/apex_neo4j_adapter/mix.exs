defmodule ApexNeo4jAdapter.MixProject do
  use Mix.Project

  def project do
    [
      app: :apex_neo4j_adapter,
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
      mod: {ApexNeo4jAdapter, ["localhost", 7687]},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:apex, in_umbrella: true},
      {:bolt_sips, "2.0.7"}
    ]
  end
end
