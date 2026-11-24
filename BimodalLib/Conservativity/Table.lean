/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Conservativity.Proved
import BimodalLib.Conservativity.TemporalBase

/-!
# The conservativity edges and what is known of each

One row per edge of the fragment lattice. A row holds the statement of the edge and a verdict on
that statement. The verdict is a dependent value: `proved` carries a proof of the statement,
`refuted` carries a proof of its negation, and `open` carries the obstruction as text. The index
prints the constructor, so a row reads "proved" only when the kernel has checked a proof of the
statement the row holds, and "refuted" only when it has checked a proof of the negation.

## Main definitions

* `BimodalLib.EdgeVerdict`: proved, refuted or open.
* `BimodalLib.ConservativityEdge`: a row.
* The rows, in the namespace `BimodalLib.Edges`.
-/

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Metalogic FormalSystem.Metalogic.Conservativity

/-- What is known of a statement: a proof, a proof of the negation, or an obstruction. -/
inductive EdgeVerdict (statement : Prop) : Type where
  /-- The statement is proved. -/
  | proved (proof : statement) : EdgeVerdict statement
  /-- The statement is refuted. -/
  | refuted (proof : ¬ statement) : EdgeVerdict statement
  /-- The statement is neither proved nor refuted; the text names what stands in the way. -/
  | «open» (obstruction : String) : EdgeVerdict statement

/-- A conservativity edge: a smaller cell, the larger system that is claimed to prove nothing new
about it, the statement of that claim, and what is known of it. -/
structure ConservativityEdge where
  /-- The position of the row in the table. -/
  order : Nat
  /-- The smaller cell, as printed. -/
  smaller : String
  /-- The larger cell or system, as printed. -/
  larger : String
  /-- The frame class of the edge, where it is stated at one. -/
  frameClass : Option FrameClass
  /-- The statement of the edge. -/
  statement : Prop
  /-- What is known of the statement. -/
  verdict : EdgeVerdict statement
  /-- The declaration that proves or refutes the edge, or the conjecture that states it. -/
  reference : String

/-- The status of a verdict, as the index prints it. -/
def EdgeVerdict.name {statement : Prop} : EdgeVerdict statement → String
  | .proved _ => "proved"
  | .refuted _ => "refuted"
  | .open _ => "open"

namespace Edges

/-- The base language into the extended language: the extended system derives the embedding of a
formula exactly when the base system derives the formula. -/
def baseIntoPlus : ConservativityEdge where
  order := 0
  smaller := "L, every cell"
  larger := "L⁺, the extended system"
  frameClass := none
  statement := ∀ (fc : FrameClass) (φ : Formula),
    PlusDerivable fc [] (ofFormula φ) ↔ Derivable fc [] φ
  verdict := .proved fun fc φ => by
    cases fc with
    | Base => exact plusDerivable_ofFormula_iff completeness_base φ
    | Dense => exact plusDerivable_ofFormula_iff completeness_dense φ
    | ZTime => exact plusDerivable_ofFormula_iff completeness_ztime φ
    | RTime => exact plusDerivable_ofFormula_iff completeness_rtime φ
  reference := "FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff"

/-- `Boolean` into `ModalBoolean` with `□`. -/
def booleanIntoModalBoolean : ConservativityEdge where
  order := 1
  smaller := "Boolean"
  larger := "ModalBoolean, □"
  frameClass := none
  statement := ∀ (fc : FrameClass) (φ : Formula), profileF φ ≤ {} →
    DerivableIn { box := true } fc φ → DerivableIn {} fc φ
  verdict := .proved derivableIn_boolean_of_box
  reference := "BimodalLib.derivableIn_boolean_of_box"

/-- `Boolean` into `TemporalBoolean`. -/
def booleanIntoTemporalBoolean : ConservativityEdge where
  order := 2
  smaller := "Boolean"
  larger := "TemporalBoolean"
  frameClass := none
  statement := ∀ (fc : FrameClass) (φ : Formula), profileF φ ≤ {} →
    DerivableIn { temporal := true } fc φ → DerivableIn {} fc φ
  verdict := .proved derivableIn_boolean_of_temporal
  reference := "BimodalLib.derivableIn_boolean_of_temporal"

/-- `Boolean` into the full base system. -/
def booleanIntoTM : ConservativityEdge where
  order := 3
  smaller := "Boolean"
  larger := "ModalTemporalBoolean, the base system"
  frameClass := none
  statement := ∀ fc : FrameClass, ConservativeEdge {} fc
  verdict := .proved conservativeEdge_boolean
  reference := "BimodalLib.conservativeEdge_boolean"

/-- `ModalBoolean` with `□` into the full base system. -/
def modalBooleanIntoTM : ConservativityEdge where
  order := 4
  smaller := "ModalBoolean, □"
  larger := "ModalTemporalBoolean, the base system"
  frameClass := none
  statement := ∀ fc : FrameClass, ConservativeEdge { box := true } fc
  verdict := .proved conservativeEdge_box
  reference := "BimodalLib.conservativeEdge_box"

/-- `ModalBoolean` with `□` into `ModalBoolean` with `□` and `⊡`. -/
def modalBooleanBoxIntoBoxStab : ConservativityEdge where
  order := 5
  smaller := "ModalBoolean, □"
  larger := "ModalBoolean, □ and ⊡"
  frameClass := none
  statement := ∀ (fc : FrameClass) (φ : Formula), profileF φ ≤ { box := true } →
    DerivableInP { box := true, stab := true } fc (ofFormula φ) →
    DerivableIn { box := true } fc φ
  verdict := .proved derivableIn_box_of_derivableInP
  reference := "BimodalLib.derivableIn_box_of_derivableInP"

/-- `TemporalBoolean` into the full base system at the base class. -/
def temporalBooleanIntoTMBase : ConservativityEdge where
  order := 6
  smaller := "TemporalBoolean"
  larger := "ModalTemporalBoolean, the base system"
  frameClass := some .Base
  statement := ConservativeEdge { temporal := true } .Base
  verdict := .refuted not_conservativeEdge_temporal_base
  reference := "BimodalLib.not_conservativeEdge_temporal_base"

/-- The obstruction shared by the open temporal edges. -/
def temporalObstruction : String :=
  "The translation that proves this edge reads □ as `always`. It needs the S5 laws of \
  `always`, the law `always φ → always Gφ` and replacement of provable equivalents, each \
  derived inside the temporal cell at this class. None is derived in the tree. No \
  completeness theorem is needed."

/-- `TemporalBoolean` into the full base system at the dense class. -/
def temporalBooleanIntoTMDense : ConservativityEdge where
  order := 7
  smaller := "TemporalBoolean"
  larger := "ModalTemporalBoolean, the base system"
  frameClass := some .Dense
  statement := ConservativeEdge { temporal := true } .Dense
  verdict := .open temporalObstruction
  reference := "BimodalLib.Conjectures.temporalBooleanIntoTMDense"

/-- `TemporalBoolean` into the full base system at the integer-time class. -/
def temporalBooleanIntoTMZTime : ConservativityEdge where
  order := 8
  smaller := "TemporalBoolean"
  larger := "ModalTemporalBoolean, the base system"
  frameClass := some .ZTime
  statement := ConservativeEdge { temporal := true } .ZTime
  verdict := .open temporalObstruction
  reference := "BimodalLib.Conjectures.temporalBooleanIntoTMZTime"

/-- `TemporalBoolean` into the full base system at the Dedekind-complete class. -/
def temporalBooleanIntoTMRTime : ConservativityEdge where
  order := 9
  smaller := "TemporalBoolean"
  larger := "ModalTemporalBoolean, the base system"
  frameClass := some .RTime
  statement := ConservativeEdge { temporal := true } .RTime
  verdict := .open temporalObstruction
  reference := "BimodalLib.Conjectures.temporalBooleanIntoTMRTime"

/-- That discreteness is uniform over time, in both directions: if there is a next moment there
always is one, and if there is a previous moment there always is one. The full base system
derives each conjunct at the base class, through `□`. -/
def discreteUniformity : Formula :=
  Formula.always
    (((Formula.next Formula.top).imp (Formula.always (Formula.next Formula.top))).and
      ((Formula.prev Formula.top).imp (Formula.always (Formula.prev Formula.top))))

/-- The statement of the repaired temporal edge at the base class: a formula of the temporal
cell that the full base system derives is derivable within the cell from the hypothesis that
discreteness is uniform. -/
def RepairedTemporalBase : Prop :=
  ∀ φ : Formula, profileF φ ≤ { temporal := true } →
    Nonempty (DerivationTree FrameClass.Base [] φ) →
    DerivableIn { temporal := true } FrameClass.Base (discreteUniformity.imp φ)

/-- `TemporalBoolean` extended by the uniformity of discreteness, into the full base system at
the base class. -/
def temporalBooleanUniformIntoTMBase : ConservativityEdge where
  order := 10
  smaller := "TemporalBoolean with uniform discreteness as a hypothesis"
  larger := "ModalTemporalBoolean, the base system"
  frameClass := some .Base
  statement := RepairedTemporalBase
  verdict := .open "As for the other temporal edges, with one more step: the translation of \
    the axiom `X⊤ → □X⊤` is `X⊤ → always X⊤`, which the temporal cell at the base class does \
    not derive, so it is taken as a hypothesis. Whether that hypothesis is enough is not \
    known."
  reference := "BimodalLib.Conjectures.temporalBooleanUniformIntoTMBase"

end Edges

end BimodalLib
