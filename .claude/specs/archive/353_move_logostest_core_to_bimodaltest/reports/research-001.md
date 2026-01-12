# Research Report: Task #353

**Task**: Move LogosTest/Core/ to BimodalTest/
**Date**: 2026-01-10
**Focus**: Directory structure, namespace migration, lakefile configuration

## Summary

Task 353 involves moving the `LogosTest/Core/` directory to a new top-level `BimodalTest/` directory to mirror the Bimodal library structure established in task 352. This follows the Mathlib pattern (Mathlib/ + MathlibTest/) with separate test directory. The work is straightforward since task 352 already updated all imports from `Logos.Core` to `Bimodal`.

## Findings

### Current State Analysis

**Files to move**: 30 Lean files in `LogosTest/Core/`
- `Automation/` - 5 files (ProofSearchTest, EdgeCaseTest, ProofSearchBenchmark, TacticsTest, TacticsTest_Simple)
- `Integration/` - 7 files (EndToEndTest, ProofSystemSemanticsTest, BimodalIntegrationTest, TemporalIntegrationTest, ComplexDerivationTest, AutomationProofSystemTest, Helpers)
- `Metalogic/` - 3 files (SoundnessTest, CompletenessTest, SoundnessPropertyTest)
- `ProofSystem/` - 3 files (AxiomsTest, DerivationTest, DerivationPropertyTest)
- `Property/` - 1 file (Generators)
- `Semantics/` - 3 files (TruthTest, TaskFrameTest, SemanticPropertyTest)
- `Syntax/` - 3 files (FormulaTest, ContextTest, FormulaPropertyTest)
- `Theorems/` - 4 files (PropositionalTest, ModalS4Test, ModalS5Test, PerpetuityTest)
- Root: `Property.lean`

**Documentation files to move**: 3 markdown files
- `LogosTest/Core/Integration/README.md`
- `LogosTest/Core/Integration/COVERAGE.md`
- `LogosTest/Core/Property/README.md`

### Imports Already Updated (Task 352)

Task 352 already updated all test files to import from `Bimodal.*` instead of `Logos.Core.*`. This means the library imports in test files are already correct.

### Changes Required

#### 1. Directory Move
Move `LogosTest/Core/` → `BimodalTest/` using `git mv` to preserve history.

#### 2. Namespace Changes
All files use `namespace LogosTest.Core.*` which needs to change to `namespace BimodalTest.*`:
- 27 namespace declarations across all test files
- Examples:
  - `namespace LogosTest.Core.Syntax` → `namespace BimodalTest.Syntax`
  - `namespace LogosTest.Core.Metalogic` → `namespace BimodalTest.Metalogic`
  - `namespace LogosTest.Core.Integration.Helpers` → `namespace BimodalTest.Integration.Helpers`

#### 3. Internal Import Updates
30+ internal imports reference `LogosTest.Core.*`:
- `import LogosTest.Core.Integration.Helpers` → `import BimodalTest.Integration.Helpers`
- `import LogosTest.Core.Property.Generators` → `import BimodalTest.Property.Generators`
- etc.

#### 4. Parent Directory Imports
Files in `LogosTest/` that import from `LogosTest/Core/` need updates:
- `LogosTest/Syntax.lean` - imports FormulaTest, ContextTest
- `LogosTest/ProofSystem.lean` - imports AxiomsTest, DerivationTest
- `LogosTest/Semantics.lean` - imports TaskFrameTest, TruthTest
- `LogosTest/Metalogic.lean` - imports SoundnessTest
- `LogosTest/Integration.lean` - imports 7 test files
- `LogosTest/Theorems.lean` - imports PerpetuityTest

These will need to change from `import LogosTest.Core.*` to `import BimodalTest.*`.

#### 5. Lakefile Configuration
Add `lean_lib BimodalTest` target to `lakefile.lean`:
```lean
lean_lib BimodalTest where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩,
    ⟨`autoImplicit, false⟩
  ]
```

#### 6. Test Executable
The `lean_exe test` configuration uses `root := `LogosTest.Main` which imports `LogosTest.LogosTest`. This chain should continue to work after updates since `LogosTest.LogosTest` will import from `BimodalTest.*` via the updated parent files.

### Mathlib Pattern Reference

Following the Mathlib pattern:
- Library: `Mathlib/` → `Bimodal/`
- Tests: `MathlibTest/` → `BimodalTest/`

The test library mirrors the source library structure:
- `Bimodal/Syntax/Formula.lean` tested by `BimodalTest/Syntax/FormulaTest.lean`
- `Bimodal/ProofSystem/Derivation.lean` tested by `BimodalTest/ProofSystem/DerivationTest.lean`

### LogosTest Structure After Migration

After moving `LogosTest/Core/` to `BimodalTest/`, the `LogosTest/` directory will contain:
- `Main.lean` - Test executable entry point
- `LogosTest.lean` - Root re-export (will import from BimodalTest)
- `Syntax.lean`, `ProofSystem.lean`, etc. - Category re-exports (will import from BimodalTest)
- `README.md` - Will need path updates

`LogosTest/` becomes a thin wrapper that imports from `BimodalTest/` for the TM logic tests, leaving room for future Logos extension tests.

## Recommendations

1. **Use git mv**: Preserve commit history by using `git mv LogosTest/Core BimodalTest`

2. **Follow task 352 pattern**: Use similar phased approach:
   - Phase 1: Physical move and lakefile update
   - Phase 2: Namespace migration (LogosTest.Core → BimodalTest)
   - Phase 3: External reference updates (parent LogosTest/*.lean files)
   - Phase 4: Verification and cleanup

3. **Update README files**: Update paths in:
   - `LogosTest/README.md` (references to Core/)
   - `BimodalTest/Integration/README.md` (if needed)

4. **Backwards compatibility**: Consider if `LogosTest/Core.lean` re-export layer is needed (likely not, since this is test code)

## References

- Task 352 implementation summary: `.claude/specs/352_rename_logos_core_to_bimodal/summaries/implementation-summary-20260110.md`
- Current lakefile: `lakefile.lean` (shows existing lean_lib patterns)
- Mathlib pattern: Mathlib + MathlibTest separate directories

## Next Steps

1. Create implementation plan with phased approach
2. Phase 1: `git mv` and lakefile update
3. Phase 2: Namespace changes (sed/Edit on 27 namespace declarations)
4. Phase 3: Import updates (30+ internal imports, 6+ parent imports)
5. Phase 4: Verify build, update documentation
