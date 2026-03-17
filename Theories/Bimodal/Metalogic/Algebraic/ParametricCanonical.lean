import Bimodal.Metalogic.Algebraic.UltrafilterMCS
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Semantics.TaskFrame

/-!
# D-Parametric Canonical TaskFrame

This module defines a D-parametric canonical TaskFrame construction for the
Lindenbaum-Tarski algebraic representation theorem.

## Key Insight

The duration type D is a **parameter**, not constructed from syntax. This avoids
the "domain mismatch" problems from earlier approaches (tasks 977/978/982) that
tried to build D from syntax (e.g., TimelineQuot).

The construction is **uniform in D**: the same algebraic structure works for
any totally ordered abelian group D (Int, Rat, or any other).

## Main Definitions

- `ParametricCanonicalWorldState`: MCS-based world states (D-independent)
- `parametric_canonical_task_rel D`: D-parametric task relation using CanonicalR
- `ParametricCanonicalTaskFrame D`: D-parametric TaskFrame

## Design

The task relation is defined as:
- **d > 0**: `CanonicalR M.val N.val` (g_content M ⊆ N — forward temporal accessibility)
- **d = 0**: `M = N` (zero displacement = same world-state)
- **d < 0**: `CanonicalR N.val M.val` (converse for backward direction)

This matches the existing `canonical_task_rel` in CanonicalConstruction.lean but
generalized to arbitrary D instead of hardcoded Int.

## References

- Research: specs/985_lindenbaum_tarski_representation_theorem/reports/research-002.md
- Existing: Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean
-/

namespace Bimodal.Metalogic.Algebraic.ParametricCanonical

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Algebraic.UltrafilterMCS
open Bimodal.Semantics

/-!
## Parametric Canonical World State

The world state is an MCS, packaged as a subtype. This is D-independent:
the same MCS structure works regardless of the duration type.
-/

/--
Parametric canonical world state: a maximal consistent set packaged as a subtype.

This is the WorldState of the parametric canonical TaskFrame.
It is D-independent since MCS structure depends only on formula syntax.
-/
def ParametricCanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

/-!
## D-Parametric Task Relation

The task relation uses CanonicalR from CanonicalFrame.lean, with sign-based
case analysis to handle forward (d > 0), identity (d = 0), and backward (d < 0).
-/

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
Parametric canonical task relation: forward accessibility with converse for negative durations.

The task relation captures temporal coherence between MCSs along trajectories:
- **d > 0**: `CanonicalR M.val N.val` (g_content M ⊆ N) — N is forward-accessible from M
- **d = 0**: `M = N` — zero displacement means same world-state
- **d < 0**: `CanonicalR N.val M.val` — backward direction uses converse relationship

This is parametric in D: the same definition works for any ordered abelian group.
-/
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0

/-!
## TaskFrame Axioms

We prove the three TaskFrame axioms: nullity_identity, forward_comp, and converse.
-/

/--
Nullity identity: `parametric_canonical_task_rel M 0 N` holds iff `M = N`.
-/
theorem parametric_task_rel_nullity_identity (M N : ParametricCanonicalWorldState) :
    parametric_canonical_task_rel M (0 : D) N ↔ M = N := by
  unfold parametric_canonical_task_rel
  simp only [gt_iff_lt, lt_irrefl, ite_false]

/--
Forward compositionality: `task_rel M x U → task_rel U y V → task_rel M (x+y) V`
when `0 ≤ x` and `0 ≤ y`.

Since we restrict to non-negative durations, only these cases apply:
- x = 0, y = 0: M = U ∧ U = V → M = V (transitivity of equality)
- x = 0, y > 0: M = U, substitute → CanonicalR M V
- x > 0, y = 0: U = V, substitute → CanonicalR M V
- x > 0, y > 0: chain via `canonicalR_transitive` (uses temp_4: G(φ) → G(G(φ)))
-/
theorem parametric_task_rel_forward_comp
    (M U V : ParametricCanonicalWorldState) (x y : D)
    (hx : 0 ≤ x) (hy : 0 ≤ y)
    (h1 : parametric_canonical_task_rel M x U)
    (h2 : parametric_canonical_task_rel U y V) :
    parametric_canonical_task_rel M (x + y) V := by
  unfold parametric_canonical_task_rel at *
  -- With 0 ≤ x and 0 ≤ y, we have 0 ≤ x + y
  by_cases hx_pos : x > 0
  · -- x > 0: h1 gives CanonicalR M.val U.val
    have hx_neg : ¬(x < 0) := not_lt.mpr (le_of_lt hx_pos)
    simp only [hx_pos, ite_true, hx_neg, ite_false] at h1
    by_cases hy_pos : y > 0
    · -- x > 0, y > 0: h2 gives CanonicalR U.val V.val, x + y > 0
      have hy_neg : ¬(y < 0) := not_lt.mpr (le_of_lt hy_pos)
      simp only [hy_pos, ite_true, hy_neg, ite_false] at h2
      have hsum_pos : x + y > 0 := add_pos hx_pos hy_pos
      simp only [hsum_pos, ite_true]
      exact canonicalR_transitive M.val U.val V.val M.property h1 h2
    · -- x > 0, y = 0: h2 gives U = V
      have hy_eq : y = 0 := le_antisymm (not_lt.mp hy_pos) hy
      subst hy_eq
      have hy_neg : ¬((0 : D) < 0) := lt_irrefl 0
      have hy_npos : ¬((0 : D) > 0) := lt_irrefl 0
      simp only [hy_npos, ite_false, hy_neg] at h2
      subst h2  -- U = V
      simp only [add_zero, hx_pos, ite_true]
      exact h1
  · -- x = 0: h1 gives M = U
    have hx_eq : x = 0 := le_antisymm (not_lt.mp hx_pos) hx
    subst hx_eq
    have hx_neg : ¬((0 : D) < 0) := lt_irrefl 0
    have hx_npos : ¬((0 : D) > 0) := lt_irrefl 0
    simp only [hx_npos, ite_false, hx_neg] at h1
    subst h1  -- M = U
    simp only [zero_add]
    exact h2

/--
Converse axiom: `parametric_canonical_task_rel M d N ↔ parametric_canonical_task_rel N (-d) M`.

This holds because of how we defined `parametric_canonical_task_rel`:
- If d > 0: LHS = CanonicalR M N, RHS (with -d < 0) = CanonicalR M N
- If d = 0: LHS = M = N, RHS (with -0 = 0) = N = M
- If d < 0: LHS = CanonicalR N M, RHS (with -d > 0) = CanonicalR N M
-/
theorem parametric_task_rel_converse
    (M : ParametricCanonicalWorldState) (d : D) (N : ParametricCanonicalWorldState) :
    parametric_canonical_task_rel M d N ↔ parametric_canonical_task_rel N (-d) M := by
  unfold parametric_canonical_task_rel
  by_cases hd_pos : d > 0
  · -- d > 0: LHS = CanonicalR M.val N.val
    -- -d < 0: RHS = CanonicalR M.val N.val
    have hd_neg : ¬(d < 0) := not_lt.mpr (le_of_lt hd_pos)
    have hnd_neg : -d < 0 := neg_neg_of_pos hd_pos
    have hnd_npos : ¬(-d > 0) := not_lt.mpr (le_of_lt hnd_neg)
    simp only [hd_pos, ite_true, hd_neg, ite_false, hnd_npos, hnd_neg]
  · by_cases hd_neg : d < 0
    · -- d < 0: LHS = CanonicalR N.val M.val
      -- -d > 0: RHS = CanonicalR N.val M.val
      have hd_npos : ¬(d > 0) := not_lt.mpr (le_of_lt hd_neg)
      have hnd_pos : -d > 0 := neg_pos_of_neg hd_neg
      have hnd_nneg : ¬(-d < 0) := not_lt.mpr (le_of_lt hnd_pos)
      simp only [hd_npos, ite_false, hd_neg, ite_true, hnd_pos, hnd_nneg]
    · -- d = 0: LHS = M = N, RHS = N = M
      have hd_eq : d = 0 := le_antisymm (not_lt.mp hd_pos) (not_lt.mp hd_neg)
      subst hd_eq
      simp only [neg_zero, gt_iff_lt, lt_irrefl, ite_false]
      exact ⟨Eq.symm, Eq.symm⟩

/-!
## The Parametric Canonical TaskFrame
-/

/--
The D-parametric canonical task frame.

- **WorldState** = `ParametricCanonicalWorldState` (MCS pairs) — D-independent
- **D** = arbitrary ordered abelian group (Int, Rat, etc.)
- **task_rel** = `parametric_canonical_task_rel` — uses CanonicalR

This construction is **uniform in D**: instantiate with D = Int for discrete time,
D = Rat for dense time, or any other ordered abelian group.
-/
def ParametricCanonicalTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := ParametricCanonicalWorldState
  task_rel := parametric_canonical_task_rel
  nullity_identity := parametric_task_rel_nullity_identity
  forward_comp := fun M U V x y hx hy h1 h2 =>
    parametric_task_rel_forward_comp M U V x y hx hy h1 h2
  converse := parametric_task_rel_converse

/-!
## Derived Properties
-/

/--
Nullity theorem: zero-duration task is reflexive.
-/
theorem parametric_task_rel_nullity (M : ParametricCanonicalWorldState) :
    parametric_canonical_task_rel M (0 : D) M :=
  (parametric_task_rel_nullity_identity M M).mpr rfl

/--
Forward-positive case: for d > 0, task_rel M d N iff CanonicalR M.val N.val.
-/
theorem parametric_task_rel_pos {d : D} (hd : d > 0)
    (M N : ParametricCanonicalWorldState) :
    parametric_canonical_task_rel M d N ↔ CanonicalR M.val N.val := by
  unfold parametric_canonical_task_rel
  simp only [hd, ite_true]

/--
Zero case: task_rel M 0 N iff M = N.
-/
theorem parametric_task_rel_zero (M N : ParametricCanonicalWorldState) :
    parametric_canonical_task_rel M (0 : D) N ↔ M = N :=
  parametric_task_rel_nullity_identity M N

/--
Negative case: for d < 0, task_rel M d N iff CanonicalR N.val M.val.
-/
theorem parametric_task_rel_neg {d : D} (hd : d < 0)
    (M N : ParametricCanonicalWorldState) :
    parametric_canonical_task_rel M d N ↔ CanonicalR N.val M.val := by
  unfold parametric_canonical_task_rel
  have hd_npos : ¬(d > 0) := not_lt.mpr (le_of_lt hd)
  simp only [hd_npos, ite_false, hd, ite_true]

end Bimodal.Metalogic.Algebraic.ParametricCanonical
