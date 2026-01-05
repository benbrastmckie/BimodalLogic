---
name: sync
agent: orchestrator
description: "Bidirectional synchronization of TODO.md and state.json using git blame timestamps"
context_level: 2
language: markdown
routing:
  language_based: false
  target_agent: status-sync-manager
timeout: 600
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"
    - "core/standards/command-argument-handling.md"
  max_context_size: 50000
---

**Task Input (optional):** $ARGUMENTS

<context>
  <system_context>Sync command with git blame-based per-field conflict resolution</system_context>
  <task_context>Detect discrepancies between TODO.md and state.json, resolve conflicts using git blame timestamps, apply updates atomically</task_context>
</context>

<role>Sync command agent - Bidirectional synchronization of TODO.md and state.json with field-level precision</role>

<task>
  Parse arguments (--dry-run flag), detect field-level discrepancies between TODO.md and state.json, resolve conflicts using git blame timestamps, apply atomic updates via status-sync-manager
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse arguments and validate files</action>
    <process>
      1. Parse --dry-run flag from $ARGUMENTS
         - Check if $ARGUMENTS contains "--dry-run"
         - Set dry_run=true if present, false otherwise
      
      2. Validate git repository
         - Check if .git directory exists
         - Run: git rev-parse --is-inside-work-tree
         - If not git repo: Error "Not a git repository. Git history required for sync."
      
      3. Validate TODO.md exists and is tracked
         - Check .opencode/specs/TODO.md exists
         - Run: git ls-files --error-unmatch .opencode/specs/TODO.md
         - If not tracked: Error "TODO.md not tracked in git. Run: git add .opencode/specs/TODO.md && git commit"
      
      4. Validate state.json exists and is tracked
         - Check .opencode/specs/state.json exists
         - Run: git ls-files --error-unmatch .opencode/specs/state.json
         - If not tracked: Error "state.json not tracked in git. Run: git add .opencode/specs/state.json && git commit"
      
      5. Validate state.json is valid JSON
         - Run: jq empty .opencode/specs/state.json
         - If invalid: Error "state.json is malformed. Fix JSON syntax before sync."
      
      6. Check for uncommitted changes
         - Run: git diff --name-only .opencode/specs/TODO.md .opencode/specs/state.json
         - If uncommitted changes found: Warn "Uncommitted changes detected. Commit before sync for accurate timestamps. Falling back to file mtime for uncommitted lines."
         - Store uncommitted_files list
      
      7. Generate session_id
         - session_id=sess_$(date +%Y%m%d)_$(openssl rand -hex 3)
      
      8. Create backups
         - cp .opencode/specs/TODO.md /tmp/TODO.md.backup.$session_id
         - cp .opencode/specs/state.json /tmp/state.json.backup.$session_id
    </process>
    <checkpoint>Arguments parsed, files validated, backups created</checkpoint>
  </stage>
  
  <stage id="2" name="ExtractTasksAndFields">
    <action>Extract all tasks and their field locations from both files</action>
    <process>
      1. Parse TODO.md to extract task entries
         - Use grep to find task headers: grep -n "^### [0-9]\+\." .opencode/specs/TODO.md
         - For each task:
           * Extract task number from header
           * Find field line numbers:
             - Status line: grep -n "**Status**:" in task section
             - Priority line: grep -n "**Priority**:" in task section
             - Effort line: grep -n "**Effort**:" in task section
             - Language line: grep -n "**Language**:" in task section
             - Description line: grep -n "**Description**:" in task section
           * Extract field values
           * Store: {task_number, fields: {status: {value, line_number}, priority: {value, line_number}, ...}}
      
      2. Parse state.json to extract task entries
         - Use jq to extract active_projects array
         - For each task in active_projects:
           * Extract project_number
           * Find field line numbers using grep with line numbers:
             - Status line: grep -n '"status":' for this task's JSON object
             - Priority line: grep -n '"priority":' for this task's JSON object
             - Effort line: grep -n '"effort":' for this task's JSON object
             - Language line: grep -n '"language":' for this task's JSON object
             - Description line: grep -n '"description":' for this task's JSON object
           * Extract field values
           * Store: {project_number, fields: {status: {value, line_number}, priority: {value, line_number}, ...}}
      
      3. Build task index
         - Create map of task_number → {todo_fields, state_fields}
         - Identify tasks in TODO.md but not state.json
         - Identify tasks in state.json but not TODO.md
    </process>
    <checkpoint>All tasks and field locations extracted</checkpoint>
  </stage>
  
  <stage id="3" name="GetGitBlameTimestamps">
    <action>Get git blame timestamps for each field in both files</action>
    <process>
      1. Cache git blame output for TODO.md
         - Run: git blame --line-porcelain .opencode/specs/TODO.md > /tmp/todo_blame_$session_id.txt
         - Parse output to build line_number → {commit_hash, author_time, summary} map
      
      2. Cache git blame output for state.json
         - Run: git blame --line-porcelain .opencode/specs/state.json > /tmp/state_blame_$session_id.txt
         - Parse output to build line_number → {commit_hash, author_time, summary} map
      
      3. For each task in TODO.md:
         - For each field (status, priority, effort, language, description):
           * Lookup line_number in TODO.md blame cache
           * Extract author_time (Unix epoch seconds)
           * Store: todo_fields[field].timestamp = author_time
           * Store: todo_fields[field].commit = commit_hash
      
      4. For each task in state.json:
         - For each field (status, priority, effort, language, description):
           * Lookup line_number in state.json blame cache
           * Extract author_time (Unix epoch seconds)
           * Store: state_fields[field].timestamp = author_time
           * Store: state_fields[field].commit = commit_hash
      
      5. Handle uncommitted changes fallback
         - For files in uncommitted_files list:
           * If field line is uncommitted (git diff shows change):
             - Use file mtime as fallback timestamp
             - Mark field as uncommitted: field.uncommitted = true
             - Warn: "Field {field} in {file} has uncommitted changes. Using file mtime as timestamp."
    </process>
    <checkpoint>Git blame timestamps extracted for all fields</checkpoint>
  </stage>
  
  <stage id="4" name="DetectDiscrepancies">
    <action>Compare field values and detect discrepancies</action>
    <process>
      1. For each task in task index:
         - If task only in TODO.md:
           * Mark for addition to state.json
           * Add to discrepancies: {task_number, type: "missing_in_state", action: "add_to_state"}
         
         - If task only in state.json:
           * Mark for addition to TODO.md
           * Add to discrepancies: {task_number, type: "missing_in_todo", action: "add_to_todo"}
         
         - If task in both files:
           * For each field (status, priority, effort, language, description):
             a. Normalize values for comparison:
                - Status: [NOT STARTED] ↔ not_started, [PLANNED] ↔ planned, etc.
                - Priority: High ↔ high, Medium ↔ medium, Low ↔ low
                - Effort: Keep as-is (string comparison)
                - Language: Keep as-is (string comparison)
                - Description: Keep as-is (string comparison)
             
             b. Compare normalized values:
                - If values differ:
                  * Record discrepancy: {
                      task_number,
                      field,
                      todo_value,
                      todo_timestamp,
                      todo_commit,
                      state_value,
                      state_timestamp,
                      state_commit,
                      type: "field_mismatch"
                    }
      
      2. Build discrepancy report
         - Count total discrepancies
         - Group by type: missing_in_state, missing_in_todo, field_mismatch
         - Sort by task_number
    </process>
    <checkpoint>All discrepancies detected and cataloged</checkpoint>
  </stage>
  
  <stage id="5" name="ResolveConflicts">
    <action>Resolve field-level conflicts using git blame timestamps</action>
    <process>
      1. For each field_mismatch discrepancy:
         - Compare timestamps: todo_timestamp vs state_timestamp
         
         - If todo_timestamp > state_timestamp:
           * Resolution: prefer_todo
           * Action: update_state
           * Reason: "TODO.md field modified more recently ({todo_commit} at {todo_time} vs {state_commit} at {state_time})"
         
         - If state_timestamp > todo_timestamp:
           * Resolution: prefer_state
           * Action: update_todo
           * Reason: "state.json field modified more recently ({state_commit} at {state_time} vs {todo_commit} at {todo_time})"
         
         - If timestamps equal:
           * Resolution: prefer_state (state.json is authoritative source)
           * Action: update_todo
           * Reason: "Timestamps equal, preferring state.json as authoritative source"
      
      2. For missing_in_state discrepancies:
         - Resolution: add_to_state
         - Action: create task in state.json with all fields from TODO.md
         - Reason: "Task exists in TODO.md but not in state.json"
      
      3. For missing_in_todo discrepancies:
         - Resolution: add_to_todo
         - Action: create task in TODO.md with all fields from state.json
         - Reason: "Task exists in state.json but not in TODO.md"
      
      4. Build resolution plan
         - List all field-level updates: {task_number, field, action, old_value, new_value, reason}
         - List all task additions: {task_number, action, source_file, reason}
         - Validate plan is consistent (no conflicting updates)
      
      5. Generate resolution summary
         - Count updates by action type: update_todo, update_state, add_to_todo, add_to_state
         - Estimate changes: X fields in TODO.md, Y fields in state.json
    </process>
    <checkpoint>All conflicts resolved with field-level precision</checkpoint>
  </stage>
  
  <stage id="6" name="ApplyOrPreview">
    <action>Apply updates atomically or preview in dry-run mode</action>
    <process>
      1. If dry_run mode:
         - Display resolution plan:
           ```
           SYNC PREVIEW (--dry-run mode)
           
           DISCREPANCIES DETECTED: {count}
           
           FIELD-LEVEL UPDATES:
           {for each field update:}
           - Task {number}, field {field}: {old_value} → {new_value}
             Source: {source_file} (modified {timestamp}, commit {commit_hash})
             Reason: {reason}
           
           TASK ADDITIONS:
           {for each task addition:}
           - Task {number}: Add to {target_file}
             Source: {source_file}
             Reason: {reason}
           
           SUMMARY:
           - {count} fields to update in TODO.md
           - {count} fields to update in state.json
           - {count} tasks to add to TODO.md
           - {count} tasks to add to state.json
           
           Run without --dry-run to apply changes.
           ```
         - Exit with status 0
      
      2. If NOT dry_run mode:
         - For each field update:
           a. Prepare status-sync-manager delegation context:
              - operation: "update_status"
              - task_number: {number}
              - field_updates: [{field, new_value}]
              - session_id: {session_id}
              - delegation_depth: 1
              - delegation_path: ["orchestrator", "sync", "status-sync-manager"]
           
           b. Invoke status-sync-manager via task tool
           
           c. Validate return status
           
           d. If failed: Rollback all previous updates, restore from backups, exit with error
         
         - For each task addition:
           a. Prepare status-sync-manager delegation context:
              - operation: "create_task"
              - task_number: {number}
              - title: {title}
              - description: {description}
              - priority: {priority}
              - effort: {effort}
              - language: {language}
              - session_id: {session_id}
              - delegation_depth: 1
              - delegation_path: ["orchestrator", "sync", "status-sync-manager"]
           
           b. Invoke status-sync-manager via task tool
           
           c. Validate return status
           
           d. If failed: Rollback all previous updates, restore from backups, exit with error
      
      3. Verify synchronization succeeded
         - Re-run discrepancy detection (Stage 4)
         - If discrepancies still exist: Warn "Synchronization incomplete. Manual review needed."
         - If no discrepancies: Success "TODO.md and state.json are now synchronized."
    </process>
    <checkpoint>Updates applied atomically or preview displayed</checkpoint>
  </stage>
  
  <stage id="7" name="CreateCommit">
    <action>Create git commit with sync changes</action>
    <process>
      1. Skip if dry_run mode
      
      2. Prepare git-workflow-manager delegation context:
         - scope_files: [".opencode/specs/TODO.md", ".opencode/specs/state.json"]
         - message_template: "sync: bidirectional TODO.md and state.json synchronization ({count} changes)"
         - task_context: {
             description: "Synchronized {count} field-level changes using git blame timestamps",
             change_count: {count}
           }
         - session_id: {session_id}
         - delegation_depth: 1
         - delegation_path: ["orchestrator", "sync", "git-workflow-manager"]
      
      3. Invoke git-workflow-manager via task tool
      
      4. Validate return status
      
      5. If commit failed:
         - Warn "Git commit failed. Changes applied but not committed. Run: git add .opencode/specs/TODO.md .opencode/specs/state.json && git commit -m 'sync: ...'"
         - Do NOT rollback (changes are valid, just not committed)
    </process>
    <checkpoint>Git commit created or warning issued</checkpoint>
  </stage>
  
  <stage id="8" name="ReportResults">
    <action>Display synchronization results</action>
    <process>
      1. Format results summary:
         ```
         SYNCHRONIZATION COMPLETE
         
         CHANGES APPLIED:
         - {count} fields updated in TODO.md
         - {count} fields updated in state.json
         - {count} tasks added to TODO.md
         - {count} tasks added to state.json
         
         FIELD-LEVEL UPDATES:
         {for each field update:}
         - Task {number}, field {field}: {old_value} → {new_value}
           Reason: {reason}
         
         TASK ADDITIONS:
         {for each task addition:}
         - Task {number}: Added to {target_file}
           Reason: {reason}
         
         FILES UPDATED:
         - .opencode/specs/TODO.md
         - .opencode/specs/state.json
         
         GIT COMMIT: {commit_hash}
         
         TODO.md and state.json are now synchronized.
         ```
      
      2. Clean up temporary files:
         - rm /tmp/todo_blame_$session_id.txt
         - rm /tmp/state_blame_$session_id.txt
         - rm /tmp/TODO.md.backup.$session_id
         - rm /tmp/state.json.backup.$session_id
      
      3. Exit with status 0
    </process>
    <checkpoint>Results displayed, cleanup complete</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
/sync                  # Apply synchronization
/sync --dry-run        # Preview changes without applying
```

## What This Does

1. **Validates files and git repository**
   - Ensures TODO.md and state.json are tracked in git
   - Checks for uncommitted changes (warns if found)
   - Creates backups before synchronization

2. **Extracts tasks and field locations**
   - Parses TODO.md to find all task entries and field line numbers
   - Parses state.json to find all tasks and field line numbers
   - Builds task index mapping task numbers to fields

3. **Gets git blame timestamps for each field**
   - Uses `git blame --line-porcelain` to get commit timestamps
   - Caches blame output for performance
   - Falls back to file mtime for uncommitted changes

4. **Detects field-level discrepancies**
   - Compares each field (status, priority, effort, language, description)
   - Normalizes values for comparison (e.g., [PLANNED] ↔ planned)
   - Identifies tasks present in only one file

5. **Resolves conflicts using git blame timestamps**
   - Compares timestamps for each mismatched field
   - Prefers field with most recent git blame timestamp
   - Provides surgical precision (each field resolved independently)

6. **Applies updates atomically**
   - Delegates to status-sync-manager for atomic updates
   - Updates both files using two-phase commit protocol
   - Rolls back on failure

7. **Creates git commit**
   - Delegates to git-workflow-manager
   - Commits both files with descriptive message
   - Warns if commit fails (but doesn't rollback valid changes)

8. **Reports results**
   - Displays field-level changes made
   - Shows git blame timestamps and reasons
   - Confirms synchronization success

## Dry-Run Mode

Use `--dry-run` to preview changes without applying them:

```bash
/sync --dry-run
```

This displays:
- All field-level discrepancies detected
- Git blame timestamps for each field
- Resolution decisions (which file's value will be used)
- Summary of changes that would be applied

## Examples

```bash
# Apply synchronization
/sync

# Preview changes without applying
/sync --dry-run

# Example output (dry-run):
SYNC PREVIEW (--dry-run mode)

DISCREPANCIES DETECTED: 3

FIELD-LEVEL UPDATES:
- Task 296, field status: [PLANNED] → [IMPLEMENTING]
  Source: state.json (modified 2026-01-05 09:30:00, commit abc123)
  Reason: state.json field modified more recently

- Task 297, field priority: high → medium
  Source: TODO.md (modified 2026-01-05 10:15:00, commit def456)
  Reason: TODO.md field modified more recently

TASK ADDITIONS:
- Task 298: Add to state.json
  Source: TODO.md
  Reason: Task exists in TODO.md but not in state.json

SUMMARY:
- 1 field to update in TODO.md
- 1 field to update in state.json
- 0 tasks to add to TODO.md
- 1 task to add to state.json

Run without --dry-run to apply changes.
```

## Error Handling

**Not a Git Repository:**
```
Error: Not a git repository. Git history required for sync.
```

**Files Not Tracked:**
```
Error: TODO.md not tracked in git.
Run: git add .opencode/specs/TODO.md && git commit
```

**Uncommitted Changes:**
```
Warning: Uncommitted changes detected in TODO.md.
Commit before sync for accurate timestamps.
Falling back to file mtime for uncommitted lines.
```

**Malformed JSON:**
```
Error: state.json is malformed. Fix JSON syntax before sync.
```

**Synchronization Failure:**
```
Error: Synchronization failed. Restoring from backups.
Reason: status-sync-manager returned failed status
```

## Git Blame-Based Conflict Resolution

The /sync command uses git blame to determine which file has the most recent change to each specific field. This provides surgical precision in conflict resolution.

**Example:**
- TODO.md file modified at 2026-01-05 10:00:00 (typo fix in description)
- state.json file modified at 2026-01-05 09:00:00 (status update)

**File-level comparison (naive approach):**
- Would prefer ALL fields from TODO.md (newer file mtime)
- Would incorrectly overwrite recent status change in state.json

**Git blame field-level comparison (this approach):**
- Status field in TODO.md: last modified 2026-01-05 08:00:00
- Status field in state.json: last modified 2026-01-05 09:00:00
- Resolution: Prefer state.json status (newer field timestamp)
- Description field in TODO.md: last modified 2026-01-05 10:00:00
- Description field in state.json: last modified 2026-01-05 07:00:00
- Resolution: Prefer TODO.md description (newer field timestamp)
- **Result:** Each field resolved independently based on its own modification history

## Performance

- Git blame caching: ~50-100ms per file (one-time cost)
- Field extraction: ~10ms per task
- Conflict resolution: ~1ms per field
- Total: ~200-500ms for typical TODO.md with 50-100 tasks

## Limitations

- Requires git repository with commit history
- Requires files tracked in git (not newly created)
- Falls back to file mtime for uncommitted changes (less accurate)
- Does not synchronize archived tasks (only active_projects)
- Does not synchronize plan files or other artifacts

## Related Commands

- `/abandon` - Mark tasks as [ABANDONED]
- `/task` - Create new tasks
- `/implement` - Implement tasks
- `/research` - Research tasks
- `/plan` - Plan tasks
