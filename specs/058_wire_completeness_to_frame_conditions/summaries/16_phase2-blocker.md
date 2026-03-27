# Summary: Task #58 Phase 2 Blocker

**Task**: 58 - wire_completeness_to_frame_conditions
**Status**: BLOCKED
**Session**: sess_1774636946_5bdf38
**Date**: 2026-03-27

## Progress Summary

### Phase 1: COMPLETED
- Created sorry-free `neg_not_in_seed_when_in_brs` theorem
- Deleted false theorems (`neg_not_in_boundary_resolution_set`, `neg_not_in_constrained_successor_seed_restricted`)
- All four supporting lemmas verified (neg_not_in_g_content_when_F_in, neg_not_in_deferralDisjunctions, neg_not_in_p_step_blocking_restricted, brs_mutual_exclusion)

### Phase 2: BLOCKED
- `constrained_successor_seed_restricted_consistent` still has 1 sorry
- `augmented_seed_consistent` also has 1 sorry (depends on the same gap)

### Phase 3: BLOCKED (depends on Phase 2)
- Cannot wire to Completeness.lean until Phase 2 is resolved

## Technical Blocker

The proof of `constrained_successor_seed_restricted_consistent` requires showing:

**Given**: L subset seed with L derives falsum
**Goal**: False (derive contradiction with u's consistency)

### The Gap

The seed is: `g_content(u) + deferralDisjunctions(u) + p_step_blocking_restricted(phi, u) + BRS(phi, u)`

- Non-BRS elements are all in u
- BRS elements may or may not be in u
- For BRS elements not in u, their negations ARE in u (by DRM maximality)

The challenge: transforming a derivation `L derives bot` (where L may contain BRS elements not in u) into a derivation from u (to contradict u's consistency).

### Attempted Approaches

1. **Direct substitution**: Replace BRS elements with their deferral disjunctions from u
   - **Issue**: `psi or F(psi) in u` cannot directly replace `psi` in a derivation

2. **Deduction theorem elimination**: Use deduction theorem to eliminate BRS elements one by one
   - **Issue**: Gives `L' derives psi.neg`, not `L' derives bot`

3. **No contradictory pairs argument**: Show seed has no `{psi, psi.neg}` pairs
   - **Issue**: "No contradictory pairs implies consistent" is not generally true in modal logic without additional semantic arguments

4. **Cut-style transformation**: Show any `L derives bot` can be transformed to `L' derives bot` where `L' subset u`
   - **Issue**: This requires careful tracking of how BRS elements are used in the derivation

### Potential Path Forward

The proof likely requires one of:

1. **Semantic argument**: Use the fact that the seed is satisfiable (e.g., via canonical model construction) to derive consistency
2. **Proof-theoretic argument**: Develop a "cut-like" transformation lemma that handles the BRS case
3. **Alternative consistency definition**: Reformulate the problem using a different notion of consistency that's easier to prove

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`: Added proof structure with sorry, extensive comments documenting the gap
- `specs/058_wire_completeness_to_frame_conditions/plans/15_bypass-false-theorem.md`: Updated Phase 2 status to BLOCKED

## Build Status

- `lake build` succeeds
- 275 sorries in Theories/ (baseline count, not increased by this task)
- 3 axioms in Theories/ (unchanged)

## Recommendations

1. **Research**: Study how similar consistency proofs are done in the literature (e.g., Fitting's modal logic textbook)
2. **Alternative approach**: Consider building the canonical model first and using semantic consistency
3. **Decomposition**: This may require a separate task to develop the proof-theoretic machinery needed
