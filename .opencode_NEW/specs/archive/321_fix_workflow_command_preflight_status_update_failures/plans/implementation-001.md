# Implementation Plan: Fix Systematic Preflight Failures in Workflow Commands

## Metadata

- **Task**: 321 - Fix workflow command preflight status update failures
- **Status**: [NOT STARTED]
- **Estimated Effort**: 6 hours
- **Language**: meta
- **Priority**: High
- **Created**: 2026-01-05
- **Plan Version**: 1
- **Complexity**: Medium
- **Dependencies**: None
- **Blocking**: None

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) are experiencing systematic preflight failures where step_0_preflight instructions in subagent markdown files are **not being executed** by AI agents. This causes status markers to remain stale (e.g., [NOT STARTED] instead of [RESEARCHING]) when work begins, leading to state synchronization failures between TODO.md and state.json.

**Root Cause**: Documentation-vs-execution gap. Subagent markdown files contain instructions to delegate to status-sync-manager during preflight, but these instructions are not consistently executed by AI agents reading the markdown.

### Scope

**In Scope**:
- Debug why step_0_preflight instructions are not being executed
- Create standardized status marker convention file (.opencode/context/system/status-markers.md)
- Add minimal strategic validation to catch silent failures
- Fix root cause of preflight execution gap

**Out of Scope**:
- Extensive validation checks that bloat complexity
- Timeout protection mechanisms (per user guidance)
- Postflight failures (covered by task 320)
- Complete workflow redesign

### Constraints

**User-Specified Constraints**:
1. PRIMARY FOCUS: Debug why step_0_preflight instructions are NOT being executed
2. AVOID: Adding tons of validation checks that bloat complexity and slow workflow
3. ALLOW: Minimal key validation checks at strategic points to avoid silent failures
4. AVOID: Useless timeout protection that causes more issues than it solves
5. REQUIRED: Create .opencode/context/system/status-markers.md for consistent status marker conventions

### Definition of Done

- [ ] Root cause of preflight non-execution identified and documented
- [ ] Status marker convention file created at .opencode/context/system/status-markers.md
- [ ] Minimal strategic validation added to detect silent preflight failures
- [ ] Preflight execution gap fixed in all 6 workflow subagents
- [ ] All changes tested with at least one workflow command
- [ ] Documentation updated to reflect fixes
- [ ] No new complexity or timeout mechanisms added

### Research Integration

This plan integrates findings from 1 research report:

**Integrated Reports**:
- **research-001.md** (2026-01-05): Comprehensive analysis of preflight status update failures
  - Key Finding: Subagent markdown files contain step_0_preflight instructions to delegate to status-sync-manager, but these instructions are not being executed by AI agents (documentation-vs-execution gap)
  - Key Finding: Commands do not validate that preflight execution occurred (no validation in Stage 3)
  - Key Finding: State synchronization failures are silent (Task 314 shows TODO.md updated but state.json not updated)
  - Recommendation: Focus on making preflight instructions more concrete and executable, add minimal validation to catch failures
  - Recommendation: Create single source of truth for status markers to eliminate inconsistencies

## Goals and Non-Goals

### Goals

1. **Identify root cause** of why step_0_preflight instructions are not executed
2. **Fix preflight execution gap** with minimal complexity increase
3. **Standardize status markers** via .opencode/context/system/status-markers.md
4. **Add minimal validation** at strategic points to catch silent failures
5. **Maintain workflow speed** - no bloat, no unnecessary checks

### Non-Goals

1. Add extensive validation checks throughout the workflow
2. Implement timeout protection mechanisms
3. Fix postflight failures (separate task 320)
4. Redesign entire workflow architecture
5. Add metrics, monitoring, or checkpoint systems (future work)

## Risks and Mitigations

### Risk 1: Root Cause May Be Architectural

**Risk**: The documentation-vs-execution gap may be inherent to how AI agents process markdown instructions

**Likelihood**: Medium  
**Impact**: High  
**Mitigation**: 
- Investigate multiple potential causes (instruction clarity, delegation syntax, validation gaps)
- Test different instruction formats to find what works
- Document findings for future reference
- If architectural, propose minimal viable fix

### Risk 2: Minimal Validation May Miss Edge Cases

**Risk**: Adding only minimal validation may not catch all failure modes

**Likelihood**: Medium  
**Impact**: Medium  
**Mitigation**:
- Focus validation on critical checkpoints (preflight completion)
- Use fail-fast approach to surface issues quickly
- Document known edge cases for future enhancement
- Monitor for new failure patterns post-fix

### Risk 3: Status Marker Standardization May Require Updates Across Many Files

**Risk**: Creating single source of truth may require updating many references

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**:
- Use grep to find all status marker references
- Update systematically in single phase
- Test after updates to ensure consistency
- Keep changes minimal and focused

## Implementation Phases

### Phase 1: Root Cause Investigation [NOT STARTED]

**Objective**: Debug why step_0_preflight instructions are not being executed by AI agents

**Tasks**:
1. Analyze current step_0_preflight instruction format in all 6 subagents
2. Compare instruction clarity, specificity, and delegation syntax
3. Investigate if instructions are too abstract or lack concrete examples
4. Check if delegation context format is unclear or ambiguous
5. Test hypothesis: Are instructions being read but not executed, or not read at all?
6. Document findings with specific examples of what works vs. what doesn't

**Acceptance Criteria**:
- Root cause hypothesis documented with evidence
- Specific instruction format issues identified
- Concrete examples of successful vs. failed preflight execution
- Clear understanding of what makes instructions executable vs. non-executable

**Estimated Effort**: 1.5 hours

**Validation**:
- Findings documented in phase notes
- Hypothesis testable with concrete examples
- Team consensus on root cause

---

### Phase 2: Create Status Marker Convention File [NOT STARTED]

**Objective**: Create .opencode/context/system/status-markers.md as single source of truth for status marker conventions

**Tasks**:
1. Create .opencode/context/system/ directory if it doesn't exist
2. Extract all status marker definitions from state-management.md and status-transitions.md
3. Create status-markers.md with:
   - Complete list of all status markers (in-progress and completion)
   - Valid status transitions
   - Usage guidelines for each marker
   - Mapping between TODO.md markers (e.g., [RESEARCHING]) and state.json values (e.g., "researching")
4. Update state-management.md to reference status-markers.md
5. Update status-transitions.md to reference status-markers.md
6. Verify no inconsistencies between files

**Acceptance Criteria**:
- .opencode/context/system/status-markers.md created
- All status markers documented with clear definitions
- Valid transitions documented
- Cross-references added to state-management.md and status-transitions.md
- No duplicate or conflicting definitions

**Estimated Effort**: 1 hour

**Validation**:
- File exists and is well-formatted
- All status markers from research report included
- Cross-references work correctly
- No inconsistencies found

---

### Phase 3: Fix Preflight Execution Gap in Subagents [NOT STARTED]

**Objective**: Update step_0_preflight instructions in all 6 subagents to ensure execution

**Tasks**:
1. Based on Phase 1 findings, determine minimal fix for preflight instructions
2. Update step_0_preflight in all 6 subagents:
   - researcher.md
   - planner.md
   - implementer.md
   - lean-research-agent.md
   - lean-planner.md
   - lean-implementation-agent.md
3. Make instructions more concrete and executable (based on root cause findings)
4. Add explicit delegation syntax examples if needed
5. Add clear validation requirements
6. Keep changes minimal - focus on execution, not documentation bloat

**Acceptance Criteria**:
- All 6 subagents updated with improved preflight instructions
- Instructions are concrete and executable
- Delegation syntax is clear and unambiguous
- Validation requirements are explicit
- No unnecessary complexity added

**Estimated Effort**: 2 hours

**Validation**:
- All 6 subagent files updated
- Instructions follow consistent format
- Test with one workflow command shows preflight executes
- No regression in existing functionality

---

### Phase 4: Add Minimal Strategic Validation [NOT STARTED]

**Objective**: Add minimal validation at strategic points to catch silent preflight failures

**Tasks**:
1. Identify 1-2 strategic validation points (likely in command Stage 3: ValidateReturn)
2. Add single validation check: Verify status was updated after subagent returns
3. Implementation approach:
   - Read current status from state.json
   - Check if status matches expected in-progress or completion marker
   - If mismatch: Log error and fail fast with clear message
   - If match: Log success and continue
4. Add validation to ONE workflow command first (e.g., /research) as proof of concept
5. Test validation catches preflight failures
6. If successful, replicate to other 3 commands

**Acceptance Criteria**:
- Validation added to at least /research command
- Validation is minimal (single check, <10 lines of code)
- Validation catches preflight failures and fails fast
- Clear error messages guide debugging
- No performance impact (<100ms overhead)

**Estimated Effort**: 1 hour

**Validation**:
- Validation code added to command files
- Test shows validation catches preflight failure
- Test shows validation passes when preflight succeeds
- Error messages are clear and actionable

---

### Phase 5: Testing and Verification [NOT STARTED]

**Objective**: Test all fixes with real workflow commands and verify preflight execution

**Tasks**:
1. Create test task in TODO.md for testing
2. Test /research command with updated subagent:
   - Verify status updates to [RESEARCHING] at start
   - Verify status updates to [RESEARCHED] at completion
   - Verify state.json synchronized with TODO.md
3. Test validation catches failures:
   - Simulate preflight failure (comment out delegation)
   - Verify validation detects and reports failure
4. Test at least one other command (/plan or /implement)
5. Verify no regressions in existing functionality
6. Document test results

**Acceptance Criteria**:
- All tests pass successfully
- Preflight execution confirmed for tested commands
- Validation catches simulated failures
- No regressions detected
- Test results documented

**Estimated Effort**: 1 hour

**Validation**:
- Test task created and executed
- Status updates verified in both TODO.md and state.json
- Validation test passes
- No errors or warnings in execution
- Test results documented in phase notes

---

### Phase 6: Documentation and Cleanup [NOT STARTED]

**Objective**: Update documentation to reflect fixes and clean up any temporary changes

**Tasks**:
1. Document root cause findings in appropriate location (possibly ADR or research report addendum)
2. Update any affected documentation files
3. Verify status-markers.md is properly referenced
4. Clean up any temporary test tasks or files
5. Review all changes for consistency
6. Prepare summary of changes for commit message

**Acceptance Criteria**:
- Root cause documented
- All documentation updated
- No temporary files left behind
- Changes are consistent and well-documented
- Ready for git commit

**Estimated Effort**: 0.5 hours

**Validation**:
- Documentation complete and accurate
- No temporary files remain
- All references updated
- Changes ready for commit

---

## Testing and Validation

### Unit Testing

**Not applicable** - This is a meta-level workflow fix, not code implementation

### Integration Testing

1. **Preflight Execution Test**:
   - Run /research on test task
   - Verify status updates to [RESEARCHING] immediately
   - Verify status updates to [RESEARCHED] on completion
   - Verify state.json synchronized

2. **Validation Test**:
   - Simulate preflight failure
   - Verify validation catches failure
   - Verify clear error message displayed

3. **Multi-Command Test**:
   - Test /research, /plan, and /implement
   - Verify consistent behavior across commands
   - Verify no regressions

### Acceptance Testing

1. **User Workflow Test**:
   - Complete full workflow: /research → /plan → /implement
   - Verify status updates at each stage
   - Verify state synchronization throughout
   - Verify no silent failures

2. **Edge Case Test**:
   - Test with task that has existing artifacts
   - Test with task in various starting states
   - Verify validation handles edge cases gracefully

## Artifacts and Outputs

### Primary Artifacts

1. **.opencode/context/system/status-markers.md**
   - Single source of truth for status marker conventions
   - Complete list of all markers and transitions
   - Usage guidelines

2. **Updated Subagent Files** (6 files):
   - researcher.md
   - planner.md
   - implementer.md
   - lean-research-agent.md
   - lean-planner.md
   - lean-implementation-agent.md

3. **Updated Command Files** (1-4 files):
   - research.md (minimum)
   - plan.md (if time permits)
   - implement.md (if time permits)
   - revise.md (if time permits)

### Documentation Artifacts

1. **Root Cause Documentation**:
   - Findings from Phase 1 investigation
   - Explanation of documentation-vs-execution gap
   - Recommendations for future instruction writing

2. **Updated References**:
   - state-management.md (cross-reference to status-markers.md)
   - status-transitions.md (cross-reference to status-markers.md)

### Test Artifacts

1. **Test Results**:
   - Preflight execution test results
   - Validation test results
   - Multi-command test results

## Rollback/Contingency

### Rollback Plan

If fixes cause issues:

1. **Immediate Rollback**:
   - Git revert to previous commit
   - Restore original subagent files
   - Restore original command files

2. **Partial Rollback**:
   - Keep status-markers.md (no harm)
   - Revert subagent changes if they cause issues
   - Revert validation changes if they cause false positives

### Contingency Plan

If root cause cannot be fixed:

1. **Document Limitation**:
   - Document that preflight instructions are not reliably executed
   - Recommend manual status updates as workaround
   - Propose architectural change for future work

2. **Minimal Viable Fix**:
   - Focus on validation to catch failures
   - Accept that preflight may not execute, but failures are caught
   - Provide clear error messages for manual intervention

## Success Metrics

### Primary Metrics

1. **Preflight Execution Rate**:
   - Target: 100% of workflow commands execute preflight
   - Measurement: Test with multiple commands and verify status updates

2. **State Synchronization**:
   - Target: 100% synchronization between TODO.md and state.json
   - Measurement: Compare status markers after workflow execution

3. **Silent Failure Rate**:
   - Target: 0% silent failures (all failures caught by validation)
   - Measurement: Test with simulated failures

### Secondary Metrics

1. **Workflow Speed**:
   - Target: No measurable slowdown (<100ms overhead)
   - Measurement: Compare execution time before/after changes

2. **Code Complexity**:
   - Target: Minimal increase (< 50 lines total across all files)
   - Measurement: Line count diff

3. **Documentation Quality**:
   - Target: Single source of truth for status markers
   - Measurement: No conflicting definitions found

## Notes

### Key Insights from Research

1. **Documentation-vs-Execution Gap**: The core issue is that markdown instructions are not reliably executed by AI agents. This suggests instructions need to be more concrete, explicit, and possibly include examples.

2. **No Validation**: Commands currently don't validate that preflight executed. Adding minimal validation at strategic points can catch failures without bloating complexity.

3. **Status Marker Inconsistency**: Multiple files define status markers with slight variations. Single source of truth will eliminate confusion.

### Implementation Strategy

1. **Debug First**: Phase 1 focuses on understanding WHY preflight doesn't execute before attempting fixes
2. **Standardize**: Phase 2 creates foundation for consistent status marker usage
3. **Fix Root Cause**: Phase 3 addresses the core execution gap
4. **Validate Minimally**: Phase 4 adds just enough validation to catch failures
5. **Test Thoroughly**: Phase 5 ensures fixes work in practice
6. **Document**: Phase 6 captures learnings for future reference

### Alignment with User Guidance

- ✅ PRIMARY FOCUS: Debug why preflight not executing (Phase 1)
- ✅ AVOID: Tons of validation checks (Phase 4 is minimal)
- ✅ ALLOW: Minimal strategic validation (Phase 4)
- ✅ AVOID: Timeout protection (not included)
- ✅ REQUIRED: status-markers.md (Phase 2)

---

**Plan Status**: Ready for implementation  
**Next Step**: Begin Phase 1 - Root Cause Investigation
