#!/usr/bin/env bash
# update-plan-status.sh - Centralized plan file status update helper
#
# Usage:
#   ./update-plan-status.sh TASK_NUMBER PROJECT_NAME NEW_STATUS
#   ./update-plan-status.sh --validate TASK_NUMBER
#
# This script updates the plan file's Status field (line 4 of metadata block)
# to keep it synchronized with state.json and TODO.md.
#
# Three-file synchronization order: state.json -> TODO.md -> plan file
#
# Modes:
#   Update mode (default): Set plan file status to NEW_STATUS
#   Validate mode (--validate): Check plan file status matches state.json, auto-fix if not
#
# Arguments:
#   TASK_NUMBER    Task number (e.g., 927)
#   PROJECT_NAME   Project name slug (e.g., fix_status_sync). Can be empty for fallback glob.
#   NEW_STATUS     Target status marker (IMPLEMENTING, COMPLETED, PARTIAL, etc.)
#
# Returns:
#   Exit 0: Success, prints updated file path (or "ok" if validation passed)
#   Exit 0: No-op (file not found or already at target status), prints empty
#   Exit 1: Invalid arguments
#
# See: .claude/context/core/formats/plan-format.md

set -e

# Map state.json status to plan file status marker
map_state_to_plan_status() {
    local state_status="$1"
    case "$state_status" in
        "not_started") echo "NOT STARTED" ;;
        "researching") echo "RESEARCHING" ;;
        "researched") echo "RESEARCHED" ;;
        "planning") echo "PLANNING" ;;
        "planned") echo "PLANNED" ;;
        "implementing") echo "IMPLEMENTING" ;;
        "completed") echo "COMPLETED" ;;
        "partial") echo "PARTIAL" ;;
        "blocked") echo "BLOCKED" ;;
        "abandoned") echo "ABANDONED" ;;
        "expanded") echo "EXPANDED" ;;
        *) echo "" ;;
    esac
}

# Validation mode: compare plan file status with state.json and auto-fix
validate_and_fix() {
    local task_number="$1"
    local state_file="specs/state.json"

    # Validate state file exists
    if [ ! -f "$state_file" ]; then
        echo "Error: $state_file not found" >&2
        exit 1
    fi

    # Get state.json status and project_name
    local task_data
    task_data=$(jq -r --argjson num "$task_number" \
        '.active_projects[] | select(.project_number == $num)' \
        "$state_file" 2>/dev/null || echo "")

    if [ -z "$task_data" ]; then
        echo "Error: Task $task_number not found in state.json" >&2
        exit 1
    fi

    local state_status
    state_status=$(echo "$task_data" | jq -r '.status // ""')
    local project_name
    project_name=$(echo "$task_data" | jq -r '.project_name // ""')

    # Map state status to plan file status
    local expected_plan_status
    expected_plan_status=$(map_state_to_plan_status "$state_status")

    if [ -z "$expected_plan_status" ]; then
        echo "Warning: Unknown state.json status '$state_status'" >&2
        echo "ok"
        exit 0
    fi

    # Find plan file
    local plan_file=""
    if [ -n "$project_name" ]; then
        plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1 || true)
    fi
    if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
        plan_file=$(ls -1 specs/${task_number}_*/plans/implementation-*.md 2>/dev/null | sort -V | tail -1 || true)
    fi

    # If no plan file, nothing to validate
    if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
        echo "ok"
        exit 0
    fi

    # Get current plan file status
    local current_plan_status
    current_plan_status=$(grep -m1 "^- \*\*Status\*\*:" "$plan_file" | sed 's/.*\[\([^]]*\)\].*/\1/' || echo "")

    # Compare and auto-fix if mismatch
    if [ "$current_plan_status" != "$expected_plan_status" ]; then
        echo "Warning: Status mismatch for task $task_number" >&2
        echo "  state.json: $state_status -> plan should be: [$expected_plan_status]" >&2
        echo "  plan file:  [$current_plan_status]" >&2
        echo "  Auto-fixing..." >&2

        # Fix the status
        sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [${expected_plan_status}]/" "$plan_file"

        echo "fixed:$plan_file"
    else
        echo "ok"
    fi
    exit 0
}

# Check for validate mode
if [ "$1" = "--validate" ]; then
    if [ $# -lt 2 ]; then
        echo "Usage: $0 --validate TASK_NUMBER" >&2
        exit 1
    fi
    validate_and_fix "$2"
    # validate_and_fix exits, so we won't reach here
fi

if [ $# -lt 2 ]; then
    echo "Usage: $0 TASK_NUMBER PROJECT_NAME NEW_STATUS" >&2
    echo "       $0 --validate TASK_NUMBER" >&2
    echo "" >&2
    echo "Arguments:" >&2
    echo "  TASK_NUMBER    Task number to update" >&2
    echo "  PROJECT_NAME   Project name slug (can be empty for fallback)" >&2
    echo "  NEW_STATUS     Target status: IMPLEMENTING, COMPLETED, PARTIAL, etc." >&2
    echo "" >&2
    echo "Validation mode:" >&2
    echo "  --validate     Compare plan file status with state.json and auto-fix mismatches" >&2
    exit 1
fi

task_number="$1"
project_name="$2"
new_status="${3:-}"

# Validate task_number is a number
if ! [[ "$task_number" =~ ^[0-9]+$ ]]; then
    echo "Error: TASK_NUMBER must be a number" >&2
    exit 1
fi

# Validate new_status is provided
if [ -z "$new_status" ]; then
    echo "Error: NEW_STATUS is required" >&2
    exit 1
fi

# Normalize status to uppercase
new_status=$(echo "$new_status" | tr '[:lower:]' '[:upper:]')

# Validate status is known
# Task-level statuses: NOT STARTED, RESEARCHING, RESEARCHED, PLANNING, PLANNED, IMPLEMENTING, COMPLETED
# Terminal/special: BLOCKED, ABANDONED, PARTIAL, EXPANDED
# Phase-level: IN PROGRESS (used for individual phases within plan)
case "$new_status" in
    "NOT STARTED"|"IN PROGRESS"|"IMPLEMENTING"|"COMPLETED"|"PARTIAL"|"BLOCKED"|"ABANDONED"|"PLANNING"|"PLANNED"|"RESEARCHING"|"RESEARCHED"|"EXPANDED")
        ;;
    *)
        echo "Error: Unknown status: $new_status" >&2
        exit 1
        ;;
esac

# Find plan file using project_name if available, otherwise fallback glob
plan_file=""

if [ -n "$project_name" ]; then
    # Try with project_name first
    plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1 || true)
fi

# Fallback: glob without project_name
if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
    plan_file=$(ls -1 specs/${task_number}_*/plans/implementation-*.md 2>/dev/null | sort -V | tail -1 || true)
fi

# Check if plan file exists
if [ -z "$plan_file" ] || [ ! -f "$plan_file" ]; then
    # No-op: file not found (this is not an error, just nothing to update)
    echo ""
    exit 0
fi

# Check current status to avoid unnecessary writes
current_status=$(grep -m1 "^- \*\*Status\*\*:" "$plan_file" | sed 's/.*\[\([^]]*\)\].*/\1/' || echo "")

if [ "$current_status" = "$new_status" ]; then
    # No-op: already at target status
    echo ""
    exit 0
fi

# Update the plan file status using sed
# Pattern matches: - **Status**: [ANY_STATUS]
# Replaces with: - **Status**: [NEW_STATUS]
sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [${new_status}]/" "$plan_file"

# Verify the update succeeded
updated_status=$(grep -m1 "^- \*\*Status\*\*:" "$plan_file" | sed 's/.*\[\([^]]*\)\].*/\1/' || echo "")

if [ "$updated_status" = "$new_status" ]; then
    echo "$plan_file"
else
    echo "Warning: Status update may have failed. Expected [$new_status], got [$updated_status]" >&2
    echo "$plan_file"
fi
