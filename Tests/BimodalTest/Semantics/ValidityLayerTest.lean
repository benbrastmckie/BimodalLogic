/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TruthClauses
import FormalSystem.Semantics.StarLanguage.StarValidity
import FormalSystem.Semantics.MinusLanguage.MinusValidity

/-!
# The abstract validity layer: definitional-coincidence regressions

`FormalSystem/Semantics/ValidityLayer.lean` writes the validity layer once against the class
`PointTruth`, and each object language then instantiates it and delegates its own theorem bodies
to the generic ones. The delegation is only statement-preserving because each per-language
validity `def` is **definitionally equal** to the generic one at that language's instance — a
`rfl`, not a proved biconditional.

That defeq is the load-bearing fact of the whole refactor, and nothing in the library states it:
the per-language `def`s are deliberately left with their original bodies (their reducibility and
`unfold`/`simp` behaviour is depended on at hundreds of downstream sites), so no library theorem
ever needs to mention the coincidence. This file is where it is pinned, so that a later edit to
either side turns a test red instead of silently making the two layers diverge.

## What is measured here

Every check is a compiler check, not an assertion: an `example ... := rfl` that fails to
elaborate is a build failure.

- The four validity coincidences for each object language, populated as each language is
  instantiated.
- A toy fifth language, exercising the extension contract end to end: the minimum a new language
  must supply in order to inherit the layer.

## References

* `FormalSystem/Semantics/ValidityLayer.lean` — the layer and its extension contract
-/

namespace BimodalTest.Semantics.ValidityLayerTest

open FormalSystem FormalSystem.Semantics

/-! ## Smoke check: the generic layer elaborates -/

section Smoke
variable {L : Type} [PointTruth L]

example (F : TaskFrame) (φ : L) : Prop := TaskFrame.GenericValidOn F φ
example (P : TaskFrame → Prop) (φ : L) : Prop := GenericValidOnFrames P φ
example (fc : ProofSystem.FrameClass) (φ : L) : Prop := GenericValidIn fc φ
example (φ : L) : Prop := GenericValid φ

end Smoke

/-! ## The validity coincidences, one group per object language

Each group is the load-bearing defeq that makes that language's delegating wrappers
statement-preserving. `rfl` and nothing else: if any of these ever needs a `show` or a `change`,
the corresponding instance is no longer the language's own validity relation. -/

section L
variable (F : TaskFrame) (P : TaskFrame → Prop) (fc : ProofSystem.FrameClass) (φ : Syntax.Formula)

example : TaskFrame.ValidOn F φ = TaskFrame.GenericValidOn F φ := rfl
example : ValidOnFrames P φ = GenericValidOnFrames P φ := rfl
example : ValidIn fc φ = GenericValidIn fc φ := rfl
example : Valid φ = GenericValid φ := rfl

end L

section LMinus
variable (F : TaskFrame) (P : TaskFrame → Prop) (fc : ProofSystem.FrameClass)
  (φ : MinusLanguage.MinusFormula)

example : TaskFrame.MinusValidOn F φ = TaskFrame.GenericValidOn F φ := rfl
example : MinusValidOnFrames P φ = GenericValidOnFrames P φ := rfl
example : MinusValidIn fc φ = GenericValidIn fc φ := rfl
example : MinusValid φ = GenericValid φ := rfl

end LMinus

section LPlus
variable (F : TaskFrame) (P : TaskFrame → Prop) (fc : ProofSystem.FrameClass)
  (φ : PlusLanguage.PlusFormula)

example : TaskFrame.PlusValidOn F φ = TaskFrame.GenericValidOn F φ := rfl
example : PlusValidOnFrames P φ = GenericValidOnFrames P φ := rfl
example : PlusValidIn fc φ = GenericValidIn fc φ := rfl
example : PlusValid φ = GenericValid φ := rfl

end LPlus

/-! ### L⋆ — the load-bearing case

`StarFormula`'s point is `(τ, x, v⃗)`, not `(τ, x)`. These four are the evidence that **one**
abstraction covers both shapes: the stored-time vector is the innermost binder everywhere, so
`∀ v` folds into the instance's `sat` field without disturbing any binder telescope. -/

section LStar
variable (F : TaskFrame) (P : TaskFrame → Prop) (fc : ProofSystem.FrameClass)
  (φ : StarLanguage.StarFormula)

example : TaskFrame.StarValidOn F φ = TaskFrame.GenericValidOn F φ := rfl
example : StarValidOnFrames P φ = GenericValidOnFrames P φ := rfl
example : StarValidIn fc φ = GenericValidIn fc φ := rfl
example : StarValid φ = GenericValid φ := rfl

end LStar

/-! ## The derived-operator coincidences, one group per object language

Each language's own derived-operator `def`s are the same Łukasiewicz/`untl` encodings as the
generic `abbrev`s of `Semantics/TruthClauses.lean`. That character-for-character agreement is
what lets the clause-lemma wrappers delegate without a `show`; nothing in the library states it,
so it is pinned here. -/

section LOperators
variable (φ ψ : Syntax.Formula)

example : Syntax.Formula.neg φ = TruthClauses.neg φ := rfl
example : (Syntax.Formula.top : Syntax.Formula) = TruthClauses.top := rfl
example : Syntax.Formula.and φ ψ = TruthClauses.and φ ψ := rfl
example : Syntax.Formula.or φ ψ = TruthClauses.or φ ψ := rfl
example : Syntax.Formula.diamond φ = TruthClauses.diamond φ := rfl
example : Syntax.Formula.someFuture φ = TruthClauses.someFuture φ := rfl
example : Syntax.Formula.somePast φ = TruthClauses.somePast φ := rfl
example : Syntax.Formula.allFuture φ = TruthClauses.allFuture φ := rfl
example : Syntax.Formula.allPast φ = TruthClauses.allPast φ := rfl
example : Syntax.Formula.always φ = TruthClauses.always φ := rfl

end LOperators

/-! ### L⁻ — the tense-primitive presentation

`allFuture`/`allPast` are **primitive** constructors in L⁻, so its existential tenses and its
`always` are the *primed* generic operators, derived in the opposite duality direction. These
four bridges are what make L⁻'s two existential-tense lemmas and its `always_iff` delegate. -/

section LMinusOperators
open MinusLanguage
variable (φ ψ : MinusFormula)

example : MinusFormula.neg φ = TruthClauses.neg φ := rfl
example : (MinusFormula.top : MinusFormula) = TruthClauses.top := rfl
example : MinusFormula.and φ ψ = TruthClauses.and φ ψ := rfl
example : MinusFormula.or φ ψ = TruthClauses.or φ ψ := rfl
example : MinusFormula.diamond φ = TruthClauses.diamond φ := rfl
example : MinusFormula.someFuture φ = TruthClauses.someFuture' φ := rfl
example : MinusFormula.somePast φ = TruthClauses.somePast' φ := rfl
example : MinusFormula.always φ = TruthClauses.always' φ := rfl

end LMinusOperators

section LPlusOperators
open PlusLanguage
variable (φ ψ : PlusFormula)

example : PlusFormula.neg φ = TruthClauses.neg φ := rfl
example : (PlusFormula.top : PlusFormula) = TruthClauses.top := rfl
example : PlusFormula.and φ ψ = TruthClauses.and φ ψ := rfl
example : PlusFormula.or φ ψ = TruthClauses.or φ ψ := rfl
example : PlusFormula.diamond φ = TruthClauses.diamond φ := rfl
example : PlusFormula.someFuture φ = TruthClauses.someFuture φ := rfl
example : PlusFormula.somePast φ = TruthClauses.somePast φ := rfl
example : PlusFormula.allFuture φ = TruthClauses.allFuture φ := rfl
example : PlusFormula.allPast φ = TruthClauses.allPast φ := rfl
example : PlusFormula.always φ = TruthClauses.always φ := rfl
example : PlusFormula.dstab φ = TruthClauses.dstab φ := rfl

end LPlusOperators

section LStarOperators
open StarLanguage
variable (φ ψ : StarFormula)

example : StarFormula.neg φ = TruthClauses.neg φ := rfl
example : (StarFormula.top : StarFormula) = TruthClauses.top := rfl
example : StarFormula.and φ ψ = TruthClauses.and φ ψ := rfl
example : StarFormula.or φ ψ = TruthClauses.or φ ψ := rfl
example : StarFormula.diamond φ = TruthClauses.diamond φ := rfl
example : StarFormula.someFuture φ = TruthClauses.someFuture φ := rfl
example : StarFormula.somePast φ = TruthClauses.somePast φ := rfl
example : StarFormula.allFuture φ = TruthClauses.allFuture φ := rfl
example : StarFormula.allPast φ = TruthClauses.allPast φ := rfl
example : StarFormula.always φ = TruthClauses.always φ := rfl
example : StarFormula.dstab φ = TruthClauses.dstab φ := rfl

end LStarOperators

/-! ## A toy fifth language: the extension contract, exercised end to end

The deliverable that pays for the refactor is the contract in the two modules' `## Design
Invariants` sections: *exactly what a fifth object language must supply in order to inherit the
validity layer for free*. This section is that claim, checked rather than asserted — a minimal
language declared here in the test tree, with nothing but the instances the contract names, and
`example`s that the inherited names elaborate at it.

`Toy` deliberately has **only** `atom`/`bot`/`imp`/`box`: no temporal operators at all. That makes
it a check of the tiering as well as of the contract — it takes the Boolean tier and nothing else,
and is not required to supply `untl`, `snce` or the tenses in order to get it. -/

namespace FifthLanguage

open FormalSystem FormalSystem.Semantics

/-- A minimal fifth object language: propositional atoms, falsum, implication, and the modal box.
No temporal operators, so it exercises the Boolean tier alone. -/
inductive Toy where
  /-- A propositional atom. -/
  | atom : Syntax.Atom → Toy
  /-- Falsum. -/
  | bot : Toy
  /-- Material implication. -/
  | imp : Toy → Toy → Toy
  /-- The modal box. -/
  | box : Toy → Toy

/-- The truth recursion for `Toy`, with the same four clause shapes as every other language in
the tree. -/
def ToyTruthAt {F : TaskFrame} (M : TaskModel F) (τ : ConvexHistory F) (t : F.Duration) :
    Toy → Prop
  | .atom p => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | .bot => False
  | .imp φ ψ => ToyTruthAt M τ t φ → ToyTruthAt M τ t ψ
  | .box φ => ∀ (σ : ConvexHistory F), σ.IsTotal → ToyTruthAt M σ t φ

/-! ### Everything the contract asks for, and nothing else -/

/-- Obligation 1 of the validity-layer contract: one instance, one field. -/
instance : PointTruth Toy where
  sat M τ t φ := ToyTruthAt M τ t φ

/-- Obligation 1 of the clause-layer contract: the pointed relation with a trivial environment. -/
instance : TruthEnv Toy where
  Env _ := PUnit
  T M τ t _ φ := ToyTruthAt M τ t φ

/-- Obligation 2 of the clause-layer contract: the Boolean bundle, every clause field `Iff.rfl`
or `fun h => h` — which is the compiler confirming `ToyTruthAt` has the shared clause shapes. -/
instance : BoolClauses Toy where
  bot := Toy.bot
  imp := Toy.imp
  box := Toy.box
  bot_clause _ _ _ _ := fun h => h
  imp_clause _ _ _ _ _ _ := Iff.rfl
  box_clause _ _ _ _ _ := Iff.rfl

/-! ### What that bought

Every `example` below elaborates from the three instances above and nothing else. -/

section Inherited
variable (F : TaskFrame) (P : TaskFrame → Prop) (fc : ProofSystem.FrameClass)
  (M : TaskModel F) (τ : ConvexHistory F) (t : F.Duration) (φ ψ : Toy)

-- The four validity notions.
example : Prop := TaskFrame.GenericValidOn F φ
example : Prop := GenericValidOnFrames P φ
example : Prop := GenericValidIn fc φ
example : Prop := GenericValid φ

-- The bundled/unbundled bridge, both monotonicity lemmas, and a representative adapter from
-- each of the four families.
example : TaskFrame.GenericValidOn F φ ↔
    ∀ (M : TaskModel F) (τ : ConvexHistory F), τ.IsTotal →
      ∀ x : F.Duration, PointTruth.sat M τ x φ :=
  genericValidOn_iff_total F φ

example {Q : TaskFrame → Prop} (h : ∀ G, Q G → P G) (hP : GenericValidOnFrames P φ) :
    GenericValidOnFrames Q φ :=
  GenericValidOnFrames.mono h hP

example {fc₁ fc₂ : ProofSystem.FrameClass} (h : fc₁ ≤ fc₂) (hv : GenericValidIn fc₁ φ) :
    GenericValidIn fc₂ φ :=
  GenericValidIn.mono h hv

example (h : TaskFrame.GenericValidOn F φ) (hτ : τ.IsTotal) : PointTruth.sat M τ t φ :=
  TaskFrame.GenericValidOn.apply_total h M τ hτ t

example (h : GenericValidOnFrames P φ) (hF : P F) (hτ : τ.IsTotal) : PointTruth.sat M τ t φ :=
  GenericValidOnFrames.apply_total h F hF M τ hτ t

example (h : GenericValidIn fc φ) (hF : fc.Sat F) (hτ : τ.IsTotal) : PointTruth.sat M τ t φ :=
  GenericValidIn.apply_total h F hF M τ hτ t

example (h : GenericValid φ) (hτ : τ.IsTotal) : PointTruth.sat M τ t φ :=
  GenericValid.apply h F M τ hτ t

example (h : ¬ GenericValid φ) :
    ¬ ∀ (G : TaskFrame) (N : TaskModel G) (σ : ConvexHistory G), σ.IsTotal →
        ∀ x : G.Duration, PointTruth.sat N σ x φ :=
  GenericValid.of_not h

-- The whole Boolean clause tier, at the toy language's own truth relation.
example : ToyTruthAt M τ t (TruthClauses.neg φ) ↔ ¬ ToyTruthAt M τ t φ :=
  TruthClauses.neg_iff (L := Toy) M τ t PUnit.unit φ

example : ToyTruthAt M τ t (TruthClauses.top : Toy) :=
  TruthClauses.top_true (L := Toy) M τ t PUnit.unit

example : ToyTruthAt M τ t (TruthClauses.and φ ψ) ↔
    (ToyTruthAt M τ t φ ∧ ToyTruthAt M τ t ψ) :=
  TruthClauses.and_iff (L := Toy) M τ t PUnit.unit φ ψ

example : ToyTruthAt M τ t (TruthClauses.or φ ψ) ↔
    (ToyTruthAt M τ t φ ∨ ToyTruthAt M τ t ψ) :=
  TruthClauses.or_iff (L := Toy) M τ t PUnit.unit φ ψ

example : ToyTruthAt M τ t (TruthClauses.diamond φ) ↔
    ∃ σ : ConvexHistory F, σ.IsTotal ∧ ToyTruthAt M σ t φ :=
  TruthClauses.diamond_iff (L := Toy) M τ t PUnit.unit φ

end Inherited

end FifthLanguage

end BimodalTest.Semantics.ValidityLayerTest
