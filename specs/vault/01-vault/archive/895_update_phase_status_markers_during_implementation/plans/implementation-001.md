# Implementation Plan: Task #895

- **Task**: 895 - Update phase status markers during implementation
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/895_update_phase_status_markers_during_implementation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Modify implementation agent definitions and related skills to ensure phase status markers are updated at appropriate lifecycle points. The research confirms that agents already mark phases `[IN PROGRESS]` before work, but error and partial paths do not consistently update to terminal statuses (`[COMPLETED]`, `[PARTIAL]`, `[BLOCKED]`). This plan addresses the gap by making status transitions explicit in all code paths.

### Research Integration

Key findings from research-001.md:
1. Two-level status management exists: task-level (TODO.md/state.json) vs phase-level (plan file)
2. Current agents already mark `[IN PROGRESS]` before work begins (Stage 4A in both agents)
3. Gap: Error paths don't explicitly handle `[PARTIAL]` or `[BLOCKED]` status updates
4. Terminology: Keep using `[IN PROGRESS]` for phases (not `[IMPLEMENTING]`) per artifact-formats.md

## Goals & Non-Goals

**Goals**:
- Ensure every phase receives a terminal status (`[COMPLETED]`, `[PARTIAL]`, or `[BLOCKED]`) before the agent proceeds to the next phase or returns
- Make error paths explicitly update phase status before returning or committing
- Add a status decision tree to artifact-formats.md documenting when each terminal status should be used
- Update skill-team-implement to handle teammate phase status updates consistently

**Non-Goals**:
- Change terminology (`[IN PROGRESS]` remains the correct phase status, not `[IMPLEMENTING]`)
- Add new status markers beyond the established set
- Change task-level status handling (this is about phase-level only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing implementations | H | L | Changes are additive; existing `[COMPLETED]` paths unchanged |
| Status update race conditions | M | L | Git commits happen after status update; atomic within single agent |
| Inconsistent documentation | M | M | Update artifact-formats.md in same phase as agent changes |

## Implementation Phases

### Phase 1: Update general-implementation-agent.md [NOT STARTED]

- **Dependencies:** None
- **Goal:** Enhance Phase Checkpoint Protocol to explicitly handle terminal statuses on all code paths

**Tasks**:
- [ ] Add explicit status decision tree section before Phase Checkpoint Protocol
- [ ] Update Stage 4 to show status update on step failure (`[PARTIAL]` or `[BLOCKED]`)
- [ ] Update Stage 4 verification failure path with explicit status update
- [ ] Add step 4E "Mark Phase Status" that consolidates status decision logic
- [ ] Update Error Handling section to reference phase status updates

**Timing**: 45 minutes

**Files to modify**:
- `.claude/agents/general-implementation-agent.md` - Enhance Stage 4 and add status decision logic

**Verification**:
- Phase Checkpoint Protocol has explicit status update on error paths
- Status decision criteria documented for COMPLETED/PARTIAL/BLOCKED

---

### Phase 2: Update lean-implementation-flow.md [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Apply same phase status handling patterns to Lean implementation flow

**Tasks**:
- [ ] Update Stage 4 to mirror general-implementation-agent patterns
- [ ] Add explicit status update before Stage 4E (Update Progress Subsection)
- [ ] Update error handling sections with status decision criteria
- [ ] Ensure `[PARTIAL]` and `[BLOCKED]` are handled consistently with Phase 1

**Timing**: 30 minutes

**Files to modify**:
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` - Stage 4 error handling

**Verification**:
- Phase status updated before Progress subsection is written
- Error paths show explicit terminal status decision

---

### Phase 3: Update skill-team-implement for teammate status handling [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Ensure team skill handles teammate phase status when phases fail or timeout

**Tasks**:
- [ ] Add phase status update logic in Stage 6 when teammate completes
- [ ] Add explicit `[PARTIAL]`/`[BLOCKED]` handling in Error Handling section
- [ ] Update context exhaustion handling to ensure phase is marked appropriately
- [ ] Ensure debug cycle marks phase status correctly

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-team-implement/SKILL.md` - Stage 6, Stage 7, Error Handling

**Verification**:
- Teammate failure triggers phase status update
- Context exhaustion updates phase to `[PARTIAL]`
- Debug cycle failure marks phase appropriately

---

### Phase 4: Update artifact-formats.md with status decision tree [NOT STARTED]

- **Dependencies:** None
- **Goal:** Document when each terminal phase status should be used

**Tasks**:
- [ ] Add "Phase Status Decision Tree" section after "Phase Status Markers" section
- [ ] Document criteria for `[COMPLETED]` (all steps done, verification passed)
- [ ] Document criteria for `[PARTIAL]` (some progress, can resume)
- [ ] Document criteria for `[BLOCKED]` (cannot proceed without external change)
- [ ] Add examples for each status transition

**Timing**: 30 minutes

**Files to modify**:
- `.claude/rules/artifact-formats.md` - Add status decision tree section

**Verification**:
- Decision tree is clear and actionable
- Each terminal status has documented criteria
- Examples illustrate proper usage

---

### Phase 5: Verification and consistency check [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4
- **Goal:** Verify all changes are consistent and complete

**Tasks**:
- [ ] Review all modified files for consistency in terminology
- [ ] Verify cross-references between agent definitions and artifact-formats.md
- [ ] Ensure status decision criteria are identical across agents
- [ ] Check that skill-team-implement references match agent patterns

**Timing**: 15 minutes

**Files to modify**:
- No new modifications; read and verify existing changes

**Verification**:
- All files use consistent `[IN PROGRESS]` terminology (not `[IMPLEMENTING]`)
- Status decision tree is referenced in agent definitions
- No contradictions between files

## Testing & Validation

- [ ] All modified markdown files have valid structure
- [ ] No broken internal references in documentation
- [ ] Status markers use correct terminology throughout
- [ ] Phase Checkpoint Protocol is complete and actionable

## Artifacts & Outputs

- `.claude/agents/general-implementation-agent.md` (modified)
- `.claude/context/project/lean4/agents/lean-implementation-flow.md` (modified)
- `.claude/skills/skill-team-implement/SKILL.md` (modified)
- `.claude/rules/artifact-formats.md` (modified)
- `specs/895_update_phase_status_markers_during_implementation/summaries/implementation-summary-{DATE}.md` (created)

## Rollback/Contingency

All changes are documentation updates to `.claude/` files. If issues arise:
1. Revert specific files via `git checkout HEAD~1 -- <file>`
2. Changes are additive; existing functionality unaffected
3. No code execution paths modified; behavior changes are agent instruction changes
