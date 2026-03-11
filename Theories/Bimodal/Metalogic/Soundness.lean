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

**Omega Parameterization (Task 912)**:
Validity and semantic consequence now quantify over shift-closed Omega sets.
All soundness proofs use the `ShiftClosed Omega` hypothesis where previously
`Set.univ_shift_closed` was used. This enables completeness proofs to provide
a matching Omega.

## References

* [ARCHITECTURE.md](../../../docs/UserGuide/ARCHITECTURE.md) - Soundness specification
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
* [Validity.lean](../../Semantics/Validity.lean) - Semantic validity
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

/-- Temporal 4 axiom is valid: `⊨ Fφ → FFφ`. -/
theorem temp_4_valid (φ : Formula) : ⊨ ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future s hts r hsr
  exact h_future r (lt_trans hts hsr)

/-- Temporal A axiom is valid: `⊨ φ → F(sometime_past φ)`. -/
theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_future φ.sometime_past)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi s hts
  simp only [Formula.sometime_past, Formula.some_past, Formula.neg, truth_at]
  intro h_all_neg
  exact h_all_neg t hts h_phi

/-- TL axiom validity: `△φ → F(Pφ)` is valid. -/
theorem temp_l_valid (φ : Formula) :
    ⊨ (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_always s _hts r _hrs
  simp only [Formula.always, Formula.and, Formula.neg, truth_at] at h_always
  have h1 :
    (∀ (u : T), u < t → truth_at M Omega τ u φ) ∧
    ((truth_at M Omega τ t φ →
      (∀ (v : T), t < v → truth_at M Omega τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : truth_at M Omega τ t φ ∧ (∀ (v : T), t < v → truth_at M Omega τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2
  rcases lt_trichotomy r t with h_lt | h_eq | h_gt
  · exact h_past r h_lt
  · rw [h_eq]; exact h_now
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

/-- Temporal linearity axiom validity:
`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)` is valid.

Uses linearity of D (LinearOrder instance).
-/
theorem temp_linearity_valid (φ ψ : Formula) :
    ⊨ (Formula.and (Formula.some_future φ) (Formula.some_future ψ) |>.imp
      (Formula.or (Formula.some_future (Formula.and φ ψ))
        (Formula.or (Formula.some_future (Formula.and φ (Formula.some_future ψ)))
          (Formula.some_future (Formula.and (Formula.some_future φ) ψ))))) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.some_future, Formula.neg, truth_at]
  intro h_conj
  -- Extract F(phi) and F(psi) witnesses
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

/-- Density axiom (DN) is valid on dense orders: `⊨_dense Fφ → FFφ`.
With irreflexive semantics, Fφ means ∃ s > t with φ(s). Using DenselyOrdered,
given witness s > t, we get u with t < u < s. Then Fφ holds at u (via s), so FFφ at t. -/
theorem density_valid (φ : Formula) : valid_dense (φ.some_future.imp φ.some_future.some_future) := by
  intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_F_phi h_GnFphi
  -- h_F_phi : ¬∀ s > t, ¬φ(s), i.e., ∃ s > t, φ(s)
  -- h_GnFphi : ∀ u > t, ¬(¬∀ v > u, ¬φ(v)), i.e., ∀ u > t, ∀ v > u, ¬φ(v)
  -- Extract witness s > t with φ(s)
  have ⟨s, hts, h_phi_s⟩ : ∃ s, t < s ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no
    exact h_F_phi (fun s hs h_phi => h_no s hs h_phi)
  -- Use density to find u with t < u < s
  obtain ⟨u, htu, hus⟩ := DenselyOrdered.dense t s hts
  -- h_GnFphi at u says: ∀ v > u, ¬φ(v). But φ(s) and u < s. Contradiction.
  exact h_GnFphi u htu (fun h_all_neg => h_all_neg s hus h_phi_s)

/-- Forward discreteness axiom (DF) is valid on discrete orders: `⊨_discrete (F⊤ ∧ φ ∧ Hφ) → F(Hφ)`.
With irreflexive semantics and SuccOrder, given F⊤ (∃ s > t), φ at t, and Hφ at t (∀ r < t, φ(r)),
we take u = Order.succ t. Then Hφ at u means ∀ r < succ(t), φ(r), which holds because
r < succ(t) implies r ≤ t, and either r < t (by Hφ) or r = t (by φ at t). -/
theorem discreteness_forward_valid (φ : Formula) :
    valid_discrete (Formula.and (Formula.bot.neg.some_future)
      (Formula.and φ (Formula.all_past φ)) |>.imp
      (Formula.all_past φ).some_future) := by
  intro T _ _ _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.some_future, Formula.neg, truth_at]
  intro h_conj h_G_not_H
  -- h_conj encodes (F⊤ → (φ → Hφ → ⊥) → ⊥) → ⊥, from which we extract three parts.
  -- But the negation encoding means we work contrapositively.
  -- We need: h_G_not_H applied at u = Order.succ t.
  -- First show t is not maximal from h_conj (which encodes F⊤).
  have h_not_max : ¬IsMax t := by
    intro h_max
    apply h_conj
    intro h_F_top _
    apply h_F_top
    intro s hts
    exact absurd hts (not_lt.mpr (h_max (le_of_lt hts)))
  -- Take u = Order.succ t
  have h_lt_succ : t < Order.succ t := Order.lt_succ_of_not_isMax h_not_max
  -- h_G_not_H at Order.succ t: need to show (∀ r < succ t, φ(r)) → False is False
  apply h_G_not_H (Order.succ t) h_lt_succ
  -- Goal: ∀ r < succ(t), φ(r)
  intro r h_r_lt_succ
  have h_r_le_t : r ≤ t := Order.le_of_lt_succ h_r_lt_succ
  -- Extract φ at t and Hφ at t from h_conj
  have ⟨_, h_phi_and_H⟩ := and_of_not_imp_not h_conj
  have ⟨h_phi, h_H⟩ := and_of_not_imp_not h_phi_and_H
  rcases eq_or_lt_of_le h_r_le_t with h_eq | h_lt
  · rw [h_eq]; exact h_phi
  · exact h_H r h_lt

/-- Future seriality axiom is valid on dense orders: `⊨_dense F(¬⊥)`.
Requires `Nontrivial D` (via `valid_dense`) to ensure there exist distinct elements,
from which `NoMaxOrder` follows using the group structure. -/
theorem seriality_future_valid : valid_dense (Formula.some_future (Formula.neg Formula.bot)) := by
  intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_all_neg
  -- From Nontrivial + AddCommGroup + LinearOrder + IsOrderedAddMonoid, derive NoMaxOrder
  have : NoMaxOrder T := by
    constructor; intro a
    obtain ⟨b, hb⟩ := exists_ne a
    rcases lt_trichotomy a b with h | h | h
    · exact ⟨b, h⟩
    · exact absurd h (Ne.symm hb)
    · exact ⟨a + (a - b), lt_add_of_pos_right a (sub_pos.mpr h)⟩
  obtain ⟨s, hts⟩ := exists_gt t
  exact h_all_neg s hts id

/-- Past seriality axiom is valid on dense orders: `⊨_dense P(¬⊥)`.
Requires `Nontrivial D` (via `valid_dense`) to ensure there exist distinct elements,
from which `NoMinOrder` follows using the group structure. -/
theorem seriality_past_valid : valid_dense (Formula.some_past (Formula.neg Formula.bot)) := by
  intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_past, Formula.neg, truth_at]
  intro h_all_neg
  have : NoMinOrder T := by
    constructor; intro a
    obtain ⟨b, hb⟩ := exists_ne a
    rcases lt_trichotomy a b with h | h | h
    · exact ⟨a + (a - b), add_lt_of_neg_right a (sub_neg.mpr h)⟩
    · exact absurd h (Ne.symm hb)
    · exact ⟨b, h⟩
  obtain ⟨s, hts⟩ := exists_lt t
  exact h_all_neg s hts id

/-- All base TM axioms (excluding density, discreteness, and seriality) are universally valid.
With irreflexive semantics, density requires DenselyOrdered, discreteness requires SuccOrder,
and seriality requires Nontrivial, so they are handled separately. -/
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
  | temp_l ψ => exact temp_l_valid ψ
  | modal_future ψ => exact modal_future_valid ψ
  | temp_future ψ => exact temp_future_valid ψ
  | temp_linearity φ ψ => exact temp_linearity_valid φ ψ
  | density _ => exact absurd h_base id
  | discreteness_forward _ => exact absurd h_base id
  | seriality_future => exact absurd h_base id
  | seriality_past => exact absurd h_base id

/-- All dense-compatible axioms are valid on densely ordered frames.
This covers all base axioms (universally valid, hence valid on dense frames) plus the density axiom. -/
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
  | temp_l ψ => exact Validity.valid_implies_valid_dense (temp_l_valid ψ)
  | modal_future ψ => exact Validity.valid_implies_valid_dense (modal_future_valid ψ)
  | temp_future ψ => exact Validity.valid_implies_valid_dense (temp_future_valid ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_dense (temp_linearity_valid φ ψ)
  | density ψ => exact density_valid ψ
  | discreteness_forward _ => exact absurd h_dc id
  | seriality_future => exact seriality_future_valid
  | seriality_past => exact seriality_past_valid

/-- All discrete-compatible axioms are valid on discrete frames.
This covers all base axioms (universally valid, hence valid on discrete frames) plus discreteness. -/
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
  | temp_l ψ => exact Validity.valid_implies_valid_discrete (temp_l_valid ψ)
  | modal_future ψ => exact Validity.valid_implies_valid_discrete (modal_future_valid ψ)
  | temp_future ψ => exact Validity.valid_implies_valid_discrete (temp_future_valid ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_discrete (temp_linearity_valid φ ψ)
  | density _ => exact absurd h_dc id
  | discreteness_forward ψ => exact discreteness_forward_valid ψ
  | seriality_future =>
    intro T _ _ _ _ _ _ F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_future, Formula.neg, truth_at]
    intro h_all_neg
    have : NoMaxOrder T := by
      constructor; intro a
      obtain ⟨b, hb⟩ := exists_ne a
      rcases lt_trichotomy a b with h | h | h
      · exact ⟨b, h⟩
      · exact absurd h (Ne.symm hb)
      · exact ⟨a + (a - b), lt_add_of_pos_right a (sub_pos.mpr h)⟩
    obtain ⟨s, hts⟩ := exists_gt t
    exact h_all_neg s hts id
  | seriality_past =>
    intro T _ _ _ _ _ _ F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_past, Formula.neg, truth_at]
    intro h_all_neg
    have : NoMinOrder T := by
      constructor; intro a
      obtain ⟨b, hb⟩ := exists_ne a
      rcases lt_trichotomy a b with h | h | h
      · exact ⟨a + (a - b), add_lt_of_neg_right a (sub_neg.mpr h)⟩
      · exact absurd h (Ne.symm hb)
      · exact ⟨b, h⟩
    obtain ⟨s, hts⟩ := exists_lt t
    exact h_all_neg s hts id

end Bimodal.Metalogic
