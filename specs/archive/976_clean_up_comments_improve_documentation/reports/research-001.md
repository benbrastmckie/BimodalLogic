# Research Report: Task #976

**Task**: 976 - Clean up comments and improve documentation
**Started**: 2026-03-16T10:00:00Z
**Completed**: 2026-03-16T10:45:00Z
**Effort**: Medium (documentation task spanning multiple directories)
**Dependencies**: None
**Sources/Inputs**: Codebase exploration, existing README files, Lean source files
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The codebase has **51 existing README.md files** in the project (excluding .lake, .opencode, .claude)
- **41 directories are missing README.md files** across Theories, Tests, and Boneyard
- Lean source files have **excellent documentation quality** with comprehensive module headers and docstrings
- ROAD_MAP.md is extensive (~1400 lines) but needs updating to reflect current state
- Comment cleanup needed: 2 TODO comments, 7+ DEPRECATED markers to clean up or archive

## Context & Scope

This research inventories the documentation state of the ProofChecker codebase to support task 976, which aims to:
1. Clean up comments throughout the codebase
2. Ensure every subdirectory has an accurate and complete README.md
3. Update ROAD_MAP.md to represent the present state

### Scope Boundaries

- **In scope**: Theories/, Tests/, Boneyard/, docs/, specs/, scripts/, benchmarks/, build/
- **Out of scope**: .claude/, .opencode/, .lake/ (configuration/build directories)

## Findings

### 1. Directory Structure Overview

The project contains approximately **145 directories** (excluding .lake, .git, .opencode, .claude). Key areas:

| Area | Directories | README Coverage |
|------|-------------|-----------------|
| Theories/Bimodal | ~40 subdirs | Partial (20+ missing) |
| Tests | ~8 subdirs | Partial (5 missing) |
| Boneyard | ~35 subdirs | Partial (15+ missing) |
| docs/ | 7 subdirs | Complete |
| Top-level (scripts, specs, benchmarks, build) | 4 | None (all missing) |

### 2. README.md Inventory

#### Directories WITH README.md (51 total)

**Theories hierarchy (well-documented):**
- `/Theories/README.md` - Good overview
- `/Theories/Bimodal/README.md` - Excellent (334 lines, comprehensive)
- `/Theories/Bimodal/Metalogic/README.md` - Excellent (384 lines, architecture diagrams)
- `/Theories/Bimodal/Metalogic/Core/README.md`
- `/Theories/Bimodal/Metalogic/Bundle/README.md`
- `/Theories/Bimodal/Metalogic/Soundness/README.md`
- `/Theories/Bimodal/Metalogic/Algebraic/README.md`
- `/Theories/Bimodal/Metalogic/Compactness/README.md`
- `/Theories/Bimodal/Metalogic/Decidability/README.md`
- `/Theories/Bimodal/Metalogic/Representation/README.md`
- `/Theories/Bimodal/Automation/README.md`
- `/Theories/Bimodal/Theorems/Perpetuity/README.md`
- `/Theories/Bimodal/typst/README.md`
- `/Theories/Bimodal/docs/` (5 subdirs with READMEs)
- `/Theories/Bimodal/Boneyard/README.md`
- `/Theories/Bimodal/Boneyard/Task956_IntRat/README.md`
- `/Theories/Bimodal/Boneyard/Task956_StrictDensity/README.md`

**docs/ hierarchy (complete):**
- All 7 subdirectories have README.md files

**Tests/ hierarchy (partial):**
- `/Tests/README.md`
- `/Tests/BimodalTest/README.md`
- `/Tests/BimodalTest/Integration/README.md`
- `/Tests/BimodalTest/Property/README.md`
- `/Tests/BimodalTest/Metalogic_v2/README.md`

**Boneyard/ (partial):**
- `/Boneyard/README.md`
- Multiple subdirectories with READMEs (v2, v3, v4, v5, v7, v8, etc.)

#### Directories MISSING README.md (41 identified)

**Theories/Bimodal/ (20 missing):**
```
Theories/Bimodal/Syntax/
Theories/Bimodal/Semantics/
Theories/Bimodal/ProofSystem/
Theories/Bimodal/Examples/
Theories/Bimodal/Theorems/
Theories/Bimodal/latex/
Theories/Bimodal/latex/subfiles/
Theories/Bimodal/latex/assets/
Theories/Bimodal/latex/build/
Theories/Bimodal/Metalogic/ConservativeExtension/
Theories/Bimodal/Metalogic/Canonical/
Theories/Bimodal/Metalogic/Relational/
Theories/Bimodal/Metalogic/Domain/
Theories/Bimodal/Metalogic/StagedConstruction/
Theories/Bimodal/Boneyard/IntRepresentation/
Theories/Bimodal/Boneyard/Task970/
Theories/Bimodal/Boneyard/Task971/
Theories/Bimodal/Boneyard/Metalogic_v8/
Theories/Bimodal/typst/chapters/
Theories/Bimodal/typst/notation/
```

**Tests/ (5 missing):**
```
Tests/BimodalTest/Theorems/
Tests/BimodalTest/Automation/
Tests/BimodalTest/Semantics/
Tests/BimodalTest/Syntax/
Tests/BimodalTest/ProofSystem/
```

**Boneyard/ (12+ missing):**
```
Boneyard/Metalogic/Compat/
Boneyard/Metalogic/Bundle/
Boneyard/Metalogic/Bundle/CanonicalQuotientApproach/
Boneyard/Metalogic/Bundle/RecursiveSeed/
Boneyard/Metalogic/FDSM_SingleHistory/
Boneyard/Metalogic/Metalogic_v3/Coherence/
Boneyard/Metalogic/Metalogic_v3/TruthLemma/
Boneyard/Metalogic/Metalogic_v4/ (and subdirs)
Boneyard/Metalogic/Metalogic_v5/ (and subdirs)
Boneyard/Metalogic/Metalogic_v7/Bundle/
Boneyard/Metalogic/Metalogic_v8/ (and subdirs)
Boneyard/Metalogic/Metalogic_FMP_orphans/
```

**Top-level (4 missing):**
```
/scripts/
/benchmarks/
/specs/
/build/
```

### 3. Comment Quality Assessment

#### Positive Findings

**Excellent module-level documentation:**
- All Lean files in Theories/Bimodal use `/-! ... -/` header comments
- Headers include: Main Definitions, Main Results, Implementation Notes, References
- Example: `Formula.lean` has 46 lines of header documentation
- Example: `Soundness.lean` has 65 lines of header documentation

**Good docstrings:**
- Public definitions use `/-- ... -/` docstrings
- Type signatures documented
- Mathlib-style documentation conventions followed

**Comment count (Theories/Bimodal):**
- 2764 comment lines across 119 Lean files
- Average: ~23 comment lines per file

#### Issues to Address

**TODO/FIXME comments (2 found):**
```
Theories/Bimodal/Boneyard/Task956_StrictDensity/DensityFrameCondition_StrictAttempt.lean:1064:
  TODO: Implement this approach if the direct proofs prove too difficult.

Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean:1183:
  -- TODO: This section needs the GContent ⊆ M' argument
```

**DEPRECATED markers (7+ found):**
```
Theories/Bimodal/Boneyard/Metalogic_v8/Bundle/DovetailingChain.lean:12-14
Theories/Bimodal/Boneyard/Task970/TemporalCoherentConstruction.lean:12-14
Theories/Bimodal/Boneyard/IntRepresentation/Representation.lean:16-18
Theories/Bimodal/Metalogic/Representation.lean:17 (obsolete reference)
Theories/Bimodal/Automation/AesopRules.lean:39 (deprecated tm_auto)
```

These are appropriate (marking archived/deprecated code) but should be verified as accurate.

### 4. ROAD_MAP.md Analysis

**Location**: `/specs/ROAD_MAP.md`
**Size**: ~1400 lines (93KB)
**Last Updated**: 2026-03-14

**Strengths:**
- Comprehensive coverage of strategies, architectural decisions, ambitions
- Well-organized with Strategies, Ambitions, Dead Ends, and Phases sections
- Detailed D-from-syntax strategy documentation (Phases 0-8)
- Good historical record of abandoned approaches

**Issues to Update:**
1. **Sorry count outdated** (line 1002): States "11 sorries" but may have changed
2. **Module architecture diagram** (lines 1048-1081): May need updating for new modules
3. **Deprecated files section** (lines 173-176): Lists files as "DEPRECATED" that may now be archived
4. **Phase status markers**: Some phases marked as completed/ongoing may need review
5. **Content Boundaries note** should be verified against actual TODO.md scope

### 5. Existing README Quality Assessment

**Excellent quality examples:**
- `Theories/Bimodal/README.md`: 334 lines, tables, code examples, cross-references
- `Theories/Bimodal/Metalogic/README.md`: 384 lines, architecture diagrams, dependency flowcharts

**Good quality but needs updates:**
- `Theories/README.md`: 34 lines, accurate but brief
- Various Boneyard READMEs: Document archival status appropriately

**Template patterns observed:**
```markdown
# {Directory Name}

{Brief description}

## Purpose
{What this module does}

## Contents
| File | Description |
|------|-------------|
| X.lean | Does Y |

## Status
{Current implementation status}
```

## Decisions

1. **Prioritize active directories**: Theories/Bimodal/* should receive READMEs before Boneyard/*
2. **Skip build directories**: latex/build/, .lake/ don't need READMEs
3. **Simple READMEs for leaf directories**: Syntax/, Semantics/, etc. need file listings only
4. **Keep Boneyard READMEs minimal**: "Archived from X, see Y for details"

## Recommendations

### Phase 1: Comment Cleanup (Estimated: 1 hour)

1. **Resolve TODO comments** (2 instances)
   - Evaluate if TODOs are still relevant
   - Either complete the TODO or remove if obsolete

2. **Verify DEPRECATED markers** (7+ instances)
   - Ensure deprecated code is actually archived
   - Remove markers from files that have been properly archived
   - Update markers to point to replacement modules

3. **Check for stale references**
   - Review comments referencing old module paths
   - Update cross-references to current locations

### Phase 2: README Creation (Estimated: 4-6 hours)

**Priority 1 - Active Theories directories (10 READMEs):**
1. Syntax/ - Formula, Atom, Context definitions
2. Semantics/ - TaskFrame, TaskModel, Truth, Validity
3. ProofSystem/ - Axioms, Derivation
4. Examples/ - Demo and tutorial files
5. Theorems/ - Perpetuity principles, modal theorems
6. Metalogic/ConservativeExtension/
7. Metalogic/Canonical/
8. Metalogic/Domain/
9. Metalogic/StagedConstruction/
10. latex/ - BimodalReference documentation

**Priority 2 - Top-level directories (4 READMEs):**
1. scripts/ - Utility scripts
2. benchmarks/ - Performance benchmarks
3. specs/ - Task artifacts
4. build/ - Build outputs (minimal)

**Priority 3 - Test directories (5 READMEs):**
1. Tests/BimodalTest/Syntax/
2. Tests/BimodalTest/Semantics/
3. Tests/BimodalTest/ProofSystem/
4. Tests/BimodalTest/Theorems/
5. Tests/BimodalTest/Automation/

**Priority 4 - Boneyard directories (15+ READMEs):**
- Create minimal READMEs pointing to ROAD_MAP.md Dead Ends section

### Phase 3: ROAD_MAP.md Update (Estimated: 2 hours)

1. **Verify sorry count**: Run grep and update line 1002
2. **Update module architecture**: Ensure diagram matches current structure
3. **Review phase status markers**: Mark completed phases appropriately
4. **Add new sections if needed**: Document any recent architectural changes
5. **Update "Last Updated" date**: Change from 2026-03-14 to current

### README Template

For each new README.md:

```markdown
# {Directory Name}

{One-sentence description of what this directory contains.}

## Contents

| File | Description |
|------|-------------|
| File1.lean | Brief description |
| File2.lean | Brief description |

## Related Documentation

- [Parent README](../README.md)
- [Relevant reference](path/to/doc.md)
```

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Documentation becomes stale | Medium | Medium | Add "Last Updated" dates to READMEs |
| Inconsistent README styles | Low | Low | Use template consistently |
| Missing directory contents | Low | Medium | Run `ls` before writing each README |

## Appendix

### Search Queries Used

```bash
# Find directories missing README.md
find /path -type d | while read dir; do
  if [ ! -f "$dir/README.md" ]; then echo "Missing: $dir"; fi
done

# Count comment lines in Lean files
grep -c "^/-|^--" *.lean

# Find TODO/FIXME comments
grep -rn "TODO|FIXME" Theories/ --include="*.lean"

# Find DEPRECATED markers
grep -rn "DEPRECATED|deprecated" Theories/ --include="*.lean"
```

### File Counts

| Directory | Lean Files | README Present |
|-----------|------------|----------------|
| Theories/Bimodal/Syntax | 4 | No |
| Theories/Bimodal/Semantics | 5 | No |
| Theories/Bimodal/ProofSystem | 3 | No |
| Theories/Bimodal/Examples | 8 | No |
| Theories/Bimodal/Metalogic | 70+ | Yes (parent) |
