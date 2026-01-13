import Mathlib.Algebra.Order.Group.Defs

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
- Paper's nullity: `w ∈ w · 0` corresponds to `nullity : ∀ w, task_rel w 0 w`
- Paper's compositionality: If `u ∈ w · d` and `v ∈ u · e` then `v ∈ w · (d + e)`
  corresponds to
  `compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v`
- The ordered additive group structure provides the required abelian group with total order

## Main Definitions

- `TaskFrame D`: Structure with world states, times of type `D`, task relation, and constraints
- `TaskFrame.nullity`: Identity task constraint (`task_rel w 0 w`)
- `TaskFrame.compositionality`: Task composition constraint

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
- Nullity constraint: zero-duration task is identity
- Compositionality: tasks compose sequentially with additive time

The task relation `task_rel w x u` means: starting from world state `w`,
executing a task of duration `x` can result in world state `u`.

**Type Parameters**:
- `D`: Temporal duration type with totally ordered abelian group structure

**Paper Alignment**: Matches JPL paper def:frame (line 1835) exactly with
`D = ⟨D, +, ≤⟩` as a totally ordered abelian group.
-/
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- Type of world states -/
  WorldState : Type
  /-- Task relation: `task_rel w x u` means u is reachable from w by task of duration x -/
  task_rel : WorldState → D → WorldState → Prop
  /--
  Nullity constraint: zero-duration task is identity.

  For any world state `w`, executing a zero-duration task from `w` results in `w`.
  This gives reflexivity of the task relation.
  -/
  nullity : ∀ w, task_rel w 0 w
  /--
  Compositionality constraint: tasks compose with time addition.

  If task of duration `x` takes `w` to `u`, and task of duration `y` takes `u` to `v`,
  then task of duration `x + y` takes `w` to `v`.
  This gives a form of transitivity for the task relation.
  -/
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v

namespace TaskFrame

/--
Simple unit-based task frame for testing.

World states are Unit (trivial), task relation is always true.
This is the simplest possible task frame, polymorphic over temporal type `D`.
-/
def trivial_frame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/--
Identity task frame: task relation is identity.

World states can be any type, task relation holds iff source equals target and time is 0.
Polymorphic over both world state type and temporal type.
-/
def identity_frame (W : Type) {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := W
  task_rel := fun w x u => w = u ∧ x = 0
  nullity := fun w => ⟨rfl, rfl⟩
  compositionality := by
    intros w u v x y hwu huv
    obtain ⟨h1, h2⟩ := hwu
    obtain ⟨h3, h4⟩ := huv
    subst h1 h3
    simp [h2, h4]

/--
Natural number based task frame.

World states are natural numbers. Task relation: task of duration x from w
can reach any state (permissive for simplicity).
Polymorphic over temporal type `D`.
-/
def nat_frame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := Nat
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

end TaskFrame

end Bimodal.Semantics
