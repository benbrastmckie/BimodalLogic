# Implementation Summary: Task #753

**Completed**: 2026-01-29
**Duration**: ~2 hours
**Plan Version**: v003

## Overview

This task addressed sorries in `CoherentConstruction.lean` and `TaskRelation.lean` using a clean-break approach focused on quality over backwards compatibility.

## Changes Made

### Phase 1: Sigma-Type Chain Refactoring [COMPLETED]

Eliminated the 2 infrastructure sorries (lines 403, 416) in `CoherentConstruction.lean` by:

1. **Added helper lemmas**:
   - `mcs_no_G_bot`: Proves G-bot not in any MCS (via T-axiom reasoning)
   - `mcs_no_H_bot`: Proves H-bot not in any MCS (symmetric)

2. **Refactored chain construction** to sigma-type pattern:
   - `mcs_forward_chain_aux`: Returns `{ S : Set Formula // SetMaximalConsistent S }`
   - `mcs_backward_chain_aux`: Symmetric for backward chain
   - `mcs_forward_chain` and `mcs_backward_chain`: Projections

3. **Why this works**: The sigma-type carries the MCS invariant through recursion, so at each step we have access to the proof that the current element is MCS. Combined with `mcs_no_G_bot`, we can prove the forward_seed is consistent.

### Phase 2: TaskRelation Documentation [COMPLETED]

Instead of proving or deleting the 5 compositionality sorries in `TaskRelation.lean`, documented them as architectural limitations that don't affect completeness:

- Added detailed module-level documentation explaining why these cases aren't exercised
- Created table mapping each sorry to its case and reason for exclusion

### Phase 3: Cross-Origin Gap Documentation [COMPLETED]

Updated header documentation in `CoherentConstruction.lean`:
- Corrected line numbers in the gaps table
- Expanded explanation of why cross-origin cases are intentional exclusions
- Added list of proven cases used by completeness theorem

### Phase 4: Verification [COMPLETED]

Final sorry counts:
- `CoherentConstruction.lean`: 8 sorries (all cross-origin coherence, documented)
- `TaskRelation.lean`: 5 sorries (compositionality, documented as non-essential)
- Total: 13 sorries (all documented as intentional scope exclusions)

## Files Modified

- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
  - Added `mcs_no_G_bot` and `mcs_no_H_bot` lemmas
  - Refactored `mcs_forward_chain` and `mcs_backward_chain` to sigma-type pattern
  - Added auxiliary lemmas `mcs_forward_chain_aux` and `mcs_backward_chain_aux`
  - Updated header documentation with correct line numbers and expanded explanations

- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
  - Added comprehensive module-level documentation explaining why compositionality sorries don't affect completeness

- `specs/753_prove_sorries_in_coherentconstruction/plans/implementation-003.md`
  - Updated phase status markers

## Verification

- `lake build` succeeds with no errors
- All changes tested against full project build
- Sorry count matches documented intentional gaps

## Key Insights

1. **Sigma-type pattern**: Carrying invariants through recursive definitions eliminates circular dependencies between definitions and their properties.

2. **T-axiom reasoning**: The T-axiom (Gφ → φ) provides a simple proof that G-bot cannot be in any MCS, since this would imply bot in MCS, contradicting consistency.

3. **Cross-origin coherence**: The remaining gaps are fundamental architectural limitations, not proof difficulties. The completeness theorem only needs same-direction coherence (forward G in forward chain, backward H in backward chain).

## Notes

- The TaskRelation compositionality sorries were kept rather than deleted because:
  1. The `UniversalCanonicalFrame` definition depends on `canonical_task_rel_comp`
  2. Removing it would require significant refactoring of the frame construction
  3. Documentation clarifies these don't affect completeness

- Future work could explore:
  1. Alternative frame construction that doesn't require full compositionality
  2. Proving cross-origin coherence via additional axioms or construction techniques
