# Handoff: Phase 2 T-Axiom Removal

**Task**: 956 - Irreflexive G/H refactoring
**Phase**: 2 (Remove T-Axioms) - PARTIAL
**Session**: sess_1773174380_a3f2b7
**Date**: 2026-03-09

## Immediate Next Action

Fix `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`:
1. Remove the `| temp_t_future` and `| temp_t_past` match arms (lines ~496-501, ~898-899)
2. Fix `axiom_density_valid` (line ~853) and `axiom_discreteness_forward_valid` (line ~879) which use `le_refl t` where `t < t` is now needed

## Current State

### Completed
- **Phase 1 (Core Semantic Switch)**: DONE and builds
  - `Truth.lean`: `≤` changed to `<` in `truth_at` for `all_past`/`all_future`
  - Time-shift proofs updated: `sub_le_sub_right` -> `sub_lt_sub_right`, etc.
  - `lake build Bimodal.Semantics.Truth` passes

- **Phase 2 (Axiom Type Changes)**: PARTIAL
  - `Axioms.lean`: `temp_t_future` and `temp_t_past` constructors removed
  - `Axioms.lean`: Added `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible`, `Axiom.isBase` predicates
  - `lake build Bimodal.ProofSystem.Axioms` passes
  - Soundness files NOT yet updated (build fails)

### Files Modified
- `Theories/Bimodal/Semantics/Truth.lean` - Phase 1 changes
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Phase 2 changes

### Files Needing Changes
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - Remove T-axiom cases, fix density/discreteness
- `Theories/Bimodal/Metalogic/Soundness.lean` - Same

## Key Decisions Made

### 1. Irreflexive Semantics Design
- `all_past φ` now: `∀ s, s < t → truth_at ... s φ` (was `s ≤ t`)
- `all_future φ` now: `∀ s, t < s → truth_at ... s φ` (was `t ≤ s`)

### 2. T-Axiom Removal
- `temp_t_future` (G φ → φ) and `temp_t_past` (H φ → φ) removed from `Axiom` type
- These are no longer sound with irreflexive semantics (would need `t < t`)

### 3. Frame-Class Validity Architecture (CRITICAL)
With irreflexive semantics, `density` and `discreteness_forward` are NOT universally valid:
- **Density** (`Fφ → FFφ`): requires `DenselyOrdered D`
- **Discreteness** (`(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`): requires `SuccOrder D`
- **Neither is valid on all linear orders**

The `Axiom.isBase`, `Axiom.isDenseCompatible`, and `Axiom.isDiscreteCompatible` predicates
were added to support splitting the soundness theorem by frame class.

**Recommended approach**:
- `axiom_valid_base`: `Axiom.isBase h → ⊨ φ` (universally valid)
- `axiom_valid_dense`: `Axiom.isDenseCompatible h → valid_dense φ`
- `axiom_valid_discrete`: `Axiom.isDiscreteCompatible h → valid_discrete φ`
- Soundness splits into base + frame-specific versions
- The existing `DenseSoundness.lean` and `DiscreteSoundness.lean` provide the right structure

### 4. Density proof approach
For `density_valid`: Extract witness s > t from Fφ, use `DenselyOrdered.dense t s hts` to get u with t < u < s, then Fφ holds at u via witness s. **This proof is correct and complete** (was written in the session before being reverted with the broken Soundness.lean).

### 5. Discreteness proof approach
For `discreteness_forward_valid`: Use `Order.succ t` as witness. Need `Order.lt_succ_of_not_isMax` and `Order.le_of_lt_succ`. Non-maximality follows from F⊤ premise.

## What NOT to Try

1. **Do NOT try to prove density/discreteness as `⊨` (universally valid)** - impossible with irreflexive semantics
2. **Do NOT try to prove `axiom_valid_dense` for `discreteness_forward`** - it is NOT valid on dense frames (counterexample: on ℚ, Hφ at t and φ at t does NOT imply F(Hφ) because there are points between t and any u > t where φ need not hold)
3. **Do NOT put sorry in density/discreteness proofs** - the right approach is frame-class splitting

## Critical Context

1. The `SoundnessLemmas.lean` file has a parallel structure to `Soundness.lean` for temporal duality (swap validity). It also needs T-axiom cases removed and density/discreteness types fixed.
2. The `valid_implies_valid_dense` and `valid_implies_valid_discrete` helpers in `Validity.lean` provide coercion from universal to frame-class validity.
3. The downstream completeness proofs (Phases 6-10) only need dense soundness, not universal soundness.
4. Many files in `Bundle/` reference `temp_t_future`/`temp_t_past` and `canonicalR_reflexive` - these are Phases 6-7 concerns.

## References

- Plan: `specs/956_construct_d_as_translation_group_from_syntax/plans/implementation-003.md`
- Research: `specs/956_construct_d_as_translation_group_from_syntax/reports/research-016.md`
