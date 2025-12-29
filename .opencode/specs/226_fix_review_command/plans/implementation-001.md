# Implementation Plan: Fix /review Command Issues

- **Task**: 226 - Fix /review command to use next_project_number, create matching task, include actionable follow-up tasks in summary, reduce verbosity, and improve context file organization
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/226_fix_review_command/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/common/standards/plan.md
  - .opencode/context/common/system/status-markers.md
  - .opencode/context/common/system/artifact-management.md
  - .opencode/context/common/standards/tasks.md
  - .opencode/context/common/workflows/command-lifecycle.md
  - .opencode/context/common/standards/subagent-return-format.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

The /review command has 5 critical issues: (1) project numbering bug causing directory collisions, (2) missing TODO.md task creation for review projects, (3) follow-up tasks formatted as prose instead of actionable /task-ready format, (4) excessive verbosity bloating orchestrator context window, and (5) context file duplication. All issues stem from incomplete integration with command-lifecycle.md and status-sync-manager patterns. This plan implements fixes across 3 phases following existing architectural patterns with no breaking changes.

## Goals & Non-Goals

**Goals**:
- Fix project numbering to use next_project_number from state.json (no collisions)
- Create TODO.md task entry for review project with status [COMPLETED]
- Format follow-up tasks with actual task numbers and invocation instructions
- Reduce reviewer return verbosity from 280-580 tokens to <100 tokens
- Eliminate 60% context file duplication via reference pattern
- Maintain backward compatibility with existing review projects
- Follow command-lifecycle.md and status-sync-manager delegation patterns

**Non-Goals**:
- Change user-facing /review command syntax
- Modify registry update behavior
- Add new review features (metrics dashboard, scheduling)
- Migrate existing review projects (225_codebase_review remains as-is)

## Risks & Mitigations

- **Risk**: Project numbering fix breaks existing review projects. **Mitigation**: Only affects new reviews; existing projects remain accessible.
- **Risk**: Task creation fails if review task number already exists. **Mitigation**: Add collision detection and increment to next available number.
- **Risk**: Verbosity reduction loses important metrics. **Mitigation**: All metrics preserved in review summary artifact; only return format changes.
- **Risk**: Context file refactoring breaks /review execution. **Mitigation**: Validate all references resolve before deployment; test with actual /review.
- **Risk**: status-sync-manager delegation fails. **Mitigation**: Add validation and error handling with rollback.

## Implementation Phases

### Phase 1: Fix Project Numbering and Task Creation [COMPLETED]

- **Goal**: Ensure /review uses next_project_number from state.json and creates matching TODO.md task entry
- **Tasks**:
  - [ ] Read .opencode/command/review.md Stage 1 (lines 60-69)
  - [ ] Update Stage 1 to substitute next_project_number into project_path template
  - [ ] Add validation that next_project_number is positive integer
  - [ ] Add collision detection for existing project directories
  - [ ] Read .opencode/command/review.md Stage 7 (lines 309-360)
  - [ ] Update Stage 7 to create TODO.md task entry for review project
  - [ ] Format task entry: number matches project, status [COMPLETED], link to review summary
  - [ ] Update status-sync-manager delegation payload to include review_task_number
  - [ ] Test: Run /review and verify project directory uses next_project_number
  - [ ] Test: Verify TODO.md contains review task entry with correct number and status
  - [ ] Test: Verify state.json increments next_project_number
  - [ ] Test: Verify no directory number collisions
- **Timing**: 4 hours
- **Files Modified**:
  - .opencode/command/review.md (Stage 1, Stage 7)

### Phase 2: Fix Summary Formatting and Verbosity [COMPLETED]

- **Goal**: Format follow-up tasks with actual task numbers and reduce reviewer return to <100 tokens
- **Tasks**:
  - [ ] Read .opencode/agent/subagents/reviewer.md Step 4 (lines 123-157)
  - [ ] Update Step 4 to create review summary with placeholder task numbers (TBD-1, TBD-2)
  - [ ] Read .opencode/agent/subagents/reviewer.md Step 5 (lines 160-240)
  - [ ] Remove verbose metrics object from return format
  - [ ] Remove verbose identified_tasks array from return format
  - [ ] Add brief metrics_summary to metadata field (<20 tokens)
  - [ ] Verify return format follows subagent-return-format.md (<100 tokens)
  - [ ] Read .opencode/command/review.md Stage 6 (CreateTasks)
  - [ ] Update Stage 6 to read identified_tasks from review summary artifact (not return object)
  - [ ] Update Stage 6 to create tasks and collect actual task numbers
  - [ ] Read .opencode/command/review.md Stage 7 (Postflight)
  - [ ] Update Stage 7 to replace placeholder task numbers in review summary with actual numbers
  - [ ] Add invocation instructions for each follow-up task
  - [ ] Test: Verify review summary contains actual task numbers (e.g., "Task 227")
  - [ ] Test: Verify review summary includes invocation instructions
  - [ ] Test: Verify reviewer return <100 tokens
  - [ ] Test: Verify /review can read identified_tasks from artifact
- **Timing**: 2 hours
- **Files Modified**:
  - .opencode/agent/subagents/reviewer.md (Step 4, Step 5)
  - .opencode/command/review.md (Stage 6, Stage 7)

### Phase 3: Context File Organization Cleanup [COMPLETED]

- **Goal**: Eliminate 60% duplication in review.md via reference pattern
- **Tasks**:
  - [ ] Read .opencode/context/common/workflows/review.md (287 lines)
  - [ ] Identify duplicated sections (workflow stages, artifact management, validation)
  - [ ] Refactor Workflow Stages section to reference command-lifecycle.md
  - [ ] Preserve reviewer-specific adaptations (8 stage customizations)
  - [ ] Refactor Artifact Management section to reference artifact-management.md
  - [ ] Preserve review-specific artifacts (project directory, summary, registries)
  - [ ] Preserve unique content (Review Checklist, Report Format, Common Issues, Best Practices)
  - [ ] Validate all references resolve to existing files
  - [ ] Verify review.md reduced from 287 lines to ~150 lines (47% reduction)
  - [ ] Test: Run /review and verify command still works
  - [ ] Test: Verify all references load correctly
  - [ ] Test: Verify no functionality lost
- **Timing**: 2 hours
- **Files Modified**:
  - .opencode/context/common/workflows/review.md

## Testing & Validation

**Unit Tests** (per phase):
- [ ] Phase 1: Verify /review uses next_project_number from state.json
- [ ] Phase 1: Verify /review creates TODO.md task for review project
- [ ] Phase 2: Verify review summary contains actual task numbers
- [ ] Phase 2: Verify reviewer return <100 tokens
- [ ] Phase 3: Verify review.md references resolve correctly

**Integration Tests**:
- [ ] Run /review on test repository
- [ ] Verify project directory created with correct number (next_project_number)
- [ ] Verify TODO.md contains review task entry (status: [COMPLETED])
- [ ] Verify TODO.md contains follow-up tasks with actual numbers
- [ ] Verify review summary contains actual task numbers with invocation instructions
- [ ] Verify orchestrator receives <100 token return
- [ ] Verify all registries updated correctly
- [ ] Verify git commit created with all changes
- [ ] Verify state.json incremented next_project_number

**Regression Tests**:
- [ ] Verify existing review projects still accessible (225_codebase_review)
- [ ] Verify review summary format backward compatible
- [ ] Verify registry update behavior unchanged
- [ ] Verify no breaking changes to /review command syntax

**Validation Criteria**:
- [ ] No directory number collisions
- [ ] Review task number matches project number
- [ ] Follow-up tasks have sequential numbers
- [ ] All task numbers exist in TODO.md
- [ ] Reviewer return <100 tokens (95% verbosity reduction)
- [ ] review.md size reduced by 47% (287 → 150 lines)
- [ ] Duplication reduced by 85% (343 → 50 lines)

## Artifacts & Outputs

**Modified Files**:
- .opencode/command/review.md (Stage 1, Stage 6, Stage 7)
- .opencode/agent/subagents/reviewer.md (Step 4, Step 5)
- .opencode/context/common/workflows/review.md (refactored)

**Created Artifacts**:
- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)

**Test Artifacts**:
- Test review project directory (e.g., 227_codebase_review)
- Test review summary with actual task numbers
- Test TODO.md entries (review task + follow-up tasks)

## Rollback/Contingency

**If Phase 1 fails** (project numbering):
- Revert .opencode/command/review.md Stage 1 and Stage 7 changes
- Delete test review project directory if created
- Remove test TODO.md task entries
- Revert state.json next_project_number if incremented

**If Phase 2 fails** (summary formatting):
- Revert .opencode/agent/subagents/reviewer.md Step 4 and Step 5 changes
- Revert .opencode/command/review.md Stage 6 and Stage 7 changes
- Review summary will have placeholder task numbers (degraded but functional)
- Reviewer return will be verbose (degraded but functional)

**If Phase 3 fails** (context file organization):
- Revert .opencode/context/common/workflows/review.md to original
- /review command will work with duplicated content (degraded but functional)
- Context window will be larger but no functionality lost

**General Rollback**:
- All changes are to markdown specification files (no code changes)
- Git revert to commit before implementation
- No data loss (existing review projects unaffected)
- No breaking changes (backward compatible)

**Contingency Plan**:
- If collision detection fails: Manually increment next_project_number in state.json
- If task creation fails: Manually create TODO.md task entry
- If summary update fails: Manually update review summary with task numbers
- If verbosity reduction breaks orchestrator: Revert to verbose return format
- If context file refactoring breaks /review: Revert to original review.md

## Success Criteria

- [ ] /review creates project directory using next_project_number from state.json
- [ ] No directory number collisions occur
- [ ] TODO.md contains review task entry with matching project number
- [ ] Review task has status [COMPLETED] with completion timestamp
- [ ] Review task links to review summary artifact
- [ ] Review summary contains actual task numbers (not placeholders)
- [ ] Review summary includes invocation instructions for each follow-up task
- [ ] Reviewer return <100 tokens (95% verbosity reduction from 280-580 tokens)
- [ ] All metrics and identified_tasks preserved in review summary artifact
- [ ] review.md reduced from 287 lines to ~150 lines (47% reduction)
- [ ] Duplication reduced from 343 lines to ~50 lines (85% reduction)
- [ ] All references in review.md resolve to existing files
- [ ] /review command functionality unchanged (backward compatible)
- [ ] All integration tests pass
- [ ] No regression in existing review projects
