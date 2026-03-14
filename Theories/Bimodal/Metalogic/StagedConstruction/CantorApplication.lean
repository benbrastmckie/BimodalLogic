import Bimodal.Metalogic.StagedConstruction.DenseTimeline
import Mathlib.Order.Antisymmetrization
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Data.Rat.Encodable
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Algebra.Order.Field.Basic

/-!
# Cantor Isomorphism Application

This module applies Cantor's theorem (`Order.iso_of_countable_dense`) to the
dense staged timeline to establish an order isomorphism with the rationals Q.

## Overview

The dense timeline (from DenseTimeline.lean) is a countable, dense, linearly
preordered set without endpoints. The Antisymmetrization (quotient by mutual
CanonicalR) gives a proper LinearOrder. Cantor's uniqueness theorem then
provides an order isomorphism T ≃o Q.

## Key Types and Theorems

- `DenseTimelineElem`: subtype of StagedPoints in the dense timeline union
- `TimelineQuot`: antisymmetrization of the timeline (has LinearOrder)
- `cantor_iso`: Nonempty (TimelineQuot ≃o ℚ)

## References

- Task 956, plan v015: Phase 6
- Mathlib `Order.iso_of_countable_dense`: Cantor's uniqueness theorem
- Mathlib `Antisymmetrization`: quotient construction for preorders
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Dense Timeline Element Type

The elements of the dense timeline, as a subtype of StagedPoint.
-/

/-- A point in the dense timeline union. -/
def DenseTimelineElem : Type :=
  { p : StagedPoint // p ∈ denseTimelineUnion root_mcs root_mcs_proof }

/-!
## Preorder on Dense Timeline Elements

The preorder uses StagedPoint.le: a ≤ b iff a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs.
-/

/-- Preorder instance for dense timeline elements. -/
noncomputable instance : Preorder (DenseTimelineElem root_mcs root_mcs_proof) where
  le a b := StagedPoint.le a.1 b.1
  le_refl a := StagedPoint.le_refl a.1
  le_trans a b c hab hbc := StagedPoint.le_trans a.1 b.1 c.1 hab hbc

/-- The preorder on dense timeline elements is total. -/
instance : IsTotal (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·) where
  total a b := denseTimeline_linearly_ordered root_mcs root_mcs_proof a.1 b.1 a.2 b.2

/-- Decidable ≤ for dense timeline elements (from classical decidability). -/
noncomputable instance : DecidableLE (DenseTimelineElem root_mcs root_mcs_proof) :=
  fun _ _ => Classical.propDecidable _

/-- Decidable < for dense timeline elements (from classical decidability). -/
noncomputable instance : DecidableLT (DenseTimelineElem root_mcs root_mcs_proof) :=
  fun _ _ => Classical.propDecidable _

/-!
## Timeline Quotient (Antisymmetrization)

The antisymmetrization quotients by the equivalence a ~ b iff a ≤ b ∧ b ≤ a.
This gives a partial order. Combined with totality, it gives a linear order.
-/

/-- The timeline quotient: antisymmetrization of the dense timeline. -/
def TimelineQuot : Type :=
  Antisymmetrization (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·)

/-- The timeline quotient has a linear order (from Antisymmetrization + total preorder). -/
noncomputable instance TimelineQuotLinearOrder : LinearOrder (TimelineQuot root_mcs root_mcs_proof) :=
  inferInstanceAs (LinearOrder (Antisymmetrization (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·)))

/-!
## Strict Density via Quotient-Level No-Covers Argument

Key insight: When the source MCS M is reflexive (CanonicalR M M), any distinguishing
formula δ for ¬CanonicalR(M', M) satisfies G(δ) ∉ M (otherwise T4 + reflexivity
gives δ ∈ M, contradicting δ ∉ M). This forces Case A of density_frame_condition,
where the intermediate V contains ¬δ. Since G(δ) ∈ M' → δ ∈ GContent(M') ⊆ V
would give both δ and ¬δ in V (contradiction), we get ¬CanonicalR(M', V).

This provides a STRICT intermediate (not equivalent to the target) whenever the
source is reflexive -- which is always the case when iterating from an element
equivalent to the original source (mutual CanonicalR implies reflexivity via T4).
-/

/-- Key lemma: An intermediate cannot be equivalent to both endpoints. -/
theorem intermediate_not_both_equiv
    (p q c : StagedPoint)
    (hp_q : CanonicalR p.mcs q.mcs)
    (hq_not_p : ¬CanonicalR q.mcs p.mcs)
    (hc_p : CanonicalR c.mcs p.mcs)
    (hc_q : CanonicalR q.mcs c.mcs) :
    False := by
  have hq_p := canonicalR_transitive q.mcs c.mcs p.mcs q.is_mcs hc_q hc_p
  exact hq_not_p hq_p

/-- T4-based transitivity: if a -> b and b -> c, then a -> c via Temporal 4 axiom. -/
theorem canonicalR_T4_chain (a b c : StagedPoint)
    (hab : CanonicalR a.mcs b.mcs)
    (hbc : CanonicalR b.mcs c.mcs) :
    CanonicalR a.mcs c.mcs := by
  intro phi h_phi_Ga
  have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
    DerivationTree.axiom [] _ (Axiom.temp_4 phi)
  have h_GGphi_a : Formula.all_future (Formula.all_future phi) ∈ a.mcs :=
    set_mcs_implication_property a.is_mcs (theorem_in_mcs a.is_mcs h_T4) h_phi_Ga
  have h_Gphi_b : Formula.all_future phi ∈ b.mcs := hab h_GGphi_a
  exact hbc h_Gphi_b

/-- When M and M' are mutually accessible, both are reflexive via Temporal 4 propagation. -/
theorem mutual_canonicalR_implies_reflexive
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_R' : CanonicalR M' M) :
    CanonicalR M M ∧ CanonicalR M' M' := by
  constructor
  · intro phi h_phi_GContent
    have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 phi)
    have h_GG_phi_M : Formula.all_future (Formula.all_future phi) ∈ M :=
      set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_T4) h_phi_GContent
    have h_G_phi_M' : Formula.all_future phi ∈ M' := h_R h_GG_phi_M
    exact h_R' h_G_phi_M'
  · intro phi h_phi_GContent
    have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 phi)
    have h_GG_phi_M' : Formula.all_future (Formula.all_future phi) ∈ M' :=
      set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_T4) h_phi_GContent
    have h_G_phi_M : Formula.all_future phi ∈ M := h_R' h_GG_phi_M'
    exact h_R h_G_phi_M

/-- When both source and target are reflexive, density gives a STRICT intermediate:
    one that is not equivalent to the target. The source reflexivity forces Case A
    (G(δ) ∉ M), and the target reflexivity rules out the V = M' subcase. -/
theorem density_frame_condition_strict
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M)
    (h_M_refl : CanonicalR M M)
    (h_M'_refl : CanonicalR M' M') :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR M' W := by
  -- Step 0: Get distinguishing formula delta
  obtain ⟨delta, h_G_delta_M', h_delta_not_M⟩ :=
    distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  -- Step 1: M reflexive + G(delta) ∈ M → delta ∈ M. But delta ∉ M. So G(delta) ∉ M.
  have h_G_delta_not_M : Formula.all_future delta ∉ M := by
    intro h_G_delta_M
    exact h_delta_not_M (h_M_refl h_G_delta_M)
  -- Step 2: Case A: F(¬delta) ∈ M
  have h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M :=
    not_G_implies_F_neg h_mcs h_G_delta_not_M
  -- Step 3: Double-density construction
  obtain ⟨W₁, h_W₁_mcs, h_R_MW₁, h_F_neg_W₁⟩ :=
    density_of_canonicalR M h_mcs (Formula.neg delta) h_F_neg_delta
  obtain ⟨V, h_V_mcs, h_R_W₁V, h_neg_delta_V⟩ :=
    canonical_forward_F W₁ h_W₁_mcs (Formula.neg delta) h_F_neg_W₁
  have h_R_MV : CanonicalR M V := canonicalR_transitive M W₁ V h_mcs h_R_MW₁ h_R_W₁V
  -- Step 4: Linearity
  have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
  -- Helper: M' → V is impossible (delta and ¬delta in V)
  have h_not_M'V : ¬CanonicalR M' V := by
    intro h_R'V
    exact set_consistent_not_both h_V_mcs.1 delta (h_R'V h_G_delta_M') h_neg_delta_V
  rcases h_lin with h_VM' | h_M'V | h_eq
  · -- V → M': V is the strict intermediate
    exact ⟨V, h_V_mcs, h_R_MV, h_VM', h_not_M'V⟩
  · -- M' → V: impossible
    exact absurd h_M'V h_not_M'V
  · -- V = M': impossible when M' is reflexive
    -- V = M' gives ¬delta ∈ M'. M' reflexive + G(delta) ∈ M' gives delta ∈ M'. Contradiction.
    exfalso
    have h_neg_delta_M' : Formula.neg delta ∈ M' := h_eq ▸ h_neg_delta_V
    have h_delta_M' : delta ∈ M' := h_M'_refl h_G_delta_M'
    exact set_consistent_not_both h_mcs'.1 delta h_delta_M' h_neg_delta_M'

/-- G(δ) ∈ W and F(¬δ) ∈ W is inconsistent: □δ and ◇¬δ cannot coexist in an MCS.
    This follows from the duality: G(δ) → G(¬¬δ), and F(¬δ) = ¬G(¬¬δ). -/
private theorem G_F_neg_inconsistent
    {W : Set Formula} {delta : Formula}
    (h_W_mcs : SetMaximalConsistent W)
    (h_G_delta : Formula.all_future delta ∈ W)
    (h_F_neg : Formula.some_future (Formula.neg delta) ∈ W) : False := by
  -- Step 1: δ → ¬¬δ is a theorem (double negation introduction)
  have h_dni : [] ⊢ delta.imp (Formula.neg (Formula.neg delta)) := dni_theorem delta
  -- Step 2: G(δ → ¬¬δ) by temporal necessitation
  have h_G_dni : [] ⊢ Formula.all_future (delta.imp (Formula.neg (Formula.neg delta))) :=
    DerivationTree.temporal_necessitation _ h_dni
  -- Step 3: G(δ → ¬¬δ) → (G(δ) → G(¬¬δ)) by temporal K distribution
  have h_K : [] ⊢ (Formula.all_future (delta.imp (Formula.neg (Formula.neg delta)))).imp
      ((Formula.all_future delta).imp (Formula.all_future (Formula.neg (Formula.neg delta)))) :=
    DerivationTree.axiom [] _ (Axiom.temp_k_dist delta (Formula.neg (Formula.neg delta)))
  -- Step 4: G(δ) → G(¬¬δ)
  have h_imp : [] ⊢ (Formula.all_future delta).imp (Formula.all_future (Formula.neg (Formula.neg delta))) :=
    DerivationTree.modus_ponens [] _ _ h_K h_G_dni
  -- Step 5: G(¬¬δ) ∈ W
  have h_G_nn : Formula.all_future (Formula.neg (Formula.neg delta)) ∈ W :=
    set_mcs_implication_property h_W_mcs (theorem_in_mcs h_W_mcs h_imp) h_G_delta
  -- Step 6: F(¬δ) = ¬G(¬¬δ) definitionally. So ¬G(¬¬δ) ∈ W.
  -- F(¬δ) = some_future(neg δ) = neg(all_future(neg(neg δ))) = neg(G(¬¬δ))
  -- So h_F_neg : neg(all_future(neg(neg delta))) ∈ W
  -- And h_G_nn : all_future(neg(neg delta)) ∈ W
  -- Contradiction by consistency
  exact set_consistent_not_both h_W_mcs.1 (Formula.all_future (Formula.neg (Formula.neg delta))) h_G_nn h_F_neg

/-- Strengthened Case A: when we have F(¬delta) ∈ M and G(delta) ∈ M',
    the density intermediate is STRICT: ¬CanonicalR(M', W).
    The strictness comes from ¬delta in V contradicting delta from GContent(M'),
    and the G/F duality making CanonicalR(M', W₁) impossible. -/
theorem density_frame_condition_caseA_strict
    {M M' : Set Formula} {delta : Formula}
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_G_delta_M' : Formula.all_future delta ∈ M')
    (h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR M' W := by
  -- Step 1: Density gives W₁ with CanonicalR(M, W₁) and F(¬delta) ∈ W₁
  obtain ⟨W₁, h_W₁_mcs, h_R_MW₁, h_F_neg_W₁⟩ :=
    density_of_canonicalR M h_mcs (Formula.neg delta) h_F_neg_delta
  -- Step 2: Forward witness gives V with CanonicalR(W₁, V) and ¬delta ∈ V
  obtain ⟨V, h_V_mcs, h_R_W₁V, h_neg_delta_V⟩ :=
    canonical_forward_F W₁ h_W₁_mcs (Formula.neg delta) h_F_neg_W₁
  -- Step 3: CanonicalR(M, V) by transitivity
  have h_R_MV : CanonicalR M V := canonicalR_transitive M W₁ V h_mcs h_R_MW₁ h_R_W₁V
  -- Key: ¬CanonicalR(M', V) because delta and ¬delta would coexist in V
  have h_not_M'V : ¬CanonicalR M' V := by
    intro h_R'V
    exact set_consistent_not_both h_V_mcs.1 delta (h_R'V h_G_delta_M') h_neg_delta_V
  -- Key: CanonicalR(M', W₁) is impossible by G/F duality
  have h_not_M'W₁ : ¬CanonicalR M' W₁ := by
    intro h_R'W₁
    -- G(delta) ∈ M'. By T4: G(G(delta)) ∈ M'. So G(delta) ∈ GContent(M') ⊆ W₁.
    have h_T4 : [] ⊢ (Formula.all_future delta).imp (Formula.all_future (Formula.all_future delta)) :=
      DerivationTree.axiom [] _ (Axiom.temp_4 delta)
    have h_GG : Formula.all_future (Formula.all_future delta) ∈ M' :=
      set_mcs_implication_property h_mcs' (theorem_in_mcs h_mcs' h_T4) h_G_delta_M'
    have h_G_W₁ : Formula.all_future delta ∈ W₁ := h_R'W₁ h_GG
    -- G(delta) ∈ W₁ and F(¬delta) ∈ W₁: contradiction by duality
    exact G_F_neg_inconsistent h_W₁_mcs h_G_W₁ h_F_neg_W₁
  -- Step 4: Linearity of V and M' from M
  have h_lin := canonical_forward_reachable_linear M V M' h_mcs h_V_mcs h_mcs' h_R_MV h_R
  rcases h_lin with h_VM' | h_M'V | h_eq
  · -- CanonicalR(V, M'): V is the strict intermediate
    exact ⟨V, h_V_mcs, h_R_MV, h_VM', h_not_M'V⟩
  · -- CanonicalR(M', V): impossible
    exact absurd h_M'V h_not_M'V
  · -- V = M': Use W₁ as intermediate instead
    -- W₁ has CanonicalR(M, W₁) and CanonicalR(W₁, M') (from h_eq and CanonicalR(W₁, V))
    rw [h_eq] at h_R_W₁V
    -- CanonicalR(W₁, M') = h_R_W₁V. ¬CanonicalR(M', W₁) = h_not_M'W₁.
    exact ⟨W₁, h_W₁_mcs, h_R_MW₁, h_R_W₁V, h_not_M'W₁⟩

/-- When the source M is reflexive, density always gives a STRICT intermediate. -/
theorem density_frame_condition_reflexive_source
    (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M')
    (h_not_R' : ¬CanonicalR M' M)
    (h_M_refl : CanonicalR M M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ CanonicalR W M' ∧
      ¬CanonicalR M' W := by
  -- Get distinguishing formula delta
  obtain ⟨delta, h_G_delta_M', h_delta_not_M⟩ :=
    distinguishing_formula_exists h_mcs h_mcs' h_not_R'
  -- M reflexive + G(delta) ∈ M → delta ∈ M. But delta ∉ M. So G(delta) ∉ M.
  have h_G_delta_not_M : Formula.all_future delta ∉ M := by
    intro h_G_delta_M
    exact h_delta_not_M (h_M_refl h_G_delta_M)
  -- Case A applies: F(¬delta) ∈ M
  have h_F_neg_delta : Formula.some_future (Formula.neg delta) ∈ M :=
    not_G_implies_F_neg h_mcs h_G_delta_not_M
  -- Apply the strict Case A lemma
  exact density_frame_condition_caseA_strict h_mcs h_mcs' h_R h_G_delta_M' h_F_neg_delta

/-- Strict intermediate exists: Given [p] < [q] in the quotient, there exists
    an element e with [p] < [e] < [q].

    This is proven using density_frame_condition_reflexive_source when needed.
    The key insight is that when the iteration reaches a reflexive point,
    we can use the strict version to escape the equivalence class.

    The proof uses classical existence: we show that assuming no strict
    intermediate leads to a contradiction with density. -/
theorem strict_intermediate_exists
    (p q : DenseTimelineElem root_mcs root_mcs_proof)
    (h_R : CanonicalR p.1.mcs q.1.mcs)
    (h_not_R : ¬CanonicalR q.1.mcs p.1.mcs) :
    ∃ e : DenseTimelineElem root_mcs root_mcs_proof,
      CanonicalR p.1.mcs e.1.mcs ∧ ¬CanonicalR e.1.mcs p.1.mcs ∧
      CanonicalR e.1.mcs q.1.mcs ∧ ¬CanonicalR q.1.mcs e.1.mcs := by
  -- Strategy: Use dense_timeline_has_intermediate repeatedly.
  -- Each intermediate c satisfies:
  -- - CanonicalR p c (from density)
  -- - CanonicalR c q (from density)
  -- - c cannot be ~ both p and q (by intermediate_not_both_equiv)
  --
  -- Case 1: c ≁ p and c ≁ q → c is the strict intermediate
  -- Case 2: c ~ p → p is reflexive, use density_frame_condition_reflexive_source
  -- Case 3: c ~ q → apply density to (p, c), get d; repeat analysis
  --
  -- The iteration terminates because density_frame_condition_reflexive_source
  -- provides a STRICT intermediate when the source is reflexive.
  --
  -- Get non-strict intermediate
  obtain ⟨c, hc_mem, hc_R_p, hc_R_q⟩ :=
    dense_timeline_has_intermediate root_mcs root_mcs_proof p.1 q.1 p.2 q.2 h_R h_not_R
  let c' : DenseTimelineElem root_mcs root_mcs_proof := ⟨c, hc_mem⟩
  by_cases h_cp : CanonicalR c.mcs p.1.mcs
  · -- c ~ p: p is reflexive
    have h_p_refl : CanonicalR p.1.mcs p.1.mcs := by
      have h_mutual := mutual_canonicalR_implies_reflexive p.1.mcs c.mcs p.1.is_mcs c.is_mcs hc_R_p h_cp
      exact h_mutual.1
    -- Use density_frame_condition_reflexive_source to get strict MCS intermediate
    obtain ⟨W, h_W_mcs, h_pW, h_Wq, h_not_qW⟩ :=
      density_frame_condition_reflexive_source p.1.mcs q.1.mcs p.1.is_mcs q.1.is_mcs h_R h_not_R h_p_refl
    -- W is a strict MCS. Create a StagedPoint for it.
    -- W is reachable from p via density, so by the staged construction it's in the timeline.
    -- Use dense_timeline_has_intermediate to get a timeline point with these properties.
    -- The point from (p, q) might not be W, but we can show existence non-constructively.
    --
    -- Key insight: We can construct a timeline element with MCS = W using the
    -- density construction. The issue is showing W ∈ denseTimelineUnion.
    --
    -- Alternative approach: use the fact that density_frame_condition_reflexive_source
    -- constructs W via the same mechanism as density_frame_condition but with strictness.
    -- The point c from dense_timeline_has_intermediate may or may not be W.
    -- But we can show by contradiction that some strict intermediate exists.
    --
    -- Non-constructive argument:
    -- If no element in the timeline is strictly between [p] and [q], then
    -- every intermediate from dense_timeline_has_intermediate is ~ p or ~ q.
    -- But density_frame_condition_reflexive_source says there EXISTS a strict MCS.
    -- This MCS must appear somewhere in the timeline (by completeness of construction).
    --
    -- For now, we use sorry as this requires deeper integration with the staged construction.
    sorry
  · -- c ≁ p: c is strictly above p
    by_cases h_cq : CanonicalR q.1.mcs c.mcs
    · -- c ~ q: symmetric case, iterate on (p, c)
      -- First show c ≁ p holds (we have ¬CanonicalR c.mcs p.1.mcs)
      have h_not_cp : ¬CanonicalR c.mcs p.1.mcs := h_cp
      -- Apply density to (p, c)
      obtain ⟨d, hd_mem, hd_R_p, hd_R_c⟩ :=
        dense_timeline_has_intermediate root_mcs root_mcs_proof p.1 c p.2 hc_mem hc_R_p h_not_cp
      let d' : DenseTimelineElem root_mcs root_mcs_proof := ⟨d, hd_mem⟩
      -- d has CanonicalR p d and CanonicalR d c
      have hd_R_q : CanonicalR d.mcs q.1.mcs :=
        canonicalR_transitive d.mcs c.mcs q.1.mcs d.is_mcs hd_R_c hc_R_q
      by_cases h_dp : CanonicalR d.mcs p.1.mcs
      · -- d ~ p: p is reflexive, use strict version
        have h_p_refl : CanonicalR p.1.mcs p.1.mcs := by
          have h_mutual := mutual_canonicalR_implies_reflexive p.1.mcs d.mcs p.1.is_mcs d.is_mcs hd_R_p h_dp
          exact h_mutual.1
        -- Similar to above case
        sorry
      · -- d ≁ p
        by_cases h_dc : CanonicalR c.mcs d.mcs
        · -- d ~ c ~ q
          have h_dq : CanonicalR q.1.mcs d.mcs := by
            -- c ~ q and d ~ c implies d ~ q
            -- c ~ q: CanonicalR c q (have hc_R_q) and CanonicalR q c (have h_cq)
            -- d ~ c: CanonicalR d c (have hd_R_c) and CanonicalR c d (have h_dc)
            -- So CanonicalR q c and CanonicalR c d gives CanonicalR q d
            exact canonicalR_transitive q.1.mcs c.mcs d.mcs q.1.is_mcs h_cq h_dc
          -- d ~ q and d ≁ p
          -- Iterate again on (p, d)
          sorry
        · -- d ≁ c, hence d ≁ q
          have h_not_dq : ¬CanonicalR q.1.mcs d.mcs := by
            intro h_qd
            -- Have: CanonicalR q c (h_cq), CanonicalR q d (h_qd), CanonicalR d c (hd_R_c)
            -- Use linearity
            have h_lin := canonical_forward_reachable_linear q.1.mcs c.mcs d.mcs q.1.is_mcs c.is_mcs d.is_mcs h_cq h_qd
            rcases h_lin with h_cd | h_dc' | h_eq
            · exact h_dc h_cd
            · -- h_dc' duplicates hd_R_c, use T4 chain argument
              have h_cd : CanonicalR c.mcs d.mcs := by
                intro phi h_phi_Gc
                have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
                  DerivationTree.axiom [] _ (Axiom.temp_4 phi)
                have h_GGphi : Formula.all_future (Formula.all_future phi) ∈ c.mcs :=
                  set_mcs_implication_property c.is_mcs (theorem_in_mcs c.is_mcs h_T4) h_phi_Gc
                have h_Gphi_q : Formula.all_future phi ∈ q.1.mcs := hc_R_q h_GGphi
                exact h_qd h_Gphi_q
              exact h_dc h_cd
            · exact h_dc (h_eq ▸ hd_R_c)
          -- d is strictly between p and q!
          exact ⟨d', hd_R_p, h_dp, hd_R_q, h_not_dq⟩
    · -- c ≁ p and c ≁ q: c is the strict intermediate!
      exact ⟨c', hc_R_p, h_cp, hc_R_q, h_cq⟩

/-!
## Cantor Prerequisites for TimelineQuot

We need: Countable, DenselyOrdered, NoMinOrder, NoMaxOrder, Nonempty.
-/

/-- The timeline quotient is nonempty. -/
instance : Nonempty (TimelineQuot root_mcs root_mcs_proof) := by
  obtain ⟨p, hp⟩ := dense_timeline_nonempty root_mcs root_mcs_proof
  exact ⟨toAntisymmetrization (· ≤ ·) ⟨p, hp⟩⟩

/-- The timeline quotient is countable. -/
instance : Countable (TimelineQuot root_mcs root_mcs_proof) := by
  -- TimelineQuot is a quotient of DenseTimelineElem
  -- DenseTimelineElem is a subtype of StagedPoint
  -- StagedPoint has at most countably many values (each is an MCS + stage)
  -- The dense timeline union is countable
  have h_countable := dense_timeline_countable root_mcs root_mcs_proof
  -- DenseTimelineElem is countable (subtype of a countable set)
  have : Countable (DenseTimelineElem root_mcs root_mcs_proof) := by
    exact Set.Countable.to_subtype h_countable
  -- Antisymmetrization of a countable type is countable (it's a quotient)
  exact Quotient.countable

/-- The timeline quotient has no maximum element. -/
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      -- Strategy: Find a strict future using density_frame_condition_strict
      -- Step 1: Get any future q with CanonicalR(p.mcs, q.mcs)
      obtain ⟨q, hq_mem, hq_R⟩ := dense_timeline_has_future root_mcs root_mcs_proof p.1 p.2
      -- Step 2: Case split on whether this is strict
      by_cases h_strict : ¬CanonicalR q.mcs p.1.mcs
      case pos =>
        -- q is strictly greater than p
        let q' : DenseTimelineElem root_mcs root_mcs_proof := ⟨q, hq_mem⟩
        use toAntisymmetrization (· ≤ ·) q'
        -- Show p < q' in the antisymmetrization using the simp lemma
        rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
        -- Need: p.1 < q (as StagedPoints)
        -- In preorder: p.1 < q means p.1 ≤ q ∧ ¬(q ≤ p.1)
        constructor
        · -- p.1 ≤ q: StagedPoint.le via CanonicalR
          exact Or.inr hq_R
        · -- ¬(q ≤ p.1): strictness
          intro hqp
          cases hqp with
          | inl h_eq =>
            -- q.mcs = p.1.mcs
            -- We have hq_R : CanonicalR p.1.mcs q.mcs
            -- Substituting h_eq: CanonicalR q.mcs q.mcs
            have h_refl : CanonicalR q.mcs q.mcs := h_eq ▸ hq_R
            -- Also h_strict : ¬CanonicalR q.mcs p.1.mcs
            -- Substituting h_eq: ¬CanonicalR q.mcs q.mcs
            exact h_strict (h_eq.symm ▸ h_refl)
          | inr h_R => exact h_strict h_R
      case neg =>
        -- CanonicalR(q.mcs, p.mcs) holds, so q ~ p in quotient
        -- Use density_frame_condition_strict to find a strict intermediate
        push_neg at h_strict
        -- We have CanonicalR(p.mcs, q.mcs) and CanonicalR(q.mcs, p.mcs)
        -- This means p ~ q in the quotient. We need to find something strictly above.
        -- Apply density_frame_condition_strict to get a strict intermediate
        -- But wait - we need ¬CanonicalR(q.mcs, p.mcs) for that, which we don't have!
        -- When p ~ q in the quotient, we need a different approach.
        --
        -- Key insight: apply seriality to q to get q', then use density to find
        -- a strict intermediate between p and q' if needed.
        obtain ⟨q', hq'_mem, hq'_R⟩ := dense_timeline_has_future root_mcs root_mcs_proof q hq_mem
        -- We have CanonicalR(q.mcs, q'.mcs)
        -- By transitivity via q ~ p: CanonicalR(p.mcs, q'.mcs)
        have hp_q' : CanonicalR p.1.mcs q'.mcs :=
          canonicalR_transitive p.1.mcs q.mcs q'.mcs p.1.is_mcs hq_R hq'_R
        -- Case split: is q' strict over p?
        by_cases h_strict' : ¬CanonicalR q'.mcs p.1.mcs
        · -- q' is strictly greater than p
          let q'' : DenseTimelineElem root_mcs root_mcs_proof := ⟨q', hq'_mem⟩
          use toAntisymmetrization (· ≤ ·) q''
          rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
          constructor
          · exact Or.inr hp_q'
          · intro hq'p
            cases hq'p with
            | inl h_eq =>
              have h_refl : CanonicalR q'.mcs q'.mcs := h_eq ▸ hp_q'
              exact h_strict' (h_eq.symm ▸ h_refl)
            | inr h_R => exact h_strict' h_R
        · -- Still not strict - both q and q' are in the same equivalence class as p
          push_neg at h_strict'
          -- We have: p ~ q ~ q' (all mutually accessible)
          -- This means p.mcs is reflexive: CanonicalR(p.mcs, p.mcs)
          -- (since CanonicalR is transitive and symmetric on this equivalence class)
          --
          -- Key insight: if p.mcs is reflexive, then any future from seriality
          -- might also be reflexive and equivalent. But the DENSITY construction
          -- must eventually break out of this equivalence class.
          --
          -- However, for NoMaxOrder, we can use a different argument:
          -- Since p ~ q ~ q', and the timeline is DENSE between any strictly
          -- ordered pair, we need to find a pair that IS strictly ordered.
          --
          -- Actually, the timeline MUST have strict orderings, otherwise
          -- the quotient would be a single point, contradicting non-emptiness
          -- and the existence of multiple MCSs.
          --
          -- Use the irreflexive_mcs_has_strict_future lemma:
          -- Check if p.mcs is reflexive
          by_cases h_p_refl : CanonicalR p.1.mcs p.1.mcs
          · -- p.mcs is reflexive
            -- We have a loop: p ~ q ~ q' ~ ... all equivalent
            -- Need to escape via density_frame_condition_strict
            -- For now, use sorry - full solution needs well-founded iteration
            sorry
          · -- p.mcs is NOT reflexive - but this case is UNREACHABLE
            -- We have:
            -- - hq_R : CanonicalR p.1.mcs q.mcs
            -- - h_strict : CanonicalR q.mcs p.1.mcs (from push_neg)
            -- By the mutual_canonicalR_implies_refl lemma, this implies
            -- CanonicalR p.1.mcs p.1.mcs, contradicting h_p_refl
            exfalso
            apply h_p_refl
            -- Show CanonicalR p.1.mcs p.1.mcs from the mutual accessibility
            -- Using: hq_R, h_strict, h_strict' (and transitivity/Temporal 4)
            -- GContent(p.1.mcs) ⊆ q.mcs (hq_R)
            -- GContent(q.mcs) ⊆ p.1.mcs (h_strict)
            -- By Temporal 4: G(phi) ∈ p.1.mcs → G(G(phi)) ∈ p.1.mcs → G(phi) ∈ GContent(p.1.mcs)
            -- So phi ∈ GContent(p.1.mcs) → G(phi) ∈ GContent(p.1.mcs) ⊆ q.mcs → phi ∈ GContent(q.mcs) ⊆ p.1.mcs
            -- Hence GContent(p.1.mcs) ⊆ p.1.mcs
            intro phi h_phi_GContent
            -- phi ∈ GContent(p.1.mcs) means G(phi) ∈ p.1.mcs
            -- By Temporal 4: G(G(phi)) ∈ p.1.mcs
            have h_T4 : [] ⊢ (Formula.all_future phi).imp (Formula.all_future (Formula.all_future phi)) :=
              DerivationTree.axiom [] _ (Axiom.temp_4 phi)
            have h_GG_phi : Formula.all_future (Formula.all_future phi) ∈ p.1.mcs :=
              set_mcs_implication_property p.1.is_mcs (theorem_in_mcs p.1.is_mcs h_T4) h_phi_GContent
            -- G(phi) ∈ GContent(p.1.mcs) ⊆ q.mcs
            have h_G_phi_q : Formula.all_future phi ∈ q.mcs := hq_R h_GG_phi
            -- phi ∈ GContent(q.mcs) ⊆ p.1.mcs
            exact h_strict h_G_phi_q

/-- The timeline quotient has no minimum element. -/
instance : NoMinOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_lt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      -- Symmetric to NoMaxOrder but using past direction
      -- Get any past predecessor q with CanonicalR(q.mcs, p.mcs)
      obtain ⟨q, hq_mem, hq_R⟩ := dense_timeline_has_past root_mcs root_mcs_proof p.1 p.2
      -- Case split on whether this is strict
      by_cases h_strict : ¬CanonicalR p.1.mcs q.mcs
      case pos =>
        -- q is strictly less than p
        let q' : DenseTimelineElem root_mcs root_mcs_proof := ⟨q, hq_mem⟩
        use toAntisymmetrization (· ≤ ·) q'
        rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
        constructor
        · -- q' ≤ p: via CanonicalR q.mcs p.mcs
          exact Or.inr hq_R
        · -- ¬(p ≤ q'): strictness
          intro hpq
          cases hpq with
          | inl h_eq =>
            have h_refl : CanonicalR p.1.mcs p.1.mcs := h_eq.symm ▸ hq_R
            exact h_strict (h_eq ▸ h_refl)
          | inr h_R => exact h_strict h_R
      case neg =>
        -- Similar iteration as NoMaxOrder
        push_neg at h_strict
        -- Full proof requires well-founded iteration on candidate formula set
        -- For now, use sorry
        sorry

/-- The timeline quotient is densely ordered. -/
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) where
  dense := by
    intro a b hab
    -- a < b means a ≤ b and ¬(b ≤ a) at the quotient level
    -- Get representatives
    induction a using Antisymmetrization.ind with
    | _ p =>
      induction b using Antisymmetrization.ind with
      | _ q =>
        -- hab : toAntisymmetrization p < toAntisymmetrization q
        rw [toAntisymmetrization_lt_toAntisymmetrization_iff] at hab
        -- hab : p < q as StagedPoints
        -- This means p.1 ≤ q.1 and ¬(q.1 ≤ p.1)
        obtain ⟨h_le, h_not_le⟩ := hab
        -- h_le : StagedPoint.le p.1 q.1 = (p.1.mcs = q.1.mcs ∨ CanonicalR p.1.mcs q.1.mcs)
        -- h_not_le : ¬StagedPoint.le q.1 p.1
        -- Unfold h_not_le to get the components
        simp only [StagedPoint.le] at h_not_le
        push_neg at h_not_le
        obtain ⟨h_neq, h_not_R⟩ := h_not_le
        -- From h_le: must be CanonicalR case since p.1.mcs ≠ q.1.mcs
        have h_R : CanonicalR p.1.mcs q.1.mcs := by
          simp only [StagedPoint.le] at h_le
          cases h_le with
          | inl h_eq => exact absurd h_eq.symm h_neq
          | inr h_R => exact h_R
        -- Use non-strict density to get intermediate c
        obtain ⟨c, hc_mem, hc_R_p, hc_R_q⟩ :=
          dense_timeline_has_intermediate root_mcs root_mcs_proof p.1 q.1 p.2 q.2 h_R h_not_R
        -- c has: CanonicalR(p.mcs, c.mcs) and CanonicalR(c.mcs, q.mcs)
        -- At quotient level: [p] ≤ [c] ≤ [q]
        -- Key insight: c CANNOT be equivalent to both p and q
        -- (if c ~ p and c ~ q, then p ~ q, contradicting [p] < [q])
        -- So at least one of [p] < [c] or [c] < [q] holds
        let c' : DenseTimelineElem root_mcs root_mcs_proof := ⟨c, hc_mem⟩
        -- Check both equivalences
        by_cases h_cp : CanonicalR c.mcs p.1.mcs
        · -- c ~ p: [c] = [p]
          -- Since c ~ p and we have [p] < [q], we need [c] < [q]
          -- But for density we need something STRICTLY between
          -- Since c = p in quotient, c doesn't work. Need to iterate.
          -- However, we can show c is NOT equivalent to q (otherwise p ~ q)
          have h_not_cq : ¬CanonicalR q.1.mcs c.mcs := by
            intro h_qc
            exact h_not_R (canonicalR_transitive q.1.mcs c.mcs p.1.mcs q.1.is_mcs h_qc h_cp)
          -- Apply density again to (c, q) where [c] = [p] < [q]
          -- c' has CanonicalR(c, q) and NOT CanonicalR(q, c) = h_not_cq
          obtain ⟨d, hd_mem, hd_R_c, hd_R_q⟩ :=
            dense_timeline_has_intermediate root_mcs root_mcs_proof c q.1 hc_mem q.2 hc_R_q h_not_cq
          let d' : DenseTimelineElem root_mcs root_mcs_proof := ⟨d, hd_mem⟩
          -- d has CanonicalR(c, d) and CanonicalR(d, q)
          -- Since c ~ p, we have CanonicalR(p, d) by transitivity
          have hd_R_p : CanonicalR p.1.mcs d.mcs :=
            canonicalR_transitive p.1.mcs c.mcs d.mcs p.1.is_mcs hc_R_p hd_R_c
          -- d cannot be equivalent to both c and q (would make c ~ q)
          -- Check if d ~ c (hence d ~ p)
          by_cases h_dc : CanonicalR d.mcs c.mcs
          · -- d ~ c ~ p: iterate again using strict_intermediate_exists
            obtain ⟨e, he_p, he_not_p, he_q, hq_not_e⟩ :=
              strict_intermediate_exists root_mcs root_mcs_proof p q h_R h_not_R
            use toAntisymmetrization (· ≤ ·) e
            constructor
            · -- [p] < [e]
              rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
              constructor
              · exact Or.inr he_p
              · simp only [StagedPoint.le]
                push_neg
                exact ⟨fun h => he_not_p (h.symm ▸ he_p), he_not_p⟩
            · -- [e] < [q]
              rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
              constructor
              · exact Or.inr he_q
              · simp only [StagedPoint.le]
                push_neg
                exact ⟨fun h => hq_not_e (h ▸ he_q), hq_not_e⟩
          · -- d ≁ c (hence d ≁ p since c ~ p)
            have h_dp : ¬CanonicalR d.mcs p.1.mcs := by
              intro h_dp
              -- CanonicalR(d, p) and CanonicalR(p, c) via c ~ p implies CanonicalR(d, c)
              -- Actually c ~ p means CanonicalR(c, p) AND CanonicalR(p, c)
              -- We have h_cp : CanonicalR(c, p)
              -- From hc_R_p : CanonicalR(p, c)
              -- So CanonicalR(d, p) and CanonicalR(p, c) => CanonicalR(d, c)
              exact h_dc (canonicalR_transitive d.mcs p.1.mcs c.mcs d.is_mcs h_dp hc_R_p)
            -- Check if d ~ q
            by_cases h_dq : CanonicalR q.1.mcs d.mcs
            · -- d ~ q: use strict_intermediate_exists
              obtain ⟨e, he_p, he_not_p, he_q, hq_not_e⟩ :=
                strict_intermediate_exists root_mcs root_mcs_proof p q h_R h_not_R
              use toAntisymmetrization (· ≤ ·) e
              constructor
              · -- [p] < [e]
                rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                constructor
                · exact Or.inr he_p
                · simp only [StagedPoint.le]
                  push_neg
                  exact ⟨fun h => he_not_p (h.symm ▸ he_p), he_not_p⟩
              · -- [e] < [q]
                rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                constructor
                · exact Or.inr he_q
                · simp only [StagedPoint.le]
                  push_neg
                  exact ⟨fun h => hq_not_e (h ▸ he_q), hq_not_e⟩
            · -- d ≁ p AND d ≁ q: d is the strict intermediate!
              use toAntisymmetrization (· ≤ ·) d'
              constructor
              · -- [p] < [d]
                rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                constructor
                · exact Or.inr hd_R_p
                · simp only [StagedPoint.le]
                  push_neg
                  exact ⟨fun h => h_dp (h.symm ▸ hd_R_p), h_dp⟩
              · -- [d] < [q]
                rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                constructor
                · exact Or.inr hd_R_q
                · simp only [StagedPoint.le]
                  push_neg
                  exact ⟨fun h => h_dq (h ▸ hd_R_q), h_dq⟩
        · -- ¬(c ~ p): [p] < [c]
          -- Check if c ~ q
          by_cases h_cq : CanonicalR q.1.mcs c.mcs
          · -- c ~ q: [c] = [q], so [p] < [c] = [q]
            -- Need c' ≁ q for [c'] < [q]
            have h_not_cp : ¬CanonicalR c.mcs p.1.mcs := h_cp
            -- Apply density to (p, c) where [p] < [c] = [q]
            obtain ⟨d, hd_mem, hd_R_p, hd_R_c⟩ :=
              dense_timeline_has_intermediate root_mcs root_mcs_proof p.1 c p.2 hc_mem hc_R_p h_not_cp
            let d' : DenseTimelineElem root_mcs root_mcs_proof := ⟨d, hd_mem⟩
            -- d has CanonicalR(p, d) and CanonicalR(d, c)
            -- Since c ~ q, we have CanonicalR(d, q)
            have hd_R_q : CanonicalR d.mcs q.1.mcs :=
              canonicalR_transitive d.mcs c.mcs q.1.mcs d.is_mcs hd_R_c hc_R_q
            -- Check if d ~ p
            by_cases h_dp : CanonicalR d.mcs p.1.mcs
            · -- d ~ p: use strict_intermediate_exists
              obtain ⟨e, he_p, he_not_p, he_q, hq_not_e⟩ :=
                strict_intermediate_exists root_mcs root_mcs_proof p q h_R h_not_R
              use toAntisymmetrization (· ≤ ·) e
              constructor
              · -- [p] < [e]
                rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                constructor
                · exact Or.inr he_p
                · simp only [StagedPoint.le]
                  push_neg
                  exact ⟨fun h => he_not_p (h.symm ▸ he_p), he_not_p⟩
              · -- [e] < [q]
                rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                constructor
                · exact Or.inr he_q
                · simp only [StagedPoint.le]
                  push_neg
                  exact ⟨fun h => hq_not_e (h ▸ he_q), hq_not_e⟩
            · -- d ≁ p
              -- Check if d ~ c (hence d ~ q)
              by_cases h_dc : CanonicalR c.mcs d.mcs
              · -- d ~ c ~ q: use strict_intermediate_exists
                obtain ⟨e, he_p, he_not_p, he_q, hq_not_e⟩ :=
                  strict_intermediate_exists root_mcs root_mcs_proof p q h_R h_not_R
                use toAntisymmetrization (· ≤ ·) e
                constructor
                · -- [p] < [e]
                  rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                  constructor
                  · exact Or.inr he_p
                  · simp only [StagedPoint.le]
                    push_neg
                    exact ⟨fun h => he_not_p (h.symm ▸ he_p), he_not_p⟩
                · -- [e] < [q]
                  rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                  constructor
                  · exact Or.inr he_q
                  · simp only [StagedPoint.le]
                    push_neg
                    exact ⟨fun h => hq_not_e (h ▸ he_q), hq_not_e⟩
              · -- d ≁ p AND d ≁ c (hence d ≁ q)
                have h_dq : ¬CanonicalR q.1.mcs d.mcs := by
                  intro h_qd
                  -- c ~ q means CanonicalR(q, c) = h_cq and CanonicalR(c, q) = hc_R_q
                  -- We want to show CanonicalR(c, d) to get c ~ d, contradicting h_dc
                  -- From h_cq : CanonicalR(q, c) and h_qd : CanonicalR(q, d), we use linearity:
                  -- CanonicalR(q, c) and CanonicalR(q, d) by linearity gives one of:
                  -- CanonicalR(c, d), CanonicalR(d, c), or c = d
                  -- We have CanonicalR(d, c) from hd_R_c. If c = d, then trivially c ~ d.
                  -- Need to show: from CanonicalR(q, c), CanonicalR(q, d), CanonicalR(d, c),
                  -- we can derive CanonicalR(c, d).
                  -- Use linearity: canonical_forward_reachable_linear on q, c, d
                  have h_lin := canonical_forward_reachable_linear q.1.mcs c.mcs d.mcs
                    q.1.is_mcs c.is_mcs d.is_mcs h_cq h_qd
                  rcases h_lin with h_cd | h_dc' | h_eq
                  · -- CanonicalR(c, d): contradiction with h_dc
                    exact h_dc h_cd
                  · -- CanonicalR(d, c): already have this from hd_R_c, no new info
                    -- But we also have CanonicalR(d, c), so if we can show CanonicalR(c, d)...
                    -- Actually h_dc' duplicates hd_R_c. We need a different approach.
                    -- Let me use a different linearity: from q reachable from c (via h_cq inverted)
                    -- Wait, h_cq : CanonicalR(q, c) means GContent(q) ⊆ c
                    -- And hc_R_q : CanonicalR(c, q) means GContent(c) ⊆ q
                    -- So c ~ q (bidirectional). Therefore CanonicalR(c, d) iff CanonicalR(q, d).
                    -- We have CanonicalR(q, d) from h_qd. By c ~ q: CanonicalR(c, d).
                    -- More precisely: CanonicalR(q, d) means GContent(q) ⊆ d
                    -- CanonicalR(c, q) means GContent(c) ⊆ q
                    -- For CanonicalR(c, d), need GContent(c) ⊆ d
                    -- GContent(c) ⊆ q (from hc_R_q)
                    -- GContent(q) ⊆ d (from h_qd)
                    -- Need: GContent(c) ⊆ GContent(q)? Not directly...
                    -- Actually, use Temporal 4: if G(phi) ∈ c, then G(G(phi)) ∈ c
                    -- So G(phi) ∈ GContent(c) ⊆ q. Hence phi ∈ GContent(q) ⊆ d.
                    -- Wait, GContent(c) ⊆ q means: if G(phi) ∈ c, then phi ∈ q. Not G(phi) ∈ q.
                    -- Let me be more careful.
                    -- CanonicalR(c, q) = GContent(c) ⊆ q
                    -- GContent(c) = { phi | G(phi) ∈ c }
                    -- So: if G(phi) ∈ c, then phi ∈ q.
                    -- CanonicalR(q, d) = GContent(q) ⊆ d
                    -- So: if G(psi) ∈ q, then psi ∈ d.
                    -- For CanonicalR(c, d), need: if G(phi) ∈ c, then phi ∈ d.
                    -- If G(phi) ∈ c, by Temporal 4, G(G(phi)) ∈ c.
                    -- So G(phi) ∈ GContent(c) ⊆ q, hence G(phi) ∈ q.
                    -- Then phi ∈ GContent(q) ⊆ d, so phi ∈ d.
                    -- This shows CanonicalR(c, d)!
                    have h_cd : CanonicalR c.mcs d.mcs := by
                      intro phi h_phi_Gc
                      -- h_phi_Gc : G(phi) ∈ c.mcs
                      -- By Temporal 4: G(G(phi)) ∈ c.mcs
                      have h_T4 : [] ⊢ (Formula.all_future phi).imp
                          (Formula.all_future (Formula.all_future phi)) :=
                        DerivationTree.axiom [] _ (Axiom.temp_4 phi)
                      have h_GGphi : Formula.all_future (Formula.all_future phi) ∈ c.mcs :=
                        set_mcs_implication_property c.is_mcs (theorem_in_mcs c.is_mcs h_T4) h_phi_Gc
                      -- G(phi) ∈ GContent(c) ⊆ q (via hc_R_q)
                      have h_Gphi_q : Formula.all_future phi ∈ q.1.mcs := hc_R_q h_GGphi
                      -- phi ∈ GContent(q) ⊆ d (via h_qd)
                      exact h_qd h_Gphi_q
                    exact h_dc h_cd
                  · -- c = d: then c ~ d trivially (same MCS is reflexive in ~)
                    exact h_dc (h_eq ▸ hd_R_c)
                use toAntisymmetrization (· ≤ ·) d'
                constructor
                · -- [p] < [d]
                  rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                  constructor
                  · exact Or.inr hd_R_p
                  · simp only [StagedPoint.le]
                    push_neg
                    exact ⟨fun h => h_dp (h.symm ▸ hd_R_p), h_dp⟩
                · -- [d] < [q]
                  rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
                  constructor
                  · exact Or.inr hd_R_q
                  · simp only [StagedPoint.le]
                    push_neg
                    exact ⟨fun h => h_dq (h ▸ hd_R_q), h_dq⟩
          · -- ¬(c ~ p) and ¬(c ~ q): c is strictly between!
            use toAntisymmetrization (· ≤ ·) c'
            constructor
            · -- [p] < [c]
              rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
              constructor
              · exact Or.inr hc_R_p
              · simp only [StagedPoint.le]
                push_neg
                constructor
                · intro h_eq
                  exact h_cp (h_eq.symm ▸ hc_R_p)
                · exact h_cp
            · -- [c] < [q]
              rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
              constructor
              · exact Or.inr hc_R_q
              · simp only [StagedPoint.le]
                push_neg
                constructor
                · intro h_eq
                  exact h_cq (h_eq ▸ hc_R_q)
                · exact h_cq

/-- Cantor's theorem: the timeline quotient is order-isomorphic to Q. -/
theorem cantor_iso :
    Nonempty (TimelineQuot root_mcs root_mcs_proof ≃o Rat) :=
  Order.iso_of_countable_dense
    (TimelineQuot root_mcs root_mcs_proof) Rat

end Bimodal.Metalogic.StagedConstruction
