/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.ZTimeSharpness
import BimodalLib.Countermodel
import BimodalLib.Registry

/-!
# Registered countermodels: `TemporalBoolean` at `RTime`

The refuted inferences whose operators are temporal and whose model lives at the real-time
class. Both rows below are `RTime`-maximal: each inference is a `ZTime` principle — valid
exactly at the integer-time class — so it is refuted at `Base`, at `Dense` and at `RTime`, and
`RTime` is the greatest of those three in the frame-class tree. The `Base` and `Dense` readings
of each row follow by `CountermodelEntry.transferLe`, and neither duplicate is registered.

This is the pair that makes the tree shape of the order visible: a `ZTime` principle is refuted
along the whole `Base ≤ Dense ≤ RTime` chain and valid at `ZTime`, which sits on the other
branch.

## Tags

countermodel · temporal · rtime · prior-uz · ztime-sharpness
-/

namespace BimodalLib.Countermodels.TemporalBoolean.RTime

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.Metalogic.Independence

/-- Prior's UZ axiom at the canonical schema variable: `Fp → (¬p U p)`. -/
def priorUZStatement : Formula :=
  (schemaVar 0).someFuture.imp (Formula.untl (schemaVar 0).neg (schemaVar 0))

/--
SEMANTIC: Prior's UZ axiom `Fp → (¬p U p)` fails at `RTime`.

Filed at `RTime`, which is maximal: `prior_UZ_validIn_iff_ztime` shows the formula valid exactly
at `ZTime`, so it is refuted along the whole `Base ≤ Dense ≤ RTime` chain and `RTime` is the
greatest class of that chain. The `Base` and `Dense` readings follow by `transferLe`.
-/
def cmPriorUZ : CountermodelEntry Formula where
  premises := []
  conclusion := priorUZStatement
  frameClass := FrameClass.RTime
  grade := .semantic
  refutation := fun h =>
    not_validIn_rtime_prior_UZ _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.Metalogic.Independence.not_validIn_rtime_prior_UZ"
  note := "Maximal at RTime: valid exactly at ZTime, so refuted along the whole Base-Dense-RTime \
    chain. The Base and Dense readings follow by transferLe."

/-- The Z1 axiom at the canonical schema variable: `G(Gp → p) → (FGp → Gp)`. -/
def z1Statement : Formula :=
  ((schemaVar 0).allFuture.imp (schemaVar 0)).allFuture.imp
    ((schemaVar 0).allFuture.someFuture.imp (schemaVar 0).allFuture)

/--
SEMANTIC: the Z1 axiom `G(Gp → p) → (FGp → Gp)` fails at `RTime`.

Filed at `RTime` for the same reason as the row above: `z1_validIn_iff_ztime` shows the formula
valid exactly at `ZTime`. The `Base` and `Dense` readings follow by `transferLe`.
-/
def cmZ1 : CountermodelEntry Formula where
  premises := []
  conclusion := z1Statement
  frameClass := FrameClass.RTime
  grade := .semantic
  refutation := fun h =>
    not_validIn_rtime_z1 _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.Metalogic.Independence.not_validIn_rtime_z1"
  note := "Maximal at RTime: valid exactly at ZTime. The Base and Dense readings follow by \
    transferLe."

end BimodalLib.Countermodels.TemporalBoolean.RTime
