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
# Resume support:
#   If a previous run was interrupted, partial output files are preserved. On the
#   next run, the script detects partial output and prompts to resume or restart.
#   Resume loads the formula list from a checkpoint file to ensure deterministic
#   ordering, then skips already-labeled formulas and appends new results.
#
#   ./scripts/run_dataset_generation.sh --resume c9    # Always resume (no prompt)
#   ./scripts/run_dataset_generation.sh --no-resume c9 # Always restart fresh (no prompt)
#
# Progress output:
#   The generator emits periodic progress lines to stdout with [tag] prefixes:
#     [gen]   - Overall generation phase start/end timing
#     [enum]  - Per-complexity-level enumeration progress (count, rate, elapsed)
#     [valid] - Axiom seeding (every 10%) and Nec/MP closure round stats
#     [label] - Labeling progress every 1000 formulas (rate, ETA, valid/timeout %)
#   Use grep to filter: ./scripts/run_dataset_generation.sh c5 2>&1 | grep '^\[label\]'
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
# Resume mode: "auto" (prompt), "always" (--resume), "never" (--no-resume)
RESUME_MODE="auto"
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
                local checkpoint="${f%.jsonl}.checkpoint"
                if [ -f "$checkpoint" ]; then
                    echo "  Checkpoint file: $checkpoint (for deterministic resume)"
                fi
            fi
        done
        echo "  Re-run the same command to resume from where it left off."
        echo "  Use --no-resume to start fresh instead."
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

# --- Resume detection ---

# Validate the last line of a JSONL file is valid JSON.
# If invalid, truncate the last line and return the adjusted line count.
# Args: $1 = jsonl file path
# Sets: VALIDATED_LINES = line count after validation/truncation
validate_last_line() {
    local jsonl_file="$1"
    local lines
    lines=$(wc -l < "$jsonl_file" 2>/dev/null || echo "0")

    if [ "$lines" -eq 0 ]; then
        VALIDATED_LINES=0
        return
    fi

    # Check if last line is valid JSON
    if tail -1 "$jsonl_file" | python3 -m json.tool > /dev/null 2>&1; then
        VALIDATED_LINES="$lines"
    else
        echo "  WARNING: Last line of $jsonl_file is not valid JSON (likely interrupted mid-write)"
        if [ "$DRY_RUN" = true ]; then
            echo "  [dry-run] Would truncate last line for clean resume"
            VALIDATED_LINES=$((lines - 1))
        else
            echo "  Truncating last line for clean resume..."
            # Remove the last line (corrupt partial write)
            head -n $((lines - 1)) "$jsonl_file" > "${jsonl_file}.tmp"
            mv "${jsonl_file}.tmp" "$jsonl_file"
            VALIDATED_LINES=$((lines - 1))
            echo "  Truncated to $VALIDATED_LINES valid lines"
        fi
    fi
}

# Detect partial output and determine resume parameters.
# Args: $1 = output jsonl file path
# Sets: RESUME_FROM = number of lines to skip (0 = fresh start)
#        RESUME_FLAGS = extra flags to pass to the generator
detect_resume() {
    local output_file="$1"
    local checkpoint_file="${output_file%.jsonl}.checkpoint"
    RESUME_FROM=0
    RESUME_FLAGS=""

    # No partial file = fresh start
    if [ ! -f "$output_file" ] || [ ! -s "$output_file" ]; then
        return
    fi

    # Validate and get line count
    validate_last_line "$output_file"
    local line_count="$VALIDATED_LINES"

    if [ "$line_count" -eq 0 ]; then
        # Empty or fully truncated -- treat as fresh start
        if [ "$DRY_RUN" = false ]; then
            rm -f "$output_file"
        fi
        return
    fi

    # We have partial output -- decide what to do based on RESUME_MODE
    case "$RESUME_MODE" in
        always)
            echo "  Resuming from line $line_count (--resume mode)"
            RESUME_FROM="$line_count"
            ;;
        never)
            if [ "$DRY_RUN" = true ]; then
                echo "  [dry-run] Would remove partial output and start fresh (--no-resume mode)"
            else
                echo "  Removing partial output and starting fresh (--no-resume mode)"
                rm -f "$output_file" "$checkpoint_file"
            fi
            return
            ;;
        auto)
            echo ""
            echo "  Found partial output: $output_file ($line_count lines)"
            if [ -f "$checkpoint_file" ]; then
                echo "  Checkpoint file found: $checkpoint_file (deterministic resume available)"
            else
                echo "  WARNING: No checkpoint file found -- resume will re-enumerate formulas"
            fi
            # In dry-run mode or non-interactive, default to resume
            if [ "$DRY_RUN" = true ]; then
                echo "  [dry-run] Would prompt to resume from line $line_count"
                RESUME_FROM="$line_count"
            elif [ -t 0 ]; then
                echo ""
                read -r -p "  Resume from line $line_count? [Y/n/restart] " response
                case "${response,,}" in
                    n|no|restart)
                        echo "  Starting fresh..."
                        if [ "$DRY_RUN" = false ]; then
                            rm -f "$output_file" "$checkpoint_file"
                        fi
                        return
                        ;;
                    *)
                        echo "  Resuming from line $line_count"
                        RESUME_FROM="$line_count"
                        ;;
                esac
            else
                # Non-interactive: default to resume
                echo "  Non-interactive mode: resuming from line $line_count (use --no-resume to start fresh)"
                RESUME_FROM="$line_count"
            fi
            ;;
    esac

    # Build resume flags
    RESUME_FLAGS="--resume-from $RESUME_FROM"
    if [ -f "$checkpoint_file" ]; then
        RESUME_FLAGS="$RESUME_FLAGS --use-checkpoint --checkpoint-file $checkpoint_file"
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

# Clean up checkpoint file after successful completion
cleanup_checkpoint() {
    local output_file="$1"
    local checkpoint_file="${output_file%.jsonl}.checkpoint"
    if [ -f "$checkpoint_file" ]; then
        rm -f "$checkpoint_file"
        echo "  Cleaned up checkpoint file: $checkpoint_file"
    fi
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
        rm -f data/smoke-test.jsonl data/smoke-test_metadata.json data/smoke-test.checkpoint
        echo "Smoke test files cleaned up."
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/smoke-test.jsonl/}")
}

run_c5() {
    local output_file="data/bmlogic-c5.jsonl"
    echo "=== C5 Production Run (complexity 5, exhaustive, ~1.5K formulas) ==="
    echo "Started at: $(date -Iseconds)"

    # Check for resume
    detect_resume "$output_file"
    PARTIAL_FILES+=("$output_file")

    # Exhaustive enumeration of all complexity-5 bimodal formulas with duals.
    # shellcheck disable=SC2086
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 5 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --valid-seed-count 2000 \
        --output "$output_file" \
        --mode exhaustive \
        --include-duals \
        $RESUME_FLAGS
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l "$output_file"
        cat data/bmlogic-c5_metadata.json
        echo ""
        validate_output "$output_file"
        cleanup_checkpoint "$output_file"
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c5.jsonl/}")
}

run_c7() {
    local output_file="data/bmlogic-c7.jsonl"
    echo "=== C7 Production Run (complexity 7, exhaustive, ~50K formulas) ==="
    echo "Started at: $(date -Iseconds)"

    # Check for resume
    detect_resume "$output_file"
    PARTIAL_FILES+=("$output_file")

    # Exhaustive enumeration of all complexity-7 bimodal formulas with duals.
    # shellcheck disable=SC2086
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 7 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 50000 \
        --valid-seed-count 5000 \
        --output "$output_file" \
        --mode exhaustive \
        --include-duals \
        $RESUME_FLAGS
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l "$output_file"
        cat data/bmlogic-c7_metadata.json
        echo ""
        validate_output "$output_file"
        cleanup_checkpoint "$output_file"
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c7.jsonl/}")
}

run_c9() {
    local output_file="data/bmlogic-c9.jsonl"
    echo "=== C9 Production Run (complexity 9, exhaustive, ~300K-1.8M formulas, est. 30min-2h) ==="
    echo "Started at: $(date -Iseconds)"

    # Check for resume
    detect_resume "$output_file"
    PARTIAL_FILES+=("$output_file")

    # Exhaustive enumeration of all complexity-9 bimodal formulas with duals.
    # Capped at 2M formulas as a safety limit.
    # NOTE: Task 251 optimized generateValidBatch from O(n^2) to O(n) MP closure
    # using HashMap-based implication index and HashSet pool. 5000 seeds is now
    # feasible (pool cap is 10K; 5K seeds provide good valid enrichment).
    # shellcheck disable=SC2086
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 9 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 2000000 \
        --valid-seed-count 5000 \
        --output "$output_file" \
        --mode exhaustive \
        --include-duals \
        $RESUME_FLAGS
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l "$output_file"
        cat data/bmlogic-c9_metadata.json
        echo ""
        validate_output "$output_file"
        cleanup_checkpoint "$output_file"
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c9.jsonl/}")
}

run_c11() {
    local output_file="data/bmlogic-c11.jsonl"
    echo "=== C11 Production Run (complexity 11, stratified, ~500K-2M formulas, est. 1-4h) ==="
    echo "Started at: $(date -Iseconds)"

    # Check for resume
    detect_resume "$output_file"
    PARTIAL_FILES+=("$output_file")

    # Stratified enumeration: exhaustive up to c9, sampled at c10/c11.
    # Quotas: c10 = 100K samples, c11 = 300K samples (0 = exhaustive for c1-c9).
    # NOTE: Task 251 optimized generateValidBatch from O(n^2) to O(n) MP closure.
    # 10000 seeds is now feasible with HashMap-based implication index; provides
    # strong valid enrichment for the larger c11 formula pool.
    # shellcheck disable=SC2086
    run_cmd time lake exe dataset_generator -- \
        --max-complexity 11 \
        --max-modal-depth 2 \
        --max-temporal-depth 2 \
        --max-formulas 2000000 \
        --valid-seed-count 10000 \
        --output "$output_file" \
        --mode stratified \
        --stratified-quotas "10:100000,11:300000" \
        --include-duals \
        $RESUME_FLAGS
    if [ "$DRY_RUN" = false ]; then
        echo ""
        echo "Completed at: $(date -Iseconds)"
        echo "Output:"
        wc -l "$output_file"
        cat data/bmlogic-c11_metadata.json
        echo ""
        validate_output "$output_file"
        cleanup_checkpoint "$output_file"
    fi
    PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/bmlogic-c11.jsonl/}")
}

# --- Argument parsing ---

# Parse flags before the command
while [ $# -gt 0 ]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --resume)
            RESUME_MODE="always"
            shift
            ;;
        --no-resume)
            RESUME_MODE="never"
            shift
            ;;
        *)
            break
            ;;
    esac
done

# Initialize RESUME_FLAGS for dry-run or no-partial cases
RESUME_FLAGS=""

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
        echo "Usage: $0 [--dry-run] [--resume|--no-resume] {smoke|c5|c7|c9|c11|all}"
        echo ""
        echo "Options:"
        echo "  --dry-run    Print commands without executing"
        echo "  --resume     Always resume from partial output (no prompt)"
        echo "  --no-resume  Always start fresh, removing partial output (no prompt)"
        echo ""
        echo "Commands:"
        echo "  smoke   Quick 20-formula validation run"
        echo "  c5      Complexity 5, exhaustive, ~1.5K formulas (bmlogic-c5.jsonl)"
        echo "  c7      Complexity 7, exhaustive, ~50K formulas (bmlogic-c7.jsonl)"
        echo "  c9      Complexity 9, exhaustive, ~300K-1.8M formulas (bmlogic-c9.jsonl, est. 30min-2h)"
        echo "  c11     Complexity 11, stratified, ~500K-2M formulas (bmlogic-c11.jsonl, est. 1-4h)"
        echo "  all     Run all tiers: c5, c7, c9, c11 sequentially"
        echo ""
        echo "Resume behavior:"
        echo "  If a run is interrupted (Ctrl+C), partial output and checkpoint files"
        echo "  are preserved. On the next run, the script detects partial output and:"
        echo "    - Validates the last JSONL line (truncates if corrupt)"
        echo "    - Prompts to resume or restart (unless --resume/--no-resume is set)"
        echo "    - Uses the checkpoint file for deterministic formula ordering"
        echo "    - Skips already-labeled formulas and appends new results"
        echo ""
        echo "Progress output:"
        echo "  The generator emits progress lines with [tag] prefixes:"
        echo "    [gen]   Overall generation phase timing"
        echo "    [enum]  Per-complexity-level enumeration (count, rate, elapsed)"
        echo "    [valid] Axiom seeding and Nec/MP closure round stats"
        echo "    [label] Labeling progress (rate, ETA, valid/timeout %)"
        exit 0
        ;;
    *)
        echo "Unknown command: $1"
        echo "Usage: $0 [--dry-run] [--resume|--no-resume] {smoke|c5|c7|c9|c11|all}"
        exit 1
        ;;
esac
