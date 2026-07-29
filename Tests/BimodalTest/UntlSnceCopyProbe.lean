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

## What section B is hardened against

Section B's rows are the ones a future PASSIVE-arm repair will be graded on, so they are built to
fail *loudly* rather than quietly when the arm changes shape:

* `armsB` reads **either** branching constructor. Matching `.branching` alone would make `armsB`
  empty under a switch to `.branchingOrdered` — the shape a repair must take, since its two arms
  carry different orderings — and B4 would then read `false` **vacuously**, which is
  indistinguishable from "the defect was repaired". Row **B0** pins which constructor is live, so
  the switch is reported rather than inferred.
* Rows **B5**/**B5′** measure fresh-time production, the failure mode nothing else here can see:
  divergence reaches the decision procedure only as `.fuelExhausted`. They are *differential* —
  a triggered profile against a control with the negative `Until` deleted — because the engine
  mints times on this branch for reasons unrelated to `untlNeg`, so no single count is pinnable.
  See the row's own comment for the measurement that establishes this.
* Row **B6** pins the post-blocking pass, whose fresh-time rejection test reads `applyRule`'s
  *outer* ordering and is therefore blind to a fresh time hidden inside a per-arm ordering.
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

`true` before the repair, `false` after. This single row is defect 1. -/
/-- info: false -/
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
all empty; `untlNegProps` was the only non-empty block, and it is gone. Was `[2, 3]`. -/
/-- info: [1, 2] -/
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

/-- Its successor branches, read out of **either** branching constructor.

Deliberately not `| .branching bss => bss | _ => []`. Under that form, a future switch of the
PASSIVE arm to `.branchingOrdered` — the shape any co-decomposition repair must take, since its
two arms would carry different orderings — makes `armsB` silently **empty**. B1 would then fail
loudly, but B2 would read `true` and B4 would read `false` **vacuously**, and a vacuous `false`
on B4 is indistinguishable from a genuine repair. That is the failure mode this destructuring
removes: the rows keep measuring the arms whichever constructor carries them, and row B0 below
is what reports the switch. -/
def armsB : List (List SignedFormula) :=
  match resB.1 with
  | .branching bss => bss
  | .branchingOrdered brs => brs.map Prod.fst
  | _ => []

/-! ### Row B0 — **which branching constructor is live.** Today: `.branching`

A repair of the PASSIVE arm must return `.branchingOrdered` (`.branching` shares one ordering
across all arms, and the two repaired arms need different ones), so this row flipping to `false`
is the signal that the arm's shape changed. It exists so that change is *reported* rather than
inferred from a row that went quiet. -/
/-- info: true -/
#guard_msgs in
#eval resB.1 matches .branching _

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

/-! ### Row B5 — **the re-fire counter**, as a *differential* gate

No other row in this file, and no row in the conformance corpus, can see a termination defect. A
diverging arm surfaces to the decision procedure as `.fuelExhausted`, which `isValid = false`
conflates with `extractionFailed`; and every `Until`/`Since` corpus row targets `CLOSED`, so the
corpus gates the under-closing direction only. This row is the instrument for the other
direction.

The concrete divergence it guards against: the `unprocessed` filter in `applyRule`'s `.untlNeg`
arm suppresses re-firing at `t'` only because **every** emitted arm places `¬event` or `¬guard`
at `t'` *itself*. Any repair that moves the guard failure to a fresh interpolant strictly inside
`(l.time, t')` — which is what the semantics actually licenses — leaves `t'` passing the filter,
and the arm re-fires at `t'` without bound, minting one time per re-fire.

**Why this is a pair of rows and not one pinned number.** The obvious design — run to a fixed
fuel and pin a single count, treating any growth as divergence — does not survive contact with
this engine. Measured below: following `expandOnce`'s first arm from `bB`, the count is
`2 + k/4` and *does not saturate* through `k = 128`. That growth is real but it is **not**
`untlNeg`'s: the control row, the identical measurement on the same branch with the negative
`Until` deleted outright, grows **faster** (`44` against `34` at `k = 128`). It is ordinary
seriality-driven witness minting — `serialityRule` puts `T(F⊤)`/`T(P⊤)` on the branch and the
temporal existentials mint a witness for each — and the negative `Until` slightly *slows* it by
spending steps on co-decomposition instead. First-arm-following is also not the real search,
which explores every arm and is bounded by fuel and `maxBranches`.

So the gate is the **relation between the two profiles**, not either profile alone. Today the
triggered profile sits strictly *below* the control from `k = 16` on. A passive-arm repair that
re-fires would push it *above*. Both are pinned, so that crossover is a diff rather than a
judgement call — and either profile changing on its own localises the cause to the trigger or to
the engine's background minting. -/

/-- Follow `expandOnce` for `k` steps, taking the first arm at every split, and count the times
the resulting branch knows. -/
def stepTimes : Nat → Branch → TimeOrdering → Nat
  | 0, b, _ => (Branch.knownTimes b).length
  | k + 1, b, ord =>
    match expandOnce b ord .Base with
    | (.extended b', ord') => stepTimes k b' ord'
    | (.split (b' :: _), ord') => stepTimes k b' ord'
    | (.splitOrdered ((b', o') :: _), _) => stepTimes k b' o'
    | (_, _) => (Branch.knownTimes b).length

/-! Triggered profile, at `k = 0, 4, 8, 16, 32, 64, 128`. -/
/-- info: [2, 3, 4, 6, 10, 18, 34] -/
#guard_msgs in
#eval [stepTimes 0 bB ordB, stepTimes 4 bB ordB, stepTimes 8 bB ordB, stepTimes 16 bB ordB,
       stepTimes 32 bB ordB, stepTimes 64 bB ordB, stepTimes 128 bB ordB]

/-- The same branch with the negative `Until` **removed** — the control for row B5. -/
def bBctl : Branch := [ SignedFormula.pos x { world := 0, time := 1 } ]

/-! Control profile, same fuels. Entry-wise `≥` the triggered profile from `k = 16` on; a
passive-arm repair that re-fires reverses that. -/
/-- info: [1, 3, 4, 7, 12, 23, 44] -/
#guard_msgs in
#eval [stepTimes 0 bBctl ordB, stepTimes 4 bBctl ordB, stepTimes 8 bBctl ordB,
       stepTimes 16 bBctl ordB, stepTimes 32 bBctl ordB, stepTimes 64 bBctl ordB,
       stepTimes 128 bBctl ordB]

/-! ### Row B5′ — the comparison itself, stated as the single fact the gate turns on -/
/-- info: true -/
#guard_msgs in
#eval [16, 32, 64, 128].all fun k => stepTimes k bB ordB ≤ stepTimes k bBctl ordB

/-! ### Row B6 — the post-blocking pass still mints nothing on this branch

`expandOnceNoFresh` exists to finish label-free work "without extending the time structure the
blocking decision was made against", and it enforces that by rejecting any candidate rule whose
returned ordering is longer than the one it was given. That test reads `applyRule`'s **second
component**, so a rule that hides a fresh time inside a per-arm ordering while returning the
unextended ordering outright would slip straight through it — and `saturateBlocked` carries the
same test and the same exposure. These two rows pin both halves of the guard against exactly
that: the constructor it comes back with, and whether the outer ordering reports growth. -/
/-- info: false -/
#guard_msgs in
#eval (expandOnceNoFresh bB ordB .Base).1 matches .splitOrdered _

/-- info: false -/
#guard_msgs in
#eval (expandOnceNoFresh bB ordB .Base).2.constraints.length > ordB.constraints.length

/-! ## Section C — the verdict on an invalid `Until` implication

`U(p,q) → U(r,s)` is invalid (the `ℤ` model above satisfies the antecedent at `0` and refutes the
consequent there). No conformance row covers this direction. The fuel is deliberately small: the
row's job is to record which `DecisionResult` constructor comes back, not to hunt for a
countermodel, and `isValid = false` alone would not distinguish the three ways of failing.

As it turned out, the fuel was ample: after the copy deletion this search terminates with a
countermodel rather than exhausting its budget. -/

/-- The invalid implication. -/
def invalidUntil : Formula := (Formula.untl p q).imp (Formula.untl r s)

/-- The verdict, at a bounded fuel. -/
def verdictC : DecisionResult invalidUntil := decide invalidUntil 4 200

/-! ### Row C1 — not judged valid -/
/-- info: false -/
#guard_msgs in
#eval verdictC.isValid

/-! ### Row C2 — is it positively judged **invalid**?

**This row moved, and it is the deletion's clearest dividend.** Before the deletion the run
returned `fuelExhausted`; after it, the engine positively refutes the formula. The copy was
closing off the very branches a countermodel had to be read from. -/
/-- info: true -/
#guard_msgs in
#eval verdictC.isInvalid

/-! ### Row C3 — is a countermodel in hand?

Moved with C2. `false` before the deletion. -/
/-- info: true -/
#guard_msgs in
#eval verdictC.getCountermodel?.isSome

/-! ### Row C4 — did the tableau **close** (i.e. claim the invalid formula valid)?

This is the over-closing measurement, and the one `isValid` alone cannot make. `true` here would
mean the engine answers wrongly. -/
/-- info: false -/
#guard_msgs in
#eval verdictC.isExtractionFailed

/-! ### Row C5 — or did it simply run out of budget?

`true` before the deletion, `false` after: the budget is no longer the binding constraint,
because the search now terminates with a verdict. -/
/-- info: false -/
#guard_msgs in
#eval verdictC.isFuelExhausted

/-! ## Section D — the `untlNeg`/`snceNeg` **ACTIVE** arms' self-propagated `Until`/`Since`

Section A measures the copy of *other* negative `Until`s onto a minted time (deleted). Section B
measures the PASSIVE arm's endpoint co-decomposition (escalated, unrepaired). This section
measures a **third, independent** defect that neither sees: the ACTIVE arm re-asserts **its own**
`¬U(event,guard)` at the time it just minted.

The hand refutation these rows convert into facts is over `D = ℚ`, with `V(q,e) ⟺ q > 0`,
`V(q,g) ⟺ q ∉ {1/n : n ≥ 1}`, `V(q,x) ⟺ q = 0`, `V(q,y) ⟺ q = −1`. On the branch below,
`¬U(e,g)@0` is **true** (every `s > 0` has some `1/n` strictly inside `(0,s)` where `g` fails),
yet both emitted arms are false at every admissible interpretation `C` of the minted time:

* branch 1 demands `¬e@C`, and the ordering forces `C > 0`, where `e` holds throughout;
* branch 2 demands `¬g@C` — so `C = 1/n` — **and** `¬U(e,g)@(1/n)`. But `U(e,g)@(1/n)` is true:
  pick `s ∈ (1/n, 1/(n−1))` (any `s > 1` when `n = 1`); `e@s` holds and `(1/n, s)` contains no
  `1/m`, so the guard holds across the whole interval. It is the **second conjunct** — the
  self-propagated `¬U(e,g)@fresh` — that makes branch 2 unsatisfiable, and it is the sub-term
  the repair deletes.

Unlike section A's copy, no `untlNegProps` block is involved: the sub-term is written into the
arm literally, so the deletion of the copy blocks left it standing. `T(x)@0` and `T(y)@2` are not
decoration — they pin the origin against the shift orbit and force `tv 2 < tv 0` respectively, so
that re-choosing the history is not an escape.

**Row D1c/D2c are the before/after rows for the ACTIVE-arm repair**: `true` before the deletion
of the self-propagated sub-term, `false` after. Every other row in the section is a
precondition-pin, so that a `false` on D1c/D2c cannot be produced *vacuously* by the arm ceasing
to fire — the failure mode section B's own comment describes. -/

/-- Probe atom `y` — pins `tv 2 = −1`, i.e. that `2` lies *below* `0`. -/
def y : Formula := .atom (Atom.mkBase "y")

/-! ### D1 — the `.untlNeg` ACTIVE arm -/

/-- The ℚ-refutation branch. `maxTime = 2`, so `nextTime = 3`. -/
def bD : Branch :=
  [ SignedFormula.neg (Formula.untl e g) { world := 0, time := 0 }
  , SignedFormula.pos x { world := 0, time := 0 }
  , SignedFormula.pos y { world := 0, time := 2 } ]

/-- The `F(U(e,g))` the rule fires on. -/
def srcD : SignedFormula := SignedFormula.neg (Formula.untl e g) { world := 0, time := 0 }

/-- The recorded ordering. A constraint `(a,b)` means `a < b`, so `(2,0)` says `2 < 0`: time `0`
has **no** future, which is exactly the ACTIVE arm's precondition, while `timeCount = 2` keeps it
inside the arm's `0 < timeCount < 4` window. -/
def ordD : TimeOrdering := { constraints := [(2, 0)] }

/-- What the ACTIVE arm returns. -/
def resD : RuleResult × TimeOrdering := applyRule .untlNeg srcD bD ordD

/-- Its successor branches, read out of **either** branching constructor, for the reason row B0's
comment gives: a constructor switch must be *reported* by D1e, never silently empty these rows. -/
def armsD : List (List SignedFormula) :=
  match resD.1 with
  | .branching bss => bss
  | .branchingOrdered brs => brs.map Prod.fst
  | _ => []

/-- The sub-term under audit: the arm's **own** `¬U(e,g)`, at the time it just minted. -/
def selfCopyD : SignedFormula :=
  SignedFormula.neg (Formula.untl e g) { world := 0, time := bD.nextTime }

/-! #### Row D1a — the ACTIVE arm fires, and branches in two -/
/-- info: 2 -/
#guard_msgs in
#eval armsD.length

/-! #### Row D1b — the ACTIVE preconditions actually hold, and the minted time is `3`

`[futureOf 0 |>.length, timeCount, nextTime]`. The first must be `0` (else the PASSIVE arm runs
instead), the second must lie in `(0,4)`, and the third is the minted index. If any of these
moves, D1c has stopped measuring the arm it was written for. -/
/-- info: [0, 2, 3] -/
#guard_msgs in
#eval [(ordD.futureOf 0).length, ordD.timeCount, bD.nextTime]

/-! #### Row D1c — **the measurement.** Is `¬U(e,g)` re-asserted at the minted time?

`true` before the ACTIVE-arm repair, `false` after. **It has flipped**: the self-propagated
sub-term is deleted. Read together with D1a and D1b, which are unchanged across the repair and
so exclude the vacuous route to `false` — the arm still fires, still branches in two, and still
mints `3`; what it no longer does is re-assert its own negative Until there. -/
/-- info: false -/
#guard_msgs in
#eval armsD.any fun arm => arm.contains selfCopyD

/-! #### Row D1d — the arm shapes

`autoProp` is empty on this branch (no `T(G·)`, no `F(F·)`, no `□`/`◇`), so the lengths are
exactly the co-decomposition payloads. Before the repair: branch 1 `[¬e@3, sf]` and branch 2
`[¬g@3, ¬U(e,g)@3, sf]`, i.e. `[2, 3]`. **After: `[2, 2]`** — the two arms are now symmetric,
which is the shape the classical split `¬e@C ∨ ¬g@C` actually licenses. -/
/-- info: [2, 2] -/
#guard_msgs in
#eval armsD.map List.length

/-! #### Row D1e — the ordering is extended, and returned as the **outer** component

The arm mints `3` above `0`, so the returned ordering is strictly longer than `ordD`. This is the
component `expandOnceNoFresh`'s fresh-time rejection test reads; row B6 is the corresponding pin
for the PASSIVE arm. `[constructor-is-.branching, constraints grew]`. -/
/-- info: [true, true] -/
#guard_msgs in
#eval [resD.1 matches .branching _, resD.2.constraints.length > ordD.constraints.length]

/-! ### D2 — the `.snceNeg` mirror

The exact time reversal of D1: `(0,2)` says `0 < 2`, so time `0` has no **past** and the
`.snceNeg` ACTIVE arm fires, minting `3` below `0`. The mirror claim was inferred rather than
measured before these rows existed. -/

/-- The mirror branch. -/
def bD' : Branch :=
  [ SignedFormula.neg (Formula.snce e g) { world := 0, time := 0 }
  , SignedFormula.pos x { world := 0, time := 0 }
  , SignedFormula.pos y { world := 0, time := 2 } ]

/-- The `F(S(e,g))` the rule fires on. -/
def srcD' : SignedFormula := SignedFormula.neg (Formula.snce e g) { world := 0, time := 0 }

/-- `0 < 2`: time `0` has no past. -/
def ordD' : TimeOrdering := { constraints := [(0, 2)] }

/-- What the `.snceNeg` ACTIVE arm returns. -/
def resD' : RuleResult × TimeOrdering := applyRule .snceNeg srcD' bD' ordD'

/-- Its successor branches, constructor-agnostically. -/
def armsD' : List (List SignedFormula) :=
  match resD'.1 with
  | .branching bss => bss
  | .branchingOrdered brs => brs.map Prod.fst
  | _ => []

/-- The mirror sub-term under audit. -/
def selfCopyD' : SignedFormula :=
  SignedFormula.neg (Formula.snce e g) { world := 0, time := bD'.nextTime }

/-! #### Row D2a — the ACTIVE arm fires, and branches in two -/
/-- info: 2 -/
#guard_msgs in
#eval armsD'.length

/-! #### Row D2b — `[pastOf 0 |>.length, timeCount, nextTime]` -/
/-- info: [0, 2, 3] -/
#guard_msgs in
#eval [(ordD'.pastOf 0).length, ordD'.timeCount, bD'.nextTime]

/-! #### Row D2c — **the mirror measurement.** `true` before the repair, `false` after; flipped
in lockstep with D1c, confirming the two arms are genuine time reversals rather than merely
similar-looking. -/
/-- info: false -/
#guard_msgs in
#eval armsD'.any fun arm => arm.contains selfCopyD'

/-! #### Row D2d — the arm shapes; `[2, 3]` before the repair, `[2, 2]` after -/
/-- info: [2, 2] -/
#guard_msgs in
#eval armsD'.map List.length

/-! #### Row D2e — constructor and ordering extension -/
/-- info: [true, true] -/
#guard_msgs in
#eval [resD'.1 matches .branching _, resD'.2.constraints.length > ordD'.constraints.length]

end BimodalTest.UntlSnceCopyProbe
