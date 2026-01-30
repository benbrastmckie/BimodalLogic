/-!
# Archived: Truth Lemma Gap Code (Task 776)

**Archived**: 2026-01-30
**Original Location**: Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
**Reason**: Contains sorry in truth_at_implies_semantic_truth due to architectural impossibility

## Why This Code is Archived

### Sorry #2: truth_at_implies_semantic_truth

The "forward truth lemma" requires showing that if a formula is true under
recursive `truth_at` evaluation, then the finite model's assignment marks it true.

**Why it's sorry'd**: **Architectural impossibility** due to S5-style Box semantics.

**Architectural Analysis** (from Task 750 research):

1. **Box Quantifies Over ALL Histories**: In TM semantics, `truth_at M tau t (box psi)`
   requires `psi` to be true at ALL world states accessible from `tau.states t _`.
   This is universal quantification over the entire frame.

2. **MCS Construction Has One State**: A ClosureMaximalConsistent set describes ONE
   world state's truth values. It has no information about other histories.

3. **The Gap**: For the forward direction, we need:
   - Given: `truth_at M tau t phi` (recursive evaluation)
   - Show: The assignment at `tau.states t ht` has `phi` marked true

   For compound formulas (especially Box), this requires the assignment to MATCH
   recursive evaluation. But arbitrary `FiniteWorldState`s have arbitrary
   locally-consistent assignments - they don't necessarily match recursive truth.

4. **For MCS-derived states**: The backward direction works because MCS membership
   DEFINES what's true. But the forward direction would require knowing the formula
   is in the MCS, which requires completeness - circular!

## Sorry-Free Alternative

Use `semantic_weak_completeness` from the active codebase:

```lean
-- In Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

This theorem works via contrapositive:
1. Assume phi is not provable
2. Then {phi.neg} is consistent
3. Build MCS-derived countermodel
4. phi is false at this world state (by construction)
5. Contradicts hypothesis

The contrapositive avoids the forward truth lemma because:
- We only need to show phi is FALSE at ONE world state
- MCS-derived world states have the truth correspondence property

## Archived Theorems

The following theorems were removed from SemanticCanonicalModel.lean:

### truth_at_atom_iff_semantic
Truth correspondence for atoms (base case, actually provable but part of deprecated path).

### truth_at_bot_iff_semantic
Truth correspondence for bot (base case, actually provable but part of deprecated path).

### truth_at_implies_semantic_truth (SORRY)
The forward truth lemma - this is where the sorry is.

### valid_implies_semantic_truth
Bridge lemma connecting universal validity to semantic model truth.
Depends on truth_at_implies_semantic_truth.

### valid_implies_neg_unsatisfiable
If phi is valid, there is no model where phi.neg is true.

### set_mcs_neg_excludes_helper
Helper for negation excludes membership in MCS.

### sorry_free_weak_completeness
Misnamed - actually depends on sorried truth_at_implies_semantic_truth.

## References

- Task 750: Original research on truth bridge gap
- Task 769: Sorry audit and deprecation marking
- Task 776: This archival
-/

-- NOTE: This file does not compile. It is preserved as documentation only.
-- The code below shows the original definitions for reference.

/-
namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics

-- DEPRECATED (Task 769, 2026-01-30): Use semantic_weak_completeness instead
theorem truth_at_implies_semantic_truth (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi) :
    semantic_truth_at_v2 phi (tau.states 0 ht)
      (BoundedTime.origin (temporalBound phi)) phi := by
  -- ARCHITECTURAL GAP: The fundamental issue is that FiniteWorldState's assignment
  -- can be ANY locally consistent function, but semantic truth checking requires
  -- the assignment to MATCH what recursive evaluation would produce. This is only
  -- guaranteed for MCS-derived world states.
  sorry

theorem valid_implies_semantic_truth (phi : Formula)
    (h_valid : valid phi) :
    forall (w : SemanticWorldState phi),
      semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi := by
  intro w
  obtain ⟨tau, ht, h_eq⟩ := semantic_world_state_has_world_history phi w
  have h_truth := h_valid Int (SemanticCanonicalFrame phi) (SemanticCanonicalModel phi) tau 0
  have h_semantic := truth_at_implies_semantic_truth phi tau ht h_truth
  rw [← h_eq]
  exact h_semantic

theorem valid_implies_neg_unsatisfiable (phi : Formula) (h_valid : valid phi) :
    forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (F : TaskFrame D) (M : TaskModel F) (tau : WorldHistory F) (t : D),
    not (truth_at M tau t phi.neg) := by
  intro D _ _ _ F M tau t h_neg
  simp only [truth_at, Formula.neg] at h_neg
  have h_phi := h_valid D F M tau t
  exact h_neg h_phi

noncomputable def sorry_free_weak_completeness (phi : Formula) :
    valid phi -> ⊢ phi := by
  intro h_valid
  apply semantic_weak_completeness phi
  exact valid_implies_semantic_truth phi h_valid

end Bimodal.Metalogic.FMP
-/
