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
A finite truth assignment is locally consistent if it respects:
1. Bot is not true
2. Implications are respected: if (psi -> chi) is true and psi is true, then chi is true
3. Modal T axiom: if box(psi) is true, then psi is true (reflexivity)
4. Temporal reflexivity: if all_past(psi) is true, then psi is true
5. Temporal reflexivity: if all_future(psi) is true, then psi is true

These constraints ensure the world state corresponds to a maximal consistent set
restricted to the subformula closure.
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
  -- Modal T axiom: box(psi) -> psi (for subformulas in closure)
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
  exact w.consistent.2.1 psi chi h_imp h_psi h_chi

/--
Modal T axiom: box(psi) implies psi in any consistent world state.
-/
theorem box_t (w : FiniteWorldState phi) (psi : Formula)
    (h_box : Formula.box psi ∈ closure phi)
    (h_psi : psi ∈ closure phi) :
    w.models (Formula.box psi) h_box → w.models psi h_psi := by
  simp only [models]
  exact w.consistent.2.2.1 psi h_box h_psi

/--
Temporal reflexivity for past: all_past(psi) implies psi.
-/
theorem all_past_refl (w : FiniteWorldState phi) (psi : Formula)
    (h_past : Formula.all_past psi ∈ closure phi)
    (h_psi : psi ∈ closure phi) :
    w.models (Formula.all_past psi) h_past → w.models psi h_psi := by
  simp only [models]
  exact w.consistent.2.2.2.1 psi h_past h_psi

/--
Temporal reflexivity for future: all_future(psi) implies psi.
-/
theorem all_future_refl (w : FiniteWorldState phi) (psi : Formula)
    (h_fut : Formula.all_future psi ∈ closure phi)
    (h_psi : psi ∈ closure phi) :
    w.models (Formula.all_future psi) h_fut → w.models psi h_psi := by
  simp only [models]
  exact w.consistent.2.2.2.2 psi h_fut h_psi

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

/-!
## Phase 3: Finite Task Relation

The finite task relation connects world states via tasks while respecting subformula
transfer properties. This is the canonical relation for completeness, restricted
to formulas in the subformula closure.

**Key Properties**:
1. **Box transfer**: If box(psi) true at source, then psi true at target (for psi in closure)
2. **Future transfer**: If d > 0 and all_future(psi) true at source, then psi true at target
3. **Past transfer**: If d < 0 and all_past(psi) true at source, then psi true at target
4. **Persistence**: Box formulas persist along the relation

**Design Note**:
Unlike the infinite canonical model which used Duration for time, we use Int directly
since the finite model's time domain is finite anyway (bounded by temporal depth).
-/

/--
The finite task relation for world states restricted to a target formula's closure.

`finite_task_rel phi w d u` holds when:
1. For all box(psi) in closure: if box(psi) true at w, then psi true at u
2. For all all_future(psi) in closure: if d > 0 and all_future(psi) true at w, then psi true at u
3. For all all_past(psi) in closure: if d < 0 and all_past(psi) true at w, then psi true at u
4. Box formulas persist (unconditionally)
5. Future formulas persist when d >= 0 (forward in time)
6. Past formulas persist when d <= 0 (backward in time)

This is a semantic relation: it describes when state u is a valid task-successor
of state w after duration d.
-/
def finite_task_rel (phi : Formula) (w : FiniteWorldState phi) (d : Int)
    (u : FiniteWorldState phi) : Prop :=
  -- Box transfer: box(psi) at w implies psi at u (for psi in closure)
  (∀ psi : Formula,
    ∀ h_box : Formula.box psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    w.models (Formula.box psi) h_box → u.models psi h_psi) ∧
  -- Future transfer: all_future(psi) at w implies psi at u when d > 0
  (∀ psi : Formula,
    ∀ h_fut : Formula.all_future psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    d > 0 → w.models (Formula.all_future psi) h_fut → u.models psi h_psi) ∧
  -- Past transfer: all_past(psi) at w implies psi at u when d < 0
  (∀ psi : Formula,
    ∀ h_past : Formula.all_past psi ∈ closure phi,
    ∀ h_psi : psi ∈ closure phi,
    d < 0 → w.models (Formula.all_past psi) h_past → u.models psi h_psi) ∧
  -- Box persistence: box formulas persist along the relation
  (∀ psi : Formula,
    ∀ h_box : Formula.box psi ∈ closure phi,
    w.models (Formula.box psi) h_box → u.models (Formula.box psi) h_box) ∧
  -- Future persistence: all_future(psi) persists when moving forward (d >= 0)
  (∀ psi : Formula,
    ∀ h_fut : Formula.all_future psi ∈ closure phi,
    d ≥ 0 → w.models (Formula.all_future psi) h_fut → u.models (Formula.all_future psi) h_fut) ∧
  -- Past persistence: all_past(psi) persists when moving backward (d <= 0)
  (∀ psi : Formula,
    ∀ h_past : Formula.all_past psi ∈ closure phi,
    d ≤ 0 → w.models (Formula.all_past psi) h_past → u.models (Formula.all_past psi) h_past)

namespace FiniteTaskRel

variable {phi : Formula}

/--
Nullity: zero-duration task is identity.

For d = 0, any world state relates to itself. This is the reflexivity property
required by TaskFrame.
-/
theorem nullity (w : FiniteWorldState phi) : finite_task_rel phi w 0 w := by
  unfold finite_task_rel
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Box transfer: use T axiom (box(psi) -> psi)
    intros psi h_box h_psi h_w_box
    exact FiniteWorldState.box_t w psi h_box h_psi h_w_box
  · -- Future transfer: vacuously true for d = 0 (since ¬(0 > 0))
    intros psi h_fut h_psi h_d_pos
    omega
  · -- Past transfer: vacuously true for d = 0 (since ¬(0 < 0))
    intros psi h_past h_psi h_d_neg
    omega
  · -- Box persistence: trivially true (w relates to w)
    intros psi h_box h_w_box
    exact h_w_box
  · -- Future persistence: trivially true (w relates to w)
    intros psi h_fut _ h_w_fut
    exact h_w_fut
  · -- Past persistence: trivially true (w relates to w)
    intros psi h_past _ h_w_past
    exact h_w_past

/--
Compositionality: sequential tasks compose with time addition.

If `finite_task_rel phi w x u` and `finite_task_rel phi u y v`,
then `finite_task_rel phi w (x + y) v`.
-/
theorem compositionality (w u v : FiniteWorldState phi) (x y : Int)
    (h_wu : finite_task_rel phi w x u) (h_uv : finite_task_rel phi u y v) :
    finite_task_rel phi w (x + y) v := by
  unfold finite_task_rel at *
  obtain ⟨h_wu_box, h_wu_fut, h_wu_past, h_wu_box_pers, h_wu_fut_pers, h_wu_past_pers⟩ := h_wu
  obtain ⟨h_uv_box, h_uv_fut, h_uv_past, h_uv_box_pers, h_uv_fut_pers, h_uv_past_pers⟩ := h_uv
  refine ⟨?_, ?_, ?_, ?_, ?_, ?_⟩
  · -- Box transfer: box(psi) at w -> psi at v
    intros psi h_box h_psi h_w_box
    have h_u_box : u.models (Formula.box psi) h_box := h_wu_box_pers psi h_box h_w_box
    exact h_uv_box psi h_box h_psi h_u_box
  · -- Future transfer for x + y > 0
    intros psi h_fut h_psi h_sum_pos h_w_fut
    by_cases hx : x > 0
    · -- If x > 0: by future transfer w->u, psi is true at u
      -- But we need psi at v, not u. The issue is we don't have general persistence for psi.
      -- However, if y >= 0, we can use future persistence w->u, then future transfer at u->v
      by_cases hy : y ≥ 0
      · -- x > 0 and y >= 0: Use future persistence w->u (since x > 0 means x >= 0),
        -- then all_future(psi) at u, then future transfer u->v (y > 0 if y > 0)
        have hx_ge : x ≥ 0 := le_of_lt hx
        have h_u_fut : u.models (Formula.all_future psi) h_fut := h_wu_fut_pers psi h_fut hx_ge h_w_fut
        by_cases hy_pos : y > 0
        · exact h_uv_fut psi h_fut h_psi hy_pos h_u_fut
        · -- y = 0: use T axiom
          push_neg at hy_pos
          have hy_eq : y = 0 := le_antisymm hy_pos hy
          have h_v_fut : v.models (Formula.all_future psi) h_fut := h_uv_fut_pers psi h_fut hy h_u_fut
          exact FiniteWorldState.all_future_refl v psi h_fut h_psi h_v_fut
      · -- x > 0 and y < 0: x + y > 0 means x > -y > 0
        push_neg at hy
        have h_u_psi : u.models psi h_psi := h_wu_fut psi h_fut h_psi hx h_w_fut
        -- Need psi to persist from u to v when y < 0
        -- We don't have general psi persistence, so this case is problematic
        -- Actually, for the canonical model, we need a different approach here
        sorry
    · -- x <= 0
      push_neg at hx
      by_cases hy : y > 0
      · -- x <= 0 and y > 0: Use future persistence (x >= 0? No, x <= 0)
        -- If x <= 0, future formulas may not persist from w to u
        -- But x + y > 0 and x <= 0 means y > -x >= 0, so y > 0
        -- We need all_future(psi) at u. If x = 0, it persists. If x < 0, it may not.
        by_cases hx_eq : x = 0
        · -- x = 0: future persistence applies (0 >= 0)
          subst hx_eq
          have h_u_fut : u.models (Formula.all_future psi) h_fut := h_wu_fut_pers psi h_fut (le_refl 0) h_w_fut
          exact h_uv_fut psi h_fut h_psi hy h_u_fut
        · -- x < 0: This is the hard case
          have hx_neg : x < 0 := lt_of_le_of_ne hx hx_eq
          -- Future formulas don't persist backward in time
          -- This requires a different approach - maybe tracking what happens along paths
          sorry
      · -- x <= 0 and y <= 0: x + y <= 0, but we need x + y > 0, contradiction
        omega
  · -- Past transfer for x + y < 0 (symmetric to future case)
    intros psi h_past h_psi h_sum_neg h_w_past
    by_cases hx : x < 0
    · by_cases hy : y ≤ 0
      · have hx_le : x ≤ 0 := le_of_lt hx
        have h_u_past : u.models (Formula.all_past psi) h_past := h_wu_past_pers psi h_past hx_le h_w_past
        by_cases hy_neg : y < 0
        · exact h_uv_past psi h_past h_psi hy_neg h_u_past
        · push_neg at hy_neg
          have hy_eq : y = 0 := le_antisymm hy hy_neg
          have h_v_past : v.models (Formula.all_past psi) h_past := h_uv_past_pers psi h_past hy h_u_past
          exact FiniteWorldState.all_past_refl v psi h_past h_psi h_v_past
      · push_neg at hy
        sorry -- Similar to future case: x < 0, y > 0, hard case
    · push_neg at hx
      by_cases hy : y < 0
      · by_cases hx_eq : x = 0
        · subst hx_eq
          have h_u_past : u.models (Formula.all_past psi) h_past := h_wu_past_pers psi h_past (le_refl 0) h_w_past
          exact h_uv_past psi h_past h_psi hy h_u_past
        · sorry -- x > 0, hard case
      · omega
  · -- Box persistence: by transitivity
    intros psi h_box h_w_box
    have h_u_box := h_wu_box_pers psi h_box h_w_box
    exact h_uv_box_pers psi h_box h_u_box
  · -- Future persistence for x + y >= 0
    intros psi h_fut h_sum_ge h_w_fut
    by_cases hx_ge : x ≥ 0
    · have h_u_fut := h_wu_fut_pers psi h_fut hx_ge h_w_fut
      by_cases hy_ge : y ≥ 0
      · exact h_uv_fut_pers psi h_fut hy_ge h_u_fut
      · -- x >= 0 and y < 0 but x + y >= 0: means x >= -y > 0
        push_neg at hy_ge
        -- all_future at u, but y < 0 so future formulas may not persist u->v
        sorry
    · -- x < 0: future formulas may not persist w->u
      push_neg at hx_ge
      sorry
  · -- Past persistence for x + y <= 0
    intros psi h_past h_sum_le h_w_past
    by_cases hx_le : x ≤ 0
    · have h_u_past := h_wu_past_pers psi h_past hx_le h_w_past
      by_cases hy_le : y ≤ 0
      · exact h_uv_past_pers psi h_past hy_le h_u_past
      · push_neg at hy_le
        sorry
    · push_neg at hx_le
      sorry

end FiniteTaskRel

/-!
## Summary of Phase 3 Definitions

- `finite_task_rel phi w d u`: Canonical task relation restricted to closure
- `FiniteTaskRel.nullity`: Zero-duration task is identity (reflexivity) - PROVEN
- `FiniteTaskRel.compositionality`: Sequential tasks compose (transitivity) - PARTIAL

**Key Properties of finite_task_rel**:
1. Box transfer + persistence (unconditional)
2. Future transfer (when d > 0) + persistence (when d >= 0)
3. Past transfer (when d < 0) + persistence (when d <= 0)

**Nullity**: Proven using:
- T axiom for box (box(psi) -> psi)
- Temporal reflexivity (all_future(psi) -> psi, all_past(psi) -> psi)
- Trivial persistence (w relates to itself)

**Compositionality Status**:
- Box transfer and persistence: PROVEN (by transitivity)
- Temporal cases with same-sign durations: PROVEN
- Temporal cases with mixed-sign durations: PARTIAL (7 sorry gaps)

**Known Gaps in Compositionality**:
The mixed-sign cases (e.g., x > 0 and y < 0) require tracking information
about intermediate states along the path. The current relation only captures
endpoint properties, not path properties. These cases arise when:
- Future transfer at w->u (x > 0), then moving backward u->v (y < 0)
- Past transfer at w->u (x < 0), then moving forward u->v (y > 0)

These gaps may require a different approach:
1. Strengthen the relation to include more persistence conditions
2. Use a path-based construction instead of endpoint-based
3. Accept these as axioms for now and prove them semantically later
-/

/-!
## Phase 4: Finite Canonical Frame and Model

This phase assembles the TaskFrame and TaskModel structures using the
finite world states and task relation defined above.
-/

/--
The finite canonical frame for a target formula.

This is a TaskFrame with:
- World states: `FiniteWorldState phi`
- Time domain: `Int` (will be restricted to finite range in histories)
- Task relation: `finite_task_rel phi`

**Note**: We use `Int` as the time type (not `FiniteTime`) because the
TaskFrame structure requires an ordered additive group. The finite time
bound is enforced at the history level, not the frame level.
-/
noncomputable def FiniteCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := FiniteWorldState phi
  task_rel := finite_task_rel phi
  nullity := FiniteTaskRel.nullity
  compositionality := fun w u v x y h_wu h_uv => FiniteTaskRel.compositionality w u v x y h_wu h_uv

/--
The valuation for the finite canonical model.

An atom `p` is true at world state `w` iff `atom p` is in the closure
and is assigned true by `w`.

**Note**: If `atom p` is not in the closure of `phi`, the valuation is
vacuously false (atoms outside the closure don't matter for truth of phi).
-/
def finite_valuation (phi : Formula) : FiniteWorldState phi → String → Prop :=
  fun w p =>
    ∃ h : Formula.atom p ∈ closure phi, w.models (Formula.atom p) h

/--
The finite canonical model for a target formula.

Combines the finite canonical frame with the finite valuation.
-/
noncomputable def FiniteCanonicalModel (phi : Formula) : TaskModel (FiniteCanonicalFrame phi) where
  valuation := finite_valuation phi

/-!
### Finite Histories

A finite history is a function from the finite time domain to world states,
such that consecutive states are related by the task relation.
-/

/--
A finite history for a target formula.

Maps each time in `FiniteTime (temporalBound phi)` to a world state,
with the constraint that consecutive times are related by the task relation.
-/
structure FiniteHistory (phi : Formula) where
  /-- The assignment of world states to times -/
  states : FiniteTime (temporalBound phi) → FiniteWorldState phi
  /-- Consecutive states are related by unit task relation (forward) -/
  forward_rel : ∀ t : FiniteTime (temporalBound phi),
    ∀ t' : FiniteTime (temporalBound phi),
    FiniteTime.succ? (temporalBound phi) t = some t' →
    finite_task_rel phi (states t) 1 (states t')
  /-- Consecutive states are related by unit task relation (backward) -/
  backward_rel : ∀ t : FiniteTime (temporalBound phi),
    ∀ t' : FiniteTime (temporalBound phi),
    FiniteTime.pred? (temporalBound phi) t = some t' →
    finite_task_rel phi (states t) (-1) (states t')

namespace FiniteHistory

variable {phi : Formula}

/--
Get the world state at a given finite time.
-/
def stateAt (h : FiniteHistory phi) (t : FiniteTime (temporalBound phi)) :
    FiniteWorldState phi :=
  h.states t

/--
Get the world state at the origin (time 0).
-/
def originState (h : FiniteHistory phi) : FiniteWorldState phi :=
  h.states (FiniteTime.origin (temporalBound phi))

end FiniteHistory

/-!
### Converting Finite Histories to World Histories

To use the finite canonical model with the existing truth definition,
we need to convert finite histories to world histories. This requires
defining:
1. A domain predicate (which times are "valid")
2. A mapping from valid times to world states

For the finite model, all times in the finite domain are valid.
-/

/--
Convert a finite time to an integer (the time coordinate).
-/
def finiteTimeToInt (phi : Formula) (t : FiniteTime (temporalBound phi)) : Int :=
  FiniteTime.toInt (temporalBound phi) t

/--
Domain predicate for finite histories: time is valid if it's in [-k, k].
-/
def FiniteHistoryDomain (phi : Formula) (t : Int) : Prop :=
  -(temporalBound phi : Int) ≤ t ∧ t ≤ (temporalBound phi : Int)

/--
The domain is decidable.
-/
instance (phi : Formula) : DecidablePred (FiniteHistoryDomain phi) := by
  intro t
  unfold FiniteHistoryDomain
  infer_instance

/-!
## Summary of Phase 4 Definitions

- `FiniteCanonicalFrame phi`: TaskFrame using finite world states and task relation
- `finite_valuation phi`: Valuation based on atom membership in closure
- `FiniteCanonicalModel phi`: TaskModel combining frame and valuation
- `FiniteHistory phi`: Time-indexed function to world states with relation constraints
- `FiniteHistoryDomain phi`: Domain predicate for finite time bounds

**Key Properties**:
- Frame satisfies TaskFrame axioms (via nullity and compositionality of relation)
- Valuation is well-defined for atoms in closure
- Histories encode the task relation constraints between consecutive times
-/

/-!
## Phase 5: Finite Existence Lemmas

The existence lemmas establish that:
1. Any consistent world state can be extended forward to time t+1
2. Any consistent world state can be extended backward to time t-1
3. From an initial state, we can construct a full finite history

These are the key lemmas enabling the construction of countermodels for
unprovable formulas.
-/

/--
Forward existence: given a consistent world state, there exists a consistent
successor state that satisfies the forward task relation.

**Proof sketch**:
1. Start with the required transfer formulas (from all_future)
2. Use Lindenbaum extension to complete to maximal consistent set
3. Verify the resulting state satisfies finite_task_rel

This is stated as an axiom for now; the full proof requires the
Lindenbaum lemma infrastructure restricted to the finite closure.
-/
axiom finite_forward_existence (phi : Formula) (w : FiniteWorldState phi) :
  ∃ u : FiniteWorldState phi, finite_task_rel phi w 1 u

/--
Backward existence: given a consistent world state, there exists a consistent
predecessor state that satisfies the backward task relation.

**Proof sketch**: Similar to forward_existence, but using all_past transfer.
-/
axiom finite_backward_existence (phi : Formula) (w : FiniteWorldState phi) :
  ∃ u : FiniteWorldState phi, finite_task_rel phi w (-1) u

/--
History existence: given any consistent world state as origin, there exists
a finite history through that state.

This uses forward_existence and backward_existence to construct states
at all times in the finite domain.

**Note**: This is noncomputable because it uses Classical.choice to
select witnesses from the existence lemmas.
-/
noncomputable def finite_history_from_state (phi : Formula) (w : FiniteWorldState phi) :
    FiniteHistory phi := by
  -- We need to construct states at all times and prove the relation constraints
  -- This requires recursively applying forward/backward existence
  -- For now, we use a placeholder constant function and sorry the proofs
  -- Construct states function: constant at w for simplicity (placeholder)
  let states : FiniteTime (temporalBound phi) → FiniteWorldState phi := fun _ => w
  refine ⟨states, ?_, ?_⟩
  · -- Forward relation: need states(t) ~ states(t+1) for duration 1
    intro t t' h_succ
    -- states t = states t' = w, so we need finite_task_rel phi w 1 w
    -- This is NOT nullity (which is for d=0), so we need to use existence
    sorry
  · -- Backward relation: need states(t) ~ states(t-1) for duration -1
    intro t t' h_pred
    sorry

/-!
### History Construction Notes

The full construction of `finite_history_from_state` would:
1. Place `w` at the origin (time 0)
2. Use `finite_forward_existence` repeatedly to extend to times 1, 2, ..., k
3. Use `finite_backward_existence` repeatedly to extend to times -1, -2, ..., -k
4. Combine these into a single function on FiniteTime

This construction is non-trivial because we need to ensure all the consecutive
states satisfy the task relation. The existence axioms guarantee this is possible,
but the detailed construction requires careful handling of the induction.

For now, we leave this with sorry and focus on the truth lemma structure.
-/

/-!
## Summary of Phase 5 Definitions

- `finite_forward_existence`: Axiom - consistent states have forward successors
- `finite_backward_existence`: Axiom - consistent states have backward predecessors
- `finite_history_from_state`: Construct history from initial state (2 sorries)

**Status**: Existence lemmas stated as axioms. Full proofs would require:
1. Lindenbaum lemma for finite closure
2. Consistency preservation under transfer
3. Recursive construction with correct relation proofs

These can be proven later when the Lindenbaum infrastructure is extended
to handle finite closures. The axioms capture the essential semantic property
that the canonical model is complete.
-/

/-!
## Phase 6: Finite Truth Lemma

The truth lemma is the key result connecting syntactic membership (formula in
world state) with semantic truth (truth_at in the model). It states:

For all psi in closure(phi), and for all times t in the finite domain:
  psi true in world state S_t  <->  truth_at M tau t psi

where M is the finite canonical model, tau is a finite history, and S_t is the
world state at time t in that history.

The proof proceeds by structural induction on psi, with each case using the
properties of locally consistent world states and the finite task relation.
-/

/-!
### Truth Lemma Setup

We need to relate the finite model's truth evaluation to the world states.
Since our finite model uses a different structure than WorldHistory, we
first define truth evaluation directly on finite histories.
-/

/--
Truth evaluation on the finite canonical model with a finite history.

This directly evaluates formulas on the finite model without converting
to WorldHistory, which simplifies the truth lemma proof.
-/
def finite_truth_at (phi : Formula) (h : FiniteHistory phi)
    (t : FiniteTime (temporalBound phi)) : Formula → Prop
  | Formula.atom p =>
    -- Atom is true iff it's in the closure and true in the world state
    ∃ h_mem : Formula.atom p ∈ closure phi, (h.states t).models (Formula.atom p) h_mem
  | Formula.bot =>
    -- Bot is always false
    False
  | Formula.imp psi chi =>
    -- Implication is material conditional
    finite_truth_at phi h t psi → finite_truth_at phi h t chi
  | Formula.box psi =>
    -- Box is true iff psi is true at all finite histories at time t
    ∀ h' : FiniteHistory phi, finite_truth_at phi h' t psi
  | Formula.all_past psi =>
    -- All past is true iff psi is true at all earlier times in the finite domain
    ∀ s : FiniteTime (temporalBound phi),
      FiniteTime.toInt (temporalBound phi) s < FiniteTime.toInt (temporalBound phi) t →
      finite_truth_at phi h s psi
  | Formula.all_future psi =>
    -- All future is true iff psi is true at all later times in the finite domain
    ∀ s : FiniteTime (temporalBound phi),
      FiniteTime.toInt (temporalBound phi) t < FiniteTime.toInt (temporalBound phi) s →
      finite_truth_at phi h s psi

/--
The finite truth lemma: membership in world state equals truth in model.

For any formula psi in the closure of phi:
  psi is true in world state S_t  <->  finite_truth_at phi tau t psi

**Note**: This is the key completeness lemma. The proof requires:
1. Atom case: by definition of valuation
2. Bot case: by consistency (bot is never in a consistent state)
3. Imp case: by local consistency (implications are respected)
4. Box case: requires all histories to have same state at t (canonical property)
5. All_past case: by task relation transfer for past
6. All_future case: by task relation transfer for future

The modal (box) and temporal cases are where the canonical model construction
pays off - the transfer properties in finite_task_rel ensure these cases work.
-/
theorem finite_truth_lemma (phi : Formula) (h : FiniteHistory phi)
    (t : FiniteTime (temporalBound phi)) (psi : Formula) (h_mem : psi ∈ closure phi) :
    (h.states t).models psi h_mem ↔ finite_truth_at phi h t psi := by
  -- Proof by structural induction on psi
  induction psi generalizing t with
  | atom p =>
    -- Atom case: both sides check membership in world state
    simp only [FiniteWorldState.models, finite_truth_at]
    constructor
    · intro h_true
      exact ⟨h_mem, h_true⟩
    · intro ⟨_, h_true⟩
      -- By proof irrelevance, both membership proofs give same result
      exact h_true
  | bot =>
    -- Bot case: never true in consistent state, never true semantically
    simp only [FiniteWorldState.models, finite_truth_at]
    constructor
    · intro h_true
      have h_false := (h.states t).consistent.1 h_mem
      simp [h_true] at h_false
    · intro h_false
      exact False.elim h_false
  | imp psi chi ih_psi ih_chi =>
    -- Implication case: by local consistency
    simp only [FiniteWorldState.models, finite_truth_at]
    constructor
    · intro h_imp h_psi_true
      -- Need: if imp true and psi true then chi true
      -- This requires proving that psi and chi are also in closure phi
      -- when (imp psi chi) is in closure phi
      sorry
    · intro h_impl
      -- Need: if implication holds semantically, then syntactically
      sorry
  | box psi ih =>
    -- Box case: requires canonical property
    simp only [FiniteWorldState.models, finite_truth_at]
    constructor
    · intro h_box h'
      -- box(psi) true at state t, need psi true at all histories at t
      -- By canonical property, psi should be true at state t
      -- Then by IH, finite_truth_at h' t psi
      sorry
    · intro h_all
      -- psi true at all histories at t, need box(psi) true at state t
      -- This is the converse canonical property
      sorry
  | all_past psi ih =>
    -- All past case: by task relation transfer
    simp only [FiniteWorldState.models, finite_truth_at]
    constructor
    · intro h_past s h_s_lt
      -- all_past(psi) true at t, need psi true at s < t
      -- By task relation transfer from t to s
      sorry
    · intro h_all_s
      -- psi true at all s < t, need all_past(psi) true at t
      sorry
  | all_future psi ih =>
    -- All future case: by task relation transfer (symmetric to past)
    simp only [FiniteWorldState.models, finite_truth_at]
    constructor
    · intro h_fut s h_t_lt
      sorry
    · intro h_all_s
      sorry

/-!
### Truth Lemma Notes

The truth lemma proof requires several auxiliary facts:
1. Closure contains subformulas of its members
2. Task relation transfer properties connect states at different times
3. Canonical property: box(psi) at state S implies psi at all accessible states

The sorry gaps in the proof correspond to these auxiliary lemmas that need
to be developed. The structure of the proof is correct, but completing it
requires the full canonical model infrastructure.
-/

/-!
## Summary of Phase 6 Definitions

- `finite_truth_at`: Truth evaluation on finite histories
- `finite_truth_lemma`: Membership <-> truth equivalence (PARTIAL - has sorries)

**Status**: Truth lemma structure is correct but has sorry gaps:
- Imp case: needs closure contains subformulas
- Box case: needs canonical property relating box to accessibility
- Temporal cases: need task relation transfer composition

These gaps can be filled when the auxiliary infrastructure is developed.
-/

end Bimodal.Metalogic.Completeness
