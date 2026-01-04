# Implementation Plan: Fix Stage 7 (Postflight) Execution Failures

- **Task**: 240 - Systematically investigate and fix persistent workflow command Stage 7 (Postflight) failures causing incomplete status updates
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Priority**: Critical
- **Dependencies**: None
- **Research Inputs**: .opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/system/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
- **Language**: markdown
- **Lean Intent**: false

## Overview

Research definitively identified the root cause of persistent Stage 7 (Postflight) failures: Stage 7 exists only as documentation (XML/narrative syntax), not executable instructions, with no orchestrator enforcement. This causes all workflow commands (/research, /plan, /implement, /revise) to skip status updates despite successful artifact creation. The solution implements an orchestrator validation layer with command_stages tracking and Stage 7 completion checks to enforce 100% reliable execution. This plan delivers a comprehensive fix in 4 phases totaling 8 hours with LOW risk and CRITICAL impact.

## Goals & Non-Goals

**Goals:**
- Implement orchestrator validation layer to enforce Stage 7 completion
- Add command_stages tracking to delegation registry
- Validate Stage 7 completion before accepting command returns
- Verify TODO.md and state.json updates on disk
- Surface clear error messages when Stage 7 fails
- Achieve 100% reliable Stage 7 execution across all 4 workflow commands
- Eliminate silent failures requiring manual intervention

**Non-Goals:**
- Rewrite command files from XML to executable code (too risky, 100+ hours)
- Further strengthen command file prompting (already proven ineffective in task 231)
- Fix unrelated status update issues in subagents (different scope)
- Implement Stage 7 execution within command files themselves (architectural limitation)

## Risks & Mitigations

**Risk 1: Orchestrator changes break existing delegation patterns**
- Mitigation: Changes are additive only (new fields, new validation), no modifications to existing delegation logic
- Mitigation: Comprehensive testing of all 4 commands before deployment

**Risk 2: File verification false positives (files updated by other processes)**
- Mitigation: Verify modification time > command start time AND verify content changes match expected updates
- Mitigation: Include session_id in verification to ensure updates are from current command execution

**Risk 3: Performance impact from additional validation**
- Mitigation: Validation is lightweight (registry lookups, file stat calls), estimated <100ms overhead
- Mitigation: Only runs for command delegations, not subagent delegations

**Risk 4: Incomplete Stage 7 detection causes false errors**
- Mitigation: Clear error messages with manual recovery instructions
- Mitigation: Logging to errors.json for debugging
- Mitigation: Phased rollout with testing at each phase

## Implementation Phases

### Phase 1: Orchestrator Stage Tracking [NOT STARTED]

- **Goal:** Add command_stages tracking to delegation registry to enable Stage 7 validation
- **Tasks:**
  - [ ] Read orchestrator.md delegation registry structure (lines 96-146)
  - [ ] Add is_command boolean field to distinguish commands from subagents
  - [ ] Add command_stages object with current_stage, stages_completed array, stage_7_completed flag
  - [ ] Add stage_7_artifacts object tracking status_sync_manager_invoked, todo_md_updated, state_json_updated, git_commit_created
  - [ ] Update RegisterDelegation step (orchestrator.md lines 397-419) to initialize command_stages for command delegations
  - [ ] Update delegation registry documentation with new fields
  - [ ] Verify registry structure with test delegation
- **Timing:** 2 hours
- **Acceptance Criteria:**
  - Delegation registry includes command_stages for command delegations
  - command_stages initialized with stage_7_completed=false
  - stage_7_artifacts initialized with all flags=false
  - Non-command delegations (subagents) do not include command_stages
  - Registry structure documented

### Phase 2: Orchestrator Validation Implementation [NOT STARTED]

- **Goal:** Implement Stage 7 completion validation in orchestrator Step 10 (ValidateReturn)
- **Tasks:**
  - [ ] Read orchestrator.md Step 10 ValidateReturn (lines 524-630)
  - [ ] Add command_stage_validation section after existing validation
  - [ ] Check if delegation is_command (skip validation for subagents)
  - [ ] Extract command_stages from delegation registry
  - [ ] Verify stage_7_completed == true
  - [ ] Verify stage_7_artifacts.status_sync_manager_completed == true
  - [ ] Verify stage_7_artifacts.todo_md_updated == true
  - [ ] Verify stage_7_artifacts.state_json_updated == true
  - [ ] If any check fails: log error, verify files on disk, return error to user, reject return
  - [ ] Update orchestrator.md documentation with validation logic
- **Timing:** 2 hours
- **Acceptance Criteria:**
  - ValidateReturn checks Stage 7 completion for command delegations
  - Validation skipped for non-command delegations
  - Failed validation logs error to errors.json
  - Failed validation returns clear error message to user
  - Failed validation rejects return (does not proceed to ProcessResults)

### Phase 3: File Verification and Error Surfacing [NOT STARTED]

- **Goal:** Implement file verification helper and comprehensive error messages
- **Tasks:**
  - [ ] Read orchestrator.md helper_functions section (lines 772-863)
  - [ ] Implement verify_file_updated(file_path, start_time) helper function
  - [ ] Check file existence with os.path.exists()
  - [ ] Get file modification time with os.path.getmtime()
  - [ ] Compare modification time > start_time
  - [ ] Integrate file verification into Stage 7 validation
  - [ ] Verify TODO.md modification time > command start time
  - [ ] Verify state.json modification time > command start time
  - [ ] Design error message template with manual recovery instructions
  - [ ] Include list of created artifacts in error message
  - [ ] Include retry command suggestion in error message
  - [ ] Test error message clarity with sample failures
- **Timing:** 2 hours
- **Acceptance Criteria:**
  - verify_file_updated helper function implemented and tested
  - File verification integrated into Stage 7 validation
  - Error messages include manual recovery steps
  - Error messages include retry command suggestion
  - Error messages list successfully created artifacts
  - Error messages are clear and actionable

### Phase 4: Comprehensive Testing and Documentation [NOT STARTED]

- **Goal:** Test all 4 workflow commands and update documentation with lessons learned
- **Tasks:**
  - [ ] Create test task for /research command
  - [ ] Run /research {task_number} and verify Stage 7 execution
  - [ ] Verify TODO.md updated to [RESEARCHED] status
  - [ ] Verify state.json updated to "researched" status
  - [ ] Verify research report linked in TODO.md
  - [ ] Repeat test for /plan command (verify [PLANNED] status)
  - [ ] Repeat test for /implement command (verify [COMPLETED] status)
  - [ ] Repeat test for /revise command (verify [REVISED] status)
  - [ ] Test Stage 7 failure detection by simulating skipped Stage 7
  - [ ] Verify error message returned to user
  - [ ] Verify return rejected by orchestrator
  - [ ] Verify error logged to errors.json
  - [ ] Update command-lifecycle.md with lessons learned section
  - [ ] Document architectural flaw and solution in command-lifecycle.md
  - [ ] Update orchestrator.md with Stage 7 validation documentation
  - [ ] Create monitoring checklist for future Stage 7 issues
- **Timing:** 2 hours
- **Acceptance Criteria:**
  - All 4 commands tested with 100% Stage 7 execution success
  - TODO.md and state.json updated 100% reliably for all commands
  - Stage 7 failure detection tested and working
  - Error messages clear and actionable
  - Documentation updated with lessons learned
  - Monitoring checklist created for future issues

## Testing & Validation

**Unit Tests:**
- [ ] Test delegation registry initialization with command_stages
- [ ] Test delegation registry initialization without command_stages (subagents)
- [ ] Test Stage 7 validation logic with stage_7_completed=true
- [ ] Test Stage 7 validation logic with stage_7_completed=false
- [ ] Test verify_file_updated with file modified after start time
- [ ] Test verify_file_updated with file modified before start time
- [ ] Test verify_file_updated with non-existent file

**Integration Tests:**
- [ ] Test /research command end-to-end with Stage 7 validation
- [ ] Test /plan command end-to-end with Stage 7 validation
- [ ] Test /implement command end-to-end with Stage 7 validation
- [ ] Test /revise command end-to-end with Stage 7 validation
- [ ] Test Stage 7 failure detection with simulated skip
- [ ] Test error message content and clarity
- [ ] Test error logging to errors.json

**Validation Criteria:**
- [ ] 100% Stage 7 execution rate across all 4 commands (10+ test runs each)
- [ ] 100% TODO.md update rate (verified on disk)
- [ ] 100% state.json update rate (verified on disk)
- [ ] 100% Stage 7 failure detection rate (simulated failures)
- [ ] 0% silent failures (all failures return error to user)
- [ ] Error messages include manual recovery steps
- [ ] Error messages include retry command suggestion

## Artifacts & Outputs

**Implementation Artifacts:**
- .opencode/specs/240_systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures/plans/implementation-001.md (this file)

**Modified Files:**
- .opencode/agent/orchestrator.md (delegation registry, ValidateReturn step, helper functions)
- .opencode/context/core/workflows/command-lifecycle.md (lessons learned section)

**Documentation:**
- Lessons learned section in command-lifecycle.md
- Stage 7 validation documentation in orchestrator.md
- Monitoring checklist for future Stage 7 issues

**Testing Artifacts:**
- Test results for all 4 commands (10+ runs each)
- Error message samples
- errors.json log entries

## Rollback/Contingency

**Rollback Plan:**
If orchestrator validation causes unexpected issues, rollback is straightforward:

1. **Revert orchestrator.md changes:**
   - Remove command_stages from delegation registry
   - Remove command_stage_validation from ValidateReturn step
   - Remove verify_file_updated helper function

2. **Revert command-lifecycle.md changes:**
   - Remove lessons learned section

3. **Verify rollback:**
   - Test all 4 commands execute without errors
   - Verify delegation registry works without command_stages
   - Verify ValidateReturn works without Stage 7 validation

**Contingency Plan:**
If Stage 7 validation detects failures but root cause is different than expected:

1. **Investigate actual root cause:**
   - Review errors.json log entries
   - Review file modification timestamps
   - Review delegation registry state

2. **Adjust validation logic:**
   - Refine stage_7_artifacts checks
   - Adjust file verification logic
   - Update error messages

3. **Re-test:**
   - Run all 4 commands with adjusted validation
   - Verify 100% success rate
   - Verify error detection still works

**Risk Assessment:**
- Rollback risk: LOW (changes are additive, no breaking changes)
- Rollback effort: 30 minutes (simple revert of orchestrator.md changes)
- Contingency risk: LOW (validation logic can be refined without breaking existing functionality)

## Success Criteria

**Implementation Success:**
- [ ] Orchestrator tracks command_stages in delegation registry
- [ ] Orchestrator validates Stage 7 completion in ValidateReturn step
- [ ] File verification helper implemented and integrated
- [ ] Error surfacing implemented with clear messages
- [ ] All code changes documented

**Testing Success:**
- [ ] All 4 commands execute Stage 7 100% reliably (40+ test runs total)
- [ ] TODO.md updated 100% reliably (verified on disk)
- [ ] state.json updated 100% reliably (verified on disk)
- [ ] Stage 7 skipping detected and rejected 100% reliably
- [ ] Clear error messages returned to user for all failures
- [ ] No silent failures observed

**User Impact Success:**
- [ ] No more manual intervention required for status updates
- [ ] No more silent failures creating confusion
- [ ] Clear error messages when failures occur
- [ ] Reliable task tracking across all workflow commands
- [ ] User confidence in workflow system restored

**Documentation Success:**
- [ ] Lessons learned documented in command-lifecycle.md
- [ ] Stage 7 validation documented in orchestrator.md
- [ ] Monitoring checklist created for future issues
- [ ] Root cause and solution clearly explained

## Lessons Learned from Research

**Key Insights from Research Report:**

1. **Root Cause:** Stage 7 exists only as documentation (XML/narrative syntax), not executable instructions, with no orchestrator enforcement.

2. **Why Previous Fixes Failed:**
   - Task 231: Strengthened prompting without implementing orchestrator validation
   - Task 221: Addressed different problem (task-executor delegation)
   - Both addressed symptoms without addressing root cause

3. **Architectural Flaw:** Command files use XML/narrative syntax with no executable delegation mechanism. Claude interprets this as documentation rather than imperative commands.

4. **Missing Enforcement:** Orchestrator doesn't validate Stage 7 completion, allowing commands to skip Stage 7 and proceed to Stage 8 without consequence.

5. **Silent Failures:** When Stage 7 is skipped, no error is returned to user, creating false impression of success.

**Solution Approach:**

Rather than continuing to strengthen prompting (proven ineffective) or rewriting commands in executable code (too risky), this plan implements an orchestrator validation layer that enforces Stage 7 completion through:

- Command stage tracking in delegation registry
- Validation checkpoints in orchestrator ValidateReturn step
- File verification to confirm updates on disk
- Clear error messages when validation fails

This approach addresses the root cause (no enforcement) with minimal risk (additive changes only) and reasonable effort (8 hours vs 100+ hours for full rewrite).
