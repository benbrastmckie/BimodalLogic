/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.ValidityLayer
import BimodalLib.Fragment

/-!
# The countermodel registry

A countermodel is registered by declaring a constant: a definition of type
`BimodalLib.CountermodelEntry L` in a module under `BimodalLib/Countermodels/`, which the index
walk discovers. There is no registration command, because there is no declaration to read the
statement off: a theorem row cites a derivation and reads its statement from that declaration's
type, whereas a countermodel row's statement is the refuted *inference*, which the author
writes. What the kernel checks is the `refutation` field; what makes the filing computed rather
than asserted is `profile_eq`, closed by `rfl`.

The entry type is stated once, generically over `FormalSystem.Semantics.PointTruth`, and serves
both L and L⁺. That costs nothing at the statement side: `ValidIn fc φ` and `PlusValidIn fc φ`
are definitionally equal to `GenericValidIn fc φ`, so every refutation already in the tree is
admissible without restatement. The price is paid in meta-code only, where `evalExpr` is
monomorphic and an environment walk over entries needs one branch per language.

## Main definitions

* `BimodalLib.GenericConsequenceIn`: the premise-bearing consequence relation over
  `PointTruth`. This is what a countermodel entry refutes. `SemanticConsequenceIn` exists for
  `Formula` only, and L⁺ has no premise-bearing consequence predicate at all.
* `BimodalLib.HasProfile`: the profile computation of a library language, with instances for
  `Formula` and `PlusFormula`.
* `BimodalLib.inferenceProfile`: the joint profile of an inference — the premises joined onto
  the conclusion.
* `BimodalLib.Grade`: what stands behind a refutation. Three grades are admitted: `semantic`,
  `certificate` and `gatedTableau`.
* `BimodalLib.Grade.name`: the name of a grade, as the index prints it.
* `BimodalLib.CountermodelEntry`: a row. Its `refutation` field is what the kernel checks; its
  `profile_eq` field is closed by `rfl`, so the fragment is computed and not asserted.
* `BimodalLib.CountermodelEntry.fragment`, `BimodalLib.CountermodelEntry.cellName`: the
  fragment a row is filed in, and the name of its cell.

## Main statements

* `BimodalLib.genericConsequenceIn_nil`: at the empty premise list, generic consequence is
  generic validity. This is the bridge through which every `¬ Valid…`-shaped refutation already
  in the tree becomes an entry without restatement.

## Filing

A row is filed by the fragment of the refuted inference and by the **strongest** frame class at
which its model lives. The frame-class order is a tree and not a chain, so "strongest" is not
always unique and one inference may carry two maximal rows; the transfer theorem of
`BimodalLib/Countermodel/Transfer.lean` derives the weaker readings rather than registering
them.

## Tags

countermodel · refutation · theorem-library · frame-class
-/

namespace BimodalLib

open Lean
open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem
open FormalSystem.PlusLanguage

/-! ## A language-generic consequence relation -/

/--
`Γ ⊨_fc φ`, stated once over `PointTruth`: at every frame of the class `fc`, every model over
it, every world history and every time, the conclusion is true wherever all the premises are.

Stated generically because it is needed for both languages and exists for neither:
`SemanticConsequenceIn` is `Formula`-only, and L⁺ carries no premise-bearing consequence
predicate. The definition needs no implication on the language — the premises are discharged by
a list quantifier, not by an iterated `imp`.
-/
def GenericConsequenceIn {L : Type} [PointTruth L]
    (fc : FrameClass) (Γ : List L) (φ : L) : Prop :=
  ∀ F : TaskFrame, fc.Sat F → ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
    (∀ γ ∈ Γ, PointTruth.sat M τ t γ) → PointTruth.sat M τ t φ

/--
At the empty premise list, generic consequence is generic validity.

This is the bridge that admits the hand-built corpus: every landed refutation in the tree has
the `¬ Valid…` shape, and `ValidIn`/`PlusValidIn` are definitionally `GenericValidIn`, so a row
takes `fun h => <existing theorem> _ ((genericConsequenceIn_nil _ _).mp h)` as its refutation
and nothing is restated.
-/
theorem genericConsequenceIn_nil {L : Type} [PointTruth L] (fc : FrameClass) (φ : L) :
    GenericConsequenceIn fc ([] : List L) φ ↔ GenericValidIn fc φ := by
  unfold GenericConsequenceIn GenericValidIn GenericValidOnFrames TaskFrame.GenericValidOn
  exact ⟨fun h F hF M τ t => h F hF M τ t (by simp), fun h F hF M τ t _ => h F hF M τ t⟩

/-! ## The profile of a statement, per language -/

/-- The profile computation of a library language. One class, so that the entry type can be
stated once and still compute its own filing. -/
class HasProfile (L : Type) where
  /-- The primitive operators of a statement of the language. -/
  profile : L → Profile

/-- The base language computes its profile with `profileF`. -/
instance : HasProfile Formula := ⟨profileF⟩

/-- The extended language computes its profile with `profileP`. -/
instance : HasProfile PlusFormula := ⟨profileP⟩

/-- The joint profile of an inference: the profiles of the premises joined onto that of the
conclusion. An inference is filed by the operators occurring anywhere in it, premises
included. -/
def inferenceProfile {L : Type} [HasProfile L] (Γ : List L) (φ : L) : Profile :=
  Γ.foldr (fun γ acc => Profile.join (HasProfile.profile γ) acc) (HasProfile.profile φ)

/-! ## The grades -/

/--
What stands behind a refutation. Three grades are admitted.

A fourth grade, a refutation checked by the semantic evaluator against witnesses the caller
supplies, is anticipated and is deliberately absent: its client milestone and its design record
are not in the tree, so admitting the constructor now would advertise a route that does not
exist.

An ungated `invalid` verdict from a decision procedure is **not** a grade. It is registered as a
conjecture at `ConjectureStatus.heuristicallyRefuted` and never as an entry.
-/
inductive Grade
  /-- A Lean theorem that the inference is not valid, by an explicit model. -/
  | semantic
  /-- A finite certificate accepted by a proved checker: the witness-family checkers at
  `ZTime`. -/
  | certificate
  /-- An open saturated branch passing the gates, with the gate theorem applied. -/
  | gatedTableau
  deriving DecidableEq, Repr

/-- The name of a grade, as the index prints it. -/
def Grade.name : Grade → String
  | .semantic => "semantic"
  | .certificate => "certificate"
  | .gatedTableau => "gated tableau"

/-! ## The entry type -/

/--
A registered countermodel: an inference, the strongest frame class at which its model lives,
the grade of its refutation, and the refutation itself.

`refutation` is what the kernel checks, and `profile_eq` is what makes the fragment computed
rather than asserted — the two invariants the theorem half already states for `TheoremEntry`.
`model` names the model's declaration rather than packing it: every landed refutation in the
tree has the `¬ Valid…` shape, and converting one into a model-exhibiting existential needs
classical choice, which discards exactly the explicit model the conversion was for.
-/
structure CountermodelEntry (L : Type) [PointTruth L] [HasProfile L] where
  /-- The premises of the refuted inference. -/
  premises : List L
  /-- The conclusion of the refuted inference. -/
  conclusion : L
  /-- The strongest frame class at which the model lives. Because the frame-class order is a
  tree, this is not always unique, and one inference may carry two maximal rows. -/
  frameClass : FrameClass
  /-- What stands behind the refutation. -/
  grade : Grade
  /-- The refutation: the inference fails over the frames of `frameClass`. This is the field
  the kernel checks. -/
  refutation : ¬ GenericConsequenceIn frameClass premises conclusion
  /-- The primitive operators of the inference. -/
  profile : Profile
  /-- The profile is the computed one. Closed by `rfl`, so the filing is computed. -/
  profile_eq : inferenceProfile premises conclusion = profile
  /-- The declaration of the model the refutation's proof uses, where the proof names one. -/
  model : Option String := none
  /-- The declaration this refutation bounds, where it bounds one: the converse of a law, or a
  schema with its side condition dropped. -/
  nearMiss : Option Name := none
  /-- Where the inference is refuted, what the refutation bounds, and what it does not show. -/
  note : String := ""

/-- The fragment a countermodel row is filed in. -/
def CountermodelEntry.fragment {L : Type} [PointTruth L] [HasProfile L]
    (e : CountermodelEntry L) : Fragment := e.profile.fragment

/-- The name of the cell a countermodel row is filed in: its operators, as text. -/
def CountermodelEntry.cellName {L : Type} [PointTruth L] [HasProfile L]
    (e : CountermodelEntry L) : String := e.profile.cellName

end BimodalLib
