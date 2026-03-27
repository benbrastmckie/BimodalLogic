# Implementation Summary: Task #58 - Greedy Extension Approach (v17)

**Completed**: 2026-03-27
**Duration**: ~2 hours
**Status**: BLOCKED at Phase 1

## Summary

Attempted the Greedy Extension approach for proving multi-BRS consistency. Phase 1 (compatibility lemma) is fundamentally blocked. Partial progress made with base case proof.

## Changes Made

### SuccChainFMCS.lean

Added `g_content_union_brs_consistent` theorem (lines 1591-1656):

**Base Case (PROVEN)**: When L contains no BRS elements (L ⊆ g_content(u)):
- Since g_content(u) ⊆ u via `g_content_subset_deferral_restricted_mcs`
- L ⊆ u directly contradicts u's consistency if L ⊢ ⊥
- This is a much simpler proof than the original G-wrapping approach

**Multi-BRS Case (BLOCKED)**:
- The greedy extension approach requires G-wrapping L_filt after deduction
- L_filt may contain other BRS elements chi where G(chi) ∉ u
- This fundamentally blocks the G-wrapping argument

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Added `g_content_union_brs_consistent` theorem with base case proof
  - Documented the blocking obstruction in comments

- `specs/058_wire_completeness_to_frame_conditions/plans/17_greedy-extension.md`
  - Updated Phase 1 status to [BLOCKED]

## Verification

- `lake build` succeeds with expected sorry warnings
- Base case proof is sorry-free
- Multi-BRS case has documented sorry with clear obstruction

## Technical Analysis

### Why Greedy Extension Fails

The core issue is the gap between F(psi) ∈ u and G(psi) ∈ u:

1. For psi ∈ BRS: F(psi) = ¬G(¬psi) ∈ u
2. This tells us G(¬psi) ∉ u
3. It does NOT tell us G(psi) ∈ u
4. These are independent claims in temporal logic

When we have L = L_gc ∪ {psi_1, ..., psi_k} ⊢ ⊥:
- Deduction theorem gives L_gc ∪ {psi_1, ..., psi_{k-1}} ⊢ ¬psi_k
- G-wrapping requires G(chi) ∈ u for ALL chi in the context
- For chi ∈ L_gc: Yes, G(chi) ∈ u by g_content definition
- For chi ∈ {psi_1, ..., psi_{k-1}} (BRS): G(chi) ∉ u in general

### Recommended Next Steps

1. **Phase 1B (Deferral Disjunction)**: Reformulate seed to use psi ∨ F(psi) instead of bare psi
   - Seed would be subset of u (consistency trivial)
   - Question: Does this break termination?

2. **Path C (Lindenbaum Restructuring)**: Build MCS directly without proving seed consistency a priori
   - Start with u (consistent)
   - Greedily add seed elements while maintaining consistency
   - More invasive but architecturally sound

## Notes

The single-element case (`single_brs_element_with_g_content_consistent`) works because when we remove the one BRS element psi from L, we have L_filt ⊆ g_content(u), and G(chi) ∈ u for all chi ∈ L_filt. This is the key difference from the multi-element case.

The blocking obstruction is documented in team research report 76 and confirmed by this implementation attempt.
