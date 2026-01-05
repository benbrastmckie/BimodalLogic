---
name: task
agent: orchestrator
description: "Create new task in .opencode/specs/TODO.md (NO implementation)"
timeout: 120
---

**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

**CRITICAL**: This command ONLY creates task entries. It NEVER implements tasks.

<context>
  <system_context>Task creation command with inline implementation</system_context>
  <task_context>Parse task description and flags, create task entry in TODO.md and state.json</task_context>
</context>

<role>Task creation command - Parse arguments and create task entry</role>

<task>
  CRITICAL: This command ONLY creates task entries in TODO.md. It NEVER implements tasks.
  
  Process:
  1. Parse task description from $ARGUMENTS
  2. Extract optional flags (--priority, --effort, --language)
  3. Detect language from keywords if not provided
  4. Read next_project_number from state.json
  5. Format TODO.md entry
  6. Append to correct priority section in TODO.md
  7. Update state.json (increment next_project_number, add to active_projects)
  8. Return task number to user
  
  DO NOT implement the task. DO NOT create any files except TODO.md and state.json updates.
</task>

<workflow_execution>
  <critical_reminder>
    STOP: This command creates a TASK ENTRY describing work to be done.
    - If $ARGUMENTS says "Implement X", you create a task entry ABOUT implementing X
    - You do NOT implement X
    - The task will be implemented LATER by /implement command
    
    Your ONLY job: Parse arguments → Create task entry → Return task number
  </critical_reminder>
  
  <stage id="1" name="ParseAndValidate">
    <action>Parse task description and extract optional flags</action>
    <process>
      1. Parse description from $ARGUMENTS
         - Extract everything before first -- as description
         - Example: "Implement feature X --priority High" → description = "Implement feature X"
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
      
      4. Detect or extract language (default: general)
         - If --language flag present: use that value
         - Else: detect from description keywords:
           * Contains "lean", "proof", "theorem", "lemma", "tactic" → lean
           * Contains "markdown", "doc", "README", "documentation" → markdown
           * Contains "agent", "command", "context", "meta" → meta
           * Contains "python", "py" → python
           * Contains "shell", "bash", "sh" → shell
           * Default → general
         - Valid values: lean, markdown, general, python, shell, json, meta
         - If invalid: Return error "Language must be lean, markdown, general, python, shell, json, or meta"
      
      5. Validate state.json exists
         - Check .opencode/specs/state.json exists
         - If missing: Return error "state.json not found. Run /todo to regenerate."
      
      6. Validate TODO.md exists
         - Check .opencode/specs/TODO.md exists
         - If missing: Return error "TODO.md not found. Run /todo to regenerate."
    </process>
    <validation>
      - Description is non-empty
      - Priority is Low|Medium|High
      - Effort is TBD or time estimate
      - Language is valid value
      - state.json exists
      - TODO.md exists
    </validation>
    <checkpoint>Description parsed, flags extracted, language detected, files validated</checkpoint>
  </stage>
  
  <stage id="2" name="CreateTask">
    <action>Create task entry in TODO.md and state.json</action>
    <process>
      CRITICAL: You are creating a TASK ENTRY. You are NOT implementing anything.
      
      1. Read next_project_number from state.json
         next_number=$(jq -r '.next_project_number' .opencode/specs/state.json)
         
         Example: If next_project_number is 295, then next_number = 295
         
         Validate next_number is a positive integer
         If extraction fails: Return error "Failed to read next_project_number from state.json"
      
      2. Format TODO.md entry
         Create entry with this EXACT format:
         
         ### {next_number}. {description}
         - **Effort**: {effort}
         - **Status**: [NOT STARTED]
         - **Priority**: {priority}
         - **Language**: {language}
         - **Blocking**: None
         - **Dependencies**: None
         
         ---
         
         
         
         Example for task 295 "Implement LeanSearch integration" with Medium priority, TBD effort, lean language:
         
         ### 295. Implement LeanSearch integration
         - **Effort**: TBD
         - **Status**: [NOT STARTED]
         - **Priority**: Medium
         - **Language**: lean
         - **Blocking**: None
         - **Dependencies**: None
         
         ---
         
         
         
         CRITICAL: Use `- **Field**:` format (dash, space, double asterisks)
         CRITICAL: Language field is MANDATORY (per tasks.md line 110)
         CRITICAL: All required fields must be present
      
      3. Determine priority section in TODO.md
         Based on priority value:
         - High → Insert after "## High Priority" heading
         - Medium → Insert after "## Medium Priority" heading  
         - Low → Insert after "## Low Priority" heading
         
         Find the line number of the priority section heading
         Insert the formatted entry after that heading
      
      4. Append entry to TODO.md
         Read current TODO.md content
         Find the priority section heading (## High Priority, ## Medium Priority, or ## Low Priority)
         Insert the formatted entry after the heading (after any blank lines)
         Write updated TODO.md
         
         Use Read tool to read TODO.md
         Use Edit tool to insert entry after priority section heading
         
         If write fails: Return error "Failed to update TODO.md"
      
      5. Update state.json
         Generate timestamp in ISO 8601 format: $(date -Iseconds)
         
         Update state.json with jq:
         - Increment next_project_number by 1
         - Add entry to active_projects array with:
           * project_number: {next_number} (integer)
           * project_name: {slug from description} (lowercase, underscores)
           * type: "feature"
           * phase: "not_started"
           * status: "not_started"
           * priority: {priority in lowercase}
           * language: {language}
           * created: {timestamp}
           * last_updated: {timestamp}
         
         Example jq command:
         jq --arg num "295" \
            --arg desc "implement_leansearch_integration" \
            --arg lang "lean" \
            --arg prio "medium" \
            --arg ts "2026-01-04T20:00:00Z" \
            '.next_project_number = (.next_project_number + 1) |
             .active_projects += [{
               project_number: ($num | tonumber),
               project_name: $desc,
               type: "feature",
               phase: "not_started",
               status: "not_started",
               priority: $prio,
               language: $lang,
               created: $ts,
               last_updated: $ts
             }]' .opencode/specs/state.json > /tmp/state.json.tmp
         
         Move temp file to state.json:
         mv /tmp/state.json.tmp .opencode/specs/state.json
         
         If update fails: Return error "Failed to update state.json"
      
      6. Verify updates
         Read TODO.md and verify task entry is present
         Read state.json and verify next_project_number incremented
         Read state.json and verify active_projects contains new task
         
         If verification fails: Return error with details
      
      7. Return result to user
         Output:
         Task {next_number} created: {description}
         Priority: {priority}, Effort: {effort}, Language: {language}
         
         Next steps:
           /research {next_number} - Research this task
           /plan {next_number} - Create implementation plan
           /implement {next_number} - Implement the task
         
         STOP HERE. Do NOT implement the task.
         The task entry has been created in TODO.md.
         The user will use /research, /plan, /implement later.
    </process>
    <checkpoint>Task created in TODO.md and state.json, result returned to user</checkpoint>
  </stage>
</workflow_execution>

<critical_constraints>
  <absolutely_forbidden>
    This command MUST NOT:
    - Implement the task described in $ARGUMENTS
    - Create any commands, agents, or implementation files
    - Examine existing code to understand implementation
    - Create /sync commands or similar
    - Do anything except create a task entry in TODO.md and state.json
    
    If you find yourself thinking about HOW to implement the task:
    - STOP immediately
    - You are violating the command constraints
    - Return to creating the task entry only
  </absolutely_forbidden>
  
  <only_allowed_actions>
    The ONLY actions allowed:
    1. Parse task description from $ARGUMENTS
    2. Extract --priority, --effort, --language flags
    3. Validate inputs
    4. Read next_project_number from state.json
    5. Format TODO.md entry
    6. Append entry to TODO.md
    7. Update state.json
    8. Return task number to user
  </only_allowed_actions>
</critical_constraints>

<validation>
  <pre_execution>
    - Task description validated (non-empty)
    - Priority validated (Low|Medium|High)
    - Effort validated (TBD or time estimate)
    - Language validated (lean|markdown|general|python|shell|json|meta)
    - state.json exists and is readable
    - TODO.md exists and is readable
  </pre_execution>
  
  <post_execution>
    - Task number allocated correctly
    - TODO.md contains new task entry
    - state.json next_project_number incremented
    - state.json active_projects contains new task
    - Language field is set (MANDATORY)
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
  
  <missing_state_json>
    If state.json not found:
      - Return error: "state.json not found at .opencode/specs/state.json"
      - Suggest: "Run /todo to regenerate state.json"
      - DO NOT create task
  </missing_state_json>
  
  <missing_todo_md>
    If TODO.md not found:
      - Return error: "TODO.md not found at .opencode/specs/TODO.md"
      - Suggest: "Run /todo to regenerate TODO.md"
      - DO NOT create task
  </missing_todo_md>
  
  <update_failed>
    If TODO.md or state.json update fails:
      - Return error with details
      - Suggest checking file permissions
      - DO NOT retry
  </update_failed>
</error_handling>

## Usage

```bash
/task DESCRIPTION [FLAGS]
/task "Implement feature X"
/task "Fix bug Y" --priority High
/task "Add documentation" --effort "2 hours" --language markdown
```

## What This Does

1. Parses task description and optional flags from $ARGUMENTS
2. Validates inputs (description, priority, effort, language)
3. Reads next_project_number from state.json
4. Formats TODO.md entry following task standards
5. Appends entry to correct priority section in TODO.md
6. Updates state.json (increments next_project_number, adds to active_projects)
7. Returns task number and next steps to user

**CRITICAL**: This command ONLY creates task entries. It does NOT implement tasks.

## Flags

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| --priority | Low\|Medium\|High | Medium | Task priority |
| --effort | TBD or time estimate | TBD | Effort estimate |
| --language | lean\|markdown\|general\|python\|shell\|json\|meta | general | Task language (auto-detected if not provided) |

## Language Detection

If --language flag not provided, language is auto-detected from description keywords:

| Keywords | Language |
|----------|----------|
| lean, proof, theorem, lemma, tactic | lean |
| markdown, doc, README, documentation | markdown |
| agent, command, context, meta | meta |
| python, py | python |
| shell, bash, sh | shell |
| (default) | general |

## Next Steps

After creating a task, use these commands:

- `/research {number}` - Research the task
- `/plan {number}` - Create implementation plan
- `/implement {number}` - Implement the task

## Examples

```bash
# Basic task creation
/task "Fix bug in Foo.lean"
# → Creates task with Medium priority, TBD effort, lean language (auto-detected)

# Task with custom priority
/task "Add feature X" --priority High
# → Creates task with High priority, TBD effort, general language

# Task with all flags
/task "Implement proof for theorem Y" --priority High --effort "4 hours" --language lean
# → Creates task with High priority, 4 hours effort, lean language
```

## Important Notes

1. This command ONLY creates task entries - it does NOT implement tasks
2. Uses inline implementation (no delegation to subagent)
3. Matches /research and /implement pattern (executable pseudocode)
4. Task number comes from state.json next_project_number field
5. After creating task, user must use /research, /plan, /implement separately
6. Language field is MANDATORY per tasks.md line 110 quality checklist
7. Metadata format uses `- **Field**:` pattern
8. All required fields (Language, Effort, Priority, Status) are enforced
