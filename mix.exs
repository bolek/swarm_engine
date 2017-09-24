defmodule SwarmEngine.Mixfile do
  use Mix.Project

  def project do
    [
      app: :swarm_engine,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger,
        :goth,
        :hackney
      ],
      mod: {SwarmEngine.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:goth, "~> 0.4.0"},
      {:postgrex, ">= 0.0.0"},
      {:ecto, "~> 2.1"},
      {:hackney, "~> 1.9"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
