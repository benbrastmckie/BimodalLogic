---
name: {command}
agent: {primary_agent}
description: "{one-line purpose}"
context_level: {1|2|3}
language: {markdown|lean|shell|json|...}
---

Context Loaded:
@.opencode/specs/TODO.md (if task-bound)
@.opencode/specs/state.json
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/commands.md
@.opencode/context/project/{logic|lean4|repo}/project-overview.md (as needed)

<context>
  <system_context>{system scope and guarantees}</system_context>
  <domain_context>{domain or repo scope}</domain_context>
  <task_context>{command mission}</task_context>
  <execution_context>{operational constraints: lazy creation, status sync, language routing}</execution_context>
</context>

<role>{Primary command role and specialization}</role>

<task>{Single-sentence objective including status marker expectations and lazy-creation guardrails}</task>

<argument_parsing>
  <invocation_format>
    /{command} PARAM1 [PARAM2] [--flag]
    
    Examples:
    - /{command} {example_arg1}
    - /{command} {example_arg1} {example_arg2}
  </invocation_format>
  
  <parameters>
    <param_name>
      <position>{1|2|3...}</position>
      <type>{integer|string|boolean|range}</type>
      <required>{true|false}</required>
      <description>{What this parameter represents}</description>
      <extraction>{How to extract from user input}</extraction>
      <validation>{Validation rules}</validation>
      <default>{Default value if not provided}</default>
    </param_name>
    
    <!-- Add more parameters as needed -->
    
    <flags>
      <flag_name>
        <flag>{--flag-name}</flag>
        <type>boolean</type>
        <required>false</required>
        <description>{What this flag does}</description>
        <default>false</default>
      </flag_name>
    </flags>
  </parameters>
  
  <parsing_logic>
    When user invokes "/{command} {example_invocation}", parse as:
    1. Command: "{command}"
    2. Arguments: ["{arg1}", "{arg2}", ...]
    3. Extracted:
       - param1 = {value1}
       - param2 = {value2}
       - flags = {flag_map}
  </parsing_logic>
  
  <error_handling>
    If {condition}:
      Return: "Error: {message}. Usage: /{command} {usage_pattern}"
  </error_handling>
</argument_parsing>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate inputs and set status markers</action>
    <process>
      1. Parse arguments from input (see <argument_parsing> above)
      2. Load TODO entry (if applicable); set task to [IN PROGRESS] and add **Started** date.
      3. If a plan link exists, set plan status to [IN PROGRESS] with (Started: ISO8601_timestamp).
      4. Sync state.json status to `in_progress` with started_at; no directories created.
    </process>
  </stage>
  <stage id="2" name="Execution">
    <action>Route to primary agent/subagents</action>
    <process>
      1. Select agent path (Lean vs non-Lean using TODO Language or --lang).
      2. Allocate context level (1/2/3) per command scope.
      3. Execute command-specific actions; create artifacts only when writing outputs; create only required subdir.
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Sync artifacts, TODO, and state</action>
    <process>
      1. Update plan phases/status markers with timestamps (if plan used).
      2. Emit or update summaries under summaries/implementation-summary-YYYYMMDD.md when artifacts are produced.
      3. Sync .opencode/specs/TODO.md and state.json with status + timestamps + artifact links; update registries if impacted.
      4. Return concise summary and artifact references.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level {1|2|3} rationale; escalate when multiple files or multi-phase workflows.</context_allocation>
  <lean_routing>Use TODO `Language: lean` or `--lang lean`; validate lean-lsp MCP; abort gracefully if missing.</lean_routing>
  <batch_handling>{If applicable: wave execution via batch-task-orchestrator/batch-status-manager}</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Do not create project roots/subdirs until writing an artifact; create only needed subdir.</lazy_creation>
  <artifact_naming>{reports/research-NNN.md | plans/implementation-NNN.md | summaries/{type}-summary-YYYYMMDD.md}</artifact_naming>
  <state_sync>Update project state.json with phase/status when artifacts are created; sync global state/TODO links.</state_sync>
  <registry_sync>When command mutates implementation status or sorry/tactic counts, update IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, and TACTIC_REGISTRY.md (skip on dry-run).</registry_sync>
</artifact_management>

<quality_standards>
  <status_markers>Use markers from status-markers.md with timestamps; preserve history.</status_markers>
  <language_routing>Lean intent from TODO Language or --lang; plan lean: is secondary.</language_routing>
  <no_emojis>Outputs and artifacts must be emoji-free.</no_emojis>
  <validation>Reject invalid inputs and directory creation without artifacts.</validation>
</quality_standards>

<usage_examples>
  - `/{command} {example}`
  - `/{command} --lang lean {example_if_applicable}`
</usage_examples>

<validation>
  <pre_flight>Arguments validated; TODO/plan status set to [IN PROGRESS]; state synced.</pre_flight>
  <mid_flight>Agent routing correct; artifacts only when writing; lazy creation honored.</mid_flight>
  <post_flight>Status markers/timestamps synced; artifacts linked; registries updated when required.</post_flight>
</validation>
