# Implementation Plan: Task #368

**Task**: Refactor Documentation directory structure
**Version**: 002
**Created**: 2026-01-11
**Revision of**: implementation-001.md
**Reason**: Exploring file reorganization to improve clarity beyond just adding READMEs

## Revision Summary

The original plan focused only on adding missing README files. This revision analyzes the existing structure more deeply and identifies opportunities for file consolidation, removal of duplicates, and improved organization.

### Previous Plan Status
- All phases [NOT STARTED] - Plan revised before implementation

### Key Changes
1. **Added Phase 0**: Consolidate duplicate MAINTENANCE.md files
2. **Added Phase 0.5**: Evaluate potential file moves for improved logical grouping
3. **Refined categorization** in Development/README.md to better reflect file purposes
4. **Added explicit handling** of NAVIGATION.md at root level

## Analysis: Current Issues Found

### Issue 1: Duplicate MAINTENANCE.md Files
Two nearly identical files exist:
- `docs/development/MAINTENANCE.md` (15,234 bytes)
- `docs/project-info/MAINTENANCE.md` (19,493 bytes)

The ProjectInfo version is more complete (Five-Document Model vs Three-Document). **Recommendation**: Keep ProjectInfo version, delete or redirect Development version.

### Issue 2: Research/ Directory Organization
The Research/ directory contains 18 files with inconsistent naming:
- UPPERCASE files (CONCEPTUAL_ENGINEERING.md, DUAL_VERIFICATION.md, etc.)
- lowercase-with-hyphens files (leansearch-best-first-search.md, noncomputable-research.md)

**Recommendation**: Standardize naming OR group related files into subdirectories:
- `Research/ProofSearch/` - 6 leansearch-related files
- `Research/Theory/` - CONCEPTUAL_ENGINEERING.md, RECURSIVE_SEMANTICS.md
- `Research/Noncomputable/` - noncomputable-research.md, deduction-theorem-necessity-research.md

### Issue 3: Orphan Navigation Files
- `docs/NAVIGATION.md` (392 lines) duplicates much of README.md content
- Could be consolidated or transformed into a simpler index

### Issue 4: MCP_INTEGRATION.md Location
- Currently in `UserGuide/` but content is developer-focused (OpenCode integration)
- May fit better in `Development/` or new `Integration/` directory

## Overview

This revised plan takes a two-phase approach:
1. **Consolidation Phase**: Clean up duplicates and consider reorganization
2. **README Creation Phase**: Add navigation READMEs after structure is finalized

## Phases

### Phase 0: Resolve Duplicate MAINTENANCE.md

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Remove duplicate Development/MAINTENANCE.md
2. Update any references to point to ProjectInfo/MAINTENANCE.md

**Analysis**:
- ProjectInfo/MAINTENANCE.md is 4,259 bytes larger and more complete
- Development/MAINTENANCE.md references `../ProjectInfo/*.md` (points elsewhere anyway)
- Keeping one authoritative version eliminates confusion

**Steps**:
1. Verify ProjectInfo/MAINTENANCE.md has all content from Development version
2. Search for references to `Development/MAINTENANCE.md`
3. Update docs/README.md to reference ProjectInfo version only
4. Delete `docs/development/MAINTENANCE.md`
5. Verify no broken links

**Verification**:
- Only one MAINTENANCE.md exists
- All references updated

---

### Phase 0.5: Evaluate MCP_INTEGRATION.md Location (Optional)

**Estimated effort**: 10 minutes
**Status**: [COMPLETED]
**Decision**: Keep in UserGuide/ - will note as "advanced users/developers" in README

**Decision Point**: Should MCP_INTEGRATION.md move to Development/?

**Arguments for moving**:
- Content is developer/contributor focused (OpenCode integration)
- Not a user guide topic in the traditional sense

**Arguments against**:
- It describes how users integrate with the system
- Moving files creates redirect issues

**Recommendation**: Keep in UserGuide/ but note in README that it's for advanced users/developers.

---

### Phase 1: Create UserGuide/README.md

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create README.md following Template G pattern
2. Include all 7 UserGuide files with descriptions
3. Categorize by audience level (beginner → advanced)

**Files to create**:
- `docs/user-guide/README.md` - New file (~80 lines)

**Steps**:
1. Create header with back-link: `[Back to Documentation](../README.md)`
2. Add overview section describing user-facing documentation
3. Create navigation table organized by learning progression:

   **Getting Started**:
   - TUTORIAL.md - Getting started guide (beginners)
   - EXAMPLES.md - Usage examples and proof patterns

   **Core Concepts**:
   - METHODOLOGY.md - Philosophical foundations
   - ARCHITECTURE.md - TM logic specification

   **Integration**:
   - INTEGRATION.md - Model-checker integration
   - MCP_INTEGRATION.md - MCP server integration (advanced)

   **Development**:
   - TACTIC_DEVELOPMENT.md - Custom tactic development (advanced)

4. Add recommended reading order for new users
5. Add related documentation links
6. Add footer back-link

**Verification**:
- All 7 files linked correctly
- Learning progression is clear

---

### Phase 2: Create Development/README.md

**Estimated effort**: 45 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create README.md for directory (now 12 files after Phase 0)
2. Organize files by category with clear descriptions

**Files to create**:
- `docs/development/README.md` - New file (~100 lines)

**Steps**:
1. Create header with back-link
2. Add overview describing developer standards and guides
3. Organize files into categories:

   **Standards & Style**:
   - LEAN_STYLE_GUIDE.md - Coding conventions (896 lines - comprehensive)
   - TESTING_STANDARDS.md - Test requirements
   - QUALITY_METRICS.md - Quality targets

   **Practical Guides**:
   - METAPROGRAMMING_GUIDE.md - LEAN 4 metaprogramming
   - PROPERTY_TESTING_GUIDE.md - Property-based testing
   - NONCOMPUTABLE_GUIDE.md - Noncomputable definitions guide

   **Project Organization**:
   - MODULE_ORGANIZATION.md - Directory structure
   - DIRECTORY_README_STANDARD.md - README documentation standard
   - PHASED_IMPLEMENTATION.md - Implementation roadmap

   **Contribution Workflow**:
   - CONTRIBUTING.md - How to contribute
   - VERSIONING.md - Semantic versioning policy

   **Quality Assurance**:
   - DOC_QUALITY_CHECKLIST.md - Documentation QA

4. Add recommended reading order for new contributors
5. Link to ProjectInfo/MAINTENANCE.md for task workflow
6. Add footer back-link

**Verification**:
- All 12 files linked correctly (MAINTENANCE.md removed in Phase 0)
- Categories clearly distinguish file purposes

---

### Phase 3: Create ProjectInfo/README.md

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create README.md for project status tracking
2. Emphasize the relationship to MAINTENANCE.md workflow

**Files to create**:
- `docs/project-info/README.md` - New file (~70 lines)

**Steps**:
1. Create header with back-link
2. Add overview describing project status and tracking
3. Create navigation table:

   **Status Tracking**:
   - IMPLEMENTATION_STATUS.md - Module-by-module status
   - SORRY_REGISTRY.md - Technical debt tracking

   **Feature & Capability Tracking**:
   - FEATURE_REGISTRY.md - Feature tracking
   - TACTIC_REGISTRY.md - Tactic implementation status

   **Workflow**:
   - MAINTENANCE.md - TODO management workflow (authoritative source)

4. Add note explaining Five-Document Model from MAINTENANCE.md
5. Add related documentation links
6. Add footer back-link

**Verification**:
- All 5 files linked correctly
- Relationship to MAINTENANCE.md workflow is clear

---

### Phase 4: Create Reference/README.md

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create lightweight README.md for quick reference materials
2. Follow Template D (lightweight) pattern

**Files to create**:
- `docs/reference/README.md` - New file (~50 lines)

**Steps**:
1. Create header with back-link
2. Add brief overview of reference materials
3. Create navigation table:
   - API_REFERENCE.md - Logos API documentation (generated from docstrings)
   - GLOSSARY.md - Terminology and key concepts
   - OPERATORS.md - Formal symbols reference (Unicode notation)
4. Add quick lookup section with common needs
5. Add footer back-link

**Verification**:
- All 3 files linked correctly
- Quick lookup section is helpful

---

### Phase 5: Create Architecture/README.md

**Estimated effort**: 15 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Create lightweight README.md for ADR catalog
2. Follow Template D (lightweight) pattern
3. Explain ADR purpose and naming convention

**Files to create**:
- `docs/architecture/README.md` - New file (~50 lines)

**Steps**:
1. Create header with back-link
2. Add overview explaining ADR (Architectural Decision Record) purpose
3. Create ADR listing:
   - ADR-001-Classical-Logic-Noncomputable.md - Classical logic for metalogic
   - ADR-004-Remove-Project-Level-State-Files.md - State file architecture
4. Note the numbering gap (ADR-002, ADR-003 may be future or deprecated)
5. Add guidance on creating new ADRs
6. Add footer back-link

**Verification**:
- Both ADR files linked correctly
- ADR purpose and format are explained

---

### Phase 6: Update Root README.md

**Estimated effort**: 30 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Add README links to each subdirectory section
2. Remove duplicate reference to Development/MAINTENANCE.md
3. Ensure NAVIGATION.md role is clear

**Files to modify**:
- `docs/README.md` - Add README links, update references

**Steps**:
1. Read current README.md content
2. For each subdirectory section, add README.md as first link:
   - Architecture/README.md
   - Development/README.md
   - Installation/README.md (already has README)
   - ProjectInfo/README.md
   - Reference/README.md
   - Research/README.md (already has README)
   - UserGuide/README.md
3. Update Development/ section to remove MAINTENANCE.md reference (now in ProjectInfo only)
4. Add note about NAVIGATION.md for alternative navigation style
5. Verify all links are valid

**Verification**:
- All 7 subdirectory sections have README links
- No duplicate MAINTENANCE.md references
- All links work correctly

---

### Phase 7: Final Verification and Cleanup

**Estimated effort**: 20 minutes
**Status**: [COMPLETED]

**Objectives**:
1. Verify all README files follow the standard
2. Check all links work bidirectionally
3. Ensure MAINTENANCE.md consolidation is complete
4. Validate no orphan references

**Steps**:
1. Verify each new README has:
   - Header back-link to parent
   - Complete file listing
   - Related documentation section
   - Footer back-link
2. Check all internal links work
3. Grep for "Development/MAINTENANCE" and update any remaining references
4. Verify 100-character line limit
5. Run link validation if available

**Verification**:
- All links bidirectional
- No orphan references to deleted files
- Consistent formatting
- Standard compliance

## Dependencies

- None - all work can proceed independently

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Broken links after MAINTENANCE.md consolidation | Medium | Medium | Grep for all references before deletion |
| Research/ naming inconsistency confuses users | Low | Low | Note in README, defer reorganization to future task |
| NAVIGATION.md overlap with README.md | Low | Low | Clarify roles in root README |

## Success Criteria

- [ ] Duplicate MAINTENANCE.md resolved (only ProjectInfo version remains)
- [ ] 5 new README.md files created (UserGuide, Development, ProjectInfo, Reference, Architecture)
- [ ] Each README follows DIRECTORY_README_STANDARD.md Template G/D pattern
- [ ] All files in each directory linked with descriptions
- [ ] Back-links to parent directory in header and footer
- [ ] Root README.md updated with subdirectory README links
- [ ] All cross-references verified working (no broken links)
- [ ] 100-character line limit followed

## Future Considerations (Out of Scope)

These were identified but deferred to avoid scope creep:

1. **Research/ subdirectory organization**: Group 18 files into subdirectories (ProofSearch/, Theory/, etc.)
2. **NAVIGATION.md consolidation**: Consider merging with README.md or repurposing
3. **Filename standardization**: Resolve UPPERCASE vs lowercase-hyphen inconsistency in Research/

## Rollback Plan

If implementation fails:
1. Restore Development/MAINTENANCE.md from git if deleted
2. Delete new README.md files
3. Revert docs/README.md via git

The only destructive change is MAINTENANCE.md consolidation, which is easily reversible via git.
