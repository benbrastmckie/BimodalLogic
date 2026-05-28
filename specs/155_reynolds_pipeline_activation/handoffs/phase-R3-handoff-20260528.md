# Phase R3 Handoff: Case II Restructure (Updated)

**Date**: 2026-05-28
**Session**: sess_1748404800_caseii2
**Phase**: R3 (CaseAnalysis Rewrite)
**Status**: In Progress

## What Was Done

Restructured `ghr93_case_II` in CaseAnalysis.lean to fix the cross-game ordering problem in Case B (Round 2). The old approach used the original tau at rank r+delta for Round 2, while Round 1 responses came from tau_left at rank r -- two different games with no ordering relationship. The new approach sub-splits Case B on b_sp vs e_n:

- **Case B1** (c < b_sp <= e_n): Uses tau_left for both Round 1 and Round 2. All orderings from a single game's winning condition.
- **Case B2** (b_sp > e_n): Uses tau_right for Round 2. Orderings from interval containment + tau_right.

### Key Architectural Change

The old code played the composed backward game `tau_composed` for Round 1, but then used the ORIGINAL tau (at rank r+delta, projected) for Round 2. This created a cross-game ordering mismatch that manifested as 6 sorry sites.

The new code plays tau_left directly for Round 1 (giving resp_left, from which resp_mod is derived), and then for Round 2:
- B1: plays tau_left again. The key ordering `tau_b_pn` (b_resp < p_n iff b_sp < e_n) comes directly from tau_left's winning condition at positions n+1 vs n+2.
- B2: plays tau_right. The orderings between resp_mod and b_resp follow from interval containment (resp_mod(k) <= e_n < b_sp, and b_resp >= p_n > a_init(k)).

### Lines Changed

- Deleted 2147 lines of old block-commented Case II proof
- Added ~550 lines of new proof
- Net: reduced CaseAnalysis.lean from 4712 to ~3350 lines

### Sorry Sites

**In Case II** (4 sorry sites, down from 8):
1. Line 1668: Case A grid dispatch rename_i pattern (pre-existing)
2. Line 1669: Case A grid dispatch rename_i pattern (pre-existing)
3. Lines 2026-2027: Case B1 grid dispatch edge cases (2 goals: b_resp vs x' equality, remaining fallback)
4. Line 2107: Case B2 same_order_type (full sorry -- same pattern as B1 but needs tau_right orderings)

**Outside Case II** (1 sorry site):
5. Line 3350: Cases III/IV winning condition (pre-existing, independent of Case II)

## Immediate Next Action

Close the 4 remaining sorry sites in Case II ordering:

### B1 edge cases (lines 2026-2027)
- Line 2026: Need `b_resp = x' -> b_sp = x` (equality direction). Should follow from interval containment + sigma orderings.
- Line 2027: Remaining grid dispatch alternatives. Try adding more patterns to the `first | ...` chain.

### B2 ordering (line 2107)
- Same structure as B1 but using tau_right orderings instead of tau_left.
- Key orderings: resp_mod(k) <= e_n < b_sp (from interval containment), b_resp >= p_n (from tau_right interval), b_resp vs p_n iff b_sp vs e_n (from tau_right winning condition).
- Use `hord_right_b` to extract ordering facts from tau_right.

### Case A rename_i (lines 1668-1669)
- The `rename_i` patterns from the old code had specific numbers of underscores that no longer match.
- Alternative: use `intro` with `omega` to identify the offending indices.

## Key Decisions

1. **Did NOT use U(B,sf_top) transfer** (the "correct" GHR93 approach). This requires the Stavi expressive completeness chain (Phases 6D-6F) which has sorry in `nf_2var_existence_characterizable`. The tau_left/tau_right sub-split approach achieves the same result without needing the characteristic formula.

2. **Kept forward-game e_n construction**. The forward game gives e_n with full rank-r formula agreement with p_n, which is exactly what's needed.

3. **resp_mod approach preserved**. When a_init(k) = p_n, respond with e_n; otherwise use resp_left(k). This handles the equality case cleanly and sel_pn_ord follows directly.

## Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (main, ~3350 lines)
- `specs/155_reynolds_pipeline_activation/plans/40_rank-restructuring-plan.md` (updated R3 tasks)
