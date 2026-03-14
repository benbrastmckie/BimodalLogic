import Bimodal.Metalogic.StagedConstruction.DenseTimeline
import Bimodal.Metalogic.Canonical.CanonicalIrreflexivityAxiom
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

## Resolved via Axiom: Reflexive MCS Irreflexivity

The three Cantor prerequisites (`NoMaxOrder`, `NoMinOrder`, `DenselyOrdered`) are
proved from the `canonicalR_irreflexive` axiom in `Canonical/CanonicalIrreflexivityAxiom.lean`.

The axiom states `¬CanonicalR M M` for all MCSs M. This is a standard result in the
modal logic literature (Goldblatt 1992, BdRV 2001), provable when the atom type supports
freshness. With `String` atoms, the proof is blocked — see the axiom file for the full
analysis and resolution path (change atom type to support freshness).

From irreflexivity, the proof pattern is uniform: if `CanonicalR(M, N)` is a seriality
or density witness, then `¬CanonicalR(N, M)` (since mutual accessibility + T4 gives
`CanonicalR(M, M)`, contradicting irreflexivity). So all witnesses are strict.

## References

- Task 956, plan v015: Phase 6
- Task 960: Duration Group Construction analysis
- Mathlib `Order.iso_of_countable_dense`: Cantor's uniqueness theorem
- Mathlib `Antisymmetrization`: quotient construction for preorders
- `Canonical/CanonicalIrreflexivityAxiom.lean`: Irreflexivity axiom resolving the obstacle
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

/-- The timeline quotient has no maximum element.

Uses `canonicalR_irreflexive` axiom: seriality gives a forward witness N via
`canonical_forward_F`, and irreflexivity ensures `¬CanonicalR(N, M)` (since
mutual accessibility + T4 composition gives `CanonicalR(M, M)`, contradicting
the axiom). So `[M] < [N]` strictly in the quotient.
-/
instance : NoMaxOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_gt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      obtain ⟨q, hq_mem, hq_R⟩ := dense_timeline_has_future root_mcs root_mcs_proof p.1 p.2
      -- By irreflexivity axiom: CanonicalR(p.mcs, q.mcs) implies ¬CanonicalR(q.mcs, p.mcs)
      have h_strict : ¬CanonicalR q.mcs p.1.mcs :=
        canonicalR_strict p.1.mcs q.mcs p.1.is_mcs q.is_mcs hq_R
      let q' : DenseTimelineElem root_mcs root_mcs_proof := ⟨q, hq_mem⟩
      use toAntisymmetrization (· ≤ ·) q'
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
      constructor
      · exact Or.inr hq_R
      · intro hqp
        cases hqp with
        | inl h_eq => exact h_strict (h_eq.symm ▸ hq_R)
        | inr h_R => exact h_strict h_R

/-- The timeline quotient has no minimum element.

Symmetric to NoMaxOrder: past seriality gives a backward witness, and
irreflexivity ensures strictness in the quotient.
-/
instance : NoMinOrder (TimelineQuot root_mcs root_mcs_proof) where
  exists_lt := by
    intro a
    induction a using Antisymmetrization.ind with
    | _ p =>
      obtain ⟨q, hq_mem, hq_R⟩ := dense_timeline_has_past root_mcs root_mcs_proof p.1 p.2
      -- By irreflexivity axiom: CanonicalR(q.mcs, p.mcs) implies ¬CanonicalR(p.mcs, q.mcs)
      have h_strict : ¬CanonicalR p.1.mcs q.mcs :=
        canonicalR_strict q.mcs p.1.mcs q.is_mcs p.1.is_mcs hq_R
      let q' : DenseTimelineElem root_mcs root_mcs_proof := ⟨q, hq_mem⟩
      use toAntisymmetrization (· ≤ ·) q'
      rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
      constructor
      · exact Or.inr hq_R
      · intro hpq
        cases hpq with
        | inl h_eq => exact h_strict (h_eq ▸ hq_R)
        | inr h_R => exact h_strict h_R

/-- The timeline quotient is densely ordered.

Uses `canonicalR_irreflexive` axiom: the non-strict density frame condition
gives an intermediate W with `CanonicalR(M, W) ∧ CanonicalR(W, N)`. Irreflexivity
ensures both are strict: mutual accessibility would give `CanonicalR(M, M)` or
`CanonicalR(N, N)` by T4 composition, contradicting the axiom.
-/
instance : DenselyOrdered (TimelineQuot root_mcs root_mcs_proof) where
  dense := by
    intro a b hab
    induction a using Antisymmetrization.ind with
    | _ p =>
      induction b using Antisymmetrization.ind with
      | _ q =>
        rw [toAntisymmetrization_lt_toAntisymmetrization_iff] at hab
        obtain ⟨h_le, h_not_le⟩ := hab
        simp only [StagedPoint.le] at h_not_le
        push_neg at h_not_le
        obtain ⟨h_neq, h_not_R⟩ := h_not_le
        have h_R : CanonicalR p.1.mcs q.1.mcs := by
          simp only [StagedPoint.le] at h_le
          cases h_le with
          | inl h_eq => exact absurd h_eq.symm h_neq
          | inr h_R => exact h_R
        -- Non-strict density: get intermediate c with CanonicalR(p, c) ∧ CanonicalR(c, q)
        obtain ⟨c, hc_mem, hc_R_p, hc_R_q⟩ :=
          dense_timeline_has_intermediate root_mcs root_mcs_proof p.1 q.1 p.2 q.2 h_R h_not_R
        let c' : DenseTimelineElem root_mcs root_mcs_proof := ⟨c, hc_mem⟩
        use toAntisymmetrization (· ≤ ·) c'
        -- By irreflexivity: both orderings are strict
        have h_strict_pc : ¬CanonicalR c.mcs p.1.mcs :=
          canonicalR_strict p.1.mcs c.mcs p.1.is_mcs c.is_mcs hc_R_p
        have h_strict_qc : ¬CanonicalR q.1.mcs c.mcs :=
          canonicalR_strict c.mcs q.1.mcs c.is_mcs q.1.is_mcs hc_R_q
        constructor
        · -- p < c in quotient
          rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
          constructor
          · exact Or.inr hc_R_p
          · intro hcp
            cases hcp with
            | inl h_eq => exact h_strict_pc (h_eq.symm ▸ hc_R_p)
            | inr h_R' => exact h_strict_pc h_R'
        · -- c < q in quotient
          rw [toAntisymmetrization_lt_toAntisymmetrization_iff]
          constructor
          · exact Or.inr hc_R_q
          · intro hqc
            cases hqc with
            | inl h_eq => exact h_strict_qc (h_eq ▸ hc_R_q)
            | inr h_R' => exact h_strict_qc h_R'

/-- Cantor's theorem: the timeline quotient is order-isomorphic to Q. -/
theorem cantor_iso :
    Nonempty (TimelineQuot root_mcs root_mcs_proof ≃o Rat) :=
  Order.iso_of_countable_dense
    (TimelineQuot root_mcs root_mcs_proof) Rat

end Bimodal.Metalogic.StagedConstruction
