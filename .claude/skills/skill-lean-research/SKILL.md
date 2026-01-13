---
name: skill-lean-research
description: Research Lean 4 and Mathlib for theorem proving tasks. Invoke for Lean-language research using LeanSearch, Loogle, and lean-lsp tools.
allowed-tools: Task
context: fork
agent: lean-research-agent
# Original context (now loaded by subagent):
#   - .claude/context/project/lean4/tools/mcp-tools-guide.md
#   - .claude/context/project/lean4/tools/leansearch-api.md
#   - .claude/context/project/lean4/tools/loogle-api.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep
#   - mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle
#   - mcp__lean-lsp__lean_leanfinder, mcp__lean-lsp__lean_local_search
#   - mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_state_search
#   - mcp__lean-lsp__lean_hammer_premise
---

# Lean Research Skill

Thin wrapper that delegates Lean 4 research to `lean-research-agent` subagent.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at CHECKPOINT 2
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:
- Task language is "lean"
- Research involves Mathlib, theorems, or proofs
- Lean-specific MCP tools are needed

---

## Execution

### 1. Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- `focus_prompt` - Optional focus for research direction

```bash
# Lookup task
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .claude/specs/state.json)

# Validate exists
if [ -z "$task_data" ]; then
  return error "Task $task_number not found"
fi

# Extract fields
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "skill-lean-research"],
  "timeout": 3600,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "lean"
  },
  "focus_prompt": "{optional focus}"
}
```

### 3. Invoke Subagent

Invoke `lean-research-agent` via Task tool with:
- Task context (number, name, description, language)
- Delegation context (session_id, depth, path)
- Focus prompt (if provided)

The subagent will:
- Load Lean-specific context files
- Use MCP search tools (leansearch, loogle, leanfinder)
- Create research report in `.claude/specs/{N}_{SLUG}/reports/`
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: completed, partial, failed, blocked
- Summary is non-empty and <100 tokens
- Artifacts array present with research report path
- Metadata contains session_id, agent_type, delegation info

### 5. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "researched",
  "summary": "Found N relevant theorems for proof approach",
  "artifacts": [
    {
      "type": "research",
      "path": ".claude/specs/{N}_{SLUG}/reports/research-{NNN}.md",
      "summary": "Lean research report with theorem findings"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "lean-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "lean-research-agent"]
  },
  "next_steps": "Run /plan {N} to create implementation plan"
}
```

---

## Error Handling

### Input Validation Errors
Return immediately with failed status if task not found.

### Subagent Errors
Pass through the subagent's error return verbatim.

### Timeout
Return partial status if subagent times out (default 3600s).
