# Research Report: Removing Sorry from weak_completeness

**Task**: 779
**Date**: 2026-01-30
**Session**: sess_1769756897_537227
**Focus**: Preserve weak_completeness while making it sorry-free

## Executive Summary

The sorry in `weak_completeness` bridges two different notions of validity:
1. **Universal validity** (`valid φ`): True in ALL models (all D, F, M, τ, t)
2. **Semantic validity** (`∀ w : SemanticWorldState, semantic_truth_at_v2 w φ`): True at all finite semantic world states

**Key Finding**: This gap IS bridgeable. The SemanticWorldState construction can be embedded into a proper TaskModel, allowing us to instantiate the universal `valid` quantification with this specific model.

## The Gap Analysis

### Current Signatures

```lean
-- What we have (sorry-free):
semantic_weak_completeness (φ : Formula) :
    (∀ w : SemanticWorldState φ, semantic_truth_at_v2 φ w origin φ) → ⊢ φ

-- What we want:
weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ

-- valid φ means:
∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
  truth_at M τ t φ
```

### The Bridge Needed

To prove `valid φ → ContextDerivable [] φ`, we need:
```
valid φ → (∀ w : SemanticWorldState φ, semantic_truth_at_v2 φ w origin φ)
```

### Why Previous Attempts Failed (Forward Truth Lemma)

The archived approach tried to prove:
```lean
-- FAILS: Forward truth lemma
truth_at M τ t φ → semantic_truth_at_v2 φ w origin φ
```

This fails because it tries to show that arbitrary model truth implies semantic model truth for a SPECIFIC world state w. The problem: arbitrary FiniteWorldStates have arbitrary locally-consistent assignments - they don't necessarily match recursive truth.

## The Solution: Build TaskModel FROM SemanticWorldState

Instead of proving the forward direction for arbitrary models, we can:

1. **Build a proper TaskModel from SemanticWorldStates**
2. **Prove truth correspondence IN THIS MODEL**
3. **Instantiate `valid` with this model**

### Construction Outline

For any formula φ, we can construct:

```lean
-- Domain: Use BoundedTime (temporalBound φ) as D (it's a LinearOrderedAddCommGroup)
-- Actually, BoundedTime is Fin (2*k+1), which is not an additive group.
-- We need Int as the time domain.

-- Frame: Use Int as time domain
def SemanticTaskFrame (φ : Formula) : TaskFrame Int := {
  states := FiniteWorldState φ,  -- World type is finite
  accessibility := fun w v => ∃ h : FiniteHistory φ, ∃ t : BoundedTime _,
                              h.states t = w ∧ h.states (t+1) = v
}

-- History: Each SemanticWorldState determines a constant history at time 0
def worldStateToHistory (φ : Formula) (w : SemanticWorldState φ) : WorldHistory (SemanticTaskFrame φ) := {
  domain := fun t => -k ≤ t ∧ t ≤ k  -- where k = temporalBound φ
  states := fun t _ => SemanticWorldState.toFiniteWorldState w  -- constant
}

-- Model: Valuation from FiniteWorldState.models
def SemanticTaskModel (φ : Formula) : TaskModel (SemanticTaskFrame φ) := {
  valuation := fun w p =>
    if h : Formula.atom p ∈ closure φ
    then w.models (Formula.atom p) h
    else false
}
```

### Truth Correspondence Theorem

The key theorem to prove:

```lean
-- For formulas in the closure, truth_at corresponds to semantic_truth_at_v2
theorem truth_correspondence (φ ψ : Formula) (h_mem : ψ ∈ closure φ)
    (w : SemanticWorldState φ) :
    truth_at (SemanticTaskModel φ) (worldStateToHistory φ w) 0 ψ ↔
    semantic_truth_at_v2 φ w origin ψ
```

### Proof Strategy

1. **Atoms**: By construction, the valuation queries FiniteWorldState.models
2. **Bot**: Both sides are False
3. **Imp**: By IH on subformulas
4. **Box**: **Critical case** - but SemanticTaskFrame has only finitely many states, and Box quantifies over all histories which are determined by finite world states
5. **Temporal**: More complex, but temporal depth bound ensures we only need finite history

### The Box Case - Why This Works

For `truth_at M τ t (box ψ)`:
- We need `∀ σ : WorldHistory, truth_at M σ t ψ`
- In SemanticTaskFrame, histories are determined by finite world states
- So this becomes `∀ w : FiniteWorldState φ, truth_at M (history_from w) t ψ`
- By IH, this is `∀ w, semantic_truth_at_v2 φ (mk w) origin ψ`
- Which is exactly what SemanticWorldState quantification provides

## Implementation Plan

### Phase 1: Define SemanticTaskFrame

Create semantic frame and model from SemanticWorldState construction:

**File**: `Metalogic/FMP/SemanticTaskFrame.lean`

```lean
-- Frame with FiniteWorldState as world type
structure SemanticTaskFrame (φ : Formula) : TaskFrame Int where
  ...

-- Model with valuation from FiniteWorldState.models
def SemanticTaskModel (φ : Formula) : TaskModel (SemanticTaskFrame φ) where
  ...
```

### Phase 2: Prove Truth Correspondence

**File**: `Metalogic/FMP/SemanticTruthCorrespondence.lean`

Prove by induction on formula structure that `truth_at` in the semantic model corresponds to `semantic_truth_at_v2`.

Key lemmas needed:
- Atom case correspondence
- Imp case by IH
- Box case using finite quantification
- Temporal cases using bounded time

### Phase 3: Complete the Bridge

**File**: Update `Metalogic/Completeness/WeakCompleteness.lean`

```lean
theorem valid_implies_semantic_validity (φ : Formula)
    (h_valid : valid φ) :
    ∀ w : SemanticWorldState φ, semantic_truth_at_v2 φ w origin φ := by
  intro w
  -- Instantiate valid with SemanticTaskModel
  have h := h_valid Int (SemanticTaskFrame φ) (SemanticTaskModel φ)
            (worldStateToHistory φ w) 0
  -- Apply truth correspondence
  exact (truth_correspondence φ φ (phi_mem_closure φ) w).mp h

theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  intro h_valid
  have h_semantic := valid_implies_semantic_validity φ h_valid
  exact ⟨semantic_weak_completeness φ h_semantic⟩
```

## Technical Challenges

### Challenge 1: BoundedTime is Not a Group

`BoundedTime k = Fin (2*k+1)` is not a `LinearOrderedAddCommGroup`. The `valid` definition requires the time domain to be such a group.

**Solution**: Use `Int` as the time domain in SemanticTaskFrame, but make histories only defined on the bounded range `[-k, k]`. Atoms outside this range are false (per paper semantics).

### Challenge 2: WorldHistory Domain

`WorldHistory F` requires a domain predicate and states function. The domain must include the origin, and states must be defined on domain times.

**Solution**: Define domain as `{t : Int | |t| ≤ temporalBound φ}` and extend FiniteHistory to this domain (possibly with constant extension).

### Challenge 3: Box Quantification

Box requires truth at ALL histories σ, but SemanticTaskFrame only has finitely many world types.

**Solution**: This is actually why it WORKS - with finite world states, "all histories" is a finite quantification that we can relate to SemanticWorldState quantification.

### Challenge 4: Temporal Operator Correspondence

Temporal operators in `truth_at` quantify over ALL times, not just bounded times.

**Solution**: For times outside the bounded range, atoms are false, so temporal formulas reduce to propositional combinations. The temporal depth bound ensures that all temporally-nested subformulas are in the closure.

## Estimated Complexity

| Phase | Effort | Risk |
|-------|--------|------|
| SemanticTaskFrame definition | Medium | Low |
| Truth correspondence for atoms/imp/bot | Low | Low |
| Truth correspondence for Box | High | Medium - requires careful handling of history quantification |
| Truth correspondence for temporal | High | Medium - requires temporal depth argument |
| Final bridge theorem | Low | Low - just composition |

**Total**: 8-12 hours of Lean proof work

## Alternative Approaches Considered

### Alternative 1: Weaken the Definition of valid

Change `valid` to only quantify over specific model types. **Rejected**: This changes the meaning of the theorem.

### Alternative 2: Use Classical Choice

Use choice to extract a specific countermodel when valid fails. **Rejected**: Doesn't actually help - we still need to show semantic_truth holds when valid holds.

### Alternative 3: Direct Proof Without Embedding

Try to prove the forward direction without building a model. **Rejected**: This is the approach that failed (TruthLemmaGap).

## Recommendations

1. **Proceed with the embedding approach** outlined above. This is mathematically sound and avoids the architectural gap.

2. **Create new supporting module** `Metalogic/FMP/SemanticTaskFrame.lean` for the frame/model construction.

3. **Prove truth correspondence incrementally** - start with atoms, work up to temporal/box cases.

4. **Update task description** to reflect goal: "Prove weak_completeness sorry-free via semantic model embedding"

## Conclusion

The sorry in `weak_completeness` CAN be removed. The key insight is that instead of trying to prove that arbitrary model truth implies semantic truth (forward truth lemma, which fails), we should:

1. Build a TaskModel from the SemanticWorldState construction
2. Prove truth correspondence IN THIS MODEL (both directions work here!)
3. Instantiate the universal `valid` quantification with this specific model

This approach avoids the architectural gap because we're not trying to relate arbitrary models to the semantic model - we're proving properties of ONE specific model that we construct to have the desired truth correspondence.

## References

- Task 750: Original truth bridge analysis
- Task 776: Metalogic refactoring
- `FMP/SemanticCanonicalModel.lean`: Source of semantic_weak_completeness
- `Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean`: Documentation of failed approaches
- `Semantics/Validity.lean`: Definition of valid
