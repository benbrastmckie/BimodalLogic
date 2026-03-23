# Implementation Summary: Task 29 - Switch to Reflexive G/H Semantics

**Date**: 2026-03-22
**Session**: sess_1774167445_7672f2
**Plan**: plans/02_reflexive-semantics-revised.md

## Overview

Switched TM bimodal logic temporal semantics from strict (`<`) to reflexive (`<=`) for G and H operators. Under reflexive semantics, `G phi` means "phi at all times s >= t" (including now), making the T-axiom (`G phi -> phi`) definitionally valid.

## Phase Completion Status

| Phase | Description | Status |
|-------|-------------|--------|
| 0 | Enumeration and Pattern Catalog | COMPLETED (prior session) |
| 1 | Core Semantic Change | COMPLETED |
| 2 | FMCS Structure Update | COMPLETED |
| 3 | Soundness Proof Repairs | COMPLETED |
| 4 | Truth Lemma Adjustment | COMPLETED (subsumed by Phase 3) |
| 5 | Axiom Removal and Downstream Repair | PARTIAL |
| 6 | Additional Axiom Conversion | PARTIAL |
| 7 | Frame Class Simplification | COMPLETED |
| 8 | Documentation and Final Verification | COMPLETED |

## Changes Made

### Phase 1: Core Semantic Change
- `Theories/Bimodal/Semantics/Truth.lean`: Changed `s < t` to `s <= t` and `t < s` to `t <= s`
- `Theories/Bimodal/ProofSystem/Axioms.lean`: Added `temp_t_future` and `temp_t_past` T-axiom constructors, classified as `FrameClass.Base`

### Phase 2: FMCS Structure Update
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`: Changed `forward_G` from `t < t'` to `t <= t'`, `backward_H` from `t' < t` to `t' <= t`

### Phase 3: Soundness and Proof Repairs (14 files)
- `Theories/Bimodal/Metalogic/Soundness.lean`: Added T-axiom validity proofs, added match cases for `temp_t_future`/`temp_t_past` in all three soundness theorems, simplified seriality proofs (now trivial via T-axiom)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`: Updated for T-axiom cases
- `Theories/Bimodal/Metalogic/IRRSoundness.lean`: Updated for T-axiom cases
- All FMCS constructions updated to handle reflexive (=) case via T-axiom derivability:
  - `CanonicalFMCS.lean`: Case split on Preorder LE definition
  - `ChainFMCS.lean`: Case split on subtype LE
  - `FMCSTransfer.lean`: Case split on eq_or_lt_of_le
  - `DovetailedTimelineQuot.lean`, `DovetailedFMCS.lean`: Case split on eq_or_lt_of_le
- Truth lemma files updated (forward uses FMCS with <=, backward weakens <= to < for temporal_backward_G/H):
  - `ParametricTruthLemma.lean`
  - `CanonicalConstruction.lean`
  - `ParametricHistory.lean`

### Phase 5: Axiom Reflexivity (Partial)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`:
  - Added proven `canonicalR_reflexive` theorem (via T-axiom)
  - Added proven `canonicalR_past_reflexive` theorem
  - Deprecated `canonicalR_irreflexive` with clear warning
  - `canonicalR_irreflexive_axiom` retained temporarily (~54 downstream call sites)

### Phase 7: Frame Class Documentation
- `Theories/Bimodal/LogicVariants.lean`: Updated axiom counts and notes for reflexive semantics, documented three-variant collapse

## Remaining Work (Phases 5-6)

### Phase 5 Continuation: Remove canonicalR_irreflexive_axiom
- ~54 call sites across 13 files need replacement arguments
- Key challenge: `lt_of_canonicalR` relies on irreflexivity; needs redesign
- Most sites use pattern: derive contradiction from CanonicalR cycle; need antisymmetry-based arguments instead
- Estimated: 5+ hours additional work

### Phase 6 Continuation: Prove axioms via T-axiom
- `discreteImmediateSuccSeed_consistent_axiom`: g_content(M) subset M simplifies Case 2, but blocking formula consistency still non-trivial
- Other axioms assessed as semantics-independent

## Axiom Status (10 total)

| Axiom | Status |
|-------|--------|
| `canonicalR_irreflexive_axiom` | DEPRECATED (semantically FALSE, retained temporarily) |
| `discreteImmediateSuccSeed_consistent_axiom` | Unchanged (possibly provable via T-axiom) |
| `discreteImmediateSucc_covers_axiom` | Unchanged |
| `discrete_Icc_finite_axiom` | Unchanged (semantics-independent) |
| `succ_chain_fam_p_step` | Unchanged (semantics-independent) |
| `f_nesting_boundary` | Unchanged (semantics-independent) |
| `p_nesting_boundary` | Unchanged (semantics-independent) |
| `successor_deferral_seed_consistent_axiom` | Unchanged |
| `predecessor_deferral_seed_consistent_axiom` | Unchanged |
| `predecessor_f_step_axiom` | Unchanged |

## Build Status

- Full `lake build` passes (1044 jobs)
- No new sorries introduced
- No new axioms introduced (canonicalR_reflexive is a proven theorem)
- Existing axiom `canonicalR_irreflexive_axiom` is now semantically false but retained

## Key Insight

The semantic change from `<` to `<=` was straightforward (2 lines in Truth.lean), but the cascading effects required updating 14+ files. The critical pattern: every FMCS construction needed a case split to handle `t = t'` (reflexive case) using the T-axiom, while the truth lemma backward directions needed to weaken `<=` to `<` for `temporal_backward_G/H` (which still use strict ordering internally). The full axiom removal (Phase 5) is a separate, much larger effort.
