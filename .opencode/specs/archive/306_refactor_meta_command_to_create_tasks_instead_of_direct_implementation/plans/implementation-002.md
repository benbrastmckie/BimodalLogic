# Implementation Plan: Refactor /meta Command to Create Tasks Instead of Direct Implementation (v2)

- **Task**: 306 - Refactor /meta command to create tasks instead of direct implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours (distributed across 5 subtasks)
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: Research report (.opencode/specs/306_refactor_meta_command_to_create_tasks_instead_of_direct_implementation/reports/research-001.md) - Comprehensive analysis of current /meta implementation and task creation pattern from /task command
- **Artifacts**: 
  - plans/implementation-002.md (this file - revised plan)
  - 5 subtasks with individual implementation plans (created via /task --divide)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Plan Version**: 2
- **Revision Reason**: User requested systematic plan divided into phases where each phase becomes a separate task with its own implementation plan and dependencies

---

## Overview

This revised plan breaks down the /meta command refactoring into 5 independent tasks, each with its own detailed implementation plan. The work will be divided using `/task --divide` to create subtasks with proper dependency tracking. Each subtask will have a dedicated implementation plan linked in TODO.md, enabling parallel work where possible and clear dependency management.

The refactoring transforms /meta from directly generating system files to creating tasks with plan artifacts, following the research → plan → implement workflow pattern. Interview functionality (Stages 0-6) is preserved while Stages 7-8 are replaced with task creation logic.

## Goals & Non-Goals

**Goals**:
- Create 5 separate tasks (one per phase) with individual implementation plans
- Establish clear dependencies between tasks to enable proper sequencing
- Enable parallel execution where dependencies allow
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
| Task coordination overhead | Medium | Low | Clear dependency tracking, detailed implementation plans per task |
| Breaking change for existing users | High | Medium | Update documentation with clear migration guide, add examples of new workflow (review plans → /implement) |
| Plan generation quality | Medium | Low | Design comprehensive templates with all necessary sections, use interview results to populate specific details, allow users to revise plans with /revise command |
| Task breakdown complexity | Medium | Medium | Use clear heuristics based on agent count and use cases, provide task breakdown preview in Stage 6 (ReviewAndConfirm), document task breakdown strategy |
| Performance regression | Low | Low | Use template-based plan generation (fast, no LLM calls), delegate directly to status-sync-manager (no intermediate layers) |

## Task Breakdown Strategy

This plan will be executed by creating 5 subtasks using `/task --divide`:

```bash
/task --divide "Refactor /meta command to create tasks instead of direct implementation: 1) Create plan generation templates, 2) Refactor Stage 7 to CreateTasksWithArtifacts, 3) Refactor Stage 8 to DeliverTaskSummary, 4) Update command documentation, 5) Test with all complexity levels"
```

Each subtask will receive:
- Dedicated task number (e.g., 306.1, 306.2, etc. or sequential numbers)
- Individual implementation plan in its own directory
- Clear dependencies on prerequisite tasks
- Effort estimate and priority
- Link to parent task 306

## Subtask Definitions

### Subtask 1: Create Plan Generation Templates
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: None (can start immediately)
- **Description**: Create reusable templates for generating plan artifacts from interview results. Templates needed for: planning task (architecture design), agent implementation tasks, command implementation tasks, and context implementation tasks. Include helper functions to populate templates with interview data.
- **Deliverables**:
  - Template for planning task (Task 1: Design architecture and workflow patterns)
  - Template for agent implementation tasks
  - Template for command implementation tasks
  - Template for context implementation tasks
  - Helper functions to populate templates with interview results
  - Test cases with sample interview data

### Subtask 2: Refactor Stage 7 to CreateTasksWithArtifacts
- **Effort**: 3 hours
- **Priority**: High
- **Dependencies**: Subtask 1 (requires templates)
- **Description**: Replace direct system generation with task creation following /task command pattern. Implement task breakdown logic based on complexity (4, 7, or 10-15 tasks), generate plan artifacts using templates, delegate to status-sync-manager for atomic task creation.
- **Deliverables**:
  - Updated meta.md Stage 7 with CreateTasksWithArtifacts logic
  - Task breakdown algorithm (complexity-based)
  - Plan artifact generation using templates
  - status-sync-manager delegation for each task
  - Error handling and rollback logic
  - Validation of all tasks created successfully

### Subtask 3: Refactor Stage 8 to DeliverTaskSummary
- **Effort**: 1 hour
- **Priority**: High
- **Dependencies**: Subtask 2 (requires Stage 7 completion)
- **Description**: Replace system delivery with task summary presentation. Present task list with plan artifact links, provide usage instructions (review plans → run /implement), create git commit via git-workflow-manager, return standardized format with task metadata.
- **Deliverables**:
  - Updated meta.md Stage 8 with DeliverTaskSummary logic
  - Task list presentation format
  - Usage instructions for /implement workflow
  - git-workflow-manager integration
  - Standardized return format with metadata

### Subtask 4: Update Command Documentation
- **Effort**: 30 minutes
- **Priority**: Medium
- **Dependencies**: Subtasks 2 and 3 (requires implementation completion)
- **Description**: Update .opencode/command/meta.md to reflect new behavior. Update Workflow section (Stages 7-8 descriptions), Artifacts section (plan artifacts instead of system files), Usage section (add /implement step), add migration guide for existing users.
- **Deliverables**:
  - Updated Workflow section in meta.md command file
  - Updated Artifacts section
  - Updated Usage section with /implement examples
  - Migration guide for existing users
  - Updated examples showing new workflow

### Subtask 5: Test with All Complexity Levels
- **Effort**: 1.5 hours
- **Priority**: High
- **Dependencies**: Subtasks 2, 3, and 4 (requires full implementation)
- **Description**: Verify refactored /meta command works correctly for simple, moderate, and complex systems. Test both prompt mode and interactive mode. Verify plan artifacts, task creation atomicity, git commits, and backward compatibility.
- **Deliverables**:
  - Test results for simple system (1-2 agents, 4 tasks)
  - Test results for moderate system (3-5 agents, 7 tasks)
  - Test results for complex system (6-8 agents, 10-15 tasks)
  - Verification of plan artifact quality
  - Verification of atomic task creation
  - Verification of git commit correctness
  - Verification of backward compatibility

## Dependency Graph

```
Subtask 1 (Templates)
    ↓
Subtask 2 (Stage 7)
    ↓
Subtask 3 (Stage 8)
    ↓
Subtask 4 (Documentation) ←─┐
    ↓                        │
Subtask 5 (Testing) ─────────┘
```

**Parallel Execution Opportunities**:
- Subtask 1 can start immediately
- Subtask 4 can start as soon as Subtasks 2 and 3 are complete (doesn't need to wait for testing)
- Subtask 5 requires all others to be complete

## Implementation Phases

### Phase 1: Create Subtasks with Implementation Plans [NOT STARTED]
- **Goal:** Use /task --divide to create 5 subtasks with individual implementation plans
- **Tasks:**
  - [ ] Run `/task --divide` command with subtask descriptions
  - [ ] Verify 5 tasks created with sequential numbers
  - [ ] Verify each task has dedicated directory in .opencode/specs/
  - [ ] Verify each task has implementation plan (plans/implementation-001.md)
  - [ ] Verify dependencies correctly set in TODO.md and state.json
  - [ ] Verify all tasks link back to parent task 306
- **Timing:** 15 minutes

### Phase 2: Execute Subtasks in Dependency Order [NOT STARTED]
- **Goal:** Implement each subtask following dependency graph
- **Tasks:**
  - [ ] Execute Subtask 1 (Templates) - no dependencies
  - [ ] Execute Subtask 2 (Stage 7) - depends on Subtask 1
  - [ ] Execute Subtask 3 (Stage 8) - depends on Subtask 2
  - [ ] Execute Subtask 4 (Documentation) - depends on Subtasks 2 and 3
  - [ ] Execute Subtask 5 (Testing) - depends on all previous subtasks
- **Timing:** 8 hours total (distributed across subtasks)

### Phase 3: Validate Complete Implementation [NOT STARTED]
- **Goal:** Verify all subtasks completed and integration successful
- **Tasks:**
  - [ ] Verify all 5 subtasks marked [COMPLETED]
  - [ ] Verify /meta command works end-to-end
  - [ ] Verify interview functionality preserved
  - [ ] Verify task creation works for all complexity levels
  - [ ] Verify documentation accurate and complete
  - [ ] Create final git commit for task 306
- **Timing:** 30 minutes

## Testing & Validation

- [ ] All 5 subtasks created with individual implementation plans
- [ ] Dependencies correctly tracked in TODO.md and state.json
- [ ] Each subtask has dedicated directory and plan artifact
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

- **plans/implementation-002.md** - This revised implementation plan
- **5 subtask directories** - Created via /task --divide:
  - .opencode/specs/{N}_create_plan_generation_templates/
  - .opencode/specs/{N+1}_refactor_stage_7_to_createtaskswithartifacts/
  - .opencode/specs/{N+2}_refactor_stage_8_to_delivertasksummary/
  - .opencode/specs/{N+3}_update_command_documentation/
  - .opencode/specs/{N+4}_test_with_all_complexity_levels/
- **5 implementation plans** - One per subtask:
  - plans/implementation-001.md in each subtask directory
- **.opencode/command/meta.md** - Updated command file (via Subtasks 2, 3)
- **.opencode/agent/subagents/meta.md** - Updated agent file (via Subtasks 2, 3)
- **summaries/implementation-summary-YYYYMMDD.md** - Implementation summary (created after completion)

## Rollback/Contingency

If task division fails:
1. Fall back to implementation-001.md (monolithic approach)
2. Execute phases sequentially without separate tasks
3. Document reason for not using task division

If subtask execution fails:
1. Identify which subtask failed
2. Review subtask implementation plan
3. Fix issues in that subtask only
4. Re-execute failed subtask
5. Continue with dependent subtasks

If integration fails:
1. Revert .opencode/command/meta.md to previous version (git checkout)
2. Revert .opencode/agent/subagents/meta.md to previous version (git checkout)
3. Review error logs to identify root cause
4. Adjust subtask plans based on findings
5. Retry implementation with fixes

## Execution Instructions

To execute this plan:

1. **Create subtasks**:
   ```bash
   /task --divide "Refactor /meta command to create tasks instead of direct implementation: 1) Create plan generation templates (2h), 2) Refactor Stage 7 to CreateTasksWithArtifacts (3h), 3) Refactor Stage 8 to DeliverTaskSummary (1h), 4) Update command documentation (30m), 5) Test with all complexity levels (1.5h)"
   ```

2. **Execute subtasks in order**:
   ```bash
   /implement {subtask_1_number}  # Templates
   /implement {subtask_2_number}  # Stage 7 (depends on subtask 1)
   /implement {subtask_3_number}  # Stage 8 (depends on subtask 2)
   /implement {subtask_4_number}  # Documentation (depends on subtasks 2, 3)
   /implement {subtask_5_number}  # Testing (depends on all)
   ```

3. **Validate and complete**:
   ```bash
   # Verify all subtasks completed
   # Test /meta command end-to-end
   # Mark task 306 as completed
   ```

## Notes

- This revised plan (v2) supersedes implementation-001.md
- The monolithic approach (v1) remains valid if task division is not desired
- Dependencies are enforced through TODO.md and state.json metadata
- Each subtask can be reviewed and revised independently
- Parallel execution possible for Subtask 4 (Documentation) once Subtasks 2 and 3 complete
