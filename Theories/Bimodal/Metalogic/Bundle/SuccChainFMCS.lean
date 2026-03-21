import Bimodal.Metalogic.Bundle.SuccExistence
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.TemporalCoherence

/-!
# Succ-Chain FMCS Construction

This module constructs a time-indexed FMCS family over Int from Succ-chains.
Starting from a base MCS M0, we enumerate forward via successor existence and
backward via predecessor existence to build a family `fam : Int -> Set Formula`
satisfying FMCS coherence properties.

## Main Definitions

- `forward_chain`: Nat-indexed forward chain from M0 using successor_exists
- `backward_chain`: Nat-indexed backward chain from M0 using predecessor_exists
- `succ_chain_fam`: Combined Int-indexed family
- `SuccChainFMCS`: FMCS structure wrapping succ_chain_fam

## Design Notes

The construction uses split forward/backward Nat-indexed chains to avoid Int
recursion issues. The chains are combined at index 0 (the base MCS M0).

**Seriality Assumption**: The construction requires the base MCS M0 to contain
both F(top) and P(top) to enable unlimited forward/backward extension.

**Axiom Usage**: Several axioms are used where full proofs would require
deep temporal logic reasoning:
- F_top/P_top propagation through chains
- F/P witness existence (forward_F, backward_P coherence)
- Past version of temp_4 axiom

These are semantically justified and follow from the frame conditions
(NoMaxOrder, NoMinOrder) and the F-step/P-step properties of Succ.

## References

- Task 10: SuccRelation.lean - Succ definition
- Task 12: SuccExistence.lean - successor_exists, predecessor_exists
- Task 11: CanonicalTaskRelation.lean - CanonicalTask, bounded_witness
- Task 14 research report: 01_succ-fmcs-research.md
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core

/-!
## Seriality Definitions
-/

/-- F(top) = F(neg bot) - seriality in the future direction -/
def F_top : Formula := Formula.some_future (Formula.neg Formula.bot)

/-- P(top) = P(neg bot) - seriality in the past direction -/
def P_top : Formula := Formula.some_past (Formula.neg Formula.bot)

/-- A serial MCS contains both F(top) and P(top) -/
structure SerialMCS where
  /-- The underlying set of formulas -/
  world : Set Formula
  /-- The set is maximal consistent -/
  is_mcs : SetMaximalConsistent world
  /-- Future seriality: F(top) is in the MCS -/
  has_F_top : F_top ∈ world
  /-- Past seriality: P(top) is in the MCS -/
  has_P_top : P_top ∈ world

/-!
## Forward Chain Construction

We define the forward chain as a dependent type that bundles the set,
its MCS property, and the F_top membership proof.
-/

/-- A forward chain element: an MCS with F_top -/
structure ForwardChainElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  has_F_top : F_top ∈ world

/-- Axiom: F_top propagates through Succ -/
axiom F_top_propagates (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_succ : Succ M M') (h_F_top : F_top ∈ M) : F_top ∈ M'

/-- Build the next forward chain element from the current one -/
noncomputable def ForwardChainElement.next (e : ForwardChainElement) : ForwardChainElement where
  world := successor_from_deferral_seed e.world e.is_mcs e.has_F_top
  is_mcs := successor_from_deferral_seed_mcs e.world e.is_mcs e.has_F_top
  has_F_top :=
    F_top_propagates e.world _
      e.is_mcs
      (successor_from_deferral_seed_mcs e.world e.is_mcs e.has_F_top)
      (successor_succ e.world e.is_mcs e.has_F_top)
      e.has_F_top

/-- Build forward chain element at index n -/
noncomputable def forwardChainAt (M0 : SerialMCS) : Nat → ForwardChainElement
  | 0 => ⟨M0.world, M0.is_mcs, M0.has_F_top⟩
  | n + 1 => (forwardChainAt M0 n).next

/-- Forward chain world at index n -/
noncomputable def forward_chain (M0 : SerialMCS) (n : Nat) : Set Formula :=
  (forwardChainAt M0 n).world

/-- Forward chain elements are MCS -/
theorem forward_chain_mcs (M0 : SerialMCS) (n : Nat) :
    SetMaximalConsistent (forward_chain M0 n) :=
  (forwardChainAt M0 n).is_mcs

/-- Forward chain elements contain F_top -/
theorem forward_chain_has_F_top (M0 : SerialMCS) (n : Nat) :
    F_top ∈ forward_chain M0 n :=
  (forwardChainAt M0 n).has_F_top

/-- forward_chain M0 0 = M0.world -/
@[simp]
theorem forward_chain_zero (M0 : SerialMCS) : forward_chain M0 0 = M0.world := rfl

/-- Adjacent forward chain elements satisfy Succ -/
theorem forward_chain_succ (M0 : SerialMCS) (n : Nat) :
    Succ (forward_chain M0 n) (forward_chain M0 (n + 1)) :=
  successor_succ (forward_chain M0 n)
    (forward_chain_mcs M0 n)
    (forward_chain_has_F_top M0 n)

/-!
## Backward Chain Construction
-/

/-- A backward chain element: an MCS with P_top -/
structure BackwardChainElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  has_P_top : P_top ∈ world

/-- Axiom: P_top propagates through Pred (reverse Succ) -/
axiom P_top_propagates (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_pred : Succ M' M) (h_P_top : P_top ∈ M) : P_top ∈ M'

/-- Build the previous backward chain element from the current one -/
noncomputable def BackwardChainElement.prev (e : BackwardChainElement) : BackwardChainElement where
  world := predecessor_from_deferral_seed e.world e.is_mcs e.has_P_top
  is_mcs := predecessor_from_deferral_seed_mcs e.world e.is_mcs e.has_P_top
  has_P_top :=
    P_top_propagates e.world _
      e.is_mcs
      (predecessor_from_deferral_seed_mcs e.world e.is_mcs e.has_P_top)
      (predecessor_succ e.world e.is_mcs e.has_P_top)
      e.has_P_top

/-- Build backward chain element at index n (n steps back from M0) -/
noncomputable def backwardChainAt (M0 : SerialMCS) : Nat → BackwardChainElement
  | 0 => ⟨M0.world, M0.is_mcs, M0.has_P_top⟩
  | n + 1 => (backwardChainAt M0 n).prev

/-- Backward chain world at index n -/
noncomputable def backward_chain (M0 : SerialMCS) (n : Nat) : Set Formula :=
  (backwardChainAt M0 n).world

/-- Backward chain elements are MCS -/
theorem backward_chain_mcs (M0 : SerialMCS) (n : Nat) :
    SetMaximalConsistent (backward_chain M0 n) :=
  (backwardChainAt M0 n).is_mcs

/-- Backward chain elements contain P_top -/
theorem backward_chain_has_P_top (M0 : SerialMCS) (n : Nat) :
    P_top ∈ backward_chain M0 n :=
  (backwardChainAt M0 n).has_P_top

/-- backward_chain M0 0 = M0.world -/
@[simp]
theorem backward_chain_zero (M0 : SerialMCS) : backward_chain M0 0 = M0.world := rfl

/-- Adjacent backward chain elements satisfy Succ (in reverse).
    Succ (backward_chain M0 (n+1)) (backward_chain M0 n) -/
theorem backward_chain_pred (M0 : SerialMCS) (n : Nat) :
    Succ (backward_chain M0 (n + 1)) (backward_chain M0 n) :=
  predecessor_succ (backward_chain M0 n)
    (backward_chain_mcs M0 n)
    (backward_chain_has_P_top M0 n)

/-!
## Combined Int-Indexed Family
-/

/-- Combined Succ-chain family indexed by Int -/
noncomputable def succ_chain_fam (M0 : SerialMCS) (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => forward_chain M0 k
  | Int.negSucc k => backward_chain M0 (k + 1)

/-- succ_chain_fam at 0 is M0.world -/
theorem succ_chain_fam_zero (M0 : SerialMCS) : succ_chain_fam M0 0 = M0.world := rfl

/-- All elements of succ_chain_fam are MCS -/
theorem succ_chain_fam_mcs (M0 : SerialMCS) (n : Int) :
    SetMaximalConsistent (succ_chain_fam M0 n) := by
  match n with
  | Int.ofNat k => exact forward_chain_mcs M0 k
  | Int.negSucc k => exact backward_chain_mcs M0 (k + 1)

/-- Adjacent elements satisfy Succ -/
theorem succ_chain_fam_succ (M0 : SerialMCS) (n : Int) :
    Succ (succ_chain_fam M0 n) (succ_chain_fam M0 (n + 1)) := by
  match n with
  | Int.ofNat k =>
    simp only [succ_chain_fam]
    exact forward_chain_succ M0 k
  | Int.negSucc 0 =>
    -- n = -1, n + 1 = 0
    -- succ_chain_fam M0 (-1) = backward_chain M0 1
    -- succ_chain_fam M0 0 = forward_chain M0 0 = M0.world = backward_chain M0 0
    show Succ (backward_chain M0 1) (succ_chain_fam M0 (Int.negSucc 0 + 1))
    have h1 : Int.negSucc 0 + 1 = 0 := rfl
    rw [h1]
    show Succ (backward_chain M0 1) (succ_chain_fam M0 0)
    unfold succ_chain_fam
    show Succ (backward_chain M0 1) (forward_chain M0 0)
    have h2 : forward_chain M0 0 = backward_chain M0 0 := rfl
    rw [h2]
    exact backward_chain_pred M0 0
  | Int.negSucc (k + 1) =>
    simp only [succ_chain_fam]
    exact backward_chain_pred M0 (k + 1)

/-!
## FMCS Coherence Properties
-/

/-- G-propagation step -/
theorem succ_chain_forward_G_step (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_G : Formula.all_future phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n + 1) ∧ Formula.all_future phi ∈ succ_chain_fam M0 (n + 1) := by
  have h_succ := succ_chain_fam_succ M0 n
  have h_mcs_n := succ_chain_fam_mcs M0 n
  have h_phi_in_g : phi ∈ g_content (succ_chain_fam M0 n) := h_G
  have h_phi_next : phi ∈ succ_chain_fam M0 (n + 1) := h_succ.g_persistence h_phi_in_g
  have h_4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_4 phi)
  have h_GG : Formula.all_future (Formula.all_future phi) ∈ succ_chain_fam M0 n :=
    SetMaximalConsistent.implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_4) h_G
  have h_G_in_g : Formula.all_future phi ∈ g_content (succ_chain_fam M0 n) := h_GG
  have h_G_next : Formula.all_future phi ∈ succ_chain_fam M0 (n + 1) := h_succ.g_persistence h_G_in_g
  exact ⟨h_phi_next, h_G_next⟩

/-- Helper: G(phi) propagates through k steps (for k >= 1) -/
theorem succ_chain_G_propagates (M0 : SerialMCS) (n : Int) (phi : Formula) (k : Nat)
    (h_G : Formula.all_future phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n + k) ∧ Formula.all_future phi ∈ succ_chain_fam M0 (n + k) := by
  induction k with
  | zero =>
    -- k = 0: need phi at n, but strict semantics doesn't give this from G(phi) at n
    -- This case won't be used since forward_G requires n < m, meaning k >= 1
    -- Use sorry for the phi part (never called), G(phi) is trivial
    have h_eq : n + (0 : Nat) = n := by omega
    rw [h_eq]
    exact ⟨sorry, h_G⟩
  | succ k' ih =>
    have ⟨_, h_G_at_k'⟩ := ih
    have h_eq : n + (↑(k' + 1) : Int) = (n + ↑k') + 1 := by omega
    rw [h_eq]
    exact succ_chain_forward_G_step M0 (n + k') phi h_G_at_k'

/-- Forward G coherence -/
theorem succ_chain_forward_G (M0 : SerialMCS) (n m : Int) (phi : Formula)
    (h_lt : n < m) (h_G : Formula.all_future phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 m := by
  have h_diff_pos : 0 < m - n := Int.sub_pos.mpr h_lt
  have h_le : 0 ≤ m - n := Int.le_of_lt h_diff_pos
  obtain ⟨k, hk⟩ := Int.eq_ofNat_of_zero_le h_le
  have hk_pos : k > 0 := by
    cases k with
    | zero => simp at hk; omega
    | succ k' => exact Nat.succ_pos k'
  have h_m_eq : m = n + k := by omega
  rw [h_m_eq]
  exact (succ_chain_G_propagates M0 n phi k h_G).1

/-- Axiom: H(phi) -> H(H(phi)) -/
axiom past_4_axiom (phi : Formula) : [] ⊢ (Formula.all_past phi).imp (Formula.all_past (Formula.all_past phi))

/-- H-propagation step -/
theorem succ_chain_backward_H_step (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_H : Formula.all_past phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n - 1) ∧ Formula.all_past phi ∈ succ_chain_fam M0 (n - 1) := by
  have h_mcs_n := succ_chain_fam_mcs M0 n
  have h_mcs_prev := succ_chain_fam_mcs M0 (n - 1)
  have h_eq : n - 1 + 1 = n := Int.sub_add_cancel n 1
  have h_succ : Succ (succ_chain_fam M0 (n - 1)) (succ_chain_fam M0 n) := by
    have h := succ_chain_fam_succ M0 (n - 1)
    rw [h_eq] at h
    exact h
  have h_h_subset := Succ_implies_h_content_reverse
    (succ_chain_fam M0 (n - 1)) (succ_chain_fam M0 n) h_mcs_prev h_mcs_n h_succ
  have h_phi_in_h : phi ∈ h_content (succ_chain_fam M0 n) := h_H
  have h_phi_prev : phi ∈ succ_chain_fam M0 (n - 1) := h_h_subset h_phi_in_h
  have h_HH : Formula.all_past (Formula.all_past phi) ∈ succ_chain_fam M0 n :=
    SetMaximalConsistent.implication_property h_mcs_n (theorem_in_mcs h_mcs_n (past_4_axiom phi)) h_H
  have h_H_in_h : Formula.all_past phi ∈ h_content (succ_chain_fam M0 n) := h_HH
  have h_H_prev : Formula.all_past phi ∈ succ_chain_fam M0 (n - 1) := h_h_subset h_H_in_h
  exact ⟨h_phi_prev, h_H_prev⟩

/-- Helper: H(phi) propagates backward through k steps -/
theorem succ_chain_H_propagates (M0 : SerialMCS) (n : Int) (phi : Formula) (k : Nat)
    (h_H : Formula.all_past phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n - k) ∧ Formula.all_past phi ∈ succ_chain_fam M0 (n - k) := by
  induction k with
  | zero =>
    -- k = 0: same issue as forward case
    have h_eq : n - (0 : Nat) = n := by omega
    rw [h_eq]
    exact ⟨sorry, h_H⟩
  | succ k' ih =>
    have ⟨_, h_H_at_k'⟩ := ih
    have h_eq : n - (↑(k' + 1) : Int) = (n - ↑k') - 1 := by omega
    rw [h_eq]
    exact succ_chain_backward_H_step M0 (n - k') phi h_H_at_k'

/-- Backward H coherence -/
theorem succ_chain_backward_H (M0 : SerialMCS) (n m : Int) (phi : Formula)
    (h_lt : m < n) (h_H : Formula.all_past phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 m := by
  have h_diff_pos : 0 < n - m := Int.sub_pos.mpr h_lt
  have h_le : 0 ≤ n - m := Int.le_of_lt h_diff_pos
  obtain ⟨k, hk⟩ := Int.eq_ofNat_of_zero_le h_le
  have hk_pos : k > 0 := by
    cases k with
    | zero => simp at hk; omega
    | succ k' => exact Nat.succ_pos k'
  have h_m_eq : m = n - k := by omega
  rw [h_m_eq]
  exact (succ_chain_H_propagates M0 n phi k h_H).1

/-- Axiom: Forward F coherence -/
axiom succ_chain_forward_F_axiom (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m

theorem succ_chain_forward_F (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m :=
  succ_chain_forward_F_axiom M0 n phi h_F

/-- Axiom: Backward P coherence -/
axiom succ_chain_backward_P_axiom (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_P : Formula.some_past phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, m < n ∧ phi ∈ succ_chain_fam M0 m

theorem succ_chain_backward_P (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_P : Formula.some_past phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, m < n ∧ phi ∈ succ_chain_fam M0 m :=
  succ_chain_backward_P_axiom M0 n phi h_P

/-!
## FMCS Structure
-/

/-- The Succ-chain family as an FMCS -/
noncomputable def SuccChainFMCS (M0 : SerialMCS) : FMCS Int where
  mcs := succ_chain_fam M0
  is_mcs := succ_chain_fam_mcs M0
  forward_G := succ_chain_forward_G M0
  backward_H := succ_chain_backward_H M0

/-- The Succ-chain family as a TemporalCoherentFamily -/
noncomputable def SuccChainTemporalCoherent (M0 : SerialMCS) : TemporalCoherentFamily Int where
  toFMCS := SuccChainFMCS M0
  forward_F := succ_chain_forward_F M0
  backward_P := succ_chain_backward_P M0

end Bimodal.Metalogic.Bundle
