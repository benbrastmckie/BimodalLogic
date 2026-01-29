import Bimodal.Semantics.Truth
import Bimodal.ProofSystem.Derivation
import Bimodal.ProofSystem.Axioms

/-!
# Soundness Lemmas - Bridge Theorems for Temporal Duality

This module contains bridge theorems that connect the proof system (DerivationTree)
to semantic validity (is_valid). These theorems were extracted to resolve a
circular dependency between Truth.lean and Soundness.lean.

## Overview

This module provides the core lemmas needed for proving soundness of the
temporal duality rule, which requires showing that validity is preserved
under formula swap.

## Module Purpose

The theorems in this module prove that swap validity is preserved for derivable formulas
using derivation induction rather than formula induction. This enables the temporal_duality
soundness proof in Soundness.lean.

## Main Results

- `axiom_swap_valid`: All 15 TM axioms remain valid after swap
- `derivable_implies_swap_valid`: Main theorem for soundness of temporal_duality
- Individual `swap_axiom_*_valid` lemmas (8 lemmas for specific axioms)
- `*_preserves_swap_valid` lemmas (5 lemmas for inference rules)

## References

* [Truth.lean](../../Semantics/Truth.lean) - Pure semantic definitions
* [Soundness.lean](Soundness.lean) - Soundness theorem using these lemmas
-/

namespace Bimodal.Metalogic.Soundness.SoundnessLemmas

open Bimodal.Syntax
open Bimodal.ProofSystem (Axiom DerivationTree)
open Bimodal.Semantics

/--
Local definition of validity to avoid circular dependency with Validity.lean.
A formula is valid if it's true at all model-history-time triples.

This is a monomorphic definition (fixed to explicit type parameter D) to allow
type inference at call sites.

**Note**: Validity quantifies over ALL times, not just times in the history's domain.
-/
private def is_valid (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (φ : Formula) : Prop :=
  ∀ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    truth_at M τ t φ

-- Section variable for theorem signatures
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Auxiliary lemma: If phi is valid, then for any specific triple (M, tau, t),
phi is true at that triple.

This is just the definition of validity, but stated as a lemma for clarity.
-/
theorem valid_at_triple {φ : Formula} (F : TaskFrame D) (M : TaskModel F)
    (τ : WorldHistory F) (t : D) (h_valid : is_valid D φ) :
    truth_at M τ t φ := h_valid F M τ t

/--
Helper lemma: truth_at is invariant under double swap.

This lemma proves that applying swap twice to a formula preserves truth evaluation.
Required because truth_at is defined by structural recursion, preventing direct use
of the involution property phi.swap.swap = phi via substitution.
-/
theorem truth_at_swap_swap {F : TaskFrame D} (M : TaskModel F)
    (τ : WorldHistory F) (t : D) (φ : Formula) :
    truth_at M τ t φ.swap_past_future.swap_past_future ↔ truth_at M τ t φ := by
  induction φ generalizing τ t with
  | atom p =>
    simp only [Formula.swap_temporal, truth_at]
  | bot =>
    simp only [Formula.swap_temporal, truth_at]
  | imp φ ψ ih_φ ih_ψ =>
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h <;> intro h_φ
    · exact (ih_ψ τ t).mp (h ((ih_φ τ t).mpr h_φ))
    · exact (ih_ψ τ t).mpr (h ((ih_φ τ t).mp h_φ))
  | box φ ih =>
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h σ
    · exact (ih σ t).mp (h σ)
    · exact (ih σ t).mpr (h σ)
  | all_past φ ih =>
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h s h_ord
    · exact (ih τ s).mp (h s h_ord)
    · exact (ih τ s).mpr (h s h_ord)
  | all_future φ ih =>
    simp only [Formula.swap_temporal, truth_at]
    constructor <;> intro h s h_ord
    · exact (ih τ s).mp (h s h_ord)
    · exact (ih τ s).mpr (h s h_ord)

/-! ## Axiom Swap Validity (Approach D: Derivation-Indexed Proof)

This section proves validity of swapped axioms to enable temporal duality soundness
via derivation induction instead of formula induction.
-/

/--
Modal T axiom (MT) is self-dual under swap: `Box phi -> phi` swaps to `Box(swap phi) -> swap phi`.
-/
theorem swap_axiom_mt_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp φ).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap_φ
  exact h_box_swap_φ τ

/--
Modal 4 axiom (M4) is self-dual under swap: `Box phi -> Box Box phi` swaps to `Box(swap phi) -> Box Box(swap phi)`.
-/
theorem swap_axiom_m4_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.box φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap_φ σ ρ
  exact h_box_swap_φ ρ

/--
Modal B axiom (MB) is self-dual under swap: `phi -> Box Diamond phi` swaps to `swap phi -> Box Diamond(swap phi)`.
-/
theorem swap_axiom_mb_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.box φ.diamond)).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_past_future, Formula.diamond, truth_at]
  intro h_swap_φ σ h_all_not
  exact h_all_not τ h_swap_φ

/--
Temporal 4 axiom (T4) swaps to a valid formula: `G phi -> G G phi` swaps to `H(swap phi) -> H H(swap phi)`.
-/
theorem swap_axiom_t4_valid (φ : Formula) :
    is_valid D
      ((Formula.all_future φ).imp
       (Formula.all_future (Formula.all_future φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_past_swap r h_r_le_t u h_u_le_r
  have h_u_le_t : u ≤ t := le_trans h_u_le_r h_r_le_t
  exact h_past_swap u h_u_le_t

/--
Temporal A axiom (TA) swaps to a valid formula: `phi -> G(sometime_past phi)` swaps to
`swap phi -> H(sometime_future (swap phi))`.
-/
theorem swap_axiom_ta_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.sometime_past)).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_past_future, Formula.sometime_past, Formula.sometime_future, truth_at]
  intro h_swap_φ s h_s_le_t h_all_not_future
  -- h_all_not_future : ForAll u, s <= u -> Not(swap phi at u)
  -- We need to show False given h_swap_phi : swap phi at t
  -- Use u = t: need s <= t which is h_s_le_t
  exact h_all_not_future t h_s_le_t h_swap_φ

/--
Temporal L axiom (TL) swaps to a valid formula: `Always phi -> G H phi` swaps to `Always(swap phi) -> H(G(swap phi))`.
-/
theorem swap_axiom_tl_valid (φ : Formula) :
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_always s h_s_le_t u h_s_le_u
  by_cases h_ut : u ≤ t
  · apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro h_fut_all h_conj
    apply h_conj
    intro h_now h_past
    exact h_neg (h_past u h_ut)
  · have h_gt : t < u := lt_of_not_le h_ut
    apply Classical.byContradiction
    intro h_neg
    apply h_always
    intro h_fut_all h_conj
    exact h_neg (h_fut_all u (le_of_lt h_gt))

/--
Modal-Future axiom (MF) swaps to a valid formula: `Box phi -> Box G phi` swaps to `Box(swap phi) -> Box H(swap phi)`.
-/
theorem swap_axiom_mf_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.box (Formula.all_future φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap σ s h_s_le_t
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t))
  exact (TimeShift.time_shift_preserves_truth M σ t s φ.swap_past_future).mp h_at_shifted

/--
Temporal-Future axiom (TF) swaps to a valid formula: `Box phi -> G Box phi` swaps to `Box(swap phi) -> H Box(swap phi)`.
-/
theorem swap_axiom_tf_valid (φ : Formula) :
    is_valid D ((Formula.box φ).imp (Formula.all_future (Formula.box φ))).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro h_box_swap s h_s_le_t σ
  have h_at_shifted := h_box_swap (WorldHistory.time_shift σ (s - t))
  exact (TimeShift.time_shift_preserves_truth M σ t s φ.swap_past_future).mp h_at_shifted

/-! ## Rule Preservation -/

/--
Modus ponens preserves swap validity.
-/
theorem mp_preserves_swap_valid (φ ψ : Formula)
    (h_imp : is_valid D (φ.imp ψ).swap_past_future)
    (h_phi : is_valid D φ.swap_past_future) :
    is_valid D ψ.swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at] at h_imp h_phi ⊢
  exact h_imp F M τ t (h_phi F M τ t)

/--
Modal K rule preserves swap validity.
-/
theorem modal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D (Formula.box φ).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro σ
  exact h F M σ t

/--
Temporal K rule preserves swap validity.
-/
theorem temporal_k_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D (Formula.all_future φ).swap_past_future := by
  intro F M τ t
  simp only [Formula.swap_temporal, truth_at]
  intro s h_s_lt_t
  exact h F M τ s

/--
Weakening preserves swap validity (trivial for empty context).
-/
theorem weakening_preserves_swap_valid (φ : Formula)
    (h : is_valid D φ.swap_past_future) :
    is_valid D φ.swap_past_future := h

/-! ## Axiom Swap Validity Master Theorem -/

theorem axiom_swap_valid (φ : Formula) (h : Axiom φ) : is_valid D φ.swap_past_future := by
  cases h with
  | prop_k ψ χ ρ =>
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_abc h_ab h_a
    exact h_abc h_a (h_ab h_a)
  | prop_s ψ χ =>
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_a _
    exact h_a
  | modal_t ψ => exact swap_axiom_mt_valid ψ
  | modal_4 ψ => exact swap_axiom_m4_valid ψ
  | modal_b ψ => exact swap_axiom_mb_valid ψ
  | modal_5_collapse ψ =>
    intro F M τ t
    simp only [Formula.swap_past_future, Formula.diamond, Formula.neg, truth_at]
    intro h_diamond_box σ
    by_contra h_not_psi
    apply h_diamond_box
    intro ρ h_box_at_rho
    have h_psi_at_sigma := h_box_at_rho σ
    exact h_not_psi h_psi_at_sigma
  | ex_falso ψ =>
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_bot
    exfalso
    exact h_bot
  | peirce ψ χ =>
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_peirce
    by_cases h : truth_at M τ t ψ.swap_past_future
    · exact h
    · have h_imp : truth_at M τ t (ψ.swap_past_future.imp χ.swap_past_future) := by
        unfold truth_at
        intro h_psi
        exfalso
        exact h h_psi
      exact h_peirce h_imp
  | modal_k_dist ψ χ =>
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_box_imp h_box_psi σ
    exact h_box_imp σ (h_box_psi σ)
  | temp_k_dist ψ χ =>
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_past_imp h_past_psi s hst
    exact h_past_imp s hst (h_past_psi s hst)
  | temp_4 ψ => exact swap_axiom_t4_valid ψ
  | temp_a ψ => exact swap_axiom_ta_valid ψ
  | temp_l ψ => exact swap_axiom_tl_valid ψ
  | modal_future ψ => exact swap_axiom_mf_valid ψ
  | temp_future ψ => exact swap_axiom_tf_valid ψ
  | temp_t_future ψ =>
    -- G phi -> phi swaps to H phi -> phi (which is also valid by reflexivity)
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_all_past
    exact h_all_past t (le_refl t)
  | temp_t_past ψ =>
    -- H phi -> phi swaps to G phi -> phi (which is also valid by reflexivity)
    intro F M τ t
    simp only [Formula.swap_temporal, truth_at]
    intro h_all_future
    exact h_all_future t (le_refl t)

/-! ## Axiom Validity (Local) -/

-- Propositional axioms (use tauto for brevity)
private theorem axiom_prop_k_valid (φ ψ χ : Formula) :
    is_valid D ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ))) := by
  intro F M τ t; simp only [truth_at]; tauto

private theorem axiom_prop_s_valid (φ ψ : Formula) :
    is_valid D (φ.imp (ψ.imp φ)) := by
  intro F M τ t; simp only [truth_at]; tauto

-- Modal axioms
private theorem axiom_modal_t_valid (φ : Formula) :
    is_valid D (φ.box.imp φ) := by
  intro F M τ t; simp only [truth_at]; intro h; exact h τ

private theorem axiom_modal_4_valid (φ : Formula) :
    is_valid D ((φ.box).imp (φ.box.box)) := by
  intro F M τ t; simp only [truth_at]; intro h σ ρ; exact h ρ

private theorem axiom_modal_b_valid (φ : Formula) :
    is_valid D (φ.imp (φ.diamond.box)) := by
  intro F M τ t; simp only [truth_at]; intro h σ h_neg; exact h_neg τ h

private theorem axiom_modal_5_collapse_valid (φ : Formula) :
    is_valid D (φ.box.diamond.imp φ.box) := by
  intro F M τ t; simp only [truth_at]; intro h ρ
  by_contra h_not; exact h (fun σ h_box => h_not (h_box ρ))

private theorem axiom_ex_falso_valid (φ : Formula) :
    is_valid D (Formula.bot.imp φ) := by
  intro F M τ t; simp only [truth_at]; tauto

private theorem axiom_peirce_valid (φ ψ : Formula) :
    is_valid D (((φ.imp ψ).imp φ).imp φ) := by
  intro F M τ t; simp only [truth_at]; intro h
  by_cases hφ : truth_at M τ t φ
  · exact hφ
  · exact h (fun h_phi => absurd h_phi hφ)

-- Distribution axioms
private theorem axiom_modal_k_dist_valid (φ ψ : Formula) :
    is_valid D ((φ.imp ψ).box.imp (φ.box.imp ψ.box)) := by
  intro F M τ t; simp only [truth_at]; intro h_imp h_phi σ; exact h_imp σ (h_phi σ)

private theorem axiom_temp_k_dist_valid (φ ψ : Formula) :
    is_valid D ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future)) := by
  intro F M τ t; simp only [truth_at]; intro h_imp h_phi s hs; exact h_imp s hs (h_phi s hs)

-- Temporal axioms (reflexive: <= instead of <)
private theorem axiom_temp_4_valid (φ : Formula) :
    is_valid D ((φ.all_future).imp (φ.all_future.all_future)) := by
  intro F M τ t; simp only [truth_at]; intro h s hts r hsr; exact h r (le_trans hts hsr)

private theorem axiom_temp_a_valid (φ : Formula) :
    is_valid D (φ.imp (Formula.all_future φ.sometime_past)) := by
  -- TA: phi -> G(Not H Not phi). After intro: need to show Not H Not phi at time s >= t given phi at t
  -- h_neg : ForAll r <= s, Not(phi at r). Use r = t with hts : t <= s.
  intro F M τ t; simp only [truth_at]; intro h s hts h_neg; exact h_neg t hts h

private theorem and_of_not_imp_not {P Q : Prop} (h : (P → Q → False) → False) : P ∧ Q :=
  ⟨Classical.byContradiction (fun hP => h (fun p _ => hP p)),
   Classical.byContradiction (fun hQ => h (fun _ q => hQ q))⟩

private theorem axiom_temp_l_valid (φ : Formula) :
    is_valid D (φ.always.imp (Formula.all_future (Formula.all_past φ))) := by
  intro F M τ t
  simp only [truth_at]
  intro h_always s hts r hrs
  -- h_always : truth_at M tau t (Always phi)
  -- Always phi = all_past phi And (phi And all_future phi) = (all_past phi -> (phi -> all_future phi -> falsity) -> falsity) -> falsity
  -- After unfolding, this gives us phi at all times via Classical reasoning
  have h1 :
    (∀ (u : D), u ≤ t → truth_at M τ u φ) ∧
    ((truth_at M τ t φ →
      (∀ (v : D), t ≤ v → truth_at M τ v φ) → False) → False) :=
    and_of_not_imp_not h_always
  obtain ⟨h_past, h_middle⟩ := h1
  have h2 : truth_at M τ t φ ∧ (∀ (v : D), t ≤ v → truth_at M τ v φ) :=
    and_of_not_imp_not h_middle
  obtain ⟨h_now, h_future⟩ := h2
  -- Now hrs : r <= s and hts : t <= s
  -- Need: truth_at M tau r phi
  by_cases h_rt : r ≤ t
  · exact h_past r h_rt
  · have h_tr : t ≤ r := le_of_not_le h_rt
    exact h_future r h_tr

-- Time-shift axioms (share common time-shift pattern)
private theorem axiom_modal_future_valid (φ : Formula) :
    is_valid D ((φ.box).imp ((φ.all_future).box)) := by
  intro F M τ t; simp only [truth_at]; intro h σ s hs
  exact (TimeShift.time_shift_preserves_truth M σ t s φ).mp (h (WorldHistory.time_shift σ (s - t)))

private theorem axiom_temp_future_valid (φ : Formula) :
    is_valid D ((φ.box).imp ((φ.box).all_future)) := by
  intro F M τ t; simp only [truth_at]; intro h s hs σ
  exact (TimeShift.time_shift_preserves_truth M σ t s φ).mp (h (WorldHistory.time_shift σ (s - t)))

private theorem axiom_locally_valid {φ : Formula} : Axiom φ → is_valid D φ := by
  intro h_axiom
  cases h_axiom with
  | prop_k φ ψ χ => exact axiom_prop_k_valid φ ψ χ
  | prop_s φ ψ => exact axiom_prop_s_valid φ ψ
  | modal_t ψ => exact axiom_modal_t_valid ψ
  | modal_4 ψ => exact axiom_modal_4_valid ψ
  | modal_b ψ => exact axiom_modal_b_valid ψ
  | modal_5_collapse ψ => exact axiom_modal_5_collapse_valid ψ
  | ex_falso ψ => exact axiom_ex_falso_valid ψ
  | peirce φ ψ => exact axiom_peirce_valid φ ψ
  | modal_k_dist φ ψ => exact axiom_modal_k_dist_valid φ ψ
  | temp_k_dist φ ψ => exact axiom_temp_k_dist_valid φ ψ
  | temp_4 ψ => exact axiom_temp_4_valid ψ
  | temp_a ψ => exact axiom_temp_a_valid ψ
  | temp_l ψ => exact axiom_temp_l_valid ψ
  | temp_t_future ψ =>
    intro F M τ t; simp only [truth_at]; intro h; exact h t (le_refl t)
  | temp_t_past ψ =>
    intro F M τ t; simp only [truth_at]; intro h; exact h t (le_refl t)
  | modal_future ψ => exact axiom_modal_future_valid ψ
  | temp_future ψ => exact axiom_temp_future_valid ψ

/-! ## Combined Theorem: Derivable Implies Valid AND Swap Valid -/

/--
Combined theorem: Derivability from empty context implies both validity and swap validity.
-/
theorem derivable_implies_valid_and_swap_valid :
    ∀ {φ : Formula}, DerivationTree [] φ →
      (is_valid D φ ∧ is_valid D φ.swap_past_future) := by
  intro φ h_deriv
  have h_general : ∀ (Gamma : List Formula) (ψ : Formula),
      DerivationTree Gamma ψ → Gamma = [] →
        (is_valid D ψ ∧ is_valid D ψ.swap_past_future) := by
    intro Gamma ψ h
    induction h with
    | «axiom» Gamma' ψ' h_axiom =>
      intro h_eq
      constructor
      · exact axiom_locally_valid h_axiom
      · exact axiom_swap_valid ψ' h_axiom

    | «assumption» Gamma' ψ' h_mem =>
      intro h_eq
      rw [h_eq] at h_mem
      exact False.elim (List.not_mem_nil h_mem)

    | modus_ponens Gamma' ψ' χ' h_imp h_ψ' ih_imp ih_ψ' =>
      intro h_eq
      obtain ⟨h_imp_valid, h_imp_swap⟩ := ih_imp h_eq
      obtain ⟨h_ψ_valid, h_ψ_swap⟩ := ih_ψ' h_eq
      constructor
      · intro F M τ t
        have h1 := h_imp_valid F M τ t
        have h2 := h_ψ_valid F M τ t
        simp only [truth_at] at h1
        exact h1 h2
      · exact mp_preserves_swap_valid ψ' χ' h_imp_swap h_ψ_swap

    | necessitation ψ' h_ψ' ih =>
      intro h_eq
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · intro F M τ t σ
        exact h_valid F M σ t
      · exact modal_k_preserves_swap_valid ψ' h_swap

    | temporal_necessitation ψ' h_ψ' ih =>
      intro h_eq
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · intro F M τ t s hts
        exact h_valid F M τ s
      · exact temporal_k_preserves_swap_valid ψ' h_swap

    | temporal_duality ψ' h_ψ' ih =>
      intro h_eq
      obtain ⟨h_valid, h_swap⟩ := ih rfl
      constructor
      · exact h_swap
      · intro F M τ t
        have h_truth := h_valid F M τ t
        exact (truth_at_swap_swap M τ t ψ').mpr h_truth

    | weakening Gamma' Delta' ψ' h_ψ' h_subset ih =>
      intro h_eq
      have h_gamma_empty : Gamma' = [] := by
        cases Gamma' with
        | nil => rfl
        | cons head tail =>
          have : head ∈ Delta' := h_subset List.mem_cons_self
          rw [h_eq] at this
          exact False.elim (List.not_mem_nil this)
      exact ih h_gamma_empty

  exact h_general [] φ h_deriv rfl

/--
Soundness from empty context: derivability implies validity.
-/
theorem soundness_from_empty :
    ∀ {φ : Formula}, DerivationTree [] φ → is_valid D φ :=
  fun h => (derivable_implies_valid_and_swap_valid h).1

/--
Main theorem: If a formula is derivable from empty context, then its swap is valid.
-/
theorem derivable_implies_swap_valid :
    ∀ {φ : Formula}, DerivationTree [] φ → is_valid D φ.swap_past_future :=
  fun h => (derivable_implies_valid_and_swap_valid h).2

end Bimodal.Metalogic.Soundness.SoundnessLemmas
