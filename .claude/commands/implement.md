---
description: Execute implementation with resume support
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Bash(mkdir:*), Bash(date:*), Bash(od:*), Bash(tr:*), Bash(ls:*), Bash(grep:*), Bash(sed:*), Read, Edit, Glob
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /implement Command

Execute implementation plan with automatic resume support by delegating to the appropriate implementation skill/subagent.

## Arguments

- `$1` - Task number (required)
- Optional: `--force` to override status validation

## Execution

### CHECKPOINT 1: GATE IN (Preflight)

1. **Generate Session ID**
   ```bash
   session_id="sess_$(date +%s)_$(od -An -N3 -tx1 /dev/urandom | tr -d ' ')"
   ```

2. **Parse Arguments**
   ```bash
   task_number="$1"
   force_flag=false
   if [ "$2" = "--force" ]; then
     force_flag=true
   fi
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
       if [ "$force_flag" = false ]; then
         echo "Error: Task #$task_number is already completed"
         echo "Use --force to re-implement"
         exit 1
       fi
       ;;
     "abandoned")
       echo "Error: Task #$task_number is abandoned. Use /task --recover first"
       exit 1
       ;;
     "planned"|"implementing"|"partial"|"researched"|"not_started")
       # Status allows implementation
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
   mkdir -p "$task_dir/reports" "$task_dir/plans" "$task_dir/summaries" "$task_dir/.meta"
   ```

8. **Find Implementation Plan**
   ```bash
   plan_path=""
   if ls "$task_dir/plans/implementation-"*.md 1>/dev/null 2>&1; then
     plan_path=$(ls -1 "$task_dir/plans/implementation-"*.md | sort -V | tail -1)
   fi

   if [ -z "$plan_path" ] || [ ! -f "$plan_path" ]; then
     echo "Error: No implementation plan found for task #$task_number"
     echo "Run: /plan $task_number first"
     exit 1
   fi
   ```

9. **Detect Resume Point**
   ```bash
   resume_phase=1
   # Scan plan for phase status markers
   if grep -q '\[IN PROGRESS\]' "$plan_path"; then
     # Resume from in-progress phase
     resume_phase=$(grep -n '\[IN PROGRESS\]' "$plan_path" | head -1 | grep -oP 'Phase \K\d+')
   elif grep -q '\[PARTIAL\]' "$plan_path"; then
     # Resume from partial phase
     resume_phase=$(grep -n '\[PARTIAL\]' "$plan_path" | head -1 | grep -oP 'Phase \K\d+')
   else
     # Find first NOT STARTED phase
     first_not_started=$(grep -n '\[NOT STARTED\]' "$plan_path" | head -1 | grep -oP 'Phase \K\d+')
     if [ -n "$first_not_started" ]; then
       resume_phase=$first_not_started
     fi
   fi
   ```

10. **Preflight Status Update**
    ```bash
    timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Update state.json to "implementing"
    jq --arg num "$task_number" \
       --arg status "implementing" \
       --arg ts "$timestamp_iso" \
       --arg sid "$session_id" \
      '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
        status: $status,
        last_updated: $ts,
        session_id: $sid,
        started: (if .started then .started else $ts end)
      }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
    ```

    **Update TODO.md**: Use Edit tool to change status marker to `[IMPLEMENTING]`.

    **Update plan file**: Update the Status field to `[IMPLEMENTING]`:
    ```bash
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [IMPLEMENTING]/" "$plan_path"
    ```

**ABORT** if any validation fails.

**On GATE IN success**: Task validated, status updated to [IMPLEMENTING]. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Language-Based Routing**:

| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-implementation` |
| `latex` | `skill-latex-implementation` |
| `general`, `meta`, `markdown` | `skill-implementer` |

**Invoke the Skill tool NOW** with:
```
skill: "{skill-name from table above}"
args: "task_number={N} session_id={session_id} task_dir={task_dir} plan_path={plan_path} resume_phase={resume_phase}"
```

The skill will spawn the appropriate agent to execute the implementation plan.

**On DELEGATE success**: Skill returns text summary. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT (Postflight)

1. **Read Metadata File**
   ```bash
   metadata_file="${task_dir}/.meta/implement-return-meta.json"

   if [ ! -f "$metadata_file" ]; then
     echo "Error: Implementation metadata file not found at $metadata_file"
     echo "The skill may have failed to complete properly"
     # Keep status as "implementing" for retry
     exit 1
   fi

   # Extract metadata
   impl_status=$(jq -r '.status // "unknown"' "$metadata_file")
   impl_summary=$(jq -r '.summary // ""' "$metadata_file")
   artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
   artifact_type=$(jq -r '.artifacts[0].type // "summary"' "$metadata_file")
   artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
   phases_completed=$(jq -r '.metadata.phases_completed // 0' "$metadata_file")
   phases_total=$(jq -r '.metadata.phases_total // 0' "$metadata_file")

   # Extract completion_data
   completion_summary=$(jq -r '.completion_data.completion_summary // ""' "$metadata_file")
   claudemd_suggestions=$(jq -r '.completion_data.claudemd_suggestions // ""' "$metadata_file")
   roadmap_items=$(jq -c '.completion_data.roadmap_items // []' "$metadata_file")
   ```

2. **Validate Required Fields**
   ```bash
   if [ "$impl_status" = "unknown" ] || [ -z "$impl_status" ]; then
     echo "Error: Missing or invalid status in implementation metadata"
     exit 1
   fi

   if [ -z "$impl_summary" ]; then
     echo "Error: Missing summary in implementation metadata"
     exit 1
   fi
   ```

3. **Verify Artifact Exists (if implemented)**
   ```bash
   if [ "$impl_status" = "implemented" ]; then
     if [ -n "$artifact_path" ] && [ -f "$artifact_path" ]; then
       echo "Found implementation summary: $artifact_path"
     else
       echo "Warning: Implementation summary not found: $artifact_path"
     fi
   fi
   ```

4. **Postflight Status Update**

   **If impl_status is "implemented"**:
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

   # Step 1: Update status to "completed"
   jq --arg num "$task_number" \
      --arg status "completed" \
      --arg ts "$timestamp_iso" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       status: $status,
       last_updated: $ts,
       completed: $ts
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

   # Step 2: Add completion_summary
   if [ -n "$completion_summary" ]; then
     jq --arg num "$task_number" \
        --arg summary "$completion_summary" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).completion_summary = $summary' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   fi

   # Step 3: Add language-specific completion fields
   # For meta tasks: add claudemd_suggestions
   if [ "$task_language" = "meta" ] && [ -n "$claudemd_suggestions" ]; then
     jq --arg num "$task_number" \
        --arg suggestions "$claudemd_suggestions" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).claudemd_suggestions = $suggestions' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   fi

   # For non-meta tasks: add roadmap_items (if present and non-empty)
   if [ "$task_language" != "meta" ] && [ "$roadmap_items" != "[]" ] && [ -n "$roadmap_items" ]; then
     jq --arg num "$task_number" \
        --argjson items "$roadmap_items" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).roadmap_items = $items' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   fi
   ```

   **Update TODO.md**: Use Edit tool to change status marker from `[IMPLEMENTING]` to `[COMPLETED]`.

   **Update plan file**: Update the Status field to `[COMPLETED]`:
   ```bash
   sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [COMPLETED]/" "$plan_path"
   ```

   **If impl_status is "partial"**:
   ```bash
   timestamp_iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)

   # Update resume point only
   jq --arg num "$task_number" \
      --arg ts "$timestamp_iso" \
      --argjson phase "$phases_completed" \
     '(.active_projects[] | select(.project_number == ($num | tonumber))) |= . + {
       last_updated: $ts,
       resume_phase: ($phase + 1)
     }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   ```

   TODO.md stays as `[IMPLEMENTING]`.

   **Update plan file**: Update the Status field to `[PARTIAL]`:
   ```bash
   sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_path"
   ```

5. **Link Artifacts (if implemented)**

   Add artifact to state.json (two-step pattern for Issue #1132):
   ```bash
   if [ "$impl_status" = "implemented" ] && [ -n "$artifact_path" ]; then
     # Step 1: Filter out existing summary artifacts
     jq --arg num "$task_number" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts =
         [(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts // [] | .[] | select(.type != "summary")]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

     # Step 2: Add new summary artifact
     jq --arg num "$task_number" \
        --arg path "$artifact_path" \
        --arg type "$artifact_type" \
        --arg summary "$artifact_summary" \
       '(.active_projects[] | select(.project_number == ($num | tonumber))).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
       specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
   fi
   ```

   **Update TODO.md**: Add summary artifact link:
   ```markdown
   - **Summary**: [{filename}]({artifact_path})
   ```

6. **Cleanup Metadata File**
   ```bash
   rm -f "$metadata_file"
   ```

**On GATE OUT success**: Status updated, artifacts linked. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

### CHECKPOINT 3: COMMIT

**On completion:**
```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: complete implementation

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

**On partial:**
```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: partial implementation (phases 1-{M} of {total})

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

**On Completion:**
```
Implementation complete for Task #{N}

{impl_summary}

Summary: {artifact_path}
Phases completed: {phases_completed}/{phases_total}

Status: [COMPLETED]
```

**On Partial:**
```
Implementation paused for Task #{N}

{impl_summary}

Completed: Phases 1-{M}
Remaining: Phase {M+1}

Status: [IMPLEMENTING]
Next: /implement {N} (will resume from Phase {M+1})
```

## Error Handling

### GATE IN Failure
- Task not found: Return error with guidance
- No plan found: Return error "Run /plan {N} first"
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Keep [IMPLEMENTING], log error
- Timeout: Progress preserved in plan phase markers, user can re-run

### GATE OUT Failure
- Missing metadata file: Keep [IMPLEMENTING], report error
- Missing artifacts: Log warning, continue with status update
- Link failure: Non-blocking warning

### Build Errors
- Skill returns partial/failed status
- Error details included in result
- User can fix issues and re-run /implement
