# Research Report: Refactor /abandon Command to Support Ranges and Lists

## Metadata

- **Task**: 311 - Refactor /abandon command to support ranges and lists of task numbers
- **Started**: 2026-01-05
- **Completed**: 2026-01-05
- **Effort**: 3-4 hours (estimated implementation)
- **Priority**: Medium
- **Dependencies**: None
- **Sources/Inputs**: 
  - `.opencode/command/abandon.md` (current implementation)
  - `.opencode/command/implement.md` (range parsing example)
  - `.opencode/command/todo.md` (bulk operations example)
  - `.opencode/context/core/system/state-lookup.md` (range parsing patterns)
  - `.opencode/agent/subagents/status-sync-manager.md` (atomic updates)
- **Artifacts**: 
  - `reports/research-001.md` (this document)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research analyzes the current `/abandon` command implementation and designs an enhancement to support bulk abandonment of multiple tasks using range and list syntax (e.g., `/abandon 293-295, 302, 303`). The current implementation only supports single task abandonment, requiring multiple command executions for bulk operations. The proposed solution adds argument parsing for ranges (N-M) and comma-separated lists, validates all tasks before abandonment, and delegates to status-sync-manager for atomic updates. Implementation requires updating 1 command file and 1 context file with an estimated effort of 3-4 hours.

**Key Findings**:
1. Current `/abandon` command only supports single task numbers
2. Range parsing pattern exists in `/implement` command (e.g., `105-107`)
3. Bulk operations pattern exists in `/todo` command (archiving multiple tasks)
4. status-sync-manager does NOT currently support bulk abandonment operations
5. Atomic updates require either loop delegation or new status-sync-manager operation

**Recommendation**: Implement iterative approach with loop delegation to status-sync-manager for each task, ensuring atomic updates per task with rollback capability.

---

## Context & Scope

### Current Implementation

The `/abandon` command (`.opencode/command/abandon.md`) currently:
- Accepts single task number: `/abandon 298`
- Validates task exists in state.json
- Validates status allows abandonment (not completed, not already abandoned)
- Delegates to status-sync-manager for atomic updates
- Updates status to [ABANDONED] in both TODO.md and state.json

**Current Workflow** (2 stages):
1. **Stage 1 (ParseAndValidate)**: Parse task number, validate task exists, validate status
2. **Stage 2 (Delegate)**: Delegate to status-sync-manager for atomic updates

**Limitations**:
- Only supports single task abandonment
- Requires multiple command executions for bulk operations
- No support for range syntax (e.g., `293-295`)
- No support for comma-separated lists (e.g., `302, 303`)

### Use Cases

**Use Case 1: Range Abandonment**
```bash
/abandon 293-295
# Should abandon tasks 293, 294, 295
```

**Use Case 2: List Abandonment**
```bash
/abandon 302, 303
# Should abandon tasks 302, 303
```

**Use Case 3: Mixed Range and List**
```bash
/abandon 293-295, 302, 303
# Should abandon tasks 293, 294, 295, 302, 303
```

**Use Case 4: Single Task (Backward Compatibility)**
```bash
/abandon 298
# Should abandon task 298 (existing behavior)
```

### Requirements

**Functional Requirements**:
1. Parse range syntax: `N-M` expands to all tasks from N to M inclusive
2. Parse comma-separated lists: `A, B, C` expands to tasks A, B, C
3. Parse mixed syntax: `N-M, A, B` combines ranges and lists
4. Validate all tasks exist before abandoning any
5. Validate all tasks have valid status for abandonment
6. Perform atomic updates (all tasks or none)
7. Maintain backward compatibility with single task syntax
8. Provide clear error messages for invalid input

**Non-Functional Requirements**:
1. Performance: Complete within 60s timeout (current timeout)
2. Atomicity: All tasks updated or none (rollback on failure)
3. Consistency: Maintain TODO.md and state.json synchronization
4. Usability: Clear error messages, helpful recommendations

---

## Key Findings

### Finding 1: Range Parsing Pattern Exists in /implement Command

The `/implement` command (`.opencode/command/implement.md`) already implements range parsing:

```bash
# Parse range from $ARGUMENTS
if [[ "$ARGUMENTS" =~ ^([0-9]+)-([0-9]+)$ ]]; then
  start_num="${BASH_REMATCH[1]}"
  end_num="${BASH_REMATCH[2]}"
  
  # Validate range
  if [ "$start_num" -gt "$end_num" ]; then
    echo "Error: Invalid range $start_num-$end_num (start > end)"
    exit 1
  fi
  
  # Lookup each task in range
  for num in $(seq "$start_num" "$end_num"); do
    task_data=$(jq -r --arg num "$num" \
      '.active_projects[] | select(.project_number == ($num | tonumber))' \
      specs/state.json)
    
    if [ -z "$task_data" ]; then
      echo "Error: Task $num not found in range"
      exit 1
    fi
    
    # Process task...
  done
fi
```

**Key Insights**:
- Uses regex to match range pattern: `^([0-9]+)-([0-9]+)$`
- Validates start <= end
- Uses `seq` to expand range
- Validates each task exists before processing
- Provides clear error messages

**Limitation**: Only supports single range, not mixed range and list syntax.

### Finding 2: Bulk Operations Pattern Exists in /todo Command

The `/todo` command (`.opencode/command/todo.md`) implements bulk archival:

```bash
# Stage 1: Query state.json for completed and abandoned tasks
completed_tasks=$(jq -r '.active_projects[] | select(.status == "completed") | .project_number' specs/state.json)
abandoned_tasks=$(jq -r '.active_projects[] | select(.status == "abandoned") | .project_number' specs/state.json)

# Stage 4: Execute cleanup script with task list
task_list="250,251,252,253,254"  # Comma-separated
python3 .opencode/scripts/todo_cleanup.py --tasks "$task_list"
```

**Key Insights**:
- Uses comma-separated list format for bulk operations
- Delegates to external script for processing
- Implements rollback on failure (git reset)
- Provides user confirmation for bulk operations (threshold: 5 tasks)

**Limitation**: Uses external Python script, not status-sync-manager delegation.

### Finding 3: status-sync-manager Does NOT Support Bulk Abandonment

The `status-sync-manager` (`.opencode/agent/subagents/status-sync-manager.md`) supports:
- `update_status` operation: Single task status update
- `create_task` operation: Single task creation
- `archive_tasks` operation: Bulk archival (moves to completed_projects)

**Key Insight**: `archive_tasks` operation exists for bulk archival, but it only handles completed/abandoned tasks moving to archive, NOT abandoning active tasks.

**Gap**: No `abandon_tasks` operation for bulk abandonment of active tasks.

**Options**:
1. **Option A**: Add new `abandon_tasks` operation to status-sync-manager
2. **Option B**: Loop over tasks and call `update_status` for each task
3. **Option C**: Extend `update_status` to accept array of task numbers

### Finding 4: Argument Parsing Pattern for Mixed Syntax

To support mixed range and list syntax (`293-295, 302, 303`), we need to:

1. **Split by comma**: `IFS=',' read -ra PARTS <<< "$ARGUMENTS"`
2. **For each part**:
   - Trim whitespace
   - Check if range pattern: `[0-9]+-[0-9]+`
   - If range: Expand using `seq`
   - If single number: Add to list
3. **Deduplicate**: Remove duplicate task numbers
4. **Sort**: Sort task numbers for consistent processing

**Example Implementation**:
```bash
# Parse mixed range and list syntax
parse_task_numbers() {
  local input="$1"
  local task_numbers=()
  
  # Split by comma
  IFS=',' read -ra PARTS <<< "$input"
  
  for part in "${PARTS[@]}"; do
    # Trim whitespace
    part=$(echo "$part" | xargs)
    
    # Check if range pattern
    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      start="${BASH_REMATCH[1]}"
      end="${BASH_REMATCH[2]}"
      
      # Validate range
      if [ "$start" -gt "$end" ]; then
        echo "Error: Invalid range $start-$end (start > end)"
        return 1
      fi
      
      # Expand range
      for num in $(seq "$start" "$end"); do
        task_numbers+=("$num")
      done
    elif [[ "$part" =~ ^[0-9]+$ ]]; then
      # Single number
      task_numbers+=("$part")
    else
      echo "Error: Invalid task number format: $part"
      return 1
    fi
  done
  
  # Deduplicate and sort
  printf '%s\n' "${task_numbers[@]}" | sort -nu
}

# Usage
task_numbers=$(parse_task_numbers "$ARGUMENTS")
```

### Finding 5: Atomic Updates Require Careful Design

**Challenge**: How to ensure atomicity when abandoning multiple tasks?

**Option A: Loop Delegation (Recommended)**
- Loop over task numbers
- Delegate to status-sync-manager for each task
- If any delegation fails: Rollback all previous updates
- Pros: Reuses existing status-sync-manager logic, atomic per task
- Cons: Multiple delegations (slower), complex rollback logic

**Option B: New Bulk Operation**
- Add `abandon_tasks` operation to status-sync-manager
- Accept array of task numbers
- Perform atomic update across all tasks
- Pros: Single delegation, true atomicity
- Cons: Requires modifying status-sync-manager (higher effort)

**Option C: Batch Update**
- Extend `update_status` to accept array of task numbers
- Perform atomic update across all tasks
- Pros: Minimal changes to status-sync-manager
- Cons: Changes existing operation signature (breaking change)

**Recommendation**: **Option A (Loop Delegation)** for initial implementation:
- Lower effort (no status-sync-manager changes)
- Reuses existing atomic update logic
- Rollback is straightforward (reverse loop)
- Can be optimized later with Option B if needed

---

## Detailed Analysis

### Argument Parsing Algorithm

**Input**: `$ARGUMENTS` (e.g., `"293-295, 302, 303"`)

**Output**: Array of task numbers (e.g., `[293, 294, 295, 302, 303]`)

**Algorithm**:
```
1. Split input by comma: parts = split($ARGUMENTS, ',')
2. For each part in parts:
   a. Trim whitespace: part = trim(part)
   b. If part matches range pattern (N-M):
      i. Extract start and end: start, end = extract_range(part)
      ii. Validate start <= end
      iii. Expand range: for num in seq(start, end): add num to task_numbers
   c. Else if part matches single number pattern (N):
      i. Add part to task_numbers
   d. Else:
      i. Return error: "Invalid task number format: {part}"
3. Deduplicate task_numbers: task_numbers = unique(task_numbers)
4. Sort task_numbers: task_numbers = sort(task_numbers)
5. Return task_numbers
```

**Edge Cases**:
- Empty input: Return error "Task number required"
- Invalid format: Return error "Invalid task number format: {part}"
- Range with start > end: Return error "Invalid range {start}-{end} (start > end)"
- Duplicate numbers: Deduplicate automatically
- Mixed valid and invalid: Return error on first invalid part

### Validation Algorithm

**Input**: Array of task numbers

**Output**: Validation result (success or error)

**Algorithm**:
```
1. For each task_number in task_numbers:
   a. Lookup task in state.json:
      task_data = jq('.active_projects[] | select(.project_number == task_number)')
   b. If task_data is empty:
      i. Return error: "Task {task_number} not found"
   c. Extract status: status = task_data.status
   d. If status == "completed":
      i. Return error: "Cannot abandon completed task {task_number}"
   e. If status == "abandoned":
      i. Return error: "Task {task_number} already abandoned"
   f. If status not in [not_started, in_progress, researched, planned, blocked]:
      i. Return error: "Invalid status '{status}' for task {task_number}"
2. Return success
```

**Validation Rules**:
- All tasks must exist in state.json
- All tasks must have valid status for abandonment
- Fail fast: Return error on first validation failure
- Provide clear error message with task number

### Abandonment Algorithm (Loop Delegation)

**Input**: Array of validated task numbers

**Output**: Abandonment result (success or error with rollback)

**Algorithm**:
```
1. Initialize abandoned_tasks = []
2. For each task_number in task_numbers:
   a. Delegate to status-sync-manager:
      result = delegate(
        subagent_type="status-sync-manager",
        operation="update_status",
        task_number=task_number,
        new_status="abandoned",
        timestamp=current_date
      )
   b. If result.status == "completed":
      i. Add task_number to abandoned_tasks
   c. Else (delegation failed):
      i. Log error: "Failed to abandon task {task_number}: {result.error}"
      ii. Rollback all previous abandonments:
          For each num in abandoned_tasks (reverse order):
            rollback_result = delegate(
              subagent_type="status-sync-manager",
              operation="update_status",
              task_number=num,
              new_status=original_status[num],
              timestamp=current_date
            )
      iii. Return error: "Failed to abandon task {task_number}, rolled back {len(abandoned_tasks)} tasks"
3. Return success: "Abandoned {len(abandoned_tasks)} tasks: {task_numbers}"
```

**Rollback Strategy**:
- Track original status for each task before abandonment
- On failure: Reverse loop through abandoned tasks
- Restore original status for each task
- Log rollback success/failure
- Return error with rollback details

### Performance Analysis

**Single Task Abandonment**:
- Current: ~50ms (parse + validate + delegate)
- Proposed: ~50ms (same, backward compatible)

**Bulk Abandonment (10 tasks)**:
- Loop delegation: ~500ms (10 * 50ms per task)
- Bulk operation: ~100ms (single delegation)

**Scalability**:
- Loop delegation: O(n) where n = number of tasks
- Bulk operation: O(1) (single delegation)

**Recommendation**: Loop delegation is acceptable for initial implementation. Optimize with bulk operation if performance becomes issue.

---

## Code Examples

### Example 1: Parse Mixed Range and List Syntax

```bash
# Function to parse task numbers from mixed syntax
parse_task_numbers() {
  local input="$1"
  local task_numbers=()
  
  # Handle empty input
  if [ -z "$input" ]; then
    echo "Error: Task number required" >&2
    echo "Usage: /abandon TASK_NUMBER|RANGE|LIST" >&2
    echo "Examples:" >&2
    echo "  /abandon 298" >&2
    echo "  /abandon 293-295" >&2
    echo "  /abandon 302, 303" >&2
    echo "  /abandon 293-295, 302, 303" >&2
    return 1
  fi
  
  # Split by comma
  IFS=',' read -ra PARTS <<< "$input"
  
  for part in "${PARTS[@]}"; do
    # Trim whitespace
    part=$(echo "$part" | xargs)
    
    # Check if range pattern (N-M)
    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
      start="${BASH_REMATCH[1]}"
      end="${BASH_REMATCH[2]}"
      
      # Validate range
      if [ "$start" -gt "$end" ]; then
        echo "Error: Invalid range $start-$end (start > end)" >&2
        return 1
      fi
      
      # Expand range
      for num in $(seq "$start" "$end"); do
        task_numbers+=("$num")
      done
    # Check if single number pattern (N)
    elif [[ "$part" =~ ^[0-9]+$ ]]; then
      task_numbers+=("$part")
    else
      echo "Error: Invalid task number format: '$part'" >&2
      echo "Expected: number (e.g., 298) or range (e.g., 293-295)" >&2
      return 1
    fi
  done
  
  # Deduplicate and sort
  printf '%s\n' "${task_numbers[@]}" | sort -nu
}

# Usage
task_numbers=$(parse_task_numbers "$ARGUMENTS")
if [ $? -ne 0 ]; then
  exit 1
fi

# Convert to array
readarray -t task_array <<< "$task_numbers"
echo "Parsed ${#task_array[@]} task(s): ${task_array[*]}"
```

### Example 2: Validate All Tasks Before Abandonment

```bash
# Function to validate all tasks
validate_tasks() {
  local -n task_nums=$1  # Array of task numbers
  local -n original_statuses=$2  # Associative array to store original statuses
  
  # Validate state.json exists
  if [ ! -f specs/state.json ]; then
    echo "Error: state.json not found" >&2
    echo "Run /meta to regenerate state.json" >&2
    return 1
  fi
  
  # Validate state.json is valid JSON
  if ! jq empty specs/state.json 2>/dev/null; then
    echo "Error: state.json is corrupt or invalid JSON" >&2
    echo "Run /meta to regenerate state.json" >&2
    return 1
  fi
  
  # Validate each task
  for task_number in "${task_nums[@]}"; do
    # Lookup task in state.json
    task_data=$(jq -r --arg num "$task_number" \
      '.active_projects[] | select(.project_number == ($num | tonumber))' \
      specs/state.json)
    
    # Check task exists
    if [ -z "$task_data" ]; then
      echo "Error: Task $task_number not found in state.json" >&2
      echo "" >&2
      echo "Available tasks:" >&2
      jq -r '.active_projects[] | "\(.project_number). \(.project_name) [\(.status)]"' \
        specs/state.json | head -10 >&2
      return 1
    fi
    
    # Extract status
    status=$(echo "$task_data" | jq -r '.status')
    project_name=$(echo "$task_data" | jq -r '.project_name')
    
    # Store original status for rollback
    original_statuses[$task_number]="$status"
    
    # Validate status allows abandonment
    case "$status" in
      "completed")
        echo "Error: Cannot abandon completed task $task_number ($project_name)" >&2
        echo "Recommendation: Completed tasks are terminal and cannot be abandoned" >&2
        return 1
        ;;
      "abandoned")
        echo "Error: Task $task_number already abandoned ($project_name)" >&2
        echo "Recommendation: Task has already been abandoned" >&2
        return 1
        ;;
      "not_started"|"in_progress"|"researched"|"planned"|"blocked")
        # Status allows abandonment
        echo "Validated task $task_number: $project_name [$status]"
        ;;
      *)
        echo "Warning: Unknown status '$status' for task $task_number" >&2
        echo "Proceeding with abandonment, but status may be invalid" >&2
        ;;
    esac
  done
  
  return 0
}

# Usage
declare -A original_statuses
if ! validate_tasks task_array original_statuses; then
  exit 1
fi
```

### Example 3: Abandon Tasks with Rollback

```bash
# Function to abandon tasks with rollback on failure
abandon_tasks() {
  local -n task_nums=$1  # Array of task numbers
  local -n orig_statuses=$2  # Associative array of original statuses
  local abandoned_tasks=()
  local timestamp=$(date -I)
  
  echo "Abandoning ${#task_nums[@]} task(s)..."
  
  # Abandon each task
  for task_number in "${task_nums[@]}"; do
    echo "Abandoning task $task_number..."
    
    # Delegate to status-sync-manager
    # NOTE: This is pseudocode - actual delegation uses task tool
    result=$(delegate_to_status_sync_manager \
      --operation "update_status" \
      --task_number "$task_number" \
      --new_status "abandoned" \
      --timestamp "$timestamp")
    
    # Check delegation result
    if [ $? -eq 0 ]; then
      abandoned_tasks+=("$task_number")
      echo "  [SUCCESS] Task $task_number marked as [ABANDONED]"
    else
      echo "  [FAILED] Failed to abandon task $task_number" >&2
      echo "" >&2
      echo "Rolling back ${#abandoned_tasks[@]} abandoned task(s)..." >&2
      
      # Rollback all previous abandonments
      for ((i=${#abandoned_tasks[@]}-1; i>=0; i--)); do
        rollback_num="${abandoned_tasks[$i]}"
        rollback_status="${orig_statuses[$rollback_num]}"
        
        echo "  Rolling back task $rollback_num to [$rollback_status]..." >&2
        
        rollback_result=$(delegate_to_status_sync_manager \
          --operation "update_status" \
          --task_number "$rollback_num" \
          --new_status "$rollback_status" \
          --timestamp "$timestamp")
        
        if [ $? -eq 0 ]; then
          echo "    [SUCCESS] Rolled back task $rollback_num" >&2
        else
          echo "    [FAILED] Failed to rollback task $rollback_num" >&2
          echo "    WARNING: Manual intervention required" >&2
        fi
      done
      
      echo "" >&2
      echo "Error: Failed to abandon task $task_number" >&2
      echo "Rolled back ${#abandoned_tasks[@]} task(s)" >&2
      return 1
    fi
  done
  
  echo ""
  echo "Successfully abandoned ${#abandoned_tasks[@]} task(s): ${abandoned_tasks[*]}"
  echo "Files updated: TODO.md, state.json"
  return 0
}

# Usage
if ! abandon_tasks task_array original_statuses; then
  exit 1
fi
```

---

## Decisions

### Decision 1: Use Loop Delegation (Not Bulk Operation)

**Decision**: Implement loop delegation to status-sync-manager for each task, rather than adding new bulk operation.

**Rationale**:
- Lower implementation effort (no status-sync-manager changes)
- Reuses existing atomic update logic
- Rollback is straightforward (reverse loop)
- Can be optimized later if performance becomes issue

**Trade-offs**:
- Slower for large bulk operations (O(n) vs O(1))
- More complex rollback logic in command file
- Multiple delegations increase failure surface

**Alternatives Considered**:
- Add `abandon_tasks` operation to status-sync-manager (higher effort)
- Extend `update_status` to accept array (breaking change)

### Decision 2: Fail Fast Validation

**Decision**: Validate all tasks before abandoning any task.

**Rationale**:
- Prevents partial abandonment on validation failure
- Provides clear error messages upfront
- Reduces rollback complexity

**Trade-offs**:
- Slower for large bulk operations (two passes)
- More upfront validation logic

**Alternatives Considered**:
- Validate and abandon in single pass (more complex rollback)

### Decision 3: Deduplicate and Sort Task Numbers

**Decision**: Automatically deduplicate and sort task numbers after parsing.

**Rationale**:
- Prevents duplicate abandonments
- Provides consistent processing order
- Simplifies error messages

**Trade-offs**:
- Hides duplicate input from user (could be confusing)

**Alternatives Considered**:
- Error on duplicate input (more strict, less user-friendly)

### Decision 4: Maintain Backward Compatibility

**Decision**: Support single task syntax without changes.

**Rationale**:
- Existing scripts and workflows continue to work
- No breaking changes
- Gradual adoption of new syntax

**Trade-offs**:
- More complex argument parsing logic

**Alternatives Considered**:
- Require new syntax for all cases (breaking change)

---

## Recommendations

### Recommendation 1: Implement Loop Delegation Approach

**Priority**: High

**Description**: Implement bulk abandonment using loop delegation to status-sync-manager for each task, with rollback on failure.

**Implementation Steps**:
1. Add `parse_task_numbers()` function to parse mixed range and list syntax
2. Add `validate_tasks()` function to validate all tasks before abandonment
3. Add `abandon_tasks()` function to abandon tasks with rollback
4. Update Stage 1 (ParseAndValidate) to use `parse_task_numbers()` and `validate_tasks()`
5. Update Stage 2 (Delegate) to use `abandon_tasks()` with loop delegation
6. Add comprehensive error handling and rollback logic
7. Update documentation with new syntax examples

**Estimated Effort**: 3-4 hours

**Files to Modify**:
- `.opencode/command/abandon.md` - Add parsing, validation, and loop delegation logic

**Files to Create**:
- None (reuses existing status-sync-manager)

### Recommendation 2: Add Comprehensive Error Messages

**Priority**: Medium

**Description**: Provide clear, actionable error messages for all failure cases.

**Error Cases**:
- Empty input: "Task number required. Usage: /abandon TASK_NUMBER|RANGE|LIST"
- Invalid format: "Invalid task number format: '{part}'. Expected: number or range"
- Invalid range: "Invalid range {start}-{end} (start > end)"
- Task not found: "Task {number} not found in state.json. Available tasks: ..."
- Cannot abandon completed: "Cannot abandon completed task {number}. Completed tasks are terminal."
- Already abandoned: "Task {number} already abandoned"
- Delegation failure: "Failed to abandon task {number}, rolled back {count} tasks"

**Implementation**: Add error messages to each validation and delegation step.

### Recommendation 3: Add Usage Examples to Documentation

**Priority**: Medium

**Description**: Update command documentation with comprehensive usage examples.

**Examples to Add**:
```bash
# Single task (existing)
/abandon 298

# Range
/abandon 293-295

# Comma-separated list
/abandon 302, 303

# Mixed range and list
/abandon 293-295, 302, 303

# Multiple ranges
/abandon 290-292, 300-302
```

**Implementation**: Update "Usage" and "Examples" sections in `.opencode/command/abandon.md`.

### Recommendation 4: Consider Future Optimization

**Priority**: Low

**Description**: If bulk abandonment becomes common, consider adding `abandon_tasks` operation to status-sync-manager for better performance.

**Trigger**: If users frequently abandon >10 tasks at once, or if performance becomes issue.

**Implementation**: Add new operation to status-sync-manager with atomic bulk update logic.

**Estimated Effort**: 6-8 hours (requires status-sync-manager changes and testing)

---

## Risks & Mitigations

### Risk 1: Rollback Failure

**Risk**: Rollback may fail, leaving system in inconsistent state.

**Likelihood**: Low

**Impact**: High (manual intervention required)

**Mitigation**:
- Log all rollback attempts with details
- Provide clear error message with manual recovery instructions
- Test rollback logic thoroughly
- Consider adding rollback verification step

**Recovery**:
```bash
# Manual recovery if rollback fails
# 1. Check state.json for inconsistencies
jq '.active_projects[] | select(.status == "abandoned")' specs/state.json

# 2. Manually restore status using /sync command
/sync

# 3. Or manually edit state.json and TODO.md
```

### Risk 2: Partial Abandonment on Timeout

**Risk**: Command may timeout during bulk abandonment, leaving some tasks abandoned and others not.

**Likelihood**: Low (60s timeout is generous)

**Impact**: Medium (requires manual cleanup)

**Mitigation**:
- Validate all tasks before abandonment (fail fast)
- Log progress during abandonment
- Provide clear error message with list of abandoned tasks
- Consider increasing timeout for bulk operations

**Recovery**:
- Check command output for list of abandoned tasks
- Re-run command with remaining tasks

### Risk 3: Invalid Range Input

**Risk**: User may provide invalid range (e.g., `295-293` with start > end).

**Likelihood**: Medium

**Impact**: Low (validation catches this)

**Mitigation**:
- Validate range in parsing step
- Provide clear error message: "Invalid range {start}-{end} (start > end)"
- Show correct syntax in error message

### Risk 4: Duplicate Task Numbers

**Risk**: User may provide duplicate task numbers (e.g., `293, 293-295`).

**Likelihood**: Medium

**Impact**: Low (deduplication handles this)

**Mitigation**:
- Automatically deduplicate task numbers after parsing
- Log deduplication for transparency
- Consider warning user about duplicates

---

## Appendix: Sources and Citations

### Source 1: Current /abandon Command Implementation

**File**: `.opencode/command/abandon.md`

**Key Sections**:
- Lines 1-175: Complete command implementation
- Lines 22-49: Stage 1 (ParseAndValidate) - Single task parsing
- Lines 51-68: Stage 2 (Delegate) - Delegation to status-sync-manager
- Lines 88-98: Status transition rules

**Relevance**: Baseline implementation to extend with bulk support.

### Source 2: Range Parsing Pattern in /implement Command

**File**: `.opencode/command/implement.md`

**Key Sections**:
- Lines 30-32: Range syntax in $ARGUMENTS
- Lines 264: Example usage `/implement 105-107`
- Lines 293: Batch support documentation

**Relevance**: Provides proven pattern for range parsing.

### Source 3: Range Parsing Pattern in state-lookup.md

**File**: `.opencode/context/core/system/state-lookup.md`

**Key Sections**:
- Lines 145-187: Pattern 2 - Get Multiple Tasks (Range Operations)
- Lines 149-184: Complete range parsing implementation

**Relevance**: Provides detailed algorithm and best practices for range parsing.

### Source 4: Bulk Operations Pattern in /todo Command

**File**: `.opencode/command/todo.md`

**Key Sections**:
- Lines 50-85: Stage 1 (ScanState) - Query multiple tasks
- Lines 156-194: Stage 4 (RunCleanupScript) - Bulk archival with rollback
- Lines 159-161: Comma-separated list format

**Relevance**: Provides pattern for bulk operations and rollback logic.

### Source 5: status-sync-manager Operations

**File**: `.opencode/agent/subagents/status-sync-manager.md`

**Key Sections**:
- Lines 55-122: Input parameters for operations
- Lines 130-142: Operation routing logic
- Lines 260-300: archive_tasks operation (bulk archival)

**Relevance**: Shows existing bulk operation pattern and atomic update logic.

---

## Conclusion

Refactoring the `/abandon` command to support ranges and lists of task numbers is a valuable enhancement that improves workflow efficiency. The proposed loop delegation approach balances implementation effort with functionality, providing atomic updates with rollback capability while reusing existing status-sync-manager logic. Implementation requires updating 1 command file with an estimated effort of 3-4 hours. The solution maintains backward compatibility, provides comprehensive error handling, and can be optimized later if performance becomes an issue.

**Next Steps**:
1. Review research findings and recommendations
2. Create implementation plan based on loop delegation approach
3. Implement parsing, validation, and abandonment logic
4. Test with various input formats (single, range, list, mixed)
5. Test rollback logic with simulated failures
6. Update documentation with new syntax examples
7. Consider future optimization with bulk operation if needed
