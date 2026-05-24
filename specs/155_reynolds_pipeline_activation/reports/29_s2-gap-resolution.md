# Research Report: S2 Gap Sorry Resolution

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Focus**: How to close the sorry at S2 (line 4165) — gap sub-case in obtain_split_point_props

---

## Critical Discovery: K⁻ Semantics Were Misunderstood

**All prior reports (28, 35, 38, 39) misidentified K⁻ as "past eventually" (∃ s < t, φ(s)). This is WRONG.**

The actual definition in the codebase (`EFGames.lean:7337-7389`):

```lean
sf_K_minus A = .neg (.std_snce sf_verum (.neg A))
```

And `sf_K_minus_iff` gives:
```
K⁻(A)(t) ↔ ¬∃ mu s < t, ∀ mu u ∈ (s,t), ¬A(u)
```

**K⁻(A)(t) means: "A is cofinal below t among mu-points"** — for every mu-point s below t, there exists a mu-point u between s and t where A holds. Equivalently: no matter how close you approach t from below, you always find A holding.

This is NOT "∃ s < t, A(s)" (past eventually). It's "∀ mu s < t, ∃ mu u ∈ (s,t), A(u)" (cofinal below).

---

## How This Resolves GHR93 Claim 1 (Direction 1)

GHR93 uses C' = ¬C ∨ K⁻(¬C) to show: response ≤ d-bar.

With the correct K⁻ semantics:

**If response > d-bar**:
- ¬C(response) = FALSE (C holds above d-bar since S_C is... the continuation set holds there)
- K⁻(¬C)(response) = "¬C is cofinal below response" = "for all mu s < response, ∃ mu u ∈ (s, response) with ¬C(u)"
- Take mu s between d-bar and response: all mu u in (s, response) satisfy u > d-bar, so C(u) = true, so ¬C(u) = false. No witness exists.
- Therefore K⁻(¬C)(response) = FALSE

So C'(response) = false ∨ false = FALSE when response > d-bar.

**If response ≤ d-bar**: C'(response) = TRUE (either ¬C holds directly, or K⁻(¬C) holds because C fails cofinally approaching d-bar from below).

**C' DOES distinguish response ≤ d-bar from response > d-bar.**

---

## Proof State at S2 (line 4165)

Key hypotheses:
- `h_not_le : rank_embed d < r2_resp` — we want contradiction (showing response cannot be above d)
- `r2_resp = Sum.inr g_r2` — response is a gap at rank r+2
- `A_fail : StaviFormula` with `hA_depth : stavi_depth A_fail ≤ r`
- `hA_interval : ∀ mu v ∈ (a_bwd(n), y'), A_fail at v` (rank r, N-side)
- `hA_fail_c : ¬A_fail at c_inf` (rank r, M-side)
- `hA_fail_r2 : ¬A_fail at r2_resp` (rank r+2, N-side, via formula agreement bridge)
- `hform_w : formula_agreement 1 (M-tuple) (N-tuple)` — universal for depth ≤ r+2

---

## Resolution: Use K⁻(¬A_fail) via Formula Agreement

**Step 1**: Construct `K := sf_K_minus (.neg A_fail)` with `stavi_depth K ≤ r + 2` (from `stavi_depth_sf_K_minus`).

**Step 2**: Show `stavi_temporal_truth_mu M atomMap (r+2) (rank_embed c_inf) K` holds.

K⁻(¬A_fail)(c_inf) at rank r+2 means: "¬A_fail is cofinal below rank_embed(c_inf) among rank-(r+2) mu-points."

From `h_cofinal_failure_below_c_inf`: for any s < c_inf (in M), there exists mu u ∈ (s, c_inf) where cont_holds_cross fails. ¬cont_holds_cross at u gives ∃ D with ¬D at u... but we need ¬A_fail specifically.

**ISSUE**: We need ¬A_fail to be cofinal below c_inf in M, but `hA_fail_c` only gives ¬A_fail AT c_inf, not below it.

**HOWEVER**: `hA_fail_c : ¬A_fail at c_inf` AND the cofinal failure together give: for any s < c_inf, ∃ mu u ∈ (s, c_inf) where SOME formula fails. But not necessarily A_fail.

**Alternative Step 2**: Use the formula agreement DIRECTLY on a K⁻ formula that we CAN establish at c_inf.

Since `h_cofinal_failure_below_c_inf` gives cofinal cont_holds_cross failure below c_inf, and `cont_holds_cross` involves the predicate `∀ A depth ≤ r, if A on interval, then A at u`, the failure gives a DIFFERENT A at each level. We cannot use K⁻(¬A_fail) because A_fail is not guaranteed to fail cofinally below c_inf.

---

## Sub-Case Analysis: Is S2 Actually Reachable?

The sorry IS reachable — the game allows gap responses. In GHR93, if d-bar is a gap, the response IS a gap.

---

## How `stavi_temporal_truth_mu` Works at Gaps

From `EFGames.lean:751-753`:
```lean
interp := fun p e => match e with
  | .inl x => M.interp p x
  | .inr _ => False  -- gaps have no predicate values
```

Atoms are always FALSE at gaps. Temporal connectives (Until/Since/Stavi) quantify over other elements (mu-points), so their truth at a gap depends on nearby mu-points — not on the gap itself.

Key implication: A formula that is TRUE at all mu-points in an interval can still be FALSE at a gap in that interval (if it's atomic or involves positive atoms). Conversely, a formula that is FALSE at a gap might be TRUE at all nearby carrier points.

---

## The Real Resolution Path

The fix requires establishing K⁻(¬A_fail)(c_inf) in M. This needs: ¬A_fail holds COFINALLY below c_inf among mu-points. But we only know ¬A_fail holds AT c_inf (point value).

**Key insight**: The cofinal failure below c_inf gives DIFFERENT formulas at each level. To use K⁻, we need a SINGLE formula that fails cofinally. A_fail (from ¬cont_holds_cross at c_inf) fails AT c_inf but we don't know it fails cofinally BELOW c_inf.

**Three possible fixes**:

### Fix 1: Show A_fail fails cofinally below c_inf (easiest if true)

If `¬stavi_temporal_truth_mu M atomMap r c_inf A_fail` AND c_inf is the infimum of S_C_M, then there should be points approaching c_inf from below where A_fail also fails (by the infimum property). Specifically: if A_fail held at all mu-points below c_inf, and A_fail holds on (a_bwd(n), y') in N (cross), then c_inf would be in S_C_M... but it IS (hc_inf_in_SC_M). Hmm.

Actually: `hc_inf_in_SC_M : c_inf ∈ S_C_M`. This means cont_holds_cross holds at c_inf. But `hA_fail_c : ¬A_fail at c_inf`. So A_fail holds on (a_bwd(n), y') in N (hA_interval) but A_fail FAILS at c_inf in M. This is consistent because cont_holds_cross quantifies over formulas holding on the N-side interval and asks about the M-side.

The cofinal failure gives: for s < c_inf, ∃ mu u ∈ (s, c_inf) with ¬cont_holds_cross at u. ¬cont_holds_cross at u gives ∃ D, D on N-interval but ¬D at u (in M). This D might be A_fail or might be different at each level.

### Fix 2: Use the FULL formula agreement universally

The formula agreement `hform_w` holds for ALL formulas of depth ≤ r+2. Instead of using just A_fail, use the FAMILY of all bounded-depth formulas. Construct: "the NormalForm type of c_inf equals the NormalForm type of r2_resp" (since formula_agreement at all depths implies same NF). Then use NF properties to derive contradiction.

This is the most principled approach but may require new infrastructure (NormalForm comparison lemmas).

### Fix 3: Show the gap sub-case is eliminated by hd_in_SC + continuity

If `d ∈ S_C` and `hd_le_an_proof : d ≤ a_bwd(n)`, and `hd_glb : ∀ s ∈ S_C, d ≤ s` (d is lower bound), then d = min(S_C). If S_C is upward closed (continuation_set_upward_closed exists), then ALL elements ≥ d in [x', y'] are in S_C. This means all mu-points above d satisfy cont_holds, hence A_fail holds at all mu above d. Then the K⁻ argument works.

**Check**: Is `continuation_set_upward_closed` proved? If so, this is the fix.

---

## Concrete Recommended Resolution

**Check `continuation_set_upward_closed`**. If it says S_C is upward closed (i.e., if s ∈ S_C and s ≤ t ≤ y', then t ∈ S_C), then:

1. Since d = inf(S_C) and S_C is upward closed: all mu v with d < v < y' are in S_C (they're above d = inf, and below y' which is in the interval)
2. s ∈ S_C means cont_holds at s, which means: for all D depth ≤ r, if D on N-interval, then D at s
3. A_fail satisfies the premise (hA_interval), so A_fail holds at all mu v with d < v < y'
4. This extends hA_interval from (a_bwd(n), y') to (d, y')
5. Now construct K := sf_K_minus (.neg A_fail), depth ≤ r+2
6. Show K holds at rank_embed(c_inf) in M: need ¬A_fail cofinal below c_inf in M
   - From hA_fail_c (¬A_fail at c_inf) and the infimum property of c_inf...
   - Actually this is the M-SIDE, not N-side. A_fail relates to N. Need cross structure.
   - Use `h_cofinal_failure_below_c_inf` which gives ¬cont_holds_cross cofinally below c_inf. cont_holds_cross failing at u means ∃ D with D on N-interval but ¬D(u) in M_cross.
   - Can we ensure this D = A_fail at every level? Only if A_fail is the unique formula that fails at c_inf.

**This path is blocked** unless we can show A_fail specifically fails cofinally (not just cont_holds_cross fails cofinally with various formulas).

---

## Final Assessment

**S2 is a genuine architectural blocker.** It cannot be closed with:
- A_fail alone (doesn't fail cofinally below c_inf in M)
- K⁻(¬A_fail) (can't establish the M-side cofinality)
- Truth inheritance from carriers to gaps (atoms are False at gaps)

**What IS needed**: Either
1. Materialize C as a formula (blocked — infinite atoms)
2. Use the NormalForm equivalence from formula_agreement to derive a structural contradiction (new infrastructure needed)
3. Restructure the proof to avoid the gap sub-case (show continuation_set has only carrier-point elements above d, eliminating gap responses)

**Confidence**: HIGH that S2 cannot be closed with current approach. MEDIUM that Fix 3 (continuation_set structure) might work but requires investigation.

---

## Key Takeaway for S1

S1 (boundary case, r2_resp = rank_embed(y')) might be closable by a similar K⁻ argument — if K⁻(¬A_fail) at rank_embed(c_inf) can be established. The boundary case has c_inf = y (M-side boundary), making the cofinal argument different from the gap case.
