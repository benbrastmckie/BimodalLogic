---
name: todo
agent: orchestrator
description: "Maintain TODO.md (archive completed/abandoned tasks)"
context_level: 1
language: markdown
---

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/system/git-commits.md

<context>
  <system_context>
    TODO.md maintenance workflow that archives completed and abandoned tasks while
    preserving task numbering, state synchronization, and all project artifacts.
  </system_context>
  <domain_context>
    Task archival with user confirmation for bulk operations. Maintains consistency
    between TODO.md, state.json, and archive/state.json. Moves project directories to archive.
  </domain_context>
  <task_context>
    Archive completed and abandoned tasks from TODO.md, move project directories to archive,
    update state.json and archive/state.json, preserve task numbering, and commit archival.
  </task_context>
  <execution_context>
    Atomic updates across 4 entities (TODO.md, state.json, archive/state.json, project directories).
    User confirmation for bulk operations (threshold: 5 tasks). Two-phase commit with rollback.
    Self-healing for missing archive infrastructure. Git commit after archival.
  </execution_context>
</context>

<role>TODO Maintenance Command - Archive completed and abandoned tasks</role>

<task>
  Archive completed and abandoned tasks from TODO.md, move project directories to archive,
  update state.json and archive/state.json atomically, preserve task numbering and all
  artifacts, and commit archival changes.
</task>

<workflow_execution>
  <stage id="1" name="ScanTODO">
    <action>Scan TODO.md for completed and abandoned tasks</action>
    <process>
      1. Load TODO.md
      2. Parse all task entries
      3. Identify tasks with [COMPLETED] status
      4. Identify tasks with [ABANDONED] status
      5. Count total tasks to remove
      6. Prepare removal list
    </process>
    <identification>
      Tasks to remove:
        - Status: [COMPLETED]
        - Status: [ABANDONED]
      
      Tasks to keep:
        - Status: [NOT STARTED]
        - Status: [IN PROGRESS]
        - Status: [RESEARCHED]
        - Status: [PLANNED]
        - Status: [BLOCKED]
    </identification>
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

  <stage id="3" name="PrepareArchival">
    <action>Prepare project directory moves and archive state updates</action>
    <process>
      1. Ensure archive/state.json exists (self-healing if missing)
      2. Load current archive/state.json
      3. For each task to archive:
         a. Extract task metadata (number, slug, title, status, dates, type)
         b. Build project slug from title (convert to snake_case, max 50 chars)
         c. Check if project directory exists: .opencode/specs/{number}_{slug}/
         d. If exists: Prepare directory move operation
         e. If missing: Log info (task has no artifacts to archive)
         f. Build archive entry for archive/state.json
      4. Prepare archive/state.json updates (append new archive entries)
      5. Validate all operations in memory (paths, metadata, writability)
      6. Store archival context for later stages
    </process>
    <self_healing>
      If archive/state.json does not exist:
        1. Create .opencode/specs/archive/ directory
        2. Write archive/state.json from template:
           {
             "_schema_version": "1.0.0",
             "_comment": "Auto-created with self-healing on first archival",
             "_last_updated": "{current_timestamp}",
             "archived_projects": []
           }
        3. Log self-healing action to main state.json recent_activities
        4. Continue with archival workflow
    </self_healing>
    <archive_entry_format>
      For each task to archive, create entry:
      {
        "project_number": {task_number},
        "project_name": "{slug}",
        "type": "{task_type|'task'}",
        "status": "completed|abandoned",
        "created": "{created_date|'unknown'}",
        "started": "{started_date}",
        "completed": "{completed_date}" (if COMPLETED),
        "abandoned": "{abandoned_date}" (if ABANDONED),
        "archived": "{current_date_YYYY-MM-DD}",
        "summary": "{task_title}",
        "artifacts": {
          "base_path": ".opencode/specs/archive/{number}_{slug}/"
        }
      }
    </archive_entry_format>
    <directory_move_preparation>
      For each task:
        - Build source path: .opencode/specs/{number}_{slug}
        - Build destination path: .opencode/specs/archive/{number}_{slug}
        - Check if source exists
        - If exists: Add to move_operations list
        - If missing: Log info, no move operation
      
      Store move_operations for Stage 5 execution
    </directory_move_preparation>
  </stage>

  <stage id="4" name="PrepareUpdates">
    <action>Prepare TODO.md and state.json updates</action>
    <process>
      1. Create updated TODO.md content:
         a. Remove [COMPLETED] tasks
         b. Remove [ABANDONED] tasks
         c. Preserve all other tasks
         d. Preserve task numbering (do not renumber)
      2. Create updated state.json content:
         a. Move archived tasks from active_projects to completed_projects (with archival metadata)
         b. Preserve entries for remaining active tasks
         c. Update repository_health metrics (reduce active_tasks count)
         d. Add recent_activities entries for each archived task
      3. Validate updates in memory
    </process>
    <numbering_preservation>
      CRITICAL: Do not renumber tasks
      
      If tasks 63, 64, 65 exist and 64 is removed:
        - Keep task 63 as 63
        - Remove task 64
        - Keep task 65 as 65
      
      Gaps in numbering are acceptable and expected
    </numbering_preservation>
  </stage>

  <stage id="5" name="AtomicUpdate">
    <action>Atomically update 4 entities: TODO.md, state.json, archive/state.json, directories</action>
    <process>
      **Phase 1 (Prepare)**:
      1. Backup current state:
         - Backup TODO.md → TODO.md.bak
         - Backup state.json → state.json.bak
         - Backup archive/state.json → archive/state.json.bak
         - No directory backup (rely on git, expensive operation)
      2. Validate all updates are well-formed (JSON parseable, paths valid)
      3. Validate all target paths are writable
      4. If any validation fails:
         - Delete backups
         - Return error with details
         - Abort archival
      
      **Phase 2 (Commit)**:
      1. Write updated TODO.md
      2. Verify write succeeded (file exists, size > 0)
      3. Write updated state.json
      4. Verify write succeeded
      5. Write updated archive/state.json
      6. Verify write succeeded
      7. Move project directories (for each move operation):
         - If src exists: shutil.move(src, dst)
         - Verify move succeeded (dst exists, src removed)
         - On failure: trigger rollback
      8. If any operation fails:
         - Execute rollback_archival()
         - Return error with failure details
      9. On success:
         - Delete backup files
         - Proceed to git commit
    </process>
    <atomic_guarantee>
      Two-phase commit:
        1. Prepare: Validate updates in memory, create backups
        2. Commit: Write 3 files + move directories or rollback all
      
      All or nothing across 4 entities:
        - TODO.md updated or restored
        - state.json updated or restored
        - archive/state.json updated or restored
        - Directories moved or reversed
    </atomic_guarantee>
    <rollback_mechanism>
      rollback_archival():
        1. Restore files from backups:
           - Copy TODO.md.bak → TODO.md
           - Copy state.json.bak → state.json
           - Copy archive/state.json.bak → archive/state.json
        2. Reverse directory moves:
           - For each attempted move:
             - If dst exists and src missing: move(dst, src)
             - Log reversal
        3. Cleanup backup files
        4. Log rollback to errors.json
        5. Return error to user
      
      Rollback guarantees system returns to pre-archival state
    </rollback_mechanism>
  </stage>

  <stage id="6" name="GitCommit">
    <action>Commit archival changes</action>
    <process>
      1. Stage files:
         - git add TODO.md
         - git add .opencode/specs/state.json
         - git add .opencode/specs/archive/state.json
         - git add .opencode/specs/archive/  (pick up moved directories)
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

  <stage id="7" name="ReturnSuccess">
    <action>Return comprehensive archival summary</action>
    <return_format>
      TODO.md archival complete
      
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
      - TODO.md
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
  <no_emojis>
    No emojis in output or commit messages
  </no_emojis>
</quality_standards>

<usage_examples>
  - `/todo` (archive completed and abandoned tasks with artifacts)
</usage_examples>

<validation>
  <pre_flight>
    - TODO.md loaded successfully
    - state.json loaded successfully
    - Tasks to archive identified
    - archive/state.json exists or created (self-healing)
    - User confirmation obtained (if needed)
  </pre_flight>
  <mid_flight>
    - Archival context prepared (archive entries, move operations)
    - TODO.md and state.json updates prepared in memory
    - archive/state.json updates prepared in memory
    - Validation passed (well-formed JSON, valid paths)
    - Backups created
  </mid_flight>
  <post_flight>
    - TODO.md updated (tasks removed)
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
    If TODO.md has no [COMPLETED] or [ABANDONED] tasks:
      - Return early
      - Message: "No tasks to archive"
      - No changes made
  </no_tasks_to_archive>
  <file_read_failure>
    If TODO.md or state.json cannot be read:
      - Return error
      - Provide file path
      - Recommend manual check
      - Do not proceed with archival
  </file_read_failure>
  <file_write_failure>
    If any file write fails (TODO.md, state.json, archive/state.json):
      - Rollback all files from backups
      - Reverse any directory moves
      - Log error to errors.json with failure details
      - Return error with rollback confirmation
      - Recommend retry
  </file_write_failure>
  <directory_move_failure>
    If directory move fails (permissions, disk space, etc.):
      - Rollback all file writes from backups
      - Reverse previous directory moves
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
      - Recommend: git reset --hard HEAD (if git clean)
      - Or: manually restore from .bak files
      - Include session details for debugging
  </rollback_failure>
</error_handling>
