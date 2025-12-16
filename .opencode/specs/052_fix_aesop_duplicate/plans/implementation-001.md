# Implementation Plan: Fix AesopRules.lean Duplicate Declaration

**Project**: 052_fix_aesop_duplicate
**Task**: #52
**Complexity**: Simple
**Estimated Effort**: 30 minutes
**Priority**: Medium (blocks full build)

## Task Description

`Logos/Core/Automation/AesopRules.lean` has a duplicate declaration error for `apply_modal_k` that blocks the full project build.

**Error**:
```
error: 'Logos.Core.Automation.apply_modal_k' has already been declared
```

## Root Cause Analysis

After reading the file, the issue is clear:
- **Line 220-222**: First declaration of `apply_modal_k`
- **Line 230-232**: Duplicate declaration of `apply_modal_k` (identical)

Both declarations are:
```lean
@[aesop safe apply]
theorem apply_modal_k {Γ : Context} {φ : Formula} :
    Derivable Γ φ → Derivable (Context.map Formula.box Γ) (Formula.box φ) :=
  generalized_modal_k Γ φ
```

This is a simple copy-paste error. The second declaration should be removed.

## Changes Required

1. **Remove duplicate declaration** (lines 230-232)
2. **Verify no other duplicates exist** in the file
3. **Ensure Aesop rule registration remains correct**

## Files Affected

- `Logos/Core/Automation/AesopRules.lean`: Remove lines 230-232

## Implementation Steps

### Step 1: Remove Duplicate Declaration

Remove the second `apply_modal_k` declaration at lines 230-232:

```lean
/--
Generalized Modal K rule as safe apply rule.

To prove `□φ` from `□Γ`, if we can prove `φ` from `Γ`, then we're done.
-/
@[aesop safe apply]
theorem apply_modal_k {Γ : Context} {φ : Formula} :
    Derivable Γ φ → Derivable (Context.map Formula.box Γ) (Formula.box φ) :=
  generalized_modal_k Γ φ
```

**Action**: Delete lines 224-232 (includes docstring and declaration)

### Step 2: Verify File Structure

After removal, verify:
- First `apply_modal_k` at lines 220-222 remains intact
- `apply_temporal_k` at lines 240-242 follows correctly
- No other duplicate declarations exist
- File compiles without errors

### Step 3: Test Compilation

Run LEAN 4 compilation to verify:
```bash
lake build Logos.Core.Automation.AesopRules
```

Expected: No duplicate declaration errors

## Verification Steps

- [x] Duplicate declaration identified (lines 230-232)
- [ ] Duplicate removed from file
- [ ] File compiles without errors
- [ ] No other duplicates in file
- [ ] Aesop rules still registered correctly

## Success Criteria

1. ✅ File compiles without duplicate declaration error
2. ✅ First `apply_modal_k` declaration remains (lines 220-222)
3. ✅ No other duplicate declarations exist
4. ✅ Aesop rule set remains functional

## Dependencies

None - this is a standalone fix.

## Impact

**Medium** - Blocks full project build but doesn't affect core functionality. Once fixed, full build can proceed.

## Notes

- This is a simple copy-paste error
- The duplicate is identical to the original
- No semantic changes needed, just removal
- Quick fix that unblocks build process
