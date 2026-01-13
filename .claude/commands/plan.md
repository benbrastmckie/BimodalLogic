---
description: Create implementation plan for a task
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /plan Command

Create a phased implementation plan for a task by delegating to the planner skill/subagent.

## Arguments

- `$1` - Task number (required)

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
   - Status allows planning: not_started, researched, partial
   - If planned: Note existing plan, offer --force for revision
   - If completed: ABORT "Task already completed"
   - If implementing: ABORT "Task in progress, use /revise instead"

4. **Load Context**
   - Task description from state.json
   - Research reports from `.claude/specs/{N}_{SLUG}/reports/` (if any)

5. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `preflight_update(task_number, "planning", session_id)`

6. **Verify** status is now "planning"

**ABORT** if any validation fails. **PROCEED** if all pass.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-planner"
args: "task_number={N} research_path={path to research report if exists} session_id={session_id}"
```

The skill spawns `planner-agent` which analyzes task requirements and research findings, decomposes into logical phases, identifies risks and mitigations, and creates a plan in `.claude/specs/{N}_{SLUG}/plans/`.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts, metadata (phase_count, estimated_hours)

2. **Verify Artifacts**
   Check plan file exists on disk

3. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `postflight_update(task_number, "planned", artifacts, session_id)`

4. **Verify** status is "planned" and plan is linked

**PROCEED** to commit. **RETRY** skill if validation fails.

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

Plan: {artifact_path from skill result}

Phases: {phase_count from metadata}
Total estimated effort: {estimated_hours from metadata}

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
- Missing artifacts: Log warning, continue with available
- Link failure: Non-blocking warning
