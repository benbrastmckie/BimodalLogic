# /task Command Remaining Work - Quick Start Guide

**For**: Developers implementing the remaining 20% of /task command enhancements  
**Date**: 2026-01-07  
**Estimated Time**: 18-24 hours  

---

## TL;DR - What You Need to Do

### 3 Main Tasks

1. **Create task-divider subagent** (3-4 hours)
   - Extract inline division logic from task.md Stage 2
   - Make it work for existing tasks (not just new tasks)
   - Return 1-5 subtask descriptions

2. **Add git commits everywhere** (4-6 hours)
   - Add git-workflow-manager delegation to 4 operations
   - Non-critical failures (log warning, continue)
   - Descriptive commit messages

3. **Test and document** (6-8 hours)
   - Integration testing (all flags together)
   - Update user documentation
   - Refine context files

---

## Phase A: Create task-divider Subagent (8-10 hours)

### Step A.1: Create the Subagent File (3-4 hours)

**File**: `.opencode/agent/subagents/task-divider.md`

**Copy from**: task.md Stage 2 (lines 120-165) - the inline division logic

**Key Changes**:
1. **Input**: Accept `task_number` and `task_description` (not just new task description)
2. **Read from state.json**: Get existing task description if task_number provided
3. **Output**: Return array of subtask descriptions (not formatted tasks)

**Template**:
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
---

<inputs_required>
  <parameter name="task_number" type="integer" optional="true">
    Task number to divide (for existing tasks)
  </parameter>
  <parameter name="task_description" type="string">
    Task description to analyze
  </parameter>
  <parameter name="optional_prompt" type="string" optional="true">
    User guidance for division
  </parameter>
</inputs_required>

<process_flow>
  <step_1_analyze>
    Analyze description for natural divisions:
    - Bullet points or numbered lists
    - "and" conjunctions
    - Comma-separated items
    - Sequential steps (first, then, finally)
    - Multiple verbs (implement X, add Y, fix Z)
  </step_1_analyze>
  
  <step_2_generate>
    Generate 1-5 subtask descriptions:
    - Each subtask self-contained
    - Clear scope and deliverables
    - Numbered: "Task 1/N: ...", "Task 2/N: ...", etc.
  </step_2_generate>
  
  <step_3_return>
    Return:
    {
      "status": "completed",
      "subtask_descriptions": [...],
      "subtask_count": N
    }
  </step_3_return>
</process_flow>
```

**Test**:
```bash
# Test with simple task
/task "Implement feature X: add UI, add backend, add tests"
# Creates task 350

/task --divide 350
# Should create tasks 351-353
```

---

### Step A.2: Add Rollback Mechanism (2-3 hours)

**File**: `.opencode/command/task.md` Stage 5 (DivideExistingTask)

**Location**: After subtask creation loop, before parent dependency update

**Add**:
```xml
<rollback_on_failure>
  If any subtask creation fails:
  
  1. Track created subtasks:
     - Initialize created_subtasks = []
     - After each successful creation: created_subtasks.append(task_number)
  
  2. On failure:
     - For each task_number in created_subtasks:
       * Delegate to status-sync-manager with operation "archive_tasks"
       * Force delete (don't just archive)
     - Decrement next_project_number by length(created_subtasks)
     - Return error: "Failed to create subtask {N}: {error}. Rolled back {count} subtasks."
</rollback_on_failure>
```

**Test**:
```bash
# Simulate failure (corrupt state.json mid-operation)
/task --divide 370

# Should rollback and report error
```

---

### Step A.3: Add Git Commit (1-2 hours)

**File**: `.opencode/command/task.md` Stage 5 (DivideExistingTask)

**Location**: After parent dependency update, before success message

**Add**:
```xml
<git_commit>
  Delegate to git-workflow-manager:
  - operation: "commit_changes"
  - files: [".opencode/specs/TODO.md", ".opencode/specs/state.json"]
  - commit_message: "task: divide task {parent_number} into {subtask_count} subtasks ({subtask_range})"
  - session_id: {session_id}
  
  If git commit fails: Log warning (non-critical)
</git_commit>
```

**Test**:
```bash
/task --divide 326

# Check git log
git log -1
# Should see: "task: divide task 326 into 3 subtasks (327-329)"
```

---

## Phase B: Add Git Commits Everywhere (4-6 hours)

### Step B.1: Add to --recover (1-2 hours)

**File**: `.opencode/command/task.md` Stage 4 (RecoverTasks)

**Location**: After successful recovery, before success message

**Add**:
```xml
<git_commit>
  Delegate to git-workflow-manager:
  - commit_message: "task: recover {count} tasks from archive ({ranges})"
</git_commit>
```

---

### Step B.2: Add to --sync (1-2 hours)

**File**: `.opencode/command/task.md` Stage 6 (SyncTasks)

**Location**: After successful sync, before success message

**Add**:
```xml
<git_commit>
  Delegate to git-workflow-manager:
  - commit_message: "task: sync TODO.md and state.json for {count} tasks ({ranges or 'all'})"
  - commit_body: {conflict_resolution_summary}
</git_commit>
```

---

### Step B.3: Add to --abandon (1-2 hours)

**File**: `.opencode/command/task.md` Stage 7 (AbandonTasks)

**Location**: After successful abandonment, before success message

**Add**:
```xml
<git_commit>
  Delegate to git-workflow-manager:
  - commit_message: "task: abandon {count} tasks ({ranges})"
</git_commit>
```

---

## Phase C: Test and Document (6-8 hours)

### Step C.1: Integration Testing (3-4 hours)

**Test Suite**: Run all test cases from TASK_COMMAND_REMAINING_WORK_PLAN.md

**Key Tests**:
1. End-to-end workflow (create → divide → abandon → recover → sync)
2. Bulk operations (ranges, lists)
3. Error handling (invalid inputs, partial failures)
4. Git blame conflict resolution
5. Rollback mechanism
6. Performance (bulk operations with 100+ tasks)

**Checklist**:
- [ ] All flags work individually
- [ ] All flags work together
- [ ] Bulk operations work correctly
- [ ] Error handling covers edge cases
- [ ] Git commits created for all operations
- [ ] Rollback mechanism works correctly
- [ ] Performance targets met (<120s per operation)

---

### Step C.2: Update Documentation (2-3 hours)

**Files to Update**:

1. **`.opencode/command/task.md`** (Usage section):
   - Add examples for all flags
   - Add error handling examples
   - Add performance notes

2. **`.opencode/README.md`** (or user guide):
   - Add /task command comprehensive guide
   - Add flag usage examples
   - Add troubleshooting section

3. **Architecture docs**:
   - Document task-divider subagent
   - Document git-workflow-manager integration
   - Document rollback mechanism

4. **Migration guide** (NEW):
   - Document changes from old commands
   - Provide examples for common workflows
   - Add FAQ section

---

### Step C.3: Refine Context Files (1-2 hours)

**Create**: `.opencode/context/core/standards/git-integration.md`

**Content**:
```markdown
# Git Integration Standards

## Git Commit Delegation Pattern

All state-changing operations MUST create git commits.

### Delegation Pattern
```xml
<git_commit>
  Delegate to git-workflow-manager:
  - operation: "commit_changes"
  - files: [modified files]
  - commit_message: "{operation}: {summary}"
  - session_id: {session_id}
  
  If git commit fails: Log warning (non-critical)
</git_commit>
```

### Commit Message Formats

**Task Creation**: `task: create task {number} - {title}`
**Task Recovery**: `task: recover {count} tasks from archive ({ranges})`
**Task Division**: `task: divide task {parent_number} into {subtask_count} subtasks ({subtask_range})`
**Task Synchronization**: `task: sync TODO.md and state.json for {count} tasks ({ranges or 'all'})`
**Task Abandonment**: `task: abandon {count} tasks ({ranges})`
```

**Update**: `.opencode/context/core/orchestration/delegation.md`

**Add**:
```markdown
### Task Division Delegation Pattern

Delegation chain:
1. task.md → task-divider (analyze task)
2. task.md → task-creator (create each subtask)
3. task.md → status-sync-manager (update parent dependencies)
4. task.md → git-workflow-manager (commit changes)

Rollback on failure:
- Track created subtasks
- Delete on failure
- Restore next_project_number
```

**Update**: `.opencode/context/core/orchestration/validation.md`

**Add**:
```markdown
### Rollback Validation Pattern

Pre-rollback: Verify rollback is necessary
During rollback: Verify each cleanup step succeeds
Post-rollback: Verify state restored to pre-operation values
```

---

## Common Pitfalls to Avoid

### 1. Don't Duplicate Logic
- ❌ Copy-paste inline division logic to task-divider
- ✅ Extract and enhance inline logic

### 2. Don't Make Git Commits Critical
- ❌ Fail operation if git commit fails
- ✅ Log warning and continue

### 3. Don't Skip Rollback Testing
- ❌ Assume rollback works without testing
- ✅ Test rollback with simulated failures

### 4. Don't Bloat Context Files
- ❌ Add every detail to context files
- ✅ Add only essential patterns and standards

### 5. Don't Skip Integration Testing
- ❌ Test each flag in isolation only
- ✅ Test all flags together in workflows

---

## Verification Checklist

### Phase A Complete
- [ ] task-divider.md exists in `.opencode/agent/subagents/`
- [ ] task-divider analyzes existing tasks correctly
- [ ] Rollback mechanism implemented in task.md Stage 5
- [ ] Git commit integration added to Stage 5
- [ ] /task --divide 326 works end-to-end
- [ ] Rollback tested with simulated failure

### Phase B Complete
- [ ] Git commit added to --recover (Stage 4)
- [ ] Git commit added to --sync (Stage 6)
- [ ] Git commit added to --abandon (Stage 7)
- [ ] All git commits tested
- [ ] Git commit failures are non-critical

### Phase C Complete
- [ ] All integration tests pass
- [ ] User documentation updated
- [ ] Architecture documentation updated
- [ ] Migration guide created
- [ ] git-integration.md created
- [ ] delegation.md updated
- [ ] validation.md updated
- [ ] Context files reviewed and pruned

### Overall Complete
- [ ] All phases complete
- [ ] All test cases pass
- [ ] All documentation updated
- [ ] Context files accurate and complete
- [ ] No bloat or missing context
- [ ] Ready for production use

---

## Time Estimates

### Optimistic (18 hours)
- Phase A: 8 hours
- Phase B: 4 hours
- Phase C: 6 hours

### Realistic (21 hours)
- Phase A: 9 hours
- Phase B: 5 hours
- Phase C: 7 hours

### Pessimistic (24 hours)
- Phase A: 10 hours
- Phase B: 6 hours
- Phase C: 8 hours

---

## Getting Help

### Reference Documents
- **Comprehensive Plan**: `.opencode/specs/TASK_COMMAND_COMPREHENSIVE_ENHANCEMENT_PLAN.md`
- **Remaining Work Plan**: `.opencode/specs/TASK_COMMAND_REMAINING_WORK_PLAN.md`
- **Status Summary**: `.opencode/specs/TASK_COMMAND_STATUS_SUMMARY.md`

### Key Files to Review
- **task.md**: `.opencode/command/task.md` (all stages)
- **status-sync-manager.md**: `.opencode/agent/subagents/status-sync-manager.md` (operations)
- **task-creator.md**: `.opencode/agent/subagents/task-creator.md` (subtask creation)
- **git-workflow-manager.md**: `.opencode/agent/subagents/git-workflow-manager.md` (git commits)

### Questions to Ask
1. How does inline division work in task.md Stage 2?
2. How does task-creator create subtasks?
3. How does status-sync-manager update task metadata?
4. How does git-workflow-manager create commits?
5. What's the rollback pattern for multi-step operations?

---

## Success Criteria

### You're Done When:
1. ✅ /task --divide 326 works end-to-end
2. ✅ Git commits created for all operations
3. ✅ Rollback mechanism tested and working
4. ✅ All integration tests pass
5. ✅ All documentation updated
6. ✅ Context files refined (no bloat, complete coverage)

### You Can Ship When:
1. ✅ All test cases pass
2. ✅ All documentation updated
3. ✅ Context files accurate and complete
4. ✅ No bloat or missing context
5. ✅ Ready for production use

---

**Quick Start Guide Author**: Claude (AI Assistant)  
**Date**: 2026-01-07  
**For**: Developers implementing remaining /task command work  
**Estimated Time**: 18-24 hours  
**Next Action**: Begin Phase A.1 (Create task-divider subagent)
