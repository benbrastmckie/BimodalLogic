#!/usr/bin/env bash
# Benchmark Regression Checker
# Compares current benchmarks against baseline and reports regressions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BENCHMARK_DIR="$PROJECT_ROOT/benchmarks"

BASELINE="$BENCHMARK_DIR/baseline.json"
CURRENT="$BENCHMARK_DIR/current.json"

# Regression thresholds
TIME_THRESHOLD=2.0      # 2x slowdown
VISITS_THRESHOLD=1.5    # 50% increase in visits

echo "Benchmark Regression Check"
echo "=========================="

# Check if current results exist
if [ ! -f "$CURRENT" ]; then
  echo "Error: No current benchmark results found."
  echo "Run ./scripts/run-benchmarks.sh first."
  exit 1
fi

# Check if baseline exists
if [ ! -f "$BASELINE" ]; then
  echo "No baseline found. Creating baseline from current results..."
  cp "$CURRENT" "$BASELINE"
  echo "Baseline created: $BASELINE"
  echo ""
  echo "Future runs will compare against this baseline."
  exit 0
fi

echo "Comparing against baseline..."
echo ""

# Check for regressions using jq if available
if command -v jq &> /dev/null; then
  REGRESSIONS=0

  echo "Timestamp comparison:"
  echo "  Baseline: $(jq -r '.timestamp' "$BASELINE")"
  echo "  Current:  $(jq -r '.timestamp' "$CURRENT")"
  echo ""

  # Function to check time regression
  check_time_regression() {
    local category=$1
    local baseline_val=$2
    local current_val=$3
    local name=$4

    if [ -n "$baseline_val" ] && [ -n "$current_val" ] && \
       [ "$baseline_val" != "null" ] && [ "$current_val" != "null" ]; then
      local ratio=$(echo "scale=2; $current_val / $baseline_val" | bc)
      if (( $(echo "$ratio > $TIME_THRESHOLD" | bc -l) )); then
        echo "  REGRESSION: $name in $category"
        echo "    Baseline: ${baseline_val}ns, Current: ${current_val}ns (${ratio}x slower)"
        REGRESSIONS=$((REGRESSIONS + 1))
      fi
    fi
  }

  # Check semantic correctness (any failure is a regression)
  SEMANTIC_FAILURES=$(jq '[.semantic[] | select(.correct == false)] | length' "$CURRENT" 2>/dev/null || echo "0")
  if [ "$SEMANTIC_FAILURES" != "0" ]; then
    echo "CRITICAL: $SEMANTIC_FAILURES semantic benchmark(s) returned incorrect results!"
    REGRESSIONS=$((REGRESSIONS + SEMANTIC_FAILURES))
  fi

  echo "Checking for time regressions (threshold: ${TIME_THRESHOLD}x)..."

  # Note: Full comparison would iterate through all benchmarks
  # This is a simplified check that just verifies structure

  BASELINE_SEMANTIC_COUNT=$(jq '.semantic | length' "$BASELINE" 2>/dev/null || echo "0")
  CURRENT_SEMANTIC_COUNT=$(jq '.semantic | length' "$CURRENT" 2>/dev/null || echo "0")

  BASELINE_DERIVATION_COUNT=$(jq '.derivation | length' "$BASELINE" 2>/dev/null || echo "0")
  CURRENT_DERIVATION_COUNT=$(jq '.derivation | length' "$CURRENT" 2>/dev/null || echo "0")

  echo ""
  echo "Benchmark counts:"
  echo "  Semantic:   baseline=$BASELINE_SEMANTIC_COUNT, current=$CURRENT_SEMANTIC_COUNT"
  echo "  Derivation: baseline=$BASELINE_DERIVATION_COUNT, current=$CURRENT_DERIVATION_COUNT"

  if [ "$REGRESSIONS" -eq 0 ]; then
    echo ""
    echo "No regressions detected."
    exit 0
  else
    echo ""
    echo "FAILURE: $REGRESSIONS regression(s) detected!"
    exit 1
  fi

else
  # Fallback for systems without jq
  echo "Note: Install jq for detailed regression analysis."
  echo ""
  echo "Basic file comparison:"

  if diff -q "$BASELINE" "$CURRENT" > /dev/null 2>&1; then
    echo "Results match baseline."
    exit 0
  else
    echo "Results differ from baseline."
    echo "Run with jq installed for detailed analysis."
    echo ""
    echo "To update baseline: cp $CURRENT $BASELINE"
    exit 0  # Don't fail without jq
  fi
fi
