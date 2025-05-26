defmodule ProvSparqlPoc.GraphStore do
  use GenServer
  alias RDF.Graph
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def get_graph, do: GenServer.call(__MODULE__, :get_graph)
  def add_triples(triples), do: GenServer.call(__MODULE__, {:add_triples, triples})
  def clear_graph, do: GenServer.call(__MODULE__, :clear_graph)

  @impl true
  def init(_opts) do
    Logger.info("Starting RDF Graph Store")
    {:ok, %{graph: Graph.new()}}
  end

  @impl true
  def handle_call(:get_graph, _from, %{graph: graph} = state) do
    {:reply, graph, state}
  end

  def handle_call({:add_triples, triples}, _from, %{graph: graph} = state) do
    new_graph = Graph.add(graph, triples)
    {:reply, :ok, %{state | graph: new_graph}}
  end

  def handle_call(:clear_graph, _from, state) do
    {:reply, :ok, %{state | graph: Graph.new()}}
  end
end
