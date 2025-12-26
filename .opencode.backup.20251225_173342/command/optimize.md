---
name: optimize
agent: orchestrator
description: "Optimize agent/command/context design and compliance via orchestrated meta-system review"
context_level: 2
language: markdown
subagents:
  - planner
  - context-references
  - context-refactor
  - dependency-mapper
  - doc-analyzer
  - style-checker
mcp_requirements: []
registry_impacts:
  - .opencode/specs/TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (conditional)
creates_root_on: "When writing the first optimize artifact (plan or report) after resolving the task binding"
creates_subdir:
  - plans
  - reports
  - summaries
---

Context Loaded:
@context/index.md
@context/common/templates/
@context/common/system/context-guide.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/common/system/git-commits.md
@context/common/standards/commands.md
@context/common/standards/patterns.md
@context/common/standards/tasks.md
@context/common/standards/plan.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json

<context>
  <system_context>Meta command orchestrating optimization of agents, subagents, commands, and context references with mandatory task+plan creation and status-marker compliance.</system_context>
  <domain_context>.opencode meta-system architecture, command standards, registry/state synchronization, and artifact management.</domain_context>
  <task_context>Bind or create a TODO task, generate a plan artifact, and execute a routed optimization review that aligns command→agent→subagent flows and context usage.</task_context>
  <execution_context>Markdown/meta only (reject lean); orchestrator is primary; planner invoked as subagent for plan creation; lazy directory creation enforced.</execution_context>
</context>

<role>Orchestrator-led meta optimizer coordinating planner and analysis subagents for compliant task, plan, and optimization artifact delivery.</role>

<task>Create or update the optimization task entry, generate a plan artifact through planner, route optimization analyses to supporting subagents, and sync TODO/state with status markers.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate flags and task binding</action>
    <process>
      1. Parse flags: --scope {all|commands|agents|contexts|docs|routing} (default: all); --task {id|new}; --priority {High|Medium|Low}; --title (when creating); --lang {markdown} (reject lean).
      2. Enforce markdown/meta scope; reject Lean intent and fail fast on unsupported flags or malformed inputs.
      3. Resolve task binding: if --task points to an existing TODO entry, load it and set **Status** to [IN PROGRESS] with **Started** timestamp; otherwise allocate a new task ID from state.json, insert a Medium-priority markdown TODO entry with Files Affected covering .opencode command/context/specs, and set it to [IN PROGRESS].
      4. Sync .opencode/specs/state.json to `in_progress` with started_at; do not create project directories during preflight.
    </process>
  </stage>
  <stage id="2" name="PlanCreation">
    <action>Invoke planner subagent and prepare artifacts</action>
    <process>
      1. Derive project slug from the TODO title; lazy-create the project root and `plans/` only when writing the plan artifact.
      2. Orchestrator delegates plan drafting to @subagents/planner **using `.opencode/context/common/standards/plan.md` section ordering** (context → role → task → workflow_execution → routing_intelligence → artifact_management → quality_standards → usage_examples → validation); include required front matter/metadata and Research Inputs (or "none linked"), and ensure phase status markers/timestamps are present.
      3. Warn (do not fail) on missing/dangling research links; do not create directories while resolving links.
      4. Link the plan path back into TODO.md and state.json; update plan status markers to mirror TODO/state transitions.
    </process>
  </stage>
  <stage id="3" name="Execution">
    <action>Route optimization analysis to subagents</action>
    <process>
      1. Confirm Level 2 filtered context suffices; keep allocation minimal and avoid extra directory creation until artifacts are emitted.
      2. Orchestrator coordinates subagents:
         - context-references: map command→agents, agent→subagents, and agent/command→context references; flag mismatches.
         - context-refactor: propose context loading deduplication aligned to context-guide and patterns.
         - dependency-mapper: capture cross-agent/command dependencies and routing flows; detect orphans.
         - doc-analyzer/style-checker (docs scope): validate against standards/commands, **plan.md section order**, and patterns; ensure plan-generation instructions in /optimize align with plan standard.
      3. Aggregate findings into compliance tables and remediation steps; write `reports/optimize-report-YYYYMMDD.md` only when emitting results (lazy-create `reports/`).
    </process>
  </stage>
  <stage id="4" name="Postflight">
    <action>Sync artifacts, TODO, and state</action>
    <process>
      1. Update plan phases/status markers with timestamps; set TODO/status to [COMPLETED], [BLOCKED], or [PAUSED] as appropriate and record **Completed** or blocking reason.
      2. Emit optional `summaries/implementation-summary-YYYYMMDD.md` when artifacts exist and link in TODO/state; keep lazy creation (no summaries without artifacts).
      3. Sync .opencode/specs/state.json with final status, timestamps, plan/report links, and registry impacts; update IMPLEMENTATION_STATUS.md when command/agent routing changes affect implementation readiness.
      4. Return concise summary with artifact links; no emojis.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Default Level 2 filtered context; escalate only if remediation requires multi-command rewrites.</context_allocation>
  <lean_routing>Reject --lang lean; optimize operates in markdown/meta space only.</lean_routing>
  <batch_handling>For large scopes, coordinate via batch-task-orchestrator/batch-status-manager while preserving per-task status markers.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project root only when writing the first plan/report; create only the needed subdir (plans|reports|summaries) at artifact write time; no directories during validation or routing phases.</lazy_creation>
  <artifact_naming>Plan: plans/implementation-XXX.md; Report: reports/optimize-report-YYYYMMDD.md; Summary: summaries/implementation-summary-YYYYMMDD.md.</artifact_naming>
  <state_sync>Update .opencode/specs/state.json when artifacts are created or statuses change; mirror plan/TODO status markers and timestamps.</state_sync>
  <registry_sync>Update TODO.md and state.json on every execution; adjust IMPLEMENTATION_STATUS.md when optimization changes affect implementation/tactic readiness.</registry_sync>
</artifact_management>

  <quality_standards>
    <status_markers>Use status-markers.md for TODO entries, plan headers, and phases; preserve timestamp history.</status_markers>
    <language_routing>Markdown/meta only; reject Lean overrides and omit Lean contexts.</language_routing>
    <plan_compliance>Plans must conform to `.opencode/context/common/standards/plan.md` (section order, required metadata/front matter, Research Inputs, phase scaffolding with status markers/timestamps); reject outputs that deviate.</plan_compliance>
    <no_emojis>Outputs and artifacts must be emoji-free.</no_emojis>
    <validation>Fail fast on invalid flags, missing task binding, or directory creation attempts outside artifact writes.</validation>
  </quality_standards>


<usage_examples>
  - `/optimize --task 155 --scope commands`
  - `/optimize --scope agents,contexts`
  - `/optimize --task new --title "Optimize meta command routing" --priority Medium`
  - `/optimize --scope docs`
</usage_examples>

<validation>
  <pre_flight>Arguments validated; markdown-only enforced; task resolved/created and set to [IN PROGRESS] with timestamps.</pre_flight>
  <mid_flight>Planner subagent creates plan with lazy directories; orchestrator routes optimization subagents; artifacts only when writing outputs.</mid_flight>
  <post_flight>TODO/state/plan synced with status markers and links; registries updated when applicable.</post_flight>
</validation>
