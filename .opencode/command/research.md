---
command: research
description: Research a task and create reports
version: "1.0"
mode: command
temperature: 0.2
arguments:
  name: task_number
  type: integer
  required: true
  description: Task number to research
  name: focus
  type: string
  required: false
  description: Optional focus prompt
tools:
  read: true
  write: true
  edit: true
  glob: true
  bash: true
  skill: true
permissions:
  read:
    "**/*.md": "allow"
    ".opencode/**/*": "allow"
    "specs/**/*": "allow"
  write:
    "specs/**/*": "allow"
  bash:
    "git:*": "allow"
    "jq:*": "allow"
    "*": "deny"
allowed_tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
argument_hint: TASK_NUMBER [FOCUS]
delegation_depth: 1
max_delegation_depth: 3
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required: "core/workflows/command-lifecycle.md"
---

## Context Loading Guidance

- Routing stages: do not load context.
- Execution stages: use `.opencode/context/index.md` for targeted context loading.


## Context Loading Guidance

- Routing stages: do not load context.
- Execution stages: use `.opencode/context/index.md` for targeted context loading.


# /research Command

Conduct research for a task by delegating to the appropriate research skill/subagent.

## Arguments

- `$1` - Task number (required)
- Remaining args - Optional focus/prompt for research direction

## Execution

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```
   session_id = sess_{timestamp}_{random}
   ```

2. **Lookup Task**
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     specs/state.json)
   ```

3. **Validate**
   - Task exists (ABORT if not)
   - Status allows research: not_started, planned, partial, blocked, researched
   - If completed/abandoned: ABORT with recommendation

**ABORT** if any validation fails.

**On GATE IN success**: Task validated. **IMMEDIATELY CONTINUE** to STAGE 2 below.

### STAGE 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Language-Based Routing**:

| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-research` |
| `general`, `meta`, `markdown`, `latex` | `skill-researcher` |

**Invoke the Skill tool NOW** with:
```
skill: "{skill-name from table above}"
args: "task_number={N} focus={focus_prompt} session_id={session_id}"
```

The skill will spawn the appropriate agent to conduct research and create a report.

**On DELEGATE success**: Research complete. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts

2. **Verify Artifacts**
   Check each artifact path exists on disk

3. **Verify Status Updated**
   The skill handles status updates internally (preflight and postflight).
   Confirm status is now "researched" in specs/state.json.

**RETRY** skill if validation fails.

**On GATE OUT success**: Artifacts verified. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

### CHECKPOINT 3: COMMIT

```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: complete research

Session: {session_id}

Co-Authored-By: OpenCode <noreply@opencode.ai>
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

```
Research completed for Task #{N}

Report: {artifact_path from skill result}

Summary: {summary from skill result}

Status: [RESEARCHED]
Next: /plan {N}
```

## Error Handling

### GATE IN Failure
- Task not found: Return error with guidance
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Keep [RESEARCHING], log error
- Timeout: Partial research preserved, user can re-run

### GATE OUT Failure
- Missing artifacts: Log warning, continue with available
- Link failure: Non-blocking warning
