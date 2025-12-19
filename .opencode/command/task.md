---
name: task
agent: orchestrator
description: "Complete a task from TODO.md by task number with automatic status tracking"
---

You are executing a task from the TODO.md task list for the ProofChecker project.

**Task Number:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/specs/TODO.md
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/lean4/
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/logic/
@/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.opencode/context/project/project-context.md

**Task:**

Execute the task workflow with automatic TODO.md status tracking:

1. **Pre-Execution: Mark Task as IN PROGRESS**
   - Read TODO.md and locate task by number
   - Update task status to `[IN PROGRESS]` if not already set
   - Add timestamp: `**Started**: YYYY-MM-DD`
   - Write updated TODO.md back to file
   - If task not found or already complete, log warning and proceed

2. **Route to @subagents/task-executor with task number**
   - Task executor will:
     - Read TODO.md and extract task details by number
     - Analyze task complexity (simple vs complex)
     - Execute appropriate workflow:
       - **Complex tasks**: Research → Plan → Recommend next step
       - **Simple tasks**: Plan → Execute or Recommend next step
     - Create project directory and artifacts in .opencode/specs/NNN_task_name/
     - Present plan summary and recommendations

3. **Post-Execution: Mark Task as COMPLETE (if executed)**
   - If task was executed directly (simple tasks only):
     - Update task status from `[IN PROGRESS]` to `[COMPLETE]`
     - Add completion timestamp: `**Completed**: YYYY-MM-DD`
     - Move task to "Completed" section or mark with ✅
     - Write updated TODO.md back to file
   - If task requires further work (/lean or /implement):
     - Leave status as `[IN PROGRESS]`
     - User will manually mark complete after implementation

4. **Present results with next steps**

**TODO.md Status Tracking:**

The command automatically manages task status in TODO.md:

- **Task Start**: Status → `[IN PROGRESS]`, adds `**Started**: YYYY-MM-DD`
- **Task Complete** (simple tasks): Status → `[COMPLETE]`, adds `**Completed**: YYYY-MM-DD`
- **Task Requires Implementation**: Status remains `[IN PROGRESS]` until user completes /lean or /implement

**Task Matching Logic:**

Tasks are identified by:
1. **Task number** (e.g., "61" matches "### 61. Add Missing Directory READMEs")
2. **Section headers** with format: `### {number}. {title}`
3. **Status field** in task body: `**Status**: Not Started|In Progress|Complete`

**Error Handling:**

- Task not found → Log warning, proceed with execution (no status update)
- TODO.md not found → Log warning, proceed with execution (no status update)
- Task already complete → Notify user, suggest other tasks
- Multiple matches → Use first match, log warning
- File write errors → Log error, continue with task execution

**Expected Output:**

- ✅ TODO.md status update confirmation (if successful)
- Task details (title, description, complexity, effort)
- Workflow executed (research phase if complex, planning phase)
- Artifacts created (research reports, implementation plans)
- Recommended next step (/lean or /implement command)
- Files affected and dependencies
- ✅ TODO.md completion update (if task was executed directly)

**Examples:**

```
/task 59    # Simple task: Update IMPLEMENTATION_STATUS.md
            # → Marks [IN PROGRESS] → Executes → Marks [COMPLETE]

/task 52    # Moderate task: Fix AesopRules duplicate
            # → Marks [IN PROGRESS] → Creates plan → Recommends /implement
            # → User runs /implement → User manually marks complete

/task 9     # Complex task: Begin Completeness Proofs (requires research)
            # → Marks [IN PROGRESS] → Research + Plan → Recommends /lean
            # → User runs /lean → User manually marks complete
```

**Status Tracking Workflow:**

```
Task Start:
  TODO.md: **Status**: Not Started
         ↓ (automatic)
  TODO.md: **Status**: [IN PROGRESS]
           **Started**: 2025-12-16

Task Execution:
  - If simple & executed directly:
      TODO.md: **Status**: [COMPLETE] ✅
               **Completed**: 2025-12-16
  
  - If requires /lean or /implement:
      TODO.md: **Status**: [IN PROGRESS]
               (user completes implementation)
               (user manually marks complete)
```

Execute the task now with automatic status tracking.
