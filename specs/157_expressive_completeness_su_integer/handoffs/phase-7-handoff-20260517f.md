# Phase 7 Handoff: atom_elim_correct Reduction

**Date**: 2026-05-17T20:12Z
**Session**: sess_1779047546_46f440
**Status**: PARTIAL - 3 sorries reduced to 1

## Summary

Reduced the 3 identical sorry obligations in `expressiveness_inner` (the .ex and .all cases) to a single well-specified theorem `atom_elim_correct` at line 916 of ExpressiveCompleteness.lean.

## What Was Done

1. **Added atom membership lemmas** (`to_int_struct_mem_freshAM`, `to_int_struct_mem_atomMap`): prove that injective atom maps correctly separate contributions in `to_int_struct`.

2. **Added `int_truth_foldl_and`**: helper for unfolding foldl-and semantics.

3. **Proved `guardFormula_correct`**: the guard formula correctly captures whether an assignment σ matches the model M at time t. Requires atomMap injective.

4. **Defined `atom_elim_correct`** with the correct type signature and wired it into the 3 sorry sites, closing them.

## The Remaining Sorry

```lean
private theorem atom_elim_correct {sig : MonadicSignature}
    (atomMap : sig.preds → Atom) (hinj : Function.Injective atomMap)
    (freshAM : (extSignature sig).preds → Atom) (freshAM_inj : Function.Injective freshAM)
    (M : IntStructureFromSig sig) (t : Int)
    (B_sep : Formula) (hB_sep : Separation.is_properly_separated B_sep = true) :
    Separation.int_truth (to_int_struct (extIntStruct M t) freshAM) t B_sep ↔
    Separation.int_truth (to_int_struct M atomMap) t (quantElimFormula atomMap freshAM B_sep) := by
  sorry
```

## Blocker Analysis

The proof of `atom_elim_correct` requires:

1. **Disjointness of atomMap and freshAM ranges**: The `elimExtFromSep` function uses sequential `applySubsts`, which applies substitutions left-to-right. After replacing `freshAM (.orig p)` with `atom (atomMap p)`, the remaining substitutions (for const_at_ref, lt_ref, gt_ref) may further modify `atom (atomMap p)` if `atomMap p` happens to equal some `freshAM ep'`.

   - At the TOP level (called from `separation_implies_expressiveness`): atomMap uses `mk_fresh "p"` and freshAM uses `mk_fresh "e"` — disjoint (different base strings).
   - At RECURSIVE levels: atomMap = previous freshAM (both base "e") — indices may overlap.

2. **Proof strategy once disjointness is resolved**:
   - Define σ*(p) = decide(M.interp p t)
   - Show guardFormula_correct makes the σ* branch true
   - Show `elimExtFromSep_correct`: structural induction on B_sep relating M_ext truth to M_orig truth of the substituted formula
   - For temporal cases (all_past, snce, etc.): use the fact that at past times s < t, the substitutions (lt→True, gt→False, orig→atomMap_atom, const→value) correctly represent M_ext semantics in M_orig

3. **Options to fix the disjointness issue**:
   - (A) Change freshAM construction to use a unique prefix per recursion level (e.g., `mk_fresh ("e" ++ toString depth) i`)
   - (B) Change freshAM to use offset indices that avoid atomMap's range (compute max index in atomMap's image + 1)
   - (C) Add `h_disjoint` hypothesis to `atom_elim_correct` and thread it through `expressiveness_inner` / `expressiveness_wf` / `expressiveness_fixed_atomMap`; provable at top level only

   Option (B) is simplest: replace `Atom.mk_fresh "e" (Fintype.equivFin ... ep).val` with `Atom.mk_fresh "e" (offset + (Fintype.equivFin ... ep).val)` where offset is chosen to exceed all indices appearing in atomMap's range.

## Key Decisions

- Removed the `h_disjoint` parameter from `atom_elim_correct` to keep the interface clean and compilable. The disjointness is needed for the PROOF but not the TYPE.
- Used `guardFormula_correct` with `hinj` (atomMap injective) for the guard semantics.
- The `int_truth_foldl_and` helper will also be needed for `int_truth_foldl_or` (for quantElimFormula) once the proof is attempted.

## Immediate Next Action

1. Fix the freshAM construction to guarantee disjointness (option B above)
2. Prove `elimExtFromSep_correct` by structural induction on B_sep with the disjointness available
3. Prove `quantElimFormula_correct_iff` (disjunction unfolding)
4. Combine into `atom_elim_correct`
