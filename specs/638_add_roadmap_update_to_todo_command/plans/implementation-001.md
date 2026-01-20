# Implementation Plan: Task #638

- **Task**: 638 - add_roadmap_update_to_todo_command
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/638_add_roadmap_update_to_todo_command/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Extend the `/todo` command to update ROAD_MAP.md checkboxes when archiving completed or abandoned tasks. The implementation adds a new Step 5.5 after archive operations but before git commit. This step searches ROAD_MAP.md for exact `(Task {N})` references and annotates matching items based on task status. Completed tasks mark items as checked with completion date; abandoned tasks add an abandonment note while keeping items unchecked.

### Research Integration

Key findings from research-001.md:
- Integration point identified as Step 5.5 (after archive operations, before git commit)
- Exact `(Task {N})` matching is safest for initial implementation; title matching deferred to future enhancement
- Annotation format follows roadmap-format.md conventions
- Completed and abandoned tasks require different treatments

## Goals & Non-Goals

**Goals**:
- Add roadmap update capability to /todo command
- Support exact `(Task {N})` reference matching
- Mark completed task items as checked with annotation
- Mark abandoned task items with abandonment note (keep unchecked)
- Integrate with existing dry-run output
- Update git commit messages to reflect roadmap changes

**Non-Goals**:
- Title fuzzy matching (future enhancement, per task 639)
- File path existence matching (handled by /review)
- Interactive confirmation for each roadmap item (batch only)
- Modifying /review command (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| False positives on matching | Medium | Low | Start with exact `(Task {N})` only, no fuzzy matching |
| Edit conflicts with concurrent changes | Low | Low | Sequential single-item edits, git commit preserves |
| ROAD_MAP.md format changes | Low | Low | Regex patterns from roadmap-format.md are stable |
| Performance on batch archival | Low | Low | Grep is fast; ROAD_MAP.md is ~730 lines |

## Implementation Phases

### Phase 1: Add Roadmap Tracking Infrastructure [NOT STARTED]

**Goal**: Add tracking data structures and helper logic for roadmap updates.

**Tasks**:
- [ ] Add Step 3.5 to collect task-to-roadmap matching data
- [ ] Define tracking structure for roadmap updates
- [ ] Add variables for counting roadmap changes

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 3.5 after "Prepare Archive List"

**Details**:

After Step 3, add Step 3.5 to scan ROAD_MAP.md for task references:

```markdown
### 3.5. Scan Roadmap for Task References

For each archivable task, check if ROAD_MAP.md contains `(Task {N})` references:

```bash
# Initialize roadmap tracking
roadmap_matches=()
for task in "${archivable_tasks[@]}"; do
  project_num=$(echo "$task" | jq -r '.project_number')
  status=$(echo "$task" | jq -r '.status')

  # Search for exact task reference
  matches=$(grep -n "(Task ${project_num})" specs/ROAD_MAP.md 2>/dev/null || true)

  if [ -n "$matches" ]; then
    roadmap_matches+=("${project_num}:${status}:${matches}")
  fi
done
```

Track:
- `roadmap_matches[]` - Array of task:status:line_info tuples
- `roadmap_completed_count` - Count of completed task matches
- `roadmap_abandoned_count` - Count of abandoned task matches
```

**Verification**:
- Step 3.5 documented in todo.md
- Tracking variables defined

---

### Phase 2: Update Dry-Run Output [NOT STARTED]

**Goal**: Show roadmap changes in dry-run preview.

**Tasks**:
- [ ] Add roadmap updates section to dry-run output (Step 4)
- [ ] Show preview of checkbox changes for each matched item

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 4 (Dry Run Output)

**Details**:

Extend the dry-run output template in Step 4:

```markdown
### 4. Dry Run Output (if --dry-run)

```
Tasks to archive:
...existing content...

Roadmap updates:
- [ ] {item text} (line {N}) -> [x] *(Completed: Task {N}, {DATE})*
- [ ] {item text} (line {N}) -> [ ] *(Task {N} abandoned: {reason})*

Total roadmap items to update: {N}
- Completed: {N}
- Abandoned: {N}

...rest of output...
```
```

**Verification**:
- Dry-run output includes roadmap preview
- Preview shows both completed and abandoned treatments

---

### Phase 3: Implement Roadmap Update Step [NOT STARTED]

**Goal**: Add Step 5.5 to perform actual roadmap updates.

**Tasks**:
- [ ] Add Step 5.5 after Step 5.F (Misplaced Directories)
- [ ] Implement exact `(Task {N})` matching with grep
- [ ] Implement annotation for completed tasks
- [ ] Implement annotation for abandoned tasks
- [ ] Add skip logic for already-annotated items

**Timing**: 45 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 5.5

**Details**:

Add new step between 5.F and 6:

```markdown
### 5.5. Update Roadmap for Archived Tasks

**Context**: Load @.claude/context/core/patterns/roadmap-update.md for matching strategy.

For each archived task with roadmap matches (from Step 3.5):

**1. Read current ROAD_MAP.md content**

**2. For each match, determine if already annotated**:
```bash
# Skip if already has completion or abandonment annotation
if echo "$line_content" | grep -q '\*(Completed:\|*(Abandoned:\|*(Task .* abandoned:'; then
  echo "Skipped: Line $line_num already annotated"
  ((roadmap_skipped++))
  continue
fi
```

**3. Apply appropriate annotation**:

For completed tasks:
```
Edit old_string: "- [ ] {item_text} (Task {N})"
     new_string: "- [x] {item_text} (Task {N}) *(Completed: Task {N}, {DATE})*"
```

For abandoned tasks:
```
Edit old_string: "- [ ] {item_text} (Task {N})"
     new_string: "- [ ] {item_text} (Task {N}) *(Task {N} abandoned: {short_reason})*"
```

**4. Track changes**:
```json
{
  "roadmap_updates": {
    "completed_annotated": 2,
    "abandoned_annotated": 1,
    "skipped_already_annotated": 1
  }
}
```

**Safety Rules** (from roadmap-update.md):
- Skip items already containing `*(Completed:` or `*(Task` annotations
- Preserve existing formatting and indentation
- One edit per item (no batch edits to same line)
- Never remove existing content
```

**Verification**:
- Step 5.5 documented with full logic
- Skip logic prevents double-annotation
- Both completed and abandoned paths covered

---

### Phase 4: Update Git Commit Message [NOT STARTED]

**Goal**: Include roadmap update count in commit message.

**Tasks**:
- [ ] Update Step 6 commit message format
- [ ] Add conditional for roadmap update count

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 6 (Git Commit)

**Details**:

Extend commit message patterns in Step 6:

```markdown
### 6. Git Commit

...existing content...

Include roadmap update count in message as applicable:
```bash
# If roadmap items updated, orphans tracked, and misplaced moved:
git commit -m "todo: archive {N} tasks, update {R} roadmap items, track {M} orphans, move {P} misplaced"

# If roadmap items updated only:
git commit -m "todo: archive {N} tasks, update {R} roadmap items"

# If roadmap items updated and orphans tracked:
git commit -m "todo: archive {N} tasks, update {R} roadmap items, track {M} orphaned directories"
```
```

**Verification**:
- Commit message includes roadmap count when applicable
- Multiple conditional patterns documented

---

### Phase 5: Update Output Report [NOT STARTED]

**Goal**: Show roadmap changes in final output.

**Tasks**:
- [ ] Add roadmap updates section to Step 7 output
- [ ] Show breakdown of completed vs abandoned annotations

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 7 (Output)

**Details**:

Extend output template in Step 7:

```markdown
### 7. Output

```
Archived {N} tasks:
...existing content...

Roadmap updated: {N} items
- Marked complete: {N}
  - {item text} (line {N})
- Marked abandoned: {N}
  - {item text} (line {N})
- Skipped (already annotated): {N}

...rest of output...
```

If no roadmap items were updated:
- Omit the "Roadmap updated" section
```

**Verification**:
- Output includes roadmap section when changes made
- Breakdown shows completed vs abandoned

---

### Phase 6: Documentation and Notes [NOT STARTED]

**Goal**: Add notes section documenting roadmap integration.

**Tasks**:
- [ ] Add roadmap update notes to Notes section
- [ ] Document annotation formats
- [ ] Document matching strategy and limitations

**Timing**: 15 minutes

**Files to modify**:
- `.claude/commands/todo.md` - Update Notes section

**Details**:

Add new subsection to Notes:

```markdown
### Roadmap Updates

**Matching Strategy**:
- Current implementation uses exact `(Task {N})` matching only
- Title fuzzy matching planned for future enhancement (task 639)
- File path matching not performed (handled by /review)

**Annotation Formats**:

Completed tasks:
```markdown
- [x] {item text} (Task {N}) *(Completed: Task {N}, {DATE})*
```

Abandoned tasks (checkbox stays unchecked):
```markdown
- [ ] {item text} (Task {N}) *(Task {N} abandoned: {short_reason})*
```

**Safety Rules**:
- Skip items already annotated (contain `*(Completed:` or `*(Task` patterns)
- Preserve existing formatting and indentation
- One edit per item
- Never remove existing content

**Date Format**: ISO date (YYYY-MM-DD) from task completion/abandonment timestamp

**Abandoned Reason**: Truncated to first 50 characters of `abandoned_reason` field
```

**Verification**:
- Notes section documents all roadmap update behavior
- Annotation formats clearly specified
- Matching limitations noted

## Testing & Validation

- [ ] Create test task with `(Task 638)` reference in ROAD_MAP.md
- [ ] Run `/todo --dry-run` and verify roadmap preview section appears
- [ ] Run `/todo` and verify checkbox updated correctly
- [ ] Verify already-annotated items are skipped
- [ ] Verify abandoned task annotation format (checkbox stays unchecked)
- [ ] Verify git commit message includes roadmap count

## Artifacts & Outputs

- `specs/638_add_roadmap_update_to_todo_command/plans/implementation-001.md` (this file)
- `.claude/commands/todo.md` (modified)
- `specs/638_add_roadmap_update_to_todo_command/summaries/implementation-summary-{DATE}.md` (on completion)

## Rollback/Contingency

If implementation causes issues:
1. Revert changes to `.claude/commands/todo.md` via git
2. Roadmap changes are idempotent (re-running with fix won't corrupt)
3. Manual annotation removal: search for `*(Completed: Task 638` pattern
