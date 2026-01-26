#!/usr/bin/env bash
# atomic-postflight-plan.sh - Atomic state update for planning workflow
#
# Usage: atomic-postflight-plan.sh TASK_NUMBER ARTIFACT_PATH ARTIFACT_SUMMARY PROJECT_NAME
#
# This script ensures atomic updates to both state.json and TODO.md for plan workflow.

set -euo pipefail

# Parse arguments
if [ $# -lt 4 ]; then
    echo "Usage: $0 TASK_NUMBER ARTIFACT_PATH ARTIFACT_SUMMARY PROJECT_NAME"
    exit 1
fi

task_number="$1"
artifact_path="$2"
artifact_summary="$3"
project_name="$4"

# Change to project root
cd "$(dirname "$0")/../.."

echo "=== Atomic Postflight for Plan (Task $task_number) ==="

# Backup current state
echo "Creating backups..."
cp specs/state.json /tmp/state.json.backup
cp specs/TODO.md /tmp/TODO.md.backup

# Update state.json to temp
echo "Updating state.json..."
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Step 1: Update status and timestamps
jq --arg num "$task_number" \
   --arg status "planned" \
   --arg ts "$timestamp" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
     status: $status,
     last_updated: $ts,
     planned: $ts
   }' specs/state.json > /tmp/state.json.new

# Step 2: Add artifact to state.json temp
jq --arg num "$task_number" \
   --arg path "$artifact_path" \
   --arg summary "$artifact_summary" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts += [{
     type: "plan",
     path: $path,
     summary: $summary
   }]' /tmp/state.json.new > /tmp/state.json.tmp
mv /tmp/state.json.tmp /tmp/state.json.new

# Update TODO.md to temp (Python script)
echo "Updating TODO.md..."
if ! python3 .claude/scripts/update-todo-artifact.py \
    --input specs/TODO.md \
    --output /tmp/TODO.md.new \
    --task "$task_number" \
    --type "plan" \
    --path "$artifact_path"; then

    echo "ERROR: Python TODO.md updater failed"
    exit 1
fi

# Validate temp files
echo "Validating updates..."
source .claude/scripts/lib/validation.sh

if ! validate_state_json /tmp/state.json.new "$task_number" "planned" "plan"; then
    echo "ERROR: state.json validation failed"
    exit 1
fi

if ! validate_todo_md /tmp/TODO.md.new "$task_number" "PLANNED" "Plan"; then
    echo "ERROR: TODO.md validation failed"
    exit 1
fi

# Atomic replace (both or neither)
echo "Performing atomic replace..."
mv /tmp/state.json.new specs/state.json
mv /tmp/TODO.md.new specs/TODO.md

echo "✓ SUCCESS: Atomic postflight completed"
exit 0
