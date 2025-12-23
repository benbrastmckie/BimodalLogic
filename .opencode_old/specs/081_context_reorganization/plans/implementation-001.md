# Implementation Plan: Context Directory Reorganization

**Project**: #081
**Version**: 001
**Date**: 2025-12-20
**Complexity**: MODERATE
**Estimated Effort**: 3.5 hours

## Task Description

Reorganize `.opencode/context/` directory to eliminate redundancy and improve organization:

**Required Moves/Integrations:**

1. **Move to `logic/domain/`** (consolidate logic domain knowledge):
   - `logic/metalogic/soundness-completeness.md` → `logic/domain/`
   - `logic/proof-theory/proof-theory-concepts.md` → `logic/domain/`
   - `logic/semantics/task-semantics.md` → `logic/domain/`
   - **Action**: Replace or integrate with existing files in `logic/domain/` to avoid redundancy

2. **Move to `lean4/domain/`** (type theory belongs with LEAN 4):
   - `logic/type-theory/dependent-types.md` → `lean4/domain/`

3. **Integrate into `core/`** (project-level context):
   - `project/project-context.md` → `core/system/`
   - `repo/project-structure.md` → `core/system/`
   - **Action**: Integrate into existing core/ structure

**Goals:**
- Clean, consistent, complete, well-structured `.opencode/context/` directory
- Eliminate redundancy and duplication
- Clear separation: `logic/domain/` (logic concepts), `lean4/domain/` (LEAN 4 concepts), `core/` (project context)
- Maintain all unique information
- Update all references to moved files

---

## Complexity Assessment

**Level**: MODERATE

**Estimated Effort**: 3.5 hours
- File moves: 0.5 hours
- Integration: 1.5 hours
- Reference updates: 1.0 hours
- Validation: 0.5 hours

**Challenges**:
1. Semantic mismatch: `task-semantics.md` (418 lines, task-based) vs `semantics-concepts.md` (58 lines, Kripke-based) - fundamentally different semantic frameworks
2. Detail level disparity: `soundness-completeness.md` (314 lines, comprehensive) vs `metalogic-concepts.md` (85 lines, brief overview)
3. Content overlap with different focus: `proof-theory-concepts.md` files (281 vs 47 lines)
4. Risk of breaking agent context loading if references aren't updated properly
5. Need to preserve unique information from both detailed and brief versions

**Risk Assessment**: MEDIUM
- Agent context loading may break if file paths change without updating references
- Loss of brief overview utility - agents may prefer concise summaries over 300+ line files
- Semantic confusion if both Kripke and task semantics files aren't clearly distinguished
- Project context files (215 + 139 lines) may duplicate information already in `core/`
- Type theory file (369 lines) is general LEAN 4 content, not Logos-specific

---

## Dependencies

### Required Imports
None (documentation reorganization only)

### Prerequisites
1. Backup of `.opencode/context/` directory
2. Understanding of file content and overlap
3. List of all references to files being moved

### Files to Update (40 total references)

**Index and README files** (18 references):
- `.opencode/context/logic/README.md` (12 references, includes duplicates)
- `.opencode/context/README.md` (6 references)
- `.opencode/README.md` (1 reference)
- `.opencode/ARCHITECTURE.md` (1 reference)

**Command files** (4 references):
- `.opencode/command/lean.md` (1 reference)
- `.opencode/command/todo.md` (1 reference)
- `.opencode/command/add.md` (1 reference)
- `.opencode/command/task.md` (1 reference)

**Documentation files** (1 reference):
- `.opencode/context/repo/documentation-standards.md` (1 reference)

**Specs files** (16 references):
- `.opencode/specs/066_opencode_readme_documentation/plans/implementation-001.md` (4 references)
- `.opencode/specs/066_opencode_readme_documentation/reports/research-001.md` (7 references)
- `.opencode/specs/080_documentation_review/analysis/inventory.md` (5 references)
- `.opencode/specs/README.md` (1 reference)

### Critical Dependencies

1. **CRITICAL**: `.opencode/context/logic/README.md` contains DUPLICATE entries for `proof-theory-concepts.md` (lines 30, 48, 71, 72, 105) - one in `domain/`, one in `proof-theory/`. After move, only `domain/` entry should remain.

2. **CRITICAL**: `.opencode/command/add.md` line 15 uses incorrect path missing `.opencode/` prefix

3. **CRITICAL**: Multiple command files use old absolute path format with `/home/benjamin/Documents/Philosophy/Projects/` instead of `/home/benjamin/Projects/`

4. **IMPORTANT**: `dependent-types.md` is moving from `logic/type-theory/` to `lean4/domain/` - cross-domain move requires careful path updates

5. **IMPORTANT**: `project-context.md` and `project-structure.md` are moving from separate directories (`project/`, `repo/`) to unified `core/system/` directory

### Path Inconsistencies to Fix

1. `.opencode/command/todo.md` - Uses `/home/benjamin/Documents/Philosophy/Projects/ProofChecker`
2. `.opencode/command/add.md` - Missing `.opencode/` in path
3. `.opencode/command/task.md` - Uses old path format
4. `.opencode/command/plan.md` - Uses old path format
5. `.opencode/command/revise.md` - Uses old path format
6. `.opencode/command/research.md` - Uses old path format

---

## Implementation Steps

### Phase 1: Preparation and Backup (15 minutes)

**Step 1.1: Create Backup**

**Action**: Create complete backup of `.opencode/context/` directory
**File**: N/A
**Commands**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode
cp -r context context.backup-20251220
```
**Verification**: Verify backup exists and is complete
```bash
diff -r context context.backup-20251220
```

**Step 1.2: Document Current State**

**Action**: List all files being moved and their sizes
**File**: `.opencode/specs/081_context_reorganization/analysis/file-inventory.md`
**Content**:
```markdown
# File Inventory - Context Reorganization

## Files to Move

### Logic Domain Files
- `logic/metalogic/soundness-completeness.md` (314 lines)
- `logic/proof-theory/proof-theory-concepts.md` (281 lines)
- `logic/semantics/task-semantics.md` (418 lines)

### Type Theory File
- `logic/type-theory/dependent-types.md` (369 lines)

### Project Context Files
- `project/project-context.md` (215 lines)
- `repo/project-structure.md` (139 lines)

## Existing Target Files

### Logic Domain
- `logic/domain/metalogic-concepts.md` (85 lines) - TO BE REPLACED
- `logic/domain/proof-theory-concepts.md` (47 lines) - TO BE REPLACED
- `logic/domain/semantics-concepts.md` (58 lines) - TO BE RENAMED

### Core System
- `core/system/context-guide.md` (existing)
```

---

### Phase 2: Logic Domain Integration (45 minutes)

**Step 2.1: Replace Metalogic File**

**Action**: Replace brief `metalogic-concepts.md` with comprehensive `soundness-completeness.md`
**File**: `logic/domain/metalogic-concepts.md`
**Rationale**: The 314-line version is a complete superset of the 85-line brief version

**Commands**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Replace brief with detailed
mv logic/metalogic/soundness-completeness.md \
   logic/domain/metalogic-concepts.md
```

**Verification**: Check file exists and has correct content
```bash
wc -l logic/domain/metalogic-concepts.md  # Should be 314 lines
head -n 5 logic/domain/metalogic-concepts.md  # Check header
```

**Step 2.2: Replace Proof Theory File**

**Action**: Replace brief `proof-theory-concepts.md` with comprehensive version
**File**: `logic/domain/proof-theory-concepts.md`
**Rationale**: The 281-line version covers everything in the brief version plus extensive additional content

**Commands**:
```bash
# Replace brief with detailed
mv logic/proof-theory/proof-theory-concepts.md \
   logic/domain/proof-theory-concepts.md
```

**Verification**: Check file exists and has correct content
```bash
wc -l logic/domain/proof-theory-concepts.md  # Should be 281 lines
head -n 5 logic/domain/proof-theory-concepts.md  # Check header
```

**Step 2.3: Reorganize Semantics Files**

**Action**: Move task semantics and rename Kripke semantics for clarity
**Files**: 
- `logic/domain/task-semantics.md` (new)
- `logic/domain/kripke-semantics-overview.md` (renamed)

**Rationale**: These describe fundamentally different semantic frameworks and should both be kept

**Commands**:
```bash
# Move task semantics to domain
mv logic/semantics/task-semantics.md \
   logic/domain/task-semantics.md

# Rename Kripke semantics for clarity
mv logic/domain/semantics-concepts.md \
   logic/domain/kripke-semantics-overview.md
```

**Verification**: Check both files exist
```bash
ls -lh logic/domain/task-semantics.md
ls -lh logic/domain/kripke-semantics-overview.md
```

**Step 2.4: Add Cross-References**

**Action**: Add cross-reference note to `kripke-semantics-overview.md`
**File**: `logic/domain/kripke-semantics-overview.md`

**Edit**: Add at top of file (after title):
```markdown
# Kripke Semantics Overview

> **Note**: This file describes standard Kripke semantics for modal logic. For the actual
> Logos implementation using task-based semantics, see [task-semantics.md](task-semantics.md).

## Overview
...
```

**Edit**: Add to `task-semantics.md` (after overview):
```markdown
## Overview

Logos implements **task-based semantics** for bimodal temporal logic TM, not standard Kripke 
semantics. For a comparison with standard Kripke semantics, see 
[kripke-semantics-overview.md](kripke-semantics-overview.md).

**Key Distinction**: Unlike Kripke semantics which uses accessibility relations between worlds...
```

---

### Phase 3: Type Theory Migration (15 minutes)

**Step 3.1: Move Type Theory File**

**Action**: Move `dependent-types.md` from `logic/type-theory/` to `lean4/domain/`
**File**: `lean4/domain/dependent-types.md`
**Rationale**: General LEAN 4 type theory content belongs with other LEAN 4 language documentation

**Commands**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Move to lean4/domain
mv logic/type-theory/dependent-types.md \
   lean4/domain/dependent-types.md
```

**Verification**: Check file exists in new location
```bash
ls -lh lean4/domain/dependent-types.md
wc -l lean4/domain/dependent-types.md  # Should be 369 lines
```

---

### Phase 4: Project Context Integration (20 minutes)

**Step 4.1: Move Project Context**

**Action**: Move `project-context.md` to `core/system/project-overview.md`
**File**: `core/system/project-overview.md`
**Rationale**: Project overview belongs in core system documentation

**Commands**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Move to core/system with new name
mv project/project-context.md \
   core/system/project-overview.md
```

**Verification**: Check file exists
```bash
ls -lh core/system/project-overview.md
wc -l core/system/project-overview.md  # Should be 215 lines
```

**Step 4.2: Move Project Structure**

**Action**: Move `project-structure.md` to `core/system/artifact-management.md`
**File**: `core/system/artifact-management.md`
**Rationale**: AI system artifact management belongs in core system documentation

**Commands**:
```bash
# Move to core/system with new name
mv repo/project-structure.md \
   core/system/artifact-management.md
```

**Verification**: Check file exists
```bash
ls -lh core/system/artifact-management.md
wc -l core/system/artifact-management.md  # Should be 139 lines
```

---

### Phase 5: Reference Updates (60 minutes)

**Step 5.1: Update logic/README.md**

**Action**: Update all references and remove duplicates
**File**: `.opencode/context/logic/README.md`

**Updates Required** (12 references):
1. Line 30: Update `proof-theory/proof-theory-concepts.md` → `domain/proof-theory-concepts.md`
2. Line 48: Remove duplicate entry for `proof-theory-concepts.md`
3. Line 71: Update quick reference table entry
4. Line 72: Remove duplicate quick reference entry
5. Line 105: Update usage pattern example
6. Line 40: Update `metalogic/soundness-completeness.md` → `domain/metalogic-concepts.md`
7. Line 75: Update quick reference table
8. Line 107: Update usage pattern example
9. Line 64: Update `type-theory/dependent-types.md` → `../lean4/domain/dependent-types.md`
10. Line 77-78: Update quick reference table entries
11. Line 111: Update usage pattern example
12. Add entries for `task-semantics.md` and `kripke-semantics-overview.md`

**Verification**: Check all links work
```bash
# Test markdown links (manual verification)
grep -n "\.md" .opencode/context/logic/README.md
```

**Step 5.2: Update context/README.md**

**Action**: Update main context README
**File**: `.opencode/context/README.md`

**Updates Required** (6 references):
1. Line 54: Update `proof-theory-concepts.md` → `domain/proof-theory-concepts.md`
2. Line 57: Remove duplicate `proof-theory/` entry
3. Line 55: Update `soundness-completeness.md` → `domain/metalogic-concepts.md`
4. Line 60: Update `type-theory/dependent-types.md` → `../lean4/domain/dependent-types.md`
5. Line 120: Update `project/project-context.md` → `core/system/project-overview.md`
6. Line 83: Update `repo/project-structure.md` → `core/system/artifact-management.md`

**Step 5.3: Update .opencode/README.md**

**Action**: Update main .opencode README
**File**: `.opencode/README.md`

**Updates Required** (1 reference):
1. Line 230: Update `repo/project-structure.md` → `core/system/artifact-management.md`

**Step 5.4: Update .opencode/ARCHITECTURE.md**

**Action**: Update architecture documentation
**File**: `.opencode/ARCHITECTURE.md`

**Updates Required** (1 reference):
1. Line 151: Update `repo/project-structure.md` → `core/system/artifact-management.md`

**Step 5.5: Fix Command File Path Inconsistencies**

**Action**: Fix incorrect and outdated paths in command files
**Files**: 
- `.opencode/command/lean.md`
- `.opencode/command/todo.md`
- `.opencode/command/add.md`
- `.opencode/command/task.md`

**Updates for lean.md** (1 reference):
- Line 27: Update `@.../repo/project-structure.md` → `@.../core/system/artifact-management.md`

**Updates for todo.md** (1 reference):
- Line 14: Fix path `/home/benjamin/Documents/Philosophy/Projects/` → `/home/benjamin/Projects/`
- Line 14: Update `project/project-context.md` → `core/system/project-overview.md`

**Updates for add.md** (1 reference):
- Line 15: Fix path (add `.opencode/`)
- Line 15: Update `project/project-context.md` → `core/system/project-overview.md`

**Updates for task.md** (1 reference):
- Line 27: Fix path `/home/benjamin/Documents/Philosophy/Projects/` → `/home/benjamin/Projects/`
- Line 27: Update `project/project-context.md` → `core/system/project-overview.md`

**Step 5.6: Update Documentation Standards**

**Action**: Update cross-reference in documentation standards
**File**: `.opencode/context/repo/documentation-standards.md`

**Updates Required** (1 reference):
1. Line 229: Update `project-structure.md` → `../core/system/artifact-management.md`

**Step 5.7: Update Specs Documentation**

**Action**: Update references in specs files
**Files**:
- `.opencode/specs/066_opencode_readme_documentation/plans/implementation-001.md` (4 refs)
- `.opencode/specs/066_opencode_readme_documentation/reports/research-001.md` (7 refs)
- `.opencode/specs/080_documentation_review/analysis/inventory.md` (5 refs)
- `.opencode/specs/README.md` (1 ref)

**Updates for 066/plans/implementation-001.md**:
1. Line 408: Update `../context/repo/project-structure.md` → `../context/core/system/artifact-management.md`
2. Line 703: Update `proof-theory-concepts.md` → `domain/proof-theory-concepts.md`
3. Line 705: Update `soundness-completeness.md` → `domain/metalogic-concepts.md`
4. Line 706: Update `dependent-types.md` → `../lean4/domain/dependent-types.md`

**Updates for 066/reports/research-001.md**:
1. Line 45: Update `repo/project-structure.md` → `core/system/artifact-management.md`
2. Lines 145, 150: Update `proof-theory-concepts.md` references
3. Line 148: Update `soundness-completeness.md` → `domain/metalogic-concepts.md`
4. Line 154: Update `dependent-types.md` → `../lean4/domain/dependent-types.md`
5. Line 753: Update `metalogic/soundness-completeness.md` → `domain/metalogic-concepts.md`

**Updates for 080/analysis/inventory.md**:
1. Line 169: Update `context/logic/metalogic/soundness-completeness.md` → `context/logic/domain/metalogic-concepts.md`
2. Line 170: Update `context/logic/proof-theory/proof-theory-concepts.md` → `context/logic/domain/proof-theory-concepts.md`
3. Line 172: Update `context/logic/type-theory/dependent-types.md` → `context/lean4/domain/dependent-types.md`
4. Line 154: Update `context/repo/project-structure.md` → `context/core/system/artifact-management.md`
5. Line 204: Update `context/project/project-context.md` → `context/core/system/project-overview.md`

**Updates for specs/README.md**:
1. Line 208: Update `../context/repo/project-structure.md` → `../context/core/system/artifact-management.md`

---

### Phase 6: Cleanup Empty Directories (10 minutes)

**Step 6.1: Remove Empty Directories**

**Action**: Remove now-empty source directories
**Directories**:
- `logic/metalogic/`
- `logic/proof-theory/`
- `logic/semantics/`
- `logic/type-theory/`
- `project/`
- `repo/` (if empty after moving files)

**Commands**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Check if directories are empty
ls -la logic/metalogic/
ls -la logic/proof-theory/
ls -la logic/semantics/
ls -la logic/type-theory/
ls -la project/
ls -la repo/

# Remove empty directories
rmdir logic/metalogic/
rmdir logic/proof-theory/
rmdir logic/semantics/
rmdir logic/type-theory/
rmdir project/

# Only remove repo/ if it's empty (may have other files)
# Check first: ls -la repo/
# If empty: rmdir repo/
```

**Verification**: Verify directories are removed
```bash
ls -la logic/
ls -la .
```

---

### Phase 7: Validation and Testing (30 minutes)

**Step 7.1: Verify File Integrity**

**Action**: Check all moved files exist and are complete
**Commands**:
```bash
cd /home/benjamin/Projects/ProofChecker/.opencode/context

# Check all target files exist
ls -lh logic/domain/metalogic-concepts.md
ls -lh logic/domain/proof-theory-concepts.md
ls -lh logic/domain/task-semantics.md
ls -lh logic/domain/kripke-semantics-overview.md
ls -lh lean4/domain/dependent-types.md
ls -lh core/system/project-overview.md
ls -lh core/system/artifact-management.md

# Verify line counts
wc -l logic/domain/metalogic-concepts.md  # Should be ~314
wc -l logic/domain/proof-theory-concepts.md  # Should be ~281
wc -l logic/domain/task-semantics.md  # Should be ~418
wc -l lean4/domain/dependent-types.md  # Should be ~369
wc -l core/system/project-overview.md  # Should be ~215
wc -l core/system/artifact-management.md  # Should be ~139
```

**Step 7.2: Verify No Broken Links**

**Action**: Check all markdown links resolve correctly
**Commands**:
```bash
# Search for broken links (manual verification)
grep -r "\.md" .opencode/context/README.md
grep -r "\.md" .opencode/context/logic/README.md
grep -r "\.md" .opencode/README.md

# Check for old paths that should have been updated
grep -r "metalogic/soundness-completeness" .opencode/
grep -r "proof-theory/proof-theory-concepts" .opencode/
grep -r "semantics/task-semantics" .opencode/
grep -r "type-theory/dependent-types" .opencode/
grep -r "project/project-context" .opencode/
grep -r "repo/project-structure" .opencode/
```

**Expected**: No matches for old paths (all should be updated)

**Step 7.3: Test Agent Context Loading**

**Action**: Verify agents can load context files without errors
**Commands**:
```bash
# Test loading context files (if agent testing available)
# This would require running actual agent commands

# Manual verification: Check that context files are accessible
cat .opencode/context/logic/domain/metalogic-concepts.md | head -n 20
cat .opencode/context/logic/domain/task-semantics.md | head -n 20
cat .opencode/context/lean4/domain/dependent-types.md | head -n 20
cat .opencode/context/core/system/project-overview.md | head -n 20
```

**Step 7.4: Verify Content Quality**

**Action**: Check that no information was lost and files are properly organized
**Checklist**:
- [ ] All unique information preserved
- [ ] Clear distinction between Kripke and task semantics
- [ ] Cross-references added between related files
- [ ] No duplicate information
- [ ] File organization is logical and consistent

**Step 7.5: Update Index Files**

**Action**: Ensure all index files reflect new structure
**Files**:
- `.opencode/context/index.md`
- `.opencode/context/logic/README.md`
- `.opencode/context/lean4/README.md`
- `.opencode/context/core/README.md` (if exists)

**Verification**: Check index files list correct paths

---

## File Structure

### Before Reorganization
```
.opencode/context/
├── logic/
│   ├── domain/
│   │   ├── metalogic-concepts.md (85 lines - brief)
│   │   ├── proof-theory-concepts.md (47 lines - brief)
│   │   └── semantics-concepts.md (58 lines - Kripke)
│   ├── metalogic/
│   │   └── soundness-completeness.md (314 lines - detailed)
│   ├── proof-theory/
│   │   └── proof-theory-concepts.md (281 lines - detailed)
│   ├── semantics/
│   │   └── task-semantics.md (418 lines - task-based)
│   └── type-theory/
│       └── dependent-types.md (369 lines)
├── project/
│   └── project-context.md (215 lines)
└── repo/
    └── project-structure.md (139 lines)
```

### After Reorganization
```
.opencode/context/
├── logic/
│   └── domain/
│       ├── metalogic-concepts.md (314 lines - comprehensive)
│       ├── proof-theory-concepts.md (281 lines - comprehensive)
│       ├── task-semantics.md (418 lines - Logos implementation)
│       └── kripke-semantics-overview.md (58 lines - standard Kripke)
├── lean4/
│   └── domain/
│       ├── dependent-types.md (369 lines)
│       ├── key-mathematical-concepts.md (existing)
│       ├── lean4-syntax.md (existing)
│       └── mathlib-overview.md (existing)
└── core/
    └── system/
        ├── project-overview.md (215 lines)
        ├── artifact-management.md (139 lines)
        └── context-guide.md (existing)
```

---

## Verification Checkpoints

### After Phase 2 (Logic Domain Integration)
- [ ] `logic/domain/metalogic-concepts.md` exists (314 lines)
- [ ] `logic/domain/proof-theory-concepts.md` exists (281 lines)
- [ ] `logic/domain/task-semantics.md` exists (418 lines)
- [ ] `logic/domain/kripke-semantics-overview.md` exists (58 lines)
- [ ] Cross-references added between semantics files
- [ ] Old directories `logic/metalogic/`, `logic/proof-theory/`, `logic/semantics/` are empty

### After Phase 3 (Type Theory Migration)
- [ ] `lean4/domain/dependent-types.md` exists (369 lines)
- [ ] Old directory `logic/type-theory/` is empty

### After Phase 4 (Project Context Integration)
- [ ] `core/system/project-overview.md` exists (215 lines)
- [ ] `core/system/artifact-management.md` exists (139 lines)
- [ ] Old directories `project/`, `repo/` are empty (or `repo/` has only other files)

### After Phase 5 (Reference Updates)
- [ ] All 40 references updated
- [ ] No broken markdown links
- [ ] Path inconsistencies fixed in command files
- [ ] Duplicate entries removed from `logic/README.md`

### After Phase 6 (Cleanup)
- [ ] Empty directories removed
- [ ] Directory structure is clean

### After Phase 7 (Validation)
- [ ] All files exist and are complete
- [ ] No broken links found
- [ ] Agent context loading works (if testable)
- [ ] Content quality verified
- [ ] Index files updated

---

## Success Criteria

1. **File Organization**:
   - All logic domain files consolidated in `logic/domain/`
   - Type theory file moved to `lean4/domain/`
   - Project context files in `core/system/`
   - No empty directories remaining

2. **Content Quality**:
   - No information lost during moves
   - Clear distinction between Kripke and task semantics
   - Cross-references added where appropriate
   - No duplicate information

3. **Reference Integrity**:
   - All 40 references updated correctly
   - No broken markdown links
   - Path inconsistencies fixed
   - Index files reflect new structure

4. **Agent Functionality**:
   - Agents can load context files without errors
   - No path errors in agent logs
   - Context loading performance acceptable

5. **Documentation Standards**:
   - All files follow documentation standards
   - Consistent formatting and structure
   - Clear and concise content

---

## Related Research

- Complexity analysis by complexity-analyzer specialist
- Dependency mapping by dependency-mapper specialist
- Documentation standards: `.opencode/context/repo/documentation-standards.md`
- Directory README standard: `Documentation/Development/DIRECTORY_README_STANDARD.md`

---

## Notes

### Integration Strategy Rationale

**Metalogic and Proof Theory**: REPLACE brief with detailed
- The comprehensive versions (314 and 281 lines) are complete supersets
- Brief versions add no unique value
- Agents benefit from complete LEAN 4 proof structures

**Semantics**: KEEP BOTH
- `task-semantics.md` describes actual Logos implementation (task frames, world histories)
- `kripke-semantics-overview.md` describes standard Kripke semantics
- These are complementary, not redundant
- Renamed for clarity to avoid confusion

**Type Theory**: MOVE to lean4/domain/
- General LEAN 4 content, not Logos-specific
- Belongs with other LEAN 4 language documentation

**Project Context**: MOVE to core/system/
- Project overview and artifact management are core system concerns
- Renamed for clarity (`project-overview.md`, `artifact-management.md`)

### Risk Mitigation

**High Risk**: Breaking agent context loading
- **Mitigation**: Systematic reference updates with verification
- **Mitigation**: Test agent loading after each phase (if possible)

**Medium Risk**: Broken markdown links
- **Mitigation**: Comprehensive reference update checklist
- **Mitigation**: Automated link checking

**Low Risk**: File corruption during move
- **Mitigation**: Use `mv` (atomic operation)
- **Mitigation**: Create backup before starting

### Alternative Approach Considered

**Hybrid Strategy**: Keep brief files as "quick reference"
- `metalogic-quick-ref.md` (85 lines)
- `proof-theory-quick-ref.md` (47 lines)

**Decision**: Not implemented
- Adds file count without clear benefit
- Agents can read first sections of detailed files for quick reference
- Can be added later if needed

### Path Standardization

Multiple command files use inconsistent paths:
- Old: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker`
- New: `/home/benjamin/Projects/ProofChecker`

This reorganization includes fixing these inconsistencies.
