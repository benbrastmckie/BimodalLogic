---
name: task
agent: orchestrator
description: "Complete task(s) from TODO.md with intelligent routing, automatic coordinator selection, and end-to-end execution"
---

You are executing task(s) from the TODO.md task list for the ProofChecker project.

**Intelligent Routing**: The `/task` command automatically analyzes task type and routes to the appropriate coordinator agent:
- LEAN proof tasks → proof-developer (tactic, term-mode, metaprogramming specialists)
- Documentation tasks → documenter (doc-analyzer, doc-writer specialists)
- Refactoring tasks → refactorer (style-checker, proof-simplifier specialists)
- Research tasks → researcher (lean-search, loogle, web-research specialists)
- General code tasks → implementer (no specialists)
- Batch tasks → batch-task-orchestrator (dependency-analyzer, status-manager specialists)

**Note**: Meta-system tasks (agent/command creation) are NOT routed by `/task`. Use `/meta` command directly for these.

**End-to-End Execution**: Tasks are executed completely within `/task` - no manual follow-up commands needed.

**Task Input:** $ARGUMENTS

**Context Loaded:**
@/home/benjamin/Projects/ProofChecker/.opencode/specs/TODO.md
@/home/benjamin/Projects/ProofChecker/.opencode/context/lean4/
@/home/benjamin/Projects/ProofChecker/.opencode/context/logic/
@/home/benjamin/Projects/ProofChecker/.opencode/context/core/system/project-overview.md

## Input Format Support

The `/task` command supports multiple input formats:

**Single Task:**
```
/task 63
```
Executes single task using existing workflow (task-executor).

**Task List:**
```
/task 63, 64, 65
```
Executes multiple tasks in batch with dependency analysis.

**Task Range:**
```
/task 65-67
```
Expands to tasks 65, 66, 67 and executes in batch.

**Mixed Format:**
```
/task 63, 65-67, 88
```
Combines list and range: tasks 63, 65, 66, 67, 88 in batch.

## Execution Workflow

### Step 1: Parse Input

Parse the input arguments to extract task numbers:

1. **Split by commas** to get individual parts
2. **For each part:**
   - If contains hyphen (`-`): Parse as range
     - Extract start and end numbers
     - Validate: start ≤ end
     - Expand to list: [start, start+1, ..., end]
   - Else: Parse as single number
3. **Combine all numbers** into single list
4. **Remove duplicates** and sort
5. **Validate** all numbers are positive integers

**Parsing Examples:**
```
"63"           → [63]
"63, 64, 65"   → [63, 64, 65]
"65-67"        → [65, 66, 67]
"63, 65-67, 88" → [63, 65, 66, 67, 88]
"67-65"        → ERROR: Invalid range (start > end)
"63-"          → ERROR: Invalid range format
"abc"          → ERROR: Invalid number format
```

**Error Handling:**
- Invalid format → Return error with examples
- Invalid range (start > end) → Return error
- Non-numeric input → Return error
- Empty input → Return error

### Step 2: Route Based on Task Count

After parsing, determine execution mode:

**Single Task Mode** (1 task):
```
Route to: @subagents/task-executor
Pass: task_number (single integer)
Behavior: Existing single-task workflow
  - Mark task IN PROGRESS
  - Analyze complexity
  - Execute workflow (research + plan or plan only)
  - Mark COMPLETE if executed directly
  - Return plan and recommendations
```

**Batch Mode** (2+ tasks):
```
Route to: @subagents/batch-task-orchestrator
Pass: task_numbers (list of integers)
Behavior: New batch execution workflow
  - Validate all tasks
  - Analyze dependencies (via task-dependency-analyzer)
  - Display execution plan
  - Execute in waves (parallel within wave, sequential across waves)
  - Update TODO.md atomically (via batch-status-manager)
  - Generate comprehensive summary
```

### Step 3: Execute Workflow

**For Single Task:**

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

**For Batch Tasks:**

1. **Route to @subagents/batch-task-orchestrator**
   - Pass task_numbers list
   - Orchestrator will:
     - Validate all tasks exist and are not complete
     - Analyze dependencies (via task-dependency-analyzer)
     - Detect circular dependencies (abort if found)
     - Group tasks into execution waves (topological sort)
     - Display execution plan
     - Execute waves sequentially:
       - Mark wave tasks IN PROGRESS (via batch-status-manager)
       - Execute tasks in wave in parallel (max 5 concurrent)
       - Mark completed tasks COMPLETE (via batch-status-manager)
       - Mark failed tasks FAILED (via batch-status-manager)
       - Block dependent tasks if failures occur
     - Generate comprehensive summary report

2. **Present batch execution summary**
   - Total tasks executed
   - Completed/failed/blocked counts
   - Execution time per wave
   - Artifacts created
   - Recommendations for next steps

## TODO.md Status Tracking

The command automatically manages task status in TODO.md using standardized status markers (see `.opencode/context/repo/status-markers.md`):

**Single Task:**
- **Task Start**: Status → `[IN PROGRESS]`, adds `**Started**: YYYY-MM-DD`
- **Task Complete** (simple tasks): Status → `[COMPLETED]`, adds `**Completed**: YYYY-MM-DD`
- **Task Requires Implementation**: Status remains `[IN PROGRESS]` until user completes /lean or /implement

**Batch Tasks:**
- **Wave Start**: All tasks in wave → `[IN PROGRESS]`, adds `**Started**: YYYY-MM-DD`
- **Wave End**: 
  - Completed tasks → `[COMPLETED]`, adds `**Completed**: YYYY-MM-DD`
  - Failed tasks → `[ABANDONED]`, adds `**Abandoned**: YYYY-MM-DD` + abandonment reason
  - Blocked tasks → `[BLOCKED]`, adds `**Blocked**: YYYY-MM-DD` + blocking reason
- **Atomic Updates**: All status updates in wave performed atomically (single file write)

## Task Matching Logic

Tasks are identified by:
1. **Task number** (e.g., "61" matches "### 61. Add Missing Directory READMEs")
2. **Section headers** with format: `### {number}. {title}`
3. **Status field** in task body: `**Status**: [NOT STARTED]|[IN PROGRESS]|[BLOCKED]|[ABANDONED]|[COMPLETED]`

## Dependency Handling

**Dependency Format in TODO.md:**
```markdown
### 64. Create Example-Builder Specialist
**Dependencies**: 63

### 66. Populate context/logic/standards/
**Dependencies**: 65

### 68. Populate context/logic/patterns/
**Dependencies**: 65, 66, 67
```

**Batch Execution with Dependencies:**
1. Parse dependencies from TODO.md
2. Build dependency graph (DAG)
3. Detect circular dependencies (abort if found)
4. Perform topological sort to create execution waves
5. Execute waves in order:
   - Wave 1: Tasks with no dependencies
   - Wave 2: Tasks depending only on Wave 1
   - Wave N: Tasks depending only on Waves 1..N-1

**Example:**
```
Tasks: 63, 64, 65, 66, 67, 88
Dependencies: 64→63, 65→63, 66→64, 67→65

Execution Plan:
  Wave 1: [63, 88] (no dependencies, execute in parallel)
  Wave 2: [64, 65] (depend on 63, execute in parallel after Wave 1)
  Wave 3: [66, 67] (depend on 64/65, execute in parallel after Wave 2)
```

## Error Handling

**Input Validation Errors:**
- Invalid format → Error message with examples
- Invalid range → Error message
- Empty input → Error message

**Task Validation Errors:**
- Task not found → Log warning, skip task (batch) or abort (single)
- Task already complete → Notify user, suggest other tasks
- All tasks invalid (batch) → Error message

**Dependency Errors:**
- Circular dependency → Error with cycle path, abort batch execution
- External dependency not complete → Warning, may cause issues

**Execution Errors:**
- Task execution fails → Mark as FAILED, block dependents, continue with independent tasks
- Task timeout (>1 hour) → Mark as FAILED, block dependents
- TODO.md update fails → Log error, continue with execution (graceful degradation)

## Expected Output

**Single Task:**
- ✅ TODO.md status update confirmation (if successful)
- Task details (title, description, complexity, effort)
- Workflow executed (research phase if complex, planning phase)
- Artifacts created (research reports, implementation plans)
- Recommended next step (/lean or /implement command)
- Files affected and dependencies
- ✅ TODO.md completion update (if task was executed directly)

**Batch Tasks:**
- Dependency analysis summary
- Execution plan (waves with task counts)
- Wave-by-wave progress reporting
- Task completion/failure details
- Comprehensive summary:
  - Total tasks / Completed / Failed / Blocked
  - Execution time per wave
  - Artifacts created
  - TODO.md update status
  - Recommendations for next steps

## Examples

**Single Task:**
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

**Batch Tasks:**
```
/task 63, 64, 65
# → Analyzes dependencies
# → Executes in waves based on dependencies
# → Reports completion status for all tasks

/task 65-67
# → Expands to [65, 66, 67]
# → Analyzes dependencies
# → Executes in waves
# → Reports completion status

/task 63, 65-67, 88
# → Expands to [63, 65, 66, 67, 88]
# → Analyzes dependencies (e.g., 65→64, 67→66)
# → Execution plan:
#    Wave 1: [63, 88] (no dependencies)
#    Wave 2: [65, 66] (depend on Wave 1)
#    Wave 3: [67] (depends on Wave 2)
# → Executes waves in parallel
# → Reports comprehensive summary
```

## Status Tracking Workflow

```
Single Task:
  TODO.md: **Status**: [NOT STARTED]
         ↓ (automatic)
  TODO.md: **Status**: [IN PROGRESS]
           **Started**: 2025-12-19

  Task Execution:
    - If simple & executed directly:
        TODO.md: **Status**: [COMPLETED] ✅
                 **Completed**: 2025-12-19
    
    - If requires /lean or /implement:
        TODO.md: **Status**: [IN PROGRESS]
                 (user completes implementation)
                 (user manually marks complete)

Batch Tasks:
  Wave Start:
    TODO.md: **Status**: [IN PROGRESS] (all tasks in wave)
             **Started**: 2025-12-19
  
  Wave End:
    TODO.md: **Status**: [COMPLETED] ✅ (completed tasks)
             **Completed**: 2025-12-19
    
    TODO.md: **Status**: [ABANDONED] (failed tasks)
             **Abandoned**: 2025-12-19
             **Abandonment Reason**: {error}
    
    TODO.md: **Status**: [BLOCKED] (blocked tasks)
             **Blocked**: 2025-12-19
             **Blocking Reason**: Blocked by failed task {num}
```

Execute the task(s) now with automatic status tracking and intelligent routing.
