# Implementation Plan: Task #618

- **Task**: 618 - Move Metalogic to Boneyard, make Metalogic_v2 independent
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Normal
- **Dependencies**: None
- **Research Inputs**: specs/618_move_metalogic_to_boneyard_make_v2_independent/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Move the entire `Theories/Bimodal/Metalogic/` directory to `Theories/Bimodal/Boneyard/Metalogic/` and update all external consumers to either use `Metalogic_v2` equivalents or be moved to Boneyard themselves. The goal is to ensure nothing outside `Boneyard/` imports from within `Boneyard/`, establishing `Metalogic_v2` as the sole active metalogic implementation.

### Research Integration

Research confirmed:
- Metalogic_v2 is fully independent of Metalogic (no source imports detected)
- 4 external files import from Metalogic: `Logos/Metalogic.lean`, `Demo.lean`, `Propositional.lean`, `GeneralizedNecessitation.lean`
- 3 test files in `Tests/BimodalTest/Metalogic/` need migration
- Decidability module is unique to Metalogic (not yet in Metalogic_v2)
- `Metalogic_v2.Core.DeductionTheorem` provides equivalent functionality for migration

## Goals & Non-Goals

**Goals**:
- Move ALL of `Theories/Bimodal/Metalogic/` to `Theories/Bimodal/Boneyard/Metalogic/`
- Ensure NOTHING outside `Boneyard/` imports from within `Boneyard/`
- Migrate external consumers to `Metalogic_v2` equivalents where possible
- Handle the `Demo.lean` decidability dependency appropriately
- Preserve build success throughout migration

**Non-Goals**:
- Implementing decidability in Metalogic_v2 (separate future task)
- Changing any Metalogic_v2 functionality
- Removing any functionality (only relocating)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Demo.lean uses Decidability not in Metalogic_v2 | Medium | High | Move Demo.lean to Boneyard as well (it's a demo/example, not core functionality) |
| Import path changes break internal Metalogic references | Medium | Medium | Update all internal imports during move |
| Build failures from missed dependencies | High | Medium | Run `lake build` after each phase |
| Test files break | Low | High | Move old tests to archive, Metalogic_v2 has comprehensive tests |

## Implementation Phases

### Phase 1: Move Metalogic Directory to Boneyard [NOT STARTED]

**Goal**: Physically relocate all Metalogic files to Boneyard and update internal imports

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic/` directory structure
- [ ] Move all 23 files from `Theories/Bimodal/Metalogic/` to `Theories/Bimodal/Boneyard/Metalogic/`
- [ ] Update all internal imports from `Bimodal.Metalogic.` to `Bimodal.Boneyard.Metalogic.`
- [ ] Update `Theories/Bimodal/Metalogic.lean` hub file to import from new location
- [ ] Verify internal Metalogic build succeeds

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic/**/*.lean` - All moved files (23 files)
- `Theories/Bimodal/Metalogic.lean` - Hub file imports
- `Theories/Bimodal/Boneyard/Metalogic/Core/Basic.lean` - Internal imports
- `Theories/Bimodal/Boneyard/Metalogic/Core/Provability.lean` - Internal imports
- `Theories/Bimodal/Boneyard/Metalogic/Soundness/*.lean` - Internal imports
- `Theories/Bimodal/Boneyard/Metalogic/Completeness/*.lean` - Internal imports
- `Theories/Bimodal/Boneyard/Metalogic/Decidability/*.lean` - Internal imports
- `Theories/Bimodal/Boneyard/Metalogic/Representation/*.lean` - Internal imports
- `Theories/Bimodal/Boneyard/Metalogic/Applications/*.lean` - Internal imports

**Verification**:
- All Metalogic files exist under `Boneyard/Metalogic/`
- Original `Theories/Bimodal/Metalogic/` directory is removed (only hub remains)
- `lake build Bimodal.Boneyard.Metalogic.Decidability` succeeds

---

### Phase 2: Migrate Propositional.lean and GeneralizedNecessitation.lean [NOT STARTED]

**Goal**: Update theorem files to use Metalogic_v2.Core.DeductionTheorem instead of Metalogic.DeductionTheorem

**Tasks**:
- [ ] Update `Theories/Bimodal/Theorems/Propositional.lean` import to `Bimodal.Metalogic_v2.Core.DeductionTheorem`
- [ ] Verify Propositional.lean compiles with new import
- [ ] Update `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` import to `Bimodal.Metalogic_v2.Core.DeductionTheorem`
- [ ] Verify GeneralizedNecessitation.lean compiles with new import
- [ ] Run `lake build` to confirm no regressions

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems/Propositional.lean` - Line 4: change import
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - Line 3: change import

**Verification**:
- Both files compile without errors
- No imports from `Bimodal.Metalogic.` (without _v2) in either file
- Dependent files still compile

---

### Phase 3: Migrate Logos/Metalogic.lean [NOT STARTED]

**Goal**: Update Logos integration file to use Metalogic_v2

**Tasks**:
- [ ] Update `Theories/Logos/Metalogic.lean` imports from `Bimodal.Metalogic.*` to `Bimodal.Metalogic_v2.*`
- [ ] Map Soundness: `Bimodal.Metalogic.Soundness` -> `Bimodal.Metalogic_v2.Soundness.Soundness`
- [ ] Map Completeness: `Bimodal.Metalogic.Completeness` -> `Bimodal.Metalogic_v2.Completeness.StrongCompleteness`
- [ ] Verify any re-exports or type aliases still work
- [ ] Run `lake build Logos.Metalogic` to verify

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Logos/Metalogic.lean` - Lines 1-3: update imports

**Verification**:
- File compiles without errors
- No imports from `Bimodal.Metalogic.` (without _v2)
- Logos module builds successfully

---

### Phase 4: Move Demo.lean to Boneyard [NOT STARTED]

**Goal**: Relocate Demo.lean to Boneyard since it depends on Decidability which is unique to old Metalogic

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Examples/` directory
- [ ] Move `Theories/Bimodal/Examples/Demo.lean` to `Theories/Bimodal/Boneyard/Examples/Demo.lean`
- [ ] Update Demo.lean imports to use `Bimodal.Boneyard.Metalogic.*` paths
- [ ] Update any hub files that import Demo.lean (if any)
- [ ] Add deprecation notice to Demo.lean header
- [ ] Verify build succeeds

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Examples/Demo.lean` - New location with updated imports
- Original `Theories/Bimodal/Examples/Demo.lean` - Remove after move

**Verification**:
- Demo.lean exists only in `Boneyard/Examples/`
- Demo.lean compiles from new location
- No files outside Boneyard import from Boneyard

---

### Phase 5: Archive Old Metalogic Tests [NOT STARTED]

**Goal**: Remove or archive the 3 old Metalogic test files since Metalogic_v2 has comprehensive tests

**Tasks**:
- [ ] Remove `Tests/BimodalTest/Metalogic/` directory and its 3 test files
- [ ] Update `Tests/BimodalTest.lean` to remove imports of Metalogic tests (if present)
- [ ] Verify Metalogic_v2 tests (12 files) still run successfully
- [ ] Run full test build to verify no broken imports

**Timing**: 15 minutes

**Files to modify**:
- `Tests/BimodalTest/Metalogic/SoundnessTest.lean` - Delete
- `Tests/BimodalTest/Metalogic/CompletenessTest.lean` - Delete
- `Tests/BimodalTest/Metalogic/SoundnessPropertyTest.lean` - Delete
- `Tests/BimodalTest.lean` - Remove Metalogic test imports (if any)

**Verification**:
- No test files import from `Bimodal.Metalogic.` (without _v2)
- `lake build` succeeds
- Metalogic_v2 tests still pass

---

### Phase 6: Update Hub File and Final Cleanup [NOT STARTED]

**Goal**: Update or remove the Metalogic.lean hub file and verify no Boneyard imports remain outside Boneyard

**Tasks**:
- [ ] Either remove `Theories/Bimodal/Metalogic.lean` entirely OR convert it to a deprecation notice pointing to Metalogic_v2
- [ ] Run comprehensive grep to verify no imports from `Bimodal.Metalogic.` outside Boneyard
- [ ] Run comprehensive grep to verify no imports from `Bimodal.Boneyard.` outside Boneyard
- [ ] Verify full `lake build` succeeds
- [ ] Add deprecation documentation following existing Boneyard pattern

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - Remove or convert to deprecation notice

**Verification**:
- `grep -r "import.*Bimodal\.Metalogic\." --include="*.lean"` returns only Boneyard files
- `grep -r "import.*Bimodal\.Boneyard\." --include="*.lean"` returns only Boneyard files
- Full project builds successfully
- All Metalogic_v2 tests pass

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No files outside `Boneyard/` import from `Bimodal.Metalogic.` (without _v2)
- [ ] No files outside `Boneyard/` import from `Bimodal.Boneyard.*`
- [ ] Metalogic_v2 tests all pass
- [ ] `Theories/Bimodal/Theorems/Propositional.lean` compiles
- [ ] `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` compiles
- [ ] `Theories/Logos/Metalogic.lean` compiles

## Artifacts & Outputs

- `specs/618_move_metalogic_to_boneyard_make_v2_independent/plans/implementation-001.md` - This plan
- `specs/618_move_metalogic_to_boneyard_make_v2_independent/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If migration fails:
1. Git revert to pre-migration state
2. All original files are preserved in git history
3. No data loss is possible since this is purely a refactoring operation

If specific phase fails:
1. Stop at failed phase
2. Debug and fix before proceeding
3. Each phase is independently verifiable via `lake build`
