---
name: lean
agent: orchestrator
description: "Implement Lean 4 proofs using multi-phase Lean-specialist stack"
context_level: 2
language: markdown
subagents:
  - complexity-analyzer
  - dependency-mapper
  - library-navigator
  - proof-strategy-advisor
  - tactic-recommender
  - proof-developer
  - proof-optimizer
  - performance-profiler
  - example-builder
  - documentation-generator
  - code-reviewer
  - style-checker
mcp_requirements:
  - "lean-lsp (required)"
registry_impacts:
  - TODO.md
  - .opencode/specs/state.json
  - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
  - SORRY_REGISTRY.md
  - TACTIC_REGISTRY.md
creates_root_on: "When writing first Lean artifact (reports/summaries)"
creates_subdir:
  - reports
  - summaries
---

Context Loaded:
@.opencode/context/project/lean4/
@.opencode/context/project/logic/
@context/common/standards/commands.md
@context/common/standards/code.md
@context/common/standards/tests.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/project/repo/project-overview.md

<context>
  <system_context>Lean implementation with specialist routing and MCP validation.</system_context>
  <domain_context>Lean 4 proofs within ProofChecker (Lake/mathlib stack).</domain_context>
  <task_context>Execute plan-driven Lean implementation with optional research, verification, optimization, and documentation phases.</task_context>
  <execution_context>Respect flags (`--fast`, `--skip-*`, `--full`); validate lean-lsp MCP before Lean work; honor lazy creation.</execution_context>
</context>

<role>Lean implementation orchestrator coordinating Lean specialists and phase execution.</role>

<task>Given a project number and flags, locate the plan, run configured phases (analysis, research, implementation, verification, optimization, docs), update plan/TODO/state with status markers, and return artifact references.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate inputs and Lean MCP</action>
    <process>
      1. Parse `$ARGUMENTS`: project number and flags; show help and exit on `--help`.
      2. Resolve plan in `.opencode/specs/NNN_project/` (error if missing; no dirs created).
      3. Validate `lean-lsp` MCP availability (uvx lean-lsp-mcp); abort with remediation if missing.
      4. Set TODO/plan status to [IN PROGRESS] with timestamps when task-bound; update state to `in_progress`.
    </process>
  </stage>
  <stage id="2" name="PhaseExecution">
    <action>Run selected phases via Lean specialists</action>
    <process>
      1. (Optional) Analysis: complexity-analyzer, dependency-mapper → reports/analysis-*.
      2. (Optional) Research/strategy: library-navigator, proof-strategy-advisor, tactic-recommender → reports/research-*.
      3. Implementation: proof-developer/lean-implementation-orchestrator executes plan phases; lazy creation for artifacts.
      4. (Optional) Verification/quality: verification-specialist, code-reviewer, style-checker.
      5. (Optional) Optimization: proof-simplifier, proof-optimizer, performance-profiler.
      6. (Optional) Documentation/examples: example-builder, documentation-generator, doc-analyzer.
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Sync and summarize</action>
    <process>
      1. Update plan with phase status markers/timestamps; skip completed phases.
      2. Emit/update implementation summary `summaries/implementation-summary-YYYYMMDD.md` when artifacts produced.
      3. Sync TODO/state with status, timestamps, and artifact links; update registries if sorry/tactic counts change.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 2 by default; elevate to Level 3 when combining multiple phases across many files.</context_allocation>
  <lean_routing>Lean intent required; TODO `Language` or `--lang` override respected; plan `lean:` secondary.</lean_routing>
  <batch_handling>Phases can run in waves; ensure atomic status updates per phase.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create project roots/subdirs only when writing artifacts (reports/summaries); never pre-create.</lazy_creation>
  <artifact_naming>Use standard naming: reports/{analysis|research|verification}-NNN.md, summaries/implementation-summary-YYYYMMDD.md.</artifact_naming>
  <state_sync>Update project/global state with phase/status and artifacts.</state_sync>
  <registry_sync>Update IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md, TACTIC_REGISTRY.md when Lean work changes status/sorry/tactic counts; skip on dry-run.</registry_sync>
  <git_commits>After artifacts/status updates, use git-commits.md + git-workflow-manager to stage only Lean-related files; avoid blanket adds and commit with scoped messages.</git_commits>
</artifact_management>

<quality_standards>
  <status_markers>Use status-markers.md; preserve **Started/Completed** timestamps.</status_markers>
  <language_routing>Lean-specific paths enforced; non-Lean contexts excluded.</language_routing>
  <no_emojis>No emojis in outputs or artifacts.</no_emojis>
  <validation>Fail early on missing plan or MCP; no directory creation without artifacts.</validation>
</quality_standards>

<usage_examples>
  - `/lean 129 --fast`
  - `/lean 132 --full`
  - `/lean 130 --skip-research --skip-docs`
</usage_examples>

<validation>
  <pre_flight>Plan resolved; MCP validated; statuses set when task-bound.</pre_flight>
  <mid_flight>Phases executed per flags; lazy creation enforced.</mid_flight>
  <post_flight>Plan/TODO/state/registries synced; artifacts referenced.</post_flight>
</validation>
