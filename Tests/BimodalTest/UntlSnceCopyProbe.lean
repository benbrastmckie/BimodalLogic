/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.DecisionProcedure

/-!
# The `untl`/`snce` interval-relative propagation defects, measured

Two independent defects live in the `Until`/`Since` rules, and this file pins both as *facts*
about what `applyRule` emits rather than as hand arguments about what it ought to emit. The
conformance corpus (`Tests/BimodalTest/TableauConformance.lean`) cannot do this job: every one of
its `Until`/`Since` rows targets `CLOSED`, so it gates the **under**-closing direction only and
would not have caught either defect.

## Defect 1 — the unconditional copy (`untlPos`, `sncePos`, and the ACTIVE arms)

`untlPos` emits an `untlNegProps` block copying every `F(U(e',g'))` standing at the trigger's
time *unconditionally* to the freshly minted time. `Formula.untl` is evaluated along one history
and its truth is interval-relative, so `F(U(e',g'))@t` does not imply `F(U(e',g'))@t'` for
`t < t'`. Unlike the `□`/`◇` copies `boxDiamondPersistence` performs, no shift-closure argument
is available, because the claim is not `Ω`-universal.

The refuting model (`ℤ`, four atoms `V(n,p) ⟺ n = 5`, `V(n,q) ⟺ n ≥ 1`, `V(n,r) ⟺ n ≥ 2`,
`V(n,s) ⟺ n ≠ 1`) is recorded in full at
`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`. **Sections A and C below pin the
step it argues about.** Section A is the copy itself; it read `true` before the deletion of the
`untlNegProps`/`snceNegProps` blocks from `untlPos`/`sncePos` and reads `false` after.

## Defect 2 — the PASSIVE arms' co-decomposition (`untlNeg`, `snceNeg`)

Independent of any copy block. For `a < c`, `¬U(e,g)@a` implies only
`¬e@c ∨ ∃ z ∈ (a,c). ¬g@z` — the guard failure lies strictly *between*. The PASSIVE arm instead
places it *at* `c` and additionally re-asserts `¬U(e,g)@c`. Over `ℤ` with `e` true exactly at `3`
and `g` false exactly at `1`, `¬U(e,g)@0` holds while `e@3` and `g@3` are both true, so both
emitted arms fail. **Section B pins that the arm fires and what it emits.** This defect is
NOT repaired here: its fix converts the PASSIVE arm into a fresh-time producer, with termination
and completeness consequences that must be designed rather than improvised.

## What each row is evidence of

Sections A and B measure *steps*, which is what the two soundness refutations argue about, and
they are cheap and deterministic. Section C measures a *verdict*, which is a strictly weaker and
strictly more expensive question — a false formula emitted onto a branch does not by itself close
it. Per the group-3 lesson, section C discriminates with `isInvalid` / `getCountermodel?` and
never with `isValid` alone: `isValid = false` conflates "judged invalid" with `extractionFailed`.
-/

namespace BimodalTest.UntlSnceCopyProbe

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-- Probe atom `p` — the `untlPos` trigger's event. -/
def p : Formula := .atom (Atom.mkBase "p")
/-- Probe atom `q` — the `untlPos` trigger's guard. -/
def q : Formula := .atom (Atom.mkBase "q")
/-- Probe atom `r` — the copied negative Until's event. -/
def r : Formula := .atom (Atom.mkBase "r")
/-- Probe atom `s` — the copied negative Until's guard. -/
def s : Formula := .atom (Atom.mkBase "s")

/-! ## Section A — the `untlPos` copy

The branch of the `ℤ` counterexample: `T(U(p,q))` and `F(U(r,s))` at one label. It is
**satisfiable** in that model with `tv 0 = 0`. -/

/-- The satisfiable source branch. -/
def bA : Branch :=
  [ SignedFormula.pos (Formula.untl p q) { world := 0, time := 0 }
  , SignedFormula.neg (Formula.untl r s) { world := 0, time := 0 } ]

/-- The `T(U(p,q))` the rule fires on. -/
def srcA : SignedFormula := SignedFormula.pos (Formula.untl p q) { world := 0, time := 0 }

/-- The two successor branches `untlPos` produces. -/
def armsA : List (List SignedFormula) :=
  match (applyRule .untlPos srcA bA TimeOrdering.empty).1 with
  | .branching bss => bss
  | _ => []

/-- The copied formula the defect is about: `F(U(r,s))` at the *minted* time. -/
def copiedA : SignedFormula :=
  SignedFormula.neg (Formula.untl r s) { world := 0, time := bA.nextTime }

/-! ### Row A1 — the rule is applicable and branches in two -/
/-- info: 2 -/
#guard_msgs in
#eval armsA.length

/-! ### Row A2 — **the measurement.** Is `F(U(r,s))` copied to the minted time?

`true` before the repair, `false` after. This single row is defect 1.

**Pinned at the PRE-repair value.** -/
/-- info: true -/
#guard_msgs in
#eval armsA.any fun arm => arm.contains copiedA

/-! ### Row A3 — the minted time is `1`, i.e. `bA.nextTime`, and both arms speak about it

Unmoved by the repair: the witness labelling was never the problem. -/
/-- info: true -/
#guard_msgs in
#eval armsA.all fun arm => arm.any fun sf => sf.label.time == bA.nextTime

/-! ### Row A4 — the arms after the repair are exactly the event witness and the guard-and-continue
pair, with no propagation at all on this branch

`bA` carries no `T(G·)`, no `F(F·)` and no `□`/`◇`, so `gProps`, `fNegProps` and `modalProps` are
all empty; `untlNegProps` was the only non-empty block, and it is gone.

**Pinned at the PRE-repair value**: `[2, 3]`, one copied formula per arm. -/
/-- info: [2, 3] -/
#guard_msgs in
#eval armsA.map List.length

/-! ## Section B — the `untlNeg` PASSIVE arm (NOT repaired)

`ord = ⟨[(0,1)]⟩`, so `futureOf 0 = [1]` and time `1` is unprocessed. The pinning formula
`T(x)@(w₀,1)` is not exotic: `someFuturePos` on `T(F x)@(w₀,0)` produces exactly that shape with
exactly that ordering constraint. -/

/-- Probe atom `e` — true exactly at `3` in the refuting model. -/
def e : Formula := .atom (Atom.mkBase "e")
/-- Probe atom `g` — false exactly at `1` in the refuting model. -/
def g : Formula := .atom (Atom.mkBase "g")
/-- Probe atom `x` — pins `tv 1 = 3`. -/
def x : Formula := .atom (Atom.mkBase "x")

/-- The branch of the PASSIVE-arm refutation. -/
def bB : Branch :=
  [ SignedFormula.neg (Formula.untl e g) { world := 0, time := 0 }
  , SignedFormula.pos x { world := 0, time := 1 } ]

/-- The `F(U(e,g))` the rule fires on. -/
def srcB : SignedFormula := SignedFormula.neg (Formula.untl e g) { world := 0, time := 0 }

/-- The recorded ordering `0 < 1`. -/
def ordB : TimeOrdering := { constraints := [(0, 1)] }

/-- What the PASSIVE arm returns. -/
def resB : RuleResult × TimeOrdering := applyRule .untlNeg srcB bB ordB

/-- Its successor branches. -/
def armsB : List (List SignedFormula) :=
  match resB.1 with
  | .branching bss => bss
  | _ => []

/-! ### Row B1 — the PASSIVE arm fires: two branches, not `.notApplicable` -/
/-- info: 2 -/
#guard_msgs in
#eval armsB.length

/-! ### Row B2 — it fires at the **existing** time `1`, and mints nothing

Every formula it emits sits at a time already in `ordB`; no fresh time appears. This is what
distinguishes the PASSIVE arm from the ACTIVE one and is why the copy deletion does not touch
it. -/
/-- info: true -/
#guard_msgs in
#eval armsB.all fun arm => arm.all fun sf => sf.label.time ≤ 1

/-! ### Row B3 — the ordering comes back **unchanged** -/
/-- info: true -/
#guard_msgs in
#eval resB.2.constraints == ordB.constraints

/-! ### Row B4 — **the measurement.** The guard failure is placed *at* `1`, not strictly between

`¬U(e,g)@0` licenses only `¬e@1 ∨ ∃ z ∈ (0,1). ¬g@z`. Branch 2 asserts `¬g@1`, an endpoint, and
`¬U(e,g)@1` alongside it. In the model with `e` true exactly at `3` and `g` false exactly at `1`,
interpreting `1` as the instant `3` makes both `e` and `g` true there, so both arms fail. This
row stays `true` — the defect is escalated, not repaired. -/
/-- info: true -/
#guard_msgs in
#eval armsB.any fun arm =>
  arm.contains (SignedFormula.neg g { world := 0, time := 1 })
    && arm.contains (SignedFormula.neg (Formula.untl e g) { world := 0, time := 1 })

/-! ## Section C — the verdict on an invalid `Until` implication

`U(p,q) → U(r,s)` is invalid (the `ℤ` model above satisfies the antecedent at `0` and refutes the
consequent there). No conformance row covers this direction. The fuel is deliberately small: the
row's job is to record which `DecisionResult` constructor comes back, not to hunt for a
countermodel, and `isValid = false` alone would not distinguish the three ways of failing. -/

/-- The invalid implication. -/
def invalidUntil : Formula := (Formula.untl p q).imp (Formula.untl r s)

/-- The verdict, at a bounded fuel. -/
def verdictC : DecisionResult invalidUntil := decide invalidUntil 4 200

/-! ### Row C1 — not judged valid -/
/-- info: false -/
#guard_msgs in
#eval verdictC.isValid

/-! ### Row C2 — is it positively judged **invalid**? -/
/-- info: false -/
#guard_msgs in
#eval verdictC.isInvalid

/-! ### Row C3 — is a countermodel in hand? -/
/-- info: false -/
#guard_msgs in
#eval verdictC.getCountermodel?.isSome

/-! ### Row C4 — did the tableau **close** (i.e. claim the invalid formula valid)?

This is the over-closing measurement, and the one `isValid` alone cannot make. `true` here would
mean the engine answers wrongly. -/
/-- info: false -/
#guard_msgs in
#eval verdictC.isExtractionFailed

/-! ### Row C5 — or did it simply run out of budget? -/
/-- info: true -/
#guard_msgs in
#eval verdictC.isFuelExhausted

end BimodalTest.UntlSnceCopyProbe
