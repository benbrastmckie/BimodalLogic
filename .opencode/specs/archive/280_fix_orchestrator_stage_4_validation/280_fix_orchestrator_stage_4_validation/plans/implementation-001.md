# Implementation Plan: Fix Orchestrator Stage 4 Validation

## Metadata

- **Task**: 280 - Fix orchestrator Stage 4 validation to enforce subagent return format and prevent phantom research
- **Status**: [NOT STARTED]
- **Estimated Effort**: 7 hours
- **Actual Effort**: TBD
- **Language**: markdown
- **Priority**: High
- **Created**: 2026-01-03
- **Started**: TBD
- **Completed**: TBD
- **Research Integrated**: Yes (research-001.md)

## Overview

### Problem Statement

The orchestrator's Stage 4 (ValidateReturn) is documented but NOT implemented. It references `validation-rules.md` which contains comprehensive validation logic, but the orchestrator only lists the validation steps without executing them. This allows subagents to return plain text or malformed JSON, claim "completed" status without creating artifacts, and cause "phantom research" where users think work is done but no artifacts exist.

**Root Cause**: Stage 4 is documentation-only, not executable validation logic.

**Impact**: ALL workflow commands (/research, /plan, /implement, /revise) are vulnerable to phantom operations.

### Scope

**In Scope**:
- Rewrite orchestrator Stage 4 with executable validation logic
- Implement 5 validation steps: JSON structure, required fields, status enum, session_id, artifacts
- Add error handling for validation failures
- Test validation with malformed returns
- Update validation-rules.md with implementation details
- Test all workflow commands with validation enabled

**Out of Scope**:
- Creating external validation script (using inline logic instead)
- Validation metrics and monitoring (future enhancement)
- Automated validation test suite (future enhancement)
- Schema versioning (future enhancement)

### Constraints

- Must follow validation-rules.md logic exactly
- Must not break existing subagents that return valid JSON
- Must fail fast on validation errors (no silent failures)
- Must provide clear, actionable error messages
- Must validate artifacts only for status=completed (not partial/failed/blocked)

### Definition of Done

- [ ] Orchestrator Stage 4 contains executable validation logic
- [ ] All 5 validation steps implemented (JSON, fields, status, session_id, artifacts)
- [ ] Validation rejects plain text returns
- [ ] Validation rejects phantom research (status=completed, no artifacts)
- [ ] Validation rejects missing artifact files
- [ ] Validation rejects empty artifact files
- [ ] Validation rejects session_id mismatches
- [ ] Error messages are clear and actionable
- [ ] All workflow commands tested with validation enabled
- [ ] validation-rules.md updated with implementation details
- [ ] No regressions in normal operation

## Goals and Non-Goals

### Goals

1. **Prevent Phantom Research**: Reject returns with status=completed but no artifacts
2. **Enforce Return Format**: Reject plain text or malformed JSON returns
3. **Validate Artifacts**: Verify all artifact files exist and are non-empty
4. **Clear Error Messages**: Provide actionable feedback for validation failures
5. **Protect All Commands**: Apply validation to /research, /plan, /implement, /revise

### Non-Goals

1. Creating external validation script (using inline logic)
2. Adding validation metrics/monitoring (future work)
3. Creating automated test suite (future work)
4. Enhancing return format with schema versioning (future work)
5. Validating artifacts for partial/failed/blocked status

## Risks and Mitigations

### Risk 1: Breaking Existing Subagents

**Description**: Strict validation may break subagents that return slightly malformed JSON

**Likelihood**: Medium  
**Impact**: High (workflow commands stop working)

**Mitigation**:
- Test all subagents with validation enabled before deployment
- Fix any subagents that fail validation
- Review existing subagent returns for compliance

### Risk 2: False Positives

**Description**: Validation may reject legitimate returns (e.g., partial results with no artifacts)

**Likelihood**: Low  
**Impact**: Medium (legitimate operations fail)

**Mitigation**:
- Only validate artifacts for status=completed
- Allow empty artifacts for partial/failed/blocked status
- Test edge cases thoroughly

### Risk 3: Incomplete Validation

**Description**: Validation may miss edge cases or new failure modes

**Likelihood**: Medium  
**Impact**: Medium (phantom research still possible)

**Mitigation**:
- Follow validation-rules.md comprehensively
- Add test cases for all known failure modes
- Monitor for new failure patterns

## Implementation Phases

### Phase 1: Implement JSON Structure and Required Fields Validation [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Implement Steps 1-2 of validation logic to reject plain text and incomplete returns

**Tasks**:
1. Read current orchestrator.md Stage 4 (lines 200-212)
2. Read validation-rules.md Steps 1-2 (lines 32-58)
3. Rewrite Stage 4 `<process>` section with executable logic:
   - Step 1: Validate JSON structure (parse with jq, fail if invalid)
   - Step 2: Validate required fields (status, summary, artifacts, metadata)
   - Step 2b: Validate metadata subfields (session_id, agent_type, delegation_depth, delegation_path)
4. Add `<validation_failure_handling>` section for error responses
5. Update `<checkpoint>` to reflect actual execution

**Acceptance Criteria**:
- [ ] Stage 4 contains executable jq commands for JSON parsing
- [ ] Stage 4 checks all required fields (status, summary, artifacts, metadata)
- [ ] Stage 4 checks all metadata subfields
- [ ] Error handling section added with clear error messages
- [ ] Checkpoint updated to "Return validated and artifacts verified (ACTUALLY EXECUTED)"

**Validation**:
- Test with plain text return (should fail with "Invalid JSON return")
- Test with missing status field (should fail with "Missing required field: status")
- Test with missing metadata.session_id (should fail with "Missing required metadata field: session_id")

---

### Phase 2: Implement Status Enum and Session ID Validation [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Implement Steps 3-4 of validation logic to reject invalid status values and session mismatches

**Tasks**:
1. Read validation-rules.md Steps 3-4 (lines 60-90)
2. Add to Stage 4 `<process>` section:
   - Step 3: Validate status enum (completed, partial, failed, blocked)
   - Step 4: Validate session_id matches expected value
3. Add error messages for invalid status and session_id mismatch
4. Document expected_session_id source (from delegation context)

**Acceptance Criteria**:
- [ ] Stage 4 validates status is one of: completed, partial, failed, blocked
- [ ] Stage 4 compares returned session_id with expected session_id
- [ ] Error message for invalid status includes valid values
- [ ] Error message for session_id mismatch includes expected and actual values

**Validation**:
- Test with invalid status "success" (should fail with "Invalid status: success")
- Test with session_id mismatch (should fail with "Session ID mismatch")
- Test with valid status "completed" (should pass this step)

---

### Phase 3: Implement Artifact Validation (CRITICAL) [NOT STARTED]

**Estimated Effort**: 2 hours

**Objective**: Implement Step 5 of validation logic to prevent phantom research

**Tasks**:
1. Read validation-rules.md Step 5 (lines 105-169)
2. Add to Stage 4 `<process>` section:
   - Step 5a: If status=completed, check artifacts array is non-empty
   - Step 5b: For each artifact path, verify file exists on disk
   - Step 5c: For each artifact path, verify file is non-empty (size > 0)
   - Step 5d: Log validation success with artifact count
3. Add error messages for:
   - Phantom research (status=completed, no artifacts)
   - Artifact not found (file doesn't exist)
   - Empty artifact (file size = 0)
4. Document that validation only applies to status=completed

**Acceptance Criteria**:
- [ ] Stage 4 checks artifacts array is non-empty if status=completed
- [ ] Stage 4 verifies each artifact file exists with [ -f "$path" ]
- [ ] Stage 4 verifies each artifact file is non-empty with [ -s "$path" ]
- [ ] Stage 4 logs "[PASS] {N} artifacts validated" on success
- [ ] Error message for phantom research is clear and actionable
- [ ] Validation skipped for partial/failed/blocked status

**Validation**:
- Test with status=completed, empty artifacts (should fail with "Phantom research detected")
- Test with status=completed, artifact file missing (should fail with "Artifact not found")
- Test with status=completed, artifact file empty (should fail with "Artifact is empty")
- Test with status=partial, empty artifacts (should pass - no validation)
- Test with status=completed, valid artifacts (should pass with "[PASS] 1 artifacts validated")

---

### Phase 4: Test Validation with Malformed Returns [NOT STARTED]

**Estimated Effort**: 1.5 hours

**Objective**: Verify validation rejects all known failure modes

**Tasks**:
1. Create test cases for each validation failure scenario:
   - Plain text return (not JSON)
   - Missing required field (status, summary, artifacts, metadata)
   - Missing metadata subfield (session_id, agent_type, delegation_depth, delegation_path)
   - Invalid status value ("success", "done", etc.)
   - Session ID mismatch
   - Phantom research (status=completed, no artifacts)
   - Missing artifact file
   - Empty artifact file
2. Test each scenario manually or with test script
3. Verify error messages are clear and actionable
4. Document test results

**Acceptance Criteria**:
- [ ] All 8 validation failure scenarios tested
- [ ] All scenarios produce expected error messages
- [ ] Error messages include recommendations for fixing
- [ ] No false positives (legitimate returns pass validation)
- [ ] Test results documented

**Validation**:
- Run each test case and verify expected error
- Verify error messages match validation-rules.md examples
- Verify orchestrator does not proceed to Stage 5 on validation failure

---

### Phase 5: Test All Workflow Commands and Update Documentation [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Verify validation works for all commands and update documentation

**Tasks**:
1. Test /research command with valid and invalid returns
2. Test /plan command with valid and invalid returns
3. Test /implement command with valid and invalid returns
4. Test /revise command with valid and invalid returns
5. Verify no regressions in normal operation
6. Update validation-rules.md:
   - Add note that validation is enforced by orchestrator Stage 4
   - Add examples of validation failures and error messages
   - Update "See Also" section to reference orchestrator Stage 4
7. Document any issues found and fixes applied

**Acceptance Criteria**:
- [ ] /research tested with valid return (passes)
- [ ] /research tested with invalid return (fails with clear error)
- [ ] /plan tested with valid return (passes)
- [ ] /plan tested with invalid return (fails with clear error)
- [ ] /implement tested with valid return (passes)
- [ ] /implement tested with invalid return (fails with clear error)
- [ ] /revise tested with valid return (passes)
- [ ] /revise tested with invalid return (fails with clear error)
- [ ] validation-rules.md updated with implementation details
- [ ] No regressions in normal operation

**Validation**:
- Run each workflow command with valid subagent return
- Run each workflow command with malformed return
- Verify validation catches all malformed returns
- Verify normal operations still work

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
- Orchestrator logs validation results

## Artifacts and Outputs

### Primary Artifacts

1. **Updated Orchestrator** (`.opencode/agent/orchestrator.md`)
   - Stage 4 rewritten with executable validation logic
   - Validation failure handling added
   - Checkpoint updated

2. **Updated Validation Rules** (`.opencode/context/core/system/validation-rules.md`)
   - Implementation details added
   - Examples of validation failures added
   - Reference to orchestrator Stage 4 added

### Supporting Artifacts

3. **Test Results Documentation**
   - Test cases executed
   - Results for each scenario
   - Issues found and fixes applied

4. **Git Commit**
   - All changes committed with message: "task 280: implement orchestrator Stage 4 validation to prevent phantom research"

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

- [ ] Implementation completed within 7 hours estimate
- [ ] All phases completed in order
- [ ] All acceptance criteria met
- [ ] Git commit created with all changes

## Dependencies

### Required Files

- `.opencode/agent/orchestrator.md` (orchestrator implementation)
- `.opencode/context/core/system/validation-rules.md` (validation logic reference)
- `.opencode/context/core/standards/subagent-return-format.md` (return format standard)

### Required Tools

- `jq` (JSON parsing and validation)
- Text editor (for updating orchestrator.md)
- Git (for committing changes)

### Required Knowledge

- Orchestrator architecture and stage flow
- Subagent return format standard
- Validation logic from validation-rules.md
- Bash scripting (for jq commands)

## Notes

### Research Integration

This plan integrates findings from research-001.md:

- **Finding 1**: Validation logic exists in validation-rules.md but is not executed → Phase 1-3 implement the logic
- **Finding 2**: Phantom research example (task 279) → Phase 3 specifically addresses this
- **Finding 3**: Vulnerability affects all workflow commands → Phase 5 tests all commands
- **Finding 4**: Return format standard is well-defined → Used as reference for validation
- **Finding 5**: Stage 4 is documentation-only → Phases 1-3 convert to executable logic

### Implementation Approach

Using **Approach 1 (Inline Validation Logic)** from research recommendations:
- All validation logic in orchestrator Stage 4 `<process>` section
- No external validation script
- Consistent with other orchestrator stages
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
- NOT proceed to Stage 5 (fail fast)

### Testing Strategy

- Test each validation step independently (unit testing)
- Test all workflow commands with validation enabled (integration testing)
- Test edge cases (partial status, empty artifacts, etc.)
- Verify no regressions in normal operation (regression testing)
