# /task Command Enhancement Summary

**Version**: 2.0  
**Date**: 2026-01-07  
**Status**: Ready for Implementation

---

## Quick Reference

### Command Syntax

```bash
# Task Creation (existing)
/task "description" [--priority PRIORITY] [--effort EFFORT] [--language LANG] [--divide]

# Recovery (NEW - bulk support)
/task --recover TASK_RANGES              # Examples: 350, 343-345, 337,343-345

# Division (NEW - single task)
/task --divide TASK_NUMBER [PROMPT]      # Example: /task --divide 326 "Focus on phases"

# Synchronization (NEW - git blame conflict resolution)
/task --sync [TASK_RANGES]               # Examples: (no args = all), 343-345, 337,343-345

# Abandonment (NEW - bulk support)
/task --abandon TASK_RANGES              # Examples: 343-345, 337,343-345,350
```

---

## Key Features

### 1. Bulk Operations

**Flags with Bulk Support**: --recover, --sync, --abandon

**Range Syntax**:
- Single task: `350`
- Range: `343-345` (expands to 343, 344, 345)
- List: `337, 343-345, 350` (expands to 337, 343, 344, 345, 350)

**Benefits**:
- Efficient multi-task operations
- Atomic updates (all tasks or none)
- Single git commit for all changes

### 2. Git Blame Conflict Resolution

**Flag**: --sync

**How It Works**:
1. Compares TODO.md and state.json for each task
2. Identifies discrepancies in fields (status, priority, effort, etc.)
3. Uses `git blame` to determine which version is newer
4. Applies the version with the latest commit timestamp
5. Logs all conflict resolutions

**Example**:
```bash
# Task 343 has different status in TODO.md vs state.json
# TODO.md: [IN PROGRESS] (committed 2026-01-07 10:00:00)
# state.json: [RESEARCHED] (committed 2026-01-07 11:00:00)

/task --sync 343

# Result: Uses state.json version (newer commit)
# Log: "Task 343 field 'status': state.json (11:00:00) > TODO.md (10:00:00) → state.json wins"
```

**Default Behavior**:
```bash
/task --sync  # No arguments = sync ALL tasks
```

### 3. Single Task Division

**Flag**: --divide

**How It Works**:
1. Analyzes existing task description for natural divisions
2. Creates 1-5 subtasks based on analysis
3. Updates parent task with subtask dependencies
4. Includes rollback on partial failure

**Example**:
```bash
/task --divide 326 "Focus on implementation phases"

# Creates subtasks:
# - Task 327: Phase 1 - Architecture
# - Task 328: Phase 2 - Implementation
# - Task 329: Phase 3 - Testing
# Updates task 326 dependencies: [327, 328, 329]
```

**Note**: No bulk support (operates on single task only)

---

## Architectural Alignment

### Phase 3 Standards Maintained

✅ **Agent Field**: Changed to `orchestrator` (not `status-sync-manager`)  
✅ **Separation of Concerns**: Command orchestrates, subagents execute  
✅ **Validation Gates**: Added at critical points for all operations  
✅ **Minimal Inline Logic**: Complex operations delegated to subagents  
✅ **Explicit Return Format**: Task numbers only, validated  

### Enhanced Architecture

```
Stage 1: ParseAndValidate → Route based on flag
Stage 2: PrepareTasks (if no flag or inline --divide)
Stage 3: CreateTasks (if no flag)
Stage 4: RecoverTasks (if --recover) ← BULK SUPPORT
Stage 5: DivideExistingTask (if --divide TASK_NUMBER) ← SINGLE TASK
Stage 6: SyncTasks (if --sync) ← BULK SUPPORT + GIT BLAME
Stage 7: AbandonTasks (if --abandon) ← BULK SUPPORT
Stage 8: ReturnSuccess (all operations)
```

---

## Implementation Phases

### Phase 1: Architecture Update (3-4 hours)
- Refactor task.md to Phase 3 standards
- Add flag routing logic
- Add validation gates

### Phase 2: --recover with Bulk Support (8-10 hours)
- Parse task ranges
- Implement unarchive_tasks operation (bulk)
- Add range parsing logic
- Add git commit integration

### Phase 3: --divide for Existing Tasks (8-10 hours)
- Analyze existing task descriptions
- Create subtasks with dependencies
- Add rollback mechanism
- Add git commit integration

### Phase 4: --sync with Git Blame (10-12 hours)
- Implement git blame conflict resolution
- Support "all tasks" default behavior
- Add range parsing logic
- Add git commit integration

### Phase 5: --abandon with Bulk Support (4-6 hours)
- Reuse existing archive_tasks operation
- Add range parsing logic
- Add git commit integration

### Phase 6: Testing and Documentation (6-8 hours)
- Comprehensive test suite
- Documentation updates
- Performance testing
- Migration guide

**Total Estimated Effort**: 39-50 hours

---

## Key Differences from v1.0

### Changes in v2.0

1. **--recover**: Changed from single task to bulk support
   - v1.0: `/task --recover TASK_NUMBER`
   - v2.0: `/task --recover TASK_RANGES`
   - Effort: 6-8h → 8-10h

2. **--sync**: Added git blame conflict resolution
   - v1.0: Used state.json as source of truth
   - v2.0: Uses git blame to determine latest version
   - Default: Syncs ALL tasks when no ranges specified
   - Effort: 6-8h → 10-12h

3. **--divide**: No changes (single task only)
   - Effort: 8-10h (unchanged)

4. **--abandon**: No changes (already had bulk support)
   - Effort: 4-6h (unchanged)

5. **Testing**: Increased for additional test cases
   - Effort: 4-6h → 6-8h

**Total Effort**: 31-42h → 39-50h

---

## Usage Examples

### Example 1: Recover Multiple Archived Tasks
```bash
# Archive tasks
/todo --archive 350-352

# Recover them
/task --recover 350-352

# Result:
# - Tasks 350, 351, 352 unarchived
# - All appear in TODO.md with [NOT STARTED] status
# - All appear in state.json active_projects
# - All removed from archive/state.json
# - Git commit: "task: recover 3 tasks from archive (350-352)"
```

### Example 2: Sync All Tasks with Conflict Resolution
```bash
# Manually edit TODO.md and state.json (introduce conflicts)
# Task 343: status=[IN PROGRESS] in TODO.md (older)
# Task 343: status=[RESEARCHED] in state.json (newer)

# Sync all tasks
/task --sync

# Result:
# - ALL tasks synchronized
# - Task 343 uses state.json status (newer via git blame)
# - Conflict resolution logged
# - Git commit: "task: sync TODO.md and state.json for 1 task (343)"
```

### Example 3: Divide Task into Subtasks
```bash
# Create a complex task
/task "Implement feature X: add UI, add backend, add tests"

# Divide it
/task --divide 351

# Result:
# - Task 352: "Implement feature X (1/3): Add UI"
# - Task 353: "Implement feature X (2/3): Add backend"
# - Task 354: "Implement feature X (3/3): Add tests"
# - Task 351 dependencies: [352, 353, 354]
# - Git commit: "task: divide task 351 into 3 subtasks (352-354)"
```

### Example 4: Abandon Multiple Tasks
```bash
# Abandon tasks
/task --abandon 343-345, 350

# Result:
# - Tasks 343, 344, 345, 350 moved to archive/
# - TODO.md and state.json updated
# - archive/state.json updated
# - Git commit: "task: abandon 4 tasks (343-345, 350)"
```

---

## Git Blame Conflict Resolution Details

### Algorithm

1. **Identify Discrepancies**: Compare TODO.md vs state.json for each field
2. **Get Timestamps**: Use `git blame` to find last commit for each field
3. **Resolve Conflicts**: Choose version with latest commit timestamp
4. **Apply Changes**: Update both files with resolved values
5. **Log Results**: Record all conflict resolutions

### Example Log

```
Task 343: 3 fields resolved
  - status: state.json (2026-01-07 11:00:00) > TODO.md (2026-01-07 10:00:00) → state.json wins
  - priority: TODO.md (2026-01-07 12:00:00) > state.json (2026-01-07 09:00:00) → TODO.md wins
  - effort: timestamps equal → state.json wins (tie-breaker)

Summary: 1 task synced, 3 conflicts resolved
```

### Edge Cases

- **Task only in TODO.md**: Check git log for deletion, add to state.json if never existed
- **Task only in state.json**: Check git log for deletion, add to TODO.md if never existed
- **Multiple fields differ**: Resolve each field independently
- **Git blame fails**: Fallback to state.json as source of truth

---

## Success Metrics

### Quantitative
- **Flag Success Rate**: 100% for valid inputs
- **Atomic Update Success**: 100% (all files updated or none)
- **Git Commit Success**: >95% (non-critical failures acceptable)
- **Error Detection Rate**: 100% for invalid inputs
- **Performance**: <120s per operation, <5s for single task operations

### Qualitative
- **User Experience**: Clear error messages, predictable behavior
- **Code Quality**: Follows Phase 3 patterns, well-documented
- **Maintainability**: Easy to extend
- **Reliability**: Atomic updates prevent data corruption
- **Consistency**: All flags follow same architectural pattern

---

## Next Steps

1. **Review Plan**: Ensure all stakeholders agree with approach
2. **Begin Phase 1**: Update task.md architecture to Phase 3 standards
3. **Implement Phases 2-5**: Add flags incrementally
4. **Test Thoroughly**: Run comprehensive test suite
5. **Update Documentation**: Ensure all docs reflect new capabilities
6. **Deploy**: Roll out to production

---

**Plan Location**: `.opencode/specs/TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md`  
**Version**: 2.0  
**Last Updated**: 2026-01-07
