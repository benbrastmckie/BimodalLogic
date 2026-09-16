/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TemporalOrder
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.Frames
import FormalSystem.Semantics.FrameProperty
import FormalSystem.Semantics.FrameClassValidity
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.PartialHistory
import FormalSystem.Semantics.PartialHistoryOrder
import FormalSystem.Semantics.FrameAxioms
import FormalSystem.Semantics.Extension
import FormalSystem.Semantics.TaskModel
import FormalSystem.Semantics.TruthClauses
import FormalSystem.Semantics.ValidityLayer
import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.TruthTransport
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Semantics.Ultraproduct
import FormalSystem.Semantics.Validity
import FormalSystem.Semantics.DeterministicBridge
import FormalSystem.Semantics.StateLocalTransfer
import FormalSystem.Semantics.DurationClassification
import FormalSystem.Semantics.LexCarrier
import FormalSystem.Semantics.IntTransfer
import FormalSystem.Semantics.Correspondence

/-!
# FormalSystem.Semantics - Task Frame Semantics

Aggregates all semantic components for bimodal logic TM (Tense and Modality). Provides
task frame semantics with world histories, truth evaluation, and validity definitions
polymorphic over temporal types.

## Submodules

The L⁻/L⁺/L⋆ language-family modules (the `MinusLanguage.*`, `PlusLanguage.*` and
`StarLanguage.*` entries below) live in the subdirectories `Semantics/MinusLanguage/`,
`Semantics/PlusLanguage/` and `Semantics/StarLanguage/`. This file does **not** import them
directly: they are aggregated by the sibling aggregators `Semantics/MinusLanguage.lean`,
`Semantics/PlusLanguage.lean` and `Semantics/StarLanguage.lean`, which the root aggregator
`FormalSystem/FormalSystem.lean` imports, mirroring `Syntax/`. This file still reaches much of
L⁺ and L⋆ transitively, through `DeterministicBridge` and `StateLocalTransfer`. The
subdirectories `Extension/`, `Ultraproduct/`, `Correspondence/` and `Frames/` are imported
through their sibling aggregators `Semantics/Extension.lean` and so on.

- `TemporalOrder`: `def:temporal-order` reified — "a nontrivial totally ordered abelian
  group" as a structure rather than an unnamed four-binder list, with `CoeSort` to its
  carrier and the four algebra projections re-exported as instances; the object a frame's
  duration component *is*, and the object the frame fibration is indexed by
- `TaskFrame`: the total space of the frame fibration — a `Duration : TemporalOrder` paired
  with a `FrameOver Duration`, so `def:frame`'s `⟨W, 𝔇, ⇒⟩` unfolds exactly as the paper writes
  it. `FrameOver D` is the fibre over a fixed temporal order and the sole declaration site of
  the four frame axioms plus the converse convention; `TaskFrame`'s flat surface (`F.WorldState`, `F.TaskRel`, `F.saturation`)
  is preserved by delegating accessors
- `FrameProperty`: `def:frame-properties` as predicates on a *frame* — `TaskFrame.IsDense`,
  `IsDiscrete`, `IsComplete`, plus the two narrowings the tree's soundness targets actually need
  (`IsZTime`, `def:BX-z`'s narrowing to ℤ-time via `prop:archimedean`; `IsRTime`,
  dense-and-complete). Possible as ordinary predicates because `TaskFrame` carries `Duration` as a
  field rather than as an index. Each narrowing records at its definition site why it is named
  for its carrier rather than for the paper's clause
- `FrameClassValidity`: the semantic interpretation of `ProofSystem.FrameClass` —
  `FrameClass.Sat : FrameClass → TaskFrame → Prop` and its antitonicity `Sat.anti`. The **only**
  module under `Semantics/` importing anything from `ProofSystem/`; the seam is confined here
  because `Sat` is the single point at which a proof-side tag acquires a semantic meaning
- `IntNormalForm`: the ℤ-frame normal form — over `D = ℤ` a task frame is determined by its
  one-step relation `step w u := TaskRel w 1 u`, with `iter`/`iter_add` as the arithmetic core and
  `taskRel_eq_iter` as the decomposition theorem; also records the binder-fit finding for the two
  Mathlib succ-Archimedean-to-ℤ transfer routes
- `PartialHistory`: The paper's partial-history layer (`def:world-history`) — task-respecting
  state assignments on a *nonempty* time set; carries the totality predicate `IsTotal`, the
  convexity predicate `IsConvex`, the extension relation `Extends`, time shift, and
  `TaskFrame.HF`, the *world histories* (the paper's possible worlds), i.e. the total ones
- `FrameAxioms`: *Saturation*, *Seriality*, and the interpolation half of *Compositionality* as
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
against `docs/reference/paper-definitions-of-record.md`'s DANGLING entry, not a live `\label`. See
`Semantics/Extension/Admissible.lean`'s header for the full note.

- `Extension.Step`: `lem:step` — every partial history extends by one arbitrary duration; the
  join of `lem:constraint`, *Saturation*, and `lem:admissible`, and **the sole application site of
  the *Saturation* axiom** in the development
- `Extension.Extension`: `thm:extension` — every partial history is extended by some possible
  world, proved from Zorn over the extension order plus `lem:step` and nothing else — and
  `cor:occurrence` in **hypothesis form**: every world state occurs at any prescribed time in some
  possible world, by extending the one-point partial history `{⟨x, w⟩}`. The frame-intrinsic
  form of `cor:occurrence` is deliberately not provided; it is gated on the frame-axiom-field
  refactor described in `Extension.Step`
- `TaskModel`: Task models extending frames with valuation functions `V: W × String → Prop`
- `ValidityLayer`: `PointTruth` — the class abstracting "truth at a point `(M, τ, x)`" — and the
  validity layer written **once** against it: `TaskFrame.GenericValidOn`, `GenericValidOnFrames`,
  `GenericValidIn`, `GenericValid`, both monotonicity lemmas, the eight binder-shape adapters and
  the three countermodel contrapositives. All four object languages instantiate it with a single
  `sat` field and delegate their own theorem bodies to it, L⋆ folding its stored-time vector in as
  the innermost binder. The module docstring carries the extension contract: what a fifth language
  must supply to inherit the layer
- `TruthClauses`: the same idea one level down, for the derived-operator clause lemmas —
  `TruthEnv` (the pointed relation with an inert environment parameter) and one class per
  primitive operator, with the derived operators and their characterization lemmas proved once and
  tiered by which primitives a language has. L⁻ takes the tense-primitive tier, L⁺ and L⋆ the
  stability tier, and L⋆'s environment is its stored-time vector
- `Truth`: Recursive truth evaluation `M,τ,t ⊨ φ` for formulas at model-history-time triples
- `MinusLanguage.MinusTruth`: the same recursion for the tense-primitive base language — `MinusTruthAt`, defined
  natively on `MinusFormula`'s six constructors per `def:BL-semantics` (H and G quantify over
  strictly past/future times directly, not via `untl`/`snce`), plus the `MinusTruth.*` clause and
  derived-operator characterization lemmas
- `MinusLanguage.MinusFrame`: a native L⁻ frame notion *not* bound to `TaskFrame` — `MinusFrame`, `MinusFrame.swap`,
  `MinusFrameTruth` (with `□` read as the universal modality over the point set) and
  `MinusFrameValid`, plus the `MinusFrameTruth.*` characterization family and the order-reversal
  transfer lemma `truth_swap`. Dropping the `Duration : TemporalOrder` group structure is what
  frees the class from the dense-or-discrete dichotomy, which is what makes a countermodel to
  `(Sp)` possible; see `Metalogic/Conservativity/SpCountermodel.lean`
- `Validity`: Semantic validity `⊨ φ` and consequence `Γ ⊨ φ` quantifying over all temporal types
- `MinusLanguage.MinusValidity`: the base-language mirrors — `MinusValid`, `MinusSemanticConsequence`, `MinusValidDense`,
  `MinusValidZTime` and `MinusValidRTime`, binder for binder against `MinusTruthAt`; there is
  deliberately no density-free `MinusValidComplete`, which would be refutable
- `PlusLanguage.PlusTruth`: the truth recursion for the language L⁺ (L plus the stability modal `⊡`,
  `FormalSystem/PlusLanguage/Formula.lean`) — `SameStateAt` (the paper's `⟨τ⟩_x`, line 1108) and
  `PlusTruthAt`, whose seventh clause is the paper's `($\Stability$)` clause (`def:BLstar-semantics`); the
  `PlusTruth.*` clause lemmas, the S5 validities of `⊡`, and `stab_state_only` (`⊡φ` depends on
  the world state alone)
- `PlusLanguage.PlusValidity`: the L⁺ mirrors of `Validity` — `PlusValidOnFrames` (the frame-predicate
  primitive), `PlusValidIn`, `PlusValid` and the per-class abbreviations — plus the truth-transfer
  bridge `plusTruthAt_ofFormula` and `plusValidIn_ofFormula_iff`, the semantic conservativity of
  L⁺ over L at every frame class
- `PlusLanguage.PlusPasting`: the history-pasting lemma (`paste`: two total histories sharing a state at `t`
  paste into a total history, by *Compositionality* and the converse convention alone), the
  purity congruences, and the pasting validities PS/US/FS/GS and their past mirrors — the
  `⊡`/tense interaction principles the S5 axioms of `⊡` miss
- `PlusLanguage.PlusNonValidities`: the five refutations on `natFrame` over `ℤ` (`⊡p → □⊡p`, `G⊡p → ⊡Gp`,
  `⊡GPp → G⊡Pp`, *Determined* `Fp → ⊡Fp` over a non-deterministic frame, `P⊡p → ⊡Pp`), which
  bound the axiom set from above
- `PlusLanguage.PlusDeterminism`: `app:deterministic`'s **positive** half — the singleton bridge
  `states_eq_of_deterministic` and the deterministic collapse `⊡φ ↔ φ`
  (`determined_of_deterministic`, `stab_biconditional_plusValidOn_of_deterministic`), valid on
  every frame satisfying `TaskFrame.Deterministic`, and choice-free
- `PlusLanguage.PlusStateLocal`: the **state-locality** fragment of L⁺ — `PlusFormula.StateLocal`, the
  syntactic predicate cut by structural recursion over all seven constructors (`atom`, `bot`,
  `imp` propositionally; `box` and `stab` for an *arbitrary* argument; `untl`, `snce` excluded),
  and `IsPlusStateLocal`, the semantic property it approximates: two possible worlds carrying the
  same world state at `t` agree about `φ` at `t`. Carries the soundness induction
  `isPlusStateLocal_of_stateLocal`, a non-preservation witness for each excluded constructor, and
  the headline `φ ↔ ⊡φ` (`plusStateLocal_stab_iff`, `plusStateLocal_plusValid_iff_stab`) together
  with its argument-shaped half `stab_of_stateLocal`, which is what discharges the AS arm of TM⁺
  soundness and which strictly generalizes the atom-level `p → ⊡p` this tower used to carry
- `StarLanguage.StarStateLocal`: the **state-locality** fragment of L⋆ — `StarFormula.StateLocal`, the
  syntactic predicate cut by structural recursion (`atom`, `bot`, `imp`, `timeStore` recursively;
  `box` and `stab` for an *arbitrary* argument; `untl`, `snce`, `timeRecall` excluded), and
  `IsStateLocal`, the semantic property it approximates: two possible worlds carrying the same
  world state at `t` agree about `φ` at `t`, under one and the same stored-time vector. Carries
  the soundness induction `isStateLocal_of_stateLocal`, a non-preservation witness for each
  excluded constructor, and the headline `φ ↔ ⊡φ` (`stateLocal_stab_iff`,
  `stateLocal_starValid_iff_stab`) — the companion facing the other way to `stab_state_only`,
  which says `⊡φ` is state-local where this says a state-local `φ` is already `⊡`-stable
- `StateLocalTransfer`: `stateLocal_ofPlus_iff` — the two state-locality fragments agree along
  `ofPlus`, as a **biconditional**, so the L⁺ fragment is exactly the `ofPlus`-preimage of the L⋆
  one. Its own module rather than either fragment's, so that the L⁺ conservativity route does not
  acquire an L⋆ dependency
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
  `TruthAt`'s quantifies over possible worlds, and `forward_repr` already reconciles the two
- `IntTransfer`: carrier normalization for the discrete branch -- a generic transport of
  frames, `TaskModel`, `PartialHistory`, and `TruthAt` along any ordered-group isomorphism
  `e : D ≃+o E` (via the `HEq`-free `Aligned` relation rather than a history `Equiv`), composed
  with `DurationClassification`'s `intIso` to give `validZTime_iff_validInt`: quantifying over
  every discrete duration carrier is the same as quantifying over `ℤ` alone

## Semantic Structure

The semantics follows the JPL paper "The Perpetuity Calculus of Agency":

| Component | Paper Definition | Implementation |
|-----------|------------------|----------------|
| Task Frame | `F = ⟨W, D, ⇒⟩` (`def:frame`) | `TaskFrame` = `Σ D : TemporalOrder, FrameOver D` |
| Compositionality | `w ⇒_(x+y) v` iff `w ⇒_x u` and `u ⇒_y v` for some `u` | `comp` field |
| Seriality | `w ⇒_x u` and `v ⇒_x w` for some `u, v` | `serial` field |
| Limit | `⋂_{x > 0} (w)_x = {w}` | `limit` field |
| Saturation | `⋂ S ≠ ∅` for a `⊇`-directed family of nonempty fibers and segments | `saturation` field |
| Partial History | `τ : X → W`, `X ⊆ D` nonempty (`def:world-history`) | `PartialHistory F` |
| World History | partial history with `X = D` (sec:Construction) | `TaskFrame.HF`; predicate form `PartialHistory.IsTotal` |
| Truth | `M,τ,x ⊨ φ` | `TruthAt M τ t φ` |
| Validity | True in all models, at every total history | `Valid φ` |

The frame carries **four** axioms, the four rows above. *Nullity* (`w ⇒_0 w`) is **derived**,
choice-free, from Seriality at `x = 0` together with Limit. `FrameOver` has no zero-duration
field: `FrameOver.nullity` and the biconditional `FrameOver.nullity_identity`
(`TaskRel w 0 u ↔ w = u`) are theorems proved from the `serial` and `limit` fields, so the Lean
frame class is exactly the paper's.

## Temporal Polymorphism

The semantics is polymorphic over temporal type `T : Type*` with
`LinearOrderedAddCommGroup T`:

- `Int`: Discrete integer time (standard temporal logic)
- `Rat`: Dense rational time (fine-grained reasoning)
- `Real`: Continuous real time (physical systems)
- Custom bounded or modular time structures

## Truth Clauses

`TruthAt` takes four arguments — `TruthAt M τ t φ` — and recurses on the **six** `Formula`
constructors. `H`, `G`, `P` and `F` are derived from `untl`/`snce`, so they have no clause here;
see `Truth.lean`'s `Truth.*_iff` family for their characterizations.

| Formula | Truth Condition |
|---------|-----------------|
| `atom p` | `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p` |
| `⊥` | `False` |
| `φ → ψ` | `TruthAt M τ t φ → TruthAt M τ t ψ` |
| `□φ` | `∀ σ, σ.IsTotal → TruthAt M σ t φ` |
| `U(ψ, φ)` (`untl ψ φ`) | `∃ s > t, TruthAt M τ s φ ∧ ∀ r, t < r → r < s → TruthAt M τ r ψ` |
| `S(ψ, φ)` (`snce ψ φ`) | `∃ s < t, TruthAt M τ s φ ∧ ∀ r, s < r → r < t → TruthAt M τ r ψ` |

## Usage

```lean
import FormalSystem.Semantics

open FormalSystem.Semantics
open FormalSystem.Syntax

-- Validity notation
#check (⊨ Formula.atomS "p" : Prop)  -- Not valid

-- Semantic consequence
#check ([Formula.atomS "p"] ⊨ Formula.atomS "p" : Prop)  -- Valid

-- Truth at a specific frame. `TruthAt` takes four arguments, not five.
variable {F : TaskFrame} (M : TaskModel F) (τ : PartialHistory F) (t : F.Duration)

#check TruthAt M τ t (Formula.box (Formula.atomS "p"))
```

## References

* [TaskFrame.lean](Semantics/TaskFrame.lean) - Task frame structure
* [PartialHistory.lean](Semantics/PartialHistory.lean) - Partial and world histories, and `TaskFrame.HF`
* [TaskModel.lean](Semantics/TaskModel.lean) - Task model with valuation
* [Truth.lean](Semantics/Truth.lean) - Truth evaluation
* [Validity.lean](Semantics/Validity.lean) - Validity and semantic consequence
-/
