# Phase 7 Handoff: Infrastructure Complete, atom_elim_correct Remains

**Date**: 2026-05-17T21:20Z
**Session**: sess_1779050716_7a0566
**Status**: PARTIAL - Infrastructure laid out, 3 sorries remain

## Summary of Changes

1. **formula_atoms** defined in `Separation/Defs.lean` - collects all atoms in a formula as `Set Atom`
2. **proper_separation_preserves_atoms** axiom added to `SeparationThm.lean` - atom-preserving separation
3. **int_truth_depends_on_atoms** proved in ExpressiveCompleteness.lean - truth depends only on formula's atoms
4. **Refactored expressiveness chain** to carry:
   - `atomMap_base : String` — base string of atomMap construction
   - `h_am_form : ∀ p, atomMap p = mk_fresh atomMap_base (equivFin p).val` — exact form
   - `h_base_ne : atomMap_base ≠ "e" ++ toString (card sig.preds)` — disjointness guarantee
   - Output type includes `formula_atoms A ⊆ Set.range atomMap` (atom containment)
5. **h_disj proved** at both .ex and .all call sites using `mk_fresh_base_ne` + `h_base_ne`
6. **hB_atoms proved** at both call sites using `proper_separation_preserves_atoms` + IH atom containment
7. **h_base_ne_rec proved** at recursive calls using `String.append_left_cancel` + `Nat.repr_injective`

## Remaining Sorries (3)

### 1. atom_elim_correct (line 958) — THE MAIN SORRY
```lean
private theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (h_disj : ∀ (p : sig.preds) (ep : (extSignature sig).preds), atomMap p ≠ freshAM ep)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true)
    (hB_atoms : Separation.formula_atoms B_sep ⊆ Set.range freshAM) :
    int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep)
```

**Approach**: Now that we have h_disj and hB_atoms, the proof proceeds by:
1. Define σ*(p) = decide(M.interp p t)
2. Unfold quantElimFormula to the disjunction over σ
3. Show the σ* branch is correct:
   - guardFormula_correct gives guard is true
   - elimExtFromSep_correct (structural induction on B_sep) gives body correct
4. Show other branches have false guards (by guardFormula_correct)
5. Combine with int_truth_foldl_or

The KEY sub-proof is `elimExtFromSep_correct`:
- At atom a: by hB_atoms, a = freshAM ep for some ep. Case split on ep.
  With h_disj, applySubsts correctly substitutes without double-replacement.
- At temporal cases: use applySubsts_past_correct / applySubsts_future_correct
  (already proved) with the fact that is_properly_separated ensures purity.

### 2. Atom containment for quantElimFormula (line 1139, .ex case)
After elimExtFromSep replaces all freshAM atoms with atomMap atoms or constants,
the output should only contain atomMap atoms. This is structural but needs formal proof.

### 3. Atom containment for neg A_ex (line 1217, .all case)
Same as #2 but for the negated formula.

## Key Decisions Made

- Used `proper_separation_preserves_atoms` axiom (will be proved in Phase 6)
- Used base-string differentiation for h_disj (atomMap_base ≠ freshBase)
- Used `Nat.repr_injective` and `String.append_left_cancel` for recursive h_base_ne
- Added `h_base_ne` as parameter (proved at top level via native_decide on first char)

## Immediate Next Action

1. Prove `elimExtFromSep_correct` by structural induction on B_sep (the plan's Task 7.6)
2. Prove `int_truth_foldl_or` helper (Task 7.4)
3. Prove `guardFormula_unique` (Task 7.5)
4. Compose into `atom_elim_correct` (Task 7.8)
5. Close atom containment sorries (lines 1139, 1217)

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Defs.lean` (formula_atoms)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (axiom)
