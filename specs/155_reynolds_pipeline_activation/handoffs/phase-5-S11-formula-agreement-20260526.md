# Phase 5 S11: Formula Agreement via Gap Detection Unique

## Status: PARTIAL (4 S11 sorries from original 2)

## Summary

Decomposed the S11.1 sorry (gap matching) into a structured proof with
well-typed sub-goals. The core formula agreement (A(γ_M) ↔ A(γ_N)) is
now fully proved via the gap detection transfer chain + gap_detection_unique.

## What Was Done

### S11.1 Left Case Structure (PROVED except sub-sorries)

1. **Reference point m_N**: Constructed carrier point m_N ∈ γ_N.val.cut ∩ [x', y']
   with D-between condition. Case splits on d being point vs gap:
   - d is point: d_pt ∈ cut, x' ≤ d_pt. PROVED.
   - d is gap (strict): find element in γ_N.cut \ g_d.cut. PROVED.
   - d = γ_N (degenerate): SORRY (edge case, line 3170).

2. **Forward game extraction**: Reduced h_fwd_r3 to 1-round game, challenged
   with m_N to get m_M. PROVED.

3. **Formula agreement at carrier points**: Proved hform_pts via
   stavi_truth_mu_at_point (rank-independence of carrier-point truth). PROVED.

4. **Gap detection transfer (forward)**: left_formula_gap_detection backward
   at m_N, transfer via hform_pts, forward at m_M. PROVED.

5. **γ_M existence**: Instantiated hform_transfer with sf_verum to get γ_M
   as a D-left-definable gap above m_M. PROVED.

6. **Interval bound**: x ≤ m_M < γ_M (proved). γ_M ≤ y: SORRY (line 3324).

7. **Formula agreement iff**: BOTH DIRECTIONS PROVED.
   - Forward (A(γ_M) → A(γ_N)): left_formula backward at m_M with γ_M,
     transfer to m_N, extract via left_formula at m_N, gap_detection_unique
     identifies the extracted gap as γ_N.
   - Backward (A(γ_N) → A(γ_M)): hform_transfer gives γ_A, then
     gap_detection_unique identifies γ_A = γ_M.

### Right Case (SORRY, line 3395)
Symmetric to left case using right_formula_gap_detection and
gap_detection_unique_right. Not yet written.

### S11.3 Winning Condition (SORRY, line 3449)
Unchanged from previous. Follows Case II pattern (~200 lines).

## Remaining Sorries (S11-specific)

| Line | Type | Description | Difficulty |
|------|------|-------------|------------|
| 3170 | degenerate | d = Sum.inr γ_N edge case | Medium |
| 3324 | interval | γ_M ≤ y upper bound | Hard |
| 3395 | symmetric | Right D-definability case | Medium (boilerplate) |
| 3449 | assembly | S11.3 winning condition | Hard (200+ lines) |

## Key Techniques Used

- `gap_detection_unique`: proves two D-left-definable gaps above the same
  reference point with the same D-between condition must be equal
- `left_formula_gap_detection`: converts gap properties ↔ temporal formula truth
- `stavi_truth_mu_at_point`: carrier-point truth is rank-independent
- `rank_embed_stavi_truth_mu`: truth preserved by rank embedding
- Forward game round reduction via `ghr93_duplicator_wins_round_mono`

## Build Verification

- `lake build` passes (1667 jobs, 0 errors)
- Phase 3C sorries untouched (lines 1423, 1792, 2003, 2056)
- Theorem6.lean: sorry-free (not modified)
