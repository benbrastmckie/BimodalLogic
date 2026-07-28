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

end BimodalTest.BoxSpreadProbe
