/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.PropDecide
import FormalSystem.Metalogic.Decidability.Propositional.Decidable

/-!
# Tests for `propDecide`

Exercises the reflective propositional tautology tactic on schematic and concrete goals,
across all four supported goal shapes (`⊢ φ`, `⊢[fc] φ`, `|-! φ`, `|-![fc] φ`), including
goals with opaque modal/temporal subterms (which only a schematic-`env` reflection argument
can close — a bare truth-table `decide` on `Formula` itself cannot).

Type-valued goals (`⊢ φ`, `⊢[fc] φ`, built on the `Type`-valued `DerivationTree`) are marked
`noncomputable example`, since the underlying Kalmar soundness proof (`deductionTheorem`) is
noncomputable; Prop-valued goals (`|-! φ`, `|-![fc] φ`, built on `Derivable`) need no such
marking since `Prop`-valued definitions are erased by the compiler.
-/

namespace BimodalTest.Metalogic.PropDecideTest

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Automation

/-! ## Schematic Goals (`⊢ φ`) -/

/-- K axiom skeleton. -/
noncomputable example (p q : Formula) : ⊢ p.imp (q.imp p) := by propDecide

/-- Peirce's law. -/
noncomputable example (p q : Formula) : ⊢ ((p.imp q).imp p).imp p := by propDecide

/-- Reductio-ad-absurdum skeleton: `A → (¬A → B)`. -/
noncomputable example (A B : Formula) : ⊢ A.imp (A.neg.imp B) := by propDecide

/-- Contrapositive-flavoured tautology, already in imp/bot form: `(¬A → ¬B) → (B → A)`. -/
noncomputable example (A B : Formula) : ⊢ (A.neg.imp B.neg).imp (B.imp A) := by propDecide

/-- De Morgan: `¬(A ∧ B) → (¬A ∨ ¬B)`. `and`/`or`/`neg`-shaped goals are in scope:
`PropDecide.reify` calls `whnf` on every subterm, which unfolds `Formula.and`/`Formula.or`/
`Formula.neg` into the `imp`/`bot` skeleton automatically, so no manual unfolding is needed. -/
noncomputable example (A B : Formula) : ⊢ (A.and B).neg.imp (A.neg.or B.neg) := by propDecide

/-- Distributivity, in the shape `BooleanStructure.le_sup_inf_quot` discharges:
`((A ∨ B) ∧ (A ∨ C)) → (A ∨ (B ∧ C))`. -/
noncomputable example (A B C : Formula) :
    ⊢ ((A.or B).and (A.or C)).imp (A.or (B.and C)) := by propDecide

/-- Modal K axiom's propositional skeleton, with `□A`/`□B` as opaque reified variables —
demonstrates the schematic-`env` reflection argument closing goals that a bare truth-table
`decide` on `Formula` cannot (since `□A`/`□B` are not literals). -/
noncomputable example (A : Formula) : ⊢ A.box.imp A.box := by propDecide

/-- Temporal `Until`/`Since` subterms as opaque reified variables. -/
noncomputable example (A B C D : Formula) :
    ⊢ (Formula.untl B A).imp ((Formula.snce D C).imp (Formula.untl B A)) := by propDecide

/-! ## Frame-Class-Indexed Goals (`⊢[fc] φ`) -/

noncomputable example (fc : FrameClass) (p q : Formula) : ⊢[fc] p.imp (q.imp p) := by
  propDecide

noncomputable example (fc : FrameClass) (A : Formula) : ⊢[fc] A.box.imp A.box := by propDecide

/-! ## Prop-Valued Goals (`|-! φ`) -/

example (p q : Formula) : |-! ((p.imp q).imp p).imp p := by propDecide

example (A B : Formula) : |-! A.imp (A.neg.imp B) := by propDecide

/-! ## Prop-Valued, Frame-Class-Indexed Goals (`|-![fc] φ`) -/

example (fc : FrameClass) (p q : Formula) : |-![fc] p.imp (q.imp p) := by propDecide

/-! ## Concrete (Atom-Only) Goals -/

noncomputable example : ⊢ (Formula.atom (Atom.mkBase "p")).imp
    ((Formula.atom (Atom.mkBase "q")).imp (Formula.atom (Atom.mkBase "p"))) := by
  propDecide

/-! ## `PropForm` tautologies (from `Propositional/PropForm.lean`)

Kernel-`decide` reducibility on closed `PropForm` terms — no `native_decide`. -/

section PropFormTautologies

open FormalSystem.Metalogic.Decidability.Propositional
open FormalSystem.Metalogic.Decidability.Propositional.PropForm

/-- Peirce's law: `((p → q) → p) → p`. -/
private def peirceForm : PropForm := imp (imp (imp (var 0) (var 1)) (var 0)) (var 0)

example : peirceForm.isTaut = true := by decide

/-- K axiom skeleton: `p → (q → p)`. -/
private def kForm : PropForm := imp (var 0) (imp (var 1) (var 0))

example : kForm.isTaut = true := by decide

/-- A 5-variable tautology (32 assignments): `p0 → (p1 → (p2 → (p3 → (p4 → p0))))`. -/
private def fiveVarForm : PropForm :=
  imp (var 0) (imp (var 1) (imp (var 2) (imp (var 3) (imp (var 4) (var 0)))))

example : fiveVarForm.isTaut = true := by decide

end PropFormTautologies

/-! ## Deciding derivability (from `Propositional/Decidable.lean`) -/

section DecidableDerivable

open FormalSystem.Metalogic.Decidability.Propositional
open FormalSystem.Semantics

private def pAtomEx : Formula := Formula.atom (Atom.mkBase "p")
private def qAtomEx : Formula := Formula.atom (Atom.mkBase "q")

/-- `instDecidableDerivable` decides the concrete tautology `p → p` as derivable. -/
example : |-! (pAtomEx.imp pAtomEx) := by
  have hp : isPropositional (pAtomEx.imp pAtomEx) = true := by decide
  have hd : |-! (pAtomEx.imp pAtomEx) := by
    have hraw := tautology_derivable (reify (pAtomEx.imp pAtomEx)).1 (by decide)
      (reify (pAtomEx.imp pAtomEx)).2
    rwa [reify_denote (pAtomEx.imp pAtomEx) hp] at hraw
  match instDecidableDerivable (pAtomEx.imp pAtomEx) hp with
  | isTrue h => exact h
  | isFalse hnd => exact absurd hd hnd

/-- `instDecidableDerivable` decides the concrete non-tautology `p → q` as underivable
(`isFalse`). -/
example : ¬ |-! (pAtomEx.imp qAtomEx) := by
  have hp : isPropositional (pAtomEx.imp qAtomEx) = true := by decide
  match instDecidableDerivable (pAtomEx.imp qAtomEx) hp with
  | isFalse hnd => exact hnd
  | isTrue hd =>
      have htaut := derivable_tautology (pAtomEx.imp qAtomEx) hp hd
      exact absurd htaut (by decide)

end DecidableDerivable

end BimodalTest.Metalogic.PropDecideTest
