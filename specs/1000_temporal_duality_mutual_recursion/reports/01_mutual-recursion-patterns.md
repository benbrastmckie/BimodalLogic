# Research Report: Mutual Recursion Patterns for temporal_duality Soundness

**Task**: 1000 - temporal_duality_mutual_recursion
**Session**: sess_1773944850_1f2cb3
**Date**: 2026-03-19

## Executive Summary

The `temporal_duality` case in `soundness_dense` (Soundness.lean:690-697) requires proving that if `d : DerivationTree [] phi` is valid, then `phi.swap` is also valid. This creates a mutual dependency between:

1. `derivable_locally_valid`: Proving derivable formulas are valid
2. `derivable_implies_swap_valid`: Proving swaps of derivable formulas are valid

The core challenge is that Lean's termination checker cannot infer structural recursion when the derivation tree index (`DerivationTree [] phi`) varies while the formula itself changes (to `phi.swap`).

## Problem Analysis

### Current State

**Location**: `Theories/Bimodal/Metalogic/Soundness.lean:690-697`

```lean
| temporal_duality phi' d' ih =>
    -- d' : |- phi', and the goal is truth_at ... phi'.swap
    -- This requires derivable_implies_swap_valid from SoundnessLemmas, which proves
    -- that for derivable formulas, their swap is also valid.
    -- However, implementing this requires resolving mutual recursion between
    -- derivable_locally_valid and derivable_implies_swap_valid (see research report).
    -- For now, marked sorry pending proper implementation.
    sorry
```

### Why Structural Recursion Fails

The induction hypothesis `ih` has type:
```lean
ih : d'.isDenseCompatible -> ... -> truth_at M Omega tau t phi'
```

But the goal is:
```lean
goal : truth_at M Omega tau t phi'.swap
```

The formula index changes from `phi'` to `phi'.swap`, which is not structurally smaller. The derivation `d'` proves `phi'`, not `phi'.swap`.

### Mutual Dependency Structure

To prove `soundness_dense`, we need:
1. **For temporal_duality case**: If `|- phi` is valid, then `phi.swap` is valid
2. **This requires**: `derivable_implies_swap_valid : (|- phi) -> is_valid phi.swap`

But `derivable_implies_swap_valid` itself requires:
- Proving axiom swaps are valid (done in `axiom_swap_valid`)
- Proving rule preservation for swaps (done in `*_preserves_swap_valid`)
- **For temporal_duality subcase**: Proving `((phi.swap).swap)` is valid, which needs `phi` is valid

This creates the mutual recursion:
```
soundness_dense <---> derivable_implies_swap_valid
      |                        |
      v                        v
  (d' : |- phi)          (d' : |- phi)
      |                        |
      v                        v
 valid phi.swap           valid (phi.swap).swap = valid phi
```

## Solution Approaches

### Approach A: Combined Well-Founded Induction (RECOMMENDED)

**Pattern**: Define a single function computing both goals simultaneously using `Prod` return type.

```lean
/-- Combined soundness and swap-soundness via well-founded recursion on height. -/
def soundness_and_swap_combined
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [DenselyOrdered D] [Nontrivial D]
    (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible)
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau ∈ Omega) (t : D) :
    truth_at M Omega tau t phi ∧ truth_at M Omega tau t phi.swap := by
  induction d generalizing tau t with
  | axiom _ phi' h_ax =>
    constructor
    · exact axiom_locally_valid h_ax h_dc F M Omega h_sc tau h_mem t
    · exact axiom_swap_valid phi' h_ax h_dc F M Omega h_sc tau h_mem t
  | temporal_duality phi' d' ih =>
    -- ih gives both parts for d' at phi'
    have ⟨h_valid, h_swap⟩ := ih h_dc tau h_mem t
    constructor
    · -- Goal: phi'.swap valid. Use second part of ih directly
      exact h_swap
    · -- Goal: (phi'.swap).swap = phi' valid. Use first part of ih
      rw [Formula.swap_past_future_involutive] at h_valid ⊢
      exact h_valid
  -- ... other cases use ih.1 for validity, ih.2 for swap validity
termination_by d.height
```

**Advantages**:
- Single induction handles both goals
- `termination_by d.height` works since we always recurse on subderivations
- The temporal_duality case has access to both `h_valid` (for phi') and `h_swap` (for phi'.swap)
- Uses the involution property: `phi.swap.swap = phi`

**Implementation Notes**:
1. Define in SoundnessLemmas.lean to avoid circular imports
2. Requires proving `Formula.swap_past_future_involutive : phi.swap.swap = phi`
3. Extract separate theorems from the combined result

### Approach B: Explicit WellFounded.fix

**Pattern**: Use `WellFounded.Nat.fix` with explicit height measure.

```lean
def derivable_implies_swap_valid_wf (phi : Formula) (d : DerivationTree [] phi)
    (h_dc : d.isDenseCompatible) :
    is_valid D phi.swap :=
  WellFounded.Nat.fix (h := fun d => d.height)
    (F := fun d ih =>
      match d with
      | .temporal_duality phi' d' =>
        -- Can call ih d' (proof that d'.height < d.height)
        have h_phi_valid : is_valid D phi' := ih d' (by simp [DerivationTree.height]; omega)
        -- Use h_phi_valid and involution
        ...
      | ... => ...)
    d
```

**Advantages**:
- Maximum control over recursion
- Can pass arbitrary recursive hypotheses

**Disadvantages**:
- More verbose
- Harder to read and maintain
- Requires explicit proof that all recursive calls have smaller height

### Approach C: Sum Type Encoding

**Pattern**: Encode the two goals as `Sum` type and do well-founded induction on tagged inputs.

```lean
inductive SoundnessGoal (phi : Formula) where
  | validity : SoundnessGoal phi
  | swapValidity : SoundnessGoal phi

def soundness_sum (d : DerivationTree [] phi) (goal : SoundnessGoal phi) :
    match goal with
    | .validity => is_valid D phi
    | .swapValidity => is_valid D phi.swap := by
  match goal with
  | .validity =>
    induction d with
    | temporal_duality phi' d' ih =>
      -- Need swap validity of phi', call recursively with .swapValidity
      exact soundness_sum d' .swapValidity
    | ...
  | .swapValidity =>
    induction d with
    | temporal_duality phi' d' ih =>
      -- Need validity of phi' (since phi'.swap.swap = phi')
      exact soundness_sum d' .validity
    | ...
termination_by (d.height, goal)
```

**Advantages**:
- Clean separation of cases
- Lexicographic termination on (height, goal)

**Disadvantages**:
- Complex type signatures with dependent match
- May have issues with definitional equality in Lean 4

### Approach D: Mutual Block with termination_by

**Pattern**: Use Lean 4's `mutual` block with shared `termination_by`.

```lean
mutual
def derivable_locally_valid (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) :
    is_valid D phi := by
  match d with
  | .temporal_duality phi' d' =>
    -- Goal is phi'.swap valid
    exact derivable_implies_swap_valid d' (by simp [DerivationTree.isDenseCompatible] at h_dc; exact h_dc)
  | ...

def derivable_implies_swap_valid (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) :
    is_valid D phi.swap := by
  match d with
  | .temporal_duality phi' d' =>
    -- Goal is (phi'.swap).swap = phi' valid
    have h_inv : phi'.swap.swap = phi' := Formula.swap_past_future_involutive phi'
    rw [h_inv]
    exact derivable_locally_valid d' (by simp [DerivationTree.isDenseCompatible] at h_dc; exact h_dc)
  | ...
end

termination_by
  derivable_locally_valid d _ => d.height
  derivable_implies_swap_valid d _ => d.height
```

**Status**: This is the most idiomatic Lean 4 approach but requires verifying that Lean's termination checker accepts cross-calls within mutual blocks.

## Existing Codebase Patterns

### DeductionTheorem.lean Pattern

The project already uses well-founded recursion on `DerivationTree.height` in `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean`:

```lean
def deduction_theorem (Gamma : Context) (A B : Formula)
    (h : (A :: Gamma) |- B) :
    Gamma |- A.imp B := by
  -- ... match on h ...
termination_by h.height
decreasing_by
  simp_wf
  · exact DerivationTree.mp_height_gt_left _ _
  · exact DerivationTree.mp_height_gt_right _ _
  · -- ...
```

This confirms the pattern works and should be followed.

### Height Properties Available

From `Derivation.lean`:
- `DerivationTree.height` : computable height function
- `mp_height_gt_left` : h1.height < (modus_ponens ... h1 h2).height
- `mp_height_gt_right` : h2.height < (modus_ponens ... h1 h2).height
- `subderiv_height_lt` : d.height < (weakening ... d ...).height
- `temporal_duality_height_succ` : (temporal_duality phi d).height = d.height + 1

### Supporting Lemmas Available

From `SoundnessLemmas.lean`:
- `axiom_swap_valid` : All axiom swaps are valid (COMPLETE)
- `mp_preserves_swap_valid` : Modus ponens preserves swap validity (COMPLETE)
- `modal_k_preserves_swap_valid` : Modal K preserves swap validity (COMPLETE)
- `temporal_k_preserves_swap_valid` : Temporal K preserves swap validity (COMPLETE)
- `axiom_locally_valid` : All axioms are locally valid (COMPLETE)
- `truth_at_swap_swap` : Double swap preserves truth (COMPLETE)

### Missing Lemma

Need to verify/add:
```lean
theorem Formula.swap_past_future_involutive (phi : Formula) :
    phi.swap_past_future.swap_past_future = phi
```

This should be in `Bimodal/Syntax/Formula.lean` or similar.

## Recommended Implementation Plan

### Phase 1: Verify Prerequisites

1. Check that `Formula.swap_past_future_involutive` exists or add it
2. Verify all axiom cases are handled in `axiom_swap_valid`

### Phase 2: Implement Combined Theorem

1. Add to `SoundnessLemmas.lean`:
```lean
/-- Combined soundness: derivability implies both validity and swap-validity.

Uses well-founded recursion on derivation height to handle the mutual dependency
between validity and swap-validity in the temporal_duality case.
-/
theorem derivable_valid_and_swap_valid [DenselyOrdered D] [Nontrivial D]
    {phi : Formula} (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) :
    is_valid D phi ∧ is_valid D phi.swap_past_future := by
  induction d with
  | axiom _ phi' h_ax =>
    exact ⟨axiom_locally_valid h_ax h_dc, axiom_swap_valid phi' h_ax h_dc⟩
  | temporal_duality phi' d' ih =>
    obtain ⟨h_valid, h_swap⟩ := ih h_dc
    constructor
    · exact h_swap  -- phi'.swap is valid
    · simp only [Formula.swap_past_future_involutive] at h_valid ⊢
      exact h_valid  -- (phi'.swap).swap = phi' is valid
  | modus_ponens _ phi' psi' d1 d2 ih1 ih2 =>
    obtain ⟨h_dc1, h_dc2⟩ := h_dc
    obtain ⟨h1_valid, h1_swap⟩ := ih1 h_dc1
    obtain ⟨h2_valid, h2_swap⟩ := ih2 h_dc2
    constructor
    · -- psi' valid from modus ponens
      exact mp_valid h1_valid h2_valid
    · -- psi'.swap valid from mp_preserves_swap_valid
      exact mp_preserves_swap_valid phi' psi' h1_swap h2_swap
  | necessitation phi' d' ih =>
    obtain ⟨h_valid, h_swap⟩ := ih h_dc
    constructor
    · exact necessitation_preserves_valid h_valid
    · exact modal_k_preserves_swap_valid phi' h_swap
  | temporal_necessitation phi' d' ih =>
    obtain ⟨h_valid, h_swap⟩ := ih h_dc
    constructor
    · exact temporal_necessitation_preserves_valid h_valid
    · exact temporal_k_preserves_swap_valid phi' h_swap
  | irr p phi' h_fresh d' ih =>
    -- IRR case - handle separately
    sorry
  | weakening Gamma' Delta' phi' d' h_sub ih =>
    exact ih h_dc
  | assumption _ _ h_mem =>
    -- Empty context, h_mem : phi ∈ [] is false
    exact absurd h_mem (List.not_mem_nil _)
termination_by d.height
```

### Phase 3: Extract Individual Theorems

```lean
/-- Derivability implies validity (extracted from combined theorem). -/
theorem derivable_locally_valid [DenselyOrdered D] [Nontrivial D]
    {phi : Formula} (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) :
    is_valid D phi :=
  (derivable_valid_and_swap_valid d h_dc).1

/-- Derivability implies swap validity (extracted from combined theorem). -/
theorem derivable_implies_swap_valid [DenselyOrdered D] [Nontrivial D]
    {phi : Formula} (d : DerivationTree [] phi) (h_dc : d.isDenseCompatible) :
    is_valid D phi.swap_past_future :=
  (derivable_valid_and_swap_valid d h_dc).2
```

### Phase 4: Wire into soundness_dense

```lean
| temporal_duality phi' d' ih =>
    -- Use the extracted swap validity theorem
    have h_dc_sub : d'.isDenseCompatible := h_dc
    exact derivable_implies_swap_valid d' h_dc_sub F M Omega h_sc tau h_mem t
```

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| `termination_by d.height` rejected | Low | High | Use explicit WellFounded.fix |
| Missing involution lemma | Low | Medium | Add to Formula.lean |
| IRR case complexity | Medium | Medium | Handle separately with product frame |
| Type unification issues | Low | Medium | Add explicit type annotations |

## Conclusion

**Recommended approach**: Approach A (Combined Well-Founded Induction) using `Prod` return type.

This approach:
1. Follows existing patterns in the codebase (DeductionTheorem.lean)
2. Cleanly handles the mutual dependency
3. Uses `termination_by d.height` which is already proven to work
4. Produces both theorems in one pass, avoiding any actual mutual recursion

The implementation should take approximately 2-3 hours for a skilled Lean developer familiar with the codebase.
