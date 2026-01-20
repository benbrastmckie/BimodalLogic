# Research Report: Task #649

**Task**: 649 - Improve /learn NOTE: tag dependency handling
**Date**: 2026-01-20
**Focus**: Understanding current /learn implementation and designing NOTE: tag dependency handling

## Summary

The `/learn` command currently creates fix-it and learn-it tasks independently when NOTE: tags exist. This research documents the current implementation and identifies the specific code locations and modifications needed to: (1) add a dependency from fix-it task to learn-it task, and (2) have the learn-it task replace NOTE: tags with FIX: tags during implementation.

## Current Implementation Analysis

### File Locations

| File | Purpose |
|------|---------|
| `.claude/commands/learn.md` | Command definition and user-facing documentation |
| `.claude/skills/skill-learn/SKILL.md` | Direct execution skill implementing tag scanning and task creation |
| `.claude/docs/examples/learn-flow-example.md` | End-to-end example documentation |

### Current Tag-to-Task Mapping

| Tag | Task Types Created | Description |
|-----|-------------------|-------------|
| `FIX:` | fix-it-task only | Local code changes |
| `NOTE:` | fix-it-task AND learn-it-task | Both local changes and context updates |
| `TODO:` | todo-task(s) | Individual tasks per selected item |

### Current Task Creation Flow (skill-learn/SKILL.md)

1. **Tag Extraction** (Steps 3.1-3.3): Scans files using grep patterns for FIX:, NOTE:, TODO: tags
2. **Tag Display** (Step 4): Shows findings to user
3. **Task Type Selection** (Step 6): User selects which task types to create via AskUserQuestion
4. **Task Creation** (Steps 8.2-8.4): Creates tasks independently in sequence

### Current Task Schema (from state.json)

Tasks support a `dependencies` array field:
```json
{
  "project_number": 399,
  "dependencies": [398],
  ...
}
```

And TODO.md uses format:
```markdown
- **Dependencies**: 398
```

Multiple dependencies use comma-separated values: `- **Dependencies**: 398, 399`

## Findings

### Finding 1: Task Creation Order in SKILL.md

Current task creation order (Step 8):
1. 8.2: Fix-It Task (if selected)
2. 8.3: Learn-It Task (if selected)
3. 8.4: Todo-Tasks (if selected)

**Required Change**: Reverse the creation order when NOTE: tags exist, creating learn-it task FIRST so its task number can be used as a dependency for the fix-it task.

### Finding 2: Task Creation Independence

Current implementation creates tasks with no inter-task relationships:
- No `dependencies` array is populated
- No `parent_task` field is set
- Tasks are created as independent entities

**Required Change**: When both fix-it and learn-it tasks are created from NOTE: tags:
- Create learn-it task first to get its task number
- Create fix-it task with `dependencies: [learn-it-task-number]`

### Finding 3: NOTE: to FIX: Tag Replacement

Current behavior: NOTE: tags are included in both fix-it and learn-it task descriptions, but the original source files are never modified.

**Task Description of Current Behavior**:
- Fix-it task: "Address {N} items from embedded tags:\n\n{list including NOTE: items}"
- Learn-it task: "Update {N} context files based on learnings:\n\n{grouped NOTE: items}"

**Required Change**: The learn-it task description should include an explicit instruction to:
1. Update the relevant context files based on the NOTE: insights
2. Replace each `NOTE:` tag in the source file with `FIX:` (keeping the message)

This creates a clear division of labor:
- **Learn-it task**: Extracts knowledge to context files, converts NOTE: -> FIX:
- **Fix-it task**: Makes file-local code changes based on remaining FIX: tags

### Finding 4: Dependency Format in TODO.md and state.json

**TODO.md format** (from existing examples):
```markdown
- **Dependencies**: 398
```

**state.json format** (from existing examples):
```json
{
  "dependencies": [398]
}
```

Both formats are already established and working. The `/learn` skill just needs to use them when creating tasks.

### Finding 5: Conditional Dependency Logic

Dependencies should ONLY be added when:
1. Both fix-it AND learn-it tasks are selected by the user
2. There are NOTE: tags present

If user selects only fix-it (no learn-it), or there are no NOTE: tags, no dependency is needed.

## Recommendations

### Implementation Approach

**Phase 1: Modify Task Creation Order**

Location: `.claude/skills/skill-learn/SKILL.md`, Step 8

Change from:
```
8.2: Fix-It Task
8.3: Learn-It Task
```

To conditional logic:
```
if (NOTE: tags exist AND both fix-it and learn-it selected):
    8.2a: Learn-It Task FIRST (capture task number)
    8.2b: Fix-It Task with dependency on learn-it
else:
    8.2: Fix-It Task (original behavior)
    8.3: Learn-It Task (original behavior)
```

**Phase 2: Add Dependency Field Population**

Add dependency field to fix-it task creation when learn-it task exists:

```json
{
  "title": "Fix issues from FIX:/NOTE: tags",
  "dependencies": [learn_it_task_number],
  ...
}
```

**Phase 3: Update Learn-It Task Description**

Modify the learn-it task description template to include NOTE: -> FIX: replacement instruction:

Current:
```
"description": "Update {N} context files based on learnings:\n\n{grouped by target context}"
```

Proposed:
```
"description": "Update context files based on {N} NOTE: tags and replace NOTE: with FIX: in source files:\n\n{grouped by target context}\n\n**After updating context files, replace each NOTE: tag with FIX: in the source file to enable the fix-it task to make file-local changes.**"
```

**Phase 4: Update Documentation**

Update files to reflect new behavior:
- `.claude/commands/learn.md` - Tag Types table, task type descriptions
- `.claude/docs/examples/learn-flow-example.md` - Example output

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| User selects learn-it but not fix-it | No dependency needed | Conditional logic checks both selections |
| No NOTE: tags exist | No dependency needed | Conditional logic checks NOTE: tag count |
| Task number collision | Invalid dependency | Sequential task creation ensures valid numbers |
| Existing workflows disrupted | User confusion | Changes are additive, existing behavior preserved when conditions not met |

## Code Location Summary

| Change | File | Section |
|--------|------|---------|
| Task creation order | `skill-learn/SKILL.md` | Step 8 |
| Dependency field | `skill-learn/SKILL.md` | Step 8.2 jq command |
| Learn-it description | `skill-learn/SKILL.md` | Step 8.3 template |
| TODO.md dependency format | `skill-learn/SKILL.md` | Step 9.2 |
| User documentation | `commands/learn.md` | Tag Types table |
| Example documentation | `docs/examples/learn-flow-example.md` | Task Creation section |

## Division of Labor Summary

After implementation, the workflow for NOTE: tags will be:

```
1. /learn scans file, finds NOTE: tags
2. User selects both fix-it and learn-it tasks
3. Learn-it task created (e.g., Task #650)
4. Fix-it task created with dependency on #650 (e.g., Task #651, depends on 650)
5. User implements learn-it task first:
   - Updates .claude/context/ files with insights
   - Replaces NOTE: with FIX: in source files
   - Commits changes
6. User implements fix-it task second:
   - Makes file-local code changes for FIX: tags
   - Commits changes
```

This ensures:
- Context documentation is updated BEFORE code changes
- Clear separation: learn-it = documentation, fix-it = code
- Dependency enforces correct ordering

## Next Steps

Run `/plan 649` to create a detailed implementation plan based on these findings.
