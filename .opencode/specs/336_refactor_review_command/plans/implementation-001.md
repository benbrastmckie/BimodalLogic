# Implementation Plan: Refactor /review Command and reviewer Subagent

- **Task**: 336 - Refactor /review command and reviewer subagent to follow modern standards
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**: 
  - Current implementations: .opencode/command/review.md (176 lines), .opencode/agent/subagents/reviewer.md (545 lines)
  - Reference implementations: /research, /implement commands
  - Standards: command-template.md, subagent-template.md, workflow_execution pattern
- **Artifacts**: 
  - plans/implementation-001.md (this file)
  - .opencode/command/review.md (refactored, <300 lines)
  - .opencode/agent/subagents/reviewer.md (refactored with 8-stage workflow)
- **Standards**:
  - .opencode/context/core/formats/plan-format.md
  - .opencode/context/core/workflows/command-workflow.md
  - .opencode/context/core/workflows/agent-workflow.md
  - .opencode/context/core/formats/subagent-return.md
- **Type**: general
- **Lean Intent**: false

## Overview

Refactor the /review command and reviewer subagent to follow modern .opencode standards established by /research and /implement. The current implementation has workflow logic embedded in the command file, uses the older process_flow pattern in the subagent, and loads context at Level 3 (eager, 100KB) which is too heavy. This refactoring will achieve clean separation of concerns (command parses/validates/delegates, subagent executes), minimize complexity, optimize context loading to Level 2, and ensure robust functionality with comprehensive validation.

## Goals & Non-Goals

**Goals**:
- Simplify command file to <300 lines with 4-stage pattern (ParseAndValidate, Delegate, ValidateReturn, RelayResult)
- Refactor reviewer subagent to use 8-stage workflow_execution pattern
- Move all workflow logic from command to subagent
- Reduce context loading from Level 3 (100KB) to Level 2 (50KB)
- Ensure subagent returns standardized format per subagent-return-format.md
- Maintain all existing functionality (registry updates, task creation, review summaries)
- Move task creation logic from subagent to command (proper separation)
- No preflight/postflight needed (review command is read-only analysis with post-processing)

**Non-Goals**:
- Changing registry file formats or locations
- Adding new review capabilities (scope: refactoring only)
- Modifying registry update logic (preserve existing behavior)
- Changing review summary format

## Risks & Mitigations

| Risk | Mitigation |
|------|-----------|
| Breaking existing review workflow | Maintain exact same inputs/outputs, comprehensive testing before deployment |
| Context bloat in subagent | Reduce from Level 3 to Level 2 (50KB), lazy load only required context files |
| Loss of registry update logic | Carefully migrate all update logic from command to subagent Stage 3 |
| Task creation in wrong place | Move task creation from subagent to command (Stage 4.5) |
| Validation gaps | Add comprehensive validation in both command (Stage 3) and subagent (Stage 4) |

## Implementation Phases

### Phase 1: Refactor Command File (review.md) [NOT STARTED]
- **Goal:** Simplify command to 4-stage pattern with task creation, <300 lines
- **Tasks:**
  - [ ] Read current review.md implementation (176 lines)
  - [ ] Extract workflow logic to be moved to subagent
  - [ ] Implement Stage 1 (ParseAndValidate):
    - Parse scope from $ARGUMENTS: lean, docs, all (default: all)
    - Validate scope is valid enum
    - Load current registries:
      * Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
      * Documentation/ProjectInfo/SORRY_REGISTRY.md
      * Documentation/ProjectInfo/TACTIC_REGISTRY.md
      * Documentation/ProjectInfo/FEATURE_REGISTRY.md
    - Read next_project_number from state.json
    - Generate project_path: .opencode/specs/{next_project_number}_codebase_review
    - If zero registries loaded: Return error "Registry files not found"
  - [ ] Implement Stage 2 (Delegate):
    - Generate session_id for tracking
    - Prepare delegation context (review_scope, project_path, current_registries, session_id, delegation_depth=1, delegation_path)
    - Invoke reviewer subagent via task tool
    - Pass scope and registry data
    - Wait for return (timeout: 3600s)
  - [ ] Implement Stage 3 (ValidateReturn):
    - Parse return as JSON
    - Validate required fields: status, summary, artifacts, metadata, identified_tasks, metrics
    - Validate status is "completed" or "partial"
    - Validate session_id matches expected
    - Validate artifacts array includes review summary and registry updates
    - Validate metrics object has required fields (sorry_count, axiom_count, build_errors)
    - Validate identified_tasks array is present (may be empty)
    - If validation fails: Return error with details
  - [ ] Implement Stage 3.5 (CreateTasks):
    - Extract identified_tasks from subagent return
    - For each task in identified_tasks:
      * Create task entry in TODO.md via status-sync-manager
      * Set status: [NOT STARTED]
      * Set priority from task.priority
      * Set language from task.language
      * Set effort from task.estimated_hours
      * Link to review summary artifact
    - Update state.json with new task entries
    - Increment next_project_number for each task
    - If task creation fails: Log warning but continue (non-critical)
  - [ ] Implement Stage 4 (RelayResult):
    - Extract key information from return
    - Format user-friendly summary
    - Display registry updates performed
    - Display key findings (sorry count, build errors, etc.)
    - Display tasks created (with task numbers)
    - Display next steps
    - Return to user
  - [ ] Update frontmatter:
    - context_level: 2 (reduce from 3)
    - routing.target_agent: reviewer
    - context_loading.required: delegation.md, state-management.md, subagent-return.md
    - context_loading.max_context_size: 50000 (reduce from 100000)
    - Remove unnecessary context files
  - [ ] Remove embedded workflow logic (moved to subagent)
  - [ ] Verify file is <300 lines
- **Timing:** 1.5-2 hours

### Phase 2: Refactor Subagent (reviewer.md) [NOT STARTED]
- **Goal:** Convert to 8-stage workflow_execution pattern, reduce context to Level 2
- **Tasks:**
  - [ ] Read current reviewer.md (545 lines)
  - [ ] Replace process_flow with workflow_execution
  - [ ] Implement Stage 1 (ValidateInputs):
    - Validate review_scope is valid enum (full|lean|docs)
    - Validate project_path is non-empty string
    - Validate current_registries object is present
    - Validate session_id provided
    - Validate delegation_depth <= 3
    - Validate delegation_path is array
    - If validation fails: Return error status
  - [ ] Implement Stage 2 (LoadContext):
    - Load required context files (Level 2, 50KB budget):
      * core/orchestration/delegation.md
      * core/orchestration/state-management.md
      * core/formats/subagent-return.md
      * core/formats/summary-format.md
    - Load current registry files (already passed in current_registries)
    - Verify context loaded successfully
  - [ ] Implement Stage 3 (AnalyzeCodebase):
    - Determine analysis scope based on review_scope:
      * full: Analyze entire codebase (Lean + docs + tests)
      * lean: Focus on Lean code only
      * docs: Focus on documentation only
    - Scan all relevant files in scope
    - Collect metrics:
      * Count sorry statements (Lean files)
      * Count axiom placeholders (Lean files)
      * Count build errors (if any)
      * Identify undocumented tactics (Lean files)
      * Identify missing features (compare with FEATURE_REGISTRY.md)
      * Identify implementation gaps (compare with IMPLEMENTATION_STATUS.md)
    - Categorize findings by severity (high/medium/low priority)
    - Note file locations for each finding
    - Update registries:
      * IMPLEMENTATION_STATUS.md: Update module completion percentages
      * SORRY_REGISTRY.md: Add new sorry statements, remove proven ones
      * TACTIC_REGISTRY.md: Add newly documented tactics, flag undocumented
      * FEATURE_REGISTRY.md: Add newly implemented features, flag missing
    - Identify maintenance tasks:
      * Create task descriptions for each finding
      * Assign priorities based on severity
      * Set language field based on task type
      * Estimate effort for each task
  - [ ] Implement Stage 4 (ValidateOutputs):
    - Validate all registries updated successfully
    - Validate metrics collected (sorry_count, axiom_count, build_errors)
    - Validate identified_tasks list is valid
    - Validate each task has required fields (description, priority, language, estimated_hours)
    - If validation fails: Log errors and return partial status
  - [ ] Implement Stage 5 (CreateArtifacts):
    - Create summaries subdirectory in project_path (lazy creation)
    - Write summaries/review-summary.md following summary.md standard:
      * Metadata: Status [COMPLETED], timestamps, priority, dependencies
      * Overview: 2-3 sentences on review scope and context
      * What Changed: Bullet list of registry updates performed
      * Key Findings: Bullet list of critical findings (sorry count, build errors, etc.)
      * Impacts: Bullet list of implications for codebase health
      * Follow-ups: Bullet list of identified tasks with placeholder numbers (TBD-1, TBD-2, etc.)
      * References: Paths to updated registries
    - Keep summary concise (3-5 sentences in Overview, <100 tokens total overview)
    - Use bullet lists for clarity
    - Use placeholder task numbers (TBD-1, TBD-2, etc.) in Follow-ups section
    - Validate summary file written successfully
  - [ ] Implement Stage 6 (UpdateState):
    - NO state updates in subagent (command handles task creation)
    - Skip this stage
  - [ ] Implement Stage 7 (CreateCommit):
    - Delegate to git-workflow-manager to commit registry updates and review summary
    - Scope files: all 4 registries + review summary artifact
    - Message: "review: update registries and create review summary (task 336)"
    - If commit fails: Log warning but continue (non-critical)
  - [ ] Implement Stage 8 (ReturnResults):
    - Format return per subagent-return-format.md
    - Include status: "completed"
    - Include summary: Brief findings (<100 tokens)
    - Include artifacts: Array with review summary and registry paths
    - Include metadata: session_id, duration, agent_type="reviewer", delegation info
    - Include errors: [] (or error details if any)
    - Include next_steps: "Review findings and address high-priority tasks"
    - Include identified_tasks: Array of tasks for command to create
    - Include metrics: sorry_count, axiom_count, build_errors, etc.
  - [ ] Update frontmatter:
    - context_loading.strategy: lazy
    - context_loading.required: delegation.md, state-management.md, subagent-return.md, summary-format.md
    - context_loading.max_context_size: 50000 (reduce from 100000)
    - delegation.can_delegate_to: ["git-workflow-manager"]
  - [ ] Remove old process_flow sections
  - [ ] Verify workflow_execution follows 8-stage pattern
- **Timing:** 2-2.5 hours

### Phase 3: Testing & Validation [NOT STARTED]
- **Goal:** Verify refactored implementation works correctly
- **Tasks:**
  - [ ] Test command with scope=all:
    - Expected: Full codebase review, all registries updated
  - [ ] Test command with scope=lean:
    - Expected: Only Lean code reviewed, relevant registries updated
  - [ ] Test command with scope=docs:
    - Expected: Only documentation reviewed, relevant registries updated
  - [ ] Test command with invalid scope:
    - Expected: Error message with valid scopes
  - [ ] Test subagent return validation:
    - Verify status field validated
    - Verify session_id validated
    - Verify artifacts array validated
    - Verify metrics object validated
    - Verify identified_tasks array validated
  - [ ] Test task creation:
    - Verify tasks created in TODO.md
    - Verify tasks added to state.json
    - Verify task numbers sequential
    - Verify task priorities correct
  - [ ] Test error handling:
    - Missing registries: Expected error message
    - Subagent timeout: Expected timeout handling
    - Validation failure: Expected error details
    - Task creation failure: Expected warning but continue
  - [ ] Verify context loading efficiency:
    - Check context size <50KB (Level 2)
    - Verify only required context loaded
  - [ ] Verify file sizes:
    - review.md <300 lines
    - reviewer.md follows 8-stage pattern
  - [ ] Compare output with original implementation:
    - Same registry updates
    - Same metrics collected
    - Same task creation logic
- **Timing:** 1-1.5 hours

### Phase 4: Documentation & Cleanup [NOT STARTED]
- **Goal:** Update documentation and commit changes
- **Tasks:**
  - [ ] Update review.md documentation section:
    - Document 4-stage workflow with task creation
    - Update delegation section
    - Update error handling section
  - [ ] Update reviewer.md documentation:
    - Document 8-stage workflow
    - Update input/output specifications
    - Update examples
    - Note that task creation moved to command
  - [ ] Verify standards compliance:
    - Command follows command-template.md
    - Subagent follows subagent-template.md
    - Return format matches subagent-return-format.md
  - [ ] Create git commit:
    - Message: "refactor: modernize /review command and reviewer subagent (task 336)"
    - Include: review.md, reviewer.md
  - [ ] Update this plan status to [COMPLETED]
- **Timing:** 30 minutes

## Testing & Validation

**Command File Validation**:
- [ ] File size <300 lines
- [ ] 4-stage workflow implemented (ParseAndValidate, Delegate, ValidateReturn, RelayResult)
- [ ] Task creation in Stage 3.5 (after validation, before relay)
- [ ] No embedded workflow logic (all in subagent)
- [ ] Context loading optimized (Level 2, <50KB)
- [ ] Comprehensive validation in Stage 3

**Subagent Validation**:
- [ ] 8-stage workflow_execution implemented
- [ ] All stages have action, process, validation, checkpoint
- [ ] Return format matches subagent-return-format.md
- [ ] Context loading strategy: lazy, Level 2 (reduced from Level 3)
- [ ] Task creation removed from subagent (moved to command)
- [ ] Git commit in Stage 7 for registry updates

**Functional Validation**:
- [ ] Registry update logic preserved
- [ ] Metrics collection works correctly
- [ ] Task identification works correctly
- [ ] All scopes work (full, lean, docs)
- [ ] Error handling comprehensive

**Standards Compliance**:
- [ ] Follows command-template.md
- [ ] Follows subagent-template.md
- [ ] Follows workflow_execution pattern
- [ ] Follows subagent-return-format.md

## Artifacts & Outputs

**Modified Files**:
- .opencode/command/review.md (refactored, <300 lines)
- .opencode/agent/subagents/reviewer.md (refactored, 8-stage workflow)

**Created Files**:
- .opencode/specs/{next_project_number}_codebase_review/summaries/review-summary.md (by subagent)
- Updated registry files (by subagent)

**State Updates**:
- TODO.md: New task entries created by command
- state.json: New task entries added by command

## Rollback/Contingency

If refactoring breaks functionality:
1. Revert git commit: `git revert HEAD`
2. Restore original implementations from git history
3. Review test failures and fix issues
4. Re-test before re-deploying

If validation fails:
1. Review validation errors in detail
2. Fix specific validation issues
3. Re-run tests
4. Update plan with lessons learned

## Success Criteria

- [ ] review.md <300 lines with 4-stage pattern
- [ ] reviewer.md uses 8-stage workflow_execution
- [ ] All workflow logic in subagent (not command)
- [ ] Context loading reduced from Level 3 to Level 2 (<50KB)
- [ ] Task creation moved from subagent to command
- [ ] Return format standardized per subagent-return-format.md
- [ ] All existing functionality preserved
- [ ] Comprehensive validation at command and subagent levels
- [ ] All tests pass
- [ ] Standards compliance verified
- [ ] Git commit created

## Notes

- **Task Creation Location**: Moved from subagent to command (Stage 3.5) for proper separation of concerns
- **Context Reduction**: Level 3 (100KB) → Level 2 (50KB) for better performance
- **Git Commit**: Subagent commits registry updates and review summary (Stage 7)
- **Separation of Concerns**: Command parses/validates/delegates/creates tasks, subagent executes analysis
- **Standards Alignment**: Follows same pattern as /research and /implement commands
