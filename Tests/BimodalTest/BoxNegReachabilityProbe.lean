/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# The `boxNeg` counterexample branch WAS reachable — and the copy that spoiled it is now gone

`Tests/BimodalTest/BoxNegPreservationProbe.lean` measured that `applyRule .boxNeg` mapped the
satisfiable branch `T(G p) @ (w₀,t₀)`, `F(□(G p)) @ (w₀,t₀)` to an unsatisfiable one, refuting
`RuleSound carrierBase .boxNeg` as stated. This file answered the question that left open —
**does the engine ever present such a branch to `boxNeg`?** — and the answer was yes. That
closed the last escape route, and the offending emission was subsequently deleted from the
engine.

**Everything below is written so the past tense describes the defect and the present tense
describes the engine as it now stands.** Rows 1-5 are unmoved by the repair; rows 6-10 moved,
and their movement is the repair measured from the reachability side.

## Part 1-2 — the schedule and additivity claims, both still false, both unmoved

The standing defence was "no — `T(G p)` is an `imp`, and the propositional rules are scheduled
first, so an undecomposed `T(G p)` never stands beside `F(□(G p))` when `boxNeg` fires." It
rested on two claims, and both are false independently of the repair:

1. **The schedule claim is false of the *branching* propositional rules.** `allRules` schedules
   `boxNeg` ahead of `impPos`, `andNeg` and `orPos` (rows 2-3), and ahead of `allFuturePos`
   (row 3).
2. **Expansion is additive, so decomposition removes nothing.** `applyRule`'s `.linear` output is
   read by `expandOnceUnblocked` as `formulas ++ b`, so the source formula stays on the branch
   (row 4).

Rows 1-5 all still hold. In particular **row 5 still reads `true`**: `boxNeg` does fire on this
branch and does mint world `1` carrying the witness `F(G p)`. The repair did not make the branch
unreachable, and was never meant to — group 1, the existential witness, is sound and untouched.

## Part 3-4 — what the repair changed

What used to arrive beside the witness was `T(G p)`, copied into the fresh world by the
`tempGProps` block: a **shape** filter (`branch.allFuturePosAtTime`) over the branch list,
indifferent to whether a formula had been expanded, and indifferent to which world it came from.
Those six group-3 blocks in each of `.boxNeg`/`.diamondPos` have been deleted as unsound. Each
rule now emits `.linear (witness :: boxProps ++ diaProps)`.

So the clash is gone (row 6), the branch the engine builds is **open** rather than closed
(rows 7-8), and `buildTableau` no longer returns `allClosed` for `(G p) → □(G p)` (row 9) — a
formula that is **invalid**: `box φ` is `∀ σ, σ.IsTotal → TruthAt … σ t φ`, quantifying over the
total histories `H_F` at the fixed time, while `G p` is evaluated along `τ` alone, so a frame
carrying one total history with `p` throughout the future and one without refutes it. The tableau
no longer reports
a valid formula where there is none.

## What is fixed, and what is still owed

`decide` moved from **`extractionFailed`** to **`fuelExhausted`** (row 10). That is a real
improvement and not a cosmetic one: by this codebase's R7 semantics `isKnownValid` is true for
`extractionFailed`, so the old value was an assertion that this invalid formula is **valid**.
The new value is recognised by `isUndecided` as honest ignorance. A wrong answer became no
answer.

**But the positive refutation is not here.** The plan for this repair required `buildTableau` to
return `.hasOpen` and `decide` to return `.invalid` with a countermodel. At fuel 1000 it returns
neither: the branch stays open long enough to exhaust the budget without saturating (row 9's
`(0, 0)`), and rows 11-12 still pin no countermodel. Fuel 30, 60, 400 and 1000 all agree. That
is a **resource/completeness** question — see `Verified/Termination/Fuel.lean`'s bounds — and it
is recorded here rather than papered over. Row 10 exists precisely so that the day it becomes
`.invalid` is loud.
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

/-! ### Row 6 — the `tempGProps` copy no longer arrives beside it, so there is no clash.

**Was `true`** — and that `true` was the refutation of the reachability claim: the branch the
preservation probe showed to be mapped from satisfiable to unsatisfiable was a branch the engine
actually built. With the six group-3 blocks deleted, the minted world receives the witness alone
and no `T(G p)` from any other world. Compare `BoxNegPreservationProbe.lean` rows 3 and 4, which
measure the same absence at the `applyRule` level. -/
/-- info: false -/
#guard_msgs in
#eval reached.any fun bo => clashAtFreshWorld bo.1

/-! ### Row 7 — the one reached branch is now **open**, not closed.

**Was `(1, 0)`** — one branch, none open. The branch count is unchanged; what changed is that it
no longer closes. This is the repair seen at the branch level, and it is the single most direct
statement of it in this file: the engine was closing a branch it had no grounds to close. -/
/-- info: (1, 1) -/
#guard_msgs in
#eval (reached.length, (reached.filter fun bo => !isClosed bo.1 .Base).length)

/-! ### Row 8 — and there is no closure reason at all.

**Was `some (1, 1, 0)`** — a `contradiction` at the minted world `1`, at the source time `0`,
i.e. the `tempGProps` clash itself rather than a negated axiom. It is now `none`: nothing on the
branch closes it. The tags `1`/`2`/`3` for `contradiction`/`botPos`/`axiomNeg` are retained so
that a future closure by a *different* route would be reported rather than silently read as the
old one. -/
/-- info: none -/
#guard_msgs in
#eval (reached.head?.bind fun bo => findClosure bo.1 .Base).map fun cr =>
        match cr with
        | .contradiction _ l => (1, l.world, l.time)
        | .botPos l => (2, l.world, l.time)
        | .axiomNeg _ _ l => (3, l.world, l.time)

/-! ## Part 4 — what the engine therefore answers, before and after

The preservation probe originally recorded `isValid ((G p) → □(G p)) = false` and read it as
*the correct verdict on an invalid formula*, concluding that no engine defect was in evidence.
The rows below measure what that `false` actually is — and it was never a refutation, either
before the repair or after it. What changed is which wrong-shaped answer it stands for. -/

/-! ### Row 9 — the real driver, on the real initial branch, no longer returns `allClosed`.

`1` tags `.allClosed`, `2` tags `.hasOpen`, `0` tags fuel exhaustion; the second component is the
branch count.

**Was `(1, 1)`** — the tableau closed, i.e. reported this **invalid** formula **valid**. That was
the defect this file exists to document. It is now `(0, 0)`: the budget is exhausted without the
branch saturating.

`(0, 0)` was an improvement over `(1, 1)` and was **not** the intended end state, which is
`(2, _)`. Fuel 30, 60, 400 and 1000 all returned `(0, 0)`, so the ceiling was not bracketed from
above and this was a termination/bound question rather than a budget one.

**It is now `(2, 40)`** — the intended end state. The branch saturates with an open branch of
length 40 at unchanged fuel 1000.

* **Old (pinned) value**: `(0, 0)`
* **New (measured) value**: `(2, 40)`
* **Owner of the move**: `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
  `def trivialEventWitnessed` and its two consultation sites. It is **not** owned by
  `Decidability/Saturation.lean` (an earlier guess) and **not** by the semantics refactor. The
  guard stops minting trivial seriality witnesses, so the time domain stops growing without
  bound and the branch reaches saturation instead of exhausting fuel. -/
/-- info: (2, 40) -/
#guard_msgs in
#eval match buildTableau (gp.imp gp.box) 1000 .Base with
      | none => (0, 0)
      | some (.allClosed bs) => (1, bs.length)
      | some (.hasOpen ob _ _ _) => (2, ob.length)

/-! ### Row 10 — `isValid`'s `false` is still not an `invalid` verdict, but it is now honest.

The tuple is `(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)`.

**Was `(false, false, false, true, false)`** — `extractionFailed`. `decide` closed the tableau
and then failed to extract a proof term. By this codebase's R7 semantics `isKnownValid` is true
for `extractionFailed`, so that value **asserted the formula is valid**. It is not.

It then became `(false, false, true, false, true)` — `fuelExhausted`, which `isUndecided`
recognises as "undetermined". That move was from a wrong answer to no answer.

**It is now `(false, true, false, false, false)`** — `.invalid`. The third and final step of the
history: from a wrong answer, to no answer, to the right answer. The formula is invalid and the
engine now says so.

* **Old (pinned) value**: `(false, false, true, false, true)` (`fuelExhausted`)
* **New (measured) value**: `(false, true, false, false, false)` (`invalid`)
* **Owner of the move**: `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
  `def trivialEventWitnessed` and its two consultation sites — **not**
  `Decidability/Saturation.lean` and **not** the semantics refactor. Row 9's saturation is the
  precondition: once the branch saturates rather than exhausting fuel, `decide` reads an open
  saturated branch and returns `.invalid`.

This is the anchor row for the whole repair, and it is duplicated deliberately at
`CrossWorldPropagationProbe.lean` row F, whose five sibling rows all call `isValid` and so
cannot see this distinction. -/
/-- info: (false, true, false, false, false) -/
#guard_msgs in
#eval let r := decide (gp.imp gp.box)
      (r.isValid, r.isInvalid, r.isFuelExhausted, r.isExtractionFailed, r.isUndecided)

/-! ### Row 11 — a countermodel **is** now produced.

This row was long unmoved at `false`, and it recorded the criterion still owed: the earlier
repair removed the false claim of validity but did not supply the positive refutation.

**That criterion is now met.** `getCountermodel?` returns `some`.

* **Old (pinned) value**: `false`
* **New (measured) value**: `true`
* **Owner of the move**: `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
  `def trivialEventWitnessed` and its two consultation sites — **not**
  `Decidability/Saturation.lean` and **not** the semantics refactor. Extraction runs off row 10's
  `.invalid` verdict, which in turn runs off row 9's saturated open branch.

Recorded separately: the returned Layer-0 `SimpleCountermodel` has `isConsistent = false`, since
the Layer-0 flattening discards the `(world, time)` label. This row asserts only that extraction
returns `some`, which is what is measured here; the `isConsistent` question is un-owned by this
row and by the suite, which contains no `#guard_msgs` asserting it. -/
/-- info: true -/
#guard_msgs in
#eval (decide (gp.imp gp.box)).getCountermodel?.isSome

/-! ### Row 12 — `isValid` reports `false`, the value the earlier reading rested on.

Unmoved. Kept last, immediately after the rows that say what it means, so the two can never
again be read apart: this `false` is row 10's constructor — `extractionFailed` then,
`fuelExhausted` now — and a countermodel neither time. -/
/-- info: false -/
#guard_msgs in
#eval isValid (gp.imp gp.box)

end BimodalTest.BoxNegReachabilityProbe
