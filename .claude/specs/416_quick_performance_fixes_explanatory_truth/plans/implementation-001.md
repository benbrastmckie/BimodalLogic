# Implementation Plan: Task #416

**Task**: Quick performance fixes for Explanatory/Truth.lean
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Apply three quick performance fixes to improve build performance for `Explanatory/Truth.lean`:
1. Run `lake clean` to clear stale build artifacts
2. Add `@[irreducible]` attribute to `truthAt` function
3. Add `set_option synthInstance.maxHeartbeats 100000` for typeclass synthesis

The namespace error fix mentioned in the original task description is no longer needed (already resolved).

## Phases

### Phase 1: Clean Build Environment

**Estimated effort**: 5 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Clear stale build artifacts that may contain inconsistent elaboration data
2. Prepare for fresh build with new settings

**Steps**:
1. Run `lake clean` from project root
2. Verify `.lake/build` directory is cleared

**Verification**:
- `.lake/build` directory should be empty or removed
- No cached `.olean` files remain

---

### Phase 2: Add Performance Attributes

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add `@[irreducible]` attribute to prevent expensive definitional unfolding
2. Add `synthInstance.maxHeartbeats` option to prevent typeclass synthesis timeouts

**Files to modify**:
- `Theories/Logos/SubTheories/Explanatory/Truth.lean` - Add attributes and options

**Steps**:
1. Open `Truth.lean`
2. Add `set_option synthInstance.maxHeartbeats 100000` after line 36 (after variable declaration)
3. Add `@[irreducible]` attribute immediately before `def truthAt` at line 99

**Code Changes**:

After line 36 (`variable {T : Type*} [LinearOrderedAddCommGroup T]`), add:
```lean
-- Performance: Increase heartbeats for deep typeclass hierarchy (LinearOrderedAddCommGroup)
set_option synthInstance.maxHeartbeats 100000
```

Before line 99 (`def truthAt`), add:
```lean
/--
Truth evaluation for Explanatory Extension formulas.
...
-/
@[irreducible]
def truthAt ...
```

**Verification**:
- File parses without syntax errors
- `lean_diagnostic_messages` returns empty for Truth.lean

---

### Phase 3: Rebuild and Validate

**Estimated effort**: 30-60 minutes (build time)
**Status**: [NOT STARTED]

**Objectives**:
1. Rebuild the project with new settings
2. Verify performance improvement
3. Check for any regressions

**Steps**:
1. Run `lake build Logos.SubTheories.Explanatory.Truth` to build the specific module
2. Check `lean_diagnostic_messages` for any errors
3. Test `lean_hover_info` on `truthAt` to verify it completes in reasonable time (<10 seconds)
4. Run full `lake build` to check for downstream regressions

**Verification**:
- `lake build` completes without errors
- `lean_hover_info` on `truthAt` returns within 10 seconds (previously timed out at 30s)
- No new compiler warnings or errors introduced

---

## Dependencies

- None - this task is independent and can proceed immediately

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `@[irreducible]` breaks existing proofs | Medium | Low | Search for uses of `truthAt` in proofs; add `unfold truthAt` where needed |
| Build still slow after changes | Low | Low | Continue with tasks 417-420 for deeper optimizations |
| synthInstance.maxHeartbeats too low | Low | Low | Can increase to 150000 or 200000 if needed |

## Success Criteria

- [ ] `lake clean` completed successfully
- [ ] `@[irreducible]` attribute added to `truthAt`
- [ ] `synthInstance.maxHeartbeats 100000` option added
- [ ] `lean_diagnostic_messages` returns no errors for Truth.lean
- [ ] `lean_hover_info` on `truthAt` completes in <10 seconds
- [ ] Full `lake build` passes without regressions

## Rollback Plan

If implementation fails:
1. Revert changes to `Truth.lean` using `git checkout -- Theories/Logos/SubTheories/Explanatory/Truth.lean`
2. Run `lake clean && lake build` to restore previous state
3. Document failure mode for further investigation
