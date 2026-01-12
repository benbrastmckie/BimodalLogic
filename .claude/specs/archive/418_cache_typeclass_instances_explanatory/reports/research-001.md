# Research Report: Task #418

**Task**: Cache typeclass instances in Explanatory
**Date**: 2026-01-12
**Focus**: Add explicit instance arguments to avoid slow typeclass inference

## Summary

This task addresses typeclass inference performance by caching instances that are inferred repeatedly during elaboration. The primary targets are `CompleteLattice` instances (from ConstitutiveFrame) and derived instances from `LinearOrderedAddCommGroup`. The recommended approach uses explicit instance parameters with default values (`inst : T := inferInstance`) and/or the `letI`/`haveI` pattern for local instance caching in proofs.

## Findings

### 1. Instance Inference Bottlenecks

Based on parent task 400's research, two typeclass hierarchies cause repeated slow inference:

| Hierarchy | Source | Depth | Impact |
|-----------|--------|-------|--------|
| `CompleteLattice` | `ConstitutiveFrame.lattice` | Deep (Sup, Inf, Lattice, PartialOrder, Preorder) | Affects every `verifies`/`falsifies`/`truthAt` call |
| `LinearOrderedAddCommGroup T` | Frame.lean variable | Very deep (diamond inheritance) | Addressed by task 416, but residual issues remain |

### 2. Current Instance Flow

The instance resolution path for a `truthAt` call:

```
truthAt M τ t ht σ idx φ
  ├─ M : CoreModel T
  │   └─ M.frame : CoreFrame T
  │       └─ M.frame.toConstitutiveFrame : ConstitutiveFrame
  │           └─ [lattice : CompleteLattice State]  ← INFERENCE HERE
  └─ [LinearOrderedAddCommGroup T]  ← INFERENCE HERE (via variable)
```

Each recursive case of `truthAt` (17 cases) re-triggers this inference chain.

### 3. Lean 4 Local Instance Caching

Lean 4 automatically considers local variables as instances during synthesis. Key tools:

| Construct | Use Case | Example |
|-----------|----------|---------|
| `letI x := ...` | Cache instance in term | `letI _ := F.lattice; ...` |
| `haveI : T := ...` | Cache instance in proof | `haveI : CompleteLattice S := F.lattice` |
| Explicit parameter | Pass instance directly | `def f (_ : CompleteLattice S := F.lattice)` |
| `@` syntax | Bypass inference entirely | `@truthAt T inst M τ t ht σ idx φ` |

### 4. Recommended Caching Patterns

#### Pattern A: Explicit Instance Parameter with Default

```lean
-- Add cached instance as explicit parameter with default value
def truthAt (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame) (idx : TemporalIndex T)
    (latInst : CompleteLattice M.frame.State := M.frame.toConstitutiveFrame.lattice)
    : Formula → Prop
```

**Pros**: Callers don't need to change; instance cached at definition site.
**Cons**: Adds parameter to signature; may complicate proofs about `truthAt`.

#### Pattern B: Local Instance at Call Site

```lean
-- Cache instance in function body
def validInModel (M : CoreModel T) (φ : Formula) : Prop :=
  letI := M.frame.toConstitutiveFrame.lattice  -- Cache before recursive calls
  ∀ (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame),
    truthAt M τ t ht σ TemporalIndex.empty φ
```

**Pros**: Non-invasive; doesn't change function signatures.
**Cons**: Must be added at each call site.

#### Pattern C: Abbreviation with Cached Instance

```lean
-- Create an abbreviation that inlines the instance
abbrev truthAtCached (M : CoreModel T) (τ : WorldHistory M.frame) (t : T)
    (ht : t ∈ τ.domain) (σ : VarAssignment M.frame.toConstitutiveFrame)
    (idx : TemporalIndex T) (φ : Formula) : Prop :=
  letI := M.frame.toConstitutiveFrame.lattice
  truthAt M τ t ht σ idx φ
```

**Pros**: Backward compatible; callers can use either version.
**Cons**: Two entry points to maintain.

### 5. Specific Instances to Cache

| Instance | Location | Priority |
|----------|----------|----------|
| `CompleteLattice M.frame.State` | Truth.lean:truthAt | High |
| `CompleteLattice M.frame.State` | Semantics.lean:verifies/falsifies | High |
| `LinearOrderedAddCommGroup T` | Already optimized by task 416 | Done |

### 6. verifies/falsifies Mutual Block

The `verifies`/`falsifies` mutual definitions in Foundation/Semantics.lean (lines 47-139) also trigger repeated CompleteLattice inference. These should receive the same caching treatment.

### 7. Interaction with Task 416 Fixes

Task 416 applied:
- `set_option synthInstance.maxHeartbeats 100000` (line 39)
- `@[irreducible]` on `truthAt` (line 102)

The `@[irreducible]` helps by preventing unfolding during proofs, but instance inference still occurs at the definition site. Instance caching complements this fix.

### 8. Verification Approach

After implementing caching:

1. Run `lake clean && lake build` to rebuild from scratch
2. Use `set_option trace.Meta.synthInstance true` to verify reduced inference attempts
3. Compare build times before/after
4. Check that all proofs still compile

## Recommendations

### Implementation Strategy

1. **Start with `truthAt`**: Add explicit instance parameter for `CompleteLattice` with default value

2. **Update `validInModel` and `entailsInModel`**: These call `truthAt` in quantifiers; add `letI` caching

3. **Update `verifies`/`falsifies`**: Add instance caching to mutual block body

4. **Verify build**: Run full build and compare times

### Proposed Code Changes

**Truth.lean (truthAt definition)**:
```lean
@[irreducible]
def truthAt (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame) (idx : TemporalIndex T)
    (_ : CompleteLattice M.frame.State := M.frame.toConstitutiveFrame.lattice)
    : Formula → Prop
```

**Truth.lean (validInModel)**:
```lean
def validInModel (M : CoreModel T) (φ : Formula) : Prop :=
  letI := M.frame.toConstitutiveFrame.lattice
  ∀ (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame),
    truthAt M τ t ht σ TemporalIndex.empty φ
```

### Alternative: No Signature Changes

If signature changes are undesirable, use `letI` only inside function bodies:

```lean
@[irreducible]
def truthAt (M : CoreModel T) (τ : WorldHistory M.frame) (t : T) (ht : t ∈ τ.domain)
    (σ : VarAssignment M.frame.toConstitutiveFrame) (idx : TemporalIndex T)
    : Formula → Prop :=
  letI := M.frame.toConstitutiveFrame.lattice
  match ... with  -- existing cases
```

This may provide less benefit since each recursive call still triggers inference.

## References

- [Lean 4 Type Classes Documentation](https://lean-lang.org/theorem_proving_in_lean4/type_classes.html)
- [Typeclass inference performance (Issue #2055)](https://github.com/leanprover/lean4/issues/2055)
- [Use and Abuse of Instance Parameters](https://link.springer.com/article/10.1007/s10817-024-09712-7)
- [Lean 4.22.0 Release Notes - Local instance cache improvements](https://lean-lang.org/doc/reference/latest/releases/v4.22.0/)
- Task 400 research report - Performance investigation
- Task 416 research report - Quick fixes applied

## Next Steps

1. Create implementation plan with phased approach
2. Implement caching in Truth.lean first
3. Extend to Semantics.lean if Truth.lean shows improvement
4. Run build timing comparison
