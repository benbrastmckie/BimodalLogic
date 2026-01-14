# Implementation Plan: /abandon Command

**Task**: 298 - Create /abandon command to mark tasks as [ABANDONED] with reason  
**Status**: [PLANNING]  
**Created**: 2026-01-05  
**Estimated Effort**: 2.5 hours  
**Complexity**: Low-Medium  
**Language**: markdown  
**Priority**: Medium  

---

## Metadata

**Research Integrated**: Yes  
**Research Artifacts**:
- .opencode/specs/298_abandon_command/reports/research-001.md

**Dependencies**: None  
**Blocking**: None  

**Phase Count**: 4  
**Total Estimated Hours**: 2.5  

---

## Overview

### Problem Statement

Currently, there is no standardized command to mark tasks as [ABANDONED] with a documented reason. Users must manually edit TODO.md and state.json, which is error-prone and bypasses atomic update mechanisms. This creates inconsistencies between the two files and lacks proper audit trails for abandoned work.

### Solution Approach

Create a /abandon command following the same architectural patterns as /plan, /implement, and /research commands. The command will:
1. Parse task number and optional reason from arguments
2. Validate task exists and status allows abandonment
3. Prompt for reason if not provided inline
4. Delegate to status-sync-manager for atomic updates
5. Return success or error message

### Scope

**In Scope**:
- /abandon command file creation
- Argument parsing (task number + optional reason)
- Task validation (existence, status)
- Interactive reason prompting
- Delegation to status-sync-manager
- Error handling and messages

**Out of Scope**:
- Reversal mechanism (/unabandoned command)
- Confirmation prompts for high-priority tasks
- Batch abandonment support
- status-sync-manager modifications (already supports [ABANDONED])

### Constraints

- Must follow command-template.md structure exactly
- Must use state.json for task lookup (not TODO.md)
- Must delegate to status-sync-manager (no direct file manipulation)
- Must validate status transition before delegation
- Must support both inline and prompted reason
- Reason must be 10-500 characters

### Definition of Done

- [ ] /abandon command file created at .opencode/command/abandon.md
- [ ] Command follows two-stage pattern (ParseAndValidate, Delegate)
- [ ] Task validation uses state.json lookup
- [ ] Status transition validation implemented
- [ ] Reason parsing supports inline and prompted modes
- [ ] Delegation to status-sync-manager implemented
- [ ] Error messages clear and actionable
- [ ] Command tested with valid and invalid inputs
- [ ] Documentation includes usage examples

---

## Goals and Non-Goals

### Goals

1. **Consistency**: Follow exact same patterns as /plan, /implement, /research
2. **Reliability**: Atomic updates via status-sync-manager delegation
3. **Usability**: Support both inline and interactive reason entry
4. **Clarity**: Clear error messages for all failure cases
5. **Performance**: Fast task lookup using state.json (8x faster than TODO.md)

### Non-Goals

1. **Reversal**: /unabandoned command (future enhancement)
2. **Confirmation**: Prompts for high-priority tasks (future enhancement)
3. **Batch**: Abandon multiple tasks at once (future enhancement)
4. **History**: Track abandonment history beyond single reason (future enhancement)

---

## Risks and Mitigations

### Risk 1: Status Transition Validation Mismatch

**Description**: Command validation and status-sync-manager validation may diverge.  
**Likelihood**: Medium  
**Impact**: Medium  

**Mitigation**:
- Reference status-markers.md in both validators
- Add integration test verifying both validators agree
- Document valid transitions in state-management.md

### Risk 2: Reason Prompt Hangs in Non-Interactive Mode

**Description**: read -r hangs if command run in script/pipeline.  
**Likelihood**: Low  
**Impact**: High  

**Mitigation**:
- Detect non-interactive mode: if [ ! -t 0 ]
- Require reason inline in non-interactive mode
- Add timeout to read: read -r -t 30 reason
- Document requirement in command help

### Risk 3: Reason Contains Special Characters

**Description**: Quotes, newlines break JSON/markdown formatting.  
**Likelihood**: Medium  
**Impact**: Medium  

**Mitigation**:
- Use jq --arg for automatic escaping
- Validate reason contains only printable ASCII
- Strip newlines and control characters
- Test with special character inputs

---

## Implementation Phases

### Phase 1: Create Command File Structure [NOT STARTED]

**Estimated Effort**: 30 minutes

**Objective**: Create /abandon command file with frontmatter and basic structure.

**Tasks**:
1. Create .opencode/command/abandon.md
2. Add frontmatter following command-template.md:
   - name: abandon
   - agent: orchestrator
   - description: "Mark tasks as [ABANDONED] with reason"
   - context_level: 2
   - language: markdown
   - routing.language_based: false
   - routing.target_agent: status-sync-manager
   - timeout: 300
3. Add context_loading section:
   - strategy: lazy
   - required: delegation.md, state-management.md, command-argument-handling.md
   - max_context_size: 50000
4. Add Task Input specification
5. Add context block
6. Add role and task blocks

**Acceptance Criteria**:
- [ ] abandon.md created with valid frontmatter
- [ ] Frontmatter matches command-template.md structure
- [ ] Direct routing to status-sync-manager configured
- [ ] Context loading specified

**Validation**:
```bash
# Verify file exists
test -f .opencode/command/abandon.md

# Verify frontmatter is valid YAML
head -20 .opencode/command/abandon.md | grep -q "name: abandon"
```

---

### Phase 2: Implement Stage 1 (ParseAndValidate) [NOT STARTED]

**Estimated Effort**: 1 hour

**Objective**: Implement argument parsing, task lookup, and validation logic.

**Tasks**:
1. Parse task number from $ARGUMENTS (first token)
2. Validate task number is positive integer
3. Parse reason from $ARGUMENTS (remaining tokens)
4. If reason empty: Prompt user with read -r
5. Validate reason length (10-500 characters)
6. Validate state.json exists and is valid JSON
7. Lookup task in state.json using jq
8. Validate task exists
9. Extract current status from task_data
10. Validate status allows abandonment:
    - Not "completed" (terminal state)
    - Not "abandoned" (already abandoned)
    - Not "not_started" (cannot abandon work never started)
11. Generate timestamp: $(date -I)

**Acceptance Criteria**:
- [ ] Task number parsed and validated
- [ ] Reason parsed from inline or prompted
- [ ] Reason length validated (10-500 chars)
- [ ] state.json lookup implemented
- [ ] Task existence validated
- [ ] Status transition validated
- [ ] Clear error messages for all failure cases

**Validation**:
```bash
# Test valid input
/abandon 298 "No longer needed"

# Test missing reason (should prompt)
/abandon 298

# Test invalid task number
/abandon abc  # Should error

# Test task not found
/abandon 9999  # Should error

# Test completed task
/abandon 221  # Should error (task 221 is completed)

# Test not started task
/abandon 260  # Should error (task 260 is not started)
```

**Error Messages**:
- Invalid task number: "Error: Task number must be an integer. Got: {input}"
- Task not found: "Error: Task {number} not found in state.json"
- Task completed: "Error: Task {number} is [COMPLETED]. Cannot abandon completed tasks."
- Task abandoned: "Error: Task {number} is already [ABANDONED]"
- Task not started: "Error: Task {number} is [NOT STARTED]. Cannot abandon work that hasn't started. Use /todo to remove task instead."
- Missing reason: "Error: Abandonment reason required. Usage: /abandon TASK_NUMBER [REASON]"
- Reason too short: "Error: Abandonment reason too short (minimum 10 characters)"
- Reason too long: "Error: Abandonment reason too long (maximum 500 characters)"

---

### Phase 3: Implement Stage 2 (Delegate) [NOT STARTED]

**Estimated Effort**: 45 minutes

**Objective**: Implement delegation to status-sync-manager with proper context.

**Tasks**:
1. Generate session_id: sess_$(date +%Y%m%d)_$(openssl rand -hex 3)
2. Prepare delegation context JSON:
   - operation: "update_status"
   - task_number: {number}
   - new_status: "abandoned"
   - timestamp: {iso_timestamp}
   - abandonment_reason: {reason}
   - session_id: {session_id}
   - delegation_depth: 1
   - delegation_path: ["orchestrator", "abandon", "status-sync-manager"]
3. Invoke status-sync-manager via task tool
4. Validate return format is valid JSON
5. Extract status from return
6. If status == "completed": Display success message
7. If status == "failed": Display error message and exit 1
8. Relay result to user

**Acceptance Criteria**:
- [ ] Session ID generated correctly
- [ ] Delegation context includes all required fields
- [ ] status-sync-manager invoked via task tool
- [ ] Return format validated
- [ ] Success/failure handled correctly
- [ ] User sees clear result message

**Validation**:
```bash
# Test successful abandonment
/abandon 298 "No longer needed due to architectural changes"
# Expected: "Task 298 marked as [ABANDONED]"
# Expected: "Reason: No longer needed due to architectural changes"
# Expected: "Files updated: TODO.md, state.json"

# Verify TODO.md updated
grep -A 10 "^### 298\." .opencode/specs/TODO.md | grep "\[ABANDONED\]"

# Verify state.json updated
jq -r '.active_projects[] | select(.project_number == 298) | .status' .opencode/specs/state.json
# Expected: "abandoned"

# Verify abandonment_reason in state.json
jq -r '.active_projects[] | select(.project_number == 298) | .abandonment_reason' .opencode/specs/state.json
# Expected: "No longer needed due to architectural changes"
```

---

### Phase 4: Add Documentation and Error Handling [NOT STARTED]

**Estimated Effort**: 15 minutes

**Objective**: Add usage documentation and comprehensive error handling.

**Tasks**:
1. Add Usage section with examples:
   - /abandon TASK_NUMBER [REASON]
   - /abandon 298
   - /abandon 298 "No longer needed"
2. Add What This Does section
3. Add Error Handling section with all error cases
4. Add Notes section:
   - Delegates to status-sync-manager
   - Atomic updates across TODO.md and state.json
   - Abandonment reason required and stored
   - No git commit created (status-sync-manager handles)
5. Add non-interactive mode detection:
   - if [ ! -t 0 ]; then require reason inline
6. Add timeout to read prompt: read -r -t 30 reason
7. Add special character handling:
   - Strip newlines from reason
   - Validate printable ASCII only

**Acceptance Criteria**:
- [ ] Usage section with examples added
- [ ] What This Does section added
- [ ] Error Handling section with all cases added
- [ ] Notes section added
- [ ] Non-interactive mode handled
- [ ] Read timeout added
- [ ] Special character handling added

**Validation**:
```bash
# Test non-interactive mode
echo "298" | /abandon
# Expected: Error requiring inline reason

# Test timeout
/abandon 298
# (wait 30 seconds without input)
# Expected: Timeout error

# Test special characters
/abandon 298 "Reason with \"quotes\" and 'apostrophes'"
# Expected: Success (characters escaped)

# Test newlines
/abandon 298 "Reason with
newline"
# Expected: Newline stripped or error
```

---

## Testing and Validation

### Unit Tests

**Test 1: Valid Abandonment**
```bash
/abandon 298 "No longer needed due to architectural changes"
# Expected: Success, status updated to [ABANDONED]
```

**Test 2: Prompted Reason**
```bash
/abandon 298
> No longer needed
# Expected: Success, status updated to [ABANDONED]
```

**Test 3: Invalid Task Number**
```bash
/abandon abc
# Expected: Error "Task number must be an integer"
```

**Test 4: Task Not Found**
```bash
/abandon 9999
# Expected: Error "Task 9999 not found"
```

**Test 5: Completed Task**
```bash
/abandon 221
# Expected: Error "Cannot abandon completed tasks"
```

**Test 6: Already Abandoned Task**
```bash
/abandon 298
/abandon 298
# Expected: Error "Task already abandoned"
```

**Test 7: Not Started Task**
```bash
/abandon 260
# Expected: Error "Cannot abandon work that hasn't started"
```

**Test 8: Reason Too Short**
```bash
/abandon 298 "short"
# Expected: Error "Reason too short (minimum 10 characters)"
```

**Test 9: Reason Too Long**
```bash
/abandon 298 "$(printf 'a%.0s' {1..501})"
# Expected: Error "Reason too long (maximum 500 characters)"
```

### Integration Tests

**Test 1: Atomic Update Verification**
```bash
# Abandon task
/abandon 298 "Test reason"

# Verify TODO.md updated
grep -A 10 "^### 298\." .opencode/specs/TODO.md | grep "\[ABANDONED\]"

# Verify state.json updated
jq -r '.active_projects[] | select(.project_number == 298) | .status' .opencode/specs/state.json

# Verify both files have same status
```

**Test 2: Rollback on Failure**
```bash
# Make state.json read-only
chmod 444 .opencode/specs/state.json

# Try to abandon task
/abandon 298 "Test reason"
# Expected: Error, TODO.md rolled back

# Verify TODO.md not updated
grep -A 10 "^### 298\." .opencode/specs/TODO.md | grep -v "\[ABANDONED\]"

# Restore permissions
chmod 644 .opencode/specs/state.json
```

### Acceptance Tests

**Test 1: End-to-End Workflow**
```bash
# Create test task
/task "Test task for abandonment" --priority=low

# Start task
/implement {task_number}
# (cancel implementation)

# Abandon task
/abandon {task_number} "Test abandonment workflow"

# Verify status
grep -A 10 "^### {task_number}\." .opencode/specs/TODO.md | grep "\[ABANDONED\]"

# Verify reason
grep -A 10 "^### {task_number}\." .opencode/specs/TODO.md | grep "Test abandonment workflow"
```

---

## Artifacts and Outputs

### Primary Artifacts

1. **.opencode/command/abandon.md**
   - Command file with frontmatter
   - Two-stage workflow implementation
   - Documentation and examples
   - Estimated size: ~150 lines

### Modified Files

1. **.opencode/specs/TODO.md**
   - Updated by status-sync-manager when task abandoned
   - Status marker changed to [ABANDONED]
   - Abandonment reason added
   - Timestamp added

2. **.opencode/specs/state.json**
   - Updated by status-sync-manager when task abandoned
   - status field changed to "abandoned"
   - abandonment_reason field added
   - abandoned timestamp added

### Documentation

1. **Usage Examples** (in abandon.md)
   - Basic usage
   - Inline reason
   - Prompted reason
   - Error cases

2. **Error Messages** (in abandon.md)
   - All failure scenarios
   - Recommendations for each error
   - Usage examples

---

## Rollback/Contingency

### Rollback Plan

If /abandon command causes issues:

1. **Remove command file**:
   ```bash
   rm .opencode/command/abandon.md
   ```

2. **Revert any abandoned tasks manually**:
   ```bash
   # Edit TODO.md to change status back
   # Edit state.json to change status back
   ```

3. **Use /meta to regenerate state.json** (if corrupted):
   ```bash
   /meta
   ```

### Contingency Plan

If status-sync-manager doesn't support [ABANDONED]:

1. **Verify status-sync-manager supports abandoned status**:
   ```bash
   grep -A 20 "abandoned" .opencode/agent/subagents/status-sync-manager.md
   ```

2. **If not supported**: Add abandoned status support to status-sync-manager first

3. **If supported but broken**: Fix status-sync-manager before implementing /abandon

---

## Success Metrics

### Functional Metrics

- [ ] Command successfully abandons tasks with valid status
- [ ] Command rejects invalid status transitions
- [ ] Abandonment reason captured in both TODO.md and state.json
- [ ] Atomic updates work correctly (both files updated or neither)
- [ ] Rollback works on failure

### Quality Metrics

- [ ] All error cases have clear messages
- [ ] Command follows same patterns as /plan, /implement, /research
- [ ] Code is well-documented with examples
- [ ] No direct file manipulation (delegates to status-sync-manager)

### Performance Metrics

- [ ] Task lookup completes in <10ms (state.json)
- [ ] Total command execution <500ms (excluding user input)
- [ ] No performance regression vs other commands

---

## Notes

### Research Integration

Research findings from research-001.md inform this plan:
- Two-stage command pattern (ParseAndValidate, Delegate)
- State.json lookup (8x faster than TODO.md)
- Direct routing to status-sync-manager (no intermediate agent)
- Status validation in command (fail fast)
- Flexible argument parsing (inline + prompted)
- Clear error messages for all cases

### Architectural Decisions

1. **Direct Routing**: Route directly to status-sync-manager (no intermediate agent) because /abandon has no business logic beyond status update.

2. **Duplicate Validation**: Validate status transition in command AND status-sync-manager for better UX (fail fast) and defense in depth.

3. **Prompted Reason**: Support both inline and prompted reason for flexible usage patterns.

4. **Minimum Reason Length**: 10 characters minimum to ensure meaningful reasons without being too restrictive.

### Dependencies

- status-sync-manager must support "abandoned" status (already implemented)
- state.json must exist and be valid (validated in command)
- TODO.md must exist (validated by status-sync-manager)

### Future Enhancements

1. **/unabandoned command**: Reverse abandonment (change status back)
2. **Confirmation prompts**: For high-priority or long-running tasks
3. **Batch abandonment**: Abandon multiple tasks at once
4. **Abandonment history**: Track multiple abandonment attempts
5. **Abandonment categories**: Categorize reasons (obsolete, blocked, duplicate, etc.)

---

## Phase Status Summary

| Phase | Status | Estimated | Actual | Notes |
|-------|--------|-----------|--------|-------|
| 1. Create Command File Structure | [NOT STARTED] | 30 min | - | Frontmatter and basic structure |
| 2. Implement Stage 1 (ParseAndValidate) | [NOT STARTED] | 1 hour | - | Argument parsing and validation |
| 3. Implement Stage 2 (Delegate) | [NOT STARTED] | 45 min | - | Delegation to status-sync-manager |
| 4. Add Documentation and Error Handling | [NOT STARTED] | 15 min | - | Usage docs and error handling |

**Total Estimated**: 2.5 hours  
**Total Actual**: -  
**Completion**: 0%  

---

## Conclusion

This implementation plan provides a clear roadmap for creating the /abandon command following the same architectural patterns as existing workflow commands. The plan breaks the work into 4 manageable phases totaling 2.5 hours of effort. Each phase has clear objectives, tasks, acceptance criteria, and validation steps.

The command will be simple (~150 lines), delegate all status updates to status-sync-manager, and provide excellent UX with clear error messages and flexible argument parsing. Research findings have been fully integrated to ensure consistency with existing commands and best practices.

**Next Steps**: Execute Phase 1 to create the command file structure.
