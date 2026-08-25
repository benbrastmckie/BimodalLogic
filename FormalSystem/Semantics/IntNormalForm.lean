/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.WorldHistory
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred

/-!
# The ℤ-Frame Normal Form

Over `D = ℤ` a task frame is determined by a single relation: its **one-step** relation
`step w u := TaskRel w 1 u`. This module establishes that determination in the decomposition
direction — every `TaskFrame ℤ` *is* the iterate of its own one-step relation — and supplies the
arithmetic core (`iter`, `iter_add`) that the synthesis direction and the history-space
characterization both consume.

## Why ℤ, and why this is the spine

Three facts about `TaskFrame ℤ` collapse the general theory to a graph-theoretic one:

- `⇒₀` is the identity — carried directly by the `nullity_identity` field. (In the paper this is
  the ℤ-instance of *Limit*: `|y| < 1` forces `y = 0` over ℤ, so the intersection of the positive
  cones of `w` is `Fib(w, 0)`, which *Limit* pins to `{w}`.)
- `⇒ₙ = step^n` for `n ≥ 0`, by induction from the paper's *Compositionality*
  (`def:frame#Compositionality`) at `x = n`, `y = 1`.
- Negative durations are the converse convention (`def:task-relation`), carried by the `converse`
  field.

Everything downstream — the characterization of `H_F` as the bi-infinite step-paths, frame
synthesis from a bare bi-serial relation, and computable model checking — rests on this.

## Main Definitions

- `iter` — `n`-fold iteration of a binary relation, `iter R 0 = Eq` and
  `iter R (n+1) w u = ∃ v, iter R n w v ∧ R v u`
- `TaskFrame.step` — the one-step relation of a `TaskFrame ℤ`
- `IsStepPath` — a bi-infinite walk `f : ℤ → WorldState` stepping between consecutive times
- `TaskFrame.HF.path` — the bare path underlying a total world history
- `TaskFrame.HFofStepPath` — the total world history determined by a bi-infinite step-path

## Main Results

- `iter_add` — `iter R (m + n)` factors as `iter R m` followed by `iter R n`
- `TaskFrame.taskRel_natCast_iff_iter` — the nonnegative core: `TaskRel w (n : ℤ) u ↔ step^n w u`
- `TaskFrame.taskRel_eq_iter` — the uniform two-sided characterization, valid at every `d : ℤ`
- `TaskFrame.mem_HF_iff_adjacent` — `H_F` over ℤ is exactly the set of bi-infinite step-paths
- `TaskFrame.isTotal_respects_iff_adjacent` — the predicate-on-histories form of the same fact

## The Mathlib succ-Archimedean-to-ℤ transfer: binder-fit finding

`Semantics/Validity.lean`'s `ValidDiscrete` quantifies over duration types carrying
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D]`
`[IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]`. Two Mathlib results transfer such a
`D` to `ℤ`, and they are **not** interchangeable. Both binder fits were machine-checked against
this repository's pinned Mathlib before anything here was written:

- `orderIsoIntOfLinearSuccPredArch : D ≃o ℤ` fits that bundle **verbatim** — `NoMaxOrder D`,
  `NoMinOrder D`, and `Nonempty D` all synthesize from it, so no hypothesis need be added. It is
  `noncomputable`, and it delivers only an **order** isomorphism.
- `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos : D ≃+o ℤ` delivers the stronger
  **order-and-additive** isomorphism, but does **not** fit the bundle as it stands: `Archimedean D`
  does not synthesize from `[IsSuccArchimedean D] [IsPredArchimedean D]` (those are order-successor
  conditions, not the additive Archimedean property), and it additionally requires an
  `IsLeast {y : D | 0 < y} x` witness.

The distinction is load bearing rather than cosmetic. Durations *add* — `TaskRel`'s
*Compositionality* is stated at `x + y` — so a transfer that only preserves order is not enough to
carry a frame across; the additive iso is the one that is actually needed. The route for the
`ValidDiscrete`-to-ℤ transfer is therefore the second lemma, with `Archimedean D` and the
least-positive-element witness supplied (the successor structure is what produces the latter),
**not** a drop-in application of the first.

That route has since been taken. `Semantics/DurationClassification.lean` carries
`archimedean_of_lub` for the Dedekind-complete branch and now also the discrete branch's
successor-based analogue: `archimedean_of_succ` (the `Archimedean D` instance),
`isLeast_pos_succ_zero` (the witness), and `intIso : D ≃+o ℤ` packaging both.
`Semantics/IntTransfer.lean` transports `TaskFrame`, `TaskModel`, `WorldHistory`, and `TruthAt`
along that isomorphism, yielding `validDiscrete_iff_validInt : ValidDiscrete φ ↔ ValidInt φ`.

## What buying the right to work over ℤ is worth

The transfer above is not bookkeeping for its own sake: it is what makes the frame axioms cheap.
`TaskFrame.ofStep` below discharges **all seven** `TaskFrame` fields from a bare bi-serial relation
on a finite nonempty carrier, leaving exactly **one** genuine obligation — bi-seriality (`fwd` and
`bwd`). Its docstring tabulates the source of every field. So for *any* relation over `ℤ` on a
finite carrier, however non-permissive its shape, the four `def:frame` axioms cost one obligation
and nothing else. `Decidability/IntPresentation.lean`'s `toTaskFrame` is literally
`TaskFrame.ofStep P.stepRel P.fwd P.bwd`, and pays exactly that.

This pricing is available **only over ℤ**, and the asymmetry is the whole reason the transfer is
worth doing first. Two of the seven discharges are ℤ-specific: `limit` comes from
`TaskFrame.limit_of_succOrder`, which needs the successor structure, and `ofStep` itself is stated
at `TaskFrame ℤ`. A frame left polymorphic in `D` — such as `RefinedFilteredTaskFrame D` under
`Metalogic/Decidability/FMP/` — has neither, so each axiom must be re-discharged by hand for the
particular relation at hand. Estimates that price re-discharging the frame axioms as a large,
open-ended piece of work are measuring the `D`-polymorphic case; they do not transfer to the
ℤ case, and quoting them at a ℤ-frame overstates its cost by a wide margin.

## References

* `Semantics/TaskFrame.lean` — the `TaskFrame` structure and its four axiom fields
* `Semantics/DurationClassification.lean` — the Hölder discrete-or-dense dichotomy
-/

namespace FormalSystem.Semantics

/-!
## Iteration of a binary relation

The arithmetic core. Stated over a bare `W → W → Prop` with no frame, no duration type, and no
order, so that it is reusable wherever a step relation appears.
-/

/--
`iter R n` is the `n`-fold composite of the binary relation `R`: `iter R 0` is equality, and
`iter R (n+1)` is `iter R n` followed by one more `R`-step.

The recursion appends the new step on the **right**, which is what makes `iter_add`'s proof a
direct induction on the second summand and matches the `Compositionality`-at-`y = 1` shape used by
`TaskFrame.taskRel_natCast_iff_iter`.
-/
def iter {W : Type} (R : W → W → Prop) : ℕ → W → W → Prop
  | 0 => Eq
  | n + 1 => fun w u => ∃ v, iter R n w v ∧ R v u

@[simp]
theorem iter_zero {W : Type} (R : W → W → Prop) (w u : W) : iter R 0 w u ↔ w = u := Iff.rfl

@[simp]
theorem iter_succ {W : Type} (R : W → W → Prop) (n : ℕ) (w u : W) :
    iter R (n + 1) w u ↔ ∃ v, iter R n w v ∧ R v u := Iff.rfl

theorem iter_one {W : Type} (R : W → W → Prop) (w u : W) : iter R 1 w u ↔ R w u := by
  constructor
  · rintro ⟨v, rfl, h⟩; exact h
  · intro h; exact ⟨w, rfl, h⟩

/--
Iteration adds: an `(m + n)`-step path factors, at the `m`-th state, into an `m`-step path
followed by an `n`-step path.

This is the whole of *Compositionality* for the normal form — both directions of the paper's
biconditional at once — which is why a frame synthesized from a bare step relation gets its `comp`
field for free.
-/
theorem iter_add {W : Type} (R : W → W → Prop) (m n : ℕ) (w u : W) :
    iter R (m + n) w u ↔ ∃ v, iter R m w v ∧ iter R n v u := by
  induction n generalizing u with
  | zero => simp
  | succ n ih =>
    constructor
    · rintro ⟨z, hz, hstep⟩
      obtain ⟨v, hv, hvz⟩ := (ih z).mp hz
      exact ⟨v, hv, z, hvz, hstep⟩
    · rintro ⟨v, hv, z, hvz, hstep⟩
      exact ⟨z, (ih z).mpr ⟨v, hv, hvz⟩, hstep⟩

namespace TaskFrame

/-!
## The one-step relation and the decomposition theorem
-/

/--
The **one-step relation** of a task frame over ℤ: `step F w u` holds exactly when a task of
duration `1` takes `w` to `u`.

Over ℤ this single relation determines the whole frame — see `taskRel_eq_iter` below — which is
what reduces the semantics of a finite-`WorldState` frame to reachability in a finite directed
graph.
-/
def step (F : TaskFrame ℤ) : F.WorldState → F.WorldState → Prop :=
  fun w u => F.TaskRel w 1 u

theorem step_def (F : TaskFrame ℤ) (w u : F.WorldState) : F.step w u ↔ F.TaskRel w 1 u := Iff.rfl

/--
**The decomposition theorem, nonnegative core**: over ℤ, a task of natural-number duration `n` is
exactly an `n`-fold iteration of the one-step relation.

By induction on `n`. The base case is the `nullity_identity` field (`⇒₀` is the identity); the
step case is the `comp` field — the paper's biconditional *Compositionality*
(`def:frame#Compositionality`) — instantiated at `x = n`, `y = 1`, both nonnegative.
-/
theorem taskRel_natCast_iff_iter (F : TaskFrame ℤ) (n : ℕ) (w u : F.WorldState) :
    F.TaskRel w (n : ℤ) u ↔ iter F.step n w u := by
  induction n generalizing u with
  | zero => simpa using F.nullity_identity w u
  | succ n ih =>
    have hcast : ((n + 1 : ℕ) : ℤ) = (n : ℤ) + 1 := by push_cast; rfl
    rw [hcast, iter_succ]
    have hcomp := F.comp w u (n : ℤ) 1 (Int.natCast_nonneg n) zero_le_one
    rw [hcomp]
    exact ⟨fun ⟨v, h1, h2⟩ => ⟨v, (ih v).mp h1, h2⟩,
           fun ⟨v, h1, h2⟩ => ⟨v, (ih v).mpr h1, h2⟩⟩

/--
**The decomposition theorem**: over ℤ, an arbitrary `TaskFrame` is determined by its one-step
relation, at *every* duration — negative durations included.

The statement is uniform rather than case-split: the two conjuncts are each guarded by a sign
condition, so at a positive `d` the second is vacuous, at a negative `d` the first is, and at
`d = 0` both fire and together say `w = u` (which is exactly `nullity_identity`). The sign split
survives only inside the proof, where the negative half is discharged by the `converse` field
(`def:task-relation`'s converse convention) — the same route the paper uses.

`Int.natAbs` is the right index on both sides because `(-d).natAbs = d.natAbs`: a backward task of
duration `d < 0` is a forward `|d|`-step path traversed in the other direction.
-/
theorem taskRel_eq_iter (F : TaskFrame ℤ) (w u : F.WorldState) (d : ℤ) :
    F.TaskRel w d u ↔
      (0 ≤ d → iter F.step d.natAbs w u) ∧ (d ≤ 0 → iter F.step d.natAbs u w) := by
  constructor
  · intro h
    refine ⟨fun hd => ?_, fun hd => ?_⟩
    · have : ((d.natAbs : ℤ)) = d := Int.natAbs_of_nonneg hd
      exact (F.taskRel_natCast_iff_iter d.natAbs w u).mp (by rwa [this])
    · have hconv : F.TaskRel u (-d) w := (F.converse w d u).mp h
      have hnat : (((-d).natAbs : ℤ)) = -d := Int.natAbs_of_nonneg (by omega)
      have := (F.taskRel_natCast_iff_iter (-d).natAbs u w).mp (by rwa [hnat])
      rwa [Int.natAbs_neg] at this
  · rintro ⟨hpos, hneg⟩
    rcases le_or_gt 0 d with hd | hd
    · have hnat : ((d.natAbs : ℤ)) = d := Int.natAbs_of_nonneg hd
      exact hnat ▸ (F.taskRel_natCast_iff_iter d.natAbs w u).mpr (hpos hd)
    · have hd' : d ≤ 0 := le_of_lt hd
      have hnat : (((-d).natAbs : ℤ)) = -d := Int.natAbs_of_nonneg (by omega)
      have hiter : iter F.step (-d).natAbs u w := by
        rw [Int.natAbs_neg]; exact hneg hd'
      have : F.TaskRel u (-d) w :=
        hnat ▸ (F.taskRel_natCast_iff_iter (-d).natAbs u w).mpr hiter
      exact (F.converse w d u).mpr this

/-- The one-step relation is `taskRel_eq_iter` at `d = 1`: a sanity check that `step` really is
the `d = 1` slice, stated so a reader can see the two presentations agree. -/
theorem taskRel_one_iff_step (F : TaskFrame ℤ) (w u : F.WorldState) :
    F.TaskRel w 1 u ↔ F.step w u := Iff.rfl

end TaskFrame

/-!
## `H_F` over ℤ is exactly the set of bi-infinite step-paths

`def:world-history` makes a total world history a task-respecting assignment on *all* of `D`, with
an all-pairs obligation. Over ℤ that all-pairs obligation is redundant: adjacency at consecutive
integers implies it, by `taskRel_eq_iter`. This is what makes both the truth lemma and the model
checker tractable — a total history over a finite carrier becomes a bi-infinite walk in a finite
directed graph.

`regionFrame` is deliberately **not** the carrier used here. Its
`not_regionConstant_regionHistory` machine-checks that no history on that carrier ever repeats a
state, which forecloses every lasso argument on it. This presentation exists precisely so that the
downstream periodicity arguments have an obstruction-free carrier.
-/

/--
A **bi-infinite step-path** in a frame over ℤ: a state at every integer time, with a one-step
transition between consecutive times.
-/
def IsStepPath (F : TaskFrame ℤ) (f : ℤ → F.WorldState) : Prop :=
  ∀ n : ℤ, F.step (f n) (f (n + 1))

namespace TaskFrame

/-- The bare path underlying a total world history: totality makes the domain proof uniform, so
the dependent `states` field collapses to a plain function `ℤ → WorldState`. -/
def HF.path {F : TaskFrame ℤ} (τ : F.HF) : ℤ → F.WorldState :=
  fun t => τ.val.states t (τ.property t)

/--
Along a bi-infinite step-path, an `n`-step iterate connects a state to the state `n` times later.

This is the induction that discharges the all-pairs `respects_task` obligation from adjacency
alone; it is the technical heart of `mem_HF_iff_adjacent`'s converse direction.
-/
theorem iter_of_isStepPath {F : TaskFrame ℤ} {f : ℤ → F.WorldState} (h : IsStepPath F f)
    (n : ℕ) (s : ℤ) : iter F.step n (f s) (f (s + n)) := by
  induction n with
  | zero => simp
  | succ n ih =>
    refine ⟨f (s + n), ih, ?_⟩
    have hs : s + ((n : ℤ) + 1) = (s + n) + 1 := by omega
    have := h (s + n)
    rwa [show ((n + 1 : ℕ) : ℤ) = (n : ℤ) + 1 by push_cast; rfl, hs]

/-- A bi-infinite step-path satisfies the all-pairs task-respect obligation. -/
theorem respects_of_isStepPath {F : TaskFrame ℤ} {f : ℤ → F.WorldState} (h : IsStepPath F f)
    (s t : ℤ) : F.TaskRel (f s) (t - s) (f t) := by
  refine (F.taskRel_eq_iter (f s) (f t) (t - s)).mpr ⟨fun hd => ?_, fun hd => ?_⟩
  · have hst : t = s + ((t - s).natAbs : ℤ) := by omega
    have hgo := iter_of_isStepPath h (t - s).natAbs s
    rwa [← hst] at hgo
  · have hst : s = t + ((t - s).natAbs : ℤ) := by omega
    have hgo := iter_of_isStepPath h (t - s).natAbs t
    rwa [← hst] at hgo

/--
The total world history determined by a bi-infinite step-path. Every field is discharged from
adjacency: the domain is all of ℤ (so `nonempty_domain` and `convex` are trivial), and
`respects_task` is `respects_of_isStepPath`.
-/
def HFofStepPath (F : TaskFrame ℤ) (f : ℤ → F.WorldState) (h : IsStepPath F f) : F.HF :=
  ⟨{ domain := fun _ => True
     nonempty_domain := ⟨0, trivial⟩
     states := fun t _ => f t
     respects_task := fun s t _ _ => respects_of_isStepPath h s t
     convex := fun _ _ _ _ _ _ _ => trivial }, fun _ => trivial⟩

@[simp]
theorem HFofStepPath_path (F : TaskFrame ℤ) (f : ℤ → F.WorldState) (h : IsStepPath F f) :
    (HFofStepPath F f h).path = f := rfl

/-- Every total world history over ℤ is a bi-infinite step-path. -/
theorem HF.isStepPath {F : TaskFrame ℤ} (τ : F.HF) : IsStepPath F τ.path := by
  intro n
  have := τ.val.respects_task n (n + 1) (τ.property n) (τ.property (n + 1))
  rwa [show n + 1 - n = (1 : ℤ) by omega] at this

/--
**`H_F` over ℤ is exactly the set of bi-infinite step-paths.**

A function `f : ℤ → WorldState` is the underlying path of some total world history if and only if
it steps between consecutive times. The forward direction instantiates `def:world-history`'s
all-pairs task-respect at consecutive times; the converse rebuilds the all-pairs obligation from
adjacency alone, by `taskRel_eq_iter` and induction on the gap.
-/
theorem mem_HF_iff_adjacent (F : TaskFrame ℤ) (f : ℤ → F.WorldState) :
    (∃ τ : F.HF, τ.path = f) ↔ IsStepPath F f := by
  constructor
  · rintro ⟨τ, rfl⟩; exact τ.isStepPath
  · intro h; exact ⟨HFofStepPath F f h, rfl⟩

/--
The predicate-on-histories form of `mem_HF_iff_adjacent`: for a world history already known to be
total, task-respect at consecutive times is equivalent to task-respect at all pairs. The `←`
direction is the substantive one — it is what lets a construction discharge `respects_task` from a
single adjacency hypothesis.
-/
theorem isTotal_respects_iff_adjacent (F : TaskFrame ℤ) (f : ℤ → F.WorldState) :
    (∀ s t : ℤ, F.TaskRel (f s) (t - s) (f t)) ↔ IsStepPath F f := by
  constructor
  · intro h n
    have := h n (n + 1)
    rwa [show n + 1 - n = (1 : ℤ) by omega] at this
  · intro h s t; exact respects_of_isStepPath h s t

end TaskFrame

/-!
## Frame synthesis: from a bi-serial one-step relation to a `TaskFrame ℤ`

The converse of the decomposition theorem. Six of the seven `TaskFrame` fields come for free from
the normal form; the seventh, *Seriality*, is a genuine hypothesis and cannot be dropped.

**Seriality is free from *Occurrence*, never from ℤ.** It is tempting to think finiteness or
discreteness rescues it. They do not: the relation `R w d u := (d = 0)` on `W = Unit` over `D = ℤ`
satisfies `nullity_identity`, *Compositionality*, the converse convention, *Limit*, and
*Spherical*, and fails *Seriality* — on a one-element carrier. `ofStep` therefore takes forward and
backward seriality of `R₁` as hypotheses (`fwd`, `bwd`), and they are exactly bi-seriality of the
one-step relation. Do not attempt to derive them.
-/

/--
The two-sided ℤ task relation generated by a one-step relation `R₁`.

The shape is `taskRel_eq_iter`'s conclusion taken as a *definition*, which is what makes the
decomposition and synthesis directions agree definitionally rather than up to a transport.
-/
def ofStepRel {W : Type} (R₁ : W → W → Prop) (w : W) (d : ℤ) (u : W) : Prop :=
  (0 ≤ d → iter R₁ d.natAbs w u) ∧ (d ≤ 0 → iter R₁ d.natAbs u w)

/-- At a nonnegative duration, `ofStepRel` is forward iteration. The reverse conjunct is not lost:
it can only fire at `d = 0`, where it follows from the forward one. -/
theorem ofStepRel_of_nonneg {W : Type} {R₁ : W → W → Prop} {d : ℤ} (hd : 0 ≤ d) (w u : W) :
    ofStepRel R₁ w d u ↔ iter R₁ d.natAbs w u := by
  refine ⟨fun h => h.1 hd, fun h => ⟨fun _ => h, fun hd' => ?_⟩⟩
  have hz : d = 0 := le_antisymm hd' hd
  subst hz
  simpa using ((iter_zero R₁ w u).mp (by simpa using h)).symm

/-- At a nonpositive duration, `ofStepRel` is backward iteration, by the same argument mirrored. -/
theorem ofStepRel_of_nonpos {W : Type} {R₁ : W → W → Prop} {d : ℤ} (hd : d ≤ 0) (w u : W) :
    ofStepRel R₁ w d u ↔ iter R₁ d.natAbs u w := by
  refine ⟨fun h => h.2 hd, fun h => ⟨fun hd' => ?_, fun _ => h⟩⟩
  have hz : d = 0 := le_antisymm hd hd'
  subst hz
  simpa using ((iter_zero R₁ u w).mp (by simpa using h)).symm

/-- Forward seriality iterates: from every state there is an `n`-step forward path. -/
theorem exists_iter_fwd {W : Type} {R₁ : W → W → Prop} (fwd : ∀ w, ∃ u, R₁ w u) (n : ℕ) (w : W) :
    ∃ u, iter R₁ n w u := by
  induction n generalizing w with
  | zero => exact ⟨w, rfl⟩
  | succ n ih =>
    obtain ⟨v, hv⟩ := ih w
    obtain ⟨u, hu⟩ := fwd v
    exact ⟨u, v, hv, hu⟩

/-- Backward seriality iterates: into every state there is an `n`-step forward path. -/
theorem exists_iter_bwd {W : Type} {R₁ : W → W → Prop} (bwd : ∀ w, ∃ v, R₁ v w) (n : ℕ) (u : W) :
    ∃ w, iter R₁ n w u := by
  induction n generalizing u with
  | zero => exact ⟨u, rfl⟩
  | succ n ih =>
    obtain ⟨v, hv⟩ := bwd u
    obtain ⟨w, hw⟩ := ih v
    exact ⟨w, v, hw, hv⟩

namespace TaskFrame

/--
**Frame synthesis over ℤ**: a bi-serial relation on a finite nonempty carrier generates a
`TaskFrame ℤ`.

The seven field discharges, and where each comes from:

| field | source |
|-------|--------|
| `nonempty` | the `[Nonempty W]` instance |
| `nullity_identity` | free — `iter R₁ 0` *is* `Eq` |
| `comp` | free — `iter_add`, which is the paper's biconditional *Compositionality* whole |
| `converse` | free — `ofStepRel` is symmetric in its two sign-guarded conjuncts by construction |
| `serial` | **the one genuine obligation**: exactly `fwd` and `bwd` (see the section note above) |
| `limit` | `TaskFrame.limit_of_succOrder` — ℤ is a `SuccOrder`, so *Limit* is automatic |
| `spherical` | `TaskFrame.spherical_of_finite` — the carrier is finite |

`spherical_of_finite` is the *only* applicable route here, because `R₁` is arbitrary in shape and
every other `Spherical` helper constrains the relation's shape. It costs `Classical.choice`, and
that cost is accepted for `ofStep` specifically. It is **not** a licence to re-route a frame whose
relation *does* fit a choice-free class helper — see `spherical_of_finite`'s own docstring.
-/
def ofStep {W : Type} [Finite W] [Nonempty W] (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w) : TaskFrame ℤ where
  WorldState := W
  nonempty := inferInstance
  TaskRel := ofStepRel R₁
  nullity_identity := fun w u => by
    rw [ofStepRel_of_nonneg (le_refl (0 : ℤ))]
    simp
  comp := fun w v x y hx hy => by
    rw [ofStepRel_of_nonneg (add_nonneg hx hy)]
    have hnat : (x + y).natAbs = x.natAbs + y.natAbs := by omega
    rw [hnat, iter_add]
    exact exists_congr fun u => by
      rw [ofStepRel_of_nonneg hx, ofStepRel_of_nonneg hy]
  converse := fun w d u => by
    constructor
    · rintro ⟨h1, h2⟩
      exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
             fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩
    · rintro ⟨h1, h2⟩
      exact ⟨fun hd => by simpa [Int.natAbs_neg] using h2 (by omega),
             fun hd => by simpa [Int.natAbs_neg] using h1 (by omega)⟩
  serial := fun w x hx => by
    constructor
    · obtain ⟨u, hu⟩ := exists_iter_fwd fwd x.natAbs w
      exact ⟨u, (ofStepRel_of_nonneg hx w u).mpr hu⟩
    · obtain ⟨v, hv⟩ := exists_iter_bwd bwd x.natAbs w
      exact ⟨v, (ofStepRel_of_nonneg hx v w).mpr hv⟩
  limit := limit_of_succOrder (fun w u => by
    rw [ofStepRel_of_nonneg (le_refl (0 : ℤ))]
    simp)
  spherical := spherical_of_finite (ofStepRel R₁)

@[simp]
theorem ofStep_taskRel {W : Type} [Finite W] [Nonempty W] (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w) :
    (ofStep R₁ fwd bwd).TaskRel = ofStepRel R₁ := rfl

/-- The one-step relation of a synthesized frame is the relation it was synthesized from. -/
theorem ofStep_step {W : Type} [Finite W] [Nonempty W] (R₁ : W → W → Prop)
    (fwd : ∀ w, ∃ u, R₁ w u) (bwd : ∀ w, ∃ v, R₁ v w) (w u : W) :
    (ofStep R₁ fwd bwd).step w u ↔ R₁ w u := by
  show ofStepRel R₁ w 1 u ↔ _
  rw [ofStepRel_of_nonneg (zero_le_one : (0 : ℤ) ≤ 1)]
  exact iter_one R₁ w u

end TaskFrame

/-!
### Worked instances

Two small ℤ frames the results above are exercised on: `staticFrame` (already in the tree) for the
history-space characterization, and `flipFrame` (synthesized here by `ofStep`) for frame synthesis.
`flipFrame` is the two-state cycle — the smallest carrier on which a lasso argument has anything
to bite on — so it is kept as a named definition rather than inlined into an `example`.
-/

section WorkedInstances

/-- `staticFrame W` over ℤ relates a state only to itself, so its step relation is equality and
its bi-infinite step-paths are exactly the constant paths. -/
example (W : Type) [Nonempty W] (w : W) :
    IsStepPath (TaskFrame.staticFrame W (D := ℤ)) (fun _ => w) := by
  intro _
  exact (TaskFrame.staticFrame_rel_iff W (D := ℤ) w 1 w).mpr rfl

/-- The two-state flip relation on `Bool` is bi-serial, so `ofStep` synthesizes a `TaskFrame ℤ`
from it: the canonical two-cycle, and the smallest frame on which a lasso argument has anything
to bite on. -/
def flipFrame : TaskFrame ℤ :=
  TaskFrame.ofStep (fun w u : Bool => w ≠ u)
    (fun w => ⟨!w, by cases w <;> simp⟩) (fun w => ⟨!w, by cases w <;> simp⟩)

/-- `ofStep` really does recover the relation it was given. -/
example (w u : Bool) :
    (TaskFrame.ofStep (fun w u : Bool => w ≠ u)
      (fun w => ⟨!w, by cases w <;> simp⟩) (fun w => ⟨!w, by cases w <;> simp⟩)).step w u
      ↔ w ≠ u :=
  TaskFrame.ofStep_step _ _ _ w u

/-- …and the characterization then produces an actual member of `H_F` over that frame. -/
example (W : Type) [Nonempty W] (w : W) :
    ∃ τ : (TaskFrame.staticFrame W (D := ℤ)).HF, τ.path = fun _ => w :=
  (TaskFrame.mem_HF_iff_adjacent (TaskFrame.staticFrame W (D := ℤ)) (fun _ => w)).mpr
    (fun _ => (TaskFrame.staticFrame_rel_iff W (D := ℤ) w 1 w).mpr rfl)

end WorkedInstances

end FormalSystem.Semantics
