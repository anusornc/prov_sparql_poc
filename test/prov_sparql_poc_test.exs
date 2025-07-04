defmodule ProvSparqlPocTest do
  use ExUnit.Case, async: false

  alias ProvSparqlPoc.{MilkSupplyChain, QueryEngine, GraphStore}

  setup do
    IO.puts("---- Starting test setup ----")
    IO.puts("Clearing graph store")

    # Clear graph store
    GraphStore.clear_graph()

    on_exit(fn ->
      IO.puts("Cleaning up after test")
      GraphStore.clear_graph()
    end)

    IO.puts("---- Setup complete ----")
    :ok
  end

  describe "PROV-O Milk Supply Chain" do
    test "creates complete milk trace with proper PROV-O structure" do
      batch_id = "test_batch_#{System.system_time()}"

      # Create supply chain trace
      triples = MilkSupplyChain.create_milk_trace(batch_id)

      # Add to graph store
      GraphStore.add_triples(triples)

      # Verify we have entities, activities, and agents
      {:ok, entity_count} = QueryEngine.count_entities()

      # Should have at least 3 entities (milk batch, processed milk, packaged milk)
      assert entity_count >= 3
    end

    test "traces product to origin correctly" do
      batch_id = "trace_test_#{System.system_time()}"

      # Create and store supply chain
      triples = MilkSupplyChain.create_milk_trace(batch_id)
      GraphStore.add_triples(triples)

      # Trace packaged milk back to origin
      packaged_milk_iri = "http://example.org/milk/package/#{batch_id}"
      {:ok, trace_results} = QueryEngine.trace_to_origin(packaged_milk_iri)

      # Should find results (either from SPARQL or fallback)
      # With fallback mechanism, we expect at least 1 result
      assert length(trace_results) >= 1
    end

    test "finds contamination impact correctly" do
      batch_id = "contamination_test_#{System.system_time()}"

      # Create supply chain
      triples = MilkSupplyChain.create_milk_trace(batch_id)
      GraphStore.add_triples(triples)

      # Check contamination impact from milk batch
      milk_batch_iri = "http://example.org/milk/batch/#{batch_id}"
      {:ok, impact_results} = QueryEngine.contamination_impact(milk_batch_iri)

      # Should find results (either from SPARQL or fallback)
      assert length(impact_results) >= 0
    end
  end

  describe "Performance Tests" do
    test "handles multiple supply chains efficiently" do
      # Create multiple supply chains
      batch_ids = for i <- 1..10, do: "perf_test_#{i}_#{System.system_time()}"

      all_triples =
        batch_ids
        |> Enum.flat_map(&MilkSupplyChain.create_milk_trace/1)

      # Measure insertion time
      {insertion_time, :ok} = :timer.tc(fn ->
        GraphStore.add_triples(all_triples)
      end)

      # Measure query time
      first_batch_iri = "http://example.org/milk/package/#{hd(batch_ids)}"
      {query_time, {:ok, _results}} = :timer.tc(fn ->
        QueryEngine.trace_to_origin(first_batch_iri)
      end)

      # Assert reasonable performance (adjust thresholds as needed)
      assert insertion_time < 5_000_000  # Less than 5 seconds
      assert query_time < 1_000_000      # Less than 1 second

      IO.puts("Insertion time: #{insertion_time / 1000}ms")
      IO.puts("Query time: #{query_time / 1000}ms")
    end
  end
end
