# Implementation Summary: Task #70 - Separate-Direction Witnesses (v5)

**Task**: Explore ultrafilter-based construction for temporal coherence
**Plan Version**: v5 (separate-direction witnesses)
**Status**: Implemented
**Date**: 2026-03-30

## Overview

This task analyzed and documented the temporal coherence approach for completeness.
The bidirectional witness approach (plan v4) was found to be BLOCKED due to
H_theory elements not being G-liftable. The working approach uses separate-direction
witnesses via SuccChainFMCS, achieving cross-direction coherence at the chain level.

## Phases Completed

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Archive bidirectional construction | COMPLETED |
| 1 | Prove Succ relation G-propagation | COMPLETED (pre-existing) |
| 2 | Prove Succ relation H-propagation | COMPLETED (pre-existing) |
| 3 | Chain-level G-propagation (forward) | COMPLETED (pre-existing) |
| 4 | Chain-level H-propagation (backward) | COMPLETED (pre-existing) |
| 5 | Package as TemporallyCoherent FMCS | COMPLETED (pre-existing) |
| 6 | Connect to truth lemma | COMPLETED |
| 7 | Document F/P gaps and next steps | COMPLETED |

## Key Findings

### Bidirectional Construction BLOCKED

The `bidirectional_temporal_box_seed` approach (plan v4) requires that ALL seed
elements be G-liftable for the consistency proof. This fails for H_theory elements:

- **Required**: `H(a) -> G(H(a))` to G-lift H_theory elements
- **Status**: NOT derivable in TM logic
- **Consequence**: `G_of_bidirectional_seed` has sorry at H_theory case
- **Resolution**: Archive as blocked, use separate-direction approach

### Working Approach: Separate-Direction Witnesses

The SuccChainFMCS construction achieves cross-direction coherence at CHAIN level:

**Sorry-Free Theorems**:
- `Succ.g_persistence`: g_content(M) ⊆ M' (SuccRelation.lean:69)
- `Succ_implies_h_content_reverse`: h_content(M') ⊆ M (SuccRelation.lean:102)
- `succ_chain_forward_G`: G(phi) at t implies phi at all t' > t (SuccChainFMCS.lean:449)
- `succ_chain_backward_H`: H(phi) at t implies phi at all t' < t (SuccChainFMCS.lean:513)
- `SuccChainFMCS`: FMCS structure with `forward_G` and `backward_H` (SuccChainFMCS.lean:1001)

**Known Gaps (F/P Existential Witnesses)**:
- `forward_F` and `backward_P` have sorries due to unbounded F/P nesting
- For sorry-free completeness, use `semantic_weak_completeness` (FMP path)

### Truth Lemma Connection

The truth lemma (SuccChainTruth.lean) uses the chain-level coherence:
- G/H forward direction: Uses sorry-free `succ_chain_forward_G_le`/`succ_chain_backward_H_le`
- G/H backward direction: Requires `forward_F`/`backward_P` which have sorries
- For completeness, only FORWARD direction is needed

## Files Modified

1. **Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean**
   - Added BLOCKED documentation to `bidirectional_temporal_box_seed`
   - Added BLOCKED documentation to `G_of_bidirectional_seed` (H_theory case)
   - Added BLOCKED documentation to `bidirectional_seed_consistent`

2. **Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean**
   - Added "Connection to Truth Lemma (Task #70 Phase 6)" documentation section

3. **ROADMAP.md**
   - Updated "Temporal Coherence Resolution" section
   - Archived bidirectional approach as dead end #5
   - Documented working separate-direction approach
   - Updated implementation status

## Verification

- **Build**: Passes successfully (938 jobs)
- **No new sorries introduced**: All modifications were documentation/comments
- **No new axioms introduced**: Zero axiom declarations added
- **Key theorems sorry-free**: Verified via lean_goal (goals_after: [])

## Next Steps

1. **For sorry-free completeness**: Use `semantic_weak_completeness` (FMP path)
2. **F/P gaps**: Could be addressed via formula-restricted completeness or fair-scheduling chains
3. **Class A sorries**: Modal duality via DNE (small, unblocks further work)

## References

- Report 10: `specs/070_explore_ultrafilter_construction/reports/10_blocker-analysis.md`
- Plan v5: `specs/070_explore_ultrafilter_construction/plans/05_separate-direction-witnesses.md`
- Previous summary: `specs/070_explore_ultrafilter_construction/summaries/06_bidirectional-blocked-summary.md`
