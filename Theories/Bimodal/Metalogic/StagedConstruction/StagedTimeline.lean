import Bimodal.Metalogic.Canonical.CanonicalTimeline
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Syntax.Formula

/-!
# Staged Timeline Infrastructure for D-from-Syntax Construction

This module defines the infrastructure for the step-by-step (staged) construction
of a countable dense linear order from the canonical timeline of MCSs.

## Overview

The staged construction (Burgess/Venema/Goldblatt technique) builds the timeline
incrementally:
- **Even stages**: Process F/P formula obligations (add witness MCSs)
- **Odd stages**: Ensure density (insert intermediate MCSs between successive pairs)

This approach avoids the ConstructiveQuotient entirely, sidestepping the
G-completeness blocker identified in research-034. The Cantor prerequisites
(NoMaxOrder, NoMinOrder, DenselyOrdered, Countable) are BUILT IN by construction.

## Key Types

- `StagedPoint`: An MCS with its stage-of-introduction index
- `StagedTimeline`: A function from stage number to the finite set of points at that stage
- `TimelineUnion`: The union of all stages (the full timeline)

## References

- Task 956 plan v014: Phase 1 (Staged Construction Infrastructure)
- research-034: ConstructiveQuotient blocker, staged construction justification
- Burgess 1984, "Basic Tense Logic"
- Venema 2001, "Temporal Logic"
- Goldblatt 1992, "Logics of Time and Computation"
-/

namespace Bimodal.Metalogic.StagedConstruction

open Bimodal.Syntax
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Canonical
open Bimodal.ProofSystem

/-!
## Stage Type

A stage is simply a natural number. Even stages process F/P obligations,
odd stages ensure density.
-/

/-- A stage in the construction is a natural number. -/
abbrev Stage := Nat

/-- A stage is an even (obligation) stage. -/
def Stage.isEven (s : Stage) : Prop := s % 2 = 0

/-- A stage is an odd (density) stage. -/
def Stage.isOdd (s : Stage) : Prop := s % 2 = 1

instance (s : Stage) : Decidable (Stage.isEven s) :=
  Nat.decEq (s % 2) 0

instance (s : Stage) : Decidable (Stage.isOdd s) :=
  Nat.decEq (s % 2) 1

/-!
## StagedPoint: An MCS with Stage Index

Each point in the staged timeline is an MCS together with the stage number
at which it was introduced. This pairing enables countability (omega stages,
finitely many additions per stage).
-/

/--
A point in the staged timeline: an MCS together with the stage at which
it was introduced into the timeline.
-/
structure StagedPoint where
  /-- The underlying maximal consistent set. -/
  mcs : Set Formula
  /-- Proof that the set is maximal consistent. -/
  is_mcs : SetMaximalConsistent mcs
  /-- The stage at which this point was introduced. -/
  introduced_at : Stage

/-!
## Ordering on StagedPoints

The order on StagedPoints is induced by the canonical temporal relation CanonicalR
on the underlying MCSs. Two points are related iff their underlying MCSs are
related by CanonicalR.

Since the staged construction maintains linearity at each stage (by construction),
the ordering is a total preorder. Two StagedPoints with the same underlying MCS
(but possibly different introduction stages) are considered equivalent.
-/

/--
The strict ordering on StagedPoints: `a < b` iff `CanonicalR a.mcs b.mcs` and
NOT `CanonicalR b.mcs a.mcs` (strictly forward in canonical time).
-/
def StagedPoint.lt (a b : StagedPoint) : Prop :=
  CanonicalR a.mcs b.mcs ∧ ¬CanonicalR b.mcs a.mcs

/--
The non-strict ordering on StagedPoints: `a ≤ b` iff `a.mcs = b.mcs` or
`CanonicalR a.mcs b.mcs`.
-/
def StagedPoint.le (a b : StagedPoint) : Prop :=
  a.mcs = b.mcs ∨ CanonicalR a.mcs b.mcs

/--
Two StagedPoints are equivalent if their underlying MCSs are equal.
-/
def StagedPoint.equiv (a b : StagedPoint) : Prop :=
  a.mcs = b.mcs

theorem StagedPoint.le_refl (a : StagedPoint) : StagedPoint.le a a :=
  Or.inl rfl

theorem StagedPoint.le_trans (a b c : StagedPoint)
    (hab : StagedPoint.le a b) (hbc : StagedPoint.le b c) :
    StagedPoint.le a c := by
  rcases hab with h_eq_ab | hab
  · -- a.mcs = b.mcs, so CanonicalR a.mcs c.mcs ↔ CanonicalR b.mcs c.mcs
    rcases hbc with h_eq_bc | hbc
    · exact Or.inl (h_eq_ab.trans h_eq_bc)
    · exact Or.inr (h_eq_ab ▸ hbc)
  · rcases hbc with h_eq_bc | hbc
    · exact Or.inr (h_eq_bc ▸ hab)
    · exact Or.inr (canonicalR_transitive a.mcs b.mcs c.mcs a.is_mcs hab hbc)

/-!
Note: Under irreflexive semantics, mutual CanonicalR (a.mcs, b.mcs and b.mcs, a.mcs)
does NOT imply a.mcs = b.mcs. Two MCSs can agree on all G-formulas (g_content) while
differing on base formulas. Antisymmetry is ensured by the staged construction itself,
which maintains strict ordering between distinct MCSs. See `StagedTimeline.strict_between_distinct`.
-/

/-!
## Timeline Sets

A timeline set is a finite collection of StagedPoints that is linearly ordered
(each pair is comparable). The staged construction builds these incrementally.
-/

/--
A timeline set is linearly ordered if every pair of points is comparable
by the canonical relation.
-/
def IsLinearlyOrdered (S : Finset StagedPoint) : Prop :=
  ∀ a ∈ S, ∀ b ∈ S, StagedPoint.le a b ∨ StagedPoint.le b a

/-!
## StagedTimeline Type

A StagedTimeline is a function mapping each stage to the (accumulated) set of
StagedPoints present at that stage. The timeline grows monotonically: each stage
adds new points but never removes old ones.
-/

/--
A staged timeline is a monotonically growing sequence of linearly ordered finite sets
of StagedPoints, starting from a root MCS at stage 0.
-/
structure StagedTimeline where
  /-- The root MCS (origin of the timeline). -/
  root : StagedPoint
  /-- The root is at stage 0. -/
  root_stage : root.introduced_at = 0
  /-- The accumulated set of points at each stage. -/
  at_stage : Stage → Finset StagedPoint
  /-- The root is in stage 0. -/
  root_in_stage_0 : root ∈ at_stage 0
  /-- Monotonicity: each stage includes all points from the previous stage. -/
  monotone : ∀ n : Stage, at_stage n ⊆ at_stage (n + 1)
  /-- Each stage is linearly ordered. -/
  linear_at_stage : ∀ n : Stage, IsLinearlyOrdered (at_stage n)

/-!
## Timeline Union

The full timeline T is the union of all stages. This is the complete countable
dense linear order (once the construction is fully executed).
-/

/--
The union of all stages of a StagedTimeline: the complete set of StagedPoints.
-/
def StagedTimeline.union (T : StagedTimeline) : Set StagedPoint :=
  { p | ∃ n : Stage, p ∈ T.at_stage n }

/--
Every point at stage n is in the union.
-/
theorem StagedTimeline.at_stage_subset_union (T : StagedTimeline) (n : Stage) :
    ↑(T.at_stage n) ⊆ T.union := by
  intro p hp
  exact ⟨n, hp⟩

/--
The root is in the union.
-/
theorem StagedTimeline.root_in_union (T : StagedTimeline) :
    T.root ∈ T.union :=
  ⟨0, T.root_in_stage_0⟩

/--
Monotonicity: if p is in stage n, it is in stage n + k for all k.
-/
theorem StagedTimeline.monotone_forward (T : StagedTimeline) (n k : Stage) :
    T.at_stage n ⊆ T.at_stage (n + k) := by
  induction k with
  | zero => simp
  | succ k ih =>
    calc T.at_stage n ⊆ T.at_stage (n + k) := ih
    _ ⊆ T.at_stage (n + k + 1) := T.monotone (n + k)

/--
If p is in stage n and m ≥ n, then p is in stage m.
-/
theorem StagedTimeline.monotone_le (T : StagedTimeline) {n m : Stage}
    (h : n ≤ m) : T.at_stage n ⊆ T.at_stage m := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_add_of_le h
  exact T.monotone_forward n k

/--
The union is linearly ordered: any two points in the union are comparable.
-/
theorem StagedTimeline.union_linearly_ordered (T : StagedTimeline)
    (a b : StagedPoint) (ha : a ∈ T.union) (hb : b ∈ T.union) :
    StagedPoint.le a b ∨ StagedPoint.le b a := by
  obtain ⟨n, ha_n⟩ := ha
  obtain ⟨m, hb_m⟩ := hb
  -- Both a and b are in stage max(n, m)
  have ha_max : a ∈ T.at_stage (max n m) :=
    T.monotone_le (Nat.le_max_left n m) ha_n
  have hb_max : b ∈ T.at_stage (max n m) :=
    T.monotone_le (Nat.le_max_right n m) hb_m
  exact T.linear_at_stage (max n m) a ha_max b hb_max

/-!
## Nonemptiness

The staged timeline is always nonempty (it contains at least the root).
-/

theorem StagedTimeline.union_nonempty (T : StagedTimeline) :
    Set.Nonempty T.union :=
  ⟨T.root, T.root_in_union⟩

end Bimodal.Metalogic.StagedConstruction
