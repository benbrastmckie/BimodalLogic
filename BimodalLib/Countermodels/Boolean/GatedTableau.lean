/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Countermodel.Gates

/-!
# Registered countermodels: `Boolean`, the gated-tableau grade

One row at `grade := .gatedTableau`, on explicit branch data. The branch below is the open
saturated branch the tableau procedure produces for `p → ⊥`, transcribed as data; the gates are
discharged by `decide` on that data and the refutation follows from
`BimodalLib.not_genericConsequenceIn_of_gatesOK`. No tableau is rebuilt in the kernel.

## This row is the grade's existence witness, not the grade's population

The pipeline's refutation dataset carries 1,047 distinct gated statements, and **none of them
can be turned into a kernel-checked entry as the data file stands**: the records carry
`true_atoms`/`false_atoms` and the gate flags, and not the open branch or its `TimeOrdering`,
which is exactly what the gate theorem consumes. Admitting the bulk therefore waits on the
pipeline emitting branches, and on the line cost that follows from doing so — measured at
roughly 70 wrapped source lines per entry against a package-wide 1,500-line file linter that CI
enforces with `--wfail`, so 1,047 entries is on the order of 73,000 lines across some fifty
files. That is left as the part of the design record that remains unimplemented.

## An ungated verdict is never a row

A decision procedure's bare `invalid` verdict does not become an entry at any grade. It is
registered as a conjecture at `ConjectureStatus.heuristicallyRefuted`, whose own docstring says
so: a procedure returned a refutation that no theorem stands behind. Only a branch that passes
the gates, with the gate theorem applied, is admitted here.

## Measurements of record

Taken on this module before the row was committed, so the `decide` cost is a sized quantity and
not a default:

* branch length: 14 signed formulas
* distinct times on the branch: 4, namely `[3, 2, 1, 0]`; distinct worlds: 1
* ordering: 3 constraints
* `maxRecDepth` the gate discharge needs: **none** — `decide` closes `gates_ok` at the default
  depth of 512, so no `set_option` is present
* elaboration of this module against a warm build: under 3 seconds
* every line of this file is at most 100 characters

## Tags

countermodel · tableau · gated-tableau · boolean · decide
-/

namespace BimodalLib.Countermodels.Boolean.GatedTableau

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.Verified.Bridge

/-- The atom of the refuted formula, at the canonical schema variable's atom. -/
def atomP : Atom := { base := "p", freshIndex := some 0 }

/-- `⊤`, as the branch's saturation steps write it. -/
def verum : Formula := .imp .bot .bot

/-- A label from a world index and a time index. -/
def label (w t : Nat) : Label := { world := w, time := t }

/-- The refuted formula: `p → ⊥`. -/
def statement : Formula := .imp (.atom atomP) .bot

/--
The open saturated branch denying `statement`, transcribed as data.

Read bottom-up: the last entry is the root denial `¬(p → ⊥)` at the initial label, from which
the implication rule yields `p` positive and `⊥` negative at the same label, and the saturation
steps supply the `⊤ U ⊤` and `⊤ S ⊤` obligations and their witnesses at times 1, 2 and 3.
-/
def branch : Branch :=
  [ ⟨.neg, .bot, label 0 2⟩, ⟨.neg, .bot, label 0 3⟩, ⟨.pos, verum, label 0 3⟩
  , ⟨.pos, .untl verum verum, label 0 1⟩, ⟨.pos, .snce verum verum, label 0 1⟩
  , ⟨.pos, verum, label 0 2⟩
  , ⟨.neg, .bot, label 0 1⟩, ⟨.pos, verum, label 0 1⟩
  , ⟨.pos, .untl verum verum, label 0 0⟩, ⟨.pos, .snce verum verum, label 0 0⟩
  , ⟨.pos, .atom atomP, label 0 0⟩, ⟨.neg, .bot, label 0 0⟩
  , ⟨.pos, .atom atomP, label 0 0⟩, ⟨.neg, statement, label 0 0⟩ ]

/-- The branch's time ordering: three constraints over the four times. -/
def ordering : TimeOrdering := { constraints := [(1, 3), (2, 0), (0, 1)] }

/--
The branch passes every gate, decided on finite data.

No `maxRecDepth` bump: measured, `decide` closes this goal at the default depth of 512. The
research for this module reached for `maxRecDepth 10000` and the bump turned out to be
unnecessary, so it is deliberately absent — an unneeded ceiling would hide a later regression
in exactly the quantity it was raised to protect.
-/
theorem gates_ok : gatesOK statement FrameClass.Base branch ordering = true := by decide

/--
GATED TABLEAU: `p → ⊥` is refuted by an open saturated branch passing the gates.

The grade's existence witness. What the kernel checks is the gate conjunction on the branch
data, by `decide`, and then the gate bridge; the model is the `ℤ` region model
`not_valid_of_hasOpen_int` constructs from the branch, which is why `model` names that theorem
rather than a standalone model declaration.
-/
def cmGatedImpBot : CountermodelEntry Formula where
  premises := []
  conclusion := statement
  frameClass := FrameClass.Base
  grade := .gatedTableau
  refutation := not_genericConsequenceIn_of_gatesOK gates_ok
  profile := {}
  profile_eq := rfl
  model := some
    "FormalSystem.Metalogic.Decidability.Verified.Bridge.not_valid_of_hasOpen_int"
  note := "The gated-tableau grade's existence witness. Bulk admission of the pipeline's 1047 \
    distinct gated statements waits on the pipeline emitting the open branch and its \
    TimeOrdering; the data file carries neither. An ungated invalid verdict is never admitted \
    at any grade."

end BimodalLib.Countermodels.Boolean.GatedTableau
