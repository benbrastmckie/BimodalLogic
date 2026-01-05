# /task Command Refactor Test Plan

**Created**: 2026-01-04  
**Purpose**: Validate /task command refactor with description clarification  
**Status**: READY FOR TESTING

---

## Test Overview

This test plan validates the enhanced /task command with:
1. Description clarification via description-clarifier subagent
2. Title and description fields in TODO.md and state.json
3. Automatic metadata detection (language, priority, effort)
4. Skip clarification flag for advanced users

---

## Test Cases

### Test 1: Basic Task Creation with Clarification

**Input**:
```bash
/task "sync thing for todo and state"
```

**Expected Behavior**:
1. Stage 1: Parse rough description "sync thing for todo and state"
2. Stage 2: Invoke description-clarifier
   - Research similar tasks in TODO.md
   - Search context files for "sync", "todo", "state"
   - Generate clarified description (2-3 sentences)
   - Detect language=meta, priority=High, effort=4-6 hours
3. Stage 3: Invoke task-creator
   - Create TODO.md entry with Description field
   - Create state.json entry with description field
   - Return task number

**Expected Output**:
```
Clarified description: Create a /sync command that synchronizes TODO.md and state.json bidirectionally, ensuring both files remain consistent. The command should detect discrepancies, resolve conflicts, and update both files atomically.
Detected: Language=meta, Priority=High, Effort=4-6 hours
Confidence: high
Similar tasks: 271, 272, 285

Task 296 created: Create /sync command for TODO.md and state.json synchronization
Description: Create a /sync command that synchronizes TODO.md and state.json bidirectionally, ensuring both files remain consistent. The command should detect discrepancies, resolve conflicts, and update both files atomically.
Priority: High, Effort: 4-6 hours, Language: meta

Next steps:
  /research 296 - Research this task
  /plan 296 - Create implementation plan
  /implement 296 - Implement the task
```

**Validation**:
- [ ] TODO.md contains task entry with Description field
- [ ] state.json contains task entry with description field
- [ ] Language detected correctly (meta)
- [ ] Priority detected correctly (High)
- [ ] Effort estimated correctly (4-6 hours)
- [ ] Similar tasks identified

---

### Test 2: Task Creation with Priority Override

**Input**:
```bash
/task "fix the lean stuff" --priority High
```

**Expected Behavior**:
1. Stage 1: Parse rough description, extract --priority High
2. Stage 2: Invoke description-clarifier
   - Clarify "fix the lean stuff" to specific description
   - Detect language=lean, priority=High (from research), effort=2-4 hours
3. Stage 3: Use --priority High (user override) instead of detected priority

**Expected Output**:
```
Clarified description: Fix Lean compilation errors in the Logos/Core module by resolving type mismatches and missing imports. This will restore the build and enable further development on the proof system.
Detected: Language=lean, Priority=High, Effort=2-4 hours
Confidence: medium
Similar tasks: 250, 260, 275

Task 297 created: Fix Lean compilation errors in Logos/Core module
Description: Fix Lean compilation errors in the Logos/Core module by resolving type mismatches and missing imports. This will restore the build and enable further development on the proof system.
Priority: High, Effort: 2-4 hours, Language: lean

Next steps:
  /research 297 - Research this task
  /plan 297 - Create implementation plan
  /implement 297 - Implement the task
```

**Validation**:
- [ ] Priority is High (user override)
- [ ] Language detected correctly (lean)
- [ ] Description clarified from vague to specific
- [ ] Effort estimated correctly

---

### Test 3: Task Creation with All Flags (Skip Clarification)

**Input**:
```bash
/task "Implement proof for theorem Y" --priority High --effort "4 hours" --language lean
```

**Expected Behavior**:
1. Stage 1: Parse description, extract all flags
2. Stage 1: Detect all metadata provided, set skip_clarification=true
3. Stage 3: Skip to CreateTask (no clarification)
   - Use rough description as-is (must be 50-500 chars)
   - Use provided flags

**Expected Output**:
```
Task 298 created: Implement proof for theorem Y
Description: Implement proof for theorem Y
Priority: High, Effort: 4 hours, Language: lean

Next steps:
  /research 298 - Research this task
  /plan 298 - Create implementation plan
  /implement 298 - Implement the task
```

**Validation**:
- [ ] Clarification skipped (all flags provided)
- [ ] Description used as-is
- [ ] All flags applied correctly
- [ ] Task created successfully

---

### Test 4: Task Creation with --skip-clarification Flag

**Input**:
```bash
/task "Fix bug in Foo.lean. The issue is that the proof doesn't compile due to type mismatch in the apply tactic." --skip-clarification
```

**Expected Behavior**:
1. Stage 1: Parse description, extract --skip-clarification flag
2. Stage 3: Skip to CreateTask (no clarification)
   - Use rough description as-is (must be 50-500 chars)
   - Detect language from description (lean)
   - Use default priority (Medium)
   - Use default effort (TBD)

**Expected Output**:
```
Task 299 created: Fix bug in Foo.lean
Description: Fix bug in Foo.lean. The issue is that the proof doesn't compile due to type mismatch in the apply tactic.
Priority: Medium, Effort: TBD, Language: lean

Next steps:
  /research 299 - Research this task
  /plan 299 - Create implementation plan
  /implement 299 - Implement the task
```

**Validation**:
- [ ] Clarification skipped (--skip-clarification flag)
- [ ] Description used as-is
- [ ] Language detected from description (lean)
- [ ] Default priority (Medium) used
- [ ] Default effort (TBD) used

---

### Test 5: Error Handling - Empty Description

**Input**:
```bash
/task ""
```

**Expected Behavior**:
1. Stage 1: Validate description is non-empty
2. Return error

**Expected Output**:
```
Error: Task description cannot be empty

Usage: /task "Your task description here"
```

**Validation**:
- [ ] Error message clear and actionable
- [ ] No task created
- [ ] Usage example provided

---

### Test 6: Error Handling - Description Too Short (with --skip-clarification)

**Input**:
```bash
/task "Fix bug" --skip-clarification
```

**Expected Behavior**:
1. Stage 1: Parse description "Fix bug"
2. Stage 3: Validate description length (< 50 chars)
3. Return error

**Expected Output**:
```
Error: Description too short (minimum 50 characters)

Suggestion: Provide more details or let description-clarifier expand it
```

**Validation**:
- [ ] Error message clear and actionable
- [ ] No task created
- [ ] Suggestion provided

---

### Test 7: Error Handling - Invalid Priority

**Input**:
```bash
/task "Implement feature X" --priority Critical
```

**Expected Behavior**:
1. Stage 1: Validate priority value
2. Return error

**Expected Output**:
```
Error: Priority must be Low, Medium, or High

Usage: /task "description" --priority High
```

**Validation**:
- [ ] Error message clear and actionable
- [ ] No task created
- [ ] Valid values listed

---

### Test 8: Error Handling - Invalid Language

**Input**:
```bash
/task "Implement feature X" --language rust
```

**Expected Behavior**:
1. Stage 1: Validate language value
2. Return error

**Expected Output**:
```
Error: Language must be lean, markdown, general, python, shell, json, or meta

Usage: /task "description" --language lean
```

**Validation**:
- [ ] Error message clear and actionable
- [ ] No task created
- [ ] Valid values listed

---

### Test 9: Metadata Detection - Lean Task

**Input**:
```bash
/task "add leansearch api integration"
```

**Expected Behavior**:
1. Stage 2: description-clarifier detects language=lean from keywords
2. Stage 2: description-clarifier estimates priority=Medium (feature)
3. Stage 2: description-clarifier estimates effort=6-8 hours (API integration)

**Expected Output**:
```
Clarified description: Integrate LeanSearch REST API for theorem search functionality, enabling automated proof search using the LeanSearch service. This will enhance the proof automation capabilities by providing access to Mathlib theorems and tactics.
Detected: Language=lean, Priority=Medium, Effort=6-8 hours
Confidence: high
Similar tasks: 280, 285

Task 300 created: Integrate LeanSearch REST API for theorem search
Description: Integrate LeanSearch REST API for theorem search functionality, enabling automated proof search using the LeanSearch service. This will enhance the proof automation capabilities by providing access to Mathlib theorems and tactics.
Priority: Medium, Effort: 6-8 hours, Language: lean

Next steps:
  /research 300 - Research this task
  /plan 300 - Create implementation plan
  /implement 300 - Implement the task
```

**Validation**:
- [ ] Language detected correctly (lean)
- [ ] Priority estimated correctly (Medium)
- [ ] Effort estimated correctly (6-8 hours)
- [ ] Description clarified and expanded

---

### Test 10: Metadata Detection - Meta Task

**Input**:
```bash
/task "create new agent for code review"
```

**Expected Behavior**:
1. Stage 2: description-clarifier detects language=meta from keywords
2. Stage 2: description-clarifier estimates priority=Medium (feature)
3. Stage 2: description-clarifier estimates effort=4-6 hours (agent creation)

**Expected Output**:
```
Clarified description: Create a new code-review agent that analyzes code quality, identifies issues, and suggests improvements. This agent will integrate with the /review command to provide automated code review capabilities.
Detected: Language=meta, Priority=Medium, Effort=4-6 hours
Confidence: high
Similar tasks: 270, 275, 280

Task 301 created: Create code-review agent
Description: Create a new code-review agent that analyzes code quality, identifies issues, and suggests improvements. This agent will integrate with the /review command to provide automated code review capabilities.
Priority: Medium, Effort: 4-6 hours, Language: meta

Next steps:
  /research 301 - Research this task
  /plan 301 - Create implementation plan
  /implement 301 - Implement the task
```

**Validation**:
- [ ] Language detected correctly (meta)
- [ ] Priority estimated correctly (Medium)
- [ ] Effort estimated correctly (4-6 hours)
- [ ] Description clarified and expanded

---

## Integration Tests

### Integration Test 1: TODO.md Format

**Test**: Verify TODO.md entry format after task creation

**Expected Format**:
```markdown
### 296. Create /sync command for TODO.md and state.json synchronization
- **Effort**: 4-6 hours
- **Status**: [NOT STARTED]
- **Priority**: High
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

**Description**: Create a /sync command that synchronizes TODO.md and state.json bidirectionally, ensuring both files remain consistent. The command should detect discrepancies, resolve conflicts, and update both files atomically.

---
```

**Validation**:
- [ ] Heading format correct (### {number}. {title})
- [ ] Metadata format correct (- **Field**: value)
- [ ] Description field present
- [ ] Description on separate line after metadata
- [ ] Separator (---) present

---

### Integration Test 2: state.json Format

**Test**: Verify state.json entry format after task creation

**Expected Format**:
```json
{
  "project_number": 296,
  "project_name": "create_sync_command_for_todo_md_and_state_json_synchronization",
  "type": "feature",
  "phase": "not_started",
  "status": "not_started",
  "priority": "high",
  "language": "meta",
  "description": "Create a /sync command that synchronizes TODO.md and state.json bidirectionally, ensuring both files remain consistent. The command should detect discrepancies, resolve conflicts, and update both files atomically.",
  "created": "2026-01-04T20:00:00Z",
  "last_updated": "2026-01-04T20:00:00Z"
}
```

**Validation**:
- [ ] project_number correct
- [ ] project_name is slug from title
- [ ] description field present
- [ ] description matches TODO.md
- [ ] language field present
- [ ] priority field present (lowercase)
- [ ] timestamps present

---

### Integration Test 3: Atomic Updates

**Test**: Verify both TODO.md and state.json updated atomically

**Procedure**:
1. Create task with /task command
2. Verify TODO.md contains new entry
3. Verify state.json contains new entry
4. Verify next_project_number incremented

**Validation**:
- [ ] Both files updated
- [ ] Task number consistent across files
- [ ] next_project_number incremented by 1
- [ ] No partial updates

---

## Performance Tests

### Performance Test 1: Clarification Speed

**Test**: Measure time for description clarification

**Procedure**:
1. Run /task with rough description
2. Measure time from invocation to completion

**Expected**:
- Clarification completes in < 30 seconds
- Total task creation completes in < 60 seconds

**Validation**:
- [ ] Clarification fast enough for interactive use
- [ ] No timeout errors

---

### Performance Test 2: Skip Clarification Speed

**Test**: Measure time for task creation with --skip-clarification

**Procedure**:
1. Run /task with --skip-clarification flag
2. Measure time from invocation to completion

**Expected**:
- Task creation completes in < 5 seconds

**Validation**:
- [ ] Skip clarification significantly faster
- [ ] No performance regression

---

## Success Criteria

- ✅ All test cases pass (10/10)
- ✅ All integration tests pass (3/3)
- ✅ All performance tests pass (2/2)
- ✅ Error handling works correctly
- ✅ Metadata detection accuracy >80%
- ✅ Description field in 100% of new tasks
- ✅ Atomic updates work 100% of the time

---

## Test Execution Log

| Test | Status | Notes |
|------|--------|-------|
| Test 1: Basic Task Creation | ⏳ Pending | |
| Test 2: Priority Override | ⏳ Pending | |
| Test 3: All Flags (Skip) | ⏳ Pending | |
| Test 4: Skip Clarification Flag | ⏳ Pending | |
| Test 5: Empty Description Error | ⏳ Pending | |
| Test 6: Description Too Short Error | ⏳ Pending | |
| Test 7: Invalid Priority Error | ⏳ Pending | |
| Test 8: Invalid Language Error | ⏳ Pending | |
| Test 9: Lean Task Detection | ⏳ Pending | |
| Test 10: Meta Task Detection | ⏳ Pending | |
| Integration Test 1: TODO.md Format | ⏳ Pending | |
| Integration Test 2: state.json Format | ⏳ Pending | |
| Integration Test 3: Atomic Updates | ⏳ Pending | |
| Performance Test 1: Clarification Speed | ⏳ Pending | |
| Performance Test 2: Skip Clarification Speed | ⏳ Pending | |

---

## Notes

- Tests should be run in order
- Each test should be independent (no dependencies on previous tests)
- Clean up test tasks after validation
- Document any issues or unexpected behavior
- Update test plan if new edge cases discovered

---

**End of Test Plan**
