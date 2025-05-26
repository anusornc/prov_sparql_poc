defmodule ProvSparqlPoc.QueryEngine do
  @moduledoc """
  SPARQL query engine for supply chain traceability.

  Fixed to handle SPARQL.ex result formats correctly and use simpler queries.
  """

  alias ProvSparqlPoc.GraphStore

  @doc """
  Count all entities - using simple SELECT instead of COUNT aggregate
  """
  def count_entities do
    query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

    SELECT ?entity WHERE {
      ?entity rdf:type prov:Entity .
    }
    """

    case execute_query(query) do
      {:ok, %SPARQL.Query.Result{results: results}} ->
        count = length(results)
        IO.puts("✅ SPARQL entity count: #{count}")
        {:ok, count}

      {:error, reason} ->
        IO.puts("SPARQL query failed: #{inspect(reason)}")
        {:ok, 0}
    end
  end

  @doc """
  List all entities in the graph
  """
  def list_entities do
    query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>

    SELECT ?entity ?type WHERE {
      ?entity rdf:type prov:Entity .
      OPTIONAL { ?entity <http://example.org/provType> ?type . }
    }
    ORDER BY ?entity
    """

    execute_query(query)
  end

  @doc """
  Trace a product back to its origin - simplified query
  """
  def trace_to_origin(product_id) do
    # First, let's just find direct relationships
    query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>

    SELECT ?entity ?relation WHERE {
      {
        <#{product_id}> prov:wasDerivedFrom ?entity .
        BIND("wasDerivedFrom" AS ?relation)
      } UNION {
        <#{product_id}> prov:wasGeneratedBy ?entity .
        BIND("wasGeneratedBy" AS ?relation)
      } UNION {
        <#{product_id}> prov:wasAttributedTo ?entity .
        BIND("wasAttributedTo" AS ?relation)
      }
    }
    """

    execute_query(query)
  end

  @doc """
  Find contamination impact - simplified query
  """
  def contamination_impact(contaminated_batch_id) do
    query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>

    SELECT ?affected_product WHERE {
      ?affected_product prov:wasDerivedFrom <#{contaminated_batch_id}> .
    }
    """

    execute_query(query)
  end

  @doc """
  Get all relationships for a supply chain entity
  """
  def get_entity_relationships(entity_iri) do
    query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>

    SELECT ?predicate ?object WHERE {
      <#{entity_iri}> ?predicate ?object .
      FILTER(STRSTARTS(STR(?predicate), "http://www.w3.org/ns/prov#"))
    }
    """

    execute_query(query)
  end

  @doc """
  Get supply chain network - simplified to show direct relationships
  """
  def get_supply_chain_network(batch_id) do
    query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>

    SELECT ?subject ?predicate ?object WHERE {
      {
        <#{batch_id}> ?predicate ?object .
        BIND(<#{batch_id}> AS ?subject)
      } UNION {
        ?subject ?predicate <#{batch_id}> .
        BIND(<#{batch_id}> AS ?object)
      }
      FILTER(STRSTARTS(STR(?predicate), "http://www.w3.org/ns/prov#"))
    }
    """

    execute_query(query)
  end

  @doc """
  Test basic SPARQL functionality with simple queries
  """
  def test_basic_queries do
    IO.puts("🧪 Testing basic SPARQL queries...")

    # Test 1: Get all triples
    IO.puts("\n1. Testing: Get all triples")
    all_query = "SELECT ?s ?p ?o WHERE { ?s ?p ?o . } LIMIT 10"
    case execute_query(all_query) do
      {:ok, %SPARQL.Query.Result{results: results}} ->
        IO.puts("✅ Found #{length(results)} triples")
        if length(results) > 0 do
          IO.puts("Sample: #{inspect(hd(results))}")
        end
      {:error, error} -> IO.puts("❌ Failed: #{inspect(error)}")
    end

    # Test 2: Get all types
    IO.puts("\n2. Testing: Get all types")
    type_query = """
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    SELECT ?subject ?type WHERE { ?subject rdf:type ?type . }
    """
    case execute_query(type_query) do
      {:ok, %SPARQL.Query.Result{results: results}} ->
        IO.puts("✅ Found #{length(results)} typed entities")
        Enum.each(results, fn result ->
          IO.puts("  #{inspect(result["subject"])} → #{inspect(result["type"])}")
        end)
      {:error, error} -> IO.puts("❌ Failed: #{inspect(error)}")
    end

    # Test 3: Get PROV entities
    IO.puts("\n3. Testing: Get PROV entities")
    prov_query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    SELECT ?entity WHERE { ?entity rdf:type prov:Entity . }
    """
    case execute_query(prov_query) do
      {:ok, %SPARQL.Query.Result{results: results}} ->
        IO.puts("✅ Found #{length(results)} PROV entities")
        Enum.each(results, fn result ->
          IO.puts("  #{inspect(result["entity"])}")
        end)
      {:error, error} -> IO.puts("❌ Failed: #{inspect(error)}")
    end

    # Test 4: Get PROV relationships
    IO.puts("\n4. Testing: Get PROV relationships")
    rel_query = """
    PREFIX prov: <http://www.w3.org/ns/prov#>
    SELECT ?s ?p ?o WHERE {
      ?s ?p ?o .
      FILTER(STRSTARTS(STR(?p), "http://www.w3.org/ns/prov#"))
    }
    """
    case execute_query(rel_query) do
      {:ok, %SPARQL.Query.Result{results: results}} ->
        IO.puts("✅ Found #{length(results)} PROV relationships")
        Enum.take(results, 5) |> Enum.each(fn result ->
          IO.puts("  #{inspect(result["s"])} --#{inspect(result["p"])}--> #{inspect(result["o"])}")
        end)
      {:error, error} -> IO.puts("❌ Failed: #{inspect(error)}")
    end

    IO.puts("\n🎯 Basic query testing complete!")
  end

  @doc """
  Debug function to inspect the graph structure
  """
  def debug_graph do
    graph = GraphStore.get_graph()
    all_triples = RDF.Graph.triples(graph)

    IO.puts("\n=== GRAPH DEBUG INFO ===")
    IO.puts("Total triples: #{length(all_triples)}")

    # Show PROV relationships
    prov_relationships = all_triples
    |> Enum.filter(fn {_subject, predicate, _object} ->
      to_string(predicate) =~ "prov#"
    end)

    IO.puts("\nPROV Relationships (#{length(prov_relationships)}):")
    prov_relationships
    |> Enum.take(10)
    |> Enum.each(fn {subject, predicate, object} ->
      s_short = to_string(subject) |> String.replace("http://example.org/", "")
      p_short = to_string(predicate) |> String.replace("http://www.w3.org/ns/prov#", "prov:")
      o_short = case to_string(object) do
        "http://example.org/" <> rest -> rest
        "http://www.w3.org/ns/prov#" <> rest -> "prov:" <> rest
        other -> other
      end
      IO.puts("  #{s_short} --#{p_short}--> #{o_short}")
    end)

    IO.puts("=== END DEBUG INFO ===\n")

    {:ok, %{
      total_triples: length(all_triples),
      prov_relationships: length(prov_relationships)
    }}
  end

  # FIXED: Using correct SPARQL.ex API with proper argument order
  defp execute_query(sparql_query) do
    graph = GraphStore.get_graph()

    try do
      # CORRECT API: graph first, query second
      result = SPARQL.execute_query(graph, sparql_query)
      {:ok, result}
    rescue
      error ->
        IO.puts("SPARQL execution failed: #{inspect(error)}")
        {:error, error}
    end
  end
end
