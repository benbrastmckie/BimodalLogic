import Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra
import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.Semantics.TaskFrame

/-!
# DenseTaskRelation: Task Relation for Dense Temporal Domain

This module defines `DenseTask(u, q, v)` as the deterministic three-place task relation
where `u + q = v` under the transferred group structure on `TimelineQuot`.

## Overview

The dense task relation leverages:
- `timelineQuotAddCommGroup` from `TimelineQuotAlgebra.lean` - group structure on TimelineQuot
- `canonicalTaskRel` pattern from `DurationTransfer.lean` - generic task relation definition
- `TaskFrame` from `Semantics/TaskFrame.lean` - axiomatization of task frames

## Main Definitions

- `DenseTask`: The core task relation `u + q = v`
- `DenseTaskFrame`: TaskFrame instance for TimelineQuot

## Main Results

- `DenseTask_zero`: Zero duration iff identity
- `DenseTask_add`: Composition of consecutive tasks
- `DenseTask_neg`: Task reversal via negation
- `density_interpolation`: Any positive-duration task has arbitrary rational subdivision
- `subdivision_at_point`: Any task can be divided at an arbitrary point

## Design Notes

The `DenseTask` relation uses the transferred `AddCommGroup` structure on `TimelineQuot`,
which is derived from the Cantor isomorphism `TimelineQuot ≃o Q`. This makes the task
relation deterministic: given start state `u` and duration `q`, there is exactly one
end state `v = u + q`.

The TaskFrame axioms (nullity_identity, forward_comp, converse) follow trivially from
group properties already proven generically in `DurationTransfer.lean`.

## References

- Task 16: Define DenseTask relation
- Task 956: D construction via Cantor
- TimelineQuotAlgebra.lean: AddCommGroup on TimelineQuot
- DurationTransfer.lean: Generic task relation transfer
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Domain
open Bimodal.Semantics

variable (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)

/-!
## Section 1: Core DenseTask Definition

The task relation is defined as `u + q = v` using the transferred group structure.
This follows the `canonicalTaskRel` pattern from `DurationTransfer.lean`.
-/

/--
The dense task relation: duration `q` takes state `u` to state `v` iff `u + q = v`.

This uses the `AddCommGroup` structure on `TimelineQuot` transferred from Q via
the Cantor isomorphism. The relation is deterministic: for any `u` and `q`,
there is exactly one `v` satisfying `DenseTask u q v`.

Note: We use explicit type class application to ensure the correct group structure is used.
-/
def DenseTask (u q v : TimelineQuot root_mcs root_mcs_proof) : Prop :=
  @HAdd.hAdd _ _ _
    (@instHAdd _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toAdd) u q = v

/-!
## Section 2: Basic Equivalences

These lemmas establish the fundamental properties of `DenseTask` needed for
the TaskFrame axioms.
-/

/--
Zero duration relates exactly identical states: `DenseTask u 0 v ↔ u = v`.

This is the `nullity_identity` axiom for TaskFrame.
-/
theorem DenseTask_zero (u v : TimelineQuot root_mcs root_mcs_proof) :
    DenseTask root_mcs root_mcs_proof u
      (@Zero.zero _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toZero) v ↔ u = v := by
  unfold DenseTask
  have h : @HAdd.hAdd _ _ _
      (@instHAdd _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toAdd) u
      (@Zero.zero _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toZero) = u := by
    letI := timelineQuotAddCommGroup root_mcs root_mcs_proof
    exact @add_zero _ _ u
  rw [h]

/--
Consecutive tasks compose: if `DenseTask u q w` and `DenseTask w r v`,
then `DenseTask u (q + r) v`.

This establishes forward compositionality (the `forward_comp` axiom).
-/
theorem DenseTask_add (u w v q r : TimelineQuot root_mcs root_mcs_proof)
    (h1 : DenseTask root_mcs root_mcs_proof u q w)
    (h2 : DenseTask root_mcs root_mcs_proof w r v) :
    DenseTask root_mcs root_mcs_proof u
      (@HAdd.hAdd _ _ _ (@instHAdd _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toAdd) q r) v := by
  unfold DenseTask at *
  letI := timelineQuotAddCommGroup root_mcs root_mcs_proof
  rw [← h2, ← h1]
  exact (add_assoc u q r).symm

/--
Task reversal via negation: `DenseTask u q v ↔ DenseTask v (-q) u`.

This is the `converse` axiom for TaskFrame.
-/
theorem DenseTask_neg (u q v : TimelineQuot root_mcs root_mcs_proof) :
    DenseTask root_mcs root_mcs_proof u q v ↔
    DenseTask root_mcs root_mcs_proof v
      (@Neg.neg _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toNeg q) u := by
  unfold DenseTask
  letI := timelineQuotAddCommGroup root_mcs root_mcs_proof
  constructor
  · intro h
    rw [← h]
    exact add_neg_cancel_right u q
  · intro h
    have h' : v + -q + q = u + q := by rw [h]
    simp only [neg_add_cancel_right] at h'
    exact h'.symm

/-!
## Section 3: TaskFrame Instance

Create the `TaskFrame` structure for `TimelineQuot` using `DenseTask`.
-/

/--
TaskFrame instance for the dense temporal domain.

The task relation is `DenseTask`, with axioms proven from group properties:
- `nullity_identity`: from `DenseTask_zero`
- `forward_comp`: from `DenseTask_add` (restricted to non-negative durations)
- `converse`: from `DenseTask_neg`
-/
noncomputable def DenseTaskFrame :
    @TaskFrame (TimelineQuot root_mcs root_mcs_proof)
      (timelineQuotAddCommGroup root_mcs root_mcs_proof)
      (inferInstance : LinearOrder (TimelineQuot root_mcs root_mcs_proof))
      (timelineQuotIsOrderedAddMonoid root_mcs root_mcs_proof) := by
  letI acg := timelineQuotAddCommGroup root_mcs root_mcs_proof
  letI oam := timelineQuotIsOrderedAddMonoid root_mcs root_mcs_proof
  exact { WorldState := TimelineQuot root_mcs root_mcs_proof
          task_rel := fun w d u => w + d = u
          nullity_identity := fun w u => ⟨fun h => by rw [add_zero] at h; exact h,
                                          fun h => by rw [add_zero]; exact h⟩
          forward_comp := fun w u v x y _ _ h1 h2 => by
            rw [← h2, ← h1]
            exact (add_assoc w x y).symm
          converse := fun w d u => ⟨
            fun h => by rw [← h]; exact add_neg_cancel_right w d,
            fun h => by
              have h' : u + -d + d = w + d := by rw [h]
              simp only [neg_add_cancel_right] at h'
              exact h'.symm⟩ }

/-!
## Section 4: Density Interpolation

The key semantic property: any positive-duration task can be subdivided at
any intermediate rational point. This follows from group arithmetic.
-/

/--
Density interpolation theorem: for any task `DenseTask u q v` and any
intermediate duration `r`, there exists an intermediate state `w` such that
`DenseTask u r w` and `DenseTask w (q + (-r)) v`.

This captures the dense nature of the temporal domain: tasks can be
subdivided at arbitrary rational points.
-/
theorem density_interpolation
    (u q v : TimelineQuot root_mcs root_mcs_proof)
    (htask : DenseTask root_mcs root_mcs_proof u q v)
    (r : TimelineQuot root_mcs root_mcs_proof) :
    letI acg := timelineQuotAddCommGroup root_mcs root_mcs_proof
    ∃ w : TimelineQuot root_mcs root_mcs_proof,
      DenseTask root_mcs root_mcs_proof u r w ∧
      DenseTask root_mcs root_mcs_proof w
        (@HAdd.hAdd _ _ _ (@instHAdd _ acg.toAdd) q (@Neg.neg _ acg.toNeg r)) v := by
  letI acg := timelineQuotAddCommGroup root_mcs root_mcs_proof
  use @HAdd.hAdd _ _ _ (@instHAdd _ acg.toAdd) u r
  constructor
  · -- DenseTask u r (u + r)
    unfold DenseTask
    rfl
  · -- DenseTask (u + r) (q + (-r)) v
    unfold DenseTask at htask ⊢
    rw [← htask]
    -- Need: u + r + (q + -r) = u + q
    rw [add_assoc, add_comm q (-r), ← add_assoc r (-r) q, add_neg_cancel, zero_add]

/--
Subdivision at midpoint: any task can be divided into two consecutive subtasks.

Given `DenseTask u q v`, for any durations r and s with r + s = q,
we can find a state at u + r.

This captures the essential density property: tasks are infinitely subdividable.
-/
theorem subdivision_at_point
    (u q v : TimelineQuot root_mcs root_mcs_proof)
    (htask : DenseTask root_mcs root_mcs_proof u q v)
    (r s : TimelineQuot root_mcs root_mcs_proof)
    (hrs : @HAdd.hAdd _ _ _
      (@instHAdd _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toAdd) r s = q) :
    ∃ w : TimelineQuot root_mcs root_mcs_proof,
      DenseTask root_mcs root_mcs_proof u r w ∧
      DenseTask root_mcs root_mcs_proof w s v := by
  letI := timelineQuotAddCommGroup root_mcs root_mcs_proof
  use u + r
  constructor
  · -- DenseTask u r (u + r)
    unfold DenseTask
    rfl
  · -- DenseTask (u + r) s v
    unfold DenseTask at htask ⊢
    rw [← htask, ← hrs]
    exact add_assoc u r s

end Bimodal.Metalogic.StagedConstruction
