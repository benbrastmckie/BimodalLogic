# S1 Boundary Sorry Resolution

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Focus**: Why S1 (line 3901) has no contradiction in Case B, and how to fix it

---

## Diagnosis

S1 is at line 3901, inside `obtain_split_point_props`, in **Case B** (¬cont_holds_cross at c_inf), in the sub-case where `r2_resp = rank_embed(y')`.

### Why Case B's A_fail approach fails at the boundary

1. Case B extracts `A_fail` from `¬cont_holds_cross(c_inf)`: depth ≤ r, holds on (a_bwd(n), y') in N, fails at c_inf in M
2. Formula agreement gives: `¬A_fail at r2_resp` (fails at response too)
3. To derive contradiction: need `A_fail at r2_resp` (holds at response)
4. For carrier-point r2_resp: project to q_r2, use `hd_in_SC.2` which gives A_fail on **open** interval (d, y')
5. When r2_resp = rank_embed(y'): q_r2 = y', which is NOT in the open interval (d, y')
6. **No contradiction derivable** — A_fail may legitimately fail at y' itself

### Why GHR93 doesn't have this problem

GHR93 uses formula C' = ¬C ∨ K⁻(¬C) directly. The argument:
- C'(c) holds in M (infimum property)
- By formula agreement at rank r+2, C'(response) holds in N
- C'(response) implies response ≤ d-bar

This works at ANY point including the boundary y'. The Lean code can't do this because C is a predicate (`cont_holds`), not a formula.

---

## Resolution: K⁻ Argument IS Available in Case B When c_inf = y

### Key Insight

When `r2_resp = rank_embed(y')`, the code proves `c_inf = y` (line 3875). In this sub-case:

`h_cofinal_failure_below_c_inf` (line 3080) provides: for any s < c_inf, ∃ v with `s < v ≤ c_inf` AND **`v < y`**. When c_inf = y, the conjunction `v ≤ y ∧ v < y` gives `v < y = c_inf` — **strict inequality**.

This means `h_strict_failure` (currently available only in Case A) CAN be derived in Case B when c_inf = y:

```lean
-- In Case B, r2_resp = rank_embed(y') branch, after proving h_c_eq_y : c_inf = y:
have h_strict_failure_B :
    ∀ (s : ExtendedCarrier M atomMap r),
      inClosedInterval x y s → s < c_inf →
      ∃ (u : ExtendedCarrier M atomMap r),
        s < u ∧ u < c_inf ∧ u < y ∧
        mu_holds u ∧ ¬ cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
  intro s hs hs_lt_c
  obtain ⟨v, hsv, hv_le_c, hv_lt_y, hmu_v, h_not_cont_v⟩ :=
    h_cofinal_failure_below_c_inf s hs hs_lt_c
  -- v ≤ c_inf = y AND v < y. Together: v < y = c_inf.
  have hv_lt_c : v < c_inf := by rw [h_c_eq_y]; exact hv_lt_y
  exact ⟨v, hsv, hv_lt_c, hv_lt_y, hmu_v, h_not_cont_v⟩
```

Once `h_strict_failure_B` is available, the entire Case A K⁻(¬D_M) argument (lines 3660-3929, sorry-free) can be replicated.

---

## Concrete Resolution Paths

### Path 1: Duplicate K⁻ argument inside Case B boundary (150-200 lines)

At line 3901 (inside the `exfalso` block), replace `sorry` with:
1. Derive `h_strict_failure_B` (5 lines, as shown above)
2. Build `h_strict_bridge_B` (same as lines 3660-3701, ~40 lines)
3. Run `pigeonhole_definable_formula_cross_strict` (same as line 3711, ~5 lines)
4. Construct K⁻(¬D_M) (same as line 3726, ~5 lines)
5. Prove Since(⊤, D_M) FALSE at c_inf (same as lines 3738-3798, ~60 lines)
6. Transfer K_minus via formula agreement (same as lines 3810-3820, ~10 lines)
7. Show Since(⊤, D_M) TRUE at r2_resp (same as lines 3828-3929, ~100 lines — this part IS the r2_resp < rank_embed(y') branch which works fine)

Wait — step 7 is the issue. The proof at lines 3828-3929 shows Since TRUE at r2_resp by providing a witness rank_embed(d) < r2_resp and showing D_M holds at all mu in between. The `< rank_embed(y')` branch (line 3902-3910) shows q < y'. But we're in the = branch!

Actually NO. We're proving Since TRUE at r2_resp. The witness s = rank_embed(d). We need D_M at all mu u in (rank_embed(d), r2_resp). Each such u satisfies u < r2_resp = rank_embed(y'), so u < rank_embed(y'). Project: q < y'. So D_M at q via hD_interval (q in (d, y')). **This works even when r2_resp = rank_embed(y')!**

The problem in the EXISTING code: the K⁻ proof at lines 3828-3929 is INSIDE the Case B flow which tries the A_fail approach first. It's the < branch at line 3902 that closes successfully. The = branch (line 3854) tries a different approach (exfalso + A_fail) which fails.

**The fix**: In the = branch, DON'T try A_fail. Instead, run the K⁻ argument directly.

### Path 2: Restructure — handle r2_resp = rank_embed(y') before the cont_holds case split (cleaner, ~50 lines net)

Before line 3645 (`by_cases h_cont_c`), add:
```lean
-- Handle boundary case first: if r2_resp = rank_embed(y'), c_inf = y,
-- and the K⁻ argument works directly (h_cofinal_failure gives strict failures).
suffices h_r2_lt : r2_resp < rank_embed (by omega : r ≤ r + 2) y' by
  -- ... proceed to by_cases h_cont_c only when r2_resp < rank_embed(y') ...
```

This would prove `r2_resp < rank_embed(y')` as a precondition for the Case A/B split, with the = case handled separately via the K⁻ argument above.

### Path 3: Extract a shared lemma for the K⁻ argument (cleanest long-term, ~250 lines refactoring)

Factor the K⁻(¬D_M) argument (currently inside Case A, lines 3646-3929) into a standalone lemma:
```lean
private theorem claim1_direction1_K_minus
    (h_strict_failure : ...) (hwin_r2 : ...) (hform_w : ...) (h_not_le : ...) : False
```
Then call it from both Case A (with its h_strict_failure) and Case B boundary (with h_strict_failure_B).

---

## Recommended Path

**Path 1** (duplicate K⁻ inside Case B boundary). Rationale:
- Minimal code disruption to the sorry-free Case A proof
- Self-contained fix in one location
- ~150-200 lines added at line 3901
- The argument is well-understood and sorry-free (just needs to be repeated with h_strict_failure_B)

Path 3 is cleaner long-term but risks breaking the sorry-free Case A proof during refactoring.

---

## S2 Implications

S2 (line 3935) is the **gap** sub-case in Case B. The analysis above applies to the **carrier-point** sub-case. For gaps, the K⁻ approach works the same way:
- Since(⊤, D_M) TRUE at r2_resp needs D_M at all mu in (rank_embed(d), r2_resp)
- These mu-points project to (d, q) at rank r where q < y' (since r2_resp < rank_embed(y') from the = case)

Wait — at S2, r2_resp is a gap and the issue is different. The gap sub-case is at line 3935 which is OUTSIDE the `rcases eq_or_lt_of_le hr2_le_y'` split. Let me check...

Actually looking at lines 3836 and 3930: line 3836 splits on `isPoint_or_isGap r2_resp`. The carrier-point case includes the sorry at 3901 (inside the eq branch). The gap case at 3930 has its own sorry at 3935.

For the gap case (S2): r2_resp is a gap at rank r+2. The K⁻ argument at line 3828 splits on `isPoint_or_isGap d`:
- d carrier point: provides the Since witness at rank_embed(d)
- d gap: need different witness

In Case B (the gap case at line 3930-3935): we have A_fail from ¬cont_holds_cross. The K⁻ approach still works because the Since argument doesn't depend on whether r2_resp is a carrier point or gap — it only needs mu-points BETWEEN rank_embed(d) and r2_resp where D_M holds.

**S2 resolution**: Same as S1 — use the K⁻(¬D_M) argument instead of the direct A_fail approach. The K⁻ argument is agnostic to whether r2_resp is carrier or gap.

---

## Confidence

**HIGH** on diagnosis: the boundary issue is clearly identified — hd_in_SC.2 uses open intervals, A_fail at y' is not derivable.

**HIGH** on resolution: `h_cofinal_failure_below_c_inf` with c_inf = y gives strict failures (confirmed by reading the definition at lines 3080-3097). The K⁻ argument is sorry-free in Case A and replicable in Case B.

**MEDIUM** on line count estimate: ~150-200 lines is approximate. The K⁻ argument is complex (60 lines for Since FALSE, 100 lines for Since TRUE), but it's a direct copy-paste with variable renaming.

---

## Summary

| Finding | Detail |
|---------|--------|
| Root cause | Case B uses direct A_fail which requires open interval (d, y'); boundary y' excluded |
| GHR93 avoidance | GHR93 uses formula C' which works at any point including boundary |
| Fix available | K⁻(¬D_M) argument works even in Case B when c_inf = y |
| Key enabler | h_cofinal_failure_below_c_inf gives v < y; when c_inf = y this gives v < c_inf (strict) |
| Both S1 and S2 | Same resolution: fall back to K⁻ argument instead of direct A_fail |
| Effort | ~150-200 lines (Path 1: duplicate K⁻ in Case B boundary sub-case) |
