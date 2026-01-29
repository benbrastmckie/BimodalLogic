# Research Report: Task #750 (Supplementary)

**Task**: Relationship analysis between tasks 749 and 750
**Date**: 2026-01-29
**Focus**: Should we proceed with task 749 given research-006.md findings? How do these tasks relate?

## Summary

Tasks 749 and 750 represent **two independent paths** to sorry-free completeness. Research-006 clarifies that the algebraic path (tangentially related to both tasks) is a separate concern. The key finding is: **Task 749 is valuable and should proceed, but it addresses a different gap than Task 750.**

## Task Relationship Analysis

### Task 749: Establish sorry-free completeness via semantic_weak_completeness

**Goal**: Bridge from `valid φ` (standard Kripke validity) to `semantic_weak_completeness` (which is already sorry-free).

**The Gap** (from research-001.md):
```
valid φ → ∀ (w : SemanticWorldState φ), semantic_truth_at_v2 φ w t φ
```

**What 749 Provides**: If successful, a completely new sorry-free completeness theorem using the FMP machinery. This is a **shortcut** that bypasses all the canonical model machinery with sorries.

### Task 750: Refactor forward Truth Lemma to remove sorries

**Goal**: Clean up the canonical model path by:
1. Removing unnecessary backward direction
2. Refactoring forward direction to avoid sorries
3. Potentially leveraging algebraic representation theorem

**What 750 Provides**: A cleaner canonical model approach with fewer sorries, maintaining the traditional proof architecture.

### How They Relate

| Aspect | Task 749 | Task 750 |
|--------|----------|----------|
| **Path** | FMP/semantic model | Canonical model |
| **Approach** | Bridge validity → finite model truth | Fix existing sorries |
| **Dependency** | Uses `semantic_weak_completeness` (sorry-free) | Uses `representation_theorem` (has sorries) |
| **Outcome** | New sorry-free completeness theorem | Reduced sorries in existing path |
| **Architectural Change** | Additive (new theorem) | Refactoring (fix existing) |

## Does Research-006 Affect Task 749?

**Short answer: No.**

Research-006 analyzed the **algebraic path** (AlgebraicRepresentation.lean), which:
- Proves `AlgSatisfiable φ ↔ AlgConsistent φ`
- Uses ultrafilters of the Lindenbaum algebra
- Has no explicit time structure

This is **not related** to task 749's approach. Task 749 uses:
- The FMP path (FiniteModelProperty.lean, SemanticCanonicalModel.lean)
- `semantic_weak_completeness` which works with `SemanticWorldState`
- Explicit (bounded) time structure via `BoundedTime`

The semantic gap identified in research-006 is between:
```
Algebraic semantics (ultrafilters) ← gap → Kripke semantics (TaskModel)
```

Task 749's gap is different:
```
Kripke semantics (valid over all TaskModel) ← gap → FMP semantics (SemanticWorldState)
```

## Recommendation: Proceed with Task 749

### Reasons

1. **Independent value**: Task 749 provides a completely sorry-free path to completeness that doesn't depend on fixing the canonical model sorries.

2. **Smaller gap to bridge**: The FMP semantic model is closer to Kripke semantics than the algebraic model:
   - SemanticWorldState has explicit world state structure
   - SemanticCanonicalModel is a TaskModel (same type!)
   - The bridge is about showing validity specializes correctly

3. **Complementary to 750**: Even if task 750 succeeds in reducing sorries, task 749 provides an alternative route that's valuable for:
   - Redundancy (two independent completeness proofs)
   - Educational value (demonstrates FMP-based approach)
   - Future extensions (FMP machinery may be useful elsewhere)

4. **Research-006 explicitly says**: "Continue with task 750 as planned - focus on Representation path" - but this doesn't preclude task 749, which uses a different path entirely.

### Prioritization

| Priority | Task | Reasoning |
|----------|------|-----------|
| **Higher** | 750 | Directly addresses existing sorries in the main completeness path |
| **Secondary** | 749 | Provides alternative sorry-free path, but requires new bridging work |

However, if the goal is "achieve sorry-free completeness by any means," task 749 may actually be **faster** because:
- `semantic_weak_completeness` is already sorry-free
- The gap is a single theorem (`valid_implies_all_semantic_truth`)
- No need to fix multiple scattered sorries

### Suggested Order

1. **First**: Complete task 750's research/planning to understand full scope
2. **Then**: Assess whether task 749's bridge is easier than 750's fixes
3. **Choose**: Implement whichever path is more tractable first

## Architecture Overview

```
                COMPLETENESS PATHS
                ==================

    PATH A (Task 750)                PATH B (Task 749)
    =================                =================
         valid φ                          valid φ
           │                                │
           ▼                                ▼
     Canonical Model              SemanticCanonicalModel
     (UniversalCanonical)         (over BoundedTime)
           │                                │
           ▼                                ▼
     Truth Lemma                  valid_implies_all_semantic_truth
     (has sorries)                (needs to be proven)
           │                                │
           ▼                                ▼
     representation_theorem       semantic_weak_completeness
     (has sorries)                (sorry-free!)
           │                                │
           ▼                                ▼
         ⊢ φ                              ⊢ φ


    PATH C (Not Recommended - research-006)
    =======================================
    AlgebraicRepresentation
           │
           ▼
    AlgSatisfiable ↔ AlgConsistent
           │
           ▼
    (No bridge to Kripke semantics)
    (Would need new theorem: 2-4 weeks)
```

## Conclusion

**Task 749 should proceed.** It represents a valid, potentially faster path to sorry-free completeness that is independent of the canonical model sorries addressed by task 750. The research in research-006 about the algebraic semantic gap is **orthogonal** to task 749's approach.

The decision of which to implement first depends on:
- If minimizing total sorries is the goal → Task 750
- If achieving any sorry-free completeness fastest is the goal → Task 749 may be faster

Both tasks provide value and are complementary rather than redundant.
