# Implementation Plan: Archive Dead Quasimodel Code

- **Task**: 107 - archive_dead_quasimodel_code
- **Status**: [IMPLEMENTING]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/107_archive_dead_quasimodel_code/reports/01_quasimodel-archive-audit.md
- **Artifacts**: plans/01_quasimodel-archive.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Move three orphaned files (OracleStep.lean, OracleCoherence.lean, RoundRobinChain.lean) totaling 44 sorry-lines and ~1,467 lines of dead code to a new `Boneyard/QuasimodelOracle/` subdirectory. OracleCoherence and RoundRobinChain are already in `BXCanonical/Boneyard/`; only OracleStep needs moving from `Quasimodel/`. None of the files are in the build chain, so this is a pure file-reorganization task with zero build risk.

### Research Integration

The research report confirmed:
- All three files are orphaned (no live imports)
- Sorry counts match: OracleStep (25), OracleCoherence (14), RoundRobinChain (5) = 44 total lines
- Existing `Boneyard/RoundRobinChain/` directory creates a naming collision, resolved by using `QuasimodelOracle/` as the subdirectory name
- A comment in `RootScopedChain.lean:451` references the old `Boneyard/RoundRobinChain.lean` path and needs updating
- Existing Boneyard READMEs (e.g., `UltrafilterDeadCode/README.md`) provide a template to follow

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- ROADMAP.md Section "Archived code" already mentions `Boneyard/OracleCoherence.lean` and `Boneyard/RoundRobinChain/`. This task consolidates the oracle-related archive into a single subdirectory under main Boneyard, consistent with the roadmap's documentation of archived approaches.

## Goals & Non-Goals

**Goals**:
- Move OracleStep.lean, OracleCoherence.lean, and RoundRobinChain.lean to `Theories/Bimodal/Boneyard/QuasimodelOracle/`
- Remove the now-empty `BXCanonical/Boneyard/` directory
- Create a README.md in the new archive directory following existing Boneyard conventions
- Update the stale cross-reference in `RootScopedChain.lean`
- Verify `lake build` passes after the move

**Non-Goals**:
- Modifying any Lean source code beyond path references in comments
- Updating `lakefile.lean` or `BXCanonical.lean` (files are already outside build chain)
- Archiving any other files

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Name collision with existing `Boneyard/RoundRobinChain/` | L | L | Using `QuasimodelOracle/` subdirectory avoids collision |
| Broken cross-reference in comments | L | L | Update `RootScopedChain.lean` line 451 |
| OracleCoherence imports OracleStep by old path | L | L | Update import or remove it (archived code, not compiled) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Move Files and Create README [COMPLETED]

**Goal**: Relocate the three orphaned files to `Boneyard/QuasimodelOracle/` and create the archive README.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Boneyard/QuasimodelOracle/`
- [ ] Move `Theories/Bimodal/Metalogic/BXCanonical/Quasimodel/OracleStep.lean` to `Theories/Bimodal/Boneyard/QuasimodelOracle/OracleStep.lean`
- [ ] Move `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/OracleCoherence.lean` to `Theories/Bimodal/Boneyard/QuasimodelOracle/OracleCoherence.lean`
- [ ] Move `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/RoundRobinChain.lean` to `Theories/Bimodal/Boneyard/QuasimodelOracle/RoundRobinChain.lean`
- [ ] Remove the now-empty `Theories/Bimodal/Metalogic/BXCanonical/Boneyard/` directory
- [ ] Update the import in `OracleCoherence.lean` line 14 from `import Bimodal.Metalogic.BXCanonical.Quasimodel.OracleStep` to the new path, or comment it out since the file is archived and not compiled
- [ ] Update the comment in `RootScopedChain.lean` (line ~451) referencing `Boneyard/RoundRobinChain.lean` to point to `Boneyard/QuasimodelOracle/RoundRobinChain.lean`
- [ ] Create `Theories/Bimodal/Boneyard/QuasimodelOracle/README.md` following the pattern in `UltrafilterDeadCode/README.md`:
  - Archive date (2026-04-20)
  - Why archived (oracle step approach has fundamental sorry gaps; backward coherence obstruction)
  - File summary table with sorry counts
  - Note that files were already outside build chain

**Timing**: 20 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Boneyard/QuasimodelOracle/OracleStep.lean` - moved from Quasimodel/
- `Theories/Bimodal/Boneyard/QuasimodelOracle/OracleCoherence.lean` - moved from BXCanonical/Boneyard/
- `Theories/Bimodal/Boneyard/QuasimodelOracle/RoundRobinChain.lean` - moved from BXCanonical/Boneyard/
- `Theories/Bimodal/Boneyard/QuasimodelOracle/README.md` - new file
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - update comment reference

**Verification**:
- All three files exist in `Boneyard/QuasimodelOracle/`
- `BXCanonical/Boneyard/` directory no longer exists
- `BXCanonical/Quasimodel/OracleStep.lean` no longer exists
- README.md exists with archive metadata

---

### Phase 2: Build Verification [COMPLETED]

**Goal**: Confirm `lake build` passes with zero regressions after the file moves.

**Tasks**:
- [ ] Run `lake build` and confirm success
- [ ] Verify the three moved files are not referenced in any build output or error messages
- [ ] Confirm sorry count in active tree has not changed (files were already outside build chain)

**Timing**: 10 minutes

**Depends on**: 1

**Files to modify**: None (verification only)

**Verification**:
- `lake build` completes successfully
- No new errors or warnings related to the moved files

## Testing & Validation

- [ ] `lake build` passes without errors
- [ ] `grep -r "OracleStep" Theories/Bimodal/Metalogic/BXCanonical/` returns no results (only Boneyard references remain)
- [ ] `grep -r "BXCanonical/Boneyard" Theories/` returns no results (old directory removed)
- [ ] README.md in `Boneyard/QuasimodelOracle/` contains archive date, file table, and sorry counts

## Artifacts & Outputs

- `Theories/Bimodal/Boneyard/QuasimodelOracle/OracleStep.lean`
- `Theories/Bimodal/Boneyard/QuasimodelOracle/OracleCoherence.lean`
- `Theories/Bimodal/Boneyard/QuasimodelOracle/RoundRobinChain.lean`
- `Theories/Bimodal/Boneyard/QuasimodelOracle/README.md`

## Rollback/Contingency

Since these are git-tracked file moves, rollback is trivial: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` to restore original file locations. No code logic changes are involved.
