# Implementation Plan: Fix lean-research-agent Preflight Status Updates and Artifact Linking

**Task**: 290  
**Created**: 2026-01-04  
**Status**: [NOT STARTED]  
**Estimated Effort**: 2-3 hours  
**Complexity**: Low-Medium  
**Language**: markdown

## Metadata

- **Task Number**: 290
- **Task Name**: Fix lean-research-agent preflight status updates and artifact linking
- **Estimated Hours**: 2.5
- **Language**: markdown
- **Priority**: High
- **Dependencies**: Task 289 (completed)
- **Research Integrated**: Yes
- **Research Report**: specs/290_fix_lean_research_agent_preflight_status_updates_and_artifact_linking/reports/research-001.md

## Overview

### Problem Statement

After Task 289 fixed step naming inconsistency in Lean subagents, `/research 260` (a Lean task) still exhibits behavior differences from the standard workflow:

1. **Unnecessary summary artifact**: Creates and links both a research report AND a summary (old behavior), when only the research report should be created and linked
2. **Direct file manipulation**: Updates TODO.md and state.json directly instead of delegating to status-sync-manager and git-workflow-manager

**Note**: The task description's claim about missing preflight status updates is INCORRECT. Research revealed that preflight updates ARE working correctly after Task 289.

### Scope

**In Scope**:
- Remove summary artifact requirements from lean-research-agent.md
- Replace direct file manipulation with status-sync-manager delegation
- Add git-workflow-manager delegation for automatic commits
- Align lean-research-agent behavior with researcher.md standard

**Out of Scope**:
- Preflight status updates (already working correctly)
- Other Lean subagents (lean-planner, lean-implementation-agent)
- General researcher.md (already correct)

### Constraints

- Must maintain backward compatibility with existing Lean research tasks
- Must not affect research quality or functionality
- Must follow researcher.md pattern exactly
- Must use atomic updates via status-sync-manager

### Definition of Done

- [ ] Summary artifact requirements removed from lean-research-agent.md
- [ ] Direct TODO.md/state.json updates replaced with status-sync-manager delegation
- [ ] git-workflow-manager delegation added for automatic commits
- [ ] `/research` on Lean tasks creates only research report (no summary)
- [ ] Artifact links in TODO.md show only research report
- [ ] state.json updated atomically with research report path
- [ ] Git commit created automatically
- [ ] Behavior matches researcher.md exactly
- [ ] No regression in Lean research functionality

## Goals and Non-Goals

### Goals

1. **Remove summary artifact creation**: Eliminate outdated summary artifact requirements
2. **Delegate status updates**: Replace direct file manipulation with status-sync-manager
3. **Add git automation**: Delegate to git-workflow-manager for automatic commits
4. **Align with standard**: Match researcher.md behavior exactly

### Non-Goals

1. Fix preflight status updates (already working)
2. Modify other Lean subagents (separate tasks)
3. Change research report format or content
4. Modify researcher.md (already correct)

## Risks and Mitigations

### Risk 1: Breaking Existing Lean Research Tasks

**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**: Only affects future tasks; existing task artifacts remain unchanged

### Risk 2: Status Synchronization Failures

**Likelihood**: Low  
**Impact**: High  
**Mitigation**: Use proven status-sync-manager pattern from researcher.md; test thoroughly

### Risk 3: Git Commit Failures

**Likelihood**: Low  
**Impact**: Low  
**Mitigation**: Git failures are non-critical; logged but don't fail command

## Implementation Phases

### Phase 1: Remove Summary Artifact Requirements (1 hour)

**Objective**: Eliminate outdated summary artifact creation and validation

**Tasks**:
1. Remove `<summary_artifact_enforcement>` section (lines 452-496)
2. Update step_4 process (lines 430-558):
   - Remove step 3 "Create research summary artifact"
   - Remove summaries/ directory creation
   - Keep only research report creation
3. Update step_6 validation (lines 641-700):
   - Remove line 647: "Verify summary artifact created"
   - Remove lines 648-649: Summary validation
   - Remove line 657: Summary link in TODO.md
   - Remove line 665: "AND summary artifact"
4. Update return format (lines 700+):
   - Remove summary artifact from artifacts array
   - Keep only research report

**Acceptance Criteria**:
- [ ] No references to summary artifact creation
- [ ] No summaries/ directory creation
- [ ] Only research report in artifacts array
- [ ] Validation checks only research report

**Estimated Time**: 1 hour

### Phase 2: Replace Direct File Updates with status-sync-manager Delegation (1 hour)

**Objective**: Replace direct TODO.md and state.json manipulation with atomic status-sync-manager delegation

**Tasks**:
1. Locate direct file update code in step_6 (lines 651-662):
   - Lines 651-657: Direct TODO.md status marker update
   - Lines 658-662: Direct state.json update
2. Replace with status-sync-manager delegation pattern from researcher.md:
   - Prepare delegation context with validated_artifacts
   - Invoke status-sync-manager to mark [RESEARCHED]
   - Pass research report path and metadata
   - Validate status-sync-manager return
3. Remove direct file manipulation code
4. Update step_6 documentation to reflect delegation pattern

**Reference**: researcher.md step_4_postflight (lines 331-379)

**Acceptance Criteria**:
- [ ] No direct TODO.md updates in lean-research-agent.md
- [ ] No direct state.json updates in lean-research-agent.md
- [ ] status-sync-manager invoked with correct parameters
- [ ] Atomic updates across TODO.md and state.json
- [ ] Error handling for status-sync-manager failures

**Estimated Time**: 1 hour

### Phase 3: Add git-workflow-manager Delegation (30 minutes)

**Objective**: Add automatic git commit creation via git-workflow-manager delegation

**Tasks**:
1. Add git-workflow-manager invocation after status-sync-manager
2. Prepare delegation context with scope_files:
   - Research report path
   - specs/TODO.md
   - specs/state.json
3. Set message_template: "task {number}: research completed"
4. Handle git-workflow-manager return:
   - Extract commit_hash if successful
   - Log error if failed (non-critical)
   - Include warning in return if git failed
5. Update step_6 documentation

**Reference**: researcher.md step_4_postflight (lines 349-368)

**Acceptance Criteria**:
- [ ] git-workflow-manager invoked after status-sync-manager
- [ ] Scope files include report, TODO.md, state.json
- [ ] Commit message follows standard format
- [ ] Git failures logged but don't fail command
- [ ] Commit hash included in return metadata

**Estimated Time**: 30 minutes

### Phase 4: Testing and Validation (30 minutes)

**Objective**: Verify changes work correctly with Lean research tasks

**Tasks**:
1. Test `/research` on a Lean task (e.g., task 260 or create test task)
2. Verify status updates to [RESEARCHING] at start (already working)
3. Verify status updates to [RESEARCHED] at end
4. Verify only research report created (no summary)
5. Verify only research report linked in TODO.md
6. Verify state.json updated with report path only
7. Verify git commit created automatically
8. Verify no regression in research quality
9. Compare with `/plan` and general `/research` behavior

**Acceptance Criteria**:
- [ ] Lean research creates only report artifact
- [ ] TODO.md shows only report link
- [ ] state.json has only report path
- [ ] Git commit created with correct message
- [ ] Status transitions work correctly
- [ ] Research quality unchanged
- [ ] Behavior matches researcher.md

**Estimated Time**: 30 minutes

## Testing and Validation

### Unit Testing

**Not Applicable**: Changes are to documentation/specification files, not code

### Integration Testing

**Test Case 1: Lean Research Task**
- **Setup**: Create or use existing Lean task
- **Action**: Run `/research {task_number}`
- **Expected**: Only research report created and linked
- **Validation**: Check TODO.md, state.json, git log

**Test Case 2: Status Synchronization**
- **Setup**: Lean task in [NOT STARTED] status
- **Action**: Run `/research {task_number}`
- **Expected**: Status → [RESEARCHING] → [RESEARCHED]
- **Validation**: Check TODO.md and state.json status markers

**Test Case 3: Git Automation**
- **Setup**: Lean research task
- **Action**: Run `/research {task_number}`
- **Expected**: Git commit created automatically
- **Validation**: Check git log for commit with correct message

### Regression Testing

**Test Case 1: General Research**
- **Setup**: Non-Lean task
- **Action**: Run `/research {task_number}`
- **Expected**: No change in behavior
- **Validation**: Verify researcher.md still works correctly

**Test Case 2: Existing Lean Tasks**
- **Setup**: Previously researched Lean task (e.g., task 260)
- **Action**: Review existing artifacts
- **Expected**: Old artifacts unchanged
- **Validation**: Verify task 260 summary artifact still exists

## Artifacts and Outputs

### Modified Files

1. `.opencode/agent/subagents/lean-research-agent.md`
   - Remove summary artifact requirements
   - Replace direct file updates with status-sync-manager delegation
   - Add git-workflow-manager delegation

### Created Files

None (only modifying existing file)

### Documentation Updates

**lean-research-agent.md**:
- Updated step_4 process (artifact creation)
- Updated step_6 validation (artifact validation)
- Updated step_7 postflight (status updates and git commits)
- Updated return format (artifacts array)

## Rollback/Contingency

### Rollback Plan

**If Changes Cause Issues**:
1. Revert lean-research-agent.md to previous version
2. Restore from git: `git checkout HEAD~1 .opencode/agent/subagents/lean-research-agent.md`
3. Test with Lean research task to verify rollback successful

### Contingency Plan

**If status-sync-manager Delegation Fails**:
1. Check status-sync-manager.md for correct invocation pattern
2. Verify delegation context format matches researcher.md
3. Add detailed error logging to identify failure point
4. Fall back to direct file updates temporarily if needed

**If git-workflow-manager Delegation Fails**:
1. Git failures are non-critical - log and continue
2. User can manually commit if needed
3. Investigate git-workflow-manager logs for root cause

## Success Metrics

### Quantitative Metrics

1. **Artifact Count**: 1 artifact per Lean research task (down from 2)
2. **Status Sync Success Rate**: 100% (atomic updates via status-sync-manager)
3. **Git Automation Rate**: >95% (git-workflow-manager creates commits)

### Qualitative Metrics

1. **Consistency**: Lean research matches general research behavior
2. **Simplicity**: Fewer artifacts to manage and validate
3. **Reliability**: Atomic updates prevent synchronization failures

### Validation Criteria

- [ ] Lean research creates only 1 artifact (report)
- [ ] TODO.md and state.json synchronized atomically
- [ ] Git commits created automatically
- [ ] Behavior matches researcher.md exactly
- [ ] No regression in research quality

## Dependencies

### Upstream Dependencies

- **Task 289**: Completed (fixed Lean subagent step naming)
- **status-sync-manager**: Must support mark_researched operation
- **git-workflow-manager**: Must support commit creation

### Downstream Dependencies

- **Task 291**: Will implement this plan (if created)
- **Future Lean Research**: Will benefit from simplified workflow

## Notes

### Research Findings

Research revealed that the task description's assumption about missing preflight status updates is INCORRECT. Preflight updates ARE working correctly after Task 289. The actual issues are:

1. **Outdated documentation**: lean-research-agent.md requires summary artifacts (old behavior)
2. **Direct file manipulation**: Updates TODO.md/state.json directly instead of delegating

### Alignment with researcher.md

This plan aligns lean-research-agent.md with researcher.md by:
- Removing summary artifact creation
- Delegating to status-sync-manager for atomic updates
- Delegating to git-workflow-manager for automatic commits
- Following the same step_4_postflight pattern

### Impact on Existing Tasks

Existing Lean research tasks (e.g., task 260) are unaffected:
- Old summary artifacts remain in place
- No cleanup needed
- Only future tasks use new behavior

## Phase Status

- [ ] Phase 1: Remove Summary Artifact Requirements [NOT STARTED]
- [ ] Phase 2: Replace Direct File Updates [NOT STARTED]
- [ ] Phase 3: Add git-workflow-manager Delegation [NOT STARTED]
- [ ] Phase 4: Testing and Validation [NOT STARTED]
