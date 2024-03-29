defmodule ApexDash.Mixfile do
  use Mix.Project

  def project do
    [
      app: :apex_dash,
      version: "0.0.1",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {ApexDash.Application, []},
      extra_applications: [:apex_broadcast, :logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "1.5.3"},
      {:phoenix_pubsub, "2.0.0"},
      {:phoenix_html, "2.14.2"},
      {:phoenix_live_reload, "1.2.4", only: :dev},
      {:gettext, "0.18.0"},
      {:plug_cowboy, "2.3.0"},
      {:apex, in_umbrella: true},
      {:phoenix_live_view, "0.14.1"},
      {:jason, "~> 1.2.1"},
      {:gen_stage, "~> 1.0.0"}
    ]
  end
end
