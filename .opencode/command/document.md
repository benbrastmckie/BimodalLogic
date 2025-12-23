---
name: document
agent: orchestrator
description: "Update documentation to be complete, accurate, and concise"
context_level: 2
language: markdown
subagents:
  - doc-analyzer
  - doc-writer
  - documentation-generator (optional)
mcp_requirements: []
registry_impacts:
  - TODO.md (task-bound)
  - .opencode/specs/state.json (task-bound)
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (when doc status changes are recorded)
creates_root_on: "Only when writing documentation summaries"
creates_subdir:
  - summaries
dry_run: "Scope/analysis preview only; no dirs/artifacts/status/registry writes."
---

Context Loaded:
@context/common/standards/documentation.md
@context/common/standards/commands.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/project/repo/project-overview.md

<context>
  <system_context>Documentation maintenance with completeness, accuracy, and concision requirements.</system_context>
  <domain_context>ProofChecker documentation tree and standards.</domain_context>
  <task_context>Analyze gaps, update docs, remove bloat, and summarize changes.</task_context>
  <execution_context>Route to documenter specialists; create artifacts only when writing updates; sync TODO/state if task-bound.</execution_context>
</context>

<role>Documentation orchestrator ensuring standards-compliant updates.</role>

<task>Update documentation for the provided scope `$ARGUMENTS`, following documentation standards and lazy creation rules.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate scope and load standards</action>
    <process>
      1. Parse scope string/paths.
      2. Confirm documentation standards are loaded; set task status to [IN PROGRESS] if invoked via /task.
    </process>
  </stage>
  <stage id="2" name="ExecuteDocumentation">
    <action>Route to @subagents/documenter</action>
    <process>
      1. Run doc-analyzer to find gaps/outdated sections.
      2. Run doc-writer to update docs; remove bloat; ensure accuracy and cross-links.
      3. Produce summary of changes.
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Summarize and sync</action>
    <process>
      1. Record updated files and any new summaries.
      2. Sync TODO/state if task-bound; ensure status markers/timestamps updated.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (multi-file documentation updates requiring standards + project overview).</context_allocation>
  <lean_routing>Non-Lean unless scope explicitly requires Lean code docs; load Lean contexts only when needed.</lean_routing>
  <batch_handling>Handle multiple files within single documenter run.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project roots/subdirs only if new summaries/reports are written; otherwise modify existing docs in-place.</lazy_creation>
  <artifact_naming>Documentation summaries go under summaries/{type}-summary-YYYYMMDD.md when produced.</artifact_naming>
  <state_sync>Update project/global state when artifacts are created; link summaries in TODO/state.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md if documentation impacts task status; registries unchanged otherwise.</registry_sync>
  <git_commits>After documentation updates and status syncs, use git-commits.md + git-workflow-manager to stage only doc-related files; avoid blanket commits.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md when task-bound; add **Started**/**Completed** dates.</status_markers>
  <language_routing>Language remains markdown unless Lean docs require Lean context.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Verify links/paths; reject edits that violate lazy creation.</validation>
</quality_standards>

<usage_examples>
  - `/document "Update ProofSearch docs"`
  - `/document "Refresh README and Architecture sections"`
</usage_examples>

<validation>
  <pre_flight>Scope parsed; standards loaded.</pre_flight>
  <mid_flight>Documenter executed; only necessary files touched.</mid_flight>
  <post_flight>Summaries and state/TODO (if task-bound) updated.</post_flight>
</validation>
