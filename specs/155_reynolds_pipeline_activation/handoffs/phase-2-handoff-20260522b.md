# Phase 2 Handoff (Round 4): Lemma 9 Gap Detection

## Summary

No additional sorry sites closed this round. Deep investigation of base.snce forward direction identified the precise D-failure localization strategy and confirmed the proof architecture compiles. The destructured setup with all FO table components works in Lean. The remaining work is mechanical (but long).

## Key Finding: D-Failure Localization

The forward direction of base.snce requires constructing U'(⊤, D)(m) with bound s₁ (from U'(⊤, g∧D)(s)). This requires D to fail within (m, s₁).

**Proof that D fails in (m, s₁)**: By contradiction. If D held throughout (m, s₁), then U'(D, g∧D)(s) would hold with the same bound s₁: the only difference between U'(⊤, g∧D) and U'(D, g∧D) is the A-position in the right branch body (⊤ vs D). With D everywhere on (m, s₁) ⊇ (u, s₁) for any u ∈ (s, s₁), the right branch with D succeeds whenever the right branch with ⊤ does. This contradicts hNotU'D_gD_s.

## Proof Architecture (Verified to Compile)

After `simp only [left_formula_base]`, `rw [stavi_truth_mu_at_point m (.std_untl _ D)]`, `simp only [stavi_temporal_truth]`:

```lean
-- Forward setup (COMPILES):
intro ⟨s, hms, hcompound_s, hD_bet⟩
obtain ⟨hDs, hgs, hSnce_s, hU'top_gD_s, hNotU'D_gD_s⟩ := hcompound_s
obtain ⟨s₁, hss₁, h_body_gD, h_gD_fail, h_gD_init⟩ := hU'top_gD_s
obtain ⟨u_fail_gD, hsu_fail, hu_fail_s₁, hgD_fail⟩ := h_gD_fail
obtain ⟨u_init_gD, hsu_init, hu_init_s₁, hgD_init⟩ := h_gD_init
```

**Critical**: Do NOT use `simp only [stavi_temporal_truth] at hU'top_gD_s` — it's a no-op and blocks the subsequent `obtain`. Destructure directly.

## Remaining Steps for base.snce Forward

1. **D-failure in (m, s₁)** (~25 lines): by_contra h_all; construct U'(D, g∧D)(s) from h_body_gD + D-everywhere; contradict hNotU'D_gD_s.

2. **D initial segment** (~10 lines): D on (m, u_init_gD) from hD_bet + hgD_init.

3. **Construct U'(⊤, D)(m) with bound s₁** (~40 lines):
   - Condition (1): for u ≤ s, use D-cofinal from init segment. For u > s, extract D-cofinal from h_body_gD left branch (g∧D-cofinal → D-cofinal). For right branch, use D-failure witness from step 1.
   - Condition (2): D-failure point from step 1.
   - Condition (3): D on (m, u_init_gD).

4. **Apply stavi_untl_gap_detection** (~5 lines): get D-gap γ from U'(⊤, D)(m).

5. **S(f,g)^mu at γ** (~30 lines): s ∈ cut (s < γ since D(s) holds and γ is where D transitions). S(f,g)(s) → S(f,g)^mu(γ) using s as mu-point witness.

## Remaining Phase 2 Sorry Sites (5)

| # | Line | Status | Next Step |
|---|------|--------|-----------|
| 1 | ~2890 | base.snce | Architecture verified, ~110 lines to implement |
| 2 | ~3332 | stavi_snce case | Blocked on stavi_snce_gap_detection |
| 3 | ~3412 | std_snce case | Same compound decomposition as base.snce |
| 4 | ~3368 | stavi_snce_gap_detection | Needs RHS refactoring + ~250 lines |
| 5 | ~3384 | right_formula_gap_detection | Blocked on above + dual of all left cases |

## Technical Notes

- `hU'top_gD_s` type after first `obtain`: raw ∃ form (already expanded, simp is no-op)
- `hNotU'D_gD_s` differs from `hU'top_gD_s` ONLY in right branch A-position: `Formula.top` vs `D`
- `h_body_gD` left branch gives g∧D-cofinal → D-cofinal (since g∧D → D)
- `h_body_gD` right branch has `Formula.top` in A-position (always true, irrelevant)
- Gap ordering needs `@LT.lt (ExtendedCarrier M atomMap r) extendedLinearOrder.toLT`
