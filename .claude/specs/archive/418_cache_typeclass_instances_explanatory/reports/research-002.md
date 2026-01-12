# Research Report: Task #418 (Post-Task 420 Analysis)

**Task**: Cache typeclass instances in Explanatory
**Date**: 2026-01-11
**Focus**: Analyze impact of task 420's unbundling on task 418's caching strategy

## Summary

Task 420's unbundling of `LinearOrderedAddCommGroup T` → `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]` has **minimal impact** on task 418's `CompleteLattice` caching strategy. The two typeclass hierarchies are **orthogonal**: `CompleteLattice` applies to the `State` type (mereological structure), while `IsOrderedAddMonoid` applies to the time type `T` (temporal ordering). Task 418's recommendations remain valid but with slightly updated context.

## Key Finding: Orthogonal Type Hierarchies

### Hierarchy 1: CompleteLattice (State Type)

```
ConstitutiveFrame.State : Type*
  └─ [CompleteLattice State]
       ├─ Sup, Inf
       ├─ Lattice
       ├─ PartialOrder
       └─ Preorder
```

**Used for**: Mereological operations (fusion, parthood, null/full states)
**Located in**: Foundation/Frame.lean (line 52)
**Impacts**: `verifies`, `falsifies`, `truthAt` (via parthood checks)

### Hierarchy 2: IsOrderedAddMonoid (Time Type)

```
T : Type* (time)
  ├─ [AddCommGroup T]
  ├─ [LinearOrder T]
  └─ [IsOrderedAddMonoid T]  ← Task 420 unbundling
```

**Used for**: Temporal operations (past/future, duration comparison)
**Located in**: Explanatory/Frame.lean (line 34), Explanatory/Truth.lean (line 36)
**Impacts**: Temporal operators (H, G, P, F, Since, Until)

### Why They're Orthogonal

1. **Different types**: `CompleteLattice` is on `M.frame.State`, while `IsOrderedAddMonoid` is on `T`
2. **Different modules**: `CompleteLattice` comes from Foundation layer (no temporal structure); `IsOrderedAddMonoid` is added in Explanatory layer
3. **No inheritance path**: There's no typeclass inheritance connecting these hierarchies

## Impact Analysis

### What Task 420 Changed

| Before | After |
|--------|-------|
| `[LinearOrderedAddCommGroup T]` | `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]` |

This unbundling:
1. **Reduces** diamond inheritance issues for `T`-related inference
2. **Does not affect** `CompleteLattice` inference on `State`
3. **May slightly reduce** overall typeclass search time due to simpler `T` constraints

### What Task 418 Still Needs to Address

The `CompleteLattice` caching recommendations from research-001.md remain valid:

| Instance to Cache | Still Needed? | Reason |
|-------------------|---------------|--------|
| `CompleteLattice M.frame.State` in `truthAt` | YES | Unaffected by task 420 |
| `CompleteLattice M.frame.State` in `verifies`/`falsifies` | YES | Foundation layer unchanged |
| `LinearOrderedAddCommGroup T` | NO | Already addressed by task 420 |

### Updated Priority Assessment

| Task 418 Recommendation | Original Priority | Post-420 Priority | Notes |
|-------------------------|-------------------|-------------------|-------|
| Cache `CompleteLattice` in `truthAt` | High | High | Still beneficial |
| Cache in `validInModel`/`entailsInModel` | Medium | Medium | Still beneficial |
| Cache in `verifies`/`falsifies` | High | High | Foundation unchanged |
| Address `LinearOrderedAddCommGroup` | High | N/A | Done by task 420 |

## Recommendations

### 1. Task 418 Remains Relevant

The core recommendation—caching `CompleteLattice M.frame.State`—is **unaffected** by task 420. The research-001.md patterns should be implemented:

```lean
-- Pattern B (recommended): Local instance at call site
@[irreducible]
def truthAt (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame) (idx : TemporalIndex T)
    : Formula → Prop :=
  letI := M.frame.toConstitutiveFrame.lattice  -- Cache CompleteLattice
  match ... with  -- existing cases
```

### 2. Synergy with Task 420

Task 420's unbundling may have already provided some performance improvement for the `T` type. Task 418's `CompleteLattice` caching would provide **complementary** improvement for the `State` type. Together, they address both slow inference paths identified in task 400.

### 3. Updated Effort Estimate

Since `LinearOrderedAddCommGroup` caching is no longer needed (done by task 420):

| Original Estimate | Updated Estimate | Reason |
|-------------------|------------------|--------|
| 2-3 hours | 1.5-2 hours | Scope reduced |

### 4. Verification Approach (Updated)

After implementing `CompleteLattice` caching:

1. Run `lake clean && lake build`
2. Compare build times with task 420's baseline (post-Mathlib-upgrade times)
3. Use `set_option trace.Meta.synthInstance true` to verify reduced inference
4. Document combined impact of tasks 420 + 418

## Remaining Work

Task 418 should proceed with implementation focusing on:

1. **Primary**: Add `letI := M.frame.toConstitutiveFrame.lattice` inside `truthAt` body
2. **Secondary**: Add similar caching to `validInModel` and `entailsInModel`
3. **Optional**: Add caching to `verifies`/`falsifies` in Foundation/Semantics.lean

The `LinearOrderedAddCommGroup`-related recommendations from research-001.md (row 3 of the table) can be marked as **DONE by task 420**.

## Decision

**Task 418 should proceed to planning/implementation** with the understanding that:
- Task 420 already addressed the `T` type hierarchy
- Task 418 should focus exclusively on `CompleteLattice State` caching
- The two tasks together provide comprehensive typeclass optimization

## References

- Task 417 research-002.md - Details of task 420's unbundling approach
- Task 418 research-001.md - Original caching patterns (still valid for CompleteLattice)
- Task 400 research-001.md - Performance investigation identifying both bottlenecks

## Next Steps

1. Create implementation plan for task 418 (reduced scope)
2. Focus on `CompleteLattice` caching only
3. Benchmark against post-task-420 baseline
