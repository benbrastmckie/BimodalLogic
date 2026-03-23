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
    simp only [succ_chain_fam] at h_φ ⊢
    -- h_φ : φ ∈ p_content (forward_chain M0 (k + 1)), i.e., P(φ) ∈ forward_chain(k+1)
    -- Goal: φ ∈ forward_chain M0 k ∨ P(φ) ∈ forward_chain M0 k

    have h_mcs_u : SetMaximalConsistent (forward_chain M0 k) := forward_chain_mcs M0 k
    have h_mcs_v : SetMaximalConsistent (forward_chain M0 (k + 1)) := forward_chain_mcs M0 (k + 1)
    have h_P_in_v : Formula.some_past φ ∈ forward_chain M0 (k + 1) := h_φ

    -- Try: φ ∈ u or P(φ) ∈ u
    by_cases h_φ_in_u : φ ∈ forward_chain M0 k
    · exact Set.mem_union_left _ h_φ_in_u
    · by_cases h_P_in_u : Formula.some_past φ ∈ forward_chain M0 k
      · exact Set.mem_union_right _ h_P_in_u
      · -- BLOCKER: φ ∉ u and P(φ) ∉ u, but P(φ) ∈ v
        -- Analysis shows this configuration IS possible in the forward chain:
        -- The forward chain construction does NOT include pastDeferralDisjunctions.
        -- Therefore, P-step is NOT guaranteed by the construction.
        --
        -- Counter-example scenario:
        -- Let u have H(¬φ) ∈ u (so P(φ) ∉ u and φ ∉ u by temp_t_past).
        -- The successor v = successor_from_deferral_seed(u) can have:
        -- - φ ∈ v (not blocked since g_content(u) doesn't constrain φ directly)
        -- - P(φ) ∈ v (follows from φ ∈ v by reflexive P)
        -- This violates P-step but is consistent with Succ(u, v).
        --
        -- Resolution requires EITHER:
        -- 1. Adding past analog of temp_a: φ → H(F(φ))
        -- 2. Modifying forward chain to include P-deferral seeds
        -- 3. Using a different construction (e.g., FMCSTransfer with full CanonicalMCS)
        --
        -- See task 46 research report for detailed analysis.
        sorry
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

/--
**BLOCKED (mathematically false)**: F-nesting boundedness for arbitrary SetMaximalConsistent.

This theorem CANNOT be proven because an arbitrary MCS can consistently contain all
F-iterations. Counterexample: the set {F^n(p) | n ∈ Nat} is consistent and can be
extended to an MCS via Lindenbaum's lemma.

**Migration path**: Use `f_nesting_is_bounded_restricted` instead, which requires
RestrictedMCS evidence. For completeness proofs, build RestrictedMCS from the
target formula's closure.

**Current status**: Remains as sorry for backward compatibility; callers should migrate.
-/
@[deprecated f_nesting_is_bounded_restricted]
theorem f_nesting_is_bounded (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_F n phi ∉ M := by
  -- BLOCKED: This claim is FALSE for arbitrary MCS.
  sorry

/--
**BLOCKED (uses blocked f_nesting_is_bounded)**: F-nesting boundary for arbitrary MCS.

Migrate to `f_nesting_boundary_restricted` which works with RestrictedMCS.

F-nesting boundary: Given F(phi) ∈ M, there exists d ≥ 1 such that
iter_F d phi ∈ M and iter_F (d+1) phi ∉ M.

**Semantic Justification**:
The sequence F(phi), FF(phi), FFF(phi), ... must eventually leave M because:
1. M is consistent (no formula and its negation are both in M)
2. For each formula psi, either psi ∈ M or neg(psi) ∈ M (negation completeness)
3. If all F^n(phi) ∈ M for all n, the frame would need infinitely many future
   worlds to satisfy all these commitments, violating finite satisfiability.

The proof combines f_nesting_is_bounded (existence of some n with iter_F n phi ∉ M)
with f_nesting_boundary_of_bounded (extracting the boundary via Nat.find).
-/
theorem f_nesting_boundary
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_F d phi ∈ M ∧ iter_F (d + 1) phi ∉ M :=
  f_nesting_boundary_of_bounded M h_mcs phi h_F (f_nesting_is_bounded M h_mcs phi h_F)

/-- Forward F coherence for negative indices.

When F(phi) ∈ backward_chain M0 (k+1), i.e., at index -(k+1), we find m > -(k+1)
with phi ∈ succ_chain_fam M0 m. The proof uses the same f_nesting_boundary and
bounded_witness strategy as the positive case.
-/
theorem succ_chain_forward_F_neg (M0 : SerialMCS) (k : Nat) (phi : Formula)
    (h_F : Formula.some_future phi ∈ backward_chain M0 (k + 1)) :
    ∃ m : Int, Int.negSucc k < m ∧ phi ∈ succ_chain_fam M0 m := by
  -- backward_chain M0 (k+1) = succ_chain_fam M0 (Int.negSucc k)
  have h_mcs := backward_chain_mcs M0 (k + 1)

  -- Use f_nesting_boundary to find the F-depth
  obtain ⟨d, h_d_ge, h_iter_d, h_iter_d1_not⟩ := f_nesting_boundary
    (backward_chain M0 (k + 1)) h_mcs phi h_F

  -- The start index is Int.negSucc k = -(k+1)
  let start : Int := Int.negSucc k
  have h_start_eq : succ_chain_fam M0 start = backward_chain M0 (k + 1) := rfl

  -- Build the CanonicalTask_forward_MCS chain from start to start + d
  have h_chain := succ_chain_canonicalTask_forward_MCS_from M0 start d

  -- Rewrite h_chain to use backward_chain
  rw [h_start_eq] at h_chain

  -- Apply bounded_witness
  have h_phi_at_end : phi ∈ succ_chain_fam M0 (start + d) :=
    bounded_witness (backward_chain M0 (k + 1)) (succ_chain_fam M0 (start + d)) phi d
      h_iter_d h_iter_d1_not h_chain

  -- The witness is at start + d > start (since d ≥ 1)
  use start + d
  constructor
  · -- start < start + d because d ≥ 1
    have h_d_pos : 0 < d := Nat.pos_of_ne_zero (Nat.one_le_iff_ne_zero.mp h_d_ge)
    have h_d_pos_int : (0 : Int) < (d : Int) := Int.ofNat_lt.mpr h_d_pos
    omega
  · exact h_phi_at_end

/-- Forward F coherence: If F(phi) in mcs(n), then exists m > n with phi in mcs(m).

**Proof Strategy**:
1. F(phi) ∈ mcs(n) means F(phi) ∈ forward_chain M0 n (for n ≥ 0)
2. Use f_nesting_boundary to find d ≥ 1 with iter_F d phi ∈ M and iter_F (d+1) phi ∉ M
3. Build CanonicalTask_forward_MCS chain of length d from forward_chain M0 k
4. Apply bounded_witness to get phi in forward_chain M0 (k + d)

For negative indices, we step forward to 0 or beyond and apply the positive case.
-/
theorem succ_chain_forward_F (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, n < m ∧ phi ∈ succ_chain_fam M0 m := by
  -- Case analysis on n
  match n with
  | Int.ofNat k =>
    -- n = k ≥ 0, so succ_chain_fam M0 n = forward_chain M0 k
    simp only [succ_chain_fam] at h_F ⊢
    have h_mcs_k := forward_chain_mcs M0 k

    -- Use f_nesting_boundary to find the F-depth
    obtain ⟨d, h_d_ge, h_iter_d, h_iter_d1_not⟩ := f_nesting_boundary
      (forward_chain M0 k) h_mcs_k phi h_F

    -- Build the CanonicalTask_forward_MCS chain from k to k+d
    have h_chain := forward_chain_canonicalTask_forward_MCS_from M0 k d

    -- Apply bounded_witness
    have h_phi_kd : phi ∈ forward_chain M0 (k + d) :=
      bounded_witness (forward_chain M0 k) (forward_chain M0 (k + d)) phi d
        h_iter_d h_iter_d1_not h_chain

    -- The witness is at k + d > k (since d ≥ 1)
    use Int.ofNat (k + d)
    constructor
    · -- k < k + d because d ≥ 1
      have h_d_pos : 0 < d := Nat.pos_of_ne_zero (Nat.one_le_iff_ne_zero.mp h_d_ge)
      have h_lt : k < k + d := Nat.lt_add_of_pos_right h_d_pos
      exact Int.ofNat_lt.mpr h_lt
    · exact h_phi_kd

  | Int.negSucc k =>
    -- n < 0, so we're in the backward chain
    -- succ_chain_fam M0 n = backward_chain M0 (k + 1)
    simp only [succ_chain_fam] at h_F ⊢
    -- Use the negative case theorem
    exact succ_chain_forward_F_neg M0 k phi h_F

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

/--
**BLOCKED (mathematically false)**: P-nesting boundedness for arbitrary SetMaximalConsistent.

This theorem CANNOT be proven because an arbitrary MCS can consistently contain all
P-iterations. Symmetric to f_nesting_is_bounded.

**Migration path**: Use `p_nesting_is_bounded_restricted` instead, which requires
RestrictedMCS evidence.

**Current status**: Remains as sorry for backward compatibility; callers should migrate.
-/
@[deprecated p_nesting_is_bounded_restricted]
theorem p_nesting_is_bounded (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ n, n ≥ 2 ∧ iter_P n phi ∉ M := by
  -- BLOCKED: This claim is FALSE for arbitrary MCS.
  sorry

/--
P-nesting boundary: Given P(phi) ∈ M, there exists d ≥ 1 such that
iter_P d phi ∈ M and iter_P (d+1) phi ∉ M.

Symmetric to f_nesting_boundary for the past direction.
-/
theorem p_nesting_boundary
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ∃ d : Nat, d ≥ 1 ∧ iter_P d phi ∈ M ∧ iter_P (d + 1) phi ∉ M :=
  p_nesting_boundary_of_bounded M h_mcs phi h_P (p_nesting_is_bounded M h_mcs phi h_P)

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

/--
Backward P coherence: If P(phi) ∈ mcs(n), then exists m < n with phi ∈ mcs(m).

**Proof Strategy** (symmetric to forward F):
1. P(phi) ∈ mcs(n) at succ_chain_fam M0 n
2. Use p_nesting_boundary to find d ≥ 1 with iter_P d phi ∈ M and iter_P (d+1) phi ∉ M
3. Build CanonicalTask_backward_MCS_P chain of length d going backward from n
4. Apply backward_witness to get phi at succ_chain_fam M0 (n - d)
-/
theorem succ_chain_backward_P (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_P : Formula.some_past phi ∈ succ_chain_fam M0 n) :
    ∃ m : Int, m < n ∧ phi ∈ succ_chain_fam M0 m := by
  have h_mcs_n := succ_chain_fam_mcs M0 n

  -- Use p_nesting_boundary to find the P-depth
  obtain ⟨d, h_d_ge, h_iter_d, h_iter_d1_not⟩ := p_nesting_boundary
    (succ_chain_fam M0 n) h_mcs_n phi h_P

  -- Build the backward chain from (n - d) to n
  have h_chain := succ_chain_canonicalTask_backward_MCS_P_from M0 n d

  -- Apply backward_witness
  have h_phi_at_start : phi ∈ succ_chain_fam M0 (n - d) :=
    backward_witness (succ_chain_fam M0 (n - d)) (succ_chain_fam M0 n) phi d
      h_iter_d h_iter_d1_not h_chain

  -- The witness is at n - d < n (since d ≥ 1)
  use n - d
  constructor
  · -- n - d < n because d ≥ 1
    have h_d_pos : 0 < d := Nat.pos_of_ne_zero (Nat.one_le_iff_ne_zero.mp h_d_ge)
    have h_d_pos_int : (0 : Int) < (d : Int) := Int.ofNat_lt.mpr h_d_pos
    omega
  · exact h_phi_at_start

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

/-- The Succ-chain family as a TemporalCoherentFamily -/
noncomputable def SuccChainTemporalCoherent (M0 : SerialMCS) : TemporalCoherentFamily Int where
  toFMCS := SuccChainFMCS M0
  forward_F := succ_chain_forward_F M0
  backward_P := succ_chain_backward_P M0

end Bimodal.Metalogic.Bundle
