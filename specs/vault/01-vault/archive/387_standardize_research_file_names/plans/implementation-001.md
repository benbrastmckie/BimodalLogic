# Implementation Plan: Task #387

**Task**: Standardize Research/ file names and fix references
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Rename 15 research documentation files from inconsistent naming (ALL_CAPS and mixed lowercase-hyphenated) to consistent lowercase-hyphenated format. Update all active references across the codebase to prevent broken links. Skip archive directories to preserve historical accuracy.

## Phases

### Phase 1: Rename docs/Research/ files

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Rename 5 files in docs/Research/ to lowercase-hyphenated format
2. Remove redundant "-research" suffixes from 2 files
3. Preserve git history using `git mv`

**Files to modify**:
- `docs/Research/DUAL_VERIFICATION.md` → `dual-verification.md`
- `docs/Research/PROOF_LIBRARY_DESIGN.md` → `proof-library-design.md`
- `docs/Research/THEORY_COMPARISON.md` → `theory-comparison.md`
- `docs/Research/deduction-theorem-necessity-research.md` → `deduction-theorem-necessity.md`
- `docs/Research/noncomputable-research.md` → `noncomputable.md`

**Steps**:
1. Run `git mv` for each file rename
2. Verify files renamed correctly with `ls -la`

**Verification**:
- All 5 files renamed successfully
- `git status` shows renames (not delete+add)

---

### Phase 2: Rename Theories/Logos/docs/Research/ files

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Rename 3 files in Logos research directory

**Files to modify**:
- `Theories/Logos/docs/Research/CONCEPTUAL_ENGINEERING.md` → `conceptual-engineering.md`
- `Theories/Logos/docs/Research/LAYER_EXTENSIONS.md` → `layer-extensions.md`
- `Theories/Logos/docs/Research/RECURSIVE_SEMANTICS.md` → `recursive-semantics.md`

**Steps**:
1. Run `git mv` for each file rename
2. Verify files renamed correctly

**Verification**:
- All 3 files renamed successfully
- `git status` shows renames

---

### Phase 3: Rename Theories/Bimodal/docs/Research/ files

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Rename 4 files in Bimodal research directory (3 ALL_CAPS + 1 redundant suffix)

**Files to modify**:
- `Theories/Bimodal/docs/Research/LEANSEARCH_API_SPECIFICATION.md` → `leansearch-api-specification.md`
- `Theories/Bimodal/docs/Research/MODAL_TEMPORAL_PROOF_SEARCH.md` → `modal-temporal-proof-search.md`
- `Theories/Bimodal/docs/Research/PROOF_SEARCH_AUTOMATION.md` → `proof-search-automation.md`
- `Theories/Bimodal/docs/Research/temporal-logic-automation-research.md` → `temporal-logic-automation.md`

**Steps**:
1. Run `git mv` for each file rename
2. Verify files renamed correctly

**Verification**:
- All 4 files renamed successfully
- `git status` shows renames

---

### Phase 4: Update references in active documentation

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Update all references in README.md (project root)
2. Update references in docs/Research/README.md
3. Update references in Theories/*/docs/**/*.md
4. Update references in Theories/*/*.lean doc comments

**Files to modify**:
- `README.md` - ~12 references
- `docs/Research/README.md` - ~18 references
- `docs/README.md` - cross-references
- `Theories/Logos/README.md` - theory comparison links
- `Theories/Logos/docs/README.md`
- `Theories/Logos/docs/Research/README.md`
- `Theories/Logos/docs/**/*.md` - various references
- `Theories/Logos/SubTheories/*.lean` - doc comments
- `Theories/Bimodal/README.md`
- `Theories/Bimodal/docs/README.md`
- `Theories/Bimodal/docs/Research/README.md`
- `Theories/Bimodal/docs/**/*.md`

**Steps**:
1. Use grep to find all references to renamed files in active directories
2. Update each reference using Edit tool with replace_all where appropriate
3. Focus on directories: README.md, docs/, Theories/

**Verification**:
- Grep for old file names returns no hits in active directories
- All links in README files work correctly

---

### Phase 5: Verify and commit

**Estimated effort**: 10 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify no broken links in active documentation
2. Commit all changes with descriptive message

**Steps**:
1. Run grep for each old filename pattern to verify no remaining references
2. Run `git status` to review all changes
3. Commit with message format: "task 387 phase 5: complete file standardization"

**Verification**:
- No grep hits for old ALL_CAPS filenames in docs/ or Theories/
- Git commit successful
- Build still works (if applicable)

---

## Dependencies

- None - this is a standalone documentation task

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Missed reference causes broken link | Low | Medium | Thorough grep verification before commit |
| Archive references updated accidentally | Low | Low | Explicit exclusion of archive/ directories |
| Git history lost for renames | Low | Low | Use `git mv` instead of delete+create |

## Success Criteria

- [ ] 15 files renamed to lowercase-hyphenated format
- [ ] All active documentation references updated
- [ ] No broken links in README.md, docs/, Theories/
- [ ] Archive directories unchanged
- [ ] Git history preserved for renamed files

## Rollback Plan

If issues discovered post-implementation:
1. `git revert HEAD` to undo commit
2. Files will return to original names
3. References will return to original values
