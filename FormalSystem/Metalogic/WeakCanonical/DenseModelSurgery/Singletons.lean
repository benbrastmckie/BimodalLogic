/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.NoGaps

/-!
# Reynolds §7 Theorem 5: a dense set of singleton classes, from axiom Sep

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§7 *"Separability"*, printed **p.184**.

This module lands **D2**, the second hypothesis of Doets' theorem: a Prior structure satisfying
every substitution instance of axiom Sep has, for every contemporaneous equivalence relation
whose quotient is densely ordered, a *dense set of singleton classes*.

## The source, verbatim

Printed p.184, **Theorem 5** — statement and whole proof:

> **THEOREM 5** *Suppose that `M` is a Prior structure which also satisfies every substitution
> instance of axiom Sep.*
>
> *Then for every contemporaneous equivalence relation `∼` such that `M/∼` is densely ordered,
> `M/∼` has a dense set of singletons.*
>
> **PROOF.** From the preceding theorem 4 we know that the `∼`-classes do not end at gaps. In
> fact the classes must be closed intervals: if a class has an excluded end point then this point
> is in the next class and this contradicts density.
>
> Suppose that `c < d` in `M` such that `c ≁ d`. We must show that there is a singleton class
> between the classes of `c` and `d`. Without loss of generality, `c` is the right hand end point
> of its class.
>
> Let the temporal formula `C` be true exactly at points who are the left hand end points of their
> classes. This includes the case of a singleton class. We use expressive completeness here.
>
> Now `C ∧ U(C, ¬C)` never holds in `M`, so it certainly does not hold soon after `c`, and so
> `¬K⁺(C ∧ U(C, ¬C))` holds at `c`.
>
> Also `K⁺(C)` holds at `c` so we can use axiom Sep to deduce that `K⁺(K⁺C ∧ K⁻C)` holds at `c`.
>
> Certainly `K⁺C ∧ K⁻C` must hold at some `e` between `c` and `d` but clearly `e` must be in a
> class of its own. ∎

The block above was read off the page image
(`Reynolds_1992_Axiomatization_Until_Since_without_IRR.pdf`, PDF page index 19 = printed p.184)
and not off the pre-segmented corpus chunk.

## Corpus and page-measurement notes

**Page reference, corrected.** Plan v10's Phase 23 says *"printed pp.184-185"*. Measured off the
200 dpi page images: §7 *Separability* **opens** on printed p.183, directly under Theorem 4's
statement, and Lemma 10 with its whole proof is on p.183. **Theorem 5's statement and its entire
proof fit on printed p.184 alone**, and §8 *Doets' Theorem* also opens on p.184; p.185 is already
inside §8's preliminaries. So the citation for everything in this module is `p.184`, singular.

The offset measured for §6 (`printed page = PDF 1-based page + 164`) **does** carry over to §7 —
verified page by page across PDF indices 18, 19 and 20 — but the plan's *content* attribution did
not, which is why the offset was re-measured rather than assumed.

**Corpus reliability.** §6's chunk had two recorded display defects (see `Lemma34.lean`'s
*"Lemma 4 at the boundary"*). The §7 chunk (`sec04_7-separability.md`) was compared
sentence-by-sentence against the p.183 and p.184 images and is **clean**: Theorem 5's statement
and all five proof paragraphs match the printed page. §7 carries no displayed formulas in
Theorem 5 at all — everything is inline — which is consistent with §6's finding that the corpus's
inline prose is reliable where its displays are not. **No source defect is claimed or repaired by
this module.**

## Proof step to declaration map

| Reynolds' step (printed p.184) | Declaration |
|---|---|
| *"the classes do not end at gaps"* | `no_gaps_dense_prior` / `no_gaps_dense_prior_left` (Phase 22, 22.1) |
| *"the classes must be closed intervals"*, right end | `exists_rightEndPoint` |
| *"…"*, left end | `exists_leftEndPoint` (by order duality, not a hand mirror) |
| *"Without loss of generality, `c` is the right hand end point of its class"* | `exists_rightEndPoint`, applied to `c` inside `reynolds_theorem5` |
| *"Let the temporal formula `C` be true exactly at … left hand end points"* | `leftEndFormula`, `classLeftEndFormula`, `classLeftEndFormula_spec` |
| *"We use expressive completeness here"* | `uSExpressivelyCompleteOverDensePrior` (§5 Theorem 3), consumed in `classLeftEndFormula` |
| *"`C ∧ U(C,¬C)` never holds in `M`"* | `not_leftEnd_and_untl` |
| *"…so `¬K⁺(C ∧ U(C,¬C))` holds at `c`"* | `not_kplusOpen_of_never` |
| *"Also `K⁺(C)` holds at `c`"* | `kplusOpen_classLeftEnd` |
| *"we can use axiom Sep to deduce that `K⁺(K⁺C ∧ K⁻C)` holds at `c`"* | the `h_sep` hypothesis of `reynolds_theorem5` |
| *"`K⁺C ∧ K⁻C` must hold at some `e` between `c` and `d`"* | `reynolds_theorem5`, the final `h_sep … d hc'd` |
| *"but clearly `e` must be in a class of its own"* | `isSingletonClass_of_kplus_kminus` |

*"We use expressive completeness here"* is the sentence Block D exists for. It is consumed at
exactly one place — `classLeftEndFormula` — and nowhere else in this module.

## Where Sep comes from, and where it does not

Reynolds' §7 has two halves. **Lemma 10** (Sep's validity over real flows, printed p.183) is
**not re-derived here**: `sep_valid` (`Soundness.lean:1601`) is landed and already stated at
`ValidDedekindDense`. This module consumes `Axiom.sep`'s *derivability* side — the semantic
reading of the axiom scheme at a structure — exactly as Phase 16 does for Prior-U and Prior-S.

`Axiom.sep` (`ProofSystem/Axioms.lean:420`) is stated with `Formula.kPlus` / `Formula.kMinus`.
It is read here through **Phase 10.1's bridge**, cited by name: `Kamp.kPlus_formula_correct` and
`Kamp.kMinus_formula_correct` (`Kamp/KPlusFaithful.lean:150`, `:170`), which identify
`Formula.kPlus` / `Formula.kMinus` with `Kamp.kplusOpen` / `Kamp.kminusOpen` — the faithful
`Prop`-level readings, **not** this tree's stronger `kplus` / `kminus`, which carry an extra
conjunct that is in neither Reynolds nor Rabinovich.

## `SemanticSepOpen` and the layering it preserves

`SemanticSep` (`BXCanonical/Chronicle/ChronicleMonadicBridge.lean:863`) is the same statement as
`SemanticSepOpen` below, character for character in its body. It is **restated** here rather than
imported for the reason `ChronicleInstance.lean` records: `ChronicleMonadicBridge`'s transitive
closure is roughly 280 modules, and `DenseModelSurgery/` is a low-level parametric §6/§7 layer
that must not depend on it. Nothing is removed or renamed; `SemanticSep` stands untouched.

That the two are *definitionally the same* is not asserted — it is machine-checked, at the one
place the two layers meet: `ChronicleInstance.lean` passes `hpack.sep`, a `SemanticSep`, directly
into a `SemanticSepOpen` argument. That application elaborates only if the two are defeq.

## Honest caveat, carried forward

Every §6 lemma below Lemma 2 remains **conditional**: `IsContempEquivDense ε` plus Reynolds'
Prior-U / Prior-S on `M` are hypotheses, and the only `ε` this tree can currently exhibit
satisfying them is the total relation `epsTop` (`Defs.lean:461`), for which `EndsInGapOnRight`
is empty (`not_endsInGapOnRight_epsTop`). So the results below are not discharged at any
non-trivial instance; the first live instance is due at the Lemma 9 / dense-surgery stage.

**This module inherits that caveat unchanged and adds nothing to its discharge.** Theorem 5
consumes Theorem 4, so it is conditional on everything Theorem 4 is conditional on, plus Sep and
plus the density of `M/∼`. Phase 22.1 retired the *third* condition (`HasBadIntervalSurgery`) and
the *structure* half at one named structure; the `ε` half stands until Reynolds' §8 Lemma 12
lands. `EndsInGapOnRight` being empty at `epsTop` makes an instantiation there vacuous, and
`QuotientDenselyOrdered M (epsTop sig)` is itself unsatisfiable whenever `M` has two points — so
the `epsTop` instantiation of Theorem 5 is vacuous for a *second*, independent reason, recorded
below as `quotientDenselyOrdered_epsTop_vacuous` rather than left to be rediscovered. **No §6 or
§7 result is described as discharged by this module.** See `NoGaps.lean`'s
`## Conditionality after Theorem 4` for the full three-condition accounting.

## References

- Reynolds 1992, §7 Theorem 5, printed p.184 (statement and whole proof)
- Reynolds 1992, §7 Lemma 10, printed p.183 (Sep's validity over real flows — *not* re-derived)
- Reynolds 1992, §8 Theorem 6, printed p.184 (Doets' theorem, whose D2 this is)
- `NoGaps.lean` — Theorem 4 (D1), `no_gaps_dense_prior` / `no_gaps_dense_prior_left`
- `Defs.lean` — `ContempEquivDense`, `IsContempEquivDense`, `EndsInGapOnRight` / `OnLeft`
- `Dual.lean` — the order-duality transport used for the left-hand closed-interval lemma
- `uSExpressivelyCompleteOverDensePrior` (`PriorExpressivenessDense.lean:302`) — §5 Theorem 3
- `Kamp.kplusOpen` / `Kamp.kminusOpen` (`Kamp/KPlusFaithful.lean:113`, `:126`) — Reynolds' `K⁺`/`K⁻`
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

/-! ## Class end points, singleton classes, and the two quotient properties

Reynolds names four things in §7 without defining any of them: the *right hand end point of a
class*, the *left hand end point of a class*, *`M/∼` is densely ordered* and *`M/∼` has a dense
set of singletons*. All four are stated below directly in terms of `∼` itself, with no quotient
type constructed: a class is `{y | a ∼ y}`, and every property Reynolds uses of `M/∼` is a
property of `∼` on `M`. -/

/-- **`t` is the left hand end point of its class**: nothing below `t` is contemporaneous with it.

*"the left hand end points of their classes. This includes the case of a singleton class"*
(printed p.184) — a singleton class satisfies this vacuously, which is what makes `C` true there
too. -/
def IsLeftEndPoint (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) : Prop :=
  ∀ y : M.carrier, y < t → ¬ ContempEquivDense M ε t y

/-- **`t` is the right hand end point of its class** — the mirror of `IsLeftEndPoint`.

*"Without loss of generality, `c` is the right hand end point of its class"* (printed p.184). -/
def IsRightEndPoint (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) : Prop :=
  ∀ y : M.carrier, t < y → ¬ ContempEquivDense M ε t y

/-- **`t`'s class is a singleton**: *"`e` must be in a class of its own"* (printed p.184). -/
def IsSingletonClass (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2)
    (t : M.carrier) : Prop :=
  ∀ y : M.carrier, ContempEquivDense M ε t y → y = t

/-- **`M/∼` is densely ordered** — Theorem 5's standing hypothesis, printed p.184.

Between any two distinct classes there is a third: given `a < b` in different classes, some `c`
strictly between them is in a class distinct from both. Stated on `M` rather than on a quotient
type; the two are the same condition, since a class is convex by clause (ii) of
`IsContempEquivDense`. -/
def QuotientDenselyOrdered (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2) : Prop :=
  ∀ a b : M.carrier, a < b → ¬ ContempEquivDense M ε a b →
    ∃ c : M.carrier, a < c ∧ c < b ∧
      ¬ ContempEquivDense M ε a c ∧ ¬ ContempEquivDense M ε c b

/-- **`M/∼` has a dense set of singletons** — Theorem 5's conclusion, and **D2**, the second
hypothesis of Doets' theorem (Reynolds §8 Theorem 6, printed p.184).

*"We must show that there is a singleton class between the classes of `c` and `d`"* — so between
any two points in distinct classes there is a point whose own class is a singleton. -/
def HasDenseSingletons (M : OrderedMonadicStructure sig) (ε : MonadicFormula sig 2) : Prop :=
  ∀ c d : M.carrier, c < d → ¬ ContempEquivDense M ε c d →
    ∃ e : M.carrier, c < e ∧ e < d ∧ IsSingletonClass M ε e

/-- **Axiom Sep at a structure, in the `kplusOpen` idiom** — Reynolds 1992, printed p.168:

```
Sep:   K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)
```

The body is character-for-character `SemanticSep`
(`BXCanonical/Chronicle/ChronicleMonadicBridge.lean:863`). It is restated rather than imported
purely to keep this parametric §6/§7 layer off `ChronicleMonadicBridge`'s ~280-module closure;
see the module header. `SemanticSep` is untouched, and the two are shown defeq by use, in
`ChronicleInstance.lean`. -/
def SemanticSepOpen (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (p : Formula),
    Kamp.kplusOpen M atomMap p t →
    ¬ Kamp.kplusOpen M atomMap (Formula.and p (Formula.untlQ p.neg p)) t →
    Kamp.kplusOpen M atomMap (Formula.and (Formula.kPlus p) (Formula.kMinus p)) t

/-! ## *"In fact the classes must be closed intervals"*

> *"if a class has an excluded end point then this point is in the next class and this contradicts
> density."* (printed p.184)

Reynolds' one-sentence argument, executed. `EndsInGapOnRight`'s three conjuncts are exactly
*"the class is bounded above"*, *"the class has no last point"* and *"there is no first point
above the class"*. Theorem 4 refutes their conjunction. So a class that is bounded above and has
no last point must have a *first point above it* — Reynolds' *"excluded end point"* — and that
point's class is the next class, with nothing between. Density forbids that.

The conclusion is therefore the existence of a genuine end point, which is what *"closed
interval"* means here. -/

section ClosedIntervals

variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}

/-- **A class bounded strictly above has a right hand end point** — printed p.184's *"the classes
must be closed intervals"*, right-hand half.

`hgap` is Theorem 4 (`no_gaps_dense_prior`); `hdense` is Theorem 5's standing density hypothesis;
`htx`/`hx` say the class of `t` is strictly bounded above, which is what makes the question of an
end point arise at all. -/
theorem exists_rightEndPoint (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
    (hdense : QuotientDenselyOrdered M ε)
    (hgap : ∀ t : M.carrier, ¬ EndsInGapOnRight M ε t)
    {t x : M.carrier} (htx : t < x) (hx : ¬ ContempEquivDense M ε t x) :
    ∃ r : M.carrier, ContempEquivDense M ε t r ∧ IsRightEndPoint M ε r := by
  by_contra hcon
  -- *"the class has no last point"* — `EndsInGapOnRight`'s second conjunct.
  have hno : ¬ ∃ z : M.carrier, ContempEquivDense M ε t z ∧
      ∀ y : M.carrier, z < y → ¬ ContempEquivDense M ε t y := by
    rintro ⟨z, hz, hzmax⟩
    exact hcon ⟨z, hz, fun y hzy hzyc => hzmax y hzy (contemp_trans hε M hz hzyc)⟩
  -- Theorem 4 then forces the third conjunct to fail: there IS a first point above the class.
  have h3 : ∃ z : M.carrier, t < z ∧ ¬ ContempEquivDense M ε t z ∧
      ∀ y : M.carrier, t < y → y < z → ContempEquivDense M ε t y := by
    by_contra h3'
    exact hgap t ⟨⟨x, htx, hx⟩, hno, h3'⟩
  -- *"this point is in the next class and this contradicts density"*.
  obtain ⟨z, htz, hnz, hbetween⟩ := h3
  obtain ⟨c, htc, hcz, hntc, -⟩ := hdense t z htz hnz
  exact hntc (hbetween c htc hcz)

/-- **Density transports to the order dual.** The one transport `exists_leftEndPoint` needs beyond
what `Dual.lean` already supplies. -/
theorem quotientDenselyOrdered_dual (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
    (hdense : QuotientDenselyOrdered M ε) :
    QuotientDenselyOrdered (dual M) (dualize ε) := by
  intro a b hab hnab
  obtain ⟨c, hbc, hca, hnbc, hnca⟩ := hdense b a ((d_lt (M := M) a b).mp hab)
    (fun h => hnab ((contempEquivDense_dual (M := M) ε a b).mpr (contemp_symm hε M h)))
  refine ⟨c, hca, hbc, ?_, ?_⟩
  · exact fun h => hnca (contemp_symm hε M ((contempEquivDense_dual (M := M) ε a c).mp h))
  · exact fun h => hnbc (contemp_symm hε M ((contempEquivDense_dual (M := M) ε c b).mp h))

/-- **A class bounded strictly below has a left hand end point** — printed p.184's *"the classes
must be closed intervals"*, left-hand half.

Obtained by instantiating `exists_rightEndPoint` at `(dual M, dualize ε)` through `Dual.lean`,
not by a hand-written mirror: `endsInGapOnRight_dual` exchanges the two gap predicates,
`isContempEquivDense_dualize` carries `ε`, and `quotientDenselyOrdered_dual` carries density. -/
theorem exists_leftEndPoint (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
    (hdense : QuotientDenselyOrdered M ε)
    (hgap : ∀ t : M.carrier, ¬ EndsInGapOnLeft M ε t)
    {t x : M.carrier} (hxt : x < t) (hx : ¬ ContempEquivDense M ε t x) :
    ∃ l : M.carrier, ContempEquivDense M ε t l ∧ IsLeftEndPoint M ε l := by
  have hgap' : ∀ s : (dual M).carrier, ¬ EndsInGapOnRight (dual M) (dualize ε) s := by
    intro s hs
    exact hgap s ((endsInGapOnRight_dual (M := M) ε s).mp hs)
  have hx' : ¬ ContempEquivDense (dual M) (dualize ε) (d t) (d x) := fun h =>
    hx ((contempEquivDense_dual (M := M) ε t x).mp h)
  obtain ⟨r, hr, hrend⟩ := exists_rightEndPoint (M := dual M) (ε := dualize ε)
    (isContempEquivDense_dualize hε) (quotientDenselyOrdered_dual hε hdense) hgap'
    (t := d t) (x := d x) ((d_lt t x).mpr hxt) hx'
  refine ⟨r, (contempEquivDense_dual (M := M) ε t r).mp hr, ?_⟩
  intro y hy hcon
  exact hrend (d y) ((d_lt (M := M) r y).mpr hy) ((contempEquivDense_dual (M := M) ε r y).mpr hcon)

end ClosedIntervals

/-! ## *"Let the temporal formula `C` be true exactly at … left hand end points"*

> *"This includes the case of a singleton class. We use expressive completeness here."*
> (printed p.184)

The monadic side is one formula, `∀y(y < x → ¬ε(x, y))`; the temporal side is one application of
`uSExpressivelyCompleteOverDensePrior` to it. This is the same two-step shape `Defs.lean` uses for
Lemma 2's `R`, and it is the *only* consumption of expressive completeness in §7. -/

section LeftEndFormula

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- **`x` is the left hand end point of its class**, as a monadic formula:

```
    ∀y(y < x → ¬ε(x, y))
```

De Bruijn layout: the single free variable `0` is `x`. Under the binder `0` is the bound variable
`y` and `1` is `x`. -/
def leftEndFormula (ε : MonadicFormula sig 2) : MonadicFormula sig 1 :=
  .all (.imp (.lt 0 1) (.not (epsAt ε 1 0)))

/-- Environment lookup at index `1` under one binder: the free variable `x`. -/
private theorem consLE_one {α : Type*} (x t : α) :
    (Fin.cons x (fun _ : Fin 1 => t) : Fin 2 → α) 1 = t := rfl

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The `leftEndFormula` transcription is correct**: evaluating it at `t` is exactly
`IsLeftEndPoint M ε t`. Checked rather than asserted, as `rhoFormula_eval` is for `ρ`. -/
theorem leftEndFormula_eval (M : OrderedMonadicStructure sig)
    (ε : MonadicFormula sig 2) (t : M.carrier) :
    eval M (fun _ => t) (leftEndFormula ε) ↔ IsLeftEndPoint M ε t := by
  simp only [leftEndFormula, IsLeftEndPoint, eval, eval_imp, eval_epsAt, Fin.cons_zero,
    consLE_one]

/-- **`C`** — the `{U,S}`-formula of Theorem 5, printed p.184: the temporal equivalent of
*"`x` is the left hand end point of its class"*, produced by
`uSExpressivelyCompleteOverDensePrior` (§5 Theorem 3).

*"We use expressive completeness here"* — this declaration is that sentence, and the only place
in §7 where expressive completeness is consumed.

Produced from `ε`, `atomMap` and `h_surj` alone: no structure is supplied, so a single `C` serves
every Prior structure, exactly as Lemma 2's `R` does. -/
noncomputable def classLeftEndFormula (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) : Formula :=
  (uSExpressivelyCompleteOverDensePrior atomMap h_surj (leftEndFormula ε)).val

/-- **`C` holds exactly at the left hand end points of classes**, in every Prior structure. -/
theorem classLeftEndFormula_spec (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (ε : MonadicFormula sig 2) (M : OrderedMonadicStructure sig)
    (h_prior_U : SemanticPriorU M atomMap) (h_prior_S : SemanticPriorS M atomMap)
    (t : M.carrier) :
    TemporalTruth M atomMap t (classLeftEndFormula atomMap h_surj ε) ↔ IsLeftEndPoint M ε t :=
  ((uSExpressivelyCompleteOverDensePrior atomMap h_surj (leftEndFormula ε)).property
    M h_prior_U h_prior_S t).symm.trans (leftEndFormula_eval M ε t)

end LeftEndFormula

/-! ## The three steps between `C` and Sep

> *"Now `C ∧ U(C, ¬C)` never holds in `M`, so it certainly does not hold soon after `c`, and so
> `¬K⁺(C ∧ U(C, ¬C))` holds at `c`. Also `K⁺(C)` holds at `c` …"* (printed p.184)

Both facts are consequences of density alone, given that classes are closed intervals. They are
stated for an arbitrary `C` satisfying the left-end-point spec, so that nothing here depends on
how `C` was produced. -/

section SepInputs

variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}
variable {atomMap : Formula → sig.preds}

/-- **`C ∧ U(C, ¬C)` never holds in `M`** — printed p.184.

If `x` is a left hand end point and `y > x` is the *next* left hand end point with none strictly
between, then `x ≁ y`, so density supplies a class strictly between them, and that class's own
left hand end point lies strictly between `x` and `y`. Contradiction.

The step where the class strictly between is shown to *have* a left hand end point is exactly
where *"the classes must be closed intervals"* is consumed. -/
theorem not_leftEnd_and_untl (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
    (hdense : QuotientDenselyOrdered M ε)
    (hgapL : ∀ t : M.carrier, ¬ EndsInGapOnLeft M ε t)
    {C : Formula} (hC : ∀ s : M.carrier, TemporalTruth M atomMap s C ↔ IsLeftEndPoint M ε s)
    (x : M.carrier) :
    ¬ TemporalTruth M atomMap x (Formula.and C (Formula.untlQ C.neg C)) := by
  rw [Kamp.temporal_truth_and]
  rintro ⟨hCx, y, hxy, hCy, hmid⟩
  have hxend : IsLeftEndPoint M ε x := (hC x).mp hCx
  have hyend : IsLeftEndPoint M ε y := (hC y).mp hCy
  -- `x ≁ y`: `y` is a left hand end point and `x < y`.
  have hnxy : ¬ ContempEquivDense M ε x y := fun h =>
    hyend x hxy (contemp_symm hε M h)
  obtain ⟨c, hxc, hcy, hnxc, hncy⟩ := hdense x y hxy hnxy
  -- `c`'s class is strictly bounded below by `x`, so it has a left hand end point.
  obtain ⟨l, hcl, hlend⟩ := exists_leftEndPoint hε hdense hgapL hxc
    (fun h => hnxc (contemp_symm hε M h))
  -- `x < l`: otherwise convexity puts `x` in `c`'s class.
  have hxl : x < l := by
    rcases lt_trichotomy x l with h | h | h
    · exact h
    · subst h; exact absurd (contemp_symm hε M hcl) hnxc
    · exact absurd (contemp_trans hε M
        (contemp_symm hε M (contemp_of_between hε M h.le hxc.le (contemp_symm hε M hcl)))
        (contemp_symm hε M hcl)) hnxc
  -- `l < y`: otherwise convexity puts `y` in `c`'s class.
  have hly : l < y := by
    by_contra hcon
    exact hncy (contemp_of_between hε M hcy.le (not_lt.mp hcon) hcl)
  -- But then `C` holds at `l`, strictly between `x` and `y`.
  exact ((Kamp.temporal_truth_neg M atomMap l C).mp (hmid l hxl hly)) ((hC l).mpr hlend)

/-- **A formula that never holds is not `K⁺`-true anywhere with a point above it** — printed
p.184's *"so it certainly does not hold soon after `c`"*. -/
theorem not_kplusOpen_of_never {P : Formula}
    (hnever : ∀ x : M.carrier, ¬ TemporalTruth M atomMap x P)
    {c d : M.carrier} (hcd : c < d) : ¬ Kamp.kplusOpen M atomMap P c := by
  intro h
  obtain ⟨r, -, -, hr⟩ := h d hcd
  exact hnever r hr

/-- **`K⁺(C)` holds at a right hand end point** — printed p.184's *"Also `K⁺(C)` holds at `c`"*.

Given any `s > c`: since `c` is the right hand end point of its class, `c ≁ s`, so density
supplies a class strictly between, and (classes being closed intervals) that class's left hand end
point lies strictly between `c` and `s`. So `C` holds arbitrarily soon after `c`. -/
theorem kplusOpen_classLeftEnd (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
    (hdense : QuotientDenselyOrdered M ε)
    (hgapL : ∀ t : M.carrier, ¬ EndsInGapOnLeft M ε t)
    {C : Formula} (hC : ∀ s : M.carrier, TemporalTruth M atomMap s C ↔ IsLeftEndPoint M ε s)
    {c : M.carrier} (hc : IsRightEndPoint M ε c) : Kamp.kplusOpen M atomMap C c := by
  intro s hcs
  obtain ⟨m, hcm, hms, hncm, hnms⟩ := hdense c s hcs (hc s hcs)
  obtain ⟨l, hml, hlend⟩ := exists_leftEndPoint hε hdense hgapL hcm
    (fun h => hncm (contemp_symm hε M h))
  have hcl : c < l := by
    rcases lt_trichotomy c l with h | h | h
    · exact h
    · subst h; exact absurd (contemp_symm hε M hml) hncm
    · exact absurd (contemp_trans hε M
        (contemp_symm hε M (contemp_of_between hε M h.le hcm.le (contemp_symm hε M hml)))
        (contemp_symm hε M hml)) hncm
  have hls : l < s := by
    by_contra hcon
    exact hnms (contemp_of_between hε M hms.le (not_lt.mp hcon) hml)
  exact ⟨l, hcl, hls, (hC l).mpr hlend⟩

/-- **`K⁺C ∧ K⁻C` forces a singleton class** — printed p.184's *"but clearly `e` must be in a
class of its own"*.

If some `y ≠ e` were contemporaneous with `e`, then the whole closed interval between them lies
in `e`'s class; but `K⁺C` (resp. `K⁻C`) puts a left hand end point strictly inside that interval,
and a left hand end point of `e`'s own class cannot have a class-mate strictly below it.

No gap lemma is consumed here: `y` itself supplies the bound that `K⁺`/`K⁻` is applied at. -/
theorem isSingletonClass_of_kplus_kminus (hε : IsContempEquivDenseOn ε C) [InStructureClass C M]
    {C : Formula} (hC : ∀ s : M.carrier, TemporalTruth M atomMap s C ↔ IsLeftEndPoint M ε s)
    {e : M.carrier} (hp : Kamp.kplusOpen M atomMap C e) (hm : Kamp.kminusOpen M atomMap C e) :
    IsSingletonClass M ε e := by
  intro y hy
  rcases lt_trichotomy y e with h | h | h
  · -- `y < e`: `K⁻C` gives a left hand end point `r ∈ (y, e)`, which is class-mate to `y < r`.
    obtain ⟨r, hyr, hre, hrC⟩ := hm y h
    have hrend : IsLeftEndPoint M ε r := (hC r).mp hrC
    have hyr' : ContempEquivDense M ε y r :=
      contemp_of_between hε M hyr.le hre.le (contemp_symm hε M hy)
    exact absurd (contemp_symm hε M hyr') (hrend y hyr)
  · exact h
  · -- `e < y`: `K⁺C` gives a left hand end point `r ∈ (e, y)`, which is class-mate to `e < r`.
    obtain ⟨r, her, hry, hrC⟩ := hp y h
    have hrend : IsLeftEndPoint M ε r := (hC r).mp hrC
    have her' : ContempEquivDense M ε e r := contemp_of_between hε M her.le hry.le hy
    exact absurd (contemp_symm hε M her') (hrend e her)

end SepInputs

/-! ## Theorem 5

> **THEOREM 5** *Suppose that `M` is a Prior structure which also satisfies every substitution
> instance of axiom Sep. Then for every contemporaneous equivalence relation `∼` such that `M/∼`
> is densely ordered, `M/∼` has a dense set of singletons.* (printed p.184)

Reynolds' five proof paragraphs, in order. Theorem 4 is consumed at the top — both ends — and is
not re-proved; the *"without loss of generality"* is discharged rather than assumed, by moving `c`
to the right hand end point of its own class via `exists_rightEndPoint`. -/

section Theorem5

variable [Fintype sig.preds] [DecidableEq sig.preds]
variable {M : OrderedMonadicStructure sig} {ε : MonadicFormula sig 2}

/-- **Reynolds 1992, §7 Theorem 5, printed p.184.**

> *Suppose that `M` is a Prior structure which also satisfies every substitution instance of axiom
> Sep.*
>
> *Then for every contemporaneous equivalence relation `∼` such that `M/∼` is densely ordered,
> `M/∼` has a dense set of singletons.*

This is **D2**, the second hypothesis of Doets' theorem (Reynolds §8 Theorem 6, printed p.184).

`no_gaps_dense_prior` and `no_gaps_dense_prior_left` (Theorem 4, D1) are consumed inside, so
Theorem 4 is *not* an extra hypothesis: the Prior pair that Theorem 4 needs is already here.

**Still conditional**, and on exactly what Theorem 4 is conditional on plus Sep and density:
`IsContempEquivDense ε` remains a hypothesis, and no non-trivial `ε` is available in this tree.
See the module header's *"Honest caveat, carried forward"*. -/
theorem reynolds_theorem5 (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] [IsSurgeryClosed C]
    (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (h_sep : SemanticSepOpen M atomMap)
    (hdense : QuotientDenselyOrdered M ε) :
    HasDenseSingletons M ε := by
  intro c d hcd hncd
  -- *"From the preceding theorem 4 we know that the `∼`-classes do not end at gaps."*
  have hgapR : ∀ t : M.carrier, ¬ EndsInGapOnRight M ε t :=
    no_gaps_dense_prior atomMap h_surj hε h_prior_U h_prior_S
  have hgapL : ∀ t : M.carrier, ¬ EndsInGapOnLeft M ε t :=
    no_gaps_dense_prior_left atomMap h_surj hε h_prior_U h_prior_S
  -- *"Without loss of generality, `c` is the right hand end point of its class."*
  obtain ⟨c', hcc', hc'⟩ := exists_rightEndPoint hε hdense hgapR hcd hncd
  have hcc'le : c ≤ c' := by
    by_contra hcon
    exact hc' c (not_le.mp hcon) (contemp_symm hε M hcc')
  have hc'd : c' < d := by
    rcases lt_trichotomy c' d with h | h | h
    · exact h
    · subst h; exact absurd hcc' hncd
    · exact absurd (contemp_of_between hε M hcd.le h.le hcc') hncd
  -- *"Let the temporal formula `C` be true exactly at … left hand end points …"*
  have hC := classLeftEndFormula_spec atomMap h_surj ε M h_prior_U h_prior_S
  -- *"Now `C ∧ U(C, ¬C)` never holds in `M`, … so `¬K⁺(C ∧ U(C, ¬C))` holds at `c`."*
  have h2 : ¬ Kamp.kplusOpen M atomMap
      (Formula.and (classLeftEndFormula atomMap h_surj ε)
        (Formula.untlQ (classLeftEndFormula atomMap h_surj ε).neg
          (classLeftEndFormula atomMap h_surj ε))) c' :=
    not_kplusOpen_of_never (not_leftEnd_and_untl hε hdense hgapL hC) hc'd
  -- *"Also `K⁺(C)` holds at `c` …"*
  have h1 : Kamp.kplusOpen M atomMap (classLeftEndFormula atomMap h_surj ε) c' :=
    kplusOpen_classLeftEnd hε hdense hgapL hC hc'
  -- *"… so we can use axiom Sep to deduce that `K⁺(K⁺C ∧ K⁻C)` holds at `c`."*
  have h3 := h_sep c' (classLeftEndFormula atomMap h_surj ε) h1 h2
  -- *"Certainly `K⁺C ∧ K⁻C` must hold at some `e` between `c` and `d` …"*
  obtain ⟨e, hce, hed, he⟩ := h3 d hc'd
  rw [Kamp.temporal_truth_and, Kamp.kPlus_formula_correct, Kamp.kMinus_formula_correct] at he
  -- *"… but clearly `e` must be in a class of its own."*
  exact ⟨e, lt_of_le_of_lt hcc'le hce, hed,
    isSingletonClass_of_kplus_kminus hε hC he.1 he.2⟩

/-- **D2, the second hypothesis of Doets' theorem** — Reynolds §8 Theorem 6, printed p.184:

> **D2)**: *if `M/∼` is densely ordered, then `M/∼` has a dense set of singletons.*

`reynolds_theorem5` in the shape §8 consumes it: density of the quotient as an antecedent rather
than as a standing hypothesis. The Sep hypothesis is Reynolds' *"`M` … also satisfies every
substitution instance of axiom Sep"*, and the Prior pair is *"`M` is a Prior structure"*. -/
theorem dense_singletons_of_sep (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (hε : IsContempEquivDenseOn ε C) [InStructureClass C M] [IsSurgeryClosed C]
    (h_prior_U : SemanticPriorU M atomMap)
    (h_prior_S : SemanticPriorS M atomMap) (h_sep : SemanticSepOpen M atomMap) :
    QuotientDenselyOrdered M ε → HasDenseSingletons M ε :=
  fun hdense => reynolds_theorem5 atomMap h_surj hε h_prior_U h_prior_S h_sep hdense

end Theorem5

/-! ## Anti-vacuity, stated honestly

The `epsTop` instantiation is vacuous **twice over**, and both reasons are recorded here rather
than left to be rediscovered:

1. `EndsInGapOnRight` is empty at `epsTop` (`not_endsInGapOnRight_epsTop`), which is the standing
   §6 reason;
2. `QuotientDenselyOrdered M (epsTop sig)` is itself *unsatisfiable* whenever `M` has two
   distinct points, since `epsTop`'s single class is the whole structure and the definition's
   `¬ ContempEquivDense` antecedent can never be met.

So Theorem 5 at `epsTop` has an unsatisfiable hypothesis, not merely a trivial conclusion. A live
non-trivial `ε` is Reynolds' §8 Lemma 12 and is not in this tree. -/

/-- **`QuotientDenselyOrdered` is unsatisfiable at `epsTop`** on any structure with two distinct
points: the hypothesis `¬ ContempEquivDense M (epsTop sig) a b` is never met.

Recorded so that no reader mistakes an `epsTop` instantiation of Theorem 5 for a non-trivial
instance of §7. -/
theorem quotientDenselyOrdered_epsTop_vacuous (M : OrderedMonadicStructure sig)
    (a b : M.carrier) (_hab : a < b) :
    ¬ ¬ ContempEquivDense M (epsTop sig) a b :=
  fun h => h (contempEquivDense_epsTop M a b)

end FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery
