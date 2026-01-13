import Bimodal.Syntax.Formula
import Bimodal.Semantics
import Bimodal.ProofSystem
import Bimodal.Metalogic.Decidability.SignedFormula
import Mathlib.Data.Finset.Basic
import Mathlib.Data.List.Basic
import Mathlib.Data.Fin.Basic
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Order.Zorn
import Mathlib.Data.Fintype.Pi

/-!
# Finite Canonical Model for Completeness

This module implements the finite canonical model construction for proving completeness
of TM bimodal logic. The key insight is that for any finite formula phi, we only need
a finite countermodel to falsify it if it's not derivable.

## Approach

The finite model property for TM logic:
- **Temporal bound**: `temporalDepth phi` bounds the time domain needed
- **Modal bound**: `modalDepth phi` bounds the number of world histories needed
- **Subformula bound**: The subformula closure `closure phi` is finite

This approach sidesteps the compositionality gaps in the infinite Duration-based construction
by working directly with finite structures.

## Main Definitions

### Phase 1: Finite Time Domain
- `FiniteTime k`: Time domain `Fin (2 * k + 1)` representing integers from `-k` to `+k`
- `FiniteTime.toInt`: Conversion to centered integers
- `closure`: Subformula closure as a Finset

### Phase 2-7: (Subsequent phases)
- Finite world states
- Finite task relation
- Finite canonical model
- Truth lemma
- Completeness theorems

## References

* Modal Logic, Blackburn et al. - Finite model property
* Goldblatt, Logics of Time and Computation - Temporal completeness
* Research report: .claude/specs/458_extend_canonical_history_full_domain/reports/research-004.md
-/

namespace Bimodal.Metalogic.Completeness

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.ProofSystem
open Bimodal.Metalogic.Decidability

/-!
## Phase 1: Finite Time Domain and Subformula Closure

The finite time domain is `Fin (2 * k + 1)` where `k = temporalDepth phi`.
This represents integers from `-k` to `+k` centered at the origin.
-/

/--
Finite time domain for a given temporal bound `k`.

The type `FiniteTime k` represents the integers from `-k` to `+k`,
which is `2k + 1` values total. We use `Fin (2 * k + 1)` as the carrier.

**Key property**: For a formula `phi`, setting `k = temporalDepth phi` gives
a time domain sufficient to evaluate all temporal subformulas.
-/
abbrev FiniteTime (k : Nat) := Fin (2 * k + 1)

namespace FiniteTime

/--
Convert a finite time to a centered integer.

Maps `Fin (2 * k + 1)` to `Int` such that:
- 0 maps to -k
- k maps to 0
- 2k maps to +k

**Examples** (for k = 2, so domain is Fin 5 = {0, 1, 2, 3, 4}):
- toInt 0 = -2
- toInt 1 = -1
- toInt 2 = 0
- toInt 3 = 1
- toInt 4 = 2
-/
def toInt (k : Nat) (t : FiniteTime k) : Int :=
  (t.val : Int) - (k : Int)

/--
The origin (time 0) in the finite time domain.

This is the element that maps to 0 under `toInt`.
-/
def origin (k : Nat) : FiniteTime k :=
  ⟨k, by omega⟩

/--
The origin maps to 0 under `toInt`.
-/
theorem origin_toInt (k : Nat) : toInt k (origin k) = 0 := by
  simp [origin, toInt]

/--
The minimum time (maps to -k).
-/
def minTime (k : Nat) : FiniteTime k :=
  ⟨0, by omega⟩

/--
The minimum time maps to -k under `toInt`.
-/
theorem minTime_toInt (k : Nat) : toInt k (minTime k) = -(k : Int) := by
  simp [minTime, toInt]

/--
The maximum time (maps to +k).
-/
def maxTime (k : Nat) : FiniteTime k :=
  ⟨2 * k, by omega⟩

/--
The maximum time maps to +k under `toInt`.
-/
theorem maxTime_toInt (k : Nat) : toInt k (maxTime k) = (k : Int) := by
  simp only [maxTime, toInt]
  omega

/--
toInt is injective: different finite times map to different integers.
-/
theorem toInt_injective (k : Nat) : Function.Injective (toInt k) := by
  intros t1 t2 h
  simp [toInt] at h
  ext
  omega

/--
The range of toInt is exactly [-k, k].
-/
theorem toInt_range (k : Nat) (t : FiniteTime k) :
    -(k : Int) ≤ toInt k t ∧ toInt k t ≤ (k : Int) := by
  constructor
  · simp only [toInt]
    omega
  · simp only [toInt]
    have : t.val ≤ 2 * k := Nat.lt_succ_iff.mp t.isLt
    omega

/--
Any integer in [-k, k] is in the range of toInt.
-/
theorem toInt_surj_on_range (k : Nat) (n : Int)
    (h_lower : -(k : Int) ≤ n) (h_upper : n ≤ (k : Int)) :
    ∃ t : FiniteTime k, toInt k t = n := by
  -- We need to find t such that t.val - k = n, i.e., t.val = n + k
  have h_nonneg : 0 ≤ n + k := by omega
  have h_bound : n + k < 2 * k + 1 := by omega
  have h_toNat_bound : (n + k).toNat < 2 * k + 1 := by
    rw [Int.toNat_lt h_nonneg]
    exact h_bound
  use ⟨(n + k).toNat, h_toNat_bound⟩
  simp only [toInt, Int.toNat_of_nonneg h_nonneg]
  omega

/--
Successor time: increment by 1 if possible.

Returns `some (t + 1)` if `t + 1` is in bounds, otherwise `none`.
This is used for forward temporal reasoning within the finite domain.
-/
def succ? (k : Nat) (t : FiniteTime k) : Option (FiniteTime k) :=
  if h : t.val + 1 < 2 * k + 1 then
    some ⟨t.val + 1, h⟩
  else
    none

/--
Predecessor time: decrement by 1 if possible.

Returns `some (t - 1)` if `t - 1` is in bounds, otherwise `none`.
This is used for backward temporal reasoning within the finite domain.
-/
def pred? (k : Nat) (t : FiniteTime k) : Option (FiniteTime k) :=
  if h : 0 < t.val then
    some ⟨t.val - 1, by omega⟩
  else
    none

/--
Successor increments toInt by 1.
-/
theorem succ_toInt (k : Nat) (t : FiniteTime k) (t' : FiniteTime k)
    (h : succ? k t = some t') : toInt k t' = toInt k t + 1 := by
  simp only [succ?] at h
  split_ifs at h with h_bound
  simp only [Option.some.injEq] at h
  subst h
  unfold toInt
  push_cast
  omega

/--
Predecessor decrements toInt by 1.
-/
theorem pred_toInt (k : Nat) (t : FiniteTime k) (t' : FiniteTime k)
    (h : pred? k t = some t') : toInt k t' = toInt k t - 1 := by
  simp only [pred?] at h
  split_ifs at h with h_bound
  simp only [Option.some.injEq] at h
  subst h
  unfold toInt
  -- t.val ≥ 1 from h_bound, so t.val - 1 as Nat is correct
  have h1 : 1 ≤ t.val := h_bound
  -- (t.val - 1 : Nat) as Int equals (t.val : Int) - 1
  have h3 : ((t.val - 1 : Nat) : Int) = (t.val : Int) - 1 := Int.ofNat_sub h1
  rw [h3]
  omega

end FiniteTime

/-!
## Subformula Closure as Finset

We convert the list-based `subformulas` function to a `Finset` for finite
model construction. This uses the existing implementation from SignedFormula.lean.
-/

/--
Subformula closure of a formula as a Finset.

This is the set of all subformulas of `phi`, including `phi` itself.
The finiteness is guaranteed because formulas are inductively defined.

**Key property**: Any formula that appears during tableau expansion
or truth evaluation is in the closure.
-/
def closure (phi : Formula) : Finset Formula :=
  (Formula.subformulas phi).toFinset

/--
The formula itself is in its closure.
-/
theorem self_mem_closure (phi : Formula) : phi ∈ closure phi := by
  simp [closure]
  exact Formula.self_mem_subformulas phi

/--
Closure of implication contains both sides.
-/
theorem imp_left_mem_closure (psi chi : Formula) :
    psi ∈ closure (Formula.imp psi chi) := by
  simp [closure]
  exact Formula.imp_left_mem_subformulas psi chi

theorem imp_right_mem_closure (psi chi : Formula) :
    chi ∈ closure (Formula.imp psi chi) := by
  simp [closure]
  exact Formula.imp_right_mem_subformulas psi chi

/--
Subformulas of a box formula are in the closure.
-/
theorem box_sub_mem_closure (psi : Formula) :
    psi ∈ closure (Formula.box psi) := by
  simp only [closure, Formula.subformulas, List.toFinset_cons]
  exact Finset.mem_insert_of_mem (List.mem_toFinset.mpr (Formula.self_mem_subformulas psi))

/--
Subformulas of an all_past formula are in the closure.
-/
theorem all_past_sub_mem_closure (psi : Formula) :
    psi ∈ closure (Formula.all_past psi) := by
  simp only [closure, Formula.subformulas, List.toFinset_cons]
  exact Finset.mem_insert_of_mem (List.mem_toFinset.mpr (Formula.self_mem_subformulas psi))

/--
Subformulas of an all_future formula are in the closure.
-/
theorem all_future_sub_mem_closure (psi : Formula) :
    psi ∈ closure (Formula.all_future psi) := by
  simp only [closure, Formula.subformulas, List.toFinset_cons]
  exact Finset.mem_insert_of_mem (List.mem_toFinset.mpr (Formula.self_mem_subformulas psi))

/--
The closure is finite (by construction as a Finset, trivially true).
-/
theorem closure_is_finite (phi : Formula) : (closure phi : Set Formula).Finite :=
  Set.toFinite (closure phi : Set Formula)

/--
Closure is monotonic with respect to subformula relation.

If `psi` is a subformula of `phi`, then `closure psi ⊆ closure phi`.
-/
theorem closure_mono {phi psi : Formula} (h : psi ∈ closure phi) :
    closure psi ⊆ closure phi := by
  intro chi h_chi
  simp [closure] at *
  -- chi is a subformula of psi, psi is a subformula of phi
  -- Need to show chi is a subformula of phi
  -- This requires structural induction on formula
  sorry -- Will be filled in during implementation

/--
Size of the closure (number of distinct subformulas).

This bounds the complexity of the finite model.
-/
def closureSize (phi : Formula) : Nat := (closure phi).card

/--
The closure size is at most the complexity of the formula.
-/
theorem closureSize_le_complexity (phi : Formula) :
    closureSize phi ≤ phi.complexity := by
  simp [closureSize, closure]
  -- Each subformula contributes at most 1 to complexity
  sorry -- Will be filled in during implementation

/--
The negation closure: if phi is in closure, so is neg phi (if neg phi exists as subformula).

Note: This is NOT automatically true since neg is defined (phi -> bot).
We need to handle negations specially in the finite model.
-/
def closureWithNeg (phi : Formula) : Finset Formula :=
  closure phi ∪ (closure phi).image Formula.neg

/-!
## Temporal Bound

The temporal bound determines the size of the finite time domain needed.
-/

/--
Temporal bound for a formula.

This is the temporal depth, which determines the size of the finite
time domain needed to evaluate the formula.
-/
def temporalBound (phi : Formula) : Nat := phi.temporalDepth

/--
The finite time domain for a formula is `FiniteTime (temporalBound phi)`.
-/
abbrev FormulaTime (phi : Formula) := FiniteTime (temporalBound phi)

/-!
## Consistency Definitions (for Phase 2+)

These definitions prepare the ground for finite world state construction.
We define consistency restricted to a subformula closure.
-/

/--
A finite truth assignment on a subformula closure.

This assigns a boolean (true/false) to each formula in the closure.
-/
def FiniteTruthAssignment (phi : Formula) := (closure phi) → Bool

/--
A finite truth assignment is propositionally consistent if it respects:
1. Not both a formula and its negation are true
2. Implications are respected: if (psi -> chi) is true and psi is true, then chi is true
3. Bot is not true
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
    v ⟨chi, h_chi⟩ = true)

/-!
## Properties of Finite Time Domain Arithmetic

These lemmas support arithmetic operations on finite times.
-/

/--
The total number of time points in the finite domain.
-/
def timeCount (k : Nat) : Nat := 2 * k + 1

/--
Fintype instance for FiniteTime.
-/
instance (k : Nat) : Fintype (FiniteTime k) :=
  inferInstance

/--
The finite time domain has exactly `2k + 1` elements.
-/
theorem finiteTime_card (k : Nat) : Fintype.card (FiniteTime k) = 2 * k + 1 := by
  simp [Fintype.card_fin]

/-!
## Phase 2: Finite World States

A finite world state is a locally consistent truth assignment on the subformula closure.
This represents a "world" in the finite canonical model where each subformula has a
definite truth value that respects propositional logic.
-/

/--
A finite world state for a target formula phi.

This is a truth assignment on the subformula closure that is propositionally consistent.
Each world state represents a possible "world" in the finite canonical model.

**Key properties**:
- Assignment is total on `closure phi`
- Bot is false
- Implications are materially respected
- Finite: at most `2^|closure phi|` possible states
-/
structure FiniteWorldState (phi : Formula) where
  /-- The truth assignment on subformulas -/
  assignment : FiniteTruthAssignment phi
  /-- The assignment is propositionally consistent -/
  consistent : IsLocallyConsistent phi assignment

namespace FiniteWorldState

variable {phi : Formula}

/--
Check if a formula (in the closure) is true in this world state.
-/
def satisfies (w : FiniteWorldState phi) (psi : Formula) (h : psi ∈ closure phi) : Bool :=
  w.assignment ⟨psi, h⟩

/--
Notation-friendly version: w |= psi means psi is true in w.
Returns Prop instead of Bool for logical statements.
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
Implication is materially correct in any consistent world state.
-/
theorem imp_correct (w : FiniteWorldState phi) (psi chi : Formula)
    (h_imp : Formula.imp psi chi ∈ closure phi)
    (h_psi : psi ∈ closure phi)
    (h_chi : chi ∈ closure phi) :
    w.models (Formula.imp psi chi) h_imp →
    w.models psi h_psi →
    w.models chi h_chi := by
  simp only [models]
  exact w.consistent.2 psi chi h_imp h_psi h_chi

/--
Convert a world state to a set of formulas (the "true" formulas).
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

We need to explicitly unfold `FiniteTruthAssignment` to help Lean find the instance.
-/
instance truthAssignmentFintype (phi : Formula) : Fintype (FiniteTruthAssignment phi) :=
  Pi.instFintype

/--
The type of finite world states is finite.

Since each world state is determined by its assignment (a function from
a finite set to Bool), there are at most 2^|closure phi| world states.
-/
instance finiteWorldState_finite (phi : Formula) : Finite (FiniteWorldState phi) := by
  apply Finite.of_injective (fun w => w.assignment)
  intros w1 w2 h_eq
  exact FiniteWorldState.ext h_eq

/--
Decidable equality for finite world states.

Two world states are equal iff their assignments are equal.
-/
noncomputable instance finiteWorldState_decidableEq (phi : Formula) :
    DecidableEq (FiniteWorldState phi) := by
  intros w1 w2
  by_cases h : w1.assignment = w2.assignment
  · exact isTrue (FiniteWorldState.ext h)
  · exact isFalse (fun h_eq => h (congrArg FiniteWorldState.assignment h_eq))

/-!
## Phase 2 Continued: World State Constructions

These definitions support building world states from maximal consistent sets
(the connection between syntactic and semantic constructions).
-/

open Classical in
/--
Given a subset of formulas (restricted to the closure), create a truth assignment.

This is used to convert maximal consistent sets to world states.
We use Classical.decide for set membership since sets may not be decidable.
-/
noncomputable def assignmentFromSet (phi : Formula) (S : Set Formula) :
    FiniteTruthAssignment phi :=
  fun ⟨psi, _⟩ => if psi ∈ S then true else false

/--
Build a world state from a set of formulas, given consistency proof.

This is the key connection between the syntactic (maximal consistent sets)
and semantic (world states) sides of completeness.
-/
noncomputable def worldStateFromSet (phi : Formula) (S : Set Formula)
    (h_consistent : IsLocallyConsistent phi (assignmentFromSet phi S)) :
    FiniteWorldState phi :=
  ⟨assignmentFromSet phi S, h_consistent⟩

/-!
## Summary of Phase 2 Definitions

- `FiniteWorldState phi`: Structure combining assignment with consistency
- `FiniteWorldState.satisfies`: Check formula truth in a state
- `FiniteWorldState.models`: Propositional version of satisfies
- `FiniteWorldState.toSet`: Convert state to set of true formulas
- `Finite (FiniteWorldState phi)`: World states are finite
- `assignmentFromSet`: Convert set to truth assignment
- `worldStateFromSet`: Build world state from consistent set
-/

end Bimodal.Metalogic.Completeness
