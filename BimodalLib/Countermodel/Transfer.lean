/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.PlusValidity
import BimodalLib.Countermodel

/-!
# Transfer of countermodels

A countermodel registered once stands for every weaker reading of the same inference. Two
transfers are available, and each rests on a named theorem rather than on a convention: one
moves a refutation down the frame-class order, the other reads an L countermodel in L⁺.

## The frame-class order is a tree, not a chain

`Base ≤ everything`; `Dense ≤ {Dense, RTime}`; `RTime ≤ RTime`; `ZTime ≤ ZTime`. `ZTime` is
**incomparable** with both `Dense` and `RTime`: a model at `ZTime` does not refute at `Dense`
or at `RTime`, and a model at `RTime` does not refute at `ZTime`.

This is why `not_genericConsequenceIn_of_le` takes an explicit `fc₁ ≤ fc₂` hypothesis rather
than relying on a "weaker class" convention: the order is checked by the kernel and not by the
author. It is also why "the strongest frame class at which the model lives" is not always
unique, so one inference may legitimately carry two maximal rows — one at `RTime`, one at
`ZTime` — rather than one.

## Main statements

* `BimodalLib.not_genericConsequenceIn_of_le`: a refutation at a stronger class refutes at
  every weaker class the model belongs to.
* `BimodalLib.not_genericConsequenceIn_ofFormula`: an L countermodel refutes the L⁺ reading of
  the same inference, premise by premise.
* `BimodalLib.inferenceProfile_map_ofFormula`: the embedding preserves the joint profile of an
  inference, so an L⁺ reading is filed in the same cell as the L original.
* `BimodalLib.hasProfile_eq_profileF`, `BimodalLib.hasProfile_eq_profileP`: the two profile
  instances unfold to the two computations, as named `rfl` lemmas.

## Main definitions

* `BimodalLib.CountermodelEntry.transferLe`: the entry rebuilt at a weaker class.
* `BimodalLib.CountermodelEntry.toPlus`: the entry read in L⁺.

The design record names `plusValidIn_ofFormula_iff` for the L-into-L⁺ step. That theorem is the
`Γ = []` case and carries no premises, so the premise-bearing transfer below goes through
`plusTruthAt_ofFormula` instead.

## Tags

countermodel · transfer · frame-class · plus-language
-/

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.PlusLanguage

/-! ## Transfer downward in the frame-class order -/

/--
**Frame-class transfer, downward.** A refutation at a stronger class refutes at every weaker
class the model belongs to.

The hypothesis `fc₁ ≤ fc₂` is what makes this sound in the tree order: `FrameClass.Sat` is
antitone, so a frame of the weaker class's collection need not satisfy the stronger class and
the step cannot be run in reverse. Proved by an explicit term through `FrameClass.Sat.anti`, so
the transferred refutation's axiom set is exactly the original's.
-/
theorem not_genericConsequenceIn_of_le {L : Type} [PointTruth L]
    {fc₁ fc₂ : FrameClass} (h : fc₁ ≤ fc₂) {Γ : List L} {φ : L}
    (hr : ¬ GenericConsequenceIn fc₂ Γ φ) : ¬ GenericConsequenceIn fc₁ Γ φ :=
  fun hc => hr (fun F hF => hc F (FrameClass.Sat.anti h hF))

/-! ## Transfer of an L countermodel into L⁺ -/

/--
**A countermodel in L refutes in L⁺.** The L⁺ reading of an L inference — every premise and the
conclusion carried along `ofFormula` — fails wherever the L inference does.

The step is `plusTruthAt_ofFormula`, the truth-transfer bridge: the six L clauses of
`PlusTruthAt` are `TruthAt`'s verbatim, so the embedding changes nothing at a point. The
premises are carried by `List.mem_map`.
-/
theorem not_genericConsequenceIn_ofFormula {fc : FrameClass} {Γ : List Formula} {φ : Formula}
    (hr : ¬ GenericConsequenceIn fc Γ φ) :
    ¬ GenericConsequenceIn fc (Γ.map ofFormula) (ofFormula φ) := by
  intro hc
  refine hr (fun F hF M τ t hpre => ?_)
  refine (plusTruthAt_ofFormula M φ τ t).mp (hc F hF M τ t ?_)
  intro γ hγ
  obtain ⟨γ', hγ', rfl⟩ := List.mem_map.mp hγ
  exact (plusTruthAt_ofFormula M γ' τ t).mpr (hpre γ' hγ')

/-- The profile instance of the base language unfolds to `profileF`. Named rather than
exploited inline with `show`, which this package's linter flags and CI's `--wfail` would then
fail on. -/
theorem hasProfile_eq_profileF (φ : Formula) : HasProfile.profile φ = profileF φ := rfl

/-- The profile instance of the extended language unfolds to `profileP`. -/
theorem hasProfile_eq_profileP (φ : PlusFormula) : HasProfile.profile φ = profileP φ := rfl

/-- The embedding preserves the joint profile of an inference: the premises and conclusion are
each filed as they were, so an L⁺ reading lands in the same cell as the L original. -/
theorem inferenceProfile_map_ofFormula (Γ : List Formula) (φ : Formula) :
    inferenceProfile (Γ.map ofFormula) (ofFormula φ) = inferenceProfile Γ φ := by
  induction Γ with
  | nil =>
    simp only [List.map_nil, inferenceProfile, List.foldr_nil, hasProfile_eq_profileF,
      hasProfile_eq_profileP]
    exact profileP_ofFormula φ
  | cons γ Γ ih =>
    simp only [List.map_cons, inferenceProfile, List.foldr_cons, hasProfile_eq_profileF,
      hasProfile_eq_profileP] at ih ⊢
    rw [ih, profileP_ofFormula γ]

/-! ## The entry-level companions -/

/--
The entry rebuilt at a weaker frame class. The filing changes and nothing else: the inference,
the grade, the profile and the cited model are carried over unchanged, and the refutation is the
original's image under `not_genericConsequenceIn_of_le`.

A derived entry of this shape is not registered. Rows are filed at maximal classes only, and
this is what makes the weaker readings available without a second row.
-/
def CountermodelEntry.transferLe {L : Type} [PointTruth L] [HasProfile L]
    (e : CountermodelEntry L) {fc : FrameClass} (h : fc ≤ e.frameClass) :
    CountermodelEntry L where
  premises := e.premises
  conclusion := e.conclusion
  frameClass := fc
  grade := e.grade
  refutation := not_genericConsequenceIn_of_le h e.refutation
  profile := e.profile
  profile_eq := e.profile_eq
  model := e.model
  nearMiss := e.nearMiss
  note := e.note

/-- The entry read in L⁺: the same inference carried along `ofFormula`, at the same frame class
and grade, filed in the same cell by `inferenceProfile_map_ofFormula`. -/
def CountermodelEntry.toPlus (e : CountermodelEntry Formula) :
    CountermodelEntry PlusFormula where
  premises := e.premises.map ofFormula
  conclusion := ofFormula e.conclusion
  frameClass := e.frameClass
  grade := e.grade
  refutation := not_genericConsequenceIn_ofFormula e.refutation
  profile := e.profile
  profile_eq := (inferenceProfile_map_ofFormula e.premises e.conclusion).trans e.profile_eq
  model := e.model
  nearMiss := e.nearMiss
  note := e.note

end BimodalLib
