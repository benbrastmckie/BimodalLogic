# Renaming Impact Analysis: Logos → Logos

**Report Date**: 2025-12-04
**Analysis Scope**: Complete impact assessment of renaming project from Logos to Logos
**Purpose**: Identify all files, references, and configurations requiring changes

## Executive Summary

Renaming Logos to Logos affects 100+ files across source code, tests, documentation, and configuration. This report provides a comprehensive inventory of changes needed, organized by impact level and file type.

## 1. High-Impact Changes (Build-Breaking)

### 1.1 Build Configuration

#### lakefile.toml (CRITICAL)

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/lakefile.toml`

**Current Content**:
```toml
name = "Logos"
version = "0.1.0"
keywords = ["logic", "modal-logic", "temporal-logic", "proof-system", "lean4"]
license = "MIT"

[[lean_lib]]
name = "Logos"

[[lean_lib]]
name = "LogosTest"

[[lean_lib]]
name = "Archive"

[[lean_exe]]
name = "test"
root = "LogosTest.Main"
```

**Required Changes**:
```toml
name = "Logos"                          # Change project name
version = "0.1.0"
keywords = ["logic", "modal-logic", "temporal-logic", "formal-language", "lean4"]
license = "MIT"

[[lean_lib]]
name = "Logos"                          # Change library name

[[lean_lib]]
name = "LogosTest"                      # Change test library name

[[lean_lib]]
name = "Archive"                        # Keep or rename to LogosArchive

[[lean_exe]]
name = "test"
root = "LogosTest.Main"                 # Update test root
```

**Impact**: Build system will fail if not updated correctly. Must be first change.

### 1.2 Root Directory Rename

**Current**: `/home/benjamin/Documents/Philosophy/Projects/Logos/`
**Target**: `/home/benjamin/Documents/Philosophy/Projects/Logos/`

**Decision Point**: Should the repository directory be renamed?
- **Option A**: Rename directory (full consistency)
- **Option B**: Keep directory name (minimize disruption)

**Recommendation**: Rename directory for full consistency, but document old path in migration guide.

### 1.3 Main Source Directory

**Current**: `Logos/` (source directory)
**Target**: `Logos/Core/` (with layer organization)

**Files to Rename**:
```
Logos/ → Logos/Core/
  ├── Syntax/ → Logos/Core/Syntax/
  ├── ProofSystem/ → Logos/Core/ProofSystem/
  ├── Semantics/ → Logos/Core/Semantics/
  ├── Metalogic/ → Logos/Core/Metalogic/
  ├── Theorems/ → Logos/Core/Theorems/
  └── Automation/ → Logos/Core/Automation/
```

**Alternative (Simpler for Phase 1)**:
```
Logos/ → Logos/
  (Keep subdirectories as-is, add Core/ layer in Phase 2)
```

**Recommendation**: Phase 1 (simple rename), Phase 2 (add Core/ layer).

### 1.4 Root Library Files

#### Logos.lean → Logos.lean

**Current**: `Logos.lean`
**Target**: `Logos.lean`

**Current Content**:
```lean
-- Re-export public API
import Logos.Syntax
import Logos.ProofSystem
import Logos.Semantics
import Logos.Metalogic
import Logos.Theorems
import Logos.Automation

namespace Logos
def version : String := "0.1.0"
end Logos
```

**Required Changes**:
```lean
-- Re-export public API
import Logos.Syntax
import Logos.ProofSystem
import Logos.Semantics
import Logos.Metalogic
import Logos.Theorems
import Logos.Automation

namespace Logos
def version : String := "0.1.0"
end Logos
```

**Impact**: All imports of `Logos` will break.

### 1.5 Test Directory

**Current**: `LogosTest/`
**Target**: `LogosTest/`

**Files to Rename**:
```
LogosTest/ → LogosTest/
  ├── LogosTest.lean → LogosTest.lean
  ├── Main.lean (update imports)
  ├── Syntax/ (update namespace declarations)
  ├── ProofSystem/ (update namespace declarations)
  ├── Semantics/ (update namespace declarations)
  ├── Integration/ (update namespace declarations)
  ├── Metalogic/ (update namespace declarations)
  ├── Theorems/ (update namespace declarations)
  └── Automation/ (update namespace declarations)
```

#### LogosTest.lean → LogosTest.lean

**Current Content**:
```lean
import Logos

namespace LogosTest
-- Test infrastructure
end LogosTest
```

**Required Changes**:
```lean
import Logos

namespace LogosTest
-- Test infrastructure
end LogosTest
```

### 1.6 Build Artifacts Directory

**Current**: `.lake/build/lib/Logos/`
**Target**: `.lake/build/lib/Logos/`

**Impact**: Will be regenerated automatically during `lake build`. No manual changes needed, but users should run `lake clean` before rebuild.

## 2. Lean Source Files (33 files)

### 2.1 Namespace Declarations

**Pattern to Change**:
```lean
namespace Logos
  -- or --
namespace Logos.Syntax
  -- or --
namespace Logos.Semantics
  -- etc.
```

**Target Pattern**:
```lean
namespace Logos
  -- or --
namespace Logos.Syntax
  -- or --
namespace Logos.Semantics
  -- etc.
```

**Files Requiring Namespace Changes** (33 files):

#### Main Source Files (15 files)
1. `Logos/Syntax/Formula.lean` → `namespace Logos.Syntax`
2. `Logos/Syntax/Context.lean` → `namespace Logos.Syntax`
3. `Logos/ProofSystem/Axioms.lean` → `namespace Logos.ProofSystem`
4. `Logos/ProofSystem/Derivation.lean` → `namespace Logos.ProofSystem`
5. `Logos/Semantics/TaskFrame.lean` → `namespace Logos.Semantics`
6. `Logos/Semantics/WorldHistory.lean` → `namespace Logos.Semantics`
7. `Logos/Semantics/TaskModel.lean` → `namespace Logos.Semantics`
8. `Logos/Semantics/Truth.lean` → `namespace Logos.Semantics`
9. `Logos/Semantics/Validity.lean` → `namespace Logos.Semantics`
10. `Logos/Metalogic/Soundness.lean` → `namespace Logos.Metalogic`
11. `Logos/Metalogic/Completeness.lean` → `namespace Logos.Metalogic`
12. `Logos/Theorems/Perpetuity.lean` → `namespace Logos.Theorems`
13. `Logos/Automation/Tactics.lean` → `namespace Logos.Automation`
14. `Logos/Automation/ProofSearch.lean` → `namespace Logos.Automation`
15. `Logos.lean` (root) → `namespace Logos`

#### Module Aggregator Files (6 files)
16. `Logos/Syntax.lean` → `namespace Logos.Syntax`
17. `Logos/ProofSystem.lean` → `namespace Logos.ProofSystem`
18. `Logos/Semantics.lean` → `namespace Logos.Semantics`
19. `Logos/Metalogic.lean` → `namespace Logos.Metalogic`
20. `Logos/Theorems.lean` → `namespace Logos.Theorems`
21. `Logos/Automation.lean` → `namespace Logos.Automation`

#### Test Files (10+ files)
22. `LogosTest/Syntax/FormulaTest.lean` → `namespace LogosTest.Syntax.FormulaTest`
23. `LogosTest/Syntax/ContextTest.lean` → `namespace LogosTest.Syntax.ContextTest`
24. `LogosTest/ProofSystem/AxiomsTest.lean` → `namespace LogosTest.ProofSystem.AxiomsTest`
25. `LogosTest/ProofSystem/DerivationTest.lean` → `namespace LogosTest.ProofSystem.DerivationTest`
26. `LogosTest/Semantics/TaskFrameTest.lean` → `namespace LogosTest.Semantics.TaskFrameTest`
27. `LogosTest/Semantics/TruthTest.lean` → `namespace LogosTest.Semantics.TruthTest`
28. `LogosTest/Integration/EndToEndTest.lean` → `namespace LogosTest.Integration.EndToEndTest`
29. `LogosTest/Metalogic/SoundnessTest.lean` → `namespace LogosTest.Metalogic.SoundnessTest`
30. `LogosTest/Metalogic/CompletenessTest.lean` → `namespace LogosTest.Metalogic.CompletenessTest`
31. `LogosTest/Theorems/PerpetuityTest.lean` → `namespace LogosTest.Theorems.PerpetuityTest`
32. `LogosTest/Automation/TacticsTest.lean` → `namespace LogosTest.Automation.TacticsTest`
33. `LogosTest/Automation/TacticsTest_Simple.lean` → `namespace LogosTest.Automation.TacticsTest_Simple`

#### Archive Files (4 files)
34. `Archive/ModalProofs.lean` → `namespace Archive.ModalProofs` (imports change)
35. `Archive/TemporalProofs.lean` → `namespace Archive.TemporalProofs` (imports change)
36. `Archive/BimodalProofs.lean` → `namespace Archive.BimodalProofs` (imports change)
37. `Archive/Archive.lean` → Keep namespace, update imports

### 2.2 Import Statements

**Pattern to Change**:
```lean
import Logos.Syntax.Formula
import Logos.Semantics.TaskFrame
import Logos
```

**Target Pattern**:
```lean
import Logos.Syntax.Formula
import Logos.Semantics.TaskFrame
import Logos
```

**Files with Import Statements** (30+ files):
- All test files import from `Logos.*`
- All archive examples import from `Logos.*`
- Internal modules import from `Logos.*`

**Systematic Search Command**:
```bash
grep -r "import Logos" --include="*.lean" | wc -l
# Expected: 30+ occurrences
```

### 2.3 Example Refactoring: Truth.lean

**Current Content** (abbreviated):
```lean
import Logos.Semantics.TaskModel
import Logos.Semantics.WorldHistory
import Logos.Syntax.Formula

namespace Logos.Semantics

def truth_at (M : TaskModel T) (τ : WorldHistory M.frame) (t : T)
  (h : τ.domain t) : Formula → Prop
  | Formula.atom p => M.valuation p τ t h
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t h φ → truth_at M τ t h ψ
  | Formula.box φ => ∀ (τ' : WorldHistory M.frame) (h' : τ'.domain t),
      truth_at M τ' t h' φ
  | Formula.past φ => ∀ (t' : T) (h' : τ.domain t'), t' < t →
      truth_at M τ t' h' φ
  | Formula.future φ => ∀ (t' : T) (h' : τ.domain t'), t < t' →
      truth_at M τ t' h' φ

end Logos.Semantics
```

**Required Changes**:
```lean
import Logos.Semantics.TaskModel
import Logos.Semantics.WorldHistory
import Logos.Syntax.Formula

namespace Logos.Semantics

def truth_at (M : TaskModel T) (τ : WorldHistory M.frame) (t : T)
  (h : τ.domain t) : Formula → Prop
  | Formula.atom p => M.valuation p τ t h
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t h φ → truth_at M τ t h ψ
  | Formula.box φ => ∀ (τ' : WorldHistory M.frame) (h' : τ'.domain t),
      truth_at M τ' t h' φ
  | Formula.past φ => ∀ (t' : T) (h' : τ.domain t'), t' < t →
      truth_at M τ t' h' φ
  | Formula.future φ => ∀ (t' : T) (h' : τ.domain t'), t < t' →
      truth_at M τ t' h' φ

end Logos.Semantics
```

**Changes**: 4 lines (3 imports + 1 namespace declaration + 1 namespace end)

## 3. Documentation Files (40+ files)

### 3.1 README.md (ROOT)

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/README.md`

**Current Title**: "# Logos: LEAN 4 Proof Assistant for Logos"

**Required Changes**:
1. Update title: "# Logos: Formal Language of Thought with Proof Verification"
2. Update opening paragraph: "Logos is a..." → "Logos is a formal language of thought with..."
3. Update repository structure diagram (Logos/ → Logos/)
4. Update command examples (`lake build Logos` → `lake build Logos`)
5. Update installation instructions (git clone URL, cd command)
6. Update citation BibTeX entry (title, repository name)

**Estimated Changes**: 30+ occurrences of "Logos"

### 3.2 CLAUDE.md

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md`

**Current Title**: "# CLAUDE.md - Logos Project Configuration"

**Required Changes**:
1. Update title and project name
2. Update project overview description
3. Update directory structure diagram
4. Update namespace references
5. Update command examples
6. Update import examples
7. Update file path references

**Estimated Changes**: 50+ occurrences of "Logos"

### 3.3 Documentation/ Directory

#### UserGuide/ Files (5 files)

1. **ARCHITECTURE.md**
   - Update title
   - Update namespace examples
   - Update import examples
   - Update file path references
   - **Estimated Changes**: 20+ occurrences

2. **METHODOLOGY.md**
   - Update project name references
   - Update file path references
   - **Estimated Changes**: 10+ occurrences

3. **TUTORIAL.md**
   - Update project name
   - Update import statements in examples
   - Update command examples
   - **Estimated Changes**: 15+ occurrences

4. **EXAMPLES.md**
   - Update namespace declarations in code examples
   - Update import statements
   - **Estimated Changes**: 20+ occurrences

5. **INTEGRATION.md**
   - Update Logos references
   - Update component names
   - **Estimated Changes**: 15+ occurrences

#### ProjectInfo/ Files (4 files)

1. **IMPLEMENTATION_STATUS.md**
   - Update title ("Logos MVP" → "Logos Core Layer MVP")
   - Update module names
   - Update verification commands
   - **Estimated Changes**: 30+ occurrences

2. **KNOWN_LIMITATIONS.md**
   - Update project name references
   - Update file paths
   - **Estimated Changes**: 10+ occurrences

3. **CONTRIBUTING.md**
   - Update project name
   - Update setup instructions
   - Update repository URL
   - **Estimated Changes**: 10+ occurrences

4. **VERSIONING.md**
   - Update project name
   - **Estimated Changes**: 5+ occurrences

#### Development/ Files (10+ files)

1. **LEAN_STYLE_GUIDE.md**
   - Update namespace examples
   - Update code examples
   - **Estimated Changes**: 10+ occurrences

2. **MODULE_ORGANIZATION.md**
   - Update directory structure
   - Update namespace hierarchy
   - **Estimated Changes**: 20+ occurrences

3. **TESTING_STANDARDS.md**
   - Update test file examples
   - Update namespace references
   - **Estimated Changes**: 15+ occurrences

4. **TACTIC_DEVELOPMENT.md**
   - Update code examples
   - Update import statements
   - **Estimated Changes**: 10+ occurrences

5. **QUALITY_METRICS.md**
   - Update project name
   - **Estimated Changes**: 5+ occurrences

6-10. **Other Development Docs**
   - Similar pattern of updates
   - **Estimated Total**: 50+ occurrences across files

#### Research/ Files (3 files)

1. **LAYER_EXTENSIONS.md**
   - Update references to current implementation
   - Update file path references
   - **Estimated Changes**: 10+ occurrences

2. **DUAL_VERIFICATION.md**
   - Update Logos component names
   - Update architecture diagrams
   - **Estimated Changes**: 20+ occurrences

3. **PROOF_LIBRARY_DESIGN.md**
   - Update project name
   - Update file paths
   - **Estimated Changes**: 10+ occurrences

#### Reference/ Files (2 files)

1. **OPERATORS.md**
   - Minimal changes (mostly operator definitions)
   - **Estimated Changes**: 5+ occurrences

2. **GLOSSARY.md**
   - Update Logos definition entry
   - **Estimated Changes**: 5+ occurrences

### 3.4 Module READMEs

**Files**:
1. `Logos/README.md` → `Logos/README.md`
2. `LogosTest/README.md` → `LogosTest/README.md`
3. `Archive/README.md` (update references)

**Changes per File**: 20+ occurrences of "Logos"

### 3.5 Archive Documentation

**Files**:
1. `Archive/logos-original/README.md`
   - Update integration references
   - **Estimated Changes**: 5+ occurrences

2. `Archive/logos-original/README-ARCHIVE.md`
   - Update integration references
   - **Estimated Changes**: 5+ occurrences

## 4. Configuration and Metadata Files

### 4.1 Git Configuration

#### .gitignore

**Current Content** (relevant excerpt):
```
.lake/
build/
*.olean
```

**No Changes Needed**: Build artifact patterns are namespace-independent.

### 4.2 CI/CD Configuration

#### .github/workflows/ci.yml (if exists)

**Expected Pattern**:
```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Logos
        run: lake build
      - name: Run tests
        run: lake test
```

**Required Changes**:
```yaml
name: CI
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Build Logos
        run: lake build
      - name: Run tests
        run: lake test
```

**Impact**: Job names and descriptions, not commands (lake build is universal).

### 4.3 VS Code Configuration (if exists)

#### .vscode/settings.json

**Potential Content**:
```json
{
  "lean4.serverLogging.enabled": true,
  "lean4.toolchain": "leanprover/lean4:v4.14.0"
}
```

**No Changes Needed**: Settings are project-agnostic.

## 5. Claude Code Framework Files

### 5.1 Specifications Directory

**Location**: `.claude/specs/`

**Relevant Specs**: Any specs referencing Logos structure or files

**Estimated Impact**: 10+ specification documents may reference Logos

**Action**: Update after main refactor, or note in specs that structure has changed.

### 5.2 Test Suite

**Location**: `.claude/tests/`

**Estimated Impact**: Minimal (tests are for Claude Code framework, not Logos)

**Action**: No changes needed unless tests reference Logos structure.

## 6. External References

### 6.1 GitHub Repository

**Current URL** (assumed): `https://github.com/benbrastmckie/Logos`
**Target URL**: `https://github.com/benbrastmckie/Logos`

**Required Actions**:
1. Rename GitHub repository (Settings → Repository name)
2. Update local git remote: `git remote set-url origin https://github.com/benbrastmckie/Logos`
3. Update README.md clone instructions
4. Update documentation references
5. Set up redirect from old URL (GitHub provides automatic redirect)

**Impact**: All git clone instructions, links in papers, and external references

### 6.2 Documentation Cross-References

**Pattern**: Links to files within repository

**Example**:
```markdown
See [Logos/README.md](Logos/README.md) for details.
```

**Target**:
```markdown
See [Logos/README.md](Logos/README.md) for details.
```

**Estimated Occurrences**: 100+ cross-reference links across documentation

### 6.3 Paper Citations

**Current Citation** (from README.md):
```bibtex
@software{proofchecker2025,
  title = {Logos: LEAN 4 Proof System for Bimodal Logic TM},
  author = {Your Name},
  year = {2025},
  url = {https://github.com/yourusername/Logos}
}
```

**Required Citation**:
```bibtex
@software{logos2025,
  title = {Logos: Formal Language of Thought with Proof Verification},
  author = {Benjamin Brast-McKie},
  year = {2025},
  url = {https://github.com/benbrastmckie/Logos}
}
```

**Impact**: Papers citing the project need to use updated citation.

## 7. Change Summary by Category

### 7.1 Critical (Build-Breaking) Changes

**Total Files**: 5
1. lakefile.toml (1 file)
2. Root library files (3 files: Logos.lean, LogosTest.lean, Archive.lean)
3. Directory names (2 directories: Logos/ → Logos/, LogosTest/ → LogosTest/)

**Priority**: HIGHEST - must be done first and correctly

### 7.2 High-Priority (Compilation-Breaking) Changes

**Total Files**: 37
1. Namespace declarations (33 Lean files)
2. Import statements (30+ Lean files, many overlapping with namespace changes)
3. Module aggregator files (6 files)

**Priority**: HIGH - must be done immediately after critical changes

### 7.3 Medium-Priority (Documentation) Changes

**Total Files**: 40+
1. README.md (1 file)
2. CLAUDE.md (1 file)
3. Documentation/ files (35+ files)
4. Module READMEs (3 files)

**Priority**: MEDIUM - should be done in same commit as code changes for consistency

### 7.4 Low-Priority (External) Changes

**Total Items**: Variable
1. GitHub repository rename (1 action)
2. Git remote URL update (1 command per clone)
3. External documentation/papers (unknown quantity)

**Priority**: LOW - can be done after main refactor, with transition period

## 8. Refactoring Strategy

### 8.1 Phase 1: Critical Infrastructure (Day 1)

**Steps**:
1. Create new git branch: `git checkout -b refactor/logos-rename`
2. Rename directories:
   - `mv Logos Logos`
   - `mv LogosTest LogosTest`
3. Update lakefile.toml
4. Rename root files:
   - `mv Logos.lean Logos.lean`
   - `mv LogosTest.lean LogosTest.lean`
5. Run `lake clean`
6. Test: `lake build` (expect many errors at this point)

### 8.2 Phase 2: Namespace Updates (Day 1-2)

**Steps**:
1. Update all namespace declarations in Logos/ (15 files)
2. Update all namespace declarations in LogosTest/ (10+ files)
3. Update all namespace declarations in Archive/ (4 files)
4. Update all import statements (automated with sed/find-replace)
5. Test: `lake build` (should succeed)
6. Test: `lake test` (should succeed)

**Automated Script** (for import statements):
```bash
find . -name "*.lean" -type f -exec sed -i 's/import Logos/import Logos/g' {} +
find . -name "*.lean" -type f -exec sed -i 's/namespace Logos/namespace Logos/g' {} +
find . -name "*.lean" -type f -exec sed -i 's/LogosTest/LogosTest/g' {} +
```

**Warning**: Review changes carefully, don't blindly apply to all files.

### 8.3 Phase 3: Documentation Updates (Day 2-3)

**Steps**:
1. Update README.md
2. Update CLAUDE.md
3. Update Documentation/UserGuide/ files (5 files)
4. Update Documentation/ProjectInfo/ files (4 files)
5. Update Documentation/Development/ files (10+ files)
6. Update Documentation/Research/ files (3 files)
7. Update Documentation/Reference/ files (2 files)
8. Update module READMEs (3 files)

**Automated Search-Replace** (use carefully):
```bash
find Documentation -name "*.md" -type f -exec sed -i 's/Logos/Logos/g' {} +
# Then manually review for false positives
```

### 8.4 Phase 4: Verification (Day 3)

**Steps**:
1. Full build: `lake clean && lake build`
2. Run tests: `lake test`
3. Build documentation: `lake build :docs`
4. Check all README files render correctly
5. Verify all cross-references work
6. Check for remaining "Logos" references: `grep -r "Logos" --include="*.md" --include="*.lean"`

### 8.5 Phase 5: External Updates (Day 4+)

**Steps**:
1. Commit changes: `git add -A && git commit -m "Refactor: Rename Logos to Logos"`
2. Push to remote: `git push origin refactor/logos-rename`
3. Create pull request and review
4. Merge to main
5. Rename GitHub repository
6. Update git remotes: `git remote set-url origin https://github.com/benbrastmckie/Logos`
7. Update any external documentation or links

## 9. Automated Change Scripts

### 9.1 Namespace Update Script

```bash
#!/bin/bash
# rename-namespaces.sh

echo "Updating namespace declarations..."

# Main source files
find Logos -name "*.lean" -type f -exec sed -i 's/^namespace Logos/namespace Logos/g' {} +
find Logos -name "*.lean" -type f -exec sed -i 's/^end Logos/end Logos/g' {} +

# Test files
find LogosTest -name "*.lean" -type f -exec sed -i 's/^namespace LogosTest/namespace LogosTest/g' {} +
find LogosTest -name "*.lean" -type f -exec sed -i 's/^end LogosTest/end LogosTest/g' {} +

echo "Namespace declarations updated."
```

### 9.2 Import Update Script

```bash
#!/bin/bash
# rename-imports.sh

echo "Updating import statements..."

# Update Logos imports to Logos
find . -name "*.lean" -type f -exec sed -i 's/import Logos\./import Logos./g' {} +
find . -name "*.lean" -type f -exec sed -i 's/import Logos$/import Logos/g' {} +

# Update LogosTest imports to LogosTest
find . -name "*.lean" -type f -exec sed -i 's/import LogosTest\./import LogosTest./g' {} +
find . -name "*.lean" -type f -exec sed -i 's/import LogosTest$/import LogosTest/g' {} +

echo "Import statements updated."
```

### 9.3 Documentation Update Script

```bash
#!/bin/bash
# rename-docs.sh

echo "Updating documentation references..."

# Update markdown files in Documentation/
find Documentation -name "*.md" -type f -exec sed -i 's/Logos/Logos/g' {} +

# Update README files
sed -i 's/Logos/Logos/g' README.md
sed -i 's/Logos/Logos/g' CLAUDE.md
find . -maxdepth 2 -name "README.md" -type f -exec sed -i 's/Logos/Logos/g' {} +

# Update file path references
find Documentation -name "*.md" -type f -exec sed -i 's|Logos/|Logos/|g' {} +
find Documentation -name "*.md" -type f -exec sed -i 's|LogosTest/|LogosTest/|g' {} +

echo "Documentation updated."
```

### 9.4 Verification Script

```bash
#!/bin/bash
# verify-rename.sh

echo "Verifying rename completeness..."

# Check for remaining Logos references in Lean files
echo "Checking Lean source files..."
grep -r "Logos" --include="*.lean" Logos/ LogosTest/ Archive/ && echo "WARNING: Found Logos references in Lean files" || echo "✓ No Logos in Lean files"

# Check for remaining Logos references in documentation
echo "Checking documentation files..."
grep -r "Logos" --include="*.md" Documentation/ README.md CLAUDE.md && echo "WARNING: Found Logos references in documentation" || echo "✓ No Logos in documentation"

# Check build succeeds
echo "Testing build..."
lake clean && lake build && echo "✓ Build successful" || echo "ERROR: Build failed"

# Check tests pass
echo "Testing test suite..."
lake test && echo "✓ Tests passed" || echo "ERROR: Tests failed"

echo "Verification complete."
```

## 10. Risk Mitigation

### 10.1 Pre-Refactoring Checklist

- [ ] Create full backup: `tar -czf proofchecker-backup-$(date +%Y%m%d).tar.gz Logos/`
- [ ] Commit all current work: `git add -A && git commit -m "Pre-refactor checkpoint"`
- [ ] Create refactor branch: `git checkout -b refactor/logos-rename`
- [ ] Document current git status: `git status > pre-refactor-status.txt`
- [ ] Verify tests pass: `lake test` (baseline)
- [ ] Create rollback plan document

### 10.2 Post-Change Verification

- [ ] Build succeeds: `lake clean && lake build`
- [ ] Tests pass: `lake test`
- [ ] Documentation builds: `lake build :docs`
- [ ] No Logos references in code: `grep -r "Logos" --include="*.lean"`
- [ ] No Logos references in docs: `grep -r "Logos" --include="*.md"`
- [ ] All README files render correctly
- [ ] Git history preserved: `git log` shows complete history

### 10.3 Rollback Plan

**If refactor fails**:
1. Abort current changes: `git reset --hard HEAD`
2. Return to main branch: `git checkout main`
3. Delete refactor branch: `git branch -D refactor/logos-rename`
4. Restore from backup: `tar -xzf proofchecker-backup-YYYYMMDD.tar.gz`

**If refactor succeeds but issues found later**:
1. Keep refactor branch for reference
2. Create fix branch: `git checkout -b fix/post-refactor-issues`
3. Address specific issues incrementally
4. Merge fixes: `git merge fix/post-refactor-issues`

## 11. Timeline Estimate

### Conservative Estimate

**Day 1** (4-6 hours):
- Phase 1: Critical infrastructure (1 hour)
- Phase 2: Namespace updates (3-5 hours)

**Day 2** (4-6 hours):
- Phase 3: Documentation updates (4-6 hours)

**Day 3** (2-4 hours):
- Phase 4: Verification (1-2 hours)
- Phase 5: External updates (1-2 hours)

**Total**: 10-16 hours over 3 days

### Optimistic Estimate (with automation)

**Day 1** (2-4 hours):
- Phases 1-2 combined with scripts

**Day 2** (2-3 hours):
- Phase 3 with automation

**Day 3** (1-2 hours):
- Phases 4-5

**Total**: 5-9 hours over 3 days

## 12. Success Criteria

### Must-Have (Blocking)
- [ ] `lake build` succeeds with zero errors
- [ ] `lake test` passes all tests
- [ ] No "Logos" namespace references in Lean code
- [ ] lakefile.toml correctly configured
- [ ] All imports resolve correctly

### Should-Have (Important)
- [ ] README.md fully updated
- [ ] CLAUDE.md fully updated
- [ ] Core documentation files updated (UserGuide/, ProjectInfo/)
- [ ] No "Logos" references in documentation
- [ ] Module READMEs updated

### Nice-to-Have (Optional)
- [ ] GitHub repository renamed
- [ ] All development documentation updated
- [ ] All cross-references verified
- [ ] External links updated

---

**Report Completion**: 2025-12-04
**Next Report**: 004-lean-layered-architecture-patterns.md
**Estimated Change Volume**: 100+ files, 500+ individual changes
**Recommended Timeline**: 3 days for thorough refactoring with verification
