# Teammate C (Critic) Findings: Task 157

**Date**: 2026-05-19
**Focus**: Gap analysis, circularity detection, and blind spot identification for Phase 3-4 approach

---

## Key Findings

### CRITICAL: `single_U_formula_separable` Uses `snce_separable` Axiom — Plan is Circular

**Severity**: BLOCKER — the entire depth-1 approach in the plan is invalid as written.

The plan (v16, Task 3.5) proposes `lemma_10_2_6_self_contained` using `single_U_formula_separable` as the callback for `no_S_nested_in_U_separable_param`. But tracing the code reveals a fatal circularity:

1. `lemma_10_2_6_self_contained` calls `no_S_nested_in_U_separable_param` with callback
2. `no_S_nested_in_U_separable_param` (line 1634) passes the callback to `subst_in_separated_separable` (line 1674)
3. `subst_in_separated_separable` at `.snce c d` case (line 1170) invokes the callback on `.snce (subst c p (.untl A B)) (subst d p (.untl A B))`
4. The callback is meant to use `single_U_formula_separable`
5. **But `single_U_formula_separable` at its own `.snce` case (line 187) calls `snce_separable` — the AXIOM**

So the "self-contained" depth-1 case is NOT self-contained. It depends on `snce_separable`, which is exactly the axiom we're trying to eliminate.

**The handoff (Section 4) correctly identifies this issue** but the plan's Task 3.5 does not resolve it. The plan says:
> "Uses no_S_nested_in_U_separable_param with single_U_formula_separable as the callback"

This is wrong — `single_U_formula_separable` cannot serve as an axiom-free callback because it internally uses `snce_separable`.

### CRITICAL: Need Axiom-Free `single_U_formula_separable` (or Replacement)

To make the depth-1 case truly self-contained, one of these approaches is needed:

**Option A**: Rewrite `single_U_formula_separable` to use `snce_depth_of_U` induction instead of structural induction.
- GHR94 10.2.5 proof: induction on k = max S-nesting above U(A,B)
- k=0: formula is syntactically separated (already proved as `snce_depth_zero_single_U_separated`, line 1390)
- k>0: apply Lemma 10.2.4 (Cases 1-8) at the most deeply nested S containing U(A,B), reducing k by 1
- This avoids `snce_separable` entirely

**Option B**: Don't use `single_U_formula_separable` as callback. Instead, build a new callback that handles the `.snce` case directly via Cases 1-8.

**Option C**: Use the existing `no_S_nested_in_U_separable_param_jd` recursively — the callback formula has JD ≤ 1, and at JD=0 it's directly separated. But at JD=1, we still need a non-circular callback. This pushes the problem down but doesn't solve it.

### MODERATE: Callback `has_single_U_type` Claim is VALID

The handoff's claim that callback formulas have single U-type when `U_nesting_depth phi <= 1` is correct. Here's the trace:

1. `no_S_nested_in_U_separable_param` extracts U-type `(AB.1, AB.2)` via `extract_U_type` (line 1648)
2. `extract_U_type_S_free` proves `is_S_free AB.1 ∧ is_S_free AB.2` (line 1649)
3. When `U_nesting_depth phi <= 1`, `U_nesting_depth_le_one_untl_args_U_free` proves the extracted A, B are U-free (line 1457)
4. After abstracting and separating, the callback at `.snce c d` receives `subst c p (.untl A B)` where c is U-free
5. Since c is U-free, all U in `subst c p (.untl A B)` comes from the substitution `p → .untl A B`
6. Since A, B are U-free, `has_single_U_type (subst c p (.untl A B)) A B` holds
7. `has_single_U_type` at `.snce` (line 46) recurses into children — so `.snce (subst c p ...) (subst d p ...)` has single U-type

**Verified correct.**

### MODERATE: Callback `U_nesting_depth` Bound is VALID

The callback formula `.snce (subst c p (.untl A B)) (subst d p (.untl A B))` has `U_nesting_depth <= 1` when the original formula has `U_nesting_depth <= 1`:

1. c, d are U-free (from separated ψ), so `U_nesting_depth c = U_nesting_depth d = 0`
2. After substituting p → .untl A B, each introduced `.untl A B` has depth 1 (since A, B are U-free)
3. `U_nesting_depth (.snce ...) = max(U_nesting_depth(subst c ...), U_nesting_depth(subst d ...)) ≤ 1`

**Verified correct.** But this doesn't help because the callback function (`single_U_formula_separable`) is the problem, not the callback formula's properties.

### LOW: `abstract_inner_U` Approach for Depth ≥ 2 — Conceptually Sound but Complex

The plan's Phase 3 Tasks 3.6-3.11 for `abstract_inner_U` are conceptually aligned with GHR94 10.2.7. The key question is whether `back_subst_U_nesting_depth_lt` (Task 3.11) is provable:

- Inner U's `U(X_ij, Y_ij)` were at depth ≥ 2 in the original (inside U-args of outer U's)
- After abstraction + separation + back-substitution, they land in "pure-past" positions of the separated form
- In the separated form, these positions are under `.snce` nodes but NOT under `.untl` nodes
- So their `U_nesting_depth` is at most the depth of the inner U's themselves, which was < original depth

This argument is sound but the formal proof may be subtle due to the indirect nature of "landing in pure-past positions."

### LOW: Overlooked Simpler Path — The Self-Recursive Approach

Question Q4 from the handoff asks whether `no_S_nested_in_U_separable_param` can be made self-referential. This is worth investigating more:

The existing structure already has TWO induction levels:
1. **Outer**: `no_S_nested_in_U_separable_param` — induction on `count_U_subformulas`
2. **Inner**: callback handles `.snce` cases

If we could make the callback call `no_S_nested_in_U_separable_param` recursively (instead of an external callback), we'd need a well-founded measure that decreases. The compound measure `(snce_depth_of_U, count_U_subformulas)` lexicographically might work:
- The callback formula has `snce_depth_of_U = 0` or strictly less than the original
- When `snce_depth_of_U = 0`, the formula is directly separable (already proved)

This could potentially eliminate the need for both `single_U_formula_separable` AND `abstract_inner_U`, replacing them with a single self-contained induction. But this would require significant restructuring.

---

## Recommended Approach

### Immediate Fix: Axiom-Free `single_U_formula_separable`

The **minimum viable fix** is to rewrite `single_U_formula_separable` following GHR94 10.2.5 exactly:

```
theorem single_U_formula_separable_noax (φ A B : Formula)
    (hA_sf : is_S_free A = true) (hB_sf : is_S_free B = true)
    (hA_uf : is_U_free A = true) (hB_uf : is_U_free B = true)
    (h_single : has_single_U_type φ A B) :
    is_separable φ
```

**Proof strategy**: Induction on `snce_depth_of_U φ`:
- **k = 0**: `snce_depth_zero_single_U_separated` (line 1390) proves `is_syntactically_separated φ = true`, hence separable. Already implemented — no axiom needed.
- **k > 0**: Find the most deeply nested `.snce C F` containing U(A,B). Apply Cases 1-8 (GHR94 Lemma 10.2.4, using existing `elim_case_1` through `elim_case_4` from Eliminations.lean and `case5_separable_Z_gen` through `case8_separable_Z` from DedekindZ.lean) to eliminate U from under this S. This reduces `snce_depth_of_U` by at least 1. Apply IH.

**Key requirement**: This new version requires `is_U_free A` and `is_U_free B` as additional hypotheses (which the plan's Task 3.4 `callback_has_single_U_type` already provides for depth ≤ 1). The current `single_U_formula_separable` only requires `is_S_free A, B`, which is weaker.

**Complexity estimate**: ~100-200 LOC. The most complex part is implementing "find the most deeply nested S containing U and apply Cases 1-8" as a formula transformation (GHR94 10.2.4 mechanization).

### Plan Correction Required

Tasks 3.4-3.5 in the plan need revision:
1. Task 3.4 (`callback_has_single_U_type`) is valid and should remain
2. Task 3.5 (`lemma_10_2_6_self_contained`) must be revised to use an **axiom-free** version of `single_U_formula_separable`, not the existing one
3. **New task needed**: Create `single_U_formula_separable_noax` with `snce_depth_of_U` induction + 10.2.4 at each step

---

## Evidence/Examples

### Code Trace: The Circular Dependency

```
lemma_10_2_6_self_contained (proposed)
  → no_S_nested_in_U_separable_param (Hierarchy.lean:1634)
    → subst_in_separated_separable (Hierarchy.lean:1144)
      → [at .snce case, line 1170] callback(chi, hns)
        → single_U_formula_separable (Hierarchy.lean:170)
          → [at .snce case, line 187] snce_separable ψ₁ ψ₂ ...
            → SeparationThm.lean:101: axiom snce_separable  ← AXIOM!
```

### Existing Axiom-Free Infrastructure for 10.2.5

- `snce_depth_zero_single_U_separated` (line 1390): k=0 base case — **axiom-free**
- `elim_case_1` through `elim_case_4` (Eliminations.lean): Cases 1-4 — **axiom-free**
- `case5_separable_Z_gen` through `case8_separable_Z` (DedekindZ.lean): Cases 5-8 for Z — **axiom-free**
- `replace_untl`, `replace_untl_U_free` (Hierarchy.lean:1514-1538): U-type replacement — **axiom-free**
- `single_U_eval_when_U_true/false` (Hierarchy.lean:1555-1610): Semantic evaluation — **axiom-free**

All the raw ingredients for Lemma 10.2.4 exist axiom-free. The missing piece is composing them into a proof of "S(C,F) with single-U-type at top level → separable" (the CNF/DNF decomposition + Cases 1-8 application).

---

## Confidence Level

**High** — The circularity finding is based on direct code tracing of `single_U_formula_separable` (line 187) calling `snce_separable` (axiom at SeparationThm.lean:101). This is a provable fact about the current code, not a speculation. The fix path (GHR94-faithful 10.2.5 via `snce_depth_of_U` induction) is also well-supported by existing infrastructure.

The one uncertainty is whether the 10.2.4 mechanization (CNF/DNF + Cases 1-8) can be implemented cleanly given the existing Cases 1-8 infrastructure, which was designed for specific formula shapes (atom arguments). GHR94 10.2.4 requires decomposing `S(C, F)` into normal forms with respect to `U(A,B)`, which is a non-trivial formula transformation. The existing `replace_untl` infrastructure handles part of this (the event-guard decomposition) but the full CNF/DNF step may need additional work.
