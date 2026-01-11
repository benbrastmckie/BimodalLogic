import Logos.Foundation
import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Algebra.Order.Group.OrderIso

/-!
# Core Frame - Task Relation Extension

This module extends the Constitutive Frame with temporal structure and a task
relation, enabling evaluation of truth relative to world-histories and times.

## Paper Specification Reference

**Core Frame Extension (RECURSIVE_SEMANTICS.md)**:
The Core Extension extends the Constitutive Foundation with:
- Temporal Order: D = ⟨D, +, ≤⟩ is a totally ordered abelian group
- Task Relation: ⇒ is a ternary relation on S × D × S satisfying constraints

## Main Definitions

- `CoreFrame`: Frame with temporal order and task relation
- State modality concepts: possible, compatible, maximal, world-state
- `WorldHistory`: Function assigning world-states to times

## Implementation Notes

The task relation s ⇒_d t represents "there is a task from s to t of duration d".
All constraints are formulated using state modality concepts.
-/

namespace Logos.Core

open Logos.Foundation

variable {T : Type*} [LinearOrderedAddCommGroup T]

/--
A Core Frame extends a Constitutive Frame with temporal structure and a task relation.

The task relation `s ⇒_d t` (taskRel s d t) means "there is a task from state s
to state t of duration d".
-/
structure CoreFrame (T : Type*) [LinearOrderedAddCommGroup T] extends ConstitutiveFrame where
  /-- The task relation: taskRel s d t means s ⇒_d t -/
  taskRel : State → T → State → Prop
  /-- Nullity: every state has a trivial task to itself -/
  nullity : ∀ s : State, taskRel s 0 s
  /-- Compositionality: If s ⇒_x t and t ⇒_y u, then s ⇒_{x+y} u -/
  compositionality : ∀ s t u : State, ∀ x y : T,
    taskRel s x t → taskRel t y u → taskRel s (x + y) u
  /-- Parthood Left: If d ⊑ s and s ⇒_x t, then d ⇒_x r for some r ⊑ t -/
  parthood_left : ∀ d s t : State, ∀ x : T,
    toConstitutiveFrame.parthood d s → taskRel s x t →
    ∃ r, toConstitutiveFrame.parthood r t ∧ taskRel d x r
  /-- Parthood Right: If r ⊑ t and s ⇒_x t, then d ⇒_x r for some d ⊑ s -/
  parthood_right : ∀ r s t : State, ∀ x : T,
    toConstitutiveFrame.parthood r t → taskRel s x t →
    ∃ d, toConstitutiveFrame.parthood d s ∧ taskRel d x r
  /-- Containment Left: If s ∈ P, d ⊑ s, and d ⇒_x r, then s ⇒_x t.r for some t -/
  containment_left : ∀ d r s : State, ∀ x : T,
    taskRel s 0 s →  -- s is possible
    toConstitutiveFrame.parthood d s →
    taskRel d x r →
    ∃ t, taskRel s x (toConstitutiveFrame.fusion t r)
  /-- Containment Right: If t ∈ P, r ⊑ t, and d ⇒_x r, then s.d ⇒_x t for some s -/
  containment_right : ∀ d r t : State, ∀ x : T,
    taskRel t 0 t →  -- t is possible
    toConstitutiveFrame.parthood r t →
    taskRel d x r →
    ∃ s, taskRel (toConstitutiveFrame.fusion s d) x t

namespace CoreFrame

variable {F : CoreFrame T}

/-! ### State Modality Definitions -/

/--
A state is *possible* if it has a trivial task to itself: s ⇒_0 s
-/
def possible (s : F.State) : Prop := F.taskRel s 0 s

/--
A state is *impossible* if it does not have a trivial task to itself.
-/
def impossible (s : F.State) : Prop := ¬possible s

/--
Two states are *connected* if there is a task between them in either direction.
-/
def connected (s t : F.State) : Prop :=
  ∃ d : T, F.taskRel s d t ∨ F.taskRel t d s

/--
Two states are *compatible* if their fusion is possible: s.t ∈ P
-/
def compatible (s t : F.State) : Prop :=
  possible (F.toConstitutiveFrame.fusion s t)

/--
A state s is a *maximal t-compatible part* of r if:
- s ⊑ r (s is a part of r)
- s ∘ t (s is compatible with t)
- For all s' where s ⊑ s' ⊑ r and s' ∘ t, we have s' ⊑ s

This captures the largest part of r that is compatible with t.
-/
def maximal_t_compatible (s t r : F.State) : Prop :=
  F.toConstitutiveFrame.parthood s r ∧
  compatible s t ∧
  ∀ s' : F.State,
    F.toConstitutiveFrame.parthood s s' →
    F.toConstitutiveFrame.parthood s' r →
    compatible s' t →
    F.toConstitutiveFrame.parthood s' s

/--
A state s is *maximal* if every compatible state is a part of s.
-/
def maximal (s : F.State) : Prop :=
  ∀ t : F.State, compatible t s → F.toConstitutiveFrame.parthood t s

/--
A state w is a *world-state* if it is a maximal possible state.
-/
def world_state (w : F.State) : Prop :=
  possible w ∧ maximal w

/--
A state s is *necessary* if s ~ t implies s = t for all t.
(Connected to exactly itself.)
-/
def necessary (s : F.State) : Prop :=
  ∀ t : F.State, connected s t → s = t

/-! ### Basic Theorems -/

/--
Every state is connected to itself (via nullity).
-/
theorem self_connected (s : F.State) : connected s s := by
  use 0
  left
  exact F.nullity s

/--
If s is possible, s is compatible with itself.
-/
theorem possible_self_compatible (s : F.State) (hp : possible s) : compatible s s := by
  unfold compatible possible at *
  -- s.s = s by idempotence, so we need to show taskRel (s.s) 0 (s.s)
  -- This requires showing s ⊔ s = s
  simp only [ConstitutiveFrame.fusion]
  have h : s ⊔ s = s := @sup_idem _ _ s
  rw [h]
  exact hp

/--
The null state is possible (by nullity).
-/
theorem null_possible : possible (F.toConstitutiveFrame.null : F.State) := by
  exact F.nullity F.toConstitutiveFrame.null

end CoreFrame

/-! ### World-History -/

/--
A convex subset of the temporal order.
-/
structure Convex (X : Set T) : Prop where
  convex : ∀ x y z : T, x ∈ X → z ∈ X → x ≤ y → y ≤ z → y ∈ X

/--
A *world-history* over a core frame F is a function τ : X → W where:
- X ⊆ D is a convex subset of the temporal order
- τ(x) is a world-state for each x ∈ X
- τ(x) ⇒_{y-x} τ(y) for all times x, y ∈ X where x ≤ y
-/
structure WorldHistory (F : CoreFrame T) where
  /-- The domain of the world-history (a convex subset of T) -/
  domain : Set T
  /-- The domain is convex -/
  domain_convex : Convex domain
  /-- The state assignment function -/
  states : (t : T) → t ∈ domain → F.State
  /-- Each assigned state is a world-state -/
  world_states : ∀ t (ht : t ∈ domain), CoreFrame.world_state (states t ht)
  /-- The task relation is respected -/
  task_respecting : ∀ x y (hx : x ∈ domain) (hy : y ∈ domain),
    x ≤ y → F.taskRel (states x hx) (y - x) (states y hy)

namespace WorldHistory

variable {F : CoreFrame T}

/--
The set of all world-histories over a core frame.
-/
def AllHistories (F : CoreFrame T) : Set (WorldHistory F) := Set.univ

/--
Get the state at a time (if in domain).
-/
def stateAt (τ : WorldHistory F) (t : T) (ht : t ∈ τ.domain) : F.State :=
  τ.states t ht

/--
Check if two world-histories agree on overlapping times.
-/
def agrees (τ₁ τ₂ : WorldHistory F) : Prop :=
  ∀ t (h₁ : t ∈ τ₁.domain) (h₂ : t ∈ τ₂.domain),
    τ₁.states t h₁ = τ₂.states t h₂

end WorldHistory

/-! ### Core Model -/

/--
A *core model* combines a core frame with an interpretation.
-/
structure CoreModel (T : Type*) [LinearOrderedAddCommGroup T] where
  /-- The underlying core frame -/
  frame : CoreFrame T
  /-- The interpretation function (inherited from constitutive model) -/
  interp : Interpretation frame.toConstitutiveFrame

end Logos.Core
