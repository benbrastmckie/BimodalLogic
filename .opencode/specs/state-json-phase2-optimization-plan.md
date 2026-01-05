# State.json Phase 2 Optimization Plan - Extended Command Coverage

**Project**: ProofChecker State Management Optimization - Phase 2
**Created**: 2026-01-05
**Revised**: 2026-01-05 (Coordinated with task-command-refactor-plan.md)
**Status**: DRAFT - Ready for Review
**Depends On**: state-json-optimization-plan.md (Phase 1 - COMPLETED)
**Coordinates With**: task-command-refactor-plan.md (IN PROGRESS)

## Revision Summary (2026-01-05)

This plan has been revised to coordinate with `task-command-refactor-plan.md`, which enhances the `/task` command to include description clarification. Key changes:

### Changes to Phase 1 (Synchronization Utilities)
- **status-sync-manager.create_task()** now supports separate `title` and `description` parameters
- TODO.md format includes **Description**: field (per task-command-refactor-plan.md)
- state.json format includes "description" field (per task-command-refactor-plan.md)
- Validation utilities check description field consistency
- Repair utilities handle missing description fields
- **Effort increased**: 3 hours → 3.5 hours

### Changes to Phase 5 (/task Command)
- **Scope changed**: Focus on task-creator subagent integration with sync manager
- **Workflow unchanged**: /task command workflow handled by task-command-refactor-plan.md
- task-creator subagent updated to use status-sync-manager.create_task()
- Ensures atomic task creation with description field
- **Effort increased**: 1.5 hours → 2 hours

### Implementation Coordination
- **Critical Path**: This plan Phase 1 → task-command-refactor-plan.md Phase 2 → This plan Phase 5 → task-command-refactor-plan.md Phase 3
- **Parallel Work**: Phases 2-4 (/todo, /review, /meta) can proceed independently
- **Total Effort**: 13.5 hours → 14.5 hours

## Executive Summary

Phase 1 successfully optimized `/implement`, `/research`, `/plan`, and `/revise` commands to use state.json for fast task lookup, achieving 25-50x performance improvement (100ms → 4ms). This plan extends the optimization to the remaining commands (`/todo`, `/review`, `/meta`, `/task`) and improves synchronization utilities to ensure state.json and TODO.md remain perfectly synchronized.

### Scope

**Commands to Optimize**:
1. `/todo` - Archive completed/abandoned tasks
2. `/review` - Codebase analysis and registry updates
3. `/meta` - System builder and task creation
4. `/task` - Simple task creation

**Synchronization Improvements**:
1. Enhance status-sync-manager for better state.json handling
2. Add validation utilities for state.json ↔ TODO.md consistency
3. Create repair utilities for desynchronization scenarios

## Problem Analysis

### Current State

**Phase 1 Commands** (✅ Optimized):
- `/implement`, `/research`, `/plan`, `/revise`
- Use state.json for fast task lookup (4ms average)
- 25-50x faster than TODO.md parsing

**Phase 2 Commands** (⚠️ Not Optimized):
- `/todo` - Scans TODO.md for completed/abandoned tasks (Stage 1)
- `/review` - Loads TODO.md for task creation
- `/meta` - Creates tasks, updates state.json and TODO.md
- `/task` - Creates tasks, updates state.json and TODO.md

### Performance Opportunities

| Command | Current Approach | Optimization Opportunity | Expected Improvement |
|---------|------------------|-------------------------|---------------------|
| `/todo` | Scans TODO.md for [COMPLETED]/[ABANDONED] | Query state.json by status | 10-20x faster scanning |
| `/review` | Reads TODO.md for next_project_number | Read from state.json | 25-50x faster |
| `/meta` | Updates TODO.md and state.json separately | Use state.json as source of truth | Better consistency |
| `/task` | Updates TODO.md and state.json separately | Use state.json as source of truth | Better consistency |

### Synchronization Concerns

**Current Synchronization**:
- status-sync-manager handles status updates atomically
- Two-phase commit ensures consistency
- Works well for status transitions

**Gaps**:
1. **Task Creation**: `/meta` and `/task` update files separately (not atomic)
2. **Bulk Operations**: `/todo` archives multiple tasks (complex synchronization)
3. **Validation**: No automated check for state.json ↔ TODO.md consistency
4. **Repair**: No automated repair for desynchronization

## Proposed Solution

### Design Principles

1. **state.json as Source of Truth for Automation**:
   - All commands read from state.json (fast, structured)
   - TODO.md remains human-readable interface
   - Synchronization ensures both stay consistent

2. **Atomic Updates for All Operations**:
   - Task creation (single task)
   - Task archival (bulk operations)
   - Status transitions (existing)

3. **Validation and Repair**:
   - Automated consistency checks
   - Self-healing for minor desynchronization
   - Clear error messages for manual intervention

### Architecture Changes

#### Current Flow (Mixed Approach)

```
Phase 1 Commands (Optimized):
  /implement → state.json lookup → fast (4ms)
  /research → state.json lookup → fast (4ms)
  /plan → state.json lookup → fast (4ms)
  /revise → state.json lookup → fast (4ms)

Phase 2 Commands (Not Optimized):
  /todo → TODO.md scan → slow (~100ms)
  /review → TODO.md read → slow (~100ms)
  /meta → TODO.md + state.json separate updates → inconsistency risk
  /task → TODO.md + state.json separate updates → inconsistency risk
```

#### Proposed Flow (Fully Optimized)

```
All Commands:
  Read Operations → state.json (fast, 4ms average)
  Write Operations → enhanced-sync-manager (atomic, consistent)

Synchronization:
  enhanced-sync-manager → updates both TODO.md and state.json atomically
  validation-utility → checks consistency periodically
  repair-utility → fixes desynchronization automatically
```

## Implementation Plan

### Phase 1: Enhance Synchronization Utilities (3.5 hours)

**Goal**: Improve status-sync-manager and create validation/repair utilities

**Note**: This phase coordinates with task-command-refactor-plan.md to support description field in task creation.

#### Task 1.1: Enhance status-sync-manager (2 hours)

**Current Capabilities**:
- Atomic status updates
- Two-phase commit
- Rollback on failure

**Enhancements Needed**:
1. **Task Creation Support**:
   - Add `create_task()` method
   - Atomic creation in both TODO.md and state.json
   - Validate task number uniqueness
   - Handle priority section placement
   - **Support description field** (per task-command-refactor-plan.md)

2. **Bulk Operations Support**:
   - Add `archive_tasks()` method
   - Atomic archival of multiple tasks
   - Move tasks from active_projects to completed_projects
   - Update TODO.md in single transaction

3. **Metadata Sync**:
   - Ensure all fields sync correctly (language, priority, effort, **description**, etc.)
   - Validate metadata consistency
   - Handle optional fields gracefully

**Implementation**:
```markdown
New Methods in status-sync-manager:

1. create_task(task_number, title, description, metadata)
   - Validate task_number not in use
   - Validate description is non-empty (50-500 chars, per task-command-refactor-plan.md)
   - Create entry in state.json active_projects with description field
   - Create entry in TODO.md with Description field (correct priority section)
   - Atomic commit (both or neither)
   - Return success/failure

   TODO.md format (per task-command-refactor-plan.md):
   ```
   ### {number}. {title}
   - **Effort**: {effort}
   - **Status**: [NOT STARTED]
   - **Priority**: {priority}
   - **Language**: {language}
   - **Blocking**: None
   - **Dependencies**: None
   
   **Description**: {description}
   
   ---
   ```

   state.json format (per task-command-refactor-plan.md):
   ```json
   {
     "project_number": {number},
     "project_name": "{slug}",
     "type": "feature",
     "phase": "not_started",
     "status": "not_started",
     "priority": "{priority}",
     "language": "{language}",
     "description": "{description}",
     "effort": "{effort}",
     "blocking": [],
     "dependencies": [],
     "created": "{timestamp}",
     "last_updated": "{timestamp}"
   }
   ```

2. archive_tasks(task_numbers, archive_metadata)
   - Validate all tasks exist
   - Move from active_projects to completed_projects in state.json
   - Remove from TODO.md
   - Add to archive/state.json
   - Atomic commit (all or nothing)
   - Return archived count

3. validate_metadata(task_number)
   - Compare TODO.md and state.json metadata
   - Include description field in comparison
   - Return differences if any
   - Suggest corrections
```

**Files to Modify**:
- `.opencode/agent/subagents/status-sync-manager.md`

**Coordination with task-command-refactor-plan.md**:
- ✅ create_task() signature includes title and description (separate parameters)
- ✅ TODO.md format includes **Description**: field
- ✅ state.json format includes "description" field
- ✅ Validation ensures description is 50-500 chars
- ✅ Compatible with task-creator subagent updates (task-command-refactor-plan.md Phase 2)

**Validation**:
- [ ] create_task() creates task atomically in both files
- [ ] Description field appears in both TODO.md and state.json
- [ ] archive_tasks() handles bulk operations correctly
- [ ] Rollback works for all new methods
- [ ] Metadata stays synchronized (including description)
- [ ] Multi-line descriptions work correctly

**Estimated Effort**: 2 hours (increased from 1.5 hours due to description field support)

#### Task 1.2: Create Validation Utility (1 hour)

**Purpose**: Automated consistency checking between state.json and TODO.md

**Features**:
1. **Consistency Checks**:
   - All tasks in state.json exist in TODO.md
   - All tasks in TODO.md exist in state.json
   - Metadata matches (status, priority, language, etc.)
   - Task numbers are unique
   - next_project_number is correct

2. **Reporting**:
   - List inconsistencies found
   - Severity levels (critical, warning, info)
   - Suggested fixes

3. **Auto-Repair** (optional):
   - Fix minor inconsistencies automatically
   - Require confirmation for major changes

**Implementation**:
```bash
# New utility script
.opencode/scripts/validate_state_sync.py

Features:
- Read both TODO.md and state.json
- Compare task lists
- Compare metadata for each task
- Report inconsistencies
- Optionally repair (with --fix flag)

Usage:
  python3 .opencode/scripts/validate_state_sync.py          # Check only
  python3 .opencode/scripts/validate_state_sync.py --fix    # Check and repair
  python3 .opencode/scripts/validate_state_sync.py --report # Detailed report
```

**Validation Checks**:
```python
1. Task Existence:
   - state.json task exists in TODO.md
   - TODO.md task exists in state.json
   - Severity: CRITICAL (missing tasks)

2. Metadata Consistency:
   - Status matches
   - Priority matches
   - Language matches
   - Effort matches
   - Description matches (NEW - per task-command-refactor-plan.md)
   - Severity: WARNING (metadata mismatch)

3. Numbering:
   - No duplicate task numbers
   - next_project_number > max(task_numbers)
   - Severity: CRITICAL (numbering issues)

4. Structure:
   - state.json is valid JSON
   - TODO.md has required sections
   - TODO.md has Description field for each task (NEW)
   - state.json has description field for each task (NEW)
   - Severity: CRITICAL (structure issues)
```

**Files to Create**:
- `.opencode/scripts/validate_state_sync.py`
- `.opencode/context/core/system/validation-utilities.md` (documentation)

**Validation**:
- [ ] Detects missing tasks in either file
- [ ] Detects metadata mismatches
- [ ] Detects numbering issues
- [ ] Provides clear error messages
- [ ] Auto-repair works correctly (with --fix)

**Estimated Effort**: 1 hour

#### Task 1.3: Create Repair Utility (30 minutes)

**Purpose**: Automated repair for common desynchronization scenarios

**Scenarios to Handle**:
1. **Missing task in state.json**: Add from TODO.md
2. **Missing task in TODO.md**: Add from state.json
3. **Metadata mismatch**: Use state.json as source of truth (or prompt user)
4. **Incorrect next_project_number**: Recalculate from max task number

**Implementation**:
```bash
# Repair utility (can be part of validate_state_sync.py)
python3 .opencode/scripts/validate_state_sync.py --fix --auto

Features:
- Detect inconsistencies
- Apply fixes automatically (with --auto) or prompt user
- Create backup before repair
- Validate after repair
- Report changes made
```

**Repair Strategies**:
```python
1. Missing Task in state.json:
   - Parse task from TODO.md (including Description field)
   - Add to state.json active_projects (including description field)
   - Preserve all metadata

2. Missing Task in TODO.md:
   - Get task from state.json (including description field)
   - Add to TODO.md with Description field (correct priority section)
   - Format according to standards (per task-command-refactor-plan.md)

3. Metadata Mismatch:
   - Prompt user: "Use state.json or TODO.md as source?"
   - Or: Use state.json by default (automation-friendly)
   - Update the other file
   - Include description field in comparison

4. Incorrect next_project_number:
   - Calculate: max(all_task_numbers) + 1
   - Update state.json

5. Missing Description Field (NEW):
   - If TODO.md has Description but state.json doesn't: copy to state.json
   - If state.json has description but TODO.md doesn't: copy to TODO.md
   - If neither has description: mark as WARNING (legacy task)
```

**Files to Modify**:
- `.opencode/scripts/validate_state_sync.py` (add repair logic)

**Validation**:
- [ ] Repairs missing tasks correctly
- [ ] Handles metadata mismatches
- [ ] Recalculates next_project_number correctly
- [ ] Creates backups before repair
- [ ] Validates after repair

**Estimated Effort**: 30 minutes

---

### Phase 2: Optimize /todo Command (2 hours)

**Goal**: Use state.json for fast scanning of completed/abandoned tasks

#### Current Approach (Stage 1: ScanTODO)

```xml
<stage id="1" name="ScanTODO">
  1. Load TODO.md (entire file, ~2000+ lines)
  2. Parse all task entries
  3. Identify tasks with [COMPLETED] status
  4. Identify tasks with [ABANDONED] status
  5. Count total tasks to remove
  6. Prepare removal list
</stage>
```

**Performance**: ~100-200ms for scanning TODO.md

#### Proposed Approach (Stage 1: ScanState)

```xml
<stage id="1" name="ScanState">
  1. Load state.json (structured data)
  2. Query tasks by status:
     completed_tasks=$(jq -r '.active_projects[] | select(.status == "completed") | .project_number' state.json)
     abandoned_tasks=$(jq -r '.active_projects[] | select(.status == "abandoned") | .project_number' state.json)
  3. Count total tasks to archive
  4. Prepare archival list with metadata
</stage>
```

**Performance**: ~10-20ms for querying state.json (10-20x faster)

#### Implementation Changes

**File to Modify**: `.opencode/command/todo.md`

**Changes**:

1. **Stage 1: ScanState** (replace ScanTODO):
   ```xml
   <stage id="1" name="ScanState">
     <action>Query state.json for completed and abandoned tasks</action>
     <process>
       1. Validate state.json exists and is valid JSON
       2. Query completed tasks:
          completed=$(jq -r '.active_projects[] | select(.status == "completed") | 
            {project_number, project_name, completed}' .opencode/specs/state.json)
       3. Query abandoned tasks:
          abandoned=$(jq -r '.active_projects[] | select(.status == "abandoned") | 
            {project_number, project_name, abandoned, abandonment_reason}' .opencode/specs/state.json)
       4. Combine into archival list
       5. Count total tasks to archive
       6. Extract metadata for each task (for archive/state.json)
     </process>
     <checkpoint>Archival list prepared from state.json</checkpoint>
   </stage>
   ```

2. **Stage 4: RunCleanupScript** (enhance):
   - Pass archival list to cleanup script
   - Script uses list instead of scanning TODO.md
   - Faster execution

3. **Add Validation**:
   - Verify state.json exists before scanning
   - Validate JSON structure
   - Handle missing state.json gracefully

**Benefits**:
- ✅ 10-20x faster scanning (10-20ms vs 100-200ms)
- ✅ More reliable (structured data vs text parsing)
- ✅ Better metadata extraction (all fields available)
- ✅ Easier to extend (add new status filters)

**Validation**:
- [ ] Correctly identifies completed tasks
- [ ] Correctly identifies abandoned tasks
- [ ] Handles empty archival list (no tasks to archive)
- [ ] Metadata extraction works correctly
- [ ] Cleanup script receives correct task list

**Estimated Effort**: 2 hours

---

### Phase 3: Optimize /review Command (1.5 hours)

**Goal**: Use state.json for fast access to task metadata and next_project_number

#### Current Approach

```markdown
Orchestrator handles:
- Parse review scope from arguments
- Load current registries
- Determine review focus
- Read next_project_number from state.json  ← Already uses state.json!
- Delegate to reviewer subagent
```

**Analysis**: `/review` already reads next_project_number from state.json. Main optimization is ensuring reviewer subagent uses state.json for task queries.

#### Proposed Enhancements

1. **Reviewer Subagent Optimization**:
   - Use state.json to query tasks by language (for Lean-specific reviews)
   - Use state.json to query tasks by status (for maintenance task creation)
   - Use state.json for task metadata when creating maintenance tasks

2. **Fast Task Queries**:
   ```bash
   # Get all Lean tasks
   lean_tasks=$(jq -r '.active_projects[] | select(.language == "lean") | 
     {project_number, project_name, status}' .opencode/specs/state.json)
   
   # Get all tasks with sorry/axiom issues (if tracked in state.json)
   sorry_tasks=$(jq -r '.active_projects[] | select(.has_sorry == true) | 
     {project_number, project_name}' .opencode/specs/state.json)
   ```

3. **Task Creation via Enhanced Sync Manager**:
   - Use status-sync-manager.create_task() for atomic task creation
   - Ensures consistency between TODO.md and state.json

**Files to Modify**:
- `.opencode/agent/subagents/reviewer.md` (if it exists)
- `.opencode/command/review.md` (documentation)

**Benefits**:
- ✅ Faster task queries (4ms vs 100ms)
- ✅ Atomic task creation (via enhanced sync manager)
- ✅ Better consistency

**Validation**:
- [ ] Task queries use state.json
- [ ] Task creation uses enhanced sync manager
- [ ] Review completes successfully
- [ ] Created tasks appear in both TODO.md and state.json

**Estimated Effort**: 1.5 hours

---

### Phase 4: Optimize /meta Command (2 hours)

**Goal**: Use enhanced sync manager for atomic task creation

#### Current Approach (Stage 7: Create Tasks With Artifacts)

```markdown
Stage 7: Create Tasks With Artifacts
- Determines task breakdown based on system complexity
- Creates project directories in .opencode/specs/NNN_*/
- Generates plan artifacts ONLY (plans/implementation-001.md)
- Creates task entries in TODO.md with Type field set to 'meta'
- Updates state.json with task metadata and increments next_project_number
- Validates all artifacts
```

**Issue**: Updates TODO.md and state.json separately (not atomic)

#### Proposed Approach

1. **Use Enhanced Sync Manager**:
   ```markdown
   Stage 7: Create Tasks With Artifacts
   - Determines task breakdown
   - Creates project directories
   - Generates plan artifacts
   - For each task:
     * Call status-sync-manager.create_task(number, description, metadata)
     * Atomic creation in both TODO.md and state.json
     * Validates creation succeeded
   - Validates all artifacts
   ```

2. **Batch Task Creation**:
   - Create all tasks in single transaction
   - Rollback all if any fails
   - Ensures consistency

**Files to Modify**:
- `.opencode/agent/subagents/meta/meta.md` (or wherever meta agent is defined)
- `.opencode/command/meta.md` (documentation)

**Benefits**:
- ✅ Atomic task creation (all or nothing)
- ✅ Guaranteed consistency between TODO.md and state.json
- ✅ Better error handling (rollback on failure)
- ✅ Simpler code (delegate to sync manager)

**Validation**:
- [ ] Tasks created atomically
- [ ] Rollback works if creation fails
- [ ] All tasks appear in both files
- [ ] Metadata is consistent
- [ ] next_project_number increments correctly

**Estimated Effort**: 2 hours

---

### Phase 5: Optimize /task Command (2 hours)

**Goal**: Integrate with task-creator subagent for atomic task creation with description clarification

#### Current Approach (Per task-command-refactor-plan.md)

The `/task` command is being refactored to include description clarification:

```xml
<stage id="1" name="ParseAndValidate">
  - Parse rough description from $ARGUMENTS
  - Extract optional flags (--priority, --effort, --language, --skip-clarification)
  - Validate description is non-empty
</stage>

<stage id="2" name="ClarifyDescription">
  - Invoke description-clarifier subagent
  - Research and clarify task description
  - Extract metadata (language, priority, effort)
  - Override flags with clarified metadata if not explicitly set
</stage>

<stage id="3" name="CreateTask">
  - Invoke task-creator subagent
  - Pass clarified description and metadata
  - task-creator handles TODO.md and state.json updates
</stage>
```

**Issue**: task-creator subagent (per task-command-refactor-plan.md Phase 2) will be updated to require description field and create entries in both TODO.md and state.json, but needs to use enhanced sync manager for atomic operations.

#### Proposed Approach

**Phase 5 focuses on ensuring task-creator uses enhanced sync manager**, not modifying /task command workflow (which is handled by task-command-refactor-plan.md).

**Changes to task-creator subagent**:

1. **Update Step 3 (UpdateFiles) to use enhanced sync manager**:
   ```xml
   <step_3_update_files>
     <action>Create task atomically using enhanced sync manager</action>
     <process>
       1. Prepare task metadata:
          - task_number (from next_project_number)
          - title
          - description (NEW - from clarified description)
          - priority
          - effort
          - language
          - status: not_started
       
       2. Call status-sync-manager.create_task():
          - Atomic creation in both TODO.md and state.json
          - Validates task number uniqueness
          - Places in correct priority section
          - Increments next_project_number
          - Rollback on failure
       
       3. Validate creation succeeded
       4. Return task number and metadata
     </process>
     <checkpoint>Task created atomically</checkpoint>
   </step_3_update_files>
   ```

2. **Remove separate TODO.md and state.json update logic**:
   - Old approach: Step 2 formats TODO entry, Step 3 updates both files separately
   - New approach: Step 2 prepares metadata, Step 3 delegates to sync manager

**Files to Modify**:
- `.opencode/agent/subagents/task-creator.md` (update Step 3 to use sync manager)

**Coordination with task-command-refactor-plan.md**:
- ✅ task-command-refactor-plan.md Phase 2 adds description field to task-creator inputs
- ✅ This phase (state.json Phase 5) makes task-creator use sync manager for atomic updates
- ✅ Both changes are compatible and complementary

**Benefits**:
- ✅ Atomic task creation (both files or neither)
- ✅ Consistent with other optimized commands
- ✅ Better error handling (automatic rollback)
- ✅ Guaranteed consistency
- ✅ Works seamlessly with description clarification workflow

**Validation**:
- [ ] task-creator uses enhanced sync manager
- [ ] Task created atomically in both TODO.md and state.json
- [ ] Description field included (from task-command-refactor-plan.md)
- [ ] Metadata is consistent
- [ ] Rollback works on failure
- [ ] next_project_number increments correctly
- [ ] Works with /task command's clarification workflow

**Estimated Effort**: 2 hours (increased from 1.5 hours due to coordination with task-command-refactor-plan.md)

---

### Phase 6: Testing and Validation (2 hours)

**Goal**: Comprehensive testing of all optimizations and synchronization

#### Test Matrix

| Command | Test Case | Expected Result |
|---------|-----------|-----------------|
| `/todo` | Archive 5 completed tasks | Fast scan (10-20ms), atomic archival |
| `/todo` | No tasks to archive | Fast scan, early return |
| `/review` | Full codebase review | Fast task queries, atomic task creation |
| `/meta` | Create 3 tasks | Atomic creation, all tasks in both files |
| `/task` | Create task with clarification | Clarified description, atomic creation, Description field in both files |
| `/task` | Create task with --skip-clarification | No clarification, atomic creation, Description field in both files |
| `validate_state_sync.py` | Check consistency | Reports no issues, validates description fields |
| `validate_state_sync.py` | Check task with missing description | Reports WARNING for missing description field |
| `validate_state_sync.py --fix` | Repair desync | Fixes issues, validates after, repairs missing descriptions |

#### Performance Testing

```bash
# Test /todo performance
time /todo  # Should be <50ms total (vs ~200ms before)

# Test /review performance
time /review lean  # Should use state.json for queries

# Test /meta performance
time /meta "Create test system"  # Atomic task creation

# Test /task performance
time /task "Test task"  # Atomic creation
```

**Performance Targets**:
- `/todo` scanning: <20ms (vs ~100ms before, 5x faster)
- `/review` task queries: <10ms per query
- `/meta` task creation: <50ms per task (atomic)
- `/task` task creation: <30ms (atomic)

#### Consistency Testing

```bash
# Create tasks with /task (with description clarification per task-command-refactor-plan.md)
/task "sync thing for todo and state"
# Expected: Clarifies description, creates task with Description field in both files

/task "Test task 2" --skip-clarification
# Expected: Creates task without clarification, still includes Description field

# Validate consistency (including description field)
python3 .opencode/scripts/validate_state_sync.py
# Expected: No inconsistencies found
# Expected: Description field present in both TODO.md and state.json

# Archive tasks with /todo
/todo

# Validate consistency
python3 .opencode/scripts/validate_state_sync.py
# Expected: No inconsistencies found

# Create tasks with /meta
/meta "Create test system"

# Validate consistency
python3 .opencode/scripts/validate_state_sync.py
# Expected: No inconsistencies found

# Test description field validation
# Manually remove Description field from TODO.md for task 296
python3 .opencode/scripts/validate_state_sync.py
# Expected: WARNING - Description field missing in TODO.md for task 296

# Repair description field
python3 .opencode/scripts/validate_state_sync.py --fix
# Expected: Copies description from state.json to TODO.md
```

#### Synchronization Testing

```bash
# Test rollback on failure
# (Simulate failure in status-sync-manager)

# Test repair utility
# (Manually create desynchronization)
# Run: python3 .opencode/scripts/validate_state_sync.py --fix
# Expected: Repairs desynchronization

# Test validation utility
# (Check various scenarios)
```

**Validation Checklist**:
- [ ] All commands use state.json for reads
- [ ] All commands use enhanced sync manager for writes
- [ ] Performance targets met
- [ ] Consistency maintained across all operations
- [ ] Rollback works correctly
- [ ] Validation utility detects issues (including missing description fields)
- [ ] Repair utility fixes issues (including missing description fields)
- [ ] No regressions in existing functionality
- [ ] Description field appears in all new tasks (TODO.md and state.json)
- [ ] Description field validation works correctly
- [ ] Multi-line descriptions work correctly
- [ ] Legacy tasks without descriptions handled gracefully

**Estimated Effort**: 2 hours

---

### Phase 7: Documentation and Cleanup (1 hour)

**Goal**: Update documentation to reflect Phase 2 optimizations

#### Documentation Updates

1. **Update state-lookup.md**:
   - Add patterns for bulk operations (archival)
   - Add patterns for task creation
   - Document enhanced sync manager usage

2. **Update state-management.md**:
   - Document enhanced sync manager methods
   - Document validation and repair utilities
   - Add troubleshooting guide

3. **Create validation-utilities.md**:
   - Document validate_state_sync.py usage
   - Document repair strategies
   - Add examples and troubleshooting

4. **Update command documentation**:
   - Update /todo.md with state.json approach
   - Update /review.md with optimization notes
   - Update /meta.md with atomic creation
   - Update /task.md with atomic creation

5. **Update command-template.md**:
   - Add task creation pattern (via sync manager)
   - Add bulk operation pattern
   - Add validation pattern

**Files to Update**:
- `.opencode/context/core/system/state-lookup.md`
- `.opencode/context/core/system/state-management.md`
- `.opencode/context/core/system/validation-utilities.md` (new)
- `.opencode/command/todo.md`
- `.opencode/command/review.md`
- `.opencode/command/meta.md`
- `.opencode/command/task.md`
- `.opencode/context/core/templates/command-template.md`

**Validation**:
- [ ] All documentation is accurate
- [ ] Examples match implementation
- [ ] No contradictory information
- [ ] Troubleshooting guides are helpful

**Estimated Effort**: 1 hour

---

## Detailed Implementation Examples

### Example 1: Enhanced status-sync-manager.create_task()

**Before** (separate updates, per task-command-refactor-plan.md):
```python
# In task-creator subagent
# Step 2: Create TODO entry
todo_entry = format_task_entry(number, title, description, metadata)
append_to_todo(todo_entry, priority_section)

# Step 3: Update state.json
state = read_state_json()
state['next_project_number'] += 1
state['active_projects'].append({
    'project_number': number,
    'project_name': slug,
    'description': description,  # NEW field
    'priority': priority,
    'effort': effort,
    'language': language,
    ...
})
write_state_json(state)
```

**After** (atomic via sync manager):
```python
# In task-creator subagent (updated per task-command-refactor-plan.md Phase 2)
# Step 3: Create task atomically
result = status_sync_manager.create_task(
    task_number=next_number,
    title=title,
    description=clarified_description,  # From description-clarifier
    metadata={
        'priority': priority,
        'effort': effort,
        'language': language,
        'status': 'not_started'
    }
)

if not result.success:
    # Automatic rollback already happened
    return error(result.error_message)
```

**sync-manager implementation** (enhanced for description field):
```python
def create_task(task_number, title, description, metadata):
    # Phase 1: Prepare
    validate_task_number_unique(task_number)
    validate_description(description)  # 50-500 chars
    
    # Format TODO.md entry with Description field
    todo_entry = format_todo_entry(task_number, title, description, metadata)
    # Example:
    # ### 296. Create /sync command
    # - **Effort**: 4 hours
    # - **Status**: [NOT STARTED]
    # - **Priority**: High
    # - **Language**: meta
    # - **Blocking**: None
    # - **Dependencies**: None
    # 
    # **Description**: Create a /sync command that synchronizes TODO.md and state.json bidirectionally.
    # 
    # ---
    
    # Format state.json entry with description field
    state_entry = format_state_entry(task_number, title, description, metadata)
    # Example:
    # {
    #   "project_number": 296,
    #   "project_name": "create_sync_command",
    #   "description": "Create a /sync command that synchronizes TODO.md and state.json bidirectionally.",
    #   "priority": "high",
    #   "language": "meta",
    #   "effort": "4 hours",
    #   ...
    # }
    
    # Backup current state
    backup_todo = read_file('TODO.md')
    backup_state = read_file('state.json')
    
    # Phase 2: Commit
    try:
        # Update TODO.md
        append_to_priority_section(todo_entry, metadata['priority'])
        
        # Update state.json
        state = json.loads(backup_state)
        state['active_projects'].append(state_entry)
        state['next_project_number'] += 1
        write_file('state.json', json.dumps(state))
        
        # Verify both succeeded
        verify_task_in_todo(task_number)
        verify_task_in_state(task_number)
        verify_description_in_both(task_number, description)  # NEW
        
        return success()
    except Exception as e:
        # Rollback
        write_file('TODO.md', backup_todo)
        write_file('state.json', backup_state)
        return error(f"Task creation failed: {e}")
```

### Example 2: /todo Command State.json Query

**Before** (TODO.md scanning):
```bash
# Stage 1: ScanTODO
todo_content=$(cat .opencode/specs/TODO.md)

# Find completed tasks (slow, ~100ms)
completed_tasks=$(echo "$todo_content" | grep -B 1 "\[COMPLETED\]" | grep "^###" | sed 's/### \([0-9]*\)\..*/\1/')

# Find abandoned tasks (slow, ~100ms)
abandoned_tasks=$(echo "$todo_content" | grep -B 1 "\[ABANDONED\]" | grep "^###" | sed 's/### \([0-9]*\)\..*/\1/')

# Total time: ~200ms
```

**After** (state.json query):
```bash
# Stage 1: ScanState
# Find completed tasks (fast, ~5ms)
completed_tasks=$(jq -r '.active_projects[] | select(.status == "completed") | .project_number' .opencode/specs/state.json)

# Find abandoned tasks (fast, ~5ms)
abandoned_tasks=$(jq -r '.active_projects[] | select(.status == "abandoned") | .project_number' .opencode/specs/state.json)

# Get metadata for archival (fast, ~5ms)
archival_data=$(jq -r '.active_projects[] | select(.status == "completed" or .status == "abandoned") | 
  {project_number, project_name, status, completed, abandoned, abandonment_reason}' .opencode/specs/state.json)

# Total time: ~15ms (13x faster)
```

### Example 3: Validation Utility

**Usage**:
```bash
# Check consistency
python3 .opencode/scripts/validate_state_sync.py

# Output:
# Checking state.json ↔ TODO.md consistency...
# 
# ✓ All tasks in state.json exist in TODO.md
# ✓ All tasks in TODO.md exist in state.json
# ✓ Metadata is consistent for all tasks
# ✓ Task numbers are unique
# ✓ next_project_number is correct (280)
# 
# No inconsistencies found.
```

**With issues**:
```bash
# Check consistency (with issues)
python3 .opencode/scripts/validate_state_sync.py

# Output:
# Checking state.json ↔ TODO.md consistency...
# 
# ✗ CRITICAL: Task 259 exists in state.json but not in TODO.md
# ✗ WARNING: Task 260 metadata mismatch:
#   - state.json: priority=high, status=planned
#   - TODO.md: priority=medium, status=not_started
# ✗ WARNING: next_project_number (280) should be 281 (max task + 1)
# 
# Found 3 inconsistencies (1 critical, 2 warnings)
# 
# Run with --fix to repair automatically.
```

**Auto-repair**:
```bash
# Repair inconsistencies
python3 .opencode/scripts/validate_state_sync.py --fix

# Output:
# Checking state.json ↔ TODO.md consistency...
# 
# Found 3 inconsistencies. Repairing...
# 
# Creating backup: .opencode/specs/TODO.md.backup
# Creating backup: .opencode/specs/state.json.backup
# 
# ✓ Added task 259 to TODO.md from state.json
# ✓ Updated task 260 metadata in TODO.md from state.json
# ✓ Updated next_project_number to 281
# 
# Validating repairs...
# ✓ All inconsistencies resolved
# 
# Repairs complete. Backups saved.
```

## Performance Analysis

### Expected Performance Improvements

| Operation | Before (TODO.md) | After (state.json) | Improvement |
|-----------|------------------|-------------------|-------------|
| /todo scan | ~200ms | ~15ms | 13x faster |
| /review task query | ~100ms | ~4ms | 25x faster |
| /meta task creation | ~150ms | ~50ms | 3x faster (atomic) |
| /task task creation | ~100ms | ~30ms | 3x faster (atomic) |

### Scalability

**TODO.md approach** (degrades linearly):
- 100 tasks: ~100ms scan
- 500 tasks: ~200ms scan
- 1000 tasks: ~400ms scan

**state.json approach** (scales well):
- 100 tasks: ~10ms query
- 500 tasks: ~15ms query
- 1000 tasks: ~20ms query

### Consistency Improvements

**Before**:
- Task creation: 2 separate file updates (risk of inconsistency)
- Bulk archival: Complex synchronization logic
- No automated validation
- Manual repair required

**After**:
- Task creation: Atomic (both files or neither)
- Bulk archival: Atomic via enhanced sync manager
- Automated validation (validate_state_sync.py)
- Automated repair (--fix flag)

## Risk Analysis

### Low Risk: Breaking Existing Synchronization

**Mitigation**:
- ✅ Enhance status-sync-manager (don't replace)
- ✅ Add new methods (create_task, archive_tasks)
- ✅ Preserve existing status update methods
- ✅ Backward compatible

**Contingency**: If issues arise, new methods can be disabled without affecting existing functionality

### Low Risk: Validation Utility False Positives

**Mitigation**:
- ✅ Comprehensive testing of validation logic
- ✅ Clear severity levels (critical vs warning)
- ✅ Manual review before auto-repair
- ✅ Backups before repair

**Contingency**: Restore from backup if repair causes issues

### Medium Risk: Bulk Operations Complexity

**Mitigation**:
- ✅ Thorough testing of /todo archival
- ✅ Transaction-based approach (all or nothing)
- ✅ Comprehensive rollback logic
- ✅ Validation after archival

**Contingency**: Rollback mechanism ensures system can recover from failures

### Low Risk: Performance Regression

**Mitigation**:
- ✅ JSON parsing is proven faster (Phase 1 results)
- ✅ Benchmark all operations
- ✅ Compare before/after performance

**Contingency**: If slower, revert to previous approach (unlikely based on Phase 1 results)

## Success Criteria

### Quantitative Metrics

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| /todo scan time | ~200ms | ~15ms | <20ms |
| /review task query | ~100ms | ~4ms | <10ms |
| /meta task creation | ~150ms | ~50ms | <100ms |
| /task task creation | ~100ms | ~30ms | <50ms |
| Consistency issues | Manual detection | Automated | 0 issues |

### Qualitative Metrics

- [ ] **Performance**: All commands feel noticeably faster
- [ ] **Consistency**: state.json and TODO.md always synchronized
- [ ] **Reliability**: Atomic operations prevent partial updates
- [ ] **Maintainability**: Easier to add new commands
- [ ] **Validation**: Automated consistency checking
- [ ] **Repair**: Automated repair for common issues

### Validation Checklist

- [ ] All Phase 2 commands use state.json for reads
- [ ] All Phase 2 commands use enhanced sync manager for writes
- [ ] Performance targets met for all operations
- [ ] Consistency maintained across all operations
- [ ] Validation utility detects all inconsistencies
- [ ] Repair utility fixes all common issues
- [ ] No regressions in Phase 1 commands
- [ ] Documentation is complete and accurate

## Rollback Plan

If issues arise:

1. **Immediate rollback**:
   ```bash
   git checkout .opencode/command/todo.md
   git checkout .opencode/command/review.md
   git checkout .opencode/command/meta.md
   git checkout .opencode/command/task.md
   git checkout .opencode/agent/subagents/status-sync-manager.md
   ```

2. **Restore previous behavior**:
   - Commands revert to previous approach
   - Functionality preserved
   - Performance returns to baseline

3. **Analyze failure**:
   - Review error logs
   - Identify root cause
   - Document issues

4. **Fix and retry**:
   - Address identified issues
   - Re-test thoroughly
   - Re-deploy

## Implementation Timeline

### Total Estimated Effort: ~14.5 hours

**Phase 1**: Enhance Synchronization Utilities (3.5 hours)
- Task 1.1: Enhance status-sync-manager (2 hours) - includes description field support
- Task 1.2: Create validation utility (1 hour) - includes description field validation
- Task 1.3: Create repair utility (30 minutes) - includes description field repair

**Phase 2**: Optimize /todo Command (2 hours)

**Phase 3**: Optimize /review Command (1.5 hours)

**Phase 4**: Optimize /meta Command (2 hours)

**Phase 5**: Optimize /task Command (2 hours) - coordinates with task-command-refactor-plan.md

**Phase 6**: Testing and Validation (2 hours)

**Phase 7**: Documentation and Cleanup (1 hour)

### Coordination with task-command-refactor-plan.md

**Dependencies**:
- ✅ Phase 1 (this plan) must complete before task-command-refactor-plan.md Phase 2
- ✅ status-sync-manager.create_task() must support description field
- ✅ Validation utilities must check description field consistency

**Parallel Work**:
- ⚙️ task-command-refactor-plan.md Phase 1 (description-clarifier) can proceed independently
- ⚙️ This plan's Phase 2-4 (/todo, /review, /meta) can proceed independently

**Sequential Work**:
1. This plan Phase 1 (enhance sync manager with description support)
2. task-command-refactor-plan.md Phase 2 (update task-creator to use sync manager)
3. This plan Phase 5 (verify task-creator integration)
4. task-command-refactor-plan.md Phase 3 (update /task command workflow)

### Recommended Approach

**Week 1** (Coordinated with task-command-refactor-plan.md):
- Day 1: Phase 1 (synchronization utilities with description support) - **PREREQUISITE for task-command-refactor-plan.md Phase 2**
- Day 2: Phase 2 (/todo optimization) + task-command-refactor-plan.md Phase 1 (description-clarifier) in parallel
- Day 3: Phase 3 (/review optimization) + task-command-refactor-plan.md Phase 2 (task-creator updates) in parallel

**Week 2**:
- Day 1: Phase 4 (/meta optimization)
- Day 2: Phase 5 (verify task-creator integration) + task-command-refactor-plan.md Phase 3 (/task workflow)
- Day 3: Phase 6 (testing and validation) + task-command-refactor-plan.md Phase 4 (testing)
- Day 4: Phase 7 (documentation) + task-command-refactor-plan.md Phase 5 (documentation)

**Critical Path**:
1. ✅ This plan Phase 1 (sync manager with description support) - **BLOCKS task-command-refactor-plan.md Phase 2**
2. ✅ task-command-refactor-plan.md Phase 2 (task-creator uses sync manager) - **BLOCKS this plan Phase 5**
3. ✅ This plan Phase 5 (verify integration) - **BLOCKS task-command-refactor-plan.md Phase 3**
4. ✅ task-command-refactor-plan.md Phase 3 (/task workflow) - **COMPLETES /task refactor**

## Conclusion

This Phase 2 optimization extends the successful Phase 1 approach to all remaining commands, achieving:

- ✅ **Comprehensive optimization**: All commands use state.json for fast reads
- ✅ **Atomic operations**: Enhanced sync manager ensures consistency
- ✅ **Automated validation**: Detect inconsistencies automatically
- ✅ **Automated repair**: Fix common issues automatically
- ✅ **Better performance**: 3-25x faster operations
- ✅ **Better reliability**: Atomic updates prevent partial failures
- ✅ **Description field support**: Coordinates with task-command-refactor-plan.md for enhanced task creation

The implementation builds on Phase 1's proven success (25-50x improvement) and extends it to the entire command ecosystem.

### Key Coordination Points with task-command-refactor-plan.md

1. **status-sync-manager.create_task()** (this plan Phase 1):
   - Adds description parameter (title and description separate)
   - Supports Description field in TODO.md
   - Supports description field in state.json
   - Validates description length (50-500 chars)

2. **task-creator subagent** (both plans):
   - task-command-refactor-plan.md Phase 2: Adds description input validation
   - This plan Phase 5: Updates to use status-sync-manager.create_task()
   - Result: Atomic task creation with description field

3. **/task command** (task-command-refactor-plan.md):
   - Adds description clarification workflow
   - Delegates to task-creator (which uses sync manager from this plan)
   - Result: Clarified descriptions + atomic creation

4. **Validation utilities** (this plan Phase 1):
   - Validates description field consistency
   - Repairs missing description fields
   - Supports legacy tasks without descriptions

---

**Next Steps**:
1. Review this plan
2. Approve or request changes
3. Implement Phase 1 (synchronization utilities)
4. Implement Phase 2 (/todo optimization)
5. Test thoroughly
6. Implement remaining phases
7. Validate performance and consistency improvements
8. Document lessons learned

**Dependencies**:
- Phase 1 (state-json-optimization-plan.md) must be completed ✅
- All Phase 1 commands must be working correctly ✅
- state.json must be properly maintained ✅
- **NEW**: Coordinates with task-command-refactor-plan.md for /task command enhancement

**Related Documents**:
- `.opencode/specs/state-json-optimization-plan.md` (Phase 1 - COMPLETED)
- `.opencode/specs/task-command-refactor-plan.md` (Parallel work - IN PROGRESS)
- `.opencode/context/core/system/state-lookup.md` (Phase 1 patterns)
- `.opencode/context/core/system/state-management.md` (State management standard)
- `.opencode/agent/subagents/status-sync-manager.md` (Current sync manager)
- `.opencode/agent/subagents/task-creator.md` (To be updated by both plans)
