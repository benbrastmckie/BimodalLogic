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

### CHECKPOINT 1: GATE IN

1. **Generate Session ID**
   ```
   session_id = sess_{timestamp}_{random}
   ```

2. **Lookup Task**
   ```bash
   task_data=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber))' \
     .claude/specs/state.json)
   ```

3. **Validate**
   - Task exists (ABORT if not)
   - Status allows implementation: planned, implementing, partial, researched, not_started
   - If completed: ABORT unless --force
   - If abandoned: ABORT "Recover task first"

4. **Load Implementation Plan**
   Find latest: `.claude/specs/{N}_{SLUG}/plans/implementation-{LATEST}.md`

   If no plan: ABORT "No implementation plan found. Run /plan {N} first."

5. **Detect Resume Point**
   Scan plan for phase status markers:
   - [NOT STARTED] → Start here
   - [IN PROGRESS] → Resume here
   - [COMPLETED] → Skip
   - [PARTIAL] → Resume here

   If all [COMPLETED]: Task already done

6. **Update Status (via skill-status-sync)**
   Invoke skill-status-sync: `preflight_update(task_number, "implementing", session_id)`

7. **Verify** status is now "implementing"

**ABORT** if any validation fails. **PROCEED** if all pass.

### STAGE 2: DELEGATE

Route by language (see routing.md):

| Language | Skill |
|----------|-------|
| lean | skill-lean-implementation |
| latex | skill-latex-implementation |
| general/meta/markdown | skill-implementer |

Invoke skill with:
- task_number: {N}
- plan_path: {path to implementation plan}
- resume_phase: {phase number to resume from, if any}
- session_id: {session_id}

Skill spawns appropriate agent which:
- Executes plan phases sequentially
- Updates phase markers in plan file
- Creates commits per phase
- Creates implementation summary
- Returns structured result

### CHECKPOINT 2: GATE OUT

1. **Validate Return**
   Required fields: status, summary, artifacts, metadata (phases_completed, phases_total)

2. **Verify Artifacts**
   Check summary file exists on disk (if completed)

3. **Update Status (via skill-status-sync)**

   **If result.status == "completed":**
   Invoke skill-status-sync: `postflight_update(task_number, "completed", artifacts, session_id)`

   **If result.status == "partial":**
   Keep status as "implementing", note resume point

4. **Verify** status and artifact links

**PROCEED** to commit. **RETRY** skill if validation fails.

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

### GATE IN Failure
- Task not found: Return error with guidance
- No plan found: Return error "Run /plan {N} first"
- Invalid status: Return error with current status

### DELEGATE Failure
- Skill fails: Keep [IMPLEMENTING], log error
- Timeout: Progress preserved in plan phase markers, user can re-run

### GATE OUT Failure
- Missing artifacts: Log warning, continue with available
- Link failure: Non-blocking warning

### Build Errors
- Skill returns partial/failed status
- Error details included in result
- User can fix issues and re-run /implement
