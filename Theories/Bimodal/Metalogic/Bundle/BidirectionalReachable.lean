import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame

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
## Summary

This module establishes:
1. `BidirectionalReachable M₀ M` - reflexive-transitive-symmetric closure of CanonicalR
2. `BidirectionalFragment M₀ h_mcs₀` - the type of MCSes bidirectionally reachable from M₀
3. Forward and backward closure: taking CanonicalR edges stays in the fragment
4. `forward_F_stays_in_fragment`: F-witnesses are in the fragment
5. `backward_P_stays_in_fragment`: P-witnesses are in the fragment

Next steps (Phase B of plan):
- Prove that any two elements in the bidirectional fragment are CanonicalR-comparable
- This uses the linearity axiom to establish total ordering within the fragment
-/

end Bimodal.Metalogic.Bundle
