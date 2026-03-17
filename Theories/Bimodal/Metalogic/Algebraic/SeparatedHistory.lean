import Bimodal.Metalogic.Algebraic.SeparatedTaskFrame
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical
import Bimodal.Metalogic.Bundle.TemporalCoherence

/-!
# Separated WorldHistories: TimelineQuot -> CanonicalMCS

This module builds WorldHistories over the SeparatedCanonicalTaskFrame,
mapping TimelineQuot times to ParametricCanonicalWorldState (all MCSs).

## Key Design

The history construction uses the timelineQuotFMCS from TimelineQuotCanonical.lean,
but views the MCSs as elements of W = ParametricCanonicalWorldState (all MCSs)
rather than as elements of TimelineQuot.

This achieves the W/D separation:
- D = TimelineQuot (time domain with dense linear order)
- W = ParametricCanonicalWorldState (ALL MCSs as world states)
- h : D -> W maps each time to its MCS in the full world state space

## Main Definitions

- `separatedHistory`: WorldHistory over SeparatedCanonicalTaskFrame
- `SeparatedCanonicalOmega`: Set of world-histories from timelineQuotFMCS

## References

- Task 982: Wire dense completeness domain connection
- research-009.md: W/D separation architecture
- ParametricHistory.lean: parametric_to_history infrastructure
-/

namespace Bimodal.Metalogic.Algebraic.SeparatedHistory

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Metalogic.Algebraic.SeparatedTaskFrame
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCompleteness
open Bimodal.Metalogic.StagedConstruction.TimelineQuotCanonical
open Bimodal.Semantics

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

-- Provide the typeclass instances for TimelineQuot
attribute [local instance] timelineQuotAddCommGroup timelineQuotIsOrderedAddMonoid

/-!
## FMCS over TimelineQuot

We use the existing timelineQuotFMCS, which assigns:
- mcs(t) = timelineQuotMCS(t) for each time t in TimelineQuot
- forward_G and backward_H are proven via the linking lemmas
-/

/--
The timelineQuotFMCS viewed as an FMCS for the separated construction.
This is just a re-export for clarity.
-/
noncomputable abbrev separatedFMCS :
    FMCS (TimelineQuot root_mcs root_mcs_proof) :=
  timelineQuotFMCS root_mcs root_mcs_proof

/-!
## WorldHistory Construction

The key insight: we can convert an FMCS over TimelineQuot to a WorldHistory
over SeparatedCanonicalTaskFrame because:

1. The domain is full (every time t : TimelineQuot is in domain)
2. The states map t to (timelineQuotMCS t, is_mcs proof) as a ParametricCanonicalWorldState
3. The respects_task follows from forward_G of the FMCS (using CanonicalR)

However, we need to adapt the conversion since ParametricCanonicalTaskFrame
uses parametric_canonical_task_rel which checks sign of duration.
-/

/--
Convert separatedFMCS to a WorldHistory over SeparatedCanonicalTaskFrame.

The history has:
- domain = full (every time in TimelineQuot is in domain)
- states(t) = (timelineQuotMCS t, is_mcs proof) wrapped as ParametricCanonicalWorldState
- respects_task = from forward_G coherence via CanonicalR linkage

Note: This is morally similar to parametric_to_history but specialized to
the separated frame where we know the specific structure of timelineQuotFMCS.
-/
noncomputable def separatedHistory :
    WorldHistory (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => timelineQuotToWorldState root_mcs root_mcs_proof t
  respects_task := fun s t _ _ hst => by
    -- Need: task_rel (states s) (t - s) (states t)
    -- task_rel = parametric_canonical_task_rel
    -- For d = t - s >= 0 (since s <= t), need CanonicalR or equality
    show parametric_canonical_task_rel _ _ _
    unfold parametric_canonical_task_rel
    by_cases h_pos : t - s > 0
    · -- t - s > 0: need CanonicalR
      rw [if_pos h_pos]
      -- Use the linking lemma: s < t implies CanonicalR
      have h_lt : s < t := by
        by_contra h_nlt
        have h_le' : t ≤ s := le_of_not_lt h_nlt
        have h_eq : s = t := le_antisymm hst h_le'
        subst h_eq
        simp at h_pos
      -- timelineQuot_lt_implies_canonicalR gives us the CanonicalR
      have h_R := timelineQuot_lt_implies_canonicalR root_mcs root_mcs_proof s t h_lt
      -- Now we need to show the WorldState values have the same underlying MCS
      simp only [timelineQuotToWorldState, timelineQuotToWorldState_val]
      exact h_R
    · -- t - s <= 0, but s <= t implies t - s >= 0, so t - s = 0
      have h_eq : t - s = 0 := le_antisymm (not_lt.mp h_pos) (sub_nonneg.mpr hst)
      have h_neg : ¬(t - s < 0) := not_lt.mpr (sub_nonneg.mpr hst)
      rw [if_neg h_pos, if_neg h_neg]
      -- Need states s = states t, i.e., s = t
      have h_s_eq_t : s = t := by
        have := sub_eq_zero.mp h_eq
        exact this.symm
      subst h_s_eq_t
      rfl

/--
States of separatedHistory at time t.
-/
theorem separatedHistory_states (t : TimelineQuot root_mcs root_mcs_proof) (ht : True) :
    (separatedHistory root_mcs root_mcs_proof).states t ht =
    timelineQuotToWorldState root_mcs root_mcs_proof t := rfl

/--
The underlying MCS of the world state at time t equals timelineQuotMCS t.
-/
theorem separatedHistory_mcs_eq (t : TimelineQuot root_mcs root_mcs_proof) (ht : True) :
    ((separatedHistory root_mcs root_mcs_proof).states t ht).val =
    timelineQuotMCS root_mcs root_mcs_proof t := rfl

/-!
## Omega: Set of WorldHistories

For the truth lemma, we need a set Omega of WorldHistories.
The simplest choice is the singleton containing just separatedHistory.

However, for modal saturation (Box case of truth lemma), we may need
additional witness histories. For now, we define the canonical Omega.
-/

/--
The canonical Omega for the separated construction: singleton with separatedHistory.

Note: This is NOT shift-closed. For a shift-closed version, see below.
-/
def SeparatedCanonicalOmega :
    Set (WorldHistory (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof)) :=
  { separatedHistory root_mcs root_mcs_proof }

/--
The shift-closed Omega: all time-shifts of separatedHistory.

This set is shift-closed by construction.
-/
def ShiftClosedSeparatedOmega :
    Set (WorldHistory (SeparatedCanonicalTaskFrame root_mcs root_mcs_proof)) :=
  { σ | ∃ (delta : TimelineQuot root_mcs root_mcs_proof),
    σ = WorldHistory.time_shift (separatedHistory root_mcs root_mcs_proof) delta }

/--
separatedHistory is in ShiftClosedSeparatedOmega (take delta = 0).
-/
theorem separatedHistory_in_shiftClosed :
    separatedHistory root_mcs root_mcs_proof ∈
    ShiftClosedSeparatedOmega root_mcs root_mcs_proof := by
  use 0
  simp only [WorldHistory.time_shift, add_zero]
  rfl

/--
ShiftClosedSeparatedOmega is shift-closed.
-/
theorem shiftClosedSeparatedOmega_is_shift_closed :
    ShiftClosed (ShiftClosedSeparatedOmega root_mcs root_mcs_proof) := by
  intro σ h_mem Δ'
  obtain ⟨delta, h_eq⟩ := h_mem
  refine ⟨delta + Δ', ?_⟩
  subst h_eq
  -- Need to show: time_shift (time_shift h delta) Δ' = time_shift h (delta + Δ')
  simp only [WorldHistory.time_shift, separatedHistory]
  congr 1
  ext t ht
  simp only [Subtype.mk.injEq, Set.ext_iff, add_assoc, add_comm Δ' delta]

/--
The canonical Omega is a subset of the shift-closed Omega.
-/
theorem separatedCanonicalOmega_subset_shiftClosed :
    SeparatedCanonicalOmega root_mcs root_mcs_proof ⊆
    ShiftClosedSeparatedOmega root_mcs root_mcs_proof := by
  intro σ h_mem
  simp only [SeparatedCanonicalOmega, Set.mem_singleton_iff] at h_mem
  subst h_mem
  exact separatedHistory_in_shiftClosed root_mcs root_mcs_proof

/-!
## Summary

This module establishes:
1. `separatedHistory`: WorldHistory mapping TimelineQuot -> ParametricCanonicalWorldState
2. `SeparatedCanonicalOmega`: Singleton set with separatedHistory
3. `ShiftClosedSeparatedOmega`: Shift-closed enlargement

The next phase (Phase 4) will prove the truth lemma for this construction.

**Key property**: The world states are in W = ParametricCanonicalWorldState (ALL MCSs).
Witnesses for F(φ)/P(φ) exist in W even if they're not in TimelineQuot,
because W contains ALL MCSs, not just those arising from the staged construction.
-/

end Bimodal.Metalogic.Algebraic.SeparatedHistory
