---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
context_level: 2
language: varies
---

**Task Input (required):** $ARGUMENTS (task number or range; e.g., `/implement 197`, `/implement 105-107`)

Context Loaded:
@.opencode/context/common/workflows/command-lifecycle.md
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
  Follow command-lifecycle.md 8-stage pattern with these variations:
  
  <stage id="1" name="Preflight">
    <status_transition>
      Initial: [NOT STARTED], [PLANNED], [REVISED]
      In-Progress: [IMPLEMENTING]
    </status_transition>
    <validation>
      - Task number(s) must exist in TODO.md
      - Tasks must not be [COMPLETED] or [ABANDONED]
      - If range: all tasks in range must be valid
      - Language field must be present
      - Check for plan existence and phase statuses
    </validation>
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
  </stage>

  <stage id="2" name="DetermineRouting">
    <critical_importance>
      CRITICAL: This stage MUST extract the Language field and determine routing.
      DO NOT skip this stage. DO NOT assume language without extraction.
      Incorrect routing bypasses Lean-specific tooling (lean-lsp-mcp).
    </critical_importance>
    <language_extraction>
      Extract Language field from TODO.md task using explicit bash command:
      ```bash
      grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
      ```
      Validate extraction succeeded (non-empty result)
      If extraction fails: default to "general" and log warning
      Log extracted language: "Task ${task_number} language: ${language}"
    </language_extraction>
    <plan_detection>
      Check for plan existence in TODO.md (look for "Plan:" link)
      Log plan status: "Task ${task_number} has_plan: ${has_plan}"
    </plan_detection>
    <routing>
      Determine target agent using explicit IF/ELSE logic:
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
      Log routing decision: "Routing /implement (task ${task_number}, Language: ${language}, has_plan: ${has_plan}) to ${agent} (${mode})"
    </routing>
    <validation>
      MUST complete before Stage 3:
      - Language field extracted and logged
      - Plan existence checked and logged
      - Routing decision made and logged
      - Target agent determined
      - Agent matches language and plan status
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
    <timeout>7200s (2 hours)</timeout>
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
          "plan_path": "{plan_path}" (if has_plan),
          "resume_from_phase": {phase_number} (if resuming)
        }
      }
    </delegation_context>
    <special_context>
      plan_path: string (if plan exists)
      resume_from_phase: integer (if resuming from incomplete phase)
    </special_context>
  </stage>

  <!-- Stages 4-6: Follow command-lifecycle.md (no variations) -->

  <stage id="7" name="Postflight">
    <status_transition>
      Completion: [COMPLETED] + **Completed**: {date} + ✅
      Partial: [PARTIAL] + note about resume
      Failed: Keep [IMPLEMENTING]
      Blocked: [BLOCKED]
    </status_transition>
    <artifact_linking>
      - Implementation: [implementation file paths]
      - Summary: [.opencode/specs/{task_number}_{slug}/summaries/implementation-summary-{date}.md]
    </artifact_linking>
    <git_commit>
      Scope: Implementation files + TODO.md + state.json + plan (if exists)
      Message: "task {number}: implementation completed"
      
      For phased implementation: Create commit per phase
      For direct implementation: Create single commit
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
    <atomic_update>
      Use status-sync-manager to atomically:
        - Update TODO.md: Add implementation artifact links
        - Update TODO.md: Change status to [COMPLETED] or [PARTIAL]
        - Update TODO.md: Add Completed timestamp (if completed)
        - Update state.json: status = "completed" or "partial"
        - Update state.json: completed timestamp (if completed)
        - Update state.json: artifacts array
        - Update plan file: Mark phases [COMPLETED] (if phased)
    </atomic_update>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <return_format>
      Implementation completed for task {number}
      
      {brief_summary from implementation agent (3-5 sentences)}
      
      Artifacts created:
      - Implementation: {file_paths}
      - Summary: {summary_path}
      
      Task marked [COMPLETED].
      
      ---
      
      Or if partial:
      Implementation partially completed for task {number}
      
      {brief_summary from implementation agent}
      
      Partial artifacts: {list}
      Phases completed: {completed_phases} of {total_phases}
      
      Resume with: /implement {number}
    </return_format>
    <context_window_protection>
      CRITICAL: Return only brief summary (3-5 sentences) and artifact paths.
      DO NOT include full implementation code or details.
      Full content is in artifact files for user to review separately.
      This protects orchestrator context window from bloat.
    </context_window_protection>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Implementation requires project context based on language
  </context_allocation>
  <lean_routing>
    If Language: lean → lean-implementation-agent
    - Load .opencode/context/project/lean4/
    - Use lean-lsp-mcp for compilation and verification
    - Support both phased and simple modes
  </lean_routing>
  <general_routing>
    If Language: * AND has_plan → task-executor (phased)
    If Language: * AND no_plan → implementer (direct)
    - Load .opencode/context/project/repo/
    - Use language-appropriate tooling
  </general_routing>
</routing_intelligence>

<artifact_management>
  <lazy_creation>
    Do not create specs/NNN_*/ until writing implementation artifacts
    Create summaries/ subdirectory when writing implementation-summary-{date}.md
  </lazy_creation>
  <artifact_naming>
    Implementation files: Language-specific paths (e.g., Logos/Core/*.lean)
    Implementation summaries: specs/NNN_{task_slug}/summaries/implementation-summary-{YYYYMMDD}.md
  </artifact_naming>
  <state_sync>
    Update state.json with artifact paths when implementation completes
    Sync TODO.md with implementation artifact links
    Update plan file with phase statuses (if phased)
  </state_sync>
</artifact_management>

<quality_standards>
  <status_markers>
    Use [IMPLEMENTING] at start, [COMPLETED] at completion per status-markers.md
    Use [PARTIAL] for incomplete phased implementations
    Include Started and Completed timestamps
  </status_markers>
  <language_routing>
    Route based on TODO.md Language field
    Validate lean-lsp-mcp availability for Lean tasks
  </language_routing>
  <no_emojis>
    No emojis in implementation artifacts, summaries, or status updates
  </no_emojis>
  <atomic_updates>
    Use status-sync-manager for atomic multi-file updates
  </atomic_updates>
</quality_standards>

<usage_examples>
  - `/implement 196` (implement task 196)
  - `/implement 196 "Focus on error handling"` (implement with specific focus)
  - `/implement 105-107` (batch implement tasks 105-107)
</usage_examples>

<error_handling>
  Follow command-lifecycle.md error handling patterns:
  
  <timeout>
    If implementation times out after 7200s:
      - Check for partial artifacts
      - Return partial status
      - Keep task [IMPLEMENTING] or [PARTIAL]
      - Provide resume instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error with details
      - Return failed status
      - Keep task [IMPLEMENTING]
      - Recommend subagent fix
  </validation_failure>
  <tool_unavailable>
    If lean-lsp-mcp or language tools unavailable:
      - Log tool unavailability
      - Attempt degraded mode if possible
      - Return error if tools critical
      - Note tool unavailability in summary
  </tool_unavailable>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
