import Bimodal.Metalogic.Decidability.FMP.FiniteModel
import Bimodal.Semantics.Truth
import Bimodal.Semantics.Validity

/-!
# Truth Preservation (Filtration Lemma) - Infrastructure

This module provides the infrastructure for proving truth preservation
under filtration. The main Filtration Lemma will be completed in a
subsequent implementation phase.

## Overview

The Filtration Lemma states: for any formula ψ in the subformula closure of φ,
ψ is true at a world w iff ψ is "true" at the equivalence class [w].

For our MCS-based approach:
- "Worlds" are closure MCS
- "Truth" at a closure MCS S is membership: ψ ∈ S
- The filtration lemma becomes: truth preservation through the quotient

## Main Definitions

- `mcsTruth`: Truth in a closure MCS (membership)
- `filteredMcsTruth`: Truth lifted to filtered worlds
- Basic lemmas for bot and negation consistency

## Status

Phase 4 infrastructure is in place. The full filtration lemma proof
for all formula cases (atom, bot, imp, box, past, future) requires
additional work on modal/temporal MCS properties.

## References

- Blackburn, de Rijke, Venema: Modal Logic (Ch 2.3)
-/

namespace Bimodal.Metalogic.Decidability.FMP

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## MCS Truth Definition

For the MCS-based approach, "truth" at a closure MCS S is just membership.
This is well-defined for closure formulas since they're in the closure.
-/

/--
A formula is "MCS-true" at a closure MCS if it's a member of the MCS.
-/
def mcsTruth (phi : Formula) (S : ClosureMCSBundle phi) (ψ : Formula) : Prop :=
  ψ ∈ S.carrier

/--
MCS truth respects filtration equivalence for closure formulas.
-/
theorem mcsTruth_respects_equiv (phi ψ : Formula) (hψ : ψ ∈ subformulaClosure phi)
    {S T : ClosureMCSBundle phi} (h : ClosureMCSEquiv phi S T) :
    mcsTruth phi S ψ ↔ mcsTruth phi T ψ := by
  simp only [mcsTruth]
  exact h ψ hψ

/--
Lift MCS truth to filtered worlds.
-/
def filteredMcsTruth (phi ψ : Formula) (hψ : ψ ∈ subformulaClosure phi)
    (w : FilteredWorld phi) : Prop :=
  Quotient.lift (fun S => mcsTruth phi S ψ)
    (fun S T h => propext (mcsTruth_respects_equiv phi ψ hψ h)) w

/-!
## Basic MCS Properties for Truth Preservation

These properties establish that MCS membership behaves like truth.
-/

/--
Bot is never in a consistent MCS.
-/
theorem bot_not_in_mcs {phi : Formula} (S : ClosureMCSBundle phi) :
    Formula.bot ∉ S.carrier := by
  intro h_bot
  -- If bot ∈ S, then [bot] ⊢ bot, contradicting consistency
  have h_deriv : DerivationTree [Formula.bot] Formula.bot :=
    DerivationTree.assumption [Formula.bot] Formula.bot List.mem_cons_self
  have h_cons := closure_mcs_consistent S.is_mcs
  apply h_cons [Formula.bot]
  · intro ψ hψ
    simp only [List.mem_singleton] at hψ
    exact hψ ▸ h_bot
  · exact ⟨h_deriv⟩

/--
Filtration lemma for Bot: bot is never "true" in the filtered model.
-/
theorem filtration_lemma_bot (phi : Formula) (w : FilteredWorld phi)
    (h_clos : Formula.bot ∈ subformulaClosure phi) :
    ¬filteredMcsTruth phi Formula.bot h_clos w := by
  obtain ⟨S, hS⟩ := Quotient.exists_rep w
  simp only [← hS, filteredMcsTruth, mcsTruth]
  exact bot_not_in_mcs S

/--
An MCS cannot contain both a formula and its negation.
-/
theorem mcs_not_both_and_neg {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_psi : ψ ∈ S.carrier)
    (h_neg : ψ.neg ∈ S.carrier) :
    False := by
  -- [ψ, ψ.neg] ⊢ ⊥
  have h_deriv : DerivationTree [ψ, ψ.neg] Formula.bot := by
    -- ψ.neg = ψ → ⊥
    have h1 : DerivationTree [ψ, ψ.neg] ψ.neg :=
      DerivationTree.assumption [ψ, ψ.neg] ψ.neg (List.mem_cons_of_mem _ List.mem_cons_self)
    have h2 : DerivationTree [ψ, ψ.neg] ψ :=
      DerivationTree.assumption [ψ, ψ.neg] ψ List.mem_cons_self
    exact DerivationTree.modus_ponens [ψ, ψ.neg] ψ Formula.bot h1 h2
  have h_sub : ∀ x ∈ [ψ, ψ.neg], x ∈ S.carrier := by
    intro x hx
    simp only [List.mem_cons, List.mem_nil_iff] at hx
    rcases hx with rfl | rfl | hf
    · exact h_psi
    · exact h_neg
    · exact hf.elim
  exact closure_mcs_consistent S.is_mcs [ψ, ψ.neg] h_sub ⟨h_deriv⟩

/--
MCS implication property: if φ → ψ ∈ S and φ ∈ S, then ψ ∈ S
(assuming ψ is in the closure).
-/
theorem mcs_imp_elim {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ χ : Formula}
    (h_imp : (ψ.imp χ) ∈ S.carrier)
    (h_psi : ψ ∈ S.carrier)
    (h_chi_clos : χ ∈ closureWithNeg phi) :
    χ ∈ S.carrier := by
  -- Use deductive closure: [ψ → χ, ψ] ⊢ χ by modus ponens
  have h_deriv : DerivationTree [ψ.imp χ, ψ] χ := by
    have h1 : DerivationTree [ψ.imp χ, ψ] (ψ.imp χ) :=
      DerivationTree.assumption [ψ.imp χ, ψ] (ψ.imp χ) List.mem_cons_self
    have h2 : DerivationTree [ψ.imp χ, ψ] ψ :=
      DerivationTree.assumption [ψ.imp χ, ψ] ψ (List.mem_cons_of_mem _ List.mem_cons_self)
    exact DerivationTree.modus_ponens [ψ.imp χ, ψ] ψ χ h1 h2
  -- All premises are in S
  have h_sub : ∀ x ∈ [ψ.imp χ, ψ], x ∈ S.carrier := by
    intro x hx
    simp only [List.mem_cons, List.mem_nil_iff] at hx
    rcases hx with rfl | rfl | hf
    · exact h_imp
    · exact h_psi
    · exact hf.elim
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_chi_clos

/--
Filtration lemma for implication (forward direction).
If ψ → χ ∈ S and ψ ∈ S, then χ ∈ S.
-/
theorem filtration_imp_forward {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ χ : Formula}
    (h_imp_clos : (ψ.imp χ) ∈ subformulaClosure phi)
    (h_imp : (ψ.imp χ) ∈ S.carrier)
    (h_psi : ψ ∈ S.carrier) :
    χ ∈ S.carrier := by
  -- χ ∈ subformulaClosure phi since imp is in closure
  have h_chi_subclos : χ ∈ subformulaClosure phi :=
    closure_imp_right phi ψ χ h_imp_clos
  have h_chi_clos : χ ∈ closureWithNeg phi :=
    subformulaClosure_subset_closureWithNeg phi h_chi_subclos
  exact mcs_imp_elim h_imp h_psi h_chi_clos

/-!
## Summary

This module provides:
1. MCS truth definition (membership-based)
2. Truth lifting to filtered worlds
3. Bot lemma: bot is never true
4. Negation consistency: can't have both ψ and ¬ψ
5. Implication elimination

The full filtration lemma for all formula cases (including modal box
and temporal operators) requires additional infrastructure for:
- Modal witness properties (diamond witnesses)
- Temporal structure preservation
- Connection to semantic truth_at

These will be addressed in continued Phase 4 work.
-/

end Bimodal.Metalogic.Decidability.FMP
