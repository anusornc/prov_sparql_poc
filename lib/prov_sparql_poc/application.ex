defmodule ProvSparqlPoc.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the RDF graph store
      {ProvSparqlPoc.GraphStore, []}
    ]

    opts = [strategy: :one_for_one, name: ProvSparqlPoc.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
