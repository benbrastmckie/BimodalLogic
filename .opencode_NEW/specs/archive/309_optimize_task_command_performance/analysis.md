# /task Command Performance Analysis

**Date**: 2026-01-05  
**Analyst**: Claude  
**Scope**: Optimize `/task` command for non-divide case

---

## Executive Summary

The `/task` command without `--divide` flag is slow due to unnecessary delegation layers. Current architecture uses 3-layer delegation (command → task-creator → status-sync-manager) when a 2-layer approach (command → status-sync-manager) would suffice for simple task creation.

**Key Findings**:
- Current execution time: ~5-10 seconds for single task
- Delegation overhead: 2 subagent invocations
- Context loading: ~2150 lines across 3 files
- Optimization potential: 40-60% time reduction

---

## Current Architecture

### Delegation Chain

```
User: /task "description"
  ↓
1. /task command (504 lines)
   - Stage 1: ParseInput (extract flags)
   - Stage 2: ReformulateDescription (inline, fast)
   - Stage 3: DivideIfRequested (skip if no --divide)
   - Stage 4: CreateTasks → delegates to task-creator
   ↓
2. task-creator subagent (453 lines)
   - Step 0: Preflight validation
   - Step 1: Read next_project_number from state.json
   - Step 2: Delegate to status-sync-manager
   ↓
3. status-sync-manager subagent (1193 lines)
   - Step 0: Validate inputs
   - Step 1: Prepare TODO.md and state.json entries
   - Step 2: Backup and update files
   - Step 3: Atomic commit with rollback
   - Step 4: Return success
```

### Performance Breakdown

| Stage | Component | Time (est) | Lines | Overhead |
|-------|-----------|------------|-------|----------|
| 1 | /task command parsing | 0.5s | 504 | Low |
| 2 | task-creator delegation | 2-3s | 453 | **High** |
| 3 | status-sync-manager | 2-4s | 1193 | Medium |
| **Total** | | **5-10s** | **2150** | |

---

## Root Cause Analysis

### Why is it slow?

1. **Unnecessary Delegation Layer**: task-creator subagent adds minimal value
   - Only reads `next_project_number` from state.json
   - Immediately delegates to status-sync-manager
   - No complex logic or validation beyond what command already does

2. **Context Loading Overhead**: Each delegation loads full agent context
   - task-creator: 453 lines + context files
   - status-sync-manager: 1193 lines + context files
   - Total: ~2150 lines + shared context

3. **Subagent Invocation Overhead**: Each `task()` call has overhead
   - Session initialization
   - Context loading
   - Return format parsing
   - Error handling

### What does task-creator actually do?

Looking at `.opencode/agent/subagents/task-creator.md`:

```markdown
<step_1_allocate_number>
  1. Read specs/state.json
  2. Extract next_project_number field using jq
  3. Validate it's a number >= 0
  4. Store for use in task creation
</step_1_allocate_number>

<step_2_delegate_to_status_sync>
  1. Prepare task metadata
  2. Invoke status-sync-manager via task tool
  3. Wait for completion
  4. Parse task number from return
</step_2_delegate_to_status_sync>
```

**Analysis**: task-creator is a thin wrapper that:
- Reads one field from state.json
- Passes it to status-sync-manager
- Returns the result

This can be done directly by the command.

---

## Optimization Opportunities

### Option 1: Direct Delegation (Recommended)

**Change**: `/task` command delegates directly to status-sync-manager

**Benefits**:
- Eliminates task-creator layer (saves 2-3s)
- Reduces context loading by 453 lines
- Simplifies architecture
- Maintains atomic updates via status-sync-manager

**Implementation**:
```markdown
<stage id="4" name="CreateTasks">
  <action>Create task entries via status-sync-manager</action>
  <process>
    1. For each task in task_list:
       a. Delegate to status-sync-manager:
          - operation: "create_task"
          - title, description, priority, effort, language
          - status-sync-manager reads next_project_number internally
       b. Collect task_number from return
  </process>
</stage>
```

**Effort**: 2-3 hours
- Update /task command Stage 4
- Update task-creator documentation (mark as deprecated or remove)
- Test atomic updates still work
- Update architecture documentation

**Risk**: Low
- status-sync-manager already has `create_task_flow`
- No changes to status-sync-manager needed
- Rollback is simple (revert command file)

---

### Option 2: Inline Task Creation (Not Recommended)

**Change**: `/task` command creates tasks directly without any delegation

**Benefits**:
- Maximum performance (eliminates all delegation)
- Simplest possible architecture

**Drawbacks**:
- Loses atomic updates (two-phase commit)
- Duplicates status-sync-manager logic in command
- Higher risk of inconsistent state
- Violates separation of concerns

**Verdict**: Not recommended. Atomic updates are critical.

---

### Option 3: Batch Delegation (Future Enhancement)

**Change**: For `--divide` flag, batch all task creations into single status-sync-manager call

**Benefits**:
- Reduces delegation overhead for multi-task creation
- Maintains atomic updates

**Implementation**:
```markdown
status-sync-manager receives:
{
  "operation": "create_tasks_batch",
  "tasks": [
    {title, description, priority, effort, language},
    {title, description, priority, effort, language},
    ...
  ]
}

Returns:
{
  "task_numbers": [303, 304, 305],
  "status": "completed"
}
```

**Effort**: 4-6 hours
- Extend status-sync-manager with batch operation
- Update /task command to use batch for --divide
- Test atomic rollback for partial failures

**Priority**: Medium (future enhancement after Option 1)

---

## Recommended Implementation Plan

### Phase 1: Direct Delegation (2-3 hours)

1. **Update /task command** (1 hour)
   - Modify Stage 4 to delegate directly to status-sync-manager
   - Remove task-creator invocation
   - Update error handling

2. **Update Documentation** (0.5 hours)
   - Mark task-creator as deprecated in frontmatter
   - Update architecture notes in /task command
   - Update `.opencode/context/core/system/routing-guide.md`

3. **Testing** (0.5-1 hour)
   - Test single task creation
   - Test --divide flag (multiple tasks)
   - Test error handling (invalid inputs)
   - Test atomic rollback (simulate failure)

4. **Validation** (0.5 hours)
   - Verify TODO.md and state.json consistency
   - Verify next_project_number increments correctly
   - Verify performance improvement (measure before/after)

### Phase 2: Remove task-creator (Optional, 1 hour)

1. **Archive task-creator** (0.5 hours)
   - Move to `.opencode/agent/subagents/archive/`
   - Update references in documentation

2. **Update Tests** (0.5 hours)
   - Remove task-creator tests
   - Update integration tests

---

## Expected Performance Improvement

### Before Optimization

| Metric | Value |
|--------|-------|
| Execution time | 5-10s |
| Delegation layers | 3 |
| Context loading | ~2150 lines |
| Subagent invocations | 2 |

### After Optimization (Option 1)

| Metric | Value | Improvement |
|--------|-------|-------------|
| Execution time | 3-5s | **40-50% faster** |
| Delegation layers | 2 | -33% |
| Context loading | ~1697 lines | -21% |
| Subagent invocations | 1 | -50% |

### After Optimization (Option 3, future)

| Metric | Value | Improvement |
|--------|-------|-------------|
| Execution time (5 tasks) | 4-6s | **60-70% faster** |
| Delegation layers | 2 | -33% |
| Batch efficiency | 5 tasks in 1 call | 5x |

---

## Risk Assessment

### Low Risk
- ✅ status-sync-manager already has `create_task_flow`
- ✅ No changes to status-sync-manager needed
- ✅ Atomic updates preserved
- ✅ Easy rollback (revert command file)

### Medium Risk
- ⚠️ Need to test error handling thoroughly
- ⚠️ Need to verify all edge cases (invalid inputs, file permissions, etc.)

### High Risk
- ❌ None identified

---

## Alternative Approaches Considered

### 1. Optimize task-creator Performance
**Rejected**: Doesn't address root cause (unnecessary layer)

### 2. Cache next_project_number
**Rejected**: Introduces race conditions, violates atomicity

### 3. Parallel Task Creation
**Rejected**: Complex, high risk, minimal benefit for typical use case

---

## Conclusion

**Recommendation**: Implement Option 1 (Direct Delegation)

**Rationale**:
- 40-50% performance improvement
- Low risk, high reward
- Maintains atomic updates
- Simplifies architecture
- 2-3 hours implementation time

**Next Steps**:
1. Create task in TODO.md
2. Implement Phase 1 (Direct Delegation)
3. Test thoroughly
4. Measure performance improvement
5. Consider Phase 2 (Remove task-creator) after validation

---

## Appendix: Performance Measurement

### Before Optimization
```bash
time /task "Test task creation"
# Expected: 5-10 seconds
```

### After Optimization
```bash
time /task "Test task creation"
# Expected: 3-5 seconds (40-50% improvement)
```

### Measurement Script
```bash
#!/bin/bash
# measure-task-performance.sh

echo "Measuring /task command performance..."

# Test 1: Single task
echo "Test 1: Single task creation"
time /task "Performance test task 1"

# Test 2: Multiple tasks with --divide
echo "Test 2: Multiple tasks with --divide"
time /task "Task A, Task B, Task C" --divide

# Test 3: Task with all flags
echo "Test 3: Task with all flags"
time /task "Complex task" --priority High --effort "2 hours" --language lean

echo "Performance measurement complete."
```

---

**End of Analysis**
