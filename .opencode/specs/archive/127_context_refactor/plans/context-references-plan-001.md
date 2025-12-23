---
project: 127_context_refactor
plan_type: context_references
source_refactor_plan: .opencode/specs/127_context_refactor/plans/context-refactor-plan-001.md
created: 2025-12-22
status: pending-refactor-structure
---

# Context References Update Plan (Placeholder-aware)

## 1) Inputs and constraints
- Refactor plan path provided: `.opencode/specs/127_context_refactor/plans/context-refactor-plan-001.md` (currently a placeholder with no new structure defined).
- Scope: all agent and command markdown files under `.opencode/agent/` and `.opencode/command/`.
- Requirement: map existing context references (`@...` or `.opencode/context/...`) to the post-refactor structure and define per-file edit steps. Because the refactor plan is empty, mappings are provisional and edits are deferred until a real structure exists.

## 2) Current context references (by file)
### Agents
- `.opencode/agent/subagents/lean-implementation-orchestrator.md`
  - Loaded: `@context/project/lean4/`, `@context/project/logic/`, `@context/common/standards/code.md`, `@context/common/standards/tests.md`, `@context/common/standards/documentation.md`
  - Narrative: `.opencode/context/project/lean4`, `.../logic`
- `.opencode/agent/subagents/task-adder.md`
  - Narrative: `.opencode/context/common/system/context-guide.md`
- `.opencode/agent/subagents/specialists/context-analyzer.md`
  - Narrative: `.opencode/context/`, `.opencode/agent/`, `.opencode/command/`; instructions to `glob` `.opencode/context/`
- `.opencode/agent/subagents/context-references.md`
  - Narrative: `.opencode/context/common/system/context-guide.md`; instructions to find `@/` or `.opencode/context/`
- `.opencode/agent/subagents/context-refactor.md`
  - Narrative: `.opencode/context/common/system/context-guide.md`

### Commands
- `.opencode/command/lean.md`
  - Loaded: `@.opencode/context/project/lean4/`, `@.opencode/context/project/logic/`, `@.opencode/context/common/standards/{code,tests,documentation}.md`, `@.opencode/context/project/repo/project-overview.md`
- `.opencode/command/task.md`
  - Loaded: `@.opencode/specs/TODO.md`, `@.opencode/specs/state.json`, `@.opencode/context/common/system/{state-schema,artifact-management,status-markers}.md`, `@.opencode/context/common/standards/{tasks,patterns}.md`, `@.opencode/context/common/workflows/task-breakdown.md`, `@.opencode/context/project/repo/project-overview.md`, optional Lean contexts `@.opencode/context/project/lean4/*`, `@.opencode/context/project/logic/*`
- `.opencode/command/plan.md`
  - Loaded: same as `/task` plus optional Lean contexts; non-Lean avoidance noted
- `.opencode/command/add.md`
  - Loaded: `@.opencode/specs/TODO.md`, `@.opencode/specs/state.json`, `@.opencode/context/common/system/{state-schema,artifact-management}.md`, `@.opencode/context/common/standards/{tasks,patterns}.md`
- `.opencode/command/research.md`
  - Loaded: `@.opencode/specs/TODO.md`, `@.opencode/specs/state.json`, `@.opencode/context/common/system/{state-schema,artifact-management}.md`, `@.opencode/context/common/standards/{tasks,patterns}.md`, `@.opencode/context/common/workflows/task-breakdown.md`
- `.opencode/command/context.md`
  - Loaded: `@context/common/system/context-guide.md`
- `.opencode/command/meta.md`
  - Narrative: generated structure lists `.opencode/context/`; docs list `.opencode/context/README.md`
- `.opencode/command/README.md`
  - Narrative: context allocation sourced from `.opencode/context/`

## 3) Old → new mapping (provisional)
Because the provided refactor plan is a placeholder with no target structure, no authoritative new paths are defined. Provisional mapping is identity (old → same) until a real refactor structure is produced.
- All `@context/...` and `@.opencode/context/...` entries: **no change** yet; pending actual refactor mapping.
- Narrative mentions of `.opencode/context/...`: **no change** yet; re-evaluate once refactor plan specifies new layout.

## 4) Per-file edit steps (deferred until real refactor plan exists)
For each file below, re-run this plan when a non-placeholder refactor plan is available. Then replace the identity mapping with concrete edits derived from the new structure.
- `.opencode/agent/subagents/lean-implementation-orchestrator.md`: update `<loaded_context>` and domain context paths once new Lean/logic/standards locations are defined.
- `.opencode/agent/subagents/task-adder.md`: update reference to `context-guide.md` if moved/renamed.
- `.opencode/agent/subagents/specialists/context-analyzer.md`: adjust references to `.opencode/context/` tree to match new root/segments.
- `.opencode/agent/subagents/context-references.md`: align instructions and context-guide path with new structure.
- `.opencode/agent/subagents/context-refactor.md`: align context-guide path with new structure.
- `.opencode/command/lean.md`: update loaded contexts to new Lean/logic/standards/repo paths.
- `.opencode/command/task.md`: update loaded contexts and optional Lean paths to new structure.
- `.opencode/command/plan.md`: update loaded contexts and optional Lean paths to new structure.
- `.opencode/command/add.md`: update common/system and standards paths.
- `.opencode/command/research.md`: update common/system/standards/workflows paths.
- `.opencode/command/context.md`: update `@context/common/system/context-guide.md` to new path.
- `.opencode/command/meta.md`: update narrative examples of `.opencode/context/` and documentation links.
- `.opencode/command/README.md`: update context allocation narrative to reflect new hierarchy.

## 5) Immediate next actions
1. Produce a complete refactor structure in `.opencode/specs/127_context_refactor/plans/context-refactor-plan-001.md` (or superseding version).
2. Re-run the context-references workflow with the real refactor plan to generate concrete old→new mappings and apply edits.
3. Once the new structure is defined, update all listed files using `edit` tool steps derived from the final mapping and verify references via `grep`.
