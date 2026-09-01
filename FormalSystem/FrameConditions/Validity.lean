/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Validity

/-!
# Validity bridges between `valid` and the fibre

## What this module still holds

Two bridges, and nothing else: `valid_of_forall_valid_over` and `valid_over_of_valid`, which
relate `Semantics.valid` to `TaskFrame.ValidOn` quantified over a fibre `FrameOver D`. They are
statements about the fibration, not about any frame class, which is why they survive the retirement
recorded below.

## What was retired, and why

This module used to carry a second, parallel family of frame-class validity predicates —
`ValidLinear`, `ValidDenseFc`, `ValidDiscreteFc`, `ValidOnInt` — each stated over the marker
typeclasses of `FrameConditions/FrameClass.lean`, together with eight bridge lemmas relating them
to `Semantics/Validity.lean`'s predicates. All twelve declarations are gone. Two independent
reasons, either of which is sufficient:

1. **Zero live consumers.** Each of the four predicates occurred in exactly two places: its own
   declaration here, and prose in the `FormalSystem/FrameConditions.lean` aggregator's docstring.
   `FrameConditions/Soundness.lean` — the only other importer of this module — referenced none of
   them. The eight bridge lemmas were likewise unreferenced outside this file.

2. **The marker-typeclass binder lists did not match the predicates they claimed to mirror**, and
   the mismatches ran in the unsound direction. `DiscreteTemporalFrame` omits `IsPredArchimedean`,
   which `Semantics.ValidDiscrete` binds, so `ValidDiscreteFc` silently ranged over a *wider* class
   than its stated counterpart; `DenseTemporalFrame` conversely adds `NoMaxOrder`/`NoMinOrder`,
   narrowing it. A validity predicate whose frame constraint is an inlined binder list maintained by
   hand, rather than derived from a frame-class tag, is exactly the defect the
   `FrameClass.Sat`/`ValidIn` layer in `Semantics/FrameClassValidity.lean` and
   `Semantics/Validity.lean` exists to remove. Re-deriving these four names as abbreviations over
   that layer would have preserved the names at the cost of preserving the two silent
   class mismatches with them.

The replacements are `Semantics.ValidIn` (indexed by `ProofSystem.FrameClass`, with its frame
constraint read off the tag by `FrameClass.Sat`) and, for the `ℤ` fibre, `Semantics.ValidInt`
(`Semantics/IntTransfer.lean`), of which the deleted `ValidOnInt` was a definitional duplicate.

## References

- `FormalSystem.Semantics.Validity` — `valid`, `TaskFrame.ValidOn`, and the `ValidIn` layer
- `FormalSystem.Semantics.FrameClassValidity` — the `FrameClass → TaskFrame → Prop` interpretation
- `FormalSystem.Semantics.IntTransfer` — `ValidInt`, the surviving `ℤ`-fibre predicate
-/

namespace FormalSystem.FrameConditions

open FormalSystem.Syntax
open FormalSystem.Semantics

/--
Validity over every fibre implies universal validity: if every frame over every temporal order
validates `φ`, then `valid φ`.

This is immediate since `valid` quantifies over all frames, and a frame is a temporal order paired
with a fibre element.
-/
theorem valid_of_forall_valid_over {φ : Formula}
    (h : ∀ (D : TemporalOrder) (F : FrameOver D), F.toTaskFrame.ValidOn φ) :
    valid φ := by
  intro F M τ hτ t
  exact h F.Duration F.toFibre M ⟨τ, hτ⟩ t

/--
Universal validity implies validity over any specific fibre.
-/
theorem valid_over_of_valid {D : TemporalOrder} {φ : Formula} (h : valid φ)
    (F : FrameOver D) : F.toTaskFrame.ValidOn φ := by
  intro M τ t
  exact h F M τ.val τ.property t

end FormalSystem.FrameConditions
