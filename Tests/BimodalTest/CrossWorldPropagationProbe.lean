/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability

/-!
# Does the fresh-world temporal copy make the engine decide wrongly? Measured, and it does not

`applyRule`'s `boxNeg` and `diamondPos` arms mint a fresh world and copy three groups of
formulas to it. The third group is the *cross-modal-temporal* one: every `T(GB)`, `T(HB)`,
`F(FB)`, `F(PB)`, `F(U(B,C))` and `F(S(B,C))` standing at the source label's **time**, copied to
the fresh world at that same time, from **any** world.

That copy has no evident semantic justification. `G` is evaluated inside a single history, and
the fresh world's witness history is chosen to falsify `□A` (resp. satisfy `◇A`) and for nothing
else; a second history need not agree with the first about what holds at all later times. So the
question is whether the copy can turn a *satisfiable* branch into a closed one — which, if it
can, would make the procedure report `valid` for an invalid formula.

## The rows

Each row is a formula that is **invalid** — `Ω` may hold a history with a future (resp. past)
`p` while `τ` has none, so the antecedent can hold at `τ` while the `□`-consequent fails — and
that is also shaped to drive exactly the suspect copy: the antecedent leaves a `G`/`F`-negative
formula standing at the root label, and the consequent's `F(□·)` is what fires `boxNeg` and
copies it to the fresh world, where the witness itself supplies the opposite sign.

If the copy were making the engine decide wrongly, these are the shapes on which it would show,
and the verdict would read `true`.

Rows D and E are controls, and both are needed: D pins that the harness reports `true` when it
should, so a row reading `false` is not merely the procedure failing to close anything; E pins
that `false` is reachable on a formula with no temporal content at all.

## What this measures and what it does not

It measures **verdicts**, not steps. A `false` on every row establishes that the copy does not
produce a wrong answer on these shapes. It does *not* establish that the copy preserves
satisfiability, and the two come apart: a step can spoil a satisfiable branch while every branch
it spoils is closable by some other route. The proof obligation recorded in
`Verified/Decidable.lean` ("What `boxNeg` and `diamondPos` still owe") is therefore untouched by
this file — the file exists so that the next dispatch starts from a measurement rather than from
the suspicion this one started with.
-/

namespace BimodalTest.CrossWorldPropagationProbe

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-- Probe atom `p`. -/
def p : Formula := .atom (Atom.mkBase "p")

/-- Probe atom `q`. -/
def q : Formula := .atom (Atom.mkBase "q")

/-! ### Row A — `(¬F p) → □(¬F p)`

Invalid. The root gives `T(¬F p)` and `F(□(¬F p))` at `(w₀, t₀)`; `negPos` turns the first into
`F(F p)` there, which is precisely a `someFutureNeg` formula at `t₀` and so is copied to the
world `boxNeg` mints — where the witness `F(¬F p)` yields `T(F p)` at the same label. -/
/-- info: false -/
#guard_msgs in
#eval isValid ((Formula.someFuture p).neg.imp ((Formula.someFuture p).neg.box))

/-! ### Row B — `(G p) → □(G p)`

Invalid, and the `T(GB)` half of the copy rather than the `F(FB)` half. -/
/-- info: false -/
#guard_msgs in
#eval isValid ((Formula.allFuture p).imp ((Formula.allFuture p).box))

/-! ### Row C — `(¬P p) → □(¬P p)`

Invalid. The past mirror of row A, driving the `F(PB)` half. -/
/-- info: false -/
#guard_msgs in
#eval isValid ((Formula.somePast p).neg.imp ((Formula.somePast p).neg.box))

/-! ### Row D — control, a genuine validity

Pins that the harness reports `true` when it should, so `false` above is a verdict and not a
failure to close. -/
/-- info: true -/
#guard_msgs in
#eval isValid (p.imp p)

/-! ### Row E — control, a genuine invalidity with no temporal content -/
/-- info: false -/
#guard_msgs in
#eval isValid (p.imp q)

end BimodalTest.CrossWorldPropagationProbe
