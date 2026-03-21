# Implementation Summary: Task #741

**Completed**: 2026-01-29
**Status**: PARTIAL (blocked by fundamental limitation)
**Duration**: ~2 hours

## Summary

Task 741 analyzed the witness extraction architecture required for the backward Truth Lemma
temporal cases (TruthLemma.lean lines 423, 441). The implementation discovered a fundamental
limitation: the proofs require an "omega-rule" that TM logic (and standard proof systems)
cannot express.

## Outcome

**Infrastructure Created**:
- New file `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean`
- H_completeness and G_completeness lemma signatures with partial proofs
- witness_from_not_H and witness_from_not_G corollary lemmas (complete proofs, inherit sorries)
- Comprehensive documentation of the omega-rule limitation

**NOT REQUIRED FOR COMPLETENESS**: The representation theorem only uses `truth_lemma_forward`.
The backward direction would provide "tightness" properties but is not needed for the main
completeness result.

## Key Finding: Omega-Rule Limitation

The backward Truth Lemma needs H-completeness:
```lean
(forall s < t, psi in mcs(s)) -> H psi in mcs(t)
```

This requires deriving `H psi` from infinitely many `psi` instances at different times.
Standard proof systems lack this "omega-rule". The IndexedMCSFamily coherence conditions
only provide the converse direction (`backward_H`).

## Files Modified

- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` - NEW: witness extraction infrastructure
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` - Import and improved documentation
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` - Updated references
- `specs/741_.../plans/implementation-001.md` - Updated with analysis

## Verification

- `lake build` completes successfully
- All existing functionality preserved
- New TemporalCompleteness.lean compiles with explicit sorries

## Future Options

If the backward Truth Lemma becomes needed:

1. **Extend IndexedMCSFamily**: Add H/G-completeness as axioms to the structure
2. **Construction-specific**: Prove for specific constructions (e.g., CoherentConstruction with finite bounds)
3. **Finite domain**: For bounded domains, the omega-rule becomes finite conjunction
4. **Semantic bridge**: May be possible via canonical model truth (needs careful circularity analysis)

## Notes

The witness extraction lemmas (`witness_from_not_H`, `witness_from_not_G`) have COMPLETE
proofs that correctly invoke the contrapositive of H/G-completeness. The sorries are
only in the underlying completeness lemmas themselves.

The task provides a clear architectural foundation if the backward Truth Lemma is
pursued in the future, while documenting why the direct approach is blocked.
