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
| *"any bad interval, if bounded, has excluded end points in `M`"* | `reynolds_lemma6_right_endpoint` |
| *"using mirror images of the above and previous results"* | `ClassInteriorToLInterval`, `endsInGapOnRight_of_endsInGapOnLeft` (via `Dual.lean`) |
| Lemma 6, all four clauses, assembled | `reynolds_lemma6` |
| *"a temporal formula `C` which is true only at points within a `∼`-class after some `¬B` in that class"* | `afterNotHoldsInClassFormula` / `AfterNotHoldsInClass` / `afterNotHoldsInClassTemporal` (+ `_eval`, `_spec`) |
| *"`C` is true for a while up to the gap at the end and false arbitrarily soon after the gap. This contradicts Prior-U"* | `false_of_holds_throughout_class_from_bounded` |
| *"`C` will be false for a while at the beginning of each class"* | `exists_notAfterNotHolds_in_class` (via `reynolds_lemma5_first`) |
| Lemma 7, first statement, *"at the start"* | `reynolds_lemma7_start` |
| Lemma 7, first statement, *"Similarly at the end"* | `reynolds_lemma7_end` (mirror: Prior-S, `λ`, `beforeNotHoldsInClassTemporal`) |
| Lemma 7, second statement | `reynolds_lemma7_close_to_left` / `reynolds_lemma7_close_to_right` |
| both statements assembled | `reynolds_lemma7` |

## LEMMA 6'S FOUR HALVES — all discharged, the fourth by duality transport

Lemma 6's proof ends *"Using mirror images of the above and previous results we get our proof."*
All four of its halves are discharged below (`reynolds_lemma6`), and no `sorry` stands in for
any of them.

The fourth — `R` holds wherever `L` does — is **not** a second proof. It is
`endsInGapOnLeft_of_endsInGapOnRight` instantiated at `(dual M, dualize ε)` through
`DenseModelSurgery/Dual.lean`, with the interval endpoints exchanged; the *"previous results"*
the mirrored argument appeals to are supplied by `reynolds_lemma5_first_left`, itself an
instantiation of `reynolds_lemma5_first` at the dual. An instantiation is what Reynolds' one
sentence actually says; a hand-written mirror would formalize a proof he did not write.

The `λ`-side interval hypothesis has no counterpart in the tree and is defined here as
`ClassInteriorToLInterval`, the exact mirror of `ClassInteriorToRInterval`.

Note that Lemma 7's mirror is landed here **by hand**, at `:968-1225`. It predates the transport
layer and is left exactly as it is — nothing is deleted, refactored or deprecated — but it is the
last mirror in this tree that should be written that way. It does not run into the `λ`-side
Lemma 5 question at all: a bad interval carries both `R` and `L` throughout
(`ClassInteriorToBadInterval`), so its Lemma 5 appeals use the `R` side directly even in the
past-directed argument.

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

/-! ## Class-mates stay inside the interval

Two one-line consequences of convexity, used repeatedly below: a class-mate of `t` cannot escape
past a point outside `t`'s class on either side. -/

/-- Every class-mate of `t` lies strictly above a point below `t` that is outside `t`'s class. -/
theorem lt_of_classMate {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {a t s : M.carrier} (hat : a < t)
    (hna : ¬ ContempEquivDense M ε t a) (hts : ContempEquivDense M ε t s) : a < s := by
  by_contra hcon
  push_neg at hcon
  exact hna (contemp_trans hε M hts
    (contemp_of_between hε M hcon hat.le (contemp_symm hε M hts)))

/-- Every class-mate of `t` lies strictly below a point above `t` that is outside `t`'s class. -/
theorem classMate_lt {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t b s : M.carrier} (htb : t < b)
    (hnb : ¬ ContempEquivDense M ε t b) (hts : ContempEquivDense M ε t s) : s < b := by
  by_contra hcon
  push_neg at hcon
  exact hnb (contemp_of_between hε M htb.le hcon hts)

/-! ## The gap-crossing contradiction Lemma 7 actually licenses

See the module header for why neither `false_of_holds_throughout_class` (`Lemma34.lean:595`) nor
`false_of_holds_throughout_class_bounded` (`Lemma5.lean:400`) can be used here. Both slots are
weakened:

* `hin` only from `s` **onwards** in the class — Reynolds' *"true for a while at the end"*;
* `hout` only *"false **arbitrarily soon** after the gap"* — some failure point at or below each
  given point beyond the class, rather than failure at every such point.

The proof is the same Prior-U argument as its two predecessors: Prior-U applied to `P` at `s`
produces a boundary point `s₁` for the stretch on which `P` holds; `s₁` cannot lie in `s`'s class,
because the class has no last point and `P` holds throughout it from `s` on; so `(s, s₁)` cannot be
contained in the class either, since `s₁` would be *"the first point after the class"*, which
`ρ(s)`'s third conjunct forbids. `hout` then supplies a `P`-failure at or below the resulting point
of `(s, s₁)`, where Prior-U's stretch says `P` holds. -/

/-- **The gap-crossing contradiction, from `s` onwards and bounded.**

Strictly weaker in both hypothesis slots than `false_of_holds_throughout_class_bounded`
(`Lemma5.lean:400`), which is left in place unweakened and unrenamed together with all of its
consumers. Prior-S is not needed. -/
theorem false_of_holds_throughout_class_from_bounded {atomMap : Formula → sig.preds}
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    {s : M.carrier} (hs : EndsInGapOnRight M ε s) (P : Formula)
    {b : M.carrier} (hsb : s < b) (hnb : ¬ ContempEquivDense M ε s b)
    (hin : ∀ r : M.carrier, ContempEquivDense M ε s r → s ≤ r → TemporalTruth M atomMap r P)
    (hout : ∀ u : M.carrier, s < u → u < b → ¬ ContempEquivDense M ε s u →
      ∃ r : M.carrier, s < r ∧ r ≤ u ∧ ¬ TemporalTruth M atomMap r P) : False := by
  -- *"there is no first point after the class"*: some point of `(s,b)` is already outside it.
  have hu₀ : ∃ u : M.carrier, s < u ∧ u < b ∧ ¬ ContempEquivDense M ε s u := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨b, hsb, hnb, fun y h₁ h₂ => hcon y h₁ h₂⟩
  obtain ⟨u₀, hsu₀, hu₀b, hnu₀⟩ := hu₀
  obtain ⟨r₀, hsr₀, hr₀u₀, hnP₀⟩ := hout u₀ hsu₀ hu₀b hnu₀
  obtain ⟨y, hsy, hcy⟩ := exists_contemp_gt hε M hs
  have hstretch : ∃ c : M.carrier, s < c ∧ ∀ r : M.carrier, s < r → r < c →
      TemporalTruth M atomMap r P :=
    ⟨y, hsy, fun r h₁ h₂ => hin r (contemp_of_between hε M h₁.le h₂.le hcy) h₁.le⟩
  obtain ⟨s₁, hss₁, hbelow, hcase⟩ := h_prior_U s P hstretch ⟨r₀, hsr₀, hnP₀⟩
  have hns₁ : ¬ ContempEquivDense M ε s s₁ := by
    intro hc
    rcases hcase with hn | ⟨_hb, hkplus⟩
    · exact hn (hin s₁ hc hss₁.le)
    · obtain ⟨y', hs₁y', hcy'⟩ :=
        exists_contemp_gt hε M ((endsInGapOnRight_congr hε M hc).mp hs)
      obtain ⟨r, hs₁r, hry', hnr⟩ := hkplus y' hs₁y'
      exact hnr (hin r (contemp_trans hε M hc (contemp_of_between hε M hs₁r.le hry'.le hcy'))
        (le_trans hss₁.le hs₁r.le))
  have hex : ∃ r : M.carrier, s < r ∧ r < s₁ ∧ ¬ ContempEquivDense M ε s r := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨s₁, hss₁, hns₁, fun z h₁ h₂ => hcon z h₁ h₂⟩
  obtain ⟨r, hsr, hrs₁, hnr⟩ := hex
  rcases lt_or_ge r₀ s₁ with hlt | hge
  · exact hnP₀ (hbelow r₀ hsr₀ hlt)
  · have hrb : r < b :=
      lt_of_lt_of_le hrs₁ (le_trans hge (le_trans hr₀u₀ hu₀b.le))
    obtain ⟨r', hsr', hr'r, hnP'⟩ := hout r hsr hrb hnr
    exact hnP' (hbelow r' hsr' (lt_of_le_of_lt hr'r hrs₁))

/-! ## `C`: *"true only at points within a `∼`-class after some `¬B` in that class"*

Reynolds' auxiliary formula for Lemma 7, printed p.180. Its monadic form is one existential:
*"some class-mate of mine lies strictly below me and fails `B`"*. -/

/-- **`C`'s monadic form** — *"I am at a point within a `∼`-class after some `¬β` in that class"*.

De Bruijn layout: free variable `0` is `x`; under `∃v` the indices are `0 = v`, `1 = x`. -/
def afterNotHoldsInClassFormula (ε : MonadicFormula sig 2) (β : MonadicFormula sig 1) :
    MonadicFormula sig 1 :=
  .ex (.and (epsAt ε 1 0) (.and (.lt 0 1) (.not (atVar β 0))))

/-- **What `C` says.** -/
def AfterNotHoldsInClass (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (P : M.carrier → Prop) (t : M.carrier) : Prop :=
  ∃ v : M.carrier, ContempEquivDense M ε t v ∧ v < t ∧ ¬ P v

/-- **The `C` transcription is correct** — checked, not asserted. -/
theorem afterNotHoldsInClassFormula_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (β : MonadicFormula sig 1) (t : M.carrier) :
    eval M (fun _ => t) (afterNotHoldsInClassFormula ε β) ↔
      AfterNotHoldsInClass M ε (fun v => eval M (fun _ => v) β) t := by
  simp only [afterNotHoldsInClassFormula, AfterNotHoldsInClass, eval, eval_epsAt, eval_atVar,
    Fin.cons_zero, b2_one]

/-- **`C` is upward closed in a class** — *"then true for a while at the end"* (printed p.180). -/
theorem afterNotHoldsInClass_of_le {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (P : M.carrier → Prop) {t u : M.carrier}
    (htu : ContempEquivDense M ε t u) (hle : t ≤ u) (ht : AfterNotHoldsInClass M ε P t) :
    AfterNotHoldsInClass M ε P u := by
  obtain ⟨v, hvc, hvt, hnv⟩ := ht
  exact ⟨v, contemp_trans hε M (contemp_symm hε M htu) hvc, lt_of_lt_of_le hvt hle, hnv⟩

/-- **`¬C` is downward closed in a class** — *"`C` will be false for a while at the beginning of
each class"* (printed p.180). The contrapositive of `afterNotHoldsInClass_of_le`. -/
theorem not_afterNotHoldsInClass_of_le {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (P : M.carrier → Prop) {t u : M.carrier}
    (htu : ContempEquivDense M ε t u) (hle : u ≤ t) (ht : ¬ AfterNotHoldsInClass M ε P t) :
    ¬ AfterNotHoldsInClass M ε P u := fun h =>
  ht (afterNotHoldsInClass_of_le hε M P (contemp_symm hε M htu) hle h)

section Lemma7

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds' `C`** — *"a temporal formula `C` which is true only at points within a `∼`-class
after some `¬B` in that class"* (printed p.180). -/
noncomputable def afterNotHoldsInClassTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (B : Formula) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (afterNotHoldsInClassFormula ε (temporalToMonadic atomMap B))).val

/-- **What `C` holds of**, in every Prior structure. -/
theorem afterNotHoldsInClassTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (B : Formula) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (afterNotHoldsInClassTemporal atomMap h_surj ε B) ↔
      AfterNotHoldsInClass M ε (fun v => TemporalTruth M atomMap v B) t := by
  refine ((uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (afterNotHoldsInClassFormula ε (temporalToMonadic atomMap B))).property
      M h_prior_U h_prior_S t).symm.trans ?_
  rw [afterNotHoldsInClassFormula_eval]
  simp only [eval_temporalToMonadic]

/-- **Reynolds 1992, §6 Lemma 7, printed pp.180-181 — first statement, the *start* half.**

> *If a formula `B` is true for a while at the start of a `∼`-class in a bad interval then it
> holds throughout the bad interval.*
>
> *Suppose that `γ < δ` are gaps and that `(γ, δ)` is a `∼`-class within a bad interval. Suppose
> that `B` holds for a while after `γ` but that `¬B` holds somewhere in the bad interval. By
> lemma 5, `¬B` also holds somewhere in `(γ, δ)`. Using `ε` and expressive completeness we can
> find a temporal formula `C` which is true only at points within a `∼`-class after some `¬B` in
> that class. `C` will be false for a while at the beginning of each class and then true for a
> while at the end. In fact `C` is true for a while up to the gap at the end and false arbitrarily
> soon after the gap. This contradicts Prior-U.*

*"`(γ, δ)` is a `∼`-class within a bad interval"* is `hint`; *"`B` holds for a while after `γ`"*
is `hstart`, `B` at every class-mate of `t` below some class-mate `x`; *"throughout the bad
interval"* is the conclusion at every `u ∈ [a, b]`.

Reynolds' *"`C` will be false for a while at the beginning of each class"* is where Lemma 5 is
used a second time, on `¬C`: `¬C` holds at `x` outright, because `hstart` gives `B` at every
class-mate below `x`. -/
theorem reynolds_lemma7_start (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (B : Formula) {a t b : M.carrier}
    (hint : ClassInteriorToRInterval M ε a t b)
    (hstart : ∃ x : M.carrier, ContempEquivDense M ε t x ∧
      ∀ q : M.carrier, ContempEquivDense M ε t q → q < x → TemporalTruth M atomMap q B)
    {u : M.carrier} (hau : a ≤ u) (hub : u ≤ b) : TemporalTruth M atomMap u B := by
  by_contra hnB
  obtain ⟨x, hxc, hxB⟩ := hstart
  have ht : EndsInGapOnRight M ε t :=
    hint.rThroughout t hint.left_lt.le hint.lt_right.le
  set C := afterNotHoldsInClassTemporal atomMap h_surj ε B with hCdef
  have hCspec : ∀ z : M.carrier, TemporalTruth M atomMap z C ↔
      AfterNotHoldsInClass M ε (fun v => TemporalTruth M atomMap v B) z := fun z =>
    afterNotHoldsInClassTemporal_spec atomMap h_surj ε B M h_prior_U h_prior_S z
  -- `hIcc` for any two points of `[a, b]`.
  have hIcc : ∀ z w : M.carrier, a ≤ z → z ≤ b → a ≤ w → w ≤ b →
      ∀ q : M.carrier, min z w ≤ q → q ≤ max z w → EndsInGapOnRight M ε q := by
    intro z w hz₁ hz₂ hw₁ hw₂ q hq₁ hq₂
    exact hint.rThroughout q (le_trans (le_min hz₁ hw₁) hq₁) (le_trans hq₂ (max_le hz₂ hw₂))
  have hat : a ≤ t := hint.left_lt.le
  have htb : t ≤ b := hint.lt_right.le
  -- *"By lemma 5, `¬B` also holds somewhere in `(γ, δ)`."*
  obtain ⟨p, hpc, hpB⟩ :=
    reynolds_lemma5_first h_surj hε M h_prior_U h_prior_S (Formula.imp B Formula.bot)
      (hIcc u t hau hub hat htb) ⟨u, contemp_refl hε M u, hnB⟩
  -- *"true for a while at the end"*: pick a class-mate `s` above `p`.
  have hRp : EndsInGapOnRight M ε p := (endsInGapOnRight_congr hε M hpc).mp ht
  obtain ⟨s, hps, hpsc⟩ := exists_contemp_gt hε M hRp
  have hts : ContempEquivDense M ε t s := contemp_trans hε M hpc hpsc
  have hRs : EndsInGapOnRight M ε s := (endsInGapOnRight_congr hε M hts).mp ht
  have has : a < s := lt_of_classMate hε M hint.left_lt hint.left_out hts
  have hsb : s < b := classMate_lt hε M hint.lt_right hint.right_out hts
  have hnsb : ¬ ContempEquivDense M ε s b :=
    fun hc => hint.right_out (contemp_trans hε M hts hc)
  -- `hin`: `C` holds throughout `s`'s class from `s` on.
  have hin : ∀ r : M.carrier, ContempEquivDense M ε s r → s ≤ r →
      TemporalTruth M atomMap r C := by
    intro r hsr hle
    refine (hCspec r).mpr (afterNotHoldsInClass_of_le hε M _ hsr hle ?_)
    exact ⟨p, contemp_trans hε M (contemp_symm hε M hts) hpc, hps, hpB⟩
  -- `hout`: *"false arbitrarily soon after the gap"*, via Lemma 5 applied to `¬C`.
  have hnCx : ¬ AfterNotHoldsInClass M ε (fun v => TemporalTruth M atomMap v B) x := by
    rintro ⟨v, hvc, hvx, hnv⟩
    exact hnv (hxB v (contemp_trans hε M hxc hvc) hvx)
  have hout : ∀ w : M.carrier, s < w → w < b → ¬ ContempEquivDense M ε s w →
      ∃ r : M.carrier, s < r ∧ r ≤ w ∧ ¬ TemporalTruth M atomMap r C := by
    intro w hsw hwb hnsw
    have hax : a < x := lt_of_classMate hε M hint.left_lt hint.left_out hxc
    have hxb : x < b := classMate_lt hε M hint.lt_right hint.right_out hxc
    obtain ⟨w', hw'c, hw'⟩ :=
      reynolds_lemma5_first h_surj hε M h_prior_U h_prior_S (Formula.imp C Formula.bot)
        (hIcc x w hax.le hxb.le (le_trans has.le hsw.le) hwb.le)
        ⟨x, contemp_refl hε M x, fun h => hnCx ((hCspec x).mp h)⟩
    -- Move the witness down to `w` if it overshot.
    refine ⟨min w' w, ?_, min_le_right w' w, ?_⟩
    · have hkey : ∀ z : M.carrier, ContempEquivDense M ε w z → s < z := by
        intro z hwz
        by_contra hcon
        push_neg at hcon
        have hzs : ContempEquivDense M ε z s :=
          contemp_of_between hε M hcon hsw.le (contemp_symm hε M hwz)
        exact hnsw (contemp_trans hε M (contemp_symm hε M hzs) (contemp_symm hε M hwz))
      rcases le_total w' w with h | h
      · rw [min_eq_left h]; exact hkey w' hw'c
      · rw [min_eq_right h]; exact hkey w (contemp_refl hε M w)
    · rcases le_total w' w with h | h
      · rw [min_eq_left h]; exact hw'
      · rw [min_eq_right h]
        intro hCw
        exact hw' ((hCspec w').mpr
          (afterNotHoldsInClass_of_le hε M _ hw'c h ((hCspec w).mp hCw)))
  exact false_of_holds_throughout_class_from_bounded hε M h_prior_U hRs C hsb hnsb hin hout

/-- **Reynolds 1992, §6 Lemma 7, printed p.181 — second statement, the *left end* half.**

> *If a formula is true anywhere in a bad interval it is true arbitrarily close to each end of
> each class in the interval.*
>
> *Applying the above to the negation of a formula gives us the second part.*

Exactly Reynolds' one-line derivation: were `A` to fail on a whole initial stretch of the class,
`¬A` would be *"true for a while at the start"*, so by the first statement `¬A` would hold
throughout the interval, contradicting `A` holding somewhere in it. -/
theorem reynolds_lemma7_close_to_left (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (A : Formula) {a t b : M.carrier}
    (hint : ClassInteriorToRInterval M ε a t b)
    (hsome : ∃ u : M.carrier, a ≤ u ∧ u ≤ b ∧ TemporalTruth M atomMap u A)
    (x : M.carrier) (hxc : ContempEquivDense M ε t x) :
    ∃ q : M.carrier, ContempEquivDense M ε t q ∧ q < x ∧ TemporalTruth M atomMap q A := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨u, hau, hub, hAu⟩ := hsome
  exact reynolds_lemma7_start atomMap h_surj hε M h_prior_U h_prior_S
    (Formula.imp A Formula.bot) hint ⟨x, hxc, fun q hq hqx => hcon q hq hqx⟩ hau hub hAu

end Lemma7

/-! ## The mirror: *"Similarly at the end"*

Reynolds discharges the second half of Lemma 7's first statement with the single word *"Similarly"*
(printed p.180). The mirror is not free: it runs on Prior-S rather than Prior-U, on `λ` rather than
`ρ`, and on the mirror auxiliary formula *"before some `¬B` in that class"*. Everything it needs
that the tree does not already have in mirrored form is landed below, with each declaration
labelled as a mirror rather than a transcription — Reynolds prints no text for any of it.

Lemma 5 is **not** mirrored, and does not need to be: `reynolds_lemma5_first` is already
two-sided in its two points (its `hIcc` runs over `[min t t', max t t']`), and it is stated over
`R`, which by Lemma 6 holds throughout a bad interval alongside `L`. That is why the hypothesis
package below carries both. -/

/-- **`λ` is a property of the `∼`-class**, the mirror of `endsInGapOnRight_congr`
(`Lemma34.lean:242`). Reynolds uses it silently on both sides. -/
theorem endsInGapOnLeft_congr {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t u : M.carrier}
    (htu : ContempEquivDense M ε t u) : EndsInGapOnLeft M ε t ↔ EndsInGapOnLeft M ε u := by
  have main : ∀ {p q : M.carrier}, ContempEquivDense M ε p q → EndsInGapOnLeft M ε p →
      EndsInGapOnLeft M ε q := by
    intro p q hpq h
    obtain ⟨⟨y₀, hy₀p, hny₀⟩, h2, h3⟩ := h
    have key : ∀ c : M.carrier, ContempEquivDense M ε p c ↔ ContempEquivDense M ε q c :=
      fun _ => contemp_congr_left hε M hpq
    refine ⟨⟨y₀, ?_, fun hc => hny₀ ((key y₀).mpr hc)⟩, ?_, ?_⟩
    · by_contra hle
      push_neg at hle
      exact hny₀ ((key y₀).mpr
        (contemp_of_between hε M hle hy₀p.le (contemp_symm hε M hpq)))
    · rintro ⟨z, hz, hz2⟩
      exact h2 ⟨z, (key z).mpr hz, fun y hy hc => hz2 y hy ((key y).mp hc)⟩
    · rintro ⟨z, hzq, hnz, hall⟩
      refine h3 ⟨z, ?_, fun hc => hnz ((key z).mp hc), ?_⟩
      · by_contra hle
        push_neg at hle
        exact hnz ((key z).mp (contemp_of_between hε M hle hzq.le hpq))
      · intro y hzy hyp
        rcases lt_or_ge y q with hyq | hqy
        · exact (key y).mpr (hall y hzy hyq)
        · exact (key y).mpr
            (contemp_of_between hε M hqy hyp.le (contemp_symm hε M hpq))
  exact ⟨main htu, main (contemp_symm hε M htu)⟩

/-- **The class has no first point**, the mirror of `exists_contemp_gt` (`Lemma34.lean:265`):
`λ(t)`'s second conjunct at `z := t`, with reflexivity. -/
theorem exists_contemp_lt {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t : M.carrier} (h : EndsInGapOnLeft M ε t) :
    ∃ y : M.carrier, y < t ∧ ContempEquivDense M ε t y := by
  by_contra hcon
  push_neg at hcon
  exact h.2.1 ⟨t, contemp_refl hε M t, fun y hy => hcon y hy⟩

/-- **`t`'s class lies in the interior of a bad interval** — printed p.180, Lemma 6: *"In any bad
interval both `R` and `L` hold throughout."*

The `R` half is `ClassInteriorToRInterval`; `lThroughout` is the `L` half, which
`endsInGapOnLeft_of_endsInGapOnRight` supplies class by class. -/
structure ClassInteriorToBadInterval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (a t b : M.carrier) : Prop where
  /-- The `R` half of *"both `R` and `L` hold throughout"*. -/
  toR : ClassInteriorToRInterval M ε a t b
  /-- The `L` half of *"both `R` and `L` hold throughout"*. -/
  lThroughout : ∀ q : M.carrier, a ≤ q → q ≤ b → EndsInGapOnLeft M ε q

/-- **The gap-crossing contradiction, up to `s` and bounded** — the past-directed mirror of
`false_of_holds_throughout_class_from_bounded`, on Prior-S and `λ`. No printed source: Reynolds
writes only *"Similarly at the end"*. -/
theorem false_of_holds_throughout_class_upto_bounded {atomMap : Formula → sig.preds}
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_S : SemanticPriorS M atomMap)
    {s : M.carrier} (hs : EndsInGapOnLeft M ε s) (P : Formula)
    {b : M.carrier} (hbs : b < s) (hnb : ¬ ContempEquivDense M ε s b)
    (hin : ∀ r : M.carrier, ContempEquivDense M ε s r → r ≤ s → TemporalTruth M atomMap r P)
    (hout : ∀ u : M.carrier, u < s → b < u → ¬ ContempEquivDense M ε s u →
      ∃ r : M.carrier, r < s ∧ u ≤ r ∧ ¬ TemporalTruth M atomMap r P) : False := by
  have hu₀ : ∃ u : M.carrier, u < s ∧ b < u ∧ ¬ ContempEquivDense M ε s u := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨b, hbs, hnb, fun y h₁ h₂ => hcon y h₂ h₁⟩
  obtain ⟨u₀, hu₀s, hbu₀, hnu₀⟩ := hu₀
  obtain ⟨r₀, hr₀s, hu₀r₀, hnP₀⟩ := hout u₀ hu₀s hbu₀ hnu₀
  obtain ⟨y, hys, hcy⟩ := exists_contemp_lt hε M hs
  have hstretch : ∃ c : M.carrier, c < s ∧ ∀ r : M.carrier, c < r → r < s →
      TemporalTruth M atomMap r P :=
    ⟨y, hys, fun r h₁ h₂ => hin r
      (contemp_trans hε M hcy
        (contemp_of_between hε M h₁.le h₂.le (contemp_symm hε M hcy))) h₂.le⟩
  obtain ⟨s₁, hs₁s, hbelow, hcase⟩ := h_prior_S s P hstretch ⟨r₀, hr₀s, hnP₀⟩
  have hns₁ : ¬ ContempEquivDense M ε s s₁ := by
    intro hc
    rcases hcase with hn | ⟨_hb, hkminus⟩
    · exact hn (hin s₁ hc hs₁s.le)
    · obtain ⟨y', hy's₁, hcy'⟩ :=
        exists_contemp_lt hε M ((endsInGapOnLeft_congr hε M hc).mp hs)
      obtain ⟨r, hy'r, hrs₁, hnr⟩ := hkminus y' hy's₁
      refine hnr (hin r (contemp_trans hε M hc ?_) (le_trans hrs₁.le hs₁s.le))
      exact contemp_trans hε M hcy'
        (contemp_of_between hε M hy'r.le hrs₁.le (contemp_symm hε M hcy'))
  have hex : ∃ r : M.carrier, r < s ∧ s₁ < r ∧ ¬ ContempEquivDense M ε s r := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨s₁, hs₁s, hns₁, fun z h₁ h₂ => hcon z h₂ h₁⟩
  obtain ⟨r, hrs, hs₁r, hnr⟩ := hex
  rcases lt_or_ge s₁ r₀ with hlt | hge
  · exact hnP₀ (hbelow r₀ hlt hr₀s)
  · have hbr : b < r :=
      lt_of_le_of_lt (le_trans hbu₀.le (le_trans hu₀r₀ hge)) hs₁r
    obtain ⟨r', hr's, hrr', hnP'⟩ := hout r hrs hbr hnr
    exact hnP' (hbelow r' (lt_of_lt_of_le hs₁r hrr') hr's)

/-- **`C'`'s monadic form** — *"I am at a point within a `∼`-class before some `¬β` in that
class"*, the mirror of `afterNotHoldsInClassFormula`.

De Bruijn layout: free variable `0` is `x`; under `∃v` the indices are `0 = v`, `1 = x`. -/
def beforeNotHoldsInClassFormula (ε : MonadicFormula sig 2) (β : MonadicFormula sig 1) :
    MonadicFormula sig 1 :=
  .ex (.and (epsAt ε 1 0) (.and (.lt 1 0) (.not (atVar β 0))))

/-- **What `C'` says.** -/
def BeforeNotHoldsInClass (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (P : M.carrier → Prop) (t : M.carrier) : Prop :=
  ∃ v : M.carrier, ContempEquivDense M ε t v ∧ t < v ∧ ¬ P v

/-- **The `C'` transcription is correct** — checked, not asserted. -/
theorem beforeNotHoldsInClassFormula_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (β : MonadicFormula sig 1) (t : M.carrier) :
    eval M (fun _ => t) (beforeNotHoldsInClassFormula ε β) ↔
      BeforeNotHoldsInClass M ε (fun v => eval M (fun _ => v) β) t := by
  simp only [beforeNotHoldsInClassFormula, BeforeNotHoldsInClass, eval, eval_epsAt, eval_atVar,
    Fin.cons_zero, b2_one]

/-- **`C'` is downward closed in a class** — the mirror of `afterNotHoldsInClass_of_le`. -/
theorem beforeNotHoldsInClass_of_le {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (P : M.carrier → Prop) {t u : M.carrier}
    (htu : ContempEquivDense M ε t u) (hle : u ≤ t) (ht : BeforeNotHoldsInClass M ε P t) :
    BeforeNotHoldsInClass M ε P u := by
  obtain ⟨v, hvc, htv, hnv⟩ := ht
  exact ⟨v, contemp_trans hε M (contemp_symm hε M htu) hvc, lt_of_le_of_lt hle htv, hnv⟩

section Lemma7Mirror

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds' `C'`** — the mirror of `afterNotHoldsInClassTemporal`. -/
noncomputable def beforeNotHoldsInClassTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (B : Formula) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (beforeNotHoldsInClassFormula ε (temporalToMonadic atomMap B))).val

/-- **What `C'` holds of**, in every Prior structure. -/
theorem beforeNotHoldsInClassTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (B : Formula) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (beforeNotHoldsInClassTemporal atomMap h_surj ε B) ↔
      BeforeNotHoldsInClass M ε (fun v => TemporalTruth M atomMap v B) t := by
  refine ((uSExpressivelyCompleteOverDensePrior atomMap h_surj
    (beforeNotHoldsInClassFormula ε (temporalToMonadic atomMap B))).property
      M h_prior_U h_prior_S t).symm.trans ?_
  rw [beforeNotHoldsInClassFormula_eval]
  simp only [eval_temporalToMonadic]

/-- **Reynolds 1992, §6 Lemma 7, printed p.180 — first statement, the *end* half.**

> *… Similarly at the end.*

The mirror of `reynolds_lemma7_start`, on Prior-S, `λ` and `C'`. Reynolds prints one word for it;
everything below the statement is therefore this tree's mirror rather than a transcription. -/
theorem reynolds_lemma7_end (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (B : Formula) {a t b : M.carrier}
    (hint : ClassInteriorToBadInterval M ε a t b)
    (hend : ∃ x : M.carrier, ContempEquivDense M ε t x ∧
      ∀ q : M.carrier, ContempEquivDense M ε t q → x < q → TemporalTruth M atomMap q B)
    {u : M.carrier} (hau : a ≤ u) (hub : u ≤ b) : TemporalTruth M atomMap u B := by
  by_contra hnB
  obtain ⟨x, hxc, hxB⟩ := hend
  have hR := hint.toR
  have ht : EndsInGapOnRight M ε t := hR.rThroughout t hR.left_lt.le hR.lt_right.le
  set C := beforeNotHoldsInClassTemporal atomMap h_surj ε B with hCdef
  have hCspec : ∀ z : M.carrier, TemporalTruth M atomMap z C ↔
      BeforeNotHoldsInClass M ε (fun v => TemporalTruth M atomMap v B) z := fun z =>
    beforeNotHoldsInClassTemporal_spec atomMap h_surj ε B M h_prior_U h_prior_S z
  have hIcc : ∀ z w : M.carrier, a ≤ z → z ≤ b → a ≤ w → w ≤ b →
      ∀ q : M.carrier, min z w ≤ q → q ≤ max z w → EndsInGapOnRight M ε q := by
    intro z w hz₁ hz₂ hw₁ hw₂ q hq₁ hq₂
    exact hR.rThroughout q (le_trans (le_min hz₁ hw₁) hq₁) (le_trans hq₂ (max_le hz₂ hw₂))
  have hat : a ≤ t := hR.left_lt.le
  have htb : t ≤ b := hR.lt_right.le
  -- *"By lemma 5, `¬B` also holds somewhere in the class."*
  obtain ⟨p, hpc, hpB⟩ :=
    reynolds_lemma5_first h_surj hε M h_prior_U h_prior_S (Formula.imp B Formula.bot)
      (hIcc u t hau hub hat htb) ⟨u, contemp_refl hε M u, hnB⟩
  have hap : a < p := lt_of_classMate hε M hR.left_lt hR.left_out hpc
  have hpb : p < b := classMate_lt hε M hR.lt_right hR.right_out hpc
  have hLp : EndsInGapOnLeft M ε p := hint.lThroughout p hap.le hpb.le
  obtain ⟨s, hsp, hpsc⟩ := exists_contemp_lt hε M hLp
  have hts : ContempEquivDense M ε t s := contemp_trans hε M hpc hpsc
  have has : a < s := lt_of_classMate hε M hR.left_lt hR.left_out hts
  have hsb : s < b := classMate_lt hε M hR.lt_right hR.right_out hts
  have hLs : EndsInGapOnLeft M ε s := hint.lThroughout s has.le hsb.le
  have hnsa : ¬ ContempEquivDense M ε s a :=
    fun hc => hR.left_out (contemp_trans hε M hts hc)
  -- `hin`: `C'` holds throughout `s`'s class up to `s`.
  have hin : ∀ r : M.carrier, ContempEquivDense M ε s r → r ≤ s →
      TemporalTruth M atomMap r C := by
    intro r hsr hle
    refine (hCspec r).mpr (beforeNotHoldsInClass_of_le hε M _ hsr hle ?_)
    exact ⟨p, contemp_trans hε M (contemp_symm hε M hts) hpc, hsp, hpB⟩
  -- `hout`: `C'` is false arbitrarily soon *before* the gap at the left end.
  have hnCx : ¬ BeforeNotHoldsInClass M ε (fun v => TemporalTruth M atomMap v B) x := by
    rintro ⟨v, hvc, hxv, hnv⟩
    exact hnv (hxB v (contemp_trans hε M hxc hvc) hxv)
  have hout : ∀ w : M.carrier, w < s → a < w → ¬ ContempEquivDense M ε s w →
      ∃ r : M.carrier, r < s ∧ w ≤ r ∧ ¬ TemporalTruth M atomMap r C := by
    intro w hws haw hnsw
    have hax : a < x := lt_of_classMate hε M hR.left_lt hR.left_out hxc
    have hxb : x < b := classMate_lt hε M hR.lt_right hR.right_out hxc
    obtain ⟨w', hw'c, hw'⟩ :=
      reynolds_lemma5_first h_surj hε M h_prior_U h_prior_S (Formula.imp C Formula.bot)
        (hIcc x w hax.le hxb.le haw.le (le_trans hws.le hsb.le))
        ⟨x, contemp_refl hε M x, fun h => hnCx ((hCspec x).mp h)⟩
    refine ⟨max w' w, ?_, le_max_right w' w, ?_⟩
    · have hkey : ∀ z : M.carrier, ContempEquivDense M ε w z → z < s := by
        intro z hwz
        by_contra hcon
        push_neg at hcon
        have hws' : ContempEquivDense M ε w s :=
          contemp_of_between hε M hws.le hcon hwz
        exact hnsw (contemp_symm hε M hws')
      rcases le_total w' w with h | h
      · rw [max_eq_right h]; exact hkey w (contemp_refl hε M w)
      · rw [max_eq_left h]; exact hkey w' hw'c
    · rcases le_total w' w with h | h
      · rw [max_eq_right h]
        intro hCw
        exact hw' ((hCspec w').mpr
          (beforeNotHoldsInClass_of_le hε M _ hw'c h ((hCspec w).mp hCw)))
      · rw [max_eq_left h]; exact hw'
  exact false_of_holds_throughout_class_upto_bounded hε M h_prior_S hLs C has hnsa hin hout

/-- **Reynolds 1992, §6 Lemma 7, printed p.181 — second statement, the *right end* half.** -/
theorem reynolds_lemma7_close_to_right (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (A : Formula) {a t b : M.carrier}
    (hint : ClassInteriorToBadInterval M ε a t b)
    (hsome : ∃ u : M.carrier, a ≤ u ∧ u ≤ b ∧ TemporalTruth M atomMap u A)
    (x : M.carrier) (hxc : ContempEquivDense M ε t x) :
    ∃ q : M.carrier, ContempEquivDense M ε t q ∧ x < q ∧ TemporalTruth M atomMap q A := by
  by_contra hcon
  push_neg at hcon
  obtain ⟨u, hau, hub, hAu⟩ := hsome
  exact reynolds_lemma7_end atomMap h_surj hε M h_prior_U h_prior_S
    (Formula.imp A Formula.bot) hint ⟨x, hxc, fun q hq hxq => hcon q hq hxq⟩ hau hub hAu

/-- **Reynolds 1992, §6 Lemma 7, printed pp.180-181 — both statements.**

> *If a formula `B` is true for a while at the start of a `∼`-class in a bad interval then it
> holds throughout the bad interval. Similarly at the end.*
>
> *If a formula is true anywhere in a bad interval it is true arbitrarily close to each end of
> each class in the interval.*

The four halves assembled, on one class in the interior of a bad interval. -/
theorem reynolds_lemma7 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {a t b : M.carrier}
    (hint : ClassInteriorToBadInterval M ε a t b) :
    (∀ B : Formula, (∃ x : M.carrier, ContempEquivDense M ε t x ∧
        ∀ q : M.carrier, ContempEquivDense M ε t q → q < x → TemporalTruth M atomMap q B) →
      ∀ u : M.carrier, a ≤ u → u ≤ b → TemporalTruth M atomMap u B) ∧
    (∀ B : Formula, (∃ x : M.carrier, ContempEquivDense M ε t x ∧
        ∀ q : M.carrier, ContempEquivDense M ε t q → x < q → TemporalTruth M atomMap q B) →
      ∀ u : M.carrier, a ≤ u → u ≤ b → TemporalTruth M atomMap u B) ∧
    (∀ A : Formula, (∃ u : M.carrier, a ≤ u ∧ u ≤ b ∧ TemporalTruth M atomMap u A) →
      ∀ x : M.carrier, ContempEquivDense M ε t x →
        (∃ q : M.carrier, ContempEquivDense M ε t q ∧ q < x ∧ TemporalTruth M atomMap q A) ∧
        (∃ q : M.carrier, ContempEquivDense M ε t q ∧ x < q ∧
          TemporalTruth M atomMap q A)) := by
  refine ⟨fun B hstart u h₁ h₂ => reynolds_lemma7_start atomMap h_surj hε M h_prior_U h_prior_S
      B hint.toR hstart h₁ h₂,
    fun B hend u h₁ h₂ => reynolds_lemma7_end atomMap h_surj hε M h_prior_U h_prior_S
      B hint hend h₁ h₂,
    fun A hsome x hxc => ⟨?_, ?_⟩⟩
  · exact reynolds_lemma7_close_to_left atomMap h_surj hε M h_prior_U h_prior_S A hint.toR
      hsome x hxc
  · exact reynolds_lemma7_close_to_right atomMap h_surj hε M h_prior_U h_prior_S A hint
      hsome x hxc

/-! ## *"Any bad interval, if bounded, has excluded end points in `M`"*

Printed p.180, the third clause of Lemma 6's statement. This is Lemma 3's argument
(`reynolds_lemma3_right`, `Lemma34.lean:308`) run on `R ∨ L` in place of `R`: Prior-U applied to
the temporal formula `badPointFormula` produces a first non-bad point, which is an element of `M`
excluded from the interval.

Reynolds' *"plainly impossible given `ρ`"* step — the elimination of Prior-U's *last point of the
stretch* disjunct — needs `R` at the boundary point, which is Lemma 6's own first clause. It is
therefore taken as the hypothesis `hbadR` rather than silently assumed. -/

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — third clause.**

> *Any bad interval, if bounded, has excluded end points in `M` (neither `R` nor `L` holds at
> these end points).*

The right-hand end point. `hbadR` is Lemma 6's first clause (*"in any bad interval both `R` and
`L` hold throughout"*) in the form this argument consumes. -/
theorem reynolds_lemma6_right_endpoint (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnRight M ε t)
    (hbadR : ∀ q : M.carrier, t ≤ q → IsBadPoint M ε q → EndsInGapOnRight M ε q)
    (hnot : ∃ u : M.carrier, t < u ∧ ¬ IsBadPoint M ε u) :
    ∃ s : M.carrier, t < s ∧
      (∀ r : M.carrier, t < r → r < s → IsBadPoint M ε r) ∧ ¬ IsBadPoint M ε s := by
  have hspec : ∀ r : M.carrier,
      TemporalTruth M atomMap r (badPointFormula atomMap h_surj ε) ↔ IsBadPoint M ε r :=
    fun r => badPointFormula_spec atomMap h_surj ε M h_prior_U h_prior_S r
  obtain ⟨y, hty, hy⟩ := endsInGapOnRight_forAWhile hε M ht
  have hstretch : ∃ s : M.carrier, t < s ∧
      ∀ r : M.carrier, t < r → r < s →
        TemporalTruth M atomMap r (badPointFormula atomMap h_surj ε) :=
    ⟨y, hty, fun r h₁ h₂ => (hspec r).mpr (IsBadPoint.of_right (hy r h₁ h₂.le))⟩
  obtain ⟨u, htu, hnu⟩ := hnot
  obtain ⟨s, hts, hbelow, hcase⟩ :=
    h_prior_U t (badPointFormula atomMap h_surj ε) hstretch
      ⟨u, htu, fun h => hnu ((hspec u).mp h)⟩
  refine ⟨s, hts, fun r h₁ h₂ => (hspec r).mp (hbelow r h₁ h₂), ?_⟩
  rcases hcase with hns | ⟨hs, hkplus⟩
  · exact fun h => hns ((hspec s).mpr h)
  · exfalso
    have hRs : EndsInGapOnRight M ε s := hbadR s hts.le ((hspec s).mp hs)
    obtain ⟨y', hsy', hy'⟩ := endsInGapOnRight_forAWhile hε M hRs
    obtain ⟨r, hsr, hry', hnr⟩ := hkplus y' hsy'
    exact hnr ((hspec r).mpr (IsBadPoint.of_right (hy' r hsr hry'.le)))

/-! ## *"Using mirror images of the above and previous results"* — the fourth half

Reynolds closes Lemma 6 with that one sentence and no second proof. It is discharged here as an
**instantiation** at `(dual M, dualize ε)` through `DenseModelSurgery/Dual.lean`, which is what
that sentence formalizes: a hand-written mirror would formalize a proof he did not write.

The `λ`-side interval hypothesis has no counterpart in the tree, so it is defined here as the
exact mirror of `ClassInteriorToRInterval`. -/

/-- **`t`'s class lies in the interior of a maximal interval of `L`** — the `λ`-side mirror of
`ClassInteriorToRInterval`, with `EndsInGapOnLeft` in place of `EndsInGapOnRight` and everything
else unchanged.

Like its `ρ`-side original this is a *rendering* rather than a quotation: Reynolds names the
interval and leaves the dual to his p.178 convention. -/
structure ClassInteriorToLInterval (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (a t b : M.carrier) : Prop where
  /-- `a` lies below `t`. -/
  left_lt : a < t
  /-- `b` lies above `t`. -/
  lt_right : t < b
  /-- `a` is outside `t`'s class. -/
  left_out : ¬ ContempEquivDense M ε t a
  /-- `b` is outside `t`'s class. -/
  right_out : ¬ ContempEquivDense M ε t b
  /-- `L` holds throughout `[a, b]`: the whole stretch is inside the one maximal interval. -/
  lThroughout : ∀ q : M.carrier, a ≤ q → q ≤ b → EndsInGapOnLeft M ε q

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — *"using mirror images of the above and previous
results we get our proof"*: `R` holds wherever `L` does.**

The exact mirror of `endsInGapOnLeft_of_endsInGapOnRight`, obtained by instantiating that theorem
at `(dual M, dualize ε)` with the interval endpoints exchanged. The *"previous results"* the
mirrored argument appeals to are supplied by `reynolds_lemma5_first_left`, itself an
instantiation. -/
theorem endsInGapOnRight_of_endsInGapOnLeft (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {a t b : M.carrier}
    (hint : ClassInteriorToLInterval M ε a t b) :
    EndsInGapOnRight M ε t := by
  have hint' : ClassInteriorToRInterval (dual M) (dualize ε) (d b) (d t) (d a) :=
    { left_lt := hint.lt_right
      lt_right := hint.left_lt
      left_out := fun h => hint.right_out ((contempEquivDense_dual (M := M) ε t b).mp h)
      right_out := fun h => hint.left_out ((contempEquivDense_dual (M := M) ε t a).mp h)
      rThroughout := fun q h₁ h₂ =>
        (endsInGapOnRight_dual (M := M) ε q).mpr (hint.lThroughout q h₂ h₁) }
  exact (endsInGapOnLeft_dual (M := M) ε t).mp
    (endsInGapOnLeft_of_endsInGapOnRight atomMap h_surj (isContempEquivDense_dualize hε) (dual M)
      (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U) hint')

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — all four halves.**

> *Bad points only occur in non-singleton bad intervals.*
>
> *In any bad interval both `R` and `L` hold throughout. Any bad interval, if bounded, has
> excluded end points in `M` (neither `R` nor `L` holds at these end points).*

Four halves. The first three are read off a class in the interior of a maximal interval of `R`:

1. the point is not an isolated bad point;
2. `L` holds wherever `R` does — Reynolds' *"we first show that `L` holds wherever `R` does"*;
3. the interval, if bounded on the right, has an excluded end point in `M`.

The **fourth** is Reynolds' closing *"using mirror images of the above and previous results we get
my proof"* — `R` wherever `L` holds. It takes the `λ`-side interval as its own hypothesis, since
nothing about a maximal interval of `R` supplies one, and is discharged by
`endsInGapOnRight_of_endsInGapOnLeft`.

**Standing caveat.** Like every §6 result below Lemma 2 this is **conditional**:
`IsContempEquivDense ε` together with Prior-U/Prior-S are hypotheses, and the only `ε` this tree
can currently exhibit satisfying them is `epsTop`, for which `EndsInGapOnRight` is empty. There
is no live non-trivial instance yet, and nothing here is discharged in the unconditional
sense. -/
theorem reynolds_lemma6 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {a t b : M.carrier}
    (hint : ClassInteriorToRInterval M ε a t b) :
    (∃ y : M.carrier, t < y ∧ ∀ r : M.carrier, t < r → r ≤ y → IsBadPoint M ε r) ∧
    EndsInGapOnLeft M ε t ∧
    ((∀ q : M.carrier, t ≤ q → IsBadPoint M ε q → EndsInGapOnRight M ε q) →
      (∃ u : M.carrier, t < u ∧ ¬ IsBadPoint M ε u) →
      ∃ s : M.carrier, t < s ∧
        (∀ r : M.carrier, t < r → r < s → IsBadPoint M ε r) ∧ ¬ IsBadPoint M ε s) ∧
    (∀ a' b' : M.carrier, ClassInteriorToLInterval M ε a' t b' → EndsInGapOnRight M ε t) := by
  have ht : EndsInGapOnRight M ε t :=
    hint.rThroughout t hint.left_lt.le hint.lt_right.le
  exact ⟨reynolds_lemma6_nonsingleton hε M ht,
    endsInGapOnLeft_of_endsInGapOnRight atomMap h_surj hε M h_prior_U h_prior_S hint,
    fun hbadR hnot =>
      reynolds_lemma6_right_endpoint atomMap h_surj hε M h_prior_U h_prior_S ht hbadR hnot,
    fun _ _ hintL =>
      endsInGapOnRight_of_endsInGapOnLeft atomMap h_surj hε M h_prior_U h_prior_S hintL⟩

/-! ## The interval witness, and Lemma 6's first clause without it

`ClassInteriorToRInterval` and `ClassInteriorToLInterval` were introduced above as *hypotheses*,
and nothing in this tree produced one on either side. `exists_classInteriorToRInterval` below is
that producer. It is what Reynolds' Lemma 4 was supposed to supply and — with the display as
printed — could not; see the *"Lemma 4 at the boundary"* section of `Lemma34.lean` for the
one-symbol defect in the source that blocked it, and for the repaired reading that unblocks it.

With the producer in hand, both halves of Lemma 6's first clause become hypothesis-free. -/

/-- **The interval witness, produced.** Wherever `R` holds, `t`'s class lies in the interior of a
maximal interval of `R`: there are `a < t < b` outside `t`'s class with `R` throughout `[a, b]`.

The **upper** endpoint is `reynolds_lemma4_no_last_class` used as it stands. The **lower** endpoint
is where the repaired Lemma 4 pays: negating `reynolds_lemma4_no_first_class_closed` gives a `y`
below `t`, outside `t`'s class, with `R` throughout the **closed** `[y, t)`, which is what
`rThroughout`'s closed `[a, b]` demands. The faithful strict form gives only the **open** `(y, t)`,
and shrinking `a` into `(y, t)` is unavailable in exactly the configuration where `t`'s class
begins immediately after `y ∈ M` — the boundary case documented in `Lemma34.lean`. -/
theorem exists_classInteriorToRInterval (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    ∃ a b : M.carrier, ClassInteriorToRInterval M ε a t b := by
  obtain ⟨b, htb, hnb, hIccb⟩ :=
    reynolds_lemma4_no_last_class atomMap h_surj hε M h_prior_U h_prior_S ht
  have hnf := reynolds_lemma4_no_first_class_closed atomMap h_surj hε M h_prior_U h_prior_S t
  have hlow : ∃ y : M.carrier, y < t ∧ ¬ ContempEquivDense M ε t y ∧
      ∀ z : M.carrier, y ≤ z → z < t → EndsInGapOnRight M ε z := by
    by_contra hcon
    push_neg at hcon
    refine hnf ⟨ht, fun y hy hny => ?_⟩
    obtain ⟨z, hyz, hzt, hnz⟩ := hcon y hy hny
    exact ⟨z, hyz, hzt, hnz⟩
  obtain ⟨a, hat, hna, hIcca⟩ := hlow
  have hR : ∀ q : M.carrier, a ≤ q → q ≤ b → EndsInGapOnRight M ε q := by
    intro q h₁ h₂
    rcases lt_or_ge q t with h | h
    · exact hIcca q h₁ h
    · exact hIccb q h h₂
  exact ⟨a, b, ⟨hat, htb, hna, hnb, hR⟩⟩

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — *"we first show that `L` holds wherever `R`
does"*, with no interval hypothesis.**

`endsInGapOnLeft_of_endsInGapOnRight` above is Reynolds' five-paragraph argument; this is that
theorem with its hypothesis discharged by `exists_classInteriorToRInterval`. The original is kept
unchanged for callers that already hold an interval witness. -/
theorem endsInGapOnLeft_of_endsInGapOnRight' (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    EndsInGapOnLeft M ε t := by
  obtain ⟨a, b, hint⟩ :=
    exists_classInteriorToRInterval atomMap h_surj hε M h_prior_U h_prior_S ht
  exact endsInGapOnLeft_of_endsInGapOnRight atomMap h_surj hε M h_prior_U h_prior_S hint

/-- **Reynolds 1992, §6 Lemma 6, printed p.180 — *"using mirror images"*, with no interval
hypothesis.**

By instantiation at `(dual M, dualize ε)` through `Dual.lean`, exactly as
`endsInGapOnRight_of_endsInGapOnLeft` is. This is the third use of the transport layer, and no
`λ`-side interval witness is needed: the `ρ`-side producer above supplies the dual one. -/
theorem endsInGapOnRight_of_endsInGapOnLeft' (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) {t : M.carrier} (ht : EndsInGapOnLeft M ε t) :
    EndsInGapOnRight M ε t :=
  (endsInGapOnLeft_dual (M := M) ε t).mp
    (endsInGapOnLeft_of_endsInGapOnRight' atomMap h_surj (isContempEquivDense_dualize hε) (dual M)
      (semanticPriorU_dual h_prior_S) (semanticPriorS_dual h_prior_U)
      ((endsInGapOnRight_dual (M := M) ε t).mpr ht))

end Lemma7Mirror

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
