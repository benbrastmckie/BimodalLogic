# Research Report: Task #638

**Task**: add_roadmap_update_to_todo_command - Extend /todo to update ROAD_MAP.md on archival
**Date**: 2026-01-20
**Effort**: 2-4 hours
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: /todo command, /review command, roadmap-update.md, roadmap-format.md, task 637 artifacts
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- The `/todo` command archives tasks to `specs/archive/` but does not update `ROAD_MAP.md` checkboxes
- The `/review` command already has comprehensive roadmap integration with matching patterns and annotation logic
- The same matching strategy (exact `(Task {N})` refs, title fuzzy match, file path checks) can be reused
- Integration point is Step 5 of /todo (after archive operations, before git commit)
- Completed tasks should mark items `[x]`, abandoned tasks should add annotation noting abandonment

## Context & Scope

### Problem Statement

When tasks are archived via `/todo`, roadmap checkboxes that reference those tasks remain unchecked. This creates inconsistency between:
1. The archive (which correctly records task completion)
2. The roadmap (which shows items as incomplete)

Task 637 manually fixed 10 roadmap checkboxes, demonstrating the gap exists and is fixable.

### Current State Analysis

**`/todo` command** (`.claude/commands/todo.md`):
- Scans for tasks with `status == "completed"` or `status == "abandoned"`
- Moves tasks from `state.json` to `archive/state.json`
- Removes entries from `TODO.md`
- Moves project directories to `specs/archive/`
- Git commits the changes
- **Does NOT touch ROAD_MAP.md**

**`/review` command** (`.claude/commands/review.md`):
- Has Step 2.5 "Roadmap Integration" with full parsing
- Has Step 2.5.2 "Cross-Reference Roadmap with Project State"
- Has Step 2.5.3 "Annotate Completed Roadmap Items"
- Uses Edit tool for checkbox updates
- Safety rules: skip already-annotated, preserve formatting, one edit per item

## Findings

### /review's Roadmap Matching Logic

The `/review` command uses a three-tier matching strategy (from `roadmap-update.md`):

| Match Type | Confidence | Example |
|------------|------------|---------|
| Exact | High (auto-annotate) | Item contains `(Task 628)` |
| Title | Medium (suggest) | Item text "Create API documentation" matches task title |
| File path | Medium (suggest) | Item references `docs/reference/API_REFERENCE.md` which exists |

**Annotation format** (from `roadmap-format.md`):
```markdown
- [x] {item text} *(Completed: Task {N}, {DATE})*
```

### Data Available at Archival Time

When `/todo` archives a task, the following data is available in `state.json`:

```json
{
  "project_number": 637,
  "project_name": "fix_roadmap_checkboxes_not_updated",
  "status": "completed",
  "completed": "2026-01-20T07:18:21Z",
  "artifacts": [...]
}
```

For abandoned tasks:
```json
{
  "status": "abandoned",
  "abandoned": "2026-01-20T00:54:35Z",
  "abandoned_reason": "Research found bridge not required..."
}
```

This provides:
- Task number for exact `(Task {N})` matching
- Task title (via `project_name`) for fuzzy title matching
- Status to distinguish completed vs abandoned
- Completion/abandonment date for annotation

### ROAD_MAP.md Structure

Current structure (726 lines):
- 6 phases with priority markers
- 79 unchecked items (`- [ ]`), 10 checked items (`- [x]`)
- Status tables for proven components
- No explicit `(Task {N})` references (these are added by annotation)

### Integration Point Analysis

The `/todo` command has clear integration points:

**After Step 5.D (Move Project Directories)**:
- All archival operations complete
- Task data still in memory from Step 3 (Prepare Archive List)
- Before git commit (Step 6)

**Proposed New Step: 5.5 "Update Roadmap for Archived Tasks"**

### Matching Strategy for /todo

Since `/todo` operates on batch archival, the matching should be:

1. **Exact match** (Task number in item): Auto-annotate
   - Grep ROAD_MAP.md for `(Task {N})`

2. **Title match** (Task title substring): Auto-annotate if confident
   - For each archived task, search for items containing task title keywords
   - Example: Task "fix_roadmap_checkboxes_not_updated" matches "roadmap checkboxes"

3. **Skip file path matching**: Too slow for batch operations, and /review handles this

### Completed vs Abandoned Handling

**Completed tasks**:
```markdown
- [x] {item} *(Completed: Task {N}, {DATE})*
```

**Abandoned tasks** (two options):

Option A - Mark complete with note:
```markdown
- [x] {item} *(Abandoned: Task {N}, {DATE} - {reason})*
```

Option B - Keep unchecked with note:
```markdown
- [ ] {item} *(Task {N} abandoned: {reason})*
```

**Recommendation**: Option B for abandoned tasks. Abandoned tasks didn't complete the work, so the checkbox should remain unchecked, but a note prevents re-creating the task.

### Safety Considerations

From `/review`'s safety rules (apply to `/todo` as well):
- Skip items already annotated (contain `*(Completed:` or `*(Abandoned:`)
- Preserve existing formatting and indentation
- One edit per item (no batch edits)
- Log skipped items for reporting

### Implementation Complexity

| Component | Complexity | Notes |
|-----------|------------|-------|
| Exact `(Task {N})` matching | Low | Simple grep + edit |
| Title fuzzy matching | Medium | Need word tokenization, substring matching |
| Annotation format | Low | Reuse from roadmap-format.md |
| Batch processing | Medium | Multiple edits in sequence |
| Dry-run support | Low | Add to existing --dry-run flow |

## Recommendations

### 1. Add Step 5.5 to /todo Command

Insert after Step 5.D (or 5.F if orphan/misplaced handling occurs):

```markdown
### 5.5. Update Roadmap for Archived Tasks

**Context**: Load @.claude/context/core/patterns/roadmap-update.md for matching strategy.

For each archived task (completed or abandoned):

**1. Check for exact task references:**
```bash
grep -n "(Task ${task_num})" specs/ROAD_MAP.md
```

**2. If match found, annotate:**
- For completed: `- [x] {item} *(Completed: Task {N}, {DATE})*`
- For abandoned: Keep `- [ ]` but add `*(Task {N} abandoned: {short_reason})*`

**3. Check for title matches (optional, conservative):**
- Tokenize task name: `fix_roadmap_checkboxes_not_updated` -> ["roadmap", "checkboxes"]
- Search for items containing these keywords
- Only auto-annotate if high confidence (multiple keyword match)

**4. Track changes:**
```json
{
  "roadmap_updates": {
    "completed_annotated": 2,
    "abandoned_annotated": 1,
    "skipped_already_annotated": 1
  }
}
```
```

### 2. Extend Dry-Run Output

Add roadmap update preview to Step 4 (Dry Run Output):

```
Roadmap updates:
- [ ] Create API documentation -> [x] *(Completed: Task 637, 2026-01-20)*
- [ ] Fix proof dependencies -> [ ] *(Task 621 abandoned: out of scope)*

Total roadmap items affected: 2
```

### 3. Update Git Commit Message

Extend Step 6 commit format:

```bash
git commit -m "todo: archive {N} tasks, update {M} roadmap items"
```

### 4. Add to Output Report

Extend Step 7 output:

```
Roadmap updated: {N} items
- Marked complete: {N}
- Marked abandoned: {N}
- Skipped (already annotated): {N}
```

## Decisions

1. **Integration point**: After Step 5.D, before git commit (Step 6)
2. **Matching scope**: Exact `(Task {N})` match only for initial implementation; title matching as future enhancement
3. **Abandoned handling**: Keep checkbox unchecked, add abandonment note
4. **Confidence threshold**: Only auto-annotate on exact task number match; title matching requires user confirmation

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| False positive title matches | Medium | Start with exact `(Task {N})` only; add title matching as opt-in |
| Roadmap format changes | Low | Regex patterns from roadmap-format.md are stable |
| Edit conflicts | Low | One edit per item, sequential processing |
| Performance on large roadmaps | Low | ROAD_MAP.md is 726 lines; grep is fast |

## Appendix

### Files Examined

- `/home/benjamin/Projects/ProofChecker/.claude/commands/todo.md` (484 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/commands/review.md` (449 lines)
- `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md` (726 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/patterns/roadmap-update.md` (101 lines)
- `/home/benjamin/Projects/ProofChecker/.claude/context/core/formats/roadmap-format.md` (66 lines)
- `/home/benjamin/Projects/ProofChecker/specs/state.json` (482 lines)
- `/home/benjamin/Projects/ProofChecker/specs/archive/state.json` (100 lines)
- `/home/benjamin/Projects/ProofChecker/specs/637_fix_roadmap_checkboxes_not_updated/` (research, plan, summary)

### Search Patterns Used

```bash
# Count checkboxes in ROAD_MAP.md
grep -c "- \[ \]" specs/ROAD_MAP.md  # 79 unchecked
grep -c "- \[x\]" specs/ROAD_MAP.md  # 10 checked

# Find task references
grep -n "(Task [0-9]*)" specs/ROAD_MAP.md  # 0 explicit refs currently
```

### Related Task: 639

Task 639 "improve_review_roadmap_matching" may enhance the matching logic used by both `/review` and `/todo`. The implementation for task 638 should use a shared matching utility that 639 can later improve.

## Next Steps

Run `/plan 638` to create implementation plan for adding roadmap update capability to the /todo command.
