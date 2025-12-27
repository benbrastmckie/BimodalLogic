---
name: task
agent: orchestrator
description: "Add tasks to TODO.md with standardized format"
context_level: 1
language: markdown
---

**Task Input (required):** $ARGUMENTS (task description; e.g., `/task "Implement feature X"`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md

<context>
  <system_context>
    Task creation system with atomic numbering and standardized TODO.md format.
    Ensures unique task numbers and consistent task structure.
  </system_context>
  <domain_context>
    TODO.md task management with status markers, effort estimates, and language tracking.
  </domain_context>
  <task_context>
    Create new task entry in TODO.md with next available number, standardized format,
    and initial [NOT STARTED] status.
  </task_context>
  <execution_context>
    Atomic task numbering via atomic-task-numberer subagent. Status synchronization
    via status-sync-manager. No directory creation (lazy creation principle).
  </execution_context>
</context>

<role>Task Creation Command - Add new tasks to TODO.md with unique numbering</role>

<task>
  Add new task to TODO.md with atomic number allocation, standardized format,
  language detection, and synchronized state.json update.
</task>

<workflow_execution>
  <stage id="1" name="ParseInput">
    <action>Parse task description and extract metadata</action>
    <process>
      1. Parse task description from user input
      2. Extract priority (default: Medium)
      3. Extract effort estimate (default: TBD)
      4. Detect language from description keywords:
         - "lean", "proof", "theorem" → Language: lean
         - "markdown", "doc", "README" → Language: markdown
         - Default → Language: general
      5. Validate description is non-empty
    </process>
    <validation>
      - Description must be non-empty string
      - Priority must be: Low|Medium|High|Critical
      - Effort must be: TBD or valid time estimate
    </validation>
  </stage>

  <stage id="2" name="PrepareDelegation">
    <action>Prepare delegation context for atomic-task-numberer</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1 (orchestrator → task → atomic-task-numberer)
      3. Set delegation_path = ["orchestrator", "task", "atomic-task-numberer"]
      4. Set timeout = 60s (simple operation)
      5. Store session_id for validation
    </process>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "task", "atomic-task-numberer"],
        "timeout": 60
      }
    </delegation_context>
  </stage>

  <stage id="3" name="InvokeTaskNumberer">
    <action>Invoke atomic-task-numberer to get next task number</action>
    <process>
      1. Route to atomic-task-numberer subagent
      2. Pass delegation context
      3. Request next available task number
      4. Set timeout to 60s
    </process>
    <invocation>
      task_tool(
        subagent_type="atomic-task-numberer",
        prompt="Allocate next task number",
        session_id=delegation_context["session_id"],
        delegation_depth=1,
        delegation_path=delegation_context["delegation_path"],
        timeout=60
      )
    </invocation>
  </stage>

  <stage id="4" name="ReceiveTaskNumber">
    <action>Wait for and receive task number from subagent</action>
    <process>
      1. Poll for completion (max 60s)
      2. Receive return object from atomic-task-numberer
      3. Handle timeout if no response
      4. Handle exceptions if invocation failed
    </process>
    <timeout_handling>
      If timeout (no response after 60s):
        1. Log timeout error with session_id
        2. Return error to user
        3. Recommend retry
    </timeout_handling>
    <validation>
      1. Validate return against subagent-return-format.md
      2. Check session_id matches expected
      3. Validate status is "completed"
      4. Extract task_number from return
    </validation>
  </stage>

  <stage id="5" name="CreateTODOEntry">
    <action>Create formatted TODO.md entry</action>
    <process>
      1. Format task entry:
         ### {number}. {description}
         - **Effort**: {effort}
         - **Status**: [NOT STARTED]
         - **Priority**: {priority}
         - **Language**: {language}
      2. Append to TODO.md
      3. Preserve existing task numbering
    </process>
    <format_example>
      ### 197. Implement LeanSearch REST API integration
      - **Effort**: 4 hours
      - **Status**: [NOT STARTED]
      - **Priority**: High
      - **Language**: lean
    </format_example>
  </stage>

  <stage id="6" name="UpdateState">
    <action>Update state.json with new task</action>
    <process>
      1. Load state.json
      2. Add task entry:
         {
           "task_number": {number},
           "status": "not_started",
           "priority": {priority},
           "language": {language},
           "created": "{YYYY-MM-DD}"
         }
      3. Write state.json atomically
    </process>
    <atomic>
      Use file locking or atomic write to prevent race conditions
    </atomic>
  </stage>

  <stage id="7" name="ReturnSuccess">
    <action>Return task number and summary to user</action>
    <return_format>
      Task {number} created: {description}
      - Priority: {priority}
      - Language: {language}
      - Status: [NOT STARTED]
    </return_format>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 1 (Isolated) - Simple task creation, minimal context needed
  </context_allocation>
  <delegation>
    Single delegation to atomic-task-numberer (depth 1)
    No further delegation from atomic-task-numberer
  </delegation>
</routing_intelligence>

<validation>
  <pre_flight>
    - Description validated (non-empty)
    - Priority validated (valid enum)
    - Language detected or defaulted
  </pre_flight>
  <mid_flight>
    - Task number received and validated
    - Return format validated against standard
    - Session ID matches expected
  </mid_flight>
  <post_flight>
    - TODO.md updated with new task
    - state.json updated atomically
    - Task number returned to user
  </post_flight>
</validation>

<quality_standards>
  <status_markers>
    Use [NOT STARTED] for new tasks per status-markers.md
  </status_markers>
  <language_detection>
    Detect language from description keywords, default to "general"
  </language_detection>
  <no_emojis>
    No emojis in task entries or output
  </no_emojis>
  <atomic_updates>
    state.json updates must be atomic to prevent race conditions
  </atomic_updates>
</quality_standards>

<usage_examples>
  - `/task Implement LeanSearch REST API integration`
  - `/task Add missing directory READMEs --priority High`
  - `/task Fix delegation hang in task-executor --effort 2h`
</usage_examples>

<error_handling>
  <timeout>
    If atomic-task-numberer times out:
      - Log error with session_id
      - Return error to user
      - Recommend retry
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error
      - Return error to user
      - Include details of validation failure
  </validation_failure>
  <state_update_failure>
    If state.json update fails:
      - Rollback TODO.md changes
      - Return error to user
      - Log error for debugging
  </state_update_failure>
</error_handling>
