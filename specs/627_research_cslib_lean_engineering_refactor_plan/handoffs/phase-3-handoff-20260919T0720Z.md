# Phase 3 Handoff: ADR-010 and ADR-011 (Proposed)

- **Task**: 627
- **Phases closed**: 1 and 3 of 4 (Phase 3 taken before Phase 2: cheaper, and it lets the
  programme document link to the ADRs without a dangling C13 link)
- **Session**: sess_1789799001_60286d
- **Next action**: open Phase 2 (`docs/development/PUBLICATION_REFACTOR.md`, README row,
  re-link the backticked mention in `MODULE_INVARIANTS.md`), then Phase 4.

## State

- New: `docs/architecture/ADR-010-Boneyard-At-Repository-Root.md`,
  `docs/architecture/ADR-011-Extract-Expressiveness.md` (both `**Proposed** - 2026-09-19`,
  five standard sections).
- Edited: `docs/architecture/README.md` (catalog rows + details paragraphs + note),
  `ADR-006` and `ADR-009` (one Status paragraph each; `**Accepted**` unchanged).
- Both ADRs mention `docs/development/PUBLICATION_REFACTOR.md` in backticks only (file not yet
  present); Phase 2 may convert those to links or leave them.
- `bash scripts/check-module-invariants.sh --no-build` exit 0 after Phase 3.
- Library tree still untouched by this task (the two pre-existing README one-liners remain
  unstaged).

## Conventions kept (see Phase 1 handoff)

Relative hypothetical paths; no `FormalSystem.`-prefixed future module names; no task numbers;
no literal paper anchors; no `File.lean:NNN`; no stale axiom-count shapes.
