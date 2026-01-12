---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
---

# /research Command

Conduct research for a task by delegating to the appropriate research skill/subagent.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Execution

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```
   session_id = sess_{timestamp}_{random}
   ```

2. **Lookup Task**
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     .claude/specs/state.json)
   ```

3. **Validate**
   - Task exists (ABORT if not)
   - Status allows research: not_started, planned, partial, blocked, researched
   - If completed/abandoned: ABORT with recommendation

4. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `preflight_update(task_number, "researching", session_id)`

5. **Verify** status is now "researching"

**ABORT** if any validation fails. **PROCEED** if all pass.

### STAGE 2: DELEGATE

Route by language (see routing.md):

| Language | Skill |
|----------|-------|
| lean | skill-lean-research |
| other | skill-researcher |

Invoke skill with:
- task_number: {N}
- focus_prompt: {optional focus}
- session_id: {session_id}

Skill spawns appropriate agent which:
- Conducts research using language-appropriate tools
- Creates report in `.claude/specs/{N}_{SLUG}/reports/`
- Returns structured result

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts

2. **Verify Artifacts**
   Check each artifact path exists on disk

3. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `postflight_update(task_number, "researched", artifacts, session_id)`

4. **Verify** status is "researched" and artifacts are linked

**PROCEED** to commit. **RETRY** skill if validation fails.

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

Report: {artifact_path from skill result}

Summary: {summary from skill result}

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
- Missing artifacts: Log warning, continue with available
- Link failure: Non-blocking warning
