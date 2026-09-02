/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
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

/-- Propositional K swaps to itself at swapped subformulas: swap distributes over `imp`, and
`TruthAt` at an implication is definitionally an arrow, so this is the K combinator. -/
theorem prop_k_swap_valid (φ ψ χ : Formula) :
    ValidIn FrameClass.Base
      ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  intro h_abc h_ab h_a
  exact h_abc h_a (h_ab h_a)

/-- Propositional S swaps to itself at swapped subformulas: the K combinator of the pair. -/
theorem prop_s_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base (φ.imp (ψ.imp φ)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  intro h_a _
  exact h_a

/-- Modal 5 collapse swaps to itself: `◇□φ → □φ` is self-dual under the temporal swap, since the
swap touches no modal operator. The `box`/`diamond` pair is the S5 collapse over total histories,
which does not mention time at all. -/
theorem modal_5_collapse_swap_valid (φ : Formula) :
    ValidIn FrameClass.Base (φ.box.diamond.imp φ.box).swapTemporal := by
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

/-- Ex falso swaps to itself at a swapped consequent. -/
theorem ex_falso_swap_valid (φ : Formula) :
    ValidIn FrameClass.Base (Formula.bot.imp φ).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  intro h_bot
  exfalso
  exact h_bot

/-- Peirce's law swaps to itself at swapped subformulas; the proof is the classical case split on
whether the swapped antecedent holds. -/
theorem peirce_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base (((φ.imp ψ).imp φ).imp φ).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swapTemporal, TruthAt]
  intro h_peirce
  by_cases h : TruthAt M τ t φ.swapTemporal
  · exact h
  · have h_imp : TruthAt M τ t (φ.swapTemporal.imp ψ.swapTemporal) := by
      unfold TruthAt
      intro h_psi
      exfalso
      exact h h_psi
    exact h_peirce h_imp

/-- Modal K distribution swaps to itself: the swap fixes `□`, so this is K at swapped
subformulas. -/
theorem modal_k_dist_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base ((φ.imp ψ).box.imp (φ.box.imp ψ.box)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  intro h_box_imp h_box_psi σ h_σ_mem
  exact h_box_imp σ h_σ_mem (h_box_psi σ h_σ_mem)

/-- Future seriality swaps to past seriality: `⊤ → F⊤` becomes `⊤ → P⊤`, witnessed by
`exists_lt`. -/
theorem serial_future_swap_valid :
    ValidIn FrameClass.Base
      ((Formula.bot.imp Formula.bot).imp
        (Formula.someFuture (Formula.bot.imp Formula.bot))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_some_future, Formula.swapTemporal]
  simp only [TruthAt, Truth.some_past_iff]
  intro _
  obtain ⟨s, hst⟩ := exists_lt t
  exact ⟨s, hst, fun h => h⟩

/-- Past seriality swaps to future seriality: `⊤ → P⊤` becomes `⊤ → F⊤`, witnessed by
`exists_gt`. -/
theorem serial_past_swap_valid :
    ValidIn FrameClass.Base
      ((Formula.bot.imp Formula.bot).imp
        (Formula.somePast (Formula.bot.imp Formula.bot))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_some_past, Formula.swapTemporal]
  simp only [TruthAt, Truth.some_future_iff]
  intro _
  obtain ⟨s, hts⟩ := exists_gt t
  exact ⟨s, hts, fun h => h⟩

/-- Left monotonicity of Until under `G` swaps to left monotonicity of Since under `H`:
`H(φ' → χ') → (φ' S ψ') → (χ' S ψ')`. -/
theorem left_mono_until_G_swap_valid (φ χ ψ : Formula) :
    ValidIn FrameClass.Base
      ((φ.imp χ).allFuture.imp ((Formula.untl φ ψ).imp (Formula.untl χ ψ))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
  simp only [TruthAt, Truth.past_iff]
  intro h_H ⟨s, hst, h_ψs, h_guard⟩
  exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩

/-- Left monotonicity of Since under `H` swaps to left monotonicity of Until under `G`:
`G(φ' → χ') → (φ' U ψ') → (χ' U ψ')`. -/
theorem left_mono_since_H_swap_valid (φ χ ψ : Formula) :
    ValidIn FrameClass.Base
      ((φ.imp χ).allPast.imp ((Formula.snce φ ψ).imp (Formula.snce χ ψ))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_all_past, Formula.swapTemporal]
  simp only [TruthAt, Truth.future_iff]
  intro h_G ⟨s, hts, h_ψs, h_guard⟩
  exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩

/-- Right monotonicity of Until swaps to right monotonicity of Since:
`H(φ' → ψ') → (χ' S φ') → (χ' S ψ')`. -/
theorem right_mono_until_swap_valid (φ ψ χ : Formula) :
    ValidIn FrameClass.Base
      ((φ.imp ψ).allFuture.imp ((Formula.untl χ φ).imp (Formula.untl χ ψ))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_all_future, Formula.swapTemporal]
  simp only [TruthAt, Truth.past_iff]
  intro h_H ⟨s, hst, h_φs, h_guard⟩
  exact ⟨s, hst, h_H s hst h_φs, h_guard⟩

/-- Right monotonicity of Since swaps to right monotonicity of Until:
`G(φ' → ψ') → (χ' U φ') → (χ' U ψ')`. -/
theorem right_mono_since_swap_valid (φ ψ χ : Formula) :
    ValidIn FrameClass.Base
      ((φ.imp ψ).allPast.imp ((Formula.snce χ φ).imp (Formula.snce χ ψ))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_all_past, Formula.swapTemporal]
  simp only [TruthAt, Truth.future_iff]
  intro h_G ⟨s, hts, h_φs, h_guard⟩
  exact ⟨s, hts, h_G s hts h_φs, h_guard⟩

/-- The future connection axiom `φ → G(Pφ)` swaps to `φ' → H(Fφ')`: at any past `s < t`, the
present `t` is itself the required future witness. -/
theorem connect_future_swap_valid (φ : Formula) :
    ValidIn FrameClass.Base (φ.imp (φ.somePast.allFuture)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_some_past, Formula.swap_temporal_all_future,
    Formula.swapTemporal]
  simp only [TruthAt, Truth.past_iff, Truth.some_future_iff]
  intro h_φt s hst
  exact ⟨t, hst, h_φt⟩

/-- The past connection axiom `φ → H(Fφ)` swaps to `φ' → G(Pφ')`, mirror of
`connect_future_swap_valid`. -/
theorem connect_past_swap_valid (φ : Formula) :
    ValidIn FrameClass.Base (φ.imp (φ.someFuture.allPast)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_some_future, Formula.swap_temporal_all_past,
    Formula.swapTemporal]
  simp only [TruthAt, Truth.future_iff, Truth.some_past_iff]
  intro h_φt s hts
  exact ⟨t, hts, h_φt⟩

/-- Until enrichment swaps to Since enrichment: `p' ∧ (φ' S ψ') → φ' S (ψ' ∧ (φ' U p'))`. The
Since-witness `s < t` also witnesses the inner Until, with `t` itself carrying `p'`. -/
theorem enrichment_until_swap_valid (φ ψ p : Formula) :
    ValidIn FrameClass.Base (Formula.and p (Formula.untl φ ψ) |>.imp
        (Formula.untl φ (Formula.and ψ (Formula.snce φ p)))).swapTemporal := by
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

/-- Since enrichment swaps to Until enrichment, mirror of `enrichment_until_swap_valid`. -/
theorem enrichment_since_swap_valid (φ ψ p : Formula) :
    ValidIn FrameClass.Base (Formula.and p (Formula.snce φ ψ) |>.imp
        (Formula.snce φ (Formula.and ψ (Formula.untl φ p)))).swapTemporal := by
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

/-- Until self-accumulation swaps to Since self-accumulation:
`(φ' S ψ') → ((φ' ∧ (φ' S ψ')) S ψ')`. The original witness is reused, and each guard point
inherits the Since from the same witness. -/
theorem self_accum_until_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base ((Formula.untl φ ψ).imp
        (Formula.untl (Formula.and φ (Formula.untl φ ψ)) ψ)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
  intro ⟨s, hst, h_ψs, h_guard⟩
  refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
  exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr =>
      h_guard q hsq (lt_trans hqr hrt)⟩

/-- Since self-accumulation swaps to Until self-accumulation, mirror of
`self_accum_until_swap_valid`. -/
theorem self_accum_since_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base ((Formula.snce φ ψ).imp
        (Formula.snce (Formula.and φ (Formula.snce φ ψ)) ψ)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swapTemporal, Formula.and, Formula.neg, TruthAt]
  intro ⟨s, hts, h_ψs, h_guard⟩
  refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
  exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs =>
      h_guard q (lt_trans htr hrq) hqs⟩

/-- Until absorption swaps to Since absorption:
`(φ' S (φ' ∧ (φ' S ψ'))) → (φ' S ψ')`. The inner witness `s₂` serves as the outer one, and the
guard obligation splits by trichotomy at the intermediate point `s₁`. -/
theorem absorb_until_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base
      ((Formula.untl φ (Formula.and φ (Formula.untl φ ψ))).imp
        (Formula.untl φ ψ)).swapTemporal := by
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

/-- Since absorption swaps to Until absorption, mirror of `absorb_until_swap_valid`. -/
theorem absorb_since_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base
      ((Formula.snce φ (Formula.and φ (Formula.snce φ ψ))).imp
        (Formula.snce φ ψ)).swapTemporal := by
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

/-- Until linearity swaps to Since linearity. Two Since-witnesses `s₁` and `s₂` below `t` are
ordered by `lt_trichotomy`, and each of the three cases selects the matching disjunct. -/
theorem linear_until_swap_valid (φ ψ χ θ : Formula) :
    ValidIn FrameClass.Base (Formula.and (Formula.untl φ ψ) (Formula.untl χ θ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.untl (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.untl (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.untl (Formula.and φ χ) (Formula.and φ θ)))).swapTemporal := by
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

/-- Since linearity swaps to Until linearity, mirror of `linear_until_swap_valid`. -/
theorem linear_since_swap_valid (φ ψ χ θ : Formula) :
    ValidIn FrameClass.Base (Formula.and (Formula.snce φ ψ) (Formula.snce χ θ)
        |>.imp (Formula.or
          (Formula.or
            (Formula.snce (Formula.and φ χ) (Formula.and ψ θ))
            (Formula.snce (Formula.and φ χ) (Formula.and ψ χ)))
          (Formula.snce (Formula.and φ χ) (Formula.and φ θ)))).swapTemporal := by
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

/-- `(φ U ψ) → Fψ` swaps to `(φ' S ψ') → Pψ'`: the Since-witness is the past witness, and the
guard is discarded. -/
theorem until_F_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base ((Formula.untl φ ψ).imp (Formula.someFuture ψ)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_some_future, Formula.swapTemporal]
  simp only [TruthAt, Truth.some_past_iff]
  intro ⟨s, hst, h_ψs, _h_guard⟩
  exact ⟨s, hst, h_ψs⟩

/-- `(φ S ψ) → Pψ` swaps to `(φ' U ψ') → Fψ'`, mirror of `until_F_swap_valid`. -/
theorem since_P_swap_valid (φ ψ : Formula) :
    ValidIn FrameClass.Base ((Formula.snce φ ψ).imp (Formula.somePast ψ)).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swap_temporal_some_past, Formula.swapTemporal]
  simp only [TruthAt, Truth.some_future_iff]
  intro ⟨s, hts, h_ψs, _h_guard⟩
  exact ⟨s, hts, h_ψs⟩

/-- Forward discreteness symmetry swaps to the backward direction. From a predecessor gap `r < t`
the reflected point `t + (t - r)` is a successor gap, since a point strictly inside the
reflected interval maps back into `(r, t)`. -/
theorem discrete_symm_fwd_swap_valid :
    ValidIn FrameClass.Base ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.snce Formula.bot (Formula.bot.imp Formula.bot))).swapTemporal := by
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

/-- Backward discreteness symmetry swaps to the forward direction, mirror of
`discrete_symm_fwd_swap_valid`. -/
theorem discrete_symm_bwd_swap_valid :
    ValidIn FrameClass.Base ((Formula.snce Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.untl Formula.bot (Formula.bot.imp Formula.bot))).swapTemporal := by
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

/-- Forward gap propagation swaps to past propagation: a gap of width `t - r` at `t` translates to
a gap of the same width at every `u`, by shifting the witness. -/
theorem discrete_propagate_fwd_swap_valid :
    ValidIn FrameClass.Base ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allFuture
        (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))).swapTemporal := by
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

/-- Backward gap propagation swaps to future propagation, mirror of
`discrete_propagate_fwd_swap_valid`. -/
theorem discrete_propagate_bwd_swap_valid :
    ValidIn FrameClass.Base ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.allPast (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))).swapTemporal := by
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

/-- Gap necessity swaps to itself with `U` exchanged for `S`: the gap witness is a fact about the
duration order, so it transfers unchanged to every total history. -/
theorem discrete_box_necessity_swap_valid :
    ValidIn FrameClass.Base ((Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).imp
      (Formula.box (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)))).swapTemporal := by
  refine ValidIn.of_forall_total ?_
  intro F _ M τ _hτ t
  simp only [Formula.swapTemporal, TruthAt]
  intro ⟨r, hrt, _h_top_r, h_guard⟩ σ _h_σ_mem
  exact ⟨r, hrt, fun h => h, h_guard⟩

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
  | prop_k ψ χ ρ => exact prop_k_swap_valid ψ χ ρ
  | prop_s ψ χ => exact prop_s_swap_valid ψ χ
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ => exact modal_5_collapse_swap_valid ψ
  | ex_falso ψ => exact ex_falso_swap_valid ψ
  | peirce ψ χ => exact peirce_swap_valid ψ χ
  | modal_k_dist ψ χ => exact modal_k_dist_swap_valid ψ χ
  | serial_future => exact serial_future_swap_valid
  | serial_past => exact serial_past_swap_valid
  | left_mono_until_G φ χ ψ => exact left_mono_until_G_swap_valid φ χ ψ
  | left_mono_since_H φ χ ψ => exact left_mono_since_H_swap_valid φ χ ψ
  | right_mono_until φ ψ χ => exact right_mono_until_swap_valid φ ψ χ
  | right_mono_since φ ψ χ => exact right_mono_since_swap_valid φ ψ χ
  | connect_future φ => exact connect_future_swap_valid φ
  | connect_past φ => exact connect_past_swap_valid φ
  | enrichment_until φ ψ p => exact enrichment_until_swap_valid φ ψ p
  | enrichment_since φ ψ p => exact enrichment_since_swap_valid φ ψ p
  | self_accum_until φ ψ => exact self_accum_until_swap_valid φ ψ
  | self_accum_since φ ψ => exact self_accum_since_swap_valid φ ψ
  | absorb_until φ ψ => exact absorb_until_swap_valid φ ψ
  | absorb_since φ ψ => exact absorb_since_swap_valid φ ψ
  | linear_until φ ψ χ θ => exact linear_until_swap_valid φ ψ χ θ
  | linear_since φ ψ χ θ => exact linear_since_swap_valid φ ψ χ θ
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted in the
  -- open-guard refactor)
  | until_F φ ψ => exact until_F_swap_valid φ ψ
  | since_P φ ψ => exact since_P_swap_valid φ ψ
  | temp_linearity φ ψ => exact axiom_temp_linearity_past_valid φ.swapTemporal ψ.swapTemporal
  | temp_linearity_past φ ψ => exact axiom_temp_linearity_valid φ.swapTemporal ψ.swapTemporal
  | F_until_equiv φ => exact axiom_P_since_equiv_valid φ.swapTemporal
  | P_since_equiv φ => exact axiom_F_until_equiv_valid φ.swapTemporal
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted in the
  -- open-guard refactor)
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | discrete_symm_fwd => exact discrete_symm_fwd_swap_valid
  | discrete_symm_bwd => exact discrete_symm_bwd_swap_valid
  | discrete_propagate_fwd => exact discrete_propagate_fwd_swap_valid
  | discrete_propagate_bwd => exact discrete_propagate_bwd_swap_valid
  | discrete_box_necessity => exact discrete_box_necessity_swap_valid
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
theorem prior_UZ_is_valid (φ : Formula) :
    ValidDiscrete (φ.someFuture.imp (Formula.untl φ.neg φ)) := by
  refine ValidDiscrete.of_forall ?_
  intro F _ _ _ _ M τ _hτ t
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
theorem prior_SZ_is_valid (φ : Formula) :
    ValidDiscrete (φ.somePast.imp (Formula.snce φ.neg φ)) := by
  refine ValidDiscrete.of_forall ?_
  intro F _ _ _ _ M τ _hτ t
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
theorem z1_is_valid (φ : Formula) :
    ValidDiscrete ((φ.allFuture.imp φ).allFuture.imp
      (φ.allFuture.someFuture.imp φ.allFuture)) := by
  refine ValidDiscrete.of_forall ?_
  intro F _ _ _ _ M τ _hτ t
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
theorem z1_past_is_valid (φ : Formula) :
    ValidDiscrete ((φ.allPast.imp φ).allPast.imp
      (φ.allPast.somePast.imp φ.allPast)) := by
  refine ValidDiscrete.of_forall ?_
  intro F _ _ _ _ M τ _hτ t
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
