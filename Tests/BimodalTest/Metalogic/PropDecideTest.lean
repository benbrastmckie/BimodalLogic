/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Automation.Tactics.PropDecide

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

/-- De Morgan-style: `¬(A ∧ B) → (¬A ∨ ¬B)` unfolded to imp/bot skeleton via `and`/`or`/`neg`
definitional unfolding is out of scope for the pure imp/bot reflection skeleton (`and`/`or`
are themselves defined via `imp`/`neg`, so this reduces to an imp/bot tautology once
unfolded). Test the already-imp/bot-unfolded contrapositive-flavoured tautology instead. -/
noncomputable example (A B : Formula) : ⊢ (A.neg.imp B.neg).imp (B.imp A) := by propDecide

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

end BimodalTest.Metalogic.PropDecideTest
