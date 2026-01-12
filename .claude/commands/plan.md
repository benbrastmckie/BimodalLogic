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

### 1. Parse and Validate

```
task_number = $ARGUMENTS
```

**Lookup task via jq**:
```bash
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .claude/specs/state.json)

# Validate task exists
if [ -z "$task_data" ]; then
  echo "Error: Task $task_number not found in state.json"
  exit 1
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
```

### 2. Validate Status

Allowed: not_started, researched, partial
- If planned: Note existing plan, offer --force for revision
- If completed: Error "Task already completed"
- If implementing: Error "Task in progress, use /revise instead"

### 3. Load Context

Gather context for the planner:
1. **Task description** from state.json
2. **Research reports** from `.claude/specs/{N}_{SLUG}/reports/` (if any exist)

### 4. Update Status to PLANNING

Update both files atomically:

**state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "planning",
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**TODO.md** (via Edit tool):
Update the status marker from current status to `[PLANNING]`

### 5. Invoke Planner Skill

Invoke **skill-planner** via the **Skill tool**:

```
Invoke skill-planner with:
- task_number: {N}
- research_path: {path to research report if exists}
```

The skill will spawn `planner-agent` via Task tool which will:
- Load planning context files
- Analyze task requirements and research findings
- Decompose into logical phases
- Identify risks and mitigations
- Create plan in `.claude/specs/{N}_{SLUG}/plans/`
- Return JSON result

### 6. Handle Skill Result

The skill returns a JSON result:

```json
{
  "status": "completed|partial|failed",
  "summary": "Created N-phase implementation plan",
  "artifacts": [
    {
      "type": "plan",
      "path": ".claude/specs/{N}_{SLUG}/plans/implementation-{NNN}.md",
      "summary": "Phased implementation plan"
    }
  ],
  "metadata": {
    "phase_count": 3,
    "estimated_hours": 8
  },
  "next_steps": "Run /implement {N} to execute the plan"
}
```

**On completed**: Proceed to step 7
**On partial**: Log partial status, proceed with partial state
**On failed**: Log error, keep status as planning, output error

### 7. Update Status to PLANNED

Update both files atomically:

**state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "planned",
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**TODO.md** (via Edit tool):
- Update status marker to `[PLANNED]`
- Add plan link if not already present

### 8. Git Commit

```bash
git add .claude/specs/
git commit -m "task {N}: create implementation plan

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### 9. Output

```
Plan created for Task #{N}

Plan: {artifact_path from skill result}

Phases: {phase_count from metadata}
Total estimated effort: {estimated_hours from metadata}

Status: [PLANNED]
Next: /implement {N}
```

## Error Handling

### Skill Invocation Failure
If the Skill tool fails to invoke:
1. Log the error
2. Keep status as [PLANNING]
3. Output error message with recovery instructions

### Subagent Timeout
If the subagent times out:
1. Skill returns partial status
2. Partial plan is preserved
3. User can re-run /plan to continue

### Task Not Found
Return immediately with clear error message.
