import Bimodal.Boneyard.Metalogic_v2.Decidability.Saturation
import Bimodal.Semantics.TaskFrame
import Bimodal.Semantics.TaskModel
import Bimodal.Semantics.WorldHistory
import Bimodal.Semantics.Truth
import Mathlib.Data.Finset.Basic

/-!
# BranchTaskModel - TaskModel Extraction from Saturated Tableau Branches

This module extracts proper TaskModel structures from saturated open tableau branches.
Unlike the SimpleCountermodel (which treats modal/temporal as identity), this provides
semantically correct task frame extraction following the JPL paper's task semantics.

## Overview

A saturated open branch in the TM tableau describes constraints that a countermodel
must satisfy. This module builds a TaskFrame and TaskModel that satisfies those
constraints, with:
- WorldState type derived from branch atoms
- Task relation satisfying nullity and compositionality
- Valuation function from branch positive atoms

## Main Definitions

- `BranchWorldState`: World state type extracted from saturated branch atoms
- `branch_task_rel`: Task relation satisfying nullity and compositionality
- `extractBranchTaskFrame`: Construct TaskFrame from saturated open branch
- `extractBranchTaskModel`: Construct TaskModel with valuation from branch

## Implementation Notes

For tableau-based finite model extraction, we use:
- D = Int (discrete integer time, sufficient for FMP)
- WorldState = BranchWorldState (finite type based on branch atoms)
- Task relation permissive for simplicity (any state reachable from any state)

This simplified task relation ensures nullity and compositionality hold trivially,
while the valuation extracts the actual semantic content from the branch.

## References

* JPL Paper "The Perpetuity Calculus of Agency" (app:TaskSemantics)
* Gore, R. (1999). Tableau Methods for Modal and Temporal Logics
* Research report: specs/630_build_taskmodel_extraction_from_saturated_branches/reports/research-001.md
-/

namespace Bimodal.Metalogic_v2.Decidability

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics

/-!
## Phase 1: BranchWorldState Definition
-/

/--
World state extracted from a saturated tableau branch.

A branch world state captures which atoms are true at a particular world.
This is the minimal structure needed for finite model extraction.

**Design Choice**: We use `Finset String` rather than `List String` to ensure
uniqueness and enable decidable equality.
-/
structure BranchWorldState where
  /-- The set of atoms true at this world state. -/
  atoms : Finset String
  deriving DecidableEq

namespace BranchWorldState

/-- Empty world state where no atoms are true. -/
def empty : BranchWorldState := ⟨∅⟩

/-- Singleton world state with one true atom. -/
def singleton (p : String) : BranchWorldState := ⟨{p}⟩

/-- Check if an atom is true at this world state. -/
def hasAtom (w : BranchWorldState) (p : String) : Bool :=
  p ∈ w.atoms

/-- Add an atom to the world state. -/
def addAtom (w : BranchWorldState) (p : String) : BranchWorldState :=
  ⟨insert p w.atoms⟩

/-- Union of two world states. -/
def union (w₁ w₂ : BranchWorldState) : BranchWorldState :=
  ⟨w₁.atoms ∪ w₂.atoms⟩

instance : Inhabited BranchWorldState := ⟨empty⟩

end BranchWorldState

/-!
## Branch World State Extraction
-/

/--
Extract atoms that are positively signed (true) from a branch.
Returns the set of atoms p where T(p) appears in the branch.
-/
def extractTrueAtomSet (b : Branch) : Finset String :=
  b.foldl (fun acc sf =>
    match sf.sign, sf.formula with
    | .pos, .atom p => insert p acc
    | _, _ => acc
  ) ∅

/--
Extract atoms that are negatively signed (false) from a branch.
Returns the set of atoms p where F(p) appears in the branch.
-/
def extractFalseAtomSet (b : Branch) : Finset String :=
  b.foldl (fun acc sf =>
    match sf.sign, sf.formula with
    | .neg, .atom p => insert p acc
    | _, _ => acc
  ) ∅

/--
Extract the world state from a saturated branch.
The world state consists of all atoms that appear positively (T(p)) in the branch.
-/
def extractBranchWorldState (b : Branch) : BranchWorldState :=
  ⟨extractTrueAtomSet b⟩

/--
Extract valuation from a world state.
An atom p is true at world state w iff p is in w's atom set.
-/
def branchWorldStateValuation (w : BranchWorldState) (p : String) : Prop :=
  p ∈ w.atoms

/--
Decidable valuation predicate for branch world states.
-/
instance (w : BranchWorldState) : DecidablePred (branchWorldStateValuation w) := fun p =>
  if h : p ∈ w.atoms then isTrue h else isFalse h

/-!
## Phase 2: Branch Task Relation
-/

/--
The branch task relation on BranchWorldState.

For simplicity in tableau-based extraction, we use a permissive task relation
where any state is reachable from any state at any duration. This ensures:
- Nullity holds trivially (w reachable from w at duration 0)
- Compositionality holds trivially (transitivity via any intermediate state)

The actual semantic content comes from the valuation, not the frame structure.

**Design Rationale**: In tableau extraction, we have a single saturated branch
representing constraints on a countermodel. The branch describes what formulas
must hold, and the permissive task relation ensures we can construct world
histories satisfying those constraints without additional frame restrictions.
-/
def branch_task_rel (_w : BranchWorldState) (_d : Int) (_v : BranchWorldState) : Prop :=
  True

/--
Nullity: Zero-duration task is identity (trivially satisfied by permissive relation).
-/
theorem branch_task_rel_nullity (w : BranchWorldState) : branch_task_rel w 0 w := by
  unfold branch_task_rel
  trivial

/--
Compositionality: Tasks compose with duration addition (trivially satisfied).
-/
theorem branch_task_rel_comp (w u v : BranchWorldState) (d1 d2 : Int)
    (_h1 : branch_task_rel w d1 u) (_h2 : branch_task_rel u d2 v) :
    branch_task_rel w (d1 + d2) v := by
  unfold branch_task_rel
  trivial

/--
Time extraction lemma: task relation holds for any duration.
This is a consequence of our permissive definition.
-/
lemma branch_task_rel_any (w v : BranchWorldState) (d : Int) : branch_task_rel w d v := by
  unfold branch_task_rel
  trivial

/-!
## Phase 3: TaskFrame and TaskModel Construction
-/

/--
The task frame for branch-extracted models.

Uses Int as the duration type (sufficient for FMP finite models).
WorldState is BranchWorldState, task relation is the permissive branch_task_rel.
-/
def BranchTaskFrame : TaskFrame Int where
  WorldState := BranchWorldState
  task_rel := branch_task_rel
  nullity := branch_task_rel_nullity
  compositionality := branch_task_rel_comp

/--
Extract a TaskFrame from a saturated open branch.

Note: The returned frame is the same BranchTaskFrame for any branch.
The branch-specific information is captured in the TaskModel's valuation.
-/
def extractBranchTaskFrame (_b : Branch) : TaskFrame Int :=
  BranchTaskFrame

/--
A task model built from a saturated branch.

The valuation assigns atoms based on whether they appear positively in the branch:
- An atom p is true at world state w if p is in w's atom set
-/
def extractBranchTaskModel (b : Branch) : TaskModel BranchTaskFrame where
  valuation := branchWorldStateValuation

/--
The branch world state for model construction.
This is the designated initial world state extracted from the branch.
-/
def extractInitialWorldState (b : Branch) : BranchWorldState :=
  extractBranchWorldState b

/-!
## World History Construction
-/

/--
A world history for BranchTaskFrame that assigns the same world state everywhere.

Since our task relation is permissive (always True), we can construct histories
that assign any world state at any time. The simplest is a constant history.

**Parameters**:
- `w`: The constant world state for all times
-/
def constantBranchHistory (w : BranchWorldState) : WorldHistory BranchTaskFrame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => w
  respects_task := fun _ _ _ _ _ => trivial

/--
Extract a world history from a saturated branch.
Uses the branch's initial world state as a constant history.
-/
def extractBranchWorldHistory (b : Branch) : WorldHistory BranchTaskFrame :=
  constantBranchHistory (extractInitialWorldState b)

/-!
## Valuation Properties
-/

/--
Helper lemma: membership in extractTrueAtomSet via induction on the branch.
-/
lemma mem_extractTrueAtomSet_iff (b : Branch) (p : String) :
    p ∈ extractTrueAtomSet b ↔ SignedFormula.pos (.atom p) ∈ b := by
  unfold extractTrueAtomSet
  induction b with
  | nil =>
    simp only [List.foldl_nil, Finset.not_mem_empty, List.not_mem_nil, iff_false]
    intro h; exact h
  | cons sf rest ih =>
    simp only [List.foldl_cons, List.mem_cons]
    constructor
    · intro h
      -- Case split on the head element
      match hsign : sf.sign, hform : sf.formula with
      | .pos, .atom q =>
        simp only [hsign, hform] at h
        by_cases hpq : p = q
        · left
          subst hpq
          rfl
        · -- p ≠ q, so p must be in rest
          have h' : p ∈ List.foldl (fun acc sf =>
              match sf.sign, sf.formula with
              | .pos, .atom p => insert p acc
              | _, _ => acc) ∅ rest := by
            simp only [Finset.mem_insert] at h
            cases h with
            | inl heq => exact absurd heq hpq
            | inr hin => exact hin
          right
          exact ih.mp h'
      | .pos, _ =>
        simp only [hsign] at h
        right
        exact ih.mp h
      | .neg, _ =>
        simp only [hsign] at h
        right
        exact ih.mp h
    · intro h
      cases h with
      | inl heq =>
        -- sf is SignedFormula.pos (.atom p)
        simp only [SignedFormula.pos] at heq
        match hsign : sf.sign, hform : sf.formula with
        | .pos, .atom q =>
          simp only [hsign, hform, Finset.mem_insert]
          have : q = p := by
            have : sf = ⟨.pos, .atom p⟩ := heq
            simp only [SignedFormula.mk.injEq] at this
            cases this.2
            rfl
          left
          exact this.symm
        | .pos, _ =>
          -- This case is impossible: sf.formula must be .atom p
          have : sf = ⟨.pos, .atom p⟩ := heq
          simp only [SignedFormula.mk.injEq] at this
          cases hform
          exact (Formula.noConfusion this.2)
        | .neg, _ =>
          -- This case is impossible: sf.sign must be .pos
          have : sf = ⟨.pos, .atom p⟩ := heq
          simp only [SignedFormula.mk.injEq] at this
          cases hsign
          exact (Sign.noConfusion this.1)
      | inr hin =>
        -- p is in rest
        match hsign : sf.sign, hform : sf.formula with
        | .pos, .atom q =>
          simp only [hsign, hform, Finset.mem_insert]
          right
          exact ih.mpr hin
        | .pos, _ =>
          simp only [hsign]
          exact ih.mpr hin
        | .neg, _ =>
          simp only [hsign]
          exact ih.mpr hin

/--
Atom truth in extracted model: p is true at extracted world state
iff T(p) appears in the branch.
-/
theorem atom_true_iff_pos_in_branch (b : Branch) (p : String) :
    branchWorldStateValuation (extractBranchWorldState b) p ↔
    SignedFormula.pos (.atom p) ∈ b := by
  unfold branchWorldStateValuation extractBranchWorldState
  exact mem_extractTrueAtomSet_iff b p

/--
Atom falsity in extracted model: p is NOT in extracted world state
if F(p) appears in an open branch.

Note: This relies on branch consistency (no atom is both T(p) and F(p)).
-/
theorem atom_false_if_neg_in_open_branch (b : Branch)
    (hOpen : findClosure b = none) (p : String)
    (hneg : SignedFormula.neg (.atom p) ∈ b) :
    ¬branchWorldStateValuation (extractBranchWorldState b) p := by
  intro hval
  -- hval says T(p) is effectively in b
  rw [atom_true_iff_pos_in_branch] at hval
  -- Now we have both T(p) and F(p) in b, contradicting openness
  have hconsist := open_branch_consistent b hOpen p
  exact hconsist ⟨hval, hneg⟩

end Bimodal.Metalogic_v2.Decidability
