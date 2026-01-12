# Implementation Plan: Task #368

**Task**: Refactor Documentation directory structure
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Create 5 missing README.md files in Documentation subdirectories following the DIRECTORY_README_STANDARD.md pattern. Each README will have back-links to parent, file listings with descriptions, audience guidance, and related documentation links. The root README.md will be updated to reference the new subdirectory READMEs. No file relocations are needed as content is already well-organized.

## Phases

### Phase 1: Create UserGuide/README.md

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create README.md following Template G pattern
2. Include all 7 UserGuide files with descriptions
3. Add audience-focused navigation (new users, developers, researchers)

**Files to create**:
- `docs/user-guide/README.md` - New file (~80 lines)

**Steps**:
1. Create header with back-link: `[Back to Documentation](../README.md)`
2. Add overview section describing user-facing documentation
3. Create navigation table with all 7 files:
   - ARCHITECTURE.md - TM logic specification
   - EXAMPLES.md - Usage examples and proof patterns
   - INTEGRATION.md - Model-checker integration
   - MCP_INTEGRATION.md - MCP server integration
   - METHODOLOGY.md - Philosophical foundations
   - TACTIC_DEVELOPMENT.md - Custom tactic development
   - TUTORIAL.md - Getting started guide
4. Add recommended reading order for new users
5. Add related documentation links
6. Add footer back-link

**Verification**:
- All 7 files linked correctly
- Back-links work
- Follows 100-character line limit

---

### Phase 2: Create Development/README.md

**Estimated effort**: 45 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create README.md for the largest subdirectory (12 files)
2. Organize files by category (Standards, Guides, Workflow)
3. Include audience guidance for contributors and developers

**Files to create**:
- `docs/development/README.md` - New file (~100 lines)

**Steps**:
1. Create header with back-link
2. Add overview describing developer standards and guides
3. Organize files into categories:
   - **Standards**: LEAN_STYLE_GUIDE.md, TESTING_STANDARDS.md, QUALITY_METRICS.md
   - **Guides**: METAPROGRAMMING_GUIDE.md, PROPERTY_TESTING_GUIDE.md, NONCOMPUTABLE_GUIDE.md
   - **Workflow**: CONTRIBUTING.md, MAINTENANCE.md, VERSIONING.md
   - **Organization**: MODULE_ORGANIZATION.md, DIRECTORY_README_STANDARD.md, PHASED_IMPLEMENTATION.md
   - **Quality**: DOC_QUALITY_CHECKLIST.md
4. Create navigation table with descriptions
5. Add recommended reading order for new contributors
6. Add related documentation links
7. Add footer back-link

**Verification**:
- All 12 files linked correctly
- Categories make logical sense
- Follows standard format

---

### Phase 3: Create ProjectInfo/README.md

**Estimated effort**: 20 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create README.md for project status tracking
2. Focus on status and registry documentation
3. Include guidance for maintainers

**Files to create**:
- `docs/project-info/README.md` - New file (~60 lines)

**Steps**:
1. Create header with back-link
2. Add overview describing project status and tracking
3. Create navigation table with all files:
   - FEATURE_REGISTRY.md - Feature tracking
   - IMPLEMENTATION_STATUS.md - Module-by-module status
   - MAINTENANCE.md - TODO management workflow
   - SORRY_REGISTRY.md - Technical debt tracking
   - TACTIC_REGISTRY.md - Tactic implementation status
4. Add related documentation links
5. Add footer back-link

**Verification**:
- All files linked correctly
- Audience is clear (maintainers, contributors)

---

### Phase 4: Create Reference/README.md

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create lightweight README.md for quick reference materials
2. Follow Template D (lightweight) pattern

**Files to create**:
- `docs/reference/README.md` - New file (~50 lines)

**Steps**:
1. Create header with back-link
2. Add brief overview of reference materials
3. Create navigation table:
   - API_REFERENCE.md - Logos API documentation
   - GLOSSARY.md - Terminology and key concepts
   - OPERATORS.md - Formal symbols reference
4. Add quick links for common lookups
5. Add footer back-link

**Verification**:
- All 3 files linked correctly
- Concise and focused

---

### Phase 5: Create Architecture/README.md

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Create lightweight README.md for ADR catalog
2. Follow Template D (lightweight) pattern
3. Explain ADR purpose and format

**Files to create**:
- `docs/architecture/README.md` - New file (~50 lines)

**Steps**:
1. Create header with back-link
2. Add overview explaining ADR (Architectural Decision Record) purpose
3. Create ADR listing:
   - ADR-001-Classical-Logic-Noncomputable.md - Classical logic decision
   - ADR-004-Remove-Project-Level-State-Files.md - State file architecture
4. Add guidance on creating new ADRs
5. Add footer back-link

**Verification**:
- Both ADR files linked correctly
- ADR purpose is clear

---

### Phase 6: Update Root README.md

**Estimated effort**: 30 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Add README links to each subdirectory section
2. Ensure consistency with new README structure
3. Verify all cross-references

**Files to modify**:
- `docs/README.md` - Add README links to subdirectory sections

**Steps**:
1. Read current README.md content
2. For each subdirectory section (UserGuide, Development, ProjectInfo, Reference, Architecture), add README.md as first link
3. Update any outdated file references
4. Verify all links are valid

**Verification**:
- All 7 subdirectory sections have README links
- All links work correctly
- No broken references

---

### Phase 7: Final Verification

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify all README files follow the standard
2. Check all links work bidirectionally
3. Ensure consistency across all READMEs

**Files to verify**:
- All 5 new README.md files
- Updated docs/README.md

**Steps**:
1. Verify each new README has:
   - Header back-link to parent
   - Complete file listing
   - Related documentation section
   - Footer back-link
2. Check all internal links work
3. Verify 100-character line limit
4. Confirm audience guidance is clear

**Verification**:
- All links bidirectional
- Consistent formatting
- Standard compliance

## Dependencies

- None - all work is additive to existing structure

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken links | Low | Low | Verify all links in final phase |
| Inconsistent format | Low | Low | Follow Installation/README.md pattern |
| Missing files | Low | Low | Check directory listings before creating READMEs |

## Success Criteria

- [ ] 5 new README.md files created (UserGuide, Development, ProjectInfo, Reference, Architecture)
- [ ] Each README follows DIRECTORY_README_STANDARD.md Template G/D pattern
- [ ] All files in each directory linked with descriptions
- [ ] Back-links to parent directory in header and footer
- [ ] Root README.md updated with subdirectory README links
- [ ] All cross-references verified working
- [ ] 100-character line limit followed

## Rollback Plan

If implementation fails, simply delete the new README.md files. No existing files are modified except docs/README.md, which can be reverted via git.
