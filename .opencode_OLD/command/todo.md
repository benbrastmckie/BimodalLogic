---
name: todo
agent: orchestrator
description: "Maintain .opencode/specs/TODO.md (archive completed/abandoned tasks)"
context_level: 1
language: markdown
routing:
  target_agent: todo-manager
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/state-management.md"
    - "core/standards/git-safety.md"
  max_context_size: 10000
---

**Task Input (optional):** $ARGUMENTS

<context>
  <system_context>TODO.md maintenance workflow for archiving completed/abandoned tasks</system_context>
  <task_context>Archive tasks, move project directories, update state files atomically</task_context>
  <execution_context>User confirmation for bulk ops (>5 tasks), two-phase commit with rollback</execution_context>
</context>

<role>TODO Maintenance Command - Archive completed and abandoned tasks</role>

<task>
  Parse arguments, validate files, delegate to todo-manager, handle user confirmation, relay results
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse arguments and validate files</action>
    <process>
      1. Parse flags from $ARGUMENTS:
         - --dry-run: Preview without changes
         - --force: Skip confirmation (future)
      
      2. Validate files:
         - Check .opencode/specs/TODO.md exists
         - Check .opencode/specs/state.json exists and is valid JSON
         - If missing/corrupt: Return error "Run /meta to regenerate state.json"
      
      3. Count tasks to archive:
         completed=$(jq -r '[.active_projects[] | select(.status == "completed")] | length' .opencode/specs/state.json)
         abandoned=$(jq -r '[.active_projects[] | select(.status == "abandoned")] | length' .opencode/specs/state.json)
         total=$((completed + abandoned))
      
      4. Early return if zero:
         - If total == 0: Display "No tasks to archive" and return
      
      5. Display preview:
         "Found {total} tasks to archive: {completed} completed, {abandoned} abandoned"
    </process>
    <checkpoint>Files validated, task count determined</checkpoint>
  </stage>

  <stage id="2" name="Delegate">
    <action>Delegate to todo-manager subagent</action>
    <process>
      1. Generate session_id:
         session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
      
      2. Prepare delegation context:
         {
           "session_id": "{session_id}",
           "delegation_depth": 1,
           "delegation_path": ["orchestrator", "todo", "todo-manager"],
           "confirmation_provided": false,
           "dry_run": {dry_run_flag}
         }
      
      3. Invoke todo-manager:
         task(subagent_type="todo-manager", prompt="{context}", description="Archive tasks")
      
      4. Wait for return (timeout: 300s)
    </process>
    <checkpoint>todo-manager invoked, return received</checkpoint>
  </stage>

  <stage id="3" name="ValidateReturn">
    <action>Validate return and handle user confirmation</action>
    <process>
      1. Parse return as JSON and validate fields:
         - status: "completed", "awaiting_confirmation", "cancelled", or "failed"
         - summary, metadata, archival_summary required
      
      2. Handle status cases:
         
         a. awaiting_confirmation:
            - Display task list: "The following {count} tasks will be archived:"
            - For each: "  - Task {number}: {title} [{status}]"
            - Request confirmation: "Archive these tasks? (yes/no): "
            - If declined: Display "Archival aborted by user" and return
            - If confirmed: Re-invoke todo-manager with confirmation_provided=true
         
         b. completed:
            - Proceed to Stage 4
         
         c. cancelled:
            - Display "Archival cancelled" and return
         
         d. failed:
            - Display error details and return error
      
      3. Validate archival_summary (if completed):
         - Check required fields: tasks_archived, completed_count, abandoned_count
    </process>
    <checkpoint>Return validated, confirmation handled</checkpoint>
  </stage>

  <stage id="4" name="RelayResult">
    <action>Format and display archival summary</action>
    <process>
      1. Extract from archival_summary:
         - tasks_archived, completed_count, abandoned_count
         - directories_moved, tasks_without_directories
         - remaining_active_tasks, archive_location
      
      2. Format summary:
         .opencode/specs/TODO.md archival complete
         
         Tasks archived: {total}
         - Completed: {completed}
         - Abandoned: {abandoned}
         
         {if directories_moved:}
         Project directories moved:
         {for each:} - {dir} → archive/{dir}
         
         {if tasks_without_directories:}
         Tasks without directories: {count}
         {for each:} - Task {number}: {title}
         
         Remaining active tasks: {remaining}
         Archive location: {location}
      
      3. Display git commit info (if available):
         - "Git commit: {hash}"
         - "Message: {message}"
      
      4. Display warnings (if any)
    </process>
    <checkpoint>Results relayed to user</checkpoint>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 1 (Isolated) - Minimal context</context_allocation>
  <delegation>Delegate to todo-manager for archival execution</delegation>
</routing_intelligence>

<quality_standards>
  <numbering_preservation>NEVER renumber tasks - gaps are acceptable</numbering_preservation>
  <atomic_updates>Two-phase commit via todo-manager with rollback</atomic_updates>
  <artifact_preservation>Move entire project directories, no data loss</artifact_preservation>
  <self_healing>Auto-create archive infrastructure if missing</self_healing>
  <user_confirmation>Request confirmation if archiving >5 tasks</user_confirmation>
</quality_standards>

<usage_examples>
  - `/todo` - Archive completed/abandoned tasks
  - `/todo --dry-run` - Preview without changes
</usage_examples>

<validation>
  <pre_flight>
    - TODO.md and state.json exist and valid
    - Task count determined
    - User confirmation obtained (if needed)
  </pre_flight>
  <post_flight>
    - Archival summary displayed
    - Git commit info shown
    - Warnings displayed (if any)
  </post_flight>
</validation>

<error_handling>
  <no_tasks>Return early with "No tasks to archive"</no_tasks>
  <file_error>Return error with file path and recommendation</file_error>
  <invalid_json>Return "state.json corrupt, run /meta"</invalid_json>
  <timeout>Return "todo-manager timeout after 300s"</timeout>
  <invalid_return>Return "Invalid return format from todo-manager"</invalid_return>
  <user_declined>Display "Archival aborted by user"</user_declined>
  <subagent_failed>Display error details and rollback confirmation</subagent_failed>
</error_handling>
