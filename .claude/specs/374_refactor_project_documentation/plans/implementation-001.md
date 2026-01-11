# Implementation Plan: Task #374

**Task**: Refactor project Documentation to theory-specific directories
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Move theory-specific documentation from ProofChecker/Documentation/ to the appropriate
theory directories (Logos/Documentation/ or Bimodal/Documentation/), leaving only
project-wide documentation in the root Documentation/ directory. This follows the
"Move with Links" approach recommended in the research report.

## Phases

### Phase 1: Create Target Directory Structure

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create Research/ directories in theory Documentation folders
2. Ensure all target directories exist before file moves

**Files to create**:
- `Logos/Documentation/Research/` - new directory
- `Bimodal/Documentation/Research/` - new directory

**Steps**:
1. Create Logos/Documentation/Research/ directory
2. Create Bimodal/Documentation/Research/ directory
3. Verify both directories exist

**Verification**:
- `ls -la Logos/Documentation/Research/` succeeds
- `ls -la Bimodal/Documentation/Research/` succeeds

---

### Phase 2: Move Logos-Specific Files

**Estimated effort**: 30 minutes
**Status**: [IN PROGRESS]

**Objectives**:
1. Move 5 Logos-specific files to Logos/Documentation/
2. Preserve git history with `git mv`

**Files to move**:
- `Documentation/Research/RECURSIVE_SEMANTICS.md` → `Logos/Documentation/Research/`
- `Documentation/Research/LAYER_EXTENSIONS.md` → `Logos/Documentation/Research/`
- `Documentation/Research/CONCEPTUAL_ENGINEERING.md` → `Logos/Documentation/Research/`
- `Documentation/UserGuide/METHODOLOGY.md` → `Logos/Documentation/UserGuide/`
- `Documentation/Reference/GLOSSARY.md` → `Logos/Documentation/Reference/`

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
**Status**: [NOT STARTED]

**Objectives**:
1. Move 13 Bimodal-specific files to Bimodal/Documentation/
2. Preserve git history with `git mv`

**Files to move**:
- `Documentation/Research/MODAL_TEMPORAL_PROOF_SEARCH.md` → `Bimodal/Documentation/Research/`
- `Documentation/Research/temporal-logic-automation-research.md` → `Bimodal/Documentation/Research/`
- `Documentation/Research/PROOF_SEARCH_AUTOMATION.md` → `Bimodal/Documentation/Research/`
- `Documentation/Research/leansearch-best-first-search.md` → `Bimodal/Documentation/Research/`
- `Documentation/Research/leansearch-priority-queue.md` → `Bimodal/Documentation/Research/`
- `Documentation/Research/leansearch-proof-caching-memoization.md` → `Bimodal/Documentation/Research/`
- `Documentation/Research/LEANSEARCH_API_SPECIFICATION.md` → `Bimodal/Documentation/Research/`
- `Documentation/UserGuide/ARCHITECTURE.md` → `Bimodal/Documentation/UserGuide/`
- `Documentation/UserGuide/TUTORIAL.md` → `Bimodal/Documentation/UserGuide/`
- `Documentation/UserGuide/EXAMPLES.md` → `Bimodal/Documentation/UserGuide/`
- `Documentation/UserGuide/TACTIC_DEVELOPMENT.md` → `Bimodal/Documentation/UserGuide/`
- `Documentation/Reference/OPERATORS.md` → `Bimodal/Documentation/Reference/`
- `Documentation/ProjectInfo/TACTIC_REGISTRY.md` → `Bimodal/Documentation/ProjectInfo/`

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
**Status**: [NOT STARTED]

**Objectives**:
1. Fix relative links in moved files pointing to other Documentation/ files
2. Fix links in remaining Documentation/ files pointing to moved files
3. Update theory README.md files with Research/ sections

**Files to modify**:
- All moved files (18 total) - update relative path links
- `Logos/Documentation/README.md` - add Research/ section
- `Bimodal/Documentation/README.md` - add Research/ section
- `Documentation/Research/README.md` - update to reference theory-specific research
- `Documentation/UserGuide/README.md` - remove moved files
- `Documentation/Reference/README.md` - remove moved files
- `Documentation/ProjectInfo/README.md` - remove TACTIC_REGISTRY reference

**Steps**:
1. Update Logos/Documentation/README.md with Research/ directory listing
2. Update Bimodal/Documentation/README.md with Research/ directory listing
3. Update Documentation/Research/README.md to point to theory research
4. Create Logos/Documentation/Research/README.md
5. Create Bimodal/Documentation/Research/README.md
6. Fix cross-references in moved files (grep for broken links)
7. Update remaining README.md files

**Verification**:
- `grep -r "Documentation/Research/RECURSIVE" .` returns no hits in Documentation/
- `grep -r "Documentation/UserGuide/ARCHITECTURE" .` returns no hits in Documentation/
- All README.md files have correct links

---

### Phase 5: Update Root Documentation/README.md

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Simplify Documentation/README.md to focus on project-wide content
2. Remove references to moved files
3. Add clear pointers to theory-specific documentation

**Files to modify**:
- `Documentation/README.md` - simplify and update
- `Documentation/UserGuide/README.md` - update file listing

**Steps**:
1. Update Documentation/README.md overview section
2. Remove moved files from UserGuide section
3. Update Research section to point to theory research
4. Remove moved files from Reference section
5. Update ProjectInfo section
6. Verify all remaining links work

**Verification**:
- Documentation/README.md contains no broken links
- All listed files exist

---

### Phase 6: Final Verification and Cleanup

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

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
- `find Documentation/ -type d -empty` returns nothing
- All moved files are accessible from their new locations
- Git commit succeeds

## Dependencies

- Task 360: Created Bimodal/Documentation/ (COMPLETED)
- Task 372: Created Logos/Documentation/ (COMPLETED)
- Documentation_OLD/ backup exists (user-created)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken links in moved files | Medium | High | Systematic grep for all cross-references |
| Broken external links | Low | Low | Focus on internal links; external links preserved |
| Git history loss | Medium | Low | Use `git mv` to preserve history |
| Missing backup | High | Low | User confirmed Documentation_OLD/ exists |

## Success Criteria

- [ ] All 5 Logos-specific files moved to Logos/Documentation/
- [ ] All 13 Bimodal-specific files moved to Bimodal/Documentation/
- [ ] All cross-references updated and working
- [ ] Logos/Documentation/README.md includes Research/ section
- [ ] Bimodal/Documentation/README.md includes Research/ section
- [ ] Documentation/README.md simplified to project-wide content
- [ ] No broken internal links

## Rollback Plan

1. If issues discovered during implementation:
   - `git checkout HEAD -- Documentation/` to restore moved files
   - `git checkout HEAD -- Logos/Documentation/` to restore original state
   - `git checkout HEAD -- Bimodal/Documentation/` to restore original state

2. If issues discovered after commit:
   - Restore from Documentation_OLD/ backup
   - Create new commit with restored files
