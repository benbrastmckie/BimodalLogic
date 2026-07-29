/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.PriorExpressivenessDense
import FormalSystem.Metalogic.WeakCanonical.Kamp.Prop43Translate

/-!
# Reynolds §6 vocabulary: contemporaneous equivalence, `ρ`, `λ`, and Lemma 2

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§6 *"No gaps between equivalence classes"*, printed pp.176-177.

This module lands the §6 vocabulary at the **dense** instance and discharges **Lemma 2**, the
first of §6's nine lemmas, by applying `uSExpressivelyCompleteOverDensePrior`
(`PriorExpressivenessDense.lean:302`) to the monadic formula `ρ`.

## The source, verbatim

Printed p.176, the definition of a contemporaneous equivalence relation:

> Suppose that `ε(x, y)` is a monadic formula with two free variables `x` and `y`. We say that
> `ε` defines a *contemporaneous equivalence relation* if and only if on any temporal structure
> `M`, if we define the binary relation `∼_M` by
>
> `a ∼_M b  iff  M ⊨ ε(a, b)`,
>
> then
>
> * `∼_M` is an equivalence relation on the domain of `M`,
> * `∼_M` partitions `M` into intervals and
> * `ε` depends only on contemporary properties: i.e. for all `a, b ∈ M`,
>   `M ⊨ ε(a,b)  iff  M | [a,b] ⊨ ε(a,b)`.
>
> A binary relation `∼` on a structure `M` is called a *contemporaneous equivalence relation* if
> and only if it is defined as `∼_M` by such an `ε`.

Printed p.177, the definition of `ρ`:

> Given such an `ε`, define `ρ(x)` as
>
> ```
>     ∃y > x  ¬ε(x, y)
>   ∧  ¬∃z(ε(x, z) ∧ ∀y > z  ¬ε(x, y))
>   ∧  ¬∃z(x < z ∧ ¬ε(x, z) ∧ ∀y(x < y < z → ε(x, y))).
> ```
>
> This says that `x`'s `∼`-class ends in a gap on the right. Dually we can define `λ(x)` about
> left ends. Note that the end of the whole structure is not a gap and that `ρ` will not hold of
> points in the last `∼_M` class (if there is such a class).
>
> Now by the expressive completeness of `U` and `S` there is temporal `R` true in any Prior
> structure exactly where `ρ(x)` is.

Printed p.177, **Lemma 2**:

> **LEMMA 2** *Suppose that `ε` defines the contemporaneous equivalence relation `∼_N` on any
> structure `N`.*
>
> *Then there is an `US`-formula `R` which holds in any Prior structure `N` exactly at those
> points whose `∼_N`-class ends in a gap on the right.*
>
> Dually `L`.

## CORRECTION TO THE LOCAL CORPUS — `ρ` HAS THREE CONJUNCTS, NOT TWO

The pre-segmented markdown chunk
`~/Projects/Literature/sources/reynolds_1992/sec03_6-no-gaps-between-equivalence-classes.md`
renders `ρ` as a **two**-conjunct formula

```
∃y > x ¬ε(x, y) ∧ ¬∃z(x < z ∧ ε(x, z) ∧ ∀y(x < y < z → ε(x, y)))
```

which differs from the printed page in two places: the entire **middle** conjunct
`¬∃z(ε(x,z) ∧ ∀y > z ¬ε(x,y))` is missing, and the negation on `ε(x,z)` in the final conjunct
has been dropped. The formula transcribed below is the printed one, read off the page image of
the source PDF (`Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`, PDF page index 12 =
printed p.177) rather than off the markdown chunk, whose OCR-derived text layer is degraded
exactly at this display formula.

The correction is not cosmetic. The three conjuncts are, in order:

1. `∃y > x ¬ε(x,y)` — the class does **not** extend forever to the right;
2. `¬∃z(ε(x,z) ∧ ∀y > z ¬ε(x,y))` — the class has **no last point**;
3. `¬∃z(x < z ∧ ¬ε(x,z) ∧ ∀y(x<y<z → ε(x,y)))` — there is **no first point after** the class.

"Ends in a gap on the right" is exactly the conjunction of these three: a Dedekind gap is a cut
with no greatest element below and no least element above, and (1) is what makes the cut exist at
all. The corpus' two-conjunct version is not merely weaker — it is *wrong*: its second conjunct,
read against a class that partitions `M` into intervals, says "no point of the class lies strictly
above `x`", i.e. `x` is the class's maximum, which is the negation of clause 2 rather than a
weakening of it. Nothing downstream of `rhoFormula` can be trusted against the corpus text.

Plan v8's Phase 17 task list quotes the corrupted two-conjunct form. This module transcribes the
printed source instead, per the standing literature-fidelity directive; see the phase deviation
record.

## What has no source

Reynolds writes only *"Dually we can define `λ(x)` about left ends"* and *"Dually `L`"* — he
prints no formula for `λ` and no statement for `L`. `lambdaFormula` and `gapLeftFormula` below
are therefore **this tree's mirror**, obtained by reversing every order comparison in `ρ` and
leaving `ε`'s argument order alone (`ε` is symmetric as a relation, by clause (i)). They are
labelled as such at each declaration and are not presented as transcriptions.

`ContempEquivDense` is likewise a rendering choice rather than a quotation: Reynolds states the
three clauses in prose over an unspecified satisfaction relation, and clause (ii) — *"partitions
`M` into intervals"* — is rendered here as **convexity of each class**, which is what "partitions
into intervals" amounts to once (i) has made the classes a partition.

## The uniformity Reynolds relies on

Lemma 2 asserts one `R` that works in **any** Prior structure `N`, not one `R` per structure.
That uniformity is inherited directly from `uSExpressivelyCompleteOverDensePrior`, whose subtype
value `A` is produced *before* any structure is supplied and whose property is then universally
quantified over `M`. It is the same uniformity Reynolds flags at §5, printed p.176:

> Note the uniformity of the translation over the whole of `S`.

`reynolds_lemma2` below is stated in exactly that shape — `∃ R : Formula, ∀ M, …` — so the
quantifier order is visible in the statement rather than left to a reader's trust. Reynolds'
Lemma 9 (Phase 22) consumes precisely this: it applies `R` to a *surgered* structure `N` that is
not the `M` the formula was produced from.

## Can the landed `ContempEquiv` be reused?

**No**, for two independent reasons, and the phase's charter asks that this be recorded rather
than resolved by silently generalizing the landed definition. The landed `ContempEquiv`
(`IntegerModel/GoodStructures.lean:729`) is untouched by this module.

1. **Wrong kind of object.** `ContempEquiv sig k M a b` is `VeryGood sig k (M.subinterval sig
   (min a b) (max a b))` — a semantic relation with no defining monadic formula. Reynolds' §6
   needs `ε` *syntactically*: `ρ` and `λ` are built by quantifying over `ε`'s two free variables,
   and there is nothing to quantify over in a `VeryGood` predicate. A formula-free relation cannot
   be fed to expressive completeness, which is what Lemma 2 is.
2. **Its equivalence theorem is unavailable at a dense carrier.** `contemp_equiv_is_equiv`
   (`GoodStructures.lean:749`) carries `[SuccOrder M.carrier]` and `[NoMaxOrder M.carrier]`.
   `false_of_succOrder_dense` below proves that these two together with `DenselyOrdered` are
   *contradictory*, so on the dense flows this development targets the landed clause-(i) theorem
   has no instance at all. This is machine-checked here rather than asserted.

So `ContempEquiv` is at best a candidate *instance* of `IsContempEquivDense` at a discrete
carrier, never the general notion §6 quantifies over. No dense sibling of `ContempEquiv` is
introduced; `ContempEquivDense` is the §6 notion, parameterized by `ε`.

## References

- Reynolds 1992, §6, printed pp.176-177 (the definitions and Lemma 2)
- Reynolds 1992, §5, printed p.176 (the uniformity remark)
- `uSExpressivelyCompleteOverDensePrior` (`PriorExpressivenessDense.lean:302`) — Reynolds §5
  Theorem 3, the input to Lemma 2
- `MonadicFormula.rename` / `eval_rename` (`Kamp/Prop43Translate.lean:109`, `:130`) — the variable
  reindexing `ρ` and `λ` are assembled with
-/

namespace FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

open FormalSystem.Syntax FormalSystem.Metalogic.WeakCanonical

/-! ## The `SuccOrder` obstruction

The machine-checked half of the `ContempEquiv`-reuse verdict recorded in the module header. -/

/-- **A densely ordered flow with no maximum admits no `SuccOrder`.**

Given a point `a`: `NoMaxOrder` supplies `b > a`, so `Order.succ a ≤ b` and `a ≤ Order.succ a`.
If `a = Order.succ a` then `Order.succ a ≤ a`, making `a` a maximum, which `NoMaxOrder` forbids.
Otherwise `a < Order.succ a`, and density supplies `c` strictly between, whence
`Order.succ a ≤ c < Order.succ a`.

Consequence for this module: `contemp_equiv_is_equiv` (`IntegerModel/GoodStructures.lean:749`),
which establishes clause (i) for the landed `ContempEquiv`, carries `[SuccOrder M.carrier]` and
`[NoMaxOrder M.carrier]` and therefore has **no instance** on a densely ordered flow. The landed
`ContempEquiv` is not reusable at the dense carrier; see the module header. -/
theorem false_of_succOrder_dense {α : Type*} [LinearOrder α] [SuccOrder α]
    [DenselyOrdered α] [NoMaxOrder α] (a : α) : False := by
  obtain ⟨b, hab⟩ := exists_gt a
  have hle : a ≤ Order.succ a := Order.le_succ a
  rcases eq_or_lt_of_le hle with heq | hlt
  · exact absurd (Order.max_of_succ_le heq.ge) (not_isMax a)
  · obtain ⟨c, hac, hcs⟩ := exists_between hlt
    exact absurd (Order.succ_le_of_lt hac) (not_le.mpr hcs)

/-! ## `ε` at a pair of variables

`ε` is a `MonadicFormula sig 2` whose free variable `0` is Reynolds' `x` and whose free variable
`1` is his `y`. `epsAt` places it at an arbitrary pair of De Bruijn indices, which is what lets
`ρ` mention `ε(x,y)`, `ε(x,z)` and `ε(x,y)` again from under two nested binders. -/

/-- `ε` with its two free variables reindexed to `i` (the `x` slot) and `j` (the `y` slot).

Built from the landed `MonadicFormula.rename` (`Kamp/Prop43Translate.lean:109`) rather than a
fresh substitution operator. -/
def epsAt {sig : MonadicSignature} {n : Nat} (ε : MonadicFormula sig 2) (i j : Fin n) :
    MonadicFormula sig n :=
  ε.rename ![i, j]

/-- **`∼_M`, the relation `ε` defines** — Reynolds 1992, printed p.176:
`a ∼_M b  iff  M ⊨ ε(a, b)`.

Free variable `0` of `ε` is `a`, free variable `1` is `b`. This is the §6 notion; it is *not* a
dense sibling of the landed `ContempEquiv` (`IntegerModel/GoodStructures.lean:729`), which is a
`VeryGood`-based relation with no defining formula — see the module header. -/
def ContempEquivDense {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (a b : M.carrier) : Prop :=
  eval M ![a, b] ε

/-- Evaluating a reindexed `ε` is `∼_M` at the reindexed points. -/
theorem eval_epsAt {sig : MonadicSignature} {n : Nat} (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (env : Fin n → M.carrier) (i j : Fin n) :
    eval M env (epsAt ε i j) ↔ ContempEquivDense M ε (env i) (env j) := by
  unfold epsAt ContempEquivDense
  rw [Kamp.eval_rename]
  have h : env ∘ ![i, j] = ![env i, env j] := by
    funext k; fin_cases k <;> rfl
  rw [h]

/-! ## The three clauses

Reynolds' bullets, printed p.176. Clause (ii), *"`∼_M` partitions `M` into intervals"*, is
rendered as convexity of each class; clause (iii) uses `M.subinterval` (`MonadicFO.lean:215`) for
Reynolds' `M | [a,b]`, with `min`/`max` endpoints so that the clause is stated for every ordered
pair without presupposing `a ≤ b` — the same convention the landed `ContempEquiv` uses. -/

/-- **`ε` defines a contemporaneous equivalence relation** — Reynolds 1992, printed p.176, all
three clauses, universally quantified over structures exactly as the source has them (*"on any
temporal structure `M`"*).

Note this is a property of `ε` alone. `ContempEquivDense M ε` is the relation; this is the
predicate saying that relation deserves the name at every `M`.

## Clause (i) is restricted to countable dense flows, and why

Clause (i) quantifies over `[Countable] [DenselyOrdered]` structures; clauses (ii) and (iii)
remain at **every** structure. This is not a convenience: at the one `ε` this development has
to instantiate — Reynolds' own `ε(x,y)` of §8 Lemma 12, `epsDense` — the unrestricted clause (i)
is **false**, while (ii) and (iii) are theorems at every structure.

Clause (i) is therefore split into its three components: `refl` and `symm` are stated at every
structure, and only `trans` carries the instances. `IsContempEquivDense.equiv` below reassembles
them into the `Equivalence` bundle at a countable dense flow, so every existing `hε.equiv M`
call site reads unchanged.

Transitivity is the whole of the difference. `simDense_trans` (`RealModel/EpsilonDense.lean`)
needs both instances, and `EpsilonDense`'s module header exhibits the counterexample without
density: with `M | (a,b) ≅ (0,1]` having a maximum `x` and `M | (b,c)` very good, `a ∼ b` and
`b ∼ c` but `M | (x,b)` is empty, so `a ≁ c`. Countability enters through Lemma 11 (*"countable
and very good ⇒ good"*), which the transitivity proof calls. By contrast `simDense_refl`,
`simDense_symm`, `simDense_convex` and `simDense_contemporary` carry **no** instance
hypotheses — hence clauses (ii) and (iii) are left unrestricted, exactly as strong as before.

Keeping the restriction on clause (i) alone is what makes `epsDense` an instance of this
predicate at all (`epsDense_isContempEquivDense`, `RealModel/EpsilonDense.lean`), and it is the
narrowest weakening that achieves it: everything downstream that projects `.equiv` does so at
the ambient `M` or at `dual M`, never at a structure whose countability or density is in doubt.
The one projection at a surgered structure uses `.contemporary`, which is unrestricted. -/
structure IsContempEquivDense {sig : MonadicSignature} (ε : MonadicFormula sig 2) : Prop where
  /-- Clause (i), reflexivity — at every structure. -/
  refl : ∀ (M : OrderedMonadicStructure sig) (a : M.carrier), ContempEquivDense M ε a a
  /-- Clause (i), symmetry — at every structure. -/
  symm : ∀ (M : OrderedMonadicStructure sig) {a b : M.carrier},
    ContempEquivDense M ε a b → ContempEquivDense M ε b a
  /-- Clause (i), transitivity — **only** at countable dense flows. This single field carries the
  whole of the weakening; see the restriction note on the structure. -/
  trans : ∀ (M : OrderedMonadicStructure sig) [Countable M.carrier] [DenselyOrdered M.carrier]
    {a b c : M.carrier}, ContempEquivDense M ε a b → ContempEquivDense M ε b c →
      ContempEquivDense M ε a c
  /-- Clause (ii): *"`∼_M` partitions `M` into intervals"*, i.e. each class is convex.

  Carries the same instances as `trans`, and for the same reason: the clause is *inherited* by
  `dualize ε` (`Dual.lean`) only through transitivity at `dual M` — from `a ≤ b ≤ c` and `a ∼ c`
  the dual reads off `c ∼ b`, and getting back to `a ∼ b` is a transitivity step that no
  rearrangement of the convexity clause avoids. -/
  convex : ∀ (M : OrderedMonadicStructure sig) [Countable M.carrier] [DenselyOrdered M.carrier]
    (a b c : M.carrier), a ≤ b → b ≤ c →
    ContempEquivDense M ε a c → ContempEquivDense M ε a b
  /-- Clause (iii): *"`ε` depends only on contemporary properties: i.e. for all `a, b ∈ M`,
  `M ⊨ ε(a,b)` iff `M | [a,b] ⊨ ε(a,b)`"*. -/
  contemporary : ∀ (M : OrderedMonadicStructure sig) (a b : M.carrier),
    ContempEquivDense M ε a b ↔
      ContempEquivDense (M.subinterval sig (min a b) (max a b)) ε
        ⟨a, min_le_left a b, le_max_left a b⟩ ⟨b, min_le_right a b, le_max_right a b⟩

/-- **Clause (i) reassembled** — Reynolds' *"`∼_M` is an equivalence relation on the domain of
`M`"*, at a countable dense flow, which is where his §8 uses it.

The three components are separate fields so that the instances ride on transitivity alone; this
is the bundle the surgery development reads them through. -/
theorem IsContempEquivDense.equiv {sig : MonadicSignature} {ε : MonadicFormula sig 2}
    (hε : IsContempEquivDense ε) (M : OrderedMonadicStructure sig) [Countable M.carrier]
    [DenselyOrdered M.carrier] : Equivalence (ContempEquivDense M ε) where
  refl := hε.refl M
  symm := hε.symm M
  trans := hε.trans M

/-! ## `ρ` and `λ` -/

/-- **`ρ(x)`** — Reynolds 1992, printed p.177, transcribed from the page image (see the module
header's corpus correction):

```
    ∃y > x  ¬ε(x, y)
  ∧  ¬∃z(ε(x, z) ∧ ∀y > z  ¬ε(x, y))
  ∧  ¬∃z(x < z ∧ ¬ε(x, z) ∧ ∀y(x < y < z → ε(x, y))).
```

*"This says that `x`'s `∼`-class ends in a gap on the right."*

De Bruijn layout: the single free variable `0` is `x`. Under the first binder `0` is the bound
variable and `1` is `x`; under a second binder `0` is the inner bound variable, `1` the outer
one and `2` is `x`. -/
def rhoFormula {sig : MonadicSignature} (ε : MonadicFormula sig 2) : MonadicFormula sig 1 :=
  -- ∃y > x ¬ε(x,y)
  .and (.ex (.and (.lt 1 0) (.not (epsAt ε 1 0))))
    (.and
      -- ¬∃z(ε(x,z) ∧ ∀y > z ¬ε(x,y))
      (.not (.ex (.and (epsAt ε 1 0)
        (.all (.imp (.lt 1 0) (.not (epsAt ε 2 0)))))))
      -- ¬∃z(x < z ∧ ¬ε(x,z) ∧ ∀y(x < y < z → ε(x,y)))
      (.not (.ex (.and (.lt 1 0)
        (.and (.not (epsAt ε 1 0))
          (.all (.imp (.and (.lt 2 0) (.lt 0 1)) (epsAt ε 2 0))))))))

/-- **`λ(x)`** — the left-hand mirror of `rhoFormula`.

**No source.** Reynolds writes only *"Dually we can define `λ(x)` about left ends"* and prints no
formula. This is this tree's mirror: every order comparison in `ρ` is reversed and `ε`'s argument
order is left alone (`ε` is symmetric as a relation by clause (i) of `IsContempEquivDense`). -/
def lambdaFormula {sig : MonadicSignature} (ε : MonadicFormula sig 2) : MonadicFormula sig 1 :=
  -- ∃y < x ¬ε(x,y)
  .and (.ex (.and (.lt 0 1) (.not (epsAt ε 1 0))))
    (.and
      -- ¬∃z(ε(x,z) ∧ ∀y < z ¬ε(x,y))
      (.not (.ex (.and (epsAt ε 1 0)
        (.all (.imp (.lt 0 1) (.not (epsAt ε 2 0)))))))
      -- ¬∃z(z < x ∧ ¬ε(x,z) ∧ ∀y(z < y < x → ε(x,y)))
      (.not (.ex (.and (.lt 0 1)
        (.and (.not (epsAt ε 1 0))
          (.all (.imp (.and (.lt 1 0) (.lt 0 2)) (epsAt ε 2 0))))))))

/-! ## What `ρ` and `λ` say

Named semantic readings, so that Lemma 2's statement can be phrased in Reynolds' words rather
than in De Bruijn indices, and so that the transcription above is *checked* against its intended
meaning rather than asserted (`rhoFormula_eval`, `lambdaFormula_eval`). -/

/-- **`x`'s `∼`-class ends in a gap on the right** — the semantic content of `ρ`, one conjunct per
printed line:

1. the class does not extend forever to the right;
2. the class has no last point;
3. there is no first point after the class.

Their conjunction is precisely a Dedekind gap at the class's right end, together with the
existence of the cut. -/
def EndsInGapOnRight {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) : Prop :=
  (∃ y : M.carrier, t < y ∧ ¬ ContempEquivDense M ε t y) ∧
  (¬ ∃ z : M.carrier, ContempEquivDense M ε t z ∧
      ∀ y : M.carrier, z < y → ¬ ContempEquivDense M ε t y) ∧
  (¬ ∃ z : M.carrier, t < z ∧ ¬ ContempEquivDense M ε t z ∧
      ∀ y : M.carrier, t < y → y < z → ContempEquivDense M ε t y)

/-- **`x`'s `∼`-class ends in a gap on the left** — the mirror of `EndsInGapOnRight`, and like
`lambdaFormula` a mirror rather than a transcription. -/
def EndsInGapOnLeft {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) : Prop :=
  (∃ y : M.carrier, y < t ∧ ¬ ContempEquivDense M ε t y) ∧
  (¬ ∃ z : M.carrier, ContempEquivDense M ε t z ∧
      ∀ y : M.carrier, y < z → ¬ ContempEquivDense M ε t y) ∧
  (¬ ∃ z : M.carrier, z < t ∧ ¬ ContempEquivDense M ε t z ∧
      ∀ y : M.carrier, z < y → y < t → ContempEquivDense M ε t y)

/-- Environment lookup at index `1` under one binder: the free variable `x`. -/
private theorem cons2_one {α : Type*} (x t : α) :
    (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → α) 1 = t := rfl

/-- Environment lookup at index `1` under two binders: the outer bound variable. -/
private theorem cons3_one {α : Type*} (y x t : α) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → α) 1 = x := rfl

/-- Environment lookup at index `2` under two binders: the free variable `x`. -/
private theorem cons3_two {α : Type*} (y x t : α) :
    (Fin.cons y (Fin.cons x (fun _ : Fin 1 => t)) : Fin 3 → α) 2 = t := rfl

/-- **The `ρ` transcription is correct**: evaluating `rhoFormula ε` at `t` is exactly
`EndsInGapOnRight M ε t`. Checked rather than asserted — this is what pins the De Bruijn indices
in `rhoFormula` to the printed formula's variable names. -/
theorem rhoFormula_eval {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) :
    eval M (fun _ => t) (rhoFormula ε) ↔ EndsInGapOnRight M ε t := by
  simp only [rhoFormula, EndsInGapOnRight, eval, eval_imp, eval_epsAt, Fin.cons_zero,
    cons2_one, cons3_one, cons3_two, and_imp]

/-- **The `λ` mirror is correct**: evaluating `lambdaFormula ε` at `t` is exactly
`EndsInGapOnLeft M ε t`. -/
theorem lambdaFormula_eval {sig : MonadicSignature} (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) :
    eval M (fun _ => t) (lambdaFormula ε) ↔ EndsInGapOnLeft M ε t := by
  simp only [lambdaFormula, EndsInGapOnLeft, eval, eval_imp, eval_epsAt, Fin.cons_zero,
    cons2_one, cons3_one, cons3_two, and_imp]

/-! ## Lemma 2

*"Now by the expressive completeness of `U` and `S` there is temporal `R` true in any Prior
structure exactly where `ρ(x)` is."* (printed p.177) — so Lemma 2 is one application of
`uSExpressivelyCompleteOverDensePrior` to `rhoFormula ε`, and nothing else. -/

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- **`R`** — the `{U,S}`-formula of Reynolds' Lemma 2, printed p.177: the temporal equivalent of
`ρ`, produced by `uSExpressivelyCompleteOverDensePrior` (§5 Theorem 3).

Produced from `ε`, `atomMap` and `h_surj` alone: no structure is supplied here, which is the
uniformity Lemma 9 later relies on. -/
noncomputable def gapRightFormula (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (rhoFormula ε)).val

/-- **`L`** — the mirror of `gapRightFormula`, for left ends. Reynolds writes only *"Dually `L`"*;
this construction has no printed source. -/
noncomputable def gapLeftFormula (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (lambdaFormula ε)).val

/-- **`R` holds exactly where the class ends in a gap on the right**, in every Prior structure.

The composition: `uSExpressivelyCompleteOverDensePrior`'s property gives
`eval M (fun _ => t) (rhoFormula ε) ↔ TemporalTruth M atomMap t R`, and `rhoFormula_eval`
identifies the left side with `EndsInGapOnRight`. -/
theorem gapRightFormula_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (gapRightFormula atomMap h_surj ε) ↔ EndsInGapOnRight M ε t :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj (rhoFormula ε)).property
    M h_prior_U h_prior_S t).symm.trans (rhoFormula_eval M ε t)

/-- **`L` holds exactly where the class ends in a gap on the left**, in every Prior structure. -/
theorem gapLeftFormula_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (gapLeftFormula atomMap h_surj ε) ↔ EndsInGapOnLeft M ε t :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj (lambdaFormula ε)).property
    M h_prior_U h_prior_S t).symm.trans (lambdaFormula_eval M ε t)

/-- **Reynolds 1992, §6 Lemma 2, printed p.177**:

> *Then there is an `US`-formula `R` which holds in any Prior structure `N` exactly at those
> points whose `∼_N`-class ends in a gap on the right.*

The quantifier order is the content: `∃ R` comes **before** `∀ N`, so a single `R` serves every
Prior structure. Lemma 9 (Phase 22) applies this `R` to a structure obtained by surgery on the
one it was produced from, and that step is legitimate only because of this ordering.

Reynolds' standing hypothesis *"Suppose that `ε` defines the contemporaneous equivalence relation
`∼_N` on any structure `N`"* is **not** needed for this lemma and is therefore not carried here:
the derivation is one application of expressive completeness to `ρ`, which is a monadic formula
whatever `ε` is. `reynolds_lemma2_of_contemp` restates the result with the source's hypothesis in
place, for consumers written against Reynolds' literal statement. -/
theorem reynolds_lemma2 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) :
    ∃ R : Formula, ∀ (M : OrderedMonadicStructure sig),
      SemanticPriorU M atomMap → SemanticPriorS M atomMap →
      ∀ t : M.carrier, TemporalTruth M atomMap t R ↔ EndsInGapOnRight M ε t :=
  ⟨gapRightFormula atomMap h_surj ε,
    fun M hU hS t => gapRightFormula_spec atomMap h_surj ε M hU hS t⟩

/-- **Lemma 2, dually `L`** — printed p.178, *"Dually `L`."* The statement is the mirror; see
`lambdaFormula`'s docstring for what is and is not sourced. -/
theorem reynolds_lemma2_dual (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) :
    ∃ L : Formula, ∀ (M : OrderedMonadicStructure sig),
      SemanticPriorU M atomMap → SemanticPriorS M atomMap →
      ∀ t : M.carrier, TemporalTruth M atomMap t L ↔ EndsInGapOnLeft M ε t :=
  ⟨gapLeftFormula atomMap h_surj ε,
    fun M hU hS t => gapLeftFormula_spec atomMap h_surj ε M hU hS t⟩

/-- **Lemma 2 with Reynolds' standing hypothesis in place.** Identical conclusion; the hypothesis
is carried so that the declaration matches the printed statement literally. That it is discardable
is itself worth recording: §6's use of `ε`-contemporaneity begins at Lemma 3, not here. -/
theorem reynolds_lemma2_of_contemp (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (_hε : IsContempEquivDense ε) :
    ∃ R : Formula, ∀ (M : OrderedMonadicStructure sig),
      SemanticPriorU M atomMap → SemanticPriorS M atomMap →
      ∀ t : M.carrier, TemporalTruth M atomMap t R ↔ EndsInGapOnRight M ε t :=
  reynolds_lemma2 atomMap h_surj ε

/-! ## Anti-vacuity

`IsContempEquivDense` is a three-clause universally quantified property; a version of it that no
`ε` satisfies would make every §6 lemma downstream of Lemma 3 vacuous. One inhabitant is exhibited
here.

What is **not** established at this phase: that `EndsInGapOnRight` ever *holds*. Exhibiting that
needs a structure with an actual gap, which is Phase 22's chronicle instance. The witness below
goes the other way — it shows `ρ` is correctly refuted when the class is everything — so it pins
`rhoFormula`'s truth conditions without claiming more than is proved. -/

/-- The formula `¬(x < x)`, true of every pair: the coarsest contemporaneous equivalence, whose
single class is the whole structure. -/
def epsTop (sig : MonadicSignature) : MonadicFormula sig 2 :=
  .not (.lt 0 0)

/-- `∼_M` for `epsTop` is the total relation. -/
@[simp] theorem contempEquivDense_epsTop {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (a b : M.carrier) :
    ContempEquivDense M (epsTop sig) a b := by
  simp [ContempEquivDense, epsTop, eval]

/-- **`IsContempEquivDense` is inhabited.** `epsTop` satisfies all three clauses: the total
relation is an equivalence, its single class is trivially convex, and both sides of clause (iii)
are true outright. -/
theorem isContempEquivDense_epsTop (sig : MonadicSignature) :
    IsContempEquivDense (epsTop sig) where
  refl M _ := contempEquivDense_epsTop M _ _
  symm := by intros; exact contempEquivDense_epsTop _ _ _
  trans := by intros; exact contempEquivDense_epsTop _ _ _
  convex := by intros; exact contempEquivDense_epsTop _ _ _
  contemporary M a b :=
    ⟨fun _ => contempEquivDense_epsTop _ _ _, fun _ => contempEquivDense_epsTop M a b⟩

/-- **`ρ` is refuted where it should be.** When every point is contemporaneous with every other,
no class ends in a gap, and `EndsInGapOnRight` fails at every point — its first conjunct asks for
a non-equivalent point above. So `gapRightFormula` is not a tautology in disguise. -/
theorem not_endsInGapOnRight_epsTop {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (t : M.carrier) :
    ¬ EndsInGapOnRight M (epsTop sig) t := by
  rintro ⟨⟨y, _, hy⟩, -, -⟩
  exact hy (contempEquivDense_epsTop M t y)

/-- The same fact on the temporal side: `R` is false at every point of every Prior structure when
`ε` is `epsTop`. This is `gapRightFormula_spec` used in the refuting direction. -/
theorem not_gapRightFormula_epsTop (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    ¬ TemporalTruth M atomMap t (gapRightFormula atomMap h_surj (epsTop sig)) := by
  intro h
  exact not_endsInGapOnRight_epsTop M t
    ((gapRightFormula_spec atomMap h_surj (epsTop sig) M h_prior_U h_prior_S t).mp h)

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
