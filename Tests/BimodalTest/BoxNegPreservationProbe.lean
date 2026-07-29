/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# `boxNeg` **did not** preserve satisfiability — the defect, and its repair, both measured here

This file was written to refute `RuleSound carrierBase .boxNeg` by exhibiting a satisfiable
branch that `applyRule .boxNeg` mapped to an unsatisfiable one. It succeeded, the defect was
fixed by deleting the offending emission, and the rows below now pin the **repaired** behaviour.
Everything in the present tense below describes the engine as it stands; the defect is described
throughout in the past tense.

## The branch

Row B of `Tests/BimodalTest/CrossWorldPropagationProbe.lean` is `(G p) → □(G p)`, which is
**invalid** — `Ω` may hold a history with a `¬p` somewhere in the future while `τ` has none.
Negating it and applying `impNeg` gives the two-formula branch

```
T(G p)   @ (w₀, t₀)
F(□(G p)) @ (w₀, t₀)
```

which is therefore **satisfiable**: interpret `w₀` by a history where `p` holds at every later
time, in an `Ω` that also holds one where it does not.

## What the rule used to do to it — the defect

`applyRule .boxNeg` on the second formula minted `w₁` and emitted **two** formulas, both at the
single label `(w₁, t₀)`:

* the **witness** `F(G p)`, from `F(□(G p))`; and
* `T(G p)`, from `tempGProps` — a cross-modal-temporal copy of the `T(G·)` formulas standing at
  the source label's *time*, taken from **any** world.

They were the same formula at the same label with opposite signs. No choice of `hist` or `tv`
can satisfy both, since `SatAt` reads them as `TruthAt …` and `¬ TruthAt …` at one point. So the
successor was unsatisfiable while the branch was satisfiable, and

```
RuleSound carrierBase .boxNeg
```

as stated in `Verified/Decidable.lean` was **false**. The same argument applied to `diamondPos`,
whose `tempGProps` block was identical.

The copy conflated "true along the history being built" with "true at this instant along every
admissible history" — precisely the distinction `□`/`◇` quantify over — so it was unsound at the
source rather than merely inconvenient.

## The repair

The six group-3 `let` blocks in each of `.boxNeg` and `.diamondPos`
(`tempGProps`, `tempHProps`, `tempFNegProps`, `tempPNegProps`, `tempUNegProps`, `tempSNegProps`)
and their `temporalProps` assembly were deleted from
`FormalSystem/Metalogic/Decidability/Tableau.lean`. Each rule now emits
`.linear (witness :: boxProps ++ diaProps)`. Groups 1 (the existential witness) and 2
(`T(□B)`/`F(◇B)` propagation) are sound and were left byte-identical.

Rows 1, 3 and 4 below are the repair, measured. Row 3 in particular is the soundness defect
itself: it asked whether the rule manufactures a same-label opposite-sign pair, and the answer
is now `false`.

## What this file does *not* establish

The repair removes a wrong answer; it does not by itself supply a right one. On
`(G p) → □(G p)` the engine no longer closes the tableau — but within the fuel budgets measured
so far it does not positively refute the formula either, returning `.fuelExhausted` rather than
`.invalid`-with-countermodel. Row 5's `false` is therefore still not a verdict of "invalid";
what changed is that it is now honest ignorance rather than a failed extraction after a wrongly
closed tableau. See `Tests/BimodalTest/BoxNegReachabilityProbe.lean` rows 9-12, which pin the
`decide` constructor directly, and `Verified/Bridge/BoxSaturation.lean`'s `BoxAnchored` rationale
for the side condition the deletion costs.
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

/-! ### Row 1 — the rule is applicable and emits exactly **one** formula

Was `2` before the repair: the witness plus the `tempGProps` copy. It is now the witness alone,
which is the whole of what `.boxNeg` is entitled to emit — `boxProps` and `diaProps` are empty on
this branch, since `b0` carries no `T(□·)` and no `F(◇·)` besides the source. -/
/-- info: 1 -/
#guard_msgs in
#eval emitted.length

/-! ### Row 2 — it sits at the freshly minted world, at the source time.

Unmoved by the repair: the witness was always correctly labelled; it is the *company* it used to
keep that was wrong. -/
/-- info: true -/
#guard_msgs in
#eval emitted.all fun sf => sf.label == { world := 1, time := 0 }

/-! ### Row 3 — no two emitted formulas carry the **same formula with opposite signs**

This is the measurement, and this row is the soundness defect itself. It read `true` before the
repair: a branch containing both is unsatisfiable outright, so the successor of a satisfiable
branch was unsatisfiable and `RuleSound carrierBase .boxNeg` was false. It now reads `false` —
applying `.boxNeg` to this branch no longer manufactures a contradictory pair.

The assertion is deliberately unchanged; only its pinned value moved. -/
/-- info: false -/
#guard_msgs in
#eval emitted.any fun a => emitted.any fun c =>
  a.formula == c.formula && a.label == c.label && a.sign == Sign.pos && c.sign == Sign.neg

/-! ### Row 4 — and no `T(G p)` standing at another world is copied across

The mechanism behind row 3, isolated. `tempGProps` was the only route by which a `T(G·)` from
another world could reach the minted world; with it deleted there is none. Was `true`. -/
/-- info: false -/
#guard_msgs in
#eval emitted.any fun a => a.sign == Sign.pos && a.formula == Formula.allFuture p

/-! ### Row 5 — the verdict on the formula itself is still `false`

Unmoved in value, but no longer for the same reason. Before the repair this `false` was
`decide` returning `extractionFailed` after `buildTableau` wrongly **closed** the tableau on an
invalid formula. It is now `decide` returning `fuelExhausted`: the branch stays open and the
search runs out its budget. `isValid` is `true` only for `.valid`, so it cannot discriminate the
two — `BoxNegReachabilityProbe.lean` rows 9-12 pin the constructor. -/
/-- info: false -/
#guard_msgs in
#eval isValid ((Formula.allFuture p).imp ((Formula.allFuture p).box))

end BimodalTest.BoxNegPreservationProbe
