/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Lemma5

/-!
# Reynolds §6 Lemmas 6 and 7: bad points and bad intervals

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§6 *"No gaps between equivalence classes"*, printed **pp.179-181**.

This module continues `Lemma5.lean` with the *bad point* / *bad interval* vocabulary and with
Lemmas 6 and 7.

## The source, verbatim

Printed **p.179**, last paragraph — the definition:

> We define a *bad* point to be where `R ∨ L` holds. We define a *bad* interval as a non-empty
> and maximal one in which `R ∨ L` holds throughout.

Printed **p.180**, **Lemma 6**:

> **LEMMA 6** *Bad points only occur in non-singleton bad intervals.*
>
> *In any bad interval both `R` and `L` hold throughout. Any bad interval, if bounded, has
> excluded end points in `M` (neither `R` nor `L` holds at these end points).*
>
> **PROOF.** We first show that `L` holds wherever `R` does. Suppose for contradiction that we
> have a maximal interval of `R` in which `L` fails to hold somewhere. So `¬L` holds throughout
> at least one `∼`-class. By the definition of `L`, there are two cases. Either this particular
> `∼`-class is one which includes its left hand end point or it is one which begins just after
> some point of `M`. The class can not be unbounded below for then it would be first in this bad
> interval.
>
> In fact we can not have a class beginning just after a point `r` of `M`. Since the class can
> not be first in the bad interval `r` itself must be in a `∼`-class in the bad interval. But
> `r`'s class can not end in a gap on the right when `r` must be its right hand end point.
>
> Thus we have a class in the bad interval which includes its left hand end point. Its not hard
> to use the previous result to show that throughout the bad interval all classes include their
> left hand end points.
>
> Let `B` be a temporal formula true at times which are not left hand end points of their
> `∼`-classes. `B` is then true continuously in any class from just after the left hand end point
> up until the gap at the right hand end point. `B` must be false arbitrarily soon after the gap
> contradicting Prior-U.
>
> Using mirror images of the above and previous results we get our proof. ∎

Printed **pp.180-181**, **Lemma 7**:

> **LEMMA 7** *If a formula `B` is true for a while at the start of a `∼`-class in a bad interval
> then it holds throughout the bad interval. Similarly at the end.*
>
> *If a formula is true anywhere in a bad interval it is true arbitrarily close to each end of
> each class in the interval.*
>
> **PROOF.** Suppose that `γ < δ` are gaps and that `(γ, δ)` is a `∼`-class within a bad interval.
>
> Suppose that `B` holds for a while after `γ` but that `¬B` holds somewhere in the bad interval.
> By lemma 5, `¬B` also holds somewhere in `(γ, δ)`.
>
> Using `ε` and expressive completeness we can find a temporal formula `C` which is true only at
> points within a `∼`-class after some `¬B` in that class. `C` will be false for a while at the
> beginning of each class and then true for a while at the end.
>
> In fact `C` is true for a while up to the gap at the end and false arbitrarily soon after the
> gap. This contradicts Prior-U.
>
> Applying the above to the negation of a formula gives us the second part. ∎

## Proof-step → name map

Reynolds' proof steps, in printed order, against the declarations below.

| Printed step (p.179-181) | Declaration |
| --- | --- |
| *"a bad point … where `R ∨ L` holds"* | `IsBadPoint`, `badPointFormula` (+ `_spec`) |
| *"a bad interval … non-empty and maximal one in which `R ∨ L` holds throughout"* | `IsBadInterval` (+ `IsBadInterval.maximal_among`) |
| *"a temporal formula true at times which are not left hand end points of their `∼`-classes"* | `notLeftEndFormula` / `NotLeftEnd` / `notLeftEndTemporal` (+ `_eval`, `_spec`) |
| *"we can not have a class beginning just after a point `r` of `M`"* | `not_endsInGapOnRight_of_immediatePredecessor` |
| *"throughout the bad interval all classes include their left hand end points"* | `exists_leftEnd_throughout` (via `reynolds_lemma5_first`) |
| *"`B` is true continuously in any class … `B` must be false arbitrarily soon after the gap contradicting Prior-U"* | `false_of_allClassesHaveLeftEnd` |
| *"`L` holds wherever `R` does"* | `endsInGapOnLeft_of_endsInGapOnRight` |
| *"Bad points only occur in non-singleton bad intervals"* | `reynolds_lemma6_nonsingleton` |
| *"a temporal formula `C` which is true only at points within a `∼`-class after some `¬B` in that class"* | `afterNotHoldsInClassFormula` / `AfterNotHoldsInClass` / `afterNotHoldsInClassTemporal` (+ `_eval`, `_spec`) |
| *"`C` is true for a while up to the gap at the end and false arbitrarily soon after the gap. This contradicts Prior-U"* | `false_of_holds_throughout_class_from_bounded` |
| *"`C` will be false for a while at the beginning of each class"* | `exists_notAfterNotHolds_in_class` (via `reynolds_lemma5_first`) |
| Lemma 7, first statement | `reynolds_lemma7_start` |
| Lemma 7, second statement | `reynolds_lemma7_dense` |
| both statements assembled | `reynolds_lemma7` |

## PAGE MAP — the plan's page references run one to two pages early

Measured against the page images of
`Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`. The printed page number is the PDF
page number (1-based) plus 164 throughout §6.

| Material | PDF page (1-based) | Printed page | Plan v8 says |
| --- | --- | --- | --- |
| `ρ`, Lemma 2 | 13 | 177 | 177 ✓ |
| Lemma 3, Lemma 4 statement | 14 | 178 | 177 ✗ |
| Lemma 4 proof, Lemma 5, *bad point* / *bad interval* | 15 | 179 | 178 ✗ |
| Lemma 6, Lemma 7 statement + proof opening | 16 | 180 | 178-179 ✗ |
| Lemma 7 proof close, surgery set-up, Lemma 8 | 17 | 181 | 179 ✗ |

So Phase 20's material is on printed **pp.179-181**, not pp.178-179. Docstrings below use the
measured pages. This extends the drift Phases 18 and 19 recorded.

## CORPUS CHECK — no third defect; the §6 display warning is unchanged

The two §6 corpus defects recorded so far (`ρ`'s missing middle conjunct, under `Defs.lean`;
Lemma 4's mangled display, under `Lemma34.lean`) both sit at **displayed** formulas. Lemmas 6
and 7, and the *bad point* / *bad interval* definition, contain **no displayed formula at all** —
they are pure running prose. Every sentence block-quoted above was read off the page images and
agrees with
`~/Projects/Literature/sources/reynolds_1992/sec03_6-no-gaps-between-equivalence-classes.md`
word for word, with one printer's typo preserved here and normalised there (*"Its not hard"* on
the page; the corpus writes *"It's not hard"*). The §6 defect count therefore stands at **two**,
and the standing warning continues to apply to displays specifically.

## WHICH GAP-CROSSING LEMMA LEMMA 7 LICENSES — neither of the two already landed

The standing instruction was to determine which of the two landed forms Lemma 7 consumes before
using either. The answer is **neither**, and the reason is visible in Reynolds' own sentence
*"`C` will be false for a while at the beginning of each class and then true for a while at the
end"*.

* `false_of_holds_throughout_class` (`Lemma34.lean:595`, Phase 18) requires the auxiliary formula
  to hold **throughout** `s`'s class and to fail at **every** later point outside it. Reynolds'
  `C` fails both halves: it is false at the beginning of `s`'s own class, and it is true again
  near the end of every later class in the interval.
* `false_of_holds_throughout_class_bounded` (`Lemma5.lean:400`, Phase 19) weakens only the second
  half. Its `hin` still demands `C` throughout the class, which `C` does not satisfy.

`false_of_holds_throughout_class_from_bounded` below weakens **both** slots, and is the form
Lemma 7 actually licenses:

* `hin` is required only from `s` **onwards** inside the class — which is exactly *"true for a
  while at the end"*, since `C` is upward closed in a class;
* `hout` asks only that `C` be false **arbitrarily soon** after the gap (some failure point at or
  below each given point beyond the class), which is Reynolds' *"false arbitrarily soon after the
  gap"* read literally rather than as *"false everywhere after the gap"*.

Both earlier forms are left in place, unweakened and unrenamed; nothing that consumes them
changes. The new theorem is proved from scratch rather than by generalising either in place.

## Renderings that are this tree's, not Reynolds' words

* *"a maximal interval of `R`"* containing a whole class in its interior is rendered as
  `ClassInteriorToRInterval M ε a t b`: two points `a < t < b` outside `t`'s class with `R`
  holding throughout `[a, b]`. Reynolds obtains exactly this from Lemma 4 (*"There is no last
  class and no first class in any maximal interval of `R`"*), which supplies a class below and a
  class above; convexity of a maximal interval supplies `R` in between.
* *"non-empty and maximal one in which `R ∨ L` holds throughout"* is rendered as `IsBadInterval`,
  whose maximality clause is stated in **saturation** form — any point joined to a member by a
  stretch of bad points is itself a member. `IsBadInterval.maximal_among` derives the
  maximal-among-bad-intervals reading from it, so the rendering is checked rather than asserted.
* *"the class includes its left hand end point"* is rendered as the existence of a class-mate `w`
  with no class-mate strictly below it, matching the `¬ v < w` idiom `ClassBeginsWith`
  (`Lemma5.lean:278`) and `ClassBeginsAtGapStart` (`Lemma34.lean:434`) already use.

## Honest caveat, carried forward

Every §6 lemma below Lemma 2 remains **conditional**. `IsContempEquivDense ε` together with
Reynolds' Prior-U and Prior-S on `M` are hypotheses throughout, and the only `ε` this tree can
currently exhibit satisfying them is the total relation `epsTop` (`Defs.lean:461`), for which
`EndsInGapOnRight` is empty (`not_endsInGapOnRight_epsTop`). Nothing below is discharged at a
non-trivial instance; the first live instance is due at the Lemma 9 / dense-surgery stage. These
results are **not** to be described as discharged.

## References

- Reynolds 1992, §6 Lemmas 6 and 7, printed pp.179-181
- `Defs.lean` — `ρ`, `λ`, `EndsInGapOnRight`, `EndsInGapOnLeft`, `gapRightFormula`,
  `gapLeftFormula`, Lemma 2
- `Lemma34.lean` — Lemmas 3 and 4, the class calculus, `false_of_holds_throughout_class`
- `Lemma5.lean` — Lemma 5, `false_of_holds_throughout_class_bounded`, `exists_bound_notHolds`,
  `temporalToMonadic`, `relativizeAt`
- `SemanticPriorU` (`PriorDefsDense.lean:119`) — Reynolds' Prior-U, printed p.168
-/

namespace FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

open FormalSystem.Syntax FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! ## Environment lookups

`Lemma5.lean`'s lookups are `private` to that module, so the two this module's transcriptions
need are restated here rather than exported from there — zero changes to `Lemma5.lean`. -/

section EnvLookup

variable {α : Type*}

private theorem b2_one (x t : α) : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → α) 1 = t := rfl

end EnvLookup

/-! ## Bad points and bad intervals

*"We define a bad point to be where `R ∨ L` holds. We define a bad interval as a non-empty and
maximal one in which `R ∨ L` holds throughout."* (printed p.179) -/

/-- **A bad point** — printed p.179: a point where `R ∨ L` holds.

Stated semantically, as the disjunction of the two `Defs.lean` readings; `badPointFormula` below
is the temporal formula, and `badPointFormula_spec` checks that the two agree in every Prior
structure. -/
def IsBadPoint (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2) (t : M.carrier) :
    Prop :=
  EndsInGapOnRight M ε t ∨ EndsInGapOnLeft M ε t

/-- A bad point on the right. -/
theorem IsBadPoint.of_right {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}
    {t : M.carrier} (h : EndsInGapOnRight M ε t) : IsBadPoint M ε t := Or.inl h

/-- A bad point on the left. -/
theorem IsBadPoint.of_left {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}
    {t : M.carrier} (h : EndsInGapOnLeft M ε t) : IsBadPoint M ε t := Or.inr h

/-- **A bad interval** — printed p.179: *"a non-empty and maximal one in which `R ∨ L` holds
throughout"*.

`nonempty`, `bad` and `convex` are the three words *"non-empty"*, *"in which `R ∨ L` holds
throughout"* and *"interval"*. `saturated` is this tree's rendering of *"maximal"*: any point
joined to a member of `Q` by an unbroken stretch of bad points is itself in `Q`.
`IsBadInterval.maximal_among` derives the maximal-among-bad-intervals reading from it, so the
rendering is checked rather than asserted. -/
structure IsBadInterval (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (Q : M.carrier → Prop) : Prop where
  /-- *"non-empty"*. -/
  nonempty : ∃ t : M.carrier, Q t
  /-- *"in which `R ∨ L` holds throughout"*. -/
  bad : ∀ t : M.carrier, Q t → IsBadPoint M ε t
  /-- *"interval"*: `Q` is convex. -/
  convex : ∀ a b c : M.carrier, a ≤ b → b ≤ c → Q a → Q c → Q b
  /-- *"maximal"*, in saturation form. -/
  saturated : ∀ a t : M.carrier, Q a →
    (∀ q : M.carrier, min a t ≤ q → q ≤ max a t → IsBadPoint M ε q) → Q t

/-- **The saturation clause really is maximality.** No convex set of bad points properly
contains a bad interval. -/
theorem IsBadInterval.maximal_among {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}
    {Q Q' : M.carrier → Prop} (hQ : IsBadInterval M ε Q)
    (hbad' : ∀ t : M.carrier, Q' t → IsBadPoint M ε t)
    (hconv' : ∀ a b c : M.carrier, a ≤ b → b ≤ c → Q' a → Q' c → Q' b)
    (hsub : ∀ t : M.carrier, Q t → Q' t) : ∀ t : M.carrier, Q' t → Q t := by
  intro t ht'
  obtain ⟨a, ha⟩ := hQ.nonempty
  have ha' : Q' a := hsub a ha
  refine hQ.saturated a t ha (fun q hq₁ hq₂ => hbad' q ?_)
  rcases le_total a t with h | h
  · rw [min_eq_left h] at hq₁
    rw [max_eq_right h] at hq₂
    exact hconv' a q t hq₁ hq₂ ha' ht'
  · rw [min_eq_right h] at hq₁
    rw [max_eq_left h] at hq₂
    exact hconv' t q a hq₁ hq₂ ht' ha'

section BadPointFormula

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **`R ∨ L`**, as a temporal formula — printed p.179.

`∨` is spelled with the tree's primitive connectives, `¬R → L`. -/
noncomputable def badPointFormula (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  .imp (.imp (gapRightFormula atomMap h_surj ε) .bot) (gapLeftFormula atomMap h_surj ε)

/-- **`R ∨ L` holds exactly at the bad points**, in every Prior structure. -/
theorem badPointFormula_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (badPointFormula atomMap h_surj ε) ↔ IsBadPoint M ε t := by
  have hR := gapRightFormula_spec atomMap h_surj ε M h_prior_U h_prior_S t
  have hL := gapLeftFormula_spec atomMap h_surj ε M h_prior_U h_prior_S t
  constructor
  · intro h
    by_cases hr : TemporalTruth M atomMap t (gapRightFormula atomMap h_surj ε)
    · exact Or.inl (hR.mp hr)
    · exact Or.inr (hL.mp (h hr))
  · rintro (h | h)
    · exact fun hn => (hn (hR.mpr h)).elim
    · exact fun _ => hL.mpr h

end BadPointFormula

/-! ## `B`: *"true at times which are not left hand end points of their `∼`-classes"*

Reynolds' auxiliary formula for the last paragraph of the Lemma 6 proof (printed p.180). Its
monadic form is one existential: *"some class-mate of mine lies strictly below me"*. -/

/-- **`B`'s monadic form** — *"I am not the left hand end point of my `∼`-class"*.

De Bruijn layout: free variable `0` is `x`; under `∃v` the indices are `0 = v`, `1 = x`. -/
def notLeftEndFormula (ε : MonadicFormula sig 2) : MonadicFormula sig 1 :=
  .ex (.and (epsAt ε 1 0) (.lt 0 1))

/-- **What `B` says.** -/
def NotLeftEnd (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2) (t : M.carrier) :
    Prop :=
  ∃ v : M.carrier, ContempEquivDense M ε t v ∧ v < t

/-- **The `B` transcription is correct** — checked, not asserted. -/
theorem notLeftEndFormula_eval (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) :
    eval M (fun _ => t) (notLeftEndFormula ε) ↔ NotLeftEnd M ε t := by
  simp only [notLeftEndFormula, NotLeftEnd, eval, eval_epsAt, Fin.cons_zero, b2_one]

/-- **`B` is upward closed in a class** — *"`B` is true continuously in any class from just after
the left hand end point up until the gap"* (printed p.180). -/
theorem notLeftEnd_of_le {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t u : M.carrier} (htu : ContempEquivDense M ε t u)
    (hle : t ≤ u) (ht : NotLeftEnd M ε t) : NotLeftEnd M ε u := by
  obtain ⟨v, hvc, hvt⟩ := ht
  exact ⟨v, contemp_trans hε M (contemp_symm hε M htu) hvc, lt_of_lt_of_le hvt hle⟩

section NotLeftEndTemporal

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds' `B`** — *"a temporal formula true at times which are not left hand end points of
their `∼`-classes"* (printed p.180).

Produced from `ε`, `atomMap` and `h_surj` before any structure is supplied, so one formula serves
every Prior structure. -/
noncomputable def notLeftEndTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (notLeftEndFormula ε)).val

/-- **`B` holds exactly at the non-left-end points**, in every Prior structure. -/
theorem notLeftEndTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (notLeftEndTemporal atomMap h_surj ε) ↔ NotLeftEnd M ε t :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj (notLeftEndFormula ε)).property
    M h_prior_U h_prior_S t).symm.trans (notLeftEndFormula_eval M ε t)

end NotLeftEndTemporal

/-! ## *"we can not have a class beginning just after a point `r` of `M`"*

The second paragraph of the Lemma 6 proof, printed p.180. Reynolds' reason is that `r` *"must be
its right hand end point"*, and a class with a right hand end point does not end in a gap on the
right. No temporal formula and no Prior axiom is involved: this is pure class calculus. -/

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — second paragraph.**

> *In fact we can not have a class beginning just after a point `r` of `M`. Since the class can
> not be first in the bad interval `r` itself must be in a `∼`-class in the bad interval. But
> `r`'s class can not end in a gap on the right when `r` must be its right hand end point.*

If `t`'s class begins just after `r` — `r` below the class, and everything in `(r, t)` inside it —
then `r` is the greatest element of its own class, so `ρ` fails at `r`. -/
theorem not_endsInGapOnRight_of_immediatePredecessor {ε : MonadicFormula sig 2}
    (hε : IsContempEquivDense ε) (M : OrderedMonadicStructure sig) {t r : M.carrier}
    (hrt : r < t) (hnrt : ¬ ContempEquivDense M ε t r)
    (hbetween : ∀ y : M.carrier, r < y → y < t → ContempEquivDense M ε t y) :
    ¬ EndsInGapOnRight M ε r := by
  intro hr
  -- *"`r` must be its right hand end point"*: `r` has no class-mate above it.
  refine hr.2.1 ⟨r, contemp_refl hε M r, ?_⟩
  intro y hry hcy
  rcases lt_or_ge y t with hyt | hty
  · exact hnrt (contemp_trans hε M (hbetween y hry hyt) (contemp_symm hε M hcy))
  · exact hnrt (contemp_symm hε M (contemp_of_between hε M hrt.le hty hcy))

/-! ## A class in the interior of a maximal interval of `R`

Reynolds' Lemma 4 — *"There is no last class and no first class in any maximal interval of
`R`"* — is what puts a class strictly inside its interval, with a class below and a class above.
This is that conclusion, packaged as the hypothesis the Lemma 6 and Lemma 7 proofs consume: two
witnesses `a < t < b` outside `t`'s class, with `R` throughout the closed segment `[a, b]`. -/

/-- **`t`'s class lies in the interior of a maximal interval of `R`**, witnessed by points `a`
below and `b` above it.

This is a *rendering*, not a quotation: Reynolds names the interval and appeals to Lemma 4 for
*"the class can not be first"* and for the class above. Convexity of a maximal interval supplies
`R` in between, which is `rThroughout`. -/
structure ClassInteriorToRInterval (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (a t b : M.carrier) : Prop where
  /-- `a` lies below `t`. -/
  left_lt : a < t
  /-- `b` lies above `t`. -/
  lt_right : t < b
  /-- `a` is outside `t`'s class — *"the class can not be first in this bad interval"*. -/
  left_out : ¬ ContempEquivDense M ε t a
  /-- `b` is outside `t`'s class — *"there is no last class"*. -/
  right_out : ¬ ContempEquivDense M ε t b
  /-- `R` holds throughout `[a, b]`: the whole stretch is inside the one maximal interval. -/
  rThroughout : ∀ q : M.carrier, a ≤ q → q ≤ b → EndsInGapOnRight M ε q

/-! ## *"throughout the bad interval all classes include their left hand end points"*

*"Its not hard to use the previous result to show that …"* (printed p.180). The *previous result*
is Lemma 5: *"the class includes its left hand end point"* is the same as *"`¬B` holds somewhere
in the class"*, and Lemma 5's first statement carries *"holds somewhere in one class"* to *"holds
somewhere in each class in the interval"*. -/

section Transfer

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **A class includes its left hand end point iff `¬B` holds somewhere in it.**

One direction of Reynolds' *"use the previous result"* step: it is what lets Lemma 5 be applied
to the property *"includes its left hand end point"*, which is not itself a temporal formula. -/
theorem leftEnd_iff_exists_not_notLeftEnd {ε : MonadicFormula sig 2}
    (hε : IsContempEquivDense ε) (M : OrderedMonadicStructure sig) (t : M.carrier) :
    (∃ w : M.carrier, ContempEquivDense M ε t w ∧
        ∀ u : M.carrier, ContempEquivDense M ε t u → ¬ u < w) ↔
      ∃ w : M.carrier, ContempEquivDense M ε t w ∧ ¬ NotLeftEnd M ε w := by
  constructor
  · rintro ⟨w, hwc, hwmin⟩
    refine ⟨w, hwc, ?_⟩
    rintro ⟨v, hvc, hvw⟩
    exact hwmin v (contemp_trans hε M hwc hvc) hvw
  · rintro ⟨w, hwc, hwn⟩
    refine ⟨w, hwc, ?_⟩
    intro u huc huw
    exact hwn ⟨u, contemp_trans hε M (contemp_symm hε M hwc) huc, huw⟩

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — third paragraph.**

> *Its not hard to use the previous result to show that throughout the bad interval all classes
> include their left hand end points.*

Given one class in the interval that includes its left hand end point, every class the interval
meets does. Lemma 5's first statement, applied to `¬B`. -/
theorem exists_leftEnd_throughout (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {z q : M.carrier}
    (hIcc : ∀ p : M.carrier, min z q ≤ p → p ≤ max z q → EndsInGapOnRight M ε p)
    (hz : ¬ NotLeftEnd M ε z) :
    ∃ w : M.carrier, ContempEquivDense M ε q w ∧
      ∀ u : M.carrier, ContempEquivDense M ε q u → ¬ u < w := by
  set B := notLeftEndTemporal atomMap h_surj ε with hBdef
  have hspec : ∀ x : M.carrier, TemporalTruth M atomMap x B ↔ NotLeftEnd M ε x := fun x =>
    notLeftEndTemporal_spec atomMap h_surj ε M h_prior_U h_prior_S x
  have hA : ∃ w : M.carrier, ContempEquivDense M ε z w ∧
      TemporalTruth M atomMap w (Formula.imp B Formula.bot) :=
    ⟨z, contemp_refl hε M z, fun h => hz ((hspec z).mp h)⟩
  obtain ⟨w, hwc, hwn⟩ :=
    reynolds_lemma5_first h_surj hε M h_prior_U h_prior_S (Formula.imp B Formula.bot) hIcc hA
  exact (leftEnd_iff_exists_not_notLeftEnd hε M q).mpr
    ⟨w, hwc, fun h => hwn ((hspec w).mpr h)⟩

end Transfer

/-! ## *"`B` must be false arbitrarily soon after the gap contradicting Prior-U"*

The last paragraph of the Lemma 6 proof, printed p.180. Prior-U is applied to `B` at a point `s`
of a class that is *not* its left hand end point; the boundary point Prior-U returns is trapped
between `s` and the left hand end point of a later class, and both of Prior-U's disjuncts fail
there. -/

section Lemma6Core

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — final paragraph.**

> *Let `B` be a temporal formula true at times which are not left hand end points of their
> `∼`-classes. `B` is then true continuously in any class from just after the left hand end point
> up until the gap at the right hand end point. `B` must be false arbitrarily soon after the gap
> contradicting Prior-U.*

Hypotheses, in Reynolds' order: `s` ends in a gap on the right and is not the left hand end point
of its class (witnessed by the class-mate `v < s`); `b` lies beyond `s`'s class with `R`
throughout `(s, b)`; and every class the open segment `(s, b)` meets includes its left hand end
point.

The `b` here is not a weakening. Lemma 4 supplies a later class in the same maximal interval, and
convexity of the interval supplies `R` in between, which is exactly what
`ClassInteriorToRInterval` packages. -/
theorem false_of_allClassesHaveLeftEnd (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap)
    {s v b : M.carrier} (hs : EndsInGapOnRight M ε s)
    (hvs : v < s) (hvc : ContempEquivDense M ε s v)
    (hsb : s < b) (hnb : ¬ ContempEquivDense M ε s b)
    (hR : ∀ q : M.carrier, s < q → q < b → EndsInGapOnRight M ε q)
    (hleft : ∀ q : M.carrier, s < q → q < b →
      ∃ w : M.carrier, ContempEquivDense M ε q w ∧
        ∀ u : M.carrier, ContempEquivDense M ε q u → ¬ u < w) : False := by
  set B := notLeftEndTemporal atomMap h_surj ε with hBdef
  have hspec : ∀ x : M.carrier, TemporalTruth M atomMap x B ↔ NotLeftEnd M ε x := fun x =>
    notLeftEndTemporal_spec atomMap h_surj ε M h_prior_U h_prior_S x
  -- *"`B` is true continuously in any class from just after the left hand end point"*: the
  -- `U(⊤,B)` antecedent of Prior-U.
  obtain ⟨y, hsy, hcy⟩ := exists_contemp_gt hε M hs
  have hstretch : ∃ z : M.carrier, s < z ∧ ∀ r : M.carrier, s < r → r < z →
      TemporalTruth M atomMap r B := by
    refine ⟨y, hsy, fun r h₁ h₂ => (hspec r).mpr ⟨v, ?_, lt_trans hvs h₁⟩⟩
    exact contemp_trans hε M
      (contemp_symm hε M (contemp_of_between hε M h₁.le h₂.le hcy)) hvc
  -- *"`B` must be false … after the gap"*: the `F¬B` antecedent, at the left hand end point of a
  -- later class.
  have hu₀ : ∃ u : M.carrier, s < u ∧ u < b ∧ ¬ ContempEquivDense M ε s u := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨b, hsb, hnb, fun z h₁ h₂ => hcon z h₁ h₂⟩
  obtain ⟨u₀, hsu₀, hu₀b, hnu₀⟩ := hu₀
  obtain ⟨w₀, hw₀c, hw₀min⟩ := hleft u₀ hsu₀ hu₀b
  have hw₀u₀ : w₀ ≤ u₀ := not_lt.mp (hw₀min u₀ (contemp_refl hε M u₀))
  have hw₀b : w₀ < b := lt_of_le_of_lt hw₀u₀ hu₀b
  have hsw₀ : s < w₀ := by
    by_contra hcon
    push_neg at hcon
    have h1 : ContempEquivDense M ε w₀ s :=
      contemp_of_between hε M hcon hsu₀.le (contemp_symm hε M hw₀c)
    exact hnu₀ (contemp_trans hε M (contemp_symm hε M h1) (contemp_symm hε M hw₀c))
  have hnBw₀ : ¬ TemporalTruth M atomMap w₀ B := by
    intro h
    obtain ⟨v', hv'c, hv'lt⟩ := (hspec w₀).mp h
    exact hw₀min v' (contemp_trans hε M hw₀c hv'c) hv'lt
  obtain ⟨s₁, hss₁, hbelow, hcase⟩ := h_prior_U s B hstretch ⟨w₀, hsw₀, hnBw₀⟩
  have hs₁w₀ : s₁ ≤ w₀ := by
    by_contra hcon
    push_neg at hcon
    exact hnBw₀ (hbelow w₀ hsw₀ hcon)
  have hs₁b : s₁ < b := lt_of_le_of_lt hs₁w₀ hw₀b
  rcases hcase with hnB₁ | ⟨hB₁, hkplus⟩
  · -- `¬B(s₁)`: `s₁` lies beyond `s`'s class, and a later class starts inside `(s, s₁)`.
    have hns₁ : ¬ ContempEquivDense M ε s s₁ := by
      intro hc
      exact hnB₁ ((hspec s₁).mpr
        ⟨v, contemp_trans hε M (contemp_symm hε M hc) hvc, lt_trans hvs hss₁⟩)
    have hex : ∃ r : M.carrier, s < r ∧ r < s₁ ∧ ¬ ContempEquivDense M ε s r := by
      by_contra hcon
      push_neg at hcon
      exact hs.2.2 ⟨s₁, hss₁, hns₁, fun z h₁ h₂ => hcon z h₁ h₂⟩
    obtain ⟨r, hsr, hrs₁, hnr⟩ := hex
    obtain ⟨w, hwc, hwmin⟩ := hleft r hsr (lt_trans hrs₁ hs₁b)
    have hwr : w ≤ r := not_lt.mp (hwmin r (contemp_refl hε M r))
    have hsw : s < w := by
      by_contra hcon
      push_neg at hcon
      have h1 : ContempEquivDense M ε w s :=
        contemp_of_between hε M hcon hsr.le (contemp_symm hε M hwc)
      exact hnr (contemp_trans hε M (contemp_symm hε M h1) (contemp_symm hε M hwc))
    have hnBw : ¬ TemporalTruth M atomMap w B := by
      intro h
      obtain ⟨v', hv'c, hv'lt⟩ := (hspec w).mp h
      exact hwmin v' (contemp_trans hε M hwc hv'c) hv'lt
    exact hnBw (hbelow w hsw (lt_of_le_of_lt hwr hrs₁))
  · -- `B(s₁) ∧ K⁺(¬B)(s₁)`: `s₁`'s class has no last point, so `B` cannot fail just above it.
    have hRs₁ : EndsInGapOnRight M ε s₁ := hR s₁ hss₁ hs₁b
    obtain ⟨y₁, hs₁y₁, hcy₁⟩ := exists_contemp_gt hε M hRs₁
    obtain ⟨v₁, hv₁c, hv₁lt⟩ := (hspec s₁).mp hB₁
    obtain ⟨r, hs₁r, hry₁, hnr⟩ := hkplus y₁ hs₁y₁
    refine hnr ((hspec r).mpr ⟨v₁, ?_, lt_trans hv₁lt hs₁r⟩)
    exact contemp_trans hε M
      (contemp_symm hε M (contemp_of_between hε M hs₁r.le hry₁.le hcy₁)) hv₁c

end Lemma6Core

/-! ## *"`L` holds wherever `R` does"*

The Lemma 6 proof assembled. `EndsInGapOnLeft`'s three conjuncts are discharged in Reynolds'
order: the first from the class not being first in the interval, the third by
`not_endsInGapOnRight_of_immediatePredecessor`, and the second — *"the class includes its left
hand end point"* — by `exists_leftEnd_throughout` followed by
`false_of_allClassesHaveLeftEnd`. -/

section Lemma6

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — *"we first show that `L` holds wherever `R`
does"*.**

`R` at `t`, plus `t`'s class lying in the interior of a maximal interval of `R`, gives `L` at
`t`. -/
theorem endsInGapOnLeft_of_endsInGapOnRight (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {a t b : M.carrier}
    (hint : ClassInteriorToRInterval M ε a t b) :
    EndsInGapOnLeft M ε t := by
  have ht : EndsInGapOnRight M ε t :=
    hint.rThroughout t hint.left_lt.le hint.lt_right.le
  refine ⟨⟨a, hint.left_lt, hint.left_out⟩, ?_, ?_⟩
  · -- *"the class includes its left hand end point"* is impossible.
    rintro ⟨z, hzc, hzmin⟩
    -- `z` is the least element of `t`'s class, so `¬B` holds at `z`.
    have hzle : z ≤ t := not_lt.mp (fun h => hzmin t h (contemp_refl hε M t))
    have haz : a < z := by
      by_contra hcon
      push_neg at hcon
      have hza : ContempEquivDense M ε z a :=
        contemp_of_between hε M hcon hint.left_lt.le (contemp_symm hε M hzc)
      exact hint.left_out (contemp_trans hε M hzc hza)
    have hzb : z < b := lt_of_le_of_lt hzle hint.lt_right
    have hnz : ¬ NotLeftEnd M ε z := by
      rintro ⟨v, hvc, hvz⟩
      exact hzmin v hvz (contemp_trans hε M hzc hvc)
    have hRz : EndsInGapOnRight M ε z := hint.rThroughout z haz.le hzb.le
    -- A class-mate `s > z`: `s` is not the left hand end point of its class.
    obtain ⟨s, hzs, hcs⟩ := exists_contemp_gt hε M hRz
    have hst : ContempEquivDense M ε s t :=
      contemp_trans hε M (contemp_symm hε M hcs) (contemp_symm hε M hzc)
    have hsb : s < b := by
      by_contra hcon
      push_neg at hcon
      exact hint.right_out
        (contemp_of_between hε M hint.lt_right.le hcon (contemp_symm hε M hst))
    have hnb : ¬ ContempEquivDense M ε s b :=
      fun hc => hint.right_out (contemp_trans hε M (contemp_symm hε M hst) hc)
    have hRs : EndsInGapOnRight M ε s := (endsInGapOnRight_congr hε M hcs).mp hRz
    refine false_of_allClassesHaveLeftEnd atomMap h_surj hε M h_prior_U h_prior_S
      hRs hzs (contemp_symm hε M hcs) hsb hnb
      (fun q h₁ h₂ => hint.rThroughout q (le_trans haz.le (le_trans hzs.le h₁.le)) h₂.le)
      (fun q h₁ h₂ => ?_)
    refine exists_leftEnd_throughout atomMap h_surj hε M h_prior_U h_prior_S ?_ hnz
    intro p hp₁ hp₂
    have haq : a ≤ q := le_of_lt (lt_trans haz (lt_trans hzs h₁))
    exact hint.rThroughout p (le_trans (le_min haz.le haq) hp₁)
      (le_trans hp₂ (max_le hzb.le h₂.le))
  · -- *"we can not have a class beginning just after a point `r` of `M`"*.
    rintro ⟨z, hzt, hnz, hall⟩
    have haz : a ≤ z := by
      by_contra hcon
      push_neg at hcon
      exact hint.left_out (hall a hcon hint.left_lt)
    exact not_endsInGapOnRight_of_immediatePredecessor hε M hzt hnz hall
      (hint.rThroughout z haz (le_trans hzt.le hint.lt_right.le))

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — *"bad points only occur in non-singleton bad
intervals"*, right-hand half.**

Where `R` holds, `R` holds on a whole stretch above, so the point is not an isolated bad point.
This is `endsInGapOnRight_forAWhile` (`Lemma34.lean:277`) read as a statement about bad
points. -/
theorem reynolds_lemma6_nonsingleton {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    ∃ y : M.carrier, t < y ∧ ∀ r : M.carrier, t < r → r ≤ y → IsBadPoint M ε r := by
  obtain ⟨y, hty, hy⟩ := endsInGapOnRight_forAWhile hε M ht
  exact ⟨y, hty, fun r h₁ h₂ => IsBadPoint.of_right (hy r h₁ h₂)⟩

end Lemma6

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
