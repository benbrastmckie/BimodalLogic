---
name: review
agent: orchestrator
description: "Analyze codebase, update registries, create maintenance tasks"
context_level: 3
language: varies
---

Context Loaded:
@.opencode/specs/.opencode/specs/TODO.md
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
      4. Read next_project_number from state.json
      5. Validate next_project_number is positive integer
      6. Check for existing project directory collision
      7. Generate project path: .opencode/specs/{next_project_number}_codebase_review
      8. Prepare review context
    </process>
    <project_directory>
      Format: {next_project_number}_codebase_review
      Example: 207_codebase_review
      Created: Lazily by reviewer subagent when writing first artifact
      Note: Do NOT create directory here, let reviewer create it
    </project_directory>
    <validation>
      - Registries exist (create if missing)
      - Review scope is valid
      - next_project_number is valid positive integer
      - No existing project directory with same number
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
      6. Prepare review context (scope, current registries, project_path)
    </process>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "review", "reviewer"],
        "timeout": 3600,
        "review_context": {
          "scope": "{full|lean|docs}",
          "project_path": ".opencode/specs/{number}_codebase_review",
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
      3. Pass review scope and project_path
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
        project_path=project_path,
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
      5. Extract review summary artifact path
      6. Handle timeout gracefully
    </process>
    <timeout_handling>
      If timeout (no response after 3600s):
        1. Log timeout error with session_id
        2. Check for partial registry updates
        3. Check for partial review summary artifact
        4. Return partial status
        5. Provide retry instructions
    </timeout_handling>
    <validation>
      1. Validate return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches
      4. Validate status is valid enum (completed|partial|failed|blocked)
      5. Validate artifacts array contains review summary
      6. Validate review summary artifact exists on disk
      7. Validate registry update artifacts exist
    </validation>
  </stage>

  <stage id="5" name="ProcessResults">
    <action>Extract registry updates, artifacts, and identified tasks</action>
    <process>
      1. Extract status from return (completed|partial|failed|blocked)
      2. Extract review summary artifact path from artifacts array
      3. Extract updated registry paths from artifacts
      4. Extract list of identified tasks from identified_tasks field
      5. Extract brief summary from summary field (for user return)
      6. Extract metrics from metrics field (for state.json)
      7. Extract errors if status != completed
      8. Determine next action based on status
    </process>
    <artifact_extraction>
      - Review summary artifact: artifacts[0] (type: "summary")
      - Registry artifacts: artifacts[1-4] (type: "documentation")
      - Verify review summary path: {project_path}/summaries/review-summary.md
    </artifact_extraction>
    <status_handling>
      If status == "completed":
        - All registries updated
        - Review summary created
        - Tasks identified
        - Proceed to postflight
      If status == "partial":
        - Some registries updated
        - Partial review summary may exist
        - Save partial results
        - Provide retry instructions
      If status == "failed" or "blocked":
        - No usable results
        - Handle errors
        - Provide recovery steps
    </status_handling>
  </stage>

  <stage id="6" name="CreateTasks">
    <action>Create .opencode/specs/TODO.md tasks for identified work</action>
    <process>
      1. Read review summary artifact to extract identified_tasks
      2. Parse identified_tasks from Follow-ups section (TBD-1, TBD-2, etc.)
      3. For each identified task, invoke /task command:
         a. One /task invocation per identified task (no batching)
         b. Set description from task.description
         c. Set priority from task.priority (high|medium|low)
         d. Set language from task.language (lean|markdown|general)
         e. Link to review findings in description
         f. Set estimated_hours based on task complexity
      3. Error handling:
         a. If /task invocation fails: Log error, continue to next task
         b. Track failed task descriptions for manual creation
         c. Include failed task count in summary
      4. Collect created task numbers (successful creations only)
      5. Map placeholder numbers (TBD-1, TBD-2) to actual task numbers
      6. Prepare task summary (created count, failed count)
      7. POST-FLIGHT VALIDATION: Verify each created task complies with standards
         a. Read created task entry from TODO.md
         b. Validate Language field is present
         c. Validate metadata uses `- **Field**:` format (not `*Field**:`)
         d. Validate all required fields present (Language, Effort, Priority, Status)
         e. If validation fails: Log error with task number and specific violation
         f. Track non-compliant tasks for reporting
    </process>
    <task_creation_loop>
      Example loop:
      
      created_tasks = []
      failed_tasks = []
      
      for task in identified_tasks:
        try:
          task_number = invoke_task_command(
            description=task.description,
            priority=task.priority,
            language=task.language,
            estimated_hours=task.estimated_hours
          )
          created_tasks.append(task_number)
        except TaskCreationError as e:
          log_error(e)
          failed_tasks.append({
            "description": task.description,
            "error": str(e)
          })
          continue  # Don't abort, continue to next task
      
      return {
        "created_tasks": created_tasks,
        "failed_tasks": failed_tasks
      }
    </task_creation_loop>
    <task_numbering>
      Tasks created sequentially using next_task_number from state.json
      No gaps in task numbering (sequential: 201, 202, 203, ...)
      /task command increments next_task_number after each creation
    </task_numbering>
    <task_linking>
      Link tasks to review findings in description:
      - "Fix 12 sorry statements in Logos/Core/Theorems/ (identified in review #207)"
      - "Document 8 undocumented tactics in ProofSearch.lean (see review #207)"
      - "Implement 3 missing features from FEATURE_REGISTRY (review #207 findings)"
      
      Include review project number for traceability
    </task_linking>
    <error_handling>
      If task creation fails:
      1. Log error with task description and reason
      2. Continue to next task (don't abort review)
      3. Track failed tasks in failed_tasks array
      4. Include failed task count in review summary
      5. Provide manual creation instructions in summary
      
      Example error log:
      {
        "type": "task_creation_failed",
        "task_description": "Fix 12 sorry statements in Logos/Core/Theorems/",
        "error": ".opencode/specs/TODO.md write failed: Permission denied",
        "recoverable": true,
        "recommendation": "Manually create task with description above"
      }
    </error_handling>
    <post_flight_validation>
      After creating each task, validate compliance with task standards:
      
      1. Language Field Validation:
         - Read created task entry from TODO.md
         - Verify Language field is present
         - If missing: Log error with task number
         - Error type: "task_standard_violation"
         - Recommendation: "Add Language field to task {number}"
      
      2. Metadata Format Validation:
         - Verify all metadata uses `- **Field**:` pattern
         - Check for incorrect patterns like `*Field**:`
         - If wrong format: Log error with task number and field name
         - Error type: "task_format_violation"
         - Recommendation: "Fix metadata format in task {number}: use `- **Field**:` not `*Field**:`"
      
      3. Required Fields Validation:
         - Verify Language, Effort, Priority, Status fields present
         - If missing: Log error with task number and missing field
         - Error type: "task_missing_field"
         - Recommendation: "Add {field_name} to task {number}"
      
      4. Validation Reporting:
         - Track all non-compliant tasks in validation_errors array
         - Include validation error count in review summary
         - Provide specific violations for each non-compliant task
         - Return validation errors in review return object
      
      Example validation error:
      {
        "type": "task_standard_violation",
        "task_number": 201,
        "violation": "missing_language_field",
        "error": "Task 201 missing required Language field",
        "recoverable": true,
        "recommendation": "Add Language field to task 201 in TODO.md"
      }
    </post_flight_validation>
    <batching_decision>
      Create ALL identified tasks (no batching):
      - Rationale: Review identifies actionable work, all should be tracked
      - Priority filtering: User can filter by priority in .opencode/specs/TODO.md
      - Task count limit: None (create all identified tasks)
      - If too many tasks: Consider breaking into sub-tasks in future reviews
    </batching_decision>
    <task_creation_examples>
      Example identified tasks from reviewer:
      [
        {
          "description": "Fix 12 sorry statements in Logos/Core/Theorems/",
          "priority": "high",
          "language": "lean",
          "estimated_hours": 6
        },
        {
          "description": "Document 8 undocumented tactics in ProofSearch.lean",
          "priority": "medium",
          "language": "lean",
          "estimated_hours": 4
        },
        {
          "description": "Implement 3 missing features from FEATURE_REGISTRY",
          "priority": "medium",
          "language": "lean",
          "estimated_hours": 8
        }
      ]
      
      Created tasks: 201, 202, 203
      Failed tasks: None
    </task_creation_examples>
  </stage>

  <stage id="7" name="Postflight">
    <action>Delegate atomic state updates to status-sync-manager</action>
    <process>
      1. If status == "completed":
         a. Prepare state update payload for status-sync-manager:
            - validated_artifacts: All artifacts from reviewer return (review summary + registries)
            - review_metrics: Metrics from reviewer return (sorry_count, axiom_count, build_errors, etc.)
            - created_tasks: Task numbers from Stage 6 CreateTasks
            - review_task_number: Project number (matches next_project_number used for directory)
            - project_path: Review project directory path
            - review_scope: Scope from input (full|lean|docs)
         b. Delegate to status-sync-manager for atomic update:
            - Create .opencode/specs/TODO.md task entry for review project:
              * Task number: review_task_number (matches project number)
              * Status: [COMPLETED]
              * Title: "Codebase review - {scope}"
              * Completion timestamp
              * Link to review summary artifact
            - Update .opencode/specs/TODO.md with created follow-up tasks
            - Update state.json:
              * Increment next_project_number
              * Add new task entries
              * Update repository_health.technical_debt (sorry_count, axiom_count, build_errors)
              * Update repository_health.last_assessed (review timestamp)
              * Add repository_health.review_artifacts entry
            - Create project state.json:
              * type: "review"
              * status: "completed"
              * scope: review_scope
              * created: timestamp
              * completed: timestamp
              * artifacts: [review summary artifact]
              * metrics: review_metrics from reviewer
              * registries_updated: [IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY, FEATURE_REGISTRY]
         c. Wait for status-sync-manager return (two-phase commit)
          d. Replace placeholder task numbers in review summary:
             - Read review summary artifact
             - Replace TBD-1 with actual task number from Stage 6 mapping
             - Replace TBD-2 with actual task number from Stage 6 mapping
             - Continue for all placeholder numbers
             - Add invocation instructions for each task (e.g., "Run: /implement {task_number}")
             - Write updated review summary back to artifact
          e. If status-sync-manager succeeds:
             - Git commit all changes (registries + .opencode/specs/TODO.md + state.json + project state.json + updated review summary)
             - Message: "review: update registries and create {N} tasks"
          f. If status-sync-manager fails:
            - Rollback any partial updates (status-sync-manager handles this)
            - Log error to errors.json
            - Return failed status with rollback details
      2. If status == "partial":
         a. Prepare partial state update payload:
            - validated_artifacts: Partial artifacts from reviewer return
            - review_metrics: Partial metrics (if available)
            - created_tasks: Task numbers created before partial completion
         b. Delegate to status-sync-manager for partial atomic update:
            - Update .opencode/specs/TODO.md with created tasks (if any)
            - Update state.json:
              * Increment next_project_number if directory created
              * Add new task entries (if any)
              * Add partial repository_health.review_artifacts entry (if summary created)
            - Create project state.json with status: "in_progress"
         c. Git commit partial updates (if any artifacts created)
         d. Provide retry instructions
      3. If status == "failed" or "blocked":
         a. No status-sync-manager delegation
         b. No state.json updates
         c. No registry updates
         d. No git commit
    </process>
    <status_sync_manager_delegation>
      Delegate to status-sync-manager with payload:
      {
        "operation": "review_complete",
        "review_task_number": 207,
        "validated_artifacts": [
          {
            "type": "summary",
            "path": "{review_summary_path}",
            "summary": "Review findings"
          },
          {
            "type": "documentation",
            "path": "Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md",
            "summary": "Updated implementation status"
          },
          {
            "type": "documentation",
            "path": "Documentation/ProjectInfo/SORRY_REGISTRY.md",
            "summary": "Updated sorry registry"
          },
          {
            "type": "documentation",
            "path": "Documentation/ProjectInfo/TACTIC_REGISTRY.md",
            "summary": "Updated tactic registry"
          },
          {
            "type": "documentation",
            "path": "Documentation/ProjectInfo/FEATURE_REGISTRY.md",
            "summary": "Updated feature registry"
          }
        ],
        "review_metrics": {
          "sorry_count": 10,
          "axiom_count": 11,
          "build_errors": 3,
          "undocumented_tactics": 8,
          "missing_features": 3,
          "tasks_created": 5
        },
        "created_tasks": [201, 202, 203, 204, 205],
        "project_path": ".opencode/specs/207_codebase_review",
        "review_scope": "full",
        "timestamp": "2025-12-28T20:00:00Z"
      }
      
      status-sync-manager performs two-phase commit:
      1. Prepare: Validate all updates, create backups
      2. Commit: Write all files atomically or rollback on failure
      
      Atomicity guarantee: .opencode/specs/TODO.md + state.json + project state.json all updated or none
    </status_sync_manager_delegation>
    <repository_health_updates>
      status-sync-manager updates state.json repository_health section:
      
      1. technical_debt (from review_metrics):
         {
           "sorry_count": 10,
           "axiom_count": 11,
           "build_errors": 3
         }
      
      2. last_assessed (from timestamp):
         "last_assessed": "2025-12-28T20:00:00Z"
      
      3. review_artifacts (append new entry):
         "review_artifacts": [
           {
             "timestamp": "2025-12-28T20:00:00Z",
             "path": ".opencode/specs/207_codebase_review/summaries/review-summary.md",
             "scope": "full"
           }
         ]
      
      All updates atomic with .opencode/specs/TODO.md and project state.json
    </repository_health_updates>
    <two_phase_commit>
      Phase 1 (Prepare):
        - Validate all file paths exist
        - Validate JSON schemas
        - Create backups of .opencode/specs/TODO.md, state.json
        - Prepare all updates in memory
        - Verify no conflicts
      
      Phase 2 (Commit or Rollback):
        - If validation passes: Write all files atomically
        - If validation fails: Restore from backups, return error
        - If write fails: Restore from backups, return error
        - Delete backups on success
    </two_phase_commit>
    <error_handling>
      If status-sync-manager fails:
        1. Automatic rollback (status-sync-manager responsibility)
        2. Log error to errors.json with details
        3. Return failed status to user
        4. Recommendation: "Retry /review after resolving state file issues"
        5. Preserve reviewer artifacts (don't delete review summary)
      
      If git commit fails (after successful status-sync-manager):
        1. Log error to errors.json
        2. Continue (git failure non-critical)
        3. Return success with warning: "State updated but git commit failed"
    </error_handling>
    <git_commit>
      Scope: Review summary + updated registries + .opencode/specs/TODO.md + state.json + project state.json
      Message: "review: update registries and create {N} tasks"
      
      Commit only after successful status-sync-manager update
      Use git-workflow-manager for scoped commit
      Git failure is non-critical (state already updated)
    </git_commit>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <action>Return summary and artifact path to user</action>
    <return_format>
      Review completed
      - Status: Completed
      - Review summary: {review_summary_artifact_path}
      - Registries updated: {count}
      - Tasks created: {count}
      - Summary: {brief summary from reviewer (2-5 sentences)}
      
      Or if partial:
      Review partially completed
      - Status: Partial
      - Review summary: {review_summary_artifact_path} (if created)
      - Partial registries updated: {count}
      - Resume with: /review to continue
      
      Or if blocked:
      Review blocked
      - Status: Blocked
      - Blocking reason: {reason}
      - Resolve blocker and retry with: /review
    </return_format>
    <context_protection>
      Return only:
      - Brief summary from reviewer (already <100 tokens)
      - Review summary artifact path
      - Registry and task counts
      
      Do NOT return verbose key findings (they're in review summary artifact)
      This protects orchestrator context window from verbose output
    </context_protection>
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
  <lazy_creation>
    Do not create project directory until reviewer writes first artifact
    Reviewer creates project root ({number}_codebase_review) when writing summary
    Create only summaries/ subdirectory (not reports/ or plans/)
    Project state.json created lazily by status-sync-manager in Stage 7
  </lazy_creation>
  <artifact_naming>
    Project directory: {next_project_number}_codebase_review
    Review summary: summaries/review-summary.md
    Project state: state.json (in project root)
    Follows summary.md standard (3-5 sentences overview, <100 tokens)
  </artifact_naming>
  <registry_updates>
    Update all project registries:
      - IMPLEMENTATION_STATUS.md (module completion status)
      - SORRY_REGISTRY.md (sorry statement tracking)
      - TACTIC_REGISTRY.md (tactic documentation)
      - FEATURE_REGISTRY.md (feature completeness)
  </registry_updates>
  <state_sync>
    Delegated to status-sync-manager for atomic updates:
    - Update .opencode/specs/TODO.md with created tasks
    - Update state.json with new task entries
    - Update state.json repository_health with review_artifacts entry
    - Create project state.json with review metadata
    - Increment next_project_number after project creation
    
    All updates atomic (all succeed or all rollback)
  </state_sync>
  <project_state_json>
    Created lazily by status-sync-manager when review completes
    Location: {project_path}/state.json
    
    Schema:
    {
      "type": "review",
      "status": "completed|in_progress",
      "scope": "full|lean|docs",
      "created": "2025-12-28T20:00:00Z",
      "completed": "2025-12-28T21:30:00Z",
      "artifacts": [
        {
          "type": "summary",
          "path": "summaries/review-summary.md",
          "summary": "Review findings and recommendations"
        }
      ],
      "metrics": {
        "sorry_count": 10,
        "axiom_count": 11,
        "build_errors": 3,
        "undocumented_tactics": 8,
        "missing_features": 3,
        "tasks_created": 5
      },
      "registries_updated": [
        "IMPLEMENTATION_STATUS",
        "SORRY_REGISTRY",
        "TACTIC_REGISTRY",
        "FEATURE_REGISTRY"
      ]
    }
    
    Example: .opencode/specs/207_codebase_review/state.json
  </project_state_json>
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
    Validate created tasks comply with task standards
    Ensure Language field present for all tasks
    Ensure metadata format uses `- **Field**:` pattern
    Report validation errors for non-compliant tasks
  </task_creation>
  <task_validation>
    Post-flight validation ensures created tasks comply with standards:
    
    1. Language Field Check:
       - MANDATORY per tasks.md line 110 quality checklist
       - Must be present for routing to appropriate agents
       - Missing Language field is validation error
    
    2. Metadata Format Check:
       - Must use `- **Field**:` pattern (not `*Field**:`)
       - Ensures consistency with task standards
       - Wrong format is validation error
    
    3. Required Fields Check:
       - Language, Effort, Priority, Status must be present
       - Missing required field is validation error
    
    4. Validation Reporting:
       - All validation errors logged with task number
       - Specific violation type and recommendation provided
       - Validation errors included in review return object
       - User notified of non-compliant tasks for manual fix
  </task_validation>
  <no_emojis>
    No emojis in registries or task descriptions
    
    Validation: Before returning artifacts, verify:
    - grep -E "[\x{1F300}-\x{1F9FF}\x{2600}-\x{26FF}\x{2700}-\x{27BF}]" artifact.md returns no results
    - If emojis found: Replace with text alternatives ([PASS]/[FAIL]/[WARN])
    - Fail command if emojis cannot be removed
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
    - Tasks created in .opencode/specs/TODO.md
    - Created tasks validated for compliance with task standards
    - All created tasks have Language field
    - All created tasks use correct bullet formatting (`- **Field**:`)
    - Validation errors logged for non-compliant tasks
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
