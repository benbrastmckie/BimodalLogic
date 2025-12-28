---
name: plan
agent: orchestrator
description: "Create implementation plans with [PLANNED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/plan 197`, `/plan 196`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md
@.opencode/context/common/system/git-commits.md

<context>
  <system_context>
    Planning workflow with research harvesting, phase breakdown, and [PLANNED]
    status marker. Creates implementation plans following plan.md template.
  </system_context>
  <domain_context>
    Implementation planning for both Lean and general tasks. Harvests research
    links from TODO.md and incorporates findings into plan.
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
      <description>The task number from TODO.md to plan</description>
      <extraction>Extract first argument after command name as task number</extraction>
      <validation>Must be a valid integer that exists in TODO.md</validation>
    </task_number>
    
    <prompt>
      <position>2</position>
      <type>string</type>
      <required>false</required>
      <description>Optional additional context for planning</description>
      <extraction>Extract remaining arguments after task number as prompt string</extraction>
      <default>Use task description and research findings from TODO.md</default>
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
    If task not found in TODO.md:
      Return: "Error: Task {task_number} not found in TODO.md"
  </error_handling>
</argument_parsing>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate task and prepare for planning</action>
    <process>
      1. Parse task number from input (see <argument_parsing> above)
      2. Load task from TODO.md
      3. Validate task exists and is not [COMPLETED]
      4. Extract task description and language
      5. Check for existing plan (warn if exists)
      6. Mark task [PLANNING] with Started timestamp
      7. Update state.json: status = "planning", started = "{YYYY-MM-DD}"
    </process>
    <status_update>
      Atomic update via status-sync-manager:
        - TODO.md: [PLANNING], **Started**: {date}
        - state.json: status = "planning", started = "{date}"
    </status_update>
    <validation>
      - Task number must exist in TODO.md
      - Task must not be [COMPLETED] or [ABANDONED]
      - Warn if plan already exists (suggest /revise instead)
    </validation>
  </stage>

  <stage id="2" name="HarvestResearch">
    <action>Extract research links from TODO.md</action>
    <process>
      1. Scan TODO.md task entry for research links
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
    <action>Prepare delegation context for planner</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1 (orchestrator → plan → planner)
      3. Set delegation_path = ["orchestrator", "plan", "planner"]
      4. Set timeout = 1800s (30 minutes for planning)
      5. Store session_id for validation
      6. Prepare planning context (task, language, research)
    </process>
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
  </stage>

  <stage id="4" name="InvokePlanner">
    <action>Invoke planner subagent</action>
    <process>
      1. Route to planner subagent
      2. Pass delegation context
      3. Pass task description and language
      4. Pass research inputs if available
      5. Set timeout to 1800s
    </process>
    <invocation>
      task_tool(
        subagent_type="planner",
        prompt="Create implementation plan for task {number}: {description}",
        session_id=delegation_context["session_id"],
        delegation_depth=1,
        delegation_path=delegation_context["delegation_path"],
        timeout=1800,
        research_inputs=research_findings
      )
    </invocation>
  </stage>

  <stage id="5" name="ReceiveResults">
    <action>Wait for and receive planning results</action>
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
        3. Return partial status with plan found
        4. Keep task [PLANNING] (not failed)
        5. Message: "Planning timed out after 30 minutes. Partial plan available. Resume with /plan {number}"
    </timeout_handling>
    <validation>
      1. Validate return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches
      4. Validate status is valid enum (completed|partial|failed|blocked)
      5. Validate artifacts array structure
      6. Check plan file exists
    </validation>
  </stage>

  <stage id="6" name="ProcessResults">
    <action>Extract plan artifacts and summary from validated return</action>
    <process>
      1. Extract status from return (completed|partial|failed|blocked)
      2. Extract plan path from artifacts array
      3. Extract summary for TODO.md
      4. Extract phase count and effort estimate
      5. Extract errors if status != completed
      6. Determine next action based on status
    </process>
    <status_handling>
      If status == "completed":
        - Plan created successfully
        - Proceed to postflight with plan path
      If status == "partial":
        - Partial plan created
        - Keep task [PLANNING]
        - Save partial plan
        - Provide resume instructions
      If status == "failed":
        - No usable plan
        - Handle errors
        - Provide recovery steps
      If status == "blocked":
        - Mark task [BLOCKED]
        - Cannot proceed
        - Identify blocker
        - Request user intervention
    </status_handling>
  </stage>

  <stage id="7" name="Postflight">
    <action>Update status, link plan, and commit</action>
    <process>
      1. If status == "completed":
         a. Update TODO.md:
            - Add plan link
            - Change status to [PLANNED]
            - Add Completed timestamp
            - Add phase count and effort estimate
         b. Update state.json:
            - status = "planned"
            - completed = "{YYYY-MM-DD}"
            - plan_path = "{plan_path}"
            - phases = {phase_count}
            - estimated_effort = {effort}
         c. Git commit:
            - Scope: Plan file + TODO.md + state.json
            - Message: "task {number}: plan created"
       2. If status == "partial":
          a. Keep TODO.md status [PLANNING]
          b. Add partial plan link
          c. Git commit partial plan:
             - Scope: Partial plan file only
             - Message: "task {number}: partial plan created"
       3. If status == "failed":
          a. Keep TODO.md status [PLANNING]
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
        - Update TODO.md: Add plan link
        - Update TODO.md: Change status to [PLANNED]
        - Update TODO.md: Add Completed timestamp
        - Update state.json: status = "planned"
        - Update state.json: completed timestamp
        - Update state.json: plan_path
    </atomic_update>
    <git_commit>
      Scope: Plan file + TODO.md + state.json
      Message: "task {number}: plan created"
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <action>Return brief summary with plan reference</action>
    <process>
      1. Extract brief summary from planner return (already <100 tokens)
      2. Extract plan path from artifacts array
      3. Return brief format to orchestrator (3-5 sentences, <100 tokens)
      4. No summary artifact needed - plan artifact is self-documenting
    </process>
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
      
      Example (partial):
      ```
      Plan partially created for task 198.
      Research findings incomplete, created initial 2 phases.
      Resume with: /plan 198
      Plan: .opencode/specs/198_task_name/plans/implementation-001.md
      ```
    </return_format>
    <token_limit>
      Return must be under 100 tokens (approximately 400 characters).
      Brief overview must be 3-5 sentences maximum.
      Full details are in the plan artifact file (no separate summary).
    </token_limit>
    <rationale>
      Plan artifact is self-documenting and contains all details.
      Unlike /implement (which creates multiple code files), /plan creates
      ONE artifact (the plan) which serves as its own documentation.
      No summary artifact needed.
    </rationale>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Planning requires project context based on language
  </context_allocation>
  <research_harvesting>
    Check TODO.md for research links
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
    Sync TODO.md with plan link
  </state_sync>
</artifact_management>

<quality_standards>
  <status_markers>
    Use [IN PROGRESS] at start, [PLANNED] at completion per status-markers.md
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
  <no_emojis>
    No emojis in plans or status updates
  </no_emojis>
  <atomic_updates>
    Use status-sync-manager for atomic multi-file updates
  </atomic_updates>
</quality_standards>

<usage_examples>
  - `/plan 196` (create plan for task 196)
</usage_examples>

<validation>
  <pre_flight>
    - Task exists in TODO.md
    - Task not [COMPLETED] or [ABANDONED]
    - Warn if plan already exists
    - Status set to [IN PROGRESS] with Started timestamp
  </pre_flight>
  <mid_flight>
    - Planner invoked successfully
    - Return validated against subagent-return-format.md
    - Session ID matches expected
    - Plan file exists on disk
  </mid_flight>
  <post_flight>
    - Status updated to [PLANNED] (if completed)
    - Plan linked in TODO.md
    - state.json synchronized
    - Git commit created (if completed)
  </post_flight>
</validation>

<error_handling>
  <timeout>
    If planning times out after 1800s:
      - Check for partial plan
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
