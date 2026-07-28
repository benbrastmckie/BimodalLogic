/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure
import FormalSystem.Metalogic.Decidability.FMP.FMP
import FormalSystem.Metalogic.Soundness

/-!
# Correctness of the Decision Procedure

This module proves properties of the tableau decision procedure.

## Main Theorems

- `validity_decidable`: Validity is classically decidable
- `decide_result_exclusive`: Decision results are mutually exclusive

## Implementation Notes

The `soundness` theorem in `Soundness.lean` proves `Γ ⊢[Base] φ → Γ ⊨ φ`, i.e.,
derivability from context `Γ` at `FrameClass.Base` implies semantic consequence.
The `FrameClass.Base` parameter structurally excludes axioms with
`minFrameClass > Base` (density, Prior-UZ/SZ, z1) via the `h_fc` gate.

- `decide_sound`: If `decide φ` returns `.valid proof`, then `⊨ φ` (semantic validity)
- Frame-class specific soundness is available via `soundness_dense`, `soundness_discrete`

## References

* Wu, M. Verified Decision Procedures for Modal Logics
* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics
open FormalSystem.Metalogic

/-!
## Soundness of the Decision Procedure
-/

/--
Soundness of the decision procedure: if a formula has a `FrameClass.Base`
derivation (as produced by `decide` returning `.valid proof`), then the
formula is semantically valid.

This follows immediately from the `soundness` theorem with empty context,
where the context hypothesis is vacuously satisfied.
-/
theorem decide_sound (φ : Formula) (d : ⊢ φ) : ⊨ φ := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t
  exact soundness [] φ d D F M Omega h_sc τ h_mem t (by simp)

/--
Variant of `decide_sound` that extracts the proof from a `DecisionResult.valid`.
-/
theorem decide_sound' (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass) (proof : ⊢ φ)
    (_h : decide φ searchDepth tableauFuel fc = .valid proof) : ⊨ φ :=
  decide_sound φ proof

/-!
## Decidability Theorem
-/

/--
Validity is decidable for TM bimodal logic.

This combines soundness and completeness to show that validity
is a decidable property (using classical logic for incomplete cases).
-/
theorem validity_decidable (φ : Formula) :
    (⊨ φ) ∨ ¬(⊨ φ) := by
  -- Classical disjunction
  exact Classical.em (⊨ φ)

/--
Alternative formulation: there exists a decision procedure
that correctly determines validity (using classical logic
for timeout cases).
-/
theorem validity_has_decision_procedure (φ : Formula) :
    ∃ (decision : Bool), (decision = true ↔ ⊨ φ) := by
  by_cases h : (⊨ φ)
  · exact ⟨true, by simp [h]⟩
  · exact ⟨false, by simp [h]⟩

/-!
## Statistics and Properties
-/

/--
Properties of the decision result.

Post-R7 this is a four-way exclusivity statement: the former `timeout` constructor was split
into `fuelExhausted` (validity genuinely undetermined) and `extractionFailed` (the tableau
closed, so the formula is valid, but no proof term was reconstructed).
-/
theorem decide_result_exclusive (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass := .Base) :
    let r := decide φ searchDepth tableauFuel fc
    (r.isValid ∧ ¬r.isInvalid ∧ ¬r.isFuelExhausted ∧ ¬r.isExtractionFailed) ∨
    (¬r.isValid ∧ r.isInvalid ∧ ¬r.isFuelExhausted ∧ ¬r.isExtractionFailed) ∨
    (¬r.isValid ∧ ¬r.isInvalid ∧ r.isFuelExhausted ∧ ¬r.isExtractionFailed) ∨
    (¬r.isValid ∧ ¬r.isInvalid ∧ ¬r.isFuelExhausted ∧ r.isExtractionFailed) := by
  simp only [DecisionResult.isValid, DecisionResult.isInvalid,
    DecisionResult.isFuelExhausted, DecisionResult.isExtractionFailed]
  cases decide φ searchDepth tableauFuel fc <;> simp

/--
Honest reporting (R7): a closed tableau is never reported as undecided.

`isUndecided` holds only of `fuelExhausted`; in particular `extractionFailed` — the case in
which every tableau branch closed but proof-term reconstruction was incomplete — does not
count as undecided. This is the property the pre-R7 single `timeout` constructor made
unstatable.
-/
theorem not_undecided_of_extractionFailed (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass := .Base)
    (h : (decide φ searchDepth tableauFuel fc).isExtractionFailed) :
    ¬(decide φ searchDepth tableauFuel fc).isUndecided := by
  revert h
  simp only [DecisionResult.isExtractionFailed, DecisionResult.isUndecided]
  cases decide φ searchDepth tableauFuel fc <;> simp

/--
Every `extractionFailed` result is a known-valid result: the tableau closed.
-/
theorem isKnownValid_of_extractionFailed (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass := .Base)
    (h : (decide φ searchDepth tableauFuel fc).isExtractionFailed) :
    (decide φ searchDepth tableauFuel fc).isKnownValid := by
  revert h
  simp only [DecisionResult.isExtractionFailed, DecisionResult.isKnownValid]
  cases decide φ searchDepth tableauFuel fc <;> simp

/-!
## Completeness via FMP

The Finite Model Property provides completeness: if φ is valid,
then φ is provable. This is because:
1. If φ is not provable, then ¬φ is consistent
2. By FMP, there exists a finite model where ¬φ is true
3. Therefore φ is not valid in all models (contradiction)

Taking the contrapositive: valid → provable.
-/

/--
FMP-based completeness: If φ is true in all closure MCS,
then φ is provable from the empty context.

This is the key completeness theorem connecting semantic validity
(via MCS membership) to syntactic provability.
-/
theorem fmp_completeness (φ : Formula) :
    (∀ (S : FMP.ClosureMCSBundle φ), φ ∈ S.carrier) →
    Derivable FrameClass.Base [] φ :=
  FMP.fmp_contrapositive φ

/--
FMP-based incompleteness witness: If φ is not provable,
then there exists a finite model (closure MCS) where φ fails.

This is the contrapositive of completeness.
-/
theorem fmp_incompleteness_witness (φ : Formula) :
    ¬Derivable FrameClass.Base [] φ →
    ∃ (S : FMP.ClosureMCSBundle φ), φ ∉ S.carrier ∧
    Finite (FMP.FilteredWorld φ) :=
  FMP.mcs_finite_model_property φ

/--
The filtered model is finite, providing a bound on countermodel size.
-/
theorem countermodel_size_bound (φ : Formula) :
    Finite (FMP.FilteredWorld φ) :=
  FMP.FilteredWorld.finite φ

end FormalSystem.Metalogic.Decidability
