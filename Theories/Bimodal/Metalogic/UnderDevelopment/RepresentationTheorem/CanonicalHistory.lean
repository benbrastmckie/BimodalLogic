/-!
# UNDER DEVELOPMENT - Canonical History Construction

**Status**: Under Development (restored from Boneyard/Metalogic_v4/ by Task 774)
**Sorry Count**: 0 (this file is sorry-free, but depends on sorried TaskRelation)
**Original Location**: `Metalogic/Representation/CanonicalHistory.lean`
**Reason**: Depends on TaskRelation.lean (5 sorries) which was architecturally unprovable

## Development Status

This file constructs canonical world histories from indexed MCS families. It is sorry-free
itself, but depends on `TaskRelation.lean` which contains 5 sorries for cross-sign duration
composition that are architecturally unprovable.

The `UniversalCanonicalFrame` defined here uses `canonical_task_rel_comp` from TaskRelation,
which is a sorry because task relation compositionality across sign boundaries requires an
omega-rule or cross-origin axioms not present in TM logic.

## Key Definitions

- `UniversalCanonicalFrame D`: The canonical TaskFrame over duration type D
- `canonical_history`: WorldHistory using same MCS at all times (blocked by T-axiom)
- `canonical_history_family`: WorldHistory from IndexedMCSFamily (main construction)

## Working Alternative

For completeness proofs, use `semantic_weak_completeness` from `FMP/SemanticCanonicalModel.lean`
which works via contrapositive and avoids the task relation compositionality issue entirely.

## References

- Task 750: Truth bridge analysis confirming architectural limitations
- Task 769: Deprecation of sorried code with DEPRECATED markers
- Task 772: Original archival
- Task 774: Restoration to UnderDevelopment/
-/

import Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem.TaskRelation
import Bimodal.Metalogic.Representation.IndexedMCSFamily
import Bimodal.Semantics.WorldHistory

/-!
# Canonical History Construction for Universal Parametric Canonical Model

This module constructs canonical world histories from indexed MCS families.
For each `IndexedMCSFamily`, we construct a history that:
1. Has full domain (all times in D)
2. Assigns a canonical world at each time using the family's MCS
3. Respects the canonical task relation via family coherence conditions

## Overview

**Key Insight (from research-004.md)**: The "same MCS at all times" approach fails
because it requires temporal T-axioms (G phi -> phi, H phi -> phi) that TM logic
does NOT have. G/H are irreflexive operators.

**Solution**: Use an `IndexedMCSFamily` where each time has its own MCS, connected
by temporal coherence conditions:
- forward_G: G phi in mcs(t) implies phi in mcs(t') for t' > t
- backward_H: H phi in mcs(t) implies phi in mcs(t') for t' < t
- forward_H: H phi in mcs(t') implies phi in mcs(t) for t < t'
- backward_G: G phi in mcs(t') implies phi in mcs(t) for t' < t

## Main Definitions

- `UniversalCanonicalFrame`: The canonical TaskFrame over D
- `canonical_history_family`: WorldHistory from an IndexedMCSFamily

## References

- Research report: specs/654_.../reports/research-004.md (indexed family approach)
- Implementation plan: specs/654_.../plans/implementation-004.md
-/

namespace Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Representation
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
        -- This follows from the T-axiom for G: G φ → φ (temp_t_future)
        intro φ hG
        exact mcs_closed_temp_t_future h_mcs φ hG
      · -- H φ ∈ Gamma → φ ∈ Gamma
        -- This follows from the T-axiom for H: H φ → φ (temp_t_past)
        intro φ hH
        exact mcs_closed_temp_t_past h_mcs φ hH
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

/-!
## Indexed Family-Based Canonical History (v004)

This section provides the refactored canonical history using IndexedMCSFamily
instead of a single MCS at all times.

**Why this approach works**:
- The old approach required G phi -> phi (T-axiom) to show task relation
- TM logic does NOT have this axiom (G is irreflexive)
- IndexedMCSFamily provides coherence conditions that work without T-axiom
- forward_G gives us: G phi in mcs(t) implies phi in mcs(t') for t' > t
- This is exactly what we need for the positive duration case
-/

/--
Canonical history states from an indexed family.

At time t, the canonical world uses the family's MCS at t.
-/
def canonical_history_family_states (family : IndexedMCSFamily D) :
    (t : D) → full_domain D t → (UniversalCanonicalFrame D).WorldState :=
  fun t _ => { mcs := family.mcs t, time := t, is_mcs := family.is_mcs t }

/--
The task relation holds between consecutive states in a family-based canonical history.

**Proof Strategy**:
- d = 0: trivial (nullity)
- d > 0: use forward_G for G formulas, forward_H for H formulas
- d < 0: use backward_G and backward_H

**Key Insight**: Unlike the single-MCS approach, we don't need T-axioms.
The family coherence conditions directly provide the formula propagation.
-/
lemma canonical_history_family_respects (family : IndexedMCSFamily D) :
    ∀ (s t : D) (hs : full_domain D s) (ht : full_domain D t),
      s ≤ t → (UniversalCanonicalFrame D).task_rel
        (canonical_history_family_states D family s hs)
        (t - s)
        (canonical_history_family_states D family t ht) := by
  intro s t _hs _ht hst
  unfold canonical_history_family_states UniversalCanonicalFrame canonical_task_rel
  simp only
  by_cases hd : t - s = 0
  · -- t - s = 0 case: same time, so s = t
    simp only [hd, dite_eq_ite, ite_true]
    constructor
    · -- MCS equality at same time
      have heq : t = s := by
        have h : t - s + s = 0 + s := by rw [hd]
        simp at h
        exact h
      subst heq
      rfl
    · -- Time equality
      have heq : t = s := by
        have h : t - s + s = 0 + s := by rw [hd]
        simp at h
        exact h
      exact heq.symm
  · -- t - s ≠ 0 case
    simp only [hd, dite_eq_ite, ite_false]
    by_cases hpos : 0 < t - s
    · -- Positive duration (t > s, moving forward in time)
      simp only [hpos, ite_true]
      refine ⟨?_, ?_, ?_⟩
      · -- G φ ∈ family.mcs s → φ ∈ family.mcs t
        -- Use forward_G: G phi at s implies phi at t since s < t
        intro φ hG
        have hlt : s < t := by
          have hpos' : 0 < t - s := hpos
          have : s < s + (t - s) := by
            rw [add_comm]
            exact lt_add_of_pos_left s hpos'
          simp at this
          exact this
        exact family.forward_G s t φ hlt hG
      · -- H φ ∈ family.mcs t → φ ∈ family.mcs s
        -- Use forward_H: H phi at t implies phi at s since s < t
        intro φ hH
        have hlt : s < t := by
          have hpos' : 0 < t - s := hpos
          have : s < s + (t - s) := by
            rw [add_comm]
            exact lt_add_of_pos_left s hpos'
          simp at this
          exact this
        exact family.forward_H s t φ hlt hH
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
The canonical history from an indexed MCS family.

This WorldHistory:
- Has full domain (all times in D)
- Uses the family's MCS at each time (different MCS at different times)
- Satisfies the task relation via family coherence conditions

**Contrast with `canonical_history`**:
- `canonical_history` uses same MCS at all times (BLOCKED by T-axiom requirement)
- `canonical_history_family` uses family's varying MCS (works without T-axiom)
-/
def canonical_history_family (family : IndexedMCSFamily D) :
    WorldHistory (UniversalCanonicalFrame D) where
  domain := full_domain D
  convex := full_domain_convex D
  states := canonical_history_family_states D family
  respects_task := canonical_history_family_respects D family

/-!
### Properties of Family-Based Canonical Histories
-/

/--
The MCS at time t in a family-based canonical history is the family's MCS at t.
-/
lemma canonical_history_family_mcs (family : IndexedMCSFamily D)
    (t : D) (ht : (canonical_history_family D family).domain t) :
    ((canonical_history_family D family).states t ht).mcs = family.mcs t :=
  rfl

/--
The time at any point in a family-based canonical history matches the parameter.
-/
lemma canonical_history_family_time (family : IndexedMCSFamily D)
    (t : D) (ht : (canonical_history_family D family).domain t) :
    ((canonical_history_family D family).states t ht).time = t :=
  rfl

/--
All times are in the domain of a family-based canonical history.
-/
lemma canonical_history_family_full_domain (family : IndexedMCSFamily D)
    (t : D) : (canonical_history_family D family).domain t :=
  trivial

end Bimodal.Metalogic.UnderDevelopment.RepresentationTheorem
