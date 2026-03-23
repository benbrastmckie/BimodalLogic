import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.TemporalCoherence
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed
import Bimodal.Metalogic.Canonical.CanonicalTimeline
import Mathlib.Algebra.Order.Group.Int

/-!
# BFMCS Construction for D = Int

This module provides infrastructure for constructing a temporally coherent BFMCS over Int.
Given any MCS M, the goal is to construct a BFMCS over Int containing M at time 0.

**Status**: Partial implementation (4 sorries remaining - fundamental architectural blocker).
- Core chain construction complete (intChainMCS, enrichedIntChainMCS)
- G/H propagation proofs complete (no sorries)
- F/P witness proofs have FUNDAMENTAL BLOCKER (see below)

## FUNDAMENTAL LIMITATION: F/P in Linear Chains

**Why forward_F/backward_P CANNOT be proven for ANY linear chain construction**:

Linear chain constructions use Lindenbaum extension at each step. When building
position n+1 from position n, the Lindenbaum lemma can introduce G(~phi) into the
extension, which kills F(phi) = ~G(~phi). This means:
- F(phi) at position t does NOT imply F(phi) persists to later positions
- The dovetailing step where phi is processed may have already lost F(phi)

This is not a flaw in the implementation - it's a fundamental limitation of
linear chain constructions. See:
- Task 1004 research: specs/1004_dovetailing_chain_fp_witnesses/reports/
- Task 916 analysis: Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean lines 1869-1893

## Working Alternative: CanonicalFMCS

The `CanonicalFMCS` construction (from CanonicalFMCS.lean) uses ALL MCSes as
the domain instead of a linear chain. There:
- `canonicalMCS_forward_F` is trivially proven (no sorry!)
- `canonicalMCS_backward_P` is trivially proven (no sorry!)

The witness from `canonical_forward_F` is automatically a domain element
because ALL MCSes are in the domain. This is the recommended approach for
completeness proofs.

## Historical Context

The original hope was that by embedding CanonicalMCS into Int via dovetailing,
we could transfer the F/P witnesses. This fails because:
1. The embedding is not surjective (not all MCSes appear in the chain)
2. The specific witness from canonical_forward_F may not be in the chain

## The Chain Construction

Given root MCS M0 at time 0:
- For t > 0: Build forward chain using g_content extension (ExistsTask-related)
- For t < 0: Build backward chain using h_content extension

The forward_F and backward_P witnesses come from canonical_forward_F/canonical_backward_P,
and we show they must land at some Int index in our chain via a dovetailing argument.

Actually, the simpler approach: the witness MCS W from canonical_forward_F is
SOME MCS, and we include it at position t+1 (or some later position via dovetailing).

## Implementation Strategy

Use a dovetailing enumeration where at each step t, we extend the chain to
satisfy the "oldest unsatisfied" F/P obligation. This ensures all obligations
are eventually witnessed within the Int-indexed chain.

## References

- CanonicalFMCS.lean: Sorry-free CanonicalMCS construction (template)
- CanonicalFrame.lean: canonical_forward_F, canonical_backward_P lemmas
- TemporalCoherence.lean: TemporalCoherentFamily, BFMCS.temporally_coherent definitions
- Research: specs/986_bfmcs_construction_for_int/reports/research-001.md
-/

namespace Bimodal.Metalogic.Algebraic.IntBFMCS

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.ProofSystem

/-!
## Core Lemmas: Consistent Set Extension

g_content of an MCS is consistent (proven in DiscreteSuccSeed.lean).
We add the symmetric h_content_consistent here.
-/

-- Re-export from StagedConstruction
open Bimodal.Metalogic.StagedConstruction in
/-- g_content of an MCS is consistent. Alias for the existing theorem. -/
theorem g_content_consistent' (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (g_content M) :=
  g_content_consistent M h_mcs

/-- h_content of an MCS is consistent.

If M is an MCS, then h_content(M) = {φ | H(φ) ∈ M} is consistent.
Proof: If h_content(M) were inconsistent, some L ⊆ h_content(M) derives ⊥.
By generalized past K, H(L) ⊢ H(⊥). Since all H(L) are in M, H(⊥) ∈ M.
From H(⊥) we derive contradiction using seriality_past. -/
theorem h_content_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (h_content M) := by
  intro L hL_sub ⟨d⟩
  -- L ⊆ h_content(M), so for each φ ∈ L, H(φ) ∈ M
  have h_H_in_M : ∀ φ ∈ L, Formula.all_past φ ∈ M := by
    intro φ hφ
    have h_in_hc : φ ∈ h_content M := hL_sub φ hφ
    exact h_in_hc
  -- By generalized past K: H(L) ⊢ H(⊥)
  have d_H_bot : (Context.map Formula.all_past L) ⊢ Formula.all_past Formula.bot :=
    Bimodal.Theorems.generalized_past_k L Formula.bot d
  -- All H(L) are in M
  have h_H_L_in_M : ∀ φ ∈ Context.map Formula.all_past L, φ ∈ M := by
    intro φ hφ
    rw [Context.mem_map_iff] at hφ
    obtain ⟨χ, hχ_in, hχ_eq⟩ := hφ
    rw [← hχ_eq]
    exact h_H_in_M χ hχ_in
  -- So H(⊥) ∈ M
  have h_H_bot : Formula.all_past Formula.bot ∈ M :=
    SetMaximalConsistent.closed_under_derivation h_mcs _ h_H_L_in_M d_H_bot
  -- Derive contradiction: H(⊥) implies ¬P(¬⊥), but seriality_past gives P(¬⊥)
  -- We need: H(⊥) → H(¬¬⊥) (by necessitation on ⊥ → ¬¬⊥)
  -- Then P(¬⊥) = ¬H(¬¬⊥) contradicts H(¬¬⊥)
  have h_ef : [] ⊢ Formula.bot.imp (Formula.neg (Formula.neg Formula.bot)) :=
    DerivationTree.axiom [] _ (Axiom.ex_falso (Formula.neg (Formula.neg Formula.bot)))
  have h_H_ef : [] ⊢ (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot))).all_past :=
    Bimodal.Theorems.past_necessitation _ h_ef
  have h_k : [] ⊢ (Formula.bot.imp (Formula.neg (Formula.neg Formula.bot))).all_past.imp
      (Formula.bot.all_past.imp (Formula.neg (Formula.neg Formula.bot)).all_past) :=
    Bimodal.Theorems.past_k_dist Formula.bot (Formula.neg (Formula.neg Formula.bot))
  have h_imp : [] ⊢ Formula.bot.all_past.imp (Formula.neg (Formula.neg Formula.bot)).all_past :=
    DerivationTree.modus_ponens [] _ _ h_k h_H_ef
  have h_H_nnbot : (Formula.neg (Formula.neg Formula.bot)).all_past ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_imp) h_H_bot
  -- P(¬⊥) = ¬H(¬¬⊥) by definition: some_past φ = φ.neg.all_past.neg
  have h_serial : Formula.some_past (Formula.neg Formula.bot) ∈ M :=
    Bimodal.Metalogic.Canonical.SetMaximalConsistent.contains_seriality_past M h_mcs
  -- P(¬⊥) = (¬⊥).neg.all_past.neg = (¬¬⊥).all_past.neg = ¬H(¬¬⊥)
  have h_eq : Formula.some_past (Formula.neg Formula.bot) =
      Formula.neg ((Formula.neg (Formula.neg Formula.bot)).all_past) := rfl
  rw [h_eq] at h_serial
  exact set_consistent_not_both h_mcs.1 ((Formula.neg (Formula.neg Formula.bot)).all_past) h_H_nnbot h_serial

/-!
## Successor and Predecessor MCS Construction

These use Lindenbaum extension of g_content/h_content.
-/

/--
Given an MCS M, produce a successor MCS M' with ExistsTask M M'.

The successor is the Lindenbaum extension of g_content(M).
Since g_content(M) is consistent (proven in DiscreteSuccSeed), Lindenbaum gives an MCS.
ExistsTask M M' = (g_content M ⊆ M') holds by construction.
-/
noncomputable def successorMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (M' : Set Formula), SetMaximalConsistent M' ∧ ExistsTask M M' := by
  have h_cons : SetConsistent (g_content M) :=
    Bimodal.Metalogic.StagedConstruction.g_content_consistent M h_mcs
  choose W h_extends h_W_mcs using set_lindenbaum (g_content M) h_cons
  exact ⟨W, h_W_mcs, h_extends⟩

/--
Given an MCS M, produce a predecessor MCS M' with ExistsTask M' M.

The predecessor is the Lindenbaum extension of h_content(M).
The ExistsTask relation M' -> M follows from h_content/g_content duality.
-/
noncomputable def predecessorMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (M' : Set Formula), SetMaximalConsistent M' ∧ ExistsTask M' M := by
  have h_cons : SetConsistent (h_content M) := h_content_consistent M h_mcs
  choose W h_extends h_W_mcs using set_lindenbaum (h_content M) h_cons
  -- Need: ExistsTask W M, i.e., g_content W ⊆ M
  -- From h_content M ⊆ W, by duality: g_content W ⊆ M
  have h_R : ExistsTask W M :=
    h_content_subset_implies_g_content_reverse M W h_mcs h_W_mcs h_extends
  exact ⟨W, h_W_mcs, h_R⟩

/-!
## Int-Indexed Chain via Well-Founded Recursion

Define the chain by building outward from 0 using Nat recursion.
-/

/-- Positive chain: iterate successorMCS from M0. -/
noncomputable def posChain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    (n : Nat) → Σ' (M : Set Formula), SetMaximalConsistent M
  | 0 => ⟨M0, h_mcs0⟩
  | n + 1 =>
    let prev := posChain M0 h_mcs0 n
    let succ := successorMCS prev.1 prev.2
    ⟨succ.1, succ.2.1⟩

/-- Negative chain: iterate predecessorMCS from M0. -/
noncomputable def negChain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    (n : Nat) → Σ' (M : Set Formula), SetMaximalConsistent M
  | 0 => ⟨M0, h_mcs0⟩
  | n + 1 =>
    let prev := negChain M0 h_mcs0 n
    let pred := predecessorMCS prev.1 prev.2
    ⟨pred.1, pred.2.1⟩

/-- The Int-indexed MCS assignment. -/
noncomputable def intChainMCS (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Int → Set Formula :=
  fun t =>
    if h : t = 0 then M0
    else if h : t > 0 then (posChain M0 h_mcs0 t.toNat).1
    else (negChain M0 h_mcs0 ((-t).toNat)).1

/-- Each element of the Int chain is an MCS. -/
theorem intChainMCS_is_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    SetMaximalConsistent (intChainMCS M0 h_mcs0 t) := by
  unfold intChainMCS
  split_ifs with h0 hpos
  · exact h_mcs0
  · exact (posChain M0 h_mcs0 t.toNat).2
  · exact (negChain M0 h_mcs0 ((-t).toNat)).2

/-!
## ExistsTask Chain Properties

Show that consecutive elements in the chain are ExistsTask-related.
-/

/-- ExistsTask holds for consecutive positive chain elements. -/
theorem posChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    ExistsTask (posChain M0 h_mcs0 n).1 (posChain M0 h_mcs0 (n + 1)).1 := by
  -- Unfold the definition: posChain (n+1) = ⟨succ.1, succ.2.1⟩ where succ = successorMCS prev.1 prev.2
  -- successorMCS returns ⟨M', h_mcs', h_R⟩ where h_R : ExistsTask prev.1 M'
  -- So posChain (n+1).1 = successorMCS(posChain n).1
  -- And we need ExistsTask (posChain n).1 (posChain (n+1)).1
  -- = ExistsTask (posChain n).1 (successorMCS ...).1
  -- which is exactly successorMCS(...).2.2
  show ExistsTask (posChain M0 h_mcs0 n).1
       (successorMCS (posChain M0 h_mcs0 n).1 (posChain M0 h_mcs0 n).2).1
  exact (successorMCS (posChain M0 h_mcs0 n).1 (posChain M0 h_mcs0 n).2).2.2

/-- ExistsTask holds for consecutive negative chain elements (going backward). -/
theorem negChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    ExistsTask (negChain M0 h_mcs0 (n + 1)).1 (negChain M0 h_mcs0 n).1 := by
  show ExistsTask
       (predecessorMCS (negChain M0 h_mcs0 n).1 (negChain M0 h_mcs0 n).2).1
       (negChain M0 h_mcs0 n).1
  exact (predecessorMCS (negChain M0 h_mcs0 n).1 (negChain M0 h_mcs0 n).2).2.2

/-- ExistsTask holds between adjacent elements of the Int chain.
For any t, ExistsTask (intChainMCS t) (intChainMCS (t+1)) holds. -/
theorem intChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    ExistsTask (intChainMCS M0 h_mcs0 t) (intChainMCS M0 h_mcs0 (t + 1)) := by
  -- Three cases: t < 0, t = 0, t > 0
  -- When t >= 0: both sides use posChain, so posChain_canonicalR applies
  -- When t < -1: both sides use negChain, need to relate negChain indices
  -- When t = -1: left uses negChain 1, right uses posChain 0 = M0 = negChain 0
  by_cases h0 : t = 0
  · -- Case t = 0: intChainMCS 0 = M0 = posChain 0, intChainMCS 1 = posChain 1
    subst h0
    simp only [intChainMCS, Int.add_zero]
    simp only [gt_iff_lt, Int.lt_irrefl, ↓reduceDIte, Int.zero_lt_one]
    -- Now we have ExistsTask M0 (posChain M0 h_mcs0 1).1
    -- Since posChain 0 = ⟨M0, h_mcs0⟩, we need posChain_canonicalR 0
    have h := posChain_canonicalR M0 h_mcs0 0
    simp only [posChain, Nat.add_eq, Nat.add_zero] at h
    exact h
  · by_cases hpos : t > 0
    · -- Case t > 0: both use posChain
      have hpos1 : t + 1 > 0 := by omega
      simp only [intChainMCS, hpos, hpos1, h0, ↓reduceDIte]
      have hne1 : t + 1 ≠ 0 := by omega
      simp only [hne1, ↓reduceDIte]
      -- intChainMCS t = posChain t.toNat, intChainMCS (t+1) = posChain (t+1).toNat
      have h_eq : (t + 1).toNat = t.toNat + 1 := by omega
      rw [h_eq]
      exact posChain_canonicalR M0 h_mcs0 t.toNat
    · -- Case t < 0 (since t ≠ 0 and not t > 0)
      have hneg : t < 0 := by omega
      by_cases h1 : t = -1
      · -- Subcase t = -1: need ExistsTask (negChain 1) M0
        subst h1
        have h_sum : (-1 : Int) + 1 = 0 := by omega
        rw [h_sum]
        have h_lhs : intChainMCS M0 h_mcs0 (-1) = (negChain M0 h_mcs0 1).1 := by
          simp only [intChainMCS]
          split_ifs <;> simp_all
        have h_rhs : intChainMCS M0 h_mcs0 0 = M0 := by
          simp only [intChainMCS]
          split_ifs <;> simp_all
        rw [h_lhs, h_rhs]
        have h := negChain_canonicalR M0 h_mcs0 0
        simp only [negChain, Nat.add_eq] at h
        exact h
      · -- Subcase t < -1: both use negChain
        have hneg1 : t + 1 < 0 := by omega
        have hne1 : t + 1 ≠ 0 := by omega
        have hngt1 : ¬(t + 1 > 0) := by omega
        have hngt : ¬(t > 0) := by omega
        simp only [intChainMCS, h0, ↓reduceDIte, hngt, hngt1, hne1]
        -- intChainMCS t = negChain (-t).toNat
        -- intChainMCS (t+1) = negChain (-(t+1)).toNat
        -- Need: ExistsTask (negChain (-t).toNat).1 (negChain (-(t+1)).toNat).1
        -- Note: -(t+1) = -t - 1, so (-(t+1)).toNat = (-t).toNat - 1
        -- And negChain_canonicalR says: ExistsTask (negChain (n+1)) (negChain n)
        have h_idx_eq : (-(t+1)).toNat + 1 = (-t).toNat := by omega
        rw [← h_idx_eq]
        exact negChain_canonicalR M0 h_mcs0 (-(t+1)).toNat

/-!
## Forward G and Backward H Coherence

G and H coherence follow from ExistsTask transitivity along the chain.
-/

/--
ExistsTask propagates G-formulas: if ExistsTask M M' and G(phi) ∈ M, then phi ∈ M'.

This follows directly from the definition: ExistsTask M M' = g_content(M) ⊆ M',
and G(phi) ∈ M means phi ∈ g_content(M), so phi ∈ M'.
-/
theorem canonicalR_propagates_G (M M' : Set Formula)
    (h_R : ExistsTask M M') (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    phi ∈ M' :=
  h_R h_G

/--
ExistsTask propagates G-formulas to the target (G(phi) ∈ M and ExistsTask M M' implies G(phi) ∈ M').

This uses the temporal 4 axiom: G(phi) → G(G(phi)).
-/
theorem canonicalR_propagates_GG (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_R : ExistsTask M M') (phi : Formula)
    (h_G : Formula.all_future phi ∈ M) :
    Formula.all_future phi ∈ M' := by
  -- By temporal 4: G(phi) → G(G(phi))
  have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  have h_GG : Formula.all_future (Formula.all_future phi) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_G
  -- G(G(phi)) ∈ M means G(phi) ∈ g_content(M) ⊆ M'
  exact h_R h_GG

/--
Helper: G(phi) propagates forward along the chain.
If G(phi) ∈ intChainMCS t and t <= t', then G(phi) ∈ intChainMCS t'.
-/
theorem intChain_G_propagates (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t ≤ t') (h_G : Formula.all_future phi ∈ intChainMCS M0 h_mcs0 t) :
    Formula.all_future phi ∈ intChainMCS M0 h_mcs0 t' := by
  -- Induction on (t' - t).toNat
  have h_diff_nonneg : 0 ≤ t' - t := by omega
  generalize h_eq : (t' - t).toNat = k
  induction k generalizing t' with
  | zero =>
    -- k = 0 means t' - t = 0 (since t' - t >= 0), so t' = t
    have h_eq' : t' = t := by
      have := Int.toNat_of_nonneg h_diff_nonneg
      rw [h_eq] at this
      omega
    subst h_eq'
    exact h_G
  | succ n ih =>
    -- k = n + 1, so t' - t >= 1, meaning t < t'
    have h_lt : t < t' := by
      have h1 : (t' - t).toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    -- t' - 1 is between t and t' (inclusive)
    have h_t'_pred : t ≤ t' - 1 := by omega
    have h_diff' : ((t' - 1) - t).toNat = n := by
      have h1 : (t' - t).toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    have h_diff_nonneg' : 0 ≤ (t' - 1) - t := by omega
    -- By IH, G(phi) ∈ intChainMCS (t' - 1)
    have h_G_pred := ih (t' - 1) h_t'_pred h_diff_nonneg' h_diff'
    -- G(phi) propagates from t' - 1 to t' via canonicalR_propagates_GG
    have h_mcs_pred := intChainMCS_is_mcs M0 h_mcs0 (t' - 1)
    have h_R := intChain_canonicalR M0 h_mcs0 (t' - 1)
    have h_rewrite : t' - 1 + 1 = t' := by omega
    rw [h_rewrite] at h_R
    exact canonicalR_propagates_GG (intChainMCS M0 h_mcs0 (t' - 1)) (intChainMCS M0 h_mcs0 t')
      h_mcs_pred h_R phi h_G_pred

/-- Forward G: If G(phi) in mcs(t) and t < t', then phi in mcs(t'). -/
theorem intChain_forward_G (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_lt : t < t') (h_G : Formula.all_future phi ∈ intChainMCS M0 h_mcs0 t) :
    phi ∈ intChainMCS M0 h_mcs0 t' := by
  -- Strategy:
  -- 1. G(phi) ∈ mcs(t) and t < t'
  -- 2. By intChain_G_propagates, G(phi) ∈ mcs(t' - 1)
  -- 3. By ExistsTask from (t' - 1) to t', phi ∈ mcs(t')
  have h_le : t ≤ t' - 1 := by omega
  have h_G_pred := intChain_G_propagates M0 h_mcs0 t (t' - 1) phi h_le h_G
  have h_R := intChain_canonicalR M0 h_mcs0 (t' - 1)
  have h_rewrite : t' - 1 + 1 = t' := by omega
  rw [h_rewrite] at h_R
  exact canonicalR_propagates_G (intChainMCS M0 h_mcs0 (t' - 1)) (intChainMCS M0 h_mcs0 t')
    h_R phi h_G_pred

/--
ExistsTask_past holds between adjacent elements going backward.
For any t, ExistsTask_past (intChainMCS (t+1)) (intChainMCS t) holds.
This is derived from intChain_canonicalR via duality.
-/
theorem intChain_canonicalR_past (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    ExistsTask_past (intChainMCS M0 h_mcs0 (t + 1)) (intChainMCS M0 h_mcs0 t) := by
  have h_R := intChain_canonicalR M0 h_mcs0 t
  have h_mcs_t := intChainMCS_is_mcs M0 h_mcs0 t
  have h_mcs_t1 := intChainMCS_is_mcs M0 h_mcs0 (t + 1)
  exact g_content_subset_implies_h_content_reverse (intChainMCS M0 h_mcs0 t) (intChainMCS M0 h_mcs0 (t + 1))
    h_mcs_t h_mcs_t1 h_R

/--
ExistsTask_past propagates H-formulas: if ExistsTask_past M M' and H(phi) ∈ M, then phi ∈ M'.

This follows directly from the definition: ExistsTask_past M M' = h_content(M) ⊆ M',
and H(phi) ∈ M means phi ∈ h_content(M), so phi ∈ M'.
-/
theorem canonicalR_past_propagates_H (M M' : Set Formula)
    (h_R : ExistsTask_past M M') (phi : Formula) (h_H : Formula.all_past phi ∈ M) :
    phi ∈ M' :=
  h_R h_H

/--
ExistsTask_past propagates H-formulas to the target (H(phi) ∈ M and ExistsTask_past M M' implies H(phi) ∈ M').

This uses the temporal 4 axiom for H: H(phi) → H(H(phi)).
-/
theorem canonicalR_past_propagates_HH (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_R : ExistsTask_past M M') (phi : Formula)
    (h_H : Formula.all_past phi ∈ M) :
    Formula.all_past phi ∈ M' := by
  -- By temporal 4 for H: H(phi) → H(H(phi))
  have h_H4 : [] ⊢ (Formula.all_past phi).imp (Formula.all_past (Formula.all_past phi)) :=
    temp_4_past phi
  have h_HH : Formula.all_past (Formula.all_past phi) ∈ M :=
    SetMaximalConsistent.implication_property h_mcs (theorem_in_mcs h_mcs h_H4) h_H
  -- H(H(phi)) ∈ M means H(phi) ∈ h_content(M) ⊆ M'
  exact h_R h_HH

/--
Helper: H(phi) propagates backward along the chain.
If H(phi) ∈ intChainMCS t and t' <= t, then H(phi) ∈ intChainMCS t'.
-/
theorem intChain_H_propagates (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t' ≤ t) (h_H : Formula.all_past phi ∈ intChainMCS M0 h_mcs0 t) :
    Formula.all_past phi ∈ intChainMCS M0 h_mcs0 t' := by
  -- Induction on (t - t').toNat
  have h_diff_nonneg : 0 ≤ t - t' := by omega
  generalize h_eq : (t - t').toNat = k
  induction k generalizing t' with
  | zero =>
    -- k = 0 means t - t' = 0 (since t - t' >= 0), so t' = t
    have h_eq' : t' = t := by
      have := Int.toNat_of_nonneg h_diff_nonneg
      rw [h_eq] at this
      omega
    subst h_eq'
    exact h_H
  | succ n ih =>
    -- k = n + 1, so t - t' >= 1, meaning t' < t
    have h_lt : t' < t := by
      have h1 : (t - t').toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    -- t' + 1 is between t' and t (inclusive)
    have h_t'_succ : t' + 1 ≤ t := by omega
    have h_diff' : (t - (t' + 1)).toNat = n := by
      have h1 : (t - t').toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    have h_diff_nonneg' : 0 ≤ t - (t' + 1) := by omega
    -- By IH, H(phi) ∈ intChainMCS (t' + 1)
    have h_H_succ := ih (t' + 1) h_t'_succ h_diff_nonneg' h_diff'
    -- H(phi) propagates from t' + 1 to t' via canonicalR_past_propagates_HH
    have h_mcs_succ := intChainMCS_is_mcs M0 h_mcs0 (t' + 1)
    have h_R := intChain_canonicalR_past M0 h_mcs0 t'
    exact canonicalR_past_propagates_HH (intChainMCS M0 h_mcs0 (t' + 1)) (intChainMCS M0 h_mcs0 t')
      h_mcs_succ h_R phi h_H_succ

/-- Backward H: If H(phi) in mcs(t) and t' < t, then phi in mcs(t'). -/
theorem intChain_backward_H (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_lt : t' < t) (h_H : Formula.all_past phi ∈ intChainMCS M0 h_mcs0 t) :
    phi ∈ intChainMCS M0 h_mcs0 t' := by
  -- Strategy:
  -- 1. H(phi) ∈ mcs(t) and t' < t
  -- 2. By intChain_H_propagates, H(phi) ∈ mcs(t' + 1)
  -- 3. By ExistsTask_past from (t' + 1) to t', phi ∈ mcs(t')
  have h_le : t' + 1 ≤ t := by omega
  have h_H_succ := intChain_H_propagates M0 h_mcs0 t (t' + 1) phi h_le h_H
  have h_R := intChain_canonicalR_past M0 h_mcs0 t'
  exact canonicalR_past_propagates_H (intChainMCS M0 h_mcs0 (t' + 1)) (intChainMCS M0 h_mcs0 t')
    h_R phi h_H_succ

/-!
## Forward F and Backward P (The Hard Part)

This is where the construction becomes non-trivial. For forward_F, we need:
If F(phi) in mcs(t), then exists s > t with phi in mcs(s).

The witness MCS from canonical_forward_F is SOME MCS, not necessarily in our chain.
We need to show that our chain construction includes such a witness.

### Solution: The chain IS the witness

Since we're building the chain via successorMCS, which extends g_content,
we can choose at each step to prioritize witnessing a specific F-obligation.

For a proper dovetailing construction, we would enumerate all (t, phi) pairs
and ensure each F(phi) at t gets witnessed at some s > t.

For now, we use a simplified argument: canonical_forward_F gives us a witness W,
and W is SOME MCS. While W may not be in our specific chain, the chain can be
EXTENDED to include W via...

Actually, the key insight: our chain construction using g_content extension
DOES include all relevant witnesses. Here's why:

If F(psi) ∈ M at some time t, then:
1. canonical_forward_F gives witness W with ExistsTask M W and psi ∈ W
2. The witness W is constructed via Lindenbaum of {psi} ∪ g_content(M)
3. Our successorMCS at t gives M' = Lindenbaum of g_content(M)
4. Both W and M' extend g_content(M), so they're "compatible"

The problem: W may contain psi but M' (our specific successor) may not.

The solution: Modify the chain construction to use canonical_forward_F witnesses
instead of generic successorMCS.

For now, we provide the structure and mark forward_F/backward_P with sorry,
acknowledging this requires the enriched construction.
-/

/-- The basic Int FMCS (without F/P coherence proof). -/
noncomputable def intFMCS_basic (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) : FMCS Int where
  mcs := intChainMCS M0 h_mcs0
  is_mcs := intChainMCS_is_mcs M0 h_mcs0
  forward_G := intChain_forward_G M0 h_mcs0
  backward_H := intChain_backward_H M0 h_mcs0

/-!
## Enriched Dovetailing Chain Construction

The basic chain construction uses generic Lindenbaum extension at each step,
which does not guarantee that witnesses from canonical_forward_F/canonical_backward_P
appear in the chain. The enriched construction uses dovetailing to ensure
all F/P obligations are witnessed.

### Key Insight

Instead of building separate posChain/negChain using generic successorMCS,
we enumerate (position, formula) obligation pairs and place witness MCSes
from canonical_forward_F/canonical_backward_P at specific positions.

### Dovetailing Strategy

We use Cantor pairing to enumerate pairs (|t|, formula_encoding) where t ranges
over integers. The sign of t determines whether we process F (t >= 0) or P (t < 0)
obligations. When processing obligation (t, k):
- If F(decode(k)) is in the MCS at position t, get witness W from canonical_forward_F
  and assign it to the next available future position
- Symmetrically for P

### Int Encoding for Cantor Pairing

Since Cantor pairing operates on Nat x Nat, we encode Int positions as Nat:
- 0 ↦ 0
- positive n ↦ 2*n
- negative -n ↦ 2*n - 1

This ensures every Int position is enumerated.
-/

/-- Encode an Int as a Nat for use in Cantor pairing.
    Uses the standard bijection: 0 ↦ 0, n > 0 ↦ 2n, n < 0 ↦ 2|n|-1 -/
def intToNat : Int → Nat
  | 0 => 0
  | Int.ofNat (n + 1) => 2 * (n + 1)
  | Int.negSucc n => 2 * n + 1

/-- Decode a Nat back to an Int. -/
def natToInt : Nat → Int
  | 0 => 0
  | n + 1 => if n % 2 = 0 then Int.negSucc (n / 2) else Int.ofNat ((n + 1) / 2)

/-- natToInt is left inverse of intToNat. -/
theorem natToInt_intToNat (t : Int) : natToInt (intToNat t) = t := by
  cases t with
  | ofNat n =>
    cases n with
    | zero => rfl
    | succ m =>
      show natToInt (2 * (m + 1)) = Int.ofNat (m + 1)
      simp only [natToInt, show 2 * (m + 1) = (2*m + 1) + 1 by omega]
      split_ifs with h
      · omega
      · simp only [show (2 * m + 1 + 1) / 2 = m + 1 by omega]
  | negSucc n =>
    show natToInt (2 * n + 1) = Int.negSucc n
    simp only [natToInt, show 2 * n + 1 = (2 * n) + 1 by omega]
    split_ifs with h
    · simp only [show (2 * n) / 2 = n by omega]
    · omega

/-- Encodable instance for Formula (from Countable). -/
noncomputable instance formulaEncodable : Encodable Formula :=
  Encodable.ofCountable Formula

/-- Decode a Nat to Option Formula. -/
noncomputable def decodeFormula (k : Nat) : Option Formula :=
  @Encodable.decode Formula formulaEncodable k

/-- Encode a formula to Nat. -/
noncomputable def encodeFormula (phi : Formula) : Nat :=
  @Encodable.encode Formula formulaEncodable phi

/-- Encoding is injective. -/
theorem encodeFormula_injective : Function.Injective encodeFormula :=
  @Encodable.encode_injective Formula formulaEncodable

/-- Decode of encode is the formula. -/
theorem decodeFormula_encodeFormula (phi : Formula) : decodeFormula (encodeFormula phi) = some phi :=
  @Encodable.encodek Formula formulaEncodable phi

/-!
### Obligation Enumeration

An obligation is a (position, formula) pair. We enumerate using Cantor pairing
on (intToNat position, formula encoding).
-/

/-- An obligation: position t and formula phi for F/P witness processing. -/
structure Obligation where
  position : Int
  formula : Formula
  deriving DecidableEq

/-- The Nat encoding of an obligation for Cantor enumeration. -/
noncomputable def obligationToNat (obl : Obligation) : Nat :=
  Nat.pair (intToNat obl.position) (encodeFormula obl.formula)

/-- Check if a Nat decodes to a valid obligation. -/
noncomputable def natToObligation? (n : Nat) : Option Obligation :=
  let (pos_nat, formula_nat) := Nat.unpair n
  match decodeFormula formula_nat with
  | some phi => some { position := natToInt pos_nat, formula := phi }
  | none => none

/-- For every obligation, there exists an n that decodes to it. -/
theorem obligation_coverage (obl : Obligation) :
    natToObligation? (obligationToNat obl) = some obl := by
  simp only [natToObligation?, obligationToNat, Nat.unpair_pair,
             natToInt_intToNat, decodeFormula_encodeFormula]

/-!
### Enriched Chain State

The enriched chain state tracks:
- MCS assignment for each Int position (partial function)
- The next available future position for F-witnesses
- The next available past position for P-witnesses
- ExistsTask relations between adjacent assigned positions

For simplicity, we start with the basic chain as the "skeleton" and show that
all witnesses from canonical_forward_F/canonical_backward_P are already
accounted for by the existing chain structure.
-/

/-!
### Key Theorem: F-Witness Existence via Chain Embedding

The key insight for proving forward_F is that given F(phi) in mcs(t), we don't
need the SPECIFIC witness from canonical_forward_F to appear in our chain.
We just need SOME MCS M' at position s > t with phi in M' and ExistsTask mcs(t) M'.

Since our chain satisfies ExistsTask mcs(t) mcs(t+1) for all t, and
ExistsTask propagates G-formulas via Temporal 4, the question is whether
phi necessarily ends up in some future MCS.

Actually, this is exactly what fails: generic Lindenbaum extension of g_content
doesn't guarantee phi enters the chain.

The FIX: Use the witness MCS from canonical_forward_F as mcs(t+1) instead of
a generic Lindenbaum extension. This requires re-building the chain with
a dovetailing strategy that prioritizes witness obligations.

### Simplified Approach: Redefine Chain Using Canonical Witnesses

Instead of the complex dovetailing, we take a simpler approach:
1. Keep the basic chain structure with ExistsTask between adjacent elements
2. For forward_F: observe that canonical_forward_F gives witness W with
   ExistsTask mcs(t) W and phi in W
3. The key: W has ExistsTask relationship with mcs(t), and our chain has
   ExistsTask mcs(t) mcs(t+1), so W is "comparable" to mcs(t+1) by linearity

This doesn't directly place phi in the chain. The true fix requires the
enriched construction below.
-/

/-!
### Direct Proof Strategy

Given F(phi) at position t:
1. canonical_forward_F gives witness W with ExistsTask mcs(t) W and phi in W
2. W is SOME MCS (not necessarily in our chain)
3. We need to show phi appears in our chain at some s > t

Key observation: We can MODIFY the chain construction to USE the witness W
from canonical_forward_F as the next element instead of generic successorMCS.

The modification: Define enrichedPosChain that at each step (t, k):
- If decodeFormula k = some phi and F(phi) is in current MCS at t:
  - Use the witness from canonical_forward_F as the next chain element
- Otherwise: use the generic successorMCS

This ensures every F obligation is eventually witnessed.
-/

/-- Get the witness MCS for F(phi) from canonical_forward_F.
    Uses Classical.choose to extract the witness from the existential. -/
noncomputable def forwardWitnessMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    Σ' (W : Set Formula), SetMaximalConsistent W ∧ ExistsTask M W ∧ phi ∈ W :=
  let W := Classical.choose (canonical_forward_F M h_mcs phi h_F)
  let h_spec := Classical.choose_spec (canonical_forward_F M h_mcs phi h_F)
  ⟨W, h_spec.1, h_spec.2.1, h_spec.2.2⟩

/-- The witness MCS contains phi. -/
theorem forwardWitnessMCS_contains_phi (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    phi ∈ (forwardWitnessMCS M h_mcs phi h_F).1 :=
  (forwardWitnessMCS M h_mcs phi h_F).2.2.2

/-- The witness MCS has ExistsTask relation with the source. -/
theorem forwardWitnessMCS_canonicalR (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    ExistsTask M (forwardWitnessMCS M h_mcs phi h_F).1 :=
  (forwardWitnessMCS M h_mcs phi h_F).2.2.1

/-- The witness MCS is maximal consistent. -/
theorem forwardWitnessMCS_is_mcs (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_F : Formula.some_future phi ∈ M) :
    SetMaximalConsistent (forwardWitnessMCS M h_mcs phi h_F).1 :=
  (forwardWitnessMCS M h_mcs phi h_F).2.1

-- Enable classical decidability for the definitions below
attribute [local instance] Classical.propDecidable

/-- Enriched successor that uses canonical_forward_F witness when processing
    an F-obligation, otherwise falls back to generic successorMCS.
    Uses classical decidability for the F membership check. -/
noncomputable def enrichedSuccessorMCS
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (step : Nat) : Σ' (M' : Set Formula), SetMaximalConsistent M' ∧ ExistsTask M M' :=
  if h_some : (decodeFormula (Nat.unpair step).2).isSome then
    if h_F : Formula.some_future ((decodeFormula (Nat.unpair step).2).get h_some) ∈ M then
      let wit := forwardWitnessMCS M h_mcs ((decodeFormula (Nat.unpair step).2).get h_some) h_F
      ⟨wit.1, wit.2.1, wit.2.2.1⟩
    else
      successorMCS M h_mcs
  else
    successorMCS M h_mcs

/-- Get the witness MCS for P(phi) from canonical_backward_P.
    Returns (W, is_mcs, ExistsTask W M, phi ∈ W).
    Uses Classical.choose to extract the witness from the existential. -/
noncomputable def backwardWitnessMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    Σ' (W : Set Formula), SetMaximalConsistent W ∧ ExistsTask W M ∧ phi ∈ W :=
  let W := Classical.choose (canonical_backward_P M h_mcs phi h_P)
  let h_spec := Classical.choose_spec (canonical_backward_P M h_mcs phi h_P)
  let h_W_mcs := h_spec.1
  let h_R_past := h_spec.2.1
  let h_phi := h_spec.2.2
  -- ExistsTask_past M W means h_content M ⊆ W
  -- We need ExistsTask W M means g_content W ⊆ M
  let h_R : ExistsTask W M := h_content_subset_implies_g_content_reverse M W h_mcs h_W_mcs h_R_past
  ⟨W, h_W_mcs, h_R, h_phi⟩

/-- The backward witness MCS contains phi. -/
theorem backwardWitnessMCS_contains_phi (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    phi ∈ (backwardWitnessMCS M h_mcs phi h_P).1 :=
  (backwardWitnessMCS M h_mcs phi h_P).2.2.2

/-- The backward witness MCS has ExistsTask relation with the target. -/
theorem backwardWitnessMCS_canonicalR (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula) (h_P : Formula.some_past phi ∈ M) :
    ExistsTask (backwardWitnessMCS M h_mcs phi h_P).1 M :=
  (backwardWitnessMCS M h_mcs phi h_P).2.2.1

/-- Enriched predecessor that uses canonical_backward_P witness when processing
    a P-obligation, otherwise falls back to generic predecessorMCS.

    NOTE: Uses same if-pattern as enrichedSuccessorMCS for consistent handling. -/
noncomputable def enrichedPredecessorMCS
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (step : Nat) : Σ' (M' : Set Formula), SetMaximalConsistent M' ∧ ExistsTask M' M :=
  if h_some : (decodeFormula (Nat.unpair step).2).isSome then
    if h_P : Formula.some_past ((decodeFormula (Nat.unpair step).2).get h_some) ∈ M then
      let wit := backwardWitnessMCS M h_mcs ((decodeFormula (Nat.unpair step).2).get h_some) h_P
      ⟨wit.1, wit.2.1, wit.2.2.1⟩
    else
      predecessorMCS M h_mcs
  else
    predecessorMCS M h_mcs

/-!
### Enriched Chain Construction

The enriched chain is built like the basic chain but uses enrichedSuccessorMCS
and enrichedPredecessorMCS. The key property is that at each step, if there's
a matching F/P obligation, the specific witness is used.
-/

/-- Enriched positive chain using enrichedSuccessorMCS at each step. -/
noncomputable def enrichedPosChain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    (n : Nat) → Σ' (M : Set Formula), SetMaximalConsistent M
  | 0 => ⟨M0, h_mcs0⟩
  | n + 1 =>
    let prev := enrichedPosChain M0 h_mcs0 n
    let succ := enrichedSuccessorMCS prev.1 prev.2 n
    ⟨succ.1, succ.2.1⟩

/-- Enriched negative chain using enrichedPredecessorMCS at each step. -/
noncomputable def enrichedNegChain (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    (n : Nat) → Σ' (M : Set Formula), SetMaximalConsistent M
  | 0 => ⟨M0, h_mcs0⟩
  | n + 1 =>
    let prev := enrichedNegChain M0 h_mcs0 n
    let pred := enrichedPredecessorMCS prev.1 prev.2 n
    ⟨pred.1, pred.2.1⟩

/-- The enriched Int-indexed MCS assignment. -/
noncomputable def enrichedIntChainMCS (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Int → Set Formula :=
  fun t =>
    if h : t = 0 then M0
    else if h : t > 0 then (enrichedPosChain M0 h_mcs0 t.toNat).1
    else (enrichedNegChain M0 h_mcs0 ((-t).toNat)).1

/-- Each element of the enriched chain is an MCS. -/
theorem enrichedIntChainMCS_is_mcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    SetMaximalConsistent (enrichedIntChainMCS M0 h_mcs0 t) := by
  unfold enrichedIntChainMCS
  split_ifs with h0 hpos
  · exact h_mcs0
  · exact (enrichedPosChain M0 h_mcs0 t.toNat).2
  · exact (enrichedNegChain M0 h_mcs0 ((-t).toNat)).2

/-- ExistsTask holds for consecutive enriched positive chain elements. -/
theorem enrichedPosChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    ExistsTask (enrichedPosChain M0 h_mcs0 n).1 (enrichedPosChain M0 h_mcs0 (n + 1)).1 := by
  show ExistsTask (enrichedPosChain M0 h_mcs0 n).1
       (enrichedSuccessorMCS (enrichedPosChain M0 h_mcs0 n).1 (enrichedPosChain M0 h_mcs0 n).2 n).1
  exact (enrichedSuccessorMCS (enrichedPosChain M0 h_mcs0 n).1 (enrichedPosChain M0 h_mcs0 n).2 n).2.2

/-- ExistsTask holds for consecutive enriched negative chain elements (going backward). -/
theorem enrichedNegChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    ExistsTask (enrichedNegChain M0 h_mcs0 (n + 1)).1 (enrichedNegChain M0 h_mcs0 n).1 := by
  show ExistsTask
       (enrichedPredecessorMCS (enrichedNegChain M0 h_mcs0 n).1 (enrichedNegChain M0 h_mcs0 n).2 n).1
       (enrichedNegChain M0 h_mcs0 n).1
  exact (enrichedPredecessorMCS (enrichedNegChain M0 h_mcs0 n).1 (enrichedNegChain M0 h_mcs0 n).2 n).2.2

/-- ExistsTask holds between adjacent elements of the enriched Int chain. -/
theorem enrichedIntChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    ExistsTask (enrichedIntChainMCS M0 h_mcs0 t) (enrichedIntChainMCS M0 h_mcs0 (t + 1)) := by
  by_cases h0 : t = 0
  · subst h0
    simp only [enrichedIntChainMCS, Int.add_zero]
    simp only [gt_iff_lt, Int.lt_irrefl, ↓reduceDIte, Int.zero_lt_one]
    have h := enrichedPosChain_canonicalR M0 h_mcs0 0
    simp only [enrichedPosChain, Nat.add_eq, Nat.add_zero] at h
    exact h
  · by_cases hpos : t > 0
    · have hpos1 : t + 1 > 0 := by omega
      simp only [enrichedIntChainMCS, hpos, hpos1, h0, ↓reduceDIte]
      have hne1 : t + 1 ≠ 0 := by omega
      simp only [hne1, ↓reduceDIte]
      have h_eq : (t + 1).toNat = t.toNat + 1 := by omega
      rw [h_eq]
      exact enrichedPosChain_canonicalR M0 h_mcs0 t.toNat
    · have hneg : t < 0 := by omega
      by_cases h1 : t = -1
      · subst h1
        have h_sum : (-1 : Int) + 1 = 0 := by omega
        rw [h_sum]
        have h_lhs : enrichedIntChainMCS M0 h_mcs0 (-1) = (enrichedNegChain M0 h_mcs0 1).1 := by
          simp only [enrichedIntChainMCS]
          split_ifs <;> simp_all
        have h_rhs : enrichedIntChainMCS M0 h_mcs0 0 = M0 := by
          simp only [enrichedIntChainMCS]
          split_ifs <;> simp_all
        rw [h_lhs, h_rhs]
        have h := enrichedNegChain_canonicalR M0 h_mcs0 0
        simp only [enrichedNegChain, Nat.add_eq] at h
        exact h
      · have hneg1 : t + 1 < 0 := by omega
        have hne1 : t + 1 ≠ 0 := by omega
        have hngt1 : ¬(t + 1 > 0) := by omega
        have hngt : ¬(t > 0) := by omega
        simp only [enrichedIntChainMCS, h0, ↓reduceDIte, hngt, hngt1, hne1]
        have h_idx_eq : (-(t+1)).toNat + 1 = (-t).toNat := by omega
        rw [← h_idx_eq]
        exact enrichedNegChain_canonicalR M0 h_mcs0 (-(t+1)).toNat

/-!
### G and H Propagation for Enriched Chain

These follow the same pattern as the basic chain since ExistsTask holds.
-/

/-- G(phi) propagates forward along the enriched chain. -/
theorem enrichedIntChain_G_propagates (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t ≤ t')
    (h_G : Formula.all_future phi ∈ enrichedIntChainMCS M0 h_mcs0 t) :
    Formula.all_future phi ∈ enrichedIntChainMCS M0 h_mcs0 t' := by
  have h_diff_nonneg : 0 ≤ t' - t := by omega
  generalize h_eq : (t' - t).toNat = k
  induction k generalizing t' with
  | zero =>
    have h_eq' : t' = t := by
      have := Int.toNat_of_nonneg h_diff_nonneg
      rw [h_eq] at this
      omega
    subst h_eq'
    exact h_G
  | succ n ih =>
    have h_lt : t < t' := by
      have h1 : (t' - t).toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    have h_t'_pred : t ≤ t' - 1 := by omega
    have h_diff' : ((t' - 1) - t).toNat = n := by
      have h1 : (t' - t).toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    have h_diff_nonneg' : 0 ≤ (t' - 1) - t := by omega
    have h_G_pred := ih (t' - 1) h_t'_pred h_diff_nonneg' h_diff'
    have h_mcs_pred := enrichedIntChainMCS_is_mcs M0 h_mcs0 (t' - 1)
    have h_R := enrichedIntChain_canonicalR M0 h_mcs0 (t' - 1)
    have h_rewrite : t' - 1 + 1 = t' := by omega
    rw [h_rewrite] at h_R
    exact canonicalR_propagates_GG (enrichedIntChainMCS M0 h_mcs0 (t' - 1))
      (enrichedIntChainMCS M0 h_mcs0 t') h_mcs_pred h_R phi h_G_pred

/-- Forward G for enriched chain. -/
theorem enrichedIntChain_forward_G (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_lt : t < t')
    (h_G : Formula.all_future phi ∈ enrichedIntChainMCS M0 h_mcs0 t) :
    phi ∈ enrichedIntChainMCS M0 h_mcs0 t' := by
  have h_le : t ≤ t' - 1 := by omega
  have h_G_pred := enrichedIntChain_G_propagates M0 h_mcs0 t (t' - 1) phi h_le h_G
  have h_R := enrichedIntChain_canonicalR M0 h_mcs0 (t' - 1)
  have h_rewrite : t' - 1 + 1 = t' := by omega
  rw [h_rewrite] at h_R
  exact canonicalR_propagates_G (enrichedIntChainMCS M0 h_mcs0 (t' - 1))
    (enrichedIntChainMCS M0 h_mcs0 t') h_R phi h_G_pred

/-- ExistsTask_past holds between adjacent enriched chain elements going backward. -/
theorem enrichedIntChain_canonicalR_past (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    ExistsTask_past (enrichedIntChainMCS M0 h_mcs0 (t + 1)) (enrichedIntChainMCS M0 h_mcs0 t) := by
  have h_R := enrichedIntChain_canonicalR M0 h_mcs0 t
  have h_mcs_t := enrichedIntChainMCS_is_mcs M0 h_mcs0 t
  have h_mcs_t1 := enrichedIntChainMCS_is_mcs M0 h_mcs0 (t + 1)
  exact g_content_subset_implies_h_content_reverse (enrichedIntChainMCS M0 h_mcs0 t)
    (enrichedIntChainMCS M0 h_mcs0 (t + 1)) h_mcs_t h_mcs_t1 h_R

/-- H(phi) propagates backward along the enriched chain. -/
theorem enrichedIntChain_H_propagates (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_le : t' ≤ t)
    (h_H : Formula.all_past phi ∈ enrichedIntChainMCS M0 h_mcs0 t) :
    Formula.all_past phi ∈ enrichedIntChainMCS M0 h_mcs0 t' := by
  have h_diff_nonneg : 0 ≤ t - t' := by omega
  generalize h_eq : (t - t').toNat = k
  induction k generalizing t' with
  | zero =>
    have h_eq' : t' = t := by
      have := Int.toNat_of_nonneg h_diff_nonneg
      rw [h_eq] at this
      omega
    subst h_eq'
    exact h_H
  | succ n ih =>
    have h_lt : t' < t := by
      have h1 : (t - t').toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    have h_t'_succ : t' + 1 ≤ t := by omega
    have h_diff' : (t - (t' + 1)).toNat = n := by
      have h1 : (t - t').toNat = n + 1 := h_eq
      have h2 := Int.toNat_of_nonneg h_diff_nonneg
      omega
    have h_diff_nonneg' : 0 ≤ t - (t' + 1) := by omega
    have h_H_succ := ih (t' + 1) h_t'_succ h_diff_nonneg' h_diff'
    have h_mcs_succ := enrichedIntChainMCS_is_mcs M0 h_mcs0 (t' + 1)
    have h_R := enrichedIntChain_canonicalR_past M0 h_mcs0 t'
    exact canonicalR_past_propagates_HH (enrichedIntChainMCS M0 h_mcs0 (t' + 1))
      (enrichedIntChainMCS M0 h_mcs0 t') h_mcs_succ h_R phi h_H_succ

/-- Backward H for enriched chain. -/
theorem enrichedIntChain_backward_H (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t t' : Int) (phi : Formula) (h_lt : t' < t)
    (h_H : Formula.all_past phi ∈ enrichedIntChainMCS M0 h_mcs0 t) :
    phi ∈ enrichedIntChainMCS M0 h_mcs0 t' := by
  have h_le : t' + 1 ≤ t := by omega
  have h_H_succ := enrichedIntChain_H_propagates M0 h_mcs0 t (t' + 1) phi h_le h_H
  have h_R := enrichedIntChain_canonicalR_past M0 h_mcs0 t'
  exact canonicalR_past_propagates_H (enrichedIntChainMCS M0 h_mcs0 (t' + 1))
    (enrichedIntChainMCS M0 h_mcs0 t') h_R phi h_H_succ

/-!
### Forward F for Enriched Chain

The key theorem: if F(phi) is in the enriched chain at position t, then phi
appears at some position s > t.

The proof uses the fact that at step n = pair(intToNat t, encodeFormula phi),
the enrichedSuccessorMCS is called with that exact (t, phi) pair, and it
places the witness from canonical_forward_F at position t+1 (or a later
extension of that chain element).
-/

/-- Key lemma: enrichedSuccessorMCS with matching step places phi in result.
    If step n = pair(_, encodeFormula phi) and F(phi) is in M, then phi is in the result. -/
theorem enrichedSuccessorMCS_witness_phi (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (step : Nat) (phi : Formula)
    (h_step : (Nat.unpair step).2 = encodeFormula phi)
    (h_F : Formula.some_future phi ∈ M) :
    phi ∈ (enrichedSuccessorMCS M h_mcs step).1 := by
  have h_decode : decodeFormula (Nat.unpair step).2 = some phi := by
    rw [h_step, decodeFormula_encodeFormula]
  -- Unfold enrichedSuccessorMCS and simplify using h_decode and h_F
  simp only [enrichedSuccessorMCS, h_decode, Option.isSome_some, ↓reduceDIte, Option.get_some, h_F]
  -- The goal now asks for phi in forwardWitnessMCS applied to (get _ = phi)
  -- Use convert to match with forwardWitnessMCS_contains_phi applied directly to phi
  convert forwardWitnessMCS_contains_phi M h_mcs phi h_F using 3 <;>
    simp only [h_decode, Option.get_some]

/-- Intermediate lemma: If step encodes phi and position t is in positive chain,
    then phi appears in the successor when F(phi) is present. -/
theorem enrichedPosChain_witness_propagates
    (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (n step : Nat) (phi : Formula)
    (h_step : (Nat.unpair step).2 = encodeFormula phi)
    (h_step_bound : step ≤ n)
    (h_F : Formula.some_future phi ∈ (enrichedPosChain M0 h_mcs0 step).1) :
    phi ∈ (enrichedPosChain M0 h_mcs0 (step + 1)).1 := by
  show phi ∈ (enrichedSuccessorMCS (enrichedPosChain M0 h_mcs0 step).1
                                   (enrichedPosChain M0 h_mcs0 step).2 step).1
  exact enrichedSuccessorMCS_witness_phi (enrichedPosChain M0 h_mcs0 step).1
    (enrichedPosChain M0 h_mcs0 step).2 step phi h_step h_F

/-- Forward F coherence for the enriched Int FMCS.

Given F(phi) at time t in the enriched chain, there exists s > t with phi in mcs(s).
The proof uses the dovetailing property: at step pair(intToNat(t), encodeFormula(phi)),
the enrichedSuccessorMCS places a witness from canonical_forward_F.
-/
theorem enrichedIntFMCS_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ enrichedIntChainMCS M0 h_mcs0 t) :
    ∃ s : Int, t < s ∧ phi ∈ enrichedIntChainMCS M0 h_mcs0 s := by
  -- The witness appears at position t+1 if we're at the right dovetail step,
  -- or at some later position where the dovetail step aligns.
  -- Key insight: at step n = pair(intToNat(t), encodeFormula(phi)),
  -- if that step aligns with our chain position, the witness is placed.
  --
  -- More concretely: consider position t >= 0. The chain at position n uses
  -- enrichedSuccessorMCS at step (n-1). If (n-1) has formula encoding for phi,
  -- and F(phi) is in the MCS at that position, the witness is placed.
  --
  -- The actual proof requires showing:
  -- 1. There exists a chain position s > t where the step parameter
  --    equals pair(_, encodeFormula(phi))
  -- 2. At that position, F(phi) is still present (by G propagation from t)
  -- 3. The enrichedSuccessorMCS places phi in the result
  --
  -- For simplicity, we observe that at position t+1, if the step
  -- matches, we're done. Otherwise, we continue to t+2, t+3, etc.
  --
  -- The coverage theorem (forall_obligation_eventually_processed) guarantees
  -- that at some step n, the obligation (t, phi) is processed.

  -- Strategy: Find s such that enrichedPosChain step matches our obligation
  -- For t >= 0: s = (intToNat t).succ will process step = intToNat t
  -- But we need step's formula_encoding to be encodeFormula phi...

  -- The dovetailing enumeration processes step n = pair(pos, form) at chain position related to n.
  -- Key: at chain position 1 + pair(intToNat t, encodeFormula phi), the obligation is processed.

  by_cases h_t_pos : t ≥ 0
  · -- t >= 0: F(phi) is in enrichedPosChain at position t.toNat
    -- At chain position s = 1 + pair(t.toNat, encodeFormula phi), the step parameter
    -- is pair(t.toNat, encodeFormula phi), so enrichedSuccessorMCS will use
    -- the witness from canonical_forward_F IF F(phi) is present.

    -- But wait - the chain at position s uses the MCS at position s-1, not position t.
    -- So we need F(phi) to be present at position s-1.

    -- By intChain_G_propagates (for enriched chain), if G(phi') is at position t,
    -- it's also at position s-1 for s-1 >= t.
    -- But we have F(phi), not G(anything).

    -- The key insight: F(phi) at position t doesn't automatically propagate to s-1.
    -- However, canonical_forward_F gives us a witness W at position t+1 (in our chain).

    -- Actually, let's reconsider. The enrichedSuccessorMCS at step n:
    -- - Checks if decodeFormula (Nat.unpair n).2 = some phi'
    -- - If F(phi') is in the current MCS, uses canonical_forward_F witness

    -- The current MCS is the MCS at position n (for positive chain).
    -- So for F(phi) at position t to be witnessed, we need:
    -- 1. Some chain position s such that the step (s-1) has formula encoding = encodeFormula phi
    -- 2. F(phi) is present at position s-1

    -- For (1): s = pair(0, encodeFormula phi) + 1 gives step = pair(0, encodeFormula phi)
    --          which decodes to formula phi. But this is position 0, not position t.

    -- This is the fundamental issue: the basic dovetailing approach doesn't directly
    -- connect the chain position where F(phi) appears with the step where phi is decoded.

    -- REVISED APPROACH: We use the fact that canonical_forward_F gives a witness
    -- that is ExistsTask-related to the source. The enriched chain at position t+1
    -- MAY be this witness (if the step parameter encodes phi), or may be different.

    -- The correct approach is to observe that SOMEWHERE in the positive chain,
    -- there's a position s where:
    -- - step (s-1) decodes to phi
    -- - The MCS at position s-1 contains F(phi) (by G/F propagation from position t)

    -- This requires showing F(phi) propagates appropriately. F(phi) <-> ~G(~phi).
    -- If F(phi) is at position t, and position t' > t, does F(phi) remain?
    -- Not necessarily! F(phi) can become false at future positions.

    -- CORRECTION: The approach needs to handle this differently.
    -- Since we want F(phi) witnessed at s > t, we should use the witness
    -- from canonical_forward_F(mcs(t), phi, h_F) and show it appears at t+1.

    -- At position t+1, the step parameter is t (for positive chain).
    -- enrichedSuccessorMCS at step t decodes the formula Nat.unpair(t).2.
    -- This is NOT encodeFormula(phi) in general!

    -- So the enriched construction as currently designed doesn't guarantee
    -- phi is at t+1. It only places phi if the step happens to decode to phi.

    -- FUNDAMENTAL ISSUE: The dovetailing needs to be indexed differently.
    -- At position t, we need step to process obligation (t, phi).
    -- But step = t means unpair(t) = (some_pos, some_form).

    -- FUNDAMENTAL BLOCKER (Task 1004 research):
    --
    -- Linear chain constructions cannot satisfy forward_F because F-formulas
    -- don't persist through generic Lindenbaum extensions. When we build position
    -- n+1 from position n, the Lindenbaum extension can introduce G(~phi), which
    -- kills F(phi) = ~G(~phi).
    --
    -- The dovetailing approach fails because:
    -- 1. The step parameter at position s doesn't encode the position where F(phi) exists
    -- 2. Even if it did, F(phi) may have been "killed" by generic extensions along the way
    --
    -- WORKING ALTERNATIVE: Use CanonicalFMCS (from CanonicalFMCS.lean) where ALL MCSes
    -- are in the domain. There, forward_F is trivial because the witness from
    -- canonical_forward_F is automatically in the domain.
    --
    -- RESOLUTION PATH: Would require omega-squared construction that processes
    -- F-obligations IMMEDIATELY when they appear, before Lindenbaum extension.
    -- See Task 916 analysis in Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean.
    sorry
  · -- t < 0: symmetric case (same fundamental blocker applies)
    sorry

/-- Forward F coherence for Int FMCS (original basic chain).

**FUNDAMENTAL LIMITATION**: This cannot be proven for ANY linear chain construction.
F-formulas don't persist through Lindenbaum extensions because the extension can
introduce G(~phi), killing F(phi) = ~G(~phi).

**WORKING ALTERNATIVE**: Use `canonicalMCS_forward_F` from CanonicalFMCS.lean,
which uses ALL MCSes as the domain (not just a linear chain). There, forward_F
is trivially proven because the witness from `canonical_forward_F` is automatically
a domain element.

**REFERENCES**:
- Task 1004 research: specs/1004_dovetailing_chain_fp_witnesses/reports/
- Task 916 analysis: Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean lines 1869-1893
- Working proof: CanonicalFMCS.lean `canonicalMCS_forward_F`
-/
theorem intFMCS_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ intChainMCS M0 h_mcs0 t) :
    ∃ s : Int, t < s ∧ phi ∈ intChainMCS M0 h_mcs0 s := by
  sorry

/--
Backward P coherence for Int FMCS.

**FUNDAMENTAL LIMITATION**: Symmetric to forward_F. P-formulas don't persist through
Lindenbaum extensions because extensions can introduce H(~phi), killing P(phi).

**WORKING ALTERNATIVE**: Use `canonicalMCS_backward_P` from CanonicalFMCS.lean.
-/
theorem intFMCS_backward_P (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_P : Formula.some_past phi ∈ intChainMCS M0 h_mcs0 t) :
    ∃ s : Int, s < t ∧ phi ∈ intChainMCS M0 h_mcs0 s := by
  sorry

/-!
## Complete Int FMCS

With the above theorems (pending proofs for forward_F/backward_P), we can
define the complete Int FMCS with temporal coherence.
-/

-- Note: TemporalCoherentFamily requires forward_F/backward_P

/-!
## BFMCS Construction

To construct a BFMCS Int, we need:
1. A set of FMCS families
2. Modal coherence: Box phi in any family implies phi in all families
3. Temporal coherence: all families have forward_F/backward_P

For a single-family BFMCS, modal coherence is trivial (only one family).
-/

-- Placeholder for the full BFMCS construction
-- Requires completing the forward_F/backward_P proofs first

/-!
## Alternative: Use CanonicalMCS-based Construction

Since the CanonicalMCS construction (from CanonicalFMCS.lean) is sorry-free,
we can:
1. Use CanonicalMCS-indexed FMCS (which has trivial forward_F/backward_P)
2. Define an embedding Int -> CanonicalMCS (our chain)
3. Construct BFMCS Int by "pulling back" along this embedding

However, this approach changes the type from BFMCS Int to something involving
CanonicalMCS, which doesn't satisfy the algebraic infrastructure requirements.

The correct approach is to complete the dovetailing construction above.
-/

end Bimodal.Metalogic.Algebraic.IntBFMCS
