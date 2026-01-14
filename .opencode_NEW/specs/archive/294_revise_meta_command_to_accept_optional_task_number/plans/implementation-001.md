# Implementation Plan: Revise /meta Command to Accept Optional Task Number

## Metadata

- **Task**: 294 - Revise /meta command to accept optional task number
- **Status**: [NOT STARTED]
- **Estimated Effort**: 10 hours
- **Priority**: Medium
- **Language**: markdown
- **Type**: feature
- **Created**: 2026-01-04
- **Plan Version**: 001
- **Research Integrated**: Yes
- **Research Artifacts**:
  - `.opencode/specs/294_revise_meta_command_to_accept_optional_task_number/reports/research-001.md`

---

## Overview

### Problem Statement

The /meta command currently supports two modes: Prompt Mode (with arguments) and Interactive Mode (no arguments). Users need a third mode to run /meta on existing tasks (Task Mode) to generate meta-specific implementation plans, similar to how /research, /implement, and /plan commands work.

### Scope

This implementation will:
- Add Stage 1 (ParseAndValidate) to /meta command for task number detection
- Implement three-mode detection: Task Mode (integer first token) → Prompt Mode (non-integer arguments) → Interactive Mode (no arguments)
- Extract task metadata from state.json when task number provided
- Adapt meta agent workflow to skip interview stages when task context is provided
- Maintain full backward compatibility with existing /meta usage patterns
- Update documentation and examples

### Constraints

- Must maintain backward compatibility with existing Prompt Mode and Interactive Mode
- Must follow established pattern from /research, /implement, and /plan commands
- Must use state.json as authoritative source for task metadata
- Must validate task exists before treating integer as task number
- Must provide graceful fallback to Prompt Mode if task not found

### Definition of Done

- [ ] /meta 294 works (Task Mode)
- [ ] /meta "prompt text" works (Prompt Mode)
- [ ] /meta works (Interactive Mode)
- [ ] All three modes properly validated and tested
- [ ] Documentation updated with examples
- [ ] Backward compatibility verified
- [ ] Git commit created with all changes

---

## Goals and Non-Goals

### Goals

1. **Add Task Mode Support**: Enable /meta to accept task number as first argument
2. **Maintain Backward Compatibility**: Ensure existing Prompt Mode and Interactive Mode continue to work
3. **Follow Established Patterns**: Implement consistent with /research, /implement, and /plan commands
4. **Efficient Metadata Extraction**: Use state.json for 8x faster metadata extraction
5. **Clear Documentation**: Update command documentation with usage examples for all three modes

### Non-Goals

1. **Change Existing Workflow**: Not modifying the core 8-stage interview workflow for Prompt/Interactive modes
2. **Create New Command**: Not creating a separate command like /meta-plan
3. **Modify state.json Structure**: Not changing the task metadata structure
4. **Add Complex Validation**: Not adding extensive task type validation beyond basic checks

---

## Risks and Mitigations

### Risk 1: Breaking Backward Compatibility

**Likelihood**: Low  
**Impact**: Medium

**Description**: Users who currently use `/meta 294` expecting it to be treated as a domain prompt will experience breaking changes.

**Mitigation**:
- Implement fallback to Prompt Mode if task number not found in state.json
- Log warning when falling back to Prompt Mode
- Document the change clearly in command documentation
- Test with existing usage patterns to verify no breaking changes

**Contingency**: If breaking changes detected, add flag to force Prompt Mode: `/meta --prompt 294`

### Risk 2: Confusion Between /meta and /plan

**Likelihood**: Medium  
**Impact**: Low

**Description**: Users might be confused about when to use /meta vs. /plan for planning tasks.

**Mitigation**:
- Add validation to check task type (warn if not "meta")
- Document clear guidelines on when to use each command
- Provide examples for both commands in documentation
- Add help text to command output

**Contingency**: Add cross-reference in documentation and suggestion in /meta output

### Risk 3: Stage Renumbering Complexity

**Likelihood**: Low  
**Impact**: Medium

**Description**: Renumbering stages from 0-8 to 0-9 might introduce errors or inconsistencies.

**Mitigation**:
- Use systematic approach for stage renumbering
- Update all stage references in documentation
- Test all stage transitions thoroughly
- Verify stage checkpoints work correctly

**Contingency**: If renumbering causes issues, use conditional Stage 1 without renumbering existing stages

---

## Implementation Phases

### Phase 1: Add Stage 1 (ParseAndValidate) to /meta Command [NOT STARTED]

**Duration**: 2 hours  
**Dependencies**: None

**Objectives**:
- Insert new Stage 1 (ParseAndValidate) before current Stage 1 (InitiateInterview)
- Implement three-mode detection logic
- Parse task number and validate if Task Mode
- Extract task metadata from state.json
- Determine which stages to execute based on mode

**Tasks**:
1. Add Stage 1 section to .opencode/command/meta.md
2. Implement mode detection logic:
   - Check if $ARGUMENTS is empty → Interactive Mode
   - Check if first token is integer and task exists → Task Mode
   - Otherwise → Prompt Mode
3. Add task number parsing and validation
4. Add state.json lookup and metadata extraction
5. Add fallback to Prompt Mode if task not found (with warning)
6. Add stage routing based on detected mode

**Acceptance Criteria**:
- [ ] Stage 1 section added to meta.md command file
- [ ] Three-mode detection logic implemented
- [ ] Task number parsing validates integer format
- [ ] state.json lookup works correctly
- [ ] Metadata extraction includes all required fields
- [ ] Fallback to Prompt Mode works with warning
- [ ] Stage routing directs to correct next stage

**Testing**:
- Test with valid task number: `/meta 294`
- Test with invalid task number: `/meta 999` (should fall back to Prompt Mode)
- Test with non-integer prompt: `/meta "create system"`
- Test with no arguments: `/meta`

---

### Phase 2: Renumber Existing Stages [NOT STARTED]

**Duration**: 1 hour  
**Dependencies**: Phase 1

**Objectives**:
- Renumber existing stages to accommodate new Stage 1
- Update all stage references in command file
- Ensure stage transitions work correctly

**Tasks**:
1. Renumber stages in .opencode/command/meta.md:
   - Current Stage 0 (DetectExistingProject) → Stage 0 (unchanged)
   - NEW Stage 1 (ParseAndValidate) → Stage 1
   - Current Stage 1 (InitiateInterview) → Stage 2
   - Current Stage 2 (GatherDomainInformation) → Stage 3
   - Current Stage 3 (IdentifyUseCases) → Stage 4
   - Current Stage 4 (AssessComplexity) → Stage 5
   - Current Stage 5 (IdentifyIntegrations) → Stage 6
   - Current Stage 6 (ReviewAndConfirm) → Stage 7
   - Current Stage 7 (CreateTasksWithArtifacts) → Stage 8
   - Current Stage 8 (DeliverTaskSummary) → Stage 9
2. Update all stage references in workflow description
3. Update stage transition logic
4. Verify stage checkpoints

**Acceptance Criteria**:
- [ ] All stages renumbered correctly
- [ ] Stage references updated throughout command file
- [ ] Stage transitions work correctly
- [ ] Stage checkpoints verified

**Testing**:
- Verify Interactive Mode executes all stages in correct order
- Verify Prompt Mode skips Stage 2 (formerly Stage 1)
- Verify stage numbers match in workflow description

---

### Phase 3: Make Stages Conditional Based on Mode [NOT STARTED]

**Duration**: 1.5 hours  
**Dependencies**: Phase 2

**Objectives**:
- Add mode checks to each stage
- Skip Stages 2-7 if mode="task"
- Skip Stage 2 if mode="prompt"
- Execute all stages if mode="interactive"

**Tasks**:
1. Add conditional logic to Stage 2 (InitiateInterview):
   - Skip if mode != "interactive"
2. Add conditional logic to Stages 3-7 (interview stages):
   - Skip if mode == "task"
   - Execute if mode == "prompt" or mode == "interactive"
3. Update stage descriptions to indicate conditional execution
4. Document mode-specific behavior in each stage

**Acceptance Criteria**:
- [ ] Stage 2 skipped in Prompt Mode and Task Mode
- [ ] Stages 3-7 skipped in Task Mode
- [ ] All stages execute in Interactive Mode
- [ ] Stage descriptions updated with conditional notes
- [ ] Mode-specific behavior documented

**Testing**:
- Test Task Mode: Verify Stages 2-7 skipped
- Test Prompt Mode: Verify Stage 2 skipped, Stages 3-7 executed
- Test Interactive Mode: Verify all stages executed

---

### Phase 4: Adapt Stage 8 (CreateTasksWithArtifacts) for Task Mode [NOT STARTED]

**Duration**: 2 hours  
**Dependencies**: Phase 3

**Objectives**:
- Add conditional logic for mode="task"
- Create plan artifact for single task (not multiple tasks)
- Use existing task directory
- Follow plan.md template standard
- Update task status to [PLANNED]

**Tasks**:
1. Add mode check at start of Stage 8
2. Implement Task Mode branch:
   - Use existing task directory: `.opencode/specs/{task_number}_{project_name}/`
   - Create plans/ subdirectory if not exists
   - Generate plan artifact: `plans/implementation-001.md`
   - Include metadata from task (number, description, priority, etc.)
   - Include sections: Overview, Goals, Phases, Testing, Artifacts
   - Write plan artifact to disk
   - Validate plan artifact exists and is non-empty
3. Keep existing logic for Prompt Mode and Interactive Mode
4. Document Task Mode behavior in stage description

**Acceptance Criteria**:
- [ ] Mode check implemented at start of Stage 8
- [ ] Task Mode creates plan artifact in existing task directory
- [ ] Plan artifact follows plan.md template standard
- [ ] Plan includes all required sections
- [ ] Plan artifact validated before proceeding
- [ ] Prompt/Interactive Mode logic unchanged
- [ ] Task Mode behavior documented

**Testing**:
- Test Task Mode: Verify plan artifact created in correct directory
- Test plan artifact content: Verify all sections present
- Test plan artifact validation: Verify non-empty check works
- Test Prompt/Interactive Mode: Verify multiple tasks created as before

---

### Phase 5: Adapt Stage 9 (DeliverTaskSummary) for Task Mode [NOT STARTED]

**Duration**: 1.5 hours  
**Dependencies**: Phase 4

**Objectives**:
- Add conditional logic for mode="task"
- Present plan artifact link
- Provide usage instructions for /implement
- Create git commit with plan artifact
- Return standardized format

**Tasks**:
1. Add mode check at start of Stage 9
2. Implement Task Mode branch:
   - Format plan presentation with task details
   - Include plan path and usage instructions
   - Delegate to git-workflow-manager for commit
   - Return standardized format with plan artifact
3. Keep existing logic for Prompt Mode and Interactive Mode
4. Document Task Mode behavior in stage description

**Acceptance Criteria**:
- [ ] Mode check implemented at start of Stage 9
- [ ] Task Mode presents plan artifact link
- [ ] Usage instructions provided for /implement command
- [ ] Git commit created with plan artifact
- [ ] Standardized return format includes plan metadata
- [ ] Prompt/Interactive Mode logic unchanged
- [ ] Task Mode behavior documented

**Testing**:
- Test Task Mode: Verify plan presentation format
- Test git commit: Verify commit created with correct message
- Test return format: Verify standardized format matches spec
- Test Prompt/Interactive Mode: Verify task summary as before

---

### Phase 6: Update meta Agent to Handle Task Context [NOT STARTED]

**Duration**: 1.5 hours  
**Dependencies**: Phase 5

**Objectives**:
- Update .opencode/agent/subagents/meta.md to handle task context
- Detect if task_number provided in delegation context
- Extract task metadata from delegation context
- Use task description as domain context
- Skip interview stages if task context provided

**Tasks**:
1. Add task context detection in meta agent
2. Extract task metadata from delegation context:
   - task_number
   - project_name
   - description
   - priority
   - type
   - language
3. Use task metadata to populate context:
   - domain = inferred from task description
   - purpose = task description
   - target_users = inferred from task context
4. Adapt stage execution to skip interview if task context provided
5. Update return format to include task_number and mode in metadata

**Acceptance Criteria**:
- [ ] Task context detection implemented
- [ ] Task metadata extracted from delegation context
- [ ] Task metadata used to populate domain context
- [ ] Interview stages skipped when task context provided
- [ ] Return format includes task_number and mode
- [ ] Agent documentation updated

**Testing**:
- Test with task context: Verify interview stages skipped
- Test without task context: Verify full interview executed
- Test metadata extraction: Verify all fields extracted correctly
- Test return format: Verify task_number and mode included

---

### Phase 7: Update Command Documentation [NOT STARTED]

**Duration**: 1 hour  
**Dependencies**: Phase 6

**Objectives**:
- Update .opencode/command/meta.md to document new task number support
- Add usage examples for all three modes
- Document mode detection logic
- Provide troubleshooting guidance

**Tasks**:
1. Update Usage section:
   - Add task number parameter: `/meta [TASK_NUMBER | PROMPT]`
   - Document three modes: Task Mode, Prompt Mode, Interactive Mode
2. Add Examples section:
   - Example 1: Task mode - `/meta 294`
   - Example 2: Task mode with custom prompt - `/meta 294 "Focus on agent architecture"`
   - Example 3: Prompt mode - `/meta "I want to revise..."`
   - Example 4: Interactive mode - `/meta`
3. Update Workflow section:
   - Document three-mode behavior
   - Show stage execution flow for each mode
4. Add Mode Detection section:
   - Explain how mode is detected
   - Document fallback behavior
   - Provide troubleshooting guidance
5. Add comparison with /plan command:
   - When to use /meta vs. /plan
   - Examples for both commands

**Acceptance Criteria**:
- [ ] Usage section updated with task number parameter
- [ ] Examples added for all three modes
- [ ] Workflow section updated with mode-specific behavior
- [ ] Mode Detection section added
- [ ] Comparison with /plan command added
- [ ] Documentation clear and comprehensive

**Testing**:
- Review documentation for clarity
- Verify examples are accurate
- Test examples to ensure they work as documented

---

### Phase 8: Testing and Validation [NOT STARTED]

**Duration**: 1.5 hours  
**Dependencies**: Phase 7

**Objectives**:
- Test all three modes thoroughly
- Verify backward compatibility
- Validate plan artifacts created correctly
- Test error handling and edge cases

**Tasks**:
1. Test Task Mode:
   - Test with valid task number: `/meta 294`
   - Test with invalid task number: `/meta 999`
   - Test with task number and custom prompt: `/meta 294 "custom prompt"`
   - Verify plan artifact created in correct directory
   - Verify plan artifact follows template standard
   - Verify task status updated to [PLANNED]
   - Verify git commit created
2. Test Prompt Mode:
   - Test with non-integer prompt: `/meta "create system"`
   - Test with integer prompt that doesn't match task: `/meta 999`
   - Verify multiple tasks created
   - Verify plan artifacts created for all tasks
   - Verify backward compatibility maintained
3. Test Interactive Mode:
   - Test with no arguments: `/meta`
   - Verify full interview executed
   - Verify multiple tasks created
   - Verify backward compatibility maintained
4. Test error handling:
   - Test with missing state.json
   - Test with invalid state.json
   - Test with task not found
   - Verify error messages clear and helpful
5. Test edge cases:
   - Test with task number 0
   - Test with negative task number
   - Test with very large task number
   - Test with special characters in prompt

**Acceptance Criteria**:
- [ ] All Task Mode tests pass
- [ ] All Prompt Mode tests pass
- [ ] All Interactive Mode tests pass
- [ ] Error handling tests pass
- [ ] Edge case tests pass
- [ ] Backward compatibility verified
- [ ] All test results documented

**Testing**:
- Run all test cases systematically
- Document test results
- Fix any issues found
- Re-test after fixes

---

## Testing and Validation

### Unit Tests

1. **Mode Detection Tests**:
   - Test empty arguments → Interactive Mode
   - Test integer first token with valid task → Task Mode
   - Test integer first token with invalid task → Prompt Mode (fallback)
   - Test non-integer first token → Prompt Mode

2. **Task Number Parsing Tests**:
   - Test valid integer: "294"
   - Test invalid integer: "abc"
   - Test negative integer: "-1"
   - Test zero: "0"
   - Test large integer: "999999"

3. **Metadata Extraction Tests**:
   - Test with complete task metadata
   - Test with missing optional fields
   - Test with missing state.json
   - Test with invalid JSON in state.json

### Integration Tests

1. **Task Mode Integration**:
   - Test full workflow: `/meta 294` → plan artifact created → status updated → git commit
   - Test with custom prompt: `/meta 294 "custom prompt"`
   - Test with meta task type
   - Test with non-meta task type (should warn)

2. **Prompt Mode Integration**:
   - Test full workflow: `/meta "create system"` → multiple tasks created → plan artifacts created
   - Test backward compatibility with existing usage

3. **Interactive Mode Integration**:
   - Test full workflow: `/meta` → interview → multiple tasks created → plan artifacts created
   - Test backward compatibility with existing usage

### Acceptance Tests

1. **User Workflow Tests**:
   - User runs `/meta 294` → receives plan artifact → runs `/implement 294`
   - User runs `/meta "create system"` → receives multiple tasks → runs `/implement` on each
   - User runs `/meta` → completes interview → receives multiple tasks

2. **Backward Compatibility Tests**:
   - Existing Prompt Mode usage continues to work
   - Existing Interactive Mode usage continues to work
   - No breaking changes to existing workflows

3. **Documentation Tests**:
   - All examples in documentation work as described
   - Usage instructions are clear and accurate
   - Troubleshooting guidance is helpful

---

## Artifacts and Outputs

### Primary Artifacts

1. **Updated Command File**: `.opencode/command/meta.md`
   - Stage 1 (ParseAndValidate) added
   - Stages renumbered (0-9)
   - Conditional stage execution implemented
   - Documentation updated with three-mode support

2. **Updated Agent File**: `.opencode/agent/subagents/meta.md`
   - Task context handling added
   - Metadata extraction from delegation context
   - Interview stages skip logic for task context
   - Return format updated with task_number and mode

3. **Plan Artifacts**: `.opencode/specs/{task_number}_{project_name}/plans/implementation-001.md`
   - Created for tasks in Task Mode
   - Follows plan.md template standard
   - Includes metadata, phases, testing, artifacts sections

### Supporting Artifacts

1. **Test Results Documentation**:
   - Test cases and results for all three modes
   - Error handling test results
   - Edge case test results
   - Backward compatibility verification

2. **Git Commits**:
   - Commit for command file updates
   - Commit for agent file updates
   - Commit for documentation updates
   - Commit for plan artifacts (per task)

---

## Rollback/Contingency

### Rollback Plan

If implementation causes issues:

1. **Immediate Rollback**:
   - Revert git commits for command and agent files
   - Restore previous version of .opencode/command/meta.md
   - Restore previous version of .opencode/agent/subagents/meta.md
   - Remove any plan artifacts created in Task Mode

2. **Partial Rollback**:
   - If only Task Mode has issues, disable Task Mode detection
   - Fall back to Prompt Mode for all integer arguments
   - Keep Prompt Mode and Interactive Mode working

3. **Data Recovery**:
   - No data loss risk (only adding functionality)
   - Plan artifacts can be manually removed if needed
   - state.json not modified (read-only)

### Contingency Plans

1. **If Breaking Changes Detected**:
   - Add flag to force Prompt Mode: `/meta --prompt 294`
   - Document flag usage for edge cases
   - Update documentation with migration guide

2. **If Confusion Between /meta and /plan**:
   - Add cross-reference in documentation
   - Add suggestion in /meta output: "Hint: Use /plan for non-meta tasks"
   - Create decision tree diagram for command selection

3. **If Stage Renumbering Causes Issues**:
   - Use conditional Stage 1 without renumbering existing stages
   - Keep existing stage numbers and make Stage 1 optional
   - Update documentation to reflect conditional approach

---

## Success Metrics

### Functional Metrics

1. **Mode Detection Accuracy**: 100% correct mode detection for all test cases
2. **Task Mode Success Rate**: 100% successful plan artifact creation for valid tasks
3. **Backward Compatibility**: 100% existing usage patterns continue to work
4. **Error Handling**: 100% graceful error handling for invalid inputs

### Quality Metrics

1. **Documentation Completeness**: All three modes documented with examples
2. **Test Coverage**: All modes, error cases, and edge cases tested
3. **Code Quality**: Follows established patterns from /research, /implement, /plan
4. **User Experience**: Clear error messages and helpful guidance

### Performance Metrics

1. **Metadata Extraction Speed**: 8x faster than TODO.md parsing (using state.json)
2. **Task Mode Execution Time**: <5 seconds for plan artifact creation
3. **Prompt/Interactive Mode**: No performance degradation from current implementation

---

## Dependencies

### Internal Dependencies

1. **state.json**: Must exist and be valid JSON with task metadata
2. **TODO.md**: Must contain task entry with status and description
3. **plan.md template**: Must be available for plan artifact creation
4. **git-workflow-manager**: Must be available for git commits
5. **status-sync-manager**: Must be available for status updates

### External Dependencies

1. **jq**: Required for JSON parsing and metadata extraction
2. **git**: Required for version control and commits
3. **bash**: Required for command execution and scripting

### Command Dependencies

1. **/research**: Reference pattern for task number parsing
2. **/implement**: Reference pattern for metadata extraction
3. **/plan**: Reference pattern for plan artifact creation

---

## Notes

### Research Integration

This implementation plan integrates findings from research-001.md:

1. **Consistent Pattern**: Follows 2-stage ParseAndValidate → Delegate pattern from /research, /implement, /plan
2. **Three-Mode Detection**: Implements Task Mode (integer), Prompt Mode (non-integer), Interactive Mode (no args)
3. **State.json Metadata**: Uses state.json for 8x faster metadata extraction
4. **Workflow Adaptation**: Skips interview stages when task context provided
5. **Backward Compatibility**: Falls back to Prompt Mode if task not found

### Key Design Decisions

1. **Stage Renumbering**: Renumber existing stages to accommodate new Stage 1 (ParseAndValidate)
2. **Conditional Execution**: Make stages conditional based on detected mode
3. **Fallback Behavior**: Fall back to Prompt Mode if task number not found (with warning)
4. **Single Plan Artifact**: Create single plan artifact for Task Mode (not multiple tasks)
5. **Metadata Source**: Use state.json as authoritative source for task metadata

### Implementation Priorities

1. **High Priority**: Phases 1-5 (core functionality)
2. **Medium Priority**: Phases 6-7 (agent updates and documentation)
3. **High Priority**: Phase 8 (testing and validation)

### Estimated Timeline

- **Phase 1**: 2 hours
- **Phase 2**: 1 hour
- **Phase 3**: 1.5 hours
- **Phase 4**: 2 hours
- **Phase 5**: 1.5 hours
- **Phase 6**: 1.5 hours
- **Phase 7**: 1 hour
- **Phase 8**: 1.5 hours

**Total**: 10 hours (includes buffer for testing and iteration)

---

## Revision History

- **Version 001** (2026-01-04): Initial implementation plan created
  - 8 phases defined
  - Research findings integrated
  - Estimated effort: 10 hours
  - All phases marked [NOT STARTED]
