/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Axioms
import FormalSystem.PlusLanguage.PlusNonValidities
import BimodalLib.Countermodel

/-!
# Registered countermodels: `ModalBoolean` at `Base`

The refuted inferences whose operators are modal and whose model lives at the unconstrained
class. One row: the first of the five refutations that bound the `⊡` axiom set.

`⊡` belongs to the Modal family, so a statement mentioning `⊡` and no temporal operator is
filed in `ModalBoolean` exactly as one mentioning `□` alone would be. `Profile` records the two
operators separately, so the row still carries which of them occur.

## Near-miss naming is one-directional

The `nearMiss` field names the **declaration** this refutation bounds, not a registry row, and
the asymmetry is recorded rather than engineered away. `TheoremEntry` is `Formula`-only by type
(`stmt : (Nat → Formula) → Formula`, `proof : DerivationTree`), so the law this row bounds —
`PlusAxiom.box_stab`, an axiom constructor of the extended language — is not and cannot be a
registry row. A reciprocal row-to-row pairing is therefore not constructible, and
`BimodalLib/Countermodels/Complete.lean` checks the one direction that is: every `some nearMiss`
resolves in the environment.

## Tags

countermodel · modal · stability · base · near-miss
-/

namespace BimodalLib.Countermodels.ModalBoolean.Base

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.PlusLanguage

/-- The canonical schema variable of the extended language, at the same atom `Registry`'s
`schemaVar` uses, so an L⁺ row and an L row are stated at the same variables. -/
def plusVar (i : Nat) : PlusFormula := .atom (Atom.mkFresh "p" i)

/-- `⊡p → □⊡p` at the canonical schema variable. -/
def stabBoxStatement : PlusFormula :=
  .imp (.stab (plusVar 0)) (.box (.stab (plusVar 0)))

/--
SEMANTIC: `⊡p → □⊡p` is refuted — `⊡` does not collapse into `□`.

This is the converse of the MS axiom `□φ → ⊡φ`, whose declaration the `nearMiss` field names:
the two together bound the `⊡` axiom set from above and below, and are a near-miss pair in the
design record's sense. The refuting model is `natModel` over the permissive frame `NF` on `ℤ`.

Filed at `Base`, which is maximal here: `PlusValid` is `PlusValidIn FrameClass.Base`, and the
refutation makes no use of a frame condition, so there is no stronger class to file it at.
-/
def cmStabBox : CountermodelEntry PlusFormula where
  premises := []
  conclusion := stabBoxStatement
  frameClass := FrameClass.Base
  grade := .semantic
  refutation := fun h => refute_stab_box _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { box := true, stab := true }
  profile_eq := rfl
  model := some "FormalSystem.PlusLanguage.natModel"
  nearMiss := some ``FormalSystem.PlusLanguage.PlusAxiom.box_stab
  note := "The converse of the MS axiom □φ → ⊡φ. Together the two bound the ⊡ axiom set. The \
    bounded object is an axiom constructor, not a registry row, so the pairing is \
    one-directional by TheoremEntry's type."

end BimodalLib.Countermodels.ModalBoolean.Base
