/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity
import FormalSystem.PlusLanguage.PlusValidity
import BimodalLib.Countermodel
import BimodalLib.Subsumption

/-!
# Looking a refuted inference up, to renaming of atoms

An inference can be looked up in the countermodel library up to a renaming of its atoms. This
is the proof mode's entry point: where a tableau leaves a leaf unclosed, the leaf's inference is
looked up here, and a hit is **reported against the leaf** rather than used to discharge it.

## This never closes a goal

A hit says that a registered row refutes an inference that is a renaming of the leaf's. It is
information for the user and nothing more: the lookup returns a row, the caller prints it, and
no tactic state changes. A countermodel is not a proof of anything about the goal under
consideration, and the asymmetry is the point — a row can tell you why a branch stayed open, and
cannot tell you that your goal is false.

## Renaming is mutual substitution-instance

No new recursion is needed. `BimodalLib/Subsumption.lean`'s own header already records that
mutual instance-hood **is** renaming, so `sameUpToRenaming x y` is
`isSubstInstance x y && isSubstInstance y x`. The strictness is what makes it right: `p₀ → ⊥` is
a substitution instance of nothing stronger than itself in the second direction, so it does not
match `□p₀ → ⊥`, although the one-directional test does.

## The premise list is matched positionally, in order

An inference is folded into a single formula — `Γ.foldr .imp φ` — and the fold is matched as one
unit. That is what "a single consistent renaming" requires: the matcher threads **one**
assignment through the premises and the conclusion together, so a variable recurring across two
premises must meet the same subformula both times. The cost is that the premise list is matched
in order and not as a set: matching it as a set would require searching permutations, which this
module deliberately does not do.

For the rows landed today this distinction is moot, because every registered row has an empty
premise list and the fold degenerates to the conclusion. It will stop being moot as soon as a
row with premises is registered, which is why the behaviour is stated rather than left to be
discovered.

## Main definitions

* `BimodalLib.sameUpToRenaming`, `BimodalLib.sameUpToRenamingP`: the renaming test, over each
  language.
* `BimodalLib.inferenceAsFormula`, `BimodalLib.inferenceAsPlusFormula`: an inference folded into
  one formula, so that one assignment covers the whole of it.
* `BimodalLib.lookupCountermodel?`, `BimodalLib.lookupCountermodelP?`: the lookup entry point
  over a list of rows.

## Tags

countermodel · lookup · renaming · substitution · proof-mode
-/

namespace BimodalLib

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.PlusLanguage

/-! ## Renaming -/

/--
Whether two base-language formulas are the same up to a renaming of atoms: each is a
substitution instance of the other.

Mutual instance-hood is exactly renaming. A one-directional test would accept a strict instance
— `□p₀ → ⊥` is an instance of `p₀ → ⊥` — and a lookup that accepted strict instances would
report a row that refutes something more general than the inference asked about.
-/
def sameUpToRenaming (x y : Formula) : Bool :=
  isSubstInstance x y && isSubstInstance y x

/-- The same test over the extended language. -/
def sameUpToRenamingP (x y : PlusFormula) : Bool :=
  isSubstInstanceP x y && isSubstInstanceP y x

/-! ## An inference as one formula -/

/-- An inference folded into one formula, premises first: `γ₁ → ⋯ → γₙ → φ`. Matching the fold
rather than the parts is what makes a single assignment cover the whole inference. -/
def inferenceAsFormula (Γ : List Formula) (φ : Formula) : Formula := Γ.foldr .imp φ

/-- The same fold over the extended language. -/
def inferenceAsPlusFormula (Γ : List PlusFormula) (φ : PlusFormula) : PlusFormula :=
  Γ.foldr .imp φ

/-- Whether two base-language inferences are the same up to one consistent renaming of atoms. -/
def inferenceSameUpToRenaming (Γ₁ : List Formula) (φ₁ : Formula)
    (Γ₂ : List Formula) (φ₂ : Formula) : Bool :=
  sameUpToRenaming (inferenceAsFormula Γ₁ φ₁) (inferenceAsFormula Γ₂ φ₂)

/-- The same over the extended language. -/
def inferenceSameUpToRenamingP (Γ₁ : List PlusFormula) (φ₁ : PlusFormula)
    (Γ₂ : List PlusFormula) (φ₂ : PlusFormula) : Bool :=
  sameUpToRenamingP (inferenceAsPlusFormula Γ₁ φ₁) (inferenceAsPlusFormula Γ₂ φ₂)

/-! ## The lookup -/

/--
The first row of `entries` whose inference is the given one up to a renaming of atoms, or
`none`.

The caller supplies the rows. That is deliberate: the registry is the set of constants of the
entry type in the environment, which a compiled function cannot walk, so the environment walk
lives in the index's meta-code and the pure lookup takes its result as data.
-/
def lookupCountermodel? (entries : List (CountermodelEntry Formula))
    (Γ : List Formula) (φ : Formula) : Option (CountermodelEntry Formula) :=
  entries.find? fun e => inferenceSameUpToRenaming Γ φ e.premises e.conclusion

/-- The same lookup over the extended language. -/
def lookupCountermodelP? (entries : List (CountermodelEntry PlusFormula))
    (Γ : List PlusFormula) (φ : PlusFormula) : Option (CountermodelEntry PlusFormula) :=
  entries.find? fun e => inferenceSameUpToRenamingP Γ φ e.premises e.conclusion

/-- Whether the library, as supplied, refutes the given inference up to renaming. The `Bool`
face of the lookup, for a caller that only needs the verdict. -/
def isRefutedUpToRenaming (entries : List (CountermodelEntry Formula))
    (Γ : List Formula) (φ : Formula) : Bool :=
  (lookupCountermodel? entries Γ φ).isSome

end BimodalLib
