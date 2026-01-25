---
description: Create implementation plan for a task
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(mkdir:*), Bash(date:*), Bash(od:*), Bash(tr:*), Bash(ls:*), Read, Edit, Glob
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /plan Command

Create a phased implementation plan for a task by delegating to the planner skill/subagent.

## Arguments

- `$1` - Task number (required)

## Execution

### CHECKPOINT 1: GATE IN (Preflight)

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   task_number="$1"
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
     exit 1
   fi
   ```

5. **Validate Status**
   ```bash
   current_status=$(echo "$task_data" | jq -r '.status')

   case "$current_status" in
     "completed")
       echo "Error: Task #$task_number is already completed"
       exit 1
       ;;
     "abandoned")
       echo "Error: Task #$task_number is abandoned. Use /task --recover first"
       exit 1
       ;;
     "implementing")
       echo "Error: Task #$task_number is in progress. Use /revise instead"
       exit 1
       ;;
     "not_started"|"researched"|"partial"|"planned")
       # Status allows planning
       ;;
     *)
       echo "Warning: Unusual status: $current_status. Proceeding..."
       ;;
   esac
   ```

6. **Extract Task Metadata**
   ```bash
   task_description=$(echo "$task_data" | jq -r '.description')
   task_language=$(echo "$task_data" | jq -r '.language // "general"')
   project_name=$(echo "$task_data" | jq -r '.project_name')
   ```

7. **Create Task Directory**
   ```bash
   task_dir="specs/${task_number}_${project_name}"
   mkdir -p "$task_dir/reports" "$task_dir/plans" "$task_dir/.meta"
   ```

8. **Find Research Report (if exists)**
   ```bash
   research_path=""
   if ls "$task_dir/reports/research-"*.md 1>/dev/null 2>&1; then
     research_path=$(ls -1 "$task_dir/reports/research-"*.md | sort -V | tail -1)
   fi
   ```

9. **Preflight Status Update**
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

   # Update state.json to "planning"
   jq --arg num "$task_number" \
      --arg status "planning" \
      --arg ts "$timestamp_iso" \
      --arg sid "$session_id" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       session_id: $sid
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   **Update TODO.md**: Use Edit tool to change status marker to `[PLANNING]`.

**ABORT** if any validation fails.

**On GATE IN success**: Task validated, status updated to [PLANNING]. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-planner"
args: "task_number={N} session_id={session_id} task_dir={task_dir} research_path={research_path}"
```

The skill will spawn `planner-agent` to create an implementation plan.

**On DELEGATE success**: Skill returns text summary. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT (Postflight)

1. **Read Metadata File**
   ```bash
   metadata_file="${task_dir}/.meta/plan-return-meta.json"

   if [ ! -f "$metadata_file" ]; then
     echo "Error: Plan metadata file not found at $metadata_file"
     echo "The skill may have failed to complete properly"
     # Keep status as "planning" for retry
     exit 1
   fi

   # Extract metadata
   plan_status=$(jq -r '.status // "unknown"' "$metadata_file")
   plan_summary=$(jq -r '.summary // ""' "$metadata_file")
   artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
   artifact_type=$(jq -r '.artifacts[0].type // "plan"' "$metadata_file")
   artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
   phase_count=$(jq -r '.metadata.phase_count // 0' "$metadata_file")
   estimated_hours=$(jq -r '.metadata.estimated_hours // "unknown"' "$metadata_file")
   ```

2. **Validate Required Fields**
   ```bash
   if [ "$plan_status" = "unknown" ] || [ -z "$plan_status" ]; then
     echo "Error: Missing or invalid status in plan metadata"
     exit 1
   fi

   if [ -z "$plan_summary" ]; then
     echo "Error: Missing summary in plan metadata"
     exit 1
   fi
   ```

3. **Verify Artifact Exists**
   ```bash
   if [ -n "$artifact_path" ] && [ -f "$artifact_path" ]; then
     echo "Found plan artifact: $artifact_path"
   else
     echo "Warning: Plan artifact not found: $artifact_path"
   fi
   ```

4. **Postflight Status Update**

   **If plan_status is "planned"**:
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

   # Update state.json to "planned"
   jq --arg num "$task_number" \
      --arg status "planned" \
      --arg ts "$timestamp_iso" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       planned: $ts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   **Update TODO.md**: Use Edit tool to change status marker from `[PLANNING]` to `[PLANNED]`.

   **If plan_status is "partial"**:
   Keep status as "planning" for resume. Do not update TODO.md.

5. **Link Artifacts**

   Add artifact to state.json (two-step pattern for Issue #1132):
   ```bash
   if [ -n "$artifact_path" ]; then
     # Step 1: Filter out existing plan artifacts
     jq --arg num "$task_number" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts =
         [(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts // [] | .[] | select(.type != "plan")]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

     # Step 2: Add new plan artifact
     jq --arg num "$task_number" \
        --arg path "$artifact_path" \
        --arg type "$artifact_type" \
        --arg summary "$artifact_summary" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   fi
   ```

   **Update TODO.md**: Add plan artifact link:
   ```markdown
   - **Plan**: [{filename}]({artifact_path})
   ```

6. **Cleanup Metadata File**
   ```bash
   rm -f "$metadata_file"
   ```

**On GATE OUT success**: Status updated, artifacts linked. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

### CHECKPOINT 3: COMMIT

```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: create implementation plan

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

```
Plan created for Task #{N}

{plan_summary}

Plan: {artifact_path}
Phases: {phase_count}
Estimated effort: {estimated_hours} hours

Status: [PLANNED]
Next: /implement {N}
```

## Error Handling

### GATE IN Failure
- Task not found: Return error with guidance
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Keep [PLANNING], log error
- Timeout: Partial plan preserved, user can re-run

### GATE OUT Failure
- Missing metadata file: Keep [PLANNING], report error
- Missing artifacts: Log warning, continue with status update
- Link failure: Non-blocking warning
