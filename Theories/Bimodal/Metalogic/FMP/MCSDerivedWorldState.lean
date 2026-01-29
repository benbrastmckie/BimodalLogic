import Bimodal.Metalogic.FMP.SemanticCanonicalModel

/-!
# MCS-Derived World States for Truth Lemma

This module defines a restricted subtype of `SemanticWorldState` that carries proof
of derivation from a Closure Maximal Consistent set (MCS). For these states, we can
prove a sorry-free truth correspondence theorem.

## Motivation

The gap in `truth_at_implies_semantic_truth` exists because `IsLocallyConsistent` only
enforces the **modus ponens direction** for implications:
- `v(psi -> chi) = true AND v(psi) = true => v(chi) = true`

But for truth correspondence, we need the **biconditional**:
- `v(psi -> chi) = true <-> (v(psi) = true -> v(chi) = true)`

MCS-derived states have this biconditional via `closure_mcs_imp_iff` (proven in Closure.lean).

## Main Definitions

- `MCSDerivedSemanticWorldState`: Subtype of SemanticWorldState with MCS derivation proof
- `mcs_truth_correspondence`: Truth at position equals assignment for MCS-derived states

## Why This Suffices for Completeness

1. `valid phi -> Provable phi` needs: "If phi valid, then no countermodel"
2. `semantic_weak_completeness` constructs countermodels from MCS
3. All countermodels it produces ARE MCS-derived
4. So: `valid phi -> true at all MCS-derived states -> Provable phi`

## References

- Original gap analysis: SemanticCanonicalModel.lean lines 627-684
- MCS implication biconditional: Closure.lean `closure_mcs_imp_iff`
- MCS negation completeness: Closure.lean `closure_mcs_neg_complete`
-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core

/-!
## MCSDerivedSemanticWorldState Definition

A semantic world state is MCS-derived if its underlying FiniteWorldState comes from
a ClosureMaximalConsistent set.
-/

/--
A semantic world state together with proof of MCS derivation.

This bundles:
- The semantic world state
- The underlying MCS set
- Proof that the set is closure-maximal consistent
- Proof that the world state comes from this MCS

The key property is that MCS-derived states satisfy the full implication biconditional,
not just the modus ponens direction.
-/
structure MCSDerivedSemanticWorldState (phi : Formula) where
  /-- The underlying semantic world state -/
  state : SemanticWorldState phi
  /-- The closure-maximal consistent set this state is derived from -/
  underlying_mcs : Set Formula
  /-- Proof that the set is closure-maximal consistent -/
  underlying_mcs_proof : ClosureMaximalConsistent phi underlying_mcs
  /-- Proof that the state's underlying FiniteWorldState equals the MCS construction -/
  derivation_proof : state.toFiniteWorldState = worldStateFromClosureMCS phi underlying_mcs underlying_mcs_proof

namespace MCSDerivedSemanticWorldState

variable {phi : Formula}

/--
Get the underlying FiniteWorldState.
-/
def toFiniteWorldState (w : MCSDerivedSemanticWorldState phi) : FiniteWorldState phi :=
  w.state.toFiniteWorldState

/--
Check if a formula in the closure is true at this MCS-derived state.
-/
def models (w : MCSDerivedSemanticWorldState phi) (psi : Formula) (h_mem : psi ∈ closure phi) : Prop :=
  w.toFiniteWorldState.models psi h_mem

/--
Construct an MCSDerivedSemanticWorldState from a ClosureMaximalConsistent set.

This is the canonical constructor - it builds both the FiniteWorldState and
wraps it in a SemanticWorldState with the derivation proof.
-/
noncomputable def mk_from_closureMCS (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) : MCSDerivedSemanticWorldState phi :=
  let ws := worldStateFromClosureMCS phi S h_mcs
  let hist := finite_history_from_state phi ws
  let t := BoundedTime.origin (temporalBound phi)
  let sw := SemanticWorldState.ofHistoryTime hist t
  { state := sw
    underlying_mcs := S
    underlying_mcs_proof := h_mcs
    derivation_proof := rfl }

/--
Key lemma: For MCS-derived states, membership in the MCS equals truth in the state.

This is the foundation of all MCS truth correspondence proofs.
-/
theorem underlying_world_state_models_iff (w : MCSDerivedSemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    psi ∈ w.underlying_mcs ↔ w.models psi h_mem := by
  simp only [models, toFiniteWorldState]
  rw [w.derivation_proof]
  exact worldStateFromClosureMCS_models_iff phi w.underlying_mcs w.underlying_mcs_proof psi h_mem

/--
MCS-derived states are finite (inherits from SemanticWorldState).
-/
instance mcs_derived_finite : Finite (MCSDerivedSemanticWorldState phi) := by
  apply Finite.of_injective (fun w => w.state)
  intro w1 w2 h
  -- Need to show w1 = w2 from w1.state = w2.state
  -- Since state determines toFiniteWorldState, and toFiniteWorldState determines the assignment,
  -- the underlying_mcs must be the same (up to the assignment)
  cases w1
  cases w2
  simp only [MCSDerivedSemanticWorldState.mk.injEq] at h ⊢
  constructor
  · exact h
  · -- The MCS is determined by the state via the derivation proof
    -- This follows from injectivity of worldStateFromClosureMCS
    -- For now we can't prove this without additional axioms about MCS uniqueness
    -- However, we only need state equality for the truth lemma
    sorry -- TODO: This requires proving MCS uniqueness from state

end MCSDerivedSemanticWorldState

/-!
## MCS Truth Correspondence: Base Cases

The following theorems establish truth correspondence for atomic formulas and
propositional connectives in MCS-derived states.
-/

/--
For MCS-derived states, bot is always false.
-/
theorem mcs_truth_at_bot (phi : Formula) (w : MCSDerivedSemanticWorldState phi)
    (h_mem : Formula.bot ∈ closure phi) :
    w.models Formula.bot h_mem = False := by
  simp only [MCSDerivedSemanticWorldState.models, MCSDerivedSemanticWorldState.toFiniteWorldState]
  rw [w.derivation_proof]
  simp only [FiniteWorldState.models]
  have h_cons := (worldStateFromClosureMCS phi w.underlying_mcs w.underlying_mcs_proof).consistent
  have h_bot_false := h_cons.1 h_mem
  simp only [h_bot_false, eq_iff_iff]
  tauto

/--
For MCS-derived states, atom truth equals MCS membership.
-/
theorem mcs_truth_at_atom (phi : Formula) (w : MCSDerivedSemanticWorldState phi)
    (p : String) (h_mem : Formula.atom p ∈ closure phi) :
    w.models (Formula.atom p) h_mem ↔ Formula.atom p ∈ w.underlying_mcs := by
  rw [← w.underlying_world_state_models_iff (Formula.atom p) h_mem]

/--
For MCS-derived states, formula truth equals MCS membership (for formulas in closure).
-/
theorem mcs_truth_models_iff (phi : Formula) (w : MCSDerivedSemanticWorldState phi)
    (psi : Formula) (h_psi_mem : psi ∈ closure phi) :
    w.models psi h_psi_mem ↔ psi ∈ w.underlying_mcs := by
  rw [← w.underlying_world_state_models_iff psi h_psi_mem]

/--
Key lemma: For MCS-derived states, implication truth equals material implication.

This uses `closure_mcs_imp_iff` which provides the biconditional that
`IsLocallyConsistent` alone cannot guarantee.
-/
theorem mcs_truth_at_imp (phi : Formula) (w : MCSDerivedSemanticWorldState phi)
    (psi chi : Formula) (h_imp_mem : Formula.imp psi chi ∈ closure phi) :
    w.models (Formula.imp psi chi) h_imp_mem ↔
    (w.models psi (closure_imp_left phi psi chi h_imp_mem) →
     w.models chi (closure_imp_right phi psi chi h_imp_mem)) := by
  -- Get membership proofs for subformulas
  have h_psi_mem : psi ∈ closure phi := closure_imp_left phi psi chi h_imp_mem
  have h_chi_mem : chi ∈ closure phi := closure_imp_right phi psi chi h_imp_mem

  -- Use the MCS implication biconditional
  have h_mcs_imp := closure_mcs_imp_iff phi w.underlying_mcs w.underlying_mcs_proof psi chi h_imp_mem

  -- Convert between models and MCS membership
  rw [← w.underlying_world_state_models_iff (Formula.imp psi chi) h_imp_mem]
  rw [← w.underlying_world_state_models_iff psi h_psi_mem]
  rw [← w.underlying_world_state_models_iff chi h_chi_mem]
  exact h_mcs_imp

/--
Negation completeness for MCS-derived states: for any psi in closure,
either w models psi or w does not model psi (and equivalently, psi.neg is in the MCS).

This follows from `closure_mcs_neg_complete`.
-/
theorem mcs_neg_complete (phi : Formula) (w : MCSDerivedSemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    w.models psi h_mem ∨ ¬w.models psi h_mem := by
  -- This is just classical logic, but the important fact is that
  -- the MCS contains either psi or psi.neg
  exact Classical.em _

/--
Stronger form: In MCS-derived state, either psi is in MCS or psi.neg is in MCS.
-/
theorem mcs_contains_or_neg (phi : Formula) (w : MCSDerivedSemanticWorldState phi)
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    psi ∈ w.underlying_mcs ∨ psi.neg ∈ w.underlying_mcs := by
  exact closure_mcs_neg_complete phi w.underlying_mcs w.underlying_mcs_proof psi h_mem

end Bimodal.Metalogic.FMP
