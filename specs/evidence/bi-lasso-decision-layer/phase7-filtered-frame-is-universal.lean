import FormalSystem.Metalogic.Decidability.FMP.FiniteModel
import FormalSystem.Semantics.IntNormalForm

open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.FMP
open FormalSystem.Syntax

-- All three probes cite the frame's own bridge `RefinedFilteredTaskFrame.rel_iff` rather than
-- unfolding the frame: `RefinedFilteredTaskFrame._proof_4` carries a definitionally-unfolded
-- `TaskFrame.Limit`, so the unfolded application is not type-correct at the transparency `simp`
-- works at and no syntactic rewrite matches. See `FormalSystem/Semantics/TaskFrame.lean`'s
-- `ofReflective_taskRel` docstring: each frame states its own bridge for exactly this reason.
-- Probe A: the finite filtered frame's one-step relation over Z is UNIVERSAL.
example (phi : Formula) (w u : (FiniteFilteredTaskFrame intOrder phi).WorldState) :
    (FiniteFilteredTaskFrame intOrder phi).toFrameOver.step w u :=
  (RefinedFilteredTaskFrame.rel_iff intOrder phi w 1 u).mpr (Or.inl one_ne_zero)

-- Probe B: consequently EVERY function Z -> FilteredWorld is a step path,
-- so H_F over that frame is the full function space and carries no dynamics.
example (phi : Formula)
    (f : ℤ → (FiniteFilteredTaskFrame intOrder phi).WorldState) :
    IsStepPath (FiniteFilteredTaskFrame intOrder phi).toFrameOver f :=
  fun n => (RefinedFilteredTaskFrame.rel_iff intOrder phi (f n) 1 (f (n + 1))).mpr (Or.inl one_ne_zero)

-- Probe C: the relation carries no MCS information at all -- it is universal at
-- every nonzero duration, for every pair of filtered worlds.
example (phi : Formula) (d : ℤ) (hd : d ≠ 0)
    (w u : (FiniteFilteredTaskFrame intOrder phi).WorldState) :
    (FiniteFilteredTaskFrame intOrder phi).TaskRel w d u :=
  (RefinedFilteredTaskFrame.rel_iff intOrder phi w d u).mpr (Or.inl hd)
