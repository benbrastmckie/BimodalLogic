import Bimodal.Metalogic.StagedConstruction.Dovetailing
import Bimodal.Metalogic.StagedConstruction.DenseTimeline

/-!
# Dovetailed Staged Build for Dense Completeness

This module implements the dovetailed staged construction that processes
(point_index, formula_encoding) pairs using Cantor pairing enumeration.

## Overview

The standard staged construction (StagedExecution.lean) processes formulas in
order of their encoding: formula k is processed at stage 2k+1. This creates a
gap: points entering at stage m > 2k+1 miss having their F(phi_k) obligations
processed.

The dovetailed construction fixes this by processing (point, formula) pairs
via Cantor unpairing. At step n, we process obligation unpair(n) = (p, f),
ensuring every (point, formula) pair is eventually processed.

## Key Definitions

- `DovetailedPoint`: StagedPoint with explicit point_index
- `dovetailedBuild`: The dovetailed construction function
- `dovetailedTimelineUnion`: Union of all dovetailed stages

## Key Theorems

- `dovetailedBuild_monotone`: Each stage contains previous stages
- `dovetailedBuild_linear`: Each stage is linearly ordered
- `dovetailedTimeline_countable`: The union is countable
- `dovetailedTimeline_has_future/past`: No endpoints

## References

- Task 982: Full dovetailing for dense completeness
- Dovetailing.lean: Cantor pairing infrastructure
- StagedExecution.lean: Original staged construction
- Henkin 1949: Dovetailing enumeration technique
-/

namespace Bimodal.Metalogic.StagedConstruction.DovetailedBuild

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem
open Bimodal.Metalogic.StagedConstruction
open Bimodal.Metalogic.StagedConstruction.Dovetailing

-- Classical decidability
attribute [local instance] Classical.propDecidable

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Dovetailed Point Type

A DovetailedPoint extends StagedPoint with an explicit point index.
The point_index is assigned upon entry and used for dovetailing lookup.
-/

/-- A point in the dovetailed construction with its entry stage and point index.
    The point_index is assigned sequentially as points enter the construction.
    It is used for Cantor pairing: obligation (p, f) processes point_index p
    with formula encoding f. -/
structure DovetailedPoint where
  /-- The underlying MCS. -/
  mcs : Set Formula
  /-- Proof that the set is maximal consistent. -/
  is_mcs : SetMaximalConsistent mcs
  /-- The stage at which this point was introduced. -/
  entry_stage : Stage
  /-- The unique index assigned to this point upon entry. -/
  point_index : Nat

/-- Convert a StagedPoint to DovetailedPoint with given index. -/
noncomputable def ofStagedPoint (sp : StagedPoint) (idx : Nat) : DovetailedPoint where
  mcs := sp.mcs
  is_mcs := sp.is_mcs
  entry_stage := sp.introduced_at
  point_index := idx

/-- Convert a DovetailedPoint back to a StagedPoint (drops index). -/
def toStagedPoint (dp : DovetailedPoint) : StagedPoint where
  mcs := dp.mcs
  is_mcs := dp.is_mcs
  introduced_at := dp.entry_stage

/-!
## Ordering on DovetailedPoints

The order is induced by CanonicalR on the underlying MCSs.
-/

/-- Strict ordering: a < b iff CanonicalR a.mcs b.mcs and NOT CanonicalR b.mcs a.mcs. -/
def DovetailedPoint.lt (a b : DovetailedPoint) : Prop :=
  CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs

/-- Non-strict ordering: a ≤ b iff a.mcs = b.mcs OR CanonicalR a.mcs b.mcs. -/
def DovetailedPoint.le (a b : DovetailedPoint) : Prop :=
  a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs

/-- Two DovetailedPoints are equivalent if their underlying MCSs are equal. -/
def DovetailedPoint.equiv (a b : DovetailedPoint) : Prop :=
  a.mcs = b.mcs

theorem DovetailedPoint.le_refl (a : DovetailedPoint) : DovetailedPoint.le a a :=
  Or.inl rfl

theorem DovetailedPoint.le_trans (a b c : DovetailedPoint)
    (hab : DovetailedPoint.le a b) (hbc : DovetailedPoint.le b c) :
    DovetailedPoint.le a c := by
  rcases hab with h_eq_ab | hab
  · rcases hbc with h_eq_bc | hbc
    · exact Or.inl (h_eq_ab.trans h_eq_bc)
    · exact Or.inr (h_eq_ab ▸ hbc)
  · rcases hbc with h_eq_bc | hbc
    · exact Or.inr (h_eq_bc ▸ hab)
    · exact Or.inr (canonicalR_transitive a.mcs b.mcs c.mcs a.is_mcs hab hbc)

/-!
## DovetailedPoint Comparability from MCS Comparability
-/

theorem dovetailedPoint_le_of_mcs_comparable (a b : DovetailedPoint)
    (h_comp : CanonicalR a.mcs b.mcs ∨ CanonicalR b.mcs a.mcs ∨ a.mcs = b.mcs) :
    DovetailedPoint.le a b ∨ DovetailedPoint.le b a := by
  rcases h_comp with h_ab | h_ba | h_eq
  · exact Or.inl (Or.inr h_ab)
  · exact Or.inr (Or.inr h_ba)
  · exact Or.inl (Or.inl h_eq)

/-!
## Dovetailed Build State

The dovetailed build maintains a list of DovetailedPoints (for indexed access)
along with their properties. We track:
- The current list of points (preserving order of entry)
- Next available point index
- The current stage number
-/

/-- State of the dovetailed build at a given step. -/
structure DovetailedBuildState where
  /-- The list of points in entry order (first entry at index 0). -/
  points : List DovetailedPoint
  /-- Next available point index (= points.length). -/
  next_index : Nat
  /-- Invariant: next_index = points.length -/
  index_eq_length : next_index = points.length

/-- Initial state with just the root point. -/
noncomputable def initialState : DovetailedBuildState where
  points := [DovetailedPoint.mk root_mcs root_mcs_proof 0 0]
  next_index := 1
  index_eq_length := rfl

/-- Get point at index (if valid). -/
def getPointAt (state : DovetailedBuildState) (idx : Nat) : Option DovetailedPoint :=
  state.points[idx]?

/-- Check if an index is valid in the current state. -/
def isValidIndex (state : DovetailedBuildState) (idx : Nat) : Bool :=
  idx < state.next_index

/-- Add a new point to the state, assigning the next available index. -/
noncomputable def addPoint (state : DovetailedBuildState) (mcs : Set Formula)
    (is_mcs : SetMaximalConsistent mcs) (stage : Nat) : DovetailedBuildState where
  points := state.points ++ [DovetailedPoint.mk mcs is_mcs stage state.next_index]
  next_index := state.next_index + 1
  index_eq_length := by simp [state.index_eq_length]

/-!
## Index Invariants

Each point's point_index equals its position in the list.
This invariant is established at creation and preserved by appending.
-/

/-- Helper: getPointAt preserves indices when appending. -/
theorem getPointAt_addPoint_left {state : DovetailedBuildState} {idx : Nat}
    {mcs : Set Formula} {is_mcs : SetMaximalConsistent mcs} {stage : Nat}
    (h : idx < state.points.length) :
    getPointAt (addPoint state mcs is_mcs stage) idx = getPointAt state idx := by
  simp only [getPointAt, addPoint, List.getElem?_append_left h]

/-- The point_index of the root is 0. -/
theorem initialState_root_index :
    (initialState root_mcs root_mcs_proof).points[0]?.isSome = true ∧
    ((initialState root_mcs root_mcs_proof).points[0]?.get
      (by simp [initialState])).point_index = 0 := by
  simp [initialState]

/-- Invariant: for each point in state.points at position i, point.point_index = i. -/
def pointIndexInvariant (state : DovetailedBuildState) : Prop :=
  ∀ i : Nat, ∀ h : i < state.points.length,
    (state.points[i]'h).point_index = i

/-- Initial state satisfies the point index invariant. -/
theorem initialState_pointIndexInvariant :
    pointIndexInvariant (initialState root_mcs root_mcs_proof) := by
  intro i h
  simp only [initialState, List.length_singleton, Nat.lt_one_iff] at h
  simp [initialState, h]

/-- addPoint preserves the point index invariant. -/
theorem addPoint_pointIndexInvariant {state : DovetailedBuildState}
    {mcs : Set Formula} {is_mcs : SetMaximalConsistent mcs} {stage : Nat}
    (h_inv : pointIndexInvariant state) :
    pointIndexInvariant (addPoint state mcs is_mcs stage) := by
  intro i h
  simp only [addPoint, List.length_append, List.length_singleton] at h
  by_cases h_old : i < state.points.length
  · -- Existing point
    simp only [addPoint]
    rw [List.getElem_append_left h_old]
    exact h_inv i h_old
  · -- New point
    have h_eq : i = state.points.length := by omega
    simp only [addPoint, h_eq]
    rw [List.getElem_append_right (by omega)]
    simp [state.index_eq_length]

/-!
## Forward/Backward Witness Processing

We reuse the witness construction from StagedExecution.lean but integrate
with the DovetailedPoint structure.
-/

/-- Process a forward obligation: if F(phi) is in point's MCS, add a forward witness. -/
noncomputable def processForwardObligationDovetailed
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) : DovetailedBuildState :=
  if h : Formula.some_future phi ∈ point.mcs then
    let witness_mcs := executeForwardStep point.mcs point.is_mcs phi h
    let witness_is_mcs := executeForwardStep_mcs (h_mcs := point.is_mcs) (h_F := h)
    addPoint state witness_mcs witness_is_mcs stage
  else
    state

/-- Process a backward obligation: if P(phi) is in point's MCS, add a backward witness. -/
noncomputable def processBackwardObligationDovetailed
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) : DovetailedBuildState :=
  if h : Formula.some_past phi ∈ point.mcs then
    let witness_mcs := executeBackwardStep point.mcs point.is_mcs phi h
    let witness_is_mcs := executeBackwardStep_mcs (h_mcs := point.is_mcs) (h_P := h)
    addPoint state witness_mcs witness_is_mcs stage
  else
    state

/-- Process both F and P obligations for a point and formula. -/
noncomputable def processObligationsDovetailed
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) : DovetailedBuildState :=
  let state' := processForwardObligationDovetailed state point phi stage
  processBackwardObligationDovetailed state' point phi stage

/-!
## Density Processing

For density, we insert intermediate points for F-formulas using the density
axiom F(phi) -> F(F(phi)).
-/

/-- Process density for a point with F(phi): add density intermediate. -/
noncomputable def processDensityDovetailed
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) : DovetailedBuildState :=
  if h : Formula.some_future phi ∈ point.mcs then
    let density_witness := density_witness_exists point.mcs point.is_mcs phi h
    let witness_mcs := Classical.choose density_witness
    let witness_spec := Classical.choose_spec density_witness
    addPoint state witness_mcs witness_spec.1 stage
  else
    state

/-!
## Invariant Preservation for Processing Functions
-/

/-- processForwardObligationDovetailed preserves the point index invariant. -/
theorem processForwardObligationDovetailed_pointIndexInvariant
    {state : DovetailedBuildState} {point : DovetailedPoint} {phi : Formula} {stage : Nat}
    (h_inv : pointIndexInvariant state) :
    pointIndexInvariant (processForwardObligationDovetailed state point phi stage) := by
  unfold processForwardObligationDovetailed
  split
  · exact addPoint_pointIndexInvariant h_inv
  · exact h_inv

/-- processBackwardObligationDovetailed preserves the point index invariant. -/
theorem processBackwardObligationDovetailed_pointIndexInvariant
    {state : DovetailedBuildState} {point : DovetailedPoint} {phi : Formula} {stage : Nat}
    (h_inv : pointIndexInvariant state) :
    pointIndexInvariant (processBackwardObligationDovetailed state point phi stage) := by
  unfold processBackwardObligationDovetailed
  split
  · exact addPoint_pointIndexInvariant h_inv
  · exact h_inv

/-- processObligationsDovetailed preserves the point index invariant. -/
theorem processObligationsDovetailed_pointIndexInvariant
    {state : DovetailedBuildState} {point : DovetailedPoint} {phi : Formula} {stage : Nat}
    (h_inv : pointIndexInvariant state) :
    pointIndexInvariant (processObligationsDovetailed state point phi stage) := by
  unfold processObligationsDovetailed
  exact processBackwardObligationDovetailed_pointIndexInvariant
    (processForwardObligationDovetailed_pointIndexInvariant h_inv)

/-- processDensityDovetailed preserves the point index invariant. -/
theorem processDensityDovetailed_pointIndexInvariant
    {state : DovetailedBuildState} {point : DovetailedPoint} {phi : Formula} {stage : Nat}
    (h_inv : pointIndexInvariant state) :
    pointIndexInvariant (processDensityDovetailed state point phi stage) := by
  unfold processDensityDovetailed
  split
  · exact addPoint_pointIndexInvariant h_inv
  · exact h_inv

/-!
## Single Step of Dovetailed Build

At step n, we process obligation unpair(n) = (p_idx, f_enc):
- If p_idx is a valid point index and f_enc decodes to some formula phi:
  - Process F(phi) and P(phi) obligations for point at index p_idx
  - Add density intermediate for F(phi) if applicable
- Otherwise, no-op
-/

/-- Process one step of the dovetailed construction.
    At step n+1, obligation (p, f) = unpair(n+1) is processed. -/
noncomputable def dovetailedStep
    (state : DovetailedBuildState) (step : Nat) : DovetailedBuildState :=
  let obl := obligationAtStep step
  let p_idx := obl.point_index
  let f_enc := obl.formula_encoding
  match getPointAt state p_idx with
  | none => state  -- Point index not valid, skip
  | some point =>
    match decodeFormulaStaged f_enc with
    | none => state  -- Formula encoding not valid, skip
    | some phi =>
      -- Process F/P obligations
      let state' := processObligationsDovetailed state point phi step
      -- Process density
      processDensityDovetailed state' point phi step

/-- dovetailedStep preserves the point index invariant. -/
theorem dovetailedStep_pointIndexInvariant {state : DovetailedBuildState} {step : Nat}
    (h_inv : pointIndexInvariant state) :
    pointIndexInvariant (dovetailedStep state step) := by
  unfold dovetailedStep
  simp only [getPointAt]
  cases h_point : state.points[(obligationAtStep step).point_index]? with
  | none => exact h_inv
  | some point =>
    cases decodeFormulaStaged (obligationAtStep step).formula_encoding with
    | none => exact h_inv
    | some phi =>
      exact processDensityDovetailed_pointIndexInvariant
        (processObligationsDovetailed_pointIndexInvariant h_inv)

/-!
## Full Dovetailed Build

The full build recursively applies dovetailedStep.
-/

/-- The recursive dovetailed build. Produces the state at each step. -/
noncomputable def dovetailedBuildState : Nat → DovetailedBuildState
  | 0 => initialState root_mcs root_mcs_proof
  | n + 1 => dovetailedStep (dovetailedBuildState n) (n + 1)

/-- The dovetailed build state satisfies the point index invariant at all steps. -/
theorem dovetailedBuildState_pointIndexInvariant (n : Nat) :
    pointIndexInvariant (dovetailedBuildState root_mcs root_mcs_proof n) := by
  induction n with
  | zero => exact initialState_pointIndexInvariant root_mcs root_mcs_proof
  | succ n ih =>
    simp only [dovetailedBuildState]
    exact dovetailedStep_pointIndexInvariant ih

/-- Key lookup lemma: if p is in the state and invariant holds, lookup at p.point_index returns p. -/
theorem getPointAt_of_mem {state : DovetailedBuildState} {p : DovetailedPoint}
    (h_inv : pointIndexInvariant state)
    (h_mem : p ∈ state.points) :
    getPointAt state p.point_index = some p := by
  -- p is at some position i in the list
  have ⟨i, h_get⟩ := List.mem_iff_get.mp h_mem
  have h_i_lt := i.isLt
  -- By invariant, the element at position i has point_index = i
  have h_inv_i := h_inv i h_i_lt
  -- Since state.points[i] = p (from h_get), we have p.point_index = i
  have h_p_idx : p.point_index = i := by
    rw [← h_get]
    exact h_inv_i
  -- So looking up at p.point_index = i gives p
  simp only [getPointAt, h_p_idx]
  rw [List.getElem?_eq_getElem h_i_lt]
  rw [List.get_eq_getElem] at h_get
  exact congrArg some h_get

/-- Extract the Finset of DovetailedPoints at a given step. -/
noncomputable def dovetailedBuild (n : Nat) : Finset DovetailedPoint :=
  (dovetailedBuildState root_mcs root_mcs_proof n).points.toFinset

/-!
## Monotonicity

The build is monotonic: each step contains all previous points.
-/

theorem addPoint_points_superset (state : DovetailedBuildState)
    (mcs : Set Formula) (is_mcs : SetMaximalConsistent mcs) (stage : Nat) :
    state.points ⊆ (addPoint state mcs is_mcs stage).points := by
  intro p hp
  simp only [addPoint, List.mem_append, List.mem_singleton]
  exact Or.inl hp

theorem processForwardObligationDovetailed_monotone
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) :
    state.points ⊆ (processForwardObligationDovetailed state point phi stage).points := by
  unfold processForwardObligationDovetailed
  split
  · exact addPoint_points_superset _ _ _ _
  · exact fun _ h => h

theorem processBackwardObligationDovetailed_monotone
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) :
    state.points ⊆ (processBackwardObligationDovetailed state point phi stage).points := by
  unfold processBackwardObligationDovetailed
  split
  · exact addPoint_points_superset _ _ _ _
  · exact fun _ h => h

theorem processObligationsDovetailed_monotone
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) :
    state.points ⊆ (processObligationsDovetailed state point phi stage).points := by
  unfold processObligationsDovetailed
  intro p hp
  have h1 := processForwardObligationDovetailed_monotone state point phi stage hp
  exact processBackwardObligationDovetailed_monotone _ point phi stage h1

theorem processDensityDovetailed_monotone
    (state : DovetailedBuildState) (point : DovetailedPoint)
    (phi : Formula) (stage : Nat) :
    state.points ⊆ (processDensityDovetailed state point phi stage).points := by
  unfold processDensityDovetailed
  split
  · exact addPoint_points_superset _ _ _ _
  · exact fun _ h => h

theorem dovetailedStep_monotone (state : DovetailedBuildState) (step : Nat) :
    state.points ⊆ (dovetailedStep state step).points := by
  unfold dovetailedStep
  simp only [getPointAt]
  cases h_point : state.points[obligationAtStep step |>.point_index]? with
  | none => exact fun _ h => h
  | some point =>
    cases h_phi : decodeFormulaStaged (obligationAtStep step |>.formula_encoding) with
    | none => exact fun _ h => h
    | some phi =>
      intro p hp
      have h1 := processObligationsDovetailed_monotone state point phi step hp
      exact processDensityDovetailed_monotone _ point phi step h1

theorem dovetailedBuildState_monotone (n : Nat) :
    (dovetailedBuildState root_mcs root_mcs_proof n).points ⊆
    (dovetailedBuildState root_mcs root_mcs_proof (n + 1)).points := by
  simp only [dovetailedBuildState]
  exact dovetailedStep_monotone _ _

theorem dovetailedBuild_monotone (n : Nat) :
    dovetailedBuild root_mcs root_mcs_proof n ⊆
    dovetailedBuild root_mcs root_mcs_proof (n + 1) := by
  simp only [dovetailedBuild]
  intro p hp
  rw [List.mem_toFinset] at hp ⊢
  exact dovetailedBuildState_monotone root_mcs root_mcs_proof n hp

theorem dovetailedBuild_monotone_le {n m : Nat} (h : n ≤ m) :
    dovetailedBuild root_mcs root_mcs_proof n ⊆
    dovetailedBuild root_mcs root_mcs_proof m := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  induction k with
  | zero => exact fun _ hp => hp
  | succ k ih =>
    have h_le : n ≤ n + k := Nat.le_add_right n k
    intro p hp
    have h1 := ih h_le hp
    have h2 := dovetailedBuild_monotone root_mcs root_mcs_proof (n + k) h1
    simp only [Nat.add_assoc] at h2 ⊢
    exact h2

/-!
## Dovetailed Timeline Union

The union of all dovetailed build stages.
-/

/-- The union of all stages of the dovetailed build. -/
def dovetailedTimelineUnion : Set DovetailedPoint :=
  { p | ∃ n : Nat, p ∈ dovetailedBuild root_mcs root_mcs_proof n }

/-- The root is in the dovetailed timeline at step 0. -/
theorem root_in_dovetailedBuild_0 :
    ∃ p ∈ dovetailedBuild root_mcs root_mcs_proof 0,
      p.mcs = root_mcs ∧ p.point_index = 0 := by
  use DovetailedPoint.mk root_mcs root_mcs_proof 0 0
  constructor
  · simp only [dovetailedBuild, dovetailedBuildState, initialState, List.toFinset_cons,
      List.toFinset_nil, Finset.mem_insert]
    left
    trivial
  · exact ⟨rfl, rfl⟩

/-- The dovetailed timeline is nonempty. -/
theorem dovetailedTimeline_nonempty :
    Set.Nonempty (dovetailedTimelineUnion root_mcs root_mcs_proof) := by
  obtain ⟨p, hp, _, _⟩ := root_in_dovetailedBuild_0 root_mcs root_mcs_proof
  exact ⟨p, 0, hp⟩

/-!
## Countability

The dovetailed timeline is countable (countable union of finite sets).
-/

theorem dovetailedTimeline_countable :
    Set.Countable (dovetailedTimelineUnion root_mcs root_mcs_proof) := by
  apply Set.Countable.mono (s₂ := ⋃ n : Nat, ↑(dovetailedBuild root_mcs root_mcs_proof n))
  · intro p hp
    obtain ⟨n, hn⟩ := hp
    exact Set.mem_iUnion.mpr ⟨n, hn⟩
  · exact Set.countable_iUnion (fun n => Set.Finite.countable (Finset.finite_toSet _))

/-!
## Root Comparability

All points in the dovetailed build are MCS-comparable with the root.
-/

/-- Helper: get the root DovetailedPoint. -/
noncomputable def rootDovetailedPoint : DovetailedPoint where
  mcs := root_mcs
  is_mcs := root_mcs_proof
  entry_stage := 0
  point_index := 0

/-- Forward witness is comparable with root if source is. -/
theorem forwardWitness_comparable_with_root_dovetailed
    (point : DovetailedPoint)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ point.mcs)
    (h_comp : CanonicalR (rootDovetailedPoint root_mcs root_mcs_proof).mcs point.mcs ∨
              CanonicalR point.mcs (rootDovetailedPoint root_mcs root_mcs_proof).mcs ∨
              (rootDovetailedPoint root_mcs root_mcs_proof).mcs = point.mcs) :
    CanonicalR (rootDovetailedPoint root_mcs root_mcs_proof).mcs
      (executeForwardStep point.mcs point.is_mcs phi h_F) ∨
    CanonicalR (executeForwardStep point.mcs point.is_mcs phi h_F)
      (rootDovetailedPoint root_mcs root_mcs_proof).mcs ∨
    (rootDovetailedPoint root_mcs root_mcs_proof).mcs =
      (executeForwardStep point.mcs point.is_mcs phi h_F) := by
  have h_R : CanonicalR point.mcs (executeForwardStep point.mcs point.is_mcs phi h_F) :=
    executeForwardStep_canonicalR (h_mcs := point.is_mcs) (h_F := h_F)
  have h_mcs_w : SetMaximalConsistent (executeForwardStep point.mcs point.is_mcs phi h_F) :=
    executeForwardStep_mcs (h_mcs := point.is_mcs) (h_F := h_F)
  exact comparability_step_forward
    (rootDovetailedPoint root_mcs root_mcs_proof).mcs point.mcs
    (executeForwardStep point.mcs point.is_mcs phi h_F)
    root_mcs_proof point.is_mcs h_mcs_w h_comp h_R

/-- Backward witness is comparable with root if source is. -/
theorem backwardWitness_comparable_with_root_dovetailed
    (point : DovetailedPoint)
    (phi : Formula)
    (h_P : Formula.some_past phi ∈ point.mcs)
    (h_comp : CanonicalR (rootDovetailedPoint root_mcs root_mcs_proof).mcs point.mcs ∨
              CanonicalR point.mcs (rootDovetailedPoint root_mcs root_mcs_proof).mcs ∨
              (rootDovetailedPoint root_mcs root_mcs_proof).mcs = point.mcs) :
    CanonicalR (rootDovetailedPoint root_mcs root_mcs_proof).mcs
      (executeBackwardStep point.mcs point.is_mcs phi h_P) ∨
    CanonicalR (executeBackwardStep point.mcs point.is_mcs phi h_P)
      (rootDovetailedPoint root_mcs root_mcs_proof).mcs ∨
    (rootDovetailedPoint root_mcs root_mcs_proof).mcs =
      (executeBackwardStep point.mcs point.is_mcs phi h_P) := by
  have h_R : CanonicalR (executeBackwardStep point.mcs point.is_mcs phi h_P) point.mcs :=
    executeBackwardStep_canonicalR (h_mcs := point.is_mcs) (h_P := h_P)
  have h_mcs_w : SetMaximalConsistent (executeBackwardStep point.mcs point.is_mcs phi h_P) :=
    executeBackwardStep_mcs (h_mcs := point.is_mcs) (h_P := h_P)
  exact comparability_step_backward
    (rootDovetailedPoint root_mcs root_mcs_proof).mcs point.mcs
    (executeBackwardStep point.mcs point.is_mcs phi h_P)
    root_mcs_proof point.is_mcs h_mcs_w h_comp h_R

/-- Density witness is comparable with root if source is. -/
theorem densityWitness_comparable_with_root_dovetailed
    (point : DovetailedPoint)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ point.mcs)
    (h_comp : CanonicalR (rootDovetailedPoint root_mcs root_mcs_proof).mcs point.mcs ∨
              CanonicalR point.mcs (rootDovetailedPoint root_mcs root_mcs_proof).mcs ∨
              (rootDovetailedPoint root_mcs root_mcs_proof).mcs = point.mcs) :
    let witness := Classical.choose (density_witness_exists point.mcs point.is_mcs phi h_F)
    CanonicalR (rootDovetailedPoint root_mcs root_mcs_proof).mcs witness ∨
    CanonicalR witness (rootDovetailedPoint root_mcs root_mcs_proof).mcs ∨
    (rootDovetailedPoint root_mcs root_mcs_proof).mcs = witness := by
  let witness := Classical.choose (density_witness_exists point.mcs point.is_mcs phi h_F)
  let witness_spec := Classical.choose_spec (density_witness_exists point.mcs point.is_mcs phi h_F)
  have h_R : CanonicalR point.mcs witness := witness_spec.2.1
  have h_mcs_w : SetMaximalConsistent witness := witness_spec.1
  exact comparability_step_forward
    (rootDovetailedPoint root_mcs root_mcs_proof).mcs point.mcs witness
    root_mcs_proof point.is_mcs h_mcs_w h_comp h_R

/-!
## Linearity of Dovetailed Build

All points in the dovetailed build are MCS-comparable (via CanonicalR).
This follows from the fact that all points are comparable with the root,
and comparability is transitive via the temp_linearity axiom.
-/

/-- All points in the dovetailed build are MCS-comparable with the root. -/
theorem dovetailedBuildState_all_comparable_with_root (n : Nat)
    (p : DovetailedPoint) (hp : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points) :
    CanonicalR (rootDovetailedPoint root_mcs root_mcs_proof).mcs p.mcs ∨
    CanonicalR p.mcs (rootDovetailedPoint root_mcs root_mcs_proof).mcs ∨
    (rootDovetailedPoint root_mcs root_mcs_proof).mcs = p.mcs := by
  induction n generalizing p with
  | zero =>
    simp only [dovetailedBuildState, initialState, List.mem_singleton] at hp
    rw [hp]
    exact Or.inr (Or.inr rfl)
  | succ n ih =>
    have h_mono := dovetailedBuildState_monotone root_mcs root_mcs_proof n
    by_cases h_prev : p ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points
    · exact ih p h_prev
    · -- p was added at step n+1
      simp only [dovetailedBuildState] at hp
      unfold dovetailedStep at hp
      simp only [getPointAt] at hp
      cases h_point : (dovetailedBuildState root_mcs root_mcs_proof n).points[obligationAtStep (n + 1) |>.point_index]?
        with
      | none =>
        simp only [h_point] at hp
        exact ih p hp
      | some point =>
        simp only [h_point] at hp
        cases h_phi : decodeFormulaStaged (obligationAtStep (n + 1) |>.formula_encoding) with
        | none =>
          simp only [h_phi] at hp
          exact ih p hp
        | some phi =>
          simp only [h_phi] at hp
          -- p is either from processObligationsDovetailed or processDensityDovetailed
          -- In either case, p is a witness from a point that was already comparable with root
          have h_point_mem : point ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points := by
            have : (dovetailedBuildState root_mcs root_mcs_proof n).points[(obligationAtStep (n + 1)).point_index]? = some point := h_point
            exact List.mem_of_getElem? this
          have h_point_comp := ih point h_point_mem
          -- p is comparable with root because it's either:
          -- 1. Already in the previous state (handled by IH)
          -- 2. A forward witness from point
          -- 3. A backward witness from point
          -- 4. A density witness from point
          -- All witnesses from point are comparable with root by the comparability lemmas
          -- Since h_prev says p is NOT in the previous state, p must be a witness
          -- The witness's MCS determines comparability
          -- Use the fact that all newly added MCSs are witnesses from point
          unfold processObligationsDovetailed at hp
          unfold processForwardObligationDovetailed processBackwardObligationDovetailed at hp
          unfold processDensityDovetailed at hp
          by_cases h_F : Formula.some_future phi ∈ point.mcs
          · -- F(phi) in point.mcs - density also applies
            simp only [dif_pos h_F] at hp
            by_cases h_P : Formula.some_past phi ∈ point.mcs
            · -- Both F and P
              simp only [dif_pos h_P, addPoint, List.mem_append, List.mem_singleton] at hp
              -- hp : p in [[prev ++ [fwd]] ++ [bwd]] ++ [density]
              rcases hp with ((((hp | hp_fwd) | hp_bwd) | hp_density))
              · exact absurd hp h_prev
              · simp only [hp_fwd]
                exact forwardWitness_comparable_with_root_dovetailed root_mcs root_mcs_proof point phi h_F h_point_comp
              · simp only [hp_bwd]
                exact backwardWitness_comparable_with_root_dovetailed root_mcs root_mcs_proof point phi h_P h_point_comp
              · simp only [hp_density]
                exact densityWitness_comparable_with_root_dovetailed root_mcs root_mcs_proof point phi h_F h_point_comp
            · -- Only F
              simp only [dif_neg h_P, addPoint, List.mem_append, List.mem_singleton] at hp
              -- hp : p in [prev ++ [fwd]] ++ [density]
              rcases hp with ((hp | hp_fwd) | hp_density)
              · exact absurd hp h_prev
              · simp only [hp_fwd]
                exact forwardWitness_comparable_with_root_dovetailed root_mcs root_mcs_proof point phi h_F h_point_comp
              · simp only [hp_density]
                exact densityWitness_comparable_with_root_dovetailed root_mcs root_mcs_proof point phi h_F h_point_comp
          · -- F(phi) not in point.mcs - no density
            simp only [dif_neg h_F] at hp
            by_cases h_P : Formula.some_past phi ∈ point.mcs
            · -- Only P
              simp only [dif_pos h_P, addPoint, List.mem_append, List.mem_singleton] at hp
              -- hp : p in prev ++ [bwd]
              rcases hp with (hp | hp_bwd)
              · exact absurd hp h_prev
              · simp only [hp_bwd]
                exact backwardWitness_comparable_with_root_dovetailed root_mcs root_mcs_proof point phi h_P h_point_comp
            · -- Neither F nor P - no witnesses, contradicts h_prev
              simp only [dif_neg h_P] at hp
              exact absurd hp h_prev

/-- MCS-comparability of two points in the dovetailed build. -/
theorem dovetailedBuildState_mcs_comparable (n : Nat)
    (a b : DovetailedPoint)
    (ha : a ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points)
    (hb : b ∈ (dovetailedBuildState root_mcs root_mcs_proof n).points) :
    CanonicalR a.mcs b.mcs ∨ CanonicalR b.mcs a.mcs ∨ a.mcs = b.mcs := by
  have h_a_root := dovetailedBuildState_all_comparable_with_root root_mcs root_mcs_proof n a ha
  have h_b_root := dovetailedBuildState_all_comparable_with_root root_mcs root_mcs_proof n b hb
  rcases h_a_root with h_Ra | h_aR | h_aeq
  · rcases h_b_root with h_Rb | h_bR | h_beq
    · exact canonical_forward_reachable_linear
        (rootDovetailedPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_Ra h_Rb
    · exact comparability_step_backward a.mcs
        (rootDovetailedPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inr (Or.inl h_Ra)) h_bR
    · exact Or.inr (Or.inl (h_beq ▸ h_Ra))
  · rcases h_b_root with h_Rb | h_bR | h_beq
    · exact comparability_step_forward a.mcs
        (rootDovetailedPoint root_mcs root_mcs_proof).mcs b.mcs
        a.is_mcs root_mcs_proof b.is_mcs
        (Or.inl h_aR) h_Rb
    · exact canonical_backward_reachable_linear
        (rootDovetailedPoint root_mcs root_mcs_proof).mcs a.mcs b.mcs
        root_mcs_proof a.is_mcs b.is_mcs h_aR h_bR
    · exact Or.inl (h_beq ▸ h_aR)
  · rcases h_b_root with h_Rb | h_bR | h_beq
    · exact Or.inl (h_aeq ▸ h_Rb)
    · exact Or.inr (Or.inl (h_aeq ▸ h_bR))
    · exact Or.inr (Or.inr (h_aeq.symm.trans h_beq))

/-- The dovetailed build at each step is linearly ordered. -/
theorem dovetailedBuild_linear (n : Nat) :
    ∀ a ∈ dovetailedBuild root_mcs root_mcs_proof n,
    ∀ b ∈ dovetailedBuild root_mcs root_mcs_proof n,
    DovetailedPoint.le a b ∨ DovetailedPoint.le b a := by
  intro a ha b hb
  simp only [dovetailedBuild, List.mem_toFinset] at ha hb
  exact dovetailedPoint_le_of_mcs_comparable a b
    (dovetailedBuildState_mcs_comparable root_mcs root_mcs_proof n a b ha hb)

/-- The dovetailed timeline union is linearly ordered. -/
theorem dovetailedTimeline_linearly_ordered
    (a b : DovetailedPoint)
    (ha : a ∈ dovetailedTimelineUnion root_mcs root_mcs_proof)
    (hb : b ∈ dovetailedTimelineUnion root_mcs root_mcs_proof) :
    DovetailedPoint.le a b ∨ DovetailedPoint.le b a := by
  obtain ⟨n, hn⟩ := ha
  obtain ⟨m, hm⟩ := hb
  have ha_max := dovetailedBuild_monotone_le root_mcs root_mcs_proof (Nat.le_max_left n m) hn
  have hb_max := dovetailedBuild_monotone_le root_mcs root_mcs_proof (Nat.le_max_right n m) hm
  exact dovetailedBuild_linear root_mcs root_mcs_proof (max n m) a ha_max b hb_max

/-!
## NoMaxOrder and NoMinOrder

Every point in the dovetailed timeline has a future witness and a past witness.
These follow from the seriality axioms F(neg bot) and P(neg bot).
-/

/-- The forward witness added by processForwardObligationDovetailed when F(phi) is in point.mcs. -/
noncomputable def forwardWitnessDovetailed (point : DovetailedPoint) (phi : Formula)
    (h_F : Formula.some_future phi ∈ point.mcs) (stage : Nat) : DovetailedPoint where
  mcs := executeForwardStep point.mcs point.is_mcs phi h_F
  is_mcs := executeForwardStep_mcs
  entry_stage := stage
  point_index := 0  -- Placeholder, actual index assigned by addPoint

/-- When F(phi) is in point.mcs, processForwardObligationDovetailed adds a witness with CanonicalR. -/
theorem processForwardObligationDovetailed_adds_witness
    (state : DovetailedBuildState) (point : DovetailedPoint) (phi : Formula) (stage : Nat)
    (h_F : Formula.some_future phi ∈ point.mcs) :
    ∃ w ∈ (processForwardObligationDovetailed state point phi stage).points,
      CanonicalR point.mcs w.mcs ∧ phi ∈ w.mcs := by
  simp only [processForwardObligationDovetailed, dif_pos h_F, addPoint]
  use DovetailedPoint.mk (executeForwardStep point.mcs point.is_mcs phi h_F)
    executeForwardStep_mcs stage state.next_index
  constructor
  · simp [List.mem_append]
  · exact ⟨executeForwardStep_canonicalR (h_mcs := point.is_mcs) (h_F := h_F),
           executeForwardStep_contains_phi (h_mcs := point.is_mcs) (h_F := h_F)⟩

/-- At step pair(p_idx, f_enc), if p_idx is valid and f decodes to phi with F(phi) in point.mcs,
    then a witness with CanonicalR is added. -/
theorem dovetailedStep_adds_witness_when_processed
    (state : DovetailedBuildState) (step : Nat) (point : DovetailedPoint) (phi : Formula)
    (h_obl_point : (obligationAtStep step).point_index = point.point_index)
    (h_obl_phi : decodeFormulaStaged (obligationAtStep step).formula_encoding = some phi)
    (h_lookup : getPointAt state point.point_index = some point)
    (h_F : Formula.some_future phi ∈ point.mcs) :
    ∃ w ∈ (dovetailedStep state step).points,
      CanonicalR point.mcs w.mcs ∧ phi ∈ w.mcs := by
  simp only [dovetailedStep]
  simp only [h_obl_point, h_lookup, h_obl_phi]
  -- processObligationsDovetailed adds the forward witness
  -- processDensityDovetailed preserves it
  have h_fwd := processForwardObligationDovetailed_adds_witness state point phi step h_F
  obtain ⟨w, hw_mem, hw_R, hw_phi⟩ := h_fwd
  use w
  constructor
  · -- w is in processObligationsDovetailed, hence in processDensityDovetailed
    apply processDensityDovetailed_monotone
    apply processBackwardObligationDovetailed_monotone
    exact hw_mem
  · exact ⟨hw_R, hw_phi⟩

/-!
## Summary

This module provides the core dovetailed build infrastructure:
- DovetailedPoint with explicit point indices
- State machine for incremental construction
- Monotonicity and countability of the construction
- Linearity of the construction (via root comparability)

The forward_F/backward_P coverage theorems are proven in DovetailedForwardF.lean
and DovetailedBackwardP.lean respectively. These theorems require showing that
the dovetailed construction eventually processes all (point, formula) pairs.
-/

end Bimodal.Metalogic.StagedConstruction.DovetailedBuild
