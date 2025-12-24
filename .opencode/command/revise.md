---
name: revise
agent: orchestrator
description: "Create revised implementation plan with incremented version number"
context_level: 2
language: markdown
subagents:
  - planner
mcp_requirements:
  - "lean-lsp (when revising Lean tasks)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
creates_root_on: never (reuses existing plans/)
creates_subdir:
  - plans
dry_run: "Routing-check only: validate task/plan link and Lean intent; no dirs/artifacts/status/registry/state writes."
input_format: 'Required: single numeric task ID plus optional revision prompt (e.g., /revise 162 "Remove dry-run references"); reject ranges/lists/non-numeric inputs with error: Error: Task number is required and must be numeric (e.g., /revise 162 "Update plan scaffold"). If prompt is missing, error: Error: Revision prompt is required (e.g., /revise 162 "Add summary artifact parity checklist").'
---

**Task Input (required):** $ARGUMENTS (single numeric task ID; optional revision prompt; e.g., `/revise 162 "Remove dry-run references"`; no ranges or lists.)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/common/standards/tasks.md
@context/common/standards/commands.md
@context/common/system/artifact-management.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/project/repo/project-overview.md

<context>
  <system_context>Plan revision command with strict reuse of existing plan links and lazy creation.</system_context>
  <domain_context>Existing project plans referenced from TODO.</domain_context>
  <task_context>Create the next plan version in-place, update links/state, and preserve numbering.</task_context>
  <execution_context>No new project directories; work only within existing plan folder.</execution_context>
</context>

<role>Planner handling plan versioning and synchronization.</role>

<task>Given a task number and revision prompt, create implementation-{N+1}.md alongside existing plans, update TODO/state, and record status markers.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate task and plan link</action>
    <process>
      1. Parse single numeric task_number and capture the remaining arguments as the revision prompt; reject ranges/lists/non-numeric inputs with the numeric error above and reject missing prompts with the prompt error (no re-prompting when both are supplied).
      2. Locate task in TODO.md; extract existing plan link. If absent, instruct to run /plan first (no dirs created).
      3. Verify referenced plan file exists.
      4. If `--dry-run`, stop after validation; do not set statuses or write files.
      5. Otherwise set TODO status to [IN PROGRESS] with **Started** date; state to `in_progress` if task-bound.
    </process>
  </stage>
  <stage id="2" name="CreateRevision">
    <action>Write new plan version</action>
    <process>
      1. If `--dry-run`, preview the new filename and exit without writing.
      2. In the same `plans/` folder, increment implementation-NNN.md to implementation-{N+1}.md.
      3. Include revision prompt, delta header, `[NOT STARTED]` phase markers, and inherit Lean intent metadata.
      4. Preserve numbering; do not modify next_project_number or create new project roots.
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Sync links and state</action>
    <process>
      1. If `--dry-run`, skip writes and return the intended new plan path only.
      2. Update TODO task to point to the new plan version; keep metadata intact.
      3. Update project state.json (if present) with new plan path, phase planning, timestamps; update global state pending task.
      4. Update IMPLEMENTATION_STATUS.md/FEATURE_REGISTRY.md with revised plan reference when applicable.
      5. Return plan path and applied updates.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (planning with standards + project context).</context_allocation>
  <lean_routing>Carry over Lean intent from original plan metadata or TODO Language; load Lean contexts only when Lean.</lean_routing>
  <batch_handling>Single task per invocation.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>No new project roots; only create the new plan file in existing plans/ subdir.</lazy_creation>
  <artifact_naming>implementation-{N+1}.md in same folder.</artifact_naming>
  <state_sync>Update state/TODO with new plan link and timestamps.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md (and other registries if status changes) as needed.</registry_sync>
  <git_commits>After writing the revised plan and syncing state/TODO, use git-commits.md + git-workflow-manager to stage only revision files; avoid repo-wide adds.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md with timestamps; preserve history.</status_markers>
  <language_routing>Respect Language metadata/flags; plan lean metadata inherited.</language_routing>
  <no_emojis>Outputs/artifacts are emoji-free.</no_emojis>
  <validation>Fail fast if plan link missing; avoid directory creation outside existing plan folder.</validation>
</quality_standards>

<usage_examples>
  - `/revise 105 "Add rollback plan and metrics"`
</usage_examples>

<validation>
  <pre_flight>Task and plan validated; statuses set.</pre_flight>
  <mid_flight>New plan version created in-place.</mid_flight>
  <post_flight>TODO/state/docs synced; references returned.</post_flight>
</validation>
