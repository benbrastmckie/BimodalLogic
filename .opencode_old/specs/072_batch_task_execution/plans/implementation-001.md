# Implementation Plan: Batch Task Execution with Parallel Processing

**Project**: #072
**Version**: 001
**Date**: 2025-12-19
**Status**: ✅ COMPLETE (Implementation finished 2025-12-19T06:06:00Z)
**Complexity**: Complex
**Estimated Effort**: 18-25 hours

---

## Implementation Status

✅ **Planning Phase**: Complete (2025-12-19T05:52:00Z)
✅ **Phase 1 - Foundation**: Complete (2025-12-19T06:01:00Z)
✅ **Phase 2 - Orchestration**: Complete (2025-12-19T06:02:00Z)
✅ **Phase 3 - Integration**: Complete (2025-12-19T06:04:00Z)
✅ **Phase 4 - Testing & Documentation**: Complete (2025-12-19T06:06:00Z)

**All components implemented and documented. System ready for production use.**

See [IMPLEMENTATION_SUMMARY.md](../IMPLEMENTATION_SUMMARY.md) for complete implementation details.

---

## Table of Contents

1. [Task Description](#task-description)
2. [Architectural Decision](#architectural-decision)
3. [Complexity Assessment](#complexity-assessment)
4. [Component Design](#component-design)
5. [Dependency Analysis Algorithm](#dependency-analysis-algorithm)
6. [Parallel Execution Strategy](#parallel-execution-strategy)
7. [TODO.md Update Strategy](#todomd-update-strategy)
8. [Error Handling Strategy](#error-handling-strategy)
9. [Implementation Steps](#implementation-steps)
10. [File Structure](#file-structure)
11. [Testing Strategy](#testing-strategy)
12. [Risk Assessment](#risk-assessment)
13. [Success Criteria](#success-criteria)

---

## Task Description

Enhance the `/task` command system to support batch execution of multiple tasks with intelligent dependency analysis, parallel wave-based execution, and atomic TODO.md status tracking.

### Current System

**Existing Components**:
- `/task` command (`.opencode/command/task.md`) - handles single task execution
- `task-executor` subagent (`.opencode/agent/subagents/task-executor.md`) - executes tasks with complexity analysis and workflow routing
- TODO.md format with numbered tasks, status tracking, dependencies
- XML-optimized agent architecture with hierarchical routing

**Current Workflow**:
1. User runs `/task 63`
2. Command marks task IN PROGRESS in TODO.md
3. Routes to task-executor subagent
4. Task-executor analyzes complexity, routes to researcher/planner
5. Creates artifacts in `.opencode/specs/NNN_task_name/`
6. Returns plan and recommends next step (/lean or /implement)
7. Marks task COMPLETE if executed directly (simple tasks only)

### Enhancement Requirements

**Input Format Support**:
- Single tasks: `/task 63`
- Task lists: `/task 63, 64, 65`
- Task ranges: `/task 65-67`
- Mixed format: `/task 63, 65-67, 88`

**Core Features**:
1. **Dependency Analysis**: Parse TODO.md dependencies, build DAG, detect cycles, topological sort
2. **Parallel Execution**: Execute tasks in waves (parallel within wave, sequential across waves)
3. **TODO.md Management**: Atomic status updates, avoid race conditions
4. **Error Handling**: Graceful handling of failures, blocking dependent tasks
5. **Progress Reporting**: Wave-by-wave progress, final summary

---

## Architectural Decision

### Option Analysis

**Option 1: Enhance `/task` command directly**
- ✅ Pros: Simpler, fewer files
- ❌ Cons: Command becomes complex, harder to maintain, violates single responsibility

**Option 2: Create batch-task-orchestrator subagent**
- ✅ Pros: Separation of concerns, reusable, testable
- ❌ Cons: More files, slightly more complex routing

**Option 3: Hybrid - command handles parsing, orchestrator handles execution** ⭐ **RECOMMENDED**
- ✅ Pros: Best separation, command stays simple, orchestrator handles complexity
- ✅ Pros: Follows existing architecture patterns (task-executor, planner, researcher)
- ✅ Pros: Maintains separation of concerns
- ✅ Pros: Provides best maintainability and testability
- ❌ Cons: Most files, but cleanest architecture

### Justification for Option 3 (Hybrid)

**Architectural Consistency**:
- Mirrors existing pattern: `/task` command → task-executor → researcher/planner
- New pattern: `/task` command → batch-task-orchestrator → task-dependency-analyzer + batch-status-manager + task-executor (parallel)
- Maintains XML-optimized agent architecture with hierarchical routing
- Follows context protection principle (artifacts in .opencode/specs/, only references returned)

**Separation of Concerns**:
- **Command Layer** (`.opencode/command/task.md`): Input parsing, validation, routing decision
- **Orchestration Layer** (`.opencode/agent/subagents/batch-task-orchestrator.md`): Workflow coordination, wave execution, result aggregation
- **Specialist Layer** (`.opencode/agent/subagents/specialists/`): Dependency analysis, status management

**Maintainability**:
- Each component has single, well-defined responsibility
- Easy to test components in isolation
- Easy to extend (e.g., add priority-based scheduling, resource limits)
- Clear error boundaries and recovery strategies

**Reusability**:
- batch-task-orchestrator can be invoked by other commands (future `/batch` command)
- task-dependency-analyzer can be used for project planning
- batch-status-manager can be used for bulk TODO.md operations

---

## Complexity Assessment

**Level**: Complex

**Estimated Effort**: 18-25 hours
- Dependency analyzer specialist: 4-6 hours
- Batch status manager specialist: 3-4 hours
- Batch task orchestrator: 6-8 hours
- Command modification: 2-3 hours
- Testing and integration: 3-4 hours

**Required Knowledge Areas**:
- Graph algorithms (topological sort, cycle detection)
- Concurrent execution patterns
- File I/O atomicity and race condition prevention
- TODO.md parsing and manipulation
- XML-optimized agent architecture
- Error propagation and recovery

**Potential Challenges**:
1. **Dependency Graph Construction**: Parsing TODO.md dependencies, handling malformed data
2. **Cycle Detection**: Implementing efficient cycle detection (DFS-based or Tarjan's algorithm)
3. **Parallel Execution**: Managing concurrent task-executor invocations, tracking state
4. **TODO.md Atomicity**: Preventing race conditions during batch updates
5. **Error Propagation**: Handling partial failures, blocking dependent tasks
6. **Progress Reporting**: Real-time updates during parallel execution

---

## Component Design

### 1. Enhanced `/task` Command

**File**: `.opencode/command/task.md`

**Responsibilities**:
- Parse input arguments (single, list, range, mixed)
- Validate task numbers
- Detect batch vs single task execution
- Route to appropriate handler:
  - Single task → task-executor (existing)
  - Multiple tasks → batch-task-orchestrator (new)

**Input Parsing Logic**:
```python
def parse_task_input(args: str) -> List[int]:
    """
    Parse task input into list of task numbers.
    
    Examples:
        "63" → [63]
        "63, 64, 65" → [63, 64, 65]
        "65-67" → [65, 66, 67]
        "63, 65-67, 88" → [63, 65, 66, 67, 88]
    """
    task_numbers = []
    parts = args.split(',')
    
    for part in parts:
        part = part.strip()
        
        if '-' in part:
            # Range: "65-67"
            start, end = part.split('-')
            start, end = int(start.strip()), int(end.strip())
            if start > end:
                raise ValueError(f"Invalid range: {start}-{end}")
            task_numbers.extend(range(start, end + 1))
        else:
            # Single number: "63"
            task_numbers.append(int(part))
    
    return sorted(set(task_numbers))  # Remove duplicates, sort
```

**Routing Decision**:
```python
task_numbers = parse_task_input(args)

if len(task_numbers) == 1:
    # Single task - use existing workflow
    route_to("@subagents/task-executor", task_number=task_numbers[0])
else:
    # Batch execution - use new workflow
    route_to("@subagents/batch-task-orchestrator", task_numbers=task_numbers)
```

**Error Handling**:
- Invalid format → Error message with examples
- Empty input → Error message
- Negative numbers → Error message
- Invalid ranges (start > end) → Error message

---

### 2. Batch Task Orchestrator

**File**: `.opencode/agent/subagents/batch-task-orchestrator.md`

**Responsibilities**:
- Coordinate batch task execution workflow
- Delegate dependency analysis to task-dependency-analyzer
- Execute tasks in waves (parallel within wave, sequential across waves)
- Delegate TODO.md updates to batch-status-manager
- Aggregate results and generate summary report
- Handle errors and partial failures

**Workflow Stages**:

1. **Stage 1: Validate Tasks**
   - Read TODO.md
   - Verify all task numbers exist
   - Check if any tasks are already complete
   - Extract task details (title, dependencies, effort, etc.)

2. **Stage 2: Dependency Analysis**
   - Route to task-dependency-analyzer
   - Receive dependency graph and execution waves
   - Handle cycle detection errors

3. **Stage 3: Mark Tasks IN PROGRESS**
   - Route to batch-status-manager
   - Mark all tasks as IN PROGRESS with timestamps
   - Handle TODO.md update errors gracefully

4. **Stage 4: Execute Waves**
   - For each wave:
     - Execute all tasks in wave in parallel (concurrent task-executor invocations)
     - Wait for wave completion
     - Track successes and failures
     - Update execution state

5. **Stage 5: Mark Completed Tasks**
   - Route to batch-status-manager
   - Mark successfully executed simple tasks as COMPLETE
   - Leave moderate/complex tasks as IN PROGRESS

6. **Stage 6: Generate Summary**
   - Aggregate results across all waves
   - Generate summary report
   - Return to orchestrator

**State Tracking**:
```python
class BatchExecutionState:
    task_numbers: List[int]
    task_details: Dict[int, TaskDetails]
    dependency_graph: DependencyGraph
    execution_waves: List[List[int]]
    
    # Execution tracking
    wave_results: Dict[int, Dict[int, TaskResult]]  # wave_num → task_num → result
    completed_tasks: Set[int]
    failed_tasks: Set[int]
    blocked_tasks: Set[int]
    skipped_tasks: Set[int]
    
    # Timing
    start_time: datetime
    wave_start_times: Dict[int, datetime]
    wave_end_times: Dict[int, datetime]
```

**Parallel Execution Pattern**:
```python
def execute_wave(wave_tasks: List[int]) -> Dict[int, TaskResult]:
    """Execute all tasks in wave in parallel."""
    results = {}
    
    # Launch all tasks concurrently
    task_sessions = []
    for task_num in wave_tasks:
        session_id = f"batch_task_{task_num}_{timestamp}"
        task_sessions.append({
            'task_num': task_num,
            'session_id': session_id,
            'agent': launch_task_executor(task_num, session_id)
        })
    
    # Wait for all to complete
    for session in task_sessions:
        result = wait_for_completion(session['agent'])
        results[session['task_num']] = result
    
    return results
```

---

### 3. Task Dependency Analyzer Specialist

**File**: `.opencode/agent/subagents/specialists/task-dependency-analyzer.md`

**Responsibilities**:
- Parse TODO.md to extract task dependencies
- Build directed acyclic graph (DAG) of dependencies
- Detect circular dependencies
- Perform topological sort to group tasks into execution waves
- Return dependency graph and execution waves

**Input**:
- List of task numbers to analyze
- TODO.md content

**Output**:
```python
{
    "dependency_graph": {
        "nodes": [63, 64, 65, 66, 67],
        "edges": [
            {"from": 63, "to": 64},  # 64 depends on 63
            {"from": 63, "to": 65},  # 65 depends on 63
            {"from": 64, "to": 66},  # 66 depends on 64
        ]
    },
    "execution_waves": [
        [63],        # Wave 1: No dependencies
        [64, 65],    # Wave 2: Depend only on Wave 1
        [66, 67]     # Wave 3: Depend on Waves 1-2
    ],
    "circular_dependencies": [],  # Empty if no cycles
    "status": "success"
}
```

**Dependency Parsing**:
```python
def parse_task_dependencies(todo_content: str, task_num: int) -> List[int]:
    """
    Parse dependencies from TODO.md task section.
    
    Looks for:
        **Dependencies**: 63, 64
        **Dependencies**: None
        **Blocking**: 65, 66
    """
    # Find task section
    task_section = extract_task_section(todo_content, task_num)
    
    # Parse dependencies field
    dependencies = []
    for line in task_section.split('\n'):
        if line.startswith('**Dependencies**:'):
            dep_str = line.split(':', 1)[1].strip()
            if dep_str.lower() != 'none':
                # Parse comma-separated numbers
                dependencies = [int(d.strip()) for d in dep_str.split(',')]
    
    return dependencies
```

**Graph Construction**:
```python
def build_dependency_graph(task_numbers: List[int], todo_content: str) -> DependencyGraph:
    """Build directed graph of task dependencies."""
    graph = DependencyGraph()
    
    for task_num in task_numbers:
        graph.add_node(task_num)
        dependencies = parse_task_dependencies(todo_content, task_num)
        
        for dep in dependencies:
            if dep in task_numbers:
                # Add edge: dep → task_num (task_num depends on dep)
                graph.add_edge(dep, task_num)
    
    return graph
```

**Cycle Detection** (DFS-based):
```python
def detect_cycles(graph: DependencyGraph) -> List[List[int]]:
    """
    Detect circular dependencies using DFS.
    
    Returns list of cycles (each cycle is a list of task numbers).
    """
    WHITE, GRAY, BLACK = 0, 1, 2
    color = {node: WHITE for node in graph.nodes}
    parent = {node: None for node in graph.nodes}
    cycles = []
    
    def dfs(node):
        color[node] = GRAY
        
        for neighbor in graph.neighbors(node):
            if color[neighbor] == GRAY:
                # Back edge found - cycle detected
                cycle = extract_cycle(parent, node, neighbor)
                cycles.append(cycle)
            elif color[neighbor] == WHITE:
                parent[neighbor] = node
                dfs(neighbor)
        
        color[node] = BLACK
    
    for node in graph.nodes:
        if color[node] == WHITE:
            dfs(node)
    
    return cycles

def extract_cycle(parent, start, end):
    """Extract cycle path from parent pointers."""
    cycle = [end]
    current = start
    while current != end:
        cycle.append(current)
        current = parent[current]
    cycle.reverse()
    return cycle
```

**Topological Sort** (Kahn's Algorithm):
```python
def topological_sort_waves(graph: DependencyGraph) -> List[List[int]]:
    """
    Perform topological sort and group into execution waves.
    
    Wave 1: Nodes with in-degree 0 (no dependencies)
    Wave 2: Nodes with dependencies only in Wave 1
    Wave N: Nodes with dependencies only in Waves 1..N-1
    """
    # Calculate in-degrees
    in_degree = {node: 0 for node in graph.nodes}
    for node in graph.nodes:
        for neighbor in graph.neighbors(node):
            in_degree[neighbor] += 1
    
    # Initialize waves
    waves = []
    remaining = set(graph.nodes)
    
    while remaining:
        # Find all nodes with in-degree 0 in remaining set
        wave = [node for node in remaining if in_degree[node] == 0]
        
        if not wave:
            # No nodes with in-degree 0 - cycle exists
            raise CyclicDependencyError(f"Circular dependency detected in: {remaining}")
        
        waves.append(sorted(wave))
        
        # Remove wave nodes and update in-degrees
        for node in wave:
            remaining.remove(node)
            for neighbor in graph.neighbors(node):
                in_degree[neighbor] -= 1
    
    return waves
```

**Alternative: DFS-based Topological Sort**:
```python
def topological_sort_dfs(graph: DependencyGraph) -> List[int]:
    """
    DFS-based topological sort (returns linear order, not waves).
    Can be converted to waves by calculating depths.
    """
    visited = set()
    stack = []
    
    def dfs(node):
        visited.add(node)
        for neighbor in graph.neighbors(node):
            if neighbor not in visited:
                dfs(neighbor)
        stack.append(node)
    
    for node in graph.nodes:
        if node not in visited:
            dfs(node)
    
    return stack[::-1]  # Reverse to get topological order

def convert_to_waves(graph: DependencyGraph, topo_order: List[int]) -> List[List[int]]:
    """Convert linear topological order to waves based on depth."""
    depth = {node: 0 for node in graph.nodes}
    
    for node in topo_order:
        for neighbor in graph.neighbors(node):
            depth[neighbor] = max(depth[neighbor], depth[node] + 1)
    
    # Group by depth
    max_depth = max(depth.values())
    waves = [[] for _ in range(max_depth + 1)]
    for node in graph.nodes:
        waves[depth[node]].append(node)
    
    return [sorted(wave) for wave in waves if wave]
```

---

### 4. Batch Status Manager Specialist

**File**: `.opencode/agent/subagents/specialists/batch-status-manager.md`

**Responsibilities**:
- Perform atomic batch updates to TODO.md
- Mark multiple tasks IN PROGRESS at once
- Mark multiple tasks COMPLETE at once
- Prevent race conditions
- Handle partial update failures gracefully

**Input**:
```python
{
    "operation": "mark_in_progress" | "mark_complete",
    "tasks": [
        {"task_num": 63, "timestamp": "2025-12-19"},
        {"task_num": 64, "timestamp": "2025-12-19"},
        {"task_num": 65, "timestamp": "2025-12-19"}
    ]
}
```

**Output**:
```python
{
    "status": "success" | "partial" | "error",
    "updated_tasks": [63, 64, 65],
    "failed_tasks": [],
    "errors": []
}
```

**Atomic Update Strategy**:
```python
def batch_update_todo(operation: str, tasks: List[TaskUpdate]) -> BatchUpdateResult:
    """
    Perform atomic batch update to TODO.md.
    
    Strategy:
    1. Read entire TODO.md into memory
    2. Make all updates in memory
    3. Write entire file back in single operation
    4. No partial writes
    """
    # Read TODO.md
    todo_content = read_file(".opencode/specs/TODO.md")
    
    # Make all updates in memory
    updated_content = todo_content
    updated_tasks = []
    failed_tasks = []
    
    for task_update in tasks:
        try:
            updated_content = update_task_status(
                updated_content,
                task_update.task_num,
                operation,
                task_update.timestamp
            )
            updated_tasks.append(task_update.task_num)
        except Exception as e:
            failed_tasks.append({
                'task_num': task_update.task_num,
                'error': str(e)
            })
    
    # Write entire file back atomically
    if updated_tasks:
        write_file(".opencode/specs/TODO.md", updated_content)
    
    return BatchUpdateResult(
        status="success" if not failed_tasks else "partial",
        updated_tasks=updated_tasks,
        failed_tasks=failed_tasks
    )
```

**Update Task Status**:
```python
def update_task_status(content: str, task_num: int, operation: str, timestamp: str) -> str:
    """
    Update single task status in TODO.md content.
    
    Returns updated content (does not write to file).
    """
    # Find task section
    task_start = find_task_section_start(content, task_num)
    task_end = find_task_section_end(content, task_start)
    task_section = content[task_start:task_end]
    
    # Update status based on operation
    if operation == "mark_in_progress":
        updated_section = task_section.replace(
            "**Status**: Not Started",
            f"**Status**: [IN PROGRESS]\n**Started**: {timestamp}"
        )
    elif operation == "mark_complete":
        updated_section = task_section.replace(
            "**Status**: [IN PROGRESS]",
            "**Status**: [COMPLETE]"
        )
        # Add completion timestamp after Started line
        updated_section = add_completion_timestamp(updated_section, timestamp)
        # Add ✅ to title
        updated_section = add_checkmark_to_title(updated_section)
    
    # Replace in content
    updated_content = content[:task_start] + updated_section + content[task_end:]
    return updated_content
```

**Race Condition Prevention**:
- Single atomic write operation (read entire file, update in memory, write entire file)
- No concurrent writes (orchestrator serializes TODO.md updates)
- File locking (optional, if supported by filesystem)
- Retry logic with exponential backoff (if write fails)

**Error Recovery**:
```python
def batch_update_with_retry(operation: str, tasks: List[TaskUpdate], max_retries: int = 3) -> BatchUpdateResult:
    """Batch update with retry logic."""
    for attempt in range(max_retries):
        try:
            return batch_update_todo(operation, tasks)
        except FileWriteError as e:
            if attempt < max_retries - 1:
                sleep(2 ** attempt)  # Exponential backoff
                continue
            else:
                return BatchUpdateResult(
                    status="error",
                    updated_tasks=[],
                    failed_tasks=[t.task_num for t in tasks],
                    errors=[str(e)]
                )
```

---

## Dependency Analysis Algorithm

### Algorithm Choice: Kahn's Algorithm (Recommended)

**Rationale**:
- Simpler to implement than DFS-based approach
- Naturally produces waves (BFS-like traversal)
- Easy to detect cycles (remaining nodes with in-degree > 0)
- Efficient: O(V + E) time complexity
- Clear error messages for cycles

### Detailed Algorithm

**Input**:
- Task numbers: `[63, 64, 65, 66, 67, 88]`
- TODO.md content

**Step 1: Parse Dependencies**
```
Task 63: Dependencies: None
Task 64: Dependencies: 63
Task 65: Dependencies: 63
Task 66: Dependencies: 64
Task 67: Dependencies: 65
Task 88: Dependencies: None
```

**Step 2: Build Dependency Graph**
```
Nodes: {63, 64, 65, 66, 67, 88}
Edges: {
    63 → 64,  # 64 depends on 63
    63 → 65,  # 65 depends on 63
    64 → 66,  # 66 depends on 64
    65 → 67   # 67 depends on 65
}
```

**Step 3: Calculate In-Degrees**
```
in_degree = {
    63: 0,  # No dependencies
    64: 1,  # Depends on 63
    65: 1,  # Depends on 63
    66: 1,  # Depends on 64
    67: 1,  # Depends on 65
    88: 0   # No dependencies
}
```

**Step 4: Kahn's Algorithm - Wave 1**
```
Wave 1: Nodes with in_degree = 0
    → [63, 88]

Remove 63, 88 from graph, update in-degrees:
    in_degree[64] = 0  # 63 removed
    in_degree[65] = 0  # 63 removed
    in_degree[66] = 1  # Still depends on 64
    in_degree[67] = 1  # Still depends on 65
```

**Step 5: Kahn's Algorithm - Wave 2**
```
Wave 2: Nodes with in_degree = 0
    → [64, 65]

Remove 64, 65 from graph, update in-degrees:
    in_degree[66] = 0  # 64 removed
    in_degree[67] = 0  # 65 removed
```

**Step 6: Kahn's Algorithm - Wave 3**
```
Wave 3: Nodes with in_degree = 0
    → [66, 67]

All nodes processed.
```

**Output**:
```python
{
    "execution_waves": [
        [63, 88],    # Wave 1: Execute in parallel
        [64, 65],    # Wave 2: Execute in parallel (after Wave 1)
        [66, 67]     # Wave 3: Execute in parallel (after Wave 2)
    ],
    "dependency_graph": {
        "nodes": [63, 64, 65, 66, 67, 88],
        "edges": [
            {"from": 63, "to": 64},
            {"from": 63, "to": 65},
            {"from": 64, "to": 66},
            {"from": 65, "to": 67}
        ]
    },
    "circular_dependencies": [],
    "status": "success"
}
```

### Cycle Detection Example

**Input**:
```
Task 63: Dependencies: 65
Task 64: Dependencies: 63
Task 65: Dependencies: 64
```

**Graph**:
```
63 → 64 → 65 → 63  (cycle!)
```

**Kahn's Algorithm Execution**:
```
in_degree = {63: 1, 64: 1, 65: 1}

Wave 1: No nodes with in_degree = 0
    → Error: Circular dependency detected
```

**Cycle Extraction** (using DFS):
```python
def find_cycle_path(graph: DependencyGraph) -> List[int]:
    """Find one cycle in graph using DFS."""
    visited = set()
    rec_stack = set()
    parent = {}
    
    def dfs(node, path):
        visited.add(node)
        rec_stack.add(node)
        
        for neighbor in graph.neighbors(node):
            if neighbor not in visited:
                parent[neighbor] = node
                cycle = dfs(neighbor, path + [neighbor])
                if cycle:
                    return cycle
            elif neighbor in rec_stack:
                # Cycle found
                cycle_path = [neighbor]
                current = node
                while current != neighbor:
                    cycle_path.append(current)
                    current = parent[current]
                return cycle_path[::-1]
        
        rec_stack.remove(node)
        return None
    
    for node in graph.nodes:
        if node not in visited:
            cycle = dfs(node, [node])
            if cycle:
                return cycle
    
    return None
```

**Output**:
```python
{
    "status": "error",
    "error": "Circular dependency detected",
    "circular_dependencies": [
        [63, 64, 65, 63]  # Cycle path
    ],
    "message": "Tasks 63, 64, 65 form a circular dependency. Please resolve dependencies before batch execution."
}
```

---

## Parallel Execution Strategy

### Wave-Based Parallel Execution

**Concept**:
- Execute all tasks in a wave concurrently (parallel)
- Wait for entire wave to complete before starting next wave
- Track execution state for each task
- Handle failures gracefully

### Implementation Approach

**Option 1: Concurrent Task Agent Invocations** ⭐ **RECOMMENDED**

Use the existing `task` tool with session IDs to launch multiple task-executor agents concurrently:

```python
def execute_wave_parallel(wave_tasks: List[int]) -> Dict[int, TaskResult]:
    """
    Execute all tasks in wave in parallel using concurrent task agent invocations.
    """
    results = {}
    sessions = []
    
    # Launch all tasks concurrently
    for task_num in wave_tasks:
        session_id = f"batch_wave_{wave_num}_task_{task_num}_{timestamp()}"
        
        # Launch task-executor agent with session ID
        agent = task_agent.invoke(
            description=f"Execute task {task_num}",
            prompt=f"Execute task {task_num} from TODO.md",
            subagent_type="subagents/task-executor",
            session_id=session_id
        )
        
        sessions.append({
            'task_num': task_num,
            'session_id': session_id,
            'agent': agent,
            'start_time': datetime.now()
        })
    
    # Wait for all to complete
    for session in sessions:
        try:
            result = session['agent'].wait_for_completion(timeout=3600)  # 1 hour timeout
            results[session['task_num']] = TaskResult(
                task_num=session['task_num'],
                status='success',
                result=result,
                duration=datetime.now() - session['start_time']
            )
        except TimeoutError:
            results[session['task_num']] = TaskResult(
                task_num=session['task_num'],
                status='timeout',
                error='Task execution exceeded 1 hour timeout',
                duration=datetime.now() - session['start_time']
            )
        except Exception as e:
            results[session['task_num']] = TaskResult(
                task_num=session['task_num'],
                status='error',
                error=str(e),
                duration=datetime.now() - session['start_time']
            )
    
    return results
```

**Advantages**:
- Uses existing task-executor infrastructure
- Natural parallelism (each task gets own agent instance)
- Session IDs provide isolation and tracking
- Timeout handling prevents hanging
- Error isolation (one task failure doesn't affect others)

**Disadvantages**:
- Resource intensive (multiple concurrent agents)
- May hit system resource limits (need to add concurrency limit)

**Concurrency Limiting**:
```python
MAX_CONCURRENT_TASKS = 5  # Configurable limit

def execute_wave_with_limit(wave_tasks: List[int], max_concurrent: int = MAX_CONCURRENT_TASKS) -> Dict[int, TaskResult]:
    """
    Execute wave with concurrency limit.
    
    If wave has more tasks than limit, execute in batches.
    """
    results = {}
    
    # Split wave into batches
    batches = [wave_tasks[i:i+max_concurrent] for i in range(0, len(wave_tasks), max_concurrent)]
    
    for batch in batches:
        batch_results = execute_wave_parallel(batch)
        results.update(batch_results)
    
    return results
```

### State Tracking During Execution

**Execution State**:
```python
class WaveExecutionState:
    wave_num: int
    tasks: List[int]
    start_time: datetime
    end_time: Optional[datetime]
    
    # Task states
    running: Set[int]
    completed: Set[int]
    failed: Set[int]
    
    # Results
    results: Dict[int, TaskResult]
    
    def is_complete(self) -> bool:
        return len(self.completed) + len(self.failed) == len(self.tasks)
    
    def success_rate(self) -> float:
        total = len(self.completed) + len(self.failed)
        return len(self.completed) / total if total > 0 else 0.0
```

**Progress Reporting**:
```python
def report_wave_progress(wave_state: WaveExecutionState) -> str:
    """Generate progress report for wave."""
    total = len(wave_state.tasks)
    completed = len(wave_state.completed)
    failed = len(wave_state.failed)
    running = len(wave_state.running)
    
    return f"""
Wave {wave_state.wave_num} Progress:
  Total Tasks: {total}
  Running: {running}
  Completed: {completed} ({completed/total*100:.1f}%)
  Failed: {failed} ({failed/total*100:.1f}%)
  
  Tasks:
    Running: {sorted(wave_state.running)}
    Completed: {sorted(wave_state.completed)}
    Failed: {sorted(wave_state.failed)}
"""
```

### Error Handling During Parallel Execution

**Failure Scenarios**:
1. **Task execution fails**: Mark task as failed, continue with other tasks
2. **Task times out**: Mark task as timeout, continue with other tasks
3. **Agent crash**: Mark task as error, continue with other tasks
4. **System resource exhaustion**: Reduce concurrency, retry

**Failure Propagation**:
```python
def handle_task_failure(task_num: int, error: str, dependency_graph: DependencyGraph) -> Set[int]:
    """
    Handle task failure and identify blocked tasks.
    
    Returns set of task numbers that are now blocked.
    """
    blocked_tasks = set()
    
    # Find all tasks that depend on failed task
    for node in dependency_graph.nodes:
        if dependency_graph.has_path(task_num, node):
            blocked_tasks.add(node)
    
    return blocked_tasks
```

**Wave Execution with Failure Handling**:
```python
def execute_wave_with_error_handling(
    wave_tasks: List[int],
    failed_tasks: Set[int],
    dependency_graph: DependencyGraph
) -> Tuple[Dict[int, TaskResult], Set[int]]:
    """
    Execute wave with error handling.
    
    Returns:
        - Task results
        - Set of newly blocked tasks
    """
    # Filter out tasks blocked by previous failures
    executable_tasks = [
        task for task in wave_tasks
        if not is_blocked_by_failed_task(task, failed_tasks, dependency_graph)
    ]
    
    skipped_tasks = set(wave_tasks) - set(executable_tasks)
    
    # Execute executable tasks
    results = execute_wave_parallel(executable_tasks)
    
    # Add skipped tasks to results
    for task in skipped_tasks:
        results[task] = TaskResult(
            task_num=task,
            status='skipped',
            error=f'Blocked by failed dependencies: {get_blocking_tasks(task, failed_tasks, dependency_graph)}'
        )
    
    # Identify newly blocked tasks
    newly_blocked = set()
    for task_num, result in results.items():
        if result.status in ['error', 'timeout', 'failed']:
            blocked = handle_task_failure(task_num, result.error, dependency_graph)
            newly_blocked.update(blocked)
    
    return results, newly_blocked
```

---

## TODO.md Update Strategy

### Atomic Update Approach

**Goal**: Prevent race conditions and ensure consistency when updating TODO.md during batch execution.

**Strategy**: Single Atomic Write

1. **Read entire TODO.md into memory**
2. **Make all updates in memory** (no partial writes)
3. **Write entire file back in single operation**
4. **Verify write success**

### Update Timing

**Option 1: Batch Updates Per Wave** ⭐ **RECOMMENDED**
- Mark all tasks in wave IN PROGRESS at wave start
- Mark all completed tasks COMPLETE at wave end
- Fewer file writes (2 per wave)
- Better atomicity

**Option 2: Individual Updates Per Task**
- Mark each task IN PROGRESS when it starts
- Mark each task COMPLETE when it finishes
- More file writes (2 per task)
- More granular tracking
- Higher risk of race conditions

**Recommendation**: Option 1 (Batch Updates Per Wave)

### Implementation

**Wave Start - Mark IN PROGRESS**:
```python
def mark_wave_in_progress(wave_tasks: List[int], timestamp: str) -> BatchUpdateResult:
    """Mark all tasks in wave as IN PROGRESS."""
    updates = [
        TaskUpdate(task_num=task, timestamp=timestamp)
        for task in wave_tasks
    ]
    
    return batch_status_manager.mark_in_progress(updates)
```

**Wave End - Mark COMPLETE**:
```python
def mark_wave_complete(completed_tasks: List[int], timestamp: str) -> BatchUpdateResult:
    """
    Mark completed tasks as COMPLETE.
    
    Only marks simple tasks that were executed directly.
    Moderate/complex tasks remain IN PROGRESS.
    """
    updates = [
        TaskUpdate(task_num=task, timestamp=timestamp)
        for task in completed_tasks
        if task_was_executed_directly(task)  # Simple tasks only
    ]
    
    return batch_status_manager.mark_complete(updates)
```

### Race Condition Prevention

**Serialization**: Orchestrator serializes TODO.md updates
```python
class BatchTaskOrchestrator:
    _todo_update_lock = threading.Lock()
    
    def update_todo_atomic(self, operation: str, tasks: List[TaskUpdate]) -> BatchUpdateResult:
        """Atomic TODO.md update with lock."""
        with self._todo_update_lock:
            return batch_status_manager.update(operation, tasks)
```

**File Locking** (optional, filesystem-dependent):
```python
import fcntl

def write_todo_with_lock(content: str, filepath: str):
    """Write TODO.md with file lock."""
    with open(filepath, 'w') as f:
        # Acquire exclusive lock
        fcntl.flock(f.fileno(), fcntl.LOCK_EX)
        try:
            f.write(content)
            f.flush()
            os.fsync(f.fileno())  # Force write to disk
        finally:
            # Release lock
            fcntl.flock(f.fileno(), fcntl.LOCK_UN)
```

**Retry Logic**:
```python
def write_with_retry(content: str, filepath: str, max_retries: int = 3) -> bool:
    """Write with exponential backoff retry."""
    for attempt in range(max_retries):
        try:
            write_todo_with_lock(content, filepath)
            return True
        except IOError as e:
            if attempt < max_retries - 1:
                sleep(2 ** attempt)  # Exponential backoff: 1s, 2s, 4s
                continue
            else:
                raise
    return False
```

### Partial Update Handling

**Scenario**: Some tasks update successfully, others fail

**Strategy**: Best-effort with detailed reporting
```python
def batch_update_with_partial_handling(
    operation: str,
    tasks: List[TaskUpdate]
) -> BatchUpdateResult:
    """
    Batch update with partial failure handling.
    
    If some tasks fail to update, still update the successful ones.
    """
    # Read TODO.md
    todo_content = read_file(".opencode/specs/TODO.md")
    
    # Try to update each task
    updated_content = todo_content
    successful_updates = []
    failed_updates = []
    
    for task_update in tasks:
        try:
            updated_content = update_task_status(
                updated_content,
                task_update.task_num,
                operation,
                task_update.timestamp
            )
            successful_updates.append(task_update.task_num)
        except TaskNotFoundError as e:
            failed_updates.append({
                'task_num': task_update.task_num,
                'error': f'Task not found: {e}'
            })
        except Exception as e:
            failed_updates.append({
                'task_num': task_update.task_num,
                'error': str(e)
            })
    
    # Write updated content if any updates succeeded
    if successful_updates:
        write_with_retry(updated_content, ".opencode/specs/TODO.md")
    
    return BatchUpdateResult(
        status='success' if not failed_updates else 'partial',
        updated_tasks=successful_updates,
        failed_tasks=[u['task_num'] for u in failed_updates],
        errors=failed_updates
    )
```

---

## Error Handling Strategy

### Error Types and Handling

**1. Input Validation Errors**

**Error**: Invalid task input format
```
Input: "/task 63-"
Error: "Invalid range format: '63-'. Expected format: 'start-end' (e.g., '65-67')"
```

**Handling**:
- Validate input format before processing
- Provide clear error message with examples
- Suggest correct format

**Error**: Invalid range (start > end)
```
Input: "/task 67-65"
Error: "Invalid range: 67-65. Start must be less than or equal to end."
```

**Handling**:
- Validate range bounds
- Provide clear error message
- Suggest correction

---

**2. Task Not Found Errors**

**Error**: Task number doesn't exist in TODO.md
```
Input: "/task 63, 999, 65"
Error: "Task 999 not found in TODO.md"
```

**Handling**:
- Skip missing tasks
- Log warning
- Continue with valid tasks
- Report skipped tasks in summary

```python
def handle_missing_tasks(task_numbers: List[int], todo_content: str) -> Tuple[List[int], List[int]]:
    """
    Separate valid and missing tasks.
    
    Returns:
        - List of valid task numbers
        - List of missing task numbers
    """
    valid_tasks = []
    missing_tasks = []
    
    for task_num in task_numbers:
        if task_exists_in_todo(task_num, todo_content):
            valid_tasks.append(task_num)
        else:
            missing_tasks.append(task_num)
    
    if missing_tasks:
        log_warning(f"Tasks not found in TODO.md: {missing_tasks}")
    
    return valid_tasks, missing_tasks
```

---

**3. Task Already Complete Errors**

**Error**: Task is already marked complete
```
Input: "/task 63, 64, 65"
Task 64 status: [COMPLETE] ✅
```

**Handling**:
- Skip completed tasks
- Log info message
- Continue with incomplete tasks
- Report skipped tasks in summary

```python
def filter_incomplete_tasks(task_numbers: List[int], todo_content: str) -> Tuple[List[int], List[int]]:
    """
    Filter out already completed tasks.
    
    Returns:
        - List of incomplete task numbers
        - List of already complete task numbers
    """
    incomplete_tasks = []
    complete_tasks = []
    
    for task_num in task_numbers:
        status = get_task_status(task_num, todo_content)
        if status in ['Complete', '[COMPLETE]'] or '✅' in status:
            complete_tasks.append(task_num)
        else:
            incomplete_tasks.append(task_num)
    
    if complete_tasks:
        log_info(f"Tasks already complete (skipping): {complete_tasks}")
    
    return incomplete_tasks, complete_tasks
```

---

**4. Circular Dependency Errors**

**Error**: Circular dependency detected
```
Tasks: 63, 64, 65
Dependencies:
  63 → 64
  64 → 65
  65 → 63  (cycle!)
```

**Handling**:
- Detect cycle during dependency analysis
- Abort batch execution
- Show cycle path clearly
- Suggest resolution

```python
def handle_circular_dependency(cycles: List[List[int]]) -> None:
    """
    Handle circular dependency error.
    
    Aborts batch execution and provides clear error message.
    """
    error_msg = "Circular dependency detected in task dependencies:\n\n"
    
    for i, cycle in enumerate(cycles, 1):
        cycle_path = " → ".join(str(t) for t in cycle)
        error_msg += f"  Cycle {i}: {cycle_path}\n"
    
    error_msg += "\nPlease resolve circular dependencies before batch execution.\n"
    error_msg += "Suggestions:\n"
    error_msg += "  1. Remove one dependency from the cycle\n"
    error_msg += "  2. Split tasks to break the cycle\n"
    error_msg += "  3. Execute tasks individually in correct order\n"
    
    raise CircularDependencyError(error_msg)
```

---

**5. Task Execution Failures**

**Error**: Task execution fails during processing
```
Task 64 execution failed: "File not found: Logos/Core/Missing.lean"
```

**Handling**:
- Mark task as failed
- Block dependent tasks
- Continue with independent tasks
- Report failure in summary

```python
def handle_task_execution_failure(
    task_num: int,
    error: str,
    dependency_graph: DependencyGraph,
    remaining_waves: List[List[int]]
) -> Set[int]:
    """
    Handle task execution failure.
    
    Returns set of blocked task numbers.
    """
    # Mark task as failed
    log_error(f"Task {task_num} failed: {error}")
    
    # Find all dependent tasks
    blocked_tasks = set()
    for wave in remaining_waves:
        for task in wave:
            if dependency_graph.has_path(task_num, task):
                blocked_tasks.add(task)
                log_warning(f"Task {task} blocked by failed task {task_num}")
    
    return blocked_tasks
```

---

**6. TODO.md Update Failures**

**Error**: Cannot write to TODO.md
```
Error: "Permission denied: .opencode/specs/TODO.md"
```

**Handling**:
- Retry with exponential backoff
- Log error if all retries fail
- Continue with task execution (graceful degradation)
- Report update failure in summary

```python
def handle_todo_update_failure(error: Exception, tasks: List[int]) -> None:
    """
    Handle TODO.md update failure.
    
    Logs error but allows task execution to continue.
    """
    log_error(f"Failed to update TODO.md: {error}")
    log_error(f"Affected tasks: {tasks}")
    log_warning("Task execution will continue, but TODO.md status may be out of sync")
    log_warning("Please manually update TODO.md after batch execution completes")
```

---

**7. Timeout Errors**

**Error**: Task execution exceeds timeout
```
Task 65 execution timeout: Exceeded 1 hour limit
```

**Handling**:
- Mark task as timeout
- Block dependent tasks
- Continue with independent tasks
- Report timeout in summary

```python
def handle_task_timeout(
    task_num: int,
    timeout_duration: int,
    dependency_graph: DependencyGraph
) -> Set[int]:
    """
    Handle task execution timeout.
    
    Returns set of blocked task numbers.
    """
    log_error(f"Task {task_num} timed out after {timeout_duration} seconds")
    
    # Treat timeout as failure - block dependent tasks
    blocked_tasks = set()
    for node in dependency_graph.nodes:
        if dependency_graph.has_path(task_num, node):
            blocked_tasks.add(node)
    
    return blocked_tasks
```

---

### Error Summary Reporting

**Final Summary Format**:
```
Batch Execution Summary
=======================

Total Tasks: 8
Completed: 5 (62.5%)
Failed: 1 (12.5%)
Blocked: 1 (12.5%)
Skipped: 1 (12.5%)

Wave Execution:
  Wave 1 (2 tasks): ✓ 2 completed
  Wave 2 (3 tasks): ✓ 2 completed, ✗ 1 failed
  Wave 3 (2 tasks): ⊘ 1 blocked, ✓ 1 completed
  Wave 4 (1 task): ⊘ 1 skipped (already complete)

Completed Tasks:
  ✓ Task 63: Add Missing Directory READMEs
  ✓ Task 64: Create Example-Builder Specialist
  ✓ Task 65: Populate context/logic/processes/
  ✓ Task 66: Populate context/logic/standards/
  ✓ Task 88: Update IMPLEMENTATION_STATUS.md

Failed Tasks:
  ✗ Task 67: Populate context/logic/templates/
    Error: File not found: context/logic/templates/template.md
    
Blocked Tasks:
  ⊘ Task 68: Populate context/logic/patterns/
    Reason: Blocked by failed task 67

Skipped Tasks:
  ⊘ Task 70: Populate context/math/analysis/
    Reason: Already complete

Warnings:
  - TODO.md update failed for tasks [67, 68] - please update manually

Recommendations:
  1. Fix error in Task 67 and re-run: /task 67
  2. After fixing Task 67, run blocked task: /task 68
  3. Manually update TODO.md status for tasks [67, 68]

Total Duration: 2h 15m
Average Task Duration: 16m 52s
```

---

## Implementation Steps

### Phase 1: Foundation (6-8 hours)

**Step 1: Create Task Dependency Analyzer Specialist** (4-6 hours)

**Action**: Implement dependency graph construction and topological sort

**File**: `.opencode/agent/subagents/specialists/task-dependency-analyzer.md`

**Tasks**:
1. Create specialist agent file with XML structure
2. Implement TODO.md dependency parsing
3. Implement dependency graph construction
4. Implement cycle detection (DFS-based)
5. Implement topological sort (Kahn's algorithm)
6. Implement wave grouping
7. Add error handling and validation
8. Write comprehensive docstrings

**Verification**:
- [ ] Parse dependencies from TODO.md correctly
- [ ] Build dependency graph with correct edges
- [ ] Detect circular dependencies
- [ ] Perform topological sort correctly
- [ ] Group tasks into execution waves
- [ ] Handle edge cases (no dependencies, all dependencies, etc.)

**Test Cases**:
```python
# Test 1: Simple linear dependencies
Tasks: [1, 2, 3]
Dependencies: 1→2→3
Expected Waves: [[1], [2], [3]]

# Test 2: Parallel tasks
Tasks: [1, 2, 3, 4]
Dependencies: 1→3, 2→4
Expected Waves: [[1, 2], [3, 4]]

# Test 3: Diamond dependency
Tasks: [1, 2, 3, 4]
Dependencies: 1→2, 1→3, 2→4, 3→4
Expected Waves: [[1], [2, 3], [4]]

# Test 4: Circular dependency
Tasks: [1, 2, 3]
Dependencies: 1→2→3→1
Expected: CircularDependencyError

# Test 5: No dependencies
Tasks: [1, 2, 3]
Dependencies: None
Expected Waves: [[1, 2, 3]]
```

---

**Step 2: Create Batch Status Manager Specialist** (3-4 hours)

**Action**: Implement atomic TODO.md batch updates

**File**: `.opencode/agent/subagents/specialists/batch-status-manager.md`

**Tasks**:
1. Create specialist agent file with XML structure
2. Implement TODO.md reading and parsing
3. Implement batch status update logic
4. Implement atomic write strategy
5. Add retry logic with exponential backoff
6. Add partial update handling
7. Write comprehensive docstrings

**Verification**:
- [ ] Read TODO.md correctly
- [ ] Parse task sections accurately
- [ ] Update multiple task statuses in memory
- [ ] Write entire file atomically
- [ ] Handle partial update failures
- [ ] Retry on write failures
- [ ] Preserve TODO.md formatting

**Test Cases**:
```python
# Test 1: Mark multiple tasks IN PROGRESS
Tasks: [63, 64, 65]
Operation: mark_in_progress
Expected: All tasks marked [IN PROGRESS] with timestamps

# Test 2: Mark multiple tasks COMPLETE
Tasks: [63, 64, 65]
Operation: mark_complete
Expected: All tasks marked [COMPLETE] with completion timestamps

# Test 3: Partial update (some tasks not found)
Tasks: [63, 999, 65]
Operation: mark_in_progress
Expected: Tasks 63, 65 updated; Task 999 failed (not found)

# Test 4: Preserve formatting
Operation: mark_in_progress on task 63
Expected: Only status and timestamp changed, all other content preserved

# Test 5: Retry on write failure
Scenario: First write fails, second succeeds
Expected: Successful update after retry
```

---

### Phase 2: Orchestration (6-8 hours)

**Step 3: Create Batch Task Orchestrator** (6-8 hours)

**Action**: Implement batch execution workflow coordination

**File**: `.opencode/agent/subagents/batch-task-orchestrator.md`

**Tasks**:
1. Create orchestrator agent file with XML structure
2. Implement task validation stage
3. Implement dependency analysis routing
4. Implement wave execution logic
5. Implement parallel task execution
6. Implement error handling and recovery
7. Implement progress reporting
8. Implement summary generation
9. Write comprehensive docstrings

**Verification**:
- [ ] Validate all task numbers exist
- [ ] Route to task-dependency-analyzer correctly
- [ ] Execute waves in correct order
- [ ] Execute tasks in parallel within wave
- [ ] Handle task failures gracefully
- [ ] Block dependent tasks on failure
- [ ] Generate accurate summary report

**Test Cases**:
```python
# Test 1: Simple batch execution
Tasks: [63, 64, 65]
Dependencies: None
Expected: All tasks execute in parallel (Wave 1)

# Test 2: Sequential dependencies
Tasks: [63, 64, 65]
Dependencies: 63→64→65
Expected: Wave 1: [63], Wave 2: [64], Wave 3: [65]

# Test 3: Parallel with dependencies
Tasks: [63, 64, 65, 66]
Dependencies: 63→65, 64→66
Expected: Wave 1: [63, 64], Wave 2: [65, 66]

# Test 4: Task failure blocks dependents
Tasks: [63, 64, 65]
Dependencies: 63→64→65
Scenario: Task 64 fails
Expected: Task 63 completes, Task 64 fails, Task 65 blocked

# Test 5: Partial completion
Tasks: [63, 64, 65, 66]
Dependencies: 63→64, 65→66
Scenario: Task 64 fails, Task 66 succeeds
Expected: Tasks 63, 65, 66 complete; Task 64 failed
```

---

### Phase 3: Integration (2-3 hours)

**Step 4: Modify `/task` Command** (2-3 hours)

**Action**: Add batch input parsing and routing

**File**: `.opencode/command/task.md`

**Tasks**:
1. Read existing command file
2. Add input parsing logic (single, list, range, mixed)
3. Add validation logic
4. Add routing decision (single vs batch)
5. Update documentation
6. Add examples

**Verification**:
- [ ] Parse single task correctly: `/task 63`
- [ ] Parse task list correctly: `/task 63, 64, 65`
- [ ] Parse task range correctly: `/task 65-67`
- [ ] Parse mixed format correctly: `/task 63, 65-67, 88`
- [ ] Route single task to task-executor
- [ ] Route multiple tasks to batch-task-orchestrator
- [ ] Handle invalid input gracefully

**Test Cases**:
```python
# Test 1: Single task (existing behavior)
Input: "/task 63"
Expected: Route to task-executor

# Test 2: Task list
Input: "/task 63, 64, 65"
Expected: Route to batch-task-orchestrator with [63, 64, 65]

# Test 3: Task range
Input: "/task 65-67"
Expected: Route to batch-task-orchestrator with [65, 66, 67]

# Test 4: Mixed format
Input: "/task 63, 65-67, 88"
Expected: Route to batch-task-orchestrator with [63, 65, 66, 67, 88]

# Test 5: Invalid format
Input: "/task 63-"
Expected: Error message with examples

# Test 6: Invalid range
Input: "/task 67-65"
Expected: Error message
```

---

### Phase 4: Testing and Documentation (3-4 hours)

**Step 5: Integration Testing** (2-3 hours)

**Action**: Test end-to-end batch execution

**Test Scenarios**:

1. **Simple Batch (No Dependencies)**
   ```
   /task 63, 64, 65
   Expected: All execute in parallel, all complete
   ```

2. **Sequential Dependencies**
   ```
   /task 63, 64, 65
   Dependencies: 63→64→65
   Expected: Wave 1: [63], Wave 2: [64], Wave 3: [65]
   ```

3. **Parallel with Dependencies**
   ```
   /task 63, 64, 65, 66, 67
   Dependencies: 63→65, 63→66, 64→67
   Expected: Wave 1: [63, 64], Wave 2: [65, 66, 67]
   ```

4. **Circular Dependency**
   ```
   /task 63, 64, 65
   Dependencies: 63→64→65→63
   Expected: Error with cycle path
   ```

5. **Task Failure**
   ```
   /task 63, 64, 65, 66
   Dependencies: 63→64→65, 63→66
   Scenario: Task 64 fails
   Expected: 63 completes, 64 fails, 65 blocked, 66 completes
   ```

6. **Mixed Format Input**
   ```
   /task 63, 65-67, 88
   Expected: Parse to [63, 65, 66, 67, 88], execute correctly
   ```

7. **Already Complete Tasks**
   ```
   /task 63, 64, 65
   Scenario: Task 64 already complete
   Expected: Skip 64, execute 63 and 65
   ```

8. **Missing Tasks**
   ```
   /task 63, 999, 65
   Expected: Skip 999, execute 63 and 65, report warning
   ```

**Verification**:
- [ ] All test scenarios pass
- [ ] TODO.md updates are correct
- [ ] Error messages are clear
- [ ] Progress reporting is accurate
- [ ] Summary reports are complete

---

**Step 6: Documentation** (1 hour)

**Action**: Update documentation and examples

**Files to Update**:
1. `.opencode/command/task.md` - Add batch execution examples
2. `.opencode/specs/TODO.md` - Add batch execution usage section
3. `.opencode/QUICK-START.md` - Add batch execution quick start

**Documentation Sections**:

1. **Command Usage**:
   ```markdown
   ## Batch Task Execution
   
   Execute multiple tasks with automatic dependency resolution:
   
   ```bash
   # Execute task list
   /task 63, 64, 65
   
   # Execute task range
   /task 65-67
   
   # Execute mixed format
   /task 63, 65-67, 88
   ```
   
   Features:
   - Automatic dependency analysis
   - Parallel execution within waves
   - Atomic TODO.md status tracking
   - Graceful error handling
   ```

2. **Dependency Format**:
   ```markdown
   ## Task Dependencies in TODO.md
   
   Specify dependencies in task description:
   
   ```markdown
   ### 64. Create Example-Builder Specialist
   **Dependencies**: 63
   
   ### 66. Populate context/logic/standards/
   **Dependencies**: 65
   
   ### 68. Populate context/logic/patterns/
   **Dependencies**: 65, 66, 67
   ```
   
   Batch execution will:
   1. Parse dependencies
   2. Build dependency graph
   3. Detect circular dependencies
   4. Execute in correct order (waves)
   ```

3. **Examples**:
   ```markdown
   ## Batch Execution Examples
   
   ### Example 1: Parallel Execution (No Dependencies)
   
   ```bash
   /task 63, 64, 65
   ```
   
   All tasks execute in parallel (Wave 1).
   
   ### Example 2: Sequential Execution (Linear Dependencies)
   
   ```bash
   /task 63, 64, 65
   ```
   
   Dependencies: 63→64→65
   
   Execution:
   - Wave 1: Task 63
   - Wave 2: Task 64 (after 63 completes)
   - Wave 3: Task 65 (after 64 completes)
   
   ### Example 3: Mixed Parallel and Sequential
   
   ```bash
   /task 63, 64, 65, 66, 67
   ```
   
   Dependencies: 63→65, 63→66, 64→67
   
   Execution:
   - Wave 1: Tasks 63, 64 (parallel)
   - Wave 2: Tasks 65, 66, 67 (parallel, after Wave 1)
   ```

**Verification**:
- [ ] Documentation is clear and comprehensive
- [ ] Examples are accurate and helpful
- [ ] Usage instructions are complete

---

## File Structure

### Files to Create

```
.opencode/
├── agent/
│   └── subagents/
│       ├── batch-task-orchestrator.md          # NEW - Main batch execution orchestrator
│       └── specialists/
│           ├── task-dependency-analyzer.md     # NEW - Dependency graph and topological sort
│           └── batch-status-manager.md         # NEW - Atomic TODO.md batch updates
└── specs/
    └── 072_batch_task_execution/
        ├── plans/
        │   └── implementation-001.md           # THIS FILE
        ├── summaries/
        │   └── plan-summary.md                 # To be created
        └── state.json                          # To be created
```

### Files to Modify

```
.opencode/
├── command/
│   └── task.md                                 # MODIFY - Add batch input parsing and routing
└── specs/
    └── TODO.md                                 # MODIFY (optional) - Add batch execution examples
```

### File Descriptions

**1. `.opencode/agent/subagents/batch-task-orchestrator.md`**
- **Purpose**: Coordinate batch task execution workflow
- **Responsibilities**:
  - Validate task numbers
  - Route to task-dependency-analyzer
  - Execute tasks in waves (parallel within wave)
  - Route to batch-status-manager for TODO.md updates
  - Handle errors and partial failures
  - Generate summary report
- **Size**: ~800-1000 lines (similar to task-executor.md)

**2. `.opencode/agent/subagents/specialists/task-dependency-analyzer.md`**
- **Purpose**: Analyze task dependencies and create execution plan
- **Responsibilities**:
  - Parse TODO.md dependencies
  - Build dependency graph (DAG)
  - Detect circular dependencies
  - Perform topological sort
  - Group tasks into execution waves
- **Size**: ~400-500 lines
- **Algorithms**: DFS cycle detection, Kahn's topological sort

**3. `.opencode/agent/subagents/specialists/batch-status-manager.md`**
- **Purpose**: Manage atomic TODO.md batch updates
- **Responsibilities**:
  - Read TODO.md
  - Batch update task statuses (IN PROGRESS, COMPLETE)
  - Atomic write operations
  - Retry logic with exponential backoff
  - Partial update handling
- **Size**: ~300-400 lines

**4. `.opencode/command/task.md` (MODIFIED)**
- **Changes**:
  - Add input parsing logic (single, list, range, mixed)
  - Add validation logic
  - Add routing decision (single vs batch)
  - Update documentation with batch examples
- **Size**: +100-150 lines

**5. `.opencode/specs/TODO.md` (OPTIONAL MODIFICATION)**
- **Changes**:
  - Add batch execution usage section
  - Add dependency format documentation
  - Add examples
- **Size**: +50-100 lines

---

## Testing Strategy

### Unit Testing

**Component**: Task Dependency Analyzer

**Test Cases**:
1. **Dependency Parsing**
   - Parse single dependency: `**Dependencies**: 63`
   - Parse multiple dependencies: `**Dependencies**: 63, 64, 65`
   - Parse no dependencies: `**Dependencies**: None`
   - Handle malformed dependencies gracefully

2. **Graph Construction**
   - Build graph with correct nodes and edges
   - Handle missing dependencies (tasks not in batch)
   - Handle self-dependencies (error)

3. **Cycle Detection**
   - Detect simple cycle: 1→2→3→1
   - Detect complex cycle: 1→2→3→4→2
   - Handle no cycles (return empty list)
   - Extract correct cycle path

4. **Topological Sort**
   - Linear dependencies: [[1], [2], [3]]
   - Parallel tasks: [[1, 2], [3, 4]]
   - Diamond dependency: [[1], [2, 3], [4]]
   - No dependencies: [[1, 2, 3, 4]]

---

**Component**: Batch Status Manager

**Test Cases**:
1. **TODO.md Reading**
   - Read file correctly
   - Handle file not found
   - Handle permission errors

2. **Task Section Parsing**
   - Find task section by number
   - Extract task details
   - Handle task not found

3. **Status Updates**
   - Mark single task IN PROGRESS
   - Mark multiple tasks IN PROGRESS
   - Mark single task COMPLETE
   - Mark multiple tasks COMPLETE
   - Preserve formatting

4. **Atomic Writes**
   - Write entire file atomically
   - Handle write failures
   - Retry with exponential backoff

5. **Partial Updates**
   - Update successful tasks
   - Report failed tasks
   - Return correct status (success/partial/error)

---

**Component**: Batch Task Orchestrator

**Test Cases**:
1. **Task Validation**
   - Validate all tasks exist
   - Filter out completed tasks
   - Filter out missing tasks
   - Report validation results

2. **Dependency Analysis Routing**
   - Route to task-dependency-analyzer
   - Receive dependency graph
   - Receive execution waves
   - Handle cycle detection errors

3. **Wave Execution**
   - Execute single wave
   - Execute multiple waves
   - Execute tasks in parallel within wave
   - Wait for wave completion

4. **Error Handling**
   - Handle task execution failure
   - Block dependent tasks
   - Continue with independent tasks
   - Report errors correctly

5. **Summary Generation**
   - Aggregate results across waves
   - Calculate statistics
   - Generate formatted summary
   - Include all relevant information

---

### Integration Testing

**Test Scenario 1: Simple Batch (No Dependencies)**

**Setup**:
```
Tasks: 63, 64, 65
Dependencies: None
```

**Execution**:
```bash
/task 63, 64, 65
```

**Expected Behavior**:
1. Parse input: [63, 64, 65]
2. Route to batch-task-orchestrator
3. Validate tasks (all exist, none complete)
4. Dependency analysis: Single wave [[63, 64, 65]]
5. Mark tasks IN PROGRESS in TODO.md
6. Execute Wave 1: Tasks 63, 64, 65 in parallel
7. Wait for completion
8. Mark completed tasks COMPLETE in TODO.md
9. Generate summary

**Verification**:
- [ ] All tasks execute in parallel
- [ ] TODO.md updated correctly (IN PROGRESS → COMPLETE)
- [ ] Summary shows 3 completed tasks
- [ ] No errors reported

---

**Test Scenario 2: Sequential Dependencies**

**Setup**:
```
Tasks: 63, 64, 65
Dependencies:
  64: 63
  65: 64
```

**Execution**:
```bash
/task 63, 64, 65
```

**Expected Behavior**:
1. Parse input: [63, 64, 65]
2. Dependency analysis: Three waves [[63], [64], [65]]
3. Execute Wave 1: Task 63
4. Execute Wave 2: Task 64 (after Wave 1 completes)
5. Execute Wave 3: Task 65 (after Wave 2 completes)

**Verification**:
- [ ] Tasks execute in correct order (63 → 64 → 65)
- [ ] No parallel execution (one task per wave)
- [ ] TODO.md updated correctly
- [ ] Summary shows correct wave structure

---

**Test Scenario 3: Parallel with Dependencies**

**Setup**:
```
Tasks: 63, 64, 65, 66, 67
Dependencies:
  65: 63
  66: 63
  67: 64
```

**Execution**:
```bash
/task 63, 64, 65, 66, 67
```

**Expected Behavior**:
1. Parse input: [63, 64, 65, 66, 67]
2. Dependency analysis: Two waves [[63, 64], [65, 66, 67]]
3. Execute Wave 1: Tasks 63, 64 in parallel
4. Execute Wave 2: Tasks 65, 66, 67 in parallel (after Wave 1)

**Verification**:
- [ ] Wave 1 executes in parallel (63, 64)
- [ ] Wave 2 executes in parallel (65, 66, 67)
- [ ] Wave 2 starts only after Wave 1 completes
- [ ] TODO.md updated correctly
- [ ] Summary shows correct wave structure

---

**Test Scenario 4: Circular Dependency**

**Setup**:
```
Tasks: 63, 64, 65
Dependencies:
  64: 63
  65: 64
  63: 65  (cycle!)
```

**Execution**:
```bash
/task 63, 64, 65
```

**Expected Behavior**:
1. Parse input: [63, 64, 65]
2. Dependency analysis: Detect cycle [63, 64, 65, 63]
3. Abort execution
4. Show error message with cycle path

**Verification**:
- [ ] Cycle detected correctly
- [ ] Execution aborted (no tasks executed)
- [ ] Error message shows cycle path
- [ ] Suggestions provided for resolution
- [ ] TODO.md not modified

---

**Test Scenario 5: Task Failure Blocks Dependents**

**Setup**:
```
Tasks: 63, 64, 65, 66
Dependencies:
  64: 63
  65: 64
  66: 63
```

**Execution**:
```bash
/task 63, 64, 65, 66
```

**Scenario**: Task 64 fails during execution

**Expected Behavior**:
1. Parse input: [63, 64, 65, 66]
2. Dependency analysis: [[63], [64, 66], [65]]
3. Execute Wave 1: Task 63 (succeeds)
4. Execute Wave 2: Task 64 (fails), Task 66 (succeeds)
5. Execute Wave 3: Task 65 (blocked by failed Task 64)

**Verification**:
- [ ] Task 63 completes successfully
- [ ] Task 64 fails
- [ ] Task 65 blocked (not executed)
- [ ] Task 66 completes successfully (independent of Task 64)
- [ ] TODO.md shows correct statuses
- [ ] Summary shows: 2 completed, 1 failed, 1 blocked

---

**Test Scenario 6: Mixed Format Input**

**Setup**:
```
Tasks: 63, 65-67, 88
```

**Execution**:
```bash
/task 63, 65-67, 88
```

**Expected Behavior**:
1. Parse input: [63, 65, 66, 67, 88]
2. Continue with normal batch execution

**Verification**:
- [ ] Input parsed correctly to [63, 65, 66, 67, 88]
- [ ] All tasks execute correctly
- [ ] No parsing errors

---

**Test Scenario 7: Already Complete Tasks**

**Setup**:
```
Tasks: 63, 64, 65
Task 64 status: [COMPLETE] ✅
```

**Execution**:
```bash
/task 63, 64, 65
```

**Expected Behavior**:
1. Parse input: [63, 64, 65]
2. Validate tasks: Task 64 already complete
3. Filter to [63, 65]
4. Execute only Tasks 63, 65

**Verification**:
- [ ] Task 64 skipped (already complete)
- [ ] Tasks 63, 65 execute normally
- [ ] Summary shows 1 skipped task
- [ ] Info message logged for skipped task

---

**Test Scenario 8: Missing Tasks**

**Setup**:
```
Tasks: 63, 999, 65
Task 999 does not exist in TODO.md
```

**Execution**:
```bash
/task 63, 999, 65
```

**Expected Behavior**:
1. Parse input: [63, 999, 65]
2. Validate tasks: Task 999 not found
3. Filter to [63, 65]
4. Execute only Tasks 63, 65

**Verification**:
- [ ] Task 999 skipped (not found)
- [ ] Tasks 63, 65 execute normally
- [ ] Summary shows 1 skipped task
- [ ] Warning message logged for missing task

---

### Performance Testing

**Test 1: Large Batch (50 tasks)**

**Setup**: 50 tasks with no dependencies

**Execution**:
```bash
/task 1-50
```

**Metrics**:
- Total execution time
- Average task execution time
- Concurrency level achieved
- Resource usage (CPU, memory)

**Expected**:
- Concurrency limit enforced (max 5 concurrent tasks)
- All tasks complete successfully
- Reasonable total execution time

---

**Test 2: Deep Dependency Chain (20 levels)**

**Setup**: 20 tasks with linear dependencies (1→2→3→...→20)

**Execution**:
```bash
/task 1-20
```

**Metrics**:
- Total execution time
- Wave count (should be 20)
- Overhead per wave

**Expected**:
- 20 waves (one task per wave)
- Sequential execution
- Minimal overhead between waves

---

**Test 3: Wide Dependency Tree (1 root, 49 dependents)**

**Setup**: Task 1 with 49 tasks depending on it

**Execution**:
```bash
/task 1-50
```

**Metrics**:
- Wave count (should be 2)
- Concurrency in Wave 2
- Total execution time

**Expected**:
- Wave 1: Task 1
- Wave 2: Tasks 2-50 (parallel, with concurrency limit)
- High concurrency in Wave 2

---

## Risk Assessment

### Risk 1: Circular Dependency Detection Failure

**Risk**: Cycle detection algorithm fails to detect some cycles

**Impact**: High - Could cause infinite loops or incorrect execution order

**Likelihood**: Low - Well-tested algorithms (DFS, Kahn's)

**Mitigation**:
- Use proven algorithms (DFS-based cycle detection)
- Comprehensive unit tests with various cycle patterns
- Fallback: Kahn's algorithm will fail if cycles exist (no nodes with in-degree 0)
- Add execution timeout as safety net

**Contingency**:
- If cycle detected late, abort execution
- Provide clear error message with cycle path
- Suggest manual resolution

---

### Risk 2: Race Conditions in TODO.md Updates

**Risk**: Concurrent updates to TODO.md cause corruption or data loss

**Impact**: Medium - TODO.md becomes inconsistent or corrupted

**Likelihood**: Low - Atomic write strategy prevents most race conditions

**Mitigation**:
- Atomic write strategy (read entire file, update in memory, write entire file)
- Serialization of TODO.md updates (orchestrator lock)
- Retry logic with exponential backoff
- File locking (if supported)

**Contingency**:
- If corruption detected, restore from git
- Manual TODO.md update as fallback
- Log all update attempts for debugging

---

### Risk 3: Resource Exhaustion from Parallel Execution

**Risk**: Too many concurrent task-executor agents exhaust system resources

**Impact**: Medium - System slowdown, agent failures, or crashes

**Likelihood**: Medium - Depends on task count and system resources

**Mitigation**:
- Concurrency limit (max 5 concurrent tasks)
- Batch execution within waves if needed
- Timeout per task (1 hour default)
- Resource monitoring and throttling

**Contingency**:
- Reduce concurrency limit dynamically
- Fall back to sequential execution if resources low
- Provide manual concurrency override option

---

### Risk 4: Partial Execution Failures

**Risk**: Some tasks fail, leaving batch in inconsistent state

**Impact**: Medium - Some tasks complete, others don't, dependencies unclear

**Likelihood**: Medium - Task failures are expected

**Mitigation**:
- Graceful error handling (continue with independent tasks)
- Block dependent tasks on failure
- Comprehensive summary report
- TODO.md status tracking (IN PROGRESS vs COMPLETE)

**Contingency**:
- Provide clear summary of what completed/failed/blocked
- Suggest re-running failed tasks individually
- Provide command to resume from failure point

---

### Risk 5: Dependency Parsing Errors

**Risk**: Malformed dependency specifications in TODO.md cause parsing errors

**Impact**: Low - Batch execution fails, but no data corruption

**Likelihood**: Medium - User error in TODO.md formatting

**Mitigation**:
- Robust parsing with error handling
- Clear error messages for malformed dependencies
- Validation before execution
- Fallback: Assume no dependencies if parsing fails

**Contingency**:
- Show parsing error with line number
- Suggest correct format
- Allow user to fix and retry

---

### Risk 6: Long-Running Tasks Block Waves

**Risk**: One slow task blocks entire wave from completing

**Impact**: Medium - Reduces parallelism benefits

**Likelihood**: High - Task execution times vary widely

**Mitigation**:
- Task timeout (1 hour default)
- Progress reporting shows which tasks are running
- Allow user to cancel batch execution
- Consider priority-based scheduling (future enhancement)

**Contingency**:
- User can cancel and re-run without slow task
- Timeout will eventually unblock wave
- Manual intervention if needed

---

### Risk 7: TODO.md Format Changes Break Parsing

**Risk**: Future TODO.md format changes break dependency parsing

**Impact**: High - Batch execution stops working

**Likelihood**: Low - TODO.md format is stable

**Mitigation**:
- Flexible parsing (regex-based, not position-based)
- Version detection (check TODO.md format version)
- Backward compatibility
- Comprehensive tests

**Contingency**:
- Update parser for new format
- Provide migration guide
- Support both old and new formats temporarily

---

## Success Criteria

### Functional Requirements

- [ ] **FR1**: Parse single task input correctly (`/task 63`)
- [ ] **FR2**: Parse task list input correctly (`/task 63, 64, 65`)
- [ ] **FR3**: Parse task range input correctly (`/task 65-67`)
- [ ] **FR4**: Parse mixed format input correctly (`/task 63, 65-67, 88`)
- [ ] **FR5**: Build dependency graph from TODO.md dependencies
- [ ] **FR6**: Detect circular dependencies and abort with clear error
- [ ] **FR7**: Perform topological sort to create execution waves
- [ ] **FR8**: Execute tasks in parallel within each wave
- [ ] **FR9**: Execute waves sequentially (Wave N after Wave N-1)
- [ ] **FR10**: Mark tasks IN PROGRESS at wave start
- [ ] **FR11**: Mark completed simple tasks COMPLETE at wave end
- [ ] **FR12**: Handle task execution failures gracefully
- [ ] **FR13**: Block dependent tasks when dependency fails
- [ ] **FR14**: Continue executing independent tasks after failure
- [ ] **FR15**: Generate comprehensive summary report

### Non-Functional Requirements

- [ ] **NFR1**: Atomic TODO.md updates (no race conditions)
- [ ] **NFR2**: Concurrency limit enforced (max 5 concurrent tasks)
- [ ] **NFR3**: Task timeout enforced (1 hour default)
- [ ] **NFR4**: Clear error messages for all error types
- [ ] **NFR5**: Progress reporting during execution
- [ ] **NFR6**: Execution time < 2x sequential execution (for parallel tasks)
- [ ] **NFR7**: Memory usage < 500MB for 50-task batch
- [ ] **NFR8**: Graceful degradation on resource exhaustion

### Quality Requirements

- [ ] **QR1**: All components have comprehensive docstrings
- [ ] **QR2**: All algorithms have clear comments and explanations
- [ ] **QR3**: All error paths have appropriate error messages
- [ ] **QR4**: All test scenarios pass
- [ ] **QR5**: Code follows existing architecture patterns
- [ ] **QR6**: Documentation is complete and accurate
- [ ] **QR7**: Examples are clear and helpful

### Integration Requirements

- [ ] **IR1**: Seamless integration with existing `/task` command
- [ ] **IR2**: Compatible with existing task-executor workflow
- [ ] **IR3**: Compatible with existing TODO.md format
- [ ] **IR4**: No breaking changes to existing functionality
- [ ] **IR5**: Backward compatible (single task execution unchanged)

### User Experience Requirements

- [ ] **UX1**: Batch execution is intuitive and easy to use
- [ ] **UX2**: Error messages are clear and actionable
- [ ] **UX3**: Progress reporting is informative
- [ ] **UX4**: Summary report is comprehensive and readable
- [ ] **UX5**: Documentation provides clear examples
- [ ] **UX6**: Execution time is reasonable (< 5 min for 10 simple tasks)

---

## Related Research

### Graph Algorithms

**Topological Sort**:
- Kahn's Algorithm (BFS-based): O(V + E) time, O(V) space
- DFS-based: O(V + E) time, O(V) space
- Both produce valid topological orderings
- Kahn's naturally produces waves (BFS levels)

**Cycle Detection**:
- DFS with recursion stack: O(V + E) time, O(V) space
- Tarjan's Strongly Connected Components: O(V + E) time, O(V) space
- Both detect all cycles
- DFS simpler to implement

**References**:
- Introduction to Algorithms (CLRS), Chapter 22
- Algorithm Design Manual (Skiena), Chapter 5

---

### Parallel Task Scheduling

**Wave-Based Execution**:
- Execute tasks in topologically sorted order
- Parallelize within each level (wave)
- Wait for level completion before proceeding
- Common in build systems (Make, Bazel)

**Concurrency Control**:
- Semaphore-based limiting
- Thread pool with fixed size
- Dynamic throttling based on resources

**References**:
- GNU Make documentation (parallel execution)
- Bazel build system (action graph execution)

---

### Atomic File Updates

**Strategies**:
- Read-modify-write with locks
- Write to temp file, atomic rename
- Copy-on-write with versioning
- Transaction logs

**Best Practices**:
- Minimize lock duration
- Use exponential backoff for retries
- Validate after write
- Keep backups

**References**:
- POSIX file locking (fcntl)
- Database transaction isolation levels
- Git object storage (atomic updates)

---

### Existing Patterns in ProofChecker

**task-executor workflow**:
- Single task execution
- Complexity analysis
- Workflow routing (researcher/planner)
- Artifact creation
- Status tracking

**planner coordination**:
- Delegates to complexity-analyzer
- Delegates to dependency-mapper
- Synthesizes results
- Creates artifacts
- Returns references

**XML-optimized architecture**:
- Hierarchical routing
- Context protection
- Specialist delegation
- Artifact-based communication

---

## Notes

### Design Decisions

1. **Hybrid Architecture (Option 3)**: Chosen for best separation of concerns, maintainability, and consistency with existing patterns.

2. **Kahn's Algorithm**: Chosen for topological sort due to simplicity and natural wave production.

3. **Batch TODO.md Updates**: Chosen to minimize file writes and improve atomicity.

4. **Concurrency Limit**: Set to 5 to balance parallelism and resource usage.

5. **Task Timeout**: Set to 1 hour to prevent hanging tasks.

### Future Enhancements

1. **Priority-Based Scheduling**: Execute high-priority tasks first within waves.

2. **Resource-Aware Scheduling**: Adjust concurrency based on system resources.

3. **Incremental Execution**: Resume from failure point without re-executing completed tasks.

4. **Dependency Visualization**: Generate graphical dependency graph.

5. **Batch Execution History**: Track batch execution history and statistics.

6. **Custom Wave Grouping**: Allow user to override automatic wave grouping.

7. **Dry Run Mode**: Show execution plan without executing tasks.

8. **Interactive Mode**: Prompt user for confirmation before each wave.

### Implementation Timeline

**Week 1** (16 hours):
- Day 1-2: Task Dependency Analyzer (6 hours)
- Day 3: Batch Status Manager (4 hours)
- Day 4-5: Batch Task Orchestrator (6 hours)

**Week 2** (9 hours):
- Day 1: Command Modification (3 hours)
- Day 2: Integration Testing (3 hours)
- Day 3: Documentation (3 hours)

**Total**: 25 hours (conservative estimate)

### Maintenance Considerations

1. **TODO.md Format**: Keep dependency parsing flexible to accommodate format changes.

2. **Concurrency Limit**: Make configurable via environment variable or config file.

3. **Timeout Values**: Make configurable per task or globally.

4. **Error Messages**: Keep error messages clear and actionable.

5. **Logging**: Add comprehensive logging for debugging.

6. **Metrics**: Track execution statistics for optimization.

---

## Appendix: Code Examples

### Example 1: Dependency Graph Class

```python
class DependencyGraph:
    """Directed graph for task dependencies."""
    
    def __init__(self):
        self.nodes = set()
        self.edges = {}  # node → set of neighbors
    
    def add_node(self, node: int):
        """Add node to graph."""
        self.nodes.add(node)
        if node not in self.edges:
            self.edges[node] = set()
    
    def add_edge(self, from_node: int, to_node: int):
        """Add directed edge: from_node → to_node."""
        self.add_node(from_node)
        self.add_node(to_node)
        self.edges[from_node].add(to_node)
    
    def neighbors(self, node: int) -> Set[int]:
        """Get neighbors of node (nodes that depend on this node)."""
        return self.edges.get(node, set())
    
    def in_degree(self, node: int) -> int:
        """Calculate in-degree of node (number of dependencies)."""
        count = 0
        for neighbors in self.edges.values():
            if node in neighbors:
                count += 1
        return count
    
    def has_path(self, from_node: int, to_node: int) -> bool:
        """Check if path exists from from_node to to_node."""
        if from_node == to_node:
            return True
        
        visited = set()
        stack = [from_node]
        
        while stack:
            current = stack.pop()
            if current == to_node:
                return True
            
            if current in visited:
                continue
            
            visited.add(current)
            stack.extend(self.neighbors(current))
        
        return False
```

### Example 2: Kahn's Algorithm Implementation

```python
def topological_sort_waves(graph: DependencyGraph) -> List[List[int]]:
    """
    Perform topological sort using Kahn's algorithm.
    
    Returns list of waves (each wave is a list of task numbers).
    
    Raises:
        CircularDependencyError: If graph contains cycles.
    """
    # Calculate in-degrees
    in_degree = {node: graph.in_degree(node) for node in graph.nodes}
    
    # Initialize waves
    waves = []
    remaining = set(graph.nodes)
    
    while remaining:
        # Find all nodes with in-degree 0 in remaining set
        wave = [node for node in remaining if in_degree[node] == 0]
        
        if not wave:
            # No nodes with in-degree 0 - cycle exists
            cycle = find_cycle_dfs(graph, remaining)
            raise CircularDependencyError(
                f"Circular dependency detected: {' → '.join(map(str, cycle))}"
            )
        
        # Add wave
        waves.append(sorted(wave))
        
        # Remove wave nodes and update in-degrees
        for node in wave:
            remaining.remove(node)
            for neighbor in graph.neighbors(node):
                in_degree[neighbor] -= 1
    
    return waves
```

### Example 3: Batch TODO.md Update

```python
def batch_update_todo(
    operation: str,
    tasks: List[TaskUpdate],
    filepath: str = ".opencode/specs/TODO.md"
) -> BatchUpdateResult:
    """
    Perform atomic batch update to TODO.md.
    
    Args:
        operation: "mark_in_progress" or "mark_complete"
        tasks: List of TaskUpdate objects
        filepath: Path to TODO.md
    
    Returns:
        BatchUpdateResult with status and details
    """
    # Read entire file
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Make all updates in memory
    updated_content = content
    successful_updates = []
    failed_updates = []
    
    for task_update in tasks:
        try:
            updated_content = update_task_status(
                updated_content,
                task_update.task_num,
                operation,
                task_update.timestamp
            )
            successful_updates.append(task_update.task_num)
        except Exception as e:
            failed_updates.append({
                'task_num': task_update.task_num,
                'error': str(e)
            })
    
    # Write entire file atomically
    if successful_updates:
        with open(filepath, 'w') as f:
            f.write(updated_content)
            f.flush()
            os.fsync(f.fileno())  # Force write to disk
    
    return BatchUpdateResult(
        status='success' if not failed_updates else 'partial',
        updated_tasks=successful_updates,
        failed_tasks=[u['task_num'] for u in failed_updates],
        errors=failed_updates
    )
```

---

**End of Implementation Plan**
