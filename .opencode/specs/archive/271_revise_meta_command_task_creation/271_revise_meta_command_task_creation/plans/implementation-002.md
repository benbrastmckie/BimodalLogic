# Implementation Plan: Revise /meta Command to Create Tasks with Plan Artifacts Only

- **Task**: 271 - Revise /meta command to create tasks with linked artifacts instead of implementing directly
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/271_revise_meta_command_task_creation/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
  - .opencode/context/core/standards/subagent-return-format.md
- **Type**: meta
- **Lean Intent**: false
- **Version**: 2 (Revised)
- **Revision Date**: 2026-01-03

## Overview

This revised plan simplifies the `/meta` command artifact generation to create ONLY plan artifacts for each task, eliminating research and summary artifact generation. Additionally, it migrates the system from using 'Language' field to 'Type' field throughout (context files, commands, subagents, TODO.md, state.json), and updates the `/implement` command routing to properly handle meta tasks by routing them to meta subagents (domain-analyzer, workflow-designer, agent-generator, command-creator, context-organizer).

## Goals & Non-Goals

**Goals:**
- Revise Stage 7 (GenerateSystem → CreateTasksWithArtifacts) to create tasks with plan artifacts only
- Revise Stage 8 (DeliverSystem → DeliverTaskSummary) to present task list with usage instructions
- Generate ONLY plan artifacts (plans/implementation-001.md) for each task following plan.md standard
- Create task entries in TODO.md with proper plan artifact links following tasks.md standard
- Use next_project_number from state.json for task numbering and increment for each task
- Implement task breakdown strategy based on system complexity (simple: 4 tasks, moderate: 7 tasks, complex: 10-15 tasks)
- Migrate 'Language' field to 'Type' field across all system files
- Update /implement command routing to use 'Type' field and route meta tasks to meta subagents
- Update command documentation (meta.md) to reflect new workflow
- Follow lazy directory creation (create directories only when writing files)
- Return standardized format per subagent-return-format.md

**Non-Goals:**
- Changing Stages 0-6 (interview stages remain unchanged)
- Implementing the generated system (that's for `/implement` command)
- Creating research artifacts (eliminated - plan is self-documenting)
- Creating summary artifacts (eliminated - plan metadata provides summary)
- Creating placeholder files or pre-created empty directories
- Modifying meta subagents (domain-analyzer, workflow-designer, agent-generator, command-creator, context-organizer) - these will be invoked by /implement for meta tasks

## Risks & Mitigations

**Risk 1: Task Breakdown Complexity**
- Risk: Determining optimal task breakdown for different system sizes may be complex
- Mitigation: Use clear heuristics based on agent count and use case count from interview; follow task-breakdown.md workflow; start with simple strategy (planning task + N implementation tasks)

**Risk 2: Plan Artifact Quality**
- Risk: Generated plan artifacts may not meet quality standards
- Mitigation: Use templates from plan.md standard; validate against standards before returning; include validation checks for non-empty files, required sections

**Risk 3: Context Window Protection**
- Risk: Plan artifacts may be verbose
- Mitigation: Plan metadata provides summary information; return artifact paths not content in return object; follow subagent-return-format.md; keep summary field in return object brief (3-5 sentences)

**Risk 4: Language→Type Migration Scope**
- Risk: Migration may miss files or break existing functionality
- Mitigation: Comprehensive grep search for 'Language' field; systematic replacement; test all commands after migration; validate state.json schema

**Risk 5: Meta Task Routing**
- Risk: /implement may not properly route meta tasks to meta subagents
- Mitigation: Update routing logic to check Type field; add explicit meta type handling; test with meta task examples

## Implementation Phases

### Phase 1: Language→Type Field Migration [NOT STARTED]
- **Goal:** Migrate all system files from 'Language' field to 'Type' field
- **Tasks:**
  - [ ] Search for all occurrences of 'Language' field in context files:
    - [ ] .opencode/context/core/standards/tasks.md
    - [ ] .opencode/context/core/standards/plan.md
    - [ ] .opencode/context/core/standards/report.md
    - [ ] .opencode/context/core/system/state-management.md
    - [ ] Any other context files referencing 'Language'
  - [ ] Replace 'Language' with 'Type' in all context files
  - [ ] Update field descriptions to clarify Type values: lean, markdown, python, meta, etc.
  - [ ] Update TODO.md task entries to use 'Type' field instead of 'Language'
  - [ ] Update state.json schema to use 'type' field (already exists, verify consistency)
  - [ ] Update all command files to reference 'Type' field:
    - [ ] .opencode/command/research.md
    - [ ] .opencode/command/plan.md
    - [ ] .opencode/command/implement.md
    - [ ] .opencode/command/revise.md
    - [ ] .opencode/command/task.md
    - [ ] .opencode/command/meta.md
  - [ ] Update all subagent files to reference 'Type' field:
    - [ ] .opencode/agent/subagents/researcher.md
    - [ ] .opencode/agent/subagents/planner.md
    - [ ] .opencode/agent/subagents/implementer.md
    - [ ] .opencode/agent/subagents/task-executor.md
    - [ ] .opencode/agent/subagents/status-sync-manager.md
  - [ ] Validate migration: grep for remaining 'Language' references
- **Timing:** 2 hours

### Phase 2: Update /implement Command Routing for Meta Tasks [NOT STARTED]
- **Goal:** Update /implement command to route meta tasks to meta subagents
- **Tasks:**
  - [ ] Read .opencode/command/implement.md
  - [ ] Locate routing logic (Stage 2: DetermineRouting or equivalent)
  - [ ] Add Type field extraction from TODO.md task entry
  - [ ] Add meta type check: if Type == 'meta', route to meta subagents
  - [ ] Define meta subagent routing strategy:
    - [ ] For meta tasks, delegate to appropriate meta subagent based on task description
    - [ ] Meta subagents: domain-analyzer, workflow-designer, agent-generator, command-creator, context-organizer
    - [ ] Use task description keywords to determine which meta subagent to invoke
  - [ ] Update routing documentation in implement.md
  - [ ] Add validation: ensure Type field is read correctly
  - [ ] Test routing with example meta task
- **Timing:** 1.5 hours

### Phase 3: Revise Stage 7 - Task Breakdown Logic [NOT STARTED]
- **Goal:** Implement task breakdown strategy based on system complexity
- **Tasks:**
  - [ ] Read interview results from Stage 6 (agent count, use case count, complexity assessment)
  - [ ] Implement task breakdown heuristics:
    - [ ] Simple system (1-2 agents, 3-4 use cases): 4 tasks (planning, 3 implementation)
    - [ ] Moderate system (3-5 agents, 4-6 use cases): 7 tasks (planning, 6 implementation)
    - [ ] Complex system (6-8 agents, 7+ use cases): 10-15 tasks (planning, 9-14 implementation)
  - [ ] Generate task titles and slugs from interview results
  - [ ] Read next_project_number from .opencode/specs/state.json
  - [ ] Create task number sequence (next_project_number, next_project_number+1, ...)
  - [ ] Set Type field to 'meta' for all meta-related tasks
- **Timing:** 1.5 hours

### Phase 4: Revise Stage 7 - Plan Artifact Generation [NOT STARTED]
- **Goal:** Generate plan artifacts for each task following plan.md standard (ONLY artifact type)
- **Tasks:**
  - [ ] Generate plan metadata block (Task, Status, Effort, Priority, Dependencies, Artifacts, Standards, Type, Lean Intent)
  - [ ] Generate Overview (2-4 sentences)
  - [ ] Generate Goals & Non-Goals
  - [ ] Generate Risks & Mitigations
  - [ ] Generate Implementation Phases (1-2 hours each, status markers [NOT STARTED])
  - [ ] Generate Testing & Validation
  - [ ] Generate Artifacts & Outputs
  - [ ] Generate Rollback/Contingency
  - [ ] Create project directory: .opencode/specs/{number}_{slug}/ (lazy creation)
  - [ ] Write plan artifact: plans/implementation-001.md
  - [ ] Validate artifact exists and is non-empty
  - [ ] Extract plan metadata (phase_count, estimated_hours, complexity)
- **Timing:** 2 hours

### Phase 5: Revise Stage 7 - Task Entry Creation and State Updates [NOT STARTED]
- **Goal:** Create task entries in TODO.md and update state.json
- **Tasks:**
  - [ ] For each task, create task entry in TODO.md following tasks.md standard:
    - [ ] Include task number and title (### {number}. {title})
    - [ ] Include all required fields: Effort, Status, Priority, Type (NOT Language), Plan, Blocking, Dependencies
    - [ ] Link to plan artifact: `- **Plan**: [Implementation Plan]({path}/plans/implementation-001.md)`
    - [ ] Set Status: [NOT STARTED]
    - [ ] Set Type: meta (for meta-related tasks)
  - [ ] Update state.json for each task:
    - [ ] Add to active_projects array with metadata (project_number, project_name, type, phase, status, priority, created, artifacts)
    - [ ] Increment next_project_number
    - [ ] Use 'type' field (lowercase in state.json, consistent with existing schema)
  - [ ] Validate task entries follow tasks.md standard
  - [ ] Validate state.json updates are correct
- **Timing:** 1.5 hours

### Phase 6: Revise Stage 7 - Validation and Error Handling [NOT STARTED]
- **Goal:** Validate all artifacts and handle errors gracefully
- **Tasks:**
  - [ ] Verify all project directories created
  - [ ] Verify all plan artifacts exist and are non-empty
  - [ ] Verify plan metadata extracted (phase_count, estimated_hours, complexity)
  - [ ] Verify task entries in TODO.md follow tasks.md standard
  - [ ] Verify task entries use 'Type' field (not 'Language')
  - [ ] Verify Type field set to 'meta' for meta tasks
  - [ ] Verify state.json updates are correct
  - [ ] If validation fails: Log errors, return status "failed" with error details
  - [ ] If validation passes: Collect task numbers and artifact paths, proceed to Stage 8
- **Timing:** 1 hour

### Phase 7: Revise Stage 8 - Task Summary Delivery [NOT STARTED]
- **Goal:** Present task list with artifact links and usage instructions
- **Tasks:**
  - [ ] Format task list presentation:
    - [ ] List all created tasks with numbers and titles
    - [ ] Show plan artifact links for each task
    - [ ] Show Type field for each task (meta)
    - [ ] Show status for each task ([NOT STARTED])
  - [ ] Provide usage instructions:
    - [ ] "Review the plan artifacts for each task"
    - [ ] "Run `/implement {task_number}` for each task when ready"
    - [ ] "Meta tasks will route to meta subagents (domain-analyzer, workflow-designer, etc.)"
    - [ ] "Tasks can be implemented in order or in parallel (if no dependencies)"
  - [ ] Create git commit via git-workflow-manager:
    - [ ] Message: "meta: create tasks for {domain} system ({N} tasks)"
    - [ ] Include: TODO.md, state.json, all task directories with plan artifacts
  - [ ] Return standardized format per subagent-return-format.md:
    - [ ] status: "completed"
    - [ ] summary: Brief summary (3-5 sentences, <100 tokens)
    - [ ] artifacts: List of plan artifacts with paths
    - [ ] metadata: session_id, duration, agent_type, delegation_depth, task_count, first_task_number, last_task_number, plan_metadata
    - [ ] next_steps: "Review plan artifacts and run /implement for each task"
- **Timing:** 1.5 hours

### Phase 8: Update Command Documentation [NOT STARTED]
- **Goal:** Update meta.md command documentation to reflect new workflow
- **Tasks:**
  - [ ] Update Workflow section:
    - [ ] Revise Stage 7 description (GenerateSystem → CreateTasksWithArtifacts)
    - [ ] Revise Stage 8 description (DeliverSystem → DeliverTaskSummary)
  - [ ] Update Artifacts section:
    - [ ] Document task entries in TODO.md with Type field
    - [ ] Document plan artifacts (plans/implementation-001.md) - ONLY artifact type
    - [ ] Remove references to research and summary artifacts
    - [ ] Document state.json updates with 'type' field
  - [ ] Add examples showing review → implement workflow
  - [ ] Explain benefits of task-based approach (user review, incremental implementation)
  - [ ] Document meta task routing to meta subagents
- **Timing:** 1 hour

## Testing & Validation

- [ ] Test /meta command with simple system (1-2 agents, 3-4 use cases) - verify 4 tasks created
- [ ] Test /meta command with moderate system (3-5 agents, 4-6 use cases) - verify 7 tasks created
- [ ] Test /meta command with complex system (6-8 agents, 7+ use cases) - verify 10-15 tasks created
- [ ] Verify all plan artifacts follow plan.md standard with status markers
- [ ] Verify NO research or summary artifacts created
- [ ] Verify all task entries follow tasks.md standard with Type field
- [ ] Verify all task entries use 'Type' field (not 'Language')
- [ ] Verify Type field set to 'meta' for meta tasks
- [ ] Verify state.json next_project_number incremented correctly
- [ ] Verify state.json uses 'type' field (lowercase)
- [ ] Verify git commit created with correct message and files
- [ ] Verify return format matches subagent-return-format.md
- [ ] Verify lazy directory creation (no pre-created empty directories)
- [ ] Verify no implementation performed (only tasks and plan artifacts created)
- [ ] Test /implement command routing for meta tasks - verify routes to meta subagents
- [ ] Verify user can review plan artifacts and run /implement for each task

## Artifacts & Outputs

- .opencode/specs/271_revise_meta_command_task_creation/plans/implementation-002.md (this file)
- .opencode/agent/subagents/meta.md (revised Stage 7 and Stage 8)
- .opencode/command/meta.md (updated documentation)
- .opencode/command/implement.md (updated routing for meta tasks)
- .opencode/context/core/standards/tasks.md (Language → Type migration)
- .opencode/context/core/standards/plan.md (Language → Type migration)
- .opencode/context/core/standards/report.md (Language → Type migration)
- .opencode/context/core/system/state-management.md (Language → Type migration)
- Multiple task directories in .opencode/specs/NNN_*/ with plan artifacts only (created during testing)
- Updated .opencode/specs/TODO.md with task entries using Type field (created during testing)
- Updated .opencode/specs/state.json with incremented next_project_number and 'type' field (created during testing)

## Rollback/Contingency

If the revision causes issues:
1. Revert .opencode/agent/subagents/meta.md to previous version (restore Stage 7 GenerateSystem and Stage 8 DeliverSystem)
2. Revert .opencode/command/meta.md to previous version
3. Revert .opencode/command/implement.md to previous version (restore original routing)
4. Revert Language→Type migration in context files (restore 'Language' field)
5. Remove any test task directories created during testing
6. Restore TODO.md and state.json from git history if needed
7. Use git revert on the commit created during testing
8. Document issues in errors.json for future investigation
9. Consider phased rollout: keep old /meta command, add new /meta-tasks command for testing before full replacement

## Revision Notes

**Changes from implementation-001.md:**

1. **Eliminated Phase 2 (Research Artifact Generation)**: Research artifacts are no longer created. Plan artifacts are self-documenting with metadata, overview, and detailed phases.

2. **Eliminated Phase 4 (Summary Artifact Generation)**: Summary artifacts are no longer created. Plan metadata provides summary information (phase_count, estimated_hours, complexity).

3. **Added Phase 1 (Language→Type Migration)**: Comprehensive migration from 'Language' field to 'Type' field across all system files (context, commands, subagents, TODO.md, state.json).

4. **Added Phase 2 (Meta Task Routing)**: Updated /implement command to route meta tasks (Type == 'meta') to meta subagents instead of default implementer.

5. **Updated Phase 5 (Task Entry Creation)**: Task entries now use 'Type' field instead of 'Language' field. Meta tasks set Type to 'meta'.

6. **Simplified Artifact Structure**: Only plan artifacts created per task. No research or summary artifacts.

7. **Reduced Effort Estimate**: 10 hours (down from 13 hours) due to elimination of research and summary artifact generation.

**Rationale:**

- Plan artifacts are self-documenting with metadata section, phase breakdown, and estimates
- Research artifacts were redundant - plan Overview and Goals sections provide context
- Summary artifacts were redundant - plan metadata provides summary information
- Language→Type migration improves semantic clarity (meta is a type, not a language)
- Meta task routing ensures proper delegation to meta subagents for system generation

**Context Window Protection:**

Plan creates 1 artifact per task (plan only). Plan is self-documenting with metadata section, phase breakdown, and estimates. NO research or summary artifacts created. This protects the orchestrator's context window from bloat.

Summary is returned as metadata in the return object summary field, NOT as a separate artifact file.

Reference: artifact-management.md "Context Window Protection via Metadata Passing"
