# Implementation Summary: Archive Strict-Semantics Legacy Code

- **Task**: 94 - archive_strict_semantics_legacy
- **Status**: [COMPLETED]
- **Started**: 2026-04-12T00:00:00Z
- **Completed**: 2026-04-12T00:00:00Z
- **Effort**: 1 hour
- **Dependencies**: Task 91 (completed)
- **Artifacts**:
  - [Plan](../plans/01_archive-strict-legacy.md)
  - [Research](../reports/01_archive-strict-legacy.md)
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary-format.md

## Overview

Archived 9 legacy strict-semantics completeness files to `Boneyard/StrictSemanticsLegacy/`, removing approximately 107 sorries from the active (non-Boneyard) codebase. These files were written under strict temporal semantics (G/H with strict `<`) which is incompatible with the current reflexive BX semantics (G/H with `<=`).

## What Changed

- Moved 4 primary targets (UltrafilterChain, DovetailedChain, SuccChainFMCS, FrameConditions/Completeness) totaling 99 sorries
- Moved 2 dependent files (RestrictedTruthLemma, CanonicalConstruction) totaling 4 sorries
- Moved 3 downstream wiring files (BaseCompleteness, DiscreteCompleteness, DenseCompleteness) totaling 4 sorries
- Removed archived imports from `Metalogic.lean` and `FrameConditions.lean`
- Updated `Metalogic.lean` docstring to reference BXCanonical instead of SuccChain
- Updated import paths in 17 Boneyard files (ChainCompleteness + StrictSemanticsLegacy) to use new paths
- Added sorry count tracking to `state.json` repository_health (140 non-Boneyard, 171 Boneyard)
- Wrote `Boneyard/StrictSemanticsLegacy/README.md` documenting archival rationale

## Decisions

- Co-archived BaseCompleteness, DiscreteCompleteness, DenseCompleteness since they depend on CanonicalConstruction (the archived canonical construction, not the active BXCanonical path)
- Updated Boneyard import paths as best-effort (Boneyard is not on the build path)
- Added sorry count tracking to repository_health since state.json had no technical_debt field

## Impacts

- Non-Boneyard sorry count reduced from ~247 to ~140
- `lake build` continues to succeed with no new errors
- Active completeness path (BXCanonical) is unaffected
- FrameConditions module now has 4 submodules instead of 5

## Follow-ups

- Task 103 (roadmap update) should note the archival
- Future task could re-create Base/Discrete/DenseCompleteness wiring using BXCanonical if needed

## References

- `specs/094_archive_strict_semantics_legacy/plans/01_archive-strict-legacy.md`
- `specs/094_archive_strict_semantics_legacy/reports/01_archive-strict-legacy.md`
- `Theories/Bimodal/Boneyard/StrictSemanticsLegacy/README.md`
