# Implementation Plan: Enhance Workflow Commands with Start and End Status Updates

- **Task**: 310 - Enhance workflow commands with start and end status updates
- **Status**: [NOT STARTED]
- **Effort**: 9-12 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/310_enhance_workflow_commands_with_start_and_end_status_updates/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Research reveals that workflow commands already implement start and end status updates through subagent preflight (step_0) and postflight (step_4/7) stages. However, there are critical gaps: (1) /revise command does NOT update status to [REVISING]/[REVISED], (2) already-in-progress detection is incomplete (only checks completed/abandoned), (3) edge cases are not documented or handled. This plan focuses on closing these gaps through targeted enhancements rather than reimplementation, achieving full compliance with task requirements in 9-12 hours.

**Definition of Done**: All workflow commands properly update status at start and end, detect already-in-progress states, /revise uses correct status markers, and edge cases are documented with recovery procedures.

## Goals & Non-Goals

**Goals**:
- Enhance status validation in command files to detect already-in-progress states
- Fix /revise command to use [REVISING]/[REVISED] status markers
- Document edge cases and provide manual recovery procedures
- Add --force flag for advanced users to override validation
- Create /sync command for automated status repair (aligns with task 295)

**Non-Goals**:
- Rewriting existing status update implementation (already works well)
- Implementing full automated edge case handling (document first, automate incrementally)
- Changing status-sync-manager architecture (atomic updates work correctly)
- Modifying state.json schema (current structure is sufficient)

## Risks & Mitigations

- **Risk**: Enhanced validation breaks existing workflows. **Mitigation**: Add --force flag to override, test thoroughly, provide rollback instructions.
- **Risk**: False positives in already-in-progress detection. **Mitigation**: Add timestamp checking (only flag if >1 hour old), clear error messages with recovery steps.
- **Risk**: /revise changes break existing plans. **Mitigation**: Revision mode only affects status markers, not plan content; no breaking changes to plan format.
- **Risk**: Edge cases not fully handled. **Mitigation**: Document thoroughly, provide manual recovery instructions, implement automated handling incrementally.

## Implementation Phases

### Phase 1: Enhance Status Validation in /research Command [NOT STARTED]

- **Goal**: Add comprehensive status validation to /research command to detect already-in-progress and already-completed states
- **Tasks**:
  - [ ] Read current /research.md Stage 1 validation logic (lines 53-54)
  - [ ] Replace basic validation with comprehensive case statement
  - [ ] Add check for [RESEARCHING] status (already in progress)
  - [ ] Add check for [RESEARCHED] status (already completed)
  - [ ] Add check for [ABANDONED] status (cannot research)
  - [ ] Add helpful error messages with recommendations for each case
  - [ ] Test /research on task with [RESEARCHING] status (should report already in progress)
  - [ ] Test /research on task with [RESEARCHED] status (should report already completed)
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - /research detects [RESEARCHING] and reports "already being researched"
  - /research detects [RESEARCHED] and reports "already researched, use /plan to continue"
  - Error messages include helpful recommendations
  - No regression in normal /research workflow

### Phase 2: Enhance Status Validation in /plan and /implement Commands [NOT STARTED]

- **Goal**: Add comprehensive status validation to /plan and /implement commands
- **Tasks**:
  - [ ] Update /plan.md Stage 1 validation (lines 67-71)
  - [ ] Add check for [PLANNING] status (already in progress)
  - [ ] Add check for [PLANNED] status (already completed, suggest /revise)
  - [ ] Update /implement.md Stage 1 validation (lines 53-55)
  - [ ] Add check for [IMPLEMENTING] status (already in progress)
  - [ ] Add check for [BLOCKED] status (cannot implement, resolve blocker first)
  - [ ] Add helpful error messages with recommendations
  - [ ] Test /plan on task with [PLANNING] status
  - [ ] Test /plan on task with [PLANNED] status
  - [ ] Test /implement on task with [IMPLEMENTING] status
  - [ ] Test /implement on task with [BLOCKED] status
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - /plan detects [PLANNING] and reports "already being planned"
  - /plan detects [PLANNED] and suggests "/revise to update plan"
  - /implement detects [IMPLEMENTING] and reports "already being implemented"
  - /implement detects [BLOCKED] and reports blocker with resolution steps
  - All error messages include helpful recommendations

### Phase 3: Fix /revise Command Status Updates [NOT STARTED]

- **Goal**: Update /revise command and planner subagent to use [REVISING]/[REVISED] status markers
- **Tasks**:
  - [ ] Read planner.md inputs_required section
  - [ ] Add revision_context parameter (optional string) to planner inputs
  - [ ] Update planner.md step_0_preflight to check revision_context parameter
  - [ ] If revision_context present: update status to [REVISING] (not [PLANNING])
  - [ ] Update planner.md step_7_postflight to check revision_context parameter
  - [ ] If revision_context present: update status to [REVISED] (not [PLANNED])
  - [ ] Update /revise.md Stage 2 delegation to pass revision_context parameter
  - [ ] Add validation check in /revise.md Stage 1 for [REVISING] status
  - [ ] Test /revise on task with plan (should set [REVISING] then [REVISED])
  - [ ] Test /plan on same task (should still set [PLANNING] then [PLANNED])
  - [ ] Verify no regression in plan content or format
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - /revise updates status to [REVISING] at start (via planner step_0_preflight)
  - /revise updates status to [REVISED] at end (via planner step_7_postflight)
  - /plan continues to use [PLANNING]/[PLANNED] (no change)
  - Plan content and format unchanged (only status markers differ)
  - Both /plan and /revise create valid plan artifacts

### Phase 4: Document Edge Cases and Recovery Procedures [NOT STARTED]

- **Goal**: Create comprehensive documentation for edge cases and manual recovery procedures
- **Tasks**:
  - [ ] Create .opencode/docs/troubleshooting/ directory (lazy creation)
  - [ ] Create status-conflicts.md documentation file
  - [ ] Document edge case 1: Concurrent execution (two users run same command)
  - [ ] Document edge case 2: Stale in-progress status (command crashed, status stuck)
  - [ ] Document edge case 3: Invalid status transitions (e.g., [RESEARCHED] → [RESEARCHING])
  - [ ] Document edge case 4: Rollback failures (status-sync-manager rollback fails)
  - [ ] Document edge case 5: Timeout recovery (command times out, how to resume)
  - [ ] For each edge case: symptoms, root cause, manual recovery steps, prevention tips
  - [ ] Add links to status-conflicts.md from command error messages
  - [ ] Review documentation for clarity and completeness
- **Timing**: 1 hour
- **Acceptance Criteria**:
  - status-conflicts.md created with all 5 edge cases documented
  - Each edge case has: symptoms, root cause, recovery steps, prevention tips
  - Documentation is clear and actionable
  - Links added to command error messages for relevant edge cases

### Phase 5: Add --force Flag for Override [NOT STARTED]

- **Goal**: Add --force flag to all workflow commands to allow advanced users to override status validation
- **Tasks**:
  - [ ] Update /research.md Stage 1 to parse --force flag from $ARGUMENTS
  - [ ] Skip status validation if --force flag present
  - [ ] Log warning when --force used (for audit trail)
  - [ ] Update /plan.md Stage 1 to parse --force flag
  - [ ] Update /implement.md Stage 1 to parse --force flag
  - [ ] Update /revise.md Stage 1 to parse --force flag
  - [ ] Add --force flag documentation to command help text
  - [ ] Test /research 259 --force (should skip validation)
  - [ ] Test /plan 259 --force (should skip validation)
  - [ ] Verify warning logged when --force used
- **Timing**: 2 hours
- **Acceptance Criteria**:
  - All workflow commands accept --force flag
  - --force flag skips status validation (allows override)
  - Warning logged when --force used (audit trail)
  - --force flag documented in command help text
  - Use cases documented: recovering from stale status, re-running research, testing

### Phase 6: Create /sync Command for Status Repair [NOT STARTED]

- **Goal**: Create /sync command to automate status repair for common issues (aligns with task 295)
- **Tasks**:
  - [ ] Create .opencode/command/sync.md command file
  - [ ] Implement Stage 1: Parse task number, validate state.json exists
  - [ ] Implement Stage 2: Detect stale in-progress statuses (>24 hours old)
  - [ ] Implement Stage 3: Detect TODO.md/state.json inconsistencies
  - [ ] Implement Stage 4: Validate artifact existence matches status
  - [ ] Implement Stage 5: Offer to reset status to last known good state
  - [ ] Delegate to status-sync-manager for atomic updates
  - [ ] Add confirmation prompt before making changes
  - [ ] Test /sync on task with stale [IMPLEMENTING] status
  - [ ] Test /sync on task with TODO.md/state.json desync
  - [ ] Document /sync command in command reference
- **Timing**: 3-4 hours
- **Acceptance Criteria**:
  - /sync command created and functional
  - Detects stale in-progress statuses (>24 hours old)
  - Detects TODO.md/state.json inconsistencies
  - Validates artifact existence matches status
  - Offers to reset status with confirmation prompt
  - Delegates to status-sync-manager for atomic updates
  - Use cases: recovering from crashed commands, fixing desync, resetting stale statuses

### Phase 7: Testing and Validation [NOT STARTED]

- **Goal**: Comprehensive testing of all enhancements across all workflow commands
- **Tasks**:
  - [ ] Test /research with all status validation cases (not_started, researching, researched, abandoned)
  - [ ] Test /plan with all status validation cases (not_started, planning, planned, abandoned)
  - [ ] Test /implement with all status validation cases (planned, implementing, blocked, completed)
  - [ ] Test /revise with revision_context parameter (should use [REVISING]/[REVISED])
  - [ ] Test --force flag on all commands (should skip validation)
  - [ ] Test /sync command on stale statuses and desync cases
  - [ ] Verify no regression in normal workflow (research → plan → implement)
  - [ ] Verify status-sync-manager still provides atomic updates
  - [ ] Verify git commits created correctly for all commands
  - [ ] Document test results and any issues found
- **Timing**: 1.5 hours
- **Acceptance Criteria**:
  - All workflow commands tested with comprehensive status validation
  - /revise correctly uses [REVISING]/[REVISED] status markers
  - --force flag works on all commands
  - /sync command repairs stale statuses and desync issues
  - No regression in normal workflow
  - All tests pass, issues documented and resolved

## Testing & Validation

- [ ] Test /research status validation (already-in-progress, already-completed)
- [ ] Test /plan status validation (already-in-progress, already-completed)
- [ ] Test /implement status validation (already-in-progress, blocked)
- [ ] Test /revise status updates ([REVISING] → [REVISED])
- [ ] Test --force flag on all commands
- [ ] Test /sync command (stale status repair, desync repair)
- [ ] Verify no regression in normal workflow (research → plan → implement)
- [ ] Verify atomic updates via status-sync-manager
- [ ] Verify git commits created correctly
- [ ] Verify error messages are helpful and actionable

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- .opencode/command/research.md (enhanced validation)
- .opencode/command/plan.md (enhanced validation)
- .opencode/command/implement.md (enhanced validation)
- .opencode/command/revise.md (enhanced validation, revision_context parameter)
- .opencode/command/sync.md (new command for status repair)
- .opencode/agent/subagents/planner.md (revision_context parameter, conditional status updates)
- .opencode/docs/troubleshooting/status-conflicts.md (edge case documentation)
- summaries/implementation-summary-YYYYMMDD.md (created at completion)

## Rollback/Contingency

If enhancements cause issues:
1. Revert command files to previous versions (git revert)
2. Revert planner.md to previous version (git revert)
3. Remove /sync command if problematic
4. Keep edge case documentation (no harm, provides value)
5. Keep --force flag (provides escape hatch for users)

If specific phase fails:
- Phase 1-2 (validation): Can skip and rely on existing basic validation
- Phase 3 (/revise): Can revert to using [PLANNED] status (current behavior)
- Phase 4 (documentation): Can defer to separate task
- Phase 5 (--force): Can defer to separate task (nice-to-have)
- Phase 6 (/sync): Can defer to task 295 (already planned separately)

## Success Metrics

- All workflow commands detect already-in-progress states (no concurrent execution)
- /revise command uses [REVISING]/[REVISED] status markers (distinguishes from /plan)
- Edge cases documented with clear recovery procedures
- --force flag provides escape hatch for advanced users
- /sync command automates common status repair scenarios
- No regression in normal workflow (research → plan → implement)
- User feedback: error messages are helpful and actionable
