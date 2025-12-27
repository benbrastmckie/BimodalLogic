---
name: todo
agent: orchestrator
description: "Maintain TODO.md (clean completed/abandoned tasks)"
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
    TODO.md maintenance workflow that cleans completed and abandoned tasks while
    preserving task numbering and state synchronization.
  </system_context>
  <domain_context>
    Task list cleanup with user confirmation for bulk removals. Maintains consistency
    between TODO.md and state.json.
  </domain_context>
  <task_context>
    Clean completed and abandoned tasks from TODO.md, update state.json, preserve
    task numbering, and commit cleanup.
  </task_context>
  <execution_context>
    Atomic updates to TODO.md and state.json. User confirmation for bulk removals
    (threshold: 5 tasks). Git commit after cleanup.
  </execution_context>
</context>

<role>TODO Maintenance Command - Clean completed and abandoned tasks</role>

<task>
  Clean completed and abandoned tasks from TODO.md, update state.json atomically,
  preserve task numbering, and commit cleanup.
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

  <stage id="2" name="ConfirmRemoval">
    <action>Confirm removal with user if threshold exceeded</action>
    <process>
      1. Count tasks to remove
      2. If count > 5:
         a. Display list of tasks to remove
         b. Request user confirmation
         c. Wait for confirmation (yes/no)
         d. Abort if user declines
      3. If count <= 5:
         a. Proceed without confirmation
    </process>
    <confirmation_threshold>
      Threshold: 5 tasks
      
      If removing > 5 tasks:
        - Display task list
        - Request confirmation
        - Abort if declined
      
      If removing <= 5 tasks:
        - Proceed automatically
    </confirmation_threshold>
  </stage>

  <stage id="3" name="PrepareUpdates">
    <action>Prepare TODO.md and state.json updates</action>
    <process>
      1. Create updated TODO.md content:
         a. Remove [COMPLETED] tasks
         b. Remove [ABANDONED] tasks
         c. Preserve all other tasks
         d. Preserve task numbering (do not renumber)
      2. Create updated state.json content:
         a. Remove entries for removed tasks
         b. Preserve entries for remaining tasks
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

  <stage id="4" name="AtomicUpdate">
    <action>Atomically update TODO.md and state.json</action>
    <process>
      1. Backup current TODO.md and state.json
      2. Write updated TODO.md
      3. Verify TODO.md write successful
      4. Write updated state.json
      5. Verify state.json write successful
      6. If any write fails:
         a. Rollback both files from backup
         b. Return error
      7. If both writes succeed:
         a. Delete backups
         b. Proceed to git commit
    </process>
    <atomic_guarantee>
      Two-phase commit:
        1. Prepare: Validate updates in memory
        2. Commit: Write both files or rollback
      
      All or nothing: Both files updated or neither updated
    </atomic_guarantee>
  </stage>

  <stage id="5" name="GitCommit">
    <action>Commit cleanup</action>
    <process>
      1. Stage TODO.md and state.json
      2. Create commit:
         - Message: "todo: clean {N} completed/abandoned tasks"
      3. If commit fails:
         a. Log error to errors.json
         b. Continue (commit failure non-critical)
    </process>
    <git_commit>
      Scope: TODO.md + state.json
      Message: "todo: clean {N} completed/abandoned tasks"
      
      Use git-workflow-manager for scoped commit
    </git_commit>
  </stage>

  <stage id="6" name="ReturnSuccess">
    <action>Return summary to user</action>
    <return_format>
      TODO.md cleaned
      - Tasks removed: {count}
      - Completed: {completed_count}
      - Abandoned: {abandoned_count}
      - Remaining tasks: {remaining_count}
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
    Gaps in numbering are acceptable
  </numbering_preservation>
  <atomic_updates>
    Use two-phase commit for TODO.md and state.json
    All or nothing guarantee
  </atomic_updates>
  <user_confirmation>
    Request confirmation if removing > 5 tasks
    Display task list before removal
  </user_confirmation>
  <no_emojis>
    No emojis in output or commit messages
  </no_emojis>
</quality_standards>

<usage_examples>
  - `/todo` (clean completed and abandoned tasks)
</usage_examples>

<validation>
  <pre_flight>
    - TODO.md loaded successfully
    - Tasks to remove identified
    - User confirmation obtained (if needed)
  </pre_flight>
  <mid_flight>
    - Updates prepared in memory
    - Validation passed
    - Backups created
  </mid_flight>
  <post_flight>
    - TODO.md updated
    - state.json updated
    - Task numbering preserved
    - Git commit created
  </post_flight>
</validation>

<error_handling>
  <file_read_failure>
    If TODO.md or state.json cannot be read:
      - Return error
      - Provide file path
      - Recommend manual check
  </file_read_failure>
  <file_write_failure>
    If TODO.md or state.json write fails:
      - Rollback both files from backup
      - Return error with details
      - Recommend retry
  </file_write_failure>
  <user_declined>
    If user declines confirmation:
      - Abort cleanup
      - Return message: "Cleanup aborted by user"
  </user_declined>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
