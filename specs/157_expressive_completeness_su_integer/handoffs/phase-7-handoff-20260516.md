# Phase 7 Handoff: Elimination Cases 2-4 Completed

## Status
- Cases 1-4: FULLY PROVED (0 sorry)
- Cases 5-8: sorry (4 remaining)

## Key Decisions Made

1. **Case 2 proof strategy**: Uses neg_until_equiv to split ¬U(A,B) into G(¬A) ∨ U(¬A∧¬B, ¬A). The first branch gives S(a∧G(¬A), q) which is directly separated. The second is Case 1 with modified args.

2. **Cases 3 and 4 proof strategy**: Use neg_since_equiv to negate S(a, q∨U) or S(a, q∨¬U). The negation gives H(¬a) ∨ S(..., ¬a) where the S-part is either Case 2 (for Case 3) or Case 1 (for Case 4). Then the original ↔ ¬H(¬a) ∧ ¬(result). Separation: and_separated + neg_separated.

3. **Case 5 formula problem**: The formula `S(a,B) ∧ B ∧ U(A,B)` for the "U passes t" disjunct is WRONG because S(a,B) requires B on the full interval (s,t), which isn't available when the U-chain has gaps filled by A. The correct formula uses S(a, A∨B) instead of S(a, B). Backward direction then uses well-ordering to find the smallest A-point in (s,w) as the U-witness.

## Next Actions

1. Implement Case 5 with formula using (A∨B):
   - psi5 = [S(a,A∨B) ∧ (A∨B) ∧ U(A,B)] ∨ [A ∧ S(a,A∨B)] ∨ S(A∧q∧S(a,A∨B), q)
   - Forward: well-ordering to find last non-q point m, case split on U-witness at m
   - Backward: use smallest A-point in (s,t) as U-witness (well-ordering gives B below it)

2. Cases 6-8 reduce to earlier cases once Case 5 is available:
   - Case 6: neg_until_equiv on event → Case 5 with modified args
   - Case 7: neg_until_equiv on guard → Case 5 analog
   - Case 8: compose reductions from Cases 6+7

## Current Proof State

File: Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean (365 LOC)
Build: passes with 4 sorry warnings (Cases 5-8)
