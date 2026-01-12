# Research Report: Task #359

**Task**: Complete temporal_duality soundness case
**Date**: 2026-01-10
**Focus**: Completing the sorry at SoundnessLemmas.lean:687

## Summary

The `temporal_duality` case in `derivable_implies_swap_valid` (SoundnessLemmas.lean:687) requires proving `is_valid T ψ'.swap.swap` from `h_ψ' : DerivationTree [] ψ'`. By the involution property, this equals `is_valid T ψ'`. The solution involves restructuring to avoid the circular dependency or using a post-hoc completion approach in Soundness.lean.

## Findings

### The Problem Structure

**Location**: `Bimodal/Metalogic/SoundnessLemmas.lean:687`

**Current State**:
```lean
| temporal_duality ψ' h_ψ' ih =>
  intro h_eq
  -- Goal: is_valid T ψ'.swap_past_future.swap_past_future
  -- By involution: = is_valid T ψ'
  -- We have: h_ψ' : DerivationTree [] ψ'
  -- Need: Soundness theorem to bridge derivation to validity
  sorry
```

**The Circular Dependency**:
1. `derivable_implies_swap_valid` needs the soundness theorem for this case
2. But soundness is in Soundness.lean which imports SoundnessLemmas.lean
3. Therefore, we cannot use soundness inside SoundnessLemmas.lean

### Prior Research (Task 213)

Task 213 extensively analyzed this problem and found:

1. **`is_valid_swap_involution` is semantically FALSE** for arbitrary formulas
   - Counterexample: `φ = all_past(atom "p")` in a model where p is true in future but false in past
   - `φ.swap = all_future(atom "p")` is valid, but `φ = all_past(atom "p")` is not

2. **The theorem IS true for derivable formulas**
   - Because the temporal_duality inference rule guarantees swap preservation
   - This is a syntactic property of the proof system, not a semantic property

3. **The architecture was restructured**
   - Bridge theorems moved to `SoundnessLemmas.lean`
   - This resolved the import cycle but left the core sorry

### Proof Goal Analysis

At line 687, the goal state is:
```
case temporal_duality
T : Type u_1
inst✝ : LinearOrderedAddCommGroup T
φ : Formula
h_deriv : ⊢ φ
ψ' : Formula
h_ψ' : ⊢ ψ'
ih : [] = [] → is_valid T ψ'.swap_past_future
h_eq : [] = []
⊢ is_valid T ψ'.swap_past_future.swap_past_future
```

**Key insight**: We have `h_ψ' : ⊢ ψ'` and need `is_valid T ψ'` (after applying involution). This is exactly what the soundness theorem proves: `⊢ φ → is_valid T φ`.

### Solution Approaches

#### Approach 1: Post-hoc Completion in Soundness.lean

The current architecture allows completing the proof in Soundness.lean after the main soundness theorem is proven. This is possible because:

1. `derivable_implies_swap_valid` has a sorry for the temporal_duality case
2. Soundness.lean uses `derivable_implies_swap_valid` in its temporal_duality case (lines 666-669)
3. After proving main soundness, we could prove a "complete" version of `derivable_implies_swap_valid`

**Problem**: Soundness.lean already uses `derivable_implies_swap_valid` in its proof, creating a chicken-and-egg problem.

#### Approach 2: Mutual Recursion on Soundness and Swap Validity

**Key Insight**: We can prove both theorems simultaneously using a single derivation induction that proves two goals:
1. `⊢ φ → is_valid T φ` (soundness)
2. `⊢ φ → is_valid T φ.swap` (swap validity)

In the `temporal_duality` case of (2):
- From `h_ψ' : ⊢ ψ'`, we need `is_valid T ψ'.swap.swap = is_valid T ψ'`
- By the IH for (1) applied to `h_ψ'`, we get `is_valid T ψ'`
- Done!

**Implementation**: Define a combined theorem that proves both by mutual induction:

```lean
theorem soundness_and_swap_validity :
    ∀ {φ : Formula}, (⊢ φ) → (is_valid T φ ∧ is_valid T φ.swap_past_future) := by
  intro φ h
  induction h with
  | temporal_duality ψ' h_ψ' ih =>
    -- IH gives: is_valid T ψ' ∧ is_valid T ψ'.swap
    -- Goal: is_valid T ψ'.swap ∧ is_valid T ψ'.swap.swap
    -- Part 1: is_valid T ψ'.swap (from IH.2)
    -- Part 2: is_valid T ψ' (from IH.1, using involution)
    constructor
    · exact ih.2
    · simpa [Formula.swap_past_future_involution] using ih.1
  | ... -- other cases
```

This eliminates the circular dependency because both properties are proven in one induction.

#### Approach 3: Direct Application of Involution

Looking at the goal more carefully:
```
⊢ is_valid T ψ'.swap_past_future.swap_past_future
```

By the involution theorem `swap_past_future_involution : φ.swap.swap = φ`, we have:
```
ψ'.swap_past_future.swap_past_future = ψ'
```

So the goal is `is_valid T ψ'`. We have `h_ψ' : ⊢ ψ'`.

**The IH** gives us `is_valid T ψ'.swap`. But we need `is_valid T ψ'`.

The issue is the IH only provides swap validity for `ψ'`, not validity of `ψ'` itself. This is because `derivable_implies_swap_valid` only proves swap validity, not soundness.

**Conclusion**: Approach 2 (mutual recursion) is the correct solution.

### Implementation Strategy

**Recommended Approach**: Prove a combined theorem that gives both soundness and swap validity from derivability:

```lean
/-- Combined theorem: Derivability implies both validity and swap validity.
    This eliminates the circular dependency in the temporal_duality case. -/
theorem derivable_implies_valid_and_swap_valid :
    ∀ {φ : Formula}, DerivationTree [] φ →
      (is_valid T φ ∧ is_valid T φ.swap_past_future) := by
  intro φ h_deriv
  induction h_deriv with
  | axiom Γ' φ' h_axiom =>
    constructor
    · exact axiom_valid h_axiom
    · exact axiom_swap_valid φ' h_axiom
  | assumption Γ' φ' h_mem =>
    exact False.elim (List.not_mem_nil φ' h_mem)
  | modus_ponens Γ' φ' ψ' h_imp h_phi ih_imp ih_phi =>
    constructor
    · -- is_valid T ψ'
      intro F M τ t ht
      have h1 := ih_imp.1 F M τ t ht
      have h2 := ih_phi.1 F M τ t ht
      simp only [truth_at] at h1
      exact h1 h2
    · -- is_valid T ψ'.swap
      exact mp_preserves_swap_valid φ' ψ' ih_imp.2 ih_phi.2
  | necessitation φ' h_phi ih =>
    constructor
    · -- is_valid T (□φ')
      intro F M τ t ht σ hs
      exact ih.1 F M σ t hs
    · -- is_valid T (□φ').swap = is_valid T □(φ'.swap)
      exact modal_k_preserves_swap_valid φ' ih.2
  | temporal_necessitation φ' h_phi ih =>
    constructor
    · -- is_valid T (Fφ')
      intro F M τ t ht s hs hts
      exact ih.1 F M τ s hs
    · -- is_valid T (Fφ').swap = is_valid T P(φ'.swap)
      exact temporal_k_preserves_swap_valid φ' ih.2
  | temporal_duality ψ' h_ψ' ih =>
    -- Key case: IH gives BOTH validity and swap validity of ψ'
    -- Goal: validity and swap validity of ψ'.swap
    constructor
    · -- is_valid T ψ'.swap: from ih.2
      exact ih.2
    · -- is_valid T ψ'.swap.swap = is_valid T ψ': from ih.1
      simpa [Formula.swap_past_future_involution] using ih.1
  | weakening Γ' Δ' φ' h_phi h_sub ih =>
    -- Γ' must be empty, so ih applies
    have h_gamma_empty : Γ' = [] := by
      cases Γ' with
      | nil => rfl
      | cons head tail =>
        have : head ∈ Δ' := h_sub (List.mem_cons_self head tail)
        exact False.elim (List.not_mem_nil head this)
    exact ih h_gamma_empty
```

Then extract the individual theorems:
```lean
theorem soundness_from_empty : (⊢ φ) → is_valid T φ :=
  fun h => (derivable_implies_valid_and_swap_valid h).1

theorem derivable_implies_swap_valid : (⊢ φ) → is_valid T φ.swap :=
  fun h => (derivable_implies_valid_and_swap_valid h).2
```

## Recommendations

1. **Primary Recommendation**: Implement Approach 2 (mutual recursion) by replacing the current `derivable_implies_swap_valid` with `derivable_implies_valid_and_swap_valid` that proves both properties simultaneously.

2. **Implementation Steps**:
   - Add the combined theorem `derivable_implies_valid_and_swap_valid` in SoundnessLemmas.lean
   - Derive `soundness` from the combined theorem (or use it directly)
   - The temporal_duality case completes naturally with the mutual IH

3. **Key Insight**: The circular dependency is resolved by proving both soundness and swap validity in a single induction, so the temporal_duality case can use the soundness part of the IH.

## References

- Task 213 Research Report: `.claude/specs/213_resolve_is_valid_swap_involution_blocker/reports/research-001.md`
- Task 213 Circular Dependency Analysis: `.claude/specs/213_resolve_is_valid_swap_involution_blocker/reports/circular-dependency-analysis.md`
- SoundnessLemmas.lean: `Bimodal/Metalogic/SoundnessLemmas.lean`
- Soundness.lean: `Bimodal/Metalogic/Soundness.lean`
- Formula.swap_past_future_involution: `Bimodal/Syntax/Formula.lean:294`

## Next Steps

1. Implement `derivable_implies_valid_and_swap_valid` in SoundnessLemmas.lean
2. Update/remove the current sorry-containing `derivable_implies_swap_valid`
3. Update Soundness.lean to use the new combined theorem
4. Verify all proofs compile without sorries
5. Run full build to confirm no regressions
