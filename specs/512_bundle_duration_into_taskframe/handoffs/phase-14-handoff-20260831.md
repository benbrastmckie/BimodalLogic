# Phase 14 handoff — the decidability bridge

**Status**: [COMPLETED]. `lake build` 0, `lake build BimodalTest` 0,
`check-module-invariants.sh` ALL CHECKS PASSED, zero structural sorry, C2 profiles unchanged.
Green on the first build attempt.

## Immediate next action
Phase 15 — BiLasso.

## Carry-forward
- Two spellings of the fibre now coexist in the tree, on a stated criterion:
  `FrameOver D` for `(D : TemporalOrder)` where the carrier is free (FlowFrame's generic layer,
  the ℤ/ℝ/ℚ concrete fibres), and `FrameOver (TemporalOrder.of D)` over an ambient carrier where
  a neighbouring abstraction pins `D` to a bare type (`BFMCS`, `FrameConditionFor`, `C D`,
  `TemporalCarrier`). Phase 20 should keep `TemporalOrder.of` for that reason.
- Remaining `ParamTaskFrame` tokens in this territory are all namespace references
  (`limit_of_shift`, `sInter_nonempty_of_directed_of_univ_or_singleton`, `trivialFrame`) —
  Phase 20's namespace restoration, not type ascriptions.
- `Propositional/Decidable.lean` needed no edit at all: its 3 occurrences are `trivialFrame`
  namespace references.
- The 510 observation is recorded in the plan and the phase commit.
