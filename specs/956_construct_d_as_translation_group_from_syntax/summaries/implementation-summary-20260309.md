# Implementation Summary: Task 956 - Irreflexive G/H Refactoring

**Date**: 2026-03-09
**Plan**: implementation-003.md (supersedes implementation-002.md)
**Session**: sess_1773174380_a3f2b7
**Status**: Partial (Phase 1 complete, Phase 2 partial)

## Overview

This session began the irreflexive G/H refactoring: switching temporal operators from
reflexive (<=) to irreflexive (<) semantics. This resolves the T-axiom obstruction that
blocked the Phase 6 density proof in implementation-002.md.

## Phase 1: Core Semantic Switch [COMPLETED]

Changed `truth_at` in `Theories/Bimodal/Semantics/Truth.lean`:

- `all_past φ`: `∀ s, s ≤ t → ...` became `∀ s, s < t → ...`
- `all_future φ`: `∀ s, t ≤ s → ...` became `∀ s, t < s → ...`
- Updated all time-shift preservation proofs
- Updated all docstrings
- Build: `lake build Bimodal.Semantics.Truth` passes

## Phase 2: Remove T-Axioms [PARTIAL]

Removed T-axiom constructors from `Theories/Bimodal/ProofSystem/Axioms.lean`:
- Deleted `temp_t_future` (G phi -> phi) constructor
- Deleted `temp_t_past` (H phi -> phi) constructor
- Added frame-class predicates: `Axiom.isBase`, `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible`
- Build: `lake build Bimodal.ProofSystem.Axioms` passes
- **Remaining**: SoundnessLemmas.lean and Soundness.lean need updating

## Architectural Discovery: Frame-Class Validity

With irreflexive semantics, density and discreteness axioms are NOT universally valid:
- **density** (`Fφ → FFφ`): valid only on `DenselyOrdered` frames
- **discreteness_forward** (`(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`): valid only on `SuccOrder` frames

This requires splitting the soundness theorem by frame class. The predicates
`Axiom.isBase`, `isDenseCompatible`, `isDiscreteCompatible` were added to support this.

## Files Modified

| File | Changes |
|------|---------|
| `Theories/Bimodal/Semantics/Truth.lean` | Core <= to < switch, time-shift proofs |
| `Theories/Bimodal/ProofSystem/Axioms.lean` | Removed T-axioms, added frame-class predicates |

## Handoff

Detailed handoff at: `handoffs/phase-2-handoff-20260309.md`

## Previous Session Context

The previous implementation-002 session (also dated 2026-03-09, session sess_1773071904_5fdc8e)
completed phases 1-5 and 9-10 of that plan (adding DN/DF axioms, soundness for reflexive
semantics, partial DenseQuotient). That work is now being superseded by the irreflexive
refactoring in implementation-003.
