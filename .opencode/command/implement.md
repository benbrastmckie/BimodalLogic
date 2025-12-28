---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
context_level: 2
language: varies
---

**Task Input (required):** $ARGUMENTS (task number or range; e.g., `/implement 197`, `/implement 105-107`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md
@.opencode/context/common/system/git-commits.md

<context>
  <system_context>
    Implementation workflow with plan-based execution, resume support, and [COMPLETED]
    status marker. Supports both phased (with plan) and direct (no plan) implementation.
  </system_context>
  <domain_context>
    Implementation for Lean and general tasks. Lean tasks route to lean-implementation-agent,
    general tasks route to implementer or task-executor based on plan presence.
  </domain_context>
  <task_context>
    Execute implementation for specified task(s), resume from incomplete phases if plan exists,
    create implementation artifacts, update status to [COMPLETED], and commit changes.
  </task_context>
  <execution_context>
    Lazy directory creation (specs/NNN_*/ only when writing). Atomic status synchronization
    via status-sync-manager. Git commits per phase or per task. Resume support for interrupted work.
  </execution_context>
</context>

<role>Implementation Command - Execute tasks with plan support and resume capability</role>

<task>
  Execute implementation for task(s), resume from incomplete phases, create artifacts,
  update status to [COMPLETED] with timestamps, and commit changes per phase or task.
</task>

<argument_parsing>
  <invocation_format>
    /implement TASK_NUMBER [PROMPT]
    /implement TASK_RANGE [PROMPT]
    
    Examples:
    - /implement 196
    - /implement 196 "Focus on error handling"
    - /implement 105-107
    - /implement 105-107 "Batch implementation"
  </invocation_format>
  
  <parameters>
    <task_number_or_range>
      <position>1</position>
      <type>integer or range</type>
      <required>true</required>
      <description>Single task number or range (e.g., 105-107)</description>
      <extraction>Extract first argument after command name as task number or range</extraction>
      <validation>
        If single: Must be valid integer that exists in TODO.md
        If range: Must be format "N-M" where N and M are valid integers with N &lt; M
      </validation>
      <range_parsing>
        If argument contains hyphen (-):
          Split on hyphen to get start and end
          Validate both are integers
          Validate start &lt; end
          Generate list of task numbers: [start, start+1, ..., end]
      </range_parsing>
    </task_number_or_range>
    
    <prompt>
      <position>2</position>
      <type>string</type>
      <required>false</required>
      <description>Optional additional context for implementation</description>
      <extraction>Extract remaining arguments after task number as prompt string</extraction>
      <default>Use task description and plan from TODO.md</default>
    </prompt>
  </parameters>
  
  <parsing_logic>
    Example 1 - Single task:
    User invokes: "/implement 196 'Add tests'"
    Parse as:
    1. Command: "implement"
    2. Arguments: ["196", "Add tests"]
    3. Extracted:
       - task_numbers = [196]
       - prompt = "Add tests"
    
    Example 2 - Range:
    User invokes: "/implement 105-107"
    Parse as:
    1. Command: "implement"
    2. Arguments: ["105-107"]
    3. Extracted:
       - task_numbers = [105, 106, 107]
       - prompt = null
  </parsing_logic>
  
  <error_handling>
    If task_number missing:
      Return: "Error: Task number required. Usage: /implement TASK_NUMBER [PROMPT]"
    If task_number not integer or range:
      Return: "Error: Task must be integer or range (N-M). Got: {input}"
    If task not found in TODO.md:
      Return: "Error: Task {task_number} not found in TODO.md"
    If range invalid (start >= end):
      Return: "Error: Invalid range {start}-{end}. Start must be less than end."
    If some tasks in range missing:
      Return: "Warning: Tasks {missing_list} not found. Continuing with {found_list}"
  </error_handling>
</argument_parsing>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate task(s) and determine execution mode</action>
    <process>
      1. Parse task number(s) from input (see <argument_parsing> above)
      2. Load task(s) from TODO.md
      3. Validate all tasks exist and are not [COMPLETED]
      4. For each task:
         a. Extract task description and language
         b. Check for existing plan link in TODO.md
         c. If plan exists:
            - Load plan file
            - Check phase statuses
            - Find first [NOT STARTED] or [IN PROGRESS] phase
            - Prepare resume context
         d. If no plan:
            - Prepare for direct implementation
       5. Mark task(s) [IMPLEMENTING] with Started timestamp
       6. Update state.json: status = "implementing", started = "{YYYY-MM-DD}"
    </process>
    <resume_logic>
      If plan exists:
        - Check phase statuses in plan file
        - Find first [NOT STARTED] or [IN PROGRESS] phase
        - Resume from that phase
        - Skip [COMPLETED] phases
      Else:
        - Direct implementation (no phases)
        - Single-pass execution
    </resume_logic>
    <status_update>
      Atomic update via status-sync-manager:
        - TODO.md: [IMPLEMENTING], **Started**: {date}
        - state.json: status = "implementing", started = "{date}"
        - Plan file (if exists): Mark resuming phase [IN PROGRESS]
    </status_update>
    <validation>
      - Task number(s) must exist in TODO.md
      - Tasks must not be [COMPLETED] or [ABANDONED]
      - If range: all tasks in range must be valid
      - Language field must be present
    </validation>
  </stage>

  <stage id="2" name="DetermineRouting">
    <action>Route based on language and complexity</action>
    <critical_importance>
      CRITICAL: This stage MUST extract the Language field and determine routing.
      DO NOT skip this stage. DO NOT assume language without extraction.
      Incorrect routing bypasses Lean-specific tooling (lean-lsp-mcp).
    </critical_importance>
    <process>
      1. Extract Language field from TODO.md task using explicit bash command:
         ```bash
         grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
         ```
      2. Validate extraction succeeded (non-empty result)
      3. If extraction fails: default to "general" and log warning
      4. Log extracted language: "Task ${task_number} language: ${language}"
      5. Check for plan existence in TODO.md (look for "Plan:" link)
      6. Log plan status: "Task ${task_number} has_plan: ${has_plan}"
      7. Determine target agent using explicit IF/ELSE logic:
         ```
         IF language == "lean" AND has_plan == true:
           agent = "lean-implementation-agent"
           mode = "phased"
         ELSE IF language == "lean" AND has_plan == false:
           agent = "lean-implementation-agent"
           mode = "simple"
         ELSE IF language != "lean" AND has_plan == true:
           agent = "task-executor"
           mode = "phased"
         ELSE IF language != "lean" AND has_plan == false:
           agent = "implementer"
           mode = "direct"
         ```
      8. Log routing decision: "Routing /implement (task ${task_number}, Language: ${language}, has_plan: ${has_plan}) to ${agent} (${mode})"
      9. Prepare agent-specific context
    </process>
    <routing>
      Language: lean + has_plan → lean-implementation-agent (phased mode)
      Language: lean + no_plan → lean-implementation-agent (simple mode)
      Language: * + has_plan → task-executor (multi-phase execution)
      Language: * + no_plan → implementer (direct implementation)
    </routing>
    <validation>
      MUST complete before Stage 3:
      - Language field extracted and logged
      - Plan existence checked and logged
      - Routing decision made and logged
      - Target agent determined
      - Agent matches language and plan status
      MUST NOT skip this stage under any circumstances
    </validation>
    <pre_invocation_check>
      Before invoking agent in Stage 4, verify:
      - Language was extracted in Stage 2
      - Plan status was checked in Stage 2
      - Routing decision was logged in Stage 2
      - Selected agent matches language and plan:
        * If language == "lean" AND agent NOT IN ["lean-implementation-agent"] → ABORT with error
        * If language != "lean" AND agent == "lean-implementation-agent" → ABORT with error
        * If has_plan == true AND agent NOT IN ["lean-implementation-agent", "task-executor"] → ABORT with error
        * If has_plan == false AND agent NOT IN ["lean-implementation-agent", "implementer"] → ABORT with error
      If validation fails: Return error "Routing validation failed: language=${language}, has_plan=${has_plan}, agent=${agent}"
    </pre_invocation_check>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context for implementation agent</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1 (orchestrator → implement → {agent})
      3. Set delegation_path = ["orchestrator", "implement", "{agent}"]
      4. Set timeout = 7200s (2 hours for implementation)
      5. Store session_id for validation
      6. Prepare implementation context (task, language, plan, resume_from_phase)
    </process>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "implement", "{agent}"],
        "timeout": 7200,
        "task_context": {
          "task_number": {number},
          "description": "{description}",
          "language": "{language}",
          "plan_path": "{plan_path|null}",
          "resume_from_phase": {phase_number|null}
        }
      }
    </delegation_context>
  </stage>

  <stage id="4" name="InvokeImplementer">
    <action>Invoke appropriate implementation agent</action>
    <process>
      1. Route to selected agent (task-executor, implementer, or lean-implementation-agent)
      2. Pass delegation context
      3. Pass task description and language
      4. Pass plan reference if exists
      5. Pass resume_from_phase if resuming
      6. Set timeout to 7200s (2 hours)
    </process>
    <invocation>
      task_tool(
        subagent_type="{task-executor|implementer|lean-implementation-agent}",
        prompt="Implement task {number}: {description}",
        session_id=delegation_context["session_id"],
        delegation_depth=1,
        delegation_path=delegation_context["delegation_path"],
        timeout=7200,
        plan_path=plan_path,
        resume_from_phase=resume_from_phase
      )
    </invocation>
  </stage>

  <stage id="5" name="ReceiveResults">
    <action>Wait for and receive implementation results</action>
    <process>
      1. Poll for completion (max 7200s)
      2. Receive return object from implementation agent
      3. Validate against subagent-return-format.md
      4. Check session_id matches expected
      5. Handle timeout gracefully
    </process>
    <timeout_handling>
      If timeout (no response after 7200s):
        1. Log timeout error with session_id
        2. Check plan file for partial progress
        3. Count completed phases
        4. Return partial status with phases completed
        5. Keep task [IMPLEMENTING] (not failed)
        6. Message: "Implementation timed out after 2 hours. {N} phases completed. Resume with /implement {number}"
    </timeout_handling>
    <validation>
      1. Validate return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches
      4. Validate status is valid enum (completed|partial|failed|blocked)
      5. Validate artifacts array structure
      6. Check implementation files exist
    </validation>
  </stage>

  <stage id="6" name="ProcessResults">
    <action>Extract artifacts and determine completion status</action>
    <process>
      1. Extract status from return (completed|partial|failed|blocked)
      2. Extract implementation artifact paths
      3. Extract summary for TODO.md
      4. Extract phase completion info (if plan exists)
      5. Extract errors if status != completed
      6. Determine final task status
    </process>
    <completion_check>
      If status == "completed":
        - All phases done (or no plan)
        - Ready for [COMPLETED] status
        - Proceed to postflight
      If status == "partial":
        - Some phases done
        - Mark task [PARTIAL] status
        - User can resume later
        - Commit partial progress
      If status == "failed":
        - No usable results
        - Handle errors
        - Keep [IMPLEMENTING] status
        - Provide recovery steps
      If status == "blocked":
        - Cannot proceed
        - Mark task [BLOCKED]
        - Identify blocker
        - Request user intervention
    </completion_check>
  </stage>

  <stage id="7" name="Postflight">
    <action>Update status, link artifacts, and commit</action>
    <process>
      1. If status == "completed":
         a. Update TODO.md:
            - Add implementation artifact links
            - Change status to [COMPLETED]
            - Add Completed timestamp
            - Add checkmark to title
         b. Update state.json:
            - status = "completed"
            - completed = "{YYYY-MM-DD}"
            - artifacts = [implementation file paths]
         c. Update plan file (if exists):
            - Mark all phases [COMPLETED]
            - Add completion timestamps
         d. Git commit:
            - Scope: Implementation files + TODO.md + state.json + plan
            - Message: "task {number}: implementation completed"
      
       2. If status == "partial":
          a. Update TODO.md status to [PARTIAL]
          b. Add partial artifact links
          c. Update state.json: status = "partial"
          d. Update plan file (if exists):
             - Mark completed phases [COMPLETED]
             - Keep incomplete phases [NOT STARTED] or [IN PROGRESS]
          e. Git commit (if phases completed):
             - Scope: Phase files + plan file + TODO.md + state.json
             - Message: "task {number} phase {N}: {phase_name}"
       
       3. If status == "failed":
          a. Keep TODO.md status [IMPLEMENTING]
          b. Add error notes to TODO.md
          c. Update plan file (if exists):
             - Mark failed phase [ABANDONED]
          d. No git commit
       
       4. If status == "blocked":
          a. Update TODO.md status to [BLOCKED]
          b. Add blocking reason to TODO.md
          c. Update state.json: status = "blocked", blocked = "{date}"
          d. Update plan file (if exists):
             - Mark blocked phase [BLOCKED]
          e. No git commit
    </process>
    <atomic_update>
      Use status-sync-manager to atomically:
        - Update TODO.md: Add artifact links
        - Update TODO.md: Change status to [COMPLETED]
        - Update TODO.md: Add Completed timestamp
        - Update state.json: status = "completed"
        - Update state.json: completed timestamp
        - Update state.json: artifacts array
        - Update plan file: phase statuses
    </atomic_update>
    <git_commit>
      If completed:
        Scope: Implementation files + TODO.md + state.json + plan
        Message: "task {number}: implementation completed"
      
      If partial (and phases done):
        Scope: Phase files + plan file
        Message: "task {number} phase {N}: {phase_name}"
      
      Use git-workflow-manager for scoped commits
    </git_commit>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <action>Return brief summary with artifact reference</action>
    <process>
      1. Check for summary artifact in subagent return artifacts array
      2. If summary artifact present:
         - Extract path from artifacts
         - Create brief 3-5 sentence overview (<100 tokens)
         - Reference summary artifact path
      3. If summary artifact missing:
         - Create summary artifact from subagent return data
         - Write to summaries/implementation-summary-{YYYYMMDD}.md
         - Create brief 3-5 sentence overview (<100 tokens)
         - Reference newly created summary path
      4. Return brief format to orchestrator
    </process>
    <return_format>
      If completed:
      ```
      Implementation completed for task {number}.
      {brief_1_sentence_outcome}
      {artifact_count} artifacts created.
      Summary: {summary_path}
      ```
      
      Example (completed):
      ```
      Implementation completed for task 191.
      Fixed subagent delegation hangs across 3 phases with standardized return formats and timeout handling.
      14 artifacts created.
      Summary: .opencode/specs/191_fix_subagent_delegation_hang/summaries/implementation-summary-20251226.md
      ```
      
      If partial:
      ```
      Implementation partially completed for task {number}.
      Completed phases {completed_phases} of {total_phases}, {reason}.
      Resume with: /implement {number}
      Summary: {summary_path}
      ```
      
      Example (partial):
      ```
      Implementation partially completed for task 191.
      Completed phases 1-2 of 3, phase 3 timed out after 2 hours.
      Resume with: /implement 191
      Summary: .opencode/specs/191_fix_subagent_delegation_hang/summaries/implementation-summary-20251226.md
      ```
      
      If blocked:
      ```
      Implementation blocked for task {number}.
      {blocking_reason}
      Resolve blocker and retry with: /implement {number}
      Summary: {summary_path}
      ```
      
      Example (blocked):
      ```
      Implementation blocked for task 193.
      Lean proof requires lean-lsp-mcp which is not installed.
      Resolve blocker and retry with: /implement 193
      Summary: .opencode/specs/193_prove_is_valid_swap_involution/summaries/implementation-summary-20251228.md
      ```
    </return_format>
    <token_limit>
      Return must be under 100 tokens (approximately 400 characters).
      Brief overview must be 3-5 sentences maximum.
      Full details are in the summary artifact file.
    </token_limit>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Implementation requires project context based on language
  </context_allocation>
  <lean_routing>
    If Language: lean → lean-implementation-agent
    - Load .opencode/context/project/lean4/
    - Use lean-lsp-mcp for compilation checking
    - Validate lean-lsp-mcp availability
    - Fallback to direct file modification if unavailable
  </lean_routing>
  <general_routing>
    If Language: * + has_plan → task-executor (multi-phase)
    If Language: * + no_plan → implementer (direct)
  </general_routing>
  <batch_handling>
    If range (e.g., 105-107):
      - Execute tasks sequentially
      - Track individual task status
      - Continue on failure (don't abort batch)
      - Return batch summary
  </batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>
    Do not create specs/NNN_*/ until writing implementation artifacts
    Create only needed subdirectories when writing files
  </lazy_creation>
  <artifact_naming>
    Implementation files: Varies by task (Lean files, markdown, etc.)
    Summaries: specs/NNN_{task_slug}/summaries/implementation-summary-{YYYYMMDD}.md
  </artifact_naming>
  <state_sync>
    Update state.json with artifact paths when implementation completes
    Sync TODO.md with implementation artifact links
    Update plan file with phase statuses
  </state_sync>
  <registry_sync>
    When implementation mutates code:
      - Update IMPLEMENTATION_STATUS.md
      - Update SORRY_REGISTRY.md (if Lean)
      - Update TACTIC_REGISTRY.md (if Lean)
  </registry_sync>
</artifact_management>

<quality_standards>
  <status_markers>
    Use [IMPLEMENTING] at start, [COMPLETED]/[PARTIAL]/[BLOCKED] at finish per status-markers.md
    Include Started and Completed timestamps
    Add checkmark to title when completed
  </status_markers>
  <language_routing>
    Route based on TODO.md Language field
    Validate lean-lsp-mcp availability for Lean tasks
  </language_routing>
  <no_emojis>
    No emojis in implementation artifacts or status updates
  </no_emojis>
  <atomic_updates>
    Use status-sync-manager for atomic multi-file updates
  </atomic_updates>
  <resume_support>
    Check plan phases before execution
    Skip [COMPLETED] phases
    Resume from first incomplete phase
  </resume_support>
</quality_standards>

<usage_examples>
  - `/implement 196` (implement task 196)
  - `/implement 105-107` (implement tasks 105 through 107)
</usage_examples>

<validation>
  <pre_flight>
    - Task(s) exist in TODO.md
    - Tasks not [COMPLETED] or [ABANDONED]
    - If range: all tasks valid
    - Status set to [IN PROGRESS] with Started timestamp
    - Resume phase identified (if plan exists)
  </pre_flight>
  <mid_flight>
    - Implementation agent invoked with correct routing
    - Return validated against subagent-return-format.md
    - Session ID matches expected
    - Artifacts exist on disk
  </mid_flight>
  <post_flight>
    - Status updated to [COMPLETED] (if finished)
    - Artifacts linked in TODO.md
    - state.json synchronized
    - Plan phases updated (if plan exists)
    - Git commit created
    - Registries updated (if code changed)
  </post_flight>
</validation>

<error_handling>
  <timeout>
    If implementation times out after 7200s:
      - Check plan file for partial progress
      - Count completed phases
      - Return partial status
      - Keep task [IN PROGRESS]
      - Provide resume instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error with details
      - Return failed status
      - Keep task [IN PROGRESS]
      - Recommend subagent fix
  </validation_failure>
  <tool_unavailable>
    If lean-lsp-mcp unavailable for Lean task:
      - Log tool unavailability
      - Fallback to direct file modification
      - Continue with degraded mode
      - Note tool unavailability in summary
  </tool_unavailable>
  <build_error>
    If Lean build fails:
      - Log build errors
      - Return failed status
      - Keep task [IN PROGRESS]
      - Provide error details and fix suggestions
  </build_error>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
  <batch_failure>
    If task in range fails:
      - Log failure for that task
      - Continue with next task
      - Return batch summary with failures noted
  </batch_failure>
</error_handling>
