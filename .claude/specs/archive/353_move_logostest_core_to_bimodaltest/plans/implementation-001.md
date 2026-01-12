# Implementation Plan: Task #353

**Task**: Move LogosTest/Core/ to BimodalTest/
**Version**: 001
**Created**: 2026-01-10
**Language**: lean

## Overview

Move the `LogosTest/Core/` directory to a new top-level `BimodalTest/` directory to mirror the Bimodal library structure established in task 352. This follows the Mathlib pattern (Mathlib/ + MathlibTest/) and involves:
1. Physical directory move using `git mv`
2. Namespace migration from `LogosTest.Core` to `BimodalTest`
3. Import updates in both internal files and parent LogosTest files
4. Lakefile configuration for the new library

## Phases

### Phase 1: Physical Move and Lakefile Update

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Move LogosTest/Core/ to BimodalTest/ preserving git history
2. Create BimodalTest.lean root entry point
3. Add lean_lib BimodalTest to lakefile

**Files to modify**:
- `LogosTest/Core/` → `BimodalTest/` (directory move)
- `lakefile.lean` - Add `lean_lib BimodalTest` target
- `BimodalTest.lean` (new) - Root entry point

**Steps**:
1. Execute `git mv LogosTest/Core BimodalTest` to move directory
2. Create `BimodalTest.lean` root entry point that imports all test modules
3. Add `lean_lib BimodalTest` target to `lakefile.lean` with standard options

**Verification**:
- `BimodalTest/` directory exists with all 30 Lean files
- `BimodalTest.lean` exists at project root
- `lakefile.lean` contains `lean_lib BimodalTest`

---

### Phase 2: Namespace Migration

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Change all `namespace LogosTest.Core.*` to `namespace BimodalTest.*`
2. Update all internal imports from `LogosTest.Core.*` to `BimodalTest.*`

**Files to modify**:
- All 30 files in `BimodalTest/` - namespace declarations and internal imports

**Steps**:
1. Find all namespace declarations: `grep -r "namespace LogosTest.Core" BimodalTest/`
2. Replace `namespace LogosTest.Core` with `namespace BimodalTest` in all files
3. Find all internal imports: `grep -r "import LogosTest.Core" BimodalTest/`
4. Replace `import LogosTest.Core` with `import BimodalTest` in all files
5. Also update `open LogosTest.Core` statements if any exist

**Specific namespace changes** (27 declarations):
- `LogosTest.Core.Syntax` → `BimodalTest.Syntax`
- `LogosTest.Core.ProofSystem` → `BimodalTest.ProofSystem`
- `LogosTest.Core.Semantics` → `BimodalTest.Semantics`
- `LogosTest.Core.Metalogic` → `BimodalTest.Metalogic`
- `LogosTest.Core.Theorems` → `BimodalTest.Theorems`
- `LogosTest.Core.Automation` → `BimodalTest.Automation`
- `LogosTest.Core.Integration` → `BimodalTest.Integration`
- `LogosTest.Core.Integration.Helpers` → `BimodalTest.Integration.Helpers`
- etc.

**Verification**:
- `grep -r "LogosTest.Core" BimodalTest/` returns no results
- All files use `namespace BimodalTest.*`

---

### Phase 3: External Reference Updates

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update parent LogosTest/*.lean files to import from BimodalTest
2. Update LogosTest/README.md with correct paths

**Files to modify**:
- `LogosTest/Syntax.lean` - Update imports
- `LogosTest/ProofSystem.lean` - Update imports
- `LogosTest/Semantics.lean` - Update imports
- `LogosTest/Metalogic.lean` - Update imports
- `LogosTest/Integration.lean` - Update imports
- `LogosTest/Theorems.lean` - Update imports
- `LogosTest/README.md` - Update path references

**Steps**:
1. Update `LogosTest/Syntax.lean`:
   - `import LogosTest.Core.Syntax.FormulaTest` → `import BimodalTest.Syntax.FormulaTest`
   - `import LogosTest.Core.Syntax.ContextTest` → `import BimodalTest.Syntax.ContextTest`
   - Update namespace to `BimodalTest.Syntax`

2. Update `LogosTest/ProofSystem.lean`:
   - `import LogosTest.Core.ProofSystem.AxiomsTest` → `import BimodalTest.ProofSystem.AxiomsTest`
   - `import LogosTest.Core.ProofSystem.DerivationTest` → `import BimodalTest.ProofSystem.DerivationTest`
   - Update namespace to `BimodalTest.ProofSystem`

3. Update `LogosTest/Semantics.lean`:
   - `import LogosTest.Core.Semantics.TaskFrameTest` → `import BimodalTest.Semantics.TaskFrameTest`
   - `import LogosTest.Core.Semantics.TruthTest` → `import BimodalTest.Semantics.TruthTest`

4. Update `LogosTest/Metalogic.lean`:
   - `import LogosTest.Core.Metalogic.SoundnessTest` → `import BimodalTest.Metalogic.SoundnessTest`

5. Update `LogosTest/Integration.lean`:
   - Update all 7 integration test imports

6. Update `LogosTest/Theorems.lean`:
   - `import LogosTest.Core.Theorems.PerpetuityTest` → `import BimodalTest.Theorems.PerpetuityTest`

7. Update `LogosTest/README.md`:
   - Update references to `Core/` with `BimodalTest/`
   - Update namespace examples

**Verification**:
- `grep -r "LogosTest.Core" LogosTest/` returns no results
- All parent files import from `BimodalTest.*`

---

### Phase 4: Verification and Cleanup

**Estimated effort**: 10 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify clean build
2. Update documentation files in BimodalTest/
3. Remove any orphaned files

**Files to modify**:
- `BimodalTest/Integration/README.md` - Update if needed
- `BimodalTest/Property/README.md` - Update if needed

**Steps**:
1. Run `lake clean && lake build` to verify all changes work
2. Check for any remaining `LogosTest.Core` references: `grep -r "LogosTest.Core" .`
3. Update documentation files in BimodalTest/ if they reference old paths
4. Verify test executable still works: `lake exe test`

**Verification**:
- `lake build` completes without errors
- `grep -r "LogosTest.Core" .` returns only archive/historical references
- `lake exe test` runs successfully

## Dependencies

- Task 352 must be completed (already done - Logos/Core → Bimodal migration complete)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build failures after move | Medium | Low | Use incremental approach, verify after each phase |
| Missed import references | Low | Medium | Use grep to find all references before and after |
| Test executable broken | Medium | Low | Test executable only runs after full import chain works |

## Success Criteria

- [ ] `BimodalTest/` directory exists with all 30 Lean files from `LogosTest/Core/`
- [ ] `lean_lib BimodalTest` target exists in `lakefile.lean`
- [ ] All files use `namespace BimodalTest.*` (no `LogosTest.Core`)
- [ ] All imports updated to `import BimodalTest.*`
- [ ] `lake build` completes without errors
- [ ] `lake exe test` runs successfully
- [ ] No `LogosTest.Core` references remain (except archive/historical)

## Rollback Plan

If implementation fails:
1. `git checkout .` to revert all changes
2. `git clean -fd BimodalTest/` to remove new directory
3. `lake clean && lake build` to verify rollback

The use of `git mv` means the original LogosTest/Core/ directory will be removed, but git history allows full recovery.
