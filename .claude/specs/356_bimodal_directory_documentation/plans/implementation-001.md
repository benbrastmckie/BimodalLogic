# Implementation Plan: Task #356

**Task**: Create systematic documentation for Bimodal/ and BimodalTest/
**Version**: 001
**Created**: 2026-01-10
**Language**: general

## Overview

Create README.md files for the Bimodal/ and BimodalTest/ directories following the DIRECTORY_README_STANDARD.md templates. The Bimodal/ README will follow Template D (LEAN Source Directory), while BimodalTest/ README will follow Template E (LEAN Test Directory). Both READMEs will be modeled after the existing Logos/README.md and LogosTest/README.md patterns for consistency.

## Phases

### Phase 1: Create Bimodal/README.md

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Create comprehensive README for Bimodal/ source directory
2. Follow Template D (LEAN Source Directory) pattern
3. Ensure accurate file references post-refactoring

**Files to create**:
- `Bimodal/README.md` - New file (~100-130 lines)

**Content sections**:
1. **Header**: Title and brief purpose statement about TM bimodal logic library
2. **Purpose**: Description of what Bimodal contains (core TM logic implementation)
3. **Submodules**: List all 7 subdirectories with descriptions:
   - Syntax/ - Formula types and contexts
   - ProofSystem/ - Axioms and derivation trees
   - Semantics/ - Task frame semantics
   - Metalogic/ - Soundness, completeness
   - Theorems/ - Perpetuity principles, modal theorems
   - Automation/ - Tactics and proof search
   - Examples/ - Pedagogical examples
4. **Quick Reference**: File location guide for common functionality
5. **Building and Type-Checking**: Lake commands
6. **Module Structure**: Layered architecture overview
7. **Implementation Status**: Summary linking to IMPLEMENTATION_STATUS.md
8. **API Documentation**: Links to generated docs and guides
9. **Development Guidelines**: Links to style guide and testing standards
10. **Common Tasks**: How to add definitions, prove theorems, add axioms
11. **Related Documentation**: Links to related docs
12. **Navigation**: Links to parent, tests, documentation

**Steps**:
1. Read Logos/README.md as template reference
2. Adapt content for Bimodal-specific information
3. Update all file paths to use Bimodal/ namespace
4. Verify all referenced files exist
5. Write Bimodal/README.md

**Verification**:
- All file links in README are valid
- README follows Template D structure
- Content is consistent with Bimodal.lean docstring

---

### Phase 2: Create BimodalTest/README.md

**Estimated effort**: 1 hour
**Status**: [COMPLETED]

**Objectives**:
1. Create comprehensive README for BimodalTest/ test directory
2. Follow Template E (LEAN Test Directory) pattern
3. Ensure accurate test file references

**Files to create**:
- `BimodalTest/README.md` - New file (~120-150 lines)

**Content sections**:
1. **Header**: Title and brief purpose statement
2. **Test Organization**: List all 8 subdirectories with test descriptions:
   - Syntax/ - Formula and context tests
   - ProofSystem/ - Axiom and derivation tests
   - Semantics/ - Truth and frame tests
   - Metalogic/ - Soundness and completeness tests
   - Theorems/ - Perpetuity and modal tests
   - Automation/ - Tactic and proof search tests
   - Integration/ - Cross-module integration tests
   - Property/ - Property-based tests
3. **Running Tests**: Commands for all, specific module, specific file
4. **Running Tests in VS Code**: VS Code instructions
5. **Adding New Tests**: File placement, naming conventions
6. **Test Template**: Code example for new tests
7. **Test Quality Standards**: Coverage requirements and links
8. **Current Test Status**: Summary of implemented/planned tests
9. **Related Documentation**: Links to testing standards
10. **Navigation**: Links to parent, source, documentation

**Steps**:
1. Read LogosTest/README.md as template reference
2. Adapt content for BimodalTest-specific information
3. Update all file paths to use BimodalTest/ namespace
4. Verify all referenced test files exist
5. Write BimodalTest/README.md

**Verification**:
- All file links in README are valid
- README follows Template E structure
- Test commands work correctly

---

### Phase 3: Verify Existing Subdirectory READMEs

**Estimated effort**: 30 minutes
**Status**: [IN PROGRESS]

**Objectives**:
1. Check existing subdirectory READMEs for stale path references
2. Update any outdated paths from the Logos/Core → Bimodal refactoring
3. Ensure consistency across all documentation

**Files to verify**:
- `Bimodal/Automation/README.md` - Check for Logos/Core references
- `Bimodal/Theorems/Perpetuity/README.md` - Check for stale paths
- `BimodalTest/Integration/README.md` - Check for stale paths
- `BimodalTest/Property/README.md` - Check for stale paths

**Steps**:
1. Read each existing subdirectory README
2. Search for "Logos/Core" or outdated path references
3. Update any stale paths to use Bimodal/ namespace
4. Verify internal consistency

**Verification**:
- No references to old Logos/Core/ paths
- All file links are valid
- Documentation is internally consistent

---

### Phase 4: Final Verification and Commit

**Estimated effort**: 15 minutes
**Status**: [NOT STARTED]

**Objectives**:
1. Verify all new documentation is complete and consistent
2. Run final checks on file links
3. Commit all documentation changes

**Files modified (summary)**:
- `Bimodal/README.md` (new)
- `BimodalTest/README.md` (new)
- Potentially updated subdirectory READMEs

**Steps**:
1. Verify Bimodal/README.md exists and is complete
2. Verify BimodalTest/README.md exists and is complete
3. Run link check (optional: verify all file references)
4. Stage all changes
5. Commit with message "task 356: create systematic documentation for Bimodal directories"
6. Update task status to COMPLETED

**Verification**:
- Both new READMEs exist and are complete
- All documentation follows established patterns
- Git commit succeeds

## Dependencies

- Task 352 (Rename Logos/Core to Bimodal) - **COMPLETED**
- Task 353 (Move LogosTest/Core to BimodalTest) - **COMPLETED**

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Stale file references | Low | Low | Verify all paths during implementation |
| Inconsistent documentation | Low | Low | Use established templates as reference |
| Missing subdirectory info | Low | Low | Cross-reference with directory listing |

## Success Criteria

- [ ] Bimodal/README.md created following Template D
- [ ] BimodalTest/README.md created following Template E
- [ ] All file references in READMEs are valid
- [ ] No stale Logos/Core references in any README
- [ ] Documentation is consistent with DIRECTORY_README_STANDARD.md
- [ ] Git commit completes successfully

## Rollback Plan

Documentation-only changes are low risk. If issues arise:
1. Git revert the commit
2. Fix any identified issues
3. Re-commit corrected documentation
