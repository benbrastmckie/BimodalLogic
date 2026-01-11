#!/usr/bin/env bash
# Bimodal Benchmark Runner
# Runs all benchmark suites and captures results

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/benchmarks"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

echo "Running Bimodal benchmarks..."
echo "=============================="
echo ""

TIMESTAMP=$(date -Iseconds)

# Create temp files for output
PROOF_OUTPUT=$(mktemp)
DERIV_OUTPUT=$(mktemp)
SEMANTIC_OUTPUT=$(mktemp)

# Cleanup on exit
trap "rm -f $PROOF_OUTPUT $DERIV_OUTPUT $SEMANTIC_OUTPUT" EXIT

# Run proof search benchmarks (once)
echo "Running proof search benchmarks..."
lake env lean --run BimodalTest/Automation/ProofSearchBenchmark.lean > "$PROOF_OUTPUT" 2>&1

# Run derivation benchmarks (once)
echo "Running derivation benchmarks..."
lake env lean --run BimodalTest/ProofSystem/DerivationBenchmark.lean > "$DERIV_OUTPUT" 2>&1

# Run semantic benchmarks (once)
echo "Running semantic benchmarks..."
lake env lean --run BimodalTest/Semantics/SemanticBenchmark.lean > "$SEMANTIC_OUTPUT" 2>&1

echo ""
echo "=== Proof Search Results ==="
grep -E "(Modal|Temporal|Prop|Mixed|Context|Summary|found=)" "$PROOF_OUTPUT" | head -20

echo ""
echo "=== Derivation Results ==="
grep -E "(Axiom|Assumption|MP |Necessitation|Temporal|Weakening|SUMMARY|Benchmarks|Total|Average|height=)" "$DERIV_OUTPUT" | head -20

echo ""
echo "=== Semantic Results ==="
grep -E "(Atom|Bot|Box|Gp|Hp|→|SUMMARY|Benchmarks|Correct|Total|Average|expected=)" "$SEMANTIC_OUTPUT" | head -20

# Extract metrics
PROOF_FOUND=$(grep -c "found=true" "$PROOF_OUTPUT" || echo "0")
PROOF_TOTAL=$(grep -c "found=" "$PROOF_OUTPUT" || echo "0")
DERIV_COUNT=$(grep -c "height=" "$DERIV_OUTPUT" || echo "0")
SEMANTIC_CORRECT=$(grep -c "✓" "$SEMANTIC_OUTPUT" || echo "0")
SEMANTIC_TOTAL=$(grep -c "expected=" "$SEMANTIC_OUTPUT" || echo "0")

# Create summary JSON
cat > "$OUTPUT_DIR/current.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "summary": {
    "proof_search": {
      "found": $PROOF_FOUND,
      "total": $PROOF_TOTAL
    },
    "derivation": {
      "count": $DERIV_COUNT
    },
    "semantic": {
      "correct": $SEMANTIC_CORRECT,
      "total": $SEMANTIC_TOTAL
    }
  }
}
EOF

echo ""
echo "=============================="
echo "Benchmarks complete!"
echo "Summary saved to: $OUTPUT_DIR/current.json"
echo ""
cat "$OUTPUT_DIR/current.json"
