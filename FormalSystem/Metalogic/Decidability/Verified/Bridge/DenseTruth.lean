/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntTruth

/-!
# The truth correspondence at a dense carrier

`Bridge/IntTruth.lean` runs the signed truth-lemma induction at `ℤ`, where the placement
`finiteOrderEmbInt` is contiguous and so has **no inhabited interior gap**. This file is
sub-phase 7.1d: the same induction at `ℚ` and `ℝ`, where interior gaps *are* inhabited and the
three geometry hypotheses `ℤ` supplied — `RayOnly`, `RaySplit` and `Stepped` — are all false.

## What carries over verbatim, and why that is a theorem rather than a hope

The `atom`, `bot`, `imp` and `box` cases of `IntTruth.lean` are stated for an **arbitrary**
carrier `D` and an **arbitrary** injective placement `f`. Nothing in them mentions `ℤ`, gaps, or
rays: they need only `cutIndex_le`, which is free. They are therefore consumed here unchanged,
and `branchTruthAt_of_temporal` below is the machine-checked statement of exactly that claim —
the whole six-case induction, with the two temporal cases abstracted into hypotheses and the
other four discharged by the landed `ℤ`-file lemmas.

Isolating the assembly this way is the same move that converged the temporal cases at `ℤ`: split
before proving. It has two payoffs. It makes the *only* difference between the discrete and dense
milestones explicit and finite — two hypotheses — so a reader can see at a glance that 7.1d owes
the temporal cases and nothing else. And it means the dense side never restates
`BranchTruthAt`, `stateLabel`, `normModel`, or any of the four non-temporal cases, which is what
the Phase 7 register requires.

## Why the temporal cases genuinely do not carry over

At `ℤ` a non-placed point lies on one of the two rays (`RayOnly`), so the induction never meets
an inhabited interior gap, and `isPlacedCode_of_between` turns the semantics' "at every carrier
point strictly between" into the branch's "at every known time strictly between". At `ℚ` and `ℝ`
that step is simply false: between two consecutive placed points there is a whole interval of
carrier points, none of them placed, all reading one region label.

The replacement is `Bridge/Interpolate.lean`'s `exists_gt_sameRegion` / `exists_lt_sameRegion`,
which supply a witness **by density** where `Stepped` supplied one by a step, together with
`SameRegion` and the invariance induction — a region's points are indistinguishable, so a witness
may be moved within its region. `not_exists_gt_sameRegion_int` is the machine witness that this
route is unavailable at `ℤ`, which is why the two milestones are separate sub-phases rather than
one lemma with a disjunction in it.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

section Model

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
variable {b : Branch} {ord : TimeOrdering} {f : BranchTime b → D}

/-! ## The assembly, with the temporal cases abstracted

`Formula` has exactly six constructors — `atom`, `bot`, `imp`, `box`, `untl`, `snce`. There are
no `G`/`H`/`F`/`P` constructors: `allFuture φ` is `(untl φ.neg ⊤).neg`, so every temporal
universal lands on the `untl`/`snce` cases through `imp`.
-/

/--
**The truth-lemma induction, generic in the carrier and in the two temporal cases.**

The four non-temporal cases are discharged here, once, from `Bridge/IntTruth.lean`'s
carrier-generic lemmas. The `untl` and `snce` cases are hypotheses, because they are the only two
that distinguish a contiguous placement from a dense one.

`IntTruth.branchTruthAt` is the discrete instance of this (it predates the split and is left
exactly as it landed); the dense milestone is the other instance.

Note which gates appear and which do not: `branchOrderValid` and `temporalWitnessCheck` are
**absent**, because none of the four non-temporal cases consumes either. They re-enter through
whatever discharges `hUntl`/`hSnce`.
-/
theorem branchTruthAt_of_temporal (hf : Function.Injective f)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hne : b.knownWorlds ≠ [])
    (hUntl : ∀ φ ψ : Formula, BranchTruthAt b ord f φ → BranchTruthAt b ord f ψ →
      BranchTruthAt b ord f (Formula.untl φ ψ))
    (hSnce : ∀ φ ψ : Formula, BranchTruthAt b ord f φ → BranchTruthAt b ord f ψ →
      BranchTruthAt b ord f (Formula.snce φ ψ))
    (χ : Formula) : BranchTruthAt b ord f χ := by
  induction χ with
  | atom p => exact branchTruthAt_atom hf fc hOpen p
  | bot => exact branchTruthAt_bot fc hOpen
  | imp φ ψ hφ hψ => exact branchTruthAt_imp hSat hφ hψ
  | box φ hφ => exact branchTruthAt_box hf hSat hTot hBA hCheck hne hφ
  | untl φ ψ hφ hψ => exact hUntl φ ψ hφ hψ
  | snce φ ψ hφ hψ => exact hSnce φ ψ hφ hψ

end Model

end FormalSystem.Metalogic.Decidability.Verified.Bridge
