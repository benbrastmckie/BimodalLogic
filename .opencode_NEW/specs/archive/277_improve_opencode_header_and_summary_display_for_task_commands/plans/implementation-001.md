# Implementation Plan: Improve OpenCode Header and Summary Display for Task Commands

## Metadata
- **Task**: 277
- **Status**: [PLANNED]
- **Estimated Effort**: 4.5 hours
- **Complexity**: Medium
- **Language**: general
- **Plan Version**: 1
- **Created**: 2026-01-03
- **Research Integrated**: Yes (research-001.md)

## Overview

### Problem Statement
The OpenCode system lacks consistent user-facing headers and summary conclusions for commands. Users cannot easily identify which task or command is running, and final summaries do not include task/command references for easy tracking.

### Scope
This implementation will modify the orchestrator's Stage 5 (PostflightCleanup) to add:
1. Headers displaying "Task: {number}" for task-based commands or "Command: /{command}" for direct commands
2. Summary conclusions with task/command references
3. A new command-output.md standard documenting the format

### Constraints
- Must maintain <100 token summary limit (existing standard)
- Must not break existing command workflows
- Must work for all command types (task-based and direct)
- Changes isolated to orchestrator.md and new standard file

### Definition of Done
- Headers display correctly for all command types
- Summary conclusions include task/command references
- command-output.md standard created and documented
- All commands tested and verified
- No regression in existing functionality

## Goals and Non-Goals

### Goals
- Add user-facing headers to all command outputs
- Add summary conclusions with task/command references
- Create command-output.md standard
- Update orchestrator Stage 1 to store command metadata
- Update orchestrator Stage 5 to format headers and conclusions
- Test all command types (9 commands total)

### Non-Goals
- Modifying subagent return formats (not needed per research)
- Changing command files (orchestrator controls output)
- Streaming headers before execution (display with result)
- Enforcing stricter summary limits (existing <100 token limit sufficient)

## Risks and Mitigations

### Risk 1: Context Window Impact
**Severity**: Low  
**Description**: Adding header and conclusion increases output by ~20 tokens  
**Mitigation**: Total output still ~120 tokens, well under limits. Summary remains <100 tokens.

### Risk 2: Backward Compatibility
**Severity**: Low  
**Description**: Tools parsing command output may break  
**Mitigation**: Output is for human consumption. No known tools depend on current format. Changes are purely additive.

### Risk 3: Command Type Detection Failure
**Severity**: Medium  
**Description**: Orchestrator may fail to detect command type correctly  
**Mitigation**: Command type detection already exists in Stage 1. Add validation and fallback to generic format.

## Implementation Phases

### Phase 1: Create command-output.md Standard [NOT STARTED]
**Estimated Effort**: 1 hour

**Objectives**:
- Create `.opencode/context/core/standards/command-output.md`
- Document header format for task-based and direct commands
- Document summary conclusion format
- Provide examples for all command types

**Tasks**:
1. Create command-output.md file in standards directory
2. Define header format specifications:
   - Task-based: "Task: {number}"
   - Direct: "Command: /{command}"
3. Define conclusion format specifications:
   - Task-based: "Task {number} - /{command}"
   - Direct: "Command: /{command}"
4. Document token limits and formatting rules
5. Provide examples for each command type:
   - Task-based: /research, /plan, /implement, /revise, /task
   - Direct: /todo, /errors, /review, /meta
6. Add references to orchestrator.md and subagent-return-format.md

**Acceptance Criteria**:
- [ ] command-output.md created with complete specification
- [ ] Header formats documented for both command types
- [ ] Conclusion formats documented for both command types
- [ ] Examples provided for all 9 commands
- [ ] Token limits and formatting rules documented

**Validation**:
- File exists at correct path
- Contains all required sections
- Examples are clear and accurate

---

### Phase 2: Update Orchestrator Stage 1 (Metadata Storage) [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objectives**:
- Store command_type in delegation_context
- Store task_number in delegation_context (if applicable)
- Store command_name in delegation_context

**Tasks**:
1. Read current orchestrator.md Stage 1 implementation
2. Identify where command_type is determined (already exists)
3. Add command_type to delegation_context
4. Add task_number to delegation_context (for task-based commands)
5. Add command_name to delegation_context (from command file)
6. Ensure metadata is passed to Stage 5

**Acceptance Criteria**:
- [ ] delegation_context includes command_type
- [ ] delegation_context includes task_number (for task-based commands)
- [ ] delegation_context includes command_name
- [ ] Metadata accessible in Stage 5

**Validation**:
- Test with task-based command (e.g., /research 258)
- Test with direct command (e.g., /review)
- Verify delegation_context contains expected fields

---

### Phase 3: Update Orchestrator Stage 5 (Header and Conclusion Formatting) [NOT STARTED]
**Estimated Effort**: 1.5 hours

**Objectives**:
- Add header formatting logic before summary
- Add conclusion formatting logic after summary
- Update return_format templates for all status types

**Tasks**:
1. Read current orchestrator.md Stage 5 implementation
2. Add header formatting logic:
   - Determine command type from delegation_context
   - Format header based on command type:
     - Task-based: "Task: {task_number}"
     - Direct: "Command: /{command_name}"
3. Add conclusion formatting logic:
   - Format conclusion based on command type:
     - Task-based: "Task {task_number} - /{command_name}"
     - Direct: "Command: /{command_name}"
4. Update return_format templates:
   - Add header before summary
   - Add conclusion after artifacts/errors
5. Handle edge cases:
   - Missing task_number (fallback to generic format)
   - Missing command_name (fallback to generic format)
   - Empty summary (still display header and conclusion)

**Acceptance Criteria**:
- [ ] Header formatting logic implemented
- [ ] Conclusion formatting logic implemented
- [ ] return_format templates updated for all status types
- [ ] Edge cases handled gracefully
- [ ] Output format matches command-output.md standard

**Validation**:
- Test with completed status
- Test with failed status
- Test with partial status
- Test with blocked status
- Verify header and conclusion display correctly

---

### Phase 4: Update Orchestrator Context Loading [NOT STARTED]
**Estimated Effort**: 0.5 hours

**Objectives**:
- Add command-output.md to orchestrator's required context files
- Ensure orchestrator loads output formatting standard

**Tasks**:
1. Read orchestrator.md context_loading section
2. Add command-output.md to required context files list
3. Verify context loading order (standards should load early)
4. Test that orchestrator has access to command-output.md content

**Acceptance Criteria**:
- [ ] command-output.md added to required context files
- [ ] Context loading order correct
- [ ] Orchestrator can access command-output.md content

**Validation**:
- Verify orchestrator loads command-output.md
- Check context window size (should not exceed limits)

---

### Phase 5: Testing and Validation [NOT STARTED]
**Estimated Effort**: 1 hour

**Objectives**:
- Test all task-based commands
- Test all direct commands
- Verify headers and conclusions display correctly
- Verify no regression in existing functionality

**Tasks**:
1. Test task-based commands:
   - /research {number}
   - /plan {number}
   - /implement {number}
   - /revise {number}
   - /task {number}
2. Test direct commands:
   - /todo
   - /errors
   - /review
   - /meta
3. Verify for each command:
   - Header displays correctly
   - Summary is brief (<100 tokens)
   - Conclusion displays correctly
   - Artifacts listed correctly
   - Errors handled correctly
4. Test edge cases:
   - Invalid task number
   - Missing arguments
   - Failed command execution
   - Partial completion
5. Verify no regression:
   - Existing workflows still work
   - Subagents receive correct prompts
   - Return format still valid

**Acceptance Criteria**:
- [ ] All 5 task-based commands tested successfully
- [ ] All 4 direct commands tested successfully
- [ ] Headers display correctly for all commands
- [ ] Conclusions display correctly for all commands
- [ ] Summaries remain brief (<100 tokens)
- [ ] No regression in existing functionality
- [ ] Edge cases handled gracefully

**Validation**:
- Create test checklist with all commands
- Document test results
- Verify all acceptance criteria met

---

## Testing and Validation

### Unit Testing
- Test header formatting logic with various inputs
- Test conclusion formatting logic with various inputs
- Test command type detection
- Test task number extraction

### Integration Testing
- Test complete workflow for each command type
- Test orchestrator Stage 1 → Stage 5 data flow
- Test with real task numbers and commands

### Acceptance Testing
- Verify headers match command-output.md standard
- Verify conclusions match command-output.md standard
- Verify summaries remain brief
- Verify all 9 commands work correctly

### Regression Testing
- Test existing commands still work
- Test subagent delegation still works
- Test error handling still works
- Test artifact creation still works

## Artifacts and Outputs

### Primary Artifacts
1. `.opencode/context/core/standards/command-output.md` - Output format standard
2. `.opencode/agent/orchestrator.md` - Updated with header and conclusion logic

### Validation Artifacts
1. Test results document (informal, not committed)
2. Example outputs for all command types (in command-output.md)

## Rollback/Contingency

### Rollback Plan
If implementation causes issues:
1. Revert orchestrator.md to previous version
2. Remove command-output.md (new file, safe to delete)
3. Test that commands work without headers/conclusions
4. Investigate and fix issues before re-implementing

### Contingency Plan
If orchestrator changes are too complex:
1. Implement simplified version (headers only, no conclusions)
2. Add conclusions in follow-up task
3. Document limitations and plan for full implementation

### Validation Before Commit
- All 9 commands tested successfully
- No errors in orchestrator logic
- Headers and conclusions display correctly
- No regression in existing functionality

## Success Metrics

### Functional Metrics
- [ ] 100% of commands display headers correctly
- [ ] 100% of commands display conclusions correctly
- [ ] 100% of summaries remain <100 tokens
- [ ] 0 regressions in existing functionality

### Quality Metrics
- [ ] command-output.md standard complete and clear
- [ ] orchestrator.md changes well-documented
- [ ] All edge cases handled
- [ ] Code follows existing patterns

### User Experience Metrics
- [ ] Users can easily identify which task/command is running
- [ ] Summaries are concise and informative
- [ ] Output format is consistent across all commands

## Dependencies

### Internal Dependencies
- Orchestrator Stage 1 (command type detection) - already exists
- Orchestrator Stage 5 (output formatting) - will be modified
- Subagent return format standard - already exists

### External Dependencies
- None

### Blocking Issues
- None

## Notes

### Research Integration
This plan integrates findings from research-001.md:
- Orchestrator Stage 5 modification approach (recommended solution)
- Command type detection already exists in Stage 1
- Subagent return format already enforces <100 token summaries
- No changes needed to subagents or command files

### Implementation Strategy
The phased approach ensures:
1. Standard created first (defines requirements)
2. Metadata storage updated (enables formatting)
3. Formatting logic implemented (core functionality)
4. Context loading updated (ensures standard available)
5. Comprehensive testing (validates all changes)

### Key Decisions
- **Approach**: Modify orchestrator Stage 5 (not subagents or commands)
- **Display Timing**: Headers displayed with results (not before execution)
- **Summary Limits**: Keep existing <100 token limit (no stricter enforcement)
- **Backward Compatibility**: Purely additive changes (no breaking changes)
