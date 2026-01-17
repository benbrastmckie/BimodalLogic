---
name: skill-planner
description: Create phased implementation plans from research findings. Invoke when a task needs an implementation plan.
allowed-tools: Task, Bash(jq:*), Read, Edit, Glob, Grep
context: fork
agent: planner-agent
# Original context (now loaded by subagent):
#   - .claude/context/core/formats/plan-format.md
#   - .claude/context/core/workflows/task-breakdown.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep
---

# Planner Skill

Self-contained planning workflow that handles preflight, agent delegation, and postflight internally.

## Context Pointers

Reference (load on-demand):
- `@.claude/context/core/patterns/inline-status-update.md` - Status update patterns
- `@.claude/context/core/patterns/skill-lifecycle.md` - Skill lifecycle pattern

## Trigger Conditions

This skill activates when:
- Task status allows planning (not_started, researched)
- /plan command is invoked
- Implementation approach needs to be formalized

---

## Execution

### 0. Preflight Status Update

Update task to "planning" before starting work:

```bash
# Update state.json
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "planning" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

Then update TODO.md status marker using Edit tool:
- Find the task entry line with `grep -n "^### $task_number\." specs/TODO.md`
- Change `[RESEARCHED]` → `[PLANNING]`

**On preflight success**: Continue to Section 1.
**On preflight failure**: Return error immediately, do not invoke agent.

---

### 1. Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- Task status must allow planning

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
  "delegation_path": ["orchestrator", "plan", "skill-planner"],
  "timeout": 1800,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "{language}"
  },
  "research_path": "{path to research report if exists}"
}
```

### 3. Invoke Subagent

Invoke `planner-agent` via Task tool with:
- Task context (number, name, description, language)
- Delegation context (session_id, depth, path)
- Research report path (if available)

The subagent will:
- Load planning context files
- Analyze task requirements and research
- Decompose into logical phases
- Identify risks and mitigations
- Create plan in `specs/{N}_{SLUG}/plans/`
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: planned, partial, failed, blocked
- Summary is non-empty and <100 tokens
- Artifacts array present with plan path
- Metadata contains session_id, agent_type, delegation info

**On agent success**: Continue to Section 5 (Postflight).
**On agent failure/partial**: Skip postflight, return agent result directly.

---

### 5. Postflight Status Update

Update task to "planned" after successful agent return:

```bash
# Get artifact path from agent result
artifact_path="specs/{N}_{SLUG}/plans/implementation-{NNN}.md"

# Update state.json with status and plan artifact
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "planned" \
   --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    planned: $ts,
    artifacts: ((.artifacts // []) | map(select(.type != "plan"))) + [{"path": $path, "type": "plan"}]
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

Then update TODO.md:
- Change `[PLANNING]` → `[PLANNED]`
- Add/update plan artifact link: `- **Plan**: [implementation-{NNN}.md](specs/{N}_{SLUG}/plans/implementation-{NNN}.md)`

---

### 6. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "planned",
  "summary": "Created N-phase implementation plan",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/{N}_{SLUG}/plans/implementation-{NNN}.md",
      "summary": "Phased implementation plan"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "planner-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "plan", "planner-agent"]
  },
  "next_steps": "Run /implement {N} to execute the plan"
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
Return partial status if subagent times out (default 1800s).
