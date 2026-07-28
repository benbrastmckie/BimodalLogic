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
      ¬ EndsInGapOnRight M ε r) : False := by
  have hBspec : ∀ r : M.carrier,
      TemporalTruth M atomMap r (classBeginsAtGapStartTemporal atomMap h_surj ε) ↔
        ClassBeginsAtGapStart M ε r :=
    fun r => classBeginsAtGapStartTemporal_spec atomMap h_surj ε M h_prior_U h_prior_S r
  obtain ⟨u₀, hsu₀, hnu₀, hIcc₀⟩ :=
    exists_gt_notContemp_holds atomMap h_surj hε M h_prior_U h_prior_S hs
  have hnB₀ : ¬ ClassBeginsAtGapStart M ε u₀ :=
    not_classBeginsAtGapStart hε M hsu₀ hnu₀ hIcc₀
  -- Prior-U's `U(⊤,B)` antecedent: `B` holds throughout `s`'s class, which is non-degenerate.
  obtain ⟨y, hsy, hcy⟩ := exists_contemp_gt hε M hs
  have hstretch : ∃ b : M.carrier, s < b ∧ ∀ r : M.carrier, s < r → r < b →
      TemporalTruth M atomMap r (classBeginsAtGapStartTemporal atomMap h_surj ε) :=
    ⟨y, hsy, fun r h₁ h₂ => (hBspec r).mpr
      (classBeginsAtGapStart_of_contemp hε M hs hk (contemp_of_between hε M h₁.le h₂.le hcy))⟩
  have hfail : ∃ u : M.carrier, s < u ∧
      ¬ TemporalTruth M atomMap u (classBeginsAtGapStartTemporal atomMap h_surj ε) :=
    ⟨u₀, hsu₀, fun h => hnB₀ ((hBspec u₀).mp h)⟩
  obtain ⟨s₁, hss₁, hbelow, hcase⟩ :=
    h_prior_U s (classBeginsAtGapStartTemporal atomMap h_surj ε) hstretch hfail
  -- `s₁` is not in `s`'s class: `B` holds throughout the class, which has no last point.
  have hns₁ : ¬ ContempEquivDense M ε s s₁ := by
    intro hc
    rcases hcase with hn | ⟨_hb, hkplus⟩
    · exact hn ((hBspec s₁).mpr (classBeginsAtGapStart_of_contemp hε M hs hk hc))
    · obtain ⟨y', hs₁y', hcy'⟩ :=
        exists_contemp_gt hε M ((endsInGapOnRight_congr hε M hc).mp hs)
      obtain ⟨r, hs₁r, hry', hnr⟩ := hkplus y' hs₁y'
      exact hnr ((hBspec r).mpr (classBeginsAtGapStart_of_contemp hε M hs hk
        (contemp_trans hε M hc (contemp_of_between hε M hs₁r.le hry'.le hcy'))))
  -- `(s, s₁)` is not inside the class either: `s₁` would then be a first point after it.
  have hex : ∃ r : M.carrier, s < r ∧ r < s₁ ∧ ¬ ContempEquivDense M ε s r := by
    by_contra hcon
    push_neg at hcon
    exact hs.2.2 ⟨s₁, hss₁, hns₁, fun y h₁ h₂ => hcon y h₁ h₂⟩
  obtain ⟨r, hsr, hrs₁, hnr⟩ := hex
  rcases lt_or_ge u₀ s₁ with hlt | hge
  · exact hnB₀ ((hBspec u₀).mp (hbelow u₀ hsu₀ hlt))
  · exact not_classBeginsAtGapStart hε M hsr hnr
      (fun q h₁ h₂ => hIcc₀ q h₁ (le_trans h₂ (le_trans hrs₁.le hge)))
      ((hBspec r).mp (hbelow r hsr hrs₁))

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

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
