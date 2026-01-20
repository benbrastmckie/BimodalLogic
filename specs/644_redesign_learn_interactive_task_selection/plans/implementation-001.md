# Implementation Plan: Task #644

- **Task**: 644 - Redesign /learn command to use interactive task selection
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/644_redesign_learn_interactive_task_selection/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Redesign the /learn command to use interactive task selection instead of auto-creating tasks. The current implementation delegates to learn-agent via the Task tool, which scans for tags and creates tasks without user confirmation (except with --dry-run preview). The new design executes tag extraction directly in skill-learn (synchronously, no subagent), presents findings to the user, then uses AskUserQuestion for interactive selection of which task types to create.

### Research Integration

Research report (research-001.md) provided:
- AskUserQuestion tool supports both single-select and multi-select modes with labels and descriptions
- skill-refresh demonstrates the direct execution pattern with AskUserQuestion
- Recommended two-stage selection: task types first, then individual TODOs if selected
- Tag extraction patterns identified for all supported file types

## Goals & Non-Goals

**Goals**:
- Users always see scan results before any tasks are created
- Users select which task types to create (fix-it, learn-it, TODO tasks)
- Users can optionally select individual TODO items for task creation
- Run synchronously without subagent delegation
- Preserve existing tag extraction logic and task creation format
- Maintain git commit postflight behavior

**Non-Goals**:
- Changing the format of created tasks
- Modifying how tags are detected in source files
- Adding new tag types
- Changing the TODO.md/state.json update logic

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| AskUserQuestion UI limitations with many TODO items (>20) | Medium | Medium | Implement pagination or "Select all" option |
| Grep tool behavior differs from bash grep patterns | Low | Low | Use Bash tool with grep for consistency with current patterns |
| Breaking change removes --dry-run flag | Low | Low | Document that new flow is inherently interactive |
| Token overhead with inline tag extraction | Medium | Low | Keep extraction concise; structured processing |

## Implementation Phases

### Phase 1: Convert skill-learn to direct execution [COMPLETED]

**Goal**: Remove subagent delegation and implement tag extraction directly in skill-learn

**Tasks**:
- [ ] Update skill-learn SKILL.md frontmatter: change allowed-tools from `Task, Bash, Edit, Read, Write` to `Bash, Grep, Read, Write, Edit, AskUserQuestion`
- [ ] Remove thin wrapper pattern documentation and replace with direct execution pattern
- [ ] Remove Task tool invocation and delegation context preparation sections
- [ ] Add inline tag extraction logic using Grep/Bash patterns from learn-agent
- [ ] Implement tag categorization (fix_tags, note_tags, todo_tags arrays)
- [ ] Add display of tag summary before any selection prompts

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Major rewrite from delegation to direct execution

**Verification**:
- Skill frontmatter lists correct tools (Bash, Grep, Read, Write, Edit, AskUserQuestion)
- No references to Task tool or learn-agent
- Tag extraction logic is present inline

---

### Phase 2: Implement interactive selection flow [COMPLETED]

**Goal**: Add two-stage AskUserQuestion prompts for task type and TODO item selection

**Tasks**:
- [ ] Add task type selection prompt (multiSelect: true) for fix-it, learn-it, TODO tasks
- [ ] Add conditional TODO item selection prompt (multiSelect: true) when TODO tasks selected
- [ ] Handle edge cases: no tags found, only one tag type exists
- [ ] Implement selection result handling to determine which tasks to create
- [ ] Add handling for >20 TODO items (offer "Select all" option)

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Add AskUserQuestion prompts and handling

**Verification**:
- AskUserQuestion prompts appear after tag summary
- Multi-select works for task types
- Individual TODO selection appears only when "TODO tasks" is selected
- Edge cases handled gracefully

---

### Phase 3: Implement task creation and postflight [COMPLETED]

**Goal**: Create selected tasks and maintain git commit behavior

**Tasks**:
- [ ] Port task creation logic from learn-agent (state.json and TODO.md updates)
- [ ] Create fix-it task only if selected and FIX:/NOTE: tags exist
- [ ] Create learn-it task only if selected and NOTE: tags exist
- [ ] Create todo-tasks only for selected TODO items
- [ ] Implement git commit postflight (unchanged from current)
- [ ] Add result display showing created tasks

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Add task creation and postflight

**Verification**:
- Selected tasks are created in state.json and TODO.md
- Unselected tasks are not created
- Git commit includes session ID and task count
- Result summary shows created task numbers

---

### Phase 4: Update command and remove agent [COMPLETED]

**Goal**: Update command documentation and remove deprecated learn-agent

**Tasks**:
- [ ] Update learn.md command: remove --dry-run documentation
- [ ] Update learn.md: rewrite execution section for interactive flow
- [ ] Update learn.md: revise output examples to show interactive prompts
- [ ] Update learn.md: remove confirmation flow section (replaced by interactive selection)
- [ ] Delete learn-agent.md (agent no longer needed)
- [ ] Update CLAUDE.md Skill-to-Agent Mapping table (remove skill-learn -> learn-agent row)

**Timing**: 30 minutes

**Files to modify**:
- `.claude/commands/learn.md` - Rewrite for interactive flow
- `.claude/agents/learn-agent.md` - DELETE
- `.claude/CLAUDE.md` - Update Skill-to-Agent Mapping table

**Verification**:
- learn.md documents interactive flow without --dry-run
- learn-agent.md is deleted
- CLAUDE.md shows skill-learn as (direct execution) in mapping table

---

### Phase 5: Testing and edge cases [COMPLETED]

**Goal**: Verify the redesign works correctly across all scenarios

**Tasks**:
- [ ] Test with no tags found (should exit gracefully with message)
- [ ] Test with only FIX: tags (should offer only fix-it task type)
- [ ] Test with only NOTE: tags (should offer fix-it and learn-it)
- [ ] Test with only TODO: tags (should offer TODO tasks with item selection)
- [ ] Test with all tag types present
- [ ] Test selecting no task types (should exit without creating tasks)
- [ ] Test with >20 TODO items (verify "Select all" behavior)
- [ ] Verify git commit message format matches current pattern

**Timing**: 30 minutes

**Files to modify**:
- None (testing only)

**Verification**:
- All test scenarios pass
- No regressions from current behavior (except --dry-run removal)
- Interactive flow is intuitive and consistent

---

## Testing & Validation

- [ ] Run /learn on test files with various tag combinations
- [ ] Verify AskUserQuestion prompts display correctly
- [ ] Confirm task selection works (single and multi-select)
- [ ] Verify created tasks appear in TODO.md and state.json
- [ ] Check git commit includes correct session ID and count
- [ ] Test edge case: no tags found
- [ ] Test edge case: user selects no task types
- [ ] Test large number of TODO items (>20)

## Artifacts & Outputs

- `.claude/skills/skill-learn/SKILL.md` - Rewritten for direct execution with AskUserQuestion
- `.claude/commands/learn.md` - Updated documentation for interactive flow
- `.claude/CLAUDE.md` - Updated Skill-to-Agent Mapping table
- (deleted) `.claude/agents/learn-agent.md`
- `specs/644_redesign_learn_interactive_task_selection/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If the redesign causes issues:
1. Restore learn-agent.md from git history
2. Revert skill-learn/SKILL.md to delegation pattern
3. Revert learn.md to include --dry-run documentation
4. Revert CLAUDE.md Skill-to-Agent table entry

All changes are contained within the .claude/ directory and are easily reversible via git.
