# Implementation Plan: Fix Task Standard Violations in TODO.md Tasks 1-9

- **Task**: 236 - Investigate and fix task standard violations in TODO.md tasks 1-9
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/236_investigate_and_fix_task_standard_violations_in_todomd_tasks_1_9/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

Tasks 1-9 in TODO.md violate task standards by missing the mandatory Language field and using incorrect bullet formatting. Research identified that these tasks were manually created before the task automation system existed. The /task and /review commands already enforce standards correctly for new tasks. This plan fixes the legacy violations in tasks 1-9, adds pre-flight and post-flight validation to prevent future violations, and documents the enforcement mechanisms.

## Goals & Non-Goals

**Goals**:
- Fix all 9 tasks to include mandatory Language field
- Fix Task 1 bullet formatting from `*Field**:` to `- **Field**:`
- Add pre-flight validation to /task command to reject non-compliant inputs
- Add post-flight validation to /review command to verify created tasks
- Test task creation with validation enabled
- Document task standard enforcement mechanisms

**Non-Goals**:
- Creating new validation commands (e.g., /validate-tasks) - out of scope for this task
- Adding pre-commit hooks or CI/CD validation - future enhancement
- Changing task standards themselves - standards are already correct

## Risks & Mitigations

- **Risk**: Manual edits to TODO.md may introduce formatting errors. **Mitigation**: Use Edit tool with exact string matching; verify changes with Read tool before committing.
- **Risk**: Validation may be too strict and reject valid tasks. **Mitigation**: Follow existing /task command validation patterns; test with multiple task types.
- **Risk**: Language detection may fail for edge cases. **Mitigation**: Use explicit Language field extraction with fallback to "general" default.
- **Risk**: Changes to /task or /review may break existing workflows. **Mitigation**: Add validation as enhancement, not breaking change; test with existing task creation patterns.

## Implementation Phases

### Phase 1: Fix Tasks 1-9 Metadata and Formatting [COMPLETED]

- **Started**: 2025-12-28T22:10:00Z
- **Completed**: 2025-12-28T22:10:00Z
- **Goal**: Update tasks 1-9 to comply with task standards by adding Language field and fixing bullet formatting
- **Tasks**:
  - [ ] Add `- **Language**: lean` to Task 1 (Completeness Proofs)
  - [ ] Fix Task 1 bullet formatting: `*Effort**:` to `- **Effort**:`, `*Status**:` to `- **Status**: [NOT STARTED]`, `*Blocking**:` to `- **Blocking**:`, `*Dependencies**:` to `- **Dependencies**:`
  - [ ] Add `- **Language**: lean` to Task 2 (Resolve Truth.lean Sorries)
  - [ ] Add `- **Language**: lean` to Task 3 (Automation Tactics)
  - [ ] Add `- **Language**: lean` to Task 4 (Proof Search)
  - [ ] Add `- **Language**: lean` to Task 5 (Decidability)
  - [ ] Add `- **Language**: lean` to Task 6 (ModalS5 Limitation)
  - [ ] Add `- **Language**: markdown` to Task 7 (Document Creation of Context Files)
  - [ ] Add `- **Language**: lean` to Task 8 (Refactor Context.lean)
  - [ ] Add `- **Language**: lean` to Task 9 (Update Context References)
  - [ ] Verify all changes with Read tool
- **Timing**: 30 minutes
- **Acceptance Criteria**:
  - All 9 tasks have Language field
  - Task 1 uses correct bullet formatting (`- **Field**:`)
  - All Language values are correct (lean for code tasks, markdown for doc tasks)

### Phase 2: Add Pre-flight Validation to /task Command [COMPLETED]

- **Started**: 2025-12-28T22:11:00Z
- **Completed**: 2025-12-28T22:11:00Z
- **Goal**: Enhance /task command with explicit validation to reject non-compliant task creation attempts
- **Tasks**:
  - [ ] Read current /task command implementation (.opencode/command/task.md)
  - [ ] Add validation step after language detection (Stage 3) to verify Language field is set
  - [ ] Add validation to check metadata format uses `- **Field**:` pattern
  - [ ] Add validation to verify required fields are present (Language, Effort, Priority, Status)
  - [ ] Add error messages for validation failures with specific guidance
  - [ ] Document validation logic in command file
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - /task command validates Language field is set before creating task
  - /task command validates metadata format matches standard
  - /task command returns clear error messages for validation failures
  - Validation does not break existing task creation workflows

### Phase 3: Add Post-flight Validation to /review Command [COMPLETED]

- **Started**: 2025-12-28T22:13:00Z
- **Completed**: 2025-12-28T22:13:00Z
- **Goal**: Enhance /review command to verify created tasks comply with standards after delegation to /task
- **Tasks**:
  - [ ] Read current /review command implementation (.opencode/command/review.md)
  - [ ] Add validation step after task creation (Stage 6) to verify created tasks
  - [ ] Validate each created task has Language field
  - [ ] Validate each created task uses correct bullet formatting
  - [ ] Add error reporting for non-compliant tasks with task numbers
  - [ ] Document validation logic in command file
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - /review command validates created tasks after delegation to /task
  - /review command reports any non-compliant tasks with specific violations
  - /review command does not break existing review workflows
  - Validation catches tasks missing Language field or wrong formatting

### Phase 4: Test Task Creation with Validation Enabled [COMPLETED]

- **Started**: 2025-12-28T22:14:00Z
- **Completed**: 2025-12-28T22:14:00Z
- **Goal**: Verify validation works correctly for various task creation scenarios
- **Tasks**:
  - [ ] Test /task command with valid Lean task (should succeed)
  - [ ] Test /task command with valid markdown task (should succeed)
  - [ ] Test /task command with valid general task (should succeed)
  - [ ] Test /review command creating multiple tasks (should succeed)
  - [ ] Verify all created tasks have Language field
  - [ ] Verify all created tasks use correct bullet formatting
  - [ ] Test edge cases (empty description, missing priority, etc.)
  - [ ] Document test results
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - All valid task creation scenarios succeed
  - All created tasks comply with task standards
  - Validation catches non-compliant inputs
  - Edge cases handled gracefully with clear error messages

### Phase 5: Document Task Standard Enforcement [COMPLETED]

- **Started**: 2025-12-28T22:15:00Z
- **Completed**: 2025-12-28T22:15:00Z
- **Goal**: Update documentation to explain task standard enforcement mechanisms
- **Tasks**:
  - [ ] Update .opencode/command/task.md with validation documentation
  - [ ] Update .opencode/command/review.md with validation documentation
  - [ ] Add troubleshooting section to .opencode/context/core/standards/tasks.md
  - [ ] Document Language field importance for routing to Lean-specific agents
  - [ ] Add warning about manual task creation bypassing validation
  - [ ] Document validation error messages and resolutions
- **Timing**: 30 minutes
- **Acceptance Criteria**:
  - Command files document validation logic
  - Task standards document includes troubleshooting guidance
  - Documentation explains Language field routing impact
  - Manual editing warnings are clear

## Testing & Validation

- [ ] All 9 tasks in TODO.md have Language field
- [ ] Task 1 uses correct bullet formatting
- [ ] Language values are correct (lean for code, markdown for docs)
- [ ] /task command validates Language field before task creation
- [ ] /task command validates metadata format
- [ ] /review command validates created tasks after delegation
- [ ] Test task creation succeeds for valid inputs
- [ ] Test task creation fails gracefully for invalid inputs
- [ ] Documentation explains validation mechanisms
- [ ] No regressions in existing task creation workflows

## Artifacts & Outputs

- .opencode/specs/TODO.md (updated tasks 1-9)
- .opencode/command/task.md (enhanced with validation)
- .opencode/command/review.md (enhanced with validation)
- .opencode/context/core/standards/tasks.md (updated with troubleshooting)
- plans/implementation-001.md (this file)

## Rollback/Contingency

If validation changes break existing workflows:
1. Revert changes to /task and /review commands
2. Keep manual fixes to tasks 1-9 (no rollback needed)
3. Document validation requirements for future implementation
4. Consider less strict validation approach (warnings instead of errors)

If manual edits to TODO.md introduce errors:
1. Use git to revert TODO.md to previous state
2. Re-apply fixes more carefully with exact string matching
3. Verify each change individually before proceeding to next task
