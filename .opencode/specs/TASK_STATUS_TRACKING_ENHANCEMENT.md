# Task Command Status Tracking Enhancement

**Date**: 2025-12-16  
**Status**: Implemented  
**Files Modified**: 
- `.opencode/command/task.md`
- `.opencode/agent/subagents/task-executor.md`

## Overview

Enhanced the `/task` command to automatically track task status in TODO.md throughout the task lifecycle. Tasks are now automatically marked as `[IN PROGRESS]` when started and `[COMPLETE]` when finished (for simple tasks executed directly).

## Motivation

**Problem**: Manual TODO.md updates were error-prone and often forgotten, leading to:
- Stale task status (tasks marked "Not Started" when actually in progress)
- Duplicate work (multiple people starting the same task)
- Lost visibility into active work
- Incomplete completion tracking

**Solution**: Automatic status tracking integrated into the `/task` command workflow ensures TODO.md always reflects current task state.

## Implementation

### Architecture

The enhancement adds two new workflow stages to the task-executor agent:

1. **Stage 1: MarkTaskInProgress** (Pre-execution)
   - Reads TODO.md
   - Locates task by number
   - Updates status from "Not Started" to "[IN PROGRESS]"
   - Adds "Started: YYYY-MM-DD" timestamp
   - Writes updated TODO.md

2. **Stage 9: MarkTaskComplete** (Post-execution, conditional)
   - Only executes for simple tasks that were completed directly
   - Updates status from "[IN PROGRESS]" to "[COMPLETE]"
   - Adds "Completed: YYYY-MM-DD" timestamp
   - Optionally adds ✅ emoji to task title
   - Writes updated TODO.md

### Task Lifecycle

```
┌─────────────────────────────────────────────────────────────┐
│ User runs: /task 61                                         │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Stage 1: MarkTaskInProgress                                 │
│ - TODO.md: **Status**: Not Started                         │
│          → **Status**: [IN PROGRESS]                        │
│ - Adds: **Started**: 2025-12-16                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│ Stages 2-8: Task Execution                                  │
│ - Extract task details                                      │
│ - Assess complexity                                         │
│ - Create project directory                                  │
│ - Execute research (if complex)                             │
│ - Create implementation plan                                │
│ - Determine next step                                       │
│ - Execute task (if simple)                                  │
└─────────────────────────────────────────────────────────────┘
                            ↓
                    ┌───────┴───────┐
                    │               │
            Simple Task      Moderate/Complex Task
            (executed)       (requires /lean or /implement)
                    │               │
                    ↓               ↓
    ┌───────────────────────┐   ┌──────────────────────────┐
    │ Stage 9: Complete     │   │ Status stays IN PROGRESS │
    │ - TODO.md:            │   │ - User runs /lean or     │
    │   [IN PROGRESS]       │   │   /implement             │
    │ → [COMPLETE] ✅       │   │ - User manually marks    │
    │ - Adds: **Completed** │   │   complete later         │
    │   2025-12-16          │   └──────────────────────────┘
    └───────────────────────┘
```

### Task Matching Logic

Tasks are identified using multiple patterns:

1. **Section Header**: `### {number}. {title}`
   - Example: `### 61. Add Missing Directory READMEs`
   - Extracts task number (61) and title

2. **Status Field**: `**Status**: {current_status}`
   - Example: `**Status**: Not Started`
   - Updated to: `**Status**: [IN PROGRESS]`

3. **Timestamp Fields**:
   - `**Started**: YYYY-MM-DD` (added when marking in progress)
   - `**Completed**: YYYY-MM-DD` (added when marking complete)

### Example Transformations

#### Starting a Task

**Before** (`/task 61`):
```markdown
### 61. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: Not Started
**Priority**: Medium (documentation completeness)
**Blocking**: None
**Dependencies**: None
```

**After** (Stage 1 - MarkTaskInProgress):
```markdown
### 61. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
**Priority**: Medium (documentation completeness)
**Blocking**: None
**Dependencies**: None
```

#### Completing a Simple Task

**Before** (simple task executed):
```markdown
### 61. Add Missing Directory READMEs
**Effort**: 1 hour
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
**Priority**: Medium (documentation completeness)
```

**After** (Stage 9 - MarkTaskComplete):
```markdown
### 61. Add Missing Directory READMEs ✅
**Effort**: 1 hour
**Status**: [COMPLETE]
**Started**: 2025-12-16
**Completed**: 2025-12-16
**Priority**: Medium (documentation completeness)
```

#### Moderate/Complex Task (Requires Implementation)

**After Planning** (status remains IN PROGRESS):
```markdown
### 52. Fix AesopRules Duplicate
**Effort**: 1 hour
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
**Priority**: Medium
```

User then runs:
```bash
/implement .opencode/specs/052_fix_aesop_duplicate/plans/implementation-001.md
```

User manually marks complete after verification:
```markdown
### 52. Fix AesopRules Duplicate ✅
**Effort**: 1 hour
**Status**: [COMPLETE]
**Started**: 2025-12-16
**Completed**: 2025-12-16
**Priority**: Medium
```

## Error Handling

The implementation includes comprehensive error handling to ensure task execution continues even if status tracking fails:

### Task Not Found
- **Scenario**: Task number doesn't exist in TODO.md
- **Action**: Log warning, proceed with execution without status update
- **Message**: `"Warning: Task {number} not found in TODO.md - proceeding without status tracking"`

### TODO.md Not Found
- **Scenario**: TODO.md file doesn't exist at expected path
- **Action**: Log warning, proceed with execution
- **Message**: `"Warning: TODO.md not found at .opencode/specs/TODO.md - proceeding without status tracking"`

### Task Already Complete
- **Scenario**: Task status is already "Complete" or contains ✅
- **Action**: Notify user, suggest other tasks, STOP execution
- **Message**: `"Task {number} is already marked complete ✅. Please choose another task."`

### File Write Error
- **Scenario**: Cannot write updated TODO.md (permissions, disk full, etc.)
- **Action**: Log error, continue with task execution
- **Message**: `"Error: Failed to update TODO.md: {error_details} - continuing with task execution"`

### Multiple Matches
- **Scenario**: Multiple tasks with same number (edge case)
- **Action**: Use first match, log warning
- **Message**: `"Warning: Multiple matches for task {number} - using first occurrence"`

## File Safety

### Atomic Writes
- Read entire TODO.md into memory
- Make all modifications in memory
- Write entire file back in single operation
- No partial writes or line-by-line updates

### Preserve Formatting
- Maintain exact indentation (spaces/tabs)
- Preserve blank lines
- Keep all markdown formatting
- Only modify specific status/timestamp fields
- Leave all other content untouched

## Usage Examples

### Simple Task (Executed Directly)
```bash
/task 59    # Update IMPLEMENTATION_STATUS.md
```

**Workflow**:
1. ✅ Marks task 59 as `[IN PROGRESS]` in TODO.md
2. Executes task (updates IMPLEMENTATION_STATUS.md)
3. ✅ Marks task 59 as `[COMPLETE]` in TODO.md
4. Returns completion summary

### Moderate Task (Requires Implementation)
```bash
/task 52    # Fix AesopRules duplicate
```

**Workflow**:
1. ✅ Marks task 52 as `[IN PROGRESS]` in TODO.md
2. Creates implementation plan
3. Recommends: `/implement .opencode/specs/052_fix_aesop_duplicate/plans/implementation-001.md`
4. Status remains `[IN PROGRESS]` until user completes implementation
5. User manually marks complete after verification

### Complex Task (Requires Research + Implementation)
```bash
/task 9     # Begin Completeness Proofs
```

**Workflow**:
1. ✅ Marks task 9 as `[IN PROGRESS]` in TODO.md
2. Conducts research (creates research report)
3. Creates detailed implementation plan
4. Recommends: `/lean .opencode/specs/009_completeness_proofs/plans/implementation-001.md`
5. Status remains `[IN PROGRESS]` until user completes proof development
6. User manually marks complete after verification

## Benefits

### Visibility
- Always know which tasks are actively being worked on
- Clear distinction between "Not Started", "In Progress", and "Complete"
- Timestamps provide historical context

### Coordination
- Prevents duplicate work (can see task is already in progress)
- Team members can see what's being worked on
- Easy to identify stale tasks (started but not completed)

### Automation
- No manual TODO.md updates required for simple tasks
- Consistent status tracking across all task executions
- Reduces human error in status management

### Auditability
- Started and Completed timestamps provide audit trail
- Can track how long tasks took
- Historical record of task progression

## Testing Recommendations

### Unit Tests
1. **Test task matching**: Verify correct task is identified by number
2. **Test status updates**: Verify status changes from "Not Started" → "[IN PROGRESS]" → "[COMPLETE]"
3. **Test timestamp addition**: Verify Started and Completed timestamps are added correctly
4. **Test error handling**: Verify graceful degradation when TODO.md not found or task not found
5. **Test formatting preservation**: Verify all other TODO.md content remains unchanged

### Integration Tests
1. **Test simple task workflow**: Run `/task {number}` for simple task, verify complete lifecycle
2. **Test moderate task workflow**: Run `/task {number}` for moderate task, verify status stays IN PROGRESS
3. **Test complex task workflow**: Run `/task {number}` for complex task, verify research + planning
4. **Test already complete task**: Run `/task {number}` for completed task, verify rejection
5. **Test concurrent tasks**: Start multiple tasks, verify each tracked independently

### Edge Cases
1. **Missing TODO.md**: Verify task execution continues without status tracking
2. **Malformed task section**: Verify graceful handling of unexpected formats
3. **Duplicate task numbers**: Verify first match is used with warning
4. **File permissions**: Verify error handling when TODO.md is read-only
5. **Large TODO.md**: Verify performance with 100+ tasks

## Future Enhancements

### Potential Improvements
1. **Task dependencies**: Automatically check if blocking tasks are complete
2. **Time tracking**: Calculate actual time spent vs. estimated effort
3. **Progress indicators**: Show percentage complete for multi-phase tasks
4. **Notifications**: Alert when tasks are stale (in progress > X days)
5. **Analytics**: Generate reports on task completion rates and times

### Integration Opportunities
1. **Git integration**: Auto-commit TODO.md changes with task updates
2. **Slack/Discord**: Post notifications when tasks start/complete
3. **Dashboard**: Web UI showing current task status
4. **Calendar**: Sync task deadlines with calendar apps
5. **Metrics**: Track velocity and completion trends

## Maintenance Notes

### Updating TODO.md Format
If the TODO.md format changes, update these sections in `task-executor.md`:
- `<task_matching_patterns>`: Update regex patterns
- `<status_patterns>`: Update status field formats
- `<example_transformations>`: Update examples to match new format

### Adding New Status States
To add new status states (e.g., "[BLOCKED]", "[DEFERRED]"):
1. Update `<status_patterns>` in task-executor.md
2. Add handling logic in MarkTaskInProgress and MarkTaskComplete stages
3. Update error handling for new states
4. Add examples to documentation

### Debugging Status Tracking
If status tracking fails:
1. Check TODO.md format matches expected patterns
2. Verify task number exists in TODO.md
3. Check file permissions on TODO.md
4. Review error logs for specific failure messages
5. Test with minimal TODO.md to isolate issue

## References

- **Command File**: `.opencode/command/task.md`
- **Agent File**: `.opencode/agent/subagents/task-executor.md`
- **TODO.md**: `.opencode/specs/TODO.md`
- **Builder Templates**: `context/builder-templates/`

## Changelog

### 2025-12-16 - Initial Implementation
- Added Stage 1 (MarkTaskInProgress) to task-executor workflow
- Added Stage 9 (MarkTaskComplete) to task-executor workflow
- Updated command documentation with status tracking details
- Added comprehensive error handling
- Added task matching patterns and examples
- Updated return format to include status tracking information
- Added principles for automatic status tracking and graceful degradation

---

**Status**: ✅ Implementation Complete  
**Next Steps**: Test with real tasks, gather feedback, iterate based on usage patterns
