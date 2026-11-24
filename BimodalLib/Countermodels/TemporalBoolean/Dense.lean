/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DenseRTimeSharpness
import FormalSystem.Metalogic.Independence.SepSharpness
import BimodalLib.Countermodel
import BimodalLib.Registry

/-!
# Registered countermodels: `TemporalBoolean` at `Dense`

The refuted inferences whose operators are temporal and whose model lives at the dense class.
Both rows below are `Dense`-maximal: each inference is an `RTime` principle, valid there and
refuted at every class strictly below `RTime` in the frame-class tree, so `Dense` is the
strongest class at which a refuting model lives. The `Base` reading of each follows by
`CountermodelEntry.transferLe`, and no `Base` duplicate is registered.

Neither row bears on `ZTime`, which is incomparable with both `Dense` and `RTime`.

## Tags

countermodel · temporal · dense · prior-u-gap · separation
-/

namespace BimodalLib.Countermodels.TemporalBoolean.Dense

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.Metalogic.Independence

/-- Prior's U-gap axiom at the canonical schema variable:
`(U(⊤, p) ∧ F(¬p)) → U(¬p ∨ K⁺(¬p), p)`. -/
def priorUGapStatement : Formula := priorUGapFormula (schemaVar 0)

/--
SEMANTIC: Prior's U-gap axiom fails at `Dense`.

Filed at `Dense`, which is maximal: `prior_U_gap_minFrameClass_sharp` refutes the formula at
every class strictly below `RTime`, and `Dense` is the greatest such class. The `Base` reading
follows by `transferLe`.
-/
def cmPriorUGap : CountermodelEntry Formula where
  premises := []
  conclusion := priorUGapStatement
  frameClass := FrameClass.Dense
  grade := .semantic
  refutation := fun h =>
    not_validIn_dense_prior_U_gap _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.Metalogic.Independence.not_validIn_dense_prior_U_gap"
  note := "Maximal at Dense: the axiom is an RTime principle, refuted at every class strictly \
    below RTime. The Base reading follows by transferLe; nothing here bears on ZTime."

/-- The separation axiom's formula at the canonical schema variable. -/
def sepStatement : Formula :=
  (Formula.and (Formula.kPlus (schemaVar 0))
    (Formula.kPlus (Formula.and (schemaVar 0)
      (Formula.untl (schemaVar 0).neg (schemaVar 0)))).neg).imp
    (Formula.kPlus (Formula.and (Formula.kPlus (schemaVar 0))
      (Formula.kMinus (schemaVar 0))))

/--
SEMANTIC: the separation axiom fails at `Dense`.

Filed at `Dense`, which is maximal for the same reason as the row above: `sep_minFrameClass_sharp`
refutes the formula at every class strictly below `RTime`. The model is built over the Hahn
group `Lex (ℚ →₀ ℚ)`. The `Base` reading follows by `transferLe`.
-/
def cmSep : CountermodelEntry Formula where
  premises := []
  conclusion := sepStatement
  frameClass := FrameClass.Dense
  grade := .semantic
  refutation := fun h =>
    not_validIn_dense_sep _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.Metalogic.Independence.not_validIn_dense_sep"
  note := "Maximal at Dense: refuted at every class strictly below RTime. The operators K⁺ and \
    K⁻ are defined from Until and Since, so the row is filed as temporal and not modal."

end BimodalLib.Countermodels.TemporalBoolean.Dense
