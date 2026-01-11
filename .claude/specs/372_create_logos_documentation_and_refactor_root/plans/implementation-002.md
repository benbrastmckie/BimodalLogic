# Implementation Plan: Task #372

**Task**: Create Logos/Documentation/ and Refactor Root Documentation/
**Version**: 002
**Created**: 2026-01-11
**Revision of**: implementation-001.md
**Language**: general

## Revision Summary

**Reason**: Ensure minimal overlap between theory-specific documentation
(Logos/Documentation/, Bimodal/Documentation/) and project-wide documentation
(ProofChecker/Documentation/), with natural cross-linking integration.

### Previous Plan Issues

1. Phase 5 was underspecified - didn't account for Task 360 Phase 5 objectives
2. Overlap analysis was insufficient
3. Cross-linking strategy wasn't explicit

### Key Changes

1. **Explicit content separation principle**: Each document lives in exactly one place
2. **Clear cross-linking pattern**: Theory-specific docs link UP to project-wide for shared
   standards; project-wide docs link DOWN to theory-specific for implementations
3. **Consolidated Phase 5**: Merged with Task 360 Phase 5 objectives
4. **Reduced duplication**: Logos docs reference Bimodal directly for re-exported content

## Content Separation Principle

### Project-Wide Documentation (Documentation/)

Content that applies to **all theories** regardless of implementation:

| Category | Content Type | Examples |
|----------|-------------|----------|
| Development/ | Coding standards | LEAN_STYLE_GUIDE.md, TESTING_STANDARDS.md |
| Installation/ | Setup guides | All installation docs |
| Architecture/ | ADRs | Project-wide decisions |
| Research/ | Theory comparison | THEORY_COMPARISON.md |
| Reference/ | Shared terminology | GLOSSARY.md, generic OPERATORS.md |
| UserGuide/ | General concepts | METHODOLOGY.md, ARCHITECTURE.md overview |
| ProjectInfo/ | Project-wide status | Aggregated status, MAINTENANCE.md |

### Theory-Specific Documentation (Bimodal/Documentation/, Logos/Documentation/)

Content that is **unique to that theory**:

| Category | Content Type | Examples |
|----------|-------------|----------|
| UserGuide/ | Theory-specific guides | QUICKSTART.md, PROOF_PATTERNS.md |
| Reference/ | Theory-specific reference | AXIOM_REFERENCE.md, TACTIC_REFERENCE.md |
| ProjectInfo/ | Theory-specific status | IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md |

### Cross-Linking Pattern

```
Theory-specific docs → Project-wide docs
  "For coding standards, see Documentation/Development/LEAN_STYLE_GUIDE.md"

Project-wide docs → Theory-specific docs
  "For Bimodal axioms, see Bimodal/Documentation/Reference/AXIOM_REFERENCE.md"
  "For Logos status, see Logos/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md"
```

## Phases

### Phase 1: Create Logos/Documentation/ Directory Structure
**Status**: [COMPLETED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Create directory structure mirroring Bimodal/Documentation/
2. Create README.md navigation hub following Template G
3. Include note directing to project-wide docs for shared content

**Files to create**:
```
Logos/Documentation/
├── README.md                    # Navigation hub with cross-link note
├── UserGuide/
│   └── README.md
├── Reference/
│   └── README.md
└── ProjectInfo/
    └── README.md
```

**Steps**:
1. Create directory structure
2. Create Logos/Documentation/README.md with:
   - Note about project-wide docs at top (like Bimodal)
   - About Logos Logic section explaining current/planned status
   - Documentation Organization section
   - Cross-link to THEORY_COMPARISON.md
3. Create subdirectory README.md files

**Verification**:
- Structure mirrors Bimodal/Documentation/
- Cross-link note present at top

---

### Phase 2: Create Logos UserGuide Documents
**Status**: [COMPLETED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Create QUICKSTART.md explaining Logos' current status
2. Create CURRENT_STATUS.md (instead of PROOF_PATTERNS.md since Logos is re-export)

**Files to create**:
- `Logos/Documentation/UserGuide/QUICKSTART.md`
- `Logos/Documentation/UserGuide/CURRENT_STATUS.md`

**Content notes** (minimal overlap):
- QUICKSTART.md: Explains Logos re-exports Bimodal, links to Bimodal/Documentation/
  UserGuide/QUICKSTART.md for actual usage. NO duplicate content.
- CURRENT_STATUS.md: Unique to Logos - explains planned hyperintensional extensions

**Steps**:
1. Create QUICKSTART.md that redirects to Bimodal with explanation
2. Create CURRENT_STATUS.md documenting Logos-specific roadmap
3. Update UserGuide/README.md

**Verification**:
- No duplicated content from Bimodal
- Clear redirect for working functionality

---

### Phase 3: Create Logos Reference Documents
**Status**: [COMPLETED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Create AXIOM_REFERENCE.md (redirect to Bimodal with explanation)
2. Create EXTENSION_STUBS.md (unique to Logos)

**Files to create**:
- `Logos/Documentation/Reference/AXIOM_REFERENCE.md`
- `Logos/Documentation/Reference/EXTENSION_STUBS.md`

**Content notes** (minimal overlap):
- AXIOM_REFERENCE.md: Brief note that Logos re-exports Bimodal axioms, link to
  Bimodal/Documentation/Reference/AXIOM_REFERENCE.md. NO duplicate axiom content.
- EXTENSION_STUBS.md: Unique content documenting Epistemic/, Normative/, Explanatory/

**Steps**:
1. Create AXIOM_REFERENCE.md as redirect
2. Create EXTENSION_STUBS.md with planned extension details
3. Update Reference/README.md

**Verification**:
- AXIOM_REFERENCE.md is minimal redirect, not duplicate
- EXTENSION_STUBS.md contains unique Logos content

---

### Phase 4: Create Logos ProjectInfo Documents
**Status**: [COMPLETED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Create IMPLEMENTATION_STATUS.md (Logos-specific)
2. Create KNOWN_LIMITATIONS.md (Logos-specific)
3. Create ROADMAP.md (unique to Logos - hyperintensional development path)

**Files to create**:
- `Logos/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- `Logos/Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`
- `Logos/Documentation/ProjectInfo/ROADMAP.md`

**Content notes** (minimal overlap):
- Status: Logos-specific only (re-export status, stub modules)
- Limitations: "Not yet implemented" with link to Bimodal for working features
- Roadmap: Unique - path to second-order hyperintensional implementation

**Steps**:
1. Create IMPLEMENTATION_STATUS.md documenting current re-export state
2. Create KNOWN_LIMITATIONS.md pointing to Bimodal for functionality
3. Create ROADMAP.md with hyperintensional development phases
4. Update ProjectInfo/README.md

**Verification**:
- Status reflects actual Logos state (not Bimodal state copy)
- Roadmap provides unique development path

---

### Phase 5: Refactor Project-Wide Documentation/
**Status**: [COMPLETED]
**Estimated effort**: 1 hour

**Note**: This phase also completes Task 360 Phase 5.

**Objectives** (from Task 360 Phase 5 + new requirements):
1. Ensure Documentation/ contains only cross-theory content
2. Add "Theory-Specific Documentation" section to key files
3. Update NAVIGATION.md with theory-specific links
4. Audit for theory-specific content and generalize or move

**Files to modify**:
- `Documentation/README.md` - Add theory-specific documentation section
- `Documentation/NAVIGATION.md` - Add theory navigation
- `Documentation/ProjectInfo/README.md` - Add links to theory status
- `Documentation/UserGuide/README.md` - Add links to theory guides
- `Documentation/Reference/README.md` - Add links to theory references

**Content to add to Documentation/README.md**:
```markdown
## Theory-Specific Documentation

For theory-specific documentation, see:

| Theory | Description | Documentation |
|--------|-------------|---------------|
| **Bimodal** | Propositional intensional logic (active) | [Bimodal/Documentation/](../Bimodal/Documentation/) |
| **Logos** | Second-order hyperintensional (planned) | [Logos/Documentation/](../Logos/Documentation/) |

For comparison between theories, see [THEORY_COMPARISON.md](Research/THEORY_COMPARISON.md).
```

**Steps**:
1. Add "Theory-Specific Documentation" section to Documentation/README.md
2. Update NAVIGATION.md with theory navigation section
3. Update ProjectInfo/README.md to link to theory-specific status
4. Update UserGuide/README.md to link to theory-specific guides
5. Update Reference/README.md to link to theory-specific references
6. Audit existing content for theory-specific material:
   - If Bimodal-specific: Link to Bimodal/Documentation/ instead
   - If Logos-specific: Link to Logos/Documentation/ instead
   - If genuinely cross-theory: Keep and generalize language

**Verification**:
- "Theory-Specific Documentation" section present in README.md
- NAVIGATION.md includes theory navigation
- No theory-specific content without proper context/link
- Task 360 Phase 5 objectives satisfied

---

### Phase 6: Update Logos/README.md
**Status**: [NOT STARTED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Add "About Logos Logic" section (like Bimodal/README.md)
2. Add "Theory-Specific Documentation" section with links
3. Update "Related Documentation" and "Navigation"

**Files to modify**:
- `Logos/README.md`

**Content to add**:
```markdown
## About Logos Logic

Logos is a **planned second-order hyperintensional logic** that will extend beyond Bimodal.

| Aspect | Description |
|--------|-------------|
| **Type** | Second-order hyperintensional logic (planned) |
| **Current status** | Re-exports Bimodal TM logic |
| **Semantic primitives** | States (more fine-grained than worlds) |
| **Logical level** | Second-order with first and second-order variables |

For comparison with Bimodal propositional logic, see
[THEORY_COMPARISON.md](../Documentation/Research/THEORY_COMPARISON.md).

## Theory-Specific Documentation

For Logos-specific guides and references, see [Documentation/](Documentation/README.md):

| Document | Description |
|----------|-------------|
| [Quick Start](Documentation/UserGuide/QUICKSTART.md) | Getting started (currently redirects to Bimodal) |
| [Current Status](Documentation/UserGuide/CURRENT_STATUS.md) | Logos development status |
| [Extension Stubs](Documentation/Reference/EXTENSION_STUBS.md) | Planned extensions |
| [Implementation Status](Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md) | Module status |
| [Roadmap](Documentation/ProjectInfo/ROADMAP.md) | Development roadmap |
```

**Steps**:
1. Add "About Logos Logic" section with table
2. Add "Theory-Specific Documentation" section
3. Update "Related Documentation" to distinguish theory-specific vs project-wide
4. Update Navigation to include Documentation/

**Verification**:
- README mirrors Bimodal/README.md structure
- Clear distinction between Logos-specific and project-wide docs

---

### Phase 7: Complete Task 360 and Quality Assurance
**Status**: [NOT STARTED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Mark Task 360 as COMPLETED (Phase 5 now done)
2. Verify all cross-links work
3. Check formatting compliance
4. Verify minimal overlap achieved

**Steps**:
1. Update Task 360 status to COMPLETED in state.json and TODO.md
2. Run link verification across all documentation directories
3. Check 100-character line limits in new files
4. Verify formal symbol backticks
5. Spot-check for content duplication
6. Git commit all changes

**Verification**:
- Task 360 status is COMPLETED
- No broken links
- All files comply with DOC_QUALITY_CHECKLIST.md
- Minimal content overlap verified

---

## Dependencies

- None external
- Unblocks: Task 360 (completes Phase 5)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Content duplication | Medium | Medium | Strict redirect pattern for re-exported content |
| Broken cross-links | Medium | Low | Verify all links in QA phase |
| Task 360 objectives missed | High | Low | Explicit checklist in Phase 5 |

## Success Criteria

- [ ] Logos/Documentation/ structure created (mirrors Bimodal/Documentation/)
- [ ] Minimal overlap: Logos docs redirect to Bimodal for re-exported content
- [ ] Documentation/ has "Theory-Specific Documentation" section
- [ ] NAVIGATION.md includes theory navigation
- [ ] All cross-links verified working
- [ ] Task 360 marked COMPLETED
- [ ] DOC_QUALITY_CHECKLIST.md compliance verified

## Task 360 Phase 5 Checklist

From implementation-001.md Phase 5 objectives:
- [ ] Documentation/ contains only cross-theory content
- [ ] Bimodal-specific content moved or linked (audit complete)
- [ ] "Theory-Specific Documentation" section in Documentation/README.md
- [ ] Link to Bimodal/Documentation/README.md added
- [ ] Link to Logos/Documentation/README.md added
- [ ] NAVIGATION.md updated

## Rollback Plan

If documentation refactoring causes issues:
1. Revert changes via git
2. Restore original Documentation/ structure
3. Remove Logos/Documentation/ directory
