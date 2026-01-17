# Implementation Plan: Add Missing Stage 7 (Postflight) Validation in Workflow Commands

- **Task**: 519 - Add missing Stage 7 validation in workflow commands  
- **Status**: [NOT STARTED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: []
- **Research Inputs**: Analysis of `.opencode/command/*.md` files revealing missing postflight validation checkpoints
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/command/review.md (updated with Stage 3.6)
  - .opencode/command/task.md (updated with Stage 3)
  - .opencode/command/todo.md (updated with Stage 3.5)
  - .opencode/context/core/standards/validation-checkpoints.md (updated with standard pattern)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/workflows/command-lifecycle.md
  - .opencode/context/core/standards/validation-checkpoints.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Add missing Stage 7 (Postflight) validation checkpoints in core workflow commands (`review.md`, `task.md`, `todo.md`). Research revealed that while core commands (`research`, `plan`, `implement`, `revise`) have robust postflight validation, several commands modify project state without ensuring git commits or verifying effects, leading to potential data loss and inconsistent state.

## Research-Based Improvements

Based on the detailed analysis in `research-001.md`, this plan has been improved from the original meta-workflow focus to address the actual critical gaps:

**Original Plan Issues Fixed**:
- ❌ Focused on meta subagents (already have validation) → ✅ Focus on core commands (missing validation)
- ❌ Targeted 6 workflow commands → ✅ Target 3 critical commands that need fixing
- ❌ Generic "add validation" approach → ✅ Specific fixes for each command's unique gap

**Critical Issues Being Fixed**:
1. **review.md**: Creates tasks but doesn't commit them (CRITICAL - potential data loss)
2. **task.md**: Reports success without verifying file changes (HIGH - phantom success)
3. **todo.md**: Reports archival without verifying file moves (MEDIUM - incomplete operations)

**Deferred Issues** (per research recommendation):
- `meta.md` structural refactoring (requires separate task)
- Commands already compliant (`research`, `plan`, `implement`, `revise`)
- Read-only commands (`errors.md`)

## Goals & Non-Goals

**Goals**:
- Fix critical postflight validation gap in `review.md` (creates tasks without git commit)
- Add effect verification to `task.md` (validates file system changes)
- Add archival verification to `todo.md` (verifies file moves and status updates)
- Implement standardized postflight validation pattern across all commands
- Ensure all state-modifying commands create git commits for persistence

**Non-Goals**:
- Modifying commands that already have proper postflight validation (`research`, `plan`, `implement`, `revise`)
- Changing `errors.md` (read-only, no validation needed)
- Refactoring `meta.md` (deferred to separate task due to structural changes)
- Adding validation to non-workflow commands

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Review creates tasks but commit fails, causing "phantom" tasks | Validate commit success, return error with clear recovery steps |
| Task command reports success but no files changed | Verify actual file system changes before returning success |
| Todo command reports archival but files remain | Verify file moves and TODO.md updates before returning success |
| Breaking existing user workflows | Implement validation incrementally, test thoroughly before deployment |

## Implementation Phases

### Phase 1: Define Standard Postflight Pattern [NOT STARTED]
- **Goal**: Document the standardized postflight validation pattern based on existing compliant commands
- **Tasks**:
  - [ ] Analyze existing postflight pattern in `research.md`, `plan.md`, `implement.md`, `revise.md`
  - [ ] Extract the standardized pattern from Stage 3.5 of compliant commands
  - [ ] Document standard pattern in `validation-checkpoints.md`
  - [ ] Include: artifact validation, status verification, git commit creation, success validation
- **Timing**: 30 minutes

### Phase 2: Fix review.md Postflight Validation (CRITICAL) [NOT STARTED]
- **Goal**: Add Stage 3.6 (Postflight) to prevent phantom task creation
- **Tasks**:
  - [ ] Add Stage 3.6 "Postflight" after current Stage 3.5 (CreateTasks)
  - [ ] Verify `TODO.md` and `state.json` were actually updated with new tasks
  - [ ] Count number of tasks created for commit message
  - [ ] Invoke `git-workflow-manager` to commit changes: "review: created N tasks"
  - [ ] Validate git commit success with hash verification
  - [ ] If commit fails: return error with recovery instructions
- **Timing**: 30 minutes

### Phase 3: Fix task.md Postflight Validation (HIGH) [NOT STARTED]
- **Goal**: Add Stage 3 (Postflight) to verify actual file system effects
- **Tasks**:
  - [ ] Rename current Stage 3 to Stage 4 (Final)
  - [ ] Insert new Stage 3 "Postflight" between delegation and result return
  - [ ] Verify `TODO.md` timestamp/content actually changed
  - [ ] Verify `state.json` was updated with new timestamps
  - [ ] If subagent reported git commit: verify commit hash exists
  - [ ] Return failed status if file system unchanged despite success report
- **Timing**: 30 minutes

### Phase 4: Fix todo.md Postflight Validation (MEDIUM) [NOT STARTED]
- **Goal**: Add Stage 3.5 (Postflight) to verify archival actually occurred
- **Tasks**:
  - [ ] Add Stage 3.5 "Postflight" after current Stage 3 (Archive)
  - [ ] Verify project directories were actually moved to `archive/`
  - [ ] Verify tasks are marked `[ABANDONED]` or `[COMPLETED]` in `TODO.md`
  - [ ] If subagent reported git commit: verify commit exists and contains changes
  - [ ] Return warning if some archival actions failed but partial success occurred
- **Timing**: 30 minutes

### Phase 5: Test All Fixed Commands [NOT STARTED]
- **Goal**: Verify validation works correctly and doesn't break existing workflows
- **Tasks**:
  - [ ] Test review command: create mock review, verify tasks and commit created
  - [ ] Test task command: create task, verify TODO.md and state.json updated
  - [ ] Test todo command: archive test project, verify files moved and status updated
  - [ ] Test failure scenarios: mock failures to verify proper error handling
  - [ ] Verify error messages are clear and actionable
  - [ ] Ensure existing compliant commands still work
- **Timing**: 45 minutes

## Testing & Validation

- [ ] review.md creates git commits for new tasks (prevents phantom tasks)
- [ ] task.md verifies actual file system changes before reporting success
- [ ] todo.md verifies archival operations actually occurred
- [ ] All commands return appropriate error status with recovery instructions
- [ ] Existing compliant commands continue to work unchanged
- [ ] Error messages clearly indicate what failed and how to fix

## Artifacts & Outputs

- Updated .opencode/command/review.md with Stage 3.6 (Postflight) validation
- Updated .opencode/command/task.md with Stage 3 (Postflight) validation
- Updated .opencode/command/todo.md with Stage 3.5 (Postflight) validation
- Updated .opencode/context/core/standards/validation-checkpoints.md with standard postflight pattern

## Rollback/Contingency

If validation breaks existing workflows:
- Implement validation as warnings first, then upgrade to failures after testing
- Provide clear error messages with specific recovery steps
- Document which validations are critical (data loss prevention) vs optional
- Ensure all state-modifying operations have corresponding git commits for recovery