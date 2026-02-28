import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Completeness
import Bimodal.Metalogic.Bundle.TemporalCoherentConstruction

/-!
# Bidirectional Reachable Fragment

This module defines the bidirectional reachable fragment of the canonical frame from a root MCS.
Unlike the Boneyard's CanonicalReachable (one-directional, future-only), this captures MCSes
reachable by following CanonicalR edges in either direction (forward or backward).

## Overview

Given a root MCS `M₀`, the **bidirectional reachable fragment** consists of all MCSes `M`
that can be reached from `M₀` by a finite sequence of CanonicalR or CanonicalR⁻¹ edges.
This is the reflexive-transitive-symmetric closure of CanonicalR from `M₀`.

## Key Property: Fragment Contains F/P Witnesses

The critical advantage over the one-directional fragment:
- If `W` is in the bidirectional fragment and `F(φ) ∈ W`, the witness from `canonical_forward_F`
  is also in the fragment (one CanonicalR step forward)
- If `W` is in the bidirectional fragment and `P(φ) ∈ W`, the witness from `canonical_backward_P`
  is also in the fragment (one CanonicalR step backward)

This enables transfer of forward_F and backward_P from CanonicalMCS level to the fragment.

## Main Definitions

- `BidirectionalEdge M₁ M₂`: One-step reachability in either direction
- `BidirectionalReachable M₀ M`: `M` is reachable from `M₀` via finite BidirectionalEdge steps
- `BidirectionalFragment M₀ h_mcs₀`: Subtype of MCSes bidirectionally reachable from `M₀`

## References

- Task 951 plan v2: Bidirectional Reachable Fragment approach
- CanonicalFMCS.lean: canonicalMCS_forward_F, canonicalMCS_backward_P (sorry-free at CanonicalMCS level)
- Boneyard/CanonicalReachable.lean: One-directional predecessor (archived)
-/

namespace Bimodal.Metalogic.Bundle

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.ProofSystem

/-!
## Bidirectional Edge: One Step in Either Direction
-/

/--
A bidirectional edge between two MCSes: either CanonicalR or CanonicalR_past.

This captures one step of reachability in either the future or past direction.
-/
inductive BidirectionalEdge (M₁ M₂ : Set Formula) : Prop where
  | forward : CanonicalR M₁ M₂ → BidirectionalEdge M₁ M₂
  | backward : CanonicalR M₂ M₁ → BidirectionalEdge M₁ M₂

/--
BidirectionalEdge is symmetric.
-/
theorem BidirectionalEdge.symm {M₁ M₂ : Set Formula}
    (h : BidirectionalEdge M₁ M₂) : BidirectionalEdge M₂ M₁ := by
  cases h with
  | forward h_R => exact BidirectionalEdge.backward h_R
  | backward h_R => exact BidirectionalEdge.forward h_R

/-!
## Bidirectional Reachability: Transitive Closure
-/

/--
`BidirectionalReachable M₀ M` holds when `M` can be reached from `M₀` by a finite
sequence of bidirectional edges. This is the reflexive-transitive-symmetric closure
of CanonicalR from `M₀`.
-/
inductive BidirectionalReachable (M₀ : Set Formula) : Set Formula → Prop where
  | refl : BidirectionalReachable M₀ M₀
  | step {M₁ M₂ : Set Formula} : BidirectionalReachable M₀ M₁ →
      BidirectionalEdge M₁ M₂ → BidirectionalReachable M₀ M₂

/--
Alternative constructor: reach by taking a backward step.
-/
theorem BidirectionalReachable.step_backward {M₀ M₁ M₂ : Set Formula}
    (h_reach : BidirectionalReachable M₀ M₁) (h_R : CanonicalR M₂ M₁) :
    BidirectionalReachable M₀ M₂ :=
  BidirectionalReachable.step h_reach (BidirectionalEdge.backward h_R)

/--
Alternative constructor: reach by taking a forward step.
-/
theorem BidirectionalReachable.step_forward {M₀ M₁ M₂ : Set Formula}
    (h_reach : BidirectionalReachable M₀ M₁) (h_R : CanonicalR M₁ M₂) :
    BidirectionalReachable M₀ M₂ :=
  BidirectionalReachable.step h_reach (BidirectionalEdge.forward h_R)

/-!
## The Bidirectional Fragment Type
-/

variable {M₀ : Set Formula} {h_mcs₀ : SetMaximalConsistent M₀}

/--
A bidirectionally reachable MCS from root `M₀`: a set of formulas that is MCS
and can be reached from `M₀` by forward or backward CanonicalR edges.
-/
structure BidirectionalFragment (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) where
  /-- The underlying set of formulas -/
  world : Set Formula
  /-- The world is a maximal consistent set -/
  is_mcs : SetMaximalConsistent world
  /-- The world is bidirectionally reachable from M₀ -/
  reachable : BidirectionalReachable M₀ world

/--
Extensional equality for bidirectional fragment elements.
-/
theorem BidirectionalFragment.ext {a b : BidirectionalFragment M₀ h_mcs₀}
    (h : a.world = b.world) : a = b := by
  cases a; cases b; simp only [mk.injEq]; exact h

/--
The root `M₀` is in the bidirectional fragment (reflexivity).
-/
def BidirectionalFragment.root : BidirectionalFragment M₀ h_mcs₀ where
  world := M₀
  is_mcs := h_mcs₀
  reachable := BidirectionalReachable.refl

instance : Nonempty (BidirectionalFragment M₀ h_mcs₀) :=
  ⟨BidirectionalFragment.root⟩

/-!
## Fragment Closure Properties

The key properties: taking CanonicalR or CanonicalR⁻¹ steps from an element
of the fragment stays within the fragment.
-/

/--
Forward closure: If `W` is in the bidirectional fragment and `CanonicalR W W'`,
then `W'` is also in the bidirectional fragment.
-/
def BidirectionalFragment.forward_closed
    (a : BidirectionalFragment M₀ h_mcs₀)
    (W' : Set Formula) (h_mcs' : SetMaximalConsistent W')
    (h_R : CanonicalR a.world W') :
    BidirectionalFragment M₀ h_mcs₀ where
  world := W'
  is_mcs := h_mcs'
  reachable := a.reachable.step_forward h_R

/--
Backward closure: If `W` is in the bidirectional fragment and `CanonicalR W' W`,
then `W'` is also in the bidirectional fragment.
-/
def BidirectionalFragment.backward_closed
    (a : BidirectionalFragment M₀ h_mcs₀)
    (W' : Set Formula) (h_mcs' : SetMaximalConsistent W')
    (h_R : CanonicalR W' a.world) :
    BidirectionalFragment M₀ h_mcs₀ where
  world := W'
  is_mcs := h_mcs'
  reachable := a.reachable.step_backward h_R

/-!
## Forward_F and Backward_P Witnesses Stay in Fragment

This is the KEY property that enables transfer from CanonicalMCS level.
-/

/--
If `W` is in the bidirectional fragment and `F(φ) ∈ W`, then the witness MCS from
`canonical_forward_F` is also in the bidirectional fragment.

This uses:
1. `canonical_forward_F` gives witness `W'` with `CanonicalR W W'` and `φ ∈ W'`
2. Forward closure: `CanonicalR W W'` with `W` in fragment implies `W'` in fragment
-/
theorem forward_F_stays_in_fragment
    (a : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_F : Formula.some_future φ ∈ a.world) :
    ∃ (s : BidirectionalFragment M₀ h_mcs₀),
      CanonicalR a.world s.world ∧ φ ∈ s.world := by
  -- Get witness from canonical_forward_F at CanonicalMCS level
  obtain ⟨W', h_mcs', h_R, h_phi⟩ := canonical_forward_F a.world a.is_mcs φ h_F
  -- W' is in the fragment by forward closure
  let s := a.forward_closed W' h_mcs' h_R
  exact ⟨s, h_R, h_phi⟩

/--
If `W` is in the bidirectional fragment and `P(φ) ∈ W`, then the witness MCS from
`canonical_backward_P` is also in the bidirectional fragment.

This uses:
1. `canonical_backward_P` gives witness `W'` with `CanonicalR_past W W'` and `φ ∈ W'`
2. We convert `CanonicalR_past` to `CanonicalR` direction for fragment closure
-/
theorem backward_P_stays_in_fragment
    (a : BidirectionalFragment M₀ h_mcs₀)
    (φ : Formula) (h_P : Formula.some_past φ ∈ a.world) :
    ∃ (s : BidirectionalFragment M₀ h_mcs₀),
      CanonicalR_past a.world s.world ∧ φ ∈ s.world := by
  -- Get witness from canonical_backward_P at CanonicalMCS level
  obtain ⟨W', h_mcs', h_R_past, h_phi⟩ := canonical_backward_P a.world a.is_mcs φ h_P
  -- Convert CanonicalR_past to CanonicalR for backward closure
  -- CanonicalR_past a.world W' means HContent(a.world) ⊆ W'
  -- We need CanonicalR W' a.world for backward_closed, which means GContent(W') ⊆ a.world
  have h_R : CanonicalR W' a.world :=
    HContent_subset_implies_GContent_reverse a.world W' a.is_mcs h_mcs' h_R_past
  -- W' is in the fragment by backward closure
  let s := a.backward_closed W' h_mcs' h_R
  exact ⟨s, h_R_past, h_phi⟩

/-!
## Conversion to CanonicalMCS

Every element of the bidirectional fragment is a CanonicalMCS element.
This allows us to use the sorry-free forward_F/backward_P from CanonicalFMCS.lean.
-/

/--
Convert a bidirectional fragment element to a CanonicalMCS element.

Since every BidirectionalFragment element is an MCS, it's a valid CanonicalMCS element.
-/
def BidirectionalFragment.toCanonicalMCS (a : BidirectionalFragment M₀ h_mcs₀) :
    CanonicalMCS where
  world := a.world
  is_mcs := a.is_mcs

/--
The conversion preserves the underlying world.
-/
theorem BidirectionalFragment.toCanonicalMCS_world (a : BidirectionalFragment M₀ h_mcs₀) :
    a.toCanonicalMCS.world = a.world := rfl

/-!
## CanonicalR Preorder on the Bidirectional Fragment

The fragment inherits a Preorder from CanonicalR. We also have comparability
of elements via the linearity property.
-/

/--
Preorder on BidirectionalFragment via CanonicalR.
-/
noncomputable instance : Preorder (BidirectionalFragment M₀ h_mcs₀) where
  le a b := CanonicalR a.world b.world
  le_refl a := canonicalR_reflexive a.world a.is_mcs
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc

/-!
## Phase B: Linearity Infrastructure

The temp_linearity axiom ensures that elements reachable from a common ancestor
are CanonicalR-comparable. We adapt the infrastructure from CanonicalEmbedding.lean
(now in Boneyard) to prove totality within the bidirectional fragment.
-/

/--
Linearity in MCS: If `F(phi) ∈ M` and `F(psi) ∈ M`, then one of three disjuncts holds:
1. `F(phi ∧ psi) ∈ M` (witnesses coincide)
2. `F(phi ∧ F(psi)) ∈ M` (phi comes first, F(psi) still holds there)
3. `F(F(phi) ∧ psi) ∈ M` (psi comes first, F(phi) still holds there)

This applies the temp_linearity axiom within an MCS context.
-/
lemma mcs_F_linearity (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi psi : Formula)
    (h_Fphi : Formula.some_future phi ∈ M)
    (h_Fpsi : Formula.some_future psi ∈ M) :
    Formula.some_future (Formula.and phi psi) ∈ M ∨
    Formula.some_future (Formula.and phi (Formula.some_future psi)) ∈ M ∨
    Formula.some_future (Formula.and (Formula.some_future phi) psi) ∈ M := by
  -- From temp_linearity: ⊢ F(phi) ∧ F(psi) → F(phi ∧ psi) ∨ F(phi ∧ F(psi)) ∨ F(F(phi) ∧ psi)
  have h_lin : [] ⊢ (Formula.and (Formula.some_future phi) (Formula.some_future psi)).imp
      (Formula.or (Formula.some_future (Formula.and phi psi))
        (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
          (Formula.some_future (Formula.and (Formula.some_future phi) psi)))) :=
    DerivationTree.axiom [] _ (Axiom.temp_linearity phi psi)
  -- F(phi) ∧ F(psi) ∈ M
  have h_conj : Formula.and (Formula.some_future phi) (Formula.some_future psi) ∈ M :=
    set_mcs_conjunction_intro h_mcs h_Fphi h_Fpsi
  -- Apply linearity axiom via MCS closure
  have h_disj : Formula.or (Formula.some_future (Formula.and phi psi))
      (Formula.or (Formula.some_future (Formula.and phi (Formula.some_future psi)))
        (Formula.some_future (Formula.and (Formula.some_future phi) psi))) ∈ M :=
    set_mcs_implication_property h_mcs (theorem_in_mcs h_mcs h_lin) h_conj
  -- Extract disjuncts: either first disjunct or second disjunct (which itself is a disjunction)
  rcases set_mcs_disjunction_elim h_mcs h_disj with h1 | h23
  · exact Or.inl h1
  · rcases set_mcs_disjunction_elim h_mcs h23 with h2 | h3
    · exact Or.inr (Or.inl h2)
    · exact Or.inr (Or.inr h3)

/--
If `phi ∈ M'` and `CanonicalR M M'`, then `F(phi) ∈ M`.

This is the F-introduction rule: if phi holds in a future-accessible MCS,
then F(phi) holds in the current MCS.

**Proof**: We show ¬F(phi) ∈ M leads to contradiction.
F(phi) = ¬G(¬phi), so ¬F(phi) = ¬¬G(¬phi). By double negation elimination,
this gives G(¬phi) ∈ M. Then CanonicalR M M' gives ¬phi ∈ M'.
But phi ∈ M' by hypothesis, contradicting MCS consistency.
-/
lemma canonical_F_of_mem_successor (M M' : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mcs' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') (phi : Formula) (h_phi : phi ∈ M') :
    Formula.some_future phi ∈ M := by
  -- F(phi) = ¬G(¬phi). By MCS negation completeness, either F(phi) ∈ M or ¬F(phi) ∈ M
  by_contra h_not_F
  -- Since F(phi) ∉ M, we have ¬F(phi) ∈ M
  have h_neg_F : Formula.neg (Formula.some_future phi) ∈ M := by
    rcases set_mcs_negation_complete h_mcs (Formula.some_future phi) with h | h
    · exact absurd h h_not_F
    · exact h
  -- ¬F(phi) = ¬(¬G(¬phi)) = ¬¬G(¬phi). By double negation elimination: G(¬phi) ∈ M
  -- F(phi) = φ.neg.all_future.neg, so neg(F(phi)) = neg(φ.neg.all_future.neg)
  have h_neg_F_eq : Formula.neg (Formula.some_future phi) =
      Formula.neg (Formula.neg (Formula.all_future (Formula.neg phi))) := rfl
  rw [h_neg_F_eq] at h_neg_F
  have h_G_neg : Formula.all_future (Formula.neg phi) ∈ M :=
    mcs_double_neg_elim h_mcs _ h_neg_F
  -- By CanonicalR M M' and G(¬phi) ∈ M, we have ¬phi ∈ GContent(M) ⊆ M'
  have h_neg_phi_M' : Formula.neg phi ∈ M' := h_R h_G_neg
  -- Contradiction: phi and ¬phi both in MCS M'
  exact set_consistent_not_both h_mcs'.1 phi h_phi h_neg_phi_M'

/--
Linearity of forward-reachable elements: If M₁ and M₂ are both CanonicalR-reachable
from M, then M₁ and M₂ are CanonicalR-comparable.

This is the key structural property from the temp_linearity axiom.

**Proof**: By contradiction using mcs_F_linearity on compound formulas.
-/
theorem canonical_forward_reachable_linear (M M1 M2 : Set Formula)
    (h_mcs : SetMaximalConsistent M)
    (h_mcs1 : SetMaximalConsistent M1)
    (h_mcs2 : SetMaximalConsistent M2)
    (h_R1 : CanonicalR M M1) (h_R2 : CanonicalR M M2) :
    CanonicalR M1 M2 ∨ CanonicalR M2 M1 ∨ M1 = M2 := by
  -- By classical case analysis
  by_cases h_12 : CanonicalR M1 M2
  · exact Or.inl h_12
  · right
    by_contra h_neg
    push_neg at h_neg
    obtain ⟨h_not_21, h_neq⟩ := h_neg
    -- NOT(CanonicalR M1 M2): exists alpha with G(alpha) ∈ M1 and alpha ∉ M2
    have h_not_sub_12 : ¬(GContent M1 ⊆ M2) := h_12
    rw [Set.not_subset] at h_not_sub_12
    obtain ⟨alpha, h_alpha_G1, h_alpha_not2⟩ := h_not_sub_12
    have h_G_alpha_M1 : Formula.all_future alpha ∈ M1 := h_alpha_G1
    have h_neg_alpha_M2 : Formula.neg alpha ∈ M2 := by
      rcases set_mcs_negation_complete h_mcs2 alpha with h | h
      · exact absurd h h_alpha_not2
      · exact h
    -- NOT(CanonicalR M2 M1): exists beta with G(beta) ∈ M2 and beta ∉ M1
    have h_not_sub_21 : ¬(GContent M2 ⊆ M1) := h_not_21
    rw [Set.not_subset] at h_not_sub_21
    obtain ⟨beta, h_beta_G2, h_beta_not1⟩ := h_not_sub_21
    have h_G_beta_M2 : Formula.all_future beta ∈ M2 := h_beta_G2
    have h_neg_beta_M1 : Formula.neg beta ∈ M1 := by
      rcases set_mcs_negation_complete h_mcs1 beta with h | h
      · exact absurd h h_beta_not1
      · exact h
    -- Construct compound formulas
    have h_conj_M1 : Formula.and (Formula.all_future alpha) (Formula.neg beta) ∈ M1 :=
      set_mcs_conjunction_intro h_mcs1 h_G_alpha_M1 h_neg_beta_M1
    have h_conj_M2 : Formula.and (Formula.all_future beta) (Formula.neg alpha) ∈ M2 :=
      set_mcs_conjunction_intro h_mcs2 h_G_beta_M2 h_neg_alpha_M2
    -- F(conj) ∈ M
    have h_F_conj1 : Formula.some_future (Formula.and (Formula.all_future alpha) (Formula.neg beta)) ∈ M :=
      canonical_F_of_mem_successor M M1 h_mcs h_mcs1 h_R1 _ h_conj_M1
    have h_F_conj2 : Formula.some_future (Formula.and (Formula.all_future beta) (Formula.neg alpha)) ∈ M :=
      canonical_F_of_mem_successor M M2 h_mcs h_mcs2 h_R2 _ h_conj_M2
    -- Apply linearity
    have h_lin := mcs_F_linearity M h_mcs
      (Formula.and (Formula.all_future alpha) (Formula.neg beta))
      (Formula.and (Formula.all_future beta) (Formula.neg alpha))
      h_F_conj1 h_F_conj2
    -- All three cases yield contradiction
    rcases h_lin with h_case1 | h_case2 | h_case3
    · -- Case 1: F(conj1 ∧ conj2)
      obtain ⟨W, h_W_mcs, _, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case1
      have h_big_conj := set_mcs_conjunction_elim h_W_mcs h_W_mem
      have h_left := h_big_conj.1
      have h_right := h_big_conj.2
      have h_left_parts := set_mcs_conjunction_elim h_W_mcs h_left
      have h_right_parts := set_mcs_conjunction_elim h_W_mcs h_right
      have h_alpha_W : alpha ∈ W := by
        have h_T : [] ⊢ (Formula.all_future alpha).imp alpha :=
          DerivationTree.axiom [] _ (Axiom.temp_t_future alpha)
        exact set_mcs_implication_property h_W_mcs (theorem_in_mcs h_W_mcs h_T) h_left_parts.1
      have h_neg_alpha_W := h_right_parts.2
      exact set_consistent_not_both h_W_mcs.1 alpha h_alpha_W h_neg_alpha_W
    · -- Case 2: F(conj1 ∧ F(conj2))
      obtain ⟨W, h_W_mcs, h_R_MW, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case2
      have h_outer := set_mcs_conjunction_elim h_W_mcs h_W_mem
      have h_conj1_in_W := h_outer.1
      have h_F_conj2_W := h_outer.2
      have h_conj1_parts := set_mcs_conjunction_elim h_W_mcs h_conj1_in_W
      have h_G_alpha_W := h_conj1_parts.1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_conj2_W'⟩ := canonical_forward_F W h_W_mcs _ h_F_conj2_W
      have h_conj2_parts := set_mcs_conjunction_elim h_W'_mcs h_conj2_W'
      have h_neg_alpha_W' := h_conj2_parts.2
      have h_alpha_W' : alpha ∈ W' := canonical_forward_G W W' h_R_WW' alpha h_G_alpha_W
      exact set_consistent_not_both h_W'_mcs.1 alpha h_alpha_W' h_neg_alpha_W'
    · -- Case 3: F(F(conj1) ∧ conj2)
      obtain ⟨W, h_W_mcs, h_R_MW, h_W_mem⟩ := canonical_forward_F M h_mcs _ h_case3
      have h_outer := set_mcs_conjunction_elim h_W_mcs h_W_mem
      have h_F_conj1_W := h_outer.1
      have h_conj2_in_W := h_outer.2
      have h_conj2_parts := set_mcs_conjunction_elim h_W_mcs h_conj2_in_W
      have h_G_beta_W := h_conj2_parts.1
      obtain ⟨W', h_W'_mcs, h_R_WW', h_conj1_W'⟩ := canonical_forward_F W h_W_mcs _ h_F_conj1_W
      have h_conj1_parts := set_mcs_conjunction_elim h_W'_mcs h_conj1_W'
      have h_neg_beta_W' := h_conj1_parts.2
      have h_beta_W' : beta ∈ W' := canonical_forward_G W W' h_R_WW' beta h_G_beta_W
      exact set_consistent_not_both h_W'_mcs.1 beta h_beta_W' h_neg_beta_W'

/-!
## Summary

This module establishes:
1. `BidirectionalReachable M₀ M` - reflexive-transitive-symmetric closure of CanonicalR
2. `BidirectionalFragment M₀ h_mcs₀` - the type of MCSes bidirectionally reachable from M₀
3. Forward and backward closure: taking CanonicalR edges stays in the fragment
4. `forward_F_stays_in_fragment`: F-witnesses are in the fragment
5. `backward_P_stays_in_fragment`: P-witnesses are in the fragment
6. `mcs_F_linearity`: Linearity axiom application in MCS context
7. `canonical_forward_reachable_linear`: Totality for forward-reachable elements

Next steps (remaining Phase B):
- Extend `canonical_forward_reachable_linear` to bidirectional reachability
- Prove `bidirectional_totally_ordered` for the full fragment
-/

end Bimodal.Metalogic.Bundle
