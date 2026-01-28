---
name: skill-lean-implementation
description: Implement Lean 4 proofs and definitions using lean-lsp tools. Invoke for Lean-language implementation tasks.
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, mcp__lean-lsp__lean_goal, mcp__lean-lsp__lean_hover_info, mcp__lean-lsp__lean_completions, mcp__lean-lsp__lean_multi_attempt, mcp__lean-lsp__lean_local_search, mcp__lean-lsp__lean_state_search, mcp__lean-lsp__lean_hammer_premise, mcp__lean-lsp__lean_term_goal, mcp__lean-lsp__lean_declaration_file, mcp__lean-lsp__lean_run_code, mcp__lean-lsp__lean_build, mcp__lean-lsp__lean_leansearch, mcp__lean-lsp__lean_loogle, mcp__lean-lsp__lean_leanfinder
---

# Lean Implementation Skill

Direct execution skill for Lean 4 proof implementation. Executes MCP tools directly instead of delegating to a subagent.

**Note**: This skill was refactored from thin wrapper delegation pattern to direct execution to fix
MCP tool hanging issues in subagents (Claude Code bugs #15945, #13254, #4580).

**Temporary Workaround**: `lean_diagnostic_messages` and `lean_file_outline` removed due to MCP hanging bug (lean-lsp-mcp issues #118, #115). Use `lean_goal` + `lake build` for diagnostics, `Read` + `lean_hover_info` for file structure.

## Context References

Load on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference

**Load for Implementation**:
- `@.claude/context/project/lean4/patterns/tactic-patterns.md` - Common tactic usage patterns
- `@.claude/context/project/lean4/style/lean4-style-guide.md` - Code style conventions

**Load for Specific Needs**:
- `@Logos/Layer0/` files - When implementing Layer 0 proofs
- `@Logos/Layer1/` files - When implementing Layer 1 (modal) proofs
- `@Logos/Layer2/` files - When implementing Layer 2 (temporal) proofs

**Load for Pattern Reference**:
- `@.claude/context/core/patterns/jq-escaping-workarounds.md` - jq escaping patterns (Issue #1132)

## Trigger Conditions

This skill activates when:
- Task language is "lean"
- /implement command targets a Lean task
- Proofs or definitions need to be written

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

Update task status to "implementing" BEFORE starting implementation.

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
cat > specs/.postflight-pending << EOF
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

### Stage 4: Load and Parse Implementation Plan

Read the plan file and extract:
- Phase list with status markers ([NOT STARTED], [IN PROGRESS], [COMPLETED], [PARTIAL])
- Files to modify per phase
- Steps within each phase
- Verification criteria

```bash
# Find latest plan file
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
```

---

### Stage 5: Find Resume Point

Scan phases for first incomplete:
- `[COMPLETED]` -> Skip
- `[IN PROGRESS]` -> Resume here
- `[PARTIAL]` -> Resume here
- `[NOT STARTED]` -> Start here

If all phases are `[COMPLETED]`: Task already done, return completed status.

---

### Stage 6: Execute Proof Development Loop

For each phase starting from resume point:

#### 6A. Mark Phase In Progress

Edit plan file: Change phase status to `[IN PROGRESS]`

#### 6B. Execute Proof Development

For each proof/theorem in the phase:

1. **Read target file, locate proof point**
   - Use `Read` to get current file contents
   - Identify the theorem/lemma to prove

2. **Check current proof state**
   - Use `lean_goal` to see current goals
   - If "no goals" -> proof already complete

3. **Develop proof iteratively**
   ```
   REPEAT until goals closed or stuck:
     a. Use lean_goal to see current state
     b. Use lean_multi_attempt to try candidate tactics:
        - ["simp", "ring", "omega", "decide"]
        - ["exact h", "apply h", "intro h"]
        - Domain-specific tactics from context
     c. If promising tactic found:
        - Apply via Edit tool
        - Use lean_goal to verify progress
     d. If stuck:
        - Use lean_state_search for goal-closing lemmas
        - Use lean_hammer_premise for simp premises
        - Use lean_local_search to find related definitions
     e. If still stuck after multiple attempts:
        - Log current state
        - Return partial with recommendation
   ```

4. **Verify step completion**
   - Use `lean_goal` to confirm goals are closed
   - Run `lake build` to verify no compilation errors

### Tactic Selection Strategy

1. **Start Simple**
   - Try `simp`, `rfl`, `trivial` first
   - Try `decide` for decidable propositions
   - Try `ring` or `omega` for arithmetic

2. **Structural Tactics**
   - `intro` for implications/foralls
   - `cases` or `rcases` for disjunctions/existentials
   - `induction` for recursive types

3. **Application Tactics**
   - `exact h` when hypothesis matches goal exactly
   - `apply lemma` to reduce goal using lemma
   - `have` to introduce intermediate facts

4. **Automation**
   - `simp [lemma1, lemma2]` with specific lemmas
   - `aesop` for goal search
   - `omega` for linear arithmetic

#### 6C. Verify Phase Completion

- Run `lake build` to verify full project builds
- Check verification criteria from plan

#### 6D. Mark Phase Complete

Edit plan file: Change phase status to `[COMPLETED]`

#### 6E. Git Commit Phase

Commit phase progress:
```bash
git add -A && git commit -m "task ${task_number} phase ${phase_num}: ${phase_name}

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

### Stage 7: Run Final Build Verification

After all phases complete:
```bash
lake build
```

If build fails:
- Capture error output
- Return partial with build errors

---

### Stage 8: Create Implementation Summary

Ensure directory exists:
```bash
mkdir -p "specs/${task_number}_${project_name}/summaries"
```

Write to `specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md`:

```markdown
# Implementation Summary: Task #{N}

**Completed**: {ISO_DATE}
**Duration**: {time}

## Changes Made

{Summary of proofs developed}

## Files Modified

- `Logos/Layer{X}/File.lean` - {proof description}

## Verification

- Lake build: Success/Failure
- All goals closed: Yes/No
- Tests passed: {if applicable}

## Notes

{Any additional notes, follow-up items, or caveats}
```

---

### Stage 9: Generate Completion Data

**CRITICAL**: Before updating status, prepare the `completion_data` object.

1. Generate `completion_summary`: A 1-3 sentence description of what was accomplished
   - Focus on the mathematical/proof outcome
   - Include key theorems and lemmas proven
   - Example: "Proved completeness theorem using canonical model construction. Implemented 4 supporting lemmas including truth lemma and existence lemma."

2. Optionally generate `roadmap_items`: Array of explicit ROAD_MAP.md item texts this task addresses
   - Only include if the task clearly maps to specific roadmap items
   - Example: `["Prove completeness theorem for K modal logic"]`

---

### Stage 10: Update Task Status (Postflight)

**If implementation is complete**:

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
jq --arg summary "$completion_summary" \
  '(.active_projects[] | select(.project_number == '$task_number')).completion_summary = $summary' \
  specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

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

**If partial**:

Keep status as "implementing" but update resume point:
```bash
jq --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --argjson phase "$phases_completed" \
  '(.active_projects[] | select(.project_number == '$task_number')) |= . + {
    last_updated: $ts,
    resume_phase: ($phase + 1)
  }' specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
```

TODO.md stays as `[IMPLEMENTING]`.

**Update plan file** (if exists): Update the Status field to `[PARTIAL]`:
```bash
plan_file=$(ls -1 "specs/${task_number}_${project_name}/plans/implementation-"*.md 2>/dev/null | sort -V | tail -1)
if [ -n "$plan_file" ] && [ -f "$plan_file" ]; then
    sed -i "s/^\- \*\*Status\*\*: \[.*\]$/- **Status**: [PARTIAL]/" "$plan_file"
fi
```

**On failed**: Keep status as "implementing" for retry.

---

### Stage 11: Link Artifacts

Add artifact to state.json with summary.

**IMPORTANT**: Use two-step jq pattern to avoid Issue #1132 escaping bug. See `jq-escaping-workarounds.md`.

```bash
artifact_path="specs/${task_number}_${project_name}/summaries/implementation-summary-${date}.md"
artifact_type="summary"
artifact_summary="Implementation summary with verification results"

if [ -n "$artifact_path" ]; then
    # Step 1: Filter out existing summary artifacts (use "| not" pattern to avoid != escaping - Issue #1132)
    jq '(.active_projects[] | select(.project_number == '$task_number')).artifacts =
        [(.active_projects[] | select(.project_number == '$task_number')).artifacts // [] | .[] | select(.type == "summary" | not)]' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json

    # Step 2: Add new summary artifact
    jq --arg path "$artifact_path" \
       --arg type "$artifact_type" \
       --arg summary "$artifact_summary" \
      '(.active_projects[] | select(.project_number == '$task_number')).artifacts += [{"path": $path, "type": $type, "summary": $summary}]' \
      specs/state.json > /tmp/state.json && mv /tmp/state.json specs/state.json
fi
```

**Update TODO.md** (if implemented): Add summary artifact link:
```markdown
- **Summary**: [implementation-summary-{DATE}.md]({artifact_path})
```

---

### Stage 12: Git Commit

Commit changes with session ID:

```bash
git add -A
git commit -m "task ${task_number}: complete implementation

Session: ${session_id}

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
```

---

### Stage 13: Cleanup

Remove marker files:

```bash
rm -f specs/.postflight-pending
rm -f specs/.postflight-loop-guard
```

---

### Stage 14: Return Brief Summary

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

### MCP Tool Error Recovery

When MCP tool calls fail (AbortError -32001 or similar):

1. **Log the error context** (tool name, operation, proof state, session_id)
2. **Retry once** after 5-second delay for timeout errors
3. **Try alternative tool** per this fallback table:

| Primary Tool | Alternative | Fallback |
|--------------|-------------|----------|
| `lean_diagnostic_messages` | `lean_goal` | `lake build` via Bash |
| `lean_goal` | (essential - retry more) | Document state manually |
| `lean_state_search` | `lean_hammer_premise` | Manual tactic exploration |
| `lean_local_search` | (no alternative) | Continue with available info |

4. **Update partial_progress** in metadata if needed
5. **Continue with available information** - don't block entire implementation on one tool failure

### Build Failure

When `lake build` fails:
1. Capture full error output
2. Use `lean_goal` to check proof state at error location
3. Attempt to fix if error is clear
4. If unfixable, return partial with:
   - Build error message
   - File and line of error
   - Recommendation for fix

### Proof Stuck

When proof cannot be completed after multiple attempts:
1. Save partial progress (do not delete)
2. Document current proof state via `lean_goal`
3. Return partial with:
   - What was proven
   - Current goal state
   - Attempted tactics
   - Recommendation for next steps

### Git Commit Failure
Non-blocking: Log failure but continue with success response.

---

## Return Format

This skill returns a **brief text summary** (NOT JSON).

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
