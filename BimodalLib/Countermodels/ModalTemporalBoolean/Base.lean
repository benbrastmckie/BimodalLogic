/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.PlusLanguage.Axioms
import FormalSystem.PlusLanguage.PlusDeterminism
import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.PlusLanguage.PlusNonValidities
import BimodalLib.Countermodels.ModalBoolean.Base

/-!
# Registered countermodels: `ModalTemporalBoolean` at `Base`

The four remaining refutations that bound the `⊡` axiom set, each mentioning both `⊡` and a
temporal operator. With `cmStabBox` of `BimodalLib/Countermodels/ModalBoolean/Base.lean` these
five rows are the design record's model for near misses: each is the converse of a law, or a
schema with its side condition dropped.

All four are filed at `Base`, which is maximal: `PlusValid` is `PlusValidIn FrameClass.Base`,
and each refutation is built over the permissive integer frame `NF` without consuming a frame
condition, so there is no stronger class to file them at.

## What each row bounds

* `cmAllFutureStab` bounds `stab_allFuture_valid`: the converse of GS.
* `cmStabAllFuturePast` bounds `stab_allFuture_valid` too, from the other side: GS with its
  pure-future side condition dropped.
* `cmDetermined` bounds `determined_of_deterministic`: the *Determined* schema with its
  determinism hypothesis dropped.
* `cmSomePastStab` bounds nothing in the tree. The bound is recorded in `note`: the
  `⊡`-analogue of Kamp's AK12 has no counterpart here.

The third row is worth stating plainly, because the research for this module recorded the
*Determined* schema as unformalized: the **schema** is not registered, but the positive half of
the result is a theorem — `determined_of_deterministic`, which validates `Fφ → ⊡Fφ` on every
frame satisfying `TaskFrame.Deterministic`. That declaration is exactly what dropping the side
condition refutes, so the row names it rather than falling back to a bare `note`.

## Tags

countermodel · modal · temporal · stability · base · near-miss
-/

namespace BimodalLib.Countermodels.ModalTemporalBoolean.Base

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.PlusLanguage
open BimodalLib.Countermodels.ModalBoolean.Base (plusVar)

/-- `G⊡p → ⊡Gp` at the canonical schema variable. -/
def allFutureStabStatement : PlusFormula :=
  .imp (PlusFormula.allFuture (.stab (plusVar 0))) (.stab (PlusFormula.allFuture (plusVar 0)))

/--
SEMANTIC: `G⊡p → ⊡Gp` is refuted — the converse of GS fails even at an atom.

GS is `⊡Gφ → G⊡φ` for pure-future `φ`; this row is its converse, so the pair bounds the
stability/tense interaction from both sides.
-/
def cmAllFutureStab : CountermodelEntry PlusFormula where
  premises := []
  conclusion := allFutureStabStatement
  frameClass := FrameClass.Base
  grade := .semantic
  refutation := fun h => refute_allFuture_stab _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { stab := true, temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.PlusLanguage.natModel"
  nearMiss := some ``FormalSystem.PlusLanguage.stab_allFuture_valid
  note := "The converse of GS. Refuted at an atom, so no uniform-substitution argument is \
    needed to extend it."

/-- `⊡GPp → G⊡Pp` at the canonical schema variable. -/
def stabAllFuturePastStatement : PlusFormula :=
  .imp (.stab (PlusFormula.allFuture (PlusFormula.somePast (plusVar 0))))
    (PlusFormula.allFuture (.stab (PlusFormula.somePast (plusVar 0))))

/--
SEMANTIC: `⊡GPp → G⊡Pp` is refuted — GS genuinely needs its pure-future side condition.

This is GS itself with the side condition dropped: `Pp` is not pure-future, and at that instance
the schema fails. The `nearMiss` field names the same declaration `cmAllFutureStab` does, which
is the point: one row bounds GS by its converse and the other by its side condition.
-/
def cmStabAllFuturePast : CountermodelEntry PlusFormula where
  premises := []
  conclusion := stabAllFuturePastStatement
  frameClass := FrameClass.Base
  grade := .semantic
  refutation := fun h => refute_stab_allFuture_past _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { stab := true, temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.PlusLanguage.natModel"
  nearMiss := some ``FormalSystem.PlusLanguage.stab_allFuture_valid
  note := "GS with its pure-future side condition dropped: the instance is Pp, which is not \
    pure-future. Bounds the same declaration as cmAllFutureStab, from the other direction."

/-- `Fp → ⊡Fp` at the canonical schema variable. -/
def determinedStatement : PlusFormula :=
  .imp (PlusFormula.someFuture (plusVar 0)) (.stab (PlusFormula.someFuture (plusVar 0)))

/--
SEMANTIC: the *Determined* schema `Fp → ⊡Fp` is refuted over a non-deterministic frame.

The side condition dropped here is a frame condition rather than a syntactic one:
`determined_of_deterministic` validates the schema on every frame satisfying
`TaskFrame.Deterministic`, and this row exhibits a non-deterministic frame where it fails. Two
facts the refutation depends on, recorded because both are easy to lose: the refuting instance
must be a genuinely temporal formula, since at an atom the schema holds on every frame
(`stab_of_stateLocal`); and the integer carrier's discreteness is a real hypothesis, not a
convenience.
-/
def cmDetermined : CountermodelEntry PlusFormula where
  premises := []
  conclusion := determinedStatement
  frameClass := FrameClass.Base
  grade := .semantic
  refutation := fun h => refute_determined _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { stab := true, temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.PlusLanguage.natModel"
  nearMiss := some ``FormalSystem.PlusLanguage.determined_of_deterministic
  note := "The Determined schema with its determinism hypothesis dropped. The schema itself is \
    not registered as a theorem row, but the positive half of the result is a theorem, and that \
    is what this row names."

/-- `P⊡p → ⊡Pp` at the canonical schema variable. -/
def somePastStabStatement : PlusFormula :=
  .imp (PlusFormula.somePast (.stab (plusVar 0))) (.stab (PlusFormula.somePast (plusVar 0)))

/--
SEMANTIC: `P⊡p → ⊡Pp` is refuted — the history bundle at a time is not closed towards the past.

This is the `⊡`-analogue of the single tense/modal interaction axiom of T×W and Ockhamist logic
(Kamp's AK12, Reynolds' HN). Nothing in the tree states that analogue, so this row carries no
`nearMiss` and the bound is recorded in `note` instead: that is the honest disposition, and it
is why `nearMiss` is an `Option`.
-/
def cmSomePastStab : CountermodelEntry PlusFormula where
  premises := []
  conclusion := somePastStabStatement
  frameClass := FrameClass.Base
  grade := .semantic
  refutation := fun h => refute_somePast_stab _ ((genericConsequenceIn_nil _ _).mp h)
  profile := { stab := true, temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.PlusLanguage.natModel"
  note := "Bounds the ⊡-analogue of Kamp's AK12 / Reynolds' HN, which has no counterpart in \
    this tree. No nearMiss: the bounded object is not a declaration here."

end BimodalLib.Countermodels.ModalTemporalBoolean.Base
