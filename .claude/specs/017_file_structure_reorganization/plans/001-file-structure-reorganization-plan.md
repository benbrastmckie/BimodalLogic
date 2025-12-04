# File Structure Reorganization Implementation Plan

## Metadata
- **Date**: 2025-12-02
- **Feature**: File Structure Reorganization and Naming Consistency
- **Scope**: Rename docs/ to Documentation/, reorganize documentation files into subdirectories, update all references in CLAUDE.md, README.md, and documentation files
- **Estimated Phases**: 5
- **Estimated Hours**: 12
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Complexity Score**: 165.0
- **Structure Level**: 0
- **Research Reports**:
  - [File Structure Reorganization Research](../reports/001-file-structure-reorganization-research.md)

## Overview

The Logos project requires file structure improvements to enhance consistency and clarity. This plan addresses three main concerns:

1. **Documentation directory naming inconsistency**: The `docs/` directory uses lowercase naming while LEAN library directories use PascalCase (`Logos/`, `LogosTest/`, `Archive/`, `Counterexamples/`). Renaming to `Documentation/` will establish uniform styling across all project directories.

2. **Documentation file organization**: Currently, documentation files (ARCHITECTURE.md, TUTORIAL.md, etc.) live at the root of `docs/`. These should be organized into subdirectories for better categorization and navigation.

3. **Documentation clarity enhancement**: The current structure does not require changes to LEAN source files. Research shows that aggregator files (e.g., `Syntax.lean`, `Semantics.lean`) are a standard LEAN 4 pattern for re-exporting subdirectory modules and serve as the public API layer. These should be preserved as-is.

**Key Constraint**: This is purely a documentation reorganization. No LEAN source code files will be moved, renamed, or modified. The aggregator pattern is correct and follows LEAN 4 conventions.

## Research Summary

Based on the comprehensive research analysis:

**Aggregator Pattern (No Action Required)**:
- The research identified that files like `Syntax.lean`, `Semantics.lean`, etc. are aggregator files that re-export subdirectory modules
- This is standard LEAN 4 practice for organizing module hierarchies
- Subdirectories (`Logos/Syntax/`, `Logos/Semantics/`, etc.) contain actual implementations
- Aggregator files provide convenient single-import access to all submodules
- This pattern is transparent to Lake build system and is the correct approach
- **Recommendation**: Documentation should clarify this pattern but no code changes needed

**Documentation Naming (Action Required)**:
- Current: `docs/` uses lowercase (common GitHub convention)
- Desired: `Documentation/` to match PascalCase used in LEAN directories
- Impact: ~60+ internal link references across CLAUDE.md, README.md, and all documentation files
- **Recommendation**: Proceed with rename using automated link updates and thorough verification

**Documentation Organization (Action Required)**:
- Current: Flat structure with files at `docs/` root and specialized subdirectories (`development/`, `glossary/`)
- Desired: Organize documentation files into subdirectories within `Documentation/`
- Proposed structure:
  - `Documentation/UserGuide/` - Architecture, Tutorial, Examples, Integration
  - `Documentation/ProjectInfo/` - Implementation Status, Known Limitations, Contributing, Versioning
  - `Documentation/Development/` - Existing developer standards (LEAN_STYLE_GUIDE.md, etc.)
  - `Documentation/Reference/` - Glossary and reference materials
- **Recommendation**: Implement subdirectory organization with comprehensive link updates

**Missing Files (No Action in This Plan)**:
- Research identified missing files documented in README.md and CLAUDE.md (DSL.lean, Rules.lean, etc.)
- These should be addressed in a separate plan focused on documentation accuracy
- This plan focuses solely on file structure reorganization

## Success Criteria

- [ ] `docs/` directory renamed to `Documentation/`
- [ ] Documentation files organized into appropriate subdirectories (UserGuide, ProjectInfo, Development, Reference)
- [ ] All references to `docs/` paths updated to `Documentation/` in CLAUDE.md
- [ ] All references to `docs/` paths updated to `Documentation/` in README.md
- [ ] All internal cross-references in documentation files updated to reflect new structure
- [ ] `lake build` completes successfully (no LEAN code changes, but verification required)
- [ ] `lake test` passes (no test code changes, but verification required)
- [ ] All documentation links functional (no broken links after reorganization)
- [ ] Git history preserved (use `git mv` for all moves and renames)
- [ ] Project structure diagram in README.md updated to show new organization

## Technical Design

### Directory Reorganization Strategy

**New Documentation Structure**:
```
Documentation/
├── UserGuide/
│   ├── ARCHITECTURE.md           # System design and TM logic specification
│   ├── TUTORIAL.md               # Getting started guide
│   ├── EXAMPLES.md               # Usage examples
│   └── INTEGRATION.md            # Model-Checker integration
├── ProjectInfo/
│   ├── IMPLEMENTATION_STATUS.md  # Module-by-module status tracking
│   ├── KNOWN_LIMITATIONS.md      # Gaps, explanations, workarounds
│   ├── CONTRIBUTING.md           # Contribution guidelines
│   └── VERSIONING.md             # Semantic versioning policy
├── Development/
│   ├── LEAN_STYLE_GUIDE.md      # Coding conventions (moved from docs/development/)
│   ├── MODULE_ORGANIZATION.md    # Directory structure (moved from docs/development/)
│   ├── TESTING_STANDARDS.md      # Test requirements (moved from docs/development/)
│   ├── TACTIC_DEVELOPMENT.md     # Custom tactic patterns (moved from docs/development/)
│   └── QUALITY_METRICS.md        # Quality targets (moved from docs/development/)
└── Reference/
    └── Glossary/
        └── logical-operators.md  # Formal symbols reference (moved from docs/glossary/)
```

**Rationale**:
- **UserGuide/**: User-facing documentation for understanding and using Logos
- **ProjectInfo/**: Project status, limitations, and contribution information
- **Development/**: Developer standards and conventions (consolidates existing `docs/development/`)
- **Reference/**: Reference materials like glossaries (consolidates existing `docs/glossary/`)

### Link Update Strategy

**Link Pattern Transformations**:
1. **Simple Directory Rename**: `docs/` → `Documentation/`
   - Example: `docs/ARCHITECTURE.md` → `Documentation/UserGuide/ARCHITECTURE.md`

2. **Relative Path Adjustments**: Update relative links based on new nesting
   - From CLAUDE.md: `docs/development/LEAN_STYLE_GUIDE.md` → `Documentation/Development/LEAN_STYLE_GUIDE.md`
   - From README.md: `docs/TUTORIAL.md` → `Documentation/UserGuide/TUTORIAL.md`
   - Internal doc links: Adjust based on new relative positions

3. **Cross-Reference Updates**: Documentation files referencing each other
   - Development standards linking to user guides
   - User guides linking to reference materials
   - All links must use correct relative paths after reorganization

### Verification Approach

**Multi-Level Verification**:
1. **Structure Verification**: Confirm all files moved to correct locations
2. **Link Verification**: Parse all Markdown files and validate link targets exist
3. **Build Verification**: Run `lake build` and `lake test` to ensure no impact on LEAN code
4. **Manual Verification**: Click-through testing of key documentation paths

### Standards Compliance

**Directory Naming (from CLAUDE.md)**:
- LEAN library directories use PascalCase: `Logos/`, `LogosTest/`, `Archive/`, `Counterexamples/`
- Documentation directory should match: `Documentation/` (not `docs/`)
- Subdirectories within Documentation/ use PascalCase: `UserGuide/`, `Development/`, `ProjectInfo/`, `Reference/`

**Git Best Practices**:
- Use `git mv` to preserve file history
- Create atomic commits per phase
- Test after each phase before proceeding

**Documentation Standards (from CLAUDE.md)**:
- Markdown format with clear section headings
- Relative links for internal cross-references
- Absolute links for external references
- 100-character line limit where feasible

### Risk Mitigation

**Broken Links Risk**:
- Mitigation: Automated link validation script in Phase 3
- Fallback: Comprehensive manual verification before final commit

**Build Impact Risk**:
- Mitigation: Documentation reorganization should not affect LEAN build system
- Verification: Run `lake build` and `lake test` after each phase
- Confidence: Research confirms documentation is separate from LEAN source structure

**History Loss Risk**:
- Mitigation: Use `git mv` exclusively for all file moves
- Verification: `git log --follow` to confirm history preservation

## Implementation Phases

### Phase 1: Create New Documentation Directory Structure [COMPLETE]
dependencies: []

**Objective**: Create the new `Documentation/` directory with subdirectories, leaving existing `docs/` intact for now.

**Complexity**: Low

**Tasks**:
- [x] Create `Documentation/` directory at project root
- [x] Create subdirectories: `Documentation/UserGuide/`, `Documentation/ProjectInfo/`, `Documentation/Development/`, `Documentation/Reference/`
- [x] Create `Documentation/Reference/Glossary/` subdirectory
- [x] Verify directory structure matches design specification
- [x] Document directory structure for Phase 2 reference

**Testing**:
```bash
# Verify directory structure created
test -d Documentation/UserGuide || echo "ERROR: UserGuide not created"
test -d Documentation/ProjectInfo || echo "ERROR: ProjectInfo not created"
test -d Documentation/Development || echo "ERROR: Development not created"
test -d Documentation/Reference/Glossary || echo "ERROR: Reference/Glossary not created"

# Verify old docs/ still exists (parallel structure for safety)
test -d docs || echo "ERROR: docs/ directory missing"

echo "✓ Phase 1 Complete: Directory structure created"
```

**Expected Duration**: 0.5 hours

---

### Phase 2: Move Documentation Files Using Git [COMPLETE]
dependencies: [1]

**Objective**: Move all documentation files from `docs/` to appropriate subdirectories in `Documentation/` using `git mv` to preserve history.

**Complexity**: Medium

**Tasks**:
- [x] Move user guides: `git mv docs/ARCHITECTURE.md Documentation/UserGuide/`
- [x] Move user guides: `git mv docs/TUTORIAL.md Documentation/UserGuide/`
- [x] Move user guides: `git mv docs/EXAMPLES.md Documentation/UserGuide/`
- [x] Move user guides: `git mv docs/INTEGRATION.md Documentation/UserGuide/`
- [x] Move project info: `git mv docs/IMPLEMENTATION_STATUS.md Documentation/ProjectInfo/`
- [x] Move project info: `git mv docs/KNOWN_LIMITATIONS.md Documentation/ProjectInfo/`
- [x] Move project info: `git mv docs/CONTRIBUTING.md Documentation/ProjectInfo/`
- [x] Move project info: `git mv docs/VERSIONING.md Documentation/ProjectInfo/`
- [x] Move development standards: `git mv docs/development/LEAN_STYLE_GUIDE.md Documentation/Development/`
- [x] Move development standards: `git mv docs/development/MODULE_ORGANIZATION.md Documentation/Development/`
- [x] Move development standards: `git mv docs/development/TESTING_STANDARDS.md Documentation/Development/`
- [x] Move development standards: `git mv docs/development/TACTIC_DEVELOPMENT.md Documentation/Development/`
- [x] Move development standards: `git mv docs/development/QUALITY_METRICS.md Documentation/Development/`
- [x] Move glossary: `git mv docs/glossary/logical-operators.md Documentation/Reference/Glossary/`
- [x] Remove empty `docs/development/` directory
- [x] Remove empty `docs/glossary/` directory
- [x] Remove empty `docs/` directory
- [x] Verify all files moved successfully
- [x] Verify git history preserved using `git log --follow` on sample files

**Testing**:
```bash
# Verify all UserGuide files present
for file in ARCHITECTURE.md TUTORIAL.md EXAMPLES.md INTEGRATION.md; do
  test -f "Documentation/UserGuide/$file" || echo "ERROR: UserGuide/$file missing"
done

# Verify all ProjectInfo files present
for file in IMPLEMENTATION_STATUS.md KNOWN_LIMITATIONS.md CONTRIBUTING.md VERSIONING.md; do
  test -f "Documentation/ProjectInfo/$file" || echo "ERROR: ProjectInfo/$file missing"
done

# Verify all Development files present
for file in LEAN_STYLE_GUIDE.md MODULE_ORGANIZATION.md TESTING_STANDARDS.md TACTIC_DEVELOPMENT.md QUALITY_METRICS.md; do
  test -f "Documentation/Development/$file" || echo "ERROR: Development/$file missing"
done

# Verify glossary moved
test -f "Documentation/Reference/Glossary/logical-operators.md" || echo "ERROR: Glossary file missing"

# Verify old docs/ directory removed
test ! -d docs || echo "WARNING: docs/ directory still exists"

# Verify git history preserved (sample check)
git log --follow Documentation/UserGuide/ARCHITECTURE.md | grep -q "commit" || echo "ERROR: Git history not preserved"

echo "✓ Phase 2 Complete: All files moved with history preserved"
```

**Expected Duration**: 2 hours

---

### Phase 3: Update CLAUDE.md References [COMPLETE]
dependencies: [2]

**Objective**: Update all documentation path references in CLAUDE.md from `docs/` to `Documentation/` with new subdirectory paths.

**Complexity**: High

**Tasks**:
- [x] Read CLAUDE.md to identify all `docs/` references (estimated ~25 references)
- [x] Update "Project Structure" section (lines 47-107) with new Documentation/ structure
- [x] Update "Documentation Index" section (lines 109-141) with new paths
- [x] Update Developer Standards links (lines 111-116) from `docs/development/` to `Documentation/Development/`
- [x] Update User Documentation links (lines 118-127) from `docs/` to `Documentation/UserGuide/` and `Documentation/ProjectInfo/`
- [x] Update Symbol Formatting Standards links (line 130-131) to new paths
- [x] Update references in "Implementation Status" section (lines 17-18)
- [x] Update references in "Key Packages" section if any `docs/` paths exist
- [x] Update references in "Testing Architecture" section if any `docs/` paths exist
- [x] Update references in "Quality Standards" section if any `docs/` paths exist
- [x] Update references in "Common Tasks" section (lines 222-246) if any `docs/` paths exist
- [x] Update references in "Notes for Claude Code" section (lines 248-266) if any `docs/` paths exist
- [x] Perform find-replace validation: `grep -r "docs/" CLAUDE.md` should return zero results
- [x] Verify all new paths point to existing files

**Testing**:
```bash
# Verify no old docs/ references remain
if grep -q "docs/" /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md; then
  echo "ERROR: Old docs/ references still exist in CLAUDE.md"
  grep -n "docs/" /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
else
  echo "✓ No old docs/ references in CLAUDE.md"
fi

# Verify new Documentation/ references exist
DOC_REF_COUNT=$(grep -c "Documentation/" /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md)
if [ "$DOC_REF_COUNT" -lt 20 ]; then
  echo "WARNING: Expected at least 20 Documentation/ references, found $DOC_REF_COUNT"
else
  echo "✓ Found $DOC_REF_COUNT Documentation/ references in CLAUDE.md"
fi

# Verify all referenced paths exist
echo "Checking for broken links in CLAUDE.md..."
grep -o "Documentation/[^)]*\.md" /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md | sort -u | while read path; do
  if [ ! -f "/home/benjamin/Documents/Philosophy/Projects/Logos/$path" ]; then
    echo "ERROR: Broken link in CLAUDE.md: $path"
  fi
done

echo "✓ Phase 3 Complete: CLAUDE.md updated"
```

**Expected Duration**: 3 hours

---

### Phase 4: Update README.md and Documentation Cross-References [COMPLETE]
dependencies: [3]

**Objective**: Update all documentation path references in README.md and fix internal cross-references within documentation files.

**Complexity**: High

**Tasks**:
- [x] Read README.md to identify all `docs/` references (estimated ~15 references)
- [x] Update "Quick Start" section (lines 136-154) if any `docs/` paths exist
- [x] Update "Documentation" section (lines 156-175) with new paths:
  - Update User Documentation links to `Documentation/UserGuide/` and `Documentation/ProjectInfo/`
  - Update Developer Standards links to `Documentation/Development/`
- [x] Update "Project Structure" section (lines 176-238) with new Documentation/ directory structure
- [x] Update project structure diagram to show new subdirectory organization
- [x] Perform find-replace validation: `grep -r "docs/" README.md` should return zero results
- [x] Read each documentation file in `Documentation/` and identify internal cross-references
- [x] Update cross-references in `Documentation/UserGuide/ARCHITECTURE.md`
- [x] Update cross-references in `Documentation/UserGuide/TUTORIAL.md`
- [x] Update cross-references in `Documentation/UserGuide/EXAMPLES.md`
- [x] Update cross-references in `Documentation/UserGuide/INTEGRATION.md`
- [x] Update cross-references in `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- [x] Update cross-references in `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md`
- [x] Update cross-references in `Documentation/ProjectInfo/CONTRIBUTING.md`
- [x] Update cross-references in `Documentation/ProjectInfo/VERSIONING.md`
- [x] Update cross-references in `Documentation/Development/LEAN_STYLE_GUIDE.md`
- [x] Update cross-references in `Documentation/Development/MODULE_ORGANIZATION.md`
- [x] Update cross-references in `Documentation/Development/TESTING_STANDARDS.md`
- [x] Update cross-references in `Documentation/Development/TACTIC_DEVELOPMENT.md`
- [x] Update cross-references in `Documentation/Development/QUALITY_METRICS.md`
- [x] Verify all internal links use correct relative paths based on new structure

**Testing**:
```bash
# Verify no old docs/ references in README.md
if grep -q "docs/" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md; then
  echo "ERROR: Old docs/ references still exist in README.md"
  grep -n "docs/" /home/benjamin/Documents/Philosophy/Projects/Logos/README.md
else
  echo "✓ No old docs/ references in README.md"
fi

# Verify no old docs/ references in any documentation files
if grep -r "docs/" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/ 2>/dev/null; then
  echo "ERROR: Old docs/ references still exist in documentation files"
  grep -rn "docs/" /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/
else
  echo "✓ No old docs/ references in Documentation/"
fi

# Create comprehensive link validation script
cat > /tmp/validate_links.sh << 'EOF'
#!/bin/bash
PROJECT_ROOT="/home/benjamin/Documents/Philosophy/Projects/Logos"
ERRORS=0

# Find all markdown files and extract links
find "$PROJECT_ROOT/Documentation" -name "*.md" -type f | while read file; do
  # Extract markdown links [text](path)
  grep -o "\[.*\]([^)]*)" "$file" | sed 's/.*(\([^)]*\)).*/\1/' | while read link; do
    # Skip external links (http/https)
    if echo "$link" | grep -q "^http"; then
      continue
    fi

    # Skip anchors
    if echo "$link" | grep -q "^#"; then
      continue
    fi

    # Resolve relative path
    FILE_DIR=$(dirname "$file")
    LINK_PATH=$(realpath -m "$FILE_DIR/$link" 2>/dev/null)

    # Check if target exists
    if [ ! -f "$LINK_PATH" ] && [ ! -d "$LINK_PATH" ]; then
      echo "ERROR: Broken link in $file -> $link"
      ERRORS=$((ERRORS + 1))
    fi
  done
done

if [ "$ERRORS" -eq 0 ]; then
  echo "✓ All documentation links valid"
else
  echo "ERROR: Found $ERRORS broken links"
  exit 1
fi
EOF

chmod +x /tmp/validate_links.sh
bash /tmp/validate_links.sh

echo "✓ Phase 4 Complete: README.md and cross-references updated"
```

**Expected Duration**: 4 hours

---

### Phase 5: Verification and Build Testing [COMPLETE]
dependencies: [4]

**Objective**: Comprehensive verification that all documentation reorganization is complete, all links functional, and LEAN build system unaffected.

**Complexity**: Medium

**Tasks**:
- [x] Run `lake clean` to clear build artifacts
- [x] Run `lake build` and verify successful completion (no errors)
- [x] Run `lake test` and verify all tests pass (no failures)
- [x] Verify no `docs/` directory exists in project root
- [x] Verify `Documentation/` directory exists with all expected subdirectories
- [x] Count files in each Documentation/ subdirectory and verify against expected counts:
  - `Documentation/UserGuide/`: 4 files expected
  - `Documentation/ProjectInfo/`: 4 files expected
  - `Documentation/Development/`: 5 files expected
  - `Documentation/Reference/Glossary/`: 1 file expected
- [x] Run comprehensive link validation (use script from Phase 4)
- [x] Manual click-through verification: Open each documentation file and verify links work
- [x] Verify git history preserved: Run `git log --follow` on 3 sample files from different subdirectories
- [x] Create final verification report documenting all checks passed
- [x] Review git diff to ensure only expected changes (file moves and link updates)
- [x] Prepare commit message documenting reorganization

**Testing**:
```bash
# Clean and rebuild
lake clean
lake build || { echo "ERROR: lake build failed"; exit 1; }

# Run tests
lake test || { echo "ERROR: lake test failed"; exit 1; }

# Verify old docs/ removed
if [ -d /home/benjamin/Documents/Philosophy/Projects/Logos/docs ]; then
  echo "ERROR: Old docs/ directory still exists"
  exit 1
else
  echo "✓ Old docs/ directory removed"
fi

# Verify new structure exists
for dir in Documentation/UserGuide Documentation/ProjectInfo Documentation/Development Documentation/Reference/Glossary; do
  if [ ! -d "/home/benjamin/Documents/Philosophy/Projects/Logos/$dir" ]; then
    echo "ERROR: Directory $dir does not exist"
    exit 1
  fi
done
echo "✓ New Documentation/ structure verified"

# Count files in each subdirectory
USERGUIDE_COUNT=$(find /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/UserGuide -maxdepth 1 -type f -name "*.md" | wc -l)
PROJECTINFO_COUNT=$(find /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/ProjectInfo -maxdepth 1 -type f -name "*.md" | wc -l)
DEVELOPMENT_COUNT=$(find /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/Development -maxdepth 1 -type f -name "*.md" | wc -l)
GLOSSARY_COUNT=$(find /home/benjamin/Documents/Philosophy/Projects/Logos/Documentation/Reference/Glossary -maxdepth 1 -type f -name "*.md" | wc -l)

echo "File counts:"
echo "  UserGuide: $USERGUIDE_COUNT (expected 4)"
echo "  ProjectInfo: $PROJECTINFO_COUNT (expected 4)"
echo "  Development: $DEVELOPMENT_COUNT (expected 5)"
echo "  Reference/Glossary: $GLOSSARY_COUNT (expected 1)"

# Verify git history preserved (sample files)
echo "Verifying git history preservation..."
git log --follow Documentation/UserGuide/ARCHITECTURE.md | head -5 || echo "WARNING: Could not verify history for ARCHITECTURE.md"
git log --follow Documentation/Development/LEAN_STYLE_GUIDE.md | head -5 || echo "WARNING: Could not verify history for LEAN_STYLE_GUIDE.md"
git log --follow Documentation/Reference/Glossary/logical-operators.md | head -5 || echo "WARNING: Could not verify history for logical-operators.md"

# Run link validation script from Phase 4
bash /tmp/validate_links.sh || { echo "ERROR: Link validation failed"; exit 1; }

# Final summary
echo ""
echo "=========================================="
echo "VERIFICATION COMPLETE"
echo "=========================================="
echo "✓ Lake build successful"
echo "✓ Lake test successful"
echo "✓ Old docs/ directory removed"
echo "✓ New Documentation/ structure verified"
echo "✓ File counts match expectations"
echo "✓ Git history preserved"
echo "✓ All documentation links valid"
echo ""
echo "File Structure Reorganization Complete!"
echo "=========================================="
```

**Expected Duration**: 2.5 hours

**Note**: This phase completes the reorganization. After successful verification, commit changes with message: "Refactor: Reorganize documentation structure - rename docs/ to Documentation/ with subdirectories"

---

## Testing Strategy

### Per-Phase Testing
Each phase includes verification commands that ensure:
- Directory structure correctness
- File move completeness
- Link validity
- Git history preservation
- Build system compatibility

### Comprehensive Link Validation
Phase 4 introduces a comprehensive link validation script that:
- Parses all Markdown files in Documentation/
- Extracts all internal links (non-HTTP)
- Resolves relative paths
- Verifies target files exist
- Reports broken links with file and line information

### Build System Verification
Phases 1-5 each include `lake build` and `lake test` commands to ensure documentation changes don't impact LEAN code compilation or test execution.

### Manual Verification Checklist
Final phase includes manual click-through testing:
- Open each documentation file in Documentation/
- Verify cross-references navigate correctly
- Confirm relative paths resolve properly
- Test links from CLAUDE.md and README.md

## Documentation Requirements

### Files Requiring Updates

**Primary Documentation**:
- `CLAUDE.md` - Update all `docs/` references to `Documentation/` with new subdirectory paths (Phase 3)
- `README.md` - Update all `docs/` references and project structure diagram (Phase 4)

**Documentation Files with Cross-References**:
- `Documentation/UserGuide/ARCHITECTURE.md` - Update internal links
- `Documentation/UserGuide/TUTORIAL.md` - Update internal links
- `Documentation/UserGuide/EXAMPLES.md` - Update internal links
- `Documentation/UserGuide/INTEGRATION.md` - Update internal links
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` - Update internal links
- `Documentation/ProjectInfo/KNOWN_LIMITATIONS.md` - Update internal links
- `Documentation/ProjectInfo/CONTRIBUTING.md` - Update internal links
- `Documentation/ProjectInfo/VERSIONING.md` - Update internal links
- `Documentation/Development/LEAN_STYLE_GUIDE.md` - Update internal links
- `Documentation/Development/MODULE_ORGANIZATION.md` - Update internal links
- `Documentation/Development/TESTING_STANDARDS.md` - Update internal links
- `Documentation/Development/TACTIC_DEVELOPMENT.md` - Update internal links
- `Documentation/Development/QUALITY_METRICS.md` - Update internal links

### Update Patterns

**Link Format Transformations**:
1. Absolute paths from root: `docs/ARCHITECTURE.md` → `Documentation/UserGuide/ARCHITECTURE.md`
2. Relative paths from CLAUDE.md/README.md: `docs/development/LEAN_STYLE_GUIDE.md` → `Documentation/Development/LEAN_STYLE_GUIDE.md`
3. Cross-references within Documentation/: Adjust based on new relative positions

**Example Transformations**:
```markdown
# Before
See [Architecture Guide](docs/ARCHITECTURE.md)
See [LEAN Style Guide](docs/development/LEAN_STYLE_GUIDE.md)

# After (from README.md)
See [Architecture Guide](Documentation/UserGuide/ARCHITECTURE.md)
See [LEAN Style Guide](Documentation/Development/LEAN_STYLE_GUIDE.md)

# Before (from docs/ARCHITECTURE.md)
See [Known Limitations](KNOWN_LIMITATIONS.md)

# After (from Documentation/UserGuide/ARCHITECTURE.md)
See [Known Limitations](../ProjectInfo/KNOWN_LIMITATIONS.md)
```

### Documentation Standards Compliance

**From CLAUDE.md Documentation Standards**:
- Markdown format with clear section headings
- Relative links for internal cross-references
- Absolute links for external references
- Clear, concise descriptions
- 100-character line limit where feasible

**Directory Naming Conventions**:
- PascalCase for all directory names: `Documentation/`, `UserGuide/`, `ProjectInfo/`, `Development/`, `Reference/`
- Matches LEAN library directory conventions: `Logos/`, `LogosTest/`, `Archive/`, `Counterexamples/`

## Dependencies

### External Dependencies
- Git (for `git mv` commands to preserve history)
- Lake build system (for verification)
- Bash (for testing scripts)

### Internal Dependencies
- CLAUDE.md - Will be updated in Phase 3
- README.md - Will be updated in Phase 4
- All documentation files - Will be moved in Phase 2 and updated in Phase 4

### Phase Dependencies
- Phase 1: No dependencies (creates new directory structure)
- Phase 2: Depends on Phase 1 (moves files into new structure)
- Phase 3: Depends on Phase 2 (updates CLAUDE.md after files moved)
- Phase 4: Depends on Phase 3 (updates README.md and cross-references after CLAUDE.md updated)
- Phase 5: Depends on Phase 4 (final verification after all updates complete)

### Risk Assessment

**Low Risk Areas**:
- Directory creation (Phase 1)
- LEAN build system impact (documentation separate from source)
- Git history preservation (using `git mv`)

**Medium Risk Areas**:
- Link updates (automated validation mitigates)
- Cross-reference updates (comprehensive testing mitigates)

**High Risk Areas**:
- Manual editing of ~60 link references (systematic approach mitigates)
- Missing cross-references in documentation files (comprehensive link validation mitigates)

**Mitigation Strategy**:
- Incremental approach with verification after each phase
- Automated link validation script
- `lake build` and `lake test` after each phase
- Manual click-through verification in final phase
- Git history preservation using `git mv`

## Notes

### Aggregator Pattern Clarification

**Important Context from Research**:
The research identified that files like `Syntax.lean`, `Semantics.lean`, etc. at the root of `Logos/Logos/` are **aggregator files** that re-export subdirectory modules. This is **standard LEAN 4 practice** and is the correct organizational pattern.

**No Action Required on LEAN Source**:
- Aggregator files (`Logos/Syntax.lean`, etc.) are correct and should be preserved
- Subdirectories (`Logos/Syntax/`, etc.) contain actual implementations
- This pattern is transparent to Lake build system
- Documentation should clarify this pattern but no code changes needed

**Future Documentation Enhancement**:
Consider adding a section to `Documentation/Development/MODULE_ORGANIZATION.md` explaining the aggregator pattern to prevent future confusion. This could be addressed in a separate documentation accuracy plan.

### Out of Scope

This plan explicitly does NOT include:
1. Moving or renaming any LEAN source files (`.lean` files in `Logos/`, `LogosTest/`, etc.)
2. Modifying LEAN source code structure
3. Addressing missing files documented in README.md/CLAUDE.md (DSL.lean, Rules.lean, etc.)
4. Updating lakefile.toml (no changes needed for documentation reorganization)
5. Creating new documentation files
6. Modifying `.claude/` framework documentation structure

### Standards Alignment

**Directory Naming Consistency**:
This plan aligns with the project's use of PascalCase for directory names:
- LEAN libraries: `Logos/`, `LogosTest/`, `Archive/`, `Counterexamples/`
- Documentation: `Documentation/`, `UserGuide/`, `ProjectInfo/`, `Development/`, `Reference/`

**Git Best Practices**:
- Using `git mv` for all file moves to preserve history
- Atomic commits per phase for clear change tracking
- Verification after each phase before proceeding

**Testing Integration**:
- `lake build` and `lake test` verification after each phase
- Automated link validation
- Comprehensive manual verification

