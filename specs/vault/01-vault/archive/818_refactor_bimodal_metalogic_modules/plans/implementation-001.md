# Implementation Plan: Task #818

- **Task**: 818 - Refactor Bimodal Metalogic Modules
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: Task 812 (BMCS Completeness), Task 825 (FDSM Modal Saturation) - both completed
- **Research Inputs**: specs/818_refactor_bimodal_metalogic_modules/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan refactors the Bimodal/Metalogic/ directory (12,545 lines across 42 files) to achieve a publication-ready, maintainable structure following a clean-break methodology. The refactoring will archive obsolete code to Boneyard/ with self-contained documentation, consolidate completeness entry points, and create a clear main entry point highlighting the five main results: soundness, representation, completeness (BMCS and FMP), compactness, and decidability.

**Clean-Break Principles**:
- No historical or comparative comments in active code
- No references to Boneyard/ in active code imports or comments
- Archived code contains detailed self-contained documentation
- Task 826 will handle sorry completion; this task focuses on organization

### Research Integration

Key findings from research-001.md integrated into this plan:
- Three completeness approaches exist (Bundle/BMCS, FDSM, FMP) creating redundancy
- ~1400 lines in FDSM/ModalSaturation.lean deprecated (abstract saturation approach)
- ~100 lines in FMP/ConsistentSatisfiable.lean blocked (validity bridge)
- Root-level DeductionTheorem.lean duplicates Core/DeductionTheorem.lean
- Naming inconsistencies: `semantic_weak_completeness` vs `fmp_weak_completeness`
- Algebraic/ is self-contained and should be preserved unchanged

## Goals & Non-Goals

**Goals**:
- Archive deprecated FDSM saturation code and blocked FMP bridge code to Boneyard/
- Eliminate root-level DeductionTheorem.lean duplication
- Create unified Metalogic.lean entry point exposing main theorems clearly
- Standardize naming conventions (e.g., rename `semantic_weak_completeness` to `fmp_weak_completeness`)
- Ensure clean import graph with no Boneyard/ references in active code
- Document Boneyard/ code with detailed self-contained comments
- Verify build passes with no new sorries introduced

**Non-Goals**:
- Fix existing sorries (deferred to Task 826)
- Modify Algebraic/ directory (preserved for future algebraic representation work)
- Add new theorems or proofs
- Change the mathematical content of any proofs

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Circular import breakage | High | Medium | Phase 1 analyzes dependencies before moving files |
| Loss of working code | High | Low | Archive to Boneyard/ rather than delete; verify build at each phase |
| Incorrect theorem attribution | Medium | Low | Verify main theorem locations in research report |
| Incomplete Boneyard documentation | Medium | Medium | Strict checklist for Boneyard comments |
| Build failures from import changes | High | Medium | Phase-by-phase commits enable rollback |

## Implementation Phases

### Phase 1: Dependency Analysis and Preparation [NOT STARTED]

**Goal**: Map the complete dependency graph and identify all files that import deprecated code, establishing the safe execution order for subsequent phases.

**Tasks**:
- [ ] Generate full import graph for Metalogic/ directory
- [ ] Identify all files importing FDSM/ModalSaturation.lean deprecated sections
- [ ] Identify all files importing FMP/ConsistentSatisfiable.lean blocked code
- [ ] Identify all files importing root-level DeductionTheorem.lean
- [ ] Document import relationships in working notes
- [ ] Verify Algebraic/ imports are self-contained (no external Metalogic dependencies except Core/)

**Timing**: 1 hour

**Files to analyze**:
- All 42 files in `Theories/Bimodal/Metalogic/`
- `Theories/Bimodal/Bimodal.lean` (top-level imports)

**Verification**:
- Import graph documented
- Safe ordering established for phases 2-4

---

### Phase 2: Archive Deprecated FDSM Code [NOT STARTED]

**Goal**: Move deprecated abstract saturation approach from FDSM/ModalSaturation.lean to Boneyard/ with detailed documentation.

**Tasks**:
- [ ] Create `Theories/Boneyard/FDSM_AbstractSaturation/` directory
- [ ] Create archive file with header documentation explaining:
  - What this code was attempting (abstract saturation on untracked histories)
  - Why it was deprecated (cannot construct witnesses without MCS tracking)
  - When it was superseded (Task 825 MCSTrackedHistory approach)
  - No reference to active codebase
- [ ] Extract deprecated `saturation_step` and related code (~300 lines) from ModalSaturation.lean
- [ ] Copy to archive with imports needed to compile standalone
- [ ] Remove deprecated code from ModalSaturation.lean
- [ ] Update any files that imported the removed declarations
- [ ] Run `lake build` to verify no breakage

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/FDSM/ModalSaturation.lean` - Remove deprecated sections
- `Theories/Boneyard/FDSM_AbstractSaturation/AbstractSaturation.lean` - New archive file

**Verification**:
- `lake build` succeeds
- No active code references Boneyard/
- Archived code compiles independently (or is clearly marked as historical)

---

### Phase 3: Archive Blocked FMP Bridge Code [NOT STARTED]

**Goal**: Move blocked validity bridge code from FMP/ConsistentSatisfiable.lean to Boneyard/ with detailed documentation.

**Tasks**:
- [ ] Create `Theories/Boneyard/FMP_ValidityBridge/` directory
- [ ] Create archive file with header documentation explaining:
  - What this code was attempting (bridge from general validity to FMP-internal validity)
  - Why it is blocked (modal/temporal operator truth correspondence architectural limitation)
  - Why the FMP internal proof is sufficient (semantic_weak_completeness is sorry-free internally)
  - No reference to active codebase
- [ ] Extract blocked bridge code (~100 lines, 6 sorries) from ConsistentSatisfiable.lean
- [ ] Copy to archive with necessary context
- [ ] Remove blocked code from ConsistentSatisfiable.lean
- [ ] Update any files that imported the removed declarations
- [ ] Run `lake build` to verify no breakage

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean` - Remove blocked code
- `Theories/Boneyard/FMP_ValidityBridge/ValidityBridge.lean` - New archive file

**Verification**:
- `lake build` succeeds
- No active code references Boneyard/
- Archived code has complete self-contained documentation

---

### Phase 4: Consolidate DeductionTheorem [NOT STARTED]

**Goal**: Eliminate the root-level DeductionTheorem.lean duplication by archiving it and ensuring all code uses Core/DeductionTheorem.lean.

**Tasks**:
- [ ] Compare root-level DeductionTheorem.lean with Core/DeductionTheorem.lean
- [ ] Verify Core/ version is the canonical one (more complete)
- [ ] Create `Theories/Boneyard/Legacy/` directory for small legacy items
- [ ] Archive root-level DeductionTheorem.lean with documentation:
  - Why archived (duplication with Core/DeductionTheorem.lean)
  - What the canonical location is
- [ ] Delete `Theories/Bimodal/Metalogic/DeductionTheorem.lean`
- [ ] Update all imports to use `Bimodal.Metalogic.Core.DeductionTheorem`
- [ ] Run `lake build` to verify no breakage

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/DeductionTheorem.lean` - Delete (after archiving)
- `Theories/Boneyard/Legacy/DeductionTheorem.lean` - New archive file
- Any files importing the root-level version - Update imports

**Verification**:
- `lake build` succeeds
- No file imports `Bimodal.Metalogic.DeductionTheorem` directly
- All use `Bimodal.Metalogic.Core.DeductionTheorem`

---

### Phase 5: Standardize Naming Conventions [NOT STARTED]

**Goal**: Rename theorems and functions for clarity and consistency following the naming scheme identified in research.

**Tasks**:
- [ ] Rename `semantic_weak_completeness` to `fmp_weak_completeness` in FMP/SemanticCanonicalModel.lean
- [ ] Rename `finite_strong_completeness` to `strong_completeness` in Completeness/FiniteStrongCompleteness.lean (if appropriate given context)
- [ ] Update all call sites for renamed definitions
- [ ] Verify no naming conflicts introduced
- [ ] Run `lake build` to verify no breakage

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Rename main theorem
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean` - Evaluate rename
- Any files using renamed definitions - Update references

**Verification**:
- `lake build` succeeds
- Naming is consistent across completeness theorems
- No duplicate names

---

### Phase 6: Create Unified Entry Point [NOT STARTED]

**Goal**: Refactor Metalogic.lean to serve as the main entry point that clearly exposes the five main results: soundness, representation, completeness, compactness, and decidability.

**Tasks**:
- [ ] Rewrite Metalogic.lean with structured module-level documentation
- [ ] Add theorem index table in documentation header:
  ```lean
  /-!
  ## Main Results

  | Theorem | Type | Status |
  |---------|------|--------|
  | soundness | Gamma |- phi -> Gamma |= phi | COMPLETE |
  | bmcs_weak_completeness | bmcs_valid phi -> |- phi | COMPLETE |
  | bmcs_strong_completeness | bmcs_consequence Gamma phi -> Gamma |- phi | COMPLETE |
  | fmp_weak_completeness | fmp_internal_valid phi -> |- phi | COMPLETE |
  | decidability | decidable (|- phi) | PARTIAL |
  -/
  ```
- [ ] Organize imports by category (Core, Soundness, Completeness, Decidability)
- [ ] Add re-exports for main theorems so users can `import Bimodal.Metalogic` and access all main results
- [ ] Run `lake build` to verify no breakage

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Complete rewrite

**Verification**:
- `lake build` succeeds
- Main theorems accessible via single import
- Documentation clearly lists all main results

---

### Phase 7: Cleanup and Final Verification [NOT STARTED]

**Goal**: Ensure clean import graph, verify no Boneyard references in active code, and confirm build passes with same sorry count.

**Tasks**:
- [ ] Grep for any `Boneyard` references in `Theories/Bimodal/Metalogic/` (should be zero)
- [ ] Grep for any historical/comparative comments (remove if found)
- [ ] Verify all Boneyard/ files have self-contained documentation
- [ ] Count sorries before and after (should be unchanged or reduced by archival)
- [ ] Run full `lake build` and verify success
- [ ] Create implementation summary

**Timing**: 1 hour

**Files to verify**:
- All files in `Theories/Bimodal/Metalogic/`
- All files in `Theories/Boneyard/` created by this task

**Verification**:
- Zero references to `Boneyard` in active Metalogic/ code
- Zero historical/comparative comments
- `lake build` succeeds
- Sorry count unchanged or reduced

---

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] No new sorries introduced (compare before/after count)
- [ ] No circular imports created
- [ ] All archived code has complete documentation
- [ ] Main theorems accessible via `import Bimodal.Metalogic`
- [ ] No Boneyard references in active code
- [ ] Algebraic/ directory unchanged

## Artifacts & Outputs

- `specs/818_refactor_bimodal_metalogic_modules/plans/implementation-001.md` (this file)
- `specs/818_refactor_bimodal_metalogic_modules/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- `Theories/Boneyard/FDSM_AbstractSaturation/AbstractSaturation.lean` (archived code)
- `Theories/Boneyard/FMP_ValidityBridge/ValidityBridge.lean` (archived code)
- `Theories/Boneyard/Legacy/DeductionTheorem.lean` (archived code)
- Refactored `Theories/Bimodal/Metalogic/` directory structure

## Rollback/Contingency

If refactoring causes unexpected issues:

1. **Phase-level rollback**: Each phase commits independently. Use `git revert` on specific phase commit if needed.

2. **Full rollback**: If multiple phases fail, use `git reset --hard` to pre-refactoring state (requires user confirmation).

3. **Boneyard recovery**: Archived code remains functional. Can be restored by reversing the move operations.

4. **Import fix**: If circular imports emerge, they can be resolved by reordering imports or introducing intermediate modules.

**Critical note**: Do not delete any working code. Archive to Boneyard/ ensures recovery is always possible.
