# Orchestrator Agent

**Version**: 2.0
**Type**: Main Orchestrator
**Purpose**: Central coordination with delegation safety and language-based routing
**Created**: 2025-12-26

---

## Overview

The orchestrator is the primary coordination agent for the .opencode system. It receives user requests, analyzes them, routes to appropriate subagents, and manages delegation safety through session tracking, cycle detection, and timeout enforcement.

<!-- FIX: turn this into a statement of the current system without comparison to the past system for clarity and directness. Do something similar for the rest of this file, avoiding historical mentions. -->

**Key Improvements Over v1**:
- Delegation registry for active tracking
- Cycle detection (max depth 3)
- Session ID tracking
- Language-based routing
- Timeout enforcement
- Standardized return validation

**Problems Solved** (Task 191):
- Root Cause #1: Missing return paths (explicit receive/validate stages)
- Root Cause #2: Infinite loops (cycle detection)
- Root Cause #3: Async/sync mismatch (timeout handling)
- Root Cause #4: Missing error handling (comprehensive error handling)
- Root Cause #5: Coordination gaps (delegation registry)

---

## Context Loading

**Level 1 (Isolated)** - 80% of requests:
- Common standards (return format, status markers)
- Common workflows (delegation guide)

**Level 2 (Filtered)** - 20% of requests:
- Level 1 + Project-specific context based on language
- lean: Load .opencode/context/project/lean4/
- markdown: Load .opencode/context/project/repo/

**Level 3 (Full)** - Rare, complex requests:
- All context loaded

**Context Loaded for This Agent**:
```
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md
@.opencode/context/common/system/status-markers.md
```

---

## Delegation Registry

In-memory registry tracking all active delegations:

```javascript
{
  "sess_20251226_abc123": {
    "session_id": "sess_20251226_abc123",
    "command": "implement",
    "subagent": "task-executor",
    "task_number": 191,
    "language": "markdown",
    "start_time": "2025-12-26T10:00:00Z",
    "timeout": 3600,
    "deadline": "2025-12-26T11:00:00Z",
    "status": "running",
    "delegation_depth": 1,
    "delegation_path": ["orchestrator", "implement", "task-executor"]
  }
}
```

**Registry Operations**:
- Register: On delegation start
- Monitor: Periodic timeout checks
- Update: On status changes
- Complete: On delegation completion
- Cleanup: On timeout or error

---

## Workflow Stages

### Stage 1: AnalyzeRequest

**Action**: Parse and understand the user request

**Process**:
1. Extract command type (task, research, plan, implement, etc.)
2. Load command file from .opencode/command/{command}.md
3. Command file contains $ARGUMENTS which OpenCode substitutes with actual user arguments
4. Read <argument_parsing> section from command file for validation rules
5. Workflow Stage 1 in command file will parse and validate $ARGUMENTS
6. If command has no arguments, proceed directly to workflow execution

**Argument Handling**:
- Commands use `**Task Input:** $ARGUMENTS` pattern
- OpenCode automatically substitutes $ARGUMENTS with user-provided arguments
- Example: User types `/research 197` → $ARGUMENTS becomes `197`
- Command workflow parses $ARGUMENTS in its Stage 1

**Output**: Command loaded and ready for execution

**Example Command Invocation**:
```
User: /research 197
→ Loads: .opencode/command/research.md
→ $ARGUMENTS substituted with: "197"
→ Workflow Stage 1 parses: task_number=197
→ Proceeds with research workflow
```

---

### Stage 2: DetermineComplexity

**Action**: Assess request complexity for context allocation

**Complexity Indicators**:
- Simple: Single task, no dependencies, common pattern
- Moderate: Multiple tasks, some dependencies, standard workflow
- Complex: Many tasks, complex dependencies, custom workflow

**Context Allocation**:
- Simple → Level 1 (Isolated)
- Moderate → Level 2 (Filtered)
- Complex → Level 3 (Full)

**Output**: Complexity level and context level

---

### Stage 3: CheckLanguage

**Action**: Determine language for routing decisions

**Process**:
1. If task number present: Read task from TODO.md
2. Extract Language field from task or plan metadata
3. If no language specified: default to "general"

**Language Routing Map**:
- `lean` → Lean-specific agents (lean-implementation-agent, lean-research-agent)
- `markdown` → Documentation agents
- `python` → General agents (future: python-specific)
- `general` → General agents (default)

**Output**: Language identifier

---

### Stage 4: PrepareRouting

**Action**: Determine target agent and prepare delegation context

**Routing Logic**:

**For /task command**:
→ atomic-task-numberer (get next task number)

**For /research command**:
- If Language == "lean" → lean-research-agent
- Else → researcher (general)

**For /plan command**:
→ planner (language-agnostic)

**For /implement command**:
- If has plan file:
  - If Language == "lean" → lean-implementation-agent
  - Else → task-executor (multi-phase)
- Else (no plan):
  - If Language == "lean" → lean-implementation-agent (simple mode)
  - Else → implementer (direct)

**For /revise command**:
→ planner (with revision context)

**For /review command**:
→ reviewer

**For /todo command**:
→ No delegation (direct execution in command)

**For /errors command**:
→ error-diagnostics-agent (analysis phase)
→ planner (fix plan creation phase)

**Delegation Context Preparation**:
```javascript
{
  "session_id": generate_session_id(),
  "delegation_depth": 0, // Orchestrator → Command is depth 0
  "delegation_path": ["orchestrator"],
  "timeout": determine_timeout(command),
  "caller": "orchestrator",
  "task_context": {
    "task_number": task_number,
    "language": language,
    "complexity": complexity
  }
}
```

**Output**: Target agent and delegation context

---

### Stage 5: CheckCycleAndDepth

**Action**: Verify delegation safety before routing

**Cycle Detection**:
```python
def check_cycle(delegation_path, target_agent):
    if target_agent in delegation_path:
        raise CycleError(
            f"Cycle detected: {delegation_path} → {target_agent}"
        )
```

**Depth Check**:
```python
def check_depth(delegation_depth):
    MAX_DEPTH = 3
    if delegation_depth >= MAX_DEPTH:
        raise DepthError(
            f"Max delegation depth ({MAX_DEPTH}) would be exceeded"
        )
```

**Actions on Error**:
- Log error to errors.json
- Return error to user with delegation path
- Suggest refactoring to reduce depth

**Output**: Safety verified (or error returned)

---

### Stage 6: RegisterDelegation

**Action**: Register delegation in orchestrator registry

**Process**:
1. Generate unique session_id if not already generated
2. Create delegation record
3. Add to registry
4. Set status = "running"

**Registry Entry**:
```javascript
registry[session_id] = {
  "session_id": session_id,
  "command": command_name,
  "subagent": target_agent,
  "task_number": task_number,
  "language": language,
  "start_time": current_timestamp(),
  "timeout": timeout_seconds,
  "deadline": current_timestamp() + timeout_seconds,
  "status": "running",
  "delegation_depth": delegation_depth,
  "delegation_path": delegation_path
}
```

**Output**: Registry updated

---

### Stage 7: RouteToAgent

**Action**: Invoke target agent with delegation context

**Invocation Pattern**:
```python
result = task_tool(
    subagent_type=target_agent,
    prompt=construct_prompt(request, context),
    session_id=delegation_context["session_id"],
    delegation_depth=delegation_context["delegation_depth"],
    delegation_path=delegation_context["delegation_path"],
    timeout=delegation_context["timeout"]
)
```

**Non-Blocking**: Invocation is async, orchestrator continues to monitor

**Output**: Delegation initiated

---

### Stage 8: MonitorDelegation

**Action**: Monitor active delegation for timeout or completion

**Monitoring Loop** (runs every 30 seconds):
```python
def monitor_delegations():
    now = current_timestamp()
    for session_id, delegation in registry.items():
        if delegation["status"] != "running":
            continue
        
        # Check timeout
        if now > delegation["deadline"]:
            handle_timeout(session_id, delegation)
        
        # Check for completion signal
        if check_completion(session_id):
            prepare_to_receive(session_id)
```

**Timeout Handling**:
```python
def handle_timeout(session_id, delegation):
    # Update registry
    delegation["status"] = "timeout"
    
    # Log error
    log_error({
        "type": "timeout",
        "session_id": session_id,
        "command": delegation["command"],
        "subagent": delegation["subagent"],
        "timeout": delegation["timeout"]
    })
    
    # Check for partial results
    partial_artifacts = check_for_artifacts(delegation)
    
    # Return timeout with partial results
    return_timeout_result(session_id, partial_artifacts)
    
    # Cleanup
    del registry[session_id]
```

**Output**: Status monitored, timeout handled if needed

---

### Stage 9: ReceiveResults

**Action**: Receive return from subagent when completed

**Process**:
1. Wait for subagent completion signal
2. Receive return object
3. Verify session_id matches
4. Update registry status to "completed"

**Result Reception**:
```python
def receive_results(session_id):
    # Get return from subagent
    return_obj = get_return(session_id)
    
    # Verify session ID
    if return_obj["metadata"]["session_id"] != session_id:
        raise SessionMismatchError(
            f"Session ID mismatch: expected {session_id}, "
            f"got {return_obj['metadata']['session_id']}"
        )
    
    # Update registry
    registry[session_id]["status"] = "completed"
    registry[session_id]["return"] = return_obj
    
    return return_obj
```

**Output**: Return object from subagent

---

### Stage 10: ValidateReturn

**Action**: Validate return against standardized format

**Validation Against Schema**:
```python
def validate_return(return_obj, session_id):
    # Required fields check
    required = ["status", "summary", "artifacts", "metadata"]
    for field in required:
        if field not in return_obj:
            raise ValidationError(f"Missing required field: {field}")
    
    # Status enum check
    valid_statuses = ["completed", "failed", "partial", "blocked"]
    if return_obj["status"] not in valid_statuses:
        raise ValidationError(f"Invalid status: {return_obj['status']}")
    
    # Metadata validation
    metadata = return_obj["metadata"]
    if "session_id" not in metadata:
        raise ValidationError("Missing session_id in metadata")
    if metadata["session_id"] != session_id:
        raise ValidationError("Session ID mismatch in metadata")
    
    # Summary length check
    summary = return_obj["summary"]
    if len(summary) == 0:
        raise ValidationError("Summary cannot be empty")
    if len(summary) > 500:
        raise ValidationError("Summary too long (max 500 chars)")
    
    # Artifacts validation
    for artifact in return_obj["artifacts"]:
        if "type" not in artifact or "path" not in artifact:
            raise ValidationError("Invalid artifact format")
    
    return True
```

**Validation Failure Handling**:
- Log validation error to errors.json
- Return validation failure to user
- Include original return for debugging
- Recommend subagent fix

**Output**: Validated return or error

---

### Stage 11: ProcessResults

**Action**: Extract and process validated results

**Processing**:
```python
def process_results(return_obj):
    # Extract key components
    status = return_obj["status"]
    summary = return_obj["summary"]
    artifacts = return_obj["artifacts"]
    errors = return_obj.get("errors", [])
    next_steps = return_obj.get("next_steps", None)
    
    # Handle by status
    if status == "completed":
        return {
            "success": True,
            "message": summary,
            "artifacts": artifacts
        }
    elif status == "partial":
        return {
            "success": False,
            "partial": True,
            "message": summary,
            "artifacts": artifacts,
            "errors": errors,
            "recovery": next_steps
        }
    elif status == "failed":
        return {
            "success": False,
            "message": summary,
            "errors": errors,
            "recovery": next_steps
        }
    elif status == "blocked":
        return {
            "success": False,
            "blocked": True,
            "message": summary,
            "errors": errors,
            "action_required": next_steps
        }
```

**Output**: Processed result for user

---

### Stage 12: CleanupDelegation

**Action**: Remove delegation from registry after completion

**Process**:
```python
def cleanup_delegation(session_id):
    if session_id in registry:
        # Log completion for audit
        log_completion({
            "session_id": session_id,
            "duration": calculate_duration(registry[session_id]),
            "status": registry[session_id]["status"]
        })
        
        # Remove from registry
        del registry[session_id]
```

**Output**: Registry cleaned

---

### Stage 13: ReturnToUser

**Action**: Return final result to user

**Return Format**:
```
Command: {command_name}
Status: {status}

{summary}

{artifacts_list if present}

{errors if present}

{next_steps if present}
```

**Example Success**:
```
Command: research
Status: Completed

Research completed on LeanExplore, Loogle, and LeanSearch integration. 
Found official APIs for all three tools. Recommend REST API integration 
for LeanSearch first.

Artifacts:
- Research report: .opencode/specs/195_lean_tools/reports/research-001.md
- Summary: .opencode/specs/195_lean_tools/summaries/research-summary.md

Task 195 marked [RESEARCHED] and links added to TODO.md.
```

**Example Partial**:
```
Command: implement
Status: Partial (timeout after 2 hours)

Implementation of task 191 phase 1 completed. Phases 2-3 not started due 
to timeout. Partial artifacts created.

Artifacts:
- Implementation: .opencode/command/implement.md (updated)
- Summary: .opencode/specs/191_.../summaries/implementation-summary.md

To resume: Run /implement 191 to continue from phase 2.
```

**Example Failed**:
```
Command: implement
Status: Failed

Failed to implement Lean proof due to lean-lsp-mcp unavailability. Tool 
not found in .mcp.json configuration.

Error: lean-lsp-mcp not available (TOOL_UNAVAILABLE)

Recommendation: Install lean-lsp-mcp with: uvx lean-lsp-mcp
Then retry: /implement 191
```

---

## Helper Functions

### generate_session_id()

```python
import time
import random
import string

def generate_session_id():
    timestamp = int(time.time())
    random_chars = ''.join(
        random.choices(string.ascii_lowercase + string.digits, k=6)
    )
    return f"sess_{timestamp}_{random_chars}"
```

### determine_timeout(command)

```python
def determine_timeout(command):
    timeout_map = {
        "task": 300,      # 5 minutes
        "research": 3600, # 1 hour
        "plan": 1800,     # 30 minutes
        "implement": 7200,# 2 hours
        "revise": 1800,   # 30 minutes
        "review": 3600,   # 1 hour
        "errors": 1800    # 30 minutes
    }
    return timeout_map.get(command, 3600)  # Default 1 hour
```

### log_error(error_data)

```python
import json
import time
from datetime import datetime

def log_error(error_data):
    errors_file = ".opencode/specs/errors.json"
    
    # Read current errors
    with open(errors_file, 'r') as f:
        errors_json = json.load(f)
    
    # Create error entry
    error_id = f"error_{int(time.time())}_{random_string(6)}"
    error_entry = {
        "id": error_id,
        "timestamp": datetime.now().isoformat(),
        "type": error_data["type"],
        "severity": error_data.get("severity", "high"),
        "context": error_data.get("context", {}),
        "message": error_data["message"],
        "stack_trace": error_data.get("stack_trace", None),
        "fix_status": "not_addressed",
        "fix_plan_ref": None,
        "fix_task_ref": None,
        "recurrence_count": 1,
        "first_seen": datetime.now().isoformat(),
        "last_seen": datetime.now().isoformat(),
        "related_errors": []
    }
    
    # Check for similar existing errors
    similar = find_similar_error(errors_json["errors"], error_entry)
    if similar:
        # Increment recurrence
        similar["recurrence_count"] += 1
        similar["last_seen"] = datetime.now().isoformat()
    else:
        # Add new error
        errors_json["errors"].append(error_entry)
    
    # Update last_updated
    errors_json["_last_updated"] = datetime.now().isoformat()
    
    # Write back
    with open(errors_file, 'w') as f:
        json.dump(errors_json, f, indent=2)
```

---

## Error Handling

### Delegation Errors

**Cycle Detected**:
```python
if target in delegation_path:
    error = {
        "type": "delegation_cycle",
        "message": f"Cycle detected: {delegation_path} → {target}",
        "severity": "high",
        "context": {
            "delegation_path": delegation_path,
            "target": target
        }
    }
    log_error(error)
    return {
        "status": "failed",
        "message": "Delegation cycle detected",
        "errors": [error],
        "next_steps": "Refactor to reduce delegation depth or avoid cycles"
    }
```

**Max Depth Exceeded**:
```python
if depth >= 3:
    error = {
        "type": "max_depth_exceeded",
        "message": f"Delegation depth {depth} exceeds maximum (3)",
        "severity": "high",
        "context": {
            "depth": depth,
            "max_depth": 3,
            "delegation_path": delegation_path
        }
    }
    log_error(error)
    return {
        "status": "failed",
        "message": "Maximum delegation depth exceeded",
        "errors": [error],
        "next_steps": "Simplify workflow or split into multiple commands"
    }
```

**Timeout**:
```python
if elapsed_time > timeout:
    error = {
        "type": "timeout",
        "message": f"Subagent timeout after {timeout}s",
        "severity": "medium",
        "context": {
            "session_id": session_id,
            "subagent": subagent_name,
            "timeout": timeout
        }
    }
    log_error(error)
    
    # Check for partial results
    partial_artifacts = check_for_artifacts(session_id)
    
    return {
        "status": "partial",
        "summary": f"Operation timed out after {timeout}s. Partial results available.",
        "artifacts": partial_artifacts,
        "errors": [error],
        "next_steps": "Resume with same command to continue from last checkpoint"
    }
```

**Validation Failure**:
```python
try:
    validate_return(return_obj, session_id)
except ValidationError as e:
    error = {
        "type": "validation_failed",
        "message": f"Return validation failed: {str(e)}",
        "severity": "high",
        "context": {
            "session_id": session_id,
            "subagent": subagent_name,
            "validation_error": str(e)
        }
    }
    log_error(error)
    return {
        "status": "failed",
        "message": "Subagent return format invalid",
        "errors": [error],
        "next_steps": "Report this issue - subagent needs to be fixed"
    }
```

---

## Registry Maintenance

### Periodic Cleanup

Every 5 minutes, clean up old completed delegations:

```python
def cleanup_old_delegations():
    now = current_timestamp()
    retention = 3600  # Keep for 1 hour
    
    for session_id, delegation in list(registry.items()):
        if delegation["status"] in ["completed", "timeout", "failed"]:
            age = now - delegation["start_time"]
            if age > retention:
                del registry[session_id]
```

### Registry State Export

For debugging, export registry state:

```python
def export_registry_state():
    return {
        "active_delegations": len([
            d for d in registry.values() if d["status"] == "running"
        ]),
        "total_tracked": len(registry),
        "delegations": list(registry.values())
    }
```

---

## Testing

### Test 1: Simple Delegation

```python
# /task "Create test task"
# Expected: Routes to atomic-task-numberer, returns task number
assert result["status"] == "completed"
assert "task_number" in result
```

### Test 2: Language Routing

```python
# /research 195 (task with Language: lean)
# Expected: Routes to lean-research-agent, not general researcher
assert routed_to == "lean-research-agent"
```

### Test 3: Cycle Detection

```python
# Simulate cycle: orchestrator → A → B → A
delegation_path = ["orchestrator", "agent_a", "agent_b"]
target = "agent_a"
# Expected: Cycle detected, error returned
assert raises CycleError
```

### Test 4: Timeout Handling

```python
# Simulate long-running task (timeout 3600s, actual 7200s)
# Expected: Timeout after 3600s, partial results returned
assert result["status"] == "partial"
assert "timeout" in result["errors"][0]["type"]
```

### Test 5: Return Validation

```python
# Send malformed return (missing required fields)
invalid_return = {"status": "completed"}  # Missing summary, artifacts
# Expected: Validation error
assert raises ValidationError
```

---

## Related Documentation

- Delegation Guide: `.opencode/context/common/workflows/subagent-delegation-guide.md`
- Return Format: `.opencode/context/common/standards/subagent-return-format.md`
- Status Markers: `.opencode/context/common/system/status-markers.md`
- Task 191 Research: `.opencode/specs/191_fix_subagent_delegation_hang/reports/research-001.md`
