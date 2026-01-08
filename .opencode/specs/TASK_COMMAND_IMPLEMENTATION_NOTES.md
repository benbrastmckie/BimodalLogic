# /task Command Enhancement Implementation Notes

**Status**: Phases 1 and 6 COMPLETED, Phases 2-5 and 7 PENDING  
**Created**: 2026-01-07  
**Last Updated**: 2026-01-07

---

## Overview

This document provides detailed implementation notes for the remaining phases of the /task command comprehensive enhancement plan. Phases 1 (Architecture) and 6 (Context Updates) are complete. The following phases require implementation:

- **Phase 2**: --recover flag with bulk support
- **Phase 3**: --divide flag for existing tasks
- **Phase 4**: --sync flag with git blame conflict resolution
- **Phase 5**: --abandon flag with bulk support
- **Phase 7**: Integration testing and documentation

---

## Completed Phases

### Phase 1: Update task.md Architecture to Phase 3 Standards ✅

**Completed**: 2026-01-07  
**Commit**: dabfe6d

**What was done**:
- Changed agent field from "status-sync-manager" to "orchestrator"
- Added flag detection for --recover, --divide, --sync, --abandon
- Restructured Stage 1 (ParseAndValidate) to route based on flags
- Added Stages 4-7 for new flag operations (placeholders for delegation)
- Added Stage 8 (ReturnSuccess) for operation-specific success messages
- Added validation gates at critical points
- Maintained backward compatibility with existing /task syntax

**Files modified**:
- `.opencode/command/task.md`
- `.opencode/specs/TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md`

### Phase 6: Update Core Context Files ✅

**Completed**: 2026-01-07  
**Commit**: c796817

**What was done**:
- Updated routing.md with /task flag-based routing patterns
- Added bulk operation delegation patterns to delegation.md
- Added git blame conflict resolution delegation pattern
- Added rollback mechanism delegation pattern for task division
- Documented status-sync-manager new operations (unarchive_tasks, sync_tasks)
- Added validation gates for all new flags to validation.md
- Added range parsing validation and git blame timestamp validation
- Added bulk operation validation patterns
- Updated task-management.md with comprehensive flag usage standards

**Files modified**:
- `.opencode/context/core/orchestration/routing.md`
- `.opencode/context/core/orchestration/delegation.md`
- `.opencode/context/core/orchestration/validation.md`
- `.opencode/context/core/standards/task-management.md`
- `.opencode/specs/TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md`

---

## Pending Phases

### Phase 2: Implement --recover Flag with Bulk Support

**Status**: NOT STARTED  
**Estimated Effort**: 8-10 hours  
**Dependencies**: None (can start immediately)

**Implementation Steps**:

1. **Add unarchive_tasks operation to status-sync-manager.md**:
   
   Location: `.opencode/agent/subagents/status-sync-manager.md`
   
   Add new operation flow after `archive_tasks_flow`:
   
   ```xml
   <unarchive_tasks_flow>
     <step_0_validate_inputs>
       <action>Validate unarchive_tasks inputs</action>
       <process>
         1. Validate task_numbers is non-empty array
         2. Validate all task numbers are positive integers
         3. Validate archive/state.json exists and is readable
         4. For each task number:
            - Verify task exists in archive/state.json archived_projects
            - Verify task NOT in state.json active_projects
            - If task not found or already active: collect error
         5. If any validation errors: abort with batch error report
       </process>
       <validation>All tasks exist in archive and not in active_projects</validation>
       <output>Validated task numbers</output>
     </step_0_validate_inputs>
     
     <step_1_prepare_recovery>
       <action>Prepare recovery updates</action>
       <process>
         1. Read current TODO.md content
         2. Read current state.json content
         3. Read current archive/state.json content
         4. For each task number:
            - Extract task entry from archive/state.json
            - Reset status to "not_started"
            - Reset phase to "not_started"
            - Update last_updated timestamp
            - Format TODO.md entry (insert in correct priority section)
            - Prepare for addition to state.json active_projects
            - Prepare for removal from archive/state.json archived_projects
         5. Validate all tasks found and formatted
       </process>
       <validation>All tasks located and formatted</validation>
       <output>Prepared recovery operations</output>
     </step_1_prepare_recovery>
     
     <step_2_commit>
       <action>Commit updates atomically using atomic write pattern</action>
       <process>
         1. Generate unique temp file names (include session_id):
            - todo_tmp = ".opencode/specs/TODO.md.tmp.${session_id}"
            - state_tmp = ".opencode/specs/state.json.tmp.${session_id}"
            - archive_tmp = ".opencode/specs/archive/state.json.tmp.${session_id}"
         
         2. Write to temp files:
            - Write updated TODO.md to todo_tmp
            - Write updated state.json to state_tmp
            - Write updated archive/state.json to archive_tmp
         
         3. Verify temp files written successfully:
            - Verify all temp files exist and size > 0
            - If verification fails: Remove temp files and abort
         
         4. Atomic rename (all files or none):
            - Rename todo_tmp to .opencode/specs/TODO.md
            - Rename state_tmp to .opencode/specs/state.json
            - Rename archive_tmp to .opencode/specs/archive/state.json
            - If any rename fails: Remove temp files and abort
         
         5. Clean up temp files on success
       </process>
       <rollback_on_failure>
         If any write fails:
         1. Remove all temp files
         2. Return failed status with error details
         3. Rely on git for recovery
       </rollback_on_failure>
       <validation>All three files written atomically or temp files cleaned up</validation>
       <output>Tasks recovered atomically</output>
     </step_2_commit>
     
     <step_3_move_directories>
       <action>Move task directories from archive/ to specs/ (non-critical)</action>
       <process>
         1. For each task number:
            - Find directory: archive/{number}_*
            - If directory exists:
              * Move to specs/{number}_*
              * If move fails: Log warning, continue
            - If directory not found: Skip (not all tasks have directories)
         2. Log all directory moves (success and failure)
         3. Continue even if some moves fail (non-critical)
       </process>
       <validation>Directory moves attempted (failures logged)</validation>
       <output>Directories moved (best effort)</output>
     </step_3_move_directories>
     
     <step_4_return>
       <action>Return success with recovery count</action>
       <process>
         1. Format return following subagent-return-format.md
         2. Include count of tasks recovered
         3. Include task numbers recovered
         4. Include files updated [TODO.md, state.json, archive/state.json]
         5. Include success_count and failure_count
         6. Include session_id from input
         7. Return status completed or failed
       </process>
       <output>Standardized return object with recovery count</output>
     </step_4_return>
   </unarchive_tasks_flow>
   ```

2. **Update operation routing in status-sync-manager.md**:
   
   Add to operation_routing section:
   ```
   6. If operation == "unarchive_tasks": Execute unarchive_tasks_flow
   ```

3. **Update inputs_required section**:
   
   Add parameter documentation for unarchive_tasks operation.

4. **Test the implementation**:
   
   ```bash
   # Test single task recovery
   /task --recover 343
   
   # Test range recovery
   /task --recover 343-345
   
   # Test list recovery
   /task --recover 337, 343-345, 350
   
   # Test error handling
   /task --recover 999  # Task not in archive
   /task --recover 343  # Task already active
   ```

**Acceptance Criteria**:
- [ ] unarchive_tasks operation added to status-sync-manager.md
- [ ] Single task recovery works
- [ ] Range recovery works (343-345)
- [ ] List recovery works (337, 343-345, 350)
- [ ] All tasks appear in TODO.md with [NOT STARTED] status
- [ ] All tasks appear in state.json active_projects
- [ ] All tasks removed from archive/state.json
- [ ] Directories moved from archive/ to specs/ (if exist)
- [ ] Git commit created with task count and ranges
- [ ] Error messages report all failures clearly
- [ ] Atomic guarantee: all tasks recovered or none

---

### Phase 3: Implement --divide Flag for Existing Tasks

**Status**: NOT STARTED  
**Estimated Effort**: 8-10 hours  
**Dependencies**: None (can start immediately)

**Implementation Steps**:

1. **Check if task-divider subagent exists**:
   
   ```bash
   ls .opencode/agent/subagents/task-divider.md
   ```
   
   If not exists, create it based on the inline division logic in task.md Stage 2.

2. **Enhance task-divider to support existing task analysis**:
   
   Add capability to:
   - Read task metadata from state.json
   - Analyze task description for natural divisions
   - Accept optional prompt for division guidance
   - Return 1-5 subtask descriptions

3. **Implement rollback mechanism**:
   
   In task.md Stage 5 (DivideExistingTask):
   - Track created subtasks during loop
   - On failure: Delete created subtasks from TODO.md and state.json
   - Restore next_project_number to original value
   - Return error with rollback details

4. **Add update_task_metadata operation to status-sync-manager** (if not exists):
   
   This operation should update specific fields of a task without changing others.

5. **Test the implementation**:
   
   ```bash
   # Test basic division
   /task --divide 326
   
   # Test division with prompt
   /task --divide 326 "Focus on UI, backend, tests"
   
   # Test error handling
   /task --divide 999   # Task not found
   /task --divide 326   # Task already has dependencies
   /task --divide 326   # Task is COMPLETED
   ```

**Acceptance Criteria**:
- [ ] task-divider subagent supports existing task analysis
- [ ] Division creates 1-5 subtasks based on analysis
- [ ] Parent task updated with subtask dependencies
- [ ] Rollback works on partial failure
- [ ] Git commit created
- [ ] Error messages are clear and actionable

---

### Phase 4: Implement --sync Flag with Git Blame Conflict Resolution

**Status**: NOT STARTED  
**Estimated Effort**: 10-12 hours  
**Dependencies**: None (can start immediately)

**Implementation Steps**:

1. **Add sync_tasks operation to status-sync-manager.md**:
   
   This is the most complex operation. It requires:
   
   ```xml
   <sync_tasks_flow>
     <step_0_validate_inputs>
       <action>Validate sync_tasks inputs</action>
       <process>
         1. Validate task_ranges parameter:
            - If "all": sync all tasks
            - If array: validate all task numbers are positive integers
         2. Validate state.json exists and is readable
         3. Validate TODO.md exists and is readable
         4. If task_ranges is array:
            - Verify all tasks exist in TODO.md or state.json
            - If task not found: collect error
         5. If any validation errors: abort with batch error report
       </process>
       <validation>All inputs valid</validation>
       <output>Validated task ranges</output>
     </step_0_validate_inputs>
     
     <step_1_analyze_differences>
       <action>Compare TODO.md and state.json for each task</action>
       <process>
         1. For each task in scope:
            - Parse task entry from TODO.md
            - Parse task entry from state.json
            - Compare all fields: status, priority, effort, description, dependencies, etc.
            - If any field differs: Mark task as "has_discrepancy"
            - Record which fields differ
         2. Categorize tasks:
            - only_in_todo: Tasks in TODO.md but not in state.json
            - only_in_state: Tasks in state.json but not in TODO.md
            - in_both_with_discrepancies: Tasks in both with differences
         3. Log analysis results
       </process>
       <validation>All tasks analyzed</validation>
       <output>Discrepancy report</output>
     </step_1_analyze_differences>
     
     <step_2_resolve_conflicts_with_git_blame>
       <action>Use git blame to resolve conflicts</action>
       <process>
         1. For tasks with discrepancies:
            For each differing field:
              a. Get TODO.md timestamp:
                 - Find task entry line range in TODO.md
                 - Run: git blame -L <start>,<end> TODO.md
                 - Extract commit hash for field line
                 - Run: git show -s --format=%ct <commit_hash>
                 - Store timestamp_todo
              
              b. Get state.json timestamp:
                 - Run: git log -1 --format=%ct -S "\"project_number\": <task_number>" -- state.json
                 - Store timestamp_state
              
              c. Compare timestamps:
                 - If timestamp_state > timestamp_todo: Use state.json value
                 - If timestamp_todo > timestamp_state: Use TODO.md value
                 - If timestamps equal: Use state.json value (tie-breaker)
              
              d. Log conflict resolution:
                 - "Task {number} field '{field}': {winner} ({timestamp}) > {loser} ({timestamp})"
         
         2. For tasks only in one file:
            - Run git blame to check if task was deleted from other file
            - If deleted recently: Respect deletion (remove from both)
            - If never existed: Add to other file
         
         3. Build merged task objects using resolved field values
       </process>
       <validation>All conflicts resolved</validation>
       <output>Merged task objects with conflict resolution log</output>
     </step_2_resolve_conflicts_with_git_blame>
     
     <step_3_prepare_updates>
       <action>Prepare synchronized updates</action>
       <process>
         1. For each task:
            - Format TODO.md entry from merged object
            - Format state.json entry from merged object
            - Ensure consistency across all fields
         2. Update TODO.md content in memory
         3. Update state.json content in memory
         4. Validate both updates well-formed
       </process>
       <validation>Updates prepared correctly</validation>
       <output>Updated TODO.md and state.json content in memory</output>
     </step_3_prepare_updates>
     
     <step_4_commit>
       <action>Commit updates atomically</action>
       <process>
         1. Generate unique temp file names
         2. Write to temp files
         3. Verify temp files written successfully
         4. Atomic rename (both files or neither)
         5. Clean up temp files on success
       </process>
       <validation>Both files written atomically</validation>
       <output>Tasks synchronized</output>
     </step_4_commit>
     
     <step_5_return>
       <action>Return success with sync details</action>
       <process>
         1. Format return following subagent-return-format.md
         2. Include synced_tasks count
         3. Include conflicts_resolved count
         4. Include conflict resolution details
         5. Include files updated [TODO.md, state.json]
         6. Include session_id from input
         7. Return status completed or failed
       </process>
       <output>Standardized return object with sync details</output>
     </step_5_return>
   </sync_tasks_flow>
   ```

2. **Implement git blame helper functions**:
   
   These can be bash functions within the process flow or separate utility functions.

3. **Test the implementation**:
   
   ```bash
   # Setup: Create conflict scenario
   # 1. Edit task 343 status in TODO.md, commit
   # 2. Edit task 343 status in state.json, commit (newer)
   
   # Test sync all
   /task --sync
   
   # Test sync range
   /task --sync 343-345
   
   # Test sync list
   /task --sync 337, 343-345
   
   # Verify conflict resolution
   # - Check that state.json value was used (newer commit)
   # - Check conflict resolution logged
   ```

**Acceptance Criteria**:
- [ ] sync_tasks operation added to status-sync-manager.md
- [ ] Sync all tasks works (default behavior)
- [ ] Sync specific ranges works
- [ ] Git blame conflict resolution works correctly
- [ ] Conflicts resolved using latest commit
- [ ] Conflict resolution logged clearly
- [ ] TODO.md and state.json synchronized
- [ ] Git commit created with conflict resolution summary

---

### Phase 5: Implement --abandon Flag with Bulk Support

**Status**: NOT STARTED  
**Estimated Effort**: 4-6 hours  
**Dependencies**: None (can start immediately)

**Implementation Steps**:

1. **Verify archive_tasks operation exists in status-sync-manager.md**:
   
   The operation already exists (confirmed in earlier analysis). Just need to ensure it:
   - Supports bulk operations (array of task numbers)
   - Uses atomic two-phase commit
   - Updates TODO.md, state.json, and archive/state.json

2. **Update archive_tasks to support "abandoned" reason**:
   
   Add reason parameter to distinguish between completed and abandoned tasks.

3. **Test the implementation**:
   
   ```bash
   # Test abandon range
   /task --abandon 343-345
   
   # Test abandon list
   /task --abandon 337, 343-345, 350
   
   # Test error handling
   /task --abandon 999  # Task not found
   /task --abandon 343  # Task already abandoned
   ```

**Acceptance Criteria**:
- [ ] archive_tasks operation supports "abandoned" reason
- [ ] Abandon range works (343-345)
- [ ] Abandon list works (337, 343-345, 350)
- [ ] Tasks moved to archive/
- [ ] TODO.md and state.json updated
- [ ] archive/state.json updated
- [ ] Git commit created
- [ ] Error messages are clear and actionable

---

### Phase 7: Integration Testing and Documentation

**Status**: NOT STARTED  
**Estimated Effort**: 6-8 hours  
**Dependencies**: Phases 2-5 must be complete

**Implementation Steps**:

1. **Create comprehensive test suite**:
   
   Test each flag individually:
   - [ ] /task --recover (single, range, list)
   - [ ] /task --divide (basic, with prompt)
   - [ ] /task --sync (all, range, list)
   - [ ] /task --abandon (range, list)
   
   Test flag combinations (should error):
   - [ ] /task --recover 343 --divide 344 (error: multiple flags)
   - [ ] /task --sync --abandon 343 (error: multiple flags)
   
   Test backward compatibility:
   - [ ] /task "description" (basic creation)
   - [ ] /task "description" --priority High (with flags)
   - [ ] /task "description" --divide (inline division)
   
   Test error handling:
   - [ ] Invalid range formats
   - [ ] Tasks not found
   - [ ] Tasks already active/abandoned
   - [ ] Validation failures
   
   Test rollback mechanisms:
   - [ ] Division rollback on subtask creation failure
   - [ ] Atomic updates (all or nothing)
   
   Test git commit integration:
   - [ ] All operations create git commits
   - [ ] Commit messages are descriptive

2. **Update documentation**:
   
   - [ ] Update task.md with all flag descriptions (already done in Phase 1)
   - [ ] Update status-sync-manager.md with new operations
   - [ ] Update user guide with flag usage examples
   - [ ] Update architecture documentation

3. **Performance testing**:
   
   - [ ] Verify all operations complete within 120s timeout
   - [ ] Verify atomic operations are fast (<5s for single task)
   - [ ] Verify bulk operations scale (e.g., --abandon 100 tasks)

4. **Create migration guide**:
   
   - [ ] Document changes from old commands to new flags
   - [ ] Provide examples for common workflows
   - [ ] Document rollback procedures

**Acceptance Criteria**:
- [ ] All test cases pass
- [ ] Documentation updated
- [ ] Performance targets met
- [ ] Migration guide created

---

## Implementation Priority

Recommended implementation order:

1. **Phase 5** (--abandon): Easiest, reuses existing archive_tasks operation (4-6 hours)
2. **Phase 2** (--recover): Medium complexity, mirrors archive_tasks (8-10 hours)
3. **Phase 3** (--divide): Medium complexity, requires rollback mechanism (8-10 hours)
4. **Phase 4** (--sync): Most complex, requires git blame implementation (10-12 hours)
5. **Phase 7** (Testing): Final integration and documentation (6-8 hours)

**Total remaining effort**: 36-46 hours

---

## Key Implementation Patterns

### Atomic Two-Phase Commit

All operations that modify multiple files must use atomic two-phase commit:

```bash
# Phase 1: Prepare (write to temp files)
todo_tmp=".opencode/specs/TODO.md.tmp.${session_id}"
state_tmp=".opencode/specs/state.json.tmp.${session_id}"

echo "$updated_todo" > "$todo_tmp"
echo "$updated_state" > "$state_tmp"

# Phase 2: Commit (atomic rename)
mv "$todo_tmp" ".opencode/specs/TODO.md"
mv "$state_tmp" ".opencode/specs/state.json"

# Cleanup
rm -f "$todo_tmp" "$state_tmp"
```

### Range Parsing

All bulk operations use the same range parsing logic:

```bash
parse_ranges() {
  local ranges="$1"
  local task_numbers=()
  
  IFS=',' read -ra parts <<< "$ranges"
  
  for part in "${parts[@]}"; do
    part=$(echo "$part" | tr -d ' ')
    
    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      start="${BASH_REMATCH[1]}"
      end="${BASH_REMATCH[2]}"
      for ((i=start; i<=end; i++)); do
        task_numbers+=("$i")
      done
    elif [[ "$part" =~ ^[0-9]+$ ]]; then
      task_numbers+=("$part")
    else
      echo "[FAIL] Invalid range format: $part"
      exit 1
    fi
  done
  
  printf '%s\n' "${task_numbers[@]}" | sort -nu
}
```

### Git Blame Conflict Resolution

For sync operation, use git blame to determine latest version:

```bash
# Get TODO.md timestamp
get_todo_timestamp() {
  local task_number="$1"
  local field="$2"
  
  start_line=$(grep -n "^### ${task_number}\." TODO.md | cut -d: -f1)
  end_line=$(tail -n +$start_line TODO.md | grep -n "^---$" | head -1 | cut -d: -f1)
  end_line=$((start_line + end_line - 1))
  
  commit_hash=$(git blame -L ${start_line},${end_line} TODO.md | grep "$field" | awk '{print $1}')
  timestamp=$(git show -s --format=%ct "$commit_hash")
  
  echo "$timestamp"
}

# Get state.json timestamp
get_state_timestamp() {
  local task_number="$1"
  
  timestamp=$(git log -1 --format=%ct -S "\"project_number\": $task_number" -- state.json)
  
  echo "$timestamp"
}

# Resolve conflict
resolve_conflict() {
  local task_number="$1"
  local field="$2"
  local todo_ts=$(get_todo_timestamp "$task_number" "$field")
  local state_ts=$(get_state_timestamp "$task_number")
  
  if [ "$state_ts" -gt "$todo_ts" ]; then
    echo "state.json"
  elif [ "$todo_ts" -gt "$state_ts" ]; then
    echo "TODO.md"
  else
    echo "state.json"  # Tie-breaker
  fi
}
```

---

## Testing Checklist

Before marking any phase as complete, verify:

- [ ] Operation works for single task
- [ ] Operation works for range (if applicable)
- [ ] Operation works for list (if applicable)
- [ ] Error handling works for all edge cases
- [ ] Atomic updates work (all or nothing)
- [ ] Git commit created with descriptive message
- [ ] Return format follows subagent-return-format.md
- [ ] Validation gates prevent invalid inputs
- [ ] Rollback works on failure (if applicable)
- [ ] Performance is acceptable (<120s timeout)

---

## Notes

- All operations delegate to status-sync-manager for atomic updates
- All operations use two-phase commit for file updates
- All operations create git commits for state changes
- All operations follow subagent-return-format.md for returns
- All operations support clear error messages with recovery suggestions
- Bulk operations support range syntax: "343-345" and list syntax: "337, 343-345"
- Git blame conflict resolution uses latest commit timestamp to determine winner

---

**End of Implementation Notes**
