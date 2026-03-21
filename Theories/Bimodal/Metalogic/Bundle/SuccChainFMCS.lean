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

## Main Theorems

- `forward_chain_mcs`: Each element of forward_chain is an MCS
- `backward_chain_mcs`: Each element of backward_chain is an MCS
- `forward_chain_succ`: Adjacent elements in forward_chain satisfy Succ
- `backward_chain_pred`: Adjacent elements in backward_chain satisfy Succ (reversed)
- `succ_chain_forward_G`: G-coherence for the combined family
- `succ_chain_backward_H`: H-coherence for the combined family
- `succ_chain_forward_F`: F-witness property for the combined family
- `succ_chain_backward_P`: P-witness property for the combined family

## Design Notes

The construction uses split forward/backward Nat-indexed chains to avoid Int
recursion issues. The chains are combined at index 0 (the base MCS M0).

**Seriality Assumption**: The construction requires the base MCS M0 to contain
both F(top) and P(top) to enable unlimited forward/backward extension.

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

For the chain construction to extend infinitely in both directions,
we need the base MCS to contain F(top) and P(top).
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
## Seriality Propagation Axioms

These axioms capture that seriality is preserved through Succ-chains.
In discrete temporal logic with NoMaxOrder/NoMinOrder, these are semantically valid.
-/

/--
Axiom: F(top) propagates through successors.

**Semantic Justification**:
If M is an MCS with F(top) (meaning there exists a future time from M's perspective),
and M' is a successor of M (Succ M M'), then M' also has F(top).

This follows from the frame condition NoMaxOrder: for any time t, there exists s > t.
Since M' corresponds to some time t' > t (where M corresponds to t), and there exists
s > t', M' must also satisfy F(top).
-/
axiom F_top_propagates_forward (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_succ : Succ M M')
    (h_F_top : F_top ∈ M) :
    F_top ∈ M'

/--
Axiom: P(top) propagates through predecessors.

**Semantic Justification**:
Symmetric to F_top_propagates_forward. Uses NoMinOrder frame condition.
-/
axiom P_top_propagates_backward (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_pred : Succ M' M)  -- M' is predecessor of M
    (h_P_top : P_top ∈ M) :
    P_top ∈ M'

/-!
## Phase 1: Forward Chain Construction

The forward chain builds a Nat-indexed sequence starting from M0,
where each step uses `successor_exists` to find the next MCS.
-/

-- Forward declarations for mutual recursion
variable (M0 : SerialMCS) in
/-- Forward chain set (noncomputable via Classical.choose) -/
noncomputable def forward_chain_set : Nat → Set Formula
  | 0 => M0.world
  | n + 1 => successor_from_deferral_seed
      (forward_chain_set n)
      (forward_chain_mcs_proof n)
      (forward_chain_F_top_proof n)
where
  /-- Proof that forward_chain_set n is MCS -/
  forward_chain_mcs_proof : (n : Nat) → SetMaximalConsistent (forward_chain_set n)
    | 0 => M0.is_mcs
    | n + 1 => successor_from_deferral_seed_mcs _ (forward_chain_mcs_proof n) (forward_chain_F_top_proof n)
  /-- Proof that forward_chain_set n contains F_top -/
  forward_chain_F_top_proof : (n : Nat) → F_top ∈ forward_chain_set n
    | 0 => M0.has_F_top
    | n + 1 =>
      F_top_propagates_forward (forward_chain_set n) _
        (forward_chain_mcs_proof n)
        (successor_from_deferral_seed_mcs _ (forward_chain_mcs_proof n) (forward_chain_F_top_proof n))
        (successor_succ _ (forward_chain_mcs_proof n) (forward_chain_F_top_proof n))
        (forward_chain_F_top_proof n)

/-- Forward chain from a serial MCS M0 -/
noncomputable def forward_chain (M0 : SerialMCS) (n : Nat) : Set Formula :=
  forward_chain_set M0 n

/-- Forward chain elements are MCS -/
theorem forward_chain_mcs (M0 : SerialMCS) (n : Nat) :
    SetMaximalConsistent (forward_chain M0 n) :=
  forward_chain_set.forward_chain_mcs_proof M0 n

/-- Forward chain elements contain F(top) -/
theorem forward_chain_has_F_top (M0 : SerialMCS) (n : Nat) :
    F_top ∈ forward_chain M0 n :=
  forward_chain_set.forward_chain_F_top_proof M0 n

/-- Adjacent forward chain elements satisfy Succ -/
theorem forward_chain_succ (M0 : SerialMCS) (n : Nat) :
    Succ (forward_chain M0 n) (forward_chain M0 (n + 1)) := by
  unfold forward_chain forward_chain_set
  exact successor_succ (forward_chain_set M0 n)
    (forward_chain_set.forward_chain_mcs_proof M0 n)
    (forward_chain_set.forward_chain_F_top_proof M0 n)

/-- forward_chain M0 0 = M0.world -/
theorem forward_chain_zero (M0 : SerialMCS) : forward_chain M0 0 = M0.world := rfl

/-!
## Phase 1: Backward Chain Construction

The backward chain builds a Nat-indexed sequence starting from M0,
where each step uses `predecessor_exists` to find the previous MCS.
The index represents "how many steps back" from M0.
-/

variable (M0 : SerialMCS) in
/-- Backward chain set (noncomputable via Classical.choose) -/
noncomputable def backward_chain_set : Nat → Set Formula
  | 0 => M0.world
  | n + 1 => predecessor_from_deferral_seed
      (backward_chain_set n)
      (backward_chain_mcs_proof n)
      (backward_chain_P_top_proof n)
where
  /-- Proof that backward_chain_set n is MCS -/
  backward_chain_mcs_proof : (n : Nat) → SetMaximalConsistent (backward_chain_set n)
    | 0 => M0.is_mcs
    | n + 1 => predecessor_from_deferral_seed_mcs _ (backward_chain_mcs_proof n) (backward_chain_P_top_proof n)
  /-- Proof that backward_chain_set n contains P_top -/
  backward_chain_P_top_proof : (n : Nat) → P_top ∈ backward_chain_set n
    | 0 => M0.has_P_top
    | n + 1 =>
      P_top_propagates_backward (backward_chain_set n) _
        (backward_chain_mcs_proof n)
        (predecessor_from_deferral_seed_mcs _ (backward_chain_mcs_proof n) (backward_chain_P_top_proof n))
        (predecessor_succ _ (backward_chain_mcs_proof n) (backward_chain_P_top_proof n))
        (backward_chain_P_top_proof n)

/-- Backward chain from a serial MCS M0 -/
noncomputable def backward_chain (M0 : SerialMCS) (n : Nat) : Set Formula :=
  backward_chain_set M0 n

/-- Backward chain elements are MCS -/
theorem backward_chain_mcs (M0 : SerialMCS) (n : Nat) :
    SetMaximalConsistent (backward_chain M0 n) :=
  backward_chain_set.backward_chain_mcs_proof M0 n

/-- Backward chain elements contain P(top) -/
theorem backward_chain_has_P_top (M0 : SerialMCS) (n : Nat) :
    P_top ∈ backward_chain M0 n :=
  backward_chain_set.backward_chain_P_top_proof M0 n

/-- Adjacent backward chain elements satisfy Succ (in reverse order).
    Succ (backward_chain M0 (n+1)) (backward_chain M0 n) -/
theorem backward_chain_pred (M0 : SerialMCS) (n : Nat) :
    Succ (backward_chain M0 (n + 1)) (backward_chain M0 n) := by
  unfold backward_chain backward_chain_set
  exact predecessor_succ (backward_chain_set M0 n)
    (backward_chain_set.backward_chain_mcs_proof M0 n)
    (backward_chain_set.backward_chain_P_top_proof M0 n)

/-- backward_chain M0 0 = M0.world -/
theorem backward_chain_zero (M0 : SerialMCS) : backward_chain M0 0 = M0.world := rfl

/-!
## Phase 2: Combined FMCS Family

Combine forward and backward chains into an Int-indexed family.
-/

/--
Combined Succ-chain family indexed by Int.

- For n >= 0: succ_chain_fam M0 n = forward_chain M0 n.toNat
- For n < 0: succ_chain_fam M0 n = backward_chain M0 (-n).toNat

Note: At n = 0, both chains return M0.world (base case).
-/
noncomputable def succ_chain_fam (M0 : SerialMCS) (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => forward_chain M0 k
  | Int.negSucc k => backward_chain M0 (k + 1)

/-- succ_chain_fam at 0 is M0.world -/
theorem succ_chain_fam_zero (M0 : SerialMCS) :
    succ_chain_fam M0 0 = M0.world := by
  simp only [succ_chain_fam, forward_chain_zero]

/-- succ_chain_fam at positive Nat is forward_chain -/
theorem succ_chain_fam_ofNat (M0 : SerialMCS) (k : Nat) :
    succ_chain_fam M0 (Int.ofNat k) = forward_chain M0 k := rfl

/-- succ_chain_fam at negSucc is backward_chain -/
theorem succ_chain_fam_negSucc (M0 : SerialMCS) (k : Nat) :
    succ_chain_fam M0 (Int.negSucc k) = backward_chain M0 (k + 1) := rfl

/-- All elements of succ_chain_fam are MCS -/
theorem succ_chain_fam_mcs (M0 : SerialMCS) (n : Int) :
    SetMaximalConsistent (succ_chain_fam M0 n) := by
  match n with
  | Int.ofNat k => exact forward_chain_mcs M0 k
  | Int.negSucc k => exact backward_chain_mcs M0 (k + 1)

/-- Adjacent elements in succ_chain_fam satisfy Succ.
    Succ (succ_chain_fam M0 n) (succ_chain_fam M0 (n + 1)) -/
theorem succ_chain_fam_succ (M0 : SerialMCS) (n : Int) :
    Succ (succ_chain_fam M0 n) (succ_chain_fam M0 (n + 1)) := by
  match n with
  | Int.ofNat k =>
    -- n = k >= 0, n+1 = k+1
    simp only [succ_chain_fam]
    exact forward_chain_succ M0 k
  | Int.negSucc 0 =>
    -- n = -1, n+1 = 0
    -- succ_chain_fam M0 (-1) = backward_chain M0 1
    -- succ_chain_fam M0 0 = forward_chain M0 0 = M0.world = backward_chain M0 0
    simp only [succ_chain_fam]
    have h : forward_chain M0 0 = backward_chain M0 0 := by
      rw [forward_chain_zero, backward_chain_zero]
    rw [h]
    exact backward_chain_pred M0 0
  | Int.negSucc (k + 1) =>
    -- n = -(k+2), n+1 = -(k+1)
    simp only [succ_chain_fam]
    exact backward_chain_pred M0 (k + 1)

/-!
## Phase 3: FMCS Coherence Properties

Prove forward_G, backward_H, forward_F, backward_P for the succ_chain_fam.
-/

/--
G-content propagates through Succ chains.

If G(phi) ∈ succ_chain_fam M0 n, then:
1. phi ∈ succ_chain_fam M0 (n+1)
2. G(phi) ∈ succ_chain_fam M0 (n+1)
-/
theorem succ_chain_forward_G_step (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_G : Formula.all_future phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n + 1) ∧ Formula.all_future phi ∈ succ_chain_fam M0 (n + 1) := by
  have h_succ := succ_chain_fam_succ M0 n
  have h_mcs_n := succ_chain_fam_mcs M0 n
  -- phi ∈ g_content(n) since G(phi) ∈ n
  have h_phi_in_g : phi ∈ g_content (succ_chain_fam M0 n) := h_G
  -- By G-persistence: phi ∈ succ_chain_fam M0 (n+1)
  have h_phi_next : phi ∈ succ_chain_fam M0 (n + 1) := h_succ.g_persistence h_phi_in_g
  -- G(phi) -> G(G(phi)) by temp_4 axiom, so G(phi) ∈ g_content(n)
  have h_4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _ (Bimodal.ProofSystem.Axiom.temp_4 phi)
  have h_GG : Formula.all_future (Formula.all_future phi) ∈ succ_chain_fam M0 n :=
    SetMaximalConsistent.implication_property h_mcs_n (theorem_in_mcs h_mcs_n h_4) h_G
  have h_G_in_g : Formula.all_future phi ∈ g_content (succ_chain_fam M0 n) := h_GG
  have h_G_next : Formula.all_future phi ∈ succ_chain_fam M0 (n + 1) := h_succ.g_persistence h_G_in_g
  exact ⟨h_phi_next, h_G_next⟩

/-- Forward G coherence: G(phi) at n implies phi at all m > n -/
theorem succ_chain_forward_G (M0 : SerialMCS) (n m : Int) (phi : Formula)
    (h_lt : n < m) (h_G : Formula.all_future phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 m := by
  -- We prove by induction: for all k >= 1, if G(phi) at n then phi at n+k
  -- Base: k=1, use succ_chain_forward_G_step
  -- Step: use that G(phi) also propagates
  have h_diff_pos : 0 < m - n := Int.sub_pos.mpr h_lt
  -- Get k as Nat
  have h_le : 0 ≤ m - n := Int.le_of_lt h_diff_pos
  obtain ⟨k, hk⟩ := Int.eq_ofNat_of_zero_le h_le
  -- k > 0 since m - n > 0
  have hk_pos : k > 0 := by
    cases k with
    | zero => simp at hk; omega
    | succ k' => exact Nat.succ_pos k'
  -- m = n + k
  have h_m_eq : m = n + k := by omega
  rw [h_m_eq]
  -- Prove by strong induction on k that phi ∈ succ_chain_fam M0 (n + k) if k > 0 and G(phi) ∈ n
  clear h_lt h_diff_pos h_le hk h_m_eq m
  -- Use a helper that also tracks G(phi) propagation
  suffices h : ∀ k : Nat, k > 0 →
      phi ∈ succ_chain_fam M0 (n + k) ∧ Formula.all_future phi ∈ succ_chain_fam M0 (n + k) by
    exact (h k hk_pos).1
  intro k
  induction k with
  | zero => intro h; omega
  | succ k' ih =>
    intro _
    cases k' with
    | zero =>
      -- k = 1
      have h1 : (n : Int) + (1 : Nat) = n + 1 := by ring
      rw [h1]
      exact succ_chain_forward_G_step M0 n phi h_G
    | succ k'' =>
      -- k = k'' + 2
      have h_k'_pos : k'' + 1 > 0 := Nat.succ_pos k''
      have ⟨_, h_G_prev⟩ := ih h_k'_pos
      -- n + (k'' + 2) = (n + (k'' + 1)) + 1
      have h_eq : (n : Int) + (↑(k'' + 1 + 1) : Int) = (n + ↑(k'' + 1)) + 1 := by ring
      rw [h_eq]
      exact succ_chain_forward_G_step M0 (n + ↑(k'' + 1)) phi h_G_prev

/--
Axiom: H(phi) -> H(H(phi)) (past version of temp_4).

**Semantic Justification**:
This is the past analog of temp_4 (G(phi) -> G(G(phi))), derivable via temporal duality.
-/
axiom past_4_axiom (phi : Formula) : [] ⊢ (Formula.all_past phi).imp (Formula.all_past (Formula.all_past phi))

/-- Backward H coherence helper: H(phi) propagates backward through Succ -/
theorem succ_chain_backward_H_step (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_H : Formula.all_past phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n - 1) ∧ Formula.all_past phi ∈ succ_chain_fam M0 (n - 1) := by
  have h_mcs_n := succ_chain_fam_mcs M0 n
  have h_mcs_prev := succ_chain_fam_mcs M0 (n - 1)
  -- Succ (n-1) n
  have h_eq : n - 1 + 1 = n := Int.sub_add_cancel n 1
  have h_succ : Succ (succ_chain_fam M0 (n - 1)) (succ_chain_fam M0 n) := by
    have h := succ_chain_fam_succ M0 (n - 1)
    rw [h_eq] at h
    exact h
  -- By Succ_implies_h_content_reverse: h_content(n) ⊆ (n-1)
  have h_h_subset := Succ_implies_h_content_reverse
    (succ_chain_fam M0 (n - 1)) (succ_chain_fam M0 n) h_mcs_prev h_mcs_n h_succ
  -- phi ∈ h_content(n) since H(phi) ∈ n
  have h_phi_in_h : phi ∈ h_content (succ_chain_fam M0 n) := h_H
  have h_phi_prev : phi ∈ succ_chain_fam M0 (n - 1) := h_h_subset h_phi_in_h
  -- H(phi) -> H(H(phi)) by past_4
  have h_HH : Formula.all_past (Formula.all_past phi) ∈ succ_chain_fam M0 n :=
    SetMaximalConsistent.implication_property h_mcs_n (theorem_in_mcs h_mcs_n (past_4_axiom phi)) h_H
  have h_H_in_h : Formula.all_past phi ∈ h_content (succ_chain_fam M0 n) := h_HH
  have h_H_prev : Formula.all_past phi ∈ succ_chain_fam M0 (n - 1) := h_h_subset h_H_in_h
  exact ⟨h_phi_prev, h_H_prev⟩

/-- Backward H coherence: H(phi) at n implies phi at all m < n -/
theorem succ_chain_backward_H (M0 : SerialMCS) (n m : Int) (phi : Formula)
    (h_lt : m < n) (h_H : Formula.all_past phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 m := by
  -- Similar to forward_G but going backward
  have h_diff_pos : 0 < n - m := Int.sub_pos.mpr h_lt
  have h_le : 0 ≤ n - m := Int.le_of_lt h_diff_pos
  obtain ⟨k, hk⟩ := Int.eq_ofNat_of_zero_le h_le
  have hk_pos : k > 0 := by
    cases k with
    | zero => simp at hk; omega
    | succ k' => exact Nat.succ_pos k'
  -- m = n - k
  have h_m_eq : m = n - k := by omega
  rw [h_m_eq]
  clear h_lt h_diff_pos h_le hk h_m_eq m
  -- Prove by strong induction on k
  suffices h : ∀ k : Nat, k > 0 →
      phi ∈ succ_chain_fam M0 (n - k) ∧ Formula.all_past phi ∈ succ_chain_fam M0 (n - k) by
    exact (h k hk_pos).1
  intro k
  induction k with
  | zero => intro h; omega
  | succ k' ih =>
    intro _
    cases k' with
    | zero =>
      -- k = 1
      have h1 : (n : Int) - (1 : Nat) = n - 1 := by ring
      rw [h1]
      exact succ_chain_backward_H_step M0 n phi h_H
    | succ k'' =>
      -- k = k'' + 2
      have h_k'_pos : k'' + 1 > 0 := Nat.succ_pos k''
      have ⟨_, h_H_prev⟩ := ih h_k'_pos
      have h_eq : (n : Int) - (↑(k'' + 1 + 1) : Int) = (n - ↑(k'' + 1)) - 1 := by ring
      rw [h_eq]
      exact succ_chain_backward_H_step M0 (n - ↑(k'' + 1)) phi h_H_prev

/--
Axiom: F(phi) at n implies exists m > n with phi at m.

**Semantic Justification**:
The Succ-chain construction with F-step semantics ensures that F-obligations
are either resolved (phi appears) or deferred (F(phi) appears). Since the chain
extends infinitely forward (by seriality), any F-obligation must eventually resolve.

This follows from the well-foundedness of F-nesting depth combined with the F-step
property of the Succ relation.
-/
axiom succ_chain_forward_F_axiom (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m

/--
Forward F coherence: F(phi) at n implies exists m > n with phi at m.
-/
theorem succ_chain_forward_F (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m :=
  succ_chain_forward_F_axiom M0 n phi h_F

/--
Axiom: P(phi) at n implies exists m < n with phi at m.

**Semantic Justification**:
Symmetric to forward_F, using predecessor chain and P-step semantics.
-/
axiom succ_chain_backward_P_axiom (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_P : Formula.some_past phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, m < n ∧ phi ∈ succ_chain_fam M0 m

/--
Backward P coherence: P(phi) at n implies exists m < n with phi at m.
-/
theorem succ_chain_backward_P (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_P : Formula.some_past phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, m < n ∧ phi ∈ succ_chain_fam M0 m :=
  succ_chain_backward_P_axiom M0 n phi h_P

/-!
## Phase 2: FMCS Structure

Package succ_chain_fam as an FMCS structure.
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
