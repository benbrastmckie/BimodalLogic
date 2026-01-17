# Implementation Plan: Fix Systematic Preflight Failures in Workflow Commands (Revised)

## Metadata

- **Task**: 321 - Fix workflow command preflight status update failures
- **Status**: [NOT STARTED]
- **Estimated Effort**: 5 hours
- **Language**: meta
- **Priority**: High
- **Created**: 2026-01-05
- **Plan Version**: 2
- **Previous Version**: implementation-001.md
- **Complexity**: Medium
- **Dependencies**: None
- **Blocking**: None

## Revision Summary

**Changes from Version 1**:
1. **Integrated Task 320 Findings**: Incorporated research on postflight failures showing same root cause (delegation instructions not executed consistently)
2. **Updated Failure Frequency**: Changed from "occasional" to "consistent" failures based on user observation
3. **Added Error Logging**: All preflight/postflight failures now logged to `specs/errors.state` for debugging
4. **Reduced Complexity**: Removed timeout protection phase, streamlined validation to surgical checkpoints only
5. **Context Window Hypothesis**: Added investigation of why /plan works better (possibly due to context window priming from /research)
6. **Unified Approach**: Treat preflight and postflight as same problem with same solution

**User Feedback Incorporated**:
- "I get preflight failures consistently, rather than merely occasionally"
- "Consider task 320 in order to integrate appropriately with postflight failures which I get consistently"
- "I do notice that /plan seems to work much better for both preflight and postflight, but maybe this is because I use /plan after running /research in the same context window?"
- "Any failures should be logged to errors.state for debugging purposes"
- "Important to reduce the complexity wherever possible to avoid slowing down the workflow"

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) are experiencing **consistent** (not occasional) preflight AND postflight failures where step_0_preflight and step_4_postflight/step_7 instructions in subagent markdown files are **not being executed** by AI agents. This causes:

1. **Preflight Failures**: Status markers remain stale (e.g., [NOT STARTED] instead of [RESEARCHING]) when work begins
2. **Postflight Failures**: Artifacts created successfully but status not updated and artifacts not linked in TODO.md
3. **State Synchronization Failures**: TODO.md and state.json become desynchronized
4. **Silent Failures**: No error logging or debugging information captured

**Root Cause** (Unified for Preflight and Postflight): Documentation-vs-execution gap. Subagent markdown files contain instructions to delegate to status-sync-manager and git-workflow-manager, but these instructions are **not consistently executed** by AI agents reading the markdown.

**Interesting Observation**: /plan command appears to work better for both preflight and postflight. Hypothesis: Context window priming from /research in same session may improve instruction execution.

### Scope

**In Scope**:
- Debug why preflight AND postflight instructions are not being executed consistently
- Create standardized status marker convention file (`.opencode/context/system/status-markers.md`)
- Add surgical verification checkpoints to confirm preflight/postflight execution
- Implement error logging to `specs/errors.state` for all failures
- Investigate context window hypothesis (why /plan works better)
- Fix root cause with minimal complexity increase

**Out of Scope**:
- Extensive validation checks that bloat complexity
- Timeout protection mechanisms (per user guidance)
- Complete workflow redesign
- Metrics, monitoring, or checkpoint systems (future work)

### Constraints

**User-Specified Constraints**:
1. PRIMARY FOCUS: Debug why preflight/postflight instructions are NOT being executed
2. AVOID: Adding tons of validation checks that bloat complexity and slow workflow
3. ALLOW: Minimal surgical verification checkpoints to confirm execution
4. AVOID: Useless timeout protection that causes more issues than it solves
5. REQUIRED: Create `.opencode/context/system/status-markers.md` for consistent status marker conventions
6. REQUIRED: Log all failures to `specs/errors.state` for debugging

### Definition of Done

- [ ] Root cause of preflight/postflight non-execution identified and documented
- [ ] Status marker convention file created at `.opencode/context/system/status-markers.md`
- [ ] Surgical verification checkpoints added to confirm preflight/postflight execution
- [ ] Error logging to `specs/errors.state` implemented for all failures
- [ ] Context window hypothesis investigated and documented
- [ ] Preflight/postflight execution gap fixed in all 6 workflow subagents
- [ ] All changes tested with at least one workflow command
- [ ] Documentation updated to reflect fixes
- [ ] No new complexity or timeout mechanisms added

### Research Integration

This plan integrates findings from 2 research reports:

**Integrated Reports**:
- **321/research-001.md** (2026-01-05): Comprehensive analysis of preflight status update failures
  - Key Finding: Subagent markdown files contain step_0_preflight instructions to delegate to status-sync-manager, but these instructions are not being executed by AI agents (documentation-vs-execution gap)
  - Key Finding: Commands do not validate that preflight execution occurred (no validation in Stage 3)
  - Key Finding: State synchronization failures are silent (Task 314 shows TODO.md updated but state.json not updated)
  - Recommendation: Focus on making preflight instructions more concrete and executable, add minimal validation to catch failures

- **320/research-001.md** (2026-01-05): Analysis of postflight failures causing missing artifact links
  - Key Finding: Postflight steps ARE defined in subagents but delegation to status-sync-manager and git-workflow-manager fails silently
  - Key Finding: Evidence of partial postflight success (Task 314: artifact created, status updated, but git commit missing)
  - Key Finding: Same documentation-vs-execution gap as preflight
  - Recommendation: Unified fix for both preflight and postflight delegation issues

**Unified Insight**: Preflight and postflight failures have the **same root cause** - delegation instructions in markdown are not consistently executed by AI agents. This suggests a single fix can address both issues.

## Goals and Non-Goals

### Goals

1. **Identify root cause** of why preflight/postflight delegation instructions are not executed consistently
2. **Fix delegation execution gap** with minimal complexity increase
3. **Standardize status markers** via `.opencode/context/system/status-markers.md`
4. **Add surgical verification** at critical checkpoints to confirm execution
5. **Implement error logging** to `specs/errors.state` for debugging
6. **Investigate context window hypothesis** to understand why /plan works better
7. **Maintain workflow speed** - no bloat, no unnecessary checks

### Non-Goals

1. Add extensive validation checks throughout the workflow
2. Implement timeout protection mechanisms
3. Redesign entire workflow architecture
4. Add metrics, monitoring, or checkpoint systems (future work)
5. Fix git-workflow-manager failures (separate issue, non-critical per research)

## Risks and Mitigations

### Risk 1: Root Cause May Be Architectural

**Risk**: The documentation-vs-execution gap may be inherent to how AI agents process markdown instructions

**Likelihood**: High (consistent failures suggest systemic issue)  
**Impact**: High  
**Mitigation**: 
- Investigate multiple potential causes (instruction clarity, delegation syntax, context window effects)
- Test different instruction formats to find what works
- Document findings for future reference
- If architectural, propose minimal viable fix (e.g., explicit delegation examples, verification checkpoints)

### Risk 2: Surgical Validation May Miss Edge Cases

**Risk**: Adding only surgical validation may not catch all failure modes

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Focus validation on critical checkpoints (preflight completion, postflight completion)
- Use fail-fast approach to surface issues quickly
- Log all failures to errors.state for post-mortem analysis
- Monitor for new failure patterns post-fix

### Risk 3: Context Window Hypothesis May Be Incorrect

**Risk**: /plan may work better for reasons unrelated to context window priming

**Likelihood**: Medium  
**Impact**: Low  
**Mitigation**:
- Test hypothesis with controlled experiments
- Document alternative explanations
- Don't over-optimize for unproven hypothesis
- Focus on root cause fix that works regardless of context

### Risk 4: errors.state May Grow Unbounded

**Risk**: Error logging without rotation may cause file to grow too large

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Use append-only JSON lines format for easy parsing
- Document manual cleanup procedure
- Consider rotation in future work (out of scope for this task)

## Implementation Phases

### Phase 1: Root Cause Investigation and Context Window Hypothesis [NOT STARTED]

**Objective**: Debug why preflight/postflight delegation instructions are not being executed consistently, and investigate why /plan works better

**Tasks**:
1. **Analyze Current Delegation Instruction Format**:
   - Review step_0_preflight in all 6 subagents (researcher, planner, implementer, lean-research-agent, lean-planner, lean-implementation-agent)
   - Review step_4_postflight/step_7 in all 6 subagents
   - Compare instruction clarity, specificity, and delegation syntax
   - Identify patterns in what works vs. what doesn't

2. **Investigate Context Window Hypothesis**:
   - Test /research alone (fresh context) vs. /plan after /research (primed context)
   - Measure preflight/postflight success rates in both scenarios
   - Analyze if context window contains delegation examples that prime execution
   - Document findings with specific examples

3. **Test Delegation Execution**:
   - Create minimal test case: subagent with explicit delegation instruction
   - Test if delegation occurs when instruction is concrete vs. abstract
   - Test if delegation occurs when example syntax is provided
   - Document what makes instructions executable vs. non-executable

4. **Analyze Failure Patterns**:
   - Review evidence from Task 314 (partial postflight success)
   - Review evidence from Task 315 (full success)
   - Identify what differs between success and failure cases
   - Document failure patterns

5. **Document Root Cause Hypothesis**:
   - Synthesize findings into clear root cause hypothesis
   - Provide concrete examples of successful vs. failed delegation
   - Propose minimal fix based on findings

**Acceptance Criteria**:
- Root cause hypothesis documented with evidence
- Context window hypothesis tested and results documented
- Specific instruction format issues identified
- Concrete examples of successful vs. failed delegation
- Clear understanding of what makes instructions executable
- Minimal fix proposed

**Estimated Effort**: 1.5 hours

**Validation**:
- Findings documented in phase notes
- Hypothesis testable with concrete examples
- Proposed fix is minimal and surgical

---

### Phase 2: Create Status Marker Convention File and Error Logging Infrastructure [NOT STARTED]

**Objective**: Create `.opencode/context/system/status-markers.md` as single source of truth for status marker conventions, and implement error logging to `specs/errors.state`

**Tasks**:
1. **Create Status Marker Convention File**:
   - Create `.opencode/context/system/` directory if it doesn't exist
   - Extract all status marker definitions from state-management.md and status-transitions.md
   - Create status-markers.md with:
     - Complete list of all status markers (in-progress and completion)
     - Valid status transitions
     - Usage guidelines for each marker
     - Mapping between TODO.md markers (e.g., [RESEARCHING]) and state.json values (e.g., "researching")
   - Update state-management.md to reference status-markers.md
   - Update status-transitions.md to reference status-markers.md
   - Verify no inconsistencies between files

2. **Implement Error Logging Infrastructure**:
   - Create `specs/errors.state` file with JSON lines format
   - Define error log entry schema:
     ```json
     {
       "timestamp": "2026-01-05T18:49:00Z",
       "error_type": "preflight_failure" | "postflight_failure" | "delegation_failure",
       "task_number": 321,
       "command": "/research" | "/plan" | "/implement" | "/revise",
       "subagent": "researcher" | "planner" | "implementer" | ...,
       "step": "step_0_preflight" | "step_4_postflight" | "step_7",
       "delegation_target": "status-sync-manager" | "git-workflow-manager",
       "error_message": "Status update delegation failed",
       "context": {
         "session_id": "sess_1234567890_abc123",
         "expected_status": "researching",
         "actual_status": "not_started"
       }
     }
     ```
   - Create helper function for logging errors (can be bash function or inline code)
   - Document error log format in `.opencode/context/system/error-logging.md`

**Acceptance Criteria**:
- `.opencode/context/system/status-markers.md` created
- All status markers documented with clear definitions
- Valid transitions documented
- Cross-references added to state-management.md and status-transitions.md
- No duplicate or conflicting definitions
- `specs/errors.state` created with proper schema
- Error logging infrastructure ready for use
- Documentation complete

**Estimated Effort**: 1 hour

**Validation**:
- Files exist and are well-formatted
- All status markers from research reports included
- Cross-references work correctly
- No inconsistencies found
- Error log schema is clear and parseable

---

### Phase 3: Fix Delegation Execution Gap in Subagents [NOT STARTED]

**Objective**: Update step_0_preflight and step_4_postflight/step_7 instructions in all 6 subagents to ensure consistent execution based on Phase 1 findings

**Tasks**:
1. **Determine Minimal Fix Based on Phase 1 Findings**:
   - Review root cause hypothesis from Phase 1
   - Identify minimal changes needed to ensure delegation execution
   - Possible fixes (based on findings):
     - Add explicit delegation syntax examples
     - Make instructions more concrete and imperative
     - Add "CRITICAL: You MUST execute this step" markers
     - Provide step-by-step delegation template
     - Add explicit validation requirements

2. **Update Preflight Instructions in All 6 Subagents**:
   - researcher.md (step_0_preflight)
   - planner.md (step_0_preflight)
   - implementer.md (step_0_preflight)
   - lean-research-agent.md (step_0_preflight)
   - lean-planner.md (step_0_preflight)
   - lean-implementation-agent.md (step_0_preflight)
   
   Changes:
   - Make delegation instructions more concrete and executable
   - Add explicit delegation syntax examples
   - Add clear validation requirements
   - Add error logging on failure
   - Keep changes minimal - focus on execution, not documentation bloat

3. **Update Postflight Instructions in All 6 Subagents**:
   - researcher.md (step_4_postflight)
   - planner.md (step_7)
   - implementer.md (step_4_postflight)
   - lean-research-agent.md (step_7)
   - lean-planner.md (step_7)
   - lean-implementation-agent.md (step_7)
   
   Changes:
   - Apply same fixes as preflight
   - Ensure status-sync-manager delegation is explicit
   - Ensure git-workflow-manager delegation is explicit
   - Add error logging on failure
   - Keep git failures non-critical (per research findings)

4. **Add Error Logging to All Delegation Points**:
   - On preflight delegation failure: Log to errors.state with error_type="preflight_failure"
   - On postflight delegation failure: Log to errors.state with error_type="postflight_failure"
   - Include all relevant context (task_number, session_id, expected vs. actual status)

**Acceptance Criteria**:
- All 6 subagents updated with improved preflight instructions
- All 6 subagents updated with improved postflight instructions
- Instructions are concrete and executable
- Delegation syntax is clear and unambiguous
- Validation requirements are explicit
- Error logging added to all delegation points
- No unnecessary complexity added
- Changes are consistent across all subagents

**Estimated Effort**: 1.5 hours

**Validation**:
- All 12 instruction blocks updated (6 preflight + 6 postflight)
- Instructions follow consistent format
- Error logging code is correct
- No regression in existing functionality

---

### Phase 4: Add Surgical Verification Checkpoints [NOT STARTED]

**Objective**: Add minimal surgical verification checkpoints to workflow commands to confirm preflight/postflight execution and log failures

**Tasks**:
1. **Identify Strategic Checkpoint Locations**:
   - Preflight checkpoint: After subagent delegation, before work begins
   - Postflight checkpoint: After subagent returns, before relaying result
   - Location: Command Stage 3 (ValidateReturn)

2. **Design Surgical Verification Logic**:
   - Verification should be fast (<100ms)
   - Verification should be minimal (single check per checkpoint)
   - Verification should fail fast with clear error message
   - Verification should log failures to errors.state
   
   Preflight Verification:
   ```bash
   # After subagent delegation, check if status was updated
   current_status=$(jq -r --arg num "$task_number" \
     '.active_projects[] | select(.project_number == ($num | tonumber)) | .status' \
     specs/state.json)
   
   if [[ "$current_status" != "researching" && "$current_status" != "researched" ]]; then
     # Log error to errors.state
     echo "{\"timestamp\":\"$(date -Iseconds)\",\"error_type\":\"preflight_failure\",\"task_number\":$task_number,\"command\":\"/research\",\"subagent\":\"researcher\",\"step\":\"step_0_preflight\",\"delegation_target\":\"status-sync-manager\",\"error_message\":\"Preflight status update did not occur\",\"context\":{\"session_id\":\"$session_id\",\"expected_status\":\"researching\",\"actual_status\":\"$current_status\"}}" >> specs/errors.state
     
     # Fail fast
     echo "ERROR: Preflight verification failed - status not updated to [RESEARCHING]"
     echo "Expected: researching or researched"
     echo "Actual: $current_status"
     echo "Logged to errors.state for debugging"
     exit 1
   fi
   ```
   
   Postflight Verification:
   ```bash
   # After subagent returns, verify artifacts are linked in TODO.md
   if [[ "$status" == "completed" ]]; then
     artifact_count=$(echo "$subagent_return" | jq '.artifacts | length')
     if [[ "$artifact_count" -gt 0 ]]; then
       # Verify first artifact is linked in TODO.md
       first_artifact=$(echo "$subagent_return" | jq -r '.artifacts[0].path')
       if ! grep -q "$first_artifact" specs/TODO.md; then
         # Log error to errors.state
         echo "{\"timestamp\":\"$(date -Iseconds)\",\"error_type\":\"postflight_failure\",\"task_number\":$task_number,\"command\":\"/research\",\"subagent\":\"researcher\",\"step\":\"step_4_postflight\",\"delegation_target\":\"status-sync-manager\",\"error_message\":\"Artifact not linked in TODO.md\",\"context\":{\"session_id\":\"$session_id\",\"artifact_path\":\"$first_artifact\"}}" >> specs/errors.state
         
         # Fail fast
         echo "ERROR: Postflight verification failed - artifact not linked in TODO.md"
         echo "Artifact: $first_artifact"
         echo "Logged to errors.state for debugging"
         exit 1
       fi
     fi
   fi
   ```

3. **Implement Verification in /research Command**:
   - Add preflight verification to Stage 3 (ValidateReturn)
   - Add postflight verification to Stage 3 (ValidateReturn)
   - Test verification catches failures
   - Test verification passes when execution succeeds

4. **Replicate to Other Commands (if time permits)**:
   - /plan command
   - /implement command
   - /revise command
   - Use same verification logic, adjust for command-specific status markers

**Acceptance Criteria**:
- Surgical verification checkpoints designed
- Verification logic is minimal (<20 lines per checkpoint)
- Verification is fast (<100ms overhead)
- Verification logs failures to errors.state
- Verification fails fast with clear error messages
- At least /research command has verification implemented
- Verification tested and working

**Estimated Effort**: 1 hour

**Validation**:
- Verification code added to command files
- Test shows verification catches preflight failure
- Test shows verification catches postflight failure
- Test shows verification passes when execution succeeds
- Error messages are clear and actionable
- errors.state contains logged failures

---

### Phase 5: Testing and Verification [NOT STARTED]

**Objective**: Test all fixes with real workflow commands and verify preflight/postflight execution works consistently

**Tasks**:
1. **Create Test Task**:
   - Add test task to TODO.md (e.g., task 322)
   - Use for testing workflow commands

2. **Test /research Command**:
   - Run /research on test task
   - Verify preflight: status updates to [RESEARCHING] immediately
   - Verify postflight: status updates to [RESEARCHED] on completion
   - Verify postflight: artifact linked in TODO.md
   - Verify state.json synchronized with TODO.md
   - Check errors.state for any logged failures

3. **Test Verification Checkpoints**:
   - Simulate preflight failure (comment out delegation in subagent)
   - Verify checkpoint catches failure and logs to errors.state
   - Verify clear error message displayed
   - Restore delegation
   - Simulate postflight failure (comment out delegation in subagent)
   - Verify checkpoint catches failure and logs to errors.state
   - Verify clear error message displayed
   - Restore delegation

4. **Test Context Window Hypothesis**:
   - Test /research alone (fresh context)
   - Test /plan after /research (primed context)
   - Compare preflight/postflight success rates
   - Document findings

5. **Test Other Commands (if time permits)**:
   - /plan command
   - /implement command
   - Verify consistent behavior across commands

6. **Review errors.state**:
   - Check all logged errors are properly formatted
   - Verify error log is parseable as JSON lines
   - Document any issues found

**Acceptance Criteria**:
- All tests pass successfully
- Preflight execution confirmed for tested commands
- Postflight execution confirmed for tested commands
- Verification checkpoints catch simulated failures
- errors.state contains properly formatted error logs
- No regressions detected
- Test results documented

**Estimated Effort**: 1 hour

**Validation**:
- Test task created and executed
- Status updates verified in both TODO.md and state.json
- Artifact linking verified
- Verification tests pass
- errors.state is valid JSON lines
- No errors or warnings in execution
- Test results documented in phase notes

---

### Phase 6: Documentation and Cleanup [NOT STARTED]

**Objective**: Update documentation to reflect fixes, document root cause findings, and clean up any temporary changes

**Tasks**:
1. **Document Root Cause Findings**:
   - Create `specs/321_fix_workflow_command_preflight_status_update_failures/root-cause-analysis.md`
   - Document what was found in Phase 1 investigation
   - Document context window hypothesis findings
   - Document what fix was applied and why it works
   - Provide recommendations for future instruction writing

2. **Update Affected Documentation**:
   - Update state-management.md with cross-reference to status-markers.md
   - Update status-transitions.md with cross-reference to status-markers.md
   - Update any subagent documentation that references preflight/postflight
   - Document error logging in `.opencode/context/system/error-logging.md`

3. **Clean Up Test Artifacts**:
   - Remove test task from TODO.md (if created)
   - Clean up any temporary test files
   - Review errors.state and document any patterns found

4. **Prepare Summary**:
   - Summarize all changes made
   - Document effort spent per phase
   - List all files modified
   - Prepare commit message

5. **Final Verification**:
   - Review all changes for consistency
   - Verify no temporary code left behind
   - Verify all documentation is accurate
   - Verify errors.state is in good state

**Acceptance Criteria**:
- Root cause analysis documented
- All documentation updated
- No temporary files left behind
- Changes are consistent and well-documented
- errors.state is clean and parseable
- Ready for git commit

**Estimated Effort**: 0.5 hours

**Validation**:
- Documentation complete and accurate
- No temporary files remain
- All references updated
- Changes ready for commit
- errors.state is valid

---

## Testing and Validation

### Unit Testing

**Not applicable** - This is a meta-level workflow fix, not code implementation

### Integration Testing

1. **Preflight Execution Test**:
   - Run /research on test task
   - Verify status updates to [RESEARCHING] immediately
   - Verify state.json synchronized
   - Check errors.state for any failures

2. **Postflight Execution Test**:
   - Run /research on test task
   - Verify status updates to [RESEARCHED] on completion
   - Verify artifact linked in TODO.md
   - Verify state.json synchronized
   - Check errors.state for any failures

3. **Verification Checkpoint Test**:
   - Simulate preflight failure
   - Verify checkpoint catches failure
   - Verify error logged to errors.state
   - Verify clear error message
   - Simulate postflight failure
   - Verify checkpoint catches failure
   - Verify error logged to errors.state
   - Verify clear error message

4. **Context Window Hypothesis Test**:
   - Test /research alone (fresh context)
   - Test /plan after /research (primed context)
   - Compare success rates
   - Document findings

5. **Multi-Command Test**:
   - Test /research, /plan, and /implement
   - Verify consistent behavior across commands
   - Verify no regressions

### Acceptance Testing

1. **User Workflow Test**:
   - Complete full workflow: /research → /plan → /implement
   - Verify status updates at each stage
   - Verify state synchronization throughout
   - Verify no silent failures
   - Check errors.state for any logged failures

2. **Error Logging Test**:
   - Review errors.state after testing
   - Verify all errors are properly formatted
   - Verify error log is parseable
   - Verify error messages are actionable

## Artifacts and Outputs

### Primary Artifacts

1. **.opencode/context/system/status-markers.md**
   - Single source of truth for status marker conventions
   - Complete list of all markers and transitions
   - Usage guidelines

2. **specs/errors.state**
   - Error log file for debugging preflight/postflight failures
   - JSON lines format for easy parsing
   - Contains all logged failures with context

3. **.opencode/context/system/error-logging.md**
   - Documentation for error logging infrastructure
   - Error log schema definition
   - Usage guidelines

4. **Updated Subagent Files** (6 files):
   - researcher.md (preflight + postflight)
   - planner.md (preflight + postflight)
   - implementer.md (preflight + postflight)
   - lean-research-agent.md (preflight + postflight)
   - lean-planner.md (preflight + postflight)
   - lean-implementation-agent.md (preflight + postflight)

5. **Updated Command Files** (1-4 files):
   - research.md (verification checkpoints)
   - plan.md (if time permits)
   - implement.md (if time permits)
   - revise.md (if time permits)

### Documentation Artifacts

1. **Root Cause Analysis**:
   - `specs/321_fix_workflow_command_preflight_status_update_failures/root-cause-analysis.md`
   - Findings from Phase 1 investigation
   - Context window hypothesis findings
   - Explanation of documentation-vs-execution gap
   - Recommendations for future instruction writing

2. **Updated References**:
   - state-management.md (cross-reference to status-markers.md)
   - status-transitions.md (cross-reference to status-markers.md)

### Test Artifacts

1. **Test Results**:
   - Preflight execution test results
   - Postflight execution test results
   - Verification checkpoint test results
   - Context window hypothesis test results
   - Multi-command test results

2. **Error Logs**:
   - errors.state with logged failures from testing
   - Analysis of error patterns

## Rollback/Contingency

### Rollback Plan

If fixes cause issues:

1. **Immediate Rollback**:
   - Git revert to previous commit
   - Restore original subagent files
   - Restore original command files
   - Remove errors.state if causing issues

2. **Partial Rollback**:
   - Keep status-markers.md (no harm)
   - Keep error-logging.md (no harm)
   - Revert subagent changes if they cause issues
   - Revert verification checkpoints if they cause false positives
   - Keep errors.state for debugging

### Contingency Plan

If root cause cannot be fixed:

1. **Document Limitation**:
   - Document that delegation instructions are not reliably executed
   - Recommend manual status updates as workaround
   - Propose architectural change for future work

2. **Minimal Viable Fix**:
   - Focus on verification checkpoints to catch failures
   - Accept that delegation may not execute, but failures are caught
   - Provide clear error messages for manual intervention
   - Use errors.state for debugging and pattern analysis

3. **Alternative Approach**:
   - If context window hypothesis is correct, recommend running /plan after /research
   - Document workaround in user guide
   - Investigate architectural changes for future work

## Success Metrics

### Primary Metrics

1. **Preflight Execution Rate**:
   - Target: 100% of workflow commands execute preflight
   - Measurement: Test with multiple commands and verify status updates
   - Baseline: Currently inconsistent (user reports consistent failures)

2. **Postflight Execution Rate**:
   - Target: 100% of workflow commands execute postflight
   - Measurement: Test with multiple commands and verify artifact linking
   - Baseline: Currently inconsistent (user reports consistent failures)

3. **State Synchronization**:
   - Target: 100% synchronization between TODO.md and state.json
   - Measurement: Compare status markers after workflow execution
   - Baseline: Currently desynchronized (evidence from Task 314)

4. **Silent Failure Rate**:
   - Target: 0% silent failures (all failures caught by verification and logged)
   - Measurement: Test with simulated failures
   - Baseline: Currently 100% silent (no error logging)

### Secondary Metrics

1. **Workflow Speed**:
   - Target: No measurable slowdown (<100ms overhead)
   - Measurement: Compare execution time before/after changes
   - Baseline: Current execution time

2. **Code Complexity**:
   - Target: Minimal increase (<100 lines total across all files)
   - Measurement: Line count diff
   - Baseline: Current line count

3. **Error Log Quality**:
   - Target: All errors logged with actionable context
   - Measurement: Review errors.state entries
   - Baseline: No error logging currently

4. **Documentation Quality**:
   - Target: Single source of truth for status markers
   - Measurement: No conflicting definitions found
   - Baseline: Currently inconsistent (state-management.md vs. status-transitions.md)

## Notes

### Key Insights from Research

1. **Unified Root Cause**: Preflight and postflight failures have the same root cause (documentation-vs-execution gap). This means a single fix can address both issues.

2. **Consistent Failures**: User reports consistent failures, not occasional. This suggests a systemic issue rather than edge cases.

3. **Context Window Hypothesis**: /plan works better than /research. Possible explanation: context window priming from /research in same session provides delegation examples that improve execution.

4. **Partial Success Evidence**: Task 314 shows partial postflight success (artifact created, status updated, but git commit missing). This proves delegation CAN work but is not reliable.

5. **Silent Failures**: No error logging currently exists. Adding errors.state will provide crucial debugging information.

### Implementation Strategy

1. **Investigate First**: Phase 1 focuses on understanding WHY delegation doesn't execute before attempting fixes
2. **Infrastructure**: Phase 2 creates foundation (status-markers.md, errors.state) for consistent behavior
3. **Fix Root Cause**: Phase 3 addresses the core delegation execution gap
4. **Verify Surgically**: Phase 4 adds minimal checkpoints to catch failures
5. **Test Thoroughly**: Phase 5 ensures fixes work in practice
6. **Document**: Phase 6 captures learnings for future reference

### Alignment with User Guidance

- ✅ PRIMARY FOCUS: Debug why preflight/postflight not executing (Phase 1)
- ✅ AVOID: Tons of validation checks (Phase 4 is surgical only)
- ✅ ALLOW: Minimal surgical verification (Phase 4)
- ✅ AVOID: Timeout protection (not included)
- ✅ REQUIRED: status-markers.md (Phase 2)
- ✅ REQUIRED: errors.state logging (Phase 2, 3, 4)
- ✅ INTEGRATE: Task 320 findings (unified approach)
- ✅ INVESTIGATE: Context window hypothesis (Phase 1)
- ✅ REDUCE COMPLEXITY: Streamlined from 6 phases to 6 focused phases, removed timeout protection

### Changes from Version 1

1. **Integrated Task 320**: Unified approach for preflight and postflight
2. **Error Logging**: Added errors.state infrastructure and logging throughout
3. **Context Window Hypothesis**: Added investigation in Phase 1
4. **Reduced Complexity**: Removed timeout protection, streamlined validation
5. **Updated Failure Frequency**: Changed from "occasional" to "consistent"
6. **Surgical Verification**: Emphasized minimal checkpoints over extensive validation

---

**Plan Status**: Ready for implementation  
**Next Step**: Begin Phase 1 - Root Cause Investigation and Context Window Hypothesis
