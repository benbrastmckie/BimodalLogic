/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Init
import FormalSystem.Semantics.Presheaf.Site

/-!
# The duration monoid `BD⁺` and the twisted-arrow site

The categorical description of the interval site `Int(D)` of `Semantics/Presheaf/Site.lean`. The
**duration monoid** `BD⁺` is the one-object category whose morphisms are the durations — the
positive cone `D⁺` of a temporal order — composing by addition with identity `0`. Each duration `l`
has a **factorization category** `Fact(l)`: its objects are the factorizations `l = x + y` with
`x, y ∈ D⁺`, and its morphisms `(x, y) → (x', y')` are the durations `z ∈ D⁺` with `z + x = x'` and
`y = z + y'`. `BD⁺` is **factorization-linear**: every `Fact(l)` is a linear preorder, any two
factorizations being related by at most one morphism and by at least one in one direction or the
other. This module proves that, and it is the first conjunct of the lemma the paper states about
the duration monoid; the second conjunct — that the twisted-arrow category `Tw(BD⁺)` is isomorphic
to `Int(D)` by an isomorphism of sites — is the subject of the second half of this file.

This module is stated over a bare `{D : TemporalOrder}` and imports `Site.lean` alone: it needs
no task frame, no world state and no history theory, only the order and group structure of the
carrier, which is what keeps it below `Semantics/PartialHistory.lean` and therefore below
`Semantics/Truth.lean` in the layering, with the same `assert_not_exists` lock as `Site.lean`.

## Main Definitions

- `Dur D`: the morphisms of the duration monoid `BD⁺`, namely `TemporalOrder.PositiveCone D`.
  Equal to `Obj D` by design — the objects of `Int(D)` *are* the morphisms of `BD⁺` — the alias
  exists so that a docstring can say which role a duration is playing.
- `Dur.comp`, `Dur.id`: composition in `BD⁺`, which adds durations, and its identity `0`.
- `Factorization l`: a factorization `l = fst + snd` of a duration into two durations.
- `Factorization.Hom a b`: a morphism `a → b` of the factorization category `Fact(l)` — a duration
  `z` with `z + a.fst = b.fst` and `a.snd = z + b.snd`.
- `Factorization.homOfLe`: the comparison morphism `a → b` whenever `a.fst ≤ b.fst`, with
  `z := b.fst - a.fst`.
- `Factorization.ofCut`: the factorization `l = p + (l - p)` determined by a cut point
  `p ∈ [0, l]`.
- `Tw l' l`: the morphisms `l' → l` of the twisted-arrow category `Tw(BD⁺)` — the paper's pairs
  `(p, q)` of durations with `p + l' + q = l`, as `pre`/`post`. Its objects are the morphisms of
  `BD⁺`, i.e. `Obj D` again.
- `Tw.id`, `Tw.comp`: the identity `(0, 0)` and composition `(p, q) ∘ (p', q') = (p + p', q' + q)`.
- `Tw.toTr`, `Tw.ofTr`: the hom-set maps `(p, q) ↦ Tr p` and `Tr p ↦ (p, l - p - l')` between
  `Tw(BD⁺)` and `Int(D)`.
- `Tw.coverLeft`, `Tw.coverRight`: the two members `(0, l - p) : p → l` and `(p, 0) : (l - p) → l`
  of the Johnstone covering family of `l` in `Tw(BD⁺)`, indexed by the cut point `p` exactly as
  `Site.lean`'s are.

## Main Results

- `Dur.id_comp`, `Dur.comp_id`, `Dur.comp_assoc`, `Dur.comp_comm`: `BD⁺` is a commutative monoid.
  Together with `Dur.id` and `Dur.comp` these are exactly the data of a one-object category.
- `Factorization.ext`: a factorization is determined by its first summand alone.
- `Factorization.hom_unique`, `Factorization.hom_total`: **factorization-linearity** of `BD⁺`,
  in the two halves the paper's definition names — at most one morphism between any two
  factorizations, and at least one in one direction or the other. Only the second half consumes
  totality of the order on `D`; the first is cancellation alone.
- `Factorization.fst_le`, `Factorization.ofCut_fst`, `Factorization.ofCut_fst_self`: the
  factorizations of `l` correspond bijectively to the cut points `p ∈ [0, l]`, with
  `snd = l - p`. This is the step that upgrades the isomorphism of categories below to an
  isomorphism of *sites*.
- `Tw.id_comp`, `Tw.comp_id`, `Tw.comp_assoc`: the three category laws of `Tw(BD⁺)`. With `Tw.id`
  and `Tw.comp` these are exactly the fields a `Category` instance would need.
- `Tw.toTr_ofTr`, `Tw.ofTr_toTr`: the hom-set map is a bijection — surjective and injective
  respectively.
- `Tw.toTr_comp`, `Tw.toTr_id`: the hom-set map is functorial. Identity on objects plus bijective
  on homs: `Tw(BD⁺) ≅ Int(D)` as categories.
- `Tw.toTr_coverLeft`, `Tw.toTr_coverRight`: **coverage transport** — the isomorphism carries the
  Johnstone covering family of `Tw(BD⁺)` at a cut point to that of `Int(D)` at the same cut point,
  both by `rfl`. With the cut-point bijection above, the correspondence of covering families is
  itself a bijection, so the isomorphism is one of sites: this is the second conjunct of the
  paper's lemma, and `Int(D)` is thereby the interval site of Schultz, Spivak and Vasilakopoulou at
  the positive cone of an arbitrary temporal order.

## Implementation Notes

**Concrete structures, no `Mathlib.CategoryTheory` — reconciled with `Site.lean`'s note, not
decided afresh.** `Site.lean`'s Implementation Notes record the concrete-structures decision for
`Int(D)` and nominate "the duration monoid `BD⁺` and the twisted-arrow description of this site" as
the places where anyone wanting the categorical packaging should add a `Category` instance and
reconcile with that note. This module is that reconciliation, and it keeps the concrete route, for
reasons specific to its content. Mathlib has no twisted-arrow category, no factorization category
and no notion of factorization-linearity, so all three — and the Johnstone coverage on `Tw(BD⁺)` —
are hand-rolled under either encoding; the Mathlib route would buy only `Category` bookkeeping for
laws this module proves in one line each. What Mathlib does supply for the monoid,
`CategoryTheory.SingleObj`, is multiplicative where `BD⁺` is additive, so even `BD⁺` would reach it
only through `Multiplicative`. And the concrete route keeps this module buildable from `Site.lean`
alone, which is what keeps it below `Semantics/Truth.lean`. The trade-off is stated so it is not
re-litigated: the categorical vocabulary becomes genuinely useful one module later, when the path
category `Path(F)` and the discrete Conduché fibrations are stated, and that is the point at which
introducing `Mathlib.CategoryTheory` to the live tree should be weighed. The decision is reversible
without changing a definition here: `Dur.id`/`Dur.comp` with the three monoid laws, and — in the
second half of this file — `Tw.id`/`Tw.comp` with the three category laws, are exactly the fields a
`CategoryStruct`/`Category` instance would need.

**`BD⁺` is a hand-rolled `comp`/`id` pair, not Mathlib's monoid on the nonneg subtype.**
`Mathlib.Algebra.Order.Nonneg.Basic` would give `AddCommMonoid (TemporalOrder.PositiveCone D)`
directly, with `(a + b).val = a.val + b.val` by `rfl`. It is not imported: neither
`TemporalOrder.lean` nor `Site.lean` imports it, the hand-rolled pair compiles with no new import,
it matches `Site.lean`'s idiom of durations as elements of `↑D` carrying a nonnegativity side
condition, and an `AddCommMonoid (Obj D)` instance would otherwise be in scope for every later
importer of this module and could change how `+` elaborates there. If the cluster later wants
subtype arithmetic on the cone, that is the import to add, and adding it changes no definition
here.

**The factorization category is `Factorization`, never `Fact`.** The paper writes `Fact(l)`, but
`Fact : Prop → Prop` is Mathlib's typeclass-carried-proposition class; a namespace-local `Fact`
would shadow it and make `Fact.out` ambiguous inside this namespace.

**`Factorization.Hom` is a declaration of its own, not folded into the two linearity theorems.**
The morphism identification — `z` with `z + x = x'` and `y = z + y'` — is the load-bearing step of
factorization-linearity: without it the inference from "at most one `z`" and "some `z` in one
direction" to "linear preorder" is not visible. The verification report of record for this lemma
(archived in the paper's own repository) records the omission of exactly this identification as
the first defect of an earlier draft of the paper's proof; carrying it as a named structure keeps
the Lean statement from reproducing that defect.

**Why `hom_unique` cancels on the left.** Both `left` fields read `z + a.fst = b.fst`, so the
natural cancellation is `add_right_cancel`. At `↑D` that lemma drags `Classical.choice` into the
axiom footprint, where the commuted form — rewrite both sides to `a.fst + z` and apply
`add_left_cancel` — stays at `[propext]`. The Presheaf README publishes a per-declaration
footprint table, so the commuted form is used throughout this module.

**Paper state: the source appendix is cut.** Every paper anchor cited below lives in the appendix
`app:Structure`, which the paper **cut in full** under an explicit `% SECTION CUT` record, and
whose surviving commented block carries a bare `% CHECK` — the author has not finished reviewing
this material. Every anchor therefore resolves against
`docs/reference/paper-definitions-of-record.md`, where each carries a `DANGLING` row, and not
against a live `\label{}` in the paper; `scripts/check-paper-definitions.sh --resolve`
structurally cannot pin a commented-out label, so none of them is pinned. The mathematics here is
checked by Lean regardless of the appendix's fate, but its *correspondence to the paper* is
pinned to a record rather than to live text.

## References

* [P. Schultz, D. I. Spivak and C. Vasilakopoulou, *Dynamical Systems and Sheaves*][schultz2020],
  Defs. 3.1.3, 3.1.5 and 3.2.1 — the twisted-arrow category and the interval site, and
  Prop. 3.1.4, whose `ℝ≥0` and `ℕ` instances the lemma below generalizes to the positive cone of
  an arbitrary temporal order
* [P. T. Johnstone, *A Note on Discrete Conduché Fibrations*][johnstone1999], §2 — the
  factorization category, factorization-linearity, and the coverage
* JPL paper `def:interval-site` — the duration monoid `BD⁺` (its *Duration Monoid* item) and the
  interval category `Int(D)`. **`DANGLING`**: cut from the paper with `app:Structure` and
  recorded in `docs/reference/paper-definitions-of-record.md`
* JPL paper `def:twisted-arrow` — the factorization category, factorization-linearity, the
  twisted-arrow category and its Johnstone coverage. **`DANGLING`**, as above
* JPL paper `lem:factorization-linear` — factorization-linearity of `BD⁺`, the first conjunct of
  the lemma below. **`DANGLING`**, as above
* JPL paper `lem:interval-twisted-arrow` — `BD⁺` is factorization-linear and `Tw(BD⁺) ≅ Int(D)`
  as sites. **`DANGLING`**, as above
* JPL paper `app:Structure` — the cut appendix containing all four. **`DANGLING`**, as above
* `FormalSystem/Semantics/Presheaf/Site.lean` — `Obj`, `Tr`, the category laws and the coverage
  of `Int(D)`, and the Implementation Note this module reconciles with
* `FormalSystem/Semantics/TemporalOrder.lean` — `TemporalOrder.PositiveCone`, the durations
-/

namespace FormalSystem.Semantics.Presheaf

variable {D : TemporalOrder}

/-- The morphisms of the duration monoid `BD⁺`: the durations, i.e. the positive cone of `D`.
Equal to `Obj D` by design — the objects of `Int(D)` are the morphisms of `BD⁺` — and aliased so
that a statement can name the role a duration is playing. -/
abbrev Dur (D : TemporalOrder) : Type := TemporalOrder.PositiveCone D

namespace Dur

/-- Composition in `BD⁺`: durations compose by addition. -/
def comp (a b : Dur D) : Dur D := ⟨a.val + b.val, add_nonneg a.2 b.2⟩

/-- The identity of `BD⁺`: the zero duration. -/
def id : Dur D := ⟨0, le_refl 0⟩

/-- The value of a composite is the sum of the values. -/
@[simp] theorem comp_val (a b : Dur D) : (comp a b).val = a.val + b.val := rfl

/-- The identity has value `0`. -/
@[simp] theorem id_val : (id : Dur D).val = 0 := rfl

/-- Left unit law of `BD⁺`. -/
theorem id_comp (a : Dur D) : comp id a = a := by ext; simp

/-- Right unit law of `BD⁺`. -/
theorem comp_id (a : Dur D) : comp a id = a := by ext; simp

/-- Associativity of composition in `BD⁺`. -/
theorem comp_assoc (a b c : Dur D) : comp (comp a b) c = comp a (comp b c) := by
  ext; simp [add_assoc]

/-- Commutativity of composition in `BD⁺`: the duration monoid is the positive cone of an
abelian group, so it is commutative. Recorded because the paper's definition states it; nothing
below consumes it. -/
theorem comp_comm (a b : Dur D) : comp a b = comp b a := by ext; simp [add_comm]

end Dur

/-- An object of the factorization category `Fact(l)`: a factorization `l = fst + snd` of the
duration `l` into two durations. -/
structure Factorization (l : Obj D) where
  /-- The first summand. -/
  fst : ↑D
  /-- The second summand. -/
  snd : ↑D
  /-- The first summand is a duration. -/
  fst_nonneg : 0 ≤ fst
  /-- The second summand is a duration. -/
  snd_nonneg : 0 ≤ snd
  /-- The two summands factor `l`. -/
  add_eq : fst + snd = l.val

namespace Factorization

/-- A factorization of `l` is determined by its first summand: the second is forced by
cancellation in the two `add_eq` fields. -/
@[ext] theorem ext {l : Obj D} {a b : Factorization l} (h : a.fst = b.fst) : a = b := by
  obtain ⟨x, y, hx, hy, hxy⟩ := a
  obtain ⟨x', y', hx', hy', hxy'⟩ := b
  have hx_eq : x = x' := h
  subst hx_eq
  have hy_eq : y = y' := add_left_cancel (hxy.trans hxy'.symm)
  subst hy_eq
  rfl

/-- A morphism `a → b` of the factorization category `Fact(l)`: a duration `z` with
`z + a.fst = b.fst` and `a.snd = z + b.snd`, i.e. the amount by which the cut point moves right.
This is the morphism identification of the paper's definition, carried as its own declaration
because factorization-linearity is not visible without it. -/
structure Hom {l : Obj D} (a b : Factorization l) where
  /-- The duration by which the cut point moves. -/
  z : ↑D
  /-- The shift is a duration. -/
  z_nonneg : 0 ≤ z
  /-- The first summands differ by the shift. -/
  left : z + a.fst = b.fst
  /-- The second summands differ by the shift, the other way round. -/
  right : a.snd = z + b.snd

/-- **Factorization-linearity, first half**: any two factorizations are related by at most one
morphism — `z` is forced to equal `b.fst - a.fst`. Proved by a commuted `add_left_cancel`, not
`add_right_cancel`, to keep the footprint at `[propext]`; see the Implementation Notes. -/
theorem hom_unique {l : Obj D} {a b : Factorization l} (f g : Hom a b) : f = g := by
  obtain ⟨z, hz, hl, hr⟩ := f
  obtain ⟨z', hz', hl', hr'⟩ := g
  have h : z = z' := by
    have h1 : a.fst + z = a.fst + z' := by
      rw [add_comm a.fst z, add_comm a.fst z', hl, hl']
    exact add_left_cancel h1
  subst h
  rfl

/-- The comparison morphism `a → b` available whenever `a.fst ≤ b.fst`, with shift
`b.fst - a.fst`. -/
def homOfLe {l : Obj D} {a b : Factorization l} (h : a.fst ≤ b.fst) : Hom a b :=
  ⟨b.fst - a.fst, sub_nonneg.mpr h, sub_add_cancel b.fst a.fst, by
    rw [sub_add_eq_add_sub, eq_sub_iff_add_eq, add_comm a.snd a.fst]
    exact a.add_eq.trans b.add_eq.symm⟩

/-- **Factorization-linearity, second half**: any two factorizations are related by at least one
morphism in one direction or the other. This is the half that consumes totality of the order on
`D`. With `hom_unique`, `Fact(l)` is a linear preorder for every `l`. -/
theorem hom_total {l : Obj D} (a b : Factorization l) :
    Nonempty (Hom a b) ∨ Nonempty (Hom b a) := by
  rcases le_total a.fst b.fst with h | h
  · exact Or.inl ⟨homOfLe h⟩
  · exact Or.inr ⟨homOfLe h⟩

/-- The first summand of a factorization of `l` is a cut point of `[0, l]`. -/
theorem fst_le {l : Obj D} (a : Factorization l) : a.fst ≤ l.val := by
  rw [← a.add_eq]; exact le_add_of_nonneg_right a.snd_nonneg

/-- The factorization `l = p + (l - p)` determined by a cut point `p ∈ [0, l]`. -/
def ofCut (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) : Factorization l :=
  ⟨p, l.val - p, hp, sub_nonneg.mpr hpl, add_sub_cancel p l.val⟩

/-- The cut point of `ofCut l p` is `p`. -/
theorem ofCut_fst (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    (ofCut l p hp hpl).fst = p := rfl

/-- Every factorization is the one determined by its own cut point: with `ofCut_fst`, the
factorizations of `l` correspond bijectively to the cut points `p ∈ [0, l]`. -/
theorem ofCut_fst_self {l : Obj D} (a : Factorization l) :
    ofCut l a.fst a.fst_nonneg a.fst_le = a := by ext; rfl

end Factorization

/-- A morphism `l' → l` of the twisted-arrow category `Tw(BD⁺)`: the paper's pair `(p, q)` of
durations with `p + l' + q = l`, written `pre` and `post` — the duration before the inner window
`l'` and the duration after it. The objects of `Tw(BD⁺)` are the morphisms of `BD⁺`, i.e. the
durations, so the object type is `Obj D` as for `Int(D)`. -/
structure Tw (l' l : Obj D) where
  /-- The duration before the inner window: the paper's `p`. -/
  pre : ↑D
  /-- The duration after the inner window: the paper's `q`. -/
  post : ↑D
  /-- `pre` is a duration. -/
  pre_nonneg : 0 ≤ pre
  /-- `post` is a duration. -/
  post_nonneg : 0 ≤ post
  /-- The pair factors `l` through `l'`. -/
  factors : pre + l'.val + post = l.val

namespace Tw

/-- Twisted arrows between fixed objects are determined by their two components. -/
@[ext] theorem ext {l' l : Obj D} {f g : Tw l' l} (h₁ : f.pre = g.pre) (h₂ : f.post = g.post) :
    f = g := by
  obtain ⟨p, q, hp, hq, hf⟩ := f
  obtain ⟨p', q', hp', hq', hg⟩ := g
  have h1 : p = p' := h₁
  have h2 : q = q' := h₂
  subst h1
  subst h2
  rfl

/-- The identity `(0, 0) : l → l` of `Tw(BD⁺)`. -/
def id (l : Obj D) : Tw l l := ⟨0, 0, le_refl 0, le_refl 0, by simp⟩

/-- Composition in `Tw(BD⁺)`, in the paper's order: `(p, q) ∘ (p', q') = (p + p', q' + q)`. The
`factors` equation substitutes `l' = p' + l'' + q'` into `p + l' + q = l`. -/
def comp {l'' l' l : Obj D} (f : Tw l' l) (g : Tw l'' l') : Tw l'' l :=
  ⟨f.pre + g.pre, g.post + f.post, add_nonneg f.pre_nonneg g.pre_nonneg,
    add_nonneg g.post_nonneg f.post_nonneg, by
    calc f.pre + g.pre + l''.val + (g.post + f.post)
        = f.pre + (g.pre + l''.val + g.post) + f.post := by simp only [add_assoc]
      _ = f.pre + l'.val + f.post := by rw [g.factors]
      _ = l.val := f.factors⟩

/-- The `pre` component of a composite is the sum of the `pre` components. -/
@[simp] theorem comp_pre {l'' l' l : Obj D} (f : Tw l' l) (g : Tw l'' l') :
    (comp f g).pre = f.pre + g.pre := rfl

/-- The `post` component of a composite is the sum of the `post` components, inner first. -/
@[simp] theorem comp_post {l'' l' l : Obj D} (f : Tw l' l) (g : Tw l'' l') :
    (comp f g).post = g.post + f.post := rfl

/-- The identity has `pre` component `0`. -/
@[simp] theorem id_pre (l : Obj D) : (id l).pre = 0 := rfl

/-- The identity has `post` component `0`. -/
@[simp] theorem id_post (l : Obj D) : (id l).post = 0 := rfl

/-- Left unit law of `Tw(BD⁺)`. -/
theorem id_comp {l' l : Obj D} (f : Tw l' l) : comp (id l) f = f := by ext <;> simp

/-- Right unit law of `Tw(BD⁺)`. -/
theorem comp_id {l' l : Obj D} (f : Tw l' l) : comp f (id l') = f := by ext <;> simp

/-- Associativity of composition in `Tw(BD⁺)`. With `id_comp` and `comp_id`, `Tw(BD⁺)` is a
category, and `Tw.id`/`Tw.comp` with these three laws are exactly the fields a `Category`
instance on `Obj D` would need. -/
theorem comp_assoc {l₃ l₂ l₁ l : Obj D} (f : Tw l₁ l) (g : Tw l₂ l₁) (h : Tw l₃ l₂) :
    comp (comp f g) h = comp f (comp g h) := by ext <;> simp [add_assoc]

/-- The hom-set map `Tw(BD⁺)(l', l) → Int(D)(l', l)`: `(p, q) ↦ Tr p`. It lands among the
translations because `p + l' + q = l` with `q ∈ D⁺` gives `p + l' ≤ l`. -/
def toTr {l' l : Obj D} (f : Tw l' l) : Tr l' l :=
  ⟨f.pre, f.pre_nonneg, by rw [← f.factors]; exact le_add_of_nonneg_right f.post_nonneg⟩

/-- The inverse hom-set map `Int(D)(l', l) → Tw(BD⁺)(l', l)`: `Tr p ↦ (p, l - p - l')`. The
second component is a duration because `p + l' ≤ l`. -/
def ofTr {l' l : Obj D} (f : Tr l' l) : Tw l' l :=
  ⟨f.shift, l.val - f.shift - l'.val, f.shift_nonneg,
    sub_nonneg.mpr (le_sub_iff_add_le'.mpr f.shift_add_le), by rw [sub_sub, add_sub_cancel]⟩

/-- `toTr` is a left inverse of `ofTr`: surjectivity of the hom-set map. -/
theorem toTr_ofTr {l' l : Obj D} (f : Tr l' l) : toTr (ofTr f) = f := by ext; simp [toTr, ofTr]

/-- `ofTr` is a left inverse of `toTr`: injectivity of the hom-set map — `Tr p = Tr p'` gives
`p = p'`, whereupon cancellation gives `q = l - p - l' = q'`. With `toTr_ofTr`, the hom-set map
is a bijection `Tw(BD⁺)(l', l) ≃ Int(D)(l', l)` for every pair of objects. -/
theorem ofTr_toTr {l' l : Obj D} (f : Tw l' l) : ofTr (toTr f) = f := by
  ext
  · rfl
  · change l.val - f.pre - l'.val = f.post
    rw [sub_sub, ← f.factors, add_sub_cancel_left]

/-- `toTr` preserves composition: `(p + p', q' + q) ↦ Tr (p + p') = Tr p ∘ Tr p'`. -/
theorem toTr_comp {l'' l' l : Obj D} (f : Tw l' l) (g : Tw l'' l') :
    toTr (comp f g) = Tr.comp (toTr f) (toTr g) := by ext; simp [toTr]

/-- `toTr` preserves identities: `(0, 0) ↦ Tr 0`. With `toTr_comp`, `toTr_ofTr` and
`ofTr_toTr`, the identity-on-objects assignment `l ↦ l`, `(p, q) ↦ Tr p` is an isomorphism of
categories `Tw(BD⁺) ≅ Int(D)`. -/
theorem toTr_id (l : Obj D) : toTr (id l) = Tr.id l := by ext; simp [toTr]

/-- The left member `(0, l - p) : p → l` of the Johnstone covering family of `l` in `Tw(BD⁺)` at
the factorization `l = p + (l - p)`. Indexed by the cut point `p`, with the second summand
`q := l - p`, so that its source object is definitionally that of `Presheaf.coverLeft`. -/
def coverLeft (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) : Tw ⟨p, hp⟩ l :=
  ⟨0, l.val - p, le_refl 0, sub_nonneg.mpr hpl, by rw [zero_add, add_sub_cancel]⟩

/-- The right member `(p, 0) : (l - p) → l` of the Johnstone covering family of `l` in `Tw(BD⁺)`
at the factorization `l = p + (l - p)`, indexed as `coverLeft` is. -/
def coverRight (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    Tw ⟨l.val - p, sub_nonneg.mpr hpl⟩ l :=
  ⟨p, 0, hp, le_refl 0, by rw [add_zero, add_sub_cancel]⟩

/-- **Coverage transport, left member**: the isomorphism carries `(0, q) : p → l` to
`Tr 0 : p → l`, the left member of `Int(D)`'s covering family at `p`. Closes by `rfl` because
both families are indexed by the cut point. -/
theorem toTr_coverLeft (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    toTr (coverLeft l p hp hpl) = Presheaf.coverLeft l p hp hpl := by ext; rfl

/-- **Coverage transport, right member**: the isomorphism carries `(p, 0) : q → l` to
`Tr p : (l - p) → l`, the right member of `Int(D)`'s covering family at `p`. With
`toTr_coverLeft`, every covering family of `Tw(BD⁺)` is carried to a covering family of `Int(D)`;
and since the factorizations of `l` correspond bijectively to the cut points `p ∈ [0, l]`
(`Factorization.ofCut`, `Factorization.ofCut_fst`, `Factorization.ofCut_fst_self`), the
correspondence of covering families is itself a bijection — the step that makes the isomorphism
of categories an isomorphism of **sites**, and the step the paper proof's final paragraph
supplies. -/
theorem toTr_coverRight (l : Obj D) (p : ↑D) (hp : 0 ≤ p) (hpl : p ≤ l.val) :
    toTr (coverRight l p hp hpl) = Presheaf.coverRight l p hp hpl := by ext; rfl

end Tw

end FormalSystem.Semantics.Presheaf

assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
