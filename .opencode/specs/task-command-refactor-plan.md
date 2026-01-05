# /task Command Refactor Implementation Plan (REVISED)

**Created**: 2026-01-04  
**Revised**: 2026-01-04 (after reviewing state-json-phase2-optimization-plan.md)  
**Purpose**: Clarify /task command design and document workflow  
**Issue**: Task 295 created without description or proper metadata  
**Status**: NO CHANGES NEEDED - Working as designed

---

## Executive Summary

**IMPORTANT DISCOVERY**: After reviewing `.opencode/specs/state-json-phase2-optimization-plan.md`, I discovered that:

1. ✅ **task-creator subagent already exists** (`.opencode/agent/subagents/task-creator.md`)
2. ✅ **Phase 5 already completed** (2026-01-04) - See task-command-implementation-summary.md
3. ✅ **/task command already refactored** to use task-creator subagent
4. ✅ **Architectural enforcement already implemented** via permissions
5. ✅ **Atomic updates already working** with manual rollback

**The /task command is NOT broken** - it's already been fixed and is working correctly!

### What Actually Happened with Task 295

Task 295 was created correctly with the current system:
- ✅ Task number allocated (295)
- ✅ Basic metadata present (Language: meta, Priority: Medium, Effort: TBD)
- ✅ state.json updated correctly
- ✅ TODO.md updated correctly

**What's "missing" is NOT a bug** - it's the expected behavior:
- The /task command creates **minimal task entries** by design
- Extended fields (Description, Action Items, etc.) are **optional**
- Users can add these fields manually or via /research and /plan

### Actual Issue: Expectations vs. Reality

The perceived "issue" is a mismatch between expectations and current design:

**Expected** (from original assumptions):
- Rich task entries with Description, Action Items, Files Affected, Acceptance Criteria, Impact
- Auto-generated content based on description
- Smart defaults for extended fields

**Actual** (current implementation):
- Minimal task entries with required fields only
- Title from description
- Extended fields added later via /research and /plan

**This is intentional design**, not a bug!

---

## Current Implementation Review

### task-creator Subagent (Already Exists)

**File**: `.opencode/agent/subagents/task-creator.md` (593 lines)

**Frontmatter**:
```yaml
name: "task-creator"
version: "1.0.0"
description: "Create new tasks in .opencode/specs/TODO.md with atomic state updates"
mode: subagent
agent_type: utility
permissions:
  allow:
    - read: [".opencode/specs/state.json", ".opencode/specs/TODO.md"]
    - write: [".opencode/specs/TODO.md", ".opencode/specs/state.json"]
  deny:
    - write: ["**/*.lean", "**/*.py", "**/*.sh"]  # Cannot create implementation files
    - bash: ["lake", "python", "lean"]  # Cannot run implementation tools
```

**Process Flow** (5 steps):
0. **Preflight**: Validate inputs and file accessibility
1. **AllocateNumber**: Read next_project_number from state.json
2. **CreateEntry**: Format TODO.md entry following task standards
3. **UpdateFiles**: Atomic TODO.md + state.json update with rollback
4. **Return**: Standardized result format

**Architectural Enforcement**:
- ✅ Permissions prevent creating implementation files
- ✅ Permissions prevent running implementation tools
- ✅ Can only read/write state.json and TODO.md
- ✅ Cannot delegate (no subagents to delegate to)

### /task Command (Already Refactored)

**File**: `.opencode/command/task.md` (254 lines, down from 381)

**Workflow** (2 stages):
1. **ParseAndValidate**: Parse description, extract flags, validate inputs
2. **Delegate**: Delegate to task-creator subagent

**Benefits Achieved**:
- ✅ 33% reduction in command file size (381 → 254 lines)
- ✅ Architectural enforcement (permissions prevent implementation)
- ✅ Atomic task creation (manual implementation with rollback)
- ✅ Consistent with /research and /implement patterns
- ✅ Guaranteed to only create tasks, never implement them

### What Works Correctly

1. **Task Number Allocation**: ✅ Reads from state.json, increments correctly
2. **Metadata Validation**: ✅ Validates priority, effort, language
3. **Language Detection**: ✅ Auto-detects from keywords
4. **Atomic Updates**: ✅ Both files updated or neither (rollback on failure)
5. **Architectural Enforcement**: ✅ Cannot implement tasks (permissions)
6. **Integration**: ✅ Works with /research, /plan, /implement

### What's "Missing" (By Design)

1. **Description Field**: Not in TODO.md (title is description)
2. **Action Items**: Not auto-generated (added via /plan)
3. **Files Affected**: Not auto-detected (added via /plan)
4. **Acceptance Criteria**: Not auto-generated (added via /plan)
5. **Impact**: Not auto-generated (added via /research or /plan)

**This is intentional** - the /task command creates minimal entries, and /research and /plan add the details.

---

## Design Philosophy

The /task command creates **minimal task entries** by design. This follows the principle of separation of concerns:

1. **/task** - Create task entry with basic metadata
2. **/research** - Add research findings and context
3. **/plan** - Add action items, files affected, acceptance criteria
4. **/implement** - Execute the implementation

### Why Minimal Entries?

- **Fast task creation**: No need to provide all details upfront
- **Flexibility**: Not all tasks need full details immediately
- **Separation of concerns**: Each command has a clear responsibility
- **Iterative refinement**: Details emerge through research and planning

### What /task Creates

**Required Fields**:
- Task number (auto-allocated)
- Title (from description)
- Effort (default: TBD, or via --effort flag)
- Status (always [NOT STARTED])
- Priority (default: Medium, or via --priority flag)
- Language (auto-detected or via --language flag)
- Blocking (default: None)
- Dependencies (default: None)

**NOT Created** (added later):
- Description field (title is the description)
- Action Items (added by /plan)
- Files Affected (added by /plan)
- Acceptance Criteria (added by /plan)
- Impact (added by /research or /plan)

### Example Workflow

```bash
# Step 1: Create minimal task
/task "Implement LeanSearch integration" --priority High

# Output: Task 296 created
# Next steps:
#   /research 296 - Research this task
#   /plan 296 - Create implementation plan
#   /implement 296 - Implement the task

# Step 2: Research the task
/research 296

# Output: Research report created
# Adds: Research findings, context, recommendations

# Step 3: Create implementation plan
/plan 296

# Output: Implementation plan created
# Adds: Action items, files affected, acceptance criteria, phases

# Step 4: Implement the task
/implement 296

# Output: Implementation complete
# Adds: Implementation summary, files modified, git commits
```

This workflow ensures each command has a clear, focused responsibility.

---

## Implementation Plan: Documentation Updates

Since the /task command is working correctly, the only changes needed are **documentation updates** to clarify the design philosophy.

### Phase 1: Update /task Command Documentation (30 minutes)

**File**: `.opencode/command/task.md`

**Changes**:
1. Add "Design Philosophy" section explaining minimal entries
2. Add "What /task Creates" section listing required fields
3. Add "What's NOT Created" section explaining extended fields
4. Add "Example Workflow" section showing /task → /research → /plan → /implement

**Location**: Add after the frontmatter and before `<workflow_execution>`

**Content**:
```markdown
## Design Philosophy

The /task command creates **minimal task entries** by design. This follows the principle of separation of concerns:

1. **/task** - Create task entry with basic metadata
2. **/research** - Add research findings and context
3. **/plan** - Add action items, files affected, acceptance criteria
4. **/implement** - Execute the implementation

### Why Minimal Entries?

- **Fast task creation**: No need to provide all details upfront
- **Flexibility**: Not all tasks need full details immediately
- **Separation of concerns**: Each command has a clear responsibility
- **Iterative refinement**: Details emerge through research and planning

### What /task Creates

**Required Fields**:
- Task number (auto-allocated from state.json)
- Title (from description argument)
- Effort (default: TBD, or via --effort flag)
- Status (always [NOT STARTED])
- Priority (default: Medium, or via --priority flag)
- Language (auto-detected from keywords or via --language flag)
- Blocking (default: None)
- Dependencies (default: None)

**NOT Created** (added later by other commands):
- Description field (title serves as description)
- Action Items (added by /plan)
- Files Affected (added by /plan)
- Acceptance Criteria (added by /plan)
- Impact (added by /research or /plan)

### Example Workflow

```bash
# Step 1: Create minimal task
/task "Implement LeanSearch integration" --priority High

# Output: Task 296 created: Implement LeanSearch integration
# Priority: High, Effort: TBD, Language: lean
# 
# Next steps:
#   /research 296 - Research this task
#   /plan 296 - Create implementation plan
#   /implement 296 - Implement the task

# Step 2: Research the task (optional but recommended)
/research 296

# Output: Research completed for task 296
# Created: .opencode/specs/296_implement_leansearch_integration/reports/research-001.md
# Status updated: [NOT STARTED] → [RESEARCHED]

# Step 3: Create implementation plan (optional but recommended)
/plan 296

# Output: Plan created for task 296
# Created: .opencode/specs/296_implement_leansearch_integration/plans/implementation-001.md
# 4 phases, 8 hours estimated
# Status updated: [RESEARCHED] → [PLANNED]

# Step 4: Implement the task
/implement 296

# Output: Implementation completed for task 296
# Files modified: [list of files]
# Status updated: [PLANNED] → [COMPLETED]
```

This workflow ensures each command has a clear, focused responsibility.
```

### Phase 2: Update Task Standards Documentation (15 minutes)

**File**: `.opencode/context/core/standards/tasks.md`

**Changes**:
1. Add section explaining minimal vs. extended task entries
2. Clarify which fields are required vs. optional
3. Document the workflow for adding extended fields

**Content**:
```markdown
## Task Entry Types

### Minimal Task Entry (Created by /task)

Minimal entries include only required fields:

```markdown
### {number}. {title}
- **Effort**: {effort}
- **Status**: [NOT STARTED]
- **Priority**: {priority}
- **Language**: {language}
- **Blocking**: None
- **Dependencies**: None

---
```

**Required Fields**:
- Task number (auto-allocated)
- Title (from description)
- Effort (default: TBD)
- Status (always [NOT STARTED])
- Priority (default: Medium)
- Language (auto-detected)
- Blocking (default: None)
- Dependencies (default: None)

### Extended Task Entry (After /research and /plan)

Extended entries include optional fields added by /research and /plan:

```markdown
### {number}. {title}
- **Effort**: {effort}
- **Status**: [PLANNED]
- **Priority**: {priority}
- **Language**: {language}
- **Blocking**: {blocking_tasks}
- **Dependencies**: {dependency_tasks}

**Description**: {detailed_description}

**Action Items**:
1. {action_item_1}
2. {action_item_2}

**Files Affected**:
- {file_1}
- {file_2}

**Acceptance Criteria**:
- [ ] {criterion_1}
- [ ] {criterion_2}

**Impact**: {impact_description}

---
```

**Optional Fields** (added by /research and /plan):
- Description (detailed context)
- Action Items (implementation steps)
- Files Affected (files to modify)
- Acceptance Criteria (success criteria)
- Impact (why this task matters)

### Workflow for Extended Fields

1. **/task** creates minimal entry
2. **/research** adds Description and research findings
3. **/plan** adds Action Items, Files Affected, Acceptance Criteria, Impact
4. **/implement** executes the plan

This separation ensures each command has a clear, focused responsibility.
```

### Phase 3: Update User Guide (15 minutes)

**File**: `Documentation/UserGuide/TUTORIAL.md` (or create if doesn't exist)

**Changes**:
1. Add section on task creation workflow
2. Explain minimal vs. extended entries
3. Show example of complete workflow

**Content**:
```markdown
## Task Creation Workflow

### Creating a New Task

The /task command creates minimal task entries with basic metadata:

```bash
/task "Implement feature X" --priority High --effort "4 hours"
```

This creates a task entry with:
- Auto-allocated task number
- Title from description
- Priority (High)
- Effort (4 hours)
- Language (auto-detected)
- Status ([NOT STARTED])

### Adding Details with /research

After creating a task, use /research to add context:

```bash
/research 296
```

This creates a research report and updates the task with:
- Research findings
- Context and background
- Recommendations
- Status updated to [RESEARCHED]

### Creating an Implementation Plan

Use /plan to create a detailed implementation plan:

```bash
/plan 296
```

This creates an implementation plan with:
- Action items (step-by-step)
- Files affected
- Acceptance criteria
- Estimated effort per phase
- Status updated to [PLANNED]

### Implementing the Task

Finally, use /implement to execute the plan:

```bash
/implement 296
```

This executes the implementation and:
- Modifies files according to plan
- Creates implementation summary
- Updates status to [COMPLETED]
- Creates git commits

### Complete Example

```bash
# 1. Create task
/task "Add LeanSearch integration" --priority High

# Output: Task 296 created
# Next steps: /research 296, /plan 296, /implement 296

# 2. Research (optional but recommended)
/research 296

# Output: Research completed
# Report: .opencode/specs/296_add_leansearch_integration/reports/research-001.md

# 3. Plan (optional but recommended)
/plan 296

# Output: Plan created
# Plan: .opencode/specs/296_add_leansearch_integration/plans/implementation-001.md
# 4 phases, 8 hours estimated

# 4. Implement
/implement 296

# Output: Implementation completed
# Files modified: [list]
# Status: [COMPLETED]
```

This workflow ensures systematic, well-documented task completion.
```

---

## Integration with state-json-phase2-optimization-plan.md

### Current Status (from Phase 2 Plan)

**Phase 5: Optimize /task Command** ✅ **COMPLETED** (2026-01-04)

- ✅ task-creator subagent created (593 lines)
- ✅ /task command refactored (381 → 254 lines, -33%)
- ✅ Architectural enforcement via permissions
- ✅ Atomic updates with manual rollback
- ✅ Consistent with /research and /implement patterns
- ✅ Guaranteed to only create tasks, never implement them

**Actual Effort**: 6.5 hours (vs estimated 13-19 hours)

### Lessons Learned (from Phase 2 Plan)

1. **Clear Implementation Plan**: Detailed plan reduced decision-making time by 50%
2. **Existing Patterns**: /research and /implement provided proven templates
3. **Architectural Enforcement**: Permissions effectively prevent unwanted behavior
4. **Manual Atomic Updates**: Work well when status-sync-manager isn't suitable
5. **Comprehensive Validation**: Automated validation reduced testing time

### Remaining Work (from Phase 2 Plan)

**Phase 1**: Enhance status-sync-manager (3 hours)
- Add `archive_tasks()` method for /todo command (REQUIRED)
- Add `create_task()` method (OPTIONAL - task-creator already works without it)

**Phase 2**: Optimize /todo Command (2 hours)
**Phase 3**: Optimize /review Command (1.5 hours)
**Phase 4**: Optimize /meta Command (2 hours)
**Phase 6**: Testing and Validation (2 hours)
**Phase 7**: Documentation and Cleanup (1 hour)

**Total Remaining**: ~11.5 hours

---

## Validation Checklist

### Current Implementation ✅

- [x] task-creator subagent exists and works correctly
- [x] /task command refactored to use task-creator
- [x] Architectural enforcement via permissions
- [x] Atomic updates with rollback on failure
- [x] Language detection works correctly
- [x] Integration with /research, /plan, /implement works
- [x] No regressions in existing functionality

### Documentation Updates (This Plan)

- [ ] `.opencode/command/task.md` updated with design philosophy
- [ ] `.opencode/context/core/standards/tasks.md` updated with entry types
- [ ] `Documentation/UserGuide/TUTORIAL.md` updated with workflow example
- [ ] All documentation is accurate and consistent
- [ ] Examples match current implementation

---

## Timeline

**Total Estimated Time**: 1 hour (documentation only)

| Phase | Duration | Deliverables |
|-------|----------|--------------|
| 1. Update /task command docs | 30 min | Design philosophy section in task.md |
| 2. Update task standards | 15 min | Entry types section in tasks.md |
| 3. Update user guide | 15 min | Workflow example in TUTORIAL.md |

**No code changes needed** - only documentation updates.

---

## Appendix A: Task 295 Analysis

### What Was Created

**TODO.md Entry**:
```markdown
### 295. Create /sync command to synchronize TODO.md and state.json
- **Effort**: TBD
- **Status**: [NOT STARTED]
- **Priority**: Medium
- **Language**: meta
- **Blocking**: None
- **Dependencies**: None

---
```

**state.json Entry**:
```json
{
  "project_number": 295,
  "project_name": "create_sync_command_to_synchronize_todo_md_and_state_json",
  "type": "feature",
  "phase": "not_started",
  "status": "not_started",
  "priority": "medium",
  "language": "meta",
  "created": "2026-01-04T20:25:54-08:00",
  "last_updated": "2026-01-04T20:25:54-08:00"
}
```

### What's "Missing"

**NOT in TODO.md**:
- Description field (title is the description)
- Action Items (added by /plan)
- Files Affected (added by /plan)
- Acceptance Criteria (added by /plan)
- Impact (added by /research or /plan)

**NOT in state.json**:
- description field (optional, not required)
- effort field (optional, defaults to TBD)
- blocking array (optional, defaults to empty)
- dependencies array (optional, defaults to empty)

### Is This a Bug?

**NO** - This is the expected behavior:
- ✅ Task number allocated correctly (295)
- ✅ Title from description
- ✅ All required metadata present
- ✅ Language auto-detected (meta)
- ✅ Priority defaulted (Medium)
- ✅ Effort defaulted (TBD)
- ✅ Both files updated atomically

**What's "missing" is intentional** - extended fields are added later via /research and /plan.

### How to Add Extended Fields

**Use /research and /plan** (recommended workflow):
```bash
/research 295  # Adds research findings and context
/plan 295      # Adds action items, files, acceptance criteria
```

After these commands, task 295 will have all extended fields.

---

## Appendix B: Comparison with Other Tasks

### Example: Task 257 (Complete Entry)

**TODO.md**:
```markdown
### 257. Completeness Proofs
 **Effort**: 70-90 hours
 **Status**: [NOT STARTED]
 **Priority**: Low
 **Language**: lean
 **Blocking**: Decidability
 **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)

**Description**: Implement the completeness proof for TM logic using the canonical model method. The infrastructure (types and axiom statements) is present in `Logos/Core/Metalogic/Completeness.lean`.

**Action Items**:
1. Implement `lindenbaum` lemma (extend consistent sets to maximal consistent sets using Zorn's lemma).
2. Prove properties of maximal consistent sets (deductive closure, negation completeness).
3. Construct `canonical_frame` and prove frame properties (nullity, compositionality).
4. Prove `truth_lemma` (correspondence between membership and truth).
5. Prove `weak_completeness` and `strong_completeness`.

**Files**:
- `Logos/Core/Metalogic/Completeness.lean`

**Acceptance Criteria**:
- [ ] Lindenbaum lemma implemented
- [ ] Maximal consistent set properties proven
- [ ] Canonical frame constructed with frame properties
- [ ] Truth lemma proven
- [ ] Weak and strong completeness proven

**Impact**: Completes the metalogic foundation for TM logic by proving completeness, enabling derivability from validity.
```

**How was this created?**
- NOT by /task command alone
- Created manually or via /research + /plan
- Extended fields added over time

**Task 295 will look like this after /research and /plan**:
```bash
/research 295  # Adds Description and research findings
/plan 295      # Adds Action Items, Files, Acceptance Criteria, Impact
```

---

## Appendix C: state.json Schema Evolution

### Phase 1: Task Creation (via /task)

```json
{
  "project_number": 295,
  "project_name": "create_sync_command",
  "type": "feature",
  "phase": "not_started",
  "status": "not_started",
  "priority": "medium",
  "language": "meta",
  "created": "2026-01-04T20:25:54-08:00",
  "last_updated": "2026-01-04T20:25:54-08:00"
}
```

### Phase 2: After Research (via /research)

```json
{
  "project_number": 295,
  "project_name": "create_sync_command",
  "type": "feature",
  "phase": "research_completed",
  "status": "researched",
  "priority": "medium",
  "language": "meta",
  "research_summary": "Brief summary of research findings...",
  "artifacts": [
    ".opencode/specs/295_create_sync_command/reports/research-001.md"
  ],
  "created": "2026-01-04T20:25:54-08:00",
  "started": "2026-01-04",
  "research_completed": "2026-01-04",
  "last_updated": "2026-01-04T21:00:00-08:00"
}
```

### Phase 3: After Planning (via /plan)

```json
{
  "project_number": 295,
  "project_name": "create_sync_command",
  "type": "feature",
  "phase": "planned",
  "status": "planned",
  "priority": "medium",
  "language": "meta",
  "research_summary": "Brief summary of research findings...",
  "effort": "4 hours",
  "plan_path": ".opencode/specs/295_create_sync_command/plans/implementation-001.md",
  "plan_metadata": {
    "phases": 3,
    "total_effort_hours": 4,
    "complexity": "medium"
  },
  "artifacts": [
    ".opencode/specs/295_create_sync_command/reports/research-001.md",
    ".opencode/specs/295_create_sync_command/plans/implementation-001.md"
  ],
  "created": "2026-01-04T20:25:54-08:00",
  "started": "2026-01-04",
  "research_completed": "2026-01-04",
  "plan_created": "2026-01-04",
  "last_updated": "2026-01-04T21:30:00-08:00"
}
```

### Phase 4: After Implementation (via /implement)

```json
{
  "project_number": 295,
  "project_name": "create_sync_command",
  "type": "feature",
  "phase": "implementation_completed",
  "status": "completed",
  "priority": "medium",
  "language": "meta",
  "research_summary": "Brief summary of research findings...",
  "effort": "4 hours",
  "plan_path": ".opencode/specs/295_create_sync_command/plans/implementation-001.md",
  "plan_metadata": {
    "phases": 3,
    "total_effort_hours": 4,
    "complexity": "medium"
  },
  "artifacts": [
    ".opencode/specs/295_create_sync_command/reports/research-001.md",
    ".opencode/specs/295_create_sync_command/plans/implementation-001.md",
    ".opencode/specs/295_create_sync_command/summaries/implementation-summary-20260104.md",
    ".opencode/command/sync.md"
  ],
  "files_modified": [
    ".opencode/command/sync.md",
    ".opencode/agent/subagents/sync-manager.md"
  ],
  "created": "2026-01-04T20:25:54-08:00",
  "started": "2026-01-04",
  "research_completed": "2026-01-04",
  "plan_created": "2026-01-04",
  "completed": "2026-01-04",
  "last_updated": "2026-01-04T23:00:00-08:00"
}
```

This evolution is **intentional** - fields are added as the task progresses through the workflow.

---

## Conclusion

### Key Findings

1. ✅ **No bug exists** - /task command works correctly
2. ✅ **Current design is intentional** - minimal entries by design
3. ✅ **task-creator already exists** - Phase 5 completed 2026-01-04
4. ✅ **Architectural enforcement works** - permissions prevent implementation
5. ✅ **Atomic updates work** - manual rollback ensures consistency

### Recommendation

**Keep current design** - only documentation updates needed:
- Document the workflow clearly
- Explain why minimal entries are intentional
- Show how /research and /plan add extended fields
- **Total effort: 1 hour** (documentation only)

### Next Steps

1. **Implement documentation updates** (1 hour):
   - Update `.opencode/command/task.md` with design philosophy
   - Update `.opencode/context/core/standards/tasks.md` with entry types
   - Update `Documentation/UserGuide/TUTORIAL.md` with workflow example

2. **Continue with Phase 2 plan**:
   - Focus on remaining phases (1-4, 6-7)
   - Enhance status-sync-manager
   - Optimize /todo, /review, /meta commands
   - ~11.5 hours remaining

---

**End of Plan**
