---
command: plan
description: Create implementation plan for a task
version: "1.0"
mode: command
temperature: 0.2
arguments:
  name: task_number
  type: integer
  required: true
  description: Task number to create a plan for
tools:
  read: true
  write: true
  edit: true
  glob: true
  bash: true
  skill: true
permissions:
  read:
    "**/*.md": "allow"
    ".opencode/**/*": "allow"
    "specs/**/*": "allow"
  write:
    "specs/**/*": "allow"
  bash:
    "git:*": "allow"
    "jq:*": "allow"
    "*": "deny"
allowed_tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
argument_hint: TASK_NUMBER
delegation_depth: 1
max_delegation_depth: 3
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required: "core/workflows/command-lifecycle.md"
---

## Context Loading Guidance

- Routing stages: do not load context.
- Execution stages: use `.opencode/context/index.md` for targeted context loading.


## Context Loading Guidance

- Routing stages: do not load context.
- Execution stages: use `.opencode/context/index.md` for targeted context loading.


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
     specs/state.json)
   ```

3. **Validate**
   - Task exists (ABORT if not)
   - Status allows planning: not_started, researched, partial
   - If planned: Note existing plan, offer --force for revision
   - If completed: ABORT "Task already completed"
   - If implementing: ABORT "Task in progress, use /revise instead"

4. **Load Context**
   - Task description from specs/state.json
   - Research reports from `specs/{N}_{SLUG}/reports/` (if any)

**ABORT** if any validation fails.

**On GATE IN success**: Task validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Invoke the Skill tool NOW** with:
```
skill: "skill-planner"
args: "task_number={N} research_path={path to research report if exists} session_id={session_id}"
```

The skill spawns `planner-agent` which analyzes task requirements and research findings, decomposes into logical phases, identifies risks and mitigations, and creates a plan in `specs/{N}_{SLUG}/plans/`.

**On DELEGATE success**: Plan created. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts, metadata (phase_count, estimated_hours)

2. **Verify Artifacts**
   Check plan file exists on disk

3. **Verify Status Updated**
   The skill handles status updates internally (preflight and postflight).
   Confirm status is now "planned" in specs/state.json.

**RETRY** skill if validation fails.

**On GATE OUT success**: Plan verified. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

### CHECKPOINT 3: COMMIT

```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: create implementation plan

Session: {session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>
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
