# Phase 3 handoff (ROADMAP A4) — ROADMAP track COMPLETE

**Next action**: Phase 4 — `FormalSystem/Metalogic/README.md` B1 (C2 pointer at `:213-218`) and
B2 (sorry inventory `:233-248`). The README track is untouched so far; its plan line numbers are
still valid.

**State**: `specs/ROADMAP.md` fully corrected (A1+D1, A2/A3+D2, A4). C2 baseline block is now
`:359-373`.

**Verified at implementation time**:
- `lean_verify FormalSystem.Metalogic.completeness_dedekind` -> `[propext, Classical.choice, Quot.sound]`.
- Declaration is at `StrongCompleteness.lean:469` (namespace `FormalSystem.Metalogic` opens `:139`).
- C2's baseline (`scripts/check-module-invariants.sh:127-132`) lists exactly four theorems;
  `completeness_dedekind` is not among them. It is recorded typographically separate.

**C5 note for the README track**: C5's regex is
`\b(?:FormalSystem|BimodalTest)(?:\.[A-Z][A-Za-z0-9_]*)+` and it SKIPS `specs/`. The README is in
scope for C5; every module-shaped path written there must resolve to a `.lean` file or directory.
