/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.ProofSystem.Derivation
import FormalSystem.PlusLanguage.Derivation
import BimodalLib.Fragment

/-!
# Derivability inside a cell

Filing a statement at its smallest fragment claims that the larger logics prove nothing new
about it. To state that claim without a proof system per fragment, this module restricts the
derivations of the full systems: a derivation is **within** a cell when every formula it
derives has a profile included in the cell. The axiom instances and rule applications that stay
inside a cell are that cell's logic.

## Main definitions

* `BimodalLib.within`, `BimodalLib.withinP`: a derivation of the base system, or of the
  extended system, stays inside a cell.
* `BimodalLib.DerivableIn`, `BimodalLib.DerivableInP`: a formula has a closed derivation
  within a cell.
* `BimodalLib.ConservativeEdge`: the full base system proves nothing new about the formulas of
  a cell.

Nothing here is proved about these predicates. They are the vocabulary in which the
conservativity conjectures under `BimodalLib/Conjectures/` are stated.
-/

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

/-- The conclusion of a derivation of the base system. -/
def conclOf {fc : FrameClass} {Γ : Context} {φ : Formula} (_ : DerivationTree fc Γ φ) :
    Formula := φ

/-- Every formula derived in the derivation has a profile included in the cell `c`. -/
def within (c : Profile) {fc : FrameClass} :
    {Γ : Context} → {φ : Formula} → DerivationTree fc Γ φ → Prop
  | _, φ, .axiom _ _ _ _ => profileF φ ≤ c
  | _, φ, .assumption _ _ _ => profileF φ ≤ c
  | _, φ, .modus_ponens _ _ _ d1 d2 => profileF φ ≤ c ∧ within c d1 ∧ within c d2
  | _, _, e@(.necessitation _ d) => profileF (conclOf e) ≤ c ∧ within c d
  | _, _, e@(.temporal_necessitation _ d) => profileF (conclOf e) ≤ c ∧ within c d
  | _, _, e@(.time_reflection _ d) => profileF (conclOf e) ≤ c ∧ within c d
  | _, φ, .weakening _ _ _ d _ => profileF φ ≤ c ∧ within c d

/-- The formula has a closed derivation of the base system, at `fc`, within the cell `c`. -/
def DerivableIn (c : Profile) (fc : FrameClass) (φ : Formula) : Prop :=
  ∃ d : DerivationTree fc [] φ, within c d

/-- The conservativity edge from the cell `c` into the full base system at `fc`: a formula of
the cell that is derivable at all is derivable within the cell. -/
def ConservativeEdge (c : Profile) (fc : FrameClass) : Prop :=
  ∀ φ : Formula, profileF φ ≤ c → Nonempty (DerivationTree fc [] φ) → DerivableIn c fc φ

/-- The conclusion of a derivation of the extended system. -/
def conclOfP {fc : FrameClass} {Γ : PlusContext} {φ : PlusFormula}
    (_ : PlusDerivationTree fc Γ φ) : PlusFormula := φ

/-- Every formula derived in the derivation of the extended system has a profile included in
the cell `c`. -/
def withinP (c : Profile) {fc : FrameClass} :
    {Γ : PlusContext} → {φ : PlusFormula} → PlusDerivationTree fc Γ φ → Prop
  | _, φ, .axiom _ _ _ _ => profileP φ ≤ c
  | _, φ, .assumption _ _ _ => profileP φ ≤ c
  | _, φ, .modus_ponens _ _ _ d1 d2 => profileP φ ≤ c ∧ withinP c d1 ∧ withinP c d2
  | _, _, e@(.necessitation _ d) => profileP (conclOfP e) ≤ c ∧ withinP c d
  | _, _, e@(.temporal_necessitation _ d) => profileP (conclOfP e) ≤ c ∧ withinP c d
  | _, _, e@(.time_reflection _ d) => profileP (conclOfP e) ≤ c ∧ withinP c d
  | _, φ, .weakening _ _ _ d _ => profileP φ ≤ c ∧ withinP c d

/-- The formula has a closed derivation of the extended system, at `fc`, within the cell
`c`. -/
def DerivableInP (c : Profile) (fc : FrameClass) (φ : PlusFormula) : Prop :=
  ∃ d : PlusDerivationTree fc [] φ, withinP c d

end BimodalLib
