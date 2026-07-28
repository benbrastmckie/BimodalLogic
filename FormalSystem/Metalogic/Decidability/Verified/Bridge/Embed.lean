/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.BranchOrder
import Mathlib.Order.CountableDenseLinearOrder
import Mathlib.Data.Fintype.Sort
import Mathlib.Data.Int.SuccPred
import Mathlib.Data.Real.Basic

/-!
# Embedding a finite branch order into a carrier

`Bridge/BranchOrder.lean` turns a saturated branch's times into a finite linear order. The
countermodel lives on a carrier `D` — `ℚ`, `ℤ` or `ℝ` — so the times have to be *placed* in `D`
order-faithfully before Phase 6 can interpolate between consecutive placements. This file proves
the two placement lemmas, one per carrier shape.

## Two lemmas, not one, and no attempted reuse

The dense carriers and `ℤ` are proved by **genuinely different arguments**, and the plan's
instruction not to attempt reuse is load-bearing:

* **Dense carriers (`ℚ`, `ℝ`)** go through `Order.embedding_from_countable_to_dense`
  (`Mathlib.Order.CountableDenseLinearOrder`) — a back-and-forth construction. Its hypotheses are
  `[Countable α]` on the source and `[DenselyOrdered β] [Nontrivial β]` on the target. A finite
  linear order is countable, so the source hypothesis is free.
* **`ℤ`** satisfies neither `DenselyOrdered` nor anything close to it — between `0` and `1` there
  is nothing — so the dense lemma **does not apply**, not even after weakening. The integer case
  is proved from scratch: `Fin n ↪o ℤ` by `Nat`-cast (strictly monotone), then any finite linear
  order transported onto `Fin n` by `monoEquivOfFin`.

The `ℤ` route is elementary, which is the point: nothing is lost by not reusing the hard lemma,
and an attempted reuse would have to invent a density hypothesis `ℤ` does not have.

## Mathlib-name verification (plan constraint 2)

Every Mathlib name below was `#check`ed under this file's own import set, in one batch that also
contained a deliberate **control error** — a name that does not exist. The control reported
`unknown identifier`, which is what makes the successful checks evidence rather than an
assumption that the checking mechanism was live. Names confirmed:
`Order.embedding_from_countable_to_dense` (α and β *explicit*), `monoEquivOfFin`,
`OrderEmbedding.ofStrictMono`, `RelEmbedding.trans`, `OrderIso.toOrderEmbedding`,
`Fintype.ofFinite`, and the `ℤ` `SuccOrder`/`PredOrder`/`IsSuccArchimedean`/`IsPredArchimedean`
instances. Two first guesses were **refuted** by the same pass and corrected here:
`OrderEmbedding.trans` does not exist (`↪o` unfolds to `RelEmbedding`, so the composition is
`RelEmbedding.trans`), and `Real.isLUB_sSup` does not exist (the general
`isLUB_csSup` on a conditionally complete lattice is the lemma, used in `Carrier.lean`).
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

/-! ## Dense carriers -/

/--
Any finite linear order embeds monotonically into any nontrivial dense linear order.

This is `Order.embedding_from_countable_to_dense` with the countability of a finite type
discharged. `ℚ` and `ℝ` are the intended targets; nothing here is specific to either.
-/
theorem embed_finite_to_dense (T : Type) [LinearOrder T] [Finite T]
    (D : Type) [LinearOrder D] [DenselyOrdered D] [Nontrivial D] :
    Nonempty (T ↪o D) :=
  Order.embedding_from_countable_to_dense T D

/-! ## The integer carrier -/

/--
`Fin n ↪o ℤ` by `Nat`-cast.

Hand-rolled, deliberately: `ℤ` is not densely ordered, so `embed_finite_to_dense` does not apply
to it under any weakening of its hypotheses. See the module docstring.
-/
def finOrderEmbInt (n : ℕ) : Fin n ↪o ℤ :=
  OrderEmbedding.ofStrictMono (fun i => (i.val : ℤ)) (by
    intro i j hij
    simp only []
    omega)

/--
Any finite linear order embeds monotonically into `ℤ`.

`monoEquivOfFin` transports the order onto `Fin (card T)` — it is the *increasing* bijection, so
the transport is an order isomorphism — and `finOrderEmbInt` places that in `ℤ`. Noncomputable
only because `Fintype.ofFinite` is; the statement is the intended content.
-/
noncomputable def finiteOrderEmbInt (T : Type) [LinearOrder T] [Finite T] : T ↪o ℤ :=
  letI : Fintype T := Fintype.ofFinite T
  RelEmbedding.trans
    (monoEquivOfFin T (k := Fintype.card T) rfl).symm.toOrderEmbedding
    (finOrderEmbInt (Fintype.card T))

/-- The `Nonempty`-shaped form, matching `embed_finite_to_dense`. -/
theorem embed_finite_to_int (T : Type) [LinearOrder T] [Finite T] : Nonempty (T ↪o ℤ) :=
  ⟨finiteOrderEmbInt T⟩

/-! ## Sanity checks

Enough of each construction is exercised here that a silent Mathlib change in either route
fails the build rather than being absorbed downstream.
-/

section Checks

-- The `ℤ` embedding of `Fin 4` is the identity cast, in order.
/-- info: [0, 1, 2, 3] -/
#guard_msgs in
#eval (List.finRange 4).map (finOrderEmbInt 4)

example : Nonempty (Fin 3 ↪o ℚ) := embed_finite_to_dense (Fin 3) ℚ
example : Nonempty (Fin 3 ↪o ℝ) := embed_finite_to_dense (Fin 3) ℝ
example : Nonempty (Fin 3 ↪o ℤ) := embed_finite_to_int (Fin 3)

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
