# Phase 7 (fourth dispatch): `BoxAnchored` and the closure duality

**Status:** Phase 7 remains `[PARTIAL]`. `phases_completed` stays at 6 of 8.
**Builds:** `lake build FormalSystem.Metalogic.Decidability` green (1109 jobs);
`lake build BimodalTest` green (1961 jobs). Sorry census over `Verified/` reports `0`.
No engine file touched.

## What this dispatch was asked for, and what it found

The dispatch inherited two residuals from the 2026-07-28g banner. Neither turned out to be
what it was described as.

### Obligation B — `TimeOrderConverse` was already proved

The banner budgeted a fuel-bounded breadth-first-search duality: forward and backward
shortest-path depths agree, so equal fuel suffices. That proof already exists, in
`Verified/Termination/Fuel.lean`, as `orderDual_holds` — for **every** `TimeOrdering`, via
`open private reachableForward reachableBackward` plus the shared breadth-first shape
`bfsClosure`, with `bfsClosure_sound` for the forward half, `PathN.reverse` for the
edge-by-edge reversal, and `bfsClosure_complete` with the `BfsInv` visited-set invariant for
the backward half. `OrderDual` and `TimeOrderConverse` are the same statement.

The deliverable is therefore a rename, `timeOrderConverse`, plus the import that makes it
reachable from the bridge. Every `hConv` hypothesis downstream is now dischargeable at the
call site rather than propagated.

The two names are deliberately kept apart: the fuel module reaches the duality for a
termination purpose (`timeChain_of_linearity_saturated`) that has nothing to do with the box
grid, and merging them would couple two unrelated concerns.

### Obligation A — `BoxTemporalSpread` is refuted, and the refutation is measured

The banner named `BoxTemporalSpread` as the invariant the construction maintains, on the
strength of the world-minting copy: `boxNeg`/`diamondPos` copy `branch.allFuturePosAtTime
l.time` and `branch.allPastPosAtTime l.time` — all worlds — onto the fresh world
(`Tableau.lean:553-559`). That reading of the copy is correct.

What it misses is that the copy happens at **one** time — the *triggering* label's `l.time` —
while the box formula does not stay at one time. `boxDiamondPersistence` relabels `T(□φ)` from
`(w, t)` to `(w, freshTime)`, so a single `T(□φ)` on the seed branch becomes a `T(□φ)` at every
time the run later mints in that world. `BoxTemporalSpread` then demands `T(Gφ)` at the fresh
world at every one of those times, of which the mint supplied exactly one.

This is measured rather than argued. Running the engine on `(□p ∧ ◇q) → r` at `.Base` with
fuel `200` yields an OPEN saturated branch over 2 worlds and 7 times on which
`boxTemporalSpreadCheck` is `false`. Note that the world there is minted at the **same** time
the box formula sits at — so the failure is not the cross-time-mint case one would guess at;
it is the later persistence. `(□p ∧ ◇(G q)) → r` and the `.Dense` run of the same formula fail
identically. The rows live in `Tests/BimodalTest/BoxSpreadProbe.lean` as `#guard_msgs`, so the
refutation is re-runnable rather than assertable in prose — the same standard
`not_leftCopy_gapAdequate` set for the gap policies.

`boxAnchoredCheck` and `boxGridCheck` are both `true` on every branch that refutes the spread.

## What replaces it

`BoxAnchored`: for every `T(□φ)` on the branch and every known world `w'`, **some** known time
`s` carries `T(φ)`, `T(Gφ)` and `T(Hφ)` together at `w'`. Two differences from the spread, and
the refutation forces both — the time is existential rather than pinned to the box formula's
own `l.time`, and the content `T(φ)` is demanded alongside `T(Gφ)`/`T(Hφ)`, because the `t' = s`
case of the trichotomy has no `G`/`H` to appeal to (both are strict).

`sat_box_grid_of_anchored` derives the truth lemma's grid from it, by `knownTime_trichotomy`
taken about the anchor rather than about the box formula's own time, with `TimeOrderConverse`
now discharged rather than hypothesised. `boxAnchored_of_boxTemporalSpread` records that
nothing is lost by the weakening.

## Correction 8 — the box invariant does not want a construction induction

`timeOrderTotal`, the grid's *other* branch-level side condition, is nowhere proved invariant
under expansion in this development. It is a decidable check on the finished branch, carried as
`hTot : timeOrderTotal b timeOrd = true` and discharged per run by computation.

`BoxAnchored` has exactly the same character: a first-order condition on a finite branch,
decidable in the branch, and needed only for the one saturated branch `hasOpen` returns.
`boxAnchored_of_check` gives it the same treatment, and `sat_box_grid_of_check` is the composed
form the truth lemma consumes, with both side conditions as `Bool` equations.

This is what turns the residual from "induct over `expandOnceUnblocked` across every rule in
`allRulesForFC`, including the two that mint worlds and the six that mint times" into "evaluate
a `Bool`". A construction-level proof of `BoxAnchored` remains worth having as hygiene; it is
not on the truth lemma's critical path, and treating it as if it were is what the previous two
dispatches spent themselves on.

## Declarations added

`Verified/Bridge/BoxSaturation.lean` (purely additive — every earlier declaration retained, so
the refuted invariants stay visible):

- `timeOrderConverse` — the closure duality, discharged for every ordering.
- `BoxAnchored`, `boxAnchored_of_boxTemporalSpread`, `boxAnchored_of_check`.
- `boxTemporalSpreadCheck`, `boxAnchoredCheck`, `boxGridCheck` — the three conditions in
  decidable form, so the probe rows can evaluate them against engine output.
- `sat_box_grid_of_anchored`, `sat_box_grid_of_check`.

`Tests/BimodalTest/BoxSpreadProbe.lean` (new, registered in `Tests/BimodalTest.lean`) — three
`#guard_msgs` rows carrying the refutation.

`Verified/Bridge/TruthLemma.lean` — documentation only. The "What the truth lemma still needs"
section was stale in two of its three items (O1 and O3 had both landed) and has been rewritten
as an interface index naming the file and declaration for each of O1, O2 and O3, plus the two
refuted box invariants and why neither should be reached for again.

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1109 jobs |
| `lake build BimodalTest` | green, 1961 jobs; all `#guard_msgs` rows pass |
| sorry census, `Verified/` | `sorry_count: 0` |
| axioms, `timeOrderConverse` | `propext`, `Quot.sound` |
| axioms, `sat_box_grid_of_anchored`, `boxAnchored_of_boxTemporalSpread` | `propext`, `Classical.choice`, `Quot.sound` |

Known out-of-territory RED, pre-existing and untouched: full `lake build` fails at
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`.

## What remains in 7.1

One item, and it is the mathematical content: the **truth-lemma induction** itself —
`not_valid_of_hasOpen`, generic in `TemporalCarrier`, consuming the `sat_*` family and the three
now-complete interfaces. `TruthLemma.lean` is the file the next dispatch should open.

7.2 (semantic rule soundness as one induction over `allRulesForFC`) and 7.3
(`valid_iff_allClosed` + the four `Decidable` instances) are not started.

## Process lesson, recorded because both residuals hit it

Two cheap habits would have saved the previous dispatch's budget and this one's redirect:

1. **Grep the `Verified/` tree for an obligation's statement before budgeting a proof.**
   `orderDual_holds` had been sitting in `Fuel.lean` under a different name.
2. **Machine-probe a candidate invariant on real engine output before proving anything about
   it.** Both `BoxContextClosed` and `BoxTemporalSpread` were adopted by reading `Tableau.lean`
   carefully and both were wrong; a decidable check and three `#eval` rows settle the question
   in minutes.
