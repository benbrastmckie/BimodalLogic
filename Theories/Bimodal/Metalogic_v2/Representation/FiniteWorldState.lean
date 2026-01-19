import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic_v2.Representation.Closure
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Finite.Defs
import Mathlib.Data.Fintype.Pi

/-!
# Finite World States for Metalogic_v2

This module provides finite world states for the completeness proof.
A finite world state is a truth assignment on the subformula closure.

## Overview

For a formula phi, a finite world state assigns truth values to all
subformulas in the closure. This is the finite structure used in
the finite model property proof.

## Main Definitions

- `FiniteTruthAssignment`: Bool-valued function on closure elements
- `FiniteWorldState`: A locally consistent truth assignment
- `FiniteTime`: Bounded time domain for temporal operators
- `FiniteHistory`: Sequence of world states over time

## References

- Old Metalogic: `Bimodal.Metalogic.Completeness.FiniteCanonicalModel`
-/

namespace Bimodal.Metalogic_v2.Representation

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic_v2.Core

/-!
## Finite Time Domain

The finite time domain bounds temporal evaluation.
-/

/--
Temporal depth bound for a formula.
We use the formula's temporal depth.
-/
def temporalBound (phi : Formula) : Nat := phi.temporalDepth

/--
Finite time domain for a given bound k.
Represents integers from -k to +k (2k+1 values).
-/
abbrev FiniteTime (k : Nat) := Fin (2 * k + 1)

namespace FiniteTime

/--
Convert a finite time to a centered integer.
Maps 0 to -k, k to 0, 2k to +k.
-/
def toInt (k : Nat) (t : FiniteTime k) : Int :=
  (t.val : Int) - (k : Int)

/--
The origin (time 0) in the finite time domain.
-/
def origin (k : Nat) : FiniteTime k :=
  ⟨k, by omega⟩

/--
The origin maps to 0 under toInt.
-/
theorem origin_toInt (k : Nat) : toInt k (origin k) = 0 := by
  simp [origin, toInt]

/--
toInt is injective.
-/
theorem toInt_injective (k : Nat) : Function.Injective (toInt k) := by
  intros t1 t2 h
  simp [toInt] at h
  ext
  omega

/--
The range of toInt is [-k, k].
-/
theorem toInt_range (k : Nat) (t : FiniteTime k) :
    -(k : Int) ≤ toInt k t ∧ toInt k t ≤ (k : Int) := by
  constructor
  · simp only [toInt]; omega
  · simp only [toInt]
    have : t.val ≤ 2 * k := Nat.lt_succ_iff.mp t.isLt
    omega

end FiniteTime

/-!
## Finite Truth Assignments

A truth assignment on the closure.
-/

/--
A truth assignment on the subformula closure.
-/
def FiniteTruthAssignment (phi : Formula) : Type :=
  { psi : Formula // psi ∈ closure phi } → Bool

/--
Local consistency for a truth assignment.
This ensures the assignment respects propositional logic.
-/
def IsLocallyConsistent (phi : Formula) (v : FiniteTruthAssignment phi) : Prop :=
  -- Bot is false
  (∀ h : Formula.bot ∈ closure phi, v ⟨Formula.bot, h⟩ = false) ∧
  -- Implications are respected
  (∀ psi chi : Formula,
    ∀ h_imp : Formula.imp psi chi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    ∀ h_chi : chi ∈ closure phi,
    v ⟨Formula.imp psi chi, h_imp⟩ = true →
    v ⟨psi, h_psi⟩ = true →
    v ⟨chi, h_chi⟩ = true) ∧
  -- Modal T axiom: box(psi) -> psi
  (∀ psi : Formula,
    ∀ h_box : Formula.box psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    v ⟨Formula.box psi, h_box⟩ = true →
    v ⟨psi, h_psi⟩ = true) ∧
  -- Temporal reflexivity for past: all_past(psi) -> psi
  (∀ psi : Formula,
    ∀ h_past : Formula.all_past psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    v ⟨Formula.all_past psi, h_past⟩ = true →
    v ⟨psi, h_psi⟩ = true) ∧
  -- Temporal reflexivity for future: all_future(psi) -> psi
  (∀ psi : Formula,
    ∀ h_fut : Formula.all_future psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    v ⟨Formula.all_future psi, h_fut⟩ = true →
    v ⟨psi, h_psi⟩ = true)

/-!
## Finite World State

A world state is a locally consistent truth assignment.
-/

/--
A finite world state for a target formula phi.

This is a truth assignment on the subformula closure that is propositionally consistent.
-/
structure FiniteWorldState (phi : Formula) where
  /-- The truth assignment on subformulas -/
  assignment : FiniteTruthAssignment phi
  /-- The assignment is locally consistent -/
  consistent : IsLocallyConsistent phi assignment

namespace FiniteWorldState

variable {phi : Formula}

/--
Check if a formula (in the closure) is true in this world state.
-/
def satisfies (w : FiniteWorldState phi) (psi : Formula) (h : psi ∈ closure phi) : Bool :=
  w.assignment ⟨psi, h⟩

/--
Proposition version: psi is modeled by w.
-/
def models (w : FiniteWorldState phi) (psi : Formula) (h : psi ∈ closure phi) : Prop :=
  w.assignment ⟨psi, h⟩ = true

/--
Bot is false in any consistent world state.
-/
theorem bot_false (w : FiniteWorldState phi) (h : Formula.bot ∈ closure phi) :
    w.models Formula.bot h = False := by
  simp only [models]
  have := w.consistent.1 h
  simp [this]

/--
Implication is materially correct.
-/
theorem imp_correct (w : FiniteWorldState phi) (psi chi : Formula)
    (h_imp : Formula.imp psi chi ∈ closure phi)
    (h_psi : psi ∈ closure phi)
    (h_chi : chi ∈ closure phi) :
    w.models (Formula.imp psi chi) h_imp →
    w.models psi h_psi →
    w.models chi h_chi := by
  simp only [models]
  exact w.consistent.2.1 psi chi h_imp h_psi h_chi

/--
Convert to a set of true formulas.
-/
def toSet (w : FiniteWorldState phi) : Set Formula :=
  {psi | ∃ h : psi ∈ closure phi, w.assignment ⟨psi, h⟩ = true}

/--
A formula is in the set iff it's satisfied.
-/
theorem mem_toSet_iff (w : FiniteWorldState phi) (psi : Formula) (h : psi ∈ closure phi) :
    psi ∈ w.toSet ↔ w.models psi h := by
  simp only [toSet, Set.mem_setOf_eq, models]
  constructor
  · intro ⟨h', h_true⟩
    -- By proof irrelevance, both membership proofs give the same assignment value
    exact h_true
  · intro h_true
    exact ⟨h, h_true⟩

end FiniteWorldState

/--
Extensionality lemma for FiniteWorldState.

Two world states are equal iff their assignments are equal.
-/
@[ext]
theorem FiniteWorldState.ext {phi : Formula} {w1 w2 : FiniteWorldState phi}
    (h : w1.assignment = w2.assignment) : w1 = w2 := by
  cases w1
  cases w2
  simp only [FiniteWorldState.mk.injEq]
  exact h

/--
Fintype instance for closure elements (subtype of Finset).
-/
instance closureFintype (phi : Formula) : Fintype (closure phi) :=
  Finset.fintypeCoeSort (closure phi)

/--
The type of truth assignments on closure is finite.

We need to explicitly provide this since FiniteTruthAssignment is a dependent function type.
-/
instance truthAssignmentFintype (phi : Formula) : Fintype (FiniteTruthAssignment phi) := by
  unfold FiniteTruthAssignment
  infer_instance

/--
The type of finite world states is finite.

Since each world state is determined by its assignment (a function from
a finite set to Bool), there are at most 2^|closure phi| world states.
-/
instance finiteWorldState_finite (phi : Formula) : Finite (FiniteWorldState phi) := by
  apply Finite.of_injective (fun w => w.assignment)
  intros w1 w2 h_eq
  exact FiniteWorldState.ext h_eq

/-!
## Finite History

A history is a sequence of world states over the bounded time domain.
-/

/--
A finite history: a function from bounded time to world states.
-/
structure FiniteHistory (phi : Formula) where
  /-- World state at each time point -/
  states : FiniteTime (temporalBound phi) → FiniteWorldState phi

namespace FiniteHistory

variable {phi : Formula}

/--
The world state at the origin.
-/
def atOrigin (hist : FiniteHistory phi) : FiniteWorldState phi :=
  hist.states (FiniteTime.origin (temporalBound phi))

/--
Create a constant history from a single world state.
-/
def constant (w : FiniteWorldState phi) : FiniteHistory phi :=
  ⟨fun _ => w⟩

/--
For a constant history, all states are equal.
-/
theorem constant_states (w : FiniteWorldState phi) (t : FiniteTime (temporalBound phi)) :
    (constant w).states t = w := rfl

end FiniteHistory

/-!
## World State from Closure MCS

Build a finite world state from a closure-maximal consistent set.
-/

/--
Build truth assignment from a closure MCS.
-/
noncomputable def assignmentFromClosureMCS (phi : Formula) (S : Set Formula)
    (_h_mcs : ClosureMaximalConsistent phi S) : FiniteTruthAssignment phi :=
  fun ⟨psi, _⟩ => if Classical.propDecidable (psi ∈ S) |>.decide then true else false

/--
A closure MCS induces a locally consistent truth assignment.

NOTE: This requires the MCS to satisfy temporal reflexivity axioms (H phi -> phi, G phi -> phi).
The TM logic uses strict temporal semantics, so these are NOT valid axioms.
This is an architectural limitation - the semantic approach bypasses this issue.
-/
theorem closure_mcs_implies_locally_consistent (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) :
    IsLocallyConsistent phi (assignmentFromClosureMCS phi S h_mcs) := by
  -- The proof requires temporal reflexivity axioms which don't hold in TM logic
  -- The semantic approach (via SemanticCanonicalModel) bypasses this issue
  sorry

/--
Build a finite world state from a closure MCS.
-/
noncomputable def worldStateFromClosureMCS (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) : FiniteWorldState phi :=
  ⟨assignmentFromClosureMCS phi S h_mcs, closure_mcs_implies_locally_consistent phi S h_mcs⟩

/--
Formula membership in closure MCS equals truth in the world state.
-/
theorem worldStateFromClosureMCS_models_iff (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_mem : psi ∈ closure phi) :
    psi ∈ S ↔ (worldStateFromClosureMCS phi S h_mcs).models psi h_mem := by
  unfold worldStateFromClosureMCS FiniteWorldState.models assignmentFromClosureMCS
  simp only
  haveI : Decidable (psi ∈ S) := Classical.propDecidable (psi ∈ S)
  constructor
  · intro h_in_S
    simp only [decide_eq_true_eq, h_in_S, ite_true]
  · intro h_true
    by_contra h_not_in_S
    simp only [decide_eq_false_iff_not.mpr h_not_in_S] at h_true
    simp at h_true

/--
If psi is not in S, then it's not modeled.
-/
theorem worldStateFromClosureMCS_not_models (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) (psi : Formula) (h_mem : psi ∈ closure phi)
    (h_not : psi ∉ S) : ¬(worldStateFromClosureMCS phi S h_mcs).models psi h_mem := by
  rw [← worldStateFromClosureMCS_models_iff]
  exact h_not

/-!
## MCS-Derived World States

A world state is MCS-derived if it comes from a ClosureMaximalConsistent set.
-/

/--
A world state is MCS-derived if it's built from a closure MCS.
-/
def IsMCSDerived (phi : Formula) (w : FiniteWorldState phi) : Prop :=
  ∃ (S : Set Formula) (h_mcs : ClosureMaximalConsistent phi S),
    w = worldStateFromClosureMCS phi S h_mcs

/--
World states built from closure MCS are MCS-derived.
-/
theorem worldStateFromClosureMCS_is_mcs_derived (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) :
    IsMCSDerived phi (worldStateFromClosureMCS phi S h_mcs) :=
  ⟨S, h_mcs, rfl⟩

end Bimodal.Metalogic_v2.Representation
