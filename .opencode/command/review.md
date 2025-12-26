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
@context/common/workflows/review.md
@context/common/standards/commands.md
@context/common/system/state-schema.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/common/standards/tasks.md
@Documentation/ProjectInfo/FEATURE_REGISTRY.md
@Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
@Documentation/ProjectInfo/MAINTENANCE.md
@.opencode/specs/TODO.md
@.opencode/specs/state.json
@context/project/{logic,lean4,math,physics,repo}

<context>
  <system_context>Repository ambition/gap analysis with configuration-driven registry updates and strict numbering guardrails.</system_context>
  <domain_context>Any repository with MAINTENANCE.md update instructions (ProofChecker, other projects).</domain_context>
  <task_context>Identify gaps, update registries per MAINTENANCE.md, propose tasks via /add, optionally create review reports.</task_context>
  <execution_context>Configuration-driven workflow; no cleanup/archival; numbering only via /add; lazy directory creation enforced.</execution_context>
</context>

<role>Reviewer focusing on gap analysis, registry updates, and task discovery using configuration-driven workflow.</role>

<task>Conduct gap analysis following review.md workflow, read MAINTENANCE.md update instructions, update specified registry/status files, register new tasks via /add, optionally emit review reports, without touching archive/cleanup.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Set scope and guardrails</action>
    <process>
      1. Parse `$ARGUMENTS` for scope; confirm no cleanup/archival actions will occur.
      2. Load review.md workflow context and standards; ensure numbering changes only occur through /add.
      3. Confirm lazy directory creation enforced (no project roots without artifacts).
    </process>
  </stage>
  <stage id="2" name="GapAnalysis">
    <action>Route to @subagents/reviewer (gap-analysis)</action>
    <process>
      1. Run coverage checks following review.md workflow (functionality, code quality, security, testing, performance, maintainability).
      2. Produce findings and recommendations; optionally create review report under reports/ when writing artifact (create dirs lazily).
      3. Identify all remaining work (missing features, documentation gaps, test coverage gaps, sorry resolutions, etc.).
    </process>
  </stage>
  <stage id="3" name="ReadUpdateInstructions">
    <action>Read MAINTENANCE.md update instructions</action>
    <process>
      1. Locate repository's MAINTENANCE.md file (check Documentation/ProjectInfo/MAINTENANCE.md, docs/MAINTENANCE.md, or root MAINTENANCE.md).
      2. Extract "Update Instructions for /review Command" section.
      3. Parse list of registry/status files to update.
      4. Read task registration workflow requirements.
      5. If MAINTENANCE.md not found or section missing, use default registry list (IMPLEMENTATION_STATUS.md, FEATURE_REGISTRY.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md).
    </process>
  </stage>
  <stage id="4" name="UpdateRegistries">
    <action>Update registry and status files per MAINTENANCE.md instructions</action>
    <process>
      1. Update IMPLEMENTATION_STATUS.md: module completion percentages, sorry counts, Known Limitations section (add new gaps, remove resolved).
      2. Update FEATURE_REGISTRY.md: register new features, update feature status, cross-reference with IMPLEMENTATION_STATUS.md.
      3. Update SORRY_REGISTRY.md: add newly discovered sorry placeholders, remove resolved, update resolution guidance.
      4. Update TACTIC_REGISTRY.md (if applicable): add newly discovered tactics, update descriptions and usage examples.
      5. Validate all updates are well-formed and consistent.
    </process>
  </stage>
  <stage id="5" name="TaskRegistration">
    <action>Register new tasks via /add</action>
    <process>
      1. Invoke /add for each identified task to preserve numbering in state.json.
      2. Ensure tasks include full metadata: description, effort, priority, language, dependencies, files affected.
      3. Set status `[NOT STARTED]` for all new tasks.
      4. Do NOT implement any tasks - only identify and register.
    </process>
  </stage>
  <stage id="6" name="Postflight">
    <action>Sync docs and summarize</action>
    <process>
      1. Confirm registry/status file updates completed successfully.
      2. Confirm TODO/state updates via /add; keep archive untouched.
      3. Return findings summary, new task IDs, updated registry files, and artifact references (if reports created).
      4. Provide actionable recommendations for next steps.
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
  <registry_sync>Update registry/status files specified in MAINTENANCE.md update instructions (IMPLEMENTATION_STATUS.md, FEATURE_REGISTRY.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md); use defaults if instructions not found.</registry_sync>
  <git_commits>When reports or registry/status doc changes are written, use git-commits.md + git-workflow-manager to stage only relevant files and commit; no blanket commits.</git_commits>
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
