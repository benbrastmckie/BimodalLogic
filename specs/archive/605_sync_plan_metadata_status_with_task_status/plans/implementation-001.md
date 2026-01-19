# Implementation Plan: Task #605

- **Task**: 605 - Sync Plan Metadata Status with Task Status
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/605_sync_plan_metadata_status_with_task_status/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Implementation plan files have a `**Status**:` field in their metadata header that is never updated when tasks progress through the research/plan/implement cycle. This creates an inconsistency where completed tasks still show `[NOT STARTED]` in their plan files. The fix requires adding plan file status updates to the preflight and postflight stages of the three implementation skills: skill-implementer, skill-lean-implementation, and skill-latex-implementation.

### Research Integration

From research-001.md:
- Evidence: Tasks 604 and 568 are `[COMPLETED]` but their plan files show `[NOT STARTED]`
- Insertion points: Stage 2 (preflight) and Stage 7 (postflight) of implementation skills
- Pattern: Use sed to update the `**Status**:` line after state.json/TODO.md updates
- Risk mitigations: Check plan file exists before editing, use latest version if multiple plans

## Goals & Non-Goals

**Goals**:
- Synchronize plan file `**Status**:` field with task status during implementation
- Update plan status to `[IMPLEMENTING]` in preflight
- Update plan status to `[COMPLETED]` or `[PARTIAL]` in postflight
- Handle cases where plan file doesn't exist gracefully

**Non-Goals**:
- Updating phase-level status markers (agents already do this)
- Retroactively fixing existing completed tasks
- Adding plan status sync to non-implementation skills (research, planning)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Plan file doesn't exist | Low | Medium | Check file exists before sed; skip gracefully |
| Multiple plan versions | Medium | Low | Use `sort -V \| tail -1` to get latest version |
| Regex doesn't match malformed header | Low | Low | Use robust pattern with wildcard for status value |
| Edit fails silently | Medium | Low | Document but don't block on verification |

## Implementation Phases

### Phase 1: Add Plan Status Update to skill-implementer [NOT STARTED]

**Goal**: Add plan file status synchronization to the general implementation skill.

**Tasks**:
- [ ] Add plan file lookup helper logic after Stage 2 preflight updates
- [ ] Add sed command to update `**Status**:` to `[IMPLEMENTING]` in Stage 2
- [ ] Add plan file status update to Stage 7 postflight (COMPLETED or PARTIAL based on result)
- [ ] Add inline comments explaining the plan status sync

**Timing**: 40 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add plan status update to Stages 2 and 7

**Verification**:
- Plan status update code is present in both preflight (Stage 2) and postflight (Stage 7)
- Code handles missing plan file gracefully

---

### Phase 2: Add Plan Status Update to skill-lean-implementation [NOT STARTED]

**Goal**: Add plan file status synchronization to the Lean implementation skill.

**Tasks**:
- [ ] Add plan file lookup helper logic after Stage 2 preflight updates
- [ ] Add sed command to update `**Status**:` to `[IMPLEMENTING]` in Stage 2
- [ ] Add plan file status update to Stage 7 postflight (COMPLETED or PARTIAL based on result)
- [ ] Add inline comments explaining the plan status sync

**Timing**: 40 minutes

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add plan status update to Stages 2 and 7

**Verification**:
- Plan status update code is present in both preflight (Stage 2) and postflight (Stage 7)
- Code handles missing plan file gracefully

---

### Phase 3: Add Plan Status Update to skill-latex-implementation [NOT STARTED]

**Goal**: Add plan file status synchronization to the LaTeX implementation skill.

**Tasks**:
- [ ] Add plan file lookup helper logic after Stage 0 preflight updates
- [ ] Add sed command to update `**Status**:` to `[IMPLEMENTING]` in Stage 0
- [ ] Add plan file status update to Stage 5 postflight (COMPLETED or PARTIAL based on result)
- [ ] Add inline comments explaining the plan status sync

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-latex-implementation/SKILL.md` - Add plan status update to Stages 0 and 5

**Verification**:
- Plan status update code is present in both preflight (Stage 0) and postflight (Stage 5)
- Code handles missing plan file gracefully
- Note: skill-latex-implementation uses different stage numbering (0-based)

---

### Phase 4: Test and Verify [NOT STARTED]

**Goal**: Verify the changes work correctly with a test task.

**Tasks**:
- [ ] Review all three modified skill files for consistency
- [ ] Confirm the sed pattern matches plan-format.md metadata format
- [ ] Document the status update pattern in the skill files

**Timing**: 10 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- All three skills have consistent plan status update logic
- Status update uses correct marker format: `**Status**: [STATUS]`

## Testing & Validation

- [ ] Verify all three skill files contain plan status update code
- [ ] Confirm preflight updates to `[IMPLEMENTING]` are present
- [ ] Confirm postflight updates to `[COMPLETED]`/`[PARTIAL]` are present
- [ ] Confirm graceful handling of missing plan files

## Artifacts & Outputs

- `.claude/skills/skill-implementer/SKILL.md` - Modified with plan status sync
- `.claude/skills/skill-lean-implementation/SKILL.md` - Modified with plan status sync
- `.claude/skills/skill-latex-implementation/SKILL.md` - Modified with plan status sync
- `specs/605_sync_plan_metadata_status_with_task_status/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If changes cause issues:
1. Revert skill files to previous versions via `git checkout HEAD~1 -- .claude/skills/skill-*/SKILL.md`
2. Plan status sync is isolated to a few lines - easy to identify and remove
3. No impact on core functionality - plan status is informational only
