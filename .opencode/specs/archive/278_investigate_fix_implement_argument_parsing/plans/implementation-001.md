# Implementation Plan: Fix /implement Command Argument Parsing

## Metadata
- **Task**: 278
- **Status**: [PLANNED]
- **Estimated Effort**: 5 hours
- **Language**: general
- **Priority**: High
- **Plan Version**: 001
- **Created**: 2026-01-03
- **Research Integrated**: Yes (analysis-001.md)

## Overview

### Problem
The `/implement` command (and potentially other task-based commands) fails to parse task numbers from `$ARGUMENTS`, causing the orchestrator to return an error message requesting the task number despite it being provided. This blocks all task-based workflow commands.

### Scope
- Fix orchestrator argument parsing logic for task-based commands
- Strengthen Stage 1 (PreflightValidation) instructions
- Add explicit command type detection
- Validate fix across all task-based commands (/research, /plan, /implement, /revise)
- Add defensive validation to prevent regression

### Constraints
- Must maintain backward compatibility with existing command files
- Must not break direct commands (/meta, /review, /todo, /errors)
- Must preserve existing orchestrator workflow stages
- Changes limited to `.opencode/agent/orchestrator.md`

### Definition of Done
- `/implement 271` successfully parses 271 as task number
- All task-based commands (/research, /plan, /implement, /revise) work correctly
- Orchestrator Stage 1 correctly identifies command type
- Orchestrator Stage 1 correctly extracts and validates task number
- Orchestrator Stage 3 correctly formats prompt as "Task: {number}"
- No regression in direct command handling
- Root cause documented in plan

## Goals and Non-Goals

### Goals
1. Fix argument parsing for task-based commands
2. Add explicit command type detection logic
3. Strengthen Stage 1 validation instructions
4. Test all task-based commands for correctness
5. Document root cause and fix

### Non-Goals
- Redesigning the orchestrator architecture
- Changing command file formats
- Adding new commands or features
- Modifying subagent implementations

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking direct commands | High | Medium | Test all command types before committing |
| Orchestrator still ignores instructions | High | Medium | Add multiple reinforcement points in Stage 1 |
| Regression in other workflows | Medium | Low | Review all orchestrator stages for consistency |
| Fix doesn't address root cause | High | Low | Validate with actual command execution |

## Implementation Phases

### Phase 1: Add Explicit Command Type Detection [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Add explicit lists of task-based and direct commands to orchestrator.md

**Tasks**:
1. Read current orchestrator.md to understand structure
2. Add `<command_type_lists>` section before Stage 1
3. Define task-based commands: [research, plan, implement, revise]
4. Define direct commands: [meta, review, todo, errors]
5. Add command type detection logic to Stage 1, Step 1

**Acceptance Criteria**:
- Command type lists clearly defined in orchestrator.md
- Stage 1 references these lists for type detection
- Logic is explicit and unambiguous

**Files Modified**:
- `.opencode/agent/orchestrator.md`

### Phase 2: Strengthen Stage 1 Argument Parsing [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objective**: Make Stage 1 argument parsing instructions more explicit and imperative

**Tasks**:
1. Rewrite Stage 1, Step 2 with explicit parsing logic
2. Add validation for task-based commands:
   - Check if `$ARGUMENTS` is empty
   - Extract first token as task_number
   - Validate task_number is positive integer
   - Return error if validation fails
3. Add clear instructions for direct commands
4. Add checkpoint logging after argument parsing
5. Add examples for both command types

**Acceptance Criteria**:
- Stage 1, Step 2 has clear, imperative instructions
- Validation logic is explicit and complete
- Error handling is well-defined
- Examples demonstrate correct parsing

**Files Modified**:
- `.opencode/agent/orchestrator.md`

### Phase 3: Reinforce Stage 3 Prompt Formatting [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objective**: Ensure Stage 3 correctly uses parsed task_number from Stage 1

**Tasks**:
1. Review Stage 3 (RegisterAndDelegate) instructions
2. Add explicit reference to task_number from Stage 1
3. Strengthen prompt formatting instructions
4. Add validation that task_number was parsed in Stage 1
5. Add error handling if task_number missing

**Acceptance Criteria**:
- Stage 3 explicitly references Stage 1 task_number
- Prompt formatting is unambiguous: "Task: {task_number}"
- Validation prevents proceeding without task_number

**Files Modified**:
- `.opencode/agent/orchestrator.md`

### Phase 4: Add Defensive Validation [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Add multiple validation checkpoints to prevent orchestrator from skipping steps

**Tasks**:
1. Add pre-Stage 1 validation (orchestrator invoked correctly)
2. Add post-Stage 1 validation (all required data extracted)
3. Add pre-Stage 3 validation (task_number available for task-based commands)
4. Add explicit error messages for each validation failure
5. Add checkpoint logging between stages

**Acceptance Criteria**:
- Validation checkpoints at key transition points
- Clear error messages for each failure mode
- Logging helps diagnose future issues

**Files Modified**:
- `.opencode/agent/orchestrator.md`

### Phase 5: Testing and Validation [NOT STARTED]
**Estimated Effort**: 1 hour

**Objective**: Test all command types to ensure fix works and no regressions

**Tasks**:
1. Test task-based commands:
   - `/research 278` (existing task)
   - `/plan 278` (existing task)
   - `/implement 271` (original failing case)
   - `/revise 195` (if applicable)
2. Test direct commands:
   - `/meta` (no arguments)
   - `/review` (optional arguments)
   - `/todo` (no arguments)
   - `/errors` (no arguments)
3. Test edge cases:
   - Invalid task number (non-integer)
   - Missing task number
   - Extra arguments after task number
4. Document test results
5. Fix any issues discovered

**Acceptance Criteria**:
- All task-based commands work correctly
- All direct commands work correctly
- Edge cases handled gracefully
- No regressions detected
- Test results documented

**Files Modified**:
- None (testing only)

## Testing and Validation

### Unit Testing
- Not applicable (orchestrator is prompt-based, not code)

### Integration Testing
1. Test each task-based command with valid task number
2. Test each direct command with and without arguments
3. Test error cases (invalid input, missing arguments)

### Manual Testing
1. Run `/implement 271` and verify it proceeds to implementation
2. Run `/research 278` and verify it proceeds to research
3. Run `/plan 278` and verify it proceeds to planning
4. Run `/meta` and verify it works without arguments

### Validation Criteria
- [ ] All task-based commands parse arguments correctly
- [ ] All direct commands work as before
- [ ] Error messages are clear and helpful
- [ ] No orchestrator stage is skipped
- [ ] Logging provides visibility into execution

## Artifacts and Outputs

### Primary Artifacts
1. **Updated Orchestrator**: `.opencode/agent/orchestrator.md`
   - Command type lists added
   - Stage 1 argument parsing strengthened
   - Stage 3 prompt formatting reinforced
   - Defensive validation added

### Documentation
1. **Test Results**: Document test outcomes in this plan
2. **Root Cause Analysis**: Update analysis-001.md with confirmed root cause

### No New Files
- All changes are modifications to existing orchestrator.md

## Rollback/Contingency

### Rollback Plan
If the fix causes issues:
1. Revert `.opencode/agent/orchestrator.md` to previous version
2. Use git to restore: `git checkout HEAD~1 .opencode/agent/orchestrator.md`
3. Document what went wrong
4. Revise plan with new approach

### Contingency Approach
If orchestrator still doesn't follow instructions:
1. Consider adding argument parsing to command files themselves
2. Consider creating a dedicated argument-parser subagent
3. Consider simplifying orchestrator instructions
4. Escalate to OpenCode framework team if framework issue

## Success Metrics

### Functional Metrics
- [ ] `/implement 271` executes successfully
- [ ] All task-based commands work (4/4 tested)
- [ ] All direct commands work (4/4 tested)
- [ ] Zero regressions detected

### Quality Metrics
- [ ] Orchestrator instructions are clear and unambiguous
- [ ] Error messages are helpful and actionable
- [ ] Logging provides adequate visibility
- [ ] Code review passes (if applicable)

### User Impact
- [ ] Users can execute task-based commands
- [ ] Workflow is unblocked
- [ ] No manual workarounds needed

## Dependencies

### Upstream Dependencies
- None (self-contained fix)

### Downstream Impact
- Unblocks Task 271 (Revise /meta command)
- Unblocks Task 275 (Fix workflow status updates)
- Unblocks Task 276 (Investigate redundant state.json)
- Unblocks Task 277 (Improve command headers)
- Unblocks all future task-based work

## Notes

### Research Findings Integration
The analysis report (analysis-001.md) identified that:
1. Command file configuration is correct
2. Orchestrator documentation is correct
3. `$ARGUMENTS` variable substitution works
4. **Root cause**: Orchestrator AI agent not following Stage 1 instructions

This plan addresses the root cause by:
- Making instructions more explicit and imperative
- Adding command type detection lists
- Adding defensive validation
- Reinforcing critical steps with multiple checkpoints

### Implementation Strategy
The fix uses a "defense in depth" approach:
1. **Explicit lists**: Remove ambiguity about command types
2. **Imperative instructions**: Use "MUST" and "CRITICAL" language
3. **Validation checkpoints**: Prevent skipping steps
4. **Error handling**: Provide clear feedback on failures
5. **Logging**: Enable diagnosis of future issues

This multi-layered approach increases the likelihood that the orchestrator will follow the correct workflow.

### Lessons Learned (Post-Implementation)
_To be filled in after implementation_

## Phase Execution Log

### Phase 1: [NOT STARTED]
_Execution notes will be added here_

### Phase 2: [NOT STARTED]
_Execution notes will be added here_

### Phase 3: [NOT STARTED]
_Execution notes will be added here_

### Phase 4: [NOT STARTED]
_Execution notes will be added here_

### Phase 5: [NOT STARTED]
_Execution notes will be added here_
