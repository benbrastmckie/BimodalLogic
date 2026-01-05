---
name: task
agent: orchestrator
description: "Create new task in TODO.md and state.json atomically"
timeout: 60
---

**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

**CRITICAL**: This command ONLY creates task entries. It NEVER implements tasks.

<context>
  <system_context>Task creation command with atomic updates</system_context>
  <task_context>Parse description, detect metadata, create task entry atomically in TODO.md and state.json</task_context>
</context>

<role>Task creation command - Create new tasks in TODO.md WITHOUT implementing them</role>

<task>
  CRITICAL: This command ONLY creates task entries. It NEVER implements tasks.
  
  Process:
  1. Parse task description from $ARGUMENTS
  2. Extract optional flags (--priority, --effort, --language, --divide)
  3. Detect language from description keywords if not provided
  4. Read next_project_number from TODO.md frontmatter
  5. Delegate to status-sync-manager for atomic task creation
  6. Return task number to user
  
  DO NOT implement the task. DO NOT create any files except TODO.md and state.json updates.
</task>

<workflow_execution>
  <critical_reminder>
    STOP: This command creates a TASK ENTRY describing work to be done.
    - If $ARGUMENTS says "Implement X", you create a task entry ABOUT implementing X
    - You do NOT implement X
    - The task will be implemented LATER by /implement command
    
    Your ONLY job: Parse arguments → Detect metadata → Create task entry → Return task number
  </critical_reminder>
  
  <stage id="1" name="ParseInput">
    <action>Parse task description and extract optional flags</action>
    <process>
      1. Parse task description from $ARGUMENTS
         - Extract everything before first -- as description
         - Example: "sync thing for todo and state --priority High" → description = "sync thing for todo and state"
         - Validate description is non-empty
         - If empty: Return error "Task description cannot be empty"
      
      2. Extract priority flag (default: Medium)
         - Look for --priority flag in $ARGUMENTS
         - Extract value after --priority
         - Valid values: Low, Medium, High
         - If not provided: priority = "Medium"
         - If invalid: Return error "Priority must be Low, Medium, or High"
      
      3. Extract effort flag (default: TBD)
         - Look for --effort flag in $ARGUMENTS
         - Extract value after --effort (may be quoted)
         - Examples: --effort "2 hours", --effort 4h, --effort TBD
         - If not provided: effort = "TBD"
      
      4. Extract language flag (default: detect from description)
         - Look for --language flag in $ARGUMENTS
         - Extract value after --language
         - Valid values: lean, markdown, general, python, shell, json, meta
         - If not provided: language = null (will be detected)
         - If invalid: Return error "Language must be lean, markdown, general, python, shell, json, or meta"
      
      5. Extract divide flag (default: false)
         - Look for --divide flag in $ARGUMENTS
         - If present: divide = true
         - If not present: divide = false
         - NOTE: --divide implementation deferred to future task
         - If --divide present: Return error "--divide flag not yet implemented. Create single task for now."
      
      6. Reformulate description inline (simple transformations):
         - Capitalize first letter if not already
         - Add period at end if missing
         - Trim whitespace
         - Keep description concise (2-3 sentences max)
         - Example: "sync thing" → "Sync thing."
         - Example: "fix the lean stuff" → "Fix the lean stuff."
      
      7. Generate title from description:
         - Use first sentence or first 80 chars
         - Remove period at end
         - Capitalize properly
         - Example: "Sync thing for todo and state." → "Sync thing for todo and state"
    </process>
    <validation>
      - Description is non-empty
      - Priority is Low|Medium|High
      - Effort is non-empty string
      - Language is null or valid value
      - Title is non-empty, max 80 chars
    </validation>
    <checkpoint>Description parsed, flags extracted, title generated</checkpoint>
  </stage>
  
  <stage id="2" name="DetectLanguage">
    <action>Detect language from description keywords if not provided</action>
    <process>
      1. If --language flag provided: use it (skip detection)
      
      2. If --language not provided: detect from keywords
         - Check description (case-insensitive) for keywords:
           * lean: "lean", "proof", "theorem", "lemma", "tactic", "axiom", "sorry"
           * markdown: "markdown", "doc", "readme", "documentation", "guide"
           * meta: "command", "agent", "subagent", "context", "workflow", "delegation"
           * python: "python", ".py", "script"
           * shell: "shell", "bash", ".sh"
           * json: "json", "yaml", "toml", "config"
         - If multiple keywords match: use first match
         - If no keywords match: language = "general"
      
      3. Validate language is set (MANDATORY per tasks.md)
         - Language field must be non-null
         - If null after detection: language = "general"
    </process>
    <validation>Language field is set (never null)</validation>
    <checkpoint>Language detected or defaulted to general</checkpoint>
  </stage>
  
  <stage id="3" name="ReadNextNumber">
    <action>Read next_project_number from TODO.md frontmatter</action>
    <process>
      1. Read TODO.md file
      2. Extract YAML frontmatter (between --- markers)
      3. Parse next_project_number field
      4. Validate it's a number >= 0
      5. Store for use in task creation
    </process>
    <error_handling>
      If TODO.md missing or invalid:
        - Return error to user
        - Suggest running /todo to regenerate TODO.md
        - DO NOT proceed with task creation
    </error_handling>
    <checkpoint>Next task number allocated</checkpoint>
  </stage>
  
  <stage id="4" name="CreateTaskAtomic">
    <action>Create task entry atomically via status-sync-manager</action>
    <process>
      CRITICAL: Delegate to status-sync-manager for atomic updates.
      
      1. Prepare delegation context for status-sync-manager:
         ```json
         {
           "operation": "create_task",
           "title": "{title}",
           "description": "{description}",
           "priority": "{priority}",
           "effort": "{effort}",
           "language": "{language}",
           "new_status": "not_started",
           "timestamp": "{ISO8601 date}",
           "session_id": "{session_id}",
           "delegation_depth": 1,
           "delegation_path": ["orchestrator", "task"]
         }
         ```
      
      2. Invoke status-sync-manager via task tool:
         task(
           subagent_type="status-sync-manager",
           prompt="Create task with operation=create_task, title={title}, description={description}, priority={priority}, effort={effort}, language={language}",
           description="Create task entry atomically"
         )
      
      3. Wait for status-sync-manager to complete
         Expected return format (JSON):
         {
           "status": "completed",
           "summary": "Task {number} created: {title}",
           "task_number": {number},
           "files_updated": ["TODO.md", "state.json"],
           "metadata": {
             "session_id": "{session_id}",
             "duration_seconds": {duration},
             "agent_type": "status-sync-manager"
           }
         }
      
      4. Parse task number from return
         - Extract task_number field
         - Validate it's a positive integer
         - Store for return to user
      
      5. Validate atomic update succeeded
         - Verify status == "completed"
         - Verify files_updated includes ["TODO.md", "state.json"]
         - If failed: Return error with details
    </process>
    <error_handling>
      If status-sync-manager fails:
        - Return error: "Failed to create task: {error details}"
        - Include status-sync-manager error details
        - Suggest checking TODO.md and state.json
        - DO NOT retry (atomic update ensures no partial state)
    </error_handling>
    <checkpoint>Task created atomically in TODO.md and state.json</checkpoint>
  </stage>
  
  <stage id="5" name="ReturnSuccess">
    <action>Return task number and confirmation to user</action>
    <process>
      1. Format success message:
         ```
         Task {number} created: {title}
         - Priority: {priority}
         - Effort: {effort}
         - Language: {language}
         - Status: [NOT STARTED]
         
         Task added to TODO.md in {priority} Priority section.
         
         Next steps:
           /research {number} - Research this task
           /plan {number} - Create implementation plan
           /implement {number} - Implement the task
         ```
      
      2. Return message to user
      
      3. STOP HERE. Do NOT implement the task.
         The task entry has been created in TODO.md and state.json.
         The user will use /research, /plan, /implement later.
    </process>
    <checkpoint>Success message returned to user</checkpoint>
  </stage>
</workflow_execution>

<critical_constraints>
  <absolutely_forbidden>
    This command MUST NOT:
    - Implement the task described in $ARGUMENTS
    - Create any commands, agents, or implementation files
    - Examine existing code to understand implementation
    - Create spec directories or artifact files
    - Do anything except create a task entry in TODO.md and state.json
    
    If you find yourself thinking about HOW to implement the task:
    - STOP immediately
    - You are violating the command constraints
    - Return to creating the task entry only
  </absolutely_forbidden>
  
  <only_allowed_actions>
    The ONLY actions allowed:
    1. Parse description from $ARGUMENTS
    2. Extract --priority, --effort, --language, --divide flags
    3. Reformulate description inline (simple transformations)
    4. Detect language from keywords
    5. Read next_project_number from TODO.md
    6. Delegate to status-sync-manager for atomic task creation
    7. Return task number to user
  </only_allowed_actions>
  
  <atomic_updates>
    Task creation MUST be atomic:
    - Both TODO.md and state.json updated OR neither
    - Use status-sync-manager for atomic updates
    - No partial state allowed
    - Rollback on any failure
  </atomic_updates>
</critical_constraints>

<validation>
  <pre_execution>
    - Description validated (non-empty)
    - Priority validated (Low|Medium|High)
    - Effort validated (non-empty string)
    - Language validated (will be set via detection or flag)
    - TODO.md exists and is readable
  </pre_execution>
  
  <post_execution>
    - Task number allocated correctly
    - TODO.md contains new task entry with Description field
    - state.json updated with new task
    - TODO.md next_project_number incremented
    - Language field is set (MANDATORY)
    - Description field is set (MANDATORY)
    - Metadata format uses `- **Field**:` pattern
    - All required fields present
    - No implementation occurred
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
  
  <divide_not_implemented>
    If --divide flag present:
      - Return error: "--divide flag not yet implemented"
      - Suggest: "Create single task for now, then use /revise to subdivide later"
      - DO NOT create task
  </divide_not_implemented>
  
  <missing_todo_md>
    If TODO.md not found:
      - Return error: "TODO.md not found at .opencode/specs/TODO.md"
      - Suggest: "Run /todo to regenerate TODO.md"
      - DO NOT create task
  </missing_todo_md>
  
  <status_sync_failed>
    If status-sync-manager fails:
      - Return error: "Failed to create task: {error details}"
      - Include status-sync-manager error details
      - Suggest checking TODO.md and state.json
      - DO NOT retry
  </status_sync_failed>
</error_handling>

## Usage

```bash
/task DESCRIPTION [FLAGS]
/task "sync thing for todo and state"
/task "fix the lean stuff" --priority High
/task "Add documentation" --effort "2 hours" --language markdown
/task "Implement feature X" --priority Medium --effort "4 hours" --language lean
```

## What This Does

1. Parses description and optional flags from $ARGUMENTS
2. Reformulates description inline (simple transformations)
3. Detects language from keywords if not provided
4. Reads next_project_number from TODO.md frontmatter
5. Delegates to status-sync-manager for atomic task creation
6. Returns task number and next steps to user

**CRITICAL**: This command ONLY creates task entries. It does NOT implement tasks.

## Flags

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| --priority | Low\|Medium\|High | Medium | Task priority |
| --effort | TBD or time estimate | TBD | Effort estimate |
| --language | lean\|markdown\|general\|python\|shell\|json\|meta | Detected from keywords | Task language |
| --divide | (boolean) | false | Divide task into subtasks (NOT YET IMPLEMENTED) |

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

## Next Steps

After creating a task, use these commands:

- `/research {number}` - Research the task
- `/plan {number}` - Create implementation plan
- `/implement {number}` - Implement the task

## Examples

```bash
# Basic task creation
/task "sync thing for todo and state"
# → Detects: Language=meta, Priority=Medium, Effort=TBD
# → Creates: Task 303: "Sync thing for todo and state."

# Task with custom priority
/task "Add feature X" --priority High
# → Priority=High, Language=general, Effort=TBD

# Task with all flags
/task "Implement proof for theorem Y" --priority High --effort "4 hours" --language lean
# → Uses provided values

# Task with language detection
/task "Fix bug in Foo.lean"
# → Detects: Language=lean (keyword: "lean")

# Task with markdown detection
/task "Update README documentation"
# → Detects: Language=markdown (keywords: "README", "documentation")
```

## Important Notes

1. This command ONLY creates task entries - it does NOT implement tasks
2. Uses status-sync-manager for atomic updates (both TODO.md and state.json or neither)
3. Description reformulation is inline (simple transformations only)
4. Language detection is keyword-based (fast and accurate for common cases)
5. Task number comes from TODO.md next_project_number field
6. After creating task, user must use /research, /plan, /implement separately
7. Language field is MANDATORY per tasks.md quality checklist
8. Description field is MANDATORY
9. Metadata format uses `- **Field**:` pattern
10. All required fields (Language, Effort, Priority, Status, Description) are enforced
11. --divide flag deferred to future implementation

## Architecture Changes

**Simplified from v2.0.0**:
- Removed description-clarifier delegation (300s timeout, 473 lines)
- Removed task-creator delegation (120s timeout, 642 lines)
- Added status-sync-manager delegation for atomic updates only
- Inline description reformulation (simple transformations)
- Keyword-based language detection (fast, accurate)
- Execution time: <10s (vs 420s in v2.0.0)
- Lines of code: ~200 (vs 1570 in v2.0.0)

**Philosophy**: Direct operations with minimal delegation. Only delegate for atomic updates.

## Version History

- **v3.0.0** (2026-01-05): Simplified to direct implementation with atomic updates via status-sync-manager
- **v2.0.0** (2026-01-04): Added description clarification with description-clarifier subagent
- **v1.0.0** (2026-01-03): Initial inline implementation
