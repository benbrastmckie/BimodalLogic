# Implementation Plan v2: Update context references after refactor (Task 144)
- **Task**: 144 - Update context references after refactor
- **Status**: [COMPLETED]
- **Started**: 2025-12-23
- **Completed**: 2025-12-23
- **Effort**: 2 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: [specs/144_update_context_references_after_refactor/reports/research-001.md](../144_update_context_references_after_refactor/reports/research-001.md)
- **Artifacts**: plans/implementation-002.md (this plan)
- **Standards**: plan.md; status-markers.md; artifact-management.md; tasks.md
- **Language**: markdown
- **Lean Intent**: false
- **Type**: documentation

## Delta (v2)
- Incorporates concrete old→new mappings and per-file targets from the research report.
- Emphasizes Lean overlay rename (`proof-conventions-lean.md`) and canonical logic standards.
- Adds explicit link/path validation step for touched files.

## Overview
Apply the post-refactor mapping to agent/command documentation so all context references point to the normalized `.opencode/context` layout. Normalize references to canonical logic standards vs the Lean overlay, update command/agent context lists, and remove legacy `core/` or root `lean4/` paths.

## Objectives
- Replace legacy context paths with the normalized `common/` + `project/{logic,lean4,...}` structure.
- Point proof/notation to canonical logic standards; point Lean-specific guidance to the Lean overlay file.
- Refresh agent/command docs to cite `context/README.md` and `context/index.md` as authoritative maps.
- Run link/path validation after edits.

## Scope
- Agent/command markdown under `.opencode/agent/` and `.opencode/command/` (per-file list below).
- Documentation touch-ups limited to context-reference narratives (no code changes).

## Inputs
- Research: `specs/144_update_context_references_after_refactor/reports/research-001.md`
- Updated context structure (Task 143): `common/` vs `project/{logic,lean4,math,physics,repo}`, Lean overlay rename, refreshed `context/index.md` and `context/README.md`.

## Risks & Mitigations
- **Missed references** → ripgrep sweeps for `core/`, root `context/lean4`, and the old proof conventions filename.
- **Broken links** → run link/path validation after edits (markdown link checker or Python path scan).
- **Plan drift** → limit edits to listed files; capture outcomes in summary.

## Phases & Tasks

### Phase 1: Prepare mapping & targets [COMPLETED] [PASS]
- [x] Confirm old→new mapping:
  - `core/...` → `common/...`
  - `context/lean4/...` → `context/project/lean4/...`
  - `context/logic/...` → `context/project/logic/...`
  - `project/lean4/standards/proof-conventions.md` → `project/lean4/standards/proof-conventions-lean.md`
  - Canonical proof/notation: `project/logic/standards/{proof-conventions.md, notation-standards.md}`
- [x] Enumerate files to touch (from research):
  - Agents: `orchestrator.md`, `subagents/context-analyzer.md`, `subagents/context-refactor.md`, `subagents/context-references.md`, `subagents/lean-implementation-orchestrator.md`, `subagents/verification-specialist.md`
  - Commands/docs: `command/meta.md`, `command/document.md`, `command/refactor.md`, `command/review.md`, `command/README.md`, `command/context.md`

### Phase 2: Apply reference updates [COMPLETED] [PASS]
- [x] Replace legacy prefixes and update context lists to explicit domains (`common/` + `project/{logic|lean4}`) per file above.
- [x] Update Lean proof conventions references to the overlay file; keep canonical proof/notation pointing to logic standards.
- [x] Refresh narrative pointers to `context/README.md` and `context/index.md` as authoritative maps.

### Phase 3: Verify links and document results [COMPLETED] [PASS]
- [x] Run path validation via ripgrep for legacy prefixes (`core/`, root `context/lean4`, old proof-conventions filename) across agents/commands; no remaining hits after updates.
- [x] Capture outcomes and remaining issues in task summary (see implementation-summary-20251223.md).

## Deliverables
- Updated agent/command markdown with correct context references.
- Verification notes (link/path check results) captured in task notes/summary.

## Notes
- Keep task status markers aligned across TODO/state.
- No new directories beyond existing plan location; plan stays with prior context-reference artifacts.
