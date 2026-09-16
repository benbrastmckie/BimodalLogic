import FormalSystem.Metalogic.Decidability.FMP.FiniteModel
import FormalSystem.Semantics.IntNormalForm

open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.FMP
open FormalSystem.Syntax

-- Probe A: the finite filtered frame's one-step relation over Z is UNIVERSAL.
example (phi : Formula) (w u : (FiniteFilteredTaskFrame intOrder phi).WorldState) :
    (FiniteFilteredTaskFrame intOrder phi).toFrameOver.step w u := by
  simp [FrameOver.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]

-- Probe B: consequently EVERY function Z -> FilteredWorld is a step path,
-- so H_F over that frame is the full function space and carries no dynamics.
example (phi : Formula)
    (f : ℤ → (FiniteFilteredTaskFrame intOrder phi).WorldState) :
    IsStepPath (FiniteFilteredTaskFrame intOrder phi).toFrameOver f := by
  intro n
  simp [FrameOver.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]

-- Probe C: the relation carries no MCS information at all -- it is universal at
-- every nonzero duration, for every pair of filtered worlds.
example (phi : Formula) (d : ℤ) (hd : d ≠ 0)
    (w u : (FiniteFilteredTaskFrame intOrder phi).WorldState) :
    (FiniteFilteredTaskFrame intOrder phi).TaskRel w d u := by
  simp [FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel, hd]
