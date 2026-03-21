# Implementation Summary: Task 956 - Irreflexive G/H Refactoring

**Date**: 2026-03-09
**Plan**: implementation-003.md (supersedes implementation-002.md)
**Session**: sess_1773174380_a3f2b7
**Status**: Partial (Phases 1-7 complete, Phases 8-14 remaining)

## Overview

This session completed the core irreflexive G/H refactoring: switching temporal operators from
reflexive (<=) to irreflexive (<) semantics, removing T-axioms, adding derived reflexive
operators, and fully restructuring the soundness proofs for frame-class specific validity.

## Phase 1: Core Semantic Switch [COMPLETED]

Changed `truth_at` in `Theories/Bimodal/Semantics/Truth.lean`:
- `all_past φ`: `∀ s, s ≤ t → ...` became `∀ s, s < t → ...`
- `all_future φ`: `∀ s, t ≤ s → ...` became `∀ s, t < s → ...`
- Updated all time-shift preservation proofs

## Phase 2: Remove T-Axioms [COMPLETED]

- Deleted `temp_t_future` and `temp_t_past` from Axiom type
- Added `Axiom.isBase`, `isDenseCompatible`, `isDiscreteCompatible` predicates
- Removed T-axiom cases from SoundnessLemmas.lean (swap validity and local validity)
- Removed T-axiom cases from Soundness.lean

## Phase 3: Derived Reflexive Operators [COMPLETED]

- Added `Formula.weak_future` (G'φ := φ ∧ Gφ) to Formula.lean
- Added `Formula.weak_past` (H'φ := φ ∧ Hφ) to Formula.lean

## Phase 4: Fix Soundness Proofs [COMPLETED]

Major restructuring of soundness architecture:
- **Removed**: Universal `axiom_valid` and `soundness` theorems
- **Added**: `axiom_base_valid` (base axioms universally valid)
- **Added**: `axiom_valid_dense` (dense-compatible axioms valid on dense frames)
- **Added**: `axiom_valid_discrete` (discrete-compatible axioms valid on discrete frames)
- **Fixed**: `density_valid` now returns `valid_dense` and requires `DenselyOrdered D`
- **Fixed**: `discreteness_forward_valid` now returns `valid_discrete` and requires `SuccOrder D`
- **Fixed**: All temporal validity proofs for `<` semantics (`lt_trans`, `lt_trichotomy`)
- **SoundnessLemmas**: Removed combined theorem (no external consumers), fixed all swap proofs
- **DenseSoundness/DiscreteSoundness**: Updated for frame-class approach

## Phase 5: Fix Time-Shift Preservation [COMPLETED]

Already completed in Phase 1 (time-shift proofs updated as part of Truth.lean changes).

## Phase 6: Fix Canonical Frame [COMPLETED]

- Changed FMCS `forward_G` and `backward_H` from `≤` to `<`
- Removed `constantBFMCS` (not valid without T-axioms)
- Updated all FMCS helper lemmas
- Updated temporal coherence for strict inequalities
- DovetailingChain.lean left as orphaned (not in active import chain)

## Phase 7: Fix Bidirectional Fragment [COMPLETED]

**Key achievement**: Eliminated 2 sorries in linearity proofs using gamma-enrichment technique.

With irreflexive semantics, `G(alpha) ∈ W` does NOT imply `alpha ∈ W` (no T-axiom). This broke Case 1 of the linearity axiom application in both `canonical_forward_reachable_linear` and `canonical_backward_reachable_linear`.

**Solution**: Added separating formula `gamma ∈ M1 \ M2` to compound formulas:
- Old: `F(G(alpha) ∧ ¬beta)` and `F(G(beta) ∧ ¬alpha)`
- New: `F((G(alpha) ∧ gamma) ∧ ¬beta)` and `F((G(beta) ∧ ¬gamma) ∧ ¬alpha)`

Case 1 becomes impossible because `gamma ∧ ¬gamma` is inconsistent in any MCS. Cases 2/3 work via G/H-content propagation (unchanged). The same fix applies to both forward and backward variants.

**Modified**: `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`
- `canonical_forward_reachable_linear`: sorry eliminated
- `canonical_backward_reachable_linear`: sorry eliminated
- BidirectionalQuotient LinearOrder instance now sorry-free

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Semantics/Truth.lean` | Core ≤ to < switch (Phase 1) |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | Removed T-axioms, added frame-class predicates |
| `Theories/Bimodal/Syntax/Formula.lean` | Added weak_future, weak_past |
| `Theories/Bimodal/Metalogic/Soundness.lean` | Major restructuring (Phases 2,4) |
| `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` | Major restructuring (Phases 2,4) |
| `Theories/Bimodal/Metalogic/DenseSoundness.lean` | Frame-class approach |
| `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` | Frame-class approach |
| `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` | Removed decide_sound |
| `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` | ≤ → < in FMCS |
| `Theories/Bimodal/Metalogic/Bundle/Construction.lean` | Removed constantBFMCS |
| `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` | Eliminated 2 sorries (Phase 7) |

## Build Status

- Full `lake build` passes (758 jobs, 0 errors)
- BidirectionalReachable.lean: 0 sorries (was 2)
- Orphaned files (DovetailingChain, InteriorOperators, ChainFMCS, CanonicalCompleteness) still reference removed T-axiom constructors but are NOT in active import chain
- No new sorries introduced
- No new axioms introduced

## Handoff

Detailed handoff at: `handoffs/phase-7-handoff-20260309.md`
