---
name: task
agent: orchestrator
description: Create, recover, divide, sync, or abandon tasks
timeout: 1800
routing:
  language_based: false
  flag_based: true
  create_command: task-creator
  recover_command: task-recovery
  sync_command: task-sync
  abandon_command: task-abandon
  review_command: reviewer-agent
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/standards/git-safety.md"
  max_context_size: 30000
---

**Task Input (required):** $ARGUMENTS

<context>
  <system_context>Task management with flag-based routing</system_context>
  <task_context>Parse command flags and route to appropriate task management subagent</task_context>
</context>

<role>Task management command agent - Parse flags and route to task management subagents</role>

<task>
  Parse command flags from $ARGUMENTS, determine operation mode, delegate to appropriate task management subagent
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse command flags and determine operation mode</action>
    <process>
      1. Parse command flags from $ARGUMENTS
         - $ARGUMENTS contains: "Task description" or "--recover RANGES" or "--expand N" or "--sync" or "--abandon RANGES" or "--review N"
         - Extract operation mode and parameters
       
      2. Validate operation mode
         - If no flags: mode = "create"
         - If --recover present: mode = "recover"
         - If --expand present: mode = "expand"  
         - If --sync present: mode = "sync"
         - If --abandon present: mode = "abandon"
         - If --review present: mode = "review"
         - Extract parameters for each mode
       
      3. Validate inputs for each mode
         case "$mode" in
           "create")
              if [ -z "$description" ]; then
                echo "Error: Task description required for create mode"
                echo "Usage: /task \"Task description\""
                exit 1
              fi
              ;;
           "recover")
              if [ -z "$task_ranges" ]; then
                echo "Error: Task ranges required for recover mode"
                echo "Usage: /task --recover \"105-107\""
                exit 1
              fi
              ;;
           "expand")
              if [ -z "$task_expand" ]; then
                echo "Error: Task number and optional prompt required for expand mode"
                echo "Usage: /task --expand 196 \"Add error handling\""
                exit 1
              fi
              ;;
           "sync")
              # No additional validation needed for sync
              ;;
           "abandon")
              if [ -z "$task_ranges" ]; then
                echo "Error: Task ranges required for abandon mode"
                echo "Usage: /task --abandon \"105-107\""
                exit 1
              fi
              ;;
           "review")
              if [ -z "$task_review" ]; then
                echo "Error: Task number required for review mode"
                echo "Usage: /task --review 196"
                exit 1
              fi
              ;;
           *)
              echo "Error: Unknown mode $mode"
              exit 1
              ;;
         esac
       
      4. Validate specs/state.json exists and is valid
         - Check specs/state.json exists
         - Validate is valid JSON with jq
         - If missing/corrupt: Return error "Run /meta to regenerate state.json"
    </process>
    <checkpoint>Command parsed and validated, operation mode determined</checkpoint>
  </stage>
  
  <stage id="2" name="RouteAndExecute">
    <action>Route to appropriate task management subagent</action>
    <process>
      1. Select target subagent based on mode
         case "$mode" in
           "create")
              target_agent="task-creator"
              ;;
           "recover")
              target_agent="task-recovery"
              ;;
           "expand")
              target_agent="task-expander"
              ;;
           "sync")
              target_agent="task-sync"
              ;;
           "abandon")
              target_agent="task-abandon"
              ;;
           "review")
              target_agent="reviewer-agent"
              ;;
         esac
       
      2. Generate session_id for tracking
         - session_id="sess_$(date +%s)_$(head -c 6 /dev/urandom | base64 | tr -dc 'a-z0-9')"
         - Store for later use: expected_session_id="$session_id"
         - Log: "Generated session_id: ${session_id}"
       
      3. Invoke target subagent via task tool
         task(
           subagent_type="${target_agent}",
           prompt="{
             \"operation\": \"${mode}\",
             \"description\": \"${description}\",
             \"task_ranges\": \"${task_ranges}\",
             \"task_expand\": \"${task_expand}\",
             \"task_review\": \"${task_review}\",
             \"session_id\": \"${session_id}\",
             \"delegation_depth\": 1,
             \"delegation_path\": [\"orchestrator\", \"task\", \"${target_agent}\"]
           }",
           description="Execute ${mode} operation"
           session_id="${session_id}"
         )
       
      4. Wait for subagent to complete and capture return
         - Subagent returns JSON to stdout
         - Log: "${target_agent} completed, validating return"
         - Capture in variable: subagent_return
    </process>
    <checkpoint>Delegated to ${target_agent}, return captured</checkpoint>
  </stage>
  
  <stage id="3" name="ValidateReturn">
    <action>Validate subagent return format and artifacts</action>
    <process>
      1. Log return for debugging
         - Log first 500 chars of return
         - Log: "Validating return from ${target_agent}"
      
      2. VALIDATION STEP 1: Validate JSON Structure
         - Parse return as JSON using jq
         - If parsing fails:
           * Log error: "[FAIL] Invalid JSON return from ${target_agent}"
           * Return error to user: "Subagent return validation failed: Cannot parse return as JSON"
           * Recommendation: "Fix ${target_agent} subagent return format"
           * Exit with error
         - If parsing succeeds:
           * Log: "[PASS] Return is valid JSON"
      
      3. VALIDATION STEP 2: Validate Required Fields
         - Check required fields exist: status, summary, artifacts, metadata
         - Check metadata subfields exist: session_id, agent_type, delegation_depth, delegation_path
         - For each missing field:
           * Log error: "[FAIL] Missing required field: ${field}"
           * Return error to user: "Subagent return validation failed: Missing required field: ${field}"
           * Recommendation: "Fix ${target_agent} subagent to include all required fields"
           * Exit with error
         - If all fields present:
           * Log: "[PASS] All required fields present"
      
      4. VALIDATION STEP 3: Validate Status Field
         - Extract status from return: status=$(echo "$subagent_return" | jq -r '.status')
         - Check status is valid enum: completed, partial, failed, blocked
         - If status invalid:
           * Log error: "[FAIL] Invalid status: ${status}"
           * Log: "Valid statuses: completed, partial, failed, blocked"
           * Return error to user: "Subagent return validation failed: Invalid status: ${status}"
           * Recommendation: "Fix ${target_agent} subagent to use valid status enum"
           * Exit with error
         - If status valid:
           * Log: "[PASS] Status is valid: ${status}"
      
      5. VALIDATION STEP 4: Validate Session ID
         - Extract returned session_id: returned_session_id=$(echo "$subagent_return" | jq -r '.metadata.session_id')
         - Compare with expected session_id (from delegation context)
         - If mismatch:
           * Log error: "[FAIL] Session ID mismatch"
           * Log: "Expected: ${expected_session_id}"
           * Log: "Got: ${returned_session_id}"
           * Return error to user: "Subagent return validation failed: Session ID mismatch"
           * Recommendation: "Fix ${target_agent} subagent to return correct session_id"
           * Exit with error
         - If match:
           * Log: "[PASS] Session ID matches"
      
      6. VALIDATION STEP 5: Validate Artifacts (if applicable)
         - For task management operations, artifacts may be:
           - Created tasks (create mode)
           - Updated status files (sync mode)
           - Modified task entries (recover/abandon modes)
         - Validate operation-specific artifacts based on mode
    </process>
    <checkpoint>Subagent return validated, all checks passed</checkpoint>
  </stage>
  
  <stage id="4" name="RelayResult">
    <action>Relay validated result to user</action>
    <process>
      1. Extract key information from validated return
         - status=$(echo "$subagent_return" | jq -r '.status')
         - summary=$(echo "$subagent_return" | jq -r '.summary')
         - next_steps=$(echo "$subagent_return" | jq -r '.next_steps // "None"')
       
      2. Format response for user
         - Display operation status and summary
         - List artifacts created (if any)
         - Show next steps
      
      3. Return to user
    </process>
    <checkpoint>Result relayed to user</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
# Create new task
/task "Implement user authentication system"

# Recover tasks
/task --recover "105-107"

# Expand task with additional prompt
/task --expand 196 "Add comprehensive error handling"

# Sync TODO.md and state.json
/task --sync

# Abandon task ranges
/task --abandon "105-107"

# Review existing task
/task --review 196
```

## Operation Modes

| Mode | Subagent | Description | Example |
|-------|-----------|-------------|----------|
| create | task-creator | Creates new task entries | `/task "New feature"` |
| recover | task-recovery | Recovers abandoned tasks | `/task --recover "105-107"` |
| expand | task-expander | Expands existing tasks | `/task --expand 196 "Add details"` |
| sync | task-sync | Synchronizes state files | `/task --sync` |
| abandon | task-abandon | Archives completed tasks | `/task --abandon "105-107"` |
| review | reviewer-agent | Reviews existing tasks | `/task --review 196` |

## What This Does

1. Parses command flags to determine operation mode
2. Validates inputs for each operation mode
3. Routes to appropriate task management subagent based on mode
4. Executes operation-specific workflow (create, recover, expand, sync, abandon, review)
5. Validates subagent returns and artifacts
6. Relays results to user

## Features

- **Flag-Based Routing**: Supports 6 different operation modes
- **Session Tracking**: Consistent session management across all operations
- **Subagent Delegation**: Routes to specialized task management agents
- **Status Management**: Two-phase updates for state consistency
- **Artifact Validation**: Operation-specific artifact handling

See individual subagent files for detailed operation implementations.