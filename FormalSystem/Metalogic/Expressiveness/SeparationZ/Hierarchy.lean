/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.SeparationZ.NormalForm
import Mathlib.Data.List.Dedup
import Mathlib.Data.List.Perm.Subperm

/-!
# GHR Lemmas 10.2.5 and 10.2.6 — one `untl` type, then finitely many

[GHR][gabbay1994] vol. 1, Lemma 10.2.5 reads, verbatim:

> Suppose that A and B are wffs built without S or U and that the only appearance of U in the wff
> D is as U(A, B). Then D is equivalent to a syntactically separated wff in which U only appears
> as the formula U(A, B).

The phrase "the only appearance of U ... is as U(A, B)" places **no restriction on nesting**: the
single admitted `untl` type may sit under arbitrarily many `snce` nodes, and removing exactly
those nestings is what the lemma is for. `IsUSingleType` below is that hypothesis.

## Why `NormalForm.lean`'s `IsUTyped` cannot serve at this input position

`IsUTyped A B` admits a `snce` only through
`snce {ψ φ} : IsSOnly ψ → IsSOnly φ → IsUTyped A B (USForm.snce ψ φ)`, i.e. only when both
arguments are `untl`-free. That forbids precisely the `untl`-under-`snce` configuration
Lemma 10.2.5 exists to remove, so handing 10.2.5 that hypothesis would make it vacuous at every
input it is for. `IsUSingleType` differs from `IsUTyped` in exactly one constructor: its `snce`
recurses rather than demanding `IsSOnly` of its two arguments.

`IsUSingleType` is therefore **strictly weaker** than `IsUTyped`, and the two are not
interchangeable at an input position. The implication runs one way only
(`isUSingleType_of_isUTyped`), and the converse is refuted here rather than claimed in prose:
`not_isUTyped_snce_untl` and `isUSingleType_snce_untl` exhibit the gap at the single concrete
formula `S(⊥, U(A,B))`. The ruling of `NormalForm.lean`'s module docstring — an input position
asking for a stronger predicate than the step needs is a defect, not a strengthening — applies
verbatim one predicate further out.

## There is deliberately no `isSeparated_of_isUSingleType`

`NormalForm.lean:179`'s `isSeparated_of_isUTyped` has **no** counterpart here, and none can
exist: a `snce` carrying an `untl` argument is not syntactically separated, which is the precise
content of "strictly weaker". Producing Lemma 10.2.5's separated form is the work of `sepU`
below, not a closure property of this predicate.

## Lemma 10.2.5 in full, and the induction that is deliberately not formalized

`sepU`, `usTruth_sepU`, `isSeparated_sepU` and `isUTyped_sepU` are GHR Lemma 10.2.5 in full:
the equivalence, the separatedness of the equivalent, and its conclusion's remaining clause
that in the equivalent "`U` only appears as the formula `U(A, B)`".

GHR prove the lemma "by induction on the maximum number k of nested Ss above any U(A, B)". That
induction is **deliberately not formalized**: `sepU` is a plain structural recursion over
`USForm`, with no depth measure, no decision procedure for whether a subformula contains an
`untl`, and no one-level rewriting operator.
The structural recursion reaches the same conclusion because the two landed halves of
Lemma 10.2.4 chain at every `snce` node — `usTruth_sepSnce` supplies the equivalence and
`isUTyped_sepSnce` supplies the typedness the node above then requires as its own hypothesis —
so the nested-`S` depth never has to be measured, only recursed through.

## Main Results

- `IsUSingleType`: GHR Lemma 10.2.5's input hypothesis
- `IsUSingleType.ofIsSOnly`, `.neg`, `.and`, `.or`: the Boolean closure lemmas
- `isUSingleType_of_isUTyped`: the one-way implication from `NormalForm.lean`'s predicate
- `not_isUTyped_snce_untl`, `isUSingleType_snce_untl`: the strictness, proved at one formula
- `sepU`: the separated form of a single-`untl`-type formula
- `isUTyped_sepU`, `usTruth_sepU`, `isSeparated_sepU`: GHR Lemma 10.2.5's three conclusions
- `uTypes`, `uTypeCount`: the `U`-type measure GHR Lemma 10.2.6's induction runs on
- `IsPureType`, `HasPureUTypes`: GHR Lemma 10.2.6's input hypothesis
- `uTypes_mapU_abstr`, `uTypes_sepU`, `uTypeCount_snce_substLeaf_le`: the three separately named
  parts of 10.2.6's strict-decrease obligation
- `sepMulti`: GHR Lemma 10.2.6's separating function
- `isSeparated_sepMulti`, `usTruth_sepMulti`, `uTypes_sepMulti`: its three conclusions

## GHR Lemma 10.2.6, and the two formalization choices it forces

Lemma 10.2.6 generalizes 10.2.5 from one admitted `untl` type to finitely many. Two choices are
made here and recorded rather than left implicit.

First, the types are **read off the formula** by `uTypes` rather than supplied as the parameter
list `A₁,B₁,…,Aₙ,Bₙ` the source quantifies over, because that is what keeps the separating
function computable without threading a list through every call. `HasPureUTypes` is then the
source's hypothesis verbatim: every maximal `untl` subformula is an `untl` whose two arguments
carry no temporal operator.

Second, the induction carries the count as an **explicit budget** (`sepFuel`) rather than running
as a well-founded recursion on `uTypeCount` directly. This is forced, not preferred: the
recursive call is fired by `mapS` at the separated form's `snce` constituents, which are neither
syntactic subterms of the definition's argument nor in scope when the definition is elaborated,
so no `decreasing_by` goal can be stated for it at all. `sepMulti` instantiates the budget at the
measure, so the budget never appears in the statement of the lemma.

The strict decrease is three obligations, each its own named result and none standing in for
another: `uTypes_mapU_abstr` (abstraction drops the abstracted types), `uTypes_sepU` (separation
raises nothing — a citation of `isUTyped_sepU`, never of `isUTyped_sepSnce`, which is one level
down and adequate only at Lemma 10.2.4), and `uTypeCount_snce_substLeaf_le` (the reindexed
constituents are bounded by the pre-abstraction count less one, which is what licenses the
recursive call).

## References

* [D. M. Gabbay, I. Hodkinson and M. Reynolds, *Temporal Logic: Mathematical Foundations and
  Computational Aspects*][gabbay1994], vol. 1, Lemmas 10.2.5 and 10.2.6
-/

namespace FormalSystem.Metalogic.Expressiveness.SeparationZ

/-! ## GHR 10.2.5's precondition -/

/--
`φ` is **of single `untl` type `(A,B)`**: every `untl` occurring in `φ` is the single type
`untl B A`, with nesting otherwise unconstrained. This is GHR Lemma 10.2.5's input hypothesis,
quoted in full in the module docstring.

It is **strictly weaker** than `NormalForm.lean`'s `IsUTyped A B`, whose `snce` constructor
additionally demands that both arguments be `untl`-free. That restriction forbids exactly the
configuration Lemma 10.2.5 removes, so `IsUTyped` must never replace this predicate at an input
position: doing so makes the lemma vacuous at every input it is for. The implication
`isUSingleType_of_isUTyped` runs one way only, and `not_isUTyped_snce_untl` together with
`isUSingleType_snce_untl` refutes the converse at `S(⊥, U(A,B))`.

There is deliberately no `isSeparated_of_isUSingleType` counterpart to `isSeparated_of_isUTyped`,
and none can exist: a `snce` carrying an `untl` argument is not syntactically separated, which is
what "strictly weaker" means here. Producing the separated form is `sepU`'s work, not a closure
property of this predicate.
-/
inductive IsUSingleType (A B : USForm) : USForm → Prop
  /-- Every leaf is of single `untl` type `(A,B)`. -/
  | leaf (i : ℕ) : IsUSingleType A B (.leaf i)
  /-- Bottom is of single `untl` type `(A,B)`. -/
  | bot : IsUSingleType A B .bot
  /-- `imp` preserves the property, carrying `neg`, `and`, `or` and `iff` with it. -/
  | imp {φ ψ : USForm} :
      IsUSingleType A B φ → IsUSingleType A B ψ → IsUSingleType A B (.imp φ ψ)
  /-- The one admitted `untl`. -/
  | untl : IsUSingleType A B (USForm.untl B A)
  /-- A `snce` preserves the property: this is the one and only difference from `IsUTyped`,
  whose `snce` constructor demands `IsSOnly` of both arguments instead of recursing. -/
  | snce {ψ φ : USForm} :
      IsUSingleType A B ψ → IsUSingleType A B φ → IsUSingleType A B (USForm.snce ψ φ)

namespace IsUSingleType

variable {A B : USForm}

/-- An `untl`-free formula is of single `untl` type `(A,B)` for every `A` and `B`. -/
theorem ofIsSOnly {φ : USForm} (h : IsSOnly φ) : IsUSingleType A B φ := by
  induction h with
  | leaf i => exact IsUSingleType.leaf i
  | bot => exact IsUSingleType.bot
  | imp _ _ ihφ ihψ => exact IsUSingleType.imp ihφ ihψ
  | snce _ _ ihψ ihφ => exact IsUSingleType.snce ihψ ihφ

/-- Negation preserves single `untl` typedness. -/
theorem neg {φ : USForm} (h : IsUSingleType A B φ) : IsUSingleType A B φ.neg :=
  IsUSingleType.imp h IsUSingleType.bot

/-- Conjunction preserves single `untl` typedness. -/
theorem and {φ ψ : USForm} (hφ : IsUSingleType A B φ) (hψ : IsUSingleType A B ψ) :
    IsUSingleType A B (φ.and ψ) :=
  (IsUSingleType.imp hφ hψ.neg).neg

/-- Disjunction preserves single `untl` typedness. -/
theorem or {φ ψ : USForm} (hφ : IsUSingleType A B φ) (hψ : IsUSingleType A B ψ) :
    IsUSingleType A B (φ.or ψ) :=
  IsUSingleType.imp hφ.neg hψ

end IsUSingleType

/--
**The one-way implication.** GHR Lemma 10.2.4's precondition implies Lemma 10.2.5's: relaxing the
`snce` constructor from "both arguments `untl`-free" to "both arguments recursively of single
`untl` type" only admits more formulas. The `snce` case goes through `IsUSingleType.ofIsSOnly` at
each argument.

The converse fails — see `not_isUTyped_snce_untl` and `isUSingleType_snce_untl`.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no
separation theorem and carries no label for one)
-/
theorem isUSingleType_of_isUTyped {A B φ : USForm} (h : IsUTyped A B φ) :
    IsUSingleType A B φ := by
  induction h with
  | leaf i => exact IsUSingleType.leaf i
  | bot => exact IsUSingleType.bot
  | imp _ _ ihφ ihψ => exact IsUSingleType.imp ihφ ihψ
  | untl => exact IsUSingleType.untl
  | snce hψ hφ => exact IsUSingleType.snce (IsUSingleType.ofIsSOnly hψ) (IsUSingleType.ofIsSOnly hφ)

/-! ## The strictness, proved at one concrete formula

`S(⊥, U(A,B))` — a `snce` whose event argument is the single admitted `untl` — separates the two
predicates. The pair below is the proof that `IsUSingleType` is *strictly* weaker than
`IsUTyped`, so no later reader takes the direction of `isUSingleType_of_isUTyped` on trust. -/

/-- `IsUTyped` rejects `S(⊥, U(A,B))`: its `snce` constructor demands `IsSOnly (untl B A)`, and
`IsSOnly` has no `untl` constructor.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no
separation theorem and carries no label for one) -/
theorem not_isUTyped_snce_untl {A B : USForm} :
    ¬ IsUTyped A B (USForm.snce USForm.bot (USForm.untl B A)) := by
  intro h
  cases h with
  | snce _ hφ => cases hφ

/-- `IsUSingleType` accepts `S(⊥, U(A,B))`, which with `not_isUTyped_snce_untl` exhibits the gap
between the two predicates at one formula.

Paper: — (a result of GHR vol. 1, Chapter 10 §10.2; the manuscript states no
separation theorem and carries no label for one) -/
theorem isUSingleType_snce_untl {A B : USForm} :
    IsUSingleType A B (USForm.snce USForm.bot (USForm.untl B A)) :=
  IsUSingleType.snce IsUSingleType.bot IsUSingleType.untl

/-! ## GHR Lemma 10.2.5 by structural recursion -/

/--
The **separated form of a single-`untl`-type formula**: GHR Lemma 10.2.5's construction, by plain
structural recursion over `USForm`.

**Why the `untl` equation is the identity.** Under `IsUSingleType A B` the only `untl` node is
`untl B A`, so this equation needs no case analysis, no decidable-equality test and no
`sepU A B A = A` lemma: `IsUTyped.untl` applies to the returned node directly. A decidable
equality test here has reconstructed a case analysis the precondition already supplies.

**The `snce`/`sepSnce` argument crossing.** `USForm.snce` takes the **guard first and the event
second**, while `sepSnce A B C F` takes the **event `C` first and the guard `F` second**, so the
two arguments cross at the `snce` equation. `usTruth_sepSnce`'s own statement,
`usTruth v t (USForm.snce F C) ↔ usTruth v t (sepSnce A B C F)`, is the authority on that
crossing; an uncrossed transcription typechecks and is wrong.

This is a plain `def`, deliberately not `noncomputable`: the downstream ZTime translation's
executability deliverable consumes it transitively.
-/
def sepU (A B : USForm) : USForm → USForm
  | .leaf i => .leaf i
  | .bot => .bot
  | .imp φ ψ => .imp (sepU A B φ) (sepU A B ψ)
  | .untl ψ φ => .untl ψ φ
  | .snce ψ φ => sepSnce A B (sepU A B φ) (sepU A B ψ)

/--
**GHR Lemma 10.2.5**, the typedness half: in the separated equivalent, `untl` occurs only as
`untl B A`.

This is proved **before** the equivalence, because it supplies the hypotheses `usTruth_sepSnce`
demands at every `snce` node.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.5 (the conclusion's "`U` only appears as the formula
`U(A, B)`" clause)
-/
theorem isUTyped_sepU {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) {φ : USForm}
    (h : IsUSingleType A B φ) : IsUTyped A B (sepU A B φ) := by
  induction h with
  | leaf i => exact IsUTyped.leaf i
  | bot => exact IsUTyped.bot
  | imp _ _ ihφ ihψ => exact IsUTyped.imp ihφ ihψ
  | untl => exact IsUTyped.untl
  | snce _ _ ihψ ihφ => exact isUTyped_sepSnce hAs hBs ihφ ihψ

/--
**GHR Lemma 10.2.5**, the equivalence half: a formula whose only `untl` type is `untl B A` is
equivalent to its separated form at every leaf valuation and every time.

The `snce` case chains `usTruth_snce_congr` at the two induction hypotheses with
`usTruth_sepSnce` at the `isUTyped_sepU` witnesses; Lemma 10.2.4 is cited, never re-derived here.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.5 (the equivalence)
-/
theorem usTruth_sepU {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) {φ : USForm}
    (h : IsUSingleType A B φ) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (sepU A B φ) ↔ usTruth v t φ := by
  induction h generalizing v t with
  | leaf i => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp _ _ ihφ ihψ =>
    change (usTruth v t (sepU A B _) → usTruth v t (sepU A B _)) ↔ _
    exact imp_congr (ihφ v t) (ihψ v t)
  | untl => exact Iff.rfl
  | snce hψ hφ ihψ ihφ =>
    exact ((usTruth_sepSnce (isUTyped_sepU hAs hBs hφ) (isUTyped_sepU hAs hBs hψ) v t).symm).trans
      (usTruth_snce_congr (fun w r => ihψ w r) (fun w r => ihφ w r) v t)

/--
**GHR Lemma 10.2.5**, the separatedness half: the equivalent is syntactically separated.

A one-line composite of `isSeparated_of_isUTyped` and `isUTyped_sepU` — not a second induction,
which would be a sign the typedness lemma had been stated too weakly. The two `IsUOnly`
hypotheses are GHR's standing "`A` and `B` are wffs built without `S` or `U`".

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.5 (the conclusion's separatedness)
-/
theorem isSeparated_sepU {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) (hAu : IsUOnly A)
    (hBu : IsUOnly B) {φ : USForm} (h : IsUSingleType A B φ) : IsSeparated (sepU A B φ) :=
  isSeparated_of_isUTyped hAu hBu (isUTyped_sepU hAs hBs h)

/-! ## The `U`-type measure

GHR Lemma 10.2.6 inducts on `n`, the number of `U(Aᵢ, Bᵢ)` types **given as parameters**:
"For each i = 1, ..., n let Aᵢ and Bᵢ be wffs built without S or U. Suppose that the only
appearances of U in the wff D are in the form U(Aᵢ, Bᵢ)". This development derives the count
from `D` instead, through `uTypes` below, because that is what keeps the separating function
computable without threading a type list through every call.

GHR's occurrence-level phrasing "the number of distinct maximal `untl` subformulas" has no Lean
counterpart. `uTypes` is the restatement: it collects each `untl` node **without recursing into
its arguments** (that is the "maximal"), and deduplicates (that is the "distinct").
-/

/--
The **maximal `untl` subformulas** of `φ`, deduplicated: GHR 10.2.6's `{U(Aᵢ,Bᵢ) : i < n}` read
off the formula rather than supplied as parameters.

The `untl` equation does **not** recurse into the node's arguments, which is what makes the
collected occurrences maximal; `List.dedup` is what makes them distinct, and
`uTypes_nodup` is the consequence the measure needs.
-/
def uTypes : USForm → List USForm
  | .leaf _ => []
  | .bot => []
  | .imp φ ψ => (uTypes φ ++ uTypes ψ).dedup
  | .untl ψ φ => [USForm.untl ψ φ]
  | .snce ψ φ => (uTypes ψ ++ uTypes φ).dedup

@[simp] theorem uTypes_leaf (i : ℕ) : uTypes (USForm.leaf i) = [] := rfl

@[simp] theorem uTypes_bot : uTypes USForm.bot = [] := rfl

@[simp] theorem uTypes_untl (ψ φ : USForm) :
    uTypes (USForm.untl ψ φ) = [USForm.untl ψ φ] := rfl

theorem uTypes_imp (φ ψ : USForm) :
    uTypes (USForm.imp φ ψ) = (uTypes φ ++ uTypes ψ).dedup := rfl

theorem uTypes_snce (ψ φ : USForm) :
    uTypes (USForm.snce ψ φ) = (uTypes ψ ++ uTypes φ).dedup := rfl

@[simp] theorem mem_uTypes_imp {u φ ψ : USForm} :
    u ∈ uTypes (USForm.imp φ ψ) ↔ u ∈ uTypes φ ∨ u ∈ uTypes ψ := by
  rw [uTypes_imp, List.mem_dedup, List.mem_append]

@[simp] theorem mem_uTypes_snce {u ψ φ : USForm} :
    u ∈ uTypes (USForm.snce ψ φ) ↔ u ∈ uTypes ψ ∨ u ∈ uTypes φ := by
  rw [uTypes_snce, List.mem_dedup, List.mem_append]

/-- The collected types are pairwise distinct, so the measure counts each type once. -/
theorem uTypes_nodup : ∀ φ : USForm, (uTypes φ).Nodup
  | .leaf _ => List.nodup_nil
  | .bot => List.nodup_nil
  | .imp φ ψ => List.nodup_dedup (uTypes φ ++ uTypes ψ)
  | .untl ψ φ => List.nodup_singleton (USForm.untl ψ φ)
  | .snce ψ φ => List.nodup_dedup (uTypes ψ ++ uTypes φ)

/--
The **`U`-type measure**: the number of distinct maximal `untl` subformulas. This is the measure
GHR Lemma 10.2.6's induction runs on, and `sepFuel` consumes it as its recursion budget.
-/
def uTypeCount (φ : USForm) : ℕ := (uTypes φ).length

/-- Each collected type is its own only type: `uTypes` of an `untl` node is that node. -/
theorem uTypes_eq_singleton_of_mem : ∀ {φ u : USForm}, u ∈ uTypes φ → uTypes u = [u]
  | .leaf _, _, hu => absurd hu (by simp)
  | .bot, _, hu => absurd hu (by simp)
  | .imp φ ψ, u, hu => by
      rcases mem_uTypes_imp.mp hu with h | h
      · exact uTypes_eq_singleton_of_mem h
      · exact uTypes_eq_singleton_of_mem h
  | .untl ψ φ, u, hu => by
      have hu' : u = USForm.untl ψ φ := by simpa using hu
      subst hu'
      simp
  | .snce ψ φ, u, hu => by
      rcases mem_uTypes_snce.mp hu with h | h
      · exact uTypes_eq_singleton_of_mem h
      · exact uTypes_eq_singleton_of_mem h

/-- A collected type mentions no leaf the formula does not mention. -/
theorem maxLeaf_le_of_mem_uTypes : ∀ {φ u : USForm}, u ∈ uTypes φ → u.maxLeaf ≤ φ.maxLeaf
  | .leaf _, _, hu => absurd hu (by simp)
  | .bot, _, hu => absurd hu (by simp)
  | .imp φ ψ, u, hu => by
      rcases mem_uTypes_imp.mp hu with h | h
      · exact le_trans (maxLeaf_le_of_mem_uTypes h) (le_max_left _ _)
      · exact le_trans (maxLeaf_le_of_mem_uTypes h) (le_max_right _ _)
  | .untl ψ φ, u, hu => by
      have hu' : u = USForm.untl ψ φ := by simpa using hu
      exact le_of_eq (by rw [hu'])
  | .snce ψ φ, u, hu => by
      rcases mem_uTypes_snce.mp hu with h | h
      · exact le_trans (maxLeaf_le_of_mem_uTypes h) (le_max_left _ _)
      · exact le_trans (maxLeaf_le_of_mem_uTypes h) (le_max_right _ _)

/-- An `untl`-free formula has no types. -/
theorem uTypes_eq_nil_of_isSOnly {φ : USForm} (h : IsSOnly φ) : uTypes φ = [] := by
  induction h with
  | leaf i => rfl
  | bot => rfl
  | imp _ _ ihφ ihψ => rw [uTypes_imp, ihφ, ihψ]; rfl
  | snce _ _ ihψ ihφ => rw [uTypes_snce, ihψ, ihφ]; rfl

/-- Conversely, a formula with no types is `untl`-free, hence already separated. -/
theorem isSOnly_of_uTypes_empty : ∀ {φ : USForm}, (∀ u, u ∉ uTypes φ) → IsSOnly φ
  | .leaf i, _ => IsSOnly.leaf i
  | .bot, _ => IsSOnly.bot
  | .imp φ ψ, h =>
      IsSOnly.imp (isSOnly_of_uTypes_empty fun u hu => h u (mem_uTypes_imp.mpr (Or.inl hu)))
        (isSOnly_of_uTypes_empty fun u hu => h u (mem_uTypes_imp.mpr (Or.inr hu)))
  | .untl ψ φ, h => absurd (by simp : USForm.untl ψ φ ∈ uTypes (USForm.untl ψ φ)) (h _)
  | .snce ψ φ, h =>
      IsSOnly.snce (isSOnly_of_uTypes_empty fun u hu => h u (mem_uTypes_snce.mpr (Or.inl hu)))
        (isSOnly_of_uTypes_empty fun u hu => h u (mem_uTypes_snce.mpr (Or.inr hu)))

/-- The measure is zero exactly when the formula is `untl`-free. -/
theorem isSOnly_of_uTypeCount_le_zero {φ : USForm} (h : uTypeCount φ ≤ 0) : IsSOnly φ := by
  refine isSOnly_of_uTypes_empty fun u hu => ?_
  have := List.length_pos_of_mem hu
  rw [uTypeCount] at h
  omega

/-- `NormalForm.lean`'s precondition pins every type to the single admitted one. -/
theorem uTypes_of_isUTyped {A B : USForm} : ∀ {χ : USForm}, IsUTyped A B χ →
    ∀ u ∈ uTypes χ, u = USForm.untl B A := by
  intro χ h
  induction h with
  | leaf i => simp
  | bot => simp
  | imp _ _ ihφ ihψ =>
      intro u hu
      rcases mem_uTypes_imp.mp hu with h | h
      · exact ihφ u h
      · exact ihψ u h
  | untl => intro u hu; simpa using hu
  | snce hψ hφ =>
      intro u hu
      rw [uTypes_snce, uTypes_eq_nil_of_isSOnly hψ, uTypes_eq_nil_of_isSOnly hφ] at hu
      simp at hu

/-- Conversely, a formula all of whose types are the single admitted one satisfies GHR
Lemma 10.2.5's precondition. This is the bridge from the measure back to `IsUSingleType`. -/
theorem isUSingleType_of_uTypes {A B : USForm} : ∀ {χ : USForm},
    (∀ u ∈ uTypes χ, u = USForm.untl B A) → IsUSingleType A B χ
  | .leaf i, _ => IsUSingleType.leaf i
  | .bot, _ => IsUSingleType.bot
  | .imp φ ψ, h =>
      IsUSingleType.imp
        (isUSingleType_of_uTypes fun u hu => h u (mem_uTypes_imp.mpr (Or.inl hu)))
        (isUSingleType_of_uTypes fun u hu => h u (mem_uTypes_imp.mpr (Or.inr hu)))
  | .untl ψ φ, h => by
      rw [h (USForm.untl ψ φ) (by simp)]
      exact IsUSingleType.untl
  | .snce ψ φ, h =>
      IsUSingleType.snce
        (isUSingleType_of_uTypes fun u hu => h u (mem_uTypes_snce.mpr (Or.inl hu)))
        (isUSingleType_of_uTypes fun u hu => h u (mem_uTypes_snce.mpr (Or.inr hu)))

/-! ## GHR 10.2.6's precondition

GHR 10.2.6 asks that "the only appearances of U in the wff D are in the form U(Aᵢ, Bᵢ)", where
each `Aᵢ` and `Bᵢ` is "built without S or U". With the types read off `D` by `uTypes`, that
hypothesis is exactly the statement that every collected type is an `untl` whose two arguments
carry no temporal operator at all — `IsSOnly` and `IsUOnly` together. No new inductive predicate
is needed: `HasPureUTypes` is a condition on the measured list. -/

/--
`u` is a **pure `U`-type**: an `untl` node both of whose arguments are built without `S` or `U`.
This is GHR's standing hypothesis on the parameters `Aᵢ` and `Bᵢ`, at one type.
-/
def IsPureType (u : USForm) : Prop :=
  ∃ A B : USForm, u = USForm.untl B A ∧ IsSOnly A ∧ IsSOnly B ∧ IsUOnly A ∧ IsUOnly B

/--
**GHR Lemma 10.2.6's input hypothesis**: every maximal `untl` subformula of `φ` is a pure
`U`-type. Nesting is unconstrained, exactly as in `IsUSingleType`; what is constrained is the
shape of the types, not where they sit.
-/
def HasPureUTypes (φ : USForm) : Prop := ∀ u ∈ uTypes φ, IsPureType u

/-- A pure `U`-type is its own only type. -/
theorem uTypes_eq_self_of_isPureType {u : USForm} (h : IsPureType u) : uTypes u = [u] := by
  obtain ⟨A, B, rfl, _, _, _, _⟩ := h
  simp

/-- A pure `U`-type is separated. -/
theorem isSeparated_of_isPureType {u : USForm} (h : IsPureType u) : IsSeparated u := by
  obtain ⟨A, B, rfl, _, _, hAu, hBu⟩ := h
  exact IsSeparated.untl hBu hAu

/-! ## The abstraction and reindexing device

GHR's proof of 10.2.6 "replaces each `U(Aᵢ,Bᵢ)` for `i < n` by a fresh atom `qᵢ`", separates the
result for the one remaining type, and then "substitutes `U(Aᵢ,Bᵢ)` back for `qᵢ`". `freshLeaf`
(`Syntax.lean:342`) supplies the fresh indices, but the tree carries no substitution **operation**
on `USForm`, in either direction, so both are built here: `mapU` rewrites `untl` nodes without
descending into them, and `substLeaf` rewrites leaves.

`substLeaf`'s truth equation is what makes the reindexing step free of any fresh-atom
side-condition on the valuation: `usTruth_substLeaf` moves the substitution onto the valuation,
and the equivalence then transports through `usTruth_sepU` at the moved valuation. That is
strictly stronger than `usTruth_congr_of_update` and makes it unnecessary here; the fresh indices
are still needed, but only so that `substLeaf` inverts `mapU` **syntactically**
(`substLeaf_mapU_abstr`). -/

/-- Rewrite every maximal `untl` subformula by `g`, without descending into its arguments. -/
def mapU (g : USForm → USForm) : USForm → USForm
  | .leaf i => .leaf i
  | .bot => .bot
  | .imp φ ψ => .imp (mapU g φ) (mapU g ψ)
  | .untl ψ φ => g (USForm.untl ψ φ)
  | .snce ψ φ => .snce (mapU g ψ) (mapU g φ)

/-- Rewrite every maximal `snce` subformula by `k`, leaving `untl` nodes alone. This is the pass
that fires the recursive call of GHR 10.2.6 at the constituents that the reindexing step
recontaminates. -/
def mapS (k : USForm → USForm) : USForm → USForm
  | .leaf i => .leaf i
  | .bot => .bot
  | .imp φ ψ => .imp (mapS k φ) (mapS k ψ)
  | .untl ψ φ => USForm.untl ψ φ
  | .snce ψ φ => k (USForm.snce ψ φ)

/-- Substitute `h i` for the `i`-th leaf throughout. -/
def substLeaf (h : ℕ → USForm) : USForm → USForm
  | .leaf i => h i
  | .bot => .bot
  | .imp φ ψ => .imp (substLeaf h φ) (substLeaf h ψ)
  | .untl ψ φ => .untl (substLeaf h ψ) (substLeaf h φ)
  | .snce ψ φ => .snce (substLeaf h ψ) (substLeaf h φ)

/--
**The whole content of the reindexing step's truth preservation**: substituting on leaves is the
same as moving the substitution onto the leaf valuation. No freshness hypothesis appears, which
is why the fresh indices are needed only for the syntactic round trip.

Paper: — (formalization-native; the manuscript has no auxiliary until/since syntax and no leaf
abstraction, so it carries no label for this)
-/
theorem usTruth_substLeaf (h : ℕ → USForm) (φ : USForm) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (substLeaf h φ) ↔ usTruth (fun i s => usTruth v s (h i)) t φ := by
  induction φ generalizing t with
  | leaf i => exact Iff.rfl
  | bot => exact Iff.rfl
  | imp φ ψ ihφ ihψ =>
      change (usTruth v t (substLeaf h φ) → usTruth v t (substLeaf h ψ)) ↔ _
      exact imp_congr (ihφ t) (ihψ t)
  | untl ψ φ ihψ ihφ =>
      change usTruth v t (USForm.untl (substLeaf h ψ) (substLeaf h φ)) ↔ _
      rw [usTruth_untl_iff, usTruth_untl_iff]
      exact exists_congr fun s => and_congr_right fun _ =>
        and_congr (ihφ s) (forall_congr' fun r => imp_congr_right fun _ =>
          imp_congr_right fun _ => ihψ r)
  | snce ψ φ ihψ ihφ =>
      change usTruth v t (USForm.snce (substLeaf h ψ) (substLeaf h φ)) ↔ _
      rw [usTruth_snce_iff, usTruth_snce_iff]
      exact exists_congr fun s => and_congr_right fun _ =>
        and_congr (ihφ s) (forall_congr' fun r => imp_congr_right fun _ =>
          imp_congr_right fun _ => ihψ r)

/-- A substitution that is the identity below `j` fixes every formula whose leaves are below
`j`. -/
theorem substLeaf_eq_self_of_lt {h : ℕ → USForm} {j : ℕ} (hh : ∀ i, i < j → h i = .leaf i) :
    ∀ {φ : USForm}, φ.maxLeaf < j → substLeaf h φ = φ
  | .leaf i, hi => hh i hi
  | .bot, _ => rfl
  | .imp φ ψ, hi => by
      have h1 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ ψ.maxLeaf) hi
      have h2 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_right φ.maxLeaf _) hi
      change USForm.imp (substLeaf h φ) (substLeaf h ψ) = _
      rw [substLeaf_eq_self_of_lt hh h1, substLeaf_eq_self_of_lt hh h2]
  | .untl ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      change USForm.untl (substLeaf h ψ) (substLeaf h φ) = _
      rw [substLeaf_eq_self_of_lt hh h1, substLeaf_eq_self_of_lt hh h2]
  | .snce ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      change USForm.snce (substLeaf h ψ) (substLeaf h φ) = _
      rw [substLeaf_eq_self_of_lt hh h1, substLeaf_eq_self_of_lt hh h2]

/-- GHR's "replace each `U(Aᵢ,Bᵢ)` by a fresh atom `qᵢ`", as a function on types: the `k`-th
member of `L` goes to the leaf `j + k`, and every other `untl` node is kept. -/
def abstrFn (j : ℕ) (L : List USForm) : USForm → USForm :=
  fun u => if u ∈ L then .leaf (j + L.idxOf u) else u

/-- GHR's "substitute `U(Aᵢ,Bᵢ)` back for `qᵢ`", as a function on leaves: the inverse of
`abstrFn j L` on the fresh block, and the identity everywhere else. -/
def unabstrFn (j : ℕ) (L : List USForm) : ℕ → USForm :=
  fun i => if j ≤ i then L.getD (i - j) (.leaf i) else .leaf i

/-- Below the fresh block the reindexing is the identity. -/
theorem unabstrFn_of_lt {j : ℕ} {L : List USForm} {i : ℕ} (h : i < j) :
    unabstrFn j L i = .leaf i := by
  simp only [unabstrFn]
  rw [if_neg (Nat.not_le.mpr h)]

/-- The reindexing inverts the abstraction at every abstracted type. -/
theorem unabstrFn_abstrFn_of_mem {j : ℕ} {L : List USForm} {u : USForm} (hu : u ∈ L) :
    unabstrFn j L (j + L.idxOf u) = u := by
  have hlen : L.idxOf u < L.length := List.idxOf_lt_length_of_mem hu
  simp only [unabstrFn]
  rw [if_pos (Nat.le_add_right j (L.idxOf u)), Nat.add_sub_cancel_left,
    List.getD_eq_getElem _ _ hlen, List.getElem_idxOf hlen]

/-- Every value of the reindexing is either an untouched leaf or an abstracted type. -/
theorem unabstrFn_cases {j : ℕ} {L : List USForm} (i : ℕ) :
    unabstrFn j L i = .leaf i ∨ unabstrFn j L i ∈ L := by
  by_cases hji : j ≤ i
  · by_cases hlen : i - j < L.length
    · refine Or.inr ?_
      simp only [unabstrFn]
      rw [if_pos hji, List.getD_eq_getElem _ _ hlen]
      exact List.getElem_mem hlen
    · refine Or.inl ?_
      simp only [unabstrFn]
      rw [if_pos hji, List.getD_eq_default _ _ (Nat.le_of_not_lt hlen)]
  · exact Or.inl (unabstrFn_of_lt (Nat.lt_of_not_le hji))

/-- The reindexing introduces no type outside `L`. -/
theorem mem_uTypes_unabstrFn {j : ℕ} {L : List USForm} (hLp : ∀ u ∈ L, IsPureType u) (i : ℕ) :
    ∀ u ∈ uTypes (unabstrFn j L i), u ∈ L := by
  intro u hu
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h] at hu; simp at hu
  · rw [uTypes_eq_self_of_isPureType (hLp _ h), List.mem_singleton] at hu
    exact hu ▸ h

/-- `mapS` is the identity on every value of the reindexing, because each is a leaf or a pure
`U`-type. -/
theorem mapS_unabstrFn {k : USForm → USForm} {j : ℕ} {L : List USForm}
    (hLp : ∀ u ∈ L, IsPureType u) (i : ℕ) :
    mapS k (unabstrFn j L i) = unabstrFn j L i := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h]; rfl
  · obtain ⟨A', B', hEq, _, _, _, _⟩ := hLp _ h
    rw [hEq]; rfl

/-- Every value of the reindexing is separated. -/
theorem isSeparated_unabstrFn {j : ℕ} {L : List USForm} (hLp : ∀ u ∈ L, IsPureType u) (i : ℕ) :
    IsSeparated (unabstrFn j L i) := by
  rcases unabstrFn_cases (j := j) (L := L) i with h | h
  · rw [h]; exact IsSeparated.leaf i
  · exact isSeparated_of_isPureType (hLp _ h)

/-- Every type of an abstracted formula comes from a type of the original, through `g`. -/
theorem mem_uTypes_mapU {g : USForm → USForm} : ∀ {φ u : USForm},
    u ∈ uTypes (mapU g φ) → ∃ w ∈ uTypes φ, u ∈ uTypes (g w)
  | .leaf _, _, hu => absurd hu (by simp [mapU])
  | .bot, _, hu => absurd hu (by simp [mapU])
  | .imp φ ψ, u, hu => by
      simp only [mapU, mem_uTypes_imp] at hu
      rcases hu with h | h
      · obtain ⟨w, hw, hw'⟩ := mem_uTypes_mapU h
        exact ⟨w, mem_uTypes_imp.mpr (Or.inl hw), hw'⟩
      · obtain ⟨w, hw, hw'⟩ := mem_uTypes_mapU h
        exact ⟨w, mem_uTypes_imp.mpr (Or.inr hw), hw'⟩
  | .untl ψ φ, u, hu => ⟨USForm.untl ψ φ, by simp, by simpa only [mapU] using hu⟩
  | .snce ψ φ, u, hu => by
      simp only [mapU, mem_uTypes_snce] at hu
      rcases hu with h | h
      · obtain ⟨w, hw, hw'⟩ := mem_uTypes_mapU h
        exact ⟨w, mem_uTypes_snce.mpr (Or.inl hw), hw'⟩
      · obtain ⟨w, hw, hw'⟩ := mem_uTypes_mapU h
        exact ⟨w, mem_uTypes_snce.mpr (Or.inr hw), hw'⟩

/--
**Part (a) of GHR Lemma 10.2.6's strict-decrease obligation: the abstraction drops the abstracted
types.**

Replacing each type in `L` by a leaf fresh above `maxLeaf` removes it from the count, by `uTypes`'
own defining equations: no type of the abstracted formula lies in `L`, and every type that
survives was already a type of the original. This is the cheap part, and it is where the strict
decrease originates — `uTypes_mapU_abstr_eq_head` is the instance the recursion consumes.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6 (the "replace each `U(Aᵢ,Bᵢ)` by a fresh atom"
step)
-/
theorem uTypes_mapU_abstr {j : ℕ} {L : List USForm} {φ u : USForm}
    (hu : u ∈ uTypes (mapU (abstrFn j L) φ)) : u ∈ uTypes φ ∧ u ∉ L := by
  obtain ⟨w, hw, hw'⟩ := mem_uTypes_mapU hu
  by_cases hwL : w ∈ L
  · rw [show abstrFn j L w = USForm.leaf (j + L.idxOf w) from by
      simp only [abstrFn]; rw [if_pos hwL]] at hw'
    simp at hw'
  · rw [show abstrFn j L w = w from by simp only [abstrFn]; rw [if_neg hwL],
      uTypes_eq_singleton_of_mem hw, List.mem_singleton] at hw'
    subst hw'
    exact ⟨hw, hwL⟩

/-- Part (a) at the instance the recursion uses: abstracting the tail of the type list leaves
exactly the head. -/
theorem uTypes_mapU_abstr_eq_head {j : ℕ} {φ t u : USForm} {rest : List USForm}
    (ht : uTypes φ = t :: rest) (hu : u ∈ uTypes (mapU (abstrFn j rest) φ)) : u = t := by
  obtain ⟨h1, h2⟩ := uTypes_mapU_abstr hu
  rw [ht, List.mem_cons] at h1
  exact h1.resolve_right h2

/--
**Part (b) of GHR Lemma 10.2.6's strict-decrease obligation: separation does not raise the
measure.** Discharged by citing Phase 22.2's `isUTyped_sepU`, which already states that every
`untl` in `sepU A B φ` is the single type `untl B A`; nothing about type-cleanliness is
re-derived here, and `isUTyped_sepSnce` — one level down, about a single `snce` node, and
adequate only at Lemma 10.2.4 — is deliberately *not* what is cited.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6 (the "the separated form introduces no new type"
step)
-/
theorem uTypes_sepU {A B : USForm} (hAs : IsSOnly A) (hBs : IsSOnly B) {φ : USForm}
    (h : IsUSingleType A B φ) : ∀ u ∈ uTypes (sepU A B φ), u = USForm.untl B A :=
  uTypes_of_isUTyped (isUTyped_sepU hAs hBs h)

/-- Substituting into an `untl`-free formula introduces only the types the substitution carries. -/
theorem mem_uTypes_substLeaf_of_isSOnly {h : ℕ → USForm} {L : List USForm}
    (hh : ∀ i, ∀ u ∈ uTypes (h i), u ∈ L) {χ : USForm} (hχ : IsSOnly χ) :
    ∀ u ∈ uTypes (substLeaf h χ), u ∈ L := by
  induction hχ with
  | leaf i => intro u hu; exact hh i u (by simpa only [substLeaf] using hu)
  | bot => intro u hu; simp [substLeaf] at hu
  | imp _ _ ihφ ihψ =>
      intro u hu
      simp only [substLeaf, mem_uTypes_imp] at hu
      rcases hu with h' | h'
      · exact ihφ u h'
      · exact ihψ u h'
  | snce _ _ ihψ ihφ =>
      intro u hu
      simp only [substLeaf, mem_uTypes_snce] at hu
      rcases hu with h' | h'
      · exact ihψ u h'
      · exact ihφ u h'

/--
**Part (c) of GHR Lemma 10.2.6's strict-decrease obligation: the reindexed form's count is
bounded by the pre-abstraction count less one.**

GHR's own argument is that `U(Aₙ,Bₙ)` appears in no pure-past constituent `Dⱼ` of the separated
form, so each reindexed `Dⱼ` carries at most `n-1` types. Here that non-appearance is proved
rather than asserted: the constituent's arguments were `untl`-free before reindexing (that is
`IsUTyped`'s `snce` clause, supplied by `isUTyped_sepU`), so every type it acquires comes from
the reindexing, whose whole image lies in the abstracted tail `L`. It is this bound, not part
(a), that licenses the recursive call.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6 (the bound licensing the induction hypothesis)
-/
theorem uTypeCount_snce_substLeaf_le {j : ℕ} {L : List USForm} (hLp : ∀ u ∈ L, IsPureType u)
    {ψ χ : USForm} (hψ : IsSOnly ψ) (hχ : IsSOnly χ) :
    uTypeCount (USForm.snce (substLeaf (unabstrFn j L) ψ) (substLeaf (unabstrFn j L) χ))
      ≤ L.length := by
  simp only [uTypeCount]
  refine List.Subperm.length_le ((uTypes_nodup _).subperm ?_)
  intro u hu
  rcases mem_uTypes_snce.mp hu with h | h
  · exact mem_uTypes_substLeaf_of_isSOnly (mem_uTypes_unabstrFn hLp) hψ u h
  · exact mem_uTypes_substLeaf_of_isSOnly (mem_uTypes_unabstrFn hLp) hχ u h

/-- The reindexed constituent inherits GHR 10.2.6's precondition from the abstracted tail. -/
theorem hasPureUTypes_snce_substLeaf {j : ℕ} {L : List USForm} (hLp : ∀ u ∈ L, IsPureType u)
    {ψ χ : USForm} (hψ : IsSOnly ψ) (hχ : IsSOnly χ) :
    HasPureUTypes (USForm.snce (substLeaf (unabstrFn j L) ψ) (substLeaf (unabstrFn j L) χ)) := by
  intro u hu
  rcases mem_uTypes_snce.mp hu with h | h
  · exact hLp u (mem_uTypes_substLeaf_of_isSOnly (mem_uTypes_unabstrFn hLp) hψ u h)
  · exact hLp u (mem_uTypes_substLeaf_of_isSOnly (mem_uTypes_unabstrFn hLp) hχ u h)

/-- **The reindexing inverts the abstraction syntactically.** This is the only place the
freshness of the abstraction indices is used, and it is what makes the equivalence step need no
side-condition on the valuation. -/
theorem substLeaf_mapU_abstr {j : ℕ} {L : List USForm} : ∀ {φ : USForm}, φ.maxLeaf < j →
    substLeaf (unabstrFn j L) (mapU (abstrFn j L) φ) = φ
  | .leaf i, hi => by
      simp only [mapU, substLeaf]
      exact unabstrFn_of_lt hi
  | .bot, _ => rfl
  | .imp φ ψ, hi => by
      have h1 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ ψ.maxLeaf) hi
      have h2 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_right φ.maxLeaf _) hi
      simp only [mapU, substLeaf]
      rw [substLeaf_mapU_abstr h1, substLeaf_mapU_abstr h2]
  | .untl ψ φ, hi => by
      simp only [mapU]
      by_cases hmem : USForm.untl ψ φ ∈ L
      · rw [show abstrFn j L (USForm.untl ψ φ) = USForm.leaf (j + L.idxOf (USForm.untl ψ φ)) from
          by simp only [abstrFn]; rw [if_pos hmem]]
        simp only [substLeaf]
        exact unabstrFn_abstrFn_of_mem hmem
      · rw [show abstrFn j L (USForm.untl ψ φ) = USForm.untl ψ φ from
          by simp only [abstrFn]; rw [if_neg hmem]]
        exact substLeaf_eq_self_of_lt (fun i hij => unabstrFn_of_lt hij) hi
  | .snce ψ φ, hi => by
      have h1 : ψ.maxLeaf < j := lt_of_le_of_lt (le_max_left _ φ.maxLeaf) hi
      have h2 : φ.maxLeaf < j := lt_of_le_of_lt (le_max_right ψ.maxLeaf _) hi
      simp only [mapU, substLeaf]
      rw [substLeaf_mapU_abstr h1, substLeaf_mapU_abstr h2]

/--
**The reindexing-and-recursion pass of GHR Lemma 10.2.6.**

`ψ` is Lemma 10.2.5's output: separated and `(A,B)`-typed. Substituting the abstracted types back
for their fresh leaves leaves the `untl` nodes alone — they are `untl B A`, whose arguments
mention no fresh index — and recontaminates exactly the `snce` constituents, whose arguments were
`untl`-free. `mapS k` fires `k` at each of those, and `hk` is the recursive call's contract,
available at every formula whose type count is at most `L.length`: the pre-abstraction count less
one, by part (c).

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6 (the reindexing and recursive-call step)
-/
theorem mapS_substLeaf_spec {A B : USForm} (hAu : IsUOnly A) (hBu : IsUOnly B) {j : ℕ}
    {L : List USForm} (hLp : ∀ u ∈ L, IsPureType u) (hj : (USForm.untl B A).maxLeaf < j)
    {k : USForm → USForm}
    (hk : ∀ χ : USForm, uTypeCount χ ≤ L.length → HasPureUTypes χ →
      IsSeparated (k χ) ∧ (∀ v t, usTruth v t (k χ) ↔ usTruth v t χ) ∧
        ∀ u ∈ uTypes (k χ), u ∈ uTypes χ)
    {ψ : USForm} (hψ : IsUTyped A B ψ) :
    IsSeparated (mapS k (substLeaf (unabstrFn j L) ψ)) ∧
      (∀ v t, usTruth v t (mapS k (substLeaf (unabstrFn j L) ψ)) ↔
        usTruth v t (substLeaf (unabstrFn j L) ψ)) ∧
      ∀ u ∈ uTypes (mapS k (substLeaf (unabstrFn j L) ψ)), u = USForm.untl B A ∨ u ∈ L := by
  induction hψ with
  | leaf i =>
      rw [show substLeaf (unabstrFn j L) (USForm.leaf i) = unabstrFn j L i from rfl,
        mapS_unabstrFn hLp i]
      exact ⟨isSeparated_unabstrFn hLp i, fun _ _ => Iff.rfl,
        fun u hu => Or.inr (mem_uTypes_unabstrFn hLp i u hu)⟩
  | bot =>
      rw [show substLeaf (unabstrFn j L) USForm.bot = USForm.bot from rfl,
        show mapS k USForm.bot = USForm.bot from rfl]
      exact ⟨IsSeparated.bot, fun _ _ => Iff.rfl, fun u hu => absurd hu (by simp)⟩
  | imp _ _ ihφ ihψ =>
      simp only [substLeaf, mapS, usTruth_imp_iff, mem_uTypes_imp]
      refine ⟨IsSeparated.imp ihφ.1 ihψ.1, fun v t => imp_congr (ihφ.2.1 v t) (ihψ.2.1 v t),
        fun u hu => ?_⟩
      rcases hu with h | h
      · exact ihφ.2.2 u h
      · exact ihψ.2.2 u h
  | untl =>
      rw [substLeaf_eq_self_of_lt (fun i hij => unabstrFn_of_lt hij) hj,
        show mapS k (USForm.untl B A) = USForm.untl B A from rfl]
      exact ⟨IsSeparated.untl hBu hAu, fun _ _ => Iff.rfl,
        fun u hu => Or.inl (by simpa using hu)⟩
  | @snce ψ' χ' hψ' hχ' =>
      simp only [substLeaf, mapS]
      obtain ⟨hs, ht, hu'⟩ := hk
        (USForm.snce (substLeaf (unabstrFn j L) ψ') (substLeaf (unabstrFn j L) χ'))
        (uTypeCount_snce_substLeaf_le hLp hψ' hχ')
        (hasPureUTypes_snce_substLeaf hLp hψ' hχ')
      refine ⟨hs, ht, fun u hu => Or.inr ?_⟩
      rcases mem_uTypes_snce.mp (hu' u hu) with h | h
      · exact mem_uTypes_substLeaf_of_isSOnly (mem_uTypes_unabstrFn hLp) hψ' u h
      · exact mem_uTypes_substLeaf_of_isSOnly (mem_uTypes_unabstrFn hLp) hχ' u h

/-! ## GHR Lemma 10.2.6

The recursion is GHR's induction on the number of `U`-types, with the type count supplied as an
explicit budget. A direct well-founded recursion on `uTypeCount` is not available: the recursive
call is fired by `mapS` at constituents that are not syntactic subterms of the definition's
argument and are not even in scope at definition time, so no `decreasing_by` goal can be stated
for it. The budget is the standard rendering of the same induction, and `sepFuel_spec` is where
the three decrease obligations are discharged — `sepMulti` instantiates the budget at the
measure, so nothing about the budget leaks into the statement of the lemma. -/

/-- One step of GHR Lemma 10.2.6's induction, with `k` standing for the recursive call: keep the
first type, abstract the rest to fresh leaves, separate by Lemma 10.2.5, reindex back, and fire
`k` at the recontaminated `snce` constituents. A formula with no types is already separated and
is returned unchanged. -/
def sepBody (k : USForm → USForm) (φ : USForm) : USForm :=
  match uTypes φ with
  | [] => φ
  | USForm.untl B A :: rest =>
      mapS k (substLeaf (unabstrFn φ.freshLeaf rest)
        (sepU A B (mapU (abstrFn φ.freshLeaf rest) φ)))
  | _ :: _ => φ

theorem sepBody_nil {k : USForm → USForm} {φ : USForm} (h : uTypes φ = []) :
    sepBody k φ = φ := by
  unfold sepBody; rw [h]

theorem sepBody_cons {k : USForm → USForm} {φ A B : USForm} {rest : List USForm}
    (h : uTypes φ = USForm.untl B A :: rest) :
    sepBody k φ = mapS k (substLeaf (unabstrFn φ.freshLeaf rest)
      (sepU A B (mapU (abstrFn φ.freshLeaf rest) φ))) := by
  unfold sepBody; rw [h]

/-- GHR Lemma 10.2.6's construction with an explicit budget for the number of `U`-types left to
eliminate. A plain `def`, deliberately not `noncomputable`: the downstream ZTime translation's
executability deliverable consumes it transitively. -/
def sepFuel : ℕ → USForm → USForm
  | 0, φ => φ
  | n + 1, φ => sepBody (sepFuel n) φ

/-- **GHR Lemma 10.2.6's separating function**: the budget instantiated at the measure. A plain
`def`, deliberately not `noncomputable`. -/
def sepMulti (φ : USForm) : USForm := sepFuel (uTypeCount φ) φ

/--
**GHR Lemma 10.2.6**, with the budget explicit: a formula all of whose `untl` types are pure is
equivalent to a separated formula introducing no new type.

The three decrease obligations are discharged here, each by its own named result and none
standing in for another: part (a) by `uTypes_mapU_abstr_eq_head` (it is what makes the abstracted
formula single-typed), part (b) by `uTypes_sepU`, which is a citation of Phase 22.2's
`isUTyped_sepU` (it is what makes the reindexing's image the only source of new types), and part
(c) by `uTypeCount_snce_substLeaf_le`, which is what licenses the recursive call `ih` at the
reduced budget.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6
-/
theorem sepFuel_spec : ∀ (n : ℕ) (φ : USForm), uTypeCount φ ≤ n → HasPureUTypes φ →
    IsSeparated (sepFuel n φ) ∧ (∀ v t, usTruth v t (sepFuel n φ) ↔ usTruth v t φ) ∧
      ∀ u ∈ uTypes (sepFuel n φ), u ∈ uTypes φ := by
  intro n
  induction n with
  | zero =>
      intro φ hcount _
      exact ⟨IsSeparated.ofIsSOnly (isSOnly_of_uTypeCount_le_zero hcount),
        fun _ _ => Iff.rfl, fun _ hu => hu⟩
  | succ n ih =>
      intro φ hcount hpure
      rcases eq_or_ne (uTypes φ) [] with hlist | hne
      · rw [show sepFuel (n + 1) φ = φ from sepBody_nil hlist]
        refine ⟨IsSeparated.ofIsSOnly (isSOnly_of_uTypes_empty ?_), fun _ _ => Iff.rfl,
          fun _ hu => hu⟩
        intro u hu
        rw [hlist] at hu
        simp at hu
      · obtain ⟨t, rest, hlist⟩ := List.exists_cons_of_ne_nil hne
        obtain ⟨A, B, rfl, hAs, hBs, hAu, hBu⟩ := hpure t (by rw [hlist]; simp)
        have hmax : φ.maxLeaf < φ.freshLeaf := USForm.lt_freshLeaf φ
        have hLp : ∀ u ∈ rest, IsPureType u := fun u hu =>
          hpure u (by rw [hlist]; exact List.mem_cons_of_mem _ hu)
        have hj : (USForm.untl B A).maxLeaf < φ.freshLeaf :=
          lt_of_le_of_lt (maxLeaf_le_of_mem_uTypes (by rw [hlist]; simp)) hmax
        have hsingle : IsUSingleType A B (mapU (abstrFn φ.freshLeaf rest) φ) :=
          isUSingleType_of_uTypes fun u hu => uTypes_mapU_abstr_eq_head hlist hu
        have htyped : IsUTyped A B (sepU A B (mapU (abstrFn φ.freshLeaf rest) φ)) :=
          isUTyped_sepU hAs hBs hsingle
        have hrestlen : rest.length ≤ n := by
          have hc : uTypeCount φ = rest.length + 1 := by rw [uTypeCount, hlist]; simp
          omega
        have hk : ∀ χ : USForm, uTypeCount χ ≤ rest.length → HasPureUTypes χ →
            IsSeparated (sepFuel n χ) ∧
            (∀ v t, usTruth v t (sepFuel n χ) ↔ usTruth v t χ) ∧
              ∀ u ∈ uTypes (sepFuel n χ), u ∈ uTypes χ :=
          fun χ hc hp => ih χ (le_trans hc hrestlen) hp
        obtain ⟨hsep, htruth, hutypes⟩ := mapS_substLeaf_spec hAu hBu hLp hj hk htyped
        rw [show sepFuel (n + 1) φ = mapS (sepFuel n) (substLeaf (unabstrFn φ.freshLeaf rest)
          (sepU A B (mapU (abstrFn φ.freshLeaf rest) φ))) from sepBody_cons hlist]
        refine ⟨hsep, fun v t => ?_, fun u hu => ?_⟩
        · calc usTruth v t (mapS (sepFuel n) (substLeaf (unabstrFn φ.freshLeaf rest)
                (sepU A B (mapU (abstrFn φ.freshLeaf rest) φ))))
            _ ↔ usTruth v t (substLeaf (unabstrFn φ.freshLeaf rest)
                (sepU A B (mapU (abstrFn φ.freshLeaf rest) φ))) := htruth v t
            _ ↔ usTruth (fun i s => usTruth v s (unabstrFn φ.freshLeaf rest i)) t
                (sepU A B (mapU (abstrFn φ.freshLeaf rest) φ)) := usTruth_substLeaf _ _ _ _
            _ ↔ usTruth (fun i s => usTruth v s (unabstrFn φ.freshLeaf rest i)) t
                (mapU (abstrFn φ.freshLeaf rest) φ) := usTruth_sepU hAs hBs hsingle _ t
            _ ↔ usTruth v t (substLeaf (unabstrFn φ.freshLeaf rest)
                (mapU (abstrFn φ.freshLeaf rest) φ)) := (usTruth_substLeaf _ _ _ _).symm
            _ ↔ usTruth v t φ := by rw [substLeaf_mapU_abstr hmax]
        · rcases hutypes u hu with h | h
          · rw [hlist, h]; simp
          · rw [hlist]; exact List.mem_cons_of_mem _ h

/--
**GHR Lemma 10.2.6**, the separatedness half: a formula all of whose `untl` types are built
without `S` or `U` is equivalent to a syntactically separated formula.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6 (the conclusion's separatedness)
-/
theorem isSeparated_sepMulti {φ : USForm} (h : HasPureUTypes φ) : IsSeparated (sepMulti φ) :=
  (sepFuel_spec (uTypeCount φ) φ le_rfl h).1

/--
**GHR Lemma 10.2.6**, the equivalence half.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6 (the equivalence)
-/
theorem usTruth_sepMulti {φ : USForm} (h : HasPureUTypes φ) (v : ℕ → ℤ → Prop) (t : ℤ) :
    usTruth v t (sepMulti φ) ↔ usTruth v t φ :=
  (sepFuel_spec (uTypeCount φ) φ le_rfl h).2.1 v t

/--
**GHR Lemma 10.2.6**, the typedness half: in the separated equivalent, `U` appears only in the
forms `U(Aᵢ, Bᵢ)` it already appeared in. With `uTypes_eq_self_of_isPureType` this also gives
`HasPureUTypes (sepMulti φ)`, so the conclusion can feed the next lemma's hypothesis.

Paper: [GHR][gabbay1994] vol. 1, Lemma 10.2.6 (the conclusion's "`U` appears only in the forms
`U(Aᵢ, Bᵢ)`" clause)
-/
theorem uTypes_sepMulti {φ : USForm} (h : HasPureUTypes φ) :
    ∀ u ∈ uTypes (sepMulti φ), u ∈ uTypes φ :=
  (sepFuel_spec (uTypeCount φ) φ le_rfl h).2.2

/-- The conclusion of GHR Lemma 10.2.6 re-establishes its own hypothesis. -/
theorem hasPureUTypes_sepMulti {φ : USForm} (h : HasPureUTypes φ) :
    HasPureUTypes (sepMulti φ) := fun u hu => h u (uTypes_sepMulti h u hu)

end FormalSystem.Metalogic.Expressiveness.SeparationZ
