/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# Is the `boxNeg` counterexample branch REACHABLE by the engine's own schedule?

`Tests/BimodalTest/BoxNegPreservationProbe.lean` measured that `applyRule .boxNeg` maps the
satisfiable branch `T(G p) @ (w₀,t₀)`, `F(□(G p)) @ (w₀,t₀)` to an unsatisfiable one, refuting
`RuleSound carrierBase .boxNeg` as stated. That left one question open, and the whole shape of
sub-phase 7.2's assembly turns on it: **does the engine ever present such a branch to `boxNeg`?**

The standing answer was "no — `T(G p)` is an `imp`, and the propositional rules are scheduled
first, so an undecomposed `T(G p)` never stands beside `F(□(G p))` when `boxNeg` fires." That
answer makes a prediction this file tests, and it rests on two claims that are measured here
separately:

1. that the propositional rules precede `boxNeg` in the schedule; and
2. that decomposing `T(G p)` removes it from the branch.

Both claims are measured false below, and a third thing is measured that was not in question.

Claim 1 is false of the *branching* propositional rules: `allRules` schedules `boxNeg` ahead of
`impPos`, `andNeg` and `orPos` (rows 2-3). Claim 2 is false outright: `applyRule`'s `.linear`
output is read by `expandOnceUnblocked` as `formulas ++ b`, so expansion is **additive** and the
source formula stays on the branch (row 4); and `boxNeg`'s `tempGProps` block reads
`branch.allFuturePosAtTime`, a **shape** filter over the branch list that is indifferent to
whether a formula has been expanded. So when `boxNeg` fires, the copy fires with it — and it does
fire, on `b0` itself, under the engine's own selector (rows 5-6).

## The consequence, which is larger than the reachability question

Because the counterexample branch is reachable, the branch closes (rows 7-8, on the clash and not
on a negated axiom), and `buildTableau` returns `allClosed` for `(G p) → □(G p)` (row 9) — a
formula that is **invalid**: `box φ` is `∀ σ ∈ Ω, TruthAt … σ t φ`, quantifying over admissible
histories at the fixed time, while `G p` is evaluated along `τ` alone, so an `Ω` holding one
history with `p` throughout the future and one without refutes it. The tableau reports a valid
formula where there is none.

`Tests/BimodalTest/BoxNegPreservationProbe.lean` read `isValid ((G p) → □(G p)) = false` as the
*correct verdict on an invalid formula* and concluded on that basis that "no engine defect is
claimed here and none is measured". Rows 10-12 measure what that `false` is:
`decide` returns **`extractionFailed`** — the tableau closed and proof extraction then failed —
with `isInvalid = false` and `getCountermodel? = none`. `isValid`'s `false` conflates "judged
invalid" with "claimed valid, then could not produce the proof", and only the second happened.

So the reachability escape is closed: there is no branch invariant that admits what the engine
builds and excludes the refuting branch, because they are the same branch.
-/

namespace BimodalTest.BoxNegReachabilityProbe

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-- Probe atom `p`. -/
def p : Formula := .atom (Atom.mkBase "p")

/-- `G p` — the temporal universal the `tempGProps` block copies across worlds. -/
def gp : Formula := Formula.allFuture p

/-- The satisfiable branch of the refutation probe. -/
def b0 : Branch :=
  [ SignedFormula.pos gp { world := 0, time := 0 }
  , SignedFormula.neg (Formula.box gp) { world := 0, time := 0 } ]

/-! ## Part 1 — the schedule claim

`allRules` is consulted in order by `findApplicableRule`. -/

/-- Position of a rule in the base schedule, or `999` if absent. -/
def rulePos (r : TableauRule) : Nat :=
  match allRules.findIdx? (fun s => s == r) with
  | some i => i
  | none => 999

/-! ### Row 1 — `negPos` (the rule that decomposes `T(G p)`, since `G p` is a negation)
does precede `boxNeg`. -/
/-- info: true -/
#guard_msgs in
#eval rulePos .negPos < rulePos .boxNeg

/-! ### Row 2 — but `impPos`, the *branching* propositional rule, does **not**.

`boxNeg` is scheduled ahead of `impPos`, `andNeg` and `orPos`. So "the propositional rules are
scheduled first" is true only of the non-branching ones. -/
/-- info: true -/
#guard_msgs in
#eval rulePos .boxNeg < rulePos .impPos

/-! ### Row 3 — and `allFuturePos`, the rule that would consume `T(G p)` as a temporal
universal, is scheduled *after* `boxNeg` as well. -/
/-- info: true -/
#guard_msgs in
#eval rulePos .boxNeg < rulePos .allFuturePos

/-! ## Part 2 — expansion is additive, so the source survives its own decomposition -/

/-- One unblocked expansion step, keeping every resulting branch. -/
def step (bo : Branch × TimeOrdering) : List (Branch × TimeOrdering) :=
  match expandOnceUnblocked bo.1 bo.2 .Base with
  | (.saturated, o) => [(bo.1, o)]
  | (.extended b', o) => [(b', o)]
  | (.split bs, o) => bs.map fun b' => (b', o)
  | (.splitOrdered ps, _) => ps

/-- Run `n` expansion rounds, **retaining** closed branches rather than dropping them: a closed
branch is still a branch the engine built, and it is exactly the branches the schedule reaches
that this file is measuring. -/
def run : Nat → List (Branch × TimeOrdering) → List (Branch × TimeOrdering)
  | 0, bs => bs
  | n + 1, bs =>
      run n (bs.flatMap fun bo => if isClosed bo.1 .Base then [bo] else step bo)

/-- The branches reachable from `b0` within 12 rounds. -/
def reached : List (Branch × TimeOrdering) := run 12 [(b0, TimeOrdering.empty)]

/-! ### Row 4 — `T(G p)` is still on every reached branch.

Expansion is `formulas ++ b`; nothing is ever removed. This refutes claim 2 directly. -/
/-- info: true -/
#guard_msgs in
#eval reached.all fun bo => bo.1.contains (SignedFormula.pos gp { world := 0, time := 0 })

/-! ## Part 3 — the decisive row: is `boxNeg`'s copy actually exercised?

`boxNeg` mints world `1` from `b0`. If the engine fires it while `T(G p)` stands at time `0`,
the fresh world receives `T(G p)` from `tempGProps` *and* `F(G p)` as the witness. -/

/-- Does this branch carry both signs of `G p` at the minted world? -/
def clashAtFreshWorld (b : Branch) : Bool :=
  b.contains (SignedFormula.pos gp { world := 1, time := 0 })
    && b.contains (SignedFormula.neg gp { world := 1, time := 0 })

/-! ### Row 5 — `boxNeg` **does** fire on the counterexample branch.

The witness `F(G p)` stands at the freshly minted world `1`. So the schedule presents `b0` to
`boxNeg` after all. -/
/-- info: true -/
#guard_msgs in
#eval reached.any fun bo => bo.1.contains (SignedFormula.neg gp { world := 1, time := 0 })

/-! ### Row 6 — and the `tempGProps` copy arrives beside it, producing the clash.

This is the refutation of the reachability claim. The branch the previous measurement showed to
be mapped from satisfiable to unsatisfiable is a branch the engine actually builds. -/
/-- info: true -/
#guard_msgs in
#eval reached.any fun bo => clashAtFreshWorld bo.1

/-! ### Row 7 — every reached branch is closed, and none is open. -/
/-- info: (1, 0) -/
#guard_msgs in
#eval (reached.length, (reached.filter fun bo => !isClosed bo.1 .Base).length)

/-! ### Row 8 — and the closure reason is the clash itself, not a negated axiom.

`1` tags `contradiction`, `2` tags `botPos`, `3` tags `axiomNeg`. The label reported is the
minted world, at the source time. -/
/-- info: some (1, 1, 0) -/
#guard_msgs in
#eval (reached.head?.bind fun bo => findClosure bo.1 .Base).map fun cr =>
        match cr with
        | .contradiction _ l => (1, l.world, l.time)
        | .botPos l => (2, l.world, l.time)
        | .axiomNeg _ _ l => (3, l.world, l.time)

/-! ## Part 4 — what the engine therefore answers, and what the earlier reading of it missed

The previous probe recorded `isValid ((G p) → □(G p)) = false` and read it as *the correct
verdict on an invalid formula*, concluding that no engine defect was in evidence. The rows below
measure what that `false` actually is. -/

/-! ### Row 9 — the real driver, on the real initial branch, returns `allClosed`.

`1` tags `.allClosed`, `2` tags `.hasOpen`, `0` tags fuel exhaustion; the second component is the
branch count. The tableau closes — i.e. it reports the formula **valid**. -/
/-- info: (1, 1) -/
#guard_msgs in
#eval match buildTableau (gp.imp gp.box) 1000 .Base with
      | none => (0, 0)
      | some (.allClosed bs) => (1, bs.length)
      | some (.hasOpen ob _ _ _) => (2, ob.length)

/-! ### Row 10 — so `isValid`'s `false` is **not** an `invalid` verdict.

The tuple is `(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)`. `decide`
closes the tableau and then fails to extract a proof term, and `isValid` reports that as `false`.
The engine never judged the formula invalid. -/
/-- info: (false, false, false, true, false) -/
#guard_msgs in
#eval let r := decide (gp.imp gp.box)
      (r.isValid, r.isInvalid, r.isFuelExhausted, r.isExtractionFailed, r.isUndecided)

/-! ### Row 11 — and no countermodel was ever produced. -/
/-- info: false -/
#guard_msgs in
#eval (decide (gp.imp gp.box)).getCountermodel?.isSome

/-! ### Row 12 — `isValid` reports `false`, the value the earlier reading rested on.

Kept last, immediately after the rows that say what it means, so the two can never again be read
apart: this `false` is row 10's `extractionFailed`, not a countermodel. -/
/-- info: false -/
#guard_msgs in
#eval isValid (gp.imp gp.box)

end BimodalTest.BoxNegReachabilityProbe
