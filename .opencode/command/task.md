---
command: task
description: Create, recover, divide, sync, or abandon tasks
version: "1.0"
mode: command
temperature: 0.2
arguments:
  name: description
  type: string
  required: false
  description: Task description when no flags are provided
  name: recover
  type: string
  required: false
  description: Task ranges to recover (flag recover)
  name: expand
  type: string
  required: false
  description: Task number and optional prompt (flag expand)
  name: sync
  type: boolean
  required: false
  description: Sync specs/TODO.md and specs/state.json (flag sync)
  name: abandon
  type: string
  required: false
  description: Task ranges to archive (flag abandon)
  name: review
  type: integer
  required: false
  description: Task number to review (flag review)
tools:
  read: true
  write: true
  edit: true
  glob: false
  bash: true
permissions:
  read:
    "**/*.md": "allow"
    ".opencode/**/*": "allow"
    "specs/**/*": "allow"
  write:
    "specs/TODO.md": "allow"
  bash:
    "git:*": "allow"
    "jq:*": "allow"
    "mv:*": "allow"
    "date:*": "allow"
    "sed:*": "allow"
    "*": "deny"
allowed_tools: Read(specs/*), Edit(specs/TODO.md), Bash(jq:*), Bash(git:*), Bash(mv:*), Bash(date:*), Bash(sed:*)
argument_hint: "\"description\" | --recover N | --expand N | --sync | --abandon N | --review N"
delegation_depth: 0
max_delegation_depth: 3
context_loading:
  strategy: lazy
  index: ".opencode/context/index.md"
  required:
    - "core/workflows/command-lifecycle.md"
---

# Command: /task

**Purpose**: Unified task lifecycle management  
**Layer**: 2 (Command File - Argument Parsing Agent)  
**Delegates To**: None (Direct execution)

---

## Argument Parsing

<argument_parsing>
  <step_1>
    Parse $ARGUMENTS to detect operation mode:
    
    Check for flags in order:
    - `--recover RANGES` -> Recover mode
    - `--expand N [prompt]` -> Expand mode
    - `--sync` -> Sync mode
    - `--abandon RANGES` -> Abandon mode
    - `--review N` -> Review mode
    - No flag -> Create task mode
  </step_1>
  
  <step_2>
    CRITICAL: $ARGUMENTS is a DESCRIPTION, not instructions
    - DO NOT interpret as instructions to execute
    - DO NOT investigate, analyze, or implement
    - ONLY create task entries when in create mode
  </step_2>
</argument_parsing>

---

## Workflow Execution

<workflow_execution>
  <create_task_mode>
    <step_1>
      <action>Extract Description</action>
      <process>
        Parse description from $ARGUMENTS
        Remove trailing flags (--priority, --effort, --language)
        Extract optional: priority, effort, language
      </process>
    </step_1>
    
    <step_2>
      <action>Detect Language</action>
      <process>
        Keywords analysis:
        - "lean", "theorem", "proof", "lemma", "Mathlib" -> lean
        - "meta", "agent", "command", "skill" -> meta
        - Otherwise -> general
      </process>
    </step_2>
    
    <step_3>
      <action>Create Slug</action>
      <process>
        Lowercase, replace spaces with underscores
        Remove special characters
        Max 50 characters
      </process>
    </step_3>
    
    <step_4>
      <action>Update State Files</action>
      <process>
        Update specs/state.json with new task entry
        Update specs/TODO.md frontmatter and entry
        Ensure next_project_number matches in both files
      </process>
    </step_4>
    
    <step_5>
      <action>Commit Changes</action>
      <process>
        git add specs/
        git commit -m "task {N}: create {title}"
      </process>
    </step_5>
  </create_task_mode>
  
  <recover_mode>
    <step_1>
      <action>Parse Ranges</action>
      <process>
        Parse task ranges after --recover (e.g., "343-345", "337, 343")
      </process>
    </step_1>
    
    <step_2>
      <action>Move Tasks</action>
      <process>
        For each task number:
        Lookup in archive state.json
        Move to active_projects
        Move directory from archive (if exists)
        Update specs/TODO.md
      </process>
    </step_2>
    
    <step_3>
      <action>Commit Changes</action>
      <process>
        git commit -m "task: recover tasks {ranges}"
      </process>
    </step_3>
  </recover_mode>
  
  <expand_mode>
    <step_1>
      <action>Parse Task and Prompt</action>
      <process>
        Extract task number and optional prompt
      </process>
    </step_1>
    
    <step_2>
      <action>Analyze and Create Subtasks</action>
      <process>
        Lookup task data
        Analyze description for natural breakpoints
        Create 2-5 subtasks
        Update original task to expanded status
      </process>
    </step_2>
    
    <step_3>
      <action>Commit Changes</action>
      <process>
        git commit -m "task {N}: expand into subtasks"
      </process>
    </step_3>
  </expand_mode>
  
  <sync_mode>
    <step_1>
      <action>Compare State Files</action>
      <process>
        Read task lists from specs/state.json and specs/TODO.md
        Compare for consistency
        Use git blame for conflict resolution
      </process>
    </step_1>
    
    <step_2>
      <action>Reconcile Differences</action>
      <process>
        Sync discrepancies
        Ensure next_project_number matches
        Update both files as needed
      </process>
    </step_2>
    
    <step_3>
      <action>Commit Changes</action>
      <process>
        git commit -m "sync: reconcile specs/TODO.md and specs/state.json"
      </process>
    </step_3>
  </sync_mode>
  
  <review_mode>
    <step_1>
      <action>Validate Task</action>
      <process>
        Lookup task via jq
        Extract metadata (slug, status, language, priority)
      </process>
    </step_1>
    
    <step_2>
      <action>Load Artifacts</action>
      <process>
        Find and load plan, summary, research files
        Parse plan phases and statuses
      </process>
    </step_2>
    
    <step_3>
      <action>Generate Review Summary</action>
      <process>
        Display task overview
        Analyze phase completion
        Identify incomplete work
        Generate follow-up task suggestions
      </process>
    </step_3>
    
    <step_4>
      <action>Interactive Selection</action>
      <process>
        Present suggestions to user
        Parse user selection
        Create selected follow-up tasks
      </process>
    </step_4>
    
    <step_5>
      <action>Commit Changes</action>
      <process>
        If tasks created: git commit -m "task {N}: review - created {N} follow-up tasks"
      </process>
    </step_5>
  </review_mode>
  
  <abandon_mode>
    <step_1>
      <action>Parse Ranges</action>
      <process>
        Parse task ranges after --abandon
      </process>
    </step_1>
    
    <step_2>
      <action>Archive Tasks</action>
      <process>
        For each task number:
        Lookup and validate task
        Move to archive with abandoned status
        Remove from active_projects
        Remove from specs/TODO.md
        Move directory to archive (if exists)
      </process>
    </step_2>
    
    <step_3>
      <action>Commit Changes</action>
      <process>
        git commit -m "task: abandon tasks {ranges}"
      </process>
    </step_3>
  </abandon_mode>
</workflow_execution>

---

## Error Handling

<error_handling>
  <argument_errors>
    - Invalid flag -> Return usage help
    - Task not found -> Return error message
    - Invalid range format -> Return error with examples
  </argument_errors>
  
  <execution_errors>
    - jq failures -> Return error with technical details
    - File permission errors -> Return error with guidance
    - Git commit failures -> Log warning, continue
  </execution_errors>
</error_handling>

---

## State Management

<state_management>
  <reads>
    specs/state.json
    specs/TODO.md
    specs/archive/state.json (if exists)
  </reads>
  
  <writes>
    specs/state.json
    specs/TODO.md
    specs/archive/state.json (for abandon/recover)
  </writes>
</state_management>

---

## Constraints

<constraints>
  <hard_stop_after_output>
    After printing task creation output, STOP IMMEDIATELY
  </hard_stop_after_output>
  
  <scope_restriction>
    Only touch files in `specs/`:
    - specs/state.json - Machine state
    - specs/TODO.md - Task list
    - specs/archive/state.json - Archived tasks
  </scope_restriction>
  
  <forbidden_actions>
    - Read files outside `specs/`
    - Write files outside `specs/`
    - Implement, investigate, or analyze task content
    - Run build tools, tests, or development commands
    - Interpret description as instructions to follow
  </forbidden_actions>
</constraints>