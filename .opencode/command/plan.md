---
name: plan
agent: orchestrator
description: "Create implementation plans with [PLANNED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/plan 197`, `/plan 196`)

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
  Follow command-lifecycle.md 8-stage pattern with these variations:
  
  <stage id="1" name="Preflight">
    <status_transition>
      Initial: [NOT STARTED], [RESEARCHED]
      In-Progress: [PLANNING]
    </status_transition>
    <validation>
      - Task number must exist in TODO.md
      - Task must not be [COMPLETED] or [ABANDONED]
      - Warn if plan already exists (suggest /revise instead)
    </validation>
    <status_update>
      Atomic update via status-sync-manager:
        - TODO.md: [PLANNING], **Started**: {date}
        - state.json: status = "planning", started = "{date}"
    </status_update>
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
      research_inputs: array (paths to research artifacts from TODO.md)
    </special_context>
    <routing>
      No language-based routing - always routes to planner subagent
    </routing>
  </stage>

  <!-- Stages 4-6: Follow command-lifecycle.md (no variations) -->

  <stage id="7" name="Postflight">
    <status_transition>
      Completion: [PLANNED] + **Completed**: {date}
      Partial: Keep [PLANNING]
      Failed: Keep [PLANNING]
      Blocked: [BLOCKED]
    </status_transition>
    <artifact_linking>
      - Plan: [.opencode/specs/{task_number}_{slug}/plans/implementation-001.md]
      - Plan Summary: {brief_summary} ({phase_count} phases, {effort} hours)
    </artifact_linking>
    <git_commit>
      Scope: Plan file + TODO.md + state.json
      Message: "task {number}: plan created"
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
    <atomic_update>
      Use status-sync-manager to atomically:
        - Update TODO.md: Add plan link
        - Update TODO.md: Change status to [PLANNED]
        - Update TODO.md: Add Completed timestamp
        - Update state.json: status = "planned"
        - Update state.json: completed timestamp
        - Update state.json: plan_path
    </atomic_update>
  </stage>

  <stage id="8" name="ReturnSuccess">
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
