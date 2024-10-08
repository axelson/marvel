defmodule Marvel.Mixfile do
  use Mix.Project

  def project do
    [
      app: :marvel,
      version: "1.0.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      escript: escript_config(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description()
    ]
  end

  defp description do
    """
    Marvel API and CLI Client
    """
  end

  defp escript_config do
    [main_module: Marvel.CLI, name: "marvel"]
  end

  def application do
    [extra_applications: [:logger, :runtime_tools, :httpoison]]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:httpoison, "~> 2.1"},
      {:jason, "~> 1.2"},
      {:dotenv_parser, "~> 2.0"},
      {:ex_doc, "~> 0.34.2", only: :dev},
      {:esbuild, "~> 0.7.1"},
      {:mox, "~> 1.0", only: :test}
    ]
  end

  defp package do
    # These are the default files included in the package
    [
      files: ["lib", "mix.exs", "README*", "readme*", "LICENSE*", "license*", "CHANGELOG*"],
      contributors: ["Bryan Joseph"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/bryanjos/marvel"
      }
    ]
  end
end
