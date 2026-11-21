import FormalSystem.Semantics.StateTopology.ConstraintWitnesses
import FormalSystem.Semantics.HistoryMorphism

/-! PROBE 2: can `SeparatingFrame.srel` be wrapped as a `FrameOver intOrder`?
If so, it is a concrete non-saturated base frame over ℤ-time with Comp+Serial+Limit. -/

namespace Probe898b

open FormalSystem.Semantics FormalSystem.Semantics.TaskFrame
open FormalSystem.Semantics.StateTopology.SeparatingFrame

/-- `srel` satisfies the reflection law. -/
theorem srel_reflective (w : ℚ) (d : ℤ) (u : ℚ) : srel w d u ↔ srel u (-d) w := by
  rw [srel_iff, srel_iff, abs_sub_comm]
  norm_num

/-- `srel` as a (non-regular) `FrameOver intOrder`. -/
def sepFrame : FrameOver intOrder :=
  FrameOver.ofReflective ℚ srel srel_reflective

theorem sepFrame_taskRel : sepFrame.TaskRel = srel :=
  FrameOver.ofReflective_taskRel_eq

theorem sepFrame_comp : TaskFrame.Compositional sepFrame.TaskRel := by
  rw [sepFrame_taskRel]; exact srel_compositional

theorem sepFrame_serial : TaskFrame.Serial sepFrame.TaskRel := by
  rw [sepFrame_taskRel]; exact srel_serial

theorem sepFrame_limit : TaskFrame.Limit sepFrame.TaskRel := by
  rw [sepFrame_taskRel]; exact srel_limit

theorem sepFrame_not_saturation : ¬ TaskFrame.Saturation sepFrame.TaskRel := by
  rw [sepFrame_taskRel]; exact not_srel_saturation

end Probe898b
