---
name: plan
agent: orchestrator
description: "Create implementation plan(s) for existing TODO task(s) and sync artifacts (supports single, ranges, and lists)"
context_level: 2
language: markdown
subagents:
  - planner
  - batch-task-orchestrator
  - batch-status-manager
  - status-sync-manager
mcp_requirements:
  - "lean-lsp (Lean tasks only)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
creates_root_on: "When writing the first plan artifact"
creates_subdir:
  - plans
input_format: "Required: task number(s) - single (e.g., /plan 160), range (e.g., /plan 132-135), or list (e.g., /plan 132,133,134). Reject missing/non-numeric inputs. Error message (no emojis): 'Error: Task number(s) required and must be numeric (e.g., /plan 160 or /plan 132-135).'"
---

**Task Input (required):** $ARGUMENTS (task number(s); ranges/lists allowed, e.g., `/plan 160`, `/plan 132-135`, `/plan 132,133,134`)

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
      2. Detect Lean via TODO `Language` (authoritative) or `--lang`; plan `lean:` is secondary. If Lean, MCP ping `lean-lsp` before proceeding.
      3. Pre-flight: use @subagents/specialists/status-sync-manager to atomically set TODO status to [IN PROGRESS] with **Started** date and state status to `in_progress`. No dirs created.
    </process>
  </stage>
  <stage id="3" name="PrepareArtifacts">
    <action>Resolve project paths and research inputs</action>
    <process>
      1. For each task: derive slug from TODO title; create project root and `plans/` only when writing the plan.
      2. Collect research links from TODO for each task; warn on missing files but continue; do not create directories while resolving links.
    </process>
  </stage>
  <stage id="4" name="CreatePlan">
    <action>Route to planner(s)</action>
    <process>
      1. Single task: route to @subagents/planner directly.
      2. Multiple tasks: route via @subagents/batch-task-orchestrator with planner subagent for each task; batch handoff includes normalized task list, language metadata per task, research links per task, and dependency hints.
      3. For each task: generate `plans/implementation-XXX.md` (incremental) using plan standard.
      4. Include Research Inputs section with citations or "none linked" for each plan.
      5. Include `lean: true|false` in metadata and plan-level status marker `[IN PROGRESS]` with timestamps while phases start at `[NOT STARTED]`.
    </process>
  </stage>
  <stage id="5" name="Postflight">
    <action>Link and sync</action>
    <process>
      1. Use @subagents/specialists/status-sync-manager to atomically mark TODO, state.json, project state.json, and plan file to [PLANNED] status with **Completed** date for each task; add plan link to TODO and brief summary; keep metadata intact.
      2. Update project state (phase: planning, status `planned`) with plan path and timestamps for each task; avoid creating extra subdirs.
      3. Mark plan file header with [PLANNED] status and **Completed** timestamp for each plan.
      4. Return plan paths and next steps for all tasks.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (planning with standards + project overview).</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; load Lean/logic contexts only when Lean.</lean_routing>
  <batch_handling>Use batch-task-orchestrator + batch-status-manager for multi-task inputs; ensure atomic status updates per task; route each task to planner subagent.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project root and plans/ only when emitting the plan; do not create reports/ or summaries.</lazy_creation>
  <artifact_naming>Plans use `implementation-XXX.md` incremental numbering.</artifact_naming>
  <state_sync>Update project state.json when plan is written; update global state/TODO links.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md if plan changes implementation status expectations; registries untouched otherwise.</registry_sync>
  <git_commits>After the plan artifact and status updates are written, use git-commits.md + git-workflow-manager to stage only plan-related files and commit with a scoped message; no repo-wide adds.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md for plan header and phases; include timestamps.</status_markers>
  <language_routing>Respect Language metadata/flags; plan `lean:` is secondary.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Fail fast on missing task; do not create directories without emitting plan.</validation>
</quality_standards>

<usage_examples>
  - `/plan 161 "Fix parser regression"`
  - `/plan 129 --lang lean`
  - `/plan 132-135` (batch planning for tasks 132, 133, 134, 135)
  - `/plan 132,134,136` (batch planning for specific tasks)
</usage_examples>

<validation>
  <pre_flight>Task resolved; Lean intent detected; statuses set.</pre_flight>
  <mid_flight>Plan created with research inputs; lazy creation enforced.</mid_flight>
  <post_flight>TODO/state linked; plan path returned.</post_flight>
</validation>
