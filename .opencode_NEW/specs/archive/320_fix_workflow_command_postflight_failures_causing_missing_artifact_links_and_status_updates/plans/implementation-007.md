# Implementation Plan: Fix Workflow Command Postflight Failures (v7 - Root Cause Fix)

**Task**: 320 - Fix workflow command postflight failures causing missing artifact links and status updates  
**Status**: [REVISED]  
**Estimated Effort**: 4-6 hours  
**Complexity**: Medium  
**Language**: meta  
**Priority**: High  
**Created**: 2026-01-05  
**Revised**: 2026-01-06  
**Plan Version**: 7  
**Revision Reason**: Integrated research-004.md findings which identified the root cause: researcher.md bypasses status-sync-manager in step_4_postflight. The fix is straightforward - copy the working pattern from planner.md to researcher.md and document the correct pattern in context/core/ files.

---

## Overview

### Problem Statement

Workflow commands (/research, /plan, /revise, /implement) create artifacts successfully but fail to update TODO.md with status markers and artifact links. Task 324 investigation and research-004.md proved the root cause with 100% confidence:

**Root Cause**: researcher.md step_4_postflight bypasses status-sync-manager and uses direct jq commands to update state.json only, leaving TODO.md in stale state.

**Evidence**: 
- Task 323 test case: /research created research-001.md, updated state.json, but TODO.md still shows [NOT STARTED]
- Comparative analysis: planner.md and implementer.md work correctly (use status-sync-manager)
- Only researcher.md is affected

### Solution Strategy

**Simple Fix**: Copy the working delegation pattern from planner.md to researcher.md. The specification already exists in researcher.md (lines 336-391) but is not being followed during execution.

**Documentation**: Add correct pattern to context/core/ files to enforce this standard for all future workflow commands and prevent regression.

**Context Loading**: Update /meta command subagents to load these context files without bloating context unnecessarily.

### Research Integration

This plan integrates findings from research-004.md (2026-01-06):

**New Reports**:
- **research-004.md** (2026-01-06): Root cause analysis and fix strategy
  - Key Finding: researcher.md bypasses status-sync-manager (specification-implementation gap)
  - Key Finding: planner.md and implementer.md have correct implementations
  - Key Finding: Only researcher.md is affected; fix is straightforward
  - Recommendation: Copy working pattern from planner.md to researcher.md
  - Recommendation: Document correct pattern in context/core/ for enforcement

**Previously Integrated** (from plan v6):
- research-001.md: Initial analysis of postflight failures
- research-002.md: status-sync-manager bug analysis
- research-003.md: Task 321 analysis

---

## Goals and Non-Goals

### Goals

1. **Fix researcher.md postflight**: Replace direct jq commands with status-sync-manager delegation
2. **Fix researcher.md preflight**: Ensure consistent pattern for status updates
3. **Document correct pattern**: Create context/core/ files to enforce standard
4. **Update /meta subagents**: Load context files for enforcement without bloating context
5. **Validate fix**: Test with task 323 and new test cases
6. **Prevent regression**: Ensure pattern is documented and enforced

### Non-Goals

1. Fixing planner.md or implementer.md (already work correctly)
2. Redesigning status-sync-manager (works correctly when invoked)
3. Extensive testing infrastructure (minimal validation sufficient)
4. Fixing other unrelated workflow issues

---

## Scope

### In Scope

1. **researcher.md updates**:
   - step_0_preflight: Add status-sync-manager delegation for [RESEARCHING] status
   - step_4_postflight: Replace direct jq with status-sync-manager delegation
   - Verification: Add defense-in-depth checks for TODO.md and state.json

2. **Context documentation**:
   - Create .opencode/context/core/workflow/postflight-pattern.md
   - Document status-sync-manager delegation pattern
   - Include examples from planner.md and implementer.md
   - Add validation checklist

3. **Context loading**:
   - Update /meta command subagents to reference postflight-pattern.md
   - Ensure context is loaded without bloating (selective loading)
   - Document when to load this context

4. **Validation**:
   - Test fix with task 323 (existing test case)
   - Create new test task to verify end-to-end
   - Verify TODO.md and state.json synchronization

### Out of Scope

1. Fixing planner.md or implementer.md (already correct)
2. Redesigning workflow architecture
3. Extensive regression testing (minimal validation sufficient)
4. Fixing unrelated bugs in status-sync-manager

### Constraints

1. **Minimal Changes**: Only update researcher.md and add documentation
2. **Copy Working Pattern**: Use planner.md as template (proven to work)
3. **No Architecture Changes**: Keep existing delegation model
4. **Context Efficiency**: Load context selectively to avoid bloat
5. **Empirical Validation**: Test with concrete cases (task 323)

---

## Implementation Phases

### Phase 1: Fix researcher.md step_4_postflight [NOT STARTED]

**Objective**: Replace direct jq commands with status-sync-manager delegation

**Tasks**:
1. Open .opencode/agent/subagents/researcher.md
2. Locate step_4_postflight (lines 330-438)
3. Verify current specification matches planner.md pattern (lines 336-391)
4. Ensure specification is complete and correct:
   - Delegation context preparation with validated_artifacts
   - status-sync-manager invocation with timeout
   - Return validation (check files_updated)
   - Defense-in-depth verification (verify TODO.md and state.json)
   - git-workflow-manager delegation
5. Add explicit note: "CRITICAL: This specification MUST be followed during execution"
6. Add validation checkpoint: "Verify status-sync-manager was actually invoked"

**Estimated Effort**: 1 hour

**Acceptance Criteria**:
- [ ] researcher.md step_4_postflight specification is complete
- [ ] Specification matches planner.md pattern exactly
- [ ] validated_artifacts parameter included
- [ ] Defense-in-depth verification included
- [ ] Explicit execution note added

---

### Phase 2: Fix researcher.md step_0_preflight [NOT STARTED]

**Objective**: Add status-sync-manager delegation for [RESEARCHING] status

**Tasks**:
1. Locate step_0_preflight in researcher.md
2. Add status-sync-manager delegation pattern:
   - Prepare delegation context with new_status: "researching"
   - No validated_artifacts (research hasn't started)
   - Invoke status-sync-manager with timeout
   - Validate return (check files_updated)
   - Verify TODO.md updated to [RESEARCHING]
3. Add defense-in-depth verification
4. Add explicit execution note

**Estimated Effort**: 0.5 hours

**Acceptance Criteria**:
- [ ] Preflight delegation pattern added
- [ ] Pattern matches postflight pattern (except status and artifacts)
- [ ] Defense-in-depth verification included
- [ ] Explicit execution note added

---

### Phase 3: Create context/core/workflow/postflight-pattern.md [NOT STARTED]

**Objective**: Document correct postflight pattern for enforcement

**Tasks**:
1. Create .opencode/context/core/workflow/ directory (if not exists)
2. Create postflight-pattern.md with:
   - Overview: Why status-sync-manager delegation is required
   - Pattern specification: Step-by-step delegation pattern
   - Examples: Code snippets from planner.md and implementer.md
   - Validation checklist: How to verify correct implementation
   - Common mistakes: What NOT to do (direct jq commands)
   - Enforcement: When to load this context
3. Include validated_artifacts parameter documentation
4. Include defense-in-depth verification pattern
5. Add references to working implementations (planner.md, implementer.md)

**Estimated Effort**: 1.5 hours

**Acceptance Criteria**:
- [ ] postflight-pattern.md created
- [ ] Pattern specification is clear and complete
- [ ] Examples from working implementations included
- [ ] Validation checklist provided
- [ ] Common mistakes documented
- [ ] Enforcement guidelines included

---

### Phase 4: Update /meta command subagents for context loading [NOT STARTED]

**Objective**: Ensure /meta subagents load postflight-pattern.md when creating workflow commands

**Tasks**:
1. Identify /meta command subagents that create workflow commands:
   - meta.md (main subagent)
   - task-creator.md (creates tasks)
   - Any other relevant subagents
2. Add context loading directive:
   - Load postflight-pattern.md when creating/modifying workflow commands
   - Load selectively (only when needed)
   - Document when to load
3. Add validation step:
   - Verify created commands follow postflight pattern
   - Check for status-sync-manager delegation
   - Check for validated_artifacts parameter
4. Update subagent documentation

**Estimated Effort**: 1 hour

**Acceptance Criteria**:
- [ ] /meta subagents updated with context loading directive
- [ ] Loading is selective (not always loaded)
- [ ] Validation step added
- [ ] Documentation updated

---

### Phase 5: Test and validate fix [NOT STARTED]

**Objective**: Verify fix resolves the problem

**Tasks**:
1. **Test Case 1: Fix task 323 status**
   - Current state: TODO.md shows [NOT STARTED], state.json shows "researched"
   - Manually invoke status-sync-manager to sync task 323
   - Verify TODO.md updated to [RESEARCHED]
   - Verify artifact link added
   - Document before/after comparison

2. **Test Case 2: Create new test task**
   - Create test task 999 (or next available number)
   - Run /research 999 with updated researcher.md
   - Verify TODO.md updated to [RESEARCHING] at start
   - Verify TODO.md updated to [RESEARCHED] at end
   - Verify artifact link added
   - Verify state.json synchronized
   - Verify git commit includes both TODO.md and state.json

3. **Test Case 3: Verify other commands still work**
   - Run /plan on a researched task
   - Run /implement on a planned task
   - Verify no regression
   - Verify TODO.md and state.json still synchronized

4. **Documentation**
   - Document test results
   - Create before/after comparison
   - Update task 320 description with findings

**Estimated Effort**: 1.5 hours

**Acceptance Criteria**:
- [ ] Task 323 TODO.md fixed (shows [RESEARCHED] with artifact link)
- [ ] New test task works end-to-end
- [ ] TODO.md and state.json synchronized
- [ ] Git commits include both files
- [ ] No regression in other commands
- [ ] Test results documented

---

### Phase 6: Documentation and cleanup [NOT STARTED]

**Objective**: Document fix and close task

**Tasks**:
1. Create implementation summary:
   - Root cause explanation
   - Fix description
   - Test results
   - Before/after comparison
2. Update task 320 TODO.md entry:
   - Add implementation summary link
   - Update status to [COMPLETED]
   - Add completion timestamp
3. Update IMPLEMENTATION_STATUS.md (if exists)
4. Clean up test artifacts (test task 999)
5. Create git commit with all changes:
   - researcher.md updates
   - postflight-pattern.md creation
   - /meta subagent updates
   - Documentation updates
   - Test results

**Estimated Effort**: 0.5 hours

**Acceptance Criteria**:
- [ ] Implementation summary created
- [ ] Task 320 TODO.md entry updated
- [ ] IMPLEMENTATION_STATUS.md updated
- [ ] Test artifacts cleaned up
- [ ] Git commit created with descriptive message

---

## Testing and Validation

### Test Strategy

1. **Baseline Validation**: Fix task 323 (existing broken case)
2. **End-to-End Test**: Create new test task and run full workflow
3. **Regression Test**: Verify other commands still work
4. **Documentation Review**: Verify context files are clear and complete

### Test Cases

#### Test Case 1: Fix Task 323 (Baseline)

**Setup**:
- Task 323 currently has: state.json = "researched", TODO.md = "[NOT STARTED]"
- Research artifact exists: research-001.md

**Test**:
1. Manually invoke status-sync-manager with task_number=323, new_status="researched"
2. Pass validated_artifacts with research-001.md path
3. Verify TODO.md updated to [RESEARCHED]
4. Verify artifact link added

**Expected Result**:
- TODO.md shows [RESEARCHED]
- TODO.md includes artifact link to research-001.md
- state.json unchanged (already correct)

#### Test Case 2: New Test Task (End-to-End)

**Setup**:
- Create test task 999 with description "Test workflow postflight fix"

**Test**:
1. Run /research 999
2. Verify TODO.md updated to [RESEARCHING] at start
3. Verify research artifact created
4. Verify TODO.md updated to [RESEARCHED] at end
5. Verify artifact link added
6. Verify state.json synchronized
7. Verify git commit includes both TODO.md and state.json

**Expected Result**:
- TODO.md shows [RESEARCHED]
- TODO.md includes artifact link
- state.json shows status="researched"
- Git commit includes both files

#### Test Case 3: Regression Test

**Setup**:
- Use existing tasks with plans

**Test**:
1. Run /plan on a researched task
2. Run /implement on a planned task
3. Verify TODO.md and state.json updated correctly
4. Verify no errors or warnings

**Expected Result**:
- No regression in existing functionality
- TODO.md and state.json still synchronized

---

## Risks and Mitigations

### Risk 1: Specification-Implementation Gap May Persist

**Risk**: Even with updated specification, AI agents may not follow it during execution

**Likelihood**: MEDIUM  
**Impact**: HIGH (fix doesn't work)

**Mitigation**:
1. Add explicit execution notes in specification
2. Add validation checkpoints that catch failures immediately
3. Test thoroughly with concrete cases
4. Document manual workaround if needed
5. Consider architectural change if problem persists

### Risk 2: Context Loading May Bloat Context Window

**Risk**: Loading postflight-pattern.md in /meta subagents may bloat context

**Likelihood**: LOW  
**Impact**: MEDIUM (performance degradation)

**Mitigation**:
1. Load context selectively (only when creating workflow commands)
2. Keep postflight-pattern.md concise (< 500 lines)
3. Use references instead of duplicating content
4. Monitor context window usage
5. Adjust loading strategy if needed

### Risk 3: Fix May Break Existing Workflows

**Risk**: Changes to researcher.md may cause regressions

**Likelihood**: LOW  
**Impact**: HIGH (workflow commands fail)

**Mitigation**:
1. Copy proven working pattern from planner.md
2. Test thoroughly before committing
3. Keep changes minimal and surgical
4. Use git for rollback if needed
5. Monitor first few /research executions after fix

### Risk 4: Documentation May Be Insufficient

**Risk**: postflight-pattern.md may not be clear enough for enforcement

**Likelihood**: LOW  
**Impact**: MEDIUM (pattern not followed)

**Mitigation**:
1. Include concrete examples from working implementations
2. Add validation checklist
3. Document common mistakes
4. Get review from other developers (if applicable)
5. Iterate based on feedback

---

## Success Metrics

### Quantitative Metrics

1. **TODO.md Update Rate**: 100% (all workflow commands update TODO.md)
2. **State Synchronization**: 100% (TODO.md and state.json always match)
3. **Artifact Linking Rate**: 100% (all artifacts linked in TODO.md)
4. **Regression Rate**: 0% (no existing functionality broken)

### Qualitative Metrics

1. **User Visibility**: Users can see task status and artifacts in TODO.md
2. **Workflow Consistency**: TODO.md and state.json always synchronized
3. **Pattern Enforcement**: New workflow commands follow postflight pattern
4. **Documentation Quality**: postflight-pattern.md is clear and complete

### Validation Checklist

- [ ] Task 323 TODO.md fixed (baseline validation)
- [ ] New test task works end-to-end
- [ ] TODO.md and state.json synchronized
- [ ] Git commits include both files
- [ ] No regression in existing commands
- [ ] postflight-pattern.md created and clear
- [ ] /meta subagents updated for context loading
- [ ] Test results documented

---

## Artifacts and Outputs

### Primary Artifacts

1. **researcher.md** (updated):
   - step_0_preflight with status-sync-manager delegation
   - step_4_postflight with status-sync-manager delegation
   - Defense-in-depth verification
   - Explicit execution notes

2. **postflight-pattern.md** (new):
   - Pattern specification
   - Examples from working implementations
   - Validation checklist
   - Common mistakes
   - Enforcement guidelines

3. **meta.md and related subagents** (updated):
   - Context loading directive
   - Validation step
   - Documentation

### Supporting Artifacts

1. **Implementation summary**:
   - Root cause explanation
   - Fix description
   - Test results
   - Before/after comparison

2. **Test results**:
   - Task 323 fix validation
   - New test task results
   - Regression test results

3. **Git commit**:
   - All changes bundled
   - Descriptive commit message
   - References to task 320 and research-004.md

---

## Rollback/Contingency

### Rollback Plan

If fix causes regressions:

1. **Immediate Rollback**:
   - Use git to revert commit
   - Restore previous researcher.md version
   - Remove postflight-pattern.md
   - Restore /meta subagents

2. **Investigation**:
   - Analyze what went wrong
   - Check if specification-implementation gap persists
   - Review test results for clues

3. **Alternative Approach**:
   - Consider manual TODO.md updates as workaround
   - Create /sync command for synchronization
   - Investigate architectural changes if needed

### Contingency Plan

If specification-implementation gap persists:

1. **Manual Workaround**:
   - Document manual TODO.md update procedure
   - Create /sync command to synchronize TODO.md and state.json
   - Use as temporary solution

2. **Architectural Investigation**:
   - Investigate why AI agents don't follow specifications
   - Consider alternative delegation mechanisms
   - Explore enforcement strategies

3. **Long-Term Solution**:
   - Redesign workflow architecture if needed
   - Implement automated verification
   - Add monitoring and alerting

---

## Dependencies

### Task Dependencies

1. **Task 324** (completed): Root cause investigation
   - Provides evidence for fix strategy
   - Validates problem still exists
   - Identifies specific failure point

### File Dependencies

1. **researcher.md**: Main file to update
2. **planner.md**: Template for working pattern
3. **implementer.md**: Additional template reference
4. **status-sync-manager.md**: Delegation target specification
5. **git-workflow-manager.md**: Git commit delegation specification

### Context Dependencies

1. **subagent-return-format.md**: Return format specification
2. **artifact-management.md**: Artifact handling standards
3. **status-markers.md**: Status marker conventions
4. **tasks.md**: Task entry format standards

---

## References

### Research Reports

- **research-004.md**: Root cause analysis and fix strategy (2026-01-06)
- **research-001.md**: Initial postflight failure analysis
- **research-002.md**: status-sync-manager bug analysis
- **research-003.md**: Task 321 analysis

### Task Evidence

- **Task 323**: Test case proving problem exists
- **Task 324**: Root cause investigation (completed)
- **Task 314**: Example of working /implement command
- **Task 315**: Example of working /plan command

### Specifications

- **researcher.md** (lines 330-450): Current postflight specification
- **planner.md** (lines 411-530): Working postflight implementation
- **implementer.md** (lines 275-380): Working postflight implementation
- **status-sync-manager.md**: Delegation target specification

---

## Summary

**Root Cause**: researcher.md bypasses status-sync-manager in step_4_postflight, using direct jq commands instead of delegation. This leaves TODO.md in stale state.

**Fix Strategy**: Copy the working delegation pattern from planner.md to researcher.md. The specification already exists but needs explicit execution notes and validation checkpoints.

**Documentation**: Create postflight-pattern.md in context/core/workflow/ to enforce this pattern for all future workflow commands.

**Context Loading**: Update /meta subagents to load postflight-pattern.md selectively when creating workflow commands.

**Validation**: Test with task 323 (existing broken case) and new test task (end-to-end validation).

**Estimated Effort**: 4-6 hours (6 phases)

**Complexity**: Medium (straightforward fix, but requires careful testing)

**Next Steps**: Implement Phase 1 (fix researcher.md step_4_postflight)

---

**Plan Created**: 2026-01-05  
**Plan Revised**: 2026-01-06  
**Plan Version**: 7  
**Estimated Total Effort**: 4-6 hours  
**Complexity**: Medium  
**Research Integrated**: Yes (research-004.md integrated in this version)  
**Revision Reason**: Integrated research-004.md findings which identified the root cause: researcher.md bypasses status-sync-manager in step_4_postflight. The fix is straightforward - copy the working pattern from planner.md to researcher.md and document the correct pattern in context/core/ files.
