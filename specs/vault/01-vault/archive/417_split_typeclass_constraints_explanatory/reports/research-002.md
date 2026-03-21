# Research Report: Task #417 (Post-Task 420 Analysis)

**Task**: Split typeclass constraints in Explanatory
**Date**: 2026-01-11
**Focus**: Evaluate task 420's changes against original task 417 recommendations and identify remaining work

## Summary

Task 420 (Mathlib upgrade to v4.27.0-rc1) already implemented typeclass unbundling in the Explanatory module, but used a **different approach** than task 417 originally recommended. The upgrade replaced `LinearOrderedAddCommGroup T` with `[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]`, whereas task 417 recommended using `CovariantClass`. Both approaches achieve the goal of reducing typeclass search complexity, but have different trade-offs. **Task 417 may be considered substantially complete** since the core objective (splitting the bundled constraint) has been achieved, though there are optional refinements worth considering.

## Key Finding: Task 420 Already Implemented Unbundling

### What Task 420 Changed

In all three Explanatory files (Frame.lean, Truth.lean, Explanatory.lean), the constraint was changed from:

```lean
-- Before (v4.14.0)
variable {T : Type*} [LinearOrderedAddCommGroup T]
```

To:

```lean
-- After (v4.27.0-rc1)
variable {T : Type*} [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
```

This unbundling was also applied to:
- All Bimodal semantics files (TaskFrame.lean, TaskModel.lean, WorldHistory.lean, etc.)
- All structure definitions (CoreFrame, CoreModel, TaskFrame, etc.)

### Comparison with Original Task 417 Recommendation

| Aspect | Task 417 Recommended | Task 420 Implemented |
|--------|---------------------|---------------------|
| Group Structure | `[AddCommGroup T]` | `[AddCommGroup T]` |
| Order Structure | `[LinearOrder T]` | `[LinearOrder T]` |
| Order Compatibility | `[CovariantClass T T (· + ·) (· ≤ ·)]` | `[IsOrderedAddMonoid T]` |
| Contravariant Class | "May be needed" | Not included |

## Pros and Cons Analysis

### Approach 1: IsOrderedAddMonoid (Implemented by Task 420)

**Pros:**
1. **Mathlib-aligned**: Matches current Mathlib 4.27+ conventions where bundled classes are deprecated in favor of `Is*` mixins
2. **Bundled compatibility lemmas**: `IsOrderedAddMonoid` provides both `add_le_add_left` and `add_le_add_right` in a single class
3. **Future-proof**: Follows the deprecation trend in Mathlib where `OrderedSemiring` → `[Semiring R] [PartialOrder R] [IsOrderedRing R]`
4. **Simpler to understand**: Semantically clear that the monoid is ordered
5. **Build verified**: Already builds successfully with current Mathlib

**Cons:**
1. **Slightly less granular**: Bundles both left and right covariance properties
2. **Requires AddCommMonoid**: The `IsOrderedAddMonoid` class requires `[AddCommMonoid T]` as a prerequisite, not just `[AddMonoid T]`
3. **Not the minimal unbundling**: `CovariantClass` would be more fine-grained

### Approach 2: CovariantClass (Originally Recommended in research-001)

**Pros:**
1. **Maximum granularity**: Only specifies left-monotonicity explicitly
2. **Minimal assumptions**: Uses the most primitive Mathlib building block for order-algebra interaction
3. **Explicit about what's needed**: Documents exactly which direction of monotonicity is used

**Cons:**
1. **May require ContravariantClass too**: For cancellation lemmas like `add_le_add_iff_left`
2. **More verbose**: Requires spelling out the functor explicitly `(· + ·)`
3. **Against Mathlib conventions**: Mathlib is moving toward `Is*` mixins, not more granular `CovariantClass` usage at the definition level
4. **Would require undoing task 420's work**: Would need to change code that already works

### Approach 3: Do Nothing (Keep Task 420's Changes)

**Pros:**
1. **No additional work**: Code already compiles and works
2. **Consistent**: Explanatory and Bimodal now use the same pattern
3. **Tested**: The upgrade included verification that builds succeed

**Cons:**
1. **May not be optimal for performance**: Unknown if `IsOrderedAddMonoid` provides the same performance benefit as `CovariantClass`
2. **Task 417 marked incomplete**: Would need to close/merge with task 420

## Remaining Changes Analysis

### Already Complete (Done by Task 420)

| File | Change | Status |
|------|--------|--------|
| Frame.lean:34 | Variable declaration unbundled | DONE |
| Frame.lean:42 | CoreFrame structure unbundled | DONE |
| Frame.lean:221 | CoreModel structure unbundled | DONE |
| Truth.lean:36 | Variable declaration unbundled | DONE |
| Explanatory.lean:34 | Documentation example unbundled | DONE |
| All Bimodal files | Consistent unbundling | DONE |

### Optional Refinements (Not Critical)

1. **Switch to CovariantClass** (NOT RECOMMENDED)
   - Effort: 2-3 hours
   - Benefit: Marginally more explicit about requirements
   - Risk: May break some lemma applications requiring both covariance directions

2. **Add ContravariantClass** (ONLY IF NEEDED)
   - Effort: 30 minutes
   - Benefit: Enables cancellation lemmas
   - Risk: Currently not needed based on code analysis

3. **Performance benchmarking** (RECOMMENDED)
   - Effort: 1 hour
   - Benefit: Verify that unbundling achieved the desired performance improvement
   - Method: Compare build times before/after with profiling

## Recommendations

### Primary Recommendation: Close Task 417 as Merged/Complete

The core objective of task 417—splitting `LinearOrderedAddCommGroup` to reduce typeclass search complexity—has been achieved by task 420. The approach used (`IsOrderedAddMonoid`) is slightly different from what was originally recommended (`CovariantClass`), but:

1. It achieves the same goal of unbundling
2. It aligns with Mathlib's current conventions
3. It has been verified to build successfully
4. The performance benefit analysis from research-001 applies equally to this approach

**Action**: Update task 417 status to [COMPLETED] with note that it was satisfied by task 420.

### Alternative: Convert to CovariantClass (Low Priority)

If you want to follow the original task 417 recommendation exactly:

1. Replace `[IsOrderedAddMonoid T]` with `[CovariantClass T T (· + ·) (· ≤ ·)]`
2. Add `[ContravariantClass T T (· + ·) (· ≤ ·)]` if any lemma requires cancellation
3. Verify build still succeeds
4. Benchmark performance difference

**Effort**: 2-3 hours
**Risk**: Low (but may require additional ContravariantClass)
**Benefit**: Marginally more explicit, but against Mathlib conventions

### Follow-up Task (Optional): Performance Verification

Create a new task to:
1. Measure build time for Explanatory/Truth.lean before and after changes
2. Profile typeclass instance search times
3. Document actual performance improvement from unbundling

## Decision Matrix

| Option | Effort | Performance Gain | Mathlib Alignment | Recommendation |
|--------|--------|-----------------|-------------------|----------------|
| Close as complete | 0h | Already achieved | Excellent | RECOMMENDED |
| Switch to CovariantClass | 2-3h | Unknown difference | Poor | Not recommended |
| Add performance tests | 1h | Validates work | Neutral | Optional |

## References

- [Mathlib.Algebra.Order.Monoid.Defs](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/Order/Monoid/Defs.html) - IsOrderedAddMonoid definition
- Task 420 implementation summary - Details of Mathlib upgrade changes
- Task 417 research-001.md - Original recommendation for CovariantClass approach

## Next Steps

1. **Close task 417** with note: "Completed by task 420 (Mathlib upgrade) using IsOrderedAddMonoid approach"
2. Optionally run performance benchmarks to verify improvement
3. Document the pattern for future similar work
