#!/usr/bin/env bash
# Export training data from BimodalLogic for sync to BimodalHarness.
#
# Usage:
#   ./scripts/export-training-data.sh [OPTIONS] [TIER]
#
# Arguments:
#   TIER    Dataset tier to generate: c5 (default), c7, all
#           Ignored when --skip-dataset is set.
#
# Options:
#   --dry-run        Print commands without executing
#   --skip-dataset   Skip dataset_generator; only run proof_extractor
#   --skip-proofs    Skip proof_extractor; only run dataset_generator
#   -h, --help       Show this help message
#
# Shared `.lake` lock:
#   Before generating, the script rebuilds the binaries it is about to run under
#   the shared build lock (`.lake/build-guard.lock`), inside a subshell, and
#   releases the lock when that subshell exits. It does not hold the lock for the
#   run: an export lasts hours and a held lock would starve every guarded build.
#   The `lake exe` calls run outside the lock by design. See `locked_prebuild`.
#
# Output:
#   data/bmlogic-{TIER}.jsonl     Dataset for specified tier
#   data/bmlogic-{TIER}_metadata.json
#   data/proof_steps.jsonl        All proof steps (10K+ entries)
#   data/proof_steps_metadata.json
#   data/VERSION                  Schema version, git commit, export timestamp
#
# Schema gap notice:
#   proof_extractor emits 8 fields per step; BimodalHarness load_proof_steps()
#   expects 12 fields. A Python-side adapter in BimodalHarness is required.
#   See the training-pipeline sync protocol (internal, not part of the tracked deliverable).
#
# Examples:
#   ./scripts/export-training-data.sh c5                # Export c5 dataset + proofs
#   ./scripts/export-training-data.sh --dry-run c5      # Print commands, no execution
#   ./scripts/export-training-data.sh --skip-dataset    # Only update proof_steps.jsonl
#   ./scripts/export-training-data.sh --skip-proofs c7  # Only update c7 dataset
#   ./scripts/export-training-data.sh all               # Export all tiers + proofs

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# --- Defaults ---

DRY_RUN=false
SKIP_DATASET=false
SKIP_PROOFS=false
TIER="c5"

# Track partial output files for cleanup on interruption
PARTIAL_FILES=()

# --- Signal handling and cleanup ---

cleanup() {
    local exit_code=$?
    if [ ${#PARTIAL_FILES[@]} -gt 0 ] && [ "$exit_code" -ne 0 ]; then
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
    local dataset_gen="$PROJECT_ROOT/.lake/build/bin/dataset_generator"
    local proof_ext="$PROJECT_ROOT/.lake/build/bin/proof_extractor"
    local missing=false

    if [ "$SKIP_DATASET" = false ] && [ ! -x "$dataset_gen" ]; then
        echo "ERROR: dataset_generator binary not found at $dataset_gen"
        missing=true
    fi
    if [ "$SKIP_PROOFS" = false ] && [ ! -x "$proof_ext" ]; then
        echo "ERROR: proof_extractor binary not found at $proof_ext"
        missing=true
    fi
    if [ "$missing" = true ]; then
        echo "Run: lake build dataset_generator proof_extractor"
        exit 1
    fi
}

# --- Scoped locked prebuild ---
#
# `lake exe` rebuilds its target implicitly whenever a source is stale, and that
# rebuild WRITES `.lake` with no lock: a scoped build of this kind is what leaves
# an import-closure olean removed-and-not-yet-rewritten under a concurrent
# reader, which then fails with `object file '...' of module ... does not exist`.
# So the rebuild is done here, explicitly, under the shared build lock, and the
# `lake exe` calls that follow find their targets fresh.
#
# The lock is `$PROJECT_ROOT/.lake/build-guard.lock`, the path
# `.claude/scripts/lake-build-guard.sh` publishes, taken exclusively in the same
# acquisition shape as scripts/check-evidence-probes.sh's `SHARED .lake LOCK`
# block and scripts/check-module-invariants.sh's `C1: build` block (non-blocking
# try, announced bounded wait, audible unserialized run when `flock` is absent);
# the alternatives those blocks reject are recorded at `C1: build`.
#
# SUBSHELL-SCOPED, NOT HELD TO EXIT. Those two scripts hold the lock until the
# process exits. This script must not: a generation run lasts hours, and a lock
# held that long would starve every guarded build on the tree. The lock fd is
# therefore opened INSIDE the subshell and closes when the subshell exits; there
# is no `flock -u`. The `lake exe` calls are deliberately left outside the lock:
# with the targets just built they have nothing to rebuild, and a build that
# changes the sources mid-run is outside what an advisory lock can cover.
#
# LEAF-ONLY. The lock is taken here and by no caller of this script: a parent
# that held it would exclude this subshell for the whole bound.
#
# `DATASET_LOCK_WAIT_S` overrides the bounded wait (default 600 s). It exists so
# the timeout branch can be exercised deliberately; it is a test affordance.
#
# Exit status: 1 on lock timeout (an ENVIRONMENT failure) and 1 on a failed
# prebuild, each with its own message.

locked_prebuild() {
    # $@ = lake targets to build
    local lock_wait="${DATASET_LOCK_WAIT_S:-600}"
    local lock_file="$PROJECT_ROOT/.lake/build-guard.lock"
    local rc=0
    (
        mkdir -p "$PROJECT_ROOT/.lake"
        if command -v flock >/dev/null 2>&1; then
            exec {PREBUILD_LOCK_FD}<>"$lock_file"
            if ! flock -n "$PREBUILD_LOCK_FD"; then
                echo "export-training-data.sh: waiting on the shared build lock ($lock_file, up to ${lock_wait}s)" >&2
                if ! flock -w "$lock_wait" "$PREBUILD_LOCK_FD"; then
                    exit 75
                fi
            fi
        else
            echo "export-training-data.sh: flock not found on PATH; prebuilding unserialized" >&2
        fi
        lake build "$@" || exit 1
        exit 0
    ) || rc=$?
    case "$rc" in
        0) ;;
        75)
            echo "ERROR (environment): timed out after ${lock_wait}s waiting for the shared build lock" >&2
            echo "  $lock_file" >&2
            echo "  Nothing was built or generated. Re-run once the concurrent build has finished." >&2
            exit 1
            ;;
        *)
            echo "ERROR: prebuild failed: lake build $*" >&2
            exit 1
            ;;
    esac
}

# --- Dry-run wrapper ---

run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

# --- Validation ---

validate_jsonl() {
    local jsonl_file="$1"
    local label="${2:-$jsonl_file}"

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

    # Check first and last line are valid JSON
    if ! head -1 "$jsonl_file" | python3 -m json.tool > /dev/null 2>&1; then
        echo "  WARNING: First line of $jsonl_file is not valid JSON"
        return 1
    fi
    if ! tail -1 "$jsonl_file" | python3 -m json.tool > /dev/null 2>&1; then
        echo "  WARNING: Last line of $jsonl_file is not valid JSON"
        return 1
    fi

    echo "  Validation passed ($label): $lines lines, first/last lines are valid JSON"
    return 0
}

# --- Write VERSION file ---

write_version_file() {
    local tier="${1:-}"
    local proof_steps_count=0

    if [ -f "data/proof_steps.jsonl" ]; then
        proof_steps_count=$(wc -l < "data/proof_steps.jsonl")
    fi

    local lean_version
    lean_version=$(cat "$PROJECT_ROOT/lean-toolchain" 2>/dev/null | sed 's|leanprover/lean4:||' || echo "unknown")

    local git_commit
    git_commit=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")

    local export_date
    export_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] write data/VERSION:"
        echo "[dry-run]   SCHEMA_VERSION=1"
        echo "[dry-run]   LEAN_VERSION=$lean_version"
        echo "[dry-run]   EXPORT_DATE=$export_date"
        echo "[dry-run]   GIT_COMMIT=$git_commit"
        echo "[dry-run]   DATASET_TIERS=${tier:-none}"
        echo "[dry-run]   PROOF_STEPS_COUNT=$proof_steps_count"
        return
    fi

    mkdir -p data
    cat > data/VERSION << EOF
SCHEMA_VERSION=1
LEAN_VERSION=${lean_version}
EXPORT_DATE=${export_date}
GIT_COMMIT=${git_commit}
DATASET_TIERS=${tier:-none}
PROOF_STEPS_COUNT=${proof_steps_count}
EOF
    echo "  Wrote data/VERSION (schema v1, commit $git_commit)"
}

# --- Run dataset_generator ---

run_dataset_tier() {
    local t="$1"
    local output_file="data/bmlogic-${t}.jsonl"

    case "$t" in
        c5)
            echo "=== Dataset C5 (complexity 5, exhaustive, ~1.5K formulas) ==="
            echo "Started at: $(date -Iseconds)"
            PARTIAL_FILES+=("$output_file")
            run_cmd lake exe dataset_generator -- \
                --max-complexity 5 \
                --max-modal-depth 2 \
                --max-temporal-depth 2 \
                --valid-seed-count 2000 \
                --output "$output_file" \
                --mode exhaustive \
                --include-duals
            ;;
        c7)
            echo "=== Dataset C7 (complexity 7, exhaustive, ~50K formulas) ==="
            echo "Started at: $(date -Iseconds)"
            PARTIAL_FILES+=("$output_file")
            run_cmd lake exe dataset_generator -- \
                --max-complexity 7 \
                --max-modal-depth 2 \
                --max-temporal-depth 2 \
                --max-formulas 50000 \
                --valid-seed-count 5000 \
                --output "$output_file" \
                --mode exhaustive \
                --include-duals
            ;;
        *)
            echo "ERROR: Unknown dataset tier '$t'. Supported: c5, c7"
            exit 1
            ;;
    esac

    if [ "$DRY_RUN" = false ]; then
        echo "Completed at: $(date -Iseconds)"
        validate_jsonl "$output_file" "bmlogic-${t}.jsonl"
        # Remove from partial list on success
        PARTIAL_FILES=("${PARTIAL_FILES[@]/"$output_file"/}")
    fi
}

run_dataset() {
    local t="$1"
    mkdir -p data

    if [ "$t" = "all" ]; then
        run_dataset_tier c5
        echo ""
        run_dataset_tier c7
    else
        run_dataset_tier "$t"
    fi
}

# --- Run proof_extractor ---

run_proofs() {
    echo "=== Proof Steps Extraction ==="
    echo "Started at: $(date -Iseconds)"
    PARTIAL_FILES+=("data/proof_steps.jsonl")
    mkdir -p data

    run_cmd lake exe proof_extractor

    if [ "$DRY_RUN" = false ]; then
        echo "Completed at: $(date -Iseconds)"
        validate_jsonl "data/proof_steps.jsonl" "proof_steps.jsonl"
        PARTIAL_FILES=("${PARTIAL_FILES[@]/data\/proof_steps.jsonl/}")
        if [ -f "data/proof_steps_metadata.json" ]; then
            if python3 -m json.tool < "data/proof_steps_metadata.json" > /dev/null 2>&1; then
                echo "  Metadata file valid: data/proof_steps_metadata.json"
            else
                echo "  WARNING: data/proof_steps_metadata.json is not valid JSON"
            fi
        fi
    fi
}

# --- Argument parsing ---

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --skip-dataset)
            SKIP_DATASET=true
            shift
            ;;
        --skip-proofs)
            SKIP_PROOFS=true
            shift
            ;;
        -h|--help)
            head -30 "$0" | grep '^#' | sed 's/^# \?//'
            exit 0
            ;;
        c5|c7|all)
            TIER="$1"
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            echo "Usage: $0 [--dry-run] [--skip-dataset] [--skip-proofs] [c5|c7|all]"
            exit 1
            ;;
    esac
done

# Build binaries if not dry-run and they are missing
if [ "$DRY_RUN" = false ]; then
    check_prereqs
else
    echo "[dry-run] Would check prerequisites: dataset_generator, proof_extractor"
fi

# Rebuild exactly the binaries this run will execute, under the shared build
# lock, after the missing-binary check above so that check's contract is
# unchanged. Nothing to prebuild when both halves are skipped.
PREBUILD_TARGETS=()
[ "$SKIP_DATASET" = false ] && PREBUILD_TARGETS+=(dataset_generator)
[ "$SKIP_PROOFS" = false ] && PREBUILD_TARGETS+=(proof_extractor)
if [ ${#PREBUILD_TARGETS[@]} -gt 0 ]; then
    if [ "$DRY_RUN" = true ]; then
        echo "[dry-run] lake build ${PREBUILD_TARGETS[*]} (under the shared .lake build lock, released before generation)"
    else
        locked_prebuild "${PREBUILD_TARGETS[@]}"
    fi
fi

# --- Execute ---

echo "=== BimodalLogic Training Data Export ==="
echo "  Tier:          $TIER"
echo "  Skip dataset:  $SKIP_DATASET"
echo "  Skip proofs:   $SKIP_PROOFS"
echo "  Dry run:       $DRY_RUN"
echo ""

if [ "$SKIP_DATASET" = false ]; then
    run_dataset "$TIER"
    echo ""
fi

if [ "$SKIP_PROOFS" = false ]; then
    run_proofs
    echo ""
fi

# Write VERSION file (reflects current state of data/)
write_version_file "$TIER"
echo ""

echo "=== Export complete ==="
if [ "$DRY_RUN" = false ]; then
    echo "  data/VERSION and JSONL files are ready for sync to BimodalHarness."
    echo "  See the training-pipeline sync protocol (internal, not part of the tracked deliverable) for sync instructions."
fi
