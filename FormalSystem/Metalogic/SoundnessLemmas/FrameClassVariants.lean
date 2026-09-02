/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.SoundnessLemmas.Core
import FormalSystem.Semantics.Validity
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

/-!
# Soundness Lemmas for General and Discrete Frame Classes

Per-axiom validity and swap-validity for the base frame class, stated without density
constraints, together with the discrete-specific axioms. The two `Per-Axiom` sections below
hold the individual schema lemmas; `axiom_swap_valid_general` dispatches over all 45 axiom
constructors and delegates to them.
-/

namespace FormalSystem.Metalogic.SoundnessLemmas

open FormalSystem.Syntax
open FormalSystem.ProofSystem (Axiom DerivationTree FrameClass)
open FormalSystem.Semantics

variable {D : TemporalOrder}

/-! ## Per-Axiom Swap Validity

Validity of swapped axioms, which is what lets temporal-duality soundness run by derivation
induction instead of formula induction: "valid φ → valid φ.swap" is false for arbitrary
formulas, but each axiom *schema* remains valid after swap, and that is all a derivation needs.

**Self-Dual Axioms**: MT, M4, MB have the property that swap preserves their schema form.
**Transformed Axiom**: MF transforms to a different but still valid formula.

These are the delegation targets of `axiom_swap_valid_general`'s one-line arms below.
-/

/--
Modal T axiom (MT) is self-dual under swap: `box φ -> φ` swaps to `box(swap φ) -> swap φ`.

Since `box(swap φ) -> swap φ` is still an instance of MT (just with swapped subformula),
and MT is valid, this is immediate.

**Proof**: The swapped form is `(box φ.swapTemporal).imp φ.swapTemporal`.
At any triple (M, τ, t), if box φ.swap holds, then φ.swap holds at (M, τ, t) specifically.
-/
theorem swap_axiom_mt_valid (φ : Formula) :
    ValidIn FrameClass.Base ((Formula.box φ).imp φ).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ h_mem t
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
    ValidIn FrameClass.Base ((Formula.box φ).imp (Formula.box (Formula.box φ))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
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
    ValidIn FrameClass.Base (φ.imp (Formula.box φ.diamond)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ h_mem t
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
    ValidIn FrameClass.Base
      ((Formula.box φ).imp (Formula.box (Formula.allFuture φ))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
  simp only [TruthAt, Truth.past_iff]
  intro h_box_swap σ h_σ_mem s h_s_lt_t
  have h_at_shifted :=
    h_box_swap (WorldHistory.timeShift σ (s - t))
      (WorldHistory.isTotal_timeShift h_σ_mem (s - t))
  exact (TimeShift.time_shift_preserves_truth M σ t s φ.swapTemporal).mp h_at_shifted

/-! ## Per-Axiom Validity of the Unswapped Schemas

Validity of the unswapped axiom schemas at `FrameClass.Base`. The swap arms below consume these
at swapped arguments, which is why the temporal-linearity and until/since pairs come in both
future- and past-directed forms.
-/

/-- Temporal linearity axiom is locally valid (strict semantics).

`F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`

The proof uses linearity of D (the `lt_trichotomy` from `LinearOrder`). Given witnesses
s1 > t for φ and s2 > t for ψ, either s1 < s2 (take r = s1, giving F(φ ∧ F(ψ))),
s1 = s2 (giving F(φ ∧ ψ)), or s2 < s1 (take r = s2, giving F(F(φ) ∧ ψ)).
-/
theorem axiom_temp_linearity_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base (Formula.and (Formula.someFuture φ) (Formula.someFuture ψ) |>.imp
      (Formula.or (Formula.someFuture (Formula.and φ ψ))
        (Formula.or (Formula.someFuture (Formula.and φ (Formula.someFuture ψ)))
          (Formula.someFuture (Formula.and (Formula.someFuture φ) ψ))))) := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
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
    ValidIn FrameClass.Base (Formula.and (Formula.somePast φ) (Formula.somePast ψ) |>.imp
      (Formula.or (Formula.somePast (Formula.and φ ψ))
        (Formula.or (Formula.somePast (Formula.and φ (Formula.somePast ψ)))
          (Formula.somePast (Formula.and (Formula.somePast φ) ψ))))) := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
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
    ValidIn FrameClass.Base ((Formula.someFuture φ).imp
      (Formula.untl (Formula.bot.imp Formula.bot) φ)) := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, h_φs⟩
  exact ⟨s, hts, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/-- P-Since equivalence axiom validity (BX12'):
`P(φ) → (⊤ S φ)` is locally valid. Past dual of F-Until equivalence. -/
theorem axiom_P_since_equiv_valid (φ : Formula) :
    ValidIn FrameClass.Base ((Formula.somePast φ).imp
      (Formula.snce (Formula.bot.imp Formula.bot) φ)) := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, h_φs⟩
  exact ⟨s, hst, h_φs, fun _ _ _ hf => absurd hf not_false⟩

/-! ## General (Frame-Class-Free) Versions

All base axioms (those with `minFrameClass = .Base`) are valid on any linear order,
without requiring `[DenselyOrdered ↑D]` or `[Nontrivial D]`. These general versions
remove frame constraints from the swap/locally-valid lemmas, enabling soundness proofs
for the base frame class without unnecessary hypotheses.

This resolves the 3 `temporal_duality` sorries in Soundness.lean:
- `soundness` (general, line ~877)
- `soundness_discrete_valid` (line ~1094)
- `soundness_discrete` (line ~1151)
-/

/-- All base axiom swaps are valid without DenselyOrdered constraints.
Base axioms (minFrameClass = .Base) don't need density or discreteness.

**Why `FrameClass.Base` is essential here**: `h_fc : h.minFrameClass ≤ FrameClass.Base` is the
admissibility *split* that makes the conclusion hold with no order-theoretic instances on `D`.
Widening it to an arbitrary `fc` would admit axioms whose swap-validity genuinely needs those
instances. The wider case is `Metalogic/Soundness.lean`'s `axiom_swap_validIn_min`, which does
that split once for every class and consumes this lemma as its `.Base` branch. -/
theorem axiom_swap_valid_general (φ : Formula) (h : Axiom φ) (h_fc :
      h.minFrameClass ≤ FrameClass.Base)
    : ValidIn FrameClass.Base φ.swapTemporal := by
  cases h with
  | prop_k ψ χ ρ =>
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_a _
    exact h_a
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ =>
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, Formula.diamond, Formula.neg]
    simp only [TruthAt]
    intro h_diamond_box σ h_σ_mem
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ h_ρ_mem h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ h_σ_mem
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro h_box_imp h_box_psi σ h_σ_mem
    exact h_box_imp σ h_σ_mem (h_box_psi σ h_σ_mem)
  | serial_future =>
    -- swap of serial_future (⊤ → F⊤) is (⊤ → P⊤), need exists_lt
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_some_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | serial_past =>
    -- swap of serial_past (⊤ → P⊤) is (⊤ → F⊤), need exists_gt
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_some_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Swap of left_mono_until_G: H(φ'→χ') → snce(φ',ψ') → snce(χ',ψ')
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | left_mono_since_H φ χ ψ =>
    -- Swap of left_mono_since_H: G(φ'→χ') → untl(φ',ψ') → untl(χ',ψ')
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_all_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | right_mono_until φ ψ χ =>
    -- swap: H(φ'→χ') → (φ' S ψ') → (χ' S ψ')
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    -- swap: G(φ'→χ') → (φ' U ψ') → (χ' U ψ')
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_all_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | connect_future φ =>
    -- connect_future: φ → G(P(φ)), swap: swap(φ) → H(F(swap(φ)))
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal_all_future,
      Formula.swapTemporal]
    simp only [TruthAt, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | connect_past φ =>
    -- connect_past: φ → H(F(φ)), swap: swap(φ) → G(P(swap(φ)))
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal_all_past,
      Formula.swapTemporal]
    simp only [TruthAt, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Swap of enrichment_until: p ∧ snce(φ', ψ') → snce(φ', ψ' ∧ untl(φ', p))
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr =>
        h_guard q hsq (lt_trans hqr hrt)⟩
  | self_accum_since φ ψ =>
    -- Swap: (φ' U ψ') → ((φ' ∧ (φ' U ψ')) U ψ')
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs =>
        h_guard q (lt_trans htr hrq) hqs⟩
  | absorb_until φ ψ =>
    -- Swap: (φ' S (φ' ∧ (φ' S ψ'))) → (φ' S ψ')
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    -- swap of ((φ U ψ) → F(ψ)) is ((φ' S ψ') → P(ψ'))
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_some_future, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _h_guard⟩
    exact ⟨s, hst, h_ψs⟩
  | since_P φ ψ =>
    -- swap of ((φ S ψ) → P(ψ)) is ((φ' U ψ') → F(ψ'))
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swap_temporal_some_past, Formula.swapTemporal]
    simp only [TruthAt, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _h_guard⟩
    exact ⟨s, hts, h_ψs⟩
  | temp_linearity φ ψ =>
    exact axiom_temp_linearity_past_valid φ.swapTemporal ψ.swapTemporal
  | temp_linearity_past φ ψ =>
    exact axiom_temp_linearity_valid φ.swapTemporal ψ.swapTemporal
  | F_until_equiv φ =>
    exact axiom_P_since_equiv_valid φ.swapTemporal
  | P_since_equiv φ =>
    exact axiom_F_until_equiv_valid φ.swapTemporal
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted in the
  -- open-guard refactor)
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | discrete_symm_fwd =>
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
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
    refine ValidIn.of_forall_total ?_
    intro F _ M τ _hτ t
    simp only [Formula.swapTemporal, TruthAt]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ σ _h_σ_mem
    exact ⟨r, hrt, fun h => h, h_guard⟩
  | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  -- Reynolds Dedekind axioms: eliminated by frame-class incomparability
  -- (`Dedekind ≰ Base`), exactly like the Dense and Discrete cases above.
  | prior_U_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_S_gap _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | sep _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-! ## Discrete Frame Versions

The following theorems provide validity and swap-validity for all axioms on discrete
frames. Prior-UZ/SZ have `minFrameClass = .Discrete` and are only valid on discrete orders,
so these theorems handle all axioms including Prior-UZ/SZ. The discrete frame class
constraint `h.minFrameClass ≤ .Discrete` structurally excludes the density axiom.
-/

/-- Prior-UZ is valid on discrete orders: F(φ) → U(φ, ¬φ).
The nearest future witness where φ holds satisfies Until with ¬φ as guard.
Uses Nat.find for well-founded descent on the succ chain. -/
theorem prior_UZ_is_valid
    [SuccOrder ↑D] [PredOrder ↑D] [IsSuccArchimedean ↑D] [IsPredArchimedean ↑D]
    (φ : Formula) : IsValid D (φ.someFuture.imp (Formula.untl φ.neg φ)) := by
  intro F M τ _hτ t
  simp only [Formula.neg, TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, hs⟩
  obtain ⟨n, hn⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hn1 : Order.succ^[n + 1] t = s := by
    simp only [Function.iterate_succ, Function.comp_apply]; exact hn
  classical
  have h_ex : ∃ k, TruthAt M τ (Order.succ^[k + 1] t) φ := ⟨n, hn1 ▸ hs⟩
  let k₀ := Nat.find h_ex
  have hk₀ : TruthAt M τ (Order.succ^[k₀ + 1] t) φ := Nat.find_spec h_ex
  have hk₀_min : ∀ m < k₀, ¬TruthAt M τ (Order.succ^[m + 1] t) φ :=
    fun m hm => Nat.find_min h_ex hm
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts.not_isMax
  refine ⟨Order.succ^[k₀ + 1] t, ?_, hk₀, ?_⟩
  · -- t < succ^[k₀+1] t: from t < succ t ≤ succ^[k₀+1] t
    have h1 := h_iter_mono (Nat.one_le_iff_ne_zero.mpr (Nat.succ_ne_zero k₀))
    simp only at h1
    exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max) h1
  · -- ∀ r, t < r → r < succ^[k₀+1] t → ¬ TruthAt r φ
    intro r htr hrs
    obtain ⟨j, hj⟩ := (Order.succ_le_of_lt htr).exists_succ_iterate
    have hj1 : Order.succ^[j + 1] t = r := by
      simp only [Function.iterate_succ, Function.comp_apply]; exact hj
    have hj_lt : j < k₀ := by
      by_contra h_ge
      push Not at h_ge
      have h_le := h_iter_mono (show k₀ + 1 ≤ j + 1 by omega)
      simp only at h_le
      rw [hj1] at h_le
      exact absurd hrs (not_lt.mpr h_le)
    rw [← hj1]
    exact hk₀_min j hj_lt

/-- Prior-SZ is valid on discrete orders: P(φ) → S(φ, ¬φ).
Mirror of prior_UZ_is_valid using pred chain and IsPredArchimedean. -/
theorem prior_SZ_is_valid
    [SuccOrder ↑D] [PredOrder ↑D] [IsSuccArchimedean ↑D] [IsPredArchimedean ↑D]
    (φ : Formula) : IsValid D (φ.somePast.imp (Formula.snce φ.neg φ)) := by
  intro F M τ _hτ t
  simp only [Formula.neg, TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, hs⟩
  obtain ⟨n, hn⟩ := (Order.le_pred_of_lt hst).exists_pred_iterate
  have hn1 : Order.pred^[n + 1] t = s := by
    simp only [Function.iterate_succ, Function.comp_apply]; exact hn
  classical
  have h_ex : ∃ k, TruthAt M τ (Order.pred^[k + 1] t) φ := ⟨n, hn1 ▸ hs⟩
  let k₀ := Nat.find h_ex
  have hk₀ : TruthAt M τ (Order.pred^[k₀ + 1] t) φ := Nat.find_spec h_ex
  have hk₀_min : ∀ m < k₀, ¬TruthAt M τ (Order.pred^[m + 1] t) φ :=
    fun m hm => Nat.find_min h_ex hm
  have h_iter_anti : Antitone (fun i => Order.pred^[i] t) :=
    Order.pred_mono.antitone_iterate_of_map_le (Order.pred_le t)
  have h_not_min : ¬IsMin t := hst.not_isMin
  refine ⟨Order.pred^[k₀ + 1] t, ?_, hk₀, ?_⟩
  · -- pred^[k₀+1] t < t: from pred^[k₀+1] t ≤ pred t < t
    have h1 := h_iter_anti (Nat.one_le_iff_ne_zero.mpr (Nat.succ_ne_zero k₀))
    simp only at h1
    exact lt_of_le_of_lt h1 (Order.pred_lt_of_not_isMin h_not_min)
  · intro r hrs hrt
    obtain ⟨j, hj⟩ := (Order.le_pred_of_lt hrt).exists_pred_iterate
    have hj1 : Order.pred^[j + 1] t = r := by
      simp only [Function.iterate_succ, Function.comp_apply]; exact hj
    have hj_lt : j < k₀ := by
      by_contra h_ge
      push Not at h_ge
      have h_le := h_iter_anti (show k₀ + 1 ≤ j + 1 by omega)
      simp only at h_le
      rw [hj1] at h_le
      exact absurd hrs (not_lt.mpr h_le)
    rw [← hj1]
    exact hk₀_min j hj_lt

/-- Z1 is valid on discrete orders: G(Gφ→φ) → (FGφ→Gφ).
Backward induction from the Gφ witness using IsSuccArchimedean. -/
theorem z1_is_valid
    [SuccOrder ↑D] [PredOrder ↑D] [IsSuccArchimedean ↑D] [IsPredArchimedean ↑D]
    (φ : Formula) : IsValid D ((φ.allFuture.imp φ).allFuture.imp
        (φ.allFuture.someFuture.imp φ.allFuture)) := by
  intro F M τ _hτ t
  simp only [TruthAt, Truth.future_iff, Truth.some_future_iff]
  intro h_GGpIp ⟨s₀, hts₀, hs₀⟩
  obtain ⟨n₀, hn₀⟩ := (Order.succ_le_of_lt hts₀).exists_succ_iterate
  have hn₀_eq : Order.succ^[n₀ + 1] t = s₀ := by
    change Order.succ^[n₀] (Order.succ t) = s₀; exact hn₀
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts₀.not_isMax
  -- Helper: TruthAt s φ for any s > t (the main goal, proved assuming backward induction)
  -- We prove: ∀ s > t, TruthAt s φ, using backward induction from s₀.
  -- Strategy: for any s > t, obtain n with succ^[n](succ(t)) = s, then dispatch:
  --   n ≤ n₀: backward induction (h_descend below)
  --   n > n₀: either s₀ is max (so s = s₀, use h_GGpIp), or s > s₀ (use hs₀)
  have h_above_s0 : ∀ s, s₀ ≤ s → TruthAt M τ s φ := by
    intro s hs
    rcases eq_or_lt_of_le hs with rfl | hlt
    · exact h_GGpIp s₀ hts₀ hs₀
    · exact hs₀ s hlt
  -- Backward induction: TruthAt (succ^[k+1](t)) φ for all k, using Nat.strong_induction_on
  -- on the "distance from top" n₀ - k (= 0 when k ≥ n₀).
  have h_all_iterates : ∀ k, TruthAt M τ (Order.succ^[k + 1] t) φ := by
    -- Prove ∀ k ≤ n₀ by strong induction on n₀ - k
    suffices h_le : ∀ k, k ≤ n₀ → TruthAt M τ (Order.succ^[k + 1] t) φ by
      intro k
      by_cases hk : k ≤ n₀
      · exact h_le k hk
      · exact h_above_s0 _ (hn₀_eq ▸ h_iter_mono (by omega : n₀ + 1 ≤ k + 1))
    -- Strong induction: prove for k assuming it holds for all k' with k < k' ≤ n₀
    have : ∀ d, d ≤ n₀ → ∀ k, n₀ - k = d → k ≤ n₀ →
        TruthAt M τ (Order.succ^[k + 1] t) φ := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro hd k hk hkn
        apply h_GGpIp
        · exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max)
            (h_iter_mono (by omega : 1 ≤ k + 1))
        · -- Need: ∀ r > succ^[k+1](t), TruthAt r φ
          intro r hr
          obtain ⟨j, hj⟩ := (Order.succ_le_of_lt hr).exists_succ_iterate
          have hj_eq : Order.succ^[j + 1] (Order.succ^[k + 1] t) = r := by
            change Order.succ^[j] (Order.succ (Order.succ^[k + 1] t)) = r; exact hj
          rw [← hj_eq, ← Function.iterate_add_apply,
              show j + 1 + (k + 1) = (k + j + 1) + 1 from by omega]
          by_cases h_le : k + j + 1 ≤ n₀
          · exact ih (n₀ - (k + j + 1)) (by omega) (by omega) (k + j + 1) rfl h_le
          · exact h_above_s0 _ (hn₀_eq ▸ h_iter_mono (by omega : n₀ + 1 ≤ (k + j + 1) + 1))
    intro k hk
    exact this (n₀ - k) (by omega) k rfl hk
  -- Main goal
  intro s hts
  obtain ⟨m, hm⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hm_eq : Order.succ^[m] (Order.succ t) = s := hm
  exact (show Order.succ^[m + 1] t = s from hm_eq) ▸ h_all_iterates m

/-- Z1 past dual is valid on discrete orders: H(Hφ→φ) → (PHφ→Hφ).
Backward induction using IsPredArchimedean. -/
theorem z1_past_is_valid
    [SuccOrder ↑D] [PredOrder ↑D] [IsSuccArchimedean ↑D] [IsPredArchimedean ↑D]
    (φ : Formula) : IsValid D ((φ.allPast.imp φ).allPast.imp
        (φ.allPast.somePast.imp φ.allPast)) := by
  intro F M τ _hτ t
  simp only [TruthAt, Truth.past_iff, Truth.some_past_iff]
  intro h_HHpIp ⟨s₀, hs₀t, hs₀⟩
  obtain ⟨n₀, hn₀⟩ := (Order.le_pred_of_lt hs₀t).exists_pred_iterate
  have hn₀_eq : Order.pred^[n₀ + 1] t = s₀ := by
    change Order.pred^[n₀] (Order.pred t) = s₀; exact hn₀
  have h_iter_anti : Antitone (fun i => Order.pred^[i] t) :=
    Order.pred_mono.antitone_iterate_of_map_le (Order.pred_le t)
  have h_not_min : ¬IsMin t := hs₀t.not_isMin
  have h_below_s0 : ∀ u, u ≤ s₀ → TruthAt M τ u φ := by
    intro u hu
    rcases eq_or_lt_of_le hu with rfl | hlt
    · exact h_HHpIp _ hs₀t hs₀
    · exact hs₀ u hlt
  have h_all_iterates : ∀ k, TruthAt M τ (Order.pred^[k + 1] t) φ := by
    suffices h_le : ∀ k, k ≤ n₀ → TruthAt M τ (Order.pred^[k + 1] t) φ by
      intro k
      by_cases hk : k ≤ n₀
      · exact h_le k hk
      · exact h_below_s0 _ (hn₀_eq ▸ h_iter_anti (by omega : n₀ + 1 ≤ k + 1))
    have : ∀ d, d ≤ n₀ → ∀ k, n₀ - k = d → k ≤ n₀ →
        TruthAt M τ (Order.pred^[k + 1] t) φ := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro hd k hk hkn
        apply h_HHpIp
        · exact lt_of_le_of_lt (h_iter_anti (by omega : 1 ≤ k + 1))
            (Order.pred_lt_of_not_isMin h_not_min)
        · intro r hr
          obtain ⟨j, hj⟩ := (Order.le_pred_of_lt hr).exists_pred_iterate
          have hj_eq : Order.pred^[j + 1] (Order.pred^[k + 1] t) = r := by
            change Order.pred^[j] (Order.pred (Order.pred^[k + 1] t)) = r; exact hj
          rw [← hj_eq, ← Function.iterate_add_apply,
              show j + 1 + (k + 1) = (k + j + 1) + 1 from by omega]
          by_cases h_le : k + j + 1 ≤ n₀
          · exact ih (n₀ - (k + j + 1)) (by omega) (by omega) (k + j + 1) rfl h_le
          · exact h_below_s0 _ (hn₀_eq ▸ h_iter_anti (by omega : n₀ + 1 ≤ (k + j + 1) + 1))
    intro k hk
    exact this (n₀ - k) (by omega) k rfl hk
  intro s hst
  obtain ⟨m, hm⟩ := (Order.le_pred_of_lt hst).exists_pred_iterate
  have hm_eq : Order.pred^[m] (Order.pred t) = s := hm
  exact (show Order.pred^[m + 1] t = s from hm_eq) ▸ h_all_iterates m


end FormalSystem.Metalogic.SoundnessLemmas
