import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Semantics.WorldHistory
import Bimodal.Semantics.Truth

/-!
# D-Parametric History Conversion

This module converts FMCS (Family of MCS) to WorldHistory for the D-parametric
canonical TaskFrame construction.

## Key Results

- `parametric_to_history`: Convert FMCS to WorldHistory over ParametricCanonicalTaskFrame
- `ParametricCanonicalOmega`: Set of world-histories from bundle families
- `ShiftClosedParametricCanonicalOmega`: Shift-closed enlargement of CanonicalOmega
- `shiftClosedParametricCanonicalOmega_is_shift_closed`: Proof of shift-closure

## Design

The conversion uses:
- domain: full (every time is in the domain) since FMCS assigns MCS to every time
- states: the MCS at time t IS the world-state (wrapped as ParametricCanonicalWorldState)
- respects_task: proved using forward_G from FMCS structure (for positive durations)

Since domain = True for all times, we sidestep domain-related complexity.

## References

- Existing: Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean (to_history)
- Research: specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md
-/

namespace Bimodal.Metalogic.Algebraic.ParametricHistory

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Semantics

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-!
## FMCS to WorldHistory Conversion
-/

/--
Convert an FMCS to a WorldHistory in the parametric canonical TaskFrame.

- domain: full (every time is in the domain)
- states: the MCS at time t IS the world-state
- respects_task: proved using forward_G from the FMCS structure

Key property: domain = True eliminates all domain-related complexity.

**respects_task proof**: For s <= t, the duration d = t - s >= 0.
- If d > 0 (i.e., s < t): need CanonicalR (mcs s) (mcs t), which follows from forward_G.
- If d = 0 (i.e., s = t): need states s = states t, which holds since s = t.
- d < 0 is impossible since s <= t implies t - s >= 0.
-/
def parametric_to_history (fam : FMCS D) : WorldHistory (ParametricCanonicalTaskFrame D) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := fun s t _ _ hst => by
    -- Need: parametric_canonical_task_rel <mcs s> (t - s) <mcs t>
    show parametric_canonical_task_rel _ _ _
    unfold parametric_canonical_task_rel
    by_cases h_pos : t - s > 0
    · -- t - s > 0: need CanonicalR (fam.mcs s) (fam.mcs t)
      rw [if_pos h_pos]
      intro phi h_G_phi
      -- t - s > 0 and s <= t, so s < t
      have h_lt : s < t := by
        by_contra h_nlt
        have h_le : t ≤ s := le_of_not_lt h_nlt
        have h_eq : s = t := le_antisymm hst h_le
        subst h_eq
        simp at h_pos
      exact fam.forward_G s t phi h_lt h_G_phi
    · -- t - s <= 0, but s <= t means t - s >= 0, so t - s = 0
      have h_eq : t - s = 0 := le_antisymm (not_lt.mp h_pos) (sub_nonneg.mpr hst)
      have h_neg : ¬(t - s < 0) := not_lt.mpr (sub_nonneg.mpr hst)
      rw [if_neg h_pos, if_neg h_neg]
      have h_s_eq_t : s = t := by
        have : t = s := sub_eq_zero.mp h_eq
        exact this.symm
      subst h_s_eq_t
      rfl

/--
States of parametric_to_history at time t.
-/
theorem parametric_to_history_states (fam : FMCS D) (t : D) (ht : True) :
    (parametric_to_history fam).states t ht = ⟨fam.mcs t, fam.is_mcs t⟩ := rfl

/-!
## Canonical Omega
-/

/--
The parametric canonical Omega: the set of world-histories from bundle families.

ParametricCanonicalOmega B = { tau | exists fam in B.families, tau = parametric_to_history fam }

This set is NOT necessarily ShiftClosed. ShiftClosed is not needed for
the TruthLemma (only for the connection to standard validity).
-/
def ParametricCanonicalOmega (B : BFMCS D) : Set (WorldHistory (ParametricCanonicalTaskFrame D)) :=
  { tau | ∃ fam ∈ B.families, tau = parametric_to_history fam }

/-!
## Shift-Closed Canonical Omega
-/

/-- The shift-closed parametric canonical Omega: all time-shifts of canonical histories.

This is the enlargement of ParametricCanonicalOmega that includes all time-shifts.
For any family fam and any time offset delta, the shifted history
`WorldHistory.time_shift (parametric_to_history fam) delta` is in this set.
-/
def ShiftClosedParametricCanonicalOmega (B : BFMCS D) :
    Set (WorldHistory (ParametricCanonicalTaskFrame D)) :=
  { σ | ∃ (fam : FMCS D) (_ : fam ∈ B.families) (delta : D),
    σ = WorldHistory.time_shift (parametric_to_history fam) delta }

/-- Time-shift of parametric canonical histories composes: shifting by delta then delta'
equals shifting by delta + delta'.

This is the key lemma for proving shift-closure. -/
private theorem time_shift_parametric_to_history_compose
    (fam : FMCS D)
    (delta delta' : D) :
    WorldHistory.time_shift (WorldHistory.time_shift (parametric_to_history fam) delta) delta' =
    WorldHistory.time_shift (parametric_to_history fam) (delta + delta') := by
  have h_time_eq : ∀ t : D, t + delta' + delta = t + (delta + delta') := fun t => by
    rw [add_assoc, add_comm delta' delta]
  simp only [WorldHistory.time_shift, parametric_to_history]
  congr 1
  ext t ht
  simp only [Subtype.mk.injEq, Set.ext_iff]
  rw [h_time_eq t]

/-- A parametric canonical history equals its time-shift by 0. -/
private theorem parametric_to_history_eq_time_shift_zero (fam : FMCS D) :
    parametric_to_history fam = WorldHistory.time_shift (parametric_to_history fam) 0 := by
  simp only [WorldHistory.time_shift, parametric_to_history, add_zero]

/-- ShiftClosedParametricCanonicalOmega is shift-closed. -/
theorem shiftClosedParametricCanonicalOmega_is_shift_closed (B : BFMCS D) :
    ShiftClosed (ShiftClosedParametricCanonicalOmega B) := by
  intro σ h_mem Δ'
  obtain ⟨fam, hfam, delta, h_eq⟩ := h_mem
  refine ⟨fam, hfam, delta + Δ', ?_⟩
  subst h_eq
  exact time_shift_parametric_to_history_compose fam delta Δ'

/-- Every parametric canonical history is in the shift-closed parametric canonical Omega
(take delta = 0). -/
theorem parametricCanonicalOmega_subset_shiftClosed (B : BFMCS D) :
    ParametricCanonicalOmega B ⊆ ShiftClosedParametricCanonicalOmega B := by
  intro σ h_mem
  obtain ⟨fam, hfam, h_eq⟩ := h_mem
  refine ⟨fam, hfam, 0, ?_⟩
  subst h_eq
  exact parametric_to_history_eq_time_shift_zero fam

/-!
## Helper Lemmas for Truth Lemma
-/

/-- Domain of parametric_to_history is full. -/
theorem parametric_to_history_domain_full (fam : FMCS D) (t : D) :
    (parametric_to_history fam).domain t := True.intro

/-- The underlying MCS of the world state at time t equals fam.mcs t. -/
theorem parametric_to_history_mcs_eq (fam : FMCS D) (t : D) (ht : True) :
    ((parametric_to_history fam).states t ht).val = fam.mcs t := rfl

end Bimodal.Metalogic.Algebraic.ParametricHistory
