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
    case triples do
      # Handle invalid inputs gracefully
      :no_input ->
        Logger.warning("GraphStore received :no_input, skipping triple addition")
        {:reply, :ok, state}

      # Handle empty lists
      [] ->
        {:reply, :ok, state}

      # Handle nil
      nil ->
        Logger.warning("GraphStore received nil triples, skipping triple addition")
        {:reply, :ok, state}

      # Handle valid triples (list of tuples)
      triples when is_list(triples) ->
        try do
          new_graph = Graph.add(graph, triples)
          {:reply, :ok, %{state | graph: new_graph}}
        rescue
          error ->
            Logger.error("Failed to add triples to graph: #{inspect(error)}")
            {:reply, {:error, error}, state}
        end

      # Handle other invalid inputs
      invalid ->
        Logger.warning("GraphStore received invalid triples format: #{inspect(invalid)}")
        {:reply, {:error, :invalid_triples_format}, state}
    end
  end

  def handle_call(:clear_graph, _from, state) do
    {:reply, :ok, %{state | graph: Graph.new()}}
  end
end
