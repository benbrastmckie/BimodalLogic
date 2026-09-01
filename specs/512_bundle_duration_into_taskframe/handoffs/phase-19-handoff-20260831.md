# Phase 19 handoff — Tests

**Status**: [COMPLETED]. `lake build` 0, `lake build BimodalTest` 0, invariants ALL CHECKS
PASSED, zero sorry.

## Immediate next action
Phase 20 — delete the transitional layer; documentation. This is the last phase and the biggest.

## What Phase 20 must do (accumulated evidence)
1. **Relocate `namespace ParamTaskFrame`'s whole block** out of `Semantics/TaskFrame.lean` into
   `FrameOver` / `TaskFrame`. This is what restores dot notation tree-wide; without it, every
   `F.nullity` / `F.forward_comp` on a fibre-typed frame needs a qualified call. Phases 17 and 19
   both had to add such qualifications (2 sites and 7 sites respectively) — those can be reverted
   to dot notation once the block moves. Known members: `forward_comp`, `interpolates`, `nullity`,
   `backward_comp`, `limit_of_shift`, `limit_of_succOrder`, `limit_of_subsingleton`,
   `limit_of_permissive`, `spherical_of_finite`, `spherical_of_subsingleton`,
   `spherical_of_permissive`, `serial_of_total`, `serial_of_permissive`,
   `interpolates_of_total`, `interpolates_of_permissive`,
   `sInter_nonempty_of_directed_of_univ_or_singleton`,
   `sInter_nonempty_of_directed_of_minimal`, `exists_uniform_radius_of_finite`,
   `trivialFrame`, `staticFrame`, `natFrame`, `HF.isStepPath`, `map`.
2. Delete `ParamTaskFrame`, `ParamFiniteTaskFrame`, `ofParam`, `toParam`,
   `instCoeOutParamTaskFrame`. Keep `instCoeOutFrameOver` (added in Phase 12) — it is the
   permanent replacement.
3. **Keep `TemporalOrder.of`.** Phases 12, 14 and 17 all rely on it for ambient-carrier frames
   whose `D` is pinned by `BFMCS` / `FrameConditionFor` / `C D` / `TemporalCarrier`.
4. Decide `realOrder` / `ratOrder` (see the Phase 13 Record): a single home must be
   `Semantics/TemporalOrder.lean`, which needs a new Mathlib import there. Phase 20 pays a full
   rebuild anyway, so measure the wall-time delta against the Phase 0 baseline (403 s) in the
   same run.
5. `TaskFrame.lean` + `TemporalOrder.lean` module docstrings; the docs/ + README markdown sweep.

## Follow-up, out of scope for task 512
`Tests/BimodalTest/Semantics/SemanticBenchmark.lean` does not elaborate and has not since before
this task (verified against `92c26855e`). It writes `Formula.atom_s` (the declaration is `atomS`)
and compares an `Atom`-typed valuation argument to a `String` literal, at ~20 sites. It is not
imported by the test aggregator, so `lake build` does not cover it. Rehabilitating it is a
content change and belongs in its own task.
