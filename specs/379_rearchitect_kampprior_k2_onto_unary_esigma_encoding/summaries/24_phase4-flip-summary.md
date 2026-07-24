# Phase 4-flip Implementation Summary — Terminal `sigE` Summand Flip

- **Task**: 379 — `rearchitect_kampprior_k2_onto_unary_esigma_encoding`
- **Plan**: `plans/24_restore-offpath-chain-then-bridge.md`, Phase 4-flip (closes parent Phase 4)
- **Session**: sess_1784869380_2459bd
- **Date**: 2026-07-23

## What Was Done

Sub-phase 4-flip ONLY (per single-phase dispatch): the terminal summand flip making `sigE`
the infinite E[Σ] alphabet of Rabinovich Def 4.1 (PDF p.5).

### `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaExpansion.lean`
- `sigE sig F` fresh summand: `{A // A ∈ F}` → `Formula` (F retained as `_F`, a pure
  type-level stage index — downstream arities unchanged).
- `esigmaPred A` — no `hA : A ∈ F` proof (`Sum.inr A`).
- Deleted `sigE_fintypePreds` (no `Fintype` exists for the infinite alphabet) and the
  unconsumed staging helper `finite_F_suffices_per_stage`.
- `sigE_decEqPreds` survives via `Formula`'s derived `DecidableEq`.
- `canonExpand` match arm `.inr A => sat A a`; `atom_eval_new` hA-dropped; docstrings
  re-anchored to the infinite Def 4.1 alphabet.

### `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ESigmaCapture.lean`
- DELETED the finite-alphabet interval-capture trio `intervalCapture_of_atomNamed` /
  `intervalCapture_forall_mem` / `esigmaCapture_canonExpand` (whole-alphabet
  `Finset.univ.filter` witness — uninhabitable post-flip; zero code consumers; Phase 5
  removes `hCapture`/`capFn` entirely). Forced by the phase's own Prohibited clause
  ("no full-alphabet `Finset.univ`") + DoD; annotated as a deviation in the plan.
- KEPT `temporal_truth_canonExpand` (conservativity, verbatim) and `canonExpand_atom_named`
  — now unconditional: holds for EVERY `Formula` (the fact Phase 5's direct discharge uses).

### `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ZetaAtomMapReconcile.lean`
- Mechanical hA-drop fallout: `collapse_leaf_fresh`, `reconciled_no_surj_onto_inr`
  (anticipated by the plan's survival table).

## Verification (final gate)

| Check | Result |
|-------|--------|
| Full `lake build` | EXIT 0, 1772 jobs (job count identical to 4c baseline) |
| Task-zone sorries | exactly the 3 charter-permitted (KampPrior `_k+2` ~:562; EANegation :1090, :1249) |
| New sorries / vacuous defs / new axioms | 0 / 0 / 0 (single vacuous-pattern grep hit is pre-existing, `Examples/TemporalStructures.lean:269`, outside task zone) |
| `#print axioms completeness_discrete` | byte-identical to baseline: `[propext, sorryAx, Classical.choice, Lean.ofReduceBool, Lean.trustCompiler, Quot.sound]` |
| Flipped decls axiom check | `[propext, Classical.choice, Quot.sound]` — clean |
| Spine-safety grep (`sigE`/`UnaryType`/`IntervalType` in `BXCanonical/`+`Decidability/`) | EMPTY |
| Off-path scoped builds | ESigmaExpansion, ESigmaCapture, ZetaAtomMapReconcile, MonadicFormulaMap all green |

## Commits

- `728e0586c` — task 379 phase 4-flip: sigE fresh summand {A // A in F} -> Formula
- `0ce5987e6` — task 379 phase 4-flip: ZetaAtomMapReconcile hA-drop fallout

## Plan Deviations

1. Interval-capture trio deleted (altered scope of the "update atom-naming" task) — forced by
   the phase Prohibited clause; documented inline in the plan's 4-flip checklist.
2. `finite_F_suffices_per_stage` deleted alongside `sigE_fintypePreds` (unconsumed, staging
   rationale retired by the flip).
3. `ZetaAtomMapReconcile.lean` added to files-modified (mechanical hA fallout, anticipated by
   the plan's Phase-4 survival table).

## Status

Phase 4-flip [COMPLETED]; parent Phase 4 [COMPLETED]. Remaining: Phase 5 (ζ re-wire,
live-path, retires the `_k+2` residual LAST).
