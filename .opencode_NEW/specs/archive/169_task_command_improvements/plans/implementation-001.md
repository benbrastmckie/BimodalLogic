# Implementation Plan: /task Command Context Window Protection

**SUPERSEDED**: This plan has been superseded by [implementation-002.md](implementation-002.md) on 2025-12-24. Version 2 implements a clean-break approach without backward compatibility layers.

- **Task**: 169 - Improve /task command to protect primary agent context window
- **Status**: [SUPERSEDED]
- **Started**: 2025-12-24
- **Superseded**: 2025-12-24
- **Effort**: 6 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/169_task_command_improvements/reports/research-001.md (820 lines)
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
  - .opencode/context/core/system/git-commits.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

The /task command and its subagents (task-executor, batch-task-orchestrator) currently return verbose execution details (100+ lines per task) instead of artifact references and brief summaries, causing context window bloat in the primary agent. This plan implements artifact-first returns with progressive summarization, differentiates simple (direct execution) vs complex (plan-based) task paths, and enforces appropriate git commit patterns. Success is defined as: single task returns <500 tokens, batch returns <50 lines per 10 tasks, and all subagents create summary artifacts per artifact-management.md.

## Goals & Non-Goals

**Goals**:
- Implement artifact-first return format for task-executor (artifact references + 3-5 sentence summaries + key metrics)
- Enforce summary artifact creation for all detailed artifacts (research, plans, implementations)
- Add complexity assessment to /task command for routing differentiation
- Update batch-task-orchestrator to aggregate brief summaries (progressive summarization)
- Differentiate git commit patterns: simple tasks (single commit), complex tasks (commit per phase)
- Add validation layer to enforce return format compliance and summary requirements
- Achieve context window protection targets: <500 tokens per task, <50 lines per 10-task batch

**Non-Goals**:
- Changing task-executor's internal workflow or coordinator routing logic
- Modifying existing plan/research/implementation formats (only adding summaries)
- Implementing new complexity scoring algorithms (use research-001.md 7-factor scoring)
- Changing TODO.md task metadata structure
- Modifying status-sync-manager or batch-status-manager internals

## Risks & Mitigations

- **Risk**: Breaking changes to return format may impact commands that consume task-executor/batch-task-orchestrator responses.
  - **Mitigation**: Implement backward compatibility layer; audit all consuming commands (.opencode/command/*.md); update in parallel with this plan.

- **Risk**: Summary quality variance may miss important details or be too generic.
  - **Mitigation**: Provide clear templates (Appendix C in research-001.md); include examples; add quality validation checks; allow manual refinement.

- **Risk**: Complexity assessment may misclassify tasks (simple as complex or vice versa).
  - **Mitigation**: Use robust 7-indicator scoring (research-001.md Appendix B); allow manual override flags (--simple, --complex); monitor and tune thresholds.

- **Risk**: Phase-based commits for complex tasks may create too many small commits.
  - **Mitigation**: Only commit when phase produces artifacts; allow squashing during review; document commit patterns in git-commits.md.

- **Risk**: Integration testing may reveal unforeseen edge cases or workflow breaks.
  - **Mitigation**: Comprehensive test scenarios (single simple, single complex, batch mixed, error cases); incremental rollout; rollback plan ready.

## Implementation Phases

### Phase 1: Update task-executor Return Format [NOT STARTED]

- **Goal**: Replace verbose return format with artifact-first returns (references + brief summaries + metrics)
- **Tasks**:
  - [ ] Read current task-executor.md stage 10 ReturnToOrchestrator (lines 559-706)
  - [ ] Design new return format per research-001.md Priority 1 recommendation
  - [ ] Update stage 10 to return: {task_number, status, artifacts: [{type, path}], summary: "3-5 sentences", key_metrics: {complexity, effort, files_modified}}
  - [ ] Remove verbose fields: coordinator_results, workflow_executed, todo_status_tracking details
  - [ ] Add max 500 token limit validation
  - [ ] Update task-executor.md documentation with new return format and examples
  - [ ] Test return format with sample task execution
- **Timing**: 1 hour
- **Dependencies**: None
- **Validation**: Return format matches template; token count <500; all required fields present

### Phase 2: Enforce Summary Artifact Creation [NOT STARTED]

- **Goal**: Ensure all detailed artifacts (research, plans, implementations) have corresponding summary artifacts
- **Tasks**:
  - [ ] Read artifact-management.md summary requirements (lines 85-89)
  - [ ] Read research-001.md Appendix C summary templates
  - [ ] Update task-executor stage 5 (ExecuteResearchPhase) to create summaries/research-summary.md after research-001.md
  - [ ] Update task-executor stage 6 (ExecutePlanningPhase) to create summaries/plan-summary.md after implementation-001.md
  - [ ] Update task-executor stage 7 (ExecuteImplementationPhase) to create summaries/implementation-summary-YYYYMMDD.md after implementation
  - [ ] Enforce lazy directory creation: create summaries/ only when writing first summary
  - [ ] Add validation: if detailed artifact exists, summary must exist
  - [ ] Update task-executor.md documentation with summary creation workflow
- **Timing**: 45 minutes
- **Dependencies**: Phase 1 (return format must reference summary artifacts)
- **Validation**: Summary artifacts created for all detailed artifacts; summaries/ created lazily; summaries follow templates

### Phase 3: Implement Complexity Router in /task Command [NOT STARTED]

- **Goal**: Add complexity assessment stage to /task command for routing differentiation
- **Tasks**:
  - [ ] Read research-001.md Appendix B complexity scoring algorithm (7 indicators)
  - [ ] Read current task.md workflow stages 1-4
  - [ ] Add new stage 2.5 AssessComplexity between ResolveTasks and Execute
  - [ ] Implement 7-factor scoring: effort, files, LOC, dependencies, research, unknowns, risk (0-2 each)
  - [ ] Set thresholds: 0-4=simple, 5-9=moderate, 10-14=complex
  - [ ] Pass complexity flag to task-executor for execution path differentiation
  - [ ] Add manual override flags: --simple, --complex
  - [ ] Update task.md documentation with complexity assessment workflow
- **Timing**: 1 hour
- **Dependencies**: None (independent of return format changes)
- **Validation**: Complexity scores calculated correctly; thresholds applied; flags passed to executor

### Phase 4: Update batch-task-orchestrator Return Format [NOT STARTED]

- **Goal**: Implement progressive summarization for batch execution (aggregate brief summaries)
- **Tasks**:
  - [ ] Read current batch-task-orchestrator.md stage 6 ReturnResults (lines 341-400)
  - [ ] Read research-001.md Priority 4 recommendation
  - [ ] Update stage 6 to aggregate new task-executor return format
  - [ ] Implement progressive summarization: per-task summaries → wave summaries → batch summary
  - [ ] Return format: {total_tasks, completed, failed, blocked, wave_summaries: [{wave, tasks, summary}], overall_summary: "3-5 sentences"}
  - [ ] Add max 50 lines per 10 tasks validation
  - [ ] Update batch-task-orchestrator.md documentation with new return format
- **Timing**: 1 hour
- **Dependencies**: Phase 1 (must aggregate new task-executor format)
- **Validation**: Batch returns <50 lines per 10 tasks; progressive summarization applied; all tasks accounted for

### Phase 5: Differentiate Git Commit Patterns [NOT STARTED]

- **Goal**: Implement different commit patterns for simple (single commit) vs complex (commit per phase) tasks
- **Tasks**:
  - [ ] Read git-commits.md standards
  - [ ] Read research-001.md Priority 5 recommendation
  - [ ] Update task-executor to check complexity flag from /task command
  - [ ] Simple path: single commit after all changes (TODO update + implementation)
  - [ ] Complex path: commit per phase (research commit, plan commit, phase 1 commit, phase 2 commit, etc.)
  - [ ] Update commit message patterns: simple="Implement task NNN: {title}", complex="Complete phase N of task NNN: {phase_name}"
  - [ ] Only commit when phase produces artifacts (no empty commits)
  - [ ] Update task-executor.md and task.md documentation with commit patterns
- **Timing**: 45 minutes
- **Dependencies**: Phase 3 (requires complexity flag from router)
- **Validation**: Simple tasks produce 1 commit; complex tasks produce N commits (one per phase with artifacts); commit messages follow patterns

### Phase 6: Add Validation for Artifact-First Returns [NOT STARTED]

- **Goal**: Enforce return format compliance and summary requirements via validation layer
- **Tasks**:
  - [ ] Read research-001.md Priority 6 recommendation
  - [ ] Create validation function for task-executor return format
  - [ ] Validate required fields: task_number, status, artifacts, summary, key_metrics
  - [ ] Validate token count <500 for single task returns
  - [ ] Validate summary exists when detailed artifact created
  - [ ] Validate artifact paths are valid and files exist
  - [ ] Add validation to task-executor stage 10 before returning
  - [ ] Add validation to batch-task-orchestrator stage 6 before returning
  - [ ] Log validation failures with actionable error messages
  - [ ] Update documentation with validation requirements
- **Timing**: 45 minutes
- **Dependencies**: Phase 1 (return format), Phase 2 (summary requirements)
- **Validation**: All returns pass validation; validation errors logged with clear messages; no false positives

### Phase 7: Integration Testing [NOT STARTED]

- **Goal**: Validate all changes work together across single/batch and simple/complex execution paths
- **Tasks**:
  - [ ] Test scenario 1: Single simple task (no plan) → direct execution → single commit → brief summary
  - [ ] Test scenario 2: Single complex task (multi-phase plan) → research → plan → implement → commit per phase → structured summary
  - [ ] Test scenario 3: Batch of 10 tasks (mixed complexity) → wave execution → aggregated brief summaries
  - [ ] Test scenario 4: Task with existing plan link → reuse plan → update in place → phase-based commits
  - [ ] Test scenario 5: Task without plan link → direct execution → no plan creation → single commit
  - [ ] Test scenario 6: Error handling (failed task, blocked task, missing artifacts)
  - [ ] Measure context window usage: task-executor <500 tokens, batch <50 lines per 10 tasks
  - [ ] Verify backward compatibility with existing commands
  - [ ] Document test results and any issues found
- **Timing**: 1.5 hours
- **Dependencies**: Phases 1-6 (all changes must be complete)
- **Validation**: All test scenarios pass; context window targets met; no regressions; backward compatibility confirmed

### Phase 8: Documentation Updates [NOT STARTED]

- **Goal**: Update all affected documentation with new workflows, formats, and examples
- **Tasks**:
  - [ ] Update .opencode/command/task.md with complexity assessment stage and new workflow
  - [ ] Update .opencode/agent/subagents/task-executor.md with new return format and summary creation
  - [ ] Update .opencode/agent/subagents/batch-task-orchestrator.md with progressive summarization
  - [ ] Update .opencode/context/core/system/artifact-management.md with summary requirements and examples
  - [ ] Add examples to each file showing simple vs complex execution paths
  - [ ] Add troubleshooting section for common issues (validation failures, missing summaries, etc.)
  - [ ] Update TODO.md task 169 status to [COMPLETED]
  - [ ] Create migration guide for breaking changes (if any commands need updates)
- **Timing**: 1 hour
- **Dependencies**: Phase 7 (documentation reflects tested implementation)
- **Validation**: All documentation updated; examples accurate; migration guide complete; task 169 marked [COMPLETED]

## Testing & Validation

### Unit Tests
- [ ] Complexity scoring algorithm (7 indicators, thresholds)
- [ ] Return format validation (required fields, token limits)
- [ ] Summary artifact creation (templates, lazy directory creation)
- [ ] Git commit pattern selection (simple vs complex)

### Integration Tests
- [ ] Single simple task end-to-end (no plan path)
- [ ] Single complex task end-to-end (full plan path)
- [ ] Batch mixed complexity (10 tasks: 5 simple, 5 complex)
- [ ] Error scenarios (failed tasks, blocked tasks, missing artifacts)

### Context Window Measurements
- [ ] task-executor return: <500 tokens per task
- [ ] batch-task-orchestrator return: <50 lines per 10 tasks
- [ ] Summary artifacts: 3-5 sentences (50-100 tokens)

### Backward Compatibility
- [ ] Existing commands consuming task-executor still work
- [ ] Existing commands consuming batch-task-orchestrator still work
- [ ] Migration guide addresses any breaking changes

## Artifacts & Outputs

- **Plans**: .opencode/specs/169_task_command_improvements/plans/implementation-001.md (this file)
- **Summaries**: .opencode/specs/169_task_command_improvements/summaries/plan-summary.md
- **Updated Commands**: .opencode/command/task.md
- **Updated Agents**: 
  - .opencode/agent/subagents/task-executor.md
  - .opencode/agent/subagents/batch-task-orchestrator.md
- **Updated Standards**: .opencode/context/core/system/artifact-management.md
- **Test Results**: .opencode/specs/169_task_command_improvements/summaries/test-results.md (created during Phase 7)
- **Migration Guide**: .opencode/specs/169_task_command_improvements/summaries/migration-guide.md (if needed, created during Phase 8)

## Rollback/Contingency

If implementation causes critical issues:

1. **Immediate Rollback**: Revert commits in reverse order (Phase 8 → Phase 1)
2. **Partial Rollback**: Keep non-breaking changes (Phases 2, 3, 6), revert breaking changes (Phases 1, 4, 5)
3. **Backward Compatibility Layer**: If commands break, add compatibility shim to translate new format to old format
4. **Manual Override**: Add --legacy flag to /task command to use old return format temporarily
5. **Incremental Rollout**: Deploy to test tasks first, monitor for issues, then expand to production tasks

**Rollback Triggers**:
- Context window usage increases instead of decreases
- Validation failures exceed 10% of executions
- Critical commands break and cannot be quickly fixed
- Summary quality consistently poor (missing key information)
- Performance degradation >20% in task execution time

**Recovery Plan**:
- Restore previous versions of task.md, task-executor.md, batch-task-orchestrator.md from git
- Update TODO.md task 169 status to [BLOCKED] with rollback reason
- Create new task for addressing rollback issues
- Re-plan implementation with lessons learned
