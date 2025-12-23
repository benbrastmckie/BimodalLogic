---
name: todo
agent: orchestrator
 description: "Cleanup and archival lifecycle owner: remove completed/abandoned tasks, migrate state to archive, clear orphan/stale entries, sync status docs without creating new project directories"
 context_level: 2
 language: markdown
 subagents:
   - reviewer (todo-maintenance)
   - batch-status-manager
 mcp_requirements: []
 registry_impacts:
   - TODO.md
   - .opencode/specs/state.json
   - .opencode/specs/archive/state.json
   - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
   - Documentation/ProjectInfo/FEATURE_REGISTRY.md
 creates_root_on: never
 creates_subdir: []
 dry_run: "Report-only: analyze and preview moves; no dirs/status/registry writes and no archive moves."

---

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/specs/archive/state.json
@context/common/standards/tasks.md
@context/common/standards/commands.md
@context/common/system/artifact-management.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/project/repo/project-overview.md
@Documentation/ProjectInfo/FEATURE_REGISTRY.md
@Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md

<context>
  <system_context>TODO maintenance and archival with numbering guardrails.</system_context>
  <domain_context>Active specs, archive, and status docs.</domain_context>
  <task_context>Remove completed/abandoned tasks, migrate state/archive entries, and clean orphan/stale items without creating new project dirs.</task_context>
  <execution_context>Dry-run/report mode available; never create new project roots; only move existing.</execution_context>
</context>

<role>Maintenance orchestrator for TODO/state/archive synchronization.</role>

<task>Normalize TODO/status markers, migrate completed/abandoned tasks to archive, handle orphan/stale entries, and update status docs while leaving numbering unchanged.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Set scope and confirm guardrails</action>
    <process>
      1. Parse `$ARGUMENTS` for dry-run/report-only flags.
      2. Load TODO/state/archive; ensure `next_project_number` remains untouched.
      3. Confirm no new project directories will be created.
    </process>
  </stage>
  <stage id="2" name="Analyze">
    <action>Route to @subagents/reviewer (todo-maintenance)</action>
    <process>
      1. Normalize status markers; validate task IDs vs state.json.
      2. Detect completed and [ABANDONED] tasks; require confirmation when >5 combined before removal.
      3. Identify orphan specs directories and stale state entries.
    </process>
  </stage>
  <stage id="3" name="Migrate">
    <action>Perform cleanup/archival</action>
    <process>
      1. Remove completed/abandoned tasks from TODO; migrate active/pending → completed in state.json; move to archive/state with required metadata; move existing project dirs to archive/ (no new dirs).
      2. Handle orphan/stale entries (warn, migrate, do not delete contents).
    </process>
  </stage>
  <stage id="4" name="Postflight">
    <action>Sync docs and summarize</action>
    <process>
      1. Update FEATURE_REGISTRY.md and IMPLEMENTATION_STATUS.md with maintenance outcomes.
      2. Refresh `_last_updated` fields; ensure JSON validity.
      3. Return summary of operations, warnings, and next steps.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (state/TODO/archive coordination).</context_allocation>
  <lean_routing>Language metadata irrelevant; no Lean routing.</lean_routing>
  <batch_handling>Reviewer handles batch cleanup with confirmation gates.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>No new project roots/subdirs may be created; only move existing directories to archive when archiving.</lazy_creation>
  <artifact_naming>Archive paths `.opencode/specs/archive/NNN_project_name/` reused; no new artifacts unless reviewer emits report.</artifact_naming>
  <state_sync>State/TODO/archive kept consistent; `next_project_number` unchanged.</state_sync>
  <registry_sync>Update status docs; registries (SORRY/Tactic) unchanged unless reviewer specifies.</registry_sync>
</artifact_management>

<quality_standards>
  <status_markers>Apply status-markers.md; handle [COMPLETED]/[ABANDONED]/[BLOCKED].</status_markers>
  <language_routing>Not applicable; keep metadata intact.</language_routing>
  <no_emojis>No emojis.</no_emojis>
  <validation>Require confirmation when >5 removals; reject directory creation; ensure JSON validity.</validation>
</quality_standards>

<usage_examples>
  - `/todo`
  - `/todo --dry-run`
</usage_examples>

<validation>
  <pre_flight>Guardrails confirmed; dry-run respected.</pre_flight>
  <mid_flight>Reviewer executed maintenance; no new dirs created.</mid_flight>
  <post_flight>TODO/state/archive/status docs synced; summary returned.</post_flight>
</validation>
