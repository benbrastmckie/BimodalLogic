# Research Report: DeductionTheorem.lean Build Warnings

**Task**: 785
**Date**: 2026-01-31
**File**: `Theories/Bimodal/Metalogic/DeductionTheorem.lean`

## Summary

There are 8 build warnings in DeductionTheorem.lean:
- 6 unused `simp [List.filter]` arguments (lines 101, 129, 138, 225, 268, 275)
- 2 ineffective `simp_wf` tactics (lines 297, 439)

## Analysis

### Issue 1: Unused `simp [List.filter]` Arguments

**Root Cause**: The file defines a local `removeAll` function:

```lean
private def removeAll {α : Type _} [DecidableEq α] (l : List α) (a : α) : List α :=
  l.filter (· ≠ a)
```

The code uses `simp [List.filter]` to reason about membership in `removeAll` results. However, `simp` already knows the standard `List.mem_filter` lemma from `Init.Data.List.Lemmas`:

```lean
List.mem_filter : x ∈ List.filter p as ↔ x ∈ as ∧ p x = true
```

After `unfold removeAll`, the goal contains `x ∈ List.filter (· ≠ a) l`, and `simp` can simplify this directly using `List.mem_filter` without needing an explicit `List.filter` simp argument.

**Affected Lines**:

| Line | Context | Current | Fix |
|------|---------|---------|-----|
| 101 | `removeAll_subset` proof | `simp [List.filter] at hx` | `simp at hx` |
| 129 | `cons_removeAll_perm` proof (forward direction) | `simp [List.filter] at h_in` | `simp at h_in` |
| 138 | `cons_removeAll_perm` proof (backward direction) | `simp [List.filter]` | `simp` |
| 225 | `deduction_with_mem` assumption case | `simp [List.filter]` | `simp` |
| 268 | `deduction_with_mem` weakening case (A ∈ Γ'') | `simp [List.filter] at hx ⊢` | `simp at hx ⊢` |
| 275 | `deduction_with_mem` weakening case (A ∉ Γ'') | `simp [List.filter]` | `simp` |

### Issue 2: Ineffective `simp_wf` Tactics

**Root Cause**: The `simp_wf` tactic is designed to help with well-foundedness proofs by simplifying measure-related goals. In both `deduction_with_mem` (line 297) and `deduction_theorem` (line 439), the `decreasing_by` block uses `simp_wf` followed by bullet points with specific `exact` tactics.

The `simp_wf` tactic does nothing because:
1. The well-foundedness measure (`h.height`) is already in a simplified form
2. The goals immediately after `termination_by h.height` are already in the form `goal.height < h.height`
3. The subsequent `exact` tactics provide direct proofs without needing simplification

**Affected Lines**:

| Line | Function | Fix |
|------|----------|-----|
| 297 | `deduction_with_mem` | Remove `simp_wf` line |
| 439 | `deduction_theorem` | Remove `simp_wf` line |

## Recommended Fixes

### Fix Pattern A: Remove `List.filter` from simp

For each of the 6 locations with unused `simp [List.filter]`:

**Before**:
```lean
simp [List.filter]
```

**After**:
```lean
simp
```

### Fix Pattern B: Remove `simp_wf`

For each of the 2 `decreasing_by` blocks:

**Before**:
```lean
decreasing_by
  simp_wf
  · exact ...
  · exact ...
```

**After**:
```lean
decreasing_by
  · exact ...
  · exact ...
```

## Verification Strategy

1. Apply each fix individually and run `lake build Bimodal.Metalogic.DeductionTheorem`
2. Verify no new errors or warnings appear
3. Ensure all proofs still compile successfully

## Risk Assessment

**Risk Level**: Low

These are purely cosmetic changes that remove unused code. The proofs remain identical in structure and meaning. The changes:
- Do not alter proof semantics
- Do not change termination arguments
- Do not affect module API

## Line Number Reconciliation

Note: The task description listed lines 106, 134, 143, 228, 271, 278, 300, 442. The actual warning lines are 101, 129, 138, 225, 268, 275, 297, 439. This discrepancy is likely due to line numbers shifting during earlier edits or different file versions.
