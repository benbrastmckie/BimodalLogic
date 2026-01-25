# Research Report: Task #680

**Task**: 680 - unify_todo_review_roadmap_matching
**Started**: 2026-01-25T21:24:37Z
**Completed**: 2026-01-25T21:30:00Z
**Effort**: 30 minutes
**Priority**: high
**Dependencies**: Task 639 (completed)
**Sources/Inputs**:
- .claude/commands/review.md
- .claude/commands/todo.md
- .claude/context/core/patterns/roadmap-update.md
- specs/639_improve_review_roadmap_matching/summaries/implementation-summary-20260125.md
- specs/639_improve_review_roadmap_matching/plans/implementation-002.md
**Artifacts**: specs/680_unify_todo_review_roadmap_matching/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Task 639 implemented two-tier roadmap matching in /review but added "Unmatched Tasks Warning" section
- /todo command already has identical two-tier matching logic (explicit roadmap_items + exact Task refs)
- Key difference: /review includes warning for unmatched tasks, /todo does not (and should not)
- Unification requires: (1) Remove warning from /review, (2) Confirm matching logic is identical
- Both commands already use the same matching strategy from roadmap-update.md

## Context & Scope

This follow-up to Task 639 addresses two related issues:
1. The "Unmatched Tasks Warning" in /review should be removed - completed tasks without roadmap items are not an error condition
2. Ensure /todo and /review use identical matching logic for consistency

Task 639 (completed 2026-01-25) implemented explicit two-tier roadmap matching in /review, removing unreliable fuzzy matching. The implementation correctly unified the matching strategy with /todo, but added an unnecessary warning section.

## Findings

### 1. Current /review Implementation (After Task 639)

**Location**: `.claude/commands/review.md`, Step 2.5.2

**Matching Strategy** (lines 136-171):
- Priority 1: Explicit `roadmap_items` array match (exact text in ROAD_MAP.md checkboxes)
- Priority 2: Exact `(Task {N})` reference in ROAD_MAP.md
- No fuzzy matching

**Unmatched Tasks Warning** (lines 173-189):
```markdown
**Unmatched Tasks Warning:**

Track tasks that could not be matched to any roadmap item:
```json
{
  "unmatched_tasks": [
    {
      "task_number": 630,
      "task_name": "refactor_kripke_frames",
      "reason": "No roadmap_items specified, no (Task 630) reference in ROAD_MAP.md"
    }
  ],
  "warning": "3 completed tasks have no roadmap item match. Consider adding roadmap_items during implementation."
}
```

Include unmatched tasks in the review report under a dedicated warning section.
```

**Report Output Section** (lines 303-310):
```markdown
### Unmatched Completed Tasks

> **Warning**: The following completed tasks have no roadmap item match.
> Consider adding `roadmap_items` during implementation for future tasks.

| Task | Name | Reason |
|------|------|--------|
| {N} | {task_name} | No roadmap_items, no (Task N) ref |
```

### 2. Current /todo Implementation

**Location**: `.claude/commands/todo.md`, Step 3.5

**Matching Strategy** (lines 176-233):
- Step 3.5.1: Separates meta and non-meta tasks
- Step 3.5.2: Extracts completed non-meta tasks with `roadmap_items`
- Step 3.5.3: Matches using identical two-tier pattern:
  - Priority 1: Explicit roadmap_items (lines 190-206)
  - Priority 2: Exact (Task N) reference (lines 208-222)
  - Priority 3: Summary-based search (commented as "optional enhancement", lines 224-232)

**No Warning for Unmatched Tasks**: /todo does not include any warning or reporting for tasks that don't match roadmap items. This is intentional - not all completed tasks need to update the roadmap.

**Output Section** (lines 897-902):
```markdown
Roadmap updated: {N} items
- Marked complete: {N}
  - {item text} (line {N})
- Marked abandoned: {N}
  - {item text} (line {N})
- Skipped (already annotated): {N}
```

No section for unmatched tasks.

### 3. Documentation in roadmap-update.md

**Location**: `.claude/context/core/patterns/roadmap-update.md`

**Matching Strategy** (lines 24-39):
- Priority 1: Explicit roadmap_items (exact string comparison)
- Priority 2: Exact Task References (regex pattern)
- Explicitly states: "No fuzzy title matching is performed"
- Rationale: "Explicit items ensure precision over recall"

**Unmatched Tasks Section** (lines 40-49):
```markdown
### Unmatched Tasks

Tasks that don't match any roadmap item are:
- Reported in the review report under "Unmatched Completed Tasks"
- Included in summary output with warning message
- NOT automatically annotated anywhere

To fix unmatched tasks:
1. Add `(Task N)` annotation to relevant ROAD_MAP.md item, OR
2. For future tasks, populate `roadmap_items` during implementation
```

This documentation claims unmatched tasks are "Reported in the review report" but does not mandate this behavior for /todo.

### 4. Differences Identified

| Aspect | /review | /todo | Unified? |
|--------|---------|-------|----------|
| Priority 1: Explicit roadmap_items | ✓ | ✓ | ✅ Yes |
| Priority 2: Exact (Task N) refs | ✓ | ✓ | ✅ Yes |
| Fuzzy matching | ✗ Removed | ✗ Never implemented | ✅ Yes |
| Unmatched tasks warning | ✓ Lines 173-189 | ✗ Not present | ❌ **No** |
| Report output for unmatched | ✓ Lines 303-310 | ✗ Not present | ❌ **No** |

**Core Logic**: ✅ Already unified (both use identical two-tier matching)
**Warning Behavior**: ❌ Differs (/review warns, /todo does not)

### 5. Why the Warning Should Be Removed from /review

**Rationale**:
1. **Not all completed tasks update the roadmap**: Some tasks are internal refactors, bug fixes, or meta work that don't correspond to roadmap items
2. **Warning creates false positives**: Completed tasks without roadmap items are not an error - they're expected for many task types
3. **Inconsistency with /todo**: The archival command does not warn about unmatched tasks, implying this is acceptable
4. **Agents already have guidance**: Task 639 added roadmap_items guidance to all three implementation agents (general, lean, latex)
5. **Explicit is better than implicit**: If a task should update the roadmap, the agent should populate `roadmap_items` explicitly

**Design Philosophy**: The two-tier matching system is about **precision** (only match when explicitly specified), not **recall** (match as many as possible). A task with no roadmap match is not a warning condition - it's working as designed.

### 6. Location of Warning in /review

**Lines to remove**:
- Lines 173-189: "Unmatched Tasks Warning" data structure definition
- Lines 303-310: Report output section for unmatched tasks

**Lines to keep**:
- Lines 136-171: Matching strategy and process (core logic)
- Lines 191-235: Annotation process (unchanged)

## Decisions

1. **Remove unmatched tasks warning from /review**: Delete lines 173-189 and 303-310
2. **Keep matching logic unchanged**: Both commands already use identical two-tier pattern
3. **Update roadmap-update.md**: Remove references to "Unmatched Tasks" warning being mandatory
4. **No changes to /todo**: Already correct (no warning)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Agents forget to populate roadmap_items | Low | Already mitigated by Task 639 agent guidance |
| Users expect warning for unmatched tasks | Low | Documentation clarifies this is intentional design |
| Roadmap becomes stale | Low | /review still shows "Completed Since Last Review" section |

## Recommendations

### Implementation Plan (2 phases, ~1.5 hours)

**Phase 1: Remove Warning from /review** (~1 hour)
1. Edit `.claude/commands/review.md`:
   - Remove lines 173-189 ("Unmatched Tasks Warning" data structure)
   - Remove lines 303-310 (report output section)
   - Keep all matching logic (lines 136-171)
   - Keep annotation process (lines 191-235)

2. Verify no other references to `unmatched_tasks` in /review command

**Phase 2: Update Documentation** (~0.5 hours)
1. Edit `.claude/context/core/patterns/roadmap-update.md`:
   - Remove "Unmatched Tasks" section (lines 40-49)
   - Update "Matching Strategy" section to clarify unmatched tasks are expected
   - Add note: "Not all completed tasks update the roadmap - this is intentional"

2. Verify consistency between /review, /todo, and roadmap-update.md

**Verification**:
- Grep for `unmatched_tasks` across .claude/ directory (should only appear in /todo if at all)
- Verify matching strategy documented identically in both commands
- Confirm roadmap-update.md reflects actual implementation

### Expected Outcome

After implementation:
- /review and /todo use identical two-tier matching (explicit roadmap_items + exact Task refs)
- No warnings for unmatched tasks in either command
- Documentation accurately reflects implementation
- Agents continue to populate roadmap_items when appropriate (Task 639 guidance)

## Appendix

### Search Queries Used
- `grep -r "unmatched tasks" .claude/commands/`
- `grep -r "Unmatched Tasks Warning" .claude/commands/`
- `grep -n "roadmap_items" .claude/commands/review.md`
- `grep -n "roadmap_items" .claude/commands/todo.md`

### Files Analyzed
1. `.claude/commands/review.md` - /review command implementation
2. `.claude/commands/todo.md` - /todo command implementation
3. `.claude/context/core/patterns/roadmap-update.md` - Matching strategy documentation
4. `specs/639_improve_review_roadmap_matching/summaries/implementation-summary-20260125.md` - Task 639 changes
5. `specs/639_improve_review_roadmap_matching/plans/implementation-002.md` - Task 639 plan

### Key Finding Summary

**Matching logic is already unified** ✅
- Both commands use identical two-tier pattern (explicit roadmap_items, then exact Task refs)
- Both exclude fuzzy matching
- Both documented in roadmap-update.md

**Warning behavior differs** ❌
- /review includes "Unmatched Tasks Warning" (added in Task 639)
- /todo has no warning for unmatched tasks (intentional design)
- Warning should be removed from /review for consistency and correctness
