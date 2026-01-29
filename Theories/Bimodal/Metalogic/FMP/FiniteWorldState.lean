import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.FMP.Closure
import Bimodal.Metalogic.FMP.BoundedTime
import Mathlib.Data.Fin.Basic
import Mathlib.Data.Finite.Defs
import Mathlib.Data.Fintype.Pi
import Mathlib.SetTheory.Cardinal.Finite

/-!
# Parametric Finite World States for FMP

This module provides finite world states for the parametric Finite Model Property
construction. A finite world state is a truth assignment on the subformula closure.

## Design Philosophy

The key insight is that the FMP construction's cardinality bound (2^closureSize) is
purely combinatorial - it counts subsets of the subformula closure. The time domain
used for finite model construction just needs to be finite with known cardinality.

We use `BoundedTime k` (which is `Fin (2*k+1)`) as the time domain, where
`k = temporalBound φ = φ.temporalDepth`.

## Main Definitions

- `temporalBound`: Temporal depth bound for a formula
- `FiniteTruthAssignment`: Bool-valued function on closure elements at bounded times
- `IsLocallyConsistent`: Propositional + modal consistency of truth assignment
- `FiniteWorldState`: A locally consistent truth assignment
- `FiniteHistory`: Sequence of world states over bounded time domain
- `worldStateFromClosureMCS`: Construction from closure-maximal consistent sets

## Architecture

This is the parametric version of `Boneyard/Metalogic_v2/Representation/FiniteWorldState.lean`.
The original used hardcoded `Int` duration; this version uses the combinatorial
`BoundedTime k` abstraction that works with any parametric duration type.

## References

- Original: `Boneyard/Metalogic_v2/Representation/FiniteWorldState.lean`
- BoundedTime: `Metalogic/FMP/BoundedTime.lean`
- Closure: `Metalogic/FMP/Closure.lean`
-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core

/-!
## Temporal Bound

The temporal bound determines the size of the bounded time domain.
-/

/--
Temporal depth bound for a formula.
We use the formula's temporal depth.
-/
def temporalBound (phi : Formula) : Nat := phi.temporalDepth

/-!
## Finite Truth Assignments

A truth assignment on the closure over bounded time.
-/

/--
A truth assignment on the subformula closure.
-/
def FiniteTruthAssignment (phi : Formula) : Type :=
  { psi : Formula // psi ∈ closure phi } → Bool

/--
Local consistency for a truth assignment.
This ensures the assignment respects propositional logic and modal axioms.

NOTE: Temporal reflexivity (H phi -> phi, G phi -> phi) is intentionally NOT included
because TM logic uses strict temporal semantics where these axioms are not valid.
The temporal operators quantify over strictly less/greater times:
- `all_past φ` holds iff φ holds at all s < t (excluding t)
- `all_future φ` holds iff φ holds at all s > t (excluding t)
See `Semantics/Truth.lean:109-110` for the semantic definitions.
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

/--
DecidableEq instance for truth assignments.

Since the domain is finite and Bool has decidable equality,
function equality is decidable via Fintype.decidablePiFintype.
-/
instance truthAssignmentDecidableEq (phi : Formula) : DecidableEq (FiniteTruthAssignment phi) :=
  Fintype.decidablePiFintype

/--
DecidableEq instance for FiniteWorldState.

Two world states are equal iff their assignments are equal.
Since assignments have decidable equality, world states do too.
-/
instance finiteWorldState_decidableEq (phi : Formula) : DecidableEq (FiniteWorldState phi) :=
  fun w1 w2 =>
    if h : w1.assignment = w2.assignment then
      isTrue (FiniteWorldState.ext h)
    else
      isFalse (fun h_eq => h (by rw [h_eq]))

/-!
## Finite History

A history is a sequence of world states over the bounded time domain.
-/

/--
A finite history: a function from bounded time to world states.
-/
structure FiniteHistory (phi : Formula) where
  /-- World state at each time point -/
  states : BoundedTime (temporalBound phi) → FiniteWorldState phi

namespace FiniteHistory

variable {phi : Formula}

/--
The world state at the origin.
-/
def atOrigin (hist : FiniteHistory phi) : FiniteWorldState phi :=
  hist.states (BoundedTime.origin (temporalBound phi))

/--
Create a constant history from a single world state.
-/
def constant (w : FiniteWorldState phi) : FiniteHistory phi :=
  ⟨fun _ => w⟩

/--
For a constant history, all states are equal.
-/
theorem constant_states (w : FiniteWorldState phi) (t : BoundedTime (temporalBound phi)) :
    (constant w).states t = w := rfl

end FiniteHistory

/--
Extensionality for FiniteHistory.
Two histories are equal iff their states functions are equal.
-/
@[ext]
theorem FiniteHistory.ext {phi : Formula} {h1 h2 : FiniteHistory phi}
    (heq : h1.states = h2.states) : h1 = h2 := by
  cases h1
  cases h2
  simp only [FiniteHistory.mk.injEq]
  exact heq

/-!
## Fintype Instances

Since BoundedTime is finite and FiniteWorldState is finite,
FiniteHistory is also finite.
-/

/--
Fintype instance for FiniteWorldState.
Since it's a subtype of a finite function type, it inherits Fintype.
-/
noncomputable instance finiteWorldState_fintype (phi : Formula) : Fintype (FiniteWorldState phi) := by
  -- FiniteWorldState is a subtype of FiniteTruthAssignment
  -- We use Fintype.ofFinite since we already have Finite
  exact Fintype.ofFinite _

/--
Fintype instance for FiniteHistory.
Since BoundedTime and FiniteWorldState are both finite, function types are finite.
-/
noncomputable instance finiteHistory_fintype (phi : Formula) : Fintype (FiniteHistory phi) := by
  -- FiniteHistory phi is definitionally a wrapper around
  -- BoundedTime (temporalBound phi) → FiniteWorldState phi
  -- which is finite since both domain and codomain are finite
  have h_fn_fintype : Fintype (BoundedTime (temporalBound phi) → FiniteWorldState phi) := by
    infer_instance
  have equiv : (BoundedTime (temporalBound phi) → FiniteWorldState phi) ≃ FiniteHistory phi := {
    toFun := fun f => ⟨f⟩
    invFun := fun h => h.states
    left_inv := fun f => rfl
    right_inv := fun h => FiniteHistory.ext rfl
  }
  exact Fintype.ofEquiv _ equiv

instance finiteHistory_finite (phi : Formula) : Finite (FiniteHistory phi) := by
  infer_instance

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

This proof establishes the 3 conditions of `IsLocallyConsistent`:
1. Bot is false: Follows from set consistency of MCS
2. Implications respected: Uses `closure_mcs_imp_iff`
3. Modal T axiom: Uses T axiom (`□φ → φ`) being derivable as a theorem
-/
theorem closure_mcs_implies_locally_consistent (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) :
    IsLocallyConsistent phi (assignmentFromClosureMCS phi S h_mcs) := by
  unfold IsLocallyConsistent assignmentFromClosureMCS
  refine ⟨?_, ?_, ?_⟩
  -- Goal 1: Bot is false
  · intro _h_bot_mem
    simp only
    -- Show bot ∉ S using consistency
    have h_bot_not_in : Formula.bot ∉ S := by
      intro h_bot_in
      have h_cons := closure_mcs_set_consistent h_mcs
      unfold SetConsistent at h_cons
      specialize h_cons [Formula.bot] (by simp [h_bot_in])
      unfold Consistent at h_cons
      apply h_cons
      -- [bot] ⊢ bot by assumption
      exact ⟨DerivationTree.assumption [Formula.bot] Formula.bot (by simp)⟩
    haveI : Decidable (Formula.bot ∈ S) := Classical.propDecidable _
    simp only [decide_eq_true_eq, h_bot_not_in, ite_false]
  -- Goal 2: Implications are respected
  · intro psi chi h_imp h_psi h_chi h_imp_true h_psi_true
    simp only at h_imp_true h_psi_true ⊢
    haveI : Decidable (Formula.imp psi chi ∈ S) := Classical.propDecidable _
    haveI : Decidable (psi ∈ S) := Classical.propDecidable _
    haveI : Decidable (chi ∈ S) := Classical.propDecidable _
    simp only [decide_eq_true_eq] at h_imp_true h_psi_true ⊢
    -- Extract membership from the ite
    have h_imp_in_S : Formula.imp psi chi ∈ S := by
      by_contra h
      simp [h] at h_imp_true
    have h_psi_in_S : psi ∈ S := by
      by_contra h
      simp [h] at h_psi_true
    -- Use closure_mcs_imp_iff
    have h_iff := closure_mcs_imp_iff phi S h_mcs psi chi h_imp
    rw [h_iff] at h_imp_in_S
    have h_chi_in_S := h_imp_in_S h_psi_in_S
    simp [h_chi_in_S]
  -- Goal 3: Modal T axiom (box psi → psi)
  · intro psi h_box h_psi h_box_true
    simp only at h_box_true ⊢
    haveI : Decidable (psi.box ∈ S) := Classical.propDecidable _
    haveI : Decidable (psi ∈ S) := Classical.propDecidable _
    simp only [decide_eq_true_eq] at h_box_true ⊢
    -- Extract membership from the ite
    have h_box_in_S : psi.box ∈ S := by
      by_contra h
      simp [h] at h_box_true
    -- By negation completeness, psi ∈ S or psi.neg ∈ S
    have h_psi_or := closure_mcs_neg_complete phi S h_mcs psi h_psi
    cases h_psi_or with
    | inl h => simp [h]  -- psi ∈ S, we're done
    | inr h_neg =>
      -- psi.neg ∈ S, but this contradicts consistency when box psi ∈ S
      -- From box psi, by T axiom, we derive psi
      -- Then psi and psi.neg derive bot
      exfalso
      have h_incons : ¬Consistent [psi.box, psi.neg] := by
        intro h_cons
        apply h_cons
        -- Build derivation [box psi, psi.neg] ⊢ ⊥
        -- T axiom: box psi → psi
        have d_T : DerivationTree [] (psi.box.imp psi) :=
          DerivationTree.axiom [] _ (Axiom.modal_t psi)
        have d_T' : DerivationTree [psi.box, psi.neg] (psi.box.imp psi) :=
          DerivationTree.weakening [] _ _ d_T (by simp)
        -- Get box psi from context
        have d_box : DerivationTree [psi.box, psi.neg] psi.box :=
          DerivationTree.assumption _ _ (by simp)
        -- MP to get psi
        have d_psi : DerivationTree [psi.box, psi.neg] psi :=
          DerivationTree.modus_ponens _ _ _ d_T' d_box
        -- Get psi.neg from context
        have d_neg : DerivationTree [psi.box, psi.neg] psi.neg :=
          DerivationTree.assumption _ _ (by simp)
        -- MP to get ⊥
        exact ⟨derives_bot_from_phi_neg_phi d_psi d_neg⟩
      -- But [box psi, psi.neg] ⊆ S, so S is inconsistent
      have h_sub : ∀ ψ ∈ [psi.box, psi.neg], ψ ∈ S := by
        intro ψ hψ
        simp only [List.mem_cons, List.mem_nil_iff, or_false] at hψ
        rcases hψ with rfl | rfl
        · exact h_box_in_S
        · exact h_neg
      exact h_incons (h_mcs.1.2 [psi.box, psi.neg] h_sub)

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

/-!
## Cardinality Bounds

Key results for the FMP construction.
-/

/--
The number of distinct world states is bounded by 2^|closure phi|.

This is the combinatorial bound that underlies the finite model property.
-/
theorem finiteWorldState_card_bound (phi : Formula) :
    Fintype.card (FiniteWorldState phi) ≤ 2 ^ closureSize phi := by
  -- The injection FiniteWorldState phi → FiniteTruthAssignment phi
  -- shows card(FiniteWorldState) ≤ card(FiniteTruthAssignment)
  have h_inj : Function.Injective (fun w : FiniteWorldState phi => w.assignment) := by
    intros w1 w2 heq
    exact FiniteWorldState.ext heq
  have h_card_le := Fintype.card_le_of_injective _ h_inj
  -- card(FiniteTruthAssignment) = card(closure phi → Bool) = 2^|closure phi|
  have h_card_assign : Fintype.card (FiniteTruthAssignment phi) = 2 ^ Fintype.card (closure phi) := by
    unfold FiniteTruthAssignment
    simp only [Fintype.card_fun, Fintype.card_bool]
  -- closureSize = card(closure phi)
  have h_closureSize : closureSize phi = Fintype.card (closure phi) := by
    unfold closureSize
    rw [Fintype.card_coe]
  rw [h_closureSize]
  calc Fintype.card (FiniteWorldState phi)
      ≤ Fintype.card (FiniteTruthAssignment phi) := h_card_le
    _ = 2 ^ Fintype.card (closure phi) := h_card_assign

end Bimodal.Metalogic.FMP
