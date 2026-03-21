# Implementation Plan: Task #651

- **Task**: 651 - Simplify /learn NOTE: tag workflow
- **Status**: [COMPLETED]
- **Effort**: 1.5 hours
- **Priority**: Medium
- **Dependencies**: 649 (completed) - NOTE: tag dependency handling
- **Research Inputs**: specs/651_simplify_learn_note_tag_workflow/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

This task simplifies the /learn command workflow by removing the unnecessary NOTE: to FIX: tag replacement instruction from learn-it tasks. Instead, learn-it tasks will focus solely on updating context files, while fix-it tasks will explicitly handle removal of both NOTE: and FIX: tags when making code changes. This simplification removes one step from the learn-it task workflow while maintaining the dependency structure established in task 649.

### Research Integration

The research report (research-001.md) identified:
- The exact location of the NOTE: to FIX: instruction in SKILL.md (Step 8.2a, lines 259-268)
- Three files requiring updates: SKILL.md, learn.md, and learn-flow-example.md
- The need to add explicit tag removal instructions to fix-it task descriptions

## Goals & Non-Goals

**Goals**:
- Remove the "NOTE: to FIX: replacement" instruction from learn-it task descriptions (Step 8.2a)
- Add explicit tag removal instruction to fix-it task descriptions (Step 8.2b)
- Update command documentation (learn.md) to reflect simplified workflow
- Update example documentation (learn-flow-example.md) to show correct workflow

**Non-Goals**:
- Changing the dependency structure between learn-it and fix-it tasks (task 649's contribution)
- Modifying the learn-it task template without dependency (Step 8.3)
- Changing how TODO: tags are handled

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Users expect NOTE: tags to become FIX: | Low | Low | Documentation clearly explains new workflow |
| Fix-it implementers miss NOTE: tags | Medium | Low | Explicit instruction in fix-it task description |
| Workflow confusion during transition | Low | Low | Dependency relationship still enforces correct ordering |

## Implementation Phases

### Phase 1: Update SKILL.md Learn-It Task Description [COMPLETED]

**Goal**: Remove the NOTE: to FIX: replacement instruction from the learn-it task description template

**Tasks**:
- [ ] Edit `.claude/skills/skill-learn/SKILL.md` Step 8.2a (lines 259-268)
- [ ] Remove the `**Important**: After updating context files...` paragraph from the description field
- [ ] Verify the simplified description still explains what learn-it tasks do

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Remove NOTE: to FIX: instruction from Step 8.2a

**Verification**:
- The learn-it task description in Step 8.2a ends with `{grouped by target context}` without the Important paragraph
- Step 8.3 (learn-it without dependency) remains unchanged

---

### Phase 2: Update SKILL.md Fix-It Task Description [COMPLETED]

**Goal**: Add explicit instruction for fix-it tasks to remove both NOTE: and FIX: tags when making changes

**Tasks**:
- [ ] Edit `.claude/skills/skill-learn/SKILL.md` Step 8.2b (lines 274-297)
- [ ] Update the fix-it task description template to include tag removal instruction
- [ ] Add note clarifying that TODO: tags should be left untouched

**Timing**: 20 minutes

**Files to modify**:
- `.claude/skills/skill-learn/SKILL.md` - Add tag removal instruction to Step 8.2b

**Verification**:
- Fix-it task description includes instruction to remove both NOTE: and FIX: tags
- Instruction explicitly notes that TODO: tags should remain

---

### Phase 3: Update Command Documentation [COMPLETED]

**Goal**: Update learn.md to reflect the simplified workflow

**Tasks**:
- [ ] Edit `.claude/commands/learn.md` lines 44-55 (Dependency Workflow section)
- [ ] Change learn-it task description to "Updates context files based on learnings (NOTE: tags remain in source)"
- [ ] Update fix-it task description to mention it "removes NOTE: and FIX: tags when making changes"

**Timing**: 20 minutes

**Files to modify**:
- `.claude/commands/learn.md` - Update Dependency Workflow for NOTE: Tags section

**Verification**:
- Documentation clearly states learn-it tasks do not modify source file tags
- Documentation states fix-it tasks remove both NOTE: and FIX: tags

---

### Phase 4: Update Example Documentation [COMPLETED]

**Goal**: Update learn-flow-example.md to show the simplified workflow

**Tasks**:
- [ ] Edit `.claude/docs/examples/learn-flow-example.md` lines 223-228
- [ ] Remove the `**Important**:...` paragraph from the learn-it task example
- [ ] Verify example JSON matches the new simplified format

**Timing**: 30 minutes

**Files to modify**:
- `.claude/docs/examples/learn-flow-example.md` - Update learn-it task example description

**Verification**:
- Example learn-it task description no longer includes NOTE: to FIX: conversion instruction
- Example matches the updated SKILL.md template

## Testing & Validation

- [ ] Verify SKILL.md Step 8.2a learn-it description is simplified
- [ ] Verify SKILL.md Step 8.2b fix-it description includes tag removal instruction
- [ ] Verify learn.md Dependency Workflow section is updated
- [ ] Verify learn-flow-example.md example matches new format
- [ ] Verify Step 8.3 (learn-it without dependency) is unchanged
- [ ] Manual review: Run `/learn` mentally through the new flow to confirm consistency

## Artifacts & Outputs

- Modified `.claude/skills/skill-learn/SKILL.md` - Updated task description templates
- Modified `.claude/commands/learn.md` - Updated user-facing documentation
- Modified `.claude/docs/examples/learn-flow-example.md` - Updated example
- `specs/651_simplify_learn_note_tag_workflow/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the simplified workflow causes confusion or issues:
1. Restore the original SKILL.md content from git history (`git checkout HEAD~1 -- .claude/skills/skill-learn/SKILL.md`)
2. Restore documentation files similarly
3. Document the issue in errors.json for future analysis
4. Consider alternative approaches (e.g., making the NOTE: to FIX: conversion optional)
