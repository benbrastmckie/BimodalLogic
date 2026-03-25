import Bimodal.Metalogic.Bundle.SuccExistence
import Bimodal.Metalogic.Bundle.CanonicalTaskRelation
import Bimodal.Metalogic.Bundle.FMCSDef
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Core.RestrictedMCS

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

## Known Limitations (Task #55)

The `succ_chain_forward_F` and `succ_chain_backward_P` theorems depend on
`f_nesting_is_bounded` and `p_nesting_is_bounded`, which are **mathematically
FALSE** for arbitrary MCS. An MCS can contain {F^n(p) | n ∈ Nat} and still be
consistent - the formula nesting is unbounded.

**Status**: The deprecated theorems use sorry. The restricted versions
(`f_nesting_is_bounded_restricted`, etc.) work correctly for RestrictedMCS.

**Path Forward** (three options):
1. **Fair-scheduling chain**: Construct a different chain that enumerates and
   forces each F-obligation in turn, rather than deterministically choosing
   successors. This is the standard completeness technique.
2. **Bundle-level coherence**: Weaken temporal coherence to say phi appears
   in SOME family at SOME future time, rather than the SAME family. This
   requires propagating the change through BFMCS and truth evaluation.
3. **Restricted completeness**: Build the completeness proof using RestrictedMCS
   from the target formula's closure, where boundedness IS provable.

See `reports/10_team-research.md` for detailed analysis.

## References

- SuccRelation.lean - Succ definition
- SuccExistence.lean - successor_exists, predecessor_exists
- CanonicalTaskRelation.lean - CanonicalTask, bounded_witness
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

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
## Seriality Theorems

F_top and P_top are provable theorems in the discrete TM proof system (with seriality axioms).
This enables conversion from any MCS to SerialMCS.
-/

/-- neg bot (i.e., top) is a provable theorem. -/
noncomputable def neg_bot_theorem : [] ⊢ Formula.neg Formula.bot := by
  -- neg bot = bot -> bot, which is the identity on bot
  -- Use prop_s axiom: A -> (B -> A) instantiated with bot twice gives bot -> (bot -> bot)
  -- Then use identity: bot -> bot
  exact Bimodal.Theorems.Combinators.identity Formula.bot

/-- G(neg bot) is provable (by temporal necessitation on neg bot). -/
noncomputable def G_neg_bot_theorem : [] ⊢ Formula.all_future (Formula.neg Formula.bot) :=
  Bimodal.ProofSystem.DerivationTree.temporal_necessitation _ neg_bot_theorem

/-- H(neg bot) is provable (by past necessitation on neg bot). -/
noncomputable def H_neg_bot_theorem : [] ⊢ Formula.all_past (Formula.neg Formula.bot) :=
  Bimodal.Theorems.past_necessitation _ neg_bot_theorem

/-- F(neg bot) is provable using the seriality_future axiom: G(phi) -> F(phi).
    Instantiating with phi = neg bot and applying modus ponens with G_neg_bot_theorem. -/
noncomputable def F_top_theorem : [] ⊢ F_top := by
  unfold F_top
  -- seriality_future axiom: G(neg bot) -> F(neg bot)
  have h_serial : [] ⊢ (Formula.neg Formula.bot).all_future.imp
                        (Formula.neg Formula.bot).some_future :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.seriality_future (Formula.neg Formula.bot))
  exact Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_serial G_neg_bot_theorem

/-- P(neg bot) is provable using the seriality_past axiom: H(phi) -> P(phi).
    Instantiating with phi = neg bot and applying modus ponens with H_neg_bot_theorem. -/
noncomputable def P_top_theorem : [] ⊢ P_top := by
  unfold P_top
  -- seriality_past axiom: H(neg bot) -> P(neg bot)
  have h_serial : [] ⊢ (Formula.neg Formula.bot).all_past.imp
                        (Formula.neg Formula.bot).some_past :=
    Bimodal.ProofSystem.DerivationTree.axiom [] _
      (Bimodal.ProofSystem.Axiom.seriality_past (Formula.neg Formula.bot))
  exact Bimodal.ProofSystem.DerivationTree.modus_ponens [] _ _ h_serial H_neg_bot_theorem

/-- Every MCS contains F_top because F_top is a theorem.
    Theorems are in every MCS by closure under derivation. -/
theorem SetMaximalConsistent.contains_F_top {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) : F_top ∈ M :=
  theorem_in_mcs h_mcs F_top_theorem

/-- Every MCS contains P_top because P_top is a theorem.
    Theorems are in every MCS by closure under derivation. -/
theorem SetMaximalConsistent.contains_P_top {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) : P_top ∈ M :=
  theorem_in_mcs h_mcs P_top_theorem

/-- Convert any MCS to a SerialMCS.
    This is possible because F_top and P_top are theorems, hence in every MCS. -/
noncomputable def MCS_to_SerialMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) : SerialMCS where
  world := M
  is_mcs := h_mcs
  has_F_top := SetMaximalConsistent.contains_F_top h_mcs
  has_P_top := SetMaximalConsistent.contains_P_top h_mcs

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

/-- F_top propagates through Succ because F_top is a theorem in serial TM logic.
    Any MCS contains all theorems, so F_top ∈ M' automatically. -/
theorem F_top_propagates (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_succ : Succ M M') (h_F_top : F_top ∈ M) : F_top ∈ M' :=
  -- F_top is a theorem, and theorems are in every MCS
  SetMaximalConsistent.contains_F_top h_mcs'

/-- Build the next forward chain element from the current one.

Uses `constrained_successor_from_seed` instead of `successor_from_deferral_seed`
to ensure the P-step property: p_content(successor) ⊆ u ∪ p_content(u).
-/
noncomputable def ForwardChainElement.next (e : ForwardChainElement) : ForwardChainElement where
  world := constrained_successor_from_seed e.world e.is_mcs e.has_F_top
  is_mcs := constrained_successor_from_seed_mcs e.world e.is_mcs e.has_F_top
  has_F_top :=
    F_top_propagates e.world _
      e.is_mcs
      (constrained_successor_from_seed_mcs e.world e.is_mcs e.has_F_top)
      (constrained_successor_succ e.world e.is_mcs e.has_F_top)
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
  constrained_successor_succ (forward_chain M0 n)
    (forward_chain_mcs M0 n)
    (forward_chain_has_F_top M0 n)

/-- P-step property for forward chain: p_content of index k+1 flows back to index k.
    p_content(forward_chain M0 (k+1)) ⊆ forward_chain M0 k ∪ p_content(forward_chain M0 k)

    This follows from successor_p_step since forward_chain (k+1) is built as the
    constrained successor of forward_chain k.
-/
theorem forward_chain_p_step (M0 : SerialMCS) (k : Nat) :
    p_content (forward_chain M0 (k + 1)) ⊆
    forward_chain M0 k ∪ p_content (forward_chain M0 k) :=
  successor_p_step (forward_chain M0 k) (forward_chain_mcs M0 k) (forward_chain_has_F_top M0 k)

/-!
## Backward Chain Construction
-/

/-- A backward chain element: an MCS with P_top -/
structure BackwardChainElement where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  has_P_top : P_top ∈ world

/-- P_top propagates through Pred because P_top is a theorem in serial TM logic.
    Any MCS contains all theorems, so P_top ∈ M' automatically. -/
theorem P_top_propagates (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_pred : Succ M' M) (h_P_top : P_top ∈ M) : P_top ∈ M' :=
  -- P_top is a theorem, and theorems are in every MCS
  SetMaximalConsistent.contains_P_top h_mcs'

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

/-- P-step property for backward chain: p_content of index n flows to index n+1.
    p_content(backward_chain n) ⊆ (backward_chain n+1) ∪ p_content(backward_chain n+1)

    This follows from predecessor_satisfies_p_step since backward_chain (n+1) is built
    as the predecessor of backward_chain n.
-/
theorem backward_chain_p_step (M0 : SerialMCS) (n : Nat) :
    p_content (backward_chain M0 n) ⊆
    (backward_chain M0 (n + 1)) ∪ p_content (backward_chain M0 (n + 1)) :=
  predecessor_satisfies_p_step (backward_chain M0 n)
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

/--
P-step property for succ_chain_fam: p_content flows backward.

If Succ (succ_chain_fam M0 n) (succ_chain_fam M0 (n+1)), then
p_content(succ_chain_fam M0 (n+1)) ⊆ (succ_chain_fam M0 n) ∪ p_content(succ_chain_fam M0 n)

**Semantic Justification**:
In a discrete linear frame, P(φ) at world v with predecessor u means φ must hold
at u or at some world before u. This is captured by the P-step condition.

For backward_chain elements, this follows from predecessor_satisfies_p_step.
For forward_chain elements, this follows from the temporal duality:
- The successor construction ensures F-obligations propagate forward
- By duality, P-obligations must be satisfiable backward
- The succ_chain is symmetric with respect to temporal direction

**Note**: For backward chain elements (n < -1), this follows from `backward_chain_p_step`.
For forward chain elements (n >= 0), this requires proving that the successor construction
satisfies P-step, which follows from temporal duality but requires additional infrastructure.
The boundary case (n = -1) requires showing P-step from backward_chain 1 to M0.world.

For now, we prove the backward cases and leave forward cases as admitted pending
the `successor_satisfies_p_step` infrastructure.
-/
theorem succ_chain_fam_p_step (M0 : SerialMCS) (n : Int) :
    p_content (succ_chain_fam M0 (n + 1)) ⊆
    (succ_chain_fam M0 n) ∪ p_content (succ_chain_fam M0 n) := by
  intro φ h_φ
  cases n with
  | ofNat k =>
    -- n >= 0: forward chain case (k+1 -> k)
    -- P-step: p_content(forward_chain M0 (k+1)) ⊆ forward_chain M0 k ∪ p_content(forward_chain M0 k)
    -- Now that forward_chain uses constrained_successor_from_seed, we have P-step by construction.
    simp only [succ_chain_fam] at h_φ ⊢
    exact forward_chain_p_step M0 k h_φ
  | negSucc k =>
    cases k with
    | zero =>
      -- n = -1: succ_chain_fam 0 = M0.world, succ_chain_fam (-1) = backward_chain 1
      -- P-step: p_content(M0.world) ⊆ backward_chain 1 ∪ p_content(backward_chain 1)
      -- Note: M0.world = backward_chain 0 = forward_chain 0, so this is backward_chain_p_step M0 0
      show φ ∈ backward_chain M0 1 ∪ p_content (backward_chain M0 1)
      have h : Int.negSucc 0 + 1 = (0 : Int) := by native_decide
      simp only [h] at h_φ
      simp only [succ_chain_fam] at h_φ
      have h_eq : forward_chain M0 0 = backward_chain M0 0 := rfl
      rw [h_eq] at h_φ
      exact backward_chain_p_step M0 0 h_φ
    | succ k' =>
      -- n = -(k'+2): succ_chain_fam (n+1) = backward_chain (k'+1)
      -- succ_chain_fam n = backward_chain (k'+2)
      -- P-step: p_content(backward_chain (k'+1)) ⊆ backward_chain (k'+2) ∪ p_content(backward_chain (k'+2))
      simp only [succ_chain_fam] at h_φ ⊢
      exact backward_chain_p_step M0 (k' + 1) h_φ

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

/-- Helper: G(phi) propagates through k+1 steps -/
theorem succ_chain_G_propagates_succ (M0 : SerialMCS) (n : Int) (phi : Formula) (k : Nat)
    (h_G : Formula.all_future phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n + (k + 1)) ∧ Formula.all_future phi ∈ succ_chain_fam M0 (n + (k + 1)) := by
  induction k generalizing n with
  | zero =>
    -- k = 0, so we need to show result for n + 1
    have h_eq : n + ((0 : Nat) + 1) = n + 1 := by omega
    rw [h_eq]
    exact succ_chain_forward_G_step M0 n phi h_G
  | succ k' ih =>
    -- k = k' + 1, so we need result for n + (k' + 2)
    have h_eq : n + (↑(k' + 1) + 1) = (n + 1) + (↑k' + 1) := by omega
    rw [h_eq]
    -- Get G(phi) at n + 1 from the step
    have ⟨_, h_G_next⟩ := succ_chain_forward_G_step M0 n phi h_G
    -- Apply induction hypothesis with n + 1
    exact ih (n + 1) h_G_next

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
  -- k > 0 means k = j + 1 for some j
  obtain ⟨j, hj⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hk_pos)
  have h_m_eq : m = n + (j + 1) := by omega
  rw [h_m_eq]
  exact (succ_chain_G_propagates_succ M0 n phi j h_G).1

/-- H(phi) -> H(H(phi)) - derivable via temporal duality from temp_4.

This was previously an axiom but is now proven via temp_4_past in MCSProperties.lean.
-/
noncomputable def past_4_theorem (phi : Formula) : [] ⊢ (Formula.all_past phi).imp (Formula.all_past (Formula.all_past phi)) :=
  temp_4_past phi

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
    SetMaximalConsistent.implication_property h_mcs_n (theorem_in_mcs h_mcs_n (past_4_theorem phi)) h_H
  have h_H_in_h : Formula.all_past phi ∈ h_content (succ_chain_fam M0 n) := h_HH
  have h_H_prev : Formula.all_past phi ∈ succ_chain_fam M0 (n - 1) := h_h_subset h_H_in_h
  exact ⟨h_phi_prev, h_H_prev⟩

/-- Helper: H(phi) propagates backward through k+1 steps -/
theorem succ_chain_H_propagates_succ (M0 : SerialMCS) (n : Int) (phi : Formula) (k : Nat)
    (h_H : Formula.all_past phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 (n - (k + 1)) ∧ Formula.all_past phi ∈ succ_chain_fam M0 (n - (k + 1)) := by
  induction k generalizing n with
  | zero =>
    -- k = 0, so we need to show result for n - 1
    have h_eq : n - ((0 : Nat) + 1) = n - 1 := by omega
    rw [h_eq]
    exact succ_chain_backward_H_step M0 n phi h_H
  | succ k' ih =>
    -- k = k' + 1, so we need result for n - (k' + 2)
    have h_eq : n - (↑(k' + 1) + 1) = (n - 1) - (↑k' + 1) := by omega
    rw [h_eq]
    -- Get H(phi) at n - 1 from the step
    have ⟨_, h_H_prev⟩ := succ_chain_backward_H_step M0 n phi h_H
    -- Apply induction hypothesis with n - 1
    exact ih (n - 1) h_H_prev

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
  -- k > 0 means k = j + 1 for some j
  obtain ⟨j, hj⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.pos_iff_ne_zero.mp hk_pos)
  have h_m_eq : m = n - (j + 1) := by omega
  rw [h_m_eq]
  exact (succ_chain_H_propagates_succ M0 n phi j h_H).1

/-!
## Forward Chain to CanonicalTask_forward_MCS

Build the connection between forward_chain and CanonicalTask_forward_MCS
needed for bounded_witness application.
-/

/-- Helper: Build CanonicalTask_forward_MCS from a starting position in the forward chain. -/
theorem forward_chain_canonicalTask_forward_MCS_from (M0 : SerialMCS) (start : Nat) (n : Nat) :
    CanonicalTask_forward_MCS (forward_chain M0 start) n (forward_chain M0 (start + n)) := by
  induction n generalizing start with
  | zero =>
    simp only [Nat.add_zero]
    exact CanonicalTask_forward_MCS.base (forward_chain_mcs M0 start)
  | succ k ih =>
    -- Chain from start to (start + k + 1) of length (k + 1)
    -- = Succ at start, then chain from (start+1) to (start + k + 1) of length k
    have h_mcs_start := forward_chain_mcs M0 start
    have h_mcs_start1 := forward_chain_mcs M0 (start + 1)
    have h_succ := forward_chain_succ M0 start
    have h_eq : start + (k + 1) = (start + 1) + k := by omega
    rw [h_eq]
    exact CanonicalTask_forward_MCS.step h_mcs_start h_mcs_start1 h_succ (ih (start + 1))

/-- Build CanonicalTask_forward_MCS chain from forward_chain starting at 0.
    This connects the forward chain to the bounded_witness theorem. -/
theorem forward_chain_canonicalTask_forward_MCS (M0 : SerialMCS) (n : Nat) :
    CanonicalTask_forward_MCS (forward_chain M0 0) n (forward_chain M0 n) := by
  have h := forward_chain_canonicalTask_forward_MCS_from M0 0 n
  simp only [Nat.zero_add] at h
  exact h

/-- Build CanonicalTask_forward_MCS from any index in the succ_chain_fam.
    This generalizes forward_chain_canonicalTask_forward_MCS_from to Int indices. -/
theorem succ_chain_canonicalTask_forward_MCS_from (M0 : SerialMCS) (start : Int) (n : Nat) :
    CanonicalTask_forward_MCS (succ_chain_fam M0 start) n (succ_chain_fam M0 (start + n)) := by
  induction n generalizing start with
  | zero =>
    -- start + ↑0 = start
    have h_eq : start + ((0 : Nat) : Int) = start := Int.add_zero start
    rw [h_eq]
    exact CanonicalTask_forward_MCS.base (succ_chain_fam_mcs M0 start)
  | succ k ih =>
    have h_mcs_start := succ_chain_fam_mcs M0 start
    have h_mcs_start1 := succ_chain_fam_mcs M0 (start + 1)
    have h_succ := succ_chain_fam_succ M0 start
    have h_eq : start + (k + 1 : Nat) = (start + 1) + (k : Nat) := by omega
    rw [h_eq]
    exact CanonicalTask_forward_MCS.step h_mcs_start h_mcs_start1 h_succ (ih (start + 1))

/-!
## Backward Chain to CanonicalTask_backward_MCS_P

Build the connection between backward_chain and CanonicalTask_backward_MCS_P
needed for backward_witness application (P coherence).
-/

/-- Build CanonicalTask_backward_MCS_P from backward_chain elements.
    This connects the backward chain to the backward_witness theorem.

    backward_chain M0 n is n steps back from M0.world.
    backward_chain M0 (start + n) is n steps further back from backward_chain M0 start.
-/
theorem backward_chain_canonicalTask_backward_MCS_P (M0 : SerialMCS) (start n : Nat) :
    CanonicalTask_backward_MCS_P (backward_chain M0 (start + n)) n (backward_chain M0 start) := by
  induction n generalizing start with
  | zero =>
    simp only [Nat.add_zero]
    exact CanonicalTask_backward_MCS_P.base (backward_chain_mcs M0 start)
  | succ k ih =>
    -- backward_chain M0 (start + (k+1)) is (k+1) steps back from backward_chain M0 start
    -- = 1 step back from backward_chain M0 (start + k), then k steps to backward_chain M0 start
    have h_mcs_plus := backward_chain_mcs M0 (start + (k + 1))
    have h_mcs_k := backward_chain_mcs M0 (start + k)
    have h_succ := backward_chain_pred M0 (start + k)
    have h_p_step := backward_chain_p_step M0 (start + k)
    have h_eq : start + (k + 1) = (start + k) + 1 := by omega
    rw [h_eq]
    exact CanonicalTask_backward_MCS_P.step h_mcs_plus h_mcs_k h_succ h_p_step (ih start)

/-!
## Forward F Coherence via single_step_forcing and bounded_witness

The key insight: F(phi) in mcs implies either:
1. FF(phi) is not in mcs -> single_step_forcing gives witness at next step
2. FF(phi) is in mcs -> we need bounded_witness with the appropriate nesting depth

For the general case, we use single_step_forcing which handles F(phi) with FF(phi) not in mcs.
The bounded_witness case requires finding the F-nesting boundary.
-/

/--
Helper lemma: iter_F d (F phi) = iter_F (d+1) phi

This relates F-nesting of F(phi) to F-nesting of phi with one more layer.
-/
theorem iter_F_shift (d : Nat) (phi : Formula) :
    iter_F d (Formula.some_future phi) = iter_F (d + 1) phi := by
  induction d with
  | zero => rfl
  | succ k ih =>
    -- iter_F (k+1) (F phi) = F(iter_F k (F phi)) = F(iter_F (k+1) phi) = iter_F (k+2) phi
    calc iter_F (k + 1) (Formula.some_future phi)
        = Formula.some_future (iter_F k (Formula.some_future phi)) := rfl
      _ = Formula.some_future (iter_F (k + 1) phi) := by rw [ih]
      _ = iter_F (k + 2) phi := rfl

/--
F-nesting boundary (with explicit boundedness): Given F(phi) ∈ M and existence of
some n where iter_F n phi ∉ M, there exists d ≥ 1 such that iter_F d phi ∈ M
and iter_F (d+1) phi ∉ M.

This is the core lemma that extracts the boundary using Nat.find.
-/
theorem f_nesting_boundary_of_bounded
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M)
    (h_bounded : ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M) :  -- Strengthened: n ≥ 2
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ M ∧ iter_F (d + 1) phi ∉ M := by
  classical
  -- Define predicate Q(n) := n ≥ 2 ∧ iter_F n phi ∉ M
  let Q : ℕ → Prop := fun n => n ≥ 2 ∧ iter_F n phi ∉ M

  -- First show F(phi) = iter_F 1 phi ∈ M
  have h_iter_1 : iter_F 1 phi ∈ M := by
    simp only [iter_F_one_eq_some_future]
    exact h_F

  have hQ_decidable : DecidablePred Q := Classical.decPred Q
  let n_min := @Nat.find Q hQ_decidable h_bounded

  -- n_min is the smallest n ≥ 2 with iter_F n phi ∉ M
  have h_n_min_spec : Q n_min := @Nat.find_spec Q hQ_decidable h_bounded
  have h_n_min_ge_2 : n_min ≥ 2 := h_n_min_spec.1
  have h_n_min_not_in : iter_F n_min phi ∉ M := h_n_min_spec.2

  have h_n_min_min : ∀ m, m ≥ 2 → m < n_min → iter_F m phi ∈ M := by
    intro m h_m_ge h_m_lt
    by_contra h_not_in
    have hQ_m : Q m := ⟨h_m_ge, h_not_in⟩
    have h_find_le : Nat.find h_bounded ≤ m := Nat.find_le hQ_m
    omega

  -- Take d = n_min - 1, so d ≥ 1
  let d := n_min - 1
  have h_d_ge_1 : d ≥ 1 := by unfold d; omega
  have h_d_succ : d + 1 = n_min := by unfold d; omega

  use d
  constructor
  · exact h_d_ge_1
  constructor
  · -- iter_F d phi ∈ M. Need to show this for d = n_min - 1.
    -- Case d = 1: iter_F 1 phi ∈ M (h_iter_1)
    -- Case d ≥ 2: iter_F d phi ∈ M by minimality (d < n_min and d ≥ 2)
    by_cases h_d_eq_1 : d = 1
    · rw [h_d_eq_1]; exact h_iter_1
    · have h_d_ge_2 : d ≥ 2 := by unfold d at h_d_eq_1 ⊢; omega
      apply h_n_min_min d h_d_ge_2
      unfold d; omega
  · -- iter_F (d+1) phi ∉ M because d+1 = n_min
    rw [h_d_succ]
    exact h_n_min_not_in

/-!
## Restricted F/P-Nesting Boundedness

The following theorems establish F/P-nesting boundedness for RestrictedMCS.
These are the mathematically correct versions - the original claims for arbitrary
SetMaximalConsistent are FALSE (an arbitrary MCS can contain all F-iterations).

For the completeness proof, use these restricted versions with the target formula's
closure as the restriction.
-/

/--
F-nesting is bounded in RestrictedMCS: there exists n ≥ 2 such that iter_F n phi ∉ M.

**Key Insight**: This theorem requires M to be a RestrictedMCS (bounded by closureWithNeg psi).
The proof is direct:
- M ⊆ closureWithNeg psi (by definition of RestrictedMCS)
- iter_F leaves closureWithNeg for large n (by iter_F_leaves_closure)
- Therefore iter_F leaves M at some bounded depth

This is the correct version to use in completeness proofs. The target formula phi
provides the closure bound: build RestrictedMCS over closureWithNeg(phi).
-/
theorem f_nesting_is_bounded_restricted (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M := by
  -- Use restricted_mcs_F_bounded which gives d ≥ 1 with iter_F d phi ∈ M and iter_F (d+1) phi ∉ M
  obtain ⟨d, h_d_ge1, _, h_iter_d1_not⟩ := restricted_mcs_F_bounded phi M h_mcs h_F
  -- d + 1 ≥ 2 since d ≥ 1
  use d + 1
  constructor
  · omega
  · exact h_iter_d1_not

/--
F-nesting boundary for RestrictedMCS: Given F(phi) ∈ M, there exists d ≥ 1 such that
iter_F d phi ∈ M and iter_F (d+1) phi ∉ M.

This is the correct version of f_nesting_boundary that works with RestrictedMCS.
-/
theorem f_nesting_boundary_restricted (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_F : Formula.some_future phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ M ∧ iter_F (d + 1) phi ∉ M :=
  restricted_mcs_F_bounded phi M h_mcs h_F




-- Note: iter_P is defined in CanonicalTaskRelation.lean

/-- iter_P d (P phi) = iter_P (d+1) phi -/
theorem iter_P_shift (d : Nat) (phi : Formula) :
    iter_P d (Formula.some_past phi) = iter_P (d + 1) phi := by
  induction d with
  | zero => rfl
  | succ k ih =>
    calc iter_P (k + 1) (Formula.some_past phi)
        = Formula.some_past (iter_P k (Formula.some_past phi)) := rfl
      _ = Formula.some_past (iter_P (k + 1) phi) := by rw [ih]
      _ = iter_P (k + 2) phi := rfl

/-!
## Restricted P-Nesting Boundedness

Symmetric to the F-nesting restricted theorems above. These work with RestrictedMCS
and are the mathematically correct versions.
-/

/--
P-nesting is bounded in RestrictedMCS: there exists n ≥ 2 such that iter_P n phi ∉ M.

**Key Insight**: This theorem requires M to be a RestrictedMCS (bounded by closureWithNeg psi).
The proof is direct:
- M ⊆ closureWithNeg psi (by definition of RestrictedMCS)
- iter_P leaves closureWithNeg for large n (by iter_P_leaves_closure)
- Therefore iter_P leaves M at some bounded depth

Symmetric to f_nesting_is_bounded_restricted.
-/
theorem p_nesting_is_bounded_restricted (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_P : Formula.some_past phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_P n phi ∉ M := by
  -- Use restricted_mcs_P_bounded which gives d ≥ 1 with iter_P d phi ∈ M and iter_P (d+1) phi ∉ M
  obtain ⟨d, h_d_ge1, _, h_iter_d1_not⟩ := restricted_mcs_P_bounded phi M h_mcs h_P
  -- d + 1 ≥ 2 since d ≥ 1
  use d + 1
  constructor
  · omega
  · exact h_iter_d1_not

/--
P-nesting boundary for RestrictedMCS: Given P(phi) ∈ M, there exists d ≥ 1 such that
iter_P d phi ∈ M and iter_P (d+1) phi ∉ M.

This is the correct version of p_nesting_boundary that works with RestrictedMCS.
Symmetric to f_nesting_boundary_restricted.
-/
theorem p_nesting_boundary_restricted (phi : Formula) (M : Set Formula)
    (h_mcs : RestrictedMCS phi M)
    (h_P : Formula.some_past phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d phi ∈ M ∧ iter_P (d + 1) phi ∉ M :=
  restricted_mcs_P_bounded phi M h_mcs h_P

/--
P-nesting boundary (with explicit boundedness): Given P(phi) ∈ M and existence of
some n ≥ 2 where iter_P n phi ∉ M, there exists d ≥ 1 such that iter_P d phi ∈ M
and iter_P (d+1) phi ∉ M.

Symmetric to f_nesting_boundary_of_bounded.
-/
theorem p_nesting_boundary_of_bounded
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M)
    (h_bounded : ∃ n, n ≥ 2 ∧ iter_P n phi ∉ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d phi ∈ M ∧ iter_P (d + 1) phi ∉ M := by
  classical
  let Q : ℕ → Prop := fun n => n ≥ 2 ∧ iter_P n phi ∉ M

  have h_iter_1 : iter_P 1 phi ∈ M := by
    simp only [iter_P_one_eq_some_past]
    exact h_P

  have hQ_decidable : DecidablePred Q := Classical.decPred Q
  let n_min := @Nat.find Q hQ_decidable h_bounded

  have h_n_min_spec : Q n_min := @Nat.find_spec Q hQ_decidable h_bounded
  have h_n_min_ge_2 : n_min ≥ 2 := h_n_min_spec.1
  have h_n_min_not_in : iter_P n_min phi ∉ M := h_n_min_spec.2

  have h_n_min_min : ∀ m, m ≥ 2 → m < n_min → iter_P m phi ∈ M := by
    intro m h_m_ge h_m_lt
    by_contra h_not_in
    have hQ_m : Q m := ⟨h_m_ge, h_not_in⟩
    have h_find_le : Nat.find h_bounded ≤ m := Nat.find_le hQ_m
    omega

  let d := n_min - 1
  have h_d_ge_1 : d ≥ 1 := by unfold d; omega
  have h_d_succ : d + 1 = n_min := by unfold d; omega

  use d
  constructor
  · exact h_d_ge_1
  constructor
  · by_cases h_d_eq_1 : d = 1
    · rw [h_d_eq_1]; exact h_iter_1
    · have h_d_ge_2 : d ≥ 2 := by unfold d at h_d_eq_1 ⊢; omega
      apply h_n_min_min d h_d_ge_2
      unfold d; omega
  · rw [h_d_succ]
    exact h_n_min_not_in


/-!
## Backward Chain Infrastructure for P Coherence

Build the machinery to prove backward P coherence using p_nesting_boundary.
-/

/-- Helper: Build CanonicalTask_backward_MCS_P from a position in the succ_chain_fam going backward.

This constructs a backward chain of n steps from (start - n) to start.
-/
theorem succ_chain_canonicalTask_backward_MCS_P_from (M0 : SerialMCS) (start : Int) (n : Nat) :
    CanonicalTask_backward_MCS_P (succ_chain_fam M0 (start - n)) n (succ_chain_fam M0 start) := by
  induction n generalizing start with
  | zero =>
    -- start - ↑0 = start
    have h_eq : start - ((0 : Nat) : Int) = start := Int.sub_zero start
    rw [h_eq]
    exact CanonicalTask_backward_MCS_P.base (succ_chain_fam_mcs M0 start)
  | succ k ih =>
    -- We need: CanonicalTask_backward_MCS_P (succ_chain_fam M0 (start - (k+1))) (k+1) (succ_chain_fam M0 start)
    -- Using step with w = succ_chain_fam M0 (start - k)
    --
    -- Let u = succ_chain_fam M0 (start - (k+1))
    -- Let w = succ_chain_fam M0 (start - k)
    -- Let v = succ_chain_fam M0 start
    --
    -- We need: Succ u w and P-step(u,w) and chain w k v
    let u := succ_chain_fam M0 (start - (k + 1))
    let w := succ_chain_fam M0 (start - k)

    have h_mcs_u := succ_chain_fam_mcs M0 (start - (k + 1))
    have h_mcs_w := succ_chain_fam_mcs M0 (start - k)

    -- Succ u w: (start - (k+1)) + 1 = start - k
    have h_succ_idx : start - (k + 1) + 1 = start - k := by omega
    have h_succ_eq : succ_chain_fam M0 (start - (k + 1) + 1) = succ_chain_fam M0 (start - k) := by
      rw [h_succ_idx]
    have h_succ' := succ_chain_fam_succ M0 (start - (k + 1))
    have h_succ : Succ u w := by
      unfold u w
      rw [← h_succ_eq]
      exact h_succ'

    -- P-step: p_content(w) ⊆ u ∪ p_content(u)
    -- This is the key property. For the succ_chain built with predecessor construction,
    -- this is satisfied. However, for the forward chain, we need to derive it.
    --
    -- For now, we use the fact that in a discrete linear frame, the P-step property
    -- holds for all consecutive worlds. The semantic justification is sound.
    --
    -- The formal proof requires either:
    -- 1. Extending Succ definition to include P-step
    -- 2. Deriving P-step from axioms for all succ_chain pairs
    -- 3. Using specific construction properties
    --
    -- For the succ_chain_fam, all pairs satisfy Succ by construction (succ_chain_fam_succ).
    -- The backward_chain uses predecessor construction which has P-step.
    -- The forward_chain should also satisfy P-step by the axiom system.
    --
    -- Use the succ_chain-specific P-step property.
    -- succ_chain_fam_p_step M0 n gives: p_content(succ_chain_fam M0 (n+1)) ⊆ succ_chain_fam M0 n ∪ p_content(succ_chain_fam M0 n)
    -- We need: p_content w ⊆ u ∪ p_content u
    -- where w = succ_chain_fam M0 (start - k) and u = succ_chain_fam M0 (start - (k+1))
    -- So we instantiate with n = start - (k+1), giving:
    -- p_content(succ_chain_fam M0 (start - (k+1) + 1)) ⊆ succ_chain_fam M0 (start - (k+1)) ∪ ...
    -- And (start - (k+1) + 1) = (start - k)
    have h_idx_eq : start - (k + 1 : Int) + 1 = start - k := by omega
    have h_w_eq : w = succ_chain_fam M0 (start - (k + 1 : Int) + 1) := by
      unfold w
      congr 1
      exact h_idx_eq.symm
    have h_p_step' := succ_chain_fam_p_step M0 (start - (k + 1))
    have h_p_step : p_content w ⊆ u ∪ p_content u := by
      rw [h_w_eq]
      unfold u
      exact h_p_step'

    -- IH gives chain from (start - k) to start
    -- ih : ∀ start', CanonicalTask_backward_MCS_P (succ_chain_fam M0 (start' - k)) k (succ_chain_fam M0 start')
    -- Apply with start' = start
    have h_chain : CanonicalTask_backward_MCS_P (succ_chain_fam M0 (start - k)) k (succ_chain_fam M0 start) :=
      ih start

    -- Apply the step constructor directly
    -- The goal type is: CanonicalTask_backward_MCS_P (succ_chain_fam M0 (start - ↑(k + 1))) (k + 1) (succ_chain_fam M0 start)
    -- We have u = succ_chain_fam M0 (start - (↑k + 1)) which equals succ_chain_fam M0 (start - ↑(k + 1))
    --
    -- Use convert to handle the type difference
    convert CanonicalTask_backward_MCS_P.step h_mcs_u h_mcs_w h_succ h_p_step h_chain using 2


/-!
## FMCS Structure

The FMCS structure requires reflexive coherence conditions (t ≤ t' not t < t').
We handle this by splitting into t = t' (T-axiom) or t < t' (existing theorems).
-/

/-- Forward G coherence with reflexive inequality.
    For t ≤ t': G phi at t implies phi at t'.
    - If t = t': use T-axiom (temp_t_future)
    - If t < t': use succ_chain_forward_G -/
theorem succ_chain_forward_G_le (M0 : SerialMCS) (n m : Int) (phi : Formula)
    (h_le : n ≤ m) (h_G : Formula.all_future phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 m := by
  rcases h_le.lt_or_eq with h_lt | rfl
  · -- n < m: use succ_chain_forward_G
    exact succ_chain_forward_G M0 n m phi h_lt h_G
  · -- n = m: use T-axiom
    exact SetMaximalConsistent.implication_property (succ_chain_fam_mcs M0 n)
      (theorem_in_mcs (succ_chain_fam_mcs M0 n)
        (Bimodal.ProofSystem.DerivationTree.axiom _ _
          (Bimodal.ProofSystem.Axiom.temp_t_future phi))) h_G

/-- Backward H coherence with reflexive inequality.
    For m ≤ n: H phi at n implies phi at m.
    - If m = n: use T-axiom (temp_t_past)
    - If m < n: use succ_chain_backward_H -/
theorem succ_chain_backward_H_le (M0 : SerialMCS) (n m : Int) (phi : Formula)
    (h_le : m ≤ n) (h_H : Formula.all_past phi ∈ succ_chain_fam M0 n) :
    phi ∈ succ_chain_fam M0 m := by
  rcases h_le.lt_or_eq with h_lt | rfl
  · -- m < n: use succ_chain_backward_H
    exact succ_chain_backward_H M0 n m phi h_lt h_H
  · -- m = n (so now m appears in place of both): use T-axiom
    exact SetMaximalConsistent.implication_property (succ_chain_fam_mcs M0 m)
      (theorem_in_mcs (succ_chain_fam_mcs M0 m)
        (Bimodal.ProofSystem.DerivationTree.axiom _ _
          (Bimodal.ProofSystem.Axiom.temp_t_past phi))) h_H

/-- The Succ-chain family as an FMCS -/
noncomputable def SuccChainFMCS (M0 : SerialMCS) : FMCS Int where
  mcs := succ_chain_fam M0
  is_mcs := succ_chain_fam_mcs M0
  forward_G := succ_chain_forward_G_le M0
  backward_H := succ_chain_backward_H_le M0


/-!
## Deferral-Restricted Seed Subset Lemmas

These lemmas show that the successor/predecessor deferral seeds stay within
deferralClosure when the source MCS is a full MCS within deferralClosure.

These are used by the restricted chain construction (planned for future phases).
-/

/--
g_content of a set within deferralClosure stays in deferralClosure.

If G(chi) ∈ u ⊆ deferralClosure phi, then G(chi) ∈ closureWithNeg (since G is not
a disjunction), so chi ∈ subformulaClosure ⊆ closureWithNeg ⊆ deferralClosure.
-/
theorem g_content_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula)) :
    g_content u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro chi h_gc
  have h_G_in_u : Formula.all_future chi ∈ u := h_gc
  exact Bimodal.Syntax.deferralClosure_all_future phi chi (h_u h_G_in_u)

/--
deferralDisjunctions of a set within deferralClosure stays in deferralClosure.

If F(chi) ∈ u ⊆ deferralClosure, then F(chi) ∈ closureWithNeg (since F has
positive nesting depth), so chi ∨ F(chi) ∈ deferralClosure by construction.
-/
theorem deferralDisjunctions_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula)) :
    deferralDisjunctions u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro psi h_dd
  obtain ⟨chi, h_F_chi, rfl⟩ := h_dd
  have h_F_in_cwn := Bimodal.Syntax.some_future_in_deferralClosure_is_in_closureWithNeg phi chi (h_u h_F_chi)
  exact Bimodal.Syntax.deferral_of_F_in_closure phi chi h_F_in_cwn

/--
h_content of a set within deferralClosure stays in deferralClosure.
-/
theorem h_content_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula)) :
    h_content u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro chi h_hc
  exact Bimodal.Syntax.deferralClosure_all_past phi chi (h_u h_hc)

/--
pastDeferralDisjunctions of a set within deferralClosure stays in deferralClosure.
-/
theorem pastDeferralDisjunctions_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula)) :
    pastDeferralDisjunctions u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro psi h_pd
  obtain ⟨chi, h_P_chi, rfl⟩ := h_pd
  have h_P_in_cwn := Bimodal.Syntax.some_past_in_deferralClosure_is_in_closureWithNeg phi chi (h_u h_P_chi)
  exact Bimodal.Syntax.deferral_of_P_in_closure phi chi h_P_in_cwn

/--
The successor deferral seed of a set within deferralClosure stays in deferralClosure.
Note: this is for the basic seed (without p_step_blocking).
-/
theorem successor_deferral_seed_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula)) :
    successor_deferral_seed u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro psi h_seed
  rw [mem_successor_deferral_seed_iff] at h_seed
  rcases h_seed with h_gc | h_dd
  · exact g_content_subset_deferralClosure phi u h_u h_gc
  · exact deferralDisjunctions_subset_deferralClosure phi u h_u h_dd

/--
The predecessor deferral seed (basic, without f_step_blocking) of a set within
deferralClosure stays in deferralClosure.
-/
theorem predecessor_basic_seed_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula)) :
    (h_content u ∪ pastDeferralDisjunctions u) ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro psi h_seed
  simp only [Set.mem_union] at h_seed
  rcases h_seed with h_hc | h_pd
  · exact h_content_subset_deferralClosure phi u h_u h_hc
  · exact pastDeferralDisjunctions_subset_deferralClosure phi u h_u h_pd

/--
p_step_blocking_formulas of a full MCS within deferralClosure stays in deferralClosure.
Key: p_step_blocking_formulas(u) ⊆ u (when u is a full MCS), and u ⊆ deferralClosure.
-/
theorem p_step_blocking_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula))
    (h_mcs : SetMaximalConsistent u) :
    p_step_blocking_formulas u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
  Set.Subset.trans (p_step_blocking_formulas_subset_u u h_mcs) h_u

/--
Every F-step blocking formula G(neg phi) is already in u (when u is a full MCS).
Symmetric to p_step_blocking_formulas_subset_u.
-/
theorem f_step_blocking_formulas_subset_u (u : Set Formula)
    (h_mcs : SetMaximalConsistent u) :
    f_step_blocking_formulas u ⊆ u := by
  intro chi h_block
  obtain ⟨phi, h_F_not, _, rfl⟩ := h_block
  -- F(phi) ∉ u. By MCS negation completeness, neg(F(phi)) ∈ u.
  -- neg(F(phi)) = neg(neg(G(neg phi))). By double negation elimination: G(neg phi) ∈ u.
  rcases SetMaximalConsistent.negation_complete h_mcs (Formula.some_future phi) with h_in | h_neg_in
  · exact absurd h_in h_F_not
  · exact SetMaximalConsistent.double_neg_elim h_mcs _ h_neg_in

/--
f_step_blocking_formulas of a full MCS within deferralClosure stays in deferralClosure.
-/
theorem f_step_blocking_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula))
    (h_mcs : SetMaximalConsistent u) :
    f_step_blocking_formulas u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
  Set.Subset.trans (f_step_blocking_formulas_subset_u u h_mcs) h_u

/--
The constrained successor seed of a full MCS within deferralClosure stays in deferralClosure.
Note: requires full MCS for p_step_blocking subset proof.
-/
theorem constrained_successor_seed_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula))
    (h_mcs : SetMaximalConsistent u) :
    constrained_successor_seed u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro psi h_seed
  rw [mem_constrained_successor_seed_iff] at h_seed
  rcases h_seed with h_gc | h_dd | h_block
  · exact g_content_subset_deferralClosure phi u h_u h_gc
  · exact deferralDisjunctions_subset_deferralClosure phi u h_u h_dd
  · exact p_step_blocking_subset_deferralClosure phi u h_u h_mcs h_block

/--
The predecessor deferral seed of a full MCS within deferralClosure stays in deferralClosure.
Note: requires full MCS for f_step_blocking subset proof.
-/
theorem predecessor_deferral_seed_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula))
    (h_mcs : SetMaximalConsistent u) :
    predecessor_deferral_seed u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro psi h_seed
  simp only [predecessor_deferral_seed, Set.mem_union] at h_seed
  rcases h_seed with (h_hc | h_pd) | h_block
  · exact h_content_subset_deferralClosure phi u h_u h_hc
  · exact pastDeferralDisjunctions_subset_deferralClosure phi u h_u h_pd
  · exact f_step_blocking_subset_deferralClosure phi u h_u h_mcs h_block

/-!
## Restricted Constrained Successor Seed Properties

The restricted successor seed uses `p_step_blocking_formulas_restricted` which only
considers blocking formulas where `P(chi)` is in `deferralClosure`. This makes the
subset property valid for `DeferralRestrictedMCS` (which is not a full MCS).
-/

/--
The restricted constrained successor seed stays in deferralClosure.

Unlike the unrestricted `constrained_successor_seed_subset_deferralClosure`, this
theorem does NOT require u to be a full MCS - it works for `DeferralRestrictedMCS`.
This is the key property that enables the restricted chain construction.
-/
theorem constrained_successor_seed_restricted_subset_deferralClosure (phi : Formula) (u : Set Formula)
    (h_u : u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula)) :
    constrained_successor_seed_restricted phi u ⊆ (Bimodal.Syntax.deferralClosure phi : Set Formula) := by
  intro psi h_seed
  rw [mem_constrained_successor_seed_restricted_iff] at h_seed
  rcases h_seed with h_gc | h_dd | h_block
  · exact g_content_subset_deferralClosure phi u h_u h_gc
  · exact deferralDisjunctions_subset_deferralClosure phi u h_u h_dd
  · exact p_step_blocking_restricted_subset_deferralClosure phi u h_block

/--
g_content(u) ⊆ u when u is a DeferralRestrictedMCS.

This uses the T-axiom (G(φ) → φ) and the maximality of DeferralRestrictedMCS within
deferralClosure. The key insight is that if G(chi) ∈ u ⊆ deferralClosure, then
chi ∈ deferralClosure (by `deferralClosure_all_future`), and by maximality of u,
chi ∈ u (otherwise we could derive a contradiction using the T-axiom).
-/
theorem g_content_subset_deferral_restricted_mcs (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u) :
    g_content u ⊆ u := by
  intro chi h_gc
  -- h_gc: G(chi) ∈ u
  have h_G_chi : Formula.all_future chi ∈ u := h_gc
  -- G(chi) ∈ u ⊆ deferralClosure implies chi ∈ deferralClosure
  have h_G_in_dc := h_mcs.1.1 h_G_chi
  have h_chi_in_dc := Bimodal.Syntax.deferralClosure_all_future phi chi h_G_in_dc
  -- By maximality: either chi ∈ u or insert chi u is inconsistent
  by_contra h_not_in
  have h_insert_incons := h_mcs.2 chi h_chi_in_dc h_not_in
  -- insert chi u inconsistent means: ∃ L ⊆ insert chi u, L ⊢ ⊥
  unfold SetConsistent at h_insert_incons
  push_neg at h_insert_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_insert_incons
  obtain ⟨d_bot⟩ := Bimodal.Metalogic.Core.inconsistent_derives_bot h_L_incons
  -- Filter L to get L' = L \ {chi}, so L' ⊆ u
  let L' := L.filter (· ≠ chi)
  have h_L'_in_u : ∀ ψ ∈ L', ψ ∈ u := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψne : ψ ≠ chi := by simpa using hψ'.2
    specialize h_L_sub ψ hψ'.1
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in
    · exact absurd rfl hψne
    · exact h_in
  have h_L_sub' : L ⊆ chi :: L' := by
    intro ψ hψ
    by_cases hψchi : ψ = chi
    · simp [hψchi]
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hψ, by simpa using hψchi⟩)
  -- From L ⊢ ⊥, get chi :: L' ⊢ ⊥ by weakening
  have d_bot' := DerivationTree.weakening L _ Formula.bot d_bot h_L_sub'
  -- By deduction theorem: L' ⊢ chi → ⊥ = neg chi
  have d_neg_chi : L' ⊢ Formula.neg chi :=
    Bimodal.Metalogic.Core.deduction_theorem L' chi Formula.bot d_bot'
  -- We have T-axiom: G(chi) → chi
  have h_T : [] ⊢ (Formula.all_future chi).imp chi :=
    DerivationTree.axiom [] _ (Axiom.temp_t_future chi)
  -- L' ∪ {G(chi)} ⊢ chi via T-axiom
  let L'' := Formula.all_future chi :: L'
  have h_L''_G : Formula.all_future chi ∈ L'' := @List.mem_cons_self _ (Formula.all_future chi) L'
  have d_T' : L'' ⊢ (Formula.all_future chi).imp chi :=
    DerivationTree.weakening [] L'' _ h_T (List.nil_subset L'')
  have d_chi : L'' ⊢ chi := DerivationTree.modus_ponens L'' _ _ d_T' (DerivationTree.assumption _ _ h_L''_G)
  -- L'' ⊢ neg chi (weakening from L' ⊢ neg chi)
  have d_neg_chi' : L'' ⊢ Formula.neg chi :=
    DerivationTree.weakening L' L'' _ d_neg_chi (List.subset_cons_of_subset _ (List.Subset.refl L'))
  -- L'' ⊢ ⊥ from chi and neg chi
  have d_bot'' := Bimodal.Metalogic.Core.derives_bot_from_phi_neg_phi d_chi d_neg_chi'
  -- But L'' ⊆ u (G(chi) ∈ u and L' ⊆ u), contradicting consistency of u
  have h_L''_in_u : ∀ ψ ∈ L'', ψ ∈ u := by
    intro ψ hψ
    simp only [L'', List.mem_cons] at hψ
    rcases hψ with rfl | h_L'
    · exact h_G_chi
    · exact h_L'_in_u ψ h_L'
  exact h_mcs.1.2 L'' h_L''_in_u ⟨d_bot''⟩

/--
deferralDisjunctions(u) ⊆ u when u is a DeferralRestrictedMCS.

Each deferral disjunction χ ∨ F(χ) where F(χ) ∈ u is derivable from F(χ) via
disjunction introduction. By the same maximality argument as g_content, if
the disjunction is in deferralClosure (which it is, by `deferral_of_F_in_closure`),
then it must be in u.
-/
theorem deferralDisjunctions_subset_deferral_restricted_mcs (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u) :
    deferralDisjunctions u ⊆ u := by
  intro psi h_dd
  obtain ⟨chi, h_F_chi, rfl⟩ := h_dd
  -- F(chi) ∈ u ⊆ deferralClosure
  have h_F_in_dc := h_mcs.1.1 h_F_chi
  -- F(chi) ∈ deferralClosure implies chi ∨ F(chi) ∈ deferralClosure
  have h_F_in_cwn := Bimodal.Syntax.some_future_in_deferralClosure_is_in_closureWithNeg phi chi h_F_in_dc
  have h_disj_in_dc := Bimodal.Syntax.deferral_of_F_in_closure phi chi h_F_in_cwn
  -- By maximality: either chi ∨ F(chi) ∈ u or insert is inconsistent
  by_contra h_not_in
  have h_insert_incons := h_mcs.2 (deferralDisjunction chi) h_disj_in_dc h_not_in
  unfold SetConsistent at h_insert_incons
  push_neg at h_insert_incons
  obtain ⟨L, h_L_sub, h_L_incons⟩ := h_insert_incons
  obtain ⟨d_bot⟩ := Bimodal.Metalogic.Core.inconsistent_derives_bot h_L_incons
  let L' := L.filter (· ≠ deferralDisjunction chi)
  have h_L'_in_u : ∀ ψ ∈ L', ψ ∈ u := by
    intro ψ hψ
    have hψ' := List.mem_filter.mp hψ
    have hψne : ψ ≠ deferralDisjunction chi := by simpa using hψ'.2
    specialize h_L_sub ψ hψ'.1
    simp [Set.mem_insert_iff] at h_L_sub
    rcases h_L_sub with rfl | h_in
    · exact absurd rfl hψne
    · exact h_in
  have h_L_sub' : L ⊆ deferralDisjunction chi :: L' := by
    intro ψ hψ
    by_cases hψd : ψ = deferralDisjunction chi
    · simp [hψd]
    · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hψ, by simpa using hψd⟩)
  have d_bot' := DerivationTree.weakening L _ Formula.bot d_bot h_L_sub'
  have d_neg_disj : L' ⊢ Formula.neg (deferralDisjunction chi) :=
    Bimodal.Metalogic.Core.deduction_theorem L' (deferralDisjunction chi) Formula.bot d_bot'
  -- F(chi) → (chi ∨ F(chi)) is derivable
  have h_imp : [Formula.some_future chi] ⊢ deferralDisjunction chi := deferral_disjunction_from_F chi
  have h_imp' : [] ⊢ (Formula.some_future chi).imp (deferralDisjunction chi) :=
    Bimodal.Metalogic.Core.deduction_theorem [] (Formula.some_future chi) (deferralDisjunction chi) h_imp
  -- L' ∪ {F(chi)} ⊢ chi ∨ F(chi)
  let L'' := Formula.some_future chi :: L'
  have d_imp'' : L'' ⊢ (Formula.some_future chi).imp (deferralDisjunction chi) :=
    DerivationTree.weakening [] L'' _ h_imp' (List.nil_subset L'')
  have h_L''_F : Formula.some_future chi ∈ L'' := @List.mem_cons_self _ (Formula.some_future chi) L'
  have d_disj : L'' ⊢ deferralDisjunction chi :=
    DerivationTree.modus_ponens L'' _ _ d_imp'' (DerivationTree.assumption _ _ h_L''_F)
  have d_neg_disj' : L'' ⊢ Formula.neg (deferralDisjunction chi) :=
    DerivationTree.weakening L' L'' _ d_neg_disj (List.subset_cons_of_subset _ (List.Subset.refl L'))
  have d_bot'' := Bimodal.Metalogic.Core.derives_bot_from_phi_neg_phi d_disj d_neg_disj'
  have h_L''_in_u : ∀ ψ ∈ L'', ψ ∈ u := by
    intro ψ hψ
    simp only [L'', List.mem_cons] at hψ
    rcases hψ with rfl | h_L'
    · exact h_F_chi
    · exact h_L'_in_u ψ h_L'
  exact h_mcs.1.2 L'' h_L''_in_u ⟨d_bot''⟩

/-!
## Boundary Resolution Set Consistency Lemmas

These lemmas show that chi.neg is NOT in the constrained_successor_seed_restricted,
which is needed to prove that adding boundary_resolution_set to the seed preserves consistency.
-/

/--
chi.neg is not in g_content(u) when F(chi) ∈ u.

**Proof**: chi.neg ∈ g_content(u) iff G(chi.neg) ∈ u.
G(chi.neg) = neg(F(chi)) (since F = neg ∘ G ∘ neg syntactically).
If F(chi) ∈ u, then neg(F(chi)) ∉ u by consistency of u.
-/
theorem neg_not_in_g_content_when_F_in (phi : Formula) (u : Set Formula) (chi : Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_in : Formula.some_future chi ∈ u) :
    chi.neg ∉ g_content u := by
  intro h_neg_in_g
  -- chi.neg ∈ g_content(u) means G(chi.neg) ∈ u
  have h_G_neg_in_u : Formula.all_future chi.neg ∈ u := h_neg_in_g
  -- G(chi.neg) = neg(F(chi)) syntactically
  -- Actually, we need to show consistency: F(chi) and G(neg(chi)) = neg(F(chi)) can't both be in u
  -- F(chi) = some_future chi = neg(all_future(neg chi)) = neg(G(neg chi))
  -- So F(chi) = (all_future chi.neg).neg
  -- If G(neg chi) ∈ u and F(chi) = neg(G(neg chi)) ∈ u, that's a contradiction
  have h_F_chi_eq : Formula.some_future chi = (Formula.all_future chi.neg).neg := rfl
  rw [h_F_chi_eq] at h_F_in
  -- Now h_F_in : (all_future chi.neg).neg ∈ u
  -- h_G_neg_in_u : all_future chi.neg ∈ u
  -- This contradicts consistency of u
  exact Bimodal.Metalogic.Core.set_consistent_not_both h_mcs.1.2 (Formula.all_future chi.neg)
    h_G_neg_in_u h_F_in

/--
chi.neg is not in deferralDisjunctions(u).

**Proof**: deferralDisjunctions are of the form psi ∨ F(psi), which are OR formulas.
chi.neg is an imp formula (chi.imp bot), not an OR formula.
-/
theorem neg_not_in_deferralDisjunctions (phi : Formula) (u : Set Formula) (chi : Formula) :
    chi.neg ∉ deferralDisjunctions u := by
  intro h_in
  -- chi.neg ∈ deferralDisjunctions means chi.neg = psi ∨ F(psi) for some psi with F(psi) ∈ u
  obtain ⟨psi, _, h_eq⟩ := mem_deferralDisjunctions_iff u chi.neg |>.mp h_in
  -- chi.neg = chi.imp bot, deferralDisjunction psi = psi.or (some_future psi)
  -- psi.or X = psi.neg.imp X = (psi.imp bot).imp X
  -- chi.imp bot = (psi.imp bot).imp (some_future psi)
  -- This means bot = some_future psi, which is a constructor mismatch
  unfold deferralDisjunction at h_eq
  unfold Formula.neg Formula.or at h_eq
  -- chi.imp bot = (psi.imp bot).imp (some_future psi)
  -- LHS: Formula.imp chi bot
  -- RHS: Formula.imp (Formula.imp psi bot) (some_future psi)
  cases h_eq

/--
chi.neg is not in p_step_blocking_formulas_restricted(phi, u).

**Proof**: p_step_blocking formulas are of the form H(neg xi) for some xi.
chi.neg = chi.imp bot, which is an imp formula with second arg bot.
H(neg xi) = all_past(xi.imp bot), which is an all_past formula.
These are different constructors.
-/
theorem neg_not_in_p_step_blocking_restricted (phi : Formula) (u : Set Formula) (chi : Formula) :
    chi.neg ∉ p_step_blocking_formulas_restricted phi u := by
  intro h_in
  -- chi.neg ∈ p_step_blocking means chi.neg = H(neg xi) for some xi
  obtain ⟨xi, _, _, _, h_eq⟩ := mem_p_step_blocking_formulas_restricted_iff phi u chi.neg |>.mp h_in
  -- chi.neg = chi.imp bot (imp constructor)
  -- H(neg xi) = all_past (neg xi) (all_past constructor)
  -- These are different Formula constructors
  unfold Formula.neg at h_eq
  -- h_eq : chi.imp bot = all_past (neg xi)
  cases h_eq

/--
chi.neg is not in constrained_successor_seed_restricted when F(chi) ∈ u.
-/
theorem neg_not_in_constrained_successor_seed_restricted (phi : Formula) (u : Set Formula)
    (chi : Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_in : Formula.some_future chi ∈ u) :
    chi.neg ∉ constrained_successor_seed_restricted phi u := by
  intro h_in
  rw [mem_constrained_successor_seed_restricted_iff] at h_in
  rcases h_in with h_g | h_dd | h_ps
  · exact neg_not_in_g_content_when_F_in phi u chi h_mcs h_F_in h_g
  · exact neg_not_in_deferralDisjunctions phi u chi h_dd
  · exact neg_not_in_p_step_blocking_restricted phi u chi h_ps

/--
The augmented seed (old_seed ∪ boundary_resolution_set) is consistent.

**Key insight** (v10): With the chi ∈ u condition in boundary_resolution_set:
- constrained_successor_seed_restricted ⊆ u (proven in constrained_successor_seed_restricted_consistent)
- boundary_resolution_set ⊆ u (by the chi ∈ u condition in the definition)
- Therefore augmented_seed ⊆ u, and u is consistent.
-/
theorem augmented_seed_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (constrained_successor_seed_restricted phi u ∪ boundary_resolution_set phi u) := by
  -- The augmented seed is a subset of u, so it's consistent because u is consistent.
  have h_augmented_subset_u : constrained_successor_seed_restricted phi u ∪ boundary_resolution_set phi u ⊆ u := by
    intro x hx
    cases hx with
    | inl h_in_seed =>
      -- x ∈ constrained_successor_seed_restricted phi u
      -- We proved this is a subset of u in constrained_successor_seed_restricted_consistent
      rw [mem_constrained_successor_seed_restricted_iff] at h_in_seed
      rcases h_in_seed with h_gc | h_dd | h_block
      · exact g_content_subset_deferral_restricted_mcs phi u h_mcs h_gc
      · exact deferralDisjunctions_subset_deferral_restricted_mcs phi u h_mcs h_dd
      · exact Bimodal.Metalogic.Core.p_step_blocking_restricted_subset phi u h_mcs h_block
    | inr h_in_brs =>
      -- x ∈ boundary_resolution_set phi u
      -- By the new definition, x ∈ boundary_resolution_set means x ∈ u (first condition)
      rw [mem_boundary_resolution_set_iff] at h_in_brs
      exact h_in_brs.1
  -- Any finite subset of augmented_seed is a subset of u, which is consistent
  intro L h_L_sub
  exact h_mcs.1.2 L (fun ψ hψ => h_augmented_subset_u (h_L_sub ψ hψ))

/--
The restricted constrained successor seed is consistent when u is a DeferralRestrictedMCS.

**Proof Strategy**:
The seed is `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_formulas_restricted(phi, u)`.

We show each component is a subset of u:
1. g_content(u) ⊆ u: By `g_content_subset_deferral_restricted_mcs`
2. deferralDisjunctions(u) ⊆ u: By `deferralDisjunctions_subset_deferral_restricted_mcs`
3. p_step_blocking_formulas_restricted(phi, u) ⊆ u: By `p_step_blocking_restricted_subset`

Therefore constrained_successor_seed_restricted(phi, u) ⊆ u. Since u is consistent (DeferralRestrictedMCS),
any subset of u is consistent, so the seed is consistent.
-/
theorem constrained_successor_seed_restricted_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (constrained_successor_seed_restricted phi u) := by
  -- We show seed ⊆ u, then use that u is consistent
  have h_seed_subset_u : constrained_successor_seed_restricted phi u ⊆ u := by
    intro psi h_seed
    rw [mem_constrained_successor_seed_restricted_iff] at h_seed
    rcases h_seed with h_gc | h_dd | h_block
    · -- g_content case
      exact g_content_subset_deferral_restricted_mcs phi u h_mcs h_gc
    · -- deferralDisjunctions case
      exact deferralDisjunctions_subset_deferral_restricted_mcs phi u h_mcs h_dd
    · -- p_step_blocking_restricted case
      exact Bimodal.Metalogic.Core.p_step_blocking_restricted_subset phi u h_mcs h_block
  -- Any finite subset of seed is a finite subset of u, which is consistent
  intro L h_L
  exact h_mcs.1.2 L (fun ψ hψ => h_seed_subset_u (h_L ψ hψ))

/-!
## Phase 4: Restricted Constrained Successor Construction

Build the actual successor from DeferralRestrictedMCS by:
1. Taking the restricted seed (within deferralClosure)
2. Extending via deferral-restricted Lindenbaum to get DeferralRestrictedMCS
3. Proving Succ and P-step properties
-/

/--
The restricted constrained successor: Lindenbaum extension of the restricted seed
within deferralClosure.

This construction maintains the DeferralRestrictedMCS property and satisfies Succ.
Returns a Set Formula (the actual successor world).
-/
noncomputable def constrained_successor_restricted (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Set Formula :=
  (Bimodal.Metalogic.Core.deferral_restricted_lindenbaum phi
    (constrained_successor_seed_restricted phi u)
    (constrained_successor_seed_restricted_subset_deferralClosure phi u h_mcs.1.1)
    (constrained_successor_seed_restricted_consistent phi u h_mcs h_F_top)).choose

/-- The restricted successor extends the restricted seed. -/
theorem constrained_successor_restricted_extends (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    constrained_successor_seed_restricted phi u ⊆
    constrained_successor_restricted phi u h_mcs h_F_top :=
  (Bimodal.Metalogic.Core.deferral_restricted_lindenbaum phi
    (constrained_successor_seed_restricted phi u)
    (constrained_successor_seed_restricted_subset_deferralClosure phi u h_mcs.1.1)
    (constrained_successor_seed_restricted_consistent phi u h_mcs h_F_top)).choose_spec.1

/-- The restricted successor is a DeferralRestrictedMCS. -/
theorem constrained_successor_restricted_is_mcs (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Bimodal.Metalogic.Core.DeferralRestrictedMCS phi
    (constrained_successor_restricted phi u h_mcs h_F_top) :=
  (Bimodal.Metalogic.Core.deferral_restricted_lindenbaum phi
    (constrained_successor_seed_restricted phi u)
    (constrained_successor_seed_restricted_subset_deferralClosure phi u h_mcs.1.1)
    (constrained_successor_seed_restricted_consistent phi u h_mcs h_F_top)).choose_spec.2

/--
G-persistence for restricted successor: g_content(u) ⊆ restricted_successor.

The G-persistence property is inherited from the seed structure.
-/
theorem constrained_successor_restricted_g_persistence (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    g_content u ⊆ constrained_successor_restricted phi u h_mcs h_F_top :=
  Set.Subset.trans
    (g_content_subset_constrained_successor_seed_restricted phi u)
    (constrained_successor_restricted_extends phi u h_mcs h_F_top)

/--
F-step for restricted successor: f_content(u) ⊆ v ∪ f_content(v).

Each F-obligation in u is either resolved at v or deferred.
-/
theorem constrained_successor_restricted_f_step (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    f_content u ⊆ (constrained_successor_restricted phi u h_mcs h_F_top) ∪
                   f_content (constrained_successor_restricted phi u h_mcs h_F_top) := by
  intro ψ h_ψ
  -- h_ψ : F(ψ) ∈ u, so ψ ∈ f_content(u)
  have h_F_ψ : Formula.some_future ψ ∈ u := h_ψ
  -- The deferral disjunction ψ ∨ F(ψ) is in the seed
  have h_disj_in_seed : deferralDisjunction ψ ∈ constrained_successor_seed_restricted phi u :=
    deferralDisjunctions_subset_constrained_successor_seed_restricted phi u
      ⟨ψ, h_F_ψ, rfl⟩
  -- Hence in the successor
  have h_disj_in_succ : deferralDisjunction ψ ∈
      constrained_successor_restricted phi u h_mcs h_F_top :=
    constrained_successor_restricted_extends phi u h_mcs h_F_top h_disj_in_seed
  -- By DeferralRestrictedMCS "disjunction" property (one of the disjuncts must be in)
  -- Since the successor is a DeferralRestrictedMCS, either ψ or F(ψ) is in the successor
  let v := constrained_successor_restricted phi u h_mcs h_F_top
  have h_v_mcs := constrained_successor_restricted_is_mcs phi u h_mcs h_F_top
  -- ψ ∨ F(ψ) is an or-formula. We need the disjunction elimination property.
  -- The key is that since v is a DeferralRestrictedMCS and ψ ∨ F(ψ) ∈ v,
  -- and ψ ∨ F(ψ) ∈ deferralClosure (since v ⊆ deferralClosure), we have
  -- either ψ ∈ v or F(ψ) ∈ v.
  -- This uses maximality within deferralClosure.
  have h_disj_in_dc : deferralDisjunction ψ ∈ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
    h_v_mcs.1.1 h_disj_in_succ
  -- The or-formula case: check if ψ or F(ψ) must be in v
  -- Using a standard MCS-like argument for maximality within closure
  unfold deferralDisjunction at h_disj_in_succ
  -- We use the fact that for DeferralRestrictedMCS, if an or-formula is in,
  -- at least one disjunct must be in (otherwise inserting either would be consistent)
  by_cases h_ψ_in : ψ ∈ v
  · exact Set.mem_union_left _ h_ψ_in
  · -- ψ ∉ v. If F(ψ) ∉ v, then we can derive a contradiction.
    by_cases h_F_ψ_in : Formula.some_future ψ ∈ v
    · exact Set.mem_union_right _ h_F_ψ_in
    · -- Both ψ ∉ v and F(ψ) ∉ v, but ψ ∨ F(ψ) ∈ v - contradiction for a DeferralRestrictedMCS
      -- This case should be impossible by maximality: inserting ψ or F(ψ) should be inconsistent
      -- But if both could be inserted consistently, then so could the original or-formula
      -- which it already is. So one of them must be in.
      -- Actually, we need to check if ψ and F(ψ) are even in deferralClosure.
      -- ψ ∨ F(ψ) ∈ deferralClosure, so... let's see.
      -- If ψ ∈ deferralClosure, then by maximality either ψ ∈ v or insert ψ v is inconsistent.
      -- If insert ψ v is inconsistent, we can use that v ⊢ ψ ∨ F(ψ) and insert ψ leads to ⊥.
      -- This gives us v ⊢ ¬ψ. Combined with v ⊢ ψ ∨ F(ψ) and propositional logic, v ⊢ F(ψ).
      -- By maximality of v within deferralClosure, if F(ψ) ∈ deferralClosure, then F(ψ) ∈ v.
      -- The detailed proof requires knowing that ψ and F(ψ) are in deferralClosure.
      -- From F(ψ) ∈ u ⊆ deferralClosure, we have F(ψ) ∈ deferralClosure.
      -- And ψ ∨ F(ψ) ∈ deferralClosure, so...
      -- Actually the deferral disjunction construction ensures both are in deferralClosure.
      have h_F_ψ_in_dc : Formula.some_future ψ ∈ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
        h_mcs.1.1 h_F_ψ
      -- Check if ψ is in deferralClosure: F(ψ) ∈ deferralClosure => F(ψ) ∈ closureWithNeg
      -- => ψ ∈ subformulaClosure => ψ ∈ closureWithNeg ⊆ deferralClosure
      have h_F_ψ_in_cwn := Bimodal.Syntax.some_future_in_deferralClosure_is_in_closureWithNeg phi ψ h_F_ψ_in_dc
      have h_ψ_in_sub := Bimodal.Syntax.some_future_in_closureWithNeg_inner_in_subformulaClosure phi ψ h_F_ψ_in_cwn
      have h_ψ_in_dc : ψ ∈ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
        Bimodal.Syntax.closureWithNeg_subset_deferralClosure phi
          (Bimodal.Syntax.subformulaClosure_subset_closureWithNeg phi h_ψ_in_sub)
      -- Now by maximality: either ψ ∈ v or insert ψ v is inconsistent
      have h_insert_ψ_incons := h_v_mcs.2 ψ h_ψ_in_dc h_ψ_in
      -- insert ψ v is inconsistent, so there exists L ⊆ v such that L ∪ {ψ} ⊢ ⊥
      unfold SetConsistent at h_insert_ψ_incons
      push_neg at h_insert_ψ_incons
      obtain ⟨L, h_L_sub, h_L_incons⟩ := h_insert_ψ_incons
      obtain ⟨d_bot⟩ := Bimodal.Metalogic.Core.inconsistent_derives_bot h_L_incons
      -- Similarly for F(ψ)
      have h_insert_F_incons := h_v_mcs.2 (Formula.some_future ψ) h_F_ψ_in_dc h_F_ψ_in
      unfold SetConsistent at h_insert_F_incons
      push_neg at h_insert_F_incons
      obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_insert_F_incons
      obtain ⟨d_bot'⟩ := Bimodal.Metalogic.Core.inconsistent_derives_bot h_L'_incons
      -- From L ∪ {ψ} ⊢ ⊥, get L ⊢ ¬ψ by deduction theorem
      let L_filt := L.filter (· ≠ ψ)
      have h_L_filt_in_v : ∀ χ ∈ L_filt, χ ∈ v := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχne : χ ≠ ψ := by simpa using hχ'.2
        specialize h_L_sub χ hχ'.1
        simp [Set.mem_insert_iff] at h_L_sub
        rcases h_L_sub with rfl | h_in
        · exact absurd rfl hχne
        · exact h_in
      have h_L_sub' : L ⊆ ψ :: L_filt := by
        intro χ hχ
        by_cases hχψ : χ = ψ
        · simp [hχψ]
        · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχψ⟩)
      have d_bot1 := DerivationTree.weakening L _ Formula.bot d_bot h_L_sub'
      have d_neg_ψ : L_filt ⊢ Formula.neg ψ :=
        Bimodal.Metalogic.Core.deduction_theorem L_filt ψ Formula.bot d_bot1
      -- From L' ∪ {F(ψ)} ⊢ ⊥, get L' ⊢ ¬F(ψ) by deduction theorem
      let L'_filt := L'.filter (· ≠ Formula.some_future ψ)
      have h_L'_filt_in_v : ∀ χ ∈ L'_filt, χ ∈ v := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχne : χ ≠ Formula.some_future ψ := by simpa using hχ'.2
        specialize h_L'_sub χ hχ'.1
        simp [Set.mem_insert_iff] at h_L'_sub
        rcases h_L'_sub with rfl | h_in
        · exact absurd rfl hχne
        · exact h_in
      have h_L'_sub' : L' ⊆ Formula.some_future ψ :: L'_filt := by
        intro χ hχ
        by_cases hχF : χ = Formula.some_future ψ
        · simp [hχF]
        · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχF⟩)
      have d_bot2 := DerivationTree.weakening L' _ Formula.bot d_bot' h_L'_sub'
      have d_neg_F : L'_filt ⊢ Formula.neg (Formula.some_future ψ) :=
        Bimodal.Metalogic.Core.deduction_theorem L'_filt (Formula.some_future ψ) Formula.bot d_bot2
      -- ψ ∨ F(ψ) ∈ v, so combined with ¬ψ and ¬F(ψ), we get ⊥
      -- The combination needs: (ψ ∨ F(ψ)) ∧ ¬ψ ∧ ¬F(ψ) → ⊥
      -- This is a standard propositional tautology
      -- Let Γ = L_filt ++ L'_filt ++ [ψ ∨ F(ψ)]
      let Γ := L_filt ++ L'_filt ++ [Formula.or ψ (Formula.some_future ψ)]
      have h_Γ_in_v : ∀ χ ∈ Γ, χ ∈ v := by
        intro χ hχ
        simp only [Γ, List.mem_append, List.mem_singleton] at hχ
        rcases hχ with (h1 | h2) | h3
        · exact h_L_filt_in_v χ h1
        · exact h_L'_filt_in_v χ h2
        · rw [h3]; exact h_disj_in_succ
      -- Now derive ⊥ from Γ using propositional logic
      -- Γ = L_filt ++ L'_filt ++ [or ψ (F ψ)]
      -- So L_filt ⊆ L_filt ++ L'_filt ⊆ Γ
      have h_L_filt_sub_Γ : L_filt ⊆ Γ := by
        intro χ hχ
        simp only [Γ, List.mem_append, List.mem_singleton]
        left; left; exact hχ
      have d_neg_ψ' : Γ ⊢ Formula.neg ψ :=
        DerivationTree.weakening L_filt Γ _ d_neg_ψ h_L_filt_sub_Γ
      have h_L'_filt_sub_Γ : L'_filt ⊆ Γ := by
        intro χ hχ
        simp only [Γ, List.mem_append, List.mem_singleton]
        left; right; exact hχ
      have d_neg_F' : Γ ⊢ Formula.neg (Formula.some_future ψ) :=
        DerivationTree.weakening L'_filt Γ _ d_neg_F h_L'_filt_sub_Γ
      have h_or_in_Γ : Formula.or ψ (Formula.some_future ψ) ∈ Γ :=
        List.mem_append_right _ (List.mem_singleton_self _)
      have d_or : Γ ⊢ Formula.or ψ (Formula.some_future ψ) :=
        DerivationTree.assumption Γ _ h_or_in_Γ
      -- Use disjunctive syllogism: (ψ ∨ F(ψ)) ∧ ¬ψ → F(ψ)
      -- Then F(ψ) ∧ ¬F(ψ) → ⊥
      -- We derive ⊥ from the disjunction and both negations.
      -- Standard propositional logic derivation:
      -- 1. From ψ ∨ F(ψ) and ¬ψ and ¬F(ψ):
      -- 2. By case elimination: if ψ then ⊥ (from ψ and ¬ψ), if F(ψ) then ⊥ (from F(ψ) and ¬F(ψ))
      -- 3. Both cases lead to ⊥, so ⊥
      -- This requires a derivation of: (A ∨ B) → ¬A → ¬B → ⊥
      -- Using modus ponens with A ∨ B and the derived implication:
      -- (A → ⊥) → (B → ⊥) → (A ∨ B) → ⊥
      -- We have: d_neg_ψ' : Γ ⊢ ψ → ⊥  (since ¬ψ = ψ → ⊥)
      -- We have: d_neg_F' : Γ ⊢ F(ψ) → ⊥  (since ¬F(ψ) = F(ψ) → ⊥)
      -- We have: d_or : Γ ⊢ ψ ∨ F(ψ)
      -- By or-elimination theorem: Γ ⊢ ⊥
      have d_bot3 : Γ ⊢ Formula.bot :=
        Bimodal.Theorems.Propositional.or_elim_neg_neg Γ ψ (Formula.some_future ψ)
          d_or d_neg_ψ' d_neg_F'
      exact False.elim (h_v_mcs.1.2 Γ h_Γ_in_v ⟨d_bot3⟩)

/--
The restricted successor satisfies the Succ relation: Succ u v.
-/
theorem constrained_successor_restricted_succ (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Succ u (constrained_successor_restricted phi u h_mcs h_F_top) :=
  ⟨constrained_successor_restricted_g_persistence phi u h_mcs h_F_top,
   constrained_successor_restricted_f_step phi u h_mcs h_F_top⟩

/--
P-step for restricted successor: p_content(v) ⊆ u ∪ p_content(u).

This is the key property that uses the restricted P-step blocking formulas.
If P(chi) appears in the successor v and chi ∉ u and P(chi) ∉ u, then:
1. P(chi) ∈ v ⊆ deferralClosure implies P(chi) ∈ deferralClosure
2. By restricted blocking definition, H(neg chi) ∈ p_step_blocking_formulas_restricted
3. H(neg chi) ∈ seed ⊆ v
4. But P(chi) = neg(H(neg chi)) ∈ v contradicts MCS consistency with H(neg chi) ∈ v
-/
theorem constrained_successor_restricted_p_step (phi : Formula) (u : Set Formula)
    (h_mcs : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    p_content (constrained_successor_restricted phi u h_mcs h_F_top) ⊆ u ∪ p_content u := by
  intro chi h_chi_in_p_content
  -- h_chi_in_p_content : P(chi) ∈ v, so chi ∈ p_content(v)
  let v := constrained_successor_restricted phi u h_mcs h_F_top
  have h_v_mcs := constrained_successor_restricted_is_mcs phi u h_mcs h_F_top
  have h_P_chi_in_v : Formula.some_past chi ∈ v := h_chi_in_p_content
  -- We need: chi ∈ u ∨ P(chi) ∈ u
  by_cases h_chi_in_u : chi ∈ u
  · exact Set.mem_union_left _ h_chi_in_u
  · by_cases h_P_chi_in_u : Formula.some_past chi ∈ u
    · exact Set.mem_union_right _ h_P_chi_in_u
    · -- chi ∉ u and P(chi) ∉ u — derive contradiction
      -- P(chi) ∈ v ⊆ deferralClosure implies P(chi) ∈ deferralClosure
      have h_P_chi_in_dc : Formula.some_past chi ∈
          (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
        h_v_mcs.1.1 h_P_chi_in_v
      -- By restricted blocking definition, H(neg chi) is in the restricted blocking set
      have h_block : Formula.all_past (Formula.neg chi) ∈
          p_step_blocking_formulas_restricted phi u :=
        ⟨chi, h_P_chi_in_dc, h_P_chi_in_u, h_chi_in_u, rfl⟩
      -- H(neg chi) ∈ seed ⊆ v
      have h_in_seed : Formula.all_past (Formula.neg chi) ∈
          constrained_successor_seed_restricted phi u :=
        p_step_blocking_restricted_subset_constrained_successor_seed_restricted phi u h_block
      have h_H_in_v : Formula.all_past (Formula.neg chi) ∈ v :=
        constrained_successor_restricted_extends phi u h_mcs h_F_top h_in_seed
      -- But P(chi) = neg(H(neg chi)) ∈ v contradicts consistency with H(neg chi) ∈ v
      exact False.elim (Bimodal.Metalogic.Core.set_consistent_not_both h_v_mcs.1.2
        (Formula.all_past (Formula.neg chi)) h_H_in_v h_P_chi_in_v)

/-!
## Phase 5: Restricted Chain Construction

Build the restricted successor chain starting from a DeferralRestrictedMCS that contains
both F_top and P_top (a "serial" DeferralRestrictedMCS).

The key insight is that F_top and P_top are theorems, so they are in any consistent set
that is closed under derivation. For DeferralRestrictedMCS, we need F_top and P_top to
be in deferralClosure phi to ensure the restricted closure property is maintained.
-/

/--
A serial DeferralRestrictedMCS: a DeferralRestrictedMCS that also contains F_top and P_top.
This is the starting point for the restricted chain construction.
-/
structure DeferralRestrictedSerialMCS (phi : Formula) where
  world : Set Formula
  is_drm : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi world
  has_F_top : F_top ∈ world
  has_P_top : P_top ∈ world

/--
Coerce DeferralRestrictedSerialMCS to its underlying DeferralRestrictedMCS.
-/
def DeferralRestrictedSerialMCS.toDeferralRestrictedMCS {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) :
    Bimodal.Metalogic.Core.DeferralRestrictedMCS phi M.world :=
  M.is_drm

/--
A restricted forward chain element: a DeferralRestrictedMCS with F_top.
This bundles the MCS, its restriction proof, and F_top membership.
-/
structure RestrictedForwardChainElement (phi : Formula) where
  world : Set Formula
  is_drm : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi world
  has_F_top : F_top ∈ world

/--
F_top propagates through the restricted successor because F_top is a theorem.
The restricted successor is a DeferralRestrictedMCS, hence consistent and closed
under derivation for formulas in deferralClosure.
-/
theorem F_top_in_restricted_successor (phi : Formula) (u : Set Formula)
    (h_drm : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi u)
    (h_F_top : F_top ∈ u) :
    F_top ∈ constrained_successor_restricted phi u h_drm h_F_top := by
  -- F_top is a theorem, and the restricted successor is consistent
  -- Since F_top ∈ deferralClosure phi (it's a basic formula from seriality),
  -- the DeferralRestrictedMCS property ensures F_top is in the successor if
  -- excluding it would make the set inconsistent.
  -- Actually, F_top is in the seed if G(neg bot) ∈ u (which it is, since u is consistent MCS-like).
  -- Simpler: F_top is a theorem, so adding it to any consistent set keeps it consistent.
  -- For DeferralRestrictedMCS, the maximality within deferralClosure ensures F_top is in
  -- the successor if F_top ∈ deferralClosure and excluding it would be inconsistent.
  --
  -- Key fact: F_top = F(neg bot) is in deferralClosure phi for any phi (it has no subformulas
  -- that reference phi, so it's in the base of any closure).
  -- Actually, we need to be more careful. F(neg bot) is in deferralClosure iff neg bot is in
  -- closureWithNeg, which requires neg bot to be a subformula of phi or its negation.
  -- This is NOT necessarily true for arbitrary phi.
  --
  -- However, the restricted successor is built from Lindenbaum extension of a consistent seed.
  -- The result is a DeferralRestrictedMCS, which by definition is maximal within deferralClosure.
  -- If F_top were not in the result, then its negation G(neg (neg bot)) = G(bot) would need to
  -- be derivable, but that contradicts consistency.
  --
  -- The cleanest approach: the successor extends the seed which contains g_content(u).
  -- If G(neg bot) ∈ u (which follows from u being consistent, since G(neg bot) is a theorem),
  -- then neg bot ∈ g_content(u) ⊆ seed ⊆ successor.
  -- But we need F_top = F(neg bot), not neg bot.
  --
  -- Alternative: Since the successor is a DeferralRestrictedMCS, it's consistent.
  -- F_top = F(neg bot) is a theorem. If F_top were not in the successor, then by
  -- DeferralRestrictedMCS maximality (for formulas in deferralClosure), adding F_top
  -- would make it inconsistent. But theorems can always be added to consistent sets.
  -- So if F_top ∈ deferralClosure, it must be in the successor.
  --
  -- The question is whether F_top ∈ deferralClosure phi.
  -- deferralClosure phi = closureWithNeg phi ∪ {ψ ∨ F(ψ) | F(ψ) ∈ closureWithNeg}
  --                                          ∪ {ψ ∨ P(ψ) | P(ψ) ∈ closureWithNeg}
  -- For F_top = F(neg bot) to be in deferralClosure, we need F(neg bot) ∈ closureWithNeg phi.
  -- closureWithNeg phi contains phi and all subformulas, plus negations.
  -- F(neg bot) is only in closureWithNeg phi if it's a subformula of phi (or its negation).
  --
  -- This is a problem! F_top may NOT be in deferralClosure phi for arbitrary phi.
  --
  -- SOLUTION: For the completeness proof, we start with phi being the formula we want to
  -- prove consistent. We need phi to "contain" F_top and P_top in some sense, or we need
  -- to explicitly add them to the closure.
  --
  -- For now, we'll use the fact that the constrained_successor_restricted_is_mcs gives us
  -- a DeferralRestrictedMCS, and check if F_top can be proven to be in it directly.
  --
  -- Actually, looking at the construction more carefully:
  -- constrained_successor_restricted uses deferral_restricted_lindenbaum which produces
  -- a DeferralRestrictedMCS. The DeferralRestrictedMCS property only guarantees maximality
  -- for formulas IN deferralClosure.
  --
  -- But the underlying set IS consistent (by DeferralRestrictedConsistent).
  -- And any consistent set can be extended to include theorems.
  -- The question is whether the Lindenbaum extension might have added neg(F_top) = G(bot).
  --
  -- G(bot) is NOT a theorem (it says "always false"), so adding it would make the set
  -- inconsistent. Therefore, G(bot) ∉ successor.
  -- By MCS maximality within closure, if F_top = neg(G(bot)) is in deferralClosure,
  -- then F_top ∈ successor.
  --
  -- If F_top is NOT in deferralClosure, we need a different argument.
  -- But actually, looking at constrained_successor_restricted_is_mcs, it returns
  -- DeferralRestrictedMCS, not SetMaximalConsistent. So we cannot directly use
  -- negation completeness for formulas outside deferralClosure.
  --
  -- WORKAROUND: Assume F_top ∈ deferralClosure phi. For the completeness proof,
  -- we can ensure this by considering closures that include seriality formulas.
  -- For now, we'll use the fact that the seed contains theorems indirectly.
  --
  -- Actually, let's check: is G(neg bot) ∈ u? If u is a DeferralRestrictedMCS,
  -- it's consistent, and G(neg bot) is a theorem. If G(neg bot) ∈ deferralClosure phi,
  -- then by maximality, G(neg bot) ∈ u. Then neg bot ∈ g_content(u) ⊆ seed ⊆ successor.
  -- But we need F(neg bot), not neg bot.
  --
  -- The seed contains deferralDisjunctions: {ψ ∨ F(ψ) | F(ψ) ∈ u}.
  -- If F(neg bot) ∈ u = F_top ∈ u (given), then (neg bot) ∨ F(neg bot) ∈ seed.
  -- So (neg bot) ∨ F_top ∈ successor.
  -- By disjunction elimination (since successor is consistent): neg bot ∈ successor or F_top ∈ successor.
  -- Both are consistent to add, so by MCS property... but we only have DeferralRestrictedMCS.
  --
  -- KEY INSIGHT: deferralDisjunction(neg bot) = (neg bot) ∨ F(neg bot) ∈ deferralClosure
  -- because F(neg bot) ∈ u ⊆ deferralClosure, so the deferral formula is in deferralClosure.
  -- The successor is a DeferralRestrictedMCS, so for formulas in deferralClosure, it behaves
  -- like an MCS. So either neg bot ∈ successor or F(neg bot) ∈ successor (disjunction property).
  --
  -- Now, is neg bot ∈ deferralClosure? neg bot = bot → bot, which is a basic propositional
  -- formula. It's in closureWithNeg phi if bot is a subformula... bot is the base case,
  -- but whether neg bot ∈ closureWithNeg depends on phi.
  --
  -- Hmm, this is getting complicated. Let me take a simpler approach:
  -- The successor is a DeferralRestrictedMCS, hence consistent.
  -- We'll prove F_top is in it by showing its negation leads to contradiction.
  --
  -- If F_top ∉ successor, then by DeferralRestrictedMCS maximality (if F_top ∈ deferralClosure),
  -- inserting F_top would make it inconsistent. But F_top is a theorem, so this is impossible.
  -- Therefore F_top ∈ successor (assuming F_top ∈ deferralClosure).
  -- KEY INSIGHT: We follow the same pattern as constrained_successor_restricted_f_step.
  -- F_top ∈ u, so the deferral disjunction (neg bot) ∨ F_top is in the seed.
  -- The successor extends the seed, so (neg bot) ∨ F_top ∈ successor.
  -- Since F_top ∈ u ⊆ deferralClosure phi, F_top ∈ deferralClosure phi.
  -- By the disjunction argument, either neg bot or F_top must be in the successor.
  -- We show by contradiction (same as the f_step proof) that one must be in.
  --
  let ψ := Formula.neg Formula.bot  -- the inner formula of F_top
  -- F_top = F(ψ) ∈ u
  have h_F_ψ : Formula.some_future ψ ∈ u := h_F_top
  -- The deferral disjunction ψ ∨ F(ψ) is in the seed
  have h_disj_in_seed : deferralDisjunction ψ ∈ constrained_successor_seed_restricted phi u :=
    deferralDisjunctions_subset_constrained_successor_seed_restricted phi u ⟨ψ, h_F_ψ, rfl⟩
  -- Hence in the successor
  let v := constrained_successor_restricted phi u h_drm h_F_top
  have h_disj_in_succ : deferralDisjunction ψ ∈ v :=
    constrained_successor_restricted_extends phi u h_drm h_F_top h_disj_in_seed
  have h_v_mcs := constrained_successor_restricted_is_mcs phi u h_drm h_F_top
  -- F_top ∈ deferralClosure phi (since F_top ∈ u ⊆ deferralClosure phi)
  have h_F_top_in_dc : Formula.some_future ψ ∈ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
    h_drm.1.1 h_F_top
  -- From F_top ∈ deferralClosure, ψ = neg bot is in subformulaClosure hence deferralClosure
  have h_F_ψ_in_cwn := Bimodal.Syntax.some_future_in_deferralClosure_is_in_closureWithNeg phi ψ h_F_top_in_dc
  have h_ψ_in_sub := Bimodal.Syntax.some_future_in_closureWithNeg_inner_in_subformulaClosure phi ψ h_F_ψ_in_cwn
  have h_ψ_in_dc : ψ ∈ (Bimodal.Syntax.deferralClosure phi : Set Formula) :=
    Bimodal.Syntax.closureWithNeg_subset_deferralClosure phi
      (Bimodal.Syntax.subformulaClosure_subset_closureWithNeg phi h_ψ_in_sub)
  -- Now we prove F_top ∈ v by showing one of ψ or F(ψ) must be in v
  unfold deferralDisjunction at h_disj_in_succ
  by_cases h_F_ψ_in : Formula.some_future ψ ∈ v
  · -- F_top ∈ v, done
    exact h_F_ψ_in
  · -- F_top ∉ v, so we must show ψ ∈ v... actually we need to show this leads to F_top ∈ v
    -- Since F_top ∉ v and F_top ∈ deferralClosure, insert F_top v is inconsistent
    have h_insert_F_incons := h_v_mcs.2 (Formula.some_future ψ) h_F_top_in_dc h_F_ψ_in
    -- insert F_top v is inconsistent, so there exists L ⊆ v such that L ∪ {F_top} ⊢ ⊥
    unfold SetConsistent at h_insert_F_incons
    push_neg at h_insert_F_incons
    obtain ⟨L', h_L'_sub, h_L'_incons⟩ := h_insert_F_incons
    obtain ⟨d_bot'⟩ := Bimodal.Metalogic.Core.inconsistent_derives_bot h_L'_incons
    -- From L' ∪ {F(ψ)} ⊢ ⊥, get L' ⊢ ¬F(ψ) by deduction theorem
    let L'_filt := L'.filter (· ≠ Formula.some_future ψ)
    have h_L'_filt_in_v : ∀ χ ∈ L'_filt, χ ∈ v := by
      intro χ hχ
      have hχ' := List.mem_filter.mp hχ
      have hχne : χ ≠ Formula.some_future ψ := by simpa using hχ'.2
      specialize h_L'_sub χ hχ'.1
      simp [Set.mem_insert_iff] at h_L'_sub
      rcases h_L'_sub with rfl | h_in
      · exact absurd rfl hχne
      · exact h_in
    have h_L'_sub' : L' ⊆ Formula.some_future ψ :: L'_filt := by
      intro χ hχ
      by_cases hχF : χ = Formula.some_future ψ
      · simp [hχF]
      · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχF⟩)
    have d_bot2 := DerivationTree.weakening L' _ Formula.bot d_bot' h_L'_sub'
    have d_neg_F : L'_filt ⊢ Formula.neg (Formula.some_future ψ) :=
      Bimodal.Metalogic.Core.deduction_theorem L'_filt (Formula.some_future ψ) Formula.bot d_bot2
    -- Now check if ψ ∈ v
    by_cases h_ψ_in : ψ ∈ v
    · -- ψ ∈ v. We have ψ ∨ F(ψ) ∈ v, ψ ∈ v, and we derived ¬F(ψ).
      -- Now use: ψ → F(ψ) is derivable (by F-axiom: φ → F(φ))
      -- So from ψ we get F(ψ), and then F(ψ) ∧ ¬F(ψ) → ⊥
      -- Actually, F_top is a theorem! So if v is consistent, F_top must be in v by maximality.
      -- Since F_top ∈ deferralClosure and F_top ∉ v, insert F_top v is inconsistent.
      -- But F_top is a theorem, so any superset containing F_top of a consistent set is consistent.
      -- Contradiction!
      -- We have: L'_filt ⊢ ¬F_top (d_neg_F), and L'_filt ⊆ v
      -- Also F_top is a theorem: [] ⊢ F_top
      -- So L'_filt ⊢ F_top (by weakening)
      -- Then L'_filt ⊢ ⊥ (from F_top and ¬F_top)
      -- But L'_filt ⊆ v and v is consistent, contradiction.
      have d_F_top_from_empty : ([] : List Formula) ⊢ Formula.some_future ψ := F_top_theorem
      have d_F_top : L'_filt ⊢ Formula.some_future ψ :=
        DerivationTree.weakening [] L'_filt _ d_F_top_from_empty (List.nil_subset _)
      have d_bot_final : L'_filt ⊢ Formula.bot :=
        Bimodal.Metalogic.Core.derives_bot_from_phi_neg_phi d_F_top d_neg_F
      exact False.elim (h_v_mcs.1.2 L'_filt h_L'_filt_in_v ⟨d_bot_final⟩)
    · -- Neither ψ nor F(ψ) is in v, but ψ ∨ F(ψ) ∈ v
      -- This contradicts DeferralRestrictedMCS property (same as f_step proof)
      have h_insert_ψ_incons := h_v_mcs.2 ψ h_ψ_in_dc h_ψ_in
      unfold SetConsistent at h_insert_ψ_incons
      push_neg at h_insert_ψ_incons
      obtain ⟨L, h_L_sub, h_L_incons⟩ := h_insert_ψ_incons
      obtain ⟨d_bot⟩ := Bimodal.Metalogic.Core.inconsistent_derives_bot h_L_incons
      let L_filt := L.filter (· ≠ ψ)
      have h_L_filt_in_v : ∀ χ ∈ L_filt, χ ∈ v := by
        intro χ hχ
        have hχ' := List.mem_filter.mp hχ
        have hχne : χ ≠ ψ := by simpa using hχ'.2
        specialize h_L_sub χ hχ'.1
        simp [Set.mem_insert_iff] at h_L_sub
        rcases h_L_sub with rfl | h_in
        · exact absurd rfl hχne
        · exact h_in
      have h_L_sub' : L ⊆ ψ :: L_filt := by
        intro χ hχ
        by_cases hχψ : χ = ψ
        · simp [hχψ]
        · exact List.mem_cons_of_mem _ (List.mem_filter.mpr ⟨hχ, by simpa using hχψ⟩)
      have d_bot1 := DerivationTree.weakening L _ Formula.bot d_bot h_L_sub'
      have d_neg_ψ : L_filt ⊢ Formula.neg ψ :=
        Bimodal.Metalogic.Core.deduction_theorem L_filt ψ Formula.bot d_bot1
      -- Now combine: L_filt ⊢ ¬ψ, L'_filt ⊢ ¬F(ψ), and v has ψ ∨ F(ψ)
      let Γ := L_filt ++ L'_filt ++ [Formula.or ψ (Formula.some_future ψ)]
      have h_Γ_in_v : ∀ χ ∈ Γ, χ ∈ v := by
        intro χ hχ
        simp only [Γ, List.mem_append, List.mem_singleton] at hχ
        rcases hχ with (h1 | h2) | h3
        · exact h_L_filt_in_v χ h1
        · exact h_L'_filt_in_v χ h2
        · rw [h3]; exact h_disj_in_succ
      have h_L_filt_sub_Γ : L_filt ⊆ Γ := by
        intro χ hχ
        simp only [Γ, List.mem_append, List.mem_singleton]
        left; left; exact hχ
      have d_neg_ψ' : Γ ⊢ Formula.neg ψ :=
        DerivationTree.weakening L_filt Γ _ d_neg_ψ h_L_filt_sub_Γ
      have h_L'_filt_sub_Γ : L'_filt ⊆ Γ := by
        intro χ hχ
        simp only [Γ, List.mem_append, List.mem_singleton]
        left; right; exact hχ
      have d_neg_F' : Γ ⊢ Formula.neg (Formula.some_future ψ) :=
        DerivationTree.weakening L'_filt Γ _ d_neg_F h_L'_filt_sub_Γ
      have h_or_in_Γ : Formula.or ψ (Formula.some_future ψ) ∈ Γ :=
        List.mem_append_right _ (List.mem_singleton_self _)
      have d_or : Γ ⊢ Formula.or ψ (Formula.some_future ψ) :=
        DerivationTree.assumption Γ _ h_or_in_Γ
      have d_bot3 : Γ ⊢ Formula.bot :=
        Bimodal.Theorems.Propositional.or_elim_neg_neg Γ ψ (Formula.some_future ψ)
          d_or d_neg_ψ' d_neg_F'
      exact False.elim (h_v_mcs.1.2 Γ h_Γ_in_v ⟨d_bot3⟩)

/--
Build the next restricted forward chain element from the current one.
-/
noncomputable def RestrictedForwardChainElement.next (phi : Formula)
    (e : RestrictedForwardChainElement phi) : RestrictedForwardChainElement phi where
  world := constrained_successor_restricted phi e.world e.is_drm e.has_F_top
  is_drm := constrained_successor_restricted_is_mcs phi e.world e.is_drm e.has_F_top
  has_F_top := F_top_in_restricted_successor phi e.world e.is_drm e.has_F_top

/--
Build restricted forward chain element at index n.
-/
noncomputable def restrictedForwardChainAt (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) : Nat → RestrictedForwardChainElement phi
  | 0 => ⟨M0.world, M0.is_drm, M0.has_F_top⟩
  | n + 1 => (restrictedForwardChainAt phi M0 n).next phi

/--
Restricted forward chain world at index n.
-/
noncomputable def restricted_forward_chain (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) : Set Formula :=
  (restrictedForwardChainAt phi M0 n).world

/--
Restricted forward chain elements are DeferralRestrictedMCS.
-/
theorem restricted_forward_chain_is_drm (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    Bimodal.Metalogic.Core.DeferralRestrictedMCS phi (restricted_forward_chain phi M0 n) :=
  (restrictedForwardChainAt phi M0 n).is_drm

/--
Restricted forward chain elements contain F_top.
-/
theorem restricted_forward_chain_has_F_top (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    F_top ∈ restricted_forward_chain phi M0 n :=
  (restrictedForwardChainAt phi M0 n).has_F_top

/--
restricted_forward_chain phi M0 0 = M0.world
-/
@[simp]
theorem restricted_forward_chain_zero (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) :
    restricted_forward_chain phi M0 0 = M0.world := rfl

/--
Adjacent restricted forward chain elements satisfy Succ.
-/
theorem restricted_forward_chain_succ (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    Succ (restricted_forward_chain phi M0 n) (restricted_forward_chain phi M0 (n + 1)) :=
  constrained_successor_restricted_succ phi
    (restricted_forward_chain phi M0 n)
    (restricted_forward_chain_is_drm phi M0 n)
    (restricted_forward_chain_has_F_top phi M0 n)

/--
P-step property for restricted forward chain: the successor's P-content flows back.
-/
theorem restricted_forward_chain_p_step (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    p_content (restricted_forward_chain phi M0 (n + 1)) ⊆
    (restricted_forward_chain phi M0 n) ∪ p_content (restricted_forward_chain phi M0 n) :=
  constrained_successor_restricted_p_step phi
    (restricted_forward_chain phi M0 n)
    (restricted_forward_chain_is_drm phi M0 n)
    (restricted_forward_chain_has_F_top phi M0 n)

/-!
## F-Nesting Boundedness for Restricted Forward Chain

The key property: F-iterations are bounded in DeferralRestrictedMCS.
This follows directly from `deferral_restricted_mcs_F_bounded`.
-/

/--
F-nesting boundary in restricted forward chain.

For any psi with F(psi) in the chain at position n, there exists d >= 1 such that
iter_F d psi is in the chain at n, but iter_F (d+1) psi is not.

This is the key boundedness property that replaces the false `f_nesting_is_bounded`.
-/
theorem restricted_forward_chain_F_bounded (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d psi ∈ restricted_forward_chain phi M0 n ∧
               iter_F (d + 1) psi ∉ restricted_forward_chain phi M0 n :=
  Bimodal.Metalogic.Core.deferral_restricted_mcs_F_bounded phi psi
    (restricted_forward_chain phi M0 n)
    (restricted_forward_chain_is_drm phi M0 n)
    h_F

/--
Build CanonicalTask_forward chain for restricted forward chain.

This is the basic chain (no MCS requirement), used for structural properties.
-/
theorem restricted_forward_chain_canonicalTask_forward_from (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (d : Nat) :
    CanonicalTask_forward (restricted_forward_chain phi M0 k) d
                          (restricted_forward_chain phi M0 (k + d)) := by
  induction d generalizing k with
  | zero =>
    simp only [Nat.add_zero]
    exact CanonicalTask_forward.base
  | succ n ih =>
    -- Need: chain from k to k + (n + 1)
    -- Use: Succ from k to k+1, then chain from k+1 to k+1+n = k+(n+1)
    have h_succ := restricted_forward_chain_succ phi M0 k
    have h_chain := ih (k + 1)
    -- h_chain : CanonicalTask_forward chain(k+1) n chain(k+1+n)
    -- k+1+n = k+(n+1) by omega
    have h_eq : k + 1 + n = k + (n + 1) := by omega
    rw [h_eq] at h_chain
    exact CanonicalTask_forward.step h_succ h_chain

/-!
## Restricted Bounded Witness Theorems

These theorems prove the bounded witness lemma for DeferralRestrictedMCS chains.
The key insight is that restricted MCS have negation completeness for formulas
in subformulaClosure, and F-formulas in deferralClosure are in closureWithNeg,
hence their F-subformulas are in subformulaClosure.

**Key property**: If `FF(psi) ∈ deferralClosure phi`, then `FF(psi) ∈ subformulaClosure phi`,
so negation completeness applies.
-/



/--
Helper: F(psi) in the restricted chain at position k implies psi or F(psi) is in position k+1.

This follows from the F-step property of the restricted successor.
-/
theorem restricted_forward_chain_F_step_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 k) :
    psi ∈ restricted_forward_chain phi M0 (k + 1) ∨
    Formula.some_future psi ∈ restricted_forward_chain phi M0 (k + 1) := by
  -- F(psi) ∈ chain(k) means psi ∈ f_content(chain(k))
  -- By F-step: f_content(chain(k)) ⊆ chain(k+1) ∪ f_content(chain(k+1))
  have h_f_step := (restricted_forward_chain_succ phi M0 k).2
  have h_psi_in_f : psi ∈ f_content (restricted_forward_chain phi M0 k) := h_F
  have h_or := h_f_step h_psi_in_f
  simp only [Set.mem_union] at h_or
  exact h_or

/--
Helper: If iter_F d psi ∈ chain(k) for some d >= 1, then psi ∈ chain(k + d') for some d'.

Uses restricted_bounded_witness with the boundary from restricted_forward_chain_F_bounded.
-/
private theorem restricted_forward_chain_iter_F_witness (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k d : Nat) (psi : Formula)
    (h_d_ge : d ≥ 1)
    (h_iter : iter_F d psi ∈ restricted_forward_chain phi M0 k) :
    ∃ m : Nat, k < m ∧ psi ∈ restricted_forward_chain phi M0 m := by
  -- iter_F d psi ∈ chain(k) with d >= 1 implies F(iter_F (d-1) psi) ∈ chain(k)
  -- which means some_future (iter_F (d-1) psi) ∈ chain(k)
  -- Use F_bounded to get the boundary for iter_F (d-1) psi

  -- First, handle the case d = 1 separately or use the general approach
  -- For d >= 1, iter_F d psi = F(iter_F (d-1) psi), so iter_F (d-1) psi ∈ f_content(chain(k))

  -- Get the F-boundary using restricted_forward_chain_F_bounded
  -- We need F(something) ∈ chain(k). We have iter_F d psi ∈ chain(k).
  -- If d = 1, iter_F 1 psi = F(psi), so F(psi) ∈ chain(k).
  -- Use F_bounded on psi to get boundary d_max.

  -- Actually, the simpler approach: iter_F d psi has F-nesting depth d + f_nesting_depth(psi).
  -- The F_bounded on the inner formula gives us the boundary.

  -- For the general case: iter_F d psi ∈ chain(k) with d >= 1.
  -- We can view iter_F d psi as F^d(psi).
  -- Use F_bounded to find d_max such that iter_F d_max psi ∈ chain(k) and iter_F (d_max+1) psi ∉ chain(k).
  -- Then apply restricted_bounded_witness.

  -- The key observation: we have iter_F d psi ∈ chain(k) for some d >= 1.
  -- This means F(iter_F (d-1) psi) ∈ chain(k), i.e., some_future (iter_F (d-1) psi) ∈ chain(k).
  -- By F_bounded on iter_F (d-1) psi, there exists d' >= 1 such that:
  -- - iter_F d' (iter_F (d-1) psi) ∈ chain(k)
  -- - iter_F (d'+1) (iter_F (d-1) psi) ∉ chain(k)
  -- Note: iter_F d' (iter_F (d-1) psi) = iter_F (d' + d - 1) psi

  -- Simpler: use iter_F_implies_F to get F(psi') for some psi' in the chain
  have h_some_F : Formula.some_future (iter_F (d - 1) psi) ∈ restricted_forward_chain phi M0 k := by
    have h_eq : iter_F d psi = Formula.some_future (iter_F (d - 1) psi) := by
      obtain ⟨d', rfl⟩ : ∃ d', d = d' + 1 := ⟨d - 1, by omega⟩
      simp [iter_F_succ]
    rw [← h_eq]
    exact h_iter

  -- Apply F_bounded to iter_F (d-1) psi
  obtain ⟨d_max, h_d_max_ge, h_d_max_in, h_d_max_not⟩ :=
    restricted_forward_chain_F_bounded phi M0 k (iter_F (d - 1) psi) h_some_F

  -- iter_F d_max (iter_F (d-1) psi) = iter_F (d_max + d - 1) psi
  -- For this to work, we need to relate the boundaries.
  -- Actually, the cleanest approach: apply bounded_witness to iter_F (d-1) psi directly.

  -- iter_F d_max (iter_F (d-1) psi) ∈ chain(k)
  -- iter_F (d_max + 1) (iter_F (d-1) psi) ∉ chain(k)
  -- By bounded_witness on iter_F (d-1) psi with depth d_max:
  -- iter_F (d-1) psi ∈ chain(k + d_max)

  have h_result := restricted_bounded_witness phi M0 k (iter_F (d - 1) psi) d_max
    h_d_max_ge h_d_max_in h_d_max_not
  -- h_result : iter_F (d-1) psi ∈ chain(k + d_max)

  -- We want to show: psi ∈ chain(k + d_max + (d-1))
  -- If d = 1, then iter_F 0 psi = psi ∈ chain(k + d_max), so m = k + d_max, and k < k + d_max (since d_max >= 1).
  -- If d > 1, then iter_F (d-1) psi ∈ chain(k + d_max) with d-1 >= 1.
  --   We can recursively apply this theorem. But for simplicity, let's iterate.

  -- Base case d = 1
  by_cases h_eq : d = 1
  · -- d = 1
    subst h_eq
    simp only [Nat.sub_self, iter_F_zero] at h_result
    -- h_result : psi ∈ chain(k + d_max)
    exact ⟨k + d_max, by omega, h_result⟩
  · -- d > 1, so d - 1 >= 1
    have h_gt : d > 1 := by omega
    have h_d_minus_1_ge : d - 1 ≥ 1 := by omega
    -- Recurse with d - 1 at position k + d_max
    obtain ⟨m, h_m_gt, h_psi_in_m⟩ :=
      restricted_forward_chain_iter_F_witness phi M0 (k + d_max) (d - 1) psi h_d_minus_1_ge h_result
    -- h_m_gt : k + d_max < m
    -- h_psi_in_m : psi ∈ chain(m)
    exact ⟨m, by omega, h_psi_in_m⟩
termination_by d

theorem restricted_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ restricted_forward_chain phi M0 m := by
  -- F(psi) = iter_F 1 psi ∈ chain(n)
  have h_iter1 : iter_F 1 psi ∈ restricted_forward_chain phi M0 n := by
    simp only [iter_F_succ, iter_F_zero]
    exact h_F
  exact restricted_forward_chain_iter_F_witness phi M0 n 1 psi (Nat.le_refl 1) h_iter1

/-!
## Backward Chain Construction (P-direction)

NOTE: The backward chain requires a symmetric `constrained_predecessor_restricted` construction
that mirrors `constrained_successor_restricted`. This construction needs:
1. h_content (analogous to g_content for backward direction)
2. pastDeferralDisjunctions (analogous to deferralDisjunctions)
3. f_step_blocking_formulas_restricted (analogous to p_step_blocking_formulas_restricted)

The existing `predecessor_from_deferral_seed` in SuccExistence.lean works for general MCS,
but we need a version that stays within deferralClosure for DeferralRestrictedMCS.

Requirements are documented below.
-/

/--
A restricted backward chain element: a DeferralRestrictedMCS with P_top.
This bundles the MCS, its restriction proof, and P_top membership.

Requires constrained_predecessor_restricted.
-/
structure RestrictedBackwardChainElement (phi : Formula) where
  world : Set Formula
  is_drm : Bimodal.Metalogic.Core.DeferralRestrictedMCS phi world
  has_P_top : P_top ∈ world

/-!
## Coercion to Standard Chain Type

For compatibility with the existing FMCS infrastructure, we provide coercions from
the restricted chain types to standard chain types.
-/

/--
Extend a DeferralRestrictedSerialMCS to a full MCS using Lindenbaum's lemma.

The extension preserves F_top and P_top membership since the original set is a subset
of the extension.
-/
noncomputable def DeferralRestrictedSerialMCS.extendToMCS {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) : Set Formula :=
  (Bimodal.Metalogic.Core.set_lindenbaum M.world
    (Bimodal.Metalogic.Core.deferral_restricted_mcs_is_consistent M.is_drm)).choose

/--
The extension is a SetMaximalConsistent.
-/
theorem DeferralRestrictedSerialMCS.extendToMCS_is_mcs {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) :
    SetMaximalConsistent (M.extendToMCS) :=
  (Bimodal.Metalogic.Core.set_lindenbaum M.world
    (Bimodal.Metalogic.Core.deferral_restricted_mcs_is_consistent M.is_drm)).choose_spec.2

/--
The extension contains the original world.
-/
theorem DeferralRestrictedSerialMCS.extendToMCS_extends {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) :
    M.world ⊆ M.extendToMCS :=
  (Bimodal.Metalogic.Core.set_lindenbaum M.world
    (Bimodal.Metalogic.Core.deferral_restricted_mcs_is_consistent M.is_drm)).choose_spec.1

/--
F_top is in the extension.
-/
theorem DeferralRestrictedSerialMCS.extendToMCS_has_F_top {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) :
    F_top ∈ M.extendToMCS :=
  M.extendToMCS_extends M.has_F_top

/--
P_top is in the extension.
-/
theorem DeferralRestrictedSerialMCS.extendToMCS_has_P_top {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) :
    P_top ∈ M.extendToMCS :=
  M.extendToMCS_extends M.has_P_top

/-!
## Transfer-Back Property for Lindenbaum Extension

The key property for the Lindenbaum extension approach: formulas in deferralClosure
that are in the extension must also be in the original restricted MCS.

This follows from the maximality property of DeferralRestrictedMCS:
if psi ∈ deferralClosure and psi ∉ M, then insert psi M is inconsistent.
But ext(M) ⊇ M ∪ {psi} is consistent, so psi ∉ M leads to contradiction.
-/

/--
Transfer-back property: If psi is in the deferral closure AND in the Lindenbaum
extension, then psi is in the original restricted MCS.

This is the key lemma that enables using bounded_witness on extensions and
transferring the result back to the restricted chain.

**Proof**: By contradiction using DeferralRestrictedMCS maximality.
- Suppose psi ∈ deferralClosure and psi ∈ ext(M) but psi ∉ M.world.
- By DeferralRestrictedMCS maximality: psi ∉ M.world implies insert psi M.world is inconsistent.
- But ext(M) ⊇ M.world ∪ {psi} (since M.world ⊆ ext(M) and psi ∈ ext(M)).
- And ext(M) is consistent (it's an MCS).
- Contradiction: insert psi M.world cannot be inconsistent.
-/
theorem DeferralRestrictedSerialMCS.extendToMCS_transfer_back {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) (psi : Formula)
    (h_in_dc : psi ∈ (deferralClosure phi : Set Formula))
    (h_in_ext : psi ∈ M.extendToMCS) :
    psi ∈ M.world := by
  by_contra h_not_in_M
  -- By DeferralRestrictedMCS maximality: psi ∉ M.world implies insert psi M.world is inconsistent
  have h_incons : ¬SetConsistent (insert psi M.world) :=
    M.is_drm.2 psi h_in_dc h_not_in_M
  -- But ext(M) ⊇ insert psi M.world
  have h_subset : insert psi M.world ⊆ M.extendToMCS := by
    intro chi h_chi
    cases Set.mem_insert_iff.mp h_chi with
    | inl h_eq => exact h_eq ▸ h_in_ext
    | inr h_in_M => exact M.extendToMCS_extends h_in_M
  -- And ext(M) is consistent
  have h_cons_ext : SetConsistent M.extendToMCS := M.extendToMCS_is_mcs.1
  -- Subset of consistent set is consistent
  have h_cons_insert : SetConsistent (insert psi M.world) := by
    intro L h_L_in_insert
    apply h_cons_ext L
    intro chi h_chi_in_L
    exact h_subset (h_L_in_insert chi h_chi_in_L)
  exact h_incons h_cons_insert

/--
Transfer-back for restricted forward chain elements: If psi is in deferralClosure
and in ANY consistent superset of chain(k), then psi is in chain(k).

This is the core transfer-back lemma using DeferralRestrictedMCS maximality directly.
-/
theorem restricted_forward_chain_transfer_back (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula)
    (h_in_dc : psi ∈ (deferralClosure phi : Set Formula))
    (T : Set Formula)
    (h_superset : restricted_forward_chain phi M0 k ⊆ T)
    (h_T_cons : SetConsistent T)
    (h_psi_in_T : psi ∈ T) :
    psi ∈ restricted_forward_chain phi M0 k := by
  -- Use DeferralRestrictedMCS maximality
  by_contra h_not_in
  have h_drm := restricted_forward_chain_is_drm phi M0 k
  -- By maximality: if psi ∈ dc and psi ∉ chain(k), then insert psi chain(k) is inconsistent
  have h_incons : ¬SetConsistent (insert psi (restricted_forward_chain phi M0 k)) :=
    h_drm.2 psi h_in_dc h_not_in
  -- But insert psi chain(k) ⊆ T
  have h_sub : insert psi (restricted_forward_chain phi M0 k) ⊆ T := by
    intro chi h_chi
    cases Set.mem_insert_iff.mp h_chi with
    | inl h_eq => exact h_eq ▸ h_psi_in_T
    | inr h_in => exact h_superset h_in
  -- And T is consistent
  have h_ins_cons : SetConsistent (insert psi (restricted_forward_chain phi M0 k)) := by
    intro L h_L
    apply h_T_cons L
    intro chi h_chi_in_L
    exact h_sub (h_L chi h_chi_in_L)
  exact h_incons h_ins_cons

/--
Convert a DeferralRestrictedSerialMCS to a SerialMCS.

This uses Lindenbaum's lemma to extend the underlying DeferralRestrictedMCS to a full
SetMaximalConsistent set. The extension preserves F_top and P_top membership since
the original set is a subset of the extension.

**Note**: The resulting SerialMCS.world may be different from M.world - it's the
Lindenbaum extension, not the original set.
-/
noncomputable def DeferralRestrictedSerialMCS.toSerialMCS {phi : Formula}
    (M : DeferralRestrictedSerialMCS phi) : SerialMCS where
  world := M.extendToMCS
  is_mcs := M.extendToMCS_is_mcs
  has_F_top := M.extendToMCS_has_F_top
  has_P_top := M.extendToMCS_has_P_top

/-!
## Summary: Implementation Status

This file provides the restricted chain construction for DeferralRestrictedMCS.

**Core infrastructure**:
- `DeferralRestrictedSerialMCS` structure definition
- `RestrictedForwardChainElement` structure
- `restricted_forward_chain` construction
- `restricted_forward_chain_succ` (Succ relation between adjacent elements)
- `restricted_forward_chain_p_step` (P-step property)
- `restricted_forward_chain_F_bounded` (F-nesting boundedness)
- `restricted_forward_chain_canonicalTask_forward_from` (chain construction)
- `restricted_forward_chain_forward_F` (forward F coherence)
- `DeferralRestrictedSerialMCS.toSerialMCS` (coercion to SerialMCS via Lindenbaum extension)
- `DeferralRestrictedSerialMCS.extendToMCS_*` (extension properties)

**Restricted MCS variants** (mathematically correct):
- `f_nesting_is_bounded_restricted` - F-nesting bounds for RestrictedMCS
- `f_nesting_boundary_restricted` - F boundary for RestrictedMCS
- `p_nesting_is_bounded_restricted` - P-nesting bounds for RestrictedMCS
- `p_nesting_boundary_restricted` - P boundary for RestrictedMCS

**Open items**:
1. `constrained_predecessor_restricted` construction (symmetric to successor)
2. `restricted_backward_chain` using the predecessor construction
3. `restricted_succ_chain_fam` combining forward and backward chains
4. Full P-nesting coherence proofs

**Dead code cleanup** (task 56, 2026-03-24):
Removed ~2055 lines of deprecated/FALSE theorems:
- `restricted_single_step_forcing`, `restricted_succ_propagates_F_not`, variants (9 sorries, proven FALSE)
- `restricted_bounded_witness` (depended on FALSE theorems)
- `f_nesting_is_bounded`, `f_nesting_boundary` (mathematically FALSE for arbitrary MCS)
- `p_nesting_is_bounded`, `p_nesting_boundary` (mathematically FALSE for arbitrary MCS)
- `succ_chain_forward_F`, `succ_chain_forward_F_neg`, `succ_chain_backward_P` (depended on FALSE theorems)
- `SuccChainTemporalCoherent` (depended on FALSE theorems)
-/

end Bimodal.Metalogic.Bundle
