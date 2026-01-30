# Implementation Summary: Task #779

**Date**: 2026-01-30
**Status**: BLOCKED (Architectural Gap)
**Session**: sess_1769757568_82ba31

## Summary

Task 779 attempted to prove `weak_completeness` sorry-free via semantic model embedding
as proposed in research-002.md. Implementation revealed that the proposed approach faces
the same architectural gap as the original forward truth lemma.

## Files Created/Modified

### Created
- `Theories/Bimodal/Metalogic/FMP/SemanticTaskFrame.lean` - Frame and model construction
- `Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean` - Correspondence attempts with documented gaps

### Modified
- `Theories/Bimodal/Metalogic/FMP.lean` - Added import for SemanticTaskFrame

## Technical Findings

### The Proposed Approach

Research-002.md proposed:
1. Build a TaskModel from SemanticWorldStates (using Int as time domain)
2. Prove truth correspondence in this specific model
3. Bridge valid(phi) to semantic_weak_completeness hypothesis

### Why It Fails

The core issue is the mismatch between two notions of truth:

1. **Recursive truth (truth_at)**: Evaluates formulas recursively on structure
2. **Assignment truth (models)**: Directly checks the FiniteWorldState's assignment

These only coincide for MCS-derived world states. For arbitrary locally-consistent
world states, they can differ:

**Example**: For phi = psi -> chi, a world state could have:
- assignment(psi -> chi) = false
- assignment(psi) = false
- truth_at(psi) = false (from atom correspondence)
- truth_at(psi -> chi) = (false -> ...) = true

So truth_at evaluates to TRUE but assignment is FALSE.

### Root Cause

`semantic_truth_at_v2` is defined as:
```lean
∃ h_mem : psi ∈ closure phi, w.toFiniteWorldState.models psi h_mem
```

This is NOT recursively defined - it just checks the assignment. The assignment only
reflects provability for MCS-derived world states, not arbitrary locally-consistent ones.

### Architectural Implications

The sorry in `weak_completeness` is architectural and CANNOT be removed with any
approach that tries to bridge `valid` to `semantic_truth_at_v2` for ALL world states.

The fundamental issue is:
- `valid phi` quantifies over ALL models (including SemanticTaskModel)
- `semantic_weak_completeness` hypothesis requires truth at ALL SemanticWorldStates
- SemanticWorldStates include arbitrary locally-consistent states
- Assignment-based truth differs from recursive truth for non-MCS-derived states

## What Was Accomplished

1. **SemanticTaskFrame.lean**: Successfully built frame and model construction
   - SemanticTaskFrame with Int time domain and FiniteWorldState worlds
   - SemanticTaskModel with valuation from FiniteWorldState.models
   - worldStateToHistory mapping
   - All compiles without sorry

2. **SemanticTruthCorrespondence.lean**: Documented the gap
   - valid_at_semantic_model: Works (trivial instantiation)
   - truth_correspondence_atom: Works (atoms have full correspondence)
   - truth_correspondence_bot: Works (both sides False)
   - truth_at_semantic_implies_semantic_truth: SORRY - architectural gap
   - valid_implies_semantic_validity: SORRY (depends on above)

## Recommendations

1. **Do NOT attempt to bridge valid -> semantic_truth_at_v2** for arbitrary world states.
   The gap is architectural, not a proof difficulty.

2. **Use semantic_weak_completeness** for sorry-free completeness proofs. It works via
   contrapositive and only needs MCS-derived world states where correspondence holds.

3. **Consider alternative theorem statements** if universal validity is truly needed:
   - Change `valid` definition to use SemanticWorldState-based semantics
   - Or accept the architectural sorry as documenting a semantic gap

4. **The files created are still useful** for understanding the gap and may serve
   as documentation or starting points for alternative approaches.

## Related Documentation

- `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean`: Original gap documentation
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean`: Gap explanation in docstring
- `specs/779_archive_weak_completeness_for_sorry_free_metalogic/reports/research-002.md`: The (incorrect) research proposal
