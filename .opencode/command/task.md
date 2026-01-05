---
name: task
agent: status-sync-manager
description: "Create new task entries in TODO.md and state.json (NEVER implements tasks)"
timeout: 120
---

**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

**CRITICAL ARCHITECTURAL CONSTRAINT**: This command creates TASK ENTRIES ONLY. It NEVER implements tasks.

<context>
  <system_context>Task creation command - creates entries in TODO.md describing work to be done</system_context>
  <task_context>Parse description, optionally divide into subtasks, create task entries atomically</task_context>
  <architectural_constraint>
    This command is FORBIDDEN from implementing tasks. It only creates task entries.
    Implementation happens later via /implement command.
  </architectural_constraint>
</context>

<role>
  Task entry creator - Parses user descriptions and creates structured task entries in TODO.md
</role>

<task>
  Create task entries in TODO.md and state.json:
  1. Parse task description from $ARGUMENTS
  2. Extract optional flags (--priority, --effort, --language, --divide)
  3. Reformulate description naturally (inline, no subagent)
  4. If --divide: intelligently divide into 1-5 subtasks
  5. Delegate to task-creator subagent for each task
  6. Return task numbers to user
  
  FORBIDDEN: Implementing tasks, creating code files, running build tools
</task>

<workflow_execution>
  <critical_reminder>
    STOP AND READ THIS CAREFULLY:
    
    This command creates TASK ENTRIES describing work to be done.
    It does NOT do the work itself.
    
    Example:
    - User says: /task "Implement feature X"
    - You create: Task entry "Implement feature X" in TODO.md
    - You do NOT: Actually implement feature X
    
    The task will be implemented LATER by /implement command.
    
    Your ONLY job: Parse → Reformulate → Create task entry → Return task number
  </critical_reminder>
  
  <stage id="1" name="ParseInput">
    <action>Parse task description and extract flags</action>
    <process>
      1. Extract task description from $ARGUMENTS:
         - Everything before first -- flag is description
         - Example: "sync thing --priority High" → description = "sync thing"
         - Validate non-empty
         - If empty: Return error "Task description cannot be empty"
      
      2. Extract --priority flag (default: Medium):
         - Look for --priority in $ARGUMENTS
         - Valid values: Low, Medium, High
         - If not provided: priority = "Medium"
         - If invalid: Return error "Priority must be Low, Medium, or High"
      
      3. Extract --effort flag (default: TBD):
         - Look for --effort in $ARGUMENTS
         - Examples: --effort "2 hours", --effort 4h, --effort TBD
         - If not provided: effort = "TBD"
      
      4. Extract --language flag (default: auto-detect):
         - Look for --language in $ARGUMENTS
         - Valid: lean, markdown, general, python, shell, json, meta
         - If not provided: will be detected in Stage 2
         - If invalid: Return error with valid options
      
      5. Extract --divide flag (default: false):
         - Look for --divide in $ARGUMENTS
         - If present: divide = true (will divide into subtasks)
         - If not present: divide = false (single task)
    </process>
    <validation>
      - Description is non-empty
      - Priority is Low|Medium|High
      - Effort is non-empty string
      - Language is null or valid value
      - Divide is boolean
    </validation>
    <checkpoint>Input parsed and validated</checkpoint>
  </stage>
  
  <stage id="2" name="ReformulateDescription">
    <action>Reformulate description naturally (inline, no subagent)</action>
    <process>
      1. Clean and normalize:
         - Trim leading/trailing whitespace
         - Remove multiple spaces
         - Fix common typos (teh→the, adn→and, etc.)
      
      2. Ensure proper sentence structure:
         - Capitalize first letter
         - Add period at end if missing
         - Ensure complete sentences (subject + verb)
      
      3. Improve clarity:
         - Remove filler words (just, really, very, etc.)
         - Make imperative (start with verb)
         - Keep concise (2-3 sentences max)
      
      4. Generate title from description:
         - Use first sentence or first 80 chars
         - Remove period at end
         - Capitalize properly
         - Example: "Sync thing for todo and state." → "Sync thing for todo and state"
      
      5. Detect language if not provided:
         - Check for keywords:
           * lean: "lean", "proof", "theorem", "lemma", "tactic", "axiom", "sorry"
           * markdown: "markdown", "doc", "readme", "documentation", "guide"
           * meta: "command", "agent", "subagent", "context", "workflow"
           * python: "python", ".py", "script"
           * shell: "shell", "bash", ".sh"
           * json: "json", "yaml", "toml", "config"
         - If no keywords match: language = "general"
         - If multiple match: use first match
    </process>
    <validation>
      - Description is well-formed (capitalized, punctuated)
      - Title is non-empty, max 80 chars
      - Language is set (never null)
    </validation>
    <checkpoint>Description reformulated, title generated, language detected</checkpoint>
  </stage>
  
  <stage id="3" name="DivideIfRequested">
    <action>If --divide flag present, divide into 1-5 subtasks</action>
    <process>
      1. Check if --divide flag present:
         - If false: Skip to Stage 4 with single task
         - If true: Continue with division logic
      
      2. Analyze description for natural divisions:
         - Look for bullet points or numbered lists
         - Look for "and" conjunctions
         - Look for comma-separated items
         - Look for sequential steps (first, then, finally)
         - Look for multiple verbs (implement X, add Y, fix Z)
      
      3. Determine number of subtasks (1-5):
         - If no natural divisions found: 1 task (no division)
         - If 2-5 natural divisions found: create that many tasks
         - If >5 divisions found: group into 5 logical subtasks
         - Aim for balanced subtasks (similar complexity)
      
      4. Generate subtask descriptions:
         - Each subtask should be self-contained
         - Each subtask should have clear scope
         - Maintain original priority/effort for all subtasks
         - Number subtasks: "Task 1/3: ...", "Task 2/3: ...", etc.
      
      5. Prepare task list:
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
  
  <stage id="4" name="CreateTasks">
    <action>Create task entries via status-sync-manager</action>
    <process>
      1. For each task in task_list:
         a. Delegate to status-sync-manager:
            - operation: "create_task"
            - title: task.title
            - description: task.description
            - priority: task.priority
            - effort: task.effort
            - language: task.language
            - timestamp: $(date -I)
            - session_id: {session_id}
            - delegation_depth: {depth + 1}
            - delegation_path: [...path, "status-sync-manager"]
         
         b. Collect task_number from return.metadata.task_number:
            - Store in created_tasks array
            - Validate task_number is positive integer
            - If task_number missing: Read next_project_number - 1 from state.json as fallback
         
         c. Handle errors:
            - If status-sync-manager fails: stop and return error
            - Include details of which task failed
            - List successfully created tasks (if any)
            - Note: status-sync-manager handles rollback automatically
      
      2. Validate all tasks created:
         - Verify created_tasks array has expected length
         - Verify all task_numbers are unique
         - Verify all task_numbers are sequential (if multiple)
    </process>
    <error_handling>
      If status-sync-manager fails:
        - Return error: "Failed to create task {N}: {error details}"
        - List successfully created tasks: "Created tasks: {numbers}"
        - Note: Failed task was rolled back atomically
        - Suggest: "Use /implement {number} to work on created tasks"
    </error_handling>
    <checkpoint>All tasks created atomically in TODO.md and state.json</checkpoint>
  </stage>
  
  <stage id="5" name="ReturnSuccess">
    <action>Return task numbers and next steps to user</action>
    <process>
      1. Format success message:
         - If single task:
           ```
           Task {number} created: {title}
           - Priority: {priority}
           - Effort: {effort}
           - Language: {language}
           - Status: [NOT STARTED]
           
           Next steps:
             /research {number} - Research this task
             /plan {number} - Create implementation plan
             /implement {number} - Implement the task
           ```
         
         - If multiple tasks (--divide):
           ```
           Created {count} tasks:
           - Task {number1}: {title1}
           - Task {number2}: {title2}
           - Task {number3}: {title3}
           
           All tasks:
           - Priority: {priority}
           - Effort: {effort}
           - Language: {language}
           - Status: [NOT STARTED]
           
           Next steps:
             /research {number1} - Research first task
             /implement {number1} - Implement first task
             (Repeat for other tasks as needed)
           ```
      
      2. Return message to user
      
      3. STOP HERE. Do NOT implement any tasks.
         The task entries have been created in TODO.md and state.json.
         The user will use /research, /plan, /implement later.
    </process>
    <checkpoint>Success message returned to user</checkpoint>
  </stage>
</workflow_execution>

<critical_constraints>
  <absolutely_forbidden>
    This command MUST NOT:
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
    1. Parse description from $ARGUMENTS
    2. Extract flags (--priority, --effort, --language, --divide)
    3. Reformulate description inline (simple transformations)
    4. Detect language from keywords
    5. Divide into subtasks if --divide flag present
    6. Delegate to status-sync-manager for each task
    7. Return task numbers to user
  </only_allowed_actions>
  
  <architectural_enforcement>
    Technical barriers to prevent implementation:
    - Command delegates to status-sync-manager (not implementer)
    - status-sync-manager has permissions that DENY code file writes
    - status-sync-manager has permissions that DENY build tool execution
    - status-sync-manager can ONLY write to TODO.md and state.json
    - Orchestrator validates return format (must be task numbers only)
  </architectural_enforcement>
</critical_constraints>

<validation>
  <pre_execution>
    - Description validated (non-empty)
    - Priority validated (Low|Medium|High)
    - Effort validated (non-empty string)
    - Language will be set (via detection or flag)
    - Divide flag is boolean
    - TODO.md exists and is readable
    - state.json exists and is readable
  </pre_execution>
  
  <post_execution>
    - Task numbers allocated correctly
    - TODO.md contains new task entries
    - state.json updated with new tasks
    - state.json next_project_number incremented
    - Language field is set (MANDATORY)
    - Description field is set (MANDATORY)
    - Metadata format uses `- **Field**:` pattern
    - All required fields present
    - NO implementation occurred
    - NO code files created
    - NO spec directories created
  </post_execution>
</validation>

<error_handling>
  <empty_description>
    If description is empty:
      - Return error: "Task description cannot be empty"
      - Show usage: "/task \"Your task description here\""
      - DO NOT create task
  </empty_description>
  
  <invalid_priority>
    If priority is not Low|Medium|High:
      - Return error: "Priority must be Low, Medium, or High"
      - Show usage: "/task \"description\" --priority High"
      - DO NOT create task
  </invalid_priority>
  
  <invalid_language>
    If language is not valid:
      - Return error: "Language must be lean, markdown, general, python, shell, json, or meta"
      - Show usage: "/task \"description\" --language lean"
      - DO NOT create task
  </invalid_language>
  
  <division_failed>
    If --divide flag present but division fails:
      - Return error: "Failed to divide task into subtasks"
      - Suggest: "Try creating single task without --divide flag"
      - DO NOT create any tasks
  </division_failed>
  
  <task_creation_failed>
    If status-sync-manager fails:
      - Return error: "Failed to create task: {error details}"
      - Include status-sync-manager error details
      - List successfully created tasks (if any)
      - Note: Failed task was rolled back atomically
      - Suggest checking TODO.md and state.json
  </task_creation_failed>
</error_handling>

## Usage

```bash
# Basic task creation
/task "Implement feature X"
# → Creates: Task 303: "Implement feature X."

# Task with priority
/task "Fix bug in module Y" --priority High
# → Creates: Task 304: "Fix bug in module Y." (High priority)

# Task with all flags
/task "Add documentation for Z" --priority Medium --effort "2 hours" --language markdown
# → Creates: Task 305: "Add documentation for Z." (Medium, 2 hours, markdown)

# Task with division
/task "Refactor system: update commands, fix agents, improve docs" --divide
# → Creates: 
#    Task 306: "Refactor system (1/3): Update commands."
#    Task 307: "Refactor system (2/3): Fix agents."
#    Task 308: "Refactor system (3/3): Improve docs."
```

## What This Does

1. Parses description and optional flags from $ARGUMENTS
2. Reformulates description inline (capitalize, punctuate, clarify)
3. Detects language from keywords if not provided
4. If --divide: divides into 1-5 subtasks based on natural divisions
5. Delegates to status-sync-manager for each task
6. Returns task numbers and next steps to user

**CRITICAL**: This command ONLY creates task entries. It does NOT implement tasks.

## Flags

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| --priority | Low\|Medium\|High | Medium | Task priority |
| --effort | TBD or time estimate | TBD | Effort estimate |
| --language | lean\|markdown\|general\|python\|shell\|json\|meta | Auto-detected | Task language |
| --divide | (boolean) | false | Divide task into 1-5 subtasks |

## Language Detection

If --language flag not provided, language is auto-detected from keywords:

| Keywords | Language |
|----------|----------|
| lean, proof, theorem, lemma, tactic | lean |
| markdown, doc, README, documentation | markdown |
| command, agent, context, workflow | meta |
| python, py | python |
| shell, bash, sh | shell |
| json, yaml, toml, config | json |
| (default) | general |

## Task Division (--divide flag)

When --divide flag is present, the command analyzes the description for natural divisions:

1. **Bullet points or numbered lists**: Each item becomes a subtask
2. **"and" conjunctions**: Split on "and" to create subtasks
3. **Comma-separated items**: Each item becomes a subtask
4. **Sequential steps**: "first", "then", "finally" indicate subtasks
5. **Multiple verbs**: "implement X, add Y, fix Z" creates 3 subtasks

The command creates 1-5 subtasks based on natural divisions found. If no divisions found, creates single task.

## Next Steps

After creating a task, use these commands:

- `/research {number}` - Research the task
- `/plan {number}` - Create implementation plan
- `/implement {number}` - Implement the task

## Examples

```bash
# Basic task creation
/task "Implement proof search"
# → Detects: Language=lean, Priority=Medium, Effort=TBD
# → Creates: Task 303: "Implement proof search."

# Task with custom priority
/task "Add feature X" --priority High
# → Priority=High, Language=general, Effort=TBD

# Task with all flags
/task "Implement theorem Y" --priority High --effort "4 hours" --language lean
# → Uses provided values

# Task with language detection
/task "Fix bug in Foo.lean"
# → Detects: Language=lean (keyword: "lean")

# Task with markdown detection
/task "Update README documentation"
# → Detects: Language=markdown (keywords: "README", "documentation")

# Task with division
/task "Refactor system: update commands, fix agents, improve docs" --divide
# → Creates 3 tasks:
#    Task 303: "Refactor system (1/3): Update commands."
#    Task 304: "Refactor system (2/3): Fix agents."
#    Task 305: "Refactor system (3/3): Improve docs."
```

## Important Notes

1. This command ONLY creates task entries - it does NOT implement tasks
2. Uses status-sync-manager for atomic updates (both TODO.md and state.json or neither)
3. Description reformulation is inline (simple transformations only)
4. Language detection is keyword-based (fast and accurate for common cases)
5. Task numbers come from state.json next_project_number field
6. After creating task, user must use /research, /plan, /implement separately
7. Language field is MANDATORY per tasks.md quality checklist
8. Description field is MANDATORY
9. Metadata format uses `- **Field**:` pattern
10. All required fields (Language, Effort, Priority, Status, Description) are enforced
11. --divide flag divides task into 1-5 subtasks based on natural divisions

## Architecture

**Optimized in v5.0.0**:
- Direct delegation to status-sync-manager (eliminated task-creator layer)
- Inline description reformulation (simple transformations)
- Keyword-based language detection (fast, accurate)
- Added --divide flag for task subdivision
- Execution time: 3-5s for single task, 9-12s for 5 tasks (40-50% improvement from v4.0.0)
- Lines of code: ~300 command + direct delegation (vs ~300 + 658 in v4.0.0)

**Philosophy**: Direct operations with minimal delegation. Delegate only for atomic updates.

**Architectural Enforcement**: status-sync-manager has permissions that DENY code file writes and build tool execution, ensuring it can ONLY create task entries.

## Version History

- **v5.0.0** (2026-01-05): Optimized with direct delegation to status-sync-manager (eliminated task-creator layer, 40-50% performance improvement)
- **v4.0.0** (2026-01-05): Full refactor with --divide flag, improved description reformulation, architectural enforcement
- **v3.0.0** (2026-01-05): Simplified to direct implementation with atomic updates via status-sync-manager
- **v2.0.0** (2026-01-04): Added description clarification with description-clarifier subagent
- **v1.0.0** (2026-01-03): Initial inline implementation
