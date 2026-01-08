---
name: review
agent: orchestrator
description: "Analyze codebase, update registries, create maintenance tasks"
context_level: 2
language: varies
routing:
  language_based: false
  target_agent: reviewer
timeout: 3600
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/formats/subagent-return.md"
  max_context_size: 50000
---

**Usage:** `/review [SCOPE]`

## Description

Analyzes codebase, updates registries (IMPLEMENTATION_STATUS, SORRY_REGISTRY, TACTIC_REGISTRY, FEATURE_REGISTRY), creates maintenance tasks, commits updates.

## Workflow

**Command (4-stage):** ParseAndValidate → Delegate → ValidateReturn → CreateTasksAndRelay  
**Subagent (8-stage):** Analysis → Registry updates → Task identification → Summary creation → Git commit

## Arguments

- `SCOPE` (optional): lean, docs, all (default: all)

## Examples

```bash
/review                  # Full codebase review
/review lean             # Lean code only
/review docs             # Documentation only
```

<context>
  <system_context>Review command with 4-stage pattern</system_context>
  <task_context>Parse scope, delegate to reviewer, create tasks from findings</task_context>
</context>

<role>Review command - Parse arguments and delegate to reviewer</role>

<task>Parse scope, load registries, delegate to reviewer, validate return, create tasks, relay results</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse scope and load registries</action>
    <process>
      1. Parse scope from $ARGUMENTS (default: "all")
         - Valid: lean, docs, all
         - If invalid: Error "Invalid scope: ${scope}. Valid: lean, docs, all"
      
      2. Load registries from Documentation/ProjectInfo/
         - IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md, FEATURE_REGISTRY.md
         - If none found: Error "Registry files not found"
      
      3. Read next_project_number from state.json
         - next_num=$(jq -r '.next_project_number' .opencode/specs/state.json)
         - If fails: Error "Run /meta to regenerate state.json"
      
      4. Generate project_path: .opencode/specs/${next_num}_codebase_review
    </process>
    <checkpoint>Scope validated, registries loaded, project path generated</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to reviewer subagent</action>
    <process>
      1. Generate session_id: sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')
      
      2. Invoke reviewer via task tool:
         {
           "review_scope": "${scope}",
           "project_path": "${project_path}",
           "current_registries": {
             "implementation_status": "Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md",
             "sorry_registry": "Documentation/ProjectInfo/SORRY_REGISTRY.md",
             "tactic_registry": "Documentation/ProjectInfo/TACTIC_REGISTRY.md",
             "feature_registry": "Documentation/ProjectInfo/FEATURE_REGISTRY.md"
           },
           "session_id": "${session_id}",
           "delegation_depth": 1,
           "delegation_path": ["orchestrator", "review", "reviewer"]
         }
      
      3. Wait for return (timeout: 3600s)
    </process>
    <checkpoint>Reviewer invoked, return captured</checkpoint>
  </stage>
  
  <stage id="3" name="ValidateReturn">
    <action>Validate reviewer return</action>
    <process>
      1. Parse as JSON (jq validation)
         - If fails: Error "Return is not valid JSON"
      
      2. Validate required fields:
         - status (completed|partial), summary, artifacts, metadata, identified_tasks, metrics
         - If missing: Error "Missing required field: ${field}"
      
      3. Validate status is "completed" or "partial"
         - If failed: Error "Reviewer failed: ${error_msg}"
      
      4. Validate session_id matches
         - If mismatch: Warning (non-critical)
      
      5. Validate review summary artifact exists on disk
         - summary_artifact=$(jq -r '.artifacts[] | select(.type == "summary") | .path')
         - If not found: Error "Review summary artifact missing"
      
      6. Validate metrics: sorry_count, axiom_count, build_errors
         - If missing: Warning, default to 0
      
      7. Extract identified_tasks count
         - task_count=$(jq -r '.identified_tasks | length')
    </process>
    <checkpoint>Return validated, artifacts verified</checkpoint>
  </stage>
  
  <stage id="3.5" name="CreateTasks">
    <action>Create tasks from identified_tasks</action>
    <process>
      1. Extract identified_tasks array
         - If empty: Skip to Stage 4
      
      2. For each task:
         a. Extract: description, priority, language, estimated_hours
         b. Validate fields (defaults: priority=medium, language=general, hours=2)
         c. Create TODO.md entry:
            ### {next_num}. {description}
            - **Effort**: {hours} hours
            - **Status**: [NOT STARTED]
            - **Priority**: {priority}
            - **Language**: {language}
            - **Created By**: Review task 336
            - **Review Artifact**: [{summary_artifact}]
         
         d. Update state.json:
            - Add to active_projects
            - Increment next_project_number
            - Update task_counts
         
         e. Store created task number
         f. If fails: Log warning, continue (non-critical)
      
      3. Log: "Created ${count} tasks: ${task_numbers}"
    </process>
    <checkpoint>Tasks created, state updated</checkpoint>
  </stage>
  
  <stage id="4" name="RelayResult">
    <action>Format and relay results</action>
    <process>
      1. Extract: status, summary, metrics, next_steps
      
      2. Display summary:
         ═══════════════════════════════════════
         Review Completed
         ═══════════════════════════════════════
         
         Summary: ${summary}
         
         Key Findings:
           • Sorry statements: ${sorry_count}
           • Axiom placeholders: ${axiom_count}
           • Build errors: ${build_errors}
         
         Registry Updates:
           • [List updated registries]
         
         Tasks Created:
           • Task ${num}: ${description}
           • [...]
         
         Review Summary: ${summary_artifact}
         
         Next Steps: ${next_steps}
         ═══════════════════════════════════════
    </process>
    <checkpoint>Results relayed to user</checkpoint>
  </stage>
</workflow_execution>

## Error Handling

| Error | Message | Recommendation |
|-------|---------|----------------|
| Invalid scope | Invalid scope: {scope}. Valid: lean, docs, all | Use valid scope |
| Registry not found | Registry files not found | Check Documentation/ProjectInfo/ |
| state.json error | Failed to read next_project_number | Run /meta |
| Validation failure | Return validation failed: {details} | Fix reviewer return format |
| Task creation failure | Failed to create task: {description} | Manually create in TODO.md |

## Notes

- **4-Stage Pattern**: Simplified command logic, all workflow in subagent
- **Context Level 2**: Reduced from Level 3 (50KB budget)
- **Task Creation**: Moved from subagent to command (proper separation)
- **Atomic Updates**: Registry updates by subagent, task creation by command
- **Graceful Degradation**: Non-critical failures logged but don't abort

See: `.opencode/agent/subagents/reviewer.md`, `Documentation/ProjectInfo/*_REGISTRY.md`
