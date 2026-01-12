---
description: Research a task and create reports
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
argument-hint: TASK_NUMBER [FOCUS]
model: claude-opus-4-5-20251101
---

# /research Command

Conduct research for a task by delegating to the appropriate research skill/subagent.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Execution

### 1. Parse and Validate

```
task_number = first token from $ARGUMENTS
focus_prompt = remaining tokens (optional)
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

Allowed statuses: not_started, planned, partial, blocked
- If completed/abandoned: Error with recommendation
- If researching: Warn about stale status, continue
- If already researched: Note existing report, continue (will create new version)

### 3. Update Status to RESEARCHING

Update both files atomically:

**state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "researching",
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**TODO.md** (via Edit tool):
Update the status marker from current status to `[RESEARCHING]`

### 4. Route by Language and Invoke Skill

Based on task language, invoke the appropriate skill via the **Skill tool**:

**If language == "lean":**
```
Invoke skill-lean-research with:
- task_number: {N}
- focus_prompt: {optional focus}
```

The skill will spawn `lean-research-agent` via Task tool which will:
- Use Lean MCP tools (leansearch, loogle, leanfinder)
- Create research report in `.claude/specs/{N}_{SLUG}/reports/`
- Return JSON result

**If language != "lean" (general, meta, markdown, latex, etc.):**
```
Invoke skill-researcher with:
- task_number: {N}
- focus_prompt: {optional focus}
```

The skill will spawn `general-research-agent` via Task tool which will:
- Use WebSearch, WebFetch, Read, Grep, Glob
- Create research report in `.claude/specs/{N}_{SLUG}/reports/`
- Return JSON result

### 5. Handle Skill Result

The skill returns a JSON result:

```json
{
  "status": "completed|partial|failed",
  "summary": "Brief summary of research findings",
  "artifacts": [
    {
      "type": "research",
      "path": ".claude/specs/{N}_{SLUG}/reports/research-{NNN}.md",
      "summary": "Research report description"
    }
  ],
  "next_steps": "Run /plan {N} to create implementation plan"
}
```

**On completed**: Proceed to step 6
**On partial**: Log partial status, proceed to step 6 with partial state
**On failed**: Log error, keep status as researching, output error

### 6. Update Status to RESEARCHED

Update both files atomically:

**state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "researched",
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**TODO.md** (via Edit tool):
- Update status marker to `[RESEARCHED]`
- Add research report link if not already present

### 7. Git Commit

```bash
git add .claude/specs/
git commit -m "task {N}: complete research

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### 8. Output

```
Research completed for Task #{N}

Report: {artifact_path from skill result}

Summary: {summary from skill result}

Status: [RESEARCHED]
Next: /plan {N}
```

## Error Handling

### Skill Invocation Failure
If the Skill tool fails to invoke:
1. Log the error
2. Keep status as [RESEARCHING]
3. Output error message with recovery instructions

### Subagent Timeout
If the subagent times out:
1. Skill returns partial status
2. Partial research is preserved
3. User can re-run /research to continue

### Task Not Found
Return immediately with clear error message.
