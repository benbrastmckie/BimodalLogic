# Implementation Plan: Refactor /todo Command and Create todo-manager Subagent

- **Task**: 337 - Refactor /todo command and create todo-manager subagent to follow modern standards
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: 
  - Current implementation: .opencode/command/todo.md (372 lines with embedded workflow)
  - Reference implementations: /research, /implement commands
  - Standards: command-template.md, subagent-template.md, workflow_execution pattern
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/command/todo.md (refactored, <300 lines)
  - .opencode/agent/subagents/todo-manager.md (new subagent with 8-stage workflow)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/workflows/command-workflow.md
  - .opencode/context/core/workflows/agent-workflow.md
  - .opencode/context/core/formats/subagent-return.md
- **Type**: general
- **Lean Intent**: false

## Overview

Refactor the /todo command to follow modern .opencode standards by extracting its embedded 372-line workflow into a new todo-manager subagent. The current implementation violates the <300 line command file standard and does all work directly in the command file instead of delegating to a subagent. This refactoring will achieve clean separation of concerns (command parses/validates/delegates, subagent executes), minimize complexity, maintain the excellent atomic update and rollback logic, and ensure robust functionality with comprehensive validation.

## Goals & Non-Goals

**Goals**:
- Simplify command file to <300 lines with 4-stage pattern (ParseAndValidate, Delegate, ValidateReturn, RelayResult)
- Create new todo-manager subagent with 8-stage workflow_execution pattern
- Extract all workflow logic from command to subagent
- Maintain atomic updates across 4 entities (TODO.md, state.json, archive/state.json, project directories)
- Preserve two-phase commit with rollback on failure
- Maintain user confirmation for bulk operations (>5 tasks)
- Preserve self-healing for missing archive infrastructure
- Add preflight/postflight pattern for git commits
- Optimize context loading to Level 1 (10KB budget)

**Non-Goals**:
- Changing TODO.md or state.json schemas
- Modifying cleanup script logic (.opencode/scripts/todo_cleanup.py)
- Adding new archival features (scope: refactoring only)
- Changing task numbering preservation logic

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Breaking atomic updates | Carefully migrate two-phase commit logic to subagent, comprehensive testing |
| Loss of rollback capability | Preserve all rollback logic in subagent Stage 6, test failure scenarios |
| Git commit failures | Add preflight/postflight pattern with proper error handling |
| Context bloat in subagent | Use Level 1 context loading (10KB), lazy load only required context files |
| Validation gaps | Add comprehensive validation in both command (Stage 3) and subagent (Stage 4) |

## Implementation Phases

### Phase 1: Create todo-manager Subagent [NOT STARTED]
- **Goal:** Create new subagent with 8-stage workflow_execution pattern
- **Tasks:**
  - [ ] Create .opencode/agent/subagents/todo-manager.md
  - [ ] Add frontmatter:
    - name: "todo-manager"
    - version: "1.0.0"
    - description: "TODO.md maintenance agent for archiving completed/abandoned tasks"
    - mode: subagent
    - agent_type: maintenance
    - temperature: 0.2
    - max_tokens: 2000
    - timeout: 300
    - tools: read, write, bash
    - permissions: allow read/write to .opencode/specs/*, deny rm/sudo
    - context_loading: strategy=lazy, Level 1 (10KB)
    - delegation: max_depth=2, can_delegate_to=["git-workflow-manager"]
  - [ ] Implement Stage 1 (ValidateInputs):
    - Validate TODO.md exists and is readable
    - Validate state.json exists and is valid JSON
    - Validate archive/state.json exists (or can be created)
    - Validate session_id provided
    - Validate delegation_depth <= 2
    - If validation fails: Return error status
  - [ ] Implement Stage 2 (LoadContext):
    - Load required context files (Level 1, 10KB budget):
      * core/orchestration/state-management.md
      * core/standards/git-safety.md
    - Load TODO.md content
    - Load state.json content
    - Load archive/state.json content (or create from template)
    - Verify context loaded successfully
  - [ ] Implement Stage 3 (IdentifyTasksToArchive):
    - Query state.json for completed tasks (fast, ~5ms):
      * completed_tasks=$(jq -r '.active_projects[] | select(.status == "completed") | .project_number' state.json)
    - Query state.json for abandoned tasks (fast, ~5ms):
      * abandoned_tasks=$(jq -r '.active_projects[] | select(.status == "abandoned") | .project_number' state.json)
    - Get metadata for archival (fast, ~5ms):
      * archival_data=$(jq -r '.active_projects[] | select(.status == "completed" or .status == "abandoned") | {project_number, project_name, status, completed, abandoned, abandonment_reason}' state.json)
    - Count total tasks to archive
    - Prepare archival list with metadata
    - If count == 0: Return early with status "completed", message "No tasks to archive"
    - If count > 5: Request user confirmation (return status "awaiting_confirmation" with task list)
  - [ ] Implement Stage 4 (ValidateOutputs):
    - Validate archival list is non-empty (unless count == 0)
    - Validate all task numbers are valid integers
    - Validate metadata is complete for each task
    - If validation fails: Log errors and return error status
  - [ ] Implement Stage 5 (CreateArtifacts):
    - NO artifacts created (archival only)
    - Skip this stage
  - [ ] Implement Stage 6 (ExecuteArchival):
    - Check git status:
      * If merge in progress: Return error "Merge in progress. Resolve merge before running /todo"
      * If detached HEAD: Return error "Detached HEAD detected. Checkout branch before running /todo"
    - Auto-commit uncommitted changes (if any):
      * Stage all changes: git add .
      * Create commit: "Auto-commit before archiving {N} completed/abandoned tasks"
      * If commit fails: Return error "Failed to auto-commit changes"
    - Create pre-cleanup snapshot commit:
      * Stage TODO.md, state.json, archive/state.json
      * Create commit: "todo: snapshot before archiving {N} tasks (task 337)"
      * If commit fails: Return error "Failed to create pre-cleanup snapshot"
    - Execute cleanup script:
      * Prepare task list: "250,251,252,253,254"
      * Run: python3 .opencode/scripts/todo_cleanup.py --tasks "{task_list}"
      * Capture stdout, stderr, exit code
      * Timeout: 120 seconds
    - Check exit code:
      * 0: Success, proceed to Stage 7
      * 1-3: Validation/I/O/argument error, rollback and return error
    - On failure:
      * Rollback: git reset --hard HEAD~1
      * Verify rollback succeeded
      * Log error to errors.json
      * Return error with script output
  - [ ] Implement Stage 7 (CreateCommit):
    - Stage files:
      * git add .opencode/specs/TODO.md
      * git add .opencode/specs/state.json
      * git add .opencode/specs/archive/state.json
      * git add .opencode/specs/archive/ (pick up moved directories)
    - Verify staged changes: git status --short
    - Create commit:
      * Message: "todo: archive {N} completed/abandoned tasks (task 337)"
      * Examples: "todo: archive 2 completed tasks (task 337)"
    - If commit fails:
      * Log error to errors.json
      * Continue (commit failure non-critical, archival already complete)
      * Return success with warning about git failure
  - [ ] Implement Stage 8 (ReturnResults):
    - Format return per subagent-return-format.md
    - Include status: "completed"
    - Include summary: "Archived {N} tasks ({completed} completed, {abandoned} abandoned)"
    - Include artifacts: [] (empty, no files created)
    - Include metadata: session_id, duration, agent_type="todo-manager", delegation info
    - Include errors: [] (or error details if any)
    - Include next_steps: "Remaining active tasks: {count}"
    - Include archival_summary:
      * tasks_archived: {total_count}
      * completed_count: {completed_count}
      * abandoned_count: {abandoned_count}
      * directories_moved: [{number}_{slug}, ...]
      * tasks_without_directories: [{number}: {title}, ...]
      * remaining_active_tasks: {remaining_count}
  - [ ] Add comprehensive error handling:
    - No tasks to archive: Return early with message
    - File read failure: Return error with file path
    - File write failure: Rollback and return error
    - Directory move failure: Rollback and return error
    - User declined confirmation: Return status "cancelled"
    - Git commit failure: Log warning but continue
    - Rollback failure: Return critical error with recovery instructions
  - [ ] Add quality standards:
    - Numbering preservation: NEVER renumber tasks
    - Atomic updates: Two-phase commit for 4 entities
    - Artifact preservation: Move entire project directories
    - Self-healing: Auto-create archive/state.json if missing
    - User confirmation: Request if archiving >5 tasks
- **Timing:** 2-2.5 hours

### Phase 2: Refactor Command File (todo.md) [NOT STARTED]
- **Goal:** Simplify command to 4-stage pattern, <300 lines
- **Tasks:**
  - [ ] Read current todo.md implementation (372 lines)
  - [ ] Extract all workflow logic to be moved to subagent
  - [ ] Implement Stage 1 (ParseAndValidate):
    - Parse flags from $ARGUMENTS (currently no flags, but prepare for future)
    - Validate TODO.md exists and is readable
    - Validate state.json exists and is valid JSON
    - Quick check: Count tasks to archive from state.json
    - If zero tasks: Return early with message "No tasks to archive"
  - [ ] Implement Stage 2 (Delegate):
    - Generate session_id for tracking
    - Prepare delegation context (session_id, delegation_depth=1, delegation_path)
    - Invoke todo-manager subagent via task tool
    - Wait for return (timeout: 300s)
  - [ ] Implement Stage 3 (ValidateReturn):
    - Parse return as JSON
    - Validate required fields: status, summary, metadata, archival_summary
    - Validate status is "completed", "cancelled", or "awaiting_confirmation"
    - If status == "awaiting_confirmation":
      * Display task list to user
      * Request confirmation (yes/no)
      * If user declines: Return message "Archival aborted by user"
      * If user confirms: Re-invoke subagent with confirmation flag
    - Validate session_id matches expected
    - Validate archival_summary object has required fields
    - If validation fails: Return error with details
  - [ ] Implement Stage 4 (RelayResult):
    - Extract key information from archival_summary
    - Format user-friendly summary
    - Display tasks archived (count, completed, abandoned)
    - Display directories moved (if any)
    - Display tasks without directories (if any)
    - Display remaining active tasks
    - Display archive location
    - Return to user
  - [ ] Update frontmatter:
    - context_level: 1 (keep current)
    - routing.target_agent: todo-manager
    - context_loading.required: state-management.md, git-safety.md
    - context_loading.max_context_size: 10000 (Level 1)
    - Remove unnecessary context files
  - [ ] Remove all embedded workflow logic (moved to subagent)
  - [ ] Verify file is <300 lines (should be ~150 lines after refactoring)
- **Timing:** 1-1.5 hours

### Phase 3: Testing & Validation [NOT STARTED]
- **Goal:** Verify refactored implementation works correctly
- **Tasks:**
  - [ ] Test command with no tasks to archive:
    - Expected: "No tasks to archive"
  - [ ] Test command with 1-5 tasks to archive:
    - Expected: Tasks archived without confirmation
  - [ ] Test command with >5 tasks to archive:
    - Expected: Confirmation requested, tasks archived after confirmation
  - [ ] Test user declining confirmation:
    - Expected: "Archival aborted by user"
  - [ ] Test atomic updates:
    - Verify TODO.md updated (tasks removed)
    - Verify state.json updated (tasks moved to completed_projects)
    - Verify archive/state.json updated (new archive entries)
    - Verify project directories moved to archive
  - [ ] Test rollback on failure:
    - Simulate cleanup script failure
    - Expected: git reset --hard HEAD~1, system rolled back
  - [ ] Test self-healing:
    - Delete archive/state.json
    - Run /todo
    - Expected: archive/state.json auto-created from template
  - [ ] Test git commit handling:
    - Verify pre-cleanup snapshot created
    - Verify post-archival commit created
    - Test commit failure: Expected warning but continue
  - [ ] Test error handling:
    - Merge in progress: Expected error message
    - Detached HEAD: Expected error message
    - File read failure: Expected error message
    - File write failure: Expected rollback and error
  - [ ] Verify context loading efficiency:
    - Check context size <10KB (Level 1)
    - Verify only required context loaded
  - [ ] Verify file sizes:
    - todo.md <300 lines (should be ~150 lines)
    - todo-manager.md follows 8-stage pattern
  - [ ] Compare output with original implementation:
    - Same archival logic
    - Same atomic updates
    - Same rollback behavior
    - Same user confirmation
- **Timing:** 1-1.5 hours

### Phase 4: Documentation & Cleanup [NOT STARTED]
- **Goal:** Update documentation and commit changes
- **Tasks:**
  - [ ] Update todo.md documentation section:
    - Document 4-stage workflow
    - Update delegation section
    - Update error handling section
  - [ ] Create todo-manager.md documentation:
    - Document 8-stage workflow
    - Document atomic update logic
    - Document rollback behavior
    - Document user confirmation logic
    - Update input/output specifications
    - Update examples
  - [ ] Verify standards compliance:
    - Command follows command-template.md
    - Subagent follows subagent-template.md
    - Return format matches subagent-return-format.md
  - [ ] Create git commit:
    - Message: "refactor: modernize /todo command and create todo-manager subagent (task 337)"
    - Include: todo.md, todo-manager.md
  - [ ] Update this plan status to [COMPLETED]
- **Timing:** 30 minutes

## Testing & Validation

**Command File Validation**:
- [ ] File size <300 lines (should be ~150 lines)
- [ ] 4-stage workflow implemented (ParseAndValidate, Delegate, ValidateReturn, RelayResult)
- [ ] No embedded workflow logic (all in subagent)
- [ ] Context loading optimized (Level 1, <10KB)
- [ ] Comprehensive validation in Stage 3
- [ ] User confirmation handling in Stage 3

**Subagent Validation**:
- [ ] 8-stage workflow_execution implemented
- [ ] All stages have action, process, validation, checkpoint
- [ ] Return format matches subagent-return-format.md
- [ ] Context loading strategy: lazy, Level 1
- [ ] Atomic updates preserved (two-phase commit)
- [ ] Rollback logic preserved
- [ ] Git commits in Stage 6 (preflight) and Stage 7 (postflight)

**Functional Validation**:
- [ ] Archival logic preserved
- [ ] Atomic updates work correctly
- [ ] Rollback works on failure
- [ ] User confirmation works (>5 tasks)
- [ ] Self-healing works (missing archive/state.json)
- [ ] Task numbering preserved
- [ ] Project directories moved correctly

**Standards Compliance**:
- [ ] Follows command-template.md
- [ ] Follows subagent-template.md
- [ ] Follows workflow_execution pattern
- [ ] Follows subagent-return-format.md

## Artifacts & Outputs

**Modified Files**:
- .opencode/command/todo.md (refactored, <300 lines)

**Created Files**:
- .opencode/agent/subagents/todo-manager.md (new subagent, 8-stage workflow)

**State Updates**:
- TODO.md: Archived tasks removed
- state.json: Archived tasks moved to completed_projects
- archive/state.json: New archive entries added
- Project directories: Moved to archive/

## Rollback/Contingency

If refactoring breaks functionality:
1. Revert git commit: `git revert HEAD`
2. Restore original todo.md from git history
3. Delete todo-manager.md
4. Review test failures and fix issues
5. Re-test before re-deploying

If validation fails:
1. Review validation errors in detail
2. Fix specific validation issues
3. Re-run tests
4. Update plan with lessons learned

If atomic updates fail:
1. System automatically rolls back via git reset
2. Verify rollback succeeded
3. Check errors.json for failure details
4. Fix root cause before retrying

## Success Criteria

- [ ] todo.md <300 lines with 4-stage pattern
- [ ] todo-manager.md created with 8-stage workflow_execution
- [ ] All workflow logic in subagent (not command)
- [ ] Context loading optimized (Level 1, <10KB)
- [ ] Atomic updates preserved (two-phase commit)
- [ ] Rollback logic preserved
- [ ] User confirmation preserved (>5 tasks)
- [ ] Self-healing preserved
- [ ] Return format standardized per subagent-return-format.md
- [ ] All existing functionality preserved
- [ ] Comprehensive validation at command and subagent levels
- [ ] All tests pass
- [ ] Standards compliance verified
- [ ] Git commit created

## Notes

- **Atomic Updates**: Two-phase commit across 4 entities (TODO.md, state.json, archive/state.json, project directories)
- **Rollback**: Automatic rollback via git reset --hard HEAD~1 on any failure
- **User Confirmation**: Requested if archiving >5 tasks (threshold configurable)
- **Self-Healing**: Auto-creates archive/state.json from template if missing
- **Context Efficiency**: Level 1 loading (10KB budget) sufficient for maintenance task
- **Separation of Concerns**: Command parses/validates/delegates, subagent executes archival
- **Standards Alignment**: Follows same pattern as /research and /implement commands
- **Git Commits**: Preflight snapshot (Stage 6) and postflight commit (Stage 7)
