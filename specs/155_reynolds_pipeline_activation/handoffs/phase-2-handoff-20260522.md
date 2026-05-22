# Phase 2 Handoff (Round 3): Lemma 9 Gap Detection

## Summary

Deleted provably false theorems `std_untl_gap_detection` and `std_snce_gap_detection`. Fixed pre-existing type class synthesis error in stavi_untl backward proof. Verified approach for base.snce forward direction.

## What Was Done

1. **Deleted false theorems**: `std_untl_gap_detection` (was line 2682) and `std_snce_gap_detection` (was line 3256) replaced with explanatory comments. Build passes.

2. **Fixed build error**: Pre-existing type class error at line 3228 in stavi_untl backward proof. Added explicit `@LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT` annotation.

3. **Verified D-failure argument** for base.snce forward direction:
   - From `¬U'(D, g∧D)(s) ∧ U'(⊤, g∧D)(s)`: D must fail somewhere above s
   - Proof by contradiction: if D held everywhere, construct U'(D, g∧D)(s) using same FO table witnesses
   - For condition (1), case split on `u < u_fail_gD`: left disjunct uses D-everywhere, right uses ¬(g∧D) witness
   - This argument type-checks in Lean (verified via lean_goal)

## Remaining Sorry Sites in EFGames.lean (7)

| # | Line | Location | Status | Approach |
|---|------|----------|--------|----------|
| 1 | 2895 | base.snce | APPROACH VERIFIED | D-gap construction from compound (see below) |
| 2 | 3307 | stavi_snce case | BLOCKED | Needs stavi_snce_gap_detection |
| 3 | 3387 | std_snce case | NEEDS DIRECT PROOF | Same compound decomposition as base.snce |
| 4 | 3409 | stavi_snce_gap_detection | NEEDS REFACTOR | RHS too strong; mirror untl with reversed inequalities |
| 5 | 3425 | right_formula_gap_detection | BLOCKED | Needs #4 + dual of all left cases |
| 6 | 4486 | ghr93_decomposition_implies_game | Phase 4 |
| 7 | 5788 | stavi_expressive_completeness | Phase 4 |

## base.snce Forward Direction: Detailed Proof Plan

### Setup (verified, ~15 lines)
```lean
simp only [left_formula_base]
rw [stavi_truth_mu_at_point m (.std_untl _ D)]
simp only [stavi_temporal_truth]
constructor
· intro ⟨s, hms, h_compound_s, hD_bet_ms⟩
  obtain ⟨hDs, hgs, hSnce_s, hU'top_gD_s, hNotU'D_gD_s⟩ := h_compound_s
  simp only [stavi_temporal_truth] at hU'top_gD_s
  obtain ⟨s₁, hss₁, h_body_gD, ⟨u_fail_gD, ...⟩, ⟨u_init_gD, ...⟩⟩ := hU'top_gD_s
```

### Step 1: D fails above s (~20 lines, verified)
```lean
have hD_fails : ∃ u_D, s < u_D ∧ ¬stavi_temporal_truth M atomMap u_D D := by
  by_contra h_all; push_neg at h_all
  apply hNotU'D_gD_s; simp only [stavi_temporal_truth]
  refine ⟨s₁, hss₁, ?_, conditions_2_3_reuse⟩
  intro u hsu hus₁
  by_cases h_lt : u < u_fail_gD
  · left; exact ⟨u_fail_gD, h_lt, D_everywhere⟩
  · right; exact ⟨D_everywhere, u_fail_gD, ...⟩
```

### Step 2: D initial segment (~10 lines, verified)
```lean
have hD_init : ∀ v, s < v → v < u_init_gD → stavi_temporal_truth M atomMap v D
have hD_full_init : ∀ v, m < v → v < u_init_gD → stavi_temporal_truth M atomMap v D
```

### Step 3: Construct D-gap (~120 lines, follows stavi_untl_gap_detection pattern)
Replicate the cut construction from `stavi_untl_gap_detection` forward direction:
- `cut = {x | ∀ u, m < u → u ≤ x → ∃ v > u, D on (m, v)}`
- D on (m, s) + D(s) → s ∈ cut? No, s might not be in cut. Actually m ∈ cut.
- Use h_body_gD (condition 1 from U'(⊤, g∧D)(s)) for cofinal propagation
- Key difference: the "condition (1)" here is for g∧D, not D. Need to extract D-cofinal from g∧D-cofinal. This works because g∧D ⊆ D (g∧D → D).

**IMPORTANT**: The condition (1) body `h_body_gD` uses g∧D, not D. For the cut construction, we need D-cofinality, not g∧D-cofinality. The left disjunct of h_body_gD gives `∃ v > u, g∧D on (s, v)` which implies `D on (s, v)`. So D-cofinality follows from g∧D-cofinality.

### Step 4: Show S(f,g)^mu at the D-gap (~30 lines)
- hSnce_s : S(f,g)(s), s is an actual point, s ∈ cut (or near cut boundary)
- Need S(f,g)^mu at the gap γ = ∃ t < γ (mu-point), f^mu(t) ∧ g^mu on (t, γ)
- Use s as the mu-point since s is in the cut (below the gap)
- f(s) from S(f,g)(s), g(s) from compound

### Step 5: Backward direction (~100 lines)
Given D-gap γ with S(f,g)^mu(γ), construct std_untl(compound, D)(m).
Need s > m with compound(s) and D on (m, s).
- From D-between: D holds at cut points between m and γ
- Need a complement point s where ALL compound components hold
- S(f,g)^mu(γ) gives witnesses at complement points
- g∧D at cut points (from D-definability), ¬(g∧D) at complement (from definability)
- U'(⊤, g∧D) at complement points from gap structure
- ¬U'(D, g∧D) from D-failure at complement points

## Depth Issue: RESOLVED

`stavi_untl_gap_detection` requires `stavi_depth D ≤ r` to produce `RDefinableGap`. The base.snce proof constructs a D-gap (not a (g∧D)-gap), so only `stavi_depth D ≤ r` is needed (which we have as `hD`). The approach does NOT use `stavi_untl_gap_detection` as a black box — it inlines the gap construction from raw FO table data.

## Recommended Approach

1. **Extract gap construction helper** from `stavi_untl_gap_detection` forward direction (~160 lines) into a standalone lemma that produces `Gap M.carrier` (not `RDefinableGap`). This eliminates the depth constraint from the construction and allows reuse.

2. **Apply helper** in base.snce with the D-cofinal data extracted from the compound's FO table.

3. **stavi_snce_gap_detection**: Refactor RHS to match untl pattern, then prove by mirroring stavi_untl_gap_detection backward direction.

## Files Modified
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` — deleted false theorems, fixed type class error
