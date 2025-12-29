---
name: revise
agent: orchestrator
description: "Create new plan versions with [REVISED] status"
context_level: 2
language: markdown
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return-format.md"
    - "core/system/status-markers.md"
    - "system/routing-guide.md"
  optional:
    - "project/processes/planning-workflow.md"
    - "core/standards/plan.md"
  max_context_size: 50000
---

**Task Input (required):** $ARGUMENTS (task number and optional prompt; e.g., `/revise 196`, `/revise 196 "Adjust approach"`)

<context>
  <system_context>
    Plan revision command that creates new plan versions for tasks with existing plans.
    Increments plan version number and updates task status to [REVISED].
  </system_context>
  <domain_context>
    ProofChecker plan revision with version management, preserving all previous plan versions
    while creating updated plans based on new information or changing requirements.
  </domain_context>
  <task_context>
    Parse task number, validate task has existing plan, calculate next version number,
    delegate to planner for revision, and update status to [REVISED].
  </task_context>
  <execution_context>
    Routing layer only. Delegates to planner subagent for actual plan revision.
    Planner handles version management and plan preservation.
  </execution_context>
</context>

<role>Plan revision command - Route tasks to planner for plan version updates</role>

<task>
  Parse task number, validate task exists with existing plan, calculate next plan version,
  delegate to planner subagent for plan revision, validate new plan artifact, and relay results to user.
</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse arguments and validate task</action>
    <process>
      1. Parse task number from $ARGUMENTS
      2. Parse optional revision reason from $ARGUMENTS
      3. Validate task number is integer
      4. Validate task exists in TODO.md
      5. Validate task has existing plan:
         - Check for **Plan**: link in task entry
         - If no plan: Error (use /plan instead)
      6. Update status to [REVISING]
    </process>
    <validation>
      - Task number must be integer
      - Task must exist in TODO.md
      - Task must have existing plan (cannot revise non-existent plan)
    </validation>
    <checkpoint>Task validated and status updated to [REVISING]</checkpoint>
  </stage>

  <stage id="2" name="CalculateVersion">
    <action>Calculate next plan version number</action>
    <process>
      1. Extract current plan path from TODO.md task entry
      2. Parse version number from filename:
         - implementation-001.md → version 1
         - implementation-002.md → version 2
         - etc.
      3. Increment version: next_version = current + 1
      4. Format new plan path: implementation-{next_version:03d}.md
      5. Verify new plan path doesn't already exist
    </process>
    <version_numbering>
      - First plan: implementation-001.md
      - First revision: implementation-002.md
      - Second revision: implementation-003.md
      - etc.
    </version_numbering>
    <checkpoint>Next version calculated</checkpoint>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1
      3. Set delegation_path = ["orchestrator", "revise", "planner"]
      4. Set timeout = 1800s (30 minutes)
      5. Prepare task context:
         - task_number
         - current_plan_path
         - next_version
         - revision_reason (if provided)
    </process>
    <checkpoint>Delegation context prepared</checkpoint>
  </stage>

  <stage id="4" name="Delegate">
    <action>Delegate to planner subagent</action>
    <process>
      1. Invoke planner with task context
      2. Pass delegation context
      3. Pass revision context (current plan, next version, reason)
      4. Wait for return
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
         - artifacts (array with new plan artifact)
         - metadata (object with version, phase_count, estimated_hours)
         - session_id (matches expected)
      3. Verify new plan artifact exists on disk
      4. Verify old plan still exists (preserved)
      5. Check token limits (summary &lt;100 tokens)
    </process>
    <checkpoint>Return validated</checkpoint>
  </stage>

  <stage id="6" name="ReturnSuccess">
    <action>Return result to user</action>
    <return_format>
      <completed>
        Plan revised for task {number}.
        {brief_summary}
        Version {version}, {phase_count} phases, {effort} hours estimated.
        Plan: {new_plan_path}
        Previous: {old_plan_path}
      </completed>
      
      <partial>
        Plan partially revised for task {number}.
        {brief_reason}
        Resume with: /revise {number}
        Plan: {new_plan_path}
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
  - Plan revision (creates new version, preserves old)
  - Version management (increments version number)
  - Research integration (if new research available)
  - Phase breakdown updates
  - Status updates (via status-sync-manager)
  - Git commits (via git-workflow-manager)
  
  See also: `.opencode/context/project/processes/planning-workflow.md`
</delegation>

<quality_standards>
  <plan_preservation>
    Original plan files are never modified:
    - New plan version created as separate file
    - All plan versions preserved in plans/ directory
    - TODO.md plan link updated to point to latest version
  </plan_preservation>
  
  <version_management>
    Plans are versioned sequentially:
    - implementation-001.md (first plan)
    - implementation-002.md (first revision)
    - implementation-003.md (second revision)
    - etc.
  </version_management>
  
  <atomic_updates>
    Status updates delegated to status-sync-manager for atomic synchronization:
    - TODO.md (status, timestamps, plan link to new version)
    - state.json (status, timestamps, plan_path, plan_metadata)
  </atomic_updates>
  
  <lazy_directory_creation>
    Directories already exist from original plan creation.
    New plan file written to existing plans/ subdirectory.
  </lazy_directory_creation>
</quality_standards>

<usage_examples>
  - `/revise 196` - Create new plan version for task 196
  - `/revise 196 "Adjust phase breakdown based on new findings"` - Revise with specific reason
</usage_examples>

<validation>
  <pre_flight>
    - Task number is valid integer
    - Task exists in TODO.md
    - Task has existing plan (cannot revise non-existent plan)
    - Next version number calculated correctly
  </pre_flight>
  <mid_flight>
    - Delegation context prepared
    - Return validated against schema
    - New plan artifact exists
    - Old plan still exists (preserved)
  </mid_flight>
  <post_flight>
    - New plan artifact created
    - Old plan preserved
    - Status updated to [REVISED]
    - TODO.md plan link updated to new version
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
    
    Usage: /revise TASK_NUMBER [PROMPT]
  </invalid_task_number>
  
  <no_existing_plan>
    Error: Task {task_number} has no existing plan
    
    Recommendation: Use /plan {task_number} to create initial plan
  </no_existing_plan>
  
  <version_already_exists>
    Error: Plan version {version} already exists for task {task_number}
    
    Existing plan: {plan_path}
    
    Recommendation: Check plan directory for existing versions
  </version_already_exists>
  
  <revision_timeout>
    Error: Plan revision timed out after 1800s
    
    Status: Partial revision may exist
    Task status: [REVISING]
    
    Recommendation: Resume with /revise {task_number}
  </revision_timeout>
  
  <validation_failure>
    Error: Plan revision validation failed
    
    Details: {validation_error}
    
    Recommendation: Fix planner subagent implementation
  </validation_failure>
  
  <git_commit_failure>
    Warning: Git commit failed
    
    Plan revised successfully: {new_plan_path}
    Task status updated to [REVISED]
    
    Manual commit required:
      git add {files}
      git commit -m "task {number}: plan revised (version {version})"
    
    Error: {git_error}
  </git_commit_failure>
</error_handling>

<notes>
  - **Version Management**: Plans versioned sequentially (001, 002, 003, etc.)
  - **Plan Preservation**: Original plans never modified, all versions preserved
  - **Research Integration**: Planner can incorporate new research if available
  - **Context Window Protection**: Summary in return metadata, not separate artifact
  - **Atomic Updates**: status-sync-manager ensures consistency across files
  - **Git Workflow**: Delegated to git-workflow-manager for standardized commits
  
  For detailed workflow documentation, see:
  - `.opencode/context/project/processes/planning-workflow.md`
  - `.opencode/agent/subagents/planner.md`
</notes>
