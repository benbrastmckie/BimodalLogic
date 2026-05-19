# JD = 1 Oracle Fix: Root Cause and Solution

## 1. Junction Depth Definition Analysis

### Codebase Definition (mutually recursive)
```
junction_depth (.untl a b) = max (junction_depth_U a) (junction_depth_U b)
junction_depth (.snce a b) = max (junction_depth_S a) (junction_depth_S b)
junction_depth_U (.snce a b) = 1 + max (junction_depth a) (junction_depth b)
junction_depth_S (.untl a b) = 1 + max (junction_depth a) (junction_depth b)
```

### Key Implications at JD <= 1
- `junction_depth (.snce a b) <= 1` means `junction_depth_S a <= 1` and `junction_depth_S b <= 1`
- Since `junction_depth phi <= junction_depth_S phi`, we get `junction_depth a <= 1` and `junction_depth b <= 1`
- For S-free formulas: `junction_depth_U = 0` (no `.snce` to increment) so `junction_depth (.untl c d) = 0` when c, d are S-free
- Therefore S-free implies JD = 0
- `junction_depth (.snce a b) <= 1` does NOT imply `junction_depth a = 0`; it can be 1

### GHR94 vs Codebase Junction Depth
GHR94 counts the LENGTH of the alternating chain (number of temporal operators); our code counts ALTERNATION POINTS. Mapping: GHR94 JD = our JD + 1 (approximately). GHR94's base case "JD <= 1 is already separated" = our "JD = 0 is already separated."

## 2. Callback Formula JD Bounds

`callback_jd_le_one` proves: for separated psi with U-free `.snce` branches c, d, and S-free A, B:
```
junction_depth (.snce (subst c p (.untl A B)) (subst d p (.untl A B))) <= 1
```
This bound is TIGHT at 1 when p occurs in c or d (because `junction_depth_S (.untl A B) = 1` for S-free A, B). So oracle formulas genuinely have JD = 1, not 0.

## 3. Why the Oracle Chain Loops at JD = 1

Tracing the chain on phi = `.snce (.imp (.untl p q) r) s` (JD = 1, count_U = 1):
1. `no_S_nested_in_U_separable_direct_param(phi, oracle)` -> depth <= 1 -> `lemma_10_2_6_self_contained_param`
2. Extract `(p, q)`, abstract to `.snce (.imp z r) s`, separate (U-free = already separated)
3. Substitute back: `subst_in_separated_separable_typed` at `.snce` case produces phi itself
4. `single_U_formula_separable_noax_param(phi, p, q, ...)`: `.snce` case, IH on children, box-normalize, oracle receives phi

**The oracle receives the ORIGINAL formula.** No measure decreases. A standalone theorem using the chain as its own oracle would be circular.

## 4. Root Cause: Deviation from GHR94 Structure

### What GHR94 Does (Lemma 10.2.8)
At JD >= 2 (their counting, = our JD >= 1):
1. For S(D1, D2): find covering U(Ai, Bi) subformulas
2. **Abstract maximal S(E, F) inside U-arguments** to fresh atoms zij
3. Result has no_S_nested_in_U -> apply Lemma 10.2.7
4. Back-substitute zij -> S(E, F): junction depth decreases by 1
5. Apply JD IH

### What the Current Code Does
1. Separate sub-formulas a, b of `.snce a b` by structural IH
2. Box-normalize to chi_a, chi_b
3. `.snce chi_a chi_b` has no_S_nested_in_U, JD <= 1
4. Apply `no_S_nested_in_U_separable_direct_param` with oracle
5. Oracle receives JD <= 1 formulas -> ih_jd needs JD < 1 = JD = 0 -> FAILS

### The Mismatch
GHR94 abstracts `.snce` from inside `.untl` arguments (making them S-free). The current code separates the sub-formulas first, then tries to handle the normalized result with the 10.2.7 chain. This is backwards: 10.2.7 should be applied BEFORE separation of sub-formulas, not after.

## 5. Assessment of Approaches

### Approach 1: Direct Proof for JD <= 1 + no_S_nested_in_U (BLOCKED)
The oracle chain is a no-op on JD <= 1 formulas (callback = original). No decreasing measure exists because the chain doesn't make structural progress at this level.

### Approach 2: Use no_S_nested_in_U_separable_param_jd (BLOCKED)
Same issue: the callback receives the original formula at JD = 1.

### Approach 3: Bound callback JD < 1 (IMPOSSIBLE)
`callback_jd_le_one` is tight at 1 when substitution introduces `.untl` into `.snce` branches.

### Approach 4: Modify all_formulas_separable_aux at JD = 1 (BLOCKED without structural change)
The ih_jd at n = 1 can only provide JD = 0 oracles, but oracle formulas have JD = 1.

### Approach 5: Make single_U_formula_separable_noax_param oracle-free (NECESSARY COMPONENT)
At `snce_depth_of_U = 1` in `single_U_formula_separable_noax_param`, the oracle formula has:
- `has_single_U_type A B` (preserved through separation at depth 0)
- `snce_depth_of_U C'' = 0`, `snce_depth_of_U F'' = 0` (from `separated_boxnorm_snce_depth_zero`)
- A, B S-free and U-free (from U_nesting_depth <= 1 extraction)
- `has_no_allpast_allfuture`

These are EXACTLY the preconditions of `snce_single_U_depth_one_separable` (Lemma 10.2.4, non-recursive). **Replace the oracle call with a direct call to this theorem.**

This makes 10.2.5 oracle-free -> 10.2.6 oracle-free -> 10.2.7 at depth <= 1 oracle-free.

### Approach 6: Restructure 10.2.8 to Match GHR94 (RECOMMENDED)
The fundamental fix. Follow GHR94's actual proof structure.

## 6. Recommended Fix

### Phase A: Make 10.2.5 Oracle-Free (~40 LOC)
In `single_U_formula_separable_noax_param`, `.snce C F` case:
- **Current**: unified oracle call for all depths >= 1
- **Fix**: split depth = 1 (use `snce_single_U_depth_one_separable` directly) vs depth >= 2 (use oracle)

Need to prove: `has_single_U_type C'' A B` is preserved through separation+box-normalization at depth 0. This holds because at depth 0, the structural IH preserves `.untl A B` nodes, and box-normalization doesn't touch `.untl`.

Create `single_U_formula_separable_no_oracle` that is ENTIRELY oracle-free (depth 1 uses direct lemma, depth >= 2 uses IH on depth then direct lemma for oracle formulas at depth <= 1).

### Phase B: Make 10.2.7 Oracle-Free (~20 LOC)
`no_S_nested_in_U_separable_direct_param` at depth <= 1: already oracle-free after Phase A.
At depth >= 2: GHR94 abstracts INNER U-subformulas (making outer U-args U-free), applies 10.2.6. Back-substitution produces pure-past parts with U-nesting-depth < n (NOT JD-bounded oracle formulas). The current `subst_in_separated_separable_depth` handles this when A, B are U-free.

The existing code at depth >= 2 uses `subst_in_separated_separable_jd` (JD-bounded oracle). But GHR94's approach uses `subst_in_separated_separable_depth` (U-nesting-depth-bounded callback). Since the abstracted inner U-formulas make outer args U-free, `subst_in_separated_separable_depth` applies. Callback at depth <= 1 -> Phase A handles it.

**However**: the current `extract_U_type` at depth >= 2 finds the OUTERMOST `.untl` (whose args may not be U-free). GHR94 instead makes the args U-free by abstracting inner U-subformulas. This requires a new function `abstract_inner_U_from_args` that replaces U-subformulas inside `.untl` arguments with fresh atoms.

### Phase C: Restructure 10.2.8 (.snce Case) (~60 LOC)
Replace the current `.snce a b` case in `all_formulas_separable_aux`:

**Current**: separate a, b by structural IH -> box-normalize -> `no_S_nested_in_U_separable_direct_param` with oracle

**New** (following GHR94):
1. Find covering `.untl (Ai, Bi)` in the `.snce` node
2. Abstract maximal `.snce` subformulas inside each Ai, Bi to fresh atoms
3. Result has `no_S_nested_in_U` -> apply oracle-free 10.2.7
4. Back-substitute: each resubstituted `.snce (Eij, Fij)` has JD <= n-1
5. Apply JD IH (which works because n-1 < n)

### Helper Infrastructure Needed
- `abstract_untl_jd_le`: abstracting `.untl A B` doesn't increase JD (~30 LOC, parallel to `abstract_snce_jd_le`)
- `abstract_inner_U_from_untl_args`: abstract U-subformulas inside `.untl` arguments (~50 LOC)
- `has_single_U_type_preserved_by_sep_depth0`: preservation through separation at snce_depth_of_U = 0 (~20 LOC)
- Junction depth decrease after S-abstraction from U-args (~30 LOC)

## 7. Estimated LOC

| Component | Lines |
|-----------|-------|
| Phase A: oracle-free 10.2.5 | 40 |
| Phase B: oracle-free 10.2.7 + inner-U abstraction | 80 |
| Phase C: restructured 10.2.8 | 60 |
| Helper lemmas | 130 |
| **Total** | **~310** |

The approach faithfully follows GHR94's proof structure, which was designed to avoid exactly the oracle circularity we encountered.
