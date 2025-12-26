---
name: plan
agent: orchestrator
description: "Create implementation plan(s) for existing TODO task(s) and sync artifacts (supports single, ranges, and lists)"
context_level: 2
language: markdown
subagents:
  - planner
  - batch-task-orchestrator
  - batch-status-manager
  - status-sync-manager
mcp_requirements:
  - "lean-lsp (Lean tasks only)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
creates_root_on: "When writing the first plan artifact"
creates_subdir:
  - plans
input_format: "Required: task number(s) - single (e.g., /plan 160), range (e.g., /plan 132-135), or list (e.g., /plan 132,133,134). Reject missing/non-numeric inputs. Error message (no emojis): 'Error: Task number(s) required and must be numeric (e.g., /plan 160 or /plan 132-135).'"
---

**Task Input (required):** $ARGUMENTS (task number(s); ranges/lists allowed, e.g., `/plan 160`, `/plan 132-135`, `/plan 132,133,134`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/common/standards/commands.md
@context/common/standards/plan.md
@context/common/standards/tasks.md
@context/common/standards/subagent-return-format.md
@context/common/workflows/task-breakdown.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/project/repo/project-overview.md
(@.opencode/context/project/lean4/* and @.opencode/context/project/logic/* when Lean intent is detected)

<context>
  <system_context>Planning command that must honor numbering, status markers, and lazy directory creation.</system_context>
  <domain_context>TODO tasks and project specs directories.</domain_context>
  <task_context>Create an implementation plan for the specified task, capture research links, and sync TODO/state.</task_context>
  <execution_context>Plan creation may create project root and plans/ subdir only when writing the plan artifact.</execution_context>
</context>

<role>Planner orchestrating plan creation with research inputs and Lean routing awareness.</role>

<task>Given a task number and optional prompt, generate an implementation plan with research inputs, set status markers, and link artifacts in TODO/state.</task>

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
      2. Detect Lean via TODO `Language` (authoritative) or `--lang`; plan `lean:` is secondary. If Lean, MCP ping `lean-lsp` before proceeding.
      3. Pre-flight: use @subagents/specialists/status-sync-manager to atomically set TODO status to [IN PROGRESS] with **Started** date and state status to `in_progress`. No dirs created.
    </process>
  </stage>
  <stage id="3" name="PrepareArtifacts">
    <action>Resolve project paths and research inputs</action>
    <process>
      1. For each task: derive slug from TODO title; create project root and `plans/` only when writing the plan.
      2. Collect research links from TODO for each task; warn on missing files but continue; do not create directories while resolving links.
    </process>
  </stage>
  <stage id="4" name="CreatePlan">
    <action>Route to planner(s)</action>
    <process>
      1. Generate unique session_id for tracking: `cmd_plan_{task_number}_{timestamp}_{random}`
         - Format: task_number = single task or first in range
         - timestamp = ISO8601 format (e.g., 20251226T143022)
         - random = 6 character alphanumeric
         - Example: `cmd_plan_202_20251226T143022_pqr456`
      2. Single task: route to @subagents/planner directly with session_id.
      3. Multiple tasks: route via @subagents/batch-task-orchestrator with planner subagent for each task; batch handoff includes normalized task list, language metadata per task, research links per task, dependency hints, and session_id.
      4. For each task: generate `plans/implementation-XXX.md` (incremental) using plan standard.
      5. Include Research Inputs section with citations or "none linked" for each plan.
      6. Include `lean: true|false` in metadata and plan-level status marker `[IN PROGRESS]` with timestamps while phases start at `[NOT STARTED]`.
      7. Store session_id for use in ReceiveResults stage
    </process>
    <session_tracking>
      Store the following for ReceiveResults:
      - session_id: Unique identifier for this planning execution
      - start_time: Timestamp when delegation began
      - target_agent: planner or batch-task-orchestrator
      - task_numbers: Task number(s) being planned
    </session_tracking>
  </stage>
  <stage id="4.5" name="ReceiveResults">
    <action>Wait for planner completion and receive results</action>
    <process>
      1. Poll for completion using session_id from CreatePlan stage
      2. Set timeout: 3600 seconds (1 hour)
      3. Receive return_value from planner subagent
      4. Validate return format against @context/common/standards/subagent-return-format.md:
         - Check required fields present (status, summary, artifacts, metadata)
         - Validate status enum (completed|failed|partial|blocked)
         - Validate metadata fields (session_id, duration_seconds, agent_type)
         - Validate artifacts array structure (can be empty)
      5. Handle timeout/error cases with appropriate recovery
    </process>
    <error_handling>
      <on_timeout>
        1. Log: "Planning timeout after 3600s for session {session_id}"
        2. Attempt to retrieve partial plan results from artifacts
        3. Mark task(s) as [IN PROGRESS] (not failed) to allow resume
        4. Return to user: "Planning timed out after 1 hour. Check .opencode/specs/{project}/plans/ for partial plan. Task marked IN PROGRESS for resume."
        5. Proceed to Postflight with partial data if available
      </on_timeout>
      <on_validation_error>
        1. Log validation error with details: "Return format validation failed for session {session_id}: {error_details}"
        2. Retry once with same parameters (may be transient parsing issue)
        3. If retry validation fails:
           a. Log: "Return format validation failed after retry"
           b. Return error to user: "Planner returned invalid format. Check logs for details."
           c. Suggest manual intervention: "Review .opencode/specs/{project}/plans/ for any plan artifacts created"
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
        3. Return graceful error: "Unexpected error receiving planner results. Session: {session_id}"
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
      5. Each artifact must have type and path fields (expect type="plan")
      6. metadata must have session_id, duration_seconds, agent_type
      7. errors must be array if present (can be empty)
    </validation_rules>
    <checkpoint>Planning results received, validated, and error-checked</checkpoint>
  </stage>
  <stage id="4.75" name="ProcessResults">
    <action>Process validated return value and extract planning results</action>
    <process>
      1. Extract status from return_value.status
      2. Extract summary from return_value.summary (plan overview)
      3. Extract artifacts array from return_value.artifacts (implementation plans)
      4. Extract metadata from return_value.metadata
      5. Check errors array from return_value.errors:
         - If non-empty, log all errors with details
         - Include error information in user summary
         - Determine if errors are blocking vs. non-blocking
      6. Update command state with results:
         - Store plan paths for state sync and TODO links
         - Store plan summary for user reporting
         - Store metadata for debugging
         - Store final status (completed/failed/partial/blocked)
      7. Prepare data for Postflight stage:
         - Plan artifact paths for state.json and TODO links
         - Summary for user report
         - Status for TODO/plan/state updates
         - Error information for user report
    </process>
    <status_interpretation>
      - completed: Plan finished, all phases defined, mark [PLANNED]
      - partial: Some planning done, mark [IN PROGRESS], report partial plan
      - failed: Planning failed, mark [IN PROGRESS] with error details, suggest fixes
      - blocked: Cannot proceed with planning, mark [IN PROGRESS], report blockers
    </status_interpretation>
    <artifact_processing>
      For each artifact in artifacts array:
      1. Validate path exists (log warning if missing, but don't fail)
      2. Expect type="plan" for implementation plans
      3. Store plan path for TODO link and state.json sync
      4. Prepare for git staging (will be handled by git-workflow-manager)
    </artifact_processing>
    <checkpoint>Planning results processed and ready for Postflight sync</checkpoint>
  </stage>
  <stage id="5" name="Postflight">
    <action>Link and sync</action>
    <process>
      1. Check final status from ProcessResults stage (completed|partial|failed|blocked)
      2. Route to appropriate status sync operation based on final status:
         - If status = completed: Mark as [PLANNED]
         - If status = partial|failed|blocked: Keep status as [IN PROGRESS] with note
      3. For completed status, use @subagents/specialists/status-sync-manager to atomically mark TODO, state.json, project state.json, and plan file to [PLANNED] status with **Completed** date for each task; add plan link to TODO and brief summary; keep metadata intact.
      4. For partial/failed/blocked status:
         - Ensure TODO remains [IN PROGRESS]
         - Add note to task with status reason
         - Include error details or next steps from planner return
         - Link any partial plan artifacts created
      5. Update project state (phase: planning, status) with plan path and timestamps for each task; avoid creating extra subdirs.
      6. Mark plan file header with appropriate status and timestamp for each plan.
      7. Return concise summary including:
         - Final status (completed|partial|failed|blocked)
         - Plan artifact paths (from artifacts array)
         - Plan overview (from summary field)
         - TODO/state sync status
         - Error information if any
         - Next steps from planner return if provided
    </process>
    <status_handling>
      <on_completed>
        1. Mark all tasks as [PLANNED] with timestamp
        2. Link plans in TODO
        3. Mark plan file header with [PLANNED] and **Completed** timestamp
        4. Update state.json with plan paths
        5. Report success to user with plan summary
      </on_completed>
      <on_partial>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Partial plan - see plans/ for details"
        3. Link partial plans if created
        4. Mark plan file header with [IN PROGRESS]
        5. Report to user: "Partial planning: {summary}. Plans: {list}. Next: {next_steps}"
      </on_partial>
      <on_failed>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Planning failed - see error details"
        3. Report errors to user with suggested fixes
        4. Include error recovery steps from planner
      </on_failed>
      <on_blocked>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Planning blocked - {blocker_reason}"
        3. Report blocker to user with clear explanation
        4. Suggest actions to unblock planning (e.g., run /research first)
      </on_blocked>
    </status_handling>
    <error_handling>
      If status-sync-manager fails:
      1. Log detailed error including which file failed to update
      2. Return error to user with actionable message
      3. Do NOT mark task as planned if atomic update failed
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
  <context_allocation>Level 2 (planning with standards + project overview).</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; load Lean/logic contexts only when Lean.</lean_routing>
  <batch_handling>Use batch-task-orchestrator + batch-status-manager for multi-task inputs; ensure atomic status updates per task; route each task to planner subagent.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project root and plans/ only when emitting the plan; do not create reports/ or summaries.</lazy_creation>
  <artifact_naming>Plans use `implementation-XXX.md` incremental numbering.</artifact_naming>
  <state_sync>Update project state.json when plan is written; update global state/TODO links.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md if plan changes implementation status expectations; registries untouched otherwise.</registry_sync>
  <git_commits>After the plan artifact and status updates are written, use git-commits.md + git-workflow-manager to stage only plan-related files and commit with a scoped message; no repo-wide adds.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md for plan header and phases; include timestamps.</status_markers>
  <language_routing>Respect Language metadata/flags; plan `lean:` is secondary.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Fail fast on missing task; do not create directories without emitting plan.</validation>
</quality_standards>

<usage_examples>
  - `/plan 161 "Fix parser regression"`
  - `/plan 129 --lang lean`
  - `/plan 132-135` (batch planning for tasks 132, 133, 134, 135)
  - `/plan 132,134,136` (batch planning for specific tasks)
</usage_examples>

<validation>
  <pre_flight>Task resolved; Lean intent detected; statuses set.</pre_flight>
  <mid_flight>Plan created with research inputs; lazy creation enforced.</mid_flight>
  <post_flight>TODO/state linked; plan path returned.</post_flight>
</validation>
