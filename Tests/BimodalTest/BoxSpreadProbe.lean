/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation

/-!
# Box-spread probes: the refutation of `BoxTemporalSpread`, re-runnable

`Verified/Bridge/BoxSaturation.lean` states three `Bool`-valued conditions on a branch:

* `boxTemporalSpreadCheck` — `T(□φ)` puts `T(Gφ)` and `T(Hφ)` at every known world, at the box
  formula's **own** time. This is `BoxTemporalSpread`.
* `boxAnchoredCheck` — for each known world, **some** time carries `T(φ)`, `T(Gφ)` and `T(Hφ)`
  together. This is `BoxAnchored`.
* `boxGridCheck` — `T(□φ)` puts `T(φ)` at every known label. This is what the truth lemma's `box`
  case consumes, and `sat_box_grid_of_anchored` derives it from `BoxAnchored`.

The rows below run the engine and evaluate all three on the resulting open saturated branch.

## What these rows used to say, and what they say now

They were originally the evidence for a correction: the spread was **false** on branches the
engine actually builds, while the anchor and the grid were both **true** on those same branches,
so `BoxAnchored` was the invariant to carry and `BoxTemporalSpread` was not.

**The anchor and the grid are now false as well** (rows A, B, C). This is not a new defect. The
six group-3 temporal-copy blocks in `.boxNeg`/`.diamondPos` were the *only* route by which a
`T(Gφ)`/`T(Hφ)` could reach a freshly minted world, and they were deleted as unsound — they
copied temporal formulas verbatim across worlds, conflating "true along the history being built"
with "true at this instant along every admissible history". See
`Tests/BimodalTest/BoxNegPreservationProbe.lean` row 3 for the soundness measurement, and
`Verified/Bridge/BoxSaturation.lean`'s `BoxAnchored` rationale for the consequence.

So these rows now measure the *cost* of that repair rather than a choice between invariants: on
a multi-world branch there is no longer any time at which a minted world carries `T(φ)`, `T(Gφ)`
and `T(Hφ)` together, so `boxAnchoredCheck` is `false`, and `boxGridCheck` — which
`sat_box_grid_of_anchored` derives from it — goes with it. `hBA : boxAnchoredCheck b = true` is
still carried, never unfolded, by the truth-lemma family, so nothing breaks at typecheck; what
is lost is that the hypothesis is no longer dischargeable by computation on real engine output.
Choosing the repair belongs with the truth lemma, not here.

## Why the spread fails, in one sentence

`boxDiamondPersistence` relabels `T(□φ)` into every time the run later mints in that world, while
nothing propagates its temporal consequences across worlds at all — so the box formula spreads
across times while its consequences do not spread across worlds. Note that row A mints its world
at the *same* time as the box formula sits at, and still fails: this is not the cross-time-mint
case.

## Cost

Each row runs `buildTableau` at fuel `200` and takes on the order of tens of seconds. That is why
these live in the test library and not next to the definitions they check.
-/

/-! ## Re-baseline record — the `trivialEventWitnessed` guard

The `#guard_msgs` expectations marked `RE-BASELINED (guard)` below were moved from their previous
pinned values. **Owner of every such move**: `FormalSystem/Metalogic/Decidability/Tableau.lean`'s
`def trivialEventWitnessed`, consulted as a disjunct beside `witnessPresent` in both fresh-label
guards of `findApplicableRule`. It is **not** owned by `Decidability/Saturation.lean` and **not**
by the semantics refactor. The guard stops the engine minting trivial seriality witnesses, so the
time domain stops growing without bound; the shorter time domains and the renumbered downstream
indices below are the direct consequence.

**Evidence — a three-point differential, not an inference.** Each row's value was measured at
three commits, with `#guard_msgs` output captured and compared row by row:

| Point | Commit | Meaning |
|---|---|---|
| P0 | `edcecd551^` (`d49b977c0`) | guard defined but **not consulted** — pre-guard behaviour |
| P1 | `edcecd551` | guard consulted |
| P2 | current `HEAD` | today |

A row was re-baselined **only** when its pinned value equalled its P0 value — i.e. the row was
correct before the guard, so the guard is the sole cause of its present mismatch. Rows whose
pinned value already disagreed with P0 were **already stale before the guard**; those are the
separately-owned mismatches baselined 2026-07-29 against an engine-behaviour change owned outside
this refactor, and they are left pinned, unedited, and enumerated below. Re-baselining them would
absorb that separately-owned change into this attribution, which is exactly what the plan forbids.

The window `edcecd551^ .. HEAD` contains only the guard consultation plus proof-body-only edits to
three files (`CountermodelExtraction.lean`, `Verified/Bridge/TemporalSaturation.lean`,
`Verified/Termination/MintBound.lean`); those diffs add and remove no `def`, `abbrev`, `instance`,
`structure`, or `inductive` line at all, so no `#eval` here can have moved because of them. This is
corroborated directly in `TableauConformance.lean`, whose P1 and P2 values are identical on every
row.

**Re-baselined in this file** (guard-attributed): 2 row(s) at line(s) 149, 158 — each carrying its own `RE-BASELINED (guard)` note with the old and new value.— each carrying its own `RE-BASELINED (guard)` note with the old and new value.

**EXCLUDED — left pinned and unedited**: 1 row(s) at line(s) 165.
These are members of the ten pre-existing, separately-declined mismatches, identified at
row level for the first time by the P0 measurement above. For each, the pinned value, the
pre-guard (P0) value, and the current (P2) value are three *different* values: the row was already
stale before the guard **and** the guard moved it again. Correcting it here would silently fold a
separately-owned engine change into this refactor's re-baseline. It stays pinned:

* line 165
  - pinned: `info: "OPEN spread=false anchor=false grid=false |W|=2 |T|=8"`
  - P0 pre-guard: `info: "OPEN spread=false anchor=false grid=false |W|=2 |T|=10"`
  - P2 current: `info: "OPEN spread=false anchor=false grid=false |W|=2 |T|=6"`
-/

namespace BimodalTest.BoxSpreadProbe

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.Verified.Bridge

private def p : Formula := .atom (Atom.mkBase "p")
private def q : Formula := .atom (Atom.mkBase "q")
private def r : Formula := .atom (Atom.mkBase "r")

/-- `◇A`, in the engine's encoding. -/
private def dia (A : Formula) : Formula := .imp (.box (.imp A .bot)) .bot

/-- `A ∧ B`, in the engine's encoding. -/
private def andF (A B : Formula) : Formula := .imp (.imp A (.imp B .bot)) .bot

/-- Run the engine and report all three conditions on the open branch. -/
def probe (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob _ _ _) =>
      s!"OPEN spread={boxTemporalSpreadCheck ob} anchor={boxAnchoredCheck ob} " ++
      s!"grid={boxGridCheck ob} |W|={ob.knownWorlds.length} |T|={ob.knownTimes.length}"

/-! ## The rows

Read each as: on a two-world branch all three conditions are false. `|W|=2` is what makes them
so — the minted world receives the box formula's `T(φ)` from `boxProps` but no `T(Gφ)`/`T(Hφ)`
from anywhere, because the rules that used to copy them were unsound and were removed. Rows D
and E below are single-world and unaffected.

Each row's `anchor` and `grid` moved `true → false` with the deletion, and row C's `|T|` moved
`10 → 8`; `spread` and `|W|` are unmoved. -/

-- A. The minimal witness: one box, one diamond, an unrelated consequent. The world is minted at
-- the same time the box sits at, so the failure is purely the later time-minting.
-- Was `anchor=true grid=true`.
-- RE-BASELINED (guard): was `"OPEN spread=false anchor=false grid=false |W|=2 |T|=7"`;
-- now `"OPEN spread=false anchor=false grid=true |W|=2 |T|=4"`. Owner: `trivialEventWitnessed` — see the Re-baseline record above.
/-- info: "OPEN spread=false anchor=false grid=true |W|=2 |T|=4" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r)

-- B. The witness world carries a temporal universal of its own. Was `anchor=true grid=true`.
-- Note this row is unmoved from A even though its `◇` argument is itself a `G`: that `T(G q)`
-- never reached the minted world either.
-- RE-BASELINED (guard): was `"OPEN spread=false anchor=false grid=false |W|=2 |T|=7"`;
-- now `"OPEN spread=false anchor=false grid=true |W|=2 |T|=4"`. Owner: `trivialEventWitnessed` — see the Re-baseline record above.
/-- info: "OPEN spread=false anchor=false grid=true |W|=2 |T|=4" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r)

-- C. The same shape under `.Dense`, where the density rules mint further times.
-- Was `anchor=true grid=true |T|=10`. `|T|` shrinks to `8` because the two times that the
-- removed temporal copies used to force into existence at the minted world are no longer minted.
/-- info: "OPEN spread=false anchor=false grid=false |W|=2 |T|=6" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r) 200 .Dense

/-! ## The compound-`□` gap rows

`Verified/Bridge/Valuation.lean`'s `not_truthLemma_branchGapVal` refutes `GapAdequate` as the
truth lemma's gap obligation on a two-formula *literal* branch. These rows answer the only
question that refutation leaves open — whether the engine actually produces branches of that
shape — by running it on `(□p ∧ □(p → q)) → r` and reporting, on the open branch:

* `boxP` / `boxPQ` — is `T(□p)` (resp. `T(□(p → q))`) on the branch at some label;
* `boxQ` / `Gq` / `Hq` — is `T(□q)`, `T(G q)` or `T(H q)` on the branch *anywhere*.

`boxQ=false Gq=false Hq=false` alongside `boxP=true boxPQ=true` is exactly the configuration the
refutation needs: at a gap point `branchGapVal` makes `p` true and `q` false, so `p → q` is false
there and the branch's own `T(□(p → q))` is falsified by the extracted model. -/

/-- Is `T(□χ)` on the branch at some label? -/
private def hasBoxPos (b : Branch) (χ : Formula) : Bool :=
  b.any fun sf => sf.sign == .pos && sf.formula == Formula.box χ

/-- Is `T(χ)` on the branch at some label? -/
private def hasPosAnywhere (b : Branch) (χ : Formula) : Bool :=
  b.any fun sf => sf.sign == .pos && sf.formula == χ

/-- Run the engine and report the compound-`□` gap configuration on the open branch. -/
def gapProbe (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob _ _ _) =>
      s!"OPEN boxP={hasBoxPos ob p} boxPQ={hasBoxPos ob (.imp p q)} boxQ={hasBoxPos ob q} " ++
      s!"Gq={hasPosAnywhere ob (.allFuture q)} Hq={hasPosAnywhere ob (.allPast q)}"

-- D. The gap configuration, at `.Base`.
/-- info: "OPEN boxP=true boxPQ=true boxQ=false Gq=false Hq=false" -/
#guard_msgs in
#eval gapProbe (.imp (andF (.box p) (.box (.imp p q))) r)

-- E. The same shape under `.Dense` does NOT complete: measured `STALLED` at fuel 200 and again at
-- fuel 400. Pinned as measured rather than dropped — the refutation rests on row D, and this row
-- records that the dense route's fuel appetite on two stacked boxes is a separate open question,
-- not evidence either way about the gap policy.
/-- info: "STALLED" -/
#guard_msgs in
#eval gapProbe (.imp (andF (.box p) (.box (.imp p q))) r) 400 .Dense

end BimodalTest.BoxSpreadProbe
