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

The rows below run the engine and evaluate all three on the resulting open saturated branch. They
are the evidence for the correction: the spread is **false** on branches the engine actually
builds, while the anchor and the grid are both **true** on those same branches. Without them the
choice between the two invariants is a matter of reading `Tableau.lean` carefully enough, which is
precisely what went wrong twice before (`BoxContextClosed`, then `BoxTemporalSpread`).

## Why the spread fails, in one sentence

The world-minting rules copy `allFuturePosAtTime l.time` at the **triggering** label's time only,
while `boxDiamondPersistence` relabels `T(□φ)` into every time the run later mints in that world —
so the box formula spreads across times faster than its temporal consequences spread across
worlds. Note that row A mints its world at the *same* time as the box formula sits at, and still
fails: this is not the cross-time-mint case, it is the later persistence.

## Cost

Each row runs `buildTableau` at fuel `200` and takes on the order of tens of seconds. That is why
these live in the test library and not next to the definitions they check.
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

Read each as: the spread is false, the anchor is true, and the grid — the thing actually
needed — is true. -/

-- A. The minimal witness: one box, one diamond, an unrelated consequent. The world is minted at
-- the same time the box sits at, so the failure is purely the later time-minting.
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=7" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r)

-- B. The witness world carries a temporal universal of its own.
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=7" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia (.allFuture q))) r)

-- C. The same shape under `.Dense`, where the density rules mint further times.
/-- info: "OPEN spread=false anchor=true grid=true |W|=2 |T|=10" -/
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
