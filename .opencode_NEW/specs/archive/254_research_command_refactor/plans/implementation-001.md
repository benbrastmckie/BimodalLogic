# Implementation Plan: Refactor /research Command

**Task**: 254 - Refactor /research command to directly invoke agents and properly manage task status and state updates  
**Plan Version**: 001  
**Created**: 2025-12-29T19:03:42Z  
**Status**: [NOT STARTED]  
**Estimated Effort**: 6-8 hours  
**Priority**: High  
**Complexity**: Medium  
**Language**: markdown

---

## Metadata

**Research Inputs**: 
- Research Report: `.opencode/research/task-254-research-command-refactor.md`
- Key Findings: Split implementation (research.md + research-routing.md + research.md.backup) causes workflow to stop after routing stages 1-3. Root cause: workflow defined as XML documentation rather than executable code. Solution: Adopt OpenAgents frontmatter delegation pattern proven in Task 240 migration.

**Dependencies**: None  
**Blocking**: None  
**Related Tasks**: Task 240 (OpenAgents migration), Tasks 244-247 (frontmatter delegation patterns)

---

## Overview

### Problem Statement

The /research command is experiencing systematic failures:
1. Workflow stops after routing stages 1-3, never executing stages 4-8
2. No status updates to [RESEARCHING] at start or [RESEARCHED] at completion
3. state.json not updated with status transitions or artifact paths
4. Research reports not linked back to TODO.md task entries
5. No git commits created for research artifacts and status updates
6. Split implementation across 3 files (research.md, research-routing.md, research.md.backup) creates confusion

Root cause: Command contains workflow as XML documentation (narrative) rather than executable code, causing Claude to skip stages 4-8 as optional guidance.

### Scope

**In Scope**:
- Delete redundant files (research-routing.md, research.md.backup)
- Simplify research.md to frontmatter delegation pattern (150-200 lines)
- Update researcher.md to own complete workflow including status updates
- Implement status transitions via status-sync-manager ([RESEARCHING] → [RESEARCHED])
- Implement state.json updates following state-management.md schema
- Link research reports to TODO.md task entries
- Create git commits via git-workflow-manager
- Implement proper argument parsing (task_number, prompt, --divide flag)
- Use state.json for language field lookup instead of parsing TODO.md
- Follow lazy directory creation per artifact-management.md
- Validate against delegation.md return format requirements
- Test with both Lean and markdown tasks

**Out of Scope**:
- Changes to lean-research-agent.md (separate agent, not modified in this task)
- Changes to other commands (/plan, /implement, /revise)
- Implementation of --divide flag functionality (flag parsing only, functionality deferred)
- Changes to status-sync-manager or git-workflow-manager (use as-is)

### Constraints

- Must follow OpenAgents frontmatter delegation pattern from Task 240
- Must maintain backward compatibility with existing research artifacts
- Must not break existing /research command usage patterns
- research.md must be 150-200 lines (down from 272 lines)
- All status updates must be atomic (TODO.md + state.json together)
- Must follow lazy directory creation (no pre-creation during routing)
- Must use text-based status indicators ([PASS]/[FAIL]/[WARN])

### Definition of Done

- Single research.md file with frontmatter delegation (150-200 lines)
- research-routing.md and research.md.backup deleted
- researcher.md owns complete workflow with status updates and git commits
- /research command successfully updates status to [RESEARCHING] before agent invocation
- /research command successfully updates status to [RESEARCHED] after completion
- state.json updated with proper status transitions and artifact paths
- Research reports linked in TODO.md task entries
- Git commits created with research artifacts and status updates
- Lazy directory creation validated (no pre-creation)
- Return format validates against delegation.md schema
- Tested successfully with both Lean task and markdown task
- All 15 acceptance criteria from task description met

---

## Goals and Non-Goals

### Goals

1. **Eliminate Redundancy**: Single source of truth for /research command
2. **Complete Workflow Execution**: Stages 1-8 execute reliably (100% Stage 7 execution)
3. **Proper Status Management**: Atomic status updates via status-sync-manager
4. **State Tracking**: state.json updated with status and artifacts
5. **Artifact Linking**: Research reports linked in TODO.md
6. **Git Integration**: Commits created via git-workflow-manager
7. **Simplified Command**: research.md reduced to 150-200 lines
8. **Agent Ownership**: researcher.md owns complete workflow
9. **Validation**: Return format follows delegation.md standard
10. **Testing**: Validated with both Lean and markdown tasks

### Non-Goals

1. Implementing --divide flag functionality (parsing only, functionality deferred)
2. Modifying lean-research-agent.md workflow
3. Changing other workflow commands (/plan, /implement, /revise)
4. Refactoring status-sync-manager or git-workflow-manager
5. Adding new research capabilities beyond status/state management

---

## Risks and Mitigations

### Risk 1: Breaking Existing Research Workflows
**Likelihood**: Medium  
**Impact**: High  
**Mitigation**: 
- Test with existing tasks before deployment
- Maintain backward compatibility with existing research artifacts
- Validate argument parsing matches current behavior
- Test both Lean and markdown task routing

### Risk 2: Status Update Failures
**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- Use proven status-sync-manager pattern from /plan and /implement
- Implement atomic updates (all files or none)
- Add validation checks before and after status updates
- Test status transitions with multiple scenarios

### Risk 3: Git Commit Failures
**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Use proven git-workflow-manager pattern from /plan and /implement
- Git failures are non-critical (warn but don't fail command)
- Provide manual recovery instructions if git fails
- Test git workflow with clean repository state

### Risk 4: Incomplete Workflow Execution
**Likelihood**: Low (with proper implementation)  
**Impact**: High  
**Mitigation**:
- Follow Task 240 proven pattern exactly
- Move workflow ownership to researcher.md agent
- Remove XML documentation from command file
- Validate Stage 7 execution in testing

### Risk 5: Language Routing Failures
**Likelihood**: Low  
**Impact**: Medium  
**Mitigation**:
- Use state.json for language lookup (more reliable than TODO.md parsing)
- Add fallback to TODO.md parsing if state.json missing
- Test routing with both Lean and markdown tasks
- Log routing decisions for debugging

---

## Implementation Phases

### Phase 1: Clean Up Redundant Files and Analyze Current State [COMPLETED]
**Estimated Effort**: 0.5 hours  
**Status**: [COMPLETED]
**Started**: 2025-12-29T00:00:00Z
**Completed**: 2025-12-29T00:00:00Z

**Objectives**:
- Remove redundant files to establish single source of truth
- Analyze current research.md structure
- Document current researcher.md workflow ownership

**Tasks**:
1. Delete `.opencode/command/research-routing.md` (redundant routing file)
2. Delete `.opencode/command/research.md.backup` (outdated backup)
3. Verify only `research.md` remains in command directory
4. Read current `researcher.md` to understand existing workflow
5. Document current workflow gaps (missing status updates, git commits)
6. Create backup of current research.md for reference

**Validation**:
- [PASS] Only research.md exists in .opencode/command/ (no research-routing.md or research.md.backup)
- [PASS] Current researcher.md workflow documented
- [PASS] Workflow gaps identified and documented

**Deliverables**:
- Redundant files deleted
- Current state documented
- Workflow gap analysis

---

### Phase 2: Simplify research.md to Frontmatter Delegation Pattern [COMPLETED]
**Estimated Effort**: 1 hour  
**Status**: [COMPLETED]
**Started**: 2025-12-29T00:00:00Z
**Completed**: 2025-12-29T00:00:00Z

**Objectives**:
- Reduce research.md from 272 lines to 150-200 lines
- Remove routing stages XML documentation
- Keep frontmatter delegation pattern
- Maintain usage examples and artifact descriptions

**Tasks**:
1. Keep frontmatter delegation (lines 1-10) with routing configuration
2. Keep purpose, usage, examples sections (clear user documentation)
3. Keep artifacts created, status transitions sections (reference documentation)
4. Remove routing stages 1-3 XML documentation (move to researcher.md)
5. Remove execution stage references (researcher.md owns execution)
6. Remove detailed context loading instructions (use context/index.md)
7. Add brief workflow description delegating to researcher agent
8. Validate file size is 150-200 lines
9. Validate frontmatter matches /plan and /implement patterns

**Validation**:
- [PASS] research.md is 150-200 lines (down from 272 lines)
- [PASS] Frontmatter delegation pattern matches /plan and /implement
- [PASS] No routing stages XML documentation in command file
- [PASS] Usage examples and artifact descriptions preserved
- [PASS] Brief workflow description delegates to researcher agent

**Deliverables**:
- Simplified research.md (150-200 lines)
- Frontmatter delegation pattern implemented
- Clear user documentation preserved

---

### Phase 3: Update researcher.md with Complete Workflow Ownership [COMPLETED]
**Estimated Effort**: 2 hours  
**Status**: [COMPLETED]
**Started**: 2025-12-29T00:00:00Z
**Completed**: 2025-12-29T00:00:00Z

**Objectives**:
- researcher.md owns complete workflow (stages 1-6)
- Implement status updates via status-sync-manager
- Implement git commits via git-workflow-manager
- Implement proper argument parsing
- Use state.json for language field lookup

**Tasks**:
1. Add Stage 1 (Preflight):
   - Parse task_number, prompt, --divide flag from delegation context
   - Validate task exists in TODO.md
   - Extract language from state.json (fallback to TODO.md parsing)
   - Invoke status-sync-manager to mark [RESEARCHING]
   - Add **Started**: {date} timestamp
2. Add Stage 2 (Research Execution):
   - Conduct research using web sources, documentation
   - Gather findings, citations, recommendations
   - Create research report content
3. Add Stage 3 (Artifact Creation):
   - Lazy create project directory: specs/{task_number}_{slug}/
   - Lazy create reports/ subdirectory
   - Write research-001.md report
   - Validate artifact exists and is non-empty
4. Add Stage 4 (Validation):
   - Verify research report created successfully
   - Verify report contains findings and citations
   - Prepare return object with artifact path and summary
5. Add Stage 5 (Postflight):
   - Invoke status-sync-manager to mark [RESEARCHED]
   - Add **Completed**: {date} timestamp
   - Link research report in TODO.md task entry
   - Update state.json with artifact path
   - Invoke git-workflow-manager to create commit
6. Add Stage 6 (Return):
   - Return standardized format per delegation.md
   - Include brief summary (<100 tokens)
   - Include artifact path
   - Include session metadata

**Validation**:
- [PASS] researcher.md owns stages 1-6 workflow
- [PASS] Stage 1 invokes status-sync-manager for [RESEARCHING]
- [PASS] Stage 5 invokes status-sync-manager for [RESEARCHED]
- [PASS] Stage 5 invokes git-workflow-manager for commit
- [PASS] Argument parsing extracts task_number, prompt, --divide
- [PASS] Language extracted from state.json (fallback to TODO.md)
- [PASS] Lazy directory creation (no pre-creation)
- [PASS] Return format follows delegation.md schema

**Deliverables**:
- researcher.md with complete workflow ownership
- Status updates via status-sync-manager
- Git commits via git-workflow-manager
- Proper argument parsing
- state.json language lookup

---

### Phase 4: Implement Status-Sync-Manager Integration [COMPLETED]
**Estimated Effort**: 1.5 hours  
**Status**: [COMPLETED]
**Started**: 2025-12-29T00:00:00Z
**Completed**: 2025-12-29T00:00:00Z

**Objectives**:
- Integrate status-sync-manager for atomic status updates
- Implement [RESEARCHING] status update in Stage 1
- Implement [RESEARCHED] status update in Stage 5
- Update state.json with status transitions and artifacts

**Tasks**:
1. Stage 1 status-sync-manager delegation:
   - Prepare delegation context (task_number, new_status: "researching", timestamp)
   - Invoke status-sync-manager with timeout (60s)
   - Validate return status == "completed"
   - Verify files_updated includes ["TODO.md", "state.json"]
   - Abort if status update fails
2. Stage 5 status-sync-manager delegation:
   - Prepare delegation context (task_number, new_status: "researched", timestamp, validated_artifacts)
   - Invoke status-sync-manager with timeout (60s)
   - Validate return status == "completed"
   - Verify files_updated includes ["TODO.md", "state.json"]
   - Verify artifact linked in TODO.md
   - Abort if status update fails
3. state.json update schema:
   - Add "status": "researching" in Stage 1
   - Add "started": "{date}" in Stage 1
   - Add "status": "researched" in Stage 5
   - Add "completed": "{date}" in Stage 5
   - Add "artifacts": [{type, path, summary}] in Stage 5
4. Atomic update validation:
   - Verify TODO.md and state.json updated together
   - Verify rollback on failure (no partial updates)
   - Test with status-sync-manager error scenarios

**Validation**:
- [PASS] Stage 1 marks task [RESEARCHING] in TODO.md
- [PASS] Stage 1 updates state.json status to "researching"
- [PASS] Stage 5 marks task [RESEARCHED] in TODO.md
- [PASS] Stage 5 updates state.json status to "researched"
- [PASS] Stage 5 links research report in TODO.md
- [PASS] Stage 5 updates state.json artifacts array
- [PASS] Atomic updates verified (all files or none)
- [PASS] Rollback tested on failure scenarios

**Deliverables**:
- status-sync-manager integration in Stage 1 and Stage 5
- Atomic status updates across TODO.md and state.json
- state.json schema updates with status and artifacts

---

### Phase 5: Implement Git-Workflow-Manager Integration [COMPLETED]
**Estimated Effort**: 1 hour  
**Status**: [COMPLETED]
**Started**: 2025-12-29T00:00:00Z
**Completed**: 2025-12-29T00:00:00Z

**Objectives**:
- Integrate git-workflow-manager for standardized commits
- Create commits after successful research completion
- Scope files correctly (research report + status files)
- Handle git failures gracefully (non-critical)

**Tasks**:
1. Stage 5 git-workflow-manager delegation:
   - Prepare delegation context (scope_files, message_template, task_context)
   - scope_files: [research_report_path, TODO.md, state.json, project_state.json]
   - message_template: "task {number}: research completed"
   - Invoke git-workflow-manager with timeout (120s)
   - Validate return status (completed or failed)
2. Git failure handling:
   - If status == "completed": Log commit hash
   - If status == "failed": Log warning (non-critical)
   - Git failure does not fail research command
   - Provide manual recovery instructions
3. Commit message format:
   - "task 254: research completed"
   - Follow git-commits.md standard
4. File scoping:
   - Add research report path
   - Add specs/TODO.md
   - Add specs/state.json
   - Add specs/{task_number}_{slug}/state.json
   - Do NOT use `git add -A` (scoped additions only)

**Validation**:
- [PASS] git-workflow-manager invoked in Stage 5
- [PASS] Commit created with research artifacts and status updates
- [PASS] Commit message follows standard format
- [PASS] Files scoped correctly (no `git add -A`)
- [PASS] Git failures handled gracefully (non-critical)
- [PASS] Manual recovery instructions provided on failure

**Deliverables**:
- git-workflow-manager integration in Stage 5
- Standardized git commits for research completion
- Graceful git failure handling

---

### Phase 6: Implement Validation and Error Handling [COMPLETED]
**Estimated Effort**: 1 hour  
**Status**: [COMPLETED]
**Started**: 2025-12-29T00:00:00Z
**Completed**: 2025-12-29T00:00:00Z

**Objectives**:
- Validate return format against delegation.md schema
- Implement error handling for common failure scenarios
- Provide actionable recovery instructions
- Validate artifact creation before returning

**Tasks**:
1. Return format validation:
   - Validate status field (completed/failed/partial/blocked)
   - Validate summary field (<100 tokens)
   - Validate artifacts array (type, path, summary)
   - Validate metadata (session_id, duration, agent_type, delegation_depth, delegation_path)
   - Validate errors array (if status != completed)
2. Artifact validation:
   - Verify research report exists on disk
   - Verify research report is non-empty (size > 0)
   - Verify summary field in return object is brief (<100 tokens)
   - Return validation result in metadata field
3. Error handling scenarios:
   - Task not found: Return error with recommendation
   - Language extraction failed: Warn and default to "general"
   - Research timeout: Return partial status with artifacts found
   - Status update failed: Return error with manual recovery steps
   - Git commit failed: Warn but don't fail command
4. Recovery instructions:
   - Task not found: "Verify task number exists in TODO.md"
   - Status update failed: "Manually update TODO.md and state.json, or retry /research {number}"
   - Git commit failed: "Manually commit with: git add {files}; git commit -m 'task {number}: research completed'"

**Validation**:
- [PASS] Return format validates against delegation.md schema
- [PASS] Artifact validation checks exist and non-empty
- [PASS] Summary field within token limit (<100 tokens)
- [PASS] Error handling covers all common scenarios
- [PASS] Recovery instructions are actionable
- [PASS] Validation failures return proper error format

**Deliverables**:
- Return format validation
- Artifact validation checks
- Comprehensive error handling
- Actionable recovery instructions

---

### Phase 7: Testing and Validation [COMPLETED]
**Estimated Effort**: 1.5 hours  
**Status**: [COMPLETED]
**Started**: 2025-12-29T00:00:00Z
**Completed**: 2025-12-29T00:00:00Z

**Objectives**:
- Test /research command with both Lean and markdown tasks
- Validate all status transitions
- Verify state.json updates
- Confirm git commits created
- Validate return format
- Test error scenarios

**Tasks**:
1. Test 1: Basic research (markdown task)
   - Run: `/research 254`
   - Verify: TODO.md shows [RESEARCHING] during execution
   - Verify: TODO.md shows [RESEARCHED] after completion
   - Verify: state.json status = "researched"
   - Verify: Research report exists at expected path
   - Verify: Research report linked in TODO.md
   - Verify: Git commit created with message "task 254: research completed"
2. Test 2: Research with prompt (markdown task)
   - Run: `/research 254 "Focus on status transitions"`
   - Verify: Same validations as Test 1
   - Verify: Prompt incorporated into research
3. Test 3: Research with --divide flag (markdown task)
   - Run: `/research 254 --divide`
   - Verify: Flag parsed correctly (functionality deferred, no error)
   - Verify: Same validations as Test 1
4. Test 4: Lean task routing
   - Run: `/research {lean_task_number}`
   - Verify: Routes to lean-research-agent (not researcher)
   - Verify: Same status updates and git commits
   - Verify: Lean-specific tools available
5. Test 5: Error handling
   - Run: `/research 9999` (non-existent task)
   - Verify: Error message "Task 9999 not found"
   - Verify: No status updates
   - Verify: No artifacts created
   - Verify: Actionable recovery instructions
6. Validation checks:
   - research.md is 150-200 lines
   - No redundant files (research-routing.md, research.md.backup deleted)
   - Lazy directory creation (no pre-creation)
   - Return format validates against delegation.md
   - All 15 acceptance criteria met

**Validation**:
- [PASS] Test 1: Basic research completes successfully
- [PASS] Test 2: Research with prompt completes successfully
- [PASS] Test 3: --divide flag parsed correctly
- [PASS] Test 4: Lean task routes to lean-research-agent
- [PASS] Test 5: Error handling works correctly
- [PASS] All validation checks pass
- [PASS] All 15 acceptance criteria met

**Deliverables**:
- Test results documented
- All tests passing
- Validation checks confirmed
- Acceptance criteria verified

---

## Testing and Validation

### Unit Testing

**Status Update Testing**:
- Test status-sync-manager invocation in Stage 1 ([RESEARCHING])
- Test status-sync-manager invocation in Stage 5 ([RESEARCHED])
- Test atomic updates (TODO.md + state.json together)
- Test rollback on failure scenarios

**Git Workflow Testing**:
- Test git-workflow-manager invocation in Stage 5
- Test commit message format
- Test file scoping (no `git add -A`)
- Test graceful failure handling

**Argument Parsing Testing**:
- Test task_number extraction
- Test prompt extraction (optional)
- Test --divide flag parsing (optional)
- Test invalid argument handling

**Language Routing Testing**:
- Test state.json language lookup
- Test fallback to TODO.md parsing
- Test Lean task routing to lean-research-agent
- Test markdown task routing to researcher

### Integration Testing

**End-to-End Workflow**:
- Test complete workflow: /research → [RESEARCHING] → research → [RESEARCHED] → git commit
- Test with Lean task (routes to lean-research-agent)
- Test with markdown task (routes to researcher)
- Test with prompt parameter
- Test with --divide flag

**State Management**:
- Verify TODO.md status updates
- Verify state.json status updates
- Verify state.json artifacts array updates
- Verify research report linking in TODO.md

**Error Scenarios**:
- Test task not found error
- Test language extraction failure (fallback)
- Test status update failure (rollback)
- Test git commit failure (non-critical)

### Validation Criteria

**File Structure**:
- [PASS] Only research.md exists (no research-routing.md or research.md.backup)
- [PASS] research.md is 150-200 lines
- [PASS] researcher.md owns complete workflow

**Status Transitions**:
- [PASS] TODO.md updates to [RESEARCHING] in Stage 1
- [PASS] TODO.md updates to [RESEARCHED] in Stage 5
- [PASS] state.json updates atomically with TODO.md
- [PASS] Timestamps added correctly

**Artifact Management**:
- [PASS] Research report created at correct path
- [PASS] Research report linked in TODO.md
- [PASS] state.json artifacts array updated
- [PASS] Lazy directory creation (no pre-creation)

**Git Integration**:
- [PASS] Git commit created after successful research
- [PASS] Commit message follows standard format
- [PASS] Files scoped correctly
- [PASS] Git failures handled gracefully

**Return Format**:
- [PASS] Return format validates against delegation.md
- [PASS] Summary field within token limit (<100 tokens)
- [PASS] Artifacts array populated correctly
- [PASS] Metadata includes session_id, duration, agent_type, delegation_depth, delegation_path

---

## Artifacts and Outputs

### Modified Files

1. `.opencode/command/research.md` (simplified to 150-200 lines)
2. `.opencode/agent/subagents/researcher.md` (complete workflow ownership)

### Deleted Files

1. `.opencode/command/research-routing.md` (redundant)
2. `.opencode/command/research.md.backup` (outdated)

### Created Artifacts (during testing)

1. Research report: `specs/254_research_command_refactor/reports/research-001.md` (already exists)
2. Test research reports for validation tasks

### Updated Files (during execution)

1. `specs/TODO.md` (status updates, research links)
2. `specs/state.json` (status transitions, artifacts)
3. `specs/{task_number}_{slug}/state.json` (project state)

---

## Rollback/Contingency

### Rollback Plan

If implementation fails or causes regressions:

1. **Restore research.md from backup**:
   - Backup created in Phase 1
   - Restore original 272-line version
   - Restore research-routing.md if needed

2. **Revert researcher.md changes**:
   - Git revert commits from this task
   - Restore previous researcher.md version

3. **Clean up test artifacts**:
   - Remove test research reports
   - Revert TODO.md and state.json changes

### Contingency Measures

**If status-sync-manager integration fails**:
- Fall back to manual TODO.md and state.json updates
- Document manual update procedure
- Create follow-up task for status-sync-manager debugging

**If git-workflow-manager integration fails**:
- Git commits are non-critical, can be manual
- Document manual commit procedure
- Create follow-up task for git-workflow-manager debugging

**If language routing fails**:
- Fall back to default researcher agent for all tasks
- Document routing issue
- Create follow-up task for routing fix

**If testing reveals critical issues**:
- Pause deployment
- Document issues in task notes
- Revise plan with additional phases
- Re-test before deployment

---

## Success Metrics

### Quantitative Metrics

1. **File Size Reduction**: research.md reduced from 272 lines to 150-200 lines (26-44% reduction)
2. **File Count Reduction**: 3 files (research.md, research-routing.md, research.md.backup) → 1 file (research.md) (67% reduction)
3. **Stage 7 Execution Rate**: 100% (status updates and git commits always execute)
4. **Test Pass Rate**: 5/5 tests pass (100%)
5. **Acceptance Criteria**: 15/15 criteria met (100%)

### Qualitative Metrics

1. **Code Clarity**: Single source of truth, clear delegation pattern
2. **Workflow Reliability**: Complete workflow execution (stages 1-8)
3. **Status Management**: Atomic status updates, no partial failures
4. **Error Handling**: Comprehensive error scenarios with recovery instructions
5. **Maintainability**: Simplified command file, agent owns workflow

### Validation Checklist

- [PASS] Single /research command file with frontmatter delegation (research.md)
- [PASS] research.md.backup and research-routing.md removed
- [PASS] Command parses arguments correctly (task_number, prompt, --divide)
- [PASS] Language field read from state.json (not TODO.md parsing)
- [PASS] TODO.md status updates to [RESEARCHING] before agent invocation
- [PASS] Appropriate research agent invoked based on language field
- [PASS] TODO.md status updates to [RESEARCHED] after successful completion
- [PASS] state.json updated with proper status transitions
- [PASS] Research report path linked in TODO.md task entry
- [PASS] project state.json artifacts array updated
- [PASS] git commit created after successful research
- [PASS] Lazy directory creation follows artifact-management.md
- [PASS] Error handling includes recovery instructions
- [PASS] Return format validates against delegation.md schema
- [PASS] Tested successfully with both Lean and markdown tasks

---

## References

**Standards**:
- `.opencode/context/core/standards/delegation.md` - Delegation patterns and return format
- `.opencode/context/core/system/state-management.md` - Status markers and state.json schema
- `.opencode/context/core/system/git-commits.md` - Git commit patterns
- `.opencode/context/core/system/artifact-management.md` - Lazy directory creation, artifact patterns

**Successful Patterns**:
- `.opencode/command/plan.md` - Frontmatter delegation, status updates, git commits
- `.opencode/command/implement.md` - Frontmatter delegation, status updates, git commits
- `specs/240_*/reports/research-001.md` - OpenAgents comparative analysis
- `specs/240_*/plans/implementation-002.md` - OpenAgents migration plan with Phase 1 validation

**Current Implementation**:
- `.opencode/command/research.md` - Current routing implementation (272 lines)
- `.opencode/command/research-routing.md` - Redundant file (167 lines)
- `.opencode/command/research.md.backup` - Backup file (678 lines)
- `.opencode/agent/subagents/researcher.md` - Current researcher agent

**Research**:
- `.opencode/research/task-254-research-command-refactor.md` - Research report for this task

---

## Notes

**Implementation Strategy**: Follow Task 240 Phase 1 proven pattern exactly. The OpenAgents frontmatter delegation pattern has demonstrated 100% Stage 7 execution reliability in /plan and /implement commands. This refactoring applies the same architectural pattern to /research command.

**Key Insight**: The root cause of systematic failures is workflow defined as XML documentation (narrative) rather than executable code. Moving workflow ownership from command to agent eliminates this problem because agents execute workflows as code, not documentation.

**Testing Priority**: Focus testing on status transitions and git commits (Stage 7 execution) as these are the primary failure points in the current implementation.

**Backward Compatibility**: Maintain existing /research command usage patterns. Users should not notice any difference except improved reliability (status updates and git commits now work).

**Future Work**: --divide flag functionality is parsed but not implemented in this task. Functionality will be implemented in a follow-up task after core refactoring is validated.
