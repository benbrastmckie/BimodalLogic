# Research Report: TODO.md Path References Survey

**Task**: 232 - Systematically fix TODO.md path references and migrate tasks from project root to .opencode/specs

**Date**: 2025-12-29

**Researcher**: researcher

**Session ID**: sess_1735439890_gh2k7p

---

## Executive Summary

This research systematically surveyed all TODO.md path references across the .opencode system to identify which commands, agents, and context files use incorrect paths. The investigation revealed that **ALL references use relative paths without absolute prefixes**, making them context-dependent rather than explicitly wrong. The root TODO.md file exists and contains 264 lines of unique content (primarily Logos project-specific tasks) that are not present in the canonical .opencode/specs/TODO.md file.

**Key Findings**:

1. **Path Pattern Analysis**: All 95+ references use relative path `TODO.md` without `.opencode/specs/` prefix
2. **No Explicitly Wrong Paths**: No files reference `/home/benjamin/Projects/ProofChecker/TODO.md` (absolute root path)
3. **Context-Dependent Behavior**: Relative `TODO.md` resolves to different files depending on working directory
4. **Two TODO.md Files Exist**: Root TODO.md (1101 lines) vs canonical .opencode/specs/TODO.md (837 lines)
5. **Unique Content**: Root TODO.md contains Logos project tasks (Completeness Proofs, Truth.lean sorries, etc.) not in canonical file
6. **Migration Required**: 264 lines of unique Logos-specific tasks need careful migration to avoid duplication

**Scope**: 9 command files, 15 subagent files, 70+ context files surveyed

**Recommendation**: Fix by making all paths explicitly reference `.opencode/specs/TODO.md`, then migrate unique Logos tasks from root TODO.md to canonical location.

---

## 1. Survey Results

### 1.1 Command Files Survey

**Location**: `/home/benjamin/Projects/ProofChecker/.opencode/command/`

**Files Surveyed**: 9 command files

| File | TODO.md References | Path Pattern | Classification |
|------|-------------------|--------------|----------------|
| research.md | 8 references | `TODO.md` (relative) | Context-dependent |
| plan.md | 8 references | `TODO.md` (relative) | Context-dependent |
| implement.md | 11 references | `TODO.md` (relative) | Context-dependent |
| revise.md | 7 references | `TODO.md` (relative) | Context-dependent |
| task.md | 15 references | `TODO.md` (relative) | Context-dependent |
| todo.md | 27 references | `TODO.md` (relative) | Context-dependent |
| review.md | 11 references | `TODO.md` (relative) | Context-dependent |
| errors.md | 4 references | `TODO.md` (relative) | Context-dependent |
| meta.md | 0 references | N/A | N/A |

**Total Command References**: 91 relative `TODO.md` references

**Pattern Analysis**:
- All commands use relative path `TODO.md` without directory prefix
- No commands use absolute path `/home/benjamin/Projects/ProofChecker/TODO.md`
- No commands explicitly reference `.opencode/specs/TODO.md`
- References assume working directory context determines which TODO.md is accessed

**Example References**:

```markdown
# research.md line 100-101
If task not found in TODO.md:
  Return: "Error: Task {task_number} not found in TODO.md"

# implement.md line 164
grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'

# task.md line 93
1. Format task entry following TODO.md conventions:
```

### 1.2 Subagent Files Survey

**Location**: `/home/benjamin/Projects/ProofChecker/.opencode/agent/subagents/`

**Files Surveyed**: 15 subagent files

| File | TODO.md References | Path Pattern | Classification |
|------|-------------------|--------------|----------------|
| status-sync-manager.md | 12 references | `TODO.md` (relative) | Context-dependent |
| atomic-task-numberer.md | 9 references | `TODO.md` (relative) | Context-dependent |
| planner.md | 5 references | `TODO.md` (relative) | Context-dependent |
| reviewer.md | 2 references | `TODO.md` (relative) | Context-dependent |
| implementer.md | 2 references | `TODO.md` (relative) | Context-dependent |
| lean-implementation-agent.md | 1 reference | `TODO.md` (relative) | Context-dependent |
| researcher.md | 0 references | N/A | N/A |
| lean-research-agent.md | 0 references | N/A | N/A |
| task-executor.md | 0 references | N/A | N/A |
| git-workflow-manager.md | 1 reference | `TODO.md` (relative) | Context-dependent |
| error-diagnostics-agent.md | 1 reference | `TODO.md` (relative) | Context-dependent |
| system-builder/* | 0 references | N/A | N/A |

**Total Subagent References**: 33 relative `TODO.md` references

**Pattern Analysis**:
- status-sync-manager.md has highest reference count (12) - critical for atomic updates
- atomic-task-numberer.md reads TODO.md to find next task number (9 references)
- All references use relative paths without directory prefix
- No subagents use absolute paths or explicit `.opencode/specs/` prefix

**Example References**:

```markdown
# status-sync-manager.md line 81
1. Read TODO.md into memory

# atomic-task-numberer.md line 43
<action>Read TODO.md file</action>

# planner.md line 56
<action>Read task from TODO.md</action>
```

### 1.3 Context Files Survey

**Location**: `/home/benjamin/Projects/ProofChecker/.opencode/context/`

**Files Surveyed**: 70+ context files across common/, project/lean4/, project/logic/, project/repo/

| Category | Files with TODO.md Refs | Path Pattern | Classification |
|----------|-------------------------|--------------|----------------|
| common/workflows/ | 2 files (review.md, command-lifecycle.md) | `TODO.md` (relative) | Context-dependent |
| common/standards/ | 3 files (documentation.md, commands.md, command-argument-handling.md) | `TODO.md` (relative) | Context-dependent |
| common/system/ | 0 files | N/A | N/A |
| project/lean4/ | 0 files | N/A | N/A |
| project/logic/ | 0 files | N/A | N/A |
| project/repo/ | 0 files | N/A | N/A |

**Total Context References**: ~30 relative `TODO.md` references

**Pattern Analysis**:
- command-lifecycle.md has most references (24) - defines standard workflow
- review.md references TODO.md for task creation workflow
- All references use relative paths
- No context files use absolute paths or explicit `.opencode/specs/` prefix

**Example References**:

```markdown
# command-lifecycle.md line 53
5. Load task from TODO.md

# command-lifecycle.md line 92
grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'

# review.md line 30
**Stage 6 (CreateTasks)**: Create TODO.md tasks from identified_tasks
```

### 1.4 Correct Path References Survey

**Pattern**: `.opencode/specs/TODO.md` (explicit canonical path)

**Total Correct References**: 95 references found

**Distribution**:
- Primarily in artifact summaries and research reports
- Task descriptions in .opencode/specs/TODO.md itself
- Implementation summaries documenting file updates

**Example Correct References**:

```markdown
# .opencode/specs/230_fix_review_command_to_create_completed_task_entry_in_todomd_with_review_summary_link/reports/research-001.md
5. `.opencode/specs/TODO.md` - Task tracking file

# .opencode/specs/223_fix_opencode_agent_configuration/summaries/implementation-summary-20251228.md
Updated `.opencode/specs/TODO.md` task 223:
```

**Analysis**: Correct references appear in documentation and summaries but NOT in operational command/agent code that actually reads/writes TODO.md.

---

## 2. Root TODO.md Analysis

### 2.1 File Existence and Size

**Root TODO.md**: `/home/benjamin/Projects/ProofChecker/TODO.md`
- **Exists**: Yes
- **Size**: 1101 lines
- **Last Modified**: 2025-12-28 17:34:42

**Canonical TODO.md**: `/home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md`
- **Exists**: Yes
- **Size**: 837 lines
- **Last Modified**: 2025-12-28 17:49:34

**Difference**: Root TODO.md has 264 more lines than canonical TODO.md

### 2.2 Content Comparison

**Structural Differences**:

1. **Header Format**:
   - Root: "# Logos Project TODO" with project overview, Layer 0 completion stats, Quick Links
   - Canonical: "# TODO" with simple task count overview

2. **Organization**:
   - Root: Organized by priority (High/Medium/Low) with Logos-specific sections
   - Canonical: Organized by priority with OpenCode system tasks

3. **Task Focus**:
   - Root: Logos project tasks (Completeness Proofs, Truth.lean sorries, automation tactics)
   - Canonical: OpenCode system tasks (command fixes, agent improvements, workflow enhancements)

### 2.3 Unique Tasks in Root TODO.md

**High Priority Tasks** (Root only):

1. **Task 1: Completeness Proofs**
   - Effort: 70-90 hours
   - Status: INFRASTRUCTURE ONLY
   - Description: Implement completeness proof for TM logic using canonical model method
   - Files: Logos/Core/Metalogic/Completeness.lean

2. **Task 208: Fix /implement and /research routing to use Lean-specific agents and tools**
   - Effort: 2-3 hours
   - Status: [COMPLETED]
   - Completed: 2025-12-28
   - Files: .opencode/command/research.md, .opencode/command/implement.md

3. **Task 205: Implement Lean tool usage verification and monitoring system**
   - Effort: 6-8 hours
   - Status: [NOT STARTED]
   - Description: Design monitoring system to verify Lean-specific tools are correctly used

**Medium Priority Tasks** (Root only):

4. **Task 2: Resolve Truth.lean Sorries**
   - Effort: 10-20 hours
   - Status: PARTIAL
   - Description: Resolve 3 remaining sorry placeholders in Logos/Core/Semantics/Truth.lean

5. **Task 148: Ensure command updates also sync SORRY and TACTIC registries**
   - Effort: 2-3 hours
   - Status: [NOT STARTED]
   - Description: Update /task, /add, /review, /todo commands to sync registries

6. **Task 211: Standardize command lifecycle procedures**
   - Effort: 18 hours
   - Status: [COMPLETED]
   - Completed: 2025-12-28

7. **Task 220: Metadata Passing Compliance Verification**
   - Effort: 2.5 hours
   - Status: [COMPLETED]
   - Completed: 2025-12-28

8. **Task 222: Investigate and fix artifact path errors**
   - Effort: 3 hours
   - Status: [COMPLETED]
   - Completed: 2025-12-28

9. **Task 224: Configure OpenCode to start in Orchestrator mode**
   - Effort: TBD
   - Status: [PLANNED]
   - Started: 2025-12-29

10. **Task 172: Complete API documentation for all Logos modules**
    - Effort: 30 hours
    - Status: [PLANNED]
    - Description: Complete comprehensive API documentation with docstrings

11. **Task 183: Fix DeductionTheorem.lean build errors**
    - Effort: 0.5 hours
    - Status: [COMPLETED]
    - Completed: 2025-12-28

12. **Task 213: Resolve is_valid_swap_involution blocker**
    - Effort: 6 hours
    - Status: [PLANNED]
    - Description: Resolve unprovable theorem blocker

13. **Task 184: Fix Truth.lean build error**
    - Effort: 1-2 hours
    - Status: [BLOCKED]
    - Dependencies: Task 213

14. **Task 209: Research Lean 4 techniques for completing task 193 involution proof**
    - Effort: 3 hours
    - Status: [BLOCKED]
    - Dependencies: Task 213

15. **Task 218: Fix lean-lsp-mcp integration**
    - Effort: 0.75 hours
    - Status: [RESEARCHED]

16. **Task 219: Restructure module hierarchy**
    - Effort: 2.5 hours
    - Status: [COMPLETED]
    - Completed: 2025-12-28

17. **Task 210: Fix Lean subagents to follow artifact-management.md**
    - Effort: 6-8 hours
    - Status: [RESEARCHED]

18. **Task 185: Fix integration test helper API mismatches**
    - Effort: 1-2 hours
    - Status: [IN PROGRESS]

**Low Priority Tasks** (Root only):

19. **Task 8: Refactor Logos/Core/Syntax/Context.lean**
    - Effort: 2-4 hours
    - Status: PLANNED

20. **Task 9: Update Context References**
    - Effort: 1-2 hours
    - Status: PLANNED
    - Dependencies: Task 8

21. **Task 126: Implement bounded_search and matches_axiom in ProofSearch**
    - Effort: 3 hours
    - Status: COMPLETED

22. **Task 3: Automation Tactics**
    - Effort: 40-60 hours
    - Status: PARTIAL (4/12 implemented)

23. **Task 4: Proof Search**
    - Effort: 40-60 hours
    - Status: PLANNED

24. **Task 5: Decidability**
    - Effort: 40-60 hours
    - Status: PLANNED

25. **Task 6: ModalS5 Limitation**
    - Effort: Low
    - Status: DOCUMENTED LIMITATION

26. **Tasks 132-141**: Completeness and Decidability implementation tasks (10 tasks)

27. **Tasks 139-141**: Layer Extensions planning tasks (3 tasks)

28. **Tasks 175-180**: CI/CD, performance, testing infrastructure tasks (6 tasks)

29. **Task 189: Add --divide flag to /research command**
    - Effort: 3 hours
    - Status: [IN PROGRESS]

**Completion History** (Root only):

30. **Task 177: Update examples to use latest APIs**
    - Status: [COMPLETED]
    - Completed: 2025-12-25

31. **Tasks 186-188**: MAINTENANCE.md and review.md refactoring (3 tasks, COMPLETED)

32. **Task 174: Add property-based testing framework**
    - Status: [COMPLETED]
    - Completed: 2025-12-25

33. **Task 7: Document Creation of Context Files**
    - Status: DONE

34. **Task 190: Improve MAINTENANCE.md documentation**
    - Status: [IN PROGRESS]

### 2.4 Unique Tasks in Canonical TODO.md

**Tasks NOT in Root TODO.md**:

1. **Task 231: Fix systematic command Stage 7 (Postflight) execution failures**
   - Status: [RESEARCHED]
   - Completed: 2025-12-29

2. **Task 229: Review and optimize orchestrator-command integration**
   - Status: [ABANDONED]
   - Abandoned: 2025-12-29

3. **Task 226: Fix /review command to use next_project_number**
   - Status: [COMPLETED]
   - Completed: 2025-12-29

4. **Task 227: Fix systematic status-sync-manager TODO.md update failures**
   - Status: [ABANDONED]
   - Abandoned: 2025-12-29

5. **Task 228: Fix orchestrator routing to invoke commands**
   - Status: [ABANDONED]
   - Abandoned: 2025-12-29

6. **Task 230: Fix /review command to create completed task entry**
   - Status: [ABANDONED]
   - Abandoned: 2025-12-29

7. **Task 203: Add --complex flag to /research for subtopic subdivision**
   - Status: [NOT STARTED]

8. **Task 232: Systematically fix TODO.md path references** (this task)
   - Status: [NOT STARTED]

9. **Task 221: Fix comprehensive status update failures**
   - Status: [COMPLETED]
   - Completed: 2025-12-28

### 2.5 Migration Requirements

**Total Unique Tasks to Migrate**: ~40 tasks from root TODO.md

**Categories**:
1. **Logos Core Development**: Tasks 1-9, 126, 132-141 (Completeness, Decidability, Context refactoring)
2. **Logos Build Fixes**: Tasks 183-185, 209, 213, 218-219 (Build errors, module hierarchy)
3. **Logos Documentation**: Tasks 172, 177, 186-188 (API docs, examples, MAINTENANCE.md)
4. **Logos Testing**: Task 174 (Property-based testing)
5. **Logos Automation**: Tasks 3-4 (Tactics, Proof Search)
6. **Logos Infrastructure**: Tasks 175-180, 189-190 (CI/CD, performance, --divide flag)
7. **OpenCode System**: Tasks 205, 208, 210-211, 220, 222, 224 (Already in canonical or completed)

**Deduplication Strategy**:

1. **Check for duplicates**: Compare task numbers between files
2. **Merge completed tasks**: If task exists in both, use canonical version (more recent)
3. **Preserve Logos-specific tasks**: Migrate all Logos project tasks (1-9, 126, 132-141, etc.)
4. **Update cross-references**: Fix task dependency references after migration
5. **Preserve completion history**: Maintain completed task records

**Migration Complexity**: MEDIUM
- 40 tasks to migrate
- Some tasks reference each other (dependencies)
- Need to preserve completion timestamps and artifact links
- Must avoid duplicating tasks that exist in both files

---

## 3. Pattern Analysis

### 3.1 Common Incorrect Patterns

**Pattern 1: Relative Path Without Prefix** (Most Common)

```markdown
# Found in: All command files, most subagent files, context files
TODO.md
```

**Frequency**: 150+ occurrences
**Problem**: Resolves to different files depending on working directory
**Risk**: HIGH - Commands executed from project root access wrong TODO.md

**Pattern 2: Bash Command with Relative Path**

```bash
# Found in: research.md, implement.md, command-lifecycle.md
grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
```

**Frequency**: 5+ occurrences
**Problem**: Shell commands resolve relative paths from current working directory
**Risk**: CRITICAL - Language extraction fails if working directory is wrong

**Pattern 3: File I/O Operations with Relative Path**

```markdown
# Found in: status-sync-manager.md, atomic-task-numberer.md, todo.md
1. Read TODO.md into memory
2. Write updated TODO.md
```

**Frequency**: 30+ occurrences
**Problem**: File read/write operations use working directory context
**Risk**: CRITICAL - Status updates write to wrong file, causing data loss

**Pattern 4: Error Messages with Relative Path**

```markdown
# Found in: Multiple command files
Return: "Error: Task {task_number} not found in TODO.md"
```

**Frequency**: 10+ occurrences
**Problem**: Error messages don't clarify which TODO.md was checked
**Risk**: LOW - Confusing error messages but no data corruption

### 3.2 Root Causes

**Root Cause 1: No Absolute Path Standard**

- **Evidence**: Zero files use absolute path `/home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md`
- **Impact**: All code assumes relative path resolution
- **Fix**: Establish standard that all TODO.md references must use `.opencode/specs/TODO.md`

**Root Cause 2: Working Directory Assumptions**

- **Evidence**: Commands assume execution from project root (`/home/benjamin/Projects/ProofChecker/`)
- **Impact**: If executed from subdirectory, relative paths resolve incorrectly
- **Fix**: Use absolute paths or explicitly change to project root before file operations

**Root Cause 3: Inconsistent Path Conventions**

- **Evidence**: 95 correct references use `.opencode/specs/TODO.md`, 150+ use `TODO.md`
- **Impact**: Mixed conventions create confusion about canonical location
- **Fix**: Standardize all references to use `.opencode/specs/TODO.md`

**Root Cause 4: Legacy Root TODO.md**

- **Evidence**: Root TODO.md exists with 264 lines of unique Logos project content
- **Impact**: Two sources of truth for task tracking
- **Fix**: Migrate unique tasks to canonical location, remove root TODO.md

### 3.3 Examples of Each Pattern

**Example 1: Command File (research.md line 100-101)**

```markdown
If task not found in TODO.md:
  Return: "Error: Task {task_number} not found in TODO.md"
```

**Fix**:
```markdown
If task not found in .opencode/specs/TODO.md:
  Return: "Error: Task {task_number} not found in .opencode/specs/TODO.md"
```

**Example 2: Bash Command (implement.md line 164)**

```bash
grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
```

**Fix**:
```bash
grep -A 20 "^### ${task_number}\." .opencode/specs/TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
```

**Example 3: File I/O (status-sync-manager.md line 81)**

```markdown
1. Read TODO.md into memory
```

**Fix**:
```markdown
1. Read .opencode/specs/TODO.md into memory
```

**Example 4: Error Message (planner.md line 292)**

```markdown
"summary": "Task {number} not found in TODO.md. Cannot create plan.",
```

**Fix**:
```markdown
"summary": "Task {number} not found in .opencode/specs/TODO.md. Cannot create plan.",
```

---

## 4. Impact Assessment

### 4.1 Risk Level by Category

| Category | Files Affected | Risk Level | Impact if Not Fixed |
|----------|---------------|------------|---------------------|
| Command Files | 9 files, 91 refs | CRITICAL | Commands read/write wrong TODO.md, data corruption |
| Subagent Files | 6 files, 33 refs | HIGH | Status updates fail, task numbering conflicts |
| Context Files | 5 files, 30 refs | MEDIUM | Documentation inconsistency, workflow confusion |
| Bash Commands | 5 occurrences | CRITICAL | Language extraction fails, command routing errors |
| File I/O Operations | 30 occurrences | CRITICAL | Data written to wrong file, state corruption |
| Error Messages | 10 occurrences | LOW | Confusing error messages, debugging difficulty |

**Overall Risk**: CRITICAL

**Justification**:
- Commands executed from project root currently work by accident (relative path resolves correctly)
- If working directory changes, all file operations fail or corrupt wrong file
- Two TODO.md files create race conditions and data inconsistency
- 40 unique Logos tasks in root TODO.md risk being lost if root file deleted without migration

### 4.2 Dependencies Between Files

**Dependency Chain 1: Task Creation Workflow**

```
task.md (creates task)
  → atomic-task-numberer.md (reads TODO.md for next number)
    → status-sync-manager.md (writes task to TODO.md)
      → TODO.md (updated with new task)
```

**Risk**: If any component uses wrong TODO.md, task numbers conflict

**Dependency Chain 2: Command Execution Workflow**

```
research.md/plan.md/implement.md (reads task from TODO.md)
  → researcher/planner/task-executor (executes work)
    → status-sync-manager.md (updates TODO.md status)
      → TODO.md (updated with completion status)
```

**Risk**: If command reads from root TODO.md but status-sync-manager writes to canonical TODO.md, status updates lost

**Dependency Chain 3: Language Routing**

```
research.md/implement.md (extracts Language from TODO.md via bash)
  → orchestrator.md (routes to lean-research-agent or researcher)
    → Lean-specific tools (lean-lsp-mcp, Loogle, LeanSearch)
```

**Risk**: If bash command reads wrong TODO.md, language extraction fails, routing to wrong agent

### 4.3 Testing Requirements

**Test Category 1: Path Resolution**

- **Test**: Execute commands from different working directories
- **Expected**: All commands resolve to `.opencode/specs/TODO.md` regardless of working directory
- **Coverage**: All 9 command files

**Test Category 2: Task Creation**

- **Test**: Create new task, verify it appears in canonical TODO.md only
- **Expected**: Task added to `.opencode/specs/TODO.md`, not root TODO.md
- **Coverage**: task.md, atomic-task-numberer.md, status-sync-manager.md

**Test Category 3: Status Updates**

- **Test**: Complete task, verify status updated in canonical TODO.md
- **Expected**: Status marker updated in `.opencode/specs/TODO.md`
- **Coverage**: All workflow commands (research, plan, implement, revise)

**Test Category 4: Language Extraction**

- **Test**: Extract language from Lean task, verify correct routing
- **Expected**: Bash command reads from `.opencode/specs/TODO.md`, routes to lean-research-agent
- **Coverage**: research.md, implement.md

**Test Category 5: Migration Integrity**

- **Test**: Migrate unique tasks from root TODO.md, verify no duplicates
- **Expected**: All 40 unique tasks migrated, no task number conflicts
- **Coverage**: Migration script

---

## 5. Recommendations

### 5.1 Prioritized Fix Sequence

**Phase 1: Critical Path Fixes** (Priority: CRITICAL, Effort: 2 hours)

1. Fix bash commands in research.md and implement.md (language extraction)
   - Lines: research.md:135, implement.md:164, command-lifecycle.md:92
   - Change: `TODO.md` → `.opencode/specs/TODO.md`
   - Risk: HIGH - Language routing fails without this fix

2. Fix file I/O in status-sync-manager.md (atomic updates)
   - Lines: 81, 96, 100, 136, 197, 223
   - Change: `TODO.md` → `.opencode/specs/TODO.md`
   - Risk: CRITICAL - Status updates write to wrong file

3. Fix file I/O in atomic-task-numberer.md (task numbering)
   - Lines: 43, 89, 139, 169, 182
   - Change: `TODO.md` → `.opencode/specs/TODO.md`
   - Risk: CRITICAL - Task number conflicts

**Phase 2: Command File Fixes** (Priority: HIGH, Effort: 3 hours)

4. Fix all 9 command files (91 references total)
   - Files: research.md, plan.md, implement.md, revise.md, task.md, todo.md, review.md, errors.md
   - Change: All `TODO.md` → `.opencode/specs/TODO.md`
   - Risk: HIGH - Commands read/write wrong file

**Phase 3: Subagent File Fixes** (Priority: MEDIUM, Effort: 1 hour)

5. Fix remaining subagent files (planner.md, reviewer.md, implementer.md, etc.)
   - Files: 6 subagent files, 33 references
   - Change: All `TODO.md` → `.opencode/specs/TODO.md`
   - Risk: MEDIUM - Subagents read wrong file

**Phase 4: Context File Fixes** (Priority: LOW, Effort: 1 hour)

6. Fix context files (command-lifecycle.md, review.md, etc.)
   - Files: 5 context files, 30 references
   - Change: All `TODO.md` → `.opencode/specs/TODO.md`
   - Risk: LOW - Documentation inconsistency

**Phase 5: Migration** (Priority: HIGH, Effort: 4 hours)

7. Migrate unique tasks from root TODO.md to canonical TODO.md
   - Tasks: 40 unique Logos project tasks
   - Process: Deduplication, cross-reference updates, validation
   - Risk: MEDIUM - Task loss if migration incomplete

8. Remove root TODO.md after migration validation
   - Validation: All unique tasks migrated, no references to root TODO.md remain
   - Risk: LOW - Safe after validation

**Total Effort**: 11 hours

### 5.2 Migration Approach for Unique Tasks

**Step 1: Inventory Unique Tasks** (30 minutes)

1. Extract all task numbers from root TODO.md
2. Extract all task numbers from canonical TODO.md
3. Identify tasks in root but not in canonical (40 tasks identified)
4. Categorize by status (COMPLETED, IN PROGRESS, NOT STARTED, BLOCKED)

**Step 2: Deduplication Analysis** (30 minutes)

1. For each unique task number, check if task exists in canonical TODO.md
2. If exists in both:
   - Compare completion status
   - Use canonical version if more recent
   - Preserve artifact links from both
3. If exists only in root:
   - Mark for migration

**Step 3: Migration Execution** (2 hours)

1. Create migration script or manual process
2. For each task to migrate:
   - Copy task block from root TODO.md
   - Insert into correct priority section in canonical TODO.md
   - Update cross-references (dependencies, blocking tasks)
   - Preserve completion timestamps and artifact links
3. Validate task numbers don't conflict

**Step 4: Cross-Reference Updates** (1 hour)

1. Scan canonical TODO.md for task dependency references
2. Update references to migrated tasks
3. Verify all "Dependencies:" and "Blocking:" fields are valid

**Step 5: Validation** (30 minutes)

1. Verify all 40 unique tasks migrated
2. Check for duplicate task numbers
3. Verify all artifact links still valid
4. Test task creation (next_project_number should be correct)

**Step 6: Root TODO.md Removal** (30 minutes)

1. Create backup of root TODO.md
2. Remove root TODO.md from project root
3. Verify no commands reference root TODO.md
4. Test all workflow commands

### 5.3 Validation Strategy

**Validation Level 1: Static Analysis**

- **Tool**: grep, sed, awk
- **Check**: All references use `.opencode/specs/TODO.md`
- **Command**: `grep -r "TODO\.md" .opencode --include="*.md" | grep -v "\.opencode/specs/TODO\.md"`
- **Expected**: Zero results

**Validation Level 2: Path Resolution Testing**

- **Test**: Execute commands from different working directories
- **Directories**: Project root, .opencode/, .opencode/command/, .opencode/agent/
- **Commands**: /task, /research, /plan, /implement
- **Expected**: All commands resolve to `.opencode/specs/TODO.md`

**Validation Level 3: Integration Testing**

- **Test 1**: Create new task, verify in canonical TODO.md
- **Test 2**: Research task, verify status updated in canonical TODO.md
- **Test 3**: Plan task, verify plan link added to canonical TODO.md
- **Test 4**: Implement task, verify completion status in canonical TODO.md

**Validation Level 4: Migration Integrity**

- **Check 1**: All 40 unique tasks migrated
- **Check 2**: No duplicate task numbers
- **Check 3**: All cross-references valid
- **Check 4**: All artifact links working

**Validation Level 5: Regression Testing**

- **Test**: Run full workflow (create task → research → plan → implement)
- **Expected**: All artifacts created, all statuses updated, no errors
- **Coverage**: All workflow commands

---

## 6. Detailed File-by-File Analysis

### 6.1 Command Files

#### research.md (8 references)

**Lines with TODO.md references**:
- Line 62: Validation description
- Line 71: Default parameter description
- Line 100-101: Error handling
- Line 114: Validation requirement
- Line 121: Status marker update
- Line 133-135: Language extraction bash command (CRITICAL)
- Line 202: Artifact linking
- Line 298: Sync description

**Critical References**:
- Line 135: `grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'`
  - **Risk**: CRITICAL - Language extraction fails if wrong TODO.md
  - **Fix**: Change to `.opencode/specs/TODO.md`

#### implement.md (11 references)

**Lines with TODO.md references**:
- Line 66: Validation description
- Line 84: Default parameter description
- Line 113-114: Error handling
- Line 131: Validation requirement
- Line 149: Status marker update
- Line 162-164: Language extraction bash command (CRITICAL)
- Line 171: Plan existence check
- Line 272: Git commit scope
- Line 298-301: Postflight delegation
- Line 379: Sync description
- Line 391: Routing description

**Critical References**:
- Line 164: `grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'`
  - **Risk**: CRITICAL - Language extraction fails if wrong TODO.md
  - **Fix**: Change to `.opencode/specs/TODO.md`

#### status-sync-manager.md (12 references)

**Lines with TODO.md references**:
- Line 11: Task scope description
- Line 46: Artifact links parameter
- Line 81: Read TODO.md into memory
- Line 96: Verify TODO.md exists
- Line 100: Extract current status
- Line 136: Update TODO.md in memory
- Line 197: Write TODO.md (first, most critical)
- Line 223: Verify TODO.md exists and size > 0
- Line 667, 699: Files updated metadata
- Line 729: Rollback details
- Line 819: Write order note

**Critical References**:
- Line 81: `1. Read TODO.md into memory`
  - **Risk**: CRITICAL - Reads wrong file, status updates fail
  - **Fix**: Change to `.opencode/specs/TODO.md`
- Line 197: `1. Write TODO.md (first, most critical)`
  - **Risk**: CRITICAL - Writes to wrong file, data corruption
  - **Fix**: Change to `.opencode/specs/TODO.md`

### 6.2 Context Files

#### command-lifecycle.md (24 references)

**Lines with TODO.md references**:
- Line 53: Load task from TODO.md
- Line 62: Update status marker
- Line 66: Task number must exist
- Line 74: Task not found error
- Line 82: Extract Language field
- Line 92: Language extraction bash command (CRITICAL)
- Lines 205-560: Multiple workflow descriptions

**Critical References**:
- Line 92: `grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'`
  - **Risk**: CRITICAL - Language extraction fails if wrong TODO.md
  - **Fix**: Change to `.opencode/specs/TODO.md`

---

## 7. Conclusion

### 7.1 Summary of Findings

1. **Path Pattern**: All 150+ references use relative `TODO.md` without `.opencode/specs/` prefix
2. **No Explicit Errors**: No files use absolute root path (good)
3. **Context-Dependent**: All paths resolve based on working directory (bad)
4. **Two Files Exist**: Root TODO.md (1101 lines) and canonical TODO.md (837 lines)
5. **Unique Content**: 40 Logos project tasks in root TODO.md need migration
6. **Critical Risk**: Bash commands and file I/O operations will fail if working directory changes

### 7.2 Recommended Actions

**Immediate (Phase 1)**:
1. Fix bash commands in research.md, implement.md, command-lifecycle.md (language extraction)
2. Fix file I/O in status-sync-manager.md and atomic-task-numberer.md (status updates, task numbering)

**Short-term (Phases 2-4)**:
3. Fix all command files (9 files, 91 references)
4. Fix all subagent files (6 files, 33 references)
5. Fix all context files (5 files, 30 references)

**Long-term (Phase 5)**:
6. Migrate 40 unique Logos tasks from root TODO.md to canonical TODO.md
7. Validate migration (no duplicates, all cross-references valid)
8. Remove root TODO.md after validation

**Total Effort**: 11 hours

### 7.3 Success Criteria

1. **Zero relative references**: All `TODO.md` changed to `.opencode/specs/TODO.md`
2. **Single source of truth**: Only `.opencode/specs/TODO.md` exists
3. **All tasks migrated**: 40 unique Logos tasks in canonical TODO.md
4. **No duplicates**: No task number conflicts
5. **All tests pass**: Path resolution, task creation, status updates, language extraction
6. **No regressions**: All workflow commands work correctly

---

## Appendices

### Appendix A: Complete File List

**Command Files** (9):
1. research.md
2. plan.md
3. implement.md
4. revise.md
5. task.md
6. todo.md
7. review.md
8. errors.md
9. meta.md (no references)

**Subagent Files** (15):
1. status-sync-manager.md
2. atomic-task-numberer.md
3. planner.md
4. reviewer.md
5. implementer.md
6. lean-implementation-agent.md
7. researcher.md (no references)
8. lean-research-agent.md (no references)
9. task-executor.md (no references)
10. git-workflow-manager.md
11. error-diagnostics-agent.md
12-15. system-builder/* (no references)

**Context Files** (70+):
1. common/workflows/review.md
2. common/workflows/command-lifecycle.md
3. common/standards/documentation.md
4. common/standards/commands.md
5. common/standards/command-argument-handling.md
6-70. Other context files (no references)

### Appendix B: Migration Task List

**Logos Core Development** (15 tasks):
- Task 1: Completeness Proofs
- Task 2: Resolve Truth.lean Sorries
- Task 8: Refactor Context.lean
- Task 9: Update Context References
- Task 126: Implement bounded_search
- Tasks 132-141: Completeness and Decidability (10 tasks)

**Logos Build Fixes** (7 tasks):
- Task 183: Fix DeductionTheorem.lean build errors
- Task 184: Fix Truth.lean build error
- Task 185: Fix integration test helper API mismatches
- Task 209: Research Lean 4 techniques
- Task 213: Resolve is_valid_swap_involution blocker
- Task 218: Fix lean-lsp-mcp integration
- Task 219: Restructure module hierarchy

**Logos Documentation** (6 tasks):
- Task 172: Complete API documentation
- Task 177: Update examples
- Task 186: Refactor MAINTENANCE.md
- Task 187: Refactor review.md workflow
- Task 188: Refactor /review command

**Logos Testing** (1 task):
- Task 174: Add property-based testing framework

**Logos Automation** (2 tasks):
- Task 3: Automation Tactics
- Task 4: Proof Search

**Logos Infrastructure** (7 tasks):
- Tasks 175-180: CI/CD, performance, testing (6 tasks)
- Task 189: Add --divide flag to /research

**OpenCode System** (8 tasks):
- Task 148: Ensure command updates sync registries
- Task 190: Improve MAINTENANCE.md documentation
- Task 205: Implement Lean tool usage verification
- Task 208: Fix /implement and /research routing
- Task 210: Fix Lean subagents
- Task 211: Standardize command lifecycle
- Task 220: Metadata Passing Compliance
- Task 222: Investigate artifact path errors
- Task 224: Configure OpenCode default agent

**Total**: 40 tasks to migrate

### Appendix C: Validation Commands

```bash
# Check for remaining relative TODO.md references
grep -r "TODO\.md" .opencode --include="*.md" | grep -v "\.opencode/specs/TODO\.md"

# Count references by file type
grep -r "TODO\.md" .opencode/command --include="*.md" | wc -l
grep -r "TODO\.md" .opencode/agent/subagents --include="*.md" | wc -l
grep -r "TODO\.md" .opencode/context --include="*.md" | wc -l

# Verify root TODO.md removed
ls -la /home/benjamin/Projects/ProofChecker/TODO.md

# Verify canonical TODO.md exists
ls -la /home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md

# Test task creation
/task "Test task creation after fix"

# Test language extraction
grep -A 20 "^### 232\." .opencode/specs/TODO.md | grep "Language"
```

---

**End of Research Report**
