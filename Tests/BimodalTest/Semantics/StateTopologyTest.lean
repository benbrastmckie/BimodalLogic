/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.StateTopology.Counterexamples

/-!
# Regression witness for the state-topology collection

The state-topology collection is cited from outside the repository: the manuscript's
task-semantics appendix draws on it, through
`docs/reference/state-topology-appendix-support.md`. Every declaration that support table names
is therefore load-bearing in a way an ordinary internal lemma is not — a rename or a weakened
statement would silently break a citation that no in-tree consumer would notice, because the
collection's two modules are deliberate leaves with no in-tree consumer at all.

This module is that missing consumer. It does two separable things:

1. **Use** the headline declarations at their real statements — the T1 biconditional in both of
   its forms, the open-set criterion, R0 for the state topology, history continuity, and one
   promoted result from each of the two real witnesses. A rename or a weakened hypothesis stops
   this file compiling.
2. **Pin** the axiom profiles with `#guard_msgs`-gated `#print axioms` blocks. These are
   build-breaking: if a profile moves, this module stops compiling, and the corresponding
   `docs/theorem-index.md` and support-table rows must move with it.

It is a **leaf**, imported by nothing but the test aggregator, for the same import-weight reason
that keeps `FormalSystem/Semantics/StateTopology.lean` out of `FormalSystem/Semantics.lean`.

## Related

- `FormalSystem/Semantics/StateTopology.lean` — the general-relation and frame-level layers
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — the four witnesses
- `docs/reference/state-topology-appendix-support.md` — what each of these certifies
-/

-- Inherited from `Semantics/StateTopology.lean`: `coneTopology` and `nbhdTopology` are `def`s of
-- class type, which `warn.classDefReducibility` reports at every mention.
set_option warn.classDefReducibility false

namespace BimodalTest.Semantics.StateTopologyTest

open Topology TopologicalSpace Set
open FormalSystem.Semantics
open FormalSystem.Semantics.TaskFrame
open FormalSystem.Semantics.StateTopology

/-! ## The characterization, used at both of its statements -/

section General

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {W : Type}

/-- The T1 biconditional round-trips: *Limit* gives T1 and T1 gives *Limit* back, with no frame
constraint consumed in between. -/
theorem limit_iff_t1_roundTrip (R : W → D → W → Prop) :
    TaskFrame.Limit R ↔ @T1Space W (nbhdTopology R) :=
  (t1Space_nbhdTopology_iff_limit R).symm

/-- The form the appendix states: under *Seriality*, the `⊆` half of *Limit* really does yield
the paper's equality form, routed through the T1 biconditional. -/
theorem serial_equality_form (R : W → D → W → Prop) (hs : Serial R)
    (hlim : TaskFrame.Limit R) : ∀ w, ⋂ x > (0 : D), cone R w x = {w} :=
  (t1Space_nbhdTopology_iff_iInter_cone_of_serial R hs).mpr
    ((t1Space_nbhdTopology_iff_limit R).mpr hlim)

/-- The open-set criterion is usable as a criterion, in the direction a consumer needs: exhibit a
positive cone inside the set at each of its points and the set is open. -/
theorem isOpen_of_criterion (R : W → D → W → Prop) {O : Set W}
    (h : ∀ w ∈ O, ∃ x, 0 < x ∧ cone R w x ⊆ O) : IsOpen[nbhdTopology R] O :=
  (nbhdTopology_isOpen_iff R).mpr h

/-- The paper's closure phrasings are the Mathlib classes: T1 as `cl{w} = {w}`, R0 as the
commutativity of `w ∈ cl{u}`. -/
theorem closure_phrasings (R : W → D → W → Prop) (hlim : TaskFrame.Limit R) :
    (∀ w : W, closure[nbhdTopology R] ({w} : Set W) = {w}) ∧
      ∀ w u : W, w ∈ closure[nbhdTopology R] ({u} : Set W) →
        u ∈ closure[nbhdTopology R] ({w} : Set W) := by
  letI := nbhdTopology R
  haveI := (t1Space_nbhdTopology_iff_limit R).mpr hlim
  exact ⟨t1Space_iff_closure_singleton.mp inferInstance,
    r0Space_iff_mem_closure_comm.mp inferInstance⟩

end General

/-! ## The frame register -/

section Frames

variable {D : TemporalOrder}

/-- The frame-level open-set criterion, R0 and the equality form of *Limit* are all available at
a regular frame without unfolding the `stateTopology` instance. -/
theorem regular_frame_package (F : FrameOver D) [F.IsRegular] :
    R0Space F.WorldState ∧
      (∀ w : F.WorldState, ⋂ x > (0 : (↑D : Type)), TaskFrame.cone F.TaskRel w x = {w}) ∧
      (∀ O : Set F.WorldState,
        (∀ w ∈ O, ∃ x, 0 < x ∧ TaskFrame.cone F.TaskRel w x ⊆ O) → IsOpen O) :=
  ⟨FrameOver.r0Space_stateTopology F, FrameOver.iInter_cone_eq_singleton F,
    fun _ h => (FrameOver.isOpen_iff F).mpr h⟩

/-- Every world history is a continuous path into the state topology. The order topology on the
duration carrier is an explicit binder, never a global instance. -/
theorem history_is_continuous (F : FrameOver D) [TopologicalSpace (↑D : Type)]
    [OrderTopology (↑D : Type)] {τ : (↑D : Type) → F.WorldState}
    (hτ : TaskFrame.IsHistory F.TaskRel τ) : Continuous τ :=
  FrameOver.continuous_of_history F hτ

end Frames

/-! ## The two real witnesses -/

/-- **The two-origin frame**: T1, not Hausdorff, and the two topologies coincide — so the
separation failure is a property of the frame, not of the choice of topology. Also witnesses that
*Triangle* is sufficient but not necessary for cone-openness. -/
theorem twoOrigins_package :
    ¬ TaskFrame.Triangle TwoOrigins.rel ∧
      coneTopology TwoOrigins.rel = nbhdTopology TwoOrigins.rel ∧
      TwoOrigins.frame.coneTop = FrameOver.stateTopology TwoOrigins.frame ∧
      @T1Space TwoOrigins.frame.WorldState (FrameOver.stateTopology TwoOrigins.frame) ∧
      ¬ @T2Space TwoOrigins.frame.WorldState (FrameOver.stateTopology TwoOrigins.frame) ∧
      ¬ @T2Space TwoOrigins.frame.WorldState TwoOrigins.frame.coneTop :=
  ⟨TwoOrigins.not_triangle, TwoOrigins.coneTopology_eq_nbhdTopology,
    TwoOrigins.frame_coneTop_eq_stateTopology, TwoOrigins.frame_t1Space,
    TwoOrigins.frame_not_t2Space, TwoOrigins.frame_not_t2Space_coneTop⟩

/-- **The hedgehog**: the two topologies really can differ, and the subbasis topology is strictly
finer. In Mathlib's order `t₁ ≤ t₂` means `t₁` is finer, so the strict form reads
`coneTopology < nbhdTopology`. -/
theorem hedgehog_package :
    coneTopology Hedgehog.rel ≠ nbhdTopology Hedgehog.rel ∧
      coneTopology Hedgehog.rel < nbhdTopology Hedgehog.rel :=
  ⟨Hedgehog.coneTopology_ne_nbhdTopology, Hedgehog.coneTopology_lt_nbhdTopology⟩

/-! ## Axiom-profile pins

Build-breaking. If one of these moves, update the expected block and the matching
`docs/theorem-index.md` and support-table rows in the same change.
-/

/--
info: 'FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_limit' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_limit

/--
info: 'FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial

/--
info: 'FormalSystem.Semantics.FrameOver.isOpen_iff' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.FrameOver.isOpen_iff

/--
info: 'FormalSystem.Semantics.FrameOver.r0Space_stateTopology' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.FrameOver.r0Space_stateTopology

/--
info: 'FormalSystem.Semantics.FrameOver.iInter_cone_eq_singleton' depends on axioms: [propext, Classical.choice, Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.FrameOver.iInter_cone_eq_singleton

/--
info: 'FormalSystem.Semantics.TaskFrame.continuous_nbhdTopology_of_history' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.TaskFrame.continuous_nbhdTopology_of_history

/--
info: 'FormalSystem.Semantics.StateTopology.TwoOrigins.not_triangle' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.StateTopology.TwoOrigins.not_triangle

/--
info: 'FormalSystem.Semantics.StateTopology.TwoOrigins.frame_not_t2Space_coneTop' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.StateTopology.TwoOrigins.frame_not_t2Space_coneTop

/--
info: 'FormalSystem.Semantics.StateTopology.Hedgehog.coneTopology_lt_nbhdTopology' depends on axioms: [propext,
 Classical.choice,
 Quot.sound]
-/
#guard_msgs in
#print axioms FormalSystem.Semantics.StateTopology.Hedgehog.coneTopology_lt_nbhdTopology

end BimodalTest.Semantics.StateTopologyTest
