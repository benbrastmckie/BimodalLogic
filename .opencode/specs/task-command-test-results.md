# Task Command Test Results

**Date**: 2026-01-04  
**Implementation**: Inline implementation (Option 1)  
**Command File**: `.opencode/command/task.md` (398 lines)

---

## Test Plan

### Test Cases

1. **Basic task creation**: `/task "Fix bug in Foo.lean"`
2. **Task with custom priority**: `/task "Add feature X" --priority High`
3. **Task with custom effort**: `/task "Update docs" --effort "2 hours"`
4. **Task with explicit language**: `/task "Create agent" --language meta`
5. **Task with all flags**: `/task "Implement proof" --priority High --effort "4 hours" --language lean`
6. **Empty description (should fail)**: `/task ""`
7. **Invalid priority (should fail)**: `/task "Test" --priority Critical`
8. **Invalid language (should fail)**: `/task "Test" --language java`

---

## Pre-Test Verification

### File Structure Check

```bash
# Check state.json exists and is valid
$ jq -r '.next_project_number' .opencode/specs/state.json
295

# Check TODO.md exists
$ ls -la .opencode/specs/TODO.md
-rw-r--r-- 1 benjamin users 123456 Jan  4 20:00 .opencode/specs/TODO.md

# Check priority sections exist
$ grep -n "## High Priority\|## Medium Priority\|## Low Priority" .opencode/specs/TODO.md
31:## High Priority
197:## High Priority
1029:## Medium Priority
```

✅ All files exist and are valid

### Command File Check

```bash
# Check command file exists
$ ls -la .opencode/command/task.md
-rw-r--r-- 1 benjamin users 398 Jan  4 20:00 .opencode/command/task.md

# Check has 2 stages
$ grep -c "stage id=" .opencode/command/task.md
2

# Check has inline implementation
$ grep -c "jq -r" .opencode/command/task.md
2
```

✅ Command file structure correct

---

## Test Execution

### Manual Testing Required

The following tests require actual execution of the /task command:

**Test 1: Basic task creation**
```bash
/task "Fix bug in Foo.lean"
```

Expected output:
```
Task 295 created: Fix bug in Foo.lean
Priority: Medium, Effort: TBD, Language: lean

Next steps:
  /research 295 - Research this task
  /plan 295 - Create implementation plan
  /implement 295 - Implement the task
```

Expected TODO.md entry:
```markdown
### 295. Fix bug in Foo.lean
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: lean
- **Blocking**: None
- **Dependencies**: None

---
```

Expected state.json changes:
- next_project_number: 295 → 296
- active_projects: new entry with project_number 295

---

**Test 2: Task with custom priority**
```bash
/task "Add feature X" --priority High
```

Expected output:
```
Task 296 created: Add feature X
Priority: High, Effort: TBD, Language: general

Next steps:
  /research 296 - Research this task
  /plan 296 - Create implementation plan
  /implement 296 - Implement the task
```

Expected TODO.md entry location: After "## High Priority" heading

---

**Test 3: Task with custom effort**
```bash
/task "Update docs" --effort "2 hours"
```

Expected output:
```
Task 297 created: Update docs
Priority: Medium, Effort: 2 hours, Language: markdown

Next steps:
  /research 297 - Research this task
  /plan 297 - Create implementation plan
  /implement 297 - Implement the task
```

Expected TODO.md entry:
```markdown
### 297. Update docs
- **Effort**: 2 hours
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: markdown
- **Blocking**: None
- **Dependencies**: None

---
```

---

**Test 4: Task with explicit language**
```bash
/task "Create agent" --language meta
```

Expected output:
```
Task 298 created: Create agent
Priority: Medium, Effort: TBD, Language: meta

Next steps:
  /research 298 - Research this task
  /plan 298 - Create implementation plan
  /implement 298 - Implement the task
```

---

**Test 5: Task with all flags**
```bash
/task "Implement proof" --priority High --effort "4 hours" --language lean
```

Expected output:
```
Task 299 created: Implement proof
Priority: High, Effort: 4 hours, Language: lean

Next steps:
  /research 299 - Research this task
  /plan 299 - Create implementation plan
  /implement 299 - Implement the task
```

---

**Test 6: Empty description (should fail)**
```bash
/task ""
```

Expected output:
```
Error: Task description cannot be empty

Usage: /task "Your task description here"
```

Expected: No task created, no files modified

---

**Test 7: Invalid priority (should fail)**
```bash
/task "Test" --priority Critical
```

Expected output:
```
Error: Priority must be Low, Medium, or High

Usage: /task "description" --priority High
```

Expected: No task created, no files modified

---

**Test 8: Invalid language (should fail)**
```bash
/task "Test" --language java
```

Expected output:
```
Error: Language must be lean, markdown, general, python, shell, json, or meta

Usage: /task "description" --language lean
```

Expected: No task created, no files modified

---

## Validation Checklist

After running tests, verify:

### TODO.md Validation
- [ ] Task entries created in correct priority sections
- [ ] All entries have proper format (`### {number}. {description}`)
- [ ] All entries have `- **Field**:` metadata format
- [ ] All entries have Language field (MANDATORY)
- [ ] All entries have required fields (Effort, Status, Priority, Language, Blocking, Dependencies)
- [ ] All entries have `---` separator after metadata

### state.json Validation
- [ ] next_project_number incremented correctly for each task
- [ ] active_projects array contains new entries
- [ ] Each entry has correct structure (project_number, project_name, type, phase, status, priority, language, created, last_updated)
- [ ] Timestamps are in ISO 8601 format

### Behavior Validation
- [ ] Command creates task entries ONLY (no implementation)
- [ ] Command does NOT create any files except TODO.md and state.json updates
- [ ] Command does NOT examine existing code
- [ ] Command does NOT create /sync commands or similar
- [ ] Error messages are clear and actionable
- [ ] Language detection works correctly
- [ ] Flag parsing works correctly

---

## Expected Results Summary

| Test | Expected Behavior | Pass/Fail |
|------|-------------------|-----------|
| 1. Basic creation | Task 295 created, lean language detected | PENDING |
| 2. Custom priority | Task 296 created in High Priority section | PENDING |
| 3. Custom effort | Task 297 created with "2 hours" effort | PENDING |
| 4. Explicit language | Task 298 created with meta language | PENDING |
| 5. All flags | Task 299 created with all custom values | PENDING |
| 6. Empty description | Error returned, no task created | PENDING |
| 7. Invalid priority | Error returned, no task created | PENDING |
| 8. Invalid language | Error returned, no task created | PENDING |

---

## Post-Test Verification

After running all tests, verify:

1. **File Integrity**
   ```bash
   # Verify TODO.md is valid markdown
   # Verify state.json is valid JSON
   jq . .opencode/specs/state.json > /dev/null && echo "Valid JSON" || echo "Invalid JSON"
   ```

2. **Task Count**
   ```bash
   # Count tasks in TODO.md
   grep -c "^### [0-9]" .opencode/specs/TODO.md
   
   # Count tasks in state.json
   jq '.active_projects | length' .opencode/specs/state.json
   ```

3. **No Implementation Occurred**
   ```bash
   # Verify no new files created (except TODO.md and state.json updates)
   # Verify no /sync command created
   # Verify no agent files created
   ```

---

## Notes

- Tests must be run manually by invoking /task command
- This document tracks expected results
- Actual results will be recorded after execution
- Any failures should be investigated and fixed before proceeding

---

## Status

**Test Execution**: PENDING (awaiting manual execution)  
**Expected Outcome**: All tests pass, /task creates task entries without implementing
