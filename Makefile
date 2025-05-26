.PHONY: help deps test benchmark-main benchmark-scalability benchmark-complexity benchmark-memory benchmark-all benchmark-clean benchmark-view

# Default target
help:
	@echo "ProvSparqlPoc Benchmark Commands"
	@echo "================================="
	@echo ""
	@echo "Setup:"
	@echo "  deps                 Install dependencies"
	@echo "  test                 Run tests"
	@echo ""
	@echo "Benchmarks:"
	@echo "  benchmark-main       Run main operations benchmark"
	@echo "  benchmark-scalability Run scalability benchmark"
	@echo "  benchmark-complexity  Run query complexity benchmark" 
	@echo "  benchmark-memory     Run memory stress test"
	@echo "  benchmark-all        Run complete benchmark suite"
	@echo ""
	@echo "Utilities:"
	@echo "  benchmark-clean      Clean benchmark results"
	@echo "  benchmark-view       Open benchmark results in browser"
	@echo ""

# Setup commands
deps:
	mix deps.get
	mix deps.compile

test:
	mix test

# Individual benchmark commands
benchmark-main:
	@echo "🚀 Running main operations benchmark..."
	mix run benchmark/run_benchmarks.exs main

benchmark-scalability:
	@echo "📈 Running scalability benchmark..."
	mix run benchmark/run_benchmarks.exs scalability

benchmark-complexity:
	@echo "🧩 Running query complexity benchmark..."
	mix run benchmark/run_benchmarks.exs complexity

benchmark-memory:
	@echo "🧠 Running memory stress test..."
	mix run benchmark/run_benchmarks.exs memory

benchmark-all:
	@echo "🎯 Running complete benchmark suite..."
	mix run benchmark/run_benchmarks.exs all

# Utility commands
benchmark-clean:
	@echo "🧹 Cleaning benchmark results..."
	rm -rf benchmark_results/
	@echo "✅ Benchmark results cleaned"

benchmark-view:
	@echo "🌐 Opening benchmark results..."
	@if [ -f "benchmark_results/index.html" ]; then \
		open benchmark_results/index.html 2>/dev/null || \
		xdg-open benchmark_results/index.html 2>/dev/null || \
		echo "Please open benchmark_results/index.html in your browser"; \
	else \
		echo "❌ No benchmark results found. Run 'make benchmark-all' first."; \
	fi

# Quick development workflow
quick-test: test benchmark-main

# Full validation workflow  
validate: test benchmark-all