import Bimodal.Metalogic.Representation.TaskRelation
import Bimodal.Semantics.WorldHistory

/-!
# Canonical History Construction for Universal Parametric Canonical Model

This module constructs canonical world histories from maximal consistent sets.
For each MCS Gamma, we construct a history that:
1. Has full domain (all times in D)
2. Assigns a canonical world at each time
3. Respects the canonical task relation

## Overview

The key insight is that given an MCS Gamma, we can construct a history where:
- The time domain is all of D (full/universal domain)
- At time t, the world is (Gamma, t) - same MCS, varying time
- The task relation is automatically satisfied by construction

## Main Definitions

- `UniversalCanonicalFrame`: The canonical TaskFrame over D
- `canonical_history`: The WorldHistory for an MCS

## References

- Research report: specs/654_.../reports/research-003.md
- Implementation plan: specs/654_.../plans/implementation-003.md
-/

namespace Bimodal.Metalogic.Representation

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic_v2.Core
open Bimodal.Semantics

/-!
## Canonical Frame

The canonical frame is defined using canonical worlds and task relation.
Note: We fix D : Type to match TaskFrame's universe constraint.
-/

variable (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
The universal canonical frame over duration type D.

This frame uses canonical worlds (MCS + time) and the canonical task relation.
-/
def UniversalCanonicalFrame : TaskFrame D where
  WorldState := CanonicalWorld D
  task_rel := canonical_task_rel
  nullity := canonical_task_rel_nullity
  compositionality := canonical_task_rel_comp

/-!
## Canonical History Domain

For the canonical model, histories have full domain (all times are valid).
-/

/--
Full domain predicate: all times are in the domain.
-/
def full_domain : D → Prop := fun _ => True

/--
Full domain is trivially convex.
-/
lemma full_domain_convex : ∀ (x z : D), full_domain D x → full_domain D z →
    ∀ (y : D), x ≤ y → y ≤ z → full_domain D y :=
  fun _ _ _ _ _ _ _ => trivial

/-!
## Canonical History Construction

Given an MCS Gamma, construct a history where all worlds share Gamma.
-/

/--
Canonical history states: at time t, the world has MCS Gamma at time t.

This creates a "line" of worlds through the same MCS at different times.
-/
def canonical_history_states (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    (t : D) → full_domain D t → (UniversalCanonicalFrame D).WorldState :=
  fun t _ => { mcs := Gamma, time := t, is_mcs := h_mcs }

/--
The canonical task relation holds between consecutive states in a canonical history.

This is because the history uses the same MCS throughout, and our task relation
is defined to handle this case.
-/
lemma canonical_history_respects (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    ∀ (s t : D) (hs : full_domain D s) (ht : full_domain D t),
      s ≤ t → (UniversalCanonicalFrame D).task_rel
        (canonical_history_states D Gamma h_mcs s hs)
        (t - s)
        (canonical_history_states D Gamma h_mcs t ht) := by
  intro s t _hs _ht hst
  unfold canonical_history_states UniversalCanonicalFrame canonical_task_rel
  simp only
  -- We need to show the task relation holds between (Gamma, s) and (Gamma, t)
  -- The duration is t - s
  by_cases hd : t - s = 0
  · -- t - s = 0 case: same time, so s = t
    simp only [hd, dite_eq_ite, ite_true]
    -- Need: True ∧ s = t
    constructor
    · trivial
    · -- s = t follows from t - s = 0
      have heq : t = s := by
        have h : t - s + s = 0 + s := by rw [hd]
        simp at h
        exact h
      exact heq.symm
  · -- t - s ≠ 0 case
    simp only [hd, dite_eq_ite, ite_false]
    by_cases hpos : 0 < t - s
    · -- Positive duration (t > s)
      simp only [hpos, ite_true]
      refine ⟨?_, ?_, ?_⟩
      · -- G φ ∈ Gamma → φ ∈ Gamma
        -- This follows from the T-axiom for G: G φ → φ
        intro φ hG
        sorry -- T-axiom application for future
      · -- H φ ∈ Gamma → φ ∈ Gamma
        intro φ hH
        sorry -- T-axiom application for past
      · -- Time arithmetic: t = s + (t - s)
        simp only [add_sub_cancel]
    · -- Negative duration case: impossible since s ≤ t implies t - s ≥ 0
      exfalso
      have hnonneg : 0 ≤ t - s := sub_nonneg.mpr hst
      have hlt : t - s < 0 := by
        push_neg at hpos
        exact lt_of_le_of_ne hpos (fun h => hd h)
      exact not_le.mpr hlt hnonneg

/--
The canonical history for an MCS Gamma.

This WorldHistory:
- Has full domain (all times in D)
- Assigns the same MCS Gamma at each time
- Satisfies the task relation by construction
-/
def canonical_history (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) :
    WorldHistory (UniversalCanonicalFrame D) where
  domain := full_domain D
  convex := full_domain_convex D
  states := canonical_history_states D Gamma h_mcs
  respects_task := canonical_history_respects D Gamma h_mcs

/-!
## Properties of Canonical Histories
-/

/--
The MCS at any time in a canonical history is the original Gamma.
-/
lemma canonical_history_mcs (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) (ht : (canonical_history D Gamma h_mcs).domain t) :
    ((canonical_history D Gamma h_mcs).states t ht).mcs = Gamma :=
  rfl

/--
The time at any point in a canonical history matches the time parameter.
-/
lemma canonical_history_time (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) (ht : (canonical_history D Gamma h_mcs).domain t) :
    ((canonical_history D Gamma h_mcs).states t ht).time = t :=
  rfl

/--
All times are in the domain of a canonical history.
-/
lemma canonical_history_full_domain (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) : (canonical_history D Gamma h_mcs).domain t :=
  trivial

end Bimodal.Metalogic.Representation
