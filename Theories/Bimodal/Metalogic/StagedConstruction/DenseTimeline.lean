import Bimodal.Metalogic.StagedConstruction.CantorPrereqs
import Bimodal.Metalogic.StagedConstruction.DensityFrameCondition

/-!
# Dense Staged Timeline

This module extends the staged timeline with density-frame-condition witnesses
to produce a countable dense linear order without endpoints.

## Overview

The base staged timeline (from StagedExecution.lean) has all Cantor prerequisites
EXCEPT density. This module defines a "density-enriched" build that adds
density_frame_condition intermediates for all strictly ordered pairs at each stage.

## Key Theorems

- `dense_timeline_has_intermediate`: the enriched timeline has CanonicalR-intermediates
- `dense_timeline_countable`, `dense_timeline_nonempty`, etc.: other Cantor prereqs
- `dense_timeline_has_future`, `dense_timeline_has_past`: no endpoints

## References

- Task 956, plan v015: Phase 5
- DensityFrameCondition.lean: `density_frame_condition` theorem
- CantorPrereqs.lean: other Cantor prerequisites for the base timeline
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
## Density Intermediate Construction
-/

/-- Extract the intermediate MCS from density_frame_condition.
    When the source a.mcs is reflexive, uses the strict variant that guarantees
    ¬CanonicalR(b.mcs, W), ensuring the intermediate is not equivalent to the target. -/
noncomputable def densityIntermediateMCS
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs) : Set Formula :=
  if h_refl : CanonicalR a.mcs a.mcs then
    (density_frame_condition_reflexive_source a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R h_refl).choose
  else
    (density_frame_condition a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R).choose

theorem densityIntermediateMCS_spec
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs) :
    SetMaximalConsistent (densityIntermediateMCS a b h_R h_not_R) ∧
    CanonicalR a.mcs (densityIntermediateMCS a b h_R h_not_R) ∧
    CanonicalR (densityIntermediateMCS a b h_R h_not_R) b.mcs := by
  simp only [densityIntermediateMCS]
  split
  · -- Reflexive case: use density_frame_condition_reflexive_source
    rename_i h_refl
    have spec := (density_frame_condition_reflexive_source a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R h_refl).choose_spec
    exact ⟨spec.1, spec.2.1, spec.2.2.1⟩
  · -- Non-reflexive case: use density_frame_condition
    exact (density_frame_condition a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R).choose_spec

/-- When the source is reflexive, the density intermediate is strict from the target:
    ¬CanonicalR(b.mcs, intermediate). This guarantees the intermediate is not
    equivalent to b in the quotient. -/
theorem densityIntermediateMCS_strict_from_target
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs)
    (h_refl : CanonicalR a.mcs a.mcs) :
    ¬CanonicalR b.mcs (densityIntermediateMCS a b h_R h_not_R) := by
  simp only [densityIntermediateMCS, dif_pos h_refl]
  exact (density_frame_condition_reflexive_source a.mcs b.mcs a.is_mcs b.is_mcs h_R h_not_R h_refl).choose_spec.2.2.2

/-- Create a StagedPoint from a density intermediate. -/
noncomputable def densityIntermediatePoint
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs)
    (stage : Stage) : StagedPoint where
  mcs := densityIntermediateMCS a b h_R h_not_R
  is_mcs := (densityIntermediateMCS_spec a b h_R h_not_R).1
  introduced_at := stage

theorem densityIntermediatePoint_canonicalR_left
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs)
    (stage : Stage) :
    CanonicalR a.mcs (densityIntermediatePoint a b h_R h_not_R stage).mcs :=
  (densityIntermediateMCS_spec a b h_R h_not_R).2.1

theorem densityIntermediatePoint_canonicalR_right
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs)
    (stage : Stage) :
    CanonicalR (densityIntermediatePoint a b h_R h_not_R stage).mcs b.mcs :=
  (densityIntermediateMCS_spec a b h_R h_not_R).2.2

/-- When the source is reflexive, the density intermediate point is strict from target b:
    ¬CanonicalR(b.mcs, c.mcs) where c is the intermediate. -/
theorem densityIntermediatePoint_strict_from_target
    (a b : StagedPoint)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs)
    (stage : Stage)
    (h_refl : CanonicalR a.mcs a.mcs) :
    ¬CanonicalR b.mcs (densityIntermediatePoint a b h_R h_not_R stage).mcs :=
  densityIntermediateMCS_strict_from_target a b h_R h_not_R h_refl

/-!
## Dense Stage Construction
-/

/-- Collect density intermediates for all strictly ordered pairs in a Finset. -/
noncomputable def densityWitnessesForSet
    (S : Finset StagedPoint) (stage : Stage) : Finset StagedPoint :=
  S.biUnion fun a =>
    S.biUnion fun b =>
      if h : CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs then
        {densityIntermediatePoint a b h.1 h.2 stage}
      else ∅

/-- The dense staged build. -/
noncomputable def denseStage : Nat → Finset StagedPoint
  | 0 =>
    let base := stagedBuild root_mcs root_mcs_proof 0
    base ∪ densityWitnessesForSet base 0
  | n + 1 =>
    let base := stagedBuild root_mcs root_mcs_proof (n + 1)
    let prev := denseStage n
    let combined := base ∪ prev
    combined ∪ densityWitnessesForSet combined (n + 1)

theorem stagedBuild_subset_denseStage (n : Nat) :
    stagedBuild root_mcs root_mcs_proof n ⊆ denseStage root_mcs root_mcs_proof n := by
  cases n with
  | zero => exact Finset.subset_union_left
  | succ n => exact Finset.Subset.trans Finset.subset_union_left Finset.subset_union_left

theorem denseStage_monotone (n : Nat) :
    denseStage root_mcs root_mcs_proof n ⊆
    denseStage root_mcs root_mcs_proof (n + 1) := by
  intro p hp
  show p ∈ denseStage root_mcs root_mcs_proof (n + 1)
  simp only [denseStage]
  rw [Finset.mem_union]
  left
  rw [Finset.mem_union]
  right
  exact hp

theorem denseStage_monotone_forward (n k : Nat) :
    denseStage root_mcs root_mcs_proof n ⊆ denseStage root_mcs root_mcs_proof (n + k) := by
  induction k with
  | zero => exact fun _ hp => hp
  | succ k ih =>
    intro p hp
    exact denseStage_monotone root_mcs root_mcs_proof (n + k) (ih hp)

theorem denseStage_monotone_le {n m : Nat} (h : n ≤ m) :
    denseStage root_mcs root_mcs_proof n ⊆ denseStage root_mcs root_mcs_proof m := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  exact denseStage_monotone_forward root_mcs root_mcs_proof n k

def denseTimelineUnion : Set StagedPoint :=
  { p | ∃ n : Nat, p ∈ denseStage root_mcs root_mcs_proof n }

theorem base_union_subset_dense :
    (buildStagedTimeline root_mcs root_mcs_proof).union ⊆
    denseTimelineUnion root_mcs root_mcs_proof := by
  intro p hp
  obtain ⟨n, hn⟩ := hp
  exact ⟨n, stagedBuild_subset_denseStage root_mcs root_mcs_proof n hn⟩

/-!
## Linearity of Dense Timeline
-/

theorem denseStage_all_comparable_with_root (n : Nat)
    (p : StagedPoint) (hp : p ∈ denseStage root_mcs root_mcs_proof n) :
    CanonicalR (rootPoint root_mcs root_mcs_proof).mcs p.mcs ∨
    CanonicalR p.mcs (rootPoint root_mcs root_mcs_proof).mcs ∨
    (rootPoint root_mcs root_mcs_proof).mcs = p.mcs := by
  induction n generalizing p with
  | zero =>
    simp only [denseStage] at hp
    rw [Finset.mem_union] at hp
    rcases hp with h_base | h_density
    · exact stagedBuild_all_comparable_with_root root_mcs root_mcs_proof 0 p h_base
    · simp only [densityWitnessesForSet] at h_density
      rw [Finset.mem_biUnion] at h_density
      obtain ⟨a, ha_mem, h_rest⟩ := h_density
      rw [Finset.mem_biUnion] at h_rest
      obtain ⟨b, _, h_dite⟩ := h_rest
      split at h_dite
      · rename_i h_cond
        rw [Finset.mem_singleton] at h_dite
        rw [h_dite]
        have h_R_ap := densityIntermediatePoint_canonicalR_left a b h_cond.1 h_cond.2 0
        have h_root_a := stagedBuild_all_comparable_with_root root_mcs root_mcs_proof 0 a ha_mem
        exact comparability_step_forward
          (rootPoint root_mcs root_mcs_proof).mcs a.mcs
          (densityIntermediatePoint a b h_cond.1 h_cond.2 0).mcs
          root_mcs_proof a.is_mcs
          (densityIntermediatePoint a b h_cond.1 h_cond.2 0).is_mcs
          h_root_a h_R_ap
      · simp at h_dite
  | succ n ih =>
    simp only [denseStage] at hp
    rw [Finset.mem_union] at hp
    rcases hp with h_combined | h_density
    · rw [Finset.mem_union] at h_combined
      rcases h_combined with h_base | h_prev
      · exact stagedBuild_all_comparable_with_root root_mcs root_mcs_proof (n + 1) p h_base
      · exact ih p h_prev
    · simp only [densityWitnessesForSet] at h_density
      rw [Finset.mem_biUnion] at h_density
      obtain ⟨a, ha_mem, h_rest⟩ := h_density
      rw [Finset.mem_biUnion] at h_rest
      obtain ⟨b, _, h_dite⟩ := h_rest
      split at h_dite
      · rename_i h_cond
        rw [Finset.mem_singleton] at h_dite
        rw [h_dite]
        have h_R_ap := densityIntermediatePoint_canonicalR_left a b h_cond.1 h_cond.2 (n + 1)
        rw [Finset.mem_union] at ha_mem
        have h_root_a : CanonicalR (rootPoint root_mcs root_mcs_proof).mcs a.mcs ∨
            CanonicalR a.mcs (rootPoint root_mcs root_mcs_proof).mcs ∨
            (rootPoint root_mcs root_mcs_proof).mcs = a.mcs := by
          rcases ha_mem with h_base | h_prev
          · exact stagedBuild_all_comparable_with_root root_mcs root_mcs_proof (n + 1) a h_base
          · exact ih a h_prev
        exact comparability_step_forward
          (rootPoint root_mcs root_mcs_proof).mcs a.mcs
          (densityIntermediatePoint a b h_cond.1 h_cond.2 (n + 1)).mcs
          root_mcs_proof a.is_mcs
          (densityIntermediatePoint a b h_cond.1 h_cond.2 (n + 1)).is_mcs
          h_root_a h_R_ap
      · simp at h_dite

theorem denseStage_mcs_comparable (n : Nat)
    (a b : StagedPoint) (ha : a ∈ denseStage root_mcs root_mcs_proof n)
    (hb : b ∈ denseStage root_mcs root_mcs_proof n) :
    CanonicalR a.mcs b.mcs ∨ CanonicalR b.mcs a.mcs ∨ a.mcs = b.mcs := by
  have h_root_a := denseStage_all_comparable_with_root root_mcs root_mcs_proof n a ha
  have h_root_b := denseStage_all_comparable_with_root root_mcs root_mcs_proof n b hb
  rcases h_root_a with h_Ra | h_aR | h_eq_a
  · -- CanonicalR(root, a)
    rcases h_root_b with h_Rb | h_bR | h_eq_b
    · exact canonical_forward_reachable_linear root_mcs a.mcs b.mcs root_mcs_proof a.is_mcs b.is_mcs h_Ra h_Rb
    · exact comparability_step_backward a.mcs root_mcs b.mcs a.is_mcs root_mcs_proof b.is_mcs
        (Or.inr (Or.inl h_Ra)) h_bR
    · -- root.mcs = b.mcs: CanonicalR(root, a) = CanonicalR(b, a) after transport
      exact Or.inr (Or.inl (h_eq_b ▸ h_Ra))
  · -- CanonicalR(a, root)
    rcases h_root_b with h_Rb | h_bR | h_eq_b
    · exact comparability_step_forward a.mcs root_mcs b.mcs a.is_mcs root_mcs_proof b.is_mcs
        (Or.inl h_aR) h_Rb
    · exact canonical_backward_reachable_linear root_mcs a.mcs b.mcs root_mcs_proof a.is_mcs b.is_mcs h_aR h_bR
    · -- root.mcs = b.mcs: CanonicalR(a, root) = CanonicalR(a, b) after transport
      exact Or.inl (h_eq_b ▸ h_aR)
  · -- root.mcs = a.mcs
    rcases h_root_b with h_Rb | h_bR | h_eq_b
    · exact Or.inl (h_eq_a ▸ h_Rb)
    · exact Or.inr (Or.inl (h_eq_a ▸ h_bR))
    · exact Or.inr (Or.inr (h_eq_a.symm.trans h_eq_b))

theorem denseStage_linear (n : Nat) :
    IsLinearlyOrdered (denseStage root_mcs root_mcs_proof n) := by
  intro a ha b hb
  exact stagedPoint_le_of_mcs_comparable a b
    (denseStage_mcs_comparable root_mcs root_mcs_proof n a b ha hb)

theorem denseTimeline_mcs_comparable
    (a b : StagedPoint)
    (ha : a ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (hb : b ∈ denseTimelineUnion root_mcs root_mcs_proof) :
    CanonicalR a.mcs b.mcs ∨ CanonicalR b.mcs a.mcs ∨ a.mcs = b.mcs := by
  obtain ⟨n, hn⟩ := ha
  obtain ⟨m, hm⟩ := hb
  exact denseStage_mcs_comparable root_mcs root_mcs_proof (max n m) a b
    (denseStage_monotone_le root_mcs root_mcs_proof (Nat.le_max_left n m) hn)
    (denseStage_monotone_le root_mcs root_mcs_proof (Nat.le_max_right n m) hm)

/-- The dense timeline union is linearly ordered: any two points are comparable under ≤. -/
theorem denseTimeline_linearly_ordered
    (a b : StagedPoint)
    (ha : a ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (hb : b ∈ denseTimelineUnion root_mcs root_mcs_proof) :
    StagedPoint.le a b ∨ StagedPoint.le b a :=
  stagedPoint_le_of_mcs_comparable a b
    (denseTimeline_mcs_comparable root_mcs root_mcs_proof a b ha hb)

/-!
## Density (Intermediate existence)
-/

theorem dense_timeline_has_intermediate
    (a b : StagedPoint)
    (ha : a ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (hb : b ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs) :
    ∃ c : StagedPoint, c ∈ denseTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR a.mcs c.mcs ∧ CanonicalR c.mcs b.mcs := by
  obtain ⟨n, hn⟩ := ha
  obtain ⟨m, hm⟩ := hb
  set N := max n m
  have ha_N := denseStage_monotone_le root_mcs root_mcs_proof (Nat.le_max_left n m) hn
  have hb_N := denseStage_monotone_le root_mcs root_mcs_proof (Nat.le_max_right n m) hm
  let c := densityIntermediatePoint a b h_R h_not_R (N + 1)
  refine ⟨c, ⟨N + 1, ?_⟩, ?_, ?_⟩
  · show c ∈ denseStage root_mcs root_mcs_proof (N + 1)
    simp only [denseStage]
    rw [Finset.mem_union]
    right
    simp only [densityWitnessesForSet]
    rw [Finset.mem_biUnion]
    have ha_combined : a ∈ stagedBuild root_mcs root_mcs_proof (N + 1) ∪
        denseStage root_mcs root_mcs_proof N :=
      Finset.mem_union.mpr (Or.inr ha_N)
    have hb_combined : b ∈ stagedBuild root_mcs root_mcs_proof (N + 1) ∪
        denseStage root_mcs root_mcs_proof N :=
      Finset.mem_union.mpr (Or.inr hb_N)
    exact ⟨a, ha_combined, Finset.mem_biUnion.mpr ⟨b, hb_combined,
      by simp only [c]; rw [dif_pos ⟨h_R, h_not_R⟩]; exact Finset.mem_singleton.mpr rfl⟩⟩
  · exact densityIntermediatePoint_canonicalR_left a b h_R h_not_R (N + 1)
  · exact densityIntermediatePoint_canonicalR_right a b h_R h_not_R (N + 1)

/-- When the source is reflexive, the intermediate from dense_timeline_has_intermediate
    is strict from the target: ¬CanonicalR(b.mcs, c.mcs). This is the key property
    for proving DenselyOrdered at the quotient level. -/
theorem dense_timeline_has_strict_intermediate
    (a b : StagedPoint)
    (ha : a ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (hb : b ∈ denseTimelineUnion root_mcs root_mcs_proof)
    (h_R : CanonicalR a.mcs b.mcs)
    (h_not_R : ¬CanonicalR b.mcs a.mcs)
    (h_refl : CanonicalR a.mcs a.mcs) :
    ∃ c : StagedPoint, c ∈ denseTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR a.mcs c.mcs ∧ CanonicalR c.mcs b.mcs ∧ ¬CanonicalR b.mcs c.mcs := by
  obtain ⟨n, hn⟩ := ha
  obtain ⟨m, hm⟩ := hb
  set N := max n m
  have ha_N := denseStage_monotone_le root_mcs root_mcs_proof (Nat.le_max_left n m) hn
  have hb_N := denseStage_monotone_le root_mcs root_mcs_proof (Nat.le_max_right n m) hm
  let c := densityIntermediatePoint a b h_R h_not_R (N + 1)
  refine ⟨c, ⟨N + 1, ?_⟩, ?_, ?_, ?_⟩
  · show c ∈ denseStage root_mcs root_mcs_proof (N + 1)
    simp only [denseStage]
    rw [Finset.mem_union]
    right
    simp only [densityWitnessesForSet]
    rw [Finset.mem_biUnion]
    have ha_combined : a ∈ stagedBuild root_mcs root_mcs_proof (N + 1) ∪
        denseStage root_mcs root_mcs_proof N :=
      Finset.mem_union.mpr (Or.inr ha_N)
    have hb_combined : b ∈ stagedBuild root_mcs root_mcs_proof (N + 1) ∪
        denseStage root_mcs root_mcs_proof N :=
      Finset.mem_union.mpr (Or.inr hb_N)
    exact ⟨a, ha_combined, Finset.mem_biUnion.mpr ⟨b, hb_combined,
      by simp only [c]; rw [dif_pos ⟨h_R, h_not_R⟩]; exact Finset.mem_singleton.mpr rfl⟩⟩
  · exact densityIntermediatePoint_canonicalR_left a b h_R h_not_R (N + 1)
  · exact densityIntermediatePoint_canonicalR_right a b h_R h_not_R (N + 1)
  · exact densityIntermediatePoint_strict_from_target a b h_R h_not_R (N + 1) h_refl

/-!
## Origin tracking for dense timeline points

Every point in the dense timeline is either from the base timeline or is a
density intermediate. For density intermediates, we know CanonicalR relationships
with the source points. This tracking enables the NoMaxOrder/NoMinOrder proofs.
-/

/-- Every point in the dense timeline either comes from the base timeline
    or has a known CanonicalR-future in the dense timeline (the "right endpoint"
    of the density pair that created it). -/
theorem dense_point_has_future_witness (n : Nat)
    (p : StagedPoint) (hp : p ∈ denseStage root_mcs root_mcs_proof n) :
    (∃ m, p ∈ stagedBuild root_mcs root_mcs_proof m) ∨
    (∃ q : StagedPoint, q ∈ denseTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR p.mcs q.mcs) := by
  induction n generalizing p with
  | zero =>
    simp only [denseStage] at hp
    rw [Finset.mem_union] at hp
    rcases hp with h_base | h_density
    · exact Or.inl ⟨0, h_base⟩
    · simp only [densityWitnessesForSet] at h_density
      rw [Finset.mem_biUnion] at h_density
      obtain ⟨a, _, h_rest⟩ := h_density
      rw [Finset.mem_biUnion] at h_rest
      obtain ⟨b, hb_mem, h_dite⟩ := h_rest
      split at h_dite
      · rename_i h_cond
        rw [Finset.mem_singleton] at h_dite
        subst h_dite
        -- p = densityIntermediatePoint a b ..., CanonicalR(p.mcs, b.mcs)
        exact Or.inr ⟨b, ⟨0, stagedBuild_subset_denseStage root_mcs root_mcs_proof 0 hb_mem⟩,
          densityIntermediatePoint_canonicalR_right a b h_cond.1 h_cond.2 0⟩
      · simp at h_dite
  | succ n ih =>
    simp only [denseStage] at hp
    rw [Finset.mem_union] at hp
    rcases hp with h_combined | h_density
    · rw [Finset.mem_union] at h_combined
      rcases h_combined with h_base | h_prev
      · exact Or.inl ⟨n + 1, h_base⟩
      · exact ih p h_prev
    · simp only [densityWitnessesForSet] at h_density
      rw [Finset.mem_biUnion] at h_density
      obtain ⟨a, _, h_rest⟩ := h_density
      rw [Finset.mem_biUnion] at h_rest
      obtain ⟨b, hb_mem, h_dite⟩ := h_rest
      split at h_dite
      · rename_i h_cond
        rw [Finset.mem_singleton] at h_dite
        subst h_dite
        -- b is in the combined set = stagedBuild(n+1) ∪ denseStage(n)
        rw [Finset.mem_union] at hb_mem
        have hb_dense : b ∈ denseTimelineUnion root_mcs root_mcs_proof := by
          rcases hb_mem with h_base | h_prev
          · exact ⟨n + 1, stagedBuild_subset_denseStage root_mcs root_mcs_proof (n + 1) h_base⟩
          · exact ⟨n, h_prev⟩
        exact Or.inr ⟨b, hb_dense,
          densityIntermediatePoint_canonicalR_right a b h_cond.1 h_cond.2 (n + 1)⟩
      · simp at h_dite

/-- Symmetric: every density point also has a CanonicalR-predecessor. -/
theorem dense_point_has_past_witness (n : Nat)
    (p : StagedPoint) (hp : p ∈ denseStage root_mcs root_mcs_proof n) :
    (∃ m, p ∈ stagedBuild root_mcs root_mcs_proof m) ∨
    (∃ q : StagedPoint, q ∈ denseTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR q.mcs p.mcs) := by
  induction n generalizing p with
  | zero =>
    simp only [denseStage] at hp
    rw [Finset.mem_union] at hp
    rcases hp with h_base | h_density
    · exact Or.inl ⟨0, h_base⟩
    · simp only [densityWitnessesForSet] at h_density
      rw [Finset.mem_biUnion] at h_density
      obtain ⟨a, ha_mem, h_rest⟩ := h_density
      rw [Finset.mem_biUnion] at h_rest
      obtain ⟨b, _, h_dite⟩ := h_rest
      split at h_dite
      · rename_i h_cond
        rw [Finset.mem_singleton] at h_dite
        subst h_dite
        exact Or.inr ⟨a, ⟨0, stagedBuild_subset_denseStage root_mcs root_mcs_proof 0 ha_mem⟩,
          densityIntermediatePoint_canonicalR_left a b h_cond.1 h_cond.2 0⟩
      · simp at h_dite
  | succ n ih =>
    simp only [denseStage] at hp
    rw [Finset.mem_union] at hp
    rcases hp with h_combined | h_density
    · rw [Finset.mem_union] at h_combined
      rcases h_combined with h_base | h_prev
      · exact Or.inl ⟨n + 1, h_base⟩
      · exact ih p h_prev
    · simp only [densityWitnessesForSet] at h_density
      rw [Finset.mem_biUnion] at h_density
      obtain ⟨a, ha_mem, h_rest⟩ := h_density
      rw [Finset.mem_biUnion] at h_rest
      obtain ⟨b, _, h_dite⟩ := h_rest
      split at h_dite
      · rename_i h_cond
        rw [Finset.mem_singleton] at h_dite
        subst h_dite
        rw [Finset.mem_union] at ha_mem
        have ha_dense : a ∈ denseTimelineUnion root_mcs root_mcs_proof := by
          rcases ha_mem with h_base | h_prev
          · exact ⟨n + 1, stagedBuild_subset_denseStage root_mcs root_mcs_proof (n + 1) h_base⟩
          · exact ⟨n, h_prev⟩
        exact Or.inr ⟨a, ha_dense,
          densityIntermediatePoint_canonicalR_left a b h_cond.1 h_cond.2 (n + 1)⟩
      · simp at h_dite

/-!
## NoMaxOrder, NoMinOrder, Nonemptiness
-/

theorem dense_timeline_nonempty :
    Set.Nonempty (denseTimelineUnion root_mcs root_mcs_proof) :=
  Set.Nonempty.mono (base_union_subset_dense root_mcs root_mcs_proof)
    (staged_timeline_nonempty root_mcs root_mcs_proof)

theorem dense_timeline_has_future
    (p : StagedPoint) (hp : p ∈ denseTimelineUnion root_mcs root_mcs_proof) :
    ∃ q : StagedPoint, q ∈ denseTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR p.mcs q.mcs := by
  obtain ⟨n, hn⟩ := hp
  rcases dense_point_has_future_witness root_mcs root_mcs_proof n p hn with ⟨m, hm⟩ | ⟨q, hq⟩
  · -- p is a base point: use staged_timeline_has_future
    obtain ⟨q, hq_base, hq_R⟩ := staged_timeline_has_future root_mcs root_mcs_proof p ⟨m, hm⟩
    exact ⟨q, base_union_subset_dense root_mcs root_mcs_proof hq_base, hq_R⟩
  · -- p is a density point with known future q
    exact ⟨q, hq.1, hq.2⟩

theorem dense_timeline_has_past
    (p : StagedPoint) (hp : p ∈ denseTimelineUnion root_mcs root_mcs_proof) :
    ∃ q : StagedPoint, q ∈ denseTimelineUnion root_mcs root_mcs_proof ∧
      CanonicalR q.mcs p.mcs := by
  obtain ⟨n, hn⟩ := hp
  rcases dense_point_has_past_witness root_mcs root_mcs_proof n p hn with ⟨m, hm⟩ | ⟨q, hq⟩
  · -- p is a base point: use staged_timeline_has_past
    obtain ⟨q, hq_base, hq_R⟩ := staged_timeline_has_past root_mcs root_mcs_proof p ⟨m, hm⟩
    exact ⟨q, base_union_subset_dense root_mcs root_mcs_proof hq_base, hq_R⟩
  · -- p is a density point with known predecessor q
    exact ⟨q, hq.1, hq.2⟩

/-!
## Countability
-/

theorem dense_timeline_countable :
    Set.Countable (denseTimelineUnion root_mcs root_mcs_proof) := by
  apply Set.Countable.mono (s₂ := ⋃ n : Nat, ↑(denseStage root_mcs root_mcs_proof n))
  · intro p hp
    obtain ⟨n, hn⟩ := hp
    exact Set.mem_iUnion.mpr ⟨n, hn⟩
  · exact Set.countable_iUnion (fun n => Set.Finite.countable (Finset.finite_toSet _))

/-!
## Investigation: Density Intermediate Escapes Source Class (Task 961)

**Status: BLOCKED - Mathematical obstruction identified**

**Investigation Result:**
The `density_escapes_source_class` lemma CANNOT be proven from the current
density_frame_condition construction.

**Mathematical Analysis:**
The intermediate c is constructed via density_frame_condition_reflexive_source,
which uses the Lindenbaum extension of {neg delta} ∪ GContent(W₁).

The key issue: Lindenbaum extension is NON-CONSTRUCTIVE. It uses the axiom of
choice to pick formulas to add, maintaining consistency. We CANNOT control which
G-formulas end up in the final MCS c.

**Counterexample structure:**
- M (source) is reflexive with GContent(M) = {alpha, beta, ...}
- delta is the distinguishing formula: G(delta) ∈ M', delta ∉ M
- Since M is reflexive, G(delta) ∉ M (otherwise delta ∈ M)
- So F(neg delta) ∈ M, and we construct c with neg delta ∈ c

However, the Lindenbaum extension of {neg delta} ∪ GContent(W₁) may produce c
such that GContent(c) ⊆ M. This happens when:
- c inherits only G-formulas from GContent(M) (via transitivity through W₁)
- No new G-formulas with content NOT in M are added by Lindenbaum

In such cases: c ~ M (c is equivalent to source), defeating the escape property.

**Conclusion:**
The "density_escapes_source_class" property is NOT a consequence of the
density_frame_condition construction. The iteration CAN produce intermediates
that remain equivalent to the source, with no guarantee of termination.

This is the FUNDAMENTAL TERMINATION GAP identified in research-007.

**Resolution requires either:**
1. A stronger construction that tracks formula consumption
2. Well-founded induction on a different measure
3. Acceptance of an axiom for termination

See: specs/961_quotient_density_iteration_no_max_min_dense/plans/implementation-007.md
-/

end Bimodal.Metalogic.StagedConstruction
