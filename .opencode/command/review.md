---
name: review
agent: orchestrator
description: "Analyze codebase, update registries, create maintenance tasks"
context_level: 3
language: varies
---

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md
@.opencode/context/common/system/git-commits.md
@Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
@Documentation/ProjectInfo/SORRY_REGISTRY.md
@Documentation/ProjectInfo/TACTIC_REGISTRY.md
@Documentation/ProjectInfo/FEATURE_REGISTRY.md

<context>
  <system_context>
    Codebase review workflow that analyzes code, updates registries, and creates
    maintenance tasks. Comprehensive analysis of implementation status, sorry counts,
    tactic usage, and feature completeness.
  </system_context>
  <domain_context>
    Repository-wide analysis for both Lean and general code. Updates project registries
    and creates tasks for identified work.
  </domain_context>
  <task_context>
    Analyze codebase, update IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md,
    TACTIC_REGISTRY.md, FEATURE_REGISTRY.md, create tasks for identified work,
    and commit registry updates.
  </task_context>
  <execution_context>
    Full context loading (Level 3). Atomic registry updates. Git commit after review.
    Task creation for identified maintenance work.
  </execution_context>
</context>

<role>Review Command - Analyze codebase and update project registries</role>

<task>
  Analyze codebase comprehensively, update all project registries, create tasks
  for identified work, and commit registry updates.
</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Prepare for codebase review</action>
    <process>
      1. Parse review scope from input (default: full codebase)
      2. Load current registries:
         - IMPLEMENTATION_STATUS.md
         - SORRY_REGISTRY.md
         - TACTIC_REGISTRY.md
         - FEATURE_REGISTRY.md
      3. Determine review focus (Lean, docs, all)
      4. Prepare review context
    </process>
    <validation>
      - Registries exist (create if missing)
      - Review scope is valid
    </validation>
  </stage>

  <stage id="2" name="PrepareDelegation">
    <action>Prepare delegation context for reviewer</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1 (orchestrator → review → reviewer)
      3. Set delegation_path = ["orchestrator", "review", "reviewer"]
      4. Set timeout = 3600s (1 hour for comprehensive review)
      5. Store session_id for validation
      6. Prepare review context (scope, current registries)
    </process>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "review", "reviewer"],
        "timeout": 3600,
        "review_context": {
          "scope": "{full|lean|docs}",
          "current_registries": {
            "implementation_status": "{path}",
            "sorry_registry": "{path}",
            "tactic_registry": "{path}",
            "feature_registry": "{path}"
          }
        }
      }
    </delegation_context>
  </stage>

  <stage id="3" name="InvokeReviewer">
    <action>Invoke reviewer subagent</action>
    <process>
      1. Route to reviewer subagent
      2. Pass delegation context
      3. Pass review scope
      4. Pass current registry contents
      5. Set timeout to 3600s
    </process>
    <invocation>
      task_tool(
        subagent_type="reviewer",
        prompt="Review codebase and update registries",
        session_id=delegation_context["session_id"],
        delegation_depth=1,
        delegation_path=delegation_context["delegation_path"],
        timeout=3600,
        scope=review_scope,
        current_registries=registry_contents
      )
    </invocation>
  </stage>

  <stage id="4" name="ReceiveResults">
    <action>Wait for and receive review results</action>
    <process>
      1. Poll for completion (max 3600s)
      2. Receive return object from reviewer
      3. Validate against subagent-return-format.md
      4. Check session_id matches expected
      5. Handle timeout gracefully
    </process>
    <timeout_handling>
      If timeout (no response after 3600s):
        1. Log timeout error with session_id
        2. Check for partial registry updates
        3. Return partial status
        4. Provide retry instructions
    </timeout_handling>
    <validation>
      1. Validate return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches
      4. Validate status is valid enum
      5. Validate registry update artifacts exist
    </validation>
  </stage>

  <stage id="5" name="ProcessResults">
    <action>Extract registry updates and identified tasks</action>
    <process>
      1. Extract status from return (completed|partial|failed|blocked)
      2. Extract updated registry paths from artifacts
      3. Extract list of identified tasks
      4. Extract summary of findings
      5. Extract errors if status != completed
      6. Determine next action based on status
    </process>
    <status_handling>
      If status == "completed":
        - All registries updated
        - Tasks identified
        - Proceed to postflight
      If status == "partial":
        - Some registries updated
        - Save partial results
        - Provide retry instructions
      If status == "failed" or "blocked":
        - No usable results
        - Handle errors
        - Provide recovery steps
    </status_handling>
  </stage>

  <stage id="6" name="CreateTasks">
    <action>Create TODO.md tasks for identified work</action>
    <process>
      1. For each identified task from review:
         a. Invoke /task command to create task
         b. Set appropriate priority based on severity
         c. Set language based on task type
         d. Link to review findings
      2. Collect created task numbers
      3. Prepare task summary
    </process>
    <task_creation>
      Example identified tasks:
        - "Fix 12 sorry statements in Logos/Core/Theorems/"
        - "Document 8 undocumented tactics in ProofSearch.lean"
        - "Implement 3 missing features from FEATURE_REGISTRY"
    </task_creation>
  </stage>

  <stage id="7" name="Postflight">
    <action>Update registries and commit</action>
    <process>
      1. If status == "completed":
         a. Write updated registries:
            - IMPLEMENTATION_STATUS.md
            - SORRY_REGISTRY.md
            - TACTIC_REGISTRY.md
            - FEATURE_REGISTRY.md
         b. Update TODO.md with created tasks
         c. Update state.json with new tasks
         d. Git commit:
            - Scope: Updated registries + TODO.md + state.json
            - Message: "review: update registries and create {N} tasks"
      2. If status == "partial":
         a. Write partial registry updates
         b. Git commit partial updates
         c. Provide retry instructions
      3. If status == "failed" or "blocked":
         a. No registry updates
         b. No git commit
    </process>
    <git_commit>
      Scope: Updated registries + TODO.md + state.json
      Message: "review: update registries and create {N} tasks"
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <action>Return summary to user</action>
    <return_format>
      Review completed
      - Registries updated: {list}
      - Tasks created: {count}
      - Summary: {brief summary of findings}
      - Key findings:
        - Sorry count: {count}
        - Undocumented tactics: {count}
        - Missing features: {count}
        - Implementation gaps: {count}
    </return_format>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 3 (Full) - Review requires comprehensive codebase context
  </context_allocation>
  <review_scope>
    Full: Analyze entire codebase (Lean + docs + tests)
    Lean: Focus on Lean code only
    Docs: Focus on documentation only
  </review_scope>
</routing_intelligence>

<artifact_management>
  <registry_updates>
    Update all project registries:
      - IMPLEMENTATION_STATUS.md (module completion status)
      - SORRY_REGISTRY.md (sorry statement tracking)
      - TACTIC_REGISTRY.md (tactic documentation)
      - FEATURE_REGISTRY.md (feature completeness)
  </registry_updates>
  <state_sync>
    Update TODO.md with created tasks
    Update state.json with new task entries
  </state_sync>
</artifact_management>

<quality_standards>
  <registry_accuracy>
    Ensure registry updates are accurate and complete
    Cross-reference with actual codebase state
  </registry_accuracy>
  <task_creation>
    Create specific, actionable tasks
    Set appropriate priorities
    Link to review findings
  </task_creation>
  <no_emojis>
    No emojis in registries or task descriptions
  </no_emojis>
</quality_standards>

<usage_examples>
  - `/review` (full codebase review)
  - `/review --scope lean` (Lean code only)
  - `/review --scope docs` (documentation only)
</usage_examples>

<validation>
  <pre_flight>
    - Review scope validated
    - Current registries loaded
    - Reviewer invoked successfully
  </pre_flight>
  <mid_flight>
    - Return validated against subagent-return-format.md
    - Session ID matches expected
    - Registry updates exist
  </mid_flight>
  <post_flight>
    - Registries updated
    - Tasks created in TODO.md
    - state.json synchronized
    - Git commit created
  </post_flight>
</validation>

<error_handling>
  <timeout>
    If review times out after 3600s:
      - Check for partial registry updates
      - Return partial status
      - Provide retry instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error
      - Return failed status
      - Recommend subagent fix
  </validation_failure>
  <task_creation_failure>
    If task creation fails:
      - Log error
      - Continue with registry updates
      - Note failed task creation in summary
  </task_creation_failure>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
