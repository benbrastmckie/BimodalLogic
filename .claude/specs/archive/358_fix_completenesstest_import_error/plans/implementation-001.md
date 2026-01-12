# Implementation Plan: Task #358

**Task**: Fix CompletenessTest.lean import error
**Version**: 001
**Created**: 2026-01-10
**Language**: lean

## Overview

Move import statements to the beginning of `BimodalTest/Metalogic/CompletenessTest.lean`. Lean 4 requires imports before any other content, including module docstrings. Currently the file has a 24-line docstring before imports, causing a compiler error.

## Phases

### Phase 1: Fix Import Placement

**Estimated effort**: 5 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Move import statements to the beginning of the file
2. Preserve the module docstring after imports
3. Verify file compiles without errors

**Files to modify**:
- `BimodalTest/Metalogic/CompletenessTest.lean` - Reorder imports and docstring

**Steps**:
1. Read current file content
2. Move lines 26-27 (imports) to lines 1-2
3. Shift the module docstring (lines 1-24) to after imports
4. Verify file compiles with `lean_diagnostic_messages`

**Verification**:
- No compiler errors on `BimodalTest/Metalogic/CompletenessTest.lean`
- Module docstring content preserved
- File structure follows Lean 4 conventions

## Dependencies

- None

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| None significant | - | - | Simple file reorder |

## Success Criteria

- [ ] Import statements at beginning of file
- [ ] No "invalid import" compiler error
- [ ] Module docstring preserved after imports
- [ ] File builds successfully

## Rollback Plan

Git revert if needed - single file change is easily reversible.
