# Phase 2 Handoff: IsVEA Predicate and Arity Reduction

## Status: BLOCKED

## What Was Accomplished

1. **Phase 1 completed**: Prop43.lean archived to Boneyard, k=1 dependencies inlined into KampPrior.lean, build passes, sorry audit matches (3 sorries in active files).

2. **IsVEA definition implemented** in ArityReduction.lean:
   ```lean
   def IsVEA (atomMap) (phi : MonadicFormula sig m) : Prop :=
     ∀ (i j : Fin m), i < j →
       ∃ (v : VVecEA2), ∀ M h_UZ h_SZ zi zj (h_lt : zi < zj),
         v.holds M atomMap zi zj ↔
         ∃ env, env i = zi ∧ env j = zj ∧ eval M env phi
   ```

3. **isVEA_ex proved sorry-free**: The existential closure of IsVEA is trivial because the bound variable is already existentially quantified in the pair projection. VVecEA2 for pair (i,j) in `.ex phi` = VVecEA2 for pair (i+1, j+1) in phi.

## What Blocks Progress

### Core Blocker: VVecEA2 Negation Biconditional

To prove `fo_isVEA` (Prop 4.3) by structural induction, the `.all` case requires:
```
.all phi = .not (.ex (.not phi))
```

This needs IsVEA for `.not phi`, which at arity 2 requires:
```
neg_2var_vec_ea_indep v .holds z0 z1 ↔ ¬v.holds z0 z1
```

The FORWARD direction is `neg_2var_vec_ea_indep_correct` (existing, sorry-free).
The BACKWARD direction requires proving that `v.holds` and `(neg v).holds` cannot both be true on the same interval (z0, z1). This disjointness is expected to hold for the three-case construction (A, B1, B2) but is not proved.

### Analysis of the Three Cases

The `neg_interval_formula_indep` construction (NegationIndep.lean) builds:
- **Case A**: No witness with pointType(0) in (z0, z1) → covers when bf has no witnesses of the right type
- **Case B1**: First occurrence of pointType(0) at r0, tail negated → covers when bf fails after r0
- **Case B2**: First occurrence via INF bracket → covers when bf fails at r0

These three cases are designed to be exhaustive (covering all reasons why `¬bf.holds`). The disjointness with `bf.holds` should follow from:
- Case A: bf requires witnesses with pointType(0), but Case A asserts none exist → disjoint
- Cases B1/B2: bf requires specific interval conditions, but B1/B2 assert the negation of some condition → disjoint

Proving this rigorously requires ~100-200 lines of case analysis on the bracket formula structure.

## Recommended Next Steps

1. **Prove the backward direction of Prop 4.2 biconditional** (~100-200 lines):
   ```lean
   theorem neg_2var_vec_ea_indep_backward {sig : MonadicSignature}
       {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
       (h_INF : HasAttainedINF M atomMap)
       (v : VVecEA2) (z0 z1 : M.carrier) (h_lt : z0 < z1)
       (h_neg_holds : (neg_2var_vec_ea_indep v).holds M atomMap z0 z1) :
       ¬v.holds M atomMap z0 z1
   ```
   This would give the full biconditional needed for the negation case of fo_isVEA.

2. **Alternative: Redefine the induction to avoid negation at arity >= 3**.
   At arity 2, the negation biconditional suffices (since projection is deterministic).
   A mutual recursion `fo1_to_temporal` + `fo2_to_vvecEA2` at arities 1 and 2 might work if the `.ex` case at arity 2 can be handled WITHOUT going through arity 3. This would require showing that `∃x. psi(x, z0, z1)` for `psi : MonadicFormula sig 3` can be converted to VVecEA2 directly (absorbing x as a witness).

3. **Alternative: Use a completely different proof strategy** for the KampPrior sorry that bypasses IsVEA entirely, e.g., a semantic compactness argument or a direct translation using the table method.

## Key Files

- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/ArityReduction.lean` -- IsVEA def + isVEA_ex (sorry-free)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- sorry at line 287 (unchanged)
- `/home/benjamin/Projects/BimodalLogic/Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NegationIndep.lean` -- neg_2var_vec_ea_indep (forward direction)

## Session

Session: sess_1782247840_0cc7cd
