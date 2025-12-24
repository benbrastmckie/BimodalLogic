---
name: research
agent: orchestrator
description: "Create research reports for TODO task(s) and sync artifacts (supports single, ranges, and lists)"
context_level: 2
language: markdown
subagents:
  - researcher
  - batch-task-orchestrator
  - batch-status-manager
  - status-sync-manager
mcp_requirements:
  - "lean-lsp (Lean research only)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
creates_root_on: "When writing the first research report"
creates_subdir:
  - reports
input_format: "Required: task number(s) - single (e.g., /research 160), range (e.g., /research 132-135), or list (e.g., /research 132,133,134). Reject missing/non-numeric inputs. Error message (no emojis): 'Error: Task number(s) required and must be numeric (e.g., /research 160 or /research 132-135).'"
---

**Task Input (required):** $ARGUMENTS (task number(s); ranges/lists allowed, e.g., `/research 160`, `/research 132-135`, `/research 132,133,134`)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/common/standards/tasks.md
@context/common/standards/commands.md
@context/common/standards/patterns.md
@context/common/workflows/task-breakdown.md

<context>
  <system_context>Research command producing reports and linking them to tasks.</system_context>
  <domain_context>TODO tasks and project specs directories.</domain_context>
  <task_context>Conduct research for a specified task, produce reports, and sync TODO/state.</task_context>
  <execution_context>Lazy creation: create project root and reports/ only when writing the first research artifact.</execution_context>
</context>

<role>Research orchestrator coordinating researcher specialists.</role>

<task>Given a task number and optional prompt, generate research report(s), update TODO/state, and maintain status markers.</task>

<workflow_execution>
  <stage id="1" name="ParseInput">
    <action>Validate task numbers</action>
    <process>
      1. Support single numbers, comma-separated lists, and ranges (e.g., `160`, `132,133`, `132-135`). Detect range/list invocations first, normalize to an ordered, de-duplicated task list, and preserve numeric-only validation.
      2. Validate positive integers; deduplicate expanded lists; fail clearly on invalid formats and return bad inputs.
      3. If more than one normalized task remains, classify as batch and route to batch-task-orchestrator; otherwise continue with single-task flow.
    </process>
  </stage>
  <stage id="2" name="ResolveTasks">
    <action>Load TODO entries and detect Lean intent</action>
    <process>
      1. Locate each task in TODO.md; if missing, report and continue.
      2. Detect Lean via TODO `Language` (authoritative) or `--lang`; if Lean, MCP ping `lean-lsp` before proceeding.
      3. Pre-flight: use @subagents/specialists/status-sync-manager to atomically set TODO status to [IN PROGRESS] with **Started** date and state to `in_progress`. No dirs created.
    </process>
  </stage>
  <stage id="3" name="Research">
    <action>Route to researcher(s)</action>
    <process>
      1. Single task: route to @subagents/researcher directly.
      2. Multiple tasks: route via @subagents/batch-task-orchestrator with researcher subagent for each task; batch handoff includes normalized task list, language metadata per task, and dependency hints.
      3. For each task: derive slug and plan project root; create root + reports/ only when writing artifacts (lazy creation).
      4. Produce `reports/research-XXX.md` (incremental) following report standard for each task.
      5. Capture artifact paths and brief findings summary per task.
    </process>
  </stage>
  <stage id="4" name="Postflight">
    <action>Sync and summarize</action>
    <process>
      1. Use @subagents/specialists/status-sync-manager to atomically mark TODO, state.json, and project state.json to [RESEARCHED] status with **Completed** date for each task; add research link to TODO and brief summary; preserve metadata.
      2. Update project state (reports array, phase/status `researched`, timestamps) without creating extra subdirs when artifacts were written.
      3. Return artifact references and next steps for all tasks.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (task-scoped research using standards + task metadata).</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; load Lean/logic contexts only when Lean.</lean_routing>
  <batch_handling>Use batch-task-orchestrator + batch-status-manager for multi-task inputs; ensure atomic status updates per task; route each task to researcher subagent.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project root/reports/ only when writing research artifacts; no other subdirs.</lazy_creation>
  <artifact_naming>reports/research-XXX.md (incremental).</artifact_naming>
  <state_sync>Update project/global state with report paths and timestamps; link in TODO.</state_sync>
  <registry_sync>Registries unchanged unless research updates implementation status.</registry_sync>
  <git_commits>After research artifacts and state/TODO links are written, use git-commits.md + git-workflow-manager to stage only related files; avoid blanket commits.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md; include timestamps for transitions.</status_markers>
  <language_routing>Respect Language metadata/flags.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Fail clearly on missing task; avoid directory creation without artifacts.</validation>
</quality_standards>

<usage_examples>
  - `/research 161 "Investigate parser regression"`
  - `/research 129 --lang lean "Temporal swap strategy"`
  - `/research 132-135` (batch research for tasks 132, 133, 134, 135)
  - `/research 132,134,136` (batch research for specific tasks)
</usage_examples>

<validation>
  <pre_flight>Task resolved; statuses set.</pre_flight>
  <mid_flight>Researcher produced artifacts with lazy creation.</mid_flight>
  <post_flight>TODO/state linked; references returned.</post_flight>
</validation>
