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

**Status**: Partial implementation (4 sorries remaining).
- Core chain construction complete
- G/H propagation proofs need induction formalization
- F/P witness proofs blocked by need for dovetailing construction

## Key Insight: Embedding CanonicalMCS into Int

The construction uses an **embedding from CanonicalMCS into the BFMCS families**.
Since `CanonicalMCS` (the type of ALL maximal consistent sets) has trivial
forward_F and backward_P (every witness MCS is in the domain by construction),
we leverage this by:

1. Building an Int-indexed FMCS where each `mcs(t)` is some MCS
2. For forward_F/backward_P: use the fact that `canonical_forward_F`/`canonical_backward_P`
   give us witness MCSes that exist SOMEWHERE
3. The key observation: we don't need the witness to be AT A SPECIFIC Int time,
   we just need it to be in the FMCS at SOME time with the right ordering

## The Chain Construction

Given root MCS M0 at time 0:
- For t > 0: Build forward chain using g_content extension (CanonicalR-related)
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
Given an MCS M, produce a successor MCS M' with CanonicalR M M'.

The successor is the Lindenbaum extension of g_content(M).
Since g_content(M) is consistent (proven in DiscreteSuccSeed), Lindenbaum gives an MCS.
CanonicalR M M' = (g_content M ⊆ M') holds by construction.
-/
noncomputable def successorMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (M' : Set Formula), SetMaximalConsistent M' ∧ CanonicalR M M' := by
  have h_cons : SetConsistent (g_content M) :=
    Bimodal.Metalogic.StagedConstruction.g_content_consistent M h_mcs
  choose W h_extends h_W_mcs using set_lindenbaum (g_content M) h_cons
  exact ⟨W, h_W_mcs, h_extends⟩

/--
Given an MCS M, produce a predecessor MCS M' with CanonicalR M' M.

The predecessor is the Lindenbaum extension of h_content(M).
The CanonicalR relation M' -> M follows from h_content/g_content duality.
-/
noncomputable def predecessorMCS (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (M' : Set Formula), SetMaximalConsistent M' ∧ CanonicalR M' M := by
  have h_cons : SetConsistent (h_content M) := h_content_consistent M h_mcs
  choose W h_extends h_W_mcs using set_lindenbaum (h_content M) h_cons
  -- Need: CanonicalR W M, i.e., g_content W ⊆ M
  -- From h_content M ⊆ W, by duality: g_content W ⊆ M
  have h_R : CanonicalR W M :=
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
## CanonicalR Chain Properties

Show that consecutive elements in the chain are CanonicalR-related.
-/

/-- CanonicalR holds for consecutive positive chain elements. -/
theorem posChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    CanonicalR (posChain M0 h_mcs0 n).1 (posChain M0 h_mcs0 (n + 1)).1 := by
  -- Unfold the definition: posChain (n+1) = ⟨succ.1, succ.2.1⟩ where succ = successorMCS prev.1 prev.2
  -- successorMCS returns ⟨M', h_mcs', h_R⟩ where h_R : CanonicalR prev.1 M'
  -- So posChain (n+1).1 = successorMCS(posChain n).1
  -- And we need CanonicalR (posChain n).1 (posChain (n+1)).1
  -- = CanonicalR (posChain n).1 (successorMCS ...).1
  -- which is exactly successorMCS(...).2.2
  show CanonicalR (posChain M0 h_mcs0 n).1
       (successorMCS (posChain M0 h_mcs0 n).1 (posChain M0 h_mcs0 n).2).1
  exact (successorMCS (posChain M0 h_mcs0 n).1 (posChain M0 h_mcs0 n).2).2.2

/-- CanonicalR holds for consecutive negative chain elements (going backward). -/
theorem negChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (n : Nat) :
    CanonicalR (negChain M0 h_mcs0 (n + 1)).1 (negChain M0 h_mcs0 n).1 := by
  show CanonicalR
       (predecessorMCS (negChain M0 h_mcs0 n).1 (negChain M0 h_mcs0 n).2).1
       (negChain M0 h_mcs0 n).1
  exact (predecessorMCS (negChain M0 h_mcs0 n).1 (negChain M0 h_mcs0 n).2).2.2

/-- CanonicalR holds between adjacent elements of the Int chain.
For any t, CanonicalR (intChainMCS t) (intChainMCS (t+1)) holds. -/
theorem intChain_canonicalR (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    CanonicalR (intChainMCS M0 h_mcs0 t) (intChainMCS M0 h_mcs0 (t + 1)) := by
  -- Three cases: t < 0, t = 0, t > 0
  -- When t >= 0: both sides use posChain, so posChain_canonicalR applies
  -- When t < -1: both sides use negChain, need to relate negChain indices
  -- When t = -1: left uses negChain 1, right uses posChain 0 = M0 = negChain 0
  by_cases h0 : t = 0
  · -- Case t = 0: intChainMCS 0 = M0 = posChain 0, intChainMCS 1 = posChain 1
    subst h0
    simp only [intChainMCS, Int.add_zero]
    simp only [gt_iff_lt, Int.lt_irrefl, ↓reduceDIte, Int.zero_lt_one]
    -- Now we have CanonicalR M0 (posChain M0 h_mcs0 1).1
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
      · -- Subcase t = -1: need CanonicalR (negChain 1) M0
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
        -- Need: CanonicalR (negChain (-t).toNat).1 (negChain (-(t+1)).toNat).1
        -- Note: -(t+1) = -t - 1, so (-(t+1)).toNat = (-t).toNat - 1
        -- And negChain_canonicalR says: CanonicalR (negChain (n+1)) (negChain n)
        have h_idx_eq : (-(t+1)).toNat + 1 = (-t).toNat := by omega
        rw [← h_idx_eq]
        exact negChain_canonicalR M0 h_mcs0 (-(t+1)).toNat

/-!
## Forward G and Backward H Coherence

G and H coherence follow from CanonicalR transitivity along the chain.
-/

/--
CanonicalR propagates G-formulas: if CanonicalR M M' and G(phi) ∈ M, then phi ∈ M'.

This follows directly from the definition: CanonicalR M M' = g_content(M) ⊆ M',
and G(phi) ∈ M means phi ∈ g_content(M), so phi ∈ M'.
-/
theorem canonicalR_propagates_G (M M' : Set Formula)
    (h_R : CanonicalR M M') (phi : Formula) (h_G : Formula.all_future phi ∈ M) :
    phi ∈ M' :=
  h_R h_G

/--
CanonicalR propagates G-formulas to the target (G(phi) ∈ M and CanonicalR M M' implies G(phi) ∈ M').

This uses the temporal 4 axiom: G(phi) → G(G(phi)).
-/
theorem canonicalR_propagates_GG (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_R : CanonicalR M M') (phi : Formula)
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
  -- 3. By CanonicalR from (t' - 1) to t', phi ∈ mcs(t')
  have h_le : t ≤ t' - 1 := by omega
  have h_G_pred := intChain_G_propagates M0 h_mcs0 t (t' - 1) phi h_le h_G
  have h_R := intChain_canonicalR M0 h_mcs0 (t' - 1)
  have h_rewrite : t' - 1 + 1 = t' := by omega
  rw [h_rewrite] at h_R
  exact canonicalR_propagates_G (intChainMCS M0 h_mcs0 (t' - 1)) (intChainMCS M0 h_mcs0 t')
    h_R phi h_G_pred

/--
CanonicalR_past holds between adjacent elements going backward.
For any t, CanonicalR_past (intChainMCS (t+1)) (intChainMCS t) holds.
This is derived from intChain_canonicalR via duality.
-/
theorem intChain_canonicalR_past (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) (t : Int) :
    CanonicalR_past (intChainMCS M0 h_mcs0 (t + 1)) (intChainMCS M0 h_mcs0 t) := by
  have h_R := intChain_canonicalR M0 h_mcs0 t
  have h_mcs_t := intChainMCS_is_mcs M0 h_mcs0 t
  have h_mcs_t1 := intChainMCS_is_mcs M0 h_mcs0 (t + 1)
  exact g_content_subset_implies_h_content_reverse (intChainMCS M0 h_mcs0 t) (intChainMCS M0 h_mcs0 (t + 1))
    h_mcs_t h_mcs_t1 h_R

/--
CanonicalR_past propagates H-formulas: if CanonicalR_past M M' and H(phi) ∈ M, then phi ∈ M'.

This follows directly from the definition: CanonicalR_past M M' = h_content(M) ⊆ M',
and H(phi) ∈ M means phi ∈ h_content(M), so phi ∈ M'.
-/
theorem canonicalR_past_propagates_H (M M' : Set Formula)
    (h_R : CanonicalR_past M M') (phi : Formula) (h_H : Formula.all_past phi ∈ M) :
    phi ∈ M' :=
  h_R h_H

/--
CanonicalR_past propagates H-formulas to the target (H(phi) ∈ M and CanonicalR_past M M' implies H(phi) ∈ M').

This uses the temporal 4 axiom for H: H(phi) → H(H(phi)).
-/
theorem canonicalR_past_propagates_HH (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_R : CanonicalR_past M M') (phi : Formula)
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
  -- 3. By CanonicalR_past from (t' + 1) to t', phi ∈ mcs(t')
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
1. canonical_forward_F gives witness W with CanonicalR M W and psi ∈ W
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
## Forward F via Canonical Witnesses

The key observation: for any F(phi) at time t, canonical_forward_F gives us
a witness MCS W. While W is not in our current chain, we can DEFINE the chain
to include such witnesses.

### Enriched Chain Construction

Instead of using generic successorMCS, at each step we:
1. Identify the "oldest" unwitnessed F-obligation from the past of the chain
2. Use canonical_forward_F to get the witness MCS
3. Include that witness as the next chain element

This dovetailing ensures all F-obligations are eventually witnessed.

For now, we provide the forward_F theorem assuming this enriched construction.
-/

/--
Forward F coherence for Int FMCS.

Given F(phi) at time t, we need a witness at some s > t with phi ∈ mcs(s).
This uses canonical_forward_F to get the witness MCS, then shows it appears
in our chain construction.

For the basic chain (without dovetailing), this is NOT automatically true.
For the enriched chain (with dovetailing), this holds by construction.

TODO: Implement the enriched dovetailing chain construction.
-/
theorem intFMCS_forward_F (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (t : Int) (phi : Formula)
    (h_F : Formula.some_future phi ∈ intChainMCS M0 h_mcs0 t) :
    ∃ s : Int, t < s ∧ phi ∈ intChainMCS M0 h_mcs0 s := by
  -- For the basic chain, the witness from canonical_forward_F may not be in our chain.
  -- We need the enriched dovetailing construction to guarantee this.
  sorry

/--
Backward P coherence for Int FMCS.

Symmetric to forward_F.
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
