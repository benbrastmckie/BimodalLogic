/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.ProofSystem.Derivable
import FormalSystem.Semantics.Validity
import FormalSystem.Metalogic.SoundnessLemmas.FrameClassVariants
import FormalSystem.Metalogic.SoundnessLemmas.Separability

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
- `axiom_valid`: Base axioms are universally valid
- `axiom_dense_valid`: Dense-compatible axioms are valid on dense frames
- `axiom_discrete_valid`: Discrete-compatible axioms are valid on discrete frames

## Implementation Notes

**Completed Proofs**:
- Base axiom validity lemmas: prop_k, prop_s, ex_falso, peirce, MT, M4, MB, M5_collapse,
  MK_dist, TK_dist, T4, TA, TL, MF, TF, linearity (universally valid)
- Frame-class axiom validity: density (ValidDense), discreteness_forward (ValidDiscrete)
- axiom_valid, axiom_dense_valid, axiom_discrete_valid (combined validators)

**Key Techniques**:
- Time-shift invariance (MF, TF): Uses `WorldHistory.timeShift` and
  `TimeShift.time_shift_preserves_truth` to relate truth at different times
- Classical logic helpers for conjunction extraction (TL)
- Derivation-indexed induction for temporal duality soundness

**Totality Parameterization**:
Validity and semantic consequence quantify over the frame's **total** histories
(`τ.IsTotal`, the predicate form of `H_F` membership), matching `def:logical-consequence`.
There is no admissible-history parameter and no shift-closure side condition: totality is
preserved by `timeShift` (`WorldHistory.isTotal_timeShift`), so time-shift invariance carries
no hypothesis to quantify over. `TruthAt`'s remaining set argument is inert and is supplied
as `Set.univ`.

## Full Derivation Soundness

The theorem `soundness : (Γ ⊢ φ) → (Γ ⊨ φ)` follows from:
1. **Axiom validity**: `axiom_valid`, `axiom_dense_valid`, `axiom_discrete_valid`
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
Prior-UZ/SZ are excluded from dense derivations by the `h.minFrameClass ≤ .Dense` constraint
(their `minFrameClass = .Discrete` is incomparable with `.Dense`).

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - Soundness specification
* [Derivation.lean](../../ProofSystem/Derivation.lean) - Derivability relation
* [Validity.lean](../../Semantics/Validity.lean) - Semantic validity
* [SoundnessLemmas.lean](./SoundnessLemmas.lean) - Axiom validity and swap preservation
* [IRRSoundness.lean](./IRRSoundness.lean) - IRR rule soundness
* JPL Paper app:valid (line 1984) - Perpetuity principle validity proofs
-/

namespace FormalSystem.Metalogic

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Semantics

/-! ## Classical Logic Helper -/

/-- Helper lemma for extracting conjunction from negated implication encoding. -/
private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

/-- Propositional K axiom is valid. -/
theorem prop_k_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
  intro h1 h2 h_phi
  exact h1 h_phi (h2 h_phi)

/-- Propositional S axiom is valid. -/
theorem prop_s_valid (φ ψ : Formula) : ⊨ (φ.imp (ψ.imp φ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
  intro h_phi _
  exact h_phi

/-- Modal T axiom is valid: `⊨ □φ → φ`. -/
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro T _ _ _ _ F M τ h_mem t
  simp only [TruthAt]
  intro h_box
  exact h_box τ h_mem

/-- Modal 4 axiom is valid: `⊨ □φ → □□φ`. -/
theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
  intro h_box σ h_σ_mem ρ h_ρ_mem
  exact h_box ρ h_ρ_mem

/-- Modal B axiom is valid: `⊨ φ → □◇φ`. -/
theorem modal_b_valid (φ : Formula) : ⊨ (φ.imp (φ.diamond.box)) := by
  intro T _ _ _ _ F M τ h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [TruthAt]
  intro h_phi σ _h_σ_mem h_box_neg
  exact h_box_neg τ h_mem h_phi

/-- Modal 5 Collapse axiom is valid: `⊨ ◇□φ → □φ`. -/
theorem modal_5_collapse_valid (φ : Formula) : ⊨ (φ.box.diamond.imp φ.box) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.diamond, Formula.neg]
  simp only [TruthAt]
  intro h_diamond_box ρ h_ρ_mem
  by_contra h_not_phi
  apply h_diamond_box
  intro σ h_σ_mem h_box_at_sigma
  exact h_not_phi (h_box_at_sigma ρ h_ρ_mem)

/-- EFQ axiom is valid: `⊨ ⊥ → φ`. -/
theorem ex_falso_valid (φ : Formula) : ⊨ (Formula.bot.imp φ) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
  intro h_bot
  exfalso
  exact h_bot

/-- Peirce's Law is valid: `⊨ ((φ → ψ) → φ) → φ`. -/
theorem peirce_valid (φ ψ : Formula) : ⊨ (((φ.imp ψ).imp φ).imp φ) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
  intro h_peirce
  by_cases h : TruthAt M τ t φ
  · exact h
  · have h_imp : TruthAt M τ t (φ.imp ψ) := by
      simp only [TruthAt]
      intro h_phi
      exfalso
      exact h h_phi
    exact h_peirce h_imp

/-- Modal K Distribution axiom is valid: `⊨ □(φ → ψ) → (□φ → □ψ)`. -/
theorem modal_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
  intro h_box_imp h_box_phi σ h_σ_mem
  exact h_box_imp σ h_σ_mem (h_box_phi σ h_σ_mem)

/-- Temporal K Distribution axiom is valid: `⊨ F(φ → ψ) → (Fφ → Fψ)`. -/
theorem temp_k_dist_valid (φ ψ : Formula) :
    ⊨ ((φ.imp ψ).allFuture.imp (φ.allFuture.imp ψ.allFuture)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff]
  intro h_future_imp h_future_phi s hts
  exact h_future_imp s hts (h_future_phi s hts)

/-- Temporal 4 axiom is valid: `⊨ Gφ → GGφ`.
Under strict semantics, uses transitivity of <. -/
theorem temp_4_valid (φ : Formula) : ⊨ ((φ.allFuture).imp (φ.allFuture.allFuture)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff]
  intro h_future s hts r hsr
  exact h_future r (lt_trans hts hsr)

/-- Serial future axiom is valid on nontrivial orders: `⊤ → F(⊤)`.
For any time t in a nontrivial ordered group, there exists s > t. -/
theorem serial_future_axiom_valid :
    ⊨ ((Formula.bot.imp Formula.bot).imp (Formula.someFuture (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.some_future_iff]
  intro _h_top
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, id⟩

/-- Serial past axiom is valid on nontrivial orders: `⊤ → P(⊤)`.
For any time t in a nontrivial ordered group, there exists s < t. -/
theorem serial_past_axiom_valid :
    ⊨ ((Formula.bot.imp Formula.bot).imp (Formula.somePast (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.some_past_iff]
  intro _h_top
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, id⟩

/-- Temporal A axiom is valid: `⊨ φ → G(Pφ)`.
Under strict semantics: if φ at t, then for all s > t, there exists r < s with φ(r) (namely, t). -/
theorem temp_a_valid (φ : Formula) : ⊨ (φ.imp (Formula.allFuture φ.somePast)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff, Truth.some_past_iff]
  intro h_phi s hts
  exact ⟨t, hts, h_phi⟩

/-- TL axiom validity: `△φ → G(Hφ)` is valid.
Under strict semantics, △φ = Hφ ∧ φ ∧ Gφ encodes: (∀ u < t, φ(u)) ∧ φ(t) ∧ (∀ v > t, φ(v)).
The goal G(Hφ) requires: ∀ s > t, ∀ r < s, φ(r).
This is implied by the △φ hypothesis which covers all times. -/
theorem temp_l_valid (φ : Formula) :
    ⊨ (φ.always.imp (Formula.allFuture (Formula.allPast φ))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff, Truth.past_iff]
  intro h_always s _hts r hrs
  simp only [Formula.always, Formula.and, Formula.neg, TruthAt,
    Truth.future_iff, Truth.past_iff] at h_always
  -- Under strict semantics, always encodes: (∀ u < t, φ(u)) ∧ ((φ(t) → (∀ v > t, φ(v)) → ⊥) → ⊥)
  have h1 :
    (∀ (u : T), u < t → TruthAt M τ u φ) ∧
    ((TruthAt M τ t φ →
      (∀ (v : T), t < v → TruthAt M τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : TruthAt M τ t φ ∧ (∀ (v : T), t < v → TruthAt M τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2
  rcases lt_trichotomy r t with h_lt | h_eq | h_gt
  · exact h_past r h_lt
  · exact h_eq ▸ h_now
  · exact h_future r h_gt

/-- MF axiom validity: `□φ → □(Fφ)` is valid. Time-shift invariance carries no side condition:
totality of the shifted history is `WorldHistory.isTotal_timeShift`. -/
theorem modal_future_valid (φ : Formula) : ⊨ ((φ.box).imp ((φ.allFuture).box)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff]
  intro h_box_phi σ h_σ_mem s hts
  have h_phi_at_shifted :=
    h_box_phi (WorldHistory.timeShift σ (s - t))
      (WorldHistory.isTotal_timeShift h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M σ t s φ).mp h_phi_at_shifted

/-- Temporal A Dual axiom is valid: `⊨ φ → H(Fφ)`.
Under strict semantics: if φ at t, then for all s < t, there exists r > s with φ(r) (namely, t). -/
theorem temp_a_dual_valid (φ : Formula) : ⊨ (φ.imp (Formula.allPast φ.someFuture)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.past_iff, Truth.some_future_iff]
  intro h_phi s hst
  exact ⟨t, hst, h_phi⟩

/-- Temporal linearity axiom validity:
`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)` is valid.

Uses linearity of D (LinearOrder instance).
Under strict semantics, F quantifies over s > t.
-/
theorem temp_linearity_valid (φ ψ : Formula) :
    ⊨ (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and φ ψ))
        (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
          (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, TruthAt,
    Truth.some_future_iff]
  intro h_conj
  -- Extract F(phi) and F(psi) witnesses from the conjunction
  have h_F_phi : ∃ s, t < s ∧ TruthAt M τ s φ := by
    by_contra h_no
    exact h_conj (fun h1 _ => h_no h1)
  have h_F_psi : ∃ s, t < s ∧ TruthAt M τ s ψ := by
    by_contra h_no
    exact h_conj (fun _ h2 => h_no h2)
  obtain ⟨s1, hs1t, h_phi_s1⟩ := h_F_phi
  obtain ⟨s2, hs2t, h_psi_s2⟩ := h_F_psi
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: second disjunct F(φ ∧ F(ψ))
    intro _
    intro h_neg_second
    exfalso
    exact h_neg_second ⟨s1, hs1t, fun h_imp => h_imp h_phi_s1 ⟨s2, h_lt, h_psi_s2⟩⟩
  · -- s1 = s2: first disjunct F(φ ∧ ψ)
    subst h_eq
    intro h_neg_first
    exfalso
    exact h_neg_first ⟨s1, hs1t, fun h_imp => h_imp h_phi_s1 h_psi_s2⟩
  · -- s2 < s1: third disjunct F(F(φ) ∧ ψ)
    intro _; intro _
    exact ⟨s2, hs2t, fun h_imp => h_imp ⟨s1, h_gt, h_phi_s1⟩ h_psi_s2⟩

/-- Past temporal linearity axiom validity (BX11'):
`P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)` is valid.

Mirror of `temp_linearity_valid` for the past direction.
-/
theorem temp_linearity_past_valid (φ ψ : Formula) :
    ⊨ (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, TruthAt,
    Truth.some_past_iff]
  intro h_conj
  have h_P_phi : ∃ s, s < t ∧ TruthAt M τ s φ := by
    by_contra h_no
    exact h_conj (fun h1 _ => h_no h1)
  have h_P_psi : ∃ s, s < t ∧ TruthAt M τ s ψ := by
    by_contra h_no
    exact h_conj (fun _ h2 => h_no h2)
  obtain ⟨s1, hs1t, h_phi_s1⟩ := h_P_phi
  obtain ⟨s2, hs2t, h_psi_s2⟩ := h_P_psi
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: third disjunct P(P(φ) ∧ ψ)
    intro _; intro _
    exact ⟨s2, hs2t, fun h_imp => h_imp ⟨s1, h_lt, h_phi_s1⟩ h_psi_s2⟩
  · -- s1 = s2: first disjunct P(φ ∧ ψ)
    subst h_eq
    intro h_neg_first
    exfalso
    exact h_neg_first ⟨s1, hs1t, fun h_imp => h_imp h_phi_s1 h_psi_s2⟩
  · -- s2 < s1: second disjunct P(φ ∧ P(ψ))
    intro _
    intro h_neg_second
    exfalso
    exact h_neg_second ⟨s1, hs1t, fun h_imp => h_imp h_phi_s1 ⟨s2, h_gt, h_psi_s2⟩⟩

/-- F-Until equivalence axiom validity (BX12):
`F(φ) → (⊤ U φ)` is valid. Here ⊤ = ⊥ → ⊥.

If F(φ) holds at t, there exists s ≥ t with φ(s). Take this s as the Until witness.
The guard ⊤ is trivially satisfied on (t, s). -/
theorem F_until_equiv_valid (φ : Formula) :
    ⊨ ((Formula.someFuture φ).imp (Formula.untlQ (Formula.bot.imp Formula.bot) φ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, h_φs⟩
  exact ⟨s, hts, h_φs, fun _ _ _ => id⟩

/-- P-Since equivalence axiom validity (BX12'):
`P(φ) → S(φ, ⊤)` is valid. Past dual of F-Until equivalence. -/
theorem P_since_equiv_valid (φ : Formula) :
    ⊨ ((Formula.somePast φ).imp (Formula.snceQ (Formula.bot.imp Formula.bot) φ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, h_φs⟩
  exact ⟨s, hst, h_φs, fun _ _ _ => id⟩

/-- Dense indicator axiom is valid on dense orders: `⊨_dense ¬U(⊤,⊥)`.
On a densely ordered frame, `U(⊤,⊥)` at t requires s > t with empty (t,s),
but `DenselyOrdered` provides r with t < r < s, contradiction. -/
theorem dense_indicator_valid :
    ValidDense (Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)).neg := by
  intro T _ _ _ h_dense _ F M τ _h_mem t
  simp only [Formula.neg, TruthAt]
  intro ⟨s, hts, _h_top, h_guard⟩
  obtain ⟨r, htr, hrs⟩ := @DenselyOrdered.dense T _ h_dense t s hts
  exact h_guard r htr hrs

/-- Density axiom (DN) is valid on dense orders: `⊨_dense GGφ → Gφ`.
Under strict semantics: GGφ → Gφ requires DenselyOrdered. Given s > t,
find r with t < r < s by density, then h_GG(r)(s) gives φ(s). -/
theorem density_valid (φ : Formula) :
    ValidDense ((φ.allFuture.allFuture).imp φ.allFuture) := by
  intro T _ _ _ h_dense _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff]
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
    ValidDiscrete (Formula.and (Formula.bot.neg.someFuture)
      (Formula.and φ (Formula.allPast φ)) |>.imp
      (Formula.allPast φ).someFuture) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch _h_nontriv F M τ _h_mem t
  simp only [Formula.and, Formula.neg, TruthAt,
    Truth.some_future_iff, Truth.past_iff]
  intro h_conj
  have h1 := and_of_not_imp_not h_conj
  have ⟨_h_F_top, h_phi_and_H⟩ := h1
  have h2 := and_of_not_imp_not h_phi_and_H
  have ⟨h_phi, h_H⟩ := h2
  have _h_nomax : NoMaxOrder T := inferInstance
  exact ⟨Order.succ t, Order.lt_succ_of_not_isMax (not_isMax t), fun r hr => by
    rcases lt_or_eq_of_le (Order.le_of_lt_succ hr) with h | h
    · exact h_H r h
    · exact h ▸ h_phi⟩

/-- Future seriality axiom validity: `⊨_discrete Gφ → Fφ`.
Under strict semantics: Gφ → Fφ requires NoMaxOrder. -/
theorem seriality_future_valid (φ : Formula) :
    ValidDiscrete (φ.allFuture.imp φ.someFuture) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch h_nontriv F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff, Truth.some_future_iff]
  intro h_G
  have : NoMaxOrder T := inferInstance
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, h_G s hts⟩

/-- Past seriality axiom validity: `⊨_discrete Hφ → Pφ`.
Under strict semantics: Hφ → Pφ requires NoMinOrder. -/
theorem seriality_past_valid (φ : Formula) :
    ValidDiscrete (φ.allPast.imp φ.somePast) := by
  intro T _ _ _ _h_succ _h_pred _h_succ_arch _h_pred_arch h_nontriv F M τ _h_mem t
  simp only [TruthAt, Truth.past_iff, Truth.some_past_iff]
  intro h_H
  have : NoMinOrder T := inferInstance
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, h_H s hst⟩

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
    ⊨ ((φ.imp χ).allFuture.imp ((Formula.untlQ φ ψ).imp (Formula.untlQ χ ψ))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff]
  intro h_G ⟨s, hts, h_event, h_guard⟩
  exact ⟨s, hts, h_event, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩

/-- BX2H: Left monotonicity of Since under H: `H(φ→χ) → ((φ S ψ) → (χ S ψ))`.
Under open guard (s,t): H(φ→χ) gives (φ→χ) at all r < t, covering guard interval (s,t).
No pointwise condition at t needed since the guard is the open interval (s,t). -/
theorem left_mono_since_H_valid (φ χ ψ : Formula) :
    ⊨ ((φ.imp χ).allPast.imp ((Formula.snceQ φ ψ).imp (Formula.snceQ χ ψ))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.past_iff]
  intro h_H ⟨s, hst, h_event, h_guard⟩
  exact ⟨s, hst, h_event, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩

/-- BX3: Right monotonicity of Until: `G(φ → ψ) → ((χ U φ) → (χ U ψ))`.
Same witness s; φ(s) and (φ → ψ)(s) give ψ(s). Guard is unchanged. -/
theorem right_mono_until_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp ψ).allFuture.imp ((Formula.untlQ χ φ).imp (Formula.untlQ χ ψ))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff]
  intro h_G ⟨s, hts, h_φs, h_guard⟩
  exact ⟨s, hts, h_G s hts h_φs, h_guard⟩

/-- BX3': Right monotonicity of Since: `H(φ → ψ) → ((χ S φ) → (χ S ψ))`. -/
theorem right_mono_since_valid (φ ψ χ : Formula) :
    ⊨ ((φ.imp ψ).allPast.imp ((Formula.snceQ χ φ).imp (Formula.snceQ χ ψ))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.past_iff]
  intro h_H ⟨s, hst, h_φs, h_guard⟩
  exact ⟨s, hst, h_H s hst h_φs, h_guard⟩

/-- BX4: Temporal connectedness (future): `φ → G(P(φ))`.
If φ holds now, then at all future times, P(φ) holds.
Proof: for any s ≥ t, P(φ)(s) = ¬H(¬φ)(s) = ¬∀w ≤ s.¬φ(w). Take w = t: t ≤ s, φ(t). -/
theorem connect_future_valid (φ : Formula) :
    ⊨ (φ.imp (φ.somePast.allFuture)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff, Truth.some_past_iff]
  intro h_φt s hts
  exact ⟨t, hts, h_φt⟩

/-- BX4': Temporal connectedness (past): `φ → H(F(φ))`.
If φ holds now, then at all past times, F(φ) holds.
Proof: for any s ≤ t, F(φ)(s) = ¬G(¬φ)(s) = ¬∀w ≥ s.¬φ(w). Take w = t: t ≥ s, φ(t). -/
theorem connect_past_valid (φ : Formula) :
    ⊨ (φ.imp (φ.someFuture.allPast)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.past_iff, Truth.some_future_iff]
  intro h_φt s hst
  exact ⟨t, hst, h_φt⟩

/-- BX13: Until-Since enrichment (Burgess A3a, Xu axiom (3)):
`p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))`.
Valid under open guard (t,s): given p(t) and untl(φ, ψ) at t with witness s > t,
ψ(s), and φ on (t,s). Take same witness s for the conclusion.
- ψ(s) holds (from hypothesis).
- snce(φ, p)(s): take u = t as Since witness. t < s, p(t), and φ on (t,s) = the Until guard.
- Guard φ on (t,s): same as the hypothesis guard. -/
theorem enrichment_until_valid (φ ψ p : Formula) :
    ⊨ (Formula.and p (Formula.untlQ φ ψ) |>.imp
      (Formula.untlQ φ (Formula.and ψ (Formula.snceQ φ p)))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro h_conj
  have h_pt : TruthAt M τ t p := by
    by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
  have h_until : ∃ s, t < s ∧ TruthAt M τ s ψ ∧
      ∀ r, t < r → r < s → TruthAt M τ r φ := by
    by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
  obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
  refine ⟨s, hts, ?_, h_guard⟩
  intro h_imp
  exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩

/-- BX13': Since-Until enrichment (Burgess A3b, Xu axiom (4)):
`p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))`.
Mirror of enrichment_until for the Since direction. -/
theorem enrichment_since_valid (φ ψ p : Formula) :
    ⊨ (Formula.and p (Formula.snceQ φ ψ) |>.imp
      (Formula.snceQ φ (Formula.and ψ (Formula.untlQ φ p)))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro h_conj
  have h_pt : TruthAt M τ t p := by
    by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
  have h_since : ∃ s, s < t ∧ TruthAt M τ s ψ ∧
      ∀ r, s < r → r < t → TruthAt M τ r φ := by
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
    ⊨ ((Formula.untlQ φ ψ).imp
      (Formula.untlQ (Formula.and φ (Formula.untlQ φ ψ)) ψ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
  exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hqr hqs => h_guard q (lt_trans htr hqr) hqs⟩

/-- BX5': Self-accumulation of Since: `(φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)`. -/
theorem self_accum_since_valid (φ ψ : Formula) :
    ⊨ ((Formula.snceQ φ ψ).imp
      (Formula.snceQ (Formula.and φ (Formula.snceQ φ ψ)) ψ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
  exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩

theorem absorb_until_valid (φ ψ : Formula) :
    ⊨ ((Formula.untlQ φ (Formula.and φ (Formula.untlQ φ ψ))).imp (Formula.untlQ φ ψ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
  -- Extract φ(s₁) and (φ U ψ)(s₁) from the conjunction (encoded as double negation)
  have h_φs₁_and_until : TruthAt M τ s₁ φ ∧
      (∃ s₂, s₁ < s₂ ∧ TruthAt M τ s₂ ψ ∧
        ∀ q, s₁ < q → q < s₂ → TruthAt M τ q φ) := by
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
    ⊨ ((Formula.snceQ φ (Formula.and φ (Formula.snceQ φ ψ))).imp (Formula.snceQ φ ψ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.neg, TruthAt]
  intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
  have h_φs₁_and_since : TruthAt M τ s₁ φ ∧
      (∃ s₂, s₂ < s₁ ∧ TruthAt M τ s₂ ψ ∧
        ∀ q, s₂ < q → q < s₁ → TruthAt M τ q φ) := by
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
    ⊨ (Formula.and (Formula.untlQ φ ψ) (Formula.untlQ χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.untlQ (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.untlQ (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.untlQ (Formula.and φ χ) (Formula.and φ θ)))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, TruthAt]
  intro h_conj
  -- Extract both Until hypotheses from the conjunction encoding
  have h_both : (∃ s, t < s ∧ TruthAt M τ s ψ ∧
      ∀ r, t < r → r < s → TruthAt M τ r φ) ∧
    (∃ s, t < s ∧ TruthAt M τ s θ ∧
      ∀ r, t < r → r < s → TruthAt M τ r χ) := by
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
    ⊨ (Formula.and (Formula.snceQ φ ψ) (Formula.snceQ χ θ)
      |>.imp (Formula.or
        (Formula.or
          (Formula.snceQ (Formula.and φ χ) (Formula.and ψ θ))
          (Formula.snceQ (Formula.and φ χ) (Formula.and ψ χ)))
        (Formula.snceQ (Formula.and φ χ) (Formula.and φ θ)))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [Formula.and, Formula.or, Formula.neg, TruthAt]
  intro h_conj
  have h_both : (∃ s, s < t ∧ TruthAt M τ s ψ ∧
      ∀ r, s < r → r < t → TruthAt M τ r φ) ∧
    (∃ s, s < t ∧ TruthAt M τ s θ ∧
      ∀ r, s < r → r < t → TruthAt M τ r χ) := by
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

/-- BX10: Until implies eventuality: `(φ U ψ) → F(ψ)`.
F(ψ) = ¬G(¬ψ). Under reflexive Until, witness s ≥ t gives ψ(s), so ¬∀u≥t.¬ψ(u). -/
theorem until_F_valid (φ ψ : Formula) :
    ⊨ ((Formula.untlQ φ ψ).imp (Formula.someFuture ψ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, h_ψs, _⟩
  exact ⟨s, hts, h_ψs⟩

/-- BX10': Since implies past eventuality: `(φ S ψ) → P(ψ)`.
P(ψ) = ¬H(¬ψ). Under reflexive Since, witness s ≤ t gives ψ(s), so ¬∀u≤t.¬ψ(u). -/
theorem since_P_valid (φ ψ : Formula) :
    ⊨ ((Formula.snceQ φ ψ).imp (Formula.somePast ψ)) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, h_ψs, _⟩
  exact ⟨s, hst, h_ψs⟩

/-! ## Uniformity Axiom Validity

The following four axioms encode the uniformity of discreteness in ordered abelian groups.
They are valid over ALL `AddCommGroup D` with `IsOrderedAddMonoid D` because the
group's translation invariance ensures that gaps (empty open intervals) are uniform
across all time points.

Key semantic fact: `TruthAt M τ t (Formula.untl (bot.imp bot) bot)` means
∃ s > t with (t,s) empty in D. The guard `bot` is always False, so no element can
lie in (t,s). The event `bot.imp bot` is `⊤` which is always True.
-/

/-- Discrete symmetry forward: U(⊤,⊥) → S(⊤,⊥).
If there is a gap (t, s) with s > t, then (t-(s-t), t) is also empty by translation. -/
theorem discrete_symm_fwd_valid :
    ⊨ ((Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.snceQ Formula.bot (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
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
    ⊨ ((Formula.snceQ Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
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
    ⊨ ((Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allFuture (Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.future_iff]
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
    ⊨ ((Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt, Truth.past_iff]
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

/-- Discrete box necessity: U(⊤,⊥) → □(U(⊤,⊥)).
If there is a gap (t, s) at history τ, then for any total history σ,
the same gap exists (truth of U(⊤,⊥) depends only on D's order, not on τ). -/
theorem discrete_box_necessity_valid :
    ⊨ ((Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.box (Formula.untlQ Formula.bot (Formula.bot.imp Formula.bot)))) := by
  intro T _ _ _ _ F M τ _h_mem t
  simp only [TruthAt]
  intro ⟨s, hts, _h_top_s, h_guard⟩ σ _h_σ_mem
  exact ⟨s, hts, fun h => h, h_guard⟩

/-- Prior-UZ is valid on discrete orders: F(φ) → U(φ, ¬φ).
If φ holds at some future time, there is a nearest future time where φ holds. -/
theorem prior_UZ_valid (φ : Formula) :
    ValidDiscrete (φ.someFuture.imp (Formula.untlQ φ.neg φ)) := by
  intro D _ _ _ _ _ _ _ _ F M τ h_mem t
  exact SoundnessLemmas.prior_UZ_is_valid φ F M τ h_mem t

/-- Prior-SZ is valid on discrete orders: P(φ) → S(φ, ¬φ).
If φ held at some past time, there is a nearest past time where φ held. -/
theorem prior_SZ_valid (φ : Formula) : ValidDiscrete (φ.somePast.imp (Formula.snceQ φ.neg φ)) := by
  intro D _ _ _ _ _ _ _ _ F M τ h_mem t
  exact SoundnessLemmas.prior_SZ_is_valid φ F M τ h_mem t

/-- Z1 is valid on discrete orders: G(Gφ→φ) → (FGφ→Gφ).
Backward induction from the Gφ witness using IsSuccArchimedean. -/
theorem z1_valid (φ : Formula) : ValidDiscrete
    ((φ.allFuture.imp φ).allFuture.imp (φ.allFuture.someFuture.imp φ.allFuture)) := by
  intro D _ _ _ _ _ _ _ _ F M τ h_mem t
  exact SoundnessLemmas.z1_is_valid φ F M τ h_mem t

/-- All base TM axioms (excluding density, discreteness, and seriality) are universally valid.
With strict semantics, density requires DenselyOrdered, discreteness requires SuccOrder,
and seriality requires NoMaxOrder/NoMinOrder, so they are handled separately. -/
theorem axiom_valid {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Base) : ⊨
    φ := by
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
  -- NOTE: temp_k_dist and temp_4 removed as axiom constructors
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
  | discrete_box_necessity => exact discrete_box_necessity_valid
  | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  -- Reynolds Dedekind axioms: eliminated by frame-class incomparability.
  | prior_U_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_S_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | sep _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-- All dense-compatible axioms are valid on densely ordered frames.
This covers all base axioms (universally valid, hence valid on dense frames) plus the density axiom.
Note: Under strict semantics, seriality axioms require NoMaxOrder/NoMinOrder (via Nontrivial). -/
theorem axiom_dense_valid {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Dense) :
    ValidDense φ := by
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
  | serial_future => exact Validity.valid_implies_valid_dense serial_future_axiom_valid
  | serial_past => exact Validity.valid_implies_valid_dense serial_past_axiom_valid
  | left_mono_until_G φ χ ψ =>
    exact Validity.valid_implies_valid_dense (left_mono_until_G_valid φ χ ψ)
  | left_mono_since_H φ χ ψ =>
    exact Validity.valid_implies_valid_dense (left_mono_since_H_valid φ χ ψ)
  | right_mono_until φ ψ χ =>
    exact Validity.valid_implies_valid_dense (right_mono_until_valid φ ψ χ)
  | right_mono_since φ ψ χ =>
    exact Validity.valid_implies_valid_dense (right_mono_since_valid φ ψ χ)
  | connect_future _ => exact Validity.valid_implies_valid_dense (connect_future_valid _)
  | connect_past _ => exact Validity.valid_implies_valid_dense (connect_past_valid _)
  | enrichment_until φ ψ p =>
    exact Validity.valid_implies_valid_dense (enrichment_until_valid φ ψ p)
  | enrichment_since φ ψ p =>
    exact Validity.valid_implies_valid_dense (enrichment_since_valid φ ψ p)
  | self_accum_until φ ψ => exact Validity.valid_implies_valid_dense (self_accum_until_valid φ ψ)
  | self_accum_since φ ψ => exact Validity.valid_implies_valid_dense (self_accum_since_valid φ ψ)
  | absorb_until φ ψ => exact Validity.valid_implies_valid_dense (absorb_until_valid φ ψ)
  | absorb_since φ ψ => exact Validity.valid_implies_valid_dense (absorb_since_valid φ ψ)
  | linear_until _ _ _ _ => exact Validity.valid_implies_valid_dense (linear_until_valid _ _ _ _)
  | linear_since _ _ _ _ => exact Validity.valid_implies_valid_dense (linear_since_valid _ _ _ _)
  | until_F φ ψ => exact Validity.valid_implies_valid_dense (until_F_valid φ ψ)
  | since_P φ ψ => exact Validity.valid_implies_valid_dense (since_P_valid φ ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_dense (temp_linearity_valid φ ψ)
  | temp_linearity_past φ ψ =>
    exact Validity.valid_implies_valid_dense (temp_linearity_past_valid φ ψ)
  | F_until_equiv φ => exact Validity.valid_implies_valid_dense (F_until_equiv_valid φ)
  | P_since_equiv φ => exact Validity.valid_implies_valid_dense (P_since_equiv_valid φ)
  | modal_future ψ => exact Validity.valid_implies_valid_dense (modal_future_valid ψ)
  | discrete_symm_fwd => exact Validity.valid_implies_valid_dense discrete_symm_fwd_valid
  | discrete_symm_bwd => exact Validity.valid_implies_valid_dense discrete_symm_bwd_valid
  | discrete_propagate_fwd => exact Validity.valid_implies_valid_dense discrete_propagate_fwd_valid
  | discrete_propagate_bwd => exact Validity.valid_implies_valid_dense discrete_propagate_bwd_valid
  | discrete_box_necessity => exact Validity.valid_implies_valid_dense discrete_box_necessity_valid
  | density φ => exact density_valid φ
  | dense_indicator => exact dense_indicator_valid
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  -- Reynolds Dedekind axioms: eliminated by frame-class incomparability.
  | prior_U_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_S_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | sep _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-- All discrete-compatible axioms are valid on discrete frames.
This covers all base axioms (universally valid, hence valid on discrete frames) plus discreteness.
Under strict semantics, seriality requires NoMaxOrder/NoMinOrder (from SuccOrder/PredOrder +
Nontrivial). -/
theorem axiom_discrete_valid {φ : Formula} (h : Axiom φ) (h_fc :
      h.minFrameClass ≤ FrameClass.Discrete) :
    ValidDiscrete φ := by
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
  | serial_future => exact Validity.valid_implies_valid_discrete serial_future_axiom_valid
  | serial_past => exact Validity.valid_implies_valid_discrete serial_past_axiom_valid
  | left_mono_until_G φ χ ψ =>
    exact Validity.valid_implies_valid_discrete (left_mono_until_G_valid φ χ ψ)
  | left_mono_since_H φ χ ψ =>
    exact Validity.valid_implies_valid_discrete (left_mono_since_H_valid φ χ ψ)
  | right_mono_until φ ψ χ =>
    exact Validity.valid_implies_valid_discrete (right_mono_until_valid φ ψ χ)
  | right_mono_since φ ψ χ =>
    exact Validity.valid_implies_valid_discrete (right_mono_since_valid φ ψ χ)
  | connect_future _ => exact Validity.valid_implies_valid_discrete (connect_future_valid _)
  | connect_past _ => exact Validity.valid_implies_valid_discrete (connect_past_valid _)
  | enrichment_until φ ψ p =>
    exact Validity.valid_implies_valid_discrete (enrichment_until_valid φ ψ p)
  | enrichment_since φ ψ p =>
    exact Validity.valid_implies_valid_discrete (enrichment_since_valid φ ψ p)
  | self_accum_until φ ψ => exact Validity.valid_implies_valid_discrete (self_accum_until_valid φ ψ)
  | self_accum_since φ ψ => exact Validity.valid_implies_valid_discrete (self_accum_since_valid φ ψ)
  | absorb_until φ ψ => exact Validity.valid_implies_valid_discrete (absorb_until_valid φ ψ)
  | absorb_since φ ψ => exact Validity.valid_implies_valid_discrete (absorb_since_valid φ ψ)
  | linear_until _ _ _ _ => exact Validity.valid_implies_valid_discrete (linear_until_valid _ _ _ _)
  | linear_since _ _ _ _ => exact Validity.valid_implies_valid_discrete (linear_since_valid _ _ _ _)
  | until_F φ ψ => exact Validity.valid_implies_valid_discrete (until_F_valid φ ψ)
  | since_P φ ψ => exact Validity.valid_implies_valid_discrete (since_P_valid φ ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_valid_discrete (temp_linearity_valid φ ψ)
  | temp_linearity_past φ ψ =>
    exact Validity.valid_implies_valid_discrete (temp_linearity_past_valid φ ψ)
  | F_until_equiv φ => exact Validity.valid_implies_valid_discrete (F_until_equiv_valid φ)
  | P_since_equiv φ => exact Validity.valid_implies_valid_discrete (P_since_equiv_valid φ)
  | modal_future ψ => exact Validity.valid_implies_valid_discrete (modal_future_valid ψ)
  | discrete_symm_fwd => exact Validity.valid_implies_valid_discrete discrete_symm_fwd_valid
  | discrete_symm_bwd => exact Validity.valid_implies_valid_discrete discrete_symm_bwd_valid
  | discrete_propagate_fwd =>
    exact Validity.valid_implies_valid_discrete discrete_propagate_fwd_valid
  | discrete_propagate_bwd =>
    exact Validity.valid_implies_valid_discrete discrete_propagate_bwd_valid
  | discrete_box_necessity =>
    exact Validity.valid_implies_valid_discrete discrete_box_necessity_valid
  | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_UZ φ => exact prior_UZ_valid φ
  | prior_SZ φ => exact prior_SZ_valid φ
  | z1 φ => exact z1_valid φ
  -- Reynolds Dedekind axioms: eliminated by frame-class incomparability.
  | prior_U_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_S_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | sep _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-! ## Full Derivation Soundness

The main soundness theorem showing derivability implies semantic consequence.
-/

/--
Necessitation rule preserves validity: if φ is universally valid, then □φ is universally valid.

This is semantic: if φ holds at all (M, τ, hτ, t), then for any model at any time,
□φ holds because we quantify over all total histories, and φ holds at all of them.
-/
theorem necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨ (Formula.box φ) := by
  intro D _ _ _ _ F M τ h_mem t
  simp only [TruthAt]
  intro σ h_σ_mem
  exact h D F M σ h_σ_mem t

/--
Temporal necessitation preserves validity: if φ is universally valid, then Gφ is universally valid.

This is semantic: if φ holds at all (M, τ, hτ, t), then at any time s ≥ t, φ holds at (τ, s).
-/
theorem temporal_necessitation_preserves_valid {φ : Formula} (h : ⊨ φ) : ⊨
    (Formula.allFuture φ) := by
  intro D _ _ _ _ F M τ h_mem t
  simp only [Truth.future_iff]
  intro s _hts
  exact h D F M τ h_mem s

/--
**Soundness Theorem (Base)**: Derivability in the base system implies semantic consequence.

If `Γ ⊢[Base] φ`, then `Γ ⊨ φ`.
The `FrameClass.Base` parameter on `DerivationTree` structurally excludes axioms with
`minFrameClass > Base` (density, Prior-UZ/SZ, z1) via the `h_fc` gate on the axiom rule.

The proof proceeds by induction on the derivation tree structure:
- **Axiom**: Use the axiom validity theorems (incompatible axioms excluded by `h_fc`)
- **Assumption**: If φ ∈ Γ and all of Γ holds, then φ holds
- **Modus ponens**: If Γ ⊨ φ → ψ and Γ ⊨ φ, then Γ ⊨ ψ
- **Necessitation**: Uses `necessitation_preserves_valid`
- **Temporal necessitation**: Uses `temporal_necessitation_preserves_valid`
- **Temporal duality**: Uses `SoundnessLemmas.derivable_implies_swap_valid_general`
- **Weakening**: Monotonicity of semantic consequence

**Note**: Prior-UZ/SZ and z1 are excluded structurally — their `minFrameClass` is
`Discrete`, which is incomparable to `Base` in the partial order. Use
`soundness_discrete` for derivations containing these axioms.
-/
theorem soundness (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Base Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    -- All base axioms are universally valid; density/discrete excluded by h_fc
    cases h_ax with
    | prop_k φ ψ χ => exact prop_k_valid φ ψ χ D F M τ h_mem t
    | prop_s φ ψ => exact prop_s_valid φ ψ D F M τ h_mem t
    | modal_t ψ => exact modal_t_valid ψ D F M τ h_mem t
    | modal_4 ψ => exact modal_4_valid ψ D F M τ h_mem t
    | modal_b ψ => exact modal_b_valid ψ D F M τ h_mem t
    | modal_5_collapse ψ => exact modal_5_collapse_valid ψ D F M τ h_mem t
    | ex_falso ψ => exact ex_falso_valid ψ D F M τ h_mem t
    | peirce φ ψ => exact peirce_valid φ ψ D F M τ h_mem t
    | modal_k_dist φ ψ => exact modal_k_dist_valid φ ψ D F M τ h_mem t
    | serial_future => exact serial_future_axiom_valid D F M τ h_mem t
    | serial_past => exact serial_past_axiom_valid D F M τ h_mem t
    | left_mono_until_G φ χ ψ => exact left_mono_until_G_valid φ χ ψ D F M τ h_mem t
    | left_mono_since_H φ χ ψ => exact left_mono_since_H_valid φ χ ψ D F M τ h_mem t
    | right_mono_until φ ψ χ => exact right_mono_until_valid φ ψ χ D F M τ h_mem t
    | right_mono_since φ ψ χ => exact right_mono_since_valid φ ψ χ D F M τ h_mem t
    | connect_future φ => exact connect_future_valid φ D F M τ h_mem t
    | connect_past φ => exact connect_past_valid φ D F M τ h_mem t
    | enrichment_until φ ψ p => exact enrichment_until_valid φ ψ p D F M τ h_mem t
    | enrichment_since φ ψ p => exact enrichment_since_valid φ ψ p D F M τ h_mem t
    | self_accum_until φ ψ => exact self_accum_until_valid φ ψ D F M τ h_mem t
    | self_accum_since φ ψ => exact self_accum_since_valid φ ψ D F M τ h_mem t
    | absorb_until φ ψ => exact absorb_until_valid φ ψ D F M τ h_mem t
    | absorb_since φ ψ => exact absorb_since_valid φ ψ D F M τ h_mem t
    | linear_until φ ψ χ θ => exact linear_until_valid φ ψ χ θ D F M τ h_mem t
    | linear_since φ ψ χ θ => exact linear_since_valid φ ψ χ θ D F M τ h_mem t
    | until_F φ ψ => exact until_F_valid φ ψ D F M τ h_mem t
    | since_P φ ψ => exact since_P_valid φ ψ D F M τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M τ h_mem t
    | temp_linearity_past φ ψ => exact temp_linearity_past_valid φ ψ D F M τ h_mem t
    | F_until_equiv φ => exact F_until_equiv_valid φ D F M τ h_mem t
    | P_since_equiv φ => exact P_since_equiv_valid φ D F M τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M τ h_mem t
    | discrete_symm_fwd => exact discrete_symm_fwd_valid D F M τ h_mem t
    | discrete_symm_bwd => exact discrete_symm_bwd_valid D F M τ h_mem t
    | discrete_propagate_fwd => exact discrete_propagate_fwd_valid D F M τ h_mem t
    | discrete_propagate_bwd => exact discrete_propagate_bwd_valid D F M τ h_mem t
    | discrete_box_necessity => exact discrete_box_necessity_valid D F M τ h_mem t
    | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    -- Reynolds Dedekind axioms: eliminated by frame-class incomparability.
    | prior_U_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | prior_S_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | sep _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | assumption Γ' φ' h_in =>
    exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have h1 := ih1 τ h_mem t h_ctx
    have h2 := ih2 τ h_mem t h_ctx
    simp only [TruthAt] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [TruthAt]
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [Truth.future_iff]
    intro s _hts
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' ih =>
    -- d' : ⊢ φ', goal is TruthAt ... φ'.swapTemporal
    -- Use general swap validity with dense-compatibility guard
    exact SoundnessLemmas.derivable_implies_swap_valid_general d' F M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## Frame-Class-Restricted Soundness Theorems

These theorems provide soundness for specific frame classes, resolving the limitation
that the general soundness theorem cannot handle extension axioms without frame constraints.
-/

/--
**Soundness Dense Valid**: Derivability from empty context implies dense validity.

This theorem proves `ValidDense phi` for dense-compatible derivations from empty context,
which provides the universal quantification needed for the IRR soundness lemma.

**Key Insight**: The induction hypothesis at each step provides `ValidDense` for premises,
which matches the signature required by `irr_sound_dense_at_domain`.

**Note on domain membership**: The IRR case in `irr_sound_dense_at_domain` requires
`h_dom : tau.domain t`. This is handled by case split:
- Domain case: directly apply `irr_sound_dense_at_domain`
- Non-domain case: a known semantic gap (sorried) - canonical models use full domains

This theorem is defined before `soundness_dense` because `soundness_dense`'s IRR case
needs to invoke it for universal validity.
-/
theorem soundness_dense_valid {phi : Formula}
    (d : DerivationTree FrameClass.Dense [] phi) : ValidDense phi := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    -- All dense-compatible axioms are ValidDense
    exact axiom_dense_valid h_ax h_fc
  | .assumption _ _ h_mem =>
    -- Empty context has no assumptions
    exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ psi' _ d1 d2 =>
    -- From ValidDense (psi' → phi) and ValidDense psi', derive ValidDense phi
    have h1 := soundness_dense_valid d1
    have h2 := soundness_dense_valid d2
    intro D _ _ _ _ _ F M tau h_mem t
    have h1' := h1 D F M tau h_mem t
    have h2' := h2 D F M tau h_mem t
    simp only [TruthAt] at h1'
    exact h1' h2'
  | .necessitation psi' d' =>
    -- ValidDense psi' → ValidDense (box psi')
    have h := soundness_dense_valid d'
    intro D _ _ _ _ _ F M tau h_mem t
    simp only [TruthAt]
    intro sigma h_sigma_mem
    exact h D F M sigma h_sigma_mem t
  | .temporal_necessitation psi' d' =>
    -- ValidDense psi' → ValidDense (allFuture psi')
    have h := soundness_dense_valid d'
    intro D _ _ _ _ _ F M tau h_mem t
    simp only [Truth.future_iff]
    intro s _hts
    exact h D F M tau h_mem s
  | .temporal_duality psi' d' =>
    -- ValidDense psi' → ValidDense (swap psi')
    -- Use derivable_implies_swap_valid which gives IsValid, then convert
    intro D _ _ _ _ _ F M tau h_mem t
    exact SoundnessLemmas.derivable_implies_swap_valid d' F M tau h_mem t
  | .weakening Gamma' _ _ d' h_sub =>
    -- Since d : DerivationTree [] phi and Gamma' ⊆ [], we have Gamma' = []
    have h_eq : Gamma' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Gamma' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact soundness_dense_valid (h_eq ▸ d')
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

**Frame Class Constraint** (`fc = .Dense`):
The `DerivationTree .Dense` parameterization structurally ensures no discrete-specific axioms
(prior_UZ, prior_SZ, z1) appear in the derivation, since their `minFrameClass = .Discrete`
is incomparable with `.Dense`.

**Note on IRR rule**: The IRR case uses `soundness_dense_valid` to obtain universal validity,
then instantiates for the specific model.
-/
theorem soundness_dense (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Dense Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    cases h_ax with
    | prop_k φ ψ χ => exact prop_k_valid φ ψ χ D F M τ h_mem t
    | prop_s φ ψ => exact prop_s_valid φ ψ D F M τ h_mem t
    | modal_t ψ => exact modal_t_valid ψ D F M τ h_mem t
    | modal_4 ψ => exact modal_4_valid ψ D F M τ h_mem t
    | modal_b ψ => exact modal_b_valid ψ D F M τ h_mem t
    | modal_5_collapse ψ => exact modal_5_collapse_valid ψ D F M τ h_mem t
    | ex_falso ψ => exact ex_falso_valid ψ D F M τ h_mem t
    | peirce φ ψ => exact peirce_valid φ ψ D F M τ h_mem t
    | modal_k_dist φ ψ => exact modal_k_dist_valid φ ψ D F M τ h_mem t
    | serial_future => exact serial_future_axiom_valid D F M τ h_mem t
    | serial_past => exact serial_past_axiom_valid D F M τ h_mem t
    | left_mono_until_G φ χ ψ => exact left_mono_until_G_valid φ χ ψ D F M τ h_mem t
    | left_mono_since_H φ χ ψ => exact left_mono_since_H_valid φ χ ψ D F M τ h_mem t
    | right_mono_until φ ψ χ => exact right_mono_until_valid φ ψ χ D F M τ h_mem t
    | right_mono_since φ ψ χ => exact right_mono_since_valid φ ψ χ D F M τ h_mem t
    | connect_future φ => exact connect_future_valid φ D F M τ h_mem t
    | connect_past φ => exact connect_past_valid φ D F M τ h_mem t
    | enrichment_until φ ψ p => exact enrichment_until_valid φ ψ p D F M τ h_mem t
    | enrichment_since φ ψ p => exact enrichment_since_valid φ ψ p D F M τ h_mem t
    | self_accum_until φ ψ => exact self_accum_until_valid φ ψ D F M τ h_mem t
    | self_accum_since φ ψ => exact self_accum_since_valid φ ψ D F M τ h_mem t
    | absorb_until φ ψ => exact absorb_until_valid φ ψ D F M τ h_mem t
    | absorb_since φ ψ => exact absorb_since_valid φ ψ D F M τ h_mem t
    | linear_until φ ψ χ θ => exact linear_until_valid φ ψ χ θ D F M τ h_mem t
    | linear_since φ ψ χ θ => exact linear_since_valid φ ψ χ θ D F M τ h_mem t
    | until_F φ ψ => exact until_F_valid φ ψ D F M τ h_mem t
    | since_P φ ψ => exact since_P_valid φ ψ D F M τ h_mem t
    | temp_linearity φ ψ => exact temp_linearity_valid φ ψ D F M τ h_mem t
    | temp_linearity_past φ ψ => exact temp_linearity_past_valid φ ψ D F M τ h_mem t
    | F_until_equiv φ => exact F_until_equiv_valid φ D F M τ h_mem t
    | P_since_equiv φ => exact P_since_equiv_valid φ D F M τ h_mem t
    | modal_future ψ => exact modal_future_valid ψ D F M τ h_mem t
    | discrete_symm_fwd => exact discrete_symm_fwd_valid D F M τ h_mem t
    | discrete_symm_bwd => exact discrete_symm_bwd_valid D F M τ h_mem t
    | discrete_propagate_fwd => exact discrete_propagate_fwd_valid D F M τ h_mem t
    | discrete_propagate_bwd => exact discrete_propagate_bwd_valid D F M τ h_mem t
    | discrete_box_necessity => exact discrete_box_necessity_valid D F M τ h_mem t
    | density φ => exact density_valid φ D F M τ h_mem t
    | dense_indicator => exact dense_indicator_valid D F M τ h_mem t
    | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    -- Reynolds Dedekind axioms: eliminated by frame-class incomparability.
    | prior_U_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | prior_S_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | sep _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | assumption Γ' φ' h_in =>
    exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have h1 := ih1 τ h_mem t h_ctx
    have h2 := ih2 τ h_mem t h_ctx
    simp only [TruthAt] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [TruthAt]
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [Truth.future_iff]
    intro s _hts
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' ih =>
    exact SoundnessLemmas.derivable_implies_swap_valid d' F M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

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
    (d : DerivationTree FrameClass.Discrete [] phi) : ValidDiscrete phi := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact axiom_discrete_valid h_ax h_fc
  | .assumption _ _ h_mem =>
    exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := soundness_discrete_valid d1
    have h2 := soundness_discrete_valid d2
    intro D _ _ _ _ _ _ _ _ F M tau h_mem t
    have h1' := h1 D F M tau h_mem t
    have h2' := h2 D F M tau h_mem t
    simp only [TruthAt] at h1'
    exact h1' h2'
  | .necessitation psi' d' =>
    have h := soundness_discrete_valid d'
    intro D _ _ _ _ _ _ _ _ F M tau h_mem t
    simp only [TruthAt]
    intro sigma h_sigma_mem
    exact h D F M sigma h_sigma_mem t
  | .temporal_necessitation psi' d' =>
    have h := soundness_discrete_valid d'
    intro D _ _ _ _ _ _ _ _ F M tau h_mem t
    simp only [Truth.future_iff]
    intro s _hts
    exact h D F M tau h_mem s
  | .temporal_duality psi' d' =>
    -- Use discrete swap validity for derivations that may contain Prior-UZ/SZ
    intro D _ _ _ _ _ _ _ _ F M tau h_mem t
    exact SoundnessLemmas.derivable_implies_swap_valid_discrete d' F M tau h_mem t
  | .weakening Gamma' _ _ d' h_sub =>
    have h_eq : Gamma' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Gamma' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact soundness_discrete_valid (h_eq ▸ d')
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
    (d : DerivationTree FrameClass.Discrete Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    exact axiom_discrete_valid h_ax h_fc D F M τ h_mem t
  | assumption Γ' φ' h_in =>
    exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have h1 := ih1 τ h_mem t h_ctx
    have h2 := ih2 τ h_mem t h_ctx
    simp only [TruthAt] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [TruthAt]
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [Truth.future_iff]
    intro s _hts
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' ih =>
    -- Use discrete swap validity for derivations that may contain Prior-UZ/SZ
    exact SoundnessLemmas.derivable_implies_swap_valid_discrete d' F M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## Dedekind Frame Soundness Theorems

Soundness for `FrameClass.Dedekind`: Reynolds' axiomatization US/R for real flow.

**The target is `ValidDedekindDense`, NOT `ValidDedekind`, and that is deliberate.**
`FrameClass.Dedekind` sits strictly above `FrameClass.Dense` (see the `FrameClass` docstring
in `ProofSystem/Axioms.lean`), so `Axiom.density` and `Axiom.dense_indicator` are admissible in
a `.Dedekind` derivation. Both are FALSE on `ℤ` -- for `density`, take `φ` true exactly at times
`≥ t + 2`, so `GGφ` holds at `t` while `Gφ` fails; for `dense_indicator`, `U(⊤,⊥)` is true on
`ℤ` because every point has an immediate successor. And `ℤ` satisfies every binder of
`ValidDedekind` (Mathlib gives it a `ConditionallyCompleteLinearOrder` instance). So a
`soundness_dedekind` targeting `ValidDedekind` would be **refutable**. Do not "simplify" it.
-/

/-- Forgetting the least-upper-bound hypothesis: dense validity implies dense Dedekind
validity. The `ValidDedekindDense` binder set is `ValidDense`'s plus an LUB hypothesis, so
this is a pure weakening. -/
private theorem validDedekindDense_of_validDense {φ : Formula} (h : ValidDense φ) :
    ValidDedekindDense φ :=
  fun D _ _ _ _ _ _hlub F M τ h_mem t => h D F M τ h_mem t

/-! ### Semantic validity of the three Reynolds axioms

`prior_U_gap` and `prior_S_gap` are each other's temporal dual definitionally, so the two Prior
lemmas below cover both directions. Sep's dual is by contrast a genuinely separate semantic
fact and so carries its own `sep_swap_valid`; that pair is stated as two lemmas because they are
two obligations, consumed at different call sites.

The Dedekind soundness chain is now sorry-free end to end: both Prior gap lemmas, both Sep
lemmas, both dispatchers, and both soundness theorems covering all 45 axiom constructors.
-/

/-- A greatest lower bound from a least-upper-bound hypothesis: `inf B` is recovered as the
least upper bound of `B`'s set of lower bounds, via `isLUB_lowerBounds`. This is the bridge the
past-directed `prior_S_gap_valid` needs, since the `ValidDedekindDense` binder set supplies only
the upward-completeness hypothesis. `BddBelow B` is definitionally `(lowerBounds B).Nonempty`
and so is passed straight through as the nonemptiness argument; any member of `B` is an upper
bound of `lowerBounds B`. -/
private theorem exists_isGLB_of_lub {D : Type} [LinearOrder D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    {B : Set D} (hne : B.Nonempty) (hbdd : BddBelow B) : ∃ x, IsGLB B x := by
  obtain ⟨a, ha⟩ := hne
  obtain ⟨x, hx⟩ := h_lub (lowerBounds B) hbdd ⟨a, fun _ hb => hb ha⟩
  exact ⟨x, isLUB_lowerBounds.mp hx⟩

/-- **Prior-U gap axiom validity**: `U(⊤,φ) ∧ F(¬φ) → U(¬φ ∨ K⁺(¬φ), φ)` is valid on every
dense Dedekind-complete duration group.

Reynolds 1992 (printed p.168) asserts this without proof -- "It is clear that all these axioms
are valid over the reals" -- so the argument below is reconstructed rather than transcribed.

The construction: let `A` be the set of right endpoints of φ-intervals starting at `t`, i.e. the
`u > t` such that φ holds at every `r` strictly between `t` and `u`. The antecedent's `U(⊤,φ)`
conjunct makes `A` non-empty, and its `F(¬φ)` conjunct supplies a `¬φ` point bounding `A` above,
so the binder set's least-upper-bound hypothesis yields `s = sup A`. That `s` realizes as a
single point what Reynolds describes as a supremum-less non-empty proper initial segment of the
φ-region: φ holds throughout `(t, s)` because any `r < s` is undercut by some member of `A`
above it, and `s` witnesses the consequent because a `w > s` refuting the `¬φ ∨ K⁺(¬φ)` disjunct
at `s` would give φ on all of `(s, w)`, which together with φ at `s` and φ on `(t, s)` puts `w`
itself in `A` -- above its own supremum.

Note that the proof consumes only the least-upper-bound hypothesis and the linear order: it uses
no `DenselyOrdered`, `Nontrivial`, `AddCommGroup`, `IsOrderedAddMonoid`, or shift-closure
assumption, so both Prior gap axioms are in fact valid on every Dedekind-complete linear order.
The `DenselyOrdered` binder is present for consistency with the rest of the chain, not because
the mathematics needs it; see the `ValidDedekindDense` discussion above for why the weaker binder
set is required here and must not be relaxed. -/
theorem prior_U_gap_valid (φ : Formula) :
    ValidDedekindDense ((Formula.and (Formula.untlQ φ Formula.top) φ.neg.someFuture).imp
      (Formula.untlQ φ (Formula.or φ.neg (Formula.kPlus φ.neg)))) := by
  intro D _ _ _ _ _ h_lub F M τ h_mem t h_ant
  simp only [TruthAt, Formula.and, Formula.neg, Formula.someFuture, Formula.top] at h_ant
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  obtain ⟨s0, hts0, -, hp0⟩ := h1
  obtain ⟨v, htv, hnpv, -⟩ := h2
  set A : Set D := {u : D | t < u ∧ ∀ r : D, t < r → r < u → TruthAt M τ r φ} with hA
  have hs0A : s0 ∈ A := ⟨hts0, hp0⟩
  have hAbdd : BddAbove A := by
    refine ⟨v, ?_⟩
    intro u hu
    by_contra hvu
    exact hnpv (hu.2 v htv (lt_of_not_ge hvu))
  obtain ⟨s, hs⟩ := h_lub A ⟨s0, hs0A⟩ hAbdd
  have hts : t < s := lt_of_lt_of_le hts0 (hs.1 hs0A)
  have hguard : ∀ r : D, t < r → r < s → TruthAt M τ r φ := by
    intro r htr hrs
    obtain ⟨u, huA, hru, -⟩ := hs.exists_between hrs
    exact huA.2 r htr hru
  simp only [TruthAt, Formula.or, Formula.neg, Formula.kPlus, Formula.top]
  refine ⟨s, hts, ?_, hguard⟩
  intro hnn
  rintro ⟨w, hsw, -, hw⟩
  have hps : TruthAt M τ s φ := Classical.byContradiction hnn
  have hwA : w ∈ A := by
    refine ⟨lt_trans hts hsw, ?_⟩
    intro r htr hrw
    rcases lt_trichotomy r s with h | h | h
    · exact hguard r htr h
    · exact h ▸ hps
    · exact Classical.byContradiction (hw r h hrw)
  exact absurd (hs.1 hwA) (not_le_of_gt hsw)

/-- **Prior-S gap axiom validity**: `S(⊤,φ) ∧ P(¬φ) → S(¬φ ∨ K⁻(¬φ), φ)`, the past dual.

The infimum dual of `prior_U_gap_valid` (Reynolds 1992, printed p.168, likewise asserted without
proof). Here `B` is the set of left endpoints of φ-intervals ending at `t` -- the `u < t` such
that φ holds at every `r` strictly between `u` and `t` -- and the witness is `s = inf B`.

The binder set provides only a least-upper-bound hypothesis, so `exists_isGLB_of_lub` is the
bridge: it derives a greatest lower bound of `B` as the least upper bound of `B`'s lower-bound
set, via `isLUB_lowerBounds`. This costs nothing extra in hypotheses, whereas the alternative
negation route (`x ↦ -x` reverses the order) would drag in the additive group structure.

The trichotomy branches in the final step run in the mirror order to the Prior-U case: for `r`
between `w` and `t`, the case `r < s` is handled by the refuting witness and `s < r` by the
interval guard, because the `K⁻` interval now lies to the left of `s` rather than the right. -/
theorem prior_S_gap_valid (φ : Formula) :
    ValidDedekindDense ((Formula.and (Formula.snceQ φ Formula.top) φ.neg.somePast).imp
      (Formula.snceQ φ (Formula.or φ.neg (Formula.kMinus φ.neg)))) := by
  intro D _ _ _ _ _ h_lub F M τ h_mem t h_ant
  simp only [TruthAt, Formula.and, Formula.neg, Formula.somePast, Formula.top] at h_ant
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  obtain ⟨s0, hs0t, -, hp0⟩ := h1
  obtain ⟨v, hvt, hnpv, -⟩ := h2
  set B : Set D := {u : D | u < t ∧ ∀ r : D, u < r → r < t → TruthAt M τ r φ} with hB
  have hs0B : s0 ∈ B := ⟨hs0t, hp0⟩
  have hBbdd : BddBelow B := by
    refine ⟨v, ?_⟩
    intro u hu
    by_contra huv
    exact hnpv (hu.2 v (lt_of_not_ge huv) hvt)
  obtain ⟨s, hs⟩ := exists_isGLB_of_lub h_lub ⟨s0, hs0B⟩ hBbdd
  have hst : s < t := lt_of_le_of_lt (hs.1 hs0B) hs0t
  have hguard : ∀ r : D, s < r → r < t → TruthAt M τ r φ := by
    intro r hsr hrt
    obtain ⟨u, huB, -, hur⟩ := hs.exists_between hsr
    exact huB.2 r hur hrt
  simp only [TruthAt, Formula.or, Formula.neg, Formula.kMinus, Formula.top]
  refine ⟨s, hst, ?_, hguard⟩
  intro hnn
  rintro ⟨w, hws, -, hw⟩
  have hps : TruthAt M τ s φ := Classical.byContradiction hnn
  have hwB : w ∈ B := by
    refine ⟨lt_trans hws hst, ?_⟩
    intro r hwr hrt
    rcases lt_trichotomy r s with h | h | h
    · exact Classical.byContradiction (hw r hwr h)
    · exact h ▸ hps
    · exact hguard r h hrt
  exact absurd (hs.1 hwB) (not_le_of_gt hws)

/-- **Sep axiom validity**: `K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)` is valid on real flow.

Reynolds 1992 defers this at his printed p.168 -- "we investigate this axiom in more detail in
section 7 and defer proving its validity in ℝ until lemma 10 there" -- so the source for the
argument below is his §7 lemma 10.

**The separability input.** Sep is FALSE on an arbitrary densely ordered Dedekind-complete linear
order: the lexicographic square `[0,1] ×ₗₑₓ [0,1]` refutes it. The `ValidDedekindDense` algebraic
binders are therefore load-bearing here, in sharp contrast to the two Prior gap lemmas above,
which consume only the linear order and the least-upper-bound hypothesis. `AddCommGroup`,
`IsOrderedAddMonoid`, `DenselyOrdered` and `Nontrivial` together with the LUB hypothesis force
the flow to be Archimedean and hence separable; `SoundnessLemmas.exists_countable_order_dense`
extracts the countable order-dense `Q` that the argument runs on. Do not attempt to weaken the
binder set to `ValidDedekind`.

**Shape of the proof.** Negating the implication gives, at `t`: (i) φ accumulates at `t` from the
right, (ii) no φ-point just above `t` begins a φ-free gap (Reynolds' relative-density condition),
and (iii) every point of some right-neighbourhood of `t` fails `K⁺φ ∧ K⁻φ`, i.e. carries a
φ-free interval on one side -- Reynolds' adjacent intervals `I_u`. `SoundnessLemmas.sep_order`
derives the contradiction: `S := φ-region ∩ (t, s)` is dense in itself by (ii), and (iii) assigns
each `u` a point of `Q` separating `S` below `u` from `S` above it, which is impossible.

**Fidelity note -- one deliberate, bounded deviation from the source.** Reynolds' own endgame
(his step 7) thins `S` to a countable subset, invokes Cantor's theorem that a countable dense
linear order without endpoints is isomorphic to ℚ, counts the uncountably many gaps of ℚ, and
concludes by cardinal comparison. That endgame is replaced here by an equivalent Baire-style
nested-interval construction over ℕ (`SoundnessLemmas.nested_core`). Everything through
Reynolds' step 6 is followed as written; only the final move is restructured. The substitution
uses the *same* essential input -- separability -- repackaged as "each `I_u` contains a point of
a fixed countable dense `Q`", which is precisely the standard proof of Reynolds' cardinality
step. It is adopted because the `≅ ℚ` route needs Cantor's back-and-forth theorem (a substantial
development absent from this tree) and would drag `Cardinal` into the soundness chain; Reynolds'
"no last point" condition is dropped with it, since it exists only to secure order type ℚ. A
reader comparing this proof against Reynolds §7 should expect no `S ≅ ℚ` step and find
`nested_core` in its place. -/
theorem sep_valid (φ : Formula) :
    ValidDedekindDense ((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untlQ φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))) := by
  intro D _ _ _ _ _ h_lub F M τ h_mem t h_ant
  obtain ⟨Q, hQc, hQd⟩ := SoundnessLemmas.exists_countable_order_dense h_lub
  simp only [TruthAt, Formula.and, Formula.neg, Formula.kPlus, Formula.kMinus,
    Formula.top] at h_ant ⊢
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  rintro ⟨s₂, hts₂, -, hno⟩
  have hK : ∀ v, t < v → ∃ u, t < u ∧ u < v ∧ TruthAt M τ u φ := by
    intro v htv
    by_contra hc
    refine h1 ⟨v, htv, fun hb => hb, ?_⟩
    intro r htr hrv hrφ
    exact hc ⟨r, htr, hrv, hrφ⟩
  have h2' : ∃ s₁, t < s₁ ∧ (True) ∧ ∀ u, t < u → u < s₁ →
      (TruthAt M τ u φ → TruthAt M τ u (Formula.untlQ φ.neg φ) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hts₁, -, hu⟩ := hbad
      exact ⟨s₁, hts₁, trivial, fun u htu hus => Classical.byContradiction (hu u htu hus)⟩)
  obtain ⟨s₁, hts₁, -, hstart⟩ := h2'
  refine SoundnessLemmas.sep_order h_lub Q hQc hQd {u | TruthAt M τ u φ} t s₁ s₂
    hts₁ hts₂ hK ?_ ?_
  · rintro u htu hus₁ huP ⟨v, huv, hvP, hfree⟩
    exact hstart u htu hus₁ huP ⟨v, huv, hvP, fun r hur hrv => hfree r hur hrv⟩
  · intro u htu hus₂
    have hAB : TruthAt M τ u (Formula.kPlus φ) →
        TruthAt M τ u (Formula.kMinus φ) → False := by
      intro ha hb
      exact hno u htu hus₂ (fun k => k ha hb)
    by_cases hR : ∃ v, u < v ∧ ∀ w, u < w → w < v → ¬ TruthAt M τ w φ
    · exact Or.inl hR
    · refine Or.inr ?_
      have ha : TruthAt M τ u (Formula.kPlus φ) := by
        simp only [TruthAt, Formula.kPlus, Formula.neg, Formula.top]
        rintro ⟨v, huv, -, hw⟩
        exact hR ⟨v, huv, fun w huw hwv => hw w huw hwv⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      simp only [TruthAt, Formula.kMinus, Formula.neg, Formula.top]
      rintro ⟨v, hvu, -, hw⟩
      exact hns ⟨v, hvu, fun w hvw hwu => hw w hvw hwu⟩

/-- **Sep⁻ validity**: the temporal dual of `sep_valid`, needed by `temporal_duality`.

Unlike the Prior pair -- where `Formula.swapTemporal` carries `prior_U_gap` onto `prior_S_gap`
definitionally (verified by `rfl`), so those two lemmas cover each other's swap -- Sep is not
self-covering under the swap: `(sep φ).swapTemporal` exchanges `K⁺`/`K⁻` and `U`/`S`, and the
result is NOT an instance of `Axiom.sep`. It is therefore a genuinely separate semantic fact and
gets its own lemma, matching the tree's `swap_axiom_*_valid` convention in
`SoundnessLemmas/DenseValidity.lean` (nine instances, none bundled with its unswapped partner).

Stated separately from `sep_valid` rather than folded into a conjunction with it: the two are
consumed at different call sites (`axiom_dedekind_valid` and `axiom_dedekind_swap_valid`), and a
conjunction would misreport two independent obligations as one.

The proof reuses the forward order-theoretic core rather than mirroring it by hand:
`SoundnessLemmas.sep_order_mirror` is `SoundnessLemmas.sep_order` instantiated at `Dᵒᵈ`, so the
~130-line nested-interval argument is written once. (The Prior pair took the opposite route
because its dualised body is only ~25 lines.) `swapTemporal` distributes through `imp` and `bot`,
hence through `neg` and `and`, exchanges `U`/`S` and fixes `top`; so the swapped Sep is the exact
past mirror with `ψ := φ.swapTemporal`, and a single `simp only` performs the whole unfolding.
See `sep_valid` for the separability input and the recorded fidelity deviation from Reynolds. -/
theorem sep_swap_valid (φ : Formula) :
    ValidDedekindDense (((Formula.and (Formula.kPlus φ)
        (Formula.kPlus (Formula.and φ (Formula.untlQ φ.neg φ))).neg).imp
        (Formula.kPlus (Formula.and (Formula.kPlus φ) (Formula.kMinus φ)))).swapTemporal) := by
  intro D _ _ _ _ _ h_lub F M τ h_mem t h_ant
  obtain ⟨Q, hQc, hQd⟩ := SoundnessLemmas.exists_countable_order_dense h_lub
  simp only [Formula.and, Formula.neg, Formula.kPlus, Formula.kMinus, Formula.top,
    Formula.swapTemporal, TruthAt] at h_ant ⊢
  obtain ⟨h1, h2⟩ := and_of_not_imp_not h_ant
  rintro ⟨s₂, hs₂t, -, hno⟩
  have hK : ∀ v, v < t → ∃ u, v < u ∧ u < t ∧ TruthAt M τ u φ.swapTemporal := by
    intro v hvt
    by_contra hc
    refine h1 ⟨v, hvt, fun hb => hb, ?_⟩
    intro r hvr hrt hrφ
    exact hc ⟨r, hvr, hrt, hrφ⟩
  have h2' : ∃ s₁, s₁ < t ∧ (True) ∧ ∀ u, u < t → s₁ < u →
      (TruthAt M τ u φ.swapTemporal →
        TruthAt M τ u (Formula.snceQ φ.swapTemporal.neg φ.swapTemporal) → False) := by
    refine Classical.byContradiction (fun hc => h2 ?_)
    intro hbad
    exact hc (by
      obtain ⟨s₁, hs₁t, -, hu⟩ := hbad
      exact ⟨s₁, hs₁t, trivial, fun u hut hs₁u => Classical.byContradiction (hu u hs₁u hut)⟩)
  obtain ⟨s₁, hs₁t, -, hstart⟩ := h2'
  refine SoundnessLemmas.sep_order_mirror h_lub Q hQc hQd
    {u | TruthAt M τ u φ.swapTemporal} t s₁ s₂ hs₁t hs₂t hK ?_ ?_
  · rintro u hut hs₁u huP ⟨v, hvu, hvP, hfree⟩
    exact hstart u hut hs₁u huP ⟨v, hvu, hvP, fun r hvr hru => hfree r hvr hru⟩
  · intro u hut hs₂u
    have hAB : TruthAt M τ u (Formula.kMinus φ.swapTemporal) →
        TruthAt M τ u (Formula.kPlus φ.swapTemporal) → False := by
      intro ha hb
      exact hno u hs₂u hut (fun k => k ha hb)
    by_cases hL : ∃ v, v < u ∧ ∀ w, v < w → w < u → ¬ TruthAt M τ w φ.swapTemporal
    · exact Or.inl hL
    · refine Or.inr ?_
      have ha : TruthAt M τ u (Formula.kMinus φ.swapTemporal) := by
        simp only [TruthAt, Formula.kMinus, Formula.neg, Formula.top]
        rintro ⟨v, hvu, -, hw⟩
        exact hL ⟨v, hvu, fun w hvw hwu => hw w hvw hwu⟩
      have hb := hAB ha
      refine Classical.byContradiction (fun hns => hb ?_)
      simp only [TruthAt, Formula.kPlus, Formula.neg, Formula.top]
      rintro ⟨v, huv, -, hw⟩
      exact hns ⟨v, huv, fun w huw hwv => hw w huw hwv⟩

/-- All Dedekind-compatible axioms are valid on dense Dedekind-complete frames.

Dispatch: the 37 Base axioms route through `valid_implies_validDedekindDense`; the 2 Dense
axioms (`density`, `dense_indicator`) are admissible here because `Dense ≤ Dedekind`, and are
valid because the binder set carries `DenselyOrdered`; the 3 Discrete axioms are eliminated by
`Discrete ≰ Dedekind`; the 3 Reynolds axioms route to the validity lemmas above.

This theorem is itself sorry-free. -/
theorem axiom_dedekind_valid {φ : Formula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ FrameClass.Dedekind) :
    ValidDedekindDense φ := by
  cases h with
  | prop_k φ ψ χ => exact Validity.valid_implies_validDedekindDense (prop_k_valid φ ψ χ)
  | prop_s φ ψ => exact Validity.valid_implies_validDedekindDense (prop_s_valid φ ψ)
  | modal_t ψ => exact Validity.valid_implies_validDedekindDense (modal_t_valid ψ)
  | modal_4 ψ => exact Validity.valid_implies_validDedekindDense (modal_4_valid ψ)
  | modal_b ψ => exact Validity.valid_implies_validDedekindDense (modal_b_valid ψ)
  | modal_5_collapse ψ => exact Validity.valid_implies_validDedekindDense (modal_5_collapse_valid ψ)
  | ex_falso ψ => exact Validity.valid_implies_validDedekindDense (ex_falso_valid ψ)
  | peirce φ ψ => exact Validity.valid_implies_validDedekindDense (peirce_valid φ ψ)
  | modal_k_dist φ ψ => exact Validity.valid_implies_validDedekindDense (modal_k_dist_valid φ ψ)
  | serial_future => exact Validity.valid_implies_validDedekindDense serial_future_axiom_valid
  | serial_past => exact Validity.valid_implies_validDedekindDense serial_past_axiom_valid
  | left_mono_until_G φ χ ψ =>
    exact Validity.valid_implies_validDedekindDense (left_mono_until_G_valid φ χ ψ)
  | left_mono_since_H φ χ ψ =>
    exact Validity.valid_implies_validDedekindDense (left_mono_since_H_valid φ χ ψ)
  | right_mono_until φ ψ χ =>
    exact Validity.valid_implies_validDedekindDense (right_mono_until_valid φ ψ χ)
  | right_mono_since φ ψ χ =>
    exact Validity.valid_implies_validDedekindDense (right_mono_since_valid φ ψ χ)
  | connect_future _ => exact Validity.valid_implies_validDedekindDense (connect_future_valid _)
  | connect_past _ => exact Validity.valid_implies_validDedekindDense (connect_past_valid _)
  | enrichment_until φ ψ p =>
    exact Validity.valid_implies_validDedekindDense (enrichment_until_valid φ ψ p)
  | enrichment_since φ ψ p =>
    exact Validity.valid_implies_validDedekindDense (enrichment_since_valid φ ψ p)
  | self_accum_until φ ψ => exact Validity.valid_implies_validDedekindDense (self_accum_until_valid φ ψ)
  | self_accum_since φ ψ => exact Validity.valid_implies_validDedekindDense (self_accum_since_valid φ ψ)
  | absorb_until φ ψ => exact Validity.valid_implies_validDedekindDense (absorb_until_valid φ ψ)
  | absorb_since φ ψ => exact Validity.valid_implies_validDedekindDense (absorb_since_valid φ ψ)
  | linear_until _ _ _ _ => exact Validity.valid_implies_validDedekindDense (linear_until_valid _ _ _ _)
  | linear_since _ _ _ _ => exact Validity.valid_implies_validDedekindDense (linear_since_valid _ _ _ _)
  | until_F φ ψ => exact Validity.valid_implies_validDedekindDense (until_F_valid φ ψ)
  | since_P φ ψ => exact Validity.valid_implies_validDedekindDense (since_P_valid φ ψ)
  | temp_linearity φ ψ => exact Validity.valid_implies_validDedekindDense (temp_linearity_valid φ ψ)
  | temp_linearity_past φ ψ =>
    exact Validity.valid_implies_validDedekindDense (temp_linearity_past_valid φ ψ)
  | F_until_equiv φ => exact Validity.valid_implies_validDedekindDense (F_until_equiv_valid φ)
  | P_since_equiv φ => exact Validity.valid_implies_validDedekindDense (P_since_equiv_valid φ)
  | modal_future ψ => exact Validity.valid_implies_validDedekindDense (modal_future_valid ψ)
  | discrete_symm_fwd => exact Validity.valid_implies_validDedekindDense discrete_symm_fwd_valid
  | discrete_symm_bwd => exact Validity.valid_implies_validDedekindDense discrete_symm_bwd_valid
  | discrete_propagate_fwd =>
    exact Validity.valid_implies_validDedekindDense discrete_propagate_fwd_valid
  | discrete_propagate_bwd =>
    exact Validity.valid_implies_validDedekindDense discrete_propagate_bwd_valid
  | discrete_box_necessity =>
    exact Validity.valid_implies_validDedekindDense discrete_box_necessity_valid
  | density φ => exact validDedekindDense_of_validDense (density_valid φ)
  | dense_indicator => exact validDedekindDense_of_validDense dense_indicator_valid
  -- Discrete axioms: eliminated by frame-class incomparability (`Discrete ≰ Dedekind`).
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  -- The three Reynolds Dedekind axioms, each with its own validity lemma above.
  | prior_U_gap φ => exact prior_U_gap_valid φ
  | prior_S_gap φ => exact prior_S_gap_valid φ
  | sep φ => exact sep_valid φ

/-- Swap-validity for Dedekind-compatible axioms, needed by the `temporal_duality` case.

Base and Dense axioms delegate to `SoundnessLemmas.axiom_swap_valid`, which is already proved
for every axiom with `minFrameClass ≤ .Dense` on densely ordered frames. The three Reynolds
axioms are handled by duality: `swapTemporal` carries `prior_U_gap` to `prior_S_gap` (and back)
definitionally, so those two reuse each other; Sep's dual has its own lemma,
`sep_swap_valid`. -/
theorem axiom_dedekind_swap_valid {φ : Formula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ FrameClass.Dedekind) :
    ValidDedekindDense φ.swapTemporal := by
  by_cases hdense : h.minFrameClass ≤ FrameClass.Dense
  · intro D _ _ _ _ _ _hlub F M τ h_mem t
    exact SoundnessLemmas.axiom_swap_valid (D := D) φ h hdense F M τ h_mem t
  · cases h with
    | prior_U_gap ψ =>
      -- `(prior_U_gap ψ).swapTemporal` is definitionally `prior_S_gap ψ.swapTemporal`.
      exact prior_S_gap_valid ψ.swapTemporal
    | prior_S_gap ψ =>
      exact prior_U_gap_valid ψ.swapTemporal
    | sep ψ => exact sep_swap_valid ψ
    -- Discrete axioms: `Discrete ≰ Dedekind`, so `h_fc` is absurd. They need explicit arms
    -- rather than the catch-all below, which discharges via `trivial : minFrameClass ≤ Dense`
    -- and so only covers the Base and Dense constructors.
    | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | _ => exact absurd trivial hdense

/--
**Soundness Dedekind Valid**: Derivability from the empty context implies validity on dense
Dedekind-complete frames.

Patterned on `soundness_discrete_valid`. The `temporal_duality` case uses
`axiom_dedekind_swap_valid` through a mutual recursion-free route: swap-validity of a whole
derivation follows from swap-validity of its axioms plus the structural rules, which is what
`derivable_valid_and_swap_valid_dedekind` below establishes.
-/
theorem derivable_valid_and_swap_valid_dedekind {phi : Formula}
    (d : DerivationTree FrameClass.Dedekind [] phi) :
    ValidDedekindDense phi ∧ ValidDedekindDense phi.swapTemporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨axiom_dedekind_valid h_ax h_fc, axiom_dedekind_swap_valid h_ax h_fc⟩
  | .assumption _ _ h_mem =>
    exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ psi' _ d1 d2 =>
    have h1 := derivable_valid_and_swap_valid_dedekind d1
    have h2 := derivable_valid_and_swap_valid_dedekind d2
    constructor
    · intro D _ _ _ _ _ hlub F M tau h_mem t
      have h1' := h1.1 D hlub F M tau h_mem t
      have h2' := h2.1 D hlub F M tau h_mem t
      simp only [TruthAt] at h1'
      exact h1' h2'
    · intro D _ _ _ _ _ hlub F M tau h_mem t
      have h1' := h1.2 D hlub F M tau h_mem t
      have h2' := h2.2 D hlub F M tau h_mem t
      simp only [Formula.swapTemporal, TruthAt] at h1' ⊢
      exact h1' h2'
  | .necessitation psi' d' =>
    have h := derivable_valid_and_swap_valid_dedekind d'
    constructor
    · intro D _ _ _ _ _ hlub F M tau h_mem t
      simp only [TruthAt]
      intro sigma h_sigma_mem
      exact h.1 D hlub F M sigma h_sigma_mem t
    · intro D _ _ _ _ _ hlub F M tau h_mem t
      simp only [Formula.swapTemporal, TruthAt]
      intro sigma h_sigma_mem
      exact h.2 D hlub F M sigma h_sigma_mem t
  | .temporal_necessitation psi' d' =>
    have h := derivable_valid_and_swap_valid_dedekind d'
    constructor
    · intro D _ _ _ _ _ hlub F M tau h_mem t
      simp only [Truth.future_iff]
      intro s _hts
      exact h.1 D hlub F M tau h_mem s
    · intro D _ _ _ _ _ hlub F M tau h_mem t
      simp only [Formula.allFuture, Formula.someFuture, Formula.swapTemporal,
        Formula.neg, Formula.top] at *
      simp only [TruthAt] at *
      intro hcontra
      obtain ⟨s, hts, hs, _⟩ := hcontra
      exact hs (h.2 D hlub F M tau h_mem s)
  | .temporal_duality psi' d' =>
    have h := derivable_valid_and_swap_valid_dedekind d'
    refine ⟨h.2, ?_⟩
    rw [Formula.swap_temporal_involution]
    exact h.1
  | .weakening Gamma' _ _ d' h_sub =>
    have h_eq : Gamma' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Gamma' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_valid_dedekind (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/--
**Soundness Dedekind Valid**: Derivability from the empty context implies validity on dense
Dedekind-complete frames.
-/
theorem soundness_dedekind_valid {phi : Formula}
    (d : DerivationTree FrameClass.Dedekind [] phi) : ValidDedekindDense phi :=
  (derivable_valid_and_swap_valid_dedekind d).1

/--
**Soundness for Dedekind Frames**: Derivability implies semantic consequence on dense
Dedekind-complete frames.

This is the Dedekind analogue of `soundness_dense` and `soundness_discrete`. Given a
Dedekind-compatible derivation `Γ ⊢ φ`, if all formulas in `Γ` are true at some configuration
on a dense Dedekind-complete frame, then `φ` is also true there.

**The conclusion is stated over the `ValidDedekindDense` binder set, NOT `ValidDedekind`.**
`FrameClass.Dedekind` lies above `FrameClass.Dense`, so `Axiom.density` and
`Axiom.dense_indicator` are admissible in `d`; both are false on `ℤ`, and `ℤ` is
Dedekind-complete (Mathlib's `ConditionallyCompleteLinearOrder ℤ`). Dropping the
`[DenselyOrdered D]` binder here would therefore make this theorem refutable. See the section
docstring above and `Semantics/Validity.lean`.
-/
theorem soundness_dedekind (Γ : Context) (φ : Formula)
    (d : DerivationTree FrameClass.Dedekind Γ φ)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    (h_lub : ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x)
    (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (h_mem : τ.IsTotal) (t : D)
    (h_ctx : ∀ ψ ∈ Γ, TruthAt M τ t ψ) :
    TruthAt M τ t φ := by
  induction d generalizing τ t with
  | «axiom» Γ' φ' h_ax h_fc =>
    exact axiom_dedekind_valid h_ax h_fc D h_lub F M τ h_mem t
  | assumption Γ' φ' h_in =>
    exact h_ctx φ' h_in
  | modus_ponens Γ' φ' ψ' _ _ ih1 ih2 =>
    have h1 := ih1 τ h_mem t h_ctx
    have h2 := ih2 τ h_mem t h_ctx
    simp only [TruthAt] at h1
    exact h1 h2
  | necessitation φ' _ ih =>
    simp only [TruthAt]
    intro σ h_σ_mem
    exact ih σ h_σ_mem t (by simp)
  | temporal_necessitation φ' _ ih =>
    simp only [Truth.future_iff]
    intro s _hts
    exact ih τ h_mem s (by simp)
  | temporal_duality φ' d' _ih =>
    exact (derivable_valid_and_swap_valid_dedekind d').2 D h_lub F M τ h_mem t
  | weakening Γ' Δ' φ' _ h_sub ih =>
    exact ih τ h_mem t (fun ψ h_in => h_ctx ψ (h_sub h_in))

/-! ## Consistency of the Base System

Soundness's most immediate corollary: `⊥` is not a theorem. Every "the logic is consistent" side
condition in the tree ultimately wants this, and until it was stated here each such site had to
route around it by carrying an underivability hypothesis instead.

Stated as `¬ Derivable …` rather than as `Metalogic.Core.Consistent []`, which is the same
proposition by definition (`Consistent Γ := ¬ Derivable fc Γ ⊥`), because this module sits below
`Metalogic/Core/` in the import graph. Downstream files spell it with `Consistent` freely.
-/

/--
**The base system is consistent**: `⊥` is not derivable from the empty context.

The witness is `trivialFrame` over `Int` at its single world state. `soundness` turns a
derivation of `⊥` from `[]` into `trivialFrame.ValidOn ⊥`, which
`Semantics/Validity.lean`'s `TaskFrame.not_validOn_bot` refutes — that refutation is itself
`cor:occurrence`'s closing clause (`H_F ≠ ∅`), so the frame axioms doing the work here are
`trivialFrame`'s own fields.

`Int` is chosen only because it is the smallest temporal type in the tree supplying
`[Nontrivial D]`, which `soundness` binds; nothing about the argument depends on the choice.
-/
theorem not_derivable_nil_bot : ¬ Derivable FrameClass.Base ([] : Context) Formula.bot := by
  rintro ⟨d⟩
  refine TaskFrame.not_validOn_bot (D := Int) TaskFrame.trivialFrame ?_
  intro M τ x
  exact soundness [] Formula.bot d Int TaskFrame.trivialFrame M τ.val τ.property x
    (by simp)

end FormalSystem.Metalogic
