---
name: research
agent: orchestrator
description: "Create research reports for a TODO task and sync artifacts"
context_level: 2
language: markdown
subagents:
  - researcher
mcp_requirements:
  - "lean-lsp (Lean research only)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
creates_root_on: "When writing the first research report"
creates_subdir:
  - reports
dry_run: "Validate task + Lean intent, MCP ping if Lean; no dirs/status/registry writes, no artifacts."
---

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
  <stage id="1" name="Preflight">
    <action>Validate task and set status</action>
    <process>
      1. Parse task number and optional prompt; fail if missing from TODO.md.
      2. Set TODO to [IN PROGRESS] with **Started** date; state to `in_progress` before routing.
      3. Detect Lean intent via TODO `Language`/`--lang` to decide whether to load Lean contexts for research.
    </process>
  </stage>
  <stage id="2" name="Research">
    <action>Route to @subagents/researcher</action>
    <process>
      1. Derive slug and plan project root; create root + reports/ only when writing artifacts (lazy creation).
      2. Produce `reports/research-XXX.md` (incremental) following report standard.
      3. Capture artifact paths and brief findings summary.
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Sync and summarize</action>
    <process>
      1. Mark TODO and state to `[RESEARCHED]` with **Completed** date; add research link and brief summary; preserve metadata.
      2. Update project state (reports array, phase/status `researched`, timestamps) without creating extra subdirs.
      3. Return artifact references and next steps.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (task-scoped research using standards + task metadata).</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; load Lean/logic contexts only when Lean.</lean_routing>
  <batch_handling>Single task per invocation; batch via /task + researcher subagents.</batch_handling>
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
  - `/research 105 "Survey FastAPI auth best practices"`
  - `/research 129 --lang lean "Temporal swap strategy"`
</usage_examples>

<validation>
  <pre_flight>Task resolved; statuses set.</pre_flight>
  <mid_flight>Researcher produced artifacts with lazy creation.</mid_flight>
  <post_flight>TODO/state linked; references returned.</post_flight>
</validation>
