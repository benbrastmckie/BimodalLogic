#!/usr/bin/env bash
# Run production dataset generation for BMLogic training data.
#
# Usage:
#   ./scripts/run_dataset_generation.sh medium      # Complexity 5, ~5K formulas, 2K axiom seeds
#   ./scripts/run_dataset_generation.sh deep        # Complexity 7, exhaustive, ~50K formulas, 5K seeds
#   ./scripts/run_dataset_generation.sh production  # Complexity 7, exhaustive, ~60K formulas, 5K seeds
#   ./scripts/run_dataset_generation.sh smoke       # Quick validation run (20 formulas)
#   ./scripts/run_dataset_generation.sh all         # Both medium and deep runs
#
# Prerequisites:
#   lake build dataset_generator
#
# Output:
#   data/bmlogic-medium.jsonl + data/bmlogic-medium_metadata.json
#   data/bmlogic-deep.jsonl   + data/bmlogic-deep_metadata.json
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

run_medium() {
    echo "=== Medium Production Run (complexity 5, ~5K formulas) ==="
    echo "Started at: $(date -Iseconds)"
    # Post-task-210: exact-complexity enumeration eliminates blowup at complexity 5.
    time lake exe dataset_generator -- \
        --max-complexity 5 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 5000 \
        --valid-seed-count 2000 \
        --output data/bmlogic-medium.jsonl \
        --include-duals
    echo ""
    echo "Completed at: $(date -Iseconds)"
    echo "Output:"
    wc -l data/bmlogic-medium.jsonl
    cat data/bmlogic-medium_metadata.json
    echo ""
}

run_deep() {
    echo "=== Deep Production Run (complexity 7, exhaustive, ~50K formulas) ==="
    echo "Started at: $(date -Iseconds)"
    # Post-task-210: exact-complexity enumeration enables exhaustive mode at complexity 7.
    time lake exe dataset_generator -- \
        --max-complexity 7 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 50000 \
        --valid-seed-count 5000 \
        --output data/bmlogic-deep.jsonl \
        --mode exhaustive \
        --include-duals
    echo ""
    echo "Completed at: $(date -Iseconds)"
    echo "Output:"
    wc -l data/bmlogic-deep.jsonl
    cat data/bmlogic-deep_metadata.json
    echo ""
}

run_production() {
    echo "=== Production Run (complexity 7, exhaustive, ~60K formulas) ==="
    echo "Started at: $(date -Iseconds)"
    # Full production pipeline: complexity 7, high seed count, duals enabled.
    time lake exe dataset_generator -- \
        --max-complexity 7 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 60000 \
        --valid-seed-count 5000 \
        --output data/bmlogic-production.jsonl \
        --mode exhaustive \
        --include-duals
    echo ""
    echo "Completed at: $(date -Iseconds)"
    echo "Output:"
    wc -l data/bmlogic-production.jsonl
    cat data/bmlogic-production_metadata.json
    echo ""
}

case "${1:-help}" in
    smoke)
        run_smoke
        ;;
    medium)
        run_medium
        ;;
    deep)
        run_deep
        ;;
    production)
        run_production
        ;;
    all)
        run_medium
        echo ""
        run_deep
        ;;
    help|--help|-h)
        echo "Usage: $0 {smoke|medium|deep|production|all}"
        echo ""
        echo "  smoke       Quick 20-formula validation run"
        echo "  medium      Complexity 5, ~5K formulas with temporal duals and 2K axiom seeds"
        echo "  deep        Complexity 7, exhaustive, ~50K formulas with 5K axiom seeds"
        echo "  production  Complexity 7, exhaustive, ~60K formulas with 5K axiom seeds"
        echo "  all         Run both medium and deep sequentially"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: $0 {smoke|medium|deep|production|all}"
        exit 1
        ;;
esac
