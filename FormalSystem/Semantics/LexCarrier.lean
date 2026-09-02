/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Prod.Lex
import Mathlib.Algebra.Order.Monoid.Prod
import Mathlib.Algebra.Order.Archimedean.Basic
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Logic.Nontrivial.Basic
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean
import FormalSystem.Semantics.TemporalOrder

/-!
# `Prod.Lex` successor/predecessor infrastructure at `α ×ₗ ℤ`

Supplies the `SuccOrder` and `PredOrder` instances the pinned Mathlib lacks for `Prod.Lex`, so
that a lexicographic product over `ℤ` can serve as a duration carrier — at `ℚ ×ₗ ℤ` for
`Metalogic/Z1Countermodel.lean`'s CEF-closing countermodel (discharging
`bl_soundness_discrete_succ`'s `[SuccOrder] [PredOrder]` binders, report §6.1), and at `ℤ ×ₗ ℤ`
for `Metalogic/Independence/LexIntWitness.lean`'s `Sat .Discrete` separation.

## The first factor is arbitrary; only the second must be `ℤ`

Nothing below uses any property of `ℚ`. `lexSucc_le_iff` and `le_lexPred_iff` go through
`Prod.Lex.le_iff'` / `Prod.Lex.lt_iff'` and `Int.lt_iff_add_one_le`, all of which constrain only
the *second* factor. The file is therefore stated at an arbitrary ordered abelian group `α` in
the first coordinate, and both consumers are instantiations. The two carriers behave differently
in exactly one respect — a dense `α` such as `ℚ` makes the first coordinate un-steppable, a
discrete `α` such as `ℤ` does not — and that difference is invisible to everything here, because
the successor and predecessor functions never touch the first coordinate either way.

## Confirming the Mathlib gap

Under the pinned Mathlib version there is no `SuccOrder (α ×ₗ β)` / `PredOrder (α ×ₗ β)` instance
anywhere in the tree: `Mathlib/Order/SuccPred/Basic.lean` and every other `SuccPred` file
mention neither `Lex` nor `Prod`, and the only lexicographic `SuccOrder`/`PredOrder` instances in
the pinned snapshot are the unrelated `Lex (Π₀ i, α i)` (`Data/DFinsupp/Lex.lean`) and
`Lex R⟦Γ⟧` (`RingTheory/HahnSeries/Lex.lean`) constructions. So this file is not redundant with
anything upstream.

## What *is* already free from Mathlib

`AddCommGroup (α ×ₗ ℤ)` and `LinearOrder (α ×ₗ ℤ)` synthesize with no help: `Lex.instAddCommGroup`
(`Algebra/Order/Group/Synonym.lean`, the additive counterpart of `Lex.instCommGroup`) transfers
`AddCommGroup (α × ℤ)` straight across the `Lex` type synonym, and `Prod.Lex.instLinearOrder`
(`Data/Prod/Lex.lean`) builds the lexicographic linear order from `LinearOrder α` and
`LinearOrder ℤ` directly. `IsOrderedAddMonoid (α ×ₗ ℤ)` is also free, via the `to_additive`
counterpart of `Prod.Lex.isOrderedMonoid` (`Algebra/Order/Monoid/Prod.lean`), whose hypotheses
(`AddLeftStrictMono` on the *first* factor, full `IsOrderedAddMonoid` on the *second*) both hold.
`Nontrivial (α ×ₗ ℤ)` is immediate from `Nontrivial ℤ` and needs nothing of `α`. The `example`s
below pin all four as already-inferred instances, so `TemporalOrder.of (α ×ₗ ℤ)` elaborates with
no local instance work — only the successor/predecessor structure is new.

**This instance-pinning ritual is deliberately carried once.** `LexIntWitness.lean` used to
repeat the same four `example`s at `ℤ ×ₗ ℤ`; that copy is gone, and the generic block below
covers both carriers.

## The successor and predecessor functions

`succ (a, n) = (a, n + 1)` and `pred (a, n) = (a, n - 1)`: only the *second* (`ℤ`) component
moves, since the first component has no successor structure to advance along. Built via
`SuccOrder.ofSuccLeIff`/`PredOrder.ofPredLeIff`, which need only a `Preorder`.

## Main results

* `LexInt.instSuccOrder`, `LexInt.instPredOrder` — the two missing instances
* `LexInt.isLeast_pos` — `toLex (0, 1)` is the least strictly positive element
* `LexInt.not_isSuccArchimedean`, `LexInt.not_isPredArchimedean`, `LexInt.not_archimedean` — the
  three non-Archimedean facts, as **citable theorems** rather than `example`s
-/

namespace FormalSystem.Semantics

namespace LexInt

open Prod.Lex

variable {α : Type*} [AddCommGroup α] [LinearOrder α] [IsOrderedAddMonoid α]

/-! ## The four ambient instances are already free -/

example : AddCommGroup (α ×ₗ ℤ) := inferInstance
example : LinearOrder (α ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (α ×ₗ ℤ) := inferInstance
example : Nontrivial (α ×ₗ ℤ) := inferInstance

/-- The lexicographic carrier is a bona fide temporal order. -/
example (α : Type) [AddCommGroup α] [LinearOrder α] [IsOrderedAddMonoid α] : TemporalOrder :=
  TemporalOrder.of (α ×ₗ ℤ)

/-! ## Successor -/

/-- Advance only the discrete (second) component. -/
private def lexSucc (p : α ×ₗ ℤ) : α ×ₗ ℤ := toLex ((ofLex p).1, (ofLex p).2 + 1)

private theorem lexSucc_le_iff {a b : α ×ₗ ℤ} : lexSucc a ≤ b ↔ a < b := by
  simp only [lexSucc, Prod.Lex.le_iff', Prod.Lex.lt_iff', ofLex_toLex]
  refine ⟨fun ⟨h1, h2⟩ => ⟨h1, fun heq => Int.lt_iff_add_one_le.mpr (h2 heq)⟩,
    fun ⟨h1, h2⟩ => ⟨h1, fun heq => Int.lt_iff_add_one_le.mp (h2 heq)⟩⟩

instance instSuccOrder : SuccOrder (α ×ₗ ℤ) := SuccOrder.ofSuccLeIff lexSucc lexSucc_le_iff

/-! ## Predecessor -/

/-- Retreat only the discrete (second) component. -/
private def lexPred (p : α ×ₗ ℤ) : α ×ₗ ℤ := toLex ((ofLex p).1, (ofLex p).2 - 1)

private theorem le_lexPred_iff {a b : α ×ₗ ℤ} : a ≤ lexPred b ↔ a < b := by
  simp only [lexPred, Prod.Lex.le_iff', Prod.Lex.lt_iff', ofLex_toLex]
  refine ⟨fun ⟨h1, h2⟩ => ⟨h1, fun heq => Int.lt_iff_add_one_le.mpr (by
    have := h2 heq; omega)⟩,
    fun ⟨h1, h2⟩ => ⟨h1, fun heq => by
      have := Int.lt_iff_add_one_le.mp (h2 heq); omega⟩⟩

/-
The dual of `SuccOrder.ofSuccLeIff` (`Mathlib/Order/SuccPred/Basic.lean`), built by hand rather
than through the `to_dual`-generated name: mirroring that constructor's own proof exactly,
substituting `pred`/`le_pred_of_lt`/`min_of_le_pred` for `succ`/`succ_le_of_lt`/`max_of_succ_le`.
-/
instance instPredOrder : PredOrder (α ×ₗ ℤ) where
  pred := lexPred
  pred_le _ := (le_lexPred_iff.1 le_rfl).le
  min_of_le_pred ha := (lt_irrefl _ <| le_lexPred_iff.1 ha).elim
  le_pred_of_lt := le_lexPred_iff.2

/-! ## The least strictly positive element -/

/--
**`toLex (0, 1)` is the least strictly positive element of `α ×ₗ ℤ`.**

New content rather than a move: this file builds `SuccOrder`/`PredOrder` from hand-written
`succ`/`pred` functions and never had an `IsLeast {x | 0 < x}` theorem at all.
`DurationClassification.isLeast_succ_of_isLeast_pos` and `isGreatest_pred_of_isLeast_pos` turn
this one fact into the immediate-neighbour statements a `.Discrete` frame-class membership
argument needs, so a consumer never has to redo the coordinate bookkeeping.
-/
theorem isLeast_pos :
    IsLeast {x : α ×ₗ ℤ | 0 < x} (toLex ((0 : α), (1 : ℤ))) := by
  constructor
  · show (0 : α ×ₗ ℤ) < toLex ((0 : α), (1 : ℤ))
    rw [show (0 : α ×ₗ ℤ) = toLex ((0 : α), (0 : ℤ)) from rfl, Prod.Lex.toLex_lt_toLex]
    exact Or.inr ⟨rfl, by norm_num⟩
  · intro z hz
    have hz' : (0 : α ×ₗ ℤ) < z := hz
    rw [show (0 : α ×ₗ ℤ) = toLex ((0 : α), (0 : ℤ)) from rfl, show z = toLex (ofLex z) from rfl,
      Prod.Lex.toLex_lt_toLex] at hz'
    rw [show z = toLex (ofLex z) from rfl, Prod.Lex.toLex_le_toLex]
    rcases hz' with h | ⟨h1, h2⟩
    · exact Or.inl h
    · exact Or.inr ⟨h1, h2⟩

/-! ## `α ×ₗ ℤ` is not Archimedean, in any of the three senses

These three were `example`s, which cannot be cited. They are theorems now, because
`LexIntWitness.lean`'s `lexIntStaticFrame_not_sat` needs exactly the third of them, and the
first two document the same obstruction at the successor structure this file builds.

All three need `[Nontrivial α]`: over a trivial first factor `α ×ₗ ℤ` is order-isomorphic to `ℤ`
and every one of the three properties *holds*. The obstruction is precisely that the first
coordinate has room the second coordinate's steps can never cross.
-/

/--
**`α ×ₗ ℤ` is not successor-Archimedean.** For `a < b` in `α`, the points `(a, 0)` and `(b, 0)`
are related by `≤`, yet no finite number of `succ` steps — which only ever advance the second
coordinate — can move the first coordinate from `a` to `b`.
-/
theorem not_isSuccArchimedean [Nontrivial α] : ¬ IsSuccArchimedean (α ×ₗ ℤ) := by
  intro h
  obtain ⟨a, b, hab⟩ := exists_pair_lt α
  obtain ⟨n, hn⟩ := h.exists_succ_iterate_of_le
    (a := toLex (a, (0 : ℤ))) (b := toLex (b, (0 : ℤ)))
    (by rw [Prod.Lex.le_iff']; exact ⟨hab.le, fun heq => absurd heq (ne_of_lt hab)⟩)
  have hfst : ∀ m : ℕ, (ofLex ((Order.succ)^[m] (toLex (a, (0 : ℤ))))).1 = a := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [Function.iterate_succ_apply']
      show (ofLex (lexSucc ((Order.succ)^[m] (toLex (a, (0 : ℤ)))))).1 = a
      simp only [lexSucc, ofLex_toLex]
      exact ih
  have hcontra := congrArg (fun x => (ofLex x).1) hn
  rw [hfst n] at hcontra
  simp only [ofLex_toLex] at hcontra
  exact absurd hcontra (ne_of_lt hab)

/-- The `PredOrder` mirror of `not_isSuccArchimedean`. -/
theorem not_isPredArchimedean [Nontrivial α] : ¬ IsPredArchimedean (α ×ₗ ℤ) := by
  intro h
  obtain ⟨a, b, hab⟩ := exists_pair_lt α
  obtain ⟨n, hn⟩ := h.exists_pred_iterate_of_le
    (a := toLex (a, (0 : ℤ))) (b := toLex (b, (0 : ℤ)))
    (by rw [Prod.Lex.le_iff']; exact ⟨hab.le, fun heq => absurd heq (ne_of_lt hab)⟩)
  have hfst : ∀ m : ℕ, (ofLex ((Order.pred)^[m] (toLex (b, (0 : ℤ))))).1 = b := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [Function.iterate_succ_apply']
      show (ofLex (lexPred ((Order.pred)^[m] (toLex (b, (0 : ℤ)))))).1 = b
      simp only [lexPred, ofLex_toLex]
      exact ih
  have hcontra := congrArg (fun x => (ofLex x).1) hn
  rw [hfst n] at hcontra
  simp only [ofLex_toLex] at hcontra
  exact absurd hcontra.symm (ne_of_lt hab)

/--
**`α ×ₗ ℤ` is not Archimedean.**

A different proposition from `not_isSuccArchimedean`, not a restatement of it: `Archimedean` is
about `nsmul` multiples of a positive element, `IsSuccArchimedean` about iterates of `Order.succ`.
Here `toLex (0, 1)`'s multiples never move the first coordinate off `0`, so they never dominate
`toLex (b - a, 0)` for `a < b`.
-/
theorem not_archimedean [Nontrivial α] : ¬ Archimedean (α ×ₗ ℤ) := by
  intro h
  obtain ⟨a, b, hab⟩ := exists_pair_lt α
  have hc : (0 : α) < b - a := sub_pos.mpr hab
  have hfst : ∀ n : ℕ, (ofLex (n • (toLex ((0 : α), (1 : ℤ)) : α ×ₗ ℤ))).1 = 0 := by
    intro n
    induction n with
    | zero => simp
    | succ m ih =>
        have hstep : (m + 1) • (toLex ((0 : α), (1 : ℤ)) : α ×ₗ ℤ)
            = m • (toLex ((0 : α), (1 : ℤ)) : α ×ₗ ℤ) + toLex ((0 : α), (1 : ℤ)) := by
          rw [succ_nsmul]
        rw [hstep]
        show (ofLex (m • (toLex ((0 : α), (1 : ℤ)) : α ×ₗ ℤ))).1 + 0 = 0
        rw [ih, add_zero]
  obtain ⟨n, hn⟩ := h.arch (toLex (b - a, (0 : ℤ))) isLeast_pos.1
  rw [show (toLex (b - a, (0 : ℤ)) : α ×ₗ ℤ) = toLex (b - a, (0 : ℤ)) from rfl,
    show (n • (toLex ((0 : α), (1 : ℤ)) : α ×ₗ ℤ))
      = toLex (ofLex (n • (toLex ((0 : α), (1 : ℤ)) : α ×ₗ ℤ))) from rfl,
    Prod.Lex.toLex_le_toLex] at hn
  rcases hn with h1 | ⟨h1, _⟩ <;> rw [hfst n] at h1
  · exact absurd hc (not_lt.mpr h1.le)
  · exact absurd h1 (ne_of_gt hc)

end LexInt

end FormalSystem.Semantics
