# Plan Summary: Batch Task Execution with Parallel Processing

**Project**: #072
**Version**: 001
**Complexity**: Complex
**Estimated Effort**: 18-25 hours
**Date**: 2025-12-19

---

## Overview

Enhance the `/task` command system to support batch execution of multiple tasks with intelligent dependency analysis, parallel wave-based execution, and atomic TODO.md status tracking.

---

## Key Features

1. **Batch Input Parsing**: Support single tasks, task lists, ranges, and mixed formats
   - `/task 63` (single)
   - `/task 63, 64, 65` (list)
   - `/task 65-67` (range)
   - `/task 63, 65-67, 88` (mixed)

2. **Dependency Analysis**: Parse TODO.md dependencies, build DAG, detect cycles, perform topological sort

3. **Wave-Based Parallel Execution**: Execute tasks in waves (parallel within wave, sequential across waves)

4. **Atomic TODO.md Updates**: Batch status updates to prevent race conditions

5. **Graceful Error Handling**: Handle failures, block dependents, continue with independent tasks

6. **Progress Reporting**: Real-time wave progress and comprehensive summary

---

## Architectural Decision

**Hybrid Architecture (Option 3)** - Command handles parsing, orchestrator handles execution

**Components**:
- **Command Layer** (`.opencode/command/task.md`): Input parsing, validation, routing
- **Orchestration Layer** (`.opencode/agent/subagents/batch-task-orchestrator.md`): Workflow coordination, wave execution
- **Specialist Layer**:
  - `task-dependency-analyzer.md`: Dependency graph, topological sort, cycle detection
  - `batch-status-manager.md`: Atomic TODO.md batch updates

**Rationale**:
- Follows existing architecture patterns (task-executor, planner, researcher)
- Best separation of concerns
- Maintains XML-optimized agent architecture
- Provides best maintainability and testability

---

## Key Steps

### Phase 1: Foundation (6-8 hours)

1. **Create Task Dependency Analyzer Specialist** (4-6 hours)
   - Implement TODO.md dependency parsing
   - Build dependency graph (DAG)
   - Implement cycle detection (DFS-based)
   - Implement topological sort (Kahn's algorithm)
   - Group tasks into execution waves

2. **Create Batch Status Manager Specialist** (3-4 hours)
   - Implement TODO.md reading and parsing
   - Implement batch status update logic
   - Implement atomic write strategy
   - Add retry logic with exponential backoff

### Phase 2: Orchestration (6-8 hours)

3. **Create Batch Task Orchestrator** (6-8 hours)
   - Implement task validation
   - Route to task-dependency-analyzer
   - Implement wave execution logic
   - Implement parallel task execution
   - Implement error handling and recovery
   - Generate summary report

### Phase 3: Integration (2-3 hours)

4. **Modify `/task` Command** (2-3 hours)
   - Add input parsing (single, list, range, mixed)
   - Add routing decision (single vs batch)
   - Update documentation

### Phase 4: Testing and Documentation (3-4 hours)

5. **Integration Testing** (2-3 hours)
   - Test all input formats
   - Test dependency scenarios
   - Test error handling
   - Test parallel execution

6. **Documentation** (1 hour)
   - Update command documentation
   - Add batch execution examples
   - Document dependency format

---

## Dependencies

**Required Components**:
- Existing `/task` command
- Existing `task-executor` subagent
- TODO.md with dependency format
- XML-optimized agent architecture

**New Components**:
- `batch-task-orchestrator.md` (orchestrator)
- `task-dependency-analyzer.md` (specialist)
- `batch-status-manager.md` (specialist)

**External Dependencies**:
- Graph algorithms (topological sort, cycle detection)
- Concurrent task execution support
- File I/O atomicity

---

## Algorithms

### Dependency Analysis (Kahn's Algorithm)

**Input**: Task numbers, TODO.md dependencies

**Process**:
1. Parse dependencies from TODO.md
2. Build dependency graph (DAG)
3. Calculate in-degrees for all nodes
4. Repeatedly extract nodes with in-degree 0 (waves)
5. Update in-degrees after each wave
6. Detect cycles if no nodes with in-degree 0 remain

**Output**: Execution waves (e.g., [[63, 88], [64, 65], [66, 67]])

**Complexity**: O(V + E) time, O(V) space

### Cycle Detection (DFS-based)

**Process**:
1. Perform DFS with recursion stack
2. If back edge found (to node in recursion stack), cycle detected
3. Extract cycle path from parent pointers

**Complexity**: O(V + E) time, O(V) space

---

## Parallel Execution Strategy

**Wave-Based Execution**:
1. Execute all tasks in Wave 1 in parallel (concurrent task-executor invocations)
2. Wait for Wave 1 completion
3. Execute all tasks in Wave 2 in parallel
4. Repeat until all waves complete

**Concurrency Control**:
- Maximum 5 concurrent tasks (configurable)
- If wave has > 5 tasks, execute in batches
- Task timeout: 1 hour (configurable)

**Error Handling**:
- Task failure blocks dependent tasks
- Independent tasks continue execution
- Comprehensive error reporting

---

## TODO.md Update Strategy

**Atomic Batch Updates**:
1. Read entire TODO.md into memory
2. Make all updates in memory (no partial writes)
3. Write entire file back in single operation
4. Verify write success

**Update Timing**:
- **Wave Start**: Mark all tasks IN PROGRESS
- **Wave End**: Mark completed simple tasks COMPLETE

**Race Condition Prevention**:
- Single atomic write operation
- Orchestrator serializes TODO.md updates
- Retry logic with exponential backoff

---

## Error Handling

**Error Types**:
1. **Input Validation**: Invalid format, invalid range
2. **Task Not Found**: Skip, log warning, continue
3. **Task Already Complete**: Skip, log info, continue
4. **Circular Dependency**: Abort, show cycle path
5. **Task Execution Failure**: Mark failed, block dependents, continue with independent
6. **TODO.md Update Failure**: Retry, log error, continue (graceful degradation)
7. **Timeout**: Mark timeout, block dependents

**Error Reporting**:
- Clear error messages with suggestions
- Comprehensive summary report
- Detailed logging for debugging

---

## Success Criteria

**Functional**:
- [ ] Parse all input formats correctly
- [ ] Build dependency graph and detect cycles
- [ ] Execute tasks in correct wave order
- [ ] Execute tasks in parallel within waves
- [ ] Update TODO.md atomically
- [ ] Handle all error types gracefully
- [ ] Generate comprehensive summary

**Non-Functional**:
- [ ] Atomic TODO.md updates (no race conditions)
- [ ] Concurrency limit enforced
- [ ] Task timeout enforced
- [ ] Clear error messages
- [ ] Execution time < 2x sequential (for parallel tasks)

**Quality**:
- [ ] Comprehensive docstrings
- [ ] Clear algorithm comments
- [ ] All test scenarios pass
- [ ] Complete documentation

---

## Files Affected

### Files to Create

```
.opencode/agent/subagents/
├── batch-task-orchestrator.md          # NEW - Main orchestrator
└── specialists/
    ├── task-dependency-analyzer.md     # NEW - Dependency analysis
    └── batch-status-manager.md         # NEW - TODO.md updates
```

### Files to Modify

```
.opencode/command/
└── task.md                             # MODIFY - Add batch parsing and routing

.opencode/specs/
└── TODO.md                             # MODIFY (optional) - Add batch examples
```

---

## Risk Assessment

**High Risks**:
- Circular dependency detection failure → Mitigation: Well-tested algorithms, comprehensive tests
- Race conditions in TODO.md → Mitigation: Atomic writes, serialization, retry logic

**Medium Risks**:
- Resource exhaustion → Mitigation: Concurrency limit, timeouts, throttling
- Partial execution failures → Mitigation: Graceful error handling, comprehensive summary
- Long-running tasks block waves → Mitigation: Task timeout, progress reporting

**Low Risks**:
- Dependency parsing errors → Mitigation: Robust parsing, clear error messages
- TODO.md format changes → Mitigation: Flexible parsing, backward compatibility

---

## Testing Strategy

**Unit Tests**:
- Dependency parsing
- Graph construction
- Cycle detection
- Topological sort
- TODO.md updates
- Error handling

**Integration Tests**:
- Simple batch (no dependencies)
- Sequential dependencies
- Parallel with dependencies
- Circular dependency
- Task failure blocks dependents
- Mixed format input
- Already complete tasks
- Missing tasks

**Performance Tests**:
- Large batch (50 tasks)
- Deep dependency chain (20 levels)
- Wide dependency tree (1 root, 49 dependents)

---

## Timeline

**Week 1** (16 hours):
- Day 1-2: Task Dependency Analyzer (6 hours)
- Day 3: Batch Status Manager (4 hours)
- Day 4-5: Batch Task Orchestrator (6 hours)

**Week 2** (9 hours):
- Day 1: Command Modification (3 hours)
- Day 2: Integration Testing (3 hours)
- Day 3: Documentation (3 hours)

**Total**: 25 hours (conservative estimate)

---

## Full Plan

See: `.opencode/specs/072_batch_task_execution/plans/implementation-001.md`

---

## Notes

- Hybrid architecture chosen for best separation of concerns and consistency with existing patterns
- Kahn's algorithm chosen for topological sort due to simplicity and natural wave production
- Batch TODO.md updates chosen to minimize file writes and improve atomicity
- Concurrency limit set to 5 to balance parallelism and resource usage
- Task timeout set to 1 hour to prevent hanging tasks

---

**Status**: Ready for implementation
**Next Step**: Begin Phase 1 - Create Task Dependency Analyzer Specialist
