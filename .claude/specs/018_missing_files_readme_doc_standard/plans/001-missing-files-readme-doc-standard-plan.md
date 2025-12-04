# Missing Files, README Documentation, and Documentation Standard Implementation Plan

## Metadata
- **Date**: 2025-12-02
- **Feature**: Fix missing documented files, remove Counterexamples/, create directory READMEs, establish DIRECTORY_README_STANDARD.md
- **Scope**: Documentation accuracy, project structure cleanup, directory-level documentation standard creation
- **Estimated Phases**: 7
- **Estimated Hours**: 12
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Structure Level**: 0
- **Complexity Score**: 78.0
- **Research Reports**:
  - [Missing Files README Analysis](/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/018_missing_files_readme_doc_standard/reports/001_missing_files_readme_analysis.md)

## Overview

This plan addresses three critical documentation and structure issues identified in the research report:

1. **Missing Files**: Three files documented in README.md and CLAUDE.md but not implemented (DSL.lean, Rules.lean, Decidability.lean) require resolution
2. **Counterexamples Removal**: Stub-only Counterexamples/ directory violates TDD principles and should be removed
3. **Directory READMEs**: Archive/, Documentation/, Logos/, and LogosTest/ lack README.md files for navigation
4. **Documentation Standard**: Create DIRECTORY_README_STANDARD.md for LEAN 4 project directory documentation

The implementation follows a systematic approach: (1) update documentation to match reality, (2) remove stub structures, (3) establish directory documentation standard, (4) create directory READMEs following the new standard.

## Research Summary

Key findings from the missing files README analysis report:

- **DSL.lean**: Documented but not implemented; no imports found in Logos/Syntax.lean
- **Rules.lean**: Documented as separate file but rules are actually in Derivation.lean (documentation inaccuracy)
- **Decidability.lean**: Documented but marked as "planned" in README.md; not yet started
- **Counterexamples/**: Stub-only directory with comprehensive documentation but no implementations; violates TDD principles
- **Directory READMEs**: Four major directories (Archive/, Documentation/, Logos/, LogosTest/) lack README.md files
- **Documentation Standard Gap**: Existing documentation-standards.md covers .claude/ system only; LEAN 4 project directories need separate standard

Recommended approach based on research:
- Update documentation to reflect actual file structure (Rules.lean → Derivation.lean)
- Mark Decidability.lean consistently as "planned"
- Remove Counterexamples/ directory entirely (can be restored when needed)
- Create DIRECTORY_README_STANDARD.md for LEAN 4 projects (complements existing LEAN_STYLE_GUIDE.md)
- Implement directory READMEs following new standard

## Success Criteria

- [ ] Documentation accurately reflects actual project structure (no references to non-existent implemented files)
- [ ] DSL.lean status clarified in README.md and CLAUDE.md (missing or alternative location)
- [ ] Rules.lean references updated to Derivation.lean in project structure diagrams
- [ ] Decidability.lean consistently marked as "planned" across all documentation
- [ ] Counterexamples/ directory removed from codebase and lakefile.toml
- [ ] Counterexamples/ references removed from README.md and CLAUDE.md
- [ ] DIRECTORY_README_STANDARD.md created in Documentation/Development/
- [ ] Archive/README.md created following new standard
- [ ] Documentation/README.md created following new standard
- [ ] LogosTest/README.md created following new standard
- [ ] Logos/README.md created following new standard (optional, lightweight)
- [ ] All directory READMEs provide clear navigation and purpose
- [ ] Project builds successfully: `lake build`
- [ ] Tests pass: `lake test`
- [ ] No broken links in documentation

## Technical Design

### Architecture Overview

This implementation involves four parallel workstreams:

1. **Documentation Correction** (Phases 1-2): Fix inaccuracies in README.md and CLAUDE.md
2. **Structure Cleanup** (Phase 3): Remove stub-only Counterexamples/ directory
3. **Standards Creation** (Phase 4): Establish DIRECTORY_README_STANDARD.md
4. **README Implementation** (Phases 5-7): Create directory READMEs following new standard

### File Organization

**Modified Files**:
- README.md: Update project structure diagrams, implementation status
- CLAUDE.md: Update project structure diagrams, file references
- lakefile.toml: Remove Counterexamples module reference

**Removed Directory**:
- Counterexamples/: Complete removal (single file, stub-only)

**Created Files**:
- Documentation/Development/DIRECTORY_README_STANDARD.md: New standard for LEAN 4 directory documentation
- Archive/README.md: Pedagogical examples navigation
- Documentation/README.md: Documentation organization guide
- LogosTest/README.md: Test suite guide
- Logos/README.md: Source directory guide (optional, lightweight)

### Documentation Standard Design

The DIRECTORY_README_STANDARD.md will follow this structure:

1. **Purpose and Scope**: LEAN 4 project directories (not .claude/ system)
2. **Classification Rules**: When README.md required vs. when .lean module documentation suffices
3. **Template D**: LEAN source directories (lightweight, navigation-focused)
4. **Template E**: LEAN test directories (test running, organization, conventions)
5. **Template F**: LEAN example directories (pedagogical focus, learning paths)
6. **Template G**: Documentation directories (guide to documentation resources)
7. **Relationship to doc-gen4**: Acknowledge automatic API documentation generation
8. **Anti-patterns**: Duplication of .lean module documentation

### README Content Strategy

**Archive/README.md**:
- Overview of pedagogical examples (modal, temporal, bimodal)
- Guide to example categories and learning paths
- How to run examples (import statements, VS Code workflow)
- Link to Archive.lean for API documentation

**Documentation/README.md**:
- Navigation guide to 4 subdirectories (UserGuide/, ProjectInfo/, Development/, Reference/)
- Audience guide (users vs. developers)
- Quick links to most-referenced documents
- Documentation update workflow

**LogosTest/README.md**:
- Test organization by module (8 subdirectories)
- Running tests (`lake test`, `lake test LogosTest.Syntax`)
- Adding new tests (naming conventions, file placement)
- Test categories (unit, integration, property-based)
- Coverage requirements (link to TESTING_STANDARDS.md)

**Logos/README.md** (optional):
- Module organization (6 submodules)
- Source file map (where to find specific functionality)
- Link to Logos.lean for API overview
- Build and type-check commands

### Integration with Existing Standards

- **Extends** .claude/docs/reference/standards/documentation-standards.md for LEAN 4 projects
- **Complements** Documentation/Development/LEAN_STYLE_GUIDE.md (directory-level vs. code-level)
- **References** Documentation/Development/TESTING_STANDARDS.md for test directory documentation
- **Follows** Documentation/Development/MODULE_ORGANIZATION.md for structure alignment

## Implementation Phases

### Phase 1: Clarify Missing File Status [COMPLETE]
dependencies: []

**Objective**: Update README.md and CLAUDE.md to accurately reflect missing files status (DSL.lean, Decidability.lean) and correct Rules.lean references

**Complexity**: Low

**Tasks**:
- [x] Update README.md project structure diagram (lines ~185): Change `Rules.lean` to note "Rules defined in Derivation.lean"
- [x] Update CLAUDE.md project structure diagram (lines ~58): Change `Rules.lean` to note "Rules defined in Derivation.lean"
- [x] Add comment in README.md: DSL.lean is documented but not yet implemented
- [x] Add comment in CLAUDE.md: DSL.lean is documented but not yet implemented
- [x] Update README.md: Mark Decidability.lean as "planned" with clear status
- [x] Update CLAUDE.md: Mark Decidability.lean as "planned" with clear status
- [x] Verify consistency across both files for missing file documentation

**Testing**:
```bash
# Verify documentation changes
grep -n "DSL.lean" README.md CLAUDE.md
grep -n "Rules.lean" README.md CLAUDE.md
grep -n "Decidability.lean" README.md CLAUDE.md

# Ensure no broken references
grep -n "ProofSystem/Rules.lean" README.md CLAUDE.md
```

**Expected Duration**: 1 hour

### Phase 2: Update Archive Examples Documentation [COMPLETE]
dependencies: []

**Objective**: Clarify status of ModalProofs.lean and TemporalProofs.lean in project structure diagrams

**Complexity**: Low

**Tasks**:
- [x] Update README.md Archive section: Mark ModalProofs.lean and TemporalProofs.lean as "planned"
- [x] Update CLAUDE.md Archive section: Mark ModalProofs.lean and TemporalProofs.lean as "planned"
- [x] Add comment noting Archive.lean has commented imports for future files
- [x] Ensure Archive/BimodalProofs.lean is correctly documented as implemented
- [x] Verify Archive.lean module documentation matches reality

**Testing**:
```bash
# Verify Archive example documentation
grep -n "ModalProofs.lean" README.md CLAUDE.md
grep -n "TemporalProofs.lean" README.md CLAUDE.md
grep -n "BimodalProofs.lean" README.md CLAUDE.md

# Check Archive directory structure
ls -la Archive/
```

**Expected Duration**: 0.5 hours

### Phase 3: Remove Counterexamples Directory [COMPLETE]
dependencies: []

**Objective**: Remove stub-only Counterexamples/ directory and update all documentation references

**Complexity**: Low

**Tasks**:
- [x] Remove Counterexamples/ directory: `rm -rf Counterexamples/`
- [x] Update lakefile.toml: Remove `[[lean_lib]] name = "Counterexamples"` section (lines 15-16)
- [x] Update README.md: Remove Counterexamples/ from project structure diagram (lines ~217-218)
- [x] Update README.md: Remove Counterexamples/ from implementation status (line ~99)
- [x] Update CLAUDE.md: Remove Counterexamples/ from project structure diagram (lines ~87-88)
- [x] Add note to KNOWN_LIMITATIONS.md: "Counterexamples are planned for future implementation"
- [x] Verify no code imports from Counterexamples module

**Testing**:
```bash
# Verify directory removed
test ! -d Counterexamples && echo "Directory removed successfully"

# Verify lakefile.toml updated
! grep -q "Counterexamples" lakefile.toml && echo "lakefile.toml updated"

# Verify documentation updated
! grep -q "Counterexamples/" README.md && echo "README.md updated"
! grep -q "Counterexamples/" CLAUDE.md && echo "CLAUDE.md updated"

# Verify no import references
! grep -r "import Counterexamples" Logos/ LogosTest/ Archive/ && echo "No import references"

# Build test
lake build

# Test suite
lake test
```

**Expected Duration**: 1 hour

### Phase 4: Create DIRECTORY_README_STANDARD.md [COMPLETE]
dependencies: []

**Objective**: Establish comprehensive documentation standard for LEAN 4 project directory READMEs

**Complexity**: Medium

**Tasks**:
- [x] Create Documentation/Development/DIRECTORY_README_STANDARD.md
- [x] Write "Purpose and Scope" section (LEAN 4 projects, not .claude/ system)
- [x] Write "When README Required" section (classification rules for source/test/example/docs directories)
- [x] Create Template D: LEAN Source Directory (lightweight, navigation-focused)
- [x] Create Template E: LEAN Test Directory (test running, organization, conventions)
- [x] Create Template F: LEAN Example Directory (pedagogical focus, learning paths)
- [x] Create Template G: Documentation Directory (guide to documentation resources)
- [x] Write "Relationship to doc-gen4" section (avoid duplicating .lean module documentation)
- [x] Write "Integration with Existing Standards" section (references to LEAN_STYLE_GUIDE.md, TESTING_STANDARDS.md)
- [x] Write "Anti-patterns" section (duplication, over-documentation)
- [x] Add usage examples for each template
- [x] Add reference to mathlib4 documentation practices

**Testing**:
```bash
# Verify file created
test -f Documentation/Development/DIRECTORY_README_STANDARD.md && echo "Standard created"

# Verify required sections present
grep -q "Purpose and Scope" Documentation/Development/DIRECTORY_README_STANDARD.md
grep -q "Template D" Documentation/Development/DIRECTORY_README_STANDARD.md
grep -q "Template E" Documentation/Development/DIRECTORY_README_STANDARD.md
grep -q "Template F" Documentation/Development/DIRECTORY_README_STANDARD.md
grep -q "Template G" Documentation/Development/DIRECTORY_README_STANDARD.md

# Verify file is well-formatted
wc -l Documentation/Development/DIRECTORY_README_STANDARD.md  # Should be substantial (200+ lines)
```

**Expected Duration**: 3 hours

### Phase 5: Create Archive/README.md [COMPLETE]
dependencies: [4]

**Objective**: Create pedagogical navigation guide for Archive/ directory following Template F

**Complexity**: Low

**Tasks**:
- [x] Create Archive/README.md following Template F from DIRECTORY_README_STANDARD.md
- [x] Write purpose statement: pedagogical examples for TM logic learning
- [x] Document example categories: modal (planned), temporal (planned), bimodal (implemented)
- [x] Write learning path recommendations: beginner → advanced progression
- [x] Add "How to Run Examples" section (VS Code workflow, import statements)
- [x] Link to Archive.lean for API documentation
- [x] Add "Contributing Examples" section (how to add new pedagogical examples)
- [x] Link to Documentation/UserGuide/EXAMPLES.md for usage examples
- [x] Add navigation links to Logos/ and Documentation/

**Testing**:
```bash
# Verify file created
test -f Archive/README.md && echo "Archive README created"

# Verify required sections present
grep -q "Purpose" Archive/README.md
grep -q "Example Categories" Archive/README.md
grep -q "Learning Path" Archive/README.md
grep -q "How to Run Examples" Archive/README.md

# Verify link to Archive.lean
grep -q "Archive.lean" Archive/README.md

# Check formatting and length
wc -l Archive/README.md  # Should be 50-100 lines
```

**Expected Duration**: 1.5 hours

### Phase 6: Create Documentation/README.md and LogosTest/README.md [COMPLETE]
dependencies: [4]

**Objective**: Create navigation guide for Documentation/ (Template G) and test organization guide for LogosTest/ (Template E)

**Complexity**: Medium

**Tasks**:
- [x] Create Documentation/README.md following Template G
- [x] Write Documentation/ purpose statement: comprehensive project documentation hub
- [x] Document 4 subdirectories: UserGuide/, ProjectInfo/, Development/, Reference/
- [x] Add audience guide: users (UserGuide/), contributors (ProjectInfo/), developers (Development/)
- [x] Create quick links section to most-referenced documents (ARCHITECTURE.md, CLAUDE.md, TESTING_STANDARDS.md)
- [x] Add documentation update workflow guidance
- [x] Link to DIRECTORY_README_STANDARD.md in Development/
- [x] Create LogosTest/README.md following Template E
- [x] Write LogosTest/ purpose statement: comprehensive test suite for Logos
- [x] Document 8 test subdirectories: Syntax/, ProofSystem/, Semantics/, Integration/, Metalogic/, etc.
- [x] Add "Running Tests" section: `lake test`, `lake test LogosTest.Syntax`
- [x] Add "Adding New Tests" section: naming conventions, file placement, test categories
- [x] Link to TESTING_STANDARDS.md for coverage requirements
- [x] Add "Interpreting Test Output" section
- [x] Add navigation links to Logos/ and Documentation/

**Testing**:
```bash
# Verify files created
test -f Documentation/README.md && echo "Documentation README created"
test -f LogosTest/README.md && echo "LogosTest README created"

# Verify Documentation/README.md sections
grep -q "Purpose" Documentation/README.md
grep -q "UserGuide" Documentation/README.md
grep -q "ProjectInfo" Documentation/README.md
grep -q "Development" Documentation/README.md
grep -q "Quick Links" Documentation/README.md

# Verify LogosTest/README.md sections
grep -q "Running Tests" LogosTest/README.md
grep -q "Adding New Tests" LogosTest/README.md
grep -q "lake test" LogosTest/README.md
grep -q "TESTING_STANDARDS" LogosTest/README.md

# Check formatting
wc -l Documentation/README.md  # Should be 60-100 lines
wc -l LogosTest/README.md  # Should be 80-120 lines
```

**Expected Duration**: 2.5 hours

### Phase 7: Create Logos/README.md and Update Cross-References [COMPLETE]
dependencies: [4, 5, 6]

**Objective**: Create lightweight source directory guide for Logos/ (Template D) and update all cross-references in CLAUDE.md and README.md

**Complexity**: Low

**Tasks**:
- [x] Create Logos/README.md following Template D (lightweight, navigation-focused)
- [x] Write purpose statement: main source directory for TM logic implementation
- [x] Document 6 submodules: Syntax/, ProofSystem/, Semantics/, Metalogic/, Theorems/, Automation/
- [x] Add source file map: where to find specific functionality (formulas, axioms, semantics, etc.)
- [x] Link to Logos.lean for API overview
- [x] Link to Documentation/UserGuide/ARCHITECTURE.md for logic specification
- [x] Add "Building and Type-Checking" section: `lake build`, `lake env lean`
- [x] Update CLAUDE.md Section 4: Add DIRECTORY_README_STANDARD.md to Documentation Index
- [x] Update README.md: Add directory README references to project structure
- [x] Update CLAUDE.md project structure diagram: Add README.md files for Archive/, Documentation/, Logos/, LogosTest/
- [x] Update README.md project structure diagram: Add README.md files for Archive/, Documentation/, Logos/, LogosTest/
- [x] Verify all navigation links work correctly

**Testing**:
```bash
# Verify Logos/README.md created
test -f Logos/README.md && echo "Logos README created"

# Verify Logos/README.md sections
grep -q "Purpose" Logos/README.md
grep -q "Submodules" Logos/README.md
grep -q "Building and Type-Checking" Logos/README.md
grep -q "Logos.lean" Logos/README.md

# Verify CLAUDE.md updated
grep -q "DIRECTORY_README_STANDARD.md" CLAUDE.md

# Verify README.md structure updated
grep -q "Archive/README.md" README.md
grep -q "Documentation/README.md" README.md
grep -q "Logos/README.md" README.md
grep -q "LogosTest/README.md" README.md

# Check all links are valid (basic check)
wc -l Logos/README.md  # Should be 40-70 lines

# Final build and test
lake build
lake test
```

**Expected Duration**: 2.5 hours

## Testing Strategy

### Phase-Level Testing
Each phase includes specific verification commands to ensure:
- File modifications are accurate
- Removed directories are completely removed
- Created files follow standard structure
- Links and cross-references are valid

### Integration Testing
After all phases complete:
- Verify project builds: `lake build`
- Verify tests pass: `lake test`
- Verify no broken links in documentation
- Verify all directory READMEs exist: `test -f Archive/README.md && test -f Documentation/README.md && test -f LogosTest/README.md && test -f Logos/README.md`

### Documentation Quality Testing
- All README files are properly formatted Markdown
- All internal links resolve correctly
- All cross-references between CLAUDE.md and README.md are consistent
- DIRECTORY_README_STANDARD.md is comprehensive and includes all required templates

## Documentation Requirements

### Files to Update
1. **README.md**: Update project structure diagrams, add directory README references, fix missing file documentation
2. **CLAUDE.md**: Update project structure diagrams, add DIRECTORY_README_STANDARD.md to documentation index, fix missing file documentation
3. **Documentation/ProjectInfo/KNOWN_LIMITATIONS.md**: Add note about Counterexamples being planned for future

### Files to Create
1. **Documentation/Development/DIRECTORY_README_STANDARD.md**: New standard for LEAN 4 directory documentation
2. **Archive/README.md**: Pedagogical examples navigation guide
3. **Documentation/README.md**: Documentation organization guide
4. **LogosTest/README.md**: Test suite guide
5. **Logos/README.md**: Source directory guide (optional, lightweight)

### Standards Alignment
- Follow existing Documentation/Development/LEAN_STYLE_GUIDE.md for formatting (100-char line limit, 2-space indent)
- Follow .claude/docs/reference/standards/documentation-standards.md patterns adapted for LEAN 4
- Reference Documentation/Development/TESTING_STANDARDS.md for test documentation
- Follow Documentation/Development/MODULE_ORGANIZATION.md for directory structure alignment

## Dependencies

### External Dependencies
None - all work is internal documentation and structure cleanup

### Internal Prerequisites
- Read access to all project documentation files
- Write access to create new README files
- Permission to remove Counterexamples/ directory
- Permission to modify lakefile.toml

### Standards References
- .claude/docs/reference/standards/documentation-standards.md (adapted for LEAN 4)
- Documentation/Development/LEAN_STYLE_GUIDE.md (code-level documentation)
- Documentation/Development/TESTING_STANDARDS.md (test documentation requirements)
- Documentation/Development/MODULE_ORGANIZATION.md (directory structure)

## Risk Management

### Technical Risks

**Risk 1: Breaking Build**
- Likelihood: Low
- Impact: Medium
- Mitigation: Run `lake build` and `lake test` after each phase
- Rollback: Git revert if build breaks

**Risk 2: Inconsistent Documentation**
- Likelihood: Medium
- Impact: Medium
- Mitigation: Cross-check README.md and CLAUDE.md references after each change
- Rollback: Fix inconsistencies in follow-up phase

**Risk 3: Over-Documentation**
- Likelihood: Low
- Impact: Low
- Mitigation: Keep directory READMEs lightweight and navigation-focused, avoid duplicating .lean module documentation
- Rollback: Simplify READMEs if they become maintenance burden

### Process Risks

**Risk 4: Standard Complexity**
- Likelihood: Medium
- Impact: Low
- Mitigation: Start with simple templates in DIRECTORY_README_STANDARD.md, iterate based on usage
- Rollback: Simplify standard if templates are too complex

## Notes

- Phases 1-3 are independent and can run in parallel
- Phase 4 must complete before phases 5-6 (standard creation before README implementation)
- Phase 7 depends on phases 5-6 for cross-reference updates
- All directory READMEs are navigation-focused, not API documentation (that's handled by .lean module files and doc-gen4)
- Logos/README.md is optional and lightweight - may be omitted if Logos.lean provides sufficient documentation
- The new DIRECTORY_README_STANDARD.md extends .claude/docs/reference/standards/documentation-standards.md for LEAN 4 projects specifically
