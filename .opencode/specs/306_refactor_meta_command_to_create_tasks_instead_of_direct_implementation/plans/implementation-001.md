# Implementation Plan: Refactor /meta Command to Create Tasks Instead of Direct Implementation

- **Task**: 306 - Refactor /meta command to create tasks instead of direct implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: Research report (.opencode/specs/306_refactor_meta_command_to_create_tasks_instead_of_direct_implementation/reports/research-001.md) - Comprehensive analysis of current /meta implementation and task creation pattern from /task command
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/command/meta.md (updated)
  - .opencode/agent/subagents/meta.md (updated)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false

---

## Overview

Refactor the /meta command to create tasks with plan artifacts instead of directly implementing system generation. The current implementation executes an 8-stage workflow that directly generates agent, command, and context files via 5 meta subagents. The refactored version will preserve the valuable interview functionality (Stages 0-6) but replace Stage 7 (GenerateSystem) with CreateTasksWithArtifacts and Stage 8 (DeliverSystem) with DeliverTaskSummary. This aligns /meta with the research → plan → implement workflow pattern used by /task command while maintaining backward compatibility with both prompt mode and interactive mode.

## Goals & Non-Goals

**Goals**:
- Preserve interview functionality (Stages 0-6) - this is /meta's unique value proposition
- Replace Stage 7 (GenerateSystem) with CreateTasksWithArtifacts following /task command pattern
- Replace Stage 8 (DeliverSystem) with DeliverTaskSummary
- Create plan artifacts only (interview results provide research context)
- Delegate directly to status-sync-manager for atomic task creation
- Use template-based plan generation for speed and consistency
- Maintain backward compatibility with prompt mode and interactive mode
- Support task breakdown based on system complexity (4, 7, or 10-15 tasks)

**Non-Goals**:
- Creating research artifacts (interview results ARE the research)
- Changing interview stages (0-6) - keep them unchanged
- Removing meta subagents (they may be used in future /implement tasks)
- Implementing the generated system (that's for /implement command)
- Adding new flags or modes (maintain existing API)

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Breaking change for existing users | High | Medium | Update documentation with clear migration guide, add examples of new workflow (review plans → /implement) |
| Plan generation quality | Medium | Low | Design comprehensive templates with all necessary sections, use interview results to populate specific details, allow users to revise plans with /revise command |
| Task breakdown complexity | Medium | Medium | Use clear heuristics based on agent count and use cases, provide task breakdown preview in Stage 6 (ReviewAndConfirm), document task breakdown strategy |
| Performance regression | Low | Low | Use template-based plan generation (fast, no LLM calls), delegate directly to status-sync-manager (no intermediate layers) |

## Implementation Phases

### Phase 1: Create Plan Generation Templates [NOT STARTED]
- **Goal:** Create reusable templates for generating plan artifacts from interview results
- **Tasks:**
  - [ ] Create template for planning task (Task 1: Design architecture and workflow patterns)
  - [ ] Create template for agent implementation tasks
  - [ ] Create template for command implementation tasks
  - [ ] Create template for context implementation tasks
  - [ ] Add helper functions to populate templates with interview results
  - [ ] Test template generation with sample interview data
- **Timing:** 2 hours

### Phase 2: Refactor Stage 7 to CreateTasksWithArtifacts [NOT STARTED]
- **Goal:** Replace direct system generation with task creation following /task command pattern
- **Tasks:**
  - [ ] Read next_project_number from state.json
  - [ ] Implement task breakdown logic based on complexity (4, 7, or 10-15 tasks)
  - [ ] For each task: generate title, slug, description from interview results
  - [ ] For each task: create project directory (.opencode/specs/{number}_{slug}/)
  - [ ] For each task: generate plan artifact using templates (plans/implementation-001.md)
  - [ ] For each task: delegate to status-sync-manager for atomic task creation
  - [ ] Collect task_numbers from returns
  - [ ] Validate all tasks created successfully
  - [ ] Handle errors with appropriate rollback
- **Timing:** 3 hours

### Phase 3: Refactor Stage 8 to DeliverTaskSummary [NOT STARTED]
- **Goal:** Replace system delivery with task summary presentation
- **Tasks:**
  - [ ] Present task list with plan artifact links
  - [ ] Provide usage instructions (review plans → run /implement)
  - [ ] Create git commit via git-workflow-manager (TODO.md, state.json, task directories)
  - [ ] Return standardized format with task metadata
  - [ ] Include domain, task_count, first_task_number, last_task_number in metadata
  - [ ] Add next_steps guidance
- **Timing:** 1 hour

### Phase 4: Update Command Documentation [NOT STARTED]
- **Goal:** Update .opencode/command/meta.md to reflect new behavior
- **Tasks:**
  - [ ] Update Workflow section (Stages 7-8 descriptions)
  - [ ] Update Artifacts section (plan artifacts instead of system files)
  - [ ] Update Usage section (add /implement step)
  - [ ] Add migration guide for existing users
  - [ ] Update examples to show new workflow
- **Timing:** 30 minutes

### Phase 5: Testing with All Complexity Levels [NOT STARTED]
- **Goal:** Verify refactored /meta command works correctly for simple, moderate, and complex systems
- **Tasks:**
  - [ ] Test simple system (1-2 agents): Verify 4 tasks created
  - [ ] Test moderate system (3-5 agents): Verify 7 tasks created
  - [ ] Test complex system (6-8 agents): Verify 10-15 tasks created
  - [ ] Verify plan artifacts generated correctly with all required sections
  - [ ] Verify task creation atomic (TODO.md + state.json both updated)
  - [ ] Verify git commit includes all artifacts
  - [ ] Test both prompt mode and interactive mode
  - [ ] Verify backward compatibility (existing API unchanged)
- **Timing:** 1.5 hours

## Testing & Validation

- [ ] Interview functionality (Stages 0-6) unchanged and working
- [ ] Stage 7 creates tasks instead of generating system files
- [ ] Stage 8 delivers task summary instead of completed system
- [ ] Plan artifacts follow plan.md standard exactly
- [ ] Plan artifacts include all required sections (metadata, overview, goals, risks, phases, testing, artifacts, rollback)
- [ ] Task breakdown correct for all complexity levels (4, 7, 10-15 tasks)
- [ ] status-sync-manager delegation works correctly (atomic updates)
- [ ] git-workflow-manager creates commit with all artifacts
- [ ] Prompt mode works (skips Stage 1, uses $ARGUMENTS)
- [ ] Interactive mode works (full 8-stage interview)
- [ ] Documentation updated and accurate
- [ ] Migration guide clear and helpful

## Artifacts & Outputs

- **plans/implementation-001.md** - This implementation plan
- **.opencode/command/meta.md** - Updated command file with new Stages 7-8
- **.opencode/agent/subagents/meta.md** - Updated agent file with new workflow
- **Plan generation templates** - Embedded in meta.md Stage 7 logic
- **summaries/implementation-summary-YYYYMMDD.md** - Implementation summary (created after completion)

## Rollback/Contingency

If refactoring fails or causes critical issues:
1. Revert .opencode/command/meta.md to previous version (git checkout)
2. Revert .opencode/agent/subagents/meta.md to previous version (git checkout)
3. Review error logs to identify root cause
4. Adjust plan based on findings
5. Retry implementation with fixes

If plan generation quality is insufficient:
1. Enhance templates with more detailed sections
2. Add more interview result fields to template population
3. Test with real examples and iterate
4. Consider adding LLM-based plan enhancement as optional step

If task breakdown logic is incorrect:
1. Review heuristics for complexity-based breakdown
2. Add user confirmation step in Stage 6 to preview task breakdown
3. Allow user to adjust task count before creation
4. Document task breakdown strategy more clearly
