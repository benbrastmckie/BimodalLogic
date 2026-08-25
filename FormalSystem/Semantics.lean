/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Semantics.PartialHistoryOrder
import FormalSystem.Semantics.FrameAxioms
import FormalSystem.Semantics.Extension.Constraint
import FormalSystem.Semantics.Extension.Admissible
import FormalSystem.Semantics.Extension.Step
import FormalSystem.Semantics.Extension.Extension
import FormalSystem.Semantics.WorldHistory
import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.DurationClassification
import FormalSystem.Semantics.IntTransfer

/-!
# FormalSystem.Semantics - Task Frame Semantics

Aggregates all semantic components for bimodal logic TM (Tense and Modality). Provides
task frame semantics with world histories, truth evaluation, and validity definitions
polymorphic over temporal types.

## Submodules

- `TaskFrame`: Task frame structure `F = (W, T, ·)` with world states, temporal type,
  and task relation satisfying nullity and compositionality constraints
- `IntNormalForm`: the ℤ-frame normal form — over `D = ℤ` a task frame is determined by its
  one-step relation `step w u := TaskRel w 1 u`, with `iter`/`iter_add` as the arithmetic core and
  `taskRel_eq_iter` as the decomposition theorem; also records the binder-fit finding for the two
  Mathlib succ-Archimedean-to-ℤ transfer routes
- `PartialHistory`: The paper's partial-history layer (`def:world-history`) — task-respecting
  state assignments on a *nonempty* time set, with no convexity requirement; carries the
  totality predicate `IsTotal` and the extension relation `Extends`
- `FrameAxioms`: *Spherical*, *Seriality*, and the interpolation half of *Compositionality* as
  hypothesis-form `Prop`s over a bare task relation (`def:frame`), the derived `lem:nullity`,
  and `def:constraints` — the constraints a partial history imposes on a new duration
- `Extension.Constraint`: `lem:constraint` — the constraints imposed on a new duration form a
  directed family of nonempty sets, consuming *Seriality* and *Compositionality* in both of its
  directions
- `Extension.Admissible`: `lem:fibers` and `lem:admissible` — membership in every constraint is
  the fiber condition at every domain time, and that is exactly what makes the one-point extension
  `τ ∪ {⟨z, u⟩}` (`PartialHistory.adjoin`) a partial history; consumes `lem:nullity` via
  *Seriality* plus *Limit*
- `Extension.Step`: `lem:step` — every partial history extends by one arbitrary duration; the
  join of `lem:constraint`, *Spherical*, and `lem:admissible`, and **the sole application site of
  the *Spherical* axiom** in the development
- `Extension.Extension`: `thm:extension` — every partial history is extended by some total world
  history, proved from Zorn over the extension order plus `lem:step` and nothing else — and
  `cor:occurrence` in **hypothesis form**: every world state occurs at any prescribed time in some
  total world history, by extending the one-point partial history `{⟨x, w⟩}`. The frame-intrinsic
  form of `cor:occurrence` is deliberately not provided; it is gated on the frame-axiom-field
  refactor described in `Extension.Step`
- `WorldHistory`: World histories `τ: X → W` as functions from convex time domains to
  world states, respecting the task relation
- `TaskModel`: Task models extending frames with valuation functions `V: W × String → Prop`
- `Truth`: Recursive truth evaluation `M,τ,t ⊨ φ` for formulas at model-history-time triples
- `Validity`: Semantic validity `⊨ φ` and consequence `Γ ⊨ φ` quantifying over all temporal types
- `DurationClassification`: Hölder classification of Dedekind-complete duration groups --
  completeness implies Archimedean, and the discrete-or-dense dichotomy pinning the discrete
  branch to `ℤ`
- `IntTransfer`: carrier normalization for the discrete branch -- a generic transport of
  `TaskFrame`, `TaskModel`, `WorldHistory`, and `TruthAt` along any ordered-group isomorphism
  `e : D ≃+o E` (via the `HEq`-free `Aligned` relation rather than a history `Equiv`), composed
  with `DurationClassification`'s `intIso` to give `validDiscrete_iff_validInt`: quantifying over
  every discrete duration carrier is the same as quantifying over `ℤ` alone

## Semantic Structure

The semantics follows the JPL paper "The Perpetuity Calculus of Agency":

| Component | Paper Definition | Implementation |
|-----------|------------------|----------------|
| Task Frame | `F = (W, G, ·)` | `TaskFrame T` with `TaskRel` |
| Nullity | `w ∈ w · 0` | `nullity : ∀ w, TaskRel w 0 w` |
| Compositionality | `u ∈ w·d, v ∈ u·e ⟹ v ∈ w·(d+e)` | `compositionality` constraint |
| World History | `τ: X → W` convex | `WorldHistory F` with `convex` proof |
| Truth | `M,τ,x ⊨ φ` | `TruthAt M τ t ht φ` |
| Validity | True in all models | `valid φ` (polymorphic over `T`) |

## Temporal Polymorphism

The semantics is polymorphic over temporal type `T : Type*` with
`LinearOrderedAddCommGroup T`:

- `Int`: Discrete integer time (standard temporal logic)
- `Rat`: Dense rational time (fine-grained reasoning)
- `Real`: Continuous real time (physical systems)
- Custom bounded or modular time structures

## Truth Clauses

| Formula | Truth Condition |
|---------|-----------------|
| `atom p` | `M.valuation (τ.states t ht) p` |
| `⊥` | `False` |
| `φ → ψ` | `TruthAt ... φ → TruthAt ... ψ` |
| `□φ` | `∀ σ, σ.domain t → TruthAt M σ t hs φ` |
| `Hφ` | `∀ s < t, s ∈ τ.domain → TruthAt M τ s hs φ` |
| `Gφ` | `∀ s > t, s ∈ τ.domain → TruthAt M τ s hs φ` |

## Usage

```lean
import FormalSystem.Semantics

open FormalSystem.Semantics
open FormalSystem.Syntax

-- Validity notation
#check (⊨ Formula.atomS "p" : Prop)  -- Not valid

-- Semantic consequence
#check ([Formula.atomS "p"] ⊨ Formula.atomS "p" : Prop)  -- Valid

-- Work with specific temporal type
variable {F : TaskFrame Int} (M : TaskModel F) (τ : WorldHistory F)
variable (t : Int) (ht : τ.domain t)

#check TruthAt M τ t ht (Formula.box (Formula.atomS "p"))
```

## References

* [TaskFrame.lean](Semantics/TaskFrame.lean) - Task frame structure
* [WorldHistory.lean](Semantics/WorldHistory.lean) - World history definition
* [TaskModel.lean](Semantics/TaskModel.lean) - Task model with valuation
* [Truth.lean](Semantics/Truth.lean) - Truth evaluation
* [Validity.lean](Semantics/Validity.lean) - Validity and semantic consequence
-/
