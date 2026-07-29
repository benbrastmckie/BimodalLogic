/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# `boxNeg` does not preserve satisfiability — measured, on the branch that shows it

`Tests/BimodalTest/CrossWorldPropagationProbe.lean` measured **verdicts** and found them correct,
and it was explicit that this left the *proof* obligation open, "a step can spoil a satisfiable
branch while every branch it spoils is closable by some other route". This file measures the
step, and the answer is that the step is not sound: it maps a satisfiable branch to one that
closes outright.

## The branch

Row B of the verdict probe is `(G p) → □(G p)`, which is **invalid** — `Ω` may hold a history
with a `¬p` somewhere in the future while `τ` has none — and that probe's `false` is the correct
verdict. Negating it and applying `impNeg` gives the two-formula branch

```
T(G p)   @ (w₀, t₀)
F(□(G p)) @ (w₀, t₀)
```

which is therefore **satisfiable**: interpret `w₀` by a history where `p` holds at every later
time, in an `Ω` that also holds one where it does not.

## What the rule does to it

`applyRule .boxNeg` on the second formula mints `w₁` and emits exactly two formulas, both at the
single label `(w₁, t₀)`:

* the **witness** `F(G p)`, from `F(□(G p))`; and
* `T(G p)`, from `tempGProps` — the cross-modal-temporal copy of the `T(G·)` formulas standing at
  the source label's *time*, taken from **any** world.

They are the same formula at the same label with opposite signs. No choice of `hist` or `tv` can
satisfy both, since `SatAt` reads them as `TruthAt …` and `¬ TruthAt …` at one point. So the
successor is unsatisfiable while the branch was satisfiable, and

```
RuleSound carrierBase .boxNeg
```

as stated in `Verified/Decidable.lean` is **false**. `ruleSound_boxNeg` is not merely unproved;
it is not provable, and the same argument applies to `diamondPos`, whose `tempGProps` block is
identical.

## What this is *not*

It is **not** a claim that the engine decides wrongly, and the rows below pin that too: the
verdict on the very same formula is still `false`, the correct answer. The engine does not apply
`boxNeg` to this branch — `T(G p)` is itself an `imp`, so the propositional schedule reaches it
first — and the verdict probe's rows consequently do not exercise the copy in the engine's own
run, which is why they came back clean. No engine defect is claimed here and none is measured.

What is measured is that the *rule-level* preservation statement, quantified over arbitrary
branches as `RuleSound` quantifies it, is refuted. The consequence is for the shape of sub-phase
7.2's assembly, not for the engine: `∀ r ∈ allRulesForFC fc, RuleSound _ r` cannot be proved, and
the `allClosed → valid` direction needs `boxNeg`/`diamondPos` to carry a branch invariant strong
enough to exclude branches like this one — the schedule's own reachability being the obvious
candidate, since the engine never builds this successor.
-/

namespace BimodalTest.BoxNegPreservationProbe

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-- Probe atom `p`. -/
def p : Formula := .atom (Atom.mkBase "p")

/-- The satisfiable branch: `T(G p)` and `F(□(G p))` at one label. -/
def b0 : Branch :=
  [ SignedFormula.pos (Formula.allFuture p) { world := 0, time := 0 }
  , SignedFormula.neg (Formula.box (Formula.allFuture p)) { world := 0, time := 0 } ]

/-- The `F(□(G p))` the rule fires on. -/
def src : SignedFormula :=
  SignedFormula.neg (Formula.box (Formula.allFuture p)) { world := 0, time := 0 }

/-- What `boxNeg` adds to the branch. -/
def emitted : List SignedFormula :=
  match (applyRule .boxNeg src b0 TimeOrdering.empty).1 with
  | .linear fs => fs
  | _ => []

/-! ### Row 1 — the rule is applicable and emits exactly two formulas -/
/-- info: 2 -/
#guard_msgs in
#eval emitted.length

/-! ### Row 2 — both sit at the freshly minted world, at the source time -/
/-- info: true -/
#guard_msgs in
#eval emitted.all fun sf => sf.label == { world := 1, time := 0 }

/-! ### Row 3 — the two carry the **same formula with opposite signs**

This is the measurement. A branch containing both is unsatisfiable outright, so the successor of
a satisfiable branch is unsatisfiable and `RuleSound carrierBase .boxNeg` is false. -/
/-- info: true -/
#guard_msgs in
#eval emitted.any fun a => emitted.any fun c =>
  a.formula == c.formula && a.label == c.label && a.sign == Sign.pos && c.sign == Sign.neg

/-! ### Row 4 — and the copied formula is the `T(G p)` that was standing at another world -/
/-- info: true -/
#guard_msgs in
#eval emitted.any fun a => a.sign == Sign.pos && a.formula == Formula.allFuture p

/-! ### Row 5 — the verdict is nevertheless correct, so no engine defect is claimed

The engine does not apply `boxNeg` to this branch. Kept beside the rows above so the distinction
between "the step is unsound" and "the procedure answers wrongly" stays pinned rather than
remembered. -/
/-- info: false -/
#guard_msgs in
#eval isValid ((Formula.allFuture p).imp ((Formula.allFuture p).box))

end BimodalTest.BoxNegPreservationProbe
