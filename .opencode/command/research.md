---
name: research
agent: orchestrator
description: "Create research reports for TODO task(s) and sync artifacts (supports single, ranges, and lists)"
context_level: 2
language: markdown
subagents:
  - researcher
  - batch-task-orchestrator
  - batch-status-manager
  - status-sync-manager
mcp_requirements:
  - "lean-lsp (Lean research only)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
creates_root_on: "When writing the first research report"
creates_subdir:
  - reports
input_format: "Required: task number(s) - single (e.g., /research 160), range (e.g., /research 132-135), or list (e.g., /research 132,133,134). Reject missing/non-numeric inputs. Error message (no emojis): 'Error: Task number(s) required and must be numeric (e.g., /research 160 or /research 132-135).'"
---

**Task Input (required):** $ARGUMENTS (task number(s); ranges/lists allowed, e.g., `/research 160`, `/research 132-135`, `/research 132,133,134`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/common/standards/tasks.md
@context/common/standards/commands.md
@context/common/standards/patterns.md
@context/common/standards/subagent-return-format.md
@context/common/workflows/task-breakdown.md

<context>
  <system_context>Research command producing reports and linking them to tasks.</system_context>
  <domain_context>TODO tasks and project specs directories.</domain_context>
  <task_context>Conduct research for a specified task, produce reports, and sync TODO/state.</task_context>
  <execution_context>Lazy creation: create project root and reports/ only when writing the first research artifact.</execution_context>
</context>

<role>Research orchestrator coordinating researcher specialists.</role>

<task>Given a task number and optional prompt, generate research report(s), update TODO/state, and maintain status markers.</task>

<workflow_execution>
  <stage id="1" name="ParseInput">
    <action>Validate task numbers</action>
    <process>
      1. Support single numbers, comma-separated lists, and ranges (e.g., `160`, `132,133`, `132-135`). Detect range/list invocations first, normalize to an ordered, de-duplicated task list, and preserve numeric-only validation.
      2. Validate positive integers; deduplicate expanded lists; fail clearly on invalid formats and return bad inputs.
      3. If more than one normalized task remains, classify as batch and route to batch-task-orchestrator; otherwise continue with single-task flow.
    </process>
  </stage>
  <stage id="2" name="ResolveTasks">
    <action>Load TODO entries and detect Lean intent</action>
    <process>
      1. Locate each task in TODO.md; if missing, report and continue.
      2. Detect Lean via TODO `Language` (authoritative) or `--lang`; if Lean, MCP ping `lean-lsp` before proceeding.
      3. Pre-flight: use @subagents/specialists/status-sync-manager to atomically set TODO status to [IN PROGRESS] with **Started** date and state to `in_progress`. No dirs created.
    </process>
  </stage>
  <stage id="3" name="Research">
    <action>Route to researcher(s)</action>
    <process>
      1. Generate unique session_id for tracking: `cmd_research_{task_number}_{timestamp}_{random}`
         - Format: task_number = single task or first in range
         - timestamp = ISO8601 format (e.g., 20251226T143022)
         - random = 6 character alphanumeric
         - Example: `cmd_research_200_20251226T143022_xyz789`
      2. Single task: route to @subagents/researcher directly with session_id.
      3. Multiple tasks: route via @subagents/batch-task-orchestrator with researcher subagent for each task; batch handoff includes normalized task list, language metadata per task, dependency hints, and session_id.
      4. For each task: derive slug and plan project root; create root + reports/ only when writing artifacts (lazy creation).
      5. Produce `reports/research-XXX.md` (incremental) following report standard for each task.
      6. Store session_id for use in ReceiveResults stage
    </process>
    <session_tracking>
      Store the following for ReceiveResults:
      - session_id: Unique identifier for this research execution
      - start_time: Timestamp when delegation began
      - target_agent: researcher or batch-task-orchestrator
      - task_numbers: Task number(s) being researched
    </session_tracking>
  </stage>
  <stage id="3.5" name="ReceiveResults">
    <action>Wait for researcher completion and receive results</action>
    <process>
      1. Poll for completion using session_id from Research stage
      2. Set timeout: 3600 seconds (1 hour)
      3. Receive return_value from researcher subagent
      4. Validate return format against @context/common/standards/subagent-return-format.md:
         - Check required fields present (status, summary, artifacts, metadata)
         - Validate status enum (completed|failed|partial|blocked)
         - Validate metadata fields (session_id, duration_seconds, agent_type)
         - Validate artifacts array structure (can be empty)
      5. Handle timeout/error cases with appropriate recovery
    </process>
    <error_handling>
      <on_timeout>
        1. Log: "Research timeout after 3600s for session {session_id}"
        2. Attempt to retrieve partial research results from artifacts
        3. Mark task(s) as [IN PROGRESS] (not failed) to allow resume
        4. Return to user: "Research timed out after 1 hour. Check .opencode/specs/{project}/reports/ for partial findings. Task marked IN PROGRESS for resume."
        5. Proceed to Postflight with partial data if available
      </on_timeout>
      <on_validation_error>
        1. Log validation error with details: "Return format validation failed for session {session_id}: {error_details}"
        2. Retry once with same parameters (may be transient parsing issue)
        3. If retry validation fails:
           a. Log: "Return format validation failed after retry"
           b. Return error to user: "Researcher returned invalid format. Check logs for details."
           c. Suggest manual intervention: "Review .opencode/specs/{project}/reports/ for any research artifacts created"
        4. Do NOT proceed to ProcessResults if validation fails after retry
      </on_validation_error>
      <on_execution_error>
        1. Log error details with session_id and error message
        2. Check if error is recoverable (from errors[].recoverable field)
        3. If recoverable, retry once with same parameters
        4. If not recoverable or retry fails:
           a. Extract error details from errors array
           b. Return actionable error message to user with suggested fixes
           c. Mark task(s) as [IN PROGRESS] to allow manual fix and retry
        5. Do NOT proceed to ProcessResults if error not recovered
      </on_execution_error>
      <on_exception>
        1. Catch any unexpected exceptions during receive/validation
        2. Log full stack trace with session_id
        3. Return graceful error: "Unexpected error receiving researcher results. Session: {session_id}"
        4. Provide debug info: "Check orchestrator logs for stack trace"
        5. Mark task(s) as [IN PROGRESS] to preserve work and allow investigation
      </on_exception>
    </error_handling>
    <timeout_monitoring>
      - Start timeout timer when entering ReceiveResults stage
      - Check elapsed time every 10 seconds
      - If elapsed > 3600s, trigger on_timeout handler
      - Allow graceful cancellation if user interrupts
    </timeout_monitoring>
    <validation_rules>
      Follow @context/common/standards/subagent-return-format.md exactly:
      1. return_value must be JSON object
      2. status must be one of: completed, failed, partial, blocked
      3. summary must be non-empty string (2-5 sentences, max 100 tokens)
      4. artifacts must be array (can be empty)
      5. Each artifact must have type and path fields (expect type="research")
      6. metadata must have session_id, duration_seconds, agent_type
      7. errors must be array if present (can be empty)
    </validation_rules>
    <checkpoint>Research results received, validated, and error-checked</checkpoint>
  </stage>
  <stage id="3.75" name="ProcessResults">
    <action>Process validated return value and extract research results</action>
    <process>
      1. Extract status from return_value.status
      2. Extract summary from return_value.summary (research findings summary)
      3. Extract artifacts array from return_value.artifacts (research reports)
      4. Extract metadata from return_value.metadata
      5. Check errors array from return_value.errors:
         - If non-empty, log all errors with details
         - Include error information in user summary
         - Determine if errors are blocking vs. non-blocking
      6. Update command state with results:
         - Store research report paths for state sync
         - Store findings summary for user reporting
         - Store metadata for debugging
         - Store final status (completed/failed/partial/blocked)
      7. Prepare data for Postflight stage:
         - Research artifact paths for state.json and TODO links
         - Summary for user report
         - Status for TODO/state updates
         - Error information for user report
    </process>
    <status_interpretation>
      - completed: Research finished, all findings documented, mark [RESEARCHED]
      - partial: Some research done, mark [IN PROGRESS], report partial findings
      - failed: Research failed, mark [IN PROGRESS] with error details, suggest fixes
      - blocked: Cannot proceed with research, mark [IN PROGRESS], report blockers
    </status_interpretation>
    <artifact_processing>
      For each artifact in artifacts array:
      1. Validate path exists (log warning if missing, but don't fail)
      2. Expect type="research" for research reports
      3. Store report path for TODO link and state.json sync
      4. Prepare for git staging (will be handled by git-workflow-manager)
    </artifact_processing>
    <checkpoint>Research results processed and ready for Postflight sync</checkpoint>
  </stage>
  <stage id="4" name="Postflight">
    <action>Sync and summarize</action>
    <process>
      1. Check final status from ProcessResults stage (completed|partial|failed|blocked)
      2. Route to appropriate status sync operation based on final status:
         - If status = completed: Mark as [RESEARCHED]
         - If status = partial|failed|blocked: Keep status as [IN PROGRESS] with note
      3. For completed status, use @subagents/specialists/status-sync-manager to atomically mark TODO, state.json, and project state.json to [RESEARCHED] status with **Completed** date for each task; add research link to TODO and brief summary; preserve metadata.
      4. For partial/failed/blocked status:
         - Ensure TODO remains [IN PROGRESS]
         - Add note to task with status reason
         - Include error details or next steps from researcher return
         - Link any partial research artifacts created
      5. Update project state (reports array, phase/status, timestamps) without creating extra subdirs when artifacts were written.
      6. Return concise summary including:
         - Final status (completed|partial|failed|blocked)
         - Research artifact paths (from artifacts array)
         - Findings summary (from summary field)
         - TODO/state sync status
         - Error information if any
         - Next steps from researcher return if provided
    </process>
    <status_handling>
      <on_completed>
        1. Mark all tasks as [RESEARCHED] with timestamp
        2. Link research reports in TODO
        3. Update state.json with report paths
        4. Report success to user with findings summary
      </on_completed>
      <on_partial>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Partial research - see reports for findings"
        3. Link partial research reports if created
        4. Report to user: "Partial research: {summary}. Reports: {list}. Next: {next_steps}"
      </on_partial>
      <on_failed>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Research failed - see error details"
        3. Report errors to user with suggested fixes
        4. Include error recovery steps from researcher
      </on_failed>
      <on_blocked>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Research blocked - {blocker_reason}"
        3. Report blocker to user with clear explanation
        4. Suggest actions to unblock research
      </on_blocked>
    </status_handling>
    <error_handling>
      If status-sync-manager fails:
      1. Log detailed error including which file failed to update
      2. Return error to user with actionable message
      3. Do NOT mark task as researched if atomic update failed
      4. Suggest manual status update if needed
      
      If ProcessResults indicated errors:
      1. Include error details in user summary
      2. Categorize errors by type (timeout|validation|execution|resource)
      3. Provide actionable recovery steps based on error type
      4. Log errors for debugging with session_id correlation
    </error_handling>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (task-scoped research using standards + task metadata).</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; load Lean/logic contexts only when Lean.</lean_routing>
  <batch_handling>Use batch-task-orchestrator + batch-status-manager for multi-task inputs; ensure atomic status updates per task; route each task to researcher subagent.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project root/reports/ only when writing research artifacts; no other subdirs.</lazy_creation>
  <artifact_naming>reports/research-XXX.md (incremental).</artifact_naming>
  <state_sync>Update project/global state with report paths and timestamps; link in TODO.</state_sync>
  <registry_sync>Registries unchanged unless research updates implementation status.</registry_sync>
  <git_commits>After research artifacts and state/TODO links are written, use git-commits.md + git-workflow-manager to stage only related files; avoid blanket commits.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md; include timestamps for transitions.</status_markers>
  <language_routing>Respect Language metadata/flags.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Fail clearly on missing task; avoid directory creation without artifacts.</validation>
</quality_standards>

<usage_examples>
  - `/research 161 "Investigate parser regression"`
  - `/research 129 --lang lean "Temporal swap strategy"`
  - `/research 132-135` (batch research for tasks 132, 133, 134, 135)
  - `/research 132,134,136` (batch research for specific tasks)
</usage_examples>

<validation>
  <pre_flight>Task resolved; statuses set.</pre_flight>
  <mid_flight>Researcher produced artifacts with lazy creation.</mid_flight>
  <post_flight>TODO/state linked; references returned.</post_flight>
</validation>
