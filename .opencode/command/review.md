---
name: review
agent: orchestrator
description: "Ambition/gap-analysis review; propose tasks via /add without cleanup/archival"
context_level: 3
language: markdown
subagents:
  - reviewer (gap-analysis)
mcp_requirements:
  - "lean-lsp (when analyzing Lean files)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/FEATURE_REGISTRY.md
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
creates_root_on: "Only when writing review reports/summaries"
creates_subdir:
  - reports
  - summaries
---

Context Loaded:
@context/common/standards/
@context/common/standards/commands.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/common/standards/tasks.md
@Documentation/ProjectInfo/FEATURE_REGISTRY.md
@Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/project/{logic,lean4,math,physics,repo}

<context>
  <system_context>Repository ambition/gap analysis with strict numbering and lazy creation guardrails.</system_context>
  <domain_context>ProofChecker repo (code, docs, commands, tests).</domain_context>
  <task_context>Identify gaps, propose tasks via /add, optionally create review reports.</task_context>
  <execution_context>No cleanup/archival; numbering only via /add; lazy directory creation enforced.</execution_context>
</context>

<role>Reviewer focusing on gap analysis and task discovery.</role>

<task>Conduct gap analysis, register new tasks via /add, optionally emit review reports, and update status docs without touching archive/cleanup.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Set scope and guardrails</action>
    <process>
      1. Parse `$ARGUMENTS` for scope; confirm no cleanup/archival actions will occur.
      2. Load standards and status docs; ensure numbering changes only occur through /add.
    </process>
  </stage>
  <stage id="2" name="GapAnalysis">
    <action>Route to @subagents/reviewer (gap-analysis)</action>
    <process>
      1. Run coverage checks (architecture, docs, commands, tests).
      2. Produce findings and recommendations; optionally create review report under reports/ when writing artifact (create dirs lazily).
    </process>
  </stage>
  <stage id="3" name="TaskRegistration">
    <action>Register new tasks via /add</action>
    <process>
      1. Invoke /add (or todo-manager) for each proposed task to preserve numbering in state.json.
      2. Ensure tasks include full metadata and status `[NOT STARTED]`.
    </process>
  </stage>
  <stage id="4" name="Postflight">
    <action>Sync docs and summarize</action>
    <process>
      1. Update FEATURE_REGISTRY.md and IMPLEMENTATION_STATUS.md with new ambitions/gaps.
      2. Confirm TODO/state updates; keep archive untouched.
      3. Return findings, new task IDs, and artifact references (if reports created).
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 3 (repo-wide analysis).</context_allocation>
  <lean_routing>Load Lean/logic contexts when analysis touches Lean code; otherwise keep minimal.</lean_routing>
  <batch_handling>Multiple tasks proposed via /add sequentially to preserve numbering.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create review project root/subdir only when writing a report; never pre-create.</lazy_creation>
  <artifact_naming>Use reports/analysis-NNN.md or verification-NNN.md as appropriate.</artifact_naming>
  <state_sync>Update state/TODO via /add; do not alter archive/maintenance files.</state_sync>
  <registry_sync>Update FEATURE_REGISTRY.md and IMPLEMENTATION_STATUS.md; registries unchanged otherwise.</registry_sync>
  <git_commits>When reports or status doc changes are written, use git-commits.md + git-workflow-manager to stage only relevant files and commit; no blanket commits.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md for any task-bound updates.</status_markers>
  <language_routing>Respect Language metadata when proposing Lean tasks.</language_routing>
  <no_emojis>No emojis anywhere.</no_emojis>
  <validation>Reject direct numbering edits; avoid directory creation without artifacts.</validation>
</quality_standards>

<usage_examples>
  - `/review`
  - `/review "Focus on command coverage"`
</usage_examples>

<validation>
  <pre_flight>Scope set; guardrails confirmed.</pre_flight>
  <mid_flight>Gap analysis completed; tasks registered via /add.</mid_flight>
  <post_flight>Docs/state synced; references returned; archive untouched.</post_flight>
</validation>
