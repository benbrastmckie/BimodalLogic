---
name: refactor
agent: refactorer
 description: "Refactor code for readability, maintainability, and style compliance"
 context_level: 1
 language: markdown
 subagents:
   - refactorer
   - style-checker
 mcp_requirements:
   - "lean-lsp (when refactoring Lean files)"
 registry_impacts:
   - TODO.md (task-bound)
   - .opencode/specs/state.json (task-bound)
   - Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md (if implementation status changes)
 creates_root_on: "Only when writing refactoring reports/summaries"
 creates_subdir:
   - reports
   - summaries
 dry_run: "Validate scope only; no dirs/artifacts/status/registry writes."

---

Context Loaded:
@context/common/standards/code.md
@context/common/standards/patterns.md
@context/common/standards/commands.md
@context/common/system/status-markers.md
@context/common/system/artifact-management.md
@context/project/repo/project-overview.md
(@context/project/lean4/* and @context/project/logic/* when refactoring Lean files)

<context>
  <system_context>Refactoring command focused on code quality and style compliance.</system_context>
  <domain_context>Codebase files specified by the user.</domain_context>
  <task_context>Refactor provided file(s), run checks, and summarize changes.</task_context>
  <execution_context>Single-pass refactoring with minimal context; artifacts created only when writing reports/summaries.</execution_context>
</context>

<role>Refactoring specialist coordinator.</role>

<task>Improve the specified file(s) for readability and maintainability, align with standards, and report changes.</task>

<workflow_execution>
  <stage id="1" name="Preflight">
    <action>Validate inputs</action>
    <process>
      1. Parse file paths from `$ARGUMENTS`; fail on empty input.
      2. Detect Lean vs non-Lean based on extensions to adjust contexts.
      3. If task-bound, mark TODO [IN PROGRESS] with **Started** date.
    </process>
  </stage>
  <stage id="2" name="Refactor">
    <action>Route to @subagents/refactorer</action>
    <process>
      1. Apply style-checker and simplifications.
      2. Perform targeted refactors; run tests where applicable.
      3. Produce refactoring report (if created, write under reports/refactoring-NNN.md).
    </process>
  </stage>
  <stage id="3" name="Postflight">
    <action>Summarize and sync</action>
    <process>
      1. Summarize changes and files touched; create/update summary if artifacts produced.
      2. Sync TODO/state/plan when task-bound; update registries if refactor affects implementation status.
    </process>
  </stage>
</workflow_execution>

<routing_intelligence>
  <context_allocation>Level 1 for targeted refactors; elevate to Level 2 if multiple modules or tests are involved.</context_allocation>
  <lean_routing>Load Lean contexts only for Lean files; validate lean-lsp MCP if Lean edits are required.</lean_routing>
  <batch_handling>Handle multiple files in one run; keep operations atomic.</batch_handling>
</routing_intelligence>

<artifact_management>
  <lazy_creation>Create reports/summaries only when writing artifacts; no pre-creation of project roots/subdirs.</lazy_creation>
  <artifact_naming>Use reports/refactoring-NNN.md for reports; summaries/implementation-summary-YYYYMMDD.md when produced.</artifact_naming>
  <state_sync>Update project/global state if artifacts produced or task-bound status changes.</state_sync>
  <registry_sync>Update registries when refactors change implementation status; skip on dry-run.</registry_sync>
</artifact_management>

<quality_standards>
  <status_markers>Maintain status markers with timestamps when task-bound.</status_markers>
  <language_routing>Respect file-language detection for Lean vs non-Lean paths.</language_routing>
  <no_emojis>Outputs/artifacts are emoji-free.</no_emojis>
  <validation>Reject missing files and empty input; avoid directory creation without artifacts.</validation>
</quality_standards>

<usage_examples>
  - `/refactor Logos/Core/Automation/ProofSearch.lean`
  - `/refactor src/module1.ts src/module2.ts`
</usage_examples>

<validation>
  <pre_flight>Inputs validated; contexts selected.</pre_flight>
  <mid_flight>Refactorer executed with tests/checks.</mid_flight>
  <post_flight>Summaries/state synced when applicable.</post_flight>
</validation>
