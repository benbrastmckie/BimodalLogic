# Research Report: Task #651

- **Task**: 651 - Simplify /learn NOTE: tag workflow
- **Started**: 2026-01-20T21:35:30Z
- **Completed**: 2026-01-20T21:45:00Z
- **Effort**: 1 hour
- **Priority**: Medium
- **Dependencies**: 649 (completed) - NOTE: tag dependency handling
- **Sources/Inputs**:
  - `.claude/skills/skill-learn/SKILL.md` - Current skill implementation
  - `.claude/commands/learn.md` - User-facing command documentation
  - `.claude/docs/examples/learn-flow-example.md` - Flow example documentation
  - `specs/649_improve_learn_note_tag_dependency_handling/` - Context from predecessor task
- **Artifacts**: specs/651_simplify_learn_note_tag_workflow/reports/research-001.md (this file)
- **Standards**: report-format.md, artifact-formats.md, state-management.md

## Executive Summary

- Task 649 added NOTE: to FIX: tag replacement instruction to learn-it task descriptions - this is the target for removal
- The simplification removes ONE instruction from learn-it task descriptions in SKILL.md
- Fix-it task descriptions should be updated to explicitly mention removing NOTE: tags (not just FIX:)
- Documentation files need minor updates to reflect the simplified workflow
- Total changes span 3 files with targeted edits to task description templates

## Context & Scope

Task 649 (just completed) introduced dependency handling for NOTE: tags in the `/learn` command. It established that when both fix-it and learn-it tasks are selected for NOTE: tags:

1. Learn-it task is created FIRST
2. Fix-it task depends on learn-it task
3. Learn-it task description includes: "After updating context files, replace all NOTE: tags with FIX: tags"

This task (651) simplifies the workflow by **removing the NOTE: to FIX: replacement instruction** from learn-it tasks. The new model is:

- **Learn-it tasks**: Focus ONLY on updating context files and documentation (leave NOTE: tags as-is)
- **Fix-it tasks**: Remove BOTH NOTE: and FIX: tags when making file changes (leave TODO: tags)

## Findings

### 1. Current Learn-It Task Description (lines 259-268 in SKILL.md)

The learn-it task description template at Step 8.2a currently reads:

```json
{
  "title": "Update context files from NOTE: tags",
  "description": "Update {N} context files based on learnings:\n\n{grouped by target context}\n\n**Important**: After updating context files, replace all NOTE: tags with FIX: tags in the source files. This enables the dependent fix-it task to make file-local code changes.",
  "language": "meta",
  "priority": "medium",
  "effort": "1-2 hours"
}
```

**Required change**: Remove the `**Important**: After updating context files...` paragraph entirely.

### 2. Current Fix-It Task Description (lines 274-297 in SKILL.md)

The fix-it task description at Step 8.2b currently reads:

```json
{
  "title": "Fix issues from FIX:/NOTE: tags",
  "description": "Address {N} items from embedded tags:\n\n{list of items with file:line references}",
  ...
}
```

**Required change**: Update description to clarify that fix-it tasks should remove BOTH NOTE: and FIX: tags when making changes (leaving TODO: tags untouched).

### 3. Learn-It Task Without Dependency (lines 307-319 in SKILL.md)

Step 8.3 has a separate learn-it task template for when dependency is NOT created. This template does NOT have the NOTE: to FIX: instruction, so no change needed here.

### 4. Command Documentation (learn.md)

Lines 44-55 contain the "Dependency Workflow for NOTE: Tags" section that mentions:

```
1. **Learn-it task is created first** - Updates context files AND replaces all NOTE: tags with FIX: tags in source files
```

**Required change**: Remove "AND replaces all NOTE: tags with FIX: tags in source files"

### 5. Example Documentation (learn-flow-example.md)

Lines 223-228 contain the learn-it task example with the NOTE: to FIX: instruction:

```json
{
  "description": "Update 1 context files based on learnings:\n\n- Logos/Layer2/Temporal.lean:45 - This pattern should be documented\n\n**Important**: After updating context files, replace all NOTE: tags with FIX: tags in the source files. This enables the dependent fix-it task to make file-local code changes."
}
```

**Required change**: Remove the `**Important**:...` paragraph from example.

## Decisions

1. **Learn-it task description simplification**: Remove the NOTE: to FIX: replacement instruction entirely
2. **Fix-it task scope clarification**: Add explicit mention that fix-it tasks remove BOTH NOTE: and FIX: tags
3. **Maintain dependency structure**: Keep the learn-it -> fix-it dependency (task 649's core contribution)
4. **TODO: tags unchanged**: Fix-it tasks should NOT touch TODO: tags (these become separate todo-tasks)

## Recommendations

### Phase 1: Update SKILL.md Learn-It Task Description

**File**: `.claude/skills/skill-learn/SKILL.md`
**Location**: Step 8.2a (lines 259-268)

Change the description field from:
```
"description": "Update {N} context files based on learnings:\n\n{grouped by target context}\n\n**Important**: After updating context files, replace all NOTE: tags with FIX: tags in the source files. This enables the dependent fix-it task to make file-local code changes."
```

To:
```
"description": "Update {N} context files based on learnings:\n\n{grouped by target context}"
```

### Phase 2: Update SKILL.md Fix-It Task Description

**File**: `.claude/skills/skill-learn/SKILL.md`
**Location**: Step 8.2b (lines 274-297)

Update the description template to clarify NOTE: and FIX: tag removal:

Change from:
```
"description": "Address {N} items from embedded tags:\n\n{list of items with file:line references}"
```

To:
```
"description": "Address {N} items from embedded tags:\n\n{list of items with file:line references}\n\n**Note**: Remove both NOTE: and FIX: tags from source files when addressing each item. Leave TODO: tags untouched."
```

### Phase 3: Update Command Documentation

**File**: `.claude/commands/learn.md`
**Location**: Lines 44-55 (Dependency Workflow section)

Change:
```
1. **Learn-it task is created first** - Updates context files AND replaces all NOTE: tags with FIX: tags in source files
```

To:
```
1. **Learn-it task is created first** - Updates context files based on learnings (NOTE: tags remain in source)
2. **Fix-it task is created second with dependency** - Has `dependencies: [learn_it_task_num]` pointing to the learn-it task; removes NOTE: and FIX: tags when making changes
```

### Phase 4: Update Example Documentation

**File**: `.claude/docs/examples/learn-flow-example.md`
**Location**: Lines 223-228 (learn-it task example)

Remove the `**Important**:...` paragraph from the example description.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Users expect NOTE: tags to become FIX: | Low | Documentation clearly explains new workflow |
| Fix-it implementers miss NOTE: tags | Medium | Explicit instruction in fix-it task description |
| Workflow confusion | Low | Dependency relationship still enforces correct ordering |

## Appendix

### Files to Modify

1. `.claude/skills/skill-learn/SKILL.md` - 2 sections: Step 8.2a and Step 8.2b
2. `.claude/commands/learn.md` - 1 section: Dependency Workflow for NOTE: Tags
3. `.claude/docs/examples/learn-flow-example.md` - 1 section: Learn-it task example

### Workflow Comparison

**Before (Task 649)**:
```
NOTE: tag found
  -> learn-it task: Update context files + Convert NOTE: to FIX:
  -> fix-it task (depends on learn-it): Address FIX: tags only
```

**After (Task 651)**:
```
NOTE: tag found
  -> learn-it task: Update context files only (NOTE: remains)
  -> fix-it task (depends on learn-it): Address both NOTE: and FIX: tags, remove them
```

### Task Description Templates Summary

| Task Type | Current Description | Simplified Description |
|-----------|---------------------|------------------------|
| learn-it (with dependency) | Context updates + NOTE: to FIX: conversion | Context updates only |
| learn-it (without dependency) | Context updates only | No change needed |
| fix-it | Address items from tags | Address items + explicit tag removal instruction |
