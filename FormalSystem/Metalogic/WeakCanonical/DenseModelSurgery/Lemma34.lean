/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Defs

/-!
# Reynolds §6 Lemmas 3 and 4: maximal `R`-intervals

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§6 *"No gaps between equivalence classes"*, printed pp.178-179.

This module continues `Defs.lean` (§6 vocabulary, `ρ`, `λ`, Lemma 2) with the next two lemmas.
Both are statements about the set where Reynolds' `R` holds; by `gapRightFormula_spec`
(`Defs.lean:384`) that set is, in any Prior structure, exactly `EndsInGapOnRight M ε`, so the
whole development below is carried out on that semantic predicate and transported to the temporal
formula `R` where Reynolds transports it — namely at each application of Prior-U and Prior-S.

## The source, verbatim

Printed p.178, the standing hypothesis under which §6's remaining lemmas are stated:

> Now suppose that `M` is a Prior structure and that `∼ = ∼_M` is a contemporaneous equivalence
> relation defined by `ε`. Although we will only need to consider densely ordered `M` for the real
> numbers proof, it will be seen that we prove the result for any Prior structure.

Printed p.178, **Lemma 3**:

> **LEMMA 3** *The maximal intervals in which `R` holds are open intervals which, if bounded, have
> elements of `M` as their (excluded) end points.*
>
> **PROOF.** Suppose that `R` holds at `t ∈ M`. Clearly `ρ` holding at `t` implies that `R` will
> hold for a while after `t`: up until a gap in fact. Thus `t` is in a non-singleton interval of
> `R`. It is possible that `R` holds for ever after `t`.
>
> If `R` does not hold for ever after `t` then Prior-U applied to `R` implies that `M` contains a
> last point of this stretch of `R` (plainly impossible given `ρ`) or a first point of `¬R`. This
> is as claimed.
>
> Now look to the left of `t`. Looking back from just after `t` we can use Prior-S and see that
> either `R` is true always before `t`, there is a last point of `¬R` just before this stretch of
> `R` or there is no last point of `¬R`, but instead a first point of `R`. We must rule out the
> third case. Note that in the case of `M` not being dense there may be both a last point of `¬R`
> and a first point of `R`: this possibility, subsumed in the second case above, is acceptable in
> that it implies an excluded end point.
>
> Suppose, for contradiction, that `s` is this first point of `R` so that
> `M ⊨ (R ∧ K⁻(¬R))(s)`. The `∼`-class containing `s` can not stretch for ever into the future for
> then it does not end in a gap. Neither can it stretch to the end of the maximal interval of `R`
> as it would again not end at a gap.
>
> Thus there are other classes in this interval continuing on the other side of the gap which ends
> `s`'s. And for a while after the gap `R` continues to be true: we have not reached the end of the
> interval yet. Thus `R ∧ K⁻(¬R)` does not hold at the left hand end of any of these classes.
>
> Let `B` be the temporal formula saying that the `∼`-class we are now in begins with a point
> satisfying `R ∧ K⁻(¬R)`. `B` exists by expressive completeness. `B` holds in `s`'s class up to
> the gap and is false arbitrarily soon after the gap. This contradicts Prior-U applied to `B`. ∎

Printed pp.178-179, **Lemma 4**:

> **LEMMA 4** *There is no last class and no first class in any maximal interval of `R`.*
>
> **PROOF.** The last class in a maximal interval of `R` wouldn't end in a gap.
>
> By expressive completeness, the formula
>
> ```
> ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))
> ```
>
> has a temporal equivalent which is true only in the first classes of maximal intervals of `R`.
> If there is a first class then no immediately subsequent classes satisfy this and so we have this
> formula holding up to a gap and false arbitrarily soon afterwards. This contradicts Prior-U. ∎

## CORRECTION TO THE LOCAL CORPUS — Lemma 4's formula

This is the **second** corpus defect found in §6; the first, `ρ`'s missing middle conjunct, is
recorded in `Defs.lean`'s header. The pre-segmented chunk
`~/Projects/Literature/sources/reynolds_1992/sec03_6-no-gaps-between-equivalence-classes.md`
renders Lemma 4's displayed formula as

```
ρ(x) ∧ ∀y < x (y < z < x ∧ ε(y, z))
```

which differs from the printed page in four independent places:

1. the implication is gone — the printed matrix is `¬ε(x,y) → …`, and the corpus has dropped the
   entire antecedent, turning a conditional into an assertion;
2. the `∃z` binder is gone, leaving `z` **free** in what is presented as a formula of one free
   variable — the corpus text is not even well-formed;
3. the consequent's predicate is wrong: the printed text has `¬ρ(z)`, a one-place predicate about
   `z` alone, and the corpus has `ε(y,z)`, a two-place predicate about `y` and `z`;
4. consequently the quantifier nesting is flattened.

The formula transcribed below is the printed one, read off the page image of the source PDF
(`Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`, PDF page index 15 = printed p.179)
rather than off the markdown chunk. The text layer of that page is degraded at exactly this
display formula, rendering it as `p(x) A vy <    z(y < z < x A` — so neither the chunk nor
`pdftotext` is usable here and the image is the only reliable witness.

The corrected formula is also the only one that *means* what Reynolds says it means. Read out:
`x`'s class ends in a gap on the right, and every `y` below `x` that is **not** in `x`'s class has
a point `z` between it and `x` at which `ρ` fails — i.e. at which `R` is false. That is exactly
"there is no earlier class in `x`'s maximal `R`-interval", which is Reynolds' stated reading,
*"true only in the first classes of maximal intervals of `R`"*. The corpus version, with `z` free
and `ε(y,z)` in place of `¬ρ(z)`, says nothing of the kind.

Plan v8's Phase 18 task list quotes the corrupted form (*"the temporal equivalent of
`ρ(x) ∧ ∀y<x (y<z<x ∧ ε(y,z))`"*). Per the standing literature-fidelity directive the printed
formula wins and the plan premise is reported as a deviation rather than silently followed.

## What is and is not a transcription here

Reynolds states Lemma 3 as one sentence about "the maximal intervals in which `R` holds". His
*proof* establishes three separable facts, and this module lands them as three named theorems plus
the assembled statement, so that a reader can check the transcription proof-step by proof-step:

| Reynolds' proof step | In-tree name |
|---|---|
| *"`ρ` holding at `t` implies that `R` will hold for a while after `t`"* | `endsInGapOnRight_forAWhile` |
| *"Prior-U applied to `R` … a first point of `¬R`"* | `reynolds_lemma3_right` |
| *"we must rule out the third case"* (no first point of `R`) | `reynolds_lemma3_no_first_point` |
| *"Prior-S … a last point of `¬R` just before this stretch"* | `reynolds_lemma3_left` |
| the assembled statement | `reynolds_lemma3` |

"Open interval" is rendered as: `R` holds on a two-sided neighbourhood of each of its points
(`reynolds_lemma3_open`). "If bounded, have elements of `M` as their (excluded) end points" is
rendered as the pair `reynolds_lemma3_right` / `reynolds_lemma3_left`: whenever `¬R` holds
somewhere above (resp. below) a point of the interval, there is a point **of `M`** bounding the
stretch at which `R` is false — so the endpoint is an element of `M` and is excluded, rather than
being a gap. These renderings are this tree's, not Reynolds' words; the words are quoted above.

## Auxiliary formulas are named, not inlined

Reynolds' §6 proofs repeatedly say *"by expressive completeness there is a temporal formula
saying …"*. Each such formula is landed here as a **named** monadic definition together with its
temporal equivalent and a specification theorem, rather than being produced inline inside a proof:

- `classBeginsAtGapStartFormula` / `classBeginsAtGapStartTemporal` — Lemma 3's `B`, *"the `∼`-class
  we are now in begins with a point satisfying `R ∧ K⁻(¬R)`"*;
- `firstClassFormula` / `firstClassTemporal` — Lemma 4's displayed formula.

Lemmas 5-8 (Phases 19-21) each need one or two more of these, and the pattern established here is
what makes them cheap.

## References

- Reynolds 1992, §6, printed pp.178-179 (Lemmas 3 and 4)
- `Defs.lean` — `ρ`, `λ`, `EndsInGapOnRight`, `gapRightFormula`, Lemma 2
- `SemanticPriorU` / `SemanticPriorS` (`PriorDefsDense.lean:119`, `:138`) — Reynolds' Prior-U and
  Prior-S, printed p.168, in the semantic form the proofs below apply them in
-/

namespace FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

open FormalSystem.Syntax FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! ## `∼` in usable form

`IsContempEquivDense` packages Reynolds' three clauses as a structure. The proofs below use them
constantly and in a handful of fixed shapes; those shapes are named once here. -/

section ClassCalculus

variable {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
  (M : OrderedMonadicStructure sig)

include hε in
/-- Clause (i), reflexivity. -/
theorem contemp_refl (a : M.carrier) : ContempEquivDense M ε a a := (hε.equiv M).refl a

include hε in
/-- Clause (i), symmetry. -/
theorem contemp_symm {a b : M.carrier} (h : ContempEquivDense M ε a b) :
    ContempEquivDense M ε b a := (hε.equiv M).symm h

include hε in
/-- Clause (i), transitivity. -/
theorem contemp_trans {a b c : M.carrier} (h₁ : ContempEquivDense M ε a b)
    (h₂ : ContempEquivDense M ε b c) : ContempEquivDense M ε a c := (hε.equiv M).trans h₁ h₂

include hε in
/-- Class-mates have the same class: the workhorse rewriting step. -/
theorem contemp_congr_left {a b c : M.carrier} (hab : ContempEquivDense M ε a b) :
    ContempEquivDense M ε a c ↔ ContempEquivDense M ε b c :=
  ⟨fun h => contemp_trans hε M (contemp_symm hε M hab) h, fun h => contemp_trans hε M hab h⟩

include hε in
/-- Clause (ii), *"`∼_M` partitions `M` into intervals"*: anything between two class-mates is a
class-mate of both. -/
theorem contemp_of_between {a b c : M.carrier} (hab : a ≤ b) (hbc : b ≤ c)
    (hac : ContempEquivDense M ε a c) : ContempEquivDense M ε a b :=
  hε.convex M a b c hab hbc hac

end ClassCalculus

/-! ## `ρ` is a property of the class, not of the point

Reynolds uses this without comment throughout §6 — *"the `∼`-class containing `s` can not stretch
for ever into the future"* treats "ends in a gap on the right" as a property of the class. It is
worth proving rather than assuming, because `EndsInGapOnRight`'s third conjunct mentions the point
`t` itself and not only its class. -/

section ClassInvariance

variable {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
  (M : OrderedMonadicStructure sig)

include hε in
private theorem endsInGapOnRight_of_contemp {t u : M.carrier}
    (htu : ContempEquivDense M ε t u) (h : EndsInGapOnRight M ε t) :
    EndsInGapOnRight M ε u := by
  obtain ⟨⟨y₀, hty₀, hny₀⟩, h2, h3⟩ := h
  have key : ∀ c : M.carrier, ContempEquivDense M ε t c ↔ ContempEquivDense M ε u c :=
    fun _ => contemp_congr_left hε M htu
  refine ⟨⟨y₀, ?_, fun hc => hny₀ ((key y₀).mpr hc)⟩, ?_, ?_⟩
  · by_contra hle
    push_neg at hle
    exact hny₀ (contemp_of_between hε M hty₀.le hle htu)
  · rintro ⟨z, hz, hz2⟩
    exact h2 ⟨z, (key z).mpr hz, fun y hy hc => hz2 y hy ((key y).mp hc)⟩
  · rintro ⟨z, huz, hnz, hall⟩
    refine h3 ⟨z, ?_, fun hc => hnz ((key z).mp hc), ?_⟩
    · by_contra hle
      push_neg at hle
      exact hnz (contemp_of_between hε M huz.le hle (contemp_symm hε M htu))
    · intro y hty hyz
      rcases le_or_gt y u with hyu | huy
      · exact contemp_of_between hε M hty.le hyu htu
      · exact (key y).mpr (hall y huy hyz)

include hε in
/-- **"Ends in a gap on the right" is a property of the `∼`-class.**

Used silently by Reynolds at every step of §6 that speaks of *the class* ending in a gap. -/
theorem endsInGapOnRight_congr {t u : M.carrier} (htu : ContempEquivDense M ε t u) :
    EndsInGapOnRight M ε t ↔ EndsInGapOnRight M ε u :=
  ⟨endsInGapOnRight_of_contemp hε M htu,
    endsInGapOnRight_of_contemp hε M (contemp_symm hε M htu)⟩

end ClassInvariance

/-! ## *"`R` will hold for a while after `t`"*

Reynolds' first proof step in Lemma 3, and the step that makes `t` interior on the right. -/

section ForAWhile

variable {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
  (M : OrderedMonadicStructure sig)

include hε in
/-- **The class has no last point**, in the form the proofs use: `ρ(t)`'s *second* conjunct,
instantiated at `z := t` and combined with reflexivity, produces a class-mate strictly above `t`.

This is the conjunct the local corpus omits entirely (see `Defs.lean`'s header); without it there
is no route to *"`R` will hold for a while after `t`"* at all, which is a second, independent
reason the corpus text cannot be used. -/
theorem exists_contemp_gt {t : M.carrier} (h : EndsInGapOnRight M ε t) :
    ∃ y : M.carrier, t < y ∧ ContempEquivDense M ε t y := by
  by_contra hcon
  push_neg at hcon
  exact h.2.1 ⟨t, contemp_refl hε M t, fun y hy => hcon y hy⟩

include hε in
/-- **Reynolds 1992, printed p.178**: *"Clearly `ρ` holding at `t` implies that `R` will hold for a
while after `t`: up until a gap in fact. Thus `t` is in a non-singleton interval of `R`."*

The class has no last point, so it contains some `y > t`; everything in `[t, y]` is in the class by
convexity, and `ρ` is a property of the class. -/
theorem endsInGapOnRight_forAWhile {t : M.carrier} (h : EndsInGapOnRight M ε t) :
    ∃ y : M.carrier, t < y ∧ ∀ r : M.carrier, t < r → r ≤ y → EndsInGapOnRight M ε r := by
  obtain ⟨y, hty, hcy⟩ := exists_contemp_gt hε M h
  refine ⟨y, hty, fun r htr hry => ?_⟩
  exact (endsInGapOnRight_congr hε M (contemp_of_between hε M htr.le hry hcy)).mp h

end ForAWhile

/-! ## Lemma 3, the right-hand end point

*"If `R` does not hold for ever after `t` then Prior-U applied to `R` implies that `M` contains a
last point of this stretch of `R` (plainly impossible given `ρ`) or a first point of `¬R`."*

Prior-U is applied to the temporal formula `R`, exactly as printed; `gapRightFormula_spec` is what
carries its conclusion back to `EndsInGapOnRight`. -/

section RightEnd

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds 1992, §6 Lemma 3, printed p.178 — the right-hand end point.**

If `R` holds at `t` and fails somewhere above `t`, then there is a point `s` of `M` with `R`
throughout `(t, s)` and `¬R` at `s`: *"a first point of `¬R`"*. The end point is therefore an
element of `M` and is excluded from the interval, which is what the lemma claims for a bounded
maximal interval.

Reynolds' *"plainly impossible given `ρ`"* — the elimination of Prior-U's other disjunct, a last
point of the `R`-stretch — is discharged here by `endsInGapOnRight_forAWhile`: at such a last point
`R` would still hold, hence `R` would hold on a whole interval above it, contradicting the
`K⁺(¬R)` clause that the disjunct asserts. -/
theorem reynolds_lemma3_right (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {t : M.carrier} (ht : EndsInGapOnRight M ε t)
    (hnot : ∃ u : M.carrier, t < u ∧ ¬ EndsInGapOnRight M ε u) :
    ∃ s : M.carrier, t < s ∧
      (∀ r : M.carrier, t < r → r < s → EndsInGapOnRight M ε r) ∧
      ¬ EndsInGapOnRight M ε s := by
  have hspec : ∀ r : M.carrier,
      TemporalTruth M atomMap r (gapRightFormula atomMap h_surj ε) ↔ EndsInGapOnRight M ε r :=
    fun r => gapRightFormula_spec atomMap h_surj ε M h_prior_U h_prior_S r
  -- The `U(⊤,R)` antecedent of Prior-U: `R` holds for a while after `t`.
  obtain ⟨y, hty, hy⟩ := endsInGapOnRight_forAWhile hε M ht
  have hstretch : ∃ s : M.carrier, t < s ∧
      ∀ r : M.carrier, t < r → r < s →
        TemporalTruth M atomMap r (gapRightFormula atomMap h_surj ε) :=
    ⟨y, hty, fun r h₁ h₂ => (hspec r).mpr (hy r h₁ h₂.le)⟩
  -- The `F¬R` antecedent of Prior-U.
  obtain ⟨u, htu, hnu⟩ := hnot
  have hfail : ∃ u : M.carrier, t < u ∧
      ¬ TemporalTruth M atomMap u (gapRightFormula atomMap h_surj ε) :=
    ⟨u, htu, fun h => hnu ((hspec u).mp h)⟩
  obtain ⟨s, hts, hbelow, hcase⟩ :=
    h_prior_U t (gapRightFormula atomMap h_surj ε) hstretch hfail
  refine ⟨s, hts, fun r h₁ h₂ => (hspec r).mp (hbelow r h₁ h₂), ?_⟩
  rcases hcase with hns | ⟨hs, hkplus⟩
  · exact fun h => hns ((hspec s).mpr h)
  · -- *"a last point of this stretch of `R` (plainly impossible given `ρ`)"*.
    exfalso
    obtain ⟨y', hsy', hy'⟩ := endsInGapOnRight_forAWhile hε M ((hspec s).mp hs)
    obtain ⟨r, hsr, hry', hnr⟩ := hkplus y' hsy'
    exact hnr ((hspec r).mpr (hy' r hsr hry'.le))

end RightEnd

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
