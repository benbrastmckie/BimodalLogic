import FormalSystem.Metalogic.Decidability.FMP.FiniteModel
import FormalSystem.Semantics.IntNormalForm

open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.FMP
open FormalSystem.Syntax

-- Probe A: the finite filtered frame's one-step relation over Z is UNIVERSAL.
example (phi : Formula) (w u : (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.WorldState) :
    (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.step w u := by
  simp [TaskFrame.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]

-- Probe B: consequently EVERY function Z -> FilteredWorld is a step path,
-- so H_F over that frame is the full function space and carries no dynamics.
example (phi : Formula)
    (f : ℤ → (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.WorldState) :
    IsStepPath (FiniteFilteredTaskFrame ℤ phi).toTaskFrame f := by
  intro n
  simp [TaskFrame.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel]

-- Probe C: the relation carries no MCS information at all -- it is universal at
-- every nonzero duration, for every pair of filtered worlds.
example (phi : Formula) (d : ℤ) (hd : d ≠ 0)
    (w u : (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.WorldState) :
    (FiniteFilteredTaskFrame ℤ phi).toTaskFrame.TaskRel w d u := by
  simp [FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, refinedFilteredTaskRel, hd]
