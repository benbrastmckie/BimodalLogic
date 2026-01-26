#!/usr/bin/env bash
# atomic-postflight-implement.sh - Atomic state update for implementation workflow
#
# Usage: atomic-postflight-implement.sh TASK_NUMBER ARTIFACT_PATH ARTIFACT_SUMMARY PROJECT_NAME \
#                                         [COMPLETION_SUMMARY] [COMPLETION_DATA_JSON]
#
# This script ensures atomic updates to both state.json and TODO.md for implement workflow.
# Handles completion_summary, claudemd_suggestions, roadmap_items from metadata.

set -euo pipefail

# Parse arguments
if [ $# -lt 4 ]; then
    echo "Usage: $0 TASK_NUMBER ARTIFACT_PATH ARTIFACT_SUMMARY PROJECT_NAME [COMPLETION_SUMMARY] [COMPLETION_DATA_JSON]"
    exit 1
fi

task_number="$1"
artifact_path="$2"
artifact_summary="$3"
project_name="$4"
completion_summary="${5:-}"
completion_data_json="${6:-}"

# Change to project root
cd "$(dirname "$0")/../.."

echo "=== Atomic Postflight for Implementation (Task $task_number) ==="

# Backup current state
echo "Creating backups..."
cp specs/state.json /tmp/state.json.backup
cp specs/TODO.md /tmp/TODO.md.backup

# Update state.json to temp
echo "Updating state.json..."
timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Step 1: Update status and timestamps
jq --arg num "$task_number" \
   --arg status "completed" \
   --arg ts "$timestamp" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
     status: $status,
     last_updated: $ts,
     completed: $ts
   }' specs/state.json > /tmp/state.json.new

# Step 2: Add completion_summary (required for completed tasks)
if [ -n "$completion_summary" ]; then
    jq --arg num "$task_number" \
       --arg summary "$completion_summary" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).completion_summary = $summary' \
       /tmp/state.json.new > /tmp/state.json.tmp
    mv /tmp/state.json.tmp /tmp/state.json.new
fi

# Step 3: Add completion_data fields if provided (claudemd_suggestions, roadmap_items)
if [ -n "$completion_data_json" ]; then
    # Extract language
    language=$(jq -r --argjson num "$task_number" \
        '.active_projects[] | select(.project_number == $num) | .language // "general"' \
        /tmp/state.json.new)

    # For meta tasks: add claudemd_suggestions
    if [ "$language" = "meta" ]; then
        claudemd_suggestions=$(echo "$completion_data_json" | jq -r '.claudemd_suggestions // ""')
        if [ -n "$claudemd_suggestions" ]; then
            jq --arg num "$task_number" \
               --arg suggestions "$claudemd_suggestions" \
               '(.active_projects[] | select(.project_number == ($num | tonumber))).claudemd_suggestions = $suggestions' \
               /tmp/state.json.new > /tmp/state.json.tmp
            mv /tmp/state.json.tmp /tmp/state.json.new
        fi
    fi

    # For non-meta tasks: add roadmap_items (if present)
    if [ "$language" != "meta" ]; then
        roadmap_items=$(echo "$completion_data_json" | jq -c '.roadmap_items // []')
        if [ "$roadmap_items" != "[]" ]; then
            jq --arg num "$task_number" \
               --argjson items "$roadmap_items" \
               '(.active_projects[] | select(.project_number == ($num | tonumber))).roadmap_items = $items' \
               /tmp/state.json.new > /tmp/state.json.tmp
            mv /tmp/state.json.tmp /tmp/state.json.new
        fi
    fi
fi

# Step 4: Add artifact to state.json temp (implementation summary)
jq --arg num "$task_number" \
   --arg path "$artifact_path" \
   --arg summary "$artifact_summary" \
   '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts += [{
     type: "summary",
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
    --type "summary" \
    --path "$artifact_path"; then

    echo "ERROR: Python TODO.md updater failed"
    exit 1
fi

# Validate temp files
echo "Validating updates..."
source .claude/scripts/lib/validation.sh

if ! validate_state_json /tmp/state.json.new "$task_number" "completed" "summary"; then
    echo "ERROR: state.json validation failed"
    exit 1
fi

if ! validate_todo_md /tmp/TODO.md.new "$task_number" "COMPLETED" "Summary"; then
    echo "ERROR: TODO.md validation failed"
    exit 1
fi

# Atomic replace (both or neither)
echo "Performing atomic replace..."
mv /tmp/state.json.new specs/state.json
mv /tmp/TODO.md.new specs/TODO.md

echo "✓ SUCCESS: Atomic postflight completed"
exit 0
