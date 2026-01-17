# Implementation Plan: Create Task Reviser Subagent

**Task**: 299 - Create Task Reviser Subagent  
**Status**: [NOT STARTED]  
**Estimated Effort**: 3 hours  
**Complexity**: Medium  
**Language**: meta  
**Priority**: High  
**Created**: 2026-01-05  
**Plan Version**: 001  

---

## Overview

### Problem Statement

The current `/revise` command only supports plan revision when a plan already exists. However, users need the ability to revise task descriptions, requirements, and metadata (priority, effort, dependencies) before a plan is created. This is especially important during early-stage task refinement when requirements are still being clarified.

### Scope

Create a new subagent `task-reviser.md` that:
1. Handles task-only revision mode when no plan exists
2. Prompts user for revision details (description, priority, effort, dependencies)
3. Updates TODO.md and state.json atomically via status-sync-manager
4. Returns standardized format per subagent-return-format.md
5. Handles errors gracefully with rollback capability

**In Scope**:
- Task metadata extraction from state.json
- User prompts for revision details
- Atomic updates via status-sync-manager delegation
- Validation for task existence and revision context
- Error handling with rollback
- Git commit creation via git-workflow-manager

**Out of Scope**:
- Plan revision (handled by planner subagent)
- Task creation (handled by task-creator subagent)
- Task archival (handled by status-sync-manager)
- Integration with /revise command (task 301)

### Constraints

- Must follow subagent template structure (agent-template.md)
- Must delegate to status-sync-manager for atomic updates (no direct file writes)
- Must delegate to git-workflow-manager for git commits
- Must return standardized format per subagent-return-format.md
- Must validate task exists before prompting for revisions
- Must preserve task history in state.json
- Must handle concurrent access gracefully

### Definition of Done

- [ ] task-reviser.md created with proper frontmatter and metadata
- [ ] Extracts task metadata from state.json (not TODO.md)
- [ ] Prompts user for revision details with clear guidance
- [ ] Updates TODO.md and state.json atomically via status-sync-manager
- [ ] Returns standardized format with updated task info
- [ ] Handles errors gracefully with rollback via status-sync-manager
- [ ] Creates git commit via git-workflow-manager
- [ ] All validation checks pass
- [ ] Manual testing confirms atomic updates work correctly

---

## Goals and Non-Goals

### Goals

1. **Enable task-only revision**: Support revising task metadata without requiring a plan
2. **Atomic updates**: Ensure TODO.md and state.json stay synchronized
3. **User-friendly prompts**: Guide users through revision process with clear questions
4. **Error resilience**: Handle failures gracefully with rollback capability
5. **Standard integration**: Follow subagent patterns for delegation and return format

### Non-Goals

1. Plan revision (existing planner subagent handles this)
2. Task creation (existing task-creator subagent handles this)
3. Interactive mode (task-reviser is invoked by /revise command with task number)
4. Bulk task updates (single task at a time)

---

## Risks and Mitigations

### Risk 1: Race Conditions During Concurrent Updates

**Likelihood**: Medium  
**Impact**: High  
**Mitigation**: 
- Delegate to status-sync-manager which implements two-phase commit
- status-sync-manager handles file locking and atomic updates
- Validate state.json hasn't changed between read and write

### Risk 2: User Cancels Mid-Revision

**Likelihood**: Medium  
**Impact**: Low  
**Mitigation**:
- Collect all user inputs before delegating to status-sync-manager
- No file writes until all inputs validated
- If user cancels, return early with no side effects

### Risk 3: Invalid User Input

**Likelihood**: High  
**Impact**: Low  
**Mitigation**:
- Validate all inputs before delegation (priority, effort format, description length)
- Provide clear error messages with examples
- Allow user to retry with corrected input

### Risk 4: status-sync-manager Failure

**Likelihood**: Low  
**Impact**: High  
**Mitigation**:
- status-sync-manager implements rollback on failure
- Return detailed error with recovery steps
- Log error for debugging

---

## Implementation Phases

### Phase 1: Create Subagent File Structure [NOT STARTED]

**Objective**: Create task-reviser.md with proper frontmatter and basic structure

**Tasks**:
1. Create `.opencode/agent/subagents/task-reviser.md`
2. Add frontmatter with metadata:
   - name: "task-reviser"
   - version: "1.0.0"
   - description: "Task-only revision when no plan exists"
   - mode: subagent
   - agent_type: utility
   - temperature: 0.2
   - max_tokens: 3000
   - timeout: 600
3. Define tools (read, write, bash)
4. Define permissions (read state.json, write via delegation only)
5. Define context_loading strategy (lazy, required files)
6. Define delegation (can_delegate_to: status-sync-manager, git-workflow-manager)
7. Add lifecycle metadata (stage, return_format)

**Acceptance Criteria**:
- [ ] task-reviser.md exists with valid frontmatter
- [ ] All required metadata fields present
- [ ] Permissions restrict direct file writes
- [ ] Delegation targets specified correctly

**Estimated Effort**: 0.5 hours

---

### Phase 2: Implement Input Validation and Task Extraction [NOT STARTED]

**Objective**: Validate inputs and extract task metadata from state.json

**Tasks**:
1. Add `<inputs_required>` section:
   - task_number (integer, required)
   - session_id (string, required)
   - delegation_depth (integer, required)
   - delegation_path (array, required)
   - revision_context (string, optional - user's reason for revision)
2. Add `<inputs_forbidden>` section (conversation_history, full_system_state)
3. Implement Stage 1 (Input Validation):
   - Validate task_number is positive integer
   - Validate session_id provided
   - Validate delegation_depth < 3
   - Check state.json exists and is valid JSON
4. Implement task metadata extraction:
   - Read state.json
   - Find task by project_number
   - Extract: project_name, description, priority, effort, language, status, dependencies
   - Validate task exists (return error if not found)
   - Validate no plan exists (plan_path empty or missing)
5. Add error handling for missing/invalid task

**Acceptance Criteria**:
- [ ] All required inputs validated
- [ ] Task metadata extracted from state.json
- [ ] Error returned if task not found
- [ ] Error returned if plan already exists
- [ ] Validation follows subagent patterns

**Estimated Effort**: 0.5 hours

---

### Phase 3: Implement User Prompts for Revision Details [NOT STARTED]

**Objective**: Prompt user for revision details with clear guidance

**Tasks**:
1. Implement Stage 3 (Core Execution) - User Prompts:
   - Display current task metadata (description, priority, effort, dependencies)
   - Prompt for new description (optional, default: keep current)
   - Prompt for new priority (optional, default: keep current, validate: Low/Medium/High)
   - Prompt for new effort (optional, default: keep current, validate format)
   - Prompt for new dependencies (optional, default: keep current, validate task numbers exist)
   - Prompt for revision reason (optional, for git commit message)
2. Add input validation:
   - Description: 50-500 characters
   - Priority: Must be "Low", "Medium", or "High"
   - Effort: Must match pattern (e.g., "3 hours", "1 day")
   - Dependencies: Comma-separated task numbers, validate each exists
3. Add confirmation prompt:
   - Display all changes
   - Ask user to confirm before proceeding
   - Allow user to cancel (return early with no changes)
4. Handle user cancellation gracefully

**Acceptance Criteria**:
- [ ] Current task metadata displayed clearly
- [ ] User prompted for each revisable field
- [ ] Input validation provides clear error messages
- [ ] Confirmation prompt shows all changes
- [ ] User can cancel without side effects

**Estimated Effort**: 0.75 hours

---

### Phase 4: Integrate with status-sync-manager for Atomic Updates [NOT STARTED]

**Objective**: Delegate to status-sync-manager for atomic TODO.md and state.json updates

**Tasks**:
1. Prepare delegation context for status-sync-manager:
   - operation: "update_task_metadata"
   - task_number: {task_number}
   - updated_fields: {description, priority, effort, dependencies}
   - timestamp: ISO 8601 date
   - session_id: {session_id}
   - delegation_depth: {current_depth + 1}
   - delegation_path: [...current_path, "task-reviser"]
2. Invoke status-sync-manager:
   - Use task tool with subagent_type="status-sync-manager"
   - Pass delegation context
   - Set timeout: 60s
3. Wait for status-sync-manager return:
   - Maximum wait: 60s
   - If timeout: Return error with recovery steps
4. Validate status-sync-manager return:
   - Verify status == "completed"
   - Verify files_updated includes TODO.md and state.json
   - Verify rollback_performed == false
   - If validation fails: Return error with details
5. Handle status-sync-manager errors:
   - Extract error details from return
   - Log error to errors.json
   - Return error to caller with recovery steps

**Acceptance Criteria**:
- [ ] Delegation context prepared correctly
- [ ] status-sync-manager invoked successfully
- [ ] Return validated per subagent-return-format.md
- [ ] Errors handled gracefully
- [ ] Rollback triggered on failure

**Estimated Effort**: 0.5 hours

---

### Phase 5: Implement Git Commit Creation [NOT STARTED]

**Objective**: Delegate to git-workflow-manager for git commit creation

**Tasks**:
1. Prepare delegation context for git-workflow-manager:
   - scope_files: ["specs/TODO.md", "specs/state.json"]
   - message_template: "task {number}: revised task metadata"
   - task_context: {task_number, description: "revised task metadata"}
   - session_id: {session_id}
   - delegation_depth: {current_depth + 1}
   - delegation_path: [...current_path, "task-reviser"]
2. Invoke git-workflow-manager:
   - Use task tool with subagent_type="git-workflow-manager"
   - Pass delegation context
   - Set timeout: 120s
3. Wait for git-workflow-manager return:
   - Maximum wait: 120s
   - If timeout: Log error (non-critical), continue
4. Validate return:
   - If status == "completed": Extract commit_hash, log success
   - If status == "failed": Log error (non-critical), include warning in return
5. Handle git-workflow-manager errors:
   - Log error to errors.json (non-critical)
   - Include warning in return
   - Continue (git failure doesn't fail command)

**Acceptance Criteria**:
- [ ] Delegation context prepared correctly
- [ ] git-workflow-manager invoked successfully
- [ ] Commit hash extracted on success
- [ ] Errors logged but don't fail command
- [ ] Warning included in return if git fails

**Estimated Effort**: 0.25 hours

---

### Phase 6: Implement Return Formatting and Validation [NOT STARTED]

**Objective**: Format return following subagent-return-format.md and validate all outputs

**Tasks**:
1. Implement Stage 6 (Return Formatting):
   - Create return object with required fields:
     * status: "completed" | "failed"
     * summary: Brief description (<100 tokens)
     * artifacts: [] (no artifacts created, updates only)
     * metadata: {session_id, duration_seconds, agent_type, delegation_depth, delegation_path, updated_fields}
     * errors: [] (if any)
     * next_steps: "Task metadata updated. Use /plan {number} to create implementation plan."
2. Add validation before returning:
   - Verify status-sync-manager completed successfully
   - Verify TODO.md and state.json updated (check mtime)
   - Verify no artifacts accidentally created
   - Verify summary is <100 tokens
3. Add error return format:
   - status: "failed"
   - summary: Error description
   - errors: [{type, message, code, recoverable, recommendation}]
   - next_steps: Recovery steps
4. Implement Stage 8 (Cleanup):
   - Remove temporary files (if any)
   - Log completion

**Acceptance Criteria**:
- [ ] Return format matches subagent-return-format.md
- [ ] All required fields present
- [ ] Summary is concise (<100 tokens)
- [ ] Validation checks pass
- [ ] Error format follows standard

**Estimated Effort**: 0.25 hours

---

### Phase 7: Testing and Documentation [NOT STARTED]

**Objective**: Test task-reviser end-to-end and document usage

**Tasks**:
1. Manual testing:
   - Test with valid task (no plan exists)
   - Test with invalid task number (should fail)
   - Test with task that has plan (should fail)
   - Test user cancellation (should return early)
   - Test invalid inputs (priority, effort, dependencies)
   - Test status-sync-manager failure (should rollback)
   - Test git-workflow-manager failure (should warn but succeed)
2. Verify atomic updates:
   - Check TODO.md and state.json stay synchronized
   - Verify rollback works on failure
   - Verify git commit created with correct message
3. Add inline documentation:
   - Add comments explaining delegation flow
   - Add examples in error messages
   - Document expected inputs and outputs
4. Update related documentation:
   - Add task-reviser to subagent list
   - Document integration with /revise command (for task 301)

**Acceptance Criteria**:
- [ ] All test cases pass
- [ ] Atomic updates verified
- [ ] Rollback verified on failure
- [ ] Documentation complete
- [ ] Ready for integration with /revise command

**Estimated Effort**: 0.25 hours

---

## Testing and Validation

### Unit Testing

Not applicable - subagents are tested manually through command invocation.

### Integration Testing

1. **Test Case 1: Valid Task Revision**
   - Setup: Create task with no plan
   - Action: Invoke task-reviser with task number
   - Expected: User prompted, TODO.md and state.json updated, git commit created

2. **Test Case 2: Task Not Found**
   - Setup: Use non-existent task number
   - Action: Invoke task-reviser
   - Expected: Error returned, no changes made

3. **Test Case 3: Task Has Plan**
   - Setup: Create task with plan
   - Action: Invoke task-reviser
   - Expected: Error returned, user directed to use /revise for plan revision

4. **Test Case 4: User Cancellation**
   - Setup: Create task with no plan
   - Action: Invoke task-reviser, cancel at confirmation
   - Expected: No changes made, early return

5. **Test Case 5: Invalid Input**
   - Setup: Create task with no plan
   - Action: Invoke task-reviser, provide invalid priority
   - Expected: Validation error, user prompted to retry

6. **Test Case 6: status-sync-manager Failure**
   - Setup: Simulate status-sync-manager failure
   - Action: Invoke task-reviser
   - Expected: Error returned, rollback triggered, no changes made

### Manual Verification

- Verify TODO.md and state.json stay synchronized
- Verify git commit message follows format
- Verify rollback works on failure
- Verify user prompts are clear and helpful

---

## Artifacts and Outputs

### Primary Artifacts

1. **task-reviser.md**
   - Location: `.opencode/agent/subagents/task-reviser.md`
   - Type: Subagent specification
   - Purpose: Define task-reviser subagent behavior

### Secondary Artifacts

None - task-reviser updates existing files (TODO.md, state.json) via delegation.

### Outputs

- Updated TODO.md with revised task metadata
- Updated state.json with revised task metadata
- Git commit with message: "task {number}: revised task metadata"

---

## Rollback/Contingency

### Rollback Plan

If task-reviser fails after status-sync-manager invocation:
1. status-sync-manager automatically rolls back changes (two-phase commit)
2. TODO.md and state.json restored to previous state
3. No git commit created
4. Error returned to user with recovery steps

### Manual Recovery

If rollback fails:
1. Check `specs/TODO.md` for task entry
2. Check `specs/state.json` for task metadata
3. Manually restore from git history: `git checkout HEAD~1 -- specs/TODO.md specs/state.json`
4. Retry task revision

### Contingency Plan

If task-reviser is blocked:
1. Manually edit TODO.md and state.json
2. Create git commit manually
3. File bug report for task-reviser
4. Use /meta to regenerate state.json if corrupted

---

## Success Metrics

### Functional Metrics

- [ ] task-reviser.md created with all required sections
- [ ] All 7 phases completed successfully
- [ ] All acceptance criteria met
- [ ] All test cases pass

### Quality Metrics

- [ ] Follows subagent template structure
- [ ] Delegates to status-sync-manager (no direct file writes)
- [ ] Returns standardized format per subagent-return-format.md
- [ ] Error handling covers all failure modes
- [ ] User prompts are clear and helpful

### Integration Metrics

- [ ] Ready for integration with /revise command (task 301)
- [ ] Compatible with status-sync-manager API
- [ ] Compatible with git-workflow-manager API
- [ ] No breaking changes to existing subagents

---

## Dependencies

### Internal Dependencies

- **status-sync-manager**: Required for atomic TODO.md and state.json updates
- **git-workflow-manager**: Required for git commit creation
- **state.json**: Required for task metadata extraction

### External Dependencies

None

### Blocking Issues

None - all dependencies are already implemented and stable.

---

## Notes

### Research Integration

No research artifacts available for this task. Implementation follows established patterns from:
- task-creator.md (user prompts, validation)
- planner.md (delegation to status-sync-manager and git-workflow-manager)
- status-sync-manager.md (atomic update patterns)

### Design Decisions

1. **Delegate to status-sync-manager**: Ensures atomic updates and rollback capability
2. **Prompt user for all changes upfront**: Avoids partial updates if user cancels
3. **Validate plan doesn't exist**: Prevents confusion between task revision and plan revision
4. **Non-critical git failure**: Git commit failure doesn't fail the command (updates still succeed)

### Future Enhancements

- Support bulk task updates (multiple tasks at once)
- Support interactive mode (no task number, prompt for task selection)
- Support task field templates (common revision patterns)
- Support revision history tracking (audit log)

---

**Plan Status**: [NOT STARTED]  
**Last Updated**: 2026-01-05  
**Next Review**: After Phase 1 completion
