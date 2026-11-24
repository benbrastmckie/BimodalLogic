/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Conjecture
import BimodalLib.Conservativity.Table

/-!
# Conjectures: the conservativity edges

Each edge of the fragment lattice claims that a larger logic proves nothing new about the
formulas of a smaller cell. The edges are registered here as conjectures, stated over
derivability within a cell (`BimodalLib.DerivableIn`). A conjecture whose edge has since been
proved or refuted is kept, with status `derived` or `refuted` and a note naming the theorem, as
the link from the question to its answer. The table of edges, with a kernel-checked verdict for
each, is `BimodalLib/Conservativity/Table.lean`.

The method for an edge is a translation: a map on formulas that is the identity on the smaller
cell and sends every derivation of the larger logic to a derivation within the cell. The edges
out of `Boolean` and out of the cell with `□` are proved that way, by collapsing the temporal
operators. The edges out of `TemporalBoolean` need a translation that reads `□` as `always`; the
note of each open conjecture says what that translation lacks.
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
  status := .derived
  note := "Proved: BimodalLib.derivableIn_boolean_of_box, from \
    BimodalLib.conservativeEdge_boolean. The proof collapses the temporal operators and reads \
    □ as the identity; every translated axiom is a propositional tautology."

/-- `Boolean` into `TemporalBoolean`: a propositional formula derivable with the temporal
operators is derivable without them. -/
def booleanIntoTemporalBoolean : Conjecture where
  statement := ∀ (fc : FrameClass) (φ : Formula), profileF φ ≤ {} →
    DerivableIn { temporal := true } fc φ → DerivableIn {} fc φ
  fragment := .TemporalBoolean
  ops := {}
  frameClass := none
  status := .derived
  note := "Proved: BimodalLib.derivableIn_boolean_of_temporal, from \
    BimodalLib.conservativeEdge_boolean. The proof collapses the temporal operators and reads \
    □ as the identity; every translated axiom is a propositional tautology."

/-- `ModalBoolean` with `□` into TM: a formula with `□` and no temporal operator that TM
derives is derivable without the temporal operators. -/
def modalBooleanIntoTM : Conjecture where
  statement := ∀ fc : FrameClass, ConservativeEdge { box := true } fc
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := none
  status := .derived
  note := "Proved: BimodalLib.conservativeEdge_box. The proof collapses the temporal \
    operators and keeps □; the translated axioms are instances of T, 5 and K, tautologies, or \
    follow from a tautology by necessitation and K. No completeness theorem for S5 is used."

/-- `TemporalBoolean` into TM at the base class: a formula with no `□` that TM derives is
derivable without `□`. -/
def temporalBooleanIntoTMBase : Conjecture where
  statement := ConservativeEdge { temporal := true } .Base
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .Base
  status := .refuted
  note := "Refuted: BimodalLib.not_conservativeEdge_temporal_base. The full system \
    derives X⊤ → G X⊤ at the base class through □, and the temporal cell is sound for every \
    linear order without endpoints, among them the integers followed by the rationals, where \
    that formula fails. The repaired edge is temporalBooleanUniformIntoTMBase."

/-- `TemporalBoolean` into TM at the dense class. -/
def temporalBooleanIntoTMDense : Conjecture where
  statement := ConservativeEdge { temporal := true } .Dense
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .Dense
  status := .unsettled
  note := "The translation that proves this edge reads □ as always. It needs the S5 laws \
    of always, the law always φ → always Gφ and replacement of provable equivalents, each \
    derived inside the temporal cell at this class. None is derived in the tree. No \
    completeness theorem is needed."

/-- `TemporalBoolean` into TM at the integer-time class. -/
def temporalBooleanIntoTMZTime : Conjecture where
  statement := ConservativeEdge { temporal := true } .ZTime
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .ZTime
  status := .unsettled
  note := "The translation that proves this edge reads □ as always. It needs the S5 laws \
    of always, the law always φ → always Gφ and replacement of provable equivalents, each \
    derived inside the temporal cell at this class. None is derived in the tree. No \
    completeness theorem is needed."

/-- `TemporalBoolean` into TM at the Dedekind-complete class. -/
def temporalBooleanIntoTMRTime : Conjecture where
  statement := ConservativeEdge { temporal := true } .RTime
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .RTime
  status := .unsettled
  note := "The translation that proves this edge reads □ as always. It needs the S5 laws \
    of always, the law always φ → always Gφ and replacement of provable equivalents, each \
    derived inside the temporal cell at this class. None is derived in the tree. No \
    completeness theorem is needed."

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
  status := .derived
  note := "Proved: BimodalLib.derivableIn_box_of_derivableInP, from the edge from L \
    into L⁺ (plusDerivable_ofFormula_iff) and BimodalLib.conservativeEdge_box. The temporal \
    edges are not used."

/-- `TemporalBoolean` with the uniformity of discreteness as a hypothesis, into TM at the base
class: the repair of the refuted edge `temporalBooleanIntoTMBase`. -/
def temporalBooleanUniformIntoTMBase : Conjecture where
  statement := ∀ φ : Formula, profileF φ ≤ { temporal := true } →
    Nonempty (DerivationTree FrameClass.Base [] φ) →
    DerivableIn { temporal := true } FrameClass.Base (Edges.discreteUniformity.imp φ)
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some .Base
  status := .unsettled
  note := "The cell is extended by a hypothesis and not by an axiom: the statement asks for a \
    derivation, within the temporal cell, of the implication from \
    BimodalLib.Edges.discreteUniformity to the formula. The hypothesis is always((X⊤ → always \
    X⊤) ∧ (Y⊤ → always Y⊤)). The past conjunct is stated because a hypothesis is not closed \
    under time reflection, and the rationals times the naturals in the lexicographic order \
    satisfy the future conjunct alone. Whether TM derives further temporal formulas through □ \
    that this hypothesis does not yield is not known."

end BimodalLib.Conjectures
