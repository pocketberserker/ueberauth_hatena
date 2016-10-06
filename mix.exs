defmodule UeberauthHatena.Mixfile do
  use Mix.Project

  @url "https://github.com/pocketberserker/ueberauth_hatena"

  def project do
    [app: :ueberauth_hatena,
     version: "0.1.0",
     package: package,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: @url,
     homepage_url: @url,
     description: description,
     deps: deps(),
     docs: docs]
  end

  def application do
    [applications: [:logger, :httpoison, :oauth, :ueberauth]]
  end

  defp deps do
    [{:ueberauth, "~> 0.4"},
     {:oauth, github: "tim/erlang-oauth"},
     {:httpoison, "~> 0.9"},
     {:ex_doc, "~> 0.1", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp description do
    "An Uberauth strategy for Hatena authentication."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["pocketberserker"],
     licenses: ["MIT"],
     links: %{"GitHub": @url}]
  end
end
