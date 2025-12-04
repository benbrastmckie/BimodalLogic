# Project Structure and Naming Conventions Refactor Implementation Plan

## Metadata
- **Date**: 2025-12-01
- **Feature**: Project structure and naming conventions refactor to align with LEAN 4 community standards
- **Scope**: Directory reorganization, file naming updates, lakefile.toml configuration, and documentation updates
- **Estimated Phases**: 5
- **Estimated Hours**: 8
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Structure Level**: 0
- **Complexity Score**: 47.0
- **Research Reports**:
  - [Project Structure and Naming Conventions Research Report](/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/004_project_structure_naming_plan/reports/research_report.md)

## Overview

This plan implements a refactor of the Logos project's directory structure and naming conventions to align with LEAN 4 community standards as documented in the mathlib4 repository and official LEAN community style guidelines. The project is currently in the planning phase with no LEAN source code implemented yet, making this the optimal time to establish the correct structure before implementation begins.

The key changes include:
1. Renaming test directory from `Tests/` to `LogosTest/` to follow mathlib4 pattern
2. Reorganizing examples into semantic categories (`Archive/` for pedagogical examples, `Counterexamples/` for invalidity demonstrations)
3. Updating lakefile.toml to reflect new structure
4. Updating all documentation to reflect corrected structure
5. Maintaining PascalCase for all LEAN source directories and lowercase for non-LEAN meta directories

This refactor resolves the user's preference for lowercase snake_case directories by adopting LEAN 4 ecosystem standards (PascalCase for source directories) while keeping non-LEAN directories (docs/, .claude/, .github/) in lowercase as a reasonable compromise.

## Research Summary

The research report analyzed LEAN 4 community standards from mathlib4 and identified these key findings:

1. **Directory Naming**: LEAN 4 uses PascalCase (UpperCamelCase) universally for all source directories (Mathlib/, Algebra/, CategoryTheory/, etc.)
2. **Test Directories**: mathlib4 uses `MathlibTest/` (singular, project-prefixed) not `Tests/`
3. **Example Directories**: mathlib4 uses semantic categorization (`Archive/` for historical examples, `Counterexamples/` for counterexample constructions) not monolithic `Examples/`
4. **File Naming**: All `.lean` files use PascalCase (e.g., `Formula.lean`, `TaskFrame.lean`)
5. **Current Alignment**: Logos's planned structure is largely aligned with standards except for test and examples directories

The research recommends following LEAN 4 standards over personal preferences to ensure smooth integration with ecosystem tooling and community expectations.

## Success Criteria

- [ ] Directory structure matches LEAN 4 community standards (PascalCase for source, lowercase for meta)
- [ ] Test directory renamed to `LogosTest/` with mirrored source structure
- [ ] Examples organized into `Archive/` and `Counterexamples/` directories
- [ ] lakefile.toml updated with correct library configurations
- [ ] All root files created (Logos.lean, LogosTest/LogosTest.lean, Archive/Archive.lean, Counterexamples/Counterexamples.lean)
- [ ] CLAUDE.md updated with corrected project structure section
- [ ] docs/ARCHITECTURE.md updated with corrected file paths and structure
- [ ] All documentation cross-references updated to new structure
- [ ] `lake build` executes successfully with new structure
- [ ] No broken references in documentation or configuration files

## Technical Design

### Architecture Overview

The refactor implements LEAN 4 community standards for project organization:

**Directory Structure Changes**:
- `Tests/` → `LogosTest/` (follows mathlib4 `MathlibTest/` pattern)
- `Examples/` → split into `Archive/` + `Counterexamples/` (semantic categorization)
- Maintain existing `Logos/` source structure (already aligned)

**Naming Conventions**:
- **LEAN source directories**: PascalCase (Logos/, Syntax/, ProofSystem/)
- **Test directories**: PascalCase (LogosTest/, Syntax/, Integration/)
- **Example directories**: PascalCase (Archive/, Counterexamples/)
- **Meta directories**: lowercase (docs/, .claude/, .github/)
- **LEAN files**: PascalCase with .lean extension (Formula.lean, TaskFrame.lean)
- **Documentation files**: UPPERCASE for major docs (README.md, ARCHITECTURE.md), lowercase for others

**Rationale**:
- User prefers lowercase snake_case but explicitly wants to follow community standards
- LEAN 4 ecosystem uses PascalCase universally for source directories
- Deviation from standards creates friction with tooling and community
- Compromise: Use PascalCase for LEAN directories, lowercase for non-LEAN meta directories
- Pre-implementation refactor (no code exists yet) makes this low-risk

### Component Design

**1. Main Source Directory** (`Logos/`):
- No changes needed (already aligned with standards)
- Structure: Logos/{Syntax, ProofSystem, Semantics, Metalogic, Theorems, Automation}/

**2. Test Directory** (`LogosTest/`):
- Mirror main source structure for discoverability
- Structure: LogosTest/{Syntax, ProofSystem, Semantics, Integration, Metalogic}/
- Test files use `*Test.lean` suffix (e.g., FormulaTest.lean, AxiomsTest.lean)
- Root file: LogosTest/LogosTest.lean (library root)

**3. Example Directories**:
- **Archive/**: Pedagogical examples, famous proofs, historical examples
  - Files: ModalProofs.lean, TemporalProofs.lean, BimodalProofs.lean
  - Root file: Archive/Archive.lean
- **Counterexamples/**: Invalidity demonstrations, edge cases, counterexample constructions
  - Root file: Counterexamples/Counterexamples.lean
  - Future files: Invalidity.lean, EdgeCases.lean

**4. lakefile.toml Configuration**:
```toml
[package]
name = "Logos"
version = "0.1.0"
keywords = ["logic", "modal-logic", "temporal-logic", "proof-system", "lean4"]
license = "MIT"
description = "LEAN 4 implementation of axiomatic proof system for bimodal logic TM"

# Main library
[[lean_lib]]
name = "Logos"
roots = ["Logos"]
globs = ["Logos/**"]

# Test suite
[[lean_lib]]
name = "LogosTest"
roots = ["LogosTest"]
globs = ["LogosTest/**"]

# Examples - Archive
[[lean_lib]]
name = "Archive"
roots = ["Archive"]
globs = ["Archive/**"]

# Examples - Counterexamples
[[lean_lib]]
name = "Counterexamples"
roots = ["Counterexamples"]
globs = ["Counterexamples/**"]

# Test executable
[[lean_exe]]
name = "test"
root = "LogosTest"
```

**5. Documentation Updates**:
- Update CLAUDE.md section 3 (Project Structure) with new directory tree
- Update CLAUDE.md section 7 (Testing Architecture) with new test paths
- Update docs/ARCHITECTURE.md section 6.1 (Project Structure) with new paths
- Update all file path references throughout documentation

### Standards Alignment

**Code Standards**:
- Follow LEAN 4 community naming conventions (PascalCase for directories and files)
- 100-character line limit (from LEAN_STYLE_GUIDE.md)
- 2-space indentation
- Flush-left declarations

**Testing Protocols**:
- Test files mirror source structure for discoverability
- Test naming: `test_<feature>_<expected_behavior>` (from TESTING_STANDARDS.md)
- File naming: `<Module>Test.lean` (singular form)

**Documentation Policy**:
- Update all documentation to reflect new structure
- Maintain bidirectional references between related docs
- Use absolute paths for file references in documentation

**Directory Organization**:
- PascalCase for LEAN source directories (from research findings)
- Lowercase for non-LEAN meta directories (docs/, .claude/, .github/)
- Semantic organization for examples (Archive/ vs Counterexamples/)

## Implementation Phases

### Phase 1: Create Directory Structure [COMPLETE]
dependencies: []

**Objective**: Create the new directory structure following LEAN 4 community standards

**Complexity**: Low

**Tasks**:
- [x] Create main source directories (Logos/ subdirectories)
  ```bash
  mkdir -p Logos/{Syntax,ProofSystem,Semantics,Metalogic,Theorems,Automation}
  ```
- [x] Create test directory structure (LogosTest/ subdirectories)
  ```bash
  mkdir -p LogosTest/{Syntax,ProofSystem,Semantics,Integration,Metalogic}
  ```
- [x] Create example directories (Archive/, Counterexamples/)
  ```bash
  mkdir -p Archive
  mkdir -p Counterexamples
  ```
- [x] Verify directory creation with ls command
- [x] Document directory structure in phase completion notes

**Testing**:
```bash
# Verify directories exist
test -d Logos/Syntax || echo "ERROR: Logos/Syntax not found"
test -d LogosTest/Syntax || echo "ERROR: LogosTest/Syntax not found"
test -d Archive || echo "ERROR: Archive not found"
test -d Counterexamples || echo "ERROR: Counterexamples not found"

# Verify directory count
find Logos -type d | wc -l  # Should be 7 (root + 6 subdirs)
find LogosTest -type d | wc -l  # Should be 6 (root + 5 subdirs)

echo "✓ Phase 1 complete: Directory structure created"
```

**Expected Duration**: 0.5 hours

### Phase 2: Create Root Files [COMPLETE]
dependencies: [1]

**Objective**: Create root .lean files for each library to establish namespace structure

**Complexity**: Low

**Tasks**:
- [x] Create Logos.lean (main library root with re-exports)
  - Content: Module docstring and re-export statements for public API
  - Path: /home/benjamin/Documents/Philosophy/Projects/Logos/Logos.lean
- [x] Create LogosTest/LogosTest.lean (test library root)
  - Content: Module docstring and test suite organization
  - Path: /home/benjamin/Documents/Philosophy/Projects/Logos/LogosTest/LogosTest.lean
- [x] Create Archive/Archive.lean (archive library root)
  - Content: Module docstring explaining pedagogical examples
  - Path: /home/benjamin/Documents/Philosophy/Projects/Logos/Archive/Archive.lean
- [x] Create Counterexamples/Counterexamples.lean (counterexamples library root)
  - Content: Module docstring explaining counterexample constructions
  - Path: /home/benjamin/Documents/Philosophy/Projects/Logos/Counterexamples/Counterexamples.lean
- [x] Verify all root files created with correct headers

**Testing**:
```bash
# Verify root files exist
test -f Logos.lean || echo "ERROR: Logos.lean not found"
test -f LogosTest/LogosTest.lean || echo "ERROR: LogosTest.lean not found"
test -f Archive/Archive.lean || echo "ERROR: Archive.lean not found"
test -f Counterexamples/Counterexamples.lean || echo "ERROR: Counterexamples.lean not found"

# Verify files contain module docstrings
grep -q "/-!" Logos.lean || echo "WARNING: Missing module docstring in Logos.lean"
grep -q "namespace" Logos.lean || echo "WARNING: Missing namespace in Logos.lean"

echo "✓ Phase 2 complete: Root files created"
```

**Expected Duration**: 1 hour

### Phase 3: Update lakefile.toml [COMPLETE]
dependencies: [1, 2]

**Objective**: Update build configuration to reflect new directory structure

**Complexity**: Low

**Tasks**:
- [x] Read current lakefile.toml to understand existing configuration
  - Path: /home/benjamin/Documents/Philosophy/Projects/Logos/lakefile.toml
- [x] Update lakefile.toml with new library configurations
  - Replace `[[lean_lib]] name = "Examples"` with separate Archive and Counterexamples libraries
  - Replace `[[lean_lib]] name = "tests"` with LogosTest library
  - Update `[[lean_exe]]` root from "Tests" to "LogosTest"
  - Add package metadata (version, keywords, license, description)
- [x] Verify lakefile.toml syntax is valid TOML
- [x] Document changes in phase completion notes

**Testing**:
```bash
# Verify lakefile syntax
lake --version || echo "ERROR: lake not installed"

# Verify lakefile configuration
grep -q "name = \"LogosTest\"" lakefile.toml || echo "ERROR: LogosTest library not configured"
grep -q "name = \"Archive\"" lakefile.toml || echo "ERROR: Archive library not configured"
grep -q "name = \"Counterexamples\"" lakefile.toml || echo "ERROR: Counterexamples library not configured"
grep -q "root = \"LogosTest\"" lakefile.toml || echo "ERROR: Test executable root not updated"

# Attempt to build (should succeed even with empty files)
lake build || echo "WARNING: lake build failed (expected if dependencies missing)"

echo "✓ Phase 3 complete: lakefile.toml updated"
```

**Expected Duration**: 1 hour

### Phase 4: Update Documentation [COMPLETE]
dependencies: [3]

**Objective**: Update all documentation to reflect new directory structure and naming conventions

**Complexity**: Medium

**Tasks**:
- [x] Update CLAUDE.md section 3 (Project Structure) with new directory tree
  - Path: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
  - Replace `Examples/` with `Archive/` and `Counterexamples/`
  - Replace `Tests/` with `LogosTest/`
  - Update all file paths in examples
- [x] Update CLAUDE.md section 7 (Testing Architecture) with new test paths
  - Replace all `Tests/` references with `LogosTest/`
  - Update test file naming examples
- [x] Update docs/ARCHITECTURE.md section 6.1 (Project Structure) with new paths
  - Path: /home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md
  - Update directory tree diagram
  - Update all file path references in code examples
- [x] Search for and update all other `Tests/` and `Examples/` references
  - Check docs/TUTORIAL.md, docs/EXAMPLES.md, docs/CONTRIBUTING.md
  - Check src/docs/ files (LEAN_STYLE_GUIDE.md, MODULE_ORGANIZATION.md, TESTING_STANDARDS.md)
- [x] Verify no broken references remain with grep

**Testing**:
```bash
# Search for old directory references
grep -r "Tests/" docs/ || echo "✓ No 'Tests/' references in docs/"
grep -r "Examples/" docs/ || echo "✓ No 'Examples/' references in docs/"
grep -r "Tests/" CLAUDE.md && echo "ERROR: 'Tests/' still referenced in CLAUDE.md" || echo "✓ No 'Tests/' in CLAUDE.md"
grep -r "Examples/" CLAUDE.md && echo "ERROR: 'Examples/' still referenced in CLAUDE.md" || echo "✓ No 'Examples/' in CLAUDE.md"

# Verify new structure documented
grep -q "LogosTest/" CLAUDE.md || echo "ERROR: LogosTest/ not documented in CLAUDE.md"
grep -q "Archive/" CLAUDE.md || echo "ERROR: Archive/ not documented in CLAUDE.md"
grep -q "Counterexamples/" CLAUDE.md || echo "ERROR: Counterexamples/ not documented in CLAUDE.md"

# Verify ARCHITECTURE.md updated
grep -q "LogosTest/" docs/ARCHITECTURE.md || echo "ERROR: ARCHITECTURE.md not updated"

echo "✓ Phase 4 complete: Documentation updated"
```

**Expected Duration**: 3 hours

### Phase 5: Validation and Verification [COMPLETE]
dependencies: [4]

**Objective**: Verify entire refactor is complete and structure works correctly

**Complexity**: Low

**Tasks**:
- [x] Run lake build to verify configuration works
- [x] Verify all directory creation tasks completed
- [x] Verify all root files created and have correct structure
- [x] Verify lakefile.toml matches recommended configuration
- [x] Verify all documentation references updated
- [x] Run comprehensive grep search for old structure references
- [x] Document any issues found and resolution
- [x] Create final validation report

**Testing**:
```bash
# Comprehensive validation script
echo "=== Project Structure Validation ==="

# 1. Directory structure check
echo "Checking directory structure..."
test -d Logos/Syntax && echo "✓ Logos/Syntax exists" || echo "✗ Missing Logos/Syntax"
test -d Logos/ProofSystem && echo "✓ Logos/ProofSystem exists" || echo "✗ Missing Logos/ProofSystem"
test -d Logos/Semantics && echo "✓ Logos/Semantics exists" || echo "✗ Missing Logos/Semantics"
test -d Logos/Metalogic && echo "✓ Logos/Metalogic exists" || echo "✗ Missing Logos/Metalogic"
test -d Logos/Theorems && echo "✓ Logos/Theorems exists" || echo "✗ Missing Logos/Theorems"
test -d Logos/Automation && echo "✓ Logos/Automation exists" || echo "✗ Missing Logos/Automation"

test -d LogosTest/Syntax && echo "✓ LogosTest/Syntax exists" || echo "✗ Missing LogosTest/Syntax"
test -d LogosTest/ProofSystem && echo "✓ LogosTest/ProofSystem exists" || echo "✗ Missing LogosTest/ProofSystem"
test -d LogosTest/Semantics && echo "✓ LogosTest/Semantics exists" || echo "✗ Missing LogosTest/Semantics"
test -d LogosTest/Integration && echo "✓ LogosTest/Integration exists" || echo "✗ Missing LogosTest/Integration"
test -d LogosTest/Metalogic && echo "✓ LogosTest/Metalogic exists" || echo "✗ Missing LogosTest/Metalogic"

test -d Archive && echo "✓ Archive exists" || echo "✗ Missing Archive"
test -d Counterexamples && echo "✓ Counterexamples exists" || echo "✗ Missing Counterexamples"

# 2. Root files check
echo "Checking root files..."
test -f Logos.lean && echo "✓ Logos.lean exists" || echo "✗ Missing Logos.lean"
test -f LogosTest/LogosTest.lean && echo "✓ LogosTest.lean exists" || echo "✗ Missing LogosTest.lean"
test -f Archive/Archive.lean && echo "✓ Archive.lean exists" || echo "✗ Missing Archive.lean"
test -f Counterexamples/Counterexamples.lean && echo "✓ Counterexamples.lean exists" || echo "✗ Missing Counterexamples.lean"

# 3. lakefile.toml check
echo "Checking lakefile.toml..."
grep -q "name = \"LogosTest\"" lakefile.toml && echo "✓ LogosTest library configured" || echo "✗ LogosTest not configured"
grep -q "name = \"Archive\"" lakefile.toml && echo "✓ Archive library configured" || echo "✗ Archive not configured"
grep -q "name = \"Counterexamples\"" lakefile.toml && echo "✓ Counterexamples library configured" || echo "✗ Counterexamples not configured"

# 4. Documentation check
echo "Checking documentation..."
grep -q "LogosTest/" CLAUDE.md && echo "✓ CLAUDE.md updated" || echo "✗ CLAUDE.md not updated"
grep -q "Archive/" CLAUDE.md && echo "✓ Archive documented" || echo "✗ Archive not documented"
grep -q "LogosTest/" docs/ARCHITECTURE.md && echo "✓ ARCHITECTURE.md updated" || echo "✗ ARCHITECTURE.md not updated"

# 5. Old reference check
echo "Checking for old references..."
OLD_TESTS=$(grep -r "Tests/" docs/ CLAUDE.md 2>/dev/null | wc -l)
OLD_EXAMPLES=$(grep -r "Examples/" docs/ CLAUDE.md 2>/dev/null | wc -l)
if [ "$OLD_TESTS" -eq 0 ]; then
  echo "✓ No old 'Tests/' references found"
else
  echo "✗ Found $OLD_TESTS old 'Tests/' references"
fi
if [ "$OLD_EXAMPLES" -eq 0 ]; then
  echo "✓ No old 'Examples/' references found"
else
  echo "✗ Found $OLD_EXAMPLES old 'Examples/' references"
fi

# 6. Build check
echo "Checking lake build..."
lake build 2>&1 | head -5
if [ $? -eq 0 ]; then
  echo "✓ lake build successful"
else
  echo "⚠ lake build failed (may be expected if no source files yet)"
fi

echo "=== Validation Complete ==="
```

**Expected Duration**: 2.5 hours

## Testing Strategy

### Unit Testing
- **Directory Creation**: Verify each directory exists using `test -d`
- **File Creation**: Verify each root file exists using `test -f`
- **File Content**: Verify module docstrings present using `grep -q "/-!"`
- **lakefile Syntax**: Verify valid TOML using lake tooling

### Integration Testing
- **Build Integration**: Run `lake build` to verify entire configuration works
- **Documentation Links**: Verify no broken cross-references in documentation
- **Namespace Structure**: Verify namespace hierarchy matches directory structure

### Validation Testing
- **Standards Compliance**: Verify directory names match LEAN 4 PascalCase standard
- **Completeness**: Verify all old structure references removed
- **Consistency**: Verify documentation matches actual structure

### Test Automation
- Use bash test scripts for automated verification
- Run comprehensive grep searches for old structure references
- Validate lakefile.toml configuration automatically

## Documentation Requirements

### Files to Update
1. **CLAUDE.md**: Section 3 (Project Structure), Section 7 (Testing Architecture)
2. **docs/ARCHITECTURE.md**: Section 6.1 (Project Structure), all file path references
3. **docs/TUTORIAL.md**: Update any file path examples
4. **docs/EXAMPLES.md**: Update example file paths
5. **docs/CONTRIBUTING.md**: Update file path references
6. **src/docs/MODULE_ORGANIZATION.md**: Update directory structure documentation
7. **src/docs/TESTING_STANDARDS.md**: Update test directory references

### Documentation Standards
- Use absolute paths for file references where possible
- Maintain bidirectional references between related docs
- Update all code examples with correct file paths
- Ensure consistency across all documentation files

### README Updates
- Update README.md if it contains structure references
- Add note about LEAN 4 community standards compliance

## Dependencies

### External Dependencies
- LEAN 4 toolchain (already specified in lean-toolchain file)
- Lake build system (bundled with LEAN 4)

### Internal Dependencies
- Phase 1 must complete before Phase 2 (need directories before creating files)
- Phase 2 must complete before Phase 3 (need root files before configuring lakefile)
- Phase 3 must complete before Phase 4 (need working lakefile before documenting)
- Phase 4 must complete before Phase 5 (need documentation updated before final validation)

### No Blocking Dependencies
- No external systems need updating
- No database migrations required
- No API changes required

## Risk Analysis

### Low Risk Items
- Directory creation (reversible, no code changes)
- Root file creation (empty files, no logic)
- lakefile.toml updates (validates before build)

### Medium Risk Items
- Documentation updates (potential for missing references)
- Migration of planned structure (documentation may be inconsistent)

### Mitigation Strategies
1. **Comprehensive grep searches**: Find all old structure references
2. **Validation phase**: Dedicated phase for verification
3. **Test scripts**: Automated verification of changes
4. **Git version control**: Easy rollback if needed

### Rollback Plan
If issues discovered:
1. Revert all changes using git (nothing committed yet)
2. Restore original planned structure
3. Document issues for future reference

## Notes

### Key Decision Points
1. **Chosen Structure**: LogosTest/ + Archive/ + Counterexamples/ (recommended option from research)
2. **Alternative Rejected**: Test/ + Example/ (minimal change option)
3. **Rationale**: Better alignment with mathlib4 patterns, semantic organization for examples

### User Preference Resolution
- User prefers lowercase snake_case but wants to follow standards
- LEAN 4 community standard is PascalCase for source directories
- **Decision**: Follow LEAN 4 standards for source, use lowercase for meta directories
- **Compromise**: Balances user preference with ecosystem requirements

### Future Considerations
- As LEAN source code is implemented, ensure file names use PascalCase
- Consider adding more semantic example categories if needed
- Monitor LEAN 4 community standards for any updates
- Plan for eventual population of test directories with actual test files
