---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(mkdir:*), Bash(date:*), Bash(od:*), Bash(tr:*), Read, Edit
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
---

# /research Command

Conduct research for a task by delegating to the appropriate research skill/subagent.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Execution

### CHECKPOINT 1: GATE IN (Preflight)

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   task_number="$1"
   shift
   focus_prompt="$*"
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
     "not_started"|"planned"|"partial"|"blocked"|"researched")
       # Status allows research
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

8. **Preflight Status Update**
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

   # Update state.json to "researching"
   jq --arg num "$task_number" \
      --arg status "researching" \
      --arg ts "$timestamp_iso" \
      --arg sid "$session_id" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       session_id: $sid
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   **Update TODO.md**: Use Edit tool to change status marker to `[RESEARCHING]`.

**ABORT** if any validation fails.

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
skill: "{skill-name from table above}"
args: "task_number={N} session_id={session_id} task_dir={task_dir} focus_prompt={focus_prompt}"
```

The skill will spawn the appropriate agent to conduct research and create a report.

**On DELEGATE success**: Skill returns text summary. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT (Postflight)

1. **Read Metadata File**
   ```bash
   metadata_file="${task_dir}/.meta/research-return-meta.json"

   if [ ! -f "$metadata_file" ]; then
     echo "Error: Research metadata file not found at $metadata_file"
     echo "The skill may have failed to complete properly"
     # Keep status as "researching" for retry
     exit 1
   fi

   # Extract metadata
   research_status=$(jq -r '.status // "unknown"' "$metadata_file")
   research_summary=$(jq -r '.summary // ""' "$metadata_file")
   artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
   artifact_type=$(jq -r '.artifacts[0].type // "research"' "$metadata_file")
   artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
   ```

2. **Validate Required Fields**
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

3. **Verify Artifact Exists**
   ```bash
   if [ -n "$artifact_path" ] && [ -f "$artifact_path" ]; then
     echo "Found research artifact: $artifact_path"
   else
     echo "Warning: Research artifact not found: $artifact_path"
   fi
   ```

4. **Postflight Status Update**

   **If research_status is "researched"**:
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

   # Update state.json to "researched"
   jq --arg num "$task_number" \
      --arg status "researched" \
      --arg ts "$timestamp_iso" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       researched: $ts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   **Update TODO.md**: Use Edit tool to change status marker from `[RESEARCHING]` to `[RESEARCHED]`.

   **If research_status is "partial"**:
   Keep status as "researching" for resume. Do not update TODO.md.

5. **Link Artifacts**

   Add artifact to state.json (two-step pattern for Issue #1132):
   ```bash
   if [ -n "$artifact_path" ]; then
     # Step 1: Filter out existing research artifacts
     jq --arg num "$task_number" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts =
         [(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts // [] | .[] | select(.type != "research")]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

     # Step 2: Add new research artifact
     jq --arg num "$task_number" \
        --arg path "$artifact_path" \
        --arg type "$artifact_type" \
        --arg summary "$artifact_summary" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   fi
   ```

   **Update TODO.md**: Add research artifact link:
   ```markdown
   - **Research**: [{filename}]({artifact_path})
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
task {N}: complete research

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

```
Research completed for Task #{N}

{research_summary}

Report: {artifact_path}

Status: [RESEARCHED]
Next: /plan {N}
```

## Error Handling

### GATE IN Failure
- Task not found: Return error with guidance
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Keep [RESEARCHING], log error
- Timeout: Partial research preserved, user can re-run

### GATE OUT Failure
- Missing metadata file: Keep [RESEARCHING], report error
- Missing artifacts: Log warning, continue with status update
- Link failure: Non-blocking warning
