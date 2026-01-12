# Implementation Plan: Task #378

**Task**: Refactor Documentation structure with directory standards
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Refactor the docs/ directory to eliminate broken links, reduce redundancy, and ensure
compliance with DIRECTORY_README_STANDARD.md. The main tasks are: (1) merge NAVIGATION.md into
README.md, (2) update subdirectory READMEs, (3) consolidate UserGuide/ and Reference/, and
(4) delete stale files.

## Phases

### Phase 1: Merge NAVIGATION.md into README.md

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Objectives**:
1. Create unified navigation hub following Template G
2. Preserve useful content from NAVIGATION.md (use-case navigation)
3. Remove broken links to non-existent files
4. Delete NAVIGATION.md after merge

**Files to modify**:
- `docs/README.md` - Rewrite as comprehensive navigation hub
- `docs/NAVIGATION.md` - Delete after content merged

**Steps**:
1. Read both README.md and NAVIGATION.md completely
2. Identify unique valuable content in NAVIGATION.md:
   - Use-case navigation ("I want to..." sections)
   - Theory-specific documentation tables
   - Command reference (if still valid)
3. Create new README.md structure following Template G:
   - Brief purpose statement
   - Theory-specific documentation links (Bimodal, Logos)
   - Documentation organization by directory
   - Quick links for different audiences
   - Documentation update workflow
   - Documentation standards
4. Update all internal links to point to existing files only
5. Remove references to non-existent files (found in research)
6. Delete NAVIGATION.md
7. Verify no other files reference NAVIGATION.md

**Verification**:
- README.md follows Template G structure
- No broken links in README.md
- NAVIGATION.md deleted
- All existing directory READMEs are linked

---

### Phase 2: Update Subdirectory READMEs

**Estimated effort**: 2 hours
**Status**: [COMPLETED]

**Objectives**:
1. Fix broken links in each subdirectory README
2. Update reading orders and file references
3. Ensure compliance with DIRECTORY_README_STANDARD.md templates

**Files to modify**:
- `docs/architecture/README.md` - Add audience guidance
- `docs/development/README.md` - Update any stale links
- `docs/installation/README.md` - Verify links
- `docs/project-info/README.md` - Remove TACTIC_REGISTRY.md reference
- `docs/reference/README.md` - Remove GLOSSARY.md, OPERATORS.md references
- `docs/research/README.md` - Update navigation links
- `docs/user-guide/README.md` - Remove references to missing files

**Steps**:
1. **Architecture/README.md**:
   - Add audience guidance (developers, maintainers)
   - Verify ADR links are valid
2. **Development/README.md**:
   - Verify all 12 file references exist
   - Keep structure (already good)
3. **Installation/README.md**:
   - Verify all 4 file references exist
   - Keep structure (already good)
4. **ProjectInfo/README.md**:
   - Remove reference to TACTIC_REGISTRY.md (doesn't exist)
   - Update Five-Document Model to four documents
   - Verify remaining file references
5. **Reference/README.md**:
   - Remove GLOSSARY.md and OPERATORS.md references
   - Update to reflect only API_REFERENCE.md exists
   - Add cross-links to theory-specific Reference/ directories
6. **Research/README.md**:
   - Verify all research file references exist
   - Update cross-links if needed
7. **UserGuide/README.md**:
   - Remove references to TUTORIAL.md, EXAMPLES.md, METHODOLOGY.md, ARCHITECTURE.md,
     TACTIC_DEVELOPMENT.md (all moved to theory directories)
   - Update to reflect only INTEGRATION.md and MCP_INTEGRATION.md remain
   - Add prominent cross-links to theory-specific UserGuide/ directories

**Verification**:
- No broken links in any subdirectory README
- Each README follows appropriate template
- Clear audience guidance in each

---

### Phase 3: Consolidate UserGuide/ and Reference/

**Estimated effort**: 1.5 hours
**Status**: [COMPLETED]

**Decision**: Keep both directories with their current content:
- UserGuide/ has legitimate project-wide integration docs (INTEGRATION.md, MCP_INTEGRATION.md)
- Reference/ has project-wide API reference (API_REFERENCE.md)
- Both READMEs updated in Phase 2 with proper theory-specific cross-links

**Objectives**:
1. Decide whether to keep or remove nearly-empty directories
2. Move remaining files if appropriate
3. Update all cross-references

**Files to evaluate**:
- `docs/user-guide/INTEGRATION.md` - Project-wide, keep
- `docs/user-guide/MCP_INTEGRATION.md` - Project-wide, keep
- `docs/reference/API_REFERENCE.md` - Project-wide, keep

**Steps**:
1. Review remaining files in UserGuide/:
   - INTEGRATION.md (13KB) - model checker integration, project-wide
   - MCP_INTEGRATION.md (16KB) - MCP server integration, project-wide
   Both are legitimate project-wide documentation. **Keep UserGuide/ directory**.
2. Review remaining files in Reference/:
   - API_REFERENCE.md (18KB) - Logos API reference
   Consider: This references Logos specifically. Should move to Logos/docs/reference/
3. Decision: **Keep UserGuide/, move API_REFERENCE.md to Logos/docs/reference/**
4. Update UserGuide/README.md to be a thin directory with clear cross-links
5. Update Reference/README.md to redirect to theory-specific references
6. Move API_REFERENCE.md to Logos/docs/reference/
7. Update any files that reference the moved file
8. If Reference/ becomes empty (only README.md), consider removing directory

**Verification**:
- UserGuide/ has clear purpose (project-wide integration guides)
- Reference/ either has content or is removed
- All cross-references updated

---

### Phase 4: Clean Up Stale Files

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Delete files that are no longer relevant
2. Verify no orphaned references

**Files to delete**:
- `docs/research/RESEARCH_SUMMARY.md` - References moved file

**Steps**:
1. Delete RESEARCH_SUMMARY.md (references Bimodal research file)
2. Check if any files reference RESEARCH_SUMMARY.md and update them
3. Search for any other stale files referencing moved content
4. Verify Research/README.md doesn't reference deleted file

**Verification**:
- No stale files remaining
- No broken references to deleted files

---

### Phase 5: Final Quality Check

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Run verification checks from DOC_QUALITY_CHECKLIST.md
2. Verify all links work
3. Ensure consistent formatting

**Steps**:
1. Check all internal links in docs/:
   ```bash
   # Extract and verify markdown links
   for file in docs/**/*.md docs/*.md; do
     echo "Checking $file..."
     grep -Eo '\[.*\]\(([^)]+)\)' "$file" | grep -Eo '\([^)]+\)' | tr -d '()'
   done
   ```
2. Verify line limit compliance (100 chars)
3. Verify ATX-style headings (no Setext)
4. Verify code blocks have language specification
5. Create summary of changes made

**Verification**:
- Zero broken internal links
- All formatting standards met
- Documentation navigable and consistent

---

## Dependencies

- None - this task is standalone documentation refactoring

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken external references | Medium | Low | Search for external references before moving files |
| User confusion during transition | Low | Low | Commit changes atomically, update all cross-refs |
| Missing important content | Medium | Low | Review deleted files carefully, preserve in git history |

## Success Criteria

- [ ] NAVIGATION.md merged into README.md and deleted
- [ ] All subdirectory READMEs have no broken links
- [ ] README.md follows Template G from DIRECTORY_README_STANDARD.md
- [ ] UserGuide/ contains only project-wide integration docs
- [ ] Reference/ either has content or is removed
- [ ] Research/RESEARCH_SUMMARY.md deleted
- [ ] Zero broken internal links in docs/
- [ ] All READMEs comply with DIRECTORY_README_STANDARD.md

## Rollback Plan

All changes are documentation-only. If issues are discovered:
1. Git revert the commit(s)
2. Restore deleted files from git history
3. No code impact - purely documentation changes
