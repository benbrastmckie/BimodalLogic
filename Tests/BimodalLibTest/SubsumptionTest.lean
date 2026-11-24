/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import BimodalLib.Subsumption
import BimodalLib.Theorems.ModalTemporalBoolean.Base

/-!
# Tests of the subsumption matcher

Four classes, in both directions:

* **positive** — a concrete instance is recognized as an instance of its schema;
* **negative** — a non-instance is refused, asserted as `false` rather than merely absent;
* **repeated-variable agreement** — a schema variable occurring twice must meet the same
  subformula both times, which is the one case a careless matcher gets wrong by overwriting
  the earlier binding instead of failing;
* **reflexive** — every schema is an instance of itself.

The witness assignment is checked too, not only the `Bool`: a matcher that returned `some`
with a wrong assignment would pass an `isSubstInstance` test alone.
-/

namespace BimodalLibTest.SubsumptionTest

open FormalSystem.Syntax FormalSystem.ProofSystem BimodalLib

/-! ### Fixtures

`A` and `B` are schema variables, spelled as `schemaVar` is so the tests range over exactly the
formulas a registry row's `stmt schemaVar` produces. `p` is an ordinary atom, distinct from both.
-/

/-- The first schema variable. -/
def A : Formula := schemaVar 0

/-- The second schema variable. -/
def B : Formula := schemaVar 1

/-- An ordinary atom, distinct from every schema variable. -/
def p : Formula := .atom (Atom.mkBase "p")

/-! ### Positive cases -/

/-- `□⊥ → ⊥` is a substitution instance of `□A → A`. -/
example : isSubstInstance (A.box.imp A) (Formula.bot.box.imp .bot) = true := by decide

/-- The witness is the assignment that actually produces the target. -/
example :
    matchSubst? (A.box.imp A) (Formula.bot.box.imp .bot)
      = some [(Atom.mkFresh "p" 0, Formula.bot)] := by decide

/-- Substituting the witness back reproduces the target, which is the property the ADMIT stage
relies on. -/
example :
    substF (assignmentOf [(Atom.mkFresh "p" 0, Formula.bot)]) (A.box.imp A)
      = Formula.bot.box.imp .bot := by decide

/-- A two-variable schema at two different instances. -/
example : isSubstInstance (A.imp B) (Formula.bot.imp p) = true := by decide

/-- A schema variable matches an arbitrarily large subformula, not only an atom. -/
example : isSubstInstance (A.box) ((Formula.untl p p).box) = true := by decide

/-- The temporal constructors match head to head. -/
example : isSubstInstance (.untl A B) (.untl .bot p) = true := by decide

/-- `.snce` matches `.snce` and nothing else. -/
example : isSubstInstance (.snce A B) (.snce .bot p) = true := by decide

/-! ### Negative cases

Each is asserted `false`. A matcher that silently returned `true` here would admit a row as
subsumed by a schema that does not in fact cover it.
-/

/-- `□⊥ → p` is **not** an instance of `⊥ → A`: the antecedents' heads differ. -/
example : isSubstInstance (Formula.bot.imp A) (Formula.bot.box.imp p) = false := by decide

/-- `.untl` is not an instance of `.snce`. -/
example : isSubstInstance (.snce A B) (.untl .bot p) = false := by decide

/-- **Every** atom of the schema is a substitution target, not only the schema variables.
`substF σ` is defined on the `atom` constructor, so `p → A` is matched by the σ sending both
`p` and `A` to `⊥`. This is uniform substitution's own semantics and is what the ADMIT stage
needs; a matcher that privileged `schemaVar` atoms over ordinary ones would disagree with
`substF` and so with `TheoremEntry.profile_eq`. -/
example : isSubstInstance (p.imp A) (Formula.bot.imp .bot) = true := by decide

/-- A box in the schema needs a box in the target. -/
example : isSubstInstance A.box (Formula.bot.imp .bot) = false := by decide

/-- Nothing is an instance of a strictly larger schema. -/
example : isSubstInstance (A.imp B) Formula.bot = false := by decide

/-! ### The repeated-variable agreement case -/

/-- `A → A` matches `⊥ → ⊥`: the recurring variable meets the same subformula twice. -/
example : isSubstInstance (A.imp A) (Formula.bot.imp .bot) = true := by decide

/-- `A → A` does **not** match `⊥ → p`: the recurring variable is offered two different
subformulas, and the matcher must fail rather than overwrite the first binding. -/
example : isSubstInstance (A.imp A) (Formula.bot.imp p) = false := by decide

/-- The agreement check binds the variable once, not twice. -/
example :
    matchSubst? (A.imp A) (Formula.bot.imp .bot)
      = some [(Atom.mkFresh "p" 0, Formula.bot)] := by decide

/-- Agreement holds at a compound subformula too, not only at `⊥`. -/
example : isSubstInstance (A.imp A) ((p.box).imp (p.box)) = true := by decide

/-- And fails when the two compound subformulas differ. -/
example : isSubstInstance (A.imp A) ((p.box).imp (p.box.box)) = false := by decide

/-- Three occurrences all have to agree. -/
example : isSubstInstance (A.imp (A.imp A)) (Formula.bot.imp (Formula.bot.imp .bot)) = true := by
  decide

/-- One disagreeing occurrence out of three is enough to fail. -/
example : isSubstInstance (A.imp (A.imp A)) (Formula.bot.imp (Formula.bot.imp p)) = false := by
  decide

/-! ### The reflexive case -/

/-- Every schema is an instance of itself. -/
example : isSubstInstance (A.box.imp A) (A.box.imp A) = true := by decide
example : isSubstInstance (A.imp B) (A.imp B) = true := by decide
example : isSubstInstance (.untl A B) (.untl A B) = true := by decide
example : isSubstInstance Formula.bot Formula.bot = true := by decide

/-! ### Asymmetry

Subsumption is directional. The strictly more general schema subsumes the instance and not
conversely, which is what makes `assert_no_subsumed_entries`' one-sided test meaningful.
-/

example : isSubstInstance (A.box.imp A) (Formula.bot.box.imp .bot) = true := by decide
example : isSubstInstance (Formula.bot.box.imp .bot) (A.box.imp A) = false := by decide

/-! ### The build-time non-redundancy check

The command is run over the rows of one theorem module, imported the way every other test in
this directory imports its rows. The `BimodalLib` root cannot be imported here: it registers
`FormalSystem.Theorems.Combinators.identity`, which `BimodalLibTest.ProofFragmentTest` also
registers as a fixture, and the test library root then fails to import both.
-/

/-! The scoped form, over the prefix the enumerated pipeline will register under. It holds no
rows yet, so the command passes and will start guarding the moment the first generated entry
lands. The 29 rows it compares against are those of the one theorem module imported above. -/

/--
info: compared 0 candidate row(s) against 29 row(s) of 29 for subsumption
-/
#guard_msgs in
assert_no_subsumed_entries BimodalLib.Theorems.Enumerated

/-! ### Positive control: the command does catch a real subsumption

The scoped run above is vacuous on an empty prefix, so on its own it would pass even if the
matcher were broken. These two `#guard`s check the matcher against a pair of **live registry
statements** that genuinely stand in the subsumption relation, so the green run above is backed
by evidence that the predicate it uses is not trivially false.

`Combinators.topThm : ⊤` is `Combinators.identity` at `⊥` — the library proves it that way, its
body being literally `identity Formula.bot` — and `⊤` unfolds to `⊥ → ⊥`.
-/

example : isSubstInstance (A.imp A) Formula.top = true := by decide
example : isSubstInstance Formula.top (A.imp A) = false := by decide

/-- `Propositional.em : A ∨ ¬A` unfolds to `(A → ⊥) → (A → ⊥)`, also an instance of `A → A`. -/
example : isSubstInstance (A.imp A) (Formula.or A A.neg) = true := by decide

/-!
### Why the unscoped form is not asserted here

`assert_no_subsumed_entries` with no prefix reports **26 of the 190** live rows as substitution
instances of another row. That is a property of the library, not a defect of the matcher: the two
cases pinned just above are among the 26, and the first of them is witnessed by the registered
declaration's own proof term. Asserting the unscoped form green would require either dropping
26 hand-curated named laws or baselining them, and which of those is right is a design question
outside this test's remit. The unscoped form is therefore exercised nowhere in the build, and
nothing in `BimodalLib/Theorems/Complete.lean` invokes it.
-/

end BimodalLibTest.SubsumptionTest
