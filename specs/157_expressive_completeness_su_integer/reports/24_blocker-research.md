# Research Report: Phase B Blocker Analysis

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Session**: sess_1779239629_b3ced3
**Date**: 2026-05-19
**Focus**: Identify the correct way to avoid the Phase B blocker by studying GHR94's actual proof mechanism

---

## Executive Summary

The Phase B blocker arises from a mismatch between two strategies:
- `extract_innermost_U_type` finds non-surface `.untl` nodes (needed for U-free args)
- `count_U_subformulas` is flat at `.untl` (returns 1, does not recurse into `.untl` children)

This mismatch makes the inner `count_U_subformulas` induction fail at depth >= 2. Study of GHR94 Chapter 10.2 reveals that the root cause is our formalization deviating from GHR94's proof architecture. GHR94's 10.2.7 uses a **two-level abstraction** (flatten U-args, then separate, then back-substitute) whereas our code uses **one-at-a-time U-abstraction** with `count_U_subformulas` induction.

**Recommended resolution**: Path 1 (`count_U_total`) -- define a total U-count measure that recurses into ALL formula children including `.untl` args. This is the minimal-effort fix that preserves the existing code architecture.

**Alternative resolution**: A faithful GHR94 reimplementation (two-level abstraction) would be more elegant but requires significantly more infrastructure and risks destabilizing existing working code.

---

## Literature Proof Structure

**Source**: Gabbay, Hodkinson, Reynolds (1994), *Temporal Logic: Mathematical Foundations and Computational Aspects*, Vol. 1, Chapter 10, Section 10.2, pp. 569-592.

**Strategy**: Layered inductive elimination, bottom-up through four lemmas.

### Step Map

1. **Lemma 10.2.3** (8 elimination cases) -- Each form S(a +/- U(A,B), q +/- U(A,B)) where a, q, A, B are atoms is equivalent to a formula where U appears only as U(A,B) and not under any S.
   - Source: pp. 570-574
   - Lean: `SeparationThm.lean` (Cases 1-8 proved as theorems)

2. **Lemma 10.2.4** (single S with top-level U(A,B)) -- If C, F have U only as U(A,B) at top level (not under S), then S(C, F) is separable with U only as U(A,B).
   - Source: pp. 574-575
   - Lean: `snce_single_U_depth_one_separable` in `Hierarchy.lean`
   - Mechanism: DNF/CNF normalization of C, F reduces to the 8 cases of 10.2.3

3. **Lemma 10.2.5** (single U-type, arbitrary S-nesting) -- If A, B are built without S or U and U only appears in D as U(A,B), then D is separable with U only as U(A,B).
   - Source: pp. 575-576
   - Lean: `single_U_formula_separable_noax_param` in `Hierarchy.lean`
   - Mechanism: Induction on maximum S-nesting above U(A,B). Apply 10.2.4 to innermost S containing U(A,B), reducing S-nesting by 1.
   - **Key GHR94 property**: 10.2.4 preserves "U only appears as U(A,B)" -- this is stated in 10.2.4's conclusion.

4. **Lemma 10.2.6** (multiple U-types, single U-nesting level) -- If A_i, B_i are built without S or U and U only appears as U(A_i, B_i), then D is separable.
   - Source: pp. 576-577
   - Lean: `lemma_10_2_6_self_contained_param` in `Hierarchy.lean`
   - Mechanism: Induction on number n of distinct U-types. Separate for U(A_n, B_n) by abstracting other U-types to atoms, apply 10.2.5, then back-substitute and apply IH (n-1 distinct types).

5. **Lemma 10.2.7** (no S nested in U, arbitrary U-nesting) -- If D has no S nested within any U, then D is separable.
   - Source: pp. 577-578
   - Lean: `no_S_nested_in_U_separable_direct_param` in `Hierarchy.lean`
   - Mechanism: Induction on maximum U-nesting depth n.
     - n = 1: Apply 10.2.6
     - n > 1: **Two-level abstraction** (see detailed analysis below)

6. **Lemma 10.2.8** (full separation) -- Any formula is separable.
   - Source: pp. 578-580
   - Lean: `all_formulas_separable_aux` in `Hierarchy.lean`
   - Mechanism: Induction on junction depth.

### Dependencies

- Step 2 depends on Step 1
- Step 3 depends on Step 2
- Step 4 depends on Step 3
- Step 5 depends on Step 4
- Step 6 depends on Step 5

### GHR94's Mechanism at Depth >= 2 of Lemma 10.2.7

This is the critical passage (p. 577):

> *Case n > 1*: Let U(A_i, B_i) (i = 1, ..., N) be some subformulae of D such that every appearance of U in D is as a subformula of an appearance of one of the U(A_i, B_i). Each A_i and B_i are built up as a boolean combination from wffs of the form U(X_ij, Y_ij) and atoms. Replace each U(X_ij, Y_ij) in A_i and B_i by the new atom z_ij to form wffs A'_i and B'_i which are just boolean combinations of atoms. [...]
>
> Replace each occurrence of U(A_i, B_i) [...] in D by U(A'_i, B'_i) to obtain D', which can be separated by the preceding lemma.

GHR94's approach at depth >= 2 has THREE phases:

**Phase I -- Flatten**: For each maximal U-subformula U(A_i, B_i) in D, abstract all sub-U nodes U(X_ij, Y_ij) inside A_i and B_i, replacing with fresh atoms z_ij. This gives U(A'_i, B'_i) where A'_i, B'_i are atom-only (hence U-free). Replace U(A_i, B_i) with U(A'_i, B'_i) in D to get D'.

**Phase II -- Separate**: D' has no S nested in U and U-nesting depth 1 (because A'_i, B'_i are atom-only). Apply Lemma 10.2.6 to separate D' into E'.

**Phase III -- Back-substitute**: Replace each z_ij with U(X_ij, Y_ij) in E' to get E equivalent to D. E is not separated because the pure-past constituents of E' now contain U(X_ij, Y_ij). But "the level of nesting of U in U(A_i, B_i) must be strictly greater than that in its subformula U(X_ij, Y_ij)", so the IH applies to each impure constituent.

**Why this works without an oracle**: The IH at depth n gives separability for formulas with U-nesting depth < n. After back-substitution, the impure constituents have U-nesting depth < n (because U(X_ij, Y_ij) was a proper sub-U of U(A_i, B_i), so its nesting depth is strictly less). No circular dependency.

---

## Analysis of the Blocker

### Why Our Code Doesn't Match GHR94

Our `no_S_nested_in_U_separable_direct_param` (line 2599) at depth >= 2 does:

1. Extract a SURFACE `.untl A B` via `extract_U_type` (finds the first `.untl` without entering `.untl` children)
2. Abstract it: `psi = abstract_untl phi A B p`
3. Prove `count_U_subformulas psi < count_U_subformulas phi` (works because surface abstraction decreases surface count)
4. Recurse by inner IH on `count_U_subformulas`
5. Back-substitute using `subst_in_separated_separable_jd psi p A B hAB_sf.1 hAB_sf.2 hpsi_sep oracle`

**Problem at step 5**: `subst_in_separated_separable_jd` threads the oracle. At JD = 1 in `all_formulas_separable_aux`, the oracle can't be supplied from the JD IH. `subst_in_separated_separable_depth` would avoid the oracle, but it requires U-free A, B. At depth >= 2, `extract_U_type` returns A, B that are NOT U-free (they contain nested `.untl` nodes).

**Plan v23's attempted fix**: Use `extract_innermost_U_type` to find U-free A, B. But then `count_U_subformulas` doesn't decrease (because the innermost node is inside a `.untl`, and `count_U_subformulas` is flat at `.untl`).

### The Fundamental Tension (Restated)

| Strategy | Decreasing Measure | Args U-free? | Enables |
|----------|-------------------|--------------|---------|
| `extract_U_type` (surface) | `count_U_subformulas` decreases | No (at depth >= 2) | `subst_in_separated_separable_jd` (needs oracle) |
| `extract_innermost_U_type` (deep) | `count_U_subformulas` does NOT decrease | Yes | `subst_in_separated_separable_depth` (no oracle) |

Neither strategy alone satisfies both requirements: (1) a decreasing measure for IH, and (2) U-free args for oracle-free back-substitution.

---

## Evaluation of the Four Resolution Paths

### Path 1: Define `count_U_total` (RECOMMENDED)

**Idea**: Define a new measure that recurses into ALL formula children, including `.untl` args:

```lean
def count_U_total : Formula -> Nat
  | .atom _ => 0
  | .bot => 0
  | .imp a b => count_U_total a + count_U_total b
  | .box a => count_U_total a
  | .untl a b => 1 + count_U_total a + count_U_total b  -- recurse INTO children
  | .snce a b => count_U_total a + count_U_total b
```

**Why it works**: `abstract_untl phi A B p` replaces every occurrence of `.untl A B` in phi with `.atom p`. If `.untl A B` appears anywhere in phi (at any depth), each occurrence contributes `1 + count_U_total A + count_U_total B >= 1` to `count_U_total phi`. After replacement, it contributes 0. So `count_U_total` strictly decreases.

**What's needed**:
1. Define `count_U_total` (~10 LOC)
2. Define `contains_untl_deep : Formula -> Formula -> Formula -> Prop` (~10 LOC) that says `.untl A B` appears anywhere, including inside other `.untl` nodes
3. Prove `abstract_untl_count_total_lt_of_contains_deep` (~25 LOC): when `contains_untl_deep phi A B`, abstracting strictly decreases `count_U_total`
4. Prove `extract_innermost_U_type_contains_deep` (~20 LOC): `extract_innermost_U_type` finds a node satisfying `contains_untl_deep`
5. Rewrite the depth >= 2 case of `no_S_nested_in_U_separable_direct_param` to use `count_U_total` + `extract_innermost_U_type` + `subst_in_separated_separable_depth`

**Estimated effort**: ~100 LOC new infrastructure, ~30 LOC modifications to existing code.

**Risk**: Low. The `count_U_total` measure is straightforward. The `abstract_untl` decrease proof follows the same pattern as `abstract_untl_count_lt_of_contains_surface` but with an additional recursive case for `.untl c d` where `c = A /\ d = B` is false (recurse into c and d).

**GHR94 alignment**: This captures GHR94's argument in a one-at-a-time fashion. GHR94 flattens ALL sub-Us from maximal U-args simultaneously; we abstract ONE innermost U at a time, decreasing `count_U_total` each time. The end result is the same: eventually all Us at the current nesting level are eliminated.

### Path 2: Skip Phase B, Go to Phase C Combined Theorem

**Idea**: Merge 10.2.5/10.2.6/10.2.7 into a single well-founded induction on `(U_nesting_depth, count_U_subformulas)` lexicographic.

**Problem**: This doesn't resolve the fundamental tension. The combined theorem still needs to handle depth >= 2 somewhere, and the same mismatch between surface/deep extraction and count measures applies. Moving to a combined theorem changes WHERE the problem appears but not WHETHER it appears.

**Verdict**: Not recommended as a standalone fix. If Path 1 is implemented, Phase C becomes trivial (just use the now-oracle-free 10.2.7).

### Path 3: Keep Current Code at Depth >= 2

**Idea**: Continue using `extract_U_type` (surface) + `subst_in_separated_separable_jd` (oracle) at depth >= 2. Accept the oracle dependency.

**Problem**: This defeats the purpose of the task. The oracle falls back to `all_separable` which uses 4 axioms. The entire point of Phase B is to eliminate the oracle.

**Verdict**: Not acceptable. Violates plan prohibition #9 and the task's core goal.

### Path 4: `U_nesting_depth` Strictly Decreasing

**Idea**: Prove that abstracting the innermost `.untl` on the maximum-depth path strictly reduces `U_nesting_depth`.

**Problem**: `abstract_untl` replaces ALL occurrences of `.untl A B`, not just the one on the max-depth path. If the same `.untl A B` appears at both depth 1 and depth 2 in the formula, abstracting it might not decrease `U_nesting_depth` because both occurrences are removed. More precisely:

Consider `phi = .imp (.untl A B) (.untl (.untl A B) C)`. Here `U_nesting_depth = 2`. After abstracting `.untl A B`, we get `phi' = .imp (.atom p) (.untl (.atom p) C)`. Now `U_nesting_depth phi' = 1 + max(0, U_nesting_depth C)`. If C is U-free, this is 1. So depth decreased from 2 to 1 -- it works here.

But consider `phi = .imp (.untl X Y) (.untl (.untl A B) C)` where `.untl A B` is the innermost with U-free args, and `.untl X Y` is a different surface U-node with `U_nesting_depth X >= 1`. After abstracting `.untl A B`: `phi' = .imp (.untl X Y) (.untl (.atom p) C)`. Then `U_nesting_depth phi' = max(1 + max(U_nesting_depth X, U_nesting_depth Y), 1 + max(0, U_nesting_depth C))`. If X has depth 1 (i.e., X contains its own `.untl`), then `U_nesting_depth phi' = 2`. The depth didn't decrease!

**Verdict**: Unreliable. Does not generically work. Would require identifying a `.untl A B` that appears on ALL maximum-depth paths, which is a much harder algorithmic problem.

---

## Addressing the Key Question

> GHR94's 10.2.5 is self-contained (uses only 10.2.4). Our 10.2.5 needs an oracle because `has_single_U_type` isn't preserved through our elimination cases. What is GHR94's actual mechanism at depth >= 2 of 10.2.5, and can we replicate it faithfully?

### GHR94's Mechanism at Depth >= 2 of 10.2.5

GHR94's 10.2.5 says: induction on S-nesting k above U(A,B). At k > 0, apply 10.2.4 to the most deeply nested S(C,F) containing U(A,B). The result has U only as U(A,B) (by 10.2.4's conclusion) and S-nesting k-1. IH gives the result.

The critical property is: **10.2.4 preserves "U only appears as U(A,B)"**. This is stated explicitly in 10.2.4's conclusion and is the content of the 8 elimination cases in 10.2.3.

### Why Our Encoding Breaks This

Our 10.2.5 (`single_U_formula_separable_noax_param`) at depth >= 2:
1. Gets IH: C, F are separable
2. Gets separated C', F'
3. Forms `.snce C'' F''` (box-normalized)
4. Calls oracle on `.snce C'' F''`

The issue is step 2-3. The separated forms C', F' are GENERAL separated formulas, not necessarily preserving `has_single_U_type`. Our 10.2.4 analog (`snce_single_U_depth_one_separable`) handles snce_depth_of_U = 1 correctly, but the RESULT of applying the 8 elimination cases introduces `all_future` (= `.untl (neg top) _`) and `all_past` (= `.snce (neg top) _`), which create NEW U/S-types not present in the original formula.

In GHR94, G and H are treated as abbreviations. Their result explicitly claims "U only appears as U(A,B)." But our Lean encoding expands G to `neg (untl top (neg _))` which creates a `.untl top (neg _)` node -- a DIFFERENT U-type from `U(A,B)`.

### Can We Fix This?

Fixing `has_single_U_type` preservation through the 8 cases would require ensuring that the elimination cases never introduce `all_future`/`all_past` or any other `.untl`/`.snce` constructors with args different from A, B. This is fundamentally incompatible with our formula representation because:

- Case 2 uses `neg U(A,B)` which expands via 10.2.2 to `G(neg A) \/ U(neg A /\ neg B, neg A)`. The `G(neg A)` = `all_future (neg A)` introduces a `.untl` with different args.
- Cases 4, 6, 8 similarly introduce `all_future`/`all_past`.

In GHR94, these are boolean building blocks at the TOP LEVEL (not under S), so the claim "U only appears as U(A,B)" is maintained in the sense that no new U-type is UNDER an S. But syntactically, new U-types do appear. GHR94 can keep "U only as U(A,B)" because `G(neg A)` is semantically pure future and doesn't need further elimination. Our encoding doesn't distinguish "U at top level (harmless)" from "U under S (needs elimination)."

### The Right Fix

Rather than fixing `has_single_U_type` preservation (which the plan correctly marks as DEAD), the right approach is to fix the measure in 10.2.7 so that `extract_innermost_U_type` has a compatible decreasing measure. **Path 1 (`count_U_total`) achieves this.**

With `count_U_total`, the oracle in 10.2.5 is bypassed entirely:
- At depth >= 2 of 10.2.5, instead of calling an oracle on `.snce C'' F''`, we can call `no_S_nested_in_U_separable_direct_param` which is now oracle-free (thanks to Path 1 fixing 10.2.7).
- But wait -- this is circular if 10.2.7 itself calls 10.2.5.

Actually, 10.2.7 calls 10.2.6 which calls 10.2.5. And 10.2.5 at depth >= 2 calls... the oracle, which is supposed to handle `no_S_nested_in_U` formulas with JD <= 1.

The real fix chain is:
1. Fix 10.2.7 (Path 1: `count_U_total` + `extract_innermost_U_type` + `subst_in_separated_separable_depth`). This makes 10.2.7 oracle-free.
2. In `all_formulas_separable_aux`, the n=1 case can now use oracle-free 10.2.7 directly.
3. The oracle in 10.2.5 and 10.2.6 is supplied by `all_formulas_separable_aux` via JD IH. At JD >= 2, the IH handles it. At JD = 1, the oracle is supplied by the now-working n=1 path.

Wait, but the n=1 case in `all_formulas_separable_aux` IS the one that needs the oracle. Let me trace through again:

At JD = 1 in `all_formulas_separable_aux`:
- `.snce a b` node with JD = 1
- Structural IH gives separable a, b
- Box-normalize to `.snce chi_a chi_b`
- This has `no_S_nested_in_U` and `JD <= 1`
- Call `no_S_nested_in_U_separable_direct_param` on it

If 10.2.7 is oracle-free, we can call it directly without needing to supply an oracle. The oracle parameter is REMOVED from `no_S_nested_in_U_separable_direct_param`. Then at JD = 1, we just call the oracle-free 10.2.7.

But 10.2.7 internally uses 10.2.6 which uses 10.2.5. 10.2.5 at depth >= 2 currently needs an oracle. If 10.2.5's oracle is supplied by `all_formulas_separable_aux` (JD IH), then at JD = 1, we can't supply it.

**The solution**: Make 10.2.5 oracle-free TOO. This requires the `.snce C'' F''` at depth >= 2 of 10.2.5 to be handled without an oracle. The `.snce C'' F''` has `no_S_nested_in_U` and `JD <= 1`. If 10.2.7 is oracle-free, we can call it. But 10.2.7 calls 10.2.6 which calls 10.2.5 -- circular!

Breaking the circle: 10.2.5's depth >= 2 case produces `.snce C'' F''` where C'', F'' are box-normalized separated formulas. This formula has `U_nesting_depth <= 1` (via `snce_of_boxfree_sep_jd_le_one` -- actually this gives JD <= 1, but the `U_nesting_depth` bound needs checking).

Let me check: does `.snce C'' F''` at depth >= 2 of 10.2.5 have `U_nesting_depth <= 1`?

C'' = `replace_box_with_top C'` where C' is a separated formula equivalent to C. C has `has_single_U_type C A B` with A, B both S-free and U-free. C' is the separated equivalent of C. In C', every `.untl` node has S-free args (by syntactic separation). After box-normalization to C'', every `.untl` node still has S-free args. The `.untl` nodes in C'' come from the separation process applied to C.

Do the `.untl` nodes in C'' have U-free args? Not necessarily. Separation may produce `.untl X Y` where X, Y are S-free but contain `.untl` nodes.

Actually, wait. C had `has_single_U_type C A B` with A, B U-free. C' is a separated formula. In C', U appears as `.untl X Y` where X, Y are S-free. But these are NEW U-types introduced by the 8 elimination cases. These new U-types might have `U_nesting_depth > 0` (e.g., `all_future (neg A)` which is `.untl (neg top) (neg (neg A))` has `U_nesting_depth = 1`). And since C' is separated, its `.untl` nodes have S-free args, so `U_nesting_depth(.untl X Y) = 1 + max(U_nesting_depth X, U_nesting_depth Y)`. If X, Y are S-free atoms, the depth is 1. But if the elimination cases produce nested `.untl` in X or Y, the depth could be > 1.

This is related to plan prohibition #5: "NO false U-nesting-depth bounds: Box-normalized separated formulas CAN have U_nesting_depth > 1."

So `.snce C'' F''` at depth >= 2 of 10.2.5 might have `U_nesting_depth > 1`. If we have oracle-free 10.2.7, we can handle it. The key question is whether calling 10.2.7 from 10.2.5 creates a circular dependency.

**The termination argument**: 10.2.5 inducts on `snce_depth_of_U`. At depth >= 2, it calls IH to separate C, F (depth decrease). Then it forms `.snce C'' F''` and calls 10.2.7 on it. 10.2.7 inducts on `U_nesting_depth` and `count_U_total`. It calls 10.2.6 which calls 10.2.5. But 10.2.5 is called with a formula that has `has_single_U_type chi A' B'` where A', B' are S-free and U-free. The `snce_depth_of_U` of this formula is bounded by `snce_depth_of_U` of `.snce C'' F''`.

Hmm, this gets complicated. The real question is: does the combined system of 10.2.5/10.2.6/10.2.7 terminate?

**Yes**, it terminates because: 10.2.7 inducts on `(U_nesting_depth, count_U_total)` and calls 10.2.6 with `U_nesting_depth <= 1`. 10.2.6 inducts on `count_U_subformulas` (which works at depth 1) and calls 10.2.5. 10.2.5 inducts on `snce_depth_of_U` and at depth >= 2, the callback formula has `no_S_nested_in_U` -- so we can call 10.2.7 on it (not 10.2.5 recursively). 10.2.7 on this callback has `U_nesting_depth <= 1` (because the callback formula's `.untl` nodes come from back-substituting a single U(A,B) with U-free A,B into U-free separated formulas).

Actually wait. The callback from `subst_in_separated_separable_depth` at the 10.2.6 level gives formulas with `U_nesting_depth <= 1`. So when 10.2.5 at depth >= 2 calls 10.2.7 on the callback formula, 10.2.7 reduces to 10.2.6 (depth <= 1 case). 10.2.6 calls 10.2.5. 10.2.5 on these formulas has `has_single_U_type` and inducts on `snce_depth_of_U`. At depth >= 2, it calls oracle... which is 10.2.7... which calls 10.2.6... circular!

**The real solution**: The oracle in 10.2.5 at depth >= 2 receives `.snce C'' F''` which has:
- `no_S_nested_in_U`: yes (from `snce_of_boxfree_sep_no_S_nested`)
- `junction_depth <= 1`: yes (from `snce_of_boxfree_sep_jd_le_one`)

The oracle type is: `forall chi, no_S_nested_in_U chi -> junction_depth chi <= 1 -> is_separable chi`.

If we make 10.2.7 oracle-free, then at JD = 1 in `all_formulas_separable_aux`, we call oracle-free 10.2.7 directly on `.snce chi_a chi_b`. This is fine.

But 10.2.7 internally calls 10.2.6 which calls 10.2.5 which at depth >= 2 needs the oracle. The oracle that 10.2.5 needs is the SAME type: `no_S_nested_in_U chi -> junction_depth chi <= 1 -> is_separable chi`.

If 10.2.7 doesn't take an oracle but 10.2.5 still does, 10.2.7 needs to provide the oracle to 10.2.5. But 10.2.7 doesn't have a way to do that without an oracle of its own...

**Unless** we restructure 10.2.5 to not need an oracle at all. 10.2.5 at depth >= 2 forms `.snce C'' F''` with `no_S_nested_in_U`. If we can call 10.2.7 (oracle-free) on it directly, we break the dependency. But 10.2.7 calls 10.2.6 calls 10.2.5 -- so 10.2.5 must be a parameter to 10.2.7, not the reverse.

**The correct architecture** (matching GHR94):
- Make ALL of 10.2.5, 10.2.6, 10.2.7 into a SINGLE mutual/combined induction
- Or: make 10.2.5 self-contained (which GHR94 achieves because `has_single_U_type` IS preserved)

Since `has_single_U_type` preservation is dead in our encoding, the right approach is the combined induction. This means Phase C's approach (combined theorem) IS needed after all, but COMBINED with Path 1's `count_U_total`.

**Revised recommendation**: Combine Paths 1 and 2:
1. Define `count_U_total` and `contains_untl_deep` (Path 1 infrastructure)
2. Write a combined theorem `no_S_nested_sep_oracle_free` that merges 10.2.5/10.2.6/10.2.7 into a single well-founded induction on the lexicographic tuple `(U_nesting_depth, count_U_total)` (Path 2 structure)
3. Use `extract_innermost_U_type` + `count_U_total` at depth >= 2 for the inner step
4. Use `subst_in_separated_separable_depth` for oracle-free back-substitution

---

## Detailed Resolution: Combined Theorem with `count_U_total`

### Well-Founded Induction Measure

Induct on `(U_nesting_depth phi, count_U_total phi)` lexicographically with `no_S_nested_in_U phi` as a precondition.

### Case Analysis

**Base case**: `is_U_free phi = true`. Formula is already separated.

**U_nesting_depth = 1**: All `.untl` nodes have U-free args (S-free by `no_S_nested_in_U`). Use `extract_U_type` (surface) to find `.untl A B`. Abstract it. `count_U_total` strictly decreases (the surface `.untl` contributes 1 to `count_U_total`). The abstracted formula has same or lower `U_nesting_depth`. By IH on `(U_nesting_depth, count_U_total)`, the abstracted formula is separable. Back-substitute via `subst_in_separated_separable_depth` (A, B are U-free). The callback formula has `U_nesting_depth <= 1` (already proved by `callback_U_nesting_depth_le_one`). Recurse.

**U_nesting_depth >= 2**: Use `extract_innermost_U_type` to find `.untl A B` with U-free args. Abstract it. `count_U_total` strictly decreases (the deep `.untl` contributes >= 1 to `count_U_total`). `U_nesting_depth` is `<=` (already proved by `abstract_untl_U_nesting_depth_le_of_le`). By IH on `(U_nesting_depth, count_U_total)`, the abstracted formula is separable. Back-substitute via `subst_in_separated_separable_depth` (A, B are U-free). The callback formula has `U_nesting_depth <= 1` (already proved). Recurse -- and the callback lands in the depth = 1 case, which is handled.

### How `single_U_formula_separable_noax_param` Fits

The combined theorem replaces the chain 10.2.5 -> 10.2.6 -> 10.2.7 with a single theorem. The `single_U_formula_separable_noax_param` (10.2.5) is called from `subst_in_separated_separable_depth`'s callback. But the callback formula has `U_nesting_depth <= 1`, so within 10.2.5, the formula has `has_single_U_type` and `snce_depth_of_U` as the induction measure. At depth >= 2 of 10.2.5, the callback formula `.snce C'' F''` has `no_S_nested_in_U` and `JD <= 1`. Instead of calling an oracle, we call the COMBINED theorem recursively.

Wait -- but the combined theorem takes `no_S_nested_in_U` as a precondition. At depth >= 2 of 10.2.5, the callback `.snce C'' F''` does have `no_S_nested_in_U`. So we can call the combined theorem. But what are the measures?

The callback `.snce C'' F''` has `U_nesting_depth <= 1`. But we came from the combined theorem at `U_nesting_depth >= 2` (or >= 1), and within the combined theorem, we called 10.2.6 which called 10.2.5. 10.2.5's induction on `snce_depth_of_U` is a different measure from the combined theorem's `(U_nesting_depth, count_U_total)`. The callback from 10.2.5 wants to call the combined theorem at `U_nesting_depth <= 1`, which is strictly less than the original `U_nesting_depth >= 2`. So the combined theorem's outer measure decreases. This terminates!

### Concrete Architecture

```
theorem no_S_nested_sep_oracle_free (phi : Formula)
    (hns : no_S_nested_in_U phi) : is_separable phi := by
  -- Well-founded induction on (U_nesting_depth, count_U_total) lexicographic
  ...
  -- Within the proof, at depth >= 2:
  --   extract_innermost_U_type -> abstract -> count_U_total decreases -> IH
  --   back-substitute via subst_in_separated_separable_depth
  --   callback: U_nesting_depth <= 1 -> IH (U_nesting_depth decreases)
  -- At depth = 1:
  --   extract_U_type (surface, args U-free) -> abstract -> count_U_total decreases -> IH
  --   back-substitute via subst_in_separated_separable_depth
  --   callback: U_nesting_depth <= 1 -> handled by depth=1 case or base case
```

The key insight: `subst_in_separated_separable_depth`'s callback receives formulas with `U_nesting_depth <= 1`. These are fed directly back to the combined theorem's IH, where the first component `U_nesting_depth` has decreased (from >= 2 to <= 1, or from 1 to <= 1 which maintains the first component but `count_U_total` might decrease).

Actually, for the depth = 1 callback case: the callback has `U_nesting_depth <= 1`. Within the combined theorem at depth = 1, we need `count_U_total` to decrease. The callback formula is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))`. Its `count_U_total` equals `count_U_total (subst c p (.untl A B)) + count_U_total (subst d p (.untl A B))`. Since c, d are U-free (from the separated formula's `.snce` branch), each `subst c p (.untl A B)` has `count_U_total` equal to `(number of atoms p in c) * (1 + count_U_total A + count_U_total B)`. Since A, B are U-free, this simplifies to `(number of atoms p in c)`.

But this callback formula might have a LARGER `count_U_total` than the original formula. So we can't use the combined theorem's IH on `count_U_total` for the callback.

Hmm. Let me reconsider. The callback formula has `no_S_nested_in_U` and `U_nesting_depth <= 1`. Within the combined theorem, at `U_nesting_depth = 1`, we handle it by the depth-1 logic (which is essentially 10.2.6). 10.2.6 uses `count_U_subformulas` (surface count) for induction, which works at depth 1. But `count_U_subformulas` is the WRONG measure for the combined theorem. The combined theorem uses `count_U_total`.

**Solution**: The combined theorem has `count_U_total` as second component of the lexicographic pair. At depth = 1, extracting a surface U and abstracting decreases `count_U_total` (surface U contributes >= 1). So `count_U_total` decreases and the IH applies.

But then the callback from `subst_in_separated_separable_depth` produces a formula with potentially HIGHER `count_U_total`. So we need the callback to be handled differently -- not by the combined theorem's IH, but by 10.2.5 directly.

**Actually, the callback needs its own treatment**. `subst_in_separated_separable_depth`'s callback receives `.snce C' F'` with `no_S_nested_in_U` and `U_nesting_depth <= 1`. This is a single `.snce` node. Its separability follows from 10.2.5-style reasoning applied to C', F'. But 10.2.5 requires `has_single_U_type`, which the callback may not satisfy.

This is getting complex. Let me simplify the architecture.

**Simplest correct approach**: Make the combined theorem call `subst_in_separated_separable_depth` whose callback is... the combined theorem itself (at a strictly lower `U_nesting_depth`). Since the callback formula has `U_nesting_depth <= 1`, and we're at `U_nesting_depth >= 2` (or even >= 1), the first component decreases. For depth = 1, the callback also has `U_nesting_depth <= 1`, but we entered at `U_nesting_depth = 1`. The first component doesn't decrease. We need the second component to decrease.

But the callback formula might have MORE `count_U_total` than the original. So this doesn't work directly.

**The correct combined architecture requires handling the 10.2.5/10.2.6 chain INSIDE the combined theorem WITHOUT creating a `count_U_total` increase.** This means the combined theorem needs to handle the callback differently at depth = 1 vs depth >= 2.

At depth >= 2:
- Callback has `U_nesting_depth <= 1` -> first component decreases -> IH works

At depth = 1:
- We're doing one-at-a-time abstraction with `count_U_total` as inner measure
- Abstract a surface `.untl A B` (U-free args at depth 1) -> `count_U_total` decreases -> IH on second component
- Back-substitute. Callback has `U_nesting_depth <= 1` and is a single `.snce` node with `no_S_nested_in_U`
- Need to handle this callback. It's at depth <= 1 with `no_S_nested_in_U`.
- Call the combined theorem on it. First component: `U_nesting_depth <= 1` = same as current. Second component: `count_U_total` might be larger (back-substitution can increase count).
- So lexicographic IH doesn't apply directly.

**The problem persists.** Back-substitution creates a formula whose `count_U_total` can be larger. This is a fundamental issue with one-at-a-time abstraction + back-substitution.

**GHR94's resolution**: GHR94 handles back-substitution by noting that the impure constituents have LOWER U-nesting depth. At depth >= 2, this works perfectly. At depth = 1, back-substitution from 10.2.5 is handled by 10.2.4, which produces formulas where "U only appears as U(A,B)" -- so no recursion is needed (the result is already separated w.r.t. that U-type). The `has_single_U_type` preservation is what makes GHR94's 10.2.5 self-contained.

Since we can't preserve `has_single_U_type`, we need a different approach for the depth = 1 callback.

**Revised insight**: At depth = 1, the callback formula from `subst_in_separated_separable_depth` is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free and A, B are U-free (at depth 1). So the callback has:
- `no_S_nested_in_U`: yes
- `U_nesting_depth <= 1`: yes (proved by `callback_U_nesting_depth_le_one`)
- `has_single_U_type _ A B`: yes (proved by `callback_has_single_U_type`)

Since the callback DOES have `has_single_U_type`, we can use `single_U_formula_separable_noax_param` on it. But this is at depth >= 2 of 10.2.5 -- wait, no. The `snce_depth_of_U` of the callback might be large.

Actually, `single_U_formula_separable_noax_param` at depth >= 2 calls the oracle. If the oracle is the combined theorem (at U_nesting_depth <= 1), and the combined theorem at U_nesting_depth <= 1 calls `single_U_formula_separable_noax_param`... circular.

**The oracle formulas from 10.2.5 at depth >= 2**: These are `.snce C'' F''` with `no_S_nested_in_U` and `JD <= 1`. These are NOT the callback formulas from `subst_in_separated_separable_depth`. They come from the IH + box-normalization step.

Let me trace through once more, carefully:

**10.2.5 at depth >= 2 (snce_depth_of_U >= 2)**:
1. `.snce C F` with `has_single_U_type (.snce C F) A B`
2. IH: C and F are separable (snce_depth_of_U decreased)
3. Get separated C', F'
4. Box-normalize: C'', F''
5. `.snce C'' F''` has `no_S_nested_in_U` and `JD <= 1`
6. **Need**: `.snce C'' F''` is separable

At step 6, the formula `.snce C'' F''` does NOT have `has_single_U_type`. It has `no_S_nested_in_U`. If we have an oracle-free 10.2.7, we can call it. 10.2.7 uses `(U_nesting_depth, count_U_total)` induction. Inside 10.2.7, at some point, it calls 10.2.6 which calls 10.2.5. The 10.2.5 call is on a formula with `has_single_U_type chi A' B'` where A', B' are U-free and S-free. At depth >= 2 of 10.2.5, it produces another `.snce C''' F'''` with `no_S_nested_in_U` and `JD <= 1`. This formula needs to be handled by 10.2.7 again.

The termination argument works IF we can show that the formula produced at step 6 of 10.2.5, when fed to 10.2.7, eventually terminates. 10.2.7 inducts on `(U_nesting_depth, count_U_total)`. Each call to 10.2.7 from within 10.2.5 is on a formula with `U_nesting_depth` bounded by the formula that entered 10.2.7. But it's not STRICTLY less.

**This is the core circularity problem.** 10.2.5 at depth >= 2 calls 10.2.7, which calls 10.2.6, which calls 10.2.5. The measures used by each lemma are different, and none of them strictly decreases across the full cycle.

**GHR94 avoids this** because 10.2.5 is self-contained (doesn't call 10.2.7). Our encoding can't replicate this.

**The actual solution**: A single combined induction that handles all three lemmas together, using a COMPOSITE well-founded measure that strictly decreases at every recursive step in the combined proof.

The correct measure for the combined theorem is:
`(U_nesting_depth phi, Formula.sizeOf phi)`

At depth >= 2 (within the 10.2.7 part):
- Extract innermost U with U-free args, abstract it
- `count_U_total` decreases -> `sizeOf` decreases (or U_nesting_depth decreases)
- Actually `sizeOf` doesn't necessarily decrease when we abstract a deep node

Hmm. Let me think about this differently.

The measure `(U_nesting_depth, count_U_total)` with lexicographic ordering:
- At depth >= 2: abstract innermost U -> `count_U_total` strictly decreases, `U_nesting_depth` stays <=. So second component decreases.
- Back-substitute callback: `U_nesting_depth <= 1` -> first component strictly decreases (from >= 2 to <= 1). So first component decreases.
- Within the callback (at depth <= 1): abstract surface U -> `count_U_total` strictly decreases. So second component decreases.
- Back-substitute callback from depth-1 handling: `U_nesting_depth <= 1`, same first component. `count_U_total` might increase.

The problem is the last point. Back-substitution CAN increase `count_U_total`. When we substitute `.untl A B` for atom p in a separated formula, each occurrence of p becomes `.untl A B` (count 1 each, replacing 0 from atom). If p occurs k times, `count_U_total` increases by k.

**Key realization**: The back-substitution callback formula is handled by `single_U_formula_separable_noax_param` (10.2.5), NOT by the combined theorem directly. 10.2.5 uses its OWN induction on `snce_depth_of_U`. At depth >= 2, 10.2.5 needs an oracle. If we PROVIDE the oracle as the combined theorem at `U_nesting_depth < current`, and the callback formula has `U_nesting_depth <= 1` while the current formula has `U_nesting_depth >= 1`... the first component doesn't strictly decrease.

**The definitive solution**: Thread the combined theorem as a PARAMETER to 10.2.5/10.2.6 at a fixed `U_nesting_depth` bound. The combined theorem provides a proof for `U_nesting_depth <= 1` formulas using the base case. 10.2.5 at depth >= 2 calls this base case for the oracle. Since the oracle is for `U_nesting_depth <= 1` formulas, and the combined theorem handles `U_nesting_depth <= 1` without calling 10.2.5 at depth >= 2 again (it uses the depth-1 logic directly), there is no circularity.

Wait, but the combined theorem at `U_nesting_depth <= 1` IS the depth-1 logic, which IS 10.2.6, which IS "extract surface U, abstract, IH on count, back-substitute, callback to 10.2.5." And 10.2.5 at depth >= 2 calls the oracle... which is the combined theorem at `U_nesting_depth <= 1`... which calls 10.2.6... which calls 10.2.5... circular.

**Let me reconsider fundamentally.** The issue is that 10.2.5 at depth >= 2 produces a formula that needs to be separated, and that formula has `no_S_nested_in_U` but arbitrary `U_nesting_depth`. If its `U_nesting_depth <= 1`, we're in the base case of 10.2.7 and can use 10.2.6 directly. 10.2.6 calls 10.2.5 which at depth >= 2 calls the oracle... and the oracle formula also has `U_nesting_depth <= 1`... and we're in an infinite descent.

But wait -- the oracle formula from 10.2.5 at depth >= 2 has `JD <= 1`. `JD <= 1` for a formula with `no_S_nested_in_U` means: the formula is a boolean combination of atoms and `.untl A B` with S-free args (no `.snce` with `.untl` inside). This means `snce_depth_of_U = 0` or `snce_depth_of_U = 1`.

If `snce_depth_of_U = 1` (there's an S with a U inside), then 10.2.5 is at the leaf case (depth = 1), which applies 10.2.4 directly without calling the oracle. So the oracle is NOT called at depth = 1.

If `snce_depth_of_U >= 2`, that's impossible for a JD <= 1 formula. A JD <= 1 formula has at most one level of U-S alternation. `snce_depth_of_U >= 2` would require S(... U(...) ...) inside another S, which would give JD >= 2. So `snce_depth_of_U <= 1`.

**Therefore**: 10.2.5's oracle is only called at depth >= 2, but the oracle formula has `JD <= 1` which forces `snce_depth_of_U <= 1`. At depth = 1, 10.2.5 uses the leaf case (10.2.4) directly, no oracle. At depth = 0, the formula is already separated. So the oracle is NEVER actually invoked in the recursive chain!

This means: 10.2.5 at depth >= 2 calls oracle on `.snce C'' F''` with `JD <= 1`. The oracle runs 10.2.7 on it. 10.2.7 at depth <= 1 calls 10.2.6. 10.2.6 abstracts one U, back-substitutes, callback to 10.2.5. 10.2.5 receives a formula with `has_single_U_type` and `snce_depth_of_U = 1` (forced by `JD <= 1`). At depth = 1, 10.2.5 uses the leaf case. **Done. No further oracle calls.**

So the oracle IS needed but it's only invoked ONCE per depth >= 2 call, and then terminates. The combined theorem at `U_nesting_depth <= 1` handles it in finite steps.

**The actual fix for the JD = 1 case in `all_formulas_separable_aux`**:

At JD = 1:
1. `.snce a b` node
2. Structural IH: a, b separable
3. Box-normalize: `.snce chi_a chi_b`
4. Has `no_S_nested_in_U` and `JD <= 1`
5. Call `no_S_nested_in_U_separable_direct_param` with the oracle being... what?

The oracle for `no_S_nested_in_U_separable_direct_param` is: `forall chi, no_S_nested_in_U chi -> junction_depth chi <= 1 -> is_separable chi`.

At JD = 1 in `all_formulas_separable_aux`, can we provide this oracle? The JD IH is: `ih_jd n' (n' < n) psi (JD psi <= n') -> is_separable psi`. At n = 1, `ih_jd 0 (0 < 1) psi (JD psi <= 0) -> is_separable psi`. This handles JD = 0 formulas.

The oracle requires handling JD <= 1 formulas. JD = 0 is handled by `ih_jd 0`. JD = 1 is the current level. Can we handle JD = 1 oracle formulas?

An oracle formula at JD = 1 has `no_S_nested_in_U` and `JD = 1`. But we're currently PROVING separability of a JD = 1 formula. So using the oracle on another JD = 1 formula is circular.

**Unless** the oracle formula is structurally smaller. But it isn't -- it's produced by back-substitution which can make it larger.

**Wait. Let me re-read the analysis above.** I showed that the oracle from 10.2.5 is called on `.snce C'' F''` with `JD <= 1` and `snce_depth_of_U <= 1`. Then 10.2.7 -> 10.2.6 -> 10.2.5 handles it at leaf depth = 1 using 10.2.4. No further oracle calls.

So the oracle at JD = 1 is used ONCE, and the recursive call terminates without invoking the oracle again. This means the oracle call at JD = 1 is NOT circular -- it's a finite chain that terminates.

But Lean's type system doesn't know this. The oracle parameter has type `forall chi, no_S_nested_in_U chi -> JD chi <= 1 -> is_separable chi`. Lean needs to know this function terminates. If we define it as part of the JD = 1 proof, we need well-founded recursion.

**The fix**: Instead of parameterizing by an oracle, USE a self-recursive call. Make `no_S_nested_in_U_separable_direct_param` into `no_S_nested_in_U_separable_oracle_free` that doesn't take an oracle parameter. Inside, it handles everything directly.

But then 10.2.5 at depth >= 2 needs to call 10.2.7, and 10.2.7 calls 10.2.6 calls 10.2.5. Lean won't accept this mutual recursion without showing termination on a common measure.

**FINAL RESOLUTION**: Use a SINGLE combined theorem with the measure `(U_nesting_depth phi, count_U_total phi)` lexicographic:

```lean
theorem no_S_nested_sep_oracle_free (phi : Formula) (hns : no_S_nested_in_U phi) :
    is_separable phi := by
  -- WF induction on (U_nesting_depth, count_U_total) lex
  induction phi using WellFoundedRelation.wf.induction with ...
```

Within this single theorem:
- Base: U-free -> separated
- Surface U with U-free args (depth <= 1): abstract, `count_U_total` decreases -> IH. Back-substitute. Callback has `U_nesting_depth <= 1` and `has_single_U_type`. Call `single_U_formula_separable_noax_param` with oracle = self at `U_nesting_depth <= 1`.
- Deep U with U-free args (depth >= 2): abstract, `count_U_total` decreases -> IH. Back-substitute. Callback has `U_nesting_depth <= 1` -> IH (first component decreases).

And within `single_U_formula_separable_noax_param`, the oracle is the combined theorem itself. 10.2.5 at depth >= 2 calls the oracle on `.snce C'' F''` with `no_S_nested_in_U` and `JD <= 1`. The oracle is the combined theorem. This call has `U_nesting_depth <= 1` (bounded by the separated formula). But the combined theorem was entered at some `U_nesting_depth`. If the combined theorem was entered at `U_nesting_depth >= 2`, then calling it at `<= 1` decreases the first component. If entered at `U_nesting_depth = 1`, then the oracle formula has `snce_depth_of_U <= 1`, so 10.2.5 is at depth = 1 (leaf), no oracle call.

**The measure actually works**: `(U_nesting_depth, count_U_total)` lexicographic.
- Abstracting: second component decreases, first stays <=
- Back-substitution callback: `U_nesting_depth <= 1`. If current `U_nesting_depth >= 2`, first decreases. If current `U_nesting_depth = 1`, the callback has `snce_depth_of_U <= 1`, so 10.2.5 at leaf depth (no further recursion).

But wait, the "no further recursion at leaf depth" isn't captured by the measure. The measure `(U_nesting_depth, count_U_total)` doesn't account for `snce_depth_of_U` within the 10.2.5 logic.

**The triple measure**: `(U_nesting_depth, count_U_total, snce_depth_of_U)` lexicographic.
- Abstracting: second component decreases
- Back-substitution callback: first or second component decreases  
- 10.2.5 IH (at depth >= 2 within 10.2.5): third component decreases
- 10.2.5 at depth = 1: handled by 10.2.4 (no recursion)
- Oracle from 10.2.5 at depth >= 2: `U_nesting_depth <= 1` -> first component may decrease. If same, `count_U_total` might be different. But `snce_depth_of_U <= 1` -> third component <= 1 while we entered 10.2.5 at `snce_depth_of_U >= 2` -> third decreases.

Actually this triple measure seems to capture the full recursion structure. But it's complex to implement in Lean.

**Simplification**: Instead of a triple, use the fact that within 10.2.5 (which has its own `snce_depth_of_U` induction), the oracle call terminates at the leaf case. So we can keep 10.2.5 as a SEPARATE theorem parameterized by the oracle, and provide the oracle from the combined 10.2.6+10.2.7 theorem.

**Architecture**:
1. `single_U_formula_separable_noax_param` (10.2.5): takes oracle, unchanged
2. `no_S_nested_sep_oracle_free` (combined 10.2.6+10.2.7): does NOT take oracle. Uses `(U_nesting_depth, count_U_total)` induction. Inside, calls `single_U_formula_separable_noax_param` with oracle = self at `U_nesting_depth < current`.
3. `all_formulas_separable_aux`: at JD = 1, calls `no_S_nested_sep_oracle_free` directly.

For step 2, the oracle provided to 10.2.5 is:
```lean
fun chi hns hjd =>
  no_S_nested_sep_oracle_free chi hns  -- self-call, must decrease
```

But the self-call's `(U_nesting_depth, count_U_total)` needs to be smaller. The oracle formula `chi` has `JD <= 1` and `no_S_nested_in_U`. Its `U_nesting_depth` is bounded by... we need to show it's strictly less than the current formula's `U_nesting_depth`.

The current formula in 10.2.5 has `has_single_U_type _ A B` with A, B U-free. So its U_nesting_depth <= 1. The oracle formula `chi` also has `U_nesting_depth` <= ... well, it's produced by separating the `.snce C F` node and box-normalizing. It could have any `U_nesting_depth`.

Hmm, but the combined theorem 10.2.6+10.2.7 handles arbitrary `U_nesting_depth`. So the oracle from 10.2.5 just calls 10.2.6+10.2.7 on the formula. The question is whether the combined theorem's measure decreases.

The formula entering the combined theorem had some `(d, c)`. Inside the combined theorem, we called 10.2.6/10.2.5. 10.2.5 at depth >= 2 calls the oracle on `chi` with `U_nesting_depth chi <= 1` (because chi is box-normalized from separated formulas). If the combined theorem was entered at `d >= 2`, then `U_nesting_depth chi <= 1 < 2 <= d` -> first component decreases -> IH applies.

If the combined theorem was entered at `d = 1`:
- 10.2.6 extracts a surface U with U-free args (depth = 1)
- Abstracts, count_U_total decreases
- Back-substitutes, callback to 10.2.5
- 10.2.5 receives formula with `snce_depth_of_U` which could be >= 2
- 10.2.5 at depth >= 2 calls oracle on chi
- chi has `U_nesting_depth <= 1`
- Self-call to combined theorem at `U_nesting_depth <= 1`, same as entry d = 1
- First component doesn't decrease!
- But `count_U_total chi <= ?` -- we need this to be less than the original

Actually, chi is produced by box-normalizing the separated forms of C, F. It's a completely different formula from the one that entered the combined theorem. Its `count_U_total` is unrelated.

**This is the fundamental issue.** The oracle call from 10.2.5 depth >= 2 produces a formula whose `(U_nesting_depth, count_U_total)` is unrelated to the original formula's measures. So the lexicographic IH can't be used.

**The only way this works is if 10.2.5 depth >= 2 is never reached when the combined theorem is at depth = 1.** Let me verify: when the combined theorem is at depth = 1, 10.2.6 abstracts surface Us (U-free args). Back-substitution gives callback formulas with `has_single_U_type _ A B` where A, B are U-free. 10.2.5 on this formula: it has `snce_depth_of_U` which is bounded by the formula's structure. The formula is `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` where c, d are U-free.

`snce_depth_of_U` of this formula: c, d are U-free, so `subst c p (.untl A B)` has U_nesting_depth <= 1. The `.snce` contributes 1 to `snce_depth_of_U` if U appears below. So `snce_depth_of_U = 1`.

At `snce_depth_of_U = 1`, 10.2.5 is at the LEAF case (depth = 1), which applies 10.2.4 directly. **No oracle call.**

So when the combined theorem is at depth = 1, the callback to 10.2.5 has `snce_depth_of_U = 1` (leaf), and 10.2.5 doesn't call the oracle. The chain terminates!

**This is the KEY observation**: When A, B are U-free (as guaranteed by `extract_U_type` at depth 1 or `extract_innermost_U_type` at depth >= 2), back-substitution into U-free separated formula branches gives callback formulas with `snce_depth_of_U = 1`. This means 10.2.5's leaf case handles them without oracle.

**Therefore**, the oracle in 10.2.5 is NEVER called when the combined theorem is at depth = 1. It IS called at depth >= 2, but then `U_nesting_depth` strictly decreases (from >= 2 to <= 1). The combined theorem at depth <= 1 handles it without calling the oracle.

**Conclusion**: The combined theorem `no_S_nested_sep_oracle_free` with measure `(U_nesting_depth, count_U_total)` DOES terminate. The oracle in 10.2.5 is supplied by the combined theorem. At depth >= 2, oracle calls decrease `U_nesting_depth`. At depth = 1, the oracle is never called (10.2.5 uses the leaf case).

But we need to PROVE in Lean that the oracle is never called at depth = 1. Lean's termination checker won't just accept "it's never called." We need the TYPE SYSTEM to enforce it.

**Practical approach**: Keep 10.2.5 parameterized by oracle. The combined theorem provides the oracle. To satisfy Lean's termination checker, we can use:

```lean
theorem no_S_nested_sep_oracle_free (phi : Formula) (hns : no_S_nested_in_U phi) :
    is_separable phi := by
  induction h : (U_nesting_depth phi, count_U_total phi) using ... with
  | ...
    -- When calling 10.2.5 as a callback, provide oracle =
    --   fun chi hns_chi hjd_chi => no_S_nested_sep_oracle_free chi hns_chi
    -- with termination justified by U_nesting_depth chi <= 1 < U_nesting_depth phi (at depth >= 2)
    -- or by the fact that the oracle is never invoked (at depth = 1, via the Prop argument
    -- that snce_depth_of_U of callback = 1, so 10.2.5 leaf case handles it)
```

For depth = 1, the oracle is passed but never invoked. In Lean, we can pass `fun chi _ _ => absurd ... ...` or `fun chi _ _ => no_S_nested_sep_oracle_free chi ...` -- both are valid since the function is never called. The termination checker only needs to verify calls that are actually reachable.

Actually in Lean 4, termination checking is syntactic. If the oracle is `fun chi _ _ => no_S_nested_sep_oracle_free chi ...`, Lean will check termination of that call regardless of whether it's reachable. So we need the measure to decrease for the oracle call.

At depth = 1: the oracle call would be `no_S_nested_sep_oracle_free chi ...` where chi has `U_nesting_depth <= 1` = same as current. And `count_U_total chi` could be anything. So Lean can't verify termination.

**Practical workaround**: Use `WellFounded.fix` manually with the lexicographic measure, where we can provide a proof that the oracle call's measure is smaller. OR: use a `decreasing_by` tactic. OR: split into two passes.

**Simplest Lean implementation**:

```lean
-- Step 1: Prove depth-1 case without oracle
-- At depth 1, extract_U_type gives U-free args, so subst_in_separated_separable_depth
-- works, and the callback has snce_depth_of_U = 1, so 10.2.5 leaf case handles it.
-- No oracle needed at depth 1!
theorem no_S_nested_sep_depth_one (phi : Formula) (hns : no_S_nested_in_U phi)
    (hd : U_nesting_depth phi <= 1) : is_separable phi := by
  -- Induction on count_U_total (or count_U_subformulas, both work at depth 1)
  -- extract_U_type gives U-free args -> subst_in_separated_separable_depth
  -- callback: snce_depth_of_U = 1 -> 10.2.5 leaf case -> snce_single_U_depth_one_separable
  ...

-- Step 2: Prove depth >= 2 case using depth-1 as oracle
theorem no_S_nested_sep_oracle_free (phi : Formula) (hns : no_S_nested_in_U phi) :
    is_separable phi := by
  -- Induction on (U_nesting_depth, count_U_total) lex
  -- depth >= 2: extract_innermost_U_type -> abstract -> count_U_total decreases -> IH
  --   back-substitute -> callback U_nesting_depth <= 1 -> no_S_nested_sep_depth_one
  -- depth <= 1: no_S_nested_sep_depth_one directly
  ...
```

This cleanly separates concerns:
- `no_S_nested_sep_depth_one` handles U_nesting_depth <= 1 without any oracle. It uses `extract_U_type` (surface, U-free args at depth 1), `subst_in_separated_separable_depth`, and `single_U_formula_separable_noax_param` with a self-contained oracle at depth = 1.
- `no_S_nested_sep_oracle_free` handles arbitrary depth using `extract_innermost_U_type`, `count_U_total`, and `no_S_nested_sep_depth_one` for callbacks.

But `no_S_nested_sep_depth_one` uses `single_U_formula_separable_noax_param` which takes an oracle. What oracle does it provide?

At depth = 1, `single_U_formula_separable_noax_param` with `has_single_U_type _ A B` (A, B U-free). Its `snce_depth_of_U` induction:
- Leaf (depth = 1): 10.2.4, no oracle
- Depth >= 2: calls oracle on `.snce C'' F''` with `no_S_nested_in_U` and `JD <= 1`

But I showed that at depth = 1 of the OUTER theorem, the callback to 10.2.5 has `snce_depth_of_U = 1` (leaf). So the oracle is NEVER called.

We can provide a dummy oracle: `fun chi _ _ => no_S_nested_sep_depth_one chi ...`. But this requires `U_nesting_depth chi <= 1` for the call to `no_S_nested_sep_depth_one`. And the oracle formula chi has `no_S_nested_in_U` and `JD <= 1`. We need to show `U_nesting_depth chi <= 1`.

Actually, a formula with `no_S_nested_in_U` and `JD <= 1` does NOT necessarily have `U_nesting_depth <= 1`. Consider `.untl (.untl a b) c` -- this has `no_S_nested_in_U` (args are S-free), `JD = 0`, and `U_nesting_depth = 2`. Wait, `JD = 0` is wrong here. Let me check: `junction_depth (.untl (.untl a b) c) = max (junction_depth_U (.untl a b)) (junction_depth_U c) = max (max (junction_depth_U a) (junction_depth_U b)) (junction_depth_U c) = 0`. So JD = 0 with U_nesting_depth = 2. This formula does have `no_S_nested_in_U` and `JD <= 1` but `U_nesting_depth = 2`.

So the oracle formula might have `U_nesting_depth > 1`, which means `no_S_nested_sep_depth_one` can't handle it.

**Hmm.** So the oracle needs to handle arbitrary `U_nesting_depth`. We're back to needing the full `no_S_nested_sep_oracle_free`.

**But**: at depth = 1 of the OUTER theorem, the callback to 10.2.5 has `snce_depth_of_U = 1`. At `snce_depth_of_U = 1`, 10.2.5 is at the leaf case. No oracle call. So the oracle is DEAD CODE.

In Lean, we can provide ANY function as the oracle if it's never called. We just need it to TYPE-CHECK. So:

```lean
theorem no_S_nested_sep_depth_one (phi : Formula) (hns : no_S_nested_in_U phi)
    (hd : U_nesting_depth phi <= 1) : is_separable phi := by
  -- Use lemma_10_2_6_self_contained_param with oracle = fun chi _ _ => all_separable chi
  -- Wait, that uses the axiom!
  -- Alternative: provide oracle = fun chi hns_chi hjd_chi => sorry
  -- NO, can't use sorry.
```

OK, the problem remains. We need a VALID oracle. The oracle type is `forall chi, no_S_nested_in_U chi -> JD chi <= 1 -> is_separable chi`. This is exactly what we're trying to prove. But at depth = 1, the oracle is never called, so any valid proof term works.

We can provide the oracle from the JD = 0 base case for formulas with JD = 0. For JD = 1 formulas, we need... the theorem we're proving.

**But the oracle is never called.** In Lean, if we can prove that the function is never called, we can use `False.elim`:

```lean
-- If we could prove that 10.2.5 at depth 1 never calls the oracle:
have h_never_called : ∀ chi, ... → False := by ...
fun chi hns_chi hjd_chi => (h_never_called chi ...).elim
```

But proving "never called" requires tracking through 10.2.5's logic, which is complex.

**Alternative**: Use `no_S_nested_sep_oracle_free` as the oracle. But that creates a circular dependency (depth-1 theorem uses oracle-free theorem, which is defined after it).

**Simplest practical fix**: Make `no_S_nested_sep_oracle_free` handle BOTH depths in a single theorem using `WellFounded.fix` on a custom well-order. The well-order is `(U_nesting_depth, count_U_total)` lex, and for each call to the oracle (from 10.2.5), we provide a proof that the oracle's formula has strictly smaller `U_nesting_depth` (for depth >= 2 cases) or is never reached (for depth = 1 cases, via the leaf case argument).

In Lean, we can implement this as:

```lean
theorem no_S_nested_sep_oracle_free : ∀ (phi : Formula), no_S_nested_in_U phi → is_separable phi := by
  intro phi
  -- Use strong induction on (U_nesting_depth phi, count_U_total phi) lex
  have : ∀ (d c : Nat) (psi : Formula), U_nesting_depth psi ≤ d → count_U_total psi ≤ c →
      no_S_nested_in_U psi → is_separable psi := by
    intro d
    induction d using Nat.strongRecOn with | ind d ih_d =>
    intro c
    induction c using Nat.strongRecOn with | ind c ih_c =>
    intro psi hd hc hns
    ...
```

Within this double-strong-induction:
- At depth >= 2: abstract innermost U -> `count_U_total` decreases -> `ih_c`. Back-substitute. Callback has `U_nesting_depth <= 1` -> `ih_d` at `U_nesting_depth <= 1 < 2 <= d`.
- At depth = 1: abstract surface U -> `count_U_total` decreases -> `ih_c`. Back-substitute. Callback has `U_nesting_depth <= 1` and `snce_depth_of_U = 1`. Call `single_U_formula_separable_noax_param` with oracle = `ih_d` at depth 0 (for JD = 0 formulas, which are trivially separated). At `snce_depth_of_U = 1`, the oracle is at the leaf case, never called.

But the oracle type for `single_U_formula_separable_noax_param` is `forall chi, no_S_nested_in_U chi -> JD chi <= 1 -> is_separable chi`. For JD = 0 formulas, we can use the JD = 0 base case directly. For JD = 1 formulas, we'd need the result at JD = 1 -- but the oracle is never called for JD = 1 in the leaf case.

Since the oracle is never called for JD = 1 at the leaf case, we can provide any term. We can provide `ih_d 0 (by omega) ...` for JD = 0, and for JD = 1, we can provide `ih_d 1 (by omega) ...` -- but we're AT `d = 1`, so `ih_d 1` requires `1 < d` which fails.

**The hack**: Provide the oracle as a function that handles JD = 0 via the base case and JD = 1 via... `ih_c` at a smaller count. But the oracle formula's `count_U_total` is unrelated to the current formula's.

This is genuinely difficult. Let me step back and think about what actually works in Lean.

**PRAGMATIC SOLUTION**: Create `no_S_nested_sep_oracle_free` using `WellFounded.fix` with the relation `InvImage (Prod.Lex Nat.lt Nat.lt) (fun phi => (U_nesting_depth phi, count_U_total phi))`. This gives a single fixpoint that handles all cases. The key insight is:

For the oracle at depth = 1, the oracle formula (if it were ever called, which it isn't) would have `U_nesting_depth` that could be anything. BUT we know it's never called. To make Lean happy, we need to either:
(a) Prove it's never called and use `absurd`
(b) Use a different oracle type that restricts to `U_nesting_depth < d`

Option (b) is cleaner. Modify `single_U_formula_separable_noax_param` to take an oracle bounded by `U_nesting_depth chi < d`:

```lean
theorem single_U_formula_separable_noax_param' (phi A B : Formula) (d : Nat)
    (hA_sf hB_sf : ...) (hA_uf hB_uf : ...)
    (h_single : has_single_U_type phi A B)
    (oracle : ∀ (chi : Formula), no_S_nested_in_U chi →
        U_nesting_depth chi < d → is_separable chi) :
    is_separable phi
```

At depth = 1 of the combined theorem, we call this with `d = U_nesting_depth phi`. The oracle is `ih_d (U_nesting_depth chi) ...`. Since `U_nesting_depth chi < d` and we're in `ih_d d`, this works.

But does 10.2.5 at depth >= 2 actually produce oracle formulas with `U_nesting_depth < d`? Yes! The oracle formula from 10.2.5 at depth >= 2 is `.snce C'' F''` where C'', F'' are box-normalized separated formulas. These have `U_nesting_depth` bounded by the separated formula structure. The callback formula from `subst_in_separated_separable_depth` has `U_nesting_depth <= 1`. So the oracle formula also has bounded `U_nesting_depth`.

But what's the BOUND? We need `U_nesting_depth chi < d` where d is the depth parameter of the combined theorem. At the combined theorem's depth 1, `d = 1`. The oracle formula has `U_nesting_depth chi <= ?`. It's produced from 10.2.5 at `snce_depth_of_U >= 2`, where IH separates C, F, box-normalizes. The `U_nesting_depth` of `.snce C'' F''` depends on the separated forms, which could have any depth.

Actually, I realize the oracle formula from 10.2.5 at the leaf (depth = 1) is handled by 10.2.4 (no oracle). So if the combined theorem is at d = 1, 10.2.5 is called with a callback formula that has `snce_depth_of_U = 1` (leaf). The oracle is NEVER INVOKED. So we can provide `oracle := fun chi _ _ => no_S_nested_sep_oracle_free chi ...` -- but this would be a self-call without measure decrease.

OR: we provide `oracle := fun chi hns hd_lt => ih_d (U_nesting_depth chi) hd_lt chi (le_refl _) (count_U_total chi) (le_refl _) hns`. This type-checks because `U_nesting_depth chi < d` is exactly the bound `ih_d` needs.

At d = 1: `oracle := fun chi hns hd_lt => ih_d (U_nesting_depth chi) hd_lt chi ...`. The `hd_lt : U_nesting_depth chi < 1`, so `U_nesting_depth chi = 0`, meaning chi is U-free and trivially separated. This is fine!

At d >= 2: `oracle := fun chi hns hd_lt => ih_d (U_nesting_depth chi) hd_lt chi ...`. The `hd_lt : U_nesting_depth chi < d`, so `ih_d` handles it.

**This works.** The key modification is changing the oracle type from `JD <= 1` to `U_nesting_depth < d`.

---

## Final Recommended Resolution

### Architecture

1. **New infrastructure** (~100 LOC):
   - `count_U_total` (total recursive U count)
   - `contains_untl_deep` (deep containment predicate)
   - `abstract_untl_count_total_lt_of_contains_deep` (decrease lemma)
   - `abstract_untl_count_total_le` (non-increase lemma)
   - `extract_innermost_U_type_contains_deep` (bridge lemma)

2. **Modified `single_U_formula_separable_noax_param`** (~20 LOC change):
   - Change oracle type from `JD chi <= 1` to `U_nesting_depth chi < d` where d is a parameter
   - The leaf case (depth = 1) is unchanged (10.2.4, no oracle call)
   - The depth >= 2 case calls oracle with `U_nesting_depth chi < d`

3. **New `no_S_nested_sep_oracle_free`** (~80 LOC):
   - Combined 10.2.6+10.2.7 without oracle parameter
   - Double strong induction on `(U_nesting_depth, count_U_total)`
   - Depth >= 2: `extract_innermost_U_type` + `count_U_total` decrease + `subst_in_separated_separable_depth`
   - Depth = 1: `extract_U_type` (surface, U-free args) + `count_U_total` decrease + `subst_in_separated_separable_depth`
   - Back-substitution callback: `U_nesting_depth <= 1 < d` at depth >= 2, or `snce_depth_of_U = 1` (leaf) at depth = 1

4. **Modified `all_formulas_separable_aux`** (~5 LOC change):
   - Remove n=1 fallback to `all_separable`
   - At n=1: call `no_S_nested_sep_oracle_free` directly

### Estimated Effort

- New infrastructure: 100 LOC
- Modified 10.2.5 oracle type: 20 LOC
- New combined theorem: 80 LOC
- Modified 10.2.8 n=1: 5 LOC
- Testing and debugging: equivalent effort
- **Total: ~200 LOC, estimated 3-4 hours**

### Key Preconditions to Verify Before Implementation

1. `callback_U_nesting_depth_le_one` already proves callback formulas have `U_nesting_depth <= 1` -- **VERIFIED** (line 2444)
2. `extract_innermost_U_type` already exists with `_S_free` and `_U_free` companion lemmas -- **NEEDS VERIFICATION** (plan says created but may have been reverted)
3. `abstract_untl_U_nesting_depth_le_of_le` gives `<=` bound -- **VERIFIED** (line 1522)
4. At depth 1, callback to 10.2.5 has `snce_depth_of_U = 1` -- **NEEDS VERIFICATION** (this is the critical invariant)

---

## Appendix: Why `has_single_U_type` Preservation Fails

Our 8 elimination cases in `SeparationThm.lean` introduce `all_future` and `all_past`, which are syntactic sugar for `.untl` and `.snce` with specific args:
- `all_future phi = neg (untl top (neg phi))` -- introduces `.untl` with args `(imp (imp bot bot) (imp phi bot))` which is different from `(A, B)`
- `all_past phi = neg (snce top (neg phi))` -- introduces `.snce` similarly

These new temporal operators appear in Cases 2, 4, 6, 8 of Lemma 10.2.3. GHR94 handles them as abbreviations and maintains "U only appears as U(A,B)" at the formula level. But our AST encoding creates actual `.untl`/`.snce` nodes with different args, breaking `has_single_U_type`.

This is a fundamental encoding choice: our `Formula` type doesn't distinguish between "U as a temporal operator" and "G (all future) as a derived operator." Both are represented as `.untl` nodes. GHR94's proof implicitly treats G and U differently (G is semantically pure future and doesn't need elimination), but our encoding collapses them.

Fixing this would require either:
(a) Adding `all_future` and `all_past` as primitive constructors (major refactor)
(b) Reformulating `has_single_U_type` to allow `all_future`/`all_past` nodes (complex)
(c) Avoiding `has_single_U_type` entirely (our recommended approach)
