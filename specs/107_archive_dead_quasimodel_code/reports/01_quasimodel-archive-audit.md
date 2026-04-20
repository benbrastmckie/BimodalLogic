# Quasimodel Dead Code Archive Audit

- **Task**: 107 - archive_dead_quasimodel_code
- **Started**: 2026-04-20T00:00:00Z
- **Completed**: 2026-04-20T00:30:00Z
- **Effort**: Small (file moves + README creation)
- **Dependencies**: None
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean`
  - `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/OracleCoherence.lean`
  - `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/RoundRobinChain.lean`
  - `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` (module listing)
  - `lakefile.lean` (build configuration)
  - Existing `Theories/Bimodal/Boneyard/` directory structure
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md

## Executive Summary

- All three target files are confirmed orphaned: none are imported by any file in the active build chain.
- Sorry counts match the task description exactly: OracleStep (25 lines mentioning sorry), OracleCoherence (14), RoundRobinChain (5) = 44 total lines.
- Of these, 19 are executable sorry statements (10 + 6 + 3); the remainder are documentary comments about sorry usage.
- OracleCoherence and RoundRobinChain are already in `BXCanonical/Boneyard/`; only OracleStep needs moving from `Quasimodel/`.
- The main `Theories/Bimodal/Boneyard/` directory already exists with 6 subdirectories and 4 READMEs, providing a clear pattern to follow.
- No other orphaned files were found in BXCanonical -- all other files are reachable from the build root.

## Context & Scope

The task asks to move three orphaned files from `BXCanonical/` to the main `Boneyard/` directory, remove them from the build chain, and add a README.

### Build Configuration

The project uses Lake with `roots := #[`Bimodal]` and a root file `Theories/Bimodal.lean` that re-exports via `Bimodal.Bimodal`. Compilation follows the transitive import graph starting from `BXCanonical.lean`. Files not reachable through imports are not compiled.

### Current File Locations

| File | Current Location | In Build? |
|------|-----------------|-----------|
| OracleStep.lean | `BXCanonical/Quasimodel/OracleStep.lean` | No (not imported) |
| OracleCoherence.lean | `BXCanonical/Boneyard/OracleCoherence.lean` | No (already in boneyard) |
| RoundRobinChain.lean | `BXCanonical/Boneyard/RoundRobinChain.lean` | No (already in boneyard) |

## Findings

### 1. Sorry Counts (Verified)

| File | Total sorry lines | Executable sorry | Lines | Status |
|------|------------------|-----------------|-------|--------|
| OracleStep.lean | 25 | 10 | 458 | Orphaned in Quasimodel/ |
| OracleCoherence.lean | 14 | 6 | 500 | Already in BXCanonical/Boneyard/ |
| RoundRobinChain.lean | 5 | 3 | 509 | Already in BXCanonical/Boneyard/ |
| **Total** | **44** | **19** | **1,467** | |

### 2. Import Analysis

- **OracleStep.lean** is imported ONLY by `BXCanonical/Boneyard/OracleCoherence.lean` (itself orphaned). No live code depends on it.
- **OracleCoherence.lean** is imported by nothing.
- **RoundRobinChain.lean** is imported by nothing. It is referenced in comments within `RootScopedChain.lean` (line 451: "has been archived to `Boneyard/RoundRobinChain.lean`").

### 3. Existing Boneyard Structure

The main `Theories/Bimodal/Boneyard/` already contains 6 subdirectories:
- `BundleTemporalCoherence/` (with README)
- `ChainCompleteness/` (multiple subdirectories)
- `DiscreteXY/`
- `RoundRobinChain/` (DRMChain.lean + ProofSketch_Sections1to30.lean)
- `StrictSemanticsLegacy/` (with README)
- `TAxiomDependentCode/` (with README)
- `UltrafilterDeadCode/` (with README)

The `Boneyard/RoundRobinChain/` already exists with 2 files (2,522 lines). This creates a naming consideration for the BXCanonical RoundRobinChain file being moved.

### 4. No Other Orphaned Files

All other `.lean` files in `BXCanonical/` are reachable through the import chain:
- `BXCanonical.lean` (root) imports `Frame`, `TruthLemma`, `Completeness`, `CanonicalChain`, and 5 Quasimodel files
- `Completeness` -> `RootScopedChain` -> `CanonicalModel` + `OrderedSeedConsistency`
- `CanonicalChain` -> `Filtration/DefectChain` -> `Filtration/SigmaOrdering` -> `Quasimodel/EnrichedClosure`

`EnrichedClosure.lean` (0 sorries, 158 lines) is live code despite being in Quasimodel/ alongside OracleStep.

### 5. BXCanonical/Boneyard vs Main Boneyard

The BXCanonical subdirectory has its own local `Boneyard/` with 2 files (OracleCoherence and RoundRobinChain) but no README. The task description says to move files to "main Boneyard/" which is `Theories/Bimodal/Boneyard/`.

### 6. No Build Chain Impact

Since none of the three files are compiled (confirmed by absence of `.olean` artifacts in `.lake/build/lib/`), removing or moving them has zero build impact. The "remove from build chain" part of the task is already done -- they were never in it.

## Decisions

### Recommended Destination Structure

Create a new subdirectory in the main Boneyard:

```
Theories/Bimodal/Boneyard/QuasimodelOracle/
  OracleStep.lean
  OracleCoherence.lean
  RoundRobinChain.lean
  README.md
```

This avoids collision with the existing `Boneyard/RoundRobinChain/` directory.

### README Template

Follow the pattern established by `UltrafilterDeadCode/README.md`:
- Archive date
- Why the code was archived (oracle step approach has fundamental sorry gaps)
- Summary table of files and sorry counts
- Git history retrieval instructions
- Note that files are already not in build chain

## Recommendations

1. **Move OracleStep.lean** from `BXCanonical/Quasimodel/` to `Boneyard/QuasimodelOracle/`.
2. **Move OracleCoherence.lean and RoundRobinChain.lean** from `BXCanonical/Boneyard/` to `Boneyard/QuasimodelOracle/`.
3. **Delete the now-empty `BXCanonical/Boneyard/` directory** after the move.
4. **Create README.md** in the new Boneyard subdirectory following existing conventions.
5. **Update the comment in `RootScopedChain.lean`** (line 451) that references `Boneyard/RoundRobinChain.lean` to point to the new location.
6. **No lakefile or BXCanonical.lean changes needed** -- these files are already outside the build chain.
7. **Verify with `lake build`** after the move to confirm no regressions.

## Risks & Mitigations

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Name collision with existing `Boneyard/RoundRobinChain/` | Medium | Use `QuasimodelOracle/` subdirectory name |
| Broken cross-reference in comments | Low | Update `RootScopedChain.lean` line 451 |
| Future developer confusion about what's live | Low | README in archive directory explains status |

## Appendix

### Import Chain Verification

```
Bimodal.lean
  -> Bimodal/Bimodal.lean
    -> Metalogic/Metalogic.lean
      -> BXCanonical/BXCanonical.lean
        -> Frame, TruthLemma, Completeness, CanonicalChain
        -> Quasimodel/{SubformulaClosure,HintikkaPoint,Construction,Realization,LocusControl}
        (OracleStep NOT listed -- orphaned)
```

### OracleCoherence Import of OracleStep

`OracleCoherence.lean` line 14: `import Bimodal.Metalogic.BXCanonical.Quasimodel.OracleStep`

This internal dependency means OracleCoherence must be moved together with OracleStep, or the import updated post-move. Since both are going to the same archive directory, the import should be updated to use the new module path (or removed, since the code is archived and not compiled).

### Sorry Classification in OracleStep.lean

The 10 executable sorries fall into three categories:
1. **H-backward gaps** (3 sorries): Require `h = sigma_sig(w)` which Lindenbaum extension does not guarantee
2. **Until-propagation guard gaps** (4 sorries): Need `psi' not in w` from `psi' not in h`, requires `h supseteq sigma_sig(w)`
3. **Defect-count decrease gaps** (3 sorries): Lindenbaum extension may introduce new Until-defects

Per the file's own documentation, these sorries "never fire on the actual completeness proof path" because the oracle is always called on sigma_signatures in practice.
