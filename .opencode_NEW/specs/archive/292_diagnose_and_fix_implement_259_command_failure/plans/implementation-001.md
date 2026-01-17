# Implementation Plan: Diagnose and Fix /implement 259 Command Failure

**Task**: 292  
**Status**: [NOT STARTED]  
**Created**: 2026-01-04  
**Estimated Effort**: 2-3 hours  
**Complexity**: Low-Medium  
**Language**: general  
**Priority**: High

---

## Metadata

- **Task Number**: 292
- **Task Title**: Diagnose and fix /implement 259 command failure - orchestrator unable to extract $ARGUMENTS
- **Research Integrated**: Yes (research-001.md)
- **Plan Version**: 1
- **Dependencies**: Task 281 (completed - fixed $ARGUMENTS typo)
- **Blocking**: None

---

## Overview

### Problem Statement

Task 292 reports that when running `/implement 259`, the orchestrator workflow fails at Stage 1 (PreflightValidation) while attempting to extract the `$ARGUMENTS` variable. The command output shows the orchestrator trying to run `echo "$ARGUMENTS"` as a bash command, which appears to hang or fail.

However, research reveals this may be a **misdiagnosis**:
1. Task 281 already fixed the typo in `/implement` command (line 34 now correctly has `$ARGUMENTS`)
2. Task 259 exists and is valid (status: [PLANNED], language: lean, ready for implementation)
3. The orchestrator does NOT run bash commands to extract $ARGUMENTS - it receives the value from OpenCode
4. The reported behavior suggests Claude is misinterpreting orchestrator instructions

### Scope

**In Scope**:
- Verify if `/implement 259` works after Task 281 fix
- If issue persists, clarify orchestrator Stage 1 instructions to prevent bash command execution
- Add explicit anti-pattern guidance to prevent Claude from running `echo "$ARGUMENTS"`
- Test fix with `/implement 259` command

**Out of Scope**:
- Fixing Task 259 implementation itself (separate task)
- Modifying OpenCode's $ARGUMENTS passing mechanism (already working)
- Changing command file structure (Task 281 already fixed)

### Constraints

- Must not break existing working commands (`/research`, `/plan`, `/revise`)
- Must maintain backward compatibility with orchestrator workflow
- Must follow orchestrator.md specification standards
- Changes must be minimal and targeted

### Definition of Done

- [ ] Verified whether `/implement 259` works after Task 281 fix
- [ ] If working: Task marked [COMPLETED] with note "Fixed by Task 281"
- [ ] If not working: Orchestrator instructions clarified to prevent bash command execution
- [ ] Anti-pattern guidance added to prevent `echo "$ARGUMENTS"` attempts
- [ ] `/implement 259` command executes successfully
- [ ] All existing commands (`/research`, `/plan`, `/revise`) still work
- [ ] Documentation updated with clarifications
- [ ] Changes committed to git

---

## Goals and Non-Goals

### Goals

1. **Verify Task 281 Fix**: Determine if Task 281's fix resolved the issue
2. **Clarify Instructions**: If issue persists, add explicit guidance to prevent bash command execution
3. **Prevent Misinterpretation**: Add anti-patterns to orchestrator Stage 1 to prevent Claude from running `echo "$ARGUMENTS"`
4. **Enable `/implement 259`**: Ensure `/implement 259` command works end-to-end

### Non-Goals

1. **Not** implementing Task 259 itself (separate implementation task)
2. **Not** modifying OpenCode's $ARGUMENTS passing mechanism (already working)
3. **Not** restructuring orchestrator workflow (out of scope)
4. **Not** changing command file formats (Task 281 already fixed)

---

## Risks and Mitigations

### Risk 1: Issue May Already Be Fixed

**Description**: Task 281 may have already resolved the issue. Implementing unnecessary changes could introduce new bugs.

**Likelihood**: High  
**Impact**: Medium  
**Mitigation**: 
- Phase 1 verifies if issue still exists before making any changes
- If issue is resolved, mark task complete without modifications
- Document verification results

### Risk 2: Clarifications May Not Prevent Misinterpretation

**Description**: Adding explicit anti-patterns may not prevent Claude from misinterpreting instructions in all cases.

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Use multiple clarification strategies (explicit notes, examples, anti-patterns)
- Test with actual `/implement 259` command
- Monitor for recurrence in future commands

### Risk 3: Changes May Break Existing Commands

**Description**: Modifying orchestrator Stage 1 instructions could break `/research`, `/plan`, or `/revise` commands.

**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Make changes additive (add clarifications, don't remove existing logic)
- Test all workflow commands after changes
- Use git for easy rollback if needed

---

## Implementation Phases

### Phase 1: Verification - Determine if Issue Still Exists [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Verify whether `/implement 259` works after Task 281 fix.

**Tasks**:
1. Verify Task 281 fix is in place:
   ```bash
   sed -n '34p' .opencode/command/implement.md
   # Should show: "Parse task number or range from $ARGUMENTS"
   ```

2. Attempt `/implement 259` command and observe behavior:
   - Does it complete Stage 1 (PreflightValidation)?
   - Does it extract task number correctly?
   - Does it proceed to Stage 2 (DetermineRouting)?
   - Does it route to lean-implementation-agent?

3. Document results:
   - If successful: Create verification report showing issue is resolved
   - If failed: Capture exact error output and failure point

**Acceptance Criteria**:
- [ ] Task 281 fix verified in place
- [ ] `/implement 259` command attempted
- [ ] Results documented (success or failure)
- [ ] Decision made: proceed to Phase 2 or mark task complete

**Validation**:
- Verification report created with clear success/failure determination
- If successful, task can be marked [COMPLETED] with note "Fixed by Task 281"

---

### Phase 2: Analysis - Identify Root Cause (If Issue Persists) [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: If Phase 1 shows issue persists, identify exact root cause.

**Tasks**:
1. Analyze orchestrator Stage 1, Step 2 instructions:
   - Read `.opencode/agent/orchestrator.md` Stage 1, Step 2
   - Identify ambiguous language that could cause misinterpretation
   - Look for missing clarifications about $ARGUMENTS being pre-substituted

2. Compare with working commands:
   - How do `/research`, `/plan`, `/revise` handle $ARGUMENTS?
   - What makes them work correctly?
   - What's different about `/implement`?

3. Identify specific clarifications needed:
   - Where to add "DO NOT execute bash commands" note
   - Where to add "$ARGUMENTS is pre-substituted by OpenCode" note
   - Where to add anti-pattern examples

**Acceptance Criteria**:
- [ ] Root cause identified (orchestrator instruction ambiguity)
- [ ] Specific clarifications identified
- [ ] Comparison with working commands completed
- [ ] Plan for Phase 3 clarifications ready

**Validation**:
- Analysis document created with specific recommendations
- Clarifications are targeted and minimal

---

### Phase 3: Implementation - Clarify Orchestrator Instructions [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Add explicit clarifications to orchestrator Stage 1 to prevent bash command execution.

**Tasks**:
1. Update `.opencode/agent/orchestrator.md` Stage 1, Step 2:
   
   Add clarification block before existing logic:
   ```markdown
   Step 2: Parse and validate arguments (CRITICAL STEP - DO NOT SKIP)
   
   IMPORTANT: $ARGUMENTS is provided by OpenCode as a pre-substituted value.
   DO NOT execute bash commands to extract it. Parse it logically as a string.
   
   ANTI-PATTERNS (DO NOT DO):
   - DO NOT run: echo "$ARGUMENTS"
   - DO NOT run: grep, sed, awk on $ARGUMENTS
   - DO NOT use bash tool to extract $ARGUMENTS
   
   CORRECT APPROACH:
   - $ARGUMENTS is already available as a string value from OpenCode
   - Simply parse it logically (split on whitespace, extract first token)
   - Use string operations, not bash commands
   
   - IF command_type == "task-based":
     a. Check if $ARGUMENTS is empty or whitespace only
        * $ARGUMENTS is already available as a string value
        * Simply check: if $ARGUMENTS == "" or $ARGUMENTS.strip() == ""
        * If YES: ABORT with error "Task number required for /{command} command"
     ...
   ```

2. Add example showing correct parsing:
   ```markdown
   Example (CORRECT):
   - User invokes: /implement 259
   - OpenCode passes: $ARGUMENTS = "259"
   - Orchestrator receives: "259" (already substituted)
   - Orchestrator parses: Split "259" on whitespace → ["259"]
   - Orchestrator extracts: First token = "259"
   - Orchestrator validates: "259" matches regex ^[1-9][0-9]*$
   - Orchestrator proceeds: To Stage 2 with task_number = 259
   ```

3. Verify changes don't break existing logic:
   - Read through modified section
   - Ensure all existing steps still present
   - Ensure clarifications are additive, not replacing

**Acceptance Criteria**:
- [ ] Clarification block added to orchestrator.md Stage 1, Step 2
- [ ] Anti-patterns documented
- [ ] Correct approach documented
- [ ] Example added showing correct parsing
- [ ] Existing logic preserved

**Validation**:
- Modified orchestrator.md follows specification standards
- Changes are minimal and targeted
- No existing logic removed

---

### Phase 4: Testing - Verify Fix Works [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Test that `/implement 259` works after clarifications.

**Tasks**:
1. Test `/implement 259` command:
   - Verify Stage 1 (PreflightValidation) completes
   - Verify task number extracted correctly (259)
   - Verify Stage 2 (DetermineRouting) routes to lean-implementation-agent
   - Verify no bash command execution attempts
   - Verify no hanging or failures

2. Test existing commands for regression:
   - Test `/research 292` (verify still works)
   - Test `/plan 292` (verify still works)
   - Test `/revise 277` (verify still works)

3. Document test results:
   - Create test report showing all commands work
   - Note any issues or unexpected behavior
   - Verify fix is complete

**Acceptance Criteria**:
- [ ] `/implement 259` command works end-to-end
- [ ] No bash command execution attempts observed
- [ ] All existing commands (`/research`, `/plan`, `/revise`) still work
- [ ] Test report created

**Validation**:
- Test report shows all commands working
- No regressions introduced
- Fix is complete and verified

---

### Phase 5: Documentation and Cleanup [NOT STARTED]

**Estimated Effort**: 0.5 hours

**Objective**: Update documentation and commit changes.

**Tasks**:
1. Update task documentation:
   - Update TODO.md task 292 status to [COMPLETED]
   - Add completion note with fix summary
   - Link to verification/test reports

2. Update state.json:
   - Mark task 292 as completed
   - Add completion timestamp
   - Link implementation artifacts

3. Create git commit:
   - Stage changes: orchestrator.md, TODO.md, state.json
   - Commit message: "task 292: clarify orchestrator $ARGUMENTS handling to prevent bash command execution"
   - Verify commit includes all changes

4. Create implementation summary:
   - Summarize verification results (Phase 1)
   - Summarize clarifications added (Phase 3)
   - Summarize test results (Phase 4)
   - Note actual effort vs estimated

**Acceptance Criteria**:
- [ ] TODO.md updated to [COMPLETED]
- [ ] state.json updated
- [ ] Git commit created
- [ ] Implementation summary created

**Validation**:
- All documentation updated
- Git commit follows standards
- Implementation summary is complete

---

## Testing and Validation

### Test Cases

#### Test Case 1: Verify Task 281 Fix
- **Input**: Read line 34 of `.opencode/command/implement.md`
- **Expected**: Line contains "from $ARGUMENTS" (not "from arguments")
- **Validation**: Task 281 fix is in place

#### Test Case 2: Test /implement 259 Command
- **Input**: `/implement 259`
- **Expected**: 
  - Stage 1 completes successfully
  - Task number 259 extracted
  - Routes to lean-implementation-agent
  - No bash command execution attempts
- **Validation**: Command works end-to-end

#### Test Case 3: Regression Test /research
- **Input**: `/research 292`
- **Expected**: Command works as before
- **Validation**: No regression

#### Test Case 4: Regression Test /plan
- **Input**: `/plan 292`
- **Expected**: Command works as before
- **Validation**: No regression

#### Test Case 5: Regression Test /revise
- **Input**: `/revise 277`
- **Expected**: Command works as before
- **Validation**: No regression

### Validation Criteria

- [ ] All test cases pass
- [ ] No bash command execution attempts observed
- [ ] No regressions in existing commands
- [ ] `/implement 259` works end-to-end

---

## Artifacts and Outputs

### Primary Artifacts

1. **Verification Report** (Phase 1):
   - Path: `specs/292_diagnose_and_fix_implement_259_command_failure/reports/verification-001.md`
   - Content: Results of `/implement 259` test after Task 281 fix
   - Status: [NOT STARTED]

2. **Modified Orchestrator** (Phase 3, if needed):
   - Path: `.opencode/agent/orchestrator.md`
   - Content: Clarified Stage 1, Step 2 instructions
   - Status: [NOT STARTED]

3. **Test Report** (Phase 4):
   - Path: `specs/292_diagnose_and_fix_implement_259_command_failure/reports/test-001.md`
   - Content: Test results for `/implement 259` and regression tests
   - Status: [NOT STARTED]

4. **Implementation Summary** (Phase 5):
   - Path: `specs/292_diagnose_and_fix_implement_259_command_failure/summaries/implementation-summary-20260104.md`
   - Content: Summary of verification, clarifications, and test results
   - Status: [NOT STARTED]

### Supporting Artifacts

- Git commit with changes
- Updated TODO.md and state.json

---

## Rollback/Contingency

### Rollback Plan

If clarifications cause issues:

1. **Immediate Rollback**:
   ```bash
   git revert <commit_hash>
   ```

2. **Verify Rollback**:
   - Test `/research`, `/plan`, `/revise` commands
   - Verify all working as before

3. **Alternative Approach**:
   - Instead of modifying orchestrator.md, modify `/implement` command file
   - Add clarification note in command frontmatter
   - Test with `/implement 259`

### Contingency Plan

If issue persists after clarifications:

1. **Escalate to OpenCode**:
   - Report issue to OpenCode maintainers
   - Provide reproduction steps
   - Request fix in OpenCode's $ARGUMENTS passing

2. **Workaround**:
   - Add explicit validation in `/implement` command
   - Check if $ARGUMENTS is available before proceeding
   - Provide clear error message if not

---

## Success Metrics

### Primary Metrics

1. **Command Success Rate**: `/implement 259` completes successfully (100%)
2. **No Bash Execution**: Zero bash command execution attempts for $ARGUMENTS extraction
3. **No Regressions**: All existing commands (`/research`, `/plan`, `/revise`) work (100%)

### Secondary Metrics

1. **Clarity**: Orchestrator instructions are clear and unambiguous
2. **Maintainability**: Clarifications are well-documented and easy to understand
3. **Effort**: Actual effort ≤ estimated effort (2-3 hours)

### Success Criteria

- [ ] `/implement 259` works end-to-end
- [ ] No bash command execution attempts
- [ ] No regressions in existing commands
- [ ] Clarifications are clear and well-documented
- [ ] Actual effort within estimate

---

## Notes

### Research Integration

Research report (research-001.md) findings integrated:
- Task 281 fix verified (line 34 now has `$ARGUMENTS`)
- Task 259 validated (exists, status [PLANNED], language lean)
- Orchestrator does NOT execute bash commands (by design)
- Reported symptom suggests Claude misinterpretation

### Key Decisions

1. **Verification First**: Phase 1 verifies if issue still exists before making changes
2. **Minimal Changes**: If changes needed, they are additive clarifications only
3. **Anti-Patterns**: Explicit anti-patterns added to prevent bash command execution
4. **Testing**: Comprehensive testing including regression tests

### Assumptions

1. Task 281 fix is in place and correct
2. OpenCode's $ARGUMENTS passing mechanism works correctly
3. Issue is orchestrator instruction ambiguity (if it persists)
4. Clarifications will prevent Claude misinterpretation

---

## Appendix

### Related Tasks

- **Task 281**: Fixed $ARGUMENTS typo in `/implement` command (completed)
- **Task 259**: Automation Tactics implementation (planned, ready for `/implement`)

### References

- Research Report: `specs/292_diagnose_and_fix_implement_259_command_failure/reports/research-001.md`
- Orchestrator Specification: `.opencode/agent/orchestrator.md`
- Command Argument Handling: `.opencode/context/core/standards/command-argument-handling.md`
