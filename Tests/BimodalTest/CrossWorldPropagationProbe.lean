/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability

/-!
# The fresh-world temporal copy: what `isValid` could and could not see — and why row F exists

**The copy this file was written to investigate no longer exists.** `applyRule`'s `boxNeg` and
`diamondPos` arms used to mint a fresh world and copy three groups of formulas to it; the third
group was the *cross-modal-temporal* one — every `T(GB)`, `T(HB)`, `F(FB)`, `F(PB)`, `F(U(B,C))`
and `F(S(B,C))` standing at the source label's **time**, copied to the fresh world at that same
time, from **any** world. Those six blocks were deleted from both rules as unsound. Each rule now
emits `.linear (witness :: boxProps ++ diaProps)`.

The copy had no semantic justification. `G` is evaluated inside a single history, while the fresh
world's witness history is chosen to falsify `□A` (resp. satisfy `◇A`) and for nothing else; a
second history need not agree with the first about what holds at all later times.
`Tests/BimodalTest/BoxNegPreservationProbe.lean` row 3 measured the consequence directly — the
rule mapped a satisfiable branch to one carrying the same formula at the same label with opposite
signs — and `Tests/BimodalTest/BoxNegReachabilityProbe.lean` showed the engine really did build
that branch.

## This file's original thesis was superseded, and how

The title used to read "Measured, and it does not [decide wrongly]". Rows A-E all still pin the
values they always pinned — **not one of the five moved** across the deletion. That is the
problem, and it is why row F was added.

`isValid` is `(decide φ).isValid`, which is `true` only for the `.valid` constructor. It
therefore reads `false` under `.invalid`, `.fuelExhausted` and `.extractionFailed` alike. Before
the deletion, row B's `false` was `decide` returning **`extractionFailed`** — `buildTableau` had
*closed* the tableau on this invalid formula, i.e. asserted it valid, and proof extraction then
failed. This file read that `false` as "the correct verdict on an invalid formula" and concluded
no defect was in evidence. The conclusion did not follow from the measurement: the row could not
distinguish a correct refutation from a wrong closure.

## The rows

Rows A-C are formulas that are **invalid** — some total history may carry a future (resp. past)
`p` while `τ` has none, so the antecedent can hold at `τ` while the `□`-consequent fails — and
that were also shaped to drive exactly the suspect copy.

Rows D and E are controls, and both are needed: D pins that the harness reports `true` when it
should, so a row reading `false` is not merely the procedure failing to close anything; E pins
that `false` is reachable on a formula with no temporal content at all.

**Row F is the discrimination rows A-C cannot make**, pinning the `decide` *constructor* rather
than `isValid`'s collapse of it. Its subject formula `(G p) → □(G p)` has been through three
distinct states, and only the constructor tells them apart:

1. **A wrong answer.** `extractionFailed`: `buildTableau` *closed* the tableau on this invalid
   formula, which under this codebase's R7 semantics (`isKnownValid` holds of
   `extractionFailed`) asserts the formula **valid**. The cross-modal-temporal copy deleted
   above is what built that closing branch.
2. **No answer.** `fuelExhausted`, which `isUndecided` recognises as honest ignorance. A strict
   improvement in soundness, and an unfinished job on completeness.
3. **The right answer**, and this is what row F pins today:
   `(false, true, false, false, false)` — `.invalid`, with `getCountermodel?.isSome = true`. The
   branch reaches `.invalid` by *saturating an open branch*, the opposite of closing, so nothing
   here invites the deleted copy back: reinstating it would re-close the branch and restore the
   false claim of validity.

The move from state 2 to state 3 is owned by `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
`trivialEventWitnessed` guard, which suppresses an eventuality whose event is syntactically
`Formula.top` and so lets this branch saturate. The budget it needs is small and was measured:
`buildTableau ((G p).imp (G p).box) n .Base` is `none` for every `n ≤ 24` and `hasOpen` with a
stationary 40-formula certified branch for every `n ≥ 25` out to 1000. The ceiling of 25 is
recorded, with its headroom against the proved bounds, on `soundFuel'` in
`FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean`.

`BoxNegReachabilityProbe.lean` rows 9-12 pin the same distinction from the other side, on the
same formula.
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

/-! ### Row F — the `decide` constructor on row B's formula, which row B cannot see

Added because rows A-E are all `isValid`, and `isValid` is `true` only for `.valid`: every one of
them reads `false` under `.invalid`, `.fuelExhausted` and `.extractionFailed` alike. This row
pins the constructor itself, so a future change that moves `(G p) → □(G p)` between those three
outcomes cannot pass unnoticed.

The tuple is `(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)`, matching
`BoxNegReachabilityProbe.lean` row 10.

* **Before the deletion**: `(false, false, false, true, false)` — `extractionFailed`. The tableau
  closed on an invalid formula, which by this codebase's R7 semantics (`isKnownValid` is true for
  `extractionFailed`) is an assertion that the formula is **valid**. That assertion was false.
* **Then**: `fuelExhausted`, which `isUndecided` recognises as honest ignorance.
* **Now**: `(false, true, false, false, false)` — `.invalid`. The positive refutation this
  formula is owed has arrived, and pinning that fact is now this row's job.

* **Old (pinned) value**: `(false, false, true, false, true)` (`fuelExhausted`)
* **New (measured) value**: `(false, true, false, false, false)` (`invalid`)
* **Owner of the move**: `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
  `def trivialEventWitnessed` and its two consultation sites — **not**
  `Decidability/Saturation.lean` and **not** the semantics refactor. Identical move to
  `BoxNegReachabilityProbe.lean` row 10, on the same formula, as this row's design intends. -/
/-- info: (false, true, false, false, false) -/
#guard_msgs in
#eval let d := decide ((Formula.allFuture p).imp ((Formula.allFuture p).box))
      (d.isValid, d.isInvalid, d.isFuelExhausted, d.isExtractionFailed, d.isUndecided)

end BimodalTest.CrossWorldPropagationProbe
