# Implementation Plan: Archive Non-Standard Completeness Theorems

- **Task**: 948 - archive_nonstandard_completeness_theorems
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/948_archive_nonstandard_completeness_theorems/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Archive BFMCS Completeness and FMP Completeness infrastructure to the Boneyard because they use non-standard validity definitions (`bmcs_valid`, `fmp_weak_completeness`) that are not proven equivalent to the standard `valid` definition in `Semantics/Validity.lean`. This archival preserves the code for reference while cleaning up the active codebase.

### Research Integration

Integrated from `reports/research-001.md`:
- Identified 3 shared utilities (`ContextDerivable`, `not_derivable_implies_neg_consistent`, `context_not_derivable_implies_extended_consistent`) used by Representation.lean that must be relocated before archiving Completeness.lean
- Mapped all FMP dependencies (4 files with internal import chain)
- Identified Boneyard files that import FMP (can leave with broken imports as Boneyard is documented as potentially non-building)
- Recommended `Metalogic_v8/` as archive location (next version after existing v7)

## Goals & Non-Goals

**Goals**:
- Archive `Bundle/Completeness.lean` to Boneyard with proper documentation
- Archive all 4 FMP files (`Closure.lean`, `FiniteWorldState.lean`, `BoundedTime.lean`, `SemanticCanonicalModel.lean`) to Boneyard
- Relocate shared utilities to `Construction.lean` to preserve Representation.lean functionality
- Update `Metalogic.lean` imports and documentation
- Verify full project builds successfully

**Non-Goals**:
- Fixing Boneyard files that import FMP (leave with broken imports)
- Proving equivalence of validity definitions (out of scope, this is why we archive)
- Removing the Boneyard import in `Closure.lean` (it can remain in archived code)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Shared utilities have hidden dependencies | Medium | Low | Research confirmed they only use Construction.lean content |
| Build breaks after moving utilities | Medium | Low | Incremental verification after each phase |
| Missing import updates | Low | Low | Full `lake build` verification in final phase |

## Sorry Characterization

### Pre-existing Sorries
- None identified in files being archived or modified

### Expected Resolution
- N/A - no sorries to resolve

### New Sorries
- None. This task is archival/refactoring only, no new proofs required.

### Remaining Debt
- No change to project sorry count

## Implementation Phases

### Phase 1: Relocate Shared Utilities [NOT STARTED]

- **Dependencies:** None
- **Goal:** Move three shared utility declarations from `Completeness.lean` to `Construction.lean` so `Representation.lean` can remove its Completeness import

**Tasks:**
- [ ] Copy `ContextDerivable` definition (lines 293-294) to end of `Construction.lean`
- [ ] Copy `not_derivable_implies_neg_consistent` lemma (lines 178-193) to `Construction.lean`
- [ ] Copy `context_not_derivable_implies_extended_consistent` lemma (lines 308-342) to `Construction.lean`
- [ ] Add any required imports to `Construction.lean` (deduction_theorem, double_negation)
- [ ] Remove `import Bimodal.Metalogic.Bundle.Completeness` from `Representation.lean`
- [ ] Verify `Representation.lean` builds: `lake build Bimodal.Metalogic.Representation`

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - add three declarations
- `Theories/Bimodal/Metalogic/Representation.lean` - remove import

**Verification:**
- `lake build Bimodal.Metalogic.Representation` passes
- `grep -n "ContextDerivable" Construction.lean` finds the definition

---

### Phase 2: Archive Bundle/Completeness.lean [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move Completeness.lean to Boneyard with proper archive header

**Tasks:**
- [ ] Create directory `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/`
- [ ] Copy `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` to archive location
- [ ] Add archive header comment documenting reason (non-standard validity definition)
- [ ] Update import path in archived file from `Bimodal.Metalogic.Bundle` to `Bimodal.Boneyard.Metalogic_v8.Bundle`
- [ ] Remove original `Theories/Bimodal/Metalogic/Bundle/Completeness.lean`

**Timing:** 20 minutes

**Files to modify:**
- `Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/Completeness.lean` - create new
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - delete

**Verification:**
- Archived file exists with proper header
- Original file removed

---

### Phase 3: Archive FMP Directory [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Move all four FMP files to Boneyard

**Tasks:**
- [ ] Create directory `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/`
- [ ] Copy `Closure.lean` with archive header
- [ ] Copy `FiniteWorldState.lean` with archive header
- [ ] Copy `BoundedTime.lean` with archive header
- [ ] Copy `SemanticCanonicalModel.lean` with archive header
- [ ] Update import paths in all four files (internal FMP imports and Metalogic imports)
- [ ] Handle `Closure.lean`'s Boneyard import (update path or leave as-is since already Boneyard)
- [ ] Remove original `Theories/Bimodal/Metalogic/FMP/` directory

**Timing:** 45 minutes

**Files to modify:**
- `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/Closure.lean` - create new
- `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/FiniteWorldState.lean` - create new
- `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/BoundedTime.lean` - create new
- `Theories/Bimodal/Boneyard/Metalogic_v8/FMP/SemanticCanonicalModel.lean` - create new
- `Theories/Bimodal/Metalogic/FMP/` - delete directory

**Verification:**
- All four files exist in Boneyard location
- Original FMP directory removed

---

### Phase 4: Update Imports and Documentation [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Update Metalogic.lean hub and create archive documentation

**Tasks:**
- [ ] Remove `import Bimodal.Metalogic.Bundle.Completeness` from `Metalogic.lean`
- [ ] Remove `import Bimodal.Metalogic.FMP.SemanticCanonicalModel` from `Metalogic.lean`
- [ ] Update `Metalogic.lean` module docstring to remove BFMCS and FMP completeness sections
- [ ] Create `Theories/Bimodal/Boneyard/Metalogic_v8/README.md` documenting archive reason
- [ ] Verify `Metalogic.lean` builds

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Metalogic.lean` - remove imports, update docstring
- `Theories/Bimodal/Boneyard/Metalogic_v8/README.md` - create new

**Verification:**
- `lake build Bimodal.Metalogic.Metalogic` passes
- README exists with archive rationale

---

### Phase 5: Verify Full Build [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Ensure full project builds and no regressions

**Tasks:**
- [ ] Run `lake build` for full project
- [ ] Verify no new errors introduced
- [ ] Check that `Representation.lean` standard completeness theorems still work
- [ ] Update TODO.md technical debt metrics if applicable

**Timing:** 25 minutes

**Files to modify:**
- None (verification only)

**Verification:**
- `lake build` passes with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/` shows no new sorries
- No regressions in active codebase

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/Construction.lean` returns expected (should be 0)
- [ ] No new sorries introduced in any modified files
- [ ] All proofs verified: `Representation.lean` continues to build

### General
- [ ] Archive structure matches Boneyard conventions (Metalogic_v8 naming)
- [ ] Archive headers follow standard format
- [ ] All original files removed from active codebase
- [ ] No orphaned imports remain

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Archived files in `Boneyard/Metalogic_v8/`
- Archive README at `Boneyard/Metalogic_v8/README.md`

## Rollback/Contingency

If implementation fails:
1. Use `git checkout -- .` to restore original files
2. Delete any created Boneyard directories
3. Re-run `lake build` to verify restoration
4. Mark task `[BLOCKED]` with specific issue

Git provides natural rollback since all changes are committed incrementally by phase.
