# Implementation Plan: Task #618 (Revision 2)

- **Task**: 618 - Move Metalogic to Boneyard, make Metalogic_v2 independent
- **Version**: 002
- **Status**: [IMPLEMENTING]
- **Effort**: 2-2.5 hours (reduced from 3 hours)
- **Priority**: Medium
- **Dependencies**: None (task 607 completed, decidability ported)
- **Research Inputs**: specs/618_move_metalogic_to_boneyard_make_v2_independent/reports/research-001.md
- **Previous Plan**: implementation-001.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**Key changes since v001:**
1. **Task 607 COMPLETED** - Decidability module is now fully ported to Metalogic_v2
2. **Task 490 in progress** (622-625) - Decidability correctness proofs being completed
3. **Demo.lean can now use Metalogic_v2** - No longer blocked on decidability
4. **Simplified plan** - No need to move Demo.lean to Boneyard

**Impact on original phases:**
- Phase 4 (Move Demo.lean to Boneyard): **ELIMINATED** - Demo.lean can migrate to Metalogic_v2
- Phase 2-3: Unchanged (migrate external consumers)
- Overall: Simpler migration with cleaner end state

## Overview

Move the entire `Theories/Bimodal/Metalogic/` directory to `Theories/Bimodal/Boneyard/Metalogic/` and update all 4 external consumers to use `Metalogic_v2` equivalents. With decidability now in Metalogic_v2, **nothing outside Boneyard needs to import from Boneyard**.

### Current External Consumers

| File | Current Import | Target Import |
|------|----------------|---------------|
| `Theories/Bimodal/Theorems/Propositional.lean` | `Bimodal.Metalogic.DeductionTheorem` | `Bimodal.Metalogic_v2.Core.DeductionTheorem` |
| `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` | `Bimodal.Metalogic.DeductionTheorem` | `Bimodal.Metalogic_v2.Core.DeductionTheorem` |
| `Theories/Logos/Metalogic.lean` | `Bimodal.Metalogic.{Soundness,Completeness}` | `Bimodal.Metalogic_v2.{Soundness,Completeness}` |
| `Theories/Bimodal/Examples/Demo.lean` | `Bimodal.Metalogic.*` (4 imports) | `Bimodal.Metalogic_v2.*` equivalents |

## Goals & Non-Goals

**Goals**:
- Move ALL of `Theories/Bimodal/Metalogic/` to `Theories/Bimodal/Boneyard/Metalogic/`
- Migrate ALL 4 external consumers to Metalogic_v2 (no Boneyard imports outside Boneyard)
- Preserve build success throughout migration
- Clean end state: Metalogic_v2 is the sole active implementation

**Non-Goals**:
- Completing decidability proofs (task 490/622-625)
- Changing Metalogic_v2 functionality
- Removing Metalogic from Boneyard (preserved for reference)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Demo.lean API mismatch with Metalogic_v2 | Medium | Medium | Check type signatures before migration; may need minor adaptations |
| Import path changes break internal Metalogic references | Medium | Medium | Update all internal imports during move |
| Build failures from missed dependencies | High | Medium | Run `lake build` after each phase |

## Implementation Phases

### Phase 1: Migrate External Consumer Imports [COMPLETED]

**Goal**: Update all 4 external files to use Metalogic_v2 before moving Metalogic

**Tasks**:
- [ ] Update `Theories/Bimodal/Theorems/Propositional.lean`:
  - Change `import Bimodal.Metalogic.DeductionTheorem` to `import Bimodal.Metalogic_v2.Core.DeductionTheorem`
- [ ] Update `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`:
  - Change `import Bimodal.Metalogic.DeductionTheorem` to `import Bimodal.Metalogic_v2.Core.DeductionTheorem`
- [ ] Update `Theories/Logos/Metalogic.lean`:
  - Change `import Bimodal.Metalogic.Soundness` to `import Bimodal.Metalogic_v2.Soundness.Soundness`
  - Change `import Bimodal.Metalogic.Completeness` to `import Bimodal.Metalogic_v2.Completeness.StrongCompleteness`
- [ ] Update `Theories/Bimodal/Examples/Demo.lean`:
  - Change `import Bimodal.Metalogic.Soundness` to `import Bimodal.Metalogic_v2.Soundness.Soundness`
  - Change `import Bimodal.Metalogic.DeductionTheorem` to `import Bimodal.Metalogic_v2.Core.DeductionTheorem`
  - Change `import Bimodal.Metalogic.Completeness.FiniteCanonicalModel` to appropriate Metalogic_v2 equivalent
  - Change `import Bimodal.Metalogic.Decidability.DecisionProcedure` to `import Bimodal.Metalogic_v2.Decidability.DecisionProcedure`
- [ ] Run `lake build` to verify all 4 files compile

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems/Propositional.lean` - Line 4
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - Line 3
- `Theories/Logos/Metalogic.lean` - Lines 1-3
- `Theories/Bimodal/Examples/Demo.lean` - Lines 4-7

**Verification**:
- All 4 files compile without errors
- No files outside Metalogic/ import from `Bimodal.Metalogic.` (without _v2)
- `lake build` succeeds

---

### Phase 2: Move Metalogic Directory to Boneyard [IN PROGRESS]

**Goal**: Physically relocate all Metalogic files to Boneyard and update internal imports

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic/` directory structure
- [ ] Move all files from `Theories/Bimodal/Metalogic/` to `Theories/Bimodal/Boneyard/Metalogic/`
  - Core/, Soundness/, Representation/, Completeness/, Decidability/, Applications/
  - Hub files: Completeness.lean, Decidability.lean, DeductionTheorem.lean
- [ ] Update all internal imports from `Bimodal.Metalogic.` to `Bimodal.Boneyard.Metalogic.`
- [ ] Remove or redirect `Theories/Bimodal/Metalogic.lean` hub file
- [ ] Verify internal Boneyard/Metalogic build succeeds

**Timing**: 45 minutes

**Files to modify**:
- All files in `Theories/Bimodal/Boneyard/Metalogic/**/*.lean` (17+ files, internal imports)
- `Theories/Bimodal/Metalogic.lean` - Remove or convert to deprecation notice

**Verification**:
- All Metalogic files exist under `Boneyard/Metalogic/`
- Original `Theories/Bimodal/Metalogic/` directory is removed
- `lake build Bimodal.Boneyard.Metalogic.Decidability` succeeds

---

### Phase 3: Archive Old Metalogic Tests [NOT STARTED]

**Goal**: Remove the 3 old Metalogic test files since Metalogic_v2 has comprehensive tests

**Tasks**:
- [ ] Remove `Tests/BimodalTest/Metalogic/SoundnessTest.lean`
- [ ] Remove `Tests/BimodalTest/Metalogic/CompletenessTest.lean`
- [ ] Remove `Tests/BimodalTest/Metalogic/SoundnessPropertyTest.lean`
- [ ] Remove `Tests/BimodalTest/Metalogic/` directory
- [ ] Update `Tests/BimodalTest.lean` to remove Metalogic test imports (if present)
- [ ] Verify test build succeeds

**Timing**: 15 minutes

**Files to delete**:
- `Tests/BimodalTest/Metalogic/SoundnessTest.lean`
- `Tests/BimodalTest/Metalogic/CompletenessTest.lean`
- `Tests/BimodalTest/Metalogic/SoundnessPropertyTest.lean`

**Verification**:
- No test files import from `Bimodal.Metalogic.` (without _v2)
- `lake build` succeeds

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

**Goal**: Verify no Boneyard imports remain outside Boneyard and add documentation

**Tasks**:
- [ ] Run comprehensive grep to verify no imports from `Bimodal.Metalogic.` outside Boneyard
- [ ] Run comprehensive grep to verify no imports from `Bimodal.Boneyard.` outside Boneyard
- [ ] Verify full `lake build` succeeds
- [ ] Add deprecation header to Boneyard/Metalogic files following existing pattern

**Timing**: 15 minutes

**Verification**:
- `grep -r "import.*Bimodal\.Metalogic\." --include="*.lean" | grep -v Boneyard` returns nothing
- `grep -r "import.*Bimodal\.Boneyard\." --include="*.lean" | grep -v Boneyard` returns nothing
- Full project builds successfully
- All Metalogic_v2 tests pass

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] No files outside `Boneyard/` import from `Bimodal.Metalogic.` (without _v2)
- [ ] No files outside `Boneyard/` import from `Bimodal.Boneyard.*`
- [ ] Metalogic_v2 tests all pass
- [ ] All 4 migrated files compile correctly

## Artifacts & Outputs

- `specs/618_move_metalogic_to_boneyard_make_v2_independent/plans/implementation-001.md` - Original plan
- `specs/618_move_metalogic_to_boneyard_make_v2_independent/plans/implementation-002.md` - This revised plan
- `specs/618_move_metalogic_to_boneyard_make_v2_independent/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If migration fails:
1. Git revert to pre-migration state
2. All original files preserved in git history
3. No data loss possible (purely refactoring)

If specific phase fails:
1. Stop at failed phase
2. Debug and fix before proceeding
3. Each phase independently verifiable via `lake build`
