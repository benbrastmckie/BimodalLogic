# Phase 4A Blocker: Mutual Recursion in Axiom Elimination

## Session
- **Session ID**: sess_1779214591_6c5f29
- **Date**: 2026-05-19
- **Status**: BLOCKED
- **Plan**: plans/20_ghr94-faithful-plan.md

## The Fundamental Problem

Plan v20 Phase 4A claims that `single_U_formula_separable_noax` depth >= 2 can be fixed by proving `U_nesting_depth (.snce C'' F'') <= 1` and then calling `lemma_10_2_6_self_contained`. This is **incorrect** because:

1. `C'' = replace_box_with_top C'` where C' is a syntactically separated formula
2. A separated formula can have nested `.untl` nodes: e.g., `.untl (.untl p q) r` is valid (args of outer `.untl` are S-free)
3. After `replace_box_with_top`, these nested `.untl` structures remain
4. Therefore `U_nesting_depth C''` can be arbitrarily high (not bounded by 1)
5. The proposed helper `boxfree_sep_U_nesting_depth_le_one` CANNOT be proved -- it is false

## The Mutual Recursion Problem

The deeper issue is that Paths A and B are **mutually recursive**, not independently fixable:

### Dependency Chain

```
single_U_formula_separable_noax (depth >= 2)
  → needs: no_S_nested_in_U (.snce C'' F'') → is_separable
  → which requires: no_S_nested_in_U_separable_direct (arbitrary U_nesting_depth)
  → which at depth <= 1 requires: lemma_10_2_6_self_contained
  → which requires: single_U_formula_separable_noax (at all snce_depth levels!)
```

And:
```
no_S_nested_in_U_separable_direct (depth >= 2)
  → needs extract_innermost_U_type (Phase 4B fix) for U-free args
  → back-substitution callback at depth <= 1
  → which requires: lemma_10_2_6_self_contained
  → which requires: single_U_formula_separable_noax
  → which at depth >= 2 requires: no_S_nested_in_U_separable_direct
```

### Why Lean Can't Accept This

- `single_U_formula_separable_noax` is defined BEFORE `no_S_nested_in_U_separable_direct`
- It cannot forward-reference `no_S_nested_in_U_separable_direct`
- Even if reordered, `no_S_nested_in_U_separable_direct` depends on `lemma_10_2_6_self_contained` depends on `single_U_formula_separable_noax`
- Lean 4 does not allow `mutual` for `theorem` (only `def`)
- A theorem cannot reference itself (no circular definitions)

### Why the Existing Code Works (With Axioms)

The current code breaks the cycle by using `all_separable` (which is backed by axioms) at both leak sites. This provides a "ground truth" external to both theorems, preventing the circular dependency.

## What Was Tried

1. **Plan's approach** (Task 4A.1-4A.2): Prove `U_nesting_depth <= 1`. FAILS because this is false.
2. **Use `no_S_nested_in_U_separable_param_jd` with JD IH callback**: Works at JD >= 2, FAILS at JD = 1 (callback formulas have JD <= 1 = current level).
3. **Strengthen IH to preserve single-U-type**: Would work but requires proving `snce_single_U_depth_one_separable` output has `has_single_U_type`. Non-trivial additional work.
4. **Combined induction on (U_nesting_depth, count_U_subformulas)**: Can't find a decreasing measure for callback formulas.
5. **Inline everything into `all_formulas_separable_aux`**: JD = 1 case still can't handle callbacks without the full theorem.
6. **Self-referential callback via `WellFounded.fix`**: No simple decreasing Nat measure exists across callback boundaries.

## Proposed Solutions (For Research/Revision)

### Solution A: Strengthen `single_U_formula_separable_noax` to Preserve Single-U-Type

Define `is_separable_with_U_type phi A B := exists psi, separated psi /\ equiv phi psi /\ has_single_U_type psi A B`.

Prove that all cases of `single_U_formula_separable_noax` produce witnesses with `has_single_U_type`. Key requirement: prove that `snce_single_U_depth_one_separable`'s output has `has_single_U_type _ A B`. This is plausible (the separated form only contains `U(A,B)` by construction) but requires ~100-200 LOC of additional lemmas.

With this stronger IH:
- At depth >= 2: IH on C gives (C', sep, equiv, single-U-type). Box-normalize: C'' = rbwt(C'). `has_single_U_type C'' A B` (already proved: `replace_box_preserves_single_U_type`). And `snce_depth_of_U C'' = 0` (`separated_boxnorm_snce_depth_zero`). So `.snce C'' F''` has `has_single_U_type`, `snce_depth_of_U <= 1`. Use the SAME IH at depth <= 1.
- **NO MUTUAL RECURSION NEEDED**. The theorem is entirely self-contained.

**Effort estimate**: 4-6 hours. Medium risk. Requires proving preservation through event-splitting, CNF distribution, guard-clause construction.

### Solution B: GHR94-Faithful "Apply 10.2.4 to Innermost S and Replace" 

Instead of recursing on children, implement GHR94's literal approach: find the innermost `.snce C F` subformula where U(A,B) appears at top level in C and F, apply `snce_single_U_depth_one_separable` to it, and replace the subformula with the separated equivalent. The resulting formula has lower `snce_depth_of_U`.

Requires:
- A `find_and_replace_innermost_snce` function
- Proof that the replacement reduces `snce_depth_of_U`
- Proof that `has_single_U_type` is preserved (U only appears as U(A,B) in the replacement)
- Proof of semantic equivalence

**Effort estimate**: 6-8 hours. Higher risk. Complex subformula replacement formalization.

### Solution C: Use `sizeOf` + Accessibility for Termination

Define termination via `Acc` (accessibility). The callback tree has finite depth because:
- Each `no_S_nested_in_U_separable_param_jd` call does count induction (terminates)
- Callbacks are called finite times per invocation
- The total "work" is bounded

Encode this using `Acc` and `WellFounded.fix` on a custom relation.

**Effort estimate**: 8-10 hours. Highest risk. Complex well-foundedness proof.

### Solution D: Intermediate Axiom Approach

Declare a LOCAL axiom `no_S_nested_in_U_separable_axiom_local : no_S_nested_in_U phi -> is_separable phi`, use it in `single_U_formula_separable_noax`, then prove it as a theorem using `all_formulas_separable_aux` (which uses `no_S_nested_in_U_separable_direct`, which now links to the local axiom). This creates a well-typed but circular proof term that Lean may accept (since proofs are irrelevant).

**Effort estimate**: 1 hour. Very high risk -- Lean's kernel may reject the circularity.

## Recommendation

**Solution A** is the most likely to succeed with reasonable effort. The key insight: if we can show that `snce_single_U_depth_one_separable` produces a witness with `has_single_U_type`, then the ENTIRE `single_U_formula_separable_noax` becomes self-contained (no need for `no_S_nested_in_U_separable_direct` at all).

After Solution A makes `single_U_formula_separable_noax` axiom-free:
- `lemma_10_2_6_self_contained` becomes axiom-free (it calls `single_U_formula_separable_noax`)
- Phase 4B fix (`extract_innermost_U_type`) makes `no_S_nested_in_U_separable_direct` axiom-free (it calls `lemma_10_2_6_self_contained` at depth <= 1)
- `all_formulas_separable_aux` becomes axiom-free (it calls `no_S_nested_in_U_separable_direct`)
- Import reversal + axiom replacement (Phase 5) proceeds as planned

## Next Action

Run `/research 157 "Prove snce_single_U_depth_one_separable output preserves has_single_U_type"` to verify Solution A is feasible, then `/revise 157` to update the plan with Solution A as Phase 4A.
