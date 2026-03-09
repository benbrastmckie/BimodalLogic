# Implementation Summary: Task 956 - Irreflexive G/H Refactoring

**Date**: 2026-03-09
**Plan**: implementation-003.md (supersedes implementation-002.md)
**Session**: sess_1773174380_a3f2b7
**Status**: Partial (Phases 1-5 complete, Phase 6 partial)

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

## Phase 6: Fix Canonical Frame [PARTIAL]

- Changed FMCS `forward_G` and `backward_H` from `≤` to `<`
- Removed `constantBFMCS` (not valid without T-axioms)
- Updated all FMCS helper lemmas
- **Remaining**: DovetailingChain.lean (16 T-axiom references + 2 ≤/< mismatches)

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

## Build Status

- All modified files compile individually
- Full `lake build` fails on DovetailingChain.lean (cascading to CanonicalFMCS, CanonicalFrame, TemporalCoherentConstruction)
- No new sorries introduced
- No new axioms introduced

## Handoff

Detailed handoff at: `handoffs/phase-6-handoff-20260309.md`
