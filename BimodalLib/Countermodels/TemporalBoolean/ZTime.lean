/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.DenseRTimeSharpness
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.EmbedComplete
import BimodalLib.Countermodel
import BimodalLib.Registry

/-!
# Registered countermodels: `TemporalBoolean` at `ZTime`

The refuted inferences whose operators are temporal and whose model lives at the integer-time
class. Each row is a documented constant of type `BimodalLib.CountermodelEntry Formula`; there
is no registration command, because a row's statement is the inference its author writes rather
than something read off a declaration's type.

`ZTime` is the **maximal** class for all three rows here. The frame-class order is a tree and
`Base ≤ ZTime`, so `CountermodelEntry.transferLe` derives the `Base` reading of each row and no
`Base` duplicate is registered. `ZTime` is incomparable with `Dense` and with `RTime`, so
neither row says anything about those two classes — and in both cases that is the point: each
of these two inferences is a *dense*-class principle, refuted at `ZTime` precisely because
integer time is not dense.

## The certificate grade's population route

The CERTIFICATE row below is reached through the **ZTime witness-family checkers**, and that is
the grade's only population route in this tree. The tableau pipeline structurally cannot feed
this grade at `ZTime`: `regionLabel` and `temporalWitness` come back `false` on every formula
there, so the GATED TABLEAU grade is unavailable at `ZTime` by construction rather than merely
rare, and the pipeline's output carries no `ZTime` row and no certificate row at all.

## No `StarNonValidities` row is registered, here or anywhere

The design record asks for the `FormalSystem/StarLanguage/StarNonValidities.lean` refutations
"where the inference is statable in L or L⁺". Measured: it is not. `StarValidOn` carries an
extra binder — the stored-time vector — so L⋆ validity is not an instance of the L/L⁺ point
shape that `PointTruth` abstracts; there is no `profileS`, so an L⋆ row has no computable
filing; and `sentDet`, `timeStore` and `timeRecall` are L⋆-only operators. `refute_erasure`'s
content is L-statable, but the declaration as written is over `StarFormula`. The side condition
is not met, so the rows are recorded as skipped rather than silently omitted.

## Tags

countermodel · temporal · ztime · density · certificate
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

/-! ## The CERTIFICATE grade -/

/--
The generic consequence relation is the `Formula` one. A named `rfl` lemma rather than an inline
`show`: `show` is linted in this package, and CI builds with `--wfail`, so exploiting the
definitional equality inline would be a CI failure.
-/
theorem genericConsequenceIn_eq_semanticConsequenceIn
    (fc : FrameClass) (Γ : List Formula) (φ : Formula) :
    GenericConsequenceIn fc Γ φ = SemanticConsequenceIn fc Γ φ := rfl

open FormalSystem.Metalogic.Decidability in
open FormalSystem.Metalogic.Decidability.WitnessFamily.BotTargets in
/--
CERTIFICATE: `⊥ U ⊥` is refuted at `ZTime` by an accepted witness-family certificate.

What the kernel checks here is a *checker run*, not a hand-built model. `botUntlFamily` is a
finite labelled lasso; `botUntlFamily_certifies` is closed `by decide`, so the four conditions
of `WitnessFamily.Certifies` — local coherence, fulfilment, box-faithfulness and the target —
are decided on finite data; and `WitnessFamily.not_consequence_ztime` turns that into the
refutation. The model is recovered from the family by `WitnessFamily.Refutes`, which is the
model-exhibiting existential behind the certificate.

The grade's own theorem is the only one in this library that takes a premise list **natively**:
`not_consequence_ztime` concludes `¬ SemanticConsequenceIn FrameClass.ZTime Γ σ` for the
family's own `Γ`. The landed family has `Γ = []` (`WitnessFamily ([] : Context) [botUntl]`), so
this row's `premises` is empty like every other landed row's; what distinguishes the grade is
the shape of the predicate it refutes, not the content of this particular `Γ`.
-/
def cmBotUntl : CountermodelEntry Formula where
  premises := []
  conclusion := botUntl
  frameClass := FrameClass.ZTime
  grade := .certificate
  refutation := fun h =>
    WitnessFamily.not_consequence_ztime botUntlFamily
      botUntlFamily_certifies.1 botUntlFamily_certifies.2.1
      botUntlFamily_certifies.2.2.1 botUntlFamily_certifies.2.2.2
      (by simp) h
  profile := { temporal := true }
  profile_eq := rfl
  model := some "FormalSystem.Metalogic.Decidability.WitnessFamily.Refutes"
  note := "The certificate grade's population route is the ZTime witness-family checkers; \
    the tableau pipeline structurally cannot feed this grade. not_consequence_ztime is the \
    only refutation theorem in this library that takes a premise list natively, but the \
    landed family has an empty premise list, so this row's premises is [] as every other \
    row's is."

end BimodalLib.Countermodels.TemporalBoolean.ZTime
