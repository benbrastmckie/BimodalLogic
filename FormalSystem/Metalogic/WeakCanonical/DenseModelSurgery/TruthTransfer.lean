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

/-! The structure class §6 is parameterized over, together with its dual-closure hypothesis; see
`IsContempEquivDenseOn` and `IsDualClosed` (`Defs.lean`, `Dual.lean`). `IsDualClosed` is carried at
file scope rather than per-declaration because the mirror halves of Lemmas 5-9 obtain their results
by running the unmirrored half at `dual M`, and every caller of those halves needs it too. At both
instantiations of `C` it is discharged by instance search, so no call site mentions it. -/
variable {C : OrderedMonadicStructure sig → Prop} [IsDualClosed C]

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

/-! ### The second closure condition on a structure class

`reynolds_lemma9` is the one place in §6 that projects the class-gated clauses at the **surgered**
structure — Reynolds' *"Clearly `q` is not in the class of `I` in `N`"*, printed p.182. So the
structure class has to be closed under the surgery, alongside `IsDualClosed` (`Dual.lean`).

The bundle for `ε` is quantified **inside** the field rather than fixed by an index. That is what
makes one `[IsSurgeryClosed C]` binder serve both `ε` and `dualize ε`: the mirror halves of
Theorem 4 run the unmirrored half at `(dual M, dualize ε)`, and an `ε`-indexed class would have
forced a second binder at every one of them. -/

/-- **`C` is closed under bad-interval surgery**, for every `ε` whose contemporaneous-equivalence
bundle holds on `C`. -/
class IsSurgeryClosed {sig : MonadicSignature} (C : OrderedMonadicStructure sig → Prop) : Prop where
  /-- Surgered structures stay in the class. -/
  out : ∀ (ε : MonadicFormula sig 2), IsContempEquivDenseOn ε C →
    ∀ (M : OrderedMonadicStructure sig) (Q : M.carrier → Prop) (t : M.carrier),
      C M → IsBadIntervalSurgery M ε Q t → C (surgeredStructure M ε Q t)

/-- The class of all structures is trivially surgery-closed. With `instIsDualClosedUnrestricted`
this is what makes every §6 result instantiate at Reynolds' unrestricted reading with no extra
argument — the class parameterization adds nothing to those signatures that instance search does
not discharge. -/
instance instIsSurgeryClosedUnrestricted {sig : MonadicSignature} :
    IsSurgeryClosed (UnrestrictedClass sig) :=
  ⟨fun _ _ _ _ _ _ _ => trivial⟩

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
theorem mem_of_contemp (hS : IsBadIntervalSurgery M ε Q t) (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
    {p q : M.carrier} (hp : Q p) (hpq : ContempEquivDense M ε p q) : Q q := by
  obtain ⟨a, b, _, _, hint⟩ := hS.interior p p hp hp
  have haq : a < q := lt_of_classMate hε M hint.toR.left_lt hint.toR.left_out hpq
  have hqb : q < b := classMate_lt hε M hint.toR.lt_right hint.toR.right_out hpq
  refine hS.isBad.saturated p q hp (fun r hr₁ hr₂ => IsBadPoint.of_right ?_)
  refine hint.toR.rThroughout r ?_ ?_
  · exact le_trans (le_min hint.toR.left_lt.le haq.le) hr₁
  · exact le_trans hr₂ (max_le hint.toR.lt_right.le hqb.le)

/-- **`I ⊆ Q₀`** at the designated class. -/
theorem mem_of_contemp_base (hS : IsBadIntervalSurgery M ε Q t) (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
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
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
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
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
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
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
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
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
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

/-! ## Lemma 8, the `U` cases

Printed pp.181-182. Seven cases forward and six backward, transcribed in the disjoint form
described in the module header: the position of `t` is fixed first, then the position of `s`.

Two of the seven forward cases and three of the six backward cases consume Lemma 7; the rest are
Reynolds' *"apply the induction hypothesis to `A` and `B` at `s` and at all points in between"*,
which is the shared helper immediately below. -/

section Lemma8

variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2} {Q : M.carrier → Prop}
  {t : M.carrier}

/-- **Reynolds' *"apply the induction hypothesis to `A` and `B` at `s` and at all points in
between"***, printed p.181 (forward cases 1 and 7) and p.182 (backward case 1 and 6).

The forward form: when the witness `s` itself survives the surgery, it is still a witness in `N`,
because every point of `N` strictly between `x` and `s` is a point of `M` strictly between them
and so is covered by the hypothesis. -/
theorem untl_forward_of_mem {atomMap : Formula → sig.preds} {A B : Formula}
    {x : (surgeredStructure M ε Q t).carrier} {s : M.carrier}
    (hsD : SurgeryDomain M ε Q t s)
    (ihA : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val A ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y A)
    (ihB : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val B ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y B)
    (hxs : x.val < s) (hA : TemporalTruth M atomMap s A)
    (hB : ∀ r : M.carrier, x.val < r → r < s → TemporalTruth M atomMap r B) :
    TemporalTruth (surgeredStructure M ε Q t) atomMap x (.untl B A) :=
  ⟨⟨s, hsD⟩, hxs, (ihA ⟨s, hsD⟩).mp hA, fun r hxr hrs => (ihB r).mp (hB r.val hxr hrs)⟩

/-- The backward form of the same step: when no point of `M` strictly between `x` and the `N`
witness `s` has been removed by the surgery, the `N` witness is already an `M` witness. -/
theorem untl_backward_of_between {atomMap : Formula → sig.preds} {A B : Formula}
    {x s : (surgeredStructure M ε Q t).carrier}
    (ihA : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val A ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y A)
    (ihB : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val B ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y B)
    (hxs : x.val < s.val) (hA : TemporalTruth (surgeredStructure M ε Q t) atomMap s A)
    (hB : ∀ r : (surgeredStructure M ε Q t).carrier, x < r → r < s →
      TemporalTruth (surgeredStructure M ε Q t) atomMap r B)
    (hbetween : ∀ r : M.carrier, x.val < r → r < s.val → SurgeryDomain M ε Q t r) :
    TemporalTruth M atomMap x.val (.untl B A) :=
  ⟨s.val, hxs, (ihA s).mpr hA, fun r hxr hrs =>
    (ihB ⟨r, hbetween r hxr hrs⟩).mpr (hB ⟨r, hbetween r hxr hrs⟩ hxr hrs)⟩

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds 1992, §6 Lemma 8, printed p.181 — the `U` case, forward direction.**

> `(⇒)`: Consider then when `M ⊨ U(A,B)(t)` with `t ∈ N`. … There are several cases.

All seven printed cases, in the disjoint ordering fixed in the module header. Cases 2 and 5 are
the ones that consume Lemma 7; Reynolds also names Lemma 7 in case 3, where in this rendering
his remark that *"`B` holds throughout `I`"* is the observation that `I` lies inside the open
interval `(t, s)`, so the hypothesis already covers it and no appeal is needed. -/
theorem reynolds_lemma8_untl_forward (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hS : IsBadIntervalSurgery M ε Q t) (A B : Formula)
    (ihA : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val A ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y A)
    (ihB : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val B ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y B)
    (x : (surgeredStructure M ε Q t).carrier)
    (h : TemporalTruth M atomMap x.val (.untl B A)) :
    TemporalTruth (surgeredStructure M ε Q t) atomMap x (.untl B A) := by
  obtain ⟨s, hxs, hA, hB⟩ := h
  rcases x.property with hxQ | hxI
  · -- `t ∉ Q₀`: either `t ∈ Q⁻` or `t ∈ Q⁺`.
    rcases hS.lt_or_gt_of_not_mem hxQ with hxt | htx
    · -- `t ∈ Q⁻`.
      by_cases hsQ : Q s
      · -- **Forward case 2**: `t ∈ Q⁻` and `s ∈ Q₀`.
        -- *"`B` holds for a while into `Q₀` so, by lemma 7, holds everywhere in `Q₀`."*
        obtain ⟨p, hp, hps⟩ := hS.exists_mem_lt hsQ
        have hBQ : ∀ u : M.carrier, Q u → TemporalTruth M atomMap u B := by
          intro u hu
          refine hS.lemma7_start_wide atomMap h_surj hε h_prior_U h_prior_S B hp
            ⟨p, contemp_refl hε M p, ?_⟩ hu
          intro q hq hqp
          exact hB q (hS.lt_of_before hxQ hxt (hS.mem_of_contemp hε hp hq)) (lt_trans hqp hps)
        -- *"`A` holds somewhere in `Q₀` so somewhere in `I` (by lemma 7)."*
        obtain ⟨q, hqc, _, hAq⟩ := hS.lemma7_close_right_wide atomMap h_surj hε h_prior_U
          h_prior_S A hS.mem ⟨s, hsQ, hA⟩ (contemp_refl hε M t)
        have hqQ : Q q := hS.mem_of_contemp_base hε hqc
        refine ⟨⟨q, Or.inr hqc⟩, hS.lt_of_before hxQ hxt hqQ, (ihA _).mp hAq, ?_⟩
        intro r hxr hrq
        refine (ihB r).mp ?_
        rcases r.property with hrQ | hrI
        · -- `r` survives outside `Q₀` and lies below `q ∈ Q₀`, so `r ∈ Q⁻`.
          have hrt : r.val < t := by
            rcases hS.lt_or_gt_of_not_mem hrQ with hr | hr
            · exact hr
            · exact absurd (hS.lt_of_after hrQ hr hqQ) (not_lt.mpr (le_of_lt hrq))
          exact hB r.val hxr (hS.lt_of_before hrQ hrt hsQ)
        · exact hBQ r.val (hS.mem_of_contemp_base hε hrI)
      · -- **Forward cases 1 and 3**: `s ∉ Q₀`, so `s` survives and is its own witness.
        exact untl_forward_of_mem (Or.inl hsQ) ihA ihB hxs hA hB
    · -- **Forward case 7**: `t ∈ Q⁺`, so everything above `t` is also in `Q⁺`.
      have hsQ : ¬ Q s := fun hq => absurd (hS.lt_of_after hxQ htx hq) (not_lt.mpr (le_of_lt hxs))
      exact untl_forward_of_mem (Or.inl hsQ) ihA ihB hxs hA hB
  · -- `t ∈ I`.
    by_cases hsQ : Q s
    · by_cases hsI : ContempEquivDense M ε t s
      · -- **Forward case 4**: `t < s ∈ I`.
        exact untl_forward_of_mem (Or.inr hsI) ihA ihB hxs hA hB
      · -- **Forward case 5**: `t ∈ I` and `s` later in `Q₀`.
        -- `s` lies above the whole of `I`: a point of `Q₀` between two class-mates is a
        -- class-mate.
        have hIs : ∀ y : M.carrier, ContempEquivDense M ε t y → y < s := by
          intro y hy
          by_contra hcon
          push_neg at hcon
          exact hsI (contemp_trans hε M hxI
            (contemp_of_between hε M (le_of_lt hxs) hcon
              (contemp_trans hε M (contemp_symm hε M hxI) hy)))
        -- *"Again by lemma 7 we have `B` true throughout `I` in `M` and so in `N`."*
        have hBQ : ∀ u : M.carrier, Q u → TemporalTruth M atomMap u B := by
          intro u hu
          refine hS.lemma7_end_wide atomMap h_surj hε h_prior_U h_prior_S B hS.mem
            ⟨x.val, hxI, ?_⟩ hu
          intro q hq hxq
          exact hB q hxq (hIs q hq)
        -- *"lemma 7 tells us that `A` is true arbitrarily close to the end of `I`."*
        obtain ⟨q, hqc, hxq, hAq⟩ := hS.lemma7_close_right_wide atomMap h_surj hε h_prior_U
          h_prior_S A hS.mem ⟨s, hsQ, hA⟩ hxI
        refine ⟨⟨q, Or.inr hqc⟩, hxq, (ihA _).mp hAq, ?_⟩
        intro r hxr hrq
        refine (ihB r).mp (hBQ r.val (hS.mem_of_contemp_base hε ?_))
        -- `r` lies between two class-mates of `t`, hence is one.
        exact contemp_trans hε M hxI
          (contemp_of_between hε M (le_of_lt hxr) (le_of_lt hrq)
            (contemp_trans hε M (contemp_symm hε M hxI) hqc))
    · -- **Forward case 6**: `t ∈ I` and `s ∈ Q⁺`.
      exact untl_forward_of_mem (Or.inl hsQ) ihA ihB hxs hA hB

/-- **Reynolds 1992, §6 Lemma 8, printed p.182 — the `U` case, backward direction.**

> `(⇐)`: Consider then when `N ⊨ U(A,B)(t)`. … Again there are several cases.

All six printed cases. One fewer than the forward direction because `N` has no `Q₀ \ I` for `s`
to land in. Cases 2, 3 and 5 consume Lemma 7 to recover `B` at the points the surgery removed —
the only points where the `N` witness could fail to be an `M` witness. -/
theorem reynolds_lemma8_untl_backward (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hS : IsBadIntervalSurgery M ε Q t) (A B : Formula)
    (ihA : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val A ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y A)
    (ihB : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val B ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y B)
    (x : (surgeredStructure M ε Q t).carrier)
    (h : TemporalTruth (surgeredStructure M ε Q t) atomMap x (.untl B A)) :
    TemporalTruth M atomMap x.val (.untl B A) := by
  obtain ⟨s, hxs, hA, hB⟩ := h
  -- The `M`-points strictly between `x` and `s` that the surgery removed are exactly the points
  -- of `Q₀ \ I` there; every case below either shows there are none, or supplies `B` at all of
  -- `Q₀` by Lemma 7.
  have key : (∀ r : M.carrier, x.val < r → r < s.val → Q r → TemporalTruth M atomMap r B) →
      TemporalTruth M atomMap x.val (.untl B A) := by
    intro hQB
    refine ⟨s.val, hxs, (ihA s).mpr hA, ?_⟩
    intro r hxr hrs
    by_cases hrQ : Q r
    · exact hQB r hxr hrs hrQ
    · exact (ihB ⟨r, Or.inl hrQ⟩).mpr (hB ⟨r, Or.inl hrQ⟩ hxr hrs)
  rcases x.property with hxQ | hxI
  · rcases hS.lt_or_gt_of_not_mem hxQ with hxt | htx
    · -- `t ∈ Q⁻`.
      rcases s.property with hsQ | hsI
      · -- **Backward cases 1 and 3**: `s ∈ Q⁻` or `s ∈ Q⁺`.
        rcases hS.lt_or_gt_of_not_mem hsQ with hst | hts
        · -- **Backward case 1**: `s ∈ Q⁻`; nothing between was removed.
          refine key (fun r hxr hrs hrQ => absurd (hS.lt_of_before hsQ hst hrQ) ?_)
          exact not_lt.mpr (le_of_lt hrs)
        · -- **Backward case 3**: `t ∈ Q⁻` and `s ∈ Q⁺`.
          -- *"`B` holds throughout `I` in `N` and so in `M`. Lemma 7 tells us `B` holds
          -- throughout `Q₀` in `M`."*
          refine key (fun r _ _ hrQ => ?_)
          refine hS.lemma7_start_wide atomMap h_surj hε h_prior_U h_prior_S B hS.mem
            ⟨t, contemp_refl hε M t, ?_⟩ hrQ
          intro q hq _
          have hqQ : Q q := hS.mem_of_contemp_base hε hq
          exact (ihB ⟨q, Or.inr hq⟩).mpr
            (hB ⟨q, Or.inr hq⟩ (hS.lt_of_before hxQ hxt hqQ) (hS.lt_of_after hsQ hts hqQ))
      · -- **Backward case 2**: `t ∈ Q⁻` and `s ∈ I`.
        -- *"`B` holds at the beginning of `I` in `N` and so in `M`. By lemma 7 `B` holds
        -- throughout `Q₀`."*
        refine key (fun r _ _ hrQ => ?_)
        refine hS.lemma7_start_wide atomMap h_surj hε h_prior_U h_prior_S B hS.mem
          ⟨s.val, hsI, ?_⟩ hrQ
        intro q hq hqs
        exact (ihB ⟨q, Or.inr hq⟩).mpr
          (hB ⟨q, Or.inr hq⟩ (hS.lt_of_before hxQ hxt (hS.mem_of_contemp_base hε hq)) hqs)
    · -- **Backward case 6**: `t ∈ Q⁺`; nothing between was removed.
      exact key (fun r hxr _ hrQ =>
        absurd (hS.lt_of_after hxQ htx hrQ) (not_lt.mpr (le_of_lt hxr)))
  · rcases s.property with hsQ | hsI
    · -- **Backward case 5**: `t ∈ I` and `s ∈ Q⁺`.
      -- *"`B` is true throughout `I` and we have our result."*
      have hts : t < s.val := hS.lt_of_after hsQ
        (by rcases hS.lt_or_gt_of_not_mem hsQ with h | h
            · exact absurd (hS.lt_of_before hsQ h (hS.mem_of_contemp_base hε hxI))
                (not_lt.mpr (le_of_lt hxs))
            · exact h) hS.mem
      refine key (fun r _ _ hrQ => ?_)
      refine hS.lemma7_end_wide atomMap h_surj hε h_prior_U h_prior_S B hS.mem
        ⟨x.val, hxI, ?_⟩ hrQ
      intro q hq hxq
      exact (ihB ⟨q, Or.inr hq⟩).mpr
        (hB ⟨q, Or.inr hq⟩ hxq (hS.lt_of_after hsQ hts (hS.mem_of_contemp_base hε hq)))
    · -- **Backward case 4**: `t < s ∈ I`; every point between two class-mates is a class-mate,
      -- so nothing between was removed.
      refine key (fun r hxr hrs _ => ?_)
      have hrI : ContempEquivDense M ε t r :=
        contemp_trans hε M hxI (contemp_of_between hε M (le_of_lt hxr) (le_of_lt hrs)
          (contemp_trans hε M (contemp_symm hε M hxI) hsI))
      exact (ihB ⟨r, Or.inr hrI⟩).mpr (hB ⟨r, Or.inr hrI⟩ hxr hrs)

end Lemma8

/-! ## *"`S(A,B)` is similar"*

Printed p.181, the single sentence with which Reynolds discharges the `S` half of Lemma 8's
induction. Following `Dual.lean`'s standing policy — *"no later phase should derive a third
mirror by hand when an instantiation at `(dual M, dualize ε)` will do"* — the `S` cases are
**not** re-transcribed. They are the `U` cases run at the order-dual, transported back along
`temporalTruth_dual'` and a structure isomorphism.

Two bridges are new here and are the whole cost of the mirror:

* `temporalTruth_iso` — `Dual.lean` proved `eval` invariant along a `StructIso` but never lifted
  that to `TemporalTruth`. The lift is `table_correctness` on both sides of `eval_iso`.
* `surgeredDualIso` — the surgered structure commutes with the dual only up to the rewriting of
  its domain predicate by `contempEquivDense_dual`, exactly as `subintervalDualIso` handles the
  subinterval's conjunct exchange. Same points, same order, same interpretations.

Nothing in `Dual.lean` or `BadIntervals.lean` is removed, renamed or weakened by any of this. -/

section Mirror

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **`TemporalTruth` is invariant along a structure isomorphism.**

`eval_iso` (`Dual.lean:351`) with `table_correctness` (`Table.lean:254`) on both sides. This is
the lemma `Dual.lean` stopped one step short of; it is stated for an arbitrary `StructIso`, so it
is reusable for any later carrier transport. -/
theorem temporalTruth_iso {M N : OrderedMonadicStructure sig} (e : StructIso M N)
    (atomMap : Formula → sig.preds) (x : M.carrier) (A : Formula) :
    TemporalTruth N atomMap (e.toEquiv x) A ↔ TemporalTruth M atomMap x A := by
  rw [← table_correctness N atomMap (e.toEquiv x) A, ← table_correctness M atomMap x A]
  exact eval_iso e (fun _ : Fin 1 => x) (table sig atomMap A)

variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2} {Q : M.carrier → Prop}
  {t : M.carrier}

/-- **The surgered structure commutes with the dual**, up to the rewriting of its domain
predicate: the two structures have literally the same points, order and interpretations, and
their `Subtype` predicates differ only in `ContempEquivDense (dual M) (dualize ε)` versus
`ContempEquivDense M ε`, which `contempEquivDense_dual` identifies. -/
def surgeredDualEquiv (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier) :
    (dual (surgeredStructure M ε Q t)).carrier ≃
      (surgeredStructure (dual M) (dualize ε) Q (d t)).carrier where
  toFun x := ⟨d x.val, x.property.imp id fun h => (contempEquivDense_dual ε t x.val).mpr h⟩
  invFun x := ⟨x.val, x.property.imp id fun h => (contempEquivDense_dual ε t x.val).mp h⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- **The commutation is a structure isomorphism**, on the model of `subintervalDualIso`
(`Dual.lean:444`): both order and interpretation are preserved definitionally. -/
def surgeredDualIso (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) (t : M.carrier) :
    StructIso (dual (surgeredStructure M ε Q t))
      (surgeredStructure (dual M) (dualize ε) Q (d t)) where
  toEquiv := surgeredDualEquiv M ε Q t
  map_lt _ _ := Iff.rfl
  map_interp _ _ := Iff.rfl

/-- **Bad points are bad points in the dual**, with `R` and `L` exchanged — printed p.179's
*"`R ∨ L`"* is symmetric in its two disjuncts, which is why the notion survives duality
unchanged. -/
theorem isBadPoint_dual (ε : MonadicFormula sig 2) (u : M.carrier) :
    IsBadPoint (dual M) (dualize ε) (d u) ↔ IsBadPoint M ε u :=
  (or_congr (endsInGapOnRight_dual (M := M) ε u) (endsInGapOnLeft_dual (M := M) ε u)).trans
    Or.comm

/-- **The interiority package transports**, with the two bounds exchanged.

`ClassInteriorToBadInterval` asks for `R` *and* `L` throughout, so it is symmetric under the
exchange: the dual's `R` half is the original's `L` half and conversely. -/
theorem classInteriorToBadInterval_dual {a p b : M.carrier}
    (h : ClassInteriorToBadInterval M ε a p b) :
    ClassInteriorToBadInterval (dual M) (dualize ε) (d b) (d p) (d a) where
  toR :=
    { left_lt := h.toR.lt_right
      lt_right := h.toR.left_lt
      left_out := fun hc => h.toR.right_out ((contempEquivDense_dual (M := M) ε p b).mp hc)
      right_out := fun hc => h.toR.left_out ((contempEquivDense_dual (M := M) ε p a).mp hc)
      rThroughout := fun q h₁ h₂ =>
        (endsInGapOnRight_dual (M := M) ε q).mpr (h.lThroughout q h₂ h₁) }
  lThroughout := fun q h₁ h₂ =>
    (endsInGapOnLeft_dual (M := M) ε q).mpr (h.toR.rThroughout q h₂ h₁)

/-- **The surgery set-up transports to the dual.**

Every clause is its own mirror: *"non-empty"* is unchanged, *"`R ∨ L` throughout"* is
`isBadPoint_dual`, *"interval"* and *"maximal"* reverse their two bounds, and the interiority
witnesses exchange. -/
theorem isBadIntervalSurgery_dual (hS : IsBadIntervalSurgery M ε Q t) :
    IsBadIntervalSurgery (dual M) (dualize ε) Q (d t) where
  isBad :=
    { nonempty := hS.isBad.nonempty
      bad := fun u hu => (isBadPoint_dual (M := M) ε u).mpr (hS.isBad.bad u hu)
      convex := fun a b c hab hbc ha hc => hS.isBad.convex c b a hbc hab hc ha
      saturated := fun a u ha hbad =>
        hS.isBad.saturated a u ha fun q h₁ h₂ =>
          (isBadPoint_dual (M := M) ε q).mp (hbad q h₂ h₁) }
  mem := hS.mem
  interior := fun p u hp hu => by
    obtain ⟨a, b, hau, hub, hint⟩ := hS.interior p u hp hu
    exact ⟨d b, d a, hub, hau, classInteriorToBadInterval_dual hint⟩

/-- **The induction hypotheses transport across the mirror.**

An `N`-versus-`M` agreement at `C` becomes an `N'`-versus-`dual M` agreement at `swapUS C`, where
`N'` is the surgered dual. Both sides move at once: the base side by `temporalTruth_dual'`, the
surgered side by `temporalTruth_dual'` followed by `temporalTruth_iso`. -/
theorem snce_mirror_ih (atomMap : Formula → sig.preds) {C : Formula}
    (ih : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val C ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y C) :
    ∀ y : (surgeredStructure (dual M) (dualize ε) Q (d t)).carrier,
      TemporalTruth (dual M) atomMap y.val (swapUS C) ↔
        TemporalTruth (surgeredStructure (dual M) (dualize ε) Q (d t)) atomMap y (swapUS C) := by
  intro y
  obtain ⟨y₀, rfl⟩ := (surgeredDualEquiv M ε Q t).surjective y
  exact ((temporalTruth_dual' (M := M) atomMap y₀.val C).trans (ih y₀)).trans
    ((temporalTruth_dual' (M := surgeredStructure M ε Q t) atomMap y₀ C).symm.trans
      (temporalTruth_iso (surgeredDualIso M ε Q t) atomMap y₀ (swapUS C)).symm)

/-- **Reynolds 1992, §6 Lemma 8, printed p.181 — the `S` case, forward direction.**

> Now consider `U(A,B)`: `S(A,B)` is similar.

Obtained by instantiating `reynolds_lemma8_untl_forward` at `(dual M, dualize ε)`. -/
theorem reynolds_lemma8_snce_forward (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hS : IsBadIntervalSurgery M ε Q t) (A B : Formula)
    (ihA : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val A ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y A)
    (ihB : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val B ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y B)
    (x : (surgeredStructure M ε Q t).carrier)
    (h : TemporalTruth M atomMap x.val (.snce B A)) :
    TemporalTruth (surgeredStructure M ε Q t) atomMap x (.snce B A) := by
  refine (temporalTruth_dual' (M := surgeredStructure M ε Q t) atomMap x (.snce B A)).mp ?_
  refine (temporalTruth_iso (surgeredDualIso M ε Q t) atomMap (d x)
    (swapUS (.snce B A))).mp ?_
  exact reynolds_lemma8_untl_forward atomMap h_surj (isContempEquivDense_dualize hε)
    (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U)
    (isBadIntervalSurgery_dual hS) (swapUS A) (swapUS B)
    (snce_mirror_ih atomMap ihA) (snce_mirror_ih atomMap ihB)
    ((surgeredDualIso M ε Q t).toEquiv (d x))
    ((temporalTruth_dual' (M := M) atomMap x.val (.snce B A)).mpr h)

/-- **Reynolds 1992, §6 Lemma 8, printed p.182 — the `S` case, backward direction.**

The instantiation of `reynolds_lemma8_untl_backward` at `(dual M, dualize ε)`. -/
theorem reynolds_lemma8_snce_backward (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hS : IsBadIntervalSurgery M ε Q t) (A B : Formula)
    (ihA : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val A ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y A)
    (ihB : ∀ y : (surgeredStructure M ε Q t).carrier,
      TemporalTruth M atomMap y.val B ↔ TemporalTruth (surgeredStructure M ε Q t) atomMap y B)
    (x : (surgeredStructure M ε Q t).carrier)
    (h : TemporalTruth (surgeredStructure M ε Q t) atomMap x (.snce B A)) :
    TemporalTruth M atomMap x.val (.snce B A) := by
  refine (temporalTruth_dual' (M := M) atomMap x.val (.snce B A)).mp ?_
  refine reynolds_lemma8_untl_backward atomMap h_surj (isContempEquivDense_dualize hε)
    (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U)
    (isBadIntervalSurgery_dual hS) (swapUS A) (swapUS B)
    (snce_mirror_ih atomMap ihA) (snce_mirror_ih atomMap ihB)
    ((surgeredDualIso M ε Q t).toEquiv (d x)) ?_
  exact (temporalTruth_iso (surgeredDualIso M ε Q t) atomMap (d x) (swapUS (.snce B A))).mpr
    ((temporalTruth_dual' (M := surgeredStructure M ε Q t) atomMap x (.snce B A)).mpr h)

/-! ## Lemma 8

*"We proceed by induction on the construction of `A`. The cases of atomic and boolean `A` are
immediate."* — printed p.181.

*Immediate* is exact here: `surgeredStructure` inherits `M.interp p x.val` definitionally, so the
`atom` and `box` cases are `Iff.rfl`, as is `bot`; `imp` is a congruence. `box` is atomic in this
reading because `TemporalTruth` sends a box-subformula to `atomMap (.box φ)` rather than
recursing — the same reason `swapUS` leaves `.box` opaque. -/

/-- **Reynolds 1992, §6 Lemma 8, printed pp.181-182.**

> **LEMMA 8** *For all temporal formulas `A`, for all `t ∈ N`,*
>
> `M ⊨ A(t)` *iff* `N ⊨ A(t)`

`N` is `M` with a whole bad interval `Q₀` replaced by one of its `∼`-classes `I`.

**Conditional**, as every §6 result below Lemma 2 is: `IsContempEquivDense ε` and semantic
Prior-U / Prior-S are hypotheses, and this tree can exhibit no non-trivial `ε` satisfying them
until the anti-vacuity instance lands with Lemma 9 and Theorem 4. This lemma is therefore not
discharged in the unconditional sense, and must not be described as such. -/
theorem reynolds_lemma8 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (hS : IsBadIntervalSurgery M ε Q t) :
    ∀ (A : Formula) (x : (surgeredStructure M ε Q t).carrier),
      TemporalTruth M atomMap x.val A ↔
        TemporalTruth (surgeredStructure M ε Q t) atomMap x A := by
  intro A
  induction A with
  | atom _ => exact fun _ => Iff.rfl
  | bot => exact fun _ => Iff.rfl
  | box _ => exact fun _ => Iff.rfl
  | imp φ ψ ihφ ihψ => exact fun x => imp_congr (ihφ x) (ihψ x)
  | untl ψ φ ihψ ihφ =>
      exact fun x =>
        ⟨reynolds_lemma8_untl_forward atomMap h_surj hε h_prior_U h_prior_S hS φ ψ ihφ ihψ x,
          reynolds_lemma8_untl_backward atomMap h_surj hε h_prior_U h_prior_S hS φ ψ ihφ ihψ x⟩
  | snce ψ φ ihψ ihφ =>
      exact fun x =>
        ⟨reynolds_lemma8_snce_forward atomMap h_surj hε h_prior_U h_prior_S hS φ ψ ihφ ihψ x,
          reynolds_lemma8_snce_backward atomMap h_surj hε h_prior_U h_prior_S hS φ ψ ihφ ihψ x⟩

end Mirror

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
