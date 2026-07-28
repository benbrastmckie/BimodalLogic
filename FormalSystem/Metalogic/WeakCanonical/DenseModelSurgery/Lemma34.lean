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

/-! ## `ρ` at an arbitrary variable

Reynolds' auxiliary formulas quantify over points and then assert `ρ` (equivalently `R`) of the
bound variable. `rhoAt` places `ρ`'s single free variable at a chosen De Bruijn index, exactly as
`epsAt` (`Defs.lean:197`) does for `ε`'s two. -/

/-- `ρ` with its free variable reindexed to `i`. -/
def rhoAt {n : Nat} (ε : MonadicFormula sig 2) (i : Fin n) : MonadicFormula sig n :=
  (rhoFormula ε).rename ![i]

/-- Evaluating a reindexed `ρ` is *"the class ends in a gap on the right"* at the reindexed
point. -/
@[simp] theorem eval_rhoAt {n : Nat} (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (env : Fin n → M.carrier) (i : Fin n) :
    eval M env (rhoAt ε i) ↔ EndsInGapOnRight M ε (env i) := by
  unfold rhoAt
  rw [Kamp.eval_rename]
  have h : env ∘ ![i] = (fun _ : Fin 1 => env i) := by
    funext k; fin_cases k; rfl
  rw [h, rhoFormula_eval]

/-! ## Environment lookups

The auxiliary formulas below sit under up to three nested binders; these are the index lookups
that `simp` needs in order to check each transcription against its intended meaning. -/

section EnvLookup

variable {α : Type*}

private theorem c2_one (x t : α) : (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → α) 1 = t := rfl

private theorem c3_one (y x t : α) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → α) 1 = x := rfl

private theorem c3_two (y x t : α) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → α) 2 = t := rfl

private theorem c4_one (z y x t : α) :
    (Fin.cons z (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t))) : Fin 4 → α) 1 = y := rfl

private theorem c4_two (z y x t : α) :
    (Fin.cons z (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t))) : Fin 4 → α) 2 = x := rfl

private theorem c4_three (z y x t : α) :
    (Fin.cons z (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t))) : Fin 4 → α) 3 = t := rfl

end EnvLookup

/-! ## Lemma 3's auxiliary formula `B`

*"Let `B` be the temporal formula saying that the `∼`-class we are now in begins with a point
satisfying `R ∧ K⁻(¬R)`. `B` exists by expressive completeness."* (printed p.178)

Reynolds names `B` and leaves it at that. Written out, *"the class we are now in begins with `w`"*
is *"`w` is in `x`'s class and nothing in `x`'s class is below `w`"*, and `K⁻(¬R)(w)` — `¬R`
accumulating from below at `w` — is monadically `∀u < w ∃r(u < r < w ∧ ¬ρ(r))`, since `R` and `ρ`
agree in every Prior structure by Lemma 2. So `B`'s monadic source is

```
∃w( ε(x,w) ∧ ∀v(ε(x,v) → ¬ v < w) ∧ ρ(w) ∧ ∀u(u < w → ∃r(u < r ∧ r < w ∧ ¬ρ(r))) )
```

and `B` itself is its temporal equivalent. The three displayed conjuncts inside the scope of `∃w`
are, in order, *"`w` is in our class"*, *"`w` begins it"*, and *"`R ∧ K⁻(¬R)` holds at `w`"*.

This is landed as a named definition with a named semantic reading and a checked `eval` theorem,
rather than being produced inline inside Lemma 3's proof: Lemmas 5-8 (Phases 19-21) each need
formulas of exactly this shape, and `classBeginsAtGapStartFormula` is the pattern they follow. -/

/-- **Lemma 3's `B`, as a monadic formula** — *"the `∼`-class we are now in begins with a point
satisfying `R ∧ K⁻(¬R)`"* (printed p.178).

De Bruijn layout: free variable `0` is `x`. Under `∃w` the indices are `0 = w`, `1 = x`; under a
further `∀v` (or `∀u`) they are `0 = v`, `1 = w`, `2 = x`; under `∃r` inside `∀u` they are
`0 = r`, `1 = u`, `2 = w`, `3 = x`. -/
def classBeginsAtGapStartFormula (ε : MonadicFormula sig 2) : MonadicFormula sig 1 :=
  .ex
    (.and (epsAt ε 1 0)
      (.and (.all (.imp (epsAt ε 2 0) (.not (.lt 0 1))))
        (.and (rhoAt ε 0)
          (.all (.imp (.lt 0 1)
            (.ex (.and (.lt 1 0) (.and (.lt 0 2) (.not (rhoAt ε 0))))))))))

/-- **What `B` says** — the semantic reading of `classBeginsAtGapStartFormula`, in Reynolds'
words: `t`'s class has a least element `w`, and `R ∧ K⁻(¬R)` holds at `w`.

*"Begins with `w`"* is rendered as the printed `¬ v < w` rather than as `w ≤ v`; on a linear order
the two agree, and the negated form is what the monadic transcription literally contains. -/
def ClassBeginsAtGapStart (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) : Prop :=
  ∃ w : M.carrier, ContempEquivDense M ε t w ∧
    (∀ v : M.carrier, ContempEquivDense M ε t v → ¬ v < w) ∧
    EndsInGapOnRight M ε w ∧
    (∀ u : M.carrier, u < w → ∃ r : M.carrier, u < r ∧ r < w ∧ ¬ EndsInGapOnRight M ε r)

/-- **The `B` transcription is correct**: checked, not asserted, exactly as `rhoFormula_eval`
checks `ρ`. -/
theorem classBeginsAtGapStartFormula_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) :
    eval M (fun _ => t) (classBeginsAtGapStartFormula ε) ↔ ClassBeginsAtGapStart M ε t := by
  simp only [classBeginsAtGapStartFormula, ClassBeginsAtGapStart, eval, eval_imp, eval_epsAt,
    eval_rhoAt, Fin.cons_zero, c2_one, c3_one, c3_two, c4_one, c4_two, c4_three, and_imp]

section BTemporal

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Lemma 3's `B`, as a temporal formula.** *"`B` exists by expressive completeness"* — this is
that application, to `classBeginsAtGapStartFormula`.

As with `gapRightFormula` (`Defs.lean:367`), `B` is produced before any structure is supplied, so
one `B` serves every Prior structure. -/
noncomputable def classBeginsAtGapStartTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (classBeginsAtGapStartFormula ε)).val

/-- **`B` holds exactly where the class begins with a point satisfying `R ∧ K⁻(¬R)`**, in every
Prior structure. -/
theorem classBeginsAtGapStartTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (classBeginsAtGapStartTemporal atomMap h_surj ε) ↔
      ClassBeginsAtGapStart M ε t :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj (classBeginsAtGapStartFormula ε)).property
    M h_prior_U h_prior_S t).symm.trans (classBeginsAtGapStartFormula_eval M ε t)

end BTemporal

/-! ## Lemma 3, the left-hand end point

*"Now look to the left of `t`. Looking back from just after `t` we can use Prior-S and see that
either `R` is true always before `t`, there is a last point of `¬R` just before this stretch of `R`
or there is no last point of `¬R`, but instead a first point of `R`. We must rule out the third
case."* (printed p.178)

The third case is `reynolds_lemma3_no_first_point`; it is where `B` is used and where the whole of
Reynolds' remaining Lemma 3 paragraph is discharged, step for step. -/

section LeftEnd

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **A point at which `¬R` accumulates from below begins its own class.**

*"Suppose, for contradiction, that `s` is this first point of `R` so that
`M ⊨ (R ∧ K⁻(¬R))(s)`"* — the hypothesis `hk` is that `K⁻(¬R)` clause. A class-mate `v < s` would
put a whole interval `(v, s)` inside the class, where `R` holds, leaving no room for the `¬R`
points `K⁻(¬R)` demands. -/
theorem contemp_not_lt_of_kminus {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {s : M.carrier} (hs : EndsInGapOnRight M ε s)
    (hk : ∀ u : M.carrier, u < s → ∃ r : M.carrier, u < r ∧ r < s ∧ ¬ EndsInGapOnRight M ε r)
    {v : M.carrier} (hv : ContempEquivDense M ε s v) : ¬ v < s := by
  intro hvs
  obtain ⟨r, hvr, hrs, hnr⟩ := hk v hvs
  have hvs' : ContempEquivDense M ε v s := contemp_symm hε M hv
  have hvr' : ContempEquivDense M ε v r := contemp_of_between hε M hvr.le hrs.le hvs'
  exact hnr ((endsInGapOnRight_congr hε M (contemp_trans hε M hv hvr')).mp hs)

/-- **Reynolds 1992, printed p.178**: *"Thus there are other classes in this interval continuing on
the other side of the gap which ends `s`'s. And for a while after the gap `R` continues to be true:
we have not reached the end of the interval yet."*

Rendered as: above `s` there is a point `u` outside `s`'s class with `R` holding throughout the
whole of `[s, u]`. The proof is Reynolds' own case split. Either `R` holds forever after `s`, and
the point `ρ`'s first conjunct supplies works; or it does not, and `reynolds_lemma3_right` produces
the interval's excluded right end point `s'`, at which point either some point of `(s, s')` already
lies outside the class — that one works — or `s'` is *"the first point after the class"*, which is
exactly what `ρ`'s third conjunct forbids. That last branch is Reynolds' *"neither can it stretch
to the end of the maximal interval of `R` as it would again not end at a gap"*. -/
theorem exists_gt_notContemp_holds (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {s : M.carrier} (hs : EndsInGapOnRight M ε s) :
    ∃ u : M.carrier, s < u ∧ ¬ ContempEquivDense M ε s u ∧
      ∀ q : M.carrier, s ≤ q → q ≤ u → EndsInGapOnRight M ε q := by
  obtain ⟨y₀, hsy₀, hny₀⟩ := hs.1
  by_cases hforever : ∀ q : M.carrier, s < q → EndsInGapOnRight M ε q
  · refine ⟨y₀, hsy₀, hny₀, fun q hsq _ => ?_⟩
    rcases eq_or_lt_of_le hsq with rfl | h
    · exact hs
    · exact hforever q h
  · push_neg at hforever
    obtain ⟨s', hss', hbelow, hns'⟩ :=
      reynolds_lemma3_right atomMap h_surj hε M h_prior_U h_prior_S hs hforever
    by_cases hall : ∀ y : M.carrier, s < y → y < s' → ContempEquivDense M ε s y
    · exact absurd
        ⟨s', hss', fun hc => hns' ((endsInGapOnRight_congr hε M hc).mp hs), hall⟩ hs.2.2
    · push_neg at hall
      obtain ⟨u, hsu, hus', hnu⟩ := hall
      refine ⟨u, hsu, hnu, fun q hsq hqu => ?_⟩
      rcases eq_or_lt_of_le hsq with rfl | h
      · exact hs
      · exact hbelow q h (lt_of_le_of_lt hqu hus')

/-- **Reynolds 1992, printed p.178**: *"Thus `R ∧ K⁻(¬R)` does not hold at the left hand end of any
of these classes."*

Rendered as: `B` fails at any point `u` outside `s`'s class with `R` throughout `[s, u]`. If `B`
held at `u`, its witness `w` — the least element of `u`'s class — would lie strictly above `s`, and
the `K⁻(¬R)` clause at `w` would demand a `¬R` point between `s` and `w`, where `R` in fact holds
throughout. -/
theorem not_classBeginsAtGapStart {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {s u : M.carrier} (hsu : s < u)
    (hnu : ¬ ContempEquivDense M ε s u)
    (hIcc : ∀ q : M.carrier, s ≤ q → q ≤ u → EndsInGapOnRight M ε q) :
    ¬ ClassBeginsAtGapStart M ε u := by
  rintro ⟨w, huw, hmin, _hrw, hk⟩
  have hwu : w ≤ u := not_lt.mp (hmin u (contemp_refl hε M u))
  have hsw : s < w := by
    by_contra hle
    push_neg at hle
    have hwu' : ContempEquivDense M ε w u := contemp_symm hε M huw
    have hws : ContempEquivDense M ε w s := contemp_of_between hε M hle hsu.le hwu'
    exact hnu (contemp_trans hε M (contemp_symm hε M hws) hwu')
  obtain ⟨r, hsr, hrw, hnr⟩ := hk s hsw
  exact hnr (hIcc r hsr.le (le_trans hrw.le hwu))

/-- **Reynolds 1992, printed p.178**: *"`B` holds in `s`'s class"* — with `s` itself as the witness
that the class begins with a point satisfying `R ∧ K⁻(¬R)`. -/
theorem classBeginsAtGapStart_of_contemp {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {s t : M.carrier} (hs : EndsInGapOnRight M ε s)
    (hk : ∀ u : M.carrier, u < s → ∃ r : M.carrier, u < r ∧ r < s ∧ ¬ EndsInGapOnRight M ε r)
    (hst : ContempEquivDense M ε s t) : ClassBeginsAtGapStart M ε t :=
  ⟨s, contemp_symm hε M hst,
    fun _ hv => contemp_not_lt_of_kminus hε M hs hk (contemp_trans hε M hst hv),
    hs, hk⟩

/-- **The gap-crossing contradiction**, isolated once.

Reynolds runs the same argument at Lemma 3, at Lemma 4 and again at Lemmas 5 and 7: a formula that
*"holds in `s`'s class up to the gap and is false arbitrarily soon after the gap"* contradicts
Prior-U. Stated once here, with the two side conditions as hypotheses:

- `hin`: `P` holds throughout `s`'s class;
- `hout`: `P` fails at any point beyond the class that still has `R` throughout below it.

The proof is Reynolds': Prior-U applied to `P` at `s` produces a boundary point `s₁` for the
stretch on which `P` holds. `s₁` cannot be in the class, since the class has no last point. So
`(s, s₁)` cannot be inside the class either, or `s₁` would be *"the first point after the class"*,
which `ρ(s)`'s third conjunct forbids. The resulting point of `(s, s₁)` outside the class then has
`P` both true (it is inside Prior-U's stretch) and false (by `hout`).

Landed as a named, reusable theorem rather than repeated inline: Phases 20-21 (Lemmas 6 and 7)
need exactly this step, and it is the one place where Prior-U meets the gap. -/
theorem false_of_holds_throughout_class (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {s : M.carrier} (hs : EndsInGapOnRight M ε s) (P : Formula)
    (hin : ∀ r : M.carrier, ContempEquivDense M ε s r → TemporalTruth M atomMap r P)
    (hout : ∀ u : M.carrier, s < u → ¬ ContempEquivDense M ε s u →
      (∀ q : M.carrier, s ≤ q → q ≤ u → EndsInGapOnRight M ε q) →
      ¬ TemporalTruth M atomMap u P) : False := by
  obtain ⟨u₀, hsu₀, hnu₀, hIcc₀⟩ :=
    exists_gt_notContemp_holds atomMap h_surj hε M h_prior_U h_prior_S hs
  have hnP₀ : ¬ TemporalTruth M atomMap u₀ P := hout u₀ hsu₀ hnu₀ hIcc₀
  obtain ⟨y, hsy, hcy⟩ := exists_contemp_gt hε M hs
  have hstretch : ∃ b : M.carrier, s < b ∧ ∀ r : M.carrier, s < r → r < b →
      TemporalTruth M atomMap r P :=
    ⟨y, hsy, fun r h₁ h₂ => hin r (contemp_of_between hε M h₁.le h₂.le hcy)⟩
  obtain ⟨s₁, hss₁, hbelow, hcase⟩ := h_prior_U s P hstretch ⟨u₀, hsu₀, hnP₀⟩
  have hns₁ : ¬ ContempEquivDense M ε s s₁ := by
    intro hc
    rcases hcase with hn | ⟨_hb, hkplus⟩
    · exact hn (hin s₁ hc)
    · obtain ⟨y', hs₁y', hcy'⟩ :=
        exists_contemp_gt hε M ((endsInGapOnRight_congr hε M hc).mp hs)
      obtain ⟨r, hs₁r, hry', hnr⟩ := hkplus y' hs₁y'
      exact hnr (hin r (contemp_trans hε M hc (contemp_of_between hε M hs₁r.le hry'.le hcy')))
  have hex : ∃ r : M.carrier, s < r ∧ r < s₁ ∧ ¬ ContempEquivDense M ε s r := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨s₁, hss₁, hns₁, fun y h₁ h₂ => hcon y h₁ h₂⟩
  obtain ⟨r, hsr, hrs₁, hnr⟩ := hex
  rcases lt_or_ge u₀ s₁ with hlt | hge
  · exact hnP₀ (hbelow u₀ hsu₀ hlt)
  · exact hout r hsr hnr (fun q h₁ h₂ => hIcc₀ q h₁ (le_trans h₂ (le_trans hrs₁.le hge)))
      (hbelow r hsr hrs₁)

/-- **Reynolds 1992, §6 Lemma 3, printed p.178 — the third case is ruled out.**

> *We must rule out the third case. … Suppose, for contradiction, that `s` is this first point of
> `R` so that `M ⊨ (R ∧ K⁻(¬R))(s)`. … Let `B` be the temporal formula saying that the `∼`-class we
> are now in begins with a point satisfying `R ∧ K⁻(¬R)`. `B` exists by expressive completeness.
> `B` holds in `s`'s class up to the gap and is false arbitrarily soon after the gap. This
> contradicts Prior-U applied to `B`.*

There is no *first point of `R`*: no point at which `R` holds while `¬R` accumulates from below.

Reynolds' *"this contradicts Prior-U"* is the last third of the proof below. Prior-U applied to `B`
at `s` produces a boundary point `s₁` for the stretch on which `B` holds. `s₁` cannot lie in `s`'s
class, because the class has no last point and `B` holds throughout it. So `s₁` lies above the
class — and then `(s, s₁)` cannot be contained in the class either, since `s₁` would be *"the first
point after the class"*, which `ρ(s)`'s third conjunct forbids. The point of `(s, s₁)` outside the
class then has `B` true (it is inside Prior-U's stretch) and `B` false (it is outside the class
with `R` throughout below it). That is the contradiction. -/
theorem reynolds_lemma3_no_first_point (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {s : M.carrier} (hs : EndsInGapOnRight M ε s)
    (hk : ∀ u : M.carrier, u < s → ∃ r : M.carrier, u < r ∧ r < s ∧
      ¬ EndsInGapOnRight M ε r) : False :=
  false_of_holds_throughout_class atomMap h_surj hε M h_prior_U h_prior_S hs
    (classBeginsAtGapStartTemporal atomMap h_surj ε)
    (fun r hr =>
      (classBeginsAtGapStartTemporal_spec atomMap h_surj ε M h_prior_U h_prior_S r).mpr
        (classBeginsAtGapStart_of_contemp hε M hs hk hr))
    (fun u hsu hnu hIcc h =>
      not_classBeginsAtGapStart hε M hsu hnu hIcc
        ((classBeginsAtGapStartTemporal_spec atomMap h_surj ε M h_prior_U h_prior_S u).mp h))

/-- **Reynolds 1992, §6 Lemma 3, printed p.178 — the left-hand end point.**

If `R` holds at `t` and fails somewhere below `t`, then there is a point `s` of `M` with `R`
throughout `(s, t)` and `¬R` at `s`: *"a last point of `¬R` just before this stretch of `R`"*.

Prior-S is applied *"looking back from just after `t`"*, exactly as printed: at a point `y` of the
`R`-stretch above `t`, which is what supplies the `S(⊤,R)` antecedent — `R` is not yet known to
hold anywhere below `t`, so Prior-S could not be applied at `t` itself. Its third case,
*"a first point of `R`"*, is closed by `reynolds_lemma3_no_first_point`. -/
theorem reynolds_lemma3_left (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {t : M.carrier} (ht : EndsInGapOnRight M ε t)
    (hnot : ∃ u : M.carrier, u < t ∧ ¬ EndsInGapOnRight M ε u) :
    ∃ s : M.carrier, s < t ∧
      (∀ r : M.carrier, s < r → r < t → EndsInGapOnRight M ε r) ∧
      ¬ EndsInGapOnRight M ε s := by
  have hspec : ∀ r : M.carrier,
      TemporalTruth M atomMap r (gapRightFormula atomMap h_surj ε) ↔ EndsInGapOnRight M ε r :=
    fun r => gapRightFormula_spec atomMap h_surj ε M h_prior_U h_prior_S r
  -- *"Looking back from just after `t`"*: `y` is a point of the `R`-stretch above `t`.
  obtain ⟨y, hty, hy⟩ := endsInGapOnRight_forAWhile hε M ht
  have hstretch : ∃ s : M.carrier, s < y ∧ ∀ r : M.carrier, s < r → r < y →
      TemporalTruth M atomMap r (gapRightFormula atomMap h_surj ε) :=
    ⟨t, hty, fun r h₁ h₂ => (hspec r).mpr (hy r h₁ h₂.le)⟩
  obtain ⟨u, hut, hnu⟩ := hnot
  have hfail : ∃ u : M.carrier, u < y ∧
      ¬ TemporalTruth M atomMap u (gapRightFormula atomMap h_surj ε) :=
    ⟨u, lt_trans hut hty, fun h => hnu ((hspec u).mp h)⟩
  obtain ⟨s, hsy, hbelow, hcase⟩ :=
    h_prior_S y (gapRightFormula atomMap h_surj ε) hstretch hfail
  have hns : ¬ EndsInGapOnRight M ε s := by
    rcases hcase with hn | ⟨hb, hkminus⟩
    · exact fun h => hn ((hspec s).mpr h)
    · -- *"a first point of `R`"* — the third case, ruled out.
      exact absurd
        (reynolds_lemma3_no_first_point atomMap h_surj hε M h_prior_U h_prior_S ((hspec s).mp hb)
          (fun v hv => by
            obtain ⟨r, h₁, h₂, h₃⟩ := hkminus v hv
            exact ⟨r, h₁, h₂, fun h => h₃ ((hspec r).mpr h)⟩))
        not_false
  have hst : s < t := by
    rcases lt_trichotomy s t with h | rfl | h
    · exact h
    · exact absurd ht hns
    · exact absurd (hy s h hsy.le) hns
  exact ⟨s, hst, fun r h₁ h₂ => (hspec r).mp (hbelow r h₁ (lt_trans h₂ hty)), hns⟩

end LeftEnd

/-! ## Lemma 3, assembled -/

section Lemma3

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Reynolds 1992, §6 Lemma 3, printed p.178.**

> *The maximal intervals in which `R` holds are open intervals which, if bounded, have elements of
> `M` as their (excluded) end points.*

Stated at a point `t` of such an interval, in four parts, which together are the printed sentence:

1. *open on the right* — `R` holds throughout a right-neighbourhood of `t`;
2. *open on the left* — `R` holds throughout a left-neighbourhood of `t`, whenever `t` has any
   point below it at all. The proviso is not a weakening: if `t` is the least element of `M` there
   is no left-neighbourhood to speak of, and Reynolds' own parenthesis *"note that the end of the
   whole structure is not a gap"* (printed p.177) is the remark that this case is not a gap case;
3. *bounded above ⟹ excluded end point in `M`* — `reynolds_lemma3_right`;
4. *bounded below ⟹ excluded end point in `M`* — `reynolds_lemma3_left`.

Parts 3 and 4 are what *"have elements of `M` as their (excluded) end points"* asserts: the
bounding point `s` is an element of `M`, and `¬R` holds there, so it is excluded from the interval
rather than being a gap. -/
theorem reynolds_lemma3 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    (∃ b : M.carrier, t < b ∧ ∀ r : M.carrier, t < r → r ≤ b → EndsInGapOnRight M ε r) ∧
    (∀ a₀ : M.carrier, a₀ < t →
      ∃ a : M.carrier, a < t ∧ ∀ r : M.carrier, a < r → r < t → EndsInGapOnRight M ε r) ∧
    ((∃ u : M.carrier, t < u ∧ ¬ EndsInGapOnRight M ε u) →
      ∃ s : M.carrier, t < s ∧ (∀ r : M.carrier, t < r → r < s → EndsInGapOnRight M ε r) ∧
        ¬ EndsInGapOnRight M ε s) ∧
    ((∃ u : M.carrier, u < t ∧ ¬ EndsInGapOnRight M ε u) →
      ∃ s : M.carrier, s < t ∧ (∀ r : M.carrier, s < r → r < t → EndsInGapOnRight M ε r) ∧
        ¬ EndsInGapOnRight M ε s) := by
  refine ⟨endsInGapOnRight_forAWhile hε M ht, ?_,
    fun h => reynolds_lemma3_right atomMap h_surj hε M h_prior_U h_prior_S ht h,
    fun h => reynolds_lemma3_left atomMap h_surj hε M h_prior_U h_prior_S ht h⟩
  intro a₀ ha₀
  by_cases hb : ∃ u : M.carrier, u < t ∧ ¬ EndsInGapOnRight M ε u
  · obtain ⟨s, hst, hbelow, _⟩ := reynolds_lemma3_left atomMap h_surj hε M h_prior_U h_prior_S ht hb
    exact ⟨s, hst, hbelow⟩
  · push_neg at hb
    exact ⟨a₀, ha₀, fun r _ h₂ => hb r h₂⟩

end Lemma3

/-! ## Lemma 4's auxiliary formula

> *By expressive completeness, the formula*
> ```
> ρ(x) ∧ ∀y < x(¬ε(x, y) → ∃z(y < z < x ∧ ¬ρ(z)))
> ```
> *has a temporal equivalent which is true only in the first classes of maximal intervals of `R`.*
> (printed p.179)

Transcribed from the page image; see this module's header for the four independent ways the local
corpus corrupts this formula, and for why the plan's quotation of the corrupted form is not
followed. -/

/-- **Lemma 4's displayed formula**, printed p.179.

De Bruijn layout: free variable `0` is `x`; under `∀y` the indices are `0 = y`, `1 = x`; under the
inner `∃z` they are `0 = z`, `1 = y`, `2 = x`. -/
def firstClassFormula (ε : MonadicFormula sig 2) : MonadicFormula sig 1 :=
  .and (rhoAt ε 0)
    (.all (.imp (.lt 0 1)
      (.imp (.not (epsAt ε 1 0))
        (.ex (.and (.lt 1 0) (.and (.lt 0 2) (.not (rhoAt ε 0))))))))

/-- **What Lemma 4's formula says**: `t`'s class ends in a gap on the right, and every point below
`t` that is outside `t`'s class has a point of `¬R` between it and `t`.

Reynolds' reading is *"true only in the first classes of maximal intervals of `R`"*: the second
conjunct says precisely that no class of `t`'s maximal `R`-interval precedes `t`'s own, since
reaching any earlier point outside the class requires crossing a point where `R` fails. -/
def IsFirstClassPoint (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) : Prop :=
  EndsInGapOnRight M ε t ∧
  ∀ y : M.carrier, y < t → ¬ ContempEquivDense M ε t y →
    ∃ z : M.carrier, y < z ∧ z < t ∧ ¬ EndsInGapOnRight M ε z

/-- **The Lemma 4 transcription is correct** — checked, not asserted. Given that the corpus text
for this formula is corrupted in four places, this theorem is the only thing standing between the
transcription and a silent mis-reading. -/
theorem firstClassFormula_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) :
    eval M (fun _ => t) (firstClassFormula ε) ↔ IsFirstClassPoint M ε t := by
  simp only [firstClassFormula, IsFirstClassPoint, eval, eval_imp, eval_epsAt, eval_rhoAt,
    Fin.cons_zero, c2_one, c3_one, c3_two]

section Lemma4

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **Lemma 4's formula, as a temporal formula** — *"has a temporal equivalent"*, printed p.179. -/
noncomputable def firstClassTemporal (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (firstClassFormula ε)).val

/-- The temporal equivalent holds exactly at first-class points, in every Prior structure. -/
theorem firstClassTemporal_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (firstClassTemporal atomMap h_surj ε) ↔ IsFirstClassPoint M ε t :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj (firstClassFormula ε)).property
    M h_prior_U h_prior_S t).symm.trans (firstClassFormula_eval M ε t)

/-- **Being a first-class point is a property of the class**, which is what licenses Reynolds'
*"this formula holding up to a gap"* — it holds at every point of the class, not merely at the one
it was verified at. -/
theorem isFirstClassPoint_congr {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t t' : M.carrier}
    (htt' : ContempEquivDense M ε t t') (h : IsFirstClassPoint M ε t) :
    IsFirstClassPoint M ε t' := by
  refine ⟨(endsInGapOnRight_congr hε M htt').mp h.1, fun y hyt' hny => ?_⟩
  have hnty : ¬ ContempEquivDense M ε t y := fun hc =>
    hny (contemp_trans hε M (contemp_symm hε M htt') hc)
  -- `y < t`: otherwise `t ≤ y ≤ t'` and convexity would put `y` in the class.
  have hyt : y < t := by
    by_contra hle
    push_neg at hle
    exact hnty (contemp_of_between hε M hle hyt'.le htt')
  obtain ⟨z, hyz, hzt, hnz⟩ := h.2 y hyt hnty
  -- `z < t'`: otherwise `t' ≤ z ≤ t` and convexity would put `z` in the class, where `R` holds.
  refine ⟨z, hyz, ?_, hnz⟩
  by_contra hle
  push_neg at hle
  exact hnz ((endsInGapOnRight_congr hε M
    (contemp_of_between hε M hle hzt.le (contemp_symm hε M htt'))).mp
      ((endsInGapOnRight_congr hε M htt').mp h.1))

/-- **Reynolds 1992, printed p.179**: *"no immediately subsequent classes satisfy this"*.

Beyond the class, with `R` still holding throughout below, Lemma 4's formula fails: `t` itself is a
point below, outside the later class, with no `¬R` point between. -/
theorem not_isFirstClassPoint {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig) {t u : M.carrier} (htu : t < u)
    (hnu : ¬ ContempEquivDense M ε t u)
    (hIcc : ∀ q : M.carrier, t ≤ q → q ≤ u → EndsInGapOnRight M ε q) :
    ¬ IsFirstClassPoint M ε u := by
  rintro ⟨_, h2⟩
  obtain ⟨z, htz, hzu, hnz⟩ := h2 t htu (fun hc => hnu (contemp_symm hε M hc))
  exact hnz (hIcc z htz.le hzu.le)

/-- **Reynolds 1992, §6 Lemma 4, printed pp.178-179 — there is no first class.**

> *There is no last class and no first class in any maximal interval of `R`.*
>
> *… By expressive completeness, the formula `ρ(x) ∧ ∀y < x(¬ε(x,y) → ∃z(y < z < x ∧ ¬ρ(z)))` has a
> temporal equivalent which is true only in the first classes of maximal intervals of `R`. If there
> is a first class then no immediately subsequent classes satisfy this and so we have this formula
> holding up to a gap and false arbitrarily soon afterwards. This contradicts Prior-U.*

The three sentences map to `isFirstClassPoint_congr` (*"holding up to a gap"*),
`not_isFirstClassPoint` (*"no immediately subsequent classes satisfy this"*) and
`false_of_holds_throughout_class` (*"this contradicts Prior-U"*) respectively. -/
theorem reynolds_lemma4_no_first_class (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) : ¬ IsFirstClassPoint M ε t := by
  intro h
  exact false_of_holds_throughout_class atomMap h_surj hε M h_prior_U h_prior_S h.1
    (firstClassTemporal atomMap h_surj ε)
    (fun r hr => (firstClassTemporal_spec atomMap h_surj ε M h_prior_U h_prior_S r).mpr
      (isFirstClassPoint_congr hε M hr h))
    (fun u htu hnu hIcc hP => not_isFirstClassPoint hε M htu hnu hIcc
      ((firstClassTemporal_spec atomMap h_surj ε M h_prior_U h_prior_S u).mp hP))

/-- **Reynolds 1992, §6 Lemma 4, printed pp.178-179 — there is no last class.**

> *The last class in a maximal interval of `R` wouldn't end in a gap.*

Rendered as: above any point `t` where `R` holds there is a point `u` of a *strictly later* class,
with `R` holding throughout the whole of `[t, u]` — so `t`'s class is never the last one in its
maximal `R`-interval.

Reynolds' one-line proof is the argument already carried out in `exists_gt_notContemp_holds`: were
`t`'s class the last one, its right end would be the interval's right end, which
`reynolds_lemma3_right` puts *in `M`* — so the class would end at a point rather than at a gap,
contradicting `ρ(t)`'s third conjunct. This declaration is that theorem restated under Lemma 4's
name, not a second proof of it. -/
theorem reynolds_lemma4_no_last_class (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    ∃ u : M.carrier, t < u ∧ ¬ ContempEquivDense M ε t u ∧
      ∀ q : M.carrier, t ≤ q → q ≤ u → EndsInGapOnRight M ε q :=
  exists_gt_notContemp_holds atomMap h_surj hε M h_prior_U h_prior_S ht

/-- **Reynolds 1992, §6 Lemma 4, printed pp.178-179**, both halves.

> *There is no last class and no first class in any maximal interval of `R`.* -/
theorem reynolds_lemma4 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {ε : MonadicFormula sig 2} (hε : IsContempEquivDense ε)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    {t : M.carrier} (ht : EndsInGapOnRight M ε t) :
    (∃ u : M.carrier, t < u ∧ ¬ ContempEquivDense M ε t u ∧
      ∀ q : M.carrier, t ≤ q → q ≤ u → EndsInGapOnRight M ε q) ∧
    ¬ IsFirstClassPoint M ε t :=
  ⟨reynolds_lemma4_no_last_class atomMap h_surj hε M h_prior_U h_prior_S ht,
    reynolds_lemma4_no_first_class atomMap h_surj hε M h_prior_U h_prior_S t⟩

end Lemma4

/-! ## Anti-vacuity

Every theorem above is conditional on `IsContempEquivDense ε` **and** on `EndsInGapOnRight M ε t`.
`Defs.lean` exhibits an inhabitant of the first (`isContempEquivDense_epsTop`) and proves that the
second fails everywhere for that inhabitant (`not_endsInGapOnRight_epsTop`). So the witness that
keeps `IsContempEquivDense` non-empty is exactly the one at which every statement below Lemma 2 is
vacuously satisfied, and none of the lemmas above is yet known to have a non-trivial instance.

That is not a defect of this phase; it is the shape of Reynolds' argument. §6's whole point is to
*refute* the existence of a class ending in a gap, which Lemma 9 and Theorem 4 (Phase 22) finally
do — so a structure at which `EndsInGapOnRight` holds is precisely what §6 shows cannot exist in a
Prior structure once the surgery is available. Recording the state honestly here so that no reader
mistakes the conditional theorems above for statements with a live instance in hand. -/

/-- With the total relation as `ε`, Lemma 4's formula is refuted at every point of every structure
— its first conjunct is `ρ`, which `not_endsInGapOnRight_epsTop` refutes. The witness that makes
`IsContempEquivDense` inhabited is therefore not a witness that any of §6's later lemmas has
content; see this section's note. -/
theorem not_isFirstClassPoint_epsTop (M : OrderedMonadicStructure sig) (t : M.carrier) :
    ¬ IsFirstClassPoint M (epsTop sig) t :=
  fun h => not_endsInGapOnRight_epsTop M t h.1

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
