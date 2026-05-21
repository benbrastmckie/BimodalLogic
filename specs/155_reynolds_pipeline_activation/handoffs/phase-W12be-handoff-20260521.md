# Phase W1.2b+e Handoff

**Date**: 2026-05-21
**Session**: sess_1779383375_6c61c3
**Status**: PARTIAL -- W1.2b COMPLETED, W1.2d improved, W1.2e PARTIAL

## What Was Done

### W1.2b: continuation_set open interval fix (COMPLETED)
- Changed `continuation_set` definition from half-open `(t, y']` to open `(t, y')`
- `u ≤ y'` replaced with `u < y'` at line 146
- `continuation_set_nonempty`: updated proof (trivial -- `lt_trans` instead of `lt_of_lt_of_le`)
- `a_n_in_continuation_set`: sorry at line 209 ELIMINATED (edge case u=y' impossible with open interval)
- `cont_fails_below_gap`: conclusion changed from `u ≤ y'` to `u < y'` (stronger theorem), proof updated
- `formula_failure_in_cut`: automatically consistent since both the continuation_set condition and the cont_fails_below_gap output now use `u < y'`

### W1.2d: infimum_gap_r_definable first conjunct (CLOSED)
- Added `h_above_gap_below_y'` hypothesis: ∃ q₀ ∉ cut with extendPoint q₀ < y' and x' ≤ extendPoint q₀
- First conjunct proved: use q₀ as witness t, all u ≤ q₀ satisfy extendPoint u < y', so cont_holds_above_gap applies without hitting y' edge case
- No callers of `infimum_gap_r_definable` exist yet (private theorem), so adding hypothesis is free

### W1.2e: d_consistency theorems (PARTIAL)
- Added `d_consistency_left` and `d_consistency_right` as standalone theorems
- Both have correct type signatures matching what `ghr93_strategy_restrict_left/right` expect
- Both have sorry bodies (full GHR93 Claim 1 proof needed)
- Wired into `obtain_split_point_props`, replacing 2 inline sorries

## Remaining Sorries in ExpressivenessGeneral.lean (8 sites)

| Line | Identifier | Notes |
|------|-----------|-------|
| 479 | `cont_holds_above_gap` y' case | Genuinely hard: need stavi_temporal_truth limit argument at endpoint |
| 583 | `pigeonhole_definable_formula` | Needs NormalForm-to-rank_type finiteness bridge (~80-120 lines) |
| 886 | `d_consistency_left` | Needs full GHR93 Claim 1 (infimum + uniqueness) |
| 919 | `d_consistency_right` | Dual of d_consistency_left |
| 1249 | degenerate gap sub-case (h_pt_xc) | Pre-existing, x=c both gaps |
| 1370 | gap case in obtain_split_point_props | Pre-existing, Lemma 9 needed |
| 3274 | merged_order_type | Pre-existing |
| 3495 | main theorem | Pre-existing |

## Immediate Next Action

The highest-impact next step is the **pigeonhole_definable_formula** NormalForm bridge. This requires:
1. A bridge theorem: `stavi_temporal_truth_mu N atomMap r (extendPoint p) A` ↔ some property of `nf_characteristic N r 1 (fun _ => p)`
2. Using NormalForm Fintype (NormalForm.lean:178) to show the set of rank_types at carrier points is finite
3. Standard pigeonhole argument: if no single formula fails cofinally, then the max of finitely many "last failure points" gives a contradiction with h_cofinal_failure

## Key Decisions

1. **Open interval for continuation_set**: The GHR93 text uses "t ∈ (c, y')" (open) for the continuation predicate. The half-open interval was a formalization error that created an unprovable edge case. The fix is sound and all downstream proofs adapt cleanly.

2. **Added h_above_gap_below_y' hypothesis**: The infimum_gap_r_definable first conjunct needs a carrier point between the gap and y'. In practice this always exists (since a_n < y' implies gap ≤ a_n < y'), but the lemma didn't have this as a hypothesis. Added it explicitly rather than trying to derive it from existing hypotheses.

3. **d_consistency as standalone theorems**: Rather than proving d-consistency inline (which was impossible since it requires the full Claim 1 argument), extracted it into clean standalone theorems with correct signatures. The sorry is now LOCALIZED rather than inline in a 300-line proof.
