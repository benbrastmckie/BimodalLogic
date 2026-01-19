---
name: skill-implementer
description: Execute general implementation tasks following a plan. Invoke for non-Lean implementation work.
allowed-tools: Task, Bash, Edit, Read
# Original context (now loaded by subagent):
#   - .claude/context/core/formats/summary-format.md
#   - .claude/context/core/standards/code-patterns.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep, Bash
---

# Implementer Skill

Thin wrapper that delegates general implementation to `general-implementation-agent` subagent.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at CHECKPOINT 2
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:
- Task language is "general", "meta", or "markdown"
- /implement command is invoked
- Plan exists and task is ready for implementation

---

## Execution

### 0. Preflight Status Update

Before delegating to the subagent, update task status to "implementing".

**Reference**: `@.claude/context/core/patterns/inline-status-update.md`

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "implementing" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid,
    started: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker from `[PLANNED]` to `[IMPLEMENTING]`.

---

### 1. Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- Task status must allow implementation (planned, implementing, partial)

```bash
# Lookup task
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  specs/state.json)

# Validate exists
if [ -z "$task_data" ]; then
  return error "Task $task_number not found"
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')

# Validate status
if [ "$status" = "completed" ]; then
  return error "Task already completed"
fi
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "implement", "skill-implementer"],
  "timeout": 7200,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "{language}"
  },
  "plan_path": "specs/{N}_{SLUG}/plans/implementation-{NNN}.md"
}
```

### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `general-implementation-agent`

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "general-implementation-agent"
  - prompt: [Include task_context, delegation_context, plan_path]
  - description: "Execute implementation for task {N}"
```

**DO NOT** use `Skill(general-implementation-agent)` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The subagent will:
- Load implementation context files
- Parse plan and find resume point
- Execute phases sequentially
- Create/modify files as needed
- Create implementation summary
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: implemented, partial, failed, blocked
- Summary is non-empty and <100 tokens
- Artifacts array present (implementation summary, modified files)
- Metadata contains session_id, agent_type, delegation info

### 5. Postflight Status Update

After implementation, update task status based on result.

**Reference**: `@.claude/context/core/patterns/inline-status-update.md`

**If result.status == "implemented"**:

Update state.json to "completed" (two-step to avoid jq escaping bug - see `jq-escaping-workarounds.md`):
```bash
# Step 1: Update status and timestamps
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "completed" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    completed: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add artifact
jq --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    ([(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "summary")] + [{"path": $path, "type": "summary"}])' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

Update TODO.md:
- Change status marker from `[IMPLEMENTING]` to `[COMPLETED]`
- Add summary artifact link: `- **Summary**: [implementation-summary-{DATE}.md]({artifact_path})`

**If result.status == "partial"**:

Update state.json with resume point (keep status as "implementing"):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg phase "$completed_phase" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    last_updated: $ts,
    resume_phase: ($phase | tonumber + 1)
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

TODO.md stays as `[IMPLEMENTING]`.

**On failed**: Do NOT run postflight. Keep status as "implementing" for retry.

### 6. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "implemented",
  "summary": "Implemented all N phases successfully",
  "artifacts": [
    {
      "type": "summary",
      "path": "specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md",
      "summary": "Implementation completion summary"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "general-implementation-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "general-implementation-agent"]
  },
  "next_steps": "Implementation finished. Run /task --sync to verify."
}
```

Expected partial return (timeout/error):
```json
{
  "status": "partial",
  "summary": "Completed phases 1-2, paused at phase 3",
  "artifacts": [...],
  "errors": [{
    "type": "timeout",
    "message": "Implementation exceeded timeout",
    "recoverable": true,
    "recommendation": "Run /implement {N} to resume"
  }],
  "next_steps": "Run /implement {N} to resume from phase 3"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if task not found or status invalid.

### Subagent Errors
Pass through the subagent's error return verbatim.

### Timeout
Return partial status if subagent times out (default 7200s).
