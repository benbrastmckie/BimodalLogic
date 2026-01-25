---
command: refresh
description: Refresh OpenCode sessions and clean up temporary data
version: "1.0"
mode: command
temperature: 0.2
arguments:
  name: dry_run
  type: boolean
  required: false
  description: Preview cleanup (flag dry-run)
  name: force
  type: boolean
  required: false
  description: Skip confirmation (flag force)
tools:
  read: false
  write: false
  edit: false
  glob: false
  bash: true
permissions:
  read:
    "*": "deny"
  write:
    "*": "deny"
  bash:
    "*": "allow"
allowed_tools: Bash, AskUserQuestion
argument_hint: [--dry-run] [--force]
delegation_depth: 1
max_delegation_depth: 3
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
---

# Command: /refresh

**Purpose**: Comprehensive cleanup of OpenCode resources - terminate orphaned processes and clean up ~/.opencode/ directory  
**Layer**: 2 (Command File - Argument Parsing Agent)  
**Delegates To**: skill-refresh

---

## Argument Parsing

<argument_parsing>
  <step_1>
    Parse arguments:
    dry_run = "--dry-run" in $ARGUMENTS
    force = "--force" in $ARGUMENTS
    
    Determine execution mode:
    - dry_run: Preview only
    - force: Skip confirmation, 8-hour default
    - neither: Interactive mode with prompts
  </step_1>
</argument_parsing>

---

## Workflow Execution

<workflow_execution>
  <step_1>
    <action>Delegate to Refresh Skill</action>
    <input>
      - skill: "skill-refresh"
      - args: "dry_run={dry_run} force={force}"
    </input>
    <expected_return>
      {
        "status": "completed",
        "processes_terminated": N,
        "files_deleted": N,
        "space_reclaimed": "X.X GB",
        "cleanup_report": {...}
      }
    </expected_return>
  </step_1>

  <step_2>
    <action>Present Results</action>
    <process>
      Display cleanup summary:
      - Process cleanup results
      - Directory cleanup results
      - Space reclaimed
      - Files deleted count
      
      Return to orchestrator
    </process>
  </step_2>
</workflow_execution>

---

## Error Handling

<error_handling>
  <argument_errors>
    - Invalid flags -> Return usage help
  </argument_errors>
  
  <execution_errors>
    - Skill failure -> Return error message
    - Permission errors -> Return error with sudo suggestion
    - Process termination failures -> Log warning, continue with directory cleanup
  </execution_errors>
</error_handling>

---

## State Management

<state_management>
  <reads>
    None (read-only cleanup)
  </reads>
  
  <writes>
    None (skill handles temporary file operations)
  </writes>
</state_management>