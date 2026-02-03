# Implementation Plan: Task #834

- **Task**: 834 - Enhance /todo Command with Changelog Updates and Task Suggestions
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: Task 833 (Enhance ROADMAP.md Structure with Changelog, Strategies, and Ambitions)
- **Research Inputs**: specs/834_enhance_todo_command_changelog_task_suggestions/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task extends the /todo command with two new features: (1) automatic Changelog updates when archiving completed tasks, and (2) task suggestion generation at the end of execution. The Changelog feature integrates with the schema defined in Task 833, grouping completed tasks by date and maintaining reverse chronological order. The task suggestion feature analyzes active tasks, ROADMAP.md Ambitions/Strategies, and recent completions to propose 3-5 actionable next steps following the /learn output pattern.

### Research Integration

Key findings from research-001.md:
- Current /todo command structure identified (1188 lines, 7 main sections)
- Step 5.8 location: after Step 5.7 (Sync Repository Metrics), before Step 6 (Git Commit)
- Step 7.5 location: after Step 7 (Output), before Notes section
- Changelog schema: `### YYYY-MM-DD` date headers with `- **Task {N}**: {summary}` entries
- Task suggestion priority: unblocked > stale > ambition > strategy > follow-up > new
- skill-status-sync does NOT need updates (confirmed in research)

## Goals & Non-Goals

**Goals**:
- Add Step 5.8 to update ROAD_MAP.md Changelog section with completed task entries
- Add Step 7.5 to generate and display 3-5 task suggestions
- Update dry-run output to preview Changelog changes
- Update git commit message to include Changelog entry count
- Update final output to show Changelog summary and task suggestions

**Non-Goals**:
- Modifying skill-status-sync (confirmed not needed)
- Adding abandoned tasks to Changelog (only completed tasks)
- Implementing summary-based matching (deferred to future)
- Creating new skills or agents

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Task 833 not complete | High | Medium | Check for Changelog section existence; skip Step 5.8 with warning if missing |
| Edit pattern failures for reverse chronological ordering | Medium | Low | Use unique strings for Edit operations; test with multiple date scenarios |
| ROADMAP.md parsing complexity for Ambitions/Strategies | Medium | Medium | Use simple sed/grep patterns matching Task 833 schema |
| Suggestion output too verbose | Low | Low | Limit to 5 suggestions with prioritization |

## Implementation Phases

### Phase 1: Changelog Integration [COMPLETED]

**Goal**: Add Step 5.8 to update ROAD_MAP.md Changelog section when archiving completed tasks

**Tasks**:
- [ ] Add Step 5.8 section after Step 5.7 in `.claude/commands/todo.md`
- [ ] Implement Step 5.8.1: Filter completed tasks (exclude abandoned)
- [ ] Implement Step 5.8.2: Group completed tasks by completion date (YYYY-MM-DD)
- [ ] Implement Step 5.8.3: Check for Changelog section existence (prerequisite check)
- [ ] Implement Step 5.8.4: For each date, update ROAD_MAP.md using Edit patterns
- [ ] Implement Step 5.8.5: Handle reverse chronological ordering for new date headers
- [ ] Implement Step 5.8.6: Track changes (entries_added, dates_created)
- [ ] Update dry-run output (Step 4) to show Changelog preview
- [ ] Update git commit message (Step 6) to include Changelog entry count

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 5.8 after line ~912, update Steps 4 and 6

**Verification**:
- Step 5.8 appears correctly positioned in todo.md
- Dry-run output shows Changelog preview section
- Git commit message pattern includes `{C} changelog entries`

---

### Phase 2: Task Suggestion Generation [COMPLETED]

**Goal**: Add Step 7.5 to analyze sources and generate 3-5 task suggestions

**Tasks**:
- [ ] Add Step 7.5 section after Step 7 in `.claude/commands/todo.md`
- [ ] Implement Step 7.5.1: Scan active tasks from state.json
- [ ] Implement Step 7.5.2: Identify unblocked tasks (no blockedBy or all deps completed)
- [ ] Implement Step 7.5.3: Identify stale tasks (not_started for >7 days)
- [ ] Implement Step 7.5.4: Parse ROADMAP.md Ambitions section (extract unchecked criteria)
- [ ] Implement Step 7.5.5: Parse ROADMAP.md Strategies section (find ACTIVE with next_steps)
- [ ] Implement Step 7.5.6: Analyze recent completions for follow-up patterns
- [ ] Implement Step 7.5.7: Generate prioritized suggestions (max 5)
- [ ] Implement Step 7.5.8: Format output following /learn pattern

**Timing**: 1.5 hours

**Files to modify**:
- `.claude/commands/todo.md` - Add Step 7.5 after line ~1013

**Verification**:
- Step 7.5 appears correctly positioned in todo.md
- Suggestions output follows the /learn pattern format
- Maximum 5 suggestions are displayed
- Priority ordering is: unblocked > stale > ambition > strategy > follow-up

---

### Phase 3: Edge Cases and Output Updates [COMPLETED]

**Goal**: Handle edge cases and finalize output formatting

**Tasks**:
- [ ] Handle case where Changelog section doesn't exist (graceful skip with warning)
- [ ] Handle case where no completed tasks are being archived (Step 5.8 no-op)
- [ ] Handle case where no suggestions are available ("All looks good!" message)
- [ ] Handle case where Ambitions/Strategies sections don't exist (Task 833 not complete)
- [ ] Update final output (Step 7) to include Changelog summary section
- [ ] Update final output (Step 7) to include Task Suggestions section
- [ ] Add note to Notes section about Changelog and suggestions behavior

**Timing**: 0.5 hours

**Files to modify**:
- `.claude/commands/todo.md` - Update Step 7 output format, add notes

**Verification**:
- No errors when Changelog section is missing
- No errors when zero completed tasks
- "All looks good!" appears when no suggestions
- Final output includes both Changelog and Suggestions sections

## Testing & Validation

- [ ] Verify Step 5.8 position is after Step 5.7 and before Step 6
- [ ] Verify Step 7.5 position is after Step 7 and before Notes
- [ ] Test dry-run output includes Changelog preview
- [ ] Test git commit message format with Changelog count
- [ ] Test final output shows Changelog summary
- [ ] Test final output shows Task Suggestions section
- [ ] Test edge case: missing Changelog section
- [ ] Test edge case: zero completed tasks
- [ ] Test edge case: no available suggestions

## Artifacts & Outputs

- `plans/implementation-001.md` - This plan file
- `.claude/commands/todo.md` - Modified command with Steps 5.8 and 7.5

## Rollback/Contingency

If implementation causes issues:
1. Revert `.claude/commands/todo.md` to previous version using git
2. The command will function without Changelog and suggestion features
3. No data loss risk (only display/annotation features being added)
