# ProvSparqlPoc

A **Proof of Concept (PoC)** demonstrating supply chain traceability using **W3C PROV-O ontology** with **RDF** and **SPARQL** technologies in **Elixir**.

## 🎯 Project Overview

This project models milk supply chain provenance from farm to package, enabling:

- **Complete traceability**: Track products back to their origin
- **Contamination impact analysis**: Find all affected products from a contaminated source
- **Supply chain transparency**: Visualize the entire production network
- **Regulatory compliance**: Meet food safety and traceability requirements
- **Performance at scale**: Handle multiple supply chains efficiently

## 🏗️ Architecture

### Core Components

1. **Supply Chain Modeling** (`MilkSupplyChain`)
   - Models 3 entities: `milk batch` → `processed milk` → `packaged milk`
   - Models 3 activities: `collection` → `processing` → `packaging`
   - Models 3 agents: `farmer` → `processor` → `packager`
   - Uses PROV-O relationships: `wasGeneratedBy`, `wasAttributedTo`, `wasDerivedFrom`, etc.

2. **Data Storage** (`GraphStore`)
   - GenServer-based in-memory RDF graph store
   - Stores triples representing supply chain provenance
   - Operations: `add_triples`, `get_graph`, `clear_graph`

3. **Query Engine** (`QueryEngine`)
   - SPARQL-based querying with fallback mechanisms
   - Key queries:
     - `trace_to_origin()` - trace products back to source
     - `contamination_impact()` - find all affected products
     - `get_supply_chain_network()` - full supply chain visualization
     - `count_entities()` - performance testing

4. **Benchmark Suite**
   - Comprehensive performance testing with HTML reports
   - Tests scalability from 1-50 supply chains
   - Measures creation, storage, and query performance
   - Generates interactive HTML dashboards

## 🛠️ Technology Stack

- **Elixir/OTP** - Concurrent, fault-tolerant platform
- **RDF.ex** - RDF data handling and manipulation
- **PROV.ex** - W3C PROV-O ontology support
- **SPARQL.ex** - SPARQL query execution
- **Benchee + Benchee HTML** - Performance benchmarking and reporting

## 📋 Prerequisites

- **Elixir** >= 1.18
- **Erlang/OTP** >= 27
- **Git**
- **Make** (for easy command execution)

### Installation

```bash
# Clone the repository
git clone <your-repo-url>
cd prov_sparql_poc

# Install dependencies
make deps

# Run tests to verify setup
make test
```

## 🚀 Quick Start

### 1. Basic Functionality Test

```bash
# Start an interactive shell
iex -S mix

# Create a milk supply chain
iex> alias ProvSparqlPoc.{MilkSupplyChain, QueryEngine, GraphStore}
iex> batch_id = "test_batch_001"
iex> triples = MilkSupplyChain.create_milk_trace(batch_id)
iex> GraphStore.add_triples(triples)
iex> {:ok, count} = QueryEngine.count_entities()
iex> IO.puts("Created supply chain with #{count} entities")
```

### 2. Run Benchmarks

```bash
# Run main operations benchmark
make benchmark-main

# Run scalability benchmark (1-50 supply chains)
make benchmark-scalability

# Run query performance benchmark
make benchmark-query

# Run complete benchmark suite
make benchmark-all

# View results in browser
make benchmark-view
```

## 📊 Benchmark Results

### Performance Characteristics

Based on Apple M1 testing:

| Operation | Performance | Use Case |
|-----------|-------------|----------|
| **create_supply_chain** | 263K ops/sec | Data structure creation |
| **contamination_impact** | 38K ops/sec | Safety analysis queries |
| **trace_to_origin** | 36K ops/sec | Traceability queries |
| **count_entities** | 7K ops/sec | Analytics queries |
| **add_triples_to_store** | 3K ops/sec | Data persistence |

### Memory Usage

- **Data creation**: ~13 KB per operation
- **Query operations**: ~42 KB per operation  
- **Analytics**: ~84 KB per operation

## 🧪 Use Cases Demonstrated

### 1. Food Safety Traceability

```elixir
# Trace a product back to its origin
product_iri = "http://example.org/milk/package/batch_123"
{:ok, trace_results} = QueryEngine.trace_to_origin(product_iri)
```

### 2. Contamination Impact Analysis

```elixir
# Find all products affected by contaminated source
contaminated_batch = "http://example.org/milk/batch/batch_456"
{:ok, affected_products} = QueryEngine.contamination_impact(contaminated_batch)
```

### 3. Supply Chain Network Visualization

```elixir
# Get complete supply chain network
batch_iri = "http://example.org/milk/batch/batch_789"
{:ok, network} = QueryEngine.get_supply_chain_network(batch_iri)
```

## 📁 Project Structure

```
prov_sparql_poc/
├── lib/
│   └── prov_sparql_poc/
│       ├── application.ex           # OTP application
│       ├── graph_store.ex          # RDF graph storage
│       ├── milk_supply_chain.ex    # Supply chain modeling
│       └── query_engine.ex         # SPARQL query execution
├── test/
│   └── prov_sparql_poc_test.exs    # Comprehensive tests
├── benchmark/
│   ├── supply_chain_benchmark.exs  # Benchmark suite
│   └── run_benchmarks.exs          # Benchmark runner
├── benchmark_results/              # Generated HTML reports
├── Makefile                        # Command shortcuts
├── mix.exs                         # Project configuration
└── README.md                       # This file
```

## 🔧 Available Make Commands

### Setup Commands
```bash
make deps          # Install dependencies
make test          # Run tests
```

### Benchmark Commands
```bash
make benchmark-main         # Run main operations benchmark
make benchmark-scalability  # Run scalability benchmark
make benchmark-query        # Run query performance benchmark
make benchmark-all          # Run complete benchmark suite
```

### Utility Commands
```bash
make benchmark-clean  # Clean benchmark results
make benchmark-view   # Open benchmark results in browser
```

### Development Workflows
```bash
make quick-test      # Run tests + main benchmark
make validate        # Run tests + complete benchmark suite
```

## 📈 Understanding Benchmark Reports

The benchmark generates several HTML reports:

### 1. **Main Operations** (`main_benchmark.html`)
- Core supply chain operations performance
- Memory usage analysis
- Comparison charts

### 2. **Scalability Analysis** (`scalability_benchmark.html`)  
- Performance scaling from 1-50 supply chains
- Identifies performance bottlenecks
- Memory growth patterns

### 3. **Query Performance** (`query_benchmark.html`)
- SPARQL query execution times
- Complex query analysis
- Network traversal performance

### 4. **Summary Dashboard** (`index.html`)
- Overview of all benchmark results
- Quick navigation to detailed reports
- System information and technology stack

## 🎨 PROV-O Model

The PoC implements the following PROV-O pattern:

```
Farmer Agent ──wasAssociatedWith──> Collection Activity
    │                                       │
    │                               wasGeneratedBy
    │                                       │
    └──────wasAttributedTo─────> Milk Batch Entity
                                        │
                                 wasDerivedFrom
                                        │
Processor Agent ──wasAssociatedWith──> Processing Activity  
    │                                       │
    │                               wasGeneratedBy
    │                                       │
    └──────wasAttributedTo─────> Processed Milk Entity
                                        │
                                 wasDerivedFrom
                                        │
Packager Agent ──wasAssociatedWith──> Packaging Activity
    │                                       │
    │                               wasGeneratedBy
    │                                       │
    └──────wasAttributedTo─────> Packaged Milk Entity
```

## 🔍 Example SPARQL Queries

### Trace to Origin
```sparql
PREFIX prov: <http://www.w3.org/ns/prov#>

SELECT ?entity ?activity ?agent ?timestamp WHERE {
  <product_iri> prov:wasDerivedFrom* ?entity .
  ?entity prov:wasGeneratedBy ?activity .
  ?activity prov:wasAssociatedWith ?agent .
  ?entity prov:generatedAtTime ?timestamp .
}
ORDER BY ?timestamp
```

### Contamination Impact
```sparql
PREFIX prov: <http://www.w3.org/ns/prov#>

SELECT DISTINCT ?affected_product WHERE {
  ?affected_product prov:wasDerivedFrom+ <contaminated_batch_iri> .
}
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests (`make test`)
5. Run benchmarks (`make benchmark-all`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **W3C PROV Working Group** for the PROV-O ontology specification
- **Elixir RDF Community** for excellent RDF and SPARQL libraries
- **Benchee Team** for comprehensive benchmarking tools

## 📞 Support

For questions, issues, or contributions:

1. Check existing [Issues](../../issues)
2. Create a new issue with detailed description
3. Include benchmark results if reporting performance issues
4. Provide minimal reproduction steps

---

**Built with ❤️ for supply chain transparency and food safety**