/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.CanonicalChain
import FormalSystem.Metalogic.BXCanonical.TruthLemma
import FormalSystem.Metalogic.Bundle.FMCSDef
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleTypes
import FormalSystem.Metalogic.Bundle.BFMCS
import FormalSystem.Theorems.ModalDerived

/-!
# BXCanonical Canonical Model Construction

Constructs a BFMCS Int from BXCanonical witnesses, bridging to the parametric
algebraic completeness theorem for the BX completeness proof.

Given an MCS M₀, build a chain of MCS indexed by Int. Forward steps use
`ForwardTemporalWitnessSeed` from WitnessSeed.lean, backward steps use
`PastTemporalWitnessSeed`. A pairing schedule ensures every formula is
targeted for resolution infinitely often.

The BFMCS has one FMCS per modal class reachable from M₀. Modal coherence
follows from S5 properties of BXCanonical (box_preserved_along_bx_le,
bx_modal_witness).
-/

namespace FormalSystem.Metalogic.BXCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.Combinators

/-! ## Schedule -/

/-- Enumeration schedule for the Henkin construction: stage `n` handles the formula
`Denumerable.ofNat Formula (Nat.unpair n).2`. Pairing makes every formula recur at
arbitrarily large stages, which is what `schedule_surjective_above` records. -/
noncomputable def schedule (n : Nat) : Formula :=
  Denumerable.ofNat Formula (Nat.unpair n).2

theorem schedule_surjective_above (ψ : Formula) (k : Nat) :
    ∃ n : Nat, n ≥ k ∧ schedule n = ψ :=
  ⟨Nat.pair k (Encodable.encode ψ),
   Nat.left_le_pair k _,
   by simp [schedule, Nat.unpair_pair, Denumerable.ofNat_encode]⟩

/-! ## Forward Step -/

/-- Build a successor MCS containing GContent(M). If F(ψ) ∈ M, also contains ψ.
    Under irreflexive semantics, the non-resolving branch uses GContent(M) alone
    (consistent by seriality via g_content_set_consistent). -/
noncomputable def FwdSucc (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    Set Formula := by
  by_cases h_F : Formula.someFuture ψ ∈ M
  · exact (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose
  · exact (set_lindenbaum (GContent M)
      (g_content_set_consistent h_mcs)).choose

theorem fwd_succ_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (ψ : Formula) :
    SetMaximalConsistent (fc := FrameClass.Base) (FwdSucc M h_mcs ψ) := by
  unfold FwdSucc; split
  · exact (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (GContent M)
      (g_content_set_consistent h_mcs)).choose_spec.2

theorem fwd_succ_g_content (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    GContent M ⊆ FwdSucc M h_mcs ψ := by
  unfold FwdSucc; split
  · exact fun χ hχ => (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (GContent M)
      (g_content_set_consistent h_mcs)).choose_spec.1 hχ

theorem fwd_succ_resolves (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula)
    (h_F : Formula.someFuture ψ ∈ M) : ψ ∈ FwdSucc M h_mcs ψ := by
  unfold FwdSucc; rw [dif_pos h_F]
  exact (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
    (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-! ## Backward Step -/

/-- HContent(M) is consistent for MCS M.
Under irreflexive semantics, uses seriality (⊤ → P(⊤)) via h_content_set_consistent. -/
theorem h_content_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) :
    SetConsistent (fc := FrameClass.Base) (HContent M) :=
  h_content_set_consistent h_mcs

/-- Build a predecessor MCS containing HContent(M). If P(ψ) ∈ M, also contains ψ.
    Under irreflexive semantics, the non-resolving branch uses HContent(M) alone. -/
noncomputable def BwdPred (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    Set Formula := by
  by_cases h_P : Formula.somePast ψ ∈ M
  · exact (set_lindenbaum (PastTemporalWitnessSeed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose
  · exact (set_lindenbaum (HContent M)
      (h_content_set_consistent h_mcs)).choose

theorem bwd_pred_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M)
    (ψ : Formula) :
    SetMaximalConsistent (fc := FrameClass.Base) (BwdPred M h_mcs ψ) := by
  unfold BwdPred; split
  · exact (set_lindenbaum (PastTemporalWitnessSeed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (HContent M)
      (h_content_set_consistent h_mcs)).choose_spec.2

theorem bwd_pred_h_content (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula) :
    HContent M ⊆ BwdPred M h_mcs ψ := by
  unfold BwdPred; split
  · exact fun χ hχ => (set_lindenbaum (PastTemporalWitnessSeed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (HContent M)
      (h_content_set_consistent h_mcs)).choose_spec.1 hχ

theorem bwd_pred_resolves (M : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := FrameClass.Base) M) (ψ : Formula)
    (h_P : Formula.somePast ψ ∈ M) : ψ ∈ BwdPred M h_mcs ψ := by
  unfold BwdPred; rw [dif_pos h_P]
  exact (set_lindenbaum (PastTemporalWitnessSeed M ψ)
    (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-! ## Forward/Backward Chains -/

/-- Forward Henkin chain over `FrameClass.Base`: iterate `FwdSucc` along `schedule`,
carrying the maximal-consistency proof of each stage along with the set. -/
noncomputable def fwdChain (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := fwdChain M₀ h₀ n
    ⟨FwdSucc M hM (schedule n), fwd_succ_mcs M hM (schedule n)⟩

/-- Backward Henkin chain over `FrameClass.Base`: the past-directed counterpart of
`fwdChain`, iterating `BwdPred` along `schedule`. -/
noncomputable def bwdChain (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent (fc := FrameClass.Base) M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := bwdChain M₀ h₀ n
    ⟨BwdPred M hM (schedule n), bwd_pred_mcs M hM (schedule n)⟩

/-! ## Int-indexed Chain -/

/-- The ℤ-indexed chain of maximal consistent sets: `fwdChain` at nonnegative times
and `bwdChain` at negative times. -/
noncomputable def IntChain (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (t : Int) :
    Set Formula :=
  if t ≥ 0 then (fwdChain M₀ h₀ t.toNat).val
  else (bwdChain M₀ h₀ ((-t).toNat)).val

theorem int_chain_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    IntChain M₀ h₀ 0 = M₀ := by simp [IntChain, fwdChain]

theorem int_chain_mcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (t : Int) :
    SetMaximalConsistent (fc := FrameClass.Base) (IntChain M₀ h₀ t) := by
  simp only [IntChain]; split
  · exact (fwdChain M₀ h₀ t.toNat).property
  · exact (bwdChain M₀ h₀ ((-t).toNat)).property

/-! ### Chain ordering (GContent/HContent) -/

theorem fwd_chain_g_content_step (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (n : Nat) :
    GContent (fwdChain M₀ h₀ n).val ⊆ (fwdChain M₀ h₀ (n + 1)).val := by
  change GContent (fwdChain M₀ h₀ n).val ⊆
    (FwdSucc (fwdChain M₀ h₀ n).val (fwdChain M₀ h₀ n).property (schedule n))
  exact fwd_succ_g_content _ _ _

/-- GContent transits strictly: m < n → GContent(chain(m)) ⊆ chain(n).
Under strict FMCS ordering, only strictly future propagation is needed. -/
theorem fwd_chain_g_content_trans (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    GContent (fwdChain M₀ h₀ m).val ⊆ (fwdChain M₀ h₀ n).val := by
  induction n with
  | zero => exact absurd h (Nat.not_lt_zero m)
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le (Nat.lt_succ_iff.mp h) with rfl | h_lt
    · exact fwd_chain_g_content_step M₀ h₀ m
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future (fwdChain M₀ h₀ m).property hφ
      exact fwd_chain_g_content_step M₀ h₀ n (ih h_lt h_GG)

theorem bwd_chain_h_content_step (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (n : Nat) :
    HContent (bwdChain M₀ h₀ n).val ⊆ (bwdChain M₀ h₀ (n + 1)).val := by
  change HContent (bwdChain M₀ h₀ n).val ⊆
    (BwdPred (bwdChain M₀ h₀ n).val (bwdChain M₀ h₀ n).property (schedule n))
  exact bwd_pred_h_content _ _ _

/-- HContent transits strictly: m < n → HContent(chain(m)) ⊆ chain(n).
Under strict FMCS ordering, only strictly past propagation is needed. -/
theorem bwd_chain_h_content_trans (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    HContent (bwdChain M₀ h₀ m).val ⊆ (bwdChain M₀ h₀ n).val := by
  induction n with
  | zero => exact absurd h (Nat.not_lt_zero m)
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le (Nat.lt_succ_iff.mp h) with rfl | h_lt
    · exact bwd_chain_h_content_step M₀ h₀ m
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past (bwdChain M₀ h₀ m).property hφ
      exact bwd_chain_h_content_step M₀ h₀ n (ih h_lt h_HH)

/-! ### Forward G and Backward H -/

/-- The GContent relationship also gives us reverse HContent (strict). -/
theorem fwd_chain_reverse_h (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    HContent (fwdChain M₀ h₀ n).val ⊆ (fwdChain M₀ h₀ m).val :=
  g_content_subset_implies_h_content_reverse
    (fwdChain M₀ h₀ m).val (fwdChain M₀ h₀ n).val
    (fwdChain M₀ h₀ m).property (fwdChain M₀ h₀ n).property
    (fwd_chain_g_content_trans M₀ h₀ h)

/-- Reverse: HContent along bwdChain gives GContent in reverse (strict). -/
theorem bwd_chain_reverse_g (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {m n : Nat} (h : m < n) :
    GContent (bwdChain M₀ h₀ n).val ⊆ (bwdChain M₀ h₀ m).val :=
  h_content_subset_implies_g_content_reverse
    (bwdChain M₀ h₀ m).val (bwdChain M₀ h₀ n).val
    (bwdChain M₀ h₀ m).property (bwdChain M₀ h₀ n).property
    (bwd_chain_h_content_trans M₀ h₀ h)

/-- GContent propagation across the full Int chain (strict). -/
theorem int_chain_g_content (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {t t' : Int} (h_lt : t < t') :
    GContent (IntChain M₀ h₀ t) ⊆ IntChain M₀ h₀ t' := by
  simp only [IntChain]
  split_ifs with ht ht'
  · -- t ≥ 0, t' ≥ 0: use fwd_chain_g_content_trans (strict)
    exact fwd_chain_g_content_trans M₀ h₀ (by omega)
  · -- t ≥ 0, t' < 0: impossible
    omega
  · -- t < 0, t' ≥ 0: go through M₀
    -- hχ : χ ∈ GContent(bwd(-t)), so G(χ) ∈ bwd(-t).
    -- G(G(χ)) ∈ bwd(-t) via temp_4, then bwd_chain_reverse_g: G(χ) ∈ bwd(0) = M₀.
    -- For t' > 0: G(χ) ∈ fwd(0), use fwd_chain_g_content_trans.
    -- For t' = 0: χ ∈ GContent(bwd(-t)) and bwd_chain_reverse_g: χ ∈ bwd(0) = M₀ = fwd(0).
    intro χ hχ
    have h_Gchi_in_bwd : Formula.allFuture χ ∈ (bwdChain M₀ h₀ ((-t).toNat)).val := hχ
    rcases Nat.eq_zero_or_pos t'.toNat with h_zero | h_pos
    · -- t' = 0: χ ∈ bwd(0) = M₀ = fwd(0)
      have h_chi_in_bwd0 : χ ∈ (bwdChain M₀ h₀ 0).val :=
        bwd_chain_reverse_g M₀ h₀ (by omega) hχ
      simp only [bwdChain] at h_chi_in_bwd0
      simp only [h_zero, fwdChain]
      exact h_chi_in_bwd0
    · -- t' > 0: G(χ) ∈ M₀, use fwd_chain_g_content_trans
      have h_GGchi := SetMaximalConsistent.all_future_all_future
        (bwdChain M₀ h₀ ((-t).toNat)).property h_Gchi_in_bwd
      have h_Gchi_in_bwd0 : Formula.allFuture χ ∈ (bwdChain M₀ h₀ 0).val :=
        bwd_chain_reverse_g M₀ h₀ (by omega) h_GGchi
      simp only [bwdChain] at h_Gchi_in_bwd0
      -- h_Gchi_in_bwd0 : G(χ) ∈ M₀ = fwdChain(0)
      exact fwd_chain_g_content_trans M₀ h₀ h_pos h_Gchi_in_bwd0
  · -- t < 0, t' < 0: bwd_chain_reverse_g (strict)
    -- Since t < t' < 0: (-t').toNat < (-t).toNat
    exact bwd_chain_reverse_g M₀ h₀ (by omega)

theorem int_chain_forward_G (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (t t' : Int) (φ : Formula) (h_lt : t < t')
    (h_G : Formula.allFuture φ ∈ IntChain M₀ h₀ t) :
    φ ∈ IntChain M₀ h₀ t' :=
  int_chain_g_content M₀ h₀ h_lt h_G

/-- HContent propagation across the full Int chain (reverse direction, strict). -/
theorem int_chain_h_content (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    {t t' : Int} (h_lt : t < t') :
    HContent (IntChain M₀ h₀ t') ⊆ IntChain M₀ h₀ t :=
  g_content_subset_implies_h_content_reverse
    (IntChain M₀ h₀ t) (IntChain M₀ h₀ t')
    (int_chain_mcs M₀ h₀ t) (int_chain_mcs M₀ h₀ t')
    (int_chain_g_content M₀ h₀ h_lt)

theorem int_chain_backward_H (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (t t' : Int) (φ : Formula) (h_lt : t' < t)
    (h_H : Formula.allPast φ ∈ IntChain M₀ h₀ t) :
    φ ∈ IntChain M₀ h₀ t' :=
  int_chain_h_content M₀ h₀ h_lt h_H

/-! ## FMCS -/

/-- The canonical ℤ-indexed family of maximal consistent sets built from `IntChain`,
packaged as an `FMCS` with its forward-`G` and backward-`H` coherence proofs. -/
noncomputable def bxFmcs (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    : FMCS Int where
  mcs := IntChain M₀ h₀
  is_mcs := int_chain_mcs M₀ h₀
  forward_G := int_chain_forward_G M₀ h₀
  backward_H := int_chain_backward_H M₀ h₀

theorem bx_fmcs_at_zero (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) :
    (bxFmcs M₀ h₀).mcs 0 = M₀ := int_chain_zero M₀ h₀

/-! ## Shifted FMCS

A shifted FMCS places the origin MCS at time offset `s` instead of time 0.
This is needed for modal saturation: when a Diamond witness is needed at time t,
we shift the chain so the witness MCS appears at position t.
-/

/-- A time-shifted FMCS: `mcs t = IntChain M₀ h₀ (t - s)`. -/
noncomputable def shiftedBxFmcs (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (s : Int) : FMCS Int where
  mcs t := IntChain M₀ h₀ (t - s)
  is_mcs t := int_chain_mcs M₀ h₀ (t - s)
  forward_G t t' φ h_lt h_G := int_chain_forward_G M₀ h₀ (t - s) (t' - s) φ (by omega) h_G
  backward_H t t' φ h_lt h_H := int_chain_backward_H M₀ h₀ (t - s) (t' - s) φ (by omega) h_H

theorem shifted_bx_fmcs_at_s (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀) (s : Int) :
    (shiftedBxFmcs M₀ h₀ s).mcs s = M₀ := by
  simp [shiftedBxFmcs, int_chain_zero]

/-! ## Box Stability Along the Chain -/

/-- Box formulas are stable along the IntChain: Box φ ∈ chain(t) ↔ Box φ ∈ M₀.

This is the set-level analog of `box_preserved_along_bx_le` from Frame.lean.
The proof uses:
- Forward: temporalFutureDerived (□φ → G(□φ)) for t ≥ 0, modal_4 + boxToPast for t < 0
- Backward: contrapositive via negBoxToBoxNegBox (S5 negative introspection)
-/
theorem box_stable_in_int_chain (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (φ : Formula) (t : Int) :
    Formula.box φ ∈ IntChain M₀ h₀ t ↔ Formula.box φ ∈ M₀ := by
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
        (theorem_in_mcs h₀ (negBoxToBoxNegBox φ)) h_neg_box_M0
    -- Propagate Box(¬(Box φ)) to chain(t)
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ IntChain M₀ h₀ t := by
      rcases lt_trichotomy 0 t with h_pos | rfl | h_neg
      · -- t > 0: use G propagation
        have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (temporalFutureDerived (Formula.box φ).neg))
          h_box_neg
        exact int_chain_forward_G M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) h_pos h_G
      · -- t = 0: chain(0) = M₀
        rw [int_chain_zero]; exact h_box_neg
      · -- t < 0: use H propagation (Box → Box Box → H Box via modal_4 + boxToPast)
        have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)
                trivial))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (boxToPast (Formula.box (Formula.box φ).neg))) h_box_box_neg
        exact int_chain_backward_H M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) h_neg h_H
    -- Box(¬(Box φ)) ∈ chain(t), so ¬(Box φ) ∈ chain(t) by modal_t
    have h_neg_box_t : (Formula.box φ).neg ∈ IntChain M₀ h₀ t :=
      SetMaximalConsistent.implication_property (int_chain_mcs M₀ h₀ t)
        (theorem_in_mcs (int_chain_mcs M₀ h₀ t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg) trivial))
        h_box_neg_t
    -- Contradiction: Box φ and ¬(Box φ) both in chain(t)
    exact set_consistent_not_both (int_chain_mcs M₀ h₀ t).1 (Formula.box φ) h_box_t h_neg_box_t
  · -- Forward: Box φ ∈ M₀ → Box φ ∈ chain(t)
    intro h_box_M0
    rcases lt_trichotomy 0 t with h_pos | rfl | h_neg
    · -- t > 0: use G propagation (temporalFutureDerived: □φ → G(□φ))
      have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (temporalFutureDerived φ)) h_box_M0
      exact int_chain_forward_G M₀ h₀ 0 t (Formula.box φ) h_pos h_G
    · -- t = 0: chain(0) = M₀
      rw [int_chain_zero]; exact h_box_M0
    · -- t < 0: use H propagation (modal_4: □φ → □□φ, boxToPast: □(□φ) → H(□φ))
      have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ) trivial)) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (boxToPast (Formula.box φ))) h_box_box
      exact int_chain_backward_H M₀ h₀ 0 t (Formula.box φ) h_neg h_H

/-- Box stability for shifted FMCS: Box φ ∈ (shiftedBxFmcs M₀ h₀ s).mcs t ↔ Box φ ∈ M₀. -/
theorem box_stable_in_shifted_fmcs (M₀ : Set Formula)
    (h₀ : SetMaximalConsistent (fc := FrameClass.Base) M₀)
    (φ : Formula) (s t : Int) :
    Formula.box φ ∈ (shiftedBxFmcs M₀ h₀ s).mcs t ↔ Formula.box φ ∈ M₀ :=
  box_stable_in_int_chain M₀ h₀ φ (t - s)

/-! ## FC-Parametric Chain Construction

The existing chain (FwdSucc, BwdPred, IntChain, etc.) is hardcoded to FrameClass.Base.
For completeness_discrete we need chains parametric over fc, since the BFMCS must be
typed at the same fc as the MCS input (e.g., FrameClass.Discrete).

The fc-parametric versions use:
- `forward_temporal_witness_seed_consistent` (fc-parametric, from WitnessSeed.lean)
- `past_temporal_witness_seed_consistent` (fc-parametric, from WitnessSeed.lean)
- fc-parametric GContent/HContent consistency (proved here from seed consistency)
- G/H propagation via `mcs_to_base` + existing Base-level theorems
-/

/-- GContent(M) is fc-consistent for any fc-MCS M.
Uses seriality (F(T) ∈ M) + forward_temporal_witness_seed_consistent. -/
theorem g_content_fc_consistent {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) :
    SetConsistent (fc := fc) (GContent M) := by
  have h_top : (Formula.bot.imp Formula.bot) ∈ M :=
    theorem_in_mcs h_mcs (identity Formula.bot)
  have h_F_top : Formula.someFuture (Formula.bot.imp Formula.bot) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_future trivial)) h_top
  have h_seed := forward_temporal_witness_seed_consistent M h_mcs _ h_F_top
  have h_sub : GContent M ⊆ ForwardTemporalWitnessSeed M (Formula.bot.imp Formula.bot) :=
    g_content_subset_forward_temporal_witness_seed M _
  intro L hL ⟨d⟩
  exact h_seed L (fun x hx => h_sub (hL x hx)) ⟨d⟩

/-- HContent(M) is fc-consistent for any fc-MCS M.
Uses seriality (P(T) ∈ M) + past_temporal_witness_seed_consistent. -/
theorem h_content_fc_consistent {fc : FrameClass} {M : Set Formula}
    (h_mcs : SetMaximalConsistent (fc := fc) M) :
    SetConsistent (fc := fc) (HContent M) := by
  have h_top : (Formula.bot.imp Formula.bot) ∈ M :=
    theorem_in_mcs h_mcs (identity Formula.bot)
  have h_P_top : Formula.somePast (Formula.bot.imp Formula.bot) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs
      (theorem_in_mcs h_mcs (DerivationTree.axiom [] _ Axiom.serial_past trivial)) h_top
  have h_seed := past_temporal_witness_seed_consistent M h_mcs _ h_P_top
  have h_sub : HContent M ⊆ PastTemporalWitnessSeed M (Formula.bot.imp Formula.bot) :=
    h_content_subset_past_temporal_witness_seed M _
  intro L hL ⟨d⟩
  exact h_seed L (fun x hx => h_sub (hL x hx)) ⟨d⟩

/-! ### FC-Parametric Forward/Backward Steps -/

/-- FC-parametric forward step. Builds successor MCS at fc from GContent(M).
If F(ψ) ∈ M, also resolves ψ. -/
noncomputable def FwdSuccFc {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula) :
    Set Formula := by
  by_cases h_F : Formula.someFuture ψ ∈ M
  · exact (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose
  · exact (set_lindenbaum (GContent M)
      (g_content_fc_consistent h_mcs)).choose

theorem fwd_succ_fc_mcs {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula) :
    SetMaximalConsistent (fc := fc) (FwdSuccFc M h_mcs ψ) := by
  unfold FwdSuccFc; split
  · exact (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (GContent M)
      (g_content_fc_consistent h_mcs)).choose_spec.2

theorem fwd_succ_fc_g_content {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula) :
    GContent M ⊆ FwdSuccFc M h_mcs ψ := by
  unfold FwdSuccFc; split
  · exact fun χ hχ => (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
      (forward_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (GContent M)
      (g_content_fc_consistent h_mcs)).choose_spec.1 hχ

theorem fwd_succ_fc_resolves {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula)
    (h_F : Formula.someFuture ψ ∈ M) : ψ ∈ FwdSuccFc M h_mcs ψ := by
  unfold FwdSuccFc; rw [dif_pos h_F]
  exact (set_lindenbaum (ForwardTemporalWitnessSeed M ψ)
    (forward_temporal_witness_seed_consistent M h_mcs ψ h_F)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-- FC-parametric backward step. -/
noncomputable def BwdPredFc {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula) :
    Set Formula := by
  by_cases h_P : Formula.somePast ψ ∈ M
  · exact (set_lindenbaum (PastTemporalWitnessSeed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose
  · exact (set_lindenbaum (HContent M)
      (h_content_fc_consistent h_mcs)).choose

theorem bwd_pred_fc_mcs {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula) :
    SetMaximalConsistent (fc := fc) (BwdPredFc M h_mcs ψ) := by
  unfold BwdPredFc; split
  · exact (set_lindenbaum (PastTemporalWitnessSeed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.2
  · exact (set_lindenbaum (HContent M)
      (h_content_fc_consistent h_mcs)).choose_spec.2

theorem bwd_pred_fc_h_content {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula) :
    HContent M ⊆ BwdPredFc M h_mcs ψ := by
  unfold BwdPredFc; split
  · exact fun χ hχ => (set_lindenbaum (PastTemporalWitnessSeed M ψ)
      (past_temporal_witness_seed_consistent M h_mcs ψ ‹_›)).choose_spec.1
      (Set.mem_union_right _ hχ)
  · exact fun χ hχ => (set_lindenbaum (HContent M)
      (h_content_fc_consistent h_mcs)).choose_spec.1 hχ

theorem bwd_pred_fc_resolves {fc : FrameClass}
    (M : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) M) (ψ : Formula)
    (h_P : Formula.somePast ψ ∈ M) : ψ ∈ BwdPredFc M h_mcs ψ := by
  unfold BwdPredFc; rw [dif_pos h_P]
  exact (set_lindenbaum (PastTemporalWitnessSeed M ψ)
    (past_temporal_witness_seed_consistent M h_mcs ψ h_P)).choose_spec.1
    (Set.mem_union_left _ (Set.mem_singleton ψ))

/-! ### FC-Parametric Chains -/

/-- Frame-class-parametric forward Henkin chain: `fwdChain` with the frame class `fc`
left free rather than fixed to `FrameClass.Base`. -/
noncomputable def fwdChainFc {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent (fc := fc) M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := fwdChainFc M₀ h₀ n
    ⟨FwdSuccFc M hM (schedule n), fwd_succ_fc_mcs M hM (schedule n)⟩

/-- Frame-class-parametric backward Henkin chain: `bwdChain` with the frame class `fc`
left free rather than fixed to `FrameClass.Base`. -/
noncomputable def bwdChainFc {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) :
    (n : Nat) → { M : Set Formula // SetMaximalConsistent (fc := fc) M }
  | 0 => ⟨M₀, h₀⟩
  | n + 1 =>
    let ⟨M, hM⟩ := bwdChainFc M₀ h₀ n
    ⟨BwdPredFc M hM (schedule n), bwd_pred_fc_mcs M hM (schedule n)⟩

/-- Frame-class-parametric ℤ-indexed chain: `IntChain` with the frame class `fc` left
free rather than fixed to `FrameClass.Base`. -/
noncomputable def IntChainFc {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) (t : Int) :
    Set Formula :=
  if t ≥ 0 then (fwdChainFc M₀ h₀ t.toNat).val
  else (bwdChainFc M₀ h₀ ((-t).toNat)).val

theorem int_chain_fc_zero {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) :
    IntChainFc M₀ h₀ 0 = M₀ := by simp [IntChainFc, fwdChainFc]

theorem int_chain_fc_mcs {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) (t : Int) :
    SetMaximalConsistent (fc := fc) (IntChainFc M₀ h₀ t) := by
  simp only [IntChainFc]; split
  · exact (fwdChainFc M₀ h₀ t.toNat).property
  · exact (bwdChainFc M₀ h₀ ((-t).toNat)).property

/-! ### FC-Parametric G/H Content Propagation

These proofs delegate to the Base-level versions via `mcs_to_base`, using the fact
that GContent and HContent are frame-class-independent (they only look at G/H
prefixes of formulas, not at derivability). -/

theorem fwd_chain_fc_g_content_step {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) (n : Nat) :
    GContent (fwdChainFc M₀ h₀ n).val ⊆ (fwdChainFc M₀ h₀ (n + 1)).val := by
  change GContent (fwdChainFc M₀ h₀ n).val ⊆
    (FwdSuccFc (fwdChainFc M₀ h₀ n).val (fwdChainFc M₀ h₀ n).property (schedule n))
  exact fwd_succ_fc_g_content _ _ _

theorem fwd_chain_fc_g_content_trans {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    {m n : Nat} (h : m < n) :
    GContent (fwdChainFc M₀ h₀ m).val ⊆ (fwdChainFc M₀ h₀ n).val := by
  induction n with
  | zero => exact absurd h (Nat.not_lt_zero m)
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le (Nat.lt_succ_iff.mp h) with rfl | h_lt
    · exact fwd_chain_fc_g_content_step M₀ h₀ m
    · intro φ hφ
      have h_GG := SetMaximalConsistent.all_future_all_future (fwdChainFc M₀ h₀ m).property hφ
      exact fwd_chain_fc_g_content_step M₀ h₀ n (ih h_lt h_GG)

theorem bwd_chain_fc_h_content_step {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) (n : Nat) :
    HContent (bwdChainFc M₀ h₀ n).val ⊆ (bwdChainFc M₀ h₀ (n + 1)).val := by
  change HContent (bwdChainFc M₀ h₀ n).val ⊆
    (BwdPredFc (bwdChainFc M₀ h₀ n).val (bwdChainFc M₀ h₀ n).property (schedule n))
  exact bwd_pred_fc_h_content _ _ _

theorem bwd_chain_fc_h_content_trans {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    {m n : Nat} (h : m < n) :
    HContent (bwdChainFc M₀ h₀ m).val ⊆ (bwdChainFc M₀ h₀ n).val := by
  induction n with
  | zero => exact absurd h (Nat.not_lt_zero m)
  | succ n ih =>
    rcases Nat.eq_or_lt_of_le (Nat.lt_succ_iff.mp h) with rfl | h_lt
    · exact bwd_chain_fc_h_content_step M₀ h₀ m
    · intro φ hφ
      have h_HH := SetMaximalConsistent.all_past_all_past (bwdChainFc M₀ h₀ m).property hφ
      exact bwd_chain_fc_h_content_step M₀ h₀ n (ih h_lt h_HH)

/-! ### FC-Parametric Reverse Content Propagation

The reverse propagation (GContent implies HContent reverse, and vice versa) uses
the Base-level `g_content_subset_implies_h_content_reverse`. We access it via `mcs_to_base`. -/

theorem fwd_chain_fc_reverse_h {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    {m n : Nat} (h : m < n) :
    HContent (fwdChainFc M₀ h₀ n).val ⊆ (fwdChainFc M₀ h₀ m).val :=
  g_content_subset_implies_h_content_reverse
    (fwdChainFc M₀ h₀ m).val (fwdChainFc M₀ h₀ n).val
    (Chronicle.mcs_to_base (fwdChainFc M₀ h₀ m).property)
    (Chronicle.mcs_to_base (fwdChainFc M₀ h₀ n).property)
    (fwd_chain_fc_g_content_trans M₀ h₀ h)

theorem bwd_chain_fc_reverse_g {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    {m n : Nat} (h : m < n) :
    GContent (bwdChainFc M₀ h₀ n).val ⊆ (bwdChainFc M₀ h₀ m).val :=
  h_content_subset_implies_g_content_reverse
    (bwdChainFc M₀ h₀ m).val (bwdChainFc M₀ h₀ n).val
    (Chronicle.mcs_to_base (bwdChainFc M₀ h₀ m).property)
    (Chronicle.mcs_to_base (bwdChainFc M₀ h₀ n).property)
    (bwd_chain_fc_h_content_trans M₀ h₀ h)

/-! ### FC-Parametric Int Chain G/H Propagation -/

theorem int_chain_fc_g_content {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    {t t' : Int} (h_lt : t < t') :
    GContent (IntChainFc M₀ h₀ t) ⊆ IntChainFc M₀ h₀ t' := by
  simp only [IntChainFc]
  split_ifs with ht ht'
  · exact fwd_chain_fc_g_content_trans M₀ h₀ (by omega)
  · omega
  · intro χ hχ
    have h_Gchi_in_bwd : Formula.allFuture χ ∈ (bwdChainFc M₀ h₀ ((-t).toNat)).val := hχ
    rcases Nat.eq_zero_or_pos t'.toNat with h_zero | h_pos
    · have h_chi_in_bwd0 : χ ∈ (bwdChainFc M₀ h₀ 0).val :=
        bwd_chain_fc_reverse_g M₀ h₀ (by omega) hχ
      simp only [bwdChainFc] at h_chi_in_bwd0
      simp only [h_zero, fwdChainFc]
      exact h_chi_in_bwd0
    · have h_GGchi := SetMaximalConsistent.all_future_all_future
        (bwdChainFc M₀ h₀ ((-t).toNat)).property h_Gchi_in_bwd
      have h_Gchi_in_bwd0 : Formula.allFuture χ ∈ (bwdChainFc M₀ h₀ 0).val :=
        bwd_chain_fc_reverse_g M₀ h₀ (by omega) h_GGchi
      simp only [bwdChainFc] at h_Gchi_in_bwd0
      exact fwd_chain_fc_g_content_trans M₀ h₀ h_pos h_Gchi_in_bwd0
  · exact bwd_chain_fc_reverse_g M₀ h₀ (by omega)

theorem int_chain_fc_forward_G {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    (t t' : Int) (φ : Formula) (h_lt : t < t')
    (h_G : Formula.allFuture φ ∈ IntChainFc M₀ h₀ t) :
    φ ∈ IntChainFc M₀ h₀ t' :=
  int_chain_fc_g_content M₀ h₀ h_lt h_G

theorem int_chain_fc_h_content {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    {t t' : Int} (h_lt : t < t') :
    HContent (IntChainFc M₀ h₀ t') ⊆ IntChainFc M₀ h₀ t :=
  g_content_subset_implies_h_content_reverse
    (IntChainFc M₀ h₀ t) (IntChainFc M₀ h₀ t')
    (Chronicle.mcs_to_base (int_chain_fc_mcs M₀ h₀ t))
    (Chronicle.mcs_to_base (int_chain_fc_mcs M₀ h₀ t'))
    (int_chain_fc_g_content M₀ h₀ h_lt)

theorem int_chain_fc_backward_H {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    (t t' : Int) (φ : Formula) (h_lt : t' < t)
    (h_H : Formula.allPast φ ∈ IntChainFc M₀ h₀ t) :
    φ ∈ IntChainFc M₀ h₀ t' :=
  int_chain_fc_h_content M₀ h₀ h_lt h_H

/-! ### FC-Parametric FMCS and Shifted FMCS -/

/-- Frame-class-parametric canonical `FMCS` on ℤ, built from `IntChainFc`. -/
noncomputable def bxFmcsFc {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) : FMCS (fc := fc) Int where
  mcs := IntChainFc M₀ h₀
  is_mcs := int_chain_fc_mcs M₀ h₀
  forward_G := int_chain_fc_forward_G M₀ h₀
  backward_H := int_chain_fc_backward_H M₀ h₀

/-- `bxFmcsFc` translated in time by `s`: the set at time `t` is the unshifted set at
`t - s`. Shifting is what makes the bundle of `henkinBfmcs` closed under time translation. -/
noncomputable def shiftedBxFmcsFc {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    (s : Int) : FMCS (fc := fc) Int where
  mcs t := IntChainFc M₀ h₀ (t - s)
  is_mcs t := int_chain_fc_mcs M₀ h₀ (t - s)
  forward_G t t' φ h_lt h_G := int_chain_fc_forward_G M₀ h₀ (t - s) (t' - s) φ (by omega) h_G
  backward_H t t' φ h_lt h_H := int_chain_fc_backward_H M₀ h₀ (t - s) (t' - s) φ (by omega) h_H

theorem shifted_bx_fmcs_fc_at_s {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀) (s : Int) :
    (shiftedBxFmcsFc M₀ h₀ s).mcs s = M₀ := by
  simp [shiftedBxFmcsFc, int_chain_fc_zero]

/-! ### FC-Parametric Box Stability -/

theorem box_stable_in_int_chain_fc {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    (φ : Formula) (t : Int) :
    Formula.box φ ∈ IntChainFc M₀ h₀ t ↔ Formula.box φ ∈ M₀ := by
  -- Delegate to the Base-level box_stable_in_int_chain pattern.
  -- The proof uses only temporalFutureDerived, modal_4, modal_t, negBoxToBoxNegBox,
  -- boxToPast — all Base axioms available at any fc.
  constructor
  · intro h_box_t
    by_contra h_not_box_M0
    have h_neg_box_M0 : (Formula.box φ).neg ∈ M₀ := by
      rcases SetMaximalConsistent.negation_complete h₀ (Formula.box φ) with h | h
      · exact absurd h h_not_box_M0
      · exact h
    have h_box_neg : Formula.box (Formula.box φ).neg ∈ M₀ :=
      SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (Chronicle.liftBase fc (negBoxToBoxNegBox φ))) h_neg_box_M0
    have h_box_neg_t : Formula.box (Formula.box φ).neg ∈ IntChainFc M₀ h₀ t := by
      rcases lt_trichotomy 0 t with h_pos | rfl | h_neg
      · have h_G := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (Chronicle.liftBase fc (temporalFutureDerived (Formula.box φ).neg)))
          h_box_neg
        exact int_chain_fc_forward_G M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) h_pos h_G
      · rw [int_chain_fc_zero]; exact h_box_neg
      · have h_box_box_neg : Formula.box (Formula.box (Formula.box φ).neg) ∈ M₀ :=
          SetMaximalConsistent.implication_property h₀
            (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 (Formula.box φ).neg)
                trivial))
            h_box_neg
        have h_H := SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (Chronicle.liftBase fc
              (boxToPast (Formula.box (Formula.box φ).neg)))) h_box_box_neg
        exact int_chain_fc_backward_H M₀ h₀ 0 t (Formula.box (Formula.box φ).neg) h_neg h_H
    have h_neg_box_t : (Formula.box φ).neg ∈ IntChainFc M₀ h₀ t :=
      SetMaximalConsistent.implication_property (int_chain_fc_mcs M₀ h₀ t)
        (theorem_in_mcs (int_chain_fc_mcs M₀ h₀ t)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg) trivial))
        h_box_neg_t
    exact set_consistent_not_both (int_chain_fc_mcs M₀ h₀ t).1 (Formula.box φ) h_box_t h_neg_box_t
  · intro h_box_M0
    rcases lt_trichotomy 0 t with h_pos | rfl | h_neg
    · have h_G := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (Chronicle.liftBase fc (temporalFutureDerived φ))) h_box_M0
      exact int_chain_fc_forward_G M₀ h₀ 0 t (Formula.box φ) h_pos h_G
    · rw [int_chain_fc_zero]; exact h_box_M0
    · have h_box_box : Formula.box (Formula.box φ) ∈ M₀ :=
        SetMaximalConsistent.implication_property h₀
          (theorem_in_mcs h₀ (DerivationTree.axiom [] _ (Axiom.modal_4 φ) trivial)) h_box_M0
      have h_H := SetMaximalConsistent.implication_property h₀
        (theorem_in_mcs h₀ (Chronicle.liftBase fc (boxToPast (Formula.box φ)))) h_box_box
      exact int_chain_fc_backward_H M₀ h₀ 0 t (Formula.box φ) h_neg h_H

theorem box_stable_in_shifted_fmcs_fc {fc : FrameClass}
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent (fc := fc) M₀)
    (φ : Formula) (s t : Int) :
    Formula.box φ ∈ (shiftedBxFmcsFc M₀ h₀ s).mcs t ↔ Formula.box φ ∈ M₀ :=
  box_stable_in_int_chain_fc M₀ h₀ φ (t - s)

/-! ## Henkin BFMCS on Int (Discrete Case)

Bundle of fc-parametric FMCS families on ℤ. Given an fc-MCS A with □(U(⊤,⊥)) ∈ A,
each family is `shiftedBxFmcsFc N h_N s` where N is box-equivalent to A.
This BFMCS is Z-native: the domain IS Int from the start, with no isomorphism
or chronicle indirection.
-/

/-- The Henkin bundle of frame-class-parametric `FMCS` families on ℤ, generated from an
fc-maximal-consistent set `A`: every family is `shiftedBxFmcsFc N h_N s` for some `N`
box-equivalent to `A` and some time shift `s`. Z-native — no chronicle indirection. -/
noncomputable def henkinBfmcs (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A) :
    BFMCS (fc := fc) ℤ where
  families := { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent (fc := fc) N)
    (s : ℤ),
    (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
    fam = shiftedBxFmcsFc N h_N s }
  nonempty := ⟨shiftedBxFmcsFc A h_mcs 0,
    A, h_mcs, 0, fun _ => Iff.rfl, rfl⟩
  modal_forward := by
    intro fam hfam φ t h_box fam' hfam'
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    obtain ⟨N', h_N', s', h_eqN', rfl⟩ := hfam'
    have h_box_in_N : Formula.box φ ∈ N :=
      (box_stable_in_shifted_fmcs_fc N h_N φ s t).mp h_box
    have h_box_A : Formula.box φ ∈ A := (h_eqN φ).mpr h_box_in_N
    have h_box_in_N' : Formula.box φ ∈ N' := (h_eqN' φ).mp h_box_A
    have h_box_t' : Formula.box φ ∈ (shiftedBxFmcsFc N' h_N' s').mcs t :=
      (box_stable_in_shifted_fmcs_fc N' h_N' φ s' t).mpr h_box_in_N'
    exact SetMaximalConsistent.implication_property
      ((shiftedBxFmcsFc N' h_N' s').is_mcs t)
      (theorem_in_mcs ((shiftedBxFmcsFc N' h_N' s').is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.modal_t φ) trivial)) h_box_t'
  modal_backward := by
    intro fam hfam φ t h_all
    obtain ⟨N, h_N, s, h_eqN, rfl⟩ := hfam
    suffices h_box_in_N : Formula.box φ ∈ N from
      (box_stable_in_shifted_fmcs_fc N h_N φ s t).mpr h_box_in_N
    suffices h_box_A : Formula.box φ ∈ A from (h_eqN φ).mp h_box_A
    by_contra h_not_box
    have h_neg_box : (Formula.box φ).neg ∈ A := by
      rcases SetMaximalConsistent.negation_complete h_mcs (Formula.box φ) with h | h
      · exact absurd h h_not_box
      · exact h
    have h_diamond_neg : (Formula.neg φ).diamond ∈ A :=
      SetMaximalConsistent.contrapositive h_mcs
        (Chronicle.liftBase fc (FormalSystem.Theorems.ModalDerived.boxDneTheorem φ)) h_neg_box
    obtain ⟨v, h_v_mcs, h_equiv, h_neg_phi_v⟩ := Chronicle.bx_modal_witness_fc h_mcs
        (Formula.neg φ) h_diamond_neg
    have h_fam_v_mem : shiftedBxFmcsFc v h_v_mcs t ∈
        { fam | ∃ (N : Set Formula) (h_N : SetMaximalConsistent (fc := fc) N)
          (s : ℤ),
          (∀ ψ, Formula.box ψ ∈ A ↔ Formula.box ψ ∈ N) ∧
          fam = shiftedBxFmcsFc N h_N s } :=
      ⟨v, h_v_mcs, t, fun ψ => h_equiv ψ, rfl⟩
    have h_phi_v := h_all (shiftedBxFmcsFc v h_v_mcs t) h_fam_v_mem
    rw [shifted_bx_fmcs_fc_at_s] at h_phi_v
    exact set_consistent_not_both h_v_mcs.1 φ h_phi_v h_neg_phi_v
  evalFamily := shiftedBxFmcsFc A h_mcs 0
  eval_family_mem := ⟨A, h_mcs, 0, fun _ => Iff.rfl, rfl⟩

end FormalSystem.Metalogic.BXCanonical
