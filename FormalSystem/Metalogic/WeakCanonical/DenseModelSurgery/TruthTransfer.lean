/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.BadIntervals

/-!
# Reynolds §6 Lemma 8: truth preservation under bad-interval surgery

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§6 *"No gaps between equivalence classes"*, printed **pp.181-182**.

This module continues `BadIntervals.lean` (Lemmas 6 and 7) with **Lemma 8**: the whole of a bad
interval may be replaced by any single one of its `∼`-classes without changing the truth value of
any temporal formula at any surviving point.

The printed page range was **corrected** from an earlier `pp.179-180`: the §6 page map measured
off the page images is `printed = PDF page + 164`, and Lemma 8 occupies PDF pages 17-18 = printed
**pp.181-182**. Both pages were read as images before transcription, as §6's *displayed* formulas
in the local corpus are known to be unreliable while its inline prose is clean.

## The source, verbatim

Printed **p.181**, the surgery set-up:

> Let us see what happens if we interfere with `M` by replacing a whole bad interval by one of
> its `∼`-classes.
>
> Let `Q⁻` be the subset of the domain of `M` being all that precedes the bad interval. Let `Q⁺`
> be all that follows. Either or both of these may be empty. Let `Q₀` be the bad interval itself
> and `I` be any one of its `∼`-classes.
>
> We look at `N`, the substructure of `M` whose domain is just `Q⁻ ∪ I ∪ Q⁺`.

Printed **p.181**, **Lemma 8**:

> **LEMMA 8** *For all temporal formulas `A`, for all `t ∈ N`,*
>
> `M ⊨ A(t)` *iff* `N ⊨ A(t)`
>
> **PROOF.** We proceed by induction on the construction of `A`. The cases of atomic and boolean
> `A` are immediate. Now consider `U(A,B)`: `S(A,B)` is similar.
>
> `(⇒)`: Consider then when `M ⊨ U(A,B)(t)` with `t ∈ N`. Say that `s ∈ M`, that `t < s`, that
> `M ⊨ A(s)` and for all `u ∈ M`, if `t < u < s` then `M ⊨ B(u)`.
>
> There are several cases.
>
> 1. `t < s ∈ Q⁻`: Apply the induction hypothesis to `A` and `B` at `s` and at all points in
>    between.
>
> 2. `t ∈ Q⁻` and `s ∈ Q₀`: `A` holds somewhere in `Q₀` so somewhere in `I` (by lemma 7). So
>    holds there in `I` in `N`. `B` holds for a while into `Q₀` so, by lemma 7, holds everywhere
>    in `Q₀`. By the induction hypothesis, `B` holds everywhere in `I` in `N`. Hence result.
>
> 3. `t ∈ Q⁻` and `s ∈ Q⁺`: We can deduce that `B` holds throughout `I` in both `M` and `N` and
>    get the result.
>
> 4. `t < s ∈ I`: Straight forward use of inductive hypothesis.
>
> 5. `t ∈ I` and `s` later in `Q₀`: Again by lemma 7 we have `B` true throughout `I` in `M` and
>    so in `N`. Since `A` is true somewhere in `Q₀` in `M`, lemma 7 tells us that `A` is true
>    arbitrarily close to the end of `I` in `M` and so in `N`. This gives us our result.
>
> 6. `t ∈ I` and `s ∈ Q⁺`: `B` is true throughout `I` and we have our result.
>
> 7. `t < s ∈ Q⁺`: Apply induction hypothesis to `A` and `B` at `s` and at all points in between.

Printed **p.182**, the converse direction:

> `(⇐)`: Consider then when `N ⊨ U(A,B)(t)`. Say that `t < s`, that `N ⊨ A(s)` and for all
> `u ∈ N`, if `t < u < s` then `N ⊨ B(u)`.
>
> Again there are several cases:
>
> 1. `t < s ∈ Q⁻`: Apply induction hypothesis to `A` and `B` at `s` and at all points in between.
>
> 2. `t ∈ Q⁻` and `s ∈ I`: `B` holds from `t` up until the end of `Q⁻` in both `M` and `N`. `B`
>    holds at the beginning of `I` in `N` and so in `M`. By lemma 7 `B` holds throughout `Q₀`.
>    `A` holds in `I` in `N` and so in `M` and we have our result.
>
> 3. `t ∈ Q⁻` and `s ∈ Q⁺`: `B` holds throughout `I` in `N` and so in `M`. Lemma 7 tells us `B`
>    holds throughout `Q₀` in `M`.
>
> 4. `t < s ∈ I`: Straight forward use of inductive hypothesis.
>
> 5. `t ∈ I` and `s ∈ Q⁺`: `B` is true throughout `I` and we have our result.
>
> 6. `t < s ∈ Q⁺`: Apply induction hypothesis to `A` and `B` at `s` and at all points in
>    between. ∎

**Case count, measured rather than assumed**: seven forward cases and six backward, thirteen in
all, counted off the two page images. The backward direction is one shorter because `N` has no
`Q₀ \ I` for `s` to land in.

## What is rendered rather than quoted

Reynolds' seven forward cases are *jointly exhaustive but not pairwise disjoint* — his case 4
(*"`t < s ∈ I`"*) overlaps his case 2 (*"`t ∈ Q⁻` and `s ∈ Q₀`"*) when `t ∈ Q⁻` and `s ∈ I`. Lean
needs a disjoint split, so the transcription below fixes the position of `t` first (`Q⁻`, `I`,
`Q⁺`) and the position of `s` second, which yields `3 + 3 + 1 = 7` cases in the forward direction
and `3 + 2 + 1 = 6` in the backward direction — exactly Reynolds' counts, with his case 4 read as
the `t ∈ I` reading throughout. The case names below record the correspondence.

## The gap-crossing family: which form this module uses

Three gap-crossing contradictions coexist in this tree and differ only in their preconditions:
`false_of_holds_throughout_class` (unbounded), `false_of_holds_throughout_class_bounded`, and
`false_of_holds_throughout_class_from_bounded` (with the Prior-S mirror
`false_of_holds_throughout_class_upto_bounded`). **This module uses none of them directly.** It
consumes only `reynolds_lemma7` and its four halves, which have already made that choice
internally; picking a gap-crossing form again here would be re-deriving Lemma 7. The Q-wide forms
in the `Lemma7Wide` section below are the *only* new bridge, and they are pure re-indexing of the
landed segment-bounded statements — no Prior axiom is applied in this module outside those four
calls.

## Relation to `truth_transfer` (`Transfer.lean:361`)

`truth_transfer` does **not** transfer to Lemma 8 and is not used here. It is an
Ehrenfeucht-Fraïssé argument: it moves an *existentially closed* temporal formula between two
`k`-equivalent structures via `table_correctness`, and its conclusion is *"`ψ` holds at some
point of `N`"*. Lemma 8 needs point-by-point agreement at a *designated* `t`, between two
structures that are not assumed `k`-equivalent, with the whole content sitting in the `U`/`S`
cases. The only shared vocabulary is `TemporalTruth` itself. Recorded here so the comparison is
not made twice.

## Honest caveat on conditionality

**Every §6 lemma below Lemma 2 is conditional**, this one included. `IsContempEquivDense ε` and
the semantic Prior-U / Prior-S schemes are *hypotheses*, and the only `ε` this tree can currently
exhibit satisfying them is `epsTop`, for which `EndsInGapOnRight` is empty — so there is no live
non-trivial instance of anything in this file. Nothing in §6 below Lemma 2 may be described as
discharged until the anti-vacuity instance is landed alongside Lemma 9 and Theorem 4. This
caveat is load-bearing and is not to be weakened.

## Proof-step → name map

| Printed step (pp.181-182) | Declaration |
|---|---|
| *"Let `Q₀` be the bad interval itself and `I` be any one of its `∼`-classes"* | `IsBadIntervalSurgery` |
| *"the substructure of `M` whose domain is just `Q⁻ ∪ I ∪ Q⁺`"* | `SurgeryDomain`, `surgeredStructure` |
| *"`Q⁻` … all that precedes"*, *"`Q⁺` … all that follows"* | `IsBadIntervalSurgery.lt_of_before`, `.lt_of_after` |
| *"`I` … one of its `∼`-classes"* (`I ⊆ Q₀`) | `IsBadIntervalSurgery.mem_of_contemp` |
| *"by lemma 7 … holds everywhere in `Q₀`"* (start) | `IsBadIntervalSurgery.lemma7_start_wide` |
| *"by lemma 7 … holds everywhere in `Q₀`"* (end) | `IsBadIntervalSurgery.lemma7_end_wide` |
| *"true arbitrarily close to the end of `I`"* | `IsBadIntervalSurgery.lemma7_close_right_wide` |
| *"true arbitrarily close to \[the start\] of `I`"* | `IsBadIntervalSurgery.lemma7_close_left_wide` |
| *"The cases of atomic and boolean `A` are immediate"* | `reynolds_lemma8` — `atom`/`bot`/`imp`/`box` |
| forward cases 1-7 | `reynolds_lemma8_untl_forward` |
| backward cases 1-6 | `reynolds_lemma8_untl_backward` |
| *"`S(A,B)` is similar"* | `reynolds_lemma8_snce_forward`, `reynolds_lemma8_snce_backward` |
| **LEMMA 8** itself | `reynolds_lemma8` |
-/

namespace FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

open FormalSystem.Syntax FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! ## The surgered structure

*"We look at `N`, the substructure of `M` whose domain is just `Q⁻ ∪ I ∪ Q⁺`."* -/

/-- **Restriction of an ordered monadic structure to a subset of its domain.**

The general form of `OrderedMonadicStructure.subinterval` (`MonadicFO.lean:215`), which is this
construction at `D x := a ≤ x ∧ x ≤ b`. Predicates are inherited pointwise and the order is the
inherited `Subtype` order, so `M.interp p x.val` is *definitionally* the reading of `p` at `x` in
the restriction — which is what makes Lemma 8's atomic and box cases `Iff.rfl`. -/
def restrictStructure (M : OrderedMonadicStructure sig) (D : M.carrier → Prop) :
    OrderedMonadicStructure sig where
  carrier := {x : M.carrier // D x}
  interp p x := M.interp p x.val
  carrierOrder := inferInstance

@[simp] theorem restrictStructure_lt {M : OrderedMonadicStructure sig} {D : M.carrier → Prop}
    (x y : (restrictStructure M D).carrier) : x < y ↔ x.val < y.val := Iff.rfl

/-- **`Q⁻ ∪ I ∪ Q⁺`** — printed p.181.

`Q` is the bad interval `Q₀` and `I` is the `∼`-class of `t`. Everything outside `Q` is either
`Q⁻` or `Q⁺` because a bad interval is convex, so *"all that precedes"* together with *"all that
follows"* is exactly `¬ Q`. Stated in that two-clause form rather than as a three-way union so
that membership is decided by a single question about `Q`. -/
def SurgeryDomain (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t x : M.carrier) : Prop :=
  ¬ Q x ∨ ContempEquivDense M ε t x

/-- **`N`**, the structure Lemma 8 compares against `M` — printed p.181. -/
def surgeredStructure (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier) : OrderedMonadicStructure sig :=
  restrictStructure M (SurgeryDomain M ε Q t)

/-! ## The surgery set-up

Reynolds' set-up sentence carries more than it says: *"`Q₀` the bad interval"* and *"`I` … one of
its `∼`-classes"* are used in the proof of Lemma 8 through Lemma 7, which in this tree is stated
on a **bounded** segment `[a, b]` straddling a class in the interior of the interval
(`ClassInteriorToBadInterval`). The `interior` field below is the bridge: any two points of the
interval are covered by one such segment. It is a *rendering* of Lemma 4 (*"no last class and no
first class in any maximal interval"*) plus Lemma 6 (*"in any bad interval both `R` and `L` hold
throughout"*) — not an assumption of Lemma 7, whose content it does not contain. -/

/-- **The bad-interval surgery set-up** — printed p.181.

`Q` is `Q₀` and the `∼`-class of `t` is `I`. -/
structure IsBadIntervalSurgery (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier) : Prop where
  /-- *"`Q₀` … the bad interval itself"*. -/
  isBad : IsBadInterval M ε Q
  /-- *"`I` be any one of its `∼`-classes"*: `I` is the class of `t`, and `t` is in `Q₀`. -/
  mem : Q t
  /-- Every point of `Q₀` sits in a Lemma-7-usable segment straddling any given class of `Q₀`.
  This is Lemma 4 and Lemma 6 in the form Lemma 7 consumes. -/
  interior : ∀ p u : M.carrier, Q p → Q u →
    ∃ a b : M.carrier, a ≤ u ∧ u ≤ b ∧ ClassInteriorToBadInterval M ε a p b

namespace IsBadIntervalSurgery

variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2} {Q : M.carrier → Prop}
  {t : M.carrier}

/-- Points of `Q₀` are bad points. -/
theorem badPoint (hS : IsBadIntervalSurgery M ε Q t) {u : M.carrier} (hu : Q u) :
    IsBadPoint M ε u := hS.isBad.bad u hu

/-- **A whole `∼`-class of a point of `Q₀` lies inside `Q₀`** — *"`I` be any one of its
`∼`-classes"* read as a containment.

Derived, not assumed: the interiority witnesses put the class inside `[a, b]`, `R` holds
throughout `[a, b]`, and the saturation clause of `IsBadInterval` then pulls `[a, b]` into `Q`. -/
theorem mem_of_contemp (hS : IsBadIntervalSurgery M ε Q t) (hε : IsContempEquivDense ε)
    {p q : M.carrier} (hp : Q p) (hpq : ContempEquivDense M ε p q) : Q q := by
  obtain ⟨a, b, _, _, hint⟩ := hS.interior p p hp hp
  have haq : a < q := lt_of_classMate hε M hint.toR.left_lt hint.toR.left_out hpq
  have hqb : q < b := classMate_lt hε M hint.toR.lt_right hint.toR.right_out hpq
  refine hS.isBad.saturated p q hp (fun r hr₁ hr₂ => IsBadPoint.of_right ?_)
  refine hint.toR.rThroughout r ?_ ?_
  · exact le_trans (le_min hint.toR.left_lt.le haq.le) hr₁
  · exact le_trans hr₂ (max_le hint.toR.lt_right.le hqb.le)

/-- **`I ⊆ Q₀`** at the designated class. -/
theorem mem_of_contemp_base (hS : IsBadIntervalSurgery M ε Q t) (hε : IsContempEquivDense ε)
    {q : M.carrier} (h : ContempEquivDense M ε t q) : Q q :=
  hS.mem_of_contemp hε hS.mem h

/-- **`Q⁻` precedes the bad interval** — *"all that precedes"*, printed p.181.

A point outside `Q₀` and below `t` is below *every* point of `Q₀`, by convexity. -/
theorem lt_of_before (hS : IsBadIntervalSurgery M ε Q t) {x u : M.carrier} (hx : ¬ Q x)
    (hxt : x < t) (hu : Q u) : x < u := by
  by_contra hcon
  push_neg at hcon
  exact hx (hS.isBad.convex u x t hcon hxt.le hu hS.mem)

/-- **`Q⁺` follows the bad interval** — *"all that follows"*, printed p.181. -/
theorem lt_of_after (hS : IsBadIntervalSurgery M ε Q t) {x u : M.carrier} (hx : ¬ Q x)
    (htx : t < x) (hu : Q u) : u < x := by
  by_contra hcon
  push_neg at hcon
  exact hx (hS.isBad.convex t x u htx.le hcon hS.mem hu)

/-- A point of `N` outside `Q₀` is either wholly below `Q₀` or wholly above it. -/
theorem lt_or_gt_of_not_mem (hS : IsBadIntervalSurgery M ε Q t) {x : M.carrier} (hx : ¬ Q x) :
    x < t ∨ t < x := by
  rcases lt_trichotomy x t with h | h | h
  · exact Or.inl h
  · exact absurd (h ▸ hS.mem) hx
  · exact Or.inr h

/-- **A bad interval has no first point** — printed p.180, Lemma 6's third clause read from
inside: the interiority witness `a` below `u` is joined to `u` by bad points, so saturation puts
it in `Q₀`. This is what makes *"`B` holds for a while into `Q₀`"* (forward case 2) a statement
about the start of an actual class of `Q₀`. -/
theorem exists_mem_lt (hS : IsBadIntervalSurgery M ε Q t) {u : M.carrier} (hu : Q u) :
    ∃ p : M.carrier, Q p ∧ p < u := by
  obtain ⟨a, b, hau, hub, hint⟩ := hS.interior u u hu hu
  refine ⟨a, ?_, hint.toR.left_lt⟩
  refine hS.isBad.saturated u a hu (fun r hr₁ hr₂ => IsBadPoint.of_right ?_)
  refine hint.toR.rThroughout r (le_trans (le_min hint.toR.left_lt.le le_rfl) hr₁) ?_
  exact le_trans hr₂ (max_le hub (le_trans hint.toR.left_lt.le hub))

/-- **A bad interval has no last point** — the mirror of `exists_mem_lt`. -/
theorem exists_mem_gt (hS : IsBadIntervalSurgery M ε Q t) {u : M.carrier} (hu : Q u) :
    ∃ p : M.carrier, Q p ∧ u < p := by
  obtain ⟨a, b, hau, hub, hint⟩ := hS.interior u u hu hu
  refine ⟨b, ?_, hint.toR.lt_right⟩
  refine hS.isBad.saturated u b hu (fun r hr₁ hr₂ => IsBadPoint.of_right ?_)
  refine hint.toR.rThroughout r ?_ (le_trans hr₂ (max_le hub le_rfl))
  exact le_trans (le_min hau (le_trans hau hub)) hr₁

/-! ### Lemma 7, re-indexed from a segment to the whole bad interval

Reynolds states Lemma 7 about *"a bad interval"*; the landed `reynolds_lemma7` family is stated
about a segment `[a, b]` straddling a class in the interior. The four re-indexings below are the
only bridge this module adds, and each is a single application of the corresponding landed half
at the segment supplied by `IsBadIntervalSurgery.interior`. No Prior axiom is applied outside
these four calls. -/

section Lemma7Wide

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Lemma 7, first statement, start half, over the whole bad interval** — printed pp.180-181:
*"If a formula `B` is true for a while at the start of a `∼`-class in a bad interval then it
holds throughout the bad interval."* -/
theorem lemma7_start_wide (hS : IsBadIntervalSurgery M ε Q t) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (B : Formula) {p : M.carrier} (hp : Q p)
    (hstart : ∃ x : M.carrier, ContempEquivDense M ε p x ∧
      ∀ q : M.carrier, ContempEquivDense M ε p q → q < x → TemporalTruth M atomMap q B)
    {u : M.carrier} (hu : Q u) : TemporalTruth M atomMap u B := by
  obtain ⟨a, b, hau, hub, hint⟩ := hS.interior p u hp hu
  exact reynolds_lemma7_start atomMap h_surj hε M h_prior_U h_prior_S B hint.toR hstart hau hub

/-- **Lemma 7, first statement, end half, over the whole bad interval** — printed pp.180-181:
*"Similarly at the end."* -/
theorem lemma7_end_wide (hS : IsBadIntervalSurgery M ε Q t) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (B : Formula) {p : M.carrier} (hp : Q p)
    (hend : ∃ x : M.carrier, ContempEquivDense M ε p x ∧
      ∀ q : M.carrier, ContempEquivDense M ε p q → x < q → TemporalTruth M atomMap q B)
    {u : M.carrier} (hu : Q u) : TemporalTruth M atomMap u B := by
  obtain ⟨a, b, hau, hub, hint⟩ := hS.interior p u hp hu
  exact reynolds_lemma7_end atomMap h_surj hε M h_prior_U h_prior_S B hint hend hau hub

/-- **Lemma 7, second statement, left half, over the whole bad interval** — printed p.181: *"If
a formula is true anywhere in a bad interval it is true arbitrarily close to each end of each
class in the interval."* -/
theorem lemma7_close_left_wide (hS : IsBadIntervalSurgery M ε Q t)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (A : Formula) {p : M.carrier} (hp : Q p)
    (hsome : ∃ w : M.carrier, Q w ∧ TemporalTruth M atomMap w A)
    {x : M.carrier} (hxc : ContempEquivDense M ε p x) :
    ∃ q : M.carrier, ContempEquivDense M ε p q ∧ q < x ∧ TemporalTruth M atomMap q A := by
  obtain ⟨w, hw, hAw⟩ := hsome
  obtain ⟨a, b, haw, hwb, hint⟩ := hS.interior p w hp hw
  exact reynolds_lemma7_close_to_left atomMap h_surj hε M h_prior_U h_prior_S A hint.toR
    ⟨w, haw, hwb, hAw⟩ x hxc

/-- **Lemma 7, second statement, right half, over the whole bad interval** — printed p.181, the
*"arbitrarily close to the end"* half that forward case 5 consumes by name. -/
theorem lemma7_close_right_wide (hS : IsBadIntervalSurgery M ε Q t)
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDense ε) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (A : Formula) {p : M.carrier} (hp : Q p)
    (hsome : ∃ w : M.carrier, Q w ∧ TemporalTruth M atomMap w A)
    {x : M.carrier} (hxc : ContempEquivDense M ε p x) :
    ∃ q : M.carrier, ContempEquivDense M ε p q ∧ x < q ∧ TemporalTruth M atomMap q A := by
  obtain ⟨w, hw, hAw⟩ := hsome
  obtain ⟨a, b, haw, hwb, hint⟩ := hS.interior p w hp hw
  exact reynolds_lemma7_close_to_right atomMap h_surj hε M h_prior_U h_prior_S A hint
    ⟨w, haw, hwb, hAw⟩ x hxc

end Lemma7Wide

end IsBadIntervalSurgery

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
