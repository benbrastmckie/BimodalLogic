# Implementation Plan: Task #372

**Task**: Create Logos/docs/ and Refactor Root docs/
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Overview

Create a theory-specific documentation structure for Logos/ (mirroring Bimodal/docs/)
and refactor the root docs/ directory to be genuinely theory-agnostic. This unblocks
Task 360 Phase 5.

Key insight from research: Logos is currently a re-export layer for Bimodal with stubs for
planned second-order hyperintensional extensions. Documentation should reflect this status
while preparing for future expansion.

## Phases

### Phase 1: Create Logos/docs/ Directory Structure
**Status**: [NOT STARTED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Create directory structure mirroring Bimodal/docs/
2. Create README.md navigation hub following Template G

**Files to create**:
```
Logos/docs/
├── README.md
├── UserGuide/
│   └── README.md
├── Reference/
│   └── README.md
└── ProjectInfo/
    └── README.md
```

**Steps**:
1. Create directory structure with `mkdir -p`
2. Create Logos/docs/README.md following Template G
3. Create UserGuide/README.md with category description
4. Create Reference/README.md with category description
5. Create ProjectInfo/README.md with category description

**Verification**:
- All directories exist
- All README.md files follow DIRECTORY_README_STANDARD.md

---

### Phase 2: Create Logos UserGuide Documents
**Status**: [NOT STARTED]
**Estimated effort**: 45 minutes

**Objectives**:
1. Create QUICKSTART.md for Logos-specific introduction
2. Create PROOF_PATTERNS.md or CURRENT_STATUS.md explaining re-export status

**Files to create**:
- `Logos/docs/user-guide/QUICKSTART.md`
- `Logos/docs/user-guide/CURRENT_STATUS.md`

**Content notes**:
- QUICKSTART.md should explain Logos is currently a re-export of Bimodal
- Direct users to Bimodal documentation for working implementation
- Explain planned extensions (Epistemic, Normative, Explanatory)
- CURRENT_STATUS.md documents Logos' nature as planned second-order hyperintensional logic

**Steps**:
1. Create QUICKSTART.md explaining current Logos status
2. Create CURRENT_STATUS.md documenting planned vs implemented features
3. Link to Bimodal/Documentation for working implementation
4. Update UserGuide/README.md with links

**Verification**:
- Documents accurately reflect Logos' current re-export status
- Clear guidance to Bimodal for working features

---

### Phase 3: Create Logos Reference Documents
**Status**: [NOT STARTED]
**Estimated effort**: 45 minutes

**Objectives**:
1. Create AXIOM_REFERENCE.md documenting Logos axioms (currently re-exports Bimodal)
2. Create EXTENSION_STUBS.md documenting planned extension modules

**Files to create**:
- `Logos/docs/reference/AXIOM_REFERENCE.md`
- `Logos/docs/reference/EXTENSION_STUBS.md`

**Content notes**:
- AXIOM_REFERENCE.md should note re-export of Bimodal axioms
- Link to Bimodal axiom reference for details
- EXTENSION_STUBS.md documents Epistemic/, Normative/, Explanatory/ stubs

**Steps**:
1. Create AXIOM_REFERENCE.md noting re-export status
2. Create EXTENSION_STUBS.md documenting planned extensions
3. Update Reference/README.md with links

**Verification**:
- References accurately reflect re-export relationship
- Extension stubs documented for future work

---

### Phase 4: Create Logos ProjectInfo Documents
**Status**: [NOT STARTED]
**Estimated effort**: 45 minutes

**Objectives**:
1. Create IMPLEMENTATION_STATUS.md for Logos-specific status
2. Create KNOWN_LIMITATIONS.md documenting current limitations
3. Create ROADMAP.md outlining future development

**Files to create**:
- `Logos/docs/project-info/IMPLEMENTATION_STATUS.md`
- `Logos/docs/project-info/KNOWN_LIMITATIONS.md`
- `Logos/docs/project-info/ROADMAP.md`

**Content notes**:
- Status should clearly indicate re-export layer nature
- Roadmap should outline path to full second-order implementation
- Cross-link to THEORY_COMPARISON.md

**Steps**:
1. Create IMPLEMENTATION_STATUS.md documenting re-export status
2. Create KNOWN_LIMITATIONS.md (essentially "not yet implemented")
3. Create ROADMAP.md with planned development phases
4. Update ProjectInfo/README.md with links

**Verification**:
- Status accurately reflects current state
- Roadmap provides clear future direction

---

### Phase 5: Refactor Root docs/ to Theory-Agnostic
**Status**: [NOT STARTED]
**Estimated effort**: 1 hour

**Objectives**:
1. Update docs/README.md to be genuinely project-wide
2. Update ProjectInfo/IMPLEMENTATION_STATUS.md to overview with links
3. Update UserGuide/ files to be introductory with theory links
4. Add "Theory-Specific Documentation" section throughout

**Files to modify**:
- `docs/README.md` - Add theory-specific section
- `docs/project-info/IMPLEMENTATION_STATUS.md` - Overview only
- `docs/user-guide/README.md` - Add theory links
- `docs/reference/README.md` - Add theory links

**Steps**:
1. Update docs/README.md with theory-specific doc links
2. Refactor IMPLEMENTATION_STATUS.md to overview linking to theory status
3. Add "Theory-Specific Documentation" sections to relevant README files
4. Verify no theory-specific content remains without proper context

**Verification**:
- docs/ is genuinely theory-agnostic
- Clear links to Bimodal/docs/ and Logos/docs/

---

### Phase 6: Update Logos/README.md
**Status**: [NOT STARTED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Add "Theory-Specific Documentation" section similar to Bimodal/README.md
2. Update links to point to new Logos/docs/
3. Add note about re-export relationship to Bimodal

**Files to modify**:
- `Logos/README.md`

**Steps**:
1. Add "About Logos Logic" section explaining planned hyperintensional nature
2. Add "Theory-Specific Documentation" section with links
3. Update "Related Documentation" section
4. Update Navigation to include docs/

**Verification**:
- README clearly explains Logos' current and planned status
- Clear navigation to documentation

---

### Phase 7: Cross-Link and Quality Assurance
**Status**: [NOT STARTED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Verify all cross-links between documentation directories
2. Check 100-character line limits
3. Verify formatting compliance with DOC_QUALITY_CHECKLIST.md
4. Complete Task 360 Phase 5 (update project-wide docs/)

**Steps**:
1. Run link verification across all documentation
2. Check line length compliance
3. Verify formal symbol backticks
4. Update Task 360 status if Phase 5 can complete
5. Git commit all changes

**Verification**:
- No broken links in any documentation
- All files comply with formatting standards
- Task 360 Phase 5 unblocked

---

## Dependencies

- None external
- Unblocks: Task 360 Phase 5 (Update project-wide docs/)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Logos content scattered in root docs | Medium | Medium | Careful audit before refactoring |
| Breaking existing links | Medium | Low | Verify all links in QA phase |
| Scope creep to full Logos docs | Medium | Low | Focus on re-export status, not full theory |

## Success Criteria

- [ ] Logos/docs/ structure created (mirrors Bimodal/docs/)
- [ ] All README.md files follow DIRECTORY_README_STANDARD.md Template G
- [ ] Root docs/ is theory-agnostic
- [ ] Theory-specific documentation clearly linked from both roots
- [ ] THEORY_COMPARISON.md properly cross-referenced
- [ ] Task 360 Phase 5 unblocked
- [ ] All links verified working
- [ ] DOC_QUALITY_CHECKLIST.md compliance verified

## Rollback Plan

If documentation refactoring causes issues:
1. Revert changes via git (all changes in single commit per phase)
2. Restore original docs/ structure
3. Remove Logos/docs/ directory
