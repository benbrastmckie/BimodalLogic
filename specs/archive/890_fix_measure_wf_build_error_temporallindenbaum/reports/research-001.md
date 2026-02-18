# Research Report: Task #890

**Task**: Fix measure_wf build error in TemporalLindenbaum.lean
**Date**: 2026-02-17
**Focus**: Investigate measure_wf build error at lines 220 and 263

## Summary

The `measure_wf` identifier used in `TemporalLindenbaum.lean` does not exist. It was introduced in commit `84a54862` (task 843) but was never defined locally and does not exist in Mathlib. The correct identifier is `measure` from Lean 4's `Init.WF` module, which is auto-imported and provides the same functionality.

## Findings

### 1. Error Location and Context

The error occurs at two locations in `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`:

**Line 220** (in `forward_witness_in_chain`):
```lean
induction φ using (measure_wf Formula.complexity).wf.induction with
| ind χ ih =>
```

**Line 263** (in `backward_witness_in_chain`):
```lean
induction φ using (measure_wf Formula.complexity).wf.induction with
| ind χ ih =>
```

Both lemmas use well-founded induction on `Formula.complexity : Formula → Nat` to prove that temporal witnesses are contained in witness chains.

### 2. Root Cause Analysis

The file was created in commit `84a54862` (task 843) and the `measure_wf` identifier was used without ever being defined. This appears to be a typo or confusion with the actual Lean 4 function.

**Search Results**:
- `lean_local_search("measure_wf")` → no results in codebase or Mathlib
- `lean_local_search("measure")` → found `measure` in `/home/benjamin/.elan/toolchains/leanprover--lean4---v4.27.0-rc1/src/lean/Init/WF.lean`

### 3. The Correct Identifier

Lean 4's `Init.WF` module defines `measure`:

```lean
@[reducible] def measure.{u} : {α : Sort u} → (α → Nat) → WellFoundedRelation α :=
fun {α} f => invImage f Nat.lt_wfRel
```

**Type**: `{α : Sort u_1} → (α → Nat) → WellFoundedRelation α`

This is exactly what the code expects. The expression `(measure Formula.complexity).wf` yields a `WellFounded` instance, and `.induction` provides the well-founded induction principle.

### 4. Alternative Name Change Required

There is a secondary issue: the alternative name in the `with` clause must also change.

**Current (broken)**:
```lean
induction φ using (measure_wf Formula.complexity).wf.induction with
| ind χ ih =>
```

**Correct**:
```lean
induction φ using (measure Formula.complexity).wf.induction with
| h χ ih =>
```

The `WellFounded.induction` principle expects the alternative name `h`, not `ind`. This was verified via `lean_run_code`:

```lean
-- With `ind`: "Invalid alternative name `ind`: Expected `h`"
-- With `h`: compiles successfully
```

## Recommendations

### Primary Fix

Replace both occurrences (lines 220 and 263):

**Before**:
```lean
induction φ using (measure_wf Formula.complexity).wf.induction with
| ind χ ih =>
```

**After**:
```lean
induction φ using (measure Formula.complexity).wf.induction with
| h χ ih =>
```

### Implementation Notes

1. No new imports are required - `measure` is in `Init.WF` which is auto-imported
2. The rest of the proof body should work unchanged since `χ` and `ih` bindings have the same types
3. Both fixes are syntactic only - no proof logic changes needed

### Verification Steps

After making the changes:
1. Run `lake build Bimodal.Metalogic.Bundle.TemporalLindenbaum` to verify the specific file
2. Run `lake build` to verify no downstream breakage

## References

- `Init.WF` source: `~/.elan/toolchains/leanprover--lean4---v4.27.0-rc1/src/lean/Init/WF.lean`
- Loogle search for `measure`: confirms type `{α : Sort u_1} → (α → Nat) → WellFoundedRelation α`
- Task 843 commit `84a54862`: introduced the file with the typo

## Next Steps

1. Implement the fix (estimated: 5 minutes)
2. Verify with `lake build`
3. Once fixed, task 888 can proceed (was blocked by this pre-existing error)
