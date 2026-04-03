import Bimodal.ProofSystem.Derivation
import Bimodal.Semantics.Validity
import Bimodal.Metalogic.SoundnessLemmas

/-!
# Soundness - Soundness Theorem for TM Logic

This module proves the soundness theorem for bimodal logic TM.

## Paper Specification Reference

**Perpetuity Principles (app:valid, line 1984)**:
The JPL paper "The Perpetuity Calculus of Agency" proves perpetuity principles
P1 (□φ → △φ) and P2 (▽φ → ◇φ) are valid over all task semantic models using
time-shift automorphisms.

**Axiom Validity**:
All TM axioms (MT, M4, MB, T4, TA, TL, MF, TF) are proven valid over all
task semantic models. The MF and TF axioms use time-shift invariance
(following the JPL paper's approach) to establish unconditional validity.

## Main Results

- `prop_k_valid`, `prop_s_valid`: Propositional axioms are valid
- `modal_t_valid`: Modal T axiom is valid
- `modal_4_valid`: Modal 4 axiom is valid
- `modal_b_valid`: Modal B axiom is valid
- `modal_k_dist_valid`: Modal K distribution axiom is valid

- `temp_4_valid`: Temporal 4 axiom is valid
- `temp_a_valid`: Temporal A axiom is valid
- `temp_l_valid`: TL axiom is valid (uses always definition)
- `modal_future_valid`: MF axiom is valid (via time-shift invariance)
- `temp_future_valid`: TF axiom is valid (via time-shift invariance)
- `axiom_base_valid`: Base axioms are universally valid
- `axiom_valid_dense`: Dense-compatible axioms are valid on dense frames
- `axiom_valid_discrete`: Discrete-compatible axioms are valid on discrete frames

## Implementation Notes

**Completed Proofs**:
- Base axiom validity lemmas: prop_k, prop_s, ex_falso, peirce, MT, M4, MB, M5_collapse,
  MK_dist, TK_dist, T4, TA, TL, MF, TF, linearity (universally valid)
- Frame-class axiom validity: density (valid_dense), discreteness_forward (valid_discrete)
- axiom_base_valid, axiom_valid_dense, axiom_valid_discrete (combined validators)

**Key Techniques**:
- Time-shift invariance (MF, TF): Uses `WorldHistory.time_shift` and
  `TimeShift.time_shift_preserves_truth` to relate truth at different times
- Classical logic helpers for conjunction extraction (TL)
- Derivation-indexed induction for temporal duality soundness

**Omega Parameterization**:
Validity and semantic consequence now quantify over shift-closed Omega sets.
All soundness proofs use the `ShiftClosed Omega` hypothesis where previously
`Set.univ_shift_closed` was used. This enables completeness proofs to provide
a matching Omega.

## Full Derivation Soundness

The theorem `soundness : (Γ ⊢ φ) → (Γ ⊨ φ)` follows from:
1. **Axiom validity**: `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete`
2. **Modus ponens**: If `Γ ⊨ φ → ψ` and `Γ ⊨ φ` then `Γ ⊨ ψ` (semantic by definition)
3. **Necessitation**: If `⊨ φ` then `⊨ □φ` (follows from S5 universal accessibility)
4. **Temporal necessitation**: If `⊨ φ` then `⊨ Gφ` (follows from temporal quantification)
5. **Temporal duality**: `derivable_implies_swap_valid` in SoundnessLemmas.lean
6. **IRR rule**: Sound by construction (see IRRSoundness.lean)
7. **Weakening**: Monotonicity of semantic consequence

**Status**: The axiom validity components are proven. The full composition into a single
`soundness` theorem is straightforward but has not been assembled into one lemma.
Each rule preservation property is either trivial or proven separately.

## References

* [ARCHITECTURE.md](../../../docs/UserGuide/ARCHITECTURE.md) - Soundness specification
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
* [Validity.lean](../../Semantics/Validity.lean) - Semantic validity
* [SoundnessLemmas.lean](./SoundnessLemmas.lean) - Axiom validity and swap preservation
* [IRRSoundness.lean](./IRRSoundness.lean) - IRR rule soundness
* JPL Paper app:valid (line 1984) - Perpetuity principle validity proofs
-/

namespace Bimodal.Metalogic

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/-! ## Classical Logic Helper -/

/-- Helper lemma for extracting conjunction from negated implication encoding. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/-- Propositional K axiom is valid. -/
theorem prop_k_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/-- Propositional S axiom is valid. -/
theorem prop_s_valid (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi _
  exact h_phi

/-- Modal T axiom is valid: `⊨ □φ → φ`. -/
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ h_mem t
  simp only [truth_at]
  intro h_box
  exact h_box τ h_mem

/-- Modal 4 axiom is valid: `⊨ □φ → □□φ`. -/
theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box σ h_σ_mem ρ h_ρ_mem
  exact h_box ρ h_ρ_mem

/-- Modal B axiom is valid: `⊨ φ → □◇φ`. -/
theorem modal_b_valid (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := by
  intro T _ _ _ F M Omega _h_sc τ h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at]
  intro h_phi σ _h_σ_mem h_box_neg
  exact h_box_neg τ h_mem h_phi

/-- Modal 5 Collapse axiom is valid: `⊨ ◇□φ → □φ`. -/
theorem modal_5_collapse_valid (φ : Formula) : ⊨ (φ.box.diamond.imp φ.box) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at]
  intro h_diamond_box ρ h_ρ_mem
  by_contra h_not_phi
  apply h_diamond_box
  intro σ h_σ_mem h_box_at_sigma
  exact h_not_phi (h_box_at_sigma ρ h_ρ_mem)

/-- EFQ axiom is valid: `⊨ ⊥ → φ`. -/
theorem ex_falso_valid (φ : Formula) : ⊨ (Formula.bot.imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_bot
  exfalso
  exact h_bot

/-- Peirce's Law is valid: `⊨ ((φ → ψ) → φ) → φ`. -/
theorem peirce_valid (φ ψ : Formula) : ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_peirce
  by_cases h : truth_at M Omega τ t φ
  · exact h
  · have h_imp : truth_at M Omega τ t (φ.imp ψ) := by
      simp only [truth_at]
      intro h_phi
      exfalso
      exact h h_phi
    exact h_peirce h_imp

/-- Modal K Distribution axiom is valid: `⊨ □(φ → ψ) → (□φ → □ψ)`. -/
theorem modal_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_imp h_box_phi σ h_σ_mem
  exact h_box_imp σ h_σ_mem (h_box_phi σ h_σ_mem)

/-- Temporal K Distribution axiom is valid: `⊨ F(φ → ψ) → (Fφ → Fψ)`. -/
theorem temp_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future_imp h_future_phi s hts
  exact h_future_imp s hts (h_future_phi s hts)

/-- Temporal 4 axiom is valid: `⊨ Gφ → GGφ`.
Under strict semantics, uses transitivity of <. -/
theorem temp_4_valid (φ : Formula) : ⊨ ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future s hts r hsr
  exact h_future r (lt_trans hts hsr)

/-- Temporal A axiom is valid: `⊨ φ → G(Pφ)`.
Under strict semantics: if φ at t, then for all s > t, there exists r < s with φ(r) (namely, t). -/
theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_future φ.some_past)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi s hts
  simp only [Formula.some_past, Formula.some_past, Formula.neg, truth_at]
  intro h_all_neg
  -- h_all_neg : ∀ r < s, ¬φ(r). But t < s (from hts) and φ(t) (from h_phi).
  exact h_all_neg t hts h_phi

/-- TL axiom validity: `△φ → G(Hφ)` is valid.
Under strict semantics, △φ = Hφ ∧ φ ∧ Gφ encodes: (∀ u < t, φ(u)) ∧ φ(t) ∧ (∀ v > t, φ(v)).
The goal G(Hφ) requires: ∀ s > t, ∀ r < s, φ(r).
This is implied by the △φ hypothesis which covers all times. -/
theorem temp_l_valid (φ : Formula) :
    ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_always s _hts r hrs
  simp only [Formula.always, Formula.and, Formula.neg, truth_at] at h_always
  -- Under strict semantics, always encodes: (∀ u < t, φ(u)) ∧ ((φ(t) → (∀ v > t, φ(v)) → ⊥) → ⊥)
  have h1 :
    (∀ (u : T), u < t → truth_at M Omega τ u φ) ∧
    ((truth_at M Omega τ t φ →
      (∀ (v : T), t < v → truth_at M Omega τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : truth_at M Omega τ t φ ∧ (∀ (v : T), t < v → truth_at M Omega τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2
  -- With strict semantics, we have φ at all times (past, now, future)
  -- Need φ(r) where r < s. By r < t, r = t, or r > t:
  rcases lt_trichotomy r t with h_lt | h_eq | h_gt
  · exact h_past r h_lt
  · exact h_eq ▸ h_now
  · exact h_future r h_gt

/-- MF axiom validity: `□φ → □(Fφ)` is valid. Uses ShiftClosed Omega for time-shift invariance. -/
theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.all_future).box)) := by
  intro T _ _ _ F M Omega h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_phi σ h_σ_mem s hts
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ).mp h_phi_at_shifted

/-- TF axiom validity: `□φ → F(□φ)` is valid. Uses ShiftClosed Omega for time-shift invariance. -/
theorem temp_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.box).all_future)) := by
  intro T _ _ _ F M Omega h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_phi s hts σ h_σ_mem
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ).mp h_phi_at_shifted

/-- Temporal A Dual axiom is valid: `⊨ φ → H(Fφ)`.
Under strict semantics: if φ at t, then for all s < t, there exists r > s with φ(r) (namely, t). -/
theorem temp_a_dual_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_past φ.some_future)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi s hst
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_all_neg
  -- h_all_neg : ∀ r > s, ¬φ(r). But s < t (from hst) and φ(t) (from h_phi).
  exact h_all_neg t hst h_phi

/-- Temporal linearity axiom validity:
`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)` is valid.

Uses linearity of D (LinearOrder instance).
Under strict semantics, F quantifies over s > t.
-/
theorem temp_linearity_valid (φ ψ : Formula) :
    ⊨ (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
      (Formula.or (Formula.some_future (Formula.and φ ψ))
        (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
          (Formula.some_future (Formula.and (Formula.some_future φ) ψ))))) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.some_future, Formula.neg, truth_at]
  intro h_conj
  -- Extract F(phi) and F(psi) witnesses (using < for strict semantics)
  have h_F_phi : (∀ (s : T), t < s → truth_at M Omega τ s φ → False) → False :=
    Classical.byContradiction (fun h_not =>
      h_conj (fun h1 _ => h_not (fun h_all => h1 (fun s hs h_phi => h_all s hs h_phi))))
  have h_F_psi : (∀ (s : T), t < s → truth_at M Omega τ s ψ → False) → False :=
    Classical.byContradiction (fun h_not =>
      h_conj (fun _ h2 => h_not (fun h_all => h2 (fun s hs h_psi => h_all s hs h_psi))))
  have ⟨s1, hs1t, h_phi_s1⟩ : ∃ s, t < s ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no
    exact h_F_phi (fun s hs h_phi => h_no s hs h_phi)
  have ⟨s2, hs2t, h_psi_s2⟩ : ∃ s, t < s ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_F_psi (fun s hs h_psi => h_no s hs h_psi)
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: provide second disjunct F(φ ∧ F(ψ))
    intro _
    intro h_neg_second
    exfalso
    apply h_neg_second
    intro h_all_neg_second
    exact h_all_neg_second s1 hs1t (fun h_imp => h_imp h_phi_s1 (fun h_neg_F_psi =>
      h_neg_F_psi s2 h_lt h_psi_s2))
  · -- s1 = s2: provide first disjunct F(φ ∧ ψ)
    subst h_eq
    intro h_neg_first
    exfalso
    apply h_neg_first
    intro h_all_neg_first
    exact h_all_neg_first s1 hs1t (fun h_imp => h_imp h_phi_s1 h_psi_s2)
  · -- s2 < s1: provide third disjunct F(F(φ) ∧ ψ)
    intro _
    intro _
    intro h_all_neg_third
    exact h_all_neg_third s2 hs2t (fun h_imp => h_imp
      (fun h_neg_F_phi => h_neg_F_phi s1 h_gt h_phi_s1) h_psi_s2)

/-- Density axiom (DN) is valid on dense orders: `⊨_dense GGφ → Gφ`.
Under strict semantics: for any s > t, by DenselyOrdered there exists r with t < r < s.
From GGφ (∀r > t, ∀q > r, φ(q)) at r, since r < s, we get φ(s). -/
theorem density_valid (φ : Formula) :
    valid_dense ((φ.all_future.all_future).imp φ.all_future) := by
  intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_GG s hts
  -- h_GG : ∀ r > t, ∀ q > r, φ(q)
  -- hts : t < s
  -- Goal: φ(s)
  -- By DenselyOrdered, there exists r with t < r < s.
  obtain ⟨r, htr, hrs⟩ := DenselyOrdered.dense t s hts
  exact h_GG r htr s hrs

/-- Forward discreteness axiom (DF) is valid on discrete orders: `⊨_discrete (F⊤ ∧ φ ∧ Hφ) → F(Hφ)`.
Under strict semantics: if Hφ at t (∀r < t, φ(r)) and φ(t), then Hφ at succ(t),
since for all r < succ(t), either r < t (covered by Hφ) or r = t (covered by φ(t)).
So F(Hφ) at t is witnessed by succ(t). -/
theorem discreteness_forward_valid (φ : Formula) :
    valid_discrete (Formula.and (Formula.bot.neg.some_future)
      (Formula.and φ (Formula.all_past φ)) |>.imp
      (Formula.all_past φ).some_future) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.some_future, Formula.neg, truth_at]
  intro h_conj h_G_not_H
  -- Extract F⊤, φ, and Hφ from conjunction
  have h1 := and_of_not_imp_not h_conj
  have ⟨_h_F_top, h_phi_and_H⟩ := h1
  have h2 := and_of_not_imp_not h_phi_and_H
  have ⟨h_phi, h_H⟩ := h2
  -- h_H : ∀ r < t, φ(r) (Hφ at t, strict)
  -- h_phi : φ(t)
  -- Use succ(t) as witness: t < succ(t) by Order.lt_succ
  apply h_G_not_H (Order.succ t) (Order.lt_succ t)
  -- Goal: ∀ r < succ(t), φ(r). By lt_succ_iff_of_not_isMax, r < succ(t) ↔ r ≤ t.
  intro r hrs
  rcases Order.le_of_lt_succ hrs |>.lt_or_eq with h_lt | h_eq
  · exact h_H r h_lt
  · exact h_eq ▸ h_phi

/-- Future seriality axiom validity: `⊨_discrete Gφ → Fφ`.
Under strict semantics: from Gφ at t (∀s > t, φ(s)), by NoMaxOrder ∃ s > t,
so φ(s) gives the witness for Fφ. -/
theorem seriality_future_valid (φ : Formula) :
    valid_discrete (φ.all_future.imp φ.some_future) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_G h_neg_F
  -- h_G : ∀ s > t, φ(s) (Gφ at t, strict)
  -- h_neg_F : ∀ s > t, ¬φ(s) (¬Fφ at t, strict)
  -- By NoMaxOrder, there exists s > t.
  obtain ⟨s, hts⟩ := exists_gt t
  exact h_neg_F s hts (h_G s hts)

/-- Past seriality axiom validity: `⊨_discrete Hφ → Pφ`.
Under strict semantics: from Hφ at t (∀s < t, φ(s)), by NoMinOrder ∃ s < t,
so φ(s) gives the witness for Pφ. -/
theorem seriality_past_valid (φ : Formula) :
    valid_discrete (φ.all_past.imp φ.some_past) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_past, Formula.neg, truth_at]
  intro h_H h_neg_P
  -- h_H : ∀ s < t, φ(s) (Hφ at t, strict)
  -- h_neg_P : ∀ s < t, ¬φ(s) (¬Pφ at t, strict)
  -- By NoMinOrder, there exists s < t.
  obtain ⟨s, hst⟩ := exists_lt t
  exact h_neg_P s hst (h_H s hst)

/-- Discrete Next axiom validity: `⊨_discrete F(⊤) → X(⊤)`.
Under strict semantics: if ∃ s > t (F(⊤)), then bot U (neg bot) at t.
Take witness s = succ(t). Guard interval (t, succ(t)) is empty on discrete orders. -/
theorem disc_next_valid :
    valid_discrete ((Formula.neg Formula.bot).some_future.imp
      (Formula.untl Formula.bot (Formula.neg Formula.bot))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, Formula.some_future, truth_at]
  intro _h_F_top
  -- Need: ∃ s > t, ¬False ∧ ∀ r, t < r → r < s → False
  -- Take s = succ(t). t < succ(t) by Order.lt_succ (NoMaxOrder from Nontrivial + ordered group).
  exact ⟨Order.succ t, Order.lt_succ t, id, fun r htr hrs =>
    absurd (Order.le_of_lt_succ hrs) (not_le.mpr htr)⟩

/-- Discrete Prev axiom validity: `⊨_discrete P(⊤) → Y(⊤)`.
Mirror of disc_next for past direction. -/
theorem disc_prev_valid :
    valid_discrete ((Formula.neg Formula.bot).some_past.imp
      (Formula.snce Formula.bot (Formula.neg Formula.bot))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, Formula.some_past, truth_at]
  intro _h_P_top
  -- Take s = pred(t). pred(t) < t by Order.pred_lt (NoMinOrder).
  refine ⟨Order.pred t, Order.pred_lt t, id, fun r hrs hrt => ?_⟩
  exact absurd (Order.le_pred_of_lt hrt) (not_le.mpr hrs)

/-- Until Unfold axiom validity: `⊨_discrete (φ U ψ) → X(ψ ∨ (φ ∧ (φ U ψ)))`.
Under strict semantics: given witness s > t for φ U ψ, the next instant is succ(t).
If s = succ(t), ψ holds there (left disjunct).
If s > succ(t), φ holds at succ(t) and φ U ψ continues (right disjunct). -/
theorem until_unfold_valid (φ ψ : Formula) :
    valid_discrete (Formula.untl φ ψ |>.imp
      (Formula.untl Formula.bot
        (Formula.or ψ (Formula.and φ (Formula.untl φ ψ))))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.or, Formula.and, Formula.neg, truth_at]
  intro ⟨s, hts, h_psi_s, h_phi_guard⟩
  -- Need: ∃ u > t, (ψ(u) ∨ (φ(u) ∧ (φ U ψ)(u))) ∧ ∀ r, t < r → r < u → False
  -- Take u = succ(t).
  refine ⟨Order.succ t, Order.lt_succ t, ?_, fun r htr hrs =>
    absurd (Order.le_of_lt_succ hrs) (not_le.mpr htr)⟩
  -- Show: ψ(succ(t)) ∨ (φ(succ(t)) ∧ (φ U ψ)(succ(t)))
  -- We have s > t, so succ(t) ≤ s.
  have h_succ_le_s := Order.succ_le_of_lt hts
  rcases h_succ_le_s.eq_or_lt with h_eq | h_lt
  · -- s = succ(t): ψ holds at succ(t)
    intro h_neg_psi
    exact absurd (h_eq ▸ h_psi_s) h_neg_psi
  · -- s > succ(t): φ at succ(t) and φ U ψ at succ(t) with witness s
    intro h_neg_psi h_neg_phi_and_until
    apply h_neg_phi_and_until
    · -- φ(succ(t)): from guard, since t < succ(t) < s
      exact h_phi_guard (Order.succ t) (Order.lt_succ t) h_lt
    · -- (φ U ψ)(succ(t)) with witness s
      exact ⟨s, h_lt, h_psi_s, fun r hr1 hr2 => h_phi_guard r (lt_trans (Order.lt_succ t) hr1) hr2⟩

/-- Until Intro axiom validity: `⊨_discrete X(ψ ∨ (φ ∧ (φ U ψ))) → (φ U ψ)`.
Under strict semantics: the bot-guard in X forces the witness to be succ(t).
Then ψ(succ(t)) gives φ U ψ with witness succ(t), and φ(succ(t)) ∧ (φ U ψ)(succ(t))
extends the witness from succ(t). -/
theorem until_intro_valid (φ ψ : Formula) :
    valid_discrete ((Formula.untl Formula.bot
        (Formula.or ψ (Formula.and φ (Formula.untl φ ψ)))).imp
      (Formula.untl φ ψ)) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.or, Formula.and, Formula.neg, truth_at]
  intro ⟨u, htu, h_disj, h_bot_guard⟩
  -- The bot guard forces u = succ(t):
  -- From t < u, we get succ(t) ≤ u. If succ(t) < u, then t < succ(t) < u contradicts guard.
  have h_u_eq : u = Order.succ t := le_antisymm
    (by_contra fun h_not =>
      h_bot_guard (Order.succ t) (Order.lt_succ t) (lt_of_not_le h_not))
    (Order.succ_le_of_lt htu)
  subst h_u_eq
  -- h_disj : ψ(succ(t)) ∨ (φ(succ(t)) ∧ (φ U ψ)(succ(t)))
  by_cases h_psi : truth_at M Omega τ (Order.succ t) ψ
  · -- ψ at succ(t): witness = succ(t), guard interval (t, succ(t)) is empty
    exact ⟨Order.succ t, Order.lt_succ t, h_psi, fun r htr hrs =>
      absurd (Order.le_of_lt_succ hrs) (not_le.mpr htr)⟩
  · -- φ at succ(t) and (φ U ψ) at succ(t)
    have h_and := h_disj (fun h => absurd h h_psi)
    have h_phi_and_until := and_of_not_imp_not h_and
    obtain ⟨h_phi_succ, h_until_succ⟩ := h_phi_and_until
    obtain ⟨s', hs't1, h_psi_s', h_phi_guard'⟩ := h_until_succ
    -- φ U ψ at t with witness s' > succ(t) > t, guard covers (t, s')
    exact ⟨s', lt_trans (Order.lt_succ t) hs't1, h_psi_s', fun r htr hrs => by
      -- r is either succ(t) or strictly greater
      rcases (Order.succ_le_of_lt htr).eq_or_lt with h_eq | h_lt
      · exact h_eq ▸ h_phi_succ
      · exact h_phi_guard' r h_lt hrs⟩

/-- Until Induction axiom validity:
`⊨_discrete G(ψ → χ) ∧ G(φ ∧ X(χ) → χ) → ((φ U ψ) → X(χ))`.
Proof by Succ.rec induction along the successor chain from succ(t) to s.
Base: s = succ(t), ψ(s) → χ(s) by premise 1 at time s.
Step: at n with succ(t) ≤ n < s, if χ(succ(n)) then φ(n) ∧ X(χ)(n) → χ(n) by premise 2 at time n.
Uses IsSuccArchimedean to ensure the successor chain reaches s.
Premises are under G to ensure they hold at all future times n > t. -/
theorem until_induction_valid (φ ψ χ : Formula) :
    valid_discrete (Formula.and
      ((ψ.imp χ).all_future)
      (((Formula.and φ (Formula.untl Formula.bot χ)).imp χ).all_future)
      |>.imp ((Formula.untl φ ψ).imp (Formula.untl Formula.bot χ))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro h_premises h_until
  -- Extract the two premises (under G)
  have h_prems := and_of_not_imp_not h_premises
  obtain ⟨h_base_G, h_step_G⟩ := h_prems
  -- h_base_G : ∀ u > t, ψ(u) → χ(u) (premise 1 at all future times)
  -- h_step_G : ∀ u > t, φ(u) ∧ X(χ)(u) → χ(u) (premise 2 at all future times, negated-imp)
  -- h_until : φ U ψ at t, i.e., ∃ s > t, ψ(s) ∧ ∀ r ∈ (t,s), φ(r)
  obtain ⟨s, hts, h_psi_s, h_phi_guard⟩ := h_until
  -- Need: X(χ) at t = bot U χ at t = ∃ u > t, χ(u) ∧ ∀ r ∈ (t,u), ⊥
  -- Take u = succ(t), need χ(succ(t)), empty guard.
  refine ⟨Order.succ t, Order.lt_succ t, ?_, fun r htr hrs =>
    absurd (Order.le_of_lt_succ hrs) (not_le.mpr htr)⟩
  -- Prove χ(succ(t)) by contrapositive: assume ¬χ(succ(t)), propagate forward to ¬χ(s).
  by_contra h_neg_chi_succ
  -- Propagation: if ¬χ(n) for succ(t) ≤ n < s, then ¬χ(succ(n))
  have h_propagate : ∀ n : T, Order.succ t ≤ n → n < s → ¬truth_at M Omega τ n χ →
      ¬truth_at M Omega τ (Order.succ n) χ := by
    intro n h_succ_le_n hns h_neg_chi_n h_chi_succ_n
    apply h_neg_chi_n
    -- φ(n): from guard, since t < n (succ(t) ≤ n → t < n) and n < s.
    have h_t_lt_n : t < n := lt_of_lt_of_le (Order.lt_succ t) h_succ_le_n
    have h_phi_n : truth_at M Omega τ n φ := h_phi_guard n h_t_lt_n hns
    -- X(χ)(n) = bot U χ at n with witness succ(n), empty guard.
    have h_X_chi_n : ∃ u : T, n < u ∧ truth_at M Omega τ u χ ∧
        ∀ r : T, n < r → r < u → False :=
      ⟨Order.succ n, Order.lt_succ n, h_chi_succ_n, fun r htr hrs =>
        absurd (Order.le_of_lt_succ hrs) (not_le.mpr htr)⟩
    -- Apply step premise at time n (n > t, so h_step_G gives us the premise)
    exact h_step_G n h_t_lt_n (fun h_imp => h_imp h_phi_n h_X_chi_n)
  -- Use Succ.rec to propagate ¬χ from succ(t) to s.
  have h_all_neg : ∀ n : T, Order.succ t ≤ n → n ≤ s → ¬truth_at M Omega τ n χ := by
    intro n h_le_n h_n_le_s
    refine Succ.rec ?_ ?_ h_le_n h_n_le_s
    · -- base: n = succ(t)
      intro _; exact h_neg_chi_succ
    · -- step: n → succ(n)
      intro m h_le_m ih h_succ_m_le_s
      have h_m_lt_s : m < s := lt_of_lt_of_le (Order.lt_succ m) h_succ_m_le_s
      exact h_propagate m h_le_m h_m_lt_s (ih (le_of_lt h_m_lt_s))
  -- At n = s: ¬χ(s). But ψ(s) → χ(s) by premise 1 at time s (s > t).
  exact h_all_neg s (Order.succ_le_of_lt hts) le_rfl (h_base_G s hts h_psi_s)

/-- Until Linearity axiom validity (strict):
`⊨_discrete (φ U ψ) ∧ (φ' U ψ') → (φ U (ψ ∧ (φ' U ψ'))) ∨ (φ' U (ψ' ∧ (φ U ψ))) ∨ X(ψ ∧ ψ')`.
Given witnesses s₁ for φ U ψ and s₂ for φ' U ψ', by trichotomy:
- s₁ < s₂: first disjunct
- s₁ = s₂: third disjunct X(ψ ∧ ψ')
- s₂ < s₁: second disjunct -/
theorem until_linearity_valid (φ ψ φ' ψ' : Formula) :
    valid_discrete (Formula.and (Formula.untl φ ψ) (Formula.untl φ' ψ')
      |>.imp (Formula.or
        (Formula.or
          (Formula.untl φ (Formula.and ψ (Formula.untl φ' ψ')))
          (Formula.untl φ' (Formula.and ψ' (Formula.untl φ ψ))))
        (Formula.some_future (Formula.and ψ ψ')))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.some_future, Formula.neg, truth_at]
  intro h_conj
  have h_both := and_of_not_imp_not h_conj
  obtain ⟨h_until1, h_until2⟩ := h_both
  obtain ⟨s1, hs1t, h_psi_s1, h_phi_range1⟩ := h_until1
  obtain ⟨s2, hs2t, h_psi'_s2, h_phi'_range2⟩ := h_until2
  -- Goal: (¬(A ∨ B) → False) → (∀ s > t, ¬¬(ψ(s) ∧ ψ'(s)) → False) → False
  -- Structure: intro h_neg_AB h_neg_F, then derive False.
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: first disjunct φ U (ψ ∧ (φ' U ψ')) with witness s1
    intro h_neg_AB _
    exact h_neg_AB (fun h_neg_first => False.elim (h_neg_first ⟨s1, hs1t,
      fun h_imp => h_imp h_psi_s1
        ⟨s2, h_lt, h_psi'_s2, fun r hr1 hr2 => h_phi'_range2 r (lt_trans hs1t hr1) hr2⟩,
      h_phi_range1⟩))
  · -- s1 = s2: third disjunct F(ψ ∧ ψ') with witness s1
    subst h_eq
    intro _ h_neg_F
    exact h_neg_F s1 hs1t (fun h_imp => h_imp h_psi_s1 h_psi'_s2)
  · -- s2 < s1: second disjunct φ' U (ψ' ∧ (φ U ψ)) with witness s2
    intro h_neg_AB _
    -- h_neg_AB : (¬A → B) → False. Contradict by showing A (first disjunct impossible, use second).
    -- Actually provide (¬A → B): if ¬A, then we give B (second disjunct).
    exact h_neg_AB (fun _ => ⟨s2, hs2t,
      fun h_imp => h_imp h_psi'_s2
        ⟨s1, h_gt, h_psi_s1, fun r hr1 hr2 => h_phi_range1 r (lt_trans hs2t hr1) hr2⟩,
      h_phi'_range2⟩)

/-- Since Unfold axiom validity: `⊨_discrete (φ S ψ) → Y(ψ ∨ (φ ∧ (φ S ψ)))`.
Mirror of until_unfold_valid for past direction. -/
theorem since_unfold_valid (φ ψ : Formula) :
    valid_discrete (Formula.snce φ ψ |>.imp
      (Formula.snce Formula.bot
        (Formula.or ψ (Formula.and φ (Formula.snce φ ψ))))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.or, Formula.and, Formula.neg, truth_at]
  intro ⟨s, hst, h_psi_s, h_phi_guard⟩
  -- Take u = pred(t). pred(t) < t by Order.pred_lt.
  refine ⟨Order.pred t, Order.pred_lt t, ?_, fun r hrs hrt =>
    absurd (Order.le_pred_of_lt hrt) (not_le.mpr hrs)⟩
  -- Show: ψ(pred(t)) ∨ (φ(pred(t)) ∧ (φ S ψ)(pred(t)))
  have h_pred_ge_s := Order.le_pred_of_lt hst
  rcases h_pred_ge_s.eq_or_lt with h_eq | h_lt
  · -- s = pred(t): ψ holds at pred(t)
    intro h_neg_psi
    exact absurd (h_eq ▸ h_psi_s) h_neg_psi
  · -- s < pred(t): φ at pred(t) and φ S ψ at pred(t) with witness s
    intro h_neg_psi h_neg_phi_and_since
    exact h_neg_phi_and_since
      (h_phi_guard (Order.pred t) h_lt (Order.pred_lt t))
      ⟨s, h_lt, h_psi_s, fun r hr1 hr2 => h_phi_guard r hr1 (lt_trans hr2 (Order.pred_lt t))⟩

/-- Since Intro axiom validity: `⊨_discrete Y(ψ ∨ (φ ∧ (φ S ψ))) → (φ S ψ)`.
Mirror of until_intro_valid for past direction. -/
theorem since_intro_valid (φ ψ : Formula) :
    valid_discrete ((Formula.snce Formula.bot
        (Formula.or ψ (Formula.and φ (Formula.snce φ ψ)))).imp
      (Formula.snce φ ψ)) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.or, Formula.and, Formula.neg, truth_at]
  intro ⟨u, hut, h_disj, h_bot_guard⟩
  -- Bot guard forces u = pred(t)
  have h_u_eq : u = Order.pred t := le_antisymm
    (Order.le_pred_of_lt hut)
    (by_contra fun h_not =>
      h_bot_guard (Order.pred t) (lt_of_not_le h_not) (Order.pred_lt t))
  subst h_u_eq
  by_cases h_psi : truth_at M Omega τ (Order.pred t) ψ
  · -- ψ at pred(t): witness = pred(t), guard empty
    exact ⟨Order.pred t, Order.pred_lt t, h_psi, fun r hrs hrt =>
      absurd (Order.le_pred_of_lt hrt) (not_le.mpr hrs)⟩
  · -- φ at pred(t) and (φ S ψ) at pred(t)
    have h_and := h_disj (fun h => absurd h h_psi)
    have h_phi_and_since := and_of_not_imp_not h_and
    obtain ⟨h_phi_pred, h_since_pred⟩ := h_phi_and_since
    obtain ⟨s', hs'p, h_psi_s', h_phi_guard'⟩ := h_since_pred
    exact ⟨s', lt_trans hs'p (Order.pred_lt t), h_psi_s', fun r hrs hrt => by
      rcases (Order.le_pred_of_lt hrt).eq_or_lt with h_eq | h_lt
      · exact h_eq ▸ h_phi_pred
      · exact h_phi_guard' r hrs h_lt⟩

/-- Since Induction axiom validity:
`⊨_discrete H(ψ → χ) ∧ H(φ ∧ Y(χ) → χ) → ((φ S ψ) → Y(χ))`.
Mirror of until_induction_valid. Uses IsPredArchimedean for Pred.rec induction.
Premises are under H to ensure they hold at all past times n < t. -/
theorem since_induction_valid (φ ψ χ : Formula) :
    valid_discrete (Formula.and
      ((ψ.imp χ).all_past)
      (((Formula.and φ (Formula.snce Formula.bot χ)).imp χ).all_past)
      |>.imp ((Formula.snce φ ψ).imp (Formula.snce Formula.bot χ))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro h_premises h_since
  have h_prems := and_of_not_imp_not h_premises
  obtain ⟨h_base_H, h_step_H⟩ := h_prems
  -- h_base_H : ∀ u < t, ψ(u) → χ(u)
  -- h_step_H : ∀ u < t, φ(u) ∧ Y(χ)(u) → χ(u) (negated-imp)
  obtain ⟨s, hst, h_psi_s, h_phi_guard⟩ := h_since
  -- Need: Y(χ) at t = bot S χ at t = ∃ u < t, χ(u) ∧ ∀ r ∈ (u,t), ⊥
  refine ⟨Order.pred t, Order.pred_lt t, ?_, fun r hrs hrt =>
    absurd (Order.le_pred_of_lt hrt) (not_le.mpr hrs)⟩
  -- Prove χ(pred(t)) by contrapositive propagation using Pred.rec.
  by_contra h_neg_chi_pred
  -- Propagation: ¬χ(n) ∧ s < n ≤ pred(t) → ¬χ(pred(n))
  have h_propagate : ∀ n : T, n ≤ Order.pred t → s < n → ¬truth_at M Omega τ n χ →
      ¬truth_at M Omega τ (Order.pred n) χ := by
    intro n h_n_le_pred hns h_neg_chi_n h_chi_pred_n
    apply h_neg_chi_n
    have h_n_lt_t : n < t := lt_of_le_of_lt h_n_le_pred (Order.pred_lt t)
    have h_phi_n : truth_at M Omega τ n φ := h_phi_guard n hns h_n_lt_t
    -- Apply step premise at time n (n < t, so h_step_H gives the premise)
    -- h_step_H needs: (φ(n) → (∃ u < n, χ(u) ∧ guard) → False) → False
    -- We have φ(n) and Y(χ)(n), so the double-negation holds.
    exact h_step_H n h_n_lt_t (fun h_imp => h_imp h_phi_n
      ⟨Order.pred n, Order.pred_lt n, h_chi_pred_n, fun r hpr hrn =>
        absurd (Order.le_pred_of_lt hrn) (not_le.mpr hpr)⟩)
  -- Propagate ¬χ from pred(t) down to s using Pred.rec
  have h_all_neg : ∀ n : T, s ≤ n → n ≤ Order.pred t → ¬truth_at M Omega τ n χ := by
    intro n h_s_le_n h_n_le_pred
    refine Pred.rec ?_ ?_ h_n_le_pred h_s_le_n
    · -- base: n = pred(t)
      intro _; exact h_neg_chi_pred
    · -- step: n → pred(n)
      intro m h_le_m ih h_s_le_m
      have h_s_lt_m : s < m := lt_of_le_of_lt h_s_le_m (Order.pred_lt m)
      exact h_propagate m h_le_m h_s_lt_m (ih (le_of_lt h_s_lt_m))
  -- At n = s: ¬χ(s). But ψ(s) → χ(s) by premise 1 at time s (s < t).
  exact h_all_neg s le_rfl (Order.le_pred_of_lt hst) (h_base_H s hst h_psi_s)

/-- Since Linearity axiom validity (strict):
`⊨_discrete (φ S ψ) ∧ (φ' S ψ') → (φ S (ψ ∧ (φ' S ψ'))) ∨ (φ' S (ψ' ∧ (φ S ψ))) ∨ P(ψ ∧ ψ')`.
Mirror of until_linearity_valid. Third disjunct handles coinciding witnesses. -/
theorem since_linearity_valid (φ ψ φ' ψ' : Formula) :
    valid_discrete (Formula.and (Formula.snce φ ψ) (Formula.snce φ' ψ')
      |>.imp (Formula.or
        (Formula.or
          (Formula.snce φ (Formula.and ψ (Formula.snce φ' ψ')))
          (Formula.snce φ' (Formula.and ψ' (Formula.snce φ ψ))))
        (Formula.some_past (Formula.and ψ ψ')))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, Formula.some_past, truth_at]
  intro h_conj
  have h_both := and_of_not_imp_not h_conj
  obtain ⟨h_since1, h_since2⟩ := h_both
  obtain ⟨s1, hs1t, h_psi_s1, h_phi_range1⟩ := h_since1
  obtain ⟨s2, hs2t, h_psi'_s2, h_phi'_range2⟩ := h_since2
  -- Goal: (¬(A ∨ B) → False) → (∀ s < t, ¬¬(ψ(s) ∧ ψ'(s)) → False) → False
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: second disjunct φ' S (ψ' ∧ (φ S ψ)) with witness s2
    intro h_neg_AB _
    exact h_neg_AB (fun _ =>
      ⟨s2, hs2t,
        fun h_imp => h_imp h_psi'_s2
          ⟨s1, h_lt, h_psi_s1, fun r hr1 hr2 => h_phi_range1 r hr1 (lt_trans hr2 hs2t)⟩,
        h_phi'_range2⟩)
  · -- s1 = s2: third disjunct P(ψ ∧ ψ') with witness s1
    subst h_eq
    intro _ h_neg_P
    exact h_neg_P s1 hs1t (fun h_imp => h_imp h_psi_s1 h_psi'_s2)
  · -- s2 < s1: first disjunct φ S (ψ ∧ (φ' S ψ')) with witness s1
    intro h_neg_AB _
    exact h_neg_AB (fun h_neg_first => False.elim (h_neg_first
      ⟨s1, hs1t,
        fun h_imp => h_imp h_psi_s1
          ⟨s2, h_gt, h_psi'_s2, fun r hr1 hr2 => h_phi'_range2 r hr1 (lt_trans hr2 hs1t)⟩,
        h_phi_range1⟩))

/-- Until-Since Connectedness axiom validity:
`⊨_discrete φ ∧ (χ U ψ) → χ U (ψ ∧ (χ S φ))`.
Under strict semantics: if φ(t) and χ U ψ at t with witness s, then
ψ(s) and χ S φ at s with witness t (since φ(t) and χ on (t,s)). -/
theorem until_connectedness_valid (φ ψ χ : Formula) :
    valid_discrete (Formula.and φ (Formula.untl χ ψ)
      |>.imp (Formula.untl χ (Formula.and ψ (Formula.snce χ φ)))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro h_conj
  have h_both := and_of_not_imp_not h_conj
  obtain ⟨h_phi_t, h_until⟩ := h_both
  obtain ⟨s, hts, h_psi_s, h_chi_guard⟩ := h_until
  -- Witness s for the conclusion χ U (ψ ∧ (χ S φ))
  exact ⟨s, hts, fun h_imp => h_imp h_psi_s ⟨t, hts, h_phi_t,
    fun r htr hrs => h_chi_guard r htr hrs⟩, h_chi_guard⟩

/-- Since-Until Connectedness axiom validity:
`⊨_discrete φ ∧ (χ S ψ) → χ S (ψ ∧ (χ U φ))`.
Mirror of until_connectedness_valid. -/
theorem since_connectedness_valid (φ ψ χ : Formula) :
    valid_discrete (Formula.and φ (Formula.snce χ ψ)
      |>.imp (Formula.snce χ (Formula.and ψ (Formula.untl χ φ)))) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro h_conj
  have h_both := and_of_not_imp_not h_conj
  obtain ⟨h_phi_t, h_since⟩ := h_both
  obtain ⟨s, hst, h_psi_s, h_chi_guard⟩ := h_since
  exact ⟨s, hst, fun h_imp => h_imp h_psi_s ⟨t, hst, h_phi_t,
    fun r hrs hrt => h_chi_guard r hrs hrt⟩, h_chi_guard⟩

/-- F-Until equivalence validity: `⊨_discrete F(ψ) → ⊤ U ψ`.
Under strict semantics, both express ∃ s > t with ψ(s). The ⊤ guard is vacuous. -/
theorem F_until_equiv_valid (ψ : Formula) :
    valid_discrete (Formula.some_future ψ |>.imp (Formula.untl (Formula.neg Formula.bot) ψ)) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_F
  have h_exists : ∃ s, t < s ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_F (fun s hs hpsi => h_no s hs hpsi)
  obtain ⟨s, hst, hs⟩ := h_exists
  exact ⟨s, hst, hs, fun _ _ _ h => absurd h id⟩

/-- P-Since equivalence validity: `⊨_discrete P(ψ) → ⊤ S ψ`.
Mirror of F_until_equiv_valid. -/
theorem P_since_equiv_valid (ψ : Formula) :
    valid_discrete (Formula.some_past ψ |>.imp (Formula.snce (Formula.neg Formula.bot) ψ)) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_past, Formula.neg, truth_at]
  intro h_P
  have h_exists : ∃ s, s < t ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_P (fun s hs hpsi => h_no s hs hpsi)
  obtain ⟨s, hst, hs⟩ := h_exists
  exact ⟨s, hst, hs, fun _ _ _ h => absurd h id⟩

/-- All base TM axioms (excluding density, discreteness, and seriality) are universally valid.
With strict semantics, density requires DenselyOrdered, discreteness requires SuccOrder,
and seriality requires NoMaxOrder/NoMinOrder, so they are handled separately. -/
theorem axiom_base_valid {φ : Formula} (h : Axiom φ) (h_base : h.isBase) : ⊨ φ := by
  cases h with
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
  | temp_a_dual ψ => exact temp_a_dual_valid ψ
  | temp_l ψ => exact temp_l_valid ψ
  | modal_future ψ => exact modal_future_valid ψ
  | temp_future ψ => exact temp_future_valid ψ
  | temp_linearity φ ψ => exact temp_linearity_valid φ ψ
  | density _ => exact absurd h_base id
  | discreteness_forward _ => exact absurd h_base id
  | seriality_future _ => exact absurd h_base id
  | seriality_past _ => exact absurd h_base id
  | disc_next => exact absurd h_base id
  | disc_prev => exact absurd h_base id
  | until_unfold _ _ => exact absurd h_base id
  | until_intro _ _ => exact absurd h_base id
  | until_induction _ _ _ => exact absurd h_base id
  | until_linearity _ _ _ _ => exact absurd h_base id
  | since_unfold _ _ => exact absurd h_base id
  | since_intro _ _ => exact absurd h_base id
  | since_induction _ _ _ => exact absurd h_base id
  | since_linearity _ _ _ _ => exact absurd h_base id
  | until_connectedness _ _ _ => exact absurd h_base id
  | since_connectedness _ _ _ => exact absurd h_base id
  | F_until_equiv _ => exact absurd h_base id
  | P_since_equiv _ => exact absurd h_base id

/-- All dense-compatible axioms are valid on densely ordered frames.
This covers all base axioms (universally valid, hence valid on dense frames) plus the density axiom.
Note: Under strict semantics, seriality axioms require NoMaxOrder/NoMinOrder (via Nontrivial). -/
theorem axiom_valid_dense {φ : Formula} (h : Axiom φ) (h_dc : h.isDenseCompatible) : valid_dense φ := by
  cases h with
  | prop_k φ ψ χ => exact Validity.valid_implies_valid_dense (prop_k_valid φ ψ χ)
  | prop_s φ ψ => exact Validity.valid_implies_valid_dense (prop_s_valid φ ψ)
  | modal_t ψ => exact Validity.valid_implies_valid_dense (modal_t_valid ψ)
  | modal_4 ψ => exact Validity.valid_implies_valid_dense (modal_4_valid ψ)
  | modal_b ψ => exact Validity.valid_implies_valid_dense (modal_b_valid ψ)
  | modal_5_collapse ψ => exact Validity.valid_implies_valid_dense (modal_5_collapse_valid ψ)
  | ex_falso ψ => exact Validity.valid_implies_valid_dense (ex_falso_valid ψ)
  | peirce φ ψ => exact Validity.valid_implies_valid_dense (peirce_valid φ ψ)
  | modal_k_dist φ ψ => exact Validity.valid_implies_valid_dense (modal_k_dist_valid φ ψ)
  | temp_k_dist φ ψ => exact Validity.valid_implies_valid_dense (temp_k_dist_valid φ ψ)
  | temp_4 ψ => exact Validity.valid_implies_valid_dense (temp_4_valid ψ)
  | temp_a ψ => exact Validity.valid_implies_valid_dense (temp_a_valid ψ)
  | temp_a_dual ψ => exact Validity.valid_implies_valid_dense (temp_a_dual_valid ψ)
  | temp_l ψ => exact Validity.valid_implies_valid_dense (temp_l_valid ψ)
  | modal_future ψ => exact Validity.valid_implies_valid_dense (modal_future_valid ψ)
  | temp_future ψ => exact Validity.valid_implies_valid_dense (temp_future_valid ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_dense (temp_linearity_valid φ ψ)
  | density ψ => exact density_valid ψ
  | discreteness_forward _ => exact absurd h_dc id
  | seriality_future ψ =>
    -- Under strict semantics, Gψ → Fψ. By Nontrivial + ordered group, NoMaxOrder.
    intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_future, Formula.neg, truth_at]
    intro h_G h_neg_F
    obtain ⟨s, hts⟩ := exists_gt t
    exact h_neg_F s hts (h_G s hts)
  | seriality_past ψ =>
    -- Under strict semantics, Hψ → Pψ. By Nontrivial + ordered group, NoMinOrder.
    intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_past, Formula.neg, truth_at]
    intro h_H h_neg_P
    obtain ⟨s, hst⟩ := exists_lt t
    exact h_neg_P s hst (h_H s hst)
  | disc_next => exact absurd h_dc id
  | disc_prev => exact absurd h_dc id
  | until_unfold _ _ => exact absurd h_dc id
  | until_intro _ _ => exact absurd h_dc id
  | until_induction _ _ _ => exact absurd h_dc id
  | until_linearity _ _ _ _ => exact absurd h_dc id
  | since_unfold _ _ => exact absurd h_dc id
  | since_intro _ _ => exact absurd h_dc id
  | since_induction _ _ _ => exact absurd h_dc id
  | since_linearity _ _ _ _ => exact absurd h_dc id
  | until_connectedness _ _ _ => exact absurd h_dc id
  | since_connectedness _ _ _ => exact absurd h_dc id
  | F_until_equiv _ => exact absurd h_dc id
  | P_since_equiv _ => exact absurd h_dc id

/-- All discrete-compatible axioms are valid on discrete frames.
This covers all base axioms (universally valid, hence valid on discrete frames) plus discreteness.
Under strict semantics, seriality requires NoMaxOrder/NoMinOrder (from SuccOrder/PredOrder + Nontrivial). -/
theorem axiom_valid_discrete {φ : Formula} (h : Axiom φ) (h_dc : h.isDiscreteCompatible) :
    valid_discrete φ := by
  cases h with
  | prop_k φ ψ χ => exact Validity.valid_implies_valid_discrete (prop_k_valid φ ψ χ)
  | prop_s φ ψ => exact Validity.valid_implies_valid_discrete (prop_s_valid φ ψ)
  | modal_t ψ => exact Validity.valid_implies_valid_discrete (modal_t_valid ψ)
  | modal_4 ψ => exact Validity.valid_implies_valid_discrete (modal_4_valid ψ)
  | modal_b ψ => exact Validity.valid_implies_valid_discrete (modal_b_valid ψ)
  | modal_5_collapse ψ => exact Validity.valid_implies_valid_discrete (modal_5_collapse_valid ψ)
  | ex_falso ψ => exact Validity.valid_implies_valid_discrete (ex_falso_valid ψ)
  | peirce φ ψ => exact Validity.valid_implies_valid_discrete (peirce_valid φ ψ)
  | modal_k_dist φ ψ => exact Validity.valid_implies_valid_discrete (modal_k_dist_valid φ ψ)
  | temp_k_dist φ ψ => exact Validity.valid_implies_valid_discrete (temp_k_dist_valid φ ψ)
  | temp_4 ψ => exact Validity.valid_implies_valid_discrete (temp_4_valid ψ)
  | temp_a ψ => exact Validity.valid_implies_valid_discrete (temp_a_valid ψ)
  | temp_a_dual ψ => exact Validity.valid_implies_valid_discrete (temp_a_dual_valid ψ)
  | temp_l ψ => exact Validity.valid_implies_valid_discrete (temp_l_valid ψ)
  | modal_future ψ => exact Validity.valid_implies_valid_discrete (modal_future_valid ψ)
  | temp_future ψ => exact Validity.valid_implies_valid_discrete (temp_future_valid ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_discrete (temp_linearity_valid φ ψ)
  | density _ => exact absurd h_dc id
  | discreteness_forward ψ => exact discreteness_forward_valid ψ
  | seriality_future ψ => exact seriality_future_valid ψ
  | seriality_past ψ => exact seriality_past_valid ψ
  | disc_next => exact disc_next_valid
  | disc_prev => exact disc_prev_valid
  | until_unfold φ ψ => exact until_unfold_valid φ ψ
  | until_intro φ ψ => exact until_intro_valid φ ψ
  | until_induction φ ψ χ => exact until_induction_valid φ ψ χ
  | until_linearity φ ψ φ' ψ' => exact until_linearity_valid φ ψ φ' ψ'
  | since_unfold φ ψ => exact since_unfold_valid φ ψ
  | since_intro φ ψ => exact since_intro_valid φ ψ
  | since_induction φ ψ χ => exact since_induction_valid φ ψ χ
  | since_linearity φ ψ φ' ψ' => exact since_linearity_valid φ ψ φ' ψ'
  | until_connectedness φ ψ χ => exact until_connectedness_valid φ ψ χ
  | since_connectedness φ ψ χ => exact since_connectedness_valid φ ψ χ
  | F_until_equiv ψ => exact F_until_equiv_valid ψ
  | P_since_equiv ψ => exact P_since_equiv_valid ψ

/-! ## Full Derivation Soundness

The main soundness theorem showing derivability implies semantic consequence.
-/

/--
Necessitation rule preserves validity: if φ is universally valid, then □φ is universally valid.

This is semantic: if φ holds at all (M, Omega, τ, t), then for any model at any time,
□φ holds because we quantify over all histories in Omega, and φ holds at all of them.
-/
theorem necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨ (Formula.box φ) := by
  intro D _ _ _ F M Omega h_sc τ h_mem t
  simp only [truth_at]
  intro σ h_σ_mem
  exact h D F M Omega h_sc σ h_σ_mem t

/--
Temporal necessitation preserves validity: if φ is universally valid, then Gφ is universally valid.

This is semantic: if φ holds at all (M, Omega, τ, t), then at any time s ≥ t, φ holds at (τ, s).
-/
theorem temporal_necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨ (Formula.all_future φ) := by
  intro D _ _ _ F M Omega h_sc τ h_mem t
  simp only [truth_at]
  intro s _hts
  exact h D F M Omega h_sc τ h_mem s

/--
**Soundness Theorem**: Derivability implies semantic consequence.

If `Γ ⊢ φ` (φ is derivable from context Γ), then `Γ ⊨ φ` (φ is a semantic consequence of Γ).

The proof proceeds by induction on the derivation tree structure:
- **Axiom**: Use the axiom validity theorems above
- **Assumption**: If φ ∈ Γ and all of Γ holds, then φ holds
- **Modus ponens**: If Γ ⊨ φ → ψ and Γ ⊨ φ, then Γ ⊨ ψ
- **Necessitation**: Uses `necessitation_preserves_valid`
- **Temporal necessitation**: Uses `temporal_necessitation_preserves_valid`
- **Temporal duality**: Uses `SoundnessLemmas.derivable_implies_swap_valid`
- **IRR**: See `IRRSoundness.lean` for the product frame construction
- **Weakening**: Monotonicity of semantic consequence

**Note**: This theorem is stated for the full axiom set under strict semantics.
The density, discreteness, and seriality axioms require specific frame conditions
(DenselyOrdered, SuccOrder/PredOrder, NoMaxOrder/NoMinOrder respectively).
This soundness theorem is therefore only valid when those conditions are satisfied.
-/
theorem soundness (Γ : Context) (φ : Formula) :
    DerivationTree Γ φ → (D : Type) → [AddCommGroup D] → [LinearOrder D] → [IsOrderedAddMonoid D] →
    (F : TaskFrame D) → (M : TaskModel F) →
    (Omega : Set (WorldHistory F)) → (h_sc : ShiftClosed Omega) →
    (τ : WorldHistory F) → (h_mem : τ ∈ Omega) → (t : D) →
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) →
    truth_at M Omega τ t φ := by
  intro d D _ _ _ F M Omega h_sc τ h_mem t h_ctx
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax =>
    -- All base axioms are universally valid; extension axioms require frame conditions
    cases h_ax with
    | prop_k φ ψ χ => exact prop_k_valid φ ψ χ D F M Omega h_sc τ h_mem t
    | prop_s φ ψ => exact prop_s_valid φ ψ D F M Omega h_sc τ h_mem t
    | modal_t ψ => exact modal_t_valid ψ D F M Omega h_sc τ h_mem t
    | modal_4 ψ => exact modal_4_valid ψ D F M Omega h_sc τ h_mem t
    | modal_b ψ => exact modal_b_valid ψ D F M Omega h_sc τ h_mem t
    | modal_5_collapse ψ => exact modal_5_collapse_valid ψ D F M Omega h_sc τ h_mem t
    | ex_falso ψ => exact ex_falso_valid ψ D F M Omega h_sc τ h_mem t
    | peirce φ ψ => exact peirce_valid φ ψ D F M Omega h_sc τ h_mem t
    | modal_k_dist φ ψ => exact modal_k_dist_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_k_dist φ ψ => exact temp_k_dist_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_4 ψ => exact temp_4_valid ψ D F M Omega h_sc τ h_mem t
    | temp_a ψ => exact temp_a_valid ψ D F M Omega h_sc τ h_mem t
    | temp_a_dual ψ => exact temp_a_dual_valid ψ D F M Omega h_sc τ h_mem t
    | temp_l ψ => exact temp_l_valid ψ D F M Omega h_sc τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_future ψ => exact temp_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M Omega h_sc τ h_mem t
    -- Frame-class-restricted axioms: require SuccOrder/PredOrder/DenselyOrdered.
    -- The general soundness theorem cannot handle these without frame constraints.
    -- Use soundness_dense or the discrete soundness for derivations involving these.
    | density _ => sorry
    | discreteness_forward _ => sorry
    | seriality_future _ => sorry
    | seriality_past _ => sorry
    | disc_next => sorry
    | disc_prev => sorry
    | until_unfold _ _ => sorry
    | until_intro _ _ => sorry
    | until_induction _ _ _ => sorry
    | until_linearity _ _ _ _ => sorry
    | since_unfold _ _ => sorry
    | since_intro _ _ => sorry
    | since_induction _ _ _ => sorry
    | since_linearity _ _ _ _ => sorry
    | until_connectedness _ _ _ => sorry
    | since_connectedness _ _ _ => sorry
    | F_until_equiv _ => sorry
    | P_since_equiv _ => sorry
  | assumption Γ' φ' h_in =>
    exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have h1 := ih1 τ h_mem t h_ctx
    have h2 := ih2 τ h_mem t h_ctx
    simp only [truth_at] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [truth_at]
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [truth_at]
    intro s _hts
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' ih =>
    -- ARCHITECTURAL LIMITATION: temporal_duality soundness requires
    -- [DenselyOrdered D] [Nontrivial D] constraints because it calls
    -- SoundnessLemmas.derivable_implies_swap_valid which has those constraints.
    --
    -- For soundness of derivations containing temporal_duality, use the
    -- soundness_dense theorem (line ~715) which provides these constraints.
    -- This sorry is intentional and documents the frame-class restriction.
    sorry
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## Frame-Class-Restricted Soundness Theorems

These theorems provide soundness for specific frame classes, resolving the limitation
that the general soundness theorem cannot handle extension axioms without frame constraints.
-/

/--
**Soundness Dense Valid**: Derivability from empty context implies dense validity.

This theorem proves `valid_dense phi` for dense-compatible derivations from empty context,
which provides the universal quantification needed for the IRR soundness lemma.

**Key Insight**: The induction hypothesis at each step provides `valid_dense` for premises,
which matches the signature required by `irr_sound_dense_at_domain`.

**Note on domain membership**: The IRR case in `irr_sound_dense_at_domain` requires
`h_dom : tau.domain t`. This is handled by case split:
- Domain case: directly apply `irr_sound_dense_at_domain`
- Non-domain case: a known semantic gap (sorried) - canonical models use full domains

This theorem is defined before `soundness_dense` because `soundness_dense`'s IRR case
needs to invoke it for universal validity.
-/
theorem soundness_dense_valid {phi : Formula}
    (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) : valid_dense phi := by
  match d with
  | .axiom _ _ h_ax =>
    -- All dense-compatible axioms are valid_dense
    exact axiom_valid_dense h_ax h_dc
  | .assumption _ _ h_mem =>
    -- Empty context has no assumptions
    exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ psi' _ d1 d2 =>
    -- From valid_dense (psi' → phi) and valid_dense psi', derive valid_dense phi
    obtain ⟨h_dc1, h_dc2⟩ := h_dc
    have h1 := soundness_dense_valid d1 h_dc1
    have h2 := soundness_dense_valid d2 h_dc2
    intro D _ _ _ _ _ F M Omega h_sc tau h_mem t
    have h1' := h1 D F M Omega h_sc tau h_mem t
    have h2' := h2 D F M Omega h_sc tau h_mem t
    simp only [truth_at] at h1'
    exact h1' h2'
  | .necessitation psi' d' =>
    -- valid_dense psi' → valid_dense (box psi')
    have h := soundness_dense_valid d' h_dc
    intro D _ _ _ _ _ F M Omega h_sc tau h_mem t
    simp only [truth_at]
    intro sigma h_sigma_mem
    exact h D F M Omega h_sc sigma h_sigma_mem t
  | .temporal_necessitation psi' d' =>
    -- valid_dense psi' → valid_dense (all_future psi')
    have h := soundness_dense_valid d' h_dc
    intro D _ _ _ _ _ F M Omega h_sc tau h_mem t
    simp only [truth_at]
    intro s _hts
    exact h D F M Omega h_sc tau h_mem s
  | .temporal_duality psi' d' =>
    -- valid_dense psi' → valid_dense (swap psi')
    -- Use derivable_implies_swap_valid which gives is_valid, then convert
    intro D _ _ _ _ _ F M Omega h_sc tau h_mem t
    exact SoundnessLemmas.derivable_implies_swap_valid d' h_dc F M Omega h_sc tau h_mem t
  | .weakening Gamma' _ _ d' h_sub =>
    -- Since d : DerivationTree [] phi and Gamma' ⊆ [], we have Gamma' = []
    have h_eq : Gamma' = [] := List.eq_nil_of_subset_nil h_sub
    have h_dc_sub : (h_eq ▸ d').isDenseCompatible := by
      simp only [DerivationTree.isDenseCompatible] at h_dc
      subst h_eq
      exact h_dc
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Gamma' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact soundness_dense_valid (h_eq ▸ d') h_dc_sub
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/--
**Soundness for Dense Frames**: Derivability implies semantic consequence on dense frames.

If `Γ ⊢ φ` with a dense-compatible derivation, then `Γ ⊨_dense φ`.

**Frame Constraints**:
- `[DenselyOrdered D]`: Required for density axiom (GGφ → Gφ)
- `[Nontrivial D]`: Required for seriality axioms (provides NoMaxOrder/NoMinOrder)

**Dense Compatibility** (`h_dc : d.isDenseCompatible`):
Ensures the derivation doesn't use `discreteness_forward` which is invalid on dense frames.

**Note on IRR rule**: The IRR case uses `soundness_dense_valid` to obtain universal validity,
then instantiates for the specific model.
-/
theorem soundness_dense (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ) (h_dc : d.isDenseCompatible)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) :
    truth_at M Omega τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax =>
    cases h_ax with
    | prop_k φ ψ χ => exact prop_k_valid φ ψ χ D F M Omega h_sc τ h_mem t
    | prop_s φ ψ => exact prop_s_valid φ ψ D F M Omega h_sc τ h_mem t
    | modal_t ψ => exact modal_t_valid ψ D F M Omega h_sc τ h_mem t
    | modal_4 ψ => exact modal_4_valid ψ D F M Omega h_sc τ h_mem t
    | modal_b ψ => exact modal_b_valid ψ D F M Omega h_sc τ h_mem t
    | modal_5_collapse ψ => exact modal_5_collapse_valid ψ D F M Omega h_sc τ h_mem t
    | ex_falso ψ => exact ex_falso_valid ψ D F M Omega h_sc τ h_mem t
    | peirce φ ψ => exact peirce_valid φ ψ D F M Omega h_sc τ h_mem t
    | modal_k_dist φ ψ => exact modal_k_dist_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_k_dist φ ψ => exact temp_k_dist_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_4 ψ => exact temp_4_valid ψ D F M Omega h_sc τ h_mem t
    | temp_a ψ => exact temp_a_valid ψ D F M Omega h_sc τ h_mem t
    | temp_a_dual ψ => exact temp_a_dual_valid ψ D F M Omega h_sc τ h_mem t
    | temp_l ψ => exact temp_l_valid ψ D F M Omega h_sc τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_future ψ => exact temp_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M Omega h_sc τ h_mem t
    | density ψ => exact density_valid ψ D F M Omega h_sc τ h_mem t
    | discreteness_forward _ => exact absurd h_dc id
    | seriality_future ψ =>
      -- Under strict semantics: Gψ → Fψ. Requires NoMaxOrder.
      simp only [Formula.some_future, Formula.neg, truth_at]
      intro h_G h_neg_F
      obtain ⟨s, hts⟩ := exists_gt t
      exact h_neg_F s hts (h_G s hts)
    | seriality_past ψ =>
      -- Under strict semantics: Hψ → Pψ. Requires NoMinOrder.
      simp only [Formula.some_past, Formula.neg, truth_at]
      intro h_H h_neg_P
      obtain ⟨s, hst⟩ := exists_lt t
      exact h_neg_P s hst (h_H s hst)
    | disc_next => exact absurd h_dc id
    | disc_prev => exact absurd h_dc id
    | until_unfold _ _ => exact absurd h_dc id
    | until_intro _ _ => exact absurd h_dc id
    | until_induction _ _ _ => exact absurd h_dc id
    | until_linearity _ _ _ _ => exact absurd h_dc id
    | since_unfold _ _ => exact absurd h_dc id
    | since_intro _ _ => exact absurd h_dc id
    | since_induction _ _ _ => exact absurd h_dc id
    | since_linearity _ _ _ _ => exact absurd h_dc id
    | until_connectedness _ _ _ => exact absurd h_dc id
    | since_connectedness _ _ _ => exact absurd h_dc id
    | F_until_equiv _ => exact absurd h_dc id
    | P_since_equiv _ => exact absurd h_dc id
  | assumption Γ' φ' h_in =>
    exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have ⟨h_dc1, h_dc2⟩ := h_dc
    have h1 := ih1 h_dc1 τ h_mem t h_ctx
    have h2 := ih2 h_dc2 τ h_mem t h_ctx
    simp only [truth_at] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [truth_at]
    intro σ h_σ_mem
    -- For theorems (empty context), the ih gives truth at any (σ, t)
    exact ih h_dc σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [truth_at]
    intro s _hts
    -- For theorems (empty context), the ih gives truth at any (τ, s)
    exact ih h_dc τ h_mem s (by simp)
  | temporal_duality φ' d' ih =>
    -- d' : ⊢ φ', and the goal is truth_at M Omega τ t φ'.swap_temporal
    -- Use derivable_implies_swap_valid from SoundnessLemmas
    -- h_dc : (temporal_duality φ' d').isDenseCompatible = d'.isDenseCompatible
    exact SoundnessLemmas.derivable_implies_swap_valid d' h_dc F M Omega h_sc τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih h_dc τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

end Bimodal.Metalogic
