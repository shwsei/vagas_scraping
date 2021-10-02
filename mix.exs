defmodule Webscraping.MixProject do
  use Mix.Project

  def project do
    [
      app: :webscraping,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp escript do
    [main_module: Webscraping]
  end

  defp deps do
    [
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:floki, "~> 0.31.0"},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end
end
