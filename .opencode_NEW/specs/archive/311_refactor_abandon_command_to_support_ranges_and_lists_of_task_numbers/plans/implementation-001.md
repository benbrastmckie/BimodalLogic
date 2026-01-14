# Implementation Plan: Refactor /abandon Command to Support Ranges and Lists

## Metadata

- **Task**: 311 - Refactor /abandon command to support ranges and lists of task numbers
- **Status**: [PLANNED]
- **Estimated Effort**: 3.5 hours
- **Complexity**: Medium
- **Language**: meta
- **Priority**: Medium
- **Created**: 2026-01-05
- **Plan Version**: 1

---

## Overview

### Problem Statement

The current `/abandon` command only supports abandoning a single task at a time (e.g., `/abandon 298`), requiring multiple command executions for bulk operations. This is inefficient when users need to abandon multiple related tasks, such as cleaning up a series of experimental tasks or removing obsolete work items.

### Solution Approach

Enhance the `/abandon` command to accept range syntax (e.g., `293-295`) and comma-separated lists (e.g., `302, 303`), as well as mixed syntax (e.g., `293-295, 302, 303`). The implementation will use a loop delegation approach, calling status-sync-manager for each task individually to ensure atomic updates with rollback capability on failure.

### Scope

**In Scope**:
- Parse range syntax: `N-M` expands to tasks N through M inclusive
- Parse comma-separated lists: `A, B, C` expands to tasks A, B, C
- Parse mixed syntax: `N-M, A, B` combines ranges and lists
- Validate all tasks exist and have valid status before abandoning any
- Implement rollback on failure (restore original status for all abandoned tasks)
- Maintain backward compatibility with single task syntax
- Provide clear error messages for invalid input

**Out of Scope**:
- Adding new bulk operation to status-sync-manager (future optimization)
- User confirmation prompts (command executes immediately)
- Dry-run mode (future enhancement)

### Constraints

- Must maintain backward compatibility with existing single-task syntax
- Must complete within 60s timeout (current command timeout)
- Must ensure atomicity: all tasks abandoned or none (with rollback)
- Must maintain TODO.md and state.json synchronization via status-sync-manager
- Cannot modify status-sync-manager (loop delegation only)

### Definition of Done

- [ ] `/abandon 298` works (backward compatibility)
- [ ] `/abandon 293-295` abandons tasks 293, 294, 295
- [ ] `/abandon 302, 303` abandons tasks 302, 303
- [ ] `/abandon 293-295, 302, 303` abandons all 5 tasks
- [ ] Invalid range (start > end) returns clear error
- [ ] Invalid task number returns clear error
- [ ] Task not found returns clear error
- [ ] Cannot abandon completed task (validation error)
- [ ] Cannot abandon already abandoned task (validation error)
- [ ] Rollback works on delegation failure (restores original status)
- [ ] All tasks updated in both TODO.md and state.json
- [ ] Command documentation updated with new syntax examples

---

## Research Integration

This plan integrates findings from 1 research report:

**Integrated Reports**:
- **research-001.md** (2026-01-05): Comprehensive analysis of bulk abandonment implementation approaches
  - Key Finding: Range parsing pattern exists in `/implement` command (regex-based expansion)
  - Key Finding: Bulk operations pattern exists in `/todo` command (comma-separated lists)
  - Key Finding: status-sync-manager does NOT support bulk abandonment operation
  - Recommendation: Use loop delegation approach (reuses existing atomic update logic, lower effort)
  - Recommendation: Validate all tasks before abandoning any (fail-fast approach)
  - Recommendation: Implement rollback on failure (reverse loop with original status restoration)

---

## Goals and Non-Goals

### Goals

1. Enable bulk abandonment of tasks using range and list syntax
2. Maintain atomicity with rollback capability on failure
3. Preserve backward compatibility with single-task syntax
4. Provide clear, actionable error messages for all failure cases
5. Ensure TODO.md and state.json remain synchronized

### Non-Goals

1. Optimize performance with new status-sync-manager bulk operation (future work)
2. Add user confirmation prompts for bulk operations (execute immediately)
3. Implement dry-run mode to preview changes (future enhancement)
4. Support complex range expressions (e.g., `1-10 except 5`)

---

## Risks and Mitigations

### Risk 1: Rollback Failure

**Risk**: Rollback may fail after partial abandonment, leaving system in inconsistent state.

**Likelihood**: Low

**Impact**: High (manual intervention required)

**Mitigation**:
- Track original status for each task before abandonment
- Log all rollback attempts with details
- Provide clear error message with manual recovery instructions
- Test rollback logic thoroughly with simulated failures

**Recovery**:
```bash
# Manual recovery if rollback fails
# 1. Check state.json for inconsistencies
jq '.active_projects[] | select(.status == "abandoned")' .opencode/specs/state.json

# 2. Manually restore status using /sync command
/sync

# 3. Or manually edit state.json and TODO.md
```

### Risk 2: Partial Abandonment on Timeout

**Risk**: Command may timeout during bulk abandonment, leaving some tasks abandoned and others not.

**Likelihood**: Low (60s timeout is generous for ~50ms per task)

**Impact**: Medium (requires manual cleanup)

**Mitigation**:
- Validate all tasks before abandonment (fail fast)
- Log progress during abandonment
- Provide clear error message with list of abandoned tasks
- Consider increasing timeout for bulk operations if needed

**Recovery**:
- Check command output for list of abandoned tasks
- Re-run command with remaining tasks

### Risk 3: Invalid Input Parsing

**Risk**: User may provide malformed input (e.g., `295-293`, `abc`, `1-2-3`).

**Likelihood**: Medium

**Impact**: Low (validation catches this)

**Mitigation**:
- Validate range format with regex: `^([0-9]+)-([0-9]+)$`
- Validate single number format with regex: `^[0-9]+$`
- Provide clear error message with correct syntax examples
- Show usage examples in error output

---

## Implementation Phases

### Phase 1: Argument Parsing [NOT STARTED]

**Objective**: Implement parsing logic for mixed range and list syntax.

**Duration**: 1 hour

**Tasks**:
1. Add `parse_task_numbers()` function to Stage 1 (ParseAndValidate)
2. Implement comma splitting: `IFS=',' read -ra PARTS <<< "$ARGUMENTS"`
3. For each part:
   - Trim whitespace: `part=$(echo "$part" | xargs)`
   - Check if range pattern: `[[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]`
   - If range: Validate start <= end, expand with `seq`
   - If single number: Add to task list
   - Else: Return error with usage examples
4. Deduplicate and sort task numbers: `printf '%s\n' "${task_numbers[@]}" | sort -nu`
5. Convert to array for validation

**Acceptance Criteria**:
- [ ] Parse single number: `298` → `[298]`
- [ ] Parse range: `293-295` → `[293, 294, 295]`
- [ ] Parse list: `302, 303` → `[302, 303]`
- [ ] Parse mixed: `293-295, 302, 303` → `[293, 294, 295, 302, 303]`
- [ ] Deduplicate: `293, 293-295` → `[293, 294, 295]`
- [ ] Error on invalid range: `295-293` → error
- [ ] Error on invalid format: `abc` → error

**Validation**:
- Test with all syntax variations
- Verify deduplication works correctly
- Verify error messages are clear and actionable

---

### Phase 2: Task Validation [NOT STARTED]

**Objective**: Validate all tasks exist and have valid status before abandoning any.

**Duration**: 0.5 hours

**Tasks**:
1. Add `validate_tasks()` function to Stage 1 (ParseAndValidate)
2. For each task number:
   - Lookup task in state.json: `jq '.active_projects[] | select(.project_number == ($num | tonumber))'`
   - Check task exists (non-empty result)
   - Extract status and project_name
   - Store original status in associative array for rollback
   - Validate status allows abandonment:
     * Error if status == "completed"
     * Error if status == "abandoned"
     * Allow if status in ["not_started", "in_progress", "researched", "planned", "blocked"]
3. Return error on first validation failure (fail fast)
4. Log validated tasks with original status

**Acceptance Criteria**:
- [ ] Validate task exists in state.json
- [ ] Validate status allows abandonment
- [ ] Store original status for rollback
- [ ] Error on task not found
- [ ] Error on completed task
- [ ] Error on already abandoned task
- [ ] Fail fast on first validation error

**Validation**:
- Test with non-existent task
- Test with completed task
- Test with already abandoned task
- Verify original status stored correctly

---

### Phase 3: Bulk Abandonment with Rollback [NOT STARTED]

**Objective**: Abandon tasks using loop delegation with rollback on failure.

**Duration**: 1.5 hours

**Tasks**:
1. Add `abandon_tasks()` function to Stage 2 (Delegate)
2. Initialize `abandoned_tasks` array to track progress
3. For each task number:
   - Delegate to status-sync-manager:
     ```bash
     # Prepare delegation context
     delegation_context=$(jq -n \
       --arg task_num "$task_number" \
       --arg new_status "abandoned" \
       --arg timestamp "$(date -I)" \
       '{
         task_number: $task_num,
         new_status: $new_status,
         timestamp: $timestamp,
         operation: "update_status"
       }')
     
     # Invoke status-sync-manager
     result=$(invoke_subagent "status-sync-manager" "$delegation_context")
     ```
   - Check delegation result status
   - If success: Add task to `abandoned_tasks` array
   - If failure: Trigger rollback
4. Implement rollback logic:
   - Reverse loop through `abandoned_tasks` array
   - For each task: Delegate to status-sync-manager with original status
   - Log rollback success/failure
   - Return error with rollback details
5. Log final success with count and task list

**Acceptance Criteria**:
- [ ] Delegate to status-sync-manager for each task
- [ ] Track abandoned tasks in array
- [ ] Rollback on delegation failure
- [ ] Restore original status for all abandoned tasks
- [ ] Log rollback attempts
- [ ] Return clear error on failure with rollback details
- [ ] Return success with count and task list

**Validation**:
- Test successful bulk abandonment
- Test rollback with simulated delegation failure
- Verify original status restored correctly
- Verify error messages include rollback details

---

### Phase 4: Error Handling and Messages [NOT STARTED]

**Objective**: Provide clear, actionable error messages for all failure cases.

**Duration**: 0.5 hours

**Tasks**:
1. Add comprehensive error messages:
   - Empty input: "Task number required. Usage: /abandon TASK_NUMBER|RANGE|LIST"
   - Invalid format: "Invalid task number format: '{part}'. Expected: number (e.g., 298) or range (e.g., 293-295)"
   - Invalid range: "Invalid range {start}-{end} (start > end)"
   - Task not found: "Task {number} not found in state.json. Available tasks: ..." (show first 10)
   - Cannot abandon completed: "Cannot abandon completed task {number} ({project_name}). Completed tasks are terminal."
   - Already abandoned: "Task {number} already abandoned ({project_name})"
   - Delegation failure: "Failed to abandon task {number}, rolled back {count} tasks"
2. Add usage examples to error output:
   ```
   Examples:
     /abandon 298                    # Single task
     /abandon 293-295                # Range
     /abandon 302, 303               # List
     /abandon 293-295, 302, 303      # Mixed
   ```
3. Include recommendations in error messages

**Acceptance Criteria**:
- [ ] All error cases have clear messages
- [ ] Error messages include usage examples
- [ ] Error messages include recommendations
- [ ] Error messages show context (task name, status)

**Validation**:
- Test each error case
- Verify error messages are clear and actionable
- Verify usage examples are correct

---

### Phase 5: Documentation and Testing [NOT STARTED]

**Objective**: Update command documentation and test all functionality.

**Duration**: 0.5 hours (reduced - no separate testing phase needed)

**Tasks**:
1. Update `.opencode/command/abandon.md` documentation:
   - Add new syntax to Usage section
   - Add examples for range, list, and mixed syntax
   - Update Stage 1 (ParseAndValidate) description
   - Update Stage 2 (Delegate) description
   - Add error handling documentation
2. Manual testing:
   - Test single task abandonment (backward compatibility)
   - Test range abandonment
   - Test list abandonment
   - Test mixed syntax abandonment
   - Test error cases (invalid input, task not found, invalid status)
   - Test rollback with simulated failure
3. Verify TODO.md and state.json synchronization

**Acceptance Criteria**:
- [ ] Documentation updated with new syntax
- [ ] Examples added for all syntax variations
- [ ] All test cases pass
- [ ] TODO.md and state.json synchronized

**Validation**:
- Review documentation for clarity
- Execute all test cases
- Verify synchronization with /sync command

---

## Testing and Validation

### Unit Testing

**Test Cases**:
1. **Argument Parsing**:
   - Single number: `298` → `[298]`
   - Range: `293-295` → `[293, 294, 295]`
   - List: `302, 303` → `[302, 303]`
   - Mixed: `293-295, 302, 303` → `[293, 294, 295, 302, 303]`
   - Deduplication: `293, 293-295` → `[293, 294, 295]`
   - Invalid range: `295-293` → error
   - Invalid format: `abc` → error
   - Empty input: `` → error

2. **Task Validation**:
   - Task exists: Valid task → success
   - Task not found: Non-existent task → error
   - Completed task: Task with status "completed" → error
   - Already abandoned: Task with status "abandoned" → error
   - Valid status: Task with status "not_started" → success

3. **Bulk Abandonment**:
   - Single task: Abandon 1 task → success
   - Multiple tasks: Abandon 3 tasks → success
   - Delegation failure: Simulate failure on task 2 → rollback tasks 1
   - Rollback success: Verify original status restored

### Integration Testing

**Test Scenarios**:
1. **End-to-End Success**:
   - Create 3 test tasks with status "not_started"
   - Run `/abandon 1-3`
   - Verify all 3 tasks have status "abandoned" in TODO.md and state.json
   - Verify git commit created

2. **End-to-End Rollback**:
   - Create 3 test tasks with status "not_started"
   - Simulate delegation failure on task 2
   - Verify task 1 status restored to "not_started"
   - Verify tasks 2-3 remain "not_started"
   - Verify error message includes rollback details

3. **Backward Compatibility**:
   - Run `/abandon 298` (single task)
   - Verify works as before
   - Verify no regression in functionality

### Validation Criteria

- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Backward compatibility maintained
- [ ] Error messages clear and actionable
- [ ] TODO.md and state.json synchronized
- [ ] Git commits created successfully
- [ ] No performance regression (< 60s for 10 tasks)

---

## Artifacts and Outputs

### Primary Artifacts

1. **Modified Files**:
   - `.opencode/command/abandon.md` - Enhanced with range/list parsing and bulk abandonment logic

### Supporting Artifacts

1. **Implementation Summary**:
   - `.opencode/specs/311_refactor_abandon_command_to_support_ranges_and_lists_of_task_numbers/summaries/implementation-summary-20260105.md`
   - Brief summary of changes and validation results

### Artifact Structure

```
.opencode/specs/311_refactor_abandon_command_to_support_ranges_and_lists_of_task_numbers/
├── reports/
│   └── research-001.md (existing)
├── plans/
│   └── implementation-001.md (this file)
└── summaries/
    └── implementation-summary-20260105.md (created during implementation)
```

---

## Rollback/Contingency

### Rollback Plan

If implementation fails or introduces regressions:

1. **Git Revert**:
   ```bash
   # Revert to previous version
   git log --oneline | head -5
   git revert <commit_hash>
   ```

2. **Manual Rollback**:
   - Restore `.opencode/command/abandon.md` from git history
   - Verify single-task abandonment still works
   - Document rollback reason in task notes

### Contingency Plan

If loop delegation approach proves too slow:

1. **Optimize Later**:
   - Implement new `abandon_tasks` operation in status-sync-manager
   - Migrate to bulk operation in Phase 2 (future task)
   - Estimated effort: 6-8 hours

2. **Hybrid Approach**:
   - Use loop delegation for < 5 tasks
   - Use bulk operation for >= 5 tasks
   - Requires status-sync-manager changes

---

## Success Metrics

### Functional Metrics

- [ ] All syntax variations work correctly (single, range, list, mixed)
- [ ] Validation catches all error cases
- [ ] Rollback restores original status on failure
- [ ] TODO.md and state.json remain synchronized
- [ ] Backward compatibility maintained (single-task syntax)

### Performance Metrics

- [ ] Single task: < 100ms (same as before)
- [ ] 5 tasks: < 500ms (acceptable)
- [ ] 10 tasks: < 1000ms (acceptable)
- [ ] Command completes within 60s timeout

### Quality Metrics

- [ ] Error messages clear and actionable
- [ ] Documentation complete and accurate
- [ ] All test cases pass
- [ ] No regressions in existing functionality
- [ ] Code follows command-template.md standards

---

## Dependencies

### Internal Dependencies

- status-sync-manager: Required for atomic status updates
- state.json: Source of truth for task metadata
- TODO.md: User-facing task list

### External Dependencies

- None

### Blocking Issues

- None

---

## Notes

### Implementation Notes

1. **Loop Delegation Approach**: Chosen for lower effort and reuse of existing atomic update logic. Can be optimized later with bulk operation if performance becomes issue.

2. **Fail-Fast Validation**: Validate all tasks before abandoning any to prevent partial abandonment on validation failure. Reduces rollback complexity.

3. **Deduplication**: Automatically deduplicate task numbers to prevent duplicate abandonments. User-friendly approach (no error on duplicates).

4. **Backward Compatibility**: Single-task syntax works without changes. Gradual adoption of new syntax.

### Future Enhancements

1. **Bulk Operation**: Add `abandon_tasks` operation to status-sync-manager for better performance (6-8 hours)
2. **User Confirmation**: Add confirmation prompt for bulk operations > 5 tasks (1 hour)
3. **Dry-Run Mode**: Add `--dry-run` flag to preview changes without executing (2 hours)
4. **Complex Ranges**: Support expressions like `1-10 except 5` (4 hours)

---

## Approval

- **Plan Created**: 2026-01-05
- **Plan Status**: [PLANNED]
- **Ready for Implementation**: Yes
