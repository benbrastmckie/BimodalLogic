---
name: plan
agent: orchestrator
description: "Create implementation plans with [PLANNED] status"
context_level: 2
language: markdown
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/workflows/status-transitions.md"
    - "core/system/routing-guide.md"
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/plan 197`, `/plan 196`)

<context>
  <system_context>
    Planning command that creates implementation plans with phased breakdown, effort estimates,
    and research integration. Updates task status to [PLANNED].
  </system_context>
  <domain_context>
    ProofChecker task planning with support for research integration, phase breakdown,
    and plan versioning for revisions.
  </domain_context>
  <task_context>
    Parse task number, validate task exists, delegate to planner subagent, validate plan artifact,
    and update status to [PLANNED].
  </task_context>
  <execution_context>
    Routing layer only. Delegates to planner subagent for actual plan creation.
    Planner handles research integration and plan template compliance.
  </execution_context>
</context>

<role>Planning command - Route tasks to planner for implementation plan creation</role>

<task>
  Parse task number, validate task exists and is not completed, delegate to planner subagent
  for plan creation with research integration, validate plan artifact, and relay results to user.
</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse arguments and validate task</action>
    <process>
      1. Parse task number from $ARGUMENTS
      2. Validate task number is integer
      3. Validate task exists in TODO.md
      4. Validate task is not [COMPLETED]
      5. Check if plan already exists:
         - If plan exists: Warn user to use /revise instead
         - If no plan: Proceed
      6. Update status to [PLANNING]
    </process>
    <validation>
      - Task number must be integer
      - Task must exist in TODO.md
      - Task cannot be [COMPLETED]
      - Plan should not already exist (use /revise for updates)
    </validation>
    <checkpoint>Task validated and status updated to [PLANNING]</checkpoint>
  </stage>

  <stage id="2" name="CheckLanguage">
    <action>Extract language for context loading</action>
    <process>
      1. Extract language from task entry:
         ```bash
         grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
         ```
      2. Language used for context loading in planner
      3. If extraction fails: Default to "general"
    </process>
    <checkpoint>Language extracted</checkpoint>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1
      3. Set delegation_path = ["orchestrator", "plan", "planner"]
      4. Set timeout = 1800s (30 minutes)
      5. Prepare task context:
         - task_number
         - language
         - custom_prompt (if provided)
         - research_links (from task entry)
    </process>
    <checkpoint>Delegation context prepared</checkpoint>
  </stage>

  <stage id="4" name="Delegate">
    <action>Delegate to planner subagent</action>
    <process>
      1. Invoke planner with task context
      2. Pass delegation context
      3. Wait for return
    </process>
    <checkpoint>Planner invoked</checkpoint>
  </stage>

  <stage id="5" name="ValidateReturn">
    <action>Validate planner return</action>
    <process>
      1. Validate against subagent-return-format.md
      2. Check required fields present:
         - status (completed|partial|failed|blocked)
         - summary (&lt;100 tokens)
         - artifacts (array with plan artifact)
         - metadata (object with phase_count, estimated_hours)
         - session_id (matches expected)
      3. Verify plan artifact exists on disk
      4. Check token limits (summary &lt;100 tokens)
    </process>
    <checkpoint>Return validated</checkpoint>
  </stage>

  <stage id="6" name="ReturnSuccess">
    <action>Return result to user</action>
    <return_format>
      <completed>
        Plan created for task {number}.
        {brief_summary}
        {phase_count} phases, {effort} hours estimated.
        Plan: {plan_path}
      </completed>
      
      <partial>
        Plan partially created for task {number}.
        {brief_reason}
        Resume with: /plan {number}
        Plan: {plan_path}
      </partial>
    </return_format>
    <checkpoint>Result returned to user</checkpoint>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered):
    - Load command frontmatter
    - Load required context (return format, status markers, routing guide)
    - Load optional context (planning workflow, plan template) if needed
    - Planner loads additional context per its context_loading frontmatter
  </context_allocation>
</routing_intelligence>

<delegation>
  Detailed planning workflow in `.opencode/agent/subagents/planner.md`
  
  Planner handles:
  - Research integration (automatic harvesting from TODO.md)
  - Phase breakdown (1-2 hours per phase target)
  - Effort estimation
  - Plan template compliance (follows plan.md standard)
  - Status updates (via status-sync-manager)
  - Git commits (via git-workflow-manager)
  
  See also: `.opencode/context/project/processes/planning-workflow.md`
</delegation>

<quality_standards>
  <plan_template_compliance>
    All plans must follow `.opencode/context/common/standards/plan.md` template:
    - Metadata section with all required fields
    - Phase breakdown with [NOT STARTED] markers
    - Acceptance criteria per phase
    - Effort estimates (1-2 hours per phase)
    - Success metrics
  </plan_template_compliance>
  
  <atomic_updates>
    Status updates delegated to status-sync-manager for atomic synchronization:
    - TODO.md (status, timestamps, plan link)
    - state.json (status, timestamps, plan_path, plan_metadata)
    - Project state.json (lazy created if needed)
  </atomic_updates>
  
  <lazy_directory_creation>
    Directories created only when writing artifacts:
    - .opencode/specs/{number}_{slug}/ created when writing plan
    - plans/ subdirectory created when writing implementation-001.md
  </lazy_directory_creation>
  
  <research_integration>
    Planner automatically harvests research findings from TODO.md:
    - Scans task entry for research artifact links
    - Loads research reports if present
    - Extracts key findings and recommendations
    - Incorporates into plan context and phases
    - Notes research inputs in plan metadata
  </research_integration>
</quality_standards>

<usage_examples>
  - `/plan 196` - Create plan for task 196 using task description
  - `/plan 196 "Focus on phase breakdown"` - Create plan with custom focus
</usage_examples>

<validation>
  <pre_flight>
    - Task number is valid integer
    - Task exists in TODO.md
    - Task is not [COMPLETED]
    - Plan does not already exist (or warn to use /revise)
  </pre_flight>
  <mid_flight>
    - Language extracted (or defaulted)
    - Delegation context prepared
    - Return validated against schema
  </mid_flight>
  <post_flight>
    - Plan artifact created
    - Status updated to [PLANNED]
    - Git commit created
    - Return relayed to user
  </post_flight>
</validation>

<error_handling>
  <task_not_found>
    Error: Task {task_number} not found in .opencode/specs/TODO.md
    
    Recommendation: Verify task number exists in TODO.md
  </task_not_found>
  
  <invalid_task_number>
    Error: Task number must be an integer. Got: {input}
    
    Usage: /plan TASK_NUMBER [PROMPT]
  </invalid_task_number>
  
  <task_already_completed>
    Error: Task {task_number} is already [COMPLETED]
    
    Recommendation: Cannot plan completed tasks
  </task_already_completed>
  
  <plan_already_exists>
    Warning: Plan already exists for task {task_number}
    
    Existing plan: {plan_path}
    
    Recommendation: Use /revise {task_number} to update existing plan
  </plan_already_exists>
  
  <planning_timeout>
    Error: Planning timed out after 1800s
    
    Status: Partial plan may exist
    Task status: [PLANNING]
    
    Recommendation: Resume with /plan {task_number}
  </planning_timeout>
  
  <validation_failure>
    Error: Plan validation failed
    
    Details: {validation_error}
    
    Recommendation: Fix planner subagent implementation
  </validation_failure>
  
  <git_commit_failure>
    Warning: Git commit failed
    
    Plan created successfully: {plan_path}
    Task status updated to [PLANNED]
    
    Manual commit required:
      git add {files}
      git commit -m "task {number}: plan created"
    
    Error: {git_error}
  </git_commit_failure>
</error_handling>

<notes>
  - **Research Harvesting**: Planner automatically loads research artifacts from TODO.md links
  - **Phase Sizing**: Phases kept small (1-2 hours each) for manageable execution
  - **Template Compliance**: All plans follow plan.md standard exactly
  - **Context Window Protection**: Summary in return metadata, not separate artifact
  - **Atomic Updates**: status-sync-manager ensures consistency across files
  - **Git Workflow**: Delegated to git-workflow-manager for standardized commits
  
  For detailed workflow documentation, see:
  - `.opencode/context/project/processes/planning-workflow.md`
  - `.opencode/agent/subagents/planner.md`
</notes>
