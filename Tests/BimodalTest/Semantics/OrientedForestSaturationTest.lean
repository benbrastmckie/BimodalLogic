/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.OrientedForest

/-!
# Evidence for the oriented-forest *Saturation* discharge

This module is **permanent evidence**, not a conventional test. It pins two things that would
otherwise be re-derived, or quietly broken, by a later reader:

1. **The axiom profiles** of the oriented-forest *Saturation* family, as `#guard_msgs`-gated
   `#print axioms` blocks. These are build-breaking: if a profile moves, this module stops
   compiling. Every profile recorded below was *measured* in the same dispatch that landed the
   declarations, never typed from memory or carried from a prototype.

2. **The minimality trap.** `Semantics.sInter_nonempty_of_forward_fibres` minimises duration over
   `{n | ∃ a, {u | iter E n a u} ∈ S}` — over **all** representations of **all** members. The
   natural-looking alternative, "pick one representation per member and minimise over those", is
   *wrong*, and the mistake leaves no visible trace in the proof. The fixture below compiles the
   configuration in which it fails.

## When one of these guards fires

A red build here means an axiom profile moved. The expected block is updated **in the same commit
as the change that moved it**, with the move justified in that commit — never updated on its own
to turn a red build green. A guard silently re-baselined to match whatever the tree now does
records nothing and protects nothing.

## The minimality fixture

The one-step relation `minE` below is the measured configuration from this task's research
report, on the carrier `Fin 8`:

```
0 → 1 → 2,    3 → 2,    3 → 4 → 5,    2 → 6,    2 → 7
```

Reading `0 = a`, `1 = u`, `2 = c`, `3 = a'`, `4 = d`, `5 = e`, `6` and `7` the two children of
`c`, the three compiled facts below say

* `Fib(a, 3) = Fib(c, 1) = {6, 7}` — **one member, two representations, of different durations**;
* `Fib(c, 1) ⊊ Fib(a', 2) = {5, 6, 7}`;
* `S = {Fib(a, 3), Fib(a', 2)}` is `⊇`-directed with nonempty members.

Now compare the two readings of "duration-minimal member" on this `S`:

* over **all** representations, the durations available are `{3, 1, 2}` (because `Fib(c, 1)` *is*
  the member `Fib(a, 3)`, as a set), the minimum is `1`, and it selects `{6, 7}` — which is the
  `⊆`-least member, as the proof needs;
* over **one chosen representation per member**, the durations are `{3, 2}`, the minimum is `2`,
  and it selects `{5, 6, 7}` — which is **not** `⊆`-least, and the selection step then cannot be
  completed. Nothing in the weaker reading's own statement reveals this.

**What this fixture does and does not discharge.** It compiles the representation multiplicity,
which is a fact about `iter` alone and therefore independent of any hypothesis on `minE`. It does
*not* discharge `Semantics.IsOrientedForest minE`; the undirected multigraph of `minE` is a
forest (eight vertices, seven edges, connected, so a tree by inspection), but Mathlib carries no
decision procedure for `SimpleGraph.IsAcyclic` at this pin, and discharging it by hand would add
a connectivity-and-edge-count argument that pins nothing this fixture is for. The trap being
recorded is about which representation the *minimum ranges over*, not about the hypothesis.
-/

namespace BimodalTest.Semantics

open FormalSystem.Semantics

/-! ## Axiom profiles

Every block below is build-breaking: `#guard_msgs` compares the `#print axioms` info message
against the expected text and fails the build on any difference.

The ceiling is `[propext, Classical.choice, Quot.sound]`, which is exactly
`TaskFrame.saturation_of_finite`'s own measured profile — so the oriented-forest route adds no
new axiom cost at either consumer. `Classical.choice` enters through `Semantics.pathOf`'s
`Exists.choose` and through the `by_cases` in `Semantics.exists_merge`; a `Classical.choice`-free
variant is not available for this family, for the reason recorded in
`SaturationFiniteAxiomTest.lean`'s own header.
-/

/-! ### The two headline theorems -/

/-- info: 'FormalSystem.Semantics.saturation_of_orientedForest' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.saturation_of_orientedForest

/-- info: 'FormalSystem.Semantics.saturation_of_orientedForest'' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.saturation_of_orientedForest'

/-! ### The residual step

`merge_unique` is the one committed declaration whose proof consumes the `acyclic` field — it
routes through `mergePoint_unique`, hence through `approach_concat_isPath` and `walk_unique`, i.e.
`SimpleGraph.IsAcyclic.subsingleton_path`. Its profile is guarded alongside the target-free
`mergePoint_unique` it is derived from.
-/

/-- info: 'FormalSystem.Semantics.merge_unique' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.merge_unique

/-- info: 'FormalSystem.Semantics.mergePoint_unique' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.mergePoint_unique

/-! ### The segment-subsingleton fact and the merge existence

`mid_unique` **is** the segment-subsingleton fact. `exists_merge` takes no forest hypothesis at
all, and its `Classical.choice` is the `by_cases` on the two penultimate vertices — not a forest
appeal.
-/

/-- info: 'FormalSystem.Semantics.mid_unique' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.mid_unique

/-- info: 'FormalSystem.Semantics.exists_merge' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.exists_merge

/-! ### The selection core

The declaration the minimality fixture below is about.
-/

/-- info: 'FormalSystem.Semantics.sInter_nonempty_of_forward_fibres' depends on axioms: [propext, Classical.choice, Quot.sound] -/
#guard_msgs in
#print axioms FormalSystem.Semantics.sInter_nonempty_of_forward_fibres

/-! ## The minimality fixture -/

/--
The measured minimality configuration's one-step relation on `Fin 8`:
`0 → 1 → 2`, `3 → 2`, `3 → 4 → 5`, `2 → 6`, `2 → 7`.

See this module's header for the reading of the vertices and for what the fixture does and does
not discharge.
-/
def minE : Fin 8 → Fin 8 → Prop := fun x y =>
  (x = 0 ∧ y = 1) ∨ (x = 1 ∧ y = 2) ∨ (x = 3 ∧ y = 2) ∨ (x = 3 ∧ y = 4) ∨
  (x = 4 ∧ y = 5) ∨ (x = 2 ∧ y = 6) ∨ (x = 2 ∧ y = 7)

instance : DecidableRel minE := fun x y => by unfold minE; infer_instance

/--
**One member, two representations of different durations.** The fibre at distance `3` from `0` is
the fibre at distance `1` from `2`. This is what makes "one chosen representation per member"
ill-defined as a basis for minimisation.
-/
theorem minE_fib_three_eq_fib_one : {u | iter minE 3 0 u} = {u | iter minE 1 2 u} := by
  ext u
  fin_cases u <;> simp only [Set.mem_setOf_eq, iter_succ, iter_zero] <;> decide

/--
**And the other member is strictly larger.** So the `⊆`-least member of the family below is the
one carrying the duration-`1` representation, not the one the per-member reading selects.
-/
theorem minE_fib_one_ssubset_fib_two : {u | iter minE 1 2 u} ⊂ {u | iter minE 2 3 u} := by
  constructor
  · intro u hu
    fin_cases u <;>
      simp only [Set.mem_setOf_eq, iter_succ, iter_zero] at hu ⊢ <;> revert hu <;> decide
  · intro hsub
    have hmem : (5 : Fin 8) ∈ {u | iter minE 1 2 u} := by
      refine hsub ?_
      simp only [Set.mem_setOf_eq, iter_succ, iter_zero]
      decide
    simp only [Set.mem_setOf_eq, iter_succ, iter_zero] at hmem
    revert hmem
    decide

/-- The two-member family the fixture is about. -/
def minS : Set (Set (Fin 8)) := {{u | iter minE 3 0 u}, {u | iter minE 2 3 u}}

/-- `minS` is `⊇`-directed: the smaller member is contained in every binary intersection, and it
is in the family. So the fixture really is a `Saturation` instance and not a degenerate one. -/
theorem minS_directed : TaskFrame.DirectedFamily minS := by
  have hsub : {u | iter minE 3 0 u} ⊆ {u | iter minE 2 3 u} := by
    rw [minE_fib_three_eq_fib_one]
    exact minE_fib_one_ssubset_fib_two.1
  have hall : ∀ S ∈ minS, {u | iter minE 3 0 u} ⊆ S := by
    intro S hS
    simp only [minS, Set.mem_insert_iff, Set.mem_singleton_iff] at hS
    rcases hS with hS | hS
    · subst hS; exact subset_rfl
    · subst hS; exact hsub
  refine ⟨⟨{u | iter minE 3 0 u}, Set.mem_insert _ _⟩, ?_⟩
  intro S₁ h₁ S₂ h₂
  exact ⟨{u | iter minE 3 0 u}, Set.mem_insert _ _, Set.subset_inter (hall S₁ h₁) (hall S₂ h₂)⟩

/-- Both members are nonempty, the other hypothesis `Saturation` imposes on a family. -/
theorem minS_nonempty_members : ∀ s ∈ minS, s.Nonempty := by
  intro s hs
  simp only [minS, Set.mem_insert_iff, Set.mem_singleton_iff] at hs
  rcases hs with hs | hs <;> subst hs
  · refine ⟨6, ?_⟩
    simp only [Set.mem_setOf_eq, iter_succ, iter_zero]
    decide
  · refine ⟨5, ?_⟩
    simp only [Set.mem_setOf_eq, iter_succ, iter_zero]
    decide

end BimodalTest.Semantics
