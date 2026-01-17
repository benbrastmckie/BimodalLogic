import Bimodal.ProofSystem.Derivation
import Bimodal.Semantics.Validity
import Bimodal.Metalogic_v2.Soundness.SoundnessLemmas

/-!
# Soundness - Soundness Theorem for TM Logic (Metalogic_v2)

This module proves the soundness theorem for bimodal logic TM.

## Overview

This is part of the Metalogic_v2 reorganization that establishes a
representation-first architecture with the Finite Model Property (FMP)
as the central bridge theorem.

## Main Results

- `soundness`: Derivability implies semantic validity (`Γ ⊢ φ → Γ ⊨ φ`)
- All 15 TM axioms proven valid

## Implementation Notes

**Completed Proofs**:
- 15/15 axiom validity lemmas
- 7/7 soundness cases: axiom, assumption, modus_ponens, necessitation, temporal_necessitation,
  temporal_duality, weakening

**Key Techniques**:
- Time-shift invariance (MF, TF): Uses `WorldHistory.time_shift` and
  `TimeShift.time_shift_preserves_truth` to relate truth at different times
- Classical logic helpers for conjunction extraction (TL)
- Derivation-indexed induction for temporal duality soundness

## References

* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
* [Validity.lean](../../Semantics/Validity.lean) - Semantic validity
-/

namespace Bimodal.Metalogic_v2.Soundness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/-! ## Classical Logic Helper -/

/-- Helper lemma for extracting conjunction from negated implication encoding. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/--
Propositional K axiom is valid: `⊨ (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`.
-/
theorem prop_k_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/--
Propositional S axiom is valid: `⊨ φ → (ψ → φ)`.
-/
theorem prop_s_valid (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_phi _
  exact h_phi

/--
Modal T axiom is valid: `⊨ □φ → φ`.
-/
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_box
  exact h_box τ

/--
Modal 4 axiom is valid: `⊨ □φ → □□φ`.
-/
theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_box σ ρ
  exact h_box ρ

/--
Modal B axiom is valid: `⊨ φ → □◇φ`.
-/
theorem modal_b_valid (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_phi σ
  unfold Formula.diamond truth_at
  intro h_box_neg
  have h_neg_at_tau := h_box_neg τ
  unfold Formula.neg truth_at at h_neg_at_tau
  exact h_neg_at_tau h_phi

/--
Modal 5 Collapse axiom is valid: `⊨ ◇□φ → □φ`.
-/
theorem modal_5_collapse_valid (φ : Formula) : ⊨ (φ.box.diamond.imp φ.box) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_diamond_box ρ
  unfold Formula.diamond at h_diamond_box
  unfold truth_at at h_diamond_box
  by_contra h_not_phi
  apply h_diamond_box
  intro σ
  unfold Formula.neg truth_at
  intro h_box_at_sigma
  have h_phi_at_rho := h_box_at_sigma ρ
  exact h_not_phi h_phi_at_rho

/--
EFQ axiom is valid: `⊨ ⊥ → φ`.
-/
theorem ex_falso_valid (φ : Formula) : ⊨ (Formula.bot.imp φ) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_bot
  exfalso
  exact h_bot

/--
Peirce's Law is valid: `⊨ ((φ → ψ) → φ) → φ`.
-/
theorem peirce_valid (φ ψ : Formula) : ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_peirce
  by_cases h : truth_at M τ t φ
  · exact h
  · have h_imp : truth_at M τ t (φ.imp ψ) := by
      unfold truth_at
      intro h_phi
      exfalso
      exact h h_phi
    exact h_peirce h_imp

/--
Modal K Distribution axiom is valid: `⊨ □(φ → ψ) → (□φ → □ψ)`.
-/
theorem modal_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_box_imp h_box_phi σ
  have h_imp_at_σ := h_box_imp σ
  have h_phi_at_σ := h_box_phi σ
  unfold truth_at at h_imp_at_σ
  exact h_imp_at_σ h_phi_at_σ

/--
Temporal K Distribution axiom is valid: `⊨ F(φ → ψ) → (Fφ → Fψ)`.
-/
theorem temp_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_future_imp h_future_phi s hts
  have h_imp_at_s := h_future_imp s hts
  have h_phi_at_s := h_future_phi s hts
  unfold truth_at at h_imp_at_s
  exact h_imp_at_s h_phi_at_s

/--
Temporal 4 axiom is valid: `⊨ Fφ → FFφ`.
-/
theorem temp_4_valid (φ : Formula) : ⊨ ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_future s hts r hsr
  have htr : t < r := lt_trans hts hsr
  exact h_future r htr

/--
Temporal A axiom is valid: `⊨ φ → F(sometime_past φ)`.
-/
theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_future φ.sometime_past)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_phi s hts
  unfold Formula.sometime_past Formula.some_past Formula.neg truth_at
  intro h_all_neg
  have h_neg_at_t := h_all_neg t hts
  unfold truth_at at h_neg_at_t
  exact h_neg_at_t h_phi

/--
TL axiom validity: `△φ → F(Pφ)` is valid in all task semantic models.
-/
theorem temp_l_valid (φ : Formula) :
    ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_always s hts r hrs
  simp only [Formula.always, Formula.and, Formula.neg, truth_at] at h_always
  have h1 :
    (∀ (u : T), u < t → truth_at M τ u φ) ∧
    ((truth_at M τ t φ →
      (∀ (v : T), t < v → truth_at M τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : truth_at M τ t φ ∧ (∀ (v : T), t < v → truth_at M τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2
  rcases lt_trichotomy r t with h_lt | h_eq | h_gt
  · exact h_past r h_lt
  · subst h_eq; exact h_now
  · exact h_future r h_gt

/--
MF axiom validity: `□φ → □(Fφ)` is valid in all task semantic models.
-/
theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.all_future).box)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_box_phi σ s hts
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t))
  have h_preserve := TimeShift.time_shift_preserves_truth M σ t s φ
  exact h_preserve.mp h_phi_at_shifted

/--
TF axiom validity: `□φ → F(□φ)` is valid in all task semantic models.
-/
theorem temp_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.box).all_future)) := by
  intro T _ _ _ F M τ t
  unfold truth_at
  intro h_box_phi s hts σ
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t))
  have h_preserve := TimeShift.time_shift_preserves_truth M σ t s φ
  exact h_preserve.mp h_phi_at_shifted

/--
All TM axioms are valid.
-/
theorem axiom_valid {φ : Formula} : Axiom φ → ⊨ φ := by
  intro h_axiom
  cases h_axiom with
  | prop_k φ ψ χ => exact prop_k_valid φ ψ χ
  | prop_s φ ψ => exact prop_s_valid φ ψ
  | modal_t ψ => exact modal_t_valid ψ
  | modal_4 ψ => exact modal_4_valid ψ
  | modal_b ψ => exact modal_b_valid ψ
  | modal_5_collapse ψ => exact modal_5_collapse_valid ψ
  | ex_falso ψ => exact ex_falso_valid ψ
  | peirce φ ψ => exact peirce_valid φ ψ
  | modal_k_dist φ ψ => exact modal_k_dist_valid φ ψ
  | temp_k_dist φ ψ => exact temp_k_dist_valid φ ψ
  | temp_4 ψ => exact temp_4_valid ψ
  | temp_a ψ => exact temp_a_valid ψ
  | temp_l ψ => exact temp_l_valid ψ
  | modal_future ψ => exact modal_future_valid ψ
  | temp_future ψ => exact temp_future_valid ψ

/--
Soundness theorem: Derivability implies semantic validity.

If `Γ ⊢ φ` (φ is derivable from context Γ), then `Γ ⊨ φ` (φ is a semantic consequence of Γ).
-/
theorem soundness (Γ : Context) (φ : Formula) : (Γ ⊢ φ) → (Γ ⊨ φ) := by
  intro h_deriv
  induction h_deriv with
  | «axiom» Γ' φ' h_ax =>
    intro T _ _ _ F M τ t _
    exact axiom_valid h_ax T F M τ t

  | @assumption Γ' φ' h_mem =>
    intro T _ _ _ F M τ t h_all
    exact h_all φ' h_mem

  | @modus_ponens Γ' φ' ψ' _ _ ih_imp ih_phi =>
    intro T _ _ _ F M τ t h_all
    have h_imp := ih_imp T F M τ t h_all
    have h_phi := ih_phi T F M τ t h_all
    unfold truth_at at h_imp
    exact h_imp h_phi

  | @necessitation φ' h_deriv ih =>
    intro T _ _ _ F M τ t _
    unfold truth_at
    intro σ
    exact ih T F M σ t (fun _ h => False.elim (List.not_mem_nil h))

  | @temporal_necessitation φ' h_deriv ih =>
    intro T _ _ _ F M τ t _
    unfold truth_at
    intro s hts
    exact ih T F M τ s (fun _ h => False.elim (List.not_mem_nil h))

  | @temporal_duality φ' h_deriv_phi _ =>
    intro T _ _ _ F M τ t _
    have h_swap_valid := @SoundnessLemmas.derivable_implies_swap_valid T _ _ _ _ h_deriv_phi
    exact h_swap_valid F M τ t

  | @weakening Γ' Δ' φ' _ h_sub ih =>
    intro T _ _ _ F M τ t h_all
    apply ih T F M τ t
    intro ψ h_mem
    exact h_all ψ (h_sub h_mem)

end Bimodal.Metalogic_v2.Soundness
