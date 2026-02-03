import Bimodal.ProofSystem
import Bimodal.Semantics
import Bimodal.Metalogic.FMP.SemanticCanonicalModel
import Bimodal.Metalogic.Soundness
import Bimodal.Metalogic.Core.MCSProperties
import Mathlib.Data.Set.Basic

/-!
# Bridge Lemma: Consistent Sets are Satisfiable

**ARCHITECTURAL LIMITATION**: This module attempts to bridge FMP-internal truth
(`FiniteWorldState.models`) with general TaskModel truth (`truth_at`). This bridge
is **BLOCKED** for modal and temporal operators due to fundamental model construction
issues. See research-005 in task 810 for detailed analysis.

## Status Summary

| Component | Status | Notes |
|-----------|--------|-------|
| `consistent_implies_not_neg_provable` | PROVEN | Propositional only |
| `mcs_world_truth_correspondence` | **6 SORRIES** | Modal/temporal blocked |
| `consistent_satisfiable` | DEPENDS ON SORRIES | Uses blocked lemma |
| Overall bridge approach | **BLOCKED** | Cannot be completed |

## Why The Bridge Is Blocked

The truth correspondence lemma `mcs_world_truth_correspondence` attempts to show:
```
w.models psi h_mem <-> truth_at (fmpTaskModel phi) (fmpWorldHistory phi w) 0 psi
```

**Problem 1 (Modal box)**: The FMP TaskFrame has all FiniteWorldStates as possible
world states with permissive accessibility (task_rel = True). For `truth_at ... (box psi)`,
we need psi true at ALL reachable states, not just MCS-derived ones. But non-MCS states
don't satisfy modal axioms.

**Problem 2 (Temporal)**: The FMP WorldHistory is constant (same state at all times).
Temporal operators require truth at strictly future/past times, but constant history
trivializes temporal structure.

## What IS Achievable

1. **`semantic_weak_completeness`** in SemanticCanonicalModel.lean is SORRY-FREE
   - Uses FMP-internal validity (SemanticWorldState), not general validity
   - Works via contrapositive without needing full truth correspondence

2. **Propositional fragment**: The bridge works for atoms, bot, imp
   - Lines 186-239 of `mcs_world_truth_correspondence` are proven
   - Only modal/temporal cases (lines 240-283) are blocked

3. **Finite strong completeness**: Works via impChain approach
   - See `FiniteStrongCompleteness.lean`
   - Has one sorry for validity bridge (same root cause)

## Why Contrapositive Approach Also Doesn't Work

Research-005 suggested using contrapositive of weak completeness:
```
consistent phi -> satisfiable phi  (via contrapositive)
not satisfiable -> not consistent  (contrapositive)
not satisfiable -> phi.neg valid   (definition)
phi.neg valid -> phi.neg provable  (weak completeness)
phi.neg provable -> not consistent (definition)
```

**But**: `semantic_weak_completeness` requires FMP-INTERNAL validity, not general validity.
Converting "phi.neg is valid in all TaskModels" to "phi.neg is true at all SemanticWorldStates"
requires the same blocked truth correspondence bridge.

## Recommendations

1. Use `semantic_weak_completeness` directly for completeness results
2. Accept that general validity <-> FMP-internal validity bridge is blocked
3. For publishable results, use FMP-internal validity as the semantic notion
4. Archive this file's approach as architectural limitation documentation

## References

- Task 810 research-005: Detailed blockage analysis
- SemanticCanonicalModel.lean: Working sorry-free completeness
- FiniteStrongCompleteness.lean: Finite strong completeness with validity bridge sorry

-/

namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics Bimodal.Metalogic.Core

/-!
## Set-Based Semantic Notions

These definitions mirror those in Boneyard/Metalogic_v5 but are placed here
to avoid importing the Representation-based code.
-/

/--
Set-based semantic consequence: phi is a consequence of (possibly infinite) set Gamma.

This quantifies over all temporal types D and all models.
-/
def set_semantic_consequence (Gamma : Set Formula) (phi : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    (∀ psi ∈ Gamma, truth_at M tau t psi) → truth_at M tau t phi

/--
Set-based satisfiability: a set Gamma is satisfiable if there exists a model
where all formulas in Gamma are true at some point.
-/
def set_satisfiable (Gamma : Set Formula) : Prop :=
  ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
    (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    ∀ psi ∈ Gamma, truth_at M tau t psi

/-!
## Consistency Implies Non-Provability of Negation

If {phi} is set-consistent, then phi.neg (= phi -> bot) is not provable.
-/

/--
If phi is in a set-consistent set, then phi.neg is not provable.

**Proof**: If |- phi.neg, then from [phi] we can derive bot by modus ponens.
This contradicts [phi] being consistent (which follows from SetConsistent {phi}).
-/
theorem consistent_implies_not_neg_provable (phi : Formula)
    (h_cons : SetConsistent ({phi} : Set Formula)) : ¬Nonempty (⊢ phi.neg) := by
  intro ⟨d_neg⟩
  -- From |- phi.neg (which is |- phi -> bot), we get [phi] |- bot by modus ponens
  have d_neg' : DerivationTree [phi] phi.neg :=
    DerivationTree.weakening [] [phi] phi.neg d_neg (by simp)
  have d_phi : DerivationTree [phi] phi :=
    DerivationTree.assumption [phi] phi (by simp)
  have d_bot : DerivationTree [phi] Formula.bot :=
    DerivationTree.modus_ponens [phi] phi Formula.bot d_neg' d_phi
  -- But [phi] ⊆ {phi}, so this contradicts SetConsistent {phi}
  apply h_cons [phi] (by simp : ∀ ψ ∈ [phi], ψ ∈ ({phi} : Set Formula))
  exact ⟨d_bot⟩

/-!
## FMP TaskFrame Construction

We build a TaskFrame where world states are exactly the FMP's FiniteWorldState type.
-/

/--
A TaskFrame built from FiniteWorldState for a given target formula.

The world states are exactly the FMP's FiniteWorldState type.
The task relation is permissive (always true) since we only need satisfiability at one point.
-/
noncomputable def fmpTaskFrame (phi : Formula)
    {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where
  WorldState := FiniteWorldState phi
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial

/--
A TaskModel over the FMP TaskFrame.

The valuation is derived from the FiniteWorldState's truth assignment.
For atoms not in the closure, we default to false.
-/
noncomputable def fmpTaskModel (phi : Formula)
    {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskModel (fmpTaskFrame phi (D := D)) where
  valuation := fun w p =>
    if h : Formula.atom p ∈ closure phi then
      w.models (Formula.atom p) h
    else
      False

/--
A constant WorldHistory over the FMP TaskFrame.

Returns the same world state at all times. The domain is all of D.
Since the task relation is always true, coherence is trivially satisfied.
-/
noncomputable def fmpWorldHistory (phi : Formula) (w : FiniteWorldState phi)
    {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    WorldHistory (fmpTaskFrame phi (D := D)) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => w
  respects_task := fun _ _ _ _ _ => trivial

/-!
## Truth Correspondence for MCS-Derived World States

For world states derived from ClosureMaximalConsistent sets via `worldStateFromClosureMCS`,
truth in the FMP model corresponds to truth in the general TaskModel.

The key insight is that MCS-derived world states have the negation completeness
property, which ensures the backward direction of implication correspondence.
-/

/--
For MCS-derived world states, FMP truth equals TaskModel truth.

This is the key technical lemma that enables embedding FMP models
into the general semantic framework.

**Proof Note**: The proof is by structural induction on formulas.
The critical cases are:
- Implication: Uses MCS negation completeness for backward direction
- Modal box: Uses T axiom (box psi implies psi) from MCS
- Temporal: Uses constant history (all times have same state)
-/
theorem mcs_world_truth_correspondence (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S)
    {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (psi : Formula) (h_mem : psi ∈ closure phi) :
    let w := worldStateFromClosureMCS phi S h_mcs
    w.models psi h_mem ↔
    truth_at (fmpTaskModel phi (D := D)) (fmpWorldHistory phi w) (0 : D) psi := by
  -- The proof uses structural induction on psi
  -- For MCS-derived states, we have the full correspondence due to
  -- negation completeness and the closure MCS properties
  intro w
  induction psi with
  | atom p =>
    -- Atoms: direct correspondence via valuation definition
    simp only [FiniteWorldState.models, truth_at, fmpTaskModel, fmpWorldHistory]
    constructor
    · intro h_models
      -- Need to provide the domain membership proof (trivial) and the valuation
      exact ⟨trivial, by simp only [dif_pos h_mem]; exact h_models⟩
    · intro ⟨_, h_val⟩
      simp only [dif_pos h_mem] at h_val
      exact h_val
  | bot =>
    -- Bot is false in both
    simp only [truth_at]
    constructor
    · intro h_models
      have := w.bot_false h_mem
      simp only [eq_iff_iff, iff_false] at this
      exact absurd h_models this
    · intro h; exact h.elim
  | imp psi1 psi2 ih1 ih2 =>
    -- Implication: uses MCS properties
    have h_psi1_mem : psi1 ∈ closure phi := closure_imp_left phi psi1 psi2 h_mem
    have h_psi2_mem : psi2 ∈ closure phi := closure_imp_right phi psi1 psi2 h_mem
    simp only [truth_at]
    constructor
    · -- Forward: FMP implication true → TaskModel implication true
      intro h_models h_psi1_true
      have h_psi1_fmp : w.models psi1 h_psi1_mem := (ih1 h_psi1_mem).mpr h_psi1_true
      have h_psi2_fmp := w.imp_correct psi1 psi2 h_mem h_psi1_mem h_psi2_mem h_models h_psi1_fmp
      exact (ih2 h_psi2_mem).mp h_psi2_fmp
    · -- Backward: TaskModel implication true → FMP implication true
      -- This uses MCS negation completeness
      intro h_truth
      -- In an MCS, (psi1 → psi2) ∈ S ↔ (psi1 ∈ S → psi2 ∈ S)
      have h_imp_iff := closure_mcs_imp_iff phi S h_mcs psi1 psi2 h_mem
      -- We need: w.models (psi1.imp psi2) h_mem
      -- which by worldStateFromClosureMCS_models_iff is equivalent to (psi1.imp psi2) ∈ S
      have h_w_iff := worldStateFromClosureMCS_models_iff phi S h_mcs (psi1.imp psi2) h_mem
      -- Show the implication is in S by showing psi1 ∈ S → psi2 ∈ S
      have h_in_S : (psi1.imp psi2) ∈ S := by
        rw [h_imp_iff]
        intro h_psi1_in_S
        -- psi1 ∈ S → w.models psi1 (by worldStateFromClosureMCS_models_iff, backward direction)
        have h_psi1_w := (worldStateFromClosureMCS_models_iff phi S h_mcs psi1 h_psi1_mem).mp h_psi1_in_S
        -- w.models psi1 → truth_at ... psi1 (by IH, forward direction)
        have h_psi1_truth := (ih1 h_psi1_mem).mp h_psi1_w
        -- truth_at ... psi1 → truth_at ... psi2 (by h_truth)
        have h_psi2_truth := h_truth h_psi1_truth
        -- truth_at ... psi2 → w.models psi2 (by IH, backward direction)
        have h_psi2_w := (ih2 h_psi2_mem).mpr h_psi2_truth
        -- w.models psi2 → psi2 ∈ S (by worldStateFromClosureMCS_models_iff, forward direction)
        exact (worldStateFromClosureMCS_models_iff phi S h_mcs psi2 h_psi2_mem).mpr h_psi2_w
      -- Convert membership to models (membership → models is mp direction)
      exact h_w_iff.mp h_in_S
  | box psi ih =>
    -- Modal box: the task relation is always true, so box requires psi true at all reachable states
    -- With permissive task relation, all states are reachable
    -- For a single MCS-derived state, this degenerates to T axiom
    simp only [truth_at, fmpTaskFrame, fmpWorldHistory]
    have h_psi_mem : psi ∈ closure phi := closure_box phi psi h_mem
    constructor
    · -- Forward: box psi true in FMP → box psi true in TaskModel
      intro h_box_fmp
      -- box psi true means psi is true at all reachable states
      -- Since our model has only one state w (constant history), this means psi true at w
      -- But we need to show it's true at all reachable world states
      -- The issue is that fmpTaskFrame has all FiniteWorldState phi as world states
      -- not just the MCS-derived one
      -- This requires a more sophisticated construction
      sorry
    · -- Backward: box psi true in TaskModel → box psi true in FMP
      intro h_box_truth
      -- For MCS-derived state, box psi in S implies psi in S (T axiom)
      -- So psi is true in w
      have h_box_in_S : psi.box ∈ S := by
        -- We need to relate h_box_truth to membership
        sorry
      sorry
  | all_future psi ih =>
    -- Temporal all_future: requires psi true at all strictly future times
    -- With constant history, all times have the same state
    simp only [truth_at, fmpWorldHistory]
    have h_psi_mem : psi ∈ closure phi := closure_all_future phi psi h_mem
    constructor
    · intro h_future_fmp s _hts
      -- All future times have the same state w (constant history)
      -- So need psi true at w, which follows from temporal reflexivity in MCS
      sorry
    · intro h_future_truth
      -- For any s > 0, psi is true at state w
      -- But all_future in MCS means psi true at all future MCS positions
      -- This is more complex due to indexed MCS families
      sorry
  | all_past psi ih =>
    -- Similar to all_future, symmetric case
    simp only [truth_at, fmpWorldHistory]
    have h_psi_mem : psi ∈ closure phi := closure_all_past phi psi h_mem
    sorry

/-!
## Main Bridge Lemma

The key theorem connecting consistency to satisfiability.
-/

/--
**Bridge Lemma**: If {phi} is set-consistent, then {phi} is satisfiable.

**Proof Strategy**:
1. Extend {phi} to MCS via Lindenbaum
2. phi ∈ MCS (by subset property)
3. Project to closure MCS for phi
4. Build FiniteWorldState from closure MCS
5. phi is true at this world state (by FMP truth lemma)
6. Embed into TaskModel via fmpWorldHistory
7. Truth correspondence gives set_satisfiable {phi}

**Note**: The current proof has sorries in the modal/temporal cases of
truth correspondence. These require more sophisticated FMP infrastructure
to handle the quantification over all accessible/future/past states.
-/
theorem consistent_satisfiable (phi : Formula) (h_cons : SetConsistent ({phi} : Set Formula)) :
    set_satisfiable ({phi} : Set Formula) := by
  -- Step 1: Extend {phi} to MCS via Lindenbaum
  obtain ⟨M, h_sub, h_mcs⟩ := set_lindenbaum {phi} h_cons

  -- Step 2: phi ∈ M (by subset property)
  have h_phi_in_M : phi ∈ M := h_sub (Set.mem_singleton phi)

  -- Step 3: Project to closure MCS
  let S := M ∩ (closureWithNeg phi : Set Formula)
  have h_S_mcs : ClosureMaximalConsistent phi S := mcs_projection_is_closure_mcs phi M h_mcs

  -- Step 4: phi ∈ S (since phi ∈ closure phi and phi ∈ M)
  have h_phi_closure : phi ∈ closure phi := phi_mem_closure phi
  have h_phi_in_S : phi ∈ S := by
    constructor
    · exact h_phi_in_M
    · exact closure_subset_closureWithNeg phi h_phi_closure

  -- Step 5: Build FiniteWorldState from closure MCS
  let w := worldStateFromClosureMCS phi S h_S_mcs

  -- Step 6: phi is true at w (by FMP truth lemma)
  have h_phi_true : w.models phi h_phi_closure := by
    rw [← worldStateFromClosureMCS_models_iff phi S h_S_mcs phi h_phi_closure]
    exact h_phi_in_S

  -- Step 7: Construct TaskModel and show satisfiability
  use Int, inferInstance, inferInstance, inferInstance
  use fmpTaskFrame phi
  use fmpTaskModel phi
  use fmpWorldHistory phi w
  use 0

  -- Show all formulas in {phi} are satisfied
  intro psi h_psi
  simp only [Set.mem_singleton_iff] at h_psi
  rw [h_psi]

  -- Apply truth correspondence for MCS-derived world state
  exact (mcs_world_truth_correspondence phi S h_S_mcs phi h_phi_closure).mp h_phi_true

end Bimodal.Metalogic.FMP
