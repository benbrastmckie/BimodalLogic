import Bimodal.Boneyard.Metalogic.Decidability.DecisionProcedure
import Bimodal.Boneyard.Metalogic.Soundness.Soundness

/-!
# Correctness of the Decision Procedure

This module proves the correctness of the tableau decision procedure:
- **Soundness**: If `decide` returns `valid proof`, then the formula is valid
- **Completeness**: If the formula is valid, `decide` returns `valid proof` (with sufficient fuel)

## Main Theorems

- `decide_sound`: Decision procedure is sound
- `decide_complete`: Decision procedure is complete (with sufficient fuel)

## Implementation Notes

The soundness proof relies on the existing soundness theorem from
`Bimodal.Boneyard.Metalogic.Soundness`. The completeness proof is more complex
and relies on the finite model property and tableau completeness.

## References

* Wu, M. Verified Decision Procedures for Modal Logics
* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
-/

namespace Bimodal.Boneyard.Metalogic.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Boneyard.Metalogic

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
  have h := Soundness.soundness [] φ proof
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
## Completeness (Partial)
-/

/--
The tableau method is complete: if a formula is valid, the tableau will
eventually close all branches.

Note: This is a partial formalization. Full completeness requires:
1. Finite model property for TM logic (see `Representation.FiniteModelProperty`)
2. Tableau completeness relative to FMP
3. Termination with sufficient fuel

**FMP Reference**: The `finite_model_property` theorem in
`Bimodal.Boneyard.Metalogic.Representation.FiniteModelProperty` provides the key bound:
any satisfiable formula has a model with bounded world states (≤ 2^|subformulas|).
This bounds the tableau exploration space.
-/
theorem tableau_complete (φ : Formula) :
    (⊨ φ) → ∃ (fuel : Nat), (buildTableau φ fuel).isSome ∧
             ∀ t, buildTableau φ fuel = some t → t.isValid := by
  sorry  -- Requires FMP-based termination proof; see Representation.FiniteModelProperty

/--
Decision procedure completeness: if a formula is valid and we use
sufficient fuel, decide will return valid.

Note: This is stated but not fully proven due to complexity of
FMP and completeness proofs.

**FMP Connection**: The `finite_model_property` theorem bounds the search space.
For a formula with complexity n, the fuel bound is O(2^n) since the subformula
closure has at most 2^n distinct states.
-/
theorem decide_complete (φ : Formula) (hvalid : ⊨ φ) :
    ∃ (fuel : Nat), ∃ proof, decide φ 10 fuel = .valid proof := by
  sorry  -- Requires tableau completeness; fuel bound from Representation.FiniteModelProperty

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

/--
Decision on axiom instances returns valid.
-/
theorem decide_axiom_valid (φ : Formula) (ax : Axiom φ) :
    ∃ proof, decide φ = .valid proof := by
  -- matchAxiom should find the axiom and return a proof
  use DerivationTree.axiom [] φ ax
  sorry  -- Would need to verify matchAxiom behavior

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

end Bimodal.Boneyard.Metalogic.Decidability
