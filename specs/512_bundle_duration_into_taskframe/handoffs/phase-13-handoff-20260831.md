# Phase 13 handoff — BXCanonical, Chronicle, and the countermodel bases

**Status**: [COMPLETED]. `lake build` 0, `lake build BimodalTest` 0,
`check-module-invariants.sh` ALL CHECKS PASSED, zero structural sorry.
C2 verified per-theorem: completeness / completeness_dense / completeness_discrete /
Chronicle.countermodel_dense all `[propext, Classical.choice, Quot.sound]`.

## Immediate next action
Phase 14 — the decidability bridge (`Decidability/Verified/Bridge/*`).

## Carry-forward
- The Σ-collapse pattern is now used in four places (Phases 11 and 13). Any remaining
  `∃ (D : Type) (_ : AddCommGroup D) … (F : ParamTaskFrame D)` in the tree should collapse to
  `∃ (F : TaskFrame) … (t : ↑F.Duration)` the same way, and its consumers lose five `_` slots.
- `realOrder` / `ratOrder` are still undeclared, deliberately. A single home for `ratOrder` must
  be `Semantics/TemporalOrder.lean` (no lower common ancestor of BXCanonical and Independence),
  and that module cannot currently state `⟨Rat⟩` — probed: `failed to synthesize AddCommGroup Rat`.
  Declaring them means a tree-wide import addition. Phase 20 already pays a full rebuild; decide
  it there. Meanwhile Phase 16 should use `TemporalOrder.of ℚ` for `ClockFrame`, matching
  Phase 13's spelling, and NOT declare a local `ratOrder` (it would collide with Phase 20's).

## Deviations
- `FrameOver realOrder` → `FrameOver (TemporalOrder.of ℝ)` (and the `ℚ ×ₗ ℤ` analogue).
