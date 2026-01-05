# Research Report: /sync Command for Bidirectional TODO.md and state.json Synchronization

**Task**: 296 - Create /sync command for bidirectional TODO.md and state.json synchronization  
**Started**: 2026-01-05  
**Completed**: 2026-01-05  
**Effort**: 6-8 hours  
**Priority**: Medium  
**Dependencies**: None  
**Sources/Inputs**: status-sync-manager.md, state-management.md, TODO.md, state.json, command patterns  
**Artifacts**: research-001.md  
**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research investigates the requirements for creating a `/sync` command that bidirectionally synchronizes `.opencode/specs/TODO.md` and `.opencode/specs/state.json`. The investigation reveals that the current architecture has a **critical structural issue**: state.json is malformed and contains only a single project object instead of the expected `active_projects` array structure. This malformation prevents proper metadata lookups and violates the architectural principle that state.json should be the authoritative source for task metadata.

**Key Findings**:
1. **Current state.json is malformed**: Contains single project (297) instead of `active_projects` array with all tasks
2. **TODO.md has YAML header**: Auto-generated from state.json with repository health metrics
3. **status-sync-manager provides atomic updates**: Two-phase commit protocol for consistency
4. **Architectural intent is clear**: state.json should be authoritative, TODO.md is user-facing view
5. **Sync direction should be unidirectional**: state.json → TODO.md (not bidirectional)
6. **File modification timestamps available**: Can detect which file was updated more recently

**Recommendations**:
1. **Fix state.json structure first**: Regenerate state.json with proper `active_projects` array before implementing /sync
2. **Implement unidirectional sync**: state.json → TODO.md (state.json is authoritative)
3. **Leverage status-sync-manager**: Use existing two-phase commit for atomic updates
4. **Add validation mode**: Detect discrepancies and report without modifying files
5. **Support manual conflict resolution**: When TODO.md has newer manual edits, prompt user for resolution

---

## Context & Scope

### Research Objectives

1. Understand current synchronization mechanisms between TODO.md and state.json
2. Analyze status-sync-manager's two-phase commit protocol
3. Identify conflict resolution strategies for bidirectional sync
4. Determine file modification timestamp detection methods
5. Study similar command patterns in the codebase
6. Identify edge cases and error handling requirements
7. Document atomic update patterns and rollback mechanisms

### Architectural Context

The ProofChecker .opencode system uses a dual-file approach for task tracking:

- **state.json**: Authoritative source for metadata reads (structured, fast, reliable)
- **TODO.md**: User-facing task list (markdown, human-readable, manually editable)

The architectural intent is that state.json is the **single source of truth** for programmatic access, while TODO.md is kept synchronized as a user-facing view. However, the current implementation has diverged from this design.

---

## Key Findings

### Finding 1: Current state.json Structure is Malformed

**Evidence**:
```bash
$ cat .opencode/specs/state.json
{
  "project_number": 297,
  "project_name": "simplify_task_command_to_directly_create_tasks_without_subagent_delegation",
  "type": "refactoring",
  "phase": "not_started",
  "status": "researching",
  "priority": "high",
  "language": "markdown",
  "description": "...",
  "created": "2026-01-05T08:04:58Z",
  "last_updated": "2026-01-05T08:04:58Z"
}
```

**Expected Structure** (from state-management.md):
```json
{
  "_schema_version": "1.1.0",
  "_last_updated": "2025-12-29T09:00:00Z",
  "next_project_number": 303,
  "project_numbering": {
    "min": 0,
    "max": 999,
    "policy": "increment_modulo_1000"
  },
  "active_projects": [
    {
      "project_number": 296,
      "project_name": "sync_command",
      "type": "feature",
      "phase": "not_started",
      "status": "not_started",
      "priority": "medium",
      "language": "meta",
      "description": "...",
      "created": "2026-01-05T00:00:00Z",
      "last_updated": "2026-01-05T00:00:00Z"
    },
    {
      "project_number": 297,
      "project_name": "simplify_task_command",
      "type": "refactoring",
      "phase": "not_started",
      "status": "researching",
      "priority": "high",
      "language": "markdown",
      "description": "...",
      "created": "2026-01-05T08:04:58Z",
      "last_updated": "2026-01-05T08:04:58Z"
    }
  ],
  "completed_projects": [],
  "repository_health": {
    "last_assessed": "2026-01-05",
    "overall_score": 92,
    "active_tasks": 11,
    "technical_debt": {
      "sorry_count": 6,
      "axiom_count": 11
    }
  }
}
```

**Impact**:
- Current structure prevents fast task lookups via jq queries
- Commands cannot extract metadata from state.json as designed
- Violates architectural principle that state.json is authoritative
- Explains why task 279 identified widespread use of TODO.md for metadata extraction

**Root Cause**:
The state.json file appears to have been overwritten with a single project object instead of maintaining the full state structure with `active_projects` array.

**Resolution Required**:
Before implementing /sync command, state.json must be regenerated with proper structure. This likely requires:
1. Parsing all tasks from TODO.md
2. Extracting metadata for each task
3. Reconstructing `active_projects` array
4. Adding repository health metadata
5. Setting next_project_number correctly

### Finding 2: TODO.md Has Auto-Generated YAML Header

**Evidence**:
```markdown
---
last_updated: 2026-01-05T00:00:00Z
next_project_number: 303
repository_health:
  overall_score: 92
  production_readiness: excellent
  last_assessed: 2026-01-04T06:25:00Z
task_counts:
  active: 11
  completed: 50
  blocked: 2
  in_progress: 2
  not_started: 30
  total: 88
priority_distribution:
  high: 20
  medium: 12
  low: 11
technical_debt:
  sorry_count: 6
  axiom_count: 11
  build_errors: 11
  status: well-documented
---

# TODO
```

**Analysis**:
- YAML header surfaces repository health and task metrics
- Metadata should be auto-generated from state.json
- Provides quick overview without parsing entire file
- Follows standard YAML frontmatter format

**Sync Implications**:
- YAML header should be regenerated from state.json during sync
- Manual edits to YAML header should be overwritten (not authoritative)
- Provides validation checkpoint (task_counts should match active_projects length)

### Finding 3: status-sync-manager Provides Atomic Updates

**Source**: `.opencode/agent/subagents/status-sync-manager.md`

**Two-Phase Commit Protocol**:

**Phase 1 (Prepare)**:
1. Read all target files into memory (TODO.md, state.json, plan files)
2. Validate current status allows requested transition
3. Prepare all updates in memory
4. Validate all updates are well-formed
5. If any validation fails, abort (no files written)

**Phase 2 (Commit)**:
1. Write files in dependency order: TODO.md → state.json → plan
2. Verify each write before proceeding
3. On any write failure, rollback all previous writes
4. All files updated or none updated (atomic guarantee)

**Rollback Mechanism**:
```
If any file write fails during commit:
1. Immediately stop further writes
2. Restore all previously written files from backup
3. Return error with details of which file failed
4. System remains in consistent state
```

**Key Operations**:
- `update_status`: Update task status across all files
- `create_task`: Create new task in TODO.md and state.json
- `archive_tasks`: Move completed tasks to archive

**Sync Command Integration**:
The /sync command should leverage status-sync-manager's atomic update mechanism rather than implementing its own synchronization logic. This ensures:
- Consistency with existing update patterns
- Rollback support on failures
- Validation of status transitions
- Artifact validation before linking

### Finding 4: Architectural Intent is Clear - state.json is Authoritative

**Evidence from state-management.md**:

```markdown
## State Lookup Patterns

### Read/Write Separation

**Design Principle**: Use state.json for reads, status-sync-manager for writes

- **Read operations** (task lookup, validation, metadata extraction): Use state.json
- **Write operations** (status updates, artifact links): Use status-sync-manager
- **Synchronization**: Handled automatically by status-sync-manager
```

**Fast Task Lookup Pattern**:
```bash
# Lookup task in state.json (8x faster than TODO.md parsing)
task_data=$(jq -r --arg num "$task_number" \
  '.active_projects[] | select(.project_number == ($num | tonumber))' \
  .opencode/specs/state.json)

# Extract all metadata at once
language=$(echo "$task_data" | jq -r '.language // "general"')
status=$(echo "$task_data" | jq -r '.status')
project_name=$(echo "$task_data" | jq -r '.project_name')
description=$(echo "$task_data" | jq -r '.description // ""')
priority=$(echo "$task_data" | jq -r '.priority')
```

**Performance**: ~12ms for state.json lookup vs ~100ms for TODO.md parsing (8x faster)

**Why state.json for Reads?**
- ✅ **Fast**: JSON parsing is 8x faster than markdown parsing
- ✅ **Structured**: Direct field access with jq (no grep/sed needed)
- ✅ **Reliable**: Structured data is more reliable than text parsing
- ✅ **Synchronized**: status-sync-manager keeps state.json and TODO.md in sync

**Sync Direction Implication**:
The architectural intent is **unidirectional sync**: state.json → TODO.md

- state.json is the authoritative source
- TODO.md is the user-facing view
- Synchronization ensures TODO.md reflects state.json
- Manual edits to TODO.md should be discouraged (or trigger validation warnings)

**Bidirectional Sync Concerns**:
The task description requests "bidirectional synchronization," but this conflicts with the architectural principle that state.json is authoritative. Bidirectional sync would require:
1. Detecting which file was modified more recently
2. Resolving conflicts when both files have changes
3. Parsing TODO.md to extract structured metadata (slow, error-prone)
4. Potentially overwriting authoritative state.json with manual TODO.md edits

**Recommendation**: Implement **unidirectional sync** (state.json → TODO.md) with **validation mode** that detects TODO.md manual edits and prompts user to either:
- Accept state.json as authoritative (overwrite TODO.md)
- Manually update state.json to match TODO.md edits
- Abort sync and resolve conflicts manually

### Finding 5: File Modification Timestamp Detection

**Methods Available**:

**1. stat command** (Linux):
```bash
# Get modification timestamp (seconds since epoch)
stat -c "%Y %n" .opencode/specs/TODO.md .opencode/specs/state.json

# Output:
# 1767602026 .opencode/specs/TODO.md
# 1767602243 .opencode/specs/state.json
```

**2. stat command** (macOS):
```bash
# Get modification timestamp (seconds since epoch)
stat -f "%m %N" .opencode/specs/TODO.md .opencode/specs/state.json
```

**3. ls command** (portable):
```bash
# Get modification time (human-readable)
ls -l --time-style=+%s .opencode/specs/TODO.md .opencode/specs/state.json
```

**4. git log** (if files are tracked):
```bash
# Get last commit timestamp for file
git log -1 --format="%ct" -- .opencode/specs/TODO.md
git log -1 --format="%ct" -- .opencode/specs/state.json
```

**Comparison Logic**:
```bash
todo_mtime=$(stat -c "%Y" .opencode/specs/TODO.md)
state_mtime=$(stat -c "%Y" .opencode/specs/state.json)

if [ "$todo_mtime" -gt "$state_mtime" ]; then
  echo "TODO.md is newer (modified after state.json)"
  most_recent="TODO.md"
elif [ "$state_mtime" -gt "$todo_mtime" ]; then
  echo "state.json is newer (modified after TODO.md)"
  most_recent="state.json"
else
  echo "Files have same modification time (in sync)"
  most_recent="none"
fi
```

**Limitations**:
- Modification time can be manipulated (touch command)
- Does not detect which specific fields were modified
- Cannot determine if changes are conflicting or complementary
- Git commit timestamps are more reliable but require git history

**Recommendation**:
Use stat modification times for initial detection, but implement **content-based comparison** to detect actual discrepancies:
1. Parse both files
2. Compare task metadata field-by-field
3. Identify specific discrepancies (status, priority, description, etc.)
4. Report discrepancies with modification timestamps
5. Prompt user for resolution strategy

### Finding 6: Similar Command Patterns in Codebase

**Examined Commands**:
- `/research` - Language-based routing, state.json lookup, status updates
- `/plan` - Similar pattern to /research
- `/implement` - Task execution with phase tracking
- `/abandon` - Status update with reason
- `/task` - Task creation with atomic updates
- `/meta` - System-wide operations

**Common Pattern** (from `/research` command):

```markdown
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse task number and lookup in state.json</action>
    <process>
      1. Parse task number from $ARGUMENTS
      2. Validate state.json exists and is valid
      3. Lookup task in state.json
      4. Extract all metadata at once
      5. Validate task status allows operation
      6. Determine target agent based on language
    </process>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to specialized agent</action>
    <process>
      1. Invoke target agent via task tool
      2. Wait for agent to complete
      3. Relay result to user
    </process>
  </stage>
</workflow_execution>
```

**Key Characteristics**:
- Commands are thin wrappers that delegate to subagents
- Validation happens in Stage 1 (ParseAndValidate)
- Delegation happens in Stage 2
- Commands do not implement business logic directly
- All state updates go through status-sync-manager

**Sync Command Pattern**:

The /sync command should follow this pattern:

```markdown
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse arguments and validate files</action>
    <process>
      1. Parse optional flags (--dry-run, --force, --direction)
      2. Validate TODO.md exists and is readable
      3. Validate state.json exists and is valid JSON
      4. Check file modification timestamps
      5. Determine sync direction (state.json → TODO.md by default)
    </process>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to sync-manager subagent</action>
    <process>
      1. Invoke sync-manager with:
         - sync_direction (unidirectional or bidirectional)
         - conflict_resolution (prefer_state, prefer_todo, prompt)
         - dry_run (boolean)
      2. Wait for sync-manager to complete
      3. Relay result to user
    </process>
  </stage>
</workflow_execution>
```

**Subagent Delegation**:
The actual sync logic should be implemented in a new `sync-manager.md` subagent (or extend status-sync-manager) to:
- Keep command file thin
- Protect orchestrator context window
- Enable reuse by other commands
- Follow established architectural patterns

### Finding 7: Edge Cases and Error Handling Requirements

**Edge Case 1: state.json Malformed**
- **Scenario**: state.json is not valid JSON or missing required fields
- **Detection**: jq validation fails
- **Handling**: Abort sync, prompt user to run /meta to regenerate state.json
- **Recovery**: Regenerate state.json from TODO.md

**Edge Case 2: TODO.md Missing YAML Header**
- **Scenario**: TODO.md lacks YAML frontmatter
- **Detection**: File does not start with `---`
- **Handling**: Generate YAML header from state.json, prepend to TODO.md
- **Recovery**: Automatic (sync adds missing header)

**Edge Case 3: Task in TODO.md but Not in state.json**
- **Scenario**: Manual task added to TODO.md without updating state.json
- **Detection**: Parse TODO.md, compare task numbers with state.json active_projects
- **Handling**: Prompt user to either:
  - Add task to state.json (extract metadata from TODO.md)
  - Remove task from TODO.md (treat as invalid)
- **Recovery**: Manual resolution required

**Edge Case 4: Task in state.json but Not in TODO.md**
- **Scenario**: Task removed from TODO.md manually but still in state.json
- **Detection**: Compare state.json active_projects with TODO.md task numbers
- **Handling**: Prompt user to either:
  - Add task back to TODO.md (regenerate from state.json)
  - Remove task from state.json (mark as abandoned or archived)
- **Recovery**: Manual resolution required

**Edge Case 5: Conflicting Metadata**
- **Scenario**: Task 296 has status [NOT STARTED] in TODO.md but "researching" in state.json
- **Detection**: Field-by-field comparison of task metadata
- **Handling**: Determine which file is more recent:
  - If state.json newer: Update TODO.md to match state.json
  - If TODO.md newer: Prompt user (state.json is authoritative)
- **Recovery**: Prefer state.json unless user explicitly overrides

**Edge Case 6: Both Files Modified Simultaneously**
- **Scenario**: TODO.md and state.json have same modification timestamp but different content
- **Detection**: Modification times equal but content differs
- **Handling**: Cannot determine which is authoritative, prompt user
- **Recovery**: Manual resolution required

**Edge Case 7: File Permissions**
- **Scenario**: TODO.md or state.json is read-only
- **Detection**: Write permission check fails
- **Handling**: Abort sync with clear error message
- **Recovery**: User must fix file permissions

**Edge Case 8: Concurrent Modifications**
- **Scenario**: Another process modifies files during sync
- **Detection**: File modification time changes between read and write
- **Handling**: Abort sync, report concurrent modification detected
- **Recovery**: Retry sync

**Edge Case 9: Partial Sync Failure**
- **Scenario**: TODO.md updated successfully but state.json write fails
- **Detection**: Write operation fails during commit phase
- **Handling**: Rollback TODO.md to original state (two-phase commit)
- **Recovery**: Automatic rollback via status-sync-manager

**Edge Case 10: Invalid Status Transitions**
- **Scenario**: TODO.md shows [COMPLETED] → [IN PROGRESS] (invalid)
- **Detection**: Validate status transition per status-markers.md
- **Handling**: Reject sync, report invalid transition
- **Recovery**: User must fix invalid status manually

**Error Handling Principles**:
1. **Fail fast**: Detect errors early in validation phase
2. **Clear messages**: Explain what went wrong and how to fix it
3. **Atomic updates**: Use two-phase commit to prevent partial updates
4. **Rollback support**: Restore original state on failures
5. **Dry-run mode**: Allow validation without modifying files
6. **Logging**: Record all sync operations for debugging

### Finding 8: Atomic Update Patterns and Rollback Mechanisms

**status-sync-manager Two-Phase Commit** (detailed analysis):

**Backup Strategy**:
```bash
# Phase 1: Create backups before any writes
todo_backup=$(cat .opencode/specs/TODO.md)
state_backup=$(cat .opencode/specs/state.json)
```

**Validation Before Commit**:
```bash
# Validate all updates in memory before writing
validate_todo_syntax "$updated_todo"
validate_state_json "$updated_state"
validate_status_transitions "$old_status" "$new_status"
validate_artifacts_exist "$artifact_paths"
```

**Write Order** (dependency-based):
```bash
# 1. Write TODO.md first (most critical, user-facing)
echo "$updated_todo" > .opencode/specs/TODO.md
verify_write_success || rollback_and_abort

# 2. Write state.json second
echo "$updated_state" > .opencode/specs/state.json
verify_write_success || rollback_and_abort

# 3. Write plan files last (if applicable)
echo "$updated_plan" > "$plan_path"
verify_write_success || rollback_and_abort
```

**Rollback Implementation**:
```bash
rollback_and_abort() {
  echo "Write failed, rolling back all changes..."
  
  # Restore TODO.md from backup
  echo "$todo_backup" > .opencode/specs/TODO.md
  
  # Restore state.json from backup
  echo "$state_backup" > .opencode/specs/state.json
  
  # Restore plan file from backup (if applicable)
  [ -n "$plan_backup" ] && echo "$plan_backup" > "$plan_path"
  
  # Verify rollback succeeded
  verify_rollback_success || log_critical_error
  
  # Return failed status
  return 1
}
```

**Post-Commit Validation**:
```bash
# Verify files written successfully
[ -f .opencode/specs/TODO.md ] || log_error "TODO.md missing after write"
[ -f .opencode/specs/state.json ] || log_error "state.json missing after write"
[ -s .opencode/specs/TODO.md ] || log_error "TODO.md empty after write"
[ -s .opencode/specs/state.json ] || log_error "state.json empty after write"
```

**Sync Command Rollback Requirements**:

The /sync command must implement similar rollback mechanisms:

1. **Backup both files before any modifications**
2. **Validate all updates in memory** (parse TODO.md, validate state.json)
3. **Write in dependency order** (TODO.md first, then state.json)
4. **Verify each write** before proceeding to next file
5. **Rollback on any failure** (restore both files from backups)
6. **Post-commit validation** (verify files exist, non-empty, valid syntax)

**Leveraging status-sync-manager**:

Rather than reimplementing rollback logic, the /sync command should delegate to status-sync-manager:

```bash
# Invoke status-sync-manager with full task list
status-sync-manager \
  --operation "sync_from_state" \
  --source "state.json" \
  --target "TODO.md" \
  --dry-run false \
  --session-id "$session_id"
```

This ensures:
- Consistent rollback behavior across all commands
- Reuse of tested atomic update logic
- Proper validation and error handling
- Git commit integration (via git-workflow-manager)

---

## Detailed Analysis

### Current Synchronization Mechanisms

**Existing Sync Points**:

1. **Task Creation** (`/task` command):
   - Creates task in both TODO.md and state.json atomically
   - Uses status-sync-manager for atomic updates
   - Increments next_project_number in state.json
   - Adds task to appropriate priority section in TODO.md

2. **Status Updates** (all workflow commands):
   - Updates status in both TODO.md and state.json
   - Uses status-sync-manager for atomic updates
   - Preserves timestamp history
   - Validates status transitions

3. **Artifact Linking** (`/research`, `/plan`, `/implement`):
   - Adds artifact links to TODO.md
   - Adds artifact references to state.json
   - Validates artifacts exist before linking
   - Uses status-sync-manager for atomic updates

4. **Task Archival** (`/todo` command):
   - Removes tasks from TODO.md
   - Moves tasks from active_projects to completed_projects in state.json
   - Uses status-sync-manager for atomic updates

**Synchronization Gaps**:

1. **No validation of existing sync**:
   - No command to detect discrepancies between TODO.md and state.json
   - No automated repair of desynchronized state
   - Manual edits to TODO.md can cause drift

2. **No recovery from malformed state.json**:
   - If state.json becomes corrupted, no automated recovery
   - Must manually regenerate from TODO.md (error-prone)

3. **No detection of manual TODO.md edits**:
   - Users can manually edit TODO.md without updating state.json
   - No warning or validation of manual changes
   - Can lead to inconsistent state

**Sync Command Value**:

The /sync command addresses these gaps by:
1. **Detecting discrepancies** between TODO.md and state.json
2. **Validating consistency** of task metadata across both files
3. **Repairing desynchronized state** using authoritative source (state.json)
4. **Regenerating state.json** from TODO.md when state.json is malformed
5. **Warning about manual edits** to TODO.md that conflict with state.json

### Conflict Resolution Strategies

**Strategy 1: Prefer state.json (Recommended)**

**Rationale**: state.json is the authoritative source per architectural design

**Algorithm**:
```
1. Parse state.json active_projects array
2. For each project in active_projects:
   a. Find corresponding task in TODO.md
   b. Compare metadata (status, priority, language, description, etc.)
   c. If mismatch detected:
      - Log discrepancy
      - Update TODO.md to match state.json
   d. If task missing from TODO.md:
      - Log missing task
      - Add task to TODO.md in correct priority section
3. For each task in TODO.md:
   a. Check if task exists in state.json active_projects
   b. If task not in state.json:
      - Log orphaned task
      - Prompt user to either add to state.json or remove from TODO.md
4. Regenerate TODO.md YAML header from state.json metadata
5. Write updated TODO.md atomically
```

**Pros**:
- Consistent with architectural design
- Fast (no TODO.md parsing for metadata)
- Reliable (structured data)
- Predictable behavior

**Cons**:
- Overwrites manual TODO.md edits
- May lose user-added formatting or notes
- Requires state.json to be correct

**Strategy 2: Prefer TODO.md (Not Recommended)**

**Rationale**: TODO.md is user-facing and may have manual edits

**Algorithm**:
```
1. Parse TODO.md to extract all tasks
2. For each task in TODO.md:
   a. Extract metadata (status, priority, language, description)
   b. Find corresponding project in state.json active_projects
   c. If mismatch detected:
      - Log discrepancy
      - Update state.json to match TODO.md
   d. If project missing from state.json:
      - Log missing project
      - Add project to state.json active_projects
3. For each project in state.json:
   a. Check if task exists in TODO.md
   b. If task not in TODO.md:
      - Log orphaned project
      - Prompt user to either add to TODO.md or remove from state.json
4. Update state.json metadata (repository_health, task_counts) from TODO.md
5. Write updated state.json atomically
```

**Pros**:
- Preserves manual TODO.md edits
- User-friendly (respects manual changes)

**Cons**:
- Violates architectural design (state.json should be authoritative)
- Slow (requires parsing TODO.md markdown)
- Error-prone (markdown parsing is fragile)
- Inconsistent with command patterns (all commands read from state.json)

**Strategy 3: Timestamp-Based (Hybrid)**

**Rationale**: Prefer whichever file was modified more recently

**Algorithm**:
```
1. Get modification timestamps for both files
2. Determine which file is newer
3. If state.json is newer:
   - Use Strategy 1 (prefer state.json)
4. If TODO.md is newer:
   - Detect which tasks were modified in TODO.md
   - For modified tasks only: update state.json from TODO.md
   - For unmodified tasks: update TODO.md from state.json
5. If timestamps equal:
   - Use Strategy 1 (prefer state.json by default)
```

**Pros**:
- Respects recent manual edits
- Flexible conflict resolution
- Can preserve user intent

**Cons**:
- Complex logic (harder to debug)
- Timestamps can be unreliable (touch command, git checkout)
- Partial updates can lead to inconsistent state
- Violates architectural principle (state.json should be authoritative)

**Strategy 4: Prompt User (Interactive)**

**Rationale**: Let user decide how to resolve conflicts

**Algorithm**:
```
1. Detect all discrepancies between TODO.md and state.json
2. For each discrepancy:
   a. Display both values (TODO.md vs state.json)
   b. Show modification timestamps
   c. Prompt user to choose:
      - [1] Prefer state.json (overwrite TODO.md)
      - [2] Prefer TODO.md (update state.json)
      - [3] Skip this task (leave as-is)
      - [4] Abort sync
3. Apply user's choices
4. Write updated files atomically
```

**Pros**:
- User has full control
- Can handle complex conflicts
- Preserves user intent

**Cons**:
- Not automated (requires user interaction)
- Slow for many discrepancies
- Not suitable for CI/CD or scripting
- User may not understand implications

**Recommended Strategy**:

**Default**: Strategy 1 (Prefer state.json) with **validation mode**

**Validation Mode**:
```bash
/sync --dry-run  # Detect discrepancies without modifying files
```

**Output**:
```
Sync Validation Report:

Discrepancies Detected: 3

1. Task 296: Status mismatch
   - state.json: "not_started"
   - TODO.md: "[RESEARCHING]"
   - Recommendation: Update TODO.md to match state.json

2. Task 297: Priority mismatch
   - state.json: "high"
   - TODO.md: "Medium"
   - Recommendation: Update TODO.md to match state.json

3. Task 298: Missing from state.json
   - TODO.md: Task exists
   - state.json: Task not found
   - Recommendation: Add task to state.json or remove from TODO.md

Run '/sync --force' to apply recommendations (prefer state.json)
Run '/sync --interactive' to resolve conflicts manually
```

**Force Mode**:
```bash
/sync --force  # Apply state.json → TODO.md sync without prompting
```

**Interactive Mode**:
```bash
/sync --interactive  # Prompt user for each discrepancy
```

### File Modification Timestamp Detection

**Detailed Implementation**:

**Cross-Platform Timestamp Detection**:
```bash
get_mtime() {
  local file="$1"
  
  # Try Linux stat first
  if stat -c "%Y" "$file" 2>/dev/null; then
    return 0
  fi
  
  # Try macOS stat
  if stat -f "%m" "$file" 2>/dev/null; then
    return 0
  fi
  
  # Fallback to ls (less precise)
  ls -l --time-style=+%s "$file" 2>/dev/null | awk '{print $6}'
}

todo_mtime=$(get_mtime .opencode/specs/TODO.md)
state_mtime=$(get_mtime .opencode/specs/state.json)

echo "TODO.md modified: $(date -d @$todo_mtime '+%Y-%m-%d %H:%M:%S')"
echo "state.json modified: $(date -d @$state_mtime '+%Y-%m-%d %H:%M:%S')"

if [ "$todo_mtime" -gt "$state_mtime" ]; then
  time_diff=$((todo_mtime - state_mtime))
  echo "TODO.md is newer by $time_diff seconds"
elif [ "$state_mtime" -gt "$todo_mtime" ]; then
  time_diff=$((state_mtime - todo_mtime))
  echo "state.json is newer by $time_diff seconds"
else
  echo "Files have same modification time"
fi
```

**Git-Based Timestamp Detection** (more reliable):
```bash
get_git_mtime() {
  local file="$1"
  git log -1 --format="%ct" -- "$file" 2>/dev/null || echo "0"
}

todo_git_mtime=$(get_git_mtime .opencode/specs/TODO.md)
state_git_mtime=$(get_git_mtime .opencode/specs/state.json)

echo "TODO.md last committed: $(date -d @$todo_git_mtime '+%Y-%m-%d %H:%M:%S')"
echo "state.json last committed: $(date -d @$state_git_mtime '+%Y-%m-%d %H:%M:%S')"
```

**Content-Based Change Detection** (most reliable):
```bash
# Detect which specific fields changed
detect_changes() {
  local task_num="$1"
  
  # Extract task from state.json
  state_task=$(jq -r --arg num "$task_num" \
    '.active_projects[] | select(.project_number == ($num | tonumber))' \
    .opencode/specs/state.json)
  
  # Extract task from TODO.md
  todo_task=$(grep -A 20 "^### $task_num\." .opencode/specs/TODO.md)
  
  # Compare status
  state_status=$(echo "$state_task" | jq -r '.status')
  todo_status=$(echo "$todo_task" | grep "Status:" | sed 's/.*\[\(.*\)\].*/\1/')
  
  if [ "$state_status" != "$todo_status" ]; then
    echo "Status changed: $state_status (state.json) vs $todo_status (TODO.md)"
  fi
  
  # Compare priority
  state_priority=$(echo "$state_task" | jq -r '.priority')
  todo_priority=$(echo "$todo_task" | grep "Priority:" | awk '{print $3}')
  
  if [ "$state_priority" != "$todo_priority" ]; then
    echo "Priority changed: $state_priority (state.json) vs $todo_priority (TODO.md)"
  fi
  
  # Compare language
  state_language=$(echo "$state_task" | jq -r '.language')
  todo_language=$(echo "$todo_task" | grep "Language:" | awk '{print $3}')
  
  if [ "$state_language" != "$todo_language" ]; then
    echo "Language changed: $state_language (state.json) vs $todo_language (TODO.md)"
  fi
}
```

**Recommendation**:
Use **content-based change detection** as primary method, with **file modification timestamps** as secondary indicator. This provides:
1. **Accurate detection** of which fields actually changed
2. **Granular reporting** of specific discrepancies
3. **Reliable comparison** independent of file timestamps
4. **Validation** that changes are meaningful (not just whitespace)

### Similar Command Patterns

**Command Structure Analysis**:

All workflow commands follow a consistent pattern:

**1. Frontmatter** (metadata):
```yaml
---
name: {command_name}
agent: orchestrator
description: "{Brief description}"
timeout: {seconds}
routing:
  language_based: {true|false}
  lean: {lean_agent}
  default: {default_agent}
---
```

**2. Context** (system and task context):
```markdown
<context>
  <system_context>Command purpose and role</system_context>
  <task_context>Parse arguments, validate, delegate</task_context>
</context>
```

**3. Workflow Execution** (stages):
```markdown
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    Parse arguments, validate inputs, lookup task
  </stage>
  
  <stage id="2" name="Delegate">
    Delegate to specialized subagent
  </stage>
</workflow_execution>
```

**4. Usage Documentation**:
```markdown
## Usage
Examples and explanation

## What This Does
Step-by-step description
```

**Sync Command Structure**:

Following this pattern, the /sync command should have:

**Frontmatter**:
```yaml
---
name: sync
agent: orchestrator
description: "Synchronize TODO.md and state.json, ensuring consistency"
timeout: 300
routing:
  language_based: false
  target_agent: sync-manager
---
```

**Context**:
```markdown
<context>
  <system_context>
    Sync command validates and repairs consistency between TODO.md and state.json
  </system_context>
  <task_context>
    Parse flags, validate files, detect discrepancies, delegate to sync-manager
  </task_context>
</context>
```

**Workflow Execution**:
```markdown
<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse flags and validate files</action>
    <process>
      1. Parse optional flags from $ARGUMENTS:
         - --dry-run: Validate without modifying files
         - --force: Apply sync without prompting
         - --interactive: Prompt for each discrepancy
         - --direction: unidirectional (default) or bidirectional
      2. Validate TODO.md exists and is readable
      3. Validate state.json exists and is valid JSON
      4. Check file modification timestamps
      5. Determine sync strategy based on flags
    </process>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to sync-manager subagent</action>
    <process>
      1. Invoke sync-manager with:
         - sync_direction: "state_to_todo" (default)
         - conflict_resolution: "prefer_state" (default)
         - dry_run: boolean
         - interactive: boolean
      2. Wait for sync-manager to complete
      3. Relay result to user (discrepancies found, actions taken)
    </process>
  </stage>
</workflow_execution>
```

**Usage Documentation**:
```markdown
## Usage

```bash
/sync                    # Validate and sync (state.json → TODO.md)
/sync --dry-run          # Detect discrepancies without modifying files
/sync --force            # Apply sync without prompting
/sync --interactive      # Prompt for each discrepancy
```

## What This Does

1. Validates both TODO.md and state.json exist and are well-formed
2. Detects discrepancies between the two files
3. Reports discrepancies with modification timestamps
4. Applies sync strategy (default: state.json → TODO.md)
5. Uses status-sync-manager for atomic updates
6. Creates git commit with sync changes
```

### Edge Cases and Error Handling

**Comprehensive Edge Case Matrix**:

| Edge Case | Detection | Handling | Recovery |
|-----------|-----------|----------|----------|
| state.json malformed | jq validation fails | Abort, prompt to run /meta | Regenerate from TODO.md |
| TODO.md missing YAML | File doesn't start with `---` | Generate header from state.json | Automatic |
| Task in TODO.md only | Compare task numbers | Prompt to add to state.json or remove | Manual |
| Task in state.json only | Compare task numbers | Add to TODO.md automatically | Automatic |
| Conflicting metadata | Field-by-field comparison | Prefer state.json (or prompt) | Automatic or manual |
| Both files modified | Timestamps equal, content differs | Cannot determine, prompt user | Manual |
| File permissions | Write permission check fails | Abort with error message | User fixes permissions |
| Concurrent modifications | Mtime changes during sync | Abort, report concurrent modification | Retry |
| Partial sync failure | Write fails during commit | Rollback via two-phase commit | Automatic |
| Invalid status transition | Validate per status-markers.md | Reject sync, report invalid | User fixes manually |
| Missing next_project_number | Field missing in state.json | Infer from max task number + 1 | Automatic |
| Duplicate task numbers | Multiple tasks with same number | Abort, report duplicates | User resolves manually |
| Orphaned artifacts | Artifact links to non-existent files | Warn, optionally remove links | Manual or automatic |
| YAML header mismatch | Compare header with state.json | Regenerate header from state.json | Automatic |
| Empty active_projects | state.json has no tasks | Regenerate from TODO.md | Automatic |
| Empty TODO.md | No tasks in TODO.md | Regenerate from state.json | Automatic |

**Error Handling Implementation**:

**1. Validation Errors** (abort before any writes):
```bash
validate_files() {
  # Check TODO.md exists
  if [ ! -f .opencode/specs/TODO.md ]; then
    echo "Error: TODO.md not found"
    exit 1
  fi
  
  # Check state.json exists
  if [ ! -f .opencode/specs/state.json ]; then
    echo "Error: state.json not found. Run /meta to regenerate."
    exit 1
  fi
  
  # Validate state.json is valid JSON
  if ! jq empty .opencode/specs/state.json 2>/dev/null; then
    echo "Error: state.json is not valid JSON"
    echo "Run /meta to regenerate state.json from TODO.md"
    exit 1
  fi
  
  # Check write permissions
  if [ ! -w .opencode/specs/TODO.md ]; then
    echo "Error: TODO.md is not writable"
    exit 1
  fi
  
  if [ ! -w .opencode/specs/state.json ]; then
    echo "Error: state.json is not writable"
    exit 1
  fi
}
```

**2. Discrepancy Detection** (report without modifying):
```bash
detect_discrepancies() {
  local discrepancies=0
  
  # Parse state.json active_projects
  state_tasks=$(jq -r '.active_projects[].project_number' .opencode/specs/state.json)
  
  # Parse TODO.md task numbers
  todo_tasks=$(grep -oP '^### \K\d+' .opencode/specs/TODO.md)
  
  # Find tasks in state.json but not in TODO.md
  for task in $state_tasks; do
    if ! echo "$todo_tasks" | grep -q "^$task$"; then
      echo "Discrepancy: Task $task in state.json but not in TODO.md"
      discrepancies=$((discrepancies + 1))
    fi
  done
  
  # Find tasks in TODO.md but not in state.json
  for task in $todo_tasks; do
    if ! echo "$state_tasks" | grep -q "^$task$"; then
      echo "Discrepancy: Task $task in TODO.md but not in state.json"
      discrepancies=$((discrepancies + 1))
    fi
  done
  
  return $discrepancies
}
```

**3. Atomic Updates** (two-phase commit):
```bash
sync_files() {
  # Phase 1: Prepare updates
  echo "Phase 1: Preparing updates..."
  
  # Backup original files
  todo_backup=$(cat .opencode/specs/TODO.md)
  state_backup=$(cat .opencode/specs/state.json)
  
  # Generate updated TODO.md from state.json
  updated_todo=$(generate_todo_from_state)
  
  # Validate updated TODO.md
  if ! validate_todo_syntax "$updated_todo"; then
    echo "Error: Generated TODO.md is invalid"
    return 1
  fi
  
  # Phase 2: Commit updates
  echo "Phase 2: Committing updates..."
  
  # Write TODO.md
  echo "$updated_todo" > .opencode/specs/TODO.md
  if [ $? -ne 0 ]; then
    echo "Error: Failed to write TODO.md"
    rollback
    return 1
  fi
  
  # Verify TODO.md written successfully
  if [ ! -s .opencode/specs/TODO.md ]; then
    echo "Error: TODO.md is empty after write"
    rollback
    return 1
  fi
  
  echo "Sync completed successfully"
  return 0
}

rollback() {
  echo "Rolling back changes..."
  echo "$todo_backup" > .opencode/specs/TODO.md
  echo "$state_backup" > .opencode/specs/state.json
  echo "Rollback completed"
}
```

**4. Dry-Run Mode** (validate without modifying):
```bash
if [ "$dry_run" = true ]; then
  echo "Dry-run mode: Detecting discrepancies without modifying files"
  detect_discrepancies
  exit 0
fi
```

### Atomic Update Patterns and Rollback Mechanisms

**Detailed Two-Phase Commit Implementation**:

**Phase 1: Prepare**

**Step 1.1: Read Files**
```bash
# Read both files into memory
todo_content=$(cat .opencode/specs/TODO.md)
state_content=$(cat .opencode/specs/state.json)

# Create backups
todo_backup="$todo_content"
state_backup="$state_content"
```

**Step 1.2: Parse and Validate**
```bash
# Parse state.json
state_json=$(echo "$state_content" | jq '.')
if [ $? -ne 0 ]; then
  echo "Error: state.json is not valid JSON"
  exit 1
fi

# Extract active_projects
active_projects=$(echo "$state_json" | jq -r '.active_projects')
if [ "$active_projects" = "null" ]; then
  echo "Error: state.json missing active_projects array"
  exit 1
fi

# Parse TODO.md
todo_tasks=$(echo "$todo_content" | grep -oP '^### \K\d+')
```

**Step 1.3: Detect Discrepancies**
```bash
# Compare task lists
discrepancies=$(compare_tasks "$active_projects" "$todo_tasks")
if [ -z "$discrepancies" ]; then
  echo "No discrepancies detected. Files are in sync."
  exit 0
fi

echo "Discrepancies detected:"
echo "$discrepancies"
```

**Step 1.4: Prepare Updates**
```bash
# Generate updated TODO.md from state.json
updated_todo=$(generate_todo_from_state "$state_json")

# Validate updated TODO.md syntax
if ! validate_todo_markdown "$updated_todo"; then
  echo "Error: Generated TODO.md has invalid markdown syntax"
  exit 1
fi

# Validate YAML header
if ! validate_yaml_header "$updated_todo"; then
  echo "Error: Generated TODO.md has invalid YAML header"
  exit 1
fi
```

**Step 1.5: Validate All Updates**
```bash
# Validate status transitions
if ! validate_status_transitions "$updated_todo" "$state_json"; then
  echo "Error: Invalid status transitions detected"
  exit 1
fi

# Validate task numbers are unique
if ! validate_unique_task_numbers "$updated_todo"; then
  echo "Error: Duplicate task numbers detected"
  exit 1
fi

# Validate artifact links
if ! validate_artifact_links "$updated_todo"; then
  echo "Warning: Some artifact links point to non-existent files"
fi
```

**Phase 2: Commit**

**Step 2.1: Write TODO.md**
```bash
echo "Writing TODO.md..."
echo "$updated_todo" > .opencode/specs/TODO.md

# Verify write succeeded
if [ $? -ne 0 ]; then
  echo "Error: Failed to write TODO.md"
  rollback_all
  exit 1
fi

# Verify file is non-empty
if [ ! -s .opencode/specs/TODO.md ]; then
  echo "Error: TODO.md is empty after write"
  rollback_all
  exit 1
fi
```

**Step 2.2: Verify TODO.md**
```bash
# Verify TODO.md is valid markdown
if ! validate_todo_markdown "$(cat .opencode/specs/TODO.md)"; then
  echo "Error: TODO.md is invalid after write"
  rollback_all
  exit 1
fi
```

**Step 2.3: Update state.json (if needed)**
```bash
# If state.json needs updates (e.g., last_updated timestamp)
if [ -n "$state_updates" ]; then
  echo "Writing state.json..."
  echo "$updated_state" > .opencode/specs/state.json
  
  # Verify write succeeded
  if [ $? -ne 0 ]; then
    echo "Error: Failed to write state.json"
    rollback_all
    exit 1
  fi
  
  # Verify file is non-empty and valid JSON
  if ! jq empty .opencode/specs/state.json 2>/dev/null; then
    echo "Error: state.json is invalid after write"
    rollback_all
    exit 1
  fi
fi
```

**Step 2.4: Post-Commit Validation**
```bash
# Verify both files exist and are non-empty
[ -s .opencode/specs/TODO.md ] || log_error "TODO.md missing or empty"
[ -s .opencode/specs/state.json ] || log_error "state.json missing or empty"

# Verify files are readable
[ -r .opencode/specs/TODO.md ] || log_error "TODO.md not readable"
[ -r .opencode/specs/state.json ] || log_error "state.json not readable"

# Verify files are valid
validate_todo_markdown "$(cat .opencode/specs/TODO.md)" || log_error "TODO.md invalid"
jq empty .opencode/specs/state.json || log_error "state.json invalid"
```

**Rollback Implementation**:

```bash
rollback_all() {
  echo "ERROR: Write failed. Rolling back all changes..."
  
  # Restore TODO.md from backup
  echo "$todo_backup" > .opencode/specs/TODO.md
  if [ $? -ne 0 ]; then
    echo "CRITICAL: Failed to restore TODO.md from backup!"
    echo "Backup content:"
    echo "$todo_backup"
    exit 2
  fi
  
  # Restore state.json from backup
  echo "$state_backup" > .opencode/specs/state.json
  if [ $? -ne 0 ]; then
    echo "CRITICAL: Failed to restore state.json from backup!"
    echo "Backup content:"
    echo "$state_backup"
    exit 2
  fi
  
  # Verify rollback succeeded
  if [ ! -s .opencode/specs/TODO.md ]; then
    echo "CRITICAL: TODO.md is empty after rollback!"
    exit 2
  fi
  
  if ! jq empty .opencode/specs/state.json 2>/dev/null; then
    echo "CRITICAL: state.json is invalid after rollback!"
    exit 2
  fi
  
  echo "Rollback completed successfully. Files restored to original state."
  exit 1
}
```

**Git Commit Integration**:

After successful sync, create git commit via git-workflow-manager:

```bash
# Invoke git-workflow-manager
git-workflow-manager \
  --scope-files ".opencode/specs/TODO.md,.opencode/specs/state.json" \
  --message-template "sync: synchronized TODO.md and state.json" \
  --task-context '{"description": "sync completed"}' \
  --session-id "$session_id"
```

---

## Decisions

### Decision 1: Sync Direction - Unidirectional (state.json → TODO.md)

**Rationale**:
- state.json is the authoritative source per architectural design
- All commands read metadata from state.json (8x faster than TODO.md parsing)
- TODO.md is the user-facing view, should reflect state.json
- Bidirectional sync violates architectural principle

**Implementation**:
- Default sync direction: state.json → TODO.md
- Regenerate TODO.md from state.json active_projects array
- Regenerate YAML header from state.json metadata
- Preserve TODO.md formatting where possible (priority sections, markdown structure)

**Alternative Considered**:
- Bidirectional sync with timestamp-based conflict resolution
- Rejected due to complexity and architectural violation

### Decision 2: Conflict Resolution - Prefer state.json with Validation Mode

**Rationale**:
- Consistent with architectural design
- Predictable behavior
- Fast and reliable
- Allows user to review changes before applying (--dry-run)

**Implementation**:
- Default: Prefer state.json, overwrite TODO.md
- Validation mode (--dry-run): Detect discrepancies without modifying files
- Interactive mode (--interactive): Prompt user for each discrepancy
- Force mode (--force): Apply sync without prompting

**Alternative Considered**:
- Always prompt user for conflicts
- Rejected due to poor automation support

### Decision 3: Leverage status-sync-manager for Atomic Updates

**Rationale**:
- Reuse existing tested atomic update logic
- Consistent rollback behavior across all commands
- Proper validation and error handling
- Git commit integration via git-workflow-manager

**Implementation**:
- Delegate to status-sync-manager for file writes
- Use two-phase commit protocol
- Rollback on any failure
- Create git commit after successful sync

**Alternative Considered**:
- Implement custom atomic update logic in sync command
- Rejected due to code duplication and maintenance burden

### Decision 4: Fix state.json Structure Before Implementing /sync

**Rationale**:
- Current state.json is malformed (single project instead of active_projects array)
- Cannot implement sync without proper state.json structure
- Fixing structure first enables proper testing of sync command

**Implementation**:
1. Create /meta command enhancement to regenerate state.json from TODO.md
2. Parse all tasks from TODO.md
3. Extract metadata for each task
4. Reconstruct active_projects array
5. Add repository health metadata
6. Set next_project_number correctly
7. Validate regenerated state.json
8. Write atomically

**Alternative Considered**:
- Implement sync command to handle malformed state.json
- Rejected due to complexity and edge cases

### Decision 5: Implement Validation Mode (--dry-run) as Default

**Rationale**:
- Safe default behavior (detect without modifying)
- Allows user to review discrepancies before applying sync
- Prevents accidental overwrites of manual TODO.md edits
- Encourages validation before sync

**Implementation**:
```bash
/sync              # Default: --dry-run (detect discrepancies only)
/sync --force      # Apply sync without prompting
/sync --interactive # Prompt for each discrepancy
```

**Alternative Considered**:
- Default to applying sync immediately
- Rejected due to risk of overwriting manual edits

---

## Recommendations

### Recommendation 1: Fix state.json Structure First (CRITICAL)

**Priority**: CRITICAL  
**Effort**: 2-3 hours  
**Blocking**: /sync command implementation

**Action Items**:
1. Create task to regenerate state.json from TODO.md
2. Implement /meta command enhancement or standalone script
3. Parse all tasks from TODO.md (grep for `^### \d+\.`)
4. Extract metadata for each task (status, priority, language, description, etc.)
5. Reconstruct active_projects array with all tasks
6. Add repository health metadata (task_counts, priority_distribution, technical_debt)
7. Set next_project_number to max(task_numbers) + 1
8. Validate regenerated state.json with jq
9. Backup current state.json
10. Write regenerated state.json atomically
11. Verify all commands can read from regenerated state.json

**Validation**:
```bash
# Verify state.json has active_projects array
jq '.active_projects | length' .opencode/specs/state.json

# Verify all TODO.md tasks are in state.json
todo_tasks=$(grep -oP '^### \K\d+' .opencode/specs/TODO.md | wc -l)
state_tasks=$(jq '.active_projects | length' .opencode/specs/state.json)
echo "TODO.md tasks: $todo_tasks"
echo "state.json tasks: $state_tasks"

# Verify next_project_number is correct
max_task=$(grep -oP '^### \K\d+' .opencode/specs/TODO.md | sort -n | tail -1)
next_num=$(jq -r '.next_project_number' .opencode/specs/state.json)
echo "Max task number: $max_task"
echo "Next project number: $next_num"
[ "$next_num" -gt "$max_task" ] && echo "PASS" || echo "FAIL"
```

### Recommendation 2: Implement /sync Command with Unidirectional Sync

**Priority**: High  
**Effort**: 4-6 hours  
**Dependencies**: Recommendation 1 (state.json structure fixed)

**Action Items**:
1. Create `.opencode/command/sync.md` following command template
2. Implement argument parsing (--dry-run, --force, --interactive)
3. Implement file validation (TODO.md exists, state.json valid JSON)
4. Implement discrepancy detection (compare task lists, metadata)
5. Implement sync logic (regenerate TODO.md from state.json)
6. Delegate to status-sync-manager for atomic updates
7. Implement rollback mechanism (two-phase commit)
8. Implement validation mode (--dry-run)
9. Implement interactive mode (--interactive)
10. Create git commit via git-workflow-manager
11. Add comprehensive error handling
12. Write tests for edge cases

**Command Structure**:
```yaml
---
name: sync
agent: orchestrator
description: "Synchronize TODO.md and state.json, ensuring consistency"
timeout: 300
routing:
  language_based: false
  target_agent: sync-manager
---
```

**Usage**:
```bash
/sync              # Detect discrepancies (dry-run mode)
/sync --force      # Apply sync (state.json → TODO.md)
/sync --interactive # Prompt for each discrepancy
```

### Recommendation 3: Create sync-manager Subagent

**Priority**: High  
**Effort**: 3-4 hours  
**Dependencies**: Recommendation 1 (state.json structure fixed)

**Action Items**:
1. Create `.opencode/agent/subagents/sync-manager.md`
2. Implement discrepancy detection logic
3. Implement TODO.md generation from state.json
4. Implement YAML header generation from state.json metadata
5. Implement metadata comparison (status, priority, language, etc.)
6. Implement validation mode (detect without modifying)
7. Implement interactive mode (prompt for conflicts)
8. Delegate to status-sync-manager for atomic writes
9. Return standardized format per subagent-return-format.md
10. Add comprehensive error handling and rollback

**Subagent Responsibilities**:
- Parse state.json active_projects array
- Generate TODO.md content from state.json
- Detect discrepancies between files
- Report discrepancies with modification timestamps
- Apply sync strategy (prefer state.json)
- Validate all updates before writing
- Delegate to status-sync-manager for atomic writes

### Recommendation 4: Add Validation to status-sync-manager

**Priority**: Medium  
**Effort**: 2-3 hours  
**Dependencies**: None

**Action Items**:
1. Add validation mode to status-sync-manager
2. Implement discrepancy detection without modifying files
3. Return validation report with discrepancies found
4. Add --dry-run flag support
5. Update status-sync-manager documentation

**Validation Report Format**:
```json
{
  "status": "validation_completed",
  "summary": "Detected 3 discrepancies between TODO.md and state.json",
  "discrepancies": [
    {
      "task_number": 296,
      "field": "status",
      "state_json_value": "not_started",
      "todo_md_value": "RESEARCHING",
      "recommendation": "Update TODO.md to match state.json"
    },
    {
      "task_number": 297,
      "field": "priority",
      "state_json_value": "high",
      "todo_md_value": "Medium",
      "recommendation": "Update TODO.md to match state.json"
    },
    {
      "task_number": 298,
      "field": "existence",
      "state_json_value": null,
      "todo_md_value": "exists",
      "recommendation": "Add task to state.json or remove from TODO.md"
    }
  ],
  "metadata": {
    "session_id": "sess_20260105_abc123",
    "duration_seconds": 1.2,
    "agent_type": "status-sync-manager"
  }
}
```

### Recommendation 5: Document Sync Workflow in Standards

**Priority**: Medium  
**Effort**: 1-2 hours  
**Dependencies**: Recommendations 2, 3 (sync command and subagent implemented)

**Action Items**:
1. Create `.opencode/context/core/workflows/sync-workflow.md`
2. Document sync command usage and flags
3. Document sync-manager subagent responsibilities
4. Document conflict resolution strategies
5. Document edge cases and error handling
6. Add examples of common sync scenarios
7. Update state-management.md with sync patterns

**Documentation Sections**:
- Overview of sync workflow
- When to use /sync command
- Sync direction (state.json → TODO.md)
- Conflict resolution strategies
- Validation mode (--dry-run)
- Interactive mode (--interactive)
- Edge cases and error handling
- Rollback mechanism
- Git commit integration

### Recommendation 6: Add Automated Sync Validation to CI/CD

**Priority**: Low  
**Effort**: 2-3 hours  
**Dependencies**: Recommendation 2 (sync command implemented)

**Action Items**:
1. Create CI/CD workflow to validate TODO.md and state.json consistency
2. Run /sync --dry-run in CI pipeline
3. Fail build if discrepancies detected
4. Report discrepancies in CI output
5. Add pre-commit hook to validate sync

**CI/CD Workflow**:
```yaml
name: Validate Sync

on: [push, pull_request]

jobs:
  validate-sync:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Validate TODO.md and state.json consistency
        run: |
          /sync --dry-run
          if [ $? -ne 0 ]; then
            echo "ERROR: TODO.md and state.json are out of sync"
            exit 1
          fi
```

---

## Risks & Mitigations

### Risk 1: Overwriting Manual TODO.md Edits

**Likelihood**: High  
**Impact**: Medium  
**Severity**: Medium

**Description**:
Users may manually edit TODO.md to add notes, update descriptions, or change priorities. The /sync command will overwrite these edits if state.json is preferred.

**Mitigation**:
1. **Default to validation mode** (--dry-run): Detect discrepancies without modifying files
2. **Warn about manual edits**: Display which tasks have been manually edited
3. **Interactive mode**: Prompt user to review each discrepancy before applying
4. **Git integration**: Create commit after sync, allowing easy rollback
5. **Documentation**: Clearly document that state.json is authoritative and manual TODO.md edits should be avoided

**Residual Risk**: Low (with mitigations in place)

### Risk 2: state.json Corruption

**Likelihood**: Low  
**Impact**: High  
**Severity**: Medium

**Description**:
If state.json becomes corrupted (invalid JSON, missing fields, etc.), the /sync command may fail or produce incorrect results.

**Mitigation**:
1. **Validation before sync**: Validate state.json is valid JSON with required fields
2. **Abort on corruption**: Do not proceed with sync if state.json is invalid
3. **Clear error messages**: Explain how to regenerate state.json from TODO.md
4. **Backup before sync**: Create backup of both files before any modifications
5. **Rollback on failure**: Restore original files if sync fails

**Residual Risk**: Low (with mitigations in place)

### Risk 3: Concurrent Modifications

**Likelihood**: Low  
**Impact**: Medium  
**Severity**: Low

**Description**:
Another process (user, command, script) may modify TODO.md or state.json while /sync is running, leading to race conditions.

**Mitigation**:
1. **File locking**: Use flock or similar mechanism to lock files during sync
2. **Timestamp validation**: Check modification times before and after reading files
3. **Abort on concurrent modification**: Detect if files changed during sync and abort
4. **Retry mechanism**: Allow user to retry sync after concurrent modification detected

**Residual Risk**: Very Low (with mitigations in place)

### Risk 4: Invalid Status Transitions

**Likelihood**: Medium  
**Impact**: Low  
**Severity**: Low

**Description**:
TODO.md may contain invalid status transitions (e.g., [COMPLETED] → [IN PROGRESS]) that violate status-markers.md rules.

**Mitigation**:
1. **Validate status transitions**: Check all status changes against status-markers.md
2. **Reject invalid transitions**: Abort sync if invalid transitions detected
3. **Report invalid transitions**: Clearly explain which transitions are invalid and why
4. **Suggest corrections**: Recommend valid status transitions

**Residual Risk**: Very Low (with mitigations in place)

### Risk 5: Performance with Large Task Lists

**Likelihood**: Low  
**Impact**: Low  
**Severity**: Low

**Description**:
With hundreds of tasks, parsing TODO.md and comparing with state.json may be slow.

**Mitigation**:
1. **Optimize parsing**: Use efficient grep/awk/jq patterns
2. **Parallel processing**: Compare tasks in parallel where possible
3. **Caching**: Cache parsed data to avoid redundant parsing
4. **Progress indicators**: Show progress for large task lists

**Residual Risk**: Very Low (performance is acceptable for expected task counts)

---

## Appendix: Sources and Citations

### Primary Sources

1. **status-sync-manager.md** (`.opencode/agent/subagents/status-sync-manager.md`)
   - Two-phase commit protocol
   - Atomic update patterns
   - Rollback mechanisms
   - Artifact validation protocol

2. **state-management.md** (`.opencode/context/core/system/state-management.md`)
   - State file schemas
   - Status markers and transitions
   - Timestamp formats
   - State lookup patterns
   - Read/write separation principle

3. **TODO.md** (`.opencode/specs/TODO.md`)
   - Current YAML header structure
   - Task entry format
   - Priority sections
   - Status markers in use

4. **state.json** (`.opencode/specs/state.json`)
   - Current structure (malformed - single project)
   - Expected structure (active_projects array)
   - Metadata fields

5. **research.md** (`.opencode/command/research.md`)
   - Command structure pattern
   - Argument parsing
   - State.json lookup pattern
   - Language-based routing

6. **command-template.md** (`.opencode/context/core/templates/command-template.md`)
   - Standard command structure
   - Frontmatter format
   - Workflow execution stages
   - Usage documentation

7. **git-workflow-manager.md** (`.opencode/agent/subagents/git-workflow-manager.md`)
   - Git commit creation
   - Scoped commits
   - Message generation
   - Error handling

### Secondary Sources

8. **Task 279** (TODO.md line 759)
   - Metadata lookup patterns
   - state.json vs TODO.md usage
   - Architectural issues with current implementation

9. **Task 295** (TODO.md line 1152)
   - Original /sync command task (duplicate of 296)
   - Synchronization requirements

10. **REFACTOR.md** (`.opencode/REFACTOR.md`)
    - System rebuild plan
    - Architectural principles
    - Context directory restructuring

### Code Examples

11. **File modification timestamp detection**
    - stat command (Linux and macOS)
    - ls command (portable)
    - git log (git-based timestamps)

12. **jq queries for state.json**
    - Task lookup by project_number
    - Metadata extraction
    - Array operations

13. **TODO.md parsing patterns**
    - grep for task numbers
    - awk for metadata extraction
    - sed for status markers

---

## Appendix: Implementation Checklist

### Phase 1: Fix state.json Structure (CRITICAL)

- [ ] Create task to regenerate state.json from TODO.md
- [ ] Implement TODO.md parser to extract all tasks
- [ ] Extract metadata for each task (status, priority, language, description)
- [ ] Reconstruct active_projects array
- [ ] Add repository health metadata
- [ ] Set next_project_number correctly
- [ ] Validate regenerated state.json with jq
- [ ] Backup current state.json
- [ ] Write regenerated state.json atomically
- [ ] Verify all commands can read from regenerated state.json

### Phase 2: Implement /sync Command

- [ ] Create `.opencode/command/sync.md` following command template
- [ ] Implement frontmatter (name, agent, description, routing)
- [ ] Implement argument parsing (--dry-run, --force, --interactive)
- [ ] Implement file validation (TODO.md exists, state.json valid JSON)
- [ ] Implement timestamp detection (stat command, cross-platform)
- [ ] Implement delegation to sync-manager subagent
- [ ] Implement result relay to user
- [ ] Add usage documentation
- [ ] Add examples for common scenarios

### Phase 3: Implement sync-manager Subagent

- [ ] Create `.opencode/agent/subagents/sync-manager.md`
- [ ] Implement frontmatter (name, version, mode, tools, permissions)
- [ ] Implement discrepancy detection logic
- [ ] Implement TODO.md generation from state.json
- [ ] Implement YAML header generation from state.json metadata
- [ ] Implement metadata comparison (status, priority, language, etc.)
- [ ] Implement validation mode (detect without modifying)
- [ ] Implement interactive mode (prompt for conflicts)
- [ ] Delegate to status-sync-manager for atomic writes
- [ ] Return standardized format per subagent-return-format.md
- [ ] Add comprehensive error handling and rollback

### Phase 4: Testing and Validation

- [ ] Test /sync --dry-run (validation mode)
- [ ] Test /sync --force (apply sync)
- [ ] Test /sync --interactive (prompt for conflicts)
- [ ] Test edge case: state.json malformed
- [ ] Test edge case: TODO.md missing YAML header
- [ ] Test edge case: Task in TODO.md only
- [ ] Test edge case: Task in state.json only
- [ ] Test edge case: Conflicting metadata
- [ ] Test edge case: Both files modified simultaneously
- [ ] Test edge case: File permissions
- [ ] Test edge case: Concurrent modifications
- [ ] Test edge case: Partial sync failure (rollback)
- [ ] Test edge case: Invalid status transitions
- [ ] Verify git commit created after successful sync
- [ ] Verify rollback works correctly on failures

### Phase 5: Documentation

- [ ] Create `.opencode/context/core/workflows/sync-workflow.md`
- [ ] Document sync command usage and flags
- [ ] Document sync-manager subagent responsibilities
- [ ] Document conflict resolution strategies
- [ ] Document edge cases and error handling
- [ ] Add examples of common sync scenarios
- [ ] Update state-management.md with sync patterns
- [ ] Update command documentation index

### Phase 6: CI/CD Integration (Optional)

- [ ] Create CI/CD workflow to validate TODO.md and state.json consistency
- [ ] Run /sync --dry-run in CI pipeline
- [ ] Fail build if discrepancies detected
- [ ] Report discrepancies in CI output
- [ ] Add pre-commit hook to validate sync

---

## Conclusion

This research has identified the requirements, challenges, and implementation strategy for creating a /sync command to synchronize TODO.md and state.json. The key findings are:

1. **Current state.json is malformed** and must be fixed before implementing /sync
2. **Sync should be unidirectional** (state.json → TODO.md) to maintain architectural integrity
3. **status-sync-manager provides atomic updates** that should be leveraged
4. **Validation mode (--dry-run) should be the default** to prevent accidental overwrites
5. **Comprehensive edge case handling is required** to ensure robustness

The recommended implementation approach is:
1. Fix state.json structure first (regenerate from TODO.md)
2. Implement /sync command following existing command patterns
3. Create sync-manager subagent to handle sync logic
4. Leverage status-sync-manager for atomic updates and rollback
5. Add comprehensive testing and documentation

This approach ensures consistency with the existing architecture, reuses tested components, and provides a safe, reliable synchronization mechanism.
