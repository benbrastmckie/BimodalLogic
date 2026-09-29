# Phases 4 and 5 handoff — task 696

- **Phases**: 4 (Formula-side insulation) and 5 (Plus-side insulation) — both COMPLETED
- **Next action**: Phase 6, the substrate switch: `Thread.step` becomes `trans`, `Thread.const`
  is rebuilt from `trans_refl'`, `total_eq_thread` is reproved from `lift`, and
  `succF`/`predF` start filtering on `trans`.

## What landed

`thread_share_succ` now exists at three levels — `SharingSkeleton`, `SharingWitnessFamily`, and
`PlusSharingWitnessFamily` — each stating `share (u+1) (idx u) (idx (u+1))` and each currently
proved by the step field itself. Every consumer that read a thread's step as a sharing fact now
goes through it: `Skeleton.Thread.step'`, `Sharing/Fulfil.lean`'s `untl_thread_step`,
`thread_share_pred`, `snce_thread_step` and the `window_of_threadFulfilling` escape edge,
`Sharing/Agreement.lean`'s along-thread lemma, `Specialize.lean`'s diagonal-constancy lemma, and
the four Plus-side twins.

The two family-level `Thread.step` theorems keep their statements for now, so nothing downstream
moved. Phase 6 flips them and redefines `thread_share_succ` as the arrival-pruning projection
`(θ.step u).2`, at which point every consumer above keeps working with no further edit. That is
the whole point of these two phases.

## Two recorded scope findings

The checklist grep returns 42 hits (34 Formula, 8 Plus), not round 2's 36. The excess is entirely
the Phase 2 and Phase 3 additions' own occurrences, not uncatalogued consumers.

`Sharing/Window.lean`'s `share_succ`/`walkIdx_step` sites needed no Phase 4 edit: the walks
*produce* threads rather than consuming them, and `walkIdx_step`'s only consumer anywhere in the
tree is the `step :=` field of the thread it builds. Those four sites are Phase 6 definition-site
work.

## Verification

`lake build` green after each phase (2771 jobs both times).
`scripts/check-module-invariants.sh` C2 passes at nineteen, unchanged.
Every diff hunk across `FormalSystem/` is a proof term or a docstring: no theorem statement
changed, and `plusTruth_iff_mem` / `plusRefutes_of_certifies` are untouched in the diff.
