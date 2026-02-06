# Research Report: /todo Command Archival Feature Implementation

**Task**: 201  
**Research Date**: 2025-12-27  
**Researcher**: System  
**Status**: Research Complete

---

## Executive Summary

This research investigates requirements and design approaches for implementing an archival feature in the `/todo` command that automatically archives completed and abandoned tasks while maintaining data integrity and system consistency.

**Key Findings**:
1. Current `/todo` command removes tasks from TODO.md but does not preserve artifacts or update archive state
2. Archive infrastructure already exists (`.opencode/specs/archive/state.json`) with well-defined schema
3. Archival must be atomic across 4 files: TODO.md, state.json, archive/state.json, and project directories
4. Task numbering must be preserved with gaps (critical requirement)
5. Self-healing pattern should be applied to archive/state.json creation

**Recommended Approach**: Implement 6-stage workflow with two-phase commit for atomicity and comprehensive error handling.

---

## Current State Analysis

### Existing /todo Command

**Location**: `.opencode/command/todo.md`

**Current Functionality**:
- Scans TODO.md for `[COMPLETED]` and `[ABANDONED]` tasks
- Removes tasks from TODO.md
- Updates state.json to remove entries
- Preserves task numbering (no renumbering)
- User confirmation for bulk removals (threshold: 5 tasks)
- Atomic updates via two-phase commit
- Git commit after cleanup

**Limitations**:
- Does NOT archive project artifacts
- Does NOT move project directories to archive/
- Does NOT update archive/state.json
- Task history is lost (only removed, not preserved)

### Archive Infrastructure

**Location**: `.opencode/specs/archive/`

**Existing Structure**:
```
.opencode/specs/archive/
├── state.json              # Archived project metadata
└── NNN_project_name/       # Archived project directories
    ├── reports/
    ├── plans/
    ├── summaries/
    └── state.json
```

**Archive State Schema** (from `archive/state.json`):
```json
{
  "_schema_version": "1.0.0",
  "_comment": "Auto-created with self-healing",
  "_last_updated": "YYYY-MM-DDTHH:MM:SSZ",
  "archived_projects": [
    {
      "project_number": 126,
      "project_name": "project_slug",
      "type": "implementation|bugfix|feature|...",
      "status": "completed|abandoned",
      "created": "YYYY-MM-DDTHH:MM:SSZ",
      "started": "YYYY-MM-DD",
      "completed": "YYYY-MM-DD",
      "archived": "YYYY-MM-DD",
      "summary": "Brief description",
      "artifacts": {
        "base_path": ".opencode/specs/archive/NNN_project_name/"
      }
    }
  ]
}
```

**Current Archive Count**: 20 projects archived (as of 2025-12-24)

---

## Requirements Analysis

### Functional Requirements

**FR1: Task Identification**
- Identify all tasks with status `[COMPLETED]` or `[ABANDONED]` in TODO.md
- Extract task metadata: number, title, status, dates, priority, effort
- Validate task is eligible for archival

**FR2: Artifact Preservation**
- Move project directory from `.opencode/specs/NNN_*/` to `.opencode/specs/archive/NNN_*/`
- Preserve all files: reports/, plans/, summaries/, state.json
- Handle missing project directories gracefully (some tasks may not have artifacts)

**FR3: State Synchronization**
- Remove tasks from TODO.md (preserve numbering with gaps)
- Remove entries from main state.json active_projects array
- Add entries to archive/state.json archived_projects array
- Update repository health metrics in main state.json
- Add activity log entries for each archived task

**FR4: Atomicity**
- All operations succeed or all rollback
- No partial state (e.g., TODO.md updated but archive/state.json not)
- Transactional guarantees across file system and JSON updates

**FR5: User Confirmation**
- Threshold: 5 tasks (matches existing /todo behavior)
- Display task list with numbers and titles
- Require explicit confirmation (yes/no)
- Abort gracefully if declined

**FR6: Self-Healing**
- Auto-create archive/state.json from template if missing
- Initialize with proper schema version
- Log self-healing actions to recent_activities

**FR7: Git Integration**
- Commit archival changes after successful completion
- Scoped commit: TODO.md + state.json + archive/state.json + moved directories
- Message format: "todo: archive {N} completed/abandoned tasks"

### Non-Functional Requirements

**NFR1: Data Integrity**
- No data loss during archival
- All task history preserved in archive
- Referential integrity maintained (state.json ↔ archive/state.json)

**NFR2: Performance**
- Handle up to 100 tasks in single archival operation
- Complete within 30 seconds for typical workloads

**NFR3: Error Handling**
- Graceful degradation on file system errors
- Rollback on any failure
- Clear error messages with recovery instructions

**NFR4: Maintainability**
- Follow existing /todo command patterns
- Reuse two-phase commit logic
- Document archival logic clearly

---

## Design Options

### Option 1: In-Place Enhancement (Recommended)

**Approach**: Extend existing `/todo` command with archival stages.

**Workflow**:
1. **ScanTODO**: Identify tasks to archive (existing)
2. **ConfirmRemoval**: User confirmation (existing)
3. **PrepareArchival**: NEW - Prepare project directory moves and archive state updates
4. **PrepareUpdates**: Update TODO.md and main state.json (existing)
5. **AtomicUpdate**: NEW - Four-file atomic commit (TODO + state + archive/state + directories)
6. **GitCommit**: Commit changes (existing, expand scope)
7. **ReturnSuccess**: Return summary (existing, expand details)

**Advantages**:
- Minimal disruption to existing workflow
- Reuses confirmation and error handling logic
- Single command for both cleanup and archival
- Backward compatible (archival is additive)

**Disadvantages**:
- Increased complexity in single command
- Larger atomic transaction scope

**Implementation Complexity**: Medium (3-4 hours)

### Option 2: Separate /archive Command

**Approach**: Create new `/archive` command for archival, keep `/todo` for cleanup only.

**Workflow**:
- `/todo`: Remove from TODO.md + state.json (current behavior)
- `/archive`: Move to archive/ + update archive/state.json

**Advantages**:
- Separation of concerns
- Simpler individual commands
- Users can choose cleanup-only vs full archival

**Disadvantages**:
- Two-step process (manual invocation)
- Risk of forgetting to archive after cleanup
- Duplication of scanning and confirmation logic

**Implementation Complexity**: Medium-High (4-5 hours, two commands)

### Option 3: Background Archival Service

**Approach**: Automatic background process that archives tasks after cleanup.

**Workflow**:
- `/todo`: Cleanup as usual, log tasks to archival queue
- Background service: Periodically process queue, archive tasks

**Advantages**:
- Fully automatic
- No user interaction needed
- Can optimize batch archival

**Disadvantages**:
- Requires persistent background process
- Complexity of queue management
- Delayed archival (not immediate)
- Over-engineered for current needs

**Implementation Complexity**: High (6-8 hours, requires scheduler)

---

## Recommended Design: Option 1 (In-Place Enhancement)

### Rationale

1. **User Experience**: Single command maintains simplicity
2. **Atomicity**: Natural extension of existing two-phase commit
3. **Backward Compatibility**: Archival is optional enhancement (degrades gracefully if archive/ missing)
4. **Implementation Efficiency**: Leverages 80% of existing code

### Detailed Workflow

#### Stage 1: ScanTODO (Existing, No Changes)

**Action**: Scan TODO.md for completed and abandoned tasks

**Output**:
```python
{
  "tasks_to_archive": [
    {
      "number": 172,
      "title": "Complete API documentation",
      "status": "completed",
      "started": "2025-12-24",
      "completed": "2025-12-24",
      "priority": "High",
      "effort": "30 hours"
    },
    {
      "number": 177,
      "title": "Update examples",
      "status": "completed",
      "started": "2025-12-25",
      "completed": "2025-12-25",
      "priority": "Medium",
      "effort": "8 hours"
    }
  ],
  "count": 2
}
```

#### Stage 2: ConfirmRemoval (Existing, Enhanced Display)

**Action**: Confirm archival with user if threshold exceeded

**Enhanced Display**:
```
Found 2 tasks to archive:
- Task 172: Complete API documentation [COMPLETED]
- Task 177: Update examples [COMPLETED]

These tasks will be:
1. Removed from TODO.md
2. Moved to archive/ (if project directories exist)
3. Added to archive/state.json

Proceed with archival? (yes/no):
```

**Threshold**: 5 tasks (unchanged)

#### Stage 3: PrepareArchival (NEW)

**Action**: Prepare project directory moves and archive state updates

**Process**:
1. For each task to archive:
   a. Check if project directory exists: `.opencode/specs/{number}_{slug}/`
   b. If exists:
      - Prepare move to `.opencode/specs/archive/{number}_{slug}/`
      - Extract project metadata from state.json or TODO.md
   c. If missing:
      - Log warning (task has no artifacts to archive)
      - Continue (not an error)
2. Load archive/state.json (or create from template if missing)
3. Prepare archive state entries for each task
4. Validate all updates in memory

**Self-Healing**:
```python
def ensure_archive_state_exists():
    archive_state_path = ".opencode/specs/archive/state.json"
    
    if not exists(archive_state_path):
        # Create from template
        template = {
            "_schema_version": "1.0.0",
            "_comment": "Auto-created with self-healing on first archival",
            "_last_updated": current_timestamp(),
            "archived_projects": []
        }
        
        # Ensure directory exists
        mkdir_p(".opencode/specs/archive/")
        
        # Write template
        write_json_atomic(archive_state_path, template)
        
        log_info("Self-healing: Created archive/state.json from template")
    
    return archive_state_path
```

**Archive Entry Construction**:
```python
def build_archive_entry(task):
    """Build archive/state.json entry from TODO.md task"""
    
    # Extract from TODO.md metadata
    entry = {
        "project_number": task["number"],
        "project_name": task["slug"],  # Extract from title
        "type": task.get("type", "task"),  # From TODO.md or default
        "status": "completed" if task["status"] == "[COMPLETED]" else "abandoned",
        "created": task.get("created", "unknown"),  # May not be available
        "started": task.get("started"),
        "completed": task.get("completed") if task["status"] == "[COMPLETED]" else None,
        "abandoned": task.get("abandoned") if task["status"] == "[ABANDONED]" else None,
        "archived": current_date(),  # YYYY-MM-DD
        "summary": task["title"],  # Task title as summary
        "artifacts": {
            "base_path": f".opencode/specs/archive/{task['number']}_{task['slug']}/"
        }
    }
    
    return entry
```

#### Stage 4: PrepareUpdates (Existing, No Changes)

**Action**: Prepare TODO.md and state.json updates

**Process** (unchanged):
1. Create updated TODO.md content (remove archived tasks)
2. Create updated state.json content (remove archived task entries)
3. Preserve task numbering (no renumbering)
4. Validate updates in memory

#### Stage 5: AtomicUpdate (Enhanced)

**Action**: Atomically update 4 entities: TODO.md, state.json, archive/state.json, project directories

**Two-Phase Commit Protocol**:

**Phase 1 (Prepare)**:
1. Backup current state:
   - Backup TODO.md → TODO.md.bak
   - Backup state.json → state.json.bak
   - Backup archive/state.json → archive/state.json.bak
   - No directory backup (expensive), rely on git for rollback
2. Validate all updates are well-formed
3. Validate all target paths are writable
4. If any validation fails: abort, delete backups, return error

**Phase 2 (Commit)**:
1. Write updated TODO.md
2. Verify write succeeded
3. Write updated state.json
4. Verify write succeeded
5. Write updated archive/state.json
6. Verify write succeeded
7. Move project directories (if they exist):
   ```python
   for task in tasks_to_archive:
       src = f".opencode/specs/{task['number']}_{task['slug']}"
       dst = f".opencode/specs/archive/{task['number']}_{task['slug']}"
       
       if exists(src):
           try:
               shutil.move(src, dst)
           except Exception as e:
               # Rollback all files
               rollback()
               raise ArchivalError(f"Failed to move {src}: {e}")
   ```
8. If any operation fails:
   - Rollback file writes from backups
   - Rollback directory moves (move back)
   - Return error with details

**Rollback Mechanism**:
```python
def rollback_archival():
    """Rollback all archival operations on failure"""
    
    # Restore file backups
    if exists("TODO.md.bak"):
        shutil.copy("TODO.md.bak", "TODO.md")
    if exists("state.json.bak"):
        shutil.copy("state.json.bak", "state.json")
    if exists("archive/state.json.bak"):
        shutil.copy("archive/state.json.bak", "archive/state.json")
    
    # Reverse directory moves
    for task in tasks_attempted:
        src = f".opencode/specs/archive/{task['number']}_{task['slug']}"
        dst = f".opencode/specs/{task['number']}_{task['slug']}"
        
        if exists(src) and not exists(dst):
            shutil.move(src, dst)  # Move back
    
    # Delete backups
    cleanup_backups()
    
    log_error("Archival rollback completed - all operations reversed")
```

#### Stage 6: GitCommit (Enhanced Scope)

**Action**: Commit archival changes

**Scope Expansion**:
- TODO.md (existing)
- state.json (existing)
- archive/state.json (NEW)
- Moved directories (NEW - git handles via delete/add)

**Git Command**:
```bash
git add TODO.md
git add .opencode/specs/state.json
git add .opencode/specs/archive/state.json
git add .opencode/specs/archive/  # Pick up moved directories
git status --short  # Verify staged changes
git commit -m "todo: archive {N} completed/abandoned tasks"
```

**Commit Message Examples**:
- `todo: archive 2 completed tasks`
- `todo: archive 5 completed/abandoned tasks`
- `todo: archive 1 abandoned task`

**Error Handling**:
- If commit fails: Log error, continue (commit failure non-critical)
- Archival already complete, commit just records it
- User can manually commit later if needed

#### Stage 7: ReturnSuccess (Enhanced Details)

**Action**: Return comprehensive summary to user

**Return Format**:
```
TODO.md archival complete

Tasks archived: 2
- Completed: 2
- Abandoned: 0

Project directories moved:
- 172_api_documentation → archive/172_api_documentation
- 177_examples_update → archive/177_examples_update

Remaining active tasks: 38

Archive location: .opencode/specs/archive/state.json
```

---

## Edge Cases and Error Scenarios

### Edge Case 1: No Tasks to Archive

**Scenario**: All tasks are `[NOT STARTED]`, `[IN PROGRESS]`, or `[BLOCKED]`

**Handling**:
- Stage 1 returns empty list
- Command exits early with message: "No tasks to archive. All tasks are active."
- No file operations performed

### Edge Case 2: Task Without Project Directory

**Scenario**: Task 172 is `[COMPLETED]` but `.opencode/specs/172_*/` does not exist

**Handling**:
- Archival proceeds normally
- Directory move skipped for this task
- Archive state entry created with note: "No artifacts (project directory missing)"
- Log info: "Task 172 has no project directory to archive"

### Edge Case 3: Missing archive/state.json

**Scenario**: First archival operation, archive/state.json doesn't exist

**Handling**:
- Self-healing triggers in Stage 3 (PrepareArchival)
- Create archive/state.json from template
- Log action to main state.json recent_activities
- Proceed normally

### Edge Case 4: User Declines Confirmation

**Scenario**: User types "no" when prompted

**Handling**:
- Abort immediately after Stage 2
- No file operations performed
- Return message: "Archival aborted by user"
- Exit gracefully

### Edge Case 5: Directory Move Fails (Permission Error)

**Scenario**: `shutil.move()` fails due to permissions

**Handling**:
- Catch exception in Phase 2 (Commit)
- Rollback all file writes
- Rollback previously moved directories
- Return error:
  ```
  Archival failed: Permission denied moving directory
  File: .opencode/specs/172_api_documentation
  
  To fix:
  1. Check directory permissions
  2. Ensure .opencode/specs/archive/ is writable
  3. Retry /todo command
  ```

### Edge Case 6: Git Commit Fails

**Scenario**: `git commit` returns non-zero exit code

**Handling**:
- Log error to errors.json
- Do NOT rollback archival (files already updated successfully)
- Return success with warning:
  ```
  Archival complete (git commit failed)
  
  Tasks archived: 2
  Git commit failed - you may need to commit manually.
  ```

### Edge Case 7: Malformed TODO.md (Cannot Parse)

**Scenario**: TODO.md has syntax errors, cannot extract task metadata

**Handling**:
- Stage 1 fails with clear error
- Return error:
  ```
  Failed to parse TODO.md
  
  To fix:
  1. Review TODO.md for syntax errors
  2. Ensure task format matches specification
  3. Restore from backup if needed
  ```

### Edge Case 8: state.json and TODO.md Out of Sync

**Scenario**: state.json has entry for task 172 but TODO.md doesn't

**Handling**:
- Proceed with archival for tasks found in TODO.md
- Update state.json based on TODO.md (source of truth)
- Log warning: "state.json had extra entry for task 172 (not in TODO.md)"

---

## Implementation Effort Estimate

### Breakdown by Stage

| Stage | Description | Effort | Complexity |
|-------|-------------|--------|------------|
| Stage 3 | PrepareArchival (NEW) | 2.0h | Medium |
| Stage 5 | AtomicUpdate (Enhanced) | 2.5h | High |
| Stage 6 | GitCommit (Enhanced) | 0.5h | Low |
| Stage 7 | ReturnSuccess (Enhanced) | 0.5h | Low |
| Testing | Edge cases and integration | 1.0h | Medium |
| Documentation | Command docs and examples | 0.5h | Low |

**Total Effort**: 6.0 hours

### Risk Assessment

**Medium Risk**:
- Four-file atomic commit increases failure surface
- Directory move operations can fail (permissions, disk space)
- Git operations may conflict with user's working directory state

**Mitigation**:
- Comprehensive rollback mechanism
- Extensive error handling with clear messages
- Thorough testing of all edge cases

---

## Alternative Approaches Considered

### Approach A: Lazy Archival

**Idea**: Don't move directories immediately, only update state files. Move on-demand when accessed.

**Rejected Reason**: Adds complexity without clear benefit. Immediate archival is simpler and more predictable.

### Approach B: Archive Metadata Only

**Idea**: Keep project directories in place, only update archive/state.json metadata.

**Rejected Reason**: Doesn't solve clutter problem. Archive should be physically separate for clarity.

### Approach C: Soft Delete (Rename to .archived)

**Idea**: Rename directories to `NNN_project.archived` instead of moving.

**Rejected Reason**: Doesn't scale well. Archive/ separation is cleaner and aligns with existing patterns.

---

## Testing Strategy

### Unit Tests

1. **Archive Entry Construction**
   - Test `build_archive_entry()` with various task formats
   - Verify all required fields populated
   - Handle missing optional fields gracefully

2. **Self-Healing**
   - Test `ensure_archive_state_exists()` creates valid file
   - Verify schema matches template
   - Ensure idempotent (doesn't recreate if exists)

3. **Rollback Mechanism**
   - Test `rollback_archival()` restores all files
   - Verify directory moves reversed
   - Ensure backups cleaned up

### Integration Tests

1. **Full Archival Flow**
   - Create test tasks with `[COMPLETED]` status
   - Run `/todo` command
   - Verify tasks removed from TODO.md
   - Verify entries added to archive/state.json
   - Verify directories moved to archive/

2. **Partial Archival (Mixed Tasks)**
   - Some tasks have project directories, some don't
   - Verify all tasks archived, directories moved only for existing ones

3. **Rollback on Failure**
   - Simulate directory move failure
   - Verify rollback restores original state
   - Ensure no partial archival

4. **User Confirmation**
   - Test with >5 tasks (requires confirmation)
   - Test user decline (abort)
   - Test with ≤5 tasks (auto-proceed)

### Manual Tests

1. **Real TODO.md**
   - Run on actual ProofChecker TODO.md
   - Archive 1-2 completed tasks
   - Verify correctness

2. **Edge Cases**
   - Missing archive/state.json (self-healing)
   - No tasks to archive
   - Git commit failure

---

## Documentation Updates Required

### Command Documentation

**File**: `.opencode/command/todo.md`

**Updates**:
1. Add Stage 3 (PrepareArchival)
2. Update Stage 5 (AtomicUpdate) with four-file commit
3. Update Stage 6 (GitCommit) with expanded scope
4. Update Stage 7 (ReturnSuccess) with archival details
5. Add archival error handling section

### Context Documentation

**File**: `.opencode/context/core/system/state-schema.md`

**Updates**:
- Document `/todo` command's archival workflow
- Add examples of archive state entries created by `/todo`

### User Guide

**File**: `docs/user-guide/TUTORIAL.md` or similar

**Updates**:
- Add section on task archival
- Explain `/todo` command behavior with examples
- Document archive/ structure and purpose

---

## Success Criteria

1. **Functional**:
   - `/todo` command archives completed and abandoned tasks
   - Project directories moved to archive/
   - archive/state.json updated with task metadata
   - TODO.md and state.json cleaned up
   - Task numbering preserved with gaps

2. **Non-Functional**:
   - Atomic archival (all or nothing)
   - Rollback on any failure
   - Self-healing for missing archive/state.json
   - User confirmation for bulk archival
   - Git commit records changes

3. **Quality**:
   - No data loss
   - Clear error messages
   - Comprehensive testing (unit + integration)
   - Updated documentation

---

## Recommendations

1. **Implement Option 1 (In-Place Enhancement)**: Best balance of simplicity and functionality
2. **Use Two-Phase Commit**: Ensures atomicity across all files
3. **Apply Self-Healing**: Auto-create archive/state.json from template
4. **Comprehensive Rollback**: Handle all failure scenarios gracefully
5. **Expanded Git Scope**: Commit all archival changes in single commit
6. **Enhanced User Feedback**: Show detailed archival summary

**Estimated Effort**: 6 hours total

---

## Open Questions

1. **Q**: Should archived project directories be read-only?
   **A**: No, leave as-is. Git provides version control; file permissions add complexity.

2. **Q**: Should we validate archive/state.json schema on each archival?
   **A**: Yes, light validation (check required fields). Full schema validation overkill.

3. **Q**: What if user has uncommitted changes in git?
   **A**: Proceed with archival, git commit adds on top. User responsible for commit hygiene.

4. **Q**: Should we compress archived project directories?
   **A**: No, keep as plain files. Searchability and git diffs more valuable than space savings.

---

## Conclusion

Implementing archival in the `/todo` command is feasible and aligns well with existing infrastructure. The recommended approach (Option 1) extends the current workflow with minimal disruption while providing comprehensive archival capabilities.

**Next Steps**:
1. Create implementation plan based on this research
2. Implement Stage 3 (PrepareArchival) with self-healing
3. Enhance Stage 5 (AtomicUpdate) for four-file atomicity
4. Expand Stage 6 (GitCommit) scope
5. Test thoroughly with edge cases
6. Update documentation

**Research Complete**: Ready for planning phase.
