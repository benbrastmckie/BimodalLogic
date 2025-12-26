---
name: context
agent: orchestrator
description: "Plan and route context refactor/reference updates via subagents"
context_level: 2
language: markdown
subagents:
  - context-refactor
  - context-references
  - task-adder
mcp_requirements: []
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
creates_root_on: "Subagents only when writing their artifacts"
creates_subdir:
  - reports
  - plans
---

Context Loaded:
@context/common/system/context-guide.md
@context/common/standards/commands.md
@context/common/system/artifact-management.md
@context/common/system/status-markers.md
@context/context/index.md

<context>
  <system_context>Orchestrator for context refactor/reference planning using chained subagents.</system_context>
  <domain_context>.opencode/context directory organization and references.</domain_context>
  <task_context>Create refactor and reference-update plans, then add TODO entries using subagents.</task_context>
  <execution_context>Sequence subagents, pass artifact references (not contents), and preserve lazy creation.</execution_context>
</context>

<role>Workflow orchestrator for context planning and TODO insertion.</role>

<task>Generate a context refactor plan, generate a references update plan, and register resulting tasks in TODO.md without reading artifact contents.</task>

<workflow_execution>
  <stage id="1" name="PlanContextRefactor">
    <action>Route to @subagents/context-refactor</action>
    <process>
      1. Pass user request `$ARGUMENTS`.
      2. Capture returned `artifact_path` and `summary` (no content load).
    </process>
  </stage>
  <stage id="2" name="PlanReferenceUpdates">
    <action>Route to @subagents/context-references</action>
    <process>
      1. Pass refactor plan path and parent directory for placement.
      2. Capture returned `artifact_path` and `summary`.
    </process>
  </stage>
  <stage id="3" name="RegisterTasks">
    <action>Route to @subagents/task-adder</action>
    <process>
      1. Provide JSON bundle of both plan results.
      2. Add tasks to TODO.md/state with appropriate status markers.
    </process>
  </stage>
  <stage id="4" name="PresentResults">
    <action>Return references</action>
    <process>
      1. Present summaries and artifact paths for both plans.
      2. Confirm TODO/state updates.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 (multi-step, standards + context guide required).</context_allocation>
  <lean_routing>No Lean-specific routing; language remains markdown.</lean_routing>
  <batch_handling>Sequential chaining; each stage waits for prior artifact reference.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Subagents create project roots/subdirs only when writing their artifacts; orchestrator never pre-creates.</lazy_creation>
  <state_sync>Task-adder updates TODO/state; orchestrator records references only.</state_sync>
  <registry_sync>No registry updates unless subagents specify.</registry_sync>
  <git_commits>If subagents produce artifacts/status updates, use git-commits.md + git-workflow-manager to stage only those files before committing; avoid blanket adds.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md; propagate timestamps where subagents update tasks/plans.</status_markers>
  <language_routing>Non-Lean path; Language metadata remains markdown.</language_routing>
  <no_emojis>All outputs are emoji-free.</no_emojis>
  <validation>Reject missing/invalid references; avoid reading artifact contents.</validation>
</quality_standards>

<usage_examples>
  - `/context "Refresh context mapping after refactor"`
</usage_examples>

<validation>
  <pre_flight>Request parsed; context guide loaded.</pre_flight>
  <mid_flight>Subagent calls sequenced; references captured only.</mid_flight>
  <post_flight>TODO/state updates confirmed; references returned.</post_flight>
</validation>
