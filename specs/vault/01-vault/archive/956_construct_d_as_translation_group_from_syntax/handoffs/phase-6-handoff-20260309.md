# Handoff: Phase 6 Canonical Frame (Partial) + Phases 7-14

**Task**: 956 - Irreflexive G/H refactoring
**Phase**: 6 (Fix Canonical Frame) - PARTIAL
**Session**: sess_1773174380_a3f2b7
**Date**: 2026-03-09 (iteration 2)

## Immediate Next Action

Fix `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`:
- Remove all references to `Axiom.temp_t_future` and `Axiom.temp_t_past` (16 occurrences)
- Update `≤` to `<` for temporal relation comparisons (2 occurrences at lines ~1804, ~1822)
- These T-axiom references were used for `canonicalR_reflexive` proofs; need to restructure

## Current State

### Completed (Phases 1-5)
- **Phase 1 (Core Semantic Switch)**: `Truth.lean` uses `<` instead of `≤`
- **Phase 2 (T-Axiom Removal)**: `temp_t_future` and `temp_t_past` removed from Axiom type
- **Phase 3 (Derived Operators)**: `weak_future` and `weak_past` added to Formula.lean
- **Phase 4 (Soundness Proofs)**: Complete restructuring:
  - Removed universal `axiom_valid` and `soundness` theorems (no longer valid)
  - Added `axiom_base_valid` (base axioms universally valid)
  - Added `axiom_valid_dense` (dense-compatible axioms valid on dense frames)
  - Added `axiom_valid_discrete` (discrete-compatible axioms valid on discrete frames)
  - Fixed `density_valid` to require `DenselyOrdered D`
  - Fixed `discreteness_forward_valid` to require `SuccOrder D`
  - Fixed `temp_4_valid`, `temp_l_valid`, `temp_linearity_valid` for `<` semantics
  - SoundnessLemmas: removed combined theorem (no external consumers), fixed swap proofs
  - DenseSoundness/DiscreteSoundness: updated to use new frame-class validators
  - Correctness.lean: removed `decide_sound` (needs frame-class specific version)
- **Phase 5 (Time-Shift)**: Already done in Phase 1

### Partially Completed (Phase 6)
- `FMCSDef.lean`: `forward_G` and `backward_H` changed from `≤` to `<`
- `FMCSDef.lean`: All helper lemmas updated
- `Construction.lean`: `constantBFMCS` removed (not valid without T-axioms)
- **Remaining**: DovetailingChain.lean and downstream files

### Build Status
- Files that compile: Soundness, SoundnessLemmas, DenseSoundness, DiscreteSoundness,
  Correctness, FMCSDef, Construction, Truth, Axioms, Formula, Validity
- Files that DON'T compile: DovetailingChain.lean (16 temp_t errors + 2 ≤/< mismatches)
  - Cascading failures: CanonicalFMCS, CanonicalFrame, TemporalCoherentConstruction

## Key Decisions Made

### 1. Soundness Architecture (CRITICAL)
- Universal `axiom_valid` removed - density/discreteness are frame-class specific
- No universal `soundness` theorem exists anymore
- Frame-class soundness: `axiom_valid_dense` and `axiom_valid_discrete`
- SoundnessLemmas combined theorem removed (no external consumers)
- The `axiom_swap_valid` in SoundnessLemmas requires `DenselyOrdered D` and `isDenseCompatible`

### 2. FMCS Coherence Conditions
- `forward_G` now uses `t < t'` instead of `t ≤ t'`
- `backward_H` now uses `t' < t` instead of `t' ≤ t`
- `constantBFMCS` removed - not constructible without T-axioms

### 3. Decidability Module
- `decide_sound` removed - needs frame-class specific version (Phase 12 concern)
- `validity_decidable` and `decide_result_exclusive` still compile

### 4. DovetailingChain Approach
- The plan says DovetailingChain should be marked for archival (Phase 11)
- The density completeness path uses the canonical quotient approach, NOT DovetailingChain
- Quick fix: remove T-axiom references and update `≤` → `<`
- Or: exclude from build if not needed by density path

## What NOT to Try

1. **Do NOT try to restore `constantBFMCS`** - it's fundamentally incompatible with irreflexive semantics
2. **Do NOT try to create a universal `soundness` theorem** - density and discreteness are incompatible
3. **Do NOT introduce sorry anywhere** - zero-debt policy
4. **Do NOT try to prove `axiom_swap_valid` without DenselyOrdered** for density/discreteness cases

## Critical Context

1. The `canonicalR_reflexive` theorem in CanonicalFrame.lean will need to be deleted (Phase 6 task)
2. BidirectionalReachable.lean uses `canonicalR_reflexive` for `le_refl` in Preorder instance
3. DenseQuotient.lean uses both `canonicalR_reflexive` and `canonicalR_past_reflexive`
4. CanonicalChain.lean uses them extensively (12 occurrences)
5. CanonicalFMCS.lean uses `canonicalR_reflexive` for Preorder instance
6. The density completeness path (Phases 8-10) only needs DenseQuotient, not DovetailingChain

## Files Modified in This Iteration

- `Theories/Bimodal/Metalogic/Soundness.lean` - Major restructuring
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Major restructuring
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` - Updated for frame-class approach
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - Updated for frame-class approach
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Removed `decide_sound`
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - `≤` → `<` in FMCS
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Removed `constantBFMCS`
- `Theories/Bimodal/Syntax/Formula.lean` - Added `weak_future`, `weak_past`

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-003.md`
- Previous handoff: `specs/956_construct_d_as_translation_group_from_syntax/handoffs/phase-2-handoff-20260309.md`
