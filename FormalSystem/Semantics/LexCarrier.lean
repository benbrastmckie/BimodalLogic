/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Data.Prod.Lex
import Mathlib.Algebra.Order.Monoid.Prod
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Rat.Cast.Order
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean
import FormalSystem.Semantics.TemporalOrder

/-!
# `Prod.Lex` successor/predecessor infrastructure at `ℚ ×ₗ ℤ`

Supplies the `SuccOrder` and `PredOrder` instances the pinned Mathlib lacks for `Prod.Lex`, so
that `ℚ ×ₗ ℤ` can serve as the carrier of `Metalogic/Z1Countermodel.lean`'s CEF-closing
countermodel, discharging `bl_soundness_discrete_succ`'s `[SuccOrder] [PredOrder]` binders
(report §6.1, closing paragraph).

## Confirming the Mathlib gap

Under the pinned Mathlib version there is no `SuccOrder (α ×ₗ β)` / `PredOrder (α ×ₗ β)` instance
anywhere in the tree: `Mathlib/Order/SuccPred/Basic.lean` and every other `SuccPred` file
mention neither `Lex` nor `Prod`, and the only lexicographic `SuccOrder`/`PredOrder` instances in
the pinned snapshot are the unrelated `Lex (Π₀ i, α i)` (`Data/DFinsupp/Lex.lean`) and
`Lex R⟦Γ⟧` (`RingTheory/HahnSeries/Lex.lean`) constructions. So this file is not redundant with
anything upstream.

## What *is* already free from Mathlib

`AddCommGroup (ℚ ×ₗ ℤ)` and `LinearOrder (ℚ ×ₗ ℤ)` synthesize with no help: `Lex.instAddCommGroup`
(`Algebra/Order/Group/Synonym.lean`, the additive counterpart of `Lex.instCommGroup`) transfers
`AddCommGroup (ℚ × ℤ)` straight across the `Lex` type synonym, and `Prod.Lex.instLinearOrder`
(`Data/Prod/Lex.lean`) builds the lexicographic linear order from `LinearOrder ℚ` and
`LinearOrder ℤ` directly. `IsOrderedAddMonoid (ℚ ×ₗ ℤ)` is also free, via the `to_additive`
counterpart of `Prod.Lex.isOrderedMonoid` (`Algebra/Order/Monoid/Prod.lean`), whose hypotheses
(`AddLeftStrictMono` on the *first* factor, full `IsOrderedAddMonoid` on the *second*) both hold
for `ℚ` and `ℤ`. `Nontrivial (ℚ ×ₗ ℤ)` is immediate from `Nontrivial ℤ`. The `example`s below pin
all four as already-inferred instances, so `TemporalOrder.of (ℚ ×ₗ ℤ)` elaborates with no local
instance work — only the successor/predecessor structure is new.

## The successor and predecessor functions

`succ (q, n) = (q, n + 1)` and `pred (q, n) = (q, n - 1)`: only the *second* (discrete) component
moves, since the first (dense) component has no successor structure to advance along. Built via
`SuccOrder.ofSuccLeIff`/`PredOrder.ofPredLeIff`.ker, which need only a `Preorder`, matching the
plan's documented approach — no fight with `Prod.Lex`'s order defeq materialized, so the
bare-successor-hypothesis fallback in the plan's Risks table is not needed.
-/

namespace FormalSystem.Semantics

open Prod.Lex

/-! ## The four ambient instances are already free -/

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

/-- The lexicographic carrier is a bona fide temporal order. -/
example : TemporalOrder := TemporalOrder.of (ℚ ×ₗ ℤ)

/-! ## Successor -/

/-- Advance only the discrete (second) component. -/
private def lexSucc (p : ℚ ×ₗ ℤ) : ℚ ×ₗ ℤ := toLex ((ofLex p).1, (ofLex p).2 + 1)

private theorem lexSucc_le_iff {a b : ℚ ×ₗ ℤ} : lexSucc a ≤ b ↔ a < b := by
  simp only [lexSucc, Prod.Lex.le_iff', Prod.Lex.lt_iff', ofLex_toLex]
  refine ⟨fun ⟨h1, h2⟩ => ⟨h1, fun heq => Int.lt_iff_add_one_le.mpr (h2 heq)⟩,
    fun ⟨h1, h2⟩ => ⟨h1, fun heq => Int.lt_iff_add_one_le.mp (h2 heq)⟩⟩

instance : SuccOrder (ℚ ×ₗ ℤ) := SuccOrder.ofSuccLeIff lexSucc lexSucc_le_iff

/-! ## Predecessor -/

/-- Retreat only the discrete (second) component. -/
private def lexPred (p : ℚ ×ₗ ℤ) : ℚ ×ₗ ℤ := toLex ((ofLex p).1, (ofLex p).2 - 1)

private theorem le_lexPred_iff {a b : ℚ ×ₗ ℤ} : a ≤ lexPred b ↔ a < b := by
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
instance : PredOrder (ℚ ×ₗ ℤ) where
  pred := lexPred
  pred_le _ := (le_lexPred_iff.1 le_rfl).le
  min_of_le_pred ha := (lt_irrefl _ <| le_lexPred_iff.1 ha).elim
  le_pred_of_lt := le_lexPred_iff.2

/-! ## Documentation: `ℚ ×ₗ ℤ` is not Archimedean-successor -/

/--
**`ℚ ×ₗ ℤ` is not successor-Archimedean.** Documentation only — this is never a proof
obligation the countermodel needs (the `bl_soundness_discrete_succ` binder bundle simply does
not assume `IsSuccArchimedean`), but it is what makes the countermodel's point legible: `(0, 0)`
and `(1, 0)` are related by `≤`, yet no finite number of `succ` steps (which only ever advance
the second coordinate) can reach the first coordinate `1` from `0`.
-/
example : ¬ IsSuccArchimedean (ℚ ×ₗ ℤ) := by
  intro h
  obtain ⟨n, hn⟩ := h.exists_succ_iterate_of_le
    (a := (toLex ((0 : ℚ), (0 : ℤ)))) (b := toLex ((1 : ℚ), (0 : ℤ)))
    (by rw [Prod.Lex.le_iff']; exact ⟨by norm_num, fun heq => by norm_num at heq⟩)
  -- `succ`'s iterates never move the first (dense, `ℚ`) coordinate away from `0`.
  have hfst : ∀ m : ℕ, (ofLex ((Order.succ)^[m] (toLex ((0 : ℚ), (0 : ℤ))))).1 = 0 := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [Function.iterate_succ_apply']
      show (ofLex (lexSucc ((Order.succ)^[m] (toLex ((0 : ℚ), (0 : ℤ)))))).1 = 0
      simp only [lexSucc, ofLex_toLex]
      exact ih
  have := congrArg (fun x => (ofLex x).1) hn
  rw [hfst n] at this
  simp only [ofLex_toLex] at this
  norm_num at this

/-- The `PredOrder` mirror. -/
example : ¬ IsPredArchimedean (ℚ ×ₗ ℤ) := by
  intro h
  obtain ⟨n, hn⟩ := h.exists_pred_iterate_of_le
    (a := (toLex ((0 : ℚ), (0 : ℤ)))) (b := toLex ((1 : ℚ), (0 : ℤ)))
    (by rw [Prod.Lex.le_iff']; exact ⟨by norm_num, fun heq => by norm_num at heq⟩)
  -- `pred`'s iterates never move the first (dense, `ℚ`) coordinate away from `1`.
  have hfst : ∀ m : ℕ, (ofLex ((Order.pred)^[m] (toLex ((1 : ℚ), (0 : ℤ))))).1 = 1 := by
    intro m
    induction m with
    | zero => simp
    | succ m ih =>
      rw [Function.iterate_succ_apply']
      show (ofLex (lexPred ((Order.pred)^[m] (toLex ((1 : ℚ), (0 : ℤ)))))).1 = 1
      simp only [lexPred, ofLex_toLex]
      exact ih
  have := congrArg (fun x => (ofLex x).1) hn
  rw [hfst n] at this
  simp only [ofLex_toLex] at this
  norm_num at this

end FormalSystem.Semantics
