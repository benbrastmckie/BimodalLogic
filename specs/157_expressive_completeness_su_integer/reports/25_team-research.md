# Team Research Report: Oracle Chain Termination (Task 157)

**Session**: sess_1779250647_e34579
**Teammates**: 4 (Approach D, Approach A, Approach C, Oracle JD Analysis)
**Focus**: Why does `no_S_nested_sep` block at UND <= 1, and what approach can fix it?

## Consensus Finding

**No formula-level measure works for the UND <= 1 oracle chain** because `is_separable` is existential — the separated witness has unconstrained structure, making callback measures uncontrollable.

All 4 researchers independently confirmed:
- Oracle formulas have `JD <= 1`, `snce_depth_of_U <= 1`, `no_S_nested_in_U` — all confirmed
- Oracle formulas have **uncontrolled** `U_nesting_depth`, `count_U_total`, `sizeOf`
- Concrete counterexample: `.snce (.untl q r) (.untl q r)` has JD = 1, proving oracle JD = 0 is impossible
- The identity roundtrip (abstract-substitute returns same formula) makes measure decrease impossible in general

## Approaches Ruled Out

| Approach | Finding | Why it fails |
|----------|---------|-------------|
| D: Inline n=1 in `all_formulas_separable_aux` | NOT FEASIBLE | Oracle JD can be 1, so JD IH at n=1 doesn't apply to oracle formulas |
| A: Full constructive separation | NOT RECOMMENDED | 30-50 hours, requires rewriting DedekindZ cases |
| C: Two-level non-recursive | DOES NOT WORK | Callbacks from substitution can have `snce_depth >= 2`, triggering oracle calls even at "leaf level" |
| `is_separable_with_bound` | MEDIUM FEASIBILITY | 15-25 hours, requires bounding all 8 case outputs |

## Key Structural Insight

The oracle chain IS finite — it terminates informally — but no simple formula-level measure captures the termination. The chain pattern is:

```
lemma_10_2_6 → single_U → oracle → lemma_10_2_6 → single_U → ... → leaf
```

Each oracle formula has `snce_depth_of_U <= 1`. Processing it can create callbacks with `snce_depth >= 2`, but those callbacks again produce oracle formulas with `snce_depth <= 1`. The chain terminates because the formulas become "simple enough" eventually, but "eventually" depends on the existential separated witnesses.

## Viable Paths Forward

### Path 1: Self-Contained 10.2.5 via box-free IH (v25 variant)

**Source**: Researcher D (Approach D), convergent with Researcher C

Strengthen `single_U_formula_separable_noax_param` IH to return separated + box-free equivalents:
- `.box a` → return `.imp .bot .bot` (box-free, equiv over Z)
- `.untl A B` → return `.untl (replace_box_with_top A) (replace_box_with_top B)` (box-free)
- `.snce C F` → IH gives box-free C', F'. `sep_boxfree_depth_zero` gives `snce_depth_of_U = 0`. Apply 10.2.4 directly, NO ORACLE NEEDED.

**Blocker**: Case 2 output introduces `all_future(neg A)` = U-type `(neg A, top)` ≠ `(A, B)`. The IH needs `has_single_U_type` but case output breaks it.

**Potential fix**: Track `has_single_U_type psi (replace_box_with_top A) (replace_box_with_top B)` instead. This works for the `.untl` case but doesn't solve the Case 2 U-type contamination.

**Effort**: 4-8 hours IF Case 2 contamination can be bypassed. Currently blocked by same issue as plan v25.

### Path 2: Sub-formula replacement (GHR94-faithful)

**Source**: Researcher C

Instead of abstract-substitute-callback, directly replace the innermost `.snce` containing U(A,B) with its 10.2.4 output. This follows GHR94 exactly and avoids oracle formulas entirely.

**New infrastructure needed** (~100-150 LOC):
- `find_innermost_snce_containing_U` : locate deepest `.snce` with `.untl` inside
- `replace_subformula_at_position` : replace a subformula in-place
- Proof: replacement preserves `int_equiv`
- Proof: `snce_depth_of_U` strictly decreases after replacement

**Blocker**: Same as Path 1 — the replaced subformula's 10.2.4 output introduces new U-types, so the IH hypothesis `has_single_U_type` breaks. Would need combined 10.2.5+10.2.6 as a single theorem without `has_single_U_type` requirement.

**Effort**: 15-20 hours including the infrastructure + combined proof.

### Path 3: Bounded `is_separable`

**Source**: Researcher A

Define `is_separable_bounded (phi : Formula) (n : Nat) := ∃ psi, separated psi ∧ int_equiv phi psi ∧ count_U_total psi ≤ n`. Thread this through all separation theorems.

**Key question**: Can we bound `count_U_total` of case outputs? Case 1 output has exactly 1 `.untl` node. Case 2 output has 2 (one from `all_future`, one from `case1_psi` with different args). Cases 5-8 are complex (chains through multiple cases).

**Effort**: 15-25 hours. Requires analyzing all 8 case outputs for count bounds.

### Path 4: Direct axiom elimination (simplest?)

**Source**: Researcher Oracle-JD

The axiom chain is: `all_formulas_separable_aux` at n=1 → `no_S_nested_in_U_separable_direct` → `all_separable` → `snce_separable` (axiom) + `untl_separable` (axiom).

If we can prove `snce_separable` and `untl_separable` FROM `all_formulas_separable_aux` at n >= 2 (which is already self-contained), the circle closes. The issue: `all_formulas_separable_aux` handles ALL formulas at JD >= 2, including `.snce` and `.untl`. At JD >= 2, the axiom is not needed. At JD = 1, it IS needed. At JD = 0, formulas are trivially separated.

Can we handle JD = 1 `.snce`/`.untl` formulas directly? A `.snce phi psi` with JD = 1 has `no_S_nested_in_U` after box-normalization. If we can prove `no_S_nested_in_U → is_separable` WITHOUT the axiom... that's exactly `no_S_nested_sep`, which is the original blocker.

So Path 4 reduces to the same problem. NOT a shortcut.

## Recommendation

**Path 2 (sub-formula replacement) is the most promising** but requires solving the `has_single_U_type` contamination from Case 2. The approach should be:

1. Define a COMBINED theorem that does NOT require `has_single_U_type`:
   ```
   no_S_nested_sep phi (hns : no_S_nested_in_U phi) : is_separable phi
   ```
   by double induction on `(count_U_subformulas, snce_depth_of_U)`:
   - If U-free: separated
   - If `count_U_subformulas >= 2`: extract one U-type, abstract, IH reduces count. Substitute back. Callbacks have single U-type → handled by inner induction.
   - If `count_U_subformulas = 1` (single U-type): induction on `snce_depth_of_U`.
     - Depth 0: separated
     - Depth >= 1: replace innermost `.snce` via 10.2.4. Result may have multiple U-types (from Case 2), but `count_U_subformulas` is bounded and `snce_depth_of_U` decreased. Outer IH handles.

2. The key insight: after 10.2.4, the formula may gain U-types (Case 2 adds `(neg A, top)`), but `count_U_subformulas` goes from 1 to at most K (bounded by case output). And `snce_depth_of_U` has decreased by 1. So the measure `(count_U_subformulas, snce_depth_of_U)` in lex order: the inner component decreased, and even if the outer component increased, the combined measure is well-founded IF we can bound the increase.

**Critical question for feasibility**: Does 10.2.4 applied at depth 1 produce a formula whose `count_U_subformulas` is bounded by a CONSTANT (independent of the input formula's count)? If yes, this approach works.

From the case analysis: Case 1 output has `count_U_subformulas = 1`. Case 2 output has `count_U_subformulas = 2` (two distinct U-types). Worst case across all 8 cases: need to determine the maximum.

If the maximum is K, then after applying 10.2.4 at the innermost `.snce`, `count_U_subformulas` goes from 1 to at most K, and `snce_depth_of_U` decreases by 1. Using lex `(snce_depth_of_U, count_U_subformulas)`:
- If `snce_depth >= 1`: apply 10.2.4, depth decreases → lex decrease regardless of count change
- This is just `snce_depth_of_U` induction! We don't even need the count component!

**Wait — this might actually work.** The sub-formula replacement at the innermost `.snce` strictly decreases `snce_depth_of_U`, and we don't need `has_single_U_type` for the IH — just `no_S_nested_in_U`. The Case 2 U-type contamination doesn't matter because the IH is not restricted to single-U-type formulas.

The catch: after replacement, does the formula still have `no_S_nested_in_U`? The 10.2.4 output introduces new `.untl` nodes (from Case 2's `all_future(neg A)`), but their args are S-free (since A, B were S-free). And the new `.snce` nodes in the output (from `case1_psi`) have U-free args. So `no_S_nested_in_U` is preserved.

**THIS MIGHT BE THE SOLUTION.** Research needed: verify `no_S_nested_in_U` preservation through 10.2.4 case outputs, and implement the sub-formula replacement infrastructure.
