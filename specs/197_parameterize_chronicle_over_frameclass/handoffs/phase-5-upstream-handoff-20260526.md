# Phase 5 Upstream Parameterization Handoff

## Status
- Phase 5: PARTIAL (upstream parameterization complete, ChronicleToCountermodel.lean has 88 errors remaining)

## What Was Done

### Upstream Parameterization (COMPLETE -- all build clean)

Parameterized the entire Algebraic/Bundle layer over `{fc : FrameClass}` so that the Chronicle pipeline can use arbitrary fc (especially `FrameClass.Discrete`) while still feeding into the parametric canonical model.

**Files Modified (all compile clean)**:

1. **ModalSaturation.lean** -- `SetMaximalConsistent.contrapositive` parameterized over `{fc : FrameClass}` (was hardcoded to Base)
2. **CanonicalFrame.lean** -- `existsTask_transitive` and `h_content_chain_transitive` parameterized over `{fc : FrameClass}`
3. **TemporalCoherence.lean** -- Added `{fc : FrameClass}` to variable block; changed `BFMCS D` -> `BFMCS (fc := fc) D`, `FMCS D` -> `FMCS (fc := fc) D`, `TemporalCoherentFamily D` -> `TemporalCoherentFamily fc D`; duality lemmas (`neg_all_future_to_some_future_neg`, `neg_all_past_to_some_past_neg`, `double_neg_elim`) parameterized with `.lift (by cases fc <;> trivial)` for Base-level sub-derivations
4. **ParametricCanonical.lean** -- `ParametricCanonicalWorldState` now takes `(fc : FrameClass := FrameClass.Base)` parameter; all downstream references updated to `ParametricCanonicalWorldState fc`; `ParametricCanonicalTaskFrame` auto-binds fc
5. **ParametricHistory.lean** -- Added `{fc : FrameClass}` to variable block; all `FMCS D`/`BFMCS D` -> `FMCS (fc := fc) D`/`BFMCS (fc := fc) D`; explicit `(fc := fc)` on `ParametricCanonicalTaskFrame` calls
6. **ParametricTruthLemma.lean** -- Added `{fc : FrameClass}` to variable block; `neg_imp_implies_antecedent`/`neg_imp_implies_neg_consequent` parameterized with Base-build-then-lift pattern; `parametric_box_persistent` takes `FMCS (fc := fc) D`; `ParametricCanonicalTaskModel` uses `ParametricCanonicalTaskFrame (fc := fc) D`
7. **RestrictedParametricTruthLemma.lean** -- Added `{fc : FrameClass}` to variable block; all `BFMCS D`/`FMCS D` -> fc versions; private helpers parameterized with lift pattern
8. **ChronicleTypes.lean** -- Added `mcs_to_base` theorem: `SetMaximalConsistent (fc := fc) A → SetMaximalConsistent (fc := FrameClass.Base) A`

### Key Architectural Decision
The approach follows the mathematically correct path: upstream layer functions are properly parameterized over `{fc : FrameClass}` with default `FrameClass.Base` for backward compatibility. Base-level propositional tautologies (from Propositional.lean, TemporalDerived.lean) are lifted via `DerivationTree.lift (by cases fc <;> trivial)` at the boundary, which is the proper mathematical embedding of Base derivations into arbitrary frame classes.

## Remaining Work for Phase 5

ChronicleToCountermodel.lean has 88 compilation errors. These fall into clear categories:

### Category 1: `bx_modal_witness` boundary (lines 563-577, ~3032-3042)
`bx_modal_witness` takes `BXPoint` which is hardcoded to Base. The `cantor_bfmcs_dense`/`cantor_bfmcs_discrete` `modal_backward` proofs need to construct a `BXPoint` from an fc-MCS.
**Fix**: Use `mcs_to_base h_mcs` to convert fc-MCS to Base-MCS for `BXPoint` construction. Then use `v.is_mcs` (at Base) and the fact that the returned witness's formulas are sets that don't depend on fc.

### Category 2: `SetMaximalConsistent.contrapositive` + `box_dne_theorem` (lines 562-563, 3032-3033)
`box_dne_theorem` returns `DerivationTree FrameClass.Base`. `contrapositive` now takes fc.
**Fix**: Use `liftBase fc (box_dne_theorem φ)` to lift the Base derivation, then pass to parameterized `contrapositive`.

### Category 3: TemporalDerived at Base (lines 1721, 1730)
`temp_k_dist_derived` and `contrapositive` from TemporalDerived are at Base.
**Fix**: `liftBase fc (temp_k_dist_derived ...)` and similarly.

### Category 4: Unknown `fc` in collapseClass_linearOrder (lines 2283-2349)
`collapseClass_linearOrder` is missing `(fc : FrameClass)` parameter.
**Fix**: Add `(fc : FrameClass)` parameter to `collapseClass_linearOrder` and all functions from lines ~2258 to ~2362.

### Category 5: `discrete_zero` (lines 2491-2492, 2498-2499)
Definition has wrong parameter format.
**Fix**: Fix the `limit_dom` and `limit_f` references that lost their `fc` arg.

### Category 6: Discrete pipeline mirrors (lines 3006-3346)
Mirror of Categories 1-2 for the discrete case.
**Fix**: Same patterns as dense case.

### Category 7: `countermodel_dense`/`countermodel_discrete` Algebraic boundary (lines 803-820, 3295-3312)
These functions call `ShiftClosedParametricCanonicalOmega`, `parametric_to_history`, etc. which are now parameterized. The fc should unify automatically from the BFMCS argument.
**Fix**: May need explicit `(fc := fc)` annotations on `ParametricCanonicalTaskFrame`, `ParametricCanonicalTaskModel`.

## Immediate Next Action
Fix ChronicleToCountermodel.lean errors Category by Category, starting with Category 1 (bx_modal_witness boundary) since it's the most architecturally significant and resolves the most cascading errors.

## Session
sess_1779791105_71af24
