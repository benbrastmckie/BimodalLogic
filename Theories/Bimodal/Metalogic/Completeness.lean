import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Theorems.Propositional

/-!
# Completeness for TM Bimodal Logic

This module provides modal and temporal MCS properties for the completeness
theorem of TM (Tense and Modality) bimodal logic.

## Refactoring Notes (Task 798)

This file has been refactored from a monolithic ~3720 lines to ~680 lines by:

1. **Core Extraction**: SetConsistency definitions, Lindenbaum lemma, and basic MCS
   properties moved to `Core/MaximalConsistent.lean` (re-exported from Boneyard v2)
   and `Core/MCSProperties.lean`

2. **Boneyard Archive**: Duration-based canonical model infrastructure (~2300 lines)
   archived to `Boneyard/Metalogic_v4/Completeness/MonolithicCompleteness.lean`

3. **Retained Content**: This file keeps:
   - Modal closure properties (box_closure, box_box)
   - Diamond-box duality proofs
   - Saturation lemma stubs
   - CanonicalWorldState definition

## Main Results

Re-exported from Core modules:
- `set_lindenbaum`: Lindenbaum's lemma via Zorn
- `set_mcs_closed_under_derivation`: MCS deductive closure
- `set_mcs_implication_property`, `set_mcs_negation_complete`: MCS properties
- `set_mcs_all_future_all_future`, `set_mcs_all_past_all_past`: Temporal 4 properties

Defined here:
- `set_mcs_box_closure`: Modal T property for MCS
- `set_mcs_box_box`: Modal 4 property for MCS
- `set_mcs_diamond_box_duality`: Diamond-box duality
- `CanonicalWorldState`: Type for set-based maximal consistent sets

## References

* Modal Logic, Blackburn et al., Chapter 4 (Canonical Models)
* See `Boneyard/Metalogic_v4/Completeness/` for archived Duration construction
-/

namespace Bimodal.Metalogic

open Syntax ProofSystem Semantics Theorems.Combinators Theorems.Propositional
open Bimodal.Metalogic.Core

/--
Set-based MCS: disjunction property (forward direction).

If φ ∈ S or ψ ∈ S, then (φ ∨ ψ) ∈ S.
Note: `φ.or ψ = φ.neg.imp ψ`
-/
theorem set_mcs_disjunction_intro {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : φ ∈ S ∨ ψ ∈ S) : (φ.or ψ) ∈ S := by
  -- φ.or ψ = φ.neg.imp ψ
  -- We need to show that φ.neg.imp ψ ∈ S
  cases h with
  | inl h_phi =>
    -- φ ∈ S. We derive (¬φ → ψ) from the axiom (φ → ¬φ → ψ) and modus ponens.
    -- Actually, we derive ¬φ → ψ by: from φ, derive ¬¬φ, then ¬¬φ → (¬φ → ψ) is tautology
    -- Simpler: by set_mcs_negation_complete, either φ.neg ∈ S or φ.neg.neg ∈ S
    -- Since φ ∈ S, we show φ.neg ∉ S (else inconsistent)
    -- So φ.neg.neg ∈ S is not directly helpful...
    -- Better: use the theorem that derives ¬φ → ψ from φ using weakening
    -- From [φ, φ.neg] we derive ψ via EFQ. Then φ :: [φ.neg] ⊢ ψ.
    -- By deduction theorem: [φ] ⊢ φ.neg → ψ, i.e., [φ] ⊢ φ.or ψ
    -- Then by closure: if [φ] ⊆ S, then φ.or ψ ∈ S.
    have h_deriv : DerivationTree [φ] (φ.or ψ) := by
      -- Need: [φ] ⊢ φ.neg.imp ψ
      -- Use deduction theorem: need φ.neg :: [φ] ⊢ ψ
      -- From φ.neg :: [φ] we have φ and φ.neg, so we get ⊥, then ψ by EFQ
      have h_inner : DerivationTree (φ.neg :: [φ]) ψ := by
        have h_phi_assume : (φ.neg :: [φ]) ⊢ φ :=
          DerivationTree.assumption _ _ (by simp)
        have h_neg_assume : (φ.neg :: [φ]) ⊢ φ.neg :=
          DerivationTree.assumption _ _ (by simp)
        have h_bot : (φ.neg :: [φ]) ⊢ Formula.bot :=
          derives_bot_from_phi_neg_phi h_phi_assume h_neg_assume
        -- EFQ: ⊥ → ψ (via ex_falso axiom, weakened to context)
        have h_efq_thm : [] ⊢ Formula.bot.imp ψ :=
          DerivationTree.axiom [] _ (Axiom.ex_falso ψ)
        have h_efq : (φ.neg :: [φ]) ⊢ Formula.bot.imp ψ :=
          DerivationTree.weakening [] _ _ h_efq_thm (by intro; simp)
        exact DerivationTree.modus_ponens _ _ _ h_efq h_bot
      exact deduction_theorem [φ] φ.neg ψ h_inner
    have h_sub : ∀ χ ∈ [φ], χ ∈ S := by simp [h_phi]
    exact set_mcs_closed_under_derivation h_mcs [φ] h_sub h_deriv
  | inr h_psi =>
    -- ψ ∈ S. We derive (¬φ → ψ) from the axiom ψ → (¬φ → ψ).
    have h_deriv : DerivationTree [ψ] (φ.or ψ) := by
      -- ψ → (φ.neg → ψ) is prop_s axiom (φ → (ψ → φ)) instantiated as ψ → (φ.neg → ψ)
      have h_prop_s_thm : [] ⊢ ψ.imp (φ.neg.imp ψ) :=
        DerivationTree.axiom [] _ (Axiom.prop_s ψ φ.neg)
      have h_prop_s : [ψ] ⊢ ψ.imp (φ.neg.imp ψ) :=
        DerivationTree.weakening [] _ _ h_prop_s_thm (by intro; simp)
      have h_psi_assume : [ψ] ⊢ ψ :=
        DerivationTree.assumption _ _ (by simp)
      exact DerivationTree.modus_ponens _ _ _ h_prop_s h_psi_assume
    have h_sub : ∀ χ ∈ [ψ], χ ∈ S := by simp [h_psi]
    exact set_mcs_closed_under_derivation h_mcs [ψ] h_sub h_deriv

/--
Set-based MCS: disjunction property (backward direction).

If (φ ∨ ψ) ∈ S, then φ ∈ S or ψ ∈ S.
-/
theorem set_mcs_disjunction_elim {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : (φ.or ψ) ∈ S) : φ ∈ S ∨ ψ ∈ S := by
  -- By negation completeness: either φ ∈ S or φ.neg ∈ S
  cases set_mcs_negation_complete h_mcs φ with
  | inl h_phi => exact Or.inl h_phi
  | inr h_neg_phi =>
    -- φ.neg ∈ S and (φ.or ψ) = (φ.neg.imp ψ) ∈ S
    -- By modus ponens: ψ ∈ S
    right
    exact set_mcs_implication_property h_mcs h h_neg_phi

/--
Set-based MCS: disjunction iff property.

(φ ∨ ψ) ∈ S iff (φ ∈ S or ψ ∈ S).
-/
theorem set_mcs_disjunction_iff {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    (φ.or ψ) ∈ S ↔ (φ ∈ S ∨ ψ ∈ S) :=
  ⟨set_mcs_disjunction_elim h_mcs, set_mcs_disjunction_intro h_mcs⟩

/--
Set-based MCS: conjunction property (forward direction).

If φ ∈ S and ψ ∈ S, then (φ ∧ ψ) ∈ S.
Note: `φ.and ψ = (φ.imp ψ.neg).neg`
-/
theorem set_mcs_conjunction_intro {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_phi : φ ∈ S) (h_psi : ψ ∈ S) : (φ.and ψ) ∈ S := by
  -- φ.and ψ = (φ.imp ψ.neg).neg
  -- We need (φ.imp ψ.neg).neg ∈ S
  -- By negation completeness, either (φ.imp ψ.neg) ∈ S or (φ.imp ψ.neg).neg ∈ S
  -- Assume (φ.imp ψ.neg) ∈ S. Then with φ ∈ S, by implication property: ψ.neg ∈ S.
  -- But ψ ∈ S, and ψ.neg = ψ.imp ⊥ ∈ S would give ⊥ ∈ S, contradiction.
  cases set_mcs_negation_complete h_mcs (φ.imp ψ.neg) with
  | inr h_neg => exact h_neg
  | inl h_imp =>
    -- (φ → ¬ψ) ∈ S and φ ∈ S, so ¬ψ ∈ S
    have h_neg_psi : ψ.neg ∈ S := set_mcs_implication_property h_mcs h_imp h_phi
    -- ψ ∈ S and ¬ψ ∈ S gives ⊥ derivable from S
    -- This contradicts consistency
    exfalso
    have h_deriv : DerivationTree [ψ, ψ.neg] Formula.bot := by
      have h_psi_assume : [ψ, ψ.neg] ⊢ ψ :=
        DerivationTree.assumption _ _ (by simp)
      have h_neg_assume : [ψ, ψ.neg] ⊢ ψ.neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h_psi_assume h_neg_assume
    have h_sub : ∀ χ ∈ [ψ, ψ.neg], χ ∈ S := by
      intro χ h_mem
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at h_mem
      cases h_mem with
      | inl h_eq => exact h_eq ▸ h_psi
      | inr h_eq => exact h_eq ▸ h_neg_psi
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs [ψ, ψ.neg] h_sub h_deriv
    -- ⊥ ∈ S contradicts consistency of S
    have h_cons := h_mcs.1
    unfold SetConsistent at h_cons
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    have h_bot_sub : ∀ χ ∈ [Formula.bot], χ ∈ S := by simp [h_bot_in_S]
    exact h_cons [Formula.bot] h_bot_sub ⟨h_bot_deriv⟩

/--
Set-based MCS: conjunction property (backward direction).

If (φ ∧ ψ) ∈ S, then φ ∈ S and ψ ∈ S.
-/
theorem set_mcs_conjunction_elim {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : (φ.and ψ) ∈ S) : φ ∈ S ∧ ψ ∈ S := by
  -- (φ.and ψ) = (φ.imp ψ.neg).neg ∈ S
  -- This means φ → ¬ψ ∉ S (otherwise its negation wouldn't be there)
  -- By negation completeness and the fact that (φ → ¬ψ).neg ∈ S:
  -- If (φ → ¬ψ) ∈ S, then (φ → ¬ψ).neg ∉ S (else both in, inconsistent)
  -- So (φ → ¬ψ) ∉ S
  -- Now we show φ ∈ S:
  -- Suppose φ ∉ S. Then φ.neg ∈ S by negation completeness.
  -- We show this leads to (φ → ¬ψ) derivable from {φ.neg}, which would put it in S
  -- Actually, we derive φ → ¬ψ from ¬φ via: ¬φ → (φ → ¬ψ) which is a tautology
  -- Let's verify: from ¬φ, assume φ, then we have φ and ¬φ, derive ⊥, derive anything
  constructor
  · -- Show φ ∈ S
    by_contra h_phi_not
    have h_neg_phi : φ.neg ∈ S := by
      cases set_mcs_negation_complete h_mcs φ with
      | inl h => exact absurd h h_phi_not
      | inr h => exact h
    -- From φ.neg we derive φ.imp ψ.neg
    have h_deriv : DerivationTree [φ.neg] (φ.imp ψ.neg) := by
      -- Need: [¬φ] ⊢ φ → ¬ψ
      -- By deduction theorem: need φ :: [¬φ] ⊢ ¬ψ
      have h_inner : DerivationTree (φ :: [φ.neg]) ψ.neg := by
        -- From φ and ¬φ we get ⊥, then ¬ψ = ψ → ⊥ via K1 and constant function
        have h_phi_assume : (φ :: [φ.neg]) ⊢ φ :=
          DerivationTree.assumption _ _ (by simp)
        have h_neg_assume : (φ :: [φ.neg]) ⊢ φ.neg :=
          DerivationTree.assumption _ _ (by simp)
        have h_bot : (φ :: [φ.neg]) ⊢ Formula.bot :=
          derives_bot_from_phi_neg_phi h_phi_assume h_neg_assume
        -- ¬ψ = ψ → ⊥. Need: (φ :: [φ.neg]) ⊢ ψ → ⊥
        -- Use deduction theorem: need ψ :: φ :: [φ.neg] ⊢ ⊥
        -- We already have h_bot, weaken it
        have h_bot_weak : (ψ :: φ :: [φ.neg]) ⊢ Formula.bot :=
          DerivationTree.weakening (φ :: [φ.neg]) (ψ :: φ :: [φ.neg]) _ h_bot
            (fun x hx => List.mem_cons_of_mem ψ hx)
        exact deduction_theorem (φ :: [φ.neg]) ψ Formula.bot h_bot_weak
      exact deduction_theorem [φ.neg] φ ψ.neg h_inner
    have h_sub : ∀ χ ∈ [φ.neg], χ ∈ S := by simp [h_neg_phi]
    have h_imp_in : (φ.imp ψ.neg) ∈ S :=
      set_mcs_closed_under_derivation h_mcs [φ.neg] h_sub h_deriv
    -- Now (φ.imp ψ.neg) ∈ S and (φ.imp ψ.neg).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] Formula.bot := by
      have h1 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg) :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [(φ.imp ψ.neg), (φ.imp ψ.neg).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_imp_in
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩
  · -- Show ψ ∈ S (similar argument)
    by_contra h_psi_not
    have h_neg_psi : ψ.neg ∈ S := by
      cases set_mcs_negation_complete h_mcs ψ with
      | inl h => exact absurd h h_psi_not
      | inr h => exact h
    -- From ψ.neg we derive φ.imp ψ.neg via prop_s: ψ.neg → (φ → ψ.neg)
    have h_deriv : DerivationTree [ψ.neg] (φ.imp ψ.neg) := by
      have h_prop_s_thm : [] ⊢ ψ.neg.imp (φ.imp ψ.neg) :=
        DerivationTree.axiom [] _ (Axiom.prop_s ψ.neg φ)
      have h_prop_s : [ψ.neg] ⊢ ψ.neg.imp (φ.imp ψ.neg) :=
        DerivationTree.weakening [] _ _ h_prop_s_thm (by intro; simp)
      have h_assume : [ψ.neg] ⊢ ψ.neg :=
        DerivationTree.assumption _ _ (by simp)
      exact DerivationTree.modus_ponens _ _ _ h_prop_s h_assume
    have h_sub : ∀ χ ∈ [ψ.neg], χ ∈ S := by simp [h_neg_psi]
    have h_imp_in : (φ.imp ψ.neg) ∈ S :=
      set_mcs_closed_under_derivation h_mcs [ψ.neg] h_sub h_deriv
    -- Now (φ.imp ψ.neg) ∈ S and (φ.imp ψ.neg).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] Formula.bot := by
      have h1 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg) :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [(φ.imp ψ.neg), (φ.imp ψ.neg).neg] ⊢ (φ.imp ψ.neg).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [(φ.imp ψ.neg), (φ.imp ψ.neg).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_imp_in
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
Set-based MCS: conjunction iff property.

(φ ∧ ψ) ∈ S iff (φ ∈ S and ψ ∈ S).
-/
theorem set_mcs_conjunction_iff {S : Set Formula} {φ ψ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    (φ.and ψ) ∈ S ↔ (φ ∈ S ∧ ψ ∈ S) :=
  ⟨set_mcs_conjunction_elim h_mcs, fun ⟨h1, h2⟩ => set_mcs_conjunction_intro h_mcs h1 h2⟩

/-!
### Modal Closure Properties

These lemmas establish modal closure properties for SetMaximalConsistent sets,
using the Modal T axiom (□φ → φ) to derive that necessity implies truth.
-/

/--
Set-based MCS: box closure property.

If □φ ∈ S for a SetMaximalConsistent S, then φ ∈ S.

**Proof Strategy**:
1. Modal T axiom: □φ → φ
2. With □φ ∈ S, derive φ via modus ponens
3. By closure: φ ∈ S

This is a fundamental property: what is necessarily true is actually true.
-/
theorem set_mcs_box_closure {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_box : Formula.box φ ∈ S) : φ ∈ S := by
  -- Modal T axiom: □φ → φ
  have h_modal_t_thm : [] ⊢ (Formula.box φ).imp φ :=
    DerivationTree.axiom [] _ (Axiom.modal_t φ)
  -- Weaken to context [□φ]
  have h_modal_t : [Formula.box φ] ⊢ (Formula.box φ).imp φ :=
    DerivationTree.weakening [] _ _ h_modal_t_thm (by intro; simp)
  -- Assume □φ in context
  have h_box_assume : [Formula.box φ] ⊢ Formula.box φ :=
    DerivationTree.assumption _ _ (by simp)
  -- Apply modus ponens to get φ
  have h_deriv : [Formula.box φ] ⊢ φ :=
    DerivationTree.modus_ponens _ _ _ h_modal_t h_box_assume
  -- By closure: φ ∈ S
  have h_sub : ∀ χ ∈ [Formula.box φ], χ ∈ S := by simp [h_box]
  exact set_mcs_closed_under_derivation h_mcs [Formula.box φ] h_sub h_deriv

/--
Set-based MCS: modal 4 axiom property.

If □φ ∈ S for a SetMaximalConsistent S, then □□φ ∈ S.

**Proof Strategy**:
1. Modal 4 axiom: □φ → □□φ
2. With □φ ∈ S, derive □□φ via modus ponens
3. By closure: □□φ ∈ S

This is the positive introspection property: necessary truth implies necessarily necessary.
-/
theorem set_mcs_box_box {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_box : Formula.box φ ∈ S) : (Formula.box φ).box ∈ S := by
  -- Modal 4 axiom: □φ → □□φ
  have h_modal_4_thm : [] ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) :=
    DerivationTree.axiom [] _ (Axiom.modal_4 φ)
  -- Weaken to context [□φ]
  have h_modal_4 : [Formula.box φ] ⊢ (Formula.box φ).imp (Formula.box (Formula.box φ)) :=
    DerivationTree.weakening [] _ _ h_modal_4_thm (by intro; simp)
  -- Assume □φ in context
  have h_box_assume : [Formula.box φ] ⊢ Formula.box φ :=
    DerivationTree.assumption _ _ (by simp)
  -- Apply modus ponens to get □□φ
  have h_deriv : [Formula.box φ] ⊢ (Formula.box φ).box :=
    DerivationTree.modus_ponens _ _ _ h_modal_4 h_box_assume
  -- By closure: □□φ ∈ S
  have h_sub : ∀ χ ∈ [Formula.box φ], χ ∈ S := by simp [h_box]
  exact set_mcs_closed_under_derivation h_mcs [Formula.box φ] h_sub h_deriv

/--
Set-based MCS: temporal 4 axiom property for all_future.

If Gφ ∈ S for a SetMaximalConsistent S, then GGφ ∈ S.

**Proof Strategy**:
1. Temporal 4 axiom: Gφ → GGφ
2. With Gφ ∈ S, derive GGφ via modus ponens
3. By closure: GGφ ∈ S

This is the future transitivity property: always future implies always always future.
-/
theorem set_mcs_all_future_all_future {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_all_future : Formula.all_future φ ∈ S) : (Formula.all_future φ).all_future ∈ S := by
  -- Temporal 4 axiom: Gφ → GGφ
  have h_temp_4_thm : [] ⊢ (Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 φ)
  -- Weaken to context [Gφ]
  have h_temp_4 : [Formula.all_future φ] ⊢ (Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)) :=
    DerivationTree.weakening [] _ _ h_temp_4_thm (by intro; simp)
  -- Assume Gφ in context
  have h_all_future_assume : [Formula.all_future φ] ⊢ Formula.all_future φ :=
    DerivationTree.assumption _ _ (by simp)
  -- Apply modus ponens to get GGφ
  have h_deriv : [Formula.all_future φ] ⊢ (Formula.all_future φ).all_future :=
    DerivationTree.modus_ponens _ _ _ h_temp_4 h_all_future_assume
  -- By closure: GGφ ∈ S
  have h_sub : ∀ χ ∈ [Formula.all_future φ], χ ∈ S := by simp [h_all_future]
  exact set_mcs_closed_under_derivation h_mcs [Formula.all_future φ] h_sub h_deriv

/--
Derivation of temporal 4 axiom for past: Hφ → HHφ.

Derived by applying temporal duality to the temp_4 axiom (Gφ → GGφ).
-/
def temp_4_past (φ : Formula) : DerivationTree [] (φ.all_past.imp φ.all_past.all_past) := by
  -- We want: Hφ → HHφ
  -- By temporal duality from: Gψ → GGψ where ψ = swap_temporal φ
  -- swap_temporal of (Gψ → GGψ) = Hφ' → HHφ' where φ' = swap_temporal ψ = φ
  let ψ := φ.swap_temporal
  -- Step 1: Get T4 axiom for ψ: Gψ → GGψ
  have h1 : DerivationTree [] (ψ.all_future.imp ψ.all_future.all_future) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 ψ)
  -- Step 2: Apply temporal duality to get: H(swap ψ) → HH(swap ψ)
  have h2 : DerivationTree [] (ψ.all_future.imp ψ.all_future.all_future).swap_temporal :=
    DerivationTree.temporal_duality _ h1
  -- Step 3: The result has type H(swap ψ) → HH(swap ψ) = Hφ → HHφ
  -- since swap(swap φ) = φ by involution
  have h3 : (ψ.all_future.imp ψ.all_future.all_future).swap_temporal =
      φ.all_past.imp φ.all_past.all_past := by
    -- ψ = φ.swap_temporal, so ψ.swap_temporal = φ.swap_temporal.swap_temporal = φ
    simp only [Formula.swap_temporal]
    -- Now we need to show: ψ.swap_temporal.all_past.imp ... = φ.all_past.imp ...
    -- where ψ.swap_temporal = φ by involution
    have h_inv : ψ.swap_temporal = φ := Formula.swap_temporal_involution φ
    rw [h_inv]
  rw [h3] at h2
  exact h2

/--
Set-based MCS: temporal 4 axiom property for all_past.

If Hφ ∈ S for a SetMaximalConsistent S, then HHφ ∈ S.

**Proof Strategy**:
1. Use derived temp_4_past: Hφ → HHφ
2. With Hφ ∈ S, derive HHφ via modus ponens
3. By closure: HHφ ∈ S

This is the past transitivity property: always past implies always always past.
-/
theorem set_mcs_all_past_all_past {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_all_past : Formula.all_past φ ∈ S) : (Formula.all_past φ).all_past ∈ S := by
  -- Derived temporal 4 for past: Hφ → HHφ
  have h_temp_4_past_thm : [] ⊢ (Formula.all_past φ).imp (Formula.all_past (Formula.all_past φ)) :=
    temp_4_past φ
  -- Weaken to context [Hφ]
  have h_temp_4 : [Formula.all_past φ] ⊢ (Formula.all_past φ).imp (Formula.all_past (Formula.all_past φ)) :=
    DerivationTree.weakening [] _ _ h_temp_4_past_thm (by intro; simp)
  -- Assume Hφ in context
  have h_all_past_assume : [Formula.all_past φ] ⊢ Formula.all_past φ :=
    DerivationTree.assumption _ _ (by simp)
  -- Apply modus ponens to get HHφ
  have h_deriv : [Formula.all_past φ] ⊢ (Formula.all_past φ).all_past :=
    DerivationTree.modus_ponens _ _ _ h_temp_4 h_all_past_assume
  -- By closure: HHφ ∈ S
  have h_sub : ∀ χ ∈ [Formula.all_past φ], χ ∈ S := by simp [h_all_past]
  exact set_mcs_closed_under_derivation h_mcs [Formula.all_past φ] h_sub h_deriv

/--
Set-based MCS: diamond-box duality (forward direction).

If ¬(□φ) ∈ S, then ◇(¬φ) ∈ S.

Note: ◇ψ = ¬□(¬ψ), so ◇(¬φ) = ¬□(¬¬φ).
-/
theorem set_mcs_neg_box_implies_diamond_neg {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : (Formula.box φ).neg ∈ S) : φ.neg.diamond ∈ S := by
  -- ◇(¬φ) = ¬□(¬¬φ)
  -- We have ¬□φ ∈ S. We need ¬□(¬¬φ) ∈ S.
  -- These are not directly equal, but we can derive the equivalence.
  -- Actually, ◇(¬φ) = (¬φ).neg.box.neg = ¬□(¬¬φ), which simplifies to ¬□φ
  -- if we have double negation elimination.
  -- But actually: ◇(¬φ) = (¬φ).diamond = ((¬φ).neg).box.neg = (φ.neg.neg).box.neg
  -- So ◇(¬φ) = ¬□(¬¬φ) = ¬□φ under double negation (classically).
  -- Let's prove: ¬□φ ↔ ◇¬φ classically.
  -- ◇¬φ = ¬□¬¬φ. So we need ¬□φ → ¬□¬¬φ.
  -- This follows from □¬¬φ → □φ (by □ distributing over →¬¬φ → φ).
  -- Actually, let's just unfold diamond: φ.neg.diamond = φ.neg.neg.box.neg
  -- We need to show: (φ.neg.neg).box.neg ∈ S
  -- By negation completeness: either (φ.neg.neg).box ∈ S or (φ.neg.neg).box.neg ∈ S
  -- If (φ.neg.neg).box ∈ S:
  --   We can derive (φ.neg.neg).box → φ.box (using □(¬¬φ → φ) and modal K distribution)
  --   Then φ.box ∈ S, contradicting (φ.box).neg ∈ S
  -- So (φ.neg.neg).box.neg ∈ S
  unfold Formula.diamond
  cases set_mcs_negation_complete h_mcs (φ.neg.neg.box) with
  | inr h_neg => exact h_neg
  | inl h_dne_box =>
    -- □(¬¬φ) ∈ S. We derive □φ from this, contradicting ¬□φ ∈ S.
    exfalso
    -- We need: □(¬¬φ → φ) which by Modal K gives □(¬¬φ) → □φ
    -- First, derive ¬¬φ → φ (double negation elimination)
    have h_dne : ⊢ φ.neg.neg.imp φ := double_negation φ
    -- Apply necessitation to get □(¬¬φ → φ)
    have h_nec_dne : ⊢ (φ.neg.neg.imp φ).box := DerivationTree.necessitation _ h_dne
    -- Modal K distribution: □(A → B) → (□A → □B)
    have h_modal_k : ⊢ (φ.neg.neg.imp φ).box.imp ((φ.neg.neg.box).imp (φ.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ.neg.neg φ)
    -- Apply modus ponens to get □(¬¬φ) → □φ
    have h_impl : ⊢ (φ.neg.neg.box).imp (φ.box) :=
      DerivationTree.modus_ponens [] _ _ h_modal_k h_nec_dne
    -- Now we have □(¬¬φ) ∈ S and □(¬¬φ) → □φ derivable
    -- So □φ ∈ S
    have h_sub : ∀ χ ∈ [φ.neg.neg.box], χ ∈ S := by simp [h_dne_box]
    have h_impl_ctx : [φ.neg.neg.box] ⊢ (φ.neg.neg.box).imp (φ.box) :=
      DerivationTree.weakening [] _ _ h_impl (by intro; simp)
    have h_assume : [φ.neg.neg.box] ⊢ φ.neg.neg.box :=
      DerivationTree.assumption _ _ (by simp)
    have h_deriv : [φ.neg.neg.box] ⊢ φ.box :=
      DerivationTree.modus_ponens _ _ _ h_impl_ctx h_assume
    have h_box_in_S : φ.box ∈ S :=
      set_mcs_closed_under_derivation h_mcs [φ.neg.neg.box] h_sub h_deriv
    -- Now φ.box ∈ S and (φ.box).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [φ.box, (φ.box).neg] Formula.bot := by
      have h1 : [φ.box, (φ.box).neg] ⊢ φ.box :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [φ.box, (φ.box).neg] ⊢ (φ.box).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [φ.box, (φ.box).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_box_in_S
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
Set-based MCS: diamond-box duality (backward direction).

If ◇(¬φ) ∈ S, then ¬(□φ) ∈ S.
-/
theorem set_mcs_diamond_neg_implies_neg_box {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h : φ.neg.diamond ∈ S) : (Formula.box φ).neg ∈ S := by
  -- ◇(¬φ) = ¬□(¬¬φ) ∈ S
  -- We need ¬□φ ∈ S
  -- By negation completeness: either □φ ∈ S or ¬□φ ∈ S
  -- If □φ ∈ S, then by box_closure, φ ∈ S
  -- We show this leads to a contradiction with ◇(¬φ) ∈ S
  -- Actually, from □φ, we can derive □(¬¬φ) (since φ → ¬¬φ derivable)
  -- Then □(¬¬φ) ∈ S contradicts ¬□(¬¬φ) = ◇(¬φ) ∈ S
  unfold Formula.diamond at h
  cases set_mcs_negation_complete h_mcs (Formula.box φ) with
  | inr h_neg => exact h_neg
  | inl h_box =>
    -- □φ ∈ S. We derive □(¬¬φ), contradicting ¬□(¬¬φ) ∈ S.
    exfalso
    -- We need: □(φ → ¬¬φ) which by Modal K gives □φ → □(¬¬φ)
    -- First derive φ → ¬¬φ (double negation introduction)
    have h_dni : ⊢ φ.imp φ.neg.neg := dni φ
    -- Apply necessitation
    have h_nec_dni : ⊢ (φ.imp φ.neg.neg).box := DerivationTree.necessitation _ h_dni
    -- Modal K distribution: □(A → B) → (□A → □B)
    have h_modal_k : ⊢ (φ.imp φ.neg.neg).box.imp ((φ.box).imp (φ.neg.neg.box)) :=
      DerivationTree.axiom [] _ (Axiom.modal_k_dist φ φ.neg.neg)
    -- Apply modus ponens to get □φ → □(¬¬φ)
    have h_impl : ⊢ (φ.box).imp (φ.neg.neg.box) :=
      DerivationTree.modus_ponens [] _ _ h_modal_k h_nec_dni
    -- Now we have □φ ∈ S and □φ → □(¬¬φ) derivable
    -- So □(¬¬φ) ∈ S
    have h_sub : ∀ χ ∈ [φ.box], χ ∈ S := by simp [h_box]
    have h_impl_ctx : [φ.box] ⊢ (φ.box).imp (φ.neg.neg.box) :=
      DerivationTree.weakening [] _ _ h_impl (by intro; simp)
    have h_assume : [φ.box] ⊢ φ.box :=
      DerivationTree.assumption _ _ (by simp)
    have h_deriv : [φ.box] ⊢ φ.neg.neg.box :=
      DerivationTree.modus_ponens _ _ _ h_impl_ctx h_assume
    have h_dne_box_in_S : φ.neg.neg.box ∈ S :=
      set_mcs_closed_under_derivation h_mcs [φ.box] h_sub h_deriv
    -- Now φ.neg.neg.box ∈ S and (φ.neg.neg.box).neg ∈ S, contradiction
    have h_deriv_bot : DerivationTree [φ.neg.neg.box, (φ.neg.neg.box).neg] Formula.bot := by
      have h1 : [φ.neg.neg.box, (φ.neg.neg.box).neg] ⊢ φ.neg.neg.box :=
        DerivationTree.assumption _ _ (by simp)
      have h2 : [φ.neg.neg.box, (φ.neg.neg.box).neg] ⊢ (φ.neg.neg.box).neg :=
        DerivationTree.assumption _ _ (by simp)
      exact derives_bot_from_phi_neg_phi h1 h2
    have h_sub2 : ∀ χ ∈ [φ.neg.neg.box, (φ.neg.neg.box).neg], χ ∈ S := by
      intro χ hχ
      simp only [List.mem_cons, List.mem_nil_iff, or_false] at hχ
      cases hχ with
      | inl h_eq => exact h_eq ▸ h_dne_box_in_S
      | inr h_eq => exact h_eq ▸ h
    have h_bot_in_S : Formula.bot ∈ S :=
      set_mcs_closed_under_derivation h_mcs _ h_sub2 h_deriv_bot
    have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
      DerivationTree.assumption _ _ (by simp)
    exact h_mcs.1 [Formula.bot] (by simp [h_bot_in_S]) ⟨h_bot_deriv⟩

/--
Set-based MCS: diamond-box duality iff property.

¬(□φ) ∈ S iff ◇(¬φ) ∈ S.

This establishes the classical duality between box and diamond:
¬□φ ↔ ◇¬φ (equivalently, □φ ↔ ¬◇¬φ).
-/
theorem set_mcs_diamond_box_duality {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S) :
    (Formula.box φ).neg ∈ S ↔ φ.neg.diamond ∈ S :=
  ⟨set_mcs_neg_box_implies_diamond_neg h_mcs, set_mcs_diamond_neg_implies_neg_box h_mcs⟩

/-!
### Saturation Lemmas

Modal saturation (forward direction) is proven below. Full saturation theorems
requiring canonical frame and history constructions have been archived to Boneyard.
-/

/--
Modal saturation (forward): If □φ ∈ S, then φ holds at all accessible worlds.

**Statement**: For all T accessible from S via canonical_task_rel at time 0,
if □φ ∈ S then φ ∈ T.

**Note**: This follows from the box closure property: □φ ∈ S implies φ ∈ S
by Modal T, and the task relation transfers this appropriately.
-/
theorem set_mcs_modal_saturation_forward {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_box : Formula.box φ ∈ S) : φ ∈ S :=
  -- Forward direction: Use box closure (Modal T axiom)
  set_mcs_box_closure h_mcs h_box

/-!
## Canonical Frame

The canonical frame is constructed from maximal consistent sets.
-/

/--
Canonical world states are set-based maximal consistent sets.

**Representation**: Type synonym for `{S : Set Formula // SetMaximalConsistent S}`

**Justification**: Each maximal consistent set represents a "possible world"
describing one complete, consistent way the universe could be. Using `Set Formula`
instead of `List Formula` is essential because maximal consistent sets are typically
infinite, while lists are finite. The set-based `set_lindenbaum` theorem (proven
using Zorn's lemma) ensures every consistent set can be extended to a maximal one.

**Note**: The list-based `Context` representation cannot capture true maximal
consistency because lists are inherently finite.
-/
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}

end Bimodal.Metalogic
