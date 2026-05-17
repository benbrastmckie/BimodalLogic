# Phase 7 Handoff: separation_implies_expressiveness

## Status: BLOCKED

## What Was Accomplished

1. **Purity semantic lemmas** (fully proved):
   - `past_only_is_pure_past`: syntactically past-only formulas depend only on valuations at times <= t
   - `future_only_is_pure_future`: syntactically future-only formulas depend only on valuations at times >= t
   - `past_only_subst_correct`: substitution under past-only purity
   - `future_only_subst_correct`: substitution under future-only purity

2. **Extended signature infrastructure** (fully built):
   - `ExtPred sig`: inductive type with `orig p`, `const_at_ref p`, `lt_ref`, `gt_ref`
   - `Fintype (ExtPred sig)` instance
   - `extSignature sig`: the MonadicSignature with ExtPred as predicates
   - `reduceElimLast`: eliminates the last variable from MonadicFormula sig (n+1)

3. **Quantifier-free cases** (fully proved):
   - `expressiveness_fixed_atomMap` handles atom, lt, not, and cases correctly
   - The proof structure uses a fixed injective atomMap
   - `separation_implies_expressiveness` correctly delegates to `expressiveness_fixed_atomMap`

4. **Helper lemmas**:
   - `fin1_eq_zero`, `env_fin1_cons`: Fin 1 helpers
   - `monadicFalse`: encoding of False in MonadicFormula
   - `q_exists_correct`: already existed, used by the theorem

## What Remains (Blocker)

The `.all alpha` and `.ex alpha` cases of `expressiveness_fixed_atomMap` require:

1. **`reduceElimLast_correct`** (~100 LOC): 
   ```
   eval M (Fin.cons z (fun _ => t)) alpha ↔ 
   eval M_ext (fun _ => z) (reduceElimLast 1 alpha)
   ```
   where M_ext is the extended structure with R-atoms interpreted correctly.

2. **Extended IntStructure construction** (~30 LOC):
   ```
   def extIntStruct (M : IntStructureFromSig sig) (t : Int) 
       (atomMap : sig.preds -> Atom) (atomMap_ext : ExtPred sig -> Atom) :
       IntStructureFromSig (extSignature sig)
   ```

3. **Quantifier case assembly** (~150 LOC):
   - Apply IH to get temporal formula A for the reduced formula
   - Form q_exists A (for ex) or neg(q_exists(neg A)) (for all)
   - Apply h_sep to get properly separated B'
   - Substitute: r_lt -> True in past-only, r_gt -> True in future-only
   - Substitute: c_p -> atom(atomMap p) everywhere
   - Prove the resulting formula is correct

## Key Decisions

- Used `expressiveness_fixed_atomMap` with FIXED injective atomMap to avoid the conjunction-atomMap mismatch problem
- Used structural recursion (not well-founded) for the main function -- the quantifier case will need to be restructured to use well-founded induction on quantifier_depth when implemented
- `reduceElimLast` eliminates the LAST variable (highest index) which simplifies the handling of nested quantifiers

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean`

## Next Steps

To complete this phase, implement items 1-3 above. The quantifier case will likely need `expressiveness_fixed_atomMap` to be restructured as well-founded recursion on quantifier_depth (currently structural recursion that can't recurse into extSignature).
