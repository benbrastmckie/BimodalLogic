# /task Command Enhancement - Test Plan

**Version**: 1.0  
**Date**: 2026-01-07  
**Status**: Ready for Testing

---

## Test Overview

This document provides a comprehensive test plan for the /task command enhancements. All operations have been implemented in status-sync-manager.md and are ready for testing.

### Implementation Status

| Phase | Operation | Status | Notes |
|-------|-----------|--------|-------|
| Phase 1 | Architecture | ✅ COMPLETE | task.md refactored to Phase 3 standards |
| Phase 2 | --recover | ✅ COMPLETE | unarchive_tasks operation implemented |
| Phase 3 | --divide | 🔧 ARCHITECTURE COMPLETE | Needs task-divider subagent creation |
| Phase 4 | --sync | ✅ COMPLETE | sync_tasks operation with git blame |
| Phase 5 | --abandon | ✅ COMPLETE | Enhanced archive_tasks with force_archive |
| Phase 6 | Context Docs | ✅ COMPLETE | All context files updated |
| Phase 7 | Testing | 🧪 IN PROGRESS | This document |

---

## Test Categories

### 1. Unit Tests (Per Operation)

Test each operation individually with various inputs.

### 2. Integration Tests

Test interactions between operations and backward compatibility.

### 3. Error Handling Tests

Test validation and error cases.

### 4. Performance Tests

Verify operations complete within timeout limits.

---

## Unit Tests

### Test Suite 1: --recover Flag

**Operation**: unarchive_tasks in status-sync-manager

#### Test 1.1: Recover Single Task

```bash
# Setup: Archive a task first
# (Assuming task 350 exists and is completed)

# Test
/task --recover 350

# Expected Results:
# - Task 350 appears in TODO.md with [NOT STARTED] status
# - Task 350 in state.json active_projects
# - Task 350 removed from state.json completed_projects
# - Success message: "✅ Recovered 1 task from archive: 350"
```

**Validation**:
- [ ] Task appears in TODO.md
- [ ] Task status is [NOT STARTED]
- [ ] Task in active_projects
- [ ] Task removed from completed_projects
- [ ] Success message correct

#### Test 1.2: Recover Range

```bash
# Test
/task --recover 343-345

# Expected Results:
# - Tasks 343, 344, 345 recovered
# - All appear in TODO.md with [NOT STARTED]
# - All in active_projects
# - All removed from completed_projects
# - Success message: "✅ Recovered 3 tasks from archive: 343-345"
```

**Validation**:
- [ ] All 3 tasks recovered
- [ ] Range parsing works correctly
- [ ] Atomic update (all or none)

#### Test 1.3: Recover List

```bash
# Test
/task --recover 337, 343-345, 350

# Expected Results:
# - Tasks 337, 343, 344, 345, 350 recovered (5 tasks)
# - Success message includes all task numbers
```

**Validation**:
- [ ] All 5 tasks recovered
- [ ] List parsing works correctly
- [ ] Deduplication works (if any duplicates)

#### Test 1.4: Error - Task Not in Archive

```bash
# Test
/task --recover 999

# Expected Results:
# - Error: "Task 999 not found in completed_projects"
# - No changes to files
```

**Validation**:
- [ ] Clear error message
- [ ] No file modifications
- [ ] Atomic guarantee maintained

#### Test 1.5: Error - Task Already Active

```bash
# Test (assuming task 350 is already active)
/task --recover 350

# Expected Results:
# - Error: "Task 350 already in active_projects"
# - No changes to files
```

**Validation**:
- [ ] Clear error message
- [ ] No file modifications

---

### Test Suite 2: --sync Flag

**Operation**: sync_tasks in status-sync-manager

#### Test 2.1: Sync All Tasks (Default)

```bash
# Setup: Create discrepancy
# - Edit task 343 status in TODO.md, commit
# - Edit task 343 status in state.json, commit (newer)

# Test
/task --sync

# Expected Results:
# - All tasks analyzed
# - Task 343 uses state.json value (newer commit)
# - Conflict resolution logged
# - Success message: "✅ Synced X tasks, resolved Y conflicts"
```

**Validation**:
- [ ] All tasks analyzed
- [ ] Git blame used for conflict resolution
- [ ] Latest commit wins
- [ ] Conflict log included in return

#### Test 2.2: Sync Specific Range

```bash
# Test
/task --sync 343-345

# Expected Results:
# - Only tasks 343, 344, 345 analyzed
# - Other tasks unchanged
```

**Validation**:
- [ ] Only specified tasks synced
- [ ] Other tasks unchanged

#### Test 2.3: Sync List

```bash
# Test
/task --sync 337, 343-345

# Expected Results:
# - Tasks 337, 343, 344, 345 synced
```

**Validation**:
- [ ] List parsing works
- [ ] All specified tasks synced

#### Test 2.4: Git Blame Conflict Resolution

```bash
# Setup: Create multiple conflicts
# - Task 343: status in state.json newer
# - Task 344: priority in TODO.md newer

# Test
/task --sync 343-345

# Expected Results:
# - Task 343: state.json status wins
# - Task 344: TODO.md priority wins
# - Conflict log shows timestamps and winners
```

**Validation**:
- [ ] Git blame timestamps extracted correctly
- [ ] Latest commit wins for each field
- [ ] Tie-breaker uses state.json
- [ ] Conflict log is detailed

#### Test 2.5: Task Only in One File

```bash
# Setup: Task 999 only in TODO.md (never in state.json)

# Test
/task --sync

# Expected Results:
# - Task 999 added to state.json
# - Or removed from TODO.md if recently deleted from state.json
```

**Validation**:
- [ ] Git log checked for deletions
- [ ] Appropriate action taken (add or remove)

---

### Test Suite 3: --abandon Flag

**Operation**: archive_tasks with force_archive in status-sync-manager

#### Test 3.1: Abandon Range

```bash
# Test (tasks can be any status)
/task --abandon 343-345

# Expected Results:
# - Tasks 343, 344, 345 moved to completed_projects
# - Tasks removed from TODO.md
# - Tasks removed from active_projects
# - Success message: "✅ Abandoned 3 tasks: 343-345"
```

**Validation**:
- [ ] Tasks archived regardless of status
- [ ] force_archive parameter works
- [ ] Atomic update

#### Test 3.2: Abandon List

```bash
# Test
/task --abandon 337, 343-345, 350

# Expected Results:
# - 5 tasks abandoned
```

**Validation**:
- [ ] List parsing works
- [ ] All tasks abandoned

#### Test 3.3: Error - Task Not Found

```bash
# Test
/task --abandon 999

# Expected Results:
# - Error: "Task 999 not found in active_projects"
```

**Validation**:
- [ ] Clear error message
- [ ] No file modifications

---

### Test Suite 4: --divide Flag

**Operation**: Task division with task-divider + task-creator

**Note**: This test suite is pending task-divider subagent creation.

#### Test 4.1: Divide Task (Basic)

```bash
# Test
/task --divide 326

# Expected Results:
# - Task 326 analyzed
# - 1-5 subtasks created
# - Parent task dependencies updated
# - Success message lists subtasks
```

**Validation**:
- [ ] Subtasks created
- [ ] Parent dependencies updated
- [ ] Subtask count is 1-5

#### Test 4.2: Divide Task with Prompt

```bash
# Test
/task --divide 326 "Focus on UI, backend, tests"

# Expected Results:
# - Prompt guides division
# - 3 subtasks created (UI, backend, tests)
```

**Validation**:
- [ ] Prompt influences division
- [ ] Subtasks match prompt guidance

#### Test 4.3: Error - Task Not Found

```bash
# Test
/task --divide 999

# Expected Results:
# - Error: "Task 999 not found"
```

**Validation**:
- [ ] Clear error message

#### Test 4.4: Error - Task Already Has Dependencies

```bash
# Test (task 326 already has dependencies)
/task --divide 326

# Expected Results:
# - Error: "Task 326 already has dependencies"
```

**Validation**:
- [ ] Validation prevents re-division

#### Test 4.5: Rollback on Failure

```bash
# Test (simulate failure during subtask creation)

# Expected Results:
# - Created subtasks deleted
# - next_project_number restored
# - Error message with rollback details
```

**Validation**:
- [ ] Rollback mechanism works
- [ ] No partial state

---

### Test Suite 5: Task Creation (Backward Compatibility)

**Operation**: Existing task creation flow

#### Test 5.1: Basic Task Creation

```bash
# Test
/task "Implement feature X"

# Expected Results:
# - Task created with auto-detected language
# - Default priority (Medium)
# - Default effort (TBD)
# - Status [NOT STARTED]
```

**Validation**:
- [ ] Task created successfully
- [ ] Backward compatible

#### Test 5.2: Task Creation with Flags

```bash
# Test
/task "Fix bug in module Y" --priority High --effort "2 hours" --language lean

# Expected Results:
# - Task created with specified metadata
```

**Validation**:
- [ ] All flags work
- [ ] Metadata correct

#### Test 5.3: Inline Division

```bash
# Test
/task "Refactor system: update commands, fix agents, improve docs" --divide

# Expected Results:
# - 3 tasks created
# - Each task is separate (not parent/child)
```

**Validation**:
- [ ] Inline division works
- [ ] Multiple tasks created

---

## Integration Tests

### Test Suite 6: Flag Combinations

#### Test 6.1: Multiple Flags (Should Error)

```bash
# Test
/task --recover 343 --divide 344

# Expected Results:
# - Error: "Only one flag allowed at a time"
# - No operations performed
```

**Validation**:
- [ ] Single flag enforcement works
- [ ] Clear error message

#### Test 6.2: Flag with Task Creation (Should Error)

```bash
# Test
/task "description" --recover 343

# Expected Results:
# - Error: "Cannot combine task creation with flags"
```

**Validation**:
- [ ] Validation prevents invalid combinations

---

### Test Suite 7: Workflow Tests

#### Test 7.1: Complete Lifecycle

```bash
# 1. Create task
/task "Test task for lifecycle"
# → Task 500 created

# 2. Abandon task
/task --abandon 500
# → Task 500 archived

# 3. Recover task
/task --recover 500
# → Task 500 recovered

# 4. Divide task
/task --divide 500
# → Subtasks 501, 502, 503 created

# 5. Sync tasks
/task --sync 500-503
# → All tasks synchronized
```

**Validation**:
- [ ] Complete lifecycle works
- [ ] Each operation succeeds
- [ ] State remains consistent

---

## Error Handling Tests

### Test Suite 8: Validation Errors

#### Test 8.1: Invalid Range Format

```bash
# Test
/task --recover 343-

# Expected Results:
# - Error: "Invalid range format: 343-"
```

**Validation**:
- [ ] Range parsing validation works

#### Test 8.2: Empty Arguments

```bash
# Test
/task --recover

# Expected Results:
# - Error: "Missing required arguments for --recover"
```

**Validation**:
- [ ] Required argument validation works

#### Test 8.3: Invalid Task Number

```bash
# Test
/task --recover abc

# Expected Results:
# - Error: "Task number must be positive integer"
```

**Validation**:
- [ ] Type validation works

---

## Performance Tests

### Test Suite 9: Performance

#### Test 9.1: Single Task Operations

```bash
# Test each operation with single task
# Measure execution time

# Expected Results:
# - All operations complete in < 5 seconds
```

**Validation**:
- [ ] --recover: < 5s
- [ ] --sync: < 5s
- [ ] --abandon: < 5s
- [ ] --divide: < 10s (more complex)

#### Test 9.2: Bulk Operations

```bash
# Test with 10 tasks
/task --recover 340-349

# Expected Results:
# - Completes in < 30 seconds
```

**Validation**:
- [ ] Bulk operations scale reasonably
- [ ] No timeout issues

#### Test 9.3: Sync All Tasks

```bash
# Test with all tasks in system
/task --sync

# Expected Results:
# - Completes within 120s timeout
```

**Validation**:
- [ ] Sync all completes within timeout
- [ ] Performance acceptable

---

## Test Execution Checklist

### Pre-Testing

- [ ] Backup TODO.md and state.json
- [ ] Create test tasks in archive (for --recover tests)
- [ ] Create test tasks with discrepancies (for --sync tests)
- [ ] Document current state

### During Testing

- [ ] Execute each test suite in order
- [ ] Document results (pass/fail)
- [ ] Capture error messages
- [ ] Note any unexpected behavior
- [ ] Check git status after each test

### Post-Testing

- [ ] Verify no data corruption
- [ ] Check git log for commits
- [ ] Restore backup if needed
- [ ] Document issues found
- [ ] Create bug reports for failures

---

## Test Results Template

```markdown
## Test Results - [Date]

### Test Suite 1: --recover Flag
- Test 1.1: ✅ PASS
- Test 1.2: ✅ PASS
- Test 1.3: ❌ FAIL - [Description of failure]
- Test 1.4: ✅ PASS
- Test 1.5: ✅ PASS

### Test Suite 2: --sync Flag
- Test 2.1: ✅ PASS
- ...

### Issues Found
1. [Issue description]
   - Severity: High/Medium/Low
   - Steps to reproduce
   - Expected vs actual behavior

### Overall Status
- Tests Passed: X / Y
- Tests Failed: Z
- Pass Rate: XX%
```

---

## Known Limitations

1. **Git Commit Integration**: Operations don't automatically create git commits yet (requires git-workflow-manager integration)
2. **task-divider Subagent**: Needs to be created for --divide flag
3. **archive/state.json**: Current implementation uses completed_projects in state.json instead of separate archive/state.json file
4. **Directory Moves**: Directory moves are best-effort (non-critical failures logged but don't fail operation)

---

## Next Steps

1. **Execute Test Suites**: Run all tests systematically
2. **Document Results**: Record pass/fail for each test
3. **Fix Issues**: Address any failures found
4. **Create task-divider**: Implement subagent for --divide flag
5. **Git Integration**: Add git-workflow-manager integration
6. **Performance Optimization**: If any performance issues found
7. **Documentation**: Update user guide with examples

---

**Status**: Test plan complete, ready for execution  
**Estimated Testing Time**: 4-6 hours  
**Priority**: High (validates all implementations)
