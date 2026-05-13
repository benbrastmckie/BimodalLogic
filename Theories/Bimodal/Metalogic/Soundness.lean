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

**Frame-Class Architecture**:
Soundness is organized by frame class because axioms require different frame conditions:
- `soundness`: For dense-compatible derivations on arbitrary frames (sorry-free)
- `soundness_dense`: For dense-compatible derivations on dense frames (sorry-free)
- `soundness_discrete`: For all derivations on discrete frames (sorry-free)

All soundness theorems are sorry-free. The discrete soundness theorem uses
`derivable_implies_swap_valid_discrete` from SoundnessLemmas.lean, which
proves Prior-UZ/SZ validity via well-founded descent on succ/pred chains.
Prior-UZ/SZ are excluded from dense-compatible derivations via `isDenseCompatible`.

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
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/-- Propositional S axiom is valid. -/
theorem prop_s_valid (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_phi _
  exact h_phi

/-- Modal T axiom is valid: `⊨ □φ → φ`. -/
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ _ _ _ F M Omega _h_sc τ h_mem t
  simp only [truth_at]
  intro h_box
  exact h_box τ h_mem

/-- Modal 4 axiom is valid: `⊨ □φ → □□φ`. -/
theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box σ h_σ_mem ρ h_ρ_mem
  exact h_box ρ h_ρ_mem

/-- Modal B axiom is valid: `⊨ φ → □◇φ`. -/
theorem modal_b_valid (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := by
  intro T _ _ _ _ F M Omega _h_sc τ h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at]
  intro h_phi σ _h_σ_mem h_box_neg
  exact h_box_neg τ h_mem h_phi

/-- Modal 5 Collapse axiom is valid: `⊨ ◇□φ → □φ`. -/
theorem modal_5_collapse_valid (φ : Formula) : ⊨ (φ.box.diamond.imp φ.box) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [truth_at]
  intro h_diamond_box ρ h_ρ_mem
  by_contra h_not_phi
  apply h_diamond_box
  intro σ h_σ_mem h_box_at_sigma
  exact h_not_phi (h_box_at_sigma ρ h_ρ_mem)

/-- EFQ axiom is valid: `⊨ ⊥ → φ`. -/
theorem ex_falso_valid (φ : Formula) : ⊨ (Formula.bot.imp φ) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_bot
  exfalso
  exact h_bot

/-- Peirce's Law is valid: `⊨ ((φ → ψ) → φ) → φ`. -/
theorem peirce_valid (φ ψ : Formula) : ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
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
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_imp h_box_phi σ h_σ_mem
  exact h_box_imp σ h_σ_mem (h_box_phi σ h_σ_mem)

/-- Temporal K Distribution axiom is valid: `⊨ F(φ → ψ) → (Fφ → Fψ)`. -/
theorem temp_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future_imp h_future_phi s hts
  exact h_future_imp s hts (h_future_phi s hts)

/-- Temporal 4 axiom is valid: `⊨ Gφ → GGφ`.
Under strict semantics, uses transitivity of <. -/
theorem temp_4_valid (φ : Formula) : ⊨ ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_future s hts r hsr
  exact h_future r (lt_trans hts hsr)

/-- Serial future axiom is valid on nontrivial orders: `⊤ → F(⊤)`.
For any time t in a nontrivial ordered group, there exists s > t. -/
theorem serial_future_axiom_valid :
    ⊨ ((Formula.bot.imp Formula.bot).imp (Formula.some_future (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_future, Formula.neg]
  intro _h_top h_G_neg_top
  -- Nontrivial T gives NoMaxOrder T, so exists_gt provides s > t.
  obtain ⟨s, hts⟩ := exists_gt t
  exact h_G_neg_top s hts id

/-- Serial past axiom is valid on nontrivial orders: `⊤ → P(⊤)`.
For any time t in a nontrivial ordered group, there exists s < t. -/
theorem serial_past_axiom_valid :
    ⊨ ((Formula.bot.imp Formula.bot).imp (Formula.some_past (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_past, Formula.neg]
  intro _h_top h_H_neg_top
  -- Nontrivial T gives NoMinOrder T, so exists_lt provides s < t.
  obtain ⟨s, hst⟩ := exists_lt t
  exact h_H_neg_top s hst id

/-- Temporal A axiom is valid: `⊨ φ → G(Pφ)`.
Under strict semantics: if φ at t, then for all s > t, there exists r < s with φ(r) (namely, t). -/
theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_future φ.some_past)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
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
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
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
  -- With strict semantics, h_past covers u < t and h_future covers v > t.
  -- Need φ(r) where r < s. Since s > t:
  -- If r < t, use h_past. If r = t, use h_now. If r > t, use h_future.
  rcases lt_trichotomy r t with h_lt | h_eq | h_gt
  · exact h_past r h_lt
  · exact h_eq ▸ h_now
  · exact h_future r h_gt

/-- MF axiom validity: `□φ → □(Fφ)` is valid. Uses ShiftClosed Omega for time-shift invariance. -/
theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.all_future).box)) := by
  intro T _ _ _ _ F M Omega h_sc τ _h_mem t
  simp only [truth_at]
  intro h_box_phi σ h_σ_mem s hts
  have h_phi_at_shifted := h_box_phi (WorldHistory.time_shift σ (s - t)) (h_sc σ h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M Omega h_sc σ t s φ).mp h_phi_at_shifted

-- Note: temp_future_valid (TF axiom) removed -- TF is now derived from MF + T + Modal 4.
-- Soundness of TF follows from soundness of its component axioms.

/-- Temporal A Dual axiom is valid: `⊨ φ → H(Fφ)`.
Under strict semantics: if φ at t, then for all s < t, there exists r > s with φ(r) (namely, t). -/
theorem temp_a_dual_valid (φ : Formula) : ⊨ (φ.imp (Formula.all_past φ.some_future)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
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
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
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

/-- Past temporal linearity axiom validity (BX11'):
`P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)` is valid.

Mirror of `temp_linearity_valid` for the past direction.
-/
theorem temp_linearity_past_valid (φ ψ : Formula) :
    ⊨ (Formula.and (Formula.some_past φ) (Formula.some_past ψ) |>.imp
      (Formula.or (Formula.some_past (Formula.and φ ψ))
        (Formula.or (Formula.some_past (Formula.and φ (Formula.some_past ψ)))
          (Formula.some_past (Formula.and (Formula.some_past φ) ψ))))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.some_past, Formula.neg, truth_at]
  intro h_conj
  have ⟨s1, hs1t, h_phi_s1⟩ : ∃ s, s < t ∧ truth_at M Omega τ s φ := by
    by_contra h_no; push_neg at h_no
    exact h_conj (fun h1 _ => by
      apply h1; intro s hs h_phi; exact h_no s hs h_phi)
  have ⟨s2, hs2t, h_psi_s2⟩ : ∃ s, s < t ∧ truth_at M Omega τ s ψ := by
    by_contra h_no; push_neg at h_no
    exact h_conj (fun _ h2 => by
      apply h2; intro s hs h_psi; exact h_no s hs h_psi)
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: third disjunct P(P(φ) ∧ ψ)
    intro _
    intro _
    intro h_all_neg_third
    exact h_all_neg_third s2 hs2t (fun h_imp => h_imp
      (fun h_neg_P_phi => h_neg_P_phi s1 h_lt h_phi_s1) h_psi_s2)
  · -- s1 = s2: first disjunct P(φ ∧ ψ)
    subst h_eq
    intro h_neg_first
    exfalso
    apply h_neg_first
    intro h_all_neg_first
    exact h_all_neg_first s1 hs1t (fun h_imp => h_imp h_phi_s1 h_psi_s2)
  · -- s2 < s1: second disjunct P(φ ∧ P(ψ))
    intro _
    intro h_neg_second
    exfalso
    apply h_neg_second
    intro h_all_neg_second
    exact h_all_neg_second s1 hs1t (fun h_imp => h_imp h_phi_s1 (fun h_neg_P_psi =>
      h_neg_P_psi s2 h_gt h_psi_s2))

/-- F-Until equivalence axiom validity (BX12):
`F(φ) → (⊤ U φ)` is valid. Here ⊤ = ⊥ → ⊥.

If F(φ) holds at t, there exists s ≥ t with φ(s). Take this s as the Until witness.
The guard ⊤ is trivially satisfied on (t, s). -/
theorem F_until_equiv_valid (φ : Formula) :
    ⊨ ((Formula.some_future φ).imp (Formula.untl φ (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_future, Formula.neg]
  intro h_F
  by_contra h_not_U
  push_neg at h_not_U
  apply h_F
  intro s hts h_φs
  obtain ⟨_, _, _, hf, _⟩ := h_not_U s hts h_φs
  exact hf

/-- P-Since equivalence axiom validity (BX12'):
`P(φ) → S(φ, ⊤)` is valid. Past dual of F-Until equivalence. -/
theorem P_since_equiv_valid (φ : Formula) :
    ⊨ ((Formula.some_past φ).imp (Formula.snce φ (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_past, Formula.neg]
  intro h_P
  by_contra h_not_S
  push_neg at h_not_S
  apply h_P
  intro s hst h_φs
  obtain ⟨_, _, _, hf, _⟩ := h_not_S s hst h_φs
  exact hf

/-- Density axiom (DN) is valid on dense orders: `⊨_dense GGφ → Gφ`.
Under strict semantics: GGφ → Gφ requires DenselyOrdered. Given s > t,
find r with t < r < s by density, then h_GG(r)(s) gives φ(s). -/
theorem density_valid (φ : Formula) :
    valid_dense ((φ.all_future.all_future).imp φ.all_future) := by
  intro T _ _ _ h_dense _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_GG s hts
  -- h_GG : ∀ r > t, ∀ q > r, φ(q)
  -- hts : t < s
  -- By density, find r with t < r < s
  obtain ⟨r, htr, hrs⟩ := exists_between hts
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
  have ⟨h_F_top, h_phi_and_H⟩ := h1
  have h2 := and_of_not_imp_not h_phi_and_H
  have ⟨h_phi, h_H⟩ := h2
  -- h_H : ∀ r < t, φ(r) (Hφ at t, strict)
  -- h_phi : φ(t)
  -- Use successor: succ(t) > t, and ∀ r < succ(t), r ≤ t, so φ(r) by h_H or h_phi.
  have h_nomax : NoMaxOrder T := inferInstance
  exact h_G_not_H (Order.succ t) (Order.lt_succ_of_not_isMax (not_isMax t)) (fun r hr => by
    rcases lt_or_eq_of_le (Order.le_of_lt_succ hr) with h | h
    · exact h_H r h
    · exact h ▸ h_phi)

/-- Future seriality axiom validity: `⊨_discrete Gφ → Fφ`.
Under strict semantics: Gφ → Fφ requires NoMaxOrder. -/
theorem seriality_future_valid (φ : Formula) :
    valid_discrete (φ.all_future.imp φ.some_future) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_future, Formula.neg, truth_at]
  intro h_G h_neg_F
  -- h_G : ∀ s > t, φ(s) (Gφ at t, strict)
  -- h_neg_F : ∀ s > t, ¬φ(s) (¬Fφ at t, strict)
  -- Need s > t. Use Nontrivial + ordered group structure.
  have : NoMaxOrder T := inferInstance
  obtain ⟨s, hts⟩ := exists_gt t
  exact h_neg_F s hts (h_G s hts)

/-- Past seriality axiom validity: `⊨_discrete Hφ → Pφ`.
Under strict semantics: Hφ → Pφ requires NoMinOrder. -/
theorem seriality_past_valid (φ : Formula) :
    valid_discrete (φ.all_past.imp φ.some_past) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch h_nontriv F M Omega _h_sc τ _h_mem t
  simp only [Formula.some_past, Formula.neg, truth_at]
  intro h_H h_neg_P
  -- h_H : ∀ s < t, φ(s) (Hφ at t, strict)
  -- h_neg_P : ∀ s < t, ¬φ(s) (¬Pφ at t, strict)
  -- Need s < t. Use Nontrivial + ordered group structure.
  have : NoMinOrder T := inferInstance
  obtain ⟨s, hst⟩ := exists_lt t
  exact h_neg_P s hst (h_H s hst)

/-!
## BX2-BX7: Until/Since Axiom Validity

These lemmas prove validity of the Burgess-Xu axioms BX2-BX7 (and their Since mirrors)
on all linear temporal orders with reflexive Until/Since semantics.

**Note on BX4**: Our BX4 is temporal connectedness (`φ → G(P(φ))` and `φ → H(F(φ))`),
which is provably valid under open guard (t,s) semantics. The standard Burgess-Xu A3a
(`φ ∧ (χ U ψ) → χ U (ψ ∧ (χ S φ))`) IS also valid under open guard semantics --
the Until guard interval (t,s) provides the Since guard at the witness since both
intervals are identical. A3a is added separately as BX13 (enrichment_until/since).

Recall the reflexive semantics:
- `φ U ψ` at `t`: ∃ s ≥ t, ψ(s) ∧ ∀ r, t ≤ r < s → φ(r)
- `φ S ψ` at `t`: ∃ s ≤ t, ψ(s) ∧ ∀ r, s < r ≤ t → φ(r)
- `G(φ)` at `t`: ∀ s ≥ t, φ(s)
- `H(φ)` at `t`: ∀ s ≤ t, φ(s)
-/

/-- BX2G: Left monotonicity of Until under G: `G(φ→χ) → ((φ U ψ) → (χ U ψ))`.
Under open guard (t,s): G(φ→χ) gives (φ→χ) at all r > t, covering guard interval (t,s).
No pointwise condition at t needed since the guard is the open interval (t,s). -/
theorem left_mono_until_G_valid (φ χ ψ : Formula) :
    ⊨ ((φ.imp χ).all_future.imp ((Formula.untl ψ φ).imp (Formula.untl ψ χ))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_G ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, h_event, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩

/-- BX2H: Left monotonicity of Since under H: `H(φ→χ) → ((φ S ψ) → (χ S ψ))`.
Under open guard (s,t): H(φ→χ) gives (φ→χ) at all r < t, covering guard interval (s,t).
No pointwise condition at t needed since the guard is the open interval (s,t). -/
theorem left_mono_since_H_valid (φ χ ψ : Formula) :
    ⊨ ((φ.imp χ).all_past.imp ((Formula.snce ψ φ).imp (Formula.snce ψ χ))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_H ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, h_event, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩

/-- BX3: Right monotonicity of Until: `G(φ → ψ) → ((χ U φ) → (χ U ψ))`.
Same witness s; φ(s) and (φ → ψ)(s) give ψ(s). Guard is unchanged. -/
theorem right_mono_until_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp ψ).all_future.imp ((Formula.untl φ χ).imp (Formula.untl ψ χ))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_G ⟨s, hts, h_φs, h_guard⟩
  exact ⟨s, hts, h_G s hts h_φs, h_guard⟩

/-- BX3': Right monotonicity of Since: `H(φ → ψ) → ((χ S φ) → (χ S ψ))`. -/
theorem right_mono_since_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp ψ).all_past.imp ((Formula.snce φ χ).imp (Formula.snce ψ χ))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro h_H ⟨s, hst, h_φs, h_guard⟩
  exact ⟨s, hst, h_H s hst h_φs, h_guard⟩

/-- BX4: Temporal connectedness (future): `φ → G(P(φ))`.
If φ holds now, then at all future times, P(φ) holds.
Proof: for any s ≥ t, P(φ)(s) = ¬H(¬φ)(s) = ¬∀w ≤ s.¬φ(w). Take w = t: t ≤ s, φ(t). -/
theorem connect_future_valid (φ : Formula) :
    ⊨ (φ.imp (φ.some_past.all_future)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_past, Formula.neg]
  intro h_φt s hts h_H_neg
  exact h_H_neg t hts h_φt

/-- BX4': Temporal connectedness (past): `φ → H(F(φ))`.
If φ holds now, then at all past times, F(φ) holds.
Proof: for any s ≤ t, F(φ)(s) = ¬G(¬φ)(s) = ¬∀w ≥ s.¬φ(w). Take w = t: t ≥ s, φ(t). -/
theorem connect_past_valid (φ : Formula) :
    ⊨ (φ.imp (φ.some_future.all_past)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_future, Formula.neg]
  intro h_φt s hst h_G_neg
  exact h_G_neg t hst h_φt

/-- BX13: Until-Since enrichment (Burgess A3a, Xu axiom (3)):
`p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))`.
Valid under open guard (t,s): given p(t) and untl(φ, ψ) at t with witness s > t,
ψ(s), and φ on (t,s). Take same witness s for the conclusion.
- ψ(s) holds (from hypothesis).
- snce(φ, p)(s): take u = t as Since witness. t < s, p(t), and φ on (t,s) = the Until guard.
- Guard φ on (t,s): same as the hypothesis guard. -/
theorem enrichment_until_valid (φ ψ p : Formula) :
    ⊨ (Formula.and p (Formula.untl ψ φ) |>.imp
      (Formula.untl (Formula.and ψ (Formula.snce p φ)) φ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro h_conj
  have h_pt : truth_at M Omega τ t p := by
    by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
  have h_until : ∃ s, t < s ∧ truth_at M Omega τ s ψ ∧
      ∀ r, t < r → r < s → truth_at M Omega τ r φ := by
    by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
  obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
  refine ⟨s, hts, ?_, h_guard⟩
  intro h_imp
  exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩

/-- BX13': Since-Until enrichment (Burgess A3b, Xu axiom (4)):
`p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))`.
Mirror of enrichment_until for the Since direction. -/
theorem enrichment_since_valid (φ ψ p : Formula) :
    ⊨ (Formula.and p (Formula.snce ψ φ) |>.imp
      (Formula.snce (Formula.and ψ (Formula.untl p φ)) φ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro h_conj
  have h_pt : truth_at M Omega τ t p := by
    by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
  have h_since : ∃ s, s < t ∧ truth_at M Omega τ s ψ ∧
      ∀ r, s < r → r < t → truth_at M Omega τ r φ := by
    by_contra h_neg; exact h_conj (fun _ h_s => h_neg h_s)
  obtain ⟨s, hst, h_ψs, h_guard⟩ := h_since
  refine ⟨s, hst, ?_, h_guard⟩
  intro h_imp
  exact h_imp h_ψs ⟨t, hst, h_pt, fun r hsr hrt => h_guard r hsr hrt⟩

/-- BX5: Self-accumulation of Until: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`.
Given φ U ψ with witness s ≥ t: same witness s. Endpoint ψ(s) is unchanged.
Guard at r ∈ (t, s): need φ(r) ∧ (φ U ψ)(r).
φ(r) comes from original guard. (φ U ψ)(r) uses same witness s:
ψ(s), and guard ∀ q ∈ (r, s) is a subset of (t, s). -/
theorem self_accum_until_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl ψ φ).imp
      (Formula.untl ψ (Formula.and φ (Formula.untl ψ φ)))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
  exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs⟩

/-- BX5': Self-accumulation of Since: `(φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)`. -/
theorem self_accum_since_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce ψ φ).imp
      (Formula.snce ψ (Formula.and φ (Formula.snce ψ φ)))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
  exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩

theorem absorb_until_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl (Formula.and φ (Formula.untl ψ φ)) φ).imp (Formula.untl ψ φ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
  -- Extract φ(s₁) and (φ U ψ)(s₁) from the conjunction (encoded as double negation)
  have h_φs₁_and_until : truth_at M Omega τ s₁ φ ∧
      (∃ s₂, s₁ < s₂ ∧ truth_at M Omega τ s₂ ψ ∧
        ∀ q, s₁ < q → q < s₂ → truth_at M Omega τ q φ) := by
    constructor
    · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
    · by_contra h_neg; exact h_conj (fun _ h_until => h_neg h_until)
  obtain ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩ := h_φs₁_and_until
  -- Witness s₂ for the result. Guard covers (t, s₂) via three zones.
  refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
  rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
  · exact h_guard₁ q htq h_lt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₂ q h_gt hqs₂

/-- BX6': Absorption of Since: `(φ S (φ ∧ (φ S ψ))) → (φ S ψ)`. -/
theorem absorb_since_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce (Formula.and φ (Formula.snce ψ φ)) φ).imp (Formula.snce ψ φ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.neg, truth_at]
  intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
  have h_φs₁_and_since : truth_at M Omega τ s₁ φ ∧
      (∃ s₂, s₂ < s₁ ∧ truth_at M Omega τ s₂ ψ ∧
        ∀ q, s₂ < q → q < s₁ → truth_at M Omega τ q φ) := by
    constructor
    · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
    · by_contra h_neg; exact h_conj (fun _ h_since => h_neg h_since)
  obtain ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩ := h_φs₁_and_since
  refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
  rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
  · exact h_guard₂ q hs₂q h_lt
  · exact h_eq ▸ h_φs₁
  · exact h_guard₁ q h_gt hqt

/-- BX7: Linearity of Until:
`(φ U ψ) ∧ (χ U θ) → ((φ ∧ χ) U (ψ ∧ θ)) ∨ ((φ ∧ χ) U (ψ ∧ χ)) ∨ ((φ ∧ χ) U (φ ∧ θ))`.
Given witnesses s1 for φ U ψ and s2 for χ U θ, by linearity s1 ≤ s2 or s2 ≤ s1 or s1 = s2.
- s1 = s2: first disjunct with witness s1.
- s1 < s2: second disjunct with witness s1 (ψ(s1) ∧ χ(s1) where χ(s1) from χ U θ guard).
- s2 < s1: third disjunct with witness s2 (φ(s2) ∧ θ(s2) where φ(s2) from φ U ψ guard). -/
theorem linear_until_valid (φ ψ χ θ : Formula) :
    ⊨ (Formula.and (Formula.untl ψ φ) (Formula.untl θ χ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.untl (Formula.and ψ θ) (Formula.and φ χ))
          (Formula.untl (Formula.and ψ χ) (Formula.and φ χ)))
        (Formula.untl (Formula.and φ θ) (Formula.and φ χ)))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, truth_at]
  intro h_conj
  -- Extract both Until hypotheses from the conjunction encoding
  have h_both : (∃ s, t < s ∧ truth_at M Omega τ s ψ ∧
      ∀ r, t < r → r < s → truth_at M Omega τ r φ) ∧
    (∃ s, t < s ∧ truth_at M Omega τ s θ ∧
      ∀ r, t < r → r < s → truth_at M Omega τ r χ) := by
    constructor
    · by_contra h; exact h_conj (fun h1 _ => h h1)
    · by_contra h; exact h_conj (fun _ h2 => h h2)
  obtain ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩ := h_both
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · -- s₁ < s₂: second disjunct with witness s₁ (ψ(s₁) ∧ χ(s₁))
    intro h_neg; exfalso; apply h_neg; intro _
    refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
    · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ hts₁ h_lt)
    · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (lt_trans hrs h_lt))
  · -- s₁ = s₂: first disjunct with witness s₁ (ψ(s₁) ∧ θ(s₁))
    intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
    refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
    · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
    · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (h_eq ▸ hrs))
  · -- s₂ < s₁: third disjunct with witness s₂ (φ(s₂) ∧ θ(s₂))
    intro _
    refine ⟨s₂, hts₂, ?_, fun r htr hrs h_imp => ?_⟩
    · intro h_neg; exact h_neg (h_guard₁ s₂ hts₂ h_gt) h_θs₂
    · exact h_imp (h_guard₁ r htr (lt_trans hrs h_gt)) (h_guard₂ r htr hrs)

theorem linear_since_valid (φ ψ χ θ : Formula) :
    ⊨ (Formula.and (Formula.snce ψ φ) (Formula.snce θ χ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.snce (Formula.and ψ θ) (Formula.and φ χ))
          (Formula.snce (Formula.and ψ χ) (Formula.and φ χ)))
        (Formula.snce (Formula.and φ θ) (Formula.and φ χ)))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, truth_at]
  intro h_conj
  have h_both : (∃ s, s < t ∧ truth_at M Omega τ s ψ ∧
      ∀ r, s < r → r < t → truth_at M Omega τ r φ) ∧
    (∃ s, s < t ∧ truth_at M Omega τ s θ ∧
      ∀ r, s < r → r < t → truth_at M Omega τ r χ) := by
    constructor
    · by_contra h; exact h_conj (fun h1 _ => h h1)
    · by_contra h; exact h_conj (fun _ h2 => h h2)
  obtain ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩ := h_both
  rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
  · -- s₁ < s₂ < t: third disjunct (φ∧χ) S (φ∧θ) with witness s₂
    -- Goal: (((D₁→F)→D₂)→F) → D₃. For D₃, just intro and prove D₃.
    intro _
    refine ⟨s₂, hs₂t, ?_, fun r hs₂r hrt h_imp => ?_⟩
    · intro h_neg; exact h_neg (h_guard₁ s₂ h_lt hs₂t) h_θs₂
    · exact h_imp (h_guard₁ r (lt_trans h_lt hs₂r) hrt) (h_guard₂ r hs₂r hrt)
  · -- s₁ = s₂: first disjunct (φ∧χ) S (ψ∧θ) with witness s₁
    -- Goal: (((D₁→F)→D₂)→F) → D₃. For D₁: intro h; exfalso; apply h; intro h2; exfalso; apply h2
    intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
    refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
    · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
    · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (h_eq ▸ hs₁r) hrt)
  · -- s₂ < s₁ < t: second disjunct (φ∧χ) S (ψ∧χ) with witness s₁
    -- Goal: (((D₁→F)→D₂)→F) → D₃. For D₂: intro h; exfalso; apply h; intro _; prove D₂
    intro h_outer; exfalso; apply h_outer; intro _
    refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
    · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ h_gt hs₁t)
    · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (lt_trans h_gt hs₁r) hrt)

-- BX7a/BX7a' (linear_until_a7a_valid/linear_since_a7a_valid) REMOVED.
-- Unsound under open guard semantics. See Axioms.lean note.

-- BX8/BX8' (until_step_valid/since_step_valid) REMOVED.
-- BX9/BX9' (until_elim_valid/since_elim_valid) REMOVED.
-- until_guard_valid/since_guard_valid REMOVED.
-- These axioms/theorems are not sound under open guard (t,s).
-- Archived in Boneyard/ClosedGuardLegacy/ClosedGuardSoundness.lean (task 113).

/-- BX10: Until implies eventuality: `(φ U ψ) → F(ψ)`.
F(ψ) = ¬G(¬ψ). Under reflexive Until, witness s ≥ t gives ψ(s), so ¬∀u≥t.¬ψ(u). -/
theorem until_F_valid (φ ψ : Formula) :
    ⊨ ((Formula.untl ψ φ).imp (Formula.some_future ψ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_future, Formula.neg]
  intro ⟨s, hts, h_ψs, _⟩
  intro h_G_neg
  exact h_G_neg s hts h_ψs

/-- BX10': Since implies past eventuality: `(φ S ψ) → P(ψ)`.
P(ψ) = ¬H(¬ψ). Under reflexive Since, witness s ≤ t gives ψ(s), so ¬∀u≤t.¬ψ(u). -/
theorem since_P_valid (φ ψ : Formula) :
    ⊨ ((Formula.snce ψ φ).imp (Formula.some_past ψ)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at, Formula.some_past, Formula.neg]
  intro ⟨s, hst, h_ψs, _⟩
  intro h_H_neg
  exact h_H_neg s hst h_ψs

/-! ## Uniformity Axiom Validity

The following four axioms encode the uniformity of discreteness in ordered abelian groups.
They are valid over ALL `AddCommGroup D` with `IsOrderedAddMonoid D` because the
group's translation invariance ensures that gaps (empty open intervals) are uniform
across all time points.

Key semantic fact: `truth_at M Omega τ t (Formula.untl (bot.imp bot) bot)` means
∃ s > t with (t,s) empty in D. The guard `bot` is always False, so no element can
lie in (t,s). The event `bot.imp bot` is `⊤` which is always True.
-/

/-- Discrete symmetry forward: U(⊤,⊥) → S(⊤,⊥).
If there is a gap (t, s) with s > t, then (t-(s-t), t) is also empty by translation. -/
theorem discrete_symm_fwd_valid :
    ⊨ ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp
      (Formula.snce (Formula.bot.imp Formula.bot) Formula.bot)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro ⟨s, hts, _h_top_s, h_guard⟩
  refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun h => h, fun c hrc hct => ?_⟩
  -- c ∈ (t-(s-t), t), so c+(s-t) ∈ (t, s), but (t,s) is empty
  have h1 : t < c + (s - t) :=
    calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
      _ < c + (s - t) := add_lt_add_left hrc (s - t)
  have h2 : c + (s - t) < s :=
    calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
      _ = s := by rw [add_comm, sub_add_cancel]
  exact h_guard (c + (s - t)) h1 h2

/-- Discrete symmetry backward: S(⊤,⊥) → U(⊤,⊥).
If there is a gap (r, t) with r < t, then (t, t+(t-r)) is also empty by translation. -/
theorem discrete_symm_bwd_valid :
    ⊨ ((Formula.snce (Formula.bot.imp Formula.bot) Formula.bot).imp
      (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot)) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro ⟨r, hrt, _h_top_r, h_guard⟩
  refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun h => h, fun c htc hcs => ?_⟩
  -- c ∈ (t, t+(t-r)), so c-(t-r) ∈ (r, t), but (r,t) is empty
  have h1 : r < c - (t - r) := by
    conv_lhs => rw [(sub_sub_cancel t r).symm]
    exact sub_lt_sub_right htc _
  have h2 : c - (t - r) < t := by
    conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
    exact sub_lt_sub_right hcs _
  exact h_guard (c - (t - r)) h1 h2

/-- Discrete propagation forward: U(⊤,⊥) → G(U(⊤,⊥)).
If there is a gap (t, s), then for any u > t, (u, u+(s-t)) is also empty. -/
theorem discrete_propagate_fwd_valid :
    ⊨ ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp
      (Formula.all_future (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro ⟨s, hts, _h_top_s, h_guard⟩ u _htu
  refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
  -- c ∈ (u, u+(s-t)), so c-(u-t) ∈ (t, s), but (t,s) is empty
  have h1 : t < c - (u - t) := by
    conv_lhs => rw [(sub_sub_cancel u t).symm]
    exact sub_lt_sub_right huc _
  have h2 : c - (u - t) < s := by
    conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
    exact sub_lt_sub_right hcs _
  exact h_guard (c - (u - t)) h1 h2

/-- Discrete propagation backward: U(⊤,⊥) → H(U(⊤,⊥)).
If there is a gap (t, s), then for any u < t, (u, u+(s-t)) is also empty. -/
theorem discrete_propagate_bwd_valid :
    ⊨ ((Formula.untl (Formula.bot.imp Formula.bot) Formula.bot).imp
      (Formula.all_past (Formula.untl (Formula.bot.imp Formula.bot) Formula.bot))) := by
  intro T _ _ _ _ F M Omega _h_sc τ _h_mem t
  simp only [truth_at]
  intro ⟨s, hts, _h_top_s, h_guard⟩ u _hut
  refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
  -- c ∈ (u, u+(s-t)), so c-(u-t) ∈ (t, s), but (t,s) is empty
  have h1 : t < c - (u - t) := by
    conv_lhs => rw [(sub_sub_cancel u t).symm]
    exact sub_lt_sub_right huc _
  have h2 : c - (u - t) < s := by
    conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
    exact sub_lt_sub_right hcs _
  exact h_guard (c - (u - t)) h1 h2

/-! ## Legacy Discrete Axiom Validity Theorems (Removed)

The following discrete axiom validity theorems were removed in the BX refactor:
- disc_next_valid, disc_prev_valid
- until_unfold_valid, until_intro_valid, until_induction_valid, until_linearity_valid
- since_unfold_valid, since_intro_valid, since_induction_valid, since_linearity_valid
- until_connectedness_valid, since_connectedness_valid
- F_until_equiv_valid, P_since_equiv_valid
- Discrete operator axioms (bot-Until K-distribution, determinism, identity)

These proved validity for discrete axioms that no longer exist in the BX axiom system.
The BX system uses self-accumulation (BX5/BX6) and linearity (BX7) instead.
-/

/-- Prior-UZ is valid on discrete orders: F(φ) → U(φ, ¬φ).
If φ holds at some future time, there is a nearest future time where φ holds. -/
theorem prior_UZ_valid (φ : Formula) : valid_discrete (φ.some_future.imp (Formula.untl φ φ.neg)) := by
  intro D _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t
  exact SoundnessLemmas.prior_UZ_is_valid φ F M Omega h_sc τ h_mem t

/-- Prior-SZ is valid on discrete orders: P(φ) → S(φ, ¬φ).
If φ held at some past time, there is a nearest past time where φ held. -/
theorem prior_SZ_valid (φ : Formula) : valid_discrete (φ.some_past.imp (Formula.snce φ φ.neg)) := by
  intro D _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t
  exact SoundnessLemmas.prior_SZ_is_valid φ F M Omega h_sc τ h_mem t

/-- Z1 is valid on discrete orders: G(Gφ→φ) → (FGφ→Gφ).
Backward induction from the Gφ witness using IsSuccArchimedean. -/
theorem z1_valid (φ : Formula) : valid_discrete
    ((φ.all_future.imp φ).all_future.imp (φ.all_future.some_future.imp φ.all_future)) := by
  intro D _ _ _ _ _ _ _ _ F M Omega h_sc τ h_mem t
  exact SoundnessLemmas.z1_is_valid φ F M Omega h_sc τ h_mem t

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
  | serial_future => exact serial_future_axiom_valid
  | serial_past => exact serial_past_axiom_valid
  | left_mono_until_G φ χ ψ => exact left_mono_until_G_valid φ χ ψ
  | left_mono_since_H φ χ ψ => exact left_mono_since_H_valid φ χ ψ
  | right_mono_until φ ψ χ => exact right_mono_until_valid φ ψ χ
  | right_mono_since φ ψ χ => exact right_mono_since_valid φ ψ χ
  | connect_future _ => exact connect_future_valid _
  | connect_past _ => exact connect_past_valid _
  | enrichment_until φ ψ p => exact enrichment_until_valid φ ψ p
  | enrichment_since φ ψ p => exact enrichment_since_valid φ ψ p
  | self_accum_until φ ψ => exact self_accum_until_valid φ ψ
  | self_accum_since φ ψ => exact self_accum_since_valid φ ψ
  | absorb_until φ ψ => exact absorb_until_valid φ ψ
  | absorb_since φ ψ => exact absorb_since_valid φ ψ
  | linear_until _ _ _ _ => exact linear_until_valid _ _ _ _
  | linear_since _ _ _ _ => exact linear_since_valid _ _ _ _
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim / until_guard / since_guard removed (task 113)
  | until_F φ ψ => exact until_F_valid φ ψ
  | since_P φ ψ => exact since_P_valid φ ψ
  | temp_linearity φ ψ => exact temp_linearity_valid φ ψ
  | temp_linearity_past φ ψ => exact temp_linearity_past_valid φ ψ
  | F_until_equiv φ => exact F_until_equiv_valid φ
  | P_since_equiv φ => exact P_since_equiv_valid φ
  | modal_future ψ => exact modal_future_valid ψ
  | discrete_symm_fwd => exact discrete_symm_fwd_valid
  | discrete_symm_bwd => exact discrete_symm_bwd_valid
  | discrete_propagate_fwd => exact discrete_propagate_fwd_valid
  | discrete_propagate_bwd => exact discrete_propagate_bwd_valid
  | prior_UZ _ => exact absurd h_base (by simp [Axiom.isBase])
  | prior_SZ _ => exact absurd h_base (by simp [Axiom.isBase])
  | z1 _ => exact absurd h_base (by simp [Axiom.isBase])

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
  | serial_future => exact Validity.valid_implies_valid_dense serial_future_axiom_valid
  | serial_past => exact Validity.valid_implies_valid_dense serial_past_axiom_valid
  | left_mono_until_G φ χ ψ => exact Validity.valid_implies_valid_dense (left_mono_until_G_valid φ χ ψ)
  | left_mono_since_H φ χ ψ => exact Validity.valid_implies_valid_dense (left_mono_since_H_valid φ χ ψ)
  | right_mono_until φ ψ χ => exact Validity.valid_implies_valid_dense (right_mono_until_valid φ ψ χ)
  | right_mono_since φ ψ χ => exact Validity.valid_implies_valid_dense (right_mono_since_valid φ ψ χ)
  | connect_future _ => exact Validity.valid_implies_valid_dense (connect_future_valid _)
  | connect_past _ => exact Validity.valid_implies_valid_dense (connect_past_valid _)
  | enrichment_until φ ψ p => exact Validity.valid_implies_valid_dense (enrichment_until_valid φ ψ p)
  | enrichment_since φ ψ p => exact Validity.valid_implies_valid_dense (enrichment_since_valid φ ψ p)

  | self_accum_until φ ψ => exact Validity.valid_implies_valid_dense (self_accum_until_valid φ ψ)
  | self_accum_since φ ψ => exact Validity.valid_implies_valid_dense (self_accum_since_valid φ ψ)
  | absorb_until φ ψ => exact Validity.valid_implies_valid_dense (absorb_until_valid φ ψ)
  | absorb_since φ ψ => exact Validity.valid_implies_valid_dense (absorb_since_valid φ ψ)
  | linear_until _ _ _ _ => exact Validity.valid_implies_valid_dense (linear_until_valid _ _ _ _)
  | linear_since _ _ _ _ => exact Validity.valid_implies_valid_dense (linear_since_valid _ _ _ _)
  -- NOTE: until_elim / since_elim / until_guard / since_guard removed (task 113)
  | until_F φ ψ => exact Validity.valid_implies_valid_dense (until_F_valid φ ψ)
  | since_P φ ψ => exact Validity.valid_implies_valid_dense (since_P_valid φ ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_dense (temp_linearity_valid φ ψ)
  | temp_linearity_past φ ψ => exact Validity.valid_implies_valid_dense (temp_linearity_past_valid φ ψ)
  | F_until_equiv φ => exact Validity.valid_implies_valid_dense (F_until_equiv_valid φ)
  | P_since_equiv φ => exact Validity.valid_implies_valid_dense (P_since_equiv_valid φ)
  | modal_future ψ => exact Validity.valid_implies_valid_dense (modal_future_valid ψ)
  | discrete_symm_fwd => exact Validity.valid_implies_valid_dense discrete_symm_fwd_valid
  | discrete_symm_bwd => exact Validity.valid_implies_valid_dense discrete_symm_bwd_valid
  | discrete_propagate_fwd => exact Validity.valid_implies_valid_dense discrete_propagate_fwd_valid
  | discrete_propagate_bwd => exact Validity.valid_implies_valid_dense discrete_propagate_bwd_valid
  | prior_UZ _ => exact absurd h_dc (by simp [Axiom.isDenseCompatible])
  | prior_SZ _ => exact absurd h_dc (by simp [Axiom.isDenseCompatible])
  | z1 _ => exact absurd h_dc (by simp [Axiom.isDenseCompatible])

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
  | serial_future => exact Validity.valid_implies_valid_discrete serial_future_axiom_valid
  | serial_past => exact Validity.valid_implies_valid_discrete serial_past_axiom_valid
  | left_mono_until_G φ χ ψ => exact Validity.valid_implies_valid_discrete (left_mono_until_G_valid φ χ ψ)
  | left_mono_since_H φ χ ψ => exact Validity.valid_implies_valid_discrete (left_mono_since_H_valid φ χ ψ)
  | right_mono_until φ ψ χ => exact Validity.valid_implies_valid_discrete (right_mono_until_valid φ ψ χ)
  | right_mono_since φ ψ χ => exact Validity.valid_implies_valid_discrete (right_mono_since_valid φ ψ χ)
  | connect_future _ => exact Validity.valid_implies_valid_discrete (connect_future_valid _)
  | connect_past _ => exact Validity.valid_implies_valid_discrete (connect_past_valid _)
  | enrichment_until φ ψ p => exact Validity.valid_implies_valid_discrete (enrichment_until_valid φ ψ p)
  | enrichment_since φ ψ p => exact Validity.valid_implies_valid_discrete (enrichment_since_valid φ ψ p)

  | self_accum_until φ ψ => exact Validity.valid_implies_valid_discrete (self_accum_until_valid φ ψ)
  | self_accum_since φ ψ => exact Validity.valid_implies_valid_discrete (self_accum_since_valid φ ψ)
  | absorb_until φ ψ => exact Validity.valid_implies_valid_discrete (absorb_until_valid φ ψ)
  | absorb_since φ ψ => exact Validity.valid_implies_valid_discrete (absorb_since_valid φ ψ)
  | linear_until _ _ _ _ => exact Validity.valid_implies_valid_discrete (linear_until_valid _ _ _ _)
  | linear_since _ _ _ _ => exact Validity.valid_implies_valid_discrete (linear_since_valid _ _ _ _)
  -- NOTE: until_elim / since_elim / until_guard / since_guard removed (task 113)
  | until_F φ ψ => exact Validity.valid_implies_valid_discrete (until_F_valid φ ψ)
  | since_P φ ψ => exact Validity.valid_implies_valid_discrete (since_P_valid φ ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_discrete (temp_linearity_valid φ ψ)
  | temp_linearity_past φ ψ => exact Validity.valid_implies_valid_discrete (temp_linearity_past_valid φ ψ)
  | F_until_equiv φ => exact Validity.valid_implies_valid_discrete (F_until_equiv_valid φ)
  | P_since_equiv φ => exact Validity.valid_implies_valid_discrete (P_since_equiv_valid φ)
  | modal_future ψ => exact Validity.valid_implies_valid_discrete (modal_future_valid ψ)
  | discrete_symm_fwd => exact Validity.valid_implies_valid_discrete discrete_symm_fwd_valid
  | discrete_symm_bwd => exact Validity.valid_implies_valid_discrete discrete_symm_bwd_valid
  | discrete_propagate_fwd => exact Validity.valid_implies_valid_discrete discrete_propagate_fwd_valid
  | discrete_propagate_bwd => exact Validity.valid_implies_valid_discrete discrete_propagate_bwd_valid
  | prior_UZ φ => exact prior_UZ_valid φ
  | prior_SZ φ => exact prior_SZ_valid φ
  | z1 φ => exact z1_valid φ

/-! ## Full Derivation Soundness

The main soundness theorem showing derivability implies semantic consequence.
-/

/--
Necessitation rule preserves validity: if φ is universally valid, then □φ is universally valid.

This is semantic: if φ holds at all (M, Omega, τ, t), then for any model at any time,
□φ holds because we quantify over all histories in Omega, and φ holds at all of them.
-/
theorem necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨ (Formula.box φ) := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t
  simp only [truth_at]
  intro σ h_σ_mem
  exact h D F M Omega h_sc σ h_σ_mem t

/--
Temporal necessitation preserves validity: if φ is universally valid, then Gφ is universally valid.

This is semantic: if φ holds at all (M, Omega, τ, t), then at any time s ≥ t, φ holds at (τ, s).
-/
theorem temporal_necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨ (Formula.all_future φ) := by
  intro D _ _ _ _ F M Omega h_sc τ h_mem t
  simp only [truth_at]
  intro s _hts
  exact h D F M Omega h_sc τ h_mem s

/--
**Soundness Theorem (Dense-Compatible)**: Derivability implies semantic consequence
for dense-compatible derivations.

If `Γ ⊢ φ` with a dense-compatible derivation, then `Γ ⊨ φ`.
Dense-compatibility excludes Prior-UZ/SZ which are only valid on discrete frames.

The proof proceeds by induction on the derivation tree structure:
- **Axiom**: Use the axiom validity theorems (Prior-UZ/SZ excluded by h_dc)
- **Assumption**: If φ ∈ Γ and all of Γ holds, then φ holds
- **Modus ponens**: If Γ ⊨ φ → ψ and Γ ⊨ φ, then Γ ⊨ ψ
- **Necessitation**: Uses `necessitation_preserves_valid`
- **Temporal necessitation**: Uses `temporal_necessitation_preserves_valid`
- **Temporal duality**: Uses `SoundnessLemmas.derivable_implies_swap_valid_general`
- **Weakening**: Monotonicity of semantic consequence

**Note**: Prior-UZ/SZ are excluded via the `h_dc` guard since they are not universally
valid (they fail on dense orders like Q). Use `soundness_discrete` for derivations
containing Prior-UZ/SZ.
-/
theorem soundness (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ) (h_dc : d.isDenseCompatible)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) :
    truth_at M Omega τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax =>
    -- All dense-compatible axioms are universally valid; Prior-UZ/SZ excluded by h_dc
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
    | serial_future => exact serial_future_axiom_valid D F M Omega h_sc τ h_mem t
    | serial_past => exact serial_past_axiom_valid D F M Omega h_sc τ h_mem t
    | left_mono_until_G φ χ ψ => exact left_mono_until_G_valid φ χ ψ D F M Omega h_sc τ h_mem t
    | left_mono_since_H φ χ ψ => exact left_mono_since_H_valid φ χ ψ D F M Omega h_sc τ h_mem t
    | right_mono_until φ ψ χ => exact right_mono_until_valid φ ψ χ D F M Omega h_sc τ h_mem t
    | right_mono_since φ ψ χ => exact right_mono_since_valid φ ψ χ D F M Omega h_sc τ h_mem t
    | connect_future φ => exact connect_future_valid φ D F M Omega h_sc τ h_mem t
    | connect_past φ => exact connect_past_valid φ D F M Omega h_sc τ h_mem t
    | enrichment_until φ ψ p => exact enrichment_until_valid φ ψ p D F M Omega h_sc τ h_mem t
    | enrichment_since φ ψ p => exact enrichment_since_valid φ ψ p D F M Omega h_sc τ h_mem t

    | self_accum_until φ ψ => exact self_accum_until_valid φ ψ D F M Omega h_sc τ h_mem t
    | self_accum_since φ ψ => exact self_accum_since_valid φ ψ D F M Omega h_sc τ h_mem t
    | absorb_until φ ψ => exact absorb_until_valid φ ψ D F M Omega h_sc τ h_mem t
    | absorb_since φ ψ => exact absorb_since_valid φ ψ D F M Omega h_sc τ h_mem t
    | linear_until φ ψ χ θ => exact linear_until_valid φ ψ χ θ D F M Omega h_sc τ h_mem t
    | linear_since φ ψ χ θ => exact linear_since_valid φ ψ χ θ D F M Omega h_sc τ h_mem t
    -- NOTE: until_elim / since_elim / until_guard / since_guard removed (task 113)
    | until_F φ ψ => exact until_F_valid φ ψ D F M Omega h_sc τ h_mem t
    | since_P φ ψ => exact since_P_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_linearity_past φ ψ => exact temp_linearity_past_valid φ ψ D F M Omega h_sc τ h_mem t
    | F_until_equiv φ => exact F_until_equiv_valid φ D F M Omega h_sc τ h_mem t
    | P_since_equiv φ => exact P_since_equiv_valid φ D F M Omega h_sc τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M Omega h_sc τ h_mem t

    | discrete_symm_fwd => exact discrete_symm_fwd_valid D F M Omega h_sc τ h_mem t
    | discrete_symm_bwd => exact discrete_symm_bwd_valid D F M Omega h_sc τ h_mem t
    | discrete_propagate_fwd => exact discrete_propagate_fwd_valid D F M Omega h_sc τ h_mem t
    | discrete_propagate_bwd => exact discrete_propagate_bwd_valid D F M Omega h_sc τ h_mem t
    | prior_UZ _ => exact absurd h_dc (by simp [DerivationTree.isDenseCompatible, Axiom.isDenseCompatible])
    | prior_SZ _ => exact absurd h_dc (by simp [DerivationTree.isDenseCompatible, Axiom.isDenseCompatible])
    | z1 _ => exact absurd h_dc (by simp [DerivationTree.isDenseCompatible, Axiom.isDenseCompatible])
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
    exact ih h_dc σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [truth_at]
    intro s _hts
    exact ih h_dc τ h_mem s (by simp)
  | temporal_duality φ' d' ih =>
    -- d' : ⊢ φ', goal is truth_at ... φ'.swap_temporal
    -- Use general swap validity with dense-compatibility guard
    exact SoundnessLemmas.derivable_implies_swap_valid_general d' h_dc F M Omega h_sc τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih h_dc τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

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
    | serial_future => exact serial_future_axiom_valid D F M Omega h_sc τ h_mem t
    | serial_past => exact serial_past_axiom_valid D F M Omega h_sc τ h_mem t
    | left_mono_until_G φ χ ψ => exact left_mono_until_G_valid φ χ ψ D F M Omega h_sc τ h_mem t
    | left_mono_since_H φ χ ψ => exact left_mono_since_H_valid φ χ ψ D F M Omega h_sc τ h_mem t
    | right_mono_until φ ψ χ => exact right_mono_until_valid φ ψ χ D F M Omega h_sc τ h_mem t
    | right_mono_since φ ψ χ => exact right_mono_since_valid φ ψ χ D F M Omega h_sc τ h_mem t
    | connect_future φ => exact connect_future_valid φ D F M Omega h_sc τ h_mem t
    | connect_past φ => exact connect_past_valid φ D F M Omega h_sc τ h_mem t
    | enrichment_until φ ψ p => exact enrichment_until_valid φ ψ p D F M Omega h_sc τ h_mem t
    | enrichment_since φ ψ p => exact enrichment_since_valid φ ψ p D F M Omega h_sc τ h_mem t

    | self_accum_until φ ψ => exact self_accum_until_valid φ ψ D F M Omega h_sc τ h_mem t
    | self_accum_since φ ψ => exact self_accum_since_valid φ ψ D F M Omega h_sc τ h_mem t
    | absorb_until φ ψ => exact absorb_until_valid φ ψ D F M Omega h_sc τ h_mem t
    | absorb_since φ ψ => exact absorb_since_valid φ ψ D F M Omega h_sc τ h_mem t
    | linear_until φ ψ χ θ => exact linear_until_valid φ ψ χ θ D F M Omega h_sc τ h_mem t
    | linear_since φ ψ χ θ => exact linear_since_valid φ ψ χ θ D F M Omega h_sc τ h_mem t
    -- NOTE: until_elim / since_elim / until_guard / since_guard removed (task 113)
    | until_F φ ψ => exact until_F_valid φ ψ D F M Omega h_sc τ h_mem t
    | since_P φ ψ => exact since_P_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M Omega h_sc τ h_mem t
    | temp_linearity_past φ ψ => exact temp_linearity_past_valid φ ψ D F M Omega h_sc τ h_mem t
    | F_until_equiv φ => exact F_until_equiv_valid φ D F M Omega h_sc τ h_mem t
    | P_since_equiv φ => exact P_since_equiv_valid φ D F M Omega h_sc τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M Omega h_sc τ h_mem t

    | discrete_symm_fwd => exact discrete_symm_fwd_valid D F M Omega h_sc τ h_mem t
    | discrete_symm_bwd => exact discrete_symm_bwd_valid D F M Omega h_sc τ h_mem t
    | discrete_propagate_fwd => exact discrete_propagate_fwd_valid D F M Omega h_sc τ h_mem t
    | discrete_propagate_bwd => exact discrete_propagate_bwd_valid D F M Omega h_sc τ h_mem t
    | prior_UZ _ => exact absurd h_dc (by simp [DerivationTree.isDenseCompatible, Axiom.isDenseCompatible])
    | prior_SZ _ => exact absurd h_dc (by simp [DerivationTree.isDenseCompatible, Axiom.isDenseCompatible])
    | z1 _ => exact absurd h_dc (by simp [DerivationTree.isDenseCompatible, Axiom.isDenseCompatible])
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

/-! ## Discrete Frame Soundness Theorems

Analogous to `soundness_dense_valid` and `soundness_dense` above, these theorems
provide soundness for discrete-compatible derivations on discrete frame types.
-/

/--
**Soundness Discrete Valid**: Derivability from empty context implies discrete validity.

For discrete-compatible derivations from empty context, the derived formula is
valid on all discrete frames.

**Note on temporal_duality**: The temporal_duality case uses
`derivable_implies_swap_valid_general` from SoundnessLemmas.lean, which proves
swap-validity without frame-class constraints. No separate discrete version is
needed because the BX axiom system has no frame-class extension axioms.
-/
theorem soundness_discrete_valid {phi : Formula}
    (d : DerivationTree [] phi) (h_dc : d.isDiscreteCompatible) : valid_discrete phi := by
  match d with
  | .axiom _ _ h_ax =>
    exact axiom_valid_discrete h_ax h_dc
  | .assumption _ _ h_mem =>
    exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ psi' _ d1 d2 =>
    obtain ⟨h_dc1, h_dc2⟩ := h_dc
    have h1 := soundness_discrete_valid d1 h_dc1
    have h2 := soundness_discrete_valid d2 h_dc2
    intro D _ _ _ _ _ _ _ _ F M Omega h_sc tau h_mem t
    have h1' := h1 D F M Omega h_sc tau h_mem t
    have h2' := h2 D F M Omega h_sc tau h_mem t
    simp only [truth_at] at h1'
    exact h1' h2'
  | .necessitation psi' d' =>
    have h := soundness_discrete_valid d' h_dc
    intro D _ _ _ _ _ _ _ _ F M Omega h_sc tau h_mem t
    simp only [truth_at]
    intro sigma h_sigma_mem
    exact h D F M Omega h_sc sigma h_sigma_mem t
  | .temporal_necessitation psi' d' =>
    have h := soundness_discrete_valid d' h_dc
    intro D _ _ _ _ _ _ _ _ F M Omega h_sc tau h_mem t
    simp only [truth_at]
    intro s _hts
    exact h D F M Omega h_sc tau h_mem s
  | .temporal_duality psi' d' =>
    -- Use discrete swap validity for derivations that may contain Prior-UZ/SZ
    intro D _ _ _ _ _ _ _ _ F M Omega h_sc tau h_mem t
    exact SoundnessLemmas.derivable_implies_swap_valid_discrete d' F M Omega h_sc tau h_mem t
  | .weakening Gamma' _ _ d' h_sub =>
    have h_eq : Gamma' = [] := List.eq_nil_of_subset_nil h_sub
    have h_dc_sub : (h_eq ▸ d').isDiscreteCompatible := by
      simp only [DerivationTree.isDiscreteCompatible] at h_dc
      subst h_eq
      exact h_dc
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Gamma' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact soundness_discrete_valid (h_eq ▸ d') h_dc_sub
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/--
**Soundness for Discrete Frames**: Derivability implies semantic consequence on discrete frames.

This is the discrete analogue of `soundness_dense`. Given a discrete-compatible
derivation `Γ ⊢ φ`, if all formulas in `Γ` are true at some configuration on a
discrete frame, then `φ` is also true there.
-/
theorem soundness_discrete (Γ : Context) (φ : Formula)
    (d : DerivationTree Γ φ) (h_dc : d.isDiscreteCompatible)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, truth_at M Omega τ t ψ) :
    truth_at M Omega τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax =>
    exact axiom_valid_discrete h_ax h_dc D F M Omega h_sc τ h_mem t
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
    exact ih h_dc σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [truth_at]
    intro s _hts
    exact ih h_dc τ h_mem s (by simp)
  | temporal_duality φ' d' ih =>
    -- Use discrete swap validity for derivations that may contain Prior-UZ/SZ
    exact SoundnessLemmas.derivable_implies_swap_valid_discrete d' F M Omega h_sc τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih h_dc τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

end Bimodal.Metalogic
