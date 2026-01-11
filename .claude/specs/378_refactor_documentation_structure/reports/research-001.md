# Research Report: Task #378

**Task**: Refactor Documentation structure with directory standards
**Date**: 2026-01-11
**Focus**: Analyze current docs/ structure and identify refactoring requirements

## Summary

The docs/ directory has significant organizational issues including broken links in
NAVIGATION.md, redundant content between README.md and NAVIGATION.md, and missing files that are
referenced but don't exist. The directory structure is reasonable but subdirectory READMEs need
updating to comply with DIRECTORY_README_STANDARD.md.

## Findings

### 1. Current Directory Structure

The docs/ directory contains 7 subdirectories with 41 markdown files total:

| Directory | Files | Purpose |
|-----------|-------|---------|
| Architecture/ | 3 | ADRs and architectural decisions |
| Development/ | 12 | Developer standards and guides |
| Installation/ | 5 | Setup and configuration |
| ProjectInfo/ | 5 | Status tracking and registries |
| Reference/ | 2 | API reference (missing GLOSSARY.md, OPERATORS.md) |
| Research/ | 8 | Project-wide research documents |
| UserGuide/ | 3 | User documentation (missing TUTORIAL.md, EXAMPLES.md, etc.) |

### 2. Broken Links in NAVIGATION.md

NAVIGATION.md references 10 files that do not exist in docs/:

| Missing File | Status |
|--------------|--------|
| UserGuide/TUTORIAL.md | Does NOT exist (Bimodal has one) |
| UserGuide/EXAMPLES.md | Does NOT exist (Bimodal has one) |
| UserGuide/METHODOLOGY.md | Does NOT exist (Logos has one) |
| UserGuide/ARCHITECTURE.md | Does NOT exist (Bimodal has one) |
| UserGuide/TACTIC_DEVELOPMENT.md | Does NOT exist (Bimodal has one) |
| Reference/GLOSSARY.md | Does NOT exist (Logos has one) |
| Reference/OPERATORS.md | Does NOT exist (Bimodal has OPERATORS.md in Reference/) |
| Research/CONCEPTUAL_ENGINEERING.md | Does NOT exist (Logos has one) |
| Research/LAYER_EXTENSIONS.md | Does NOT exist (Logos has one) |
| ProjectInfo/TACTIC_REGISTRY.md | Does NOT exist (Bimodal has one) |

These files were moved to theory-specific directories (Bimodal/docs/ or
Logos/docs/) during tasks 360 and 374, but NAVIGATION.md was not updated.

### 3. Redundancy Between README.md and NAVIGATION.md

Both files serve as navigation hubs with significant overlap:

**README.md (244 lines)**:
- Documentation organization overview
- Quick links by audience (new users, contributors, developers, researchers)
- Documentation update workflow
- Documentation standards

**NAVIGATION.md (403 lines)**:
- More detailed navigation by use case
- Complete file listing with counts
- Theory-specific documentation tables
- Command reference section

**Recommended Action**: Merge NAVIGATION.md content into README.md and delete NAVIGATION.md. The
README.md should become the single navigation hub per DIRECTORY_README_STANDARD.md Template G.

### 4. Subdirectory README Compliance

Most subdirectory READMEs partially comply with DIRECTORY_README_STANDARD.md but need updates:

| Directory | Has README | Compliance | Issues |
|-----------|------------|------------|--------|
| Architecture/ | Yes | Good | Missing audience guidance |
| Development/ | Yes | Good | Could add learning paths |
| Installation/ | Yes | Good | Good structure |
| ProjectInfo/ | Yes | Good | Good structure |
| Reference/ | Yes | Partial | References missing files |
| Research/ | Yes | Good | Good structure |
| UserGuide/ | Yes | Partial | References missing files, outdated reading order |

### 5. Content Distribution Analysis

The task 374 refactoring moved theory-specific content to Bimodal/docs/ and
Logos/docs/, which was correct. However, several cleanup issues remain:

**Files that should remain in docs/ (project-wide)**:
- All Development/ files (standards apply to all theories)
- All Installation/ files (project-wide setup)
- Architecture/ ADRs (cross-cutting decisions)
- Research/ files for project-wide research (DUAL_VERIFICATION.md, PROOF_LIBRARY_DESIGN.md, etc.)
- ProjectInfo/ files for project-wide status (IMPLEMENTATION_STATUS.md, SORRY_REGISTRY.md)

**Files with unclear placement**:
- Research/RESEARCH_SUMMARY.md - References MODAL_TEMPORAL_PROOF_SEARCH.md which is in
  Bimodal/docs/Research/. Should be deleted or moved.

### 6. Theory-Specific Documentation Links

README.md correctly references theory-specific documentation:
- Bimodal/docs/ (active implementation)
- Logos/docs/ (planned implementation)

But should remove links to non-existent files in project-wide directories and update cross-
references to point to the correct theory-specific locations.

## Recommendations

### 1. Merge NAVIGATION.md into README.md

- Keep README.md as the single navigation hub
- Add use-case navigation from NAVIGATION.md
- Delete NAVIGATION.md
- Update README.md to follow Template G from DIRECTORY_README_STANDARD.md

### 2. Update Subdirectory READMEs

Each subdirectory README should be updated to:
- Remove broken links to non-existent files
- Add audience guidance where missing
- Follow appropriate template (D, E, F, or G)
- Keep them lightweight (40-70 lines for source dirs, 80-120 for test/doc dirs)

### 3. Remove or Update Stale Files

- Delete Research/RESEARCH_SUMMARY.md (references moved file)
- Update any files with broken internal links

### 4. Fix UserGuide/ and Reference/

Two options:
1. **Remove the directories**: Move remaining files (INTEGRATION.md, MCP_INTEGRATION.md,
   API_REFERENCE.md) to appropriate locations since most content is now theory-specific
2. **Keep as thin redirect directories**: Keep READMEs that point to theory-specific docs

Recommended: Option 1 - consolidate remaining project-wide user content into README.md or merge
into other directories.

### 5. Proposed Final Structure

```
docs/
├── README.md              # Navigation hub (merged from NAVIGATION.md)
├── Architecture/          # ADRs (keep as-is)
│   ├── README.md
│   └── ADR-*.md
├── Development/           # Standards (keep as-is)
│   ├── README.md
│   └── *.md
├── Installation/          # Setup guides (keep as-is)
│   ├── README.md
│   └── *.md
├── ProjectInfo/           # Status tracking (keep as-is)
│   ├── README.md
│   └── *.md
└── Research/              # Project-wide research (clean up)
    ├── README.md
    └── *.md
```

Consider removing:
- UserGuide/ (move remaining content elsewhere)
- Reference/ (move remaining content elsewhere)
- NAVIGATION.md (merge into README.md)

## References

- DIRECTORY_README_STANDARD.md - Templates D, E, F, G for directory READMEs
- DOC_QUALITY_CHECKLIST.md - Quality verification procedures
- Task 374 - Previous documentation refactoring that moved theory-specific content
- Bimodal/docs/ - Active theory documentation
- Logos/docs/ - Planned theory documentation

## Next Steps

1. Create implementation plan with phased approach
2. Phase 1: Merge NAVIGATION.md into README.md
3. Phase 2: Update subdirectory READMEs to remove broken links
4. Phase 3: Decide on UserGuide/ and Reference/ restructuring
5. Phase 4: Delete stale files and verify all links
6. Phase 5: Final quality check with DOC_QUALITY_CHECKLIST.md
