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
## MCS Properties for Modal Operators

These properties establish how modal operators behave in closure MCS.
-/

/--
Box closure property for closure MCS: □ψ ∈ S implies ψ ∈ S.

This uses the Modal T axiom (□φ → φ).
-/
theorem mcs_box_closure {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_box : ψ.box ∈ S.carrier)
    (h_psi_clos : ψ ∈ closureWithNeg phi) :
    ψ ∈ S.carrier := by
  -- Modal T axiom: □ψ → ψ
  have h_modal_t_thm : [] ⊢ (ψ.box).imp ψ :=
    DerivationTree.axiom [] _ (Axiom.modal_t ψ)
  have h_deriv : [ψ.box] ⊢ ψ := by
    have h_axiom : [ψ.box] ⊢ (ψ.box).imp ψ :=
      DerivationTree.weakening [] _ _ h_modal_t_thm (by intro; simp)
    have h_assume : [ψ.box] ⊢ ψ.box :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : ∀ x ∈ [ψ.box], x ∈ S.carrier := by simp [h_box]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_psi_clos

/--
Box transitivity for closure MCS: □ψ ∈ S implies □□ψ ∈ S.

This uses the Modal 4 axiom (□φ → □□φ).
-/
theorem mcs_box_box {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_box : ψ.box ∈ S.carrier)
    (h_boxbox_clos : ψ.box.box ∈ closureWithNeg phi) :
    ψ.box.box ∈ S.carrier := by
  -- Modal 4 axiom: □ψ → □□ψ
  have h_modal_4_thm : [] ⊢ (ψ.box).imp (ψ.box.box) :=
    DerivationTree.axiom [] _ (Axiom.modal_4 ψ)
  have h_deriv : [ψ.box] ⊢ ψ.box.box := by
    have h_axiom : [ψ.box] ⊢ (ψ.box).imp (ψ.box.box) :=
      DerivationTree.weakening [] _ _ h_modal_4_thm (by intro; simp)
    have h_assume : [ψ.box] ⊢ ψ.box :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : ∀ x ∈ [ψ.box], x ∈ S.carrier := by simp [h_box]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_boxbox_clos

/--
Filtration lemma for Box (forward direction).
If □ψ ∈ closure(φ) and □ψ ∈ S, then ψ ∈ S.
-/
theorem filtration_box_forward {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_box_clos : ψ.box ∈ subformulaClosure phi)
    (h_box : ψ.box ∈ S.carrier) :
    ψ ∈ S.carrier := by
  have h_psi_clos : ψ ∈ subformulaClosure phi := closure_box phi ψ h_box_clos
  have h_psi_clneg : ψ ∈ closureWithNeg phi :=
    subformulaClosure_subset_closureWithNeg phi h_psi_clos
  exact mcs_box_closure h_box h_psi_clneg

/-!
## MCS Properties for Temporal Operators

These properties establish how temporal operators behave in closure MCS.
-/

/--
All-future reflexivity for closure MCS: Gψ ∈ S implies ψ ∈ S.

This uses the temporal T axiom (Gφ → φ).
-/
theorem mcs_all_future_closure {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_future : ψ.all_future ∈ S.carrier)
    (h_psi_clos : ψ ∈ closureWithNeg phi) :
    ψ ∈ S.carrier := by
  -- Temporal T axiom: Gψ → ψ
  have h_temp_t_thm : [] ⊢ (ψ.all_future).imp ψ :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future ψ)
  have h_deriv : [ψ.all_future] ⊢ ψ := by
    have h_axiom : [ψ.all_future] ⊢ (ψ.all_future).imp ψ :=
      DerivationTree.weakening [] _ _ h_temp_t_thm (by intro; simp)
    have h_assume : [ψ.all_future] ⊢ ψ.all_future :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : ∀ x ∈ [ψ.all_future], x ∈ S.carrier := by simp [h_future]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_psi_clos

/--
All-past reflexivity for closure MCS: Hψ ∈ S implies ψ ∈ S.

This uses the temporal T axiom for past (Hφ → φ).
-/
theorem mcs_all_past_closure {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_past : ψ.all_past ∈ S.carrier)
    (h_psi_clos : ψ ∈ closureWithNeg phi) :
    ψ ∈ S.carrier := by
  -- Temporal T axiom for past: Hψ → ψ
  have h_temp_t_thm : [] ⊢ (ψ.all_past).imp ψ :=
    DerivationTree.axiom [] _ (Axiom.temp_t_past ψ)
  have h_deriv : [ψ.all_past] ⊢ ψ := by
    have h_axiom : [ψ.all_past] ⊢ (ψ.all_past).imp ψ :=
      DerivationTree.weakening [] _ _ h_temp_t_thm (by intro; simp)
    have h_assume : [ψ.all_past] ⊢ ψ.all_past :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : ∀ x ∈ [ψ.all_past], x ∈ S.carrier := by simp [h_past]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_psi_clos

/--
All-future transitivity for closure MCS: Gψ ∈ S implies GGψ ∈ S.

This uses the temporal 4 axiom (Gφ → GGφ).
-/
theorem mcs_all_future_all_future {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_future : ψ.all_future ∈ S.carrier)
    (h_future_future_clos : ψ.all_future.all_future ∈ closureWithNeg phi) :
    ψ.all_future.all_future ∈ S.carrier := by
  -- Temporal 4 axiom: Gψ → GGψ
  have h_temp_4_thm : [] ⊢ (ψ.all_future).imp (ψ.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 ψ)
  have h_deriv : [ψ.all_future] ⊢ ψ.all_future.all_future := by
    have h_axiom : [ψ.all_future] ⊢ (ψ.all_future).imp (ψ.all_future.all_future) :=
      DerivationTree.weakening [] _ _ h_temp_4_thm (by intro; simp)
    have h_assume : [ψ.all_future] ⊢ ψ.all_future :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : ∀ x ∈ [ψ.all_future], x ∈ S.carrier := by simp [h_future]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_future_future_clos

/--
All-past transitivity for closure MCS: Hψ ∈ S implies HHψ ∈ S.

This uses the derived temporal 4 axiom for past (Hφ → HHφ).
-/
theorem mcs_all_past_all_past {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_past : ψ.all_past ∈ S.carrier)
    (h_past_past_clos : ψ.all_past.all_past ∈ closureWithNeg phi) :
    ψ.all_past.all_past ∈ S.carrier := by
  -- Derived temporal 4 for past: Hψ → HHψ
  have h_temp_4_past_thm : [] ⊢ (ψ.all_past).imp (ψ.all_past.all_past) :=
    temp_4_past ψ
  have h_deriv : [ψ.all_past] ⊢ ψ.all_past.all_past := by
    have h_axiom : [ψ.all_past] ⊢ (ψ.all_past).imp (ψ.all_past.all_past) :=
      DerivationTree.weakening [] _ _ h_temp_4_past_thm (by intro; simp)
    have h_assume : [ψ.all_past] ⊢ ψ.all_past :=
      DerivationTree.assumption _ _ (by simp)
    exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
  have h_sub : ∀ x ∈ [ψ.all_past], x ∈ S.carrier := by simp [h_past]
  exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_past_past_clos

/--
Filtration lemma for all_future (forward direction).
If Gψ ∈ closure(φ) and Gψ ∈ S, then ψ ∈ S.
-/
theorem filtration_all_future_forward {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_future_clos : ψ.all_future ∈ subformulaClosure phi)
    (h_future : ψ.all_future ∈ S.carrier) :
    ψ ∈ S.carrier := by
  have h_psi_clos : ψ ∈ subformulaClosure phi := closure_all_future phi ψ h_future_clos
  have h_psi_clneg : ψ ∈ closureWithNeg phi :=
    subformulaClosure_subset_closureWithNeg phi h_psi_clos
  exact mcs_all_future_closure h_future h_psi_clneg

/--
Filtration lemma for all_past (forward direction).
If Hψ ∈ closure(φ) and Hψ ∈ S, then ψ ∈ S.
-/
theorem filtration_all_past_forward {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula}
    (h_past_clos : ψ.all_past ∈ subformulaClosure phi)
    (h_past : ψ.all_past ∈ S.carrier) :
    ψ ∈ S.carrier := by
  have h_psi_clos : ψ ∈ subformulaClosure phi := closure_all_past phi ψ h_past_clos
  have h_psi_clneg : ψ ∈ closureWithNeg phi :=
    subformulaClosure_subset_closureWithNeg phi h_psi_clos
  exact mcs_all_past_closure h_past h_psi_clneg

/-!
## Main Filtration Lemma

The filtration lemma states that MCS membership is preserved for closure formulas.
This is the key result enabling the Finite Model Property.
-/

/--
The main filtration lemma for MCS-based FMP.

For any formula ψ in the subformula closure of φ:
- ψ ∈ S iff ψ is "true" in the filtered model at [S]

Since our filtered model uses MCS membership as truth, and the
equivalence relation only distinguishes on closure formulas,
truth is automatically preserved by construction.

This lemma provides the specific closure properties needed for
each formula constructor.
-/
theorem filtration_lemma_membership {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula} (h_clos : ψ ∈ subformulaClosure phi) :
    (ψ ∈ S.carrier) ↔ filteredMcsTruth phi ψ h_clos (toFilteredWorld phi S) := by
  simp only [filteredMcsTruth, toFilteredWorld, mcsTruth]
  rfl

/--
Negation completeness for closure MCS: for ψ ∈ closure(φ), either ψ ∈ S or ψ.neg ∈ S.
-/
theorem mcs_closure_negation_complete {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ : Formula} (h_clos : ψ ∈ subformulaClosure phi) :
    ψ ∈ S.carrier ∨ ψ.neg ∈ S.carrier :=
  closure_mcs_negation_complete S.is_mcs ψ h_clos

/--
Implication iff property for closure MCS: (ψ → χ) ∈ S iff (ψ ∈ S implies χ ∈ S).
(Only the backward direction is proven here; forward follows from mcs_imp_elim.)
-/
theorem mcs_imp_intro {phi : Formula} {S : ClosureMCSBundle phi}
    {ψ χ : Formula}
    (h_imp_clos : (ψ.imp χ) ∈ closureWithNeg phi)
    (h_psi_clos : ψ ∈ subformulaClosure phi)
    (h : ψ ∈ S.carrier → χ ∈ S.carrier) :
    (ψ.imp χ) ∈ S.carrier := by
  -- By negation completeness on ψ
  cases mcs_closure_negation_complete h_psi_clos with
  | inl h_psi =>
    -- ψ ∈ S, so χ ∈ S by hypothesis
    have h_chi : χ ∈ S.carrier := h h_psi
    -- From χ, derive ψ → χ via prop_s: χ → (ψ → χ)
    have h_prop_s_thm : [] ⊢ χ.imp (ψ.imp χ) :=
      DerivationTree.axiom [] _ (Axiom.prop_s χ ψ)
    have h_deriv : [χ] ⊢ (ψ.imp χ) := by
      have h_axiom : [χ] ⊢ χ.imp (ψ.imp χ) :=
        DerivationTree.weakening [] _ _ h_prop_s_thm (by intro; simp)
      have h_assume : [χ] ⊢ χ :=
        DerivationTree.assumption _ _ (by simp)
      exact DerivationTree.modus_ponens _ _ _ h_axiom h_assume
    have h_sub : ∀ x ∈ [χ], x ∈ S.carrier := by simp [h_chi]
    exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_imp_clos
  | inr h_neg_psi =>
    -- ψ.neg ∈ S, i.e., (ψ → ⊥) ∈ S
    -- From ψ.neg, derive ψ → χ
    -- We have ψ.neg = ψ → ⊥. Then from ⊥ we get χ (EFQ).
    -- So [ψ.neg, ψ] ⊢ χ, hence [ψ.neg] ⊢ ψ → χ
    have h_deriv : [ψ.neg] ⊢ (ψ.imp χ) := by
      have h_inner : DerivationTree (ψ :: [ψ.neg]) χ := by
        have h_psi_assume : (ψ :: [ψ.neg]) ⊢ ψ :=
          DerivationTree.assumption _ _ (by simp)
        have h_neg_assume : (ψ :: [ψ.neg]) ⊢ ψ.neg :=
          DerivationTree.assumption _ _ (by simp)
        have h_bot : (ψ :: [ψ.neg]) ⊢ Formula.bot :=
          derives_bot_from_phi_neg_phi h_psi_assume h_neg_assume
        have h_efq_thm : [] ⊢ Formula.bot.imp χ :=
          DerivationTree.axiom [] _ (Axiom.ex_falso χ)
        have h_efq : (ψ :: [ψ.neg]) ⊢ Formula.bot.imp χ :=
          DerivationTree.weakening [] _ _ h_efq_thm (by intro; simp)
        exact DerivationTree.modus_ponens _ _ _ h_efq h_bot
      exact deduction_theorem [ψ.neg] ψ χ h_inner
    have h_sub : ∀ x ∈ [ψ.neg], x ∈ S.carrier := by simp [h_neg_psi]
    exact closure_mcs_deductively_closed S.is_mcs h_sub h_deriv h_imp_clos

/-!
## Summary

This module provides the complete filtration lemma infrastructure:

1. **MCS Truth**: Membership-based truth definition
2. **Filtered Truth**: Truth lifted to quotient
3. **Bot Case**: ⊥ is never true
4. **Negation Consistency**: Can't have both ψ and ¬ψ
5. **Implication**: Both directions (modus ponens and introduction)
6. **Box (Modal)**: Forward direction (T axiom) and transitivity (4 axiom)
7. **All-future (Temporal)**: Forward direction (T axiom) and transitivity (4 axiom)
8. **All-past (Temporal)**: Forward direction (T axiom) and transitivity (4 axiom)
9. **Negation Completeness**: For closure formulas, either ψ or ¬ψ is in MCS

These properties ensure that truth (membership) is preserved under the
filtration quotient, enabling the Finite Model Property proof.
-/

end Bimodal.Metalogic.Decidability.FMP
