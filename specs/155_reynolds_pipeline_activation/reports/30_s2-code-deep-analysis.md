# S2 Code Deep Analysis: Gap Sorry Resolution Path

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Focus**: Exact proof state at S2 and whether the S1 K⁻ approach transfers

---

## 1. Proof State at S2 (line 4293)

S2 is inside `obtain_split_point_props`, in the branch:
```
rcases isPoint_or_isGap r2_resp with ⟨q_r2, hq_r2⟩ | ⟨g_r2, _hg_r2⟩
· -- carrier-point case (CLOSED — S1 sub-case via K⁻, sibling via hd_in_SC)
· -- GAP case (S2 — SORRY at line 4293)
```

Goal: `⊢ False`

Key hypotheses available (same as S1):
- `h_cofinal_failure_below_c_inf`: ∀ s ∈ [x,y] with s < c_inf, ∃ mu u with s < u ∧ u ≤ c_inf ∧ u < y ∧ ¬cont_holds_cross at u
- `hx_lt_c : x < c_inf` (so there exist points below c_inf)
- `hc_inf_in_SC_M : c_inf ∈ S_C_M` (cont_holds_cross holds at all mu-points ABOVE c_inf)
- `h_not_le : rank_embed d < r2_resp` (response is above d)
- `A_fail : StaviFormula` with depth ≤ r, holds on interval, fails at c_inf in M
- `hA_fail_r2 : ¬stavi_temporal_truth_mu N atomMap (r+2) r2_resp A_fail` (A_fail FALSE at gap r2_resp)
- `hform_w : formula_agreement 1 (M-tuple) (N-tuple)` (universal for depth ≤ r+2)

Unique to S2:
- `g_r2 : RDefinableGap N atomMap (r+2)` and `_hg_r2 : r2_resp = Sum.inr g_r2`

---

## 2. Why the Carrier-Point Approach Fails for Gaps

The carrier-point sibling (lines 4268-4287) works because:
1. r2_resp = extendPoint q_r2 → project to rank r → d < q_r2 < y'
2. `hd_in_SC.2` gives A_fail HOLDS at q_r2 (all mu-points above d satisfy the continuation condition)
3. Bridge to rank r+2: A_fail holds at r2_resp = extendPoint q_r2
4. Contradiction with hA_fail_r2

For gaps: `hd_in_SC.2` requires a mu-point. Gaps are not mu-points. A_fail truth at a gap is NOT determined by truth at nearby mu-points (atoms are False at gaps, temporal connectives evaluate independently).

---

## 3. Whether `h_cofinal_failure_below_c_inf` Gives Strict Failures

`h_cofinal_failure_below_c_inf` type:
```
∀ s ∈ [x,y], s < c_inf → ∃ u, s < u ∧ u ≤ c_inf ∧ u < y ∧ mu_holds u ∧ ¬cont_holds_cross u
```

The bound is **`u ≤ c_inf` (NON-STRICT)**. In S1, `c_inf = y` converts `u < y` to `u < c_inf` (strict). In S2, no such shortcut exists.

**Can u = c_inf?** Only if `mu_holds c_inf` (i.e., c_inf is a carrier point). If c_inf is a GAP, then mu_holds c_inf is False, so u ≠ c_inf and we get STRICT bound `u < c_inf`.

---

## 4. The Key Insight: Case-Split on IsPoint_or_isGap c_inf

**Case A: c_inf is a GAP** (c_inf = Sum.inr g_c)
- `mu_holds c_inf` is False
- `h_cofinal_failure_below_c_inf` always gives `u < c_inf` (strict, since u is a mu-point and c_inf isn't)
- This enables the SAME K⁻(¬D_M) pigeonhole argument as S1
- D_M fails cofinally below c_inf STRICTLY → K⁻(¬D_M) holds at c_inf → transfer to r2_resp → contradiction

**Case B: c_inf is a CARRIER POINT** (c_inf = extendPoint p_c)
- `mu_holds c_inf` is True
- `h_cofinal_failure_below_c_inf` may give u = c_inf (non-strict)
- K⁻ argument doesn't directly work (can't guarantee strict cofinal failures)
- BUT: we have `hA_fail_c : ¬stavi_temporal_truth_mu M atomMap r c_inf A_fail`
- AND: c_inf is a carrier point, so we can use the formula agreement differently

For Case B with c_inf as carrier point:
- rank_embed(c_inf) at rank r+2 IS a carrier point (rank_embed preserves carrier/gap status)
- `hform_1_A` gives: A_fail at rank_embed(c_inf) in M ↔ A_fail at r2_resp in N
- `hM_bridge_A` gives: A_fail at rank_embed(c_inf) ↔ A_fail at c_inf (rank r)
- So: ¬A_fail(c_inf) at rank r → ¬A_fail(rank_embed(c_inf)) at rank r+2 → ¬A_fail(r2_resp) at rank r+2
- This gives `hA_fail_r2` which we ALREADY HAVE

So the formula agreement ALREADY transferred the failure. The contradiction we seek is: show A_fail HOLDS at r2_resp. But r2_resp is a gap. A_fail truth at a gap depends on the formula's structure.

WAIT — re-reading: we already HAVE `hA_fail_r2 : ¬ A_fail at r2_resp`. We're trying to show `False`. The approach in the carrier-point case was: show A_fail HOLDS at r2_resp, contradicting hA_fail_r2. For a gap, we can't directly show A_fail holds.

**Alternative for Case B**: Use cont_holds_cross failure at c_inf differently. Since c_inf is a carrier point:
- `¬cont_holds_cross at c_inf` means ∃ A with A on interval but ¬A at c_inf
- This A = A_fail (already extracted)
- Since c_inf is a carrier point and c_inf ∈ S_C_M (the tail condition), all mu above c_inf satisfy cont_holds_cross
- The failure is AT c_inf specifically
- For K⁻(¬A_fail): need ¬A_fail cofinal below c_inf. But we only know ¬A_fail AT c_inf.

**Actually**: for the K⁻ argument with ¬A_fail: K⁻(¬A_fail)(c_inf) means "¬A_fail is cofinal below c_inf among mu-points". This requires: for any mu s < c_inf, ∃ mu u ∈ (s, c_inf) with ¬A_fail(u).

In Case B (c_inf is carrier point): the open interval (s, c_inf) doesn't include c_inf. We need ¬A_fail at points BELOW c_inf, not at c_inf itself. But we only know ¬A_fail AT c_inf.

**HOWEVER**: there's a subtlety. `h_cofinal_failure_below_c_inf` gives cont_holds_cross failures below c_inf. Each failure gives SOME formula B that fails. One of these B's might be A_fail — but the pigeonhole ensures that across infinitely many failures, at least ONE formula repeats infinitely. That formula is the D_M from pigeonhole.

So in Case B: D_M (from pigeonhole) fails cofinally below c_inf, but we need to check: do the pigeonhole failures include points STRICTLY below c_inf? If u can equal c_inf (Case B), the pigeonhole chain might converge to c_inf without giving infinitely many distinct points below.

**But the pigeonhole (`pigeonhole_definable_formula_cross_strict`) requires STRICT bound** — it takes `h_strict_bridge` which demands `u < c_inf` (strict). So in Case B, we can't even CALL the strict pigeonhole.

---

## 5. S2 Resolution: Case Split on c_inf

```lean
rcases isPoint_or_isGap c_inf with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
```

**Case A (c_inf is gap)**: 
- All failures from h_cofinal_failure_below_c_inf are STRICT (u < c_inf)
- Apply SAME argument as S1's K⁻(¬D_M) pigeonhole (~identical code, ~280 lines)
- This closes S2 for the gap c_inf sub-case

**Case B (c_inf is carrier point)**: 
- Cannot use K⁻ argument (failures may be AT c_inf, not below)
- Need different approach. Options:
  1. Show this sub-case is impossible (c_inf carrier + r2_resp gap → contradiction from game structure?)
  2. Use formula agreement at index 1 differently
  3. Use the game_tuple order agreement to derive a structural contradiction

For option 1: If c_inf is a carrier point, rank_embed(c_inf) at rank r+2 is also a carrier point. The order agreement (hord_13) relates rank_embed(c_inf) to rank_embed(y). If rank_embed(c_inf) < rank_embed(y) (i.e., c_inf < y), then r2_resp < rank_embed(y'). Since r2_resp is a gap and it's below rank_embed(y'), and it's above rank_embed(d)... this doesn't immediately give a contradiction.

For option 3: The game response a'_r2(0) = r2_resp is a gap. But the game is played at rank r+2, where gaps ARE valid elements. This is consistent.

**The genuine Case B blocker**: When c_inf is a carrier point, ¬cont_holds_cross at c_inf means A_fail fails AT c_inf but we can't prove it fails BELOW c_inf. The K⁻ argument doesn't apply. This is the TRUE S2 architectural blocker.

---

## 6. Concrete Tactic Sequence for Case A (c_inf is gap)

```lean
-- At S2 sorry site:
rcases isPoint_or_isGap c_inf with ⟨p_c, hp_c⟩ | ⟨g_c, hg_c⟩
· -- Case B: c_inf is a carrier point. TODO: separate argument needed.
  sorry
· -- Case A: c_inf is a gap. K⁻ argument applies (same as S1).
  -- h_cofinal_failure_below_c_inf gives u with s < u ≤ c_inf ∧ mu_holds u
  -- Since c_inf is a gap: mu_holds c_inf is False, so u ≠ c_inf, hence u < c_inf (strict!)
  have h_strict_failure_s2 : ∀ (s : ExtendedCarrier M atomMap r),
      inClosedInterval x y s → s < c_inf →
      ∃ (u : ExtendedCarrier M atomMap r),
        s < u ∧ u < c_inf ∧ u < y ∧ mu_holds u ∧ ¬cont_holds_cross (a_bwd ⟨n, by omega⟩) y' u := by
    intro s hs hs_lt_c
    obtain ⟨v, hsv, hv_le_c, hvy, hmu_v, h_not_cont_v⟩ :=
      h_cofinal_failure_below_c_inf s hs hs_lt_c
    have hv_lt_c : v < c_inf := lt_of_le_of_ne hv_le_c (fun h => 
      absurd (h ▸ hmu_v) (not_mu_holds_gap g_c ∘ (hg_c ▸ ·)))
    exact ⟨v, hsv, hv_lt_c, hvy, hmu_v, h_not_cont_v⟩
  -- Now apply same K⁻(¬D_M) pigeonhole argument as S1...
  -- [~250 lines identical to S1 proof]
```

---

## 7. Verdict

**S2 splits into two sub-cases:**

| Sub-case | c_inf type | K⁻ applies? | Resolution |
|----------|-----------|-------------|------------|
| A | gap | YES | Same as S1 (~280 lines, duplicated or factored) |
| B | carrier point | NO | Genuine blocker — different argument needed |

**Case A (c_inf gap)** is closable NOW with the same code as S1.

**Case B (c_inf carrier point)** requires further research:
- The K⁻ approach fails because failures may be AT c_inf rather than below
- A_fail fails AT c_inf but that doesn't give cofinal failures in the open interval below
- This is a STRICTLY SMALLER blocker than the original S2 (one sub-case of one sub-case)
- GHR93 doesn't have this problem because their C covers the full interval type

**Estimated effort**:
- Case A: ~280 lines (copy/adapt from S1) or ~50 lines (if factored into shared lemma)
- Case B: Unknown — requires new research into whether this sub-case can be eliminated or needs a different proof technique

**Recommendation**: Factor the S1 K⁻ argument into a shared lemma parameterized by a "strict cofinal failure" hypothesis. Apply it to close Case A of S2. Then investigate Case B separately — it's a much smaller and more precise blocker than "S2" was before.
