# Phase 20 handoff — the transitional layer deleted; documentation

**Status**: [COMPLETED]. This is the plan's last phase; task 512's 21 phases are all closed.

## Final verification (all on the final tree)
- `lake build` exit 0, zero errors. Full rebuild, isolated: **327 s** (baseline 403 s).
- `lake build BimodalTest` exit 0.
- `scripts/check-module-invariants.sh` (full, with build): **ALL CHECKS PASSED**, C3 structural
  sorry inventory zero, C11 archive imports resolve, C12/C13 markdown links resolve, C15 all 46
  paper anchors resolve.
- C2 flagship axiom profiles, all four, checked per theorem:
  `completeness`, `completeness_dense`, `completeness_discrete`,
  `Chronicle.countermodel_dense` = `[propext, Classical.choice, Quot.sound]`.
- `grep -rn "ParamTaskFrame\|ParamFiniteTaskFrame\|ofParam\|toParam" FormalSystem Tests` → empty.
- `grep -rn "ValidOver" FormalSystem` → empty.

## Two open items handed on, neither a defect in this tree

1. **`scripts/check-paper-definitions.sh` exits 1** — *source-paper* drift, not tree drift. It
   reports a new `def:time-shift-histories` in the live paper and two anchors whose environment
   structure moved (`def:frame#Spherical`, `cor:spherical-finite`). Task 512 touched no
   `typst/`, `latex/` or `specs/paper-definitions-of-record.md` file (verified by
   `git diff --name-only` across the whole dispatch). Whoever re-pins the record owns this.
2. **`Tests/BimodalTest/Semantics/SemanticBenchmark.lean` does not elaborate** and has not since
   before task 512 (verified against `92c26855e`). It writes `Formula.atom_s` (the declaration is
   `atomS`) and compares an `Atom`-typed valuation argument to a `String` literal, ~20 sites. It
   is unimported, so `lake build` does not cover it. Its own task.

## For task 507 (names)
- `realOrder` / `ratOrder` were deliberately not introduced. A single `ratOrder` must live in
  `Semantics/TemporalOrder.lean` to be visible to both `BXCanonical` and `Independence`, and that
  module cannot state `⟨Rat⟩` without a new Mathlib import in the transitive closure of every
  module in the tree. Present spelling: `TemporalOrder.of ℝ` / `of ℚ` / `of (ℚ ×ₗ ℤ)`, all
  `@[reducible]`. 507 owns the naming call.
- Two renames already forced by Phase 18's `ValidOver` deletion: `ValidOverInt` → `ValidOnInt`,
  `valid_over_Int_of_valid_discrete` → `valid_on_Int_of_valid_discrete`.
- `FrameConditions.LinearTemporalFrame` (`FrameClass.lean:88`) is redundant under this design:
  a `Prop` class over `(D : Type)` carrying three of `TemporalOrder`'s four components as binders
  and no fields. 507/513 territory; untouched.

## For task 510
`class TemporalCarrier (fc) (D) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
[Nontrivial D]` (`Decidability/Verified/Bridge/Carrier.lean:126`) carries exactly the four binders
`TemporalOrder` bundles, so it may reduce to `(fc : FrameClass) (D : TemporalOrder)` plus its two
genuine fields — possibly shrinking 510 to a merge. Recorded, not acted on.

## For task 513 / 507 (base change)
Phase 8's verdict stands and is unchanged: `IntTransfer.lean` is base change along
**isomorphisms** only, and the restriction is forced — *Limit* uses `map_lt_map_iff` in both
directions. No general base-change theory was added. Size that honestly.
