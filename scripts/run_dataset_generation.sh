#!/usr/bin/env bash
# Run production dataset generation for BMLogic training data.
#
# Usage:
#   ./scripts/run_dataset_generation.sh c5          # Complexity 5, exhaustive, ~1.5K formulas
#   ./scripts/run_dataset_generation.sh c7          # Complexity 7, exhaustive, ~50K formulas
#   ./scripts/run_dataset_generation.sh c9          # Complexity 9, exhaustive, ~300K-1.8M formulas (2-6h)
#   ./scripts/run_dataset_generation.sh c11         # Complexity 11, stratified, ~500K-2M formulas (3-8h)
#   ./scripts/run_dataset_generation.sh smoke       # Quick validation run (20 formulas)
#   ./scripts/run_dataset_generation.sh all         # All tiers: c5, c7, c9, c11
#
# Prerequisites:
#   lake build dataset_generator
#
# Output:
#   data/bmlogic-c5.jsonl  + data/bmlogic-c5_metadata.json   (complexity-5, exhaustive)
#   data/bmlogic-c7.jsonl  + data/bmlogic-c7_metadata.json   (complexity-7, exhaustive)
#   data/bmlogic-c9.jsonl  + data/bmlogic-c9_metadata.json   (complexity-9, exhaustive, ~300K-1.8M)
#   data/bmlogic-c11.jsonl + data/bmlogic-c11_metadata.json  (complexity-11, stratified, ~500K-2M)
#
# Feasibility gates (per run):
#   - Timeout rate < 20%
#   - Valid fraction >= 15%
#   - At least 3 distinct GoalCategory types

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# Ensure data directory exists
mkdir -p data

run_smoke() {
    echo "=== Smoke Test (complexity 3, 20 formulas) ==="
    lake exe dataset_generator -- \
        --max-complexity 3 \
        --max-formulas 20 \
        --output data/smoke-test.jsonl
    echo ""
    echo "Smoke test output:"
    wc -l data/smoke-test.jsonl
    cat data/smoke-test_metadata.json
    echo ""
    # Clean up
    rm -f data/smoke-test.jsonl data/smoke-test_metadata.json
    echo "Smoke test files cleaned up."
}

run_c5() {
    echo "=== C5 Production Run (complexity 5, exhaustive, ~1.5K formulas) ==="
    echo "Started at: $(date -Iseconds)"
    # Exhaustive enumeration of all complexity-5 bimodal formulas with duals.
    time lake exe dataset_generator -- \
        --max-complexity 5 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --valid-seed-count 2000 \
        --output data/bmlogic-c5.jsonl \
        --mode exhaustive \
        --include-duals
    echo ""
    echo "Completed at: $(date -Iseconds)"
    echo "Output:"
    wc -l data/bmlogic-c5.jsonl
    cat data/bmlogic-c5_metadata.json
    echo ""
}

run_c7() {
    echo "=== C7 Production Run (complexity 7, exhaustive, ~50K formulas) ==="
    echo "Started at: $(date -Iseconds)"
    # Exhaustive enumeration of all complexity-7 bimodal formulas with duals.
    time lake exe dataset_generator -- \
        --max-complexity 7 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 50000 \
        --valid-seed-count 5000 \
        --output data/bmlogic-c7.jsonl \
        --mode exhaustive \
        --include-duals
    echo ""
    echo "Completed at: $(date -Iseconds)"
    echo "Output:"
    wc -l data/bmlogic-c7.jsonl
    cat data/bmlogic-c7_metadata.json
    echo ""
}

run_c9() {
    echo "=== C9 Production Run (complexity 9, exhaustive, ~300K-1.8M formulas, est. 2-6h) ==="
    echo "Started at: $(date -Iseconds)"
    # Exhaustive enumeration of all complexity-9 bimodal formulas with duals.
    # Capped at 2M formulas as a safety limit.
    time lake exe dataset_generator -- \
        --max-complexity 9 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 2000000 \
        --valid-seed-count 10000 \
        --output data/bmlogic-c9.jsonl \
        --mode exhaustive \
        --include-duals
    echo ""
    echo "Completed at: $(date -Iseconds)"
    echo "Output:"
    wc -l data/bmlogic-c9.jsonl
    cat data/bmlogic-c9_metadata.json
    echo ""
}

run_c11() {
    echo "=== C11 Production Run (complexity 11, stratified, ~500K-2M formulas, est. 3-8h) ==="
    echo "Started at: $(date -Iseconds)"
    # Stratified enumeration: exhaustive up to c9, sampled at c10/c11.
    # Quotas: c10 = 100K samples, c11 = 300K samples (0 = exhaustive for c1-c9).
    time lake exe dataset_generator -- \
        --max-complexity 11 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 2000000 \
        --valid-seed-count 20000 \
        --output data/bmlogic-c11.jsonl \
        --mode stratified \
        --stratified-quotas "10:100000,11:300000" \
        --include-duals
    echo ""
    echo "Completed at: $(date -Iseconds)"
    echo "Output:"
    wc -l data/bmlogic-c11.jsonl
    cat data/bmlogic-c11_metadata.json
    echo ""
}

case "${1:-help}" in
    smoke)
        run_smoke
        ;;
    c5)
        run_c5
        ;;
    c7)
        run_c7
        ;;
    c9)
        run_c9
        ;;
    c11)
        run_c11
        ;;
    all)
        run_c5
        echo ""
        run_c7
        echo ""
        run_c9
        echo ""
        run_c11
        ;;
    help|--help|-h)
        echo "Usage: $0 {smoke|c5|c7|c9|c11|all}"
        echo ""
        echo "  smoke   Quick 20-formula validation run"
        echo "  c5      Complexity 5, exhaustive, ~1.5K formulas (bmlogic-c5.jsonl)"
        echo "  c7      Complexity 7, exhaustive, ~50K formulas (bmlogic-c7.jsonl)"
        echo "  c9      Complexity 9, exhaustive, ~300K-1.8M formulas (bmlogic-c9.jsonl, est. 2-6h)"
        echo "  c11     Complexity 11, stratified, ~500K-2M formulas (bmlogic-c11.jsonl, est. 3-8h)"
        echo "  all     Run all tiers: c5, c7, c9, c11 sequentially"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: $0 {smoke|c5|c7|c9|c11|all}"
        exit 1
        ;;
esac
