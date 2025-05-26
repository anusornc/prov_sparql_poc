# benchmark/supply_chain_benchmark.exs
# Fixed benchmark without ExUnit dependencies

alias ProvSparqlPoc.{MilkSupplyChain, QueryEngine, GraphStore}

defmodule SupplyChainBenchmark do
  def run do
    IO.puts("🚀 Starting ProvChain PROV-O + SPARQL Benchmark...")
    IO.puts("=" |> String.duplicate(60))

    Benchee.run(
      %{
        "create_supply_chain" => fn batch_id ->
          MilkSupplyChain.create_milk_trace(batch_id)
        end,
        "trace_to_origin" => fn {batch_id, product_iri} ->
          QueryEngine.trace_to_origin(product_iri)
        end,
        "contamination_impact" => fn {batch_id, batch_iri} ->
          QueryEngine.contamination_impact(batch_iri)
        end,
        "count_entities" => fn _input ->
          QueryEngine.count_entities()
        end
      },
      before_scenario: fn input ->
        # Clear graph before each scenario
        GraphStore.clear_graph()

        # Create test data
        batch_id = "bench_#{System.system_time()}"
        triples = MilkSupplyChain.create_milk_trace(batch_id)
        GraphStore.add_triples(triples)

        product_iri = "http://example.org/milk/package/#{batch_id}"
        batch_iri = "http://example.org/milk/batch/#{batch_id}"

        case input do
          "create_supply_chain" -> batch_id
          "trace_to_origin" -> {batch_id, product_iri}
          "contamination_impact" -> {batch_id, batch_iri}
          "count_entities" -> :no_input
        end
      end,
      before_each: fn input ->
        # Small delay to ensure clean state
        Process.sleep(1)
        input
      end,
      time: 5,        # Run for 5 seconds each
      memory_time: 2, # Measure memory for 2 seconds
      warmup: 1,      # 1 second warmup
      print: [
        benchmarking: true,
        fast_warning: false,
        configuration: true
      ]
    )
  end

  def run_scalability_test do
    IO.puts("\n🔬 Scalability Test - Multiple Supply Chains")
    IO.puts("=" |> String.duplicate(60))

    # Test with different data sizes
    data_sizes = [1, 5, 10, 25, 50, 100]

    Enum.each(data_sizes, fn size ->
      IO.puts("\n📊 Testing with #{size} supply chains...")

      # Measure creation time
      {creation_time, triples} = :timer.tc(fn ->
        1..size
        |> Enum.flat_map(fn i ->
          MilkSupplyChain.create_milk_trace("scale_test_#{i}_#{System.system_time()}")
        end)
      end)

      # Clear and add data
      GraphStore.clear_graph()

      {insertion_time, :ok} = :timer.tc(fn ->
        GraphStore.add_triples(triples)
      end)

      # Measure query time
      first_batch_iri = "http://example.org/milk/package/scale_test_1_#{System.system_time()}"
      {query_time, {:ok, _results}} = :timer.tc(fn ->
        QueryEngine.trace_to_origin(first_batch_iri)
      end)

      # Measure count time
      {count_time, {:ok, entity_count}} = :timer.tc(fn ->
        QueryEngine.count_entities()
      end)

      IO.puts("  Chains: #{size}")
      IO.puts("  Triples: #{length(triples)}")
      IO.puts("  Creation: #{Float.round(creation_time / 1000, 2)}ms")
      IO.puts("  Insertion: #{Float.round(insertion_time / 1000, 2)}ms")
      IO.puts("  Query: #{Float.round(query_time / 1000, 2)}ms")
      IO.puts("  Count: #{Float.round(count_time / 1000, 2)}ms")
      IO.puts("  Entities: #{entity_count}")
    end)
  end

  def run_complexity_test do
    IO.puts("\n🧩 Query Complexity Test")
    IO.puts("=" |> String.duplicate(60))

    # Create a large dataset first
    IO.puts("Creating test dataset...")

    # Clear graph
    GraphStore.clear_graph()

    # Create 20 interconnected supply chains
    all_triples = 1..20
    |> Enum.flat_map(fn i ->
      MilkSupplyChain.create_milk_trace("complexity_test_#{i}_#{System.system_time()}")
    end)

    GraphStore.add_triples(all_triples)
    IO.puts("Dataset ready: #{length(all_triples)} triples")

    # Test different query types
    queries = %{
      "simple_count" => fn ->
        QueryEngine.count_entities()
      end,
      "single_trace" => fn ->
        QueryEngine.trace_to_origin("http://example.org/milk/package/complexity_test_1_#{System.system_time()}")
      end,
      "contamination_impact" => fn ->
        QueryEngine.contamination_impact("http://example.org/milk/batch/complexity_test_1_#{System.system_time()}")
      end,
      "supply_chain_network" => fn ->
        QueryEngine.get_supply_chain_network("http://example.org/milk/batch/complexity_test_1_#{System.system_time()}")
      end
    }

    Enum.each(queries, fn {query_name, query_fn} ->
      IO.puts("\n📈 Testing #{query_name}...")

      # Run multiple times and average
      times = for _i <- 1..5 do
        {time, _result} = :timer.tc(query_fn)
        time
      end

      avg_time = Enum.sum(times) / length(times)
      min_time = Enum.min(times)
      max_time = Enum.max(times)

      IO.puts("  Average: #{Float.round(avg_time / 1000, 2)}ms")
      IO.puts("  Min: #{Float.round(min_time / 1000, 2)}ms")
      IO.puts("  Max: #{Float.round(max_time / 1000, 2)}ms")
    end)
  end
end

# Run all benchmarks
IO.puts("🎯 ProvChain PROV-O + SPARQL Performance Benchmark")
IO.puts("Testing: PROV.ex #{Application.spec(:prov, :vsn)} + SPARQL.ex #{Application.spec(:sparql, :vsn)}")
IO.puts("Date: #{DateTime.now!("Etc/UTC")}")
IO.puts("")

# Main benchmarks
SupplyChainBenchmark.run()

# Scalability test
SupplyChainBenchmark.run_scalability_test()

# Complexity test
SupplyChainBenchmark.run_complexity_test()

IO.puts("\n✅ Benchmark Complete!")
IO.puts("=" |> String.duplicate(60))
