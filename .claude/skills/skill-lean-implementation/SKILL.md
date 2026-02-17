---
name: skill-lean-implementation
description: Implement Lean 4 proofs and definitions using lean-lsp tools. Invoke for Lean-language implementation tasks.
allowed-tools: Task, Bash, Edit, Read, Write
# Original context (now loaded by subagent):
#   - .claude/context/project/lean4/tools/mcp-tools-guide.md
#   - .claude/context/project/lean4/patterns/tactic-patterns.md
# Original tools (now used by subagent):
#   - mcp__lean-lsp__lean_goal, lean_multi_attempt, lean_state_search, etc.
---

# Lean Implementation Skill

Thin wrapper that delegates Lean 4 proof implementation to `lean-implementation-agent` subagent.

**IMPORTANT**: This skill implements the skill-internal postflight pattern. After the subagent returns,
this skill handles all postflight operations (status update, artifact linking, git commit) before returning.
This eliminates the "continue" prompt issue between skill return and orchestrator.

## Context References

Reference (do not load eagerly):
- Path: `.claude/context/core/formats/return-metadata-file.md` - Metadata file schema
- Path: `.claude/context/core/patterns/postflight-control.md` - Marker file protocol
- Path: `.claude/context/core/patterns/jq-escaping-workarounds.md` - jq escaping patterns (Issue #1132)

Note: This skill is a thin wrapper with internal postflight. Context is loaded by the delegated agent.

## Trigger Conditions

This skill activates when:
- Task language is "lean"
- /implement command targets a Lean task
- Plan exists and task is ready for implementation

---

## Execution Flow

### Stage 1: Input Validation

Validate required inputs:
- `task_number` - Must be provided and exist in state.json
- Task status must allow implementation (planned, implementing, partial)
- Task language must be "lean"

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

# Validate language
if [ "$language" != "lean" ]; then
  return error "Task $task_number is not a Lean task"
fi

# Validate status
if [ "$status" = "completed" ]; then
  return error "Task already completed"
fi
```

---

### Stage 2: Preflight Status Update

Update task status to "implementing" BEFORE invoking subagent.

**Update state.json**:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "implementing" \
   --arg sid "$session_id" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    session_id: $sid,
    started: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

**Update TODO.md**: Use Edit tool to change status marker from `[PLANNED]` to `[IMPLEMENTING]`.

**Update plan file** (if exists): Update the Status field in plan metadata:
```bash
# Find latest plan file
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [IMPLEMENTING]/" "$plan_file"
fi
```

---

### Stage 3: Create Postflight Marker

Create the marker file to prevent premature termination:

```bash
# Ensure task directory exists
mkdir -p "specs/${task_number}_${project_name}"

cat > "specs/${task_number}_${project_name}/.postflight-pending" << EOF
{
  "session_id": "${session_id}",
  "skill": "skill-lean-implementation",
  "task_number": ${task_number},
  "operation": "implement",
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
  "delegation_path": ["orchestrator", "implement", "skill-lean-implementation"],
  "timeout": 7200,
  "task_context": {
    "task_number": N,
    "task_name": "{project_name}",
    "description": "{description}",
    "language": "lean"
  },
  "plan_path": "specs/{N}_{SLUG}/plans/implementation-{NNN}.md",
  "metadata_file_path": "specs/{N}_{SLUG}/.return-meta.json",
  "iteration": 1,
  "resume_phase": null,
  "handoff_path": null
}
```

**Iteration Fields** (used by Stage 6a auto-resume loop):
- `iteration`: Current loop iteration (1 for initial invocation, incremented on re-invocations)
- `resume_phase`: Phase number to resume from (null for initial, set from `partial_progress.phases_completed + 1` on re-invocation)
- `handoff_path`: Path to handoff document for context exhaustion cases (null unless agent wrote handoff)

---

### Stage 5: Invoke Subagent

**CRITICAL**: You MUST use the **Task** tool to spawn the subagent.

**Required Tool Invocation**:
```
Tool: Task (NOT Skill)
Parameters:
  - subagent_type: "lean-implementation-agent"
  - prompt: [Include task_context, delegation_context, plan_path, metadata_file_path]
  - description: "Execute Lean implementation for task {N}"
```

**DO NOT** use `Skill(lean-implementation-agent)` - this will FAIL.

The subagent will:
- Load implementation context files (MCP tools guide, tactic patterns)
- Parse plan and find resume point
- Execute phases sequentially using lean-lsp MCP tools
- Verify proofs with `lean_goal` and `lake build`
- Create implementation summary
- Write metadata to `specs/{N}_{SLUG}/.return-meta.json`
- Return a brief text summary (NOT JSON)

---

### Stage 5a: Validate Subagent Return Format

**IMPORTANT**: Check if subagent accidentally returned JSON to console instead of writing to file.

```bash
# Check if subagent return looks like JSON
subagent_return="$SUBAGENT_TEXT_RETURN"
if echo "$subagent_return" | grep -q '^{' && echo "$subagent_return" | jq empty 2>/dev/null; then
    echo "WARNING: Subagent returned JSON to console instead of writing metadata file."
fi
```

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
    phases_completed=$(jq -r '.metadata.phases_completed // 0' "$metadata_file")
    phases_total=$(jq -r '.metadata.phases_total // 0' "$metadata_file")

    # Extract completion_data fields (if present)
    completion_summary=$(jq -r '.completion_data.completion_summary // ""' "$metadata_file")
    roadmap_items=$(jq -c '.completion_data.roadmap_items // []' "$metadata_file")
else
    echo "Error: Invalid or missing metadata file"
    status="failed"
fi
```

---

### Stage 6a: Continuous Handoff Loop

If status is "partial" and `requires_user_review` is not true, automatically re-invoke the subagent with updated context. This enables multi-phase implementations to complete without manual intervention for recoverable partials.

**Loop Guard File**: Create `.postflight-loop-guard` to track iteration count across potential skill restarts:

```bash
# Create or read loop guard
loop_guard_file="specs/${task_number}_${project_name}/.postflight-loop-guard"
if [ -f "$loop_guard_file" ]; then
    iteration_count=$(cat "$loop_guard_file")
else
    iteration_count=0
fi
max_iterations=${MAX_ITERATIONS:-5}

# Enter loop (loop body starts here, checked each iteration)
while true; do
    iteration_count=$((iteration_count + 1))
    echo "$iteration_count" > "$loop_guard_file"

    # Already have status from Stage 6
    requires_review=$(jq -r '.requires_user_review // false' "$metadata_file")
    handoff_path=$(jq -r '.partial_progress.handoff_path // ""' "$metadata_file")

    # Stop condition: implemented (success)
    if [ "$status" == "implemented" ]; then
        break
    fi

    # Stop condition: hard failure
    if [ "$status" == "blocked" ] || [ "$status" == "failed" ]; then
        break
    fi

    # Stop condition: partial but requires user review
    if [ "$status" == "partial" ] && [ "$requires_review" == "true" ]; then
        echo "Partial completion requires user review - exiting loop"
        break
    fi

    # Stop condition: iteration limit reached
    if [ "$status" == "partial" ] && [ "$iteration_count" -ge "$max_iterations" ]; then
        echo "Max iterations ($max_iterations) reached - exiting loop"
        break
    fi

    # If partial and not blocked, re-invoke subagent
    if [ "$status" == "partial" ]; then
        echo "Iteration $iteration_count: Partial completion, auto-resuming..."

        # Commit iteration progress before re-invocation
        git add \
          "Theories/" \
          "specs/${task_number}_${project_name}/summaries/" \
          "specs/${task_number}_${project_name}/plans/" \
          "specs/${task_number}_${project_name}/.return-meta.json"
        git commit -m "task ${task_number}: iteration ${iteration_count} partial progress

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>" || true

        # Update delegation context with resume info
        resume_phase=$((phases_completed + 1))

        # Re-invoke subagent (same as Stage 5) with updated context
        # Delegation context now includes:
        #   - iteration: current loop iteration
        #   - resume_phase: phase to resume from
        #   - handoff_path: path to handoff document (if context exhaustion)

        # ... invoke Task tool with updated context ...
        # After subagent returns, re-read metadata (repeat Stage 6)

        if [ -f "$metadata_file" ] && jq empty "$metadata_file" 2>/dev/null; then
            status=$(jq -r '.status' "$metadata_file")
            phases_completed=$(jq -r '.metadata.phases_completed // 0' "$metadata_file")
            phases_total=$(jq -r '.metadata.phases_total // 0' "$metadata_file")
            completion_summary=$(jq -r '.completion_data.completion_summary // ""' "$metadata_file")
            roadmap_items=$(jq -c '.completion_data.roadmap_items // []' "$metadata_file")
        else
            echo "Error: Invalid or missing metadata file after re-invocation"
            status="failed"
            break
        fi

        continue
    fi

    # Unknown status - exit loop
    break
done
```

**Stop Conditions Summary**:

| Condition | Result | User Action Required |
|-----------|--------|---------------------|
| `status == "implemented"` | Proceed to postflight | None |
| `status == "blocked"` | Exit with blocker report | Yes - resolve blocker |
| `status == "failed"` | Exit with error | Yes - investigate failure |
| `status == "partial" && requires_user_review == true` | Exit with blocker | Yes - review required |
| `status == "partial" && iteration >= max_iterations` | Exit with limit warning | Optional - run again |
| `status == "partial" && requires_user_review != true` | Re-invoke subagent | None (automatic) |

**Iteration Context Passage**:

Each re-invocation includes in delegation context:
- `iteration`: Current loop iteration number
- `resume_phase`: Next phase to execute (phases_completed + 1)
- `handoff_path`: Path to handoff document if available (for context exhaustion cases)
- `session_id`: Same session ID for commit continuity

---

### Stage 7: Update Task Status (Postflight)

**If status is "implemented"**:

Update state.json to "completed" and add completion_data fields:
```bash
# Step 1: Update status and timestamps
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg status "completed" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    status: $status,
    last_updated: $ts,
    completed: $ts
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

# Step 2: Add completion_summary (always required for completed tasks)
if [ -n "$completion_summary" ]; then
    jq --arg summary "$completion_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).completion_summary = $summary' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
fi

# Step 3: Add roadmap_items (if present and non-empty)
if [ "$roadmap_items" != "[]" ] && [ -n "$roadmap_items" ]; then
    jq --argjson items "$roadmap_items" \
      '(.active_projects[] | select(.project_number == '$task_number')).roadmap_items = $items' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
fi
```

Update TODO.md: Change status marker from `[IMPLEMENTING]` to `[COMPLETED]`.

**Update plan file** (if exists): Update the Status field to `[COMPLETED]`:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [COMPLETED]/" "$plan_file"
fi
```

**If status is "partial"**:

Keep status as "implementing" but update resume point.
TODO.md stays as `[IMPLEMENTING]`.

**Update plan file** (if exists): Update the Status field to `[PARTIAL]`:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
fi
```

---

### Stage 8: Link Artifacts

Add artifact to state.json with summary. Summary artifacts should be linked for **both** implemented and partial status, since incremental summaries contain Phase Entries for completed work.

**IMPORTANT**: Use two-step jq pattern to avoid Issue #1132 escaping bug.

```bash
# Find summary artifact in metadata (regardless of status)
summary_artifact_path=$(jq -r '.artifacts[] | select(.type == "summary") | .path // ""' "$metadata_file" | head -1)
summary_artifact_summary=$(jq -r '.artifacts[] | select(.type == "summary") | .summary // ""' "$metadata_file" | head -1)

if [ -n "$summary_artifact_path" ]; then
    # Step 1: Filter out existing summary artifacts
    jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
        [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type == "summary" | not)]' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

    # Step 2: Add new summary artifact
    jq --arg path "$summary_artifact_path" \
       --arg summary "$summary_artifact_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": "summary", "summary": $summary}]' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
fi

# Also link implementation artifacts if present
if [ -n "$artifact_path" ] && [ "$artifact_type" != "summary" ]; then
    jq --arg path "$artifact_path" \
       --arg type "$artifact_type" \
       --arg summary "$artifact_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
fi
```

**Update TODO.md** (for both implemented AND partial): Add summary artifact link:
```markdown
- **Summary**: [implementation-summary-{DATE}.md]({summary_artifact_path})
```

This enables visibility into partial progress through the summary file even when implementation is incomplete.

---

### Stage 9: Git Commit

Commit changes with session ID using targeted staging (prevents race conditions with concurrent agents):

```bash
git add \
  "Theories/" \
  "specs/${task_number}_${project_name}/summaries/" \
  "specs/${task_number}_${project_name}/plans/" \
  "specs/${task_number}_${project_name}/.return-meta.json" \
  "specs/TODO.md" \
  "specs/state.json"
git commit -m "task ${task_number}: complete implementation

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

**Note**: Use targeted staging, NOT `git add -A`. See `.claude/context/core/standards/git-staging-scope.md`.

---

### Stage 10: Cleanup

Remove marker and metadata files:

```bash
rm -f "specs/${task_number}_${project_name}/.postflight-pending"
rm -f "specs/${task_number}_${project_name}/.postflight-loop-guard"
rm -f "specs/${task_number}_${project_name}/.return-meta.json"
```

---

### Stage 11: Return Brief Summary

Return a brief text summary (NOT JSON). Example:

```
Lean implementation completed for task {N}:
- All {phases_total} phases executed, all proofs verified
- Lake build: Success
- Key theorems: {theorem names}
- Created summary at specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md
- Status updated to [COMPLETED]
- Changes committed
```

---

## Error Handling

### Input Validation Errors
Return immediately with error message if task not found, wrong language, or status invalid.

### Metadata File Missing
If subagent didn't write metadata file:
1. Keep status as "implementing"
2. Do not cleanup postflight marker
3. Report error to user

### Git Commit Failure
Non-blocking: Log failure but continue with success response.

### Subagent Timeout
Return partial status if subagent times out (default 7200s).
Keep status as "implementing" for resume.

---

## Return Format

This skill returns a **brief text summary** (NOT JSON). The JSON metadata is written to the file and processed internally.

Example successful return:
```
Lean implementation completed for task 259:
- All 3 phases executed, all proofs verified
- Lake build: Success
- Implemented completeness theorem with 4 supporting lemmas
- Created summary at specs/259_completeness/summaries/implementation-summary-20260118.md
- Status updated to [COMPLETED]
- Changes committed with session sess_1736700000_abc123
```

Example partial return:
```
Lean implementation partially completed for task 259:
- Phases 1-2 of 3 executed
- Phase 3 stuck: induction case requires missing lemma
- Current proof state documented in summary
- Status remains [IMPLEMENTING] - run /implement 259 to resume
```
