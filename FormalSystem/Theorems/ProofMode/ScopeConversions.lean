/-
Copyright (c) 2026 Tanner Duve. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Tanner Duve
-/

import FormalSystem.Theorems.ProofMode.Congruence
import FormalSystem.Theorems.Perpetuity.Helpers

/-!
# Closed scope conversions for checked rewriting

These are the small, explicit TM⁺ adapters consumed by the finite scope resolver. TM uses
the original source declarations directly. No mixed-word scope search or semantic extraction
is hidden in these functions.
-/

namespace FormalSystem.PlusLanguage.ProofMode

open FormalSystem.Syntax FormalSystem.ProofSystem

variable {fc : FrameClass}

private def atom : Formula := .atom (Atom.mkFresh "" 0)

/-- A boxed guarantee is valid at every strictly future point. -/
def boxToFuture (A : PlusFormula) : PlusDerivationTree fc [] (A.box.imp A.allFuture) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.Perpetuity.boxToFuture atom)

/-- A boxed guarantee is valid at every strictly past point. -/
def boxToPast (A : PlusFormula) : PlusDerivationTree fc [] (A.box.imp A.allPast) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.Perpetuity.boxToPast atom)

/-- Positive introspection for an opaque boxed guarantee. -/
def boxIteration (A : PlusFormula) : PlusDerivationTree fc [] (A.box.imp A.box.box) :=
  .ofTMSubst (fun _ => A) (FormalSystem.ProofSystem.DerivedAxioms.modal4 atom)

/-- Transitivity retains a universal future guarantee after advancing in time. -/
def futureIteration (A : PlusFormula) :
    PlusDerivationTree fc [] (A.allFuture.imp A.allFuture.allFuture) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.TemporalDerived.gTransitivity atom)

/-- The past mirror of future persistence. -/
def pastIteration (A : PlusFormula) :
    PlusDerivationTree fc [] (A.allPast.imp A.allPast.allPast) :=
  .ofTMSubst (fun _ => A) (FormalSystem.Theorems.TemporalDerived.hTransitivity atom)

/-- Necessity implies stability at the present state. -/
def boxToStability (A : PlusFormula) : PlusDerivationTree fc [] (A.box.imp (.stab A)) :=
  .axiom [] _ (.box_stab A) (FrameClass.base_le fc)

end FormalSystem.PlusLanguage.ProofMode
