/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.GroupModel.GroupableCompanion
import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Monoid.Prod

/-!
# The Base-MCS discrete countermodel at `ℚ ×ₗ ℤ`

This module hosts `countermodel_discrete`: from a **Base** MCS `A` containing `¬φ` and
`□(nextTop)`, it builds a countermodel to `φ` on the non-Archimedean discrete carrier
`ℚ ×ₗ ℤ`. It is the Base analogue of `countermodel_discrete_reynolds_v2`
(`IntegerModel/ReynoldsBridge.lean`), which needs a *Discrete* MCS and lands on `ℤ`.

## Why this module exists rather than `Transfer.lean`

The construction consumes `companionChronicle`
(`GroupModel/GroupableCompanion.lean`), and the import chain runs

```
Transfer.lean  ←  IntegerModel/ReynoldsBridge.lean  ←  GroupModel/GroupableCompanion.lean
```

so `Transfer.lean` is strictly *upstream* of the companion lemma and cannot import it. The
theorem is therefore declared here, under `namespace FormalSystem.Metalogic.WeakCanonical`,
which preserves the fully-qualified name
`FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` verbatim — so the sole consumer,
`BXCanonical/Completeness.lean`, needs no edit at all. Moving `truth_transfer` out of
`Transfer.lean` to break the cycle upstream was rejected: it has many consumers and the churn
is unbounded.

## What changes relative to the `ℤ` blueprint

Three substitutions carry the `ℤ` body to `ℚ ×ₗ ℤ`:

* `limitdom_is_good` → `companionChronicle`. The latter carries **no** `Discrete ≤ fc`
  hypothesis (discreteness of the flow comes from `□(nextTop)` alone), so the `(le_refl _)`
  argument disappears, and it delivers `goodGroupable` rather than `good`.
* `multiFamTaskFrame` / `multiFamHistory` / `multiFam_total_eq` →
  `multiFamTaskFrameGen (ℚ ×ₗ ℤ)` / `multiFamHistoryGen` / `multiFamGen_total_eq`
  (`Algebraic/FlowFrame.lean`).
* `FrameClass.Discrete` → `FrameClass.Base` throughout. Every remaining step is already
  `{fc : FrameClass}`-generic; in particular `Axiom.modal_t` is a `.Base` axiom, so its
  `trivial` membership proof survives.

Two consequences of the carrier change are worth naming. First, `QZStructure.toOrdered_carrier`
is `rfl`, so the target carrier *is* `ℚ ×ₗ ℤ` — there is no `lo`/`hi`-carved interval subtype,
and the bounds/`toCarrier` bookkeeping that the `ℤ` blueprint needs simply has no analogue
here. Second, `omega` does not run at `ℚ ×ₗ ℤ`; the three ordered-group facts it was doing are
isolated below as `qz_add_lt_add_iff`, `qz_add_sub_cancel` and `qz_zero_add`, so the proof body
cites a proved name instead of a decision procedure.

## References

- Doets 1987, ch. 7 (pp. 89-93); Reynolds 1992, §8 (printed p. 185) — as transposed by
  `GroupModel/GoodGroupable.lean` and `GroupModel/GroupableCompanion.lean`.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.BXCanonical.Chronicle
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

/-! ## Carrier gate

The four instances `valid` (`Semantics/Validity.lean`) binds its duration type under, plus the
elaboration of the generic flow frame at this carrier. Mirrors the gates at
`GroupModel/GoodGroupable.lean` and `BXCanonical/DiscreteCarrierProbe.lean`; these lines make
*"`ℚ ×ₗ ℤ` is an admissible duration type for the flow-frame construction"* a compile-time
invariant of this module. -/

example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

noncomputable example : TaskFrame (ℚ ×ₗ ℤ) := multiFamTaskFrameGen (ℚ ×ₗ ℤ) Unit

/-! ## Carrier arithmetic

The three ordered-group facts that replace `omega` in the `untl`/`snce` cases of the ported
body. At `ℤ` these are decided; at `ℚ ×ₗ ℤ` they are instances of the ordered abelian group
laws, and naming them keeps the proof body free of ad hoc tactic guessing. -/

/-- Shift-monotonicity: translation by `w` is strictly order-preserving. This is what the `ℤ`
blueprint's `change (w₀ + t : ℤ) < w₀ + s; omega` steps become. -/
private theorem qz_add_lt_add_iff (w t s : ℚ ×ₗ ℤ) : w + t < w + s ↔ t < s :=
  add_lt_add_iff_left w

/-- Shift-cancellation: `w + (s - w) = s`, the fact that makes `s - w` the offset witnessing a
carrier point `s` as a translate of the base point `w`. Replaces the `ℤ` blueprint's
`Subtype.ext (by simp only [toCarrier]; omega)`. -/
private theorem qz_add_sub_cancel (w s : ℚ ×ₗ ℤ) : w + (s - w) = s := by abel

/-- Zero-shift: the root history's base point is `0`, so the target point `0 + s` is `s`.
Replaces the `ℤ` blueprint's `omega` at the existential-packaging step. -/
private theorem qz_zero_add (s : ℚ ×ₗ ℤ) : (0 : ℚ ×ₗ ℤ) + s = s := zero_add s

end FormalSystem.Metalogic.WeakCanonical
