---
name: errors
agent: orchestrator
description: "Analyze errors.json, create fix plans, track fix effectiveness"
context_level: 2
language: markdown
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/delegation.md"     # For delegation patterns and return format
    - "core/system/state-management.md"  # For status markers
    - "common/system/git-commits.md"     # For git commit patterns
  data_files:
    - ".opencode/specs/errors.json"      # Error log
    - ".opencode/specs/TODO.md"          # For creating fix tasks
    - ".opencode/specs/state.json"       # State tracking
  max_context_size: 50000
---

**Task Input (optional):** $ARGUMENTS (optional flags; e.g., `/errors`, `/errors --all`, `/errors --type delegation_hang`)

<context>
  <system_context>
    Error analysis workflow that analyzes errors.json, creates fix plans, tracks
    fix effectiveness, and creates TODO tasks for error resolution.
  </system_context>
  <domain_context>
    Error diagnostics for all error types: delegation_hang, tool_failure,
    status_sync_failure, build_error, git_commit_failure. Tracks recurrence
    and fix effectiveness.
  </domain_context>
  <task_context>
    Analyze errors.json, group by type and root cause, check for recurring errors,
    create fix plan, create TODO task, update errors.json with fix references,
    and commit updates.
  </task_context>
  <execution_context>
    Lazy directory creation (specs/NNN_error_fix/plans/ only when writing).
    Atomic errors.json updates. Git commit after fix plan creation.
  </execution_context>
</context>

<role>Error Analysis Command - Analyze errors and create fix plans</role>

<task>
  Analyze errors.json, create fix plans for error groups, create TODO tasks,
  update errors.json with fix references, and commit updates.
</task>

<workflow_execution>
  <stage id="1" name="LoadErrors">
    <action>Load and parse errors.json</action>
    <process>
      1. Load errors.json
      2. Parse error entries
      3. Filter errors based on flags:
         - Default: not_addressed errors only
         - --all: All errors
         - --type {type}: Specific error type only
      4. Group errors by type and root cause
      5. Check for recurring errors
    </process>
    <filtering>
      Default filter: fix_status == "not_addressed"
      
      --all flag: Include all errors
      --type {type} flag: Filter to specific type
      
      Error types:
        - delegation_hang
        - tool_failure
        - status_sync_failure
        - build_error
        - git_commit_failure
    </filtering>
    <grouping>
      Group errors by:
        1. Error type (delegation_hang, etc.)
        2. Root cause (similar stack traces, contexts)
        3. Recurrence (same error multiple times)
    </grouping>
  </stage>

  <stage id="2" name="CheckRecurrence">
    <action>Check if errors recurred after fixes</action>
    <process>
      1. For each error group:
         a. Check if similar errors have fix_status == "fix_attempted"
         b. Compare timestamps:
            - fix_attempted_date from errors.json
            - last_seen date from current error
         c. If last_seen > fix_attempted_date:
            - Mark fix as failed (error recurred)
            - Log fix effectiveness: failed
         d. If last_seen < fix_attempted_date:
            - Fix appears successful
            - Log fix effectiveness: successful
      2. Prepare recurrence report
    </process>
    <recurrence_logic>
      For each error:
        1. Find similar errors with fix_attempted
        2. Compare timestamps
        3. Determine if fix was effective
        4. Mark fix_status accordingly:
           - "resolved" if no recurrence
           - "not_addressed" if recurred (fix failed)
    </recurrence_logic>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context for error-diagnostics agent</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1 (orchestrator → errors → error-diagnostics)
      3. Set delegation_path = ["orchestrator", "errors", "error-diagnostics"]
      4. Set timeout = 1800s (30 minutes for error analysis)
      5. Store session_id for validation
      6. Prepare error analysis context (grouped errors, recurrence info)
    </process>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "errors", "error-diagnostics"],
        "timeout": 1800,
        "error_context": {
          "error_groups": [{grouped_errors}],
          "recurrence_info": [{recurrence_data}],
          "historical_fixes": [{fix_attempted_errors}]
        }
      }
    </delegation_context>
  </stage>

  <stage id="4" name="InvokeErrorDiagnostics">
    <action>Invoke error-diagnostics agent to analyze</action>
    <process>
      1. Route to error-diagnostics agent
      2. Pass delegation context
      3. Pass grouped errors
      4. Pass historical fix_attempted errors
      5. Request root cause analysis
      6. Request fix recommendations
      7. Set timeout to 1800s
    </process>
    <invocation>
      task_tool(
        subagent_type="error-diagnostics",
        prompt="Analyze {N} error groups and recommend fixes",
        session_id=delegation_context["session_id"],
        delegation_depth=1,
        delegation_path=delegation_context["delegation_path"],
        timeout=1800,
        error_groups=grouped_errors,
        historical_fixes=fix_attempted_errors
      )
    </invocation>
  </stage>

  <stage id="5" name="ReceiveAnalysis">
    <action>Receive error analysis results</action>
    <process>
      1. Poll for completion (max 1800s)
      2. Receive return object from error-diagnostics
      3. Validate against subagent-return-format.md
      4. Check session_id matches expected
      5. Handle timeout gracefully
    </process>
    <timeout_handling>
      If timeout (no response after 1800s):
        1. Log timeout error with session_id
        2. Return partial status
        3. Provide retry instructions
    </timeout_handling>
    <validation>
      1. Validate return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches
      4. Validate status is valid enum
      5. Extract root cause analysis
      6. Extract fix recommendations
    </validation>
  </stage>

  <stage id="6" name="CreateFixPlan">
    <action>Create implementation plan for error fixes</action>
    <process>
      1. Invoke planner with error analysis
      2. Pass error groups and fix recommendations
      3. Request plan creation in specs/NNN_error_fix/plans/
      4. Include all error IDs being addressed
      5. Receive plan path from planner
    </process>
    <plan_creation>
      Plan structure:
        - Overview: Error summary and impact
        - Error Groups: Grouped by type and root cause
        - Fix Recommendations: From error-diagnostics
        - Phases: Fix implementation phases
        - Success Criteria: Error resolution verification
    </plan_creation>
  </stage>

  <stage id="7" name="CreateTODOTask">
    <action>Create task in .opencode/specs/TODO.md linking fix plan</action>
    <process>
      1. Invoke /task command to create task
      2. Task description: "Fix {N} {error_type} errors"
      3. Add plan link to task
      4. Add error IDs to task notes
      5. Set priority based on error severity:
         - Critical errors → Priority: Critical
         - High severity → Priority: High
         - Medium/Low → Priority: Medium
      6. Receive task number
    </process>
    <task_format>
      ### {number}. Fix {N} {error_type} errors
      - **Effort**: TBD
      - **Status**: [NOT STARTED]
      - **Priority**: {Critical|High|Medium}
      - **Language**: {language}
      - **Plan**: {plan_path}
      - **Errors**: {error_ids}
    </task_format>
  </stage>

  <stage id="8" name="UpdateErrorsJson">
    <action>Update errors.json with fix references</action>
    <process>
      1. Load errors.json
      2. For each error in addressed groups:
         a. Set fix_status = "fix_attempted"
         b. Set fix_plan_ref = plan_path
         c. Set fix_task_ref = task_number
         d. Preserve all other error fields
      3. Write updated errors.json atomically
    </process>
    <atomic_update>
      Use atomic write to prevent race conditions
      Backup errors.json before writing
      Rollback on write failure
    </atomic_update>
  </stage>

  <stage id="9" name="GitCommit">
    <action>Commit updates</action>
    <process>
      1. Stage errors.json, .opencode/specs/TODO.md, state.json, plan file
      2. Create commit:
         - Message: "errors: create fix plan for {N} {type} errors (task {number})"
      3. If commit fails:
         a. Log error to errors.json
         b. Continue (commit failure non-critical)
    </process>
    <git_commit>
      Scope: errors.json + .opencode/specs/TODO.md + state.json + plan file
      Message: "errors: create fix plan for {N} {type} errors (task {number})"
      
      Use git-workflow-manager for scoped commit
    </git_commit>
  </stage>

  <stage id="10" name="ReturnSuccess">
    <action>Return summary to user</action>
    <return_format>
      Error analysis completed
      - Errors analyzed: {count}
      - Error groups: {group_count}
      - Fix plan created: {plan_path}
      - TODO task created: {task_number}
      - Errors updated with fix references
      
      Error breakdown:
        - {type_1}: {count_1} errors
        - {type_2}: {count_2} errors
        ...
      
      Recurrence check:
        - Recurring errors: {recurring_count}
        - Failed fixes: {failed_fix_count}
    </return_format>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Error analysis requires project context
  </context_allocation>
  <error_grouping>
    Group errors by type and root cause
    Identify recurring errors
    Check fix effectiveness
  </error_grouping>
</routing_intelligence>

<artifact_management>
  <lazy_creation>
    Do not create specs/NNN_error_fix/ until writing fix plan
    Create only plans/ subdirectory when writing plan
  </lazy_creation>
  <artifact_naming>
    Fix plans: specs/NNN_error_fix/plans/implementation-001.md
    Error analysis: Included in plan Overview section
  </artifact_naming>
  <state_sync>
    Update errors.json with fix references
    Update .opencode/specs/TODO.md with fix task
    Update state.json with new task
  </state_sync>
</artifact_management>

<quality_standards>
  <error_grouping>
    Group errors intelligently by type and root cause
    Identify patterns and recurring issues
  </error_grouping>
  <fix_effectiveness>
    Track fix effectiveness by checking recurrence
    Mark failed fixes appropriately
  </fix_effectiveness>

  <atomic_updates>
    Use atomic write for errors.json updates
  </atomic_updates>
</quality_standards>

<usage_examples>
  - `/errors` (analyze unaddressed errors)
  - `/errors --all` (analyze all errors)
  - `/errors --type delegation_hang` (analyze specific type)
</usage_examples>

<validation>
  <pre_flight>
    - errors.json loaded successfully
    - Errors filtered and grouped
    - Recurrence checked
  </pre_flight>
  <mid_flight>
    - Error-diagnostics invoked successfully
    - Return validated against subagent-return-format.md
    - Session ID matches expected
    - Fix plan created
    - TODO task created
  </mid_flight>
  <post_flight>
    - errors.json updated with fix references
    - .opencode/specs/TODO.md updated with fix task
    - state.json synchronized
    - Git commit created
  </post_flight>
</validation>

<error_handling>
  <no_errors_found>
    If no errors match filter:
      - Return message: "No errors found matching filter"
      - Suggest using --all flag
      - Abort analysis
  </no_errors_found>
  <timeout>
    If error-diagnostics times out after 1800s:
      - Return partial status
      - Provide retry instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error
      - Return failed status
      - Recommend subagent fix
  </validation_failure>
  <plan_creation_failure>
    If fix plan creation fails:
      - Log error
      - Return failed status
      - Provide error details
  </plan_creation_failure>
  <task_creation_failure>
    If TODO task creation fails:
      - Log error
      - Continue with errors.json update
      - Note task creation failure in summary
  </task_creation_failure>
  <errors_json_update_failure>
    If errors.json update fails:
      - Rollback from backup
      - Return error with details
      - Recommend retry
  </errors_json_update_failure>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
