#!/usr/bin/env bash
# check-lean-linting.sh - Opencode validator for LEAN 4 linting
# Version: 2.0.0 (revised post-research)
#
# This script integrates Lake's native `lake lint` command with the opencode
# validation framework. It wraps lint execution, parses output, and creates
# opencode-compatible state for error logging and reporting.

set -eo pipefail

# Detect project directory
if command -v git &>/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  PROJECT_DIR="$(git rev-parse --show-toplevel)"
else
  current_dir="$(pwd)"
  while [ "$current_dir" != "/" ]; do
    if [ -d "$current_dir/.claude" ]; then
      PROJECT_DIR="$current_dir"
      break
    fi
    current_dir="$(dirname "$current_dir")"
  done
fi

if [ -z "${PROJECT_DIR:-}" ] || [ ! -d "$PROJECT_DIR/.claude" ]; then
  echo "ERROR: Cannot find project directory with .claude/" >&2
  exit 2
fi

# Configuration
LINT_OUTPUT_DIR="$PROJECT_DIR/.lake"
LINT_STATE_FILE="$PROJECT_DIR/.claude/tmp/lean-lint-state.json"

# Create output directory
mkdir -p "$LINT_OUTPUT_DIR" "$PROJECT_DIR/.claude/tmp"

# Verify lint driver is configured
echo "Verifying lint driver configuration..."
if ! cd "$PROJECT_DIR" && lake check-lint >/dev/null 2>&1; then
  echo "ERROR: No lint driver configured" >&2
  echo "  Run: lake check-lint for details" >&2
  exit 2
fi

# Run lake lint
echo "Running LEAN 4 linting (lake lint)..."

LINT_EXIT_CODE=0
LINT_OUTPUT_FILE="$LINT_OUTPUT_DIR/lint-output.txt"

cd "$PROJECT_DIR" && lake lint "$@" 2>&1 | tee "$LINT_OUTPUT_FILE" || LINT_EXIT_CODE=$?

# Parse results
ERROR_COUNT=0
WARNING_COUNT=0
STYLE_ISSUES=0

if [ -f "$LINT_OUTPUT_FILE" ]; then
  # Count errors and warnings from output
  ERROR_COUNT=$(grep -c "^error:" "$LINT_OUTPUT_FILE" 2>/dev/null || true)
  WARNING_COUNT=$(grep -c "^warning:" "$LINT_OUTPUT_FILE" 2>/dev/null || true)
  # Default to 0 if empty
  ERROR_COUNT=${ERROR_COUNT:-0}
  WARNING_COUNT=${WARNING_COUNT:-0}
  
  # Parse style issues from summary line (e.g., "✗ Found 230 style issues in 18 files")
  if grep -q "Found .* style issues" "$LINT_OUTPUT_FILE" 2>/dev/null; then
    STYLE_ISSUES=$(grep "Found .* style issues" "$LINT_OUTPUT_FILE" | sed -E 's/.*Found ([0-9]+) style issues.*/\1/')
  fi
fi

# Create state file for opencode integration
cat > "$LINT_STATE_FILE" <<EOF
{
  "validator": "lean-linting",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "exit_code": $LINT_EXIT_CODE,
  "errors": $ERROR_COUNT,
  "warnings": $WARNING_COUNT,
  "style_issues": $STYLE_ISSUES,
  "lint_output": "$LINT_OUTPUT_FILE",
  "lake_version": "$(cd "$PROJECT_DIR" && lake --version 2>/dev/null || echo 'unknown')",
  "lean_version": "$(lean --version 2>/dev/null | head -1 || echo 'unknown')"
}
EOF

# Report results
if [ $LINT_EXIT_CODE -ne 0 ]; then
  echo ""
  echo "✗ LEAN 4 linting failed"
  echo "  Errors: $ERROR_COUNT"
  echo "  Warnings: $WARNING_COUNT"
  echo "  Style issues: $STYLE_ISSUES"
  echo ""
  echo "Recent output:"
  tail -30 "$LINT_OUTPUT_FILE"
  echo ""
  echo "Full output: $LINT_OUTPUT_FILE"
  exit 1
else
  echo ""
  echo "✓ LEAN 4 linting passed"
  exit 0
fi
