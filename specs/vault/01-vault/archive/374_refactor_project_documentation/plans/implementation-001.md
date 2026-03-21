# Implementation Plan: Task #374

**Task**: Refactor project Documentation to theory-specific directories
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Move theory-specific documentation from ProofChecker/docs/ to the appropriate
theory directories (Logos/docs/ or Bimodal/docs/), leaving only
project-wide documentation in the root docs/ directory. This follows the
"Move with Links" approach recommended in the research report.

## Phases

### Phase 1: Create Target Directory Structure

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create Research/ directories in theory Documentation folders
2. Ensure all target directories exist before file moves

**Files to create**:
- `Logos/docs/research/` - new directory
- `Bimodal/docs/research/` - new directory

**Steps**:
1. Create Logos/docs/research/ directory
2. Create Bimodal/docs/research/ directory
3. Verify both directories exist

**Verification**:
- `ls -la Logos/docs/research/` succeeds
- `ls -la Bimodal/docs/research/` succeeds

---

### Phase 2: Move Logos-Specific Files

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Move 5 Logos-specific files to Logos/docs/
2. Preserve git history with `git mv`

**Files to move**:
- `docs/research/RECURSIVE_SEMANTICS.md` → `Logos/docs/research/`
- `docs/research/LAYER_EXTENSIONS.md` → `Logos/docs/research/`
- `docs/research/CONCEPTUAL_ENGINEERING.md` → `Logos/docs/research/`
- `docs/user-guide/METHODOLOGY.md` → `Logos/docs/user-guide/`
- `docs/reference/GLOSSARY.md` → `Logos/docs/reference/`

**Steps**:
1. Move Research files (3 files)
2. Move UserGuide file (1 file)
3. Move Reference file (1 file)
4. Stage all changes

**Verification**:
- All 5 files exist in their new locations
- `git status` shows renamed files

---

### Phase 3: Move Bimodal-Specific Files

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Move 13 Bimodal-specific files to Bimodal/docs/
2. Preserve git history with `git mv`

**Files to move**:
- `docs/research/MODAL_TEMPORAL_PROOF_SEARCH.md` → `Bimodal/docs/research/`
- `docs/research/temporal-logic-automation-research.md` → `Bimodal/docs/research/`
- `docs/research/PROOF_SEARCH_AUTOMATION.md` → `Bimodal/docs/research/`
- `docs/research/leansearch-best-first-search.md` → `Bimodal/docs/research/`
- `docs/research/leansearch-priority-queue.md` → `Bimodal/docs/research/`
- `docs/research/leansearch-proof-caching-memoization.md` → `Bimodal/docs/research/`
- `docs/research/LEANSEARCH_API_SPECIFICATION.md` → `Bimodal/docs/research/`
- `docs/user-guide/ARCHITECTURE.md` → `Bimodal/docs/user-guide/`
- `docs/user-guide/TUTORIAL.md` → `Bimodal/docs/user-guide/`
- `docs/user-guide/EXAMPLES.md` → `Bimodal/docs/user-guide/`
- `docs/user-guide/TACTIC_DEVELOPMENT.md` → `Bimodal/docs/user-guide/`
- `docs/reference/OPERATORS.md` → `Bimodal/docs/reference/`
- `docs/project-info/TACTIC_REGISTRY.md` → `Bimodal/docs/project-info/`

**Steps**:
1. Move Research files (7 files)
2. Move UserGuide files (4 files)
3. Move Reference file (1 file)
4. Move ProjectInfo file (1 file)
5. Stage all changes

**Verification**:
- All 13 files exist in their new locations
- `git status` shows renamed files

---

### Phase 4: Update Internal Cross-References

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Fix relative links in moved files pointing to other docs/ files
2. Fix links in remaining docs/ files pointing to moved files
3. Update theory README.md files with Research/ sections

**Files to modify**:
- All moved files (18 total) - update relative path links
- `Logos/docs/README.md` - add Research/ section
- `Bimodal/docs/README.md` - add Research/ section
- `docs/research/README.md` - update to reference theory-specific research
- `docs/user-guide/README.md` - remove moved files
- `docs/reference/README.md` - remove moved files
- `docs/project-info/README.md` - remove TACTIC_REGISTRY reference

**Steps**:
1. Update Logos/docs/README.md with Research/ directory listing
2. Update Bimodal/docs/README.md with Research/ directory listing
3. Update docs/research/README.md to point to theory research
4. Create Logos/docs/research/README.md
5. Create Bimodal/docs/research/README.md
6. Fix cross-references in moved files (grep for broken links)
7. Update remaining README.md files

**Verification**:
- `grep -r "docs/research/RECURSIVE" .` returns no hits in docs/
- `grep -r "docs/user-guide/ARCHITECTURE" .` returns no hits in docs/
- All README.md files have correct links

---

### Phase 5: Update Root docs/README.md

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Simplify docs/README.md to focus on project-wide content
2. Remove references to moved files
3. Add clear pointers to theory-specific documentation

**Files to modify**:
- `docs/README.md` - simplify and update
- `docs/user-guide/README.md` - update file listing

**Steps**:
1. Update docs/README.md overview section
2. Remove moved files from UserGuide section
3. Update Research section to point to theory research
4. Remove moved files from Reference section
5. Update ProjectInfo section
6. Verify all remaining links work

**Verification**:
- docs/README.md contains no broken links
- All listed files exist

---

### Phase 6: Final Verification and Cleanup

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify no broken links across the project
2. Clean up any empty directories
3. Commit all changes

**Steps**:
1. Run link verification check
2. Verify Documentation_OLD/ backup is preserved (user-created)
3. Review git diff for unexpected changes
4. Create final commit

**Verification**:
- `find docs/ -type d -empty` returns nothing
- All moved files are accessible from their new locations
- Git commit succeeds

## Dependencies

- Task 360: Created Bimodal/docs/ (COMPLETED)
- Task 372: Created Logos/docs/ (COMPLETED)
- Documentation_OLD/ backup exists (user-created)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken links in moved files | Medium | High | Systematic grep for all cross-references |
| Broken external links | Low | Low | Focus on internal links; external links preserved |
| Git history loss | Medium | Low | Use `git mv` to preserve history |
| Missing backup | High | Low | User confirmed Documentation_OLD/ exists |

## Success Criteria

- [ ] All 5 Logos-specific files moved to Logos/docs/
- [ ] All 13 Bimodal-specific files moved to Bimodal/docs/
- [ ] All cross-references updated and working
- [ ] Logos/docs/README.md includes Research/ section
- [ ] Bimodal/docs/README.md includes Research/ section
- [ ] docs/README.md simplified to project-wide content
- [ ] No broken internal links

## Rollback Plan

1. If issues discovered during implementation:
   - `git checkout HEAD -- docs/` to restore moved files
   - `git checkout HEAD -- Logos/docs/` to restore original state
   - `git checkout HEAD -- Bimodal/docs/` to restore original state

2. If issues discovered after commit:
   - Restore from Documentation_OLD/ backup
   - Create new commit with restored files
