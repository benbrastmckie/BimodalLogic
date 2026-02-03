# Research Report: Linter Warnings in Metalogic Files

**Task**: 839 - Clean linter warnings in Metalogic files
**Date**: 2026-02-03
**Status**: Researched

## Executive Summary

Analysis of linter warnings in the three target files reveals:
- **SoundnessLemmas.lean**: 16 warnings (6 'Try this' suggestions, 10 unused simp args)
- **TaskFrame.lean**: 1 warning (duplicate namespace)
- **WorldHistory.lean**: 2 warnings (unused section variables)

Total: **19 linter warnings** across the three target files.

## File Analysis

### 1. SoundnessLemmas.lean (16 warnings)

**Location**: `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

#### 1.1 'Try this' Suggestions (6 warnings)

The linter suggests more explicit `intro` patterns:

| Line | Current | Suggested |
|------|---------|-----------|
| 221 | `intro h_box_swap_φ` then later `intro σ` | `intro h_box_swap_φ σ ρ` |
| 239 | `intro h_swap_φ` then later `intro σ` | `intro h_swap_φ σ h_all_not` |
| 287 | Multiple separate intros | `intro h_swap_φ s h_s_le_t h_all_not_future` |
| 336 | Separate intros in sub-proof | `intro h_fut_all h_conj` (2 warnings at same line for different branches) |
| 336 | Separate intros in sub-proof | `intro h_now h_past` |
| 350 | Separate intros in sub-proof | `intro h_fut_all h_conj` |

**Fix Pattern**: Combine consecutive `intro` tactics into a single `intro` with multiple binders.

#### 1.2 Unused Simp Arguments (10 warnings)

The `truth_at` lemma appears as an unused simp argument in multiple locations:

| Line | Unused Argument | Context |
|------|-----------------|---------|
| 238 | `truth_at` | `simp only [Formula.swap_past_future, Formula.diamond, truth_at]` |
| 286 | `Formula.sometime_future` | `simp only [Formula.swap_past_future, Formula.sometime_past, Formula.sometime_future, truth_at]` |
| 286 | `truth_at` | Same line, second unused arg |
| 432 | `truth_at` | `simp only [Formula.swap_temporal, truth_at] at h_imp h_phi` |
| 522 | `truth_at` | `simp only [Formula.swap_past_future, Formula.diamond, Formula.neg, truth_at]` |
| 647 | `truth_at` | `simp only [truth_at] at h_neg_at_tau` |
| 694 | `truth_at` | `simp only [truth_at] at h_imp_at_sigma` |
| 705 | `truth_at` | `simp only [truth_at] at h_imp_at_s` |
| 726 | `truth_at` | `simp only [truth_at] at h_neg_at_t` |

**Root Cause**: The `truth_at` function is not defined as a `@[simp]` lemma, so including it in `simp only` calls does nothing. The code likely evolved from a version where `truth_at` was a simp lemma.

**Fix Pattern**: Remove `truth_at` from simp argument lists. If simplification is needed, use `unfold truth_at` or `simp only [truth_at]` where `truth_at` has actual simp lemmas.

### 2. TaskFrame.lean (1 warning)

**Location**: `Theories/Bimodal/Semantics/TaskFrame.lean`

#### 2.1 Duplicate Namespace (Line 193)

**Warning**: The namespace 'FiniteTaskFrame' is duplicated in the declaration `Bimodal.Semantics.FiniteTaskFrame.FiniteTaskFrame.toTaskFrame`

**Current Code** (lines 179-195):
```lean
namespace FiniteTaskFrame

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

-- ... (some definitions) ...

/--
A finite task frame provides access to its underlying frame.
-/
def FiniteTaskFrame.toTaskFrame (F : FiniteTaskFrame D) : TaskFrame D := F.toTaskFrame

end FiniteTaskFrame
```

**Problem**: Inside `namespace FiniteTaskFrame`, the definition `def FiniteTaskFrame.toTaskFrame` creates a doubly-qualified name `FiniteTaskFrame.FiniteTaskFrame.toTaskFrame`.

**Fix**: Remove the explicit namespace prefix since we're already inside the namespace:
```lean
def toTaskFrame (F : FiniteTaskFrame D) : TaskFrame D := F.toTaskFrame
```

This will create the correct fully-qualified name `Bimodal.Semantics.FiniteTaskFrame.toTaskFrame`.

### 3. WorldHistory.lean (2 warnings)

**Location**: `Theories/Bimodal/Semantics/WorldHistory.lean`

#### 3.1 Unused Section Variables (Lines 397, 403)

**Context**: The file has section variables declared at line 101:
```lean
variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] {F : TaskFrame D}
```

**Affected Theorems**:

1. **Line 397 - `neg_neg_eq`**:
   ```lean
   theorem neg_neg_eq (t : D) : -(-t) = t := by simp
   ```
   - Uses only `AddGroup D` (for negation)
   - Does NOT need `[LinearOrder D]` or `[IsOrderedAddMonoid D]`

2. **Line 403 - `neg_injective`**:
   ```lean
   theorem neg_injective (s t : D) : -s = -t ↔ s = t := by ...
   ```
   - Uses only `AddGroup D` (for negation)
   - Does NOT need `[LinearOrder D]` or `[IsOrderedAddMonoid D]`

**Fix Pattern**: Add `omit` clause before each theorem:
```lean
omit [LinearOrder D] [IsOrderedAddMonoid D] in
theorem neg_neg_eq (t : D) : -(-t) = t := by simp

omit [LinearOrder D] [IsOrderedAddMonoid D] in
theorem neg_injective (s t : D) : -s = -t ↔ s = t := by ...
```

Alternatively, move these theorems outside the section or to a location with fewer type class constraints.

## Implementation Recommendations

### Priority Order

1. **TaskFrame.lean** (1 fix) - Simplest, just remove namespace prefix
2. **WorldHistory.lean** (2 fixes) - Add `omit` clauses
3. **SoundnessLemmas.lean** (16 fixes) - Most numerous but mechanical

### Estimated Effort

- **Low complexity**: All fixes are mechanical refactorings
- **No semantic changes**: The fixes only change syntax, not proof logic
- **No test impact**: Linter fixes don't affect correctness

### Implementation Notes

1. **For 'Try this' suggestions**: Accept the linter's suggested `intro` pattern directly
2. **For unused simp args**: Simply remove the unused arguments from the list
3. **For duplicate namespace**: Remove the redundant prefix
4. **For unused section vars**: Add `omit [...]` clause before the theorem

## Verification

After implementation, run:
```bash
lake build 2>&1 | grep -c "warning:"
```
Expected: Warning count should decrease by 19 (for the three target files).

## Appendix: Full Warning List

### SoundnessLemmas.lean Warnings
```
Line 221:2: Try this: intro h_box_swap_φ σ ρ
Line 238:56: This simp argument is unused: truth_at
Line 239:2: Try this: intro h_swap_φ σ h_all_not
Line 286:62: This simp argument is unused: Formula.sometime_future
Line 286:87: This simp argument is unused: truth_at
Line 287:2: Try this: intro h_swap_φ s h_s_le_t h_all_not_future
Line 336:4: Try this: intro h_fut_all h_conj
Line 336:4: Try this: intro h_now h_past
Line 350:4: Try this: intro h_fut_all h_conj
Line 432:36: This simp argument is unused: truth_at
Line 522:71: This simp argument is unused: truth_at
Line 647:13: This simp argument is unused: truth_at
Line 694:13: This simp argument is unused: truth_at
Line 705:13: This simp argument is unused: truth_at
Line 726:13: This simp argument is unused: truth_at
```

### TaskFrame.lean Warnings
```
Line 193:4: The namespace 'FiniteTaskFrame' is duplicated
```

### WorldHistory.lean Warnings
```
Line 397:0: automatically included section variable(s) unused in theorem `neg_neg_eq`: [LinearOrder D] [IsOrderedAddMonoid D]
Line 403:0: automatically included section variable(s) unused in theorem `neg_injective`: [LinearOrder D] [IsOrderedAddMonoid D]
```
