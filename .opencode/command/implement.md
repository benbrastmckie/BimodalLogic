---
name: implement
agent: orchestrator
description: "Execute TODO task(s) by number using plans/reports and keep specs in sync"
context_level: 2
language: markdown
subagents:
  - batch-task-orchestrator
  - batch-status-manager
  - status-sync-manager
  - implementation-orchestrator (non-Lean tasks)
  - lean-implementation-orchestrator (Lean tasks)
  - planner/researcher/reviewer/refactorer/documenter (routed per task type)
mcp_requirements:
  - "lean-lsp (required for Lean task execution)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (when implementation status changes)
  - SORRY_REGISTRY.md (when sorry counts change)
  - TACTIC_REGISTRY.md (when tactic counts change)
creates_root_on: "Only when delegated agent writes first artifact"
creates_subdir: "Delegated agent creates the needed subdir (reports|plans|summaries) when writing"
---

You are executing task(s) from `.opencode/specs/TODO.md` by number. Use existing research and plans, respect lazy directory creation, and keep TODO/state/artifacts synchronized.

**Task Input:** $ARGUMENTS (task number(s); ranges/lists allowed)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/state-schema.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/commands.md
@.opencode/context/common/standards/patterns.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/task-breakdown.md
@.opencode/context/project/repo/project-overview.md
(@.opencode/context/project/lean4/* and @.opencode/context/project/logic/* only when executing Lean-tagged plans)

<context>
  <system_context>Task executor for TODO items with batch support and strict status/lazy-creation rules.</system_context>
  <domain_context>Tasks defined in TODO.md with linked plans/research in specs/.</domain_context>
  <task_context>Resolve task numbers, pre-flight status updates, route to appropriate agents, and sync artifacts/state.</task_context>
  <execution_context>Supports single or batch execution with wave routing; no directories created without artifacts.</execution_context>
</context>

<role>Task orchestrator managing routing, status propagation, and synchronization.</role>

<task>Execute one or more TODO tasks, updating status markers, leveraging linked plans/reports, producing summaries when artifacts are written, and synchronizing TODO/state.</task>

<workflow_execution>
  <stage id="1" name="ParseInput">
    <action>Validate task numbers</action>
    <process>
      1. Support single numbers, comma-separated lists, and ranges (e.g., `105`, `105,106`, `105-107`). Detect range/list invocations first, normalize to an ordered, de-duplicated task list, and preserve numeric-only validation.
      2. Validate positive integers; deduplicate expanded lists; fail clearly on invalid formats and return bad inputs.
      3. If more than one normalized task remains, classify as batch and route to batch-task-orchestrator; otherwise continue with single-task flow.
    </process>
  </stage>
  <stage id="2" name="ResolveTasks">
    <action>Load TODO entries and detect Lean intent</action>
    <process>
      1. Locate each task in TODO.md; if missing, report and continue.
      2. Detect Lean via TODO `Language` (authoritative) or `--lang`; plan `lean:` secondary.
       3. Pre-flight: use @subagents/specialists/status-sync-manager to atomically set TODO status to [IN PROGRESS] with **Started** date and, when a plan link exists, set the plan header + first active phase to [IN PROGRESS] with (Started: ISO8601); set state to `in_progress` with started in the same batch. No dirs created.
    </process>
  </stage>
  <stage id="2.5" name="AssessComplexity">
    <action>Assess task complexity for routing differentiation</action>
    <process>
      1. Calculate complexity score using 7-factor algorithm (0-14 scale):
         - Effort estimate (0-2): <2h=0, 2-4h=1, >4h=2
         - Files affected (0-2): 1-2=0, 3-5=1, >5=2
         - Lines of code (0-2): <100=0, 100-500=1, >500=2
         - Dependencies (0-2): none=0, 1-2=1, >2=2
         - Research needed (0-2): no=0, some=1, extensive=2
         - Unknowns (0-2): clear=0, some=1, many=2
         - Risk level (0-2): low=0, medium=1, high=2
      2. Classify based on total score:
         - 0-4: Simple (direct execution, single commit)
         - 5-9: Moderate (plan-based, phase commits)
         - 10-14: Complex (full research→plan→implement, phase commits)
      3. Allow manual override with flags:
         - --simple: Force simple path (skip complexity assessment)
         - --complex: Force complex path (full workflow)
      4. Pass complexity flag to task-executor for execution path differentiation
    </process>
    <complexity_indicators>
      <simple>
        - Single file changes
        - Clear requirements
        - No dependencies
        - Low risk
        - <2 hour effort
      </simple>
      <moderate>
        - 2-5 file changes
        - Some unknowns
        - 1-2 dependencies
        - Medium risk
        - 2-4 hour effort
      </moderate>
      <complex>
        - >5 file changes
        - Significant unknowns
        - Multiple dependencies
        - High risk
        - >4 hour effort
        - Research required
      </complex>
    </complexity_indicators>
    <checkpoint>Complexity assessed and routing flag set</checkpoint>
  </stage>
  <stage id="3" name="Execute">
    <action>Route by work type and complexity</action>
    <process>
      1. Generate unique session_id for tracking: `cmd_implement_{task_number}_{timestamp}_{random}`
         - Format: task_number = single task or first in range
         - timestamp = ISO8601 format (e.g., 20251226T143022)
         - random = 6 character alphanumeric
         - Example: `cmd_implement_191_20251226T143022_abc123`
      2. Single task: route to appropriate agent with complexity flag and session_id:
         - Simple: Direct execution by implementer (no research/plan phases)
         - Moderate/Complex: Route to task-executor for full workflow
         - Documentation → documenter; refactor → refactorer; research-only → researcher
         - Lean → lean-implementation-orchestrator/proof-developer
         - Pass session_id to subagent for correlation and tracking
      3. Multiple tasks: route via batch-task-orchestrator + batch-status-manager with wave-based execution; Lean tasks use Lean path within waves. Batch handoff includes normalized task list, language metadata per task, complexity flags, dependency hints, and session_id; dependency analysis precedes execution.
      4. Reuse plan/research links exactly; maintain lazy creation (project roots/subdirs only when writing artifacts). Batch execution must keep TODO/plan/state status markers in lockstep for each task and block dependents on failure.
      5. Store session_id for use in ReceiveResults stage
    </process>
    <session_tracking>
      Store the following for ReceiveResults:
      - session_id: Unique identifier for this execution
      - start_time: Timestamp when delegation began
      - target_agent: Which subagent was invoked
      - task_numbers: Task number(s) being executed
    </session_tracking>
  </stage>
  <stage id="3.5" name="ReceiveResults">
    <action>Wait for subagent completion and receive results</action>
    <process>
      1. Poll for completion using session_id from Execute stage
      2. Set timeout: 3600 seconds (1 hour)
      3. Receive return_value from subagent
      4. Validate return format against @.opencode/context/common/standards/subagent-return-format.md:
         - Check required fields present (status, summary, artifacts, metadata)
         - Validate status enum (completed|failed|partial|blocked)
         - Validate metadata fields (session_id, duration_seconds, agent_type)
         - Validate artifacts array structure (can be empty)
      5. Handle timeout/error cases with appropriate recovery
    </process>
    <error_handling>
      <on_timeout>
        1. Log: "Subagent timeout after 3600s for session {session_id}"
        2. Attempt to retrieve partial results from artifacts
        3. Mark task(s) as [IN PROGRESS] (not failed) to allow resume
        4. Return to user: "Execution timed out after 1 hour. Check .opencode/specs/{project}/summaries/ for partial progress. Task marked IN PROGRESS for resume."
        5. Proceed to Postflight with partial data
      </on_timeout>
      <on_validation_error>
        1. Log validation error with details: "Return format validation failed for session {session_id}: {error_details}"
        2. Retry once with same parameters (may be transient parsing issue)
        3. If retry validation fails:
           a. Log: "Return format validation failed after retry"
           b. Return error to user: "Subagent returned invalid format. Check logs for details."
           c. Suggest manual intervention: "Review .opencode/specs/{project}/ for any artifacts created"
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
        3. Return graceful error: "Unexpected error receiving subagent results. Session: {session_id}"
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
      Follow @.opencode/context/common/standards/subagent-return-format.md exactly:
      1. return_value must be JSON object
      2. status must be one of: completed, failed, partial, blocked
      3. summary must be non-empty string (2-5 sentences, max 100 tokens)
      4. artifacts must be array (can be empty)
      5. Each artifact must have type and path fields
      6. metadata must have session_id, duration_seconds, agent_type
      7. errors must be array if present (can be empty)
    </validation_rules>
    <checkpoint>Results received, validated, and error-checked</checkpoint>
  </stage>
  <stage id="3.75" name="ProcessResults">
    <action>Process validated return value and extract results</action>
    <process>
      1. Extract status from return_value.status
      2. Extract summary from return_value.summary (for user reporting)
      3. Extract artifacts array from return_value.artifacts
      4. Extract metadata from return_value.metadata
      5. Check errors array from return_value.errors:
         - If non-empty, log all errors with details
         - Include error information in user summary
         - Determine if errors are blocking vs. non-blocking
      6. Update command state with results:
         - Store artifact paths for state sync
         - Store summary for user reporting
         - Store metadata for debugging
         - Store final status (completed/failed/partial/blocked)
      7. Prepare data for Postflight stage:
         - Artifact list for state.json sync
         - Summary for implementation-summary file
         - Status for TODO/plan/state updates
         - Error information for user report
    </process>
    <status_interpretation>
      - completed: All tasks succeeded, proceed to mark_completed
      - partial: Some work done, mark IN PROGRESS, report partial results
      - failed: Task failed, mark IN PROGRESS with error details, suggest fixes
      - blocked: Cannot proceed, mark IN PROGRESS, report blockers to user
    </status_interpretation>
    <artifact_processing>
      For each artifact in artifacts array:
      1. Validate path exists (log warning if missing, but don't fail)
      2. Categorize by type (research|plan|implementation|summary|test|documentation)
      3. Store for state.json artifact links
      4. Prepare for git staging (will be handled by git-workflow-manager)
    </artifact_processing>
    <checkpoint>Results processed and ready for Postflight sync</checkpoint>
  </stage>
  <stage id="4" name="Postflight">
    <action>Sync and report</action>
    <process>
      1. Check final status from ProcessResults stage (completed|partial|failed|blocked)
      2. Update plan phases/status markers when used, keeping TODO/plan/state status fields in lockstep; produce/update summaries under `summaries/implementation-summary-YYYYMMDD.md` when artifacts are written.
      3. Extract plan_path from TODO.md task entry if a plan link exists (look for `- **Plan**: [...](...)`).
      4. Route to appropriate status sync operation based on final status:
         - If status = completed: Call status-sync-manager.mark_completed
         - If status = partial|failed|blocked: Keep status as [IN PROGRESS] with note
      5. For completed status, call @subagents/specialists/status-sync-manager.mark_completed with:
         - operation: "mark_completed"
         - task_number: {task_number}
         - timestamp: {YYYY-MM-DD current date}
         - plan_path: {plan_path} (if plan link exists in TODO.md)
      6. For partial/failed/blocked status:
         - Ensure TODO remains [IN PROGRESS]
         - Add note to task with status reason
         - Include error details or next steps from subagent return
      7. Verify status-sync-manager returned success status (for completed case).
      8. If status-sync-manager fails, log error with details and report to user (do NOT swallow errors or continue silently).
      9. Sync state.json with status/timestamps/artifact links/phase markers; reuse plan links already attached.
      10. Return concise summary including:
          - Final status (completed|partial|failed|blocked)
          - Routing details (which agent executed)
          - Artifacts created (from artifacts array)
          - TODO/state/plan sync status
          - Error information if any
          - Next steps from subagent return if provided
          - Task failure details per task for batch execution
    </process>
    <status_handling>
      <on_completed>
        1. Mark all tasks as [COMPLETED] with timestamp
        2. Update plan to [COMPLETED] if all phases complete
        3. Create/update implementation summary
        4. Report success to user with artifact list
      </on_completed>
      <on_partial>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Partial completion - see summary for details"
        3. Include partial artifact list in state sync
        4. Report to user: "Partial completion: {summary}. Artifacts: {list}. Next: {next_steps}"
      </on_partial>
      <on_failed>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Execution failed - see error details"
        3. Report errors to user with suggested fixes
        4. Include error recovery steps from subagent
      </on_failed>
      <on_blocked>
        1. Keep tasks as [IN PROGRESS]
        2. Add note: "Blocked - {blocker_reason}"
        3. Report blocker to user with clear explanation
        4. Suggest actions to unblock
      </on_blocked>
    </status_handling>
    <error_handling>
      If status-sync-manager.mark_completed fails:
      1. Log detailed error including which file failed to update
      2. Return error to user with actionable message
      3. Do NOT mark task as completed if atomic update failed
      4. Suggest manual status update if needed: "Status update failed. Please manually update TODO.md, state.json, and plan file to [COMPLETED]"
      
      If ProcessResults indicated errors:
      1. Include error details in user summary
      2. Categorize errors by type (timeout|validation|execution|resource|cycle)
      3. Provide actionable recovery steps based on error type
      4. Log errors for debugging with session_id correlation
    </error_handling>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 baseline; escalate per task complexity.</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; validate lean-lsp MCP before Lean work.</lean_routing>
  <batch_handling>Use batch-task-orchestrator + batch-status-manager for multi-task inputs; ensure atomic status updates per task.</batch_handling>
</routing_intelligence>

  <artifact_management>
  <lazy_creation>Derive slug `.opencode/specs/NNN_slug/`; create project root/subdir only when writing an artifact.</lazy_creation>
  <artifact_naming>Summaries under `summaries/implementation-summary-YYYYMMDD.md`; plan/research links reused.</artifact_naming>
  <state_sync>Update project state alongside artifact writes; no project state writes when no artifacts; status sync writes to TODO/plan/state must be atomic.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md when task execution changes status or sorry/tactic counts.</registry_sync>
  <git_commits>After artifacts/state updates, use git-commits.md and git-workflow-manager to stage only task-relevant files (no `git add -A`/blanket commits) and commit with scoped messages.</git_commits>
 </artifact_management>


<quality_standards>
  <status_markers>Apply status-markers.md for tasks and plan phases with timestamps.</status_markers>
  <language_routing>Respect Language metadata/flags; plan `lean:` secondary.</language_routing>
  <no_emojis>No emojis in commands or artifacts.</no_emojis>
  <validation>Reject directory creation without artifact writes; fail clearly on invalid inputs.</validation>
</quality_standards>

<usage_examples>
  - `/implement 105`
  - `/implement 105,106`
  - `/implement 105-107`
  - `/implement 105, 107-109, 111`
</usage_examples>

<validation>
  <pre_flight>Inputs validated; TODO/plan/state set to [IN PROGRESS] with timestamps.</pre_flight>
  <mid_flight>Routing executed with lazy creation; artifacts produced as needed.</mid_flight>
  <post_flight>TODO/state synced; summaries linked; errors reported per task.</post_flight>
</validation>
