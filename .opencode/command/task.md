---
name: task
agent: orchestrator
description: "Create new task in .opencode/specs/TODO.md (NO implementation)"
timeout: 120
routing:
  default: task-creator
---

**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

**CRITICAL WARNING**: This command ONLY creates task entries. It MUST NOT implement tasks.

<context>
  <system_context>Task creation command with delegation to task-creator subagent</system_context>
  <task_context>Parse task description and flags, delegate to task-creator for atomic creation</task_context>
</context>

<role>Task creation command - Parse arguments and route to task-creator subagent</role>

<task>
  CRITICAL: This command ONLY creates task entries in TODO.md. It NEVER implements tasks.
  
  Process:
  1. Parse task description from $ARGUMENTS
  2. Extract optional flags (--priority, --effort, --language)
  3. Validate all inputs
  4. Delegate to task-creator subagent
  5. Return task number to user
  
  DO NOT implement the task. DO NOT create any files except via task-creator delegation.
  DO NOT examine existing files to understand how to implement the task.
  DO NOT create /sync commands or any other implementation.
  
  ONLY parse arguments and delegate to task-creator.
</task>

<critical_constraints>
  <absolutely_forbidden>
    This command MUST NOT:
    - Implement the task described in $ARGUMENTS
    - Create any commands, agents, or implementation files
    - Examine existing code to understand implementation
    - Create /sync commands or similar
    - Do anything except parse arguments and delegate to task-creator
    
    If you find yourself thinking about HOW to implement the task:
    - STOP immediately
    - You are violating the command constraints
    - Return to parsing arguments and delegating to task-creator
  </absolutely_forbidden>
  
  <only_allowed_actions>
    The ONLY actions allowed:
    1. Parse task description from $ARGUMENTS
    2. Extract --priority, --effort, --language flags
    3. Validate inputs
    4. Delegate to task-creator subagent
    5. Return result to user
  </only_allowed_actions>
</critical_constraints>

<workflow_execution>
  <critical_reminder>
    STOP: Before executing any stage, remember:
    - This command ONLY creates task entries
    - This command NEVER implements tasks
    - If $ARGUMENTS says "Implement X" or "Create Y", you are NOT implementing X or creating Y
    - You are creating a TASK ENTRY that describes implementing X or creating Y
    - The task will be implemented LATER by /implement command
    
    Your ONLY job: Parse arguments → Delegate to task-creator → Return task number
  </critical_reminder>
  
  <stage id="1" name="ParseAndValidate">
    <action>Parse task description and extract optional flags</action>
    <process>
      1. Parse task description from $ARGUMENTS
         - $ARGUMENTS contains: "Implement feature X" or "Fix bug Y --priority High --effort 4h"
         - Extract description (everything before first --)
         - Extract flags: --priority, --effort, --language
         - Validate description is non-empty
      
      2. Extract and validate priority flag (default: Medium)
         - Parse --priority flag if present
         - Validate is Low|Medium|High
         - Default to Medium if not provided
         - If invalid: Return error "Priority must be Low, Medium, or High"
      
      3. Extract and validate effort flag (default: TBD)
         - Parse --effort flag if present
         - Validate is TBD or time estimate (e.g., "2 hours", "4h", "1 day")
         - Default to TBD if not provided
      
      4. Detect or extract language (default: general)
         - If --language flag present: use that value
         - Else: detect from description keywords:
           * "lean", "proof", "theorem", "lemma", "tactic" → lean
           * "markdown", "doc", "README", "documentation" → markdown
           * "agent", "command", "context", "meta" → meta
           * "python", "py" → python
           * "shell", "bash", "sh" → shell
           * Default → general
         - Validate language is valid (lean|markdown|general|python|shell|json|meta)
         - If invalid: Return error "Language must be lean, markdown, general, python, shell, json, or meta"
      
      5. Validate all inputs
         - description: non-empty string
         - priority: Low|Medium|High
         - effort: TBD or time estimate
         - language: lean|markdown|general|python|shell|json|meta
    </process>
    <validation>
      - Description is non-empty
      - Priority is Low|Medium|High
      - Effort is TBD or time estimate
      - Language is valid value
    </validation>
    <checkpoint>Task description validated, metadata extracted</checkpoint>
  </stage>
  
  <stage id="2" name="Delegate">
    <action>Delegate to task-creator subagent</action>
    <process>
      CRITICAL: You are NOW delegating to task-creator. You are NOT implementing anything.
      
      1. Invoke task-creator via task tool:
         task(
           subagent_type="task-creator",
           prompt="Create task: ${description}. Priority: ${priority}. Effort: ${effort}. Language: ${language}.",
           description="Create task entry"
         )
      
      2. Wait for task-creator to complete
         - task-creator will allocate task number
         - task-creator will update TODO.md and state.json
         - task-creator will return task number
      
      3. Relay result to user:
         - Pass through task-creator's response
         - Include task number
         - Include next steps (use /research, /plan, /implement)
      
      STOP HERE. Do NOT implement the task. Do NOT create any files.
      The task entry has been created. The user will use /research, /plan, /implement later.
    </process>
    <checkpoint>Delegated to task-creator, result relayed</checkpoint>
  </stage>
</workflow_execution>

<absolutely_critical_final_reminder>
  If you have executed Stage 1 (ParseAndValidate) and Stage 2 (Delegate), you are DONE.
  
  DO NOT:
  - Implement the task
  - Create any files
  - Examine existing code
  - Think about how to implement the task
  
  The task entry has been created in TODO.md. That is ALL this command does.
  The user will use /research, /plan, /implement to work on the task later.
</absolutely_critical_final_reminder>

<critical_constraints>
  <no_implementation>
    This command ONLY creates task entries via delegation to task-creator.
    It MUST NOT:
    - Implement the task
    - Create any spec directories
    - Create any research files
    - Create any plan files
    - Create any code files
    
    The task-creator subagent enforces these constraints via permissions.
  </no_implementation>
  
  <delegation_required>
    This command MUST delegate to task-creator subagent.
    It MUST NOT:
    - Manually update TODO.md
    - Manually update state.json
    - Bypass task-creator
    
    Delegation ensures:
    - Atomic updates (via status-sync-manager)
    - Consistent validation
    - Architectural enforcement
  </delegation_required>
</critical_constraints>

<validation>
  <pre_flight>
    - Task description validated (non-empty)
    - Priority validated (Low|Medium|High)
    - Effort validated (TBD or time estimate)
    - Language validated (lean|markdown|general|python|shell|json|meta)
  </pre_flight>
  
  <post_flight>
    - task-creator returned successfully
    - Task number received
    - No implementation occurred
  </post_flight>
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
  
  <task_creator_failure>
    If task-creator fails:
      - Return error from task-creator
      - Include guidance from task-creator
      - DO NOT retry (task-creator handles errors)
  </task_creator_failure>
</error_handling>

<usage_examples>
  <example_1>
    Input: /task "Implement LeanSearch REST API integration"
    Output: Task 295 created with Medium priority, TBD effort, lean language
  </example_1>
  
  <example_2>
    Input: /task "Add missing directory READMEs" --priority High
    Output: Task 296 created with High priority, TBD effort, markdown language
  </example_2>
  
  <example_3>
    Input: /task "Fix delegation hang in task-executor" --effort "2 hours" --priority High
    Output: Task 297 created with High priority, 2 hours effort, general language
  </example_3>
  
  <example_4>
    Input: /task "Create new agent for X" --language meta
    Output: Task 298 created with Medium priority, TBD effort, meta language
  </example_4>
</usage_examples>

<important_notes>
  1. This command ONLY creates task entries - it does NOT implement tasks
  2. Delegates to task-creator subagent for atomic updates
  3. task-creator uses status-sync-manager for TODO.md + state.json consistency
  4. Task number comes from state.json next_project_number field
  5. After creating task, user must use /research, /plan, /implement separately
  6. Language field is MANDATORY per tasks.md line 110 quality checklist
  7. Metadata format uses `- **Field**:` pattern (enforced by task-creator)
  8. All required fields (Language, Effort, Priority, Status) enforced by task-creator
</important_notes>

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
3. Delegates to task-creator subagent
4. task-creator allocates task number from state.json
5. task-creator formats TODO.md entry following task standards
6. task-creator invokes status-sync-manager for atomic updates
7. Returns task number and next steps to user

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

## Architecture

This command follows the proven pattern from `/research` and `/implement`:

1. **2-stage workflow**: ParseAndValidate → Delegate
2. **Delegation to subagent**: task-creator handles execution
3. **Atomic updates**: status-sync-manager ensures consistency
4. **Architectural enforcement**: Permissions prevent implementation

See `.opencode/agent/subagents/task-creator.md` for details.
