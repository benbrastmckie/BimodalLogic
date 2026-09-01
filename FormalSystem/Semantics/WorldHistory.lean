/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.PartialHistory

/-!
# WorldHistory - World Histories for Task Semantics

This module defines world histories, which are functions from time domains to world states.

## Paper Specification Reference

**World Histories (`def:world-history`)**:
The JPL paper's layering, quoted verbatim: "A \textit{partial history} over a frame
$\F = \tuple{W, \D, \Rightarrow}$ is a function $\tau : X \to W$ on a nonempty set
$X \subseteq D$ where $\tau(x) \Rightarrow_{y-x} \tau(y)$ for all times $x, y \in X$. A
\textit{world history} is any partial history whose domain $X$ is \textit{convex}, so that
$y \in X$ whenever $x, z \in X$ and $x < y < z$. A world history is \textit{total}---
equivalently, a \textit{possible world}--- just in case $X = D$."

**ProofChecker Implementation**:
- `WorldHistory F` **extends** `PartialHistory F` (`FormalSystem/Semantics/PartialHistory.lean`),
  adding exactly one field: `convex`. This is the paper's layering, read as written — "a world
  history is any partial history whose domain `X` is convex".
- `domain: D → Prop` (inherited) represents the time subset `X ⊆ D`
- `nonempty_domain` (inherited) is the paper's requirement that `X` be *nonempty*
- `states: (t: D) → domain t → F.WorldState` (inherited) represents the function `τ: X → W`
- `respects_task` (inherited) is stated **unconditionally**, per the paper's own note that
  negative-difference instances are covered by the converse convention; the guarded form is
  available as `PartialHistory.respects_task_le`
- `convex` field enforces the paper's convexity requirement explicitly

**Two gaps this module used to record are now closed.** The nonemptiness field and the
`PartialHistory` layer both live in `PartialHistory.lean`, and `WorldHistory` inherits them. The
layering decision (why `extends` rather than a standalone structure or an `IsConvex` mixin, and
why nonemptiness is a field rather than a side hypothesis) is recorded in
`specs/decisions/total-history-validity-decisions.md`, Decision B.

**Convexity Requirement**: A domain is convex if whenever `x, z ∈ domain` with `x ≤ z`,
then all times `y` with `x ≤ y ≤ z` are also in the domain. This ensures histories
have no "gaps" in time.

**Critical Semantic Points**:
1. Box operator quantifies over ALL histories at time x
2. Past/Future operators quantify over times in the SAME history
3. Times must be in history's domain for evaluation
4. Domains must be convex (no temporal gaps)

## Main Definitions

- `WorldHistory F`: World history structure with convex domain and task constraint

## Main Results

- Example world histories (constant, trivial, universal) with convexity proofs
- Time-shift construction preserving convexity

## Implementation Notes

- Type parameter `D` represents temporal durations with ordered additive group structure
- Domain is represented as a predicate `D → Prop`
- Convexity is now formally enforced (matching paper definition exactly)
- History must respect the task relation (compositionality)

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - World history specification
* [TaskFrame.lean](TaskFrame.lean) - Task frame structure
* JPL Paper anchor `def:world-history` — cited by `\label` anchor with the verbatim quote
  above, never by raw line number
-/

namespace FormalSystem.Semantics

/--
World history for a task frame.

A world history assigns a world state to each time in its domain,
such that the history respects the task relation of the frame.

**Type Parameters**:
- `D`: Temporal duration type with totally ordered abelian group structure
- `F`: Task frame over temporal type `D`

**Paper Alignment**: matches the paper's `def:world-history` (see the module docstring for the
verbatim quote), which defines a world history as *any partial history whose domain is convex*.
This structure is exactly that: it `extends PartialHistory F` — inheriting `domain`,
`nonempty_domain`, `states`, and the unconditional `respects_task` — and adds the single
`convex` field.

Two gaps this docstring used to record are closed by the re-basing: the nonemptiness field now
exists (so the empty history is no longer a legal Lean `WorldHistory`), and the `PartialHistory`
layer exists as its own structure, since the paper's partial history requires nonemptiness
WITHOUT convexity and therefore cannot be carved out by weakening this one.
-/
structure WorldHistory (F :
      TaskFrame) extends PartialHistory F where
  /--
  Convexity constraint: domain has no temporal gaps.

  If times `x` and `z` are in the domain with `x ≤ z`, then every time `y`
  between them (`x ≤ y ≤ z`) must also be in the domain.

  **Paper Reference**: `def:world-history` (verbatim: "A \textit{world history} is any
  partial history whose domain $X$ is \textit{convex}, so that $y \in X$ whenever
  $x, z \in X$ and $x < y < z$.").
  -/
  convex : ∀ (x z : F.Duration), domain x → domain z → ∀ (y : F.Duration), x ≤ y → y ≤ z → domain y

namespace WorldHistory

variable {F : TaskFrame}

/--
Universal world history over all time (requires explicit reflexivity proof).

This history has every time in its domain and assigns the same world state everywhere.

**Frame Constraint Required**: Reflexivity proof parameter

A frame is reflexive if for all world states `w` and durations `d`, the task relation
`TaskRel w d w` holds. This is stronger than nullity (which only requires `TaskRel w 0 w`).

**Examples of Reflexive Frames**:
- `trivialFrame`: TaskRel is always True (reflexive)
- `natFrame`: TaskRel is `d ≠ 0 ∨ w = u` (reflexive via the right disjunct)
- `staticFrame`: TaskRel is `w = u` at every duration (reflexive)

**Non-Reflexive Frame Example**:
- A frame whose TaskRel holds only at duration 0 (e.g. `fun w x u => w = u ∧ x = 0`) is not
  reflexive for `d ≠ 0`. The library's former identity frame was such a frame; it violated the
  paper's *Seriality* axiom (`def:frame#Seriality`) and was replaced by the reflexive
  `staticFrame`.

**Justification**: For a constant history to respect the task relation, we need
`TaskRel w (t - s) w` for all times `s ≤ t`. Nullity only gives this when `s = t`.
Compositionality alone cannot build arbitrary-duration self-loops without additional
frame properties.

**Usage**: Call this function with a proof that `∀ d, F.TaskRel w d w`. For common frames,
use the frame-specific constructors `universalTrivialFrame` or `universalNatFrame` instead.

**Parameters**:
- `F`: The task frame
- `w`: The constant world state for all times
- `h_refl`: Proof that the frame is reflexive at state `w` for all durations
-/
def universal (F : TaskFrame) (w : F.WorldState)
    (h_refl : ∀ d : F.Duration, F.TaskRel w d w) : WorldHistory F where
  domain := fun _ => True
  nonempty_domain := ⟨0, True.intro⟩
  convex := by
    intros x z hx hz y hxy hyz
    -- Full domain is trivially convex
    exact True.intro
  states := fun _ _ => w
  respects_task := by
    intros s t hs ht
    -- Use the reflexivity proof for duration (t - s)
    exact h_refl (t - s)

/--
Trivial world history for the trivial frame.

Since trivial frame's task relation is always true, this always works.
The full domain is convex.
-/
def trivial {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D] :
    WorldHistory (FrameOver.trivialFrame (D := D)) where
  domain := fun _ => True
  nonempty_domain := ⟨0, True.intro⟩
  convex := by
    intros x z hx hz y hxy hyz
    exact True.intro
  states := fun _ _ => ()
  respects_task := by
    intros s t hs ht
    exact True.intro

/--
Universal world history for trivial frame with a specific constant state.

This is a variant of `trivial` that allows specifying the constant state
(though in trivialFrame, WorldState = Unit, so this is equivalent to `trivial`).

Since trivialFrame's task relation is always true, any constant history respects the task relation.
The full domain is convex.
-/
def universalTrivialFrame {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
    (w : (FrameOver.trivialFrame (D := D)).WorldState) :
    WorldHistory (FrameOver.trivialFrame (D := D)) where
  domain := fun _ => True
  nonempty_domain := ⟨0, True.intro⟩
  convex := by
    intros x z hx hz y hxy hyz
    exact True.intro
  states := fun _ _ => w
  respects_task := by
    intros s t hs ht
    exact True.intro

/--
Universal world history for nat frame with a specific constant Nat state.

Since natFrame's task relation is `d ≠ 0 ∨ w = u`, a constant history with state `n`
satisfies `respects_task` because `n = n` holds (right disjunct).

This demonstrates that frames with `nullity_identity` admit constant histories
as long as zero-duration relates identical states. The full domain is convex.
-/
def universalNatFrame {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]
      [SuccOrder D] [NoMaxOrder D] (n : Nat) :
    WorldHistory (FrameOver.natFrame (D := D)) where
  domain := fun _ => True
  nonempty_domain := ⟨0, True.intro⟩
  convex := by
    intros x z hx hz y hxy hyz
    exact True.intro
  states := fun _ _ => n
  respects_task := by
    intros s t hs ht
    -- natFrame.TaskRel is d ≠ 0 ∨ w = u
    -- Since states s = states t = n, we have n = n
    right
    rfl

/--
Get the state at a time (helper function that bundles membership proof).
-/
def stateAt (τ : WorldHistory F) (t : F.Duration) (h : τ.domain t) : F.WorldState :=
  τ.states t h

/-! ## Time-Shift Construction

The time-shift construction is fundamental to proving MF and TF axioms.
Given a history σ and times x, y, we construct a shifted history where
σ'(z) = σ(z + (y - x)).

This corresponds to "viewing σ from time x instead of time y".
-/

/--
Time-shifted history construction.

Given history `σ` and shift offset `Δ = y - x`, construct history `τ` where:
- `τ.domain z ↔ σ.domain (z + Δ)`
- `τ.states z = σ.states (z + Δ)`

This allows us to relate truth at (σ, y) to truth at (τ, x).

**Paper Reference**: app:auto_existence (line ~2330) defines time-shift automorphisms.

**Key Property**: If σ respects the task relation and has convex domain,
so does the shifted history, because:
1. Task relation only depends on duration (t - s), preserved under translation
2. Convexity is preserved under translation by group structure
-/
def timeShift (σ : WorldHistory F) (Δ : F.Duration) : WorldHistory F where
  domain := fun z => σ.domain (z + Δ)
  nonempty_domain := by
    obtain ⟨t, ht⟩ := σ.nonempty_domain
    refine ⟨t - Δ, ?_⟩
    rwa [sub_add_cancel]
  convex := by
    intros x z hx hz y hxy hyz
    -- Need: σ.domain (y + Δ)
    -- Have: σ.domain (x + Δ) and σ.domain (z + Δ) with x ≤ y ≤ z
    -- By convexity of σ, need to show (x + Δ) ≤ (y + Δ) ≤ (z + Δ)
    have hxy' : x + Δ ≤ y + Δ := by rw [add_comm x, add_comm y]; exact add_le_add_right hxy Δ
    have hyz' : y + Δ ≤ z + Δ := by rw [add_comm y, add_comm z]; exact add_le_add_right hyz Δ
    exact σ.convex (x + Δ) (z + Δ) hx hz (y + Δ) hxy' hyz'
  states := fun z hz => σ.states (z + Δ) hz
  respects_task := by
    intros s t hs ht
    -- Need: TaskRel (σ.states (s + Δ)) (t - s) (σ.states (t + Δ))
    -- We have: σ respects task, so
    -- TaskRel (σ.states (s + Δ)) ((t + Δ) - (s + Δ)) (σ.states (t + Δ))
    -- Since (t + Δ) - (s + Δ) = t - s, this is exactly what we need.
    -- The unconditional `respects_task` needs no `s ≤ t` side condition, so the shifted
    -- inequality the guarded form required has been dropped.
    have h_duration : (t + Δ) - (s + Δ) = t - s := by
      -- (t + Δ) - (s + Δ) = t - s by group theory
      rw [add_sub_add_right_eq_sub]
    rw [← h_duration]
    exact σ.respects_task (s + Δ) (t + Δ) hs ht

/--
Time-shift preserves domain membership (forward direction).
If z is in the shifted domain, then z + Δ is in the original domain.
-/
theorem time_shift_domain_iff (σ : WorldHistory F) (Δ z : F.Duration) :
    (timeShift σ Δ).domain z ↔ σ.domain (z + Δ) := by
  rfl

/--
Inverse time-shift: shifting by -Δ undoes shifting by Δ on the domain.
-/
theorem time_shift_inverse_domain (σ : WorldHistory F) (Δ : F.Duration) (z : F.Duration) :
    (timeShift (timeShift σ Δ) (-Δ)).domain z ↔ σ.domain z := by
  simp only [timeShift]
  constructor
  · intro h
    have : z + -Δ + Δ = z := by
      rw [add_assoc, neg_add_cancel, add_zero]
    rw [this] at h
    exact h
  · intro h
    have : z + -Δ + Δ = z := by
      rw [add_assoc, neg_add_cancel, add_zero]
    rw [this]
    exact h

/--
States are equal when times are provably equal (proof irrelevance).

This lemma allows us to transport states from one time to another when the times
are equal. This is essential for dependent type reasoning in time-shift proofs.
-/
theorem states_eq_of_time_eq (σ : WorldHistory F) (t₁ t₂ : F.Duration)
    (h : t₁ = t₂) (ht₁ : σ.domain t₁) (ht₂ : σ.domain t₂) :
    σ.states t₁ ht₁ = σ.states t₂ ht₂ := by
  subst h
  rfl

/--
Double time-shift cancels: states at (timeShift (timeShift σ Δ) (-Δ)) equal states at σ.

This is the key transport lemma for the box case of time_shift_preserves_truth.
It shows that shifting by Δ and then by -Δ returns to the original states.
-/
theorem time_shift_time_shift_states (σ : WorldHistory F) (Δ : F.Duration) (t : F.Duration)
    (ht : σ.domain t)
    (ht' : (timeShift (timeShift σ Δ) (-Δ)).domain t) :
    (timeShift (timeShift σ Δ) (-Δ)).states t ht' = σ.states t ht := by
  simp only [timeShift]
  have h_eq : t + -Δ + Δ = t := by
    rw [add_assoc, neg_add_cancel, add_zero]
  exact states_eq_of_time_eq σ (t + -Δ + Δ) t h_eq _ ht

/--
Extensionality lemma for timeShift: shifting by equal amounts gives equal histories.
-/
theorem time_shift_congr (σ : WorldHistory F) (Δ₁ Δ₂ : F.Duration) (h : Δ₁ = Δ₂) :
    timeShift σ Δ₁ = timeShift σ Δ₂ := by
  subst h
  rfl

/--
Domain membership for timeShift by zero is equivalent to original domain.
-/
theorem time_shift_zero_domain_iff (σ : WorldHistory F) (z : F.Duration) :
    (timeShift σ 0).domain z ↔ σ.domain z := by
  simp only [timeShift, add_zero]

/--
Domain membership for double time-shift with opposite amounts equals original.
-/
theorem time_shift_time_shift_neg_domain_iff (σ : WorldHistory F) (Δ : F.Duration) (z : F.Duration) :
    (timeShift (timeShift σ Δ) (-Δ)).domain z ↔ σ.domain z := by
  simp only [timeShift]
  have h : z + -Δ + Δ = z := by
    rw [add_assoc, neg_add_cancel, add_zero]
  constructor
  · intro hd; rw [h] at hd; exact hd
  · intro hd; rw [h]; exact hd

/--
States at double time-shift with opposite amounts equals original states.
-/
theorem time_shift_time_shift_neg_states (σ : WorldHistory F) (Δ : F.Duration) (t : F.Duration)
    (ht : σ.domain t) (ht' : (timeShift (timeShift σ Δ) (-Δ)).domain t) :
    (timeShift (timeShift σ Δ) (-Δ)).states t ht' = σ.states t ht := by
  simp only [timeShift]
  have h_eq : t + -Δ + Δ = t := by
    rw [add_assoc, neg_add_cancel, add_zero]
  exact states_eq_of_time_eq σ (t + -Δ + Δ) t h_eq _ ht

/-! ## Order Reversal Lemmas

These lemmas establish that group inverse (negation) provides an order-reversing
automorphism on any ordered additive group. This is crucial for proving
temporal duality soundness: swapping past and future corresponds to time reversal
via group inverse.

The key insight is that ordered additive group structure provides temporal
symmetry without requiring additional frame constraints.
-/

/--
Group inverse reverses strict order: s < t ↔ -t < -s

This order reversal is the algebraic foundation for temporal duality.
When we swap Past and Future operators, the time domain reverses under group inverse.
-/
theorem neg_lt_neg_iff {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (s t : D) : s < t ↔ -t < -s := by
  constructor
  · intro h
    -- s < t implies -t < -s
    exact neg_lt_neg h
  · intro h
    -- -t < -s implies s < t
    -- Rewrite s and t as double negatives
    have hs : s = -(-s) := by simp
    have ht : t = -(-t) := by simp
    rw [hs, ht]
    exact neg_lt_neg h

/--
Group inverse reverses non-strict order: s ≤ t ↔ -t ≤ -s
-/
theorem neg_le_neg_iff {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (s t : D) : s ≤ t ↔ -t ≤ -s := by
  constructor
  · intro h
    exact neg_le_neg h
  · intro h
    have hs : s = -(-s) := by simp
    have ht : t = -(-t) := by simp
    rw [hs, ht]
    exact neg_le_neg h

/--
Double negation is identity: -(-t) = t
-/
theorem neg_neg_eq {D : Type} [AddCommGroup D] (t : D) : -(-t) = t := by
  simp

/--
Group inverse is injective: -s = -t ↔ s = t
-/
theorem neg_injective {D : Type} [AddCommGroup D] (s t : D) : -s = -t ↔ s = t := by
  constructor
  · intro h
    have : -(-s) = -(-t) := by rw [h]
    simp only [neg_neg] at this
    exact this
  · intro h
    rw [h]

/-! ## Totality and `H_F`

`def:world-history`, verbatim: "A world history is \textit{total}--- equivalently, a
\textit{possible world}--- just in case $X = D$. … The set of all total world histories over
$\F$ is denoted $H_{\F}$."

Totality is inherited from `PartialHistory.IsTotal`; `WorldHistory.IsTotal` below is the
`WorldHistory`-level spelling of the same predicate, not a second notion. `TaskFrame.HF` bundles
it as a type, per Decision A of `specs/decisions/total-history-validity-decisions.md`: the
predicate form is used wherever totality is a *hypothesis*, and the subtype form only where `H_F`
is quantified over as an *object* in its own right.
-/

/--
A world history is **total** — equivalently, a **possible world** — just in case its domain is
all of `D`.

**Paper Reference**: `def:world-history` (verbatim: "A world history is \textit{total}---
equivalently, a \textit{possible world}--- just in case $X = D$.").

This delegates to `PartialHistory.IsTotal`; it is a spelling, not a second predicate. It is
deliberately **not** Mathlib's `IsMax` or any order-theoretic maximality predicate — maximality
under the extension order is an internal step en route to the Extension Theorem, while totality
is what validity quantifies over.
-/
def IsTotal (τ : WorldHistory F) : Prop := τ.toPartialHistory.IsTotal

/-- `WorldHistory.IsTotal` unfolds to the pointwise domain condition. -/
theorem isTotal_iff (τ : WorldHistory F) : τ.IsTotal ↔ ∀ t : F.Duration, τ.domain t := Iff.rfl

/--
Totality is preserved by time shift.

The proof is `fun t => h (t + Δ)`: the shifted domain at `t` *is* the original domain at
`t + Δ`, definitionally, so a total original domain gives a total shifted domain with no
side condition whatsoever.

This is the lemma that carries the box case of time-shift preservation of truth. Under totality,
shift-preservation is strictly easier than it was under a designated shift-closed set of
admissible histories, because there is no closure condition left to carry.
-/
theorem isTotal_timeShift {σ : WorldHistory F} (h : σ.IsTotal) (Δ : F.Duration) :
    (σ.timeShift Δ).IsTotal :=
  fun t => h (t + Δ)

/-- A total world history's domain is nonempty (witness `0`), so `nonempty_domain` costs nothing
at a total construction site. -/
theorem total_nonempty {τ : WorldHistory F} (h : τ.IsTotal) : ∃ t : F.Duration, τ.domain t :=
  τ.toPartialHistory.total_nonempty h

end WorldHistory

/--
`H_F` — the set of all total world histories over a frame, bundled as a type.

**Paper Reference**: `def:world-history` (verbatim: "The set of all total world histories over
$\F$ is denoted $H_{\F}$.").

**Encoding note** (Decision A of `specs/decisions/total-history-validity-decisions.md`): this
subtype is used **only** where `H_F` appears as an object in its own right — the Extension
Theorem's conclusion, the Occurrence Corollary, and the optional frame-relative validity. Where
totality is a *hypothesis* (truth, validity, semantic consequence, satisfiability), the predicate
form `(τ : WorldHistory F) (hτ : τ.IsTotal)` is used instead.

This is **not** a parallel validity notion or an alias: there is exactly one validity predicate,
and `HF` is a bundled name for the same `IsTotal` predicate, bridged only by `.val` / `.property`.
-/
def TaskFrame.HF (F : TaskFrame) : Type _ :=
  {τ : WorldHistory F // τ.IsTotal}

namespace TaskFrame.HF

variable {F : TaskFrame}

/-- Time shift lifted to `H_F`, through `WorldHistory.isTotal_timeShift`. -/
def timeShift (τ : F.HF) (Δ : F.Duration) : F.HF :=
  ⟨τ.val.timeShift Δ, WorldHistory.isTotal_timeShift τ.property Δ⟩

@[simp]
theorem timeShift_val (τ : F.HF) (Δ : F.Duration) : (τ.timeShift Δ).val = τ.val.timeShift Δ := rfl

end TaskFrame.HF

/--
`H_F` at the **fibre**, so that `F.HF` resolves for a fibre-typed frame as well as for a
total-space one.

Generalized field notation resolves by the head constant of `F`'s type and never consults a
coercion, so both spellings have to exist wherever both are used. Note the direction of the
delegation: `WorldHistory` is declared over the total space, so `TaskFrame.HF` is the primitive
and this is the delegating spelling — the reverse of what the plan anticipated, and forced by the
existing layering rather than chosen.
-/
@[reducible] def FrameOver.HF {D : TemporalOrder} (F : FrameOver D) : Type _ :=
  F.toTaskFrame.HF

/-- The two spellings are the same type, definitionally. -/
example {D : TemporalOrder} (F : FrameOver D) : F.HF = F.toTaskFrame.HF := rfl


end FormalSystem.Semantics
