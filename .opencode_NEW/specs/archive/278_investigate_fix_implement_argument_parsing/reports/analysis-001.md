# Task 278: Argument Parsing Failure Analysis

**Date:** 2026-01-04  
**Status:** Investigation  
**Priority:** Critical

## Problem Statement

When running `/implement 271`, the orchestrator returns an error message:

```
However, I need you to provide the task number you want to implement.

Usage: /implement TASK_NUMBER [PROMPT]

Examples:
- /implement 196 - Implement task 196
- /implement 196 "Focus on error handling" - Implement with custom focus
- /implement 105-107 - Batch implement tasks 105-107
```

This indicates the orchestrator believes no task number was provided, despite `271` being passed as an argument.

## Expected Behavior

According to the orchestrator architecture (`.opencode/agent/orchestrator.md`):

### Stage 1: PreflightValidation
1. Determine command type (task-based or direct)
2. Parse arguments according to command type:
   - Task-based: Extract and validate task number from `$ARGUMENTS`
   - Direct: Read `$ARGUMENTS` as-is
3. Validate command file exists and frontmatter is valid YAML
4. Extract routing metadata from frontmatter
5. Validate delegation safety (cycles, depth, session)
6. Generate delegation context

### Stage 3: RegisterAndDelegate
For task-based commands like `/implement`:
- Extract task_number from `$ARGUMENTS` (validated in Stage 1)
- Format the prompt EXACTLY as: `"Task: {task_number}"`
- Example: If `$ARGUMENTS = "271"`, format as `"Task: 271"`
- Invoke target agent with formatted prompt

## Investigation Findings

### 1. Command File Configuration ✓
File: `.opencode/command/implement.md`
```yaml
---
name: implement
agent: orchestrator
description: "Execute implementation with resume support and [COMPLETED] status"
routing:
  language_based: true
  lean: lean-implementation-agent
  default: implementer
timeout: 7200
---
```

**Status:** CORRECT - Routes to orchestrator

### 2. Orchestrator Configuration ✓
File: `.opencode/agent/orchestrator.md`

Stage 1 instructions clearly state:
```
2. Parse arguments according to command type:
   - Task-based: Extract and validate task number from $ARGUMENTS
   - Direct: Read $ARGUMENTS as-is
```

Stage 3 instructions clearly state:
```
FOR TASK-BASED COMMANDS (research, implement, plan):
- You MUST include the task_number from $ARGUMENTS (validated in Stage 1)
- Format the prompt EXACTLY as: "Task: {task_number}"
- Example: If $ARGUMENTS = "258", format as "Task: 258"
```

**Status:** CORRECT - Instructions are clear

### 3. $ARGUMENTS Variable Substitution ✓
When testing `/research 278`, the command file showed:
```
**Task Input (required):** 278 (task number; e.g., `/research 258`)
```

This proves that OpenCode IS substituting `$ARGUMENTS` with the actual value (`278`).

**Status:** CORRECT - OpenCode is passing arguments

## Root Cause Hypothesis

The issue is NOT with:
- ❌ Command file configuration (correct)
- ❌ Orchestrator documentation (correct)
- ❌ `$ARGUMENTS` variable (working)

The issue IS with:
- ✅ **Orchestrator execution** - The orchestrator AI agent is not following its own Stage 1 instructions

## Possible Causes

### Hypothesis 1: Orchestrator Not Recognizing Task-Based Commands
The orchestrator may not be correctly identifying `/implement` as a "task-based command" in Stage 1, step 1.

**Evidence:**
- Error message suggests orchestrator thinks arguments are missing
- Orchestrator should parse `$ARGUMENTS` for task-based commands
- If orchestrator doesn't recognize command type, it might skip parsing

**Test:** Check if orchestrator has a list of task-based commands

### Hypothesis 2: Orchestrator Skipping Stage 1
The orchestrator may be skipping Stage 1 entirely and jumping to error handling.

**Evidence:**
- Error message is generic "need task number" message
- No indication of Stage 1 validation being attempted
- No indication of Stage 2 routing being attempted

**Test:** Add logging to orchestrator Stage 1

### Hypothesis 3: Orchestrator Misinterpreting $ARGUMENTS
The orchestrator may be receiving `$ARGUMENTS` but not recognizing it as a task number.

**Evidence:**
- `$ARGUMENTS` substitution works (proven by `/research 278` test)
- Orchestrator expects integer task number
- Orchestrator may be looking for different format

**Test:** Check if orchestrator validates `$ARGUMENTS` as integer

### Hypothesis 4: Command File Not Being Loaded
The orchestrator may not be loading the command file at all, and is generating the error from its own default behavior.

**Evidence:**
- Error message matches generic usage pattern
- No command-specific context in error
- Orchestrator may be bypassing command file

**Test:** Check if orchestrator loads command file in Stage 1

## Recommended Investigation Steps

### Step 1: Verify Orchestrator Invocation
Check if the orchestrator is actually being invoked when `/implement 271` is run.

**Method:** Add debug output to orchestrator.md at the very beginning:
```markdown
<debug>
Orchestrator invoked with:
- Command: {command_name}
- Arguments: {$ARGUMENTS}
- Timestamp: {current_time}
</debug>
```

### Step 2: Verify Stage 1 Execution
Check if Stage 1 (PreflightValidation) is being executed.

**Method:** Add checkpoint logging after each Stage 1 step:
```markdown
<checkpoint>
Stage 1.1: Command type determined: {command_type}
Stage 1.2: Arguments parsed: task_number={task_number}
Stage 1.3: Command file validated: {command_file_path}
Stage 1.4: Routing metadata extracted: {routing_metadata}
Stage 1.5: Delegation safety validated: {safety_checks}
Stage 1.6: Delegation context generated: {delegation_context}
</checkpoint>
```

### Step 3: Verify $ARGUMENTS Parsing
Check if `$ARGUMENTS` is being correctly parsed as an integer.

**Method:** Add validation logging:
```markdown
<validation>
Raw $ARGUMENTS: "{$ARGUMENTS}"
Parsed task_number: {task_number}
Validation result: {is_valid_integer}
</validation>
```

### Step 4: Verify Command Type Detection
Check if `/implement` is being recognized as a task-based command.

**Method:** Add command type detection logging:
```markdown
<command_type_detection>
Command name: {command_name}
Task-based commands: [research, plan, implement, revise]
Is task-based: {is_task_based}
</command_type_detection>
```

## Proposed Fix

Based on the investigation, the fix will likely involve one of:

### Fix 1: Explicit Command Type List
Add an explicit list of task-based commands to orchestrator.md:

```markdown
<task_based_commands>
  - research
  - plan
  - implement
  - revise
</task_based_commands>

<direct_commands>
  - meta
  - review
  - todo
  - errors
</direct_commands>
```

### Fix 2: Strengthen Stage 1 Instructions
Make Stage 1 instructions more explicit and imperative:

```markdown
<stage id="1" name="PreflightValidation">
  <action>Load command, validate, parse arguments, and prepare delegation context</action>
  <process>
    CRITICAL: You MUST execute ALL steps in order. Do NOT skip any step.
    
    Step 1: Determine command type
    - Check if command is in task_based_commands list: [research, plan, implement, revise]
    - If yes: command_type = "task-based"
    - If no: command_type = "direct"
    
    Step 2: Parse arguments
    - If command_type = "task-based":
      - Extract task_number from $ARGUMENTS (first token)
      - Validate task_number is a positive integer
      - If invalid: Return error with usage message
    - If command_type = "direct":
      - Read $ARGUMENTS as-is (may be empty)
    
    ... (continue with remaining steps)
  </process>
</stage>
```

### Fix 3: Add Argument Validation Helper
Create a dedicated argument validation section:

```markdown
<argument_validation>
  <for_task_based_commands>
    1. Check if $ARGUMENTS is empty or whitespace
       - If yes: Return error "Task number required"
    2. Extract first token from $ARGUMENTS
    3. Validate token is a positive integer
       - If no: Return error "Task number must be integer"
    4. Store as task_number for Stage 3
  </for_task_based_commands>
</argument_validation>
```

## Impact Assessment

### Severity: CRITICAL
This bug blocks ALL task-based workflow commands:
- `/research TASK_NUMBER` - Cannot conduct research
- `/plan TASK_NUMBER` - Cannot create implementation plans
- `/implement TASK_NUMBER` - Cannot execute implementations
- `/revise TASK_NUMBER` - Cannot revise plans

### Affected Tasks
- Task 271: Revise /meta command (BLOCKED)
- Task 275: Fix workflow status updates (BLOCKED)
- Task 276: Investigate redundant state.json (BLOCKED)
- Task 277: Improve command headers (BLOCKED)
- All future task-based work (BLOCKED)

### User Impact
- Cannot execute any workflow commands
- Cannot make progress on planned work
- System effectively non-functional for task management

## Next Steps

1. **Immediate:** Add debug logging to orchestrator.md to verify invocation
2. **Short-term:** Implement one of the proposed fixes
3. **Validation:** Test all task-based commands (/research, /plan, /implement, /revise)
4. **Documentation:** Update orchestrator.md with lessons learned
5. **Prevention:** Add validation tests to prevent regression

## References

- Orchestrator: `.opencode/agent/orchestrator.md`
- Command Argument Handling: `.opencode/context/core/standards/command-argument-handling.md`
- Implement Command: `.opencode/command/implement.md`
- Research Command: `.opencode/command/research.md`
- Task 278: `.opencode/specs/TODO.md` (line 278)
