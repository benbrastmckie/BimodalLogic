# Phase 7: Integration Testing Results - Task 169

**Date**: 2025-12-24
**Phase**: 7 of 8
**Status**: READY FOR TESTING
**Version**: v3 (Clean Break with /task → /implement rename)

## Overview

This document defines comprehensive test scenarios for validating all changes implemented in Task 169 (context window protection for /implement command). Testing covers single/batch execution, simple/complex task paths, artifact-first returns, summary enforcement, git commit patterns, and the complete /task → /implement rename.

## Test Scenario Definitions

### Scenario 1: Single Simple Task via /implement (No Plan Path)

**Objective**: Validate simple task execution with direct implementation, single commit, and brief summary return.

**Setup**:
- Create test task in TODO.md:
  ```markdown
  ### 999. Test Simple Task - Add Comment to File
  - **Status**: [NOT STARTED]
  - **Effort**: 0.5 hours
  - **Priority**: Low
  - **Description**: Add a comment to README.md explaining project purpose
  - **Files**: README.md
  - **Dependencies**: None
  ```

**Execution**:
```
/implement 999
```

**Expected Complexity Assessment**:
- Effort: <2h → 0 points
- Files: 1 → 0 points
- LOC: <100 → 0 points
- Dependencies: 0 → 0 points
- Research: No → 0 points
- Unknowns: Clear → 0 points
- Risk: Low → 0 points
- **Total**: 0 points → **SIMPLE** classification

**Expected Workflow**:
1. Stage 1 (ParseInput): Single task detected, continue with single-task flow
2. Stage 2 (ResolveTasks): Load task 999, set TODO status to [IN PROGRESS] with Started date
3. Stage 2.5 (AssessComplexity): Calculate score=0, classify as SIMPLE
4. Stage 3 (Execute): Route to implementer with complexity=simple flag
   - Direct execution (no research/plan phases)
   - Modify README.md with comment
   - Create implementation summary artifact
5. Stage 4 (Postflight): 
   - Single git commit: "Implement task 999: Add comment to file"
   - Update TODO status to [COMPLETED] with Completed date
   - Sync state.json
   - Return artifact-first format

**Expected Return Format**:
```json
{
  "task_number": 999,
  "status": "completed",
  "summary": "Added explanatory comment to README.md describing project purpose. Simple modification with no dependencies or complexity.",
  "artifacts": [
    {
      "type": "implementation_summary",
      "path": "specs/999_test_simple_task/summaries/implementation-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "complexity": "simple",
    "effort_hours": 0.5,
    "files_modified": 1,
    "commits": 1
  }
}
```

**Validation Criteria**:
- [ ] Token count <500 tokens (measured)
- [ ] Summary is 3-5 sentences
- [ ] Summary artifact created at expected path
- [ ] Single git commit created
- [ ] Commit message follows pattern: "Implement task 999: {title}"
- [ ] TODO status updated to [COMPLETED]
- [ ] state.json updated with completed status
- [ ] No research or plan artifacts created
- [ ] Return format matches schema
- [ ] All user-facing messages use /implement terminology

**Token Count Measurement**:
```
Estimated tokens = (JSON string length) ÷ 3
Target: <500 tokens
Actual: [TO BE MEASURED]
```

---

### Scenario 2: Single Complex Task via /implement (Multi-Phase Plan)

**Objective**: Validate complex task execution with research → plan → implement phases, commit per phase, and structured summary.

**Setup**:
- Create test task in TODO.md:
  ```markdown
  ### 998. Test Complex Task - Implement New Validation System
  - **Status**: [NOT STARTED]
  - **Effort**: 6 hours
  - **Priority**: High
  - **Description**: Design and implement comprehensive validation system for artifact returns with token counting, field validation, and error handling
  - **Files**: task-executor.md, batch-task-orchestrator.md, validation-utils.md (new)
  - **Dependencies**: Task 997 (validation schema)
  - **Impact**: Critical for context window protection
  ```

**Execution**:
```
/implement 998
```

**Expected Complexity Assessment**:
- Effort: >4h → 2 points
- Files: 3 → 1 point
- LOC: >500 → 2 points
- Dependencies: 1 → 1 point
- Research: Extensive → 2 points
- Unknowns: Some → 1 point
- Risk: High → 2 points
- **Total**: 11 points → **COMPLEX** classification

**Expected Workflow**:
1. Stage 1-2: Parse input, load task, set [IN PROGRESS]
2. Stage 2.5: Calculate score=11, classify as COMPLEX
3. Stage 3 (Execute): Route to task-executor with complexity=complex flag
   - **Phase 1 - Research**: 
     - Create research-001.md
     - Create summaries/research-summary.md
     - Git commit: "Complete research phase of task 998: Validation system design"
   - **Phase 2 - Planning**:
     - Create plans/implementation-001.md
     - Create summaries/plan-summary.md
     - Git commit: "Complete planning phase of task 998: Validation implementation plan"
   - **Phase 3 - Implementation Phase 1**:
     - Implement validation in task-executor.md
     - Git commit: "Complete phase 1 of task 998: Task executor validation"
   - **Phase 4 - Implementation Phase 2**:
     - Implement validation in batch-task-orchestrator.md
     - Git commit: "Complete phase 2 of task 998: Batch orchestrator validation"
   - **Phase 5 - Implementation Phase 3**:
     - Create validation-utils.md
     - Create summaries/implementation-summary-20251224.md
     - Git commit: "Complete phase 3 of task 998: Validation utilities"
4. Stage 4 (Postflight):
   - Update TODO to [COMPLETED]
   - Update plan phases to [COMPLETED]
   - Sync state.json
   - Return artifact-first format

**Expected Return Format**:
```json
{
  "task_number": 998,
  "status": "completed",
  "summary": "Implemented comprehensive validation system across task-executor and batch-task-orchestrator with token counting, field validation, and error handling. Created reusable validation utilities and comprehensive test coverage.",
  "artifacts": [
    {
      "type": "research",
      "path": "specs/998_test_complex_task/reports/research-001.md"
    },
    {
      "type": "research_summary",
      "path": "specs/998_test_complex_task/summaries/research-summary.md"
    },
    {
      "type": "plan",
      "path": "specs/998_test_complex_task/plans/implementation-001.md"
    },
    {
      "type": "plan_summary",
      "path": "specs/998_test_complex_task/summaries/plan-summary.md"
    },
    {
      "type": "implementation_summary",
      "path": "specs/998_test_complex_task/summaries/implementation-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "complexity": "complex",
    "effort_hours": 6,
    "files_modified": 3,
    "commits": 5,
    "phases_completed": 5
  }
}
```

**Validation Criteria**:
- [ ] Token count <500 tokens (measured)
- [ ] Summary is 3-5 sentences
- [ ] All summary artifacts created (research, plan, implementation)
- [ ] 5 git commits created (one per phase)
- [ ] Commit messages follow pattern: "Complete phase N of task 998: {phase_name}"
- [ ] TODO status updated to [COMPLETED]
- [ ] Plan phases all marked [COMPLETED]
- [ ] state.json updated with all phases
- [ ] Return format matches schema
- [ ] All user-facing messages use /implement terminology

**Token Count Measurement**:
```
Estimated tokens = (JSON string length) ÷ 3
Target: <500 tokens
Actual: [TO BE MEASURED]
```

---

### Scenario 3: Batch of 10 Tasks via /implement (Mixed Complexity)

**Objective**: Validate batch execution with wave processing, progressive summarization, and aggregated brief summaries.

**Setup**:
- Create 10 test tasks in TODO.md:
  - Tasks 990-994: Simple tasks (5 tasks, score 0-4 each)
  - Tasks 995-997: Moderate tasks (3 tasks, score 5-9 each)
  - Tasks 998-999: Complex tasks (2 tasks, score 10-14 each)

**Execution**:
```
/implement 990-999
```

**Expected Workflow**:
1. Stage 1 (ParseInput): Range detected, normalize to [990,991,992,993,994,995,996,997,998,999], classify as batch
2. Stage 2 (ResolveTasks): Load all 10 tasks, set all to [IN PROGRESS]
3. Stage 2.5 (AssessComplexity): Calculate complexity for each task
4. Stage 3 (Execute): Route to batch-task-orchestrator
   - **Wave 1**: Execute independent tasks in parallel (e.g., 990, 991, 995)
   - **Wave 2**: Execute tasks dependent on Wave 1 (e.g., 992, 996)
   - **Wave 3**: Execute remaining tasks (e.g., 993, 994, 997, 998, 999)
   - Each task executed by task-executor with appropriate complexity flag
   - Progressive summarization: per-task → per-wave → batch
5. Stage 4 (Postflight):
   - Update all TODO statuses
   - Create batch summary artifact
   - Return aggregated format

**Expected Return Format**:
```json
{
  "total_tasks": 10,
  "completed": 10,
  "failed": 0,
  "blocked": 0,
  "batch_summary": "Successfully completed 10 tasks across 3 execution waves with mixed complexity. All simple tasks executed directly, moderate/complex tasks followed full workflow.",
  "task_summaries": [
    {
      "task_number": 990,
      "status": "completed",
      "summary": "Simple file modification completed",
      "artifacts": ["specs/990_*/summaries/implementation-summary-*.md"]
    },
    {
      "task_number": 991,
      "status": "completed",
      "summary": "Documentation update completed",
      "artifacts": ["specs/991_*/summaries/implementation-summary-*.md"]
    }
    // ... 8 more task summaries (one-line each)
  ],
  "artifacts": [
    {
      "type": "batch_summary",
      "path": "specs/batch_990-999/summaries/batch-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "total_effort_hours": 25,
    "total_files_modified": 18,
    "total_commits": 23,
    "execution_waves": 3,
    "simple_tasks": 5,
    "moderate_tasks": 3,
    "complex_tasks": 2
  }
}
```

**Validation Criteria**:
- [ ] Line count <50 lines per 10 tasks (measured: target <50 lines total)
- [ ] Batch summary is 2-3 sentences, <75 tokens
- [ ] Each task summary is single sentence, <150 characters
- [ ] All 10 tasks accounted for (completed + failed + blocked = 10)
- [ ] Batch summary artifact created
- [ ] Progressive summarization applied (not full task details)
- [ ] All TODO statuses updated
- [ ] state.json updated for all tasks
- [ ] Return format matches schema
- [ ] All user-facing messages use /implement terminology

**Line Count Measurement**:
```
Line count = (formatted JSON output line count)
Target: <50 lines for 10 tasks
Actual: [TO BE MEASURED]
```

---

### Scenario 4: Task with Existing Plan Link via /implement

**Objective**: Validate plan reuse, in-place updates, and phase-based commits when plan already exists.

**Setup**:
- Create test task in TODO.md with plan link:
  ```markdown
  ### 997. Test Plan Reuse - Extend Validation System
  - **Status**: [NOT STARTED]
  - **Effort**: 4 hours
  - **Priority**: Medium
  - **Plan**: specs/997_test_plan_reuse/plans/implementation-001.md
  - **Description**: Extend existing validation system with new rules
  - **Files**: validation-utils.md, task-executor.md
  ```
- Create existing plan at specified path with phases:
  - Phase 1: Add new validation rules [NOT STARTED]
  - Phase 2: Update task-executor integration [NOT STARTED]
  - Phase 3: Test and document [NOT STARTED]

**Execution**:
```
/implement 997
```

**Expected Workflow**:
1. Detect existing plan link in TODO
2. Load plan from specified path
3. Reuse plan (no new plan creation)
4. Execute phases in order:
   - Phase 1: Update validation-utils.md, set phase to [COMPLETED], commit
   - Phase 2: Update task-executor.md, set phase to [COMPLETED], commit
   - Phase 3: Create tests and docs, set phase to [COMPLETED], commit
5. Update plan header to [COMPLETED]
6. Update TODO to [COMPLETED]
7. Return artifact-first format

**Expected Return Format**:
```json
{
  "task_number": 997,
  "status": "completed",
  "summary": "Extended validation system with new rules and updated task-executor integration. Reused existing plan with 3 phases, all completed successfully.",
  "artifacts": [
    {
      "type": "plan",
      "path": "specs/997_test_plan_reuse/plans/implementation-001.md"
    },
    {
      "type": "implementation_summary",
      "path": "specs/997_test_plan_reuse/summaries/implementation-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "complexity": "moderate",
    "effort_hours": 4,
    "files_modified": 2,
    "commits": 3,
    "phases_completed": 3,
    "plan_reused": true
  }
}
```

**Validation Criteria**:
- [ ] Existing plan reused (not recreated)
- [ ] Plan updated in place (phases marked [COMPLETED])
- [ ] 3 commits created (one per phase)
- [ ] No new plan created
- [ ] Plan header updated to [COMPLETED]
- [ ] TODO updated to [COMPLETED]
- [ ] Return format includes plan_reused flag
- [ ] All user-facing messages use /implement terminology

---

### Scenario 5: Task without Plan Link via /implement (Direct Execution)

**Objective**: Validate direct execution without plan creation for moderate-complexity tasks without plan links.

**Setup**:
- Create test task in TODO.md without plan link:
  ```markdown
  ### 996. Test Direct Execution - Update Documentation
  - **Status**: [NOT STARTED]
  - **Effort**: 2 hours
  - **Priority**: Medium
  - **Description**: Update user guide with new /implement command examples
  - **Files**: docs/user-guide/TUTORIAL.md, docs/user-guide/EXAMPLES.md
  - **Dependencies**: None
  ```

**Execution**:
```
/implement 996
```

**Expected Complexity Assessment**:
- Effort: 2-4h → 1 point
- Files: 2 → 0 points
- LOC: 100-500 → 1 point
- Dependencies: 0 → 0 points
- Research: No → 0 points
- Unknowns: Clear → 0 points
- Risk: Low → 0 points
- **Total**: 2 points → **SIMPLE** classification

**Expected Workflow**:
1. No plan link in TODO
2. Complexity=simple → direct execution path
3. Update both documentation files
4. Create implementation summary
5. Single commit
6. Update TODO to [COMPLETED]

**Expected Return Format**:
```json
{
  "task_number": 996,
  "status": "completed",
  "summary": "Updated user guide and examples with /implement command usage. Direct execution without plan creation.",
  "artifacts": [
    {
      "type": "implementation_summary",
      "path": "specs/996_test_direct_execution/summaries/implementation-summary-20251224.md"
    }
  ],
  "key_metrics": {
    "complexity": "simple",
    "effort_hours": 2,
    "files_modified": 2,
    "commits": 1,
    "plan_created": false
  }
}
```

**Validation Criteria**:
- [ ] No plan created
- [ ] No research created
- [ ] Direct execution path taken
- [ ] Single commit created
- [ ] Implementation summary created
- [ ] TODO updated to [COMPLETED]
- [ ] Return format includes plan_created=false flag
- [ ] All user-facing messages use /implement terminology

---

### Scenario 6: Error Handling (Failed, Blocked, Missing Artifacts)

**Objective**: Validate error handling for various failure modes.

#### Scenario 6a: Failed Task Execution

**Setup**:
- Create task that will fail (e.g., modify non-existent file)

**Expected Behavior**:
- Task marked [FAILED] in TODO
- Error details in return format
- Recommendation for fix
- No partial artifacts created
- state.json updated with failure status

**Expected Return Format**:
```json
{
  "task_number": 995,
  "status": "failed",
  "summary": "Task execution failed due to missing file dependency.",
  "error": {
    "type": "file_not_found",
    "message": "Required file 'missing.md' not found",
    "recommendation": "Create missing.md or update task dependencies"
  },
  "artifacts": [],
  "key_metrics": {
    "complexity": "simple",
    "effort_hours": 0,
    "files_modified": 0,
    "commits": 0
  }
}
```

#### Scenario 6b: Blocked Task (Dependency Not Met)

**Setup**:
- Create task 994 with dependency on task 993
- Task 993 is [NOT STARTED]

**Expected Behavior**:
- Task 994 marked [BLOCKED] in TODO
- Blocking task identified in return
- Recommendation to complete dependency first
- No execution attempted

**Expected Return Format**:
```json
{
  "task_number": 994,
  "status": "blocked",
  "summary": "Task blocked by incomplete dependency.",
  "blocking_tasks": [993],
  "recommendation": "Complete task 993 first, then run /implement 994",
  "artifacts": [],
  "key_metrics": {
    "complexity": "unknown",
    "effort_hours": 0,
    "files_modified": 0,
    "commits": 0
  }
}
```

#### Scenario 6c: Missing Summary Artifact (Validation Failure)

**Setup**:
- Simulate task execution that creates detailed artifact without summary

**Expected Behavior**:
- Validation catches missing summary
- Automatic correction: create summary from detailed artifact
- Retry validation
- If still fails, return validation error

**Expected Return Format** (after correction):
```json
{
  "task_number": 993,
  "status": "completed",
  "summary": "Task completed with automatic summary generation after validation correction.",
  "artifacts": [
    {
      "type": "implementation",
      "path": "specs/993_*/reports/implementation-001.md"
    },
    {
      "type": "implementation_summary",
      "path": "specs/993_*/summaries/implementation-summary-20251224.md"
    }
  ],
  "validation_warnings": [
    "Summary artifact was missing and automatically generated"
  ],
  "key_metrics": {
    "complexity": "moderate",
    "effort_hours": 3,
    "files_modified": 2,
    "commits": 2
  }
}
```

**Validation Criteria**:
- [ ] Failed tasks marked [FAILED] with error details
- [ ] Blocked tasks marked [BLOCKED] with blocking task IDs
- [ ] Missing summaries automatically corrected
- [ ] Validation errors logged with actionable messages
- [ ] No partial artifacts left behind on failure
- [ ] state.json reflects failure/blocked status
- [ ] All error messages use /implement terminology

---

### Scenario 7: All Updated Consuming Commands Work with New Formats

**Objective**: Validate all commands that consume task-executor/batch-task-orchestrator outputs work correctly.

**Commands to Test**:
1. `/implement` - Primary command (already tested in scenarios 1-6)
2. `/optimize` - May coordinate batch operations
3. `/meta` - May reference task execution
4. Any other commands identified in consumers-audit.md

**Test Process**:
For each consuming command:
1. Identify how it consumes task-executor/batch-task-orchestrator outputs
2. Execute command with test scenario
3. Verify it handles new return format correctly
4. Verify it doesn't reference removed fields (coordinator_results, workflow_executed, todo_status_tracking)
5. Verify it uses new fields (artifacts, summary, key_metrics)

**Validation Criteria**:
- [ ] All consuming commands execute without errors
- [ ] No references to removed fields in any command
- [ ] All commands handle artifacts array correctly
- [ ] All commands display summaries appropriately
- [ ] All commands use /implement terminology (not /task)

---

### Scenario 8: All /task → /implement Renames Work Correctly

**Objective**: Validate complete /task → /implement rename with no broken references.

**Test Process**:

#### 8a: Command File Rename
```bash
# Verify task.md no longer exists
ls -la .opencode/command/task.md
# Expected: File not found

# Verify implement.md exists
ls -la .opencode/command/implement.md
# Expected: File exists

# Verify implement.md header uses /implement
grep "^name: implement" .opencode/command/implement.md
# Expected: Match found
```

#### 8b: Command Invocation
```bash
# Test /implement command works
/implement 999

# Test /task command fails with helpful message
/task 999
# Expected: "Command /task not found. Did you mean /implement?"
```

#### 8c: Reference Audit
```bash
# Search for remaining /task references (excluding archives and task 169 specs)
grep -rn "/task" .opencode/ --include="*.md" | grep -v "specs/archive" | grep -v "169_task_command_improvements" | grep -v "</task>"
# Expected: 0 results (or only XML closing tags)

# Search for /implement references
grep -rn "/implement" .opencode/ --include="*.md" | wc -l
# Expected: 259+ references (same count as original /task references)
```

#### 8d: Documentation Consistency
```bash
# Check README.md uses /implement
grep "/implement" .opencode/README.md
# Expected: Multiple matches

# Check QUICK-START.md uses /implement
grep "/implement" .opencode/QUICK-START.md
# Expected: At least one match

# Check SYSTEM_SUMMARY.md uses /implement
grep "/implement" .opencode/SYSTEM_SUMMARY.md
# Expected: Multiple matches
```

#### 8e: Agent Routing
```bash
# Check orchestrator.md routes /implement correctly
grep -A 2 'Triggers: "/implement' .opencode/agent/orchestrator.md
# Expected: Routes to task-executor

# Check task-executor.md references /implement
grep "/implement" .opencode/agent/subagents/task-executor.md
# Expected: Multiple matches in examples and documentation
```

**Validation Criteria**:
- [ ] task.md file removed
- [ ] implement.md file exists with correct header
- [ ] /implement command invocation works
- [ ] /task command fails with helpful error
- [ ] No /task references remain (except archives and XML tags)
- [ ] All /implement references functional
- [ ] Documentation uses /implement consistently
- [ ] Agent routing works with /implement
- [ ] No broken links or references
- [ ] Error messages use /implement terminology

---

## Expected Outcomes Summary

### Token/Line Count Measurements

| Scenario | Metric | Target | Measurement Method |
|----------|--------|--------|-------------------|
| Single Simple Task | Token count | <500 tokens | (JSON string length) ÷ 3 |
| Single Complex Task | Token count | <500 tokens | (JSON string length) ÷ 3 |
| Batch 10 Tasks | Line count | <50 lines | Formatted JSON line count |
| All Scenarios | Summary length | 3-5 sentences | Sentence count |
| Batch Summary | Batch summary | 2-3 sentences, <75 tokens | Sentence count + token estimate |
| Batch Task Summaries | Task summary | <150 characters | Character count |

### Artifact Creation Patterns

| Task Complexity | Artifacts Created | Summary Required |
|----------------|-------------------|------------------|
| Simple | implementation_summary | Yes |
| Moderate (no plan) | implementation_summary | Yes |
| Moderate (with plan) | plan, implementation_summary | Yes (both) |
| Complex | research, research_summary, plan, plan_summary, implementation_summary | Yes (all) |
| Batch | batch_summary, per-task summaries | Yes (all) |

### Git Commit Patterns

| Task Complexity | Commit Count | Commit Message Pattern |
|----------------|--------------|------------------------|
| Simple | 1 | "Implement task NNN: {title}" |
| Moderate (no plan) | 1 | "Implement task NNN: {title}" |
| Moderate (with plan) | N (per phase) | "Complete phase N of task NNN: {phase_name}" |
| Complex | N (per phase) | "Complete phase N of task NNN: {phase_name}" |
| Batch | Sum of individual | Individual patterns per task |

### Return Format Compliance

All scenarios must return JSON matching this schema:

```json
{
  "task_number": "integer",
  "status": "completed | failed | blocked",
  "summary": "string (3-5 sentences)",
  "artifacts": [
    {
      "type": "string",
      "path": "string (relative from project root)"
    }
  ],
  "key_metrics": {
    "complexity": "simple | moderate | complex",
    "effort_hours": "number",
    "files_modified": "integer",
    "commits": "integer"
  }
}
```

Batch returns must match:

```json
{
  "total_tasks": "integer",
  "completed": "integer",
  "failed": "integer",
  "blocked": "integer",
  "batch_summary": "string (2-3 sentences)",
  "task_summaries": [
    {
      "task_number": "integer",
      "status": "string",
      "summary": "string (single sentence)",
      "artifacts": ["array of paths"]
    }
  ],
  "artifacts": [
    {
      "type": "batch_summary",
      "path": "string"
    }
  ],
  "key_metrics": {
    "total_effort_hours": "number",
    "total_files_modified": "integer",
    "total_commits": "integer",
    "execution_waves": "integer"
  }
}
```

---

## Validation Checklist

### Context Window Targets

- [ ] Single task returns <500 tokens (measured, not estimated)
- [ ] Batch returns <50 lines per 10 tasks (measured, not estimated)
- [ ] Summary artifacts are 3-5 sentences (50-100 tokens)
- [ ] Batch summaries are 2-3 sentences (<75 tokens)
- [ ] Task one-line summaries are <150 characters
- [ ] Token counting methodology documented and repeatable
- [ ] Line counting methodology documented and repeatable

### No Regressions in Task Execution Workflows

- [ ] Simple tasks execute correctly (direct path)
- [ ] Complex tasks execute correctly (full workflow)
- [ ] Batch tasks execute correctly (wave-based)
- [ ] Plan reuse works correctly
- [ ] Direct execution (no plan) works correctly
- [ ] Error handling works correctly (failed, blocked, validation)
- [ ] Git commits follow correct patterns
- [ ] TODO status updates work correctly
- [ ] state.json updates work correctly
- [ ] Plan phase updates work correctly

### All User-Facing Messages Use /implement Terminology

- [ ] Command invocation uses /implement
- [ ] Error messages reference /implement
- [ ] Help text uses /implement
- [ ] Documentation examples use /implement
- [ ] Agent routing messages use /implement
- [ ] Validation error messages use /implement
- [ ] Recommendation messages use /implement
- [ ] No /task references in user-facing text

### All Validation Rules Enforced

- [ ] Required fields validated (task_number, status, summary, artifacts, key_metrics)
- [ ] Token count validation enforced (<500 tokens)
- [ ] Line count validation enforced (<50 lines per 10 tasks)
- [ ] Summary validation enforced (3-5 sentences, <100 tokens)
- [ ] Artifact validation enforced (paths exist, files present)
- [ ] Summary artifact requirement enforced (when detailed artifacts created)
- [ ] Task accounting validation enforced (completed + failed + blocked = total)
- [ ] Validation failures logged with actionable messages
- [ ] Automatic correction attempted before failure
- [ ] Retry logic works correctly

---

## Test Results

### Scenario 1: Single Simple Task
- **Status**: [NOT TESTED]
- **Token Count**: [TO BE MEASURED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

### Scenario 2: Single Complex Task
- **Status**: [NOT TESTED]
- **Token Count**: [TO BE MEASURED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

### Scenario 3: Batch of 10 Tasks
- **Status**: [NOT TESTED]
- **Line Count**: [TO BE MEASURED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

### Scenario 4: Task with Existing Plan
- **Status**: [NOT TESTED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

### Scenario 5: Task without Plan Link
- **Status**: [NOT TESTED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

### Scenario 6: Error Handling
- **6a - Failed Task**: [NOT TESTED]
- **6b - Blocked Task**: [NOT TESTED]
- **6c - Missing Artifacts**: [NOT TESTED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

### Scenario 7: Consuming Commands
- **Status**: [NOT TESTED]
- **Commands Tested**: [TO BE DOCUMENTED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

### Scenario 8: /task → /implement Rename
- **8a - Command File Rename**: [NOT TESTED]
- **8b - Command Invocation**: [NOT TESTED]
- **8c - Reference Audit**: [NOT TESTED]
- **8d - Documentation Consistency**: [NOT TESTED]
- **8e - Agent Routing**: [NOT TESTED]
- **Issues Found**: [TO BE DOCUMENTED]
- **Pass/Fail**: [TO BE DETERMINED]

---

## Key Findings

### Test Coverage

This test plan provides comprehensive coverage of:
- **Execution Paths**: Single simple, single complex, batch mixed, plan reuse, direct execution
- **Return Formats**: Artifact-first, progressive summarization, token/line limits
- **Git Patterns**: Single commit (simple), phase commits (complex), batch aggregation
- **Error Handling**: Failed tasks, blocked tasks, validation failures, automatic correction
- **Rename Validation**: Command files, invocation, references, documentation, routing
- **Integration**: All consuming commands, all workflow paths, all validation rules

### Validation Approach

Testing uses a **multi-layered validation approach**:
1. **Structural Validation**: JSON schema compliance, required fields present
2. **Quantitative Validation**: Token counts, line counts, character limits (measured)
3. **Qualitative Validation**: Summary quality, error message clarity, user experience
4. **Functional Validation**: Workflows execute correctly, artifacts created, status updated
5. **Integration Validation**: Consuming commands work, routing correct, no regressions
6. **Rename Validation**: No broken references, consistent terminology, functional commands

### Measurement Methodology

**Token Counting**:
```
tokens = (JSON string length) ÷ 3
```
This is a conservative estimate (actual tokens may be slightly lower). Validation uses this formula consistently.

**Line Counting**:
```
lines = (formatted JSON output line count)
```
Count actual newlines in formatted output, not minified JSON.

**Character Counting**:
```
characters = string.length
```
Count actual characters in summary strings.

### Risk Areas

**High Risk**:
- Batch execution with 10+ tasks (complexity of wave coordination)
- /task → /implement rename completeness (259+ references)
- Validation enforcement (automatic correction logic)

**Medium Risk**:
- Complex task workflow (multi-phase coordination)
- Error handling edge cases (partial failures, validation retries)
- Consuming command integration (format changes)

**Low Risk**:
- Simple task execution (straightforward path)
- Token/line counting (well-defined methodology)
- Documentation updates (manual verification)

---

## Next Steps

1. **Execute Test Scenarios**: Run all 8 scenarios in order
2. **Measure Metrics**: Record actual token counts, line counts, character counts
3. **Document Issues**: Log any failures, regressions, or unexpected behavior
4. **Validate Fixes**: Re-test after any corrections
5. **Update Test Results**: Fill in [NOT TESTED] sections with actual results
6. **Create Summary**: Document overall pass/fail status and key findings
7. **Proceed to Phase 8**: Update documentation with final implementation details

---

## Completion Criteria

Phase 7 is complete when:
- [ ] All 8 test scenarios executed
- [ ] All token/line/character counts measured
- [ ] All validation criteria checked
- [ ] All issues documented
- [ ] All test results recorded
- [ ] Overall pass/fail status determined
- [ ] Key findings summarized
- [ ] Ready to proceed to Phase 8 (documentation updates)

**Status**: READY FOR TESTING
**Next Phase**: Phase 8 - Documentation Updates
