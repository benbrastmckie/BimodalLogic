# Phase 1 Results: Dead Code Cleanup, Boneyard Archival, and ROADMAP Update

**Task**: 83 - Close Restricted Coherence Sorries
**Phase**: 1 of 6
**Status**: COMPLETED
**Date**: 2026-04-03

## Actions Taken

### Boneyard Archival (T-Axiom Dependent Code)

Created `Theories/Bimodal/Boneyard/TAxiomDependentCode/` with:

1. **TargetedChainArchive.lean**: 6 functions archived from TargetedChain.lean
   - `targeted_forward_chain_forward_G` (T-axiom sorry at line 255)
   - `targeted_backward_chain_backward_H` (T-axiom sorry at line 359)
   - `targeted_fam_forward_G` (T-axiom sorry at line 491)
   - `targeted_fam_backward_H` (T-axiom sorry at line 525)
   - `TargetedFMCS` (depended on above)
   - `TargetedFMCS_at_zero` (depended on above)

2. **CanonicalConstructionArchive.lean**: 1 definition archived from CanonicalConstruction.lean
   - `restricted_tc_family_to_fmcs` (forward_G/backward_H fields had sorry)

3. **TruthPreservationArchive.lean**: 4 functions archived from TruthPreservation.lean
   - `mcs_all_future_closure` (assumed T-axiom, marked DEPRECATED)
   - `mcs_all_past_closure` (assumed T-axiom, marked DEPRECATED)
   - `filtration_all_future_forward` (depended on mcs_all_future_closure)
   - `filtration_all_past_forward` (depended on mcs_all_past_closure)

4. **README.md**: Explains archival reason and lists all archived functions

### Deletions

5. **FALSE theorem deleted**: `augmented_seed_consistent` from SuccChainFMCS.lean
   - Documented counterexample existed; never referenced by active code

6. **Ghost directories deleted**:
   - `Metalogic/Canonical/` (contained only stale README about reflexive semantics)
   - `Metalogic/Soundness/` (contained only README pointing to top-level files)

7. **Deprecated aliases removed**: `CanonicalR` and `CanonicalR_past` from CanonicalFrame.lean

### Comment Cleanup

8. **Tombstone comments cleaned** in UltrafilterChain.lean:
   - R_G_refl DELETED block -> single-line note
   - R_H_refl DELETED block -> single-line note
   - temporal_witness_g_persistence DELETED block -> single-line note

9. **Stale reflexive semantics comments updated**:
   - FrameConditions/FrameClass.lean: "reflexive" -> "strict" semantics description
   - FrameConditions/Soundness.lean: "reflexive" -> "strict" semantics description
   - TemporalCoherence.lean: "weak inequality" -> "strict inequality" (2 locations)
   - SuccChainFMCS.lean: Updated g_content_subset docstring to note T-axiom dependency

10. **Typst marked**: `typst/chapters/06-notes.typ` marked with TODO for strict semantics rewrite

### ROADMAP Update

11. **Sorry census revised**: Updated from "~33" to "~220" with detailed per-file breakdown
12. **Critical path updated**: Described 3-blocker structure (derived theorems, seed redesign, truth lemma)
13. **Task 81 section expanded**: Documented strict semantics migration achievements
14. **Priority ordering updated**: Reflects current task 83 phase structure

## Skipped Items (With Justification)

- **SuccChainFMCS.lean sorry sites** (lines 1244, 4009, 4276, 4419): NOT archived because
  these are sorry calls INSIDE actively-used functions (`g_content_subset_deferral_restricted_mcs`,
  `pastDeferralDisjunctions_subset_deferral_restricted_mcs`, etc.). They are T-axiom sorry
  sites but the enclosing functions have downstream consumers. Will be addressed in Phase 3
  (seed redesign).

- **`constrained_successor_seed_restricted_consistent`** (FALSE theorem): NOT deleted because
  it is referenced at lines 2524, 2535, 2546 by downstream code. Will be restructured in Phase 3.

## Verification

- `lake build`: Passes (940 jobs, 0 errors)
- `temp_t_future|temp_t_past` grep: Zero hits in active .lean code (all hits are in Boneyard,
  comments, typst docs, or inside sorry annotations in SuccChainFMCS.lean)
- Sorry count: 220 in .lean files (excluding Boneyard); was ~224 before archival
- Axiom count: 3 (unchanged)
