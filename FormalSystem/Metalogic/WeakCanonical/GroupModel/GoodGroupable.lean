/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import FormalSystem.Metalogic.WeakCanonical.RealModel.GoodDense
import Mathlib.Algebra.Order.Monoid.Prod

/-!
# Reynolds §8 `good`, transposed to the non-Archimedean discrete carrier `ℚ ×ₗ ℤ`

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§8 *"Doets' Theorem"*, printed **p.185** — the *good* definitional preliminaries.

This module opens the group-model side of §8. It lands `QZStructure` (a monadic structure whose
flow of time is the whole of `ℚ ×ₗ ℤ`), the `goodGroupable` ∃-notion built on it, the two
transfer lemmas that notion needs, and the two endpoint corollaries that fix the shape of
everything downstream. It is the target-structure vocabulary for the direct construction over a
non-Archimedean *discrete* carrier; the companion lemma that consumes `goodGroupable` is not in
this module.

## The source sentence

Printed p.185, from §8's preliminaries (`k ≥ 2` is fixed there):

> Say that `M` is *good* if and only if there is some `N ≡_k M` such that the flow of time of
> `N` is an interval of the reals.

`goodGroupable` is that sentence with *"an interval of the reals"* replaced by *"the ordered
group `ℚ ×ₗ ℤ`"*, and nothing else changed — same `∃`, same `≡_k`, same orientation of the
`KEquiv` (the target structure on the right). The verbatim source block, the page measurement
that establishes p.185, and the corpus-reliability note are all held once in
`FormalSystem/Metalogic/WeakCanonical/RealModel/GoodDense.lean` (its `## The source, verbatim`
section); this module consumes that transcription rather than repeating it.

## Source phrase to declaration map

| Reynolds' phrase (printed p.185) | Declaration in this module |
|---|---|
| *"the flow of time of `N`"* — here `ℚ ×ₗ ℤ` rather than an interval of `ℝ` | `QZStructure`, `QZStructure.toMonadic`, `QZStructure.toOrdered` |
| the flow **is** the carrier, not a subtype of it | `QZStructure.toOrdered_carrier` (`rfl`) |
| *"`M` is good"* | `goodGroupable` |
| *"there is some `N ≡_k M`"* — the notion is `≡_k`-invariant | `goodGroupable_of_kEquiv` |
| the notion depends only on order-and-predicate structure | `goodGroupable_of_orderIso` |
| *"since `k ≥ 2` … both have a right (resp. left) hand end point"* | `noMaxOrder_of_goodGroupable`, `noMinOrder_of_goodGroupable` |

## ADAPTED-FROM

Two sibling modules, both **read, not edited**, by this one:

* `FormalSystem/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` — the `ℤ` analogue:
  `ZIntervalStructure` (`:35`), `ZIntervalStructure.toOrdered` (`:65`), `good` (`:78`),
  `VeryGood` (`:86`), for Reynolds' *discrete* development (Lemma 14, printed p.190).
* `FormalSystem/Metalogic/WeakCanonical/RealModel/GoodDense.lean` — the `ℝ` analogue:
  `RIntervalStructure` (`:175`), `goodDense` (`:237`), `veryGoodDense` (`:251`), for §8's dense
  development (Lemma 11, printed pp.185-186). `noMaxOrder_of_kEquiv` (`:469`) and
  `noMinOrder_of_kEquiv` (`:485`) are proved there and used here.

What is mirrored from them is the **API shape** — the `structure`/`toMonadic`/`toOrdered`
triple, the `∃`-shaped `good…` predicate with the target on the right of the `KEquiv`, the
`…_of_kEquiv` / `…_of_orderIso` transfer pair, the `noMaxOrder…` / `noMinOrder…` corollaries.
The *representation* is deliberately not mirrored, for the two reasons below.

### Design ruling 1: the full carrier, not an `Option`-bounds interval

`ZIntervalStructure` represents its flow of time by `lo hi : Option ℤ`. That works at `ℤ`
because every interval of `ℤ` is endpoint-determined: an `Option`-endpoint pair names it
uniquely. **That is false at `ℚ ×ₗ ℤ`**, and the reason is machine-checked rather than
asserted. Take

  `S = {x : ℚ ×ₗ ℤ | (ofLex x).1 < 0}`.

`S` is `Set.OrdConnected` — it is an interval in the only sense that survives at this carrier —
yet `S` has no greatest element (bump the `ℤ`-coordinate: `Prod.Lex.right _ (by simp)` from
`x` to `toLex ((ofLex x).1, (ofLex x).2 + 1)` stays inside `S`), and `Sᶜ` has no least element
(drop the `ℤ`-coordinate, same step). So `S` is neither `Iio b` nor `Iic b` for any `b`, and no
`Option`-endpoint pair denotes it. An `Option`-bounds mirror would therefore not even *express*
the ord-connected subsets of this carrier, let alone characterise them.

A second, independent reason: the frame-side construction downstream needs the carrier to be an
ordered *group* — it forms sums and differences of durations. An interval of `ℚ ×ₗ ℤ` is not a
group (it is not closed under `+` or negation), so the interval representation would lose
exactly the structure the construction is for. Both reasons point the same way: the flow of time
here is the whole carrier, and `QZStructure` carries only the predicate interpretations.

### Design ruling 2: there is no `veryGoodGroupable`, and none may be added

`GoodStructures.lean` has `VeryGood` and `GoodDense.lean` has `veryGoodDense`, each quantifying
the good-ness of every subinterval. **The analogue here is unsatisfiable at `k ≥ 2`, so no such
definition may be added by symmetry with those two.** `ℚ ×ₗ ℤ` is `NoMaxOrder` and `NoMinOrder`
(the two instances below), and at `k ≥ 2` `noMaxOrder_of_kEquiv` / `noMinOrder_of_kEquiv`
propagate that unboundedness backwards across `≡_k`: anything `goodGroupable` inherits it. A
closed subinterval `M | [t,u]` has a greatest and a least element, so it can never be
`goodGroupable`; a `veryGoodGroupable` quantifying over such subintervals would be identically
false on every non-degenerate structure, and every theorem proved from it would be vacuous.

`noMaxOrder_of_goodGroupable` and `noMinOrder_of_goodGroupable` below are the guardrail that
makes this a checked fact rather than a comment: they are the exact implications that would have
to be dodged for such a definition to be non-vacuous.

## Carrier gate

The four `example … := inferInstance` lines are not decoration. `FormalSystem.Semantics.Valid`
(`Validity.lean:94`) binds its duration type under exactly `AddCommGroup`, `LinearOrder`,
`IsOrderedAddMonoid` and `Nontrivial`, and `SemanticConsequence` binds the same four. The four
gate lines make *"`ℚ ×ₗ ℤ` is an admissible duration type"* a compile-time invariant of this
module, so the frame-side construction downstream inherits it instead of re-deriving it.

`Mathlib.Algebra.Order.Monoid.Prod` is imported for that gate and only for it: it supplies the
`IsOrderedAddMonoid` instance on the lexicographic product. Without it the third gate line fails
with `synthInstanceFailed` — which is the point of stating the gate.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.Metalogic.Core

/-! ## Carrier gate: `ℚ ×ₗ ℤ` satisfies the four `Valid`/`SemanticConsequence` binders. -/

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

/-! ## The target structure -/

structure QZStructure (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    where
  interp (p : sig.preds) : ℚ ×ₗ ℤ → Prop

def QZStructure.toMonadic (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (Q : QZStructure sig) : MonadicStructure sig where
  carrier := ℚ ×ₗ ℤ
  interp p x := Q.interp p x

def QZStructure.toOrdered (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (Q : QZStructure sig) : OrderedMonadicStructure sig where
  carrier := ℚ ×ₗ ℤ
  interp p x := Q.interp p x
  carrierOrder := inferInstance

theorem QZStructure.toOrdered_carrier (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (Q : QZStructure sig) :
    (Q.toOrdered sig).carrier = (ℚ ×ₗ ℤ) := rfl

/-! ## `goodGroupable` -/

def goodGroupable (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M : OrderedMonadicStructure sig) : Prop :=
  ∃ (Q : QZStructure sig), KEquiv sig k M (Q.toOrdered sig)

theorem goodGroupable_of_kEquiv (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) {M N : OrderedMonadicStructure sig}
    (h : KEquiv sig k M N) (hN : goodGroupable sig k N) : goodGroupable sig k M := by
  obtain ⟨Q, hQ⟩ := hN
  exact ⟨Q, h.trans hQ⟩

theorem goodGroupable_of_orderIso (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) {M N : OrderedMonadicStructure sig}
    (f : M.carrier ≃o N.carrier)
    (h_pred : ∀ (p : sig.preds) (x : M.carrier), M.interp p x ↔ N.interp p (f x))
    (hN : goodGroupable sig k N) : goodGroupable sig k M :=
  goodGroupable_of_kEquiv sig k (k_equiv_of_iso sig k M N f h_pred) hN

/-! ## Endpoint consequences (why the target has no bounded-interval analogue) -/

instance : NoMaxOrder (ℚ ×ₗ ℤ) :=
  ⟨fun a => ⟨toLex ((ofLex a).1, (ofLex a).2 + 1), by
    have h : a = toLex ((ofLex a).1, (ofLex a).2) := rfl
    rw [h]; exact Prod.Lex.right _ (by simp)⟩⟩

instance : NoMinOrder (ℚ ×ₗ ℤ) :=
  ⟨fun a => ⟨toLex ((ofLex a).1, (ofLex a).2 - 1), by
    have h : a = toLex ((ofLex a).1, (ofLex a).2) := rfl
    rw [h]; exact Prod.Lex.right _ (by simp)⟩⟩

theorem noMaxOrder_of_goodGroupable (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) {M : OrderedMonadicStructure sig}
    (h : goodGroupable sig k M) : NoMaxOrder M.carrier := by
  obtain ⟨Q, hQ⟩ := h
  haveI : NoMaxOrder (Q.toOrdered sig).carrier := inferInstanceAs (NoMaxOrder (ℚ ×ₗ ℤ))
  exact noMaxOrder_of_kEquiv sig k hk hQ.symm

theorem noMinOrder_of_goodGroupable (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) (hk : 2 ≤ k) {M : OrderedMonadicStructure sig}
    (h : goodGroupable sig k M) : NoMinOrder M.carrier := by
  obtain ⟨Q, hQ⟩ := h
  haveI : NoMinOrder (Q.toOrdered sig).carrier := inferInstanceAs (NoMinOrder (ℚ ×ₗ ℤ))
  exact noMinOrder_of_kEquiv sig k hk hQ.symm

end FormalSystem.Metalogic.WeakCanonical
