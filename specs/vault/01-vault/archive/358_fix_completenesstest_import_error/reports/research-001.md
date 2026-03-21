# Research Report: Task #358

**Task**: Fix CompletenessTest.lean import error
**Date**: 2026-01-10
**Focus**: Lean 4 import placement requirements

## Summary

The `BimodalTest/Metalogic/CompletenessTest.lean` file has an invalid import placement error. In Lean 4, all `import` statements must appear at the very beginning of the file, before any module docstrings or comments. The current file has a 24-line module docstring (lines 1-24) before the imports (lines 26-27), which causes the compiler error.

## Findings

### Current File Structure

```
Lines 1-24:  Module docstring (/-! ... -/)
Line 25:     Empty line
Lines 26-27: Import statements
Line 28:     Empty line
Line 29+:    Namespace and code
```

### Error Details

```
Error: invalid 'import' command, it must be used in the beginning of the file
Location: Line 26, Column 1
```

### Lean 4 Import Rules

In Lean 4:
1. Import statements must be the FIRST non-whitespace content in a file
2. Module docstrings (`/-! ... -/`) must come AFTER imports
3. Regular comments (`-- ...` or `/- ... -/`) before imports are also not allowed

### Required Fix

Move the import statements to the very beginning of the file, then place the module docstring after them:

**Correct structure:**
```lean
import Bimodal.Metalogic.Completeness
import Bimodal.ProofSystem

/-!
# Tests for Completeness Theorems
...
-/

namespace BimodalTest.Metalogic
```

### Files to Modify

- `BimodalTest/Metalogic/CompletenessTest.lean` - Move imports to beginning

## Recommendations

1. **Simple fix**: Move lines 26-27 (import statements) to lines 1-2, shifting the docstring down
2. **Preserve docstring**: Keep the module docstring intact, just move it after imports
3. **Verify build**: After fixing, run `lake build BimodalTest.Metalogic.CompletenessTest` to confirm

## References

- Lean 4 documentation: Import statements must be first
- Error message: "invalid 'import' command, it must be used in the beginning of the file"

## Next Steps

1. Move import statements to beginning of file
2. Place module docstring after imports
3. Verify file compiles without errors
4. Commit fix
