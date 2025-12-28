---
name: revise
agent: orchestrator
description: "Create new plan versions with [REVISED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number and optional prompt; e.g., `/revise 196`, `/revise 196 "Adjust approach"`)

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
    Plan revision workflow that creates new plan versions while updating task status.
    Increments plan version number (implementation-002.md, etc.).
  </system_context>
  <domain_context>
    Plan revision for tasks with existing plans. Updates status to [REVISED].
    Useful for adjusting approach based on new information.
  </domain_context>
  <task_context>
    Create new plan version for specified task, update status to [REVISED], update plan
    link in TODO.md, and commit new plan.
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
      <description>The task number from TODO.md to revise plan for</description>
      <extraction>Extract first argument after command name as task number</extraction>
      <validation>Must be a valid integer that exists in TODO.md with existing plan</validation>
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
    If task not found in TODO.md:
      Return: "Error: Task {task_number} not found in TODO.md"
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
      - Task number must exist in TODO.md
      - Task must have existing plan link
      - Plan file must exist on disk
      - Calculate next plan version number
    </validation>
    <status_update>
      Atomic update via status-sync-manager:
        - TODO.md: [REVISING], **Started**: {date} (preserve existing Started if present)
        - state.json: status = "revising"
    </status_update>
  </stage>

  <stage id="2" name="DeterminePlanVersion">
    <action>Calculate next plan version number</action>
    <process>
      1. Extract current plan path from TODO.md
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

  <!-- Stages 4-6: Follow command-lifecycle.md (no variations) -->

  <stage id="7" name="Postflight">
    <status_transition>
      Completion: [REVISED] + **Completed**: {date}
      Partial: Keep [REVISING]
      Failed: Keep [REVISING]
      Blocked: [BLOCKED]
    </status_transition>
    <validation_delegation>
      Verify planner returned validation success and metadata:
        - Check planner return metadata for validation_result
        - Verify plan artifact validated (exists, non-empty)
        - Extract plan_metadata (phase_count, estimated_hours, complexity)
        - Extract plan_version from planner return
        - If validation failed: Abort update, return error to user
    </validation_delegation>
    <git_commit>
      Scope: New plan file + TODO.md + state.json + project state.json
      Message: "task {number}: plan revised to v{version}"
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
    <atomic_update>
      Delegate to status-sync-manager:
        - task_number: {number}
        - new_status: "revised"
        - timestamp: {ISO8601 date}
        - session_id: {session_id}
        - validated_artifacts: {artifacts from planner return}
        - plan_path: {new_plan_path from planner return}
        - plan_metadata: {plan_metadata from planner return}
        - plan_version: {version from planner return}
        - revision_reason: {reason from user prompt}
      
      status-sync-manager performs two-phase commit:
        - Phase 1: Prepare, validate artifacts, backup
        - Phase 2: Write all files or rollback all
      
      Atomicity guaranteed across:
        - TODO.md (status, timestamps, updated plan link)
        - state.json (status, timestamps, plan_path, plan_metadata, plan_versions array)
        - project state.json (lazy created if needed)
    </atomic_update>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <return_format>
      Plan revised for task {number}
      
      {brief_summary from planner (3-5 sentences)}
      
      Plan artifact:
      - Version {version}: {new_plan_path}
      
      Task marked [REVISED].
    </return_format>
    <context_window_protection>
      CRITICAL: Return only brief summary (3-5 sentences) and plan path.
      DO NOT include full plan content.
      Full plan content is in artifact file for user to review separately.
      This protects orchestrator context window from bloat.
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
  <no_emojis>
    No emojis in plans or status updates
  </no_emojis>
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
