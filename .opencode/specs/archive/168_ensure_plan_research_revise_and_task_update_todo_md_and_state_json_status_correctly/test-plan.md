# Test Plan: Status Synchronization Across Commands

**Project**: #168
**Date**: 2025-12-24
**Status**: [NOT STARTED]

## Overview

This test plan validates that /plan, /research, /revise, and /task commands correctly update TODO.md, state.json, and plan files atomically using the status-sync-manager specialist.

## Test Scenarios

### Test 1: /plan Command Status Synchronization

**Objective**: Verify /plan updates TODO.md, state.json, project state.json, and plan file atomically

**Setup**:
1. Create test task in TODO.md with status [NOT STARTED]
2. Ensure task has no existing plan

**Steps**:
1. Run `/plan {task_number}`
2. Verify preflight updates:
   - TODO.md status → [IN PROGRESS]
   - TODO.md **Started** field added with current date
   - state.json status → "in_progress"
   - state.json started field added with current date
3. Verify postflight updates:
   - TODO.md status → [PLANNED]
   - TODO.md **Completed** field added with current date
   - TODO.md plan link added
   - state.json status → "planned"
   - state.json completed field added
   - state.json phase → "planning"
   - Project state.json created with status "planned"
   - Plan file header status → [PLANNED]
   - Plan file **Completed** timestamp added

**Expected Result**: All files updated atomically with [PLANNED] status

**Validation**:
- [ ] TODO.md status is [PLANNED]
- [ ] state.json status is "planned"
- [ ] Project state.json status is "planned"
- [ ] Plan file header status is [PLANNED]
- [ ] All timestamps are present and correct (YYYY-MM-DD format)
- [ ] No partial updates (all files updated or none)

---

### Test 2: /research Command Status Synchronization

**Objective**: Verify /research updates TODO.md and state.json atomically (no plan file)

**Setup**:
1. Create test task in TODO.md with status [NOT STARTED]
2. Ensure task has no existing research

**Steps**:
1. Run `/research {task_number}`
2. Verify preflight updates:
   - TODO.md status → [IN PROGRESS]
   - TODO.md **Started** field added
   - state.json status → "in_progress"
   - state.json started field added
3. Verify postflight updates:
   - TODO.md status → [RESEARCHED]
   - TODO.md **Completed** field added
   - TODO.md research link added
   - state.json status → "researched"
   - state.json completed field added
   - Project state.json created with status "researched"

**Expected Result**: TODO.md and state.json updated atomically with [RESEARCHED] status

**Validation**:
- [ ] TODO.md status is [RESEARCHED]
- [ ] state.json status is "researched"
- [ ] Project state.json status is "researched"
- [ ] All timestamps are present and correct
- [ ] No plan file created (research doesn't create plans)

---

### Test 3: /revise Command Status Preservation

**Objective**: Verify /revise preserves task status and updates files atomically

**Setup**:
1. Create test task with status [PLANNED]
2. Ensure task has existing plan file

**Steps**:
1. Run `/revise {task_number} "Test revision"`
2. Verify status preservation:
   - TODO.md status remains [PLANNED]
   - state.json status remains "planned"
3. Verify updates:
   - TODO.md plan link updated to new version
   - TODO.md revision timestamp added
   - state.json plan_version incremented
   - state.json last_updated timestamp updated
   - Project state.json plans array includes new plan
   - New plan file created with [NOT STARTED] status
   - Old plan file marked as superseded

**Expected Result**: Status preserved, plan version incremented, all files updated atomically

**Validation**:
- [ ] TODO.md status unchanged (still [PLANNED])
- [ ] state.json status unchanged (still "planned")
- [ ] New plan file created with [NOT STARTED]
- [ ] Old plan file marked as superseded
- [ ] All timestamps updated correctly

---

### Test 4: /task Command Status Synchronization

**Objective**: Verify /task updates TODO.md, state.json, and plan file atomically

**Setup**:
1. Create test task with status [PLANNED]
2. Ensure task has existing plan file

**Steps**:
1. Run `/task {task_number}`
2. Verify preflight updates:
   - TODO.md status → [IN PROGRESS] (if not already)
   - Plan file header status → [IN PROGRESS]
   - state.json status → "in_progress"
3. Verify postflight updates:
   - TODO.md status → [COMPLETED]
   - TODO.md [PASS] added to title
   - TODO.md **Completed** field added
   - state.json status → "completed"
   - state.json completed field added
   - Plan file header status → [COMPLETED]
   - Plan file **Completed** timestamp added

**Expected Result**: All files updated atomically with [COMPLETED] status

**Validation**:
- [ ] TODO.md status is [COMPLETED]
- [ ] TODO.md title has [PASS]
- [ ] state.json status is "completed"
- [ ] Plan file header status is [COMPLETED]
- [ ] All timestamps are present and correct

---

### Test 5: Rollback on Partial Failure

**Objective**: Verify rollback mechanism restores files on write failure

**Setup**:
1. Create test task with status [NOT STARTED]
2. Simulate write failure (e.g., make state.json read-only)

**Steps**:
1. Run `/plan {task_number}`
2. Verify rollback:
   - TODO.md restored to original state
   - state.json unchanged (write failed)
   - No plan file created
   - Error message returned

**Expected Result**: All files restored to original state, clear error message

**Validation**:
- [ ] TODO.md status still [NOT STARTED]
- [ ] state.json unchanged
- [ ] No plan file created
- [ ] Error message indicates which file failed
- [ ] Rollback successful

---

### Test 6: Invalid Status Transitions Rejected

**Objective**: Verify invalid status transitions are rejected

**Setup**:
1. Create test task with status [COMPLETED]

**Steps**:
1. Attempt to run `/plan {task_number}`
2. Verify rejection:
   - Error message: "Invalid status transition: [COMPLETED] → [IN PROGRESS]"
   - No files modified
   - Clear error message

**Expected Result**: Invalid transition rejected, no files modified

**Validation**:
- [ ] TODO.md status still [COMPLETED]
- [ ] state.json unchanged
- [ ] Error message clear and actionable
- [ ] No partial updates

---

### Test 7: Lazy Directory Creation Preserved

**Objective**: Verify status updates don't create directories

**Setup**:
1. Create test task with status [NOT STARTED]
2. Ensure no project directory exists

**Steps**:
1. Update task status to [IN PROGRESS] (status-only update)
2. Verify no directories created:
   - No project root directory
   - No plans/ subdirectory
   - No reports/ subdirectory

**Expected Result**: Status updated, no directories created

**Validation**:
- [ ] TODO.md status is [IN PROGRESS]
- [ ] state.json status is "in_progress"
- [ ] No project directory created
- [ ] Lazy creation preserved

---

### Test 8: Concurrent Update Handling

**Objective**: Verify file locking prevents concurrent update corruption

**Setup**:
1. Create test task with status [NOT STARTED]

**Steps**:
1. Simulate two concurrent `/plan` commands on same task
2. Verify file locking:
   - One command succeeds
   - Other command waits or fails gracefully
   - No file corruption
   - Final state is consistent

**Expected Result**: File locking prevents corruption, final state is consistent

**Validation**:
- [ ] No file corruption
- [ ] Final state is consistent
- [ ] One command succeeds
- [ ] Other command handled gracefully

---

### Test 9: Field Naming Consistency

**Objective**: Verify all timestamp fields use standardized naming (no `_at` suffix)

**Setup**:
1. Create test task and run through full workflow

**Steps**:
1. Run `/research {task_number}`
2. Run `/plan {task_number}`
3. Run `/task {task_number}`
4. Verify field naming in state.json:
   - `started` (NOT `started_at`)
   - `completed` (NOT `completed_at`)
   - `researched` (NOT `researched_at`)
   - `planned` (NOT `planned_at`)

**Expected Result**: All timestamp fields use standardized naming

**Validation**:
- [ ] state.json uses `started` not `started_at`
- [ ] state.json uses `completed` not `completed_at`
- [ ] state.json uses `researched` not `researched_at`
- [ ] state.json uses `planned` not `planned_at`
- [ ] Consistent across all state files

---

### Test 10: Batch Task Execution Status Sync

**Objective**: Verify batch task execution updates status correctly for all tasks

**Setup**:
1. Create 3 test tasks with status [PLANNED]
2. Ensure all have plan files

**Steps**:
1. Run `/task {task1},{task2},{task3}`
2. Verify wave-based execution:
   - All tasks marked [IN PROGRESS] at wave start
   - All tasks marked [COMPLETED] at wave end
   - All state files updated atomically
   - All plan files updated

**Expected Result**: All tasks updated atomically in waves

**Validation**:
- [ ] All TODO.md entries updated to [COMPLETED]
- [ ] All state.json entries updated to "completed"
- [ ] All plan files updated to [COMPLETED]
- [ ] Wave-based execution preserved
- [ ] Atomic updates per task

---

## Test Execution Checklist

### Pre-Execution
- [ ] Backup TODO.md and state.json
- [ ] Create test tasks in TODO.md
- [ ] Document initial state

### Execution
- [ ] Run Test 1: /plan command
- [ ] Run Test 2: /research command
- [ ] Run Test 3: /revise command
- [ ] Run Test 4: /task command
- [ ] Run Test 5: Rollback on failure
- [ ] Run Test 6: Invalid transitions
- [ ] Run Test 7: Lazy directory creation
- [ ] Run Test 8: Concurrent updates
- [ ] Run Test 9: Field naming consistency
- [ ] Run Test 10: Batch execution

### Post-Execution
- [ ] Restore TODO.md and state.json from backup
- [ ] Document test results
- [ ] Report any failures
- [ ] Update implementation if needed

## Success Criteria

All tests must pass with:
- [PASS] Atomic updates across all files
- [PASS] Correct status transitions
- [PASS] Proper timestamp formats
- [PASS] Rollback on failures
- [PASS] Lazy directory creation preserved
- [PASS] Field naming consistency
- [PASS] No file corruption

## Test Results

| Test | Status | Notes |
|------|--------|-------|
| Test 1: /plan | ⏳ Pending | |
| Test 2: /research | ⏳ Pending | |
| Test 3: /revise | ⏳ Pending | |
| Test 4: /task | ⏳ Pending | |
| Test 5: Rollback | ⏳ Pending | |
| Test 6: Invalid transitions | ⏳ Pending | |
| Test 7: Lazy creation | ⏳ Pending | |
| Test 8: Concurrent updates | ⏳ Pending | |
| Test 9: Field naming | ⏳ Pending | |
| Test 10: Batch execution | ⏳ Pending | |

## Notes

- Tests should be run in a test environment, not production
- Backup all files before testing
- Document any unexpected behavior
- Update implementation based on test results
