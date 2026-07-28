/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel

/-!
# Ray probes: what a region owes **itself**, and whether the branch already supplies it

`Tests/BimodalTest/RegionGateProbe.lean` measured `regionLabelCheck` and found it `true` on nine
branches the engine builds. That gate imports each region's demands from labels on the *other*
side of it — `T(U(φ,ψ))` at rank `< j` contributes its guard, `F(U(φ,ψ))` at rank `< j` its
subject, and dually for `snce`. No row of the gate asks about what a region's chosen label
demands **of the region itself**.

That distinction is invisible while a region is a single point or a bounded gap and decisive on a
**ray**, because a ray is an infinite region and every one of its points reads the same label:

* the **upper ray** (region `n`) has no point of the carrier above it that is not also in it, so
  `T(U(φ,ψ))` at the ray's chosen label needs its event witness *inside the ray* — which means
  `T(φ)` at that same label;
* the **lower ray** (region `0`) is the mirror, for `T(S(φ,ψ))`.

## What was measured, and what it says

The hypothesis this file was written to test was that the gate accepts branches failing the ray
self-demand, so that the truth lemma's `untl`/`snce` cases could not be closed against
`regionLabelCheck` as it stands. **That hypothesis is refuted on every engine row measured**:
`rayUp` and `rayDn` are `true` on all six, alongside `check=true`. The engine's untils are
witnessed at labels the gate is already willing to choose.

So the ray self-demand is not a refutation of the gate — it is a *candidate additional gate row*,
measured `true` on the corpus **before** being stated anywhere in `Verified/`, which is the order
this task's process lesson insists on. Row G is a synthetic branch on which `check=true` and
`rayUp=false`, so the condition is not vacuous and the additional row would have real content: it
is a genuine strengthening the engine happens to satisfy, not a restatement of the gate.

## Why this matters more at `ℤ` than the plan's premise assumed

`ℤ` was scheduled first on the ground that a contiguous placement has *empty* interior gap
regions, so only the two rays carry a region state. That is true (`Bridge/IntGaps.lean`,
`ray_of_gap_finiteOrderEmbInt`). What it does not deliver is the other half of the dense route:
region invariance (`Bridge/TruthLemma.lean`, `interpInvariantAt`) needs `DenselyOrdered D`, and
`not_exists_gt_sameRegion_int` (`Bridge/Interpolate.lean`) is the machine witness that it fails
at `ℤ`. So at `ℤ` the two rays are infinite regions whose points must be reasoned about one at a
time, while at `ℚ`/`ℝ` region invariance handles each region wholesale. The ray obligation
measured here is therefore the *first* thing the `ℤ` temporal cases meet, not a `ℚ`/`ℝ`
refinement — and the `ℤ`-is-easier premise holds only for the interior, not for the rays.

Rows are `#guard_msgs`-pinned so the measurement is re-runnable and a change to the gate, to
`regionLabel`, or to the engine's output shows up as a failing row rather than being absorbed.
-/
namespace BimodalTest.RayRegionProbe

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

/-! ## The self-demand of a ray -/

/-- Every `T(U(φ,ψ))` the branch asserts at `l` has `T(φ)` at `l` too: the condition an
**upper-ray** label must meet, because the ray contains no witness the branch has placed. -/
private def untlSelfWitnessed (b : Branch) (l : Label) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ _ => if sf.label == l then b.hasPosAt φ l else true
    | _, _ => true

/-- The mirror, for a **lower-ray** label and `snce`. -/
private def snceSelfWitnessed (b : Branch) (l : Label) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ _ => if sf.label == l then b.hasPosAt φ l else true
    | _, _ => true

/-- Does every world's upper-ray label witness its own untils? -/
private def rayUpOk (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    untlSelfWitnessed b ⟨w, regionLabel b ord w b.knownTimes.length⟩

/-- Does every world's lower-ray label witness its own sinces? -/
private def rayDnOk (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w => snceSelfWitnessed b ⟨w, regionLabel b ord w 0⟩

/-- The chosen ray labels' times, world-major: `(lower, upper)` per known world. -/
private def rayLabels (b : Branch) (ord : TimeOrdering) : List (TimeIndex × TimeIndex) :=
  b.knownWorlds.map fun w =>
    (regionLabel b ord w 0, regionLabel b ord w b.knownTimes.length)

/-- Run the engine and report the gate together with the two ray self-demands. -/
def probe (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob ord _ _) =>
      s!"OPEN |W|={ob.knownWorlds.length} |T|={ob.knownTimes.length} " ++
      s!"check={regionLabelCheck ob ord} " ++
      s!"rayUp={rayUpOk ob ord} rayDn={rayDnOk ob ord} rays={rayLabels ob ord}"

/-! ## Rows

Row A is the discriminator this file was written for: `F p → p` is invalid, so the engine
returns an open branch carrying `T(F p)` — the simplest possible eventuality — and the question
is whether the upper ray's chosen label witnesses it.
-/

-- A. `F p → p`. Invalid; the open branch carries `T(F p)` at the root. The upper ray's chosen
-- label is time 3, which carries the `untlPos` witness `T(p)`, so the self-demand is met.
/-- info: "OPEN |W|=1 |T|=6 check=true rayUp=true rayDn=true rays=[(3, 3)]" -/
#guard_msgs in
#eval probe (.imp (Formula.someFuture p) p)

-- B. `P p → p`, the past-directed mirror.
/-- info: "OPEN |W|=1 |T|=7 check=true rayUp=true rayDn=true rays=[(3, 3)]" -/
#guard_msgs in
#eval probe (.imp (Formula.somePast p) p)

-- C. `G p → p`, row E of the 7.1a corpus. Carries no positive until at all.
/-- info: "OPEN |W|=1 |T|=4 check=true rayUp=true rayDn=true rays=[(2, 3)]" -/
#guard_msgs in
#eval probe (.imp (.allFuture p) p)

-- D. `(□p ∧ ◇q) → r`, row A of the 7.1a corpus. Two worlds, and the two rays of the second
-- world choose a different label from the first's — the choice is per world, as intended.
/-- info: "OPEN |W|=2 |T|=7 check=true rayUp=true rayDn=true rays=[(2, 2), (5, 5)]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r)

-- E. `(□p ∧ □(p → q)) → r`, the shape that refuted `GapAdequate`.
/-- info: "OPEN |W|=1 |T|=4 check=true rayUp=true rayDn=true rays=[(2, 2)]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (.box (.imp p q))) r)

-- F. Row A under `.Dense`: density does not change what the ray owes itself.
/-- info: "OPEN |W|=1 |T|=6 check=true rayUp=true rayDn=true rays=[(3, 3)]" -/
#guard_msgs in
#eval probe (.imp (Formula.someFuture p) p) 200 .Dense

/-! ## Non-vacuity: a branch the gate accepts and the ray self-demand rejects

Every row above reports `rayUp=true`, so on its own the block is consistent with the condition
being trivially true. It is not. The branch here carries `T(U(p, ⊤))` at time `0` and `T(p)` only
at time `1`, with `T(⊤)` at both so that the gate's guard row is satisfiable. `regionLabelCheck`
accepts it — every region has an eligible label — and the upper ray's chosen label is time `0`,
which asserts the until and not its event. That is exactly the configuration the engine does not
produce and a hand-built branch can. -/

private def rayTimes : TimeOrdering := { constraints := [(0, 1)] }

private def rayRefuteBranch : Branch :=
  [ SignedFormula.pos (.untl p .top) ⟨0, 0⟩
  , SignedFormula.pos Formula.top ⟨0, 0⟩
  , SignedFormula.pos Formula.top ⟨0, 1⟩
  , SignedFormula.pos p ⟨0, 1⟩ ]

-- G. The gate accepts; the ray self-demand does not.
/-- info: "check=true rayUp=false rayDn=true rays=[(0, 0)]" -/
#guard_msgs in
#eval s!"check={regionLabelCheck rayRefuteBranch rayTimes} " ++
  s!"rayUp={rayUpOk rayRefuteBranch rayTimes} rayDn={rayDnOk rayRefuteBranch rayTimes} " ++
  s!"rays={rayLabels rayRefuteBranch rayTimes}"

end BimodalTest.RayRegionProbe
