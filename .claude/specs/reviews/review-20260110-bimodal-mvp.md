# Code Review Report: Bimodal MVP Readiness

**Date**: 2026-01-10
**Scope**: Bimodal/ and BimodalTest/ directories
**Reviewed by**: Claude

## Summary

- Total files reviewed: 70 (40 Bimodal + 30 BimodalTest)
- Critical issues: 5 (build errors blocking imports)
- High priority issues: 7 (sorries in core modules, missing docs)
- Medium priority issues: 10 (noncomputable markers, API cleanup)
- Low priority issues: 20+ (example sorries, style issues)

## Critical Issues

### 1. ModalS5.lean Build Errors
**File**: `Bimodal/Theorems/ModalS5.lean:63, 203, 379, 514, 621`
**Description**: Multiple definitions fail to compile due to dependency on noncomputable `classical_merge` and `lce_imp` from Propositional.lean without `noncomputable` markers.
**Impact**: Cascading build failures in downstream modules.
**Recommended fix**: Add `noncomputable` prefix to all affected definitions or refactor Propositional.lean to make key lemmas computable.

### 2. Examples Directory Build Failures (~150 errors)
**Files**: All 7 files in `Bimodal/Examples/`
**Description**:
- Incorrect type references (`Derivable.axiom` → should be `DerivationTree.axiom`)
- Missing namespace opens for `imp_trans`, `identity`, `combine_imp_conj`
- Missing `noncomputable` markers for perpetuity-dependent definitions
- References to nonexistent `Automation.ProofSearch.bounded_search` API
**Impact**: Examples cannot be imported; blocks `Bimodal/Examples.lean` and `Bimodal/Bimodal.lean` top-level aggregator.
**Recommended fix**: Task 355 (already researched) addresses this.

### 3. CompletenessTest.lean Invalid Import
**File**: `BimodalTest/Metalogic/CompletenessTest.lean:26`
**Description**: Import statement in wrong location (not at beginning of file).
**Impact**: Test file fails to compile.
**Recommended fix**: Move import to top of file.

### 4. BimodalProofs.lean Cascading Failures
**File**: `Bimodal/Examples/BimodalProofs.lean`
**Description**: 9+ `noncomputable` errors due to dependency on `perpetuity_5` and `perpetuity_6`.
**Impact**: Cannot demonstrate bimodal proof patterns.
**Recommended fix**: Add `noncomputable` markers to all dependent definitions.

### 5. Top-Level Aggregators Broken
**Files**: `Bimodal/Bimodal.lean`, `Bimodal/Metalogic.lean`, `Bimodal/Examples.lean`
**Description**: These aggregate imports fail due to cascading errors from sub-modules.
**Impact**: Cannot import `Bimodal` as a single module.
**Recommended fix**: Fix underlying module errors first.

## High Priority Issues

### 1. Completeness Proof Incomplete
**File**: `Bimodal/Metalogic/Completeness.lean:369`
**Description**: `provable_iff_valid` contains `sorry` - the core completeness theorem is not proven.
**Impact**: Metalogic foundation is incomplete (soundness proven, completeness not).
**Recommended fix**: This is a significant undertaking (70-90 hours estimated). Document as known limitation for MVP, with roadmap for completion.

### 2. SoundnessLemmas Temporal Duality Sorry
**File**: `Bimodal/Metalogic/SoundnessLemmas.lean:687`
**Description**: `temporal_duality` case in axiom soundness has `sorry`.
**Impact**: Soundness proof has one incomplete case.
**Recommended fix**: Complete the temporal duality soundness proof.

### 3. ModalS5 Modal 5 Sorry
**File**: `Bimodal/Theorems/ModalS5.lean:94`
**Description**: Modal 5 theorem (`◇p → □◇p`) has `sorry` due to "blocking dependency".
**Impact**: S5 modal logic is incomplete.
**Recommended fix**: Investigate blocking dependency and complete proof.

### 4. ProofSearch Sorry Placeholders
**File**: `Bimodal/Automation/ProofSearch.lean:726, 731, 736`
**Description**: Three example proof functions use `sorry` placeholders.
**Impact**: Proof search examples don't demonstrate working proofs.
**Recommended fix**: Either complete examples or mark as `#check` demonstrations.

### 5. Missing Top-Level Documentation
**Files**: `Bimodal/README.md`, `BimodalTest/README.md` (missing)
**Description**: No top-level README for either directory.
**Impact**: Users cannot understand project structure.
**Recommended fix**: Task 356 (already researched) addresses this.

### 6. API Inconsistency: Derivable vs DerivationTree
**Files**: Throughout `Bimodal/Examples/`
**Description**: Examples use `Derivable.axiom` pattern that doesn't exist; should be `DerivationTree.axiom`.
**Impact**: Confusing API for users; examples don't compile.
**Recommended fix**: Standardize on `DerivationTree.*` constructors.

### 7. ProofSearch API Not Exported
**Files**: `Bimodal/Examples/*.lean`
**Description**: Examples reference `Automation.ProofSearch.bounded_search` which isn't properly exported.
**Impact**: Users cannot use proof search in the documented way.
**Recommended fix**: Either export ProofSearch API properly or update examples.

## Medium Priority Issues

### 1. Noncomputable Perpetuity Cascade
**Files**: `Bimodal/Theorems/Perpetuity/Principles.lean`, `Bimodal/Theorems/Perpetuity/Bridge.lean`
**Description**: Some perpetuity theorems are marked `noncomputable`, cascading to all dependents.
**Impact**: Prevents evaluation/testing of proof terms.
**Recommended fix**: Investigate if computability can be restored or document as limitation.

### 2. Unused Variables Warnings
**File**: `Bimodal/Automation/ProofSearch.lean:255`
**Description**: Unused variable `ψ` warning.
**Impact**: Code quality issue.
**Recommended fix**: Prefix with underscore or use.

### 3. Deprecated Map Access Pattern
**File**: `Bimodal/Automation/ProofSearch.lean:543`
**Description**: Should use `m[a]?` instead of older access pattern.
**Impact**: Style issue, may cause future deprecation warnings.
**Recommended fix**: Update to modern syntax.

### 4. Example Sorries (Intentional)
**Files**: All Example files (~25 sorries)
**Description**: Many example proofs use `sorry` as pedagogical placeholders.
**Impact**: Examples don't demonstrate complete proofs.
**Recommended fix**: For MVP, clearly document which are exercises vs incomplete. Consider completing high-value examples.

### 5-10. Various Style/Quality Issues
**Files**: Throughout
**Description**: Linter warnings, missing docstrings on some public definitions, inconsistent naming.
**Impact**: Code quality and maintainability.
**Recommended fix**: Address in cleanup phase post-MVP.

## Code Quality Metrics

| Metric | Value | Status |
|--------|-------|--------|
| Sorry count (core modules) | 6 | Warning |
| Sorry count (examples) | ~25 | Info (pedagogical) |
| Axiom count | ~11 | OK |
| Build errors (blocking) | ~150 | Critical |
| Test file errors | 1 | High |
| Missing READMEs | 2 | High |

### Core Module Status

| Module | Status | Notes |
|--------|--------|-------|
| Syntax | ✓ Clean | Formula and Context definitions |
| ProofSystem | ✓ Clean | Axioms and Derivation |
| Semantics | ✓ Clean | Task frames and truth |
| Metalogic/Soundness | ✓ Clean | Fully proven |
| Metalogic/SoundnessLemmas | ⚠ 1 sorry | temporal_duality case |
| Metalogic/Completeness | ⚠ 1 sorry | Infrastructure only |
| Metalogic/DeductionTheorem | ✓ Clean | Fully proven |
| Automation/Tactics | ✓ Clean | Working tactics |
| Automation/ProofSearch | ⚠ 3 sorry | Examples incomplete |
| Theorems/Propositional | ✓ Clean | 8 theorems proven |
| Theorems/ModalS4 | ? Unknown | May have issues |
| Theorems/ModalS5 | ✗ 5 errors | noncomputable cascade |
| Theorems/Perpetuity | ✓ Clean | Fully proven |
| Examples/* | ✗ ~150 errors | Type/namespace issues |

## MVP Readiness Assessment

### Ready for MVP
- Syntax layer (Formula, Context)
- ProofSystem (Axioms, Derivation)
- Semantics (TaskFrame, Truth, Validity)
- Soundness proofs (12/12 axioms, 8/8 rules)
- Deduction theorem
- Propositional theorems
- Perpetuity principles (P1-P6)
- Basic proof search infrastructure
- Core tactics

### Blocking MVP
1. **~150 build errors in Examples/** - Users cannot see working examples
2. **Missing documentation** - Users cannot navigate project
3. **ModalS5 build failures** - Important modal theorems unavailable

### Nice-to-Have for MVP
- Complete soundness (temporal_duality case)
- Modal 5 theorem
- ProofSearch examples working
- Completeness proof (long-term)

## Recommendations

### Immediate Actions (Required for MVP)

1. **Fix build errors (Task 355)** - Already researched, estimated 1-2 hours
   - Replace `Derivable.*` → `DerivationTree.*`
   - Add missing namespace opens
   - Add `noncomputable` markers
   - Update/remove broken ProofSearch references

2. **Fix ModalS5 noncomputable cascade** - ~30 minutes
   - Add `noncomputable` to dependent definitions

3. **Fix CompletenessTest import** - 5 minutes
   - Move import to file beginning

4. **Create documentation (Task 356)** - Already researched, ~2-4 hours
   - Bimodal/README.md
   - BimodalTest/README.md

### Secondary Actions (Strengthen MVP)

5. **Complete temporal_duality soundness** - ~1-2 hours
   - Remove last sorry from soundness proofs

6. **Document known limitations** - 30 minutes
   - Add "Implementation Status" sections to README
   - Document that completeness is infrastructure only
   - Document modal 5 blocking dependency

### Deferred Actions (Post-MVP)

7. Complete Modal 5 theorem
8. Complete ProofSearch examples
9. Complete examples with remaining sorries
10. Implement completeness proof (70-90 hours)
11. Style cleanup and linter fixes

## Tasks to Create

Based on this review, the following tasks should be created:

### Already Exist (Continue)
- **Task 355**: Fix Bimodal build errors (RESEARCHED) - PRIORITY: CRITICAL
- **Task 356**: Create Bimodal documentation (RESEARCHED) - PRIORITY: HIGH

### New Tasks Needed
- **Task 357**: Fix ModalS5.lean noncomputable cascade - PRIORITY: CRITICAL
- **Task 358**: Fix CompletenessTest.lean import error - PRIORITY: HIGH
- **Task 359**: Complete temporal_duality soundness case - PRIORITY: MEDIUM
- **Task 360**: Create MVP status documentation - PRIORITY: MEDIUM
