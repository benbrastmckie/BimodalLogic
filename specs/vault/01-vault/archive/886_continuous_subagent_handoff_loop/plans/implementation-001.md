# Implementation Plan: Task #886

- **Task**: 886 - Continuous Subagent Handoff Loop
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: Tasks 883, 884, 885 (completed)
- **Research Inputs**: specs/886_continuous_subagent_handoff_loop/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Implement a continuous handoff loop in skill-implementer and skill-lean-implementation that automatically re-invokes subagents when partial status is returned without requiring user review. The loop checks the `requires_user_review` flag (from task 885), respects an iteration limit, and passes handoff context (from task 883) to successor subagents. This enables multi-phase implementations to complete automatically without manual intervention for recoverable partials.

### Research Integration

From research-001.md:
- Loop insertion point: Stage 6a between metadata parsing and status update
- Stop conditions: implemented, blocked, failed, requires_user_review=true, iteration limit
- Per-iteration commits preserve progress
- Handoff context passed via `partial_progress.handoff_path`

## Goals & Non-Goals

**Goals**:
- Auto-resume partial implementations that don't require user review
- Preserve progress with per-iteration commits
- Configurable iteration limit (default 5)
- Clear stop conditions and exit messaging
- Consistent behavior across both implementation skills

**Non-Goals**:
- Parallel execution within the loop (sequential only)
- Complex retry strategies with backoff (simple re-invocation)
- Automatic error correction (subagent handles that)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Infinite loop | High | Low | max_iterations guard (default 5) |
| Oscillating failures | Medium | Low | Track error hashes, exit on repeat |
| Lost progress on interrupt | Medium | Medium | Per-iteration commits |
| Context exhaustion in loop | Low | Low | Loop is lightweight; subagent handles context |

## Implementation Phases

### Phase 1: Add Loop Infrastructure to skill-implementer [COMPLETED]

- **Dependencies:** None
- **Goal:** Insert Stage 6a loop logic after Stage 6 in skill-implementer

**Tasks**:
- [ ] Add loop guard file pattern (`.postflight-loop-guard`)
- [ ] Insert Stage 6a between Stage 6 and Stage 7
- [ ] Implement loop stop condition checks
- [ ] Implement re-invocation with updated context
- [ ] Add per-iteration commit logic

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Add Stage 6a loop section

**Verification**:
- Stage 6a section present between Stage 6 and Stage 7
- Loop guard file mentioned in cleanup (Stage 10)
- Stop conditions cover all cases: implemented, blocked, failed, requires_user_review, iteration_limit

---

### Phase 2: Add Loop Infrastructure to skill-lean-implementation [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Mirror Stage 6a loop logic in skill-lean-implementation

**Tasks**:
- [ ] Copy Stage 6a structure from skill-implementer
- [ ] Adapt for Lean-specific context if needed
- [ ] Ensure consistent behavior with Phase 1

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-lean-implementation/SKILL.md` - Add Stage 6a loop section

**Verification**:
- Stage 6a identical to skill-implementer (minus agent name)
- Loop guard file mentioned in cleanup (Stage 10)

---

### Phase 3: Update implement.md Documentation [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Document auto-resume behavior for users

**Tasks**:
- [ ] Add "Auto-Resume Behavior" section
- [ ] Document stop conditions
- [ ] Document MAX_ITERATIONS configuration
- [ ] Add examples of auto-resume vs blocked scenarios

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/implement.md` - Add auto-resume documentation

**Verification**:
- New section explains auto-resume clearly
- Stop conditions listed
- Configuration method documented

---

### Phase 4: Update Context Delegation for Iterations [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Ensure delegation context includes iteration tracking and handoff path

**Tasks**:
- [ ] Update Stage 4 delegation context in both skills
- [ ] Add `iteration` field to delegation context
- [ ] Add `handoff_path` field when available from partial_progress
- [ ] Update `resume_phase` from partial_progress.phases_completed

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-implementer/SKILL.md` - Update Stage 4
- `.claude/skills/skill-lean-implementation/SKILL.md` - Update Stage 4

**Verification**:
- Delegation context JSON shows iteration, handoff_path, resume_phase fields
- Context passage documented in comments

---

### Phase 5: Testing and Verification [COMPLETED]

- **Dependencies:** Phase 1, Phase 2, Phase 3, Phase 4
- **Goal:** Verify loop behavior through manual inspection and dry-run scenarios

**Tasks**:
- [ ] Review skill files for consistency
- [ ] Verify stop condition coverage
- [ ] Verify cleanup removes loop guard file
- [ ] Verify documentation is complete

**Timing**: 25 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Both skills have identical Stage 6a structure
- All stop conditions enumerated
- Cleanup stage removes `.postflight-loop-guard`
- implement.md documents auto-resume

---

## Testing & Validation

- [ ] Stage 6a present in skill-implementer after Stage 6, before Stage 7
- [ ] Stage 6a present in skill-lean-implementation after Stage 6, before Stage 7
- [ ] Loop guard file (`.postflight-loop-guard`) created at loop start
- [ ] Loop guard file removed in cleanup (Stage 10)
- [ ] Stop conditions: implemented, blocked, failed, requires_user_review=true, iteration_limit
- [ ] Delegation context includes iteration, handoff_path, resume_phase
- [ ] implement.md documents auto-resume behavior

## Artifacts & Outputs

- `.claude/skills/skill-implementer/SKILL.md` (modified)
- `.claude/skills/skill-lean-implementation/SKILL.md` (modified)
- `.claude/commands/implement.md` (modified)
- `specs/886_continuous_subagent_handoff_loop/summaries/implementation-summary-20260217.md` (created on completion)

## Rollback/Contingency

If loop causes issues:
1. Remove Stage 6a sections from both skill files
2. Revert to sequential single-invocation behavior
3. Loop guard file cleanup can be left in place (harmless)

The loop is additive - removing Stage 6a restores original behavior with no other changes needed.
