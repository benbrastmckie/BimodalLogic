---
name: plan
agent: orchestrator
description: "Create implementation plans with [PLANNED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/plan 197`, `/plan 196`)

# Context loaded in Stage 4 (after routing)

<context>
  <system_context>
    Planning workflow with research harvesting, phase breakdown, and [PLANNED]
    status marker. Creates implementation plans following plan.md template.
  </system_context>
  <domain_context>
    Implementation planning for both Lean and general tasks. Harvests research
    links from .opencode/specs/TODO.md and incorporates findings into plan.
  </domain_context>
  <task_context>
    Create implementation plan for specified task, harvest research if available,
    create plan with phases, update status to [PLANNED], and commit artifacts.
  </task_context>
  <execution_context>
    Lazy directory creation (specs/NNN_*/plans/ only when writing). Atomic status
    synchronization via status-sync-manager. Git commit after completion.
  </execution_context>
</context>

<role>Planning Command - Create implementation plans with research integration</role>

<task>
  Create implementation plan for task, harvest research links, create phased plan,
  update status to [PLANNED] with timestamps, and commit changes.
</task>

<argument_parsing>
  <invocation_format>
    /plan TASK_NUMBER [PROMPT]
    
    Examples:
    - /plan 196
    - /plan 196 "Focus on phase breakdown"
  </invocation_format>
  
  <parameters>
    <task_number>
      <position>1</position>
      <type>integer</type>
      <required>true</required>
      <description>The task number from .opencode/specs/TODO.md to plan</description>
      <extraction>Extract first argument after command name as task number</extraction>
      <validation>Must be a valid integer that exists in .opencode/specs/TODO.md</validation>
    </task_number>
    
    <prompt>
      <position>2</position>
      <type>string</type>
      <required>false</required>
      <description>Optional additional context for planning</description>
      <extraction>Extract remaining arguments after task number as prompt string</extraction>
      <default>Use task description and research findings from .opencode/specs/TODO.md</default>
    </prompt>
  </parameters>
  
  <parsing_logic>
    When user invokes "/plan 196 'Emphasize testing'", parse as:
    1. Command: "plan"
    2. Arguments: ["196", "Emphasize testing"]
    3. Extracted:
       - task_number = 196
       - prompt = "Emphasize testing"
  </parsing_logic>
  
  <error_handling>
    If task_number missing:
      Return: "Error: Task number required. Usage: /plan TASK_NUMBER [PROMPT]"
    If task_number not integer:
      Return: "Error: Task number must be an integer. Got: {input}"
    If task not found in .opencode/specs/TODO.md:
      Return: "Error: Task {task_number} not found in .opencode/specs/TODO.md"
  </error_handling>
</argument_parsing>

<workflow_execution>
  Follow command-lifecycle.md 8-stage pattern with these variations:
  
  <stage id="1" name="Preflight">
    <status_transition>
      Initial: [NOT STARTED], [RESEARCHED]
      In-Progress: [PLANNING]
    </status_transition>
    <validation>
      - Task number must exist in .opencode/specs/TODO.md
      - Task must not be [COMPLETED] or [ABANDONED]
      - Warn if plan already exists (suggest /revise instead)
    </validation>
    <status_update>
      Atomic update via status-sync-manager:
        - .opencode/specs/TODO.md: [PLANNING], **Started**: {date}
        - state.json: status = "planning", started = "{date}"
    </status_update>
  </stage>

  <stage id="2" name="HarvestResearch">
    <action>Extract research links from .opencode/specs/TODO.md</action>
    <process>
      1. Scan .opencode/specs/TODO.md task entry for research links
      2. Extract paths to research reports and summaries
      3. Load research artifacts if present
      4. Extract key findings for plan context
      5. Prepare research inputs for planner
    </process>
    <research_integration>
      If research links found:
        - Load research-001.md and research-summary.md
        - Extract key findings and recommendations
        - Pass to planner as "Research Inputs" section
      If no research:
        - Proceed without research context
        - Note in plan that no prior research available
    </research_integration>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <timeout>1800s (30 minutes)</timeout>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "plan", "planner"],
        "timeout": 1800,
        "task_context": {
          "task_number": {number},
          "description": "{description}",
          "language": "{language}",
          "research_inputs": [{research_findings}]
        }
      }
    </delegation_context>
    <special_context>
      research_inputs: array (paths to research artifacts from .opencode/specs/TODO.md)
    </special_context>
    <routing>
      No language-based routing - always routes to planner subagent
    </routing>
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
      Completion: [PLANNED] + **Completed**: {date}
      Partial: Keep [PLANNING]
      Failed: Keep [PLANNING]
      Blocked: [BLOCKED]
    </status_transition>
    
    <validation_delegation>
      EXECUTE: Verify planner returned validation success and metadata
      
      STEP 1: CHECK planner return metadata
        - VERIFY return.status field exists and is valid
        - VERIFY return.metadata.validation_result exists
        - LOG: "Planner validation: {validation_result}"
        - IF validation_result != "success": ABORT with error
      
      STEP 2: VERIFY plan artifact validated
        - CHECK plan artifact exists on disk
        - CHECK plan artifact is non-empty (file size > 0)
        - LOG: "Plan artifact validated: {plan_path}"
        - IF artifact missing or empty: ABORT with error
      
      STEP 3: EXTRACT plan_metadata
        - EXTRACT phase_count from planner return
        - EXTRACT estimated_hours from planner return
        - EXTRACT complexity from planner return
        - VERIFY all required metadata fields present
        - LOG: "Plan metadata: {phase_count} phases, {estimated_hours} hours, {complexity} complexity"
        - IF any metadata missing: ABORT with error
      
      CHECKPOINT: Validation completed
        - [ ] Planner return validated
        - [ ] Plan artifact exists on disk
        - [ ] Plan metadata extracted
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
              "{plan_path from planner return}",
              ".opencode/specs/TODO.md",
              ".opencode/specs/state.json",
              ".opencode/specs/{task_number}_{slug}/state.json"
            ],
            "message_template": "task {number}: plan created",
            "task_context": {
              "task_number": "{number}",
              "description": "plan created"
            },
            "session_id": "{session_id}",
            "delegation_depth": 2,
            "delegation_path": ["orchestrator", "plan", "git-workflow-manager"]
          }
          ```
        
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
          "new_status": "planned",
          "timestamp": "{ISO8601 date}",
          "session_id": "{session_id}",
          "validated_artifacts": "{artifacts from planner return}",
          "plan_path": "{plan_path from planner return}",
          "plan_metadata": "{plan_metadata from planner return}",
          "delegation_depth": 2,
          "delegation_path": ["orchestrator", "plan", "status-sync-manager"]
        }
        ```
        
        VALIDATE delegation context:
          - VERIFY all required fields present
          - VERIFY task_number is positive integer
          - VERIFY new_status is valid value ("planned")
          - VERIFY timestamp is ISO8601 format
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
          - VERIFY rollback_performed == false
          - IF validation fails: ABORT with error details
        
        LOG: "status-sync-manager completed: {files_updated}"
      </step_4_validate_return>
      
      <step_5_verify_on_disk>
        VERIFY files updated on disk:
          - READ .opencode/specs/TODO.md and verify status marker changed to [PLANNED]
          - READ state.json and verify status field == "planned"
          - IF verification fails: ABORT with error
        
        CHECKPOINT: Atomic update completed successfully
          - [ ] status-sync-manager returned "completed"
          - [ ] .opencode/specs/TODO.md updated on disk
          - [ ] state.json updated on disk
          - [ ] No rollback performed
      </step_5_verify_on_disk>
      
      <status_sync_manager_protocol>
        status-sync-manager performs two-phase commit:
          - Phase 1: Prepare, validate artifacts, backup
          - Phase 2: Write all files or rollback all
        
        Atomicity guaranteed across:
          - .opencode/specs/TODO.md (status, timestamps, plan link)
          - state.json (status, timestamps, plan_path, plan_metadata)
          - project state.json (lazy created if needed)
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
                "command": "plan",
                "task_number": "{number}",
                "session_id": "{session_id}",
                "stage": 7
              },
              "message": "Planner return validation failed: {error}",
              "fix_status": "not_addressed"
            }
            ```
          
          STEP 3: RETURN validation error to user
            ```
            Error: Validation failed
            
            Details: {validation_error}
            
            Recommendation: Fix planner subagent implementation
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
                "command": "plan",
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
            - Plan: {plan_path}
            
            Manual recovery steps:
            1. Verify plan artifact exists: {plan_path}
            2. Manually update .opencode/specs/TODO.md status to [PLANNED]
            3. Manually update state.json status to "planned"
            4. Manually link plan in .opencode/specs/TODO.md
            
            Or retry: /plan {task_number}
            ```
      </error_case>
      
      <error_case name="status_sync_manager_timeout">
        IF status-sync-manager times out after 60s:
          STEP 1: LOG timeout
          
          STEP 2: CHECK files on disk
            - IF .opencode/specs/TODO.md updated: Partial success
            - IF state.json updated: Partial success
            - IF neither updated: Complete failure
          
          STEP 3: RETURN appropriate error
            ```
            Error: Status update timed out
            
            Status: {partial or complete failure}
            
            Files updated:
            - .opencode/specs/TODO.md: {yes/no}
            - state.json: {yes/no}
            
            Recommendation: Check status-sync-manager implementation
            Retry: /plan {task_number}
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
            
            Plan created successfully: {plan_path}
            Task status updated to [PLANNED]
            
            Manual commit required:
              git add {files}
              git commit -m "task {number}: plan created"
            
            Error: {git_error}
            ```
      </error_case>
    </error_handling>
    
    <stage_7_completion_checkpoint>
      VERIFY all Stage 7 steps completed:
        - [ ] Planner return validated
        - [ ] Plan artifact exists on disk
        - [ ] status-sync-manager invoked
        - [ ] status-sync-manager returned "completed"
        - [ ] .opencode/specs/TODO.md updated on disk (verified)
        - [ ] state.json updated on disk (verified)
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
      If completed:
      ```
      Plan created for task {number}.
      {brief_1_sentence_overview}
      {phase_count} phases, {effort} hours estimated.
      Plan: {plan_path}
      ```
      
      Example (completed):
      ```
      Plan created for task 195.
      Integrated LeanSearch API research findings into 4-phase implementation.
      4 phases, 6 hours estimated.
      Plan: .opencode/specs/195_lean_tools/plans/implementation-001.md
      ```
      
      If partial:
      ```
      Plan partially created for task {number}.
      {brief_reason}
      Resume with: /plan {number}
      Plan: {plan_path}
      ```
    </return_format>
    <token_limit>
      Return must be under 100 tokens (approximately 400 characters).
      Brief overview must be 3-5 sentences maximum.
      Full details are in the plan artifact file (no separate summary).
    </token_limit>
    <context_window_protection>
      Plan artifact is self-documenting and contains all details.
      Unlike /implement (which creates multiple code files), /plan creates
      ONE artifact (the plan) which serves as its own documentation.
      
      NO summary artifact created. Summary is returned as metadata in the
      return object summary field, NOT as a separate file.
      
      This protects the orchestrator's context window from bloat while
      providing necessary metadata for task tracking.
      
      Reference: artifact-management.md "Context Window Protection via Metadata Passing"
    </context_window_protection>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Planning requires project context based on language
  </context_allocation>
  <research_harvesting>
    Check .opencode/specs/TODO.md for research links
    Load research artifacts if present
    Pass research findings to planner
  </research_harvesting>
</routing_intelligence>

<artifact_management>
  <lazy_creation>
    Do not create specs/NNN_*/ until writing plan
    Create only plans/ subdirectory when writing implementation-001.md
  </lazy_creation>
  <artifact_naming>
    Implementation plans: specs/NNN_{task_slug}/plans/implementation-001.md
    Follow plan.md template structure
  </artifact_naming>
  <state_sync>
    Update state.json with plan path when planning completes
    Sync .opencode/specs/TODO.md with plan link
  </state_sync>
</artifact_management>

<quality_standards>
  <status_markers>
    Use [PLANNING] at start, [PLANNED] at completion per status-markers.md
    Include Started and Completed timestamps
  </status_markers>
  <plan_template>
    Follow plan.md template structure:
      - Metadata (project number, type, priority, complexity, estimated hours, phases)
      - Overview
      - Research Inputs (if available)
      - Phase breakdown with acceptance criteria
      - Success criteria
  </plan_template>

  <atomic_updates>
    Use status-sync-manager for atomic multi-file updates
  </atomic_updates>
</quality_standards>

<usage_examples>
  - `/plan 196` (create plan for task 196)
</usage_examples>

<error_handling>
  Follow command-lifecycle.md error handling patterns:
  
  <timeout>
    If planning times out after 1800s:
      - Check for partial plan
      - Return partial status
      - Keep task [PLANNING]
      - Provide resume instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error with details
      - Return failed status
      - Keep task [PLANNING]
      - Recommend subagent fix
  </validation_failure>
  <existing_plan>
    If plan already exists:
      - Warn user
      - Suggest /revise instead
      - Abort planning
  </existing_plan>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
