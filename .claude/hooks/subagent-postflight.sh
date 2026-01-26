#!/bin/bash
# SubagentStop hook to prevent premature workflow termination
# Called when a subagent session is about to stop
#
# Purpose: Force continuation when postflight operations are pending
# This prevents the "continue" prompt issue between skill return and orchestrator postflight
#
# Returns:
#   {"decision": "block", "reason": "..."} - Prevents stop, forces continuation
#   {} - Allows normal stop

MARKER_FILE="specs/.postflight-pending"
LOOP_GUARD_FILE="specs/.postflight-loop-guard"
MAX_CONTINUATIONS=3
MAX_MARKER_AGE_SECS=300  # 5 minutes - marker older than this indicates deadlock

# Log function for debugging
log_debug() {
    local LOG_DIR=".claude/logs"
    local LOG_FILE="$LOG_DIR/subagent-postflight.log"
    mkdir -p "$LOG_DIR"
    echo "[$(date -Iseconds)] $1" >> "$LOG_FILE"
}

# Check if marker is too old (indicates deadlock/stuck session)
check_marker_age() {
    if [ ! -f "$MARKER_FILE" ]; then
        return 0  # No marker, no age issue
    fi

    # Try to get created timestamp from marker JSON
    local created=$(jq -r '.created // ""' "$MARKER_FILE" 2>/dev/null)
    if [ -z "$created" ]; then
        # No timestamp, fall back to file modification time
        local file_age_secs=$(( $(date +%s) - $(stat -c %Y "$MARKER_FILE" 2>/dev/null || echo "0") ))
    else
        # Parse ISO timestamp and compare to now
        local created_epoch=$(date -d "$created" +%s 2>/dev/null || echo "0")
        local now_epoch=$(date +%s)
        local file_age_secs=$((now_epoch - created_epoch))
    fi

    if [ "$file_age_secs" -ge "$MAX_MARKER_AGE_SECS" ]; then
        local age_mins=$((file_age_secs / 60))
        log_debug "DEADLOCK DETECTED: Marker age ${age_mins}m >= ${MAX_MARKER_AGE_SECS}s threshold"
        log_debug "Cleaning up stale marker and running zombie cleanup"

        # Run zombie cleanup if available (non-blocking)
        local CLEANUP_SCRIPT=".claude/scripts/lean-zombie-cleanup.sh"
        if [ -x "$CLEANUP_SCRIPT" ]; then
            log_debug "Running lean zombie cleanup"
            "$CLEANUP_SCRIPT" --force --age-threshold 1 2>&1 | while read line; do
                log_debug "  cleanup: $line"
            done || log_debug "Zombie cleanup failed (non-fatal)"
        fi

        # Remove stale marker and loop guard
        rm -f "$MARKER_FILE"
        rm -f "$LOOP_GUARD_FILE"
        return 1  # Age check failed - marker was stale
    fi

    return 0  # Age check passed
}

# Check if we're in a potential infinite loop
check_loop_guard() {
    if [ -f "$LOOP_GUARD_FILE" ]; then
        local count=$(cat "$LOOP_GUARD_FILE" 2>/dev/null || echo "0")
        if [ "$count" -ge "$MAX_CONTINUATIONS" ]; then
            log_debug "Loop guard triggered: $count >= $MAX_CONTINUATIONS"
            # Reset guard and allow stop
            rm -f "$LOOP_GUARD_FILE"
            rm -f "$MARKER_FILE"
            return 1  # Allow stop
        fi
        # Increment counter
        echo $((count + 1)) > "$LOOP_GUARD_FILE"
        log_debug "Loop guard incremented to $((count + 1))"
    else
        # First continuation, initialize guard
        echo "1" > "$LOOP_GUARD_FILE"
        log_debug "Loop guard initialized to 1"
    fi
    return 0  # Allow continuation
}

# Main logic
main() {
    # Check if postflight marker exists
    if [ -f "$MARKER_FILE" ]; then
        log_debug "Postflight marker found"

        # Check for stop_hook_active flag in marker (prevents hooks calling hooks)
        if grep -q '"stop_hook_active": true' "$MARKER_FILE" 2>/dev/null; then
            log_debug "stop_hook_active flag set, allowing stop"
            rm -f "$MARKER_FILE"
            rm -f "$LOOP_GUARD_FILE"
            echo '{}'
            exit 0
        fi

        # Check marker age FIRST - stale markers indicate deadlock
        if ! check_marker_age; then
            log_debug "Stale marker cleaned up, allowing stop"
            echo '{}'
            exit 0
        fi

        # Check loop guard
        if ! check_loop_guard; then
            log_debug "Loop guard prevented continuation"
            echo '{}'
            exit 0
        fi

        # Block the stop to allow postflight to complete
        local reason=$(jq -r '.reason // "Postflight operations pending"' "$MARKER_FILE" 2>/dev/null)
        log_debug "Blocking stop: $reason"

        # Return block decision
        # Note: Using simple JSON output - no jq dependency for robustness
        echo "{\"decision\": \"block\", \"reason\": \"$reason\"}"
        exit 0
    fi

    # No marker - allow normal stop
    log_debug "No postflight marker, allowing stop"
    rm -f "$LOOP_GUARD_FILE"
    echo '{}'
    exit 0
}

main
