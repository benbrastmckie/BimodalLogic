# Phase 4 Handoff - Reynolds Pipeline Architecture

## Immediate Next Action

Complete Phase 1: US expressive completeness over Prior structures. This requires extending `US_expressively_complete_over_Z` (Theorem.lean:357-363) to work over general discrete linear orders satisfying Prior-UZ/SZ semantically. The key mathematical content is Reynolds Theorem 5 (GHR94 Theorem 9.3.1 specialized to Prior structures).

## Current Proof State

### Completed
- `one_class_implies_very_good` (ShiftAndGlue.lean) - sorry-free
- `chronicle_is_good_direct` (ShiftAndGlue.lean) - sorry via no_gaps_discrete + Prior-UZ/SZ discharge
- `countermodel_discrete_reynolds` (Transfer.lean) - demonstrates full pipeline, sorry for packaging
- fc generalization of chronicleAsMonadicStructure, chronicle_temporal_truth, imp_iff_mcs

### Three Remaining Sorries in New Code
1. `ShiftAndGlue.lean:984` - semantic Prior-UZ discharge for chronicle_is_good_direct
2. `ShiftAndGlue.lean:990` - semantic Prior-SZ discharge for chronicle_is_good_direct
3. `Transfer.lean:866` - TaskFrame packaging (h_truth_corr) in countermodel_discrete_reynolds

### Fundamental Blocker
- `GoodStructures.lean:842` - `no_gaps_discrete` (pre-existing sorry, Reynolds Theorem 14)
- Requires Phase 1 (US expressive completeness over Prior structures)

## Key Decisions Made
1. Specialized `countermodel_discrete_reynolds` to `fc = FrameClass.Discrete` (only meaningful case)
2. Generalized chronicleAsMonadicStructure to generic fc to allow Discrete MCS
3. Used `mkSigFrom` / `mkAtomMap` for signature and atom map construction
4. The section property for atomMap_fwd/atomMap_rev works because mkAtomMap is Subtype.val

## Architecture for Phase 1 Continuation

The `separation_implies_expressiveness` (Theorem.lean:330) is Z-specific. Two approaches:
1. **Direct**: Rewrite the expressiveness proof for Prior structures by showing Stavi connectives U'(A,B) reduce to U(A,B) under Prior-UZ/SZ
2. **Transfer**: Use k-equivalence between the Prior structure and Z to transfer the Z-specific result

Approach 1 is cleaner. The key insight: in a Prior structure, `F(A) -> U(A, ¬A)` means the "first occurrence" of A is expressible via U. This makes U' redundant. The separation theorem then applies because U' and S' are eliminated.
