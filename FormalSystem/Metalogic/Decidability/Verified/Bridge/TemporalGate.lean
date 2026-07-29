/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel
import FormalSystem.Metalogic.Decidability.Verified.Bridge.TemporalSaturation

/-!
# The temporal gate: what a branch owes the `untl`/`snce` cases beyond `regionLabelCheck`

A fourth decidable branch gate, in the family `timeOrderTotal` / `boxAnchoredCheck` /
`regionLabelCheck` already belongs to: a `Bool` computed from the branch and its ordering,
carried as a hypothesis exactly as those three are, and discharged for the branches the engine
builds by sub-phase 7.3 rather than here.

Every row below was **measured on the engine corpus before it was stated**, in
`Tests/BimodalTest/TemporalWitnessProbe.lean`. That corpus was extended for the purpose: the six
rows `Tests/BimodalTest/RayRegionProbe.lean` measures contain no genuine until at all — every
until in them is guard-`⊤`, so the branching `untlPos`/`untlNeg` arms never fire — and four rows
carrying genuine untils and sinces were added. Two candidate rows were **refuted** there and are
absent here as a result; they are recorded in that file, and repeating them is a
DO-NOT-RE-ATTEMPT.

## The rows, and what each is for

Write `r` for a carrier point of the `ℤ` countermodel and `L_r` for the label it reads.
Contiguity (`Bridge/IntGaps.lean`) makes every non-placed integer a point of the lower ray or the
upper ray, and puts **nothing** strictly between consecutive placed points.

* `untlNegFuture` — `F(U(φ,ψ))` at `(w,t)` denies `φ` at every known time strictly after `t`.
  This is what the negative `untl` case needs at the **placed** points above `r`. It is much
  stronger than the `F(φ)@t' ∨ F(ψ)@t'` that the now-retired `sat_untl_neg` supplied, and it has
  to be: neither disjunct alone settles the case `s = t'`, where the guard interval `(r,s)` is
  empty and only `¬φ` at `s` will do. `sat_untl_neg` was read off the PASSIVE co-decomposition arm
  of `applyRule .untlNeg`; that arm has been retired as unsound and the theorem went with it (see
  the retirement note in `Decidability/CountermodelExtraction.lean`), which strengthens rather
  than weakens the case for stating this demand as a gate row instead of inferring it from a
  rule's guard. It was measured `true` on **all twelve** corpus rows before the retirement; it is
  now `false` on the rows carrying a negative until with a known future time, because the arm was
  the only producer of `¬φ` at an existing future time. See the banner at the head of
  `Tests/BimodalTest/TemporalWitnessProbe.lean`.
* `untlRaySelf` — a positive until asserted at its world's **upper-ray** label carries its event
  at that same label. Every carrier point above an upper-ray point is on the same ray and reads
  the same label, so the witness has nowhere else to be. This is `RayRegionProbe.lean`'s `rayUp`.
* `snceNegPast`, `snceRaySelf` — the past-directed mirrors, at the lower ray.
* `untlNegRegionUp` — a **negative** until asserted at **any** region's label denies its event
  everywhere that region can see above itself: at the known times whose rank puts them at or above
  the region, and at the labels of the regions at or above it. This is Correction 12's negative
  residual, generalised from the lower ray to an arbitrary region, and it is the one row here
  whose reach is not a `strictBefore` slice. It has to be: `untlNegFuture` reaches only the known
  times strictly *after* the label, which is not all of them, because `regionLabel` picks the
  first eligible candidate and not the order-minimal one. The two reaches are separate because a
  region label's rank says nothing about its region index. Measured in the exact adopted form
  (column `uNRU`) beside the `uRL` it subsumes: `true` on all eight rows the gate accepts, its
  single `false` sitting on the row where `uRL` already fails and `regionLabelCheck` already
  rejects — so generalising from `j = 0` costs nothing anywhere in the corpus.
* `snceNegRegionDn` — the mirror, reaching **below** the region. The rays swap between the two
  operators: the `untl` row's free instance is the lower ray (`j = 0`, rank condition vacuous) and
  the `snce` row's is the upper ray (`j = n`, rank condition derived from `branchRank_lt_length`).
* `untlPosGuardedWitness` — a **positive** until has a witness strictly after its own time, with
  the guard at every known time strictly between. This is what the positive `untl` case needs at a
  **placed** point, and it is what replaced the earliest-witness iteration the design once owed:
  the branch minimises once, decidably, and the row hands back witness and guard together.
* `untlRayDnGuard` — Correction 12's **positive** residual, at the **lower** ray, with the same
  whole-of-`b.knownTimes` reach and for the same reason as row 5.
* `sncePosGuardedWitness`, `snceRayUpGuard` — the past-directed mirrors, the second at the upper
  ray.

The `⊤` exemption in rows 7-10 sits **inside** the witness, not outside the row. A row exempting
itself entirely when `ψ = ⊤` asserts nothing on the `someFuture`/`somePast` fragment, and the
positive case still needs a witness there, because `TruthAt … (untl φ ⊤)` demands one; only the
*guard* may be dropped, and it is dropped because `⊤` is true at every point of every model.

## What is deliberately **not** here

* *The negative case at non-placed points* needs no new row: `Bridge/RegionLabel.lean`'s
  `untlNegSubjects` already demands the subject of every `F(U(φ,ψ))` asserted **strictly below** a
  region, and `regionLabel_untlNeg` consumes it. The candidate row that drops that side condition
  is refuted on the corpus (rows C and I, both gate-accepted).
* *A row asking the branch to assert a guard at intervening times **without exempting `ψ = ⊤`**.*
  Refuted, and for a reason that governs the whole design: the guard of a `someFuture` is `⊤`, and
  **the engine never writes `T(⊤)` on a branch**. Any such row fails on the entire
  `someFuture`/`somePast` fragment for reasons that have nothing to do with untils. Rows 7-10 do
  demand `b.hasPosAt ψ`, but only where `ψ ≠ ⊤`; the `⊤` case is discharged semantically.
* *An escape permitting the event at the lower ray's own label with no guard obligation.* An
  earlier measured shape of row 9 allowed it. It does not close the leaf: the ray label is itself
  a known time, so the point placing it has placed points strictly below it, and every one of
  those is strictly above the lower-ray evaluation point and inside the guard interval. Deleting
  the escape costs nothing on the corpus, which is measured (column `uRD` beside `rdG`).

## A reformulation, recorded so the measurement still applies

The probe states the ray rows as a scan over `b.knownWorlds`, asking of each world's ray label
that the untils asserted *there* be self-witnessed. The rows here instead scan the branch and ask
of each positive until whether its own label is its own world's ray label. Every branch formula's
world is a known world, so the two agree on every branch; the branch-major form is used because it
makes the consumption lemma a one-line instantiation with no world-membership side condition.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

variable {b : Branch} {ord : TimeOrdering}

/-! ## The rows -/

/-- The known times strictly after `t`. -/
def futureKnown (b : Branch) (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  b.knownTimes.filter fun v => strictBefore ord t v

/-- The known times strictly before `t`. -/
def pastKnown (b : Branch) (ord : TimeOrdering) (t : TimeIndex) : List TimeIndex :=
  b.knownTimes.filter fun v => strictBefore ord v t

theorem mem_futureKnown {t v : TimeIndex} (hv : v ∈ b.knownTimes)
    (hlt : strictBefore ord t v = true) : v ∈ futureKnown b ord t :=
  List.mem_filter.mpr ⟨hv, hlt⟩

theorem mem_pastKnown {t v : TimeIndex} (hv : v ∈ b.knownTimes)
    (hlt : strictBefore ord v t = true) : v ∈ pastKnown b ord t :=
  List.mem_filter.mpr ⟨hv, hlt⟩

/-- **Row 1.** `F(U(φ,ψ))` at `(w,t)` denies `φ` at every known time strictly after `t`. -/
def untlNegFuture (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ _ =>
        (futureKnown b ord sf.label.time).all fun v =>
          b.hasNegAt φ ⟨sf.label.world, v⟩
    | _, _ => true

/-- **Row 2.** `F(S(φ,ψ))` at `(w,t)` denies `φ` at every known time strictly before `t`. -/
def snceNegPast (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ _ =>
        (pastKnown b ord sf.label.time).all fun v =>
          b.hasNegAt φ ⟨sf.label.world, v⟩
    | _, _ => true

/-- **Row 3.** A positive until at its world's upper-ray label carries its event there. -/
def untlRaySelf (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ _ =>
        if sf.label.time == regionLabel b ord sf.label.world b.knownTimes.length then
          b.hasPosAt φ sf.label
        else true
    | _, _ => true

/-- **Row 4.** A positive since at its world's lower-ray label carries its event there. -/
def snceRaySelf (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ _ =>
        if sf.label.time == regionLabel b ord sf.label.world 0 then
          b.hasPosAt φ sf.label
        else true
    | _, _ => true

/-- **Row 5.** A negative until asserted at *any* region label of its world denies its event
everywhere that region can see above itself.

This is Correction 12's negative residual, generalised from the lower ray to an arbitrary region.
The two reaches are the two shapes a point above a non-placed evaluation point can have, and they
are separate because a region label's *rank* says nothing about its region *index*:

* a **placed** point above region `j` — its time `v` satisfies `j ≤ branchRank b ord v`, which is
  exactly "`v` lies above every point of region `j`" (`branchRank_lt_cutIndex`, contrapositive);
* a **non-placed** point above region `j` — it sits in some region `j' ≥ j` and reads
  `regionLabel … j'`, whose rank bears no relation to `j'`, because `regionLabel` picks the first
  eligible candidate and not the order-minimal one.

At `j = 0` both reaches are unrestricted, so the first conjunct alone is the old lower-ray row
verbatim and `untlNegRay_low` below is recovered as its `j = 0` instance — this row **subsumes**
that one rather than sitting beside it, which is why the gate is still ten rows. `untlNegFuture`
(row 1) reaches only the known times *strictly after* the label, which is not all of them.

Measured in this exact form (`Tests/BimodalTest/TemporalWitnessProbe.lean`, column `uNRU`) beside
the `uRL` it strengthens, with the two reaches also reported separately: `true` on all eight rows
the gate accepts, and its single `false` is the row on which `uRL` already fails. -/
def untlNegRegionUp (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ _ =>
        (List.range (b.knownTimes.length + 1)).all fun j =>
          if sf.label.time == regionLabel b ord sf.label.world j then
            (b.knownTimes.all fun v =>
              if j ≤ branchRank b ord v then b.hasNegAt φ ⟨sf.label.world, v⟩ else true) &&
            ((List.range (b.knownTimes.length + 1)).all fun j' =>
              if j ≤ j' then
                b.hasNegAt φ ⟨sf.label.world, regionLabel b ord sf.label.world j'⟩
              else true)
          else true
    | _, _ => true

/-- **Row 6.** The mirror: a negative since at a region label denies its event at everything that
region can see **below** itself. Recovers the old upper-ray row as its `j = n` instance. -/
def snceNegRegionDn (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ _ =>
        (List.range (b.knownTimes.length + 1)).all fun j =>
          if sf.label.time == regionLabel b ord sf.label.world j then
            (b.knownTimes.all fun v =>
              if branchRank b ord v < j then b.hasNegAt φ ⟨sf.label.world, v⟩ else true) &&
            ((List.range (b.knownTimes.length + 1)).all fun j' =>
              if j' ≤ j then
                b.hasNegAt φ ⟨sf.label.world, regionLabel b ord sf.label.world j'⟩
              else true)
          else true
    | _, _ => true

/-- **Row 7.** A positive until has a **guarded witness**: some known time strictly after its own
time carries the event, and — unless the guard is `⊤` — every known time strictly between the two
carries the guard.

The `⊤` exemption sits *inside* the witness, not outside the row, and that placement is the whole
content of the row on the `someFuture`/`somePast` fragment. `⊤` is never written on a branch, so a
row exempting itself entirely when `ψ = ⊤` asserts nothing there — while the positive case still
needs a witness, because `TruthAt … (untl φ ⊤)` demands one. Measured in this exact form
(`Tests/BimodalTest/TemporalWitnessProbe.lean`, column `uGW`) beside the weaker `gw` and `wit` it
is the pointwise conjunction of. -/
def untlPosGuardedWitness (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ ψ =>
        (futureKnown b ord sf.label.time).any fun t =>
          b.hasPosAt φ ⟨sf.label.world, t⟩ &&
            (ψ == Formula.top ||
              (futureKnown b ord sf.label.time).all fun v =>
                !strictBefore ord v t || b.hasPosAt ψ ⟨sf.label.world, v⟩)
    | _, _ => true

/-- **Row 8.** The past-directed mirror of row 7. -/
def sncePosGuardedWitness (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ ψ =>
        (pastKnown b ord sf.label.time).any fun t =>
          b.hasPosAt φ ⟨sf.label.world, t⟩ &&
            (ψ == Formula.top ||
              (pastKnown b ord sf.label.time).all fun v =>
                !strictBefore ord t v || b.hasPosAt ψ ⟨sf.label.world, v⟩)
    | _, _ => true

/-- **Row 9.** Correction 12's *positive* residual, at the **lower** ray. A positive until
asserted at its world's lower-ray label has a witness among the known times — any of them, not
only those after the ray label — and, unless the guard is `⊤`, the guard sits at the ray's own
label **and** at every known time strictly below the witness.

Both extensions past row 7 are forced by the geometry. A carrier point below every placed point
reaches its witness across the whole of the lower ray, whose points all read the ray label, and
across *every* placed point below the witness — not merely those after the ray label, since
`regionLabel` picks the first eligible candidate and not the order-minimal one. The measured
`rdG` additionally permitted the escape "the event is at the ray's own label"; that escape is
deleted here, because the ray label is itself a known time with placed points below it, every one
of them inside the guard interval. Measured in this exact form (column `uRD`) beside `rdG`, from
which it never differs on the corpus. -/
def untlRayDnGuard (b : Branch) (ord : TimeOrdering) : Bool :=
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

/-- **Row 10.** The mirror, at the **upper** ray. The rays swap between the two operators in the
positive direction exactly as they do in the negative one, and the same way round. -/
def snceRayUpGuard (b : Branch) (ord : TimeOrdering) : Bool :=
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

/-- **Row 11.** A positive until asserted at **any** region's label has a witness, either in that
region itself or at a known time above it, with the guard carried wherever the interval reaches.

Rows 3 and 9 are the two `ℤ` leaves of this: row 3 is the upper ray, where the witness must be the
region's own label because every point above reads it, and row 9 is the lower ray, where the
witness is a known time. At `ℚ`/`ℝ` the point sits in an arbitrary region, and — crucially —
`Stepped` is false, so the upper-ray trick of stepping to a successor with an *empty* guard
interval is unavailable. The witness comes from `exists_gt_sameRegion` instead, and the guard is
then **carried across the region** rather than vanished: that is what the `self` disjunct's
`b.hasPosAt ψ` is for, and it is the one demand `ℤ` never had to make.

The `known` disjunct's two guard clauses are the two shapes a point of the interval `(r, f k)` can
have, and their side conditions are the branch-side readings of the two counting lemmas in
`Bridge/DenseTruth.lean`: `j ≤ branchRank u` for a placed point (`cutIndex_le_branchRank`), and
`j ≤ j' ≤ branchRank v` for a non-placed one (`cutIndex_mono` above, `cutIndex_le_branchRank`
below).

This row does **not** subsume rows 3, 9 and 10 — its `self` disjunct is an escape they do not
offer — so it is adopted beside them. Measured in this exact form
(`Tests/BimodalTest/TemporalWitnessProbe.lean`, column `uPR`) beside `uRD` and beside the `self`
disjunct alone: `true` on all eight rows the gate accepts, and the `self` column shows the
disjunction is load-bearing rather than decorative. -/
def untlPosRegion (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl φ ψ =>
        (List.range (b.knownTimes.length + 1)).all fun j =>
          if sf.label.time == regionLabel b ord sf.label.world j then
            (b.hasPosAt φ sf.label && (ψ == Formula.top || b.hasPosAt ψ sf.label)) ||
            (b.knownTimes.any fun v =>
              (decide (j ≤ branchRank b ord v) && b.hasPosAt φ ⟨sf.label.world, v⟩) &&
                (ψ == Formula.top ||
                  ((b.knownTimes.all fun u =>
                      if j ≤ branchRank b ord u ∧ strictBefore ord u v = true then
                        b.hasPosAt ψ ⟨sf.label.world, u⟩
                      else true) &&
                   ((List.range (b.knownTimes.length + 1)).all fun j' =>
                      if j ≤ j' ∧ j' ≤ branchRank b ord v then
                        b.hasPosAt ψ ⟨sf.label.world, regionLabel b ord sf.label.world j'⟩
                      else true))))
          else true
    | _, _ => true

/-- **Row 12.** The past-directed mirror of row 11, with the interval below the region. -/
def sncePosRegion (b : Branch) (ord : TimeOrdering) : Bool :=
  b.all fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce φ ψ =>
        (List.range (b.knownTimes.length + 1)).all fun j =>
          if sf.label.time == regionLabel b ord sf.label.world j then
            (b.hasPosAt φ sf.label && (ψ == Formula.top || b.hasPosAt ψ sf.label)) ||
            (b.knownTimes.any fun v =>
              (decide (branchRank b ord v < j) && b.hasPosAt φ ⟨sf.label.world, v⟩) &&
                (ψ == Formula.top ||
                  ((b.knownTimes.all fun u =>
                      if branchRank b ord u < j ∧ strictBefore ord v u = true then
                        b.hasPosAt ψ ⟨sf.label.world, u⟩
                      else true) &&
                   ((List.range (b.knownTimes.length + 1)).all fun j' =>
                      if j' ≤ j ∧ branchRank b ord v < j' then
                        b.hasPosAt ψ ⟨sf.label.world, regionLabel b ord sf.label.world j'⟩
                      else true))))
          else true
    | _, _ => true

/--
**The gate.** Carried on an open-branch certificate exactly as `timeOrderTotal`,
`boxAnchoredCheck` and `regionLabelCheck` are, and consumed only through the lemmas below.
-/
def temporalWitnessCheck (b : Branch) (ord : TimeOrdering) : Bool :=
  untlNegFuture b ord && snceNegPast b ord && untlRaySelf b ord && snceRaySelf b ord &&
    untlNegRegionUp b ord && snceNegRegionDn b ord &&
    untlPosGuardedWitness b ord && sncePosGuardedWitness b ord &&
    untlRayDnGuard b ord && snceRayUpGuard b ord &&
    untlPosRegion b ord && sncePosRegion b ord

theorem untlNegFuture_of_check (h : temporalWitnessCheck b ord = true) :
    untlNegFuture b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem snceNegPast_of_check (h : temporalWitnessCheck b ord = true) :
    snceNegPast b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem untlRaySelf_of_check (h : temporalWitnessCheck b ord = true) :
    untlRaySelf b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem snceRaySelf_of_check (h : temporalWitnessCheck b ord = true) :
    snceRaySelf b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem untlNegRegionUp_of_check (h : temporalWitnessCheck b ord = true) :
    untlNegRegionUp b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem snceNegRegionDn_of_check (h : temporalWitnessCheck b ord = true) :
    snceNegRegionDn b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

/-! ## Consumption

Each lemma is stated **branch fact in, branch fact out** — model truth is never a hypothesis and
never a conclusion — which is the shape `Bridge/RegionLabel.lean` established for the region gate
after three refuted policies, and the shape the induction consumes.
-/

/-- **The negative `untl` spread.** `F(U(φ,ψ))` anywhere denies `φ` at every known later time. -/
theorem untlNeg_spread (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {t v : TimeIndex}
    (hmem : (⟨.neg, .untl φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hv : v ∈ b.knownTimes) (hlt : strictBefore ord t v = true) :
    b.hasNegAt φ ⟨w, v⟩ = true := by
  have hrow := List.all_eq_true.mp (untlNegFuture_of_check h) _ hmem
  simp only at hrow
  exact List.all_eq_true.mp hrow _ (mem_futureKnown hv hlt)

/-- **The negative `snce` spread**, the mirror. -/
theorem snceNeg_spread (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {t v : TimeIndex}
    (hmem : (⟨.neg, .snce φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hv : v ∈ b.knownTimes) (hlt : strictBefore ord v t = true) :
    b.hasNegAt φ ⟨w, v⟩ = true := by
  have hrow := List.all_eq_true.mp (snceNegPast_of_check h) _ hmem
  simp only at hrow
  exact List.all_eq_true.mp hrow _ (mem_pastKnown hv hlt)

/-- **The upper-ray self-witness.** A positive until at the upper ray's own label carries its
event there — the only place an upper-ray point can find one. -/
theorem untlRay_self (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex}
    (hmem : (⟨.pos, .untl φ ψ, ⟨w, regionLabel b ord w b.knownTimes.length⟩⟩ : SignedFormula) ∈ b) :
    b.hasPosAt φ ⟨w, regionLabel b ord w b.knownTimes.length⟩ = true := by
  have hrow := List.all_eq_true.mp (untlRaySelf_of_check h) _ hmem
  simpa using hrow

/-- **The lower-ray self-witness**, the mirror. -/
theorem snceRay_self (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex}
    (hmem : (⟨.pos, .snce φ ψ, ⟨w, regionLabel b ord w 0⟩⟩ : SignedFormula) ∈ b) :
    b.hasPosAt φ ⟨w, regionLabel b ord w 0⟩ = true := by
  have hrow := List.all_eq_true.mp (snceRaySelf_of_check h) _ hmem
  simpa using hrow

/-- Row 5, unpacked at one region index: both reaches at once. -/
private theorem untlNegRegion_raw (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j : Nat} (hj : j ≤ b.knownTimes.length)
    (hmem : (⟨.neg, .untl φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b) :
    (b.knownTimes.all fun v =>
        if j ≤ branchRank b ord v then b.hasNegAt φ ⟨w, v⟩ else true) = true ∧
      ((List.range (b.knownTimes.length + 1)).all fun j' =>
        if j ≤ j' then b.hasNegAt φ ⟨w, regionLabel b ord w j'⟩ else true) = true := by
  have hrow := List.all_eq_true.mp (untlNegRegionUp_of_check h) _ hmem
  simp only at hrow
  have hj' := List.all_eq_true.mp hrow j (List.mem_range.mpr (Nat.lt_succ_of_le hj))
  simp only [beq_self_eq_true, if_true, Bool.and_eq_true] at hj'
  exact hj'

/-- **The negative `untl` region spread, at a placed point above the region.** A negative until at
region `j`'s label denies its event at every known time whose rank puts it at or above `j`. -/
theorem untlNegRegion_up (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j : Nat} {v : TimeIndex} (hj : j ≤ b.knownTimes.length)
    (hmem : (⟨.neg, .untl φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b)
    (hv : v ∈ b.knownTimes) (hrk : j ≤ branchRank b ord v) :
    b.hasNegAt φ ⟨w, v⟩ = true := by
  have := List.all_eq_true.mp (untlNegRegion_raw h hj hmem).1 _ hv
  simpa [hrk] using this

/-- **The negative `untl` region spread, at a non-placed point above the region.** The witness
reads region `j'`'s label for some `j' ≥ j`, and that label's *rank* says nothing about `j'` —
which is exactly why this is a separate reach and not a corollary of the one above. -/
theorem untlNegRegion_label (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j j' : Nat} (hj : j ≤ b.knownTimes.length)
    (hj' : j' ≤ b.knownTimes.length)
    (hmem : (⟨.neg, .untl φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b)
    (hle : j ≤ j') :
    b.hasNegAt φ ⟨w, regionLabel b ord w j'⟩ = true := by
  have := List.all_eq_true.mp (untlNegRegion_raw h hj hmem).2 j'
    (List.mem_range.mpr (Nat.lt_succ_of_le hj'))
  simpa [hle] using this

/-- **The lower-ray negative spread**, recovered as the `j = 0` instance of row 5 rather than
carried as a row of its own: at region `0` the rank side condition is vacuous, so the reach is
every known time — which is every label any point above a lower-ray point can read. -/
theorem untlNegRay_low (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {v : TimeIndex}
    (hmem : (⟨.neg, .untl φ ψ, ⟨w, regionLabel b ord w 0⟩⟩ : SignedFormula) ∈ b)
    (hv : v ∈ b.knownTimes) :
    b.hasNegAt φ ⟨w, v⟩ = true :=
  untlNegRegion_up h (Nat.zero_le _) hmem hv (Nat.zero_le _)

/-- Row 6, unpacked at one region index, the mirror. -/
private theorem snceNegRegion_raw (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j : Nat} (hj : j ≤ b.knownTimes.length)
    (hmem : (⟨.neg, .snce φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b) :
    (b.knownTimes.all fun v =>
        if branchRank b ord v < j then b.hasNegAt φ ⟨w, v⟩ else true) = true ∧
      ((List.range (b.knownTimes.length + 1)).all fun j' =>
        if j' ≤ j then b.hasNegAt φ ⟨w, regionLabel b ord w j'⟩ else true) = true := by
  have hrow := List.all_eq_true.mp (snceNegRegionDn_of_check h) _ hmem
  simp only at hrow
  have hj' := List.all_eq_true.mp hrow j (List.mem_range.mpr (Nat.lt_succ_of_le hj))
  simp only [beq_self_eq_true, if_true, Bool.and_eq_true] at hj'
  exact hj'

/-- **The negative `snce` region spread, at a placed point below the region**, the mirror. -/
theorem snceNegRegion_dn (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j : Nat} {v : TimeIndex} (hj : j ≤ b.knownTimes.length)
    (hmem : (⟨.neg, .snce φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b)
    (hv : v ∈ b.knownTimes) (hrk : branchRank b ord v < j) :
    b.hasNegAt φ ⟨w, v⟩ = true := by
  have := List.all_eq_true.mp (snceNegRegion_raw h hj hmem).1 _ hv
  simpa [hrk] using this

/-- **The negative `snce` region spread, at a non-placed point below the region**, the mirror. -/
theorem snceNegRegion_label (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j j' : Nat} (hj : j ≤ b.knownTimes.length)
    (hj' : j' ≤ b.knownTimes.length)
    (hmem : (⟨.neg, .snce φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b)
    (hle : j' ≤ j) :
    b.hasNegAt φ ⟨w, regionLabel b ord w j'⟩ = true := by
  have := List.all_eq_true.mp (snceNegRegion_raw h hj hmem).2 j'
    (List.mem_range.mpr (Nat.lt_succ_of_le hj'))
  simpa [hle] using this

/-- **The upper-ray negative spread**, recovered as the `j = n` instance of row 6.

The asymmetry with `untlNegRay_low` is real and is recorded here rather than hidden: at region `0`
the rank side condition `0 ≤ branchRank v` is *vacuous*, so the lower-ray reach is free, whereas at
region `n` the condition `branchRank v < n` has to be **derived** from `branchRank_lt_length`,
which needs `branchOrderValid`. That derivation lives at the call site in `Bridge/IntTruth.lean`
rather than here, because `branchRank_lt_length` is downstream of this file. -/
theorem snceNegRay_up (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {v : TimeIndex}
    (hmem :
      (⟨.neg, .snce φ ψ, ⟨w, regionLabel b ord w b.knownTimes.length⟩⟩ : SignedFormula) ∈ b)
    (hv : v ∈ b.knownTimes) (hrk : branchRank b ord v < b.knownTimes.length) :
    b.hasNegAt φ ⟨w, v⟩ = true :=
  snceNegRegion_dn h (le_refl _) hmem hv hrk

theorem untlPosGuardedWitness_of_check (h : temporalWitnessCheck b ord = true) :
    untlPosGuardedWitness b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem sncePosGuardedWitness_of_check (h : temporalWitnessCheck b ord = true) :
    sncePosGuardedWitness b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem untlRayDnGuard_of_check (h : temporalWitnessCheck b ord = true) :
    untlRayDnGuard b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem snceRayUpGuard_of_check (h : temporalWitnessCheck b ord = true) :
    snceRayUpGuard b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem untlPosRegion_of_check (h : temporalWitnessCheck b ord = true) :
    untlPosRegion b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

theorem sncePosRegion_of_check (h : temporalWitnessCheck b ord = true) :
    sncePosRegion b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; tauto

/-- **The guarded witness.** A positive until has a witness strictly after its own time, with the
guard at every known time strictly between the two — the `⊤` case exempted from the guard but
**not** from the witness. -/
theorem untlPos_witness (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {t : TimeIndex}
    (hmem : (⟨.pos, .untl φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b) :
    ∃ t' ∈ b.knownTimes, strictBefore ord t t' = true ∧ b.hasPosAt φ ⟨w, t'⟩ = true ∧
      (ψ = Formula.top ∨ ∀ v ∈ b.knownTimes, strictBefore ord t v = true →
        strictBefore ord v t' = true → b.hasPosAt ψ ⟨w, v⟩ = true) := by
  have hrow := List.all_eq_true.mp (untlPosGuardedWitness_of_check h) _ hmem
  simp only at hrow
  obtain ⟨t', ht', hbody⟩ := List.any_eq_true.mp hrow
  rw [futureKnown, List.mem_filter] at ht'
  simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq] at hbody
  refine ⟨t', ht'.1, ht'.2, hbody.1, ?_⟩
  rcases hbody.2 with hg | hguard
  · exact Or.inl hg
  · refine Or.inr fun v hv hvt hvt' => ?_
    have hv' := List.all_eq_true.mp hguard v (mem_futureKnown hv hvt)
    rw [hvt'] at hv'
    simpa using hv'

/-- **The guarded witness**, past-directed mirror. -/
theorem sncePos_witness (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {t : TimeIndex}
    (hmem : (⟨.pos, .snce φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b) :
    ∃ t' ∈ b.knownTimes, strictBefore ord t' t = true ∧ b.hasPosAt φ ⟨w, t'⟩ = true ∧
      (ψ = Formula.top ∨ ∀ v ∈ b.knownTimes, strictBefore ord v t = true →
        strictBefore ord t' v = true → b.hasPosAt ψ ⟨w, v⟩ = true) := by
  have hrow := List.all_eq_true.mp (sncePosGuardedWitness_of_check h) _ hmem
  simp only at hrow
  obtain ⟨t', ht', hbody⟩ := List.any_eq_true.mp hrow
  rw [pastKnown, List.mem_filter] at ht'
  simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq] at hbody
  refine ⟨t', ht'.1, ht'.2, hbody.1, ?_⟩
  rcases hbody.2 with hg | hguard
  · exact Or.inl hg
  · refine Or.inr fun v hv hvt hvt' => ?_
    have hv' := List.all_eq_true.mp hguard v (mem_pastKnown hv hvt)
    rw [hvt'] at hv'
    simpa using hv'

/-- **The lower-ray guarded witness.** A positive until at the lower ray's own label reaches a
witness among *all* the known times, with the guard at the ray label itself and at every known
time strictly below the witness. -/
theorem untlRayDn_witness (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex}
    (hmem : (⟨.pos, .untl φ ψ, ⟨w, regionLabel b ord w 0⟩⟩ : SignedFormula) ∈ b) :
    ∃ t ∈ b.knownTimes, b.hasPosAt φ ⟨w, t⟩ = true ∧
      (ψ = Formula.top ∨
        (b.hasPosAt ψ ⟨w, regionLabel b ord w 0⟩ = true ∧
          ∀ v ∈ b.knownTimes, strictBefore ord v t = true → b.hasPosAt ψ ⟨w, v⟩ = true)) := by
  have hrow := List.all_eq_true.mp (untlRayDnGuard_of_check h) _ hmem
  simp only [beq_self_eq_true, if_true] at hrow
  obtain ⟨t, ht, hbody⟩ := List.any_eq_true.mp hrow
  simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq] at hbody
  refine ⟨t, ht, hbody.1, ?_⟩
  rcases hbody.2 with hg | ⟨hl, hguard⟩
  · exact Or.inl hg
  · refine Or.inr ⟨hl, fun v hv hvt => ?_⟩
    have hv' := List.all_eq_true.mp hguard v hv
    rw [hvt] at hv'
    simpa using hv'

/-- **The upper-ray guarded witness**, the mirror. -/
theorem snceRayUp_witness (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex}
    (hmem :
      (⟨.pos, .snce φ ψ, ⟨w, regionLabel b ord w b.knownTimes.length⟩⟩ : SignedFormula) ∈ b) :
    ∃ t ∈ b.knownTimes, b.hasPosAt φ ⟨w, t⟩ = true ∧
      (ψ = Formula.top ∨
        (b.hasPosAt ψ ⟨w, regionLabel b ord w b.knownTimes.length⟩ = true ∧
          ∀ v ∈ b.knownTimes, strictBefore ord t v = true → b.hasPosAt ψ ⟨w, v⟩ = true)) := by
  have hrow := List.all_eq_true.mp (snceRayUpGuard_of_check h) _ hmem
  simp only [beq_self_eq_true, if_true] at hrow
  obtain ⟨t, ht, hbody⟩ := List.any_eq_true.mp hrow
  simp only [Bool.and_eq_true, Bool.or_eq_true, beq_iff_eq] at hbody
  refine ⟨t, ht, hbody.1, ?_⟩
  rcases hbody.2 with hg | ⟨hl, hguard⟩
  · exact Or.inl hg
  · refine Or.inr ⟨hl, fun v hv hvt => ?_⟩
    have hv' := List.all_eq_true.mp hguard v hv
    rw [hvt] at hv'
    simpa using hv'


/-! ## The interior-region positive witness, unpacked

Rows 11 and 12 are the only rows whose consumption is a **disjunction**, so their unpacking is
given a name rather than inlined: the dense positive case branches on it, and both branches are
live at every region.
-/

/-- What row 11 hands the dense positive `untl` case at region `j`: a witness inside the region,
or a witness at a known time above it with the guard carried across the interval. -/
def UntlPosRegionWitness (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat)
    (φ ψ : Formula) : Prop :=
  (b.hasPosAt φ ⟨w, regionLabel b ord w j⟩ = true ∧
      (ψ = Formula.top ∨ b.hasPosAt ψ ⟨w, regionLabel b ord w j⟩ = true)) ∨
    ∃ v ∈ b.knownTimes, j ≤ branchRank b ord v ∧ b.hasPosAt φ ⟨w, v⟩ = true ∧
      (ψ = Formula.top ∨
        ((∀ u ∈ b.knownTimes, j ≤ branchRank b ord u → strictBefore ord u v = true →
            b.hasPosAt ψ ⟨w, u⟩ = true) ∧
          (∀ j', j ≤ j' → j' ≤ branchRank b ord v → j' ≤ b.knownTimes.length →
            b.hasPosAt ψ ⟨w, regionLabel b ord w j'⟩ = true)))

/-- The mirror: what row 12 hands the dense positive `snce` case at region `j`. -/
def SncePosRegionWitness (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat)
    (φ ψ : Formula) : Prop :=
  (b.hasPosAt φ ⟨w, regionLabel b ord w j⟩ = true ∧
      (ψ = Formula.top ∨ b.hasPosAt ψ ⟨w, regionLabel b ord w j⟩ = true)) ∨
    ∃ v ∈ b.knownTimes, branchRank b ord v < j ∧ b.hasPosAt φ ⟨w, v⟩ = true ∧
      (ψ = Formula.top ∨
        ((∀ u ∈ b.knownTimes, branchRank b ord u < j → strictBefore ord v u = true →
            b.hasPosAt ψ ⟨w, u⟩ = true) ∧
          (∀ j', j' ≤ j → branchRank b ord v < j' → j' ≤ b.knownTimes.length →
            b.hasPosAt ψ ⟨w, regionLabel b ord w j'⟩ = true)))

/-- **Row 11, consumed.** -/
theorem untlPosRegion_witness (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j : Nat} (hj : j ≤ b.knownTimes.length)
    (hmem : (⟨.pos, .untl φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b) :
    UntlPosRegionWitness b ord w j φ ψ := by
  have hrow := List.all_eq_true.mp (untlPosRegion_of_check h) _ hmem
  simp only at hrow
  have hj' := List.all_eq_true.mp hrow j (List.mem_range.mpr (Nat.lt_succ_of_le hj))
  simp only [beq_self_eq_true, if_true, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] at hj'
  rcases hj' with ⟨hφ, hg⟩ | hk
  · exact Or.inl ⟨hφ, hg⟩
  · rw [List.any_eq_true] at hk
    obtain ⟨v, hv, hvc⟩ := hk
    simp only [Bool.and_eq_true, decide_eq_true_iff, Bool.or_eq_true, beq_iff_eq] at hvc
    obtain ⟨⟨hrk, hvφ⟩, hg⟩ := hvc
    refine Or.inr ⟨v, hv, hrk, hvφ, ?_⟩
    rcases hg with hg | hg
    · exact Or.inl hg
    · refine Or.inr ⟨fun u hu hru hlt => ?_, fun j' hjj hjv hjn => ?_⟩
      · have := List.all_eq_true.mp hg.1 u hu
        simpa [hru, hlt] using this
      · have := List.all_eq_true.mp hg.2 j' (List.mem_range.mpr (Nat.lt_succ_of_le hjn))
        simpa [hjj, hjv] using this

/-- **Row 12, consumed**, the mirror. -/
theorem sncePosRegion_witness (h : temporalWitnessCheck b ord = true)
    {φ ψ : Formula} {w : WorldIndex} {j : Nat} (hj : j ≤ b.knownTimes.length)
    (hmem : (⟨.pos, .snce φ ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b) :
    SncePosRegionWitness b ord w j φ ψ := by
  have hrow := List.all_eq_true.mp (sncePosRegion_of_check h) _ hmem
  simp only at hrow
  have hj' := List.all_eq_true.mp hrow j (List.mem_range.mpr (Nat.lt_succ_of_le hj))
  simp only [beq_self_eq_true, if_true, Bool.or_eq_true, Bool.and_eq_true, beq_iff_eq] at hj'
  rcases hj' with ⟨hφ, hg⟩ | hk
  · exact Or.inl ⟨hφ, hg⟩
  · rw [List.any_eq_true] at hk
    obtain ⟨v, hv, hvc⟩ := hk
    simp only [Bool.and_eq_true, decide_eq_true_iff, Bool.or_eq_true, beq_iff_eq] at hvc
    obtain ⟨⟨hrk, hvφ⟩, hg⟩ := hvc
    refine Or.inr ⟨v, hv, hrk, hvφ, ?_⟩
    rcases hg with hg | hg
    · exact Or.inl hg
    · refine Or.inr ⟨fun u hu hru hlt => ?_, fun j' hjj hjv hjn => ?_⟩
      · have := List.all_eq_true.mp hg.1 u hu
        simpa [hru, hlt] using this
      · have := List.all_eq_true.mp hg.2 j' (List.mem_range.mpr (Nat.lt_succ_of_le hjn))
        simpa [hjj, hjv] using this

end FormalSystem.Metalogic.Decidability.Verified.Bridge
