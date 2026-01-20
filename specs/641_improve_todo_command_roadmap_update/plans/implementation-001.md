# Implementation Plan: Task #641

- **Task**: 641 - improve_todo_command_roadmap_update
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None (builds on task 638)
- **Research Inputs**:
  - specs/641_improve_todo_command_roadmap_update/reports/research-001.md
  - specs/641_improve_todo_command_roadmap_update/reports/research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The `/todo` command's roadmap update feature (implemented in task 638) uses exact `(Task {N})` matching, but ROAD_MAP.md contains zero such references. This renders the feature useless. The solution is to add title keyword matching as a fallback strategy, enabling the command to find and annotate roadmap items that semantically correspond to completed/abandoned tasks.

### Research Integration

From research-001.md:
- Confirmed order of operations is correct (roadmap scan happens before archival)
- Root cause: ROAD_MAP.md has 0 `(Task N)` references, so exact matching never finds anything
- Task 639 was intended to add fuzzy matching but was never implemented

From research-002.md:
- `/revise` command has no roadmap issues (correctly scoped)
- Opportunity exists to create shared matching pattern for `/todo` and `/review`
- Recommended Option A: Extend task 641 to implement title keyword matching

## Goals & Non-Goals

**Goals**:
- Add title keyword matching as fallback when exact `(Task {N})` matching fails
- Filter out common words to reduce false positives
- Require minimum 2 keyword matches for confidence
- Integrate keyword matching into existing Step 3.5 and Step 5.5 of `/todo` command
- Update dry-run output to show proposed keyword matches
- Update documentation to reflect new matching strategy

**Non-Goals**:
- Creating a separate shared matching utility (deferred to task 639)
- Modifying `/review` command matching (separate task scope)
- Adding explicit `roadmap_items` field to state.json (task 639 scope)
- User confirmation for medium-confidence matches (keep behavior simple)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| False positive keyword matches | Medium | Medium | Require 2+ keyword matches, exclude common words |
| Over-annotation of roadmap | Low | Low | Skip already-annotated items, exact match takes priority |
| Performance on large roadmaps | Low | Low | ROAD_MAP.md is ~730 lines, keyword matching is fast |
| Task name keywords too generic | Medium | Medium | Comprehensive common word exclusion list |

## Implementation Phases

### Phase 1: Update Step 3.5 with Keyword Matching [NOT STARTED]

**Goal**: Extend the roadmap scanning step to include title keyword matching as a fallback.

**Tasks**:
- [ ] Define common word exclusion list (fix, add, update, implement, improve, create, remove, the, a, to, in, for, of, with, and, or, is, as, on, by, at, from)
- [ ] Add keyword extraction function that tokenizes `project_name` (snake_case to words)
- [ ] Add keyword matching loop that searches unchecked roadmap items
- [ ] Track both exact matches and keyword matches separately
- [ ] Require minimum 2 non-common keyword matches for confidence

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Step 3.5 section (lines ~134-166)

**Verification**:
- Dry-run output shows keyword matches when exact matches fail
- Common words are properly filtered
- Keyword matches are tracked separately from exact matches

---

### Phase 2: Update Step 5.5 with Keyword Match Annotation [NOT STARTED]

**Goal**: Apply roadmap annotations for keyword-matched items.

**Tasks**:
- [ ] Update annotation logic to handle both exact and keyword matches
- [ ] For keyword matches, include match confidence in annotation (e.g., "via keywords: roadmap, update")
- [ ] Ensure keyword matches don't overwrite existing annotations
- [ ] Apply same annotation format as exact matches (completed/abandoned)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Step 5.5 section (lines ~411-457)

**Verification**:
- Keyword-matched items are correctly annotated
- Annotation includes which keywords matched
- Already-annotated items are skipped

---

### Phase 3: Update Dry-Run Output [NOT STARTED]

**Goal**: Show keyword matches distinctly in dry-run mode.

**Tasks**:
- [ ] Add "Keyword matches" subsection to roadmap updates output
- [ ] Show which keywords matched for each item
- [ ] Distinguish between exact matches and keyword matches in counts
- [ ] Update total counts to include both match types

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Step 4 section (lines ~167-208)

**Verification**:
- Dry-run shows keyword matches with matched keywords
- Counts accurately reflect both match types
- Output is clear and distinguishable

---

### Phase 4: Update Command Output [NOT STARTED]

**Goal**: Update final output to reflect keyword match results.

**Tasks**:
- [ ] Add keyword match results to "Roadmap updated" section
- [ ] Show matched keywords for transparency
- [ ] Update git commit message to reflect keyword matches

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Steps 6-7 (lines ~465-544)

**Verification**:
- Final output distinguishes exact vs keyword matches
- Git commit message reflects roadmap update method

---

### Phase 5: Update Documentation [NOT STARTED]

**Goal**: Update notes and documentation to reflect new matching strategy.

**Tasks**:
- [ ] Update "Roadmap Updates" notes section with keyword matching details
- [ ] Document common word exclusion list
- [ ] Document minimum keyword match threshold
- [ ] Add examples of keyword matching behavior
- [ ] Note that task 639 will add explicit mapping (future enhancement)

**Timing**: 25 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Notes section (lines ~603-631)

**Verification**:
- Documentation accurately describes both matching strategies
- Common word list is documented
- Minimum threshold is documented

---

### Phase 6: Verification and Testing [NOT STARTED]

**Goal**: Verify the implementation works correctly end-to-end.

**Tasks**:
- [ ] Run `/todo --dry-run` to verify keyword matching detects items
- [ ] Verify common words are filtered correctly
- [ ] Verify 2+ keyword requirement is enforced
- [ ] Test with actual archivable task to confirm annotation
- [ ] Verify no regressions in existing exact match behavior

**Timing**: 30 minutes

**Files to modify**:
- None (verification only)

**Verification**:
- Dry-run shows keyword matches for archivable tasks
- No false positives on single-keyword items
- Existing exact match behavior unchanged

## Testing & Validation

- [ ] `/todo --dry-run` shows keyword matches when exact matches fail
- [ ] Common words are properly excluded from keyword matching
- [ ] Minimum 2 keyword threshold is enforced
- [ ] Annotation format includes matched keywords for transparency
- [ ] Already-annotated items are skipped
- [ ] Git commit message reflects matching method used

## Artifacts & Outputs

- `.claude/commands/todo.md` - Updated command with keyword matching
- `specs/641_improve_todo_command_roadmap_update/summaries/implementation-summary-{DATE}.md` - Completion summary

## Rollback/Contingency

If keyword matching produces too many false positives:
1. Increase minimum keyword threshold from 2 to 3
2. Expand common word exclusion list
3. As last resort, disable keyword matching and revert to exact-only (with documentation update)

The changes are isolated to `/todo` command and can be rolled back by reverting the single file.
