import FormalSystem.Semantics.StateTopology

set_option warn.classDefReducibility false
open Topology TopologicalSpace Set

namespace FormalSystem.Semantics.TaskFrame

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {W : Type}

/-- **`app:topology-t1` exactly as the appendix draft states it**: the paper's EQUALITY form of
*Limit* is equivalent to `𝒩_F` being T1, under *Seriality* alone.

`t1Space_nbhdTopology_iff_limit` is the sharper statement — it consumes no constraint at all —
but it is about the `⊆` half of *Limit*, which is what `TaskFrame.Limit` transcribes.
*Seriality* is what upgrades that half to the paper's equality, by way of `lem:nullity`. -/
theorem t1Space_nbhdTopology_iff_iInter_cone_of_serial (R : W → D → W → Prop) (hs : Serial R) :
    (∀ w, ⋂ x > (0 : D), cone R w x = {w}) ↔ @T1Space W (nbhdTopology R) := by
  rw [limit_eq_iff]
  constructor
  · exact fun h => h.1
  · intro h
    refine ⟨h, fun w x hx => ?_⟩
    exact mem_cone_self (nullity_of_serial_limit hs ((t1Space_nbhdTopology_iff_limit R).mp h) w) hx

end FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics
namespace FrameOver

variable {D : TemporalOrder}

/-- **The replacement `def:task-topology`, at a frame**: a set is open exactly when it contains a
positive cone around each of its members. Stated so that no consumer unfolds `stateTopology`. -/
theorem isOpen_iff (F : FrameOver D) {O : Set F.WorldState} :
    IsOpen O ↔ ∀ w ∈ O, ∃ x, 0 < x ∧ TaskFrame.cone F.TaskRel w x ⊆ O :=
  Iff.rfl

/-- **`app:topology-r0` for the state topology**, named. Under the revised `def:task-topology`
the label is about `𝒩_F`, not about the superseded subbasis topology that `r0Space_coneTop`
covers. Previously available only as an anonymous `example`. -/
theorem r0Space_stateTopology (F : FrameOver D) [F.IsRegular] :
    R0Space F.WorldState :=
  TaskFrame.r0Space_nbhdTopology_of_limit F.TaskRel F.limit

/-- **The paper's equality form of *Limit* at a regular frame**: `⋂_{x>0} (w)_x = {w}`. -/
theorem iInter_cone_eq_singleton (F : FrameOver D) [F.IsRegular] (w : F.WorldState) :
    ⋂ x > (0 : (↑D : Type)), TaskFrame.cone F.TaskRel w x = {w} :=
  (TaskFrame.limit_eq_iff F.TaskRel).mpr
    ⟨(t1Space_iff_limit F).mpr F.limit,
      fun w _x hx => TaskFrame.mem_cone_self (F.nullity w) hx⟩ w

#print axioms TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial
#print axioms isOpen_iff
#print axioms r0Space_stateTopology
#print axioms iInter_cone_eq_singleton

end FrameOver
end FormalSystem.Semantics
