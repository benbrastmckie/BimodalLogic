# /task Command Quick Reference

## Overview

The `/task` command executes tasks from TODO.md with **automatic status tracking**.

## Basic Usage

```bash
/task {number}    # Execute task by number
```

## Examples

```bash
/task 61    # Simple task: Add Missing Directory READMEs
/task 52    # Moderate task: Fix AesopRules duplicate  
/task 9     # Complex task: Begin Completeness Proofs
```

## Automatic Status Tracking

### What Happens Automatically

#### When You Start a Task
✅ **TODO.md is automatically updated**:
```markdown
**Status**: Not Started
```
↓
```markdown
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
```

#### When a Simple Task Completes
✅ **TODO.md is automatically updated**:
```markdown
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
```
↓
```markdown
**Status**: [COMPLETE] ✅
**Started**: 2025-12-16
**Completed**: 2025-12-16
```

#### When a Complex Task Needs Implementation
⏸️ **Status stays IN PROGRESS**:
```markdown
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
```

You then run the recommended command:
```bash
/lean .opencode/specs/009_task_name/plans/implementation-001.md
# or
/implement .opencode/specs/052_task_name/plans/implementation-001.md
```

After completing implementation, **manually mark complete** in TODO.md.

## Task Complexity Levels

### Simple Tasks (≤30 minutes)
- **Executed directly** by the task command
- **Automatically marked complete** ✅
- Examples: Documentation updates, simple fixes

**Workflow**:
```
/task 61 → [IN PROGRESS] → Execute → [COMPLETE] ✅
```

### Moderate Tasks (30 min - 2 hours)
- **Creates implementation plan**
- **Recommends /implement command**
- **Status stays IN PROGRESS** until you complete it
- Examples: Bug fixes, refactoring

**Workflow**:
```
/task 52 → [IN PROGRESS] → Plan → /implement → (manual complete)
```

### Complex Tasks (>2 hours)
- **Conducts research** (creates research report)
- **Creates detailed plan**
- **Recommends /lean or /implement**
- **Status stays IN PROGRESS** until you complete it
- Examples: New features, proof development

**Workflow**:
```
/task 9 → [IN PROGRESS] → Research → Plan → /lean → (manual complete)
```

## Status States

| Status | Meaning | How It's Set |
|--------|---------|--------------|
| `Not Started` | Task hasn't been started yet | Default in TODO.md |
| `[IN PROGRESS]` | Task is actively being worked on | **Automatic** when you run `/task` |
| `[COMPLETE]` ✅ | Task is finished | **Automatic** for simple tasks, **manual** for complex |

## What You Need to Do

### For Simple Tasks
**Nothing!** Just run `/task {number}` and it's done.

```bash
/task 61    # Automatically completes and marks ✅
```

### For Moderate/Complex Tasks
1. Run `/task {number}` (marks IN PROGRESS automatically)
2. Review the plan and research (if complex)
3. Run the recommended command (`/lean` or `/implement`)
4. **Manually mark complete** in TODO.md after verification

```bash
/task 52                          # Step 1: Marks IN PROGRESS
/implement .opencode/specs/...    # Step 2: Execute plan
# Step 3: Manually update TODO.md to [COMPLETE]
```

## Error Handling

### Task Not Found
```
Warning: Task 99 not found in TODO.md
Proceeding without status tracking
```
→ Task execution continues, but no status updates

### Task Already Complete
```
Task 61 is already marked complete ✅
Please choose another task.
```
→ Task execution stops, choose a different task

### TODO.md Not Found
```
Warning: TODO.md not found
Proceeding without status tracking
```
→ Task execution continues, but no status updates

## Tips

### Check Task Status
Before starting a task, check TODO.md to see if it's already in progress:
```bash
grep -A 5 "### 61" .opencode/specs/TODO.md
```

### Find Available Tasks
List all "Not Started" tasks:
```bash
grep -B 1 "Not Started" .opencode/specs/TODO.md
```

### See Active Tasks
List all tasks currently in progress:
```bash
grep -B 1 "IN PROGRESS" .opencode/specs/TODO.md
```

### Manual Status Update
If you need to manually update a task status:
1. Open `.opencode/specs/TODO.md`
2. Find the task section (e.g., `### 61. Task Name`)
3. Update the `**Status**:` field
4. Add timestamps if needed:
   - `**Started**: YYYY-MM-DD`
   - `**Completed**: YYYY-MM-DD`

## Common Workflows

### Quick Documentation Update
```bash
/task 61    # Executes and completes automatically
```

### Bug Fix
```bash
/task 52                                    # Creates plan
/implement .opencode/specs/052_.../...      # Execute fix
# Manually mark complete in TODO.md
```

### New Feature Development
```bash
/task 9                                     # Research + Plan
/lean .opencode/specs/009_.../...           # Implement proofs
# Manually mark complete in TODO.md
```

### Research Task
```bash
/task 11                                    # Research + Plan
# Review research report
# Decide on next steps
# Manually mark complete when research is done
```

## Troubleshooting

### Status Not Updating
**Check**:
1. Is TODO.md at `.opencode/specs/TODO.md`?
2. Does the task section exist with correct format?
3. Is the `**Status**:` field present?

**Fix**: Manually verify TODO.md format matches expected patterns

### Task Marked Complete But Not Done
**Cause**: Simple task was executed automatically but needs more work

**Fix**: 
1. Change status back to `[IN PROGRESS]`
2. Complete the remaining work
3. Manually mark `[COMPLETE]` when truly done

### Multiple Tasks with Same Number
**Cause**: Duplicate task numbers in TODO.md

**Fix**: 
1. Renumber tasks to ensure unique IDs
2. First match will be used with warning

## Best Practices

### Before Starting a Task
1. ✅ Check if task is already in progress (avoid duplicates)
2. ✅ Read task description and requirements
3. ✅ Check dependencies and blocking tasks
4. ✅ Estimate if you have time to complete it

### During Task Execution
1. ✅ Follow the recommended workflow (research → plan → implement)
2. ✅ Review generated artifacts (plans, research reports)
3. ✅ Ask questions if requirements are unclear
4. ✅ Update TODO.md if you discover new information

### After Task Completion
1. ✅ Verify all changes are correct
2. ✅ Run tests if applicable
3. ✅ Update related documentation
4. ✅ Manually mark complete (for moderate/complex tasks)
5. ✅ Update "Last Updated" date in TODO.md

## Quick Reference Card

```
┌─────────────────────────────────────────────────────────┐
│ /task Command Quick Reference                           │
├─────────────────────────────────────────────────────────┤
│                                                          │
│ USAGE:                                                   │
│   /task {number}                                         │
│                                                          │
│ AUTOMATIC STATUS TRACKING:                              │
│   Start:    Not Started → [IN PROGRESS] ✅              │
│   Complete: [IN PROGRESS] → [COMPLETE] ✅ (simple only) │
│                                                          │
│ TASK TYPES:                                              │
│   Simple:   Execute directly, auto-complete             │
│   Moderate: Create plan, recommend /implement           │
│   Complex:  Research + plan, recommend /lean            │
│                                                          │
│ EXAMPLES:                                                │
│   /task 61    # Simple: Auto-complete                   │
│   /task 52    # Moderate: Plan + /implement             │
│   /task 9     # Complex: Research + plan + /lean        │
│                                                          │
│ MANUAL COMPLETION:                                       │
│   Moderate/complex tasks require manual completion      │
│   after running /lean or /implement                     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

## See Also

- **Full Documentation**: `.opencode/specs/TASK_STATUS_TRACKING_ENHANCEMENT.md`
- **TODO.md**: `.opencode/specs/TODO.md`
- **Task Executor Agent**: `.opencode/agent/subagents/task-executor.md`
- **Command Definition**: `.opencode/command/task.md`
