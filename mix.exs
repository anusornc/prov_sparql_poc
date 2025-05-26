defmodule ProvSparqlPoc.MixProject do
  use Mix.Project

  def project do
    [
      app: :prov_sparql_poc,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ProvSparqlPoc.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:prov, "~> 0.1.0"},
      # อัปเดตแล้ว
      {:rdf, "~> 2.1"},
      # อัปเดตแล้ว
      {:sparql, "~> 0.3.11"},
      {:sparql_client, "~> 0.5.0"},
      {:grax, "~> 0.5.0"},
      {:jason, "~> 1.4"},
      {:benchee, "~> 1.4", only: [:dev, :test]}
    ]
  end
end
