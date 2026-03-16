import Bimodal.Metalogic.StagedConstruction.CantorApplication

/-!
# D Construction from Cantor Isomorphism

This module defines the domain D for the canonical model as the TimelineQuot,
which is order-isomorphic to the rationals Q via Cantor's theorem.

## Overview

The dense staged timeline (from DenseTimeline.lean and CantorApplication.lean)
provides a countable, dense, linearly ordered set without endpoints. By Cantor's
uniqueness theorem, this is order-isomorphic to Q.

This module:
1. Defines D as an abbreviation for TimelineQuot (the antisymmetrization)
2. Defines task_rel as the strict linear order on D
3. Proves basic frame properties: transitivity, density, seriality

## Key Definitions

- `D`: The domain type (= TimelineQuot, isomorphic to Q)
- `task_rel`: The strict temporal relation (= `<` on D)
- `cantor_iso`: The order isomorphism D ≃o Q (re-exported)

## References

- Task 956, plan v025: Phase 9
- CantorApplication.lean: Cantor isomorphism to Q
- DenseTimeline.lean: Dense timeline construction
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Domain D

D is defined as TimelineQuot, the antisymmetrization of the dense timeline.
By Cantor's theorem, D ≃o Q.
-/

/-- The domain D is the timeline quotient, order-isomorphic to Q via Cantor's theorem.

This is the canonical model domain: a countable, dense, linear order without endpoints.
Each element of D represents an equivalence class of staged MCSs under mutual
CanonicalR accessibility.
-/
abbrev D : Type := TimelineQuot root_mcs root_mcs_proof

/-!
## Task Relation

The task relation is the strict order `<` on D. This is an irreflexive,
transitive, dense relation without endpoints.
-/

/-- The task relation: `task_rel d d'` iff `d < d'` in the linear order.

This is the strict temporal relation on the canonical model domain.
Properties:
- Irreflexive (d < d is false)
- Transitive (d < d' and d' < d'' implies d < d'')
- Dense (d < d'' implies exists d' with d < d' < d'')
- Serial (for all d, exists d' with d < d' and exists d'' with d'' < d)
-/
def task_rel (d d' : D root_mcs root_mcs_proof) : Prop := d < d'

/-!
## Properties of task_rel

These properties follow directly from the LinearOrder and Cantor prerequisites
on TimelineQuot.
-/

/-- task_rel is irreflexive: no element is strictly less than itself. -/
theorem task_rel_irrefl (d : D root_mcs root_mcs_proof) : ¬task_rel root_mcs root_mcs_proof d d :=
  lt_irrefl d

/-- task_rel is transitive: if d < d' and d' < d'', then d < d''. -/
theorem task_rel_trans {d d' d'' : D root_mcs root_mcs_proof}
    (h1 : task_rel root_mcs root_mcs_proof d d')
    (h2 : task_rel root_mcs root_mcs_proof d' d'') :
    task_rel root_mcs root_mcs_proof d d'' :=
  lt_trans h1 h2

/-- task_rel is dense: between any two related elements, there exists an intermediate.

This follows from `DenselyOrdered TimelineQuot`. -/
theorem task_rel_dense {d d'' : D root_mcs root_mcs_proof}
    (h : task_rel root_mcs root_mcs_proof d d'') :
    ∃ d' : D root_mcs root_mcs_proof,
      task_rel root_mcs root_mcs_proof d d' ∧
      task_rel root_mcs root_mcs_proof d' d'' := by
  have := DenselyOrdered.dense d d'' h
  exact this

/-- task_rel is forward-serial: every element has a strictly greater element.

This follows from `NoMaxOrder TimelineQuot`. -/
theorem task_rel_serial_forward (d : D root_mcs root_mcs_proof) :
    ∃ d' : D root_mcs root_mcs_proof, task_rel root_mcs root_mcs_proof d d' := by
  have := NoMaxOrder.exists_gt d
  exact this

/-- task_rel is backward-serial: every element has a strictly smaller element.

This follows from `NoMinOrder TimelineQuot`. -/
theorem task_rel_serial_backward (d : D root_mcs root_mcs_proof) :
    ∃ d' : D root_mcs root_mcs_proof, task_rel root_mcs root_mcs_proof d' d := by
  have := NoMinOrder.exists_lt d
  exact this

/-- task_rel is trichotomous: for any two elements, exactly one of <, =, > holds. -/
theorem task_rel_trichotomous (d d' : D root_mcs root_mcs_proof) :
    task_rel root_mcs root_mcs_proof d d' ∨ d = d' ∨ task_rel root_mcs root_mcs_proof d' d := by
  rcases lt_trichotomy d d' with h | h | h
  · exact Or.inl h
  · exact Or.inr (Or.inl h)
  · exact Or.inr (Or.inr h)

/-!
## Cantor Isomorphism

Re-export the Cantor isomorphism for external use.
-/

/-- The Cantor isomorphism: D ≃o Q.

By Cantor's uniqueness theorem, any countable dense linear order without endpoints
is order-isomorphic to the rationals. This isomorphism is the key result connecting
the syntactic construction (MCSs and CanonicalR) to the semantic model (Q-indexed timeline).
-/
theorem cantor_isomorphism :
    Nonempty (D root_mcs root_mcs_proof ≃o Rat) :=
  cantor_iso root_mcs root_mcs_proof

/-!
## Instance Re-exports

These instances are already provided by CantorApplication.lean, but we
document them here for clarity.
-/

-- LinearOrder is provided by TimelineQuotLinearOrder
-- Nonempty is provided by instNonemptyTimelineQuot
-- Countable is provided by instCountableTimelineQuot
-- NoMaxOrder is provided by instNoMaxOrderTimelineQuot
-- NoMinOrder is provided by instNoMinOrderTimelineQuot
-- DenselyOrdered is provided by instDenselyOrderedTimelineQuot

end Bimodal.Metalogic.StagedConstruction
