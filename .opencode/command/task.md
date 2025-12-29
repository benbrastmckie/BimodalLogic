---
name: task
agent: orchestrator
description: "Create new task in .opencode/specs/TODO.md (NO implementation)"
context_level: 1
language: markdown
---

**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

Context Loaded:
@.opencode/specs/.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md

<context>
  <system_context>
    Simple task creation system - ONLY creates task entries, NEVER implements them.
    Reads next_project_number from state.json, creates .opencode/specs/TODO.md entry, increments number.
  </system_context>
  <domain_context>
    .opencode/specs/TODO.md task management with status markers, effort estimates, and language tracking.
  </domain_context>
  <task_context>
    Create new task entry in .opencode/specs/TODO.md with next available number from state.json,
    standardized format, and initial [NOT STARTED] status. DO NOT IMPLEMENT THE TASK.
  </task_context>
  <execution_context>
    Direct file operations only. No subagent delegation. No directory creation.
    This command ONLY creates the task entry and updates state.json.
  </execution_context>
</context>

<role>Task Creation Command - Add new tasks to .opencode/specs/TODO.md WITHOUT implementing them</role>

<task>
  CRITICAL: This command ONLY creates task entries. It NEVER implements tasks.
  
  Process:
  1. Parse task description from $ARGUMENTS
  2. Read next_project_number from .opencode/specs/state.json
  3. Create task entry in .opencode/specs/TODO.md
  4. Increment next_project_number in state.json
  5. Return task number to user
  
  DO NOT implement the task. DO NOT create any files except updating .opencode/specs/TODO.md and state.json.
</task>

<workflow_execution>
  <stage id="1" name="ParseInput">
    <action>Parse task description and extract optional metadata</action>
    <process>
      1. Parse task description from $ARGUMENTS
      2. Extract --priority flag if present (default: Medium)
      3. Extract --effort flag if present (default: TBD)
      4. Detect language from description keywords:
         - "lean", "proof", "theorem" → Language: lean
         - "markdown", "doc", "README" → Language: markdown
         - Default → Language: general
      5. Validate description is non-empty
      6. VALIDATION: Verify Language field will be set (required per tasks.md line 110)
      7. VALIDATION: Verify metadata format will use `- **Field**:` pattern
      8. VALIDATION: Verify all required fields present (Language, Effort, Priority, Status)
    </process>
    <validation>
      - Description must be non-empty string
      - Priority must be: Low|Medium|High (default: Medium)
      - Effort must be: TBD or time estimate like "2 hours"
      - Language must be set (lean|markdown|general) - MANDATORY per tasks.md
      - Metadata format must use `- **Field**:` pattern (not `*Field**:`)
      - Required fields: Language, Effort, Priority, Status
    </validation>
    <validation_errors>
      If Language not detected or set:
        - Error: "Language field is required but could not be detected"
        - Guidance: "Use --language flag to specify: lean, markdown, or general"
        - DO NOT create task
      
      If metadata format invalid:
        - Error: "Metadata format must use `- **Field**:` pattern"
        - Guidance: "Check task standards at .opencode/context/common/standards/tasks.md"
        - DO NOT create task
      
      If required field missing:
        - Error: "Required field missing: {field_name}"
        - Guidance: "All tasks must have Language, Effort, Priority, and Status fields"
        - DO NOT create task
    </validation_errors>
    <examples>
      - `/task "Implement LeanSearch integration"` → priority=Medium, effort=TBD, language=lean
      - `/task "Fix build error" --priority High --effort "2 hours"` → priority=High, effort=2 hours
      - `/task "Update README.md documentation"` → language=markdown
    </examples>
  </stage>

  <stage id="2" name="ReadNextNumber">
    <action>Read next_project_number from state.json</action>
    <process>
      1. Read .opencode/specs/state.json
      2. Extract next_project_number field
      3. Validate it's a number >= 0
      4. Store for use in task creation
    </process>
    <error_handling>
      If state.json missing or invalid:
        - Return error to user
        - Suggest running /todo to regenerate state.json
        - DO NOT proceed with task creation
    </error_handling>
  </stage>

  <stage id="3" name="CreateTODOEntry">
    <action>Create formatted .opencode/specs/TODO.md entry</action>
    <process>
      1. Format task entry following .opencode/specs/TODO.md conventions:
         ```
         ### {number}. {description}
         - **Effort**: {effort}
         - **Status**: [NOT STARTED]
         - **Priority**: {priority}
         - **Language**: {language}
         - **Blocking**: None
         - **Dependencies**: None
         ```
      2. Determine correct section in .opencode/specs/TODO.md based on priority:
         - High → ## High Priority section
         - Medium → ## Medium Priority section
         - Low → ## Low Priority section
      3. Append entry to appropriate section
      4. Use Edit tool to add entry (preserves file structure)
    </process>
    <format_example>
      ### 200. Implement LeanSearch REST API integration
      - **Effort**: TBD
      - **Status**: [NOT STARTED]
      - **Priority**: Medium
      - **Language**: lean
      - **Blocking**: None
      - **Dependencies**: None
    </format_example>
  </stage>

  <stage id="4" name="UpdateStateJson">
    <action>Increment next_project_number in state.json</action>
    <process>
      1. Read current state.json
      2. Increment next_project_number by 1
      3. Add entry to recent_activities:
         ```
         {
           "timestamp": "{ISO-8601}",
           "activity": "Created task {number}: {description} ({effort}, {priority} priority)"
         }
         ```
      4. Update _last_updated timestamp
      5. Write state.json atomically
    </process>
    <atomic_write>
      Use Edit tool with complete JSON replacement to ensure atomic update
    </atomic_write>
  </stage>

  <stage id="5" name="ReturnSuccess">
    <action>Return task number and confirmation to user</action>
    <return_format>
      Task {number} created: {description}
      - Priority: {priority}
      - Effort: {effort}
      - Language: {language}
      - Status: [NOT STARTED]
      
      Task added to .opencode/specs/TODO.md in {priority} Priority section.
      Next available task number is now {next_number}.
      
      Use `/research {number}` to research this task.
      Use `/plan {number}` to create implementation plan.
      Use `/implement {number}` to implement the task.
    </return_format>
  </stage>
</workflow_execution>

<critical_constraints>
  <no_implementation>
    This command ONLY creates task entries. It MUST NOT:
    - Implement the task
    - Create any spec directories
    - Create any research files
    - Create any plan files
    - Create any code files
    - Delegate to any subagents
    
    The ONLY files modified are:
    - .opencode/specs/.opencode/specs/TODO.md (add task entry)
    - .opencode/specs/state.json (increment next_project_number)
  </no_implementation>
  
  <no_delegation>
    This command operates entirely within the orchestrator.
    It MUST NOT delegate to ANY subagents including:
    - atomic-task-numberer (not needed - we read state.json directly)
    - status-sync-manager (not needed - simple file update)
    - Any other subagents
  </no_delegation>
  
  <file_operations_only>
    This command performs only these file operations:
    1. Read .opencode/specs/state.json
    2. Read .opencode/specs/.opencode/specs/TODO.md
    3. Edit .opencode/specs/.opencode/specs/TODO.md (add task entry)
    4. Edit .opencode/specs/state.json (increment next_project_number)
    
    No other file operations are allowed.
  </file_operations_only>
</critical_constraints>

<validation>
  <pre_flight>
    - Task description validated (non-empty)
    - Priority validated (Low|Medium|High)
    - Effort validated (TBD or time estimate)
    - Language detected or defaulted to general
    - Language field MUST be set (required per tasks.md line 110)
    - Metadata format validated (uses `- **Field**:` pattern, not `*Field**:`)
    - All required fields present (Language, Effort, Priority, Status)
    - Validation errors return clear guidance and prevent task creation
  </pre_flight>
  
  <mid_flight>
    - state.json exists and is readable
    - next_project_number is valid number
    - .opencode/specs/TODO.md exists and is writable
  </mid_flight>
  
  <post_flight>
    - .opencode/specs/TODO.md contains new task entry in correct section
    - state.json next_project_number incremented
    - state.json recent_activities updated
    - No other files created or modified
    - No implementation performed
  </post_flight>
</validation>

<quality_standards>
  <status_markers>
    Use [NOT STARTED] for new tasks per status-markers.md
  </status_markers>
  
  <language_detection>
    Detect language from description keywords:
    - lean: "lean", "proof", "theorem", "lemma", "tactic"
    - markdown: "markdown", "doc", "README", "documentation"
    - general: anything else
  </language_detection>
  
  <priority_sections>
    Add task to correct .opencode/specs/TODO.md section based on priority:
    - High → ## High Priority
    - Medium → ## Medium Priority  
    - Low → ## Low Priority
  </priority_sections>
  
  <no_emojis>
    No emojis in task entries or command output
    
    Validation: Before returning artifacts, verify:
    - grep -E "[\x{1F300}-\x{1F9FF}\x{2600}-\x{26FF}\x{2700}-\x{27BF}]" artifact.md returns no results
    - If emojis found: Replace with text alternatives ([PASS]/[FAIL]/[WARN])
    - Fail command if emojis cannot be removed
  </no_emojis>
  
  <atomic_updates>
    state.json updates must be atomic to prevent corruption
  </atomic_updates>
</quality_standards>

<usage_examples>
  <example_1>
    Input: /task "Implement LeanSearch REST API integration"
    Output: Task 200 created with Medium priority, TBD effort, lean language
  </example_1>
  
  <example_2>
    Input: /task "Add missing directory READMEs" --priority High
    Output: Task 201 created with High priority, TBD effort, markdown language
  </example_2>
  
  <example_3>
    Input: /task "Fix delegation hang in task-executor" --effort "2 hours" --priority High
    Output: Task 202 created with High priority, 2 hours effort, general language
  </example_3>
</usage_examples>

<error_handling>
  <missing_state_json>
    If state.json doesn't exist:
      - Return error: "state.json not found at .opencode/specs/state.json"
      - Suggest: "Run /todo to regenerate state files"
      - DO NOT create task
  </missing_state_json>
  
  <invalid_state_json>
    If state.json is corrupt or missing next_project_number:
      - Return error: "state.json is invalid or missing next_project_number"
      - Suggest: "Run /todo to regenerate state files"
      - DO NOT create task
  </invalid_state_json>
  
  <missing_todo>
    If .opencode/specs/TODO.md doesn't exist:
      - Return error: ".opencode/specs/TODO.md not found at .opencode/specs/.opencode/specs/TODO.md"
      - Suggest: "Run /todo to regenerate .opencode/specs/TODO.md"
      - DO NOT create task
  </missing_todo>
  
  <empty_description>
    If task description is empty:
      - Return error: "Task description cannot be empty"
      - Show usage: "/task \"Your task description here\""
      - DO NOT create task
  </empty_description>
</error_handling>

<important_notes>
  1. This command ONLY creates task entries - it does NOT implement tasks
  2. No subagent delegation - all operations in orchestrator
  3. Only two files modified: .opencode/specs/TODO.md and state.json
  4. Task number comes from state.json next_project_number field
  5. After creating task, user must use /research, /plan, /implement separately
  6. VALIDATION: Language field is MANDATORY per tasks.md line 110 quality checklist
  7. VALIDATION: Metadata format must use `- **Field**:` pattern (not `*Field**:`)
  8. VALIDATION: All required fields (Language, Effort, Priority, Status) must be present
</important_notes>

<task_standard_enforcement>
  <validation_logic>
    The /task command enforces task standards defined in .opencode/context/common/standards/tasks.md:
    
    1. Language Field Validation:
       - Language field is MANDATORY (tasks.md line 110 quality checklist)
       - Must be one of: lean, markdown, general, python, shell, json
       - Detected from description keywords or defaulted to general
       - If detection fails and no --language flag: ERROR and reject task creation
    
    2. Metadata Format Validation:
       - All metadata fields must use `- **Field**:` pattern
       - Incorrect patterns like `*Field**:` are REJECTED
       - Ensures consistency with task standards
    
    3. Required Fields Validation:
       - Language: MANDATORY (routing to Lean-specific agents)
       - Effort: MANDATORY (defaults to TBD if not provided)
       - Priority: MANDATORY (defaults to Medium if not provided)
       - Status: MANDATORY (always [NOT STARTED] for new tasks)
    
    4. Error Messages:
       - Clear, actionable error messages for validation failures
       - Guidance on how to fix the issue
       - Reference to task standards documentation
       - Task creation BLOCKED until validation passes
  </validation_logic>
  
  <language_field_importance>
    The Language field is critical for routing tasks to appropriate agents:
    - Language: lean → Routes to lean-research-agent and lean-implementation-agent
    - Language: markdown → Routes to general agents with documentation focus
    - Language: general → Routes to general-purpose agents
    
    Missing Language field prevents proper routing and breaks Lean-specific workflows.
    This is why Language is MANDATORY per tasks.md line 110 quality checklist.
  </language_field_importance>
  
  <manual_editing_warning>
    WARNING: Manual editing of .opencode/specs/TODO.md bypasses validation.
    
    If you manually edit TODO.md:
    - Ensure Language field is present for ALL tasks
    - Use `- **Field**:` format (not `*Field**:`)
    - Include all required fields (Language, Effort, Priority, Status)
    - Follow task standards in .opencode/context/common/standards/tasks.md
    
    Manual edits that violate standards may cause:
    - Routing failures (tasks sent to wrong agents)
    - Parsing errors (automation tools can't read tasks)
    - Workflow breakage (missing metadata breaks /implement, /research)
  </manual_editing_warning>
</task_standard_enforcement>
