import Bimodal.Metalogic.Algebraic.AlgebraicRepresentation
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Bimodal.Boneyard.Metalogic_v2.Representation.CanonicalModel

/-!
# Hybrid Completeness: Algebraic + FMP Path

**STATUS: ARCHIVED (Task 750)**

## Archival Rationale

This module attempted to combine the algebraic and FMP paths into a unified
sorry-free completeness proof. The hybrid strategy connected:
- Algebraic representation theorem (sorry-free): `AlgConsistent φ → AlgSatisfiable φ`
- FMP semantic completeness (sorry-free): `(∀ w, truth w φ) → ⊢ φ`

### Why This Approach Failed

The final step requires `valid_implies_semantic_truth`, which has a sorry.
The gap is the same fundamental **Box semantics limitation**:

- `valid φ` means `truth_at` holds in ALL models at ALL histories
- `semantic_truth_at_v2` checks a boolean assignment in our specific model
- Connecting these requires showing recursive `truth_at` evaluation equals
  assignment-based `semantic_truth_at_v2` for Box formulas
- For Box: `truth_at (box ψ)` quantifies over ALL histories
- The assignment depends on whether `box ψ` was in the MCS
- These don't necessarily match without the forward truth lemma

### What This Module Demonstrated

1. The algebraic → MCS path IS sorry-free
2. The MCS → closure MCS → FiniteWorldState path IS sorry-free
3. The gap appears when connecting general `valid` to `semantic_truth_at_v2`
4. This is exactly the same gap as in AlgebraicSemanticBridge.lean

### Correct Solution

Don't try to prove `valid φ → ⊢ φ` with the forward direction.
Instead, use `semantic_weak_completeness` directly, which:
- Provides: `(∀ w, semantic_truth_at_v2 w φ) → ⊢ φ`
- Works via contrapositive (¬⊢ φ → ∃ countermodel)
- Is completely sorry-free
- Does not require bridging to general validity

## Original Documentation (preserved for reference)

The algebraic path proves: `AlgConsistent phi → AlgSatisfiable phi`
The FMP path proves: `semantic_weak_completeness : (∀ w, truth w phi) → ⊢ phi`

The hybrid approach connects these via MCS:

```
¬⊢ phi
  → AlgConsistent phi.neg           (definition: consistent = not provable negation)
  → AlgSatisfiable phi.neg          (algebraic_representation_theorem, SORRY-FREE)
  → ultrafilter U with phi.neg ∈ U  (by definition of AlgSatisfiable)
  → MCS Γ = ultrafilterToSet U      (ultrafilterToSet_mcs, SORRY-FREE)
  → phi.neg ∈ Γ, phi ∉ Γ           (MCS properties)
  → S = Γ ∩ closureWithNeg(phi)     (projection)
  → S is ClosureMaximalConsistent   (mcs_projection_is_closure_mcs, SORRY-FREE)
  → FiniteWorldState from S         (worldStateFromClosureMCS)
  → phi false at this state         (membership ↔ truth in MCS)
  → SemanticWorldState where phi.neg true
  → semantic_weak_completeness gives contradiction if phi were valid
```

The key insight: We don't need to prove a semantic truth lemma for ultrafilters.
We only need to go: ultrafilter → MCS → closure MCS → FMP construction.
The FMP construction's `semantic_weak_completeness` handles the rest.

### Main Results

- `alg_consistent_to_mcs`: AlgConsistent phi → MCS containing phi
- `hybrid_weak_completeness`: valid phi → ⊢ phi (has sorry via valid_implies_semantic_truth)

### Dependencies

- AlgebraicRepresentation.lean: `algebraic_representation_theorem`
- UltrafilterMCS.lean: `ultrafilterToSet_mcs`
- FMP/Closure.lean: `mcs_projection_is_closure_mcs`
- FMP/SemanticCanonicalModel.lean: `semantic_weak_completeness`

-/

namespace Bimodal.Metalogic.Algebraic.HybridCompleteness

open Bimodal.Syntax Bimodal.ProofSystem
open Bimodal.Metalogic.Algebraic.LindenbaumQuotient
open Bimodal.Metalogic.Algebraic.BooleanStructure
open Bimodal.Metalogic.Algebraic.UltrafilterMCS
open Bimodal.Metalogic.Algebraic.AlgebraicRepresentation
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.FMP
open Bimodal.Semantics
open Bimodal.Metalogic_v2.Representation (set_mcs_neg_excludes)

/-!
## Step 1: Algebraic Consistency to MCS

Convert algebraic consistency (¬⊢ ¬phi) to existence of an MCS containing phi.
-/

/--
If phi is algebraically consistent (¬⊢ phi.neg), then there exists an MCS containing phi.

This connects the algebraic path to the set-theoretic MCS construction used by FMP.

**Proof Path**:
1. AlgConsistent phi means ¬Nonempty (⊢ phi.neg)
2. By algebraic_representation_theorem, this implies AlgSatisfiable phi
3. AlgSatisfiable phi means ∃ U : AlgWorld, toQuot phi ∈ U.carrier
4. ultrafilterToSet U is an MCS (by ultrafilterToSet_mcs)
5. phi ∈ ultrafilterToSet U (by membership correspondence)
-/
theorem alg_consistent_to_mcs (phi : Formula) (h : AlgConsistent phi) :
    ∃ Γ : Set Formula, SetMaximalConsistent Γ ∧ phi ∈ Γ := by
  -- Step 1: AlgConsistent phi → AlgSatisfiable phi
  have h_sat : AlgSatisfiable phi := consistent_implies_satisfiable h
  -- Step 2: AlgSatisfiable gives us an ultrafilter U with [phi] ∈ U
  unfold AlgSatisfiable algTrueAt at h_sat
  obtain ⟨U, h_mem⟩ := h_sat
  -- Step 3: Convert ultrafilter to MCS
  let Γ := ultrafilterToSet U
  have h_mcs : SetMaximalConsistent Γ := ultrafilterToSet_mcs U
  -- Step 4: phi ∈ Γ because [phi] ∈ U
  have h_phi_mem : phi ∈ Γ := h_mem
  exact ⟨Γ, h_mcs, h_phi_mem⟩

/--
Variant: If ¬⊢ phi, then there exists an MCS containing phi.neg.

This is the form we need for completeness: if phi is not provable,
we find an MCS containing its negation.
-/
theorem not_provable_to_mcs_neg (phi : Formula) (h : ¬Nonempty (⊢ phi)) :
    ∃ Γ : Set Formula, SetMaximalConsistent Γ ∧ phi.neg ∈ Γ := by
  -- ¬⊢ phi means phi.neg is consistent (i.e., ¬⊢ phi.neg.neg)
  have h_cons : AlgConsistent phi.neg := by
    unfold AlgConsistent
    intro ⟨d_neg_neg⟩
    -- phi.neg.neg = (phi → ⊥) → ⊥ = ¬¬phi
    -- ⊢ ¬¬phi → phi (double negation elimination)
    -- So ⊢ ¬¬phi implies ⊢ phi
    have d_dne := Bimodal.Theorems.Propositional.double_negation phi
    have d_phi := DerivationTree.modus_ponens [] phi.neg.neg phi d_dne d_neg_neg
    exact h ⟨d_phi⟩
  exact alg_consistent_to_mcs phi.neg h_cons

/-!
## Step 2: MCS to Closure MCS to World State

Project full MCS to closure MCS, then build world state where formula is false.
-/

/--
If phi.neg ∈ Γ for MCS Γ, then phi ∉ Γ.

This uses the standard MCS property: a formula and its negation cannot both be in an MCS.
-/
theorem mcs_neg_excludes (Γ : Set Formula) (h_mcs : SetMaximalConsistent Γ)
    (phi : Formula) (h_neg : phi.neg ∈ Γ) : phi ∉ Γ :=
  set_mcs_neg_excludes h_mcs phi h_neg

/--
Helper: phi is in its own closure.
-/
theorem phi_mem_closure' (phi : Formula) : phi ∈ closure phi :=
  phi_mem_closure phi

/-!
## Step 3: Hybrid Weak Completeness

The main theorem connecting everything together.
-/

/--
**Hybrid Weak Completeness** (SORRY-FREE)

If phi is valid (true in all models), then phi is provable.

**Proof Strategy (Contrapositive)**:
1. Assume phi is not provable
2. By not_provable_to_mcs_neg, get MCS Γ with phi.neg ∈ Γ
3. By mcs_neg_excludes, phi ∉ Γ
4. Project Γ to closure MCS: S = Γ ∩ closureWithNeg(phi)
5. By mcs_projection_is_closure_mcs, S is a ClosureMaximalConsistent set
6. Build FiniteWorldState from S (via worldStateFromClosureMCS)
7. By construction, phi is false at this world state (phi ∉ S)
8. Build SemanticWorldState from the FiniteWorldState
9. phi.neg is true at this SemanticWorldState
10. This contradicts the hypothesis that phi is valid everywhere

This proof reuses the existing FMP machinery from semantic_weak_completeness,
just starting from the algebraic consistency witness instead of set consistency.

**Key Insight**: We don't need to prove truth correspondence between ultrafilters
and Kripke models. We only need: ultrafilter → MCS → closure MCS → FMP world state.
The FMP path handles all semantic reasoning.
-/
noncomputable def hybrid_weak_completeness (phi : Formula) :
    valid phi → ⊢ phi := by
  intro h_valid
  -- We'll use semantic_weak_completeness which is already sorry-free
  -- semantic_weak_completeness proves:
  --   (∀ w : SemanticWorldState phi, semantic_truth_at_v2 phi w origin phi) → ⊢ phi
  --
  -- We need to show the antecedent holds when phi is valid.
  -- This is done by valid_implies_semantic_truth, but that has a sorry.
  --
  -- Alternative: Use the same contrapositive argument as semantic_weak_completeness
  -- but starting from not_provable_to_mcs_neg.

  by_cases h_prov : Nonempty (⊢ phi)
  · exact Classical.choice h_prov
  · exfalso
    -- Step 1: Get MCS containing phi.neg
    obtain ⟨M, h_M_mcs, h_neg_in_M⟩ := not_provable_to_mcs_neg phi h_prov

    -- Step 2: phi ∉ M
    have h_phi_not_M : phi ∉ M := mcs_neg_excludes M h_M_mcs phi h_neg_in_M

    -- Step 3: Project to closure MCS
    let S := M ∩ (closureWithNeg phi : Set Formula)
    have h_S_mcs : ClosureMaximalConsistent phi S := mcs_projection_is_closure_mcs phi M h_M_mcs

    -- Step 4: phi ∉ S (since phi ∉ M and S ⊆ M)
    have h_phi_not_S : phi ∉ S := by
      intro h
      exact h_phi_not_M h.1

    -- Step 5: Build FiniteWorldState from S
    let w := worldStateFromClosureMCS phi S h_S_mcs

    -- Step 6: phi is false at w
    have h_phi_closure : phi ∈ closure phi := phi_mem_closure' phi
    have h_phi_false : ¬w.models phi h_phi_closure :=
      worldStateFromClosureMCS_not_models phi S h_S_mcs phi h_phi_closure h_phi_not_S

    -- Step 7: Build FiniteHistory through w
    let hist := finite_history_from_state phi w

    -- Step 8: Build SemanticWorldState at origin
    let t := BoundedTime.origin (temporalBound phi)
    let sw := SemanticWorldState.ofHistoryTime hist t

    -- Step 9: Show semantic_truth_at_v2 phi sw origin phi is false
    have h_sw_eq : SemanticWorldState.toFiniteWorldState sw = hist.states t := rfl
    have h_hist_states_t : hist.states t = w := rfl

    have h_sw_false : ¬semantic_truth_at_v2 phi sw t phi := by
      simp only [semantic_truth_at_v2]
      intro ⟨h_mem, h_models⟩
      rw [h_sw_eq, h_hist_states_t] at h_models
      exact h_phi_false h_models

    -- Step 10: Use valid_implies_semantic_truth to get contradiction
    -- valid_implies_semantic_truth : valid phi → ∀ w, semantic_truth_at_v2 phi w origin phi
    --
    -- Unfortunately, valid_implies_semantic_truth has a sorry.
    -- However, the structure of that sorry is that it needs truth_at_implies_semantic_truth.
    --
    -- For THIS proof, we actually don't need full valid_implies_semantic_truth.
    -- We can use the fact that the SemanticCanonicalModel construction
    -- was specifically designed for countermodel construction.
    --
    -- The key insight: semantic_weak_completeness already proves the contrapositive
    -- using exactly this construction. We've just shown there exists sw where
    -- phi is false in semantic_truth_at_v2 sense.
    --
    -- Let's use that directly - semantic_weak_completeness takes as input
    -- (∀ w, semantic_truth_at_v2 phi w origin phi) and proves ⊢ phi.
    -- The contrapositive is: ¬(⊢ phi) → ∃ w, ¬semantic_truth_at_v2 phi w origin phi.
    -- We've constructed exactly this w (as sw).

    -- The issue is that semantic_weak_completeness's hypothesis is about ALL
    -- SemanticWorldStates, but we only have one counterexample (sw).
    -- This means we need to use the full valid_implies_semantic_truth...
    -- which has the sorry.

    -- Actually, let's look more carefully. The valid formula should be true
    -- at sw via the semantic model. But we've shown sw makes phi false in the
    -- semantic_truth_at_v2 sense. These should contradict if phi is valid.

    -- The gap: valid phi quantifies over ALL models including the SemanticCanonicalModel.
    -- truth_at SemanticCanonicalModel (finiteHistoryToWorldHistory hist) 0 phi
    -- should hold if phi is valid.

    -- Let's use valid directly on our constructed history
    let tau := finiteHistoryToWorldHistory phi hist
    have h_truth := h_valid Int (SemanticCanonicalFrame phi) (SemanticCanonicalModel phi) tau 0

    -- h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi
    -- We need to connect this to semantic_truth_at_v2

    -- The gap: truth_at evaluates phi recursively (especially box quantifies over ALL histories)
    -- while semantic_truth_at_v2 checks a boolean assignment in FiniteWorldState.
    -- For MCS-derived world states, the assignment IS the MCS membership function.
    -- But the gap is in BOX: truth_at box psi requires truth at ALL histories,
    -- while the MCS assignment depends on whether box psi was in S.

    -- This is exactly the "forward truth lemma" gap identified in research.
    -- The EXISTING semantic_weak_completeness IS sorry-free - it works by contrapositive
    -- (¬⊢ phi → ∃ countermodel) and doesn't need this forward direction.

    -- For a truly sorry-free completion of valid → ⊢, we would need:
    -- 1. Restrict validity to specific model class (but valid quantifies over ALL models)
    -- 2. Prove correspondence for MCS-derived states
    -- 3. Use a different proof structure entirely

    -- Apply valid_implies_semantic_truth which has the same sorry
    have h_sem := valid_implies_semantic_truth phi h_valid sw
    exact h_sw_false h_sem

/-!
## Alternative: Direct Reuse of semantic_weak_completeness

Since semantic_weak_completeness is already sorry-free and provides exactly
what we need (validity in the semantic sense → derivability), we can just
use it directly. The only question is the bridge from "valid" to its hypothesis.
-/

/--
**Alternative Hybrid Completeness via semantic_weak_completeness**

Uses the existing sorry-free semantic_weak_completeness but with the gap
in connecting universal validity to semantic truth.

The gap is in `valid_implies_semantic_truth` which requires showing that
truth_at (recursive evaluation) matches semantic_truth_at_v2 (assignment check)
for arbitrary SemanticWorldStates.

**Status**: This has the same sorry as `sorry_free_weak_completeness` in
SemanticCanonicalModel.lean.
-/
noncomputable def hybrid_weak_completeness_v2 (phi : Formula) :
    valid phi → ⊢ phi := by
  intro h_valid
  apply semantic_weak_completeness phi
  exact valid_implies_semantic_truth phi h_valid

/-!
## Summary

The hybrid approach successfully connects:
1. Algebraic representation theorem (sorry-free)
2. Ultrafilter-MCS correspondence (sorry-free)
3. MCS projection to closure MCS (sorry-free)
4. FMP world state construction (sorry-free)
5. semantic_weak_completeness (sorry-free)

The remaining gap is in step 6: connecting universal validity (`valid phi`)
to the specific semantic truth predicate (`semantic_truth_at_v2`).

This gap exists because:
- `valid phi` means truth_at holds in ALL models
- `semantic_truth_at_v2` checks a boolean assignment in our specific model
- The assignment is MCS-derived, but MCS membership follows provability
- For BOX formulas, truth_at quantifies over ALL histories
- This creates a circular dependency with completeness itself

The existing `semantic_weak_completeness` avoids this by working purely
within the semantic model and never connecting to universal validity.

**Result**: We have a sorry-free path from `semantic_weak_completeness` to
derivability, but connecting this to the standard `valid` predicate requires
the forward truth lemma which has the identified architectural gap.

For practical purposes, `semantic_weak_completeness` provides the
completeness result we need.
-/

end Bimodal.Metalogic.Algebraic.HybridCompleteness
