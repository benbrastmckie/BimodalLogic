# Batch Task Execution - Testing Guide

**Project**: #072
**Date**: 2025-12-19

---

## Quick Start

### Test Single Task (Backward Compatibility)
```bash
/task 63
```
**Expected**: Existing behavior - routes to task-executor, marks IN PROGRESS, creates plan

---

### Test Simple Batch (No Dependencies)
```bash
/task 63, 64, 65
```
**Expected**: All tasks execute in Wave 1 (parallel)

---

### Test Range Syntax
```bash
/task 65-67
```
**Expected**: Expands to [65, 66, 67], executes based on dependencies

---

### Test Mixed Syntax
```bash
/task 63, 65-67, 88
```
**Expected**: Expands to [63, 65, 66, 67, 88], executes based on dependencies

---

## Comprehensive Test Suite

### Test 1: Input Parsing

**Test 1.1: Single Task**
```bash
/task 63
```
**Expected**: Parse to [63], route to task-executor

---

**Test 1.2: Task List**
```bash
/task 63, 64, 65
```
**Expected**: Parse to [63, 64, 65], route to batch-task-orchestrator

---

**Test 1.3: Task Range**
```bash
/task 65-67
```
**Expected**: Parse to [65, 66, 67], route to batch-task-orchestrator

---

**Test 1.4: Mixed Format**
```bash
/task 63, 65-67, 88
```
**Expected**: Parse to [63, 65, 66, 67, 88], route to batch-task-orchestrator

---

**Test 1.5: Invalid Range (start > end)**
```bash
/task 67-65
```
**Expected**: Error message: "Invalid range: 67-65. Start must be less than or equal to end."

---

**Test 1.6: Incomplete Range**
```bash
/task 63-
```
**Expected**: Error message: "Invalid range format: '63-'. Expected format: 'start-end' (e.g., '65-67')"

---

**Test 1.7: Non-Numeric Input**
```bash
/task abc
```
**Expected**: Error message: "Invalid task number: 'abc'. Task numbers must be positive integers."

---

**Test 1.8: Empty Input**
```bash
/task
```
**Expected**: Error message: "No task number provided. Usage: /task <number> or /task <list> or /task <range>"

---

### Test 2: Dependency Analysis

**Test 2.1: No Dependencies**
```bash
# Setup: Tasks 63, 64, 65 have no dependencies
/task 63, 64, 65
```
**Expected**:
- Dependency graph: No edges
- Execution plan: Wave 1: [63, 64, 65]

---

**Test 2.2: Linear Dependencies**
```bash
# Setup: 64 depends on 63, 65 depends on 64
/task 63, 64, 65
```
**Expected**:
- Dependency graph: 63→64→65
- Execution plan:
  - Wave 1: [63]
  - Wave 2: [64]
  - Wave 3: [65]

---

**Test 2.3: Parallel Dependencies**
```bash
# Setup: 64 depends on 63, 65 depends on 63
/task 63, 64, 65
```
**Expected**:
- Dependency graph: 63→64, 63→65
- Execution plan:
  - Wave 1: [63]
  - Wave 2: [64, 65]

---

**Test 2.4: Diamond Dependencies**
```bash
# Setup: 64→63, 65→63, 66→64, 66→65
/task 63, 64, 65, 66
```
**Expected**:
- Dependency graph: 63→64, 63→65, 64→66, 65→66
- Execution plan:
  - Wave 1: [63]
  - Wave 2: [64, 65]
  - Wave 3: [66]

---

**Test 2.5: Circular Dependency**
```bash
# Setup: 63→64→65→63 (cycle)
/task 63, 64, 65
```
**Expected**:
- Error: "Circular dependency detected"
- Cycle path: [63, 64, 65, 63]
- Abort execution

---

**Test 2.6: External Dependency (Complete)**
```bash
# Setup: Task 65 depends on Task 64 (not in batch, already complete)
/task 65, 66, 67
```
**Expected**:
- Info: "Task 65 depends on task 64 which is not in batch but is marked complete"
- Execution proceeds normally

---

**Test 2.7: External Dependency (Not Complete)**
```bash
# Setup: Task 65 depends on Task 64 (not in batch, not complete)
/task 65, 66, 67
```
**Expected**:
- Warning: "Task 65 depends on task 64 which is not in batch and is not complete"
- Recommendation: "Consider running /task 64 first"
- Execution proceeds (may fail if dependency truly needed)

---

### Test 3: Wave Execution

**Test 3.1: Single Wave (All Parallel)**
```bash
# Setup: Tasks 63, 64, 65 have no dependencies
/task 63, 64, 65
```
**Expected**:
- Wave 1: Execute 63, 64, 65 in parallel
- All tasks start simultaneously
- All tasks complete
- TODO.md updated atomically

---

**Test 3.2: Multiple Waves (Sequential)**
```bash
# Setup: 64→63, 65→64
/task 63, 64, 65
```
**Expected**:
- Wave 1: Execute 63
- Wait for Wave 1 completion
- Wave 2: Execute 64
- Wait for Wave 2 completion
- Wave 3: Execute 65
- Each wave updates TODO.md atomically

---

**Test 3.3: Large Wave (Concurrency Limit)**
```bash
# Setup: Tasks 63-70 have no dependencies (8 tasks)
/task 63-70
```
**Expected**:
- Wave 1 split into batches:
  - Batch 1: Execute 63-67 (5 tasks, max concurrency)
  - Wait for Batch 1 completion
  - Batch 2: Execute 68-70 (3 tasks)
- All tasks complete

---

### Test 4: Error Handling

**Test 4.1: Task Not Found**
```bash
# Setup: Task 999 doesn't exist
/task 63, 999, 65
```
**Expected**:
- Warning: "Task 999 not found in TODO.md - excluding from batch"
- Execute tasks 63, 65 only
- Summary shows skipped task 999

---

**Test 4.2: Task Already Complete**
```bash
# Setup: Task 64 already marked [COMPLETE] ✅
/task 63, 64, 65
```
**Expected**:
- Info: "Task 64 already complete - skipping"
- Execute tasks 63, 65 only
- Summary shows skipped task 64

---

**Test 4.3: Task Execution Failure**
```bash
# Setup: Task 64 will fail (e.g., file not found)
/task 63, 64, 65
```
**Expected**:
- Task 63 completes
- Task 64 fails with error message
- Task 65 executes (if no dependency on 64)
- Summary shows 1 failed task
- TODO.md marks task 64 as [FAILED]

---

**Test 4.4: Task Execution Failure with Blocking**
```bash
# Setup: 65→64, Task 64 will fail
/task 63, 64, 65
```
**Expected**:
- Task 63 completes
- Task 64 fails
- Task 65 blocked (depends on 64)
- Summary shows 1 failed, 1 blocked
- TODO.md marks task 64 as [FAILED], task 65 as [BLOCKED]

---

**Test 4.5: Task Timeout**
```bash
# Setup: Task 64 takes >1 hour
/task 63, 64, 65
```
**Expected**:
- Task 63 completes
- Task 64 times out after 1 hour
- Task 64 marked as [FAILED] with timeout reason
- Task 65 blocked if depends on 64

---

**Test 4.6: TODO.md Update Failure**
```bash
# Setup: TODO.md is read-only
/task 63, 64, 65
```
**Expected**:
- Warning: "Failed to update TODO.md: Permission denied"
- Task execution continues
- Summary shows TODO.md update failed
- Recommendation: "Manually update TODO.md"

---

### Test 5: Status Tracking

**Test 5.1: Mark IN PROGRESS (Wave Start)**
```bash
/task 63, 64, 65
```
**Expected**:
- Before Wave 1: All tasks "Not Started"
- Wave 1 start: All tasks marked [IN PROGRESS] with timestamp
- Single atomic write to TODO.md

---

**Test 5.2: Mark COMPLETE (Wave End)**
```bash
# Setup: All tasks are simple and execute directly
/task 63, 64, 65
```
**Expected**:
- Wave 1 end: All tasks marked [COMPLETE] with timestamp
- ✅ added to task titles
- Single atomic write to TODO.md

---

**Test 5.3: Mark FAILED (Task Failure)**
```bash
# Setup: Task 64 fails
/task 63, 64, 65
```
**Expected**:
- Task 64 marked [FAILED] with timestamp and failure reason
- Other tasks marked [COMPLETE] or [BLOCKED]
- Single atomic write to TODO.md

---

**Test 5.4: Mark BLOCKED (Dependency Failure)**
```bash
# Setup: 65→64, Task 64 fails
/task 63, 64, 65
```
**Expected**:
- Task 65 marked [BLOCKED] with timestamp and blocking reason
- Blocking reason: "Blocked by failed task 64"
- Single atomic write to TODO.md

---

### Test 6: Progress Reporting

**Test 6.1: Execution Plan Display**
```bash
/task 63, 64, 65, 66, 67
```
**Expected**:
```
## Batch Task Execution: Tasks 63, 64, 65, 66, 67

### Dependency Analysis
**Tasks to Execute**: 5 tasks
**Dependency Graph**: {visualization}
**Execution Plan**:
  - Wave 1 (2 tasks, parallel): 63, 88
  - Wave 2 (2 tasks, parallel): 64, 65
  - Wave 3 (1 task): 66
```

---

**Test 6.2: Wave Progress**
```bash
/task 63, 64, 65
```
**Expected**:
```
### Wave 1 Execution (3 tasks in parallel)

Executing tasks 63, 64, 65...

✅ Task 63 Complete: {title}
   - Artifacts: {path}
   - Summary: {link}

✅ Task 64 Complete: {title}
   ...

✅ Task 65 Complete: {title}
   ...

**Wave 1 Results**: 3/3 complete ✅
```

---

**Test 6.3: Final Summary**
```bash
/task 63, 64, 65, 66, 67
```
**Expected**:
```
### Batch Execution Summary

**Total Tasks**: 5
**Completed**: 4 ✅
**Failed**: 1 ❌
**Blocked**: 0

**Execution Time**:
  - Wave 1: 10m
  - Wave 2: 8m
  - Total: 18m

**TODO.md Updated**: All tasks marked ✅

**Failed Tasks**:
  ❌ Task 64: {title}
     Error: {error}
     Recommendation: {fix}

**Next Steps**:
  - Fix task 64 and re-run: /task 64
  - Continue with: /implement {path}
```

---

## Edge Cases

### Edge Case 1: Single Task in Batch
```bash
/task 63,
```
**Expected**: Parse to [63], route to batch-task-orchestrator (not task-executor)
**Note**: Technically batch mode but only 1 task

---

### Edge Case 2: Duplicate Tasks
```bash
/task 63, 64, 63, 65
```
**Expected**: Parse to [63, 64, 65] (duplicates removed)

---

### Edge Case 3: Unsorted Tasks
```bash
/task 65, 63, 67, 64
```
**Expected**: Parse to [63, 64, 65, 67] (sorted)

---

### Edge Case 4: All Tasks Already Complete
```bash
# Setup: All tasks already complete
/task 63, 64, 65
```
**Expected**: Error: "No valid tasks to execute. All tasks are already complete."

---

### Edge Case 5: All Tasks Not Found
```bash
/task 999, 998, 997
```
**Expected**: Error: "No valid tasks to execute. All tasks not found in TODO.md."

---

### Edge Case 6: Self-Dependency
```bash
# Setup: Task 64 depends on 64 (self)
/task 64
```
**Expected**: Error: "Circular dependency detected: [64, 64]"

---

## Performance Tests

### Performance Test 1: Small Batch (5 tasks)
```bash
/task 63-67
```
**Expected**: Complete in <30 seconds (excluding task execution time)

---

### Performance Test 2: Medium Batch (20 tasks)
```bash
/task 63-82
```
**Expected**: Complete in <2 minutes (excluding task execution time)

---

### Performance Test 3: Large Batch (50 tasks)
```bash
/task 1-50
```
**Expected**: Complete in <5 minutes (excluding task execution time)

---

## Regression Tests

### Regression Test 1: Single Task Unchanged
```bash
/task 63
```
**Expected**: Identical behavior to pre-batch implementation

---

### Regression Test 2: TODO.md Format Preserved
```bash
/task 63, 64, 65
```
**Expected**: TODO.md formatting unchanged except for status/timestamp fields

---

### Regression Test 3: Error Messages Consistent
```bash
/task 999
```
**Expected**: Same error message as pre-batch implementation

---

## Manual Verification Checklist

After running tests, manually verify:

- [ ] TODO.md status fields updated correctly
- [ ] TODO.md timestamps added correctly
- [ ] TODO.md formatting preserved (no extra spaces, line breaks, etc.)
- [ ] Task artifacts created in correct locations
- [ ] Implementation plans created correctly
- [ ] Error messages are clear and actionable
- [ ] Progress reporting is accurate
- [ ] Summary statistics are correct
- [ ] Recommendations are helpful

---

## Test Data Setup

To run these tests, ensure TODO.md has tasks with various dependency patterns:

```markdown
### 63. Task with no dependencies
**Status**: Not Started
**Dependencies**: None

### 64. Task depending on 63
**Status**: Not Started
**Dependencies**: 63

### 65. Task depending on 63
**Status**: Not Started
**Dependencies**: 63

### 66. Task depending on 64
**Status**: Not Started
**Dependencies**: 64

### 67. Task depending on 65
**Status**: Not Started
**Dependencies**: 65

### 88. Independent task
**Status**: Not Started
**Dependencies**: None
```

---

## Troubleshooting

### Issue: Batch execution hangs
**Possible Cause**: Circular dependency not detected
**Solution**: Check dependency graph, verify cycle detection logic

---

### Issue: Tasks execute in wrong order
**Possible Cause**: Topological sort error
**Solution**: Verify Kahn's algorithm implementation, check in-degree calculations

---

### Issue: TODO.md not updated
**Possible Cause**: File write error, permission issue
**Solution**: Check file permissions, verify batch-status-manager error handling

---

### Issue: Tasks marked BLOCKED incorrectly
**Possible Cause**: Transitive dependency calculation error
**Solution**: Verify blocking propagation logic, check dependency graph

---

## Success Criteria

All tests should pass with:
- ✅ Correct parsing of all input formats
- ✅ Accurate dependency analysis
- ✅ Correct wave execution order
- ✅ Atomic TODO.md updates
- ✅ Comprehensive error handling
- ✅ Clear progress reporting
- ✅ Backward compatibility maintained

---

## Next Steps After Testing

1. Fix any bugs discovered during testing
2. Optimize performance if needed
3. Gather user feedback
4. Iterate on error messages for clarity
5. Consider additional features (dry run, resume, etc.)
