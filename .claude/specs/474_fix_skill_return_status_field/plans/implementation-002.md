# Implementation Plan: Task #474 (v002)

- **Task**: 474 - Fix skill return "status": "completed" field causing premature stops
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: High
- **Dependencies**: None (builds on tasks 462, 467)
- **Previous Version**: implementation-001.md
- **Revision Reason**: User feedback - the issue is the VALUE "completed", not the field name "status". The return should use contextual values like "planned", "researched", "implemented" that describe the achieved state.
- **Type**: meta
- **Lean Intent**: false

## Overview

Fix the root cause of workflow commands stopping prematurely after skill returns. The problem: skills return JSON with `"status": "completed"` which Claude interprets as a signal to stop execution.

**Key Insight (v002)**: The problem is not the field name "status" but the **value** "completed". This value is semantically overloaded - it means "this operation succeeded" but Claude interprets it as "the entire task is done, stop working."

**Solution (v002)**: Replace `"status": "completed"` with contextually appropriate values that describe what state was achieved:
- `"status": "planned"` - after planning completes
- `"status": "researched"` - after research completes
- `"status": "implemented"` - after implementation completes
- `"status": "synced"` - after status-sync operations
- `"status": "failed"` - on failure (unchanged)

This approach:
1. Preserves the "status" field name (no widespread renaming needed)
2. Uses values that match the actual workflow state transitions
3. Avoids the trigger word "completed"
4. Is more semantically accurate - describes *what* was achieved

## Goals & Non-Goals

**Goals**:
- Replace `"status": "completed"` value with contextual status values
- Update skill return format documentation
- Update agent return format documentation
- Ensure skill-status-sync returns match the operation type

**Non-Goals**:
- Renaming the "status" field to "outcome" (unnecessary)
- Changing task status values in state.json (these are correct)
- Removing continuation markers (defense-in-depth)

## Value Mapping

| Context | Old Value | New Value |
|---------|-----------|-----------|
| After preflight_update | "completed" | "synced" |
| After postflight_update | "completed" | The target_status (e.g., "planned", "researched") |
| After artifact_link | "completed" | "linked" |
| Research skill/agent | "completed" | "researched" |
| Plan skill/agent | "completed" | "planned" |
| Implement skill/agent | "completed" | "implemented" |
| Git workflow skill | "completed" | "committed" |
| Meta builder agent | "completed" | "tasks_created" |
| On failure | "failed" | "failed" (unchanged) |
| Partial completion | "partial" | "partial" (unchanged) |

## Implementation Phases

### Phase 1: Update Core Schema [NOT STARTED]

**Goal**: Update subagent-return.md schema to specify contextual status values

**Tasks**:
- [ ] Update `.claude/context/core/formats/subagent-return.md`
  - Change `"status"` enum from `["completed", "failed", "partial"]` to `["synced", "researched", "planned", "implemented", "linked", "committed", "tasks_created", "failed", "partial"]`
  - Add documentation explaining contextual values
  - Update examples to show operation-specific values
  - Add rationale section explaining why "completed" was removed

**Timing**: 20 minutes

**Files to modify**:
- `.claude/context/core/formats/subagent-return.md`

**Verification**:
- Schema shows expanded enum with contextual values
- "completed" value removed from enum
- Rationale documented

---

### Phase 2: Update skill-status-sync [NOT STARTED]

**Goal**: Update the primary skill causing the issue - skill-status-sync

This is the most critical phase since skill-status-sync is invoked at every checkpoint and its "completed" return is what triggers Claude to stop.

**Tasks**:
- [ ] Update `.claude/skills/skill-status-sync/SKILL.md`
  - preflight_update returns: `"status": "synced"`
  - postflight_update returns: `"status": "{target_status}"` (e.g., "planned", "researched")
  - artifact_link returns: `"status": "linked"` or `"status": "skipped"`
  - Error returns: `"status": "failed"` (unchanged)
  - Update all output examples
  - Update Return Format section

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-status-sync/SKILL.md`

**Verification**:
- No `"status": "completed"` in file
- Return examples show contextual values
- preflight shows "synced", postflight shows target status

---

### Phase 3: Update Other Skills [NOT STARTED]

**Goal**: Update remaining skill files to use contextual status values

**Tasks**:
- [ ] Update `.claude/skills/skill-planner/SKILL.md` - `"status": "planned"`
- [ ] Update `.claude/skills/skill-researcher/SKILL.md` - `"status": "researched"`
- [ ] Update `.claude/skills/skill-lean-research/SKILL.md` - `"status": "researched"`
- [ ] Update `.claude/skills/skill-implementer/SKILL.md` - `"status": "implemented"`
- [ ] Update `.claude/skills/skill-lean-implementation/SKILL.md` - `"status": "implemented"`
- [ ] Update `.claude/skills/skill-latex-implementation/SKILL.md` - `"status": "implemented"`
- [ ] Update `.claude/skills/skill-git-workflow/SKILL.md` - `"status": "committed"`
- [ ] Update `.claude/skills/skill-meta/SKILL.md` - `"status": "delegated"` (delegates to agent)

**Timing**: 40 minutes

**Files to modify**:
- 8 skill files in `.claude/skills/*/SKILL.md`

**Verification**:
- Each skill uses operation-appropriate status value
- No `"status": "completed"` in any skill file

---

### Phase 4: Update Agent Files [NOT STARTED]

**Goal**: Update agent files to use contextual status values

**Tasks**:
- [ ] Update `.claude/agents/planner-agent.md` - `"status": "planned"`
- [ ] Update `.claude/agents/lean-research-agent.md` - `"status": "researched"`
- [ ] Update `.claude/agents/general-research-agent.md` - `"status": "researched"`
- [ ] Update `.claude/agents/lean-implementation-agent.md` - `"status": "implemented"`
- [ ] Update `.claude/agents/general-implementation-agent.md` - `"status": "implemented"`
- [ ] Update `.claude/agents/latex-implementation-agent.md` - `"status": "implemented"`
- [ ] Update `.claude/agents/meta-builder-agent.md` - `"status": "tasks_created"`

**Timing**: 35 minutes

**Files to modify**:
- 7 agent files in `.claude/agents/*.md`

**Verification**:
- Each agent uses operation-appropriate status value
- No `"status": "completed"` in any agent file

---

### Phase 5: Verification and Summary [NOT STARTED]

**Goal**: Verify all changes are consistent and create implementation summary

**Tasks**:
- [ ] Run comprehensive grep for remaining `"completed"` patterns
  - `grep -r '"status".*"completed"' .claude/` should only match state.json task status
- [ ] Verify skill-status-sync preflight returns "synced"
- [ ] Verify postflight returns the target status (planned/researched/etc)
- [ ] Create implementation summary

**Timing**: 25 minutes

**Verification**:
- No `"status": "completed"` patterns remain in skill/agent returns
- Task status "completed" in state.json unchanged (different context)
- Continuation markers from task 467 still in place

## Testing & Validation

- [ ] grep verification: `grep -r '"status":\s*"completed"' .claude/` only matches state.json
- [ ] Visual inspection of skill-status-sync returns
- [ ] Verify return format is valid JSON

## Artifacts & Outputs

- plans/implementation-002.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (on completion)
- Modified files:
  - 1 schema file (subagent-return.md)
  - 9 skill files
  - 7 agent files

## Key Differences from v001

| Aspect | v001 | v002 |
|--------|------|------|
| Core change | Rename field "status" → "outcome" | Change VALUE "completed" → contextual |
| Scope | All occurrences of field name | Only value substitutions |
| Semantic accuracy | Generic "outcome" | Operation-specific (planned, researched, etc.) |
| Risk | Higher (field name change) | Lower (value change only) |
| Effort | 3 hours | 2.5 hours |

## Rollback/Contingency

If the change causes issues:
1. Values can be reverted via git revert
2. Continuation markers from task 467 remain as fallback
3. No structural changes to JSON format (just values)

## Notes

- The "status" field name is preserved - only VALUES change
- This matches how state.json already works (status: "planned", "researched", etc.)
- The trigger word "completed" is avoided entirely in skill/agent returns
- Task status "completed" in state.json remains valid (different context - describes task lifecycle)
