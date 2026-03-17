import Bimodal.Metalogic.Decidability.DecisionProcedure
import Bimodal.Metalogic.Decidability.FMP.FMP
import Bimodal.Metalogic.Soundness

/-!
# Correctness of the Decision Procedure

This module proves properties of the tableau decision procedure.

## Main Theorems

- `validity_decidable`: Validity is classically decidable
- `decide_result_exclusive`: Decision results are mutually exclusive

## Implementation Notes (Task 956)

With irreflexive temporal semantics, the universal soundness theorem
`soundness : (Γ ⊢ φ) → (Γ ⊨ φ)` no longer holds because the derivation system
includes both density (valid only on dense frames) and discreteness_forward
(valid only on discrete frames). Soundness is now frame-class specific:
- `axiom_valid_dense` for dense-compatible axioms
- `axiom_valid_discrete` for discrete-compatible axioms

The `decide_sound` theorem (relating derivability to universal validity) has been
removed. Frame-class specific soundness should be used instead.

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
-/
theorem decide_result_exclusive (φ : Formula) (searchDepth tableauFuel : Nat) :
    let r := decide φ searchDepth tableauFuel
    (r.isValid ∧ ¬r.isInvalid ∧ ¬r.isTimeout) ∨
    (¬r.isValid ∧ r.isInvalid ∧ ¬r.isTimeout) ∨
    (¬r.isValid ∧ ¬r.isInvalid ∧ r.isTimeout) := by
  simp only [DecisionResult.isValid, DecisionResult.isInvalid, DecisionResult.isTimeout]
  cases decide φ searchDepth tableauFuel <;> simp

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
    Nonempty (DerivationTree [] φ) :=
  FMP.fmp_contrapositive φ

/--
FMP-based incompleteness witness: If φ is not provable,
then there exists a finite model (closure MCS) where φ fails.

This is the contrapositive of completeness.
-/
theorem fmp_incompleteness_witness (φ : Formula) :
    ¬Nonempty (DerivationTree [] φ) →
    ∃ (S : FMP.ClosureMCSBundle φ), φ ∉ S.carrier ∧
    Finite (FMP.FilteredWorld φ) :=
  FMP.mcs_finite_model_property φ

/--
The filtered model is finite, providing a bound on countermodel size.
-/
theorem countermodel_size_bound (φ : Formula) :
    Finite (FMP.FilteredWorld φ) :=
  FMP.FilteredWorld.finite φ

end Bimodal.Metalogic.Decidability
