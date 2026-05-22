# Phase 1 Infimum Redefinition: Detailed Implementation Specification

## Executive Summary

d_consistency_left/right is UNPROVABLE with d = a_bwd(n) (report 29). The fix: redefine d as the infimum of continuation_set in obtain_split_point_props. This changes d's identity throughout the pipeline, requiring:
- obtain_split_point_props: redefine d (~80 lines)
- SplitPointProps: already changed (hd_le_an)  
- d_consistency: add infimum hypothesis, prove via Claim 1 (~100 lines)
- Case II: rewrite to not use hd_eq_an (~300-500 lines)
- Callers: minimal change (pass infimum hypothesis)

## Change 1: Redefine d in obtain_split_point_props (line 1374)

### Current
```lean
let d := a_bwd ⟨n, by omega⟩
have hd_interval : inClosedInterval x' y' d := ha_bwd ⟨n, by omega⟩
```

### Target
```lean
let a_n := a_bwd ⟨n, by omega⟩
-- S_C = continuation set
let S_C := continuation_set x' y' a_n
have hS_ne : S_C.Nonempty := continuation_set_nonempty hx'y'
have ha_n_S : a_n ∈ S_C := a_n_in_continuation_set (ha_bwd ⟨n, by omega⟩)

-- Case split: infimum at carrier point or gap
by_cases h_point_inf : ∃ p : N.carrier,
    (∀ s ∈ S_C, (extendPoint p : ExtendedCarrier N atomMap r) ≤ s) ∧
    (∀ q : N.carrier, (∀ s ∈ S_C, (extendPoint q : ...) ≤ s) → ... ≤ extendPoint p)
· -- Point infimum case
  obtain ⟨p₀, hp₀_lb, hp₀_glb⟩ := h_point_inf
  let d : ExtendedCarrier N atomMap r := extendPoint p₀
  have hd_interval : inClosedInterval x' y' d := ⟨PROVE_x'_le_d, le_trans (hp₀_lb a_n ha_n_S) (ha_bwd _).2⟩
  have hd_le_an : d ≤ a_n := hp₀_lb a_n ha_n_S
  -- Continue with this d...
  
· -- Gap infimum case
  -- Need prerequisites for infimum_gap: h_pt_below, h_above, h_not_point_glb
  have h_pt_below : ∃ p, ∀ s ∈ S_C, (extendPoint p : ...) ≤ s := by
    -- x' ≤ all s ∈ S_C. If x' is a carrier point, use it.
    -- If x' is a gap, use a carrier point in x'.cut (nonempty by Gap.nonempty)
    sorry
  have h_above : ∃ (q : N.carrier) (s : S_C), (extendPoint q : ...) > s.val := by
    -- a_n ∈ S_C. Need carrier point above... 
    -- From h_pt, ∃ p ∈ [x', y']. If p > inf, use p.
    sorry
  let γ := infimum_gap hS_ne h_pt_below h_above (by push_neg at h_point_inf; exact h_point_inf)
  let d : ExtendedCarrier N atomMap r := Sum.inr ⟨γ, infimum_gap_r_definable hx'y' ... ⟩
  have hd_le_an : d ≤ a_n := sorry -- inf ≤ member
  -- Continue with this d...
```

### Prerequisites to prove
- `x' ≤ d` when d = extendPoint p₀ (p₀ is glb of S_C, S_C ⊆ [x', y'])
- `h_pt_below` for gap case: carrier point below S_C (from x' structure)
- `h_above` for gap case: carrier point above some S_C element (from h_pt + a_n ∈ S_C)
- `hd_le_an`: infimum ≤ a_n (trivial from a_n ∈ S_C)

## Change 2: d_consistency — add infimum characterization

### Current hypotheses
```lean
(hcd_form : formula agreement at rank r)
(hcd_gp : point/gap agreement)
(hcd_boundary : boundary correspondence)
(h_fwd : rank r strategy)
(h_fwd_r1 : rank r+1 strategy)
```

### Add hypothesis
```lean
(h_d_is_inf : ∀ t, inClosedInterval x' y' t →
    (∀ u, t < u → u < y' → mu_holds u → cont_holds a_n y' u) →
    d ≤ t)
```

This says: d ≤ any element that satisfies the continuation property — i.e., d is a lower bound of continuation_set. Since d IS the infimum, this holds.

### Claim 1 proof sketch
```
1. Apply h_fwd_r1 to get rank-(r+1) response t_r1
2. t_r1 satisfies formula agreement at rank r+1 with rank_embed c
3. The continuation formula C = "∀ A (depth ≤ r), if A at all mu-points in (a_n, y') then A at t" has depth ≤ r
4. C' = ¬C ∨ K⁻¬C has depth ≤ r+1
5. C' characterizes the infimum: C'(d) holds, C'(t) fails if t < d (Spoiler exploits the gap)
6. Formula agreement at rank r+1 gives C'(t_r1) ↔ C'(rank_embed d)
7. Therefore t_r1 = rank_embed d
8. Since rank_embed is injective on carrier points: t = d
```

The challenge: step 4-6 require defining C and C' concretely as StaviFormula terms. C might not be directly expressible as a single StaviFormula (it quantifies over ALL formulas of depth ≤ r). 

**Alternative**: Instead of the C' formula approach, use the continuation set directly:
1. t_r1 has formula agreement at rank r+1 with rank_embed c
2. Show t_r1 is in the (rank r+1) continuation set (by formula transfer from rank_embed d)
3. Show d is the infimum, so rank_embed d ≤ t_r1
4. Show t_r1 ≤ rank_embed d (by similar argument in the other direction)
5. Therefore t_r1 = rank_embed d

Step 4 is the key: why can't t_r1 be above d? Because if t_r1 > d, there's a gap between d and t_r1 where continuation fails, and Spoiler can exploit this at rank r+1.

## Change 3: Case II rewrite (line 2841)

### GHR93-faithful approach
1. All a_bwd(i) > d (strictly): from hd_le_an and d being the infimum (d < a_bwd(i) for i < n; d ≤ a_bwd(n) with d < a_bwd(n) when d is strictly below)

Actually, d = infimum might EQUAL a_bwd(n) if a_bwd(n) is itself the minimum of continuation_set. In that case, h_no_split (d ≤ a_bwd(i) for all i) is compatible with d = a_bwd(n). But then hd_eq_an holds and the OLD Case II works!

**Key insight**: if d = infimum = a_bwd(n), the OLD Case II proof is valid (hd_eq_an = rfl). The ONLY case where we need the NEW Case II is when d < a_bwd(n) (infimum is strictly below). But in that case, the OLD Case II was never called — d < a_bwd(n) means ¬(d ≤ a_bwd(i) for all i with d = a_bwd(n))... wait, d IS a_bwd(n) in the old code.

Hmm, with d = infimum:
- If infimum = a_bwd(n): d = a_bwd(n), hd_le_an is an equality, OLD Case II works
- If infimum < a_bwd(n): d ≠ a_bwd(n), need NEW Case II

But Case II's hypothesis is `h_no_split : ∀ i, d ≤ a_bwd i`. With d = infimum:
- If infimum < a_bwd(n): d < a_bwd(n), but d ≤ a_bwd(i) for all i (infimum ≤ member). So h_no_split holds.
- All a_bwd(i) are STRICTLY above d when d < a_bwd(n).

In GHR93, Case II handles the case where all alpha_i > d-bar. The code should:
1. Use tau on a_bwd(0),...,a_bwd(n-1) to get resp_tau(0),...,resp_tau(n-1)
2. From a_bwd(n) in continuation set: U(B,A)(a_bwd(n)) holds (continuation property)
3. By tau's formula transfer: U(B,A)(resp_tau(n-1)) holds in M
4. Construct e_n from U(B,A)(resp_tau(n-1)): ∃ z > resp_tau(n-1) with B(z) ∧ A on (resp_tau(n-1), z)
5. Set a'_resp = (resp_tau(0),...,resp_tau(n-1), e_n)
6. Verify winning condition

This is ~300-500 lines of careful proof writing with game tuple manipulation.

## Execution Strategy

The refactoring is ATOMIC (Step 1 breaks build, all downstream must change together). Recommended approach:

1. Phase A: Change d definition + hd_le_an + hd_interval. Sorry all downstream breakage.
2. Phase B: Fix d_consistency (add infimum hypothesis, prove via Claim 1 or sorry body).
3. Phase C: Fix Case I (only needs ≤, should be easy).
4. Phase D: Rewrite Case II (the big one, ~300-500 lines).
5. Phase E: Fix callers (pass infimum hypothesis).

Each phase can be committed separately if sorry's are used as placeholders. The key is getting the INTERFACE right first (Phase A), then filling in proofs.

## Estimated Effort
- Phase A: 2-3 hours (infimum construction with all prerequisites)
- Phase B: 1-2 hours (Claim 1 or sorry)
- Phase C: 0.5 hours (≤ fixes)
- Phase D: 4-8 hours (Case II full rewrite)
- Phase E: 0.5 hours (caller fixes)
- **Total: 8-14 hours**
