/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntTruth

/-!
# The truth correspondence at a dense carrier

`Bridge/IntTruth.lean` runs the signed truth-lemma induction at `ℤ`, where the placement
`finiteOrderEmbInt` is contiguous and so has **no inhabited interior gap**. This file is
sub-phase 7.1d: the same induction at `ℚ` and `ℝ`, where interior gaps *are* inhabited and the
three geometry hypotheses `ℤ` supplied — `RayOnly`, `RaySplit` and `Stepped` — are all false.

## What carries over verbatim, and why that is a theorem rather than a hope

The `atom`, `bot`, `imp` and `box` cases of `IntTruth.lean` are stated for an **arbitrary**
carrier `D` and an **arbitrary** injective placement `f`. Nothing in them mentions `ℤ`, gaps, or
rays: they need only `cutIndex_le`, which is free. They are therefore consumed here unchanged,
and `branchTruthAt_of_temporal` below is the machine-checked statement of exactly that claim —
the whole six-case induction, with the two temporal cases abstracted into hypotheses and the
other four discharged by the landed `ℤ`-file lemmas.

Isolating the assembly this way is the same move that converged the temporal cases at `ℤ`: split
before proving. It has two payoffs. It makes the *only* difference between the discrete and dense
milestones explicit and finite — two hypotheses — so a reader can see at a glance that 7.1d owes
the temporal cases and nothing else. And it means the dense side never restates
`BranchTruthAt`, `stateLabel`, `normModel`, or any of the four non-temporal cases, which is what
the Phase 7 register requires.

## Why the temporal cases genuinely do not carry over

At `ℤ` a non-placed point lies on one of the two rays (`RayOnly`), so the induction never meets
an inhabited interior gap, and `isPlacedCode_of_between` turns the semantics' "at every carrier
point strictly between" into the branch's "at every known time strictly between". At `ℚ` and `ℝ`
that step is simply false: between two consecutive placed points there is a whole interval of
carrier points, none of them placed, all reading one region label.

The replacement is `Bridge/Interpolate.lean`'s `exists_gt_sameRegion` / `exists_lt_sameRegion`,
which supply a witness **by density** where `Stepped` supplied one by a step, together with
`SameRegion` and the invariance induction — a region's points are indistinguishable, so a witness
may be moved within its region. `not_exists_gt_sameRegion_int` is the machine witness that this
route is unavailable at `ℤ`, which is why the two milestones are separate sub-phases rather than
one lemma with a disjunction in it.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

section Model

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {b : Branch} {ord : TimeOrdering} {f : BranchTime b → D}

/-! ## The assembly, with the temporal cases abstracted

`Formula` has exactly six constructors — `atom`, `bot`, `imp`, `box`, `untl`, `snce`. There are
no `G`/`H`/`F`/`P` constructors: `allFuture φ` is `(untl φ.neg ⊤).neg`, so every temporal
universal lands on the `untl`/`snce` cases through `imp`.
-/

/--
**The truth-lemma induction, generic in the carrier and in the two temporal cases.**

The four non-temporal cases are discharged here, once, from `Bridge/IntTruth.lean`'s
carrier-generic lemmas. The `untl` and `snce` cases are hypotheses, because they are the only two
that distinguish a contiguous placement from a dense one.

`IntTruth.branchTruthAt` is the discrete instance of this (it predates the split and is left
exactly as it landed); the dense milestone is the other instance.

Note which gates appear and which do not: `branchOrderValid` and `temporalWitnessCheck` are
**absent**, because none of the four non-temporal cases consumes either. They re-enter through
whatever discharges `hUntl`/`hSnce`.
-/
theorem branchTruthAt_of_temporal (hf : Function.Injective f)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hne : b.knownWorlds ≠ [])
    (hUntl : ∀ φ ψ : Formula, BranchTruthAt b ord f φ → BranchTruthAt b ord f ψ →
      BranchTruthAt b ord f (Formula.untl φ ψ))
    (hSnce : ∀ φ ψ : Formula, BranchTruthAt b ord f φ → BranchTruthAt b ord f ψ →
      BranchTruthAt b ord f (Formula.snce φ ψ))
    (χ : Formula) : BranchTruthAt b ord f χ := by
  induction χ with
  | atom p => exact branchTruthAt_atom hf fc hOpen p
  | bot => exact branchTruthAt_bot fc hOpen
  | imp φ ψ hφ hψ => exact branchTruthAt_imp hSat hφ hψ
  | box φ hφ => exact branchTruthAt_box hf hSat hTot hBA hCheck hne hφ
  | untl φ ψ hφ hψ => exact hUntl φ ψ hφ hψ
  | snce φ ψ hφ hψ => exact hSnce φ ψ hφ hψ

end Model

/-! ## Rank and cut index are the same count

`branchRank b ord t` counts the branch's known times strictly before `t`, in the **branch**
order, as a `List.filter` length. `cutIndex (regionCode f s)` counts the placed points strictly
below `s`, in the **carrier** order, as a `Finset.card`. The dense negative temporal case needs
to compare the two, because `regionLabel_untlNeg` reaches region `j` from a label of rank
`< j` — and the region a witness sits in is named by its cut index.

This is stated for an arbitrary carrier, and is the piece the discrete milestone never needed:
at `ℤ` a witness in a gap is on a ray, so `j` was always `0` or `n` and `branchRank_lt_length`
settled the side condition without any comparison of counts.
-/

section Counting

/--
Counting over `Fin n` by list filter and by `Finset` filter agree.

`Finset.univ` on `Fin n` is `List.finRange n` with a nodup proof attached, so this is definitional
once both sides are unfolded to a multiset length; it is stated separately because the unfolding
is what a caller would otherwise have to repeat.
-/
theorem length_filter_finRange (n : Nat) (p : Fin n → Bool) :
    (List.filter p (List.finRange n)).length
      = (Finset.univ.filter (fun k : Fin n => p k = true)).card := by
  classical
  simp [Finset.univ, Fintype.elems, Finset.card, Finset.filter, Multiset.filter]

/--
**`branchRank`, counted over the index type instead of over the list.**

`b.knownTimes` is the image of `timeAt b` over all of `BranchTime b`
(`List.map_getElem_finRange`), so filtering the list and filtering the index type count the same
elements. No injectivity is needed here: the list and the index type are in definitional
bijection, not merely in bijection.
-/
theorem branchRank_eq_card (b : Branch) (ord : TimeOrdering) (t : TimeIndex) :
    branchRank b ord t
      = (Finset.univ.filter
          (fun k : BranchTime b => strictBefore ord (timeAt b k) t = true)).card := by
  rw [branchRank]
  conv_lhs => rw [← List.map_getElem_finRange b.knownTimes]
  rw [List.filter_map, List.length_map, Function.comp_def]
  exact length_filter_finRange b.knownTimes.length
    (fun k => strictBefore ord b.knownTimes[(k : Nat)] t)

end Counting

section Bridge

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {b : Branch} {ord : TimeOrdering} {f : BranchTime b → D}

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/--
**A placed point's rank is strictly below the cut index of anything above it.**

This is the side condition of `regionLabel_untlNeg` (`Bridge/RegionLabel.lean`), supplied for an
arbitrary region rather than only for the top one, and it is what lets the dense negative `untl`
case treat an interior gap and the upper ray as **one** leaf: both are non-placed points, both
read `regionLabel b ord w (cutIndex (regionCode f s))`, and the reaching lemma is `j`-generic.
At `ℤ` this collapses — `RayOnly` forces `j ∈ {0, n}` — which is exactly why the discrete
milestone got by with `branchRank_lt_length` instead.

The count is strict for a reason worth naming: `i` itself is below `s` and so is counted on the
right, while `strictBefore` is irreflexive on a gated branch and so does not count `i` on the
left. Everything else transfers by `OrderFaithful` alone.
-/
theorem branchRank_lt_cutIndex (hV : branchOrderValid b ord = true) (hOF : OrderFaithful b ord f)
    {i : BranchTime b} {s : D} (his : f i < s) :
    branchRank b ord (timeAt b i) < cutIndex (regionCode f s) := by
  classical
  rw [branchRank_eq_card, cutIndex]
  refine Finset.card_lt_card ⟨fun k hk => ?_, fun hsub => ?_⟩
  · simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
    exact lt_trans (hOF k i hk) his
  · have hi : i ∈ Finset.univ.filter (fun k : BranchTime b => k ∈ (regionCode f s).1) := by
      simp only [Finset.mem_filter, Finset.mem_univ, true_and]
      exact his
    have := hsub hi
    simp only [Finset.mem_filter, Finset.mem_univ, true_and] at this
    rw [irrefl_of_valid hV (timeAt_mem b i)] at this
    exact absurd this (by simp)

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/--
**The cut index is monotone in the carrier point.**

Free of every gate and of the branch order: `{i | f i < r} ⊆ {i | f i < s}` when `r < s`, and the
cut index is that set's cardinality. This is the side condition of the leaf where *both* the
evaluation point and the witness are non-placed — the leaf `ℤ` never had, because `RayOnly`
forbids two distinct inhabited regions strictly between placed points.
-/
theorem cutIndex_mono {r s : D} (hrs : r < s) :
    cutIndex (regionCode f r) ≤ cutIndex (regionCode f s) := by
  classical
  rw [cutIndex, cutIndex]
  refine Finset.card_le_card fun k hk => ?_
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
  exact lt_trans hk hrs

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/--
**A placed point above a region has rank at least that region's cut index.**

The companion of `branchRank_lt_cutIndex` and its exact converse in force: that one says a placed
point *below* `s` has rank strictly below `s`'s cut index, this one says a placed point *above*
`r` has rank at least `r`'s. Together they make `j ≤ branchRank b ord v` the faithful branch-side
reading of "`v`'s placed point lies above every point of region `j`", which is what row 5's first
reach is stated in.

Note which direction of the placement each needs: `branchRank_lt_cutIndex` runs on
`OrderFaithful`, this one on `OrderReflecting`. The inequality is non-strict here because no
element separates the two counts — `r` is not placed, so nothing is gained at the boundary.
-/
theorem cutIndex_le_branchRank (hOR : OrderReflecting b ord f)
    {r : D} {j : BranchTime b} (hrj : r < f j) :
    cutIndex (regionCode f r) ≤ branchRank b ord (timeAt b j) := by
  classical
  rw [branchRank_eq_card, cutIndex]
  refine Finset.card_le_card fun k hk => ?_
  simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hk ⊢
  exact hOR k j (lt_trans hk hrj)

end Bridge

/-! ## The two negative temporal halves, at a dense carrier

`ℤ`'s negative halves are seven leaves apiece, three of them vacuous by `RaySplit`. The dense ones
are **four leaves and none vacuous**, which is fewer rather than more, and the reason is the
`j`-genericity of `regionLabel_untlNeg`: a non-placed point reads
`regionLabel … (cutIndex (regionCode f s))` whether it sits in an interior gap or on a ray, so the
case split is simply *placed or not*, twice, with no ray analysis anywhere. `RayOnly`, `RaySplit`
and `isPlacedCode_of_between` do not appear.

What replaces the ray analysis is arithmetic on the cut index, and all four side conditions are
instances of the three counting lemmas above:

| leaf | reaching lemma | side condition |
|------|----------------|----------------|
| `r` placed, `s` placed | `untlNeg_spread` | `OrderReflecting` |
| `r` placed, `s` not | `regionLabel_untlNeg` | `branchRank_lt_cutIndex` |
| `r` not, `s` placed | `untlNegRegion_up` | `cutIndex_le_branchRank` |
| `r` not, `s` not | `untlNegRegion_label` | `cutIndex_mono` |

The bottom two rows are what row 5's generalisation bought, and the fourth is the one `ℤ` could
not state at all.
-/

section Dense

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {b : Branch} {ord : TimeOrdering} {f : BranchTime b → D}

/--
**Until case, negative half, at a dense carrier.**

Binder list against `IntTruth.branchTruthAt_untl_neg`: `RayOnly` and `RaySplit` are **gone**, and
`OrderFaithful` has entered, because `branchRank_lt_cutIndex` reads the placement forwards where
`untlNeg_spread` reads it backwards. Nothing else moved.
-/
theorem branchTruthAt_untl_neg_dense (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hV : branchOrderValid b ord = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ []) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (w : WorldIndex) (r : D) :
    b.hasNegAt (Formula.untl φ ψ) (stateLabel b ord f w r) = true →
      ¬ TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.untl φ ψ) := by
  intro hn hT
  obtain ⟨s, hrs, hsφ, -⟩ := hT
  have hw' : normWorld b w ∈ b.knownWorlds := normWorld_mem hne w
  have hmem : (⟨.neg, .untl φ ψ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasNegAt_iff_mem b _ _).mp hn
  refine (hφ w s).2 ?_ hsφ
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    by_cases hs : IsPlacedCode f (regionCode f s)
    · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
      rw [stateLabel_placed hf w hj]
      exact untlNeg_spread hTW hmem (timeAt_mem b j) (hOR i j (by rw [hi, hj]; exact hrs))
    · rw [stateLabel_gap w hs, hasNegAt_iff_mem]
      exact regionLabel_untlNeg hCheck hw' (cutIndex_le b _) hmem
        (branchRank_lt_cutIndex hV hOF (by rw [hi]; exact hrs))
  · rw [stateLabel_gap w hr] at hmem
    by_cases hs : IsPlacedCode f (regionCode f s)
    · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
      rw [stateLabel_placed hf w hj]
      exact untlNegRegion_up hTW (cutIndex_le b _) hmem (timeAt_mem b j)
        (cutIndex_le_branchRank hOR (by rw [hj]; exact hrs))
    · rw [stateLabel_gap w hs]
      exact untlNegRegion_label hTW (cutIndex_le b _) (cutIndex_le b _) hmem (cutIndex_mono hrs)

/-- **Since case, negative half, at a dense carrier.** The past-directed mirror, leaf for leaf,
with the two counting lemmas swapping roles: `cutIndex_le_branchRank` supplies
`regionLabel_snceNeg`'s `j ≤ branchRank` where the `untl` half used `branchRank_lt_cutIndex`, and
conversely. -/
theorem branchTruthAt_snce_neg_dense (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hV : branchOrderValid b ord = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ []) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (w : WorldIndex) (r : D) :
    b.hasNegAt (Formula.snce φ ψ) (stateLabel b ord f w r) = true →
      ¬ TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.snce φ ψ) := by
  intro hn hT
  obtain ⟨s, hsr, hsφ, -⟩ := hT
  have hw' : normWorld b w ∈ b.knownWorlds := normWorld_mem hne w
  have hmem : (⟨.neg, .snce φ ψ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasNegAt_iff_mem b _ _).mp hn
  refine (hφ w s).2 ?_ hsφ
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    by_cases hs : IsPlacedCode f (regionCode f s)
    · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
      rw [stateLabel_placed hf w hj]
      exact snceNeg_spread hTW hmem (timeAt_mem b j) (hOR j i (by rw [hi, hj]; exact hsr))
    · rw [stateLabel_gap w hs, hasNegAt_iff_mem]
      exact regionLabel_snceNeg hCheck hw' (cutIndex_le b _) hmem
        (cutIndex_le_branchRank hOR (by rw [hi]; exact hsr))
  · rw [stateLabel_gap w hr] at hmem
    by_cases hs : IsPlacedCode f (regionCode f s)
    · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
      rw [stateLabel_placed hf w hj]
      exact snceNegRegion_dn hTW (cutIndex_le b _) hmem (timeAt_mem b j)
        (branchRank_lt_cutIndex hV hOF (by rw [hj]; exact hsr))
    · rw [stateLabel_gap w hs]
      exact snceNegRegion_label hTW (cutIndex_le b _) (cutIndex_le b _) hmem (cutIndex_mono hsr)


/-! ## The two positive temporal halves, at a dense carrier

The positive halves are where the discrete and dense milestones differ most, and the difference is
one word: at `ℤ` the upper-ray leaf **vanishes** its guard interval — `Stepped` supplies an
immediate successor, so there is nothing strictly between the point and its witness — while at
`ℚ`/`ℝ` no point has a successor and the interval is always inhabited. The guard therefore has to
be *carried across a whole region* instead, which is precisely the demand row 11's `self` disjunct
makes and no `ℤ` row ever did.

`exists_gt_sameRegion` supplies the witness `Stepped` used to, and `sameRegion_convex` does the
work `upperRay_of_gt` did: everything between a point and a region-mate above it is another
region-mate, so it reads the same label and the single guard fact at that label covers the whole
interval. `RayOnly`, `RaySplit`, `Stepped`, `upperRay_of_gt` and `isPlacedCode_of_between` are all
absent.

The **placed** leaf is the one place a landed row is consumed for the first time:
`regionLabel_untlGuard` — `Bridge/RegionLabel.lean`'s straddling guard — closes the sub-leaf where
the guard interval of a placed-to-placed witness meets a non-placed point. `ℤ` never called it
because contiguity made that sub-leaf empty (`isPlacedCode_of_between`). It is worth naming that
this costs **nothing** in gate strength: `untlGuards` is already a row of `regionLabelCheck`, so
consuming it adds no obligation that sub-phase 7.3 did not already carry.
-/

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- A known time whose rank reaches a non-placed point's region is placed strictly above it.
The converse of `branchRank_lt_cutIndex`, in the contrapositive form the witness leaf needs. -/
theorem lt_of_cutIndex_le_branchRank (hV : branchOrderValid b ord = true)
    (hOF : OrderFaithful b ord f) {r : D} (hr : ¬ IsPlacedCode f (regionCode f r))
    {k : BranchTime b} (hrk : cutIndex (regionCode f r) ≤ branchRank b ord (timeAt b k)) :
    r < f k := by
  rcases lt_trichotomy (f k) r with hlt | heq | hgt
  · exact absurd (branchRank_lt_cutIndex hV hOF hlt) (not_lt.mpr hrk)
  · exact absurd (isPlacedCode_of_eq heq) hr
  · exact hgt

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- The mirror: a known time whose rank falls short of a non-placed point's region is placed
strictly below it. -/
theorem gt_of_branchRank_lt_cutIndex (hOR : OrderReflecting b ord f) {r : D}
    (hr : ¬ IsPlacedCode f (regionCode f r)) {k : BranchTime b}
    (hrk : branchRank b ord (timeAt b k) < cutIndex (regionCode f r)) : f k < r := by
  rcases lt_trichotomy (f k) r with hlt | heq | hgt
  · exact hlt
  · exact absurd (isPlacedCode_of_eq heq) hr
  · exact absurd (cutIndex_le_branchRank hOR hgt) (not_le.mpr hrk)

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- **Region-mates read the same label.** This is what replaces `upperRay_of_gt`: at `ℤ` the fact
that everything above a ray point reads the ray's label was derived from `RayOnly`/`RaySplit`; here
it is the definition of a region, and it holds at every region rather than only at the two rays. -/
theorem stateLabel_sameRegion (w : WorldIndex) {r s : D}
    (hr : ¬ IsPlacedCode f (regionCode f r)) (h : SameRegion f r s) :
    stateLabel b ord f w s = stateLabel b ord f w r := by
  have hc : regionCode f r = regionCode f s := sameRegion_iff_regionCode_eq.mp h
  have hs : ¬ IsPlacedCode f (regionCode f s) := hc ▸ hr
  rw [stateLabel_gap w hs, stateLabel_gap w hr, hc]

/--
**Until case, positive half, at a dense carrier.**

Four leaves: the evaluation point is placed or not, and in each case the witness comes from a
known time or from the point's own region. `DenselyOrdered` and `NoMaxOrder` enter here and
nowhere else in the file — they are what `Stepped` was.
-/
theorem branchTruthAt_untl_pos_dense [DenselyOrdered D] [NoMaxOrder D]
    (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hV : branchOrderValid b ord = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ []) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (hψ : BranchTruthAt b ord f ψ) (w : WorldIndex) (r : D) :
    b.hasPosAt (Formula.untl φ ψ) (stateLabel b ord f w r) = true →
      TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.untl φ ψ) := by
  intro hp
  have hw' : normWorld b w ∈ b.knownWorlds := normWorld_mem hne w
  have hmem : (⟨.pos, .untl φ ψ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasPosAt_iff_mem b _ _).mp hp
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    obtain ⟨t', ht'mem, ht'lt, ht'φ, hguard⟩ := untlPos_witness hTW hmem
    obtain ⟨j, hj⟩ := exists_index_of_mem_knownTimes ht'mem
    refine ⟨f j, by rw [← hi]; exact hOF i j (by rw [hj]; exact ht'lt), ?_, ?_⟩
    · exact (hφ w (f j)).1 (by rw [stateLabel_placed hf w (rfl : f j = f j), hj]; exact ht'φ)
    · intro u hru huj
      by_cases hu : IsPlacedCode f (regionCode f u)
      · obtain ⟨k, hk⟩ := exists_eq_of_isPlacedCode hu
        rcases hguard with hg | hg
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          rw [stateLabel_placed hf w hk]
          exact hg (timeAt b k) (timeAt_mem b k) (hOR i k (by rw [hi, hk]; exact hru))
            (by rw [← hj]; exact hOR k j (by rw [hk]; exact huj))
      · refine (hψ w u).1 ?_
        rw [stateLabel_gap w hu, hasPosAt_iff_mem]
        exact regionLabel_untlGuard hCheck hw' (cutIndex_le b _) hmem
          (branchRank_lt_cutIndex hV hOF (by rw [hi]; exact hru))
  · rw [stateLabel_gap w hr] at hmem
    have hrne : ∀ i : BranchTime b, f i ≠ r := fun i hi => hr (isPlacedCode_of_eq hi)
    rcases untlPosRegion_witness hTW (cutIndex_le b _) hmem with
      ⟨hlabφ, hlabψ⟩ | ⟨v, hv, hrk, hvφ, hg⟩
    · obtain ⟨s, hrs, hsr⟩ := exists_gt_sameRegion hrne
      refine ⟨s, hrs, ?_, ?_⟩
      · exact (hφ w s).1 (by rw [stateLabel_sameRegion w hr hsr, stateLabel_gap w hr]; exact hlabφ)
      · intro u hru hus
        rcases hlabψ with hg | hg
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          rw [stateLabel_sameRegion w hr (sameRegion_convex hsr (le_of_lt hru) (le_of_lt hus)),
            stateLabel_gap w hr]
          exact hg
    · obtain ⟨k, hk⟩ := exists_index_of_mem_knownTimes hv
      have hrk' : r < f k := lt_of_cutIndex_le_branchRank hV hOF hr (by rw [hk]; exact hrk)
      refine ⟨f k, hrk', ?_, ?_⟩
      · exact (hφ w (f k)).1 (by rw [stateLabel_placed hf w (rfl : f k = f k), hk]; exact hvφ)
      · intro u hru huk
        rcases hg with hg | ⟨hgK, hgR⟩
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          by_cases hu : IsPlacedCode f (regionCode f u)
          · obtain ⟨m, hm⟩ := exists_eq_of_isPlacedCode hu
            rw [stateLabel_placed hf w hm]
            exact hgK (timeAt b m) (timeAt_mem b m)
              (cutIndex_le_branchRank hOR (by rw [hm]; exact hru))
              (by rw [← hk]; exact hOR m k (by rw [hm]; exact huk))
          · rw [stateLabel_gap w hu]
            exact hgR (cutIndex (regionCode f u)) (cutIndex_mono hru)
              (by rw [← hk]; exact cutIndex_le_branchRank hOR huk) (cutIndex_le b _)

/--
**Since case, positive half, at a dense carrier.** The past-directed mirror, leaf for leaf, with
`exists_lt_sameRegion` for `exists_gt_sameRegion` and `regionLabel_snceGuard` for
`regionLabel_untlGuard`.
-/
theorem branchTruthAt_snce_pos_dense [DenselyOrdered D] [NoMinOrder D]
    (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hV : branchOrderValid b ord = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ []) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (hψ : BranchTruthAt b ord f ψ) (w : WorldIndex) (r : D) :
    b.hasPosAt (Formula.snce φ ψ) (stateLabel b ord f w r) = true →
      TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.snce φ ψ) := by
  intro hp
  have hw' : normWorld b w ∈ b.knownWorlds := normWorld_mem hne w
  have hmem : (⟨.pos, .snce φ ψ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasPosAt_iff_mem b _ _).mp hp
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    obtain ⟨t', ht'mem, ht'lt, ht'φ, hguard⟩ := sncePos_witness hTW hmem
    obtain ⟨j, hj⟩ := exists_index_of_mem_knownTimes ht'mem
    refine ⟨f j, by rw [← hi]; exact hOF j i (by rw [hj]; exact ht'lt), ?_, ?_⟩
    · exact (hφ w (f j)).1 (by rw [stateLabel_placed hf w (rfl : f j = f j), hj]; exact ht'φ)
    · intro u hju hur
      by_cases hu : IsPlacedCode f (regionCode f u)
      · obtain ⟨k, hk⟩ := exists_eq_of_isPlacedCode hu
        rcases hguard with hg | hg
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          rw [stateLabel_placed hf w hk]
          exact hg (timeAt b k) (timeAt_mem b k) (hOR k i (by rw [hi, hk]; exact hur))
            (by rw [← hj]; exact hOR j k (by rw [hk]; exact hju))
      · refine (hψ w u).1 ?_
        rw [stateLabel_gap w hu, hasPosAt_iff_mem]
        exact regionLabel_snceGuard hCheck hw' (cutIndex_le b _) hmem
          (cutIndex_le_branchRank hOR (by rw [hi]; exact hur))
  · rw [stateLabel_gap w hr] at hmem
    have hrne : ∀ i : BranchTime b, f i ≠ r := fun i hi => hr (isPlacedCode_of_eq hi)
    rcases sncePosRegion_witness hTW (cutIndex_le b _) hmem with
      ⟨hlabφ, hlabψ⟩ | ⟨v, hv, hrk, hvφ, hg⟩
    · obtain ⟨s, hsr, hsr'⟩ := exists_lt_sameRegion hrne
      refine ⟨s, hsr, ?_, ?_⟩
      · exact (hφ w s).1 (by rw [stateLabel_sameRegion w hr hsr', stateLabel_gap w hr]; exact hlabφ)
      · intro u hsu hur
        rcases hlabψ with hg | hg
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          rw [stateLabel_sameRegion w hr
            (hsr'.trans (sameRegion_convex hsr'.symm (le_of_lt hsu) (le_of_lt hur))),
            stateLabel_gap w hr]
          exact hg
    · obtain ⟨k, hk⟩ := exists_index_of_mem_knownTimes hv
      have hrk' : f k < r := gt_of_branchRank_lt_cutIndex hOR hr (by rw [hk]; exact hrk)
      refine ⟨f k, hrk', ?_, ?_⟩
      · exact (hφ w (f k)).1 (by rw [stateLabel_placed hf w (rfl : f k = f k), hk]; exact hvφ)
      · intro u hku hur
        rcases hg with hg | ⟨hgK, hgR⟩
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          by_cases hu : IsPlacedCode f (regionCode f u)
          · obtain ⟨m, hm⟩ := exists_eq_of_isPlacedCode hu
            rw [stateLabel_placed hf w hm]
            exact hgK (timeAt b m) (timeAt_mem b m)
              (branchRank_lt_cutIndex hV hOF (by rw [hm]; exact hur))
              (by rw [← hk]; exact hOR k m (by rw [hm]; exact hku))
          · rw [stateLabel_gap w hu]
            exact hgR (cutIndex (regionCode f u)) (cutIndex_mono hur)
              (by rw [← hk]; exact branchRank_lt_cutIndex hV hOF hku) (cutIndex_le b _)

end Dense


/-! ## The assembled induction, and the `ℚ`/`ℝ` instantiation

The assembly is `branchTruthAt_of_temporal` with the four halves above plugged in — one line per
operator, no second induction, which is what isolating the assembly first bought.

For the instantiation the placement is the `ℤ` one **cast**, not a new construction. Everything
the temporal cases ask of a placement (`Function.Injective`, `OrderFaithful`, `OrderReflecting`)
transports along any strictly monotone map, and `Int.cast` into an ordered field is one. What does
*not* transport — and what makes this a separate milestone rather than a corollary — is
`RayOnly`/`RaySplit`/`Stepped`: the cast image of a contiguous block is not contiguous in `ℚ`,
which is exactly the content of `not_exists_gt_sameRegion_int` read the other way round.
-/

section Transport

variable {D E : Type}
variable [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable [AddCommGroup E] [LinearOrder E] [IsOrderedAddMonoid E]
variable {b : Branch} {ord : TimeOrdering} {f : BranchTime b → D}

omit [AddCommGroup D] [IsOrderedAddMonoid D] [AddCommGroup E] [IsOrderedAddMonoid E] in
/-- Order faithfulness transports along a strictly monotone map. -/
theorem orderFaithful_comp {g : D → E} (hg : StrictMono g) (hOF : OrderFaithful b ord f) :
    OrderFaithful b ord (g ∘ f) := fun i j hij => hg (hOF i j hij)

omit [AddCommGroup D] [IsOrderedAddMonoid D] [AddCommGroup E] [IsOrderedAddMonoid E] in
/-- Order reflection transports along a strictly monotone map. -/
theorem orderReflecting_comp {g : D → E} (hg : StrictMono g) (hOR : OrderReflecting b ord f) :
    OrderReflecting b ord (g ∘ f) := fun i j hij => hOR i j (hg.lt_iff_lt.mp hij)

end Transport

section Assembly

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
variable {b : Branch} {ord : TimeOrdering} {f : BranchTime b → D}

/-- **The truth lemma at a dense carrier**, at every formula.

Binder list against `IntTruth.branchTruthAt`: `RayOnly`, `RaySplit` and `Stepped` are gone and
`[DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]` have taken their place. That is the whole of the
difference between the two milestones. -/
theorem branchTruthAt_dense [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]
    (hf : Function.Injective f) (hOF : OrderFaithful b ord f) (hOR : OrderReflecting b ord f)
    (hV : branchOrderValid b ord = true) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ []) (χ : Formula) : BranchTruthAt b ord f χ :=
  branchTruthAt_of_temporal hf fc hSat hOpen hTot hBA hCheck hne
    (fun _ _ hφ hψ w r =>
      ⟨branchTruthAt_untl_pos_dense hf hOF hOR hV hCheck hTW hne hφ hψ w r,
        branchTruthAt_untl_neg_dense hf hOF hOR hV hCheck hTW hne hφ w r⟩)
    (fun _ _ hφ hψ w r =>
      ⟨branchTruthAt_snce_pos_dense hf hOF hOR hV hCheck hTW hne hφ hψ w r,
        branchTruthAt_snce_neg_dense hf hOF hOR hV hCheck hTW hne hφ w r⟩)
    χ

end Assembly

section DenseCarrier

variable {b : Branch} {ord : TimeOrdering}

/--
**The countermodel at an arbitrary dense carrier reached by a strictly monotone cast.**

Stated once and applied twice, because the `ℚ` and `ℝ` headline results differ only in which
binder list the validity predicate carries — the model, the placement and the truth lemma are the
same objects, exactly as `not_valid_of_hasOpen_int` and `not_validDiscrete_of_hasOpen_int` are at
`ℤ`.
-/
theorem exists_countermodel_dense (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]
    {g : ℤ → D} (hg : StrictMono g)
    (hV : branchOrderValid b ord = true) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    {χ : Formula} {l₀ : Label} (hw₀ : l₀.world ∈ b.knownWorlds)
    (hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b) :
    ∃ t : D, ¬ TruthAt (normModel b ord (g ∘ intPlace b ord hV))
      (regionHistory (g ∘ intPlace b ord hV) l₀.world (0 : D)) t χ := by
  set f : BranchTime b → D := g ∘ intPlace b ord hV with hf_def
  have hf : Function.Injective f := hg.injective.comp (intPlace_injective hV)
  have hOF : OrderFaithful b ord f := orderFaithful_comp hg (orderFaithful_intPlace hV)
  have hOR : OrderReflecting b ord f := orderReflecting_comp hg (orderReflecting_intPlace hV)
  have hne : b.knownWorlds ≠ [] := fun hc => by rw [hc] at hw₀; exact absurd hw₀ (by simp)
  obtain ⟨i, hi⟩ := exists_index_of_mem_knownTimes (mem_knownTimes_of_mem hroot)
  have hlab : stateLabel b ord f l₀.world (f i) = l₀ := by
    rw [stateLabel_placed hf l₀.world (rfl : f i = f i), normWorld_eq_self hw₀, hi]
  have hneg : b.hasNegAt χ (stateLabel b ord f l₀.world (f i)) = true := by
    rw [hlab, hasNegAt_iff_mem]; exact hroot
  exact ⟨f i, (branchTruthAt_dense hf hOF hOR hV fc hSat hOpen hTot hBA hCheck hTW hne
    χ l₀.world (f i)).2 hneg⟩

/-- The cast `ℤ → ℚ` is strictly monotone. -/
theorem strictMono_intCast_rat : StrictMono (fun z : ℤ => (z : ℚ)) :=
  fun a c h => by show (a : ℚ) < (c : ℚ); exact_mod_cast h

/-- The cast `ℤ → ℝ` is strictly monotone. -/
theorem strictMono_intCast_real : StrictMono (fun z : ℤ => (z : ℝ)) :=
  fun a c h => by show (a : ℝ) < (c : ℝ); exact_mod_cast h

/-! ### Headline result, at `ℚ` -/

/--
**`not_validDense_of_hasOpen`.** A saturated open branch denying `χ` at one of its labels refutes
`ValidDense χ`, the countermodel being carried by `ℚ`.

`ℚ` is `DenselyOrdered`, `NoMaxOrder`, `NoMinOrder` and `Nontrivial`, which is `ValidDense`'s
binder list plus the two end-point conditions the truth lemma needs and the predicate does not
mention.
-/
theorem not_validDense_of_hasOpen (hV : branchOrderValid b ord = true)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    {χ : Formula} {l₀ : Label} (hw₀ : l₀.world ∈ b.knownWorlds)
    (hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b) : ¬ ValidDense χ := by
  intro hval
  obtain ⟨t, ht⟩ := exists_countermodel_dense ℚ strictMono_intCast_rat hV fc hSat hOpen hTot hBA
    hCheck hTW hw₀ hroot
  exact ht (hval ℚ (regionFrame WorldIndex (BranchTime b) ℚ) _ _ (fun _ => trivial) t)

/-! ### Headline result, at `ℝ` -/

/--
**`not_validDedekindDense_of_hasOpen`.** The same branch refutes `ValidDedekindDense χ`, the
countermodel being carried by `ℝ`.

This is the real-flow result, and it is the one `soundness_dedekind` targets. The extra binder
`ValidDedekindDense` carries over `ValidDense` is the least-upper-bound property, discharged for
`ℝ` by `isLUB_csSup`; nothing in the truth lemma consumes it.
-/
theorem not_validDedekindDense_of_hasOpen (hV : branchOrderValid b ord = true)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    {χ : Formula} {l₀ : Label} (hw₀ : l₀.world ∈ b.knownWorlds)
    (hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b) : ¬ ValidDedekindDense χ := by
  intro hval
  obtain ⟨t, ht⟩ := exists_countermodel_dense ℝ strictMono_intCast_real hV fc hSat hOpen hTot hBA
    hCheck hTW hw₀ hroot
  exact ht (hval ℝ (fun s hs hb => ⟨sSup s, isLUB_csSup hs hb⟩)
    (regionFrame WorldIndex (BranchTime b) ℝ) _ _ (fun _ => trivial) t)

end DenseCarrier

end FormalSystem.Metalogic.Decidability.Verified.Bridge
