# Phase 3 Handoff: PointInsertion.lean Complete + Upstream Infrastructure

## Status
- Phase 1 (ChronicleTypes.lean): COMPLETED
- Phase 2 (RRelation.lean): COMPLETED
- Phase 3 (PointInsertion.lean): COMPLETED (0 errors, 0 sorries)
- Phase 4+: NOT STARTED

## What Was Done in This Session

### Upstream Parameterization (Major Infrastructure)

Parameterized core theorem functions over `{fc : FrameClass}` to eliminate need for `liftBase fc` wrapping at call sites:

**Combinators.lean** (all at `{fc : FrameClass}` now):
- `identity`, `b_combinator`, `theorem_flip`, `theorem_app1`, `theorem_app2`, `pairing`, `dni`, `temp_future_derived`
- Pattern: changed `⊢` to `⊢[fc]`, `trivial` to `FrameClass.base_le fc` in axiom gates
- Fixed all `@` calls in downstream files (Propositional, ModalS4, ModalS5, Bridge)

**Propositional.lean** (newly parameterized):
- `efq_axiom`, `peirce_axiom`, `double_negation`
- `lce_imp`, `rce_imp` (via lift of Base-level `lce`/`rce`)

**GeneralizedNecessitation.lean** (newly parameterized):
- `reverse_deduction`, `generalized_modal_k`, `generalized_temporal_k`, `generalized_past_k`
- `generalized_temporal_k` lifts Base-level `temp_k_dist_local` internally

**WitnessSeed.lean** (newly parameterized):
- `forward_temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent`

**MCSProperties.lean** (newly parameterized):
- `SetMaximalConsistent.all_future_all_future`, `SetMaximalConsistent.all_past_all_past`

### PointInsertion.lean Fixes (3527 lines, ~344 FrameClass.Base refs)

All 344 `FrameClass.Base` references replaced with `fc`. Error fix patterns applied:
1. **fc argument insertion** (70+ calls): `deductiveClosure_is_dcs`, `burgessR_implies_burgessRSince`, `snce_left_mono_thm`, `untl_left_mono_thm`, `untl_left_mono_G`, `since_implies_P_in_mcs`, `burgessR3Maximal_extension_exists`, `burgessR3Maximal_with_guard`, `snce_left_mono_H`, `burgessR_conj`, `burgessRSince_conj`
2. **liftBase fc wrapping** (7 calls): `temp_k_dist_derived`, `demorgan_disj_neg_forward` -- these TemporalDerived functions are still at Base level
3. **Type annotations** (~15 `have` statements): Added `DerivationTree fc [] _` annotation to untyped `have` for fc inference
4. **subset_deductiveClosure/deductiveClosure_closed_under_derivation**: Added explicit `fc` and set arguments
5. **unfold tactic**: Removed `fc` from `unfold l27_a_event_list fc` (fc is parameter, not definition)

### Downstream Fixes
- RRelation.lean: Removed redundant `liftBase` wrapping from now-parameterized functions
- ChronicleTypes.lean: Same
- ReflexiveCanonical.lean: Added `DerivationTree FrameClass.Base [] _` annotations for `pairing` calls
- UltrafilterMCS.lean: Added annotation for `double_negation` call
- ParametricTruthLemma.lean: Added annotation for `temp_future_derived` call

## Current Build Status
- Full `lake build` passes with ONLY CounterexampleElimination.lean failing (expected -- it's Phase 4)
- No new sorries introduced
- No new axioms introduced

## Functions Still at Base Level (Need liftBase at Call Sites)

These TemporalDerived/Propositional functions remain at `FrameClass.Base`:
- `temp_k_dist_derived` -- used 7x in PointInsertion (all wrapped with liftBase)
- `demorgan_disj_neg_forward` -- used 4x in PointInsertion (all wrapped)
- `contrapose_imp`, `contraposition` -- used by temp_k_dist_local internally
- `temp_4_derived`, `temp_4_past` -- used by MCSProperties (lifted internally)
- All other TemporalDerived functions

Pattern for call sites: `liftBase fc (function_name args)`

## Critical Patterns for Phase 4+

### CounterexampleElimination.lean (Phase 4)
- 39 `FrameClass.Base` refs to replace
- Key issue: Chronicle condition accessors (`χ.c0`, `χ.c1`, `χ.c2'`, etc.) now take `fc` parameter
  - Use `χ.c0 fc` instead of `χ.c0`
  - Same for `ValidChronicle fc`, `ChronicleInvariant fc`, `BurgessR3Maximal fc`
- Functions that don't have `FrameClass.Base` in their header but use parameterized types in body need `(fc : FrameClass)` added manually
- Watch for `BurgessR3Maximal` calls -- all need `fc` first arg

### ChronicleConstruction.lean (Phase 4)
- 71 `FrameClass.Base` refs
- Same patterns as CounterexampleElimination

### Key Design Decision
- Explicit `(fc : FrameClass)` on definitions, `{fc : FrameClass}` implicit on theorems where inferrable
- `FrameClass.base_le fc` replaces `trivial` in axiom gates (for prop_s, prop_k, etc.)
- `liftBase fc` defined in ChronicleTypes.lean for lifting Base derivations

## Files Modified (Complete List)
1. `Theories/Bimodal/Theorems/Combinators.lean` -- parameterized 8 functions
2. `Theories/Bimodal/Theorems/Propositional.lean` -- parameterized 5 functions
3. `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` -- parameterized 4 functions
4. `Theories/Bimodal/Theorems/ModalS4.lean` -- fixed @ calls
5. `Theories/Bimodal/Theorems/ModalS5.lean` -- fixed @ calls
6. `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` -- fixed @ calls
7. `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- parameterized 2 functions
8. `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` -- parameterized 2 functions
9. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- removed redundant lifts
10. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- removed redundant lifts, added annotations
11. `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- COMPLETE (0 errors)
12. `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` -- added annotations
13. `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` -- added annotation
14. `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- added annotation
