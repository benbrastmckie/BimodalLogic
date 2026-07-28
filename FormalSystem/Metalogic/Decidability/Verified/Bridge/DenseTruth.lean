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

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
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

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
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

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
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
      ¬ TruthAt (normModel b ord f) (regionOmega f) (regionHistory f w (0 : D)) r
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
      ¬ TruthAt (normModel b ord f) (regionOmega f) (regionHistory f w (0 : D)) r
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

end Dense

end FormalSystem.Metalogic.Decidability.Verified.Bridge
