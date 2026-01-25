---
command: plan
description: Create implementation plan for a task
version: "1.0"
mode: command
temperature: 0.2
arguments:
  name: task_number
  type: integer
  required: true
  description: Task number to create a plan for
tools:
  read: true
  write: true
  edit: true
  glob: true
  bash: true
  skill: true
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
allowed_tools: Skill, Bash(jq:*), Bash(git:*), Read, Edit
argument_hint: TASK_NUMBER
delegation_depth: 1
max_delegation_depth: 3
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
---

# Command: /plan

**Purpose**: Create phased implementation plan for a task  
**Layer**: 2 (Command File - Argument Parsing Agent)  
**Delegates To**: skill-planner

---

## Argument Parsing

<argument_parsing>
  <step_1>
    Extract task_number from args[0]
    If missing: Return error "Usage: /plan <task_number>"
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
    Validate Status:
    status=$(echo "$task_data" | jq -r '.status')
    allowed_statuses=["not_started", "researched", "partial"]
    
    If status not in allowed_statuses:
      If status == "planned": Note existing plan, offer --force (if implemented)
      If status == "completed": Return error "Task already completed"
      If status == "implementing": Return error "Task in progress, use /revise instead"
      Else: Return error "Task status is {status}, expected {allowed_statuses}"
  </step_4>
</argument_parsing>

---

## Workflow Execution

<workflow_execution>
  <step_1>
    <action>Load Context</action>
    <process>
      - Task description from specs/state.json
      - Research reports from `specs/{N}_{SLUG}/reports/` (if any)
    </process>
  </step_1>

  <step_2>
    <action>Delegate to Planner Skill</action>
    <input>
      - skill: "skill-planner"
      - args: "task_number={N} research_path={path} session_id={session_id}"
    </input>
    <expected_return>
      {
        "status": "planned",
        "summary": "...",
        "artifacts": [...],
        "metadata": {"phase_count": N, "estimated_hours": M}
      }
    </expected_return>
  </step_2>
  
  <step_3>
    <action>Validate Return and Update State</action>
    <validation>
      - status is "planned"
      - artifacts array is present
      - plan file exists on disk
    </validation>
    <process>
      Confirm status is now "planned" in specs/state.json (Skill handles update)
    </process>
  </step_3>
  
  <step_4>
    <action>Commit Changes</action>
    <process>
      ```bash
      git add -A
      git commit -m "$(cat <<'EOF'
      task {N}: create implementation plan
      
      Session: {session_id}
      
      Co-Authored-By: OpenCode <noreply@opencode.ai>
      EOF
      )"
      ```
    </process>
  </step_4>
  
  <step_5>
    <action>Return Result</action>
    <output>
      Display plan path, phase count, estimated effort
      Return to orchestrator
    </output>
  </step_5>
</workflow_execution>

---

## Error Handling

<error_handling>
  <argument_errors>
    - Task not found -> Return error with guidance
    - Invalid status -> Return error with current status
  </argument_errors>
  
  <workflow_errors>
    - Skill failure -> Keep [PLANNING], log error
    - Timeout -> Partial plan preserved, user can re-run
    - Missing artifacts -> Log warning, continue with available
    - Commit failure -> Log warning, continue
  </workflow_errors>
</error_handling>

---

## State Management

<state_management>
  <reads>
    task_data=$(jq ...)
  </reads>
  
  <writes>
    # Delegated to skill for internal updates
    # Direct commit in Step 4
  </writes>
</state_management>