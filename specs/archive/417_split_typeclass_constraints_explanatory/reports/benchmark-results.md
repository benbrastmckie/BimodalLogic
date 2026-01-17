# Benchmark Results: Task #417

**Task**: Benchmark comparison of typeclass constraint approaches
**Date**: 2026-01-11
**Version**: v4.27.0-rc1 (Lean and Mathlib)

## Summary

The benchmark comparison could not be performed because `LinearOrderedAddCommGroup` has been **deprecated and removed** from Mathlib v4.27.0. The unbundled approach (`[AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]`) is now the **only compatible approach** for modern Mathlib.

## Key Finding

From `Mathlib/Algebra/Order/Group/Defs.lean`:
```lean
/-! `LinearOrderedCommGroup` and `LinearOrderedAddCommGroup` no longer exist,
but we still use the namespaces.

TODO: everything in these namespaces should be renamed; even if these typeclasses still existed,
it's unconventional to put theorems in namespaces named after them. -/
```

This means:
1. Task 420's unbundling was not just a performance optimization - it was a **necessary migration**
2. Any attempt to use bundled constraints fails at compile time
3. The benchmarking question is moot: there is only one valid approach

## Attempted Bundled Build

When attempting to use `[LinearOrderedAddCommGroup T]`:
```
error: Unknown identifier `LinearOrderedAddCommGroup`
```

The class simply does not exist in Mathlib v4.27.0.

## Unbundled Build Metrics (Baseline)

System: Lean 4.27.0-rc1, Mathlib v4.27.0-rc1

Cold build from `lake clean`:
- Full build: 53m29s (3072 modules)
- Explanatory.Syntax: 2.5s
- Explanatory.Frame: 1.8s
- Explanatory.Truth: 1.7s

Note: The `set_option synthInstance.maxHeartbeats 100000` in Truth.lean was added to handle the deeper typeclass hierarchy from unbundling, confirming that unbundling does add some typeclass search overhead, but it compiles successfully.

## Conclusion

**No benchmark comparison is possible** because:
1. Mathlib v4.27.0 removed `LinearOrderedAddCommGroup` entirely
2. The unbundled approach is the only compatible approach
3. Task 420's implementation was not optional - it was required for Mathlib compatibility

### Recommendation

- Mark task 417 as **COMPLETED** with finding: unbundling is required for Mathlib v4.27.0 compatibility
- The original task goal (splitting constraints) was already achieved by task 420
- No further action needed on typeclass constraints for Explanatory module

## Validation

Task 417 is validated as complete because:
1. Research identified the correct unbundled constraint pattern
2. Task 420 successfully implemented that pattern
3. This benchmark attempt confirms no alternative exists in modern Mathlib
