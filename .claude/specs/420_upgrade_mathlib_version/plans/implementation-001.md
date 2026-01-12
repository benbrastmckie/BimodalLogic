# Implementation Plan: Task #420

**Task**: Upgrade Mathlib version
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Most of the Mathlib upgrade work has already been completed. The toolchain has been updated to v4.27.0-rc1 and most breaking changes have been fixed. This plan covers the remaining work: fixing 2 build errors and verifying the full build.

### Already Completed (Pre-Plan)
- Toolchain updated to `leanprover/lean4:v4.27.0-rc1`
- Lakefile updated to require `mathlib @ "v4.27.0-rc1"`
- Dependencies fetched via `lake update -R`
- Mathlib cache downloaded via `lake exe cache get`
- NixOS nix-ld configuration added
- Most breaking changes fixed (LinearOrderedAddCommGroup, List lemmas, HashMap API)

## Phases

### Phase 1: Fix Remaining Build Errors

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Fix the `rfl` error in Perpetuity/Principles.lean
2. Verify WorldHistory.lean fix is correct
3. Ensure both files compile without errors

**Files to modify**:
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` - Remove unnecessary `rfl` on line 837
- `Theories/Bimodal/Semantics/WorldHistory.lean` - Verify existing fix (lines 243-244, 253)

**Steps**:
1. Read Principles.lean around line 837 to confirm the issue
2. Remove the `rfl` line since `simp only` now fully solves the goal
3. Check WorldHistory.lean lines 243-244, 253 for any remaining issues
4. Run `lake build Bimodal` to verify both files compile

**Verification**:
- `lake build Bimodal` completes without errors
- `lean_diagnostic_messages` shows no errors in affected files

---

### Phase 2: Full Build Verification

**Estimated effort**: 30 minutes
**Status**: [IN PROGRESS]

**Objectives**:
1. Run full project build
2. Verify all libraries compile (Logos, Bimodal, Tests)
3. Run tests to confirm no regressions

**Files to modify**:
- None expected (verification phase)

**Steps**:
1. Run `lake build` to build entire project
2. If errors occur, fix them iteratively
3. Run `lake build LogosTest` and `lake build BimodalTest`
4. Run test executable: `lake exe test`

**Verification**:
- `lake build` completes with exit code 0
- `lake exe test` passes all tests
- No deprecation warnings for project code (Mathlib warnings acceptable)

---

### Phase 3: System Configuration and Documentation

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Document NixOS nix-ld requirement
2. Update README or docs if needed
3. Clean up any temporary workarounds

**Files to modify**:
- None required (documentation optional)

**Steps**:
1. Verify nix-ld is enabled in system configuration
2. Test that elan-downloaded binaries work after nixos-rebuild
3. Optionally update project documentation with NixOS requirements

**Verification**:
- `lean --version` works after fresh nixos-rebuild
- `lake build` works in a fresh shell

---

## Dependencies

- NixOS nix-ld must be enabled (already configured, needs nixos-rebuild)
- Mathlib cache must be downloaded (already done)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Additional breaking changes found | Medium | Low | Fix iteratively during Phase 2 |
| LSP issues with new version | Low | Low | Restart LSP server, rebuild if needed |
| Test failures | Medium | Low | Investigate and fix or update tests |

## Success Criteria

- [ ] `lake build` completes without errors
- [ ] `lake exe test` passes all tests
- [ ] No project-owned code uses deprecated APIs
- [ ] lean-toolchain specifies v4.27.0-rc1
- [ ] lakefile.lean requires mathlib v4.27.0-rc1

## Rollback Plan

If upgrade fails:
1. `git checkout HEAD~1 -- lean-toolchain lakefile.lean lake-manifest.json`
2. `rm -rf .lake`
3. `lake update -R`
4. `lake exe cache get`
