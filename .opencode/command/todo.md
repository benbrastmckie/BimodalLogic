---
name: todo
agent: orchestrator
description: "Maintain .opencode/specs/TODO.md (archive completed/abandoned tasks)"
context_level: 1
language: markdown
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/state-management.md"  # For status markers and state schemas
    - "core/orchestration/state-management.md"  # For directory operations
    - "core/orchestration/state-lookup.md"      # Fast state.json queries
  data_files:
    - ".opencode/specs/TODO.md"          # Main TODO file
    - ".opencode/specs/state.json"       # State tracking
    - ".opencode/specs/archive/state.json"  # Archive state (lazy-created)
  max_context_size: 50000
---

<context>
  <system_context>
    .opencode/specs/TODO.md maintenance workflow that archives completed and abandoned tasks while
    preserving task numbering, state synchronization, and all project artifacts.
  </system_context>
  <domain_context>
    Task archival with user confirmation for bulk operations. Maintains consistency
    between .opencode/specs/TODO.md, state.json, and archive/state.json. Moves project directories to archive.
  </domain_context>
  <task_context>
    Archive completed and abandoned tasks from .opencode/specs/TODO.md, move project directories to archive,
    update state.json and archive/state.json, preserve task numbering, and commit archival.
  </task_context>
  <execution_context>
    Atomic updates across 4 entities (.opencode/specs/TODO.md, state.json, archive/state.json, project directories).
    User confirmation for bulk operations (threshold: 5 tasks). Two-phase commit with rollback.
    Self-healing for missing archive infrastructure. Git commit after archival.
  </execution_context>
</context>

<role>TODO Maintenance Command - Archive completed and abandoned tasks</role>

<task>
  Archive completed and abandoned tasks from .opencode/specs/TODO.md, move project directories to archive,
  update state.json and archive/state.json atomically, preserve task numbering and all
  artifacts, and commit archival changes.
</task>

<workflow_execution>
  <stage id="1" name="ScanState">
    <action>Query state.json for completed and abandoned tasks (optimized)</action>
    <process>
      1. Validate state.json exists and is valid JSON:
         - Check file exists: .opencode/specs/state.json
         - Validate JSON structure
         - If invalid: abort with error
      2. Query completed tasks (fast, ~5ms):
         completed_tasks=$(jq -r '.active_projects[] | select(.status == "completed") | .project_number' .opencode/specs/state.json)
      3. Query abandoned tasks (fast, ~5ms):
         abandoned_tasks=$(jq -r '.active_projects[] | select(.status == "abandoned") | .project_number' .opencode/specs/state.json)
      4. Get metadata for archival (fast, ~5ms):
         archival_data=$(jq -r '.active_projects[] | select(.status == "completed" or .status == "abandoned") | 
           {project_number, project_name, status, completed, abandoned, abandonment_reason}' .opencode/specs/state.json)
      5. Count total tasks to archive
      6. Prepare archival list with metadata
    </process>
    <identification>
      Tasks to archive (from state.json):
        - status == "completed"
        - status == "abandoned"
      
      Tasks to keep (from state.json):
        - status == "not_started"
        - status == "in_progress"
        - status == "researched"
        - status == "planned"
        - status == "blocked"
    </identification>
    <validation>
      - state.json exists and is readable
      - JSON structure is valid
      - Query returns valid task numbers
      - Metadata extraction succeeds
    </validation>
  </stage>

  <stage id="2" name="ConfirmArchival">
    <action>Confirm archival with user if threshold exceeded</action>
    <process>
      1. Count tasks to archive
      2. If count > 5:
         a. Display list of tasks to archive
         b. Request user confirmation
         c. Wait for confirmation (yes/no)
         d. Abort if user declines
      3. If count <= 5:
         a. Proceed without confirmation
    </process>
    <confirmation_threshold>
      Threshold: 5 tasks
      
      If archiving > 5 tasks:
        - Display task list
        - Request confirmation
        - Abort if declined
      
      If archiving <= 5 tasks:
        - Proceed automatically
    </confirmation_threshold>
  </stage>

  <stage id="3" name="GitPreCommit">
    <action>Auto-commit uncommitted changes and create pre-cleanup git snapshot</action>
    <process>
      1. Check git status:
         - Run: git status --porcelain
         - If merge in progress: Abort with error
         - Run: git symbolic-ref -q HEAD
         - If detached HEAD: Abort with error
      2. Auto-commit uncommitted changes (if any):
         - If dirty working tree (uncommitted changes):
           a. Stage all changes: git add .
           b. Create commit with message: "Auto-commit before archiving {N} completed/abandoned tasks"
           c. If commit fails: Abort archival with error
      3. Stage TODO/state files:
         - git add .opencode/specs/TODO.md
         - git add .opencode/specs/state.json
         - git add .opencode/specs/archive/state.json
      4. Create pre-cleanup snapshot commit:
         - Message: "todo: snapshot before archiving {N} tasks (task 253)"
         - Example: "todo: snapshot before archiving 5 tasks (task 253)"
      5. If snapshot commit fails:
         - Log error with details
         - Abort archival
         - Return error: "Failed to create pre-cleanup snapshot"
    </process>
    <error_handling>
      If merge in progress:
        - Return error: "Merge in progress. Resolve merge before running /todo"
        - Abort archival
      
      If detached HEAD:
        - Return error: "Detached HEAD detected. Checkout branch before running /todo"
        - Abort archival
      
      If auto-commit fails:
        - Return error: "Failed to auto-commit changes: {error_details}"
        - Abort archival
      
      If snapshot commit fails:
        - Return error: "Failed to create pre-cleanup snapshot: {error_details}"
        - Abort archival
    </error_handling>
  </stage>

  <stage id="4" name="RunCleanupScript">
    <action>Execute dedicated cleanup script with archival list (optimized)</action>
    <process>
      1. Prepare task list from Stage 1 (ScanState):
         - Extract task numbers from archival_data
         - Format as comma-separated list: "250,251,252,253,254"
      2. Execute script with task list:
         - Command: python3 .opencode/scripts/todo_cleanup.py --tasks "{task_list}"
         - Pass archival list to avoid re-scanning TODO.md
         - Capture stdout, stderr, exit code
         - Timeout: 120 seconds
      3. Check exit code:
         - 0: Success, proceed to GitPostCommit
         - 1: Validation error, rollback git commit, abort
         - 2: File I/O error, rollback git commit, abort
         - 3: Argument error, rollback git commit, abort
      4. On failure:
         - Rollback: git reset --hard HEAD~1
         - Verify rollback succeeded
         - Return error with script output
          - Include exit code and error type
    </process>
    <rollback_on_failure>
      If script fails (exit code != 0):
        1. Rollback pre-cleanup commit:
           - git reset --hard HEAD~1
        2. Verify rollback:
           - Check .opencode/specs/TODO.md matches pre-archival state
           - Check state.json matches pre-archival state
        3. Log error to errors.json:
           - Event: "todo_cleanup_script_failed"
           - Exit code: {exit_code}
           - Script output: {stdout + stderr}
        4. Return error to user:
           - "Cleanup script failed with exit code {exit_code}"
           - "System rolled back to pre-archival state"
           - "Script output: {script_output}"
    </rollback_on_failure>
  </stage>

  <stage id="5" name="GitPostCommit">
    <action>Commit archival changes</action>
    <process>
      1. Stage files:
         - git add .opencode/specs/TODO.md
         - git add .opencode/specs/state.json
         - git add .opencode/specs/archive/state.json
         - git add .opencode/specs/archive/  (pick up moved directories)
      2. Verify staged changes:
         - git status --short
       3. Create commit:
          - Message format: "todo: archive {N} completed/abandoned tasks (task 253)"
          - Examples:
           * "todo: archive 2 completed tasks (task 253)"
           * "todo: archive 5 completed/abandoned tasks (task 253)"
           * "todo: archive 1 abandoned task (task 253)"
       4. If commit fails:
          - Log error to errors.json
          - Continue (commit failure non-critical)
          - Archival already complete
          - Return success with warning about git failure
    </process>
    <git_commit>
      Scope: .opencode/specs/TODO.md + state.json + archive/state.json + moved directories
      Message: "todo: archive {N} completed/abandoned tasks (task 253)"
      
      Use git-workflow-manager for scoped commit
    </git_commit>
  </stage>

  <stage id="6" name="ReturnSuccess">
    <action>Return comprehensive archival summary</action>
    <return_format>
      .opencode/specs/TODO.md archival complete
      
      Tasks archived: {total_count}
      - Completed: {completed_count}
      - Abandoned: {abandoned_count}
      
      {if any directories moved:}
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
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 1 (Isolated) - Simple cleanup, minimal context needed
  </context_allocation>
  <no_delegation>
    No subagent delegation required
    Direct file manipulation by command
  </no_delegation>
</routing_intelligence>

<quality_standards>
  <numbering_preservation>
    NEVER renumber tasks
    Gaps in numbering are acceptable and expected
  </numbering_preservation>
  <atomic_updates>
    Use two-phase commit for 4 entities:
      - .opencode/specs/TODO.md
      - state.json
      - archive/state.json
      - Project directories
    All or nothing guarantee with comprehensive rollback
  </atomic_updates>
  <artifact_preservation>
    Preserve all project artifacts during archival
    Move entire project directories to archive
    No data loss permitted
  </artifact_preservation>
  <self_healing>
    Auto-create archive/state.json from template if missing
    Lazy creation: .opencode/specs/archive/ created only when needed
  </self_healing>
  <user_confirmation>
    Request confirmation if archiving > 5 tasks
    Display task list before archival
  </user_confirmation>

</quality_standards>

<usage_examples>
  - `/todo` (archive completed and abandoned tasks with artifacts)
</usage_examples>

<validation>
  <pre_flight>
    - .opencode/specs/TODO.md loaded successfully
    - state.json loaded successfully
    - Tasks to archive identified
    - archive/state.json exists or created (self-healing)
    - User confirmation obtained (if needed)
  </pre_flight>
  <mid_flight>
    - Git pre-cleanup snapshot created
    - Cleanup script executed successfully
    - .opencode/specs/TODO.md updated (tasks removed, dividers fixed)
    - state.json and archive/state.json updated
    - Project directories moved to archive
  </mid_flight>
  <post_flight>
    - .opencode/specs/TODO.md updated (tasks removed)
    - state.json updated (tasks moved to completed_projects, metrics updated)
    - archive/state.json updated (new archive entries)
    - Project directories moved to archive
    - Task numbering preserved
    - All artifacts preserved
    - Git commit created
  </post_flight>
</validation>

<error_handling>
  <no_tasks_to_archive>
    If .opencode/specs/TODO.md has no [COMPLETED] or [ABANDONED] tasks:
      - Return early
      - Message: "No tasks to archive"
      - No changes made
  </no_tasks_to_archive>
  <file_read_failure>
    If .opencode/specs/TODO.md or state.json cannot be read:
      - Return error
      - Provide file path
      - Recommend manual check
      - Do not proceed with archival
  </file_read_failure>
  <file_write_failure>
    If any file write fails (.opencode/specs/TODO.md, state.json, archive/state.json):
      - Rollback using git: git reset --hard HEAD~1
      - Verify rollback succeeded
      - Log error to errors.json with failure details
      - Return error with rollback confirmation
      - Recommend retry
  </file_write_failure>
  <directory_move_failure>
    If directory move fails (permissions, disk space, etc.):
      - Rollback using git: git reset --hard HEAD~1
      - Verify rollback succeeded
      - Log error to errors.json with failure details
      - Return error: "Failed to move {src} to {dst}: {reason}"
      - Recommend checking permissions/disk space
  </directory_move_failure>
  <user_declined>
    If user declines confirmation:
      - Abort archival
      - Return message: "Archival aborted by user"
      - No changes made
  </user_declined>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Archival already complete
      - Return success with warning about git failure
  </git_commit_failure>
  <rollback_failure>
    If rollback itself fails (critical):
      - Log critical error to errors.json
      - Provide manual recovery instructions
      - Recommend: git reset --hard HEAD~2 (undo both commits)
      - Or: git reflog to find pre-archival state
      - Include session details for debugging
  </rollback_failure>
</error_handling>
