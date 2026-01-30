# Implementation Plan: Task #772

- **Task**: 772 - Refactor Metalogic for sorry-free archive sorried proofs
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Priority**: high
- **Dependencies**: None (Task 769 already deprecated all sorried code)
- **Research Inputs**: specs/772_refactor_metalogic_sorry_free_archive_sorried_proofs/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Archive 20 sorried proofs from Metalogic/ to Boneyard/Metalogic_v4/ while preserving the sorry-free `semantic_weak_completeness` as the canonical completeness theorem. The refactoring moves 3 files entirely (TaskRelation.lean, CoherentConstruction.lean, TruthLemma.lean) and removes sorried theorems from 2 files (SemanticCanonicalModel.lean, FiniteModelProperty.lean). WeakCompleteness.lean is updated to export `semantic_weak_completeness` as the primary completeness result.

### Research Integration

- **Key Finding**: `semantic_weak_completeness` in FMP/SemanticCanonicalModel.lean is completely sorry-free and provides the main completeness result via contrapositive
- **Architecture Insight**: The representation theorem approach fails due to S5-style Box semantics requiring universal quantification over ALL histories
- **Risk Mitigation**: All 20 sorries are already marked DEPRECATED by Task 769, making the refactoring low-risk

## Goals & Non-Goals

**Goals**:
- Zero sorry count in Theories/Bimodal/Metalogic/ (excluding Boneyard/, Examples/)
- Preserve `semantic_weak_completeness` as the canonical completeness theorem
- Archive sorried files to Boneyard/Metalogic_v4/ with documentation
- Ensure `lake build` passes after each phase

**Non-Goals**:
- Proving the sorried theorems (architecturally impossible per research)
- Changing the semantic approach to completeness
- Modifying Core/, Soundness/, or other sorry-free modules

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import chain breakage | High | Medium | Verify dependencies before moving files, update imports incrementally |
| Downstream code relying on moved APIs | Medium | Low | Check for references to archived theorems before removal |
| Build failures | High | Low | Run `lake build` after each phase, rollback if needed |

## Implementation Phases

### Phase 1: Create Boneyard Archive Structure [COMPLETED]

**Goal**: Set up Boneyard/Metalogic_v4/ directory with documentation files for the 3 files being archived

**Estimated effort**: 30 minutes

**Objectives**:
1. Create Boneyard/Metalogic_v4/ directory structure
2. Archive TaskRelation.lean with documentation header
3. Archive CoherentConstruction.lean with documentation header
4. Archive TruthLemma.lean with documentation header

**Files to create**:
- `Theories/Bimodal/Boneyard/Metalogic_v4/TaskRelation.lean` - Archived with why-sorried documentation
- `Theories/Bimodal/Boneyard/Metalogic_v4/CoherentConstruction.lean` - Archived with why-sorried documentation
- `Theories/Bimodal/Boneyard/Metalogic_v4/TruthLemma.lean` - Archived with why-sorried documentation
- `Theories/Bimodal/Boneyard/Metalogic_v4/README.md` - Archive documentation explaining the representation theorem approach failure

**Steps**:
1. Create `Theories/Bimodal/Boneyard/Metalogic_v4/` directory
2. Copy `Representation/TaskRelation.lean` to Boneyard with header explaining 5 sorries (cross-sign duration composition)
3. Copy `Representation/CoherentConstruction.lean` to Boneyard with header explaining 8 sorries (cross-origin coherence)
4. Copy `Representation/TruthLemma.lean` to Boneyard with header explaining 4 sorries (box/temporal backward directions)
5. Create README.md explaining why the representation theorem approach was abandoned

**Verification**:
- All 3 files exist in Boneyard/Metalogic_v4/
- Each archived file has a documentation header explaining why the sorries are unprovable
- README.md documents the architectural limitation (S5-style Box semantics)

---

### Phase 2: Remove Archived Files from Representation/ [COMPLETED]

**Goal**: Delete the sorried files from Representation/ and update module imports

**Estimated effort**: 30 minutes

**Objectives**:
1. Delete TaskRelation.lean from Representation/
2. Delete CoherentConstruction.lean from Representation/
3. Delete TruthLemma.lean from Representation/
4. Update Representation module imports

**Files to delete**:
- `Theories/Bimodal/Metalogic/Representation/TaskRelation.lean`
- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation.lean` - Remove imports for deleted files

**Steps**:
1. Read Representation.lean to understand current import structure
2. Remove imports for TaskRelation, CoherentConstruction, TruthLemma
3. Delete the 3 sorried files using git rm
4. Run `lake build Theories.Bimodal.Metalogic.Representation` to check for breakage

**Verification**:
- The 3 files no longer exist in Representation/
- Representation.lean compiles without errors
- Check for broken imports in files that depended on deleted modules

---

### Phase 3: Update UniversalCanonicalModel.lean [NOT STARTED]

**Goal**: Remove dependency on CoherentConstruction and archived files

**Estimated effort**: 30 minutes

**Objectives**:
1. Analyze UniversalCanonicalModel.lean imports and dependencies
2. Remove or update references to archived theorems
3. Ensure the file compiles without sorried dependencies

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` - Remove imports and references to archived files

**Steps**:
1. Read UniversalCanonicalModel.lean to identify all references to archived files
2. Determine which definitions/theorems can be kept vs removed
3. Update or remove the CoherentConstruction dependency
4. If the file becomes empty or has no useful sorry-free content, consider archiving it too
5. Run `lake build` to verify compilation

**Verification**:
- UniversalCanonicalModel.lean compiles without importing archived files
- No sorries introduced by the changes
- All remaining content is sorry-free

---

### Phase 4: Clean SemanticCanonicalModel.lean [NOT STARTED]

**Goal**: Remove the 2 sorried theorems while preserving `semantic_weak_completeness`

**Estimated effort**: 30 minutes

**Objectives**:
1. Remove `SemanticCanonicalFrame.compositionality` (sorry at line 231)
2. Remove `truth_at_implies_semantic_truth` (sorry at line 693)
3. Preserve `semantic_weak_completeness` and all its sorry-free dependencies

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Remove sorried theorems

**Steps**:
1. Read SemanticCanonicalModel.lean to identify the 2 sorried theorems
2. Check if any sorry-free code depends on the sorried theorems
3. Remove `compositionality` and `truth_at_implies_semantic_truth`
4. Verify `semantic_weak_completeness` still compiles
5. Run `lake build` to verify

**Verification**:
- `semantic_weak_completeness` compiles without errors
- No sorries remain in SemanticCanonicalModel.lean
- All sorry-free theorems are preserved

---

### Phase 5: Clean FiniteModelProperty.lean [NOT STARTED]

**Goal**: Remove the sorried `finite_model_property_constructive` theorem

**Estimated effort**: 20 minutes

**Objectives**:
1. Remove `finite_model_property_constructive` (sorry at line 233)
2. Preserve any sorry-free content
3. Ensure the file compiles without errors

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean` - Remove sorried theorem

**Steps**:
1. Read FiniteModelProperty.lean to understand its structure
2. Identify the sorried theorem and any dependencies
3. Remove `finite_model_property_constructive`
4. Verify remaining content compiles
5. Run `lake build` to verify

**Verification**:
- No sorries remain in FiniteModelProperty.lean
- File compiles without errors
- Any sorry-free lemmas are preserved

---

### Phase 6: Update WeakCompleteness.lean [NOT STARTED]

**Goal**: Use `semantic_weak_completeness` as the primary completeness theorem

**Estimated effort**: 30 minutes

**Objectives**:
1. Update imports to use FMP/SemanticCanonicalModel instead of representation_theorem
2. Export `semantic_weak_completeness` as `weak_completeness` or similar
3. Remove any references to archived representation theorem code

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` - Switch to semantic_weak_completeness

**Steps**:
1. Read WeakCompleteness.lean to understand current implementation
2. Update imports to include SemanticCanonicalModel
3. Create a wrapper or alias for `semantic_weak_completeness`
4. Remove unused imports for archived files
5. Run `lake build` to verify

**Verification**:
- WeakCompleteness.lean exports a sorry-free completeness theorem
- No sorries in the file
- Downstream code can use the completeness theorem

---

### Phase 7: Update Metalogic Module Imports [NOT STARTED]

**Goal**: Update top-level Metalogic.lean imports and verify final sorry count

**Estimated effort**: 30 minutes

**Objectives**:
1. Update Metalogic.lean to remove imports of archived files
2. Run final `lake build` for the full project
3. Verify zero sorry count in Metalogic/ (excluding Boneyard/, Examples/)

**Files to modify**:
- `Theories/Bimodal/Metalogic.lean` - Update module imports

**Steps**:
1. Read Metalogic.lean to identify all imports
2. Remove imports for archived files (TaskRelation, CoherentConstruction, TruthLemma)
3. Ensure all sorry-free modules are still imported
4. Run `lake build` for full project
5. Run sorry count verification: `grep -r "sorry" Theories/Bimodal/Metalogic/ --include="*.lean" | grep -v Boneyard | grep -v Examples`
6. Document results

**Verification**:
- Full project builds without errors
- Zero sorries in Metalogic/ (excluding Boneyard/, Examples/)
- All sorry-free theorems accessible from Metalogic module

## Testing & Validation

- [ ] `lake build` passes after each phase
- [ ] Zero sorry count in `Theories/Bimodal/Metalogic/` (excluding Boneyard/, Examples/)
- [ ] `semantic_weak_completeness` accessible from Metalogic module
- [ ] All archived files have documentation explaining why sorries are unprovable
- [ ] No broken imports in downstream code

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/Metalogic_v4/TaskRelation.lean` - Archived with documentation
- `Theories/Bimodal/Boneyard/Metalogic_v4/CoherentConstruction.lean` - Archived with documentation
- `Theories/Bimodal/Boneyard/Metalogic_v4/TruthLemma.lean` - Archived with documentation
- `Theories/Bimodal/Boneyard/Metalogic_v4/README.md` - Archive documentation
- Updated `Theories/Bimodal/Metalogic/` with zero sorries

## Rollback/Contingency

If any phase fails:
1. Use `git checkout` to restore deleted files
2. Revert import changes
3. Document the failure in error report
4. Consider partial completion (archive some files, keep others)

Git provides full rollback capability since all changes are file deletions, moves, and edits.
