# Implementation Plan: Task #376

**Task**: Refactor repo for TheoryLib multi-theory structure
**Version**: 002
**Created**: 2026-01-12
**Revision of**: implementation-001.md
**Reason**: Incorporate changes from completed tasks 176, 179, 365, 367, 375, 377, 378, 380; add Logos/SubTheories/ organization per user request

## Revision Summary

The codebase has evolved significantly since the original plan. Several completed tasks have introduced new structures that the refactoring must account for:

### Changes Since Original Plan

| Task | Change | Impact on Refactor |
|------|--------|-------------------|
| 377 | Created Logos/Foundation/ with real content | Foundation/ must move to SubTheories/ |
| 377 | Logos/Explanatory/ has stub content | Explanatory/ must move to SubTheories/ |
| 375 | Created LaTeX/ at project root | Already provides shared LaTeX assets |
| 378 | Improved docs/ structure | Keep at project root |
| 176 | Added Bimodal/Automation/SuccessPatterns.lean | No structural impact |
| 179 | Created benchmarks/ directory at root | Keep at project root |

### Key Changes from Version 001

1. **Logos/SubTheories/** - New directory to contain Foundation/, Epistemic/, Normative/, Explanatory/ (user request)
2. **LaTeX/ already exists** - No need to create shared LaTeX structure (task 375 completed)
3. **Shared/ library deferred** - Since theories are not yet sharing Lean code, defer Shared library creation
4. **Simpler structure** - Focus on organizing existing content rather than creating new infrastructure

### New Target Structure

```
ProofChecker/
  lakefile.lean           # Updated with srcDir configuration
  LaTeX/                   # Already exists (shared assets from task 375)
  docs/           # Already exists (project-wide docs from task 378)
  benchmarks/              # Already exists (from task 179)
  Theories/
    Bimodal.lean           # Root module
    Bimodal/               # Existing Bimodal/* content (unchanged internally)
    Logos.lean             # Root module
    Logos/
      SubTheories/         # NEW: Contains theory layers
        Foundation/        # Move from Logos/Foundation/
        Epistemic/         # Move from Logos/Epistemic/
        Normative/         # Move from Logos/Normative/
        Explanatory/       # Move from Logos/Explanatory/
      docs/       # Keep theory-specific docs
      LaTeX/               # Keep theory-specific LaTeX
      Lint/                # Keep utility modules
  Tests/
    BimodalTest.lean       # Root module
    BimodalTest/           # Existing BimodalTest/* content
    LogosTest.lean         # Root module
    LogosTest/             # Existing LogosTest/* content
```

## Phases

### Phase 1: Create Logos/SubTheories/ and Reorganize Logos

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Create Logos/SubTheories/ directory
2. Move theory layers into SubTheories/
3. Update import paths within Logos/

**Files to create**:
- `Logos/SubTheories/` directory

**Files to move**:
- `Logos/Foundation/` → `Logos/SubTheories/Foundation/`
- `Logos/Foundation.lean` → `Logos/SubTheories/Foundation.lean`
- `Logos/Epistemic/` → `Logos/SubTheories/Epistemic/`
- `Logos/Epistemic.lean` → `Logos/SubTheories/Epistemic.lean`
- `Logos/Normative/` → `Logos/SubTheories/Normative/`
- `Logos/Normative.lean` → `Logos/SubTheories/Normative.lean`
- `Logos/Explanatory/` → `Logos/SubTheories/Explanatory/`
- `Logos/Explanatory.lean` → `Logos/SubTheories/Explanatory.lean`

**Files to modify**:
- `Logos.lean` - Update imports to use `Logos.SubTheories.*`
- `Logos/SubTheories/Foundation.lean` - Update internal imports
- All files in `Logos/SubTheories/*/` - Update import paths

**Steps**:
1. Create `Logos/SubTheories/` directory
2. Move Foundation layer:
   ```bash
   mkdir -p Logos/SubTheories
   mv Logos/Foundation Logos/SubTheories/
   mv Logos/Foundation.lean Logos/SubTheories/
   ```
3. Move Epistemic layer:
   ```bash
   mv Logos/Epistemic Logos/SubTheories/
   mv Logos/Epistemic.lean Logos/SubTheories/
   ```
4. Move Normative layer:
   ```bash
   mv Logos/Normative Logos/SubTheories/
   mv Logos/Normative.lean Logos/SubTheories/
   ```
5. Move Explanatory layer:
   ```bash
   mv Logos/Explanatory Logos/SubTheories/
   mv Logos/Explanatory.lean Logos/SubTheories/
   ```
6. Update imports in `Logos/SubTheories/Foundation.lean`:
   - Change `import Logos.Foundation.*` to `import Logos.SubTheories.Foundation.*`
7. Update imports in all `Logos/SubTheories/Foundation/*.lean` files
8. Update imports in other SubTheories modules similarly
9. Run `lake build Logos` to verify

**Verification**:
- `lake build Logos` succeeds
- `Logos/SubTheories/` contains Foundation/, Epistemic/, Normative/, Explanatory/
- Original Logos/docs/ and Logos/LaTeX/ remain in place

---

### Phase 2: Create Theories/ Directory and Move Bimodal

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Create Theories/ directory structure
2. Move Bimodal/ to Theories/Bimodal/
3. Update lakefile.lean for new structure

**Files to create**:
- `Theories/` directory

**Files to move**:
- `Bimodal/` → `Theories/Bimodal/`
- `Bimodal.lean` → `Theories/Bimodal.lean`

**Files to modify**:
- `lakefile.lean` - Update Bimodal library configuration
- `Theories/Bimodal.lean` - No internal import changes needed (uses `Bimodal.*` namespace)

**Steps**:
1. Create Theories directory:
   ```bash
   mkdir -p Theories
   ```
2. Move Bimodal:
   ```bash
   mv Bimodal Theories/
   mv Bimodal.lean Theories/
   ```
3. Update `lakefile.lean`:
   ```lean
   -- Define common options
   abbrev theoryLeanOptions := #[
     ⟨`pp.unicode.fun, true⟩,
     ⟨`autoImplicit, false⟩
   ]

   -- Bimodal library - standalone TM logic implementation
   lean_lib Bimodal where
     srcDir := "Theories"
     roots := #[`Bimodal]
     leanOptions := theoryLeanOptions
   ```
4. Verify Bimodal imports still work (they use `import Bimodal.X` which maps to `Theories/Bimodal/X.lean`)
5. Run `lake build Bimodal` to verify

**Verification**:
- `lake build Bimodal` succeeds
- `Theories/Bimodal/` contains all Bimodal content
- Bimodal.lean correctly exports the library

---

### Phase 3: Move Logos to Theories/

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Move Logos/ to Theories/Logos/
2. Update lakefile.lean for Logos
3. Verify cross-library imports work

**Files to move**:
- `Logos/` → `Theories/Logos/`
- `Logos.lean` → `Theories/Logos.lean`

**Files to modify**:
- `lakefile.lean` - Update Logos library configuration
- `Theories/Logos.lean` - Verify imports to Bimodal still work

**Steps**:
1. Move Logos:
   ```bash
   mv Logos Theories/
   mv Logos.lean Theories/
   ```
2. Update `lakefile.lean`:
   ```lean
   -- Logos library with linters enabled
   @[default_target]
   lean_lib Logos where
     srcDir := "Theories"
     roots := #[`Logos]
     leanOptions := theoryLeanOptions
   ```
3. Verify `Theories/Logos.lean` - the `import Bimodal` line should still work because Bimodal is a separate lean_lib
4. Run `lake build Logos` to verify

**Verification**:
- `lake build Logos` succeeds
- Cross-library import of Bimodal from Logos works
- `Theories/Logos/SubTheories/` structure is preserved

---

### Phase 4: Move Tests to Tests/ Directory

**Estimated effort**: 1.5 hours
**Status**: [NOT STARTED]

**Objectives**:
1. Create Tests/ directory
2. Move BimodalTest/ and LogosTest/
3. Update lakefile.lean and test executable

**Files to move**:
- `BimodalTest/` → `Tests/BimodalTest/`
- `BimodalTest.lean` → `Tests/BimodalTest.lean`
- `LogosTest/` → `Tests/LogosTest/`
- `LogosTest.lean` → `Tests/LogosTest.lean`

**Files to modify**:
- `lakefile.lean` - Update test library configurations and test executable

**Steps**:
1. Create Tests directory:
   ```bash
   mkdir -p Tests
   ```
2. Move test directories:
   ```bash
   mv BimodalTest Tests/
   mv BimodalTest.lean Tests/
   mv LogosTest Tests/
   mv LogosTest.lean Tests/
   ```
3. Update `lakefile.lean`:
   ```lean
   lean_lib LogosTest where
     srcDir := "Tests"
     roots := #[`LogosTest]

   lean_lib BimodalTest where
     srcDir := "Tests"
     roots := #[`BimodalTest]
     leanOptions := theoryLeanOptions

   lean_exe test where
     srcDir := "Tests"
     root := `LogosTest.Main
   ```
4. Verify test files can import theory libraries (`import Bimodal`, `import Logos`)
5. Run `lake build BimodalTest` and `lake build LogosTest`
6. Run `lake exe test` to verify test executable

**Verification**:
- `lake build BimodalTest` succeeds
- `lake build LogosTest` succeeds
- `lake exe test` runs successfully
- Test files can import both Bimodal and Logos libraries

---

### Phase 5: Update Scripts and Documentation

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]

**Objectives**:
1. Update any scripts referencing old paths
2. Update documentation to reflect new structure
3. Verify project-wide build

**Files to modify**:
- `scripts/*.lean` - Update if they reference moved files
- `docs/Architecture/` - Update path references
- `README.md` - Update directory structure documentation

**Files to create**:
- `Theories/README.md` - Document theory organization
- `Tests/README.md` - Document test organization

**Steps**:
1. Check scripts for path references:
   ```bash
   grep -r "Bimodal/" scripts/
   grep -r "Logos/" scripts/
   ```
2. Update any hard-coded paths in scripts
3. Create `Theories/README.md`:
   ```markdown
   # Theories

   This directory contains the formal logic theories implemented in Lean 4.

   ## Structure

   - `Bimodal/` - TM bimodal logic (Tense and Modality)
   - `Logos/` - Recursive semantics with layered extensions
     - `SubTheories/` - Theory layers (Foundation, Epistemic, Normative, Explanatory)
     - `docs/` - Theory-specific documentation
     - `LaTeX/` - Theory-specific LaTeX documentation
   ```
4. Create `Tests/README.md`:
   ```markdown
   # Tests

   This directory contains test suites for the formal logic theories.

   - `BimodalTest/` - Tests for Bimodal TM logic
   - `LogosTest/` - Tests for Logos recursive semantics
   ```
5. Update docs/ if it references old file paths
6. Run full build:
   ```bash
   lake clean
   lake build
   ```

**Verification**:
- `lake clean && lake build` succeeds with no warnings about missing files
- All scripts work correctly
- Documentation reflects current structure

---

## Dependencies

- No external dependencies
- Task 381 (causal semantics) and Task 382 (Spatial subtheory) should wait until after this refactoring
- This refactoring should complete before any new theory work

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| SubTheories/ import path complexity | Medium | Medium | Test imports incrementally after each move |
| Cross-library imports break | High | Low | Bimodal and Logos are separate lean_lib targets - should work |
| Scripts assume old paths | Low | Medium | Grep for path references before moving |
| LaTeX relative paths break | Medium | Low | LaTeX paths already use `../../LaTeX/` which will still work from `Theories/Logos/LaTeX/` |

## Success Criteria

- [ ] `lake clean && lake build` succeeds
- [ ] `Theories/` contains Bimodal/ and Logos/
- [ ] `Theories/Logos/SubTheories/` contains Foundation/, Epistemic/, Normative/, Explanatory/
- [ ] `Tests/` contains BimodalTest/ and LogosTest/
- [ ] `lake exe test` runs successfully
- [ ] No orphaned files in old locations
- [ ] Documentation updated to reflect new structure

## Rollback Plan

Each phase creates a git commit. If a phase fails:
1. `git reset --hard HEAD~1` to undo the last phase
2. Investigate the issue
3. Either fix and retry, or revert further if needed

The modular phase structure allows partial rollback without losing all progress.

## Comparison to Version 001

| Aspect | v001 | v002 |
|--------|------|------|
| Shared library | Created upfront | Deferred (not needed yet) |
| Logos structure | Flat | SubTheories/ for theory layers |
| LaTeX handling | Create new | Use existing (task 375) |
| Phases | 6 | 5 (simpler) |
| Total effort | ~7 hours | ~6.5 hours |
