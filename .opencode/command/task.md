---
name: task
agent: orchestrator
description: "Create new task in .opencode/specs/TODO.md with description clarification"
timeout: 300
---

**Task Input (required):** $ARGUMENTS (rough task description; e.g., `/task "sync thing for todo and state"`)

**CRITICAL**: This command ONLY creates task entries. It NEVER implements tasks.

<context>
  <system_context>Task creation command with description clarification and delegation</system_context>
  <task_context>Parse rough description, clarify it, create task entry in TODO.md and state.json</task_context>
</context>

<role>Task creation command - Parse arguments, clarify description, delegate to task-creator</role>

<task>
  CRITICAL: This command ONLY creates task entries in TODO.md. It NEVER implements tasks.
  
  Process:
  1. Parse rough description from $ARGUMENTS
  2. Extract optional flags (--priority, --effort, --language, --skip-clarification)
  3. If clarification not skipped: invoke description-clarifier to research and clarify description
  4. Delegate to task-creator with clarified title and description
  5. Return task number to user
  
  DO NOT implement the task. DO NOT create any files except TODO.md and state.json updates.
</task>

<workflow_execution>
  <critical_reminder>
    STOP: This command creates a TASK ENTRY describing work to be done.
    - If $ARGUMENTS says "Implement X", you create a task entry ABOUT implementing X
    - You do NOT implement X
    - The task will be implemented LATER by /implement command
    
    Your ONLY job: Parse arguments → Clarify description → Create task entry → Return task number
  </critical_reminder>
  
  <stage id="1" name="ParseAndValidate">
    <action>Parse rough description and extract optional flags</action>
    <process>
      1. Parse rough description from $ARGUMENTS
         - Extract everything before first -- as rough description
         - Example: "sync thing for todo and state --priority High" → rough_description = "sync thing for todo and state"
         - Validate rough description is non-empty
         - If empty: Return error "Task description cannot be empty"
      
      2. Extract priority flag (default: not set, will be detected by clarifier)
         - Look for --priority flag in $ARGUMENTS
         - Extract value after --priority
         - Valid values: Low, Medium, High
         - If not provided: priority = null (will be detected by clarifier)
         - If invalid: Return error "Priority must be Low, Medium, or High"
      
      3. Extract effort flag (default: not set, will be detected by clarifier)
         - Look for --effort flag in $ARGUMENTS
         - Extract value after --effort (may be quoted)
         - Examples: --effort "2 hours", --effort 4h, --effort TBD
         - If not provided: effort = null (will be detected by clarifier)
      
      4. Extract language flag (default: not set, will be detected by clarifier)
         - Look for --language flag in $ARGUMENTS
         - Extract value after --language
         - Valid values: lean, markdown, general, python, shell, json, meta
         - If not provided: language = null (will be detected by clarifier)
         - If invalid: Return error "Language must be lean, markdown, general, python, shell, json, or meta"
      
      5. Extract skip-clarification flag (default: false)
         - Look for --skip-clarification flag in $ARGUMENTS
         - If present: skip_clarification = true
         - If not present: skip_clarification = false
         - Special case: If --language, --priority, and --effort all set: skip_clarification = true
      
      6. Validate state.json exists
         - Check .opencode/specs/state.json exists
         - If missing: Return error "state.json not found. Run /todo to regenerate."
      
      7. Validate TODO.md exists
         - Check .opencode/specs/TODO.md exists
         - If missing: Return error "TODO.md not found. Run /todo to regenerate."
      
      8. Determine next stage:
         - If skip_clarification = true: proceed to Stage 3 (CreateTask)
         - If skip_clarification = false: proceed to Stage 2 (ClarifyDescription)
    </process>
    <validation>
      - Rough description is non-empty
      - Priority is null or Low|Medium|High
      - Effort is null or TBD or time estimate
      - Language is null or valid value
      - state.json exists
      - TODO.md exists
    </validation>
    <checkpoint>Rough description parsed, flags extracted, files validated</checkpoint>
  </stage>
  
  <stage id="2" name="ClarifyDescription">
    <action>Research and clarify task description using description-clarifier</action>
    <process>
      IMPORTANT: This stage is SKIPPED if --skip-clarification flag is set or if all metadata flags are provided.
      
      1. Invoke description-clarifier subagent via task tool:
         task(
           subagent_type="description-clarifier",
           prompt="Clarify this rough task description: ${rough_description}",
           description="Clarify task description"
         )
      
      2. Wait for clarified description and metadata from description-clarifier
         Expected return format:
         ```
         CLARIFIED DESCRIPTION:
         {2-3 sentence clarified description}
         
         TITLE:
         {short title, max 80 chars}
         
         METADATA:
         - Language: {detected language}
         - Priority: {estimated priority}
         - Effort: {estimated effort}
         - Confidence: {high|medium|low}
         
         RESEARCH SUMMARY:
         {brief summary of research findings}
         
         SIMILAR TASKS:
         {comma-separated list of task numbers, or "None found"}
         
         REASONING:
         {brief explanation of metadata choices}
         ```
      
      3. Parse clarified description and metadata:
         - Extract clarified_description (2-3 sentences)
         - Extract title (short, max 80 chars)
         - Extract detected language
         - Extract estimated priority
         - Extract estimated effort
         - Extract confidence level
      
      4. Override flags with clarified metadata if not explicitly set:
         - If --language not set: use detected language from clarifier
         - If --priority not set: use estimated priority from clarifier
         - If --effort not set: use estimated effort from clarifier
         - If flag IS set: use flag value (user override)
      
      5. Store clarified description and title for task creation:
         - title = extracted title
         - description = clarified_description
         - priority = flag value OR detected priority
         - effort = flag value OR estimated effort
         - language = flag value OR detected language
      
      6. Show clarification to user:
         Output:
         "Clarified description: {clarified_description}"
         "Detected: Language={language}, Priority={priority}, Effort={effort}"
         "Confidence: {confidence}"
         "Similar tasks: {similar_tasks}"
    </process>
    <checkpoint>Description clarified, metadata extracted, user informed</checkpoint>
  </stage>
  
  <stage id="3" name="CreateTask">
    <action>Create task entry with clarified description via task-creator</action>
    <process>
      CRITICAL: You are delegating to task-creator to create a TASK ENTRY. You are NOT implementing anything.
      
      1. Prepare task creation input:
         If clarification was performed (Stage 2):
           - title: from clarified title
           - description: from clarified description
           - priority: from flag OR clarified metadata
           - effort: from flag OR clarified metadata
           - language: from flag OR clarified metadata
         
         If clarification was skipped (--skip-clarification):
           - title: from rough description (first 80 chars)
           - description: from rough description (use as-is, must be 50-500 chars)
           - priority: from flag OR "Medium" (default)
           - effort: from flag OR "TBD" (default)
           - language: from flag OR detect from rough description
      
      2. Validate description length:
         - If description < 50 chars: Return error "Description too short (minimum 50 characters). Use description-clarifier or provide longer description."
         - If description > 500 chars: Return error "Description too long (maximum 500 characters). Use description-clarifier to condense."
      
      3. Invoke task-creator subagent via task tool:
         task(
           subagent_type="task-creator",
           prompt="Create task with title: ${title}. Description: ${description}. Priority: ${priority}. Effort: ${effort}. Language: ${language}.",
           description="Create task entry"
         )
      
      4. Wait for task-creator to complete
         Expected return format (JSON):
         {
           "status": "completed",
           "summary": "Task {number} created: {title}",
           "task_number": {number},
           "task_details": {
             "title": "{title}",
             "description": "{description}",
             "priority": "{priority}",
             "effort": "{effort}",
             "language": "{language}",
             "status": "[NOT STARTED]"
           },
           "next_steps": "Use /research {number} to research this task. Use /plan {number} to create implementation plan. Use /implement {number} to implement the task."
         }
      
      5. Relay result to user:
         Output:
         "Task {number} created: {title}"
         "Description: {description}"
         "Priority: {priority}, Effort: {effort}, Language: {language}"
         ""
         "Next steps:"
         "  /research {number} - Research this task"
         "  /plan {number} - Create implementation plan"
         "  /implement {number} - Implement the task"
         
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
    1. Parse rough description from $ARGUMENTS
    2. Extract --priority, --effort, --language, --skip-clarification flags
    3. Validate inputs
    4. Invoke description-clarifier (if not skipped)
    5. Parse clarified description and metadata
    6. Invoke task-creator with clarified inputs
    7. Return task number to user
  </only_allowed_actions>
</critical_constraints>

<validation>
  <pre_execution>
    - Rough description validated (non-empty)
    - Priority validated (null or Low|Medium|High)
    - Effort validated (null or TBD or time estimate)
    - Language validated (null or lean|markdown|general|python|shell|json|meta)
    - state.json exists and is readable
    - TODO.md exists and is readable
  </pre_execution>
  
  <post_execution>
    - Task number allocated correctly
    - TODO.md contains new task entry with Description field
    - state.json next_project_number incremented
    - state.json active_projects contains new task with description field
    - Language field is set (MANDATORY)
    - Description field is set (MANDATORY)
    - Metadata format uses `- **Field**:` pattern
    - All required fields present
    - No implementation occurred
  </post_execution>
</validation>

<error_handling>
  <empty_description>
    If rough description is empty:
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
  
  <description_too_short>
    If description < 50 chars after clarification:
      - Return error: "Description too short (minimum 50 characters)"
      - Suggest: "Provide more details or let description-clarifier expand it"
      - DO NOT create task
  </description_too_short>
  
  <description_too_long>
    If description > 500 chars after clarification:
      - Return error: "Description too long (maximum 500 characters)"
      - Suggest: "Use description-clarifier to condense or provide shorter description"
      - DO NOT create task
  </description_too_long>
  
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
  
  <clarifier_failed>
    If description-clarifier fails:
      - Return error: "Failed to clarify description: {error details}"
      - Suggest: "Use --skip-clarification flag to skip clarification"
      - DO NOT create task
  </clarifier_failed>
  
  <task_creator_failed>
    If task-creator fails:
      - Return error: "Failed to create task: {error details}"
      - Include task-creator error details
      - Suggest checking TODO.md and state.json
      - DO NOT retry
  </task_creator_failed>
</error_handling>

## Usage

```bash
/task DESCRIPTION [FLAGS]
/task "sync thing for todo and state"
/task "fix the lean stuff" --priority High
/task "Add documentation" --effort "2 hours" --language markdown
/task "Implement feature X" --skip-clarification --priority Medium --effort "4 hours" --language lean
```

## What This Does

1. Parses rough description and optional flags from $ARGUMENTS
2. Validates inputs (description, priority, effort, language)
3. Invokes description-clarifier to research and clarify description (unless skipped)
4. Parses clarified description and metadata
5. Invokes task-creator to create task entry in TODO.md and state.json
6. Returns task number and next steps to user

**CRITICAL**: This command ONLY creates task entries. It does NOT implement tasks.

## Flags

| Flag | Values | Default | Description |
|------|--------|---------|-------------|
| --priority | Low\|Medium\|High | Detected by clarifier | Task priority |
| --effort | TBD or time estimate | Detected by clarifier | Effort estimate |
| --language | lean\|markdown\|general\|python\|shell\|json\|meta | Detected by clarifier | Task language |
| --skip-clarification | (boolean) | false | Skip description clarification |

## Description Clarification

By default, /task invokes description-clarifier to:
- Research similar tasks in TODO.md
- Search context files and documentation
- Generate clear 2-3 sentence description
- Detect language, priority, and effort from context
- Return clarified description with metadata

Clarification is SKIPPED if:
- --skip-clarification flag is set
- All three flags (--language, --priority, --effort) are provided

## Language Detection

If --language flag not provided, language is auto-detected by description-clarifier from:
- Keywords in description
- Similar tasks in TODO.md
- Context files and documentation

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
# Basic task creation with clarification
/task "sync thing for todo and state"
# → Clarifies to: "Create a /sync command that synchronizes TODO.md and state.json..."
# → Detects: Language=meta, Priority=High, Effort=4-6 hours

# Task with custom priority (still clarifies description)
/task "Add feature X" --priority High
# → Clarifies description, uses High priority

# Task with all flags (skips clarification)
/task "Implement proof for theorem Y" --priority High --effort "4 hours" --language lean
# → Skips clarification, uses provided values

# Task with skip-clarification flag
/task "Fix bug in Foo.lean. The issue is that the proof doesn't compile due to type mismatch." --skip-clarification
# → Uses description as-is (must be 50-500 chars)
```

## Important Notes

1. This command ONLY creates task entries - it does NOT implement tasks
2. Uses delegation to description-clarifier and task-creator subagents
3. Description clarification is automatic unless skipped
4. Task number comes from state.json next_project_number field
5. After creating task, user must use /research, /plan, /implement separately
6. Language field is MANDATORY per tasks.md line 110 quality checklist
7. Description field is MANDATORY (new requirement)
8. Metadata format uses `- **Field**:` pattern
9. All required fields (Language, Effort, Priority, Status, Description) are enforced

## Version History

- **v2.0.0** (2026-01-04): Added description clarification with description-clarifier subagent
- **v1.0.0** (2026-01-03): Initial inline implementation
