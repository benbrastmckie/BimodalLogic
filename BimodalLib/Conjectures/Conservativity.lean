/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Conjecture
import BimodalLib.Conservativity

/-!
# Conjectures: the conservativity edges not yet proved

Each edge of the fragment lattice claims that a larger logic proves nothing new about the
formulas of a smaller cell. The edge from the base language into the extended one at
`ModalTemporalBoolean` is a theorem (`plusDerivable_ofFormula_iff`). The others are registered
here as conjectures, stated over derivability within a cell (`BimodalLib.DerivableIn`).

Each is to be established in three steps: soundness of the larger logic, a semantic bridge
from its models to those of the smaller, and completeness of the smaller. The note of each
conjecture says which step the tree lacks.
-/

namespace BimodalLib.Conjectures

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

/-- `Boolean` into `ModalBoolean`: a propositional formula derivable with `□` is derivable
without it. -/
def booleanIntoModalBoolean : Conjecture where
  statement := ∀ (fc : FrameClass) (φ : Formula), profileF φ ≤ {} →
    DerivableIn { box := true } fc φ → DerivableIn {} fc φ
  fragment := .ModalBoolean
  ops := { box := true }
  frameClass := none
  status := .unsettled
  note := "Completeness of the smaller logic is the propositional procedure under \
    FormalSystem/Metalogic/Decidability/Propositional/. The semantic bridge from a model of \
    the modal logic to a valuation is not stated in the tree."

/-- `Boolean` into `TemporalBoolean`: a propositional formula derivable with the temporal
operators is derivable without them. -/
def booleanIntoTemporalBoolean : Conjecture where
  statement := ∀ (fc : FrameClass) (φ : Formula), profileF φ ≤ {} →
    DerivableIn { temporal := true } fc φ → DerivableIn {} fc φ
  fragment := .TemporalBoolean
  ops := {}
  frameClass := none
  status := .unsettled
  note := "Completeness of the smaller logic is the propositional procedure under \
    FormalSystem/Metalogic/Decidability/Propositional/. The semantic bridge from a temporal \
    model to a valuation is not stated in the tree."

/-- `ModalBoolean` with `□` into TM: a formula with `□` and no temporal operator that TM
derives is derivable without the temporal operators. -/
def modalBooleanIntoTM : Conjecture where
  statement := ∀ fc : FrameClass, ConservativeEdge { box := true } fc
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := none
  status := .unsettled
  note := "Needs completeness of S5 for the □-fragment, which the tree does not state."

/-- `TemporalBoolean` into TM at the base class: a formula with no `□` that TM derives is
derivable without `□`. -/
def temporalBooleanIntoTMBase : Conjecture where
  statement := ConservativeEdge { temporal := true } .Base
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .Base
  status := .unsettled
  note := "Needs completeness of the temporal schemata alone at the base class, which the \
    tree does not state."

/-- `TemporalBoolean` into TM at the dense class. -/
def temporalBooleanIntoTMDense : Conjecture where
  statement := ConservativeEdge { temporal := true } .Dense
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .Dense
  status := .unsettled
  note := "Needs completeness of the temporal schemata alone at the dense class, which the \
    tree does not state."

/-- `TemporalBoolean` into TM at the integer-time class. -/
def temporalBooleanIntoTMZTime : Conjecture where
  statement := ConservativeEdge { temporal := true } .ZTime
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .ZTime
  status := .unsettled
  note := "Needs completeness of the temporal schemata alone at the integer-time class, \
    which the tree does not state."

/-- `TemporalBoolean` into TM at the Dedekind-complete class. -/
def temporalBooleanIntoTMRTime : Conjecture where
  statement := ConservativeEdge { temporal := true } .RTime
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .RTime
  status := .unsettled
  note := "Needs completeness of the temporal schemata alone at the Dedekind-complete \
    class, which the tree does not state."

/-- At `ModalBoolean`, the cell with `□` into the cell with `□` and `⊡`: a formula of the base
language with no temporal operator, derivable in the extended system without temporal
operators, is derivable in the base system within the `□` cell. -/
def modalBooleanBoxIntoBoxStab : Conjecture where
  statement := ∀ (fc : FrameClass) (φ : Formula), profileF φ ≤ { box := true } →
    DerivableInP { box := true, stab := true } fc (ofFormula φ) →
    DerivableIn { box := true } fc φ
  fragment := .ModalBoolean
  ops := { box := true, stab := true }
  frameClass := none
  status := .unsettled
  note := "Stated over derivations of the extended system within the cell (withinP). Follows \
    from the edge from L into L⁺ (plusDerivable_ofFormula_iff) once the two edges into TM are \
    proved, or directly by the collapse of ⊡ on state-local formulas."

end BimodalLib.Conjectures
