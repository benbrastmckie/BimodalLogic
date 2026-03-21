# Research Report: Task #416

**Task**: Quick performance fixes for Explanatory/Truth.lean
**Date**: 2026-01-11
**Focus**: Validate proposed quick fixes and determine implementation approach

## Summary

Research validates all four proposed quick fixes from the parent task 400's research. The namespace error in Syntax.lean:34 has already been fixed (`open Logos.Foundation` works correctly via re-export through `Logos.SubTheories.Foundation`). The `@[irreducible]` attribute is the key optimization since Lean 4.9+ makes well-founded recursive functions irreducible by default for performance reasons - this project's `truthAt` predates that default and should be explicitly marked. The `synthInstance.maxHeartbeats` increase and `lake clean` are standard remediation steps.

## Findings

### 1. Namespace Error Status - ALREADY FIXED

**Location**: `Theories/Logos/SubTheories/Explanatory/Syntax.lean:34`

The research report for task 400 mentioned changing `Logos.Foundation` to `Logos.SubTheories.Foundation`. However, inspection shows:

- Current code uses `open Logos.Foundation` (line 34)
- This works correctly because `Logos.SubTheories.Foundation.lean` re-exports the Foundation namespace
- Diagnostic check returns no errors for Syntax.lean

**Action Required**: None - this issue is already resolved.

### 2. `@[irreducible]` for `truthAt` - RECOMMENDED

**Location**: `Theories/Logos/SubTheories/Explanatory/Truth.lean:99`

**Current State**:
- `truthAt` is defined without any reducibility attribute
- The function uses recursive definition with 17 pattern match cases
- Hover info times out after 30 seconds, demonstrating severe performance issues

**Why This Helps**:
Per [Lean 4.9.0 release notes](https://lean-lang.org/blog/2024-7-1-lean-490/):
> Now functions defined by well-founded recursion are marked with `@[irreducible]` by default. Even when definitional equalities exist, these functions are frequently slow to compute with because they require reducing proof terms that are often very large.

Since this project uses Mathlib v4.14.0 (compatible with Lean 4.x where the default changed), the `truthAt` function may have been defined before this default applied, or may be using structural/match recursion that doesn't get the automatic treatment.

**Trade-offs**:
- Proofs using `rfl` on `truthAt` will need explicit `unfold truthAt` or `simp only [truthAt]`
- This is acceptable since `truthAt` is primarily used for semantic evaluation, not definitional equality proofs

### 3. `synthInstance.maxHeartbeats` Increase - RECOMMENDED

**Current Settings**: None explicitly set in project files.

**Default Values** (per [Lean documentation](https://lean-lang.org/theorem_proving_in_lean4/Type-Classes/)):
- `synthInstance.maxHeartbeats`: 200,000 (default)
- `maxHeartbeats`: 50,000 (default)

**Problem Analysis**:
Per [Lean 4 Issue #2055](https://github.com/leanprover/lean4/issues/2055), deep typeclass hierarchies like `LinearOrderedAddCommGroup T` cause exponential instance synthesis attempts:
> Lean's type class inference system sometimes tries and fails to solve the same problem 384 or more times consecutively in the middle of a proof.

The `LinearOrderedAddCommGroup T` constraint in Truth.lean triggers:
- Instance search through diamond inheritance patterns
- Multiple failed synthesis attempts for `LeftCancelMonoid`, `RightCancelMonoid`, etc.

**Recommended Value**:
```lean
set_option synthInstance.maxHeartbeats 100000
```

This balances timeout prevention with avoiding infinite loops on genuinely impossible synthesis problems.

### 4. `lake clean` - RECOMMENDED AS FIRST STEP

**Why This Helps**:
- Clears stale `.olean` files that may have inconsistent elaboration data
- Forces re-elaboration with current compiler settings
- Standard troubleshooting step before applying code changes

**Execution Order**: Should be run BEFORE applying code changes, then again after to get fresh build artifacts.

### 5. Additional Findings: `verifies`/`falsifies` Mutual Block

**Location**: `Theories/Logos/SubTheories/Foundation/Semantics.lean:47-139`

While not in scope for this task (assigned to task 419), the mutual recursion in `verifies`/`falsifies` also contributes to build slowness. Both functions should eventually be marked `@[irreducible]` or refactored.

### 6. Mathlib Version Impact

**Current**: v4.14.0 (June 2024 release)
**Latest Available**: v4.22+ (includes significant instance caching improvements)

Task 420 covers the Mathlib upgrade. For task 416's quick fixes, the current version is sufficient.

## Recommendations

### Implementation Order

1. **Run `lake clean`** - Clear stale build artifacts
2. **Add `@[irreducible]` to `truthAt`** - Primary performance fix
3. **Add `set_option synthInstance.maxHeartbeats 100000`** - Prevent synthesis timeouts
4. **Rebuild and test** - Verify performance improvement
5. **Run `lake clean` again** - Ensure fresh build with new settings

### Code Changes

**File: `Theories/Logos/SubTheories/Explanatory/Truth.lean`**

Add before line 99:
```lean
set_option synthInstance.maxHeartbeats 100000 in
@[irreducible]
def truthAt (M : CoreModel T) ...
```

Or at file scope after line 36:
```lean
set_option synthInstance.maxHeartbeats 100000
```

Then add `@[irreducible]` at line 99.

### Verification Steps

1. Check `lean_diagnostic_messages` returns empty after changes
2. Verify `lean_hover_info` on `truthAt` completes in <5 seconds
3. Run full `lake build` to confirm no regressions

## References

- [Lean 4.9.0 Release - Irreducible by Default](https://lean-lang.org/blog/2024-7-1-lean-490/)
- [Typeclass Inference Performance (Issue #2055)](https://github.com/leanprover/lean4/issues/2055)
- [Instance Synthesis Documentation](https://lean-lang.org/doc/reference/latest/Type-Classes/Instance-Synthesis/)
- [Recursive Definitions in Lean](https://lean-lang.org/blog/2024-1-11-recursive-definitions-in-lean/)
- [Parent Task 400 Research](specs/400_investigate_explanatory_truth_build_performance/reports/research-001.md)

## Next Steps

1. Proceed to `/plan 416` to create implementation plan
2. Implementation should be straightforward (2-3 edits)
3. Consider applying similar fixes to `verifies`/`falsifies` in future task
