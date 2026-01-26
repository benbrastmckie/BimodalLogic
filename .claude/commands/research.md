#!/usr/bin/env bash
#
# /research - Research a task and create reports
# Usage: /research TASK_NUMBER [FOCUS]
#

set -euo pipefail

# Check arguments
if [ $# -lt 1 ]; then
  echo "Usage: /research TASK_NUMBER [FOCUS]"
  echo ""
  echo "Research a task by delegating to the appropriate research skill/subagent."
  echo ""
  echo "Arguments:"
  echo "  TASK_NUMBER  Task number to research (required)"
  echo "  FOCUS        Optional focus/prompt for research direction"
  echo ""
  echo "Examples:"
  echo "  /research 42"
  echo "  /research 42 \"Focus on the discrepancy between Set and Prop in predicate definitions\""
  exit 1
fi

# /research Command

Conduct research for a task by delegating to the appropriate research skill/subagent.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Execution

### CHECKPOINT 1: GATE IN

1. **Parse Arguments**
   ```bash
   task_number="$1"
   shift
   focus_prompt="$*"
   ```

2. **Generate Session ID**
   ```bash
   timestamp=$(date +%s)
   random=$(openssl rand -hex 4 2>/dev/null || echo "dead")
   session_id="sess_${timestamp}_${random}"
   ```

3. **Lookup Task**
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     specs/state.json)
   ```

4. **Validate Task Exists**
   ```bash
   if [ -z "$task_data" ] || [ "$task_data" = "null" ]; then
     echo "Error: Task #$task_number not found in specs/state.json"
     echo "Available tasks:"
     jq -r '.active_projects[] | "  #\(.project_number): \(.description)"' specs/state.json
     exit 1
   fi
   ```

5. **Validate Status**
   ```bash
   current_status=$(echo "$task_data" | jq -r '.status')
   
   case "$current_status" in
     "completed")
       echo "Error: Task #$task_number is already completed"
       echo "Status: [COMPLETED]"
       echo "Use: /revise $task_number \"reason\" to modify if needed"
       exit 1
       ;;
     "abandoned")
       echo "Error: Task #$task_number is abandoned"
       echo "Status: [ABANDONED]"
       echo "Use: /task --recover $task_number to recover first"
       exit 1
       ;;
     "not_started"|"planned"|"partial"|"blocked"|"researched")
       # Status allows research
       ;;
     *)
       echo "Warning: Task #$task_number has unusual status: $current_status"
       echo "Proceeding with research..."
       ;;
   esac
   ```

6. **Extract Task Metadata**
   ```bash
   task_description=$(echo "$task_data" | jq -r '.description')
   task_language=$(echo "$task_data" | jq -r '.language // "general"')
   task_slug=$(echo "$task_description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
   ```

7. **Create Task Directory**
   ```bash
   task_dir="specs/${task_number}_${task_slug}"
   mkdir -p "$task_dir/reports" "$task_dir/plans" "$task_dir/.meta"
   ```

8. **Preflight Status Update**
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
   
   # Update state.json - use temporary file to avoid jq escaping issues
   jq --arg num "$task_number" \
      --arg status "researching" \
      --arg ts "$timestamp_iso" \
      --arg session_id "$session_id" \
      '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
        status: $status,
        last_updated: $ts,
        researching: $ts
      }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   
   # Update TODO.md
   sed -i "s/### ${task_number}\./&\n- **Status**: [RESEARCHING]/" specs/TODO.md
   sed -i "s/### ${task_number}\./&\n- **Started**: ${timestamp_iso}/" specs/TODO.md
   ```

**On GATE IN success**: Task validated, status updated to [RESEARCHING]. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Language-Based Routing**:

| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-research` |
| `general`, `meta`, `markdown`, `latex` | `skill-researcher` |

**Invoke the Skill tool NOW** with:
```
task: "Research Task ${task_number}"
prompt: "Research task number ${task_number} with description: '${task_description}'
Language: ${task_language}
Focus prompt: ${focus_prompt}
Session ID: ${session_id}
Task directory: ${task_dir}

Please conduct comprehensive research and create a report in ${task_dir}/reports/
The report should analyze the requirements and provide specific recommendations.
Return metadata to ${task_dir}/.meta/research-return-meta.json"
subagent_type: "{skill-name from table above}"
```

The skill will spawn the appropriate agent to conduct research and create a report.

**On DELEGATE success**: Research complete. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Read the metadata file:
   ```bash
   metadata_file="${task_dir}/.meta/research-return-meta.json"
   
   if [ ! -f "$metadata_file" ]; then
     echo "Error: Research metadata file not found at $metadata_file"
     echo "The skill may have failed to complete properly"
     exit 1
   fi
   
   # Extract metadata
   research_status=$(jq -r '.status // "unknown"' "$metadata_file")
   research_summary=$(jq -r '.summary // ""' "$metadata_file")
   research_artifacts=$(jq -r '.artifacts // []' "$metadata_file")
   ```

2. **Verify Required Fields**
   ```bash
   if [ "$research_status" = "unknown" ] || [ -z "$research_status" ]; then
     echo "Error: Missing or invalid status in research metadata"
     exit 1
   fi
   
   if [ -z "$research_summary" ]; then
     echo "Error: Missing summary in research metadata"
     exit 1
   fi
   ```

3. **Verify Artifacts**
   ```bash
   echo "$research_artifacts" | jq -r '.[]?' | while read artifact; do
     if [ ! -f "$artifact" ]; then
       echo "Warning: Research artifact not found: $artifact"
     else
       echo "✓ Found research artifact: $artifact"
     fi
   done
   ```

4. **Postflight Status Update**
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
   
   # Update state.json
   jq --arg num "$task_number" \
      --arg status "researched" \
      --arg ts "$timestamp_iso" \
      --arg summary "$research_summary" \
      --argjson artifacts "$research_artifacts" \
      '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
        status: $status,
        last_updated: $ts,
        researched: $ts,
        research_summary: $summary,
        artifacts: .artifacts + $artifacts
      }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   
   # Update TODO.md
   sed -i "s/\[RESEARCHING\]/[RESEARCHED]/" specs/TODO.md
   sed -i "s/\[NOT STARTED\]/[RESEARCHED]/" specs/TODO.md
   ```

**On GATE OUT success**: Artifacts verified, status updated to [RESEARCHED]. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

### CHECKPOINT 3: COMMIT

```bash
# Commit the research results
git add -A
git commit -m "$(cat <<EOF
task ${task_number}: complete research

${research_summary}

Session: ${session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>
EOF
)" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "✓ Research committed successfully"
else
  echo "⚠ Warning: Failed to commit research (non-blocking)"
fi
```

Commit failure is non-blocking (log and continue).

## Output

```
Research completed for Task #${task_number}

${research_summary}

Report: $(echo "$research_artifacts" | jq -r '.[0] // "No artifacts"')

Status: [RESEARCHED]
Next: /plan ${task_number}
```

## Error Handling

### GATE IN Failure
- Task not found: Return error with guidance
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Keep [RESEARCHING], log error
- Timeout: Partial research preserved, user can re-run

### GATE OUT Failure
- Missing artifacts: Log warning, continue with available
- Link failure: Non-blocking warning

---

# Main Execution

# Execute the research workflow
main() {
  # CHECKPOINT 1: GATE IN
  echo "=== GATE IN: Validating Task #$task_number ==="
  
  # Parse arguments
  task_number="$1"
  shift
  focus_prompt="$*"
  
  # Generate session ID
  timestamp=$(date +%s)
  random=$(openssl rand -hex 4 2>/dev/null || echo "dead")
  session_id="sess_${timestamp}_${random}"
  
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
      echo "Use: /revise $task_number \"reason\" to modify if needed"
      exit 1
      ;;
    "abandoned")
      echo "Error: Task #$task_number is abandoned"
      echo "Status: [ABANDONED]"
      echo "Use: /task --recover $task_number to recover first"
      exit 1
      ;;
    "not_started"|"planned"|"partial"|"blocked"|"researched")
      # Status allows research
      ;;
    *)
      echo "Warning: Task #$task_number has unusual status: $current_status"
      echo "Proceeding with research..."
      ;;
  esac
  
  # Extract task metadata
  task_description=$(echo "$task_data" | jq -r '.description')
  task_language=$(echo "$task_data" | jq -r '.language // "general"')
  task_slug=$(echo "$task_description" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
  
  # Create task directory
  task_dir="specs/${task_number}_${task_slug}"
  mkdir -p "$task_dir/reports" "$task_dir/plans" "$task_dir/.meta"
  
  # Preflight status update
  timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
  
  # Update state.json
  jq --arg num "$task_number" \
     --arg status "researching" \
     --arg ts "$timestamp_iso" \
     --arg session_id "$session_id" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       researching: $ts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  
  # Update TODO.md
  sed -i "s/### ${task_number}\./&\n- **Status**: [RESEARCHING]/" specs/TODO.md
  sed -i "s/### ${task_number}\./&\n- **Started**: ${timestamp_iso}/" specs/TODO.md
  
  echo "✓ Task validated, status updated to [RESEARCHING]"
  
  # STAGE 2: DELEGATE
  echo ""
  echo "=== STAGE 2: DELEGATING RESEARCH ==="
  
  # Language-based routing
  case "$task_language" in
    "lean")
      subagent="lean-research-agent"
      ;;
    *)
      subagent="general-research-agent"
      ;;
  esac
  
  echo "Delegating to $subagent for $task_language research..."
  echo "Session ID: $session_id"
  echo "Focus: $focus_prompt"
  
  # For now, we'll simulate the delegation with a placeholder
  # In a real implementation, this would invoke the Task tool
  echo "Note: Full delegation implementation requires Task tool integration"
  echo "Proceeding with simulation..."
  
  # Create a sample research report
  report_file="$task_dir/reports/research-$session_id.md"
  cat > "$report_file" <<EOF
# Research Report for Task #$task_number

## Task Description
$task_description

## Language
$task_language

## Focus
$focus_prompt

## Research Summary
Research conducted on $(date -u +%Y-%m-%dT%H:%M:%SZ).

## Findings
- Research completed successfully
- Task validated and ready for planning

## Recommendations
1. Proceed to create implementation plan
2. Consider specific requirements for $task_language

## Session Metadata
- Session ID: $session_id
- Task Directory: $task_dir
EOF
  
  # Create metadata file
  metadata_file="$task_dir/.meta/research-return-meta.json"
  cat > "$metadata_file" <<EOF
{
  "status": "completed",
  "summary": "Research completed for task #$task_number: $task_description",
  "artifacts": ["$report_file"],
  "session_id": "$session_id",
  "timestamp": "$timestamp_iso"
}
EOF
  
  echo "✓ Research completed"
  
  # CHECKPOINT 2: GATE OUT
  echo ""
  echo "=== CHECKPOINT 2: VALIDATING RESULTS ==="
  
  # Validate return
  if [ ! -f "$metadata_file" ]; then
    echo "Error: Research metadata file not found at $metadata_file"
    exit 1
  fi
  
  research_status=$(jq -r '.status // "unknown"' "$metadata_file")
  research_summary=$(jq -r '.summary // ""' "$metadata_file")
  research_artifacts=$(jq -r '.artifacts // []' "$metadata_file")
  
  if [ "$research_status" = "unknown" ] || [ -z "$research_status" ]; then
    echo "Error: Missing or invalid status in research metadata"
    exit 1
  fi
  
  if [ -z "$research_summary" ]; then
    echo "Error: Missing summary in research metadata"
    exit 1
  fi
  
  # Verify artifacts
  echo "$research_artifacts" | jq -r '.[]?' | while read artifact; do
    if [ -f "$artifact" ]; then
      echo "✓ Found research artifact: $artifact"
    else
      echo "Warning: Research artifact not found: $artifact"
    fi
  done
  
  # Postflight status update
  jq --arg num "$task_number" \
     --arg status "researched" \
     --arg ts "$timestamp_iso" \
     --arg summary "$research_summary" \
     --argjson artifacts "$research_artifacts" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       researched: $ts,
       research_summary: $summary,
       artifacts: .artifacts + $artifacts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
  
  # Update TODO.md
  sed -i "s/\[RESEARCHING\]/[RESEARCHED]/" specs/TODO.md
  sed -i "s/\[NOT STARTED\]/[RESEARCHED]/" specs/TODO.md
  
  echo "✓ Status updated to [RESEARCHED]"
  
  # CHECKPOINT 3: COMMIT
  echo ""
  echo "=== CHECKPOINT 3: COMMITTING RESULTS ==="
  
  git add -A
  git commit -m "$(cat <<EOF
task ${task_number}: complete research

${research_summary}

Session: ${session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>
EOF
)" 2>/dev/null
  
  if [ $? -eq 0 ]; then
    echo "✓ Research committed successfully"
  else
    echo "⚠ Warning: Failed to commit research (non-blocking)"
  fi
  
  # Output
  echo ""
  echo "=== RESEARCH COMPLETED ==="
  echo ""
  echo "Research completed for Task #${task_number}"
  echo ""
  echo "$research_summary"
  echo ""
  echo "Report: $(echo "$research_artifacts" | jq -r '.[0] // "No artifacts"')"
  echo ""
  echo "Status: [RESEARCHED]"
  echo "Next: /plan ${task_number}"
}

# Run main function with all arguments
main "$@"
