# Implementation Plan: /todo Command Archival Feature

**Project Number**: 201  
**Project Name**: todo_archival_feature  
**Type**: Feature  
**Priority**: High  
**Complexity**: Medium-High  
**Estimated Hours**: 6.0  
**Phases**: 4  
**Status**: [NOT STARTED]

---

## Metadata

**Created**: 2025-12-27T23:50:00Z  
**Language**: markdown  
**Approach**: In-Place Enhancement (Option 1 from research)  
**Strategy**: Extend existing /todo command with archival capabilities using two-phase commit for atomicity

---

## Overview

This plan implements archival functionality in the `/todo` command to automatically archive completed and abandoned tasks while preserving all artifacts and maintaining data integrity across multiple files.

**Core Approach**: Enhance the existing `/todo` command workflow with new archival stages that:
1. Move project directories to archive/
2. Update archive/state.json with task metadata
3. Maintain atomicity across 4 entities (TODO.md, state.json, archive/state.json, directories)
4. Apply self-healing for missing archive infrastructure
5. Provide comprehensive error handling and rollback

---

## Research Inputs

**Research Report**: `.opencode/specs/201_todo_archival_feature/reports/research-001.md`

**Key Research Findings**:
1. **Current Limitation**: `/todo` removes tasks but doesn't preserve artifacts
2. **Archive Infrastructure**: Exists with well-defined schema (20 projects already archived)
3. **Atomicity Requirement**: Must update 4 entities atomically
4. **Task Numbering**: Must preserve with gaps (critical)
5. **Self-Healing**: Apply to archive/state.json creation
6. **Recommended Approach**: In-Place Enhancement (6 hours effort)

**Design Decision**: Option 1 (In-Place Enhancement) selected for:
- Minimal disruption to existing workflow
- Single command simplicity for users
- Reuses 80% of existing code
- Natural extension of two-phase commit pattern

---

## Phase 1: Archival Preparation Logic [NOT STARTED]

**Estimated Hours**: 2.0  
**Complexity**: Medium

### Objectives

1. Create Stage 3 (PrepareArchival) in `/todo` command workflow
2. Implement self-healing for archive/state.json
3. Build archive entry construction logic
4. Validate all archival operations in memory before execution

### Tasks

#### Task 1.1: Update /todo Command Structure

**File**: `.opencode/command/todo.md`

**Changes**:
- Insert new Stage 3 (PrepareArchival) between ConfirmRemoval and PrepareUpdates
- Shift existing Stage 3-7 to Stage 4-8
- Add archival_context to workflow state

**Implementation**:
```xml
<stage id="3" name="PrepareArchival">
  <action>Prepare project directory moves and archive state updates</action>
  <process>
    1. For each task to archive:
       a. Extract task metadata (number, slug, title, status, dates)
       b. Check if project directory exists: .opencode/specs/{number}_{slug}/
       c. If exists: Prepare directory move operation
       d. If missing: Log info (task has no artifacts)
    2. Ensure archive/state.json exists (self-healing)
    3. Load current archive/state.json
    4. Build archive entry for each task
    5. Prepare archive/state.json updates
    6. Validate all operations in memory
  </process>
</stage>
```

**Acceptance Criteria**:
- [ ] Stage 3 (PrepareArchival) added to workflow
- [ ] Existing stages renumbered correctly
- [ ] Workflow state includes archival_context

#### Task 1.2: Implement Self-Healing for Archive

**File**: `.opencode/command/todo.md`

**Logic**:
```python
def ensure_archive_state_exists():
    """Create archive/state.json from template if missing"""
    archive_state_path = ".opencode/specs/archive/state.json"
    
    if not exists(archive_state_path):
        # Ensure directory exists
        mkdir_p(".opencode/specs/archive/")
        
        # Create from template
        template = {
            "_schema_version": "1.0.0",
            "_comment": "Auto-created with self-healing on first archival",
            "_last_updated": current_timestamp(),
            "archived_projects": []
        }
        
        # Write atomically
        write_json_atomic(archive_state_path, template)
        
        # Log action
        log_info("Self-healing: Created archive/state.json from template")
        
        # Add to main state recent_activities
        update_main_state_activity(
            "Self-healing: Created archive/state.json for first archival"
        )
    
    return archive_state_path
```

**Acceptance Criteria**:
- [ ] Self-healing logic implemented
- [ ] Archive directory created if missing
- [ ] archive/state.json created from template
- [ ] Action logged to main state.json
- [ ] Idempotent (doesn't recreate if exists)

#### Task 1.3: Build Archive Entry Constructor

**File**: `.opencode/command/todo.md`

**Logic**:
```python
def build_archive_entry(task):
    """Build archive/state.json entry from TODO.md task"""
    
    # Extract task slug from title (convert to snake_case)
    slug = task["title"].lower().replace(" ", "_")[:50]
    
    # Determine status
    archive_status = "completed" if task["status"] == "[COMPLETED]" else "abandoned"
    
    # Build entry
    entry = {
        "project_number": task["number"],
        "project_name": slug,
        "type": task.get("type", "task"),  # From TODO.md or default
        "status": archive_status,
        "created": task.get("created", "unknown"),  # May not be available
        "started": task.get("started"),
        "completed": task.get("completed") if task["status"] == "[COMPLETED]" else None,
        "abandoned": task.get("abandoned") if task["status"] == "[ABANDONED]" else None,
        "archived": current_date(),  # YYYY-MM-DD
        "summary": task["title"],  # Task title as summary
        "artifacts": {
            "base_path": f".opencode/specs/archive/{task['number']}_{slug}/"
        }
    }
    
    return entry
```

**Acceptance Criteria**:
- [ ] Archive entry constructor implemented
- [ ] Handles both [COMPLETED] and [ABANDONED] statuses
- [ ] Extracts all required metadata from TODO.md
- [ ] Handles missing optional fields gracefully
- [ ] Slug generation is consistent

#### Task 1.4: Directory Move Preparation

**File**: `.opencode/command/todo.md`

**Logic**:
```python
def prepare_directory_moves(tasks_to_archive):
    """Prepare directory move operations"""
    
    move_operations = []
    
    for task in tasks_to_archive:
        # Build source and destination paths
        slug = build_slug(task["title"])
        src = f".opencode/specs/{task['number']}_{slug}"
        dst = f".opencode/specs/archive/{task['number']}_{slug}"
        
        # Check if source exists
        if exists(src):
            move_operations.append({
                "task_number": task["number"],
                "src": src,
                "dst": dst,
                "exists": True
            })
        else:
            # Log but don't error - task may not have artifacts
            log_info(f"Task {task['number']} has no project directory to archive")
            move_operations.append({
                "task_number": task["number"],
                "src": None,
                "dst": None,
                "exists": False
            })
    
    return move_operations
```

**Acceptance Criteria**:
- [ ] Directory move operations prepared
- [ ] Handles missing directories gracefully
- [ ] Logs info for tasks without directories
- [ ] Returns list of move operations

### Deliverables

- [ ] Updated `.opencode/command/todo.md` with Stage 3
- [ ] Self-healing logic for archive/state.json
- [ ] Archive entry constructor function
- [ ] Directory move preparation logic
- [ ] All operations validated in memory

### Testing

**Unit Tests**:
- Test `ensure_archive_state_exists()` creates valid file
- Test `build_archive_entry()` with various task formats
- Test `prepare_directory_moves()` with existing and missing directories

**Integration Tests**:
- Test PrepareArchival stage with 2-3 test tasks
- Verify self-healing creates archive/state.json
- Verify archive entries have all required fields

---

## Phase 2: Atomic Four-File Commit [NOT STARTED]

**Estimated Hours**: 2.5  
**Complexity**: High

### Objectives

1. Enhance Stage 5 (AtomicUpdate) to handle 4 entities
2. Implement two-phase commit protocol
3. Add comprehensive rollback mechanism
4. Ensure atomicity guarantees

### Tasks

#### Task 2.1: Enhance AtomicUpdate Stage

**File**: `.opencode/command/todo.md`

**Changes**:
- Rename existing Stage 4 (AtomicUpdate) to handle 4 entities
- Implement two-phase commit protocol
- Add rollback logic

**Implementation**:
```xml
<stage id="5" name="AtomicUpdate">
  <action>Atomically update 4 entities: TODO.md, state.json, archive/state.json, directories</action>
  <process>
    **Phase 1 (Prepare)**:
    1. Backup current state:
       - Backup TODO.md → TODO.md.bak
       - Backup state.json → state.json.bak
       - Backup archive/state.json → archive/state.json.bak
       - No directory backup (rely on git, expensive)
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
    7. Move project directories (for each move operation):
       - If src exists: shutil.move(src, dst)
       - Verify move succeeded
       - On failure: rollback all previous operations
    8. If any operation fails:
       - Rollback all file writes from backups
       - Rollback directory moves (move back)
       - Return error with details
    9. On success:
       - Delete backup files
       - Proceed to git commit
  </process>
</stage>
```

**Acceptance Criteria**:
- [ ] Stage 5 handles 4 entities
- [ ] Two-phase commit implemented
- [ ] Validation in Phase 1
- [ ] Sequential operations in Phase 2
- [ ] Rollback on any failure

#### Task 2.2: Implement Rollback Mechanism

**File**: `.opencode/command/todo.md`

**Logic**:
```python
def rollback_archival(backup_files, attempted_moves):
    """Rollback all archival operations on failure"""
    
    rollback_log = []
    
    # Restore file backups
    if exists("TODO.md.bak"):
        shutil.copy("TODO.md.bak", "TODO.md")
        rollback_log.append("Restored TODO.md from backup")
    
    if exists("state.json.bak"):
        shutil.copy("state.json.bak", ".opencode/specs/state.json")
        rollback_log.append("Restored state.json from backup")
    
    if exists("archive/state.json.bak"):
        shutil.copy("archive/state.json.bak", ".opencode/specs/archive/state.json")
        rollback_log.append("Restored archive/state.json from backup")
    
    # Reverse directory moves
    for move_op in attempted_moves:
        src = move_op["src"]
        dst = move_op["dst"]
        
        # If destination exists and source doesn't, move back
        if dst and exists(dst) and not exists(src):
            try:
                shutil.move(dst, src)
                rollback_log.append(f"Reversed move: {dst} → {src}")
            except Exception as e:
                rollback_log.append(f"Failed to reverse move {dst}: {e}")
    
    # Delete backup files
    cleanup_backups()
    
    # Log rollback completion
    log_error("Archival rollback completed - all operations reversed")
    for entry in rollback_log:
        log_info(f"  {entry}")
    
    return rollback_log
```

**Acceptance Criteria**:
- [ ] Rollback restores all files from backups
- [ ] Rollback reverses all directory moves
- [ ] Comprehensive logging of rollback actions
- [ ] Cleanup of backup files
- [ ] Error logged to errors.json

#### Task 2.3: Directory Move Implementation

**File**: `.opencode/command/todo.md`

**Logic**:
```python
def execute_directory_moves(move_operations):
    """Execute directory moves with failure handling"""
    
    attempted_moves = []
    
    for move_op in move_operations:
        src = move_op["src"]
        dst = move_op["dst"]
        
        # Skip if no directory to move
        if not src or not move_op["exists"]:
            continue
        
        try:
            # Execute move
            shutil.move(src, dst)
            
            # Track attempt
            attempted_moves.append(move_op)
            
            log_info(f"Moved: {src} → {dst}")
            
        except Exception as e:
            # Move failed - rollback everything
            error_msg = f"Failed to move {src} to {dst}: {str(e)}"
            log_error(error_msg)
            
            # Trigger rollback
            rollback_archival(backup_files=[], attempted_moves=attempted_moves)
            
            # Raise error to abort archival
            raise ArchivalError(error_msg)
    
    return attempted_moves
```

**Acceptance Criteria**:
- [ ] Directory moves executed sequentially
- [ ] Skips non-existent directories
- [ ] Logs each move operation
- [ ] Triggers rollback on failure
- [ ] Returns list of attempted moves

### Deliverables

- [ ] Enhanced Stage 5 (AtomicUpdate) for 4 entities
- [ ] Two-phase commit implementation
- [ ] Comprehensive rollback mechanism
- [ ] Directory move execution logic
- [ ] Error handling for all failure scenarios

### Testing

**Unit Tests**:
- Test rollback restores all files
- Test rollback reverses directory moves
- Test directory move handles permissions errors

**Integration Tests**:
- Test full archival with 2 tasks (both with directories)
- Test archival with 1 task (no directory)
- Test rollback on state.json write failure
- Test rollback on directory move failure

---

## Phase 3: Git Commit and User Feedback [NOT STARTED]

**Estimated Hours**: 1.0  
**Complexity**: Low

### Objectives

1. Expand Stage 6 (GitCommit) scope to include archive changes
2. Enhance Stage 7 (ReturnSuccess) with archival details
3. Ensure proper commit messages and user feedback

### Tasks

#### Task 3.1: Expand Git Commit Scope

**File**: `.opencode/command/todo.md`

**Changes**:
```xml
<stage id="6" name="GitCommit">
  <action>Commit archival changes</action>
  <process>
    1. Stage files:
       - git add TODO.md
       - git add .opencode/specs/state.json
       - git add .opencode/specs/archive/state.json
       - git add .opencode/specs/archive/  # Pick up moved directories
    2. Verify staged changes:
       - git status --short
    3. Create commit:
       - Message format: "todo: archive {N} completed/abandoned tasks"
       - Examples:
         * "todo: archive 2 completed tasks"
         * "todo: archive 5 completed/abandoned tasks"
         * "todo: archive 1 abandoned task"
    4. If commit fails:
       - Log error to errors.json
       - Continue (commit failure non-critical)
       - Archival already complete
  </process>
  <git_commit>
    Scope: TODO.md + state.json + archive/state.json + moved directories
    Message: "todo: archive {N} completed/abandoned tasks"
    
    Use git-workflow-manager for scoped commit
  </git_commit>
</stage>
```

**Acceptance Criteria**:
- [ ] Git scope includes all 4 entities
- [ ] Commit message format is descriptive
- [ ] Failure is non-critical (logged but archival succeeds)
- [ ] Uses git-workflow-manager

#### Task 3.2: Enhance User Feedback

**File**: `.opencode/command/todo.md`

**Changes**:
```xml
<stage id="7" name="ReturnSuccess">
  <action>Return comprehensive archival summary</action>
  <return_format>
    TODO.md archival complete
    
    Tasks archived: {total_count}
    - Completed: {completed_count}
    - Abandoned: {abandoned_count}
    
    Project directories moved:
    {for each moved directory:}
    - {number}_{slug} → archive/{number}_{slug}
    
    {if some tasks had no directories:}
    Tasks without project directories: {count}
    {for each:}
    - Task {number}: {title}
    
    Remaining active tasks: {remaining_count}
    
    Archive location: .opencode/specs/archive/state.json
  </return_format>
</stage>
```

**Acceptance Criteria**:
- [ ] Summary shows task counts by status
- [ ] Lists all moved directories
- [ ] Notes tasks without directories
- [ ] Shows remaining active task count
- [ ] Provides archive location

### Deliverables

- [ ] Expanded git commit scope
- [ ] Enhanced user feedback format
- [ ] Comprehensive archival summary
- [ ] Error handling for git failures

### Testing

**Integration Tests**:
- Test git commit includes all 4 entities
- Test commit message format
- Test user feedback shows correct counts
- Test handling of git commit failure

---

## Phase 4: Testing and Documentation [NOT STARTED]

**Estimated Hours**: 0.5  
**Complexity**: Low

### Objectives

1. Test all edge cases
2. Verify atomicity guarantees
3. Update documentation
4. Validate against acceptance criteria

### Tasks

#### Task 4.1: Edge Case Testing

**Test Scenarios**:

1. **No tasks to archive**
   - TODO.md has no [COMPLETED] or [ABANDONED] tasks
   - Expected: Early exit with message "No tasks to archive"

2. **Task without project directory**
   - Task 172 is [COMPLETED] but no .opencode/specs/172_*/ exists
   - Expected: Archive task, skip directory move, log info

3. **Missing archive/state.json**
   - First archival operation
   - Expected: Self-healing creates archive/state.json

4. **User declines confirmation**
   - 6 tasks to archive, user types "no"
   - Expected: Abort gracefully, no changes

5. **Directory move fails (permissions)**
   - `shutil.move()` raises PermissionError
   - Expected: Rollback all operations, clear error message

6. **Git commit fails**
   - `git commit` returns non-zero
   - Expected: Log error, return success with warning

7. **state.json and TODO.md out of sync**
   - state.json has extra entry not in TODO.md
   - Expected: Proceed with TODO.md as source of truth

#### Task 4.2: Atomicity Validation

**Test Scenarios**:

1. **Rollback on state.json write failure**
   - Simulate write failure after TODO.md updated
   - Verify: TODO.md restored, no partial archival

2. **Rollback on directory move failure**
   - Simulate move failure after files updated
   - Verify: All files restored, directories reversed

3. **Partial move rollback**
   - 3 directories to move, 2nd fails
   - Verify: 1st move reversed, 3rd not attempted

#### Task 4.3: Documentation Updates

**Files to Update**:

1. **`.opencode/command/todo.md`**
   - Update command description with archival capabilities
   - Add examples of archival output
   - Document error scenarios

2. **`.opencode/context/common/system/state-schema.md`**
   - Add section on `/todo` command archival workflow
   - Include examples of archive state entries

3. **Research Report** (this file)
   - Mark as "Plan Created"
   - Link to this implementation plan

#### Task 4.4: Acceptance Criteria Validation

**Verify All Criteria**:
- [ ] /todo identifies all [COMPLETED] and [ABANDONED] tasks
- [ ] Tasks removed from TODO.md with numbering preserved
- [ ] Directories moved to archive/ (if exist)
- [ ] Entries moved from state.json to archive/state.json
- [ ] archive/state.json created if missing (self-healing)
- [ ] Repository health metrics updated
- [ ] Recent activities log updated
- [ ] Archival is atomic
- [ ] Summary report provided
- [ ] No data loss
- [ ] Lazy creation followed
- [ ] Error handling for edge cases

### Deliverables

- [ ] All edge case tests passing
- [ ] Atomicity validated
- [ ] Documentation updated
- [ ] Acceptance criteria verified

### Testing

**Manual Tests**:
- Run `/todo` on real TODO.md with 1-2 completed tasks
- Verify archival completes successfully
- Check archive/state.json has correct entries
- Verify directories moved correctly

---

## Success Criteria

### Functional Success

1. **Archival Functionality**:
   - [ ] `/todo` archives completed and abandoned tasks
   - [ ] Project directories moved to archive/
   - [ ] archive/state.json updated with metadata
   - [ ] TODO.md and state.json cleaned up
   - [ ] Task numbering preserved with gaps

2. **Data Integrity**:
   - [ ] No data loss on any operation
   - [ ] Atomic updates across all 4 entities
   - [ ] Self-healing for missing archive infrastructure
   - [ ] Rollback on any failure

3. **User Experience**:
   - [ ] User confirmation for bulk archival (>5 tasks)
   - [ ] Clear, comprehensive archival summary
   - [ ] Helpful error messages with recovery instructions

### Non-Functional Success

1. **Atomicity**: All or nothing across 4 entities
2. **Performance**: Handles up to 100 tasks in single operation
3. **Reliability**: Comprehensive error handling and rollback
4. **Maintainability**: Well-documented, follows existing patterns

---

## Risk Mitigation

### Identified Risks

1. **Four-file atomic commit increases failure surface**
   - Mitigation: Comprehensive rollback mechanism
   - Testing: Test all failure scenarios

2. **Directory move operations can fail**
   - Mitigation: Clear error messages, graceful rollback
   - Testing: Test permission errors, disk space

3. **Git conflicts with user's working directory**
   - Mitigation: Git commit is non-critical, log and continue
   - Testing: Test with uncommitted changes

### Contingency Plans

1. **If rollback fails**:
   - Log critical error with session details
   - Provide manual recovery instructions
   - Recommend git reset to last good state

2. **If archive/state.json corrupted**:
   - Self-healing recreates from template
   - Lost archive entries are non-critical
   - Manual reconstruction possible from git history

---

## Dependencies

### Internal Dependencies

- Existing `/todo` command workflow (Stages 1-2, 4-7)
- Two-phase commit pattern (from current implementation)
- self-healing pattern (from state.json)
- status-markers.md (for status definitions)

### External Dependencies

None (all functionality self-contained)

---

## Implementation Notes

### Code Reuse

- Leverage existing two-phase commit in Stage 5
- Reuse confirmation logic from Stage 2
- Apply self-healing pattern from state.json creation

### Testing Strategy

- Unit tests for individual functions
- Integration tests for full workflow
- Manual testing on real TODO.md
- Edge case testing (7 scenarios identified)

### Documentation

- Update command documentation
- Add examples to state-schema.md
- Link research report to plan

---

## Rollout Plan

1. **Phase 1**: Implement and test archival preparation logic
2. **Phase 2**: Implement and test atomic four-file commit
3. **Phase 3**: Implement git commit and user feedback
4. **Phase 4**: Test edge cases and update documentation
5. **Validation**: Run on real TODO.md with test tasks
6. **Deployment**: Merge to main after all tests pass

---

## Related Documentation

- **Research Report**: `.opencode/specs/201_todo_archival_feature/reports/research-001.md`
- **Research Summary**: `.opencode/specs/201_todo_archival_feature/summaries/research-summary.md`
- **Existing /todo Command**: `.opencode/command/todo.md`
- **Archive State Schema**: `.opencode/specs/archive/state.json`
- **State Schema Reference**: `.opencode/context/common/system/state-schema.md`
- **Status Markers**: `.opencode/context/common/system/status-markers.md`
- **Git Commits Standard**: `.opencode/context/common/system/git-commits.md`

---

## Conclusion

This implementation plan provides a comprehensive, phased approach to adding archival functionality to the `/todo` command. The plan follows the In-Place Enhancement approach (Option 1) recommended in the research, leveraging existing infrastructure and patterns while adding robust new capabilities.

**Key Strengths**:
- Minimal disruption (builds on existing workflow)
- Atomicity guaranteed via two-phase commit
- Comprehensive error handling and rollback
- Self-healing for infrastructure
- Clear testing and validation strategy

**Estimated Total Effort**: 6.0 hours across 4 phases

**Ready for Implementation**: Yes
