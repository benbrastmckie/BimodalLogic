# Implementation Plan: Task #360

**Task**: Bimodal Theory Polish and Documentation System
**Version**: 001
**Created**: 2026-01-11
**Language**: general

## Revision Summary

**Original Scope**: Create MVP status documentation (30 min effort)
- Document known limitations of Bimodal MVP
- Add Implementation Status sections to READMEs

**Revised Scope**: Comprehensive Bimodal polish and documentation system
1. Put completeness proof tasks on hold
2. Polish all elements of Bimodal/ project
3. Create differentiated documentation for Bimodal (propositional intensional) vs Logos (second-order hyperintensional)
4. Create project-wide docs/ for cross-theory content
5. Create theory-specific Bimodal/docs/ following DIRECTORY_README_STANDARD.md
6. Cross-link between project-wide and theory-specific documentation

**Reason for Revision**: User expanded scope to comprehensive Bimodal theory documentation system with proper separation from Logos theory.

## Overview

This implementation polishes the Bimodal/ project, improves its tests and documentation, and creates a proper documentation architecture that separates:
- **Project-wide documentation** in `/docs/` (applicable to all theories)
- **Theory-specific documentation** in `/Bimodal/docs/` (Bimodal-specific)

The key differentiation between theories:
- **Bimodal/**: Propositional intensional logic where primitive elements are *world-states* in the semantics, and sentence letters are interpreted by sets of world-states
- **Logos/**: Second-order hyperintensional logic (planned) where primitive elements are *states* used to interpret functions, constants, and predicates with variable assignments for first and second-order variables

## Phases

### Phase 1: Deprioritize Completeness Tasks
**Status**: [COMPLETED]
**Estimated effort**: 15 minutes

**Objectives**:
1. Update completeness-related tasks (132-135, 257) to low priority with "on hold" note
2. Document rationale in TODO.md

**Files to modify**:
- `.claude/specs/TODO.md` - Update task priorities
- `.claude/specs/state.json` - Sync priority changes

**Steps**:
1. Read current TODO.md completeness tasks
2. Update priority to "low" with note "On hold pending Bimodal polish"
3. Update state.json to match
4. Git commit changes

**Verification**:
- Completeness tasks show low priority and on-hold status

---

### Phase 2: Bimodal Test Improvements
**Status**: [COMPLETED]
**Estimated effort**: 1-2 hours

**Objectives**:
1. Audit BimodalTest/ for sorry placeholders
2. Complete high-value test implementations
3. Mark intentional exercise sorries explicitly
4. Update BimodalTest/README.md with test status

**Files to modify**:
- `BimodalTest/` - Various test files
- `BimodalTest/README.md` - Add test status section

**Steps**:
1. Run sorry audit: `grep -r "sorry" BimodalTest/`
2. Categorize sorries: completable vs infrastructure vs exercise
3. Complete completable sorries (CompletenessTest, PerpetuityTest, PropositionalTest)
4. Mark exercise sorries with `-- Exercise:` comments
5. Update BimodalTest/README.md with Implementation Status section

**Verification**:
- `lake build BimodalTest` succeeds
- All completable sorries resolved or documented

---

### Phase 3: Create Theory Comparison Document
**Status**: [COMPLETED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Create clear documentation differentiating Bimodal from Logos
2. Explain semantic primitives and logical level differences
3. Place in project-wide docs/ for cross-theory reference

**Files to create**:
- `docs/Research/THEORY_COMPARISON.md` - Bimodal vs Logos comparison

**Content structure**:
```markdown
# Theory Comparison: Bimodal vs Logos

## Overview
Brief comparison of the two logical systems implemented in ProofChecker.

## Bimodal Theory
- **Type**: Propositional intensional logic
- **Semantic primitives**: World-states
- **Interpretation**: Sentence letters → sets of world-states
- **Order**: Propositional (zeroth-order)
- **Status**: Active implementation

## Logos Theory (Planned)
- **Type**: Second-order hyperintensional logic
- **Semantic primitives**: States (more fine-grained than worlds)
- **Interpretation**: Functions, constants, predicates with variable assignments
- **Order**: Second-order with first and second-order variables
- **Status**: Future extension, currently re-exports Bimodal

## Key Differences
1. Semantic granularity
2. Logical expressiveness
3. Proof complexity

## When to Use Each
- Bimodal: Standard modal/temporal reasoning
- Logos: Hyperintensional contexts (propositional attitudes, explanations)
```

**Steps**:
1. Create THEORY_COMPARISON.md with structured comparison
2. Link from docs/README.md
3. Link from both Bimodal/README.md and Logos/README.md

**Verification**:
- Document accurately reflects theoretical differences
- Cross-references work correctly

---

### Phase 4: Create Bimodal/docs/ Structure
**Status**: [COMPLETED]
**Estimated effort**: 1 hour

**Objectives**:
1. Create theory-specific documentation directory following DIRECTORY_README_STANDARD.md
2. Organize by documentation type (UserGuide, Reference, Development)
3. Cross-link with project-wide docs/

**Directory structure to create**:
```
Bimodal/docs/
├── README.md                    # Navigation hub (Template G style)
├── UserGuide/
│   ├── README.md               # Reading order
│   ├── QUICKSTART.md           # Bimodal-specific quick start
│   └── PROOF_PATTERNS.md       # Common proof patterns in Bimodal
├── Reference/
│   ├── README.md               # Quick lookup guide
│   ├── AXIOM_REFERENCE.md      # Complete axiom reference with examples
│   └── TACTIC_REFERENCE.md     # Bimodal-specific tactic usage
└── ProjectInfo/
    ├── README.md               # Status overview
    ├── IMPLEMENTATION_STATUS.md # Bimodal-specific status
    └── KNOWN_LIMITATIONS.md    # MVP limitations with workarounds
```

**Files to create**:
- `Bimodal/docs/README.md` - Main navigation hub
- `Bimodal/docs/UserGuide/README.md` - User guide index
- `Bimodal/docs/Reference/README.md` - Reference index
- `Bimodal/docs/ProjectInfo/README.md` - Project info index
- Other files as needed

**Steps**:
1. Create directory structure
2. Create README.md files following Template G
3. Populate UserGuide/QUICKSTART.md with Bimodal-specific introduction
4. Populate Reference/AXIOM_REFERENCE.md with axiom schemas and examples
5. Populate ProjectInfo/IMPLEMENTATION_STATUS.md
6. Populate ProjectInfo/KNOWN_LIMITATIONS.md with MVP limitations

**Verification**:
- All README files follow DIRECTORY_README_STANDARD.md
- Cross-links between directories work
- DOC_QUALITY_CHECKLIST.md items satisfied

---

### Phase 5: Update Project-Wide Documentation
**Status**: [BLOCKED]
**Blocked by**: Task 372 (Logos/docs/ reorganization)
**Estimated effort**: 45 minutes

**Note**: This phase is on hold to avoid losing Logos-relevant content in docs/.
Task 372 will move Logos-specific content to Logos/docs/ first, then this
phase can update docs/ with cross-links to both theory-specific directories.

**Objectives**:
1. Ensure docs/ contains only cross-theory content
2. Move any Bimodal-specific content to Bimodal/docs/
3. Update Navigation links to include theory-specific docs

**Files to modify**:
- `docs/README.md` - Add theory-specific doc links
- `docs/NAVIGATION.md` - Update navigation structure
- Various files as needed

**Steps**:
1. Audit docs/ for Bimodal-specific content
2. Move Bimodal-specific content to Bimodal/docs/ or generalize
3. Add "Theory-Specific Documentation" section to docs/README.md
4. Link to Bimodal/docs/README.md
5. Update NAVIGATION.md

**Verification**:
- docs/ contains only cross-theory content
- Clear links to theory-specific docs

---

### Phase 6: Update Bimodal/README.md
**Status**: [COMPLETED]
**Estimated effort**: 30 minutes

**Objectives**:
1. Add theory differentiation section
2. Link to Bimodal/docs/
3. Update Implementation Status with MVP limitations
4. Add navigation to theory-specific documentation

**Files to modify**:
- `Bimodal/README.md` - Major update

**Content to add**:
```markdown
## About Bimodal Logic

Bimodal is a **propositional intensional logic** implementing TM (Tense and Modality).

**Semantic Primitives**: World-states in a Kripke-style framework
**Interpretation**: Sentence letters are interpreted by sets of world-states
**Logical Level**: Propositional (zeroth-order)

For comparison with the planned Logos hyperintensional logic, see
[Theory Comparison](../docs/Research/THEORY_COMPARISON.md).

## Theory-Specific Documentation

For Bimodal-specific documentation, see [docs/](docs/README.md):
- [Quick Start](docs/UserGuide/QUICKSTART.md)
- [Proof Patterns](docs/UserGuide/PROOF_PATTERNS.md)
- [Axiom Reference](docs/Reference/AXIOM_REFERENCE.md)
- [Implementation Status](docs/ProjectInfo/IMPLEMENTATION_STATUS.md)
- [Known Limitations](docs/ProjectInfo/KNOWN_LIMITATIONS.md)
```

**Steps**:
1. Add "About Bimodal Logic" section explaining theory type
2. Add "Theory-Specific Documentation" section
3. Update "Implementation Status" with clearer MVP notes
4. Update "Related Documentation" to include theory-specific docs

**Verification**:
- README clearly explains what Bimodal is
- Navigation to docs/ is clear
- All links work

---

### Phase 7: Quality Assurance (Bimodal Only)
**Status**: [COMPLETED]
**Estimated effort**: 30 minutes

**Note**: This phase focuses on Bimodal/ and Bimodal/docs/ only.
docs/ QA will be done after Task 372 completes.

**Objectives**:
1. Run DOC_QUALITY_CHECKLIST.md checks on Bimodal/docs/
2. Verify cross-links work within Bimodal/
3. Verify formatting compliance

**Steps**:
1. Verify all markdown links in Bimodal/ resolve
2. Check 100-character line limits in new files
3. Check formal symbol backticks
4. Fix any issues found

**Verification**:
- No broken links in Bimodal/
- Formatting compliant in new documentation

---

## Dependencies

- None external
- Internal: Each phase builds on previous

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Large scope expansion | High | Phase-by-phase implementation with commits |
| Broken cross-links | Medium | Verify all links during QA phase |
| Documentation drift | Medium | Follow DIRECTORY_README_STANDARD.md strictly |
| Bimodal test sorries complex | Medium | Mark complex ones as exercises rather than complete |

## Success Criteria

- [ ] Completeness tasks deprioritized and documented
- [ ] BimodalTest sorries resolved or documented as exercises
- [ ] THEORY_COMPARISON.md created and linked
- [ ] Bimodal/docs/ directory structure created
- [ ] All READMEs follow DIRECTORY_README_STANDARD.md
- [ ] docs/ contains only cross-theory content
- [ ] Bimodal/README.md updated with theory differentiation
- [ ] All DOC_QUALITY_CHECKLIST.md checks pass
- [ ] `lake build` succeeds
- [ ] All cross-links verified working
