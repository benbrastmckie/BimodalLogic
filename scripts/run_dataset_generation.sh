#!/usr/bin/env bash
# Run production dataset generation for BMLogic training data.
#
# Usage:
#   ./scripts/run_dataset_generation.sh c5          # Complexity 5, exhaustive, ~1.5K formulas
#   ./scripts/run_dataset_generation.sh c7          # Complexity 7, exhaustive, ~50K formulas
#   ./scripts/run_dataset_generation.sh c9          # Complexity 9, exhaustive, ~300K-1.8M formulas (30min-2h)
#   ./scripts/run_dataset_generation.sh c11         # Complexity 11, stratified, ~500K-2M formulas (1-4h)
#   ./scripts/run_dataset_generation.sh smoke       # Quick validation run (20 formulas)
#   ./scripts/run_dataset_generation.sh all         # All tiers: c5, c7, c9, c11
#   ./scripts/run_dataset_generation.sh --dry-run c5  # Print commands without executing
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

DRY_RUN=false
# Track partial output files for cleanup on interruption
PARTIAL_FILES=()

# --- Signal handling and cleanup ---

cleanup() {
    local exit_code=$?
    if [ ${#PARTIAL_FILES[@]} -gt 0 ] && [ $exit_code -ne 0 ]; then
        echo ""
        echo "=== Interrupted (exit code $exit_code) ==="
        for f in "${PARTIAL_FILES[@]}"; do
            if [ -f "$f" ]; then
                local lines
                lines=$(wc -l < "$f" 2>/dev/null || echo "0")
                echo "  Partial output: $f ($lines lines)"
            fi
        done
        echo "  Partial files preserved for inspection. Remove manually if not needed."
    fi
}

trap cleanup EXIT INT TERM

# --- Prerequisite checking ---

check_prereqs() {
    local generator="$PROJECT_ROOT/.lake/build/bin/dataset_generator"
    if [ ! -x "$generator" ]; then
        echo "ERROR: dataset_generator binary not found at $generator"
        echo "Run 'lake build dataset_generator' first."
        exit 1
    fi
}

# --- Post-run validation ---

validate_output() {
    local jsonl_file="$1"
    local meta_file="${jsonl_file%.jsonl}_metadata.json"

    if [ ! -f "$jsonl_file" ]; then
        echo "  WARNING: Output file $jsonl_file does not exist"
        return 1
    fi

    local lines
    lines=$(wc -l < "$jsonl_file")
    if [ "$lines" -eq 0 ]; then
        echo "  WARNING: Output file $jsonl_file is empty"
        return 1
    fi

    # Check first line is valid JSON
    if ! head -1 "$jsonl_file" | python3 -m json.tool > /dev/null 2>&1; then
        echo "  WARNING: First line of $jsonl_file is not valid JSON"
        return 1
    fi

    # Check last line is valid JSON
    if ! tail -1 "$jsonl_file" | python3 -m json.tool > /dev/null 2>&1; then
        echo "  WARNING: Last line of $jsonl_file is not valid JSON"
        return 1
    fi

    if [ -f "$meta_file" ]; then
        if ! python3 -m json.tool < "$meta_file" > /dev/null 2>&1; then
            echo "  WARNING: Metadata file $meta_file is not valid JSON"
            return 1
        fi
    fi

    echo "  Validation passed: $lines lines, first/last lines are valid JSON"
    return 0
}

# --- Dry-run wrapper ---

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

# --- Run functions ---

# Ensure data directory exists
mkdir -p data

run_smoke() {
    echo "=== Smoke Test (complexity 3, 20 formulas) ==="
    PARTIAL_FILES+=("data/smoke-test.jsonl")
    run_cmd lake exe dataset_generator -- \
        --max-complexity 3 \
        --max-formulas 20 \
        --output data/smoke-test.jsonl
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Smoke test output:"
        wc -l data/smoke-test.jsonl
        cat data/smoke-test_metadata.json
        echo ""
        validate_output data/smoke-test.jsonl
        # Clean up
        rm -f data/smoke-test.jsonl data/smoke-test_metadata.json
        echo "Smoke test files cleaned up."
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/smoke-test.jsonl/}")
}

run_c5() {
    echo "=== C5 Production Run (complexity 5, exhaustive, ~1.5K formulas) ==="
    echo "Started at: $(date -Iseconds)"
    PARTIAL_FILES+=("data/bmlogic-c5.jsonl")
    # Exhaustive enumeration of all complexity-5 bimodal formulas with duals.
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 5 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --valid-seed-count 2000 \
        --output data/bmlogic-c5.jsonl \
        --mode exhaustive \
        --include-duals
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l data/bmlogic-c5.jsonl
        cat data/bmlogic-c5_metadata.json
        echo ""
        validate_output data/bmlogic-c5.jsonl
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c5.jsonl/}")
}

run_c7() {
    echo "=== C7 Production Run (complexity 7, exhaustive, ~50K formulas) ==="
    echo "Started at: $(date -Iseconds)"
    PARTIAL_FILES+=("data/bmlogic-c7.jsonl")
    # Exhaustive enumeration of all complexity-7 bimodal formulas with duals.
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 7 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 50000 \
        --valid-seed-count 5000 \
        --output data/bmlogic-c7.jsonl \
        --mode exhaustive \
        --include-duals
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l data/bmlogic-c7.jsonl
        cat data/bmlogic-c7_metadata.json
        echo ""
        validate_output data/bmlogic-c7.jsonl
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c7.jsonl/}")
}

run_c9() {
    echo "=== C9 Production Run (complexity 9, exhaustive, ~300K-1.8M formulas, est. 30min-2h) ==="
    echo "Started at: $(date -Iseconds)"
    PARTIAL_FILES+=("data/bmlogic-c9.jsonl")
    # Exhaustive enumeration of all complexity-9 bimodal formulas with duals.
    # Capped at 2M formulas as a safety limit.
    # NOTE: Task 251 optimized generateValidBatch from O(n^2) to O(n) MP closure
    # using HashMap-based implication index and HashSet pool. 5000 seeds is now
    # feasible (pool cap is 10K; 5K seeds provide good valid enrichment).
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 9 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 2000000 \
        --valid-seed-count 5000 \
        --output data/bmlogic-c9.jsonl \
        --mode exhaustive \
        --include-duals
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l data/bmlogic-c9.jsonl
        cat data/bmlogic-c9_metadata.json
        echo ""
        validate_output data/bmlogic-c9.jsonl
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c9.jsonl/}")
}

run_c11() {
    echo "=== C11 Production Run (complexity 11, stratified, ~500K-2M formulas, est. 1-4h) ==="
    echo "Started at: $(date -Iseconds)"
    PARTIAL_FILES+=("data/bmlogic-c11.jsonl")
    # Stratified enumeration: exhaustive up to c9, sampled at c10/c11.
    # Quotas: c10 = 100K samples, c11 = 300K samples (0 = exhaustive for c1-c9).
    # NOTE: Task 251 optimized generateValidBatch from O(n^2) to O(n) MP closure.
    # 10000 seeds is now feasible with HashMap-based implication index; provides
    # strong valid enrichment for the larger c11 formula pool.
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 11 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 2000000 \
        --valid-seed-count 10000 \
        --output data/bmlogic-c11.jsonl \
        --mode stratified \
        --stratified-quotas "10:100000,11:300000" \
        --include-duals
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l data/bmlogic-c11.jsonl
        cat data/bmlogic-c11_metadata.json
        echo ""
        validate_output data/bmlogic-c11.jsonl
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c11.jsonl/}")
}

# --- Argument parsing ---

# Check for --dry-run flag
if [ "${1:-}" = "--dry-run" ]; then
    DRY_RUN=true
    shift
fi

# Check prerequisites (unless dry-run)
if [ "$DRY_RUN" = false ]; then
    check_prereqs
fi

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
        echo "Usage: $0 [--dry-run] {smoke|c5|c7|c9|c11|all}"
        echo ""
        echo "Options:"
        echo "  --dry-run  Print commands without executing"
        echo ""
        echo "Commands:"
        echo "  smoke   Quick 20-formula validation run"
        echo "  c5      Complexity 5, exhaustive, ~1.5K formulas (bmlogic-c5.jsonl)"
        echo "  c7      Complexity 7, exhaustive, ~50K formulas (bmlogic-c7.jsonl)"
        echo "  c9      Complexity 9, exhaustive, ~300K-1.8M formulas (bmlogic-c9.jsonl, est. 30min-2h)"
        echo "  c11     Complexity 11, stratified, ~500K-2M formulas (bmlogic-c11.jsonl, est. 1-4h)"
        echo "  all     Run all tiers: c5, c7, c9, c11 sequentially"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: $0 [--dry-run] {smoke|c5|c7|c9|c11|all}"
        exit 1
        ;;
esac
