# /task Command Remaining Work Implementation Plan

**Project**: ProofChecker .opencode Agent System  
**Based On**: TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md  
**Created**: 2026-01-07  
**Status**: Ready for Implementation  
**Estimated Duration**: 18-24 hours  

---

## Executive Summary

### Current Status

**Completed Work** (Phases 1, 2, 4, 5, 6):
- ✅ Phase 1: task.md architecture updated to Phase 3 standards
- ✅ Phase 2: --recover flag implemented with bulk support
- ✅ Phase 4: --sync flag implemented with git blame conflict resolution
- ✅ Phase 5: --abandon flag implemented with bulk support
- ✅ Phase 6: Core context files updated

**Remaining Work** (Phase 3, Phase 7, Git Integration):
- ✅ Phase 3: --divide flag for existing tasks (task-divider subagent created, rollback implemented)
- ✅ Git commit integration for all operations (git-workflow-manager delegation complete)
- ⏳ Phase 7: Integration testing and documentation
- ✅ Context file improvements (git-integration.md created)

### Problem Statement

The /task command enhancement plan is 80% complete. The remaining work includes:

1. **task-divider Subagent**: Extract inline division logic from task.md Stage 2 into dedicated subagent
2. **Git Commit Integration**: Delegate to git-workflow-manager for all state-changing operations
3. **Integration Testing**: Comprehensive end-to-end testing of all flags
4. **Context File Refinement**: Ensure context files are accurate, complete, and bloat-free
5. **Documentation Updates**: User guides, examples, and migration documentation

### Solution Approach

Implement remaining work in 3 focused phases:

**Phase A: Complete --divide Implementation** (8-10 hours)
- Create task-divider subagent
- Implement rollback mechanism
- Add git commit integration
- Test --divide flag end-to-end

**Phase B: Git Integration for All Operations** (4-6 hours)
- Add git-workflow-manager delegation to --recover
- Add git-workflow-manager delegation to --sync
- Add git-workflow-manager delegation to --abandon
- Test git commits for all operations

**Phase C: Testing, Documentation, and Context Refinement** (6-8 hours)
- Comprehensive integration testing
- Update user documentation
- Refine context files (remove bloat, ensure accuracy)
- Create migration guide

---

## Detailed Implementation Plan

### Phase A: Complete --divide Implementation (8-10 hours)

#### Objective
Implement task-divider subagent and complete --divide flag functionality for existing tasks.

#### Current State
- ✅ task.md Stage 5 (DivideExistingTask) architecturally complete
- ✅ status-sync-manager supports update_task_metadata operation
- ✅ task-creator subagent exists for subtask creation
- ⏳ task-divider subagent does NOT exist (inline logic in Stage 2)
- ⏳ Rollback mechanism not implemented
- ⏳ Git commit integration not implemented

#### Tasks

##### A.1: Create task-divider Subagent (3-4 hours)

**Location**: `.opencode/agent/subagents/task-divider.md`

**Approach**: Extract and enhance inline division logic from task.md Stage 2

**Subagent Specification**:

```yaml
---
name: "task-divider"
version: "1.0.0"
description: "Analyzes task descriptions and divides them into logical subtasks"
mode: subagent
agent_type: utility
temperature: 0.3
max_tokens: 1500
timeout: 60
tools:
  read: true
  write: false
  bash: false
permissions:
  allow:
    - read: [".opencode/specs/state.json"]
  deny:
    - write: ["**/*"]
    - bash: ["*"]
context_loading:
  strategy: lazy
  required:
    - "core/standards/task-management.md"
  max_context_size: 10000
delegation:
  max_depth: 3
  can_delegate_to: []
lifecycle:
  stage: 6
  return_format: "subagent-return-format.md"
---
```

**Inputs Required**:
- `task_number` (integer): Task to divide
- `task_description` (string): Task description from state.json
- `optional_prompt` (string, optional): User guidance for division
- `session_id` (string): Session identifier
- `delegation_depth` (integer): Current delegation depth
- `delegation_path` (array): Delegation chain

**Process Flow**:

1. **Analyze Task Description**:
   - Parse description for natural divisions:
     * Bullet points or numbered lists
     * "and" conjunctions
     * Comma-separated items
     * Sequential steps (first, then, finally)
     * Multiple verbs (implement X, add Y, fix Z)
   - Consider optional_prompt for division guidance
   - Determine optimal number of subtasks (1-5)

2. **Generate Subtask Descriptions**:
   - Create 1-5 self-contained subtask descriptions
   - Each subtask has clear scope and deliverables
   - Number subtasks: "Task 1/N: ...", "Task 2/N: ...", etc.
   - Maintain logical sequence and dependencies

3. **Validate Subtasks**:
   - Ensure 1-5 subtasks (not 0, not >5)
   - Ensure each subtask is actionable
   - Ensure subtasks cover full scope of parent task
   - Ensure no overlap between subtasks

4. **Return Subtask Array**:
   - Format: `{status: "completed", subtask_descriptions: [...], subtask_count: N}`
   - Include session_id and delegation metadata

**Acceptance Criteria**:
- [ ] Subagent file created with proper frontmatter
- [ ] Analyzes task descriptions for natural divisions
- [ ] Generates 1-5 subtask descriptions
- [ ] Respects optional_prompt for guidance
- [ ] Returns standardized format
- [ ] Handles edge cases (no natural divisions, too many divisions)

**Estimated Effort**: 3-4 hours

---

##### A.2: Implement Rollback Mechanism (2-3 hours)

**Location**: `.opencode/command/task.md` Stage 5 (DivideExistingTask)

**Approach**: Add rollback logic to Stage 5 for partial failures

**Rollback Logic**:

```xml
<rollback_mechanism>
  <track_created_subtasks>
    1. Initialize created_subtasks array
    2. For each subtask creation:
       - Delegate to task-creator
       - On success: Append task_number to created_subtasks
       - On failure: STOP and initiate rollback
  </track_created_subtasks>
  
  <rollback_on_failure>
    If any subtask creation fails:
    
    1. Delete created subtasks:
       - For each task_number in created_subtasks:
         * Delegate to status-sync-manager with operation "delete_task"
         * Remove from TODO.md and state.json
    
    2. Restore next_project_number:
       - Read current next_project_number from state.json
       - Decrement by length of created_subtasks
       - Update state.json atomically
    
    3. Return error with rollback details:
       - Status: "failed"
       - Error: "Failed to create subtask {N}: {error details}"
       - Rollback: "Deleted {count} created subtasks: {task_numbers}"
       - Recommendation: "Fix error and retry division"
  </rollback_on_failure>
  
  <validation>
    - All created subtasks deleted on failure
    - next_project_number restored to pre-division value
    - Parent task unchanged (no dependencies added)
    - Clear error message with rollback details
  </validation>
</rollback_mechanism>
```

**Note**: Requires new `delete_task` operation in status-sync-manager (or reuse archive_tasks with immediate deletion)

**Acceptance Criteria**:
- [ ] Rollback mechanism implemented in Stage 5
- [ ] Tracks created subtasks during loop
- [ ] Deletes created subtasks on failure
- [ ] Restores next_project_number on failure
- [ ] Returns clear error with rollback details
- [ ] Parent task unchanged on failure

**Estimated Effort**: 2-3 hours

---

##### A.3: Add Git Commit Integration for --divide (1-2 hours)

**Location**: `.opencode/command/task.md` Stage 5 (DivideExistingTask)

**Approach**: Delegate to git-workflow-manager after successful division

**Git Commit Logic**:

```xml
<git_commit_integration>
  <after_successful_division>
    1. Delegate to git-workflow-manager:
       - operation: "commit_changes"
       - files: [".opencode/specs/TODO.md", ".opencode/specs/state.json"]
       - commit_message: "task: divide task {parent_number} into {subtask_count} subtasks ({subtask_range})"
       - session_id: {session_id}
       - delegation_depth: {depth + 1}
       - delegation_path: [...path, "git-workflow-manager"]
    
    2. Wait for return from git-workflow-manager
    
    3. Validate return:
       - Check status == "completed"
       - Extract commit_hash from return
       - Log commit details
    
    4. If git commit fails:
       - Log warning (non-critical)
       - Continue with success message
       - Note: Files already updated, git commit is best-effort
  </after_successful_division>
  
  <commit_message_format>
    "task: divide task {parent_number} into {subtask_count} subtasks ({subtask_range})"
    
    Examples:
    - "task: divide task 326 into 3 subtasks (327-329)"
    - "task: divide task 350 into 5 subtasks (351-355)"
  </commit_message_format>
</git_commit_integration>
```

**Acceptance Criteria**:
- [ ] Git commit created after successful division
- [ ] Commit message includes parent task number and subtask range
- [ ] Git commit failure is non-critical (logged but doesn't fail operation)
- [ ] Commit hash logged for traceability

**Estimated Effort**: 1-2 hours

---

##### A.4: Integration Testing for --divide (2 hours)

**Test Cases**:

1. **Test Case A.1: Divide Simple Task**
   ```bash
   /task "Implement feature X: add UI, add backend, add tests"
   # Creates task 350
   
   /task --divide 350
   
   # Expected:
   # - Task 351: "Implement feature X (1/3): Add UI"
   # - Task 352: "Implement feature X (2/3): Add backend"
   # - Task 353: "Implement feature X (3/3): Add tests"
   # - Task 350 dependencies: [351, 352, 353]
   # - Git commit: "task: divide task 350 into 3 subtasks (351-353)"
   ```

2. **Test Case A.2: Divide with Optional Prompt**
   ```bash
   /task --divide 326 "Focus on implementation phases"
   
   # Expected:
   # - Subtasks reflect prompt guidance
   # - 1-5 subtasks created
   # - Parent dependencies updated
   ```

3. **Test Case A.3: Divide Task with No Natural Divisions**
   ```bash
   /task "Simple task with no divisions"
   # Creates task 360
   
   /task --divide 360
   
   # Expected:
   # - 1 subtask created (no division needed)
   # - Or error: "Task cannot be divided (no natural divisions found)"
   ```

4. **Test Case A.4: Rollback on Partial Failure**
   ```bash
   # Simulate failure during subtask creation
   # (e.g., corrupt state.json, disk full, etc.)
   
   /task --divide 370
   
   # Expected:
   # - Rollback initiated
   # - Created subtasks deleted
   # - next_project_number restored
   # - Clear error message with rollback details
   ```

5. **Test Case A.5: Error Handling**
   ```bash
   /task --divide 999  # Task not found
   /task --divide 350  # Task already has dependencies
   /task --divide 360  # Task status is COMPLETED
   
   # Expected:
   # - Clear error messages
   # - No state changes
   # - Helpful recommendations
   ```

**Acceptance Criteria**:
- [ ] All test cases pass
- [ ] Rollback mechanism works correctly
- [ ] Git commits created for successful divisions
- [ ] Error handling covers all edge cases

**Estimated Effort**: 2 hours

---

### Phase B: Git Integration for All Operations (4-6 hours)

#### Objective
Add git-workflow-manager delegation to --recover, --sync, and --abandon operations.

#### Current State
- ✅ git-workflow-manager subagent exists
- ⏳ --recover does NOT create git commits
- ⏳ --sync does NOT create git commits
- ⏳ --abandon does NOT create git commits

#### Tasks

##### B.1: Add Git Commit to --recover (1-2 hours)

**Location**: `.opencode/command/task.md` Stage 4 (RecoverTasks)

**Approach**: Delegate to git-workflow-manager after successful recovery

**Git Commit Logic**:

```xml
<git_commit_integration>
  <after_successful_recovery>
    1. Delegate to git-workflow-manager:
       - operation: "commit_changes"
       - files: [".opencode/specs/TODO.md", ".opencode/specs/state.json"]
       - commit_message: "task: recover {count} tasks from archive ({ranges})"
       - session_id: {session_id}
    
    2. If git commit fails: Log warning (non-critical)
  </after_successful_recovery>
  
  <commit_message_format>
    "task: recover {count} tasks from archive ({ranges})"
    
    Examples:
    - "task: recover 1 task from archive (350)"
    - "task: recover 3 tasks from archive (343-345)"
    - "task: recover 4 tasks from archive (337, 343-345)"
  </commit_message_format>
</git_commit_integration>
```

**Acceptance Criteria**:
- [ ] Git commit created after successful recovery
- [ ] Commit message includes task count and ranges
- [ ] Git commit failure is non-critical

**Estimated Effort**: 1-2 hours

---

##### B.2: Add Git Commit to --sync (1-2 hours)

**Location**: `.opencode/command/task.md` Stage 6 (SyncTasks)

**Approach**: Delegate to git-workflow-manager after successful sync

**Git Commit Logic**:

```xml
<git_commit_integration>
  <after_successful_sync>
    1. Delegate to git-workflow-manager:
       - operation: "commit_changes"
       - files: [".opencode/specs/TODO.md", ".opencode/specs/state.json"]
       - commit_message: "task: sync TODO.md and state.json for {count} tasks ({ranges or 'all'})"
       - commit_body: {conflict_resolution_summary}
       - session_id: {session_id}
    
    2. If git commit fails: Log warning (non-critical)
  </after_successful_sync>
  
  <commit_message_format>
    "task: sync TODO.md and state.json for {count} tasks ({ranges or 'all'})"
    
    Conflict resolution:
    - Task {number}: {fields_count} fields resolved ({sources})
    - Task {number}: {fields_count} fields resolved ({sources})
    
    Total: {conflicts_count} conflicts resolved using git blame
    
    Examples:
    - "task: sync TODO.md and state.json for 1 task (343)"
    - "task: sync TODO.md and state.json for 3 tasks (343-345)"
    - "task: sync TODO.md and state.json for 150 tasks (all)"
  </commit_message_format>
</git_commit_integration>
```

**Acceptance Criteria**:
- [ ] Git commit created after successful sync
- [ ] Commit message includes task count and ranges
- [ ] Commit body includes conflict resolution summary
- [ ] Git commit failure is non-critical

**Estimated Effort**: 1-2 hours

---

##### B.3: Add Git Commit to --abandon (1-2 hours)

**Location**: `.opencode/command/task.md` Stage 7 (AbandonTasks)

**Approach**: Delegate to git-workflow-manager after successful abandonment

**Git Commit Logic**:

```xml
<git_commit_integration>
  <after_successful_abandonment>
    1. Delegate to git-workflow-manager:
       - operation: "commit_changes"
       - files: [".opencode/specs/TODO.md", ".opencode/specs/state.json"]
       - commit_message: "task: abandon {count} tasks ({ranges})"
       - session_id: {session_id}
    
    2. If git commit fails: Log warning (non-critical)
  </after_successful_abandonment>
  
  <commit_message_format>
    "task: abandon {count} tasks ({ranges})"
    
    Examples:
    - "task: abandon 1 task (350)"
    - "task: abandon 3 tasks (343-345)"
    - "task: abandon 4 tasks (337, 343-345, 350)"
  </commit_message_format>
</git_commit_integration>
```

**Acceptance Criteria**:
- [ ] Git commit created after successful abandonment
- [ ] Commit message includes task count and ranges
- [ ] Git commit failure is non-critical

**Estimated Effort**: 1-2 hours

---

### Phase C: Testing, Documentation, and Context Refinement (6-8 hours)

#### Objective
Comprehensive testing, documentation updates, and context file refinement.

#### Tasks

##### C.1: Comprehensive Integration Testing (3-4 hours)

**Test Suite**: All flags together, edge cases, error handling

**Test Cases**:

1. **Test Case C.1: End-to-End Workflow**
   ```bash
   # Create task
   /task "Implement feature X: add UI, add backend, add tests"
   # Creates task 350
   
   # Divide task
   /task --divide 350
   # Creates tasks 351-353, updates 350 dependencies
   
   # Abandon subtask
   /task --abandon 352
   # Abandons task 352
   
   # Recover subtask
   /task --recover 352
   # Recovers task 352 with [NOT STARTED] status
   
   # Sync all tasks
   /task --sync
   # Synchronizes all tasks, resolves conflicts
   
   # Verify:
   # - All operations completed successfully
   # - Git commits created for each operation
   # - Files synchronized correctly
   ```

2. **Test Case C.2: Bulk Operations**
   ```bash
   # Create multiple tasks
   /task "Task 1" --priority High
   /task "Task 2" --priority High
   /task "Task 3" --priority High
   # Creates tasks 360-362
   
   # Abandon all
   /task --abandon 360-362
   
   # Recover all
   /task --recover 360-362
   
   # Sync all
   /task --sync
   
   # Verify:
   # - Bulk operations work correctly
   # - Atomic updates (all or none)
   # - Git commits include ranges
   ```

3. **Test Case C.3: Error Handling**
   ```bash
   # Test invalid inputs
   /task --recover 999  # Task not in archive
   /task --divide 999   # Task not found
   /task --sync 999-1000  # Invalid range
   /task --abandon 999  # Task not found
   
   # Test multiple flags
   /task --recover 350 --divide 351  # Error: multiple flags
   
   # Verify:
   # - Clear error messages
   # - No state changes
   # - Helpful recommendations
   ```

4. **Test Case C.4: Git Blame Conflict Resolution**
   ```bash
   # Setup: Create conflict scenario
   # 1. Edit task 343 status in TODO.md, commit
   # 2. Edit task 343 status in state.json, commit (newer)
   
   # Sync all tasks
   /task --sync
   
   # Verify:
   # - Task 343 uses state.json status (newer commit)
   # - Conflict resolution logged
   # - Git commit includes conflict resolution summary
   ```

5. **Test Case C.5: Rollback Mechanism**
   ```bash
   # Simulate failure during division
   # (e.g., corrupt state.json mid-operation)
   
   /task --divide 370
   
   # Verify:
   # - Rollback initiated
   # - Created subtasks deleted
   # - next_project_number restored
   # - Clear error message
   ```

6. **Test Case C.6: Performance Testing**
   ```bash
   # Test bulk operations with large ranges
   /task --recover 100-200  # 100 tasks
   /task --sync  # All tasks (150+ tasks)
   /task --abandon 100-200  # 100 tasks
   
   # Verify:
   # - Operations complete within 120s timeout
   # - Atomic updates work correctly
   # - Git commits created
   ```

**Acceptance Criteria**:
- [ ] All test cases pass
- [ ] Bulk operations work correctly
- [ ] Error handling covers all edge cases
- [ ] Git commits created for all operations
- [ ] Rollback mechanism works correctly
- [ ] Performance targets met (<120s per operation)

**Estimated Effort**: 3-4 hours

---

##### C.2: Update Documentation (2-3 hours)

**Documentation Updates**:

1. **Update task.md Usage Section**:
   - Add examples for all flags
   - Add error handling examples
   - Add performance notes
   - Add git commit notes

2. **Update User Guide** (`.opencode/README.md` or similar):
   - Add /task command comprehensive guide
   - Add flag usage examples
   - Add troubleshooting section
   - Add migration guide from old commands

3. **Update Architecture Documentation**:
   - Document task-divider subagent
   - Document git-workflow-manager integration
   - Document rollback mechanism
   - Update delegation patterns

4. **Create Migration Guide**:
   - Document changes from old commands to new flags
   - Provide examples for common workflows
   - Document rollback procedures
   - Add FAQ section

**Acceptance Criteria**:
- [ ] task.md usage section updated
- [ ] User guide updated with comprehensive examples
- [ ] Architecture documentation updated
- [ ] Migration guide created

**Estimated Effort**: 2-3 hours

---

##### C.3: Refine Context Files (1-2 hours)

**Objective**: Ensure context files are accurate, complete, and bloat-free

**Context Files to Review**:

1. **`.opencode/context/core/orchestration/routing.md`**:
   - ✅ Already updated in Phase 6
   - Review: Ensure /task flag routing is accurate
   - Remove: Any outdated routing patterns
   - Add: Missing routing patterns (if any)

2. **`.opencode/context/core/orchestration/delegation.md`**:
   - ✅ Already updated in Phase 6
   - Review: Ensure task-divider delegation pattern is documented
   - Remove: Duplicate delegation patterns
   - Add: Rollback mechanism delegation pattern

3. **`.opencode/context/core/orchestration/validation.md`**:
   - ✅ Already updated in Phase 6
   - Review: Ensure validation gates for all flags are documented
   - Remove: Outdated validation patterns
   - Add: Rollback validation pattern

4. **`.opencode/context/core/standards/task-management.md`**:
   - ✅ Already updated in Phase 6
   - Review: Ensure all flag usage standards are documented
   - Remove: Outdated task management patterns
   - Add: Division standards, rollback standards

5. **Create `.opencode/context/core/standards/git-integration.md`** (NEW):
   - Document git-workflow-manager delegation pattern
   - Document commit message formats
   - Document non-critical failure handling
   - Document commit hash logging

**Refinement Principles**:
- **Avoid Bloat**: Remove duplicate information, consolidate similar patterns
- **Ensure Completeness**: All new patterns documented, no missing context
- **Maintain Clarity**: Clear, concise, actionable information
- **Follow Structure**: Consistent formatting, proper headings, examples

**Acceptance Criteria**:
- [ ] All context files reviewed and refined
- [ ] No bloat or needless repetition
- [ ] All new patterns accurately represented
- [ ] New git-integration.md created
- [ ] Context files remain clear, concise, and complete

**Estimated Effort**: 1-2 hours

---

## Context File Improvements

### Identified Issues

Based on review of TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md and current implementation:

1. **Missing Context**: Git integration patterns not documented
2. **Potential Bloat**: Phase 6 updates may have duplicated information
3. **Incomplete Coverage**: Rollback mechanism not documented in validation.md
4. **Outdated Patterns**: Some delegation patterns may reference old architecture

### Proposed Improvements

#### 1. Create `.opencode/context/core/standards/git-integration.md`

**Purpose**: Document git-workflow-manager delegation patterns for all state-changing operations

**Content**:
```markdown
# Git Integration Standards

## Overview

All state-changing operations MUST create git commits for traceability and rollback capability.

## Git Commit Delegation Pattern

### When to Create Commits

Create git commits for:
- Task creation (/task "description")
- Task recovery (/task --recover)
- Task division (/task --divide)
- Task synchronization (/task --sync)
- Task abandonment (/task --abandon)
- Status updates (/implement, /research, /plan, etc.)

### Delegation Pattern

```xml
<git_commit_integration>
  <after_successful_operation>
    1. Delegate to git-workflow-manager:
       - operation: "commit_changes"
       - files: [list of modified files]
       - commit_message: "{operation}: {summary}"
       - commit_body: {optional details}
       - session_id: {session_id}
    
    2. If git commit fails: Log warning (non-critical)
  </after_successful_operation>
</git_commit_integration>
```

### Commit Message Formats

**Task Creation**:
```
task: create task {number} - {title}
```

**Task Recovery**:
```
task: recover {count} tasks from archive ({ranges})
```

**Task Division**:
```
task: divide task {parent_number} into {subtask_count} subtasks ({subtask_range})
```

**Task Synchronization**:
```
task: sync TODO.md and state.json for {count} tasks ({ranges or 'all'})

Conflict resolution:
- Task {number}: {fields_count} fields resolved ({sources})

Total: {conflicts_count} conflicts resolved using git blame
```

**Task Abandonment**:
```
task: abandon {count} tasks ({ranges})
```

### Non-Critical Failure Handling

Git commit failures are NON-CRITICAL:
- Log warning with error details
- Continue with operation success
- Files already updated atomically
- Git commit is best-effort for traceability

### Commit Hash Logging

Always log commit hash for traceability:
```
Git commit created: {commit_hash}
Files: {files}
Message: {commit_message}
```
```

**Estimated Size**: 80-100 lines (within 50-200 line guideline)

---

#### 2. Update `.opencode/context/core/orchestration/delegation.md`

**Changes**:
- Add task-divider delegation pattern
- Add rollback mechanism delegation pattern
- Remove duplicate information (if any)
- Consolidate similar patterns

**New Sections**:

```markdown
### Task Division Delegation Pattern

**When**: Dividing existing task into subtasks

**Delegation Chain**:
1. task.md Stage 5 → task-divider (analyze task)
2. task.md Stage 5 → task-creator (create each subtask)
3. task.md Stage 5 → status-sync-manager (update parent dependencies)
4. task.md Stage 5 → git-workflow-manager (commit changes)

**Rollback on Failure**:
- Track created subtasks during loop
- On failure: Delete created subtasks via status-sync-manager
- Restore next_project_number
- Return error with rollback details

### Rollback Mechanism Delegation Pattern

**When**: Partial failure during multi-step operation

**Pattern**:
1. Track created artifacts during operation
2. On failure: Delegate to cleanup subagent
3. Restore state to pre-operation values
4. Return error with rollback details

**Example** (task division):
```xml
<rollback_on_failure>
  If any subtask creation fails:
  1. Delete created subtasks (delegate to status-sync-manager)
  2. Restore next_project_number (atomic update)
  3. Return error with rollback details
</rollback_on_failure>
```
```

---

#### 3. Update `.opencode/context/core/orchestration/validation.md`

**Changes**:
- Add rollback validation pattern
- Add git commit validation pattern
- Remove outdated validation patterns

**New Sections**:

```markdown
### Rollback Validation Pattern

**When**: Multi-step operation with partial failure risk

**Validation Gates**:
1. **Pre-Rollback**: Verify rollback is necessary
2. **During Rollback**: Verify each cleanup step succeeds
3. **Post-Rollback**: Verify state restored to pre-operation values

**Example** (task division):
```xml
<rollback_validation>
  <pre_rollback>
    - Verify subtask creation failed
    - Verify created_subtasks array is populated
  </pre_rollback>
  
  <during_rollback>
    - Verify each subtask deletion succeeds
    - Verify next_project_number decrement succeeds
  </during_rollback>
  
  <post_rollback>
    - Verify all created subtasks deleted
    - Verify next_project_number restored
    - Verify parent task unchanged
  </post_rollback>
</rollback_validation>
```

### Git Commit Validation Pattern

**When**: After state-changing operation

**Validation Gates**:
1. **Pre-Commit**: Verify files updated successfully
2. **During Commit**: Verify git-workflow-manager delegation succeeds
3. **Post-Commit**: Verify commit hash returned (or log warning if failed)

**Non-Critical Failure**:
- Git commit failure does NOT fail operation
- Log warning with error details
- Continue with success message
```

---

#### 4. Review and Prune Existing Context Files

**Files to Review**:
- `.opencode/context/core/orchestration/routing.md`
- `.opencode/context/core/orchestration/delegation.md`
- `.opencode/context/core/orchestration/validation.md`
- `.opencode/context/core/standards/task-management.md`

**Review Checklist**:
- [ ] Remove duplicate information
- [ ] Consolidate similar patterns
- [ ] Ensure all new patterns documented
- [ ] Verify no outdated patterns remain
- [ ] Check file size (50-200 lines ideal)
- [ ] Verify clarity and conciseness

---

## Success Metrics

### Quantitative Metrics

- **Implementation Completeness**: 100% (all phases complete)
- **Test Pass Rate**: 100% (all test cases pass)
- **Git Commit Success**: >95% (non-critical failures acceptable)
- **Performance**: <120s per operation, <5s for single task operations
- **Context File Size**: 50-200 lines per file (avoid bloat)

### Qualitative Metrics

- **Code Quality**: Follows Phase 3 patterns, well-documented
- **Maintainability**: Easy to extend and modify
- **Reliability**: Atomic updates, rollback mechanisms
- **User Experience**: Clear error messages, predictable behavior
- **Context Quality**: Accurate, complete, bloat-free

---

## Definition of Done

### Phase A: Complete --divide Implementation
- [x] task-divider subagent created and tested
- [x] Rollback mechanism implemented and tested
- [x] Git commit integration added and tested
- [ ] All test cases pass (pending integration testing)

### Phase B: Git Integration for All Operations
- [x] Git commits created for --recover
- [x] Git commits created for --sync
- [x] Git commits created for --abandon
- [ ] All git commits tested (pending integration testing)

### Phase C: Testing, Documentation, and Context Refinement
- [ ] Comprehensive integration testing complete
- [ ] All documentation updated
- [x] Context files refined (git-integration.md created)
- [ ] Migration guide created

### Overall
- [ ] All phases complete
- [ ] All test cases pass
- [ ] All documentation updated
- [ ] Context files accurate and complete
- [ ] No bloat or missing context
- [ ] Ready for production use

---

## Timeline

**Phase A**: 8-10 hours
- A.1: Create task-divider subagent (3-4 hours)
- A.2: Implement rollback mechanism (2-3 hours)
- A.3: Add git commit integration (1-2 hours)
- A.4: Integration testing (2 hours)

**Phase B**: 4-6 hours
- B.1: Git commit for --recover (1-2 hours)
- B.2: Git commit for --sync (1-2 hours)
- B.3: Git commit for --abandon (1-2 hours)

**Phase C**: 6-8 hours
- C.1: Comprehensive integration testing (3-4 hours)
- C.2: Update documentation (2-3 hours)
- C.3: Refine context files (1-2 hours)

**Total**: 18-24 hours

---

## Dependencies

### Internal Dependencies
- ✅ status-sync-manager: Supports all required operations
- ✅ task-creator: Exists for subtask creation
- ✅ git-workflow-manager: Exists for git commits
- ⏳ task-divider: Needs creation (Phase A.1)

### External Dependencies
None

---

## Rollback/Contingency

### Rollback Plan

If any phase causes issues:

1. **Immediate Rollback**:
   ```bash
   git log --oneline -10  # Find commit before phase
   git revert <commit_hash>  # Revert phase changes
   ```

2. **Partial Rollback**:
   - If task-divider has issues: Revert subagent file
   - If git integration has issues: Remove git-workflow-manager delegation
   - If context files have issues: Revert context file changes

3. **Manual Recovery**:
   - Restore files from git history
   - Fix issues and retry phase

### Contingency Plan

If implementation is too complex:

1. **Simplify --divide**:
   - Keep inline division logic in task.md Stage 2
   - Skip task-divider subagent creation
   - Implement basic rollback (no subagent delegation)

2. **Simplify Git Integration**:
   - Make git commits optional (flag-based)
   - Skip git-workflow-manager delegation
   - Use inline git commands

3. **Simplify Context Files**:
   - Skip git-integration.md creation
   - Minimal updates to existing context files
   - Document in task.md only

---

## Next Steps

1. **Review Plan**: Ensure all stakeholders agree with approach
2. **Begin Phase A**: Create task-divider subagent
3. **Complete Phase A**: Implement rollback and git integration
4. **Begin Phase B**: Add git commits to all operations
5. **Complete Phase C**: Test, document, and refine context files
6. **Deploy**: Roll out to production

---

**Plan Author**: Claude (AI Assistant)  
**Plan Date**: 2026-01-07  
**Based On**: TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md  
**Status**: Ready for Implementation  
**Estimated Duration**: 18-24 hours
