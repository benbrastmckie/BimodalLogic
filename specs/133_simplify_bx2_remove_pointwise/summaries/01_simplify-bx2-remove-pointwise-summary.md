# Implementation Summary: Simplify BX2 -- Remove Pointwise Conjunct

- **Task**: 133 - Simplify BX2: remove pointwise conjunct, derive from BX2G
- **Status**: Implemented
- **Session**: sess_1778707221_475559
- **Date**: 2026-05-13

## Overview

Removed BX2/BX2' (`left_mono_until`/`left_mono_since`) as axiom constructors from the `Axiom` inductive type. Under open-guard semantics `(t,s)`, the pointwise conjunct `(phi->chi)` in BX2 is redundant since `G(phi->chi)` already covers the guard interval. All usages were rewritten to use BX2G/BX2H (`left_mono_until_G`/`left_mono_since_H`).

## Changes by Phase

### Phase 1: Rewrite All Direct BX2/BX2' Usages to BX2G/BX2H

**Files modified**: 2

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- Rewrote 5 functions:
  - `untl_left_mono_thm`: Simplified from 7 lines to 3 using `untl_left_mono_G`
  - `snce_left_mono_thm`: Simplified from 7 lines to 3 using `snce_left_mono_H`
  - `c4_hard_case_G_neg_delta`: Replaced `Axiom.left_mono_until` with `Axiom.left_mono_until_G`, removed pointwise derivation + conjunction
  - `c4'_hard_case_H_neg_delta`: Mirror replacement with `Axiom.left_mono_since_H`
  - Self-accumulation block (line ~1441): Replaced `Axiom.left_mono_until` with `Axiom.left_mono_until_G`, removed conjunction construction
  - Reordered `untl_left_mono_G`/`snce_left_mono_H` before `_thm` variants for forward reference
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- Rewrote 2 functions:
  - `untl_left_mono_deriv`: Simplified from 10 lines to 3 using `Axiom.left_mono_until_G`
  - `snce_left_mono_deriv`: Simplified from 7 lines to 3 using `Axiom.left_mono_since_H`

### Phase 2: Remove Constructors, Soundness Proofs, and Match Arms

**Files modified**: 4

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Removed 2 constructor declarations (`left_mono_until`, `left_mono_since`)
- `Theories/Bimodal/Metalogic/Soundness.lean` -- Removed 2 validity proof theorems (`left_mono_until_valid`, `left_mono_since_valid`) and 10 match arms
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` -- Removed 8 match arms across 4 `axiom_swap_valid` variants
- `Theories/Bimodal/ProofSystem/Substitution.lean` -- Removed 2 match arms

### Phase 3: Documentation Update and Final Verification

**Files modified**: 3

- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Updated axiom count 43->41, updated BX2/BX2' layer listing
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- Updated docstring comments referencing BX2
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- Updated ~6 comments referencing BX2/BX2'

## Metrics

| Metric | Before | After | Delta |
|--------|--------|-------|-------|
| Axiom constructors | 43 | 41 | -2 |
| Soundness proofs | N | N-2 | -2 |
| Match arms (Soundness) | N | N-10 | -10 |
| Match arms (SoundnessLemmas) | N | N-8 | -8 |
| Match arms (Substitution) | N | N-2 | -2 |
| Net lines | N | N-~120 | -~120 |

## Verification

- `lake build` passes with zero errors
- Zero references to `Axiom.left_mono_until` or `Axiom.left_mono_since` remain
- Zero new sorries introduced
- Zero custom axioms
- All 30+ call sites of `untl_left_mono_thm`/`snce_left_mono_thm` continue to compile unchanged
