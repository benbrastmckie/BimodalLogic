# Research Report: Enforce lazy directory creation for command artifacts

**Project:** #109 — enforce_lazy_directory_creation_for_command_artifacts  
**Date:** 2025-12-22  
**Research Type:** Command/agent contract audit

## Research Question
Identify commands and agents that pre-create project or artifact subdirectories (or use placeholders) in violation of the lazy directory creation standard, and recommend enforcement patterns.

## Key Findings

1. **/research command pre-creates full tree** — `.opencode/command/research.md` step 2 mandates creating the project directory **with subdirs reports/, plans/, summaries/** before any artifact is written.
2. **/plan command pre-creates full tree** — `.opencode/command/plan.md` step 2 instructs creating the project directory **with plans/, reports/, summaries/** up front.
3. **Researcher agent auto-creates project + subdirs** — `.opencode/agent/subagents/researcher.md` stage 1 creates `.opencode/specs/NNN_research_{topic}/` and stage 3 assumes `reports/` exists; this bypasses lazy creation.
4. **Planner agent auto-creates project + plans dir** — `.opencode/agent/subagents/planner.md` stage 1d creates `.opencode/specs/NNN_{project_name}/` and `plans/implementation-001.md` path is assumed, forcing early directory creation.
5. **Reviewer agent pre-creates reports/ and summaries/** — `.opencode/agent/subagents/reviewer.md` stage 1 creates `.opencode/specs/NNN_review_YYYYMMDD/` and subdirs `reports/`, `summaries/` before emitting artifacts; the `/review` command delegates here.
6. **Existing placeholder files indicate non-lazy practice** — `.opencode/specs/108_harmonize_todo_and_review_command_lifecycle_for_cleanup_and_gap_analysis/{reports/.gitkeep,plans/.gitkeep,summaries/.gitkeep}` show placeholder-based subdir creation contrary to the standard.
7. **/todo command already guards against premature creation** — `.opencode/command/todo.md` explicitly avoids creating new project directories; use as template for guardrails.

## Recommendations (enforcement patterns)
- **Command contracts:** Update `/research` and `/plan` docs to: (a) create the project root only when writing the first artifact; (b) create only the needed subdir (`reports/` or `plans/`) at that moment; (c) explicitly forbid pre-creating unused subdirs and `.gitkeep` placeholders.
- **Agent workflows:** Patch researcher, planner, and reviewer agents to gate directory creation: check for existing project root; create only the artifact-specific subdir when writing; remove instructions to create summaries/ or other subdirs proactively.
- **Placeholder cleanup:** Remove `.gitkeep` files from existing projects and prevent agents/commands from emitting them; rely on lazy subdir creation instead.
- **Validation hook:** Add a pre-flight check in orchestrator/commands to fail if attempting to create empty subdirs (unless writing an artifact) and to ensure artifacts drive directory creation.
- **State alignment:** Ensure project state files are created/updated only when an artifact is produced; no state writes on empty directories.

## Relevant Resources
- Lazy creation standard: `.opencode/context/common/system/artifact-management.md` (Best Practices #1–2)
- Violating commands: `.opencode/command/research.md`, `.opencode/command/plan.md`
- Violating agents: `.opencode/agent/subagents/researcher.md`, `.opencode/agent/subagents/planner.md`, `.opencode/agent/subagents/reviewer.md`
- Placeholder evidence: `.opencode/specs/108_harmonize_todo_and_review_command_lifecycle_for_cleanup_and_gap_analysis/`
- Guardrail example: `.opencode/command/todo.md`

## Summary
Multiple command and agent specifications still instruct pre-creating full project directory trees (reports/plans/summaries) or using `.gitkeep`, conflicting with the lazy directory creation standard in `artifact-management.md`. The primary offenders are `/research`, `/plan`, and their underlying researcher/planner agents, plus the reviewer agent and existing `.gitkeep` placeholders in project 108. Enforce lazy creation by updating command/agent contracts to create only the root and the specific subdir at artifact-write time, removing placeholder files, and gating state writes on actual artifacts.
