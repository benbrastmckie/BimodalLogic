# Phase B Analysis Handoff: Oracle Elimination Technical Gap

**Task**: 157
**Session**: sess_1779232806_81a1a1
**Date**: 2026-05-19
**Agent**: lean-implementation-agent (plan v22)
**Phase**: B (Make Lemma 10.2.7 Oracle-Free)

## What Was Accomplished

### Infrastructure Added to Hierarchy.lean
1. `is_separable_with_U_type` -- stronger separability predicate preserving `has_single_U_type`
2. `separable_with_type_imp_separable` -- implication to standard `is_separable`
3. `is_separable_with_U_type_of_equiv` -- equivalence transfer
4. `imp_separable_with_type` -- closure under `.imp`
5. `u_free_separable_with_type` -- U-free base case
6. `untl_s_free_separable_with_type` -- `.untl A B` base case
7. `case1_psi_has_single_U_type` -- GHR94 Case 1 witness preserves U-type

### Build Status
`lake build` passes with no new sorries.

## Technical Analysis: The Oracle Problem

### Plan's Approach (Tasks B.1-B.3)
The plan proposes making `no_S_nested_in_U_separable_direct_param` (10.2.7) oracle-free by:
- **Depth >= 2**: Extract innermost U-type (U-free args), abstract, count IH, back-substitute with `subst_in_separated_separable_depth`, callback at `U_nesting_depth <= 1 < d` handled by outer depth IH. **This part works.**
- **Depth <= 1**: Use `lemma_10_2_6_self_contained_param` (10.2.6) -> `single_U_formula_separable_noax_param` (10.2.5). Plan claims "oracle-free after Phase A."

### The Gap at Depth <= 1
Phase A made `single_U_formula_separable_noax_param` oracle-free at `snce_depth_of_U <= 1`. But at `snce_depth_of_U >= 2` (which CAN occur even when `U_nesting_depth <= 1`), the oracle IS still invoked.

**Why snce_depth_of_U >= 2 occurs at U_nesting_depth = 1**:
The callback formula from `subst_in_separated_separable_typed` is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free. If c has nested `.snce` nodes (e.g., `c = .snce (.snce (.atom p) (.atom q)) (.atom r)`), then after substitution:
- Inner `.snce (.untl A B) (.atom q)` has `snce_depth_of_U = 1`
- Outer `.snce (above) (.atom r)` has `snce_depth_of_U = 2`
So `snce_depth_of_U` of the callback can be >= 2 even with U-free args.

At `snce_depth_of_U >= 2` in `single_U_formula_separable_noax_param`:
- IH gives separated C', F' by structural induction
- Box-normalize to C'', F'' with `snce_depth_of_U = 0`
- Oracle receives `.snce C'' F''` with:
  - `no_S_nested_in_U` (from `snce_of_boxfree_sep_no_S_nested`)
  - `junction_depth <= 1` (from `snce_of_boxfree_sep_jd_le_one`)
  - `snce_depth_of_U <= 1`
  - But NOT `has_single_U_type _ A B` (separation doesn't preserve U-type)

The oracle formula `.snce C'' F''` lacks `has_single_U_type`, so it can't be fed back to `single_U_formula_separable_noax_param`. And it has `no_S_nested_in_U` with `JD <= 1` but unknown `U_nesting_depth`, so the outer depth IH can't handle it.

### Root Cause: Deviation from GHR94
GHR94's Lemma 10.2.5 states: "D is equivalent to a syntactically separated wff in which U only appears as the formula U(A,B)."

This is STRONGER than `is_separable`. The IH preserves `has_single_U_type`, so at `snce_depth_of_U >= 2`, the separated forms C', F' retain the U-type structure. Box-normalizing and applying 10.2.4 works directly without any oracle.

Our code's `is_separable C` gives `exists psi, separated(psi) /\ equiv(C, psi)` without constraining psi's U-type. The separated witness psi can have completely different `.untl` nodes.

## Proposed Fix: Strengthen 10.2.5

### Approach
Replace `is_separable` with `is_separable_with_U_type` in the conclusion of `single_U_formula_separable_noax_param`. The proof structure changes:
1. At the `.snce C F` case at depth >= 2:
   - IH gives `is_separable_with_U_type C A B` and `is_separable_with_U_type F A B`
   - Get separated C', F' WITH `has_single_U_type C' A B`, `has_single_U_type F' A B`
   - Box-normalize: C'', F'' preserve `has_single_U_type` (via `replace_box_preserves_single_U_type`)
   - `snce_depth_of_U C'' = 0`, `snce_depth_of_U F'' = 0` (via `separated_boxnorm_snce_depth_zero`)
   - Apply `snce_single_U_depth_one_separable` (10.2.4) directly. **No oracle needed.**
   - But need: the WITNESS from 10.2.4 also has `has_single_U_type` (for the IH to close)

### What's Needed
1. **Strengthen 10.2.4**: `snce_single_U_depth_one_separable` must output `is_separable_with_U_type (.snce C F) A B` (not just `is_separable`). This requires proving `has_single_U_type` for all 8 case witnesses.

2. **Case 1 witness**: `case1_psi a q A B` -- PROVED (`case1_psi_has_single_U_type`).

3. **Cases 2-4 witnesses**: Reduce to Case 1 via negation. The witnesses are boolean combinations of `case1_psi` and U-free components. Should be straightforward (~10 LOC each).

4. **Cases 5-8 witnesses** (DedekindZ): More complex. The witnesses involve `snce_combined_U_separable`, `Q_Z`, `d21_sep_equiv`, etc. Each is built from U-free components plus `.untl A B`, so they DO have `has_single_U_type`. But proving this formally requires tracing through the composition. Estimated ~30-50 LOC per case.

5. **Strengthen 10.2.4 theorem**: Create `snce_single_U_depth_one_separable_with_type` paralleling the existing proof but with `is_separable_with_U_type` conclusion. ~80 LOC.

6. **Strengthen 10.2.5 theorem**: Create `single_U_formula_separable_no_oracle` with `is_separable_with_U_type` conclusion and no oracle parameter. The `.snce` case at depth >= 2 uses the stronger IH + 10.2.4 directly. ~60 LOC.

7. **Build oracle-free 10.2.6 and 10.2.7**: Using the oracle-free 10.2.5. ~50 LOC.

### Estimated Total: ~350 LOC

### Alternative Approach: Well-Founded Fixed Point
Instead of strengthening 10.2.4, prove a standalone `no_S_nested_jd_le_one_separable` using well-founded recursion on a combined measure `(U_nesting_depth, count_U_subformulas, snce_depth_of_U)`. This avoids modifying the DedekindZ proofs but requires formalizing the termination argument across three nested inductions. Estimated ~200 LOC but higher risk of getting stuck on the termination proof.

## Key Files
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Hierarchy.lean` -- main file, helper lemmas added
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` -- case1_psi definition
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/DedekindZ.lean` -- Cases 5-8 (complex)
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/NormalForm.lean` -- case_N_separable_gen wrappers

## CRITICAL UPDATE: has_single_U_type Preservation FAILS

### Discovery
Cases 2, 4, 6, 8 in `snce_single_U_depth_one_separable` (10.2.4) involve negation of U(A,B). In our 6-constructor encoding (without G/H primitives), `neg U(A,B)` must be decomposed using `neg_until_equiv`:

```
neg U(A,B) <-> G(neg A) v U(neg A ^ neg B, neg A)
```

This introduces a NEW U-type `U(neg A ^ neg B, neg A)` which is NOT `U(A,B)`. So `has_single_U_type _ A B` is NOT preserved through Cases 2, 4, 6, 8.

### Why GHR94 Doesn't Have This Problem
GHR94 has G/H (always/historically) as PRIMITIVE connectives. So `neg U(A,B)` can be expressed as `G(neg B) v neg U(A, top) v ...` where G is primitive, not a U-rewriting. The separated form keeps `neg U(A,B)` as-is (it's a valid "pure future" component). In GHR94, U(A,B) with S-free A, B is a pure future formula, and `neg(pure future)` is also pure future. So `has_single_U_type` IS preserved in GHR94's language.

Our encoding MUST decompose `neg U(A,B)` because we don't have G as a primitive. This introduces new U-types.

### Impact
The proposed approach of strengthening `single_U_formula_separable_noax_param` (10.2.5) to output `is_separable_with_U_type` does NOT work for Cases 2, 4, 6, 8. A completely different approach is needed.

### Remaining Viable Approaches

1. **Add G/H primitives to Formula type**: Extend the formula type with `all_past`/`all_future` as primitives (not defined in terms of U/S). This would match GHR94's language exactly and allow the `has_single_U_type` preservation approach. MAJOR refactor affecting the entire codebase.

2. **Well-founded fixed point with combined measure**: Prove termination of the oracle chain using a lexicographic measure on `(U_nesting_depth, count_U_subformulas, snce_depth_of_U)`. The challenge is that oracle formulas don't have obviously smaller measures in all dimensions simultaneously. The argument would need to track how the three measures interact across the 10.2.5/10.2.6/10.2.7 chain.

3. **Fuel-based approach**: Pass a fuel counter through the chain. At each oracle invocation, decrement fuel. Prove that enough fuel is always available. The key insight: the oracle is invoked at `snce_depth_of_U >= 2`, and the oracle formula has `snce_depth_of_U <= 1`. But the chain may re-invoke the oracle on NEW callbacks. The question is whether the chain of re-invocations is bounded.

4. **Restructure to avoid the oracle entirely**: Instead of the abstraction-substitution pattern in 10.2.5, implement GHR94's approach of applying 10.2.4 to the INNERMOST S(C,F) directly (sub-formula replacement). This avoids producing oracle formulas altogether. Requires implementing sub-formula replacement with equivalence preservation.

## Immediate Next Action
Research approach (4) -- sub-formula replacement -- as it most closely follows GHR94 and avoids the oracle entirely. Alternatively, investigate approach (2) with careful measure analysis.

## Current Plan Status
- Phase A: [COMPLETED]
- Phase B: [IN PROGRESS] -- analysis complete, implementation strategy identified, helpers added
  - [ ] Task B.1 -- blocked pending oracle-free 10.2.5/10.2.6
  - [ ] Task B.2 -- infrastructure exists for depth >= 2 (existing `extract_U_type` + abstraction)
  - [ ] Task B.3 -- blocked pending oracle-free 10.2.5/10.2.6
  - NOTE: Plan tasks B.1-B.3 as written have a gap at depth <= 1 (see analysis above). The fix requires strengthening 10.2.4 to output `is_separable_with_U_type`, which is additional work not in the original plan.
