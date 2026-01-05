# Implementation Plan: Optimize /task Command Performance via Direct Delegation

- **Task**: 309 - Implement Option 1 (Direct Delegation) from task 309 analysis to optimize /task command performance
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: [Research Report](.opencode/specs/309_optimize_task_command_performance/reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

The /task command currently takes 5-10 seconds for simple task creation due to an unnecessary delegation layer (task-creator subagent). This plan implements Option 1 (Direct Delegation) to eliminate the task-creator layer by modifying /task command Stage 4 to delegate directly to status-sync-manager. This achieves a 40-50% performance improvement (5-10s → 3-5s) with low risk and minimal code changes. The implementation preserves all atomic update guarantees and rollback capabilities while eliminating 452 lines of context loading and one subagent invocation per task.

## Goals & Non-Goals

**Goals:**
- Reduce /task command execution time by 40-50% (from 5-10s to 3-5s)
- Eliminate unnecessary task-creator delegation layer
- Preserve atomic updates and rollback guarantees
- Maintain all existing /task command functionality (flags, --divide, error handling)
- Update documentation to reflect new architecture

**Non-Goals:**
- Batch delegation optimization (deferred to future enhancement)
- Changes to status-sync-manager implementation
- Changes to TODO.md or state.json format
- Performance optimization of other commands

## Risks & Mitigations

**Risk 1: task_number Extraction Fails**
- Likelihood: Low | Impact: High
- Mitigation: Add explicit validation with fallback to read next_project_number - 1 from state.json; clear error messages

**Risk 2: Error Handling Regression**
- Likelihood: Medium | Impact: Medium
- Mitigation: Comprehensive testing of all error cases; verify error messages are clear and actionable

**Risk 3: --divide Flag Breaks**
- Likelihood: Low | Impact: High
- Mitigation: Explicit testing with 2, 3, and 5 tasks; verify sequential task numbers and atomic creation

**Risk 4: Performance Improvement Not Realized**
- Likelihood: Low | Impact: Medium
- Mitigation: Measure baseline before implementation; validate 30%+ improvement; investigate if target not met

**Risk 5: Rollback Needed**
- Likelihood: Low | Impact: Low
- Mitigation: Keep task-creator.md as deprecated; rollback via git revert (< 5 minutes)

## Implementation Phases

### Phase 1: Baseline Measurement and Preparation [NOT STARTED]

- **Goal:** Establish performance baseline and prepare for implementation
- **Tasks:**
  - [ ] Measure current /task command performance (3 runs, calculate average)
  - [ ] Document baseline metrics (execution time, delegation count, context size)
  - [ ] Create backup branch for easy rollback
  - [ ] Review status-sync-manager create_task_flow to confirm no changes needed
  - [ ] Verify status-sync-manager return format includes metadata.task_number
- **Timing:** 30 minutes

### Phase 2: Update /task Command Stage 4 [NOT STARTED]

- **Goal:** Modify Stage 4 to delegate directly to status-sync-manager
- **Tasks:**
  - [ ] Update Stage 4 delegation target from "task-creator" to "status-sync-manager"
  - [ ] Add operation: "create_task" parameter to delegation context
  - [ ] Update task_number extraction from return.task_number to return.metadata.task_number
  - [ ] Add validation for task_number field (non-empty, positive integer)
  - [ ] Update error messages to reference status-sync-manager instead of task-creator
  - [ ] Add note about automatic rollback in error handling section
  - [ ] Update delegation_path to reflect direct delegation
- **Timing:** 1 hour

### Phase 3: Update Documentation [NOT STARTED]

- **Goal:** Update all documentation to reflect new architecture
- **Tasks:**
  - [ ] Update /task command frontmatter (agent: status-sync-manager)
  - [ ] Update routing-guide.md command mapping table
  - [ ] Mark task-creator.md as deprecated with frontmatter fields
  - [ ] Add deprecation_reason, deprecated_date, and replacement fields to task-creator.md
  - [ ] Update architecture notes if needed
  - [ ] Verify no other references to task-creator delegation pattern
- **Timing:** 30 minutes

### Phase 4: Comprehensive Testing [NOT STARTED]

- **Goal:** Validate all functionality works correctly with direct delegation
- **Tasks:**
  - [ ] Test Case 1: Single task creation (basic case)
  - [ ] Test Case 2: Multiple tasks with --divide (2, 3, 5 tasks)
  - [ ] Test Case 3: All flags (--priority High --effort "2h" --language lean)
  - [ ] Test Case 4: Error handling - empty description
  - [ ] Test Case 5: Error handling - invalid priority
  - [ ] Test Case 6: Atomic rollback (make TODO.md read-only, verify rollback)
  - [ ] Verify TODO.md and state.json consistency after each test
  - [ ] Verify next_project_number increments correctly
  - [ ] Verify task numbers are sequential for --divide
- **Timing:** 1 hour

### Phase 5: Performance Validation and Finalization [NOT STARTED]

- **Goal:** Validate performance improvement and finalize implementation
- **Tasks:**
  - [ ] Measure optimized /task command performance (3 runs, calculate average)
  - [ ] Calculate improvement percentage: (baseline - optimized) / baseline * 100%
  - [ ] Verify improvement >= 30% (minimum acceptable)
  - [ ] Verify improvement >= 40% (target)
  - [ ] Document actual performance metrics in task notes
  - [ ] Create git commit with changes
  - [ ] Update task 309 status to [COMPLETED]
  - [ ] Document lessons learned for future optimizations
- **Timing:** 30 minutes

## Testing & Validation

### Test Case 1: Single Task Creation
- Run: `/task "Test task creation"`
- Verify: Task in TODO.md and state.json, next_project_number incremented, execution time < 6s
- Pass Criteria: All files consistent, task_number returned, time improvement visible

### Test Case 2: Multiple Tasks with --divide
- Run: `/task "Task A, Task B, Task C" --divide`
- Verify: 3 tasks created, sequential numbers, next_project_number +3, execution time < 13s
- Pass Criteria: All tasks created atomically, numbers sequential, time < 13s

### Test Case 3: All Flags
- Run: `/task "Test task" --priority High --effort "2 hours" --language lean`
- Verify: Metadata correct in both files, task in High Priority section
- Pass Criteria: All metadata fields match flags

### Test Case 4: Error Handling - Invalid Input
- Run: `/task ""`
- Verify: Clear error message, no task created, next_project_number unchanged
- Pass Criteria: Fast failure (< 1s), clear error, no side effects

### Test Case 5: Atomic Rollback
- Setup: `chmod 444 .opencode/specs/TODO.md`
- Run: `/task "Test rollback"`
- Verify: Error mentions rollback, no task in either file, next_project_number unchanged
- Cleanup: `chmod 644 .opencode/specs/TODO.md`
- Pass Criteria: Rollback successful, no partial state

### Test Case 6: Performance Measurement
- Baseline: 3 runs before optimization, calculate average
- Optimized: 3 runs after optimization, calculate average
- Calculate: Improvement percentage
- Pass Criteria: >= 30% improvement (minimum), >= 40% improvement (target)

## Artifacts & Outputs

**Modified Files:**
- .opencode/command/task.md (Stage 4 updated, frontmatter updated)
- .opencode/context/core/system/routing-guide.md (command mapping updated)
- .opencode/agent/subagents/task-creator.md (marked deprecated)

**Documentation:**
- Performance metrics documented in task 309 notes
- Lessons learned for future optimizations

**Preserved Files:**
- .opencode/agent/subagents/task-creator.md (deprecated, not deleted)

## Rollback/Contingency

**If implementation fails or performance target not met:**

1. **Immediate Rollback** (< 5 minutes):
   - Revert .opencode/command/task.md to previous version
   - Revert routing-guide.md to previous version
   - Remove deprecated marker from task-creator.md
   - Verify /task command works with task-creator delegation

2. **Investigation** (if performance < 30% improvement):
   - Profile execution to identify bottlenecks
   - Check if status-sync-manager has unexpected overhead
   - Verify delegation context size is reduced
   - Consider alternative optimizations

3. **Partial Success** (30-39% improvement):
   - Keep implementation (still valuable)
   - Document actual improvement
   - Consider batch delegation as next optimization

**Rollback Validation:**
- Run Test Case 1 to verify basic functionality
- Verify execution time returns to baseline (5-10s)
- Verify all flags and --divide work correctly

## Success Metrics

**Primary Metrics:**
- Execution time reduced by 40-50% (5-10s → 3-5s)
- All test cases pass
- No regressions in functionality

**Secondary Metrics:**
- Context loading reduced by 21% (452 lines eliminated)
- Delegation layers reduced by 33% (3 → 2)
- Subagent invocations reduced by 50% (2 → 1)

**User Experience:**
- Faster task creation (noticeable improvement)
- Same reliability (atomic updates, rollback)
- Same functionality (all flags work)
