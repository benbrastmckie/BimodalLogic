# Implementation Plan: Update Orchestrator for New Argument Mechanism

**Task**: 262  
**Status**: [NOT STARTED]  
**Effort**: 2 hours  
**Priority**: Critical  
**Dependencies**: 261 (design)  
**Artifacts**: Updated orchestrator.md  
**Standards**: Agent design, delegation patterns  
**Type**: meta  
**Lean Intent**: N/A (meta task)

## Overview

Update the orchestrator agent to use the new argument passing mechanism designed in task 261. This includes modifying Stage 1 (PreflightValidation) and Stage 3 (RegisterAndDelegate) to work with the actual Claude Code CLI system.

## Goals

1. Update orchestrator.md to use new argument mechanism
2. Modify Stage 1 to parse arguments using new mechanism
3. Modify Stage 3 to format prompts correctly
4. Remove or update references to `$ARGUMENTS` if not applicable
5. Ensure backward compatibility with existing delegation patterns

## Non-Goals

- Updating command files (that's task 263)
- Testing the changes (that's task 264)
- Modifying subagent files (unless required by design)

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Orchestrator changes may break existing commands | High | Test with multiple command types |
| New mechanism may not work as expected | High | Implement with fallback logic |
| Changes may be complex and error-prone | Medium | Follow design document exactly |

## Implementation Phases

### Phase 1: Review Design [NOT STARTED]
**Estimated**: 15 minutes

**Objective**: Review task 261 design document and understand requirements

**Steps**:
1. Read task 261 design document thoroughly
2. Identify specific changes required for orchestrator
3. Note any special cases or edge cases
4. Prepare implementation checklist

**Acceptance Criteria**:
- [ ] Design document reviewed and understood
- [ ] Orchestrator changes identified
- [ ] Implementation checklist created

### Phase 2: Update Stage 1 (PreflightValidation) [NOT STARTED]
**Estimated**: 45 minutes

**Objective**: Modify Stage 1 to parse arguments using new mechanism

**Steps**:
1. Locate Stage 1 in orchestrator.md
2. Update argument parsing logic per design
3. Update validation rules for new mechanism
4. Update error messages to reflect new patterns
5. Add logging for debugging

**Acceptance Criteria**:
- [ ] Stage 1 updated with new parsing logic
- [ ] Validation rules updated
- [ ] Error messages updated
- [ ] Logging added

### Phase 3: Update Stage 3 (RegisterAndDelegate) [NOT STARTED]
**Estimated**: 30 minutes

**Objective**: Modify Stage 3 to format prompts correctly

**Steps**:
1. Locate Stage 3 in orchestrator.md
2. Update prompt formatting logic per design
3. Ensure task numbers are passed correctly to subagents
4. Update examples to reflect new mechanism
5. Verify delegation context includes all required data

**Acceptance Criteria**:
- [ ] Stage 3 updated with new prompt formatting
- [ ] Examples updated
- [ ] Delegation context verified

### Phase 4: Update Documentation and References [NOT STARTED]
**Estimated**: 30 minutes

**Objective**: Update all references to argument handling in orchestrator

**Steps**:
1. Search for all `$ARGUMENTS` references in orchestrator.md
2. Update or remove based on new mechanism
3. Update `<critical_instructions>` section
4. Update `<command_type_lists>` if needed
5. Update `<error_handling>` section with new error messages

**Acceptance Criteria**:
- [ ] All `$ARGUMENTS` references updated or removed
- [ ] Critical instructions updated
- [ ] Error handling updated
- [ ] Documentation consistent with new mechanism

## Testing & Validation

**Validation**:
1. Verify orchestrator.md syntax is valid
2. Verify all stages reference new mechanism correctly
3. Verify error messages are clear and actionable
4. Verify examples are accurate

**Manual Review**:
- Read through entire orchestrator.md for consistency
- Check that all stages flow logically
- Verify no broken references or outdated patterns

## Artifacts & Outputs

**Primary Artifacts**:
- `.opencode/agent/orchestrator.md` - Updated orchestrator

**Secondary Artifacts**:
- Implementation summary documenting changes

## Rollback/Contingency

If update breaks orchestrator:
1. Restore from `.opencode/agent/orchestrator.md.backup`
2. Document what failed and why
3. Revise implementation approach
4. Retry with corrected logic

## Success Criteria

- [ ] Orchestrator.md updated with new argument mechanism
- [ ] Stage 1 parses arguments correctly
- [ ] Stage 3 formats prompts correctly
- [ ] All references to old mechanism updated or removed
- [ ] Orchestrator ready for testing in task 264
