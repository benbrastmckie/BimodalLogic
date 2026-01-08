# /task Command Comprehensive Enhancement Plan

**Project**: ProofChecker .opencode Agent System  
**Issue**: Enhance /task command with advanced flags while maintaining architectural integrity  
**Created**: 2026-01-07  
**Revised**: 2026-01-07 (v2.0 - bulk operations, git blame conflict resolution)  
**Based On**: 
- TASK_COMMAND_IMPROVEMENT_PLAN.md (Phase 3 standards)
- Tasks 325 (--recover), 326 (--divide), 330 (--sync), 331 (--abandon)  
**Estimated Duration**: 42-54 hours  
**Status**: Phases 1 and 6 COMPLETED (architecture and documentation), Phases 2-5 and 7 require status-sync-manager implementation

---

## Executive Summary

### Problem Statement

The `/task` command currently supports basic task creation with inline division (`--divide` for new tasks). However, users need additional capabilities to manage the task lifecycle:

1. **Recovery**: Unarchive completed/abandoned tasks from archive/ with bulk support (Task 325)
2. **Division**: Divide existing tasks into subtasks with dependencies (Task 326)
3. **Synchronization**: Sync TODO.md and state.json using git blame for conflict resolution (Task 330)
4. **Bulk Abandonment**: Abandon multiple tasks via ranges/lists (Task 331)

These enhancements must be implemented while maintaining the architectural standards established in Phase 3 of TASK_COMMAND_IMPROVEMENT_PLAN.md:
- ✅ Clear separation of concerns (command orchestrates, subagents execute)
- ✅ Validation gates at critical points
- ✅ Explicit return format with validation
- ✅ Structural enforcement over prompt-based constraints
- ✅ Minimal inline logic (delegate complex operations)

### Solution Approach

Implement four new flags for the `/task` command following the Phase 3 refactoring pattern:

```
/task --recover TASK_RANGES              # Unarchive tasks from archive/ (bulk support)
/task --divide TASK_NUMBER [PROMPT]      # Divide existing task into subtasks (single task only)
/task --sync [TASK_RANGES]               # Sync TODO.md ↔ state.json (git blame conflict resolution)
/task --abandon TASK_RANGES              # Abandon multiple tasks (bulk support)
```

**Key Features**:
- **Bulk Operations**: --recover, --sync, and --abandon support ranges/lists (e.g., "343-345, 337")
- **Git Blame Conflict Resolution**: --sync uses git blame to determine latest version when discrepancies exist
- **Single Task Division**: --divide operates on one task at a time (no bulk support needed)

Each flag will:
1. Parse and validate inputs in Stage 1 (ParseAndValidate)
2. Route to specialized subagent for execution
3. Validate return format and artifacts
4. Return clear success/error messages

### Architectural Alignment with Phase 3

This plan maintains Phase 3 standards from TASK_COMMAND_IMPROVEMENT_PLAN.md:

**Phase 3 Architecture** (from improvement plan):
```
User: /task "description"
  ↓
Orchestrator: Load .opencode/command/task.md
  ↓
Task Command (agent: orchestrator):
  ├─ Stage 1: ParseAndValidate
  │   └─ Extract description, flags
  │   └─ Validate inputs
  │   └─ VALIDATION GATE: Detect implementation keywords
  ├─ Stage 2: PrepareTasks
  │   └─ If --divide: Delegate to task-divider subagent
  │   └─ Else: Single task
  │   └─ VALIDATION GATE: Ensure task list is 1-5 tasks
  ├─ Stage 3: CreateTasks
  │   └─ For each task: Delegate to task-creator subagent
  │       └─ task-creator: Reformulate + Create entry
  │   └─ VALIDATION GATE: Verify task numbers returned
  └─ Stage 4: ReturnSuccess
      └─ Format success message
      └─ Return task numbers ONLY
      └─ VALIDATION GATE: No artifacts created
```

**Enhanced Architecture** (with new flags):
```
User: /task [--recover|--divide|--sync|--abandon] ARGS
  ↓
Orchestrator: Load .opencode/command/task.md
  ↓
Task Command (agent: orchestrator):
  ├─ Stage 1: ParseAndValidate
  │   └─ Detect flag: --recover, --divide, --sync, --abandon, or none
  │   └─ Extract arguments based on flag
  │   └─ Validate inputs
  │   └─ VALIDATION GATE: Prevent implementation keywords
  │   └─ Route to appropriate stage based on flag
  │
  ├─ Stage 2: PrepareTasks (if no flag or --divide for new task)
  │   └─ If --divide (inline): Delegate to task-divider subagent
  │   └─ Else: Single task
  │   └─ VALIDATION GATE: Ensure task list is 1-5 tasks
  │
  ├─ Stage 3: CreateTasks (if no flag)
  │   └─ For each task: Delegate to task-creator subagent
  │   └─ VALIDATION GATE: Verify task numbers returned
  │
  ├─ Stage 4: RecoverTasks (if --recover)
  │   └─ Parse task ranges (support bulk: "343-345, 337")
  │   └─ Delegate to status-sync-manager (unarchive_tasks operation - bulk)
  │   └─ VALIDATION GATE: Verify tasks recovered, files updated
  │
  ├─ Stage 5: DivideExistingTask (if --divide TASK_NUMBER)
  │   └─ Delegate to task-divider subagent (analyze existing task)
  │   └─ Delegate to task-creator subagent (create subtasks)
  │   └─ Delegate to status-sync-manager (update parent dependencies)
  │   └─ VALIDATION GATE: Verify subtasks created, parent updated
  │
  ├─ Stage 6: SyncTasks (if --sync)
  │   └─ Parse task ranges (optional, default: all tasks)
  │   └─ Delegate to status-sync-manager (sync_tasks operation)
  │   └─ Use git blame to resolve conflicts (latest commit wins)
  │   └─ VALIDATION GATE: Verify sync completed, files updated
  │
  ├─ Stage 7: AbandonTasks (if --abandon)
  │   └─ Delegate to status-sync-manager (archive_tasks operation)
  │   └─ VALIDATION GATE: Verify tasks abandoned, files updated
  │
  └─ Stage 8: ReturnSuccess
      └─ Format success message based on operation
      └─ Return task numbers/ranges ONLY
      └─ VALIDATION GATE: No artifacts created
```

### Scope

**In Scope**:
- Add `--recover TASK_RANGES` flag with bulk support (Task 325)
- Add `--divide TASK_NUMBER [PROMPT]` flag for single tasks (Task 326)
- Add `--sync [TASK_RANGES]` flag with git blame conflict resolution (Task 330)
- Add `--abandon TASK_RANGES` flag with bulk support (Task 331)
- Implement git blame-based conflict resolution for --sync
- Support range/list parsing for bulk operations (e.g., "343-345, 337")
- Update task.md to route to specialized subagents
- Add validation gates for each operation
- Maintain Phase 3 architectural standards
- Comprehensive error handling
- Git commit integration for all operations

**Out of Scope**:
- Creating new subagents (use existing: status-sync-manager, task-divider, task-creator)
- Changing existing task creation flow (preserve backward compatibility)
- Bulk division (--divide operates on single task only)
- Status preservation for recovery (always resets to NOT STARTED)
- Dry-run mode for sync (avoid needless complexity per task 330)
- Interactive conflict resolution (git blame determines winner automatically)

### Constraints

- Must maintain backward compatibility with existing `/task "description"` syntax
- Must follow Phase 3 architectural pattern (orchestrate, don't implement)
- Must delegate to specialized subagents (no inline complex logic)
- Must use validation gates at critical points
- Must use atomic two-phase commit for state updates
- Must create git commits for all state changes
- Must return clear, actionable error messages
- Must complete within 120s timeout per operation

### Definition of Done

- [NOT STARTED] All four flags implemented and tested
- [NOT STARTED] Backward compatibility maintained
- [NOT STARTED] Phase 3 architectural standards followed
- [NOT STARTED] Validation gates prevent architectural violations
- [NOT STARTED] All operations delegate to subagents
- [NOT STARTED] Git commits created for all state changes
- [NOT STARTED] Error handling covers all edge cases
- [NOT STARTED] Documentation updated
- [NOT STARTED] Manual testing confirms all flags work end-to-end

---

## Research Integration

This plan integrates findings from multiple research reports and existing plans:

**Integrated Sources**:

1. **TASK_COMMAND_IMPROVEMENT_PLAN.md** (Phase 3):
   - Key Finding: Phase 3 refactoring provides long-term robustness
   - Key Finding: task-divider and task-creator subagents separate concerns
   - Key Finding: Validation gates prevent architectural violations
   - Recommendation: Change agent field to "orchestrator"
   - Recommendation: Delegate complex operations to subagents
   - Recommendation: Minimal inline logic in command file

2. **Task 325 Implementation Plan** (--recover flag):
   - Key Finding: Archive system uses atomic two-phase commit
   - Key Finding: 130 projects currently archived with full metadata
   - Key Finding: Recovery requires new operation: unarchive_tasks (bulk support)
   - Recommendation: Add `--recover TASK_RANGES` flag with bulk support
   - Recommendation: Reset status to NOT STARTED by default
   - Recommendation: Treat directory move as non-critical
   - **Revision**: Changed from single task to bulk support (ranges/lists)

3. **Task 326 Research Report** (--divide flag):
   - Key Finding: Existing --divide flag works for NEW task creation only
   - Key Finding: Task 189 researched subdivision patterns (3-5 subtasks optimal)
   - Key Finding: status-sync-manager supports create_task but NOT bulk creation
   - Key Finding: Dependency management requires updating parent task metadata
   - Recommendation: Add `/task --divide TASK_NUMBER [PROMPT]` syntax
   - Recommendation: Analyze parent task description for natural divisions
   - Recommendation: Parent depends on subtasks (not vice versa)

4. **Task 330 Description** (--sync flag):
   - Requirement: Sync TODO.md and state.json for specific task ranges
   - Requirement: Accept optional task ranges (e.g., 343-345, 337)
   - Requirement: Sync all tasks if no ranges provided
   - Requirement: Improve upon current /sync command (avoid complexity)
   - Requirement: Omit dry-run mode
   - **Revision**: Use git blame to resolve conflicts (latest commit wins)
   - **Revision**: Default behavior syncs ALL tasks when no ranges specified

5. **Task 331 Description** (--abandon flag):
   - Requirement: Abandon multiple tasks via ranges/lists
   - Requirement: Similar to /abandon command behavior
   - Requirement: Avoid needless complexity
   - Pattern: Reuse range/list parsing from task 311

---

## Goals and Non-Goals

### Goals

1. **Unified Task Management**: Provide comprehensive task lifecycle management in one command
2. **Architectural Consistency**: Follow Phase 3 standards across all flags
3. **Separation of Concerns**: Command orchestrates, subagents execute
4. **Validation Gates**: Prevent architectural violations at critical points
5. **Atomic Operations**: All state changes are atomic (all or nothing)
6. **Bulk Operations**: Support efficient bulk recovery, sync, and abandonment
7. **Git Blame Conflict Resolution**: Use git history to resolve sync conflicts automatically
8. **Clear Error Messages**: Guide users to correct usage
9. **Backward Compatibility**: Existing `/task "description"` syntax still works

### Non-Goals

1. **Bulk Division**: --divide operates on single task only (not needed for this use case)
2. **Status Preservation**: Recovery always resets to NOT STARTED (future enhancement)
3. **Dry-Run Mode**: --sync omits dry-run (avoid complexity per task 330)
4. **Interactive Conflict Resolution**: --sync uses git blame automatically (no user prompts)
5. **Interactive Division**: --divide uses AI analysis, not interactive prompts
6. **Custom Subagents**: Use existing subagents (status-sync-manager, task-divider, task-creator)

---

## Git Blame Conflict Resolution Algorithm

### Overview

When `/task --sync` encounters discrepancies between TODO.md and state.json for the same task, it uses git blame to determine which version is more recent. The version with the latest commit timestamp wins.

### Algorithm Steps

**Step 1: Identify Discrepancies**
```
For each task in sync scope:
  1. Parse task entry from TODO.md
  2. Parse task entry from state.json
  3. Compare all fields: status, priority, effort, description, artifacts, etc.
  4. If any field differs: Mark task as "has_discrepancy"
  5. Record which fields differ
```

**Step 2: Get Git Blame Timestamps**
```
For each task with discrepancies:
  For each differing field:
    1. Get TODO.md timestamp:
       - Run: git blame -L <start_line>,<end_line> TODO.md
       - Parse commit hash for the line containing the field
       - Run: git show -s --format=%ct <commit_hash>
       - Store timestamp_todo
    
    2. Get state.json timestamp:
       - Run: git log -1 --format=%ct -- state.json
       - For more precision: git log -S "project_number.*<task_number>" --format=%ct -- state.json
       - Store timestamp_state
```

**Step 3: Resolve Conflicts**
```
For each differing field:
  1. Compare timestamps: timestamp_todo vs timestamp_state
  2. If timestamp_state > timestamp_todo:
     - Use state.json value
     - Log: "Task {number} field '{field}': state.json ({timestamp_state}) > TODO.md ({timestamp_todo}) → state.json wins"
  3. If timestamp_todo > timestamp_state:
     - Use TODO.md value
     - Log: "Task {number} field '{field}': TODO.md ({timestamp_todo}) > state.json ({timestamp_state}) → TODO.md wins"
  4. If timestamps equal:
     - Use state.json value (tie-breaker: state.json is source of truth)
     - Log: "Task {number} field '{field}': timestamps equal → state.json wins (tie-breaker)"
```

**Step 4: Apply Resolved Values**
```
For each task:
  1. Build merged task object using resolved field values
  2. Format TODO.md entry from merged object
  3. Format state.json entry from merged object
  4. Prepare atomic update
```

### Example Scenario

**Setup**:
```bash
# Initial state (both files in sync)
Task 343: status=[NOT STARTED], priority=high

# User edits TODO.md
# Changes status to [IN PROGRESS]
git commit -m "task 343: start work" TODO.md
# Timestamp: 2026-01-07 10:00:00 (1704621600)

# User edits state.json
# Changes status to [RESEARCHED]
git commit -m "task 343: research complete" state.json
# Timestamp: 2026-01-07 11:00:00 (1704625200)

# Now files are out of sync
TODO.md:     status=[IN PROGRESS]  (timestamp: 1704621600)
state.json:  status=[RESEARCHED]   (timestamp: 1704625200)
```

**Sync Execution**:
```bash
/task --sync 343

# Algorithm:
# 1. Identify discrepancy: status field differs
# 2. Get timestamps:
#    - TODO.md status: 1704621600 (10:00:00)
#    - state.json status: 1704625200 (11:00:00)
# 3. Resolve conflict:
#    - 1704625200 > 1704621600
#    - state.json wins
#    - Log: "Task 343 field 'status': state.json (1704625200) > TODO.md (1704621600) → state.json wins"
# 4. Apply resolved value:
#    - Update TODO.md status to [RESEARCHED]
#    - Keep state.json status as [RESEARCHED]
# 5. Commit:
#    - git commit -m "task: sync TODO.md and state.json for 1 task (343)"
```

**Result**:
```
Both files now have: status=[RESEARCHED]
Conflict resolved automatically using git blame
```

### Edge Cases

**Case 1: Task Only in TODO.md**
```
Action: Check git log to see if task was deleted from state.json
If deleted recently: Remove from TODO.md (respect deletion)
If never existed: Add to state.json (new task)
```

**Case 2: Task Only in state.json**
```
Action: Check git log to see if task was deleted from TODO.md
If deleted recently: Remove from state.json (respect deletion)
If never existed: Add to TODO.md (new task)
```

**Case 3: Multiple Fields Differ**
```
Action: Resolve each field independently using git blame
Example:
  - status: state.json wins (newer)
  - priority: TODO.md wins (newer)
  - effort: state.json wins (newer)
Result: Merged task with best-of-both
```

**Case 4: Git Blame Fails**
```
Fallback: Use state.json as source of truth
Log warning: "Git blame failed for task {number}, using state.json"
```

### Implementation Details

**Git Blame Command for TODO.md**:
```bash
# Get line range for task 343 in TODO.md
grep -n "^### 343\." TODO.md  # Start line
grep -n "^---$" TODO.md | awk -v start=<start_line> '$1 > start {print; exit}'  # End line

# Get blame for line range
git blame -L <start>,<end> TODO.md

# Extract commit hash for specific field (e.g., status line)
git blame -L <start>,<end> TODO.md | grep "Status:" | awk '{print $1}'

# Get commit timestamp
git show -s --format=%ct <commit_hash>
```

**Git Blame Command for state.json**:
```bash
# Get last commit that modified task 343 in state.json
git log -1 --format=%ct -S "\"project_number\": 343" -- state.json

# More precise: Get commit that modified specific field
git log -1 --format=%ct -S "\"project_number\": 343.*\"status\"" -- state.json
```

**Performance Optimization**:
```
1. Batch git blame calls (one per file, not per field)
2. Cache commit timestamps (avoid redundant git show calls)
3. Use git log --all-match for precise field tracking
4. Limit git log depth (--max-count=10) for recent changes
```

### Logging and Reporting

**Conflict Resolution Log**:
```
Task 343: 3 fields resolved
  - status: state.json (2026-01-07 11:00:00) > TODO.md (2026-01-07 10:00:00) → state.json wins
  - priority: TODO.md (2026-01-07 12:00:00) > state.json (2026-01-07 09:00:00) → TODO.md wins
  - effort: timestamps equal → state.json wins (tie-breaker)

Task 344: 1 field resolved
  - description: TODO.md (2026-01-07 14:00:00) > state.json (2026-01-07 13:00:00) → TODO.md wins

Summary: 2 tasks synced, 4 conflicts resolved
```

**Git Commit Message**:
```
task: sync TODO.md and state.json for 2 tasks (343-344)

Conflict resolution:
- Task 343: 3 fields resolved (2 from state.json, 1 from TODO.md)
- Task 344: 1 field resolved (1 from TODO.md)

Total: 4 conflicts resolved using git blame
```

---

## Implementation Phases

### Phase 1: Update task.md Architecture to Phase 3 Standards [COMPLETED]

**Objective**: Refactor task.md to follow Phase 3 architectural pattern

**Tasks**:
1. Change agent field from `status-sync-manager` to `orchestrator`
2. Simplify Stage 1 (ParseAndValidate):
   - Detect flag: --recover, --divide, --sync, --abandon, or none
   - Extract arguments based on flag
   - Validate inputs
   - Add validation gate to prevent implementation keywords
   - Route to appropriate stage based on flag
3. Update Stage 2 (PrepareTasks):
   - Keep existing logic for inline --divide (new task creation)
   - Delegate to task-divider subagent if --divide present
   - Validation gate: Ensure task list is 1-5 tasks
4. Update Stage 3 (CreateTasks):
   - Keep existing logic for task creation
   - Delegate to task-creator subagent for each task
   - Validation gate: Verify task numbers returned
5. Add Stage 8 (ReturnSuccess):
   - Format success message based on operation
   - Return task numbers/ranges ONLY
   - Validation gate: No artifacts created

**Acceptance Criteria**:
- [COMPLETED] agent field changed to "orchestrator"
- [COMPLETED] Stage 1 detects all flags and routes correctly
- [COMPLETED] Validation gates added at critical points
- [COMPLETED] Existing task creation flow still works
- [COMPLETED] Backward compatibility maintained

**Estimated Effort**: 3-4 hours
**Actual Effort**: 1 hour

---

### Phase 2: Implement --recover Flag with Bulk Support (Task 325) [NOT STARTED]

**Objective**: Add --recover flag to unarchive tasks from archive/ with bulk support

**Tasks**:
1. Add Stage 4 (RecoverTasks) to task.md:
   - Parse task_ranges from arguments (support ranges/lists: "343-345, 337")
   - Validate task ranges are positive integers
   - Expand ranges to individual task numbers
   - Delegate to status-sync-manager with operation "unarchive_tasks" (bulk)
   - Wait for return
   - Validate return: status == "completed", files_updated includes [TODO.md, state.json, archive/state.json]
   - Return success message with count and task numbers
2. Implement unarchive_tasks operation in status-sync-manager (bulk support):
   - step_0_validate_inputs: 
     * Validate all tasks exist in archive
     * Validate no tasks already in active_projects
     * Collect validation errors for batch reporting
   - step_1_prepare_recovery: 
     * For each task: Format entries, reset status to NOT STARTED
     * Prepare batch updates for TODO.md, state.json, archive/state.json
   - step_2_commit: 
     * Atomic write (all tasks or none)
     * Use two-phase commit for all three files
   - step_3_move_directories: 
     * Move directories for all tasks (if exist, non-critical)
     * Log warnings for failures, continue
   - step_4_return: 
     * Return task_numbers array, files_updated, success_count, failure_count
3. Add range parsing logic:
   - Reuse patterns from task 311 (abandon command)
   - Support single numbers: "337"
   - Support ranges: "343-345"
   - Support lists: "337, 343-345, 350"
   - Validate and deduplicate
4. Add git commit integration:
   - Delegate to git-workflow-manager after successful recovery
   - Commit message: "task: recover {count} tasks from archive ({ranges})"
5. Add error handling:
   - Tasks not found in archive (report all missing)
   - Tasks already active (report all conflicts)
   - Archive state.json missing or corrupted
   - Directory move failures (non-critical, log warnings)
   - Partial recovery failure (rollback all or report partial success)

**Acceptance Criteria**:
- [NOT STARTED] /task --recover 123 unarchives single task 123
- [NOT STARTED] /task --recover 343-345 unarchives tasks 343, 344, 345
- [NOT STARTED] /task --recover 337, 343-345 unarchives tasks 337, 343, 344, 345
- [NOT STARTED] All tasks appear in TODO.md with [NOT STARTED] status
- [NOT STARTED] All tasks appear in state.json active_projects
- [NOT STARTED] All tasks removed from archive/state.json
- [NOT STARTED] Directories moved from archive/ to specs/ (if exist)
- [NOT STARTED] Git commit created with task count and ranges
- [NOT STARTED] Error messages report all failures clearly
- [NOT STARTED] Atomic guarantee: all tasks recovered or none (or partial with clear reporting)

**Estimated Effort**: 8-10 hours (increased from 6-8 for bulk support)

**Reference**: Task 325 implementation plan (revised for bulk operations)

---

### Phase 3: Implement --divide Flag for Existing Tasks (Task 326) [NOT STARTED]

**Objective**: Add --divide flag to divide existing tasks into subtasks

**Tasks**:
1. Add Stage 5 (DivideExistingTask) to task.md:
   - Parse task_number and optional_prompt from arguments
   - Validate task_number is positive integer
   - Read task metadata from state.json
   - Validate task exists, status allows division, no existing dependencies
   - Delegate to task-divider subagent for analysis:
     * Input: task description + optional_prompt
     * Output: Array of subtask descriptions (1-5)
   - Allocate N task numbers from next_project_number
   - For each subtask:
     * Delegate to task-creator subagent
     * Collect task_number from return
     * If any creation fails: Rollback and abort
   - Delegate to status-sync-manager to update parent dependencies:
     * operation: "update_task_metadata"
     * updated_fields: {"dependencies": [subtask_numbers]}
   - Return success message
2. Enhance task-divider subagent (if needed):
   - Support analyzing existing task (read from state.json)
   - Support optional prompt for division guidance
   - Return 1-5 subtask descriptions
3. Add rollback mechanism:
   - Track created subtasks during loop
   - On failure: Delete created subtasks
   - Restore next_project_number
   - Return error with rollback details
4. Add git commit integration:
   - Delegate to git-workflow-manager after successful division
   - Commit message: "task: divide task {number} into {N} subtasks"

**Acceptance Criteria**:
- [NOT STARTED] /task --divide 326 divides task 326 into subtasks
- [NOT STARTED] Subtasks created with dependencies to parent
- [NOT STARTED] Parent task updated with subtask dependencies
- [NOT STARTED] Git commit created
- [NOT STARTED] Rollback works on partial failure
- [NOT STARTED] Error messages are clear and actionable

**Estimated Effort**: 8-10 hours

**Reference**: Task 326 research report

---

### Phase 4: Implement --sync Flag with Git Blame Conflict Resolution (Task 330) [NOT STARTED]

**Objective**: Add --sync flag to synchronize TODO.md and state.json using git blame for conflict resolution

**Tasks**:
1. Add Stage 6 (SyncTasks) to task.md:
   - Parse task_ranges from arguments (optional)
   - If no ranges: Sync ALL tasks (default behavior)
   - If ranges: Parse ranges (e.g., "343-345, 337")
   - Validate ranges are valid task numbers
   - Delegate to status-sync-manager with operation "sync_tasks":
     * task_ranges: Array of task numbers or "all"
     * conflict_resolution: "git_blame" (use latest commit)
   - Wait for return
   - Validate return: status == "completed", files_updated includes [TODO.md, state.json]
   - Return success message with sync count and conflict resolution details
2. Implement sync_tasks operation in status-sync-manager with git blame:
   - step_0_validate_inputs: 
     * Validate task ranges (or "all")
     * If "all": Extract all task numbers from both TODO.md and state.json
   - step_1_analyze_differences: 
     * For each task: Compare TODO.md entry vs state.json entry
     * Identify discrepancies: status, priority, effort, description, artifacts, etc.
     * Categorize: only_in_todo, only_in_state, in_both_with_discrepancies
   - step_2_resolve_conflicts_with_git_blame:
     * For tasks with discrepancies:
       - Run `git blame TODO.md` for task's line range
       - Run `git blame state.json` for task's JSON object
       - Extract commit timestamps for each field
       - Choose version with latest commit timestamp (most recent wins)
       - Log conflict resolution: "Task 343: status from state.json (2026-01-07) vs TODO.md (2026-01-06) → state.json wins"
     * For tasks only in one file:
       - Run git blame to check if task was deleted from other file
       - If deleted recently: Respect deletion (remove from both)
       - If never existed: Add to other file
   - step_3_prepare_updates: 
     * Format entries for both files using resolved values
     * Ensure consistency across all fields
   - step_4_commit: 
     * Atomic write (TODO.md, state.json)
     * Use two-phase commit
   - step_5_return: 
     * Return synced_tasks, conflicts_resolved, files_updated
     * Include conflict resolution details for logging
3. Implement git blame helper function:
   - Function: get_last_modified_timestamp(file_path, line_range_or_json_path)
   - Use `git blame -L <start>,<end> <file>` for TODO.md line ranges
   - Use `git log -1 --format=%ct -- <file>` + jq for state.json field changes
   - Parse commit timestamp
   - Return timestamp for comparison
4. Add range parsing logic:
   - Reuse patterns from task 311 (abandon command)
   - Support single numbers: "337"
   - Support ranges: "343-345"
   - Support lists: "337, 343-345, 350"
   - Support "all" (default when no ranges specified)
   - Validate and deduplicate
5. Add git commit integration:
   - Delegate to git-workflow-manager after successful sync
   - Commit message: "task: sync TODO.md and state.json for {count} tasks ({ranges or 'all'})"
   - Include conflict resolution summary in commit message

**Acceptance Criteria**:
- [NOT STARTED] /task --sync syncs ALL tasks (default behavior)
- [NOT STARTED] /task --sync 343-345 syncs tasks 343, 344, 345
- [NOT STARTED] /task --sync 337, 343-345 syncs tasks 337, 343, 344, 345
- [NOT STARTED] Conflicts resolved using git blame (latest commit wins)
- [NOT STARTED] Conflict resolution logged clearly
- [NOT STARTED] TODO.md and state.json synchronized
- [NOT STARTED] Git commit created with conflict resolution summary
- [NOT STARTED] Error messages are clear and actionable

**Estimated Effort**: 10-12 hours (increased from 6-8 for git blame implementation)

**Reference**: Task 330 description (revised for git blame conflict resolution)

---

### Phase 5: Implement --abandon Flag (Task 331) [NOT STARTED]

**Objective**: Add --abandon flag to abandon multiple tasks via ranges/lists

**Tasks**:
1. Add Stage 7 (AbandonTasks) to task.md:
   - Parse task_ranges from arguments (required)
   - Parse ranges (e.g., "343-345, 337")
   - Validate ranges are valid task numbers
   - Delegate to status-sync-manager with operation "archive_tasks":
     * task_numbers: Array of task numbers
     * reason: "abandoned" (default)
   - Wait for return
   - Validate return: status == "completed", files_updated includes [TODO.md, state.json, archive/state.json]
   - Return success message
2. Reuse existing archive_tasks operation in status-sync-manager:
   - Already supports bulk abandonment
   - Already uses atomic two-phase commit
   - Already creates git commits
3. Add range parsing logic:
   - Reuse patterns from task 311 (abandon command)
   - Support single numbers: "337"
   - Support ranges: "343-345"
   - Support lists: "337, 343-345, 350"
   - Validate and deduplicate
4. Add error handling:
   - Task not found
   - Task already abandoned
   - Invalid range format

**Acceptance Criteria**:
- [NOT STARTED] /task --abandon 343-345 abandons tasks 343, 344, 345
- [NOT STARTED] /task --abandon 337, 343-345 abandons tasks 337, 343, 344, 345
- [NOT STARTED] Tasks moved to archive/
- [NOT STARTED] TODO.md and state.json updated
- [NOT STARTED] archive/state.json updated
- [NOT STARTED] Git commit created
- [NOT STARTED] Error messages are clear and actionable

**Estimated Effort**: 4-6 hours

**Reference**: Task 331 description, task 311 patterns

---

### Phase 6: Update Core Context Files [COMPLETED]

**Objective**: Update .opencode/context/core/ files to accurately represent new patterns without bloat

**Tasks**:
1. Update `.opencode/context/core/orchestration/routing.md`:
   - Add /task command to Command → Agent Mapping table
   - Update agent field from "status-sync-manager" to "orchestrator"
   - Add flag-based routing pattern (--recover, --divide, --sync, --abandon)
   - Add range parsing pattern to Command Argument Parsing section
   - Keep concise: Only add essential routing information
2. Update `.opencode/context/core/orchestration/delegation.md`:
   - Add bulk operation delegation pattern (recover, sync, abandon)
   - Add git blame conflict resolution delegation pattern (sync)
   - Add rollback mechanism delegation pattern (divide)
   - Document status-sync-manager new operations (unarchive_tasks, sync_tasks)
   - Keep focused: Only delegation patterns, not implementation details
3. Update `.opencode/context/core/orchestration/validation.md`:
   - Add validation gates for new flags (recover, divide, sync, abandon)
   - Add range parsing validation pattern
   - Add git blame timestamp validation pattern
   - Add bulk operation validation pattern (all-or-nothing vs partial success)
   - Keep targeted: Only validation rules, not business logic
4. Update `.opencode/context/core/standards/task-management.md`:
   - Add /task flag usage patterns (--recover, --divide, --sync, --abandon)
   - Add bulk operation standards (range syntax, error reporting)
   - Add git blame conflict resolution standards (latest commit wins)
   - Add task division standards (parent dependencies, subtask creation)
   - Keep essential: Only task management standards, not implementation
5. Review and prune:
   - Remove outdated patterns from context files
   - Consolidate duplicate information
   - Ensure no bloat or needless repetition
   - Verify all new patterns are accurately represented

**Acceptance Criteria**:
- [COMPLETED] routing.md updated with /task flag routing patterns
- [COMPLETED] delegation.md updated with bulk operation and git blame patterns
- [COMPLETED] validation.md updated with new validation gates
- [COMPLETED] task-management.md updated with flag usage standards
- [COMPLETED] No bloat or needless repetition in context files
- [COMPLETED] All new patterns accurately represented
- [COMPLETED] Context files remain clear, concise, and complete

**Estimated Effort**: 3-4 hours
**Actual Effort**: 2 hours

---

### Phase 7: Integration Testing and Documentation [NOT STARTED]

**Objective**: Test all flags together and update documentation

**Tasks**:
1. Create comprehensive test suite:
   - Test each flag individually
   - Test flag combinations (should error)
   - Test backward compatibility (existing syntax)
   - Test error handling for all edge cases
   - Test rollback mechanisms
   - Test git commit integration
2. Update documentation:
   - Update task.md with all flag descriptions
   - Update status-sync-manager.md with new operations
   - Update user guide with flag usage examples
   - Update architecture documentation
3. Performance testing:
   - Verify all operations complete within 120s timeout
   - Verify atomic operations are fast (<5s for single task)
   - Verify bulk operations scale (e.g., --abandon 100 tasks)
4. Create migration guide:
   - Document changes from old commands to new flags
   - Provide examples for common workflows
   - Document rollback procedures

**Acceptance Criteria**:
- [NOT STARTED] All test cases pass
- [NOT STARTED] Documentation updated
- [NOT STARTED] Performance targets met
- [NOT STARTED] Migration guide created

**Estimated Effort**: 4-6 hours

---

## Testing and Validation

### Manual Test Cases

#### Test Case 1: --recover Flag (Single Task)
```bash
# Archive a task
/todo --archive 350

# Recover the task
/task --recover 350

# Verify:
# - Task 350 appears in TODO.md with [NOT STARTED] status
# - Task 350 appears in state.json active_projects
# - Task 350 removed from archive/state.json
# - Directory moved from archive/ to specs/ (if exists)
# - Git commit created
```

#### Test Case 1b: --recover Flag (Bulk)
```bash
# Archive multiple tasks
/todo --archive 350-352

# Recover the tasks
/task --recover 350-352

# Verify:
# - Tasks 350, 351, 352 appear in TODO.md with [NOT STARTED] status
# - Tasks 350, 351, 352 appear in state.json active_projects
# - Tasks 350, 351, 352 removed from archive/state.json
# - Directories moved from archive/ to specs/ (if exist)
# - Git commit created with count and ranges
```

#### Test Case 2: --divide Flag
```bash
# Create a task
/task "Implement feature X: add UI, add backend, add tests"

# Divide the task
/task --divide 351

# Verify:
# - Task 351 has dependencies: [352, 353, 354]
# - Tasks 352, 353, 354 created with descriptions
# - Git commit created
```

#### Test Case 3: --sync Flag (All Tasks)
```bash
# Manually edit TODO.md and state.json (introduce inconsistencies)
# Edit task 343 status in TODO.md (older commit)
# Edit task 343 status in state.json (newer commit)

# Sync all tasks
/task --sync

# Verify:
# - ALL tasks synchronized
# - Task 343 uses state.json version (newer commit via git blame)
# - Conflict resolution logged
# - TODO.md matches state.json
# - Git commit created with conflict resolution summary
```

#### Test Case 3b: --sync Flag (Specific Ranges)
```bash
# Manually edit TODO.md (introduce inconsistency in tasks 343-345)

# Sync specific tasks
/task --sync 343-345

# Verify:
# - Tasks 343, 344, 345 synchronized
# - Conflicts resolved using git blame
# - TODO.md matches state.json for these tasks
# - Git commit created
```

#### Test Case 4: --abandon Flag
```bash
# Abandon multiple tasks
/task --abandon 343-345, 350

# Verify:
# - Tasks 343, 344, 345, 350 moved to archive/
# - TODO.md and state.json updated
# - archive/state.json updated
# - Git commit created
```

#### Test Case 5: Backward Compatibility
```bash
# Create task with existing syntax
/task "Implement feature Y" --priority high --effort 8h

# Verify:
# - Task created normally
# - No regression in existing functionality
```

#### Test Case 6: Error Handling
```bash
# Test invalid inputs
/task --recover 999  # Task not in archive
/task --recover 343-345  # Some tasks not in archive (partial failure)
/task --divide 999   # Task not found
/task --sync 999-1000  # Invalid range
/task --abandon 999  # Task not found

# Verify:
# - Clear error messages
# - No state changes (or partial with clear reporting)
# - Helpful recommendations
```

#### Test Case 7: Git Blame Conflict Resolution
```bash
# Setup: Create conflict scenario
# 1. Edit task 343 status in TODO.md, commit
# 2. Edit task 343 status in state.json, commit (newer)
# 3. Edit task 344 priority in state.json, commit
# 4. Edit task 344 priority in TODO.md, commit (newer)

# Sync all tasks
/task --sync

# Verify:
# - Task 343 uses state.json status (newer commit)
# - Task 344 uses TODO.md priority (newer commit)
# - Conflict resolution logged with timestamps
# - Git commit includes conflict resolution summary
```

### Validation Checklist

- [NOT STARTED] All 7 test cases pass (including git blame conflict resolution)
- [NOT STARTED] Bulk operations work correctly (--recover, --sync, --abandon)
- [NOT STARTED] Git blame conflict resolution works correctly
- [NOT STARTED] Backward compatibility verified
- [NOT STARTED] Error messages are clear and actionable
- [NOT STARTED] Atomic operations verified (all or nothing)
- [NOT STARTED] Git commits created for all state changes
- [NOT STARTED] Performance targets met (<120s per operation)
- [NOT STARTED] Validation gates prevent architectural violations
- [NOT STARTED] Documentation updated

---

## Artifacts and Outputs

### Primary Artifacts

1. **Modified Files**:
   - `.opencode/command/task.md` - Add all four flags and routing logic
   - `.opencode/agent/subagents/status-sync-manager.md` - Add unarchive_task and sync_tasks operations
   - `.opencode/agent/subagents/task-divider.md` - Enhance for existing task analysis (if needed)

2. **Context File Updates** (Phase 6):
   - `.opencode/context/core/orchestration/routing.md` - Add /task flag routing patterns
   - `.opencode/context/core/orchestration/delegation.md` - Add bulk operation and git blame patterns
   - `.opencode/context/core/orchestration/validation.md` - Add new validation gates
   - `.opencode/context/core/standards/task-management.md` - Add flag usage standards

3. **Documentation Updates**:
   - Update /task command usage documentation
   - Update status-sync-manager operations documentation
   - Update user guide with flag usage examples
   - Update architecture documentation

### Secondary Artifacts

1. **Implementation Summaries**:
   - `.opencode/specs/325_*/summaries/implementation-summary-*.md`
   - `.opencode/specs/326_*/summaries/implementation-summary-*.md`
   - `.opencode/specs/330_*/summaries/implementation-summary-*.md`
   - `.opencode/specs/331_*/summaries/implementation-summary-*.md`

2. **Git Commits**:
   - Commit for Phase 1 (architecture update)
   - Commit for Phase 2 (--recover flag)
   - Commit for Phase 3 (--divide flag)
   - Commit for Phase 4 (--sync flag)
   - Commit for Phase 5 (--abandon flag)
   - Commit for Phase 6 (documentation)

---

## Rollback/Contingency

### Rollback Plan

If any phase causes issues:

1. **Immediate Rollback**:
   ```bash
   git log --oneline -10  # Find commit before phase
   git revert <commit_hash>  # Revert phase changes
   ```

2. **Partial Rollback**:
   - If only one flag has issues: Revert that flag's stage
   - If architecture update has issues: Revert to Phase 2 standards
   - If subagent has issues: Revert subagent changes

3. **Manual Recovery**:
   - If a flag operation fails mid-way:
     - Check git log for pre-operation state
     - Manually restore TODO.md, state.json, archive/state.json from git
     - Move directories manually if needed

### Contingency Plan

If Phase 3 refactoring is too complex:

1. **Fallback to Phase 2 Standards**:
   - Keep agent field as "status-sync-manager"
   - Add flags without full refactoring
   - Implement validation gates inline
   - Skip task-divider and task-creator subagents

2. **Incremental Implementation**:
   - Implement flags one at a time
   - Test thoroughly before next flag
   - Rollback if any flag causes issues

3. **Simplified Flags**:
   - --recover: Single task only (no bulk)
   - --divide: Require explicit prompt (no AI analysis)
   - --sync: All tasks only (no ranges)
   - --abandon: Delegate to existing /abandon command

---

## Success Metrics

### Quantitative Metrics

- **Flag Success Rate**: 100% for valid inputs
- **Atomic Update Success**: 100% (all files updated or none)
- **Git Commit Success**: >95% (non-critical failures acceptable)
- **Error Detection Rate**: 100% for invalid inputs
- **Performance**: <120s per operation, <5s for single task operations

### Qualitative Metrics

- **User Experience**: Clear error messages, predictable behavior
- **Code Quality**: Follows Phase 3 patterns, well-documented
- **Maintainability**: Easy to extend (e.g., bulk recovery, status preservation)
- **Reliability**: Atomic updates prevent data corruption
- **Consistency**: All flags follow same architectural pattern

### Acceptance Criteria

- [NOT STARTED] All 4 flags implemented and tested
- [NOT STARTED] Phase 3 architectural standards maintained
- [NOT STARTED] Backward compatibility verified
- [NOT STARTED] Error handling covers all edge cases
- [NOT STARTED] Git commits created for all state changes
- [NOT STARTED] Documentation updated
- [NOT STARTED] Code follows existing patterns and standards

---

## Dependencies

### Internal Dependencies

- **status-sync-manager**: Must support unarchive_task and sync_tasks operations
- **task-divider**: Must support analyzing existing tasks (if not already)
- **task-creator**: Must support creating subtasks with dependencies
- **git-workflow-manager**: Used for git commit creation
- **archive/state.json**: Must exist and be valid JSON
- **TODO.md**: Must have priority sections for task insertion

### External Dependencies

None

---

## Comparison with Phase 3 Standards

### Alignment with Phase 3

| Aspect | Phase 3 Standard | This Plan |
|--------|-----------------|-----------|
| **Agent Field** | `orchestrator` | ✅ Changed to `orchestrator` |
| **Separation of Concerns** | Command orchestrates, subagents execute | ✅ All flags delegate to subagents |
| **Validation Gates** | At critical points | ✅ Added for all operations |
| **Inline Logic** | Minimal | ✅ Complex logic delegated |
| **Return Format** | Task numbers only | ✅ Validated return format |
| **Subagent Usage** | task-divider, task-creator | ✅ Used for division and creation |

### Enhancements Beyond Phase 3

1. **Multiple Operation Modes**: Phase 3 focused on task creation, this plan adds recovery, division, sync, and abandonment
2. **Range Parsing**: Added support for task ranges (e.g., 343-345)
3. **Bulk Operations**: Added support for bulk abandonment
4. **Rollback Mechanisms**: Added rollback for partial failures
5. **Comprehensive Error Handling**: Added error handling for all edge cases

---

## Notes

### Implementation Order

1. **Phase 1** (Architecture): Must be done first (foundation for all flags)
2. **Phase 2** (--recover): Can be done in parallel with Phase 3
3. **Phase 3** (--divide): Can be done in parallel with Phase 2
4. **Phase 4** (--sync): Can be done in parallel with Phase 5
5. **Phase 5** (--abandon): Can be done in parallel with Phase 4
6. **Phase 6** (Context Updates): Should be done after Phases 1-5 (documents new patterns)
7. **Phase 7** (Testing): Must be done last (integration testing)

### Future Enhancements

1. **Status Preservation**: Add `--preserve-status` flag for recovery
2. **Interactive Division**: Add `--interactive` flag for manual subtask definition
3. **Dry-Run Mode**: Add `--dry-run` flag for sync (preview changes)
4. **Custom Abandonment Reason**: Add `--reason` flag for abandonment
5. **Interactive Conflict Resolution**: Add `--interactive` flag for sync to manually choose versions
6. **Bulk Division**: Support dividing multiple tasks at once (if needed in future)

### Related Tasks

- Task 323: Fix /todo command to run markdown formatter after completion
- Task 328: Fix /task command to only create task entries and never implement directly
- Task 332: Design and implement comprehensive /task command enhancements (this plan)

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2026-01-07 | Planner | Initial comprehensive enhancement plan created |
| 2.0 | 2026-01-07 | Planner | Added bulk support for --recover, git blame conflict resolution for --sync, revised effort estimates |
| 2.1 | 2026-01-07 | Planner | Added Phase 6 for context file updates to ensure new patterns are accurately represented |

---

## Conclusion

This comprehensive enhancement plan integrates four new flags (--recover, --divide, --sync, --abandon) into the `/task` command while maintaining the architectural standards established in Phase 3 of TASK_COMMAND_IMPROVEMENT_PLAN.md.

**Key Takeaways**:
1. **Unified Task Management**: All task lifecycle operations in one command
2. **Architectural Consistency**: All flags follow Phase 3 patterns
3. **Separation of Concerns**: Command orchestrates, subagents execute
4. **Validation Gates**: Prevent violations at critical points
5. **Atomic Operations**: All state changes are atomic (all or nothing)
6. **Bulk Operations**: --recover, --sync, and --abandon support ranges/lists for efficiency
7. **Git Blame Conflict Resolution**: --sync uses git history to automatically resolve conflicts
8. **Clear Error Messages**: Guide users to correct usage
9. **Backward Compatibility**: Existing syntax still works

**Estimated Timeline**:
- Phase 1 (Architecture): 3-4 hours
- Phase 2 (--recover with bulk): 8-10 hours (increased for bulk support)
- Phase 3 (--divide): 8-10 hours
- Phase 4 (--sync with git blame): 10-12 hours (increased for git blame implementation)
- Phase 5 (--abandon): 4-6 hours
- Phase 6 (Context Updates): 3-4 hours
- Phase 7 (Testing): 6-8 hours (increased for additional test cases)
- **Total**: 42-54 hours (revised from 39-50 for context updates)

**Next Steps**: Begin with Phase 1 (Update task.md Architecture to Phase 3 Standards)

---

**Plan Author**: Claude (AI Assistant)  
**Plan Date**: 2026-01-07  
**Based On**: 
- TASK_COMMAND_IMPROVEMENT_PLAN.md (Phase 3 standards)
- Task 325 implementation plan (--recover flag)
- Task 326 research report (--divide flag)
- Task 330 description (--sync flag)
- Task 331 description (--abandon flag)
- Delegation standard (validation patterns)
- status-sync-manager.md (atomic operations)
