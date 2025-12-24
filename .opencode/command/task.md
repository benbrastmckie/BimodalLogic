---
name: task
agent: orchestrator
description: "Execute TODO task(s) by number using plans/reports and keep specs in sync"
context_level: 2
language: markdown
subagents:
  - batch-task-orchestrator
  - batch-status-manager
  - implementation-orchestrator (non-Lean tasks)
  - lean-implementation-orchestrator (Lean tasks)
  - planner/researcher/reviewer/refactorer/documenter (routed per task type)
mcp_requirements:
  - "lean-lsp (required for Lean task execution)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (when implementation status changes)
  - SORRY_REGISTRY.md (when sorry counts change)
  - TACTIC_REGISTRY.md (when tactic counts change)
creates_root_on: "Only when delegated agent writes first artifact"
creates_subdir: "Delegated agent creates the needed subdir (reports|plans|summaries) when writing"
---

You are executing task(s) from `.opencode/specs/TODO.md` by number. Use existing research and plans, respect lazy directory creation, and keep TODO/state/artifacts synchronized.

**Task Input:** $ARGUMENTS (task number(s); ranges/lists allowed)

Context Loaded:
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@.opencode/context/common/system/state-schema.md
@.opencode/context/common/system/artifact-management.md
@.opencode/context/common/system/status-markers.md
@.opencode/context/common/standards/tasks.md
@.opencode/context/common/standards/commands.md
@.opencode/context/common/standards/patterns.md
@.opencode/context/common/workflows/task-breakdown.md
@.opencode/context/project/repo/project-overview.md
(@.opencode/context/project/lean4/* and @.opencode/context/project/logic/* only when executing Lean-tagged plans)

<context>
  <system_context>Task executor for TODO items with batch support and strict status/lazy-creation rules.</system_context>
  <domain_context>Tasks defined in TODO.md with linked plans/research in specs/.</domain_context>
  <task_context>Resolve task numbers, pre-flight status updates, route to appropriate agents, and sync artifacts/state.</task_context>
  <execution_context>Supports single or batch execution with wave routing; no directories created without artifacts.</execution_context>
</context>

<role>Task orchestrator managing routing, status propagation, and synchronization.</role>

<task>Execute one or more TODO tasks, updating status markers, leveraging linked plans/reports, producing summaries when artifacts are written, and synchronizing TODO/state.</task>

<workflow_execution>
  <stage id="1" name="ParseInput">
    <action>Validate task numbers</action>
    <process>
      1. Support single numbers, comma-separated lists, and ranges (e.g., `105`, `105,106`, `105-107`). Detect range/list invocations first, normalize to an ordered, de-duplicated task list, and preserve numeric-only validation.
      2. Validate positive integers; deduplicate expanded lists; fail clearly on invalid formats and return bad inputs.
      3. If more than one normalized task remains, classify as batch and route to batch-task-orchestrator; otherwise continue with single-task flow.
    </process>
  </stage>
  <stage id="2" name="ResolveTasks">
    <action>Load TODO entries and detect Lean intent</action>
    <process>
      1. Locate each task in TODO.md; if missing, report and continue.
      2. Detect Lean via TODO `Language` (authoritative) or `--lang`; plan `lean:` secondary.
      3. Pre-flight: atomically set TODO status to [IN PROGRESS] with **Started** date and, when a plan link exists, set the plan header + first active phase to [IN PROGRESS] with (Started: ISO8601); set state to `in_progress` with started_at in the same batch. No dirs created.
    </process>
  </stage>
  <stage id="3" name="Execute">
    <action>Route by work type</action>
    <process>
      1. Single task: route to appropriate agent (documentation → documenter; refactor → refactorer; research-only → researcher; code → implementer; Lean → lean-implementation-orchestrator/proof-developer).
      2. Multiple tasks: route via batch-task-orchestrator + batch-status-manager with wave-based execution; Lean tasks use Lean path within waves. Batch handoff includes normalized task list, language metadata per task, and dependency hints; dependency analysis precedes execution.
      3. Reuse plan/research links exactly; maintain lazy creation (project roots/subdirs only when writing artifacts). Batch execution must keep TODO/plan/state status markers in lockstep for each task and block dependents on failure.
    </process>
  </stage>
  <stage id="4" name="Postflight">
    <action>Sync and report</action>
    <process>
      1. Update plan phases/status markers when used, keeping TODO/plan/state status fields in lockstep; produce/update summaries under `summaries/implementation-summary-YYYYMMDD.md` when artifacts are written.
      2. Update TODO with status markers (`[IN PROGRESS]` → `[COMPLETED]`), timestamps, and artifact links in the same atomic write batch as plan/state; keep metadata intact.
      3. Sync state.json with status/timestamps/artifact links/phase markers; reuse plan links already attached.
      4. Return concise summary of routing, artifacts, TODO/state updates, and any task failures.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 baseline; escalate per task complexity.</context_allocation>
  <lean_routing>Lean intent from TODO `Language` or `--lang`; validate lean-lsp MCP before Lean work.</lean_routing>
  <batch_handling>Use batch-task-orchestrator + batch-status-manager for multi-task inputs; ensure atomic status updates per task.</batch_handling>
</routing_intelligence>

  <artifact_management>
  <lazy_creation>Derive slug `.opencode/specs/NNN_slug/`; create project root/subdir only when writing an artifact.</lazy_creation>
  <artifact_naming>Summaries under `summaries/implementation-summary-YYYYMMDD.md`; plan/research links reused.</artifact_naming>
  <state_sync>Update project state alongside artifact writes; no project state writes when no artifacts; status sync writes to TODO/plan/state must be atomic.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md when task execution changes status or sorry/tactic counts.</registry_sync>
  <git_commits>After artifacts/state updates, use git-commits.md and git-workflow-manager to stage only task-relevant files (no `git add -A`/blanket commits) and commit with scoped messages.</git_commits>
 </artifact_management>


<quality_standards>
  <status_markers>Apply status-markers.md for tasks and plan phases with timestamps.</status_markers>
  <language_routing>Respect Language metadata/flags; plan `lean:` secondary.</language_routing>
  <no_emojis>No emojis in commands or artifacts.</no_emojis>
  <validation>Reject directory creation without artifact writes; fail clearly on invalid inputs.</validation>
</quality_standards>

<usage_examples>
  - `/task 105`
  - `/task 105,106`
  - `/task 105-107`
  - `/task 105, 107-109, 111`
</usage_examples>

<validation>
  <pre_flight>Inputs validated; TODO/plan/state set to [IN PROGRESS] with timestamps.</pre_flight>
  <mid_flight>Routing executed with lazy creation; artifacts produced as needed.</mid_flight>
  <post_flight>TODO/state synced; summaries linked; errors reported per task.</post_flight>
</validation>
