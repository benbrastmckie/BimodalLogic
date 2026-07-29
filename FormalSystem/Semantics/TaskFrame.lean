/-
Copyright (c) 2025 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Fintype.Basic

/-!
# TaskFrame - Task Frame Structure for TM Semantics

This module defines task frames, the fundamental semantic structures for bimodal logic TM.

## Paper Specification Reference

**Task Frames (app:TaskSemantics, def:frame, possible_worlds.tex:2423-2451)**:
The JPL paper "The Perpetuity Calculus of Agency" defines a frame as a structure
`F = ⟨W, D, ⇒⟩` where:
- `W` is a **nonempty** set of world states
- `D = ⟨D, +, 0, ≤⟩` is a **nontrivial** totally ordered abelian group of durations
- `⇒ ⊆ W × D⁺ × W` is a task relation on the **positive cone** `D⁺ = {x ∈ D : 0 ≤ x}`,
  extended to negative durations by the **converse convention** `w ⇒_x u := u ⇒_{-x} w`
  for `x < 0`, and determining for each `w` and each `x > 0` the **cone**
  `(w)_x = {u : w ⇒_y u for some |y| < x}` over the extended relation, subject to:
  - *Nullity*: `w ⇒_0 u` if and only if `w = u`.
  - *Compositionality*: if `w ⇒_x u` and `u ⇒_y v` then `w ⇒_{x + y} v` (on `D⁺`).
  - *Limit Nullity*: `⋂_{x > 0} (w)_x = {w}`.

**ProofChecker Implementation**:
This implementation generalizes the time group to any type `D` with an
ordered additive commutative group structure, which provides:
- Additive abelian group structure (zero, addition, inverse)
- Total linear order (≤ relation)
- Order compatibility with addition

This allows for various temporal structures:
- `Int`: Discrete integer time (standard temporal logic)
- `Rat`: Dense rational time (for fine-grained temporal reasoning)
- `Real`: Continuous real time (for physical systems)
- Custom bounded or modular time structures

**Alignment Verification** — this module *agrees* with the paper's official presentation:
- Paper's *Nullity* is an iff, and `nullity_identity : TaskRel w 0 u ↔ w = u` is an exact match.
- Paper's *Compositionality* on the positive cone is `forward_comp`, whose `0 ≤ x` and `0 ≤ y`
  hypotheses are how the paper's domain restriction is expressed against a two-sided relation.
  The law is the **lax** one (`R_{x + y} ⊇ R_x ∘ R_y`); the inclusion replaces the usual
  equality, which would additionally assert interpolation and is **not** adopted
  (possible_worlds.tex:964, which calls the positive-cone presentation "its official form").
- The two-sided `TaskRel` together with the `converse` field **is** the paper's extended
  relation over a primitive relation living on the positive cone. `converse` packages the
  paper's definitional converse convention as structure data; it is not an extra
  temporal-symmetry axiom.
- Reflection (`nullity`) and backward composition (`backward_comp`) are **derived** here,
  matching their derived status in the paper (possible_worlds.tex:954-959).
- Mixed-sign composition is not so much prohibited as **inexpressible at the primitive level**,
  since primitive durations are nonnegative. Were it extended across mixed signs, *Nullity*
  would collapse nondeterminism: `w ⇒_x u` and `w ⇒_x u'` give `u ⇒_{-x} w` by the converse
  convention, whence `u ⇒_0 u'` and so `u = u'` (possible_worlds.tex:957-959).
- The ordered additive group structure provides the required abelian group with total order.

**Known gaps relative to the paper** (stated plainly rather than silently repaired):
- The paper requires `W` nonempty; the structure carries no `Nonempty WorldState` field.
- The paper requires `D` nontrivial; `[Nontrivial D]` is not among the structure's binders and
  is supplied ad hoc at the sites that need it.
- *Limit Nullity* is the one paper clause still absent from the structure. Its intended
  transcription against the extended relation is
  `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskRel w y u) → u = w`; the `⊇` half of the paper's
  equality is `nullity` plus cone monotonicity and needs no field.

## Main Definitions

- `TaskFrame D`: Structure with world states, times of type `D`, task relation, and constraints
- `TaskFrame.nullity_identity`: Zero duration iff identity (`TaskRel w 0 u ↔ w = u`)
- `TaskFrame.forward_comp`: Lax positive-cone compositionality (`0 ≤ x`, `0 ≤ y`)
- `TaskFrame.converse`: The definitional converse convention (`TaskRel w d u ↔ TaskRel u (-d) w`)
- `TaskFrame.nullity`: Derived reflexivity theorem (`TaskRel w 0 w`)

## Main Results

- Example task frames for testing and demonstrations (polymorphic over time type)

## Implementation Notes

- Type parameter `D` represents temporal duration with ordered additive group structure
- Task relation `TaskRel w x u` means: world state `u` is reachable from `w` by task
  of duration `x`
- Nullity: zero-duration task is identity, stated as an iff
- Compositionality: sequential tasks compose on the positive cone (lax law, no interpolation)
- Typeclass parameter convention: `(D : Type*)` explicit, ordered group instances implicit

## References

* [architecture.md](../../../docs/user-guide/architecture.md) - Task semantics specification
* JPL Paper app:TaskSemantics (def:frame, possible_worlds.tex:2423-2451) - Formal task frame
  definition; the body statement is at possible_worlds.tex:908-926 with gloss at 932
-/

namespace FormalSystem.Semantics

/--
Task frame for bimodal logic TM.

A task frame consists of:
- A type of world states
- A type `D` of temporal durations with ordered additive group structure
- A task relation connecting world states via timed tasks
- Nullity identity: zero-duration task iff identity (w = u)
- Forward compositionality: tasks compose on the positive cone
- Converse: the definitional converse convention, `TaskRel w d u ↔ TaskRel u (-d) w`

The task relation `TaskRel w x u` means: starting from world state `w`,
executing a task of duration `x` can result in world state `u`.

**Type Parameters**:
- `D`: Temporal duration type with totally ordered abelian group structure

**Paper Alignment**: Matches JPL paper def:frame (possible_worlds.tex:2423-2451) on three of
its four clauses — iff-*Nullity*, the lax positive-cone *Compositionality*, and the converse
convention. *Limit Nullity* is not yet carried as a field; see the module docstring's
"Known gaps" list for its intended transcription.

**Axiomatization Notes**:
The paper's own presentation takes the primitive task relation to live on the positive cone
`D⁺ = {x : 0 ≤ x}` and extends it to negative durations by the converse convention. This
structure is that presentation: the two-sided `TaskRel` is the *extended* relation, `converse`
is the convention that defines it from the primitive one, and `forward_comp`'s `0 ≤ x`, `0 ≤ y`
hypotheses confine composition to the primitive domain. The paper calls this positive-cone form
"not merely equivalent to the definition above but its official form" and states the law as the
**lax** inclusion `R_{x + y} ⊇ R_x ∘ R_y`, the inclusion replacing an equality that would
additionally assert interpolation (possible_worlds.tex:964).

Consequently *Reflection* and backward composition are derived rather than postulated here
(`nullity`, `backward_comp`), exactly as in the paper, and mixed-sign composition is not
prohibited but inexpressible at the primitive level, since primitive durations are nonnegative.
The paper gives the same nondeterminism-collapse argument for why it must stay that way: from
`w ⇒_x u` and `w ⇒_x u'` the converse convention yields `u ⇒_{-x} w`, so mixed-sign composition
would give `u ⇒_0 u'` and hence `u = u'` (possible_worlds.tex:957-959).

This block previously recorded a divergence from the paper. There is none: the paper has since
adopted the same positive-cone presentation, and the agreement is recorded here instead.
-/
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- Type of world states -/
  WorldState : Type
  /-- Task relation: `TaskRel w x u` means u is reachable from w by task of duration x -/
  TaskRel : WorldState → D → WorldState → Prop
  /--
  Nullity identity constraint: zero-duration task relates exactly identical states.

  For any world states `w` and `u`, `TaskRel w 0 u` holds iff `w = u`.
  This is stronger than just reflexivity: it says zero duration means no change.
  -/
  nullity_identity : ∀ w u, TaskRel w 0 u ↔ w = u
  /--
  Compositionality on the positive cone: tasks compose for non-negative durations.

  If task of duration `x ≥ 0` takes `w` to `u`, and task of duration `y ≥ 0` takes `u` to `v`,
  then task of duration `x + y` takes `w` to `v`.

  The paper states *Compositionality* proviso-free, but on a primitive relation that already
  lives on the positive cone `D⁺`; the `0 ≤ x`, `0 ≤ y` hypotheses are how that domain
  restriction is expressed against the two-sided extended relation. The law is the **lax**
  inclusion `R_{x + y} ⊇ R_x ∘ R_y`: an equality would additionally assert interpolation and is
  not adopted. Composition over negative durations is derived (`backward_comp`); mixed-sign
  composition is inexpressible at the primitive level rather than prohibited.
  -/
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → TaskRel w x u → TaskRel u y v → TaskRel w (x + y) v
  /--
  The paper's **definitional converse convention**, packaged as structure data.

  `TaskRel w d u` holds iff `TaskRel u (-d) w` holds.

  This is *not* a substantive temporal-symmetry axiom. The paper's primitive task relation
  lives on the positive cone `D⁺ = {x : 0 ≤ x}` and is extended to negative durations by
  stipulating `w ⇒_x u := u ⇒_{-x} w` for `x < 0` (possible_worlds.tex:2423-2451). A two-sided
  Lean relation cannot carry that stipulation in its type, so it is carried as this field: the
  pair (two-sided `TaskRel`, `converse`) is precisely the paper's *extended* relation over a
  primitive relation on `D⁺`, and it constrains the negative half of `TaskRel` to be exactly
  the reflection of the positive half rather than adding independent content.
  -/
  converse : ∀ w d u, TaskRel w d u ↔ TaskRel u (-d) w

namespace TaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Derived nullity: zero-duration task is reflexive.

This follows from `nullity_identity`: `TaskRel w 0 w` iff `w = w`, and `w = w` is trivial.
-/
theorem nullity (F : TaskFrame D) (w : F.WorldState) : F.TaskRel w 0 w :=
  F.nullity_identity w w |>.mpr rfl

/--
Derived backward compositionality: tasks compose in the backward direction.

From `forward_comp` and `converse`, we can derive compositionality for non-positive durations.
If `TaskRel w x u` with `x ≤ 0` and `TaskRel u y v` with `y ≤ 0`,
then `TaskRel w (x + y) v`.
-/
theorem backward_comp (F : TaskFrame D) (w u v : F.WorldState) (x y : D)
    (hx : x ≤ 0) (hy : y ≤ 0)
    (h1 : F.TaskRel w x u) (h2 : F.TaskRel u y v) :
    F.TaskRel w (x + y) v := by
  -- Use converse to flip directions, then forward_comp, then converse back
  -- TaskRel w x u <-> TaskRel u (-x) w, where -x >= 0
  -- TaskRel u y v <-> TaskRel v (-y) u, where -y >= 0
  have h1' : F.TaskRel u (-x) w := F.converse w x u |>.mp h1
  have h2' : F.TaskRel v (-y) u := F.converse u y v |>.mp h2
  have hx' : 0 ≤ -x := neg_nonneg.mpr hx
  have hy' : 0 ≤ -y := neg_nonneg.mpr hy
  -- forward_comp v u w (-y) (-x): TaskRel v (-y) u -> TaskRel u (-x) w -> TaskRel v (-y + -x) w
  have h3 : F.TaskRel v ((-y) + (-x)) w := F.forward_comp v u w (-y) (-x) hy' hx' h2' h1'
  -- Now use converse: TaskRel v (-(x+y)) w <-> TaskRel w (x+y) v
  have h4 : -y + -x = -(x + y) := by simp [neg_add_rev, add_comm]
  rw [h4] at h3
  exact F.converse w (x + y) v |>.mpr h3

/--
Simple unit-based task frame for testing.

World states are Unit (trivial), task relation is always true.
This is the simplest possible task frame, polymorphic over temporal type `D`.
-/
def trivialFrame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := Unit
  TaskRel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  forward_comp := fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩

/--
Identity task frame: task relation is identity.

World states can be any type, task relation holds iff source equals target and time is 0.
Polymorphic over both world state type and temporal type.
-/
def identityFrame (W : Type) {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := W
  TaskRel := fun w x u => w = u ∧ x = 0
  nullity_identity := fun w u => by
    constructor
    · intro ⟨h1, _⟩; exact h1
    · intro h; exact ⟨h, rfl⟩
  forward_comp := by
    intros w u v x y _ _ hwu huv
    obtain ⟨h1, h2⟩ := hwu
    obtain ⟨h3, h4⟩ := huv
    subst h1 h3
    simp [h2, h4]
  converse := fun w d u => by
    constructor
    · intro ⟨h1, h2⟩
      subst h1 h2
      simp
    · intro ⟨h1, h2⟩
      constructor
      · exact h1.symm
      · exact neg_eq_zero.mp h2

/--
Natural number based task frame.

World states are natural numbers. Task relation: `TaskRel w d u` holds iff
either `d ≠ 0` (any transition for non-zero duration) or `w = u` (identity for zero duration).
This satisfies nullity_identity while remaining permissive.
Polymorphic over temporal type `D`.
-/
def natFrame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := Nat
  TaskRel := fun w d u => d ≠ 0 ∨ w = u
  nullity_identity := fun w u => by
    constructor
    · intro h
      cases h with
      | inl h => exact absurd rfl h
      | inr h => exact h
    · intro h
      right; exact h
  forward_comp := fun w u v x y hx hy h1 h2 => by
    -- Need: x + y ≠ 0 ∨ w = v
    -- Key fact: if 0 ≤ x and 0 ≤ y and x + y = 0, then x = 0 and y = 0
    cases h1 with
    | inl hxne =>
      -- x ≠ 0 but 0 ≤ x, so x > 0. If x + y = 0 then y = -x < 0, contradicting 0 ≤ y
      left
      intro heq
      -- From x + y = 0: y = -x
      have hy_eq : y = -x := (neg_eq_of_add_eq_zero_right heq).symm
      have h1 : 0 ≤ -x := hy_eq ▸ hy
      have h2 : x ≤ 0 := neg_nonneg.mp h1
      have h3 : x = 0 := le_antisymm h2 hx
      exact hxne h3
    | inr hw =>
      cases h2 with
      | inl hyne =>
        left
        intro heq
        -- From x + y = 0: x = -y
        have hx_eq : x = -y := (neg_eq_of_add_eq_zero_left heq).symm
        have h1 : 0 ≤ -y := hx_eq ▸ hx
        have h2 : y ≤ 0 := neg_nonneg.mp h1
        have h3 : y = 0 := le_antisymm h2 hy
        exact hyne h3
      | inr hu => right; exact hw.trans hu
  converse := fun w d u => by
    constructor
    · intro h
      cases h with
      | inl hd => left; simp [hd]
      | inr heq => right; exact heq.symm
    · intro h
      cases h with
      | inl hnd => left; simp only [ne_eq, neg_eq_zero] at hnd; exact hnd
      | inr heq => right; exact heq.symm

end TaskFrame

/-!
# Finite Task Frames and Models

This section extends task frames with explicit finiteness constraints.
These structures bundle the finiteness property for convenience in stating
the Finite Model Property for TM logic.
-/

open TaskFrame

/--
A task frame with finitely many world states.

This structure extends the basic `TaskFrame` with an explicit proof
that the set of world states is finite. This is useful for stating
the Finite Model Property and related results.

**Type Parameters**:
- `D`: Temporal duration type with ordered additive group structure

**Usage**: Used to package finite model constructions like `SemanticCanonicalFrame`
into a standard format for the Finite Model Property.
-/
structure FiniteTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    extends TaskFrame D where
  /-- Proof that the set of world states is finite -/
  finite_world : Finite WorldState

namespace FiniteTaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Coercion from a finite task frame to its underlying task frame.
This allows seamless use of existing definitions and theorems.
-/
instance : Coe (FiniteTaskFrame D) (TaskFrame D) where
  coe F := F.toTaskFrame

end FiniteTaskFrame

end FormalSystem.Semantics
