# Implementation Plan: Task #376

**Task**: Refactor repo for TheoryLib multi-theory structure
**Version**: 001
**Created**: 2026-01-11
**Language**: lean

## Overview

Implement Option C (Hybrid Approach) to reorganize the ProofChecker repository into a clean multi-theory structure. This creates `Shared/`, `Theories/`, and `Tests/` top-level directories while maintaining a single `lakefile.lean` with multiple `lean_lib` targets. The structure supports future theory additions and eventual extraction of shared resources.

### Target Structure

```
ProofChecker/
  lakefile.lean           # Multiple lean_lib targets
  Shared.lean             # Root module for Shared library
  Shared/
    Core.lean             # Re-exports (placeholder for future shared types)
  Theories/
    Bimodal.lean          # Root module
    Bimodal/              # Existing Bimodal/* content
    Logos.lean            # Root module
    Logos/                # Existing Logos/* content
  Tests/
    BimodalTest.lean      # Root module
    BimodalTest/          # Existing BimodalTest/* content
    LogosTest.lean        # Root module
    LogosTest/            # Existing LogosTest/* content
```

## Phases

### Phase 1: Create Directory Structure and Shared Library

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Create the new directory structure (`Shared/`, `Theories/`, `Tests/`)
2. Create placeholder Shared library with minimal content
3. Ensure `lake build` still works before moving files

**Files to create**:
- `Shared/` directory
- `Shared.lean` - Root module exporting Shared library
- `Shared/Core.lean` - Placeholder for future shared types
- `Theories/` directory
- `Tests/` directory

**Steps**:
1. Create `Shared/` directory
2. Create `Shared.lean` with minimal content:
   ```lean
   import Shared.Core

   namespace Shared
   def version : String := "0.1.0"
   end Shared
   ```
3. Create `Shared/Core.lean` with placeholder:
   ```lean
   /-! # Shared Core Types
   Placeholder for future shared definitions across theories.
   -/
   namespace Shared.Core
   end Shared.Core
   ```
4. Create `Theories/` directory
5. Create `Tests/` directory
6. Run `lake build Shared` to verify the new library compiles

**Verification**:
- `Shared/` directory exists with `Core.lean`
- `lake build` succeeds (existing code unchanged)

---

### Phase 2: Update lakefile.lean for New Structure

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Add `Shared` library target
2. Update library targets with `srcDir` and `needs` configuration
3. Abstract common Lean options into a reusable abbreviation
4. Maintain backwards compatibility during transition

**Files to modify**:
- `lakefile.lean` - Add Shared library, update library configurations

**Steps**:
1. Add common options abbreviation:
   ```lean
   abbrev theoryLeanOptions := #[
     ⟨`pp.unicode.fun, true⟩,
     ⟨`autoImplicit, false⟩
   ]
   ```

2. Add Shared library target:
   ```lean
   lean_lib Shared where
     srcDir := "."
     leanOptions := theoryLeanOptions
   ```

3. Update Bimodal library (prepare for Phase 3 move):
   ```lean
   lean_lib Bimodal where
     srcDir := "."  -- Will change to "Theories" in Phase 3
     leanOptions := theoryLeanOptions
     -- needs := #[`Shared]  -- Enable after content exists
   ```

4. Update other library targets similarly (Logos, BimodalTest, LogosTest)

5. Run `lake build` to verify all libraries still compile

**Verification**:
- `lake build` succeeds with all libraries
- `lake build Shared` specifically succeeds

---

### Phase 3: Move Bimodal Theory to Theories/

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Move Bimodal/ directory to Theories/Bimodal/
2. Move Bimodal.lean to Theories/Bimodal.lean
3. Update lakefile.lean srcDir for Bimodal
4. Update all Bimodal import paths

**Files to modify**:
- `lakefile.lean` - Update Bimodal srcDir to "Theories"
- All files in `Theories/Bimodal/` - Update internal imports if needed

**Files to move**:
- `Bimodal/` → `Theories/Bimodal/`
- `Bimodal.lean` → `Theories/Bimodal.lean`

**Steps**:
1. Move Bimodal directory:
   ```bash
   mv Bimodal/ Theories/Bimodal/
   mv Bimodal.lean Theories/Bimodal.lean
   ```

2. Update `lakefile.lean`:
   ```lean
   lean_lib Bimodal where
     srcDir := "Theories"
     roots := #[`Bimodal]
     leanOptions := theoryLeanOptions
   ```

3. Update `Theories/Bimodal.lean` import:
   ```lean
   import Theories.Bimodal.Bimodal
   ```
   Wait - this won't work. The import path must match the module root.

   **Correction**: With `srcDir := "Theories"` and `roots := #[\`Bimodal]`, the import remains `import Bimodal.Bimodal` because Lake treats `Theories/` as the source root.

4. Verify internal Bimodal imports don't need changes (they use relative paths like `Bimodal.Syntax`)

5. Run `lake build Bimodal` to verify

**Verification**:
- `lake build Bimodal` succeeds
- All Bimodal tests still import correctly (tested in Phase 5)

---

### Phase 4: Move Logos Theory to Theories/

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Move Logos/ directory to Theories/Logos/
2. Move Logos.lean to Theories/Logos.lean
3. Update lakefile.lean for Logos
4. Verify Logos still imports Bimodal correctly

**Files to modify**:
- `lakefile.lean` - Update Logos srcDir and add dependency on Bimodal
- `Theories/Logos.lean` - Update imports

**Files to move**:
- `Logos/` → `Theories/Logos/`
- `Logos.lean` → `Theories/Logos.lean`

**Steps**:
1. Move Logos directory:
   ```bash
   mv Logos/ Theories/Logos/
   mv Logos.lean Theories/Logos.lean
   ```

2. Update `lakefile.lean`:
   ```lean
   lean_lib Logos where
     srcDir := "Theories"
     roots := #[`Logos]
     leanOptions := theoryLeanOptions
     -- Logos currently re-exports Bimodal, so needs it
   ```

3. Update `Theories/Logos.lean` - verify `import Bimodal` still works
   (Since Bimodal is a separate lean_lib, this cross-library import should work)

4. Update `Theories/Logos/Core.lean` - verify `import Bimodal` works

5. Run `lake build Logos` to verify

**Verification**:
- `lake build Logos` succeeds
- `import Bimodal` from within Logos code works correctly

---

### Phase 5: Move Test Libraries to Tests/

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Move BimodalTest/ to Tests/BimodalTest/
2. Move LogosTest/ to Tests/LogosTest/
3. Move root test modules
4. Update lakefile.lean for test libraries
5. Verify tests can import their corresponding theory libraries

**Files to modify**:
- `lakefile.lean` - Update test library configurations

**Files to move**:
- `BimodalTest/` → `Tests/BimodalTest/`
- `BimodalTest.lean` → `Tests/BimodalTest.lean`
- `LogosTest/` → `Tests/LogosTest/`
- `LogosTest.lean` → `Tests/LogosTest.lean`

**Steps**:
1. Move test directories:
   ```bash
   mv BimodalTest/ Tests/BimodalTest/
   mv BimodalTest.lean Tests/BimodalTest.lean
   mv LogosTest/ Tests/LogosTest/
   mv LogosTest.lean Tests/LogosTest.lean
   ```

2. Update `lakefile.lean`:
   ```lean
   lean_lib BimodalTest where
     srcDir := "Tests"
     roots := #[`BimodalTest]
     leanOptions := theoryLeanOptions

   lean_lib LogosTest where
     srcDir := "Tests"
     roots := #[`LogosTest]
   ```

3. Update test executable:
   ```lean
   lean_exe test where
     srcDir := "Tests"
     root := `LogosTest.Main
   ```

4. Verify test files can still import theory libraries:
   - `import Bimodal` should work from BimodalTest files
   - `import Logos` should work from LogosTest files

5. Run `lake build BimodalTest` and `lake build LogosTest`

**Verification**:
- `lake build BimodalTest` succeeds
- `lake build LogosTest` succeeds
- `lake exe test` still works

---

### Phase 6: Clean Up and Document

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Remove any orphaned files from old locations
2. Update Documentation to reflect new structure
3. Update any scripts that reference old paths
4. Create README for new directory structure

**Files to modify**:
- `scripts/` - Update paths if needed
- `docs/` - Update architecture docs

**Files to create**:
- `Theories/README.md` - Document theory organization
- `Tests/README.md` - Document test organization
- `Shared/README.md` - Document shared library purpose

**Steps**:
1. Verify no orphaned `.lean` files remain in old locations

2. Check and update scripts:
   - `scripts/LintAll.lean`
   - `scripts/RunEnvLinters.lean`
   - `scripts/LintStyle.lean`

3. Update Documentation references to file paths

4. Create brief README files for new directories explaining their purpose

5. Run full build to verify everything works:
   ```bash
   lake clean
   lake build
   ```

**Verification**:
- `lake clean && lake build` succeeds
- No compilation warnings about missing files
- All tests pass

---

## Dependencies

- No external dependencies; this is a structural refactoring
- Task 377 (Logos refactor) should happen AFTER this refactoring is complete
- Task 374 (Documentation refactor) may need coordination

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import path breakage | High | Medium | Test each phase independently; commit after each phase |
| Lake srcDir confusion | Medium | Medium | Test `lake build <lib>` after each lakefile change |
| Cross-library imports fail | High | Low | Test theory→theory imports (Logos→Bimodal) explicitly |
| External tools break | Low | Low | Check scripts directory after move |

## Success Criteria

- [ ] `lake clean && lake build` succeeds
- [ ] All four libraries build: Shared, Bimodal, Logos, tests
- [ ] Directory structure matches Option C layout
- [ ] `lake exe test` runs successfully
- [ ] No orphaned files in old locations
- [ ] Import paths work correctly across library boundaries

## Rollback Plan

Each phase creates a git commit. To rollback:
1. Identify the last working commit before the failing phase
2. `git reset --hard <commit>` to restore
3. Or selectively `git revert` specific phase commits

Since this is structural refactoring with no logic changes, rollback is straightforward.
