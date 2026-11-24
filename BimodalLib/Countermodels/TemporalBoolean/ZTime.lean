/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DenseRTimeSharpness
import BimodalLib.Countermodel
import BimodalLib.Registry

/-!
# Registered countermodels: `TemporalBoolean` at `ZTime`

The refuted inferences whose operators are temporal and whose model lives at the integer-time
class. Each row is a documented constant of type `BimodalLib.CountermodelEntry Formula`; there
is no registration command, because a row's statement is the inference its author writes rather
than something read off a declaration's type.

`ZTime` is the **maximal** class for both rows here. The frame-class order is a tree and
`Base ≤ ZTime`, so `CountermodelEntry.transferLe` derives the `Base` reading of each row and no
`Base` duplicate is registered. `ZTime` is incomparable with `Dense` and with `RTime`, so
neither row says anything about those two classes — and in both cases that is the point: each
of these two inferences is a *dense*-class principle, refuted at `ZTime` precisely because
integer time is not dense.

## No `StarNonValidities` row is registered, here or anywhere

The design record asks for the `FormalSystem/StarLanguage/StarNonValidities.lean` refutations
"where the inference is statable in L or L⁺". Measured: it is not. `StarValidOn` carries an
extra binder — the stored-time vector — so L⋆ validity is not an instance of the L/L⁺ point
shape that `PointTruth` abstracts; there is no `profileS`, so an L⋆ row has no computable
filing; and `sentDet`, `timeStore` and `timeRecall` are L⋆-only operators. `refute_erasure`'s
content is L-statable, but the declaration as written is over `StarFormula`. The side condition
is not met, so the rows are recorded as skipped rather than silently omitted.

## Tags

countermodel · temporal · ztime · density
-/

namespace BimodalLib.Countermodels.TemporalBoolean.ZTime

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.Metalogic.Independence

/-- `GGp → Gp`, the density axiom's formula, at the canonical schema variable. -/
def densityStatement : Formula :=
  (schemaVar 0).allFuture.allFuture.imp (schemaVar 0).allFuture

/--
SEMANTIC: the density axiom `GGp → Gp` fails at `ZTime`.

Filed at `ZTime`, which is maximal for this row: `not_validIn_base_density` gives the `Base`
reading and is derivable from this one through `CountermodelEntry.transferLe`, since
`Base ≤ ZTime`. Nothing here bears on `Dense` — where the axiom is valid by definition of the
class — or on `RTime`.
-/
def cmDensity : CountermodelEntry Formula where
  premises := []
  conclusion := densityStatement
  frameClass := FrameClass.ZTime
  grade := .semantic
  refutation := fun h =>
    not_validIn_ztime_density _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.Metalogic.Independence.not_validIn_ztime_density"
  note := "Maximal at ZTime; the Base reading follows by transferLe. ZTime is incomparable \
    with Dense and RTime, so this row says nothing about either."

/-- `¬(⊥ U ⊤)`, the dense-class indicator formula. -/
def denseIndicatorStatement : Formula :=
  (Formula.untl Formula.bot (Formula.bot.imp Formula.bot)).neg

/--
SEMANTIC: the dense-class indicator `¬(⊥ U ⊤)` fails at `ZTime`.

The formula is valid exactly on the dense frames, so its failure at `ZTime` is the separating
fact that keeps `Dense` and `ZTime` incomparable rather than nested. Filed at `ZTime`, which is
maximal; the `Base` reading follows by `transferLe`.
-/
def cmDenseIndicator : CountermodelEntry Formula where
  premises := []
  conclusion := denseIndicatorStatement
  frameClass := FrameClass.ZTime
  grade := .semantic
  refutation := fun h =>
    not_validIn_ztime_dense_indicator ((genericConsequenceIn_nil _ _).mp h)
  profile := { temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.Metalogic.Independence.not_validIn_ztime_dense_indicator"
  note := "Maximal at ZTime; the Base reading follows by transferLe. This row is what \
    separates Dense from ZTime in the frame-class tree."

end BimodalLib.Countermodels.TemporalBoolean.ZTime
