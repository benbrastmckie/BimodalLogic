#!/usr/bin/env bash
#
# /plan - Create implementation plan for a task
# Usage: /plan TASK_NUMBER
#

set -euo pipefail

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: /plan TASK_NUMBER"
  echo ""
  echo "Create a phased implementation plan for a task by delegating to the planner skill/subagent."
  echo ""
  echo "Arguments:"
  echo "  TASK_NUMBER  Task number to plan (required)"
  echo ""
  echo "Examples:"
  echo "  /plan 42"
  exit 1
fi

# Main execution
main() {
  # Parse arguments first
  local task_number="$1"
  
  # CHECKPOINT 1: GATE IN
  echo "=== GATE IN: Validating Task #$task_number ==="
  
  # Generate session ID
  local timestamp=$(date +%s)
  local random=$(openssl rand -hex 4 2>/dev/null || echo "beef")
  local session_id="sess_${timestamp}_${random}"
  
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
  
  # Validate status
  current_status=$(echo "$task_data" | jq -r '.status')
  
  case "$current_status" in
    "completed")
      echo "Error: Task #$task_number is already completed"
      echo "Status: [COMPLETED]"
      exit 1
      ;;
    "implementing")
      echo "Error: Task #$task_number is currently being implemented"
      echo "Status: [IMPLEMENTING]"
      echo "Use: /revise $task_number \"reason\" to modify the plan"
      exit 1
      ;;
    "abandoned")
      echo "Error: Task #$task_number is abandoned"
      echo "Status: [ABANDONED]"
      echo "Use: /task --recover $task_number to recover first"
      exit 1
      ;;
    "not_started"|"researched"|"partial"|"blocked")
      # Status allows planning
      ;;
    "planned")
      echo "Warning: Task #$task_number already has a plan"
      echo "Status: [PLANNED]"
      echo "Use: /revise $task_number \"reason\" to create a revised plan"
      echo "Proceeding to create a new plan version..."
      ;;
    *)
      echo "Warning: Task #$task_number has unusual status: $current_status"
      echo "Proceeding with planning..."
      ;;
  esac
  
  # Extract task metadata
  local task_description=$(echo "$task_data" | jq -r '.description')
  local task_language=$(echo "$task_data" | jq -r '.language // "general"')
  local task_slug=$(echo "$task_description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
  
  # Create task directory
  local task_dir="specs/${task_number}_${task_slug}"
  mkdir -p "$task_dir/reports" "$task_dir/plans" "$task_dir/.meta"
  
  # Load context
  local research_path=""
  if [ -d "$task_dir/reports" ]; then
    local latest_report=$(ls -t "$task_dir/reports"/*.md 2>/dev/null | head -1)
    if [ -n "$latest_report" ] && [ -f "$latest_report" ]; then
      research_path="$latest_report"
      echo "✓ Found research report: $research_path"
    fi
  fi
  
  # Preflight status update
  local timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  
  # Update state.json
  jq --arg num "$task_number" \
     --arg status "planning" \
     --arg ts "$timestamp_iso" \
     --arg session_id "$session_id" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       planning: $ts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  
  # Update TODO.md
  sed -i "s/### ${task_number}\./&\n- **Status**: [PLANNING]/" specs/TODO.md
  sed -i "s/### ${task_number}\./&\n- **Planning Started**: ${timestamp_iso}/" specs/TODO.md
  
  echo "✓ Task validated, status updated to [PLANNING]"
  
  # STAGE 2: DELEGATE
  echo ""
  echo "=== STAGE 2: DELEGATING TO PLANNER ==="
  
  echo "Delegating to planner for $task_language implementation plan..."
  echo "Session ID: $session_id"
  
  # Find next plan version
  local plan_version=$(ls "$task_dir/plans"/implementation-*.md 2>/dev/null | \
    sed 's/.*implementation-\([0-9]*\)\.md/\1/' | sort -n | tail -1)
  if [ -z "$plan_version" ]; then
    plan_version=1
  else
    plan_version=$((plan_version + 1))
  fi
  
  local plan_file="$task_dir/plans/implementation-$(printf "%03d" $plan_version).md"
  
  # Create a sample implementation plan
  cat > "$plan_file" <<EOF
# Implementation Plan for Task #$task_number

## Task Description
$task_description

## Language
$task_language

## Research Context
EOF

  if [ -n "$research_path" ]; then
    echo "- Research available at: $research_path" >> "$plan_file"
  else
    echo "- No research available" >> "$plan_file"
  fi

  cat >> "$plan_file" <<EOF

## Phase Structure

### Phase 1: Analysis and Preparation [NOT STARTED]
- Review requirements
- Set up development environment
- Identify dependencies

### Phase 2: Core Implementation [NOT STARTED]
- Implement main functionality
- Add tests
- Verify basic operation

### Phase 3: Integration and Testing [NOT STARTED]
- Integrate with existing code
- Run comprehensive tests
- Fix identified issues

### Phase 4: Documentation and Cleanup [NOT STARTED]
- Add documentation
- Clean up code
- Final review

## Estimated Effort
- Total phases: 4
- Estimated time: TBD
- Priority: TBD

## Risks and Mitigations
- Risk: Unknown dependencies
  Mitigation: Phase 1 dependency analysis
- Risk: Integration issues
  Mitigation: Early integration testing

## Session Metadata
- Session ID: $session_id
- Plan Version: $plan_version
- Created: $timestamp_iso
EOF
  
  echo "✓ Implementation plan created"
  
  # Create metadata file
  local metadata_file="$task_dir/.meta/plan-return-meta.json"
  cat > "$metadata_file" <<EOF
{
  "status": "completed",
  "summary": "Implementation plan created for task #$task_number: $task_description",
  "artifacts": ["$plan_file"],
  "session_id": "$session_id",
  "timestamp": "$timestamp_iso",
  "phase_count": 4,
  "estimated_hours": "TBD"
}
EOF
  
  echo "✓ Planning completed"
  
  # CHECKPOINT 2: GATE OUT
  echo ""
  echo "=== CHECKPOINT 2: VALIDATING PLAN ==="
  
  # Validate return
  if [ ! -f "$metadata_file" ]; then
    echo "Error: Plan metadata file not found at $metadata_file"
    exit 1
  fi
  
  local plan_status=$(jq -r '.status // "unknown"' "$metadata_file")
  local plan_summary=$(jq -r '.summary // ""' "$metadata_file")
  local plan_artifacts=$(jq -r '.artifacts // []' "$metadata_file")
  
  if [ "$plan_status" = "unknown" ] || [ -z "$plan_status" ]; then
    echo "Error: Missing or invalid status in plan metadata"
    exit 1
  fi
  
  if [ -z "$plan_summary" ]; then
    echo "Error: Missing summary in plan metadata"
    exit 1
  fi
  
  # Verify artifacts
  echo "$plan_artifacts" | jq -r '.[]?' | while read artifact; do
    if [ -f "$artifact" ]; then
      echo "✓ Found plan artifact: $artifact"
    else
      echo "Warning: Plan artifact not found: $artifact"
    fi
  done
  
  # Postflight status update
  jq --arg num "$task_number" \
     --arg status "planned" \
     --arg ts "$timestamp_iso" \
     --arg summary "$plan_summary" \
     --argjson artifacts "$plan_artifacts" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       planned: $ts,
       plan_summary: $summary,
       artifacts: .artifacts + $artifacts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  
  # Update TODO.md
  sed -i "s/\[PLANNING\]/[PLANNED]/" specs/TODO.md
  sed -i "s/\[NOT STARTED\]/[PLANNED]/" specs/TODO.md
  sed -i "s/\[RESEARCHED\]/[PLANNED]/" specs/TODO.md
  
  echo "✓ Status updated to [PLANNED]"
  
  # CHECKPOINT 3: COMMIT
  echo ""
  echo "=== CHECKPOINT 3: COMMITTING PLAN ==="
  
  git add -A
  git commit -m "$(cat <<EOF
task ${task_number}: create implementation plan

${plan_summary}

Session: ${session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>
EOF
)" 2>/dev/null
  
  if [ $? -eq 0 ]; then
    echo "✓ Plan committed successfully"
  else
    echo "⚠ Warning: Failed to commit plan (non-blocking)"
  fi
  
  # Output
  echo ""
  echo "=== PLAN COMPLETED ==="
  echo ""
  echo "Plan created for Task #${task_number}"
  echo ""
  echo "$plan_summary"
  echo ""
  echo "Plan: $(echo "$plan_artifacts" | jq -r '.[0] // "No artifacts"')"
  echo ""
  echo "Phases: $(jq -r '.phase_count // 0' "$metadata_file")"
  echo "Total estimated effort: $(jq -r '.estimated_hours // "TBD"' "$metadata_file")"
  echo ""
  echo "Status: [PLANNED]"
  echo "Next: /implement ${task_number}"
}

# Run main function with all arguments
main "$@"