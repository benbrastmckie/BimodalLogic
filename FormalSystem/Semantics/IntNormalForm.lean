/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.WorldHistory
import Mathlib.Algebra.Order.Group.Int

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

## Main Results

- `iter_add` — `iter R (m + n)` factors as `iter R m` followed by `iter R n`
- `TaskFrame.taskRel_natCast_iff_iter` — the nonnegative core: `TaskRel w (n : ℤ) u ↔ step^n w u`
- `TaskFrame.taskRel_eq_iter` — the uniform two-sided characterization, valid at every `d : ℤ`

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
carry a frame across; the additive iso is the one that is actually needed. The route for a future
`ValidDiscrete`-to-ℤ transfer is therefore the second lemma, with `Archimedean D` and the
least-positive-element witness supplied (the successor structure is what produces the latter),
**not** a drop-in application of the first. `Semantics/DurationClassification.lean` already carries
the companion `archimedean_of_lub` for the Dedekind-complete branch; the discrete branch needs the
successor-based analogue, which is not in the tree.

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

end FormalSystem.Semantics
