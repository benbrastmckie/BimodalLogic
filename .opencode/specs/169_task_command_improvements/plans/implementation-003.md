# Implementation Plan: /implement Command Context Window Protection (v3 - Refined Clean Break)

- **Task**: 169 - Improve /implement command to protect primary agent context window
- **Status**: [NOT STARTED]
- **Version**: 3 (Revision)
- **Previous Version**: implementation-002.md
- **Revision Date**: 2025-12-24
- **Effort**: 8-9 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/169_task_command_improvements/reports/research-001.md (820 lines)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/system/git-commits.md
- **Language**: markdown
- **Lean Intent**: false

## Revision Summary

**Changes from v2 to v3**:
- **RENAMED**: All references from `/task` to `/implement` throughout plan
- **ENHANCED**: Phase 0 audit now explicitly includes /implement command and all command references
- **CLARIFIED**: Atomic deployment coordination strategy with explicit sequencing requirements
- **IMPROVED**: Validation criteria now include specific token count measurements and format compliance checks
- **ENHANCED**: Rollback procedures with detailed trigger conditions and recovery steps
- **CLARIFIED**: Testing scenarios now explicitly reference /implement command execution paths
- **ADDED**: Explicit validation that artifact paths and naming conventions remain consistent despite command rename
- **IMPROVED**: Documentation update requirements to ensure all /task → /implement references are updated
- **PRESERVED**: Clean-break approach, 8-phase structure, artifact-first returns, summary enforcement, complexity router, git commit differentiation

**Rationale**: The /task → /implement rename requires comprehensive updates across all consuming commands, documentation, and examples. This revision ensures the rename is handled atomically with all other improvements, maintaining the clean-break approach while adding clarity on coordination requirements and validation criteria.

## Overview

The /implement command (formerly /task) and its subagents (task-executor, batch-task-orchestrator) currently return verbose execution details (100+ lines per task) instead of artifact references and brief summaries, causing context window bloat in the primary agent. This plan implements artifact-first returns with progressive summarization, differentiates simple (direct execution) vs complex (plan-based) task paths, and enforces appropriate git commit patterns. **Version 3 incorporates the /task → /implement rename** and uses a clean-break approach: all consuming commands are audited and updated upfront, then breaking changes are deployed atomically without backward compatibility layers. Success is defined as: single task returns <500 tokens, batch returns <50 lines per 10 tasks, all subagents create summary artifacts per artifact-management.md, zero legacy compatibility code, and all command references updated to /implement.

## Goals & Non-Goals

**Goals**:
- Rename /task command to /implement across all files, documentation, and examples
- Implement artifact-first return format for task-executor (artifact references + 3-5 sentence summaries + key metrics)
- Enforce summary artifact creation for all detailed artifacts (research, plans, implementations)
- Add complexity assessment to /implement command for routing differentiation
- Update batch-task-orchestrator to aggregate brief summaries (progressive summarization)
- Differentiate git commit patterns: simple tasks (single commit), complex tasks (commit per phase)
- Add validation layer to enforce return format compliance and summary requirements
- Achieve context window protection targets: <500 tokens per task, <50 lines per 10-task batch
- **Clean-break deployment**: audit all consumers upfront, update in parallel, deploy atomically without backward compatibility

**Non-Goals**:
- Changing task-executor's internal workflow or coordinator routing logic
- Modifying existing plan/research/implementation formats (only adding summaries)
- Implementing new complexity scoring algorithms (use research-001.md 7-factor scoring)
- Changing TODO.md task metadata structure
- Modifying status-sync-manager or batch-status-manager internals
- **Maintaining backward compatibility** with old return formats (clean break)
- **Gradual migration** or transition periods (atomic deployment)
- Changing artifact directory structure or naming conventions (only command name changes)

## Risks & Mitigations

- **Risk**: Breaking changes deployed atomically may cause runtime failures if any consumer is missed during audit.
  - **Mitigation**: Comprehensive upfront audit of all .opencode/command/*.md and .opencode/agent/subagents/*.md files; grep for "task-executor", "batch-task-orchestrator", and "/task" references; manual review of routing logic; test all identified consumers before deployment; maintain rollback-ready git state.

- **Risk**: /task → /implement rename may miss references in documentation, examples, or error messages.
  - **Mitigation**: Comprehensive grep for all "/task", "task command", and related references; update all documentation files; update all example files; update all error messages; validate no broken links or references remain.

- **Risk**: Summary quality variance may miss important details or be too generic.
  - **Mitigation**: Provide clear templates (Appendix C in research-001.md); include examples; add quality validation checks; allow manual refinement.

- **Risk**: Complexity assessment may misclassify tasks (simple as complex or vice versa).
  - **Mitigation**: Use robust 7-indicator scoring (research-001.md Appendix B); allow manual override flags (--simple, --complex); monitor and tune thresholds.

- **Risk**: Phase-based commits for complex tasks may create too many small commits.
  - **Mitigation**: Only commit when phase produces artifacts; allow squashing during review; document commit patterns in git-commits.md.

- **Risk**: Coordinated atomic changes across 20+ files may have sequencing issues or intermediate broken states.
  - **Mitigation**: Define strict dependency order (Phase 0 → 1a → 1b → 1c); test each phase independently; use feature branch for all changes; single merge commit to main; comprehensive integration testing before merge.

- **Risk**: Integration testing may reveal unforeseen edge cases or workflow breaks.
  - **Mitigation**: Comprehensive test scenarios (single simple, single complex, batch mixed, error cases); test on feature branch; rollback plan ready; incremental validation at each phase.

## Implementation Phases

### Phase 0: Audit All Consuming Commands and /task References [NOT STARTED]

- **Goal**: Identify all commands, agents, and documentation that reference /task or consume task-executor/batch-task-orchestrator return formats
- **Tasks**:
  - [ ] Grep .opencode/command/*.md for "/task", "task-executor", and "batch-task-orchestrator" references
  - [ ] Grep .opencode/agent/subagents/*.md for same references
  - [ ] Grep Documentation/ for "/task" and "task command" references
  - [ ] Grep all .md files for "/task" references (including examples, standards, guides)
  - [ ] Read identified files to determine if they consume return formats or just route to subagents
  - [ ] Document current return format contracts (what fields are consumed, how they're used)
  - [ ] Create audit report: consumers.md listing all files, consumption patterns, required updates
  - [ ] Identify any hidden dependencies (e.g., commands that route through intermediaries)
  - [ ] Verify no external integrations consume these formats
  - [ ] Document all /task → /implement rename locations
- **Timing**: 1.5 hours (increased from 1 hour due to rename audit)
- **Dependencies**: None
- **Validation**: All consumers identified; consumption patterns documented; no hidden dependencies; audit report complete; all /task references catalogued

### Phase 1a: Define New Return Format Schemas [NOT STARTED]

- **Goal**: Create clear contract specifications for new return formats before implementation
- **Tasks**:
  - [ ] Document new task-executor return format schema (JSON structure, field types, constraints)
  - [ ] Document new batch-task-orchestrator return format schema
  - [ ] Create summary templates from research-001.md Appendix C
  - [ ] Define validation rules (token limits, required fields, forbidden fields)
  - [ ] Add schemas to artifact-management.md or create separate schema documentation
  - [ ] Include examples of compliant and non-compliant returns
  - [ ] Document token counting methodology (how to measure <500 tokens)
  - [ ] Define line counting methodology for batch returns (<50 lines per 10 tasks)
- **Timing**: 45 minutes (increased from 30 minutes for validation methodology)
- **Dependencies**: Phase 0 (audit informs schema design)
- **Validation**: Schemas documented; templates created; validation rules defined; examples provided; measurement methodologies clear

### Phase 1b: Update All Consuming Commands and /task References [NOT STARTED]

- **Goal**: Update all identified consumers to expect new return formats and rename /task to /implement before breaking changes are deployed
- **Tasks**:
  - [ ] Rename .opencode/command/task.md to .opencode/command/implement.md
  - [ ] Update implement.md header and all internal references from /task to /implement
  - [ ] For each consumer identified in Phase 0 audit:
    - [ ] Update to consume new task-executor format (if applicable)
    - [ ] Update to consume new batch-task-orchestrator format (if applicable)
    - [ ] Remove dependencies on removed fields (coordinator_results, workflow_executed, todo_status_tracking)
    - [ ] Add handling for new fields (summary, key_metrics, artifacts array)
    - [ ] Update all /task references to /implement
  - [ ] Update .opencode/command/optimize.md batch coordination (if needed)
  - [ ] Update all documentation files with /task → /implement rename
  - [ ] Update all example files with /task → /implement rename
  - [ ] Update all error messages and user-facing text
  - [ ] Test each updated consumer independently (dry-run with mock new format)
  - [ ] Document changes in migration notes
- **Timing**: 2 hours (increased from 1.5 hours due to rename work)
- **Dependencies**: Phase 1a (consumers need schema to update against)
- **Validation**: All consumers updated; no references to removed fields; all /task references renamed to /implement; dry-run tests pass; migration notes complete; no broken links

### Phase 1c: Implement New task-executor Return Format [NOT STARTED]

- **Goal**: Replace verbose return format with artifact-first returns (references + brief summaries + metrics)
- **Tasks**:
  - [ ] Read current task-executor.md stage 10 ReturnToOrchestrator (lines 559-706)
  - [ ] Update stage 10 to return: {task_number, status, artifacts: [{type, path}], summary: "3-5 sentences", key_metrics: {complexity, effort, files_modified}}
  - [ ] Remove verbose fields: coordinator_results, workflow_executed, todo_status_tracking details
  - [ ] Add max 500 token limit validation with explicit token counting
  - [ ] Update task-executor.md documentation with new return format and examples
  - [ ] Update all internal /task references to /implement in task-executor.md
  - [ ] Test return format with sample task execution
  - [ ] Measure actual token counts for sample returns
- **Timing**: 1 hour
- **Dependencies**: Phase 1b (consumers must be ready before producers change)
- **Validation**: Return format matches schema; token count <500 verified by measurement; all required fields present; removed fields absent; /implement terminology used

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
  - [ ] Verify summary templates reference /implement (not /task) where applicable
- **Timing**: 45 minutes
- **Dependencies**: Phase 1c (return format must reference summary artifacts)
- **Validation**: Summary artifacts created for all detailed artifacts; summaries/ created lazily; summaries follow templates; /implement terminology used

### Phase 3: Implement Complexity Router in /implement Command [NOT STARTED]

- **Goal**: Add complexity assessment stage to /implement command for routing differentiation
- **Tasks**:
  - [ ] Read research-001.md Appendix B complexity scoring algorithm (7 indicators)
  - [ ] Read current implement.md workflow stages 1-4
  - [ ] Add new stage 2.5 AssessComplexity between ResolveTasks and Execute
  - [ ] Implement 7-factor scoring: effort, files, LOC, dependencies, research, unknowns, risk (0-2 each)
  - [ ] Set thresholds: 0-4=simple, 5-9=moderate, 10-14=complex
  - [ ] Pass complexity flag to task-executor for execution path differentiation
  - [ ] Add manual override flags: --simple, --complex
  - [ ] Update implement.md documentation with complexity assessment workflow
  - [ ] Ensure all documentation uses /implement terminology
- **Timing**: 1 hour
- **Dependencies**: None (independent of return format changes)
- **Validation**: Complexity scores calculated correctly; thresholds applied; flags passed to executor; /implement terminology used

### Phase 4: Update batch-task-orchestrator Return Format [NOT STARTED]

- **Goal**: Implement progressive summarization for batch execution (aggregate brief summaries)
- **Tasks**:
  - [ ] Read current batch-task-orchestrator.md stage 6 ReturnResults (lines 341-400)
  - [ ] Read research-001.md Priority 4 recommendation
  - [ ] Update stage 6 to aggregate new task-executor return format
  - [ ] Implement progressive summarization: per-task summaries → wave summaries → batch summary
  - [ ] Return format: {total_tasks, completed, failed, blocked, task_summaries: [{task_number, status, summary, artifacts}], failed_tasks: [{task_number, error, recommendation}], next_steps: "brief"}
  - [ ] Add max 50 lines per 10 tasks validation with explicit line counting
  - [ ] Update batch-task-orchestrator.md documentation with new return format
  - [ ] Update all /task references to /implement in batch-task-orchestrator.md
  - [ ] Test batch returns with sample 10-task execution
  - [ ] Measure actual line counts for sample batch returns
- **Timing**: 1 hour
- **Dependencies**: Phase 1c (must aggregate new task-executor format)
- **Validation**: Batch returns <50 lines per 10 tasks verified by measurement; progressive summarization applied; all tasks accounted for; /implement terminology used

### Phase 5: Differentiate Git Commit Patterns [NOT STARTED]

- **Goal**: Implement different commit patterns for simple (single commit) vs complex (commit per phase) tasks
- **Tasks**:
  - [ ] Read git-commits.md standards
  - [ ] Read research-001.md Priority 5 recommendation
  - [ ] Update task-executor to check complexity flag from /implement command
  - [ ] Simple path: single commit after all changes (TODO update + implementation)
  - [ ] Complex path: commit per phase (research commit, plan commit, phase 1 commit, phase 2 commit, etc.)
  - [ ] Update commit message patterns: simple="Implement task NNN: {title}", complex="Complete phase N of task NNN: {phase_name}"
  - [ ] Only commit when phase produces artifacts (no empty commits)
  - [ ] Update task-executor.md and implement.md documentation with commit patterns
  - [ ] Ensure commit messages reference /implement workflow (not /task)
- **Timing**: 45 minutes
- **Dependencies**: Phase 3 (requires complexity flag from router)
- **Validation**: Simple tasks produce 1 commit; complex tasks produce N commits (one per phase with artifacts); commit messages follow patterns; /implement terminology used

### Phase 6: Add Validation for Artifact-First Returns [NOT STARTED]

- **Goal**: Enforce return format compliance and summary requirements via validation layer
- **Tasks**:
  - [ ] Read research-001.md Priority 6 recommendation
  - [ ] Create validation function for task-executor return format
  - [ ] Validate required fields: task_number, status, artifacts, summary, key_metrics
  - [ ] Validate token count <500 for single task returns (with actual token counting)
  - [ ] Validate line count <50 per 10 tasks for batch returns (with actual line counting)
  - [ ] Validate summary exists when detailed artifact created
  - [ ] Validate artifact paths are valid and files exist
  - [ ] Add validation to task-executor stage 10 before returning
  - [ ] Add validation to batch-task-orchestrator stage 6 before returning
  - [ ] Log validation failures with actionable error messages
  - [ ] Update documentation with validation requirements
  - [ ] Ensure validation error messages use /implement terminology
- **Timing**: 1 hour (increased from 45 minutes for measurement validation)
- **Dependencies**: Phase 1c (return format), Phase 2 (summary requirements)
- **Validation**: All returns pass validation; validation errors logged with clear messages; no false positives; token/line counts measured accurately; /implement terminology used

### Phase 7: Integration Testing [NOT STARTED]

- **Goal**: Validate all changes work together across single/batch and simple/complex execution paths with /implement command
- **Tasks**:
  - [ ] Test scenario 1: Single simple task via /implement (no plan) → direct execution → single commit → brief summary
  - [ ] Test scenario 2: Single complex task via /implement (multi-phase plan) → research → plan → implement → commit per phase → structured summary
  - [ ] Test scenario 3: Batch of 10 tasks via /implement (mixed complexity) → wave execution → aggregated brief summaries
  - [ ] Test scenario 4: Task with existing plan link via /implement → reuse plan → update in place → phase-based commits
  - [ ] Test scenario 5: Task without plan link via /implement → direct execution → no plan creation → single commit
  - [ ] Test scenario 6: Error handling (failed task, blocked task, missing artifacts)
  - [ ] Test scenario 7: All updated consuming commands work with new formats
  - [ ] Test scenario 8: All /task → /implement renames work correctly (no broken references)
  - [ ] Measure context window usage: task-executor <500 tokens, batch <50 lines per 10 tasks
  - [ ] Verify no regressions in task execution workflows
  - [ ] Verify all user-facing messages use /implement terminology
  - [ ] Document test results and any issues found
- **Timing**: 2 hours (increased from 1.5 hours for rename testing)
- **Dependencies**: Phases 1-6 (all changes must be complete)
- **Validation**: All test scenarios pass; context window targets met; no regressions; all consumers work correctly; all /implement references correct; no /task references remain

### Phase 8: Documentation Updates [NOT STARTED]

- **Goal**: Update all affected documentation with new workflows, formats, examples, and /implement terminology
- **Tasks**:
  - [ ] Update .opencode/command/implement.md with complexity assessment stage and new workflow
  - [ ] Update .opencode/agent/subagents/task-executor.md with new return format and summary creation
  - [ ] Update .opencode/agent/subagents/batch-task-orchestrator.md with progressive summarization
  - [ ] Update .opencode/context/common/system/artifact-management.md with summary requirements and examples
  - [ ] Update all consuming commands identified in Phase 0 with new format documentation
  - [ ] Update all user guides and tutorials with /implement command (replace /task)
  - [ ] Update all examples showing /implement usage (replace /task)
  - [ ] Add examples to each file showing simple vs complex execution paths
  - [ ] Add troubleshooting section for common issues (validation failures, missing summaries, etc.)
  - [ ] Create migration guide documenting breaking changes, clean-break approach, and /task → /implement rename
  - [ ] Update TODO.md task 169 status to [COMPLETED]
  - [ ] Verify no /task references remain in documentation
- **Timing**: 1.5 hours (increased from 1 hour for rename documentation)
- **Dependencies**: Phase 7 (documentation reflects tested implementation)
- **Validation**: All documentation updated; examples accurate; migration guide complete; task 169 marked [COMPLETED]; all /task references replaced with /implement; no broken links

## Testing & Validation

### Unit Tests
- [ ] Complexity scoring algorithm (7 indicators, thresholds)
- [ ] Return format validation (required fields, token limits with measurement)
- [ ] Summary artifact creation (templates, lazy directory creation)
- [ ] Git commit pattern selection (simple vs complex)
- [ ] Token counting accuracy (verify <500 token limit)
- [ ] Line counting accuracy (verify <50 lines per 10 tasks)

### Integration Tests
- [ ] Single simple task end-to-end via /implement (no plan path)
- [ ] Single complex task end-to-end via /implement (full plan path)
- [ ] Batch mixed complexity via /implement (10 tasks: 5 simple, 5 complex)
- [ ] Error scenarios (failed tasks, blocked tasks, missing artifacts)
- [ ] All consuming commands with new return formats
- [ ] All /task → /implement renames functional

### Context Window Measurements
- [ ] task-executor return: <500 tokens per task (measured, not estimated)
- [ ] batch-task-orchestrator return: <50 lines per 10 tasks (measured, not estimated)
- [ ] Summary artifacts: 3-5 sentences (50-100 tokens)
- [ ] Measurement methodology documented and repeatable

### Clean-Break Validation
- [ ] No backward compatibility code present
- [ ] All consumers updated and tested
- [ ] No references to removed fields (coordinator_results, workflow_executed, todo_status_tracking)
- [ ] Migration guide documents breaking changes
- [ ] Rollback plan tested and ready
- [ ] All /task references replaced with /implement
- [ ] No broken links or references

## Artifacts & Outputs

- **Plans**: .opencode/specs/169_task_command_improvements/plans/implementation-003.md (this file)
- **Summaries**: .opencode/specs/169_task_command_improvements/summaries/plan-summary-v3.md
- **Audit Report**: .opencode/specs/169_task_command_improvements/summaries/consumers-audit.md (created during Phase 0)
- **Rename Audit**: .opencode/specs/169_task_command_improvements/summaries/rename-audit.md (created during Phase 0)
- **Updated Commands**: 
  - .opencode/command/implement.md (renamed from task.md)
  - .opencode/command/optimize.md (if needed)
- **Updated Agents**: 
  - .opencode/agent/subagents/task-executor.md
  - .opencode/agent/subagents/batch-task-orchestrator.md
- **Updated Standards**: .opencode/context/common/system/artifact-management.md
- **Test Results**: .opencode/specs/169_task_command_improvements/summaries/test-results-v3.md (created during Phase 7)
- **Migration Guide**: .opencode/specs/169_task_command_improvements/summaries/migration-guide-v3.md (created during Phase 8)

## Rollback/Contingency

If implementation causes critical issues:

1. **Immediate Rollback**: Revert feature branch commits in reverse order (Phase 8 → Phase 0)
2. **Partial Rollback**: Not applicable for clean-break approach - must rollback all or nothing
3. **No Backward Compatibility Layer**: Clean-break means no compatibility shims available
4. **Rollback Triggers**:
   - Context window usage increases instead of decreases
   - Validation failures exceed 10% of executions
   - Critical commands break and cannot be quickly fixed
   - Summary quality consistently poor (missing key information)
   - Performance degradation >20% in task execution time
   - Any consuming command fails at runtime
   - Broken /implement command references or routing
   - User confusion from incomplete /task → /implement rename

**Recovery Plan**:
- Restore previous versions of all modified files from git (feature branch revert)
- Restore task.md from implement.md rename
- Update TODO.md task 169 status to [BLOCKED] with rollback reason
- Create new task for addressing rollback issues
- Re-plan implementation with lessons learned
- Consider phased approach with deprecation warnings instead of clean break

**Rollback Readiness**:
- All changes on feature branch (not merged to main until Phase 7 complete)
- Git tags at each phase boundary for granular rollback
- Comprehensive test suite to validate rollback success
- Documentation of pre-change state for reference
- Backup of task.md before rename to implement.md

## Clean-Break Approach Details

### Rationale
- **Eliminates technical debt**: No backward compatibility code to maintain long-term
- **Cleaner architecture**: Single return format, no dual-format handling, no transition logic
- **Simpler codebase**: Fewer conditionals, clearer contracts, easier to understand
- **Better long-term maintainability**: No legacy support burden, no deprecation cycles
- **Cleaner rename**: /task → /implement done atomically without transition period

### Trade-offs
- **Higher upfront risk**: All changes must be coordinated perfectly
- **Increased coordination complexity**: 20+ files must align atomically
- **No gradual migration**: Cannot validate incrementally in production
- **All-or-nothing deployment**: Single merge commit, no partial rollout
- **Rename risk**: All /task references must be found and updated

### Success Criteria
- Zero backward compatibility code in final implementation
- All consuming commands updated and tested before breaking changes deployed
- Single atomic merge commit to main (or coordinated commits in same session)
- Comprehensive migration guide for future command development
- No runtime failures from missed consumers
- Context window targets achieved: <500 tokens per task, <50 lines per 10 tasks
- All /task references replaced with /implement
- No broken links or command routing issues

### Coordination Strategy
1. **Feature Branch**: All work on dedicated branch until Phase 7 complete
2. **Phase Boundaries**: Git tag at each phase for rollback points
3. **Dependency Order**: Strict sequencing (Phase 0 → 1a → 1b → 1c → 2-6 → 7 → 8)
4. **Testing Gates**: Each phase must pass validation before proceeding
5. **Atomic Merge**: Single merge commit to main after Phase 7 passes all tests
6. **Rollback Ready**: Maintain clean main branch state for instant revert if needed
7. **Rename Coordination**: All /task → /implement changes in Phase 1b before format changes

## /task → /implement Rename Details

### Scope of Rename
- **Command File**: .opencode/command/task.md → .opencode/command/implement.md
- **Command Invocation**: `/task` → `/implement` in all documentation and examples
- **Internal References**: All mentions of "task command" → "implement command"
- **User-Facing Text**: All error messages, help text, prompts
- **Documentation**: All guides, tutorials, standards, examples
- **Subagent References**: task-executor and batch-task-orchestrator documentation

### Files Requiring Updates
- .opencode/command/implement.md (renamed from task.md)
- .opencode/agent/subagents/task-executor.md
- .opencode/agent/subagents/batch-task-orchestrator.md
- All consuming commands identified in Phase 0
- Documentation/UserGuide/*.md
- All example files
- All standards files referencing /task
- Error messages and user prompts

### Validation Criteria
- No remaining /task references in active files
- All /implement references functional
- No broken command routing
- No broken documentation links
- User-facing messages consistent with /implement terminology
- Migration guide explains rename clearly

### Backward Compatibility Note
**No backward compatibility**: The /task command will not be preserved as an alias. Users must use /implement after this change. This is consistent with the clean-break approach and eliminates confusion from dual command names.
