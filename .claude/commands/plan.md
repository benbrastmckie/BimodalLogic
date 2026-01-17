---
description: Create implementation plan for a task
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /plan Command

Create a phased implementation plan for a task by delegating to the planner skill.

## Arguments

- `$1` - Task number (required)

## Execution

### CHECKPOINT 1: VALIDATE

1. **Generate Session ID**
   ```
   session_id = sess_{timestamp}_{random}
   ```

2. **Lookup Task**
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     specs/state.json)
   ```

3. **Validate**
   - Task exists (ABORT if not)
   - Status allows planning: not_started, researched, partial
   - If planned: Note existing plan, offer --force for revision
   - If completed: ABORT "Task already completed"
   - If implementing: ABORT "Task in progress, use /revise instead"

4. **Load Context**
   - Task description from state.json
   - Research reports from `specs/{N}_{SLUG}/reports/` (if any)

**ABORT** if any validation fails.

**On VALIDATE success**: Task validated. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-planner"
args: "task_number={N} research_path={path to research report if exists} session_id={session_id}"
```

The skill handles:
- Preflight status update (→ PLANNING)
- Agent delegation for plan creation
- Postflight status update (→ PLANNED)
- Artifact linking

**On DELEGATE success**: Plan created with status updated. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

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

### VALIDATE Failure
- Task not found: Return error with guidance
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Status remains as-is, log error
- Timeout: Partial plan preserved, user can re-run

### COMMIT Failure
- Non-blocking: Log warning, continue with output
