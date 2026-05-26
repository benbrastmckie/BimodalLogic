import Bimodal.Metalogic.SoundnessLemmas.DenseValidity

/-!
# Soundness Lemmas for General and Discrete Frame Classes

General (Base) frame class and discrete frame class validity variants. Proves swap
validity and local validity for base axioms without density constraints, and for
discrete-specific axioms.
-/

namespace Bimodal.Metalogic.SoundnessLemmas

open Bimodal.Syntax
open Bimodal.ProofSystem (Axiom DerivationTree FrameClass)
open Bimodal.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-! ## General (Frame-Class-Free) Versions

All base axioms (those with `minFrameClass = .Base`) are valid on any linear order,
without requiring `[DenselyOrdered D]` or `[Nontrivial D]`. These general versions
remove frame constraints from the swap/locally-valid lemmas, enabling soundness proofs
for the base frame class without unnecessary hypotheses.

This resolves the 3 `temporal_duality` sorries in Soundness.lean:
- `soundness` (general, line ~877)
- `soundness_discrete_valid` (line ~1094)
- `soundness_discrete` (line ~1151)
-/

/-- All base axiom swaps are valid without DenselyOrdered constraints.
Base axioms (minFrameClass = .Base) don't need density or discreteness. -/
theorem axiom_swap_valid_general (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Base)
    [Nontrivial D] : is_valid D φ.swap_temporal := by
  cases h with
  | prop_k ψ χ ρ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_a _
    exact h_a
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.diamond, Formula.neg]
    simp only [truth_at]
    intro h_diamond_box σ h_σ_mem
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ h_ρ_mem h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ h_σ_mem
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_peirce
    by_cases h : truth_at M Omega τ t ψ.swap_temporal
    · exact h
    · have h_imp : truth_at M Omega τ t (ψ.swap_temporal.imp χ.swap_temporal) := by
        unfold truth_at
        intro h_psi
        exfalso
        exact h h_psi
      exact h_peirce h_imp
  | modal_k_dist ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro h_box_imp h_box_psi σ h_σ_mem
    exact h_box_imp σ h_σ_mem (h_box_psi σ h_σ_mem)
  | serial_future =>
    -- swap of serial_future (⊤ → F⊤) is (⊤ → P⊤), need exists_lt
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | serial_past =>
    -- swap of serial_past (⊤ → P⊤) is (⊤ → F⊤), need exists_gt
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Swap of left_mono_until_G: H(φ'→χ') → snce(φ',ψ') → snce(χ',ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | left_mono_since_H φ χ ψ =>
    -- Swap of left_mono_since_H: G(φ'→χ') → untl(φ',ψ') → untl(χ',ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | right_mono_until φ ψ χ =>
    -- swap: H(φ'→χ') → (φ' S ψ') → (χ' S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    -- swap: G(φ'→χ') → (φ' U ψ') → (χ' U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | connect_future φ =>
    -- connect_future: φ → G(P(φ)), swap: swap(φ) → H(F(swap(φ)))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal_all_future,
      Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | connect_past φ =>
    -- connect_past: φ → H(F(φ)), swap: swap(φ) → G(P(swap(φ)))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal_all_past,
      Formula.swap_temporal, Formula.neg]
    simp only [truth_at, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Swap of enrichment_until: p ∧ snce(φ', ψ') → snce(φ', ψ' ∧ untl(φ', p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p.swap_temporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_since : ∃ s, s < t ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ.swap_temporal := by
      by_contra h_neg; exact h_conj (fun _ h_s => h_neg h_s)
    obtain ⟨s, hst, h_ψs, h_guard⟩ := h_since
    refine ⟨s, hst, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hst, h_pt, fun r hsr hrt => h_guard r hsr hrt⟩
  | enrichment_since φ ψ p =>
    -- Swap of enrichment_since: p ∧ untl(φ', ψ') → untl(φ', ψ' ∧ snce(φ', p))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro h_conj
    have h_pt : truth_at M Omega τ t p.swap_temporal := by
      by_contra h_neg; exact h_conj (fun h_p _ => h_neg h_p)
    have h_until : ∃ s, t < s ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ.swap_temporal := by
      by_contra h_neg; exact h_conj (fun _ h_u => h_neg h_u)
    obtain ⟨s, hts, h_ψs, h_guard⟩ := h_until
    refine ⟨s, hts, ?_, h_guard⟩
    intro h_imp
    exact h_imp h_ψs ⟨t, hts, h_pt, fun r htr hrs => h_guard r htr hrs⟩
  | self_accum_until φ ψ =>
    -- Swap: (φ' S ψ') → ((φ' ∧ (φ' S ψ')) S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩
  | self_accum_since φ ψ =>
    -- Swap: (φ' U ψ') → ((φ' ∧ (φ' U ψ')) U ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs => h_guard q (lt_trans htr hrq) hqs⟩
  | absorb_until φ ψ =>
    -- Swap: (φ' S (φ' ∧ (φ' S ψ'))) → (φ' S ψ')
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hs₁t, h_conj, h_guard₁⟩
    have h_φs₁_and_since : truth_at M Omega τ s₁ φ.swap_temporal ∧
        (∃ s₂, s₂ < s₁ ∧ truth_at M Omega τ s₂ ψ.swap_temporal ∧
          ∀ q, s₂ < q → q < s₁ → truth_at M Omega τ q φ.swap_temporal) := by
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
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
    have h_φs₁_and_until : truth_at M Omega τ s₁ φ.swap_temporal ∧
        (∃ s₂, s₁ < s₂ ∧ truth_at M Omega τ s₂ ψ.swap_temporal ∧
          ∀ q, s₁ < q → q < s₂ → truth_at M Omega τ q φ.swap_temporal) := by
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
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, s < t ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r φ.swap_temporal) ∧
      (∃ s, s < t ∧ truth_at M Omega τ s θ.swap_temporal ∧
        ∀ r, s < r → r < t → truth_at M Omega τ r χ.swap_temporal) := by
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
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, t < s ∧ truth_at M Omega τ s ψ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ.swap_temporal) ∧
      (∃ s, t < s ∧ truth_at M Omega τ s θ.swap_temporal ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r χ.swap_temporal) := by
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
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted, task 113)
  | until_F φ ψ =>
    -- swap of ((φ U ψ) → F(ψ)) is ((φ' S ψ') → P(ψ'))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_future, Formula.swap_temporal]
    simp only [truth_at, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _h_guard⟩
    exact ⟨s, hst, h_ψs⟩
  | since_P φ ψ =>
    -- swap of ((φ S ψ) → P(ψ)) is ((φ' U ψ') → F(ψ'))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_some_past, Formula.swap_temporal]
    simp only [truth_at, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _h_guard⟩
    exact ⟨s, hts, h_ψs⟩
  | temp_linearity φ ψ =>
    exact axiom_temp_linearity_past_valid φ.swap_temporal ψ.swap_temporal
  | temp_linearity_past φ ψ =>
    exact axiom_temp_linearity_valid φ.swap_temporal ψ.swap_temporal
  | F_until_equiv φ =>
    exact axiom_P_since_equiv_valid φ.swap_temporal
  | P_since_equiv φ =>
    exact axiom_F_until_equiv_valid φ.swap_temporal
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted, task 113)
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | discrete_symm_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
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
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
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
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_future, Formula.swap_temporal]
    simp only [truth_at, Truth.past_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _hut
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs => rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_propagate_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal_all_past, Formula.swap_temporal]
    simp only [truth_at, Truth.future_iff]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ u _htu
    refine ⟨u - (t - r), sub_lt_self u (sub_pos.mpr hrt), fun h => h, fun c hrc hcu => ?_⟩
    have h1 : r < c + (t - u) := by
      conv_lhs => rw [show r = u - (t - r) + (t - u) from by rw [sub_add_sub_cancel', sub_sub_cancel]]
      exact add_lt_add_left hrc (t - u)
    have h2 : c + (t - u) < t := by
      conv_rhs => rw [show t = u + (t - u) from by rw [add_comm, sub_add_cancel]]
      exact add_lt_add_left hcu (t - u)
    exact h_guard (c + (t - u)) h1 h2
  | discrete_box_necessity =>
    -- swap(U(T,bot) -> □(U(T,bot))) = S(T,bot) -> □(S(T,bot))
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.swap_temporal, truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩ σ _h_σ_mem
    exact ⟨r, hrt, fun h => h, h_guard⟩
  | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-- All base axioms are locally valid without DenselyOrdered frame constraints. -/
private theorem axiom_locally_valid_general [Nontrivial D] {φ : Formula} (h : Axiom φ)
    (h_fc : h.minFrameClass ≤ FrameClass.Base) : is_valid D φ := by
  cases h with
  | prop_k φ ψ χ => exact axiom_prop_k_valid φ ψ χ
  | prop_s φ ψ => exact axiom_prop_s_valid φ ψ
  | modal_t ψ => exact axiom_modal_t_valid ψ
  | modal_4 ψ => exact axiom_modal_4_valid ψ
  | modal_b ψ => exact axiom_modal_b_valid ψ
  | modal_5_collapse ψ => exact axiom_modal_5_collapse_valid ψ
  | ex_falso ψ => exact axiom_ex_falso_valid ψ
  | peirce φ ψ => exact axiom_peirce_valid φ ψ
  | modal_k_dist φ ψ => exact axiom_modal_k_dist_valid φ ψ
  | serial_future =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.neg, truth_at, Truth.some_future_iff]
    intro _
    obtain ⟨s, hts⟩ := exists_gt t
    exact ⟨s, hts, fun h => h⟩
  | serial_past =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.neg, truth_at, Truth.some_past_iff]
    intro _
    obtain ⟨s, hst⟩ := exists_lt t
    exact ⟨s, hst, fun h => h⟩
  | left_mono_until_G φ χ ψ =>
    -- Direct: G(φ→χ) → untl(φ,ψ) → untl(χ,ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_ψs, h_guard⟩
    exact ⟨s, hts, h_ψs, fun r htr hrs => h_G r htr (h_guard r htr hrs)⟩
  | left_mono_since_H φ χ ψ =>
    -- Direct: H(φ→χ) → snce(φ,ψ) → snce(χ,ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_ψs, h_guard⟩
    exact ⟨s, hst, h_ψs, fun r hsr hrt => h_H r hrt (h_guard r hsr hrt)⟩
  | right_mono_until φ ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro h_G ⟨s, hts, h_φs, h_guard⟩
    exact ⟨s, hts, h_G s hts h_φs, h_guard⟩
  | right_mono_since φ ψ χ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro h_H ⟨s, hst, h_φs, h_guard⟩
    exact ⟨s, hst, h_H s hst h_φs, h_guard⟩
  | connect_future φ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff, Truth.some_past_iff]
    intro h_φt s hts
    exact ⟨t, hts, h_φt⟩
  | connect_past φ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff, Truth.some_future_iff]
    intro h_φt s hst
    exact ⟨t, hst, h_φt⟩
  | enrichment_until φ ψ p =>
    -- Direct: p ∧ untl(φ, ψ) → untl(φ, ψ ∧ snce(φ, p))
    intro F M Omega _h_sc τ _h_mem t
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
  | enrichment_since φ ψ p =>
    -- Direct: p ∧ snce(φ, ψ) → snce(φ, ψ ∧ untl(φ, p))
    intro F M Omega _h_sc τ _h_mem t
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
  | self_accum_until φ ψ =>
    -- Direct: (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s, hts, h_ψs, h_guard⟩
    refine ⟨s, hts, h_ψs, fun r htr hrs h_imp => ?_⟩
    exact h_imp (h_guard r htr hrs) ⟨s, hrs, h_ψs, fun q hrq hqs => h_guard q (lt_trans htr hrq) hqs⟩
  | self_accum_since φ ψ =>
    -- Direct: (φ S ψ) → ((φ ∧ (φ S ψ)) S ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s, hst, h_ψs, h_guard⟩
    refine ⟨s, hst, h_ψs, fun r hsr hrt h_imp => ?_⟩
    exact h_imp (h_guard r hsr hrt) ⟨s, hsr, h_ψs, fun q hsq hqr => h_guard q hsq (lt_trans hqr hrt)⟩
  | absorb_until φ ψ =>
    -- Direct: (φ U (φ ∧ (φ U ψ))) → (φ U ψ)
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.neg, truth_at]
    intro ⟨s₁, hts₁, h_conj, h_guard₁⟩
    have h_φs₁_and_until : truth_at M Omega τ s₁ φ ∧
        (∃ s₂, s₁ < s₂ ∧ truth_at M Omega τ s₂ ψ ∧
          ∀ q, s₁ < q → q < s₂ → truth_at M Omega τ q φ) := by
      constructor
      · by_contra h_neg; exact h_conj (fun h_φ _ => h_neg h_φ)
      · by_contra h_neg; exact h_conj (fun _ h_until => h_neg h_until)
    obtain ⟨h_φs₁, s₂, hs₁s₂, h_ψs₂, h_guard₂⟩ := h_φs₁_and_until
    refine ⟨s₂, lt_trans hts₁ hs₁s₂, h_ψs₂, fun q htq hqs₂ => ?_⟩
    rcases lt_trichotomy q s₁ with h_lt | h_eq | h_gt
    · exact h_guard₁ q htq h_lt
    · exact h_eq ▸ h_φs₁
    · exact h_guard₂ q h_gt hqs₂
  | absorb_since φ ψ =>
    -- Direct: (φ S (φ ∧ (φ S ψ))) → (φ S ψ)
    intro F M Omega _h_sc τ _h_mem t
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
  | linear_until φ ψ χ θ =>
    -- Direct: Until-based linearity
    intro F M Omega _h_sc τ _h_mem t
    simp only [Formula.and, Formula.or, Formula.neg, truth_at]
    intro h_conj
    have h_both : (∃ s, t < s ∧ truth_at M Omega τ s ψ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r φ) ∧
      (∃ s, t < s ∧ truth_at M Omega τ s θ ∧
        ∀ r, t < r → r < s → truth_at M Omega τ r χ) := by
      constructor
      · by_contra h; exact h_conj (fun h1 _ => h h1)
      · by_contra h; exact h_conj (fun _ h2 => h h2)
    obtain ⟨⟨s₁, hts₁, h_ψs₁, h_guard₁⟩, s₂, hts₂, h_θs₂, h_guard₂⟩ := h_both
    rcases lt_trichotomy s₁ s₂ with h_lt | h_eq | h_gt
    · -- s₁ < s₂: second disjunct with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ hts₁ h_lt)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (lt_trans hrs h_lt))
    · -- s₁ = s₂: first disjunct with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hts₁, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r htr hrs) (h_guard₂ r htr (h_eq ▸ hrs))
    · -- s₂ < s₁: third disjunct with witness s₂
      intro _
      refine ⟨s₂, hts₂, ?_, fun r htr hrs h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ hts₂ h_gt) h_θs₂
      · exact h_imp (h_guard₁ r htr (lt_trans hrs h_gt)) (h_guard₂ r htr hrs)
  | linear_since φ ψ χ θ =>
    -- Direct: Since-based linearity
    intro F M Omega _h_sc τ _h_mem t
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
    · -- s₁ < s₂: third disjunct with witness s₂
      intro _
      refine ⟨s₂, hs₂t, ?_, fun r hs₂r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg (h_guard₁ s₂ h_lt hs₂t) h_θs₂
      · exact h_imp (h_guard₁ r (lt_trans h_lt hs₂r) hrt) (h_guard₂ r hs₂r hrt)
    · -- s₁ = s₂: first disjunct with witness s₁
      intro h_outer; exfalso; apply h_outer; intro h_inner; exfalso; apply h_inner
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_eq ▸ h_θs₂)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (h_eq ▸ hs₁r) hrt)
    · -- s₁ > s₂: second disjunct with witness s₁
      intro h_neg; exfalso; apply h_neg; intro _
      refine ⟨s₁, hs₁t, ?_, fun r hs₁r hrt h_imp => ?_⟩
      · intro h_neg; exact h_neg h_ψs₁ (h_guard₂ s₁ h_gt hs₁t)
      · exact h_imp (h_guard₁ r hs₁r hrt) (h_guard₂ r (lt_trans h_gt hs₁r) hrt)
  -- NOTE: linear_until_a7a / linear_since_a7a removed (unsound under open guard)
  -- NOTE: until_elim / since_elim match arms removed (constructors deleted, task 113)
  | until_F φ ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.some_future_iff]
    intro ⟨s, hts, h_ψs, _⟩
    exact ⟨s, hts, h_ψs⟩
  | since_P φ ψ =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.some_past_iff]
    intro ⟨s, hst, h_ψs, _⟩
    exact ⟨s, hst, h_ψs⟩
  | temp_linearity φ ψ => exact axiom_temp_linearity_valid φ ψ
  | temp_linearity_past φ ψ => exact axiom_temp_linearity_past_valid φ ψ
  | F_until_equiv φ => exact axiom_F_until_equiv_valid φ
  | P_since_equiv φ => exact axiom_P_since_equiv_valid φ
  -- NOTE: until_guard / since_guard match arms removed (constructors deleted, task 113)
  | modal_future ψ => exact axiom_modal_future_valid ψ

  | discrete_symm_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩
    refine ⟨t - (s - t), sub_lt_self t (sub_pos.mpr hts), fun h => h, fun c hrc hct => ?_⟩
    have h1 : t < c + (s - t) :=
      calc t = t - (s - t) + (s - t) := (sub_add_cancel t (s - t)).symm
        _ < c + (s - t) := add_lt_add_left hrc (s - t)
    have h2 : c + (s - t) < s :=
      calc c + (s - t) < t + (s - t) := add_lt_add_left hct (s - t)
        _ = s := by rw [add_comm, sub_add_cancel]
    exact h_guard (c + (s - t)) h1 h2
  | discrete_symm_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨r, hrt, _h_top_r, h_guard⟩
    refine ⟨t + (t - r), lt_add_of_pos_right t (sub_pos.mpr hrt), fun h => h, fun c htc hcs => ?_⟩
    have h1 : r < c - (t - r) := by
      conv_lhs => rw [(sub_sub_cancel t r).symm]
      exact sub_lt_sub_right htc _
    have h2 : c - (t - r) < t := by
      conv_rhs => rw [(add_sub_cancel_right t (t - r)).symm]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (t - r)) h1 h2
  | discrete_propagate_fwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.future_iff]
    intro ⟨s, hts, _h_top_s, h_guard⟩ u _htu
    refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
    have h1 : t < c - (u - t) := by
      conv_lhs => rw [(sub_sub_cancel u t).symm]
      exact sub_lt_sub_right huc _
    have h2 : c - (u - t) < s := by
      conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (u - t)) h1 h2
  | discrete_propagate_bwd =>
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at, Truth.past_iff]
    intro ⟨s, hts, _h_top_s, h_guard⟩ u _hut
    refine ⟨u + (s - t), lt_add_of_pos_right u (sub_pos.mpr hts), fun h => h, fun c huc hcs => ?_⟩
    have h1 : t < c - (u - t) := by
      conv_lhs => rw [(sub_sub_cancel u t).symm]
      exact sub_lt_sub_right huc _
    have h2 : c - (u - t) < s := by
      conv_rhs => rw [show s = u + (s - t) - (u - t) from by rw [add_sub_sub_cancel, sub_add_cancel]]
      exact sub_lt_sub_right hcs _
    exact h_guard (c - (u - t)) h1 h2
  | discrete_box_necessity =>
    -- U(T,bot) -> □(U(T,bot)): discreteness depends only on D, not the history
    intro F M Omega _h_sc τ _h_mem t
    simp only [truth_at]
    intro ⟨s, hts, _h_top_s, h_guard⟩ σ _h_σ_mem
    exact ⟨s, hts, fun h => h, h_guard⟩
  | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_UZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | prior_SZ _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
  | z1 _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])

/-- Combined soundness for base derivations without frame-class constraints:
derivability implies both validity and swap-validity. Identical to
`derivable_valid_and_swap_valid` but without `[DenselyOrdered D] [Nontrivial D]`.

This is possible because the BX axiom system has no density or discreteness extension
axioms, so the proofs never actually use those constraints. -/
theorem derivable_valid_and_swap_valid_general [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Base [] φ) :
    is_valid D φ ∧ is_valid D φ.swap_temporal := by
  match d with
  | .axiom _ _ h_ax h_fc =>
    exact ⟨axiom_locally_valid_general h_ax h_fc, axiom_swap_valid_general _ h_ax h_fc⟩
  | .assumption _ _ h_mem => exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ ψ' _ d1 d2 =>
    obtain ⟨h1_valid, h1_swap⟩ := derivable_valid_and_swap_valid_general d1
    obtain ⟨h2_valid, h2_swap⟩ := derivable_valid_and_swap_valid_general d2
    exact ⟨mp_preserves_valid h1_valid h2_valid, mp_preserves_swap_valid ψ' _ h1_swap h2_swap⟩
  | .necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_general d'
    exact ⟨necessitation_preserves_local_valid h_valid, modal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_general d'
    exact ⟨temporal_necessitation_preserves_local_valid h_valid, temporal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_duality ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_general d'
    constructor
    · exact h_swap
    · simp only [Formula.swap_temporal_involution]; exact h_valid
  | .weakening Γ' _ _ d' h_sub =>
    have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Γ' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_valid_general (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/-- Derivability implies swap validity for dense-compatible derivations.
This is the theorem needed for the temporal_duality case in dense soundness. -/
theorem derivable_implies_swap_valid_general [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Base [] φ) :
    is_valid D φ.swap_temporal :=
  (derivable_valid_and_swap_valid_general d).2

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
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D (φ.some_future.imp (Formula.untl φ φ.neg)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.some_future_iff]
  intro ⟨s, hts, hs⟩
  obtain ⟨n, hn⟩ := (Order.succ_le_of_lt hts).exists_succ_iterate
  have hn1 : Order.succ^[n + 1] t = s := by
    simp; exact hn
  classical
  have h_ex : ∃ k, truth_at M Omega τ (Order.succ^[k + 1] t) φ := ⟨n, hn1 ▸ hs⟩
  let k₀ := Nat.find h_ex
  have hk₀ : truth_at M Omega τ (Order.succ^[k₀ + 1] t) φ := Nat.find_spec h_ex
  have hk₀_min : ∀ m < k₀, ¬truth_at M Omega τ (Order.succ^[m + 1] t) φ :=
    fun m hm => Nat.find_min h_ex hm
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts.not_isMax
  refine ⟨Order.succ^[k₀ + 1] t, ?_, hk₀, ?_⟩
  · -- t < succ^[k₀+1] t: from t < succ t ≤ succ^[k₀+1] t
    have h1 := h_iter_mono (Nat.one_le_iff_ne_zero.mpr (Nat.succ_ne_zero k₀))
    simp only at h1
    exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max) h1
  · -- ∀ r, t < r → r < succ^[k₀+1] t → ¬ truth_at r φ
    intro r htr hrs
    obtain ⟨j, hj⟩ := (Order.succ_le_of_lt htr).exists_succ_iterate
    have hj1 : Order.succ^[j + 1] t = r := by
      simp; exact hj
    have hj_lt : j < k₀ := by
      by_contra h_ge
      push_neg at h_ge
      have h_le := h_iter_mono (show k₀ + 1 ≤ j + 1 by omega)
      simp only at h_le
      rw [hj1] at h_le
      exact absurd hrs (not_lt.mpr h_le)
    rw [← hj1]
    exact hk₀_min j hj_lt

/-- Prior-SZ is valid on discrete orders: P(φ) → S(φ, ¬φ).
Mirror of prior_UZ_is_valid using pred chain and IsPredArchimedean. -/
theorem prior_SZ_is_valid
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D (φ.some_past.imp (Formula.snce φ φ.neg)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.some_past_iff]
  intro ⟨s, hst, hs⟩
  obtain ⟨n, hn⟩ := (Order.le_pred_of_lt hst).exists_pred_iterate
  have hn1 : Order.pred^[n + 1] t = s := by
    simp; exact hn
  classical
  have h_ex : ∃ k, truth_at M Omega τ (Order.pred^[k + 1] t) φ := ⟨n, hn1 ▸ hs⟩
  let k₀ := Nat.find h_ex
  have hk₀ : truth_at M Omega τ (Order.pred^[k₀ + 1] t) φ := Nat.find_spec h_ex
  have hk₀_min : ∀ m < k₀, ¬truth_at M Omega τ (Order.pred^[m + 1] t) φ :=
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
      simp; exact hj
    have hj_lt : j < k₀ := by
      by_contra h_ge
      push_neg at h_ge
      have h_le := h_iter_anti (show k₀ + 1 ≤ j + 1 by omega)
      simp only at h_le
      rw [hj1] at h_le
      exact absurd hrs (not_lt.mpr h_le)
    rw [← hj1]
    exact hk₀_min j hj_lt

/-- Z1 is valid on discrete orders: G(Gφ→φ) → (FGφ→Gφ).
Backward induction from the Gφ witness using IsSuccArchimedean. -/
theorem z1_is_valid
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D ((φ.all_future.imp φ).all_future.imp
        (φ.all_future.some_future.imp φ.all_future)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.future_iff, Truth.some_future_iff]
  intro h_GGpIp ⟨s₀, hts₀, hs₀⟩
  obtain ⟨n₀, hn₀⟩ := (Order.succ_le_of_lt hts₀).exists_succ_iterate
  have hn₀_eq : Order.succ^[n₀ + 1] t = s₀ := by
    show Order.succ^[n₀] (Order.succ t) = s₀; exact hn₀
  have h_iter_mono : Monotone (fun i => Order.succ^[i] t) :=
    Order.succ_mono.monotone_iterate_of_le_map (Order.le_succ t)
  have h_not_max : ¬IsMax t := hts₀.not_isMax
  -- Helper: truth_at s φ for any s > t (the main goal, proved assuming backward induction)
  -- We prove: ∀ s > t, truth_at s φ, using backward induction from s₀.
  -- Strategy: for any s > t, obtain n with succ^[n](succ(t)) = s, then dispatch:
  --   n ≤ n₀: backward induction (h_descend below)
  --   n > n₀: either s₀ is max (so s = s₀, use h_GGpIp), or s > s₀ (use hs₀)
  have h_above_s0 : ∀ s, s₀ ≤ s → truth_at M Omega τ s φ := by
    intro s hs
    rcases eq_or_lt_of_le hs with rfl | hlt
    · exact h_GGpIp s₀ hts₀ hs₀
    · exact hs₀ s hlt
  -- Backward induction: truth_at (succ^[k+1](t)) φ for all k, using Nat.strong_induction_on
  -- on the "distance from top" n₀ - k (= 0 when k ≥ n₀).
  have h_all_iterates : ∀ k, truth_at M Omega τ (Order.succ^[k + 1] t) φ := by
    -- Prove ∀ k ≤ n₀ by strong induction on n₀ - k
    suffices h_le : ∀ k, k ≤ n₀ → truth_at M Omega τ (Order.succ^[k + 1] t) φ by
      intro k
      by_cases hk : k ≤ n₀
      · exact h_le k hk
      · exact h_above_s0 _ (hn₀_eq ▸ h_iter_mono (by omega : n₀ + 1 ≤ k + 1))
    -- Strong induction: prove for k assuming it holds for all k' with k < k' ≤ n₀
    have : ∀ d, d ≤ n₀ → ∀ k, n₀ - k = d → k ≤ n₀ →
        truth_at M Omega τ (Order.succ^[k + 1] t) φ := by
      intro d
      induction d using Nat.strong_induction_on with
      | _ d ih =>
        intro hd k hk hkn
        apply h_GGpIp
        · exact lt_of_lt_of_le (Order.lt_succ_of_not_isMax h_not_max)
            (h_iter_mono (by omega : 1 ≤ k + 1))
        · -- Need: ∀ r > succ^[k+1](t), truth_at r φ
          intro r hr
          obtain ⟨j, hj⟩ := (Order.succ_le_of_lt hr).exists_succ_iterate
          have hj_eq : Order.succ^[j + 1] (Order.succ^[k + 1] t) = r := by
            show Order.succ^[j] (Order.succ (Order.succ^[k + 1] t)) = r; exact hj
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
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) : is_valid D ((φ.all_past.imp φ).all_past.imp
        (φ.all_past.some_past.imp φ.all_past)) := by
  intro F M Omega _h_sc τ _h_mem t
  simp only [Formula.neg, truth_at, Truth.past_iff, Truth.some_past_iff]
  intro h_HHpIp ⟨s₀, hs₀t, hs₀⟩
  obtain ⟨n₀, hn₀⟩ := (Order.le_pred_of_lt hs₀t).exists_pred_iterate
  have hn₀_eq : Order.pred^[n₀ + 1] t = s₀ := by
    show Order.pred^[n₀] (Order.pred t) = s₀; exact hn₀
  have h_iter_anti : Antitone (fun i => Order.pred^[i] t) :=
    Order.pred_mono.antitone_iterate_of_map_le (Order.pred_le t)
  have h_not_min : ¬IsMin t := hs₀t.not_isMin
  have h_below_s0 : ∀ u, u ≤ s₀ → truth_at M Omega τ u φ := by
    intro u hu
    rcases eq_or_lt_of_le hu with rfl | hlt
    · exact h_HHpIp _ hs₀t hs₀
    · exact hs₀ u hlt
  have h_all_iterates : ∀ k, truth_at M Omega τ (Order.pred^[k + 1] t) φ := by
    suffices h_le : ∀ k, k ≤ n₀ → truth_at M Omega τ (Order.pred^[k + 1] t) φ by
      intro k
      by_cases hk : k ≤ n₀
      · exact h_le k hk
      · exact h_below_s0 _ (hn₀_eq ▸ h_iter_anti (by omega : n₀ + 1 ≤ k + 1))
    have : ∀ d, d ≤ n₀ → ∀ k, n₀ - k = d → k ≤ n₀ →
        truth_at M Omega τ (Order.pred^[k + 1] t) φ := by
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
            show Order.pred^[j] (Order.pred (Order.pred^[k + 1] t)) = r; exact hj
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

/-- All axiom swaps are valid on discrete orders. For dense-compatible axioms,
delegates to `axiom_swap_valid_general`. For Prior-UZ/SZ, proves directly. -/
private theorem axiom_swap_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    (φ : Formula) (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Discrete) :
    is_valid D φ.swap_temporal := by
  by_cases hbase : h.minFrameClass ≤ FrameClass.Base
  · exact axiom_swap_valid_general _ h hbase
  · cases h with
    | prior_UZ φ =>
      show is_valid D (φ.swap_temporal.some_past.imp (φ.swap_temporal.snce φ.swap_temporal.neg))
      exact prior_SZ_is_valid φ.swap_temporal
    | prior_SZ φ =>
      show is_valid D (φ.swap_temporal.some_future.imp (φ.swap_temporal.untl φ.swap_temporal.neg))
      exact prior_UZ_is_valid φ.swap_temporal
    | z1 φ =>
      show is_valid D ((φ.swap_temporal.all_past.imp φ.swap_temporal).all_past.imp
        (φ.swap_temporal.all_past.some_past.imp φ.swap_temporal.all_past))
      exact z1_past_is_valid φ.swap_temporal
    | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | _ => exact absurd trivial hbase

/-- All discrete-compatible axioms are locally valid on discrete orders. For base axioms,
delegates to `axiom_locally_valid_general`. For others, proves directly. -/
private theorem axiom_locally_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    {φ : Formula} (h : Axiom φ) (h_fc : h.minFrameClass ≤ FrameClass.Discrete) :
    is_valid D φ := by
  by_cases hbase : h.minFrameClass ≤ FrameClass.Base
  · exact axiom_locally_valid_general h hbase
  · cases h with
    | prior_UZ φ => exact prior_UZ_is_valid φ
    | prior_SZ φ => exact prior_SZ_is_valid φ
    | z1 φ => exact z1_is_valid φ
    | density _ => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | dense_indicator => exact absurd h_fc (by simp [Axiom.minFrameClass, LE.le])
    | _ => exact absurd trivial hbase

/-- Combined soundness on discrete frames: derivability implies both validity
and swap-validity on discrete orders. -/
theorem derivable_valid_and_swap_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Discrete [] φ) :
    is_valid D φ ∧ is_valid D φ.swap_temporal := by
  match d with
  | .axiom _ _ h_ax h_fc => exact ⟨axiom_locally_valid_discrete h_ax h_fc, axiom_swap_valid_discrete _ h_ax h_fc⟩
  | .assumption _ _ h_mem => exact absurd h_mem (Syntax.Context.not_mem_nil _)
  | .modus_ponens _ ψ' _ d1 d2 =>
    obtain ⟨h1_valid, h1_swap⟩ := derivable_valid_and_swap_valid_discrete d1
    obtain ⟨h2_valid, h2_swap⟩ := derivable_valid_and_swap_valid_discrete d2
    exact ⟨mp_preserves_valid h1_valid h2_valid, mp_preserves_swap_valid ψ' _ h1_swap h2_swap⟩
  | .necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_discrete d'
    exact ⟨necessitation_preserves_local_valid h_valid, modal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_necessitation ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_discrete d'
    exact ⟨temporal_necessitation_preserves_local_valid h_valid, temporal_k_preserves_swap_valid ψ' h_swap⟩
  | .temporal_duality ψ' d' =>
    obtain ⟨h_valid, h_swap⟩ := derivable_valid_and_swap_valid_discrete d'
    constructor
    · exact h_swap
    · simp only [Formula.swap_temporal_involution]; exact h_valid
  | .weakening Γ' _ _ d' h_sub =>
    have h_eq : Γ' = [] := List.eq_nil_of_subset_nil h_sub
    have h_height_eq : (h_eq ▸ d').height = d'.height := by subst h_eq; rfl
    have h_term : (h_eq ▸ d').height < (DerivationTree.weakening Γ' [] _ d' h_sub).height := by
      simp only [h_height_eq, DerivationTree.height]
      omega
    exact derivable_valid_and_swap_valid_discrete (h_eq ▸ d')
termination_by d.height
decreasing_by
  all_goals first
    | exact DerivationTree.mp_height_gt_left _ _
    | exact DerivationTree.mp_height_gt_right _ _
    | simp only [DerivationTree.height]; omega

/-- Derivability implies swap validity on discrete frames.
Used in soundness_discrete_valid and soundness_discrete temporal_duality cases. -/
theorem derivable_implies_swap_valid_discrete
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]
    {φ : Formula} (d : DerivationTree FrameClass.Discrete [] φ) :
    is_valid D φ.swap_temporal :=
  (derivable_valid_and_swap_valid_discrete d).2


end Bimodal.Metalogic.SoundnessLemmas
