# Context Organization

## Overview
Unified context layout for the Logos project. Shared standards and system guides live in `common/`; domain-specific guidance lives in `project/` by domain (logic, lean4, math, physics, repo). Logic standards are canonical for proof principles and notation; Lean overlays add syntax/tooling/readability only.

## Directory Structure
```
.opencode/context/
  common/          # Shared standards, system guides, workflows, templates
    standards/     # code, docs, tests, patterns, plan/report/summary/tasks
    system/        # artifact-management, status-markers, state-schema, context-guide
    templates/     # meta and agent templates
    workflows/     # delegation, review, sessions, task-breakdown
  project/         # Domain-specific context
    logic/         # Canonical proof principles, notation, strategies
    lean4/         # Lean overlays (syntax, tooling, readability)
    math/          # Math domains (algebra, lattice, order, topology)
    physics/       # Physics domains (dynamical systems)
    repo/          # Repository overview
  README.md
  index.md
```

## Canonical vs. Overlay
- **Canonical proof/notation**: `project/logic/standards/proof-conventions.md`, `project/logic/standards/notation-standards.md`.
- **Lean overlay**: `project/lean4/standards/proof-conventions-lean.md` (references the canonical logic standards), plus Lean style/readability/patterns.
- **System standards**: `common/system/status-markers.md`, `common/system/artifact-management.md` (do not duplicate in domain files).

## Usage Guidelines
- Default to Level 1 context loads (1–2 files); Level 2 (3–4) only when needed; Level 3 rarely.
- For Lean proofs: load logic canonical standards + Lean overlay as needed.
- Keep links targeting `project/{logic|lean4|math|physics|repo}` and `common/...`; avoid legacy `core/` or root `lean4/` references.
- File naming: lowercase-hyphenated (`proof-theory-concepts.md`).
- Keep files focused (target 50–200 lines) and avoid duplication—point to shared standards instead.

## Maintenance Notes
- When adding domain guidance, first check for existing standards in `common/` and `project/logic/` to avoid duplication.
- Status markers, artifact rules, and task metadata belong in `common/system/`—reference them instead of copying.
- Record moves/renames in the plan/summary for Task 144 to update agent/command references.
