# Implementation Plan: Task #818

- **Task**: 818 - Refactor Bimodal Metalogic Modules
- **Version**: 002 (Revised post-Task 826)
- **Status**: [IMPLEMENTED]
- **Effort**: 4-5 hours (reduced from 8 hours due to task 826 work)
- **Dependencies**: Task 826 (completed - FDSM archived, BMCS verified)
- **Research Inputs**:
  - specs/818_refactor_bimodal_metalogic_modules/reports/research-005.md
  - specs/826_fdsm_completeness_saturated_construction/plans/implementation-004.md
  - specs/826_fdsm_completeness_saturated_construction/summaries/implementation-summary-20260203.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Context Update**: Task 826 completed the critical archival work (FDSM module, obsolete Completeness/), reducing active sorries from 27 to 4. This revised plan focuses on the remaining refactoring work to achieve a publication-ready metalogic.

**Current State** (post-task 826):
- **Active sorries**: 4 (all in Bundle/ and FMP/, all documented as failures)
- **Main theorems**: ALL SORRY-FREE (soundness, completeness, decidability)
- **Archived**: FDSM/ (23 sorries), FMP_Bridge/ (10 sorries), old Completeness/

**Remaining Work**:
1. Consolidate DeductionTheorem duplication
2. Standardize naming conventions
3. Create unified Metalogic.lean entry point
4. Final cleanup and verification

### Key Achievements from Task 826

- FDSM/ module archived to Boneyard/FDSM/ with README documentation
- Completeness/Completeness.lean archived to Boneyard/Completeness/
- BMCS completeness verified as primary sorry-free path
- All remaining sorries documented with alternative approaches

## Goals & Non-Goals

**Goals**:
- Eliminate root-level DeductionTheorem.lean duplication
- Rename `semantic_weak_completeness` to `fmp_weak_completeness` for clarity
- Create unified Metalogic.lean entry point with clear theorem index
- Verify no Boneyard/ references remain in active code
- Document final sorry count (4) with full context
- Ensure build passes with publication-ready structure

**Non-Goals**:
- Archive FDSM/ (already done in task 826)
- Archive old Completeness/ (already done in task 826)
- Fix remaining 4 sorries (documented as inherent limitations)
- Modify Algebraic/ directory (preserved for future work)

## Remaining Sorries (4)

| File | Line | Sorry | Status | Alternative |
|------|------|-------|--------|-------------|
| Bundle/TruthLemma.lean | 383 | all_future backward | Documented | Infinitary proof system |
| Bundle/TruthLemma.lean | 395 | all_past backward | Documented | Infinitary proof system |
| Bundle/Construction.lean | 220 | modal_backward | Documented | Multi-family BMCS |
| FMP/Closure.lean | 728 | diamond membership | Documented | Minor - not affecting completeness |

**Key Point**: These do NOT affect main theorems because completeness uses only FORWARD direction.

## Implementation Phases

### Phase 1: Consolidate DeductionTheorem [COMPLETED]

**Goal**: Eliminate root-level DeductionTheorem.lean duplication.

**Tasks**:
- [ ] Compare root-level `Metalogic/DeductionTheorem.lean` with `Core/DeductionTheorem.lean`
- [ ] Verify Core/ version is canonical (more complete)
- [ ] If root-level version has unique content, merge into Core/
- [ ] Archive root-level DeductionTheorem.lean to Boneyard/Legacy/
- [ ] Update all imports to use `Bimodal.Metalogic.Core.DeductionTheorem`
- [ ] Run `lake build` to verify no breakage

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/DeductionTheorem.lean` - Archive or delete
- `Boneyard/Legacy/DeductionTheorem.lean` - New archive (if needed)
- Any files importing root-level version - Update imports

**Verification**:
- `lake build` succeeds
- No file imports `Bimodal.Metalogic.DeductionTheorem` directly
- Core/DeductionTheorem.lean contains all needed functionality

---

### Phase 2: Standardize Naming Conventions [COMPLETED]

**Goal**: Rename theorems for clarity and consistency.

**Tasks**:
- [ ] Rename `semantic_weak_completeness` to `fmp_weak_completeness` in FMP/SemanticCanonicalModel.lean
- [ ] Add alias `semantic_weak_completeness := fmp_weak_completeness` for backwards compatibility
- [ ] Update any call sites (likely none external)
- [ ] Verify naming is consistent across modules:
  - `bmcs_weak_completeness` (Bundle/)
  - `bmcs_strong_completeness` (Bundle/)
  - `fmp_weak_completeness` (FMP/)
- [ ] Run `lake build` to verify no breakage

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Rename theorem

**Verification**:
- `lake build` succeeds
- Naming is consistent across all completeness theorems
- No duplicate or confusing names

---

### Phase 3: Create Unified Entry Point [COMPLETED]

**Goal**: Refactor Metalogic.lean to clearly expose main results with publication-ready documentation.

**Tasks**:
- [ ] Rewrite Metalogic.lean module docstring with:
  ```lean
  /-!
  # Bimodal Metalogic

  This module provides the metalogical foundations for bimodal logic:
  soundness, completeness, and decidability.

  ## Main Results

  | Result | Theorem | Status |
  |--------|---------|--------|
  | Soundness | `Soundness.soundness` | SORRY-FREE |
  | BMCS Weak Completeness | `Bundle.Completeness.bmcs_weak_completeness` | SORRY-FREE |
  | BMCS Strong Completeness | `Bundle.Completeness.bmcs_strong_completeness` | SORRY-FREE |
  | FMP Weak Completeness | `FMP.SemanticCanonicalModel.fmp_weak_completeness` | SORRY-FREE |
  | Decidability | `Decidability.DecisionProcedure.decide` | SORRY-FREE |

  ## Sorry Count

  Active sorries: 4 (all in helper lemmas, documented as failures with alternatives)
  - 2 temporal backward lemmas (omega-rule limitation)
  - 1 modal backward lemma (single-family construction)
  - 1 diamond closure membership (non-essential)

  These do NOT affect main results - completeness uses only forward direction.

  ## Module Structure

  - `Core/` - MCS theory, provability, deduction theorem
  - `Bundle/` - BMCS completeness (primary completeness result)
  - `FMP/` - Finite Model Property, FMP-internal completeness
  - `Decidability/` - Tableau-based decision procedure
  - `Algebraic/` - (Future) Algebraic representation theorem
  -/
  ```
- [ ] Organize imports by category
- [ ] Add re-exports for main theorems
- [ ] Verify clean import structure (no Boneyard references)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Complete rewrite

**Verification**:
- `lake build` succeeds
- Main theorems accessible via single import
- Documentation clearly lists all results with status

---

### Phase 4: Final Cleanup and Verification [COMPLETED]

**Goal**: Ensure publication-ready state with no loose ends.

**Tasks**:
- [ ] Grep for `Boneyard` references in `Theories/Bimodal/Metalogic/` (should be zero)
- [ ] Grep for historical/comparative comments (remove if found)
- [ ] Verify all Boneyard/ files have self-contained documentation
- [ ] Count sorries: confirm exactly 4 in active Metalogic/
- [ ] Run full `lake build` and verify success
- [ ] Update Bundle/README.md to highlight main results
- [ ] Update FMP/README.md to clarify relationship to Bundle/
- [ ] Create implementation summary

**Timing**: 1.5 hours

**Files to verify**:
- All files in `Theories/Bimodal/Metalogic/`
- `Theories/Boneyard/FDSM/README.md` (exists from task 826)
- `Theories/Boneyard/Completeness/README.md` (exists from task 826)

**Verification**:
- Zero references to `Boneyard` in active Metalogic/ code
- Zero historical/comparative comments
- `lake build` succeeds
- Exactly 4 sorries in active Metalogic/
- All README files updated

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Sorry count remains at 4 (no new sorries)
- [ ] No circular imports created
- [ ] Main theorems accessible via `import Bimodal.Metalogic`
- [ ] No Boneyard references in active code
- [ ] Algebraic/ directory unchanged

## Artifacts & Outputs

- `specs/818_refactor_bimodal_metalogic_modules/plans/implementation-002.md` (this file)
- `specs/818_refactor_bimodal_metalogic_modules/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Refactored `Theories/Bimodal/Metalogic/Metalogic.lean` with publication-ready documentation
- Updated README files for Bundle/ and FMP/

## Changes from v001

| Aspect | v001 | v002 |
|--------|------|------|
| FDSM archival | Phase 2 | DONE (task 826) |
| FMP bridge archival | Phase 3 | DONE (task 826) |
| Completeness archival | N/A | DONE (task 826) |
| Active sorries | 84 estimated | 4 confirmed |
| Effort | 8 hours | 4-5 hours |
| Phases | 7 | 4 |

## Rollback/Contingency

Since most archival is already done (task 826), rollback is straightforward:
1. Phase-level rollback via `git revert` on specific phase commit
2. DeductionTheorem: Keep root-level if Core/ version is missing functionality
3. Naming: Aliases provide backwards compatibility

## Summary

This revised plan focuses on the finishing touches needed for a publication-ready metalogic:
- **Sorry count**: 4 (down from 84+ before task 826)
- **Main theorems**: ALL SORRY-FREE
- **Structure**: Clean, maintainable, well-documented
- **Effort**: 4-5 hours (reduced from 8 due to task 826)

The metalogic is essentially complete. This task provides the final polish.
