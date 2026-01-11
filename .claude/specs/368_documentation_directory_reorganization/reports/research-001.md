# Research Report: Task #368

**Task**: Refactor Documentation directory structure
**Date**: 2026-01-11
**Focus**: Directory organization, README creation, navigation

## Summary

The docs/ directory has 54 markdown files across 7 subdirectories. The main README.md at the root is well-structured following Template G (Documentation Directory). However, 5 of 7 subdirectories lack README files per the DIRECTORY_README_STANDARD.md. The reorganization should add missing README files with proper back-links and summaries while preserving existing content.

## Current Structure

### Directory Inventory

```
docs/
├── README.md                  (199 lines) - EXISTS, follows Template G
├── NAVIGATION.md              (392 lines) - Navigation guide
├── Architecture/              (2 files) - MISSING README
│   ├── ADR-001-Classical-Logic-Noncomputable.md
│   └── ADR-004-Remove-Project-Level-State-Files.md
├── Development/               (12 files) - MISSING README
│   ├── CONTRIBUTING.md
│   ├── DIRECTORY_README_STANDARD.md
│   ├── DOC_QUALITY_CHECKLIST.md
│   ├── LEAN_STYLE_GUIDE.md
│   ├── MAINTENANCE.md
│   ├── METAPROGRAMMING_GUIDE.md
│   ├── MODULE_ORGANIZATION.md
│   ├── NONCOMPUTABLE_GUIDE.md
│   ├── PHASED_IMPLEMENTATION.md
│   ├── PROPERTY_TESTING_GUIDE.md
│   ├── QUALITY_METRICS.md
│   ├── TESTING_STANDARDS.md
│   └── VERSIONING.md
├── Installation/              (5 files) - HAS README
│   ├── README.md
│   ├── BASIC_INSTALLATION.md
│   ├── CLAUDE_CODE.md
│   ├── GETTING_STARTED.md
│   └── USING_GIT.md
├── ProjectInfo/               (4 files) - MISSING README
│   ├── FEATURE_REGISTRY.md
│   ├── IMPLEMENTATION_STATUS.md
│   ├── MAINTENANCE.md
│   ├── SORRY_REGISTRY.md
│   └── TACTIC_REGISTRY.md
├── Reference/                 (3 files) - MISSING README
│   ├── API_REFERENCE.md
│   ├── GLOSSARY.md
│   └── OPERATORS.md
├── Research/                  (18 files) - HAS README
│   ├── README.md
│   ├── CONCEPTUAL_ENGINEERING.md
│   ├── DUAL_VERIFICATION.md
│   ├── LAYER_EXTENSIONS.md
│   ├── LEANSEARCH_API_SPECIFICATION.md
│   ├── MODAL_TEMPORAL_PROOF_SEARCH.md
│   ├── PROOF_LIBRARY_DESIGN.md
│   ├── PROOF_SEARCH_AUTOMATION.md
│   ├── RECURSIVE_SEMANTICS.md
│   ├── RESEARCH_SUMMARY.md
│   ├── deduction-theorem-necessity-research.md
│   ├── leansearch-best-first-search.md
│   ├── leansearch-priority-queue.md
│   ├── leansearch-proof-caching-memoization.md
│   ├── noncomputable-research.md
│   ├── property-based-testing-lean4.md
│   └── temporal-logic-automation-research.md
└── UserGuide/                 (7 files) - MISSING README
    ├── ARCHITECTURE.md
    ├── EXAMPLES.md
    ├── INTEGRATION.md
    ├── MCP_INTEGRATION.md
    ├── METHODOLOGY.md
    ├── TACTIC_DEVELOPMENT.md
    └── TUTORIAL.md
```

### Existing READMEs Analysis

**docs/README.md** (Root)
- Well-structured, follows Template G
- Lists all subdirectories with descriptions
- Has Quick Links sections by audience
- Contains documentation update workflow
- **Status**: Good, minor updates needed to add README links

**docs/Installation/README.md**
- Good back-link to parent: `[Back to Documentation](../README.md)`
- Has navigation table with descriptions
- Includes recommended reading order
- Requirements summary table
- **Status**: Excellent example to follow

**docs/Research/README.md**
- Comprehensive with document categories
- Has status indicators for each document
- Related documentation links
- Navigation back-links
- **Status**: Good, follows pattern well

### Missing READMEs (5 directories)

1. **Architecture/** - 2 ADR files, needs lightweight README
2. **Development/** - 12 files, needs comprehensive README
3. **ProjectInfo/** - 4-5 files, needs status-focused README
4. **Reference/** - 3 files, needs quick reference README
5. **UserGuide/** - 7 files, needs audience-focused README

## Findings

### DIRECTORY_README_STANDARD.md Requirements

Per the standard, README files should:
1. Have back-links to parent directory
2. Include forward-links to subdirectory files
3. Provide summaries (not duplicate content)
4. Follow Template G for documentation directories
5. Be lightweight (40-120 lines depending on content)

Key templates:
- **Template D**: Lightweight source directory (40-70 lines)
- **Template E**: Test directory (80-120 lines)
- **Template F**: Example/pedagogical directory (70-100 lines)
- **Template G**: Documentation directory (80-120 lines)

### Navigation Pattern

The Installation/README.md provides an excellent pattern:
```markdown
# {Directory Name}

[Back to Documentation](../README.md) | [Related Link](NextFile.md)

---

## Overview
Brief description of directory contents.

## Quick Navigation
| File | Description | Audience |
|------|-------------|----------|
| [FILE.md](FILE.md) | Description | Target |

## Related Documentation
- Links to related docs in other directories

---

[Back to Documentation](../README.md) | [Related Link](NextFile.md)
```

### Content Already Well-Organized

The existing files are already well-categorized:
- **Architecture/**: Architectural Decision Records (ADRs)
- **Development/**: Developer standards and guides
- **Installation/**: Setup and configuration
- **ProjectInfo/**: Project status tracking
- **Reference/**: Quick lookup materials
- **Research/**: Research documents and vision
- **UserGuide/**: User-facing tutorials and guides

No file relocations needed - only README additions.

## Recommendations

### 1. Create Missing README Files

Create 5 README.md files following this priority:

| Directory | Priority | Template | Estimated Lines |
|-----------|----------|----------|-----------------|
| UserGuide/ | High | Template G | 70-90 |
| Development/ | High | Template G | 90-120 |
| ProjectInfo/ | Medium | Template G | 60-80 |
| Reference/ | Medium | Template D | 50-70 |
| Architecture/ | Low | Template D | 40-60 |

### 2. README Content Structure

Each README should include:
1. Back-link header with parent directory
2. Brief overview (1-2 sentences)
3. File listing table with descriptions and audience
4. Recommended reading order (for larger directories)
5. Related documentation links
6. Footer with back-link

### 3. Update Root README.md

Add README links for new subdirectory READMEs:
```markdown
### UserGuide/
- [README.md](UserGuide/README.md) - User guide overview and navigation
- [TUTORIAL.md](UserGuide/TUTORIAL.md) - Getting started guide
...
```

### 4. Consistency Checklist

For each new README:
- [ ] Back-link to parent (../README.md)
- [ ] Forward-links to all files in directory
- [ ] Brief description for each file
- [ ] Audience indication where applicable
- [ ] Related documentation section
- [ ] 100-character line limit
- [ ] Footer back-link

## References

- [DIRECTORY_README_STANDARD.md](docs/Development/DIRECTORY_README_STANDARD.md) - The governing standard
- [Installation/README.md](docs/Installation/README.md) - Excellent pattern example
- [Research/README.md](docs/Research/README.md) - Good category organization

## Next Steps

1. **Create UserGuide/README.md** - Highest user visibility
2. **Create Development/README.md** - Most files, needs organization
3. **Create ProjectInfo/README.md** - Status tracking focus
4. **Create Reference/README.md** - Quick lookup focus
5. **Create Architecture/README.md** - ADR catalog
6. **Update docs/README.md** - Add README links
7. **Verify all links** - Cross-reference validation
