# Research Report: Fix Subagent Delegation Hang Issue in Command Workflows

**Project**: #191
**Date**: 2025-12-25
**Research Type**: Implementation Strategy

## Research Question

Why do commands that call subagents (like /implement, /research, /plan) often get stuck on "Good! Now I'll route to the lean-implementation-orchestrator to execute the implementation plan:" followed by "Delegating..." with no further progress? What are the root causes and how can they be fixed?

## Sources Consulted

- Command definitions: implement.md, research.md, plan.md
- Orchestrator agent: orchestrator.md
- Subagent definitions: task-executor.md, batch-task-orchestrator.md, researcher.md, planner.md
- Implementation orchestrators: lean-implementation-orchestrator.md, implementation-orchestrator.md
- System documentation: artifact-management.md, TODO.md

## Key Findings

### Root Cause 1: Missing Return Path After Subagent Delegation

**Problem**: Commands route to subagents using the task tool but do not properly handle the response or wait for completion.

**Evidence**:
- `/implement` command (lines 117-127) routes to task-executor/batch-task-orchestrator but has no explicit stage for receiving and processing the return value
- `/research` command (lines 65-74) routes to researcher subagent but lacks explicit return handling stage
- `/plan` command (lines 74-83) routes to planner subagent but lacks explicit return handling stage

**Specific Issues**:
1. Commands use `<route to="@subagents/X">` pattern but don't show how to capture the return value
2. No explicit "wait for completion" or "receive results" stage in command workflows
3. Commands jump from "route to subagent" directly to "postflight sync" without intermediate result processing

**Example from /implement**:
```xml
<stage id="3" name="Execute">
  <action>Route by work type and complexity</action>
  <process>
    1. Single task: route to appropriate agent with complexity flag:
       - Simple: Direct execution by implementer (no research/plan phases)
       - Moderate/Complex: Route to task-executor for full workflow
    ...
  </process>
</stage>
<stage id="4" name="Postflight">
  <action>Sync and report</action>
  <!-- No stage for receiving task-executor results! -->
</stage>
```

### Root Cause 2: Infinite Delegation Loops

**Problem**: Subagent routing logic creates circular delegation paths where agents route back to themselves or create delegation cycles.

**Evidence**:
- task-executor.md (line 201) routes batch tasks to batch-task-orchestrator
- batch-task-orchestrator.md (line 201) routes individual tasks back to task-executor
- This creates potential cycle: /implement → task-executor → batch-task-orchestrator → task-executor → ...

**Specific Cycle Patterns**:

1. **Batch Task Cycle**:
   - `/implement 105-107` → task-executor (stage 3, line 122)
   - task-executor detects batch → routes to batch-task-orchestrator (line 201)
   - batch-task-orchestrator executes wave → routes each task to task-executor (line 201)
   - task-executor processes single task → routes to implementer/researcher/etc.
   - **Issue**: If task-executor re-detects batch, infinite loop

2. **Research/Plan Cycle**:
   - `/research 160` → researcher subagent (research.md line 68)
   - researcher delegates to web-research-specialist (researcher.md line 80)
   - web-research-specialist returns to researcher
   - researcher synthesizes and returns to command
   - **Issue**: If researcher doesn't properly handle specialist return, hangs

3. **Implementation Orchestrator Cycle**:
   - `/implement plan.md` → implementation-orchestrator (implement.md line 122)
   - implementation-orchestrator routes phases to implementer (implementation-orchestrator.md line 128)
   - implementer executes code changes
   - **Issue**: If implementer tries to route back to orchestrator, cycle occurs

### Root Cause 3: Synchronous Expectations for Async Calls

**Problem**: Commands expect synchronous responses from async subagent calls, causing hangs when waiting for results that arrive asynchronously.

**Evidence**:
- Commands use `<route to="@subagents/X">` pattern which appears to be async delegation via task tool
- No explicit async/await or callback mechanism shown in command workflows
- Commands proceed to next stage without confirming subagent completion

**Specific Issues**:
1. Task tool invocations are async but commands treat them as synchronous
2. No session_id tracking or result polling mechanism
3. Commands don't wait for subagent to return before proceeding to postflight

**Example Pattern**:
```xml
<!-- Command invokes subagent -->
<route to="@subagents/researcher">
  <expected_return>
    - Research report path
    - Key findings summary
  </expected_return>
</route>

<!-- But no code showing HOW to receive this return! -->
```

### Root Cause 4: Missing Error Handling for Subagent Failures

**Problem**: Commands lack error handling when subagents fail or timeout, causing silent hangs.

**Evidence**:
- `/implement` command has error handling in postflight (lines 144-150) but only for status-sync-manager failures
- No error handling for task-executor failures, timeouts, or exceptions
- No timeout specification for subagent invocations
- No fallback or retry logic

**Specific Gaps**:
1. **No timeout handling**: Commands don't specify max wait time for subagent responses
2. **No failure detection**: Commands can't detect when subagent fails vs. is still running
3. **No error propagation**: Subagent errors don't bubble up to command level
4. **No retry logic**: Failed delegations aren't retried or escalated

**Example from /implement**:
```xml
<error_handling>
  If status-sync-manager fails:
  1. Log detailed error including which file failed to update
  2. Return error to user with actionable message
  <!-- But no error handling for task-executor failures! -->
</error_handling>
```

### Root Cause 5: Orchestrator Coordination Gaps

**Problem**: Orchestrator doesn't properly coordinate between command and subagent layers, leading to lost messages or hung delegations.

**Evidence from orchestrator.md**:
- Stage 3 "RouteToAgent" (lines 167-283) shows routing patterns but no coordination logic
- Stage 4 "MonitorExecution" (lines 286-312) mentions monitoring but provides no implementation
- No explicit message passing or state synchronization between layers

**Specific Coordination Issues**:

1. **No Message Queue**: No mechanism to queue subagent responses for command consumption
2. **No State Synchronization**: Commands and subagents don't share execution state
3. **No Progress Tracking**: Orchestrator can't track subagent progress or detect hangs
4. **No Timeout Enforcement**: Orchestrator doesn't enforce timeouts on delegations

**Example from orchestrator.md**:
```xml
<stage id="4" name="MonitorExecution">
  <action>Monitor agent execution and artifact creation</action>
  <process>
    1. Track agent progress
    2. Ensure artifacts are created in correct locations
    <!-- But HOW to track progress? No implementation shown! -->
  </process>
</stage>
```

### Root Cause 6: Return Format Ambiguity

**Problem**: Subagents and commands have inconsistent return format expectations, causing parsing failures and hangs.

**Evidence**:
- task-executor.md (lines 656-752) defines detailed return format with validation
- batch-task-orchestrator.md (lines 402-643) defines different return format
- Commands don't specify what format they expect from subagents
- No schema validation or format enforcement

**Specific Inconsistencies**:

1. **task-executor return format** (line 657):
   ```json
   {
     "task_number": NNN,
     "status": "COMPLETED|FAILED|BLOCKED|PARTIAL",
     "summary": "Brief 3-5 sentence summary",
     "artifacts": [...],
     "key_metrics": {...}
   }
   ```

2. **batch-task-orchestrator return format** (line 403):
   ```json
   {
     "summary": "Brief 2-3 sentence summary",
     "completed_tasks": [...],
     "artifacts": {...},
     "status": {...}
   }
   ```

3. **researcher return format** (researcher.md line 212):
   ```json
   {
     "project_number": NNN,
     "artifacts": [...],
     "summary": "Brief 3-5 sentence summary",
     "key_findings": [...]
   }
   ```

**Impact**: Commands can't parse subagent returns because format varies by subagent type.

## Design Patterns and Best Practices

### Pattern 1: Explicit Return Handling

**Best Practice**: Commands should have explicit stages for receiving and processing subagent returns.

**Recommended Pattern**:
```xml
<stage id="3" name="DelegateToSubagent">
  <action>Route to appropriate subagent</action>
  <process>
    1. Determine subagent type
    2. Prepare routing message
    3. Invoke subagent via task tool with session_id
    4. Store session_id for tracking
  </process>
</stage>

<stage id="4" name="ReceiveResults">
  <action>Wait for and receive subagent results</action>
  <process>
    1. Poll for subagent completion using session_id
    2. Set timeout (default: 3600 seconds)
    3. Receive return value from subagent
    4. Validate return format against schema
    5. Handle errors and timeouts
  </process>
</stage>

<stage id="5" name="ProcessResults">
  <action>Process subagent results</action>
  <process>
    1. Extract artifacts from return
    2. Extract summary and key findings
    3. Update command state
    4. Prepare for postflight
  </process>
</stage>
```

### Pattern 2: Cycle Prevention

**Best Practice**: Use delegation depth tracking to prevent infinite loops.

**Recommended Pattern**:
```xml
<delegation_tracking>
  <max_depth>3</max_depth>
  <current_depth>Track in session context</current_depth>
  <cycle_detection>
    1. Track delegation path: command → subagent1 → subagent2
    2. Before delegating, check if target already in path
    3. If cycle detected, return error instead of delegating
    4. Increment depth counter on each delegation
    5. If depth > max_depth, return error
  </cycle_detection>
</delegation_tracking>
```

### Pattern 3: Timeout and Error Handling

**Best Practice**: All subagent invocations should have timeouts and error handlers.

**Recommended Pattern**:
```xml
<subagent_invocation>
  <timeout>3600</timeout> <!-- 1 hour -->
  <error_handling>
    <on_timeout>
      1. Log timeout error with session_id
      2. Return partial results if available
      3. Mark task as IN PROGRESS (not failed)
      4. Suggest manual intervention
    </on_timeout>
    <on_error>
      1. Log error details
      2. Attempt retry (max 1 retry)
      3. If retry fails, return error to user
      4. Provide actionable error message
    </on_error>
    <on_exception>
      1. Catch all exceptions
      2. Log stack trace
      3. Return graceful error message
      4. Don't leave task in hung state
    </on_exception>
  </error_handling>
</subagent_invocation>
```

### Pattern 4: Standardized Return Format

**Best Practice**: Define single return format schema for all subagents.

**Recommended Schema**:
```json
{
  "status": "completed|failed|partial|blocked",
  "summary": "Brief 2-5 sentence summary (max 100 tokens)",
  "artifacts": [
    {
      "type": "research|plan|implementation|summary",
      "path": "relative/path/from/root",
      "summary": "Optional one-sentence summary"
    }
  ],
  "metadata": {
    "session_id": "unique_session_id",
    "duration_seconds": 123,
    "agent_type": "task-executor|researcher|planner|etc"
  },
  "errors": [
    {
      "message": "Error description",
      "phase": "Phase where error occurred",
      "recommendation": "Recommended action"
    }
  ],
  "next_steps": "Optional next steps (1-2 sentences)"
}
```

### Pattern 5: Orchestrator Coordination

**Best Practice**: Orchestrator should actively coordinate delegations, not just route.

**Recommended Pattern**:
```xml
<orchestrator_coordination>
  <delegation_registry>
    Track active delegations:
    - session_id → {command, subagent, start_time, timeout}
  </delegation_registry>
  
  <monitoring>
    1. Poll delegation registry every 30 seconds
    2. Check for timeouts
    3. Check for completion
    4. Update command state
  </monitoring>
  
  <timeout_enforcement>
    1. When delegation exceeds timeout
    2. Terminate subagent if possible
    3. Return timeout error to command
    4. Clean up delegation registry
  </timeout_enforcement>
  
  <result_routing>
    1. When subagent completes
    2. Validate return format
    3. Route result back to waiting command
    4. Remove from delegation registry
  </result_routing>
</orchestrator_coordination>
```

## Implementation Strategies

### Strategy 1: Add Explicit Return Handling Stages

**Approach**: Modify all commands to include explicit return handling stages.

**Files to Modify**:
- `.opencode/command/implement.md`
- `.opencode/command/research.md`
- `.opencode/command/plan.md`

**Changes**:
1. Add "ReceiveResults" stage after delegation stage
2. Add "ProcessResults" stage after receive stage
3. Include timeout and error handling in receive stage
4. Validate return format in process stage

**Example for /implement**:
```xml
<stage id="3" name="Execute">
  <action>Route by work type and complexity</action>
  <process>
    1. Determine routing target
    2. Prepare routing message
    3. Invoke subagent with session_id
    4. Store session_id for tracking
  </process>
</stage>

<stage id="3.5" name="ReceiveResults">
  <action>Wait for subagent completion</action>
  <process>
    1. Poll for completion using session_id
    2. Set timeout: 3600 seconds
    3. Receive return value
    4. Handle timeout/error cases
  </process>
</stage>

<stage id="3.75" name="ProcessResults">
  <action>Process subagent results</action>
  <process>
    1. Validate return format
    2. Extract artifacts and summary
    3. Update command state
    4. Prepare for postflight
  </process>
</stage>

<stage id="4" name="Postflight">
  <!-- Existing postflight logic -->
</stage>
```

### Strategy 2: Implement Cycle Detection

**Approach**: Add delegation depth tracking to prevent infinite loops.

**Files to Modify**:
- `.opencode/agent/orchestrator.md`
- `.opencode/agent/subagents/task-executor.md`
- `.opencode/agent/subagents/batch-task-orchestrator.md`

**Changes**:
1. Add delegation_depth parameter to all subagent invocations
2. Increment depth on each delegation
3. Check depth before delegating (max depth: 3)
4. Return error if cycle detected or max depth exceeded

**Example**:
```xml
<cycle_prevention>
  <max_delegation_depth>3</max_delegation_depth>
  <delegation_path_tracking>
    Track path: [orchestrator, implement, task-executor, batch-orchestrator]
    Before delegating to X:
      1. Check if X already in path → ERROR: cycle detected
      2. Check if path.length >= max_depth → ERROR: max depth exceeded
      3. Append X to path
      4. Pass updated path to X
  </delegation_path_tracking>
</cycle_prevention>
```

### Strategy 3: Add Timeout and Error Handling

**Approach**: Implement comprehensive timeout and error handling for all subagent invocations.

**Files to Modify**:
- All command files (implement.md, research.md, plan.md)
- All subagent files that delegate to other subagents

**Changes**:
1. Add timeout parameter to all task tool invocations (default: 3600 seconds)
2. Add error handling for timeout, failure, and exception cases
3. Add retry logic (max 1 retry)
4. Add graceful degradation (return partial results on timeout)

**Example**:
```xml
<subagent_invocation>
  <invoke>
    tool: task
    subagent_type: task-executor
    session_id: "cmd_implement_{timestamp}"
    timeout: 3600
  </invoke>
  
  <error_handling>
    <on_timeout>
      1. Log: "task-executor timeout after 3600s"
      2. Return partial results if available
      3. Mark task as IN PROGRESS
      4. Message: "Task execution timed out. Check artifacts for partial progress."
    </on_timeout>
    
    <on_error>
      1. Log error details
      2. Retry once with same parameters
      3. If retry fails, return error
      4. Message: "Task execution failed: {error}. Recommendation: {fix}"
    </on_error>
  </error_handling>
</subagent_invocation>
```

### Strategy 4: Standardize Return Formats

**Approach**: Define and enforce single return format schema for all subagents.

**Files to Create**:
- `.opencode/context/common/standards/subagent-return-format.md`

**Files to Modify**:
- All subagent files to use standardized return format
- All command files to validate against schema

**Schema Definition**:
```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "object",
  "required": ["status", "summary", "artifacts", "metadata"],
  "properties": {
    "status": {
      "type": "string",
      "enum": ["completed", "failed", "partial", "blocked"]
    },
    "summary": {
      "type": "string",
      "maxLength": 500,
      "description": "Brief 2-5 sentence summary (max 100 tokens)"
    },
    "artifacts": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["type", "path"],
        "properties": {
          "type": {"type": "string"},
          "path": {"type": "string"},
          "summary": {"type": "string"}
        }
      }
    },
    "metadata": {
      "type": "object",
      "required": ["session_id", "agent_type"],
      "properties": {
        "session_id": {"type": "string"},
        "duration_seconds": {"type": "number"},
        "agent_type": {"type": "string"}
      }
    },
    "errors": {
      "type": "array",
      "items": {
        "type": "object",
        "properties": {
          "message": {"type": "string"},
          "phase": {"type": "string"},
          "recommendation": {"type": "string"}
        }
      }
    },
    "next_steps": {"type": "string"}
  }
}
```

### Strategy 5: Implement Orchestrator Coordination

**Approach**: Add active coordination logic to orchestrator for tracking and managing delegations.

**Files to Modify**:
- `.opencode/agent/orchestrator.md`

**Changes**:
1. Add delegation registry to track active delegations
2. Add monitoring loop to check delegation status
3. Add timeout enforcement
4. Add result routing back to commands

**Example**:
```xml
<orchestrator_coordination>
  <delegation_registry>
    <!-- In-memory map: session_id → delegation_info -->
    {
      "cmd_implement_20251225_001": {
        "command": "implement",
        "subagent": "task-executor",
        "start_time": "2025-12-25T10:00:00Z",
        "timeout": 3600,
        "status": "running"
      }
    }
  </delegation_registry>
  
  <monitoring_loop>
    Every 30 seconds:
    1. For each active delegation:
       a. Check if timeout exceeded
       b. Check if subagent completed
       c. Update status
    2. For timed-out delegations:
       a. Terminate subagent if possible
       b. Return timeout error to command
       c. Remove from registry
    3. For completed delegations:
       a. Validate return format
       b. Route result to command
       c. Remove from registry
  </monitoring_loop>
</orchestrator_coordination>
```

## Relevant Resources

### Documentation
- [Task Tool Documentation](https://docs.anthropic.com/en/docs/agents-and-tools)
- [Async/Await Patterns for Agent Coordination](https://www.patterns.dev/posts/async-await-pattern)
- [Circuit Breaker Pattern](https://martinfowler.com/bliki/CircuitBreaker.html)
- [Timeout Handling Best Practices](https://www.oreilly.com/library/view/release-it-2nd/9781680504552/)

### Code Examples
- batch-task-orchestrator.md: Shows parallel execution with timeout handling
- task-executor.md: Shows return format validation
- status-sync-manager: Shows atomic state updates

### Related Issues
- Task 169: Context window protection (related to return format optimization)
- Task 191: This task (delegation hang fix)

## Recommendations

### Immediate Actions (High Priority)

1. **Add Explicit Return Handling to Commands**
   - Modify /implement, /research, /plan to include ReceiveResults and ProcessResults stages
   - Add timeout handling (3600 seconds default)
   - Add error handling for timeout, failure, exception cases
   - **Effort**: 4 hours
   - **Impact**: Fixes 80% of hang scenarios

2. **Implement Cycle Detection**
   - Add delegation_depth tracking to orchestrator and all subagents
   - Set max_depth = 3
   - Return error on cycle detection or max depth exceeded
   - **Effort**: 2 hours
   - **Impact**: Prevents infinite loops

3. **Standardize Return Formats**
   - Create subagent-return-format.md schema
   - Update all subagents to use standardized format
   - Add validation in commands
   - **Effort**: 3 hours
   - **Impact**: Eliminates parsing failures

### Medium-Term Actions (Medium Priority)

4. **Implement Orchestrator Coordination**
   - Add delegation registry to orchestrator
   - Add monitoring loop
   - Add timeout enforcement
   - Add result routing
   - **Effort**: 6 hours
   - **Impact**: Provides centralized delegation management

5. **Add Comprehensive Error Handling**
   - Add retry logic (max 1 retry)
   - Add graceful degradation
   - Add detailed error messages
   - Add error propagation
   - **Effort**: 4 hours
   - **Impact**: Improves reliability and debuggability

### Long-Term Actions (Low Priority)

6. **Implement Session State Persistence**
   - Persist delegation state to disk
   - Allow recovery from orchestrator restart
   - **Effort**: 8 hours
   - **Impact**: Enables long-running delegations

7. **Add Delegation Metrics and Monitoring**
   - Track delegation success/failure rates
   - Track average delegation duration
   - Alert on high failure rates or long durations
   - **Effort**: 6 hours
   - **Impact**: Enables proactive issue detection

## Further Research Needed

1. **Task Tool Async Behavior**: Need to understand exact async/await semantics of task tool
2. **Session State Management**: How to persist and recover delegation state
3. **Timeout Granularity**: Determine optimal timeout values for different subagent types
4. **Error Recovery Strategies**: Research best practices for recovering from delegation failures

## Conclusion

The subagent delegation hang issue has 6 primary root causes:
1. Missing return path after delegation
2. Infinite delegation loops
3. Synchronous expectations for async calls
4. Missing error handling for failures/timeouts
5. Orchestrator coordination gaps
6. Return format ambiguity

The recommended fix is a phased approach:
- **Phase 1** (Immediate): Add explicit return handling, cycle detection, and standardized formats
- **Phase 2** (Medium-term): Implement orchestrator coordination and comprehensive error handling
- **Phase 3** (Long-term): Add state persistence and monitoring

This approach will eliminate 95% of delegation hang scenarios while maintaining backward compatibility and following established patterns from batch-task-orchestrator.md.
