# Sorry Closure Handoff - 2026-05-16

## Session: sess_1778987529_aeb59c

## Summary

Closed 11 of 39 sorries in the Separation/ directory. All closed proofs are mathematically correct and verified by `lake build`.

## Sorries Closed

### IntHelpers.lean (5/5 closed - COMPLETE)
1. `Int.exists_least_above` - Well-ordering for Z (Nat.find + shift)
2. `Int.exists_greatest_below` - Dual (mirror argument)
3. `Int.exists_least_above'` - Classical version (delegates to decidable)
4. `since_top_is_past` - S(a, True) iff some_past a
5. `until_top_is_future` - U(a, True) iff some_future a

### NegationEquiv.lean (2/2 closed - COMPLETE)
1. `neg_until_equiv` - KEY Z-dependent lemma (GHR94 10.2.2 forward)
2. `neg_since_equiv` - Dual (direct mirror proof)

### FormulaOps.lean (1/8 closed)
1. `subst_correctness` - Substitution preserves truth (induction on formula)

### Defs.lean (2/2 closed - COMPLETE)
- `u_appearances_top_level_only` - Replaced sorry body with recursive definition
- `u_appears_only_as_top_level` - Replaced sorry body with recursive definition

## Type Signature Fix

Changed elimination case conclusions from `is_U_free psi = true` to `is_syntactically_separated psi = true`. Rationale: GHR94 elimination cases produce formulas where U(A,B) appears at top level (not under S) with S-free arguments - this IS syntactically separated but NOT U-free.

## Remaining Sorries (28)

- **Eliminations.lean** (8): Core cases 1-8, need explicit formula construction per GHR94
- **DualEliminations.lean** (8): Should follow from Eliminations via duality
- **SeparationThm.lean** (5): Higher-level induction lemmas
- **FormulaOps.lean** (7): DNF/CNF defs+correctness (4), freshness (3)

## Next Steps

1. For elimination cases: construct explicit GHR94 formulas for each case, prove semantic equivalence
2. For dual cases: use `dual_equiv` + `dual_separated` from Duality.lean
3. DNF/CNF can stay as sorry (infrastructure, plan allows it)
4. SeparationThm lemmas depend on elimination cases

## Key Proof Technique Discovered

The Formula.and encoding (`neg (imp X (neg Y))`) unfolds at int_truth level as:
- `int_truth M t (Formula.and X Y) = ((int_truth M t X) -> (int_truth M t Y -> False) -> False) -> False`
- i.e., `not (X -> not Y)` which is classically `X and Y`
- To prove: `intro h; exact h hX hnotY` (where goal is the `and`)
- To extract from hypothesis: `hAnd (fun hnotX _ => hnotX hX)` gives `False` from `X`
