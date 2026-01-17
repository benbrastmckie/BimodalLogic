---
name: skill-lean-implementation
description: Implement Lean 4 proofs and definitions using lean-lsp tools. Invoke for Lean-language implementation tasks.
allowed-tools: Task
context: fork
agent: lean-implementation-agent
# Original context (now loaded by subagent):
#   - .claude/context/project/lean4/tools/mcp-tools-guide.md
#   - .claude/context/project/lean4/patterns/tactic-patterns.md
#   - .claude/context/project/lean4/standards/lean4-style-guide.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep, Bash(lake *)
#   - mcp__lean-lsp__lean_goal, mcp__lean-lsp__lean_diagnostic_messages
#   - mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_completions
#   - mcp__lean-lsp__lean_multi_attempt, mcp__lean-lsp__lean_local_search
#   - mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise
---

# Lean Implementation Skill

Thin wrapper that delegates Lean proof implementation to `lean-implementation-agent` subagent.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at CHECKPOINT 2
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:
- Task language is "lean"
- /implement command targets a Lean task
- Proofs or definitions need to be written

---

## Execution

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

# Validate language
if [ "$language" != "lean" ]; then
  return error "Task $task_number is not a Lean task"
fi

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
  "delegation_path": ["orchestrator", "implement", "skill-lean-implementation"],
  "timeout": 7200,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "lean"
  },
  "plan_path": "specs/{N}_{SLUG}/plans/implementation-{NNN}.md"
}
```

### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `lean-implementation-agent`

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "lean-implementation-agent"
  - prompt: [Include task_context, delegation_context, plan_path]
  - description: "Execute Lean implementation for task {N}"
```

**DO NOT** use `Skill(lean-implementation-agent)` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The subagent will:
- Load Lean-specific context files
- Use MCP tools (lean_goal, lean_diagnostic_messages, etc.)
- Execute proof development loop
- Create/modify .lean files
- Run lake build to verify
- Create implementation summary
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: completed, partial, failed, blocked
- Summary is non-empty and <100 tokens
- Artifacts array present (implementation files, summary)
- Metadata contains session_id, agent_type, delegation info

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "implemented",
  "summary": "Implemented N theorems with successful lake build",
  "artifacts": [
    {
      "type": "implementation",
      "path": "Logos/Layer{N}/File.lean",
      "summary": "Lean implementation file"
    },
    {
      "type": "summary",
      "path": "specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md",
      "summary": "Implementation completion summary"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "lean-implementation-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "lean-implementation-agent"]
  },
  "next_steps": "Implementation finished. Run /task --sync to verify."
}
```

Expected partial return (proof stuck/timeout):
```json
{
  "status": "partial",
  "summary": "Implemented 2/4 theorems, stuck on theorem3",
  "artifacts": [...],
  "errors": [{
    "type": "execution",
    "message": "Could not complete proof for theorem3",
    "recoverable": true,
    "recommendation": "Try alternative proof approach"
  }],
  "next_steps": "Run /implement {N} to resume"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if task not found, wrong language, or status invalid.

### Subagent Errors
Pass through the subagent's error return verbatim.

### Timeout
Return partial status if subagent times out (default 7200s).
