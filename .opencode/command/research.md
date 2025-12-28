---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`, `/research 172`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/subagent-return-format.md
@.opencode/context/common/workflows/subagent-delegation-guide.md
@.opencode/context/common/system/git-commits.md

<context>
  <system_context>
    Research workflow with language-based routing, artifact creation, and [RESEARCHED]
    status marker. Supports topic subdivision via --divide flag.
  </system_context>
  <domain_context>
    Research for both Lean and general tasks. Lean tasks route to lean-research-agent,
    general tasks route to researcher subagent.
  </domain_context>
  <task_context>
    Conduct research for specified task, create research reports and summaries,
    update task status to [RESEARCHED], and commit artifacts.
  </task_context>
  <execution_context>
    Lazy directory creation (specs/NNN_*/reports/ only when writing). Atomic status
    synchronization via status-sync-manager. Git commit after completion.
  </execution_context>
</context>

<role>Research Command - Conduct research and create reports with status tracking</role>

<task>
  Conduct research for task, create artifacts in lazy-created directories, update
  status to [RESEARCHED] with timestamps, and commit changes.
</task>

<argument_parsing>
  <invocation_format>
    /research TASK_NUMBER [PROMPT]
    
    Examples:
    - /research 197
    - /research 197 "Focus on CLI integration"
  </invocation_format>
  
  <parameters>
    <task_number>
      <position>1</position>
      <type>integer</type>
      <required>true</required>
      <description>The task number from TODO.md to research</description>
      <extraction>Extract first argument after command name as task number</extraction>
      <validation>Must be a valid integer that exists in TODO.md</validation>
    </task_number>
    
    <prompt>
      <position>2</position>
      <type>string</type>
      <required>false</required>
      <description>Optional additional context or focus for research</description>
      <extraction>Extract remaining arguments after task number as prompt string</extraction>
      <default>Use task description from TODO.md</default>
    </prompt>
    
    <flags>
      <divide>
        <flag>--divide</flag>
        <type>boolean</type>
        <required>false</required>
        <description>Subdivide research into multiple topics</description>
        <default>false</default>
      </divide>
    </flags>
  </parameters>
  
  <parsing_logic>
    When user invokes "/research 197 'Focus on CLI'", parse as:
    1. Command: "research"
    2. Arguments: ["197", "Focus on CLI"]
    3. Extracted:
       - task_number = 197
       - prompt = "Focus on CLI"
       - flags = {}
  </parsing_logic>
  
  <error_handling>
    If task_number missing:
      Return: "Error: Task number required. Usage: /research TASK_NUMBER [PROMPT]"
    If task_number not integer:
      Return: "Error: Task number must be an integer. Got: {input}"
    If task not found in TODO.md:
      Return: "Error: Task {task_number} not found in TODO.md"
  </error_handling>
</argument_parsing>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Parse and validate task number, prepare for research</action>
    <process>
      1. Parse task number from $ARGUMENTS (first argument)
      2. Validate task number is an integer
      3. If task number missing or invalid, return error: "Task number required. Usage: /research TASK_NUMBER [PROMPT]"
      4. Extract optional prompt from $ARGUMENTS (remaining text after task number)
      5. Load task from TODO.md
      6. Validate task exists and is not [COMPLETED]
      7. Extract task description and language
      8. Check for --divide flag (topic subdivision)
      9. Mark task [RESEARCHING] with Started timestamp
      10. Update state.json: status = "researching", started = "{YYYY-MM-DD}"
    </process>
    <status_update>
      Atomic update via status-sync-manager:
        - TODO.md: [RESEARCHING], **Started**: {date}
        - state.json: status = "researching", started = "{date}"
    </status_update>
    <validation>
      - Task number must exist in TODO.md
      - Task must not be [COMPLETED] or [ABANDONED]
      - Language field must be present (default to "general")
    </validation>
  </stage>

  <stage id="2" name="CheckLanguage">
    <action>Determine routing based on task language</action>
    <process>
      1. Read Language field from TODO.md task
      2. Determine target agent:
         - Language: lean → lean-research-agent
         - Language: * → researcher (general)
      3. Prepare agent-specific context
    </process>
    <routing>
      Language: lean → lean-research-agent (LeanExplore, Loogle, LeanSearch)
      Language: * → researcher (web search, documentation)
    </routing>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <action>Prepare delegation context for research agent</action>
    <process>
      1. Generate session_id: sess_{timestamp}_{random_6char}
      2. Set delegation_depth = 1 (orchestrator → research → researcher)
      3. Set delegation_path = ["orchestrator", "research", "{agent}"]
      4. Set timeout = 3600s (1 hour for research)
      5. Store session_id for validation
      6. Prepare research context (task description, language, --divide flag)
    </process>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "research", "researcher"],
        "timeout": 3600,
        "task_context": {
          "task_number": {number},
          "description": "{description}",
          "language": "{language}",
          "divide": {true|false}
        }
      }
    </delegation_context>
  </stage>

  <stage id="4" name="InvokeResearcher">
    <action>Invoke appropriate research agent</action>
    <process>
      1. Route to selected agent (researcher or lean-research-agent)
      2. Pass delegation context
      3. Pass task description and research topic
      4. Pass --divide flag if present
      5. Set timeout to 3600s
    </process>
    <invocation>
      task_tool(
        subagent_type="{researcher|lean-research-agent}",
        prompt="Research topic: {description}",
        session_id=delegation_context["session_id"],
        delegation_depth=1,
        delegation_path=delegation_context["delegation_path"],
        timeout=3600,
        divide=divide_flag
      )
    </invocation>
  </stage>

  <stage id="5" name="ReceiveResults">
    <action>Wait for and receive research results</action>
    <process>
      1. Poll for completion (max 3600s)
      2. Receive return object from research agent
      3. Validate against subagent-return-format.md
      4. Check session_id matches expected
      5. Handle timeout gracefully
    </process>
    <timeout_handling>
      If timeout (no response after 3600s):
        1. Log timeout error with session_id
        2. Check for partial artifacts on disk
        3. Return partial status with artifacts found
        4. Keep task [RESEARCHING] (not failed)
        5. Message: "Research timed out after 1 hour. Partial results available. Resume with /research {number}"
    </timeout_handling>
    <validation>
      1. Validate return is valid JSON
      2. Validate against subagent-return-format.md schema
      3. Check session_id matches
      4. Validate status is valid enum (completed|partial|failed|blocked)
      5. Validate artifacts array structure
      6. Check all artifact paths exist
    </validation>
  </stage>

  <stage id="6" name="ProcessResults">
    <action>Extract artifacts and summary from validated return</action>
    <process>
      1. Extract status from return (completed|partial|failed|blocked)
      2. Extract research report paths from artifacts array
      3. Extract summary for TODO.md
      4. Extract errors if status != completed
      5. Determine next action based on status
    </process>
    <status_handling>
      If status == "completed":
        - All research finished successfully
        - Proceed to postflight with artifacts
      If status == "partial":
        - Some research completed
        - Keep task [RESEARCHING]
        - Save partial results
        - Provide resume instructions
      If status == "failed":
        - No usable results
        - Handle errors
        - Provide recovery steps
      If status == "blocked":
        - Mark task [BLOCKED]
        - Cannot proceed
        - Identify blocker
        - Request user intervention
    </status_handling>
  </stage>

  <stage id="7" name="Postflight">
    <action>Update status, link artifacts, and commit</action>
    <process>
      1. If status == "completed":
         a. Update TODO.md:
            - Add research report links
            - Change status to [RESEARCHED]
            - Add Completed timestamp
         b. Update state.json:
            - status = "researched"
            - completed = "{YYYY-MM-DD}"
            - artifacts = [research report paths]
         c. Git commit:
            - Scope: Research artifacts + TODO.md + state.json
            - Message: "task {number}: research completed"
       2. If status == "partial":
          a. Keep TODO.md status [RESEARCHING]
          b. Add partial artifact links
          c. Git commit partial results:
             - Scope: Partial artifacts only
             - Message: "task {number}: partial research results"
       3. If status == "failed":
          a. Keep TODO.md status [RESEARCHING]
          b. Add error notes to TODO.md
          c. No git commit
       4. If status == "blocked":
          a. Update TODO.md status to [BLOCKED]
          b. Add blocking reason to TODO.md
          c. Update state.json: status = "blocked", blocked = "{date}"
          d. No git commit
    </process>
    <atomic_update>
      Use status-sync-manager to atomically:
        - Update TODO.md: Add research report links
        - Update TODO.md: Change status to [RESEARCHED]
        - Update TODO.md: Add Completed timestamp
        - Update state.json: status = "researched"
        - Update state.json: completed timestamp
        - Update state.json: artifacts array
    </atomic_update>
    <git_commit>
      Scope: Research artifacts + TODO.md + state.json
      Message: "task {number}: research completed"
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <action>Return summary to user</action>
    <return_format>
      Research completed for task {number}
      - Status: [RESEARCHED]
      - Artifacts: {list of research report paths}
      - Summary: {brief summary from research agent}
      
      Or if partial:
      Research partially completed for task {number}
      - Status: [IN PROGRESS]
      - Partial artifacts: {list}
      - Resume with: /research {number}
    </return_format>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>
    Level 2 (Filtered) - Research requires project context based on language
  </context_allocation>
  <lean_routing>
    If Language: lean → lean-research-agent
    - Load .opencode/context/project/lean4/
    - Use LeanExplore, Loogle, LeanSearch (when available)
    - Fallback to web search if tools unavailable
  </lean_routing>
  <general_routing>
    If Language: * → researcher
    - Load .opencode/context/project/repo/
    - Use web search and documentation review
  </general_routing>
</routing_intelligence>

<artifact_management>
  <lazy_creation>
    Do not create specs/NNN_*/ until writing research artifacts
    Create only reports/ subdirectory when writing research-001.md
    Create summaries/ only if summary file needed
  </lazy_creation>
  <artifact_naming>
    Research reports: specs/NNN_{task_slug}/reports/research-001.md
    Research summaries: specs/NNN_{task_slug}/summaries/research-summary.md
  </artifact_naming>
  <state_sync>
    Update state.json with artifact paths when research completes
    Sync TODO.md with research report links
  </state_sync>
</artifact_management>

<quality_standards>
  <status_markers>
    Use [IN PROGRESS] at start, [RESEARCHED] at completion per status-markers.md
    Include Started and Completed timestamps
  </status_markers>
  <language_routing>
    Route based on TODO.md Language field
    Validate lean-lsp-mcp availability for Lean tasks
  </language_routing>
  <no_emojis>
    No emojis in research reports, summaries, or status updates
  </no_emojis>
  <atomic_updates>
    Use status-sync-manager for atomic multi-file updates
  </atomic_updates>
</quality_standards>

<usage_examples>
  - `/research 195` (research task 195)
  - `/research 195 --divide` (subdivide research into topics)
</usage_examples>

<validation>
  <pre_flight>
    - Task exists in TODO.md
    - Task not [COMPLETED] or [ABANDONED]
    - Language field present
    - Status set to [IN PROGRESS] with Started timestamp
  </pre_flight>
  <mid_flight>
    - Research agent invoked with correct routing
    - Return validated against subagent-return-format.md
    - Session ID matches expected
    - Artifacts exist on disk
  </mid_flight>
  <post_flight>
    - Status updated to [RESEARCHED] (if completed)
    - Artifacts linked in TODO.md
    - state.json synchronized
    - Git commit created (if completed)
  </post_flight>
</validation>

<error_handling>
  <timeout>
    If research times out after 3600s:
      - Check for partial artifacts
      - Return partial status
      - Keep task [IN PROGRESS]
      - Provide resume instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error with details
      - Return failed status
      - Keep task [IN PROGRESS]
      - Recommend subagent fix
  </validation_failure>
  <tool_unavailable>
    If lean-lsp-mcp or Lean tools unavailable:
      - Log tool unavailability
      - Fallback to web search
      - Continue with degraded mode
      - Note tool unavailability in research report
  </tool_unavailable>
  <git_commit_failure>
    If git commit fails:
      - Log error to errors.json
      - Continue (commit failure non-critical)
      - Return success with warning
  </git_commit_failure>
</error_handling>
