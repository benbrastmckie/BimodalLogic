/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.SoundnessLemmas.Core
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

/-!
# Axiom and Rule Validity for the Dense Frame Class

Swap validity and local validity lemmas for the dense frame class. Proves that all TM
axioms remain valid after temporal swap.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.ProofSystem (Axiom DerivationTree FrameClass)
open FormalSystem.Semantics

variable {D : TemporalOrder}

/-! ## Axiom Swap Validity (Approach D: Derivation-Indexed Proof)

This section proves validity of swapped axioms to enable temporal duality soundness
via derivation induction instead of formula induction.

The key insight: Instead of proving "valid φ -> valid φ.swap" for ALL valid formulas
(which is impossible for arbitrary imp, past, future cases), we prove that EACH axiom
schema remains valid after swap. This suffices for soundness of the temporal_duality
rule because we only need swap preservation for derivable formulas.

**Self-Dual Axioms**: MT, M4, MB have the property that swap preserves their schema form.
**Transformed Axioms**: MF and the until/since equivalences transform to different but
still valid formulas.
-/

/--
Modal T axiom (MT) is self-dual under swap: `box φ -> φ` swaps to `box(swap φ) -> swap φ`.

Since `box(swap φ) -> swap φ` is still an instance of MT (just with swapped subformula),
and MT is valid, this is immediate.

**Proof**: The swapped form is `(box φ.swapTemporal).imp φ.swapTemporal`.
At any triple (M, τ, t), if box φ.swap holds, then φ.swap holds at (M, τ, t) specifically.
-/
theorem swap_axiom_mt_valid (φ : Formula) :
    IsValid D ((Formula.box φ).imp φ).swapTemporal := by
  intro F M τ h_mem t
  simp only [Formula.swapTemporal, TruthAt]
  intro h_box_swap_φ
  exact h_box_swap_φ τ h_mem

/--
Modal 4 axiom (M4) is self-dual under swap: `box φ -> box box φ` swaps to `box(swap φ) -> box
box(swap φ)`.

This is still M4, just applied to swapped formula.

**Proof**: If φ.swap holds at all total histories at t, then
"φ.swap holds at all total histories at t"
holds at all total histories at t (trivially, as this is a global property).
-/
theorem swap_axiom_m4_valid (φ : Formula) :
    IsValid D ((Formula.box φ).imp (Formula.box (Formula.box φ))).swapTemporal := by
  intro F M τ _hτ t
  simp only [Formula.swapTemporal, TruthAt]
  intro h_box_swap_φ σ h_σ_mem ρ h_ρ_mem
  exact h_box_swap_φ ρ h_ρ_mem

/--
Modal B axiom (MB) is self-dual under swap: `φ -> box diamond φ` swaps to `swap φ -> box
diamond(swap φ)`.

This is still MB, just applied to swapped formula.

**Proof**: If φ.swap holds at (M, τ, t), then for any total history σ at t, diamond(φ.swap) holds
at σ.
The diamond means "there exists some total history where it holds". We have τ witnessing this.
-/
theorem swap_axiom_mb_valid (φ : Formula) :
    IsValid D (φ.imp (Formula.box φ.diamond)).swapTemporal := by
  intro F M τ h_mem t
  simp only [Formula.swapTemporal, Formula.diamond, Formula.neg]
  simp only [TruthAt]
  intro h_swap_φ σ _h_σ_mem h_all_not
  exact h_all_not τ h_mem h_swap_φ

/--
Modal-Future axiom (MF) swaps to a valid formula: `box φ -> box Fφ` swaps to `box(swap φ) -> box
P(swap φ)`.

The swapped form states: if swap φ holds at all total histories at time t, then for all total
histories σ at time t, P(swap φ) holds at σ (i.e., swap φ holds at all times s < t in σ).

**Proof Strategy**: Use `time_shift_preserves_truth` to bridge from time t to time s < t.
Totality of the shifted history is `WorldHistory.isTotal_timeShift`; no shift-closure side
condition is required.
-/
theorem swap_axiom_mf_valid (φ : Formula) :
    IsValid D ((Formula.box φ).imp (Formula.box (Formula.allFuture φ))).swapTemporal := by
  intro F M τ _hτ t
  simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
  simp only [TruthAt, Truth.past_iff]
  intro h_box_swap σ h_σ_mem s h_s_lt_t
  have h_at_shifted :=
    h_box_swap (WorldHistory.timeShift σ (s - t))
      (WorldHistory.isTotal_timeShift h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M σ t s φ.swapTemporal).mp h_at_shifted

/-! ## Axiom Validity (Local)

These lemmas prove validity of each axiom using the local `IsValid` definition.
This is needed to prove the combined soundness+swap theorem without importing Soundness.lean.
-/

/-- Temporal linearity axiom is locally valid (strict semantics).

`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`

The proof uses linearity of D (the `lt_trichotomy` from `LinearOrder`). Given witnesses
s1 > t for φ and s2 > t for ψ, either s1 < s2 (take r = s1, giving F(φ ∧ F(ψ))),
s1 = s2 (giving F(φ ∧ ψ)), or s2 < s1 (take r = s2, giving F(F(φ) ∧ ψ)).
-/
theorem axiom_temp_linearity_valid (φ ψ : Formula) :
    IsValid D (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and φ ψ))
        (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
          (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))))) := by
  intro F M τ _hτ t
  simp only [Formula.and, Formula.or, Formula.neg, TruthAt,
    Truth.some_future_iff]
  intro h_conj
  -- Extract Fφ witness
  have ⟨s1, hts1, h_φs1⟩ : ∃ s, t < s ∧ TruthAt M τ s φ := by
    by_contra h_no; push Not at h_no
    exact h_conj (fun ⟨s, hts, h_phi⟩ _ => absurd h_phi (h_no s hts))
  -- Extract Fψ witness
  have ⟨s2, hts2, h_ψs2⟩ : ∃ s, t < s ∧ TruthAt M τ s ψ := by
    by_contra h_no; push Not at h_no
    exact h_conj (fun _ ⟨s, hts, h_psi⟩ => absurd h_psi (h_no s hts))
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: take r = s1, giving F(φ ∧ F(ψ))
    intro _; intro h_neg_second; exfalso; apply h_neg_second
    exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 ⟨s2, h_lt, h_ψs2⟩⟩
  · -- s1 = s2: giving F(φ ∧ ψ)
    subst h_eq
    intro h_neg_first; exfalso; apply h_neg_first
    exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 h_ψs2⟩
  · -- s2 < s1: take r = s2, giving F(F(φ) ∧ ψ)
    intro _; intro _
    exact ⟨s2, hts2, fun h_imp => h_imp ⟨s1, h_gt, h_φs1⟩ h_ψs2⟩

/-- Past temporal linearity axiom validity (BX11'):
`P(φ) ∧ P(ψ) → P(φ ∧ ψ) ∨ P(φ ∧ P(ψ)) ∨ P(P(φ) ∧ ψ)` is locally valid.
Mirror of `axiom_temp_linearity_valid` for the past direction. -/
theorem axiom_temp_linearity_past_valid (φ ψ : Formula) :
    IsValid D (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) := by
  intro F M τ _hτ t
  simp only [Formula.and, Formula.or, Formula.neg, TruthAt,
    Truth.some_past_iff]
  intro h_conj
  -- Extract Pφ witness
  have ⟨s1, hs1t, h_φs1⟩ : ∃ s, s < t ∧ TruthAt M τ s φ := by
    by_contra h_no; push Not at h_no
    exact h_conj (fun ⟨s, hst, h_phi⟩ _ => absurd h_phi (h_no s hst))
  -- Extract Pψ witness
  have ⟨s2, hs2t, h_ψs2⟩ : ∃ s, s < t ∧ TruthAt M τ s ψ := by
    by_contra h_no; push Not at h_no
    exact h_conj (fun _ ⟨s, hst, h_psi⟩ => absurd h_psi (h_no s hst))
  rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
  · -- s1 < s2: take r = s2, giving P(P(φ) ∧ ψ)
    intro _; intro _
    exact ⟨s2, hs2t, fun h_imp => h_imp ⟨s1, h_lt, h_φs1⟩ h_ψs2⟩
  · -- s1 = s2: giving P(φ ∧ ψ)
    subst h_eq
    intro h_neg_first; exfalso; apply h_neg_first
    exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 h_ψs2⟩
  · -- s1 > s2: take r = s1, giving P(φ ∧ P(ψ))
    intro _; intro h_neg_second; exfalso; apply h_neg_second
    exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 ⟨s2, h_gt, h_ψs2⟩⟩

/-- F-Until equivalence axiom validity (BX12):
`F(φ) → (⊤ U φ)` is locally valid.
If there exists s ≥ t with φ(s), then ⊤ U φ holds at t (take witness s, guard ⊤ = ¬⊥ is trivially
satisfied). -/
theorem axiom_F_until_equiv_valid (φ : Formula) :
    IsValid D ((Formula.someFuture φ).imp
      (Formula.untl (Formula.bot.imp Formula.bot) φ)) := by
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, h_φs⟩
  exact ⟨s, hts, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/-- P-Since equivalence axiom validity (BX12'):
`P(φ) → (⊤ S φ)` is locally valid. Past dual of F-Until equivalence. -/
theorem axiom_P_since_equiv_valid (φ : Formula) :
    IsValid D ((Formula.somePast φ).imp
      (Formula.snce (Formula.bot.imp Formula.bot) φ)) := by
  intro F M τ _hτ t
  simp only [TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, h_φs⟩
  exact ⟨s, hst, h_φs, fun _ _ _ hf => absurd hf not_false⟩

end FormalSystem.Metalogic.SoundnessLemmas
