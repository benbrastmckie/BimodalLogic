# State.json Phase 2 Optimization Plan - Extended Command Coverage

**Project**: ProofChecker State Management Optimization - Phase 2
**Created**: 2026-01-05
**Status**: DRAFT - Ready for Review
**Depends On**: state-json-optimization-plan.md (Phase 1 - COMPLETED)

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

### Phase 1: Enhance Synchronization Utilities (3 hours)

**Goal**: Improve status-sync-manager and create validation/repair utilities

#### Task 1.1: Enhance status-sync-manager (1.5 hours)

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

2. **Bulk Operations Support**:
   - Add `archive_tasks()` method
   - Atomic archival of multiple tasks
   - Move tasks from active_projects to completed_projects
   - Update TODO.md in single transaction

3. **Metadata Sync**:
   - Ensure all fields sync correctly (language, priority, effort, etc.)
   - Validate metadata consistency
   - Handle optional fields gracefully

**Implementation**:
```markdown
New Methods in status-sync-manager:

1. create_task(task_number, description, metadata)
   - Validate task_number not in use
   - Create entry in state.json active_projects
   - Create entry in TODO.md (correct priority section)
   - Atomic commit (both or neither)
   - Return success/failure

2. archive_tasks(task_numbers, archive_metadata)
   - Validate all tasks exist
   - Move from active_projects to completed_projects in state.json
   - Remove from TODO.md
   - Add to archive/state.json
   - Atomic commit (all or nothing)
   - Return archived count

3. validate_metadata(task_number)
   - Compare TODO.md and state.json metadata
   - Return differences if any
   - Suggest corrections
```

**Files to Modify**:
- `.opencode/agent/subagents/status-sync-manager.md`

**Validation**:
- [ ] create_task() creates task atomically in both files
- [ ] archive_tasks() handles bulk operations correctly
- [ ] Rollback works for all new methods
- [ ] Metadata stays synchronized

**Estimated Effort**: 1.5 hours

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
   - Severity: WARNING (metadata mismatch)

3. Numbering:
   - No duplicate task numbers
   - next_project_number > max(task_numbers)
   - Severity: CRITICAL (numbering issues)

4. Structure:
   - state.json is valid JSON
   - TODO.md has required sections
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
   - Parse task from TODO.md
   - Add to state.json active_projects
   - Preserve all metadata

2. Missing Task in TODO.md:
   - Get task from state.json
   - Add to TODO.md (correct priority section)
   - Format according to standards

3. Metadata Mismatch:
   - Prompt user: "Use state.json or TODO.md as source?"
   - Or: Use state.json by default (automation-friendly)
   - Update the other file

4. Incorrect next_project_number:
   - Calculate: max(all_task_numbers) + 1
   - Update state.json
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

### Phase 5: Optimize /task Command (1.5 hours)

**Goal**: Use enhanced sync manager for atomic task creation

#### Current Approach

```xml
<stage id="3" name="CreateTODOEntry">
  1. Format task entry
  2. Determine correct section in TODO.md
  3. Append entry to appropriate section
  4. Use Edit tool to add entry
</stage>

<stage id="4" name="UpdateStateJson">
  1. Read current state.json
  2. Increment next_project_number by 1
  3. Add entry to recent_activities
  4. Update _last_updated timestamp
  5. Write state.json atomically
</stage>
```

**Issue**: Two separate stages, not atomic across both files

#### Proposed Approach

```xml
<stage id="3" name="CreateTask">
  <action>Create task atomically in both TODO.md and state.json</action>
  <process>
    1. Prepare task metadata:
       - task_number (from state.json)
       - description
       - priority
       - effort
       - language
       - status: [NOT STARTED]
    
    2. Call status-sync-manager.create_task():
       - Atomic creation in both files
       - Validates task number uniqueness
       - Places in correct priority section
       - Increments next_project_number
       - Rollback on failure
    
    3. Validate creation succeeded
  </process>
  <checkpoint>Task created atomically</checkpoint>
</stage>

<stage id="4" name="ReturnSuccess">
  (Same as before)
</stage>
```

**Files to Modify**:
- `.opencode/command/task.md`

**Benefits**:
- ✅ Atomic task creation (both files or neither)
- ✅ Simpler workflow (3 stages → 2 stages)
- ✅ Better error handling (automatic rollback)
- ✅ Guaranteed consistency

**Validation**:
- [ ] Task created atomically
- [ ] Appears in both TODO.md and state.json
- [ ] Metadata is consistent
- [ ] Rollback works on failure
- [ ] next_project_number increments correctly

**Estimated Effort**: 1.5 hours

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
| `/task` | Create single task | Atomic creation, correct metadata |
| `validate_state_sync.py` | Check consistency | Reports no issues |
| `validate_state_sync.py --fix` | Repair desync | Fixes issues, validates after |

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
# Create tasks with /task
/task "Test task 1"
/task "Test task 2"

# Validate consistency
python3 .opencode/scripts/validate_state_sync.py
# Expected: No inconsistencies found

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
- [ ] Validation utility detects issues
- [ ] Repair utility fixes issues
- [ ] No regressions in existing functionality

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

**Before** (separate updates):
```python
# In /task command
# Stage 3: Create TODO entry
todo_entry = format_task_entry(number, description, metadata)
append_to_todo(todo_entry, priority_section)

# Stage 4: Update state.json
state = read_state_json()
state['next_project_number'] += 1
state['active_projects'].append(task_metadata)
write_state_json(state)
```

**After** (atomic via sync manager):
```python
# In /task command
# Stage 3: Create task atomically
result = status_sync_manager.create_task(
    task_number=next_number,
    description=description,
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

**sync-manager implementation**:
```python
def create_task(task_number, description, metadata):
    # Phase 1: Prepare
    validate_task_number_unique(task_number)
    todo_entry = format_todo_entry(task_number, description, metadata)
    state_entry = format_state_entry(task_number, description, metadata)
    
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

### Total Estimated Effort: ~13.5 hours

**Phase 1**: Enhance Synchronization Utilities (3 hours)
- Task 1.1: Enhance status-sync-manager (1.5 hours)
- Task 1.2: Create validation utility (1 hour)
- Task 1.3: Create repair utility (30 minutes)

**Phase 2**: Optimize /todo Command (2 hours)

**Phase 3**: Optimize /review Command (1.5 hours)

**Phase 4**: Optimize /meta Command (2 hours)

**Phase 5**: Optimize /task Command (1.5 hours)

**Phase 6**: Testing and Validation (2 hours)

**Phase 7**: Documentation and Cleanup (1 hour)

### Recommended Approach

**Week 1**:
- Day 1: Phase 1 (synchronization utilities)
- Day 2: Phase 2 (/todo optimization)
- Day 3: Phase 3 (/review optimization)

**Week 2**:
- Day 1: Phase 4 (/meta optimization)
- Day 2: Phase 5 (/task optimization)
- Day 3: Phase 6 (testing and validation)
- Day 4: Phase 7 (documentation)

## Conclusion

This Phase 2 optimization extends the successful Phase 1 approach to all remaining commands, achieving:

- ✅ **Comprehensive optimization**: All commands use state.json for fast reads
- ✅ **Atomic operations**: Enhanced sync manager ensures consistency
- ✅ **Automated validation**: Detect inconsistencies automatically
- ✅ **Automated repair**: Fix common issues automatically
- ✅ **Better performance**: 3-25x faster operations
- ✅ **Better reliability**: Atomic updates prevent partial failures

The implementation builds on Phase 1's proven success (25-50x improvement) and extends it to the entire command ecosystem.

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

**Related Documents**:
- `.opencode/specs/state-json-optimization-plan.md` (Phase 1 - COMPLETED)
- `.opencode/context/core/system/state-lookup.md` (Phase 1 patterns)
- `.opencode/context/core/system/state-management.md` (State management standard)
- `.opencode/agent/subagents/status-sync-manager.md` (Current sync manager)
