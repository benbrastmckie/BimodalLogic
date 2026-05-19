# Phase 5 Blocker Handoff: Oracle at JD = 1

**Task**: 157  
**Session**: sess_1779214591_6c5f29  
**Date**: 2026-05-19  
**Agent**: lean-implementation-agent (plan v21)

## What Was Accomplished

### Phases 4A-4C: COMPLETED
- `single_U_formula_separable_noax_param`: axiom-free (propext, Classical.choice, Quot.sound only)
- `lemma_10_2_6_self_contained_param`: axiom-free
- `no_S_nested_in_U_separable_direct_param`: axiom-free
- All three _param variants compile and pass `lean_verify`
- Old versions are thin wrappers calling _param with `all_separable` oracle

### Phase 5 Task 5.1: PARTIAL (n >= 2 done, n = 1 blocked)
- `all_formulas_separable_aux` modified:
  - `.snce` case: `by_cases hn2 : n >= 2` splits into oracle path (n>=2) and fallback (n=1)
  - `.untl` case: same pattern via duality
  - n >= 2 path uses `no_S_nested_in_U_separable_direct_param` with oracle from `ih_jd`
  - n = 1 path falls back to `no_S_nested_in_U_separable_direct` (axiom-dependent)

## The Blocker

### Problem Statement
At JD induction level n = 1 inside `all_formulas_separable_aux`, the `.snce a b` case with JD = 1 produces a normalized `.snce xa xb` with `no_S_nested_in_U` and JD <= 1. To prove it separable using `no_S_nested_in_U_separable_direct_param`, we need an oracle:

```
oracle : forall chi, no_S_nested_in_U chi -> junction_depth chi <= 1 -> is_separable chi
```

The oracle is called from inside `single_U_formula_separable_noax_param` on `.snce C'' F''` (box-normalized separated forms of IH results). These have JD <= 1 (by `snce_of_boxfree_sep_jd_le_one`).

### Why ih_jd Fails at n = 1
- `ih_jd : forall m < n, forall psi, junction_depth psi <= m -> ... -> is_separable psi`
- For n = 1: `ih_jd m (m < 1)` only gives m = 0, handling JD = 0 formulas
- Oracle formulas can have JD = 1 (when C'' or F'' directly contain `.snce` nodes)
- Therefore `ih_jd 0 (0 < 1)` cannot handle JD = 1 oracle formulas

### Why the Oracle Chain Terminates (But Isn't Expressible via ih_jd)
The oracle chain terminates because of INTERNAL measures in the `_param` functions:
1. `no_S_nested_in_U_separable_direct_param`: U_nesting_depth induction
2. `lemma_10_2_6_self_contained_param`: count_U_subformulas induction  
3. `single_U_formula_separable_noax_param`: snce_depth_of_U induction

At step 3, the oracle is called on `.snce C'' F''` after snce_depth_of_U decreased. But the oracle formula is constructed from separated witnesses, so it has no simple size relationship to the input.

### What Was Tried
1. Direct `omega` proof: fails (`junction_depth chi <= 1` and `n >= 1` does not give `< n`)
2. Nested `no_S_nested_in_U_separable_param_jd`: would require infinite nesting
3. Combined induction on (junction_depth, count_U_subformulas): callback count not decreasing
4. Bundled property `(expanded -> sep) /\ (no_S_nested -> sep)`: circular at n = 1
5. Well-founded recursion on sizeOf: oracle formulas not size-related to input

## Proposed Solutions

### Solution 1: Prove Standalone Oracle Lemma (Recommended)
Prove `no_S_nested_jd_le_one_separable` as a standalone theorem using well-founded recursion on a COMBINED measure that captures all three internal inductions:

```lean
-- Measure: (U_nesting_depth, count_U_subformulas, snce_depth_of_U)
-- Lexicographic ordering
```

This requires formalizing how the three measures interact across the _param function chain. Estimated effort: 4-6 hours.

### Solution 2: Fused Induction in all_formulas_separable_aux
Inline the entire `no_S_nested_in_U_separable_direct_param` + `lemma_10_2_6_self_contained_param` + `single_U_formula_separable_noax_param` chain inside `all_formulas_separable_aux`, adding the internal measures to the induction scheme. This avoids the oracle altogether but produces a monolithic proof. Estimated effort: 8+ hours.

### Solution 3: Change JD Induction Base
Start the JD induction from n = 2 as base case, proving n <= 1 directly. But the n = 1 proof faces the same oracle problem. This shifts rather than solves the issue.

### Solution 4: Accept Partial Progress
Keep the n >= 2 path axiom-free and n = 1 axiom-dependent. Then prove that `all_formulas_separable_aux` at n >= 2 doesn't transitively depend on the n = 1 axiom path. Unfortunately, verification shows it does (the axioms appear in `lean_verify` output).

## Immediate Next Action

Implement Solution 1: Define a lexicographic measure `(U_nesting_depth phi, count_U_subformulas phi, snce_depth_of_U phi)` and prove `no_S_nested_jd_le_one_separable` by well-founded recursion on this measure. The proof would trace through the _param chain and use the measure decrease at each step.

## Key Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` - main file, lines 2648-2671 (the n = 1 fallback)
- `/home/benjamin/Projects/ProofChecker/specs/157_expressive_completeness_su_integer/plans/21_oracle-threading-plan.md` - plan v21

## Current Build Status
`lake build` passes. No sorries. `lean_verify all_formulas_separable_aux` still shows `snce_separable` and `untl_separable` axioms (from n = 1 fallback path).
