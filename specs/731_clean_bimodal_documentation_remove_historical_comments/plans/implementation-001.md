# Implementation Plan: Task #731

- **Task**: 731 - Clean Bimodal documentation - remove historical comments
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Priority**: Medium
- **Dependencies**: Task 726 (completed - MCS lemmas moved to Core)
- **Research Inputs**: specs/731_clean_bimodal_documentation_remove_historical_comments/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task cleans up the Bimodal Lean codebase by removing all historical artifacts while preserving current documentation. The scope includes: (1) removing provenance comments from Core/*.lean files, (2) removing SUPERSEDED/DEPRECATED markers from active code, (3) eliminating narrative history explaining past approaches, (4) removing Boneyard references from active code. Additionally, update remaining Boneyard imports in theorem files to use Core, move compatibility shims to Boneyard/Compat/, and verify complete Boneyard isolation.

### Research Integration

Research report (research-001.md) identified:
- 20 provenance comments in Core/DeductionTheorem.lean (12) and Core/MCSProperties.lean (8) - **task scope change: NOW REMOVE these**
- 2 compatibility shim files (Metalogic.lean, Metalogic_v2.lean) to move
- 2 theorem files with Boneyard imports to update (GeneralizedNecessitation.lean, Propositional.lean)
- SUPERSEDED markers in IndexedMCSFamily.lean and AesopRules.lean to evaluate

**Note**: Research recommended PRESERVING provenance comments. Task description explicitly overrides this - ALL historical artifacts must be removed including provenance comments.

## Goals & Non-Goals

**Goals**:
- Remove ALL provenance comments (`-- Origin: Boneyard/...`) from Core/*.lean files
- Remove SUPERSEDED/DEPRECATED docblocks and markers from active (non-Boneyard) code
- Remove narrative history explaining past approaches or design decisions
- Update GeneralizedNecessitation.lean and Propositional.lean imports to use Core
- Move Metalogic.lean and Metalogic_v2.lean to Boneyard/Compat/
- Verify complete Boneyard isolation (no active code imports from Boneyard)
- Ensure `lake build` passes after each phase

**Non-Goals**:
- Modifying Boneyard/ directory contents (except adding Compat/)
- Removing active TODOs (e.g., "Re-enable when Task 260 is unblocked")
- Removing Lean 4 `@[deprecated]` attributes (these are functional, not historical)
- Modifying README files (documentation outside source code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Breaking imports when updating Boneyard references | High | Medium | Run `lake build` after each file change |
| Removing useful architectural context | Medium | Medium | Focus on "where it came from" not "why it's designed this way" |
| Missing some historical comments | Low | Medium | Use systematic grep patterns for each category |
| Module not found after moving shims | High | Low | Create Compat directory first, update imports in correct order |

## Implementation Phases

### Phase 1: Update Boneyard Imports in Theorem Files [COMPLETED]

**Goal**: Change GeneralizedNecessitation.lean and Propositional.lean to import from Core instead of Boneyard

**Tasks**:
- [ ] Update GeneralizedNecessitation.lean: change `import Bimodal.Boneyard.Metalogic_v2.Core.DeductionTheorem` to `import Bimodal.Metalogic.Core.DeductionTheorem`
- [ ] Update Propositional.lean: change `import Bimodal.Boneyard.Metalogic_v2.Core.DeductionTheorem` to `import Bimodal.Metalogic.Core.DeductionTheorem`
- [ ] Run `lake build` to verify changes compile

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` - import statement
- `Theories/Bimodal/Theorems/Propositional.lean` - import statement

**Verification**:
- `lake build` passes without errors
- grep for Boneyard in Theorems/ shows no matches except acceptable patterns

---

### Phase 2: Move Compatibility Shims to Boneyard/Compat [COMPLETED]

**Goal**: Relocate deprecated Metalogic.lean and Metalogic_v2.lean files to Boneyard/Compat/

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Boneyard/Compat/`
- [ ] Move `Theories/Bimodal/Metalogic.lean` to `Theories/Bimodal/Boneyard/Compat/Metalogic.lean`
- [ ] Move `Theories/Bimodal/Metalogic_v2.lean` to `Theories/Bimodal/Boneyard/Compat/Metalogic_v2.lean`
- [ ] Check if any files import these shims and update if needed
- [ ] Run `lake build` to verify no regressions

**Timing**: 20 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - move to Boneyard/Compat/
- `Theories/Bimodal/Metalogic_v2.lean` - move to Boneyard/Compat/
- `Theories/Bimodal/Boneyard/Compat/` - create directory

**Verification**:
- Files exist at new locations
- Old locations are empty
- `lake build` passes
- No imports reference old paths

---

### Phase 3: Remove Provenance Comments from Core [NOT STARTED]

**Goal**: Remove all `-- Origin: Boneyard/...` comments from Core/*.lean files

**Tasks**:
- [ ] Read DeductionTheorem.lean and identify all 12 provenance comments
- [ ] Remove provenance comments from DeductionTheorem.lean while preserving functional code
- [ ] Read MCSProperties.lean and identify all 8 provenance comments
- [ ] Remove provenance comments from MCSProperties.lean while preserving functional code
- [ ] Run `lake build` to verify changes compile

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` - remove 12 provenance comments
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - remove 8 provenance comments

**Verification**:
- `grep "-- Origin:" Theories/Bimodal/Metalogic/Core/` returns no matches
- `lake build` passes
- All theorems and definitions still present (only comments removed)

---

### Phase 4: Remove SUPERSEDED/DEPRECATED Markers from Active Code [NOT STARTED]

**Goal**: Remove historical SUPERSEDED and DEPRECATED markers from non-Boneyard files

**Tasks**:
- [ ] Read IndexedMCSFamily.lean and identify SUPERSEDED markers (lines 583-599, 634-655)
- [ ] Evaluate each marker: remove if purely historical, preserve if provides current architectural context
- [ ] Remove identified historical markers from IndexedMCSFamily.lean
- [ ] Read AesopRules.lean line 39 and evaluate DEPRECATED comment
- [ ] Remove DEPRECATED comment if purely historical (note: Lean 4 `@[deprecated]` attributes stay)
- [ ] Run `lake build` to verify changes compile

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - remove SUPERSEDED docblocks
- `Theories/Bimodal/Automation/AesopRules.lean` - remove DEPRECATED comment

**Verification**:
- `grep -E "SUPERSEDED|DEPRECATED" Theories/Bimodal --include="*.lean" | grep -v Boneyard/` returns only acceptable matches
- `lake build` passes
- Code functionality unchanged

---

### Phase 5: Verify Boneyard Isolation [NOT STARTED]

**Goal**: Confirm complete isolation - no active code imports from Boneyard except acceptable patterns

**Tasks**:
- [ ] Run comprehensive grep for Boneyard references in active code
- [ ] Verify only acceptable patterns remain:
  - MaximalConsistent.lean re-export (intentional design)
  - Examples/Demo.lean (demonstration file)
  - Files within Boneyard/ directory
- [ ] Document final state of Boneyard isolation
- [ ] Run final `lake build` to confirm clean build

**Timing**: 20 minutes

**Files to modify**:
- None (verification phase)

**Verification**:
- `grep -r "Boneyard" Theories/Bimodal --include="*.lean" | grep -v "Boneyard/" | grep -v "MaximalConsistent.lean" | grep -v "Demo.lean"` returns empty or only acceptable matches
- `lake build` passes
- All phases completed successfully

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No provenance comments remain in Core/*.lean files
- [ ] No SUPERSEDED/DEPRECATED markers in active (non-Boneyard) code (except Lean attributes)
- [ ] Compatibility shims moved to Boneyard/Compat/
- [ ] GeneralizedNecessitation.lean and Propositional.lean use Core imports
- [ ] Boneyard isolation verified (only acceptable references remain)

## Artifacts & Outputs

- `specs/731_clean_bimodal_documentation_remove_historical_comments/plans/implementation-001.md` (this file)
- `specs/731_clean_bimodal_documentation_remove_historical_comments/summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified Lean files in Theories/Bimodal/
- New directory: Theories/Bimodal/Boneyard/Compat/

## Rollback/Contingency

If changes break the build:
1. `git checkout -- Theories/Bimodal/` to restore all modified files
2. Review each phase's changes individually
3. Re-apply changes incrementally with `lake build` between each

Git provides full recovery capability since all changes are to version-controlled files.
