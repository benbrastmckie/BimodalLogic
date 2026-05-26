# Phase 2 Handoff: RRelation.lean Parameterization

## Status
Phase 1 (ChronicleTypes.lean): COMPLETED
Phase 2 (RRelation.lean): IN PROGRESS (~85% done, 11 errors remaining)
Bundle.WitnessSeed: COMPLETED (parameterized 4 utility functions)
Theorems.GeneralizedNecessitation: COMPLETED (parameterized past_necessitation, past_k_dist)

## What Was Done

### Phase 1 (COMPLETE)
- All 16 `FrameClass.Base` refs in ChronicleTypes.lean replaced with explicit `(fc : FrameClass)` parameter
- Definitions parameterized: `ClosedUnderDerivation`, `SetDeductivelyClosed`, `BurgessR3Maximal`, `rMaximal`, `R3Maximal`, `R3MaximalSince`, `rMaximalSince`, `Chronicle.c0`, `Chronicle.c1`, `Chronicle.c2'`, `ValidChronicle`, `ChronicleInvariant`, and all DCS intersection theorems
- Base-level Theorems.* derivations wrapped with `DerivationTree.lift (fc₁ := .Base) trivial`
- File compiles with 0 errors, 0 sorries

### Bundle.WitnessSeed (COMPLETE)
- Parameterized 4 functions over `{fc : FrameClass}`:
  - `some_future_all_future_neg_absurd`
  - `some_past_all_past_neg_absurd`
  - `neg_some_future_to_all_future_neg`
  - `neg_some_past_to_all_past_neg`
- Pattern: keep derivation chain at `⊢` (Base), lift final result with `DerivationTree.lift (fc₁ := .Base) trivial`
- All existing callers at `.Base` still compile (fc inferred as `.Base`)

### Phase 2 (IN PROGRESS)
- Script applied: replaced 103 `FrameClass.Base` with `fc`, added `(fc : FrameClass)` to 53 definitions/theorems
- Fixed: private theorem signatures, local function calls with explicit `fc`, Bundle function calls
- 29 errors remain, all of type "Application type mismatch" -- Base-level derivations need `DerivationTree.lift (fc₁ := .Base) trivial`

## Design Decisions

1. **Explicit `(fc : FrameClass)` over implicit**: Used explicit parameter on all definitions that return `Prop` or `Set Formula` (no type-level `fc` evidence for inference). Theorems use `(fc : FrameClass)` since implicit `{fc}` can't always be inferred.

2. **DerivationTree.lift pattern**: When a theorem uses `theorem_in_mcs h_mcs d` where `d` is built from `Bimodal.Theorems.*` (Base-level), wrap as:
   ```lean
   theorem_in_mcs h_mcs (DerivationTree.lift (fc₁ := .Base) trivial d_base)
   ```

3. **past_necessitation / past_k_dist pattern**: When these Base-level functions take an inner derivation, the inner derivation must ALSO be Base-level. Use:
   ```lean
   DerivationTree.lift (fc₁ := .Base) trivial
     (Bimodal.Theorems.past_necessitation _
       (DerivationTree.axiom (fc := .Base) [] _ (Axiom.foo bar) trivial))
   ```

4. **No `variable` approach**: Lean 4's `variable` auto-inserts into declaration parameter lists but NOT into expressions/bodies. With explicit parameters everywhere, callers must pass `fc`.

## Critical Next Step

The remaining 11 errors all stem from one root cause: `Bimodal.Theorems.Combinators` functions (`imp_trans`, `mp`, `combine_imp_conj`) produce `DerivationTree FrameClass.Base [] ...` but the Chronicle pipeline now needs `DerivationTree fc [] ...`.

**Recommended fix**: Parameterize `imp_trans`, `mp`, and `combine_imp_conj` in `Combinators.lean` with `{fc : FrameClass}`, replacing `trivial` axiom gates with `base_le fc`. This is safe because all axioms used (prop_s, prop_k) have `minFrameClass = .Base`, so `base_le fc` proves the gate. The `base_le` helper is already defined in ChronicleTypes.lean but should be moved to a more foundational location (e.g., near the FrameClass definition in Axioms.lean or a new Core module).

**Alternative** (if Combinators changes cascade too far): Use `liftBase fc` at each call site. For `imp_trans h1 h2` where `h1 h2 : DerivationTree fc`, rewrite as `liftBase fc (imp_trans (unlift h1) (unlift h2))` -- but there's no unlift function, so the whole expression would need to be at Base level first.

## Remaining Work (Phase 2)

11 errors in RRelation.lean:
- Lines 664, 719: `past_necessitation`/`past_k_dist` calls where inner axiom needs `(fc := .Base)`
- Lines 902, 950, 991, 995: `theorem_in_mcs` with Base-level derivations not yet lifted
- Lines 931, 977: unsolved goals (likely cascading from type mismatches)
- Lines 1095, 1096: similar pattern
- Lines 1228, 1238, 1248, 1257: in private theorems, Base-level derivations need lift
- Lines 1291, 1324, 1379, 1438, 1440: Bundle calls that may need fc
- Lines 1533, 1549, 1551: additional Base-level derivation lifts needed

## Resumption Protocol

1. Open RRelation.lean at each error line
2. For each `Application type mismatch` where a `⊢ ...` is expected to be `⊢[fc] ...`:
   - Wrap the Base-level derivation with `DerivationTree.lift (fc₁ := .Base) trivial (...)`
   - If the derivation contains inner derivations that should be Base-level (e.g., inside `past_necessitation`), annotate those with `(fc := .Base)` in the `DerivationTree.axiom` calls
3. For `unsolved goals`: these are likely cascading from upstream type mismatches -- fix the type mismatches first
4. Build after each batch of fixes: `lake build Bimodal.Metalogic.BXCanonical.Chronicle.RRelation`
5. Once RRelation compiles (0 errors, 0 new sorries), proceed to Phase 3 (PointInsertion.lean)

## File States

| File | Status | FrameClass.Base remaining |
|------|--------|--------------------------|
| ChronicleTypes.lean | DONE | 0 |
| Bundle/WitnessSeed.lean | DONE | ~many (only 4 functions changed) |
| RRelation.lean | IN PROGRESS | 0 (all replaced, 29 compile errors) |
| PointInsertion.lean | NOT STARTED | 344 |
| CounterexampleElimination.lean | NOT STARTED | 39 |
| ChronicleConstruction.lean | NOT STARTED | 71 |
| ChronicleToCountermodel.lean | NOT STARTED | 124 |
| ReflexiveCanonical.lean | NOT STARTED | 24 |
| TruthLemma.lean | NOT STARTED | 29 |
| FrameProperties.lean | NOT STARTED | 0 (no direct refs, but uses parameterized types) |
| ChronicleExtraction.lean | NOT STARTED | 6 |
| Transfer.lean | NOT STARTED | 1 |
| Completeness.lean | NOT STARTED | 30 |
