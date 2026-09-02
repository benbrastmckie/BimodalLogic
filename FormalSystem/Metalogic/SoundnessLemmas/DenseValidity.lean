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
Swap of F_until_equiv: `F(φ) → ⊤ U φ` swaps to `P(φ') → ⊤ S φ'`. -/
theorem swap_axiom_F_until_equiv_valid (φ : Formula) :
    IsValid D ((Formula.someFuture φ).imp
      (Formula.untl (Formula.bot.imp Formula.bot) φ)).swapTemporal := by
  intro F M τ _hτ t
  simp only [Formula.swapTemporal, TruthAt, Formula.someFuture]
  intro ⟨s, hst, h_φs, _⟩
  exact ⟨s, hst, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/--
Swap of P_since_equiv: `P(φ) → ⊤ S φ` swaps to `F(φ') → ⊤ U φ'`. -/
theorem swap_axiom_P_since_equiv_valid (φ : Formula) :
    IsValid D ((Formula.somePast φ).imp
      (Formula.snce (Formula.bot.imp Formula.bot) φ)).swapTemporal := by
  intro F M τ _hτ t
  simp only [Formula.swapTemporal, TruthAt, Formula.somePast]
  intro ⟨s, hts, h_φs, _⟩
  exact ⟨s, hts, h_φs, fun _ _ _ hf => absurd hf not_false⟩

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

/-! ## Axiom Swap Validity Master Theorem

This section adds the master theorem that combines all individual axiom swap validity lemmas.
All axiom cases are proven.

The proof handles each axiom case:
- **prop_k, prop_s**: Propositional tautologies, swap distributes over implication
- **modal_t, modal_4, modal_b**: Self-dual modal axioms (swap preserves schema form)
- **temp_4, temp_a**: Temporal axioms with straightforward swap semantics
- **temp_l (TL)**: Uses case analysis and classical logic for `always` encoding
- **modal_future (MF)**: Uses `time_shift_preserves_truth` to bridge times (TF now derived)
-/

theorem axiom_swap_valid (φ : Formula) (h : Axiom φ) [DenselyOrdered ↑D]
    (h_fc : h.minFrameClass ≤ FrameClass.Dense) : IsValid D φ.swapTemporal := by
  cases h with
  | prop_k ψ χ ρ =>
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_a _
    exact h_a
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ =>
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.diamond, Formula.neg]
    simp only [TruthAt]
    intro h_diamond_box σ h_σ_mem
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ h_ρ_mem h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ h_σ_mem
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_peirce
    by_cases h : TruthAt M τ t ψ.swapTemporal
    · exact h
    · have h_imp : TruthAt M τ t (ψ.swapTemporal.imp χ.swapTemporal) := by
        unfold TruthAt
        intro h_psi
        exfalso
        exact h h_psi
      exact h_peirce h_imp
  | modal_k_dist ψ χ =>
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_box_imp h_box_psi σ h_σ_mem
    exact h_box_imp σ h_σ_mem (h_box_psi σ h_σ_mem)
  -- NOTE: temp_k_dist and temp_4 removed as axiom constructors
  | serial_future =>
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_some_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | serial_past =>
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_some_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Swap of left_mono_until_G: H(φ'→χ') → snce(φ',ψ') → snce(χ',ψ')
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | left_mono_since_H φ χ ψ =>
    -- Swap of left_mono_since_H: G(φ'→χ') → untl(φ',ψ') → untl(χ',ψ')
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | right_mono_until φ ψ χ =>
    -- swap: G(φ'→χ') → (φ' S ψ') → (χ' S ψ')
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    -- swap: H(φ'→χ') → (φ' U ψ') → (χ' U ψ')
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | connect_future φ =>
    -- Swap of connect_future: φ → G(P(φ)) swaps to swap(φ) → H(F(swap(φ)))
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal_some_past,
      Formula.swapTemporal]
    simp only [TruthAt, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | connect_past φ =>
    -- Swap of connect_past: φ → H(F(φ)) swaps to swap(φ) → G(P(swap(φ)))
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal_some_future,
      Formula.swapTemporal]
    simp only [TruthAt, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Swap of enrichment_until: p ∧ snce(φ', ψ') → snce(φ', ψ' ∧ untl(φ', p))
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro h_conj
    have h_pt : TruthAt M τ t p.swapTemporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_since : ∃ s, s < t ∧ TruthAt M τ s ψ.swapTemporal ∧
        ∀ r, s < r → r < t → TruthAt M τ r φ.swapTemporal := by
      by_contra h_neg; exact h_conj (fun _ h_s => h_neg h_s)
    obtain ⟨s, hst, h_ψs, h_guard⟩ := h_since
    refine ⟨s, hst, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hst, h_pt, fun r hsr hrt => h_guard r hsr hrt⟩
  | enrichment_since φ ψ p =>
    -- Swap of enrichment_since: p ∧ untl(φ', ψ') → untl(φ', ψ' ∧ snce(φ', p))
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro h_conj
    have h_pt : TruthAt M τ t p.swapTemporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_until : ∃ s, t < s ∧ TruthAt M τ s ψ.swapTemporal ∧
        ∀ r, t < r → r < s → TruthAt M τ r φ.swapTemporal := by
      by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
    obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
    refine ⟨s, hts, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩
  | self_accum_until φ ψ =>
    -- Swap: (φ' S ψ') → ((φ' ∧ (φ' S ψ')) S ψ')
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr =>
        h_guard q hsq (lt_trans hqr hrt)⟩
  | self_accum_since φ ψ =>
    -- Swap: (φ' U ψ') → ((φ' ∧ (φ' U ψ')) U ψ')
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs =>
        h_guard q (lt_trans htr hrq) hqs⟩
  | absorb_until φ ψ =>
    -- Swap: (φ' S (φ' ∧ (φ' S ψ'))) → (φ' S ψ')
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
    have h_φs₁_and_since : TruthAt M τ s₁ φ.swapTemporal ∧
        (∃ s₂, s₂ < s₁ ∧ TruthAt M τ s₂ ψ.swapTemporal ∧
          ∀ q, s₂ < q → q < s₁ → TruthAt M τ q φ.swapTemporal) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_since => h_neg h_since)
    obtain ⟨h_φs₁, s₂, hs₂s₁, h_ψs₂, h_guard₂⟩ := h_φs₁_and_since
    refine ⟨s₂, lt_trans hs₂s₁ hs₁t, h_ψs₂, fun q hs₂q hqt => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₂ q hs₂q h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₁ q h_gt hqt
  | absorb_since φ ψ =>
    -- Swap: (φ' U (φ' ∧ (φ' U ψ'))) → (φ' U ψ')
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
    have h_φs₁_and_until : TruthAt M τ s₁ φ.swapTemporal ∧
        (∃ s₂, s₁ < s₂ ∧ TruthAt M τ s₂ ψ.swapTemporal ∧
          ∀ q, s₁ < q → q < s₂ → TruthAt M τ q φ.swapTemporal) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_until => h_neg h_until)
    obtain ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩ := h_φs₁_and_until
    refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₁ q htq h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₂ q h_gt hqs₂
  | linear_until φ ψ χ θ =>
    -- Swap: Since-based linearity with swapped subformulas
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.or, Formula.neg, TruthAt]
    intro h_conj
    have h_both : (∃ s, s < t ∧ TruthAt M τ s ψ.swapTemporal ∧
        ∀ r, s < r → r < t → TruthAt M τ r φ.swapTemporal) ∧
      (∃ s, s < t ∧ TruthAt M τ s θ.swapTemporal ∧
        ∀ r, s < r → r < t → TruthAt M τ r χ.swapTemporal) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hs₁t, h_ψs₁, h_guard₁⟩, s₂, hs₂t, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂ < t: third disjunct (φ∧χ) S (φ∧θ) with witness s₂
      intro _
      refine ⟨s₂, hs₂t, ?_, fun r hs₂r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ h_lt hs₂t) h_θs₂
      · exact h_imp (h_guard₁ r (lt_trans h_lt hs₂r) hrt) (h_guard₂ r hs₂r hrt)
    · -- s₁ = s₂: first disjunct (φ∧χ) S (ψ∧θ) with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (h_eq ▸ hs₁r) hrt)
    · -- s₂ < s₁ < t: second disjunct (φ∧χ) S (ψ∧χ) with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ h_gt hs₁t)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (lt_trans h_gt hs₁r) hrt)
  | linear_since φ ψ χ θ =>
    -- Swap: Until-based linearity with swapped subformulas
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.or, Formula.neg, TruthAt]
    intro h_conj
    have h_both : (∃ s, t < s ∧ TruthAt M τ s ψ.swapTemporal ∧
        ∀ r, t < r → r < s → TruthAt M τ r φ.swapTemporal) ∧
      (∃ s, t < s ∧ TruthAt M τ s θ.swapTemporal ∧
        ∀ r, t < r → r < s → TruthAt M τ r χ.swapTemporal) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: second disjunct (φ∧χ) U (ψ∧χ) with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ hts₁ h_lt)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (lt_trans hrs h_lt))
    · -- s₁ = s₂: first disjunct (φ∧χ) U (ψ∧θ) with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (h_eq ▸ hrs))
    · -- s₂ < s₁: third disjunct (φ∧χ) U (φ∧θ) with witness s₂
      intro _
      refine ⟨s₂, hts₂, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ hts₂ h_gt) h_θs₂
      · exact h_imp (h_guard₁ r htr (lt_trans hrs h_gt)) (h_guard₂ r htr hrs)
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted in the
  -- open-guard refactor)
  | until_F φ ψ =>
    -- Swap of until_F: (ψ U φ) → F(ψ) swaps to (ψ' S φ') → P(ψ')
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_some_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _h_guard⟩
    exact ⟨s, hst, h_ψs⟩
  | since_P φ ψ =>
    -- Swap of since_P: (ψ S φ) → P(ψ) swaps to (ψ' U φ') → F(ψ')
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_some_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _h_guard⟩
    exact ⟨s, hts, h_ψs⟩
  | temp_linearity φ ψ =>
    -- swap of future linearity is past linearity with swapped subformulas
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_some_future,
      Formula.swapTemporal, Formula.and, Formula.or, Formula.neg]
    simp only [TruthAt, Truth.some_past_iff]
    intro h_conj
    have ⟨s1, hs1t, h_φs1⟩ : ∃ s, s < t ∧ TruthAt M τ s φ.swapTemporal := by
      by_contra h_no; push Not at h_no
      exact h_conj (fun ⟨s, hst, h_phi⟩ _ => absurd h_phi (h_no s hst))
    have ⟨s2, hs2t, h_ψs2⟩ : ∃ s, s < t ∧ TruthAt M τ s ψ.swapTemporal := by
      by_contra h_no; push Not at h_no
      exact h_conj (fun _ ⟨s, hst, h_psi⟩ => absurd h_psi (h_no s hst))
    rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
    · -- s1 < s2: take r = s2, giving P(P(φ') ∧ ψ')
      intro _; intro _
      exact ⟨s2, hs2t, fun h_imp => h_imp ⟨s1, h_lt, h_φs1⟩ h_ψs2⟩
    · -- s1 = s2: giving P(φ' ∧ ψ')
      subst h_eq
      intro h_neg_first; exfalso; apply h_neg_first
      exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 h_ψs2⟩
    · -- s2 < s1: take r = s1, giving P(φ' ∧ P(ψ'))
      intro _; intro h_neg_second; exfalso; apply h_neg_second
      exact ⟨s1, hs1t, fun h_imp => h_imp h_φs1 ⟨s2, h_gt, h_ψs2⟩⟩
  | temp_linearity_past φ ψ =>
    -- swap of past linearity is future linearity with swapped subformulas
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_some_past,
      Formula.swapTemporal, Formula.and, Formula.or, Formula.neg]
    simp only [TruthAt, Truth.some_future_iff]
    intro h_conj
    have ⟨s1, hts1, h_φs1⟩ : ∃ s, t < s ∧ TruthAt M τ s φ.swapTemporal := by
      by_contra h_no; push Not at h_no
      exact h_conj (fun ⟨s, hts, h_phi⟩ _ => absurd h_phi (h_no s hts))
    have ⟨s2, hts2, h_ψs2⟩ : ∃ s, t < s ∧ TruthAt M τ s ψ.swapTemporal := by
      by_contra h_no; push Not at h_no
      exact h_conj (fun _ ⟨s, hts, h_psi⟩ => absurd h_psi (h_no s hts))
    rcases lt_trichotomy s1 s2 with h_lt | h_eq | h_gt
    · -- s1 < s2: take r = s1, giving F(φ' ∧ F(ψ'))
      intro _; intro h_neg_second; exfalso; apply h_neg_second
      exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 ⟨s2, h_lt, h_ψs2⟩⟩
    · -- s1 = s2: giving F(φ' ∧ ψ')
      subst h_eq
      intro h_neg_first; exfalso; apply h_neg_first
      exact ⟨s1, hts1, fun h_imp => h_imp h_φs1 h_ψs2⟩
    · -- s2 < s1: take r = s2, giving F(F(φ') ∧ ψ')
      intro _; intro _
      exact ⟨s2, hts2, fun h_imp => h_imp ⟨s1, h_gt, h_φs1⟩ h_ψs2⟩
  | F_until_equiv φ => exact swap_axiom_F_until_equiv_valid φ
  | P_since_equiv φ => exact swap_axiom_P_since_equiv_valid φ
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted in the
  -- open-guard refactor)
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | discrete_symm_fwd =>
    -- swap(U(T,bot) -> S(T,bot)) = S(T,bot) -> U(T,bot)
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro ⟨r, hrt, _h_top_r, h_guard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun h => h, fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (t - r)) h1 h2
  | discrete_symm_bwd =>
    -- swap(S(T,bot) -> U(T,bot)) = U(T,bot) -> S(T,bot)
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro ⟨s, hts, _h_top_s, h_guard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun h => h, fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact h_guard (c + (s - t)) h1 h2
  | discrete_propagate_fwd =>
    -- swap(U(T,bot) -> G(U(T,bot))) = S(T,bot) -> H(S(T,bot))
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.past_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _hut
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs =>
        rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_propagate_bwd =>
    -- swap(U(T,bot) -> H(U(T,bot))) = S(T,bot) -> G(S(T,bot))
    intro F M τ _hτ t
    simp only [Formula.swap_temporal_all_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.future_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _htu
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs =>
        rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_box_necessity =>
    -- swap(U(T,bot) -> □(U(T,bot))) = S(T,bot) -> □(S(T,bot))
    -- S(T,bot) depends only on D's order structure, not the history
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ σ _h_σ_mem
    exact ⟨r, hrt, fun h => h, h_guard⟩
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  -- Reynolds Dedekind axioms: eliminated by frame-class incomparability
  -- (`Dedekind ≰ Dense`), exactly like the Discrete cases above.
  | prior_U_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_S_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | sep _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | dense_indicator =>
    -- dense indicator: ¬U(⊤,⊥), swap is ¬S(⊤,⊥) (past density indicator)
    -- S(⊤,⊥) at t requires s < t with empty (s,t), contradicting DenselyOrdered
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.neg, TruthAt]
    intro ⟨s, hst, _h_top, h_guard⟩
    obtain ⟨r, hsr, hrt⟩ := exists_between hst
    exact h_guard r hsr hrt
  | density _ =>
    -- density axiom: GGφ → Gφ, swap is HHφ → Hφ (past density)
    -- HHφ = ¬P(¬Hφ) = ¬P(¬(¬P(¬φ))) and Hφ = ¬P(¬φ)
    -- We prove: ¬P(¬φ ∧ guard) given ¬P(¬(¬P(¬φ ∧ guard)) ∧ guard)
    -- Contrapositive: if ∃ s < t with ¬φ(s), find r via density with s < r < t
    -- Then ∃ r < t with ¬Hφ(r) (witnessed by s < r), giving P(¬Hφ)
    intro F M τ _hτ t
    simp only [Formula.swapTemporal, Formula.allFuture, Formula.someFuture,
      Formula.neg, TruthAt]
    intro h_HH ⟨s, hst, h_neg_phi_s, h_guard_s⟩
    apply h_HH
    obtain ⟨r, hrs, hrt⟩ := exists_between hst
    refine ⟨r, hrt, ?_, ?_⟩
    · -- Need: ¬¬P(¬φ) at r, i.e., ¬Hφ at r
      -- Witness: s < r with ¬φ(s)
      intro h_Hphi_r
      exact h_Hphi_r ⟨s, hrs, h_neg_phi_s, fun q hq1 hq2 => h_guard_s q hq1 (lt_trans hq2 hrt)⟩
    · -- Guard: all between r and t satisfy ⊤
      intro q hq1 hq2
      exact h_guard_s q (lt_trans hrs hq1) hq2

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
