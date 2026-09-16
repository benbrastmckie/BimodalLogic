/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import Mathlib.Order.SuccPred.Basic
import Mathlib.Order.SuccPred.Archimedean

-- Lower semantic layer: must not reach the proof system (G-15). `FrameClassValidity.lean`
-- is the one documented seam that imports `ProofSystem.Axioms`; nothing below it may.
assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
  FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass

/-!
# Frame Properties — `def:frame-properties` as predicates on frames

`def:frame-properties` states its three clauses of a *task frame*: "A task frame
`F = ⟨W, D, ⇒⟩` is Discrete/Dense/Complete if ...". This module renders each of them as exactly
that — a `TaskFrame → Prop` — which is possible because `TaskFrame` carries its `Duration` as a
field rather than as an index (see `Semantics/TaskFrame.lean`'s module docstring).

## Main Definitions

- `TaskFrame.IsDense` — `def:frame-properties`' Dense clause
- `TaskFrame.IsDiscrete` — `def:frame-properties`' Discrete clause, verbatim
- `TaskFrame.IsZTime` — `def:BX-z`'s narrowing of the discrete class to
  `ℤ`-time; strictly stronger than `IsDiscrete`, and the predicate the proof side's
  `FrameClass.ZTime` actually admits axioms for
- `TaskFrame.IsComplete` — `def:frame-properties`' Complete clause
- `TaskFrame.IsRTime` — dense *and* complete: `cor:tm-completeness`'s TM_r target
- `TaskFrame.ForwardDeterministic` — `Deterministic` with the duration binder guarded by
  `0 ≤ d`; strictly weaker, and introduced only to name what `sent:det` defines
- `TaskFrame.Deterministic` — `def:deterministic`: every fibre of the task relation is a
  subsingleton, the frame condition the stability modal `⊡` collapses over

## Why five predicates and not three

Two of `def:frame-properties`' clauses each split in this tree, and in both cases collapsing the
split would silently widen a soundness target:

- **Discrete splits.** `def:frame-properties`' bare Discrete clause is `IsDiscrete`.
  `def:BX-z` narrows the class its axioms are sound over: the discrete task frames over which
  BX_z and TM_z are sound and complete are exactly those over `ℤ`-time, because the axioms `UZ`
  and `Z1` fail over every non-Archimedean discrete order. That narrowed class is `IsZTime`, and
  only the narrowed one is a sound interpretation of the proof side's `FrameClass.ZTime`.
- **Complete splits.** `def:frame-properties`' bare Complete clause is `IsComplete`, which `ℤ`
  satisfies. `IsRTime` adds density, deleting exactly the `ℤ` branch of the Hölder dichotomy
  (`Semantics/DurationClassification.lean`'s `complete_duration_discrete_or_dense`).

Neither pair is bridged by a duplicate definition: each of the five is defined once, and the two
splits are related by the projections `isDense_of_isRTime` / `isComplete_of_isRTime` and by
the implication from `IsZTime` to `IsDiscrete` recorded on the former's docstring.

## The two narrowed classes: `IsZTime` and `IsRTime`

`def:frame-properties`' bare Discrete and Complete clauses are `IsDiscrete` and `IsComplete`, and
each keeps the paper's name. The two *narrowed* classes the proof side's tags denote are named
separately: `IsZTime` for `def:BX-z`'s ℤ-time class and `IsRTime` for the dense-and-complete
`ℝ`-time class. See `TaskFrame.IsZTime` and `TaskFrame.IsRTime`.

## Why `IsDense` is an `abbrev`

`IsDense` is declared `abbrev` (i.e. `@[reducible] def`) rather than `def`, and that is
load-bearing rather than cosmetic. Lean's instance-cache registration whnfs a candidate
hypothesis at *reducible* transparency only, so a single non-reducible `def` anywhere in the
chain `FrameClass.Sat .Dense F ⇝ TaskFrame.IsDense F ⇝ DenselyOrdered F.Duration` stops
`h : Sat .Dense F` from ever reaching the local instance cache, no matter how the hypothesis is
introduced. `FrameClass.Sat` carries `@[reducible]` for the same reason; see its docstring in
`Semantics/FrameClassValidity.lean`. `IsComplete` and `IsRTime` need no such change: they are
consumed by `obtain`/`rcases`, which whnf at *default* transparency.

## Frame properties as instance-resolvable classes: scope of the fix

Making the density chain reducible is the whole of what "frame properties resolve as instances"
buys here, and it is deliberately narrow. The strong form — restating each frame property as a
`class` with an `instance [F.IsRTime] : F.IsDense` bridge — is *impossible* for
`IsZTime`: a `Prop`-valued structure cannot project the `Type`-valued `SuccOrder`
field it must carry (the same reason `Nonempty` has no `.val`). The narrow fix nevertheless
achieves the goal it was proposed for, namely that instance resolution carries the
Dense/RTime inclusion at a `Sat` hypothesis.

One consequence that does **not** follow: the eight `by decide` regression examples elsewhere in
the tree are *not* made redundant by this. `FrameClass.Sat.anti`'s `decide` branch discharges
seven absurd order hypotheses and is still required and still cheap. Do not delete them on the
theory that instance resolution now covers them.

## References

* [TaskFrame.lean](TaskFrame.lean) — the bundled frame whose `Duration` field makes these
  ordinary predicates on a frame
* [DurationClassification.lean](DurationClassification.lean) — the Hölder dichotomy that makes the
  `IsComplete` / `IsRTime` split exactly the `ℤ` / `ℝ` split

## Tags

frame-class · frame-properties · dense · discrete · complete · def:frame-properties
-/

namespace FormalSystem.Semantics

/--
`def:frame-properties`, Dense clause, verbatim: a task frame is **Dense** "if for any `x, y ∈ D`
where `x < y`, there exists `z ∈ D` where `x < z < y`".

That is Mathlib's `DenselyOrdered` on the frame's duration carrier on the nose, so the clause is
recorded by naming that class rather than by restating its body — `DenselyOrdered.dense` is the
recorded sentence.

## Why this class is not named `IsQTime`

Unlike `IsZTime` and `IsRTime`, this is a bare paper clause that is *not* narrowed: it holds of
`ℚ`, `ℝ`, `ℚ ×ₗ ℚ` and many other duration groups, and it must contain the `ℝ`-frames because
`isDense_of_isRTime` backs `FrameClass.Sat.anti` at `Dense ≤ RTime`. Following the module's
convention above (only the narrowed, categorical classes are named for their carrier), it keeps
the paper's name. That its logic coincides with the `ℚ`-time logic is a completeness theorem, not
its definition; the full argument lives on the `FrameClass` docstring in
`ProofSystem/Axioms.lean`.
-/
abbrev TaskFrame.IsDense (F : TaskFrame) : Prop := DenselyOrdered F.Duration

/--
`def:frame-properties`, Discrete clause, verbatim: a task frame is **Discrete** "if for any
`x ∈ D`, whenever there exists `y > x`, there is a least such `y' > x` satisfying `z ≥ y'` for all
`z > x`".

**Form chosen, and why.** The clause's closing conjunct — "a least such `y' > x` satisfying
`z ≥ y'` for all `z > x`" — is precisely `IsLeast {z | x < z} y'`, which unfolds to
`y' ∈ {z | x < z} ∧ ∀ z ∈ {z | x < z}, y' ≤ z`. The `IsLeast` spelling is used rather than the
equivalent least-positive-element form (`∃ p, IsLeast {d | 0 < d} p`) because the paper states the
clause pointwise at an arbitrary `x`, not at `0`, and the two agree only after the
translation-invariance of the duration group is invoked. Recording the clause as stated keeps that
invocation a proof step rather than a definitional assumption.

**This is not the predicate `FrameClass.ZTime` is interpreted by.** See
`TaskFrame.IsZTime`, which is strictly stronger.
-/
def TaskFrame.IsDiscrete (F : TaskFrame) : Prop :=
  ∀ x : F.Duration, (∃ y, x < y) → ∃ y', IsLeast {z | x < z} y'

/--
The **successor-Archimedean discrete** class: `def:BX-z`'s narrowing of `IsDiscrete`.

`def:BX-z` closes by narrowing the discrete class over which `BX_z` and `TM_z` are sound and
complete to exactly the frames over `ℤ`-time: the axioms `UZ` and `Z1` fail over every discrete
temporal order that is not Archimedean, and the Archimedean discrete orders are exactly `ℤ`-time.
(An earlier revision of the paper reached the same conclusion by way of Hölder's theorem, which is
where this predicate's name comes from; the conclusion is unchanged, and is restated here in the
tree's own voice rather than quoted.)

**It is this predicate, not `TaskFrame.IsDiscrete`, that `FrameClass.ZTime` admits axioms
for.** `Axiom.prior_UZ`, `Axiom.prior_SZ` and `Axiom.z1` all carry `.ZTime` as their
`minFrameClass`, and by the narrowing above they are sound over `ℤ`-time rather than over every
frame satisfying `def:frame-properties`' bare Discrete clause. Interpreting `FrameClass.ZTime`
by `IsDiscrete` would silently widen the class under `soundness_ztime` — the defect that the
retired marker-typeclass frame-condition layer carried, and part of why that layer was removed.

**Existential, not instance binders, and deliberately so.** `SuccOrder` and `PredOrder` are
data-carrying structures, so a `TaskFrame → Prop` cannot take them as instance arguments; the
`Prop`-valued existential is what lets the property be predicated of a frame at all. Downstream
consumers destructure it with `obtain` and pass the witnesses positionally with `@` — never with
`haveI`, which breaks definitional equality against instances already baked into the types of `F`
and its models.

**There are, and can be, no named accessors — this form is final.** The obvious-looking
alternative, `structure TaskFrame.IsZTime (F : TaskFrame) : Prop where [succ :
SuccOrder F.Duration] …`, does not compile: a `Prop`-valued structure cannot project a
`Type`-valued field, for exactly the reason `Nonempty` has no `.val`. An `inductive` reformulation
does compile but buys only `⟨⟩`-introduction and has no projections either, so it changes a
`def:BX-z`-citing definition for nothing. The existential therefore stays, and the two bridge
lemmas below — `isZTime_of_instances` and `IsZTime.elim` — are the
introduction and elimination interface in place of accessors. Use `.elim` or `obtain`; do not
expect a `.succ` field to appear later.

This predicate implies `IsDiscrete` (a successor order supplies the least strict upper bound at
every point), but that implication is not proved here: nothing in the tree consumes it, and the
two predicates are kept independent so that neither definition is stated in terms of the other.
-/
def TaskFrame.IsZTime (F : TaskFrame) : Prop :=
  ∃ (_ : SuccOrder F.Duration) (_ : PredOrder F.Duration),
    IsSuccArchimedean F.Duration ∧ IsPredArchimedean F.Duration

/--
`def:frame-properties`, Complete clause, verbatim: a task frame is **Complete** "if every nonempty
`S ⊆ D` bounded above has a least upper bound in `D`".

Expressed as the explicit `Prop`-valued hypothesis rather than by demanding a
`ConditionallyCompleteLinearOrder` instance on the carrier: every downstream lemma indexed by the
frame's existing `LinearOrder` continues to apply, with no instance-unification risk.

**`ℤ` satisfies this.** The integers carry a Mathlib `ConditionallyCompleteLinearOrder` instance
(`Mathlib/Data/Int/ConditionallyCompleteOrder.lean`), so this clause does not single out the real
flow; by `Semantics.complete_duration_discrete_or_dense` its models are `{ℤ, ℝ}` up to
order-and-group isomorphism. The dense-and-complete narrowing is `TaskFrame.IsRTime`.

**Reciprocal pointer for `ValidComplete`.** `Semantics/Validity.lean`'s `ValidComplete` is
`ValidOnFrames` at *this* bare clause, not at `IsRTime` below, and is the one `Valid*` name
that is not `ValidIn` at its apparent tag. See the `ValidComplete` caveat in `Semantics/Validity.lean` — the one place the `ValidComplete` / `ValidRTime` distinction is argued in full.
-/
def TaskFrame.IsComplete (F : TaskFrame) : Prop :=
  ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x

/--
The **dense and Dedekind-complete** class: `def:frame-properties`' Dense clause conjoined with its
Complete clause. This is `cor:tm-completeness`'s TM_r target — that corollary states TM_r
weakly complete over `ℝ`-time, the dense and Dedekind-complete orders — and the semantic
interpretation of the proof side's `FrameClass.RTime`.

Adding density to `IsComplete` deletes precisely the `ℤ` branch of the Hölder dichotomy and
nothing else: by `Semantics.complete_duration_discrete_or_dense` a complete duration group is
either `≃+o ℤ` or densely ordered, and by `Semantics.complete_not_dense_iso_int` those branches
are exclusive. So up to order-and-group isomorphism this class is the real flow.

## Why this class is named `IsRTime`

`def:frame-properties` calls the dense-and-complete property Complete, and the word "complete" is
already load-bearing here for *proof-theoretic* completeness — `completeness`,
`completeness_dense`, `completeness_ztime`, `completeness_rtime`,
`Metalogic/StrongCompleteness.lean` — so a `TaskFrame.IsComplete`-versus-`FrameClass.Complete`
pair would collide with the tree's most-cited word at exactly the point where the two senses meet.
The name `IsRTime` says instead what the class *is*: R-time, the real flow, which by the
dichotomy above is the only nontrivial model up to order-and-group isomorphism. Its ℤ-time
counterpart is `IsZTime`, and the pair `FrameClass.ZTime` / `FrameClass.RTime` and
`ValidZTime` / `ValidRTime` carry the same two names through the proof and validity layers.

Note that the bare Complete clause above keeps the paper's name (`IsComplete`); only the
dense-and-complete conjunction is named for its carrier.
-/
def TaskFrame.IsRTime (F : TaskFrame) : Prop := F.IsDense ∧ F.IsComplete

namespace TaskFrame

/-- Introduce `IsZTime` from the four instances it existentially quantifies, so that a
site holding them as instance binders does not have to write the nested anonymous constructor. -/
theorem isZTime_of_instances (F : TaskFrame)
    [SuccOrder F.Duration] [PredOrder F.Duration]
    [IsSuccArchimedean F.Duration] [IsPredArchimedean F.Duration] :
    F.IsZTime :=
  ⟨‹_›, ‹_›, ‹_›, ‹_›⟩

/-- Eliminate `IsZTime` by running a continuation under its four instances. This is the
substitute for the projections the definition cannot have (see its docstring): the witnesses reach
the continuation through the instance cache rather than through named accessors. -/
theorem IsZTime.elim {F : TaskFrame} {motive : Prop} (h : F.IsZTime)
    (k : ∀ [SuccOrder F.Duration] [PredOrder F.Duration] [IsSuccArchimedean F.Duration]
           [IsPredArchimedean F.Duration], motive) : motive := by
  obtain ⟨_, _, _, _⟩ := h
  exact k

/-- A dense-and-complete frame is dense. Named so that downstream sites cite a lemma rather than
an anonymous `And` projection. -/
theorem isDense_of_isRTime {F : TaskFrame} (h : F.IsRTime) : F.IsDense := h.1

/-- A dense-and-complete frame is complete. Named so that downstream sites cite a lemma rather
than an anonymous `And` projection. -/
theorem isComplete_of_isRTime {F : TaskFrame} (h : F.IsRTime) : F.IsComplete := h.2

/-!
## Determinism

`def:deterministic` — the sixth frame property, and the only one here that constrains the *task
relation* rather than the duration order.
-/

/--
`def:deterministic`: **the frame is deterministic** — every fibre of the task relation is a
subsingleton. Equivalently (`TaskFrame.deterministic_iff`), `w ⇒_x u` and `w ⇒_x v` force
`u = v`.

Stated in the tree's own `Fib` idiom rather than pointwise so that the two existing helpers
consume it verbatim: `TaskFrame.saturation_of_fib_subsingleton` turns it into the frame's
*Saturation* field (`TaskFrame.saturation_of_deterministic` below), and
`translationRel_fib_subsingleton` (`Semantics/Frames/Standard.lean`) is already literally a proof
of it for the translation frames.

**One bidirectional condition, not a forward/backward conjunction.** `d` ranges over *all* of
`F.Duration`, negative durations included. That is not a strengthening bolted on for convenience:
`FrameOver.converse` is a structure field, so `w ⇒_x u ↔ u ⇒_{-x} w` holds in every frame, and
the past instances of this predicate are therefore already determined by the future ones being
asserted about *every* state. Writing it with an unrestricted binder is what makes that visible.

**Restricting `d` to `0 ≤ d` gives a strictly weaker predicate that does NOT support the bridge
lemma.** `states_eq_of_deterministic` (`Semantics/PlusLanguage/PlusDeterminism.lean`) applies this at the
possibly negative duration `s - t`; under a `0 ≤ d` guard the frame `natFrame` over `ℤ` (which
relates every state to every state at every nonzero duration in the past direction) would count
as "deterministic" while refuting the collapse. The unrestricted binder is a correctness
requirement, not fidelity to a particular phrasing.
-/
def Deterministic (F : TaskFrame) : Prop :=
  ∀ (w : F.WorldState) (d : F.Duration), (TaskFrame.Fib F.TaskRel w d).Subsingleton

/-- The `Fib` form and the pointwise form of `def:deterministic` agree — one line each way. The
pointwise form is the one a refutation is easiest to state against (see
`Metalogic/Independence/DriftFrame.lean`); the `Fib` form is the one the helpers consume. -/
theorem deterministic_iff (F : TaskFrame) :
    F.Deterministic ↔
      ∀ (w u v : F.WorldState) (x : F.Duration), F.TaskRel w x u → F.TaskRel w x v → u = v :=
  ⟨fun h w _ _ x hu hv => h w x hu hv, fun h w x _ hu _ hv => h w _ _ x hu hv⟩

/-- A deterministic frame gets its *Saturation* field for free, via
`TaskFrame.saturation_of_fib_subsingleton`: a fibre that is a subsingleton is trivially
spherically well-behaved, and `Seg` is a subset of a fibre. No Zorn, no frame machinery. This is
what lets a determinism hypothesis be *assumed* on an abstract frame without also assuming
anything else. -/
theorem saturation_of_deterministic {F : TaskFrame} (h : F.Deterministic) :
    TaskFrame.Saturation F.TaskRel :=
  TaskFrame.saturation_of_fib_subsingleton h

/--
**Forward determinism**: `Deterministic` with the duration binder guarded by `0 ≤ d`.

Strictly weaker than `TaskFrame.Deterministic`, and introduced for **one purpose only**: to name
what the manuscript's `sent:det` defines. `Deterministic`'s own docstring above explains at
length why the *unrestricted* binder is the real notion — the guarded predicate does not support
the singleton bridge, and `natFrame` over `ℤ` satisfies it while refuting the collapse. Nothing
in this development substitutes this predicate for `Deterministic`, and no result stated of
`Deterministic` may be weakened to it.

The separation is witnessed, not merely asserted: `FN`
(`Metalogic/Independence/ForwardDeterministicFrame.lean`) is forward-deterministic and **not**
`Deterministic`, over the infinite carrier `ℕ`. That the witness must be infinite is itself a
theorem-shaped fact — on a finite carrier *Seriality* makes each `⇒_x` (`x ≥ 0`) surjective and
hence injective, so forward determinism already entails the backward direction there.
-/
def ForwardDeterministic (F : TaskFrame) : Prop :=
  ∀ (w : F.WorldState) (d : F.Duration), 0 ≤ d → (TaskFrame.Fib F.TaskRel w d).Subsingleton

/-- The pointwise form of `ForwardDeterministic`, mirroring `deterministic_iff`. -/
theorem forwardDeterministic_iff (F : TaskFrame) :
    F.ForwardDeterministic ↔
      ∀ (w u v : F.WorldState) (x : F.Duration), 0 ≤ x →
        F.TaskRel w x u → F.TaskRel w x v → u = v :=
  ⟨fun h w _ _ x hx hu hv => h w x hx hu hv, fun h w x hx _ hu _ hv => h w _ _ x hx hu hv⟩

/-- Determinism implies forward determinism: the guarded binder is an instance of the
unrestricted one. The converse is **false**, and `fn_not_deterministic`
(`Metalogic/Independence/ForwardDeterministicFrame.lean`) is the witness. -/
theorem forwardDeterministic_of_deterministic {F : TaskFrame} (h : F.Deterministic) :
    F.ForwardDeterministic :=
  fun w d _ => h w d

end TaskFrame

end FormalSystem.Semantics
