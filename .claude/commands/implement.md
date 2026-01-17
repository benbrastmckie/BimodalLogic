---
description: Execute implementation with resume support
allowed-tools: Skill, Bash(jq:*), Bash(git:*), Read, Glob
argument-hint: TASK_NUMBER
model: claude-opus-4-5-20251101
---

# /implement Command

Execute implementation plan with automatic resume support by delegating to the appropriate implementation skill.

## Arguments

- `$1` - Task number (required)
- Optional: `--force` to override status validation

## Execution

### CHECKPOINT 1: VALIDATE

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
   - Status allows implementation: planned, implementing, partial, researched, not_started
   - If completed: ABORT unless --force
   - If abandoned: ABORT "Recover task first"

4. **Load Implementation Plan**
   Find latest: `specs/{N}_{SLUG}/plans/implementation-{LATEST}.md`

   If no plan: ABORT "No implementation plan found. Run /plan {N} first."

5. **Detect Resume Point**
   Scan plan for phase status markers:
   - [NOT STARTED] → Start here
   - [IN PROGRESS] → Resume here
   - [COMPLETED] → Skip
   - [PARTIAL] → Resume here

   If all [COMPLETED]: Task already done

**ABORT** if any validation fails.

**On VALIDATE success**: Task validated with resume point. **IMMEDIATELY CONTINUE** to CHECKPOINT 2 below.

### CHECKPOINT 2: DELEGATE

**EXECUTE NOW**: After CHECKPOINT 1 passes, immediately invoke the Skill tool.

**Language-Based Routing**:

| Language | Skill to Invoke |
|----------|-----------------|
| `lean` | `skill-lean-implementation` |
| `latex` | `skill-latex-implementation` |
| `general`, `meta`, `markdown` | `skill-implementer` |

**Invoke the Skill tool NOW** with:
```
skill: "{skill-name from table above}"
args: "task_number={N} plan_path={path to implementation plan} resume_phase={phase number} session_id={session_id}"
```

The skill handles:
- Preflight status update (→ IMPLEMENTING)
- Agent delegation for implementation
- Postflight status update (→ COMPLETED or stays IMPLEMENTING for partial)
- Artifact linking

**On DELEGATE success**: Implementation complete/partial with status updated. **IMMEDIATELY CONTINUE** to CHECKPOINT 3 below.

### CHECKPOINT 3: COMMIT

**On completion:**
```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: complete implementation

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

**On partial:**
```bash
git add -A
git commit -m "$(cat <<'EOF'
task {N}: partial implementation (phases 1-{M} of {total})

Session: {session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
EOF
)"
```

Commit failure is non-blocking (log and continue).

## Output

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

### VALIDATE Failure
- Task not found: Return error with guidance
- No plan found: Return error "Run /plan {N} first"
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Status remains as-is, log error
- Timeout: Progress preserved in plan phase markers, user can re-run

### COMMIT Failure
- Non-blocking: Log warning, continue with output

### Build Errors
- Skill returns partial/failed status
- Error details included in result
- User can fix issues and re-run /implement
