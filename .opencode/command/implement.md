---
name: implement
agent: orchestrator
description: "Execute implementation plans with phase tracking"
context_level: 2
language: markdown
subagents:
  - implementation-orchestrator
  - implementer specialists (per phase)
mcp_requirements: []
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
  - SORRY_REGISTRY.md (when sorry counts change)
  - TACTIC_REGISTRY.md (when tactic counts change)
creates_root_on: "Only when writing implementation artifacts via phases"
creates_subdir:
  - summaries
dry_run: "Validate plan path and routing; no dirs, no status/registry/state writes, no artifacts."
---

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/common/standards/commands.md
@context/common/standards/code.md
@context/common/standards/patterns.md
@context/common/workflows/task-breakdown.md
@context/common/system/artifact-management.md
@context/common/system/status-markers.md

<context>
  <system_context>Implementation execution driven by existing plan artifacts.</system_context>
  <domain_context>Project codebase and associated implementation plans.</domain_context>
  <task_context>Consume a provided implementation plan path, execute remaining phases, and sync plan/TODO/state with status markers.</task_context>
  <execution_context>Lazy directory creation; plan path required; Lean routing via plan metadata/TODO Language when applicable.</execution_context>
</context>

<role>Implementation orchestrator coordinating phase execution via implementer subagents.</role>

<task>Given a plan path (and optional starting phase), execute phases in order, update plan markers with timestamps, produce implementation summaries, and sync TODO/state.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate inputs and set statuses</action>
    <process>
      1. Parse `$ARGUMENTS` to extract plan path (required) and optional starting phase.
      2. Fail fast if plan path missing/invalid (no dirs created).
      3. If invoked via /task, set TODO task to [IN PROGRESS] with **Started** date and set plan header to [IN PROGRESS] (Started: ISO8601).
      4. Set state.json entry to `in_progress` with started_at.
    </process>
  </stage>
  <stage id="2" name="ExecutePhases">
    <action>Route to @subagents/implementation-orchestrator core</action>
    <process>
      1. Load plan, parse phases/dependencies; skip completed.
      2. Execute phases (parallel when safe) via implementer subagents; obey lazy creation (create only needed subdir when writing artifacts).
      3. Update plan with status markers/timestamps per phase; record artifacts.
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Sync and summarize</action>
    <process>
      1. Write or update implementation summary under `summaries/implementation-summary-YYYYMMDD.md` when artifacts produced.
      2. Sync TODO/state with status, timestamps, artifact links; update registries if implementation status changes.
      3. Return concise summary of phases completed, files modified, and next steps.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (plan-driven, multi-file updates).</context_allocation>
  <lean_routing>Lean intent inferred from TODO `Language` or explicit `--lang`; plan `lean:` is secondary. Validate `lean-lsp` MCP before Lean execution.</lean_routing>
  <batch_handling>Phase execution may run in waves; ensure atomic status updates per phase.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project roots/subdirs only when writing artifacts (plans/reports/summaries); no pre-creation.</lazy_creation>
  <artifact_naming>Implementation summaries: `summaries/implementation-summary-YYYYMMDD.md`; plan versions remain unchanged unless revised.</artifact_naming>
  <state_sync>Update project state.json alongside artifacts; update global state/TODO links.</state_sync>
  <registry_sync>When implementation status changes, update IMPLEMENTATION_STATUS.md and related registries; skip on dry-run.</registry_sync>
  <git_commits>After artifacts and status updates, use git-commits.md + git-workflow-manager to stage only implementation-related files and commit with scoped messages; avoid repo-wide adds.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Apply status-markers.md to plan phases and TODO entries with timestamps.</status_markers>
  <language_routing>Respect Language metadata/flags for Lean vs non-Lean paths.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Reject missing plan path; avoid directory creation without artifacts.</validation>
</quality_standards>

<usage_examples>
  - `/implement .opencode/specs/128_foo/plans/implementation-001.md`
  - `/implement .opencode/specs/128_foo/plans/implementation-001.md 3`
</usage_examples>

<validation>
  <pre_flight>Plan path validated; statuses set to [IN PROGRESS] when applicable.</pre_flight>
  <mid_flight>Phases executed with lazy creation; plan markers updated.</mid_flight>
  <post_flight>Summaries/artifacts linked; TODO/state/registries synced.</post_flight>
</validation>
