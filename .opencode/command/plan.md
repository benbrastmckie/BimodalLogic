---
name: plan
agent: planner
 description: "Create implementation plan for an existing TODO task number and sync artifacts"
 context_level: 2
 language: markdown
 subagents:
   - planner
 mcp_requirements:
   - "lean-lsp (Lean tasks only)"
 registry_impacts:
   - TODO.md
   - .opencode/specs/state.json
   - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
 creates_root_on: "When writing the first plan artifact"
 creates_subdir:
   - plans
 dry_run: "Parse task + Lean intent, MCP ping if Lean, no dirs/status/registry writes, no artifacts."

---

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/common/standards/commands.md
@context/common/standards/plan.md
@context/common/standards/tasks.md
@context/common/workflows/task-breakdown.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/project/repo/project-overview.md
(@.opencode/context/project/lean4/* and @.opencode/context/project/logic/* when Lean intent is detected)

<context>
  <system_context>Planning command that must honor numbering, status markers, and lazy directory creation.</system_context>
  <domain_context>TODO tasks and project specs directories.</domain_context>
  <task_context>Create an implementation plan for the specified task, capture research links, and sync TODO/state.</task_context>
  <execution_context>Plan creation may create project root and plans/ subdir only when writing the plan artifact.</execution_context>
</context>

<role>Planner orchestrating plan creation with research inputs and Lean routing awareness.</role>

<task>Given a task number and optional prompt, generate an implementation plan with research inputs, set status markers, and link artifacts in TODO/state.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate task and detect Lean intent</action>
    <process>
      1. Parse task number and optional prompt; fail clearly if task missing from TODO.md.
      2. Detect Lean via TODO `Language` or `--lang`; plan `lean:` is secondary.
      3. Set TODO status to [IN PROGRESS] with **Started** date; set state status to `in_progress` before routing.
    </process>
  </stage>
  <stage id="2" name="PrepareArtifacts">
    <action>Resolve project paths and research inputs</action>
    <process>
      1. Derive slug from TODO title; create project root and `plans/` only when writing the plan.
      2. Collect research links from TODO; warn on missing files but continue.
    </process>
  </stage>
  <stage id="3" name="CreatePlan">
    <action>Route to @subagents/planner</action>
    <process>
      1. Generate `plans/implementation-XXX.md` (incremental) using plan standard.
      2. Include Research Inputs section with citations or "none linked".
      3. Include `lean: true|false` in metadata and plan-level status marker `[IN PROGRESS]` with timestamps while phases start at `[NOT STARTED]`.
    </process>
  </stage>
  <stage id="4" name="Postflight">
    <action>Link and sync</action>
    <process>
      1. Mark TODO and state to `[PLANNED]` with **Completed** date; add plan link and brief summary; keep metadata intact.
      2. Update project state (phase: planning, status `planned`) with plan path and timestamps; avoid creating extra subdirs.
      3. Return plan path and next steps.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (planning with standards + project overview).</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; load Lean/logic contexts only when Lean.</lean_routing>
  <batch_handling>Single task per invocation; batch handled via /task + planner.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project root and plans/ only when emitting the plan; do not create reports/ or summaries.</lazy_creation>
  <artifact_naming>Plans use `implementation-XXX.md` incremental numbering.</artifact_naming>
  <state_sync>Update project state.json when plan is written; update global state/TODO links.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md if plan changes implementation status expectations; registries untouched otherwise.</registry_sync>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md for plan header and phases; include timestamps.</status_markers>
  <language_routing>Respect Language metadata/flags; plan `lean:` is secondary.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Fail fast on missing task; do not create directories without emitting plan.</validation>
</quality_standards>

<usage_examples>
  - `/plan 105 "Focus on auth flows and RBAC"`
  - `/plan 129 --lang lean`
</usage_examples>

<validation>
  <pre_flight>Task resolved; Lean intent detected; statuses set.</pre_flight>
  <mid_flight>Plan created with research inputs; lazy creation enforced.</mid_flight>
  <post_flight>TODO/state linked; plan path returned.</post_flight>
</validation>
