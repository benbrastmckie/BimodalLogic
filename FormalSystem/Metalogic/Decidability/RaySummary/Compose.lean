/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.KTypeFin
import FormalSystem.Metalogic.WeakCanonical.MixedSum
import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti

/-!
# Label-list segments and composition on representatives (B3b, the composition half)

`KTypeFin.lean` reads the `k`-type of a finite decidable structure off effectively, and in
particular the `k`-type of a half-open segment `segZ sig c a b` of a decidable colouring of
`ℤ`. This module supplies the two things an effective **composition** of such summaries needs,
and says precisely what "effective composition" means here.

## What "effective composition" means here, and why there is no `compose` on bare `k`-types

A `k`-type `KType sig k` is a function `NormalForm sig k 0 → Bool`, and most of its inhabitants
are the type of *nothing*: no structure realizes them. A function
`compose : KType sig k → KType sig k → KType sig k` on bare values would therefore have no
correctness statement off the realizable values — there is nothing for it to be correct *about*
at an unrealized argument — and any `compose` that is correct on realizable values is already
determined by them. So composition is stated on **representatives** instead: a finite segment is
represented by its list of letters, `listSeg l`, whose `k`-type is computable
(`kTypeOfFin_listSeg`), and the composition theorem is a **congruence**
(`kTypeOf_listSeg_append_congr`): the `k`-type of a concatenation `l₁ ++ l₂` depends only on the
`k`-types of `l₁` and `l₂`. That is the two-point instance of the mixing lemma
`kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean`): a concatenation *is* the ordered sum of
its two parts over the index order `Bool` (`listSeg_append_kEquiv`), and the mixing lemma
reduces a comparison of two such sums to a comparison of their `k`-type-coloured index orders,
which agree outright once the parts' `k`-types do. `Present.lean` computes path types by
closing a finite set of representative-carrying entries under this congruence; nothing here
summarizes a history, decides anything about `⊡`, or touches the realized triples `Hit`.

## The bridge from the time axis

A segment `segZ sig c a b` of a decidable colouring is order-isomorphic to the segment of its
label list `labels c a b` (the letters of `c` on `[a, b)`, read left to right), so the two
have the same `k`-type (`kTypeOf_segZ_eq_listSeg`, by `k_equiv_of_iso`). This is what lets a
summary of the time axis be handed to the list-based composition: every segment summary of
`KTypeSummary/Segment.lean` is the summary of a finite list of letters.

## Computability

`listSeg l` has carrier `Fin l.length`, whose `Fintype`, `DecidableEq`, decidable-order and
decidable-predicate instances are computable by construction — no `ℤ`-subtype instance is
involved, so the hazard documented in `KTypeFin.lean`'s header does not arise. `listSeg`,
`labels` and `kTypeOfFin (listSeg l) k` are `def`s and evaluate; the theorems are `Prop`, and
the mixing lemma's `LinearOrder Bool` path is irrelevant to their computability.

## No complexity bound

None is claimed, upper or lower. `decide` on `KType sig k` equality is exponential in
`|NormalForm sig k 0|`; witnesses run at depth 1 on lists of a few letters.

## Main definitions and results

* `listSeg` — the finite segment of a list of letters, carrier `Fin l.length`.
* `kTypeOfFin_listSeg` — its computable `k`-type is its `k`-type.
* `labels`, `kTypeOf_segZ_eq_listSeg` — a segment of a decidable colouring has the `k`-type of
  the segment of its label list.
* `listSeg_append_kEquiv` — a concatenation is the two-point ordered sum of its parts.
* `kTypeOf_listSeg_append_congr` — composition on representatives: the `k`-type of a
  concatenation depends only on the `k`-types of the parts.

## References

* [I. Hodkinson, F. Wolter, M. Zakharyaschev, *Decidable fragments of first-order temporal
  logics*, 2000] for the quasimodel over `⟨ℤ, <⟩` whose effective presentation this serves.
* [W. Thomas, *Ehrenfeucht-Fraïssé games, the composition method, and the monadic theory of
  ordinal words*, 1997] for the composition method the congruence instantiates.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

variable {sig : MonadicSignature}

/-! ## The segment of a list of letters -/

/-- **The finite segment of a list of letters**: carrier `Fin l.length`, the `i`-th point
coloured by the `i`-th letter, ordered as `Fin` is. -/
def listSeg (l : List (sig.preds → Bool)) : OrderedMonadicStructure sig where
  carrier := Fin l.length
  interp := fun p i => l.get i p = true
  carrierOrder := inferInstance

@[simp] theorem listSeg_interp (l : List (sig.preds → Bool)) (p : sig.preds)
    (i : Fin l.length) : (listSeg l).interp p i ↔ l.get i p = true := Iff.rfl

/-- The carrier of a list segment is finite — the `Fin` instance, computable. -/
instance listSegFintype (l : List (sig.preds → Bool)) : Fintype (listSeg l).carrier :=
  inferInstanceAs (Fintype (Fin l.length))

/-- Equality on a list segment is `Fin` equality, computable. -/
instance listSegDecidableEq (l : List (sig.preds → Bool)) : DecidableEq (listSeg l).carrier :=
  inferInstanceAs (DecidableEq (Fin l.length))

/-- The order on a list segment is the `Fin` order, computable. -/
instance listSegDecidableLT (l : List (sig.preds → Bool)) :
    DecidableRel (α := (listSeg l).carrier) (· < ·) :=
  inferInstanceAs (DecidableRel (α := Fin l.length) (· < ·))

/-- The predicates of a list segment are decided by `Bool` equality on the letters. -/
instance listSegDecidablePred (l : List (sig.preds → Bool)) :
    ∀ p, DecidablePred ((listSeg l).interp p) :=
  fun p i => inferInstanceAs (Decidable (l.get i p = true))

/-- The computable `k`-type of a list segment is its `k`-type. -/
theorem kTypeOfFin_listSeg [Fintype sig.preds] [DecidableEq sig.preds]
    (l : List (sig.preds → Bool)) (k : ℕ) :
    kTypeOfFin (listSeg l) k = kTypeOf sig k (listSeg l) :=
  kTypeOfFin_eq _ k

/-! ## A segment of the time axis is the segment of its label list -/

section Labels

variable (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (a b : ℤ)

/-- **The letters of a decidable colouring on `[a, b)`**, read left to right: the `i`-th letter
is the letter of `c` at time `a + i`. Empty when `b ≤ a`. -/
def labels : List (sig.preds → Bool) :=
  (List.range (b - a).toNat).map fun (i : ℕ) (p : sig.preds) => decide (c p (a + (i : ℤ)))

@[simp] theorem labels_length : (labels c a b).length = (b - a).toNat := by
  simp [labels]

theorem labels_getElem (i : ℕ) (hi : i < (labels c a b).length) (p : sig.preds) :
    (labels c a b)[i] p = decide (c p (a + i)) := by
  -- Restate the bound against the unfolded list first: `simp` will not rewrite under a
  -- `getElem` whose bound proof is typed against the folded `labels`.
  have hi' : i < ((List.range (b - a).toNat).map
      fun (i : ℕ) (p : sig.preds) => decide (c p (a + (i : ℤ)))).length := hi
  change (((List.range (b - a).toNat).map
      fun (i : ℕ) (p : sig.preds) => decide (c p (a + (i : ℤ))))[i]'hi') p = _
  simp

/-- The point of the segment `[a, b)` at time `t` is the `(t - a)`-th letter. -/
def segZToListSeg (t : (segZ sig c a b).carrier) : (listSeg (labels c a b)).carrier :=
  ⟨(t.1 - a).toNat, by rw [labels_length]; have := t.2; omega⟩

theorem segZToListSeg_strictMono : StrictMono (segZToListSeg c a b) := by
  intro s t hst
  change (s.1 - a).toNat < (t.1 - a).toNat
  have h : s.1 < t.1 := hst
  have := s.2.1
  omega

theorem segZToListSeg_surjective : Function.Surjective (segZToListSeg c a b) := by
  intro i
  have hi : i.1 < (b - a).toNat := by
    have h1 := i.2
    have h2 := labels_length c a b
    omega
  refine ⟨⟨a + i.1, by omega, by omega⟩, ?_⟩
  apply Fin.ext
  change (a + (i.1 : ℤ) - a).toNat = i.1
  omega

/-- **A segment of a decidable colouring has the `k`-type of the segment of its label list.**
The map `t ↦ t - a` is an order isomorphism `segZ sig c a b ≃o listSeg (labels c a b)`
preserving every letter, so `k_equiv_of_iso` applies. -/
theorem kTypeOf_segZ_eq_listSeg [Finite sig.preds] (k : ℕ) :
    kTypeOf sig k (segZ sig c a b) = kTypeOf sig k (listSeg (labels c a b)) := by
  refine k_equiv_of_iso sig k _ _
    (StrictMono.orderIsoOfSurjective _ (segZToListSeg_strictMono c a b)
      (segZToListSeg_surjective c a b)) ?_
  intro p t
  change c p t.1 ↔
    ((labels c a b)[(segZToListSeg c a b t).1]'(segZToListSeg c a b t).2) p = true
  rw [labels_getElem, decide_eq_true_iff]
  have := t.2.1
  change c p t.1 ↔ c p (a + (((t.1 - a).toNat : ℕ) : ℤ))
  rw [show a + (((t.1 - a).toNat : ℕ) : ℤ) = t.1 by omega]

end Labels

/-! ## A concatenation is the two-point ordered sum of its parts -/

section Append

variable (l₁ l₂ : List (sig.preds → Bool))

/-- The two summands of a concatenation, indexed by `Bool` with `false` (the left part) first. -/
abbrev appendSummand : Bool → OrderedMonadicStructure sig :=
  fun b => bif b then listSeg l₂ else listSeg l₁

/-- A point of the two-point sum, as a point of the concatenation: a left point stays where it
is, a right point is shifted past the left part. -/
def appendPt : (orderedSum sig Bool (appendSummand l₁ l₂)).carrier →
    (listSeg (l₁ ++ l₂)).carrier
  | ⟨false, i⟩ => ⟨i.1, by rw [List.length_append]; omega⟩
  | ⟨true, j⟩ => ⟨j.1 + l₁.length, by rw [List.length_append]; omega⟩

theorem appendPt_strictMono : StrictMono (appendPt l₁ l₂) := by
  intro s t hst
  have h : Sigma.Lex (· < ·) (fun _ => (· < ·)) s t := hst
  cases h with
  | left x y hij =>
    rename_i i j
    cases i <;> cases j
    · exact absurd hij (lt_irrefl _)
    · change x.1 < y.1 + l₁.length
      have := x.2
      omega
    · exact absurd hij (by decide)
    · exact absurd hij (lt_irrefl _)
  | right x y hxy =>
    rename_i i
    cases i
    · exact hxy
    · change x.1 + l₁.length < y.1 + l₁.length
      have : x.1 < y.1 := hxy
      omega

theorem appendPt_surjective : Function.Surjective (appendPt l₁ l₂) := by
  intro t
  have ht : t.1 < l₁.length + l₂.length := by
    have h1 := t.2
    have h2 : (l₁ ++ l₂).length = l₁.length + l₂.length := List.length_append
    omega
  by_cases h : t.1 < l₁.length
  · exact ⟨⟨false, ⟨t.1, h⟩⟩, Fin.ext rfl⟩
  · refine ⟨⟨true, ⟨t.1 - l₁.length, by omega⟩⟩, Fin.ext ?_⟩
    change t.1 - l₁.length + l₁.length = t.1
    omega

/-- **A concatenation is the two-point ordered sum of its parts**: `appendPt` is an order
isomorphism preserving every letter (`List.getElem_append_left`/`_right`), so
`k_equiv_of_iso` applies. -/
theorem listSeg_append_kEquiv [Finite sig.preds] (k : ℕ) :
    KEquiv sig k (listSeg (l₁ ++ l₂))
      (orderedSum sig Bool (fun b => bif b then listSeg l₂ else listSeg l₁)) := by
  refine k_equiv_of_iso sig k _ _
    (StrictMono.orderIsoOfSurjective _ (appendPt_strictMono l₁ l₂)
      (appendPt_surjective l₁ l₂)).symm ?_
  intro p x
  set s := (StrictMono.orderIsoOfSurjective _ (appendPt_strictMono l₁ l₂)
    (appendPt_surjective l₁ l₂)).symm x with hs
  have hx : appendPt l₁ l₂ s = x :=
    StrictMono.orderIsoOfSurjective_self_symm_apply _ (appendPt_strictMono l₁ l₂)
      (appendPt_surjective l₁ l₂) x
  change (l₁ ++ l₂).get x p = true ↔ (appendSummand l₁ l₂ s.1).interp p s.2
  rw [← hx]
  obtain ⟨b, i⟩ := s
  cases b
  · obtain ⟨n, hn⟩ := i
    change (l₁ ++ l₂).get ⟨n, _⟩ p = true ↔ l₁.get ⟨n, hn⟩ p = true
    simp [List.getElem_append_left, hn]
  · obtain ⟨n, hn⟩ := i
    change (l₁ ++ l₂).get ⟨n + l₁.length, _⟩ p = true ↔ l₂.get ⟨n, hn⟩ p = true
    simp only [List.get_eq_getElem]
    rw [← List.getElem_append_right' l₁ hn]

end Append

/-! ## Composition on representatives -/

-- linter.unusedFintypeInType: the `[Fintype sig.preds]` binder is consumed by the proof
-- (`k_equiv_of_iso` needs `Finite sig.preds`, derived from `Fintype`) rather than by the
-- conclusion, which mentions only `kTypeOf` and `listSeg`; it is the binder every consumer of the
-- computable `k`-type (`kTypeOfFin`, `kTypeOfFin_listSeg`) already carries. A `[DecidableEq
-- sig.preds]` binder that neither the statement nor the proof used was removed (the
-- `unusedArguments` environment linter reported it), so no `unusedDecidableInType` suppression
-- remains. Declaration-scoped, as for `exists_matching_factorization` in
-- `KTypeSummary/Family.lean`.
set_option linter.unusedFintypeInType false in
/-- **Composition on representatives.** The `k`-type of a concatenation depends only on the
`k`-types of the parts: the two-point instance of `kEquiv_orderedSum_of_kEquiv_colour`. Once
`h₁` and `h₂` are rewritten in, the two `k`-type-coloured index orders are literally the same
`kTypeColouring`, so the mixing lemma's hypothesis is `rfl`. -/
theorem kTypeOf_listSeg_append_congr [Fintype sig.preds] (k : ℕ)
    {l₁ l₁' l₂ l₂' : List (sig.preds → Bool)}
    (h₁ : kTypeOf sig k (listSeg l₁) = kTypeOf sig k (listSeg l₁'))
    (h₂ : kTypeOf sig k (listSeg l₂) = kTypeOf sig k (listSeg l₂')) :
    kTypeOf sig k (listSeg (l₁ ++ l₂)) = kTypeOf sig k (listSeg (l₁' ++ l₂')) := by
  have e₁ := listSeg_append_kEquiv l₁ l₂ k
  have e₂ := listSeg_append_kEquiv l₁' l₂' k
  have hcol : kTypeColouring sig k (fun b => bif b then listSeg l₂ else listSeg l₁) =
      kTypeColouring sig k (fun b => bif b then listSeg l₂' else listSeg l₁') := by
    unfold kTypeColouring
    congr 1
    funext b
    cases b
    · exact h₁
    · exact h₂
  have hmix := kEquiv_orderedSum_of_kEquiv_colour (sig := sig) k
    (fun b => bif b then listSeg l₂ else listSeg l₁)
    (fun b => bif b then listSeg l₂' else listSeg l₁')
    (by change kTypeOf _ _ _ = kTypeOf _ _ _; rw [hcol])
  exact e₁.trans (hmix.trans e₂.symm)

end FormalSystem.Metalogic.WeakCanonical
