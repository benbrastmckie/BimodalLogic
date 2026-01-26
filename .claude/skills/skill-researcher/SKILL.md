---
name: skill-researcher
description: Conduct general research using web search, documentation, and codebase exploration. Invoke for non-Lean research tasks.
allowed-tools: Task, Bash, Edit, Read, Write
# Original context (now loaded by subagent):
#   - .claude/context/core/formats/report-format.md
# Original tools (now used by subagent):
#   - Read, Write, Edit, Glob, Grep, WebSearch, WebFetch
---

# Researcher Skill

Thin wrapper that delegates general research to `general-research-agent` subagent.

**IMPORTANT**: This skill implements the skill-internal postflight pattern. After the subagent returns,
this skill handles all postflight operations (status update, artifact linking, git commit) before returning.
This eliminates the "continue" prompt issue between skill return and orchestrator.

## Context References

Reference (do not load eagerly):
- Path: `.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
- Path: `.claude/context/core/patterns/postflight-control.md` - Marker file protocol
- Path: `.claude/context/core/patterns/file-metadata-exchange.md` - File I/O helpers
- Path: `.claude/context/core/patterns/jq-escaping-workarounds.md` - jq escaping patterns (Issue #1132)

Note: This skill is a thin wrapper with internal postflight. Context is loaded by the delegated agent.

## Trigger Conditions

This skill activates when:
- Task language is "general", "meta", or "markdown"
- Research is needed for implementation planning
- Documentation or external resources need to be gathered

---

## Execution Flow

### Stage 1: Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- `focus_prompt` - Optional focus for research direction

```bash
# Lookup task
task_data=$(jq -r --argjson num "$task_number" \
  '.active_projects[] | select(.project_number == $num)' \
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

---

### Stage 2: Preflight Status Update

Update task status to "researching" BEFORE invoking subagent.

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

### Stage 3: Create Postflight Marker

Create the marker file to prevent premature termination:

```bash
cat > specs/.postflight-pending << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-researcher",
  "task_number": ${task_number},
  "operation": "research",
  "reason": "Postflight pending: status update, artifact linking, git commit",
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "stop_hook_active": false
}
EOF
```

---

### Stage 4: Prepare Delegation Context

Prepare delegation context for the subagent:

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
  "focus_prompt": "{optional focus}",
  "metadata_file_path": "specs/{N}_{SLUG}/.return-meta.json"
}
```

---

### Stage 5: Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "general-research-agent"
  - prompt: [Include task_context, delegation_context, focus_prompt, metadata_file_path]
  - description: "Execute research for task {N}"
```

**DO NOT** use `Skill(general-research-agent)` - this will FAIL.

The subagent will:
- Search codebase for related patterns
- Search web for documentation and examples
- Analyze findings and synthesize recommendations
- Create research report in `specs/{N}_{SLUG}/reports/`
- Write metadata to `specs/{N}_{SLUG}/.return-meta.json`
- Return a brief text summary (NOT JSON)

---

### Stage 6: Parse Subagent Return (Read Metadata File)

After subagent returns, read the metadata file:

```bash
metadata_file="specs/${task_number}_${project_name}/.return-meta.json"

if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
    status=$(jq -r '.status' "$metadata_file")
    artifact_path=$(jq -r '.artifacts[0].path // ""' "$metadata_file")
    artifact_type=$(jq -r '.artifacts[0].type // ""' "$metadata_file")
    artifact_summary=$(jq -r '.artifacts[0].summary // ""' "$metadata_file")
else
    echo "Error: Invalid or missing metadata file"
    status="failed"
fi
```

---

### Stage 7: Atomic State Update (Postflight)

**NEW ATOMIC PATTERN**: Use atomic postflight script to ensure both state.json AND TODO.md update together or neither (rollback on failure).

**CRITICAL**: This prevents the task 690 failure mode where state.json was updated but TODO.md was not.

```bash
if [ "$status" = "researched" ]; then
    echo "Executing atomic postflight update..."

    if ! .claude/scripts/atomic-postflight-research.sh \
        "$task_number" \
        "$artifact_path" \
        "$artifact_summary" \
        "$project_name"; then

        echo "ERROR: Atomic postflight failed"
        rm -f specs/.postflight-pending

        # Attempt rollback from backups
        if [ -f /tmp/state.json.backup ]; then
            cp /tmp/state.json.backup specs/state.json
            echo "Rolled back state.json"
        fi
        if [ -f /tmp/TODO.md.backup ]; then
            cp /tmp/TODO.md.backup specs/TODO.md
            echo "Rolled back TODO.md"
        fi

        return "Research completed but state update failed. Task status unchanged. Run /research ${task_number} to retry."
    fi

    echo "✓ Atomic state update successful"
else
    # On partial/failed: Keep status as "researching" for resume
    echo "Research incomplete - status remains [RESEARCHING]"
fi
```

**What the atomic script does**:
1. Creates backups of state.json and TODO.md
2. Updates both files to temp locations
3. Validates both temp files
4. Atomically replaces both (or neither on validation failure)
5. Returns success/failure status

---

### Stage 8: Validation Checkpoint (NEW)

**Read-back verification** to catch silent failures (prevents task 690 scenario):

```bash
if [ "$status" = "researched" ]; then
    echo "Validating postflight updates..."

    # Load validation library
    source .claude/scripts/lib/validation.sh

    # Validate state.json
    if ! validate_state_json specs/state.json "$task_number" "researched" "report"; then
        echo "CRITICAL: state.json validation failed after atomic update"
        rm -f specs/.postflight-pending
        return "State validation failed - manual inspection required. See specs/state.json task ${task_number}"
    fi

    # Validate TODO.md
    if ! validate_todo_md specs/TODO.md "$task_number" "RESEARCHED" "Research"; then
        echo "CRITICAL: TODO.md validation failed after atomic update"
        rm -f specs/.postflight-pending
        return "TODO.md validation failed - manual inspection required. Check specs/TODO.md task ${task_number}"
    fi

    echo "✓ Validation passed: all state updates confirmed"
fi
```

**Validation checks**:
- state.json: Task exists, status = "researched", artifact present
- TODO.md: Task exists, exactly one [RESEARCHED] marker, research link present

**On validation failure**: Abort workflow, report error to user, preserve state for manual inspection

---

### Stage 9: Conditional Git Commit

**CHANGED**: Only commit if validation passed (prevents committing inconsistent state).

```bash
if [ "$status" = "researched" ]; then
    # Only reached if atomic update AND validation succeeded
    echo "Committing changes..."

    git add specs/state.json specs/TODO.md "specs/${task_number}_${project_name}/reports/"

    if git commit -m "task ${task_number}: complete research

${artifact_summary}

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"; then
        echo "✓ Changes committed successfully"
        commit_status="committed"
    else
        echo "⚠ Git commit failed (non-blocking)"
        commit_status="commit_failed"
    fi
else
    commit_status="skipped"
fi
```

**Note**: Git commit failure is non-blocking (logged but doesn't fail workflow)

---

### Stage 10: Cleanup

Remove marker and metadata files:

```bash
rm -f specs/.postflight-pending
rm -f specs/.postflight-loop-guard
rm -f "specs/${task_number}_${project_name}/.return-meta.json"
```

---

### Stage 11: Return Brief Summary

Return a brief text summary (NOT JSON) with validation status. Example:

```
Research completed for task {N}:
- Found {count} relevant patterns and resources
- Identified implementation approach: {approach}
- Created report at specs/{N}_{SLUG}/reports/research-{NNN}.md
- Status updated to [RESEARCHED] (validated)
- Changes committed (${commit_status})
```

**Validation indicators**:
- `(validated)` - Atomic update and validation passed
- `(commit_status: committed)` - Git commit succeeded
- `(commit_status: commit_failed)` - Git commit failed (non-blocking)
- `(commit_status: skipped)` - Research incomplete, commit skipped

---

## Error Handling

### Input Validation Errors
Return immediately with error message if task not found.

### Metadata File Missing
If subagent didn't write metadata file:
1. Keep status as "researching"
2. Do not cleanup postflight marker
3. Report error to user

### Git Commit Failure
Non-blocking: Log failure but continue with success response.

### Subagent Timeout
Return partial status if subagent times out (default 3600s).
Keep status as "researching" for resume.

---

## Return Format

This skill returns a **brief text summary** (NOT JSON). The JSON metadata is written to the file and processed internally.

Example successful return:
```
Research completed for task 412:
- Found 8 relevant patterns for implementation
- Identified lazy context loading and skill-to-agent mapping patterns
- Created report at specs/412_general_research/reports/research-001.md
- Status updated to [RESEARCHED]
- Changes committed with session sess_1736700000_abc123
```

Example partial return:
```
Research partially completed for task 412:
- Found 4 codebase patterns
- Web search failed due to network error
- Partial report created at specs/412_general_research/reports/research-001.md
- Status remains [RESEARCHING] - run /research 412 to continue
```
