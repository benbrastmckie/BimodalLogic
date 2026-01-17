---
name: skill-implementer
description: Execute general implementation tasks following a plan. Invoke for non-Lean implementation work.
allowed-tools: Task, Bash(jq:*), Read, Edit, Glob, Grep
context: fork
agent: general-implementation-agent
# Original context (now loaded by subagent):
#   - .claude/context/core/formats/summary-format.md
#   - .claude/context/core/standards/code-patterns.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep, Bash
---

# Implementer Skill

Self-contained implementation workflow that handles preflight, agent delegation, and postflight internally.

## Context Pointers

Reference (load on-demand):
- `@.claude/context/core/patterns/inline-status-update.md` - Status update patterns
- `@.claude/context/core/patterns/skill-lifecycle.md` - Skill lifecycle pattern

## Trigger Conditions

This skill activates when:
- Task language is "general", "meta", or "markdown"
- /implement command is invoked
- Plan exists and task is ready for implementation

---

## Execution

### 0. Preflight Status Update

Update task to "implementing" before starting work:

```bash
# Update state.json
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

Then update TODO.md status marker using Edit tool:
- Find the task entry line with `grep -n "^### $task_number\." specs/TODO.md`
- Change `[PLANNED]` → `[IMPLEMENTING]`

**On preflight success**: Continue to Section 1.
**On preflight failure**: Return error immediately, do not invoke agent.

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

Invoke `general-implementation-agent` via Task tool with:
- Task context (number, name, description, language)
- Delegation context (session_id, depth, path)
- Plan path for execution

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

**On agent success (status=implemented)**: Continue to Section 5 (Postflight - Completed).
**On agent partial**: Continue to Section 5a (Postflight - Partial).
**On agent failure/blocked**: Skip postflight, return agent result directly.

---

### 5. Postflight Status Update (Completed)

Update task to "completed" after successful agent return:

```bash
# Get artifact path from agent result
artifact_path="specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md"

# Update state.json with status and summary artifact
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "completed" \
   --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    completed: $ts,
    artifacts: ((.artifacts // []) | map(select(.type != "summary"))) + [{"path": $path, "type": "summary"}]
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

Then update TODO.md:
- Change `[IMPLEMENTING]` → `[COMPLETED]`
- Add/update summary artifact link: `- **Summary**: [implementation-summary-{DATE}.md](specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md)`

### 5a. Postflight Status Update (Partial)

Keep task as "implementing" when partially complete:

```bash
# Update state.json with progress note
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg phase "$completed_phase" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    last_updated: $ts,
    resume_phase: ($phase | tonumber + 1)
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

TODO.md stays as `[IMPLEMENTING]`.

---

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

### Preflight Errors
Return immediately with failed status. Do not invoke agent.

### Input Validation Errors
Return immediately with failed status if task not found or status invalid.

### Subagent Errors
Skip postflight, pass through the subagent's error return verbatim.

### Postflight Errors
Log warning but return success - artifacts were created, status can be fixed manually.

### Timeout
Return partial status if subagent times out (default 7200s).
