import Bimodal.Metalogic.BXCanonical.CanonicalChain
import Bimodal.Metalogic.BXCanonical.TruthLemma
import Bimodal.Metalogic.Bundle.FMCSDef

/-!
# BXCanonical Canonical Model Construction

Constructs a BFMCS Int from BXCanonical witnesses, bridging to the parametric
algebraic completeness theorem for the BX completeness proof.

Given an MCS M₀, build a chain of MCS indexed by Int. Forward steps use
`forward_temporal_witness_seed` from WitnessSeed.lean, backward steps use
`past_temporal_witness_seed`. A pairing schedule ensures every formula is
targeted for resolution infinitely often.

The BFMCS has one FMCS per modal class reachable from M₀. Modal coherence
follows from S5 properties of BXCanonical (box_preserved_along_bx_le,
bx_modal_witness).
-/

namespace Bimodal.Metalogic.BXCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Theorems.Perpetuity
open Bimodal.Theorems.Combinators

/-! ## Schedule -/

noncomputable def schedule (n : Nat) : Formula :=
  Denumerable.ofNat Formula (Nat.unpair n).2

theorem schedule_surjective_above (ψ : Formula) (k : Nat) :
    ∃ n : Nat, n ≥ k ∧ schedule n = ψ :=
  ⟨Nat.pair k (Encodable.encode ψ),
   Nat.left_le_pair k _,
   by simp [schedule, Nat.unpair_pair, Denumerable.ofNat_encode]⟩

/-! ## Forward Step -/

/-- Build a successor MCS containing g_content(M). If F(ψ) ∈ M, also contains ψ.
    Under irreflexive semantics, the non-resolving branch uses g_content(M) alone
    (consistent by seriality via g_content_set_consistent). -/
noncomputable def fwd_succ (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    Set Formula := by
  by_cases h_F : Formula.some_future ψ ∈ M
  · exact (set_lindenbaum (forward_temporal_witness_seed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose
  · exact (set_lindenbaum (g_content M)
      (g_content_set_consistent h_mcs)).choose

theorem fwd_succ_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    SetMaximalConsistent (fwd_succ M h_mcs ψ) := by
  unfold fwd_succ; split
  · exact (set_lindenbaum (forward_temporal_witness_seed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (g_content M)
      (g_content_set_consistent h_mcs)).choose_spec.2

theorem fwd_succ_g_content (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    g_content M ⊆ fwd_succ M h_mcs ψ := by
  unfold fwd_succ; split
  · exact fun χ hχ => (set_lindenbaum (forward_temporal_witness_seed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (g_content M)
      (g_content_set_consistent h_mcs)).choose_spec.1 hχ

theorem fwd_succ_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ M) : ψ ∈ fwd_succ M h_mcs ψ := by
  unfold fwd_succ; rw [dif_pos h_F]
  exact (set_lindenbaum (forward_temporal_witness_seed M ψ)
    (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-! ## Backward Step -/

/-- h_content(M) is consistent for MCS M.
Under irreflexive semantics, uses seriality (⊤ → P(⊤)) via h_content_set_consistent. -/
theorem h_content_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) :
    SetConsistent (fc := FrameClass.Base) (h_content M) :=
  h_content_set_consistent h_mcs

/-- Build a predecessor MCS containing h_content(M). If P(ψ) ∈ M, also contains ψ.
    Under irreflexive semantics, the non-resolving branch uses h_content(M) alone. -/
noncomputable def bwd_pred (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    Set Formula := by
  by_cases h_P : Formula.some_past ψ ∈ M
  · exact (set_lindenbaum (past_temporal_witness_seed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose
  · exact (set_lindenbaum (h_content M)
      (h_content_set_consistent h_mcs)).choose

theorem bwd_pred_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    SetMaximalConsistent (bwd_pred M h_mcs ψ) := by
  unfold bwd_pred; split
  · exact (set_lindenbaum (past_temporal_witness_seed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (h_content M)
      (h_content_set_consistent h_mcs)).choose_spec.2

theorem bwd_pred_h_content (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    h_content M ⊆ bwd_pred M h_mcs ψ := by
  unfold bwd_pred; split
  · exact fun χ hχ => (set_lindenbaum (past_temporal_witness_seed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (h_content M)
      (h_content_set_consistent h_mcs)).choose_spec.1 hχ

theorem bwd_pred_resolves (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula)
    (h_P : Formula.some_past ψ ∈ M) : ψ ∈ bwd_pred M h_mcs ψ := by
  unfold bwd_pred; rw [dif_pos h_P]
  exact (set_lindenbaum (past_temporal_witness_seed M ψ)
    (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-! ## Forward/Backward Chains -/

noncomputable def fwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := fwd_chain M₀ h₀ n
    ⟨fwd_succ M hM (schedule n), fwd_succ_mcs M hM (schedule n)⟩

noncomputable def bwd_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := bwd_chain M₀ h₀ n
    ⟨bwd_pred M hM (schedule n), bwd_pred_mcs M hM (schedule n)⟩

/-! ## Int-indexed Chain -/

noncomputable def int_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (t : Int) :
    Set Formula :=
  if t ≥ 0 then (fwd_chain M₀ h₀ t.toNat).val
  else (bwd_chain M₀ h₀ ((-t).toNat)).val

theorem int_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    int_chain M₀ h₀ 0 = M₀ := by simp [int_chain, fwd_chain]

theorem int_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (t : Int) :
    SetMaximalConsistent (int_chain M₀ h₀ t) := by
  simp only [int_chain]; split
  · exact (fwd_chain M₀ h₀ t.toNat).property
  · exact (bwd_chain M₀ h₀ ((-t).toNat)).property

/-! ### Chain ordering (g_content/h_content) -/

theorem fwd_chain_g_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (n : Nat) :
    g_content (fwd_chain M₀ h₀ n).val ⊆ (fwd_chain M₀ h₀ (n + 1)).val := by
  show g_content (fwd_chain M₀ h₀ n).val ⊆
    (fwd_succ (fwd_chain M₀ h₀ n).val (fwd_chain M₀ h₀ n).property (schedule n))
  exact fwd_succ_g_content _ _ _

/-- g_content transits strictly: m < n → g_content(chain(m)) ⊆ chain(n).
Under strict FMCS ordering, only strictly future propagation is needed. -/
theorem fwd_chain_g_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    g_content (fwd_chain M₀ h₀ m).val ⊆ (fwd_chain M₀ h₀ n).val := by
  induction n with
  | zero => exact absurd h (Nat.not_lt_zero m)
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le (Nat.lt_succ_iff.mp h) with rfl | h_lt
    · exact fwd_chain_g_content_step M₀ h₀ m
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future (fwd_chain M₀ h₀ m).property hφ
      exact fwd_chain_g_content_step M₀ h₀ n (ih h_lt h_GG)

theorem bwd_chain_h_content_step (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (n : Nat) :
    h_content (bwd_chain M₀ h₀ n).val ⊆ (bwd_chain M₀ h₀ (n + 1)).val := by
  show h_content (bwd_chain M₀ h₀ n).val ⊆
    (bwd_pred (bwd_chain M₀ h₀ n).val (bwd_chain M₀ h₀ n).property (schedule n))
  exact bwd_pred_h_content _ _ _

/-- h_content transits strictly: m < n → h_content(chain(m)) ⊆ chain(n).
Under strict FMCS ordering, only strictly past propagation is needed. -/
theorem bwd_chain_h_content_trans (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    h_content (bwd_chain M₀ h₀ m).val ⊆ (bwd_chain M₀ h₀ n).val := by
  induction n with
  | zero => exact absurd h (Nat.not_lt_zero m)
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le (Nat.lt_succ_iff.mp h) with rfl | h_lt
    · exact bwd_chain_h_content_step M₀ h₀ m
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past (bwd_chain M₀ h₀ m).property hφ
      exact bwd_chain_h_content_step M₀ h₀ n (ih h_lt h_HH)

/-! ### Forward G and Backward H -/

/-- The g_content relationship also gives us reverse h_content (strict). -/
theorem fwd_chain_reverse_h (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    h_content (fwd_chain M₀ h₀ n).val ⊆ (fwd_chain M₀ h₀ m).val :=
  g_content_subset_implies_h_content_reverse
    (fwd_chain M₀ h₀ m).val (fwd_chain M₀ h₀ n).val
    (fwd_chain M₀ h₀ m).property (fwd_chain M₀ h₀ n).property
    (fwd_chain_g_content_trans M₀ h₀ h)

/-- Reverse: h_content along bwd_chain gives g_content in reverse (strict). -/
theorem bwd_chain_reverse_g (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    g_content (bwd_chain M₀ h₀ n).val ⊆ (bwd_chain M₀ h₀ m).val :=
  h_content_subset_implies_g_content_reverse
    (bwd_chain M₀ h₀ m).val (bwd_chain M₀ h₀ n).val
    (bwd_chain M₀ h₀ m).property (bwd_chain M₀ h₀ n).property
    (bwd_chain_h_content_trans M₀ h₀ h)

/-- g_content propagation across the full Int chain (strict). -/
theorem int_chain_g_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {t t' : Int} (h_lt : t < t') :
    g_content (int_chain M₀ h₀ t) ⊆ int_chain M₀ h₀ t' := by
  simp only [int_chain]
  split_ifs with ht ht'
  · -- t ≥ 0, t' ≥ 0: use fwd_chain_g_content_trans (strict)
    exact fwd_chain_g_content_trans M₀ h₀ (by omega)
  · -- t ≥ 0, t' < 0: impossible
    omega
  · -- t < 0, t' ≥ 0: go through M₀
    -- hχ : χ ∈ g_content(bwd(-t)), so G(χ) ∈ bwd(-t).
    -- G(G(χ)) ∈ bwd(-t) via temp_4, then bwd_chain_reverse_g: G(χ) ∈ bwd(0) = M₀.
    -- For t' > 0: G(χ) ∈ fwd(0), use fwd_chain_g_content_trans.
    -- For t' = 0: χ ∈ g_content(bwd(-t)) and bwd_chain_reverse_g: χ ∈ bwd(0) = M₀ = fwd(0).
    intro χ hχ
    have h_Gchi_in_bwd : Formula.all_future χ ∈ (bwd_chain M₀ h₀ ((-t).toNat)).val := hχ
    rcases Nat.eq_zero_or_pos t'.toNat with h_zero | h_pos
    · -- t' = 0: χ ∈ bwd(0) = M₀ = fwd(0)
      have h_chi_in_bwd0 : χ ∈ (bwd_chain M₀ h₀ 0).val :=
        bwd_chain_reverse_g M₀ h₀ (by omega) hχ
      simp only [bwd_chain] at h_chi_in_bwd0
      simp only [h_zero, fwd_chain]
      exact h_chi_in_bwd0
    · -- t' > 0: G(χ) ∈ M₀, use fwd_chain_g_content_trans
      have h_GGchi := SetMaximalConsistent.all_future_all_future
        (bwd_chain M₀ h₀ ((-t).toNat)).property h_Gchi_in_bwd
      have h_Gchi_in_bwd0 : Formula.all_future χ ∈ (bwd_chain M₀ h₀ 0).val :=
        bwd_chain_reverse_g M₀ h₀ (by omega) h_GGchi
      simp only [bwd_chain] at h_Gchi_in_bwd0
      -- h_Gchi_in_bwd0 : G(χ) ∈ M₀ = fwd_chain(0)
      exact fwd_chain_g_content_trans M₀ h₀ h_pos h_Gchi_in_bwd0
  · -- t < 0, t' < 0: bwd_chain_reverse_g (strict)
    -- Since t < t' < 0: (-t').toNat < (-t).toNat
    exact bwd_chain_reverse_g M₀ h₀ (by omega)

theorem int_chain_forward_G (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (t t' : Int) (φ : Formula) (h_lt : t < t')
    (h_G : Formula.all_future φ ∈ int_chain M₀ h₀ t) :
    φ ∈ int_chain M₀ h₀ t' :=
  int_chain_g_content M₀ h₀ h_lt h_G

/-- h_content propagation across the full Int chain (reverse direction, strict). -/
theorem int_chain_h_content (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {t t' : Int} (h_lt : t < t') :
    h_content (int_chain M₀ h₀ t') ⊆ int_chain M₀ h₀ t :=
  g_content_subset_implies_h_content_reverse
    (int_chain M₀ h₀ t) (int_chain M₀ h₀ t')
    (int_chain_mcs M₀ h₀ t) (int_chain_mcs M₀ h₀ t')
    (int_chain_g_content M₀ h₀ h_lt)

theorem int_chain_backward_H (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (t t' : Int) (φ : Formula) (h_lt : t' < t)
    (h_H : Formula.all_past φ ∈ int_chain M₀ h₀ t) :
    φ ∈ int_chain M₀ h₀ t' :=
  int_chain_h_content M₀ h₀ h_lt h_H

/-! ## FMCS -/

noncomputable def bx_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) : FMCS Int where
  mcs := int_chain M₀ h₀
  is_mcs := int_chain_mcs M₀ h₀
  forward_G := int_chain_forward_G M₀ h₀
  backward_H := int_chain_backward_H M₀ h₀

theorem bx_fmcs_at_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    (bx_fmcs M₀ h₀).mcs 0 = M₀ := int_chain_zero M₀ h₀

/-! ## Shifted FMCS

A shifted FMCS places the origin MCS at time offset `s` instead of time 0.
This is needed for modal saturation: when a Diamond witness is needed at time t,
we shift the chain so the witness MCS appears at position t.
-/

/-- A time-shifted FMCS: `mcs t = int_chain M₀ h₀ (t - s)`. -/
noncomputable def shifted_bx_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (s : Int) : FMCS Int where
  mcs t := int_chain M₀ h₀ (t - s)
  is_mcs t := int_chain_mcs M₀ h₀ (t - s)
  forward_G t t' φ h_lt h_G := int_chain_forward_G M₀ h₀ (t - s) (t' - s) φ (by omega) h_G
  backward_H t t' φ h_lt h_H := int_chain_backward_H M₀ h₀ (t - s) (t' - s) φ (by omega) h_H

theorem shifted_bx_fmcs_at_s (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (s : Int) :
    (shifted_bx_fmcs M₀ h₀ s).mcs s = M₀ := by
  simp [shifted_bx_fmcs, int_chain_zero]

/-! ## Box Stability Along the Chain -/

/-- Box formulas are stable along the int_chain: Box φ ∈ chain(t) ↔ Box φ ∈ M₀.

This is the set-level analog of `box_preserved_along_bx_le` from Frame.lean.
The proof uses:
- Forward: temp_future_derived (□φ → G(□φ)) for t ≥ 0, modal_4 + box_to_past for t < 0
- Backward: contrapositive via neg_box_to_box_neg_box (S5 negative introspection)
-/
theorem box_stable_in_int_chain (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (φ : Formula) (t : Int) :
    Formula.box φ ∈ int_chain M₀ h₀ t ↔ Formula.box φ ∈ M₀ := by
  constructor
  · -- Backward: Box φ ∈ chain(t) → Box φ ∈ M₀
    -- Contrapositive: Box φ ∉ M₀ → Box φ ∉ chain(t)
    intro h_box_t
    by_contra h_not_box_M0
    -- ¬(Box φ) ∈ M₀
    have h_neg_box_M0 : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box_M0
      · exact h
    -- Box(¬(Box φ)) ∈ M₀ by S5 negative introspection
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ M₀ :=
      SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (neg_box_to_box_neg_box φ)) h_neg_box_M0
    -- Propagate Box(¬(Box φ)) to chain(t)
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ int_chain M₀ h₀ t := by
      rcases lt_trichotomy 0 t with h_pos | rfl | h_neg
      · -- t > 0: use G propagation
        have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (temp_future_derived (Formula.box φ).neg))
          h_box_neg
        exact int_chain_forward_G M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) h_pos h_G
      · -- t = 0: chain(0) = M₀
        rw [int_chain_zero]; exact h_box_neg
      · -- t < 0: use H propagation (Box → Box Box → H Box via modal_4 + box_to_past)
        have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (box_to_past (Formula.box (Formula.box φ).neg))) h_box_box_neg
        exact int_chain_backward_H M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) h_neg h_H
    -- Box(¬(Box φ)) ∈ chain(t), so ¬(Box φ) ∈ chain(t) by modal_t
    have h_neg_box_t : (Formula.box φ).neg ∈ int_chain M₀ h₀ t :=
      SetMaximalConsistent.implication_property (int_chain_mcs M₀ h₀ t)
        (theorem_in_mcs (int_chain_mcs M₀ h₀ t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg)))
        h_box_neg_t
    -- Contradiction: Box φ and ¬(Box φ) both in chain(t)
    exact set_consistent_not_both (int_chain_mcs M₀ h₀ t).1 (Formula.box φ) h_box_t h_neg_box_t
  · -- Forward: Box φ ∈ M₀ → Box φ ∈ chain(t)
    intro h_box_M0
    rcases lt_trichotomy 0 t with h_pos | rfl | h_neg
    · -- t > 0: use G propagation (temp_future_derived: □φ → G(□φ))
      have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (temp_future_derived φ)) h_box_M0
      exact int_chain_forward_G M₀ h₀ 0 t (Formula.box φ) h_pos h_G
    · -- t = 0: chain(0) = M₀
      rw [int_chain_zero]; exact h_box_M0
    · -- t < 0: use H propagation (modal_4: □φ → □□φ, box_to_past: □(□φ) → H(□φ))
      have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ))) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (box_to_past (Formula.box φ))) h_box_box
      exact int_chain_backward_H M₀ h₀ 0 t (Formula.box φ) h_neg h_H

/-- Box stability for shifted FMCS: Box φ ∈ (shifted_bx_fmcs M₀ h₀ s).mcs t ↔ Box φ ∈ M₀. -/
theorem box_stable_in_shifted_fmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (φ : Formula) (s t : Int) :
    Formula.box φ ∈ (shifted_bx_fmcs M₀ h₀ s).mcs t ↔ Formula.box φ ∈ M₀ :=
  box_stable_in_int_chain M₀ h₀ φ (t - s)

end Bimodal.Metalogic.BXCanonical
