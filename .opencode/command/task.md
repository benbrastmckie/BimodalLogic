---
name: task
agent: orchestrator
description: "Unified task lifecycle management: create, recover, divide, sync, abandon tasks"
timeout: 120
---

**Task Input (required):** $ARGUMENTS (task description or flag with arguments)

**CRITICAL ARCHITECTURAL CONSTRAINT**: This command manages task lifecycle. Task creation NEVER implements tasks.

<context>
  <system_context>Unified task lifecycle management - create, recover, divide, sync, abandon tasks</system_context>
  <task_context>Parse flags and arguments, route to appropriate operation, delegate to specialized subagents</task_context>
  <architectural_constraint>
    Task creation is FORBIDDEN from implementing tasks. It only creates task entries.
    Implementation happens later via /implement command.
  </architectural_constraint>
</context>

<role>
  Task lifecycle manager - Routes task operations to specialized subagents based on flags
</role>

<task>
  Manage task lifecycle operations:
  1. Parse flags: --recover, --divide, --sync, --abandon, or none (create)
  2. Extract and validate arguments based on flag
  3. Route to appropriate stage based on flag
  4. Delegate to specialized subagents for execution
  5. Validate return format and results
  6. Return success message to user
  
  FORBIDDEN (for task creation): Implementing tasks, creating code files, running build tools
</task>

<workflow_execution>
  <stage id="1" name="ParseAndValidate">
    <action>Parse flags and arguments, validate inputs, route to appropriate stage</action>
    <process>
      1. Detect flag from $ARGUMENTS:
         - Check for --recover: Unarchive tasks from archive/
         - Check for --divide: Divide existing task into subtasks
         - Check for --sync: Synchronize TODO.md and state.json
         - Check for --abandon: Abandon tasks (move to archive/)
         - If no flag: Default to task creation (backward compatibility)
      
      2. Extract arguments based on flag:
         
         **--recover TASK_RANGES**:
         - Extract task_ranges after --recover
         - Examples: "343", "343-345", "337, 343-345, 350"
         - Validate non-empty
         - Route to Stage 4 (RecoverTasks)
         
         **--divide TASK_NUMBER [PROMPT]**:
         - Extract task_number after --divide (required)
         - Extract optional prompt (remaining arguments)
         - Validate task_number is positive integer
         - Route to Stage 5 (DivideExistingTask)
         
         **--sync [TASK_RANGES]**:
         - Extract optional task_ranges after --sync
         - If no ranges: sync ALL tasks (default)
         - Examples: "343-345", "337, 343-345"
         - Route to Stage 6 (SyncTasks)
         
         **--abandon TASK_RANGES**:
         - Extract task_ranges after --abandon (required)
         - Examples: "343-345", "337, 343-345, 350"
         - Validate non-empty
         - Route to Stage 7 (AbandonTasks)
         
         **No flag (task creation)**:
         - Extract task description (everything before first -- flag)
         - Extract optional flags: --priority, --effort, --language, --divide
         - Validate description non-empty
         - Route to Stage 2 (PrepareTasks)
      
      3. Validation gates:
         - Ensure only ONE flag present (--recover, --divide, --sync, --abandon, or none)
         - If multiple flags: Return error "Only one flag allowed at a time"
         - Validate required arguments present for each flag
         - Validate argument formats (integers, ranges, etc.)
      
      4. For task creation (no flag), validate no implementation keywords:
         - Keywords indicating implementation attempt:
           * "implement", "code", "write", "create file", "add function"
           * "fix bug", "refactor", "update code", "modify"
           * File extensions: ".lean", ".py", ".sh", ".md", ".json"
           * Directory paths: "src/", "lib/", ".opencode/"
         
         - If ANY implementation keywords found:
           Return error:
           ```
           Error: /task command creates TASK ENTRIES only, it does NOT implement tasks.
           
           Your description: "${description}"
           
           Detected implementation keywords: ${keywords_found}
           
           What you should do:
           1. Use /task to create a task entry: /task "Task description"
           2. Then use /implement to do the work: /implement {task_number}
           
           Example:
             /task "Implement feature X"  # Creates task entry
             /implement 350               # Implements the task
           ```
    </process>
    <validation>
      - Only one flag present (or none for task creation)
      - Required arguments present for each flag
      - Argument formats valid
      - For task creation: No implementation keywords detected
    </validation>
    <checkpoint>Input parsed, validated, and routed to appropriate stage</checkpoint>
  </stage>
  
  <stage id="2" name="PrepareTasks">
    <action>Prepare task list for creation (inline --divide for new tasks)</action>
    <process>
      This stage handles task creation (no flag or inline --divide for new tasks).
      
      1. Reformulate description naturally (inline, no subagent):
         - Clean and normalize (trim, remove multiple spaces, fix typos)
         - Ensure proper sentence structure (capitalize, punctuate)
         - Improve clarity (remove filler words, make imperative)
         - Generate title from description (first sentence or 80 chars)
         - Keep concise (2-3 sentences max)
      
      2. Detect language if not provided:
         - Check for keywords:
           * lean: "lean", "proof", "theorem", "lemma", "tactic", "axiom", "sorry"
           * markdown: "markdown", "doc", "readme", "documentation", "guide"
           * meta: "command", "agent", "subagent", "context", "workflow"
           * python: "python", ".py", "script"
           * shell: "shell", "bash", ".sh"
           * json: "json", "yaml", "toml", "config"
         - If no keywords match: language = "general"
         - If multiple match: use first match
      
      3. If --divide flag present (inline division for new task):
         - Analyze description for natural divisions:
           * Bullet points or numbered lists
           * "and" conjunctions
           * Comma-separated items
           * Sequential steps (first, then, finally)
           * Multiple verbs (implement X, add Y, fix Z)
         
         - Determine number of subtasks (1-5):
           * If no natural divisions: 1 task (no division)
           * If 2-5 divisions: create that many tasks
           * If >5 divisions: group into 5 logical subtasks
         
         - Generate subtask descriptions:
           * Each subtask self-contained with clear scope
           * Maintain original priority/effort for all
           * Number subtasks: "Task 1/3: ...", "Task 2/3: ...", etc.
      
      4. Prepare task list:
         - Array of task objects: [{title, description, priority, effort, language}, ...]
         - Validate each task has all required fields
         - Ensure total subtasks is 1-5
    </process>
    <validation>
      - If divide=false: task_list has 1 task
      - If divide=true: task_list has 1-5 tasks
      - Each task has: title, description, priority, effort, language
      - All tasks have same priority/effort/language
    </validation>
    <checkpoint>Task list prepared (1-5 tasks)</checkpoint>
  </stage>
  
  <stage id="3" name="CreateTasks">
    <action>Create task entries via task-creator subagent</action>
    <process>
      This stage handles task creation delegation.
      
      1. For each task in task_list:
         a. Delegate to task-creator subagent:
            - task_title: task.title
            - task_description: task.description
            - priority: task.priority
            - effort: task.effort
            - language: task.language
            - session_id: {session_id}
            - delegation_depth: {depth + 1}
            - delegation_path: [...path, "task-creator"]
         
         b. Wait for return from task-creator
         
         c. Validate return format:
            - Check status == "completed"
            - Extract task_number from return
            - Validate task_number is positive integer
         
         d. Collect task_number in created_tasks array
         
         e. Handle errors:
            - If task-creator fails: stop and return error
            - Include details of which task failed
            - List successfully created tasks (if any)
      
      2. Validate all tasks created:
         - Verify created_tasks array has expected length
         - Verify all task_numbers are unique
         - Verify all task_numbers are sequential (if multiple)
      
      3. Validate no artifacts created (architectural constraint):
         - Check return does NOT contain artifact paths
         - Verify only TODO.md and state.json were modified
         - If artifacts found: Return error (architectural violation)
    </process>
    <validation>
      - All tasks created successfully
      - All task_numbers valid and unique
      - No artifacts created (task entries only)
      - Only TODO.md and state.json modified
    </validation>
    <checkpoint>All tasks created atomically in TODO.md and state.json</checkpoint>
  </stage>
  
  <stage id="4" name="RecoverTasks">
    <action>Unarchive tasks from archive/ (--recover flag)</action>
    <process>
      This stage handles task recovery from archive/.
      
      1. Parse task_ranges from arguments:
         - Support single numbers: "337"
         - Support ranges: "343-345"
         - Support lists: "337, 343-345, 350"
         - Expand ranges to individual task numbers
         - Deduplicate task numbers
      
      2. Validate task ranges:
         - All task numbers are positive integers
         - All tasks exist in archive/state.json
         - No tasks already in active_projects
         - If validation fails: Return error with details
      
      3. Delegate to status-sync-manager:
         - operation: "unarchive_tasks"
         - task_numbers: [array of task numbers]
         - session_id: {session_id}
         - delegation_depth: {depth + 1}
         - delegation_path: [...path, "status-sync-manager"]
      
      4. Wait for return from status-sync-manager
      
      5. Validate return:
         - Check status == "completed"
         - Verify files_updated includes [TODO.md, state.json, archive/state.json]
         - Extract success_count and failure_count
         - If failures: Include error details
      
      6. Format success message:
         - "✅ Recovered {count} tasks from archive: {ranges}"
         - List task numbers recovered
         - Note: All tasks reset to [NOT STARTED] status
    </process>
    <validation>
      - Task ranges parsed correctly
      - All tasks exist in archive
      - Return format valid
      - Files updated correctly
    </validation>
    <checkpoint>Tasks recovered from archive, files updated atomically</checkpoint>
  </stage>
  
  <stage id="5" name="DivideExistingTask">
    <action>Divide existing task into subtasks (--divide flag)</action>
    <process>
      This stage handles division of existing tasks.
      
      1. Parse task_number and optional_prompt from arguments:
         - task_number is required (first argument after --divide)
         - optional_prompt is remaining arguments (if any)
         - Validate task_number is positive integer
      
      2. Validate task exists and can be divided:
         - Read task metadata from state.json
         - Verify task exists
         - Verify task status allows division (not COMPLETED or ABANDONED)
         - Verify task has no existing dependencies
         - If validation fails: Return error with details
      
      3. Delegate to task-divider subagent for analysis:
         - task_number: {task_number}
         - task_description: {from state.json}
         - optional_prompt: {optional_prompt}
         - session_id: {session_id}
         - delegation_depth: {depth + 1}
         - delegation_path: [...path, "task-divider"]
      
      4. Wait for return from task-divider:
         - Extract subtask_descriptions array (1-5 subtasks)
         - Validate subtask count is 1-5
      
      5. Create subtasks via task-creator:
         - For each subtask description:
           * Delegate to task-creator subagent
           * Collect task_number from return
           * If any creation fails: Rollback and abort
      
      6. Update parent task dependencies:
         - Delegate to status-sync-manager:
           * operation: "update_task_metadata"
           * task_number: {parent_task_number}
           * updated_fields: {"dependencies": [subtask_numbers]}
      
      7. Format success message:
         - "✅ Divided task {number} into {N} subtasks"
         - List subtask numbers and titles
         - Note: Parent task now depends on subtasks
    </process>
    <validation>
      - Task exists and can be divided
      - Subtask count is 1-5
      - All subtasks created successfully
      - Parent dependencies updated
    </validation>
    <checkpoint>Task divided into subtasks, parent dependencies updated</checkpoint>
  </stage>
  
  <stage id="6" name="SyncTasks">
    <action>Synchronize TODO.md and state.json (--sync flag)</action>
    <process>
      This stage handles synchronization with git blame conflict resolution.
      
      1. Parse task_ranges from arguments (optional):
         - If no ranges: sync ALL tasks (default)
         - If ranges provided: parse and expand
         - Support single numbers: "337"
         - Support ranges: "343-345"
         - Support lists: "337, 343-345, 350"
      
      2. Validate task ranges (if provided):
         - All task numbers are positive integers
         - All tasks exist in TODO.md or state.json
         - If validation fails: Return error with details
      
      3. Delegate to status-sync-manager:
         - operation: "sync_tasks"
         - task_ranges: [array of task numbers] or "all"
         - conflict_resolution: "git_blame"
         - session_id: {session_id}
         - delegation_depth: {depth + 1}
         - delegation_path: [...path, "status-sync-manager"]
      
      4. Wait for return from status-sync-manager
      
      5. Validate return:
         - Check status == "completed"
         - Verify files_updated includes [TODO.md, state.json]
         - Extract synced_tasks count
         - Extract conflicts_resolved count
         - Extract conflict resolution details
      
      6. Format success message:
         - "✅ Synced {count} tasks"
         - If conflicts resolved: "Resolved {count} conflicts using git blame"
         - Include conflict resolution summary
    </process>
    <validation>
      - Task ranges parsed correctly (or "all")
      - Return format valid
      - Files updated correctly
      - Conflicts resolved using git blame
    </validation>
    <checkpoint>Tasks synchronized, conflicts resolved using git blame</checkpoint>
  </stage>
  
  <stage id="7" name="AbandonTasks">
    <action>Abandon tasks (move to archive/) (--abandon flag)</action>
    <process>
      This stage handles task abandonment.
      
      1. Parse task_ranges from arguments:
         - Support single numbers: "337"
         - Support ranges: "343-345"
         - Support lists: "337, 343-345, 350"
         - Expand ranges to individual task numbers
         - Deduplicate task numbers
      
      2. Validate task ranges:
         - All task numbers are positive integers
         - All tasks exist in active_projects
         - If validation fails: Return error with details
      
      3. Delegate to status-sync-manager:
         - operation: "archive_tasks"
         - task_numbers: [array of task numbers]
         - reason: "abandoned"
         - session_id: {session_id}
         - delegation_depth: {depth + 1}
         - delegation_path: [...path, "status-sync-manager"]
      
      4. Wait for return from status-sync-manager
      
      5. Validate return:
         - Check status == "completed"
         - Verify files_updated includes [TODO.md, state.json, archive/state.json]
         - Extract success_count
      
      6. Format success message:
         - "✅ Abandoned {count} tasks: {ranges}"
         - List task numbers abandoned
         - Note: Tasks moved to archive/
    </process>
    <validation>
      - Task ranges parsed correctly
      - All tasks exist in active_projects
      - Return format valid
      - Files updated correctly
    </validation>
    <checkpoint>Tasks abandoned, moved to archive/ atomically</checkpoint>
  </stage>
  
  <stage id="8" name="ReturnSuccess">
    <action>Format and return success message based on operation</action>
    <process>
      This stage formats the final success message based on which operation was performed.
      
      1. Determine operation type:
         - Task creation (no flag)
         - Task recovery (--recover)
         - Task division (--divide)
         - Task synchronization (--sync)
         - Task abandonment (--abandon)
      
      2. Format success message based on operation:
         
         **Task Creation**:
         - If single task:
           ```
           ✅ Task {number} CREATED (not implemented): {title}
           
           Task Details:
           - Priority: {priority}
           - Effort: {effort}
           - Language: {language}
           - Status: [NOT STARTED]
           
           ⚠️  IMPORTANT: This task has been CREATED but NOT IMPLEMENTED.
           
           Next steps to IMPLEMENT this task:
             1. /research {number}  - Research the task
             2. /plan {number}      - Create implementation plan
             3. /implement {number} - Implement the task
           
           Or skip research/planning and implement directly:
             /implement {number}
           ```
         
         - If multiple tasks (--divide):
           ```
           ✅ Created {count} tasks (not implemented):
           - Task {number1}: {title1}
           - Task {number2}: {title2}
           - Task {number3}: {title3}
           
           All tasks:
           - Priority: {priority}
           - Effort: {effort}
           - Language: {language}
           - Status: [NOT STARTED]
           
           ⚠️  IMPORTANT: These tasks have been CREATED but NOT IMPLEMENTED.
           
           Next steps to IMPLEMENT these tasks:
             /research {number1}    - Research first task
             /implement {number1}   - Implement first task
             (Repeat for other tasks as needed)
           ```
         
         **Task Recovery**:
         ```
         ✅ Recovered {count} tasks from archive: {ranges}
         
         Recovered tasks:
         - Task {number1}: {title1}
         - Task {number2}: {title2}
         
         All tasks reset to [NOT STARTED] status.
         
         Next steps:
           /implement {number1}   - Implement recovered task
         ```
         
         **Task Division**:
         ```
         ✅ Divided task {number} into {N} subtasks
         
         Parent task: {number}. {title}
         
         Subtasks created:
         - Task {sub1}: {title1}
         - Task {sub2}: {title2}
         - Task {sub3}: {title3}
         
         Parent task now depends on subtasks.
         
         Next steps:
           /implement {sub1}   - Implement first subtask
         ```
         
         **Task Synchronization**:
         ```
         ✅ Synced {count} tasks
         
         Conflicts resolved: {conflicts_count}
         
         Conflict resolution summary:
         - Task {number1}: {field} from {source} (newer)
         - Task {number2}: {field} from {source} (newer)
         
         All tasks synchronized between TODO.md and state.json.
         ```
         
         **Task Abandonment**:
         ```
         ✅ Abandoned {count} tasks: {ranges}
         
         Abandoned tasks:
         - Task {number1}: {title1}
         - Task {number2}: {title2}
         
         Tasks moved to archive/.
         
         To recover: /task --recover {ranges}
         ```
      
      3. Return message to user
      
      4. STOP HERE. Operation complete.
    </process>
    <validation>
      - Success message formatted correctly
      - Task numbers/ranges included
      - Next steps provided (if applicable)
      - No artifacts created (for task creation)
    </validation>
    <checkpoint>Success message returned to user</checkpoint>
  </stage>
</workflow_execution>

<critical_constraints>
  <absolutely_forbidden>
    For task creation, this command MUST NOT:
    - Implement any tasks described in $ARGUMENTS
    - Create any code files (*.lean, *.py, *.sh, *.md, etc.)
    - Create any spec directories (.opencode/specs/{number}_*/)
    - Create any artifact files (research, plans, implementations)
    - Run any build tools (lake, python, lean, cargo, etc.)
    - Modify any project code or configuration
    - Do anything except create task entries in TODO.md and state.json
    
    If you find yourself thinking about HOW to implement the task:
    - STOP immediately
    - You are violating the command constraints
    - Return to creating the task entry only
  </absolutely_forbidden>
  
  <only_allowed_actions>
    The ONLY actions allowed:
    1. Parse flags and arguments from $ARGUMENTS
    2. Route to appropriate stage based on flag
    3. Delegate to specialized subagents (task-creator, status-sync-manager, task-divider)
    4. Validate return formats
    5. Return success messages to user
  </only_allowed_actions>
  
  <architectural_enforcement>
    Technical barriers to prevent implementation:
    - Command delegates to orchestrator (routes to specialized subagents)
    - task-creator has permissions that DENY code file writes
    - task-creator has permissions that DENY build tool execution
    - task-creator can ONLY write to TODO.md and state.json
    - Validation gates prevent architectural violations
  </architectural_enforcement>
</critical_constraints>

<validation>
  <pre_execution>
    - Flag validated (only one flag or none)
    - Arguments validated based on flag
    - Required arguments present
    - Argument formats valid
    - For task creation: No implementation keywords detected
  </pre_execution>
  
  <post_execution>
    - Operation completed successfully
    - Return format validated
    - Files updated correctly (TODO.md, state.json, archive/state.json as needed)
    - Success message formatted correctly
    - For task creation: NO implementation occurred, NO artifacts created
  </post_execution>
</validation>

<error_handling>
  <multiple_flags>
    If multiple flags present:
      - Return error: "Only one flag allowed at a time"
      - Show usage: "/task [--recover|--divide|--sync|--abandon] ARGS"
      - DO NOT proceed
  </multiple_flags>
  
  <missing_arguments>
    If required arguments missing:
      - Return error: "Missing required arguments for {flag}"
      - Show usage for that flag
      - DO NOT proceed
  </missing_arguments>
  
  <invalid_task_ranges>
    If task ranges invalid:
      - Return error: "Invalid task range format: {ranges}"
      - Show valid formats: "123", "123-125", "123, 125-127"
      - DO NOT proceed
  </invalid_task_ranges>
  
  <task_not_found>
    If task not found:
      - Return error: "Task {number} not found in {location}"
      - Suggest checking TODO.md or archive/state.json
      - DO NOT proceed
  </task_not_found>
  
  <subagent_failed>
    If subagent fails:
      - Return error: "Failed to {operation}: {error details}"
      - Include subagent error details
      - List partial results (if any)
      - Suggest recovery steps
  </subagent_failed>
</error_handling>

## Usage

```bash
# Task creation (backward compatible)
/task "Implement feature X"
/task "Fix bug in module Y" --priority High
/task "Add documentation" --priority Medium --effort "2 hours" --language markdown
/task "Refactor system: update commands, fix agents, improve docs" --divide

# Task recovery
/task --recover 343                    # Recover single task
/task --recover 343-345                # Recover range
/task --recover 337, 343-345, 350      # Recover list

# Task division (existing task)
/task --divide 326                     # Divide task 326
/task --divide 326 "Focus on UI, backend, tests"  # With prompt

# Task synchronization
/task --sync                           # Sync all tasks
/task --sync 343-345                   # Sync range
/task --sync 337, 343-345              # Sync list

# Task abandonment
/task --abandon 343-345                # Abandon range
/task --abandon 337, 343-345, 350      # Abandon list
```

## Flags

| Flag | Arguments | Description |
|------|-----------|-------------|
| (none) | DESCRIPTION [--priority] [--effort] [--language] [--divide] | Create new task(s) |
| --recover | TASK_RANGES | Unarchive tasks from archive/ |
| --divide | TASK_NUMBER [PROMPT] | Divide existing task into subtasks |
| --sync | [TASK_RANGES] | Synchronize TODO.md and state.json (default: all tasks) |
| --abandon | TASK_RANGES | Abandon tasks (move to archive/) |

## Task Range Format

Task ranges support:
- Single numbers: `343`
- Ranges: `343-345` (expands to 343, 344, 345)
- Lists: `337, 343-345, 350` (expands to 337, 343, 344, 345, 350)

## Architecture

**Phase 3 Standards (v6.0.0)**:
- agent field: "orchestrator" (routes to specialized subagents)
- Flag-based routing (--recover, --divide, --sync, --abandon)
- Validation gates at critical points
- Delegation to specialized subagents:
  * task-creator: Create task entries atomically
  * status-sync-manager: Recover, sync, abandon tasks
  * task-divider: Analyze and divide tasks
- Backward compatible with existing /task "description" syntax
- Execution time: 3-5s for single task, varies by operation

**Philosophy**: Orchestrate, don't implement. Delegate to specialized subagents for execution.
