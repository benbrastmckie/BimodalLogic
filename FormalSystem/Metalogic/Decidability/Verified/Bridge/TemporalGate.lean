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
  stronger than `sat_untl_neg`'s `F(φ)@t' ∨ F(ψ)@t'`, and it has to be: neither disjunct alone
  settles the case `s = t'`, where the guard interval `(r,s)` is empty and only `¬φ` at `s` will
  do. Measured `true` on **all twelve** corpus rows, including the four the region gate rejects.
* `untlRaySelf` — a positive until asserted at its world's **upper-ray** label carries its event
  at that same label. Every carrier point above an upper-ray point is on the same ray and reads
  the same label, so the witness has nowhere else to be. This is `RayRegionProbe.lean`'s `rayUp`.
* `snceNegPast`, `snceRaySelf` — the past-directed mirrors, at the lower ray.

## What is deliberately **not** here

* *The negative case at non-placed points* needs no new row: `Bridge/RegionLabel.lean`'s
  `untlNegSubjects` already demands the subject of every `F(U(φ,ψ))` asserted **strictly below** a
  region, and `regionLabel_untlNeg` consumes it. The candidate row that drops that side condition
  is refuted on the corpus (rows C and I, both gate-accepted).
* *A row asking the branch to assert a guard at intervening times.* Refuted, and for a reason that
  governs the whole design: the guard of a `someFuture` is `⊤`, and **the engine never writes
  `T(⊤)` on a branch**. Any row demanding `b.hasPosAt ψ` fails on the entire
  `someFuture`/`somePast` fragment for reasons that have nothing to do with untils. The `⊤` case
  must be split off and discharged semantically, which is the split `sat_untl_pos` itself makes
  (`by_cases hg : guard = Formula.top`).

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

/--
**The gate.** Carried on an open-branch certificate exactly as `timeOrderTotal`,
`boxAnchoredCheck` and `regionLabelCheck` are, and consumed only through the four lemmas below.
-/
def temporalWitnessCheck (b : Branch) (ord : TimeOrdering) : Bool :=
  untlNegFuture b ord && snceNegPast b ord && untlRaySelf b ord && snceRaySelf b ord

theorem untlNegFuture_of_check (h : temporalWitnessCheck b ord = true) :
    untlNegFuture b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; exact h.1.1.1

theorem snceNegPast_of_check (h : temporalWitnessCheck b ord = true) :
    snceNegPast b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; exact h.1.1.2

theorem untlRaySelf_of_check (h : temporalWitnessCheck b ord = true) :
    untlRaySelf b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; exact h.1.2

theorem snceRaySelf_of_check (h : temporalWitnessCheck b ord = true) :
    snceRaySelf b ord = true := by
  simp only [temporalWitnessCheck, Bool.and_eq_true] at h; exact h.2

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

end FormalSystem.Metalogic.Decidability.Verified.Bridge
