# Implementation Plan: Task #352

**Task**: Rename Logos/Core/ to Bimodal/
**Version**: 001
**Created**: 2026-01-10
**Language**: lean

## Overview

Restructure the repository to establish `Bimodal/` as an independent library containing the bimodal TM logic implementation. This involves moving `Logos/Core/` to `Bimodal/`, updating namespaces from `Logos.Core` to `Bimodal`, modifying the lakefile to add a new library target, and updating all import references across the codebase.

The research identified ~32 Lean files in Logos/Core/ and ~96 files with `import Logos.Core` references. We'll use Option 1 (Full Separation) from the research report with 4 implementation phases.

## Phases

### Phase 1: Physical Move and lakefile Update

**Status**: [COMPLETED]

**Objectives**:
1. Move `Logos/Core/` directory to `Bimodal/`
2. Add `lean_lib Bimodal` to lakefile.lean
3. Create compatibility re-export layer in `Logos/Core.lean`

**Files to modify**:
- `Logos/Core/` -> `Bimodal/` (git mv)
- `lakefile.lean` - Add Bimodal library target
- `Logos/Core.lean` - Convert to re-export Bimodal

**Steps**:
1. Use `git mv Logos/Core/ Bimodal/` to move the directory (preserves history)
2. Rename `Bimodal/Core.lean` to `Bimodal/Bimodal.lean` (main re-export module)
3. Add `lean_lib Bimodal` to lakefile.lean before LogosTest
4. Create new `Logos/Core.lean` that re-exports Bimodal for backwards compatibility:
   ```lean
   -- Backwards compatibility: re-export Bimodal as Logos.Core
   import Bimodal
   ```

**Verification**:
- Directory structure: `Bimodal/` exists with all moved files
- `Logos/Core.lean` exists as compatibility layer
- `lakefile.lean` contains `lean_lib Bimodal`

---

### Phase 2: Namespace Migration

**Status**: [COMPLETED]

**Objectives**:
1. Change all `namespace Logos.Core` to `namespace Bimodal`
2. Change all internal imports from `import Logos.Core.*` to `import Bimodal.*`
3. Update `open Logos.Core` statements to `open Bimodal`

**Files to modify**:
- All 32 files in `Bimodal/` directory
  - `Bimodal/Bimodal.lean` (was Core.lean)
  - `Bimodal/Syntax.lean`, `Bimodal/Syntax/*.lean`
  - `Bimodal/ProofSystem.lean`, `Bimodal/ProofSystem/*.lean`
  - `Bimodal/Semantics.lean`, `Bimodal/Semantics/*.lean`
  - `Bimodal/Metalogic.lean`, `Bimodal/Metalogic/*.lean`
  - `Bimodal/Theorems.lean`, `Bimodal/Theorems/*.lean`
  - `Bimodal/Automation.lean`, `Bimodal/Automation/*.lean`

**Steps**:
1. Use sed/find-replace to change `namespace Logos.Core` -> `namespace Bimodal` in all Bimodal/*.lean files
2. Update internal imports: `import Logos.Core.X` -> `import Bimodal.X`
3. Update open statements: `open Logos.Core` -> `open Bimodal`
4. Run `lake build Bimodal` to check compilation

**Verification**:
- `lake build Bimodal` compiles successfully
- No remaining `Logos.Core` namespace declarations in `Bimodal/`
- All internal imports use `Bimodal.*`

---

### Phase 3: External Reference Updates

**Status**: [COMPLETED]

**Objectives**:
1. Update `Logos.lean` and Logos re-export modules
2. Update all LogosTest imports
3. Update Archive imports
4. Update extension stubs if needed

**Files to modify**:
- `Logos.lean` - Update to import Bimodal
- `Logos/Syntax.lean`, `Logos/Semantics.lean`, `Logos/ProofSystem.lean`, etc. - Update re-exports
- `LogosTest/Core/**/*.lean` (~35 files) - Update imports
- `Archive/*.lean` (~8 files) - Update imports

**Steps**:
1. Update `Logos.lean` to import Bimodal:
   ```lean
   import Bimodal
   -- Extensions (stubs)
   import Logos.Epistemic
   ...
   ```
2. Update Logos re-export modules (`Logos/Syntax.lean`, etc.) to:
   - Either re-export from Bimodal, or
   - Be removed if superseded by Bimodal
3. Update all LogosTest imports from `import Logos.Core.*` to `import Bimodal.*`
4. Update Archive imports similarly
5. Run `lake build` to verify full compilation

**Verification**:
- `lake build` completes successfully
- `lake build LogosTest` compiles
- `lake build Archive` compiles
- No errors referencing `Logos.Core` in build output

---

### Phase 4: Final Verification and Cleanup

**Status**: [IN PROGRESS]

**Objectives**:
1. Run full build and test suite
2. Clean up any remaining Logos.Core references in documentation
3. Verify backwards compatibility layer works

**Files to modify**:
- Documentation files (if time permits, lower priority)
- Any remaining files with stale references

**Steps**:
1. Run `lake clean && lake build` for clean rebuild
2. Run test suite: `lake exe test` or `lake build LogosTest`
3. Use `grep -r "Logos\.Core" --include="*.lean"` to find any remaining references
4. Fix any remaining issues found
5. Optional: Update documentation code examples (lower priority - can be separate task)

**Verification**:
- Clean build with `lake clean && lake build` succeeds
- No Lean errors or warnings related to the rename
- Test suite passes
- `grep -r "Logos\.Core" --include="*.lean"` returns only:
  - `Logos/Core.lean` (compatibility layer)
  - Historical spec/plan files (acceptable)

---

## Dependencies

- None - this is a standalone refactoring task

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build breaks after move | High | Medium | Use `lake build` incrementally after each phase |
| Missing import updates | Medium | Medium | Use grep to find all occurrences before and after |
| Backwards compatibility breaks | Medium | Low | Keep `Logos/Core.lean` re-export layer |
| Git history loss | Low | Low | Use `git mv` to preserve history |

## Success Criteria

- [ ] `Bimodal/` directory exists with all 32 Lean files from former `Logos/Core/`
- [ ] `lean_lib Bimodal` target exists in lakefile.lean
- [ ] All `Bimodal/*.lean` files use `namespace Bimodal`
- [ ] `lake build` completes without errors
- [ ] `lake build LogosTest` compiles successfully
- [ ] Backwards compatibility: `import Logos.Core` still works via re-export
- [ ] No `sorry` placeholders introduced during refactoring

## Rollback Plan

If implementation fails:
1. `git checkout .` to restore all files to pre-change state
2. `git clean -fd Bimodal/` to remove newly created directory
3. `lake clean && lake build` to verify restoration

Since this is a pure refactoring with git tracking, rollback is straightforward via `git checkout`.
