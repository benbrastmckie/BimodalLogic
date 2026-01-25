---
command: revise
description: Create new version of implementation plan, or update task description if no plan exists
version: "1.0"
mode: command
temperature: 0.2
arguments:
  name: task_number
  type: integer
  required: true
  description: Task number to revise
  name: reason
  type: string
  required: false
  description: Optional reason for revision
tools:
  read: true
  write: true
  edit: true
  glob: true
  grep: true
  bash: true
permissions:
  read:
    "**/*.md": "allow"
    ".opencode/**/*": "allow"
    "specs/**/*": "allow"
  write:
    "specs/**/*": "allow"
  bash:
    "git:*": "allow"
    "jq:*": "allow"
    "*": "deny"
allowed_tools: Read, Write, Edit, Glob, Grep, Bash(jq:*), Bash(git:*), TodoWrite
argument_hint: TASK_NUMBER [REASON]
delegation_depth: 1
max_delegation_depth: 3
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
---

# Command: /revise

**Purpose**: Create a new version of an implementation plan, or update task description if no plan exists  
**Layer**: 2 (Command File - Argument Parsing Agent)  
**Delegates To**: skill-reviser

---

## Argument Parsing

<argument_parsing>
  <step_1>
    Extract task_number from args[0]
    Extract revision_reason from remaining args (optional)
    
    If task_number missing: Return error "Usage: /revise <task_number> [reason]"
  </step_1>
  
  <step_2>
    Generate Session ID:
    session_id = sess_{timestamp}_{random}
  </step_2>
  
  <step_3>
    Lookup Task in specs/state.json:
    ```bash
    task_data=$(jq -r --arg num "$task_number" \
      '.active_projects[] | select(.project_number == ($num | tonumber))' \
      specs/state.json)
    ```
    
    If task not found: Return error "Task {task_number} not found"
  </step_3>
  
  <step_4>
    Determine Revision Type based on status:
    - planned, implementing, partial, blocked → Plan Revision
    - not_started, researched → Description Update
    - completed → Return error "Task completed, no revision needed"
    - abandoned → Return error "Task abandoned, use /task --recover first"
  </step_4>
</argument_parsing>

---

## Workflow Execution

<workflow_execution>
  <plan_revision>
    <step_1>
      <action>Load Current Context</action>
      <process>
        - Current plan from specs/{N}_{SLUG}/plans/implementation-{LATEST}.md
        - Research reports if any
        - Implementation progress (phase statuses)
      </process>
    </step_1>

    <step_2>
      <action>Delegate to Reviser Skill</action>
      <input>
        - skill: "skill-reviser"
        - args: "task_number={task_number} revision_type=plan reason={reason} session_id={session_id}"
      </input>
      <expected_return>
        {
          "status": "revised",
          "plan_version": "implementation-002.md",
          "changes_summary": [...]
        }
      </expected_return>
    </step_2>

    <step_3>
      <action>Update State</action>
      <process>
        Update specs/state.json:
        - status to "planned"
        - Add new plan artifact
        - Update timestamps
        
        Update specs/TODO.md status marker
      </process>
    </step_3>

    <step_4>
      <action>Git Commit</action>
      <process>
        ```bash
        git add -A
        git commit -m "task {N}: revise plan (v{VERSION})
        
        Session: {session_id}
        
        Co-Authored-By: OpenCode <noreply@opencode.ai>"
        ```
      </process>
    </step_4>
  </plan_revision>

  <description_update>
    <step_1>
      <action>Load Current Description</action>
      <process>
        Extract old_description from task_data
      </process>
    </step_1>

    <step_2>
      <action>Validate Revision Reason</action>
      <validation>
        If no revision_reason provided: Return error "No revision reason provided. Usage: /revise N \"new description\""
      </validation>
    </step_2>

    <step_3>
      <action>Delegate to Reviser Skill</action>
      <input>
        - skill: "skill-reviser"
        - args: "task_number={task_number} revision_type=description new_description={reason} session_id={session_id}"
      </input>
      <expected_return>
        {
          "status": "updated",
          "description": "new description text"
        }
      </expected_return>
    </step_3>

    <step_4>
      <action>Update State</action>
      <process>
        Update specs/state.json description and timestamp
        Update specs/TODO.md description
      </process>
    </step_4>

    <step_5>
      <action>Git Commit</action>
      <process>
        ```bash
        git add -A
        git commit -m "task {N}: revise description
        
        Session: {session_id}
        
        Co-Authored-By: OpenCode <noreply@opencode.ai>"
        ```
      </process>
    </step_5>
  </description_update>

  <step_6>
    <action>Return Result</action>
    <output>
      Display revision summary:
      - Task number
      - Revision type
      - Changes made
      - New status
      - Next steps
      
      Return to orchestrator
    </output>
  </step_6>
</workflow_execution>

---

## Error Handling

<error_handling>
  <argument_errors>
    - Task not found -> Return error with guidance
    - Invalid status -> Return error with current status
    - No revision reason -> Return error with usage
  </argument_errors>
  
  <execution_errors>
    - Skill failure -> Return error message
    - Missing plan file -> Fall back to description update
    - Write failures -> Log error, preserve original
  </execution_errors>
</error_handling>

---

## State Management

<state_management>
  <reads>
    specs/state.json
    task plan files
    specs/TODO.md
  </reads>
  
  <writes>
    specs/state.json
    specs/TODO.md
    New plan files (in specs/{N}_{SLUG}/plans/)
  </writes>
</state_management>