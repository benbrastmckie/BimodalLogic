# Implementation Summary: Task #55

**Task**: Prove SuccChain Temporal Coherence Directly
**Status**: PARTIAL (Phases 1-2 complete, Phase 3 blocked, Phase 4 complete)
**Date**: 2026-03-24
**Session**: sess_1774403188_59d127 (Phase 3-4 work)

## Summary

This task attempted to prove temporal coherence for SuccChain-based FMCS without relying on the mathematically false `f_nesting_is_bounded` theorem. The core blocking issue was identified and documented, with deprecated annotations added to the affected theorems.

## Phase Status

| Phase | Status | Notes |
|-------|--------|-------|
| Phase 1: Simplify Resolving Seed | PARTIAL | Completed in prior session |
| Phase 2: Delete False Theorem | COMPLETED | Completed in prior session |
| Phase 3: Prove boxClassFamilies_temporally_coherent | BLOCKED | Mathematically blocked |
| Phase 4: Cleanup and Deprecation | COMPLETED | Documentation and deprecation added |

## Key Finding: Mathematical Blocker

The theorem `f_nesting_is_bounded` (and symmetric `p_nesting_is_bounded`) is **mathematically FALSE** for arbitrary SetMaximalConsistent:

**Counterexample**: The set `{F^n(p) | n in Nat}` is consistent (satisfiable in a frame with unbounded future). By Lindenbaum's lemma, it extends to an MCS containing all F-iterations with no boundary.

This blocks the entire proof chain:
- `f_nesting_is_bounded` (sorry, deprecated)
- `f_nesting_boundary` (depends on above, deprecated)
- `succ_chain_forward_F` (uses f_nesting_boundary)
- `SuccChainTemporalCoherent.forward_F` (uses succ_chain_forward_F)
- `boxClassFamilies_temporally_coherent` (delegates to above)
- `construct_bfmcs` (uses temporal coherence)

## Changes Made (This Session)

### Build Fixes
- Fixed `simp only [shifted_fmcs]` usage (line 1688)
- Fixed `ring_nf` -> `simp only [Int.sub_self]` (line 1770)
- Fixed docstring placement before `set_option` (lines 1806-1809)
- Fixed `rfl` proofs for `succ_chain_fam_zero` (lines 1614, 1628)

### Deprecation Annotations
Added `@[deprecated]` to:
- `f_nesting_is_bounded` -> `f_nesting_is_bounded_restricted`
- `f_nesting_boundary` -> `f_nesting_boundary_restricted`
- `p_nesting_is_bounded` -> `p_nesting_is_bounded_restricted`
- `p_nesting_boundary` -> `p_nesting_boundary_restricted`

### Documentation
Updated SuccChainFMCS.lean module header with:
- Known Limitations section explaining the blocker
- Path Forward section with three resolution options

## Prior Session Accomplishments

### Phase 1: Simplify Resolving Seed and Consistency [PARTIAL]

**Changes Made**:
1. Simplified `resolving_successor_seed` definition:
   - Before: `{phi} ∪ temporal_box_seed M ∪ deferralDisjunctions M ∪ p_step_blocking_formulas M`
   - After: `{phi} ∪ temporal_box_seed M`

2. Simplified `resolving_successor_seed_consistent`:
   - Before: Complex G-lift argument with sorry (70+ lines)
   - After: Direct delegation to `temporal_theory_witness_consistent` (1 line, sorry-free)

### Phase 2: Delete False Theorem and Unused Code [COMPLETED]

**Deletions**:
1. `temporal_witness_f_step_phi`: Trivial theorem, not used
2. `temporal_witness_f_step_general`: **Mathematically FALSE**

## Path Forward (Three Options)

1. **Fair-scheduling chain**: Construct a chain that enumerates and forces each F-obligation in turn (standard completeness technique)

2. **Bundle-level coherence**: Weaken temporal coherence to allow phi to appear in ANY family at a future time, not necessarily the SAME family

3. **Restricted completeness**: Use RestrictedMCS from the target formula's closure, where boundedness IS provable

## Verification Results

- Build: PASSES (927 jobs)
- Sorries in UltrafilterChain.lean: 0 (actual code)
- Sorries in SuccChainFMCS.lean: 9 (2 in deprecated theorems, 7 in restricted chain section)
- New axioms introduced: 0
- construct_bfmcs depends on sorryAx: YES (via temporal coherence chain)

## Files Modified (This Session)

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
  - Lines 1614, 1628: Fixed rfl proofs
  - Line 1688: Fixed shifted_fmcs simp
  - Line 1770: Fixed Int.sub_self
  - Lines 1806-1809: Fixed docstring placement

- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Module header: Added Known Limitations and Path Forward sections
  - Lines 755-759: Added deprecation to f_nesting_boundary
  - Lines 983-991: Added deprecation to p_nesting_boundary

## Recommendations

1. **Follow-up task**: Implement Option 1 (fair-scheduling chain) or Option 3 (restricted completeness) to fully resolve the temporal coherence proof

2. **Migration**: Any code using `f_nesting_is_bounded` or `p_nesting_is_bounded` should migrate to the `_restricted` variants with explicit RestrictedMCS

3. **Research**: Consider whether bundle-level coherence (Option 2) is sufficient for the intended use cases, as it may be simpler to implement

## Files Modified

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`:
  - Lines 1436-1507: Simplified resolving seed definitions
  - Lines 1542-1598: Deleted false/unused theorems
  - Various: Fixed pre-existing syntax errors throughout file

## Verification

- **Sorries in UltrafilterChain.lean**: 0 (down from 2)
- **Build status**: 10 pre-existing errors remain
- **Phase 1-2 region compiles**: Yes (no errors in lines 1436-1600)

## Recommendations

1. **Create separate task** to fix pre-existing errors in UltrafilterChain.lean (H-lift proofs, construct_bfmcs)
2. **Phases 3-4** (boxClassFamilies_temporally_coherent, deprecation) cannot proceed until blockers fixed
3. The SuccChainFMCS-based approach in SuccChainFMCS.lean still has sorries in `f_nesting_is_bounded` - that's the root cause of the temporal coherence issue

## Key Insight

The minimal seed approach (`{phi} ∪ temporal_box_seed M`) is correct for the per-obligation architecture. The extended seed approach failed because `deferralDisjunctions` are NOT G-liftable, making the consistency proof impossible. By using the minimal seed, we delegate to `temporal_theory_witness_consistent` which already handles the G-lift argument correctly.
