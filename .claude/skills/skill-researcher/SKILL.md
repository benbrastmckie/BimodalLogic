---
name: skill-researcher
description: Conduct general research using web search, documentation, and codebase exploration. Invoke for non-Lean research tasks.
allowed-tools: Task, Bash, Edit, Read
# Original context (now loaded by subagent):
#   - .claude/context/core/formats/report-format.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
---

# Researcher Skill

Thin wrapper that delegates general research to `general-research-agent` subagent.

## Context Pointers

Reference (do not load eagerly):
- Path: `.claude/context/core/validation.md`
- Purpose: Return validation at CHECKPOINT 2
- Load at: Subagent execution only

Note: This skill is a thin wrapper. Context is loaded by the delegated agent, not this skill.

## Trigger Conditions

This skill activates when:
- Task language is "general", "meta", or "markdown"
- Research is needed for implementation planning
- Documentation or external resources need to be gathered

---

## Execution

### 0. Preflight Status Update

Before delegating to the subagent, update task status to "researching".

**Reference**: `@.claude/context/core/patterns/inline-status-update.md`

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researching" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker from `[NOT STARTED]` or `[RESEARCHED]` to `[RESEARCHING]`.

---

### 1. Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- `focus_prompt` - Optional focus for research direction

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
```

### 2. Context Preparation

Prepare delegation context:

```json
{
  "session_id": "sess_{timestamp}_{random}",
  "delegation_depth": 1,
  "delegation_path": ["orchestrator", "research", "skill-researcher"],
  "timeout": 3600,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "{language}"
  },
  "focus_prompt": "{optional focus}"
}
```

### 3. Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

The `agent` field in this skill's frontmatter specifies the target: `general-research-agent`

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "general-research-agent"
  - prompt: [Include task_context, delegation_context, focus_prompt if present]
  - description: "Execute research for task {N}"
```

**DO NOT** use `Skill(general-research-agent)` - this will FAIL.
Agents live in `.claude/agents/`, not `.claude/skills/`.
The Skill tool can only invoke skills from `.claude/skills/`.

The subagent will:
- Search codebase for related patterns
- Search web for documentation and examples
- Analyze findings and synthesize recommendations
- Create research report in `specs/{N}_{SLUG}/reports/`
- Return standardized JSON result

### 4. Return Validation

Validate return matches `subagent-return.md` schema:
- Status is one of: researched, partial, failed, blocked
- Summary is non-empty and <100 tokens
- Artifacts array present with research report path
- Metadata contains session_id, agent_type, delegation info

### 5. Postflight Status Update

After successful research, update task status to "researched" and link artifacts.

**Reference**: `@.claude/context/core/patterns/inline-status-update.md`

**Update state.json** (two-step to avoid jq escaping bug - see `jq-escaping-workarounds.md`):
```bash
# Step 1: Update status and timestamps
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "researched" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    researched: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add artifact
jq --arg path "$artifact_path" \
  '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
    ([(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type != "research")] + [{"path": $path, "type": "research"}])' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**:
- Use Edit tool to change status marker from `[RESEARCHING]` to `[RESEARCHED]`
- Add research artifact link: `- **Research**: [research-{NNN}.md]({artifact_path})`

**On partial/failed**: Do NOT run postflight. Keep status as "researching" for resume.

### 6. Return Propagation

Return validated result to caller without modification.

---

## Return Format

See `.claude/context/core/formats/subagent-return.md` for full specification.

Expected successful return:
```json
{
  "status": "researched",
  "summary": "Research completed with N findings and recommendations",
  "artifacts": [
    {
      "type": "research",
      "path": "specs/{N}_{SLUG}/reports/research-{NNN}.md",
      "summary": "General research report"
    }
  ],
  "metadata": {
    "session_id": "sess_...",
    "agent_type": "general-research-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "research", "general-research-agent"]
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
