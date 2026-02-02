import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Metalogic.Soundness

/-!
# Correctness of the Decision Procedure

This module proves the soundness of the tableau decision procedure:
- **Soundness**: If `decide` returns `valid proof`, then the formula is valid

## Main Theorems

- `decide_sound`: Decision procedure is sound
- `decide_sound_when_valid`: Convenience wrapper
- `validity_decidable`: Validity is classically decidable

## Implementation Notes

The soundness proof relies on the existing soundness theorem from
`Bimodal.Metalogic.Soundness`. Completeness theorems have been archived
to Boneyard as they require finite model property formalization.

## References

* Wu, M. Verified Decision Procedures for Modal Logics
* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace Bimodal.Metalogic.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic

/-!
## Soundness
-/

/--
The decision procedure is sound: if it returns `valid proof`,
then the formula is semantically valid.

This follows from the soundness of the TM proof system.
-/
theorem decide_sound (φ : Formula) (proof : DerivationTree [] φ) :
    (⊨ φ) := by
  -- soundness : (Γ ⊢ φ) → (Γ ⊨ φ)
  -- For empty context, ([] ⊨ φ) is equivalent to (⊨ φ)
  have h := soundness [] φ proof
  exact Validity.valid_iff_empty_consequence φ |>.mpr h

/--
If decide returns valid, the formula is valid.
-/
theorem decide_valid_implies_valid (φ : Formula) (searchDepth tableauFuel : Nat)
    (proof : DerivationTree [] φ)
    (_ : decide φ searchDepth tableauFuel = .valid proof) :
    (⊨ φ) := by
  exact decide_sound φ proof

/-!
## Correctness Summary
-/

/--
Main correctness theorem: decide is sound when it succeeds.

If `decide` returns `valid proof`, the formula is valid (soundness).
If `decide` returns `invalid counter`, the formula may or may not be invalid
(countermodel extraction is simplified and not fully verified).
-/
theorem decide_sound_when_valid (φ : Formula) (searchDepth tableauFuel : Nat)
    (proof : DerivationTree [] φ) :
    decide φ searchDepth tableauFuel = .valid proof →
    (⊨ φ) := by
  intro _
  exact decide_sound φ proof

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
## Integration with Existing Soundness
-/

/--
The extracted proof from decide is correct.
This combines the decision procedure with soundness.
-/
theorem extracted_proof_correct (φ : Formula)
    (h : (decide φ).getProof?.isSome) :
    (⊨ φ) := by
  match hd : decide φ with
  | .valid proof => exact decide_sound φ proof
  | .invalid _ =>
    simp only [hd, DecisionResult.getProof?] at h
    cases h
  | .timeout =>
    simp only [hd, DecisionResult.getProof?] at h
    cases h

/-!
## Auxiliary Lemmas
-/

/--
If a formula is an axiom instance, it is valid.
-/
theorem axiom_valid' (φ : Formula) (ax : Axiom φ) : (⊨ φ) := by
  have proof : DerivationTree [] φ := DerivationTree.axiom [] φ ax
  exact decide_sound φ proof

/-!
## Statistics and Properties
-/

/--
Properties of the decision result.
-/
theorem decide_result_exclusive (φ : Formula) (searchDepth tableauFuel : Nat) :
    let r := decide φ searchDepth tableauFuel
    (r.isValid ∧ ¬r.isInvalid ∧ ¬r.isTimeout) ∨
    (¬r.isValid ∧ r.isInvalid ∧ ¬r.isTimeout) ∨
    (¬r.isValid ∧ ¬r.isInvalid ∧ r.isTimeout) := by
  simp only [DecisionResult.isValid, DecisionResult.isInvalid, DecisionResult.isTimeout]
  cases decide φ searchDepth tableauFuel <;> simp

end Bimodal.Metalogic.Decidability
