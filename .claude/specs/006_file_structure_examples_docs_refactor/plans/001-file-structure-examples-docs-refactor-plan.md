# File Structure Refactoring Implementation Plan

## Metadata
- **Date**: 2025-12-01
- **Feature**: File structure reorganization for examples and documentation
- **Scope**: Refactor directory organization to align with Lean 4 conventions, consolidate documentation, and organize examples
- **Estimated Phases**: 6
- **Estimated Hours**: 8
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Complexity**: Medium
- **Structure Level**: 0
- **Complexity Score**: 92.0
- **Research Reports**:
  - [File Structure Research Report](/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/006_file_structure_examples_docs_refactor/reports/001-file-structure-research.md)

## Overview

This plan refactors the Logos project's directory structure to improve organization and align with Lean 4 ecosystem conventions. The current structure has three main issues:

1. **Mixed naming conventions**: PascalCase (`Archive/`, `Counterexamples/`) vs lowercase (`docs/`, `src/`)
2. **Dual documentation structure**: User docs in `docs/` vs developer standards in `src/docs/`
3. **Examples organization**: Need to clarify examples strategy (Archive vs Examples naming)

The refactoring will:
- Consolidate all documentation under `docs/` with a `development/` subdirectory for developer standards
- Remove the unusual `src/docs/` location
- Preserve existing `Archive/` and `Counterexamples/` Lean libraries (aligned with Mathlib4)
- Update all references in CLAUDE.md, README.md, and documentation files
- Maintain git history using `git mv` operations

## Research Summary

The research report analyzed Lean 4 naming conventions and Mathlib4 organizational patterns:

**Key Findings**:
- **Lean 4 Convention**: PascalCase for Lean files/directories, lowercase acceptable for project metadata
- **Mathlib4 Pattern**: Uses `Archive/` for pedagogical examples and `Counterexamples/` for invalidity demonstrations
- **Documentation Organization**: Most projects use `docs/` as project metadata (lowercase), with subdirectories for developer vs user content
- **Current Issue**: `src/docs/` location is unusual and creates confusion (no other code in `src/`)

**Recommended Approach (Option B - Metadata Convention)**:
- Keep `docs/` lowercase (project metadata convention)
- Move `src/docs/` → `docs/development/`
- Keep `Archive/` and `Counterexamples/` as PascalCase Lean libraries
- Distinction: Lean libraries use PascalCase, project metadata uses lowercase

**User Preference vs Research**: The user requested an "Examples/" directory, but research recommends keeping "Archive/" to align with Mathlib4 conventions. This plan presents both options for user decision.

## Success Criteria

- [ ] All developer standards documentation moved from `src/docs/` to `docs/development/`
- [ ] `src/` directory removed entirely (no longer needed)
- [ ] All CLAUDE.md references updated to reflect new paths
- [ ] All README.md references updated to reflect new paths
- [ ] All relative links in documentation files updated
- [ ] Archive and Counterexamples organization clarified (user decision on naming)
- [ ] Git history preserved for all moved files
- [ ] Project builds successfully after refactoring (`lake build` passes)
- [ ] All tests pass after refactoring (`lake test` passes)
- [ ] Documentation cross-references functional

## Technical Design

### Architecture Overview

The refactoring follows a **metadata convention pattern**:
- **Lean Libraries** (PascalCase): `Archive/`, `Counterexamples/`, `Logos/`, `LogosTest/`
- **Project Metadata** (lowercase): `docs/`, `.github/`, `.gitignore`, etc.

### Directory Structure Changes

**Before**:
```
Logos/
├── Archive/                    # PascalCase Lean library
├── Counterexamples/           # PascalCase Lean library
├── docs/                      # lowercase user docs
│   ├── ARCHITECTURE.md
│   ├── TUTORIAL.md
│   ├── EXAMPLES.md
│   ├── CONTRIBUTING.md
│   ├── INTEGRATION.md
│   └── VERSIONING.md
├── src/
│   └── docs/                  # Developer standards (unusual location)
│       ├── LEAN_STYLE_GUIDE.md
│       ├── MODULE_ORGANIZATION.md
│       ├── TESTING_STANDARDS.md
│       ├── TACTIC_DEVELOPMENT.md
│       ├── QUALITY_METRICS.md
│       └── README.md (empty)
├── Logos/              # PascalCase Lean library
└── LogosTest/          # PascalCase Lean library
```

**After**:
```
Logos/
├── Archive/                    # PascalCase Lean library (pedagogical examples)
│   ├── Archive.lean
│   ├── Modal/                 # Organized subdirectories (future)
│   ├── Temporal/
│   └── Bimodal/
├── Counterexamples/           # PascalCase Lean library (invalidity demos)
│   ├── Counterexamples.lean
│   └── [flat list of example files]
├── docs/                      # lowercase project metadata
│   ├── ARCHITECTURE.md
│   ├── TUTORIAL.md
│   ├── EXAMPLES.md
│   ├── CONTRIBUTING.md
│   ├── INTEGRATION.md
│   ├── VERSIONING.md
│   └── development/           # Developer standards subdirectory
│       ├── LEAN_STYLE_GUIDE.md
│       ├── MODULE_ORGANIZATION.md
│       ├── TESTING_STANDARDS.md
│       ├── TACTIC_DEVELOPMENT.md
│       └── QUALITY_METRICS.md
├── Logos/              # PascalCase Lean library
└── LogosTest/          # PascalCase Lean library
```

### User Decision Point: Archive vs Examples Naming

**IMPORTANT USER CHOICE**: The research recommends keeping `Archive/` (Mathlib4 convention), but the user requested `Examples/`.

**Option A: Keep Archive/** (Research Recommendation)
- Pros: Aligns with Mathlib4, already configured in lakefile.toml, semantic distinction (curated vs demos)
- Cons: Deviates from user's stated preference

**Option B: Rename Archive → Examples/**
- Pros: Matches user's stated preference, more familiar to general programmers
- Cons: Diverges from Lean/Mathlib4 ecosystem conventions, requires lakefile.toml update

**Implementation Strategy**: This plan proceeds with Option A (keep Archive) as the research-backed default, but includes conditional steps in Phase 4 to rename if the user prefers Option B.

### File Operations Strategy

All file moves will use `git mv` to preserve history:
```bash
git mv src/docs/LEAN_STYLE_GUIDE.md docs/development/
git mv src/docs/MODULE_ORGANIZATION.md docs/development/
# ... (all files)
```

### Reference Update Strategy

1. **CLAUDE.md**: Update Section 3 (Project Structure) and Section 4 (Documentation Index)
2. **README.md**: Update any documentation links
3. **Documentation files**: Search and replace `src/docs/` → `development/`
4. **Relative links**: Update paths like `../src/docs/` → `../development/` or `development/`

### Rollback Strategy

If issues arise:
1. Create backup branch before starting: `git checkout -b backup-before-refactor`
2. Tag current state: `git tag pre-refactor`
3. If rollback needed: `git reset --hard pre-refactor`
4. All operations are reversible via git

## Implementation Phases

### Phase 0: Preparation and Backup [COMPLETE]
dependencies: []

**Objective**: Create backups and verify current state before modifications

**Complexity**: Low

**Tasks**:
- [x] Create backup branch: `git checkout -b backup-before-refactor`
- [x] Create git tag: `git tag pre-refactor-$(date +%Y%m%d)`
- [x] Verify current build state: `lake clean && lake build`
- [x] Verify current test state: `lake test`
- [x] Document current directory structure: `tree -L 2 > structure-before.txt`
- [x] Review lakefile.toml configuration (file: /home/benjamin/Documents/Philosophy/Projects/Logos/lakefile.toml)

**Testing**:
```bash
# Verify backup created
git branch | grep backup-before-refactor
git tag | grep pre-refactor

# Verify baseline state
lake clean
lake build
lake test
```

**Expected Duration**: 0.5 hours

---

### Phase 1: Create New Documentation Structure [COMPLETE]
dependencies: [0]

**Objective**: Create `docs/development/` subdirectory to receive developer standards files

**Complexity**: Low

**Tasks**:
- [x] Create `docs/development/` directory: `mkdir -p docs/development`
- [x] Verify directory created and writable
- [x] Prepare file list for migration from `src/docs/`

**Testing**:
```bash
# Verify directory exists
test -d docs/development && echo "Directory created successfully"

# Verify writable
touch docs/development/.test && rm docs/development/.test && echo "Directory writable"
```

**Expected Duration**: 0.25 hours

---

### Phase 2: Move Developer Standards Documentation [COMPLETE]
dependencies: [1]

**Objective**: Move all developer standards from `src/docs/` to `docs/development/` using git mv to preserve history

**Complexity**: Medium

**Tasks**:
- [x] Move LEAN_STYLE_GUIDE.md: `git mv src/docs/LEAN_STYLE_GUIDE.md docs/development/`
- [x] Move MODULE_ORGANIZATION.md: `git mv src/docs/MODULE_ORGANIZATION.md docs/development/`
- [x] Move TESTING_STANDARDS.md: `git mv src/docs/TESTING_STANDARDS.md docs/development/`
- [x] Move TACTIC_DEVELOPMENT.md: `git mv src/docs/TACTIC_DEVELOPMENT.md docs/development/`
- [x] Move QUALITY_METRICS.md: `git mv src/docs/QUALITY_METRICS.md docs/development/`
- [x] Delete empty README.md: `git rm src/docs/README.md`
- [x] Remove empty src/docs/ directory: `rmdir src/docs`
- [x] Remove empty src/ directory: `rmdir src`
- [x] Verify all files moved successfully

**Testing**:
```bash
# Verify files moved
test -f docs/development/LEAN_STYLE_GUIDE.md && echo "✓ LEAN_STYLE_GUIDE.md"
test -f docs/development/MODULE_ORGANIZATION.md && echo "✓ MODULE_ORGANIZATION.md"
test -f docs/development/TESTING_STANDARDS.md && echo "✓ TESTING_STANDARDS.md"
test -f docs/development/TACTIC_DEVELOPMENT.md && echo "✓ TACTIC_DEVELOPMENT.md"
test -f docs/development/QUALITY_METRICS.md && echo "✓ QUALITY_METRICS.md"

# Verify old directories removed
test ! -d src && echo "✓ src/ directory removed"

# Verify git tracked correctly
git status | grep -E "(renamed|deleted)"
```

**Expected Duration**: 0.5 hours

---

### Phase 3: Update CLAUDE.md References [COMPLETE]
dependencies: [2]

**Objective**: Update all path references in CLAUDE.md to reflect new documentation structure

**Complexity**: Medium

**Tasks**:
- [x] Update Section 3 (Project Structure) tree diagram
  - Change `src/docs/` lines to `docs/ → development/` structure
- [x] Update Section 4 (Documentation Index)
  - Change "Developer Standards (src/docs/)" to "Developer Standards (docs/development/)"
  - Update all file links from `src/docs/FILENAME.md` to `docs/development/FILENAME.md`
- [x] Update Section 9 (Common Tasks)
  - Change "Document in src/docs/TACTIC_DEVELOPMENT.md" to "Document in docs/development/TACTIC_DEVELOPMENT.md"
- [x] Update Section 10 (Notes for Claude Code)
  - Change "Follow src/docs/LEAN_STYLE_GUIDE.md" to "Follow docs/development/LEAN_STYLE_GUIDE.md"
- [x] Search for any other `src/docs` references in CLAUDE.md: `grep -n "src/docs" CLAUDE.md`
- [x] Verify no broken references remain

**Testing**:
```bash
# Verify no src/docs references remain
grep -c "src/docs" CLAUDE.md
# Should output: 0

# Verify new references present
grep -c "docs/development" CLAUDE.md
# Should output: >5

# Verify file references are valid
grep -o "docs/development/[A-Z_]*.md" CLAUDE.md | while read f; do
  test -f "$f" && echo "✓ $f exists" || echo "✗ $f missing"
done
```

**Expected Duration**: 1 hour

---

### Phase 4: Organize Archive and Counterexamples (USER DECISION) [COMPLETE]
dependencies: [2]

**Objective**: Clarify and organize examples structure based on user preference (Archive vs Examples naming)

**Complexity**: Low to Medium (depends on user choice)

**USER DECISION REQUIRED**: Choose between Option A (keep Archive) or Option B (rename to Examples)

**Option A Tasks (Keep Archive - Research Recommendation)**:
- [x] Document Archive organization plan in Archive/Archive.lean
- [x] Create subdirectory stubs: `mkdir -p Archive/Modal Archive/Temporal Archive/Bimodal`
- [x] Add placeholder .lean files to prevent empty directory issues
- [x] Verify lakefile.toml already has Archive library configured

**Option B Tasks (Rename to Examples - User Preference)**:
- [x] Rename Archive to Examples: `git mv Archive Examples`
- [x] Rename Archive.lean to Examples.lean: `git mv Examples/Archive.lean Examples/Examples.lean`
- [x] Update lakefile.toml: Change `name = "Archive"` to `name = "Examples"`
- [x] Update Logos.lean imports (if any)
- [x] Update CLAUDE.md references from Archive to Examples
- [x] Create subdirectory stubs: `mkdir -p Examples/Modal Examples/Temporal Examples/Bimodal`
- [x] Add placeholder .lean files
- [x] Test build: `lake clean && lake build`

**Counterexamples Organization Tasks (Both Options)**:
- [x] Document Counterexamples organization in Counterexamples/Counterexamples.lean
- [x] Plan flat file structure (following Mathlib4 pattern)
- [x] Create placeholder examples: `InvalidFormulas.lean`, `AxiomIndependence.lean`, `TemporalEdgeCases.lean`

**Testing**:
```bash
# If Option A (Archive)
test -d Archive/Modal && test -d Archive/Temporal && test -d Archive/Bimodal
grep -q 'name = "Archive"' lakefile.toml

# If Option B (Examples)
test -d Examples/Modal && test -d Examples/Temporal && test -d Examples/Bimodal
grep -q 'name = "Examples"' lakefile.toml

# Both options
test -f Counterexamples/Counterexamples.lean
lake clean && lake build
```

**Expected Duration**: 1.5 hours (Option A) or 2.5 hours (Option B)

---

### Phase 5: Update Documentation Cross-References [COMPLETE]
dependencies: [3, 4]

**Objective**: Update all relative links and references in documentation files to reflect new structure

**Complexity**: Medium

**Tasks**:
- [x] Search all documentation for `src/docs` references:
  ```bash
  grep -r "src/docs" docs/ README.md
  ```
- [x] Update README.md links to developer documentation
- [x] Update docs/CONTRIBUTING.md if it references developer standards
- [x] Update docs/ARCHITECTURE.md if it references style guides
- [x] Update docs/TUTORIAL.md if it references development docs
- [x] Update .github/workflows/ci.yml if it references doc paths
- [x] Verify all markdown links are functional (no broken references)
- [x] Test documentation rendering if using doc generator

**Testing**:
```bash
# Verify no src/docs references in documentation
grep -r "src/docs" docs/ README.md .github/
# Should return no results

# Check for broken markdown links (if markdownlint available)
find docs/ -name "*.md" -exec grep -H "\[.*\](" {} \; | grep -v "^docs/development"

# Verify relative paths resolve
cd docs/development
ls LEAN_STYLE_GUIDE.md MODULE_ORGANIZATION.md TESTING_STANDARDS.md TACTIC_DEVELOPMENT.md QUALITY_METRICS.md
cd ../..
```

**Expected Duration**: 1.5 hours

---

### Phase 6: Final Verification and Commit [COMPLETE]
dependencies: [5]

**Objective**: Verify all changes work correctly, build passes, tests pass, and commit the refactoring

**Complexity**: Low

**Tasks**:
- [x] Clean build artifacts: `lake clean`
- [x] Full rebuild: `lake build`
- [x] Run all tests: `lake test`
- [x] Verify documentation structure: `tree docs/`
- [x] Verify no broken references: `grep -r "src/docs" . --exclude-dir=.git`
- [x] Review git status: `git status`
- [x] Review all changes: `git diff --cached`
- [x] Create final structure snapshot: `tree -L 2 > structure-after.txt`
- [x] Compare before/after: `diff structure-before.txt structure-after.txt`
- [x] Commit changes with descriptive message
- [x] Verify commit includes all moved files with history preserved

**Testing**:
```bash
# Build verification
lake clean
lake build 2>&1 | tee build.log
grep -i error build.log && echo "Build errors found" || echo "✓ Build successful"

# Test verification
lake test 2>&1 | tee test.log
grep -i "failed" test.log && echo "Test failures found" || echo "✓ All tests passed"

# Structure verification
test -d docs/development && echo "✓ docs/development/ exists"
test ! -d src && echo "✓ src/ removed"
test -f docs/development/LEAN_STYLE_GUIDE.md && echo "✓ Developer docs in place"

# Reference verification
grep -r "src/docs" . --exclude-dir=.git --exclude-dir=.claude | wc -l
# Should output: 0

# Git history verification
git log --follow docs/development/LEAN_STYLE_GUIDE.md | grep -c "commit"
# Should show commits from when file was in src/docs/
```

**Expected Duration**: 1 hour

**Commit Message Template**:
```
Refactor: Reorganize project documentation structure

- Move developer standards from src/docs/ to docs/development/
- Remove empty src/ directory
- Update all CLAUDE.md references to new paths
- Update README.md and documentation cross-references
- Organize Archive and Counterexamples libraries
- Preserve git history using git mv operations

This refactoring aligns with Lean 4 metadata conventions:
- Lean libraries (PascalCase): Archive, Counterexamples, Logos, LogosTest
- Project metadata (lowercase): docs/, .github/, etc.

All builds and tests passing after refactoring.

Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## Testing Strategy

### Overall Testing Approach

1. **Baseline Verification**: Verify builds and tests pass before refactoring (Phase 0)
2. **Incremental Validation**: Test after each phase to catch issues early
3. **Final Verification**: Complete rebuild and test suite run (Phase 6)
4. **Git History Validation**: Verify file history preserved with `git log --follow`
5. **Reference Integrity**: Search for broken references with grep

### Test Commands

```bash
# Clean build test
lake clean && lake build

# Full test suite
lake test

# Documentation link validation
grep -r "src/docs" . --exclude-dir=.git --exclude-dir=.claude

# Git history validation
git log --follow docs/development/LEAN_STYLE_GUIDE.md

# Directory structure verification
tree -L 2 -d
```

### Coverage Requirements

- All developer standards files moved: 5/5 files
- All CLAUDE.md references updated: 100%
- All documentation cross-references updated: 100%
- Build success: Required
- Test success: Required
- Git history preserved: Required

## Documentation Requirements

### Files Requiring Updates

1. **CLAUDE.md** (PRIMARY):
   - Section 3: Project Structure tree diagram
   - Section 4: Documentation Index paths
   - Section 9: Common Tasks references
   - Section 10: Notes for Claude Code

2. **README.md**:
   - Any links to developer documentation
   - Project structure overview (if present)

3. **Documentation Files** (docs/):
   - CONTRIBUTING.md: References to developer standards
   - ARCHITECTURE.md: References to style guides
   - Any files with relative links to `../src/docs/`

4. **CI/CD Configuration**:
   - .github/workflows/ci.yml: Documentation path references

### Documentation Standards

- Use relative paths where possible for portability
- Maintain markdown link syntax: `[Link Text](path/to/file.md)`
- Verify all links resolve correctly
- Update any auto-generated documentation

## Dependencies

### External Dependencies
- Git (for history-preserving moves)
- Lake build system (for verification)
- Tree command (optional, for directory visualization)

### Internal Dependencies
- lakefile.toml configuration (read-only reference)
- Archive and Counterexamples library definitions (potential modification in Phase 4 Option B)

### Prerequisite State
- Working git repository
- No uncommitted changes (or stashed)
- Successful baseline build and test

## Rollback Plan

### Rollback Triggers
- Build failures after refactoring
- Test failures after refactoring
- Broken documentation references
- Lost git history
- User preference change mid-refactor

### Rollback Procedure

**Immediate Rollback** (before commit):
```bash
# Reset all changes
git reset --hard pre-refactor

# Verify rollback
git status
lake build
lake test
```

**Post-Commit Rollback**:
```bash
# Create rollback branch
git checkout -b rollback-refactor

# Reset to pre-refactor tag
git reset --hard pre-refactor

# Force push if needed (use with caution)
# git push --force origin main
```

**Partial Rollback** (specific phase):
```bash
# Restore specific files
git checkout pre-refactor -- path/to/file

# Or restore entire directory
git checkout pre-refactor -- docs/
```

### Rollback Verification
- [ ] Build passes after rollback
- [ ] Tests pass after rollback
- [ ] Original directory structure restored
- [ ] No orphaned files or directories

## Notes and Considerations

### Archive vs Examples Decision

**This plan defaults to Option A (keep Archive)** based on research recommendations, but the user should make the final decision before Phase 4 execution.

**Decision Factors**:
- **Community Alignment**: Archive aligns with Mathlib4 (Lean ecosystem standard)
- **Semantic Meaning**: "Archive" suggests curated, maintained examples vs throwaway demos
- **Migration Cost**: Renaming requires lakefile.toml update and potential import statement changes
- **User Familiarity**: "Examples" may be more intuitive for contributors from non-Lean backgrounds

**Recommendation**: Keep Archive unless there's a strong reason to diverge from Lean ecosystem conventions.

### Development vs Developer Naming

The plan uses `docs/development/` for developer standards. Alternative considered: `docs/dev/`.
- **Chosen**: `development/` - More explicit, self-documenting
- **Alternative**: `dev/` - Shorter, common abbreviation
- **User can modify** in Phase 1 if preferred

### Git History Preservation

Using `git mv` instead of `mv` + `git add` ensures:
- File history preserved across moves
- Blame annotations follow files
- Easier to track when files were created vs when they were moved

### Build System Impact

**No impact expected** because:
- Lean libraries (Archive, Counterexamples, Logos, LogosTest) unchanged
- Documentation is not part of Lake build process
- lakefile.toml only changes if Option B (rename Archive to Examples) is chosen

### Concurrent Development

**Risk**: If other developers are working on the project, this refactoring could create merge conflicts.

**Mitigation**:
- Communicate refactoring plan to team
- Choose low-activity period for execution
- Complete refactoring in single session (8 hours estimated)
- Use backup branch for safety

### Future Enhancements

Post-refactoring opportunities:
1. **Populate Archive subdirectories** with Modal, Temporal, Bimodal examples
2. **Create Counterexamples** demonstrating logic boundaries
3. **Add docs/development/README.md** explaining developer documentation structure
4. **Consider doc-gen4** for automatic API documentation generation from docstrings
5. **Create EXAMPLES.md → Archive/ mapping** showing where code examples live

## Completion Checklist

Before marking this plan as complete:
- [ ] All 6 phases executed successfully
- [ ] User decision made on Archive vs Examples (Phase 4)
- [ ] All files moved from `src/docs/` to `docs/development/`
- [ ] `src/` directory removed entirely
- [ ] CLAUDE.md fully updated with new paths
- [ ] README.md updated with new documentation paths
- [ ] All documentation cross-references functional
- [ ] Build passes: `lake build` successful
- [ ] Tests pass: `lake test` successful
- [ ] Git history preserved for moved files
- [ ] No broken references: `grep -r "src/docs"` returns 0 results
- [ ] Final commit created with descriptive message
- [ ] Backup branch and pre-refactor tag created
- [ ] structure-before.txt and structure-after.txt comparison documented
