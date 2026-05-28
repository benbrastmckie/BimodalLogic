# Phase R1 Handoff: SplitPointProps Restructuring

**Task**: 155 (reynolds_pipeline_activation)
**Phase**: R1 -- SplitPointProps Restructuring
**Status**: COMPLETED
**Date**: 2026-05-27
**Session**: sess_1779937857_21f022

## What Was Done

Added `delta : Nat` parameter to `SplitPointProps` so that sigma/tau live at rank `r + delta` on rank-embedded positions. Updated `obtain_split_point_props` to accept the new `delta` parameter and an IH that produces backward games at rank `r + delta`.

### Concrete Changes

**File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean`

1. **Structure definition** (line 44): Added `(delta : Nat)` parameter after `(n : Nat)`.

2. **sigma field** (was line 89): Changed from `ghr93_duplicator_wins N M atomMap n r x' d x c` to `ghr93_duplicator_wins N M atomMap n (r + delta) (rank_embed ...) (rank_embed ...) (rank_embed ...) (rank_embed ...)` with rank-embedded positions.

3. **tau field** (was line 92): Same change as sigma but for the right sub-interval `[d,y']/[c,y]`.

4. **obtain_split_point_props**: Added `(delta : Nat)` parameter. Changed `ih` signature to return backward games at `r + delta` on rank-embedded positions. Updated sigma/tau construction:
   - Non-degenerate case: `ih` directly produces the right type
   - Degenerate gap case: inlined the gap vacuity argument directly (avoids formula-agreement depth mismatch that would occur when calling `ghr93_duplicator_wins_degenerate_gap` at rank `r + delta`)

5. **h_fwd_r1 retained**: The plan suggested removing this parameter, but it is essential for the c-d correspondence proof (K-(negD) argument at rank r+2), which is independent of sigma/tau's rank.

6. **All other fields unchanged**: hc_interval, hd_interval, hd_le_an, hxc, hcy, hx'd, hdy', h_pt_xc, h_pt_cy, hcd_form, hcd_gp, h_fwd_n1, h_d_compat_left all remain at rank r.

### Verification

- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.SplitPoint` passes
- `lean_verify obtain_split_point_props`: axioms = [propext, Classical.choice, Quot.sound] (no sorryAx)
- No sorry in SplitPoint.lean (grep confirms only comments mention sorry)

### Downstream Breakage

CaseAnalysis.lean breaks at 5 call sites (lines 68, 1197, 3419, 4554, 4690) where `SplitPointProps` is used without the new `delta` parameter. This is expected and will be fixed in:
- Phase R2: Update Theorem6.lean induction to carry delta
- Phase R3: Update CaseAnalysis.lean to pass delta

## Key Decisions

1. **Degenerate gap inlining**: Instead of calling `ghr93_duplicator_wins_degenerate_gap` at rank `r + delta` (which would require formula agreement at depth `r + delta`, but we only have it at depth `r`), the degenerate case is proved directly by showing Round 2 is vacuous (gap interval has no carrier points). This avoids a depth mismatch that is mathematically irrelevant (the formula agreement is never used in the degenerate case).

2. **h_fwd_r1 kept**: The plan suggested removing this parameter, but it is needed for the Claim 1 K-(negD) argument that proves r2_resp = rank_embed(d). This argument operates at rank r+2 and is independent of sigma/tau's rank.

3. **No new helper lemmas needed**: The existing rank_embed infrastructure (rank_embed_le, rank_embed_lt, rank_embed_isPoint, rank_embed_stavi_truth_mu, rank_embed_inClosedInterval) was sufficient.

## Next Action

**Phase R2**: Restructure `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` to carry the rank offset through the induction. Specifically:
- Update `ghr93_forward_to_backward_core` to accept `delta` and pass it to the SplitPointProps construction
- Update `ghr93_forward_to_backward` and `ghr93_forward_to_backward_rank_varying`
- Remove char_k parameters (replaced by full rank-r type formula via tau at r+4)
