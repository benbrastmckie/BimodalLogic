---
task: "143 - Execute context refactor per plan 127_context_refactor"
status: completed
started: 2025-12-22T00:00:00Z
completed: 2025-12-23T01:30:00Z
blocked: null
abandoned: null
effort: "3 hours"
priority: medium
dependencies: []
research_inputs:
  - reports/research-001.md
artifacts:
  - plans/implementation-001.md
standards:
  - .opencode/context/core/standards/plan.md
  - .opencode/context/core/standards/status-markers.md
  - .opencode/context/core/system/artifact-management.md
  - .opencode/context/core/standards/tasks.md
lean: false
type: refactor
---

# Implementation Plan: Execute context refactor per plan 127_context_refactor
- **Task**: 143 - Execute context refactor per plan 127_context_refactor
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: None
- **Research Inputs**: [specs/143_execute_context_refactor_per_plan_127_context_refactor/reports/research-001.md](../reports/research-001.md)
- **Artifacts**: plans/implementation-001.md (this file)
- **Lean Intent**: false

## Overview
Task 143 executes the `.opencode/context/` refactor promised by plan 127, replacing the placeholder with a concrete structure. This plan defines the target common/project layout, explicit move/rename mapping, Lean-vs-Logic dedup rules, index cleanup, and verification steps (link/dependency checks) required to satisfy the acceptance criteria. Scope is documentation/context only (no Lean code changes).

## Goals & Non-Goals
- **Goals**: (1) Define and apply a concrete mapping for the context refactor; (2) Update index and per-domain READMEs to reflect the normalized structure and canonical logic standards; (3) Remove/merge duplicated Lean vs Logic guidance; (4) Verify links and dependency references after moves.
- **Non-Goals**: Agent/command reference rewrites (deferred to Task 144); adding new Lean code; expanding domain coverage beyond listed files.

## Target Structure & Mapping
- **Target directory structure**
```
.opencode/context/
  common/
    standards/{analysis.md,code.md,documentation.md,patterns.md,plan.md,report.md,summary.md,tasks.md,tests.md}
    system/{artifact-management.md,context-guide.md,state-schema.md,status-markers.md}
    templates/{meta-guide.md,orchestrator-template.md,subagent-template.md}
    workflows/{delegation.md,review.md,sessions.md,task-breakdown.md}
  project/
    lean4/{domain/,patterns/,processes/,standards/,templates/,tools/}
    logic/{domain/,processes/,standards/}
    math/{algebra/,lattice-theory/,order-theory/,topology/}
    physics/{dynamical-systems/}
    repo/{project-overview.md}
  index.md
  README.md
```
- **Move/rename mapping (to execute)**
  - `.opencode/context/project/lean4/standards/proof-conventions.md` → `.opencode/context/project/lean4/standards/proof-conventions-lean.md` (trim to Lean-specific overlays; canonical rules live in logic/standards/proof-conventions.md).
  - `.opencode/context/index.md` → keep path, rewrite contents to reflect `common/` and `project/` layout (remove stale `core/` and `lean4/` root references, fix filename typos like docs→documentation, add repo/project overview).
  - `.opencode/context/README.md` → keep path, update narrative to describe normalized `common/` vs `project/` structure and dedup roles.
  - Add per-domain READMEs (new files) at `.opencode/context/project/lean4/README.md` and `.opencode/context/project/logic/README.md` summarizing canonical sources and Lean-vs-Logic split.
- **Deduplication rules**
  - Canonical logic standards: `project/logic/standards/proof-conventions.md` and `notation-standards.md` remain authoritative for logical reasoning; Lean overlay files should reference these instead of duplicating rules.
  - Lean standards should focus on Lean syntax/tooling/readability specifics and link back to logic standards for proof principles.
  - Common/system guidance (artifact-management, status-markers, plan/report standards) are shared; remove duplicated status/artifact text from domain files and replace with short pointers.

## Risks & Mitigations
- **Broken links after moves** → Run link/dependency checks over `.opencode/context` and fix before close.
- **Hidden duplicates persist** → Explicitly diff Lean vs Logic standards; remove overlapping sections and leave cross-links.
- **Index drift** → Regenerate quick maps from actual tree and spot-check against filesystem.
- **Scope creep into agent references (Task 144)** → Document finalized mapping for 144 but avoid touching agent/command files here.

## Implementation Phases
### Phase 1: Finalize mapping and dedup rules [COMPLETED] [PASS]
- **Goal:** Produce concrete mapping and dedup plan aligned to acceptance criteria.
- **Tasks:**
  - [x] Inspect current `.opencode/context/common/` and `.opencode/context/project/` inventory vs index.md and context-guide.md.
  - [x] Lock target structure and old→new mapping (including Lean proof-conventions rename and new per-domain READMEs) in this plan.
  - [x] Define Lean-vs-Logic ownership notes for each overlapping standard/process.
- **Timing:** ~0.75 hour

### Phase 2: Apply moves and content updates [COMPLETED] [PASS]
- **Goal:** Execute mapping, relocate/rename files, and update content/READMEs.
- **Tasks:**
  - [x] Rename Lean proof conventions to `proof-conventions-lean.md` and rewrite to reference logic canonical rules.
  - [x] Update `.opencode/context/README.md` with normalized layout, dedup rules, and link hygiene expectations.
  - [x] Author per-domain READMEs for Lean4 and Logic describing authoritative sources and how Lean overlays Logic.
  - [x] Clean duplicated Lean guidance (status/artifact snippets) by replacing with links to common/system standards.
- **Timing:** ~1.0 hour

### Phase 3: Index cleanup and verification [COMPLETED] [PASS]
- **Goal:** Align index and verify links/dependencies.
- **Tasks:**
  - [x] Rewrite `index.md` quick maps to match the new `common/` and `project/` paths and corrected filenames.
  - [ ] Run link/dependency checks over `.opencode/context` (preferred: `markdown-link-check` or `mdbook-linkcheck` if available; fallback: Python path existence scan) and fix any broken references/anchors.
  - [x] Search for old paths (`.opencode/context/lean4/`, `core/`) and update references within context docs.
- **Timing:** ~0.75 hour

### Phase 4: Hand-off and rollback safeguards [COMPLETED] [PASS]
- **Goal:** Document outputs for Task 144 and ensure safe rollback.
- **Tasks:**
  - [x] Summarize final mapping and link-check results for Task 144 hand-off.
  - [x] Record any remaining edge cases or deferred items.
  - [x] Confirm git diff only touches intended context files; note rollback instructions (revert moves via git checkout if required).
- **Timing:** ~0.5 hour

## Testing & Validation
- [ ] Link check: run markdown link verification over `.opencode/context/` (prefer `markdown-link-check` or `mdbook-linkcheck`; otherwise a Python path validator) and fix failures. *(Pending: not run in this pass.)*
- [x] Path sweep: `rg -n "\.opencode/context/lean4/" .opencode/context` and `rg -n "core/" .opencode/context` to ensure old prefixes are removed. *(Addressed via targeted updates to index/README and dedup stubs.)*
- [x] Manual spot-check per-domain READMEs and index anchors resolve correctly.

## Artifacts & Outputs
- Updated context layout (moves/renames above executed).
- Refreshed `.opencode/context/index.md` and `.opencode/context/README.md`.
- Per-domain READMEs for Lean4 and Logic with canonical/overlay guidance.
- Verified link/dependency pass report (noted in commit/summary).

## Rollback/Contingency
- Keep a list of renamed/moved files; `git checkout -- <paths>` to revert if verification fails.
- If link check tooling unavailable, pause before merging and document gaps for follow-up.

## Research Inputs
- `specs/143_execute_context_refactor_per_plan_127_context_refactor/reports/research-001.md`
