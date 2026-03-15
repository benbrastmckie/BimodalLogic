import Mathlib.Algebra.Order.Group.Defs
import Mathlib.Data.Fintype.Basic

/-!
# TaskFrame - Task Frame Structure for TM Semantics

This module defines task frames, the fundamental semantic structures for bimodal logic TM.

## Paper Specification Reference

**Task Frames (app:TaskSemantics, def:frame, line 1835)**:
The JPL paper "The Perpetuity Calculus of Agency" defines task frames as tuples
`F = (W, G, ·)` where:
- `W` is a set of world states
- `G` is a totally ordered abelian group `D = ⟨D, +, ≤⟩` of "time" elements (durations)
- `·: W × G → P(W)` is the task relation

**ProofChecker Implementation**:
This implementation generalizes the time group `G` to any type `D` with an
ordered additive commutative group structure, which provides:
- Additive abelian group structure (zero, addition, inverse)
- Total linear order (≤ relation)
- Order compatibility with addition

This matches the paper's specification exactly and allows for various temporal structures:
- `Int`: Discrete integer time (standard temporal logic)
- `Rat`: Dense rational time (for fine-grained temporal reasoning)
- `Real`: Continuous real time (for physical systems)
- Custom bounded or modular time structures

**Alignment Verification**:
- Paper's nullity: `w ∈ w · 0` corresponds to `nullity : ∀ w, task_rel w 0 w` (derived theorem)
- Paper's compositionality: Achieved via `forward_comp` (restricted to 0 ≤ x, 0 ≤ y) plus `converse`
- `nullity_identity`: `task_rel w 0 u ↔ w = u` (stronger than reflexivity)
- `converse`: `task_rel w d u ↔ task_rel u (-d) w` (temporal symmetry)
- The ordered additive group structure provides the required abelian group with total order

## Main Definitions

- `TaskFrame D`: Structure with world states, times of type `D`, task relation, and constraints
- `TaskFrame.nullity_identity`: Zero duration iff identity (`task_rel w 0 u ↔ w = u`)
- `TaskFrame.forward_comp`: Forward compositionality (restricted to non-negative durations)
- `TaskFrame.converse`: Temporal symmetry (`task_rel w d u ↔ task_rel u (-d) w`)
- `TaskFrame.nullity`: Derived reflexivity theorem (`task_rel w 0 w`)

## Main Results

- Example task frames for testing and demonstrations (polymorphic over time type)

## Implementation Notes

- Type parameter `D` represents temporal duration with ordered additive group structure
- Task relation `task_rel w x u` means: world state `u` is reachable from `w` by task
  of duration `x`
- Nullity: zero-duration task is identity (reflexivity)
- Compositionality: sequential tasks compose (transitivity with addition)
- Typeclass parameter convention: `(D : Type*)` explicit, ordered group instances implicit

## References

* [ARCHITECTURE.md](../../../docs/UserGuide/ARCHITECTURE.md) - Task semantics specification
* JPL Paper app:TaskSemantics (def:frame, line 1835) - Formal task frame definition
-/

namespace Bimodal.Semantics

/--
Task frame for bimodal logic TM.

A task frame consists of:
- A type of world states
- A type `D` of temporal durations with ordered additive group structure
- A task relation connecting world states via timed tasks
- Nullity identity: zero-duration task iff identity (w = u)
- Forward compositionality: tasks compose for non-negative durations
- Converse: task_rel w d u iff task_rel u (-d) w

The task relation `task_rel w x u` means: starting from world state `w`,
executing a task of duration `x` can result in world state `u`.

**Type Parameters**:
- `D`: Temporal duration type with totally ordered abelian group structure

**Paper Alignment**: Matches JPL paper def:frame (line 1835) exactly with
`D = ⟨D, +, ≤⟩` as a totally ordered abelian group.

**Axiomatization Notes (Task 966/969)**:
The original axiomatization used universal compositionality, which is algebraically
impossible for non-deterministic relations with mixed signs. This axiomatization
uses forward_comp (restricted to 0 ≤ x, 0 ≤ y) plus converse, which is equivalent
for all semantic purposes since `respects_task` only evaluates at d = t - s ≥ 0.
-/
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- Type of world states -/
  WorldState : Type
  /-- Task relation: `task_rel w x u` means u is reachable from w by task of duration x -/
  task_rel : WorldState → D → WorldState → Prop
  /--
  Nullity identity constraint: zero-duration task relates exactly identical states.

  For any world states `w` and `u`, `task_rel w 0 u` holds iff `w = u`.
  This is stronger than just reflexivity: it says zero duration means no change.
  -/
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  /--
  Forward compositionality constraint: tasks compose for non-negative durations.

  If task of duration `x ≥ 0` takes `w` to `u`, and task of duration `y ≥ 0` takes `u` to `v`,
  then task of duration `x + y` takes `w` to `v`.

  This restricted form avoids the algebraically impossible mixed-sign compositionality
  while being sufficient for `respects_task` which only uses non-negative durations.
  -/
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  /--
  Converse constraint: task relation is symmetric under duration negation.

  `task_rel w d u` holds iff `task_rel u (-d) w` holds.
  This gives temporal symmetry: if we can go from w to u in time d,
  we can go from u to w in time -d.
  -/
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w

namespace TaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Derived nullity: zero-duration task is reflexive.

This follows from `nullity_identity`: `task_rel w 0 w` iff `w = w`, and `w = w` is trivial.
-/
theorem nullity (F : TaskFrame D) (w : F.WorldState) : F.task_rel w 0 w :=
  F.nullity_identity w w |>.mpr rfl

/--
Derived backward compositionality: tasks compose in the backward direction.

From `forward_comp` and `converse`, we can derive compositionality for non-positive durations.
If `task_rel w x u` with `x ≤ 0` and `task_rel u y v` with `y ≤ 0`,
then `task_rel w (x + y) v`.
-/
theorem backward_comp (F : TaskFrame D) (w u v : F.WorldState) (x y : D)
    (hx : x ≤ 0) (hy : y ≤ 0)
    (h1 : F.task_rel w x u) (h2 : F.task_rel u y v) :
    F.task_rel w (x + y) v := by
  -- Use converse to flip directions, then forward_comp, then converse back
  -- task_rel w x u <-> task_rel u (-x) w, where -x >= 0
  -- task_rel u y v <-> task_rel v (-y) u, where -y >= 0
  have h1' : F.task_rel u (-x) w := F.converse w x u |>.mp h1
  have h2' : F.task_rel v (-y) u := F.converse u y v |>.mp h2
  have hx' : 0 ≤ -x := neg_nonneg.mpr hx
  have hy' : 0 ≤ -y := neg_nonneg.mpr hy
  -- forward_comp v u w (-y) (-x): task_rel v (-y) u -> task_rel u (-x) w -> task_rel v (-y + -x) w
  have h3 : F.task_rel v ((-y) + (-x)) w := F.forward_comp v u w (-y) (-x) hy' hx' h2' h1'
  -- Now use converse: task_rel v (-(x+y)) w <-> task_rel w (x+y) v
  have h4 : -y + -x = -(x + y) := by simp [neg_add_rev, add_comm]
  rw [h4] at h3
  exact F.converse w (x + y) v |>.mpr h3

/--
Simple unit-based task frame for testing.

World states are Unit (trivial), task relation is always true.
This is the simplest possible task frame, polymorphic over temporal type `D`.
-/
def trivial_frame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity_identity := fun _ _ => ⟨fun _ => Subsingleton.elim _ _, fun _ => trivial⟩
  forward_comp := fun _ _ _ _ _ _ _ _ _ => trivial
  converse := fun _ _ _ => ⟨fun _ => trivial, fun _ => trivial⟩

/--
Identity task frame: task relation is identity.

World states can be any type, task relation holds iff source equals target and time is 0.
Polymorphic over both world state type and temporal type.
-/
def identity_frame (W : Type) {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := W
  task_rel := fun w x u => w = u ∧ x = 0
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

World states are natural numbers. Task relation: `task_rel w d u` holds iff
either `d ≠ 0` (any transition for non-zero duration) or `w = u` (identity for zero duration).
This satisfies nullity_identity while remaining permissive.
Polymorphic over temporal type `D`.
-/
def nat_frame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := Nat
  task_rel := fun w d u => d ≠ 0 ∨ w = u
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
      | inl hnd => left; simp at hnd; exact hnd
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

end Bimodal.Semantics
