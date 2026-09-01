# Phase 18 handoff — `FrameConditions/`, `ValidOver` deletion, aggregators

**Status**: [COMPLETED]. Build 0 (first attempt), test build 0, invariants ALL CHECKS PASSED,
zero sorry.

## Immediate next action
Phase 19 — Tests.

## Carry-forward
- `ValidOver` and its `⊨[D] φ` notation are gone tree-wide, prose included.
  `ValidOverInt` → `ValidOnInt`, `valid_over_Int_of_valid_discrete` →
  `valid_on_Int_of_valid_discrete` (forced renames — the old names named a deleted definition).
- The restatement idiom, reusable in Phase 19: a predicate written
  `∀ (F : …) (M) (τ : WorldHistory F) (_ : τ.IsTotal) (t), TruthAt M τ t φ` becomes
  `∀ (F : …), F.toTaskFrame.ValidOn φ`, and every proof adapts by exchanging the
  `(τ) (hτ)` pair for `HF`'s `τ.val` / `τ.property`. No new lemma is needed.
- Recorded for 507/513: `FrameConditions.LinearTemporalFrame` (`FrameClass.lean:88`) carries
  three of `TemporalOrder`'s four components as binders and has no fields — redundant under this
  design. Not touched.
