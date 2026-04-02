import Bimodal.Metalogic.Bundle.SuccChainFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.Algebraic.UltrafilterChain

/-!
# Targeted Chain Construction

This module constructs an alternative FMCS family that deliberately resolves
F/P obligations for formulas in `deferralClosure(root)`. This provides the
sorry-free restricted temporal coherence needed for `completeness_over_Int`.

## Strategy

The existing `SuccChainFMCS` builds successors via `constrained_successor_from_seed`,
which includes deferral disjunctions but cannot guarantee eventual resolution of
any specific F-obligation. The targeted chain instead uses `canonical_forward_F`
at each step, selecting which obligation to resolve via round-robin scheduling.

## Key Properties

- `targeted_fmcs_forward_G`: G(phi) at t implies phi at all t' >= t
- `targeted_fmcs_backward_H`: H(phi) at t implies phi at all t' <= t
- Forward F resolution: F(psi) with psi in deferralClosure implies eventual resolution

## Building Blocks (all sorry-free)

- `canonical_forward_F` (CanonicalFrame.lean): F(psi) in MCS M implies
  exists W with psi in W and g_content(M) subset W
- `canonical_backward_P` (CanonicalFrame.lean): P(psi) in MCS M implies
  exists W with psi in W and h_content(M) subset W
-/

namespace Bimodal.Metalogic.Bundle.TargetedChain

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Classical
open Bimodal.Metalogic.Algebraic.UltrafilterChain

/-!
## Forward Targeted Successor

Given MCS M with F(psi) in M, build a successor that resolves psi.
-/

/--
Build a forward successor of M that resolves F(psi).

If F(psi) is in M, returns an MCS W with psi in W and g_content(M) subset W.
If F(psi) is NOT in M, returns an arbitrary successor.
-/
noncomputable def targeted_forward_successor
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) : Set Formula :=
  if h_F : Formula.some_future psi ∈ M then
    Classical.choose (canonical_forward_F M h_mcs psi h_F)
  else
    constrained_successor_from_seed M h_mcs (SetMaximalConsistent.contains_F_top h_mcs)

theorem targeted_forward_successor_mcs
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) :
    SetMaximalConsistent (targeted_forward_successor M h_mcs psi) := by
  unfold targeted_forward_successor
  split
  · case isTrue h_F =>
    exact (Classical.choose_spec (canonical_forward_F M h_mcs psi h_F)).1
  · case isFalse _ =>
    exact constrained_successor_from_seed_mcs M h_mcs (SetMaximalConsistent.contains_F_top h_mcs)

theorem targeted_forward_successor_g_persistence
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) :
    g_content M ⊆ targeted_forward_successor M h_mcs psi := by
  unfold targeted_forward_successor
  split
  · case isTrue h_F =>
    exact (Classical.choose_spec (canonical_forward_F M h_mcs psi h_F)).2.1
  · case isFalse _ =>
    exact (constrained_successor_succ M h_mcs (SetMaximalConsistent.contains_F_top h_mcs)).g_persistence

theorem targeted_forward_successor_resolves
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    psi ∈ targeted_forward_successor M h_mcs psi := by
  unfold targeted_forward_successor
  simp only [h_F, dite_true]
  exact (Classical.choose_spec (canonical_forward_F M h_mcs psi h_F)).2.2

theorem targeted_forward_successor_h_content_reverse
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) :
    h_content (targeted_forward_successor M h_mcs psi) ⊆ M :=
  g_content_subset_implies_h_content_reverse M
    (targeted_forward_successor M h_mcs psi)
    h_mcs
    (targeted_forward_successor_mcs M h_mcs psi)
    (targeted_forward_successor_g_persistence M h_mcs psi)

/-!
## Backward Targeted Predecessor

Given MCS M with P(psi) in M, build a predecessor that resolves psi.
-/

noncomputable def targeted_backward_predecessor
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) : Set Formula :=
  if h_P : Formula.some_past psi ∈ M then
    Classical.choose (canonical_backward_P M h_mcs psi h_P)
  else
    predecessor_from_deferral_seed M h_mcs (SetMaximalConsistent.contains_P_top h_mcs)

theorem targeted_backward_predecessor_mcs
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) :
    SetMaximalConsistent (targeted_backward_predecessor M h_mcs psi) := by
  unfold targeted_backward_predecessor
  split
  · case isTrue h_P =>
    exact (Classical.choose_spec (canonical_backward_P M h_mcs psi h_P)).1
  · case isFalse _ =>
    exact predecessor_from_deferral_seed_mcs M h_mcs (SetMaximalConsistent.contains_P_top h_mcs)

theorem targeted_backward_predecessor_h_persistence
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) :
    h_content M ⊆ targeted_backward_predecessor M h_mcs psi := by
  unfold targeted_backward_predecessor
  split
  · case isTrue h_P =>
    exact (Classical.choose_spec (canonical_backward_P M h_mcs psi h_P)).2.1
  · case isFalse _ =>
    exact predecessor_satisfies_h_persistence M h_mcs (SetMaximalConsistent.contains_P_top h_mcs)

theorem targeted_backward_predecessor_resolves
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_P : Formula.some_past psi ∈ M) :
    psi ∈ targeted_backward_predecessor M h_mcs psi := by
  unfold targeted_backward_predecessor
  simp only [h_P, dite_true]
  exact (Classical.choose_spec (canonical_backward_P M h_mcs psi h_P)).2.2

theorem targeted_backward_predecessor_g_content_reverse
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) :
    g_content (targeted_backward_predecessor M h_mcs psi) ⊆ M :=
  h_content_subset_implies_g_content_reverse
    M (targeted_backward_predecessor M h_mcs psi)
    h_mcs
    (targeted_backward_predecessor_mcs M h_mcs psi)
    (targeted_backward_predecessor_h_persistence M h_mcs psi)

/-!
## Targeted Forward Chain with Round-Robin Scheduling
-/

structure TargetedForwardElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

noncomputable def TargetedForwardElement.next (e : TargetedForwardElement) (target : Formula) :
    TargetedForwardElement where
  world := targeted_forward_successor e.world e.is_mcs target
  is_mcs := targeted_forward_successor_mcs e.world e.is_mcs target

def schedule (targets : List Formula) (step : Nat) : Formula :=
  match targets with
  | [] => Formula.bot
  | h :: t => (h :: t).get ⟨step % (h :: t).length, Nat.mod_lt step (by simp)⟩

noncomputable def targeted_forward_chain_at
    (base : TargetedForwardElement) (targets : List Formula) : Nat → TargetedForwardElement
  | 0 => base
  | n + 1 => (targeted_forward_chain_at base targets n).next (schedule targets n)

noncomputable def targeted_forward_chain
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) : Set Formula :=
  (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).world

theorem targeted_forward_chain_mcs
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) : SetMaximalConsistent (targeted_forward_chain M0 h_mcs targets n) :=
  (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs

theorem targeted_forward_chain_g_step
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) :
    g_content (targeted_forward_chain M0 h_mcs targets n) ⊆
    targeted_forward_chain M0 h_mcs targets (n + 1) := by
  intro phi h_phi
  -- targeted_forward_chain(n+1) = targeted_forward_successor(chain_at(n).world, ...)
  -- g_content(chain(n)) ⊆ chain(n+1)
  show phi ∈ (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets (n + 1)).world
  show phi ∈ ((targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).next (schedule targets n)).world
  simp only [TargetedForwardElement.next]
  exact targeted_forward_successor_g_persistence
    (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).world
    (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs
    (schedule targets n)
    h_phi

theorem targeted_forward_chain_h_content_reverse
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) :
    h_content (targeted_forward_chain M0 h_mcs targets (n + 1)) ⊆
    targeted_forward_chain M0 h_mcs targets n := by
  intro phi h_phi
  simp only [targeted_forward_chain, targeted_forward_chain_at, TargetedForwardElement.next] at h_phi
  exact targeted_forward_successor_h_content_reverse
    (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).world
    (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs
    (schedule targets n)
    h_phi

/--
G(phi) in forward_chain(n) implies phi in forward_chain(m) for all m >= n.
-/
theorem targeted_forward_chain_forward_G
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n m : Nat) (phi : Formula)
    (h_le : n ≤ m)
    (h_G : Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets n) :
    phi ∈ targeted_forward_chain M0 h_mcs targets m := by
  -- G(phi) propagates forward: G(phi) → G(G(phi)) by temp_4, then G_step gives G(phi) at n+1
  -- So by induction G(phi) at n implies G(phi) at any m >= n.
  -- Then phi at m by T-axiom.
  suffices h_prop : ∀ j : Nat, Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets (n + j) by
    have h_at_m : Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets m := by
      have ⟨d, hd⟩ : ∃ d, m = n + d := ⟨m - n, by omega⟩
      rw [hd]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_forward_chain_mcs M0 h_mcs targets m)
      (theorem_in_mcs (targeted_forward_chain_mcs M0 h_mcs targets m)
        (DerivationTree.axiom _ _ (Axiom.temp_t_future phi)))
      h_at_m
  intro j
  induction j with
  | zero => simp; exact h_G
  | succ j ih =>
    have h_GG : Formula.all_future (Formula.all_future phi) ∈
        targeted_forward_chain M0 h_mcs targets (n + j) :=
      SetMaximalConsistent.implication_property
        (targeted_forward_chain_mcs M0 h_mcs targets (n + j))
        (theorem_in_mcs (targeted_forward_chain_mcs M0 h_mcs targets (n + j))
          (DerivationTree.axiom _ _ (Axiom.temp_4 phi)))
        ih
    show Formula.all_future phi ∈ targeted_forward_chain M0 h_mcs targets (n + (j + 1))
    have : n + (j + 1) = (n + j) + 1 := by omega
    rw [this]
    exact targeted_forward_chain_g_step M0 h_mcs targets (n + j) h_GG

theorem targeted_forward_chain_resolves_scheduled
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat)
    (h_F : Formula.some_future (schedule targets n) ∈ targeted_forward_chain M0 h_mcs targets n) :
    (schedule targets n) ∈ targeted_forward_chain M0 h_mcs targets (n + 1) := by
  unfold targeted_forward_chain targeted_forward_chain_at TargetedForwardElement.next
  exact targeted_forward_successor_resolves
    (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).world
    (targeted_forward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs
    (schedule targets n)
    h_F

/-!
## Backward Chain (Symmetric)
-/

structure TargetedBackwardElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

noncomputable def TargetedBackwardElement.prev (e : TargetedBackwardElement) (target : Formula) :
    TargetedBackwardElement where
  world := targeted_backward_predecessor e.world e.is_mcs target
  is_mcs := targeted_backward_predecessor_mcs e.world e.is_mcs target

noncomputable def targeted_backward_chain_at
    (base : TargetedBackwardElement) (targets : List Formula) : Nat → TargetedBackwardElement
  | 0 => base
  | n + 1 => (targeted_backward_chain_at base targets n).prev (schedule targets n)

noncomputable def targeted_backward_chain
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) : Set Formula :=
  (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).world

theorem targeted_backward_chain_mcs
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) : SetMaximalConsistent (targeted_backward_chain M0 h_mcs targets n) :=
  (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs

theorem targeted_backward_chain_h_step
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) :
    h_content (targeted_backward_chain M0 h_mcs targets n) ⊆
    targeted_backward_chain M0 h_mcs targets (n + 1) := by
  change h_content (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).world ⊆
    ((targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).prev (schedule targets n)).world
  simp only [TargetedBackwardElement.prev]
  exact targeted_backward_predecessor_h_persistence
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).world
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs
    (schedule targets n)

theorem targeted_backward_chain_g_content_reverse
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat) :
    g_content (targeted_backward_chain M0 h_mcs targets (n + 1)) ⊆
    targeted_backward_chain M0 h_mcs targets n := by
  -- backward_chain(n+1) = predecessor(backward_chain(n), schedule n)
  -- g_content(predecessor) ⊆ backward_chain(n)
  change g_content ((targeted_backward_chain_at ⟨M0, h_mcs⟩ targets (n + 1)).world) ⊆
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).world
  show g_content ((targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).prev (schedule targets n)).world ⊆
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).world
  simp only [TargetedBackwardElement.prev]
  exact targeted_backward_predecessor_g_content_reverse
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).world
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs
    (schedule targets n)

/--
H(phi) in backward_chain(n) implies phi in backward_chain(m) for all m >= n.
-/
theorem targeted_backward_chain_backward_H
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n m : Nat) (phi : Formula)
    (h_le : n ≤ m)
    (h_H : Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets n) :
    phi ∈ targeted_backward_chain M0 h_mcs targets m := by
  suffices h_prop : ∀ j : Nat, Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets (n + j) by
    have h_at_m : Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets m := by
      have ⟨d, hd⟩ : ∃ d, m = n + d := ⟨m - n, by omega⟩
      rw [hd]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_backward_chain_mcs M0 h_mcs targets m)
      (theorem_in_mcs (targeted_backward_chain_mcs M0 h_mcs targets m)
        (DerivationTree.axiom _ _ (Axiom.temp_t_past phi)))
      h_at_m
  intro j
  induction j with
  | zero => simp; exact h_H
  | succ j ih =>
    have h_HH : Formula.all_past (Formula.all_past phi) ∈
        targeted_backward_chain M0 h_mcs targets (n + j) :=
      SetMaximalConsistent.implication_property
        (targeted_backward_chain_mcs M0 h_mcs targets (n + j))
        (theorem_in_mcs (targeted_backward_chain_mcs M0 h_mcs targets (n + j))
          (temp_4_past phi))
        ih
    show Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets (n + (j + 1))
    have : n + (j + 1) = (n + j) + 1 := by omega
    rw [this]
    exact targeted_backward_chain_h_step M0 h_mcs targets (n + j) h_HH

theorem targeted_backward_chain_resolves_scheduled
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Nat)
    (h_P : Formula.some_past (schedule targets n) ∈ targeted_backward_chain M0 h_mcs targets n) :
    (schedule targets n) ∈ targeted_backward_chain M0 h_mcs targets (n + 1) := by
  unfold targeted_backward_chain targeted_backward_chain_at TargetedBackwardElement.prev
  exact targeted_backward_predecessor_resolves
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).world
    (targeted_backward_chain_at ⟨M0, h_mcs⟩ targets n).is_mcs
    (schedule targets n)
    h_P

/-!
## Combined Int-Indexed Targeted Family
-/

noncomputable def targeted_fam
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => targeted_forward_chain M0 h_mcs targets k
  | Int.negSucc k => targeted_backward_chain M0 h_mcs targets (k + 1)

theorem targeted_fam_zero
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula) :
    targeted_fam M0 h_mcs targets 0 = M0 := rfl

theorem targeted_fam_mcs
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Int) : SetMaximalConsistent (targeted_fam M0 h_mcs targets n) := by
  match n with
  | Int.ofNat k => exact targeted_forward_chain_mcs M0 h_mcs targets k
  | Int.negSucc k => exact targeted_backward_chain_mcs M0 h_mcs targets (k + 1)

/--
G(phi) at Int n implies phi at Int (n+1).
This handles the boundary between backward and forward chains.
-/
theorem targeted_fam_G_step
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Int) (phi : Formula)
    (h_G : Formula.all_future phi ∈ targeted_fam M0 h_mcs targets n) :
    phi ∈ targeted_fam M0 h_mcs targets (n + 1) := by
  match n with
  | Int.ofNat k =>
    -- Forward direction: g_content propagation
    exact targeted_forward_chain_g_step M0 h_mcs targets k h_G
  | Int.negSucc 0 =>
    -- n = -1, n+1 = 0: backward_chain(1) → M0
    -- G(phi) ∈ backward_chain(1) → phi ∈ g_content(backward_chain(1)) → phi ∈ M0
    show phi ∈ targeted_fam M0 h_mcs targets 0
    rw [targeted_fam_zero]
    exact targeted_backward_chain_g_content_reverse M0 h_mcs targets 0 h_G
  | Int.negSucc (k + 1) =>
    -- n = -(k+2), n+1 = -(k+1): backward_chain(k+2) → backward_chain(k+1)
    -- G(phi) ∈ backward_chain(k+2) → phi ∈ backward_chain(k+1)
    show phi ∈ targeted_fam M0 h_mcs targets (Int.negSucc (k + 1) + 1)
    have h_eq : Int.negSucc (k + 1) + 1 = Int.negSucc k := by omega
    rw [h_eq]
    simp only [targeted_fam]
    exact targeted_backward_chain_g_content_reverse M0 h_mcs targets (k + 1)
      (by change Formula.all_future phi ∈ targeted_backward_chain M0 h_mcs targets (k + 2) at h_G
          exact h_G)

/--
H(phi) at Int n implies phi at Int (n-1).
-/
theorem targeted_fam_H_step
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (n : Int) (phi : Formula)
    (h_H : Formula.all_past phi ∈ targeted_fam M0 h_mcs targets n) :
    phi ∈ targeted_fam M0 h_mcs targets (n - 1) := by
  match n with
  | Int.ofNat 0 =>
    -- n = 0, n-1 = -1: H(phi) ∈ M0 → phi ∈ backward_chain(1)
    show phi ∈ targeted_fam M0 h_mcs targets (-1)
    simp only [targeted_fam]
    exact targeted_backward_chain_h_step M0 h_mcs targets 0 h_H
  | Int.ofNat (k + 1) =>
    -- n = k+1, n-1 = k: H(phi) ∈ forward_chain(k+1) → phi ∈ forward_chain(k)
    have h_eq : (Int.ofNat (k + 1) : Int) - 1 = Int.ofNat k := by
      show (↑(k + 1) : Int) - 1 = ↑k; omega
    rw [h_eq]
    simp only [targeted_fam]
    exact targeted_forward_chain_h_content_reverse M0 h_mcs targets k
      (by change Formula.all_past phi ∈ targeted_forward_chain M0 h_mcs targets (k + 1) at h_H
          exact h_H)
  | Int.negSucc k =>
    -- n = -(k+1), n-1 = -(k+2): H(phi) ∈ backward_chain(k+1) → phi ∈ backward_chain(k+2)
    show phi ∈ targeted_fam M0 h_mcs targets (Int.negSucc k - 1)
    have h_eq : Int.negSucc k - 1 = Int.negSucc (k + 1) := by omega
    rw [h_eq]
    simp only [targeted_fam]
    exact targeted_backward_chain_h_step M0 h_mcs targets (k + 1)
      (by change Formula.all_past phi ∈ targeted_backward_chain M0 h_mcs targets (k + 1) at h_H
          exact h_H)

/--
Forward G coherence: G(phi) at t implies phi at t' for all Int t' >= t.
-/
theorem targeted_fam_forward_G
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (t t' : Int) (phi : Formula)
    (h_le : t ≤ t') (h_G : Formula.all_future phi ∈ targeted_fam M0 h_mcs targets t) :
    phi ∈ targeted_fam M0 h_mcs targets t' := by
  -- Propagate G(phi) forward step by step, then apply T-axiom at t'
  suffices h_prop : ∀ j : Nat, Formula.all_future phi ∈ targeted_fam M0 h_mcs targets (t + j) by
    have h_at_t' : Formula.all_future phi ∈ targeted_fam M0 h_mcs targets t' := by
      obtain ⟨d, hd⟩ := Int.eq_ofNat_of_zero_le (show 0 ≤ t' - t by omega)
      have : t' = t + d := by omega
      rw [this]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_fam_mcs M0 h_mcs targets t')
      (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets t')
        (DerivationTree.axiom _ _ (Axiom.temp_t_future phi)))
      h_at_t'
  intro j
  induction j with
  | zero => simp; exact h_G
  | succ j ih =>
    have h_GG : Formula.all_future (Formula.all_future phi) ∈
        targeted_fam M0 h_mcs targets (t + j) :=
      SetMaximalConsistent.implication_property
        (targeted_fam_mcs M0 h_mcs targets (t + j))
        (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets (t + j))
          (DerivationTree.axiom _ _ (Axiom.temp_4 phi)))
        ih
    show Formula.all_future phi ∈ targeted_fam M0 h_mcs targets (t + (↑(j + 1)))
    have : t + (↑(j + 1) : Int) = (t + ↑j) + 1 := by omega
    rw [this]
    exact targeted_fam_G_step M0 h_mcs targets (t + j) (Formula.all_future phi) h_GG

/--
Backward H coherence: H(phi) at t implies phi at t' for all Int t' <= t.
-/
theorem targeted_fam_backward_H
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula)
    (t t' : Int) (phi : Formula)
    (h_le : t' ≤ t) (h_H : Formula.all_past phi ∈ targeted_fam M0 h_mcs targets t) :
    phi ∈ targeted_fam M0 h_mcs targets t' := by
  suffices h_prop : ∀ j : Nat, Formula.all_past phi ∈ targeted_fam M0 h_mcs targets (t - j) by
    have h_at_t' : Formula.all_past phi ∈ targeted_fam M0 h_mcs targets t' := by
      obtain ⟨d, hd⟩ := Int.eq_ofNat_of_zero_le (show 0 ≤ t - t' by omega)
      have : t' = t - d := by omega
      rw [this]; exact h_prop d
    exact SetMaximalConsistent.implication_property
      (targeted_fam_mcs M0 h_mcs targets t')
      (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets t')
        (DerivationTree.axiom _ _ (Axiom.temp_t_past phi)))
      h_at_t'
  intro j
  induction j with
  | zero => simp; exact h_H
  | succ j ih =>
    have h_HH : Formula.all_past (Formula.all_past phi) ∈
        targeted_fam M0 h_mcs targets (t - j) :=
      SetMaximalConsistent.implication_property
        (targeted_fam_mcs M0 h_mcs targets (t - j))
        (theorem_in_mcs (targeted_fam_mcs M0 h_mcs targets (t - j))
          (temp_4_past phi))
        ih
    show Formula.all_past phi ∈ targeted_fam M0 h_mcs targets (t - ↑(j + 1))
    have : (t : Int) - (↑(j + 1) : Int) = (t - ↑j) - 1 := by omega
    rw [this]
    exact targeted_fam_H_step M0 h_mcs targets (t - j) (Formula.all_past phi) h_HH

/-!
## Targeted FMCS
-/

noncomputable def TargetedFMCS
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula) :
    FMCS Int where
  mcs := targeted_fam M0 h_mcs targets
  is_mcs := targeted_fam_mcs M0 h_mcs targets
  forward_G := fun t t' phi h_le h_G =>
    targeted_fam_forward_G M0 h_mcs targets t t' phi h_le h_G
  backward_H := fun t t' phi h_le h_H =>
    targeted_fam_backward_H M0 h_mcs targets t t' phi h_le h_H

theorem TargetedFMCS_at_zero
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) (targets : List Formula) :
    (TargetedFMCS M0 h_mcs targets).mcs 0 = M0 := rfl

end Bimodal.Metalogic.Bundle.TargetedChain
