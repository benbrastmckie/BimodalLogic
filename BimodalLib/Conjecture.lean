/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Axioms
import BimodalLib.Fragment

/-!
# Conjectures

A conjecture is a statement that is registered and not established: neither derived nor
refuted. It is a definition of type `BimodalLib.Conjecture`, which holds the statement as a
`Prop` and has no field for a proof. A conjecture therefore cannot stand where a theorem is
required, and registering one leaves no proof obligation open and adds no axiom.

To register a conjecture, declare a constant of type `Conjecture` in a module under
`BimodalLib/Conjectures/`. The index lists every such constant.

The statement is a `Prop` and not a formula, because some conjectures are about derivability
and not derivable formulas themselves: the conservativity edges are. The fragment and operator
set of a conjecture are therefore declared by its author, where those of a theorem row are
computed.
-/

namespace BimodalLib

open FormalSystem.ProofSystem

/-- What is known about a conjecture. -/
inductive ConjectureStatus
  /-- Stated and neither derived nor refuted; no procedure has returned a verdict. -/
  | unsettled
  /-- A decision procedure returned a refutation that no theorem stands behind. -/
  | heuristicallyRefuted
  /-- A decision procedure ran out of fuel or failed to extract a certificate. -/
  | undetermined
  /-- Since derived. The registration is kept as the link from the question to the theorem
  entry that answers it, which the note names. -/
  | derived
  /-- Since refuted. The registration is kept as the link from the question to the
  countermodel entry that answers it, which the note names. -/
  | refuted
  deriving DecidableEq, Repr

/-- The name of a status, as the index prints it. -/
def ConjectureStatus.name : ConjectureStatus → String
  | .unsettled => "unsettled"
  | .heuristicallyRefuted => "heuristically refuted"
  | .undetermined => "undetermined"
  | .derived => "derived"
  | .refuted => "refuted"

/-- A registered conjecture: a statement with its filing and what is known about it. There is
no proof field. -/
structure Conjecture where
  /-- The conjectured statement. -/
  statement : Prop
  /-- The fragment the conjecture is filed in. -/
  fragment : Fragment
  /-- The operators the conjecture is about; with `fragment`, its cell. -/
  ops : Profile
  /-- The frame class the conjecture is stated at, where it is stated at one. -/
  frameClass : Option FrameClass
  /-- What is known. -/
  status : ConjectureStatus
  /-- Where the conjecture is stated, what was tried, and what it would settle. -/
  note : String

end BimodalLib
