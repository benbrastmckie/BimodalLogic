# Implementation Plan: Task #649

- **Task**: 649 - Improve /learn NOTE: tag dependency handling
- **Status**: [COMPLETED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: specs/649_improve_learn_note_tag_dependency_handling/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This implementation improves the `/learn` command to establish a dependency relationship between learn-it and fix-it tasks when NOTE: tags are present. Currently, when both task types are selected, they are created independently. After this change, the fix-it task will depend on the learn-it task, ensuring proper ordering: learn-it extracts knowledge to context files and converts NOTE: to FIX:, then fix-it addresses the remaining code changes.

### Research Integration

The research report (research-001.md) identified the specific code locations in SKILL.md requiring modification and documented the existing dependency format in state.json and TODO.md.

## Goals & Non-Goals

**Goals**:
- Create learn-it task before fix-it task when NOTE: tags exist and both are selected
- Add dependency from fix-it task to learn-it task in state.json and TODO.md
- Update learn-it task description to include instruction for NOTE: to FIX: tag replacement
- Update user documentation to reflect the new behavior

**Non-Goals**:
- Changing the behavior when only one task type is selected
- Modifying TODO: tag processing
- Automatic NOTE: to FIX: conversion (the learn-it task description instructs the implementer to do this)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing learn flow | High | Low | Changes are conditional on NOTE: tags AND both task types selected |
| Incorrect dependency format | Medium | Low | Use existing documented formats from state.json and TODO.md |
| User confusion about new behavior | Low | Medium | Update documentation clearly explaining the dependency |

## Implementation Phases

### Phase 1: Modify Task Creation Logic [COMPLETED]

**Goal**: Reorder task creation when NOTE: tags exist and both fix-it and learn-it tasks are selected

**Tasks**:
- [ ] Add variable to track if learn-it task is created and store its task number
- [ ] Add conditional logic to check: (NOTE: tags exist) AND (both fix-it and learn-it selected)
- [ ] When condition is true, create learn-it task FIRST (Step 8.2a)
- [ ] Store the learn-it task number for dependency reference
- [ ] Create fix-it task SECOND with dependency array (Step 8.2b)
- [ ] When condition is false, preserve original order (fix-it then learn-it)

**Timing**: 45 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Step 8: Create Selected Tasks section

**Verification**:
- When NOTE: tags exist and both task types selected: learn-it created first, fix-it has dependency
- When only FIX: tags exist: original behavior preserved
- When only one task type selected: no dependency added

---

### Phase 2: Add Dependency Field Population [COMPLETED]

**Goal**: Populate dependency fields in both state.json and TODO.md

**Tasks**:
- [ ] Update state.json update logic to include `"dependencies": [learn_it_task_number]` for fix-it task
- [ ] Update TODO.md entry to include `- **Dependencies**: {learn_it_task_number}` for fix-it task
- [ ] Ensure jq commands use two-step pattern to avoid escaping issues

**Timing**: 30 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Step 9: Update State Files section

**Verification**:
- Fix-it task in state.json has `dependencies: [N]` where N is learn-it task number
- Fix-it task in TODO.md has `- **Dependencies**: N` line
- Learn-it task has no dependencies field

---

### Phase 3: Update Learn-It Task Description [COMPLETED]

**Goal**: Include explicit instruction in learn-it task description to replace NOTE: with FIX: in source files

**Tasks**:
- [ ] Modify the learn-it task description template in Step 8.3
- [ ] Add clear instruction about NOTE: to FIX: replacement after context updates
- [ ] Ensure instruction explains the division of labor (learn-it = context updates + tag conversion, fix-it = code changes)

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Step 8.3: Learn-It Task section

**Verification**:
- Learn-it task description includes explicit instruction about NOTE: to FIX: conversion
- Description explains the purpose (enable fix-it task to make file-local changes)

---

### Phase 4: Update Documentation [COMPLETED]

**Goal**: Update user-facing documentation to reflect the new dependency behavior

**Tasks**:
- [ ] Update `.claude/commands/learn.md`:
  - [ ] Modify Tag Types table to note dependency when both task types created
  - [ ] Add explanation of learn-it to fix-it dependency workflow
  - [ ] Update task type descriptions
- [ ] Update `.claude/docs/examples/learn-flow-example.md`:
  - [ ] Update Step 6 task creation example to show dependency
  - [ ] Update Task Types table to mention dependency
  - [ ] Update example output to show dependency in TODO.md format

**Timing**: 25 minutes

**Files to modify**:
- `.claude/commands/learn.md` - Tag Types section, Task Type Details section
- `.claude/docs/examples/learn-flow-example.md` - Step 6, example outputs, Tag Types table

**Verification**:
- Documentation clearly explains the dependency relationship
- Example output shows dependency field in created tasks
- Division of labor between learn-it and fix-it is documented

---

## Testing & Validation

- [ ] Manual test: Run `/learn` on file with NOTE: tags, select both task types, verify dependency created
- [ ] Manual test: Run `/learn` on file with only FIX: tags, verify no dependency created
- [ ] Manual test: Run `/learn` on file with NOTE: tags, select only fix-it task, verify no dependency
- [ ] Manual test: Run `/learn` on file with NOTE: tags, select only learn-it task, verify task created without dependency
- [ ] Verify state.json has correct `dependencies` array format
- [ ] Verify TODO.md has correct `- **Dependencies**:` format
- [ ] Review learn-it task description includes NOTE: to FIX: instruction

## Artifacts & Outputs

- `.claude/skills/skill-learn/SKILL.md` - Updated skill with dependency logic
- `.claude/commands/learn.md` - Updated user documentation
- `.claude/docs/examples/learn-flow-example.md` - Updated example documentation
- `specs/649_improve_learn_note_tag_dependency_handling/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If implementation causes issues:
1. Revert changes to SKILL.md to restore original task creation order
2. Revert documentation changes
3. The changes are isolated to the /learn command and do not affect other workflows

The modification is additive and preserves existing behavior when conditions are not met (no NOTE: tags or only one task type selected), so rollback risk is minimal.
