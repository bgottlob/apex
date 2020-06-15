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
      deps: deps(),
      escript: escript()
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
      {:brink, "0.1.3", path: System.get_env("APEX_BRINK_PATH")},
      {:flow, "1.0.0"},
      {:gen_stage, "1.0.0"},
      {:jason, "1.2.1"}
    ]
  end

  def escript do
    [main_module: Apex.Mock.CLI, app: nil]
  end
end
