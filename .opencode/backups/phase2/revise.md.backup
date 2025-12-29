---
name: revise
agent: orchestrator
description: "Create new plan versions with [REVISED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number and optional prompt; e.g., `/revise 196`, `/revise 196 "Adjust approach"`)

# Context loaded in Stage 4 (after routing)

<context>
  <system_context>
    Plan revision workflow that creates new plan versions while updating task status.
    Increments plan version number (implementation-002.md, etc.).
  </system_context>
  <domain_context>
    Plan revision for tasks with existing plans. Updates status to [REVISED].
    Useful for adjusting approach based on new information.
  </domain_context>
  <task_context>
    Create new plan version for specified task, update status to [REVISED], update plan
    link in .opencode/specs/TODO.md, and commit new plan.
  </task_context>
  <execution_context>
    Lazy directory creation (specs/NNN_*/plans/ already exists from original plan).
    Status update to [REVISED]. Git commit after revision.
  </execution_context>
</context>

<role>Plan Revision Command - Create new plan versions with status tracking</role>

<task>
  Create new plan version for task, update status to [REVISED], update plan link,
  and commit new plan with status updates.
</task>

<argument_parsing>
  <invocation_format>
    /revise TASK_NUMBER [PROMPT]
    
    Examples:
    - /revise 196
    - /revise 196 "Adjust phase breakdown based on new findings"
  </invocation_format>
  
  <parameters>
    <task_number>
      <position>1</position>
      <type>integer</type>
      <required>true</required>
      <description>The task number from .opencode/specs/TODO.md to revise plan for</description>
      <extraction>Extract first argument after command name as task number</extraction>
      <validation>Must be a valid integer that exists in .opencode/specs/TODO.md with existing plan</validation>
    </task_number>
    
    <prompt>
      <position>2</position>
      <type>string</type>
      <required>false</required>
      <description>Reason for revision or specific changes needed</description>
      <extraction>Extract remaining arguments after task number as prompt string</extraction>
      <default>General plan revision</default>
    </prompt>
  </parameters>
  
  <parsing_logic>
    When user invokes "/revise 196 'Simplify approach'", parse as:
    1. Command: "revise"
    2. Arguments: ["196", "Simplify approach"]
    3. Extracted:
       - task_number = 196
       - prompt = "Simplify approach"
  </parsing_logic>
  
  <error_handling>
    If task_number missing:
      Return: "Error: Task number required. Usage: /revise TASK_NUMBER [PROMPT]"
    If task_number not integer:
      Return: "Error: Task number must be an integer. Got: {input}"
    If task not found in .opencode/specs/TODO.md:
      Return: "Error: Task {task_number} not found in .opencode/specs/TODO.md"
    If task has no existing plan:
      Return: "Error: Task {task_number} has no plan. Use /plan instead."
  </error_handling>
</argument_parsing>

<workflow_execution>
  Follow command-lifecycle.md 8-stage pattern with these variations:
  
  <stage id="1" name="Preflight">
    <status_transition>
      Initial: [PLANNED], [REVISED]
      In-Progress: [REVISING]
    </status_transition>
    <validation>
      - Task number must exist in .opencode/specs/TODO.md
      - Task must have existing plan link
      - Plan file must exist on disk
      - Calculate next plan version number
    </validation>
    <status_update>
      Atomic update via status-sync-manager:
        - .opencode/specs/TODO.md: [REVISING], **Started**: {date} (preserve existing Started if present)
        - state.json: status = "revising"
    </status_update>
  </stage>

  <stage id="2" name="DeterminePlanVersion">
    <action>Calculate next plan version number</action>
    <process>
      1. Extract current plan path from .opencode/specs/TODO.md
      2. Parse version number (implementation-001.md → 1)
      3. Increment version: next_version = current + 1
      4. Format new plan path: implementation-{next_version:03d}.md
      5. Verify new plan path doesn't exist
    </process>
    <version_format>
      implementation-001.md → implementation-002.md
      implementation-002.md → implementation-003.md
      etc.
    </version_format>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <timeout>1800s (30 minutes)</timeout>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "revise", "planner"],
        "timeout": 1800,
        "task_context": {
          "task_number": {number},
          "description": "{description}",
          "language": "{language}",
          "existing_plan_path": "{current_plan_path}",
          "new_plan_version": {next_version},
          "revision_reason": "{reason}",
          "research_inputs": [{research_findings}]
        }
      }
    </delegation_context>
    <special_context>
      existing_plan_path: string (current plan file path)
      new_version: integer (incremented version number)
      revision_reason: string (from user prompt)
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
      Completion: [REVISED] + **Completed**: {date}
      Partial: Keep [REVISING]
      Failed: Keep [REVISING]
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
        - LOG: "Plan artifact validated: {new_plan_path}"
        - IF artifact missing or empty: ABORT with error
      
      STEP 3: EXTRACT plan_metadata
        - EXTRACT phase_count from planner return
        - EXTRACT estimated_hours from planner return
        - EXTRACT complexity from planner return
        - VERIFY all required metadata fields present
        - LOG: "Plan metadata: {phase_count} phases, {estimated_hours} hours, {complexity} complexity"
        - IF any metadata missing: ABORT with error
      
      STEP 4: EXTRACT plan_version
        - EXTRACT plan_version from planner return
        - VERIFY plan_version is positive integer
        - VERIFY plan_version > previous version
        - LOG: "Plan version: {plan_version}"
        - IF plan_version invalid: ABORT with error
      
      CHECKPOINT: Validation completed
        - [ ] Planner return validated
        - [ ] Plan artifact exists on disk
        - [ ] Plan metadata extracted
        - [ ] Plan version extracted and validated
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
              "{new_plan_path from planner return}",
              ".opencode/specs/TODO.md",
              ".opencode/specs/state.json",
              ".opencode/specs/{task_number}_{slug}/state.json"
            ],
            "message_template": "task {number}: plan revised to v{version}",
            "task_context": {
              "task_number": "{number}",
              "description": "plan revised to v{version}"
            },
            "session_id": "{session_id}",
            "delegation_depth": 2,
            "delegation_path": ["orchestrator", "revise", "git-workflow-manager"]
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
          "new_status": "revised",
          "timestamp": "{ISO8601 date}",
          "session_id": "{session_id}",
          "validated_artifacts": "{artifacts from planner return}",
          "plan_path": "{new_plan_path from planner return}",
          "plan_metadata": "{plan_metadata from planner return}",
          "plan_version": "{version from planner return}",
          "revision_reason": "{reason from user prompt}",
          "delegation_depth": 2,
          "delegation_path": ["orchestrator", "revise", "status-sync-manager"]
        }
        ```
        
        VALIDATE delegation context:
          - VERIFY all required fields present
          - VERIFY task_number is positive integer
          - VERIFY new_status is valid value ("revised")
          - VERIFY timestamp is ISO8601 format
          - VERIFY plan_version is positive integer
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
          - VERIFY plan_versions_updated field exists and is true
          - VERIFY rollback_performed == false
          - IF validation fails: ABORT with error details
        
        LOG: "status-sync-manager completed: {files_updated}"
      </step_4_validate_return>
      
      <step_5_verify_on_disk>
        VERIFY files updated on disk:
          - READ .opencode/specs/TODO.md and verify status marker changed to [REVISED]
          - READ .opencode/specs/TODO.md and verify plan link updated to new version
          - READ state.json and verify status field == "revised"
          - READ state.json and verify plan_versions array includes new version
          - IF verification fails: ABORT with error
        
        CHECKPOINT: Atomic update completed successfully
          - [ ] status-sync-manager returned "completed"
          - [ ] .opencode/specs/TODO.md updated on disk
          - [ ] state.json updated on disk
          - [ ] plan_versions array updated
          - [ ] No rollback performed
      </step_5_verify_on_disk>
      
      <status_sync_manager_protocol>
        status-sync-manager performs two-phase commit:
          - Phase 1: Prepare, validate artifacts, backup
          - Phase 2: Write all files or rollback all
        
        Atomicity guaranteed across:
          - .opencode/specs/TODO.md (status, timestamps, updated plan link)
          - state.json (status, timestamps, plan_path, plan_metadata, plan_versions array)
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
                "command": "revise",
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
                "command": "revise",
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
            - Revised Plan: {new_plan_path}
            
            Manual recovery steps:
            1. Verify revised plan artifact exists: {new_plan_path}
            2. Manually update .opencode/specs/TODO.md status to [REVISED]
            3. Manually update .opencode/specs/TODO.md plan link to new version
            4. Manually update state.json status to "revised"
            5. Manually append to state.json plan_versions array
            
            Or retry: /revise {task_number}
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
            Retry: /revise {task_number}
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
            
            Plan revised successfully: {new_plan_path}
            Task status updated to [REVISED]
            
            Manual commit required:
              git add {files}
              git commit -m "task {number}: plan revised to v{version}"
            
            Error: {git_error}
            ```
      </error_case>
    </error_handling>
    
    <stage_7_completion_checkpoint>
      VERIFY all Stage 7 steps completed:
        - [ ] Planner return validated
        - [ ] Plan artifact exists on disk
        - [ ] Plan version validated
        - [ ] status-sync-manager invoked
        - [ ] status-sync-manager returned "completed"
        - [ ] .opencode/specs/TODO.md updated on disk (verified)
        - [ ] state.json updated on disk (verified)
        - [ ] plan_versions array updated (verified)
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
      Plan revised for task {number}
      
      {brief_summary from planner (3-5 sentences, <100 tokens)}
      
      Plan artifact:
      - Version {version}: {new_plan_path}
      
      Task marked [REVISED].
    </return_format>
    <context_window_protection>
      CRITICAL: Return only brief summary (3-5 sentences, <100 tokens) and plan path.
      DO NOT include full plan content.
      Summary is metadata from return object, NOT a separate artifact file.
      Full plan content is in artifact file for user to review separately.
      
      Revised plan is self-documenting (like original plan). NO summary artifact created.
      
      This protects orchestrator context window from bloat.
      
      Reference: artifact-management.md "Context Window Protection via Metadata Passing"
    </context_window_protection>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Plan revision requires project context
  </context_allocation>
  <status_workflow>
    Status flow for revision:
    - Start: [REVISING] with Started timestamp
    - Completion: [REVISED] with Completed timestamp
    - Updates both plan link and status markers
  </status_workflow>
</routing_intelligence>

<artifact_management>
  <lazy_creation>
    Plans directory already exists from original plan
    Create new plan file with incremented version number
  </lazy_creation>
  <artifact_naming>
    New plan: specs/NNN_{task_slug}/plans/implementation-{version:03d}.md
    Version format: 001, 002, 003, etc.
  </artifact_naming>
  <state_sync>
    Update state.json plan_path to new version
    Preserve all other state fields (status, timestamps)
  </state_sync>
</artifact_management>

<quality_standards>
  <status_tracking>
    Track revision status with [REVISING] → [REVISED] flow
    Update plan link and status markers
  </status_tracking>
  <version_incrementing>
    Increment version number correctly
    Use zero-padded format (001, 002, etc.)
  </version_incrementing>

</quality_standards>

<usage_examples>
  - `/revise 196` (revise plan for task 196)
  - `/revise 196 "Adjust phase breakdown based on new findings"`
</usage_examples>

<error_handling>
  Follow command-lifecycle.md error handling patterns:
  
  <no_existing_plan>
    If task has no existing plan:
      - Return error
      - Suggest using /plan instead
      - Abort revision
  </no_existing_plan>
  <timeout>
    If planning times out after 1800s:
      - Check for partial plan
      - Return partial status
      - Provide retry instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error
      - Return failed status
      - Recommend subagent fix
  </validation_failure>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
