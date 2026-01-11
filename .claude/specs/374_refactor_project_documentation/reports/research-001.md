# Research Report: Task #374

**Task**: Refactor project Documentation to theory-specific directories
**Date**: 2026-01-11
**Focus**: Categorize docs/ files for sorting into Logos/, Bimodal/, or project-wide locations

## Summary

The ProofChecker/docs/ directory contains a mix of theory-specific and project-wide
documentation. With the creation of Bimodal/docs/ and Logos/docs/ in tasks
360 and 372, project-level docs/ should become theory-agnostic. This research
categorizes all files for appropriate redistribution.

## Current State Analysis

### Existing Theory-Specific Documentation

**Logos/docs/** (11 files):
- UserGuide/: CURRENT_STATUS.md, QUICKSTART.md (redirects to Bimodal)
- Reference/: AXIOM_REFERENCE.md (redirects to Bimodal), EXTENSION_STUBS.md
- ProjectInfo/: IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md, ROADMAP.md

**Bimodal/docs/** (10 files):
- UserGuide/: PROOF_PATTERNS.md, QUICKSTART.md
- Reference/: AXIOM_REFERENCE.md, TACTIC_REFERENCE.md
- ProjectInfo/: IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md

### ProofChecker/docs/ Structure (49 files)

The docs/ directory contains 8 subdirectories covering Installation, UserGuide,
Research, ProjectInfo, Development, Reference, Architecture, and AI System documentation.

## File Categorization

### Category 1: LOGOS-SPECIFIC (Move to Logos/docs/)

These files are specifically about the Logos theory or the planned Logos extensions:

| File | Reason | Target Location |
|------|--------|-----------------|
| Research/RECURSIVE_SEMANTICS.md | Describes Logos semantic extensions | Logos/docs/research/ |
| Research/LAYER_EXTENSIONS.md | Logos extension architecture | Logos/docs/research/ |
| Research/CONCEPTUAL_ENGINEERING.md | Logos philosophical foundations | Logos/docs/research/ |
| UserGuide/METHODOLOGY.md | Logos layer architecture methodology | Logos/docs/user-guide/ |
| Reference/GLOSSARY.md | Logos operator glossary | Logos/docs/reference/ |

**Rationale**: These files describe the planned Logos hyperintensional logic, its layer
architecture, and conceptual foundations. They reference Logos-specific constructs
(states, hyperintensional semantics, layer extensions).

### Category 2: BIMODAL-SPECIFIC (Move to Bimodal/docs/)

These files are specifically about Bimodal TM logic or its proof automation:

| File | Reason | Target Location |
|------|--------|-----------------|
| Research/MODAL_TEMPORAL_PROOF_SEARCH.md | TM proof search automation | Bimodal/docs/research/ |
| Research/temporal-logic-automation-research.md | Bimodal temporal tactics | Bimodal/docs/research/ |
| Research/PROOF_SEARCH_AUTOMATION.md | Bimodal proof search | Bimodal/docs/research/ |
| Research/leansearch-best-first-search.md | Bimodal search algorithms | Bimodal/docs/research/ |
| Research/leansearch-priority-queue.md | Bimodal search structures | Bimodal/docs/research/ |
| Research/leansearch-proof-caching-memoization.md | Bimodal caching | Bimodal/docs/research/ |
| Research/LEANSEARCH_API_SPECIFICATION.md | Lean search API | Bimodal/docs/research/ |
| UserGuide/ARCHITECTURE.md | TM logic specification | Bimodal/docs/user-guide/ |
| UserGuide/TUTORIAL.md | TM logic tutorial | Bimodal/docs/user-guide/ |
| UserGuide/EXAMPLES.md | TM logic examples | Bimodal/docs/user-guide/ |
| UserGuide/TACTIC_DEVELOPMENT.md | Bimodal tactic development | Bimodal/docs/user-guide/ |
| Reference/OPERATORS.md | TM operators reference | Bimodal/docs/reference/ |
| ProjectInfo/TACTIC_REGISTRY.md | Bimodal tactic registry | Bimodal/docs/project-info/ |

**Rationale**: These files describe the implemented Bimodal TM logic, its proof system,
automation tactics, and operator semantics. They are specific to the working implementation.

### Category 3: SHARED/PROJECT-WIDE (Keep in docs/)

These files are truly project-agnostic and apply to all theories:

| File | Reason |
|------|--------|
| Installation/* | Project-wide setup (BASIC_INSTALLATION.md, GETTING_STARTED.md, USING_GIT.md, CLAUDE_CODE.md) |
| Development/LEAN_STYLE_GUIDE.md | Coding style for all Lean code |
| Development/TESTING_STANDARDS.md | Testing for all theories |
| Development/CONTRIBUTING.md | How to contribute |
| Development/MODULE_ORGANIZATION.md | Project structure |
| Development/DIRECTORY_README_STANDARD.md | Documentation standard |
| Development/DOC_QUALITY_CHECKLIST.md | Quality checklist |
| Development/VERSIONING.md | Versioning policy |
| Development/PHASED_IMPLEMENTATION.md | Development process |
| Development/QUALITY_METRICS.md | Quality targets |
| Development/PROPERTY_TESTING_GUIDE.md | Property testing (if general) |
| Development/METAPROGRAMMING_GUIDE.md | Lean metaprogramming |
| Development/NONCOMPUTABLE_GUIDE.md | Noncomputable handling |
| Architecture/ADR-001-Classical-Logic-Noncomputable.md | Classical logic decision |
| Architecture/ADR-004-Remove-Project-Level-State-Files.md | State file decision |
| Research/THEORY_COMPARISON.md | Compares both theories (link from both) |
| Research/noncomputable-research.md | Classical logic research |
| Research/deduction-theorem-necessity-research.md | Classical logic research |
| Research/property-based-testing-lean4.md | Testing research |
| Research/DUAL_VERIFICATION.md | RL training (applies to both) |
| Research/PROOF_LIBRARY_DESIGN.md | Caching design (applies to both) |
| ProjectInfo/FEATURE_REGISTRY.md | Cross-theory features |
| ProjectInfo/MAINTENANCE.md | Project-wide maintenance |
| ProjectInfo/SORRY_REGISTRY.md | Technical debt (contains both) |
| Reference/API_REFERENCE.md | API reference (if general) |
| UserGuide/INTEGRATION.md | Integration guide |
| UserGuide/MCP_INTEGRATION.md | MCP integration |

### Category 4: REDUNDANT/CONSOLIDATE

Files that may be redundant with theory-specific versions:

| File | Issue | Action |
|------|-------|--------|
| ProjectInfo/IMPLEMENTATION_STATUS.md | Both theories have their own | Keep as cross-reference to theory-specific versions |

## Recommendations

### Approach 1: Move with Links (Recommended)

Move theory-specific files to their target locations and add cross-links in docs/:

1. **Create Research/ directories** in Logos/docs/ and Bimodal/docs/
2. **Move files** to appropriate theory directories
3. **Update docs/research/README.md** to link to theory-specific research
4. **Update all cross-references** in moved files

### Approach 2: Copy with Deprecation Notices

Keep originals with deprecation notices pointing to canonical locations. This preserves
any external links but creates maintenance overhead.

### Approach 3: Symlinks (Not Recommended)

Create symlinks from docs/ to theory directories. Complex to maintain and
may not work across all platforms.

## File Movement Plan

### Phase 1: Create Target Directories

```
mkdir -p Logos/docs/research/
mkdir -p Bimodal/docs/research/
```

### Phase 2: Move Logos-Specific Files

```
mv docs/research/RECURSIVE_SEMANTICS.md Logos/docs/research/
mv docs/research/LAYER_EXTENSIONS.md Logos/docs/research/
mv docs/research/CONCEPTUAL_ENGINEERING.md Logos/docs/research/
mv docs/user-guide/METHODOLOGY.md Logos/docs/user-guide/
mv docs/reference/GLOSSARY.md Logos/docs/reference/
```

### Phase 3: Move Bimodal-Specific Files

```
mv docs/research/MODAL_TEMPORAL_PROOF_SEARCH.md Bimodal/docs/research/
mv docs/research/temporal-logic-automation-research.md Bimodal/docs/research/
mv docs/research/PROOF_SEARCH_AUTOMATION.md Bimodal/docs/research/
mv docs/research/leansearch-*.md Bimodal/docs/research/
mv docs/research/LEANSEARCH_API_SPECIFICATION.md Bimodal/docs/research/
mv docs/user-guide/ARCHITECTURE.md Bimodal/docs/user-guide/
mv docs/user-guide/TUTORIAL.md Bimodal/docs/user-guide/
mv docs/user-guide/EXAMPLES.md Bimodal/docs/user-guide/
mv docs/user-guide/TACTIC_DEVELOPMENT.md Bimodal/docs/user-guide/
mv docs/reference/OPERATORS.md Bimodal/docs/reference/
mv docs/project-info/TACTIC_REGISTRY.md Bimodal/docs/project-info/
```

### Phase 4: Update READMEs and Cross-References

Update all README.md files to point to new locations. Update internal links in moved files.

### Phase 5: Update docs/README.md

Simplify to focus on project-wide documentation only, with clear pointers to
theory-specific documentation.

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Broken links | Medium | Search for all references before moving |
| Loss of content | High | User has created Documentation_OLD/ backup |
| Confusion during transition | Low | Clear commit messages |

## Next Steps

1. Create implementation plan with detailed file movements
2. Identify and update all cross-references before moving
3. Execute moves in order (directories first, then files)
4. Update all README.md files
5. Verify no broken links

## References

- Task 360: Created Bimodal/docs/
- Task 372: Created Logos/docs/
- docs/README.md: Current structure
- Logos/docs/README.md: Logos structure
- Bimodal/docs/README.md: Bimodal structure
