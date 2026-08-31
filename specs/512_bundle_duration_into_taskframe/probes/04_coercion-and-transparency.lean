import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Group.Int

namespace CoeProbe
open FormalSystem.Semantics

-- A definition already migrated to the bundled form.
def Migrated (F : TaskFrame) : Type := F.WorldState

structure MigratedStruct (F : TaskFrame) where
  w : F.WorldState

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

-- PROBE A: does CoeOut fire at an explicit argument position of a plain def?
example (F : ParamTaskFrame D) : Type := Migrated F

-- PROBE A2: at a structure's parameter position?
example (F : ParamTaskFrame D) : Type := MigratedStruct F

-- PROBE A3: with a subsequent dependent argument
def MigratedDep (F : TaskFrame) (w : F.WorldState) : Prop := F.TaskRel w 0 w
example (F : ParamTaskFrame D) (w : F.WorldState) : Prop := MigratedDep F w

-- PROBE B: reducible transparency of the exported instance at a bridged frame.
example (F : ParamTaskFrame D) :
    (TaskFrame.ofParam F).addCommGroup = (inferInstance : AddCommGroup D) := rfl

set_option maxHeartbeats 1000000 in
example (F : ParamTaskFrame D) (x y : (TaskFrame.ofParam F).Duration) : x + y = y + x :=
  add_comm x y

-- PROBE B2: does synthesis at reducible transparency find the AMBIENT binder instance?
example (F : ParamTaskFrame D) (x y : D) : (TaskFrame.ofParam F).TaskRel = F.TaskRel := rfl

end CoeProbe
