/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel

/-!
# What the `untl`/`snce` cases actually demand of a saturated branch, measured before it is stated

`Tests/BimodalTest/RayRegionProbe.lean` measured one candidate demand — the **ray self-demand**,
`T(U(φ,ψ))` at a ray's chosen label needs `T(φ)` at that same label — and found it `true` on six
engine rows. This file measures the rest of the bundle, and it exists because of a gap in that
corpus: **not one of those six rows carries a genuine until.** `F p → p`, `P p → p`, `G p → p`
and the three modal shapes produce only `untl · ⊤` and `snce · ⊤`, where the acting rules are
`someFuturePos`/`someFutureNeg` (linear, and `sat_some_future_neg` already gives `F(φ)` at
*every* known future time). The branching `untlPos`/`untlNeg` rules — the ones whose second arm
is `T(guard) ∧ T(U)` resp. `F(guard) ∧ F(U)` — are never exercised. Any conclusion about them
drawn from that corpus is a conclusion about a case the corpus does not contain.

Rows H–L below are genuine untils and sinces (`U(p,q) → q`, `p → U(p,q)`, and mirrors), so the
branching arms fire.

## The six conditions per operator, and why each is the one the case needs

Write `r` for a carrier point, `L_r` for the label it reads (`stateLabel`), and recall that at
`ℤ` the placement is contiguous: between consecutive placed points there is **nothing**, and
every non-placed integer is on the lower ray (below all placed points) or the upper ray (above
all of them).

*Positive `untl` at a placed point.* `TruthAt … (untl φ ψ)` wants `s > r` with `φ` at `s` and `ψ`
at **every** carrier point strictly between. Contiguity turns "every carrier point strictly
between" into "every placed point strictly between", i.e. every known time strictly between the
two. So the case needs a φ-witness (`posWitness`) and the guard at every known time below the
*earliest* such witness. `posDichotomy` — every known future time carries `T(φ)` or `T(ψ)` — is
the clean sufficient form: below the earliest φ-witness no time carries `T(φ)`, so every one of
them carries `T(ψ)`.

*Positive `untl` on the upper ray.* Every point above an upper-ray point is on the same ray and
reads the same label, so the witness must be that label itself: `rayPos` is `RayRegionProbe`'s
`rayUp`, restated here so the whole bundle is measured in one place.

*Negative `untl`.* `F(U(φ,ψ))` at `L_r` must make `untl φ ψ` **false** at `r`, i.e. every `s > r`
either fails `φ` or has a `¬ψ` point strictly inside `(r,s)`. `negStrong` (`F(φ)` at every known
future time) settles it outright and is what `sat_some_future_neg` gives when `ψ = ⊤`.
`negCoDec` is the weaker, semantically exact form. `rayNeg` is the upper-ray instance: all points
above a ray point read one label, so that label must carry `F(φ)`.

`sat_untl_neg` as it stands gives only `F(φ)@t' ∨ F(ψ)@t'` for each known future `t'` — the
second arm's `F(U(φ,ψ))@t'` propagation is discarded — and neither disjunct alone settles the
`s = t'` case, where the guard interval `(r,s)` is empty. That is the specific reason `negStrong`
and `negCoDec` are measured rather than assumed.

## What was measured

Three findings, none of them the one this file was written expecting.

**1. `posDichotomy` is refuted, and for a syntactic reason that governs the whole design.**
"Every known future time carries `T(φ)` or `T(ψ)`" is `false` on nine of the twelve rows —
including rows A, B, D and F, which contain no genuine until at all. The cause is that the guard
of a `someFuture` is `⊤`, and **the engine never writes `T(⊤)` on a branch**: `⊤` is true at every
point of every model without any branch fact saying so. Any candidate row that asks the branch to
*assert* the guard therefore fails on the entire `someFuture`/`somePast` fragment, for a reason
that has nothing to do with untils. The rows below consequently exempt `ψ = ⊤` explicitly, which
is the same split `sat_untl_pos` already makes (`by_cases hg : guard = Formula.top`); the `⊤` case
is discharged semantically, not from the branch.

**2. With that exemption, every candidate row holds on every row the existing gate accepts.**
On all eight rows reporting `check=true` — A, B, C, D, E, F, I, K — all ten of `gw`, `rdG`, `ruG`,
`wit`, `nStr`, `nCo`, `rP`, `rN` and their mirrors report `true`. Every `false` in the block sits
on one of the four rows (H, J, M, N) where `regionLabelCheck` **already** reports `false`. So the
bundle is a candidate *additional* gate, in the family `timeOrderTotal`/`boxAnchoredCheck`/
`regionLabelCheck` belongs to, and it is nowhere in conflict with the gate already landed.

**3. `negStrong` is true on all twelve rows, including the four the gate rejects.** `F(U(φ,ψ))` at
`(w,t)` puts `F(φ)` at *every* known time after `t`, genuine guard or not. That is much stronger
than `sat_untl_neg`'s `F(φ)@t' ∨ F(ψ)@t'` and it settles the negative case outright, with no
minimal-witness argument and no reasoning about the guard interval.

**4. A second candidate is refuted: `untlNegAllRegions`.** "Every region label of a world denies
the event of every negative until in that world" is `false` on rows C and I, both of which the
gate accepts. It overreaches: `Bridge/RegionLabel.lean`'s `untlNegSubjects` demands the subject
only of untils asserted *strictly below* the region, which is the correct side condition — a
region below the until's own time contains no point above the evaluation point and is under no
obligation. The negative case therefore consumes the **existing** `regionLabel_untlNeg` for the
non-placed points and needs a new row only for the placed ones.

**5. The lower-ray negative demand is adoptable, and the strong form is free.** `untlNegRayLow` —
"a negative until asserted at its world's lower-ray label denies its event at *every* known time"
— is `true` on eleven of twelve rows, the single `false` being row N, where `regionLabelCheck` is
already `false`. The strictly weaker "at its own label only" variant fails on exactly that same
row, so extending the demand from the ray label to the whole of `b.knownTimes` costs nothing
anywhere in the corpus, and the strong form is the one the case actually needs. This is
Correction 12's negative residual, and it and its mirror `snceNegRayUp` are now rows 5 and 6 of
`Bridge/TemporalGate.lean`'s `temporalWitnessCheck`. See the "lower-ray negative demand" section
at the foot of this file.

**6. The two positive rows are adoptable only in strengthened forms, and both strengthenings are
free.** `gw` and `rdG` are measured but neither is usable as it stands. `gw` exempts the *whole*
row when `ψ = ⊤`, so it says nothing on the `someFuture` fragment — where the positive case still
needs a witness — and `rdG` permits the escape "the event sits at the ray's own label", which does
not close the lower-ray leaf because the ray label is a known time with placed points below it,
all of them inside the guard interval. `uGW` and `uRD` (and their mirrors) move the `⊤` exemption
inside the witness and delete the escape; both are `true` on all eight rows the gate accepts, and
neither ever differs from the weaker form it strengthens anywhere in the twelve. See "The positive
rows, in the exact form the proof consumes them" at the foot of this file. These are rows 7-10 of
`Bridge/TemporalGate.lean`'s `temporalWitnessCheck`.

**A finding outside this file's scope, recorded because it is load-bearing elsewhere.**
`regionLabelCheck` is `false` on rows H, J, M and N — the branches the engine builds for
`U(p,q) → q` and `S(p,q) → q`. `regionLabelCheck b ord = true` is a *hypothesis* of
`not_valid_of_hasOpen_int`, so nothing already proved is affected; but sub-phase 7.3, which has
to discharge that hypothesis for the branches the engine actually produces, cannot discharge it
for these. That is a 7.3 obligation, measured here rather than discovered there.

## How to read a `false`

A `false` here is **not** a defect of the branch gates already landed. It is the measurement that
the corresponding row cannot be adopted as an additional gate row, and it must be recorded as a
DO-NOT-RE-ATTEMPT entry rather than proved around. `posDichotomy` is exactly that: finding 1
above is its DO-NOT-RE-ATTEMPT entry.
-/
namespace BimodalTest.TemporalWitnessProbe

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.Verified.Bridge

private def p : Formula := .atom (Atom.mkBase "p")
private def q : Formula := .atom (Atom.mkBase "q")
private def r : Formula := .atom (Atom.mkBase "r")

/-! ## Time slices -/

/-- The known times strictly after `t`, in the branch's own order. -/
private def futTimes (b : Branch) (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  b.knownTimes.filter fun v => strictBefore ord t v

/-- The known times strictly before `t`. -/
private def pastTimes (b : Branch) (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  b.knownTimes.filter fun v => strictBefore ord v t

/-! ## The six `untl` conditions -/

/-- Every known time strictly after a positive until's own time carries the event or the guard. -/
private def untlPosDichotomy (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ ψ =>
        (futTimes b ord sf.label.time).all fun v =>
          b.hasPosAt φ ⟨sf.label.world, v⟩ || b.hasPosAt ψ ⟨sf.label.world, v⟩
    | _, _ => true

/-- Some known time strictly after a positive until's own time carries the event. -/
private def untlPosWitness (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ _ =>
        (futTimes b ord sf.label.time).any fun v => b.hasPosAt φ ⟨sf.label.world, v⟩
    | _, _ => true

/-- Every known time strictly after a negative until's own time denies the event. -/
private def untlNegStrong (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ _ =>
        (futTimes b ord sf.label.time).all fun v => b.hasNegAt φ ⟨sf.label.world, v⟩
    | _, _ => true

/-- The semantically exact co-decomposition: each known future time either denies the event or
has a known time strictly between it and the until's own time denying the guard. -/
private def untlNegCoDec (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ ψ =>
        (futTimes b ord sf.label.time).all fun v =>
          b.hasNegAt φ ⟨sf.label.world, v⟩ ||
            (futTimes b ord sf.label.time).any fun u =>
              strictBefore ord u v && b.hasNegAt ψ ⟨sf.label.world, u⟩
    | _, _ => true

/-- The upper ray's chosen label witnesses its own positive untils. -/
private def untlRayPos (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    let l : Label := ⟨w, regionLabel b ord w b.knownTimes.length⟩
    b.all fun sf =>
      match sf.sign, sf.formula with
      | .pos, .untl φ _ => if sf.label == l then b.hasPosAt φ l else true
      | _, _ => true

/-- The upper ray's chosen label denies the event of its own negative untils. -/
private def untlRayNeg (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    let l : Label := ⟨w, regionLabel b ord w b.knownTimes.length⟩
    b.all fun sf =>
      match sf.sign, sf.formula with
      | .neg, .untl φ _ => if sf.label == l then b.hasNegAt φ l else true
      | _, _ => true

/-! ## The six `snce` mirrors -/

private def sncePosDichotomy (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ ψ =>
        (pastTimes b ord sf.label.time).all fun v =>
          b.hasPosAt φ ⟨sf.label.world, v⟩ || b.hasPosAt ψ ⟨sf.label.world, v⟩
    | _, _ => true

private def sncePosWitness (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ _ =>
        (pastTimes b ord sf.label.time).any fun v => b.hasPosAt φ ⟨sf.label.world, v⟩
    | _, _ => true

private def snceNegStrong (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ _ =>
        (pastTimes b ord sf.label.time).all fun v => b.hasNegAt φ ⟨sf.label.world, v⟩
    | _, _ => true

private def snceNegCoDec (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ ψ =>
        (pastTimes b ord sf.label.time).all fun v =>
          b.hasNegAt φ ⟨sf.label.world, v⟩ ||
            (pastTimes b ord sf.label.time).any fun u =>
              strictBefore ord v u && b.hasNegAt ψ ⟨sf.label.world, u⟩
    | _, _ => true

private def snceRayPos (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    let l : Label := ⟨w, regionLabel b ord w 0⟩
    b.all fun sf =>
      match sf.sign, sf.formula with
      | .pos, .snce φ _ => if sf.label == l then b.hasPosAt φ l else true
      | _, _ => true

private def snceRayNeg (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    let l : Label := ⟨w, regionLabel b ord w 0⟩
    b.all fun sf =>
      match sf.sign, sf.formula with
      | .neg, .snce φ _ => if sf.label == l then b.hasNegAt φ l else true
      | _, _ => true


/-- **The row the positive case actually needs.** Some known time strictly after the until's own
time carries the event, *and* every known time strictly between the two carries the guard. This
is `untlPosDichotomy` weakened to the times below the chosen witness — the only ones the
contiguous `ℤ` placement puts strictly inside the interval. -/
private def untlPosGuardedWitness (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ ψ =>
        ψ == Formula.top ||
        (futTimes b ord sf.label.time).any fun t =>
          b.hasPosAt φ ⟨sf.label.world, t⟩ &&
            (futTimes b ord sf.label.time).all fun v =>
              !strictBefore ord v t || b.hasPosAt ψ ⟨sf.label.world, v⟩
    | _, _ => true

/-- The mirror. -/
private def sncePosGuardedWitness (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ ψ =>
        ψ == Formula.top ||
        (pastTimes b ord sf.label.time).any fun t =>
          b.hasPosAt φ ⟨sf.label.world, t⟩ &&
            (pastTimes b ord sf.label.time).all fun v =>
              !strictBefore ord t v || b.hasPosAt ψ ⟨sf.label.world, v⟩
    | _, _ => true

/-- The **lower-ray** positive `untl` demand: a point below every placed point reads the label
`regionLabel … 0`, and every carrier point between it and a placed witness is either another
lower-ray point (same label) or a placed point below the witness. So the ray's own label must
carry the guard, and the guard must reach every known time below the witness — not merely those
above the ray label. -/
private def untlRayDnGuard (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    let l : Label := ⟨w, regionLabel b ord w 0⟩
    b.all fun sf =>
      match sf.sign, sf.formula with
      | .pos, .untl φ ψ =>
          if sf.label == l && ψ != Formula.top then
            b.hasPosAt φ l ||
              (b.hasPosAt ψ l &&
                b.knownTimes.any fun t =>
                  b.hasPosAt φ ⟨w, t⟩ &&
                    b.knownTimes.all fun v =>
                      !strictBefore ord v t || b.hasPosAt ψ ⟨w, v⟩)
          else true
      | _, _ => true

/-- The mirror, on the **upper ray** for `snce`. -/
private def snceRayUpGuard (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    let l : Label := ⟨w, regionLabel b ord w b.knownTimes.length⟩
    b.all fun sf =>
      match sf.sign, sf.formula with
      | .pos, .snce φ ψ =>
          if sf.label == l && ψ != Formula.top then
            b.hasPosAt φ l ||
              (b.hasPosAt ψ l &&
                b.knownTimes.any fun t =>
                  b.hasPosAt φ ⟨w, t⟩ &&
                    b.knownTimes.all fun v =>
                      !strictBefore ord t v || b.hasPosAt ψ ⟨w, v⟩)
          else true
      | _, _ => true

/-! ## Reporting -/

/-- Do any genuine (non-`⊤`-guarded) untils or sinces appear at all? Without this the row is
measuring the `someFuture`/`somePast` fragment and says nothing about the branching arms. -/
private def hasGenuine (b : Branch) : Bool :=
  b.any fun sf =>
    match sf.formula with
    | .untl _ ψ => ψ != Formula.top
    | .snce _ ψ => ψ != Formula.top
    | _ => false

private def report (b : Branch) (ord : TimeOrdering) : String :=
  s!"gen={hasGenuine b} check={regionLabelCheck b ord} " ++
  s!"U[dich={untlPosDichotomy b ord} wit={untlPosWitness b ord} gw={untlPosGuardedWitness b ord} rdG={untlRayDnGuard b ord} " ++
  s!"nStr={untlNegStrong b ord} nCo={untlNegCoDec b ord} " ++
  s!"rP={untlRayPos b ord} rN={untlRayNeg b ord}] " ++
  s!"S[dich={sncePosDichotomy b ord} wit={sncePosWitness b ord} gw={sncePosGuardedWitness b ord} ruG={snceRayUpGuard b ord} " ++
  s!"nStr={snceNegStrong b ord} nCo={snceNegCoDec b ord} " ++
  s!"rP={snceRayPos b ord} rN={snceRayNeg b ord}]"

/-- Run the engine and report the whole bundle. -/
def probe (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob ord _ _) =>
      s!"OPEN |T|={ob.knownTimes.length} " ++ report ob ord


private def dia (A : Formula) : Formula := .imp (.box (.imp A .bot)) .bot
private def andF (A B : Formula) : Formula := .imp (.imp A (.imp B .bot)) .bot

/-! ## Rows

Rows A–F are the six shapes `RayRegionProbe.lean` measured, carried over verbatim so the two
files can be read against each other. Every one reports `gen=false`: they contain no genuine
until or since at all, which is the gap this file exists to fill. Rows H–N are genuine.

The pinned strings are the whole measurement. The reading is in the module docstring's
"What was measured" section; in one line, **every row with `check=true` reports `true` on all
ten candidate rows, and every `false` sits on a row where `regionLabelCheck` is already
`false`.**
-/

-- A. `F p → p`.
/-- info: "OPEN |T|=6 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (Formula.someFuture p) p)

-- B. `P p → p`.
/-- info: "OPEN |T|=7 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (Formula.somePast p) p)

-- C. `G p → p`.
/-- info: "OPEN |T|=4 gen=false check=true U[dich=true wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (.allFuture p) p)

-- D. `(□p ∧ ◇q) → r`.
/-- info: "OPEN |T|=7 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (dia q)) r)

-- E. `(□p ∧ □(p → q)) → r`.
/-- info: "OPEN |T|=4 gen=false check=true U[dich=true wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (andF (.box p) (.box (.imp p q))) r)

-- F. Row A under `.Dense`.
/-- info: "OPEN |T|=6 gen=false check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (Formula.someFuture p) p) 200 .Dense

/-! ### Genuine untils and sinces — the branching arms

`U(p,q) → q` and `S(p,q) → q` put a **positive** genuine until (resp. since) on the branch, so
`untlPos`/`sncePos` fire with their two-armed conclusion. `p → U(p,q)` and `p → S(p,q)` put a
**negative** one there, firing `untlNeg`/`snceNeg`. These four are the shapes rows A–F do not
contain.
-/

-- H. `U(p,q) → q`, a positive genuine until. **`regionLabelCheck` itself reports `false`**, and
-- the two rows that fail (`gw`, `rP`) fail on that same branch — see the docstring.
/-- info: "OPEN |T|=6 gen=true check=false U[dich=false wit=true gw=false rdG=true nStr=true nCo=true rP=false rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (.untl p q) q)

-- I. `p → U(p,q)`, a negative genuine until. The gate accepts, and every candidate row holds.
/-- info: "OPEN |T|=4 gen=true check=true U[dich=true wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp p (.untl p q))

-- J. `S(p,q) → q`, the mirror of H, and the gate reports `false` in the same way.
/-- info: "OPEN |T|=7 gen=true check=false U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=false rN=true]" -/
#guard_msgs in
#eval probe (.imp (.snce p q) q)

-- K. `p → S(p,q)`, the mirror of I. The gate accepts, and every candidate row holds.
/-- info: "OPEN |T|=4 gen=true check=true U[dich=false wit=true gw=true rdG=true nStr=true nCo=true rP=true rN=true] S[dich=true wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp p (.snce p q))

-- L. `U(p,q) → U(q,p)`: a genuine until on **both** signs. The engine stalls at this fuel — the
-- row is pinned so that a future engine change which makes it terminate is visible rather than
-- silently absorbed.
/-- info: "STALLED" -/
#guard_msgs in
#eval probe (.imp (.untl p q) (.untl q p))

-- M. Row H under `.Dense`: the frame class does not move any of the twelve verdicts.
/-- info: "OPEN |T|=6 gen=true check=false U[dich=false wit=true gw=false rdG=true nStr=true nCo=true rP=false rN=true] S[dich=false wit=true gw=true ruG=true nStr=true nCo=true rP=true rN=true]" -/
#guard_msgs in
#eval probe (.imp (.untl p q) q) 200 .Dense

-- N. Row I under `.Discrete`. `regionLabelCheck` reports `false` here where it reported `true`
-- at `.Base`, and four candidate rows go with it — the frame class changes the branch, not the
-- relationship between the gate and the bundle.
/-- info: "OPEN |T|=4 gen=true check=false U[dich=true wit=true gw=true rdG=false nStr=true nCo=true rP=false rN=false] S[dich=false wit=true gw=false ruG=false nStr=true nCo=true rP=false rN=true]" -/
#guard_msgs in
#eval probe (.imp p (.untl p q)) 200 .Discrete

/-! ## A candidate that is refuted: the region labels are not uniformly negative

The negative `untl` case at a placed point needs `¬φ` at every carrier point above it, and the
points above it that are **not** placed read a region label. The obvious candidate row is that a
world's region labels all deny the event of every negative until in that world. They do not.

The reason is instructive and is exactly why the row is not needed: `Bridge/RegionLabel.lean`'s
`untlNegSubjects` already demands the subject of every `F(U(φ,ψ))` asserted **strictly below**
region `j`, and `regionLabel_untlNeg` consumes it. A region *below* the until's own time is under
no such demand, and should not be — no point of it is above the evaluation point. The candidate
row overreaches by dropping the "strictly below" side condition, and the corpus reports it.
-/

private def untlNegAllRegions (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ _ =>
        (List.range (b.knownTimes.length + 1)).all fun j =>
          b.hasNegAt φ ⟨sf.label.world, regionLabel b ord sf.label.world j⟩
    | _, _ => true

private def snceNegAllRegions (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ _ =>
        (List.range (b.knownTimes.length + 1)).all fun j =>
          b.hasNegAt φ ⟨sf.label.world, regionLabel b ord sf.label.world j⟩
    | _, _ => true

/-- Report the two over-reaching candidates alone. -/
def probe2 (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob ord _ _) =>
      s!"check={regionLabelCheck ob ord} uNAR={untlNegAllRegions ob ord} " ++
      s!"sNAR={snceNegAllRegions ob ord}"

/-- info: "A check=true uNAR=true sNAR=true" -/
#guard_msgs in
#eval "A " ++ probe2 (.imp (Formula.someFuture p) p)

/-- info: "B check=true uNAR=true sNAR=true" -/
#guard_msgs in
#eval "B " ++ probe2 (.imp (Formula.somePast p) p)

-- C. **Refuting row.** `G p → p`, which the gate accepts, and `uNAR` is `false`.
/-- info: "C check=true uNAR=false sNAR=true" -/
#guard_msgs in
#eval "C " ++ probe2 (.imp (.allFuture p) p)

/-- info: "D check=true uNAR=true sNAR=true" -/
#guard_msgs in
#eval "D " ++ probe2 (.imp (andF (.box p) (dia q)) r)

/-- info: "E check=true uNAR=true sNAR=true" -/
#guard_msgs in
#eval "E " ++ probe2 (.imp (andF (.box p) (.box (.imp p q))) r)

/-- info: "F check=true uNAR=true sNAR=true" -/
#guard_msgs in
#eval "F " ++ probe2 (.imp (Formula.someFuture p) p) 200 .Dense

/-- info: "H check=false uNAR=true sNAR=true" -/
#guard_msgs in
#eval "H " ++ probe2 (.imp (.untl p q) q)

-- I. **The second refuting row**, and the one that matters: a genuine negative until on a branch
-- the gate accepts.
/-- info: "I check=true uNAR=false sNAR=true" -/
#guard_msgs in
#eval "I " ++ probe2 (.imp p (.untl p q))

/-- info: "J check=false uNAR=true sNAR=true" -/
#guard_msgs in
#eval "J " ++ probe2 (.imp (.snce p q) q)

/-- info: "K check=true uNAR=true sNAR=true" -/
#guard_msgs in
#eval "K " ++ probe2 (.imp p (.snce p q))

/-! ## The lower-ray negative demand — Correction 12's residual, measured

The negative `untl` case at a **lower-ray** evaluation point is the one gap `untlNegFuture` plus
`regionLabel_untlNeg` do not close. A point below every placed point reads the label
`regionLabel … 0`; every carrier point above it is either a placed point, another lower-ray point
(reading that same label), or an upper-ray point (reading `regionLabel … n`). All three of those
labels are **known times**, and `untlNegFuture` reaches only the known times *strictly after* the
ray label — which is not all of them, because `regionLabel` picks the first eligible candidate and
not the order-minimal one.

So the demand is: a negative until asserted **at a world's lower-ray label** denies its event at
*every* known time of that world, its own label included. `snceNegRayUp` is the mirror at the
upper ray. `…Self` is the strictly weaker "at its own label only" variant, measured alongside so
that a `false` on the strong row says *which* part failed rather than merely that something did.
-/

/-- A negative until at its world's **lower-ray** label denies its event at every known time. -/
private def untlNegRayLow (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ _ =>
        if sf.label.time == regionLabel b ord sf.label.world 0 then
          b.knownTimes.all fun v => b.hasNegAt φ ⟨sf.label.world, v⟩
        else true
    | _, _ => true

/-- The mirror: a negative since at its world's **upper-ray** label. -/
private def snceNegRayUp (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ _ =>
        if sf.label.time == regionLabel b ord sf.label.world b.knownTimes.length then
          b.knownTimes.all fun v => b.hasNegAt φ ⟨sf.label.world, v⟩
        else true
    | _, _ => true

/-- The weaker "own label only" variant, for diagnosis. -/
private def untlNegRayLowSelf (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ _ =>
        if sf.label.time == regionLabel b ord sf.label.world 0 then
          b.hasNegAt φ sf.label
        else true
    | _, _ => true

/-- The mirror of the weaker variant. -/
private def snceNegRayUpSelf (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ _ =>
        if sf.label.time == regionLabel b ord sf.label.world b.knownTimes.length then
          b.hasNegAt φ sf.label
        else true
    | _, _ => true

/-- Report the lower/upper ray negative candidates. -/
def probe3 (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob ord _ _) =>
      s!"gen={hasGenuine ob} check={regionLabelCheck ob ord} " ++
      s!"uRL={untlNegRayLow ob ord} uRLs={untlNegRayLowSelf ob ord} " ++
      s!"sRU={snceNegRayUp ob ord} sRUs={snceNegRayUpSelf ob ord}"

/-- info: "A gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "A " ++ probe3 (.imp (Formula.someFuture p) p)

/-- info: "B gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "B " ++ probe3 (.imp (Formula.somePast p) p)

/-- info: "C gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "C " ++ probe3 (.imp (.allFuture p) p)

/-- info: "D gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "D " ++ probe3 (.imp (andF (.box p) (dia q)) r)

/-- info: "E gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "E " ++ probe3 (.imp (andF (.box p) (.box (.imp p q))) r)

/-- info: "F gen=false check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "F " ++ probe3 (.imp (Formula.someFuture p) p) 200 .Dense

/-- info: "H gen=true check=false uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "H " ++ probe3 (.imp (.untl p q) q)

-- I. The row that matters: a genuine **negative** until on a branch the gate accepts.
/-- info: "I gen=true check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "I " ++ probe3 (.imp p (.untl p q))

/-- info: "J gen=true check=false uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "J " ++ probe3 (.imp (.snce p q) q)

/-- info: "K gen=true check=true uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "K " ++ probe3 (.imp p (.snce p q))

/-- info: "M gen=true check=false uRL=true uRLs=true sRU=true sRUs=true" -/
#guard_msgs in
#eval "M " ++ probe3 (.imp (.untl p q) q) 200 .Dense

-- N. The single `false`, and it sits where every other `false` in this file sits: on a row
-- `regionLabelCheck` already rejects. `uRLs` fails with `uRL`, so what fails is the *self*-denial
-- at the ray label, not the extension to all known times — the strong row costs nothing over the
-- weak one anywhere in the corpus.
/-- info: "N gen=true check=false uRL=false uRLs=false sRU=true sRUs=true" -/
#guard_msgs in
#eval "N " ++ probe3 (.imp p (.untl p q)) 200 .Discrete

/-! ## The positive rows, in the exact form the proof consumes them

`gw` and `rdG` above are measured, but neither is in the shape the positive case can use, and the
difference is not cosmetic in either instance. Both strengthenings are measured here **before**
being stated in `Verified/`, and each is reported beside the weaker form it strengthens so that a
`false` says which part failed.

*The `⊤` exemption has to move inside the witness.* `untlPosGuardedWitness` exempts the whole row
when `ψ = ⊤`, so on the `someFuture` fragment it asserts nothing at all — and the positive case
still needs a witness there, because `TruthAt … (untl φ ⊤)` demands one. The adopted form asks for
a future known time carrying the event **always**, and attaches the guard obligation only when
`ψ ≠ ⊤`. Pointwise on each signed formula that is exactly `gw`'s body when `ψ ≠ ⊤` and `wit`'s
body when `ψ = ⊤`, and `wit` is `true` on all twelve rows above; `uGW` measures the conjunction
directly rather than inferring it.

*The ray row's first disjunct is unusable and is dropped.* `untlRayDnGuard` permits the escape
`b.hasPosAt φ l` — the event at the ray's own label, with no guard obligation at all. That does
not close the case: the ray label is a *known time*, so the point placing it has placed points
strictly below it, and every one of those is strictly above the lower-ray evaluation point and
inside the guard interval. `regionLabel` picks the first eligible candidate, not the order-minimal
one, so nothing rules them out. The adopted form deletes the escape and keeps the guarded-witness
disjunct alone, again with the `⊤` exemption inside rather than outside.
-/

/-- **Row 7 as adopted.** A future known time carries the event, and — unless the guard is `⊤` —
every known time strictly between carries the guard. -/
private def untlPosWitGuard (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ ψ =>
        (futTimes b ord sf.label.time).any fun t =>
          b.hasPosAt φ ⟨sf.label.world, t⟩ &&
            (ψ == Formula.top ||
              (futTimes b ord sf.label.time).all fun v =>
                !strictBefore ord v t || b.hasPosAt ψ ⟨sf.label.world, v⟩)
    | _, _ => true

/-- **Row 8 as adopted**, the mirror. -/
private def sncePosWitGuard (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ ψ =>
        (pastTimes b ord sf.label.time).any fun t =>
          b.hasPosAt φ ⟨sf.label.world, t⟩ &&
            (ψ == Formula.top ||
              (pastTimes b ord sf.label.time).all fun v =>
                !strictBefore ord t v || b.hasPosAt ψ ⟨sf.label.world, v⟩)
    | _, _ => true

/-- **Row 9 as adopted.** At the lower-ray label: some known time carries the event, and — unless
the guard is `⊤` — the ray's own label carries the guard and so does every known time strictly
below the witness. Branch-major, as rows 5 and 6 are. -/
private def untlRayDnWit (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ ψ =>
        if sf.label.time == regionLabel b ord sf.label.world 0 then
          b.knownTimes.any fun t =>
            b.hasPosAt φ ⟨sf.label.world, t⟩ &&
              (ψ == Formula.top ||
                (b.hasPosAt ψ sf.label &&
                  b.knownTimes.all fun v =>
                    !strictBefore ord v t || b.hasPosAt ψ ⟨sf.label.world, v⟩))
        else true
    | _, _ => true

/-- **Row 10 as adopted**, the mirror at the upper ray. -/
private def snceRayUpWit (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ ψ =>
        if sf.label.time == regionLabel b ord sf.label.world b.knownTimes.length then
          b.knownTimes.any fun t =>
            b.hasPosAt φ ⟨sf.label.world, t⟩ &&
              (ψ == Formula.top ||
                (b.hasPosAt ψ sf.label &&
                  b.knownTimes.all fun v =>
                    !strictBefore ord t v || b.hasPosAt ψ ⟨sf.label.world, v⟩))
        else true
    | _, _ => true

/-- Report the four adopted rows beside the weaker forms they strengthen. -/
def probe4 (φ : Formula) (fuel : Nat := 200) (fc : FrameClass := .Base) : String :=
  match buildTableau φ fuel fc with
  | none => "STALLED"
  | some (.allClosed _) => "CLOSED"
  | some (.hasOpen ob ord _ _) =>
      s!"gen={hasGenuine ob} check={regionLabelCheck ob ord} " ++
      s!"uGW={untlPosWitGuard ob ord} [gw={untlPosGuardedWitness ob ord} wit={untlPosWitness ob ord}] " ++
      s!"sGW={sncePosWitGuard ob ord} [gw={sncePosGuardedWitness ob ord} wit={sncePosWitness ob ord}] " ++
      s!"uRD={untlRayDnWit ob ord} [rdG={untlRayDnGuard ob ord}] " ++
      s!"sRU={snceRayUpWit ob ord} [ruG={snceRayUpGuard ob ord}]"

/-- info: "A gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "A " ++ probe4 (.imp (Formula.someFuture p) p)

/-- info: "B gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "B " ++ probe4 (.imp (Formula.somePast p) p)

/-- info: "C gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "C " ++ probe4 (.imp (.allFuture p) p)

/-- info: "D gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "D " ++ probe4 (.imp (andF (.box p) (dia q)) r)

/-- info: "E gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "E " ++ probe4 (.imp (andF (.box p) (.box (.imp p q))) r)

/-- info: "F gen=false check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "F " ++ probe4 (.imp (Formula.someFuture p) p) 200 .Dense

/-- info: "H gen=true check=false uGW=false [gw=false wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "H " ++ probe4 (.imp (.untl p q) q)

-- I. The row that matters for the positive `untl` case: a genuine until on a branch the gate
-- accepts.
/-- info: "I gen=true check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "I " ++ probe4 (.imp p (.untl p q))

/-- info: "J gen=true check=false uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "J " ++ probe4 (.imp (.snce p q) q)

/-- info: "K gen=true check=true uGW=true [gw=true wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "K " ++ probe4 (.imp p (.snce p q))

/-- info: "M gen=true check=false uGW=false [gw=false wit=true] sGW=true [gw=true wit=true] uRD=true [rdG=true] sRU=true [ruG=true]" -/
#guard_msgs in
#eval "M " ++ probe4 (.imp (.untl p q) q) 200 .Dense

-- N. Every `false` in this block sits on this row and on H, J and M — all four of them rows
-- `regionLabelCheck` already rejects. On all eight rows the gate accepts, the four adopted forms
-- report `true`, which is the acceptance standard rows 1-6 met. Beside each adopted column is
-- the weaker measured form it strengthens: `uRD`/`sRU` never differ from `rdG`/`ruG` anywhere in
-- the corpus, so deleting the `b.hasPosAt φ l` escape costs nothing, and `uGW`/`sGW` never differ
-- from `gw` either, since `wit` is `true` on all twelve rows.
/-- info: "N gen=true check=false uGW=true [gw=true wit=true] sGW=false [gw=false wit=true] uRD=false [rdG=false] sRU=false [ruG=false]" -/
#guard_msgs in
#eval "N " ++ probe4 (.imp p (.untl p q)) 200 .Discrete

end BimodalTest.TemporalWitnessProbe
