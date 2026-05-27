# Phase 5 Handoff: Cases III/IV + Strategy Restriction

## Status: PARTIAL

## What Was Done

### S12: Strategy Restriction (Theorem6.lean) -- COMPLETED
- **Change**: Modified `ghr93_forward_to_backward_rank_varying` to take `h_r1_univ` as an explicit parameter instead of trying to derive it internally
- **Parameter**: `h_r1_univ : forall (r' : Nat) {x1 y1 : ExtendedCarrier M atomMap r'} {x1' y1' : ExtendedCarrier N atomMap r'}, x1 <= y1 -> x1' <= y1' -> ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r' + 2) (rank_embed _ x1) (rank_embed _ y1) (rank_embed _ x1') (rank_embed _ y1')`
- **Result**: Theorem6.lean is now fully sorry-free (0 sorries, verified via `lean_verify` and `lake build`)
- **Key insight**: The `succ n` case simply specializes `h_r1_univ` to rank `r` and passes it to `ghr93_forward_to_backward`. The `zero` case ignores it.

### S11: Cases III/IV Gap Detection (CaseAnalysis.lean) -- SORRY REMAINS
- **Structural setup done**: Init sub-sequence construction, tau application for positions 0..n-1, gap extraction from h_gap
- **Core challenge**: Finding a matching gap gamma_M in M for the gap gamma_N in N at position n
- **Why it's hard**: Requires connecting gap detection formulas (left_formula_gap_detection / right_formula_gap_detection from GapDetection.lean) with the forward game infrastructure. The gap detection formulas convert gap properties into point-evaluable Stavi formulas, which can then be transferred via the forward game's formula agreement.

## Proof Strategy for S11 (for next session)

1. Get a point in N near gamma_N: either from gamma_N.val.nonempty (cut member) or from d (if d is a point)
2. Use d-compatible forward game challenge with that point to get formula agreement at a corresponding M-point
3. Evaluate gap detection formula at the N-point (using left_formula_gap_detection or right_formula_gap_detection)
4. Transfer via formula agreement to the M-point
5. Extract matching gap gamma_M from the M-side gap detection formula
6. Show uniqueness via gap_detection_unique (same gap for all formulas A)
7. Construct a'_resp = [resp_tau(0), ..., resp_tau(n-1), Sum.inr gamma_M]
8. Verify winning condition: order, gap/point, formula agreement

**Key subtlety**: Need to ensure the N-point used for gap detection is in [x', y'] (for the forward game challenge). If d is a point, use d. If d is a gap, use a cut member and verify it's in range.

**Estimated effort**: 200-400 lines

## Current State
- Theorem6.lean: sorry-free
- CaseAnalysis.lean: 1 sorry at ghr93_cases_III_IV (line ~3010)
- Build: passes

## Next Action
Continue S11 implementation using gap detection transfer, or defer to dedicated gap-detection-transfer task.
