# Implementation Plan: Remove Deprecated Aliases

**Task**: Remove Deprecated Aliases (Task #8)
**Date**: 2025-12-20
**Effort**: 1 hour
**Complexity**: Simple
**Type**: Code Cleanup

## Overview

Remove backward compatibility aliases that have been deprecated since 2025-12-09. These aliases were kept for migration but are no longer needed.

## Files to Modify

### 1. Logos/Core/Semantics/TaskFrame.lean
**Lines to Remove**: 148-157 (3 deprecated aliases)
- `trivialFrame` → deprecated alias for `trivial_frame`
- `identityFrame` → deprecated alias for `identity_frame`
- `natFrame` → deprecated alias for `nat_frame`

### 2. Logos/Core/Semantics/WorldHistory.lean
**Lines to Remove**: 211-215 (1 deprecated alias)
- `stateAt` → deprecated alias for `state_at`

### 3. Logos/Core/Semantics/TaskModel.lean
**Lines to Remove**: 75-85 (3 deprecated aliases)
- `allFalse` → deprecated alias for `all_false`
- `allTrue` → deprecated alias for `all_true`
- `fromList` → deprecated alias for `from_list`

## Implementation Steps

1. **Read each file** to understand current structure
2. **Remove deprecated alias blocks** (entire sections with `@[deprecated]` annotations)
3. **Preserve all other code** exactly as-is
4. **Write updated files** back to disk

## Verification Steps

1. Run `lake build` to ensure project compiles
2. Search codebase for any remaining references to old alias names
3. Confirm all 7 aliases have been removed

## Success Criteria

- ✅ All 7 deprecated aliases removed
- ✅ Full build successful (zero errors)
- ✅ No references to old alias names remain
- ✅ Code formatting and structure preserved

## Risk Assessment

**Risk Level**: Low
- Aliases are deprecated and marked for removal
- No current usage in codebase (verified in review)
- Breaking changes only affect external code using old names
- New snake_case names are the canonical versions

## Rollback Plan

If issues arise:
1. Restore files from git history
2. Investigate any unexpected dependencies
3. Add deprecation period extension if needed
