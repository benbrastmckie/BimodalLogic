---
name: research
agent: orchestrator
description: "Conduct research and create reports with [RESEARCHED] status"
context_level: 2
language: markdown
---

**Task Input (required):** $ARGUMENTS (task number; e.g., `/research 197`, `/research 172`)

Context Loaded:
@.opencode/context/common/workflows/command-lifecycle.md
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
  Follow command-lifecycle.md 8-stage pattern with these variations:
  
  <stage id="1" name="Preflight">
    <status_transition>
      Initial: [NOT STARTED]
      In-Progress: [RESEARCHING]
    </status_transition>
    <validation>
      - Task number must exist in TODO.md
      - Task must not be [COMPLETED] or [ABANDONED]
      - Language field must be present (default to "general")
      - Check for --divide flag (topic subdivision)
    </validation>
    <status_update>
      Atomic update via status-sync-manager:
        - TODO.md: [RESEARCHING], **Started**: {date}
        - state.json: status = "researching", started = "{date}"
    </status_update>
  </stage>

  <stage id="2" name="CheckLanguage">
    <critical_importance>
      CRITICAL: This stage MUST extract the Language field and determine routing.
      DO NOT skip this stage. DO NOT assume language without extraction.
      Incorrect routing bypasses Lean-specific tooling (lean-lsp-mcp, Loogle).
    </critical_importance>
    <language_extraction>
      Extract Language field from TODO.md task using explicit bash command:
      ```bash
      grep -A 20 "^### ${task_number}\." TODO.md | grep "Language" | sed 's/\*\*Language\*\*: //'
      ```
      Validate extraction succeeded (non-empty result)
      If extraction fails: default to "general" and log warning
      Log extracted language: "Task ${task_number} language: ${language}"
    </language_extraction>
    <routing>
      Language: lean → lean-research-agent (LeanExplore, Loogle, LeanSearch)
      Language: * → researcher (web search, documentation)
    </routing>
    <validation>
      MUST complete before Stage 3:
      - Language field extracted and logged
      - Routing decision made and logged
      - Target agent determined (lean-research-agent or researcher)
      - Agent matches language (lean → lean-research-agent, else → researcher)
    </validation>
    <pre_invocation_check>
      Before invoking agent in Stage 4, verify:
      - Language was extracted in Stage 2
      - Routing decision was logged in Stage 2
      - Selected agent matches language:
        * If language == "lean" AND agent != "lean-research-agent" → ABORT with error
        * If language != "lean" AND agent == "lean-research-agent" → ABORT with error
      If validation fails: Return error "Routing validation failed: language=${language}, agent=${agent}"
    </pre_invocation_check>
  </stage>

  <stage id="3" name="PrepareDelegation">
    <timeout>3600s (1 hour)</timeout>
    <delegation_context>
      {
        "session_id": "sess_{timestamp}_{random}",
        "delegation_depth": 1,
        "delegation_path": ["orchestrator", "research", "{agent}"],
        "timeout": 3600,
        "task_context": {
          "task_number": {number},
          "description": "{description}",
          "language": "{language}",
          "divide": {true|false}
        }
      }
    </delegation_context>
    <special_context>
      divide_topics: boolean (from --divide flag)
    </special_context>
  </stage>

  <!-- Stages 4-6: Follow command-lifecycle.md (no variations) -->

  <stage id="7" name="Postflight">
    <status_transition>
      Completion: [RESEARCHED] + **Completed**: {date}
      Partial: Keep [RESEARCHING]
      Failed: Keep [RESEARCHING]
      Blocked: [BLOCKED]
    </status_transition>
    <validation_delegation>
      Verify researcher returned validation success:
        - Check researcher return metadata for validation_result
        - Verify all artifacts validated (exist, non-empty, token limit)
        - If validation failed: Abort update, return error to user
    </validation_delegation>
    <git_commit>
      Scope: Research artifacts + TODO.md + state.json + project state.json
      Message: "task {number}: research completed"
      
      Commit only if status == "completed"
      Use git-workflow-manager for scoped commit
    </git_commit>
    <atomic_update>
      Delegate to status-sync-manager:
        - task_number: {number}
        - new_status: "researched"
        - timestamp: {ISO8601 date}
        - session_id: {session_id}
        - validated_artifacts: {artifacts from researcher return}
      
      status-sync-manager performs two-phase commit:
        - Phase 1: Prepare, validate artifacts, backup
        - Phase 2: Write all files or rollback all
      
      Atomicity guaranteed across:
        - TODO.md (status, timestamps, artifact links)
        - state.json (status, timestamps, artifacts array)
        - project state.json (lazy created if needed)
    </atomic_update>
  </stage>

  <stage id="8" name="ReturnSuccess">
    <return_format>
      Research completed for task {number}
      
      {brief_summary from research agent (3-5 sentences)}
      
      Artifacts created:
      - Research Report: {report_path}
      - Research Summary: {summary_path}
      
      Task marked [RESEARCHED].
      
      ---
      
      Or if partial:
      Research partially completed for task {number}
      
      {brief_summary from research agent}
      
      Partial artifacts: {list}
      
      Resume with: /research {number}
    </return_format>
    <context_window_protection>
      CRITICAL: Return only brief summary (3-5 sentences) and artifact paths.
      DO NOT include full research report content.
      Full content is in artifact files for user to review separately.
      This protects orchestrator context window from bloat.
    </context_window_protection>
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
    Use [RESEARCHING] at start, [RESEARCHED] at completion per status-markers.md
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

<error_handling>
  Follow command-lifecycle.md error handling patterns:
  
  <timeout>
    If research times out after 3600s:
      - Check for partial artifacts
      - Return partial status
      - Keep task [RESEARCHING]
      - Provide resume instructions
  </timeout>
  <validation_failure>
    If return validation fails:
      - Log validation error with details
      - Return failed status
      - Keep task [RESEARCHING]
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
