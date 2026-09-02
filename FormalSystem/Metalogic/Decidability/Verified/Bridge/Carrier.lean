/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.Embed
import FormalSystem.Semantics.Validity
import Mathlib.Algebra.Order.Archimedean.Real.Basic

/-!
# The carrier class — the one place the four frame classes diverge

The semantic bridge (Phases 6 and 7) is proved **once**, against an abstract carrier, and
instantiated four times. `TemporalCarrier fc D` is what "abstract carrier" means: everything the
bridge needs of `D` at frame class `fc`, and nothing else.

Two fields, matching the two things the bridge actually does with `D`:

* `embed_finite` — the branch's finite time order has to be *placed* in `D`
  (`Bridge/Embed.lean`);
* `frame_condition` — the countermodel has to refute the class's own validity predicate, so `D`
  has to satisfy that predicate's extra binders.

Confining the divergence to four instance declarations is the "base development plus modular
extensions" shape: adding a fifth frame class is a new `FrameConditionFor` arm plus one instance,
not a fifth copy of the truth lemma.

## Why `FrameConditionFor` is `Type`-valued and not `Prop`-valued

The obvious design — `frame_condition : Prop` — does not work, and the reason is `Discrete`.
`ValidDiscrete`'s binder list (`Semantics/Validity.lean`) contains `[SuccOrder D]` and
`[PredOrder D]`, and `SuccOrder`/`PredOrder` are **data** (`SuccOrder : (α : Type u) → [Preorder α]
→ Type u`, carrying the `succ` function), not propositions. A `Prop`-valued field could at best
carry `Nonempty (SuccOrder D)`, and every downstream use would then have to `Classical.choice`
its way back to an instance — noncomputably, and with no guarantee that two uses pick the same
successor function.

So `FrameConditionFor` returns a `Type`, `PLift`ing the genuinely propositional binders
(`DenselyOrdered`, the archimedean conditions, the least-upper-bound property) and carrying the
`Discrete` data directly. `DiscreteStructure` is a structure rather than a nested product because
`IsSuccArchimedean` is *indexed by* the `SuccOrder` instance, so the four components are
dependent.

## Correspondence with `Semantics/Validity.lean`

Each arm reproduces exactly the extra binders its validity predicate adds to `valid`:

| `fc` | predicate | extra binders reproduced |
|---|---|---|
| `.Base` | `valid` | none |
| `.Dense` | `ValidDense` | `[DenselyOrdered D]` |
| `.Discrete` | `ValidDiscrete` | `[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]` |
| `.Dedekind` | `ValidDedekindDense` | `[DenselyOrdered D]` and the explicit lub `Prop` binder |

The `AddCommGroup` / `LinearOrder` / `IsOrderedAddMonoid` / `Nontrivial` binders are shared by all
four predicates, so they sit on the class head rather than in `FrameConditionFor`.

`.Dedekind` targets **`ValidDedekindDense`, not `ValidComplete`** — this matters and is not a
simplification opportunity. `FrameClass.Dedekind` sits above `FrameClass.Dense`, so `density` and
`dense_indicator` are admissible in a `.Dedekind` derivation, and both are false on `ℤ` — which
is Dedekind-complete. Dropping the density binder here would make the matching soundness
direction refutable. The full argument is in `ValidComplete`'s docstring in `Validity.lean`.

## The four carriers

`ℚ` twice (`.Base`, `.Dense`), `ℤ` once (`.Discrete`), `ℝ` once (`.Dedekind`). `ℚ` serves `.Base`
because the base predicate binds nothing beyond the shared binders, so the cheapest carrier that
also serves `.Dense` serves both; `ℝ` is needed for `.Dedekind` because that is where the
least-upper-bound property lives; `ℤ` is forced for `.Discrete` because `ValidDiscrete`'s
successor/predecessor binders are exactly what a dense carrier lacks.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Metalogic.Decidability
open FormalSystem.ProofSystem

/-! ## The per-class frame condition -/

/--
The least-upper-bound property, in the exact shape `ValidComplete`/`ValidDedekindDense` bind it —
an explicit `Prop` binder rather than a `ConditionallyCompleteLinearOrder` instance swap. Stated
here in that shape deliberately, so a `.Dedekind` carrier's `frame_condition` can be handed to
those predicates verbatim.
-/
def HasLUBs (D : Type) [LinearOrder D] : Prop :=
  ∀ s : Set D, s.Nonempty → BddAbove s → ∃ x, IsLUB s x

/--
The discreteness data: `ValidDiscrete`'s four extra binders, packaged.

A structure rather than a product because the archimedean conditions are indexed by the
successor/predecessor instances.
-/
structure DiscreteStructure (D : Type) [LinearOrder D] : Type where
  /-- The successor operation. -/
  succOrder : SuccOrder D
  /-- The predecessor operation. -/
  predOrder : PredOrder D
  /-- Every `≤`-pair is reachable by finitely many successor steps. -/
  succArch : @IsSuccArchimedean D _ succOrder
  /-- Every `≤`-pair is reachable by finitely many predecessor steps. -/
  predArch : @IsPredArchimedean D _ predOrder

/--
What each frame class demands of a carrier, beyond the binders shared by every validity
predicate. See the module docstring for the arm-by-arm correspondence with `Validity.lean`.
-/
def FrameConditionFor (fc : FrameClass) (D : Type) [LinearOrder D] : Type :=
  match fc with
  | FrameClass.Base => PUnit
  | FrameClass.Dense => PLift (DenselyOrdered D)
  | FrameClass.Discrete => DiscreteStructure D
  | FrameClass.Dedekind => PLift (DenselyOrdered D) × PLift (HasLUBs D)

/-! ## The carrier class -/

/--
What the semantic bridge needs of a carrier `D` at frame class `fc`.

`embed_finite` is quantified over *every* finite linear order rather than over `Fin n`, on
purpose: the branch order (`Bridge/BranchOrder.lean`) is a **custom** `LinearOrder` on `Fin n`,
not the standard one, so a `Fin n`-specialised field would not accept it.
-/
class TemporalCarrier (fc : FrameClass) (D : Type)
    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] where
  /-- Any finite linear order embeds monotonically into the carrier. -/
  embed_finite : ∀ (T : Type) [LinearOrder T] [Finite T], Nonempty (T ↪o D)
  /-- The class-specific frame condition, in the shape `Validity.lean` demands. -/
  frame_condition : FrameConditionFor fc D

/-! ## The four instances -/

/-- `.Base` needs nothing beyond the shared binders; `ℚ` is the cheapest carrier that has them. -/
instance : TemporalCarrier FrameClass.Base ℚ where
  embed_finite T := embed_finite_to_dense T ℚ
  frame_condition := PUnit.unit

/-- `.Dense` adds `DenselyOrdered`, which `ℚ` has. -/
instance : TemporalCarrier FrameClass.Dense ℚ where
  embed_finite T := embed_finite_to_dense T ℚ
  frame_condition := PLift.up inferInstance

/--
`.Base` is also carried by `ℤ`, and this instance is what makes the `ℤ` milestone available to
`valid` and not only to `ValidDiscrete`.

`valid` (`Semantics/Validity.lean`) quantifies over *every* carrier, so **one** carrier refutes
it — and `ℤ` is the easy one, because `finOrderEmbInt` (`Bridge/Embed.lean`) is the `Nat`-cast
and therefore places `n` branch times *contiguously* at `0, …, n-1`. A contiguous `ℤ` placement
has no integers strictly between consecutive placed points, so its interior gap regions are
**empty** and only the two rays carry a region state. `ℚ` and `ℝ` keep the genuinely dense
interior gaps; these are different problems, and treating all four `Decidable` instances as one
milestone is on this plan's do-not-re-attempt register.

Noncomputable for the same reason the `.Discrete ℤ` instance below is: `embed_finite_to_int`
routes through `Fintype.ofFinite`.
-/
noncomputable instance : TemporalCarrier FrameClass.Base ℤ where
  embed_finite T := embed_finite_to_int T
  frame_condition := PUnit.unit

/--
`.Discrete` is carried by `ℤ`, and this is the instance that cannot reuse the dense embedding:
`ℤ` is not densely ordered, so `embed_finite` here comes from the hand-rolled `Fin n ↪o ℤ`
(`Bridge/Embed.lean`). The four discreteness components are Mathlib instances
(`Mathlib.Data.Int.SuccPred`).
-/
instance : TemporalCarrier FrameClass.Discrete ℤ where
  embed_finite T := embed_finite_to_int T
  frame_condition :=
    { succOrder := inferInstance
      predOrder := inferInstance
      succArch := inferInstance
      predArch := inferInstance }

/--
`.Dedekind` is carried by `ℝ`: dense **and** least-upper-bound complete. The lub component is
`isLUB_csSup` at the conditionally complete lattice `ℝ` (`Real.isLUB_sSup` does not exist — see
`Embed.lean`'s verification note).
-/
instance : TemporalCarrier FrameClass.Dedekind ℝ where
  embed_finite T := embed_finite_to_dense T ℝ
  frame_condition :=
    ⟨PLift.up inferInstance, PLift.up (fun _s hne hbdd => ⟨sSup _s, isLUB_csSup hne hbdd⟩)⟩

/-! ## Placing a branch's times in a carrier

The one lemma Phases 6 and 7 consume: a saturated branch whose order passes the gate has its
times placed order-faithfully in whichever carrier the frame class provides.
-/

/--
A saturated branch's times embed monotonically into any carrier for the frame class, with respect
to the branch order packaged by `Bridge/BranchOrder.lean`.

This is the composition of the two halves of Phase 5 — the order (5.1) and the embedding (5.2) —
and it is the interface Phase 6's interpolation starts from.
-/
theorem exists_monotone_placement (fc : FrameClass) (D : Type)
    [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    [TemporalCarrier fc D]
    {b : Branch} {ord : TimeOrdering} (h : branchOrderValid b ord = true) :
    ∃ f : BranchTime b → D, Function.Injective f ∧
      ∀ i j, (BranchOrder b ord h).le i j ↔ f i ≤ f j := by
  letI := BranchOrder b ord h
  obtain ⟨e⟩ := TemporalCarrier.embed_finite (fc := fc) (D := D) (BranchTime b)
  exact ⟨e, e.injective, fun i j => e.map_rel_iff.symm⟩

/-! ## Instance sanity checks

The four instances are exercised by name, so an instance that stops resolving fails the build
here rather than in Phase 7.
-/

section Checks

example : TemporalCarrier FrameClass.Base ℚ := inferInstance
noncomputable example : TemporalCarrier FrameClass.Base ℤ := inferInstance
example : TemporalCarrier FrameClass.Dense ℚ := inferInstance
noncomputable example : TemporalCarrier FrameClass.Discrete ℤ := inferInstance
example : TemporalCarrier FrameClass.Dedekind ℝ := inferInstance

/-- The `.Dedekind` frame condition really does deliver the lub binder `ValidDedekindDense` wants. -/
example : HasLUBs ℝ :=
  (TemporalCarrier.frame_condition (fc := FrameClass.Dedekind) (D := ℝ)).2.down

/-- …and the density binder alongside it. -/
example : DenselyOrdered ℝ :=
  (TemporalCarrier.frame_condition (fc := FrameClass.Dedekind) (D := ℝ)).1.down

/-- The `.Discrete` frame condition delivers a successor operation on `ℤ`. -/
noncomputable example : SuccOrder ℤ :=
  (TemporalCarrier.frame_condition (fc := FrameClass.Discrete) (D := ℤ)).succOrder

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
