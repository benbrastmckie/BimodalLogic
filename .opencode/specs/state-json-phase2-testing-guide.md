# State.json Phase 2 Optimization - Testing Guide

**Created**: 2026-01-05
**Status**: Ready for Testing
**Purpose**: Comprehensive testing guide for Phase 2 optimizations

---

## Overview

This guide provides step-by-step testing procedures for all Phase 2 optimizations:
- Phase 1: Enhanced status-sync-manager with description field support
- Phase 2: Optimized /todo command (state.json queries)
- Phase 3: Optimized /review command
- Phase 4: Optimized /meta command (atomic task creation)
- Phase 5: Optimized /task command (atomic task creation)

---

## Pre-Testing Validation

### Static Checks (Automated)

Run these checks before manual testing:

```bash
# 1. Verify state.json is valid JSON
jq empty .opencode/specs/state.json && echo "✅ state.json is valid JSON" || echo "❌ state.json is invalid"

# 2. Verify next_project_number exists
jq -r '.next_project_number' .opencode/specs/state.json && echo "✅ next_project_number found" || echo "❌ next_project_number missing"

# 3. Verify active_projects array exists
jq -r '.active_projects | length' .opencode/specs/state.json && echo "✅ active_projects array found" || echo "❌ active_projects missing"

# 4. Check for tasks with description field in state.json
jq -r '.active_projects[] | select(.description != null) | {project_number, description}' .opencode/specs/state.json | head -20

# 5. Verify TODO.md exists and is readable
[ -f .opencode/specs/TODO.md ] && echo "✅ TODO.md exists" || echo "❌ TODO.md missing"

# 6. Count tasks with Description field in TODO.md
grep -c "^\*\*Description\*\*:" .opencode/specs/TODO.md && echo "tasks have Description field" || echo "No Description fields found"
```

**Expected Results**:
- ✅ All checks should pass
- ✅ state.json should be valid JSON
- ✅ next_project_number should be a positive integer
- ✅ active_projects should be an array
- ✅ Some tasks should have description field (if any were created with Phase 2)

---

## Test Suite

### Test 1: /todo Command Optimization (Phase 2)

**Purpose**: Verify /todo uses state.json for fast scanning

**Prerequisites**:
- At least one task with status [COMPLETED] or [ABANDONED]
- If none exist, create a test task and mark it completed

**Test Steps**:

```bash
# Step 1: Create a test task and mark it completed (if needed)
# (Skip if you already have completed tasks)

# Step 2: Run /todo command
time /todo

# Step 3: Observe output and timing
```

**Expected Results**:
- ✅ Command completes successfully
- ✅ Identifies completed/abandoned tasks correctly
- ✅ Execution time < 50ms (vs ~200ms before optimization)
- ✅ No errors about state.json
- ✅ Tasks archived correctly

**Performance Benchmark**:
- **Before**: ~200ms for scanning TODO.md
- **After**: ~15ms for querying state.json
- **Improvement**: 13x faster

**Validation**:
```bash
# Verify tasks were archived
jq -r '.completed_projects | length' .opencode/specs/state.json

# Verify active_projects count decreased
jq -r '.active_projects | length' .opencode/specs/state.json
```

---

### Test 2: /review Command Optimization (Phase 3)

**Purpose**: Verify /review uses state.json for task queries

**Test Steps**:

```bash
# Step 1: Run /review command
time /review

# Step 2: Observe output
```

**Expected Results**:
- ✅ Command completes successfully
- ✅ Reads next_project_number from state.json (not TODO.md)
- ✅ Creates tasks if needed
- ✅ No errors about state.json

**Validation**:
```bash
# Check if review created any tasks
jq -r '.active_projects[] | select(.type == "maintenance") | {project_number, project_name}' .opencode/specs/state.json
```

---

### Test 3: /meta Command Atomic Task Creation (Phase 4)

**Purpose**: Verify /meta uses status-sync-manager for atomic task creation

**Test Steps**:

```bash
# Step 1: Run /meta in prompt mode with a simple request
/meta "Create a simple test system for data validation"

# Step 2: Follow the interactive prompts or let it proceed
# Step 3: Observe task creation
```

**Expected Results**:
- ✅ Tasks created successfully
- ✅ All tasks have description field in TODO.md
- ✅ All tasks have description field in state.json
- ✅ next_project_number incremented correctly
- ✅ Tasks appear in both TODO.md and state.json
- ✅ No partial task creation (atomic guarantee)

**Validation**:
```bash
# Get the task numbers created by /meta
# (Note the task numbers from the output)

# For each task number, verify it exists in both files:
TASK_NUM=XXX  # Replace with actual task number

# Check TODO.md
grep "^### ${TASK_NUM}\." .opencode/specs/TODO.md && echo "✅ Task ${TASK_NUM} in TODO.md" || echo "❌ Task ${TASK_NUM} missing from TODO.md"

# Check for Description field in TODO.md
grep -A 20 "^### ${TASK_NUM}\." .opencode/specs/TODO.md | grep "^\*\*Description\*\*:" && echo "✅ Description field present" || echo "❌ Description field missing"

# Check state.json
jq -r ".active_projects[] | select(.project_number == ${TASK_NUM})" .opencode/specs/state.json && echo "✅ Task ${TASK_NUM} in state.json" || echo "❌ Task ${TASK_NUM} missing from state.json"

# Check for description field in state.json
jq -r ".active_projects[] | select(.project_number == ${TASK_NUM}) | .description" .opencode/specs/state.json && echo "✅ description field present" || echo "❌ description field missing"
```

---

### Test 4: /task Command Atomic Task Creation (Phase 5)

**Purpose**: Verify /task uses status-sync-manager for atomic task creation

**Test Steps**:

```bash
# Step 1: Create a simple task
/task "Test atomic task creation with description field"

# Step 2: Observe output and note the task number
```

**Expected Results**:
- ✅ Task created successfully
- ✅ Task has description field in TODO.md
- ✅ Task has description field in state.json
- ✅ next_project_number incremented by 1
- ✅ Task appears in both TODO.md and state.json
- ✅ Description is 50-500 chars (validated)

**Validation**:
```bash
# Get the task number from the output
TASK_NUM=XXX  # Replace with actual task number

# Check TODO.md
grep "^### ${TASK_NUM}\." .opencode/specs/TODO.md && echo "✅ Task ${TASK_NUM} in TODO.md" || echo "❌ Task ${TASK_NUM} missing from TODO.md"

# Check for Description field in TODO.md
grep -A 20 "^### ${TASK_NUM}\." .opencode/specs/TODO.md | grep "^\*\*Description\*\*:" && echo "✅ Description field present" || echo "❌ Description field missing"

# Check state.json
jq -r ".active_projects[] | select(.project_number == ${TASK_NUM})" .opencode/specs/state.json && echo "✅ Task ${TASK_NUM} in state.json" || echo "❌ Task ${TASK_NUM} missing from state.json"

# Check for description field in state.json
jq -r ".active_projects[] | select(.project_number == ${TASK_NUM}) | .description" .opencode/specs/state.json && echo "✅ description field present" || echo "❌ description field missing"

# Verify description length (should be 50-500 chars)
DESC_LEN=$(jq -r ".active_projects[] | select(.project_number == ${TASK_NUM}) | .description | length" .opencode/specs/state.json)
if [ "$DESC_LEN" -ge 50 ] && [ "$DESC_LEN" -le 500 ]; then
  echo "✅ Description length valid: ${DESC_LEN} chars"
else
  echo "❌ Description length invalid: ${DESC_LEN} chars (should be 50-500)"
fi
```

---

### Test 5: Atomic Rollback Test (Critical)

**Purpose**: Verify status-sync-manager rolls back on failure

**Test Steps**:

This test requires simulating a failure. We'll test the validation logic instead:

```bash
# Test 1: Try to create task with invalid description (too short)
# This should fail validation before attempting creation
/task "Short"  # Less than 50 chars

# Expected: Error message about description length
```

**Expected Results**:
- ✅ Command fails with clear error message
- ✅ No partial task creation
- ✅ next_project_number unchanged
- ✅ No entry in TODO.md
- ✅ No entry in state.json

---

### Test 6: Consistency Validation

**Purpose**: Verify TODO.md and state.json are synchronized

**Test Steps**:

```bash
# Run consistency check script (if available)
python3 .opencode/scripts/validate_state_sync.py

# Or manual validation:

# 1. Count tasks in TODO.md
TODO_COUNT=$(grep -c "^### [0-9]\+\." .opencode/specs/TODO.md)
echo "TODO.md tasks: ${TODO_COUNT}"

# 2. Count tasks in state.json
STATE_COUNT=$(jq -r '.active_projects | length' .opencode/specs/state.json)
echo "state.json tasks: ${STATE_COUNT}"

# 3. Compare counts (should match)
if [ "$TODO_COUNT" -eq "$STATE_COUNT" ]; then
  echo "✅ Task counts match"
else
  echo "❌ Task counts mismatch: TODO.md=${TODO_COUNT}, state.json=${STATE_COUNT}"
fi

# 4. Verify each task in state.json exists in TODO.md
jq -r '.active_projects[].project_number' .opencode/specs/state.json | while read num; do
  grep -q "^### ${num}\." .opencode/specs/TODO.md && echo "✅ Task ${num} consistent" || echo "❌ Task ${num} missing from TODO.md"
done

# 5. Check for description field consistency
jq -r '.active_projects[] | select(.description != null) | .project_number' .opencode/specs/state.json | while read num; do
  grep -A 20 "^### ${num}\." .opencode/specs/TODO.md | grep -q "^\*\*Description\*\*:" && echo "✅ Task ${num} has Description in both files" || echo "❌ Task ${num} missing Description in TODO.md"
done
```

**Expected Results**:
- ✅ All tasks in state.json exist in TODO.md
- ✅ All tasks in TODO.md exist in state.json
- ✅ Task counts match
- ✅ Description fields are consistent

---

### Test 7: Performance Benchmarking

**Purpose**: Measure actual performance improvements

**Test Steps**:

```bash
# Benchmark /todo command
echo "Testing /todo performance..."
time /todo

# Benchmark state.json query directly
echo "Testing state.json query performance..."
time jq -r '.active_projects[] | select(.status == "completed" or .status == "abandoned") | .project_number' .opencode/specs/state.json

# Benchmark TODO.md parsing (old approach)
echo "Testing TODO.md parsing performance (old approach)..."
time grep -B 1 "\[COMPLETED\]\|\[ABANDONED\]" .opencode/specs/TODO.md | grep "^###" | sed 's/### \([0-9]*\)\..*/\1/'
```

**Expected Results**:
- ✅ state.json query: ~5-15ms
- ✅ TODO.md parsing: ~100-200ms
- ✅ Improvement: 10-20x faster

---

## Test Results Checklist

### Phase 1: Enhanced status-sync-manager
- [ ] create_task() operation exists
- [ ] archive_tasks() operation exists
- [ ] Description field validation (50-500 chars)
- [ ] Atomic updates with rollback

### Phase 2: /todo Command
- [ ] Uses state.json for scanning
- [ ] Performance < 50ms
- [ ] Correctly identifies completed/abandoned tasks
- [ ] Archives tasks successfully

### Phase 3: /review Command
- [ ] Uses state.json for next_project_number
- [ ] Creates tasks successfully
- [ ] No errors

### Phase 4: /meta Command
- [ ] Uses status-sync-manager for task creation
- [ ] All tasks have description field
- [ ] Atomic creation (all or nothing)
- [ ] next_project_number increments correctly

### Phase 5: /task Command
- [ ] Uses status-sync-manager for task creation
- [ ] Task has description field
- [ ] Atomic creation (all or nothing)
- [ ] Description length validated (50-500 chars)

### Consistency Validation
- [ ] TODO.md and state.json synchronized
- [ ] All tasks exist in both files
- [ ] Description fields consistent
- [ ] No partial task creation

### Performance Validation
- [ ] /todo: 13x faster (200ms → 15ms)
- [ ] state.json queries: ~5-15ms
- [ ] Atomic operations: <100ms

---

## Troubleshooting

### Issue: state.json not found
**Solution**: Run `/meta` to regenerate state.json

### Issue: Description field missing
**Solution**: Tasks created before Phase 2 won't have description field. Only new tasks will have it.

### Issue: Task counts mismatch
**Solution**: Run validation script to identify and repair inconsistencies:
```bash
python3 .opencode/scripts/validate_state_sync.py --fix
```

### Issue: /todo command slow
**Solution**: Verify Stage 1 is using state.json queries (check command file)

### Issue: Atomic creation failed
**Solution**: Check status-sync-manager logs for error details. Verify file permissions.

---

## Next Steps After Testing

1. **If all tests pass**: Proceed to Phase 7 (Documentation and Cleanup)
2. **If tests fail**: Document failures, fix issues, re-test
3. **Performance metrics**: Record actual performance improvements
4. **Update documentation**: Document any deviations from expected behavior

---

## Test Execution Log

**Date**: ___________
**Tester**: ___________

| Test | Status | Notes |
|------|--------|-------|
| Pre-Testing Validation | ⬜ | |
| Test 1: /todo Optimization | ⬜ | |
| Test 2: /review Optimization | ⬜ | |
| Test 3: /meta Atomic Creation | ⬜ | |
| Test 4: /task Atomic Creation | ⬜ | |
| Test 5: Atomic Rollback | ⬜ | |
| Test 6: Consistency Validation | ⬜ | |
| Test 7: Performance Benchmarking | ⬜ | |

**Overall Result**: ⬜ PASS / ⬜ FAIL

**Notes**:
___________________________________________________________________________
___________________________________________________________________________
___________________________________________________________________________

---

**End of Testing Guide**
