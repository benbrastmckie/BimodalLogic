#!/usr/bin/env bash
# validation.sh - Reusable validation functions for postflight operations
#
# This library provides validation functions to verify state.json and TODO.md
# updates completed successfully. Used by atomic postflight scripts.

# validate_state_json - Validate state.json contains expected task state
#
# Args:
#   $1 - File path to validate
#   $2 - Task number
#   $3 - Expected status (e.g., "researched", "planned", "completed")
#   $4 - Artifact type (e.g., "report", "plan", "summary")
#
# Returns:
#   0 - Validation passed
#   1 - Validation failed (prints error message)
validate_state_json() {
    local file="$1"
    local task_num="$2"
    local expected_status="$3"
    local artifact_type="$4"

    # Check JSON valid
    if ! jq empty "$file" 2>/dev/null; then
        echo "Error: Invalid JSON in $file"
        return 1
    fi

    # Check task exists
    local task=$(jq -r --argjson num "$task_num" \
        '.active_projects[] | select(.project_number == $num)' \
        "$file")

    if [ -z "$task" ] || [ "$task" = "null" ]; then
        echo "Error: Task $task_num not found in $file"
        return 1
    fi

    # Check task status
    local status=$(jq -r --argjson num "$task_num" \
        '.active_projects[] | select(.project_number == $num) | .status // "not_found"' \
        "$file")

    if [ "$status" != "$expected_status" ]; then
        echo "Error: Task $task_num status is '$status', expected '$expected_status'"
        return 1
    fi

    # Check artifact exists (if artifact_type specified)
    if [ -n "$artifact_type" ]; then
        local artifact=$(jq -r --argjson num "$task_num" \
            --arg type "$artifact_type" \
            '.active_projects[] | select(.project_number == $num) | .artifacts[]? | select(.type == $type) | .path // ""' \
            "$file")

        if [ -z "$artifact" ]; then
            echo "Error: Task $task_num artifact type '$artifact_type' not found in $file"
            return 1
        fi
    fi

    return 0
}

# validate_todo_md - Validate TODO.md contains expected task state
#
# Args:
#   $1 - File path to validate
#   $2 - Task number
#   $3 - Expected status marker (e.g., "RESEARCHED", "PLANNED", "COMPLETED")
#   $4 - Link type (e.g., "Research", "Plan", "Summary") - optional
#
# Returns:
#   0 - Validation passed
#   1 - Validation failed (prints error message)
validate_todo_md() {
    local file="$1"
    local task_num="$2"
    local expected_status="$3"
    local link_type="$4"

    # Extract task section (from ### N. to next ### or end of file)
    local section=$(sed -n "/^### ${task_num}\./,/^### [0-9]/p" "$file" | sed '$d' 2>/dev/null)

    # If section is empty, try without removing last line (task might be at end)
    if [ -z "$section" ]; then
        section=$(sed -n "/^### ${task_num}\./,\$p" "$file")
    fi

    if [ -z "$section" ]; then
        echo "Error: Task $task_num not found in $file"
        return 1
    fi

    # Check exactly one status marker (no duplicates)
    local status_count=$(echo "$section" | grep -c "\[${expected_status}\]" || true)
    if [ "$status_count" -eq 0 ]; then
        echo "Error: Task $task_num status marker [$expected_status] not found in $file"
        return 1
    elif [ "$status_count" -gt 1 ]; then
        echo "Error: Task $task_num has $status_count status markers [$expected_status], expected 1"
        return 1
    fi

    # Check artifact link exists (if link_type specified)
    if [ -n "$link_type" ]; then
        if ! echo "$section" | grep -q "^\- \*\*${link_type}\*\*:"; then
            echo "Error: Task $task_num ${link_type} link not found in $file"
            return 1
        fi
    fi

    return 0
}

# validate_file_exists - Validate a file exists
#
# Args:
#   $1 - File path
#
# Returns:
#   0 - File exists
#   1 - File does not exist
validate_file_exists() {
    local file="$1"

    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file"
        return 1
    fi

    return 0
}

# validate_json_structure - Validate JSON file has required top-level fields
#
# Args:
#   $1 - File path
#   $2+ - Required field names
#
# Returns:
#   0 - All fields present
#   1 - Missing fields
validate_json_structure() {
    local file="$1"
    shift
    local required_fields=("$@")

    if ! jq empty "$file" 2>/dev/null; then
        echo "Error: Invalid JSON in $file"
        return 1
    fi

    for field in "${required_fields[@]}"; do
        local value=$(jq -r ".$field // \"MISSING\"" "$file")
        if [ "$value" = "MISSING" ]; then
            echo "Error: Required field '$field' missing in $file"
            return 1
        fi
    done

    return 0
}
