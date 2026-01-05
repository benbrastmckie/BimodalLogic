# Implementation Plan: Refactor /meta Command to Create Tasks Instead of Direct Implementation (v3)

- **Task**: 306 - Refactor /meta command to create tasks instead of direct implementation
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: Research report (.opencode/specs/306_refactor_meta_command_to_create_tasks_instead_of_direct_implementation/reports/research-001.md) - Comprehensive analysis of current /meta implementation and task creation pattern from /task command
- **Artifacts**: 
  - plans/implementation-003.md (this file - revised plan)
  - .opencode/command/meta.md (updated)
  - .opencode/agent/subagents/meta.md (updated)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: meta
- **Lean Intent**: false
- **Plan Version**: 3
- **Revision Reason**: User requested single task with detailed implementation plan containing appropriate number of phases (not hardcoded), rather than multiple subtasks

---

## Overview

Refactor the /meta command to create tasks with plan artifacts instead of directly implementing system generation. The current implementation executes an 8-stage workflow that directly generates agent, command, and context files via 5 meta subagents. The refactored version will preserve the valuable interview functionality (Stages 0-6) but replace Stage 7 (GenerateSystem) with CreateTasksWithArtifacts and Stage 8 (DeliverSystem) with DeliverTaskSummary. This aligns /meta with the research → plan → implement workflow pattern used by /task command while maintaining backward compatibility with both prompt mode and interactive mode.

This is a single-task implementation with phases determined by the natural breakdown of the work, not by an arbitrary number.

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
- Determine phase count organically based on work breakdown, not hardcoded numbers

**Non-Goals**:
- Creating research artifacts (interview results ARE the research)
- Changing interview stages (0-6) - keep them unchanged
- Removing meta subagents (they may be used in future /implement tasks)
- Implementing the generated system (that's for /implement command)
- Adding new flags or modes (maintain existing API)
- Creating multiple subtasks (single task with detailed plan)

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Breaking change for existing users | High | Medium | Update documentation with clear migration guide, add examples of new workflow (review plans → /implement) |
| Plan generation quality | Medium | Low | Design comprehensive templates with all necessary sections, use interview results to populate specific details, allow users to revise plans with /revise command |
| Task breakdown complexity | Medium | Medium | Use clear heuristics based on agent count and use cases, provide task breakdown preview in Stage 6 (ReviewAndConfirm), document task breakdown strategy |
| Performance regression | Low | Low | Use template-based plan generation (fast, no LLM calls), delegate directly to status-sync-manager (no intermediate layers) |
| Template maintenance overhead | Low | Medium | Keep templates simple and focused, document template structure clearly, test with various interview scenarios |

## Implementation Phases

### Phase 1: Design Plan Generation Templates [NOT STARTED]
- **Goal:** Create reusable templates for generating plan artifacts from interview results
- **Tasks:**
  - [ ] Analyze interview result structure (Stages 0-6 outputs)
  - [ ] Design template for planning task (Task 1: Design architecture and workflow patterns)
  - [ ] Design template for agent implementation tasks
  - [ ] Design template for command implementation tasks
  - [ ] Design template for context implementation tasks
  - [ ] Create helper functions to populate templates with interview data
  - [ ] Test template generation with sample interview data from research report
  - [ ] Validate generated plans follow plan.md standard
- **Timing:** 2 hours
- **Deliverables:**
  - Template structure documentation
  - 4 plan templates (planning, agents, commands, context)
  - Helper functions for template population
  - Test cases with sample data

### Phase 2: Implement Stage 7 CreateTasksWithArtifacts [NOT STARTED]
- **Goal:** Replace direct system generation with task creation following /task command pattern
- **Tasks:**
  - [ ] Read next_project_number from state.json
  - [ ] Implement task breakdown logic based on complexity:
    - Simple (1-2 agents): 4 tasks
    - Moderate (3-5 agents): 7 tasks
    - Complex (6-8 agents): 10-15 tasks
  - [ ] For each task in breakdown:
    - Generate title and slug from interview results
    - Assign task number (next_project_number + index)
    - Create project directory (.opencode/specs/{number}_{slug}/)
    - Generate plan artifact using templates (plans/implementation-001.md)
    - Populate template with interview context
    - Validate plan follows plan.md standard
  - [ ] Delegate to status-sync-manager for atomic task creation:
    - operation: "create_task"
    - Include all task metadata (number, title, description, priority, effort, language)
    - Set new_status: "not_started"
  - [ ] Collect task_numbers from delegation returns
  - [ ] Validate all tasks created successfully (check TODO.md and state.json)
  - [ ] Handle errors with appropriate rollback (remove created directories)
- **Timing:** 3 hours
- **Deliverables:**
  - Updated meta.md Stage 7 with CreateTasksWithArtifacts logic
  - Task breakdown algorithm (complexity-based, not hardcoded)
  - Plan artifact generation using templates
  - status-sync-manager delegation for each task
  - Error handling and rollback logic
  - Validation of atomic task creation

### Phase 3: Implement Stage 8 DeliverTaskSummary [NOT STARTED]
- **Goal:** Replace system delivery with task summary presentation
- **Tasks:**
  - [ ] Format task list with plan artifact links
  - [ ] Generate usage instructions (review plans → run /implement)
  - [ ] Explain task dependencies and execution order
  - [ ] Create git commit via git-workflow-manager:
    - Include TODO.md and state.json
    - Include all task directories with plan artifacts
    - Generate commit message: "meta: create tasks for {domain} system ({N} tasks)"
  - [ ] Return standardized format with task metadata:
    - status: "completed"
    - summary: "Created {N} tasks for {domain} system with plan artifacts"
    - artifacts: array of task objects with number, title, plan_path, status
    - metadata: domain, task_count, first_task_number, last_task_number, integration_mode, timestamp
    - session_id: for tracking
    - next_steps: guidance for user
  - [ ] Validate return format matches subagent-return-format.md
- **Timing:** 1 hour
- **Deliverables:**
  - Updated meta.md Stage 8 with DeliverTaskSummary logic
  - Task list presentation format
  - Usage instructions for /implement workflow
  - git-workflow-manager integration
  - Standardized return format with metadata

### Phase 4: Update Command Documentation [NOT STARTED]
- **Goal:** Update .opencode/command/meta.md to reflect new behavior
- **Tasks:**
  - [ ] Update Workflow section:
    - Revise Stage 7 description (CreateTasksWithArtifacts)
    - Revise Stage 8 description (DeliverTaskSummary)
    - Keep Stages 0-6 descriptions unchanged
  - [ ] Update Artifacts section:
    - Change from system files to plan artifacts
    - Document task creation in TODO.md and state.json
    - Explain plan artifact structure
  - [ ] Update Usage section:
    - Add /implement step after /meta
    - Show workflow: /meta → review plans → /implement {number}
    - Update examples to show new workflow
  - [ ] Add migration guide for existing users:
    - Explain behavior change (tasks vs direct implementation)
    - Show before/after workflow comparison
    - Provide troubleshooting tips
  - [ ] Update command frontmatter if needed
- **Timing:** 30 minutes
- **Deliverables:**
  - Updated Workflow section in meta.md command file
  - Updated Artifacts section
  - Updated Usage section with /implement examples
  - Migration guide for existing users
  - Updated examples showing new workflow

### Phase 5: Comprehensive Testing [NOT STARTED]
- **Goal:** Verify refactored /meta command works correctly for all complexity levels and modes
- **Tasks:**
  - [ ] Test simple system (1-2 agents):
    - Run /meta with simple domain requirements
    - Verify 4 tasks created
    - Verify plan artifacts generated correctly
    - Verify TODO.md and state.json updated atomically
    - Verify git commit includes all artifacts
  - [ ] Test moderate system (3-5 agents):
    - Run /meta with moderate domain requirements
    - Verify 7 tasks created
    - Verify plan artifacts follow plan.md standard
    - Verify task dependencies indicated
    - Verify all required sections present
  - [ ] Test complex system (6-8 agents):
    - Run /meta with complex domain requirements
    - Verify 10-15 tasks created (appropriate number, not hardcoded)
    - Verify plan quality for all tasks
    - Verify task breakdown makes sense
  - [ ] Test prompt mode:
    - Run /meta "domain requirements"
    - Verify Stage 1 skipped
    - Verify Stages 2-8 execute correctly
    - Verify tasks created successfully
  - [ ] Test interactive mode:
    - Run /meta with no arguments
    - Verify full 8-stage interview executes
    - Verify tasks created successfully
  - [ ] Test backward compatibility:
    - Verify command signature unchanged
    - Verify both modes work as expected
    - Verify error handling works
  - [ ] Validate plan artifact quality:
    - Check all required sections present
    - Check metadata block correct
    - Check phases have status markers
    - Check testing criteria included
    - Check rollback plan included
- **Timing:** 1.5 hours
- **Deliverables:**
  - Test results for simple system (4 tasks)
  - Test results for moderate system (7 tasks)
  - Test results for complex system (10-15 tasks)
  - Verification of plan artifact quality
  - Verification of atomic task creation
  - Verification of git commit correctness
  - Verification of backward compatibility
  - Test report documenting all scenarios

## Testing & Validation

- [ ] Interview functionality (Stages 0-6) unchanged and working
- [ ] Stage 7 creates tasks instead of generating system files
- [ ] Stage 8 delivers task summary instead of completed system
- [ ] Plan artifacts follow plan.md standard exactly
- [ ] Plan artifacts include all required sections (metadata, overview, goals, risks, phases, testing, artifacts, rollback)
- [ ] Task breakdown correct for all complexity levels (4, 7, 10-15 tasks)
- [ ] Task breakdown determined by work complexity, not hardcoded
- [ ] status-sync-manager delegation works correctly (atomic updates)
- [ ] git-workflow-manager creates commit with all artifacts
- [ ] Prompt mode works (skips Stage 1, uses $ARGUMENTS)
- [ ] Interactive mode works (full 8-stage interview)
- [ ] Documentation updated and accurate
- [ ] Migration guide clear and helpful
- [ ] Templates generate high-quality plans
- [ ] Error handling and rollback work correctly

## Artifacts & Outputs

- **plans/implementation-003.md** - This revised implementation plan
- **.opencode/command/meta.md** - Updated command file with new Stages 7-8
- **.opencode/agent/subagents/meta.md** - Updated agent file with new workflow
- **Plan generation templates** - Embedded in meta.md Stage 7 logic:
  - Planning task template
  - Agent implementation task template
  - Command implementation task template
  - Context implementation task template
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

If template maintenance becomes burdensome:
1. Simplify templates to essential sections only
2. Document template structure clearly
3. Create template testing framework
4. Consider extracting templates to separate files if they grow large

## Notes

- This revised plan (v3) supersedes implementation-002.md and implementation-001.md
- Single task approach with detailed plan containing appropriate number of phases
- Phase count determined by natural work breakdown, not hardcoded
- Templates embedded in Stage 7 logic for simplicity
- All previous plan versions preserved for reference
- Focus on flexibility and organic phase determination
