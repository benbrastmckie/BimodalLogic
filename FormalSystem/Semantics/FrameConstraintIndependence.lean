/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import Mathlib.Data.Int.SuccPred

/-!
# Pairwise independence of `def:frame`'s four constraints, over `ℤ`

`def:frame` lists four constraints on a task relation — *Compositionality*, *Seriality*, *Limit*
and *Saturation*. This module establishes that **none of the four is a consequence of the other
three** by exhibiting, for each one, a relation that satisfies the other three and refutes it,
and states the conjunction of the four as one citable theorem,
`constraints_pairwise_independent`.

## What this establishes

| Witness | Carrier | Satisfies | Refutes |
|---------|---------|-----------|---------|
| `emptyRel` | `Bool` | *Compositionality*, *Limit*, *Saturation* | *Seriality* |
| `totalRel` | `Bool` | *Compositionality*, *Seriality*, *Saturation* | *Limit* |
| `rayRel` | `ℤ` | *Compositionality*, *Seriality*, *Limit* | *Saturation* |
| `driftRel` | `ℤ` | *Seriality*, *Limit*, *Saturation* | *Compositionality* |

The consequence for the transcription audit is that the four-clause frame-condition row is
**provably incompressible**: a reader auditing the Lean transcription against the paper's four
clauses cannot be told that three of them would do.

## This is not the tree's first independence matrix — read this before citing it as one

`FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` already carries a complete
independence matrix, and says so in its own header:

- *Seriality* fails at the **void frame** — `StateTopology.voidRel` (`Bool → ℤ → Bool → Prop`,
  the empty relation) with `voidFrame_compositional`, `voidFrame_limit`, `voidFrame_saturation`,
  `voidFrame_not_serial`. `emptyRel` below is that relation restated at a bare `ℤ` duration.
- *Compositionality* fails at the **bump frame** — `StateTopology.bumpRel` with
  `bumpFrame_serial`, `bumpFrame_limit`, `bumpFrame_saturation`,
  `bumpFrame_not_compositional`. `driftRel` below is a different witness for the same row.
- *Saturation* fails at the **separating frame** — `StateTopology.SeparatingFrame.srel`
  (`ℚ → ℤ → ℚ → Prop`, unit-speed drift on a rational carrier over ℤ-time) with `srel_serial`,
  `srel_compositional`, `srel_limit`, `not_srel_saturation`; and, over dense time, at
  `StateTopology.RationalTwoOrigins`.
- *Limit* fails at the **four-state funnel** — `StateTopology.funnel_not_limit`. That one carries
  a `[DenselyOrdered ↑D]` binder, so it does **not** apply over `ℤ`.

So what this module adds is narrower than a first matrix, and should be cited as exactly that:

1. **The aggregate statement.** `constraints_pairwise_independent` is the tree's first single
   theorem saying the four constraints are pairwise independent. Before it, the fact was four
   scattered groups of theorems plus a claim in a module header.
2. **A *Limit* refutation that holds over `ℤ`.** `totalRel_not_limit` is genuinely new: the
   funnel's needs dense time, so nothing in the tree previously refuted *Limit* over the discrete
   duration order the certificate actually uses.
3. **Uniformity over one time structure, at no import weight.** The existing witnesses are spread
   over `ℤ`-time and dense time and over `Bool`, `ℚ` and `ℝ` carriers, and they live in
   topology-carrying leaves that are deliberately kept out of `FormalSystem/Semantics.lean` — see
   that aggregator's own note on why `Mathlib.Topology.*` instances must not reach it. This module
   imports `TaskFrame` and `Mathlib.Data.Int.SuccPred` and nothing else, so the aggregate result is
   reachable from the aggregator.

The cost of (3) is that three of the four rows below re-prove, at a different witness, something
the tree already knew. That is a real duplication and is recorded as such in
`docs/reference/transcription-audit-surface.md` rather than glossed over here.

## Why `D := ℤ` and not `↑intOrder`

The four constraint predicates are `D`-typed — `TaskFrame.Serial`, `Compositional`, `Limit` and
`Saturation` all take `{W : Type} (R : W → D → W → Prop)` against the section bundle
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` — so they apply at a bare
`ℤ` as readily as at a temporal order's carrier. And `intOrder := ⟨ℤ⟩` is `@[reducible]` with
`(↑intOrder : Type) = ℤ` by `rfl`, so **every statement below is already a statement about the
certificate's own time structure**; nothing is lost by writing `ℤ`.

What is gained is that `omega` works. `omega` inspects the *syntactic* type of a hypothesis and
does not see through the `TemporalOrder` coercion, so an `↑intOrder`-typed arithmetic binder is
opaque to it — the finding `FormalSystem/Semantics/TemporalOrder.lean`'s own header records.
Stating the witnesses at `ℤ` removes that obstacle at the level of the statement rather than by
patching tactics, and a later editor must not "tidy" these signatures back to `↑intOrder`.

## What this does *not* establish

Nothing about the **definitional** audit surface. This module bounds how far the *clause count* of
`def:frame` can fall; it says nothing about how many Lean *definitions* a human must read against
the paper's text, which is a different and larger surface. The two are kept apart deliberately —
see `docs/reference/transcription-audit-surface.md`, which states the definitional residue as a
count and names every row.

## Not in `Metalogic/Independence/`

That directory means **proof-system axiom** independence: a formula not derivable from a given
axiom set. This module is about *semantic frame constraints* being mutually irredundant, an
unrelated notion, and siting it there would collide with an established meaning.

## Tags

frame-constraints · independence · transcription-audit · def:frame
-/

namespace FormalSystem.Semantics

namespace FrameConstraintIndependence

/-! ### The *Seriality* witness -/

/--
The **empty relation** on a two-point carrier: nothing is related to anything.

*Seriality* fails outright — no state has any successor — while *Compositionality*, *Limit* and
*Saturation* hold vacuously.
Paper: `def:frame#Seriality`

This is `StateTopology.voidRel` restated at a bare `ℤ` duration, so that the aggregate theorem
below needs no topology import; see this module's header for why a second statement exists.
-/
def emptyRel : Bool → ℤ → Bool → Prop := fun _ _ _ => False

/-- *Compositionality* holds vacuously for `emptyRel`: both sides of the biconditional are
`False`.
Paper: `def:frame#Compositionality`
-/
theorem emptyRel_compositional : TaskFrame.Compositional emptyRel := by
  intro w v x y _ _
  simp [emptyRel]

/-- *Limit* holds vacuously for `emptyRel`: the hypothesis at a positive duration already
supplies a related pair, and there are none.
Paper: `def:frame#Limit`
-/
theorem emptyRel_limit : TaskFrame.Limit emptyRel := by
  intro w u h
  obtain ⟨y, _, hy⟩ := h 1 (by norm_num)
  exact absurd hy (by simp [emptyRel])

/-- *Saturation* holds for `emptyRel`: every fibre is empty, hence a subsingleton, so
`TaskFrame.saturation_of_fib_subsingleton` applies.
Paper: `def:frame#Saturation`
-/
theorem emptyRel_saturation : TaskFrame.Saturation emptyRel :=
  TaskFrame.saturation_of_fib_subsingleton fun _ _ u hu =>
    absurd hu (by simp [emptyRel, TaskFrame.Fib])

/-- **`emptyRel` refutes *Seriality*.**
Paper: `def:frame#Seriality`
-/
theorem emptyRel_not_serial : ¬ TaskFrame.Serial emptyRel := by
  intro h
  obtain ⟨⟨_, hu⟩, -⟩ := h true 0 le_rfl
  exact hu

/-! ### The *Limit* witness -/

/--
The **total relation** on a two-point carrier: everything is related to everything at every
duration.

*Limit* fails — `false` lies in every positive cone of `true` — while the other three hold.
Paper: `def:frame#Limit`

**This row is the one the tree did not already have.** The existing *Limit* refutation, the
four-state funnel's `StateTopology.funnel_not_limit`, carries a `[DenselyOrdered ↑D]` binder, so
it says nothing over the discrete duration order the certificate uses. This witness is over `ℤ`.

**Why `Bool` and not `Unit`.** `FrameOver.trivialFrame` already carries the total relation on a
one-point carrier, and there *Limit* holds, by `TaskFrame.limit_of_subsingleton`: over a
subsingleton there is nothing for the cone intersection to contain besides the point itself. A
carrier with two distinct points is exactly what makes the refutation possible, so the trivial
frame is not this witness and cannot be made into one.
-/
def totalRel : Bool → ℤ → Bool → Prop := fun _ _ _ => True

/-- *Compositionality* holds for `totalRel`: both sides of the biconditional are `True`.
Paper: `def:frame#Compositionality`
-/
theorem totalRel_compositional : TaskFrame.Compositional totalRel := by
  intro w v x y _ _
  simp [totalRel]

/-- *Seriality* holds for `totalRel`, by `TaskFrame.serial_of_total`.
Paper: `def:frame#Seriality`
-/
theorem totalRel_serial : TaskFrame.Serial totalRel :=
  TaskFrame.serial_of_total fun _ _ _ => trivial

/-- *Saturation* holds for `totalRel`: every fibre and every segment is the whole carrier, so any
directed family of them has the whole carrier as its intersection.
Paper: `def:frame#Saturation`
-/
theorem totalRel_saturation : TaskFrame.Saturation totalRel := by
  intro S _ hmem
  refine ⟨true, Set.mem_sInter.mpr ?_⟩
  intro s hs
  rcases (hmem s hs).1 with ⟨w, x, rfl⟩ | ⟨w, v, x, y, _, _, rfl⟩
  · trivial
  · exact ⟨trivial, trivial⟩

/-- **`totalRel` refutes *Limit*.** `false` lies in every positive cone of `true` — the witness
duration `0` serves at every radius — so *Limit* would force `false = true`.
Paper: `def:frame#Limit`
-/
theorem totalRel_not_limit : ¬ TaskFrame.Limit totalRel := by
  intro h
  have hbad := h false true fun x hx => ⟨0, by simpa using hx, trivial⟩
  simp at hbad

/-! ### The *Saturation* witness -/

/--
**Upward rays on the integers**: at duration `0` the relation is the identity, at a positive
duration it reaches every later state, and at a negative duration every earlier one.

*Saturation* fails — the fibres of a positive duration form a `⊇`-directed family of nonempty
upward rays whose intersection recedes to infinity and is empty — while *Compositionality*,
*Seriality* and *Limit* hold.
Paper: `def:frame#Saturation`

**The failure is a recession failure, not a completeness failure.** Contrast
`StateTopology.RationalTwoOrigins.not_rel_saturation`, where *Saturation* fails because the
rational carrier is missing the point `√2` that a straddling family's intersection would have to
be: there the family is bounded and the carrier is incomplete. Here the carrier `ℤ` is as complete
as a discrete order can be, and the family is unbounded above. The two mechanisms are independent,
and reading this witness as a second instance of that one gets the geometry backwards.
-/
def rayRel : ℤ → ℤ → ℤ → Prop := fun w x u => (x = 0 ∧ u = w) ∨ (0 < x ∧ w ≤ u) ∨ (x < 0 ∧ u ≤ w)

/-- `rayRel` unfolded, as a rewriting lemma.

Deliberately **not** `@[simp]`, and used with `rw` rather than `simp only` throughout: `simp`
collapses a reflexive conjunct such as `w = w` to `True`, and `omega` cannot parse `True`, so
simping the definition open destroys exactly the arithmetic front end that stating this witness at
`ℤ` was meant to provide. -/
theorem rayRel_def (w x u : ℤ) :
    rayRel w x u ↔ (x = 0 ∧ u = w) ∨ (0 < x ∧ w ≤ u) ∨ (x < 0 ∧ u ≤ w) := Iff.rfl

/-- *Compositionality* holds for `rayRel`. Interpolation splits on whether the second duration is
zero: at `y = 0` the intermediate state must be the endpoint, and at `0 < y` the source state
itself serves.
Paper: `def:frame#Compositionality`
-/
theorem rayRel_compositional : TaskFrame.Compositional rayRel := by
  intro w v x y hx hy
  rw [rayRel_def]
  constructor
  · intro h
    rcases hy.lt_or_eq with hy0 | hy0
    · refine ⟨w, ?_, ?_⟩
      · rw [rayRel_def]; omega
      · rw [rayRel_def]; omega
    · refine ⟨v, ?_, ?_⟩
      · rw [rayRel_def]; omega
      · rw [rayRel_def]; omega
  · rintro ⟨u, h1, h2⟩
    rw [rayRel_def] at h1 h2
    omega

/-- *Seriality* holds for `rayRel`: every state is its own successor and predecessor at every
`x ≥ 0`, through the zero clause at `x = 0` and the positive clause at `0 < x`.
Paper: `def:frame#Seriality`
-/
theorem rayRel_serial : TaskFrame.Serial rayRel := by
  intro w x hx
  rcases hx.lt_or_eq with hpos | hzero
  · exact ⟨⟨w, Or.inr (Or.inl ⟨hpos, le_rfl⟩)⟩, ⟨w, Or.inr (Or.inl ⟨hpos, le_rfl⟩)⟩⟩
  · exact ⟨⟨w, Or.inl ⟨hzero.symm, rfl⟩⟩, ⟨w, Or.inl ⟨hzero.symm, rfl⟩⟩⟩

/-- *Limit* holds for `rayRel`, by `TaskFrame.limit_of_succOrder`: the duration order is discrete
and the only duration-`0` pairs are the identity.
Paper: `def:frame#Limit`
-/
theorem rayRel_limit : TaskFrame.Limit rayRel :=
  TaskFrame.limit_of_succOrder fun w u h => by rw [rayRel_def] at h; omega

/-- **`rayRel` refutes *Saturation*.**

The family `{Fib rayRel w 1 | w : ℤ}` of duration-`1` fibres is `⊇`-directed (the fibre at
`max w₁ w₂` is contained in the intersection of the fibres at `w₁` and `w₂`) and every member is a
nonempty upward ray, yet `⋂₀` of it is empty: for any candidate `a`, the fibre at `a + 1` misses
it.
Paper: `def:frame#Saturation`
-/
theorem rayRel_not_saturation : ¬ TaskFrame.Saturation rayRel := by
  intro hsat
  have hdir : TaskFrame.DirectedFamily {s : Set ℤ | ∃ w : ℤ, s = TaskFrame.Fib rayRel w 1} := by
    refine ⟨⟨TaskFrame.Fib rayRel 0 1, 0, rfl⟩, ?_⟩
    rintro s₁ ⟨w₁, rfl⟩ s₂ ⟨w₂, rfl⟩
    refine ⟨TaskFrame.Fib rayRel (max w₁ w₂) 1, ⟨max w₁ w₂, rfl⟩, ?_⟩
    intro u hu
    simp only [Set.mem_inter_iff, TaskFrame.mem_Fib, rayRel_def] at hu ⊢
    omega
  have hmem : ∀ s ∈ {s : Set ℤ | ∃ w : ℤ, s = TaskFrame.Fib rayRel w 1},
      (TaskFrame.IsFiber rayRel s ∨ TaskFrame.IsSegment rayRel s) ∧ s.Nonempty := by
    rintro s ⟨w, rfl⟩
    refine ⟨Or.inl ⟨w, 1, rfl⟩, ⟨w, ?_⟩⟩
    rw [TaskFrame.mem_Fib, rayRel_def]
    omega
  obtain ⟨a, ha⟩ := hsat _ hdir hmem
  have hbad := Set.mem_sInter.mp ha (TaskFrame.Fib rayRel (a + 1) 1) ⟨a + 1, rfl⟩
  rw [TaskFrame.mem_Fib, rayRel_def] at hbad
  omega

/-! ### The *Compositionality* witness -/

/--
A **non-additive reindexing of durations**: the identity except at `1`, where it takes the value
`5`.

Non-additivity at a single point is the whole content of the *Compositionality* refutation below:
`drift 1 + drift 1 = 10` while `drift (1 + 1) = 2`.
-/
def drift : ℤ → ℤ := fun x => if x = 1 then 5 else x

/--
A **functional but non-additive shift**: `w ⇒_x u` iff `u = w + drift x`.

*Compositionality* fails, and the other three hold. The witness is **functional on purpose**:
functionality is what makes three of the four constraints free — `Saturation` from subsingleton
fibres, *Limit* from discreteness plus `drift 0 = 0`, *Seriality* from surjectivity of each shift
— so the only thing left for the witness to break is *Compositionality*.

A different witness for the same row already exists in the
tree, `StateTopology.bumpRel`, which breaks *Compositionality* by a clause boundary at `|d| ≥ 2`
rather than by non-additivity; see this module's header.

Paper: `def:frame#Compositionality`
-/
def driftRel : ℤ → ℤ → ℤ → Prop := fun w x u => u = w + drift x

/-- *Seriality* holds for `driftRel`: each shift is a bijection of `ℤ`, so `w + drift x` is a
successor and `w - drift x` a predecessor.
Paper: `def:frame#Seriality`
-/
theorem driftRel_serial : TaskFrame.Serial driftRel := fun w x _ =>
  ⟨⟨w + drift x, rfl⟩, ⟨w - drift x, by simp [driftRel]⟩⟩

/-- *Limit* holds for `driftRel`, by `TaskFrame.limit_of_succOrder` with the zero-duration
hypothesis discharged by `drift 0 = 0`.
Paper: `def:frame#Limit`
-/
theorem driftRel_limit : TaskFrame.Limit driftRel :=
  TaskFrame.limit_of_succOrder fun w u h => by simpa [driftRel, drift] using h

/-- *Saturation* holds for `driftRel`: the relation is presented by the function
`fun w x => w + drift x`, so every fibre is a subsingleton and
`TaskFrame.saturation_of_fib_subsingleton` applies.
Paper: `def:frame#Saturation`
-/
theorem driftRel_saturation : TaskFrame.Saturation driftRel :=
  TaskFrame.saturation_of_fib_subsingleton
    (TaskFrame.fib_subsingleton_of_functional (f := fun w x => w + drift x) fun _ _ _ => Iff.rfl)

/-- **`driftRel` refutes *Compositionality*.** At `x = y = 1` two steps compose to `w + 10`, while
the single step of duration `2` gives `w + 2`; `10 ≠ 2`, so the biconditional fails from right to
left.
Paper: `def:frame#Compositionality`
-/
theorem driftRel_not_compositional : ¬ TaskFrame.Compositional driftRel := by
  intro h
  have hbad := (h 0 10 1 1 (by norm_num) (by norm_num)).mpr
    ⟨5, by simp [driftRel, drift], by simp [driftRel, drift]⟩
  simp [driftRel, drift] at hbad

/-! ### The independence matrix -/

/--
**Each of `def:frame`'s four constraints is independent of the other three**, over `ℤ`.

The duration type `intOrder` *is* `ℤ` — reducibly, and by `rfl` — so this is independence over the
very time structure the certificate uses, not over a convenient stand-in. Each conjunct supplies a
carrier and a relation satisfying three of `TaskFrame.Compositional`, `TaskFrame.Serial`,
`TaskFrame.Limit`, `TaskFrame.Saturation` and refuting the fourth, in that order: *Seriality*,
*Limit*, *Saturation*, *Compositionality*.

**What this licenses.** Exactly one claim: *the four-clause frame-condition row cannot be
compressed to three, over the certificate's own time structure.* An audit that tabulates
`def:frame`'s constraints against their Lean transcriptions has four rows there, and this theorem
says no reading of the other three yields the fourth, so those four rows are irreducible.

**What this does not license.** Any claim whatever about the *definitional* audit surface. The
number of Lean **definitions** a human must read against the paper's text is a different quantity
from the number of **clauses** in one axiom list, and this theorem bounds only the second. Ten
supporting definitions stand behind the four clauses — the fibre and segment vocabulary
(`TaskFrame.Fib`, `Seg`, `cone`, `IsFiber`, `IsSegment`, `DirectedFamily`, and the constraint
predicates themselves) — and they are named rather than inlined on purpose, so they are read
individually and counted individually. Conflating the clause count with the definition count is the
specific error `docs/reference/transcription-audit-surface.md` exists to prevent; that document
states the definitional residue as a count and keeps the two surfaces apart throughout.

Paper: `def:frame`
-/
theorem constraints_pairwise_independent :
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Compositional R ∧ TaskFrame.Limit R ∧ TaskFrame.Saturation R ∧
          ¬ TaskFrame.Serial R) ∧
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Compositional R ∧ TaskFrame.Serial R ∧ TaskFrame.Saturation R ∧
          ¬ TaskFrame.Limit R) ∧
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Compositional R ∧ TaskFrame.Serial R ∧ TaskFrame.Limit R ∧
          ¬ TaskFrame.Saturation R) ∧
    (∃ (W : Type) (R : W → ℤ → W → Prop),
        TaskFrame.Serial R ∧ TaskFrame.Limit R ∧ TaskFrame.Saturation R ∧
          ¬ TaskFrame.Compositional R) :=
  ⟨⟨Bool, emptyRel, emptyRel_compositional, emptyRel_limit, emptyRel_saturation,
      emptyRel_not_serial⟩,
   ⟨Bool, totalRel, totalRel_compositional, totalRel_serial, totalRel_saturation,
      totalRel_not_limit⟩,
   ⟨ℤ, rayRel, rayRel_compositional, rayRel_serial, rayRel_limit, rayRel_not_saturation⟩,
   ⟨ℤ, driftRel, driftRel_serial, driftRel_limit, driftRel_saturation,
      driftRel_not_compositional⟩⟩

end FrameConstraintIndependence

end FormalSystem.Semantics
