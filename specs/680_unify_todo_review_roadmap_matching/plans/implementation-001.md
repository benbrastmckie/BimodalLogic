# Implementation Plan: Task #680

- **Task**: 680 - unify_todo_review_roadmap_matching
- **Status**: [IMPLEMENTING]
- **Effort**: 1.5 hours
- **Priority**: high
- **Dependencies**: Task 639 (completed)
- **Research Inputs**: specs/680_unify_todo_review_roadmap_matching/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Remove the "Unmatched Tasks Warning" from /review command to unify roadmap matching behavior with /todo. Research shows both commands already use identical two-tier matching logic (explicit roadmap_items + exact Task refs), but /review incorrectly warns about unmatched tasks. The warning creates false positives since not all completed tasks update the roadmap. This implementation removes the warning sections from /review and updates documentation to reflect intentional design.

### Research Integration

Research report (research-001.md) confirms:
- Matching logic already unified (lines 173-189 and 303-310 add unnecessary warnings)
- Warning sections exist at specific line ranges in .claude/commands/review.md
- Documentation in roadmap-update.md incorrectly suggests warnings are mandatory
- No code changes needed to /todo (already correct)

## Goals & Non-Goals

**Goals**:
- Remove unmatched tasks warning from /review command
- Update roadmap-update.md to clarify unmatched tasks are expected
- Ensure /review and /todo use identical matching logic
- Verify no other references to unmatched_tasks warnings remain

**Non-Goals**:
- Changing the core matching logic (already correct in both commands)
- Modifying /todo command (no changes needed)
- Adding new roadmap matching features

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Agents forget to populate roadmap_items | Low | Low | Already mitigated by Task 639 agent guidance in all three implementation agents |
| Users expect warning for unmatched tasks | Low | Low | Documentation clarifies this is intentional design (precision over recall) |
| Roadmap becomes stale | Low | Low | /review still shows "Completed Since Last Review" section for visibility |

## Implementation Phases

### Phase 1: Remove Warning from /review [COMPLETED]

**Goal**: Remove unmatched tasks warning sections from /review command

**Tasks**:
- [ ] Read .claude/commands/review.md to locate warning sections
- [ ] Remove lines 173-189 ("Unmatched Tasks Warning" data structure definition)
- [ ] Remove lines 303-310 (report output section for unmatched tasks)
- [ ] Verify matching logic (lines 136-171) remains unchanged
- [ ] Verify annotation process (lines 191-235) remains unchanged
- [ ] Grep for any other references to `unmatched_tasks` in review.md

**Timing**: 0.75 hours

**Files to modify**:
- `.claude/commands/review.md` - Remove warning sections

**Verification**:
- Warning sections removed
- Matching logic intact
- No remaining unmatched_tasks references in review.md

---

### Phase 2: Update Documentation [COMPLETED]

**Goal**: Update roadmap-update.md to reflect correct behavior

**Tasks**:
- [ ] Read .claude/context/core/patterns/roadmap-update.md
- [ ] Remove "Unmatched Tasks" section (lines 40-49)
- [ ] Add note to "Matching Strategy" section: "Not all completed tasks update the roadmap - this is intentional design"
- [ ] Clarify that precision (matching explicitly specified items) takes priority over recall
- [ ] Verify consistency with /review and /todo matching descriptions

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/context/core/patterns/roadmap-update.md` - Update matching documentation

**Verification**:
- Unmatched Tasks section removed
- Documentation reflects intentional design
- Consistent with both /review and /todo implementations

---

### Phase 3: Verification [COMPLETED]

**Goal**: Confirm unification is complete and no warnings remain

**Tasks**:
- [ ] Grep for `unmatched_tasks` across .claude/ directory
- [ ] Grep for "Unmatched Tasks Warning" across .claude/ directory
- [ ] Verify matching strategy documented identically in /review and /todo
- [ ] Confirm roadmap-update.md accurately reflects implementation
- [ ] Check that Task 639 agent guidance still exists in implementation agents

**Timing**: 0.25 hours

**Files to verify**:
- `.claude/commands/review.md` - No warning references
- `.claude/commands/todo.md` - Unchanged (correct baseline)
- `.claude/context/core/patterns/roadmap-update.md` - Updated documentation
- `.claude/agents/general-implementation-agent.md` - Task 639 guidance intact
- `.claude/agents/lean-implementation-agent.md` - Task 639 guidance intact
- `.claude/agents/latex-implementation-agent.md` - Task 639 guidance intact

**Verification**:
- No unmatched_tasks warnings found in .claude/
- Both commands use identical matching logic
- Documentation is consistent
- Agent guidance for roadmap_items remains

## Testing & Validation

- [ ] /review command no longer outputs unmatched tasks warning
- [ ] /review and /todo both use two-tier matching (explicit roadmap_items, exact Task refs)
- [ ] Documentation clearly states unmatched tasks are expected
- [ ] No grep matches for "unmatched_tasks" warnings in .claude/

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md
- Modified: .claude/commands/review.md
- Modified: .claude/context/core/patterns/roadmap-update.md

## Rollback/Contingency

If changes cause issues:
1. Revert commits for this task using git
2. Restore original warning sections to /review
3. Restore original roadmap-update.md content
4. Task 639 agent guidance remains in place (independent of warning removal)
