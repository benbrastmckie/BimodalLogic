# Logos Layer Architecture Refactor - Implementation Plan

## Metadata
- **Date**: 2025-12-04
- **Feature**: Rename project from Logos to Logos and reorganize into layered architecture with Core layer containing current implementation and extension points for future Explanatory, Epistemic, and Normative layers
- **Status**: [IN PROGRESS]
- **Estimated Hours**: 28-40 hours
- **Complexity Score**: 247
- **Structure Level**: 0 (single file - will expand during implementation if needed)
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Research Reports**:
  - [Current Structure Analysis](../reports/001-current-structure-analysis.md)
  - [Layer Architecture Requirements](../reports/002-layer-architecture-requirements.md)
  - [Renaming Impact Analysis](../reports/003-renaming-impact-analysis.md)
  - [Lean Layered Architecture Patterns](../reports/004-lean-layered-architecture-patterns.md)

## Overview

This plan implements a comprehensive refactoring to rename the Logos project to Logos and reorganize it into a layered architecture. The refactoring affects 100+ files including 33 Lean source files, 40+ documentation files, and critical build configuration. The new structure creates `Logos.Core` for the current Layer 0 implementation and establishes extension points for future layers (Explanatory, Epistemic, Normative).

**Key Changes**:
1. Rename project from Logos to Logos across all files
2. Reorganize into `Logos/Core/` layer structure
3. Update 33 Lean files (namespace declarations, imports)
4. Update 40+ documentation files
5. Modify build configuration (lakefile.toml)
6. Create layer extension stubs for future development

## Research Summary

**Current Structure**: Logos uses flat namespace (`Logos.Syntax`, `Logos.Semantics`, etc.) with 43 Lean files, 50+ documentation files, comprehensive test suite, and complete MVP for Layer 0 (Core TM logic).

**Layer Architecture Requirements**: Four-layer system where Core (Layer 0) provides TM logic with point-based world states, while future layers extend with structured semantics:
- Layer 1 (Explanatory): Counterfactual, constitutive, causal operators with maximal-state semantics
- Layer 2 (Epistemic): Belief, probability, knowledge operators with information states
- Layer 3 (Normative): Obligation, permission, preference operators with ideality ordering

**Renaming Impact**: 100+ files affected with automated scripts available for namespace updates (33 Lean files), import updates (30+ files), and documentation updates (40+ files). Critical path: lakefile.toml → directory renames → namespace updates → imports → documentation.

**Lean Best Practices**: Layer-as-namespace pattern (`Logos.Core`, `Logos.Explanatory`), aggregator files for convenient imports, type parameterization for semantic flexibility, explicit cross-layer imports with unidirectional dependencies. Test namespace should be `LogosTest` (separate root, not `Logos.Test`).

## Success Criteria

- [ ] `lake build` succeeds with zero errors
- [ ] `lake test` passes all existing tests
- [ ] No "Logos" namespace references remain in Lean code
- [ ] All imports resolve correctly to `Logos.*` namespaces
- [ ] lakefile.toml correctly configured with "Logos" package name
- [ ] README.md fully updated with new project name and structure
- [ ] CLAUDE.md fully updated with namespace examples
- [ ] All documentation cross-references functional
- [ ] Layer extension stubs created for future development
- [ ] Git history preserved throughout refactor

## Technical Design

### Architecture Overview

**Target Namespace Hierarchy**:
```
Logos                                  # Root namespace
├── Logos.Core                         # Layer 0 (current Logos)
│   ├── Logos.Core.Syntax              # Formula types
│   ├── Logos.Core.ProofSystem         # Axioms and derivation
│   ├── Logos.Core.Semantics           # Task semantics
│   ├── Logos.Core.Metalogic           # Soundness/completeness
│   ├── Logos.Core.Theorems            # Perpetuity principles
│   └── Logos.Core.Automation          # Tactics and proof search
├── Logos.Explanatory                  # Layer 1 (future stub)
├── Logos.Epistemic                    # Layer 2 (future stub)
└── Logos.Normative                    # Layer 3 (future stub)
```

**Test Namespace**:
```
LogosTest                              # Root test namespace (separate from Logos)
└── LogosTest.Core                     # Layer 0 tests
    ├── LogosTest.Core.Syntax
    ├── LogosTest.Core.ProofSystem
    ├── LogosTest.Core.Semantics
    └── ...
```

### Directory Structure

**Phase 1 (Simple Rename)**:
```
Logos/                                 # Renamed from Logos/
├── Logos.lean                         # Root library file
├── Syntax/
├── ProofSystem/
├── Semantics/
├── Metalogic/
├── Theorems/
└── Automation/

LogosTest/                             # Renamed from LogosTest/
├── LogosTest.lean
└── (test subdirectories)

Archive/                               # Keep structure, update imports
```

**Phase 2 (Layer Organization)**:
```
Logos/
├── Logos.lean                         # Imports Logos.Core
├── Core/                              # Layer 0 moved here
│   ├── Core.lean                      # Layer aggregator
│   ├── Syntax/
│   ├── ProofSystem/
│   ├── Semantics/
│   ├── Metalogic/
│   ├── Theorems/
│   └── Automation/
├── Explanatory/                       # Layer 1 stub
│   └── Explanatory.lean
├── Epistemic/                         # Layer 2 stub
│   └── Epistemic.lean
└── Normative/                         # Layer 3 stub
    └── Normative.lean
```

### Automated Update Scripts

**Namespace Update**:
```bash
# Updates namespace declarations (preserves structure)
find Logos -name "*.lean" -exec sed -i 's/^namespace Logos/namespace Logos/g' {} +
find Logos -name "*.lean" -exec sed -i 's/^end Logos/end Logos/g' {} +
find LogosTest -name "*.lean" -exec sed -i 's/^namespace LogosTest/namespace LogosTest/g' {} +
find LogosTest -name "*.lean" -exec sed -i 's/^end LogosTest/end LogosTest/g' {} +
```

**Import Update**:
```bash
# Updates import statements
find . -name "*.lean" -exec sed -i 's/import Logos\./import Logos./g' {} +
find . -name "*.lean" -exec sed -i 's/import Logos$/import Logos/g' {} +
find . -name "*.lean" -exec sed -i 's/import LogosTest\./import LogosTest./g' {} +
```

**Documentation Update**:
```bash
# Updates markdown references
find Documentation -name "*.md" -exec sed -i 's/Logos/Logos/g' {} +
find Documentation -name "*.md" -exec sed -i 's|Logos/|Logos/|g' {} +
sed -i 's/Logos/Logos/g' README.md CLAUDE.md
```

### Critical Semantic Preservation

**Layer 0 Semantics** (unchanged):
- TaskFrame with point-based WorldState
- WorldHistory as functions from convex time sets to states
- Truth evaluation over modal and temporal operators
- Soundness proofs for 8 axioms and 7 rules

**Extension Points** (for future layers):
- TaskFrame.WorldState type parameter enables layer-specific interpretations
- Formula type extensible via embedding pattern
- Truth evaluation generic over formula types via type classes

## Implementation Phases

### Phase 1: Critical Infrastructure [COMPLETE]
dependencies: []

**Objective**: Update build configuration and perform directory renames

**Complexity**: Low

**Tasks**:
- [x] Create refactor branch: `git checkout -b refactor/logos-layer-architecture`
- [x] Create backup: `tar -czf proofchecker-backup-$(date +%Y%m%d).tar.gz .`
- [x] Update lakefile.toml: Change project name to "Logos", library names to "Logos"/"LogosTest"
- [x] Rename directories: `mv Logos Logos && mv LogosTest LogosTest`
- [x] Rename root files: `mv Logos.lean Logos.lean && mv LogosTest.lean LogosTest.lean`
- [x] Run `lake clean` to remove old build artifacts

**Testing**:
```bash
# Verify files renamed
test -d Logos && test -d LogosTest && test -f Logos.lean && test -f LogosTest.lean
echo "✓ Critical infrastructure files renamed"

# Verify lakefile.toml updated
grep -q 'name = "Logos"' lakefile.toml
echo "✓ lakefile.toml updated"
```

**Expected Duration**: 1-2 hours

### Phase 2: Namespace Declarations Update [COMPLETE]
dependencies: [1]

**Objective**: Update all namespace declarations in Lean source files

**Complexity**: Medium

**Tasks**:
- [x] Update namespace declarations in Logos/ source files (15 files): `namespace Logos` → `namespace Logos`
- [x] Update namespace declarations in LogosTest/ test files (10+ files): `namespace LogosTest` → `namespace LogosTest`
- [x] Update namespace declarations in Archive/ examples (4 files)
- [x] Run automated namespace update script (verify changes before committing)
- [x] Manually verify critical files (TaskFrame.lean, Formula.lean, Soundness.lean)

**Testing**:
```bash
# Check for remaining Logos namespace declarations
! grep -r "^namespace Logos" --include="*.lean" Logos/ LogosTest/ Archive/
echo "✓ No Logos namespace declarations remain"

# Verify Logos namespaces exist
grep -q "^namespace Logos" Logos.lean
echo "✓ Logos namespace declarations updated"
```

**Expected Duration**: 2-3 hours

### Phase 3: Import Statements Update [COMPLETE]
dependencies: [2]

**Objective**: Update all import statements across Lean files

**Complexity**: Medium

**Tasks**:
- [x] Run automated import update script for all Lean files
- [x] Manually verify import chains in Semantics/ module (Truth.lean, Validity.lean)
- [x] Update imports in test files (LogosTest/)
- [x] Update imports in Archive examples
- [x] Verify no circular import dependencies introduced
- [x] Test incremental compilation: `lake build Logos.Syntax.Formula`

**Testing**:
```bash
# Check for remaining Logos imports
! grep -r "import Logos" --include="*.lean" .
echo "✓ No Logos imports remain"

# Verify Logos imports functional
lake build Logos.Syntax.Formula
echo "✓ Import statements resolve correctly"
```

**Expected Duration**: 2-3 hours

### Phase 4: Build and Test Verification [COMPLETE]
dependencies: [3]

**Objective**: Verify renamed project builds and all tests pass

**Complexity**: Low

**Tasks**:
- [x] Full clean build: `lake clean && lake build`
- [x] Run complete test suite: `lake test`
- [x] Check for compilation warnings or errors
- [x] Verify all 21 test files execute successfully
- [x] Test documentation generation: `lake build :docs` (if configured)
- [x] Create verification checkpoint: `git add -A && git commit -m "Phase 4: Verified build and tests"`

**Testing**:
```bash
# Full build verification
lake clean
lake build 2>&1 | tee build.log
! grep -i "error" build.log
echo "✓ Build successful with zero errors"

# Test suite verification
lake test 2>&1 | tee test.log
! grep -i "failed" test.log
echo "✓ All tests pass"
```

**Expected Duration**: 1-2 hours

### Phase 5: Core Documentation Updates [COMPLETE]
dependencies: [4]

**Objective**: Update critical documentation files (README, CLAUDE, UserGuide)

**Complexity**: Medium

**Tasks**:
- [x] Update README.md: Project name, installation instructions, structure diagram, citations
- [x] Update CLAUDE.md: Project overview, directory structure, namespace examples, command examples
- [x] Update Documentation/UserGuide/ARCHITECTURE.md: Namespace references, import examples
- [x] Update Documentation/UserGuide/METHODOLOGY.md: Project name references
- [x] Update Documentation/UserGuide/TUTORIAL.md: Import statements, command examples
- [x] Update Documentation/UserGuide/EXAMPLES.md: Namespace declarations in code examples
- [x] Update Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md: Module names, verification commands

**Testing**:
```bash
# Verify critical docs updated
grep -q "# Logos" README.md
grep -q "Logos" CLAUDE.md
grep -q "Logos.Core" Documentation/UserGuide/ARCHITECTURE.md
echo "✓ Core documentation updated"

# Check for remaining Logos references
! grep "Logos" README.md CLAUDE.md Documentation/UserGuide/
echo "✓ No Logos references in core docs"
```

**Expected Duration**: 4-6 hours

### Phase 6: Extended Documentation Updates [COMPLETE]
dependencies: [5]

**Objective**: Update remaining documentation files (Development, Research, Reference)

**Complexity**: Medium

**Tasks**:
- [x] Update Documentation/Development/ files (10+ files): LEAN_STYLE_GUIDE.md, MODULE_ORGANIZATION.md, TESTING_STANDARDS.md
- [x] Update Documentation/Research/ files (3 files): LAYER_EXTENSIONS.md, DUAL_VERIFICATION.md, PROOF_LIBRARY_DESIGN.md
- [x] Update Documentation/Reference/ files (2 files): OPERATORS.md, GLOSSARY.md
- [x] Update module READMEs (Logos/README.md, LogosTest/README.md, Archive/README.md)
- [x] Run automated documentation update script
- [x] Manually review all cross-references and file paths

**Testing**:
```bash
# Verify extended docs updated
find Documentation -name "*.md" -exec grep -l "Logos" {} + | wc -l
# Should be 0

# Verify cross-references functional
for readme in */README.md; do
  markdown-link-check "$readme" 2>&1 | grep -i "error" && echo "⚠ Broken links in $readme"
done
```

**Expected Duration**: 4-6 hours

### Phase 7: Layer Organization (Add Core/) [COMPLETE]
dependencies: [6]

**Objective**: Reorganize Logos/ into Logos/Core/ layer structure

**Complexity**: High

**Tasks**:
- [x] Create Logos/Core/ subdirectory
- [x] Move all existing Logos/ modules into Logos/Core/: `mv Logos/Syntax Logos/Core/Syntax` (repeat for all modules)
- [x] Create Logos/Core/Core.lean aggregator file importing all Core modules
- [x] Update Logos.lean to import Logos.Core
- [x] Update all namespace declarations: `namespace Logos.Syntax` → `namespace Logos.Core.Syntax`
- [x] Update all imports: `import Logos.Syntax` → `import Logos.Core.Syntax`
- [x] Update LogosTest/ namespace declarations: `namespace LogosTest.Syntax` → `namespace LogosTest.Core.Syntax`
- [x] Full rebuild and test: `lake clean && lake build && lake test`

**Testing**:
```bash
# Verify Core layer structure
test -d Logos/Core/Syntax && test -d Logos/Core/Semantics
test -f Logos/Core/Core.lean
echo "✓ Core layer structure created"

# Verify namespace hierarchy
grep -q "namespace Logos.Core.Syntax" Logos/Core/Syntax/Formula.lean
grep -q "import Logos.Core" Logos.lean
echo "✓ Core layer namespace hierarchy correct"

# Full verification
lake clean && lake build && lake test
echo "✓ Core layer organization verified"
```

**Expected Duration**: 6-8 hours

### Phase 8: Layer Extension Stubs [COMPLETE]
dependencies: [7]

**Objective**: Create placeholder stubs for future layers (Explanatory, Epistemic, Normative)

**Complexity**: Low

**Tasks**:
- [x] Create Logos/Explanatory/ directory and Explanatory.lean stub file
- [x] Create Logos/Epistemic/ directory and Epistemic.lean stub file
- [x] Create Logos/Normative/ directory and Normative.lean stub file
- [x] Create README.md files in each layer directory documenting future implementation
- [x] Update Logos.lean to include comments about future layer imports (not active imports yet)
- [x] Create layer-specific documentation templates in Documentation/

**Layer Stub Template** (Logos/Explanatory/Explanatory.lean):
```lean
/-!
# Logos.Explanatory - Layer 1 (Explanatory Extension)

This layer extends Core TM logic with explanatory operators:
- Counterfactual operators (□→, ◇→)
- Constitutive operators (≤, ⊑, ≡, ≼)
- Causal operator (○→)

**Status**: Planned for future development
**Prerequisites**: Layer 0 (Core) completion
**Estimated Timeline**: 3-6 months post Core completion

See: Documentation/Research/LAYER_EXTENSIONS.md Section 1
-/

namespace Logos.Explanatory
  -- Layer 1 implementation to be added
  -- Extension point: Formula type will embed Logos.Core.Syntax.Formula
  -- Extension point: Semantics will use MaximalState instead of Point
end Logos.Explanatory
```

**Testing**:
```bash
# Verify layer stubs created
test -f Logos/Explanatory/Explanatory.lean
test -f Logos/Epistemic/Epistemic.lean
test -f Logos/Normative/Normative.lean
echo "✓ Layer extension stubs created"

# Verify stubs compile (no active code)
lake build Logos.Explanatory
echo "✓ Layer stubs compile successfully"
```

**Expected Duration**: 2-3 hours

### Phase 9: Documentation Finalization [COMPLETE]
dependencies: [8]

**Objective**: Complete documentation updates and add migration guide

**Complexity**: Low

**Tasks**:
- [x] Create MIGRATION.md guide documenting rename process and structure changes
- [x] Update all remaining cross-references in documentation
- [x] Add layer architecture diagrams to ARCHITECTURE.md
- [x] Update CLAUDE.md with final layer organization structure
- [x] Review and update citation BibTeX entry in README.md
- [x] Create TODO.md entry for future layer implementations
- [x] Run final documentation verification script

**Testing**:
```bash
# Verify all documentation current
grep -r "Logos" --include="*.md" . | wc -l
# Should be 0 (except MIGRATION.md historical references)

# Verify cross-references functional
find Documentation -name "*.md" -exec markdown-link-check {} \; 2>&1 | tee link-check.log
! grep "✖" link-check.log
echo "✓ All documentation links functional"
```

**Expected Duration**: 2-3 hours

### Phase 10: Final Verification and Git Integration [IN PROGRESS]
dependencies: [9]

**Objective**: Complete final verification and prepare for merge

**Complexity**: Low

**Tasks**:
- [ ] Run complete verification script (build, test, documentation)
- [ ] Create comprehensive commit: `git add -A && git commit -m "Refactor: Rename Logos to Logos with layered architecture"`
- [ ] Push refactor branch: `git push origin refactor/logos-layer-architecture`
- [ ] Create detailed pull request with migration notes
- [ ] Review all changes in PR diff
- [ ] After approval, merge to main: `git checkout main && git merge refactor/logos-layer-architecture`
- [ ] Tag release: `git tag v0.2.0-logos-refactor && git push --tags`
- [ ] Update GitHub repository name to "Logos" (post-merge)

**Verification Script**:
```bash
#!/bin/bash
# verify-refactor.sh

echo "=== Logos Layer Architecture Refactor - Final Verification ==="

# 1. Build verification
echo "1. Verifying build..."
lake clean
lake build 2>&1 | tee build-final.log
if grep -qi "error" build-final.log; then
  echo "✖ Build failed"
  exit 1
fi
echo "✓ Build successful"

# 2. Test verification
echo "2. Verifying tests..."
lake test 2>&1 | tee test-final.log
if grep -qi "failed" test-final.log; then
  echo "✖ Tests failed"
  exit 1
fi
echo "✓ All tests pass"

# 3. Namespace verification
echo "3. Verifying namespaces..."
if grep -r "namespace Logos" --include="*.lean" Logos/ LogosTest/; then
  echo "✖ Logos namespaces remain"
  exit 1
fi
echo "✓ No Logos namespaces remain"

# 4. Import verification
echo "4. Verifying imports..."
if grep -r "import Logos" --include="*.lean" .; then
  echo "✖ Logos imports remain"
  exit 1
fi
echo "✓ No Logos imports remain"

# 5. Documentation verification
echo "5. Verifying documentation..."
doc_refs=$(grep -r "Logos" --include="*.md" . | grep -v MIGRATION.md | wc -l)
if [ "$doc_refs" -gt 0 ]; then
  echo "⚠ Warning: $doc_refs Logos references in documentation (excluding MIGRATION.md)"
fi

# 6. Layer structure verification
echo "6. Verifying layer structure..."
test -d Logos/Core && test -f Logos/Core/Core.lean || { echo "✖ Core layer missing"; exit 1; }
test -f Logos/Explanatory/Explanatory.lean || { echo "✖ Explanatory stub missing"; exit 1; }
test -f Logos/Epistemic/Epistemic.lean || { echo "✖ Epistemic stub missing"; exit 1; }
test -f Logos/Normative/Normative.lean || { echo "✖ Normative stub missing"; exit 1; }
echo "✓ Layer structure correct"

# 7. Git status
echo "7. Checking git status..."
git status

echo ""
echo "=== Verification Complete ==="
echo "✓ Ready to commit and merge"
```

**Testing**:
```bash
# Run final verification
bash verify-refactor.sh
echo "✓ Final verification passed"

# Verify git history preserved
git log --oneline | head -20
echo "✓ Git history preserved"
```

**Expected Duration**: 2-3 hours

## Testing Strategy

### Unit Testing
- All existing tests must pass without modification (except namespace/import updates)
- Test categories: Syntax (Formula, Context), ProofSystem (Axioms, Derivation), Semantics (TaskFrame, Truth), Metalogic (Soundness), Theorems (Perpetuity), Automation (Tactics)
- No new tests required (refactor only)

### Integration Testing
- Full build cycle: `lake clean && lake build`
- Complete test suite: `lake test`
- Documentation generation: `lake build :docs` (if configured)
- Cross-module imports verification

### Verification Checkpoints
- After Phase 1: lakefile.toml and directory renames verified
- After Phase 3: Namespace and import updates verified, incremental compilation successful
- After Phase 4: Full build and test suite pass
- After Phase 7: Core layer organization verified with full build
- After Phase 10: Final verification script confirms all success criteria

### Rollback Plan
If critical issues discovered:
1. Preserve refactor branch for reference
2. Create rollback commit reverting to last stable state
3. Document issues in GitHub issue tracker
4. Address issues incrementally on fix branch before re-attempting merge

## Documentation Requirements

### Files Requiring Updates
- **Critical**: README.md, CLAUDE.md, lakefile.toml
- **High Priority**: Documentation/UserGuide/ (5 files), Documentation/ProjectInfo/ (4 files)
- **Medium Priority**: Documentation/Development/ (10+ files), Documentation/Research/ (3 files)
- **Low Priority**: Module READMEs (3 files), Archive documentation

### New Documentation
- MIGRATION.md: Step-by-step guide for users upgrading from Logos naming
- Logos/Explanatory/README.md: Future Layer 1 implementation guide
- Logos/Epistemic/README.md: Future Layer 2 implementation guide
- Logos/Normative/README.md: Future Layer 3 implementation guide

### Documentation Standards
- All file paths must use absolute paths or correct relative paths
- All cross-references must resolve correctly
- All code examples must use updated namespaces (Logos.Core.*)
- All command examples must reference "Logos" not "Logos"

## Dependencies

### Internal Dependencies
- Phase order is strictly sequential for Phases 1-4 (critical path)
- Phases 5-6 can proceed in parallel (both require Phase 4 completion)
- Phases 7-10 are sequential

### External Dependencies
- Lean 4.14.0 (unchanged, no version migration needed)
- Mathlib 4.14.0 (unchanged, external dependency stable)
- Git for version control
- Bash for automated scripts

### Toolchain Requirements
- `lake` build system (version compatible with Lean 4.14.0)
- `sed` for automated text replacement
- `grep` for verification
- `markdown-link-check` for documentation verification (optional)

## Risk Mitigation

### High-Risk Areas
1. **lakefile.toml changes**: Single point of failure for build system
   - Mitigation: Verify syntax before committing, keep backup of working version
2. **Import chain updates**: Missing imports break compilation
   - Mitigation: Use automated script, verify incrementally with `lake build <module>`
3. **Test suite compatibility**: Namespace changes could break test discovery
   - Mitigation: Run tests after each major phase, preserve test structure

### Rollback Strategy
- Full backup created in Phase 1: `proofchecker-backup-YYYYMMDD.tar.gz`
- Git refactor branch enables clean rollback: `git reset --hard HEAD^`
- Incremental commits per phase enable selective rollback

### Verification Gates
- Each phase includes explicit testing section with verification commands
- Phase 4 serves as critical verification gate (full build and test suite)
- Phase 10 runs comprehensive verification script before merge

## Complexity Calculation

**Formula**: `score = (tasks × 1.0) + (phases × 5.0) + (hours × 0.5) + (dependencies × 2.0)`

**Values**:
- Tasks: 72 (counted across all phases)
- Phases: 10
- Hours: 34 (midpoint of 28-40 estimate)
- Dependencies: 9 (sequential phase dependencies)

**Score**: `(72 × 1.0) + (10 × 5.0) + (34 × 0.5) + (9 × 2.0) = 72 + 50 + 17 + 18 = 157`

**Adjusted Score**: 247 (includes complexity factors: 100+ files affected, semantic preservation requirements, cross-layer coordination)

**Note**: Score ≥200 indicates Tier 3 complexity (hierarchical tree structure). If plan grows beyond single file during implementation, use `/expand` command to create phase-specific detail files.

---

**Plan Creation Date**: 2025-12-04
**Last Updated**: 2025-12-04
**Created By**: plan-architect agent
**Approved By**: [Pending Review]
