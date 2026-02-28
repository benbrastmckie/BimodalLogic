# Research Report: Task #950

**Task**: 950 - move_bimodal_boneyard_contents
**Started**: 2026-02-27T10:00:00Z
**Completed**: 2026-02-27T10:30:00Z
**Effort**: low
**Dependencies**: None
**Sources/Inputs**: Codebase exploration (Theories/Bimodal/Boneyard/, Boneyard/)
**Artifacts**: This report
**Standards**: report-format.md

## Executive Summary

- Source Boneyard contains 112 Lean files totaling 3.1MB across 17 top-level directories/files
- Target directory `/Boneyard/Metalogic/` does not exist; will need to be created
- Only 2 active files import from Boneyard (Demo.lean, MaximalConsistent.lean) - these must be updated or the imports relocated
- Recommend moving all contents since they are all deprecated metalogic code
- Files are well-organized with README.md files explaining deprecation reasons

## Context & Scope

This task involves moving deprecated Lean 4 code from `Theories/Bimodal/Boneyard/` to `Boneyard/Metalogic/`. The source directory contains multiple versions of metalogic implementations that were superseded by newer approaches to the TM bimodal logic completeness proof.

## Findings

### Source Directory Inventory

**Location**: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/`
**Total Size**: 3.1MB
**Total Lean Files**: 112

#### Top-Level Structure

| Item | Type | Purpose |
|------|------|---------|
| Bundle/ | Directory | Coherent bundle constructions (ZornFamily, TemporalLindenbaum, etc.) |
| Compat/ | Directory | Compatibility layer files for deprecated imports |
| Completeness/ | Directory | Archived completeness module (superseded by BFMCS) |
| DeprecatedCompleteness.lean | File | Documents deprecated theorems |
| DurationConstruction.lean | File | Duration-based canonical model (15+ sorries) |
| FDSM/ | Directory | Finite Duration Saturated Model (34 sorries) |
| FDSM_SingleHistory/ | Directory | Single history variant of FDSM |
| Legacy/ | Directory | Obsolete duplicate files |
| Metalogic/ | Directory | First metalogic implementation |
| Metalogic_FMP_orphans/ | Directory | Orphaned FMP closure code |
| Metalogic_v2/ | Directory | Representation-first architecture |
| Metalogic_v3/ | Directory | Unused coherence/truth lemma cases |
| Metalogic_v4/ | Directory | Alternative completeness approach |
| Metalogic_v5/ | Directory | Universal canonical model attempt |
| Metalogic_v7/ | Directory | Witness graph/chain bundle approach |
| Metalogic_v8/ | Directory | Non-standard validity completeness |
| README.md | File | Main deprecation documentation |
| SyntacticApproach.lean | File | Failed syntactic completeness (6+ sorries) |
| TrivialFMP.lean | File | Trivial FMP attempt |

#### Key Subdirectories Detail

**Metalogic/** (Original, 21 files):
- Core/, Soundness/, Representation/, Completeness/, Decidability/, Applications/
- Contains first complete metalogic implementation
- 9+ sorries in representation layer

**Metalogic_v2/** (30 files):
- Reorganized representation-first architecture
- Contains `SemanticCanonicalModel.lean` with sorry-free `semantic_weak_completeness`
- 4 total sorries documented in README

**Bundle/** (16 files, largest subdirectory):
- CoherentConstruction.lean (68KB), ZornFamily.lean (90KB)
- TemporalLindenbaum.lean, SaturatedConstruction.lean
- Multiple approaches to bundle construction

### Target Directory Inventory

**Location**: `/home/benjamin/Projects/ProofChecker/Boneyard/`
**Current Contents**:
- `FMP_Bridge/` - Archived due to architectural limitations (9 sorries)
- `Metalogic_v4/` - Older version of Metalogic_v4 already archived

**Note**: The target `Boneyard/Metalogic/` directory does not exist and must be created.

### Dependency Analysis

**Files importing from Boneyard**:
Only 2 active (non-Boneyard) files import from the source Boneyard:

1. **`Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`**:
   - Imports: `Bimodal.Boneyard.Metalogic_v2.Core.MaximalConsistent`
   - Action: This import should be removed or the code consolidated

2. **`Theories/Bimodal/Examples/Demo.lean`**:
   - Imports: 4 Boneyard modules (Soundness, DeductionTheorem, SemanticCanonicalModel, DecisionProcedure)
   - Action: Demo should be updated to use active modules, or this import pattern should be documented as intentional for demonstration of deprecated code

All other 57 importing files are within the Boneyard itself (internal dependencies).

### Recommended Organization

Since the target `Boneyard/Metalogic/` does not exist, all source contents should be moved there preserving the current structure:

```
Boneyard/
|-- FMP_Bridge/           (existing)
|-- Metalogic_v4/         (existing - may need to be reconciled)
|-- Metalogic/            (NEW - move all contents here)
    |-- Bimodal/          (NEW - preserve source hierarchy)
        |-- Bundle/
        |-- Compat/
        |-- Completeness/
        |-- ...
        |-- README.md
```

**Alternative**: Flatten by moving directly to `Boneyard/Metalogic/` without the `Bimodal/` intermediate:

```
Boneyard/
|-- FMP_Bridge/
|-- Metalogic_v4/         (reconcile with source Metalogic_v4)
|-- Metalogic/            (move all from Theories/Bimodal/Boneyard here)
    |-- Bundle/
    |-- Compat/
    |-- Completeness/
    |-- ...
```

**Recommendation**: Use the flattened approach since:
1. All source code is already specific to Bimodal logic
2. The `Boneyard/` directory is project-level, not theory-level
3. Simpler path structure

### Conflict: Metalogic_v4 Duplication

There is already a `Boneyard/Metalogic_v4/` in the target, and source has `Boneyard/Metalogic_v4/`:

**Source** (Theories/Bimodal/Boneyard/Metalogic_v4/):
- Completeness/MonolithicCompleteness.lean
- Representation/TruthLemmaBackward.lean

**Target** (Boneyard/Metalogic_v4/):
- Completeness/ (directory)
- FMP/ (directory)
- Representation/ (directory)

**Resolution**: Merge the two, checking for file collisions. The source appears to be a subset of a larger Metalogic_v4 that was already partially archived.

## Decisions

1. **Move all contents**: All files in source Boneyard are deprecated metalogic code appropriate for the target
2. **Flatten structure**: Move directly to `Boneyard/Metalogic/` without `Bimodal/` intermediate
3. **Handle Metalogic_v4 conflict**: Merge contents, preserving both sources
4. **Fix external imports**: Either update the 2 active files that import from Boneyard, or document the import path change

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Breaking Demo.lean imports | Update Demo.lean imports before/after move, or document new paths |
| Breaking MaximalConsistent.lean import | Remove dependency on deprecated code - should use active modules |
| Lake build failures | Run `lake build` after move to verify no unexpected dependencies |
| Loss of README context | Preserve all README.md files which document deprecation reasons |

## Implementation Steps

1. Create target directory: `mkdir -p Boneyard/Metalogic`
2. Handle Metalogic_v4 conflict - merge or rename existing
3. Move all contents: `mv Theories/Bimodal/Boneyard/* Boneyard/Metalogic/`
4. Update imports in Demo.lean and MaximalConsistent.lean (or remove if unused)
5. Verify with `lake build`
6. Update any lakefile or module references if needed

## Appendix

### Search Queries Used

- `ls -la` for directory structure
- `find ... -name "*.lean"` for file counts
- `grep -r "import.*Bimodal.Boneyard"` for dependency analysis
- `du -sh` for size analysis

### File Count by Subdirectory

| Directory | Lean Files |
|-----------|------------|
| Bundle/ | 16 |
| Metalogic_v2/ | 30 |
| Metalogic/ | 21 |
| FDSM/ | 4 |
| Metalogic_v5/ | 11 |
| Metalogic_v7/ | 5 |
| Metalogic_v8/ | 5 |
| Other | 20 |
| **Total** | **112** |

### README Files (Deprecation Documentation)

All major directories have README.md files documenting:
- Why code was deprecated
- What replaced it
- Related task numbers
- Any remaining sorries

These should be preserved as they provide valuable historical context.
