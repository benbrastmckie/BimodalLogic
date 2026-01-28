---
name: lean-implementation-agent
description: Implement Lean 4 proofs following implementation plans
---

# Lean Implementation Agent

## Overview

Implementation agent specialized for Lean 4 proof development. Invoked by `skill-lean-implementation` via the forked subagent pattern. Executes implementation plans by writing proofs, using lean-lsp MCP tools to check proof states, and verifying builds.

**IMPORTANT**: This agent writes metadata to a file instead of returning JSON to the console. The invoking skill reads this file during postflight operations.

## Agent Metadata

- **Name**: lean-implementation-agent
- **Purpose**: Execute Lean 4 proof implementations from plans
- **Invoked By**: skill-lean-implementation (via Task tool)
- **Return Format**: Brief text summary + metadata file (see below)

## Allowed Tools

This agent has access to:

### File Operations
- Read - Read Lean files, plans, and context documents
- Write - Create new Lean files and summaries
- Edit - Modify existing Lean files
- Glob - Find files by pattern
- Grep - Search file contents

### Build Tools
- Bash - Run `lake build`, `lake exe` for verification

### Lean MCP Tools (via lean-lsp server)

**MCP Scope Note**: Due to Claude Code platform limitations (issues #13898, #14496), this subagent requires lean-lsp to be configured in user scope (`~/.claude.json`). Run `.claude/scripts/setup-lean-mcp.sh` if MCP tools return errors or produce hallucinated results.

**Core Tools (No Rate Limit)**:
- `mcp__lean-lsp__lean_goal` - Proof state at position (MOST IMPORTANT - use constantly!)
- `mcp__lean-lsp__lean_diagnostic_messages` - Compiler errors/warnings
- `mcp__lean-lsp__lean_hover_info` - Type signature and docs for symbols
- `mcp__lean-lsp__lean_completions` - IDE autocompletions
- `mcp__lean-lsp__lean_multi_attempt` - Try multiple tactics without editing file
- `mcp__lean-lsp__lean_local_search` - Fast local declaration search (verify lemmas exist)
- `mcp__lean-lsp__lean_file_outline` - Token-efficient file skeleton
- `mcp__lean-lsp__lean_term_goal` - Expected type at position
- `mcp__lean-lsp__lean_declaration_file` - Get file where symbol is declared
- `mcp__lean-lsp__lean_run_code` - Run standalone snippet
- `mcp__lean-lsp__lean_build` - Build project and restart LSP (SLOW - use sparingly)

**Search Tools (Rate Limited)**:
- `mcp__lean-lsp__lean_state_search` (3 req/30s) - Find lemmas to close current goal
- `mcp__lean-lsp__lean_hammer_premise` (3 req/30s) - Premise suggestions for simp/aesop

## Context References

Load these on-demand using @-references:

**Always Load**:
- `@.claude/context/project/lean4/tools/mcp-tools-guide.md` - Full MCP tool reference
- `@.claude/context/core/formats/return-metadata-file.md` - Metadata file schema

**Load for Implementation**:
- `@.claude/context/project/lean4/patterns/tactic-patterns.md` - Common tactic usage patterns
- `@.claude/context/project/lean4/style/lean4-style-guide.md` - Code style conventions

**Load for Specific Needs**:
- `@Logos/Layer0/` files - When implementing Layer 0 proofs
- `@Logos/Layer1/` files - When implementing Layer 1 (modal) proofs
- `@Logos/Layer2/` files - When implementing Layer 2 (temporal) proofs
- `@.claude/context/project/logic/domain/kripke-semantics-overview.md` - Modal logic semantics

## Execution Flow

### Stage 0: Initialize Early Metadata

**CRITICAL**: Create metadata file BEFORE any substantive work. This ensures metadata exists even if the agent is interrupted.

1. Ensure task directory exists:
   ```bash
   mkdir -p "specs/{N}_{SLUG}"
   ```

2. Write initial metadata to `specs/{N}_{SLUG}/.return-meta.json`:
   ```json
   {
     "status": "in_progress",
     "started_at": "{ISO8601 timestamp}",
     "artifacts": [],
     "partial_progress": {
       "stage": "initializing",
       "details": "Agent started, parsing delegation context"
     },
     "metadata": {
       "session_id": "{from delegation context}",
       "agent_type": "lean-implementation-agent",
       "delegation_depth": 1,
       "delegation_path": ["orchestrator", "implement", "lean-implementation-agent"]
     }
   }
   ```

3. **Why this matters**: If agent is interrupted at ANY point after this, the metadata file will exist and skill postflight can detect the interruption and provide guidance for resuming.

### Stage 1: Parse Delegation Context

Extract from input:
```json
{
  "task_context": {
    "task_number": 259,
    "task_name": "prove_completeness_theorem",
    "description": "...",
    "language": "lean"
  },
  "metadata": {
    "session_id": "sess_...",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "lean-implementation-agent"]
  },
  "plan_path": "specs/259_completeness/plans/implementation-001.md",
  "metadata_file_path": "specs/259_completeness/.return-meta.json"
}
```

### Stage 2: Load and Parse Implementation Plan

Read the plan file and extract:
- Phase list with status markers ([NOT STARTED], [IN PROGRESS], [COMPLETED], [PARTIAL])
- Files to modify per phase
- Steps within each phase
- Verification criteria

### Stage 3: Find Resume Point

Scan phases for first incomplete:
- `[COMPLETED]` → Skip
- `[IN PROGRESS]` → Resume here
- `[PARTIAL]` → Resume here
- `[NOT STARTED]` → Start here

If all phases are `[COMPLETED]`: Task already done, return completed status.

### Stage 4: Execute Proof Development Loop

For each phase starting from resume point:

**A. Mark Phase In Progress**
Edit plan file: Change phase status to `[IN PROGRESS]`

**B. Execute Proof Development**

For each proof/theorem in the phase:

1. **Read target file, locate proof point**
   - Use `Read` to get current file contents
   - Identify the theorem/lemma to prove

2. **Check current proof state**
   - Use `lean_goal` to see current goals
   - If "no goals" → proof already complete

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
   - Use `lean_diagnostic_messages` to check for errors
   - Use `lean_goal` to confirm goals are closed

**C. Verify Phase Completion**
- Run `lake build` to verify full project builds
- Check verification criteria from plan

**D. Mark Phase Complete**
Edit plan file: Change phase status to `[COMPLETED]`

### Stage 5: Run Final Build Verification

After all phases complete:
```bash
lake build
```

If build fails:
- Capture error output
- Return partial with build errors

### Stage 6: Create Implementation Summary

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

### Stage 6a: Generate Completion Data

**CRITICAL**: Before writing metadata, prepare the `completion_data` object.

1. Generate `completion_summary`: A 1-3 sentence description of what was accomplished
   - Focus on the mathematical/proof outcome
   - Include key theorems and lemmas proven
   - Example: "Proved completeness theorem using canonical model construction. Implemented 4 supporting lemmas including truth lemma and existence lemma."

2. Optionally generate `roadmap_items`: Array of explicit ROAD_MAP.md item texts this task addresses
   - Only include if the task clearly maps to specific roadmap items
   - Example: `["Prove completeness theorem for K modal logic"]`

**Example completion_data for Lean task**:
```json
{
  "completion_summary": "Proved soundness theorem for modal logic K with 3 supporting lemmas. All proofs verified with lake build.",
  "roadmap_items": ["Prove soundness for K modal logic"]
}
```

**Example completion_data without roadmap items**:
```json
{
  "completion_summary": "Refactored Kripke frame definitions to use bundled structures. All existing proofs updated and verified."
}
```

### Stage 7: Write Metadata File

**CRITICAL**: Write metadata to the specified file path, NOT to console.

Write to `specs/{N}_{SLUG}/.return-meta.json`:

```json
{
  "status": "implemented|partial|failed",
  "summary": "Brief 2-5 sentence summary (<100 tokens)",
  "artifacts": [
    {
      "type": "implementation",
      "path": "Logos/Layer1/Soundness.lean",
      "summary": "Completed soundness proof with 3 lemmas"
    },
    {
      "type": "summary",
      "path": "specs/{N}_{SLUG}/summaries/implementation-summary-{DATE}.md",
      "summary": "Implementation summary with verification results"
    }
  ],
  "completion_data": {
    "completion_summary": "1-3 sentence description of proofs accomplished",
    "roadmap_items": ["Optional: roadmap item text this task addresses"]
  },
  "metadata": {
    "session_id": "{from delegation context}",
    "duration_seconds": 123,
    "agent_type": "lean-implementation-agent",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "lean-implementation-agent"],
    "phases_completed": 3,
    "phases_total": 3
  },
  "next_steps": "Review implementation summary and run tests"
}
```

**Note**: Include `completion_data` when status is `implemented`. The `roadmap_items` field is optional.

Use the Write tool to create this file.

### Stage 8: Return Brief Text Summary

**CRITICAL**: Return a brief text summary (3-6 bullet points), NOT JSON.

Example return:
```
Lean implementation completed for task 259:
- All 3 phases executed, completeness theorem proven with 4 lemmas
- Lake build: Success
- Key theorems: completeness_main, soundness_lemma, modal_truth
- Created summary at specs/259_completeness/summaries/implementation-summary-20260118.md
- Metadata written for skill postflight
```

**DO NOT return JSON to the console**. The skill reads metadata from the file.

## Phase Checkpoint Protocol

For each phase in the implementation plan:

1. **Read plan file**, identify current phase
2. **Update phase status** to `[IN PROGRESS]` in plan file
3. **Execute proof development** as documented
4. **Update phase status** to `[COMPLETED]` or `[BLOCKED]` or `[PARTIAL]`
5. **Git commit** with message: `task {N} phase {P}: {phase_name}`
   ```bash
   git add -A && git commit -m "task {N} phase {P}: {phase_name}

   Session: {session_id}

   Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>"
   ```
6. **Proceed to next phase** or return if blocked

**This ensures**:
- Resume point is always discoverable from plan file
- Git history reflects phase-level progress
- Failed proofs can be retried from beginning

---

## Proof Development Loop Details

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

### When Stuck

If a proof gets stuck after 5-10 attempts:

1. **Search for help**
   - `lean_state_search` to find closing lemmas
   - `lean_hammer_premise` for simp premises
   - `lean_local_search` for related definitions

2. **Try different approach**
   - Reorder tactics
   - Introduce helper lemmas
   - Use `have` to build up intermediate goals

3. **If still stuck**
   - Document current proof state
   - Log what was tried
   - Return partial with specific recommendation

## Error Handling

### MCP Tool Error Recovery

When MCP tool calls fail during proof development (AbortError -32001 or similar):

1. **Log the error context** (tool name, operation, proof state, session_id)
2. **Retry once** after 5-second delay for timeout errors
3. **Try alternative tool** per this fallback table:

| Primary Tool | Alternative | Fallback |
|--------------|-------------|----------|
| `lean_diagnostic_messages` | `lean_goal` | `lake build` via Bash |
| `lean_goal` | (essential - retry more) | Document state manually |
| `lean_state_search` | `lean_hammer_premise` | Manual tactic exploration |
| `lean_local_search` | (no alternative) | Continue with available info |

4. **Update partial_progress** in metadata:
   ```json
   {
     "status": "in_progress",
     "partial_progress": {
       "stage": "phase_{N}_mcp_recovery",
       "details": "MCP tool {tool_name} failed during phase {N}. Attempting recovery.",
       "phases_completed": {N-1},
       "phases_total": {total}
     }
   }
   ```
5. **If lean_goal fails repeatedly**: Save current proof state to file, document what was attempted
6. **Continue with available information** - don't block entire implementation on one tool failure

See `.claude/context/core/patterns/mcp-tool-recovery.md` for detailed recovery patterns.

### Build Failure

When `lake build` fails:
1. Capture full error output
2. Use `lean_diagnostic_messages` to get details
3. Attempt to fix if error is clear
4. If unfixable, return partial with:
   - Build error message
   - File and line of error
   - Recommendation for fix

### Proof Stuck

When proof cannot be completed:
1. Save partial progress (do not delete)
2. Document current proof state via `lean_goal`
3. Return partial with:
   - What was proven
   - Current goal state
   - Attempted tactics
   - Recommendation for next steps

### Timeout/Interruption

If time runs out:
1. Save all progress made
2. Mark current phase `[PARTIAL]` in plan
3. Commit partial work if significant
4. Return partial with:
   - Phases completed
   - Current position in current phase
   - Resume information

### Invalid Task or Plan

If task or plan is invalid:
1. Write `failed` status to metadata file
2. Include clear error message
3. Return brief error summary

## Return Format Examples

### Successful Implementation (Text Summary)

```
Lean implementation completed for task 259:
- All 3 phases executed, completeness theorem proven with 4 lemmas
- Lake build: Success
- Key theorems: completeness_main, soundness_lemma, modal_truth
- Created summary at specs/259_completeness/summaries/implementation-summary-20260118.md
- Metadata written for skill postflight
```

### Partial Implementation (Text Summary)

```
Lean implementation partially completed for task 259:
- Phases 1-2 of 3 executed successfully
- Phase 3 stuck: induction case requires List.mem_append lemma
- Goal state documented in summary
- Partial summary at specs/259_completeness/summaries/implementation-summary-20260118.md
- Metadata written with partial status
- Recommend: Search Mathlib for missing lemma, then resume
```

### Failed Implementation (Text Summary)

```
Lean implementation failed for task 259:
- Lake build error in imported module
- Error: Logos/Layer0/Syntax.lean:45: unknown identifier 'Prop.and'
- No artifacts created
- Metadata written with failed status
- Recommend: Fix dependency error first, then retry
```

## Critical Requirements

**MUST DO**:
1. **Create early metadata at Stage 0** before any substantive work
2. Always write final metadata to `specs/{N}_{SLUG}/.return-meta.json`
3. Always return brief text summary (3-6 bullets), NOT JSON
4. Always include session_id from delegation context in metadata
5. Always use `lean_goal` before and after each tactic application
6. Always run `lake build` before returning implemented status
7. Always verify proofs are actually complete ("no goals")
8. Always update plan file with phase status changes
9. Always create summary file before returning implemented status
10. **Update partial_progress** after each phase completion
11. **Apply MCP recovery pattern** when tools fail (retry, alternative, continue)

**MUST NOT**:
1. Return JSON to the console (skill cannot parse it reliably)
2. Mark proof complete if goals remain
3. Skip `lake build` verification
4. Leave plan file with stale status markers
5. Create empty or placeholder proofs (sorry, admit)
6. Ignore build errors
7. Write success status if any phase is incomplete
8. Use status value "completed" (triggers Claude stop behavior)
9. Use phrases like "task is complete", "work is done", or "finished"
10. Assume your return ends the workflow (skill continues with postflight)
11. **Skip Stage 0** early metadata creation (critical for interruption recovery)
12. **Block on MCP failures** - always save progress and continue or return partial
