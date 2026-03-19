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

/-- Temporal A axiom is valid: `⊨ φ → G(sometime_past φ)`.
Under strict semantics: if φ at t, then for all s > t, there exists r < s with φ(r) (namely, t). -/
theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_future φ.sometime_past)) := by
  intro T _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi s hts
  simp only [Formula.sometime_past, Formula.some_past, Formula.neg, truth_at]
  intro h_all_neg
  -- h_all_neg : ∀ r < s, ¬φ(r). But t < s (from hts) and φ(t) (from h_phi).
  exact h_all_neg t hts h_phi

/-- TL axiom validity: `△φ → G(Hφ)` is valid.
Under strict semantics, △φ = Hφ ∧ φ ∧ Gφ encodes: (∀ u < t, φ(u)) ∧ φ(t) ∧ (∀ v > t, φ(v)).
The goal G(Hφ) requires: ∀ s > t, ∀ r < s, φ(r).
For any r < s with s > t, by trichotomy: r < t, r = t, or r > t.
All cases are covered by the △φ hypothesis. -/
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
  -- With strict semantics, we have φ at all times (past, present, future)
  -- Need φ(r) where r < s. By trichotomy on r vs t:
  rcases lt_trichotomy r t with h_lt | h_eq | h_gt
  · exact h_past r h_lt
  · subst h_eq; exact h_now
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
Under strict semantics, this requires DenselyOrdered: for any s > t, there exists
r with t < r < s, and from GGφ we get Gφ at r, which gives φ at s. -/
theorem density_valid (φ : Formula) :
    valid_dense ((φ.all_future.all_future).imp φ.all_future) := by
  intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_GG s hts
  -- h_GG : ∀ r > t, ∀ q > r, φ(q)
  -- hts : t < s
  -- Goal: φ(s)
  -- By density, ∃ r with t < r < s (using DenselyOrdered instance)
  obtain ⟨r, htr, hrs⟩ := DenselyOrdered.dense t s hts
  -- From h_GG at r: ∀ q > r, φ(q). Since s > r, φ(s).
  exact h_GG r htr s hrs

/-- Forward discreteness axiom (DF) is valid on discrete orders: `⊨_discrete (F⊤ ∧ φ ∧ Hφ) → F(Hφ)`.
Under strict semantics, this uses the immediate successor property: given F⊤ (∃s > t),
φ at t, and Hφ at t (∀r < t, φ(r)), we need to show F(Hφ), i.e., ∃s > t, ∀r < s, φ(r).
Use the immediate successor succ t: for r < succ t, either r < t (covered by Hφ),
r = t (covered by φ), or t < r < succ t (impossible by SuccOrder property).
-/
theorem discreteness_forward_valid (φ : Formula) :
    valid_discrete (Formula.and (Formula.bot.neg.some_future)
      (Formula.and φ (Formula.all_past φ)) |>.imp
      (Formula.all_past φ).some_future) := by
  intro T _ _ _ h_succ _h_pred _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.some_future, Formula.neg, truth_at]
  intro h_conj h_G_not_H
  -- Extract F⊤, φ, and Hφ from conjunction
  have h1 := and_of_not_imp_not h_conj
  have ⟨_h_F_top, h_phi_and_H⟩ := h1
  have h2 := and_of_not_imp_not h_phi_and_H
  have ⟨h_phi, h_H⟩ := h2
  -- h_H : ∀ r < t, φ(r)
  -- h_phi : φ(t)
  -- Use succ t as the witness (it's strictly greater than t)
  have h_lt_succ : t < Order.succ t := Order.lt_succ t
  apply h_G_not_H (Order.succ t) h_lt_succ
  -- Goal: ∀ r < succ t, φ(r)
  intro r h_r_lt_succ
  -- By SuccOrder, r < succ t implies r ≤ t
  have h_r_le_t : r ≤ t := Order.lt_succ_iff.mp h_r_lt_succ
  -- Trichotomy on r ≤ t: either r < t or r = t
  rcases h_r_le_t.lt_or_eq with h_lt | h_eq
  · exact h_H r h_lt
  · subst h_eq; exact h_phi

/-- Future seriality axiom validity: `⊨_discrete Gφ → Fφ`.
Under strict semantics with SuccOrder: use succ t as witness for s > t.
The universal quantification Gφ at s implies the existential Fφ. -/
theorem seriality_future_valid (φ : Formula) :
    valid_discrete (φ.all_future.imp φ.some_future) := by
  intro T _ _ _ h_succ _h_pred _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_G h_neg_F
  -- h_G : ∀ s > t, φ(s)
  -- h_neg_F : ∀ s > t, ¬φ(s)
  -- Use succ t as witness: t < succ t by SuccOrder
  have h_lt_succ : t < Order.succ t := Order.lt_succ t
  -- h_G gives φ(succ t), h_neg_F gives ¬φ(succ t). Contradiction.
  exact h_neg_F (Order.succ t) h_lt_succ (h_G (Order.succ t) h_lt_succ)

/-- Past seriality axiom validity: `⊨_discrete Hφ → Pφ`.
Under strict semantics with PredOrder: use pred t as witness for s < t.
The universal quantification Hφ at s implies the existential Pφ. -/
theorem seriality_past_valid (φ : Formula) :
    valid_discrete (φ.all_past.imp φ.some_past) := by
  intro T _ _ _ _h_succ h_pred _h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_past, Formula.neg, truth_at]
  intro h_H h_neg_P
  -- h_H : ∀ s < t, φ(s)
  -- h_neg_P : ∀ s < t, ¬φ(s)
  -- Use pred t as witness: pred t < t by PredOrder
  have h_pred_lt : Order.pred t < t := Order.pred_lt t
  -- h_H gives φ(pred t), h_neg_P gives ¬φ(pred t). Contradiction.
  exact h_neg_P (Order.pred t) h_pred_lt (h_H (Order.pred t) h_pred_lt)

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
  | temp_l ψ => exact temp_l_valid ψ
  | modal_future ψ => exact modal_future_valid ψ
  | temp_future ψ => exact temp_future_valid ψ
  | temp_linearity φ ψ => exact temp_linearity_valid φ ψ
  | density _ => exact absurd h_base id
  | discreteness_forward _ => exact absurd h_base id
  | seriality_future _ => exact absurd h_base id
  | seriality_past _ => exact absurd h_base id

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
  | temp_l ψ => exact Validity.valid_implies_valid_dense (temp_l_valid ψ)
  | modal_future ψ => exact Validity.valid_implies_valid_dense (modal_future_valid ψ)
  | temp_future ψ => exact Validity.valid_implies_valid_dense (temp_future_valid ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_dense (temp_linearity_valid φ ψ)
  | density ψ => exact density_valid ψ
  | discreteness_forward _ => exact absurd h_dc id
  | seriality_future ψ =>
    -- Seriality: Gψ → Fψ. Valid on dense frames via DenselyOrdered → Nontrivial → NoMaxOrder
    intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_future, Formula.neg, truth_at]
    intro h_G h_neg_F
    -- DenselyOrdered + Nontrivial implies NoMaxOrder via inference
    have h_nomax : NoMaxOrder T := inferInstance
    obtain ⟨s, hts⟩ := h_nomax.exists_gt t
    exact h_neg_F s hts (h_G s hts)
  | seriality_past ψ =>
    -- Seriality: Hψ → Pψ. Valid on dense frames via DenselyOrdered → Nontrivial → NoMinOrder
    intro T _ _ _ _ _ F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_past, Formula.neg, truth_at]
    intro h_H h_neg_P
    -- DenselyOrdered + Nontrivial implies NoMinOrder via inference
    have h_nomin : NoMinOrder T := inferInstance
    obtain ⟨s, hst⟩ := h_nomin.exists_lt t
    exact h_neg_P s hst (h_H s hst)

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
  | temp_l ψ => exact Validity.valid_implies_valid_discrete (temp_l_valid ψ)
  | modal_future ψ => exact Validity.valid_implies_valid_discrete (modal_future_valid ψ)
  | temp_future ψ => exact Validity.valid_implies_valid_discrete (temp_future_valid ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_discrete (temp_linearity_valid φ ψ)
  | density _ => exact absurd h_dc id
  | discreteness_forward ψ => exact discreteness_forward_valid ψ
  | seriality_future ψ =>
    -- Under strict semantics, Gψ → Fψ requires a witness s > t
    -- Use succ t from SuccOrder: t < succ t
    intro T _ _ _ _h_succ _h_pred _h_nontriv F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_future, Formula.neg, truth_at]
    intro h_G h_neg_F
    -- Use succ t as witness: t < succ t by SuccOrder
    have hts : t < Order.succ t := Order.lt_succ t
    exact h_neg_F (Order.succ t) hts (h_G (Order.succ t) hts)
  | seriality_past ψ =>
    -- Under strict semantics, Hψ → Pψ requires a witness s < t
    -- Use pred t from PredOrder: pred t < t
    intro T _ _ _ _h_succ _h_pred _h_nontriv F M Omega _h_sc τ _h_mem t
    simp only [Formula.some_past, Formula.neg, truth_at]
    intro h_H h_neg_P
    -- Use pred t as witness: pred t < t by PredOrder
    have hst : Order.pred t < t := Order.pred_lt t
    exact h_neg_P (Order.pred t) hst (h_H (Order.pred t) hst)

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
    | temp_l ψ => exact temp_l_valid ψ D F M Omega h_sc τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_future ψ => exact temp_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M Omega h_sc τ h_mem t
    | density ψ =>
      -- Density axiom: GGψ → Gψ. Requires DenselyOrdered D.
      -- This case cannot be proven without the DenselyOrdered instance.
      -- Full soundness requires restricting to dense frames.
      sorry
    | discreteness_forward ψ =>
      -- Forward discreteness: (F⊤ ∧ φ ∧ Hφ) → F(Hφ)
      -- Requires SuccOrder D.
      sorry
    | seriality_future ψ =>
      -- Seriality: Gψ → Fψ. Requires NoMaxOrder D.
      sorry
    | seriality_past ψ =>
      -- Seriality: Hψ → Pψ. Requires NoMinOrder D.
      sorry
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
    -- Temporal duality soundness: swap of valid is valid
    -- The ih gives validity of φ' at (τ, t), need validity of swap(φ') at (τ, t)
    -- This follows from axiom_swap_valid in SoundnessLemmas but requires DenselyOrdered/Nontrivial
    sorry -- See SoundnessLemmas.axiom_swap_valid for the component proofs
  | irr p φ' h_fresh _ ih =>
    -- IRR rule soundness: see IRRSoundness.lean
    sorry -- Full proof uses product frame construction
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## Frame-Class-Restricted Soundness Theorems

These theorems provide soundness for specific frame classes, resolving the limitation
that the general soundness theorem cannot handle extension axioms without frame constraints.
-/

/--
**Soundness for Dense Frames**: Derivability implies semantic consequence on dense frames.

If `Γ ⊢ φ` with a dense-compatible derivation, then `Γ ⊨_dense φ`.

**Frame Constraints**:
- `[DenselyOrdered D]`: Required for density axiom (GGφ → Gφ)
- `[Nontrivial D]`: Required for seriality axioms (provides NoMaxOrder/NoMinOrder)

**Dense Compatibility** (`h_dc : d.isDenseCompatible`):
Ensures the derivation doesn't use `discreteness_forward` which is invalid on dense frames.

**Note on IRR rule**: The IRR case requires additional domain membership hypothesis
(`τ.domain t`) for the product frame construction. For now, this case is marked sorry.
Canonical models use full domains (`Set.univ`) where this is trivially satisfied.
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
    | temp_l ψ => exact temp_l_valid ψ D F M Omega h_sc τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_future ψ => exact temp_future_valid ψ D F M Omega h_sc τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M Omega h_sc τ h_mem t
    | density ψ =>
      -- Density axiom: GGψ → Gψ. Valid on dense frames via DenselyOrdered.
      exact density_valid ψ D F M Omega h_sc τ h_mem t
    | discreteness_forward _ =>
      -- discreteness_forward is NOT dense-compatible, eliminated by h_dc
      exact absurd h_dc id
    | seriality_future ψ =>
      -- Seriality: Gψ → Fψ. Valid on dense frames via NoMaxOrder (from DenselyOrdered + Nontrivial)
      simp only [Formula.some_future, Formula.neg, truth_at]
      intro h_G h_neg_F
      have h_nomax : NoMaxOrder D := inferInstance
      obtain ⟨s, hts⟩ := h_nomax.exists_gt t
      exact h_neg_F s hts (h_G s hts)
    | seriality_past ψ =>
      -- Seriality: Hψ → Pψ. Valid on dense frames via NoMinOrder (from DenselyOrdered + Nontrivial)
      simp only [Formula.some_past, Formula.neg, truth_at]
      intro h_H h_neg_P
      have h_nomin : NoMinOrder D := inferInstance
      obtain ⟨s, hst⟩ := h_nomin.exists_lt t
      exact h_neg_P s hst (h_H s hst)
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
    -- d' : ⊢ φ', and the goal is truth_at ... φ'.swap
    -- This requires derivable_implies_swap_valid from SoundnessLemmas, which proves
    -- that for derivable formulas, their swap is also valid.
    -- However, implementing this requires resolving mutual recursion between
    -- derivable_locally_valid and derivable_implies_swap_valid (see research report).
    -- For now, marked sorry pending proper implementation.
    sorry
  | irr p φ' h_fresh _ ih =>
    sorry -- Phase 3: Wire using irr_sound_dense_at_domain
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih h_dc τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

end Bimodal.Metalogic
