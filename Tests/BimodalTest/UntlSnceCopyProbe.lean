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

## Defect 2 — the PASSIVE arms' co-decomposition (`untlNeg`, `snceNeg`) — RETIRED

Independent of any copy block. For `a < c`, `¬U(e,g)@a` implies only
`¬e@c ∨ ∃ z ∈ (a,c). ¬g@z` — the guard failure lies strictly *between*. The PASSIVE arm instead
placed it *at* `c` and additionally re-asserted `¬U(e,g)@c`. Over `ℤ` with `e` true exactly at
`3` and `g` false exactly at `1`, `¬U(e,g)@0` holds while `e@3` and `g@3` are both true, so both
emitted arms fail. **Section B pinned that the arm fired and what it emitted**, and read `true`
for as long as it stood.

**The arms are now RETIRED**, not repaired: a sound arm would have to mint an interpolant
strictly inside the open interval, and no termination bound for that is available here — the
subformula-descent bound is refuted by the `G`-propagation channel (section E2, and F3 for the
channel reaching the arm) and a `timeCount` cap is a switch rather than a net (E1c). `Tableau.lean`'s
`.untlNeg` arm carries the full argument and the authorization.

**Reading section B after the retirement.** B0 and B1 are the live rows: no branching result,
no arms. B2, B3 and B4 are now VACUOUS — `armsB = []` makes `List.all` trivially true and
`List.any` trivially false — which is precisely the state the `armsB` docstring predicted would
be indistinguishable from a genuine repair. What distinguishes it is B0/B1 saying the cause
outright, and section F counting the firings. Do not read B2 or B4 on their own.

## What the retirement cost, measured

Recorded here because it was mis-predicted in both directions and the correction is the useful
part. The declared cost was two `TableauConformance` rows. **The conformance corpus did not move
at all** — all 29 rows unchanged. The cost landed instead on `TemporalWitnessProbe`, where
fourteen rows moved and every one of them carries `check=true → check=false`: retiring the arm
removes branch 1, the only emitter of `¬event@t'` at an *existing* time, which is exactly what
the `untlNegFuture` gate row demands, so `temporalWitnessCheck` now fails on branches it used to
accept. That is a real completeness regression in the truth-lemma gate, deliberate and
authorized, and it is larger than the declared cost while sitting somewhere else entirely.

## What each row is evidence of

Sections A and B measure *steps*, which is what the two soundness refutations argue about, and
they are cheap and deterministic. Section C measures a *verdict*, which is a strictly weaker and
strictly more expensive question — a false formula emitted onto a branch does not by itself close
it. Per the group-3 lesson, section C discriminates with `isInvalid` / `getCountermodel?` and
never with `isValid` alone: `isValid = false` conflates "judged invalid" with `extractionFailed`.

## What section B was hardened against, and how the hardening actually fared

Section B's rows were the ones a PASSIVE-arm change would be graded on, so they were built to
fail *loudly* rather than quietly when the arm changed shape. The change turned out to be a
retirement rather than the anticipated constructor switch, and the two halves of the defence
fared differently — the `armsB` destructuring did not help, the loud companion rows did. That
is recorded at each bullet and at the `armsB` binder itself.

* `armsB` reads **either** branching constructor. Matching `.branching` alone would make `armsB`
  empty under a switch to `.branchingOrdered` — the shape a repair must take, since its two arms
  carry different orderings — and B4 would then read `false` **vacuously**, which is
  indistinguishable from "the defect was repaired". Row **B0** pins which constructor is live, so
  the switch is reported rather than inferred. **Outcome**: the arm was retired, not switched,
  so `armsB` is empty and B2/B4 do read vacuously — the destructuring bought nothing. B0 and B1
  are what make the vacuity legible, and they are the part of the design that worked.
* Rows **B5**/**B5′** measure fresh-time production, the failure mode nothing else here can see:
  divergence reaches the decision procedure only as `.fuelExhausted`. They are *differential* —
  a triggered profile against a control with the negative `Until` deleted — because the engine
  mints times on this branch for reasons unrelated to `untlNeg`, so no single count is pinnable.
  See the row's own comment for the measurement that establishes this. **Outcome**: B5′ flipped
  to `false`, but in the *opposite* direction to the one it was built to catch — the triggered
  profile rose to exactly one above the control everywhere, the signature of an arm that stopped
  firing, not one that re-fires and mints. B5′ cannot tell "stopped" from "never mattered".
* Row **B6** pins the post-blocking pass, whose fresh-time rejection test reads `applyRule`'s
  *outer* ordering and is therefore blind to a fresh time hidden inside a per-arm ordering.
  Unmoved.
* Section **F**, added one commit before the retirement, is the row that closes B5′'s blind spot:
  it counts PASSIVE firings directly and went from `[1, 5, 9, 23, 75, 275, 1059]` to all-zero.
  It is the only instrument here that separates a retired arm from a capped one.
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

/-! ## Section B — the `untlNeg` PASSIVE arm (RETIRED)

**The arm these rows measure no longer exists.** Its co-decomposition at existing future times
was unsound and could not be repaired without an interpolant design this tree has no termination
bound for, so it was retired to `.notApplicable`; `Tableau.lean`'s `.untlNeg` arm carries the
full argument and the authorization. Section B is kept, and kept *running*, because a retirement
that is only asserted in a comment is not measured. Every row below is now the post-retirement
reading, and each row's own note records what it read while the arm stood.

Reading the section as a whole: **B0 and B1 are the live rows** — they say directly that no
branching result comes back and that there are no arms. **B2, B3, B4 are now vacuous**, in the
precise sense that `armsB = []` makes `List.all` trivially true and `List.any` trivially false.
That is why B0 and B1 exist, and it is exactly the failure mode the `armsB` note below was
written against: a vacuous reading is only safe when a non-vacuous row says why. Do not read B2
or B4 on their own again.

`ord = ⟨[(0,1)]⟩`, so `futureOf 0 = [1]` and time `1` was the unprocessed target the arm used to
fire at. The pinning formula `T(x)@(w₀,1)` is not exotic: `someFuturePos` on `T(F x)@(w₀,0)`
produces exactly that shape with exactly that ordering constraint. -/

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
is what reports the switch.

**This hardening did its job, and the outcome is worth recording.** The arm was not switched to
another constructor in the end; it was retired outright. `armsB` is therefore empty, and B2/B4
do read vacuously — the very state the note above calls indistinguishable from a repair. What
makes it distinguishable is that B0 (`false`) and B1 (`0`) report the cause in so many words
rather than leaving it to be inferred from a row that went quiet. The lesson generalises: the
destructuring was the wrong half of the defence, and the loud non-vacuous companion row was the
right half. -/
def armsB : List (List SignedFormula) :=
  match resB.1 with
  | .branching bss => bss
  | .branchingOrdered brs => brs.map Prod.fst
  | _ => []

/-! ### Row B0 — **which constructor comes back.** Was `.branching`; now neither

Written to report a switch to `.branchingOrdered`, the shape a co-decomposition *repair* would
have taken. What happened instead is a retirement, so the row reads `false` for the stronger
reason that no branching result comes back at all — `applyRule .untlNeg` on this configuration
now returns `.notApplicable`. Read together with B1, which distinguishes the two cases: a
constructor switch would leave B1 at `2`. -/
/-- info: false -/
#guard_msgs in
#eval resB.1 matches .branching _

/-! ### Row B1 — **the retirement itself.** The arm no longer fires: no arms, not two

Was `2`. With B0 this is the whole content of the retirement as a measurement: not a different
shape, not a narrower guard — nothing comes back. -/
/-- info: 0 -/
#guard_msgs in
#eval armsB.length

/-! ### Row B2 — VACUOUS since the retirement (`armsB = []`, so `List.all` is trivially true)

It used to say: every formula the arm emits sits at a time already in `ordB`, no fresh time
appears — the property distinguishing the PASSIVE arm from the ACTIVE one. There are no
emissions left for it to quantify over. Kept as a tripwire: if anything ever restores a firing
arm, this row starts carrying content again, and B0/B1 will have reported the restoration
first. -/
/-- info: true -/
#guard_msgs in
#eval armsB.all fun arm => arm.all fun sf => sf.label.time ≤ 1

/-! ### Row B3 — the ordering comes back **unchanged**

Unmoved by the retirement, and for a newly trivial reason: `.notApplicable` is returned paired
with `timeOrd` itself. -/
/-- info: true -/
#guard_msgs in
#eval resB.2.constraints == ordB.constraints

/-! ### Row B4 — **the measurement.** The guard failure is placed *at* `1`, not strictly between

`¬U(e,g)@0` licenses only `¬e@1 ∨ ∃ z ∈ (0,1). ¬g@z`. Branch 2 asserts `¬g@1`, an endpoint, and
`¬U(e,g)@1` alongside it. In the model with `e` true exactly at `3` and `g` false exactly at `1`,
interpreting `1` as the instant `3` makes both `e` and `g` true there, so both arms fail.

**Was `true`, and read `true` for as long as the defect stood.** It now reads `false`, and the
`false` is VACUOUS — `armsB = []`, so `List.any` is trivially false. It does **not** say the
guard failure has been moved strictly inside the interval; nothing places it anywhere any more.
This is exactly the reading the `armsB` note warned would be indistinguishable from a repair,
and B0/B1 are what make it distinguishable. The row that carries the retirement is B1, not this
one. -/
/-- info: false -/
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

So the gate is the **relation between the two profiles**, not either profile alone. Both are
pinned, so a crossover is a diff rather than a judgement call, and either profile changing on
its own localises the cause to the trigger or to the engine's background minting.

**What the retirement did to this gate, and why the crossover happened in the harmless
direction.** The triggered profile used to sit strictly *below* the control from `k = 16` on,
because the negative `Until` spent steps on co-decomposition instead of on minting. It now sits
exactly **one above** the control at every entry: `[2, 4, 5, 8, 13, 24, 45]` against
`[1, 3, 4, 7, 12, 23, 44]`, was `[2, 3, 4, 6, 10, 18, 34]`. B5′ therefore flipped to `false`.

That flip is **not** the failure mode B5′ was built to catch. B5′ was written to catch an arm
that *re-fires and mints*; what happened is an arm that stopped firing altogether, leaving the
triggered branch to mint at exactly the control's rate plus the one extra time that `bB`'s own
`T(x)@(w₀,1)` labels and `bBctl` does not. The constant offset of one, at every fuel, is the
signature of that and is why this is legible as retirement rather than as divergence. Row E1b
records the same offset for the same reason. The rows to read alongside it are **B1** (the arm
is gone) and **section F** (it fires zero times) — B5′ alone cannot distinguish "stopped" from
"never mattered", which is the same blind spot section F exists to close. -/

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

/-! Triggered profile, at `k = 0, 4, 8, 16, 32, 64, 128`. Was `[2, 3, 4, 6, 10, 18, 34]` while
the PASSIVE arm still fired. -/
/-- info: [2, 4, 5, 8, 13, 24, 45] -/
#guard_msgs in
#eval [stepTimes 0 bB ordB, stepTimes 4 bB ordB, stepTimes 8 bB ordB, stepTimes 16 bB ordB,
       stepTimes 32 bB ordB, stepTimes 64 bB ordB, stepTimes 128 bB ordB]

/-- The same branch with the negative `Until` **removed** — the control for row B5. -/
def bBctl : Branch := [ SignedFormula.pos x { world := 0, time := 1 } ]

/-! Control profile, same fuels. **Unmoved by the retirement** — it never carried the negative
`Until` — which is what makes it the reference the triggered profile's shift is measured
against. It used to sit entry-wise `≥` the triggered profile from `k = 16` on; it now sits
exactly one below it everywhere. -/
/-- info: [1, 3, 4, 7, 12, 23, 44] -/
#guard_msgs in
#eval [stepTimes 0 bBctl ordB, stepTimes 4 bBctl ordB, stepTimes 8 bBctl ordB,
       stepTimes 16 bBctl ordB, stepTimes 32 bBctl ordB, stepTimes 64 bBctl ordB,
       stepTimes 128 bBctl ordB]

/-! ### Row B5′ — the comparison itself, stated as the single fact the gate turns on

Was `true`. Reads `false` because the triggered profile now sits one *above* the control at
every fuel — see B5's note for why that is the retirement's signature and not the divergence
this row was built to catch. -/
/-- info: false -/
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

/-! ## Section E — the two quantities the PASSIVE-arm decision turns on

Section E measures nothing about soundness. It exists because the choice between the two
surviving PASSIVE-arm designs — retire the arm outright, or let it mint an interpolant under a
`timeCount` cap — was being argued from two quantities that had never actually been evaluated.
Both are recorded here as facts, so that the choice is made against measurements. -/

/-- Follow `expandOnce` for `k` steps, first arm at every split, and report the **ordering's**
`timeCount` rather than the branch's `knownTimes`. -/
def stepOrd : Nat → Branch → TimeOrdering → Nat
  | 0, _, ord => ord.timeCount
  | k + 1, b, ord =>
    match expandOnce b ord .Base with
    | (.extended b', ord') => stepOrd k b' ord'
    | (.split (b' :: _), ord') => stepOrd k b' ord'
    | (.splitOrdered ((b', o') :: _), _) => stepOrd k b' o'
    | (_, _) => ord.timeCount

/-! ### E1 — does `timeCount` cross a cap threshold early enough to retire a capped arm?

Row B5 profiles `Branch.knownTimes`; every proposed cap is stated against
`TimeOrdering.timeCount`, and the two are different objects — a time is *known* as soon as some
formula carries it, but enters `timeCount` only once an ordering constraint mentions it. So B5
cannot settle the question, and the inference "`knownTimes` grows, therefore `timeCount` grows"
is structural rather than measured. What turns on it: if `timeCount` passes the threshold within
the opening steps, a capped interpolant design is *behaviourally indistinguishable on real
branches* from simply retiring the arm — dormant either way — while carrying a far larger blast
radius. These rows are that comparison, on the same two profiles and the same fuels as B5. -/

/-! #### Row E1a — triggered profile at `k = 0, 4, 8, 16, 32, 64, 128`

Identical, entry for entry, to B5's triggered `knownTimes` profile: on this branch every known
time is an ordered time. Was `[2, 3, 4, 6, 10, 18, 34]` before the PASSIVE arms were retired,
and moved in lockstep with B5 for the reason B5's note gives. -/
/-- info: [2, 4, 5, 8, 13, 24, 45] -/
#guard_msgs in
#eval [stepOrd 0 bB ordB, stepOrd 4 bB ordB, stepOrd 8 bB ordB, stepOrd 16 bB ordB,
       stepOrd 32 bB ordB, stepOrd 64 bB ordB, stepOrd 128 bB ordB]

/-! #### Row E1b — control profile (negative `Until` deleted), same fuels

Exactly one above B5's control `knownTimes` profile at every entry, and the offset is
accounted for: `ordB = ⟨[(0,1)]⟩` mentions time `0`, which the control branch never labels.
**Unmoved by the retirement**, like B5's control and for the same reason. -/
/-- info: [2, 4, 5, 8, 13, 24, 45] -/
#guard_msgs in
#eval [stepOrd 0 bBctl ordB, stepOrd 4 bBctl ordB, stepOrd 8 bBctl ordB, stepOrd 16 bBctl ordB,
       stepOrd 32 bBctl ordB, stepOrd 64 bBctl ordB, stepOrd 128 bBctl ordB]

/-! #### Row E1c — **the crossing.** Least `k ≤ 32` at which `timeCount` reaches `4` and `8`

`[triggered≥4, control≥4, triggered≥8, control≥8]`. `none` would have meant a cap is genuinely a
net rather than a switch. It is not: `4` — the threshold the **existing** ACTIVE guard
`0 < timeCount < 4` tests — is crossed after a handful of steps, which is why the ACTIVE arms
read as dormant on every measured row, and `8` follows well inside any realistic fuel (section C
runs at fuel `200`). A `timeCount`-capped PASSIVE arm would therefore be switched off for the
overwhelming majority of every run, by background minting it has no part in.

That reading is what the retirement was decided on, and the row has since moved: it was
`[some 5, some 4, some 21, some 16]` and is now `[some 4, some 4, some 16, some 16]`. The
triggered and control crossings have **collapsed onto each other**, at both thresholds. This
strengthens the original reading rather than qualifying it: with the arm gone, the negative
`Until` no longer delays the crossing even by the one step it used to, so the crossing is now
purely background minting, with no contribution from the rule whatsoever. -/
/-- info: [some 4, some 4, some 16, some 16] -/
#guard_msgs in
#eval [(List.range 33).find? fun k => stepOrd k bB ordB ≥ 4,
       (List.range 33).find? fun k => stepOrd k bBctl ordB ≥ 4,
       (List.range 33).find? fun k => stepOrd k bB ordB ≥ 8,
       (List.range 33).find? fun k => stepOrd k bBctl ordB ≥ 8]

/-! ### E2 — does the `G`-propagation channel fire on a branch the engine actually builds?

The channel, as constructed by hand from two rule bodies: `allFuturePos` propagates
`T(G ¬U(e,g))@0` to every time the engine mints, and the positive-negation rule turns each
resulting `T(¬U(e,g))@z` into `F(U(e,g))@z` — a **new `(source, label)` pair** at every one,
hence a fresh mint allowance for any arm keyed on that pair. If it fires, no subformula-descent
argument bounds an interpolant design, because the supply of sources is not fixed in advance.

The measurement is the number of **distinct times** carrying a negative `U(e,g)` after `k` steps
from a branch that starts with exactly one such source, at time `0`, under a `G`. Growth in this
count *is* the channel. -/

/-- The branch carrying `T(G ¬U(e,g))@0` plus one future time. -/
def bE : Branch :=
  [ SignedFormula.pos (Formula.allFuture (Formula.untl e g).neg) { world := 0, time := 0 }
  , SignedFormula.pos x { world := 0, time := 1 } ]

/-- Follow `expandOnce` for `k` steps, first arm at every split, returning the branch reached. -/
def stepFull : Nat → Branch → TimeOrdering → Branch
  | 0, b, _ => b
  | k + 1, b, ord =>
    match expandOnce b ord .Base with
    | (.extended b', ord') => stepFull k b' ord'
    | (.split (b' :: _), ord') => stepFull k b' ord'
    | (.splitOrdered ((b', o') :: _), _) => stepFull k b' o'
    | (_, _) => b

/-- The distinct times at which a negative `U(e,g)` stands on `b`. -/
def negUntlTimes (b : Branch) : List TimeIndex :=
  (b.filterMap fun sf =>
    if sf.sign matches .neg && sf.formula == Formula.untl e g then some sf.label.time
    else none).eraseDups

/-! #### Row E2a — **the measurement.** Distinct negative-`U(e,g)` times after `k` steps

`k = 0, 4, 8, 16, 32, 64`. The branch **starts with none** — its only `U(e,g)` occurrence is
positive and buried under a `G` — so every count above `0` is manufactured by the channel, and
the growth is the channel operating. **It fires.** By step 64 the engine is carrying nine
distinct labelled negative `Until`s where it began with zero.

This is what makes a subformula-descent termination argument unavailable for any interpolant
design: the descent presumes a supply of `(source, label)` pairs fixed in advance, and this row
exhibits the engine manufacturing new ones without bound as it mints times.

**Survives the PASSIVE-arm retirement, and grows slightly.** Was `[0, 1, 1, 3, 5, 9]`; the
`k = 64` entry is now `10`. The channel is `allFuturePos` + `negPos`, neither of which the
retirement touched, so the manufacture continues; what changed is only that the manufactured
sources no longer spend steps firing the retired arm, leaving one more of them standing by
`k = 64`. The refutation this row supports is therefore unaffected — which matters, because it
is one of the two measurements the retirement was chosen on. -/
/-- info: [0, 1, 1, 3, 5, 10] -/
#guard_msgs in
#eval [0, 4, 8, 16, 32, 64].map fun k => (negUntlTimes (stepFull k bE ordB)).length

/-! #### Row E2b — the times themselves at `k = 32`, with the branch size

Guards against reading E2a's growth as an artefact of a branch that merely got large: the
negative `Until`s sit at five *distinct* times, not five copies at one. The branch length was
`44` before the retirement and is `42` after — two formulas smaller, the co-decomposition output
the arm used to add — while **the five times are unchanged**, which is the point of the row. -/
/-- info: ([6, 4, 3, 2, 1], 42) -/
#guard_msgs in
#eval ((negUntlTimes (stepFull 32 bE ordB)), (stepFull 32 bE ordB).length)

/-! ## Section F — T3, the PASSIVE-arm firing counter

Row **B5′** compares two `knownTimes` profiles and asks only whether the triggered profile stays
at or below the control. That comparison reads `true` in **two** completely different worlds: one
where the PASSIVE arm fires as designed and produces no extra times, and one where the arm has
been switched off entirely and produces nothing at all. Every other row in this file measures a
*single* `applyRule` call on a hand-built branch, so none of them can tell those apart either.
That is B5′'s blind spot, and this section is the instrument that closes it: a direct count of
how many times the PASSIVE arm actually returns a branching constructor along a fixed-fuel run.

The discriminator between the two arms is the **outer ordering**. The ACTIVE arm mints a fresh
time and returns `timeOrd.addFuture`/`addPast`, so its outer ordering is strictly longer than the
one it was given (rows D1e/D2e pin exactly this). The PASSIVE arm fires at an existing time and
returns the ordering **unchanged** (row B3). So "branching result with an unextended outer
ordering" identifies a PASSIVE firing without reaching inside the arm bodies, and it keeps
working if the arm's constructor is ever switched — the same hardening `armsB` has. -/

/-- Did `applyRule r sf b ord` fire through a **PASSIVE** path: a branching result whose outer
ordering did not grow? Both branching constructors are read, for the reason `armsB` reads both. -/
def passiveFires (rule : TableauRule) (sf : SignedFormula) (b : Branch) (ord : TimeOrdering) :
    Bool :=
  let res := applyRule rule sf b ord
  ((res.1 matches .branching _) || (res.1 matches .branchingOrdered _))
    && res.2.constraints.length == ord.constraints.length

/-- How many formulas on `b` the PASSIVE arms of `untlNeg`/`snceNeg` fire on, right now. -/
def passiveCount (b : Branch) (ord : TimeOrdering) : Nat :=
  (b.filter fun sf =>
    passiveFires .untlNeg sf b ord || passiveFires .snceNeg sf b ord).length

/-- Cumulative PASSIVE firings over `k` steps of the same first-arm trajectory sections B and E
walk. Counts the step it is standing on, then recurses; a stuck trajectory contributes nothing
further. -/
def stepPassive : Nat → Branch → TimeOrdering → Nat
  | 0, b, ord => passiveCount b ord
  | k + 1, b, ord =>
    passiveCount b ord +
      match expandOnce b ord .Base with
      | (.extended b', ord') => stepPassive k b' ord'
      | (.split (b' :: _), ord') => stepPassive k b' ord'
      | (.splitOrdered ((b', o') :: _), _) => stepPassive k b' o'
      | (_, _) => 0

/-! ### Row F1 — does the arm fire on the section-B branch at step 0?

The single fact B5′ cannot report. `bB` carries one negative `Until` at time `0` with time `1`
future and unprocessed, so the PASSIVE arm was live on it, and this row read `1` when it was
written and pinned — one commit before the retirement, deliberately, so that the retirement
would be measured rather than asserted. **It now reads `0`, and that is the retirement stated as
a measurement**, in the place B5′ could not state it. -/
/-- info: 0 -/
#guard_msgs in
#eval passiveCount bB ordB

/-! ### Row F2 — cumulative firings along the triggered trajectory

`k = 0, 4, 8, 16, 32, 64, 128`, the same fuels as B5 and E1. A retired arm reads all-zero here;
a capped arm reads a nonzero prefix and then flatlines, which is the shape row E1c predicts and
which is precisely what "the cap is a switch, not a net" means in firings rather than in times.
Neither shape is distinguishable from the other, or from a working repair, on B5′ alone.

**Pre-retirement this row read `[1, 5, 9, 23, 75, 275, 1059]`**, against a B5 triggered
`knownTimes` profile of `[2, 3, 4, 6, 10, 18, 34]` — the arm was not near-dormant the way the
ACTIVE arms are behind their `0 < timeCount < 4` guard, it was the busiest thing on the branch,
firing roughly thirty times per time the branch knew by `k = 128`. B5′ reported none of that,
which is the whole reason this section was built.

**It now reads all-zero at every fuel.** The retirement is complete along the entire trajectory,
not merely at step 0 (which is all F1 can see) and not merely on the hand-built configuration
(which is all B0/B1 can see). This is the row that distinguishes a retired arm from a capped
one: a cap would leave a nonzero prefix here and then flatline. -/
/-- info: [0, 0, 0, 0, 0, 0, 0] -/
#guard_msgs in
#eval [stepPassive 0 bB ordB, stepPassive 4 bB ordB, stepPassive 8 bB ordB,
       stepPassive 16 bB ordB, stepPassive 32 bB ordB, stepPassive 64 bB ordB,
       stepPassive 128 bB ordB]

/-! ### Row F3 — the control trajectory, and the `G`-propagation trajectory

`bBctl` has the negative `Until` deleted, so it is the floor: whatever it reads is firing the
engine does on its own account. `bE` is section E2's branch, where the negative `Until`s are
**manufactured** by `allFuturePos` + `negPos` rather than seeded — so it reports whether the
manufactured sources go on to fire the PASSIVE arm, which is the channel R2 is about.

Both halves were informative pre-retirement, when this row read `([0, 0], [34, 650])`. The
control read `[0, 0]`, so **every** firing counted in F2 was attributable to the negative
`Until`, with no background contribution to net out — unlike B5, where the whole difficulty was
that the engine mints times for its own reasons. And `bE` read `[34, 650]` from a branch that
starts with **zero** negative `Until`s: section E2 showed the `G`-propagation channel
manufacturing new `(source, label)` pairs, and this row showed those manufactured sources going
on to fire the PASSIVE arm hundreds of times. E2 established the channel exists; F3 established
it reached this arm — jointly the sharpest statement of why no interpolant design here has a
bound, and one of the two measurements the retirement was chosen on.

**Now `([0, 0], [0, 0])`.** The control half is unchanged and was always the floor. The `bE`
half going `[34, 650] → [0, 0]` is the load-bearing one: the manufacturing channel is untouched
(E2a still grows, and grew by one), so this zero is the retirement reaching the manufactured
sources too, not the channel drying up. Those are different facts and only this row separates
them. -/
/-- info: ([0, 0], [0, 0]) -/
#guard_msgs in
#eval ([stepPassive 32 bBctl ordB, stepPassive 128 bBctl ordB],
       [stepPassive 32 bE ordB, stepPassive 128 bE ordB])

end BimodalTest.UntlSnceCopyProbe
