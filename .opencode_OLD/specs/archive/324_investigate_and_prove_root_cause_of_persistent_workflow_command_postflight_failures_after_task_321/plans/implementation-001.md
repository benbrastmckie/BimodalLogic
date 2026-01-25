# Implementation Plan: Root Cause Investigation for Persistent Workflow Command Postflight Failures

**Task**: 324 - Investigate and prove root cause of persistent workflow command postflight failures after task 321
**Created**: 2026-01-06
**Plan Version**: 1
**Estimated Effort**: 6-8 hours
**Complexity**: Medium-High
**Language**: meta
**Priority**: High

---

## Metadata

- **Task Number**: 324
- **Status**: [PLANNED]
- **Dependencies**: Task 323 (test case), Task 320 (bug tracking)
- **Blocking**: Task 320 (fix implementation)
- **Research Integrated**: Yes
- **Plan Version**: 1
- **Reports Integrated**:
  - research-001.md (Root Cause Analysis, integrated 2026-01-06)

---

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) create artifacts successfully but fail to update TODO.md with status markers and artifact links during postflight. Task 323 provides concrete evidence: /research 323 created research-001.md and updated state.json correctly, but TODO.md still shows [NOT STARTED] with no artifact links. This contradicts task 320 plan v5 which claimed task 321 already fixed all critical bugs.

### Research Integration

This plan integrates findings from research-001.md which identified the exact failure point through empirical analysis of task 323 workflow execution:

**Root Cause Identified**: researcher.md step_4_postflight specification (lines 340-438) correctly documents invoking status-sync-manager for atomic TODO.md + state.json updates, but the actual execution bypasses status-sync-manager and only updates state.json directly using jq commands.

**Evidence**:
- Task 323 workflow report shows direct jq commands (no status-sync-manager delegation)
- Git commit 14abf52 proves TODO.md was never modified
- Current TODO.md shows [NOT STARTED] (incorrect)
- Current state.json shows "researched" (correct)
- Specification-implementation mismatch proven by 4 independent proof methods

### Scope

**In Scope**:
1. Document root cause with concrete evidence from task 323
2. Prove failure mechanism using multiple proof methods
3. Identify exact failure point in researcher.md postflight
4. Compare expected vs actual behavior systematically
5. Assess impact on all workflow commands
6. Provide detailed recommendations for task 320 fix

**Out of Scope**:
- Implementing fixes (task 320 responsibility)
- Testing other workflow commands beyond /research
- Analyzing task 321 implementation details
- Creating automated sync tools

### Definition of Done

- [NOT STARTED] Root cause proven with 4 independent proof methods
- [NOT STARTED] Evidence documented from task 323 test case
- [NOT STARTED] Failure point identified in researcher.md code
- [NOT STARTED] Expected vs actual behavior comparison complete
- [NOT STARTED] Impact assessment for all workflow commands
- [NOT STARTED] Recommendations provided for task 320 fix
- [NOT STARTED] Investigation report validated and committed

---

## Goals and Non-Goals

### Goals

1. **Prove Root Cause**: Use empirical evidence from task 323 to prove researcher.md bypasses status-sync-manager
2. **Document Failure Mechanism**: Explain exactly why TODO.md is not updated during postflight
3. **Provide Evidence Chain**: Build logical proof using workflow report, git commits, and file states
4. **Enable Task 320 Fix**: Provide actionable recommendations for implementing the fix
5. **Prevent Recurrence**: Document validation checks to prevent similar failures

### Non-Goals

1. **Implement Fixes**: Task 320 will implement the actual fixes
2. **Test All Commands**: Focus on /research as representative case
3. **Manual Sync**: Not creating tools to sync TODO.md with state.json
4. **Analyze Task 321**: Not investigating why task 321 didn't fix the issue

---

## Implementation Phases

### Phase 1: Evidence Collection (2 hours)

**Objective**: Gather all evidence from task 323 test case and related files

**Tasks**:
1. Read task 323 workflow execution report (1436 lines)
2. Extract key evidence sections:
   - Preflight process (status update to [RESEARCHING])
   - Postflight process (status update to [RESEARCHED])
   - Git commit analysis (files changed)
   - Discrepancy analysis (state.json vs TODO.md)
3. Read current state.json task 323 entry
4. Read current TODO.md task 323 entry
5. Analyze git commit 14abf52 (files changed, commit message)
6. Read researcher.md specification (step_4_postflight lines 340-438)
7. Read status-sync-manager.md specification (update_status_flow)

**Deliverables**:
- Evidence file list with line references
- Key findings extracted from each source
- Discrepancy summary table (state.json vs TODO.md)

**Acceptance Criteria**:
- [NOT STARTED] All 7 evidence sources read and analyzed
- [NOT STARTED] Key findings extracted with line numbers
- [NOT STARTED] Discrepancy table created with 4+ comparison points

---

### Phase 2: Root Cause Proof (2 hours)

**Objective**: Prove root cause using 4 independent proof methods

**Tasks**:
1. **Proof Method 1: Contradiction**
   - Assume researcher.md invokes status-sync-manager
   - Derive implications (TODO.md must be updated)
   - Show contradiction with observed state (TODO.md not updated)
   - Conclude assumption is false

2. **Proof Method 2: Evidence Chain**
   - Build logical chain from workflow report to TODO.md state
   - Show each step implies the next
   - Prove researcher.md did NOT invoke status-sync-manager

3. **Proof Method 3: Specification Mismatch**
   - Compare researcher.md specification (lines 340-438)
   - Compare actual execution (task 323 workflow report)
   - Count requirement violations (3 out of 3)
   - Prove implementation doesn't match specification

4. **Proof Method 4: Empirical Test**
   - Use task 323 as test case
   - Compare expected vs actual behavior
   - Show 7 out of 9 postflight steps don't match specification
   - Prove postflight workflow is broken

**Deliverables**:
- 4 independent proofs documented
- Proof summary table
- Confidence level assessment (target: 100%)

**Acceptance Criteria**:
- [NOT STARTED] All 4 proof methods completed
- [NOT STARTED] Each proof is logically sound and independent
- [NOT STARTED] Proofs converge on same root cause
- [NOT STARTED] Confidence level 100% (proven by multiple methods)

---

### Phase 3: Failure Mechanism Analysis (1.5 hours)

**Objective**: Explain exactly how and why the failure occurs

**Tasks**:
1. Analyze preflight vs postflight symmetry
   - Compare preflight pattern (direct jq commands)
   - Compare postflight pattern (direct jq commands)
   - Identify systematic implementation issue

2. Explain why state.json updates succeed
   - Document direct jq command usage
   - Show state.json is updated correctly
   - Explain this is legacy approach (predates status-sync-manager)

3. Explain why TODO.md updates fail
   - Show TODO.md requires status-sync-manager invocation
   - Prove status-sync-manager is never invoked
   - Explain TODO.md is never touched without delegation

4. Analyze git commit behavior
   - Show git only stages modified files
   - Prove TODO.md has no changes to stage
   - Explain git behavior is correct (problem is upstream)

5. Identify validation gaps
   - Show postflight validation only checks state.json
   - Prove no TODO.md validation performed
   - Explain why validation claimed "PASSED" despite failure

**Deliverables**:
- 5 detailed analysis sections
- Failure mechanism diagram (text-based)
- Validation gap summary

**Acceptance Criteria**:
- [NOT STARTED] All 5 analysis sections completed
- [NOT STARTED] Failure mechanism clearly explained
- [NOT STARTED] Validation gaps identified with examples

---

### Phase 4: Impact Assessment (1.5 hours)

**Objective**: Assess impact on all workflow commands and affected tasks

**Tasks**:
1. Identify affected commands
   - Confirmed: /research (proven by task 323)
   - Likely: /plan, /implement, /revise (requires verification)
   - Not affected: /task, /todo, /review (different workflows)

2. Identify affected tasks
   - Query state.json for all tasks with status="researched"
   - Check if TODO.md shows [RESEARCHED] for each
   - Document discrepancy count

3. Assess user impact
   - Visibility: Users see incorrect status in TODO.md
   - Workflow confusion: Discrepancy between authoritative and user-facing views
   - Artifact discovery: Research artifacts not discoverable from TODO.md
   - Trust: Users may lose trust in TODO.md accuracy

4. Assess system impact
   - Data integrity: state.json and TODO.md out of sync
   - Atomic updates: Atomic update mechanism bypassed
   - Validation: Postflight validation incomplete
   - Git history: Git commits incomplete (missing TODO.md)
   - Recovery: Manual recovery required

**Deliverables**:
- Affected commands list with verification status
- Affected tasks count (from state.json query)
- User impact summary (5 categories)
- System impact summary (5 categories)

**Acceptance Criteria**:
- [NOT STARTED] All workflow commands categorized (affected/not affected)
- [NOT STARTED] Affected tasks count determined
- [NOT STARTED] User impact documented with 5+ categories
- [NOT STARTED] System impact documented with 5+ categories

---

### Phase 5: Recommendations and Validation (1 hour)

**Objective**: Provide actionable recommendations for task 320 fix implementation

**Tasks**:
1. Document fix recommendations for task 320
   - Fix researcher.md step_4_postflight (remove jq, add delegation)
   - Fix researcher.md step_0_preflight (same pattern)
   - Add postflight validation (verify TODO.md updated)
   - Test with task 323 (re-run /research 323)
   - Verify other subagents (planner.md, implementer.md, task-reviser.md)

2. Document immediate mitigation steps
   - Manual TODO.md sync procedure
   - Documentation updates (warning about staleness)
   - Monitoring script (validate TODO.md vs state.json sync)

3. Document risks and mitigations
   - Risk 1: Fix breaks other functionality
   - Risk 2: Incomplete fix (other subagents affected)
   - Risk 3: Manual sync errors
   - Risk 4: User confusion during fix deployment

4. Create validation checklist
   - Preflight validation (5 checks)
   - Research validation (8 checks)
   - Postflight validation (11 checks)
   - Report quality validation (11 checks)

5. Provide verification commands
   - Verify task 323 state (4 commands)
   - Find all affected tasks (2 commands)
   - Verify status-sync-manager implementation (2 commands)

**Deliverables**:
- 5 fix recommendations for task 320
- 3 immediate mitigation steps
- 4 risks with mitigations
- Validation checklist (35 total checks)
- Verification commands (8 commands)

**Acceptance Criteria**:
- [NOT STARTED] All 5 fix recommendations documented
- [NOT STARTED] All 3 mitigation steps documented
- [NOT STARTED] All 4 risks documented with mitigations
- [NOT STARTED] Validation checklist complete (35 checks)
- [NOT STARTED] Verification commands tested and working

---

### Phase 6: Report Finalization and Commit (1 hour)

**Objective**: Finalize investigation report and create git commit

**Tasks**:
1. Compile all phases into comprehensive report
   - Executive summary (< 200 words)
   - Context & scope
   - Evidence collection (7 sources)
   - Root cause analysis (4 proof methods)
   - Detailed analysis (5 sections)
   - Impact assessment (4 categories)
   - Recommendations (5 for task 320, 3 for mitigation)
   - Risks & mitigations (4 risks)
   - Appendices (evidence files, verification commands, proof summary)

2. Validate report quality
   - All required sections present
   - Executive summary concise
   - Evidence properly cited with line numbers
   - Proofs logically sound
   - Recommendations actionable
   - No emoji (follows documentation standards)
   - Markdown formatting consistent

3. Update task 324 status to [IMPLEMENTED]
   - Delegate to status-sync-manager
   - Pass validated_artifacts array (investigation report)
   - Verify TODO.md and state.json updated

4. Create git commit
   - Delegate to git-workflow-manager
   - Scope files: investigation report, TODO.md, state.json
   - Message: "task 324: root cause investigation completed"

**Deliverables**:
- Complete investigation report (800+ lines)
- Updated TODO.md (task 324 status [IMPLEMENTED])
- Updated state.json (task 324 status "implemented")
- Git commit with all changes

**Acceptance Criteria**:
- [NOT STARTED] Report complete with all sections
- [NOT STARTED] Report validated (11 quality checks)
- [NOT STARTED] TODO.md updated to [IMPLEMENTED]
- [NOT STARTED] state.json updated to "implemented"
- [NOT STARTED] Git commit created successfully

---

## Testing and Validation

### Validation Strategy

**Evidence Validation**:
- Verify all 7 evidence sources exist and are readable
- Verify line number references are accurate
- Verify discrepancy table matches actual file states

**Proof Validation**:
- Verify each proof method is logically sound
- Verify proofs are independent (no circular reasoning)
- Verify all 4 proofs converge on same root cause

**Impact Validation**:
- Verify affected commands list is complete
- Verify affected tasks count matches state.json query
- Verify user/system impact categories are comprehensive

**Recommendation Validation**:
- Verify fix recommendations are actionable
- Verify mitigation steps are practical
- Verify risks are realistic with effective mitigations

### Test Cases

**Test Case 1: Evidence Collection**
- Input: Task 323 workflow report, state.json, TODO.md, git commit 14abf52
- Expected: 7 evidence sources read, key findings extracted, discrepancy table created
- Validation: All evidence properly cited with line numbers

**Test Case 2: Root Cause Proof**
- Input: Evidence from test case 1
- Expected: 4 independent proofs completed, all converging on same root cause
- Validation: Confidence level 100%, no logical errors

**Test Case 3: Impact Assessment**
- Input: state.json query results, workflow command analysis
- Expected: Affected commands categorized, affected tasks counted, impact documented
- Validation: All categories comprehensive, counts accurate

**Test Case 4: Recommendations**
- Input: Root cause analysis, impact assessment
- Expected: 5 fix recommendations, 3 mitigation steps, 4 risks with mitigations
- Validation: All recommendations actionable, mitigations effective

---

## Artifacts and Outputs

### Primary Artifacts

1. **Investigation Report** (`.opencode/specs/324_investigate_and_prove_root_cause_of_persistent_workflow_command_postflight_failures_after_task_321/reports/investigation-001.md`)
   - Size: ~800 lines, ~40KB
   - Sections: 9 major sections + 3 appendices
   - Evidence: 7 sources with line references
   - Proofs: 4 independent methods
   - Recommendations: 5 for task 320, 3 for mitigation
   - Risks: 4 with mitigations

### Supporting Artifacts

1. **Evidence Summary** (embedded in investigation report)
   - 7 evidence sources
   - Key findings from each source
   - Discrepancy table (state.json vs TODO.md)

2. **Proof Summary** (embedded in investigation report)
   - 4 proof methods
   - Convergence analysis
   - Confidence level assessment

3. **Verification Commands** (embedded in investigation report)
   - 8 commands for validation
   - Expected outputs documented

### Metadata Updates

1. **TODO.md**
   - Task 324 status: [NOT STARTED] → [IMPLEMENTED]
   - Implementation completed date added
   - Investigation report artifact link added

2. **state.json**
   - Task 324 status: "researched" → "implemented"
   - Implementation completed timestamp
   - Artifacts array updated with investigation report

---

## Rollback/Contingency

### Rollback Triggers

1. **Evidence Collection Failure**
   - Trigger: Cannot read required evidence files
   - Action: Abort investigation, report missing files
   - Recovery: Ensure all evidence files exist before retrying

2. **Proof Validation Failure**
   - Trigger: Proofs don't converge on same root cause
   - Action: Re-analyze evidence, revise proofs
   - Recovery: Identify logical errors, correct reasoning

3. **Impact Assessment Incomplete**
   - Trigger: Cannot determine affected tasks count
   - Action: Manual state.json inspection
   - Recovery: Use alternative query methods

### Contingency Plans

**If Evidence Incomplete**:
- Use available evidence to build partial proof
- Document gaps and assumptions
- Recommend additional investigation

**If Proofs Inconclusive**:
- Focus on strongest proof method (empirical test)
- Document uncertainty level
- Recommend further testing

**If Recommendations Unclear**:
- Provide multiple fix options
- Document trade-offs for each
- Recommend task 320 team choose best approach

---

## Success Metrics

### Quantitative Metrics

- **Evidence Sources**: 7 sources read and analyzed
- **Proof Methods**: 4 independent proofs completed
- **Confidence Level**: 100% (proven by multiple methods)
- **Affected Commands**: 4 categorized (1 confirmed, 3 likely)
- **Affected Tasks**: Count determined from state.json query
- **Fix Recommendations**: 5 actionable recommendations
- **Mitigation Steps**: 3 immediate actions
- **Risks Identified**: 4 with mitigations
- **Validation Checks**: 35 total checks
- **Verification Commands**: 8 commands provided

### Qualitative Metrics

- **Root Cause Clarity**: Root cause clearly stated and proven
- **Evidence Quality**: All evidence properly cited with line numbers
- **Proof Soundness**: All proofs logically sound and independent
- **Recommendation Actionability**: All recommendations actionable for task 320
- **Report Completeness**: All required sections present and comprehensive

### Acceptance Criteria

- [NOT STARTED] All 7 evidence sources analyzed
- [NOT STARTED] All 4 proof methods completed with 100% confidence
- [NOT STARTED] All affected commands categorized
- [NOT STARTED] All 5 fix recommendations documented
- [NOT STARTED] All 3 mitigation steps documented
- [NOT STARTED] All 4 risks documented with mitigations
- [NOT STARTED] Investigation report validated (11 quality checks)
- [NOT STARTED] TODO.md and state.json updated
- [NOT STARTED] Git commit created

---

## Dependencies and Blockers

### Dependencies

1. **Task 323 (Test Case)**: Provides concrete evidence of postflight failure
   - Status: [NOT STARTED] in TODO.md (incorrect)
   - Status: "researched" in state.json (correct)
   - Artifact: research-001.md created successfully
   - Git commit: 14abf52 (missing TODO.md)

2. **Task 320 (Bug Tracking)**: Will implement fixes based on this investigation
   - Status: [PLANNED]
   - Plan v6: Waits for task 324 investigation
   - Dependencies: Task 324 (this investigation)

### Blockers

**None**: All required evidence already exists from task 323 execution.

### External Dependencies

**None**: Investigation uses only existing files and git history.

---

## Risk Assessment

### Risk 1: Evidence Interpretation Errors

**Likelihood**: Low
**Impact**: High (incorrect root cause identification)

**Mitigation**:
- Use 4 independent proof methods
- Cross-validate findings across evidence sources
- Document all assumptions explicitly
- Provide evidence line numbers for verification

### Risk 2: Incomplete Impact Assessment

**Likelihood**: Medium
**Impact**: Medium (underestimate scope of problem)

**Mitigation**:
- Query state.json for all affected tasks
- Categorize all workflow commands
- Document both user and system impact
- Provide verification commands for validation

### Risk 3: Recommendations Not Actionable

**Likelihood**: Low
**Impact**: High (task 320 cannot implement fix)

**Mitigation**:
- Provide specific code locations (file, line numbers)
- Include example implementations
- Document validation steps
- Provide test case (task 323) for verification

### Risk 4: Report Quality Issues

**Likelihood**: Low
**Impact**: Medium (report not useful for task 320)

**Mitigation**:
- Follow report.md standards
- Include all required sections
- Validate with 11 quality checks
- Provide comprehensive appendices

---

## Notes and Assumptions

### Assumptions

1. **Task 323 Evidence is Accurate**: Workflow execution report accurately reflects actual execution
2. **researcher.md is Representative**: Other subagents (planner.md, implementer.md) may have same issue
3. **status-sync-manager is Correct**: status-sync-manager.md implementation is correct and functional
4. **Git History is Complete**: Git commit 14abf52 accurately shows all files changed

### Notes

1. **Research Already Complete**: Task 324 research (research-001.md) already identified root cause
2. **This Plan is Implementation**: This plan implements the investigation documented in research-001.md
3. **Task 320 Dependency**: Task 320 fix implementation depends on this investigation's findings
4. **Test Case Available**: Task 323 provides concrete test case for validating any fix

---

## Validation Checklist

### Pre-Implementation Validation

- [NOT STARTED] Task 324 exists in state.json
- [NOT STARTED] Task 324 status is "researched" (ready for implementation)
- [NOT STARTED] Research report (research-001.md) exists and is readable
- [NOT STARTED] Task 323 evidence files exist (workflow report, research report)
- [NOT STARTED] Git commit 14abf52 exists and is accessible

### Post-Implementation Validation

- [NOT STARTED] Investigation report created (800+ lines)
- [NOT STARTED] All 7 evidence sources analyzed
- [NOT STARTED] All 4 proof methods completed
- [NOT STARTED] All affected commands categorized
- [NOT STARTED] All 5 fix recommendations documented
- [NOT STARTED] All 3 mitigation steps documented
- [NOT STARTED] All 4 risks documented with mitigations
- [NOT STARTED] Report validated (11 quality checks)
- [NOT STARTED] TODO.md updated to [IMPLEMENTED]
- [NOT STARTED] state.json updated to "implemented"
- [NOT STARTED] Git commit created

---

**End of Implementation Plan**

**Plan Metadata**:
- Created: 2026-01-06
- Task: 324
- Plan Version: 1
- Estimated Effort: 6-8 hours
- Complexity: Medium-High
- Research Integrated: Yes (research-001.md)
- Phases: 6
- Total Validation Checks: 35
- Confidence Level: High (research already identified root cause)
