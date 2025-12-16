# Task Status Tracking - Testing Checklist

**Feature**: Automatic TODO.md status tracking for `/task` command  
**Date**: 2025-12-16  
**Status**: Ready for Testing

## Pre-Testing Setup

### Prerequisites
- [ ] TODO.md exists at `.opencode/specs/TODO.md`
- [ ] TODO.md contains tasks with standard format
- [ ] Task numbers are unique
- [ ] Status fields are present in task sections

### Backup
- [ ] Create backup of TODO.md: `cp .opencode/specs/TODO.md .opencode/specs/TODO.md.backup`
- [ ] Verify backup: `diff .opencode/specs/TODO.md .opencode/specs/TODO.md.backup`

## Unit Tests

### Test 1: Task Matching
**Objective**: Verify correct task is identified by number

**Test Cases**:
- [ ] Task with single-digit number (e.g., Task 9)
- [ ] Task with double-digit number (e.g., Task 61)
- [ ] Task with triple-digit number (e.g., Task 123)
- [ ] Task at beginning of file
- [ ] Task in middle of file
- [ ] Task at end of file

**Expected**: Correct task section is identified in all cases

### Test 2: Status Update - Mark IN PROGRESS
**Objective**: Verify status changes from "Not Started" to "[IN PROGRESS]"

**Setup**:
```markdown
### 61. Test Task
**Status**: Not Started
```

**Action**: Run `/task 61`

**Expected**:
```markdown
### 61. Test Task
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
```

**Verify**:
- [ ] Status changed to `[IN PROGRESS]`
- [ ] Started timestamp added with correct date
- [ ] All other content preserved exactly
- [ ] Formatting maintained (indentation, blank lines)

### Test 3: Status Update - Mark COMPLETE
**Objective**: Verify status changes from "[IN PROGRESS]" to "[COMPLETE]" for simple tasks

**Setup**:
```markdown
### 61. Test Task (Simple)
**Effort**: 15 minutes
**Status**: [IN PROGRESS]
**Started**: 2025-12-16
```

**Action**: Run `/task 61` (simple task that executes directly)

**Expected**:
```markdown
### 61. Test Task (Simple) ✅
**Effort**: 15 minutes
**Status**: [COMPLETE]
**Started**: 2025-12-16
**Completed**: 2025-12-16
```

**Verify**:
- [ ] Status changed to `[COMPLETE]`
- [ ] Completed timestamp added with correct date
- [ ] ✅ emoji added to title
- [ ] Started timestamp preserved
- [ ] All other content preserved exactly

### Test 4: Timestamp Addition
**Objective**: Verify timestamps are added correctly

**Test Cases**:
- [ ] Started timestamp added when marking IN PROGRESS
- [ ] Started timestamp NOT duplicated if already present
- [ ] Completed timestamp added when marking COMPLETE
- [ ] Completed timestamp NOT duplicated if already present
- [ ] Timestamps use correct format (YYYY-MM-DD)
- [ ] Timestamps use current date

**Expected**: Timestamps added correctly in all cases

### Test 5: Formatting Preservation
**Objective**: Verify all other TODO.md content remains unchanged

**Test Cases**:
- [ ] Indentation preserved (spaces and tabs)
- [ ] Blank lines preserved
- [ ] Markdown formatting preserved (bold, lists, code blocks)
- [ ] Other task sections unchanged
- [ ] Section headers unchanged
- [ ] Comments preserved
- [ ] Special characters preserved

**Expected**: Only status and timestamp fields modified, everything else identical

## Integration Tests

### Test 6: Simple Task Workflow
**Objective**: Test complete lifecycle for simple task

**Setup**: Task 61 (Add Missing Directory READMEs - 1 hour, simple)

**Steps**:
1. [ ] Verify initial status: `Not Started`
2. [ ] Run `/task 61`
3. [ ] Verify status changed to `[IN PROGRESS]`
4. [ ] Verify Started timestamp added
5. [ ] Verify task executes (creates README files)
6. [ ] Verify status changed to `[COMPLETE]`
7. [ ] Verify Completed timestamp added
8. [ ] Verify ✅ emoji added

**Expected**: Complete lifecycle works end-to-end

### Test 7: Moderate Task Workflow
**Objective**: Test workflow for moderate task requiring implementation

**Setup**: Task 52 (Fix AesopRules duplicate - 1 hour, moderate)

**Steps**:
1. [ ] Verify initial status: `Not Started`
2. [ ] Run `/task 52`
3. [ ] Verify status changed to `[IN PROGRESS]`
4. [ ] Verify Started timestamp added
5. [ ] Verify implementation plan created
6. [ ] Verify recommendation to use `/implement`
7. [ ] Verify status remains `[IN PROGRESS]` (not auto-completed)
8. [ ] Run recommended `/implement` command
9. [ ] Manually mark task complete
10. [ ] Verify final status: `[COMPLETE]`

**Expected**: Status stays IN PROGRESS until manual completion

### Test 8: Complex Task Workflow
**Objective**: Test workflow for complex task requiring research

**Setup**: Task 9 (Begin Completeness Proofs - 70-90 hours, complex)

**Steps**:
1. [ ] Verify initial status: `Not Started`
2. [ ] Run `/task 9`
3. [ ] Verify status changed to `[IN PROGRESS]`
4. [ ] Verify Started timestamp added
5. [ ] Verify research phase executes (creates research report)
6. [ ] Verify planning phase executes (creates implementation plan)
7. [ ] Verify recommendation to use `/lean`
8. [ ] Verify status remains `[IN PROGRESS]` (not auto-completed)

**Expected**: Research + planning complete, status stays IN PROGRESS

### Test 9: Already Complete Task
**Objective**: Test handling of already completed task

**Setup**:
```markdown
### 60. Test Task
**Status**: [COMPLETE]
**Completed**: 2025-12-15
```

**Action**: Run `/task 60`

**Expected**:
- [ ] Error message: "Task 60 is already marked complete ✅"
- [ ] Suggestion to choose another task
- [ ] Task execution stops (doesn't proceed)
- [ ] TODO.md unchanged

### Test 10: Concurrent Tasks
**Objective**: Test multiple tasks in progress simultaneously

**Steps**:
1. [ ] Run `/task 61` (marks IN PROGRESS)
2. [ ] Run `/task 62` (marks IN PROGRESS)
3. [ ] Verify both tasks marked IN PROGRESS
4. [ ] Verify each has unique Started timestamp
5. [ ] Complete task 61
6. [ ] Verify task 61 marked COMPLETE
7. [ ] Verify task 62 still IN PROGRESS

**Expected**: Multiple tasks tracked independently

## Error Handling Tests

### Test 11: Task Not Found
**Objective**: Test handling when task number doesn't exist

**Action**: Run `/task 999` (non-existent task)

**Expected**:
- [ ] Warning message: "Task 999 not found in TODO.md"
- [ ] Message: "Proceeding without status tracking"
- [ ] Task execution continues (doesn't crash)
- [ ] TODO.md unchanged

### Test 12: TODO.md Not Found
**Objective**: Test handling when TODO.md file doesn't exist

**Setup**: Temporarily rename TODO.md

**Action**: Run `/task 61`

**Expected**:
- [ ] Warning message: "TODO.md not found at .opencode/specs/TODO.md"
- [ ] Message: "Proceeding without status tracking"
- [ ] Task execution continues (doesn't crash)

**Cleanup**: Restore TODO.md

### Test 13: File Write Error
**Objective**: Test handling when TODO.md cannot be written

**Setup**: Make TODO.md read-only: `chmod 444 .opencode/specs/TODO.md`

**Action**: Run `/task 61`

**Expected**:
- [ ] Error message: "Failed to update TODO.md: {error}"
- [ ] Message: "Continuing with task execution"
- [ ] Task execution continues (doesn't crash)

**Cleanup**: Restore permissions: `chmod 644 .opencode/specs/TODO.md`

### Test 14: Malformed Task Section
**Objective**: Test handling of unexpected TODO.md format

**Test Cases**:
- [ ] Task section missing Status field
- [ ] Task section with unexpected format
- [ ] Task number in wrong format
- [ ] Missing section header

**Expected**: Graceful handling, warning logged, execution continues

### Test 15: Multiple Matches
**Objective**: Test handling when multiple tasks have same number

**Setup**: Create duplicate task numbers in TODO.md

**Action**: Run `/task 61`

**Expected**:
- [ ] Warning message: "Multiple matches for task 61 - using first occurrence"
- [ ] First match is updated
- [ ] Other matches unchanged
- [ ] Task execution continues

**Cleanup**: Remove duplicate task numbers

## Edge Cases

### Test 16: Large TODO.md
**Objective**: Test performance with large TODO.md file

**Setup**: TODO.md with 100+ tasks

**Action**: Run `/task 61`

**Expected**:
- [ ] Task found and updated correctly
- [ ] Performance acceptable (< 2 seconds)
- [ ] No memory issues
- [ ] File integrity maintained

### Test 17: Special Characters
**Objective**: Test handling of special characters in task titles

**Test Cases**:
- [ ] Task with emoji in title: `### 61. Add READMEs 📚`
- [ ] Task with special chars: `### 61. Fix A&B → C`
- [ ] Task with code: `### 61. Update \`Config.lean\``

**Expected**: All special characters preserved correctly

### Test 18: Different Status Formats
**Objective**: Test handling of various status field formats

**Test Cases**:
- [ ] `**Status**: Not Started`
- [ ] `**Status**: In Progress`
- [ ] `**Status**: [IN PROGRESS]`
- [ ] `**Status**: Complete`
- [ ] `**Status**: [COMPLETE]`
- [ ] `**Status**: Complete ✅`

**Expected**: All formats recognized and updated correctly

### Test 19: Missing Fields
**Objective**: Test handling when optional fields are missing

**Test Cases**:
- [ ] Task without Effort field
- [ ] Task without Priority field
- [ ] Task without Dependencies field
- [ ] Task with minimal fields (just title and status)

**Expected**: Status tracking works regardless of missing fields

### Test 20: Whitespace Variations
**Objective**: Test handling of different whitespace patterns

**Test Cases**:
- [ ] Extra spaces around Status field
- [ ] Tabs instead of spaces
- [ ] Multiple blank lines between fields
- [ ] No blank lines between fields

**Expected**: Whitespace preserved, status updated correctly

## Regression Tests

### Test 21: Existing Functionality
**Objective**: Verify existing task command functionality still works

**Test Cases**:
- [ ] Task extraction works
- [ ] Complexity assessment works
- [ ] Project directory creation works
- [ ] Research phase works (complex tasks)
- [ ] Planning phase works (all tasks)
- [ ] Execution phase works (simple tasks)
- [ ] Recommendations work (/lean, /implement)

**Expected**: All existing functionality unchanged

### Test 22: Subagent Coordination
**Objective**: Verify subagent routing still works

**Test Cases**:
- [ ] Researcher subagent called for complex tasks
- [ ] Planner subagent called for all tasks
- [ ] Todo-manager subagent integration (if used)

**Expected**: Subagent coordination works correctly

### Test 23: Artifact Creation
**Objective**: Verify artifacts still created correctly

**Test Cases**:
- [ ] Project directory created: `.opencode/specs/NNN_task_name/`
- [ ] Research reports created (complex tasks)
- [ ] Implementation plans created (all tasks)
- [ ] Summaries created
- [ ] state.json created

**Expected**: All artifacts created as before

## User Acceptance Tests

### Test 24: User Workflow - Documentation Update
**Scenario**: User wants to update documentation

**Steps**:
1. [ ] User runs `/task 61` (Add Missing Directory READMEs)
2. [ ] User sees status marked IN PROGRESS
3. [ ] Task executes and creates README files
4. [ ] User sees status marked COMPLETE
5. [ ] User verifies README files created correctly

**Expected**: Smooth workflow, clear status updates

### Test 25: User Workflow - Bug Fix
**Scenario**: User wants to fix a bug

**Steps**:
1. [ ] User runs `/task 52` (Fix AesopRules duplicate)
2. [ ] User sees status marked IN PROGRESS
3. [ ] User reviews implementation plan
4. [ ] User runs recommended `/implement` command
5. [ ] User verifies fix works
6. [ ] User manually marks task COMPLETE

**Expected**: Clear workflow, helpful recommendations

### Test 26: User Workflow - Feature Development
**Scenario**: User wants to develop new feature

**Steps**:
1. [ ] User runs `/task 9` (Begin Completeness Proofs)
2. [ ] User sees status marked IN PROGRESS
3. [ ] User reviews research report
4. [ ] User reviews implementation plan
5. [ ] User runs recommended `/lean` command
6. [ ] User develops proofs over multiple sessions
7. [ ] User manually marks task COMPLETE when done

**Expected**: Comprehensive research and planning, clear next steps

## Performance Tests

### Test 27: Response Time
**Objective**: Verify acceptable performance

**Metrics**:
- [ ] Status update (mark IN PROGRESS): < 1 second
- [ ] Task extraction: < 1 second
- [ ] Complexity assessment: < 1 second
- [ ] Status update (mark COMPLETE): < 1 second
- [ ] Total workflow (simple task): < 30 seconds
- [ ] Total workflow (moderate task): < 2 minutes
- [ ] Total workflow (complex task): < 5 minutes

**Expected**: All operations complete within acceptable time

### Test 28: File I/O Efficiency
**Objective**: Verify efficient file operations

**Metrics**:
- [ ] TODO.md read operations: 2 (start + complete)
- [ ] TODO.md write operations: 2 (start + complete)
- [ ] No unnecessary file reads/writes
- [ ] Atomic writes (no partial updates)

**Expected**: Minimal file I/O, atomic operations

## Security Tests

### Test 29: File Permissions
**Objective**: Verify proper file permission handling

**Test Cases**:
- [ ] TODO.md with 644 permissions (normal)
- [ ] TODO.md with 444 permissions (read-only)
- [ ] TODO.md with 600 permissions (owner only)
- [ ] TODO.md in read-only directory

**Expected**: Graceful handling of permission issues

### Test 30: Path Traversal
**Objective**: Verify no path traversal vulnerabilities

**Test Cases**:
- [ ] Task number with path chars: `/task ../../../etc/passwd`
- [ ] Task number with special chars: `/task 61; rm -rf /`

**Expected**: Input sanitized, no security issues

## Post-Testing

### Verification
- [ ] All tests passed
- [ ] No regressions found
- [ ] Performance acceptable
- [ ] Error handling robust
- [ ] User workflows smooth

### Cleanup
- [ ] Restore TODO.md from backup if needed
- [ ] Remove test tasks created during testing
- [ ] Reset file permissions
- [ ] Clear test artifacts

### Documentation
- [ ] Update test results in this document
- [ ] Document any issues found
- [ ] Create bug reports for failures
- [ ] Update user documentation if needed

## Test Results Summary

**Date Tested**: ___________  
**Tester**: ___________  
**Version**: ___________

| Test Category | Tests Passed | Tests Failed | Notes |
|---------------|--------------|--------------|-------|
| Unit Tests | __ / 5 | __ | |
| Integration Tests | __ / 5 | __ | |
| Error Handling | __ / 5 | __ | |
| Edge Cases | __ / 5 | __ | |
| Regression Tests | __ / 3 | __ | |
| User Acceptance | __ / 3 | __ | |
| Performance | __ / 2 | __ | |
| Security | __ / 2 | __ | |
| **TOTAL** | __ / 30 | __ | |

**Overall Status**: ⬜ PASS | ⬜ FAIL | ⬜ PARTIAL

**Issues Found**:
1. 
2. 
3. 

**Recommendations**:
1. 
2. 
3. 

---

**Sign-off**: ___________  
**Date**: ___________
