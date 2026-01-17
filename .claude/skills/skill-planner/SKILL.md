---
name: skill-planner
description: Create phased implementation plans from research findings. Invoke when a task needs an implementation plan.
allowed-tools: Task
context: fork
agent: planner-agent
# Original context (now loaded by subagent):
#   - .claude/context/core/formats/plan-format.md
#   - .claude/context/core/workflows/task-breakdown.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep
---

# Planner Skill

Thin wrapper that delegates plan creation to `planner-agent` subagent.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at CHECKPOINT 2
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:
- Task status allows planning (not_started, researched)
- /plan command is invoked
- Implementation approach needs to be formalized

---

## Execution

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

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `planner-agent`

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "planner-agent"
  - prompt: [Include task_context, delegation_context, research_path if available]
  - description: "Execute planning for task {N}"
```

**DO NOT** use `Skill(planner-agent)` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The subagent will:
- Load planning context files
- Analyze task requirements and research
- Decompose into logical phases
- Identify risks and mitigations
- Create plan in `specs/{N}_{SLUG}/plans/`
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: completed, partial, failed, blocked
- Summary is non-empty and <100 tokens
- Artifacts array present with plan path
- Metadata contains session_id, agent_type, delegation info

### 5. Return Propagation

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

### Input Validation Errors
Return immediately with failed status if task not found or status invalid.

### Subagent Errors
Pass through the subagent's error return verbatim.

### Timeout
Return partial status if subagent times out (default 1800s).
