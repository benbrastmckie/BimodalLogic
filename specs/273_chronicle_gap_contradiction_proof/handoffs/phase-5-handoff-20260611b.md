# Phase 5 Handoff: Backward Direction -- Full Compatibility Filtering

**Date**: 2026-06-11
**Session**: sess_1781193902_83bc5c
**Phase**: 5 (Backward Direction)
**Status**: IN PROGRESS (partial)

## Summary

Extended `nf_exist_formula_nested` with full non-interval ssn compatibility
filtering. The formula now checks not just atom compatibility of nf_x with
sub_nf, but also verifies that non-interval ssn conditions are consistent
with nf_x and parent_atoms. The forward proof compiles with the new filter.

## Changes Made

### New Infrastructure (NegationClosure.lean)

1. **liftSkip**: Embed Fin n into Fin (n+1) by skipping index j
2. **atomProjDrop**: Project atom assignments by dropping a variable
3. **ssn_xt_order_compat**: Check order consistency between ssn and sub_nf
4. **ssn_x_pred_compat**: Check pred atoms at variable 1 (x) match nf_x
5. **ssn_t_pred_compat**: Check pred atoms at variable 2 (t) match parent_atoms
6. **ssn_y_above_x, ssn_y_eq_x, ssn_y_eq_t, ssn_y_below_t**: Order region classifiers
7. **nf_full_compat_right/left**: Full non-interval compatibility check
8. **nf_full_compat_right/left_of_eval**: Proof that actual witnesses pass compat (has sorries)

### Formula Changes

The formula's filtering now uses `atom_compat_x nf_x && nf_full_compat_right nf_x parent_atoms sub_nf`
instead of just `atom_compat_x nf_x` for the Until case (and symmetric for Since).

## Current Sorry Inventory

1. **NegationClosure.lean:758** -- `nf_full_compat_right_of_eval` case goals:
   After `neg_from_no_witness; intro y`, need to exhibit a specific atom where
   evaluation disagrees with ssn. Cases: wrong x,t order (exhibit order atom),
   wrong x pred (exhibit pred atom at var 1), wrong t pred (exhibit pred atom at var 2),
   wrong y=x pred (exhibit pred atom at var 0), wrong y=t pred (exhibit pred atom at var 0).
   **Proof strategy**: In each case, the Boolean negation gives a specific predicate p
   where ssn disagrees with the model. Use `List.all_eq_true` negation to extract p,
   then exhibit `AtomKind.pred p ⟨i, _⟩` as the failing atom.
   **Estimate**: ~100 lines total for all cases.

2. **NegationClosure.lean:773** -- `nf_full_compat_left_of_eval`: mirror of above.
   **Estimate**: ~100 lines (symmetric).

3. **NegationClosure.lean:1091** -- Main backward direction sorry:
   ```
   h_formula : temporal_truth M atomMap t (nf_exist_formula_nested k char_kp1 char_k parent_atoms sub_nf)
   |- exists x, nf_eval_nf M (k + 1) (1 + 1) (Fin.cons x (fun _ => t)) sub_nf
   ```
   **What's needed**: The composition lemma. Even with full filtering, the formula
   does not encode enough about the quantifier conditions of atom-compatible
   non-interval ssn's. At depth 0, this gap is closable because all ssn conditions
   reduce to atom+order checks. At depth > 0, the composition lemma is needed.
   **Estimate**: ~200 lines for composition, ~100 lines for backward proof using it.

## Immediate Next Action

1. Prove the compat helper sorries (lines 758, 773) -- tedious but routine
2. Prove backward direction at depth 0 (k=0 case only, no composition needed)
3. Add composition lemma for depth 0 (trivial: atoms involve at most 2 variables)
4. Attempt backward direction at depth k+1 using composition IH

## Key Proof State

```
-- At the backward sorry point (line 1091), available hypotheses:
char_k_correct : ∀ nf_k M h_UZ h_SZ t, char_k nf_k holds at t ↔ nf_eval_nf M k 1 t nf_k
_char_kp1_correct : ∀ nf_1 M h_UZ h_SZ t, char_kp1 nf_1 holds at t ↔ nf_eval_nf M (k+1) 1 t nf_1
h_atoms : ∀ a, atom_eval M (fun _ => t) a ↔ parent_atoms a = true
h_formula : temporal_truth M atomMap t (nf_exist_formula_nested ...)
h_UZ : semantic_prior_UZ M atomMap
h_SZ : semantic_prior_SZ M atomMap
p1_k, p2_k : P1/P2 at depth k
p1_kp1 : P1 at depth k+1
```

## Decisions Made

- Full compat filtering is the correct extension (not composition alone)
- The compat check is NECESSARY for the forward direction and strengthens filtering
- The backward direction still requires composition for depth > 0
- Guard remains Formula.top (negative interval conditions are NOT encoded in guard)
