---
task: "144 - Update context references after refactor"
status: not_started
started: null
completed: null
blocked: null
abandoned: null
effort: "2 hours"
priority: medium
dependencies: []
research_inputs:
  - specs/144_update_context_references_after_refactor/reports/research-001.md
artifacts:
  - plans/implementation-001.md
standards:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
lean: false
type: documentation
---

# Implementation Plan: Update context references after refactor (Task 144)
- **Task**: 144 - Update context references after refactor
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: Medium
- **Language**: markdown
- **Research Inputs**: [specs/144_update_context_references_after_refactor/reports/research-001.md](../144_update_context_references_after_refactor/reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this plan)
- **Lean Intent**: false

## Overview
Apply the post-refactor mapping to agent/command documentation so all context references point to the new `.opencode/context` layout. Normalize references to the canonical logic standards vs the Lean overlay, update command/agent context lists, and remove legacy `core/` or root `lean4/` paths.

## Objectives
- Replace legacy context paths with the normalized `common/` + `project/{logic,lean4,...}` structure.
- Point proof/notation to canonical logic standards; point Lean-specific guidance to the Lean overlay file.
- Refresh agent/command docs to cite `context/README.md` and `index.md` as authoritative maps.
- Run link/path validation after edits.

## Scope
- Agent/command markdown under `.opencode/agent/` and `.opencode/command/` (see per-file list below).
- Documentation touch-ups limited to context-reference narratives (no code changes).

## Inputs
- Research report: `specs/144_update_context_references_after_refactor/reports/research-001.md`
- Updated context structure (from Task 143): `common/` vs `project/{logic,lean4,math,physics,repo}`, Lean overlay file rename, refreshed `context/index.md` and `context/README.md`.

## Risks & Mitigations
- **Missed references**: Mitigate via ripgrep sweeps for `core/` and root `context/lean4` prefixes and for the old proof conventions filename.
- **Broken links**: Run link/path validation after edits (markdown link checker or Python path scan).
- **Plan drift**: Keep updates limited to listed files; record mapping in summary.

## Phases & Tasks

### Phase 1: Prepare mapping & targets [NOT STARTED]
- [ ] Confirm old→new mapping:
  - `core/...` → `common/...`
  - `context/lean4/...` → `context/project/lean4/...`
  - `context/logic/...` → `context/project/logic/...`
  - `project/lean4/standards/proof-conventions.md` → `project/lean4/standards/proof-conventions-lean.md`
  - Canonical proof/notation: `project/logic/standards/{proof-conventions.md, notation-standards.md}`
- [ ] Enumerate files (from research) to touch:
  - Agents: `orchestrator.md`, `subagents/context-analyzer.md`, `subagents/context-refactor.md`, `subagents/context-references.md`, `subagents/lean-implementation-orchestrator.md`
  - Commands/docs: `command/meta.md`, `command/document.md`, `command/refactor.md`, `command/review.md`, `command/README.md`, `command/context.md`

### Phase 2: Apply reference updates [NOT STARTED]
- [ ] Replace legacy prefixes and update lists to explicit domains (`common/` + `project/{logic|lean4}`) per file above.
- [ ] Update Lean proof conventions references to the overlay file; keep canonical proof/notation pointing to logic standards.
- [ ] Refresh narrative pointers to `context/README.md` and `context/index.md` as authoritative maps.

### Phase 3: Verify links and document results [NOT STARTED]
- [ ] Run link/path validation over touched files and `.opencode/context/` (markdown link checker or Python path scan); fix any failures.
- [ ] Capture outcomes and remaining issues in the task summary (or TODO acceptance notes).

## Deliverables
- Updated agent/command markdown with correct context references.
- Verification notes (link/path check results) captured in task notes/summary.

## Notes
- Keep task status markers aligned across TODO/state.
- No new directories beyond existing plan location; plan lives beside prior context-reference plan.
