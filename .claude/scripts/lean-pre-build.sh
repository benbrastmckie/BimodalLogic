#!/usr/bin/env bash
# Lean Pre-Build Script
# Runs lake build to warm LSP cache before /implement execution
# Exit code 0 always (non-blocking)
#
# Official lean-lsp-mcp recommendation:
# "It is recommended to run lake build manually before starting the MCP.
#  This ensures a faster build time and avoids timeouts."
# Source: https://github.com/oOo0oOo/lean-lsp-mcp

set -euo pipefail

# Configuration
TIMEOUT_SECS=120
VERBOSE=false
FORCE=false
LOG_FILE=".claude/logs/lean-pre-build.log"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --timeout)
            TIMEOUT_SECS="$2"
            shift 2
            ;;
        --verbose)
            VERBOSE=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Logging function
log() {
    local msg="[$(date -Iseconds)] $1"
    echo "$msg"
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "$msg" >> "$LOG_FILE"
}

# Change to project root
cd "$(git rev-parse --show-toplevel)" || {
    log "ERROR: Not in git repository"
    exit 0  # Non-blocking
}

# Check if lake is available
if ! command -v lake &> /dev/null; then
    log "WARNING: lake command not found, skipping pre-build"
    exit 0  # Non-blocking
fi

# Optionally clean before build
if [ "$FORCE" = true ]; then
    log "Running lake clean (--force mode)..."
    lake clean 2>&1 | tee -a "$LOG_FILE" || true
fi

# Run lake build with timeout
log "Running lake build (timeout: ${TIMEOUT_SECS}s)..."
START_TIME=$(date +%s)

timeout "${TIMEOUT_SECS}s" lake build 2>&1 | tee -a "$LOG_FILE" || {
    EXIT_CODE=$?
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    if [ $EXIT_CODE -eq 124 ]; then
        log "WARNING: Pre-build timed out after ${DURATION}s (non-fatal)"
    else
        log "WARNING: Pre-build failed with exit code $EXIT_CODE after ${DURATION}s (non-fatal)"
    fi
}

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log "Pre-build completed in ${DURATION}s"

exit 0  # Always succeed (non-blocking)
