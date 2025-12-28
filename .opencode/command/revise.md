---
name: revise
agent: orchestrator
description: "Create new plan versions without changing task status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number and optional prompt; e.g., `/revise 196`, `/revise 196 "Adjust approach"`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md
@.opencode/context/common/system/git-commits.md

<context>
  <system_context>
    Plan revision workflow that creates new plan versions while preserving task status.
    Increments plan version number (implementation-002.md, etc.).
  </system_context>
  <domain_context>
    Plan revision for tasks with existing plans. Does not change task status markers.
    Useful for adjusting approach without restarting task.
  </domain_context>
  <task_context>
    Create new plan version for specified task, preserve current status, update plan
    link in TODO.md, and commit new plan.
  </task_context>
  <execution_context>
    Lazy directory creation (specs/NNN_*/plans/ already exists from original plan).
    Status preservation (no status change). Git commit after revision.
  </execution_context>
</context>

<role>Plan Revision Command - Create new plan versions while preserving status</role>

<task>
  Create new plan version for task, preserve current status, update plan link,
  and commit new plan without changing task status markers.
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
  <stage id="1" name="Preflight">
    <action>Validate task has existing plan</action>
    <process>
      1. Parse task number from input (see <argument_parsing> above)
      2. Load task from TODO.md
      3. Validate task exists
      4. Check for existing plan link in TODO.md
      5. If no plan exists: Error (use /plan instead)
      6. Load existing plan file
      7. Determine next plan version number
      8. Mark task [REVISING] with Started timestamp (or preserve if already has Started)
      9. Update state.json: status = "revising"
    </process>
    <status_update>
      Atomic update via status-sync-manager:
        - TODO.md: [REVISING], **Started**: {date} (preserve existing Started if present)
        - state.json: status = "revising"
    </status_update>
    <validation>
      - Task number must exist in TODO.md
      - Task must have existing plan link
      - Plan file must exist on disk
    </validation>
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

  <stage id="3" name="LoadRevisionContext">
    <action>Load context for plan revision</action>
    <process>
      1. Load existing plan file
      2. Extract phase statuses and completion info
      3. Load research links from TODO.md (if any)
      4. Load task description and language
      5. Prepare revision context for planner
    </process>
    <revision_context>
      - Current plan content
      - Phase completion status
      - Reasons for revision (from user input)
      - Research inputs (if available)
    </revision_context>
  </stage>

  <stage id="4" name="PrepareDelegation">
    <action>Prepare delegation context for planner</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1 (orchestrator → revise → planner)
      3. Set delegation_path = ["orchestrator", "revise", "planner"]
      4. Set timeout = 1800s (30 minutes for planning)
      5. Store session_id for validation
      6. Prepare revision context (existing plan, version, reasons)
    </process>
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
  </stage>

  <stage id="5" name="InvokePlanner">
    <action>Invoke planner with revision context</action>
    <process>
      1. Route to planner subagent
      2. Pass delegation context
      3. Pass existing plan content
      4. Pass revision reason
      5. Pass new version number
      6. Set timeout to 1800s
    </process>
    <invocation>
      task_tool(
        subagent_type="planner",
        prompt="Revise plan for task {number} to version {next_version}: {revision_reason}",
        session_id=delegation_context["session_id"],
        delegation_depth=1,
        delegation_path=delegation_context["delegation_path"],
        timeout=1800,
        existing_plan=current_plan_content,
        new_version=next_version,
        revision_reason=revision_reason
      )
    </invocation>
  </stage>

  <stage id="6" name="ReceiveResults">
    <action>Wait for and receive revised plan</action>
    <process>
      1. Poll for completion (max 1800s)
      2. Receive return object from planner
      3. Validate against subagent-return-format.md
      4. Check session_id matches expected
      5. Handle timeout gracefully
    </process>
    <timeout_handling>
      If timeout (no response after 1800s):
        1. Log timeout error with session_id
        2. Check for partial plan on disk
        3. Return partial status
        4. Provide retry instructions
    </timeout_handling>
    <validation>
      1. Validate return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches
      4. Validate status is valid enum
      5. Validate new plan file exists
    </validation>
  </stage>

  <stage id="7" name="ProcessResults">
    <action>Extract new plan and summary</action>
    <process>
      1. Extract status from return (completed|partial|failed|blocked)
      2. Extract new plan path from artifacts
      3. Extract summary of changes
      4. Extract errors if status != completed
      5. Determine next action based on status
    </process>
    <status_handling>
      If status == "completed":
        - New plan created successfully
        - Proceed to postflight
      If status == "partial":
        - Partial plan created
        - Save partial plan
        - Provide retry instructions
      If status == "failed" or "blocked":
        - No usable plan
        - Handle errors
        - Provide recovery steps
    </status_handling>
  </stage>

  <stage id="8" name="Postflight">
    <action>Update plan link and commit (preserve status)</action>
    <process>
       1. If status == "completed":
          a. Update TODO.md:
             - Update plan link to new version
             - Change status to [REVISED]
             - Add Completed timestamp (preserve Started timestamp)
             - Add note about plan revision
          b. Update state.json:
             - Update plan_path to new version
             - status = "revised"
             - completed = "{YYYY-MM-DD}"
             - Preserve started timestamp
          c. Git commit:
             - Scope: New plan file + TODO.md + state.json
             - Message: "task {number}: plan revised to v{version}"
       2. If status == "partial":
          a. Keep TODO.md status [REVISING]
          b. Add partial plan link
          c. Git commit partial plan:
             - Scope: Partial plan file only
             - Message: "task {number}: partial plan revision"
       3. If status == "failed":
          a. Keep TODO.md status [REVISING]
          b. Add error notes to TODO.md
          c. No git commit
       4. If status == "blocked":
          a. Update TODO.md status to [BLOCKED]
          b. Add blocking reason to TODO.md
          c. Update state.json: status = "blocked", blocked = "{date}"
          d. No git commit
    </process>
    <atomic_update>
      Use status-sync-manager to atomically:
        - Update TODO.md: Update plan link to new version
        - Update TODO.md: Change status to [REVISED]
        - Update TODO.md: Add Completed timestamp
        - Update state.json: status = "revised"
        - Update state.json: completed timestamp
        - Update state.json: plan_path to new version
    </atomic_update>
    <git_commit>
      Scope: New plan file + TODO.md + state.json
      Message: "task {number}: plan revised to v{version}"
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
  </stage>

  <stage id="9" name="ReturnSuccess">
    <action>Return brief summary to user with plan path</action>
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

<validation>
  <pre_flight>
    - Task exists in TODO.md
    - Task has existing plan link
    - Plan file exists on disk
    - New version number calculated
  </pre_flight>
  <mid_flight>
    - Planner invoked with revision context
    - Return validated against subagent-return-format.md
    - Session ID matches expected
    - New plan file exists
  </mid_flight>
  <post_flight>
    - Plan link updated to new version
    - Status PRESERVED (not changed)
    - state.json plan_path updated
    - Git commit created
  </post_flight>
</validation>

<error_handling>
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
