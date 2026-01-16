---
name: task
agent: orchestrator
description: "Unified task lifecycle management: create, recover, divide, sync, abandon tasks"
context_level: 2
language: varies
routing:
  flag_based: true
  operations:
    create: task-creator
    recover: status-sync-manager
    divide: task-divider
    sync: status-sync-manager
    abandon: status-sync-manager
  default: task-creator
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/standards/subagent-return.md"
    - "core/workflows/status-transitions.md"
    - "core/orchestration/routing.md"
  optional:
    - "core/standards/task-management.md"
    - "core/orchestration/state-management.md"
  max_context_size: 40000
timeout: 120
---

**Task Input (required):** $ARGUMENTS (task description or flag with arguments)

**Usage:** `/task [--recover|--divide|--sync|--abandon] ARGS`

<context>
  <system_context>Unified task lifecycle management - create, recover, divide, sync, abandon tasks</system_context>
  <task_context>Parse flags and arguments, route to appropriate subagent, delegate for execution</task_context>
</context>

<role>Task lifecycle router - Parses flags and delegates to specialized subagents</role>

<task>Parse flags/arguments from $ARGUMENTS, route to appropriate subagent, return results</task>

<workflow_execution>
  <stage id="1" name="ParseArguments">
    <action>Parse flags and arguments from $ARGUMENTS</action>
    <process>
      1. Detect flag from $ARGUMENTS:
         - --recover: Unarchive tasks
         - --divide: Divide existing task
         - --sync: Synchronize files
         - --abandon: Archive tasks
         - No flag: Create new task
      
      2. Extract arguments based on flag pattern:
         - --recover TASK_RANGES
         - --divide TASK_NUMBER [PROMPT]
         - --sync [TASK_RANGES]
         - --abandon TASK_RANGES
         - DESCRIPTION [--priority] [--effort] [--language] [--divide]
      
      3. Validate single flag only
      4. Extract task metadata for creation scenarios
    </process>
    <validation>Single flag or none, required arguments present, formats valid</validation>
    <checkpoint>Arguments parsed and validated</checkpoint>
  </stage>
  
  <stage id="2" name="DelegateToSubagent">
    <action>Route to appropriate subagent based on flag and delegate</action>
    <process>
      1. Determine target subagent based on flag:
         - No flag or --divide with new task: task-creator
         - --recover: status-sync-manager (operation: unarchive_tasks)
         - --divide (existing task): task-divider
         - --sync: status-sync-manager (operation: sync_tasks)
         - --abandon: status-sync-manager (operation: archive_tasks)
      
      2. Prepare delegation context:
         - flag: detected flag or "create"
         - arguments: extracted arguments
         - session_id: generated for tracking
         - delegation_depth: 1
         - delegation_path: ["orchestrator", "task", "{subagent_name}"]
      
      3. Delegate to target subagent:
         task(
           subagent_type="{target_subagent}",
           prompt="{
             \"operation\": \"{operation_name}\",
             \"flag\": \"{flag}\",
             \"arguments\": \"{arguments}\",
             \"session_id\": \"{session_id}\",
             \"delegation_depth\": 2,
             \"delegation_path\": [\"orchestrator\", \"task\", \"{target_subagent}\"]
           }",
           description="Execute {operation_name} operation"
         )
      
      4. Wait for subagent return
      5. Validate return format (subagent-return.md)
      6. Extract results for user formatting
    </process>
    <validation>Subagent called successfully, return format valid</validation>
    <checkpoint>Operation delegated to subagent, results received</checkpoint>
  </stage>
  
  <stage id="3" name="ReturnResults">
    <action>Format and return subagent results to user</action>
    <process>
      1. Format success message based on operation type
      2. Include task numbers, ranges, or counts as appropriate
      3. Add next steps guidance if applicable
      4. Include git commit hash if provided
      5. Return formatted message to user
    </process>
    <validation>Message formatted correctly, includes relevant details</validation>
    <checkpoint>Results returned to user</checkpoint>
  </stage>
</workflow_execution>

## Usage

```bash
# Task creation (backward compatible)
/task "Implement feature X"
/task "Fix bug in module Y" --priority High
/task "Add documentation" --priority Medium --effort "2 hours" --language markdown
/task "Refactor system: update commands, fix agents, improve docs" --divide

# Task recovery (unarchive from archive/)
/task --recover 343                    # Recover single task
/task --recover 343-345                # Recover range (3 tasks)
/task --recover 337, 343-345, 350      # Recover list (5 tasks)

# Task division (divide existing task into subtasks)
/task --divide 326                     # Divide task 326 (AI analyzes description)
/task --divide 326 "Focus on UI, backend, tests"  # With guidance prompt

# Task synchronization (resolve conflicts between TODO.md and state.json)
/task --sync                           # Sync all tasks (default)
/task --sync 343-345                   # Sync range (3 tasks)
/task --sync 337, 343-345              # Sync list (5 tasks)

# Task abandonment (move to archive/)
/task --abandon 343-345                # Abandon range (3 tasks)
/task --abandon 337, 343-345, 350      # Abandon list (5 tasks)
```

## Flags

| Flag | Arguments | Description |
|------|-----------|-------------|
| (none) | DESCRIPTION [--priority] [--effort] [--language] [--divide] | Create new task(s) |
| --recover | TASK_RANGES | Unarchive tasks from archive/ |
| --divide | TASK_NUMBER [PROMPT] | Divide existing task into subtasks |
| --sync | [TASK_RANGES] | Synchronize TODO.md and state.json (default: all tasks) |
| --abandon | TASK_RANGES | Abandon tasks (move to archive/) |

## Architecture

**Modern Standards (v7.0)**:
- Simple 3-stage workflow: Parse → Delegate → Return
- All complex logic delegated to specialized subagents
- Flag-based routing with proper argument validation
- Commands under 300 lines (focus on routing, not implementation)
- Three-layer delegation: orchestrator → command → subagent
- Subagents own complete workflows and execution

**Subagent Responsibilities**:
- task-creator: Handle task creation with inline division logic
- status-sync-manager: Handle atomic state operations (create, recover, sync, abandon)
- task-divider: Handle existing task analysis and division
- Each subagent owns their complete workflow and git integration

**Performance**: Fast delegation routing, subagents handle heavy lifting