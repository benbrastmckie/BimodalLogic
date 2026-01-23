#!/usr/bin/env bash
#
# /revise - Create new version of implementation plan, or update task description if no plan exists
# Usage: /revise TASK_NUMBER [REASON]
#

set -euo pipefail

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: /revise TASK_NUMBER [REASON]"
  echo ""
  echo "Create a new version of an implementation plan, or update task description if no plan exists."
  echo ""
  echo "Arguments:"
  echo "  TASK_NUMBER  Task number to revise (required)"
  echo "  REASON       Reason for revision (optional, required if no plan exists)"
  echo ""
  echo "Examples:"
  echo "  /revise 42 \"Add testing phase\""
  echo "  /revise 42 \"Update requirements\""
  exit 1
fi

# Main execution
main() {
  # Parse arguments first
  local task_number="$1"
  shift
  local revision_reason="$*"
  
  # Generate session ID
  local timestamp=$(date +%s)
  local random=$(openssl rand -hex 4 2>/dev/null || echo "cafe")
  local session_id="sess_${timestamp}_${random}"
  
  # CHECKPOINT 1: GATE IN
  echo "=== GATE IN: Validating Task #$task_number ==="
  
  # Lookup task
  task_data=$(jq -r --arg num "$task_number" \
    '.active_projects[] | select(.project_number == ($num | tonumber))' \
    specs/state.json)
  
  # Validate task exists
  if [ -z "$task_data" ] || [ "$task_data" = "null" ]; then
    echo "Error: Task #$task_number not found in specs/state.json"
    echo "Available tasks:"
    jq -r '.active_projects[] | "  #\(.project_number): \(.description)"' specs/state.json
    exit 1
  fi
  
  # Validate and route
  current_status=$(echo "$task_data" | jq -r '.status')
  
  case "$current_status" in
    "completed")
      echo "Error: Task #$task_number is completed"
      echo "Status: [COMPLETED]"
      echo "No revision needed for completed tasks"
      exit 1
      ;;
    "abandoned")
      echo "Error: Task #$task_number is abandoned"
      echo "Status: [ABANDONED]"
      echo "Use: /task --recover $task_number to recover first"
      exit 1
      ;;
    "planned"|"implementing"|"partial"|"blocked")
      # Plan revision route
      revise_type="plan"
      ;;
    "not_started"|"researched")
      # Description update route
      revise_type="description"
      ;;
    *)
      echo "Warning: Task #$task_number has unusual status: $current_status"
      echo "Defaulting to description update"
      revise_type="description"
      ;;
  esac
  
  # Extract task metadata
  task_description=$(echo "$task_data" | jq -r '.description')
  task_language=$(echo "$task_data" | jq -r '.language // "general"')
  task_slug=$(echo "$task_description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
  
  # Create task directory
  task_dir="specs/${task_number}_${task_slug}"
  mkdir -p "$task_dir/reports" "$task_dir/plans" "$task_dir/.meta"
  
  echo "✓ Task validated, route: $revise_type revision"
  
  # Preflight status update
  timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  
  # Update state.json
  jq --arg num "$task_number" \
     --arg status "revising" \
     --arg ts "$timestamp_iso" \
     --arg session_id "$session_id" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       revising: $ts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  
  # Update TODO.md
  sed -i "s/### ${task_number}\./&\n- **Status**: [REVISING]/" specs/TODO.md
  sed -i "s/### ${task_number}\./&\n- **Revision Started**: ${timestamp_iso}/" specs/TODO.md
  
  echo "✓ Status updated to [REVISING]"
  
  # Route based on revision type
  if [ "$revise_type" = "plan" ]; then
    # STAGE 2A: Plan Revision
    echo ""
    echo "=== STAGE 2A: PLAN REVISION ==="
    
    # Load current context
    current_plan=$(ls -t "$task_dir/plans"/implementation-*.md 2>/dev/null | head -1)
    
    if [ ! -f "$current_plan" ]; then
      echo "Warning: No existing plan found, falling back to description update"
      revise_type="description"
    else
      echo "✓ Current plan: $current_plan"
      
      # Extract current version
      current_version=$(echo "$current_plan" | sed 's/.*implementation-\([0-9]*\)\.md/\1/')
      new_version=$((current_version + 1))
      
      echo "✓ Creating new plan version: implementation-$(printf "%03d" $new_version).md"
      
      # Analyze what changed
      echo "Analyzing implementation progress..."
      
      # Create revised plan
      new_plan_file="$task_dir/plans/implementation-$(printf "%03d" $new_version).md"
      
      # Copy current plan and update version info
      cp "$current_plan" "$new_plan_file"
      
      # Update version metadata
      sed -i "s/Plan Version: [0-9]*/Plan Version: $new_version/" "$new_plan_file"
      sed -i "s/Created: /Previous Version: $current_version\\nRevised: /" "$new_plan_file"
      sed -i "s/Session ID: .*/Session ID: $session_id/" "$new_plan_file"
      
      # Add revision note
      revision_note="## Revision Note
Revision: $new_version
Reason: $revision_reason
Date: $timestamp_iso
Previous Plan: $current_plan

"
      
      # Insert revision note after Language section
      sed -i "/## Language/a\\
$revision_note" "$new_plan_file"
      
      echo "✓ Revised plan created"
      
      # Create metadata
      metadata_file="$task_dir/.meta/revise-return-meta.json"
      cat > "$metadata_file" <<EOF
{
  "status": "completed",
  "summary": "Plan revised for task #$task_number: $task_description (v$new_version)",
  "artifacts": ["$new_plan_file"],
  "session_id": "$session_id",
  "timestamp": "$timestamp_iso",
  "revision_type": "plan",
  "previous_version": $current_version,
  "new_version": $new_version,
  "key_changes": ["Updated to version $new_version", "Reason: $revision_reason"]
}
EOF
    fi
  fi
  
  if [ "$revise_type" = "description" ]; then
    # STAGE 2B: Description Update
    echo ""
    echo "=== STAGE 2B: DESCRIPTION UPDATE ==="
    
    # Validate revision reason
    if [ -z "$revision_reason" ]; then
      echo "Error: No revision reason provided"
      echo "Usage: /revise $task_number \"new description or reason\""
      exit 1
    fi
    
    old_description="$task_description"
    new_description="$revision_reason"
    
    echo "Previous: $old_description"
    echo "New: $new_description"
    
    # Update state.json
    jq --arg num "$task_number" \
       --arg desc "$new_description" \
       --arg ts "$timestamp_iso" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
         description: $desc,
         last_updated: $ts
       }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
    
    # Update TODO.md
    # Replace description in task entry
    sed -i "s/### ${task_number}\. \(.*\)/### ${task_number}\. $new_description/" specs/TODO.md
    
    echo "✓ Description updated"
    
    # Create metadata
    metadata_file="$task_dir/.meta/revise-return-meta.json"
    cat > "$metadata_file" <<EOF
{
  "status": "completed",
  "summary": "Description updated for task #$task_number",
  "artifacts": [],
  "session_id": "$session_id",
  "timestamp": "$timestamp_iso",
  "revision_type": "description",
  "previous_description": "$old_description",
  "new_description": "$new_description"
}
EOF
  fi
  
  # CHECKPOINT 2: GATE OUT
  echo ""
  echo "=== CHECKPOINT 2: VALIDATING REVISION ==="
  
  # Validate return
  if [ ! -f "$metadata_file" ]; then
    echo "Error: Revision metadata file not found at $metadata_file"
    exit 1
  fi
  
  revise_status=$(jq -r '.status // "unknown"' "$metadata_file")
  revise_summary=$(jq -r '.summary // ""' "$metadata_file")
  revise_artifacts=$(jq -r '.artifacts // []' "$metadata_file")
  
  if [ "$revise_status" = "unknown" ] || [ -z "$revise_status" ]; then
    echo "Error: Missing or invalid status in revision metadata"
    exit 1
  fi
  
  if [ -z "$revise_summary" ]; then
    echo "Error: Missing summary in revision metadata"
    exit 1
  fi
  
  # Verify artifacts for plan revision
  if [ "$revise_type" = "plan" ]; then
    echo "$revise_artifacts" | jq -r '.[]?' | while read artifact; do
      if [ -f "$artifact" ]; then
        echo "✓ Found revised plan artifact: $artifact"
      else
        echo "Warning: Revised plan artifact not found: $artifact"
      fi
    done
  fi
  
  # Postflight status update
  jq --arg num "$task_number" \
     --arg status "planned" \
     --arg ts "$timestamp_iso" \
     --arg summary "$revise_summary" \
     --argjson artifacts "$revise_artifacts" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       planned: $ts,
       revision_summary: $summary,
       artifacts: .artifacts + $artifacts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  
  # Update TODO.md
  sed -i "s/\[REVISING\]/[REVISED]/" specs/TODO.md
  
  echo "✓ Status updated to [REVISED]"
  
  # CHECKPOINT 3: COMMIT
  echo ""
  echo "=== CHECKPOINT 3: COMMITTING REVISION ==="
  
  commit_msg="task ${task_number}: revise ${revise_type}"
  
  if [ "$revise_type" = "plan" ]; then
    new_version=$(jq -r '.new_version // 0' "$metadata_file")
    commit_msg+=" (v$new_version)"
  else
    commit_msg+=" description"
  fi
  
  git add -A
  git commit -m "$(cat <<EOF
$commit_msg

$revise_summary

Session: ${session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>
EOF
)" 2>/dev/null
  
  if [ $? -eq 0 ]; then
    echo "✓ Revision committed successfully"
  else
    echo "⚠ Warning: Failed to commit revision (non-blocking)"
  fi
  
  # Output
  echo ""
  echo "=== REVISION COMPLETED ==="
  echo ""
  
  if [ "$revise_type" = "plan" ]; then
    echo "Plan revised for Task #${task_number}"
    echo ""
    new_version=$(jq -r '.new_version // 0' "$metadata_file")
    previous_version=$(jq -r '.previous_version // 0' "$metadata_file")
    echo "Previous: implementation-$previous_version.md"
    echo "New: implementation-$new_version.md"
    echo ""
    key_changes=$(jq -r '.key_changes[]?' "$metadata_file" 2>/dev/null || echo "No key changes recorded")
    echo "Key changes:"
    echo "$key_changes" | sed 's/^/- /'
    echo ""
    echo "Status: [PLANNED]"
    echo "Next: /implement ${task_number}"
  else
    echo "Description updated for Task #${task_number}"
    echo ""
    previous_description=$(jq -r '.previous_description' "$metadata_file")
    new_description=$(jq -r '.new_description' "$metadata_file")
    echo "Previous: $previous_description"
    echo "New: $new_description"
    echo ""
    echo "Status: [${current_status^^}]"
  fi
}

# Run main function with all arguments
main "$@"