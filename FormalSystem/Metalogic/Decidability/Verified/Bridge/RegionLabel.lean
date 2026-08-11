/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.Valuation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.PropSaturation

/-!
# O2's replacement: the region labelling, and its decidable gate

The countermodel's carrier places the branch's `n` times and has points nowhere near them. Those
non-placed points fall into `n + 1` **regions** — the lower ray, the interior gaps, the upper ray
— and the model must assign each region a state. Three successive attempts to *synthesise* that
state from the branch have been machine-refuted, each by the file that stated it:

* `GapDemands` (`Bridge/Valuation.lean`) — stated backwards; `gapDemands_trivial` proves every
  policy whatsoever meets it.
* the endpoint-copy policies — `not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate`.
* `GapAdequate` with `branchGapVal` — `gapAdequate_insufficient`. The policy meets the interface
  and still falsifies a branch fact, because `GapAdequate` constrains the gap at *atoms* while
  `truthAt_box_iff_base` makes `T(□χ)` a demand at gap points for **compound** `χ`.

The defect the third refutation exposes is structural and rules out the whole family: the state a
region needs must be closed under the propositional consequences of its **forced set**
`{χ : T(Gχ) below} ∪ {χ : T(Hχ) above} ∪ {χ : T(□χ)}`, and a saturated branch's forced sets are
not closed under those consequences.

## What this file does instead

A region takes the atom content of a **chosen known branch label**, and the choice is certified
by a decidable gate on the branch. Nothing is synthesised. This escapes the refutation for one
reason, and it is worth stating precisely because the 2026-07-28i ban on "any atom-wise gap
policy read off the branch's `T(G·)`/`T(H·)`/`T(□·)` facts" stands verbatim:

> a **label's** content is propositionally closed — that is exactly `sat_imp_pos`
> (`Bridge/PropSaturation.lean`) together with openness — while a **forced set** is not.

The refuting configuration itself makes the point. On a branch carrying `T(□p)` and
`T(□(p → q))`, `sat_box_grid_of_check` puts `T(p)` and `T(p → q)` at every label; `sat_imp_pos`
then forces `F(p)` or `T(q)` at each, and openness kills `F(p)`. So `T(q)` sits at every label,
and a region carrying a label's atoms makes `p → q` true — where `branchGapVal`, reading the
forced set, made it false.

## The gate

Write `rank t` for the number of branch times strictly below `t`. Region `j` of world `w` sits
strictly above every branch time of rank `< j` and strictly below every branch time of rank
`≥ j`, for `0 ≤ j ≤ n`; `j = 0` is the lower ray and `j = n` the upper ray. Region `j` is owed:

| Source | Side | Demand |
|---|---|---|
| `T(□χ)` anywhere on the branch | positive | `χ` |
| `F(◇χ)` anywhere on the branch (i.e. `□¬χ`) | negative | `χ` |
| `T(U(φ,ψ))` at a label of `w` of rank `< j` | positive | `ψ` |
| `T(S(φ,ψ))` at a label of `w` of rank `≥ j` | positive | `ψ` |
| `F(U(φ,ψ))` at a label of `w` of rank `< j` | negative | `φ` |
| `F(S(φ,ψ))` at a label of `w` of rank `≥ j` | negative | `φ` |

`regionLabelCheck` says every region of every known world has a known label meeting all of them,
on the correct side and without also carrying the complement. `regionLabel` is the chosen label,
and `branchRegionVal` is the `gapVal` parameter `branchModel` already takes — **the type is
unchanged**, so nothing downstream of `branchModel` moves.

The two `untl`/`snce` positive rows are the **straddling guards**: an until asserted below the
region whose witness lies above it needs its guard throughout the intervening stretch, and the
region is part of that stretch. The negative rows *subsume* the `G`/`H` demands rather than
sitting beside them — `G χ` is `(U(¬χ, ⊤)) → ⊥`, so on a saturated branch `T(Gχ)` at a label
appears as `F(U(¬χ, ⊤))` there, and the `F(U(φ,ψ))` row with `ψ = ⊤`, `φ = ¬χ` is exactly "`χ`
is demanded above".

## Two deliberate over-approximations

Both make the gate **harder** to pass than the induction needs, so a branch that passes is safe
and a branch that failed would not thereby be refuted:

1. The `T(U(φ,ψ))` row ignores where the witness is. An until whose witness lies *below* the
   region imposes nothing there; the gate demands `ψ` anyway.
2. The `F(U(φ,ψ))` row ignores the screening disjunct — `F(U(φ,ψ))` below the region says every
   later point either fails `φ` **or** is screened by an earlier `¬ψ`; the gate demands `¬φ`.

## Measured before stated

`Tests/BimodalTest/RegionGateProbe.lean` runs this gate's shape on branches the engine actually
builds: nine rows, six shapes at `.Base` and three at `.Dense`, all reporting `true`, including
the shape that refutes `GapAdequate`. It also pins a synthetic branch on which the gate is
**false**, so `true` here is a measurement and not a tautology. That file is the reason this one
exists in this form: three dispatches were spent on interfaces reasoned about in prose and proved
about only afterwards, and each was wrong.

## What this file does not claim

The gate is a *sufficient condition offered to the induction*, not a theorem about the engine.
Like `timeOrderTotal` and `boxAnchoredCheck`, it is discharged per run by computation on the one
finished branch `hasOpen` hands back. A construction-level proof that the engine always satisfies
it would be strictly stronger and is not on the critical path.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## Rank: where a branch time sits in the branch's own order -/

/--
How many branch times lie strictly below `t`.

`strictBefore` (`Bridge/BranchOrder.lean`) is the bridge's only order primitive, so `branchRank`
inherits its reading of the ordering. On a branch whose `branchOrderValid` gate holds this is a
bijection from `b.knownTimes` onto `0, …, n-1`, but nothing here needs that: `branchRank` is used
only to say which side of a region a label falls on, and both sides are read off the same
function.
-/
def branchRank (b : Branch) (ord : TimeOrdering) (t : TimeIndex) : Nat :=
  (b.knownTimes.filter fun s => strictBefore ord s t).length

/-! ## The demands

Six list-valued functions, one per row of the module docstring's table, kept separate so each has
its own one-line membership lemma. `regionPosDemands` and `regionNegDemands` concatenate them.
-/

/-- `χ` for every `T(□χ)` on the branch: the box content, demanded at every point of every
region. `sat_box_grid_of_check` already delivers this at every known *label*, so this row does
not in fact constrain a branch that passes O3 — it is kept so the gate is self-contained and so
it matches the probe row for row. -/
def boxContents (b : Branch) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .pos, .box χ => some χ
    | _, _ => none

/-- `χ` for every `F(◇χ)` on the branch. `F(◇χ)` is `□¬χ`, so `χ` is demanded *negatively*
everywhere. -/
def diaNegContents (b : Branch) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .neg, .imp (.box (.imp χ .bot)) .bot => some χ
    | _, _ => none

/-- The guard `ψ` of every `T(U(φ,ψ))` asserted in world `w` strictly below region `j`. -/
def untlGuards (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .pos, .untl _ ψ =>
        if sf.label.world = w ∧ branchRank b ord sf.label.time < j then some ψ else none
    | _, _ => none

/-- The guard `ψ` of every `T(S(φ,ψ))` asserted in world `w` at or above region `j`. -/
def snceGuards (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .pos, .snce _ ψ =>
        if sf.label.world = w ∧ j ≤ branchRank b ord sf.label.time then some ψ else none
    | _, _ => none

/-- The subject `φ` of every `F(U(φ,ψ))` asserted in world `w` strictly below region `j`. With
`ψ = ⊤` and `φ = ¬χ` this is the `T(Gχ)` demand. -/
def untlNegSubjects (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .neg, .untl φ _ =>
        if sf.label.world = w ∧ branchRank b ord sf.label.time < j then some φ else none
    | _, _ => none

/-- The subject `φ` of every `F(S(φ,ψ))` asserted in world `w` at or above region `j`. -/
def snceNegSubjects (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) : List Formula :=
  b.filterMap fun sf =>
    match sf.sign, sf.formula with
    | .neg, .snce φ _ =>
        if sf.label.world = w ∧ j ≤ branchRank b ord sf.label.time then some φ else none
    | _, _ => none

/-- Everything region `j` of world `w` must make **true**. -/
def regionPosDemands (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) :
    List Formula :=
  boxContents b ++ untlGuards b ord w j ++ snceGuards b ord w j

/-- Everything region `j` of world `w` must make **false**. -/
def regionNegDemands (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) :
    List Formula :=
  diaNegContents b ++ untlNegSubjects b ord w j ++ snceNegSubjects b ord w j

/-! ### Membership: a branch fact enters the demand list -/

theorem mem_boxContents {b : Branch} {χ : Formula} {l : Label}
    (h : (⟨.pos, .box χ, l⟩ : SignedFormula) ∈ b) : χ ∈ boxContents b := by
  rw [boxContents, List.mem_filterMap]
  exact ⟨_, h, rfl⟩

theorem mem_diaNegContents {b : Branch} {χ : Formula} {l : Label}
    (h : (⟨.neg, .imp (.box (.imp χ .bot)) .bot, l⟩ : SignedFormula) ∈ b) :
    χ ∈ diaNegContents b := by
  rw [diaNegContents, List.mem_filterMap]
  exact ⟨_, h, rfl⟩

theorem mem_untlGuards {b : Branch} {ord : TimeOrdering} {w : WorldIndex} {j : Nat}
    {φ ψ : Formula} {t : TimeIndex} (h : (⟨.pos, .untl φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : branchRank b ord t < j) : ψ ∈ untlGuards b ord w j := by
  rw [untlGuards, List.mem_filterMap]
  exact ⟨_, h, by simp [hrk]⟩

theorem mem_snceGuards {b : Branch} {ord : TimeOrdering} {w : WorldIndex} {j : Nat}
    {φ ψ : Formula} {t : TimeIndex} (h : (⟨.pos, .snce φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : j ≤ branchRank b ord t) : ψ ∈ snceGuards b ord w j := by
  rw [snceGuards, List.mem_filterMap]
  exact ⟨_, h, by simp [hrk]⟩

theorem mem_untlNegSubjects {b : Branch} {ord : TimeOrdering} {w : WorldIndex} {j : Nat}
    {φ ψ : Formula} {t : TimeIndex} (h : (⟨.neg, .untl φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : branchRank b ord t < j) : φ ∈ untlNegSubjects b ord w j := by
  rw [untlNegSubjects, List.mem_filterMap]
  exact ⟨_, h, by simp [hrk]⟩

theorem mem_snceNegSubjects {b : Branch} {ord : TimeOrdering} {w : WorldIndex} {j : Nat}
    {φ ψ : Formula} {t : TimeIndex} (h : (⟨.neg, .snce φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : j ≤ branchRank b ord t) : φ ∈ snceNegSubjects b ord w j := by
  rw [snceNegSubjects, List.mem_filterMap]
  exact ⟨_, h, by simp [hrk]⟩

/-! ## The gate -/

/--
Does the label `(w, t)` state every demand of region `j`, on the correct side and without also
stating the complement?

The two-sided form is what makes the check discriminating: dropping the `!hasNegAt`/`!hasPosAt`
conjuncts would let a label that carries both signs of a demand qualify, and openness of the
branch is a hypothesis this file deliberately does not take.
-/
def regionMeets (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) (t : TimeIndex) :
    Bool :=
  (regionPosDemands b ord w j).all
      (fun χ => b.hasPosAt χ ⟨w, t⟩ && !b.hasNegAt χ ⟨w, t⟩) &&
  (regionNegDemands b ord w j).all
      (fun χ => b.hasNegAt χ ⟨w, t⟩ && !b.hasPosAt χ ⟨w, t⟩)

/-- The known times whose label in world `w` is eligible to be region `j`'s state. -/
def regionLabelCandidates (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) :
    List TimeIndex :=
  b.knownTimes.filter (regionMeets b ord w j)

/--
**The gate.** Every region of every known world has an eligible label.

In the family `timeOrderTotal` (`Saturation.lean`) and `boxAnchoredCheck`
(`Bridge/BoxSaturation.lean`) belong to: a `Bool` on the finished branch, discharged per run by
computation rather than by an induction over tableau construction. `n + 1` regions per world,
indexed `0, …, n`.
-/
def regionLabelCheck (b : Branch) (ord : TimeOrdering) : Bool :=
  b.knownWorlds.all fun w =>
    (List.range (b.knownTimes.length + 1)).all fun j =>
      !(regionLabelCandidates b ord w j).isEmpty

/-- **The choice.** The first eligible known time, or `0` when there is none — the junk value is
unreachable under `regionLabelCheck`, which is the only way this is ever consumed. -/
def regionLabel (b : Branch) (ord : TimeOrdering) (w : WorldIndex) (j : Nat) : TimeIndex :=
  (regionLabelCandidates b ord w j).headD 0

/-! ### Unpacking the gate -/

variable {b : Branch} {ord : TimeOrdering} {w : WorldIndex} {j : Nat}

/-- Under the gate, region `j` of a known world has an eligible label. -/
theorem regionLabelCandidates_ne_nil (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length) :
    regionLabelCandidates b ord w j ≠ [] := by
  have h1 := (List.all_eq_true.mp h) w hw
  have hjmem : j ∈ List.range (b.knownTimes.length + 1) :=
    List.mem_range.mpr (Nat.lt_succ_of_le hj)
  have h2 := (List.all_eq_true.mp h1) j hjmem
  simp only [Bool.not_eq_true'] at h2
  exact fun hc => by simp [hc] at h2

/-- The chosen label is one of the eligible ones. -/
theorem regionLabel_mem_candidates (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length) :
    regionLabel b ord w j ∈ regionLabelCandidates b ord w j := by
  have hne := regionLabelCandidates_ne_nil h hw hj
  cases hcs : regionLabelCandidates b ord w j with
  | nil => exact absurd hcs hne
  | cons x xs => simp [regionLabel, hcs]

/-- The chosen label is a time the branch knows. -/
theorem regionLabel_mem_knownTimes (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length) :
    regionLabel b ord w j ∈ b.knownTimes :=
  (List.mem_filter.mp (regionLabel_mem_candidates h hw hj)).1

/-- The chosen label meets every demand of its region. -/
theorem regionMeets_regionLabel (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length) :
    regionMeets b ord w j (regionLabel b ord w j) = true :=
  of_decide_eq_true
    (by simpa using (List.mem_filter.mp (regionLabel_mem_candidates h hw hj)).2)

/-! ### From the gate to a fact at the chosen label -/

/-- Every positive demand is **asserted** at the chosen label. -/
theorem regionLabel_hasPos (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {χ : Formula} (hχ : χ ∈ regionPosDemands b ord w j) :
    b.hasPosAt χ ⟨w, regionLabel b ord w j⟩ = true := by
  have hm := regionMeets_regionLabel h hw hj
  rw [regionMeets, Bool.and_eq_true] at hm
  have := (List.all_eq_true.mp hm.1) χ hχ
  simp only [Bool.and_eq_true] at this
  exact this.1

/-- Every positive demand's complement is **absent** at the chosen label. -/
theorem regionLabel_not_hasNeg (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {χ : Formula} (hχ : χ ∈ regionPosDemands b ord w j) :
    b.hasNegAt χ ⟨w, regionLabel b ord w j⟩ = false := by
  have hm := regionMeets_regionLabel h hw hj
  rw [regionMeets, Bool.and_eq_true] at hm
  have := (List.all_eq_true.mp hm.1) χ hχ
  simp only [Bool.and_eq_true, Bool.not_eq_true'] at this
  exact this.2

/-- Every negative demand is **denied** at the chosen label. -/
theorem regionLabel_hasNeg (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {χ : Formula} (hχ : χ ∈ regionNegDemands b ord w j) :
    b.hasNegAt χ ⟨w, regionLabel b ord w j⟩ = true := by
  have hm := regionMeets_regionLabel h hw hj
  rw [regionMeets, Bool.and_eq_true] at hm
  have := (List.all_eq_true.mp hm.2) χ hχ
  simp only [Bool.and_eq_true] at this
  exact this.1

/-- Every negative demand's complement is **absent** at the chosen label. -/
theorem regionLabel_not_hasPos (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {χ : Formula} (hχ : χ ∈ regionNegDemands b ord w j) :
    b.hasPosAt χ ⟨w, regionLabel b ord w j⟩ = false := by
  have hm := regionMeets_regionLabel h hw hj
  rw [regionMeets, Bool.and_eq_true] at hm
  have := (List.all_eq_true.mp hm.2) χ hχ
  simp only [Bool.and_eq_true, Bool.not_eq_true'] at this
  exact this.2

/-! ## The consumption lemmas

Each takes a **branch fact** as hypothesis and delivers a branch fact **at the chosen label** —
the direction `GapAdequate` established and the direction the refuted policies got wrong. Model
truth never appears as a hypothesis.
-/

theorem regionLabel_box (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {χ : Formula} {l : Label} (hmem : (⟨.pos, .box χ, l⟩ : SignedFormula) ∈ b) :
    (⟨.pos, χ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b :=
  mem_of_branch_contains
    (regionLabel_hasPos h hw hj
      (List.mem_append_left _ (List.mem_append_left _ (mem_boxContents hmem))))

theorem regionLabel_diaNeg (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {χ : Formula} {l : Label}
    (hmem : (⟨.neg, .imp (.box (.imp χ .bot)) .bot, l⟩ : SignedFormula) ∈ b) :
    (⟨.neg, χ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b :=
  mem_of_branch_contains
    (regionLabel_hasNeg h hw hj
      (List.mem_append_left _ (List.mem_append_left _ (mem_diaNegContents hmem))))

/-- **The `untl` straddling guard.** An until asserted below the region carries its guard into
the region. -/
theorem regionLabel_untlGuard (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {φ ψ : Formula} {t : TimeIndex}
    (hmem : (⟨.pos, .untl φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : branchRank b ord t < j) :
    (⟨.pos, ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b :=
  mem_of_branch_contains
    (regionLabel_hasPos h hw hj
      (List.mem_append_left _ (List.mem_append_right _ (mem_untlGuards hmem hrk))))

/-- **The `snce` straddling guard**, the mirror image. -/
theorem regionLabel_snceGuard (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {φ ψ : Formula} {t : TimeIndex}
    (hmem : (⟨.pos, .snce φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : j ≤ branchRank b ord t) :
    (⟨.pos, ψ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b :=
  mem_of_branch_contains
    (regionLabel_hasPos h hw hj (List.mem_append_right _ (mem_snceGuards hmem hrk)))

/-- **The `F`-side demand from below.** With `ψ = ⊤` and `φ = ¬χ` this is `T(Gχ)` reaching the
region, which is why no separate `G`/`H` row is needed. -/
theorem regionLabel_untlNeg (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {φ ψ : Formula} {t : TimeIndex}
    (hmem : (⟨.neg, .untl φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : branchRank b ord t < j) :
    (⟨.neg, φ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b :=
  mem_of_branch_contains
    (regionLabel_hasNeg h hw hj
      (List.mem_append_left _ (List.mem_append_right _ (mem_untlNegSubjects hmem hrk))))

/-- **The `F`-side demand from above**, the mirror image; with `ψ = ⊤`, `φ = ¬χ` it is `T(Hχ)`. -/
theorem regionLabel_snceNeg (h : regionLabelCheck b ord = true)
    (hw : w ∈ b.knownWorlds) (hj : j ≤ b.knownTimes.length)
    {φ ψ : Formula} {t : TimeIndex}
    (hmem : (⟨.neg, .snce φ ψ, ⟨w, t⟩⟩ : SignedFormula) ∈ b)
    (hrk : j ≤ branchRank b ord t) :
    (⟨.neg, φ, ⟨w, regionLabel b ord w j⟩⟩ : SignedFormula) ∈ b :=
  mem_of_branch_contains
    (regionLabel_hasNeg h hw hj (List.mem_append_right _ (mem_snceNegSubjects hmem hrk)))

/-! ## The valuation

`branchModel`'s `gapVal` parameter, instantiated. The type is unchanged, so `branchModel`,
`regionModel`, `regionValuation` and every lemma about them are consumed verbatim.
-/

open Classical in
/--
The region index a code names: how many placed points lie below it.

`regionCode f r = ({i | f i < r}, {i | r < f i})` (`Bridge/Interpolate.lean`), so the first
component *is* the set of branch times below `r`, and its cardinality is the `j` of the gate.
Reading the index off the code rather than off `r` is what keeps the valuation a function of the
region, which is what `regionValuation` requires.
-/
noncomputable def cutIndex {b : Branch} (c : Set (BranchTime b) × Set (BranchTime b)) : Nat :=
  (Finset.univ.filter (fun i : BranchTime b => i ∈ c.1)).card

open Classical in
/-- Every code names a region the gate covers. -/
theorem cutIndex_le (b : Branch) (c : Set (BranchTime b) × Set (BranchTime b)) :
    cutIndex c ≤ b.knownTimes.length := by
  rw [cutIndex]
  have h := Finset.card_filter_le (Finset.univ : Finset (BranchTime b))
    (fun i : BranchTime b => i ∈ c.1)
  rwa [Finset.card_univ, Fintype.card_fin] at h

/--
**The gap arm of the atom clause**: a region takes the atoms of its chosen label.

Contrast `branchGapVal` (`Bridge/Valuation.lean`), which reads the region's *forced set*. That is
the whole difference, and `gapAdequate_insufficient` is the proof that it matters.
-/
noncomputable def branchRegionVal (b : Branch) (ord : TimeOrdering) :
    WorldIndex → Set (BranchTime b) × Set (BranchTime b) → Atom → Prop :=
  fun w c p => b.hasPosAt (Formula.atom p) ⟨w, regionLabel b ord w (cutIndex c)⟩ = true

section Model

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**The atom clause at a gap point.** Truth of an atom at a non-placed point is exactly the
branch's assertion of it at that region's chosen label — the readback the induction's `atom` case
consumes, in the same shape `truthAt_atom_branch_placed` has at placed points.
-/
theorem truthAt_atom_branch_region (b : Branch) (ord : TimeOrdering) {f : BranchTime b → D}
    {r : D} (hr : ¬ IsPlacedCode f (regionCode f r)) (w : WorldIndex) (p : Atom) :
    TruthAt (branchModel b f (branchRegionVal b ord))
        (regionHistory f w (0 : D)) r (Formula.atom p) ↔
      b.hasPosAt (Formula.atom p)
        ⟨w, regionLabel b ord w (cutIndex (regionCode f r))⟩ = true :=
  truthAt_atom_gap hr (branchPlacedVal b) (branchRegionVal b ord) w p

/--
**The `box` case at gap points, for atoms** — the case that killed `GapAdequate`, discharged.

`T(□p)` on the branch makes the atom `p` true at *every* gap point of every known world, because
the gate's box row puts `T(p)` at each region's chosen label. `gapAdequate_insufficient` exhibits
a branch where the refuted policy fails this for a compound formula; the compound case is the
induction's, but this is the atom-level instance and it goes the right way.
-/
theorem truthAt_atom_gap_of_box (b : Branch) (ord : TimeOrdering) {f : BranchTime b → D}
    {r : D} (hr : ¬ IsPlacedCode f (regionCode f r))
    (hcheck : regionLabelCheck b ord = true) {w : WorldIndex} (hw : w ∈ b.knownWorlds)
    {p : Atom} {l : Label}
    (hmem : (⟨.pos, .box (Formula.atom p), l⟩ : SignedFormula) ∈ b) :
    TruthAt (branchModel b f (branchRegionVal b ord))
      (regionHistory f w (0 : D)) r (Formula.atom p) := by
  rw [truthAt_atom_branch_region b ord hr w p]
  exact regionLabel_hasPos hcheck hw (cutIndex_le b _)
    (List.mem_append_left _ (List.mem_append_left _ (mem_boxContents hmem)))

end Model

end FormalSystem.Metalogic.Decidability.Verified.Bridge
