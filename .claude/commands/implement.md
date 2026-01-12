---
description: Execute implementation with resume support
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit, Glob
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /implement Command

Execute implementation plan with automatic resume support by delegating to the appropriate implementation skill/subagent.

## Arguments

- `$1` - Task number (required)
- Optional: `--force` to override status validation

## Execution

### 1. Parse and Validate

```
task_number = first token from $ARGUMENTS
force_mode = "--force" in $ARGUMENTS
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

Allowed: planned, implementing, partial, researched, not_started
- If completed: Error unless --force
- If abandoned: Error "Recover task first"
- If implementing: Resume from last incomplete phase

### 3. Load Implementation Plan

Find latest plan:
```
.claude/specs/{N}_{SLUG}/plans/implementation-{LATEST}.md
```

Use Glob to find plan files, Read to get content.

### 4. Detect Resume Point

Scan plan for phases with status markers:
- [NOT STARTED] → Start here
- [IN PROGRESS] → Resume here
- [COMPLETED] → Skip
- [PARTIAL] → Resume here

If all phases [COMPLETED]: Task already done

### 5. Update Status to IMPLEMENTING

Update both files atomically:

**state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "implementing",
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**TODO.md** (via Edit tool):
Update the status marker from current status to `[IMPLEMENTING]`

### 6. Route by Language and Invoke Skill

Based on task language, invoke the appropriate skill via the **Skill tool**:

**If language == "lean":**
```
Invoke skill-lean-implementation with:
- task_number: {N}
- plan_path: {path to implementation plan}
- resume_phase: {phase number to resume from, if any}
```

The skill will spawn `lean-implementation-agent` via Task tool which will:
- Use Lean MCP tools (lean_goal, lean_diagnostic_messages, etc.)
- Execute plan phases sequentially
- Create implementation summary
- Return JSON result

**If language == "latex":**
```
Invoke skill-latex-implementation with:
- task_number: {N}
- plan_path: {path to implementation plan}
- resume_phase: {phase number to resume from, if any}
```

The skill will spawn `latex-implementation-agent` via Task tool which will:
- Use LaTeX build tools (pdflatex, latexmk)
- Execute plan phases sequentially
- Create implementation summary
- Return JSON result

**If language is general, meta, markdown, or other:**
```
Invoke skill-implementer with:
- task_number: {N}
- plan_path: {path to implementation plan}
- resume_phase: {phase number to resume from, if any}
```

The skill will spawn `general-implementation-agent` via Task tool which will:
- Use Read, Write, Edit, Bash for file operations
- Execute plan phases sequentially
- Create implementation summary
- Return JSON result

### 7. Handle Skill Result

The skill returns a JSON result:

```json
{
  "status": "completed|partial|failed",
  "summary": "Implemented all N phases successfully",
  "artifacts": [
    {
      "type": "summary",
      "path": ".claude/specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md",
      "summary": "Implementation completion summary"
    }
  ],
  "metadata": {
    "phases_completed": 3,
    "phases_total": 3
  },
  "next_steps": "Task complete" | "Run /implement {N} to resume"
}
```

**On completed**: Proceed to step 8 with completed state
**On partial**: Proceed to step 8 with partial state (keep status as implementing)
**On failed**: Log error, output error message

### 8. Update Status Based on Result

**If result.status == "completed":**

Update both files atomically:

**state.json** (via jq):
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: "completed",
    completed: $ts,
    last_updated: $ts
  }' .claude/specs/state.json > /tmp/state.json && \
  mv /tmp/state.json .claude/specs/state.json
```

**TODO.md** (via Edit tool):
- Update status marker to `[COMPLETED]`
- Add Completed date
- Add Summary link

**If result.status == "partial":**
- Keep status as [IMPLEMENTING]
- Note resume point for next invocation

### 9. Git Commit

**On completion:**
```bash
git add -A
git commit -m "task {N}: complete implementation

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**On partial:**
```bash
git add -A
git commit -m "task {N}: partial implementation (phases 1-{M} of {N})

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

### 10. Output

**On Completion:**
```
Implementation complete for Task #{N}

Summary: {artifact_path from skill result}

Phases completed: {phases_completed}/{phases_total}

Status: [COMPLETED]
```

**On Partial:**
```
Implementation paused for Task #{N}

Completed: Phases 1-{M}
Remaining: Phase {M+1}

Status: [IMPLEMENTING]
Next: /implement {N} (will resume from Phase {M+1})
```

## Error Handling

### Skill Invocation Failure
If the Skill tool fails to invoke:
1. Log the error
2. Keep status as [IMPLEMENTING]
3. Output error message with recovery instructions

### Subagent Timeout
If the subagent times out:
1. Skill returns partial status
2. Progress is preserved in plan phase markers
3. User can re-run /implement to continue

### Build Errors
If build/verification fails:
1. Skill returns partial or failed status
2. Error details included in result
3. User can fix issues and re-run /implement

### Task Not Found
Return immediately with clear error message.

### Plan Not Found
Error: "No implementation plan found. Run /plan {N} first."
