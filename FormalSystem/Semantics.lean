/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TemporalOrder
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.FrameProperty
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
import FormalSystem.Semantics.BLTruth
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Ultraproduct.Carrier
import FormalSystem.Semantics.Ultraproduct.IndexFilter
import FormalSystem.Semantics.Ultraproduct.ShiftSetProduct
import FormalSystem.Semantics.Ultraproduct.Los
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.BLValidity
import FormalSystem.Semantics.DurationClassification
import FormalSystem.Semantics.IntTransfer

/-!
# FormalSystem.Semantics - Task Frame Semantics

Aggregates all semantic components for bimodal logic TM (Tense and Modality). Provides
task frame semantics with world histories, truth evaluation, and validity definitions
polymorphic over temporal types.

## Submodules

- `TemporalOrder`: `def:temporal-order` reified — "a nontrivial totally ordered abelian
  group" as a structure rather than an unnamed four-binder list, with `CoeSort` to its
  carrier and the four algebra projections re-exported as instances; the object a frame's
  duration component *is*, and the object the frame fibration is indexed by
- `TaskFrame`: the total space of the frame fibration — a `Duration : TemporalOrder` paired
  with a `FrameOver Duration`, so `def:frame`'s `⟨W, 𝔇, ⇒⟩` unfolds exactly as the paper writes
  it. `FrameOver D` is the fibre over a fixed temporal order and the sole declaration site of
  the six frame axioms; `TaskFrame`'s flat surface (`F.WorldState`, `F.TaskRel`, `F.spherical`)
  is preserved by delegating accessors
- `FrameProperty`: `def:frame-properties` as predicates on a *frame* — `TaskFrame.IsDense`,
  `IsDiscrete`, `IsComplete`, plus the two narrowings the tree's soundness targets actually need
  (`IsSuccArchDiscrete`, `def:TMplus-f`'s Hölder narrowing to ℤ-time; `IsDedekind`,
  dense-and-complete). Possible as ordinary predicates because `TaskFrame` carries `Duration` as a
  field rather than as an index. Records the `Dedekind`-not-`Complete` naming deviation at its
  definition site
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
`lem:fibers` above is a **RETIRED paper anchor**: the paper removed `\label{lem:fibers}` in a
2026-08 editing wave and absorbed its content into `lem:admissible`'s proof. The citation resolves
against `specs/paper-definitions-of-record.md`'s DANGLING entry, not a live `\label`. See
`Semantics/Extension/Admissible.lean`'s header for the full note.

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
- `BLTruth`: the same recursion for the tense-primitive base language — `BLTruthAt`, defined
  natively on `BLFormula`'s six constructors per `def:BL-semantics` (H and G quantify over
  strictly past/future times directly, not via `untl`/`snce`), plus the `BLTruth.*` clause and
  derived-operator characterization lemmas
- `Validity`: Semantic validity `⊨ φ` and consequence `Γ ⊨ φ` quantifying over all temporal types
- `BLValidity`: the base-language mirrors — `BLValid`, `BLSemanticConsequence`, `BLValidDense`,
  `BLValidDiscrete` and `BLValidDedekindDense`, binder for binder against `BLTruthAt`; there is
  deliberately no density-free `BLValidDedekind`, which would be refutable
- `DurationClassification`: Hölder classification of Dedekind-complete duration groups --
  completeness implies Archimedean, and the discrete-or-dense dichotomy pinning the discrete
  branch to `ℤ`
- `Ultraproduct.Carrier`: the dependent ultraproduct carrier -- `UD φ D`, the quotient of the Pi
  group `(∀ i, D i)` by its eventually-zero `AddSubgroup`, carrying the four instances a
  `TemporalOrder` demands plus `DenselyOrdered` on the Dense branch; `UOmega φ Ω`, the same
  construction on the history-carrier family; and the lifted shift action `shU` with its
  `sh_zero`/`sh_add` laws. Mathlib's `Filter.Germ` is stated for a fixed `β` and the dependent
  `Filter.Product` carries only `coeTC` and `Inhabited`, so neither applies; this quotient is
  built by hand
- `Ultraproduct.IndexFilter`: the ultrafilter on the index type -- `Idx Γ`, the finite sublists
  of `Γ`; `tailFilter`, the up-set filter built directly from its three fields; `idxUF`, its
  `Ultrafilter.of`; and `eventually_mem`, the property that every `ψ ∈ Γ` is eventually in the
  index list. `Filter.atTop` is deliberately not used: `atTop_neBot` would demand a registered
  `Preorder` instance on a `List` subtype plus `IsDirectedOrder`, a global instance-graph
  commitment for a single use
- `Ultraproduct.ShiftSetProduct`: the ultraproduct shift set -- `UT φ T`, the ultraproduct
  temporal order (carrying `@[reducible]`, which is load-bearing for `rw` motive typing);
  `uSep`, the `sep` field of `ShiftSet` discharged on the ultraproduct by contraposition plus a
  globally chosen section; and `uShiftSet φ S`, which discharges **all seven** `ShiftSet` fields
  from `S : ∀ i, ShiftSet (T i)` alone, with no hypotheses -- contrast the exploratory
  `shiftSetOnUD`, which takes `carrier_nonempty`, `sep` and `A` as hypotheses
- `Ultraproduct.Los`: Łoś's theorem for the ultraproduct shift set -- `los`, the fundamental
  theorem at `ShiftTruth` by induction on `Formula` (the `box`, `untl` and `snce` cases each
  extract a global section with `exists_section`; only `atom`, `bot` and `imp` are mechanical),
  and `los_truthAt`, the same statement at `TruthAt` obtained by conjugating `los` with
  `ShiftSet.forward_repr` on both sides. Łoś is deliberately not attacked at `TruthAt` directly:
  `ShiftTruth`'s `box` clause quantifies over the carrier the ultraproduct quotients, while
  `TruthAt`'s quantifies over total world histories, and `forward_repr` already reconciles the two
- `IntTransfer`: carrier normalization for the discrete branch -- a generic transport of
  frames, `TaskModel`, `WorldHistory`, and `TruthAt` along any ordered-group isomorphism
  `e : D ≃+o E` (via the `HEq`-free `Aligned` relation rather than a history `Equiv`), composed
  with `DurationClassification`'s `intIso` to give `validDiscrete_iff_validInt`: quantifying over
  every discrete duration carrier is the same as quantifying over `ℤ` alone

## Semantic Structure

The semantics follows the JPL paper "The Perpetuity Calculus of Agency":

| Component | Paper Definition | Implementation |
|-----------|------------------|----------------|
| Task Frame | `F = (W, G, ·)` | `TaskFrame` = `Σ D : TemporalOrder, FrameOver D` |
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
variable {F : FrameOver intOrder} (M : TaskModel F) (τ : WorldHistory F)
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
