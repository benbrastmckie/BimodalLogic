#!/usr/bin/env bash
# postflight-implement.sh - Implementation postflight with correct jq pattern
#
# Usage: ./postflight-implement.sh TASK_NUMBER ARTIFACT_PATH [ARTIFACT_SUMMARY]
#
# This script updates state.json after implementation completion using the
# two-step jq pattern to avoid Issue #1132 (Claude Code Bash tool escaping bug).
#
# Three-file synchronization: Updates state.json, then calls update-plan-status.sh
# to keep plan file in sync.
#
# See:
#   - .claude/context/core/patterns/jq-escaping-workarounds.md
#   - .claude/scripts/update-plan-status.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 2 ]; then
    echo "Usage: $0 TASK_NUMBER ARTIFACT_PATH [ARTIFACT_SUMMARY]"
    echo ""
    echo "Arguments:"
    echo "  TASK_NUMBER      Task number to update"
    echo "  ARTIFACT_PATH    Path to implementation summary (relative to project root)"
    echo "  ARTIFACT_SUMMARY Optional summary of implementation"
    exit 1
fi

task_number="$1"
artifact_path="$2"
artifact_summary="${3:-Implementation summary}"
state_file="specs/state.json"

# Validate state file exists
if [ ! -f "$state_file" ]; then
    echo "Error: $state_file not found"
    exit 1
fi

# Validate task exists
task_exists=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num) | .project_number' \
  "$state_file")

if [ -z "$task_exists" ]; then
    echo "Error: Task $task_number not found in state.json"
    exit 1
fi

echo "Updating task $task_number with implementation artifact..."

# Step 1: Update status and timestamps
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "completed" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    completed: $ts
  }' "$state_file" > /tmp/state.json && mv /tmp/state.json "$state_file"

echo "  Status updated to 'completed'"

# Step 2: Filter out existing summary artifacts (two-step pattern for Issue #1132)
jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "summary")]' \
  "$state_file" > /tmp/state.json && mv /tmp/state.json "$state_file"

# Step 3: Add new summary artifact
jq --arg path "$artifact_path" \
   --arg summary "$artifact_summary" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": "summary", "summary": $summary}]' \
  "$state_file" > /tmp/state.json && mv /tmp/state.json "$state_file"

echo "  Artifact linked: $artifact_path"

# Step 4: Update plan file status (three-file synchronization)
# Extract project_name from state.json for plan file lookup
project_name=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num) | .project_name // ""' \
  "$state_file")

# Map state.json status to plan file marker
# state.json uses: completed, partial, implementing, etc.
# plan file uses: COMPLETED, PARTIAL, IMPLEMENTING, etc.
plan_status="COMPLETED"  # This script always sets completed

# Call the centralized helper
if [ -f "$SCRIPT_DIR/update-plan-status.sh" ]; then
    plan_result=$("$SCRIPT_DIR/update-plan-status.sh" "$task_number" "$project_name" "$plan_status" 2>&1)
    if [ -n "$plan_result" ]; then
        echo "  Plan file updated: $plan_result"
    else
        echo "  Plan file: no update needed (not found or already at status)"
    fi
else
    echo "  Warning: update-plan-status.sh not found, skipping plan file update"
fi

echo "Done."
