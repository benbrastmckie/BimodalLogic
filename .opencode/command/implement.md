---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
context_level: 2
language: varies
---

**Task Input (required):** $ARGUMENTS (task number or range; e.g., `/implement 197`, `/implement 105-107`)

# Context loaded in Stage 4 (after routing)

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
        If single: Must be valid integer that exists in .opencode/specs/TODO.md
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
      <default>Use task description and plan from .opencode/specs/TODO.md</default>
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
    If task not found in .opencode/specs/TODO.md:
      Return: "Error: Task {task_number} not found in .opencode/specs/TODO.md"
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
      - Task number(s) must exist in .opencode/specs/TODO.md
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
        - .opencode/specs/TODO.md: [IMPLEMENTING], **Started**: {date}
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
      Extract Language field from .opencode/specs/TODO.md task using explicit bash command:
      ```bash
      grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
      ```
      Validate extraction succeeded (non-empty result)
      If extraction fails: default to "general" and log warning
      Log extracted language: "Task ${task_number} language: ${language}"
    </language_extraction>
    <plan_detection>
      Check for plan existence in .opencode/specs/TODO.md (look for "Plan:" link)
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

  <stage id="4" name="InvokeAgent">
    <task_extraction>
      Extract only the specific task entry from TODO.md to reduce context load:
      
      CRITICAL: Use selective loading to reduce context from 109KB to ~2KB (98% reduction)
      
      Extraction command:
      ```bash
      # Extract task entry (header + 50 lines of content)
      grep -A 50 "^### ${task_number}\." .opencode/specs/TODO.md > /tmp/task-${task_number}.md
      
      # Validate extraction succeeded (non-empty file)
      if [ ! -s /tmp/task-${task_number}.md ]; then
        echo "ERROR: Task ${task_number} not found in TODO.md"
        exit 1
      fi
      
      # Log extraction success
      echo "Extracted task ${task_number} entry ($(wc -l < /tmp/task-${task_number}.md) lines)"
      ```
      
      Fallback: If extraction fails, load full TODO.md and log warning
      
      Edge cases handled:
      - Task at end of file (grep -A 50 captures remaining lines)
      - Task with long description (50 lines sufficient for all current tasks)
      - Non-existent task (validation catches and errors)
      - Malformed task entry (validation catches empty file)
    </task_extraction>
    
    <context_loading>
      Load context files after routing, before delegation:
      @.opencode/context/common/workflows/command-lifecycle.md
      @/tmp/task-${task_number}.md (extracted task entry, ~2KB vs 109KB full TODO.md)
      @.opencode/specs/state.json
      @.opencode/context/common/system/status-markers.md
      @.opencode/context/common/standards/subagent-return-format.md
      @.opencode/context/common/workflows/subagent-delegation-guide.md
      @.opencode/context/common/system/git-commits.md
      
      NOTE: Task extraction reduces context load by 107KB (98% of TODO.md)
      Full TODO.md is 109KB, extracted task entry is ~2KB
    </context_loading>
    <!-- Follow command-lifecycle.md for agent invocation -->
  </stage>

  <!-- Stages 5-6: Follow command-lifecycle.md (no variations) -->

  <stage id="7" name="Postflight">
    <status_transition>
      Completion: [COMPLETED] + **Completed**: {date} + [PASS]
      Partial: [PARTIAL] + note about resume
      Failed: Keep [IMPLEMENTING]
      Blocked: [BLOCKED]
    </status_transition>
    
    <validation_delegation>
      EXECUTE: Verify implementation agent returned validation success
      
      STEP 1: CHECK implementation agent return metadata
        - VERIFY return.status field exists and is valid
        - VERIFY return.metadata.validation_result exists
        - LOG: "Implementation agent validation: {validation_result}"
        - IF validation_result != "success": ABORT with error
      
      STEP 2: VERIFY all artifacts validated
        - CHECK all artifacts exist on disk
        - CHECK all artifacts are non-empty (file size > 0)
        - VERIFY summary artifact within token limit (<100 tokens, ~400 chars)
        - LOG: "Implementation artifacts validated: {artifact_count} files"
        - IF any artifact missing or empty: ABORT with error
        - IF summary artifact exceeds token limit: ABORT with error
      
      STEP 3: EXTRACT and VALIDATE phase_statuses (if phased implementation)
        - DETERMINE implementation mode (phased vs direct)
        - IF phased implementation (task-executor or lean-implementation-agent with plan):
          * VERIFY phase_statuses present in return object
          * VERIFY phase_statuses is non-empty array
          * VERIFY each entry has: phase_number, status, timestamp
          * VERIFY phase numbers are positive integers
          * VERIFY status values are valid: in_progress, completed, abandoned, blocked
          * LOG: "Phase statuses validated: {phase_count} phases"
          * IF phase_statuses missing: ABORT with error "phase_statuses missing for phased implementation"
          * IF phase_statuses malformed: ABORT with error "phase_statuses malformed: {details}"
        - IF direct implementation (implementer):
          * phase_statuses not required
          * LOG: "Direct implementation - no phase_statuses required"
      
      CHECKPOINT: Validation completed
        - [ ] Implementation agent return validated
        - [ ] All artifacts exist on disk
        - [ ] Summary artifact within token limit
        - [ ] phase_statuses validated (if phased)
        - IF any checkpoint fails: ABORT Stage 7, return error to user
    </validation_delegation>
    
    <git_commit>
      <conditional>
        IF status == "completed":
          PROCEED with git commit
        ELSE:
          SKIP git commit
          LOG: "Skipping git commit (status: {status})"
          PROCEED to atomic_update
      </conditional>
      
      <invocation>
        STEP 1: PREPARE git-workflow-manager delegation
          ```json
          {
            "scope_files": [
              "{implementation_files from agent return}",
              "{summary_artifact from agent return}",
              "{plan_path if exists}",
              ".opencode/specs/TODO.md",
              ".opencode/specs/state.json",
              ".opencode/specs/{task_number}_{slug}/state.json"
            ],
            "message_template": "task {number}: implementation completed",
            "task_context": {
              "task_number": "{number}",
              "description": "implementation completed"
            },
            "session_id": "{session_id}",
            "delegation_depth": 2,
            "delegation_path": ["orchestrator", "implement", "git-workflow-manager"]
          }
          ```
        
        NOTE: For phased implementation, per-phase commits are created by task-executor.
        This commit is the final commit after all phases complete.
        
        STEP 2: INVOKE git-workflow-manager
          - Subagent type: "git-workflow-manager"
          - Delegation context: {prepared context}
          - Timeout: 120s
          - LOG: "Invoking git-workflow-manager for task {number}"
        
        STEP 3: WAIT for git-workflow-manager return
          - Maximum wait: 120s
          - IF timeout: LOG error (non-critical), continue
        
        STEP 4: VALIDATE return
          - IF status == "completed":
            * EXTRACT commit_hash from commit_info
            * LOG: "Git commit created: {commit_hash}"
          
          - IF status == "failed":
            * LOG error to errors.json (non-critical)
            * INCLUDE warning in Stage 8 return
            * CONTINUE (git failure doesn't fail command)
      </invocation>
      
      CHECKPOINT: Git commit completed (if applicable)
        - [ ] Git commit attempted (if status == "completed")
        - [ ] Git commit succeeded OR failure logged (non-critical)
    </git_commit>
    
    <atomic_update>
      <action>INVOKE status-sync-manager subagent</action>
      
      <step_1_prepare_delegation>
        PREPARE delegation context:
        ```json
        {
          "task_number": "{number}",
          "new_status": "{completed or partial}",
          "timestamp": "{ISO8601 date}",
          "session_id": "{session_id}",
          "validated_artifacts": "{artifacts from implementation agent return}",
          "plan_path": "{plan_path if exists}",
          "phase_statuses": "{phase_statuses from agent return if phased}",
          "delegation_depth": 2,
          "delegation_path": ["orchestrator", "implement", "status-sync-manager"]
        }
        ```
        
        VALIDATE delegation context:
          - VERIFY all required fields present
          - VERIFY task_number is positive integer
          - VERIFY new_status is valid value ("completed" or "partial")
          - VERIFY timestamp is ISO8601 format
          - IF phased implementation:
            * VERIFY phase_statuses present
            * VERIFY phase_statuses is non-empty array
            * LOG: "Passing phase_statuses to status-sync-manager: {phase_count} phases"
          - IF validation fails: ABORT with error
      </step_1_prepare_delegation>
      
      <step_2_invoke>
        INVOKE status-sync-manager:
          - Subagent type: "status-sync-manager"
          - Delegation context: {prepared context}
          - Timeout: 60s
          - Delegation mechanism: Per subagent-delegation-guide.md
        
        LOG: "Invoking status-sync-manager for task {number}"
      </step_2_invoke>
      
      <step_3_wait>
        WAIT for status-sync-manager return:
          - Maximum wait: 60s
          - IF timeout: ABORT with error "status-sync-manager timeout after 60s"
      </step_3_wait>
      
      <step_4_validate_return>
        VALIDATE status-sync-manager return:
          - VERIFY return format matches subagent-return-format.md
          - VERIFY status field == "completed" (not "failed" or "partial")
          - VERIFY files_updated includes [".opencode/specs/TODO.md", "state.json"]
          - IF phased implementation:
            * VERIFY files_updated includes plan file
            * VERIFY plan_phases_updated field exists and is true
          - VERIFY rollback_performed == false
          - IF validation fails: ABORT with error details
        
        LOG: "status-sync-manager completed: {files_updated}"
      </step_4_validate_return>
      
      <step_5_verify_on_disk>
        VERIFY files updated on disk:
          - READ .opencode/specs/TODO.md and verify status marker changed to [COMPLETED] or [PARTIAL]
          - READ state.json and verify status field == "completed" or "partial"
          - IF phased implementation:
            * READ plan file and verify phase statuses updated
            * VERIFY at least one phase marked [COMPLETED]
          - IF verification fails: ABORT with error
        
        CHECKPOINT: Atomic update completed successfully
          - [ ] status-sync-manager returned "completed"
          - [ ] .opencode/specs/TODO.md updated on disk
          - [ ] state.json updated on disk
          - [ ] Plan file updated (if phased)
          - [ ] No rollback performed
      </step_5_verify_on_disk>
      
      <status_sync_manager_protocol>
        status-sync-manager performs two-phase commit:
          - Phase 1: Prepare, validate artifacts, backup, parse plan file
          - Phase 2: Write all files (.opencode/specs/TODO.md, state.json, project state.json, plan file) or rollback all
        
        Atomicity guaranteed across:
          - .opencode/specs/TODO.md (status, timestamps, artifact links, checkmark if completed)
          - state.json (status, timestamps, artifacts array)
          - project state.json (lazy created if needed, CRITICAL: fail if creation fails)
          - plan file (phase statuses updated atomically if phase_statuses provided)
      </status_sync_manager_protocol>
    </atomic_update>
    
    <error_handling>
      <error_case name="validation_failed">
        IF validation fails before delegation:
          STEP 1: ABORT immediately
            - DO NOT invoke status-sync-manager
            - DO NOT invoke git-workflow-manager
          
          STEP 2: LOG error to errors.json
            ```json
            {
              "type": "validation_failed",
              "severity": "high",
              "context": {
                "command": "implement",
                "task_number": "{number}",
                "session_id": "{session_id}",
                "stage": 7
              },
              "message": "Implementation agent return validation failed: {error}",
              "fix_status": "not_addressed"
            }
            ```
          
          STEP 3: RETURN validation error to user
            ```
            Error: Validation failed
            
            Details: {validation_error}
            
            Recommendation: Fix implementation agent implementation
            ```
      </error_case>
      
      <error_case name="phase_statuses_missing">
        IF phased implementation AND phase_statuses missing:
          STEP 1: ABORT immediately
          
          STEP 2: LOG error to errors.json
            ```json
            {
              "type": "phase_statuses_missing",
              "severity": "high",
              "context": {
                "command": "implement",
                "task_number": "{number}",
                "session_id": "{session_id}",
                "stage": 7,
                "implementation_mode": "phased"
              },
              "message": "phase_statuses missing in task-executor return",
              "fix_status": "not_addressed"
            }
            ```
          
          STEP 3: RETURN error to user
            ```
            Error: phase_statuses missing
            
            Implementation mode: phased
            Agent: {agent_name}
            
            phase_statuses required for phased implementations but not found in return object.
            
            Recommendation: Fix task-executor to include phase_statuses in return
            ```
      </error_case>
      
      <error_case name="status_sync_manager_failed">
        IF status-sync-manager returns status == "failed":
          STEP 1: EXTRACT error details
            - error_type: {type from errors array}
            - error_message: {message from errors array}
            - rollback_performed: {boolean}
          
          STEP 2: LOG error to errors.json
            ```json
            {
              "type": "status_sync_failed",
              "severity": "high",
              "context": {
                "command": "implement",
                "task_number": "{number}",
                "session_id": "{session_id}",
                "stage": 7
              },
              "message": "status-sync-manager failed: {error_message}",
              "fix_status": "not_addressed"
            }
            ```
          
          STEP 3: ABORT Stage 7
            - DO NOT proceed to git commit
            - DO NOT proceed to Stage 8
          
          STEP 4: RETURN error to user
            ```
            Error: Failed to update task status
            
            Details: {error_message}
            
            Artifacts created:
            - Implementation: {file_paths}
            - Summary: {summary_path}
            
            Manual recovery steps:
            1. Verify implementation artifacts exist
            2. Manually update .opencode/specs/TODO.md status to [COMPLETED]
            3. Manually update state.json status to "completed"
            4. Manually update plan file phase statuses (if phased)
            5. Manually link artifacts in .opencode/specs/TODO.md
            
            Or retry: /implement {task_number}
            ```
      </error_case>
      
      <error_case name="status_sync_manager_timeout">
        IF status-sync-manager times out after 60s:
          STEP 1: LOG timeout
          
          STEP 2: CHECK files on disk
            - IF .opencode/specs/TODO.md updated: Partial success
            - IF state.json updated: Partial success
            - IF plan file updated: Partial success
            - IF neither updated: Complete failure
          
          STEP 3: RETURN appropriate error
            ```
            Error: Status update timed out
            
            Status: {partial or complete failure}
            
            Files updated:
            - .opencode/specs/TODO.md: {yes/no}
            - state.json: {yes/no}
            - Plan file: {yes/no}
            
            Recommendation: Check status-sync-manager implementation
            Retry: /implement {task_number}
            ```
      </error_case>
      
      <error_case name="git_commit_failed">
        IF git-workflow-manager returns status == "failed":
          STEP 1: LOG error (non-critical)
            - Git failure does not fail the command
            - Artifacts and status updates still valid
          
          STEP 2: CONTINUE to Stage 8
            - Include git failure warning in return
          
          STEP 3: RETURN success with warning
            ```
            Warning: Git commit failed
            
            Implementation completed successfully: {file_paths}
            Task status updated to [COMPLETED]
            
            Manual commit required:
              git add {files}
              git commit -m "task {number}: implementation completed"
            
            Error: {git_error}
            ```
      </error_case>
    </error_handling>
    
    <stage_7_completion_checkpoint>
      VERIFY all Stage 7 steps completed:
        - [ ] Implementation agent return validated
        - [ ] All artifacts exist on disk
        - [ ] Summary artifact within token limit
        - [ ] phase_statuses validated (if phased)
        - [ ] status-sync-manager invoked
        - [ ] status-sync-manager returned "completed"
        - [ ] .opencode/specs/TODO.md updated on disk (verified)
        - [ ] state.json updated on disk (verified)
        - [ ] Plan file updated (if phased, verified)
        - [ ] git-workflow-manager invoked (if status == "completed")
      
      IF any checkpoint fails:
        - ABORT Stage 8
        - RETURN error to user with checkpoint failure details
        - Include manual recovery instructions
      
      IF all checkpoints pass:
        - LOG: "Stage 7 (Postflight) completed successfully"
        - PROCEED to Stage 8
    </stage_7_completion_checkpoint>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <prerequisite>
      REQUIRE: Stage 7 completion checkpoint passed
      IF Stage 7 not completed: ABORT with error
    </prerequisite>
    
    <return_format>
      Implementation completed for task {number}
      
      {brief_summary from implementation agent (3-5 sentences, <100 tokens)}
      
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
      CRITICAL: Return only brief summary (3-5 sentences, <100 tokens) and artifact paths.
      DO NOT include full implementation code or details.
      Summary is metadata from return object, NOT just the summary artifact.
      Full content is in artifact files for user to review separately.
      
      Implementation creates N+1 artifacts:
      - N implementation files (code, documentation, etc.)
      - 1 summary artifact (implementation-summary-YYYYMMDD.md)
      
      Summary artifact required for multi-file outputs to provide unified overview.
      This protects orchestrator context window from reading N files.
      
      Reference: artifact-management.md "Context Window Protection via Metadata Passing"
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
    Sync .opencode/specs/TODO.md with implementation artifact links
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
    Route based on .opencode/specs/TODO.md Language field
    Validate lean-lsp-mcp availability for Lean tasks
  </language_routing>

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
