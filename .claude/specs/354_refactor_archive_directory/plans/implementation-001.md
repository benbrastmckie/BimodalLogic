# Implementation Plan: Task #354

**Task**: Refactor Archive/ directory - Move examples to Bimodal/Examples/
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Move all pedagogical example files from `Archive/` to `Bimodal/Examples/`, establishing a pattern where examples are co-located with their library. Remove the `Archive/` directory and `Logos/Examples/` shims after migration. Move historical documentation to `.claude/archive/`.

## Phases

### Phase 1: Create Bimodal/Examples/ Structure

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create `Bimodal/Examples/` directory
2. Create `Bimodal/Examples.lean` aggregator module

**Files to create**:
- `Bimodal/Examples/` directory
- `Bimodal/Examples.lean` - aggregator re-exporting all example modules

**Steps**:
1. Create `Bimodal/Examples/` directory
2. Create `Bimodal/Examples.lean` with imports for all example modules (placeholder until files moved)

**Verification**:
- Directory exists: `ls Bimodal/Examples/`
- File exists: `cat Bimodal/Examples.lean`

---

### Phase 2: Move Example Files

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Move 7 example `.lean` files from `Archive/` to `Bimodal/Examples/`
2. Update namespace declarations from `Archive` to `Bimodal.Examples`
3. Preserve git history with `git mv`

**Files to move**:
| Source | Destination |
|--------|-------------|
| `Archive/ModalProofs.lean` | `Bimodal/Examples/ModalProofs.lean` |
| `Archive/ModalProofStrategies.lean` | `Bimodal/Examples/ModalProofStrategies.lean` |
| `Archive/TemporalProofs.lean` | `Bimodal/Examples/TemporalProofs.lean` |
| `Archive/TemporalProofStrategies.lean` | `Bimodal/Examples/TemporalProofStrategies.lean` |
| `Archive/BimodalProofs.lean` | `Bimodal/Examples/BimodalProofs.lean` |
| `Archive/BimodalProofStrategies.lean` | `Bimodal/Examples/BimodalProofStrategies.lean` |
| `Archive/TemporalStructures.lean` | `Bimodal/Examples/TemporalStructures.lean` |

**Steps**:
1. Use `git mv` to move each file (preserves history)
2. Update namespace in each file: `namespace Archive` → `namespace Bimodal.Examples`
3. Update any internal cross-references between example files
4. Update documentation path references in docstrings (`Logos/Core/` → `Bimodal/`)

**Verification**:
- All 7 files exist in `Bimodal/Examples/`
- Each file has `namespace Bimodal.Examples`
- `lake build Bimodal` succeeds

---

### Phase 3: Update Bimodal Library Integration

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Update `Bimodal/Examples.lean` with actual imports
2. Update `Bimodal/Bimodal.lean` to include Examples module
3. Create `Bimodal/Examples/README.md` documentation

**Files to modify**:
- `Bimodal/Examples.lean` - finalize imports
- `Bimodal/Bimodal.lean` - add `import Bimodal.Examples`

**Files to create**:
- `Bimodal/Examples/README.md` - documentation for examples (move from Archive/README.md)

**Steps**:
1. Update `Bimodal/Examples.lean` to import all 7 example modules
2. Add `import Bimodal.Examples` to `Bimodal/Bimodal.lean`
3. Move and adapt `Archive/README.md` to `Bimodal/Examples/README.md`
4. Update paths in README from `Archive/` to `Bimodal/Examples/`

**Verification**:
- `lake build Bimodal` succeeds
- `import Bimodal.Examples` works in a test file

---

### Phase 4: Update Logos/Examples Aggregator

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Repurpose `Logos/Examples.lean` to import `Bimodal.Examples`
2. Remove individual shim files from `Logos/Examples/`
3. Set up pattern for future layer examples

**Files to modify**:
- `Logos/Examples.lean` - change to import Bimodal.Examples

**Files to delete**:
- `Logos/Examples/ModalProofs.lean`
- `Logos/Examples/ModalProofStrategies.lean`
- `Logos/Examples/TemporalProofs.lean`
- `Logos/Examples/TemporalProofStrategies.lean`
- `Logos/Examples/BimodalProofs.lean`
- `Logos/Examples/BimodalProofStrategies.lean`
- `Logos/Examples/TemporalStructures.lean`

**Steps**:
1. Update `Logos/Examples.lean`:
   ```lean
   import Bimodal.Examples

   /-!
   # Logos Examples Aggregator

   Imports examples from all Logos layers:
   - Bimodal.Examples (Layer 0 - TM Logic)
   - Future: Logos.Explanatory.Examples (Layer 1)
   - Future: Logos.Epistemic.Examples (Layer 2)
   - Future: Logos.Normative.Examples (Layer 3)
   -/
   ```
2. Delete 7 shim files from `Logos/Examples/`
3. Remove `Logos/Examples/` directory if empty

**Verification**:
- `import Logos.Examples` still works
- `Logos/Examples/` directory removed or contains only README

---

### Phase 5: Remove Archive/ Directory

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Move `Archive/logos-original/` to `.claude/archive/logos-original/`
2. Remove `Archive/` directory completely
3. Update `lakefile.lean` to remove `lean_lib Archive`

**Files to move**:
- `Archive/logos-original/` → `.claude/archive/logos-original/`

**Files to delete**:
- `Archive/Archive.lean`
- `Archive/README.md` (already moved to Bimodal/Examples/)
- `Archive/` directory

**Files to modify**:
- `lakefile.lean` - remove `lean_lib Archive` line

**Steps**:
1. Create `.claude/archive/` if not exists
2. Move `Archive/logos-original/` to `.claude/archive/logos-original/` with `git mv`
3. Delete `Archive/Archive.lean`
4. Delete `Archive/README.md`
5. Remove `Archive/` directory
6. Edit `lakefile.lean` to remove `lean_lib Archive`

**Verification**:
- `Archive/` directory no longer exists
- `lake build` succeeds without Archive library
- `.claude/archive/logos-original/` contains historical docs

---

### Phase 6: Final Verification and Documentation

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify full build succeeds
2. Update any remaining documentation references
3. Test import paths

**Files to potentially update**:
- `Documentation/Development/MODULE_ORGANIZATION.md` - update structure docs
- `Documentation/Development/NONCOMPUTABLE_GUIDE.md` - update path references

**Steps**:
1. Run `lake clean && lake build` to verify clean build
2. Search for remaining `Archive/` references: `grep -r "Archive/" --include="*.md"`
3. Search for remaining `Logos/Core/` references in examples: `grep -r "Logos/Core" Bimodal/Examples/`
4. Update any found references
5. Test import commands:
   - `import Bimodal.Examples`
   - `import Bimodal.Examples.ModalProofs`
   - `import Logos.Examples`

**Verification**:
- `lake build` succeeds
- No `Archive/` references remain in active code
- All import paths work correctly

---

## Dependencies

- Task 352 (Logos/Core → Bimodal) - COMPLETED
- Task 353 (LogosTest/Core → BimodalTest) - NOT blocking (different scope)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking existing `Archive.*` imports | Medium | Low | Build verification at each phase |
| Missing namespace updates | Low | Medium | Systematic search/replace with verification |
| Documentation references outdated | Low | High | Grep for old paths after migration |
| Git history lost | Low | Low | Use `git mv` for all file moves |

## Success Criteria

- [ ] `Bimodal/Examples/` directory contains all 7 example files
- [ ] All example files use `namespace Bimodal.Examples`
- [ ] `import Bimodal.Examples` works correctly
- [ ] `import Logos.Examples` imports Bimodal.Examples
- [ ] `Archive/` directory removed
- [ ] `lean_lib Archive` removed from lakefile
- [ ] `lake build` succeeds without errors
- [ ] No `Archive/` references in active Lean code
- [ ] `logos-original/` preserved in `.claude/archive/`

## Rollback Plan

If implementation fails:
1. Use `git checkout -- .` to revert all changes
2. Or revert specific commits if partially committed
3. Archive structure preserved in git history

The modular phase structure allows partial rollback - each phase can be reverted independently if needed.
