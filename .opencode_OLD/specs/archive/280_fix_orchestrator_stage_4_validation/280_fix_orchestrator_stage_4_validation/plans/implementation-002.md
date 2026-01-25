# Implementation Plan: Add Subagent Return Validation to Command Files

## Metadata

- **Task**: 280 - Fix orchestrator Stage 4 validation to enforce subagent return format and prevent phantom research
- **Plan Version**: 2 (Revised for v7.0 architecture)
- **Status**: [NOT STARTED]
- **Estimated Effort**: 6 hours
- **Actual Effort**: TBD
- **Language**: markdown
- **Priority**: High
- **Created**: 2026-01-05
- **Started**: TBD
- **Completed**: TBD
- **Research Integrated**: Yes (research-001.md)
- **Revision Context**: Revised for orchestrator v7.0 pure router architecture

## Overview

### Problem Statement

**CRITICAL ARCHITECTURE CHANGE**: The orchestrator has been refactored from v5.0 (6-stage workflow manager with Stage 4 ValidateReturn) to v7.0 (pure 2-stage router). The validation logic that existed in the old Stage 4 has been **completely removed** and is NOT implemented anywhere in the new architecture.

**Current State**:
- Orchestrator v7.0 is a pure router: loads command file, delegates with $ARGUMENTS
- Command files (`.opencode/command/*.md`) parse arguments and delegate to subagents
- Command files receive subagent returns but **DO NOT VALIDATE** them
- Subagents return JSON but there's **NO ENFORCEMENT** of the format
- `validation-rules.md` documents what SHOULD be validated but is NOT executed
- `validation-strategy.md` says return format validation is "worth it" but is NOT implemented

**Impact**: ALL workflow commands (/research, /plan, /implement, /revise) are vulnerable to:
- **Phantom operations**: Subagents claim "completed" but create no artifacts
- **Malformed returns**: Subagents return plain text instead of JSON
- **Missing fields**: Subagents omit required fields (status, summary, artifacts, metadata)
- **Invalid status**: Subagents use invalid status values ("success", "done", etc.)
- **Session mismatches**: Subagents return wrong session_id

**Root Cause**: Validation logic was removed during orchestrator refactor and NOT re-implemented in command files.

### Scope

**In Scope**:
- Add return validation to all command files that delegate to subagents
- Implement 5 validation steps from `validation-rules.md`:
  1. JSON structure validation
  2. Required fields validation
  3. Status enum validation
  4. Session ID validation
  5. Artifact validation (if status=completed)
- Create reusable validation helper function/section
- Test validation with malformed returns
- Update documentation to reflect new validation location

**Out of Scope**:
- Restoring old orchestrator Stage 4 (architecture has changed)
- Creating external validation script (using inline logic)
- Validation metrics and monitoring (future enhancement)
- Automated validation test suite (future enhancement)
- Schema versioning (future enhancement)

### Constraints

- Must work with orchestrator v7.0 pure router architecture
- Must not break existing command file structure
- Must follow validation-rules.md logic exactly
- Must fail fast on validation errors (no silent failures)
- Must provide clear, actionable error messages
- Must validate artifacts only for status=completed (not partial/failed/blocked)

### Definition of Done

- [ ] All command files that delegate to subagents have return validation
- [ ] All 5 validation steps implemented (JSON, fields, status, session_id, artifacts)
- [ ] Validation rejects plain text returns
- [ ] Validation rejects phantom research (status=completed, no artifacts)
- [ ] Validation rejects missing artifact files
- [ ] Validation rejects empty artifact files
- [ ] Validation rejects session_id mismatches
- [ ] Error messages are clear and actionable
- [ ] All workflow commands tested with validation enabled
- [ ] Documentation updated to reflect validation location
- [ ] No regressions in normal operation

## Goals and Non-Goals

### Goals

1. **Prevent Phantom Research**: Reject returns with status=completed but no artifacts
2. **Enforce Return Format**: Reject plain text or malformed JSON returns
3. **Validate Artifacts**: Verify all artifact files exist and are non-empty
4. **Clear Error Messages**: Provide actionable feedback for validation failures
5. **Protect All Commands**: Apply validation to /research, /plan, /implement, /revise

### Non-Goals

1. Restoring old orchestrator architecture (v7.0 is the new standard)
2. Creating external validation script (using inline logic)
3. Adding validation metrics/monitoring (future work)
4. Creating automated test suite (future work)
5. Enhancing return format with schema versioning (future work)
6. Validating artifacts for partial/failed/blocked status

## Risks and Mitigations

### Risk 1: Breaking Existing Subagents

**Description**: Strict validation may break subagents that return slightly malformed JSON

**Likelihood**: Medium  
**Impact**: High (workflow commands stop working)

**Mitigation**:
- Test all subagents with validation enabled before deployment
- Fix any subagents that fail validation
- Review existing subagent returns for compliance
- Subagents already document return format, so should be compliant

### Risk 2: False Positives

**Description**: Validation may reject legitimate returns (e.g., partial results with no artifacts)

**Likelihood**: Low  
**Impact**: Medium (legitimate operations fail)

**Mitigation**:
- Only validate artifacts for status=completed
- Allow empty artifacts for partial/failed/blocked status
- Test edge cases thoroughly
- Follow validation-strategy.md guidelines

### Risk 3: Incomplete Validation

**Description**: Validation may miss edge cases or new failure modes

**Likelihood**: Medium  
**Impact**: Medium (phantom research still possible)

**Mitigation**:
- Follow validation-rules.md comprehensively
- Add test cases for all known failure modes
- Monitor for new failure patterns

## Implementation Phases

### Phase 1: Create Reusable Validation Section Template [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Create a reusable validation section that can be added to all command files

**Tasks**:
1. Read validation-rules.md (all 5 validation steps)
2. Read validation-strategy.md (validation philosophy)
3. Create validation section template in command file format:
   - Stage 3: ValidateReturn (new stage after Delegate)
   - Implement all 5 validation steps as executable logic
   - Add error handling for each validation failure
   - Format for command file workflow_execution structure
4. Document validation section usage
5. Create example showing how to integrate into command file

**Acceptance Criteria**:
- [ ] Validation section template created with all 5 steps
- [ ] Template uses command file workflow_execution format
- [ ] Template includes error handling for all failure modes
- [ ] Template is reusable across all command files
- [ ] Documentation explains how to integrate template

**Validation**:
- Template follows validation-rules.md logic exactly
- Template fits command file structure (workflow_execution stages)
- Template is self-contained and reusable

---

### Phase 2: Add Validation to /research Command [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Add return validation to research.md command file

**Tasks**:
1. Read current research.md command file
2. Identify where subagent return is received (Stage 2: Delegate)
3. Add Stage 3: ValidateReturn after delegation
4. Integrate validation section template:
   - Validate JSON structure
   - Validate required fields
   - Validate status enum
   - Validate session_id
   - Validate artifacts (if status=completed)
5. Add error handling to return validation failures to user
6. Test with valid and invalid returns

**Acceptance Criteria**:
- [ ] research.md has Stage 3: ValidateReturn
- [ ] All 5 validation steps implemented
- [ ] Validation rejects plain text returns
- [ ] Validation rejects phantom research
- [ ] Validation rejects missing/empty artifacts
- [ ] Error messages are clear and actionable
- [ ] Normal /research operations still work

**Validation**:
- Test /research with valid return (should pass)
- Test /research with plain text return (should fail)
- Test /research with status=completed, no artifacts (should fail)
- Test /research with missing artifact file (should fail)

---

### Phase 3: Add Validation to /plan and /revise Commands [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Add return validation to plan.md and revise.md command files

**Tasks**:
1. Read current plan.md and revise.md command files
2. Add Stage 3: ValidateReturn to both files
3. Integrate validation section template (same as research.md)
4. Add error handling
5. Test with valid and invalid returns

**Acceptance Criteria**:
- [ ] plan.md has Stage 3: ValidateReturn
- [ ] revise.md has Stage 3: ValidateReturn
- [ ] All 5 validation steps implemented in both
- [ ] Validation rejects phantom planning
- [ ] Error messages are clear and actionable
- [ ] Normal /plan and /revise operations still work

**Validation**:
- Test /plan with valid return (should pass)
- Test /plan with status=completed, no artifacts (should fail)
- Test /revise with valid return (should pass)
- Test /revise with malformed return (should fail)

---

### Phase 4: Add Validation to /implement Command [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Add return validation to implement.md command file

**Tasks**:
1. Read current implement.md command file
2. Add Stage 3: ValidateReturn
3. Integrate validation section template
4. Add error handling
5. Test with valid and invalid returns

**Acceptance Criteria**:
- [ ] implement.md has Stage 3: ValidateReturn
- [ ] All 5 validation steps implemented
- [ ] Validation rejects phantom implementation
- [ ] Error messages are clear and actionable
- [ ] Normal /implement operations still work

**Validation**:
- Test /implement with valid return (should pass)
- Test /implement with status=completed, no artifacts (should fail)
- Test /implement with missing artifact file (should fail)

---

### Phase 5: Test All Commands and Update Documentation [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Comprehensive testing and documentation updates

**Tasks**:
1. Test all workflow commands with validation enabled:
   - /research with valid and invalid returns
   - /plan with valid and invalid returns
   - /implement with valid and invalid returns
   - /revise with valid and invalid returns
2. Verify no regressions in normal operation
3. Update validation-rules.md:
   - Note that validation is enforced by command files (not orchestrator)
   - Update "See Also" section to reference command files
   - Add examples of validation failures
4. Update validation-strategy.md:
   - Mark "Return Format Validation" as IMPLEMENTED
   - Document implementation location (command files Stage 3)
5. Document any issues found and fixes applied

**Acceptance Criteria**:
- [ ] All 4 workflow commands tested with valid returns (pass)
- [ ] All 4 workflow commands tested with invalid returns (fail with clear errors)
- [ ] No regressions in normal operation
- [ ] validation-rules.md updated
- [ ] validation-strategy.md updated
- [ ] Implementation location documented

**Validation**:
- Run each workflow command with valid subagent return
- Run each workflow command with malformed return
- Verify validation catches all malformed returns
- Verify normal operations still work
- Verify documentation is accurate

---

## Testing and Validation

### Unit Testing

**Test Cases**:
1. **JSON Structure Validation**:
   - Input: Plain text "Research completed"
   - Expected: "[FAIL] Invalid JSON return from researcher"

2. **Required Fields Validation**:
   - Input: JSON missing "status" field
   - Expected: "[FAIL] Missing required field: status"

3. **Status Enum Validation**:
   - Input: JSON with status="success"
   - Expected: "[FAIL] Invalid status: success"

4. **Session ID Validation**:
   - Input: JSON with wrong session_id
   - Expected: "[FAIL] Session ID mismatch"

5. **Phantom Research Validation**:
   - Input: JSON with status="completed", artifacts=[]
   - Expected: "[FAIL] Phantom research detected"

6. **Artifact Existence Validation**:
   - Input: JSON with artifact path that doesn't exist
   - Expected: "[FAIL] Artifact does not exist: {path}"

7. **Artifact Non-Empty Validation**:
   - Input: JSON with artifact path to empty file
   - Expected: "[FAIL] Artifact is empty: {path}"

8. **Valid Return**:
   - Input: JSON with all required fields, valid status, matching session_id, existing non-empty artifacts
   - Expected: "[PASS] Return validation succeeded"

### Integration Testing

**Test Scenarios**:
1. Run /research 280 with valid researcher return → should complete successfully
2. Run /research 280 with plain text return → should fail with validation error
3. Run /plan 280 with valid planner return → should complete successfully
4. Run /plan 280 with phantom plan (no artifacts) → should fail with validation error
5. Run /implement 280 with valid implementer return → should complete successfully
6. Run /implement 280 with missing artifact file → should fail with validation error

### Regression Testing

**Verify**:
- Existing workflow commands still work with valid returns
- No performance degradation (validation adds <1 second)
- Error messages are user-friendly
- Command files log validation results

## Artifacts and Outputs

### Primary Artifacts

1. **Validation Section Template**
   - Reusable validation section for command files
   - All 5 validation steps implemented
   - Error handling included

2. **Updated Command Files**:
   - `.opencode/command/research.md` (with Stage 3: ValidateReturn)
   - `.opencode/command/plan.md` (with Stage 3: ValidateReturn)
   - `.opencode/command/revise.md` (with Stage 3: ValidateReturn)
   - `.opencode/command/implement.md` (with Stage 3: ValidateReturn)

3. **Updated Documentation**:
   - `.opencode/context/core/system/validation-rules.md` (updated implementation notes)
   - `.opencode/context/core/system/validation-strategy.md` (marked as implemented)

### Supporting Artifacts

4. **Test Results Documentation**
   - Test cases executed
   - Results for each scenario
   - Issues found and fixes applied

5. **Git Commit**
   - All changes committed with message: "task 280: add subagent return validation to command files"

## Rollback/Contingency

### Rollback Plan

If validation causes issues with existing subagents:

1. **Identify Breaking Changes**:
   - Review validation errors from subagents
   - Determine if errors are legitimate or false positives

2. **Fix Subagents** (preferred):
   - Update subagents to return valid JSON format
   - Ensure all required fields are present
   - Ensure artifacts are created before status=completed

3. **Relax Validation** (fallback):
   - Temporarily disable artifact validation
   - Log validation warnings instead of failing
   - Fix subagents, then re-enable strict validation

### Contingency Plan

If validation is incomplete or misses edge cases:

1. **Monitor for New Failure Patterns**:
   - Watch for phantom research reports
   - Check errors.json for validation failures

2. **Update Validation Logic**:
   - Add new validation rules as needed
   - Test new rules thoroughly
   - Update documentation

3. **Iterate**:
   - Validation is not one-time fix
   - Continuous improvement as new patterns emerge

## Success Metrics

### Functional Metrics

- [ ] 0 phantom research incidents after implementation
- [ ] 100% of malformed returns rejected by validation
- [ ] 100% of valid returns pass validation (no false positives)
- [ ] All 8 test cases pass

### Quality Metrics

- [ ] Error messages are clear and actionable (user feedback)
- [ ] Validation adds <1 second to command execution time
- [ ] No regressions in existing workflow commands
- [ ] Documentation updated and accurate

### Process Metrics

- [ ] Implementation completed within 6 hours estimate
- [ ] All phases completed in order
- [ ] All acceptance criteria met
- [ ] Git commit created with all changes

## Dependencies

### Required Files

- `.opencode/command/research.md` (research command)
- `.opencode/command/plan.md` (plan command)
- `.opencode/command/revise.md` (revise command)
- `.opencode/command/implement.md` (implement command)
- `.opencode/context/core/system/validation-rules.md` (validation logic reference)
- `.opencode/context/core/system/validation-strategy.md` (validation philosophy)
- `.opencode/context/core/standards/subagent-return-format.md` (return format standard)

### Required Tools

- `jq` (JSON parsing and validation)
- Text editor (for updating command files)
- Git (for committing changes)

### Required Knowledge

- Orchestrator v7.0 architecture (pure router)
- Command file structure (workflow_execution stages)
- Subagent return format standard
- Validation logic from validation-rules.md
- Bash scripting (for jq commands)

## Notes

### Research Integration

This plan integrates findings from research-001.md:

- **Finding 1**: Validation logic exists in validation-rules.md but is not executed → Phases 1-4 implement the logic in command files
- **Finding 2**: Phantom research example (task 279) → Phase 2 specifically addresses this for /research
- **Finding 3**: Vulnerability affects all workflow commands → Phases 2-4 protect all commands
- **Finding 4**: Return format standard is well-defined → Used as reference for validation
- **Finding 5**: Stage 4 was documentation-only → Now implementing in command files instead

### Architecture Changes Since Original Plan

**Original Plan (v1)** assumed:
- Orchestrator v5.0 with 6 stages
- Stage 4 (ValidateReturn) exists but is documentation-only
- Fix: Rewrite Stage 4 with executable validation logic

**Revised Plan (v2)** reflects:
- Orchestrator v7.0 with 2 stages (pure router)
- Stage 4 completely removed
- Command files now handle delegation and receive returns
- Fix: Add Stage 3 (ValidateReturn) to command files

### Implementation Approach

Using **inline validation logic** in command files:
- All validation logic in command file Stage 3
- No external validation script
- Consistent with command file pattern
- Simpler to maintain and understand

### Key Validation Rules

1. **JSON Structure**: Must be valid JSON (not plain text)
2. **Required Fields**: status, summary, artifacts, metadata (with subfields)
3. **Status Enum**: Must be one of: completed, partial, failed, blocked
4. **Session ID**: Must match expected session_id from delegation context
5. **Artifacts** (CRITICAL): If status=completed, artifacts must be non-empty, files must exist and be non-empty

### Error Handling

All validation failures should:
- Log error to errors.json
- Format error response for user (clear message + recommendation)
- Return failed status to user
- NOT proceed to next stage (fail fast)

### Validation Location

**v5.0 Architecture**: Orchestrator Stage 4 (ValidateReturn)  
**v7.0 Architecture**: Command files Stage 3 (ValidateReturn)

This reflects the architectural shift from centralized orchestrator to distributed command files.

## Revision History

### Version 1 (2026-01-03)
- Original plan for orchestrator v5.0
- Assumed Stage 4 exists but is documentation-only
- Planned to rewrite Stage 4 with executable logic

### Version 2 (2026-01-05)
- Revised for orchestrator v7.0 pure router architecture
- Stage 4 completely removed in refactor
- Command files now handle delegation
- Validation moved to command files Stage 3
- Reduced effort from 7 hours to 6 hours (simpler implementation)
- Updated all phases to reflect new architecture
- Added architecture changes section
- Clarified validation location change
