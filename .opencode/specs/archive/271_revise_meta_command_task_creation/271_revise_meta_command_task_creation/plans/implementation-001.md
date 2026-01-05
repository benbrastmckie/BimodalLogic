# Implementation Plan: Revise /meta Command to Create Tasks with Linked Artifacts

- **Task**: 271 - Revise /meta command to create tasks with linked artifacts instead of implementing directly
- **Status**: [NOT STARTED]
- **Effort**: 13 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/271_revise_meta_command_task_creation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
  - .opencode/context/core/standards/report.md
  - .opencode/context/core/standards/summary.md
  - .opencode/context/core/standards/subagent-return-format.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

The `/meta` command currently implements a complete system generation workflow (Stages 0-8) that directly creates agent files, command files, and context files. This plan revises the command to align with the research → plan → implement workflow used by other ProofChecker commands. After conducting the interview (Stages 0-6), the command will create tasks in TODO.md with linked research and plan artifacts instead of directly implementing the system. This enables user review before implementation and follows ProofChecker artifact management standards.

## Goals & Non-Goals

**Goals:**
- Revise Stage 7 (GenerateSystem → CreateTasksWithArtifacts) to create tasks with artifacts instead of implementing
- Revise Stage 8 (DeliverSystem → DeliverTaskSummary) to present task list with usage instructions
- Generate research artifacts (reports/research-001.md) for each task following report.md standard
- Generate plan artifacts (plans/implementation-001.md) for each task following plan.md standard
- Generate summary artifacts (summaries/) for each task following summary.md standard (<100 tokens)
- Create task entries in TODO.md with proper artifact links following tasks.md standard
- Use next_project_number from state.json for task numbering and increment for each task
- Implement task breakdown strategy based on system complexity (simple: 4 tasks, moderate: 7 tasks, complex: 10-15 tasks)
- Update command documentation (meta.md) to reflect new workflow
- Follow lazy directory creation (create directories only when writing files)
- Return standardized format per subagent-return-format.md

**Non-Goals:**
- Changing Stages 0-6 (interview stages remain unchanged)
- Implementing the generated system (that's for `/implement` command)
- Creating placeholder files or pre-created empty directories
- Modifying meta subagents (domain-analyzer, workflow-designer, agent-generator, command-creator, context-organizer) - these may be repurposed for artifact content generation in future work

## Risks & Mitigations

**Risk 1: Task Breakdown Complexity**
- Risk: Determining optimal task breakdown for different system sizes may be complex
- Mitigation: Use clear heuristics based on agent count and use case count from interview; follow task-breakdown.md workflow; start with simple strategy (research task + planning task + N implementation tasks)

**Risk 2: Artifact Generation Quality**
- Risk: Generated research and plan artifacts may not meet quality standards
- Mitigation: Use templates from report.md and plan.md standards; validate against standards before returning; include validation checks for non-empty files, token limits, required sections

**Risk 3: Context Window Bloat**
- Risk: Generating multiple artifacts may bloat context window
- Mitigation: Use summary artifacts (<100 tokens); return artifact paths not content in return object; follow subagent-return-format.md; keep summary field in return object brief (3-5 sentences)

**Risk 4: User Confusion**
- Risk: Users may be confused by task-based workflow instead of immediate implementation
- Mitigation: Provide clear instructions in Stage 8; explain review → implement workflow; show example commands; document workflow change in meta.md

**Risk 5: State.json Synchronization**
- Risk: Multiple task creations may cause state.json conflicts or incorrect next_project_number
- Mitigation: Read next_project_number once at start of Stage 7; increment locally for each task; write all state.json updates atomically at end; validate next_project_number before each increment

## Implementation Phases

### Phase 1: Revise Stage 7 - Task Breakdown Logic [NOT STARTED]
- **Goal:** Implement task breakdown strategy based on system complexity
- **Tasks:**
  - [ ] Read interview results from Stage 6 (agent count, use case count, complexity assessment)
  - [ ] Implement task breakdown heuristics:
    - [ ] Simple system (1-2 agents, 3-4 use cases): 4 tasks (research, planning, 2 implementation)
    - [ ] Moderate system (3-5 agents, 4-6 use cases): 7 tasks (research, planning, 5 implementation)
    - [ ] Complex system (6-8 agents, 7+ use cases): 10-15 tasks (research, planning, 8-13 implementation)
  - [ ] Generate task titles and slugs from interview results
  - [ ] Read next_project_number from .opencode/specs/state.json
  - [ ] Create task number sequence (next_project_number, next_project_number+1, ...)
- **Timing:** 1.5 hours

### Phase 2: Revise Stage 7 - Research Artifact Generation [NOT STARTED]
- **Goal:** Generate research artifacts for each task following report.md standard
- **Tasks:**
  - [ ] For research task: Generate domain analysis, core concepts, use case analysis, complexity assessment, integration requirements, recommended architecture
  - [ ] For planning task: Generate architecture design, workflow patterns, agent hierarchy, integration points
  - [ ] For implementation tasks: Generate component requirements (agent/command/context), interface specifications, workflow definitions, integration points, dependencies
  - [ ] Follow report.md standard structure (metadata, executive summary, sections, sources)
  - [ ] Create project directory: .opencode/specs/{number}_{slug}/ (lazy creation)
  - [ ] Write research artifact: reports/research-001.md
  - [ ] Validate artifact exists and is non-empty
- **Timing:** 2 hours

### Phase 3: Revise Stage 7 - Plan Artifact Generation [NOT STARTED]
- **Goal:** Generate plan artifacts for each task following plan.md standard
- **Tasks:**
  - [ ] Generate plan metadata block (Task, Status, Effort, Priority, Dependencies, Research Inputs, Artifacts, Standards, Language, Lean Intent)
  - [ ] Generate Overview (2-4 sentences)
  - [ ] Generate Goals & Non-Goals
  - [ ] Generate Risks & Mitigations
  - [ ] Generate Implementation Phases (1-2 hours each, status markers [NOT STARTED])
  - [ ] Generate Testing & Validation
  - [ ] Generate Artifacts & Outputs
  - [ ] Generate Rollback/Contingency
  - [ ] Write plan artifact: plans/implementation-001.md
  - [ ] Validate artifact exists and is non-empty
- **Timing:** 2 hours

### Phase 4: Revise Stage 7 - Summary Artifact Generation [NOT STARTED]
- **Goal:** Generate summary artifacts for each task following summary.md standard
- **Tasks:**
  - [ ] Generate research-summary.md (3-5 sentences, <100 tokens, key findings)
  - [ ] Generate plan-summary.md (3-5 sentences, <100 tokens, phase overview)
  - [ ] Write summary artifacts: summaries/research-summary.md, summaries/plan-summary.md
  - [ ] Validate summaries within token limit (<100 tokens each)
  - [ ] Validate summaries are non-empty
- **Timing:** 1 hour

### Phase 5: Revise Stage 7 - Task Entry Creation and State Updates [NOT STARTED]
- **Goal:** Create task entries in TODO.md and update state.json
- **Tasks:**
  - [ ] For each task, create task entry in TODO.md following tasks.md standard:
    - [ ] Include task number and title (### {number}. {title})
    - [ ] Include all required fields: Effort, Status, Priority, Language, Research, Plan, Blocking, Dependencies
    - [ ] Link to research artifact: `- **Research**: [Research Report]({path}/reports/research-001.md)`
    - [ ] Link to plan artifact: `- **Plan**: [Implementation Plan]({path}/plans/implementation-001.md)`
    - [ ] Set Status: [NOT STARTED]
  - [ ] Update state.json for each task:
    - [ ] Add to active_projects array with metadata (project_number, project_name, type, phase, status, priority, language, created, artifacts)
    - [ ] Increment next_project_number
  - [ ] Validate task entries follow tasks.md standard
  - [ ] Validate state.json updates are correct
- **Timing:** 1.5 hours

### Phase 6: Revise Stage 7 - Validation and Error Handling [NOT STARTED]
- **Goal:** Validate all artifacts and handle errors gracefully
- **Tasks:**
  - [ ] Verify all project directories created
  - [ ] Verify all research artifacts exist and are non-empty
  - [ ] Verify all plan artifacts exist and are non-empty
  - [ ] Verify all summary artifacts exist and within token limit (<100 tokens)
  - [ ] Verify task entries in TODO.md follow tasks.md standard
  - [ ] Verify state.json updates are correct
  - [ ] If validation fails: Log errors, return status "failed" with error details
  - [ ] If validation passes: Collect task numbers and artifact paths, proceed to Stage 8
- **Timing:** 1 hour

### Phase 7: Revise Stage 8 - Task Summary Delivery [NOT STARTED]
- **Goal:** Present task list with artifact links and usage instructions
- **Tasks:**
  - [ ] Format task list presentation:
    - [ ] List all created tasks with numbers and titles
    - [ ] Show artifact links for each task (research, plan)
    - [ ] Show status for each task ([NOT STARTED])
  - [ ] Provide usage instructions:
    - [ ] "Review the research and plan artifacts for each task"
    - [ ] "Run `/implement {task_number}` for each task when ready"
    - [ ] "Tasks can be implemented in order or in parallel (if no dependencies)"
  - [ ] Create git commit via git-workflow-manager:
    - [ ] Message: "meta: create tasks for {domain} system ({N} tasks)"
    - [ ] Include: TODO.md, state.json, all task directories with artifacts
  - [ ] Return standardized format per subagent-return-format.md:
    - [ ] status: "completed"
    - [ ] summary: Brief summary (3-5 sentences, <100 tokens)
    - [ ] artifacts: List of task artifacts with paths
    - [ ] metadata: session_id, duration, agent_type, delegation_depth, task_count, first_task_number, last_task_number
    - [ ] next_steps: "Review artifacts and run /implement for each task"
- **Timing:** 1.5 hours

### Phase 8: Update Command Documentation [NOT STARTED]
- **Goal:** Update meta.md command documentation to reflect new workflow
- **Tasks:**
  - [ ] Update Workflow section:
    - [ ] Revise Stage 7 description (GenerateSystem → CreateTasksWithArtifacts)
    - [ ] Revise Stage 8 description (DeliverSystem → DeliverTaskSummary)
  - [ ] Update Artifacts section:
    - [ ] Document task entries in TODO.md
    - [ ] Document research artifacts (reports/research-001.md)
    - [ ] Document plan artifacts (plans/implementation-001.md)
    - [ ] Document summary artifacts (summaries/)
    - [ ] Document state.json updates
  - [ ] Add examples showing review → implement workflow
  - [ ] Explain benefits of task-based approach (user review, incremental implementation)
- **Timing:** 1 hour

### Phase 9: Testing and Validation [NOT STARTED]
- **Goal:** Test revised /meta command with different system complexities
- **Tasks:**
  - [ ] Test simple system (1-2 agents, 3-4 use cases):
    - [ ] Verify 4 tasks created
    - [ ] Verify all artifacts created and valid
    - [ ] Verify task entries in TODO.md
    - [ ] Verify state.json updates
  - [ ] Test moderate system (3-5 agents, 4-6 use cases):
    - [ ] Verify 7 tasks created
    - [ ] Verify all artifacts created and valid
  - [ ] Test complex system (6-8 agents, 7+ use cases):
    - [ ] Verify 10-15 tasks created
    - [ ] Verify all artifacts created and valid
  - [ ] Validate artifact standards compliance:
    - [ ] Research artifacts follow report.md
    - [ ] Plan artifacts follow plan.md
    - [ ] Summary artifacts follow summary.md (<100 tokens)
    - [ ] Task entries follow tasks.md
  - [ ] Validate git commit created successfully
  - [ ] Validate return format matches subagent-return-format.md
- **Timing:** 1.5 hours

## Testing & Validation

- [ ] Test /meta command with simple system (1-2 agents, 3-4 use cases) - verify 4 tasks created
- [ ] Test /meta command with moderate system (3-5 agents, 4-6 use cases) - verify 7 tasks created
- [ ] Test /meta command with complex system (6-8 agents, 7+ use cases) - verify 10-15 tasks created
- [ ] Verify all research artifacts follow report.md standard
- [ ] Verify all plan artifacts follow plan.md standard with status markers
- [ ] Verify all summary artifacts follow summary.md standard (<100 tokens)
- [ ] Verify all task entries follow tasks.md standard
- [ ] Verify state.json next_project_number incremented correctly
- [ ] Verify git commit created with correct message and files
- [ ] Verify return format matches subagent-return-format.md
- [ ] Verify lazy directory creation (no pre-created empty directories)
- [ ] Verify no implementation performed (only tasks and artifacts created)
- [ ] Verify user can review artifacts and run /implement for each task

## Artifacts & Outputs

- .opencode/specs/271_revise_meta_command_task_creation/plans/implementation-001.md (this file)
- .opencode/agent/subagents/meta.md (revised Stage 7 and Stage 8)
- .opencode/command/meta.md (updated documentation)
- .opencode/specs/271_revise_meta_command_task_creation/summaries/implementation-summary-YYYYMMDD.md (created at completion)
- Multiple task directories in .opencode/specs/NNN_*/ with research, plan, and summary artifacts (created during testing)
- Updated .opencode/specs/TODO.md with task entries (created during testing)
- Updated .opencode/specs/state.json with incremented next_project_number (created during testing)

## Rollback/Contingency

If the revision causes issues:
1. Revert .opencode/agent/subagents/meta.md to previous version (restore Stage 7 GenerateSystem and Stage 8 DeliverSystem)
2. Revert .opencode/command/meta.md to previous version
3. Remove any test task directories created during testing
4. Restore TODO.md and state.json from git history if needed
5. Use git revert on the commit created during testing
6. Document issues in errors.json for future investigation
7. Consider phased rollout: keep old /meta command, add new /meta-tasks command for testing before full replacement
