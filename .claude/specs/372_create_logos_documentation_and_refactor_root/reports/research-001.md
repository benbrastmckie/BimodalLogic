# Research Report: Task #372

**Task**: Create Logos/docs/ and refactor root docs/
**Date**: 2026-01-11
**Focus**: General research

## Summary

This task involves creating a theory-specific documentation structure for Logos (similar to the existing Bimodal/docs/) and refactoring the root docs/ directory to be theory-agnostic. The research reveals that Bimodal/docs/ provides an excellent model to follow, the root docs/ currently has some Logos/Bimodal-specific content that should be factored out, and the DIRECTORY_README_STANDARD.md provides clear templates for the new structure.

## Findings

### 1. Current Root docs/ Structure

The root `docs/` directory contains 8 subdirectories:
- **Architecture/** - ADRs (theory-agnostic)
- **Development/** - Standards and conventions (theory-agnostic)
- **Installation/** - Setup guides (theory-agnostic)
- **ProjectInfo/** - Implementation status, registries (mixed - some Logos-specific)
- **Reference/** - API reference, glossary (mixed)
- **Research/** - Research documents including THEORY_COMPARISON.md (theory-agnostic)
- **UserGuide/** - Tutorials, examples (mixed - some theory-specific content)
- **NAVIGATION.md** - Navigation alternative (theory-agnostic)

**Key Issues**:
- `ProjectInfo/IMPLEMENTATION_STATUS.md` contains detailed Logos-specific implementation status
- `UserGuide/` files like TUTORIAL.md, EXAMPLES.md contain Logos-specific content
- `Reference/` has theory-specific operator definitions
- The README.md references "Logos Documentation" as the main hub

### 2. Bimodal/docs/ Model

Bimodal/docs/ provides an excellent template with 3 subdirectories:
- **UserGuide/** - QUICKSTART.md, PROOF_PATTERNS.md
- **Reference/** - AXIOM_REFERENCE.md, TACTIC_REFERENCE.md
- **ProjectInfo/** - IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md

Each has a README.md following DIRECTORY_README_STANDARD.md Template G.

**Key Features**:
- Clear separation of theory-specific vs project-wide content
- Cross-links to project-wide docs/ for shared standards
- Note at top directing to project-wide docs for shared content
- Relationship table showing Bimodal-specific vs project-wide equivalents

### 3. Logos/ Current State

The Logos/ directory currently contains:
- Main implementation files (Core.lean, Syntax.lean, etc.)
- Stubs for planned extensions (Epistemic/, Normative/, Explanatory/)
- latex/ directory for mathematical documentation
- README.md with comprehensive implementation overview
- **No docs/ subdirectory**

**Key Insight from THEORY_COMPARISON.md**:
- Logos is currently a **re-export layer** for Bimodal
- Contains stubs for planned second-order hyperintensional extensions
- Full Logos implementation is future work
- Documentation should reflect this status

### 4. DIRECTORY_README_STANDARD.md Requirements

Template G (Documentation Directory) specifies:
- Organize into categories with audience guidance
- Provide quick links to most-referenced documents
- Include documentation update workflow
- Keep navigation-focused without duplicating content

### 5. Content Analysis for Refactoring

**Content that should stay in root docs/** (theory-agnostic):
- Development/ - All files (coding standards apply to all theories)
- Architecture/ - ADRs for project-wide decisions
- Installation/ - Setup applies to whole project
- Research/ - THEORY_COMPARISON.md, research methodologies

**Content that needs refactoring**:
- `ProjectInfo/IMPLEMENTATION_STATUS.md` - Currently Logos-specific; should become overview linking to theory-specific status
- `UserGuide/TUTORIAL.md` - Has theory-specific examples; should become general with links
- `Reference/OPERATORS.md` - Theory-specific operators; should link to theory-specific references

**Content that should move/copy to Logos/docs/**:
- Theory-specific implementation status
- Logos-specific user guide content
- Logos operator/axiom reference

## Recommendations

### 1. Create Logos/docs/ Structure

Mirror Bimodal/docs/ with:
```
Logos/docs/
├── README.md
├── UserGuide/
│   ├── README.md
│   ├── QUICKSTART.md
│   └── PROOF_PATTERNS.md (or similar)
├── Reference/
│   ├── README.md
│   ├── AXIOM_REFERENCE.md
│   └── TACTIC_REFERENCE.md
└── ProjectInfo/
    ├── README.md
    ├── IMPLEMENTATION_STATUS.md
    └── KNOWN_LIMITATIONS.md
```

### 2. Refactor Root docs/

Transform to theory-agnostic hub:
- Update README.md to be genuinely project-wide
- Keep Development/, Architecture/, Installation/ unchanged
- Refactor ProjectInfo/IMPLEMENTATION_STATUS.md to provide overview and link to theory-specific status files
- Update UserGuide/ to be introductory with links to theory-specific guides
- Keep Research/ as-is (already has THEORY_COMPARISON.md)

### 3. Consider Logos' Current Status

Since Logos is currently a re-export layer:
- Documentation should reflect that active development is in Bimodal
- Note Logos' planned second-order hyperintensional extensions
- Link to Bimodal documentation for currently-working implementation
- Create placeholders for future Epistemic, Normative, Explanatory documentation

## References

- Bimodal/docs/README.md - Model for theory-specific documentation
- docs/Development/DIRECTORY_README_STANDARD.md - Template standards
- docs/Research/THEORY_COMPARISON.md - Theory differentiation
- Logos/README.md - Current Logos implementation overview

## Next Steps

1. **Phase 1**: Create Logos/docs/ directory structure with README.md files
2. **Phase 2**: Create UserGuide/ documents (QUICKSTART.md, PROOF_PATTERNS.md)
3. **Phase 3**: Create Reference/ documents (AXIOM_REFERENCE.md, TACTIC_REFERENCE.md)
4. **Phase 4**: Create ProjectInfo/ documents (IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md)
5. **Phase 5**: Refactor root docs/ to be theory-agnostic
6. **Phase 6**: Update cross-links between project-wide and theory-specific docs
7. **Phase 7**: Verify all links work and documentation is consistent

**Effort Estimate**: 4-8 hours (as specified in task)

**Dependencies**: This task unblocks Task 360 Phase 5 (Update project-wide docs/)
