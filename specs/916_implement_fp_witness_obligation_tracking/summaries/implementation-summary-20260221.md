# Implementation Summary: Task #916

**Plan**: v005 (derivation surgery approach)
**Date**: 2026-02-21
**Session**: sess_1771702017_68f2f6
**Duration**: ~2 hours
**Outcome**: PARTIAL - Phase 1 completed, Phases 2-5 blocked by counterexample

## Overview

This implementation attempted to close the forward_F and backward_P sorries in
DovetailingChain.lean using the derivation surgery approach from research-007.
Phase 1 (base structural facts) was completed successfully, proving 6 new lemmas.
Phase 2 was blocked when mathematical analysis revealed that the FPreservingSeed
consistency conjecture is FALSE, invalidating the derivation surgery approach.

## Changes Made

### Phase 1: Base Structural Facts (COMPLETED)

Added 6 derivation-theoretic lemmas to DovetailingChain.lean, establishing
foundational facts about the relationship between GContent derivations,
G-formulas, and F-formulas in maximal consistent sets:

1. **`GContent_derives_neg_implies_G_neg_mem`**: If GContent(M) derives neg(alpha)
   via some finite list, then G(neg(alpha)) is in M. Uses G-lifting
   (generalized_temporal_k) and MCS closure.

2. **`FContent_blocks_GContent_derives_neg`**: If F(alpha) is in an MCS M, then
   GContent(M) does not derive neg(alpha). Contrapositive of (1) using MCS
   consistency.

3. **`F_in_MCS_implies_G_neg_not_theorem`**: If F(alpha) is in some MCS M, then
   G(neg(alpha)) is not a theorem. Uses theorem_in_mcs and MCS consistency.

4. **`P_in_MCS_implies_H_neg_not_theorem`**: Past symmetric version of (3).

5. **`HContent_derives_neg_implies_H_neg_mem`**: Past analog of (1), using
   generalized_past_k.

6. **`PContent_blocks_HContent_derives_neg`**: Past analog of (2).

All lemmas are sorry-free and depend only on standard axioms (propext,
Classical.choice, Quot.sound, Lean compiler axioms).

### Phase 2: FPreservingSeed Conjecture REFUTED

Mathematical analysis during Phase 2 revealed a concrete counterexample to
the FPreservingSeed consistency conjecture:

**Conjecture**: If M is MCS and F(psi) in M, then {psi} union GContent(M) union
FContent(M) is SetConsistent.

**Counterexample**:
- Integer time model: q false at time 0, q true at time 1, r true only at time 0
- At time 0, the MCS M has:
  - F(q) holds (q true at 1)
  - neg(q) holds (q false at 0)
  - F(r) holds (r true at 0)
  - G(F(r) -> neg(q)) holds (vacuously true at all future times since F(r) fails after time 0)
- Therefore:
  - (F(r) -> neg(q)) is in GContent(M) (since G(F(r) -> neg(q)) in M)
  - F(r) is in FContent(M) (since F(r) in M)
- The seed {q, (F(r) -> neg(q)), F(r)} derives bot:
  1. F(r) + (F(r) -> neg(q)) gives neg(q) by modus ponens
  2. neg(q) + q gives bot
- But {q} union GContent(M) is consistent (forward_temporal_witness_seed_consistent)

**Root cause**: FContent formulas can interact with GContent implications via
modus ponens to derive neg(psi), even when GContent alone cannot. The "step 12
gap" identified in research-007 Section 5.2 is unfillable because it reflects
genuine mathematical falsity, not a technical gap.

**Implication**: The derivation surgery approach (v005) is fundamentally blocked.
Phases 3-5 cannot proceed. The forward_F and backward_P sorries remain as
technical debt requiring a different approach.

## Files Modified

- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` - Added 6 structural lemmas

## Verification

- `lake build` succeeds (1001 jobs, no new errors)
- All 6 new lemmas type-check without sorry
- `#print axioms` shows only standard axioms for all new lemmas
- `forward_temporal_witness_seed_consistent` verified unchanged
- No new sorries introduced
- No new axioms introduced

## Sorry Inventory

### Pre-existing (unchanged)
- `buildDovetailingChainFamily_forward_F` (line ~1738) - forward_F sorry remains
- `buildDovetailingChainFamily_backward_P` (line ~1745) - backward_P sorry remains

### New
- None

## Mathematical Analysis

### What Was Proved
- Routes 1 and 3 of the derivation surgery argument are definitively blocked
  (Phase 1 lemmas)
- G-lifting works correctly for GContent-only derivations
- F-formulas in an MCS prevent GContent from deriving neg(alpha)

### What Was Refuted
- The FPreservingSeed conjecture (full seed consistency) is mathematically false
- Route 2 of the derivation surgery CAN succeed: FContent formulas interact
  with GContent implications via modus ponens
- The "F-formulas add no derivation power" claim from research-007 is incorrect
  for the neg(psi) direction

### Why Prior Approaches Failed
| Plan | Approach | Failure |
|------|----------|---------|
| v001 | Initial | Underspecified |
| v002 | Direct proof | F-persistence not derivable (F -> GF invalid) |
| v003 | Flat chain with witness | F(psi) killed before processing step |
| v004 | Omega^2 directed limit | Generalized consistency lemma is FALSE |
| v005 | Derivation surgery | FPreservingSeed conjecture is FALSE |

### Remaining Paths
The forward_F and backward_P proofs likely require one of:
1. **Refined seed approach**: Instead of adding ALL of FContent, add only a
   carefully chosen subset that doesn't interact with GContent implications.
   For example, only include F-formulas whose negations are not derivable
   from GContent.
2. **Alternative chain construction**: Use a different chain topology (e.g.,
   tree-based or saturation-based) where F-persistence is guaranteed by
   construction rather than by seed inclusion.
3. **Saturation approach**: Build a fully saturated model where all temporal
   obligations are handled simultaneously, avoiding the incremental chain.

## Notes

The Phase 1 lemmas are independently valuable and should be preserved. They
establish fundamental derivation-theoretic properties of GContent and HContent
that will be useful regardless of which approach is eventually taken for
forward_F and backward_P.

The counterexample to the FPreservingSeed conjecture should be formally verified
in Lean if a future approach depends on understanding exactly why this fails.
